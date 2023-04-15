import { businessApi } from "@/lib/BusinessApi"
import { testJpyc } from "@/lib/contracts"
import { prisma } from "@/lib/db"
import { runMiddleware } from "@/lib/middleware"
import { ethAddress, toChecksumAddress, withZod } from "@/lib/zod"
import { parseUnits } from "ethers/lib/utils"
import { NextApiHandler } from "next"
import { z } from "zod"
import { DEFAULT_WALLET_INDEX } from "@/config"

const PostSchema = z.object({
  body: z.object({
    masterAddress: ethAddress.transform(toChecksumAddress),
    amount: z.number().positive()
  })
})

const handlePost = withZod(PostSchema, async (req, res) => {
  const unsignedOp = await businessApi.createUnsignedPaymentOp(
    { masterAddress: req.body.masterAddress, index: DEFAULT_WALLET_INDEX },
    { token: testJpyc.address, amount: parseUnits(req.body.amount.toString(), 6) }
  )
  const dbOp = await prisma.userOperation.create({
    data: {
      sender: unsignedOp.sender,
      nonce: unsignedOp.nonce.toString(),
      initCode: unsignedOp.initCode.toString(),
      callData: unsignedOp.callData.toString(),
      callGasLimit: unsignedOp.callGasLimit.toString(),
      verificationGasLimit: unsignedOp.verificationGasLimit.toString(),
      preVerificationGas: unsignedOp.preVerificationGas.toString(),
      maxFeePerGas: unsignedOp.maxFeePerGas.toString(),
      maxPriorityFeePerGas: unsignedOp.maxPriorityFeePerGas.toString(),
      paymasterAndData: unsignedOp.paymasterAndData.toString(),
      signature: unsignedOp.signature.toString(), // ""
    }
  })
  const opHash = businessApi.getUserOpHash(unsignedOp)
  // arraryfies in the client
  // const msg = ethers.utils.arrayify(opHash)
  // const sig = wallet.sign(msg)
  return res.status(200).json({
    unsignedOpHash: opHash,
    opId: dbOp.id
  })
})

const handler: NextApiHandler = async (req, res) => {
  await runMiddleware(req, res)
  switch (req.method) {
    case "POST":
      return handlePost(req, res)
    default:
      return res.status(405).json({ message: "Method not allowed" })
  }
}

export default handler
