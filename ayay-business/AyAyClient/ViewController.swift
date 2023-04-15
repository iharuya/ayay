import UIKit
import MultipeerConnectivity
import WebKit
import Network

class ViewController: UIViewController, AyAyContractClientDelegate, UITableViewDelegate, UITableViewDataSource, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "ayayHashReceiver"{
            currentHash = message.body as? String
        }
        if message.name == "ayayIdReceiver" {
            currentOpId = message.body as? Int
        }
        if currentHash != nil && currentOpId != nil {
            contract?.sendPaymentTemplate(currentHash!, price: textField.text!)
            contract?.recieveAuthorizedPayment()
            messages.append("sent a payments of " + textField.text! + " JPY")
            currentHash = nil
        }
        if message.name == "txHashReceiver" {
            messages.append("txHash " + (message.body as! String))
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = messages[indexPath.row]
        return cell
    }
    
    func ayayContract(_ contract: AyAyContract, didFindCustomer customerName: String) {
        DispatchQueue.main.sync {
            self.customerName = customerName
            toLabel.text = "to " + customerName
        }
        messages.append("connected to " + customerName)
        DispatchQueue.main.sync {
            checkoutButton.isEnabled = true
        }
    }
    
    func ayayContract(_ contract: AyAyContract, received payment: String) {
        DispatchQueue.main.sync {
            executeScript("sendOp(\"\(payment)\", \(currentOpId!))")
            textField.text = ""
            toLabel.text = ""
            currentOpId = nil
        }
        messages.append("payments received")
        DispatchQueue.main.sync {
            tableView.reloadData()
        }
    }
    
    func ayayContract(_ contract: AyAyContract, didChange state: AyAyContractClientProgress) {
        if state == .cancelled {
            DispatchQueue.main.sync {
                toLabel.text = ""
                textField.text = ""
            }
            contract.restart()
        }
        if state == .finished {
            contract.restart()
        }
    }
    
    func ayayContract(_ contract: AyAyContract, payDistance distance: Float) {
        
    }
    
    

    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var toLabel: UILabel!
    var contract: AyAyContract?
    var customerName = String()
    var messages: [String] = []
    var engine: WKWebView?
    var currentHash: String?
    var currentOpId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        checkoutButton.isEnabled = false
        
        let monitor = NWPathMonitor()
        if monitor.currentPath.status == .unsatisfied {
            let alert = UIAlertController(title: "Internet Connection Error", message: "make sure to be connected to the Internet.", preferredStyle: .alert)
            alert.addAction(.init(title: "Quit this App", style: .default, handler: {(action) in
                exit(9)
            }))
            present(alert, animated: true)
        }
        
        let userContentController: WKUserContentController = WKUserContentController()
        userContentController.add(self, name: "ayayHashReceiver")
        userContentController.add(self, name: "ayayIdReceiver")
        userContentController.add(self, name: "ayayReceive")
        userContentController.add(self, name: "txHashReceiver")
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        let webPagePreference = WKWebpagePreferences()
        webPagePreference.allowsContentJavaScript = true
        config.defaultWebpagePreferences = webPagePreference
        engine = WKWebView(frame: .zero, configuration: config)
        view.addSubview(engine!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        contract = .init(deviceName: "AyAyShop")
        contract?.delegate = self
    }
    
    
    @IBAction func sendPayments(_ sender: Any) {
        textField.endEditing(true)
        executeScript("createOp(\"\(contract!.customerMasterAddress!)\", \(textField.text!))")
        checkoutButton.isEnabled = false
    }
    
    func executeScript(_ script: String, shouldLoad: Bool = false, isRetry: Bool = false)
    {
        var command = ""
        if shouldLoad {
//            guard let path: String = Bundle.main.path(forResource: "ethers-5.2.umd.min", ofType: "js") else { return }
//            let url = URL(fileURLWithPath: path)
            guard let path2: String = Bundle.main.path(forResource: "index", ofType: "js") else { return }
            let url2 = URL(fileURLWithPath: path2)
            //let val = try! String(contentsOf: url)
            let val2 = try! String(contentsOf: url2)
            command = val2 + "; " + script
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
}

