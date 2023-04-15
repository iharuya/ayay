import UIKit
import WebKit
import LocalAuthentication

class PayViewController: UIViewController, WKScriptMessageHandler, AyAyCustomerContractDelegate {
    func ayayContractCancelled(_ contract: AyAyCustomerContract) {
        cancelled = true
    }
    
    func ayayContractDidFindShop(_ contract: AyAyCustomerContract, to shopName: String) {
        DispatchQueue.main.sync {
            shopNameLabel.text = "paying to " + shopName
        }
    }
    
    func ayayContractDidReceived(_ contract: AyAyCustomerContract, payment: String) {
        let substrs = payment.components(separatedBy: "/")
        opHash = substrs[0]
        price = substrs[1]
        DispatchQueue.main.sync {
            
            
            priceLabel.text = price
            payButton.isEnabled = true
        }
    }
    
    func ayayContractDidSucceed(_ contract: AyAyCustomerContract) {
        if self.isBeingPresented {
            dismiss(animated: true)
        }
        dismiss(animated: true)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == key1 {
            contract?.executePayment(message.body as! String)
        }
    }
    
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    var opHash: String?
    var price: String?
    var engine: WKWebView?
    var deviceName: String!
    let handlerName = "ayayPayView"
    var contract: AyAyCustomerContract!
    var cancelled = false
    let key1 = "ayaySignatureReceiver"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.add(self, name: key1)
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        let webPagePreference = WKWebpagePreferences()
        webPagePreference.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webPagePreference
        engine = WKWebView(frame: .zero, configuration: config)
        view.addSubview(engine!)
        contract = .init(deviceName: deviceName)
        guard contract != nil else { return }
        contract.delegate = self
        payButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if cancelled {
            dismiss(animated: true)
        }
        if contract?.state == .initialized {
            contract.tryFindShop(self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    func executeScript(_ script: String, shouldLoad: Bool = false, isRetry: Bool = false)
    {
        var command = ""
        if shouldLoad {
            guard let path: String = Bundle.main.path(forResource: "ethers-5.2.umd.min", ofType: "js") else { return }
            let url = URL(fileURLWithPath: path)
            guard let path2: String = Bundle.main.path(forResource: "index", ofType: "js") else { return }
            let url2 = URL(fileURLWithPath: path2)
            let val = try! String(contentsOf: url)
            let val2 = try! String(contentsOf: url2)
            command = val+val2 + "; " + script
        }else{
            command = script
        }
            engine?.evaluateJavaScript(command, completionHandler: { (object, error) in
                if let object = object {
                    print(object)
                }
                if let error = error {
                    if isRetry {
                        print(error)
                        return
                    }else{
                        print(error)
                        print("retry!")
                    }
                    self.executeScript(script, shouldLoad: !shouldLoad, isRetry: true)
                }
            })
        
    }
    
    @IBAction func buttonPushed(_ sender: Any) {
        let context = LAContext()
        let reason = "This app uses Touch ID / Facd ID to secure your data."
        var authError: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    let script = "signUserOp(\"\(self.contract!.address_private!)\", \"\(self.opHash!)\")"
                    self.executeScript(script);
                    
                } else {
                    self.contract?.cancelPayment()
                    DispatchQueue.main.sync {
                        self.dismiss(animated: true)
                    }
                }
            }
        } else {
            contract?.cancelPayment()
            print(authError!)
            dismiss(animated: true)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    

}
