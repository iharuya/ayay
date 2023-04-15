import { Alchemy, Network } from 'alchemy-sdk';
import "dotenv/config"
import { assertIsDefined } from './utils';
import { ethers } from 'ethers';

assertIsDefined(process.env.ALCHEMY_KEY)
const settings = {
  apiKey: process.env.ALCHEMY_KEY,
  network: Network.MATIC_MUMBAI,
};
export const alchemy = new Alchemy(settings);
export const provider = new ethers.providers.AlchemyProvider("maticmum", process.env.ALCHEMY_KEY)