import Foundation
import MultipeerConnectivity

enum AyAyCustomerContractState {
    case initialized
    case foundShop
    case waitingForPayment
    case cancelled
    case receivedPayment
    case authorizedPayment
    case finished
}

class AyAyCustomerContract: NSObject, MCSessionDelegate, MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
        cancelPayment()
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            delegate?.ayayContractDidFindShop(self, to: peerID.displayName)
            do{
                try session.send(address_public.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                self.state = .foundShop
            }catch{
                cancelPayment()
            }
        }
        
        if self.state == .foundShop {
            self.state = .waitingForPayment
        }
        
        if state == .notConnected && self.state != .finished {
            cancelPayment()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if self.state == .waitingForPayment {
            if let str = String.init(data: data, encoding: .utf8) {
                state = .receivedPayment
                delegate?.ayayContractDidReceived(self, payment: str)
            }else{
                cancelPayment()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    var state : AyAyCustomerContractState = .initialized
    var session: MCSession?
    var shopID: MCPeerID?
    var browser: MCBrowserViewController?
    var delegate: AyAyCustomerContractDelegate?
    var wallet: String!
    var address_private: String!
    var address_public: String!
    init?(deviceName: String) {
        super.init()
        session = .init(peer: .init(displayName: deviceName))
        session?.delegate = self
        guard let str = UserDefaults.standard.string(forKey: "WALLET") else {
            return nil
        }
        wallet = str
        guard let str2 = UserDefaults.standard.string(forKey: "KEY") else {
            return nil
        }
        address_private = str2
        guard let str3 = UserDefaults.standard.string(forKey: "PUBLIC") else {
            return nil
        }
        address_public = str3
    }
    
    func tryFindShop(_ vc: UIViewController) {
        browser = .init(serviceType: "AyAy", session: session!)
        browser?.delegate = self
        vc.present(browser!, animated: true)
    }
    
    func cancelPayment()
    {
        state = .cancelled
        session?.disconnect()
        delegate?.ayayContractCancelled(self)
    }
    
    func executePayment(_ data: String)
    {
        guard state == .receivedPayment else {
            return
        }
        guard let sendData = data.data(using: .utf8) else{
            cancelPayment()
            return
        }
        do{
            try session?.send(sendData, toPeers: session!.connectedPeers, with: .reliable)
            state = .authorizedPayment
            delegate?.ayayContractDidSucceed(self)
        }catch{
            cancelPayment()
        }
        state = .finished
    }
    
}

protocol AyAyCustomerContractDelegate {
    func ayayContractCancelled(_ contract: AyAyCustomerContract)
    func ayayContractDidFindShop(_ contract: AyAyCustomerContract, to shopName: String)
    func ayayContractDidReceived(_ contract: AyAyCustomerContract, payment: String)
    func ayayContractDidSucceed(_ contract: AyAyCustomerContract)
}
