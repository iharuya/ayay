import { businessApi } from "@/lib/BusinessApi"
import { prisma } from "@/lib/db"
import { runMiddleware } from "@/lib/middleware"
import {  withZod } from "@/lib/zod"
import { NextApiHandler } from "next"
import { z } from "zod"

const PostSchema = z.object({
  body: z.object({
    opId: z.number(),
    signature: z.string()
  })
})

const handlePost = withZod(PostSchema, async (req, res) => {
  const dbOp = await prisma.userOperation.findUnique({
    where: {id: req.body.opId}
  })
  if (!dbOp) return res.status(404).json({message: "Op not found"})
  if (dbOp.signature.length > 2) {
    return res.status(400).json({message: "Already signed"})
  }
  const unsignedOp = dbOp
  const singedOp = Object.assign({}, unsignedOp, {signature: req.body.signature})
  const paymentHash = await businessApi.sendOpToMempool(singedOp)
  const txHash = await businessApi.getUserOpReceipt(paymentHash)
  await prisma.userOperation.update({
    where: {id: req.body.opId},
    data: {signature: req.body.signature}
  })

  return res.status(200).json({
    txHash
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
