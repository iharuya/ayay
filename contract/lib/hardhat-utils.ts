import { ethers } from "hardhat"

export const getSignerFromAddress = async (address: string) => {
  const signers =await ethers.getSigners()
  const signer = signers.find((s) => s.address === address)
  if (!signer) throw new Error(`Signer of ${address} cannot be fetched`)
  return signer
}