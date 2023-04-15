import { ethAddress, toChecksumAddress, withZod } from "@/lib/zod"
import { NextApiHandler } from "next"
import { z } from "zod"
import { runMiddleware } from "@/lib/middleware"
import { testJpyc } from "@/lib/contracts"
import { ethers } from "ethers"

const PostSchema = z.object({
  body: z.object({ address: ethAddress.transform(toChecksumAddress) })
})

const handlePost = withZod(PostSchema, async (req, res) => {
  testJpyc.transfer(req.body.address, ethers.utils.parseUnits("1000", 6))
  return res.status(200).json({message: "1,000 JPYC deposit in queue..."})
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
