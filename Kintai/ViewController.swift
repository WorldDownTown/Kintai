//
//  ViewController.swift
//  Kintai
//
//  Created by shoji on 2015/11/29.
//
//

import UIKit
import SafariServices

class ViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        let urlString = ""
        let encodedUrlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        if let encodedUrlString = encodedUrlString, url = NSURL(string: encodedUrlString) {
            let safariVC = SFSafariViewController(URL: url)
            presentViewController(safariVC, animated: false, completion: nil)
        }
    }
}
