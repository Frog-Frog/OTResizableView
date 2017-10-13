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

    var viewStrokeColor: UIColor?
    let viewStrokeLineWidth:CGFloat = 2
    
    var gripPointStrokeColor: UIColor?
    var gripPointFillColor: UIColor?
    
    let gripPointDiameter:CGFloat = 10
    let gripPointStrokeWidth:CGFloat = 2
    
    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        backgroundColor = UIColor.clear
    }
    
    
    override func draw(_ rect: CGRect) {
        let strokeRect = rect.insetBy(dx: gripPointDiameter, dy: gripPointDiameter)
        draw(stroke: strokeRect, lineWidth: viewStrokeLineWidth, color: viewStrokeColor!)
        
        let leftX:CGFloat = gripPointDiameter/2
        let rightX:CGFloat = rect.size.width - gripPointDiameter - gripPointDiameter/2
        let upperY:CGFloat = gripPointDiameter/2
        let lowerY:CGFloat = rect.size.height - gripPointDiameter - gripPointDiameter/2
        
        let gripPointSize = CGSize(width: gripPointDiameter, height: gripPointDiameter)
        
        let upperLeft = CGRect(origin: CGPoint(x: leftX, y: upperY), size: gripPointSize)
        draw(circle: upperLeft, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
        
        let upperRight = CGRect(origin: CGPoint(x: rightX, y: upperY), size: gripPointSize)
        draw(circle: upperRight, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
        
        let lowerLeft = CGRect(origin: CGPoint(x: leftX, y: lowerY), size:gripPointSize)
        draw(circle: lowerLeft, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
        
        let lowerRight = CGRect(origin: CGPoint(x: rightX, y: lowerY), size:gripPointSize)
        draw(circle: lowerRight, strokeWidth: gripPointStrokeWidth, strokeColor: gripPointStrokeColor!, fillColor: gripPointFillColor!)
    }
    
    
    private func draw(stroke rect:CGRect,lineWidth:CGFloat,color:UIColor) {
        let strokePath = UIBezierPath(rect: rect)
        strokePath.lineWidth = lineWidth;
        
        color.setStroke()
        
        strokePath.stroke()
    }
    
    
    private func draw(circle rect: CGRect, strokeWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor) {
        let circlePath = UIBezierPath(ovalIn: rect)
        circlePath.lineWidth = strokeWidth
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        circlePath.fill()
        circlePath.stroke()
    }
    
    
}
