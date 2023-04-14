import "dotenv/config"
interface NetworkConfig {
  confirmations?: number
  verifiable?: boolean
  bundlerUrl?: string
  entryPoint?: string
  myWalletFactory?: string
  myWalletPaymaster?: string
}
interface NetworksConfig {
  [networkName: string]: NetworkConfig | undefined
}
export const networksConfig: NetworksConfig = {
  hardhat: {
    confirmations: 1,
    bundlerUrl: "http://localhost:4337",
  },
  localhost: {
    confirmations: 1,
    bundlerUrl: "http://localhost:4337",
  },
  mumbai: {
    confirmations: 6,
    bundlerUrl: process.env.BUNDLER_URL_MUMBAI,
  },
}