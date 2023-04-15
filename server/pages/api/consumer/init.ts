import { ethAddress, toChecksumAddress, withZod } from "@/lib/zod"
import { NextApiHandler } from "next"
import { z } from "zod"
import { runMiddleware } from "@/lib/middleware"
import { businessApi } from "@/lib/BusinessApi"
import { DEFAULT_WALLET_INDEX } from "@/config"

const PostSchema = z.object({
  body: z.object({ masterAddress: ethAddress.transform(toChecksumAddress) })
})

const handlePost = withZod(PostSchema, async (req, res) => {
  const walletAddress = await businessApi.getWalletAddress({
    masterAddress: req.body.masterAddress,
    index: DEFAULT_WALLET_INDEX
  })
  return res.status(200).json(walletAddress)
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
