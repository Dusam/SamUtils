//
//  DrawnImageView.swift
//  AR Doctor
//
//  Created by Qian-Yu Du on 2022/5/3.
//

import UIKit
import AVFoundation
 
enum DrawMarkType: Int, CaseIterable {
    case pencil, arrow, line, circle, circelFill, rectangle, rectangleFill
    
    var title: String {
        switch self {
        case .pencil:
            return "鉛筆"
        case .arrow:
            return "箭頭"
        case .line:
            return "直線"
        case .circle:
            return "圓形"
        case .circelFill:
            return "填滿圓形"
        case .rectangle:
            return "方形"
        case .rectangleFill:
            return "填滿方形"
        }
    }
}

class DrawnImageView: UIImageView {
    
    private lazy var path = UIBezierPath()
    private lazy var beginPoint = CGPoint.zero
    private lazy var previousTouchPoint = CGPoint.zero
    private lazy var currentColor = UIColor.red
    private lazy var layers: [CAShapeLayer] = []
    
    private var currentLayerIndex = 0
    private var markType: DrawMarkType = .pencil
    private var isDraw: Bool = true

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(move))
        self.addGestureRecognizer(panRecognizer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(move))
        self.addGestureRecognizer(panRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupView() {
        isUserInteractionEnabled = true
    }
    
    func setLineColor(_ color: UIColor) {
            currentColor = color
            color.setStroke()
    }
    
    func setDraw(_ isDraw: Bool) {
        self.isDraw = isDraw
    }
    
    func setMarkType(_ type: DrawMarkType) {
        self.markType = type
    }
    
    func nextLayer() {
        guard currentLayerIndex + 1 < self.layers.count else {
            return
        }
        currentLayerIndex = currentLayerIndex + 1
        let newLayer = self.layers[currentLayerIndex]
        layer.insertSublayer(newLayer, at: UInt32(currentLayerIndex))
    }
    
    func previousLayer() {
        guard currentLayerIndex - 1 >= 0 || currentLayerIndex == 0 else {
            return
        }
        currentLayerIndex = currentLayerIndex - 1
        layer.sublayers?.last?.removeFromSuperlayer()
    }
    
    @objc private func move(gesture : UIPanGestureRecognizer) {
        guard isDraw else { return }
        
        let state = gesture.state
        switch state {
        case .began:
            UIGraphicsBeginImageContextWithOptions(self.image!.size, false, 0.0)
            previousTouchPoint = gesture.location(in: self)
            beginPoint = gesture.location(in: self)
            path = UIBezierPath()
            path.stroke()
            let newLayer = CAShapeLayer()
            newLayer.lineWidth = 1
            newLayer.lineCap = .round
            newLayer.lineJoin = .round
            newLayer.strokeColor = currentColor.cgColor
            if markType == .circelFill || markType == .rectangleFill || markType == .arrow {
                newLayer.fillColor = currentColor.cgColor
            } else {
                newLayer.fillColor = UIColor.clear.cgColor
            }
            
            if currentLayerIndex < self.layers.count - 1 {
                // 回上一步後又直接新增時，須將當前位置以後的 layer 全部移除，避免上下一步切換時會有邏輯錯誤
                self.layers.removeSubrange((currentLayerIndex + 1)...)
            }
            self.layers.append(newLayer)
            
            currentLayerIndex = self.layers.count - 1
            layer.insertSublayer(newLayer, at: UInt32(currentLayerIndex))
        
        case .changed:
            guard let layers = layer.sublayers as? [CAShapeLayer],
                  let currentLayer = layers.last else {
                return
            }
            let location = gesture.location(in: self)
            
            switch markType {
            case .pencil:
                addPencil(location, previousTouchPoint)
            case .arrow:
                addArrow(beginPoint, location)
            case .line:
                addLine(beginPoint, location)
            case .circle, .circelFill:
                addCircle(beginPoint, location)
            case .rectangle, .rectangleFill:
                addRect(beginPoint, location)
            }
            
            previousTouchPoint = location
            
            currentLayer.path = path.cgPath
            self.setNeedsDisplay()
            
        case .ended:
            UIGraphicsEndImageContext()
        default: break
        }
    }
    
    private func addPencil(_ beginPoint: CGPoint, _ lastPoint: CGPoint) {
        path.move(to: beginPoint)
        path.addLine(to: lastPoint)
    }
    
    private func addRect(_ beginPoint: CGPoint, _ lastPoint: CGPoint) {
        path = UIBezierPath(rect: CGRect(origin: CGPoint(x: min(beginPoint.x, lastPoint.x), y: min(beginPoint.y, lastPoint.y)),
                                         size: CGSize(width: abs(lastPoint.x - beginPoint.x), height: abs(lastPoint.y - beginPoint.y))))
    }
    
    private func addLine(_ beginPoint: CGPoint, _ lastPoint: CGPoint) {
        path = UIBezierPath()
        path.move(to: beginPoint)
        path.addLine(to: lastPoint)
    }
    
    private func addCircle(_ beginPoint: CGPoint, _ lastPoint: CGPoint) {
        path = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: min(beginPoint.x, lastPoint.x), y: min(beginPoint.y, lastPoint.y)),
                                           size: CGSize(width: abs(lastPoint.x - beginPoint.x), height: abs(lastPoint.y - beginPoint.y))))
    }
    
    private func addArrow(_ beginPoint: CGPoint, _ lastPoint: CGPoint) {
        path = UIBezierPath()
        path.move(to: beginPoint)
        path.addLine(to: lastPoint)
        
        let startEndAngle = atan((lastPoint.y - beginPoint.y) / (lastPoint.x - beginPoint.x)) + ((lastPoint.x - beginPoint.x) < 0 ? CGFloat(Double.pi) : 0)
        let arrowAngle = CGFloat(Double.pi / 4)

        let arrowLine1 = CGPoint(x: lastPoint.x + 4 * cos(CGFloat(Double.pi) - startEndAngle + arrowAngle),
                                 y: lastPoint.y - 4 * sin(CGFloat(Double.pi) - startEndAngle + arrowAngle))
        let arrowLine2 = CGPoint(x: lastPoint.x + 4 * cos(CGFloat(Double.pi) - startEndAngle - arrowAngle),
                                 y: lastPoint.y - 4 * sin(CGFloat(Double.pi) - startEndAngle - arrowAngle))
        
        path.addLine(to: arrowLine1)
        path.addLine(to: arrowLine2)
        path.addLine(to: lastPoint)
    }
}
