//
//  PlaceholderActivity.swift
//  TNews
//
//  Created by Denis Karpenko on 10.12.2017.
//  Copyright © 2017 Denis Karpenko. All rights reserved.
//

import UIKit

@IBDesignable class PlaceholderActivity: UIView {
    private var view: UIView!
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

        super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: 200.0, height: 150.0))
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        xibSetup()
    }
    
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of:self))
        let nib = UINib(nibName: "PlaceholderActivity", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

}
