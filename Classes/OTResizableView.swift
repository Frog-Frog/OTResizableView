//
//  OTResizableView.swift
//  OTResizableView
//
//  Created by Tomosuke Okada on 2017/08/27.
//  Copyright © 2017年 TomosukeOkada. All rights reserved.
//

import UIKit

enum TappedPosition: Int
{
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

public class OTResizableView: UIView, UIGestureRecognizerDelegate {
    
    weak public var delegate:OTResizableViewDelegate?
    
    public var minimumHeight:CGFloat = 100
    public var minimumWidth:CGFloat = 100
    
    public var gripTappableSize:CGFloat = 40
    
    public var contentView:UIView = UIView.init()
    
    private let gripPointSize:CGFloat = 10
    
    public var resizeEnabled:Bool = false
    {
        didSet {
            self.gripPointView.isHidden = self.resizeEnabled ? false:true
        }
    }
    
    public var viewStrokeColor = UIColor.red
    {
        didSet {
            self.gripPointView.viewStrokeColor = self.viewStrokeColor
        }
    }

    public var gripPointStrokeColor = UIColor.white
    {
        didSet{
            self.gripPointView.gripPointStrokeColor = self.gripPointStrokeColor
        }
    }
    
    public var gripPointFillColor = UIColor.blue
    {
        didSet {
            self.gripPointView.gripPointFillColor = self.gripPointFillColor
        }
    }
    
    private var currentTappedPostion:TappedPosition = TappedPosition.None
    
    private var startFrame = CGRect.zero
    private var minimumPoint = CGPoint.zero
    
    private var touchStartPointInSuperview = CGPoint.zero
    private var touchStartPointInSelf = CGPoint.zero
    
    private var gripPointView:OTGripPointView = OTGripPointView.init()
    
    //MARK:Initialize
    public init(contentView: UIView) {
        super.init(frame: contentView.bounds.insetBy(dx: -self.gripPointSize, dy: -self.gripPointSize))
        
        self.initialize()
        
        self.setContentView(newContentView: contentView)
    }
    
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialize()
    {
        self.prepareGesture()
    }
    
    
    //MARK:LifeCycle
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        self.prepareGripPointView()
    }
    
    
    //MARK:Prepare
    func prepareGesture()
    {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        
        let panGesutureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        self.addGestureRecognizer(panGesutureRecognizer)
    }
    
    
    func prepareGripPointView()
    {
        self.gripPointView = OTGripPointView.init(frame: self.bounds)
        self.gripPointView.isHidden = true
        
        self.gripPointView.viewStrokeColor = self.viewStrokeColor
        self.gripPointView.gripPointStrokeColor = self.gripPointStrokeColor
        self.gripPointView.gripPointFillColor = self.gripPointFillColor
        
        self.addSubview(self.gripPointView)
    }
    
    
    //MARK:Set
    func setContentView(newContentView: UIView)
    {
        self.contentView.removeFromSuperview()
        self.contentView = newContentView;
        self.contentView.frame.origin = CGPoint(x: self.gripPointSize, y: self.gripPointSize)
        self.addSubview(self.contentView)
        
        self.gripPointView.removeFromSuperview()
        self.addSubview(self.gripPointView)
    }
    
    
    func setFrame(newFrame: CGRect)
    {
        super.frame = newFrame
        self.contentView.frame = self.bounds.insetBy(dx: self.gripPointSize, dy: self.gripPointSize)
        self.gripPointView.frame = self.bounds
        self.gripPointView.setNeedsDisplay()
    }
    
    
    //MARK:Gesture
    func handleTap(gesture: UITapGestureRecognizer)
    {
        self.delegate?.tapBegin(resizableView: self)
    }
    
    
    func handlePan(gesture: UIPanGestureRecognizer)
    {
        switch gesture.state {
        case .began:
            if self.resizeEnabled {
                
                self.startFrame = self.frame;
                
                self.touchStartPointInSuperview = gesture.location(in: self.superview)
                self.touchStartPointInSelf = gesture.location(in: self)
                
                self.currentTappedPostion = self.detectCurrentTappedPosition()
                
                if self.currentTappedPostion != .None && self.currentTappedPostion != .Center {
                    self.minimumPoint = self.measureMinimumPoint()
                }
            }
            
            break
        
        case .changed:
            
            if self.resizeEnabled {
                
                let currentTouchPointInSuperview = gesture.location(in: self.superview)
                
                let differenceX = currentTouchPointInSuperview.x - self.touchStartPointInSuperview.x
                let differenceY = currentTouchPointInSuperview.y - self.touchStartPointInSuperview.y
                
                let startX = self.startFrame.origin.x
                let startY = self.startFrame.origin.y
                let startWidth = self.startFrame.size.width
                let startHeight = self.startFrame.size.height
                
                switch self.currentTappedPostion {
                case .UpperLeft:
                    
                    let resizeRect = CGRect(x: startX + differenceX, y: startY + differenceY, width: startWidth - differenceX, height: startHeight - differenceY)
                    self.resizeView(rect: resizeRect)
                    
                    break;
                
                case .UpperRight:
                    
                    let resizeRect = CGRect(x: startX, y: startY + differenceY, width: startWidth + differenceX, height: startHeight - differenceY)
                    self.resizeView(rect: resizeRect)
                    
                    break;
                    
                case .LowerLeft:
                    
                    let resizeRect = CGRect(x: startX + differenceX, y: startY, width: startWidth - differenceX, height: startHeight + differenceY)
                    self.resizeView(rect: resizeRect)
                    
                    break;
                    
                case .LowerRight:
                    
                    let resizeRect = CGRect(x: startX, y: startY, width: startWidth + differenceX, height: startHeight + differenceY)
                    self.resizeView(rect: resizeRect)
                    
                    break;
                    
                case .Center:
                    
                    let currentTouchPointInSelf = gesture.location(in: self)
                    self.moveView(touchPoint: currentTouchPointInSelf, startPoint: self.touchStartPointInSelf)
                    
                    
                    break;
                    
                default:
                    
                    break;
                }
                
                if self.currentTappedPostion == .Center {
                    self.delegate?.tapMoved(resizableView: self)
                } else {
                    self.delegate?.tapChanged(resizableView: self)
                }
            }
            
            break
        
        case .ended:
            
            self.currentTappedPostion = .None
            
            self.delegate?.tapEnd(resizableView: self)
            
            break
            
        case .cancelled:
            
            self.currentTappedPostion = .None
            
            self.delegate?.tapEnd(resizableView: self)
            
            break
            
        default:
            
            break
        }
    }
    
    
    //MARK:Prepare TapChanged
    func detectCurrentTappedPosition() -> TappedPosition
    {
        if self.touchStartPointInSelf.x < self.gripTappableSize && self.touchStartPointInSelf.y < self.gripTappableSize {
            
            return .UpperLeft
            
        } else if self.bounds.size.width - self.touchStartPointInSelf.x < self.gripTappableSize && self.touchStartPointInSelf.y < self.gripTappableSize {
            
            return .UpperRight
            
        } else if self.touchStartPointInSelf.x < self.gripTappableSize && self.bounds.size.height - self.touchStartPointInSelf.y < self.gripTappableSize {
            
            return .LowerLeft
            
        } else if self.bounds.size.width - self.touchStartPointInSelf.x < self.gripTappableSize && self.bounds.size.height - self.touchStartPointInSelf.y < self.gripTappableSize {
            
            return .LowerRight
            
        } else {
            
            return .Center
            
        }
    }
    
    
    func measureMinimumPoint() -> CGPoint {
        let originX = self.startFrame.origin.x
        let originY = self.startFrame.origin.y
        
        let upperRightX = originX + self.startFrame.size.width
        let lowerLeftY = originY + self.startFrame.size.height
        
        switch self.currentTappedPostion {
            
        case .UpperLeft:
            
            return CGPoint(x: upperRightX - self.minimumWidth, y: lowerLeftY - self.minimumHeight)
            
        case .UpperRight:
            
            return CGPoint(x: originX, y: lowerLeftY - self.minimumHeight)
            
        case .LowerLeft:
            
            return CGPoint(x: upperRightX - self.minimumWidth, y: originY)
            
        case .LowerRight:
            
            return CGPoint(x: originX, y: originY)
            
        default:
            
            return CGPoint.zero
        }
    }

    
    //MARK:TapChanged Methods
    func resizeView(rect:CGRect)
    {
        var x = rect.origin.x
        var y = rect.origin.y
        var width = rect.size.width
        var height = rect.size.height
        
        if rect.origin.x < (self.superview?.bounds.origin.x)! {
            let deltaW = self.frame.origin.x - (self.superview?.bounds.origin.x)!
            width = self.frame.size.width + deltaW
            x = (self.superview?.bounds.origin.x)!
        }
        
        if (x + width > (self.superview?.bounds.origin.x)! + (self.superview?.bounds.size.width)!) {
            width = (self.superview?.bounds.size.width)! - x;
        }
        
        if (y < (self.superview?.bounds.origin.y)!) {
            let deltaH = self.frame.origin.y - (self.superview?.bounds.origin.y)!;
            height = self.frame.size.height + deltaH;
            y = (self.superview?.bounds.origin.y)!;
        }
        
        if (y + height > (self.superview?.bounds.origin.y)! + (self.superview?.bounds.size.height)!) {
            height = (self.superview?.bounds.size.height)! - y;
        }
        
        if (width <= self.minimumWidth) {
            width = self.minimumWidth;
            x = self.minimumPoint.x;
        }
        
        if (height <= self.minimumHeight) {
            height = self.minimumHeight;
            y = self.minimumPoint.y;
        }
        
        self.setFrame(newFrame: CGRect(x: x, y: y, width: width, height: height))
    }

    
    
    
    
    func moveView(touchPoint: CGPoint, startPoint: CGPoint)
    {
        var newCenter = CGPoint(x: self.center.x + touchPoint.x - startPoint.x, y: self.center.y + touchPoint.y - startPoint.y)
        
        let midPointX = self.bounds.midX
        
        if newCenter.x > (self.superview?.bounds.size.width)! - midPointX {
            newCenter.x = (self.superview?.bounds.size.width)! - midPointX;
        }
        
        if newCenter.x < midPointX {
            newCenter.x = midPointX;
        }
        
        let midPointY = self.bounds.midY
        
        if newCenter.y > (self.superview?.bounds.size.height)! - midPointY {
            newCenter.y = (self.superview?.bounds.size.height)! - midPointY;
        }
        
        if newCenter.y < midPointY {
            newCenter.y = midPointY;
        }
        
        self.center = newCenter;
    }
}

