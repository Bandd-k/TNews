//
//  PlaceholderActivity.swift
//  TNews
//
//  Created by Denis Karpenko on 10.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

@IBDesignable class PlaceholderActivity: UIView {
    // Our custom view from the XIB file
    var view: UIView!
    @IBInspectable var isDownloading:Bool = false {
        didSet{
            if isDownloading == true {
                activityIndicator.startAnimating()
                activityIndicator.isHidden = false
                textLabel.text = "Загрузка Данных"
            }
            else {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                textLabel.text = "Данных нет"
            }
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textLabel: UILabel!
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: 200.0, height: 150.0))
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
        //        self.view = loadViewFromNib() as! CustomView
    }
    
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: "PlaceholderActivity", bundle: bundle)
        
        // Assumes UIView is top level and only object in CustomView.xib file
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
