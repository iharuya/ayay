import { NextApiRequest, NextApiResponse } from "next"
import { z, ZodSchema } from "zod"
import { getAddress, isAddress } from "ethers/lib/utils"
import { ethers } from "ethers"

export function withZod<T extends ZodSchema>(
  schema: T,
  next: (
    /* eslint-disable no-unused-vars */
    req: Omit<NextApiRequest, "query" | "body"> & z.infer<T>,
    res: NextApiResponse
    /* eslint-enable */
  ) => unknown | Promise<unknown>
) {
  return async (req: NextApiRequest, res: NextApiResponse) => {
    const parsed = schema.safeParse(req)
    if (!parsed.success) {
      res.status(400).json({
        message: "Bad Request",
        issues: JSON.parse(parsed.error.message),
      })
      return
    }
    req.query = parsed.data.query
    req.body = parsed.data.body
    return next(req, res)
  }
}

export const ethAddress = z.string().refine((val) => {
  const low = val.toLowerCase()
  return isAddress(low)
}, "Invalid ethereum address")

export const toChecksumAddress = (val: string) => {
  return getAddress(val)
}

export const bigNumberString = z.string().refine((val) => {
  try {
    ethers.BigNumber.from(val)
    return true
  } catch (error) {
    return false
  }
}, "Not big number string")
