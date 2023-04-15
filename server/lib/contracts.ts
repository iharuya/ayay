import { provider } from "./alchemy";
import { TestJPYC__factory } from "@/typechain-types";
import { EntryPoint__factory } from "@account-abstraction/contracts";

export const entryPoint = EntryPoint__factory.connect("0x0576a174D229E3cFA37253523E645A78A0C91B57", provider)
export const testJpyc = TestJPYC__factory.connect("0xF7f571309c7BFc2E6565cA6Ca13c093D78BcF90f", provider)