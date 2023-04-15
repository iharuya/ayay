-- CreateTable
CREATE TABLE "UserOperation" (
    "id" SERIAL NOT NULL,
    "sender" TEXT NOT NULL,
    "nonce" TEXT NOT NULL,
    "initCode" TEXT NOT NULL,
    "callData" TEXT NOT NULL,
    "callGasLimit" TEXT NOT NULL,
    "verificationGasLimit" TEXT NOT NULL,
    "preVerificationGas" TEXT NOT NULL,
    "maxFeePerGas" TEXT NOT NULL,
    "maxPriorityFeePerGas" TEXT NOT NULL,
    "paymasterAndData" TEXT NOT NULL,
    "signature" TEXT NOT NULL,

    CONSTRAINT "UserOperation_pkey" PRIMARY KEY ("id")
);
