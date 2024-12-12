const AIChainlinkRequest = artifacts.require("AIChainlinkRequest");

module.exports = function (deployer) {
	          const oracleAddress = "0xD67D6508D4E5611cd6a463Dd0969Fa153Be91101"; // Oracle address
	          // const oracleAddress = "0x1f3829ca4Bce27ECbB55CAA8b0F8B51E4ba2cCF6"; // Oracle address
	          // const oracleAddress = "0x4b37bA768432DDc2F792b623036b6476F53B9E69"; // Oracle address
	          // const oracleAddress = "0xb7Bc0c64C8C9805dd9AC11360E67505439b96017"; // Oracle address
	          // const jobId = web3.utils.padRight(web3.utils.utf8ToHex("592623f3138e43b685f7c6b706385ba5"), 64);
	          // const jobId = "592623f3138e43b685f7c6b706385ba5";
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("6abbdd9d2db94b9fa4ce8aa1b98fd3fb"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("fc5b8f3685fc4adcbb1791d76df0e5d9"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("023fed925b3b4f5a81448584b6c37ec7"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("26118a0be4fc41b580b1f0c224f873f8"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("ec082e473385427d87586f1298bd1ffd"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("3bf4c221925d4cb0ba797e44870f3894"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("bea58b33d7e04546955ddd21b0b57028"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("702e620837044470a53cd34a62ea0286"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("76e2d0b031d041849e0a0a51284eba06"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("5e12e54e2a0443cf85734263c7798d35"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("a1c72316b062480cb27ebf3083d1d1c8"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("602fb8d1c8d74ba4b038e9f59350360c"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("af7418ef55a145bdabd026a23e8fa48c"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("4bff49c03130491cb22640c048b49fad"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("7c846f5960e94f809940fbc99cdbd411"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("1dac3696de4c49ac94088adbfa3c535a"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("2daafda4b3934490884b8ca02e9adb2f"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("d309437ca8e14c1fb7f12087468062df"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("afc834cc5639442d8f66bd5920672d9a"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("83b21a71ff404d788a3892f9e96de6f2"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("a88c2d4c25714f27987747a1df8ac904"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("c4ee20c9f07849af9157bb00fbc80556"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("b11a3da0cd204087a52cc10356b48037"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("4b84b91ea6a8471b8045aa5b10fa9595"), 64);
                  // const jobId = web3.utils.padRight(web3.utils.fromAscii("650647e01b5f4bdfa78221c0d15af6c6"), 64);
                  const jobId = web3.utils.padRight(web3.utils.fromAscii("73d384dc04d7407caa40813c439565b1"), 64);

	          const fee = web3.utils.toWei("0.05", "ether"); // Example fee in LINK tokens
	          const linkTokenAddress = "0xE4aB69C077896252FAFBD49EFD26B5D171A32410"; // Sepolia Base LINK token address

	          deployer.deploy(AIChainlinkRequest, oracleAddress, jobId, fee, linkTokenAddress);
};
