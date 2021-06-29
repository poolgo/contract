
module.exports = {
  networks: {
    //
    development: {

      url: "https://test.confluxrpc.com",     // Localhost (default: none)
      type:"conflux",
      network_id: 1,
      networkCheckTimeout:100000,
      privateKeys: [""],
      gas: 9579660,
      gasPrice: 100,

    },
  },
  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.6.12",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 800
        }
      }
    }
  }
}
