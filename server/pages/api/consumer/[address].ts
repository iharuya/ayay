import { alchemy } from "@/lib/alchemy"
import { testJpyc } from "@/lib/contracts"
import { runMiddleware } from "@/lib/middleware"
import { ethAddress, toChecksumAddress, withZod } from "@/lib/zod"
import { formatUnits, getAddress } from "ethers/lib/utils"
import { NextApiHandler } from "next"
import { z } from "zod"

const GetSchema = z.object({
  query: z.object({ address: ethAddress.transform(toChecksumAddress) })
})

const handleGet = withZod(GetSchema, async (req, res) => {
  // for future when wallet has many tokens
  const result = await alchemy.core.getTokenBalances(req.query.address)
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
