import { ethAddress, toChecksumAddress, withZod } from "@/lib/zod"
import { NextApiHandler } from "next"
import { z } from "zod"
import { runMiddleware } from "@/lib/middleware"

const PostSchema = z.object({
  body: z.object({})
})

const handlePost = withZod(PostSchema, async (req, res) => {
  // @todo
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
