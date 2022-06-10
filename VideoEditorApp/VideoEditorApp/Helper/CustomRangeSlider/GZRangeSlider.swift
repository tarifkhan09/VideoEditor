//
//  GZRangeSlider.swift
//  VideoEditorApp
//
//  Created byMD Tarif khan on 28/3/22.
//

import Foundation
import UIKit

class GZRangeSlider: UIControl{
    private var leftHandleLayer: CALayer!
    private var rightHandleLayer: CALayer!
    private var normalbackImageView: UIImageView!
    private var highlightedImageView: UIImageView!
    private var leftTextLayer: CATextLayer!
    private var rightTextLayer: CATextLayer!
    
    private var barHeight: CGFloat = 10
    private var barWidth: CGFloat = 0
    private var handleWidth: CGFloat = 30
    private var handleHeight: CGFloat = 30
    
    private var insideMax: Int = 1000
    private var insideMin: Int = 0
    private var leftValue: Int = 0
    private var rightValue: Int = 0
    private var insideAccuracy: Int = 1
    
    private var previouslocation = CGPoint.zero
    
    private var isLeftSelected = false
    private var isRightSelected = false
    
    var valueChangeClosure: ((_ minValue: Int, _ maxValue: Int) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setInitValue()
        
        barWidth = frame.width - 2 * handleWidth
        normalbackImageView = UIImageView()
        normalbackImageView.layer.cornerRadius = 4
        normalbackImageView.backgroundColor = UIColor.lightGray
        normalbackImageView.frame = CGRect(x: handleWidth * 0.5,y: 0.5 * (frame.height - barHeight),width: frame.width - handleWidth,height: barHeight)
        addSubview(normalbackImageView)
        
        highlightedImageView = UIImageView()
        highlightedImageView.backgroundColor = UIColor.white
        highlightedImageView.frame = CGRect(x: handleWidth * 0.5 ,y: 0.5 * (frame.height - barHeight),width: frame.width - handleWidth,height: barHeight)
        addSubview(highlightedImageView)
        
        leftHandleLayer = createHandleLayer()
        leftHandleLayer.frame = CGRect(x: 0, y: 0.5 * (frame.height - handleHeight), width: handleWidth, height: handleHeight)
        layer.addSublayer(leftHandleLayer)
        
        rightHandleLayer = createHandleLayer()
        rightHandleLayer.frame = CGRect(x: frame.width - handleWidth, y: leftHandleLayer.frame.minY, width: handleWidth, height: handleHeight)
        layer.addSublayer(rightHandleLayer)
        
        let kTextWidth: CGFloat = 50
        let kTextHeight: CGFloat = 20
        leftTextLayer = createTextLayer()
        leftTextLayer.string = "\(insideMin)"
        layer.addSublayer(leftTextLayer)
        leftTextLayer.frame = CGRect(x: leftHandleLayer.frame.minX - 0.5 * (kTextWidth - leftHandleLayer.frame.width), y: leftHandleLayer.frame.minY - kTextHeight, width: kTextWidth, height: kTextHeight)
        
        rightTextLayer = createTextLayer()
        rightTextLayer.string = "\(insideMax)"
        layer.addSublayer(rightTextLayer)
        rightTextLayer.frame = CGRect(x: rightHandleLayer.frame.minX - 0.5 * (kTextWidth - leftHandleLayer.frame.width), y: leftTextLayer.frame.minY, width: kTextWidth, height: kTextHeight)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: public method
    func setRange(minRange: Int, maxRange: Int, accuracy: Int){
        assert(maxRange >= minRange, "maxRange = \(maxRange) less than minRange = \(minRange)")
        insideMax = maxRange
        insideMin = minRange
        insideAccuracy = accuracy
        setInitValue()
        setLabelText()
    }
    
    func setCurrentValue(left: Int, right: Int){
        if left >= right{
            return
        }
        leftValue = max(insideMin,left)
        leftValue = min(insideMax,leftValue)
        
        rightValue = max(right,insideMin)
        rightValue = min(rightValue,insideMax)
        
        let range = insideMax - insideMin
        let leftX = CGFloat(leftValue - insideMin)/CGFloat(range)
        let rightX = CGFloat(rightValue - insideMin)/CGFloat(range)
        
        leftHandleLayer.frame = CGRect(x: leftX * barWidth, y: 0.5 * (frame.height - handleHeight), width: handleWidth, height: handleHeight)
        rightHandleLayer.frame = CGRect(x: rightX * barWidth + leftHandleLayer.frame.width, y: leftHandleLayer.frame.minY, width: handleWidth, height: handleHeight)
        
        setLabelText()
        updateHighlightedBar()
    }
    
    //MARK: private method
    private func setInitValue(){
        leftValue = insideMin
        rightValue = insideMax
    }
    
    private func updateHighlightedBar(){
        highlightedImageView.frame = CGRect(x: leftHandleLayer.frame.maxX - 0.5 * handleWidth,y: 0.5 * (frame.height - barHeight), width: rightHandleLayer.frame.minX - leftHandleLayer.frame.maxX + handleWidth,height: barHeight)
        setLabelText()
        valueChangeClosure?(leftValue/insideAccuracy * insideAccuracy,rightValue/insideAccuracy * insideAccuracy)
    }
    
    private func setLabelText(){
        leftTextLayer.string = "\(leftValue/insideAccuracy * insideAccuracy)"
        rightTextLayer.string = "\(rightValue/insideAccuracy * insideAccuracy)"
    }
    
    private func createHandleLayer() -> CALayer{
        let layer = CALayer()
        layer.cornerRadius = handleWidth * 0.5
        layer.backgroundColor = UIColor.red.cgColor
        return layer
    }
    
    private func createTextLayer() -> CATextLayer{
        let layer = CATextLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.foregroundColor = UIColor.white.cgColor
        layer.fontSize = 12
//        CATextLayerAlignmentMode(rawValue: layer.alignmentMode = "center") ?? <#default value#>
        return layer
    }
}

//MARK: touch
extension GZRangeSlider{
    private func setHitRect(rect: CGRect) -> CGRect{
        let offset:CGFloat = 10
        return CGRect(x: rect.minX, y: rect.minY - offset, width: rect.width, height: 2 * offset + rect.height)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
        isLeftSelected = setHitRect(rect: leftHandleLayer.frame).contains(previouslocation)
        isRightSelected = setHitRect(rect: rightHandleLayer.frame).contains(previouslocation)
        return isLeftSelected || isRightSelected
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let deltaLocation = (location.x - previouslocation.x)
        previouslocation = location
        
        if isLeftSelected{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            leftHandleLayer.frame.origin.x = max(leftHandleLayer.frame.origin.x + deltaLocation, normalbackImageView.frame.minX + 0.5 * handleWidth - leftHandleLayer.frame.width)
            leftHandleLayer.frame.origin.x = min(leftHandleLayer.frame.origin.x, rightHandleLayer.frame.origin.x - leftHandleLayer.frame.width)
            leftValue = Int(leftHandleLayer.frame.origin.x/barWidth * CGFloat(insideMax - insideMin)) + insideMin
            updateHighlightedBar()
            CATransaction.commit()
            
        }else if isRightSelected{
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            rightHandleLayer.frame.origin.x = min(rightHandleLayer.frame.origin.x + deltaLocation,frame.width - rightHandleLayer.frame.width)
            rightHandleLayer.frame.origin.x = max(rightHandleLayer.frame.origin.x,leftHandleLayer.frame.origin.x + leftHandleLayer.frame.width)
            rightValue = Int((rightHandleLayer.frame.origin.x - leftHandleLayer.frame.width)/barWidth * CGFloat(insideMax - insideMin)) + insideMin
            updateHighlightedBar()
            CATransaction.commit()
        }
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        isLeftSelected = false
        isRightSelected = false
    }
    
    
}
