import { HardhatUserConfig } from "hardhat/config"
import "dotenv/config"
import "@nomicfoundation/hardhat-toolbox"
import "hardhat-deploy"

const accounts = {
  mnemonic: process.env.DEV_MNEMONIC || ""
}
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800
      }
    }
  },
  namedAccounts: {
    deployer: {
      default: 0
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts
    },
    mumbai: {
      url: process.env.RPC_URL_MUMBAI || "",
      accounts
    },
  },
  external: {
    contracts: [
      {
        artifacts: "node_modules/@account-abstraction/contracts/artifacts"
      }
    ]
  }
}

export default config
