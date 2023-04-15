import { alchemy } from "@/lib/alchemy"
import { shop1_receiver, testJpyc } from "@/lib/contracts"
import { runMiddleware } from "@/lib/middleware"
import {  withZod } from "@/lib/zod"
import { formatUnits, getAddress } from "ethers/lib/utils"
import { NextApiHandler } from "next"
import { z } from "zod"

const GetSchema = z.object({})

const handleGet = withZod(GetSchema, async (req, res) => {
  const result = await alchemy.core.getTokenBalances(shop1_receiver.address)
  const jpyc = result.tokenBalances.find((b) => getAddress(b.contractAddress) === testJpyc.address)
  if (!jpyc || jpyc.error) {
    return res.status(200).json("0")
  }
  const jpycBalanceReadable = formatUnits(jpyc.tokenBalance!, 6)
  return res.status(200).json(jpycBalanceReadable)
})

const handler: NextApiHandler = async (req, res) => {
  await runMiddleware(req, res)
  switch (req.method) {
    case "GET":
      return handleGet(req, res)
    default:
      return res.status(405).json({ message: "Method not allowed" })
  }
}

export default handler
