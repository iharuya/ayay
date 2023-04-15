import { HardhatUserConfig } from "hardhat/config";
import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";

const accounts = {
  mnemonic: process.env.DEV_MNEMONIC || "",
};
const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    shop1: {
      default: 1,
    },
    consumer1: {
      default: 2,
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts,
    },
    mumbai: {
      url: process.env.RPC_URL_MUMBAI || "",
      accounts,
    },
    scrollAlpha: {
      url: process.env.RPC_URL_SCROLLALPHA || "",
      accounts,
    },
    linea: {
      url: process.env.RPC_URL_LINEA || "",
      accounts,
    },
    gnosis: {
      url: process.env.RPC_URL_GNOSIS || "",
      accounts,
    },
    chiado: {
      url: process.env.RPC_URL_CHIADO || "",
      gasPrice: 1000000000,
      accounts,
    },
  },
  external: {
    contracts: [
      {
        artifacts: "node_modules/@account-abstraction/contracts/artifacts",
      },
    ],
  },
};

export default config;
