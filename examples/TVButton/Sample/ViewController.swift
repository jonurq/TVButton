//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 08/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import UIKit
import Foundation
import TVButton

class ViewController: UIViewController {

    @IBOutlet weak var tvButton: TVButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let background = TVButtonLayer(view: viewFromImage(image: UIImage(named: "TVButtonBackground.png")!))
        let pattern = TVButtonLayer(view: viewFromImage(image: UIImage(named: "TVButtonPattern.png")!))
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SAPE"
        label.font = UIFont.systemFont(ofSize: 40)
        let containerLabelView = UIView()
        containerLabelView.translatesAutoresizingMaskIntoConstraints = false
        containerLabelView.addSubview(label)
        label.centerYAnchor.constraint(equalTo: containerLabelView.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: containerLabelView.centerXAnchor).isActive = true
        let top = TVButtonLayer(view: containerLabelView)
            
            //TVButtonLayer(view: viewFromImage(image: UIImage(named: "TVButtonTop.png")!))
        
        tvButton.layers = [background, pattern, top]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewFromImage(image: UIImage) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        return view
    }

}

