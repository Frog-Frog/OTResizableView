//
//  OTGripPointView.swift
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

class OTGripPointView: UIView {

    public var viewStrokeColor: UIColor?
    let viewStrokeLineWidth:CGFloat = 2
    
    public var gripPointStrokeColor: UIColor?
    public var gripPointFillColor: UIColor?
    
    let gripPointDiameter:CGFloat = 10
    let gripPointStrokeWidth:CGFloat = 2
    
    init()
    {
        super.init(frame: CGRect.zero)
    }
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect)
    {
        let strokeRect = rect.insetBy(dx: gripPointDiameter, dy: gripPointDiameter)
        draws(strokeRect: strokeRect, lineWidth: viewStrokeLineWidth, color: viewStrokeColor!)
        
        let leftX:CGFloat = gripPointDiameter/2
        let rightX:CGFloat = rect.size.width - gripPointDiameter - gripPointDiameter/2
        let upperY:CGFloat = gripPointDiameter/2
        let lowerY:CGFloat = rect.size.height - gripPointDiameter - gripPointDiameter/2
        
        let gripPointSize = CGSize(width: gripPointDiameter, height: gripPointDiameter)
        
        let upperLeft = CGRect(origin: CGPoint(x: leftX, y: upperY), size: gripPointSize)
        draws(circleRect: upperLeft, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
        
        let upperRight = CGRect(origin: CGPoint(x: rightX, y: upperY), size: gripPointSize)
        draws(circleRect: upperRight, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
        
        let lowerLeft = CGRect(origin: CGPoint(x: leftX, y: lowerY), size:gripPointSize)
        draws(circleRect: lowerLeft, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
        
        let lowerRight = CGRect(origin: CGPoint(x: rightX, y: lowerY), size:gripPointSize)
        draws(circleRect: lowerRight, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
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
