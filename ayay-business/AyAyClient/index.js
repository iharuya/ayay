
function createOp(masterAddress, amount) {
    const baseUrl = "https://ayay-server-iharuya.vercel.app/api"
    fetch(`${baseUrl}/business/payment/create`, {
    method: "POST",
    body: JSON.stringify({
        masterAddress,
        amount
    }),
    headers: {
        "Content-Type": "application/json"
    }
    })
    .then((res) => res.json())
    .then((result) => {
        const unsignedOpHash = result.unsignedOpHash
        const opId = result.opId // number
        webkit.messageHandlers.ayayHashReceiver.postMessage(unsignedOpHash)
        webkit.messageHandlers.ayayIdReceiver.postMessage(opId)
    })
    .catch(e => {
        webkit.messageHandlers.ayayReceive.postMessage(`failed!! error: ${e}`)
    })
}

function sendOp(opId, signature) {
    const baseUrl = "https://ayay-server-iharuya.vercel.app/api"
    fetch(`${baseUrl}/business/payment/send`, {
    method: "POST",
    body: JSON.stringify({
        opId,
        signature
    }),
    headers: {
        "Content-Type": "application/json"
    }
    })
    .then((res) => res.json())
    .then((result) => {
        const txHash = result.txHash
        webkit.messageHandlers.txHashReceiver.postMessage(txHash)
    })
    .catch((e) => {
        webkit.messageHandlers.ayayReceive.postMessage(`failed!! error: ${e}`)
    })
}

// shopの残高を取得　ex. "2000.0"
function getShopBalance() {
    const baseUrl = "https://ayay-server-iharuya.vercel.app/api"
    fetch(`${baseUrl}/business/balance`, {
    method: "GET",
    headers: {
        'Content-Type': 'application/json'
    }
    }).then(res => res.json())
    .then(result => {
        const balance = result
        webkit.messageHandlers.shopBalanceReceiver.postMessage(balance)
    })
    .catch(e => {
        webkit.messageHandlers.ayayReceive.postMessage(`failed!! error: ${e}`)
    })
};
