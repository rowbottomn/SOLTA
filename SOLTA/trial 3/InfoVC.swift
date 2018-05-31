//
//  InfoVC.swift
//  trial 3
//
//  Created by Nathan Rowbottom on 2018-05-30.
//  Copyright © 2018 Guest User. All rights reserved.
//

import UIKit
import Foundation
import WebKit

class InfoVC: UIViewController, WKUIDelegate {

    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {

        super.viewDidLoad()
        let myURL = URL(string:"http://solta.atspace.cc")
        let myRequest = URLRequest(url: myURL!)
        webView.uiDelegate = self
        webView.load(myRequest)
        print("---------------_++++++++++++++++++++______________________\(webView.isLoading)")
        // Do any additional setup after loading the view.
    }


    
    func webViewDidClose(_ webView: WKWebView) {
    }

}

extension UIWebView {
    
    func updateLayoutForContent() {
        let javascript = "document.querySelector('meta[name=viewport]').setAttribute('content', 'width=\(self.bounds.size.width);', false); "
        self.stringByEvaluatingJavaScript(from: javascript)
    }
  
}
