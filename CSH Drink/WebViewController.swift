//
//  WebViewController.swift
//  CSH Drink
//
//  Created by Stuart Olivera on 4/26/17.
//  Copyright © 2017 Stuart Olivera. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import DeepLinkKit
import Mixpanel

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var navbar: UINavigationItem!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var spinner: UIActivityIndicatorView!

    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Mixpanel.sharedInstance().track("Opened WebDrink")
        
        self.navbar.rightBarButtonItem = UIBarButtonItem.init(customView: spinner)
        
        let url = URL(string: "https://webdrink.csh.rit.edu/mobileapp/index.php")
        self.webView.delegate = self
        self.webView.loadRequest(URLRequest(url: url!))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(WebViewController.updateApiKey), name: deepLinkUpdateKey, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func updateApiKey() {
        self.dismiss(animated: true)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.spinner.startAnimating()
    }
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.spinner.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.spinner.stopAnimating()
    }

}
