//
//  UIActivityIndicatorView+QuickStart.swift
//  QuickStart
//
//  Created by Damon Park on 2020/03/26.
//  Copyright © 2020 SendBird Inc. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    func startLoading(on view: UIView?) {
        guard self.isAnimating == false else { return }
        guard let view = view else { return }
        
        self.center = view.center
        self.hidesWhenStopped = true
        self.style = .gray
        
        if view != self.superview {
            self.superview?.removeFromSuperview()
            view.addSubview(self)
        }
        
        self.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopLoading() {
        guard self.isAnimating == true else { return }
        
        self.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}


struct ActivityIndicator {
    
    let viewForActivityIndicator = UIView()
    let backgroundView = UIView()
    let view: UIView
    let darkView: UIView
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    
    func startLoading() {
        darkView.isHidden = false
        
        viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        viewForActivityIndicator.center = CGPoint(x: self.view.frame.size.width / 2.0, y: self.view.frame.size.height / 2)
        viewForActivityIndicator.layer.cornerRadius = 12
        viewForActivityIndicator.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        backgroundView.addSubview(viewForActivityIndicator)
        
        activityIndicatorView.center = CGPoint(x: viewForActivityIndicator.frame.size.width / 2.0, y: viewForActivityIndicator.frame.size.height / 2 - 14)
        
        loadingTextLabel.textColor = UIColor.white
        loadingTextLabel.text = "Loading..."
        loadingTextLabel.font = .systemFont(ofSize: 16, weight: .regular)
        loadingTextLabel.sizeToFit()
        loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 40)
        viewForActivityIndicator.addSubview(loadingTextLabel)
        
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        viewForActivityIndicator.addSubview(activityIndicatorView)
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        view.addSubview(backgroundView)
        
        
        
        activityIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        backgroundView.removeFromSuperview()
        
        darkView.isHidden = true
    }
}

