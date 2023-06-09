import { provider } from "./alchemy";
import { AyAyFactory__factory, AyAyPaymaster__factory, AyAyReceiver__factory, TestJPYC__factory } from "@/typechain-types";
import { EntryPoint__factory } from "@account-abstraction/contracts";
import { assertIsDefined } from "./utils";
import { ethers } from "ethers";

assertIsDefined(process.env.DEPLOYER_PRIVATE_KEY)
const deployerSigner = new ethers.Wallet(process.env.DEPLOYER_PRIVATE_KEY, provider)
export const entryPoint = EntryPoint__factory.connect("0x0576a174D229E3cFA37253523E645A78A0C91B57", provider)
export const testJpyc = TestJPYC__factory.connect("0xF7f571309c7BFc2E6565cA6Ca13c093D78BcF90f", deployerSigner)
export const factory = AyAyFactory__factory.connect("0xc1C84de4313b270D0e2299C36D4D90ddfC3A7C9e", provider)
export const shop1_receiver = AyAyReceiver__factory.connect("0x17846F6BFA76c1D7D08873148C9813b6B1D98ce7", provider)
export const shop1_paymaster = AyAyPaymaster__factory.connect("0xa7A67146470571E4183D8E9219DBb4674D831B55", provider)