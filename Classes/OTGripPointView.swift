//
//  OTGripPointView.swift
//  OTResizableView
//
//  Created by Tomosuke Okada on 2017/08/27.
//  Copyright © 2017年 TomosukeOkada. All rights reserved.
//

import UIKit

class OTGripPointView: UIView {

    public var viewStrokeColor: UIColor?
    let viewStrokeLineWidth:CGFloat = 2
    
    public var gripPointStrokeColor: UIColor?
    public var gripPointFillColor: UIColor?
    
    let gripPointSize:CGFloat = 10
    let gripPointStrokeWidth:CGFloat = 2
    
    init()
    {
        super.init(frame: CGRect.zero)
    }
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect)
    {
        let strokeRect = rect.insetBy(dx: self.gripPointSize, dy: self.gripPointSize)
        self.draws(strokeRect: strokeRect, lineWidth: self.viewStrokeLineWidth, color: self.viewStrokeColor!)
        
        let leftX:CGFloat = self.gripPointSize/2
        let rightX:CGFloat = rect.size.width - self.gripPointSize - self.gripPointSize/2
        let upperY:CGFloat = self.gripPointSize/2
        let lowerY:CGFloat = rect.size.height - self.gripPointSize - self.gripPointSize/2
        
        let gripPointSize = CGSize(width: self.gripPointSize, height: self.gripPointSize)
        
        let upperLeft = CGRect(origin: CGPoint(x: leftX, y: upperY), size: gripPointSize)
        self.draws(circleRect: upperLeft, strokeWidth: self.gripPointStrokeWidth, strokeColor: self.gripPointStrokeColor!, fillColor: self.gripPointFillColor!)
        
        let upperRight = CGRect(origin: CGPoint(x: rightX, y: upperY), size: gripPointSize)
        self.draws(circleRect: upperRight, strokeWidth: self.gripPointStrokeWidth, strokeColor: self.gripPointStrokeColor!, fillColor: self.gripPointFillColor!)
        
        let lowerLeft = CGRect(origin: CGPoint(x: leftX, y: lowerY), size:gripPointSize)
        self.draws(circleRect: lowerLeft, strokeWidth: self.gripPointStrokeWidth, strokeColor: self.gripPointStrokeColor!, fillColor: self.gripPointFillColor!)
        
        let lowerRight = CGRect(origin: CGPoint(x: rightX, y: lowerY), size:gripPointSize)
        self.draws(circleRect: lowerRight, strokeWidth: self.gripPointStrokeWidth, strokeColor: self.gripPointStrokeColor!, fillColor: self.gripPointFillColor!)
    }
    
    
    func draws(strokeRect:CGRect,lineWidth:CGFloat,color:UIColor)
    {
        let strokePath = UIBezierPath.init(rect: strokeRect)
        strokePath.lineWidth = lineWidth;
        
        color.setStroke()
        
        strokePath.stroke()
    }
    
    
    func draws(circleRect:CGRect,strokeWidth:CGFloat,strokeColor:UIColor,fillColor:UIColor)
    {
        let circlePath = UIBezierPath.init(ovalIn: circleRect)
        circlePath.lineWidth = strokeWidth
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        circlePath.fill()
        circlePath.stroke()
    }
    
    
}
