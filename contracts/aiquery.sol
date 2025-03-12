// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// Import the Chainlink client contract
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * @title AIChainlinkRequest
 * @dev This contract allows users to request AI evaluations via a Chainlink oracle.
 *      It supports two flows:
 *        1. Pre-funded requests: the contract already holds LINK.
 *        2. User-funded requests: the user approves the contract to pull the fee.
 */
contract AIChainlinkRequest is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Oracle and job specifications
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    // Mapping from requestId to evaluation result
    mapping(bytes32 => Evaluation) public evaluations;

    // Struct to store evaluation results
    struct Evaluation {
        uint256[] likelihoods;
        string justificationCID;
        bool exists;
    }

    // Events
    event RequestAIEvaluation(bytes32 indexed requestId, string[] cids);
    event FulfillAIEvaluation(bytes32 indexed requestId, uint256[] likelihoods, string justificationCID);
    event Debug(address linkToken, address oracle, uint256 fee);
    event Debug1(address linkToken, address oracle, uint256 fee, uint256 balance, bytes32 jobId);
    event FulfillmentReceived(
        bytes32 indexed requestId, 
        address caller,
        uint256 likelihoodsLength,
        string justificationCID
    );

    /**
     * @notice Constructor sets up the Chainlink oracle parameters
     * @param _oracle The address of the Chainlink oracle contract
     * @param _jobId The job ID for the Chainlink request
     * @param _fee The fee required to make a request (in LINK tokens)
     * @param _link The address of the LINK token contract
     */
    constructor(address _oracle, bytes32 _jobId, uint256 _fee, address _link) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;

        // Pre-fund approval for the oracle if using the pre-funded flow.
        // (This does not affect the user-funded flow.)
        LinkTokenInterface link = LinkTokenInterface(_link);
        require(link.approve(_oracle, type(uint256).max), "Failed to approve LINK");
    }

    /**
     * @notice Request an AI evaluation via the Chainlink oracle using pre-funded LINK.
     * @param cids An array of IPFS CIDs representing the data to be evaluated
     * @return requestId The ID of the Chainlink request
     */
    function requestAIEvaluation(string[] memory cids) public returns (bytes32 requestId) {
        require(cids.length > 0, "CIDs array must not be empty");

        // Debug logs
        address linkAddress = chainlinkTokenAddress();
        uint256 linkBalance = LinkTokenInterface(linkAddress).balanceOf(address(this));
        require(linkAddress != address(0), "LINK token not initialized");
        require(oracle != address(0), "Oracle not set");
        require(fee > 0, "Fee not set");
        
        emit Debug(linkAddress, oracle, fee);
        emit Debug1(linkAddress, oracle, fee, linkBalance, jobId);

        // Build the Chainlink request
        Chainlink.Request memory request = buildOperatorRequest(jobId, this.fulfill.selector);
        string memory cidsConcatenated = concatenateCids(cids);
        request.add("cid", cidsConcatenated);

        // Send the request using pre-funded LINK from the contract
        requestId = sendOperatorRequest(request, fee);

        emit RequestAIEvaluation(requestId, cids);
    }

    /**
     * @notice Request an AI evaluation via the Chainlink oracle using user-funded LINK.
     *         The caller must have approved this contract for at least the fee amount.
     * @param cids An array of IPFS CIDs representing the data to be evaluated
     * @return requestId The ID of the Chainlink request
     */
    function requestAIEvaluationWithApproval(string[] memory cids) public returns (bytes32 requestId) {
        require(cids.length > 0, "CIDs array must not be empty");

        // Pull exactly the fee amount from the caller via transferFrom.
        require(
            LinkTokenInterface(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), fee),
            "transferFrom for fee failed"
        );

        // Build the Chainlink request
        Chainlink.Request memory request = buildOperatorRequest(jobId, this.fulfill.selector);
        string memory cidsConcatenated = concatenateCids(cids);
        request.add("cid", cidsConcatenated);

        // Send the request using the fee just pulled from the caller.
        requestId = sendOperatorRequest(request, fee);

        emit RequestAIEvaluation(requestId, cids);
    }

    /**
     * @notice New function with the same interface as the aggregator.
     *         It accepts additional parameters for alpha, maxFee, estimatedBaseCost, and maxFeeBasedScalingFactor,
     *         but these values are ignored.
     * @param cids An array of IPFS CIDs representing the data to be evaluated.
     * @return requestId The ID of the Chainlink request.
     */
    function requestAIEvaluationWithApproval(
        string[] memory cids,
        uint256 /* _alpha */,
        uint256 /* _maxFee */,
        uint256 /* _estimatedBaseCost */,
        uint256 /* _maxFeeBasedScalingFactor */
    ) public returns (bytes32 requestId) {
        // Even though these parameters are accepted,
        // they are ignored in this simple contract.
        require(cids.length > 0, "CIDs array must not be empty");

        require(
            LinkTokenInterface(chainlinkTokenAddress()).transferFrom(msg.sender, address(this), fee),
            "transferFrom for fee failed"
        );

        Chainlink.Request memory request = buildOperatorRequest(jobId, this.fulfill.selector);
        string memory cidsConcatenated = concatenateCids(cids);
        request.add("cid", cidsConcatenated);

        requestId = sendOperatorRequest(request, fee);
        emit RequestAIEvaluation(requestId, cids);
    }

    /**
     * @notice Callback function called by the Chainlink oracle with the AI evaluation results.
     * @param _requestId The ID of the Chainlink request.
     * @param likelihoods An array of integers representing the likelihoods of each option.
     * @param justificationCID The CID of the textual justification for the evaluation.
     */
    function fulfill(
        bytes32 _requestId,
        uint256[] memory likelihoods,
        string memory justificationCID
    ) public recordChainlinkFulfillment(_requestId) {
        emit FulfillmentReceived(
            _requestId, 
            msg.sender,  // This shows which address is calling fulfill
            likelihoods.length,
            justificationCID
        );
        require(likelihoods.length > 0, "Likelihoods array must not be empty");
        require(bytes(justificationCID).length > 0, "Justification CID must not be empty");

        // Store the evaluation results
        evaluations[_requestId] = Evaluation({
            likelihoods: likelihoods,
            justificationCID: justificationCID,
            exists: true
        });

        emit FulfillAIEvaluation(_requestId, likelihoods, justificationCID);
    }

    /**
     * @notice Helper function to concatenate CIDs into a single string separated by commas.
     * @param cids An array of IPFS CIDs.
     * @return A single string containing all CIDs separated by commas.
     */
    function concatenateCids(string[] memory cids) internal pure returns (string memory) {
        bytes memory concatenatedCids;
        for (uint256 i = 0; i < cids.length; i++) {
            concatenatedCids = abi.encodePacked(concatenatedCids, cids[i]);
            if (i < cids.length - 1) {
                concatenatedCids = abi.encodePacked(concatenatedCids, ",");
            }
        }
        return string(concatenatedCids);
    }

    /**
     * @notice Allows the contract owner to withdraw any LINK tokens held by the contract.
     * @param _to The address to send the LINK tokens to.
     * @param _amount The amount of LINK tokens to withdraw.
     */
    function withdrawLink(address payable _to, uint256 _amount) external {
        require(_to != address(0), "Invalid recipient address");
        LinkTokenInterface linkToken = LinkTokenInterface(chainlinkTokenAddress());
        require(linkToken.transfer(_to, _amount), "Unable to transfer");
    }

    /**
     * @notice Returns the contract configuration.
     * @return oracleAddr The oracle address.
     * @return linkAddr The LINK token address.
     * @return jobid The Chainlink job ID.
     * @return currentFee The fee used for requests.
     */
    function getContractConfig() public view returns (
        address oracleAddr,
        address linkAddr,
        bytes32 jobid,
        uint256 currentFee
    ) {
        return (oracle, chainlinkTokenAddress(), jobId, fee);
    }

    function getEvaluation(bytes32 _requestId) 
        public 
        view 
        returns (uint256[] memory likelihoods, string memory justificationCID, bool exists) 
    {
        Evaluation storage eval = evaluations[_requestId];
        return (eval.likelihoods, eval.justificationCID, eval.exists);
    }
}

