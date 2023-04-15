import Foundation
import MultipeerConnectivity

enum AyAyContractClientProgress {
    case initialized
    case connectedByCustomer
    case sentPayment
    case cancelled
    // case waitingForAuthorized
    case receivedAuthorizedPayment
    case finished
}

class AyAyContract : NSObject {
    var session: MCSession?
    var deviceName: String
    var progress: AyAyContractClientProgress
    private var targetPeer: MCPeerID?
    private var paymentCode: String? = nil
    var customerMasterAddress: String!
    private var advertiser: MCNearbyServiceAdvertiser?
    var delegate: AyAyContractClientDelegate? = nil
    init(deviceName: String) {
        self.deviceName = deviceName
        progress = .initialized
        super.init()
        
        session = MCSession(peer: .init(displayName: deviceName))
        session?.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: session!.myPeerID, discoveryInfo: nil, serviceType: "AyAy")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    func sendPaymentTemplate(_ data: String, price: String){
        guard progress == .connectedByCustomer else {
            return
        }
        do{
            try session?.send((data+"/"+price).data(using: .utf8)!, toPeers: session!.connectedPeers, with: .reliable)
            progress = .sentPayment
            delegate?.ayayContract(self, didChange: .sentPayment)
        }catch{
            print(error)
            cancelPayment()
        }
    }
    
    func recieveAuthorizedPayment() {
        guard progress == .sentPayment else{
            return
        }
        
    }
    func cancelPayment() {
        progress = .cancelled
        delegate?.ayayContract(self, didChange: .cancelled)
    }
    func restart()
    {
        paymentCode = nil
        progress = .initialized
        session?.disconnect()
        session = MCSession(peer: .init(displayName: deviceName))
        session?.delegate = self
        advertiser = MCNearbyServiceAdvertiser(peer: session!.myPeerID, discoveryInfo: nil, serviceType: "AyAy")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
}

extension AyAyContract : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
        advertiser.stopAdvertisingPeer()
        
    }
}

extension AyAyContract : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // find -> send a token
        if state == .connected {
            targetPeer = peerID
            self.progress = .connectedByCustomer
            delegate?.ayayContract(self, didChange: .connectedByCustomer)
            
            do {
                delegate?.ayayContract(self, didFindCustomer: peerID.displayName)
                return
            }
        }else if state == .notConnected {
            self.progress = .cancelled
            delegate?.ayayContract(self, didChange: .cancelled)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if progress == .connectedByCustomer {
            customerMasterAddress = String(data: data, encoding: .utf8)
        }
        
        else if progress == .sentPayment {
            paymentCode = String(data: data, encoding: .utf8)
            progress = .receivedAuthorizedPayment
            delegate?.ayayContract(self, didChange: .receivedAuthorizedPayment)
            delegate?.ayayContract(self, received: paymentCode!)
            self.session?.disconnect()
            // gonyo
            
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}

protocol AyAyContractClientDelegate {
    func ayayContract(_ contract: AyAyContract, didFindCustomer customerName: String) -> Void
    func ayayContract(_ contract: AyAyContract, received payment: String) -> Void
    func ayayContract(_ contract: AyAyContract, didChange state: AyAyContractClientProgress) -> Void
    func ayayContract(_ contract: AyAyContract, payDistance distance: Float) -> Void
}
