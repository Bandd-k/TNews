//
//  ContentViewController.swift
//  TNews
//
//  Created by Denis Karpenko on 06.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

protocol ContentViewDelegate: class {
    func updateContent(text: String)
}

class ContentViewController: UIViewController,ContentViewDelegate {
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var placeHolder: UIImageView!
    
    @IBOutlet weak var placeHolderText: UILabel!
    var news: News?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let txt = news?.content {
            textView.text = txt
            self.placeHolder.isHidden = true
            self.placeHolderText.isHidden = true
        }
        else {
            self.placeHolder.isHidden = false
            self.placeHolderText.isHidden = false
        }

        // Do any additional setup after loading the view.
    }
    
    func updateContent(text: String){
        DispatchQueue.main.async {
            self.textView.text = text // CHECK CAPUTRING
            self.placeHolder.isHidden = true
            self.placeHolderText.isHidden = true
        }
    }
}
