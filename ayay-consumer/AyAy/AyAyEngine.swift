import Foundation
import WebKit


class AyAyEngine : WKWebView, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration){
        super.init(frame: .zero, configuration: configuration)
        let userContentController: WKUserContentController = WKUserContentController()
        
        userContentController.add(self, name: "ayayReceive")

        configuration.userContentController = userContentController
        let pref = WKWebpagePreferences()
        pref.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pref
    }
    
    func loadScripts()
    {
        guard let path: String = Bundle.main.path(forResource: "index", ofType: "html") else { return }
        let localsource = URL(fileURLWithPath: path, isDirectory: false)
        let extpath: String = Bundle.main.bundlePath
        let localext = URL(fileURLWithPath: extpath, isDirectory: true)
        loadFileURL(localsource, allowingReadAccessTo: localext)
        evaluateJavaScript(try! String(contentsOf: localsource))
    }
    
    func testJS()
    {
        
        guard let path: String = Bundle.main.path(forResource: "ethers-5.2.umd.min", ofType: "js") else { return }
        let url = URL(fileURLWithPath: path)
        guard let path2: String = Bundle.main.path(forResource: "sample", ofType: "js") else { return }
        let url2 = URL(fileURLWithPath: path2)
        let val = try! String(contentsOf: url)
        let val2 = try! String(contentsOf: url2)
        evaluateJavaScript(val+val2 + "createMasterKey();", completionHandler: { (object, error) in
            if let object = object {
                print(object)
            }
            if let error = error {
                print(error)
            }
        })
    }
    
    func evalJavaScript(){
        testJS()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
