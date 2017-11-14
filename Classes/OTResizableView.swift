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

@objc public enum TappedPosition: Int {
    case UpperLeft
    case UpperRight
    case LowerLeft
    case LowerRight
    case Center
    case None
}


@objc public protocol OTResizableViewDelegate: class {
    
    @objc optional func tapBegin(_ resizableView:OTResizableView)
    
    @objc optional func tapChanged(_ resizableView:OTResizableView)
    
    @objc optional func tapMoved(_ resizableView:OTResizableView)
    
    @objc optional func tapEnd(_ resizableView:OTResizableView)
    
}


@objc open class OTResizableView: UIView, UIGestureRecognizerDelegate {
    
    @objc public weak var delegate: OTResizableViewDelegate?
    
    @objc public var minimumWidth: CGFloat = 100 {
        didSet {
            if keepAspectEnabled {
                minimumWidth = oldValue
            }
        }
    }
    
    @objc public var minimumHeight: CGFloat = 100 {
        didSet {
            if keepAspectEnabled {
                minimumHeight = oldValue
            }
        }
    }
    
    @objc public var keepAspectEnabled = false {
        willSet {
            if newValue {
                minimumWidth = frame.width * minimumAspectScale
                minimumHeight = frame.height * minimumAspectScale
            }
        }
    }
    
    @objc open var minimumAspectScale: CGFloat = 1
    
    @objc open var resizeEnabled = false {
        didSet {
            gripPointView.isHidden = resizeEnabled ? false:true
        }
    }
    
    @objc open var viewStrokeColor = UIColor.red {
        didSet {
            gripPointView.viewStrokeColor = viewStrokeColor
        }
    }
    
    @objc open var gripPointStrokeColor = UIColor.white {
        didSet{
            gripPointView.gripPointStrokeColor = gripPointStrokeColor
        }
    }
    
    @objc open var gripPointFillColor = UIColor.blue {
        didSet {
            gripPointView.gripPointFillColor = gripPointFillColor
        }
    }
    
    @objc open var gripTappableSize: CGFloat = 40
    
    @objc public let gripPointDiameter: CGFloat = 10
    
    @objc public private(set) var contentView = UIView()
    
    @objc public private(set) var currentTappedPostion:TappedPosition = .None
    
    private var startFrame = CGRect.zero
    private var minimumPoint = CGPoint.zero
    
    private var touchStartPointInSuperview = CGPoint.zero
    private var touchStartPointInSelf = CGPoint.zero
    
    private var maxAspectFrame = CGRect.zero
    
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
        gripPointView.removeFromSuperview()
        
