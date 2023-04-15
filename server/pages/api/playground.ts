import { testJpyc } from "@/lib/contracts";
import { prisma } from "@/lib/db";
import { runMiddleware } from "@/lib/middleware";
import { NextApiHandler } from "next";

const handler: NextApiHandler = async(req, res) => {
  await runMiddleware(req, res)
  if (req.method !== "GET") return res.status(405).json({message: "Method not allowed"})
  const name = await testJpyc.name()
  const ops = await prisma.userOperation.findMany()
  return res.status(200).json({name, ops})
}


export default handler