//
//  ContentViewController.swift
//  TNews
//
//  Created by Denis Karpenko on 06.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

protocol ContentViewDelegate: class {
    func updateContent(text: String?)
}

class ContentViewController: UIViewController, ContentViewDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var myActivityIndicator: PlaceholderActivity!
    
    var news: News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let txt = news?.content {
            textView.text = txt
            self.myActivityIndicator.isHidden = true
        }
        else {
            self.myActivityIndicator.isHidden = false
        }

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) { // fix of the strange behavior of textView with scrolling text down
        textView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.isScrollEnabled = true
    }

    
    func updateContent(text: String?){
        DispatchQueue.main.async {
            if let txt = text {
                self.textView.text = txt
                self.myActivityIndicator.isHidden = true
            }
            else {
                self.myActivityIndicator.isDownloading = false
            }
        }
    }
}