        gripPointView = OTGripPointView(frame: bounds)
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
    
    
    @objc public func setResizedFrame(newFrame: CGRect) {
        super.frame = newFrame
        contentView.frame = bounds.insetBy(dx: gripPointDiameter, dy: gripPointDiameter)
        contentView.setNeedsDisplay()
        gripPointView.frame = bounds
        gripPointView.setNeedsDisplay()
    }
    
    
    //MARK: - Gesture
    @objc open func handleTap(gesture: UITapGestureRecognizer) {
        delegate?.tapBegin?(self)
    }
    
    
    @objc open func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            if resizeEnabled {
                
                startFrame = frame;
                
                touchStartPointInSuperview = gesture.location(in: superview)
                touchStartPointInSelf = gesture.location(in: self)
                
                currentTappedPostion = detectCurrentTappedPosition()
                
                
                switch currentTappedPostion {
                case .UpperLeft, .UpperRight, .LowerLeft, .LowerRight:
                    minimumPoint = measureMinimumPoint()
                
                    if keepAspectEnabled {
                        maxAspectFrame = measureMaximumKeepAspectFrame()
                    }
                    
                case .Center:
                    break
                    
                case .None:
                    break
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
                    } else {
                        let differenceX = currentTouchPointInSuperview.x - touchStartPointInSuperview.x
                        let differenceY = currentTouchPointInSuperview.y - touchStartPointInSuperview.y
                        
                        resizedRect = generateNormalFrame(position: currentTappedPostion, differenceX: differenceX, differenceY: differenceY)
                        resizedRect = adjustNormal(rect: resizedRect)
                    }
                    
                    setResizedFrame(newFrame: resizedRect)
                    
                    delegate?.tapChanged?(self)
                    
                case .Center:
                    
                    let currentTouchPointInSelf = gesture.location(in: self)
                    
                    moveView(touchPoint: currentTouchPointInSelf, startPoint: touchStartPointInSelf)
                    
                    delegate?.tapMoved?(self)
                    
                case .None:
                    return
                }
            }
        case .ended:
            
            currentTappedPostion = .None
            
            maxAspectFrame = CGRect.zero
            
            delegate?.tapEnd?(self)
            
        case .cancelled:
            
            currentTappedPostion = .None
            
            maxAspectFrame = CGRect.zero
            
            delegate?.tapEnd?(self)
            
        default:
            
            currentTappedPostion = .None
            
            maxAspectFrame = CGRect.zero
            
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
        guard let superview = superview else {
            return CGRect.zero
        }
        
        var x = rect.origin.x
        var y = rect.origin.y
        var width = rect.size.width
        var height = rect.size.height
        
        if x < superview.bounds.origin.x {
            let deltaW = frame.origin.x - superview.bounds.origin.x
            width = frame.size.width + deltaW
            x = superview.bounds.origin.x
        }
        
        if rect.origin.x + width > superview.bounds.origin.x + superview.bounds.size.width {
            width = superview.bounds.size.width - x
        }
        
        if y < superview.bounds.origin.y {
            let deltaH = frame.origin.y - superview.bounds.origin.y
            height = frame.size.height + deltaH
            y = superview.bounds.origin.y
        }
        
        if y + height > superview.bounds.origin.y + superview.bounds.size.height {
            height = superview.bounds.size.height - y
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
        
        guard let superview = superview else {
            return CGRect.zero
        }
        
        var x = rect.origin.x
        var y = rect.origin.y
        var width = rect.size.width
        var height = rect.size.height
        
        if x < superview.bounds.origin.x {
            if currentTappedPostion == .UpperLeft || currentTappedPostion == .LowerLeft {
                return maxAspectFrame
            }
        }

        if x + width > superview.bounds.origin.x + superview.bounds.size.width {
            if currentTappedPostion == .UpperRight || currentTappedPostion == .LowerRight {
                return maxAspectFrame
            }
        }

        if y < superview.bounds.origin.y {
            if currentTappedPostion == .UpperLeft || currentTappedPostion == .UpperRight {
                return maxAspectFrame
            }
        }

        if y + height > superview.bounds.origin.y + superview.bounds.size.height {
            if currentTappedPostion == .LowerLeft || currentTappedPostion == .LowerRight {
                return maxAspectFrame
            }
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
    
    
    private func measureMaximumKeepAspectFrame() -> CGRect {
        guard let superview = superview else {
            return CGRect.zero
        }
        
        var xMaxFrame = CGRect.zero
        var yMaxFrame = CGRect.zero
        
        switch currentTappedPostion {
        case .UpperLeft:
            
            xMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: superview.bounds.origin.x, y: frame.origin.y))
            
            yMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: frame.origin.x, y: superview.bounds.origin.y))
            
        case .UpperRight:
            
            xMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: superview.bounds.width, y: frame.origin.y))
            
            yMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: frame.origin.x + frame.width, y: superview.bounds.origin.y))
            
        case .LowerLeft:
            
            xMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: superview.bounds.origin.x, y: frame.origin.y + frame.height))
            
            yMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: frame.origin.x, y: superview.bounds.height))
            
        case .LowerRight:
            
            xMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: superview.bounds.width, y: frame.origin.y + frame.height))
            
            yMaxFrame = generateKeepAspectFrame(position: currentTappedPostion,
                                                currentTouchPoint: CGPoint(x: frame.origin.x + frame.width, y: superview.bounds.height))
            
        default:
            
            break
        }
        
        return xMaxFrame.width/frame.width < yMaxFrame.width/frame.width  ? xMaxFrame : yMaxFrame
        
    }
    
    
    private func moveView(touchPoint: CGPoint, startPoint: CGPoint) {
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

