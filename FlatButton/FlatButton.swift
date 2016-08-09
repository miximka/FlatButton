//
//  FlatButton.swift
//  Disk Sensei
//
//  Created by Oskar Groth on 02/08/16.
//  Copyright © 2016 Cindori. All rights reserved.
//

import Cocoa
import QuartzCore

internal extension CALayer {
    internal func animate(color: CGColor, keyPath: String, duration: Double) {
        if value(forKey: keyPath) as! CGColor? != color {
            let animation = CABasicAnimation(keyPath: keyPath)
            animation.toValue = color
            animation.fromValue = value(forKey: keyPath)
            animation.duration = duration
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeForwards
            add(animation, forKey: "ColorAnimation")
            setValue(color, forKey: keyPath)
        }
    }
}

public class FlatButton: NSButton, CALayerDelegate {
    
    internal var iconLayer = CAShapeLayer()
    internal var titleLayer = CATextLayer()
    internal var mouseDown = Bool()
    public var alternateColor = NSColor()
    @IBInspectable public var fill: Bool = false {
        didSet {
            animateColor(state == NSOnState)
        }
    }
    @IBInspectable public var momentary: Bool = true {
        didSet {
            animateColor(state == NSOnState)
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 4 {
        didSet {
            layer?.cornerRadius = cornerRadius
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 1 {
        didSet {
            layer?.borderWidth = borderWidth
        }
    }
    @IBInspectable public var color: NSColor = NSColor.blue {
        didSet {
            alternateColor = tintColor(color)
            animateColor(state == NSOnState)
        }
    }
    override public var title: String {
        didSet {
            setupTitle()
        }
    }
    override public var font: NSFont? {
        didSet {
            setupTitle()
        }
    }
    override public var frame: NSRect {
        didSet {
            setupTitle()
        }
    }
    override public var image: NSImage? {
        didSet {
            setupImage()
        }
    }
    
    internal func setupTitle() {
        let attributes = [NSFontAttributeName: font!]
        let size = (title as NSString).size(withAttributes: attributes)
        titleLayer.frame = NSMakeRect(round((layer!.frame.width-size.width)/2), round((layer!.frame.height-size.height)/2), size.width, size.height)
        titleLayer.string = title
        titleLayer.font = font
        titleLayer.fontSize = font!.pointSize
    }
    
    internal func setupImage() {
        if image != nil {
            let maskLayer = CALayer()
            let imageSize = image!.size
            maskLayer.frame = NSMakeRect(round((bounds.width-imageSize.width)/2), round((bounds.height-imageSize.height)/2), imageSize.width, imageSize.height)
            var imageRect:CGRect = NSMakeRect(0, 0, imageSize.width, imageSize.height)
            let imageRef = image!.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
            maskLayer.contents = imageRef
            iconLayer.frame = bounds
            iconLayer.mask = maskLayer
        }
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    
    internal func setup() {
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = 4
        layer?.borderWidth = 1
        layer?.delegate = self
        titleLayer.delegate = self
        iconLayer.delegate = self
        layer?.addSublayer(titleLayer)
        layer?.addSublayer(iconLayer)
        setupTitle()
        setupImage()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        let trackingArea = NSTrackingArea(rect: bounds, options: [.activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    internal func removeAnimations() {
        layer?.removeAllAnimations()
        for subLayer in (layer?.sublayers)! {
            subLayer.removeAllAnimations()
        }
    }
    
    public func animateColor(_ isOn: Bool) {
        removeAnimations()
        let duration = isOn ? 0.01 : 0.1
        var bgColor = (fill || isOn) && borderWidth != 0 ? color : NSColor.clear
        if fill && isOn {
            bgColor = alternateColor
        }
        let titleColor = fill || isOn ? NSColor.white : color
        let borderColor = fill || isOn ? bgColor : color
        layer?.animate(color: bgColor.cgColor, keyPath: "backgroundColor", duration: duration)
        layer?.animate(color: borderColor.cgColor, keyPath: "borderColor", duration: duration)
        titleLayer.animate(color: titleColor.cgColor, keyPath: "foregroundColor", duration: duration)
        iconLayer.animate(color: titleColor.cgColor, keyPath: "backgroundColor", duration: duration)
    }
    
    public func setOn(_ isOn: Bool) {
        let nextState = isOn ? NSOnState : NSOffState
        if nextState != state {
            state = nextState
            animateColor(state == NSOnState)
        }
    }
    
    override public func mouseDown(with event: NSEvent) {
        if !isEnabled {
            return
        }
        mouseDown = true
        setOn(state == NSOnState ? false : true)
    }
    
    override public func mouseEntered(with event: NSEvent) {
        if mouseDown {
            setOn(state == NSOnState ? false : true)
        }
    }
    
    override public func mouseExited(with event: NSEvent) {
        if mouseDown {
            setOn(state == NSOnState ? false : true)
            mouseDown = false
        }
    }
    
    override public func mouseUp(with event: NSEvent) {
        if mouseDown {
            mouseDown = false
            if momentary {
                setOn(state == NSOnState ? false : true)
            }
            _ = target?.perform(action, with: self)
        }
    }
    
    internal func tintColor(_ color: NSColor) -> NSColor {
        var h = CGFloat(), s = CGFloat(), b = CGFloat(), a = CGFloat()
        let rgbColor = color.usingColorSpaceName(NSCalibratedRGBColorSpace)
        rgbColor?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return NSColor(hue: h, saturation: s, brightness: b == 0 ? 0.2 : b * 0.8, alpha: a)
    }
    
    override public func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
        return true
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        
    }
    
}
