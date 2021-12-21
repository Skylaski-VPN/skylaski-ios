//
//  LoginViewController.swift
//  skylaski
//
//  Created by Anilkumar on 11/05/21.
//

import UIKit
import WebKit
import SafariServices

class LoginViewController: UIViewController  {
    @IBOutlet weak var webView : WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeCaches()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToPricing), name: .notificationReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToHome), name: .movetohome, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeCaches()
    }
    
    
    func removeCaches() {
        URLCache.shared.removeAllCachedResponses()
        
        let dataTypes: Set<String> = [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date.init(timeIntervalSince1970: 0
        )) {
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webView.navigationDelegate = self
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.scrollView.isScrollEnabled = true
        webView.allowsBackForwardNavigationGestures = true
        
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36 SkylaskiVPN0.1"
        webView.allowsLinkPreview = false
        
        let myURL = URL(string:APPURL.domain + endPoint.login)
        let request: URLRequest = URLRequest.init(url: myURL!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0)
        
        if !Connectivity().isConnection() {
            self.showAlert(title: "No Internet", message: "Please check you Internet connection!!")
            return
        }
        
        webView.load(request)
    }
    
    @objc func moveToPricing() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PricingViewController") as! PricingViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc func moveToHome() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension LoginViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, SFSafariViewControllerDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("message",message)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("error",error.localizedDescription, error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let host = navigationAction.request.url else {
            return
        }
        print("urls ",host)
        let params = host.params()
        
        
        
        if host.absoluteString.contains("google-login") {            
            let url = URL(string: APPURL.domain + endPoint.googleLogin)
            let vc = SFSafariViewController(url: url!)
            vc.delegate = self
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true, completion: nil)
            
            decisionHandler(.cancel)
        }
        else if let token = params["token"] as? String {
            print(token)
            UserDefaults.standard.setValue(token, forKey: "token")
            ApiCallController().getPlans()
            decisionHandler(.cancel)
        }
        else {
            decisionHandler(.allow)
        }
        
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // This must be valid javascript!  Critically don't forget to terminate statements with either a newline or semicolon!
        print("success")
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: { result, error in
            if let userAgent = result as? String {
                print(userAgent)
            }
        })
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("err",error)
        if let err : WKError = error as? WKError , err.errorCode == 102 {
            self.viewDidLoad()
        }
    }
    
}


extension URL {
    func params() -> [String:Any] {
        var dict = [String:Any]()
        
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if let queryItems = components.queryItems {
                for item in queryItems {
                    dict[item.name] = item.value!
                }
            }
            return dict
        } else {
            return [:]
        }
    }
}
