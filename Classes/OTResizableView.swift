//
//  OTResizableView.swift
//  OTResizableView
//
//  Created by Tomosuke Okada on 2017/08/27.
//  Copyright © 2017年 TomosukeOkada. All rights reserved.
//
//  https://github.com/PKPK-Carnage/OTResizableView

/**
 [OTResizableView]
 
 Copyright (c) [2017] [Tomosuke Okada]
 
 This software is released under the MIT License.
 http://opensource.org/licenses/mit-license.ph
 
 */

import UIKit

public enum TappedPosition {
    case UpperLeft
    case UpperRight
    case LowerLeft
    case LowerRight
    case Center
    case None
}


public protocol OTResizableViewDelegate:class {
    
    func tapBegin(_ resizableView:OTResizableView)
    
    func tapChanged(_ resizableView:OTResizableView)
    
    func tapMoved(_ resizableView:OTResizableView)
    
    func tapEnd(_ resizableView:OTResizableView)
    
}


extension OTResizableViewDelegate {
    
    func tapBegin(_ resizableView:OTResizableView){}
    
    func tapChanged(_ resizableView:OTResizableView){}
    
    func tapMoved(_ resizableView:OTResizableView){}
    
    func tapEnd(_ resizableView:OTResizableView){}
    
}


open class OTResizableView: UIView, UIGestureRecognizerDelegate {
    
    public weak var delegate: OTResizableViewDelegate?
    
    public var minimumWidth: CGFloat = 100 {
        didSet {
            if keepAspectEnabled {
                minimumWidth = oldValue
            }
        }
    }
    
    public var minimumHeight: CGFloat = 100 {
        didSet {
            if keepAspectEnabled {
                minimumHeight = oldValue
            }
        }
    }
    
    public var keepAspectEnabled = false {
        willSet {
            if newValue {
                minimumWidth = frame.width
                minimumHeight = frame.height
            }
        }
    }
    
    open var resizeEnabled = false {
        didSet {
            gripPointView.isHidden = resizeEnabled ? false:true
        }
    }
    
    open var viewStrokeColor = UIColor.red {
        didSet {
            gripPointView.viewStrokeColor = viewStrokeColor
        }
    }
    
    open var gripPointStrokeColor = UIColor.white {
        didSet{
            gripPointView.gripPointStrokeColor = gripPointStrokeColor
        }
    }
    
    open var gripPointFillColor = UIColor.blue {
        didSet {
            gripPointView.gripPointFillColor = gripPointFillColor
        }
    }
    
    open var gripTappableSize: CGFloat = 40
    
    public let gripPointDiameter: CGFloat = 10
    
    private(set) var contentView = UIView()
    
    private(set) var currentTappedPostion:TappedPosition = .None
    
    private var startFrame = CGRect.zero
    private var minimumPoint = CGPoint.zero
    
    private var touchStartPointInSuperview = CGPoint.zero
    private var touchStartPointInSelf = CGPoint.zero
    
    private var keepAspectFrame: CGRect?
    
    private var gripPointView = OTGripPointView()
    
