//
//  FerrisWheelViewController.swift
//  Demo-Swift
//
//  Created by 唐米 on 2025/5/6.
//

import Foundation
import UIKit


class FerrisWheelViewController: UIViewController {
    
    private let ferrisWheelLayer = CAShapeLayer()
    private let wheelRadius: CGFloat = 100.0
    private let numberOfCarts = 7
    private let cartSize: CGSize = CGSize(width: 30, height: 40)
    private var circleView = UIView()
    private var cartViews: [UIView] = []
    private var animationDuration = 30 //转动一圈的时间
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupFerrisWheel()
        addCarts()
        NotificationCenter.default.addObserver(self, selector: #selector(startAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        startAnimation()
    }
    
    private func setupFerrisWheel() {
        circleView = UIView(frame: CGRect(x: 100, y: 300, width: 200, height: 200))
        circleView.backgroundColor = .clear
        view.addSubview(circleView)
        let center = CGPoint(x: circleView.bounds.midX, y: circleView.bounds.midY)
        let circlePath = UIBezierPath(arcCenter: center, radius: wheelRadius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        ferrisWheelLayer.path = circlePath.cgPath
        ferrisWheelLayer.fillColor = UIColor.clear.cgColor
        ferrisWheelLayer.strokeColor = UIColor.gray.cgColor
        ferrisWheelLayer.lineWidth = 2
        circleView.layer.addSublayer(ferrisWheelLayer)
        setup()
    }
    
    private func addCarts() {
        let center = CGPoint(x: circleView.bounds.midX, y: circleView.bounds.midY)
        let angleStep = (2 * .pi) / CGFloat(numberOfCarts)
        
        for i in 0..<numberOfCarts {
            let angle = CGFloat(i) * angleStep
            let cartX = center.x + wheelRadius * cos(angle) - cartSize.width / 2
            let cartY = center.y + wheelRadius * sin(angle) - cartSize.height / 2
            
            let cartView = UIView(frame: CGRect(x: cartX, y: cartY, width: cartSize.width, height: cartSize.height))
            cartView.backgroundColor = UIColor.red
            if i == 2 {
                cartView.backgroundColor = UIColor.blue
            }
            circleView.addSubview(cartView)
            cartViews.append(cartView)
        }
    }
    private func setup() {
        let bounds =  circleView.bounds
         // 创建圆形的 UIBezierPath
         let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                       radius: min(bounds.width, bounds.height) / 2,
                                       startAngle: 0,
                                       endAngle: .pi * 2,
                                       clockwise: true)

         // 创建圆形的 CAShapeLayer
         let circleLayer = CAShapeLayer()
         circleLayer.path = circlePath.cgPath
          circleLayer.strokeColor = UIColor.orange.cgColor
         circleLayer.fillColor = UIColor.clear.cgColor
         circleLayer.lineWidth = 2
         circleView.layer.addSublayer(circleLayer)
   
        let angleStep = (2 * Double.pi) / Double(numberOfCarts)
        let fullRadius = min(bounds.width, bounds.height) / 2
        let halfRadius = fullRadius / 4 // 线条长度

        // 循环绘制八条线（长度为原来的一半）
        for i in 0..<numberOfCarts {
            let angle = CGFloat(i) * CGFloat(angleStep)
            
            // 优化：计算线的起点（圆周）和终点（半半径处，即长度减半）
            let startX = bounds.midX + fullRadius * cos(angle)
            let startY = bounds.midY + fullRadius * sin(angle)
            let endX = bounds.midX + halfRadius * cos(angle) // 终点从圆心改为半半径位置
            let endY = bounds.midY + halfRadius * sin(angle)
            
            // 创建线的 UIBezierPath
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: startX, y: startY))
            linePath.addLine(to: CGPoint(x: endX, y: endY))
            
            // 1. 创建图片图层（承载图片）
            let imageLayer = CALayer()
            imageLayer.contents = UIImage(named: "线1")?.cgImage
            imageLayer.contentsScale = UIScreen.main.scale // 优化：适配屏幕分辨率，避免模糊
            imageLayer.frame = circleView.bounds
            
            // 2. 创建线条图层（作为遮罩）
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 4
            lineLayer.contentsScale = UIScreen.main.scale // 优化：遮罩也需要适配分辨率
            
            // 3. 将线条图层设为图片图层的遮罩
            imageLayer.mask = lineLayer
            
            // 4. 添加图片图层到父视图
            circleView.layer.addSublayer(imageLayer)
        }
        
        
     //偶数对称数量的时候用这个
         // 计算每条线的角度间隔
//        let angleStep = (2 * Double.pi) / Double(numberOfCarts)

//         // 循环绘制八条线
//        for i in 0..<numberOfCarts {
//             let angle = CGFloat(i) * angleStep
//
//             // 计算线的起点和终点
//             let startX = bounds.midX + (min(bounds.width, bounds.height) / 2) * cos(angle)
//             let startY = bounds.midY + (min(bounds.width, bounds.height) / 2) * sin(angle)
//             let endX = bounds.midX - (min(bounds.width, bounds.height) / 2) * cos(angle)
//             let endY = bounds.midY - (min(bounds.width, bounds.height) / 2) * sin(angle)
//
//             // 创建线的 UIBezierPath
//             let linePath = UIBezierPath()
//             linePath.move(to: CGPoint(x: startX, y: startY))
//             linePath.addLine(to: CGPoint(x: endX, y: endY))
//
//            // 1. 创建图片图层（承载图片）
//            let imageLayer = CALayer()
//            imageLayer.contents = UIImage(named: "线1")?.cgImage
//            imageLayer.frame = circleView.bounds // 图片图层大小与父视图一致
//
//            // 2. 创建线条图层（作为遮罩）
//            let lineLayer = CAShapeLayer()
//            lineLayer.path = linePath.cgPath
//            lineLayer.strokeColor = UIColor.black.cgColor // 遮罩颜色不影响，只要不透明即可
//            lineLayer.fillColor = UIColor.clear.cgColor
//            lineLayer.lineWidth = 4
//
//            // 3. 将线条图层设为图片图层的遮罩（图片只显示在线条区域）
//            imageLayer.mask = lineLayer
//
//            // 4. 添加图片图层到父视图
//            circleView.layer.addSublayer(imageLayer)
//       
//         }
     }
  @objc  private func startAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        // 设置动画从0度旋转到360度（2 * π弧度）
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float.pi * 2.0
        rotationAnimation.duration = CFTimeInterval(animationDuration)
        rotationAnimation.repeatCount = .infinity
        circleView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        // 为每个轿厢添加反向旋转动画
        for cartView in cartViews {
            let reverseRotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            reverseRotationAnimation.fromValue = 0.0
            reverseRotationAnimation.toValue = -Float.pi * 2.0
            reverseRotationAnimation.duration = CFTimeInterval(animationDuration)
            reverseRotationAnimation.repeatCount = .infinity
            cartView.layer.add(reverseRotationAnimation, forKey: "reverseRotationAnimation")
            
        }
    }
    func stopAnimation() {
          circleView.layer.removeAnimation(forKey: "rotationAnimation")
          for cartView in cartViews {
              cartView.layer.removeAnimation(forKey: "reverseRotationAnimation")
          }
      }
}
