//
//  TVButton.swift
//  TVButton
//
//  Created by Roy Marmelstein on 08/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parallax Layer Object
*/
public struct TVButtonLayer {
    /// UIImage to display. It is essential that all images have the same dimensions.
    var internalView: UIView?
}

public extension TVButtonLayer {
    /**
     Initialise the TVButton layer by passing a UIImage
     - Parameter image: UIImage to display. It is essential that all images have the same dimensions.
     */
    public init(view: UIView) {
        self.init(internalView: view)
    }
}

/**
 TVButton Object
 */
open class TVButton: UIButton, UIGestureRecognizerDelegate {
    
    // MARK: Internal variables
    internal var containerView = UIView()
    internal var specularView = UIImageView()
    internal var tvButtonAnimation: TVButtonAnimation?
    
    internal var longPressGestureRecognizer: UILongPressGestureRecognizer?
    internal var panGestureRecognizer: UIPanGestureRecognizer?
    
    // MARK: Public variables
    
    /// Stack of TVButtonLayers inside the button
    open var layers: [TVButtonLayer]? {
        didSet {
            // Remove existing parallax layer views
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            // Instantiate an imageview with corners for every layer
            for layer in layers! {
                if let view = layer.internalView {
                    view.layer.cornerRadius = cornerRadius
                    view.clipsToBounds = true
                    view.layer.needsDisplayOnBoundsChange = true
                    containerView.addSubview(view)
                    pinToSuperviewEdges(view: view, parentView: containerView)
                }
            }
            containerView.translatesAutoresizingMaskIntoConstraints = false
            // Add specular shine effect
            let frameworkBundle = Bundle(for: TVButton.self)
            let specularViewPath = frameworkBundle.path(forResource: "Specular", ofType: "png")
            specularView.image = UIImage(contentsOfFile:specularViewPath!)
            self.containerView.addSubview(specularView)
        }
    }

    /// Determines the intensity of the parallax depth effect. Default is 1.0.
    open var parallaxIntensity: CGFloat = defaultParallaxIntensity

    /// Shadow color for the TVButton. Default is black.
    open var shadowColor: UIColor = UIColor.black {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    // MARK: Lifecycle
    
    /**
    Default init for TVObject with coder.
    */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /**
     Default init for TVObject with frame.
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /**
     Lays out subviews.
     */
    override open func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
        self.layer.masksToBounds = false;
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0)
        self.layer.shadowPath = shadowPath.cgPath

        // Stop here if animation is on
        if let animation = tvButtonAnimation {
            if animation.highlightMode == true {
                return
            }
        }
        
        specularView.frame = CGRect(origin: specularView.frame.origin, size: CGSize(width: specularScale * containerView.frame.size.width, height: specularScale * containerView.frame.size.height))
    }
    
    /**
     Button setup. Conducted on init.
    */
    func setup() {
        containerView.isUserInteractionEnabled = false
        self.addSubview(containerView)
        self.translatesAutoresizingMaskIntoConstraints = false
        pinToSuperviewEdges(view: containerView, parentView: self)
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        specularView.alpha = 0.0
        specularView.contentMode = .scaleAspectFill
        self.layer.shadowRadius = self.bounds.size.height/(2*shadowFactor)
        self.layer.shadowOffset = CGSize(width: 0.0, height: shadowFactor/3)
        self.layer.shadowOpacity = 0.5;
        tvButtonAnimation = TVButtonAnimation(button: self)
        tvButtonAnimation?.startGyro()
        //self.addGestureRecognizers()
    }
    
    func pinToSuperviewEdges(view: UIView, parentView: UIView) {
        view.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
    }
    
    
    // MARK: UIGestureRecognizer actions and delegate
    
    /**
    Adds the gesture recognizers to the button.
    */
    func addGestureRecognizers(){
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer?.delegate = self
        self.addGestureRecognizer(panGestureRecognizer!)
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer?.delegate = self
        self.addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    /**
     Pan gesture recognizer handler.
     - Parameter gestureRecognizer: TVButton's UIPanGestureRecognizer.
     */
    @objc func handlePan(_ gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizerDidUpdate(gestureRecognizer)
    }
    
    /**
     Long press gesture recognizer handler.
     - Parameter gestureRecognizer: TVButton's UILongPressGestureRecognizer.
     */
    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizerDidUpdate(gestureRecognizer)
    }
    
    
    /**
     Determines button's reaction to gesturerecognizer.
     - Parameter gestureRecognizer: either UITapGestureRecognizer or UILongPressGestureRecognizer.
     */
    func gestureRecognizerDidUpdate(_ gestureRecognizer: UIGestureRecognizer){
        guard let layers = layers,
              layers.count > 0,
              let animation = tvButtonAnimation else {
            return
        }
        
        let point = gestureRecognizer.location(in: self)
        
//        switch gestureRecognizer.state {
//        case .began:
//            animation.enterMovement()
//            animation.processMovement(point)
//        case .changed:
//            animation.processMovement(point)
//        default:
//            animation.exitMovement()
//        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    /**
    UIGestureRecognizerDelegate function to allow two UIGestureRecognizers to be recognized simultaneously.
    - Parameter gestureRecognizer: First gestureRecognizer.
    - Parameter otherGestureRecognizer: Second gestureRecognizer.
    */
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
