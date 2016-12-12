//
//  RulesViewController.swift
//  DroneFlight
//
//  Created by Benjamin Durao on 10/10/16.
//  Copyright © 2016 CCSU. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {
    // MARK: Properties
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Methods
    
    // MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL (string: "https://www.faa.gov/uas/getting_started/");
        let requestObj = NSURLRequest(url: url! as URL);
        webView.loadRequest(requestObj as URLRequest);
        webView.scalesPageToFit = true
    }
}
