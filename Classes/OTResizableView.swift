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
    
    func tapBegin(resizableView:OTResizableView)
    
    func tapChanged(resizableView:OTResizableView)
    
    func tapMoved(resizableView:OTResizableView)
    
    func tapEnd(resizableView:OTResizableView)

}

open class OTResizableView: UIView, UIGestureRecognizerDelegate {
    
    weak public var delegate:OTResizableViewDelegate?
    
    open var minimumHeight:CGFloat = 100
    open var minimumWidth:CGFloat = 100
    
    open var gripTappableSize:CGFloat = 40
    
    open var contentView:UIView = UIView()
    
    open var resizeEnabled:Bool = false {
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
    
    let gripPointDiameter:CGFloat = 10
    
    private(set) var currentTappedPostion:TappedPosition = .None
    
    private var startFrame = CGRect.zero
    private var minimumPoint = CGPoint.zero
    
    private var touchStartPointInSuperview = CGPoint.zero
    private var touchStartPointInSelf = CGPoint.zero
    
    private var gripPointView:OTGripPointView = OTGripPointView()
    
    //MARK:Initialize
    public init(contentView: UIView) {
        super.init(frame: contentView.bounds.insetBy(dx: -gripPointDiameter, dy: -gripPointDiameter))
        
        initialize()
        
        setContentView(newContentView: contentView)
    }
    
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialize() {
        prepareGesture()
    }
    
    
    //MARK:LifeCycle
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        prepareGripPointView()
    }
    
    
    //MARK:Prepare
    func prepareGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        
        let panGesutureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        addGestureRecognizer(panGesutureRecognizer)
    }
    
    
    func prepareGripPointView() {
        gripPointView = OTGripPointView.init(frame: bounds)
        gripPointView.isHidden = true
        
        gripPointView.viewStrokeColor = viewStrokeColor
        gripPointView.gripPointStrokeColor = gripPointStrokeColor
        gripPointView.gripPointFillColor = gripPointFillColor
        
        addSubview(gripPointView)
    }
    
    
    //MARK:Set
    func setContentView(newContentView: UIView) {
        contentView.removeFromSuperview()
        contentView = newContentView;
        contentView.frame.origin = CGPoint(x: gripPointDiameter, y: gripPointDiameter)
        addSubview(contentView)
        
        gripPointView.removeFromSuperview()
        addSubview(gripPointView)
    }
    
    
    func setFrame(newFrame: CGRect) {
        super.frame = newFrame
        contentView.frame = bounds.insetBy(dx: gripPointDiameter, dy: gripPointDiameter)
        gripPointView.frame = bounds
        gripPointView.setNeedsDisplay()
    }
    
    
    //MARK:Gesture
    @objc open func handleTap(gesture: UITapGestureRecognizer) {
        delegate?.tapBegin(resizableView: self)
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
            
            break
        
        case .changed:
            
            if resizeEnabled {
                
                let currentTouchPointInSuperview = gesture.location(in: superview)
                
                let differenceX = currentTouchPointInSuperview.x - touchStartPointInSuperview.x
                let differenceY = currentTouchPointInSuperview.y - touchStartPointInSuperview.y
                
                let startX = startFrame.origin.x
                let startY = startFrame.origin.y
                let startWidth = startFrame.size.width
                let startHeight = startFrame.size.height
                
                switch currentTappedPostion {
                case .UpperLeft:
                    
                    let resizeRect = CGRect(x: startX + differenceX, y: startY + differenceY, width: startWidth - differenceX, height: startHeight - differenceY)
                    resizeView(rect: resizeRect)
                    
                    break;
                
                case .UpperRight:
                    
                    let resizeRect = CGRect(x: startX, y: startY + differenceY, width: startWidth + differenceX, height: startHeight - differenceY)
                    resizeView(rect: resizeRect)
                    
                    break;
                    
                case .LowerLeft:
                    
                    let resizeRect = CGRect(x: startX + differenceX, y: startY, width: startWidth - differenceX, height: startHeight + differenceY)
                    resizeView(rect: resizeRect)
                    
                    break;
                    
                case .LowerRight:
                    
                    let resizeRect = CGRect(x: startX, y: startY, width: startWidth + differenceX, height: startHeight + differenceY)
                    resizeView(rect: resizeRect)
                    
                    break;
                    
                case .Center:
                    
                    let currentTouchPointInSelf = gesture.location(in: self)
                    moveView(touchPoint: currentTouchPointInSelf, startPoint: touchStartPointInSelf)
                    
                    
                    break;
                    
                default:
                    
                    break;
                }
                
                if currentTappedPostion == .Center {
                    delegate?.tapMoved(resizableView: self)
                } else {
                    delegate?.tapChanged(resizableView: self)
                }
            }
            
            break
        
        case .ended:
            
            currentTappedPostion = .None
            
            delegate?.tapEnd(resizableView: self)
            
            break
            
        case .cancelled:
            
            currentTappedPostion = .None
            
            delegate?.tapEnd(resizableView: self)
            
            break
            
        default:
            
            break
        }
    }
    
    
    //MARK:Prepare TapChanged
    func detectCurrentTappedPosition() -> TappedPosition {
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
    
    
    func measureMinimumPoint() -> CGPoint {
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

    
    //MARK:TapChanged Methods
    func resizeView(rect:CGRect) {
        var x = rect.origin.x
        var y = rect.origin.y
        var width = rect.size.width
        var height = rect.size.height
        
        if rect.origin.x < (superview?.bounds.origin.x)! {
            let deltaW = frame.origin.x - (superview?.bounds.origin.x)!
            width = frame.size.width + deltaW
            x = (superview?.bounds.origin.x)!
        }
        
        if (x + width > (superview?.bounds.origin.x)! + (superview?.bounds.size.width)!) {
            width = (superview?.bounds.size.width)! - x;
        }
        
        if (y < (superview?.bounds.origin.y)!) {
            let deltaH = frame.origin.y - (superview?.bounds.origin.y)!;
            height = frame.size.height + deltaH;
            y = (superview?.bounds.origin.y)!;
        }
        
        if (y + height > (superview?.bounds.origin.y)! + (superview?.bounds.size.height)!) {
            height = (superview?.bounds.size.height)! - y;
        }
        
        if (width <= minimumWidth) {
            width = minimumWidth;
            x = minimumPoint.x;
        }
        
        if (height <= minimumHeight) {
            height = minimumHeight;
            y = minimumPoint.y;
        }
        
        setFrame(newFrame: CGRect(x: x, y: y, width: width, height: height))
    }

    
    func moveView(touchPoint: CGPoint, startPoint: CGPoint)
    {
        var newCenter = CGPoint(x: center.x + touchPoint.x - startPoint.x, y: center.y + touchPoint.y - startPoint.y)
        
        let midPointX = bounds.midX
        
        if newCenter.x > (superview?.bounds.size.width)! - midPointX {
            newCenter.x = (superview?.bounds.size.width)! - midPointX;
        }
        
        if newCenter.x < midPointX {
            newCenter.x = midPointX;
        }
        
        let midPointY = bounds.midY
        
        if newCenter.y > (superview?.bounds.size.height)! - midPointY {
            newCenter.y = (superview?.bounds.size.height)! - midPointY;
        }
        
        if newCenter.y < midPointY {
            newCenter.y = midPointY;
        }
        
        center = newCenter;
    }
}

