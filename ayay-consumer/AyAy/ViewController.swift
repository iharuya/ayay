import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == handlerName) {
            address_key = message.body as? String
            UserDefaults.standard.set(address_key, forKey: "KEY")
        }
        if(message.name == handlerName2){
            address_pub = message.body as? String
            UserDefaults.standard.set(address_pub, forKey: "PUBLIC")
        }
        if(message.name == handlerName3){
            address_wallet = message.body as? String
            addressLabel.text = address_wallet
            UserDefaults.standard.set(address_wallet, forKey: "WALLET")
            payButton.isEnabled = true
        }
        if(message.name == handlerName4){
            let alert = UIAlertController(title: "from Web", message: message.body as? String, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        if(message.name == handlerName5){
            balanceLabel.text = message.body as? String
            UserDefaults.standard.set(address_wallet, forKey: "BALANCE")
            balanceLabel.textColor = .black
        }
        if(message.name == handlerName6){
            balanceLabel.text = UserDefaults.standard.string(forKey: "BALANCE") ?? "0"
            balanceLabel.textColor = .gray
            print(message.body)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        testimport()
    }
    
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    var engine: WKWebView?
    var address_pub: String?
    var address_key: String?
    var address_wallet: String?
    var deviceName: String?
    let handlerName = "ayayAccountKeyReceiver"
    let handlerName2 = "ayayAccountAddressReceiver"
    let handlerName3 = "ayayAccountWalletReceiver"
    let handlerName4 = "ayayDataReceiver"
    let handlerName5 = "ayayAccountBalanceReceiver"
    let handlerName6 = "ayayReceive"

    override func viewDidLoad() {
        super.viewDidLoad()
//        #if DEBUG
//        UserDefaults.standard.removeObject(forKey: "KEY")
//        UserDefaults.standard.removeObject(forKey: "PUBLIC")
//        UserDefaults.standard.removeObject(forKey: "WALLET")
//        #endif
        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.add(self, name: handlerName)
        userContentController.add(self, name: handlerName2)
        userContentController.add(self, name: handlerName3)
        userContentController.add(self, name: handlerName4)
        userContentController.add(self, name: handlerName5)
        userContentController.add(self, name: handlerName6)
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        let webPagePreference = WKWebpagePreferences()
        webPagePreference.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webPagePreference
        engine = WKWebView(frame: .zero, configuration: config)
        engine?.navigationDelegate = self
        view.addSubview(engine!)
        payButton.isEnabled = false
    }
    @IBAction func reloadBalance(_ sender: Any) {
        let script = "getBalance(\"\(address_wallet!)\");"
        executeScript(script)
    }
    
    @IBAction func payButtonPushed(_ sender: Any) {
        deviceName = "consumer1"
        performSegue(withIdentifier: "paySegue", sender: self)
    }
    
    
    @IBAction func closeKeyboard(_ sender: UITextField) {
        sender.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let str1 = UserDefaults.standard.string(forKey: "KEY") {
            address_key = str1
        }else{
            createAccount()
        }
        if let str2 = UserDefaults.standard.string(forKey: "PUBLIC") {
            address_pub = str2
        }
        if let str3 = UserDefaults.standard.string(forKey: "WALLET") {
            address_wallet = str3
            addressLabel.text = str3
            payButton.isEnabled = true
            let script = "getBalance(\"\(address_wallet!)\");"
            executeScript(script)
        }
    }
    
    func createAccount() {
        print("creating account...")
        executeScript("initCustomer()")
    }
    
    func JS(_ filename: String) {
        guard let path: String = Bundle.main.path(forResource: filename, ofType: "js") else { return }
        let url = URL(fileURLWithPath: path)
        engine?.evaluateJavaScript(try! String(contentsOf: url) + "test();", completionHandler: { (object, error) in
            if let object = object {
                print(object)
            }
            if let error = error {
                print(error)
            }
        })
    }
    
    func testimport(){
        guard let path: String = Bundle.main.path(forResource: "ethers-5.2.umd.min", ofType: "js") else { return }
        let url = URL(fileURLWithPath: path)
        guard let path2: String = Bundle.main.path(forResource: "index", ofType: "js") else { return }
        let url2 = URL(fileURLWithPath: path2)
        let val = try! String(contentsOf: url)
        let val2 = try! String(contentsOf: url2)
        engine?.evaluateJavaScript(val+val2 + "createMasterKey();", completionHandler: { (object, error) in
            if let object = object {
                print(object)
            }
            if let error = error {
                print(error)
            }
        })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! PayViewController
        vc.deviceName = deviceName ?? "consumer1"
    }
}