    //MARK: - Initialize
    public init(contentView: UIView) {
        super.init(frame: contentView.frame.insetBy(dx: -gripPointDiameter, dy: -gripPointDiameter))
        
        initialize()
        
        setContentView(newContentView: contentView)
    }
    
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initialize() {
        backgroundColor = UIColor.clear
        prepareGesture()
    }
    
    
    //MARK: - LifeCycle
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        prepareGripPointView()
    }
    
    
    //MARK: - Prepare
    private func prepareGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        
        let panGesutureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGesutureRecognizer)
    }
    
    
    private func prepareGripPointView() {
        gripPointView = OTGripPointView.init(frame: bounds)
        gripPointView.isHidden = true
        
        gripPointView.viewStrokeColor = viewStrokeColor
        gripPointView.gripPointStrokeColor = gripPointStrokeColor
        gripPointView.gripPointFillColor = gripPointFillColor
        
        addSubview(gripPointView)
    }
    
    
    //MARK: - Set
    private func setContentView(newContentView: UIView) {
        contentView.removeFromSuperview()
        contentView = newContentView;
        contentView.frame.origin = CGPoint(x: gripPointDiameter, y: gripPointDiameter)
        addSubview(contentView)
        
        gripPointView.removeFromSuperview()
        addSubview(gripPointView)
    }
    
    
    private func setFrame(newFrame: CGRect) {
        super.frame = newFrame
        contentView.frame = bounds.insetBy(dx: gripPointDiameter, dy: gripPointDiameter)
        gripPointView.frame = bounds
        gripPointView.setNeedsDisplay()
    }
    
    
    //MARK: - Gesture
    @objc open func handleTap(gesture: UITapGestureRecognizer) {
        delegate?.tapBegin(self)
    }
    
    
    @objc open func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            if resizeEnabled {
                
                startFrame = frame;
                
                touchStartPointInSuperview = gesture.location(in: superview)
                touchStartPointInSelf = gesture.location(in: self)
                
                currentTappedPostion = detectCurrentTappedPosition()
                
                if currentTappedPostion != .None && currentTappedPostion != .Center {
                    minimumPoint = measureMinimumPoint()
                }
            }
            
        case .changed:
            
            if resizeEnabled {
                switch currentTappedPostion {
                case .UpperLeft, .UpperRight, .LowerLeft, .LowerRight:
                    
                    let currentTouchPointInSuperview = gesture.location(in: superview)
                    
                    var resizedRect = CGRect.zero
                    
                    if keepAspectEnabled {
                        resizedRect = generateKeepAspectFrame(position: currentTappedPostion, currentTouchPoint: currentTouchPointInSuperview)
                        resizedRect = adjustKeepAspect(rect: resizedRect)
                        setFrame(newFrame: resizedRect)
                    } else {
                        let differenceX = currentTouchPointInSuperview.x - touchStartPointInSuperview.x
                        let differenceY = currentTouchPointInSuperview.y - touchStartPointInSuperview.y
                        
                        resizedRect = generateNormalFrame(position: currentTappedPostion, differenceX: differenceX, differenceY: differenceY)
                        resizedRect = adjustNormal(rect: resizedRect)
                        setFrame(newFrame: resizedRect)
                    }
                    
                    delegate?.tapChanged(self)
                    
                case .Center:
                    
                    let currentTouchPointInSelf = gesture.location(in: self)
                    
                    moveView(touchPoint: currentTouchPointInSelf, startPoint: touchStartPointInSelf)
                    
                    delegate?.tapMoved(self)
                    
                case .None:
                    return
                }
            }
            
        case .ended:
            
            currentTappedPostion = .None
            
            keepAspectFrame = nil
            
            delegate?.tapEnd(self)
            
        case .cancelled:
            
            currentTappedPostion = .None
            
            keepAspectFrame = nil
            
            delegate?.tapEnd(self)
            
        default:
            
            currentTappedPostion = .None
            
            keepAspectFrame = nil
            
            return
        }
    }
    
    
    //MARK: - Normal resize
    private func generateNormalFrame(position:TappedPosition, differenceX: CGFloat, differenceY: CGFloat) -> CGRect {
        
        let startX = startFrame.origin.x
        let startY = startFrame.origin.y
        let startWidth = startFrame.width
        let startHeight = startFrame.height
        
        switch position {
        case .UpperLeft:
            return CGRect(x: startX + differenceX, y: startY + differenceY, width: startWidth - differenceX, height: startHeight - differenceY)
        case .UpperRight:
            return CGRect(x: startX, y: startY + differenceY, width: startWidth + differenceX, height: startHeight - differenceY)
        case .LowerLeft:
            return CGRect(x: startX + differenceX, y: startY, width: startWidth - differenceX, height: startHeight + differenceY)
        case .LowerRight:
            return CGRect(x: startX, y: startY, width: startWidth + differenceX, height: startHeight + differenceY)
        default:
            return CGRect.zero
        }
    }
    
    private func adjustNormal(rect: CGRect) -> CGRect {
        var x = rect.origin.x
        var y = rect.origin.y
        var width = rect.size.width
        var height = rect.size.height
        
        if x < superview!.bounds.origin.x {
            let deltaW = frame.origin.x - superview!.bounds.origin.x
            width = frame.size.width + deltaW
            x = superview!.bounds.origin.x
        }
        
        if rect.origin.x + width > superview!.bounds.origin.x + superview!.bounds.size.width {
            width = superview!.bounds.size.width - x
        }
        
        if y < superview!.bounds.origin.y {
            let deltaH = frame.origin.y - superview!.bounds.origin.y
            height = frame.size.height + deltaH
            y = superview!.bounds.origin.y
        }
        
        if y + height > superview!.bounds.origin.y + superview!.bounds.size.height {
            height = superview!.bounds.size.height - y
        }
        
        if width <= minimumWidth {
            width = minimumWidth
            x = minimumPoint.x
        }
        
        if height <= minimumHeight {
            height = minimumHeight
            y = minimumPoint.y
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    //MARK: - Keep Aspect resize
    private func generateKeepAspectFrame(position:TappedPosition, currentTouchPoint: CGPoint) -> CGRect {
        
        let scaleTuple = generateScale(position: position, currentTouchPoint: currentTouchPoint)
        let widthScale = scaleTuple.widthScale
        let heightScale = scaleTuple.heightScale
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        if widthScale > heightScale {
            width = startFrame.width * widthScale
            height = startFrame.height * widthScale
        } else {
            width = startFrame.width * heightScale
            height = startFrame.height * heightScale
        }
        
        let differenceX = startFrame.width - width
        let differenceY = startFrame.height - height
        
        switch position {
        case .UpperLeft:
            return CGRect(x: startFrame.origin.x + differenceX, y: startFrame.origin.y + differenceY, width: width, height: height)
        case .UpperRight:
            return CGRect(x: startFrame.origin.x, y: startFrame.origin.y + differenceY , width: width, height: height)
        case .LowerLeft:
            return CGRect(x: startFrame.origin.x + differenceX, y: startFrame.origin.y, width: width, height: height)
        case .LowerRight:
            return CGRect(x: startFrame.origin.x, y: startFrame.origin.y, width: width, height: height)
        default:
            return CGRect.zero
        }
        
    }
    
    
    private func generateScale(position:TappedPosition, currentTouchPoint: CGPoint) -> (widthScale: CGFloat, heightScale: CGFloat) {
        switch position {
        case .UpperLeft:
            return (widthScale: (startFrame.origin.x - currentTouchPoint.x + startFrame.width) / startFrame.width,
                    heightScale: (startFrame.origin.y - currentTouchPoint.y + startFrame.height) / startFrame.height)
        case .UpperRight:
            return (widthScale: (currentTouchPoint.x - startFrame.origin.x) / startFrame.width,
                    heightScale: (startFrame.origin.y - currentTouchPoint.y + startFrame.height) / startFrame.height)
        case .LowerLeft:
            return (widthScale: (startFrame.origin.x - currentTouchPoint.x + startFrame.width) / startFrame.width,
                    heightScale: (currentTouchPoint.y - startFrame.origin.y) / startFrame.height)
        case .LowerRight:
            return (widthScale: (currentTouchPoint.x - startFrame.origin.x) / startFrame.width,
                    heightScale: (currentTouchPoint.y - startFrame.origin.y) / startFrame.width)
        default:
            return (widthScale: 0, heightScale: 0)
        }
    }
    
    
    private func adjustKeepAspect(rect: CGRect) -> CGRect{
        
        var x = rect.origin.x
        var y = rect.origin.y
        var width = rect.size.width
        var height = rect.size.height
        
        if x < superview!.bounds.origin.x {
            let deltaW = frame.origin.x - superview!.bounds.origin.x
            width = frame.size.width + deltaW
            x = superview!.bounds.origin.x
            
            if let keepAspectFrame = keepAspectFrame {
                y = keepAspectFrame.origin.y
                height = keepAspectFrame.height
            } else {
                keepAspectFrame = CGRect(x: x, y: y, width: width, height: height)
            }
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
        if rect.origin.x + width > superview!.bounds.origin.x + superview!.bounds.size.width {
            width = superview!.bounds.size.width - x
            
            if let keepAspectFrame = keepAspectFrame {
                y = keepAspectFrame.origin.y
                height = keepAspectFrame.height
            } else {
                keepAspectFrame = CGRect(x: x, y: y, width: width, height: height)
            }
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
        if y < superview!.bounds.origin.y {
            let deltaH = frame.origin.y - superview!.bounds.origin.y
            height = frame.size.height + deltaH
            y = superview!.bounds.origin.y
            
            if let keepAspectFrame = keepAspectFrame {
                x = keepAspectFrame.origin.x
                width = keepAspectFrame.width
            } else {
                keepAspectFrame = CGRect(x: x, y: y, width: width, height: height)
            }
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
        if y + height > superview!.bounds.origin.y + superview!.bounds.size.height {
            height = superview!.bounds.size.height - y
            
            if let keepAspectFrame = keepAspectFrame {
                x = keepAspectFrame.origin.x
                width = keepAspectFrame.width
            } else {
                keepAspectFrame = CGRect(x: x, y: y, width: width, height: height)
            }
            
            return CGRect(x: x, y: y, width: width, height: height)
        }
        
        if width <= minimumWidth {
            width = minimumWidth
            x = minimumPoint.x
        }
        
        if height <= minimumHeight {
            height = minimumHeight
            y = minimumPoint.y
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    
    //MARK: - Prepare TapChanged
    private func detectCurrentTappedPosition() -> TappedPosition {
        if touchStartPointInSelf.x < gripTappableSize && touchStartPointInSelf.y < gripTappableSize {
            
            return .UpperLeft
            
        } else if bounds.size.width - touchStartPointInSelf.x < gripTappableSize && touchStartPointInSelf.y < gripTappableSize {
            
            return .UpperRight
            
        } else if touchStartPointInSelf.x < gripTappableSize && bounds.size.height - touchStartPointInSelf.y < gripTappableSize {
            
            return .LowerLeft
            
        } else if bounds.size.width - touchStartPointInSelf.x < gripTappableSize && bounds.size.height - touchStartPointInSelf.y < gripTappableSize {
            
            return .LowerRight
            
        } else {
            
            return .Center
            
        }
    }
    
    
    private func measureMinimumPoint() -> CGPoint {
        let originX = startFrame.origin.x
        let originY = startFrame.origin.y
        
        let upperRightX = originX + startFrame.size.width
        let lowerLeftY = originY + startFrame.size.height
        
        switch currentTappedPostion {
            
        case .UpperLeft:
            
            return CGPoint(x: upperRightX - minimumWidth, y: lowerLeftY - minimumHeight)
            
        case .UpperRight:
            
            return CGPoint(x: originX, y: lowerLeftY - minimumHeight)
            
        case .LowerLeft:
            
            return CGPoint(x: upperRightX - minimumWidth, y: originY)
            
        case .LowerRight:
            
            return CGPoint(x: originX, y: originY)
            
        default:
            
            return CGPoint.zero
        }
    }
    
    
    private func moveView(touchPoint: CGPoint, startPoint: CGPoint)
    {
        var newCenter = CGPoint(x: center.x + touchPoint.x - startPoint.x, y: center.y + touchPoint.y - startPoint.y)
        
        let midPointX = bounds.midX
        
        if newCenter.x > superview!.bounds.size.width - midPointX {
            newCenter.x = superview!.bounds.size.width - midPointX;
        }
        
        if newCenter.x < midPointX {
            newCenter.x = midPointX;
        }
        
        let midPointY = bounds.midY
        
        if newCenter.y > superview!.bounds.size.height - midPointY {
            newCenter.y = superview!.bounds.size.height - midPointY;
        }
        
        if newCenter.y < midPointY {
            newCenter.y = midPointY;
        }
        
        center = newCenter;
    }
}

