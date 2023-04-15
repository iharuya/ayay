function initCustomer() {
  const baseUrl = "https://ayay-server-iharuya.vercel.app/api"
  const wallet = ethers.Wallet.createRandom()
  fetch(`${baseUrl}/consumer/init`, {
    method: "POST",
    body: JSON.stringify({
      masterAddress: wallet.address
    }),
    headers: {
      'Content-Type': 'application/json'
    }
  }).then(res => res.json())
    .then(result => {
      const ayayAddress = result
      webkit.messageHandlers.ayayAccountKeyReceiver.postMessage(wallet.privateKey)
      webkit.messageHandlers.ayayAccountAddressReceiver.postMessage(wallet.address)
      webkit.messageHandlers.ayayAccountWalletReceiver.postMessage(ayayAddress)
    })
    .catch(e => {
      webkit.messageHandlers.ayayInitErrorReceiver.postMessage(`failed!! error: ${e}`)
    })
}

/**
 * ayay walletの残高を取得する
 * @param walletAddress string
 * @returns string (example: "101.5")
 */
function getBalance(walletAddress) {
    const baseUrl = "https://ayay-server-iharuya.vercel.app/api"
    const wallet = ethers.Wallet.createRandom()
    fetch(`${baseUrl}/consumer/${walletAddress}`, {
      method: "GET",
      headers: {
        'Content-Type': 'application/json'
      }
    }).then(res => res.json())
      .then(result => {
        webkit.messageHandlers.ayayAccountBalanceReceiver.postMessage(result)
      })
      .catch(e => {
        webkit.messageHandlers.ayayGetBalanceErrorReceiver.postMessage(`failed!! error: ${e}`)
      })
}

/**
 * マスターキーを使って署名する
 * @param masterKey string
 * @param unsignedOp string
 * @returns signature string
 */
function signUserOp(masterKey, unsignedOpHash) {
  const wallet = new ethers.Wallet(masterKey)
  const message = ethers.utils.arrayify(unsignedOpHash)
  wallet.signMessage(message).then((sig) => {
    webkit.messageHandlers.ayaySignatureReceiver.postMessage(sig)
  })
}

