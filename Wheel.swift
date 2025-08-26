
//
//  FerrisWheelView.swift
//  PiChild
//
//  Created by 唐米 on 2025/8/7.
//

import Foundation
import UIKit
class FerrisWheelView: UIView {
    // 旋转控制
    private var displayLink: CADisplayLink?
    private var rotationAngle: CGFloat = 0 // 当前旋转角度（弧度）
    private var lastUpdateTime: CFTimeInterval = 0 // 上一次更新时间
    
    var currentUserModel :  DeviceModel!
    var bgView = UIView()
    var ferrisWheelViewBlock : ((_ itemModel:FerrisWheelModel) -> Void)?
    var kids:[ChildenModel] = []

    private let wheelRadius: CGFloat = 139 //轮子半径
    private let numberOfCarts = 7
    private let cartSize: CGSize = CGSize(width: 82, height: 78)
    private var circleView = UIImageView()
    private var cartViews: [CarView] = []
    private var animationDuration = 31 //转动一圈的时间
    var models : [FerrisWheelModel] = []{
        didSet{
            let ticketsNum = models.count-1
            
            for index in 0 ..< numberOfCarts {
                let carView = cartViews[index]
                carView.currentUserModel = self.currentUserModel
                carView.kids = self.kids
              
                if index <= ticketsNum {
                    let model = models[index]
                    model.canTap = true
                    model.animalIcon = "pic\(index)"
                    carView.ferrisModel = models[index]
                    carView.isUserInteractionEnabled = true
                }else{
                    let model = FerrisWheelModel()
                    model.animalIcon = "pic00"
                    model.canTap = false
                    carView.ferrisModel = model
                    carView.isUserInteractionEnabled = false
                }
                
               
                cartViews[index] = carView
               
            }
          
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        setupFerrisWheel()
        addCarts()
        startAnimation()
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupFerrisWheel() {
        self.addSubview(bgView)
        
        
        circleView = UIImageView(frame: CGRectMake(25, 50, 278, 278))
        circleView.centerX = self.center.x
        circleView.isUserInteractionEnabled = true
        circleView.clipsToBounds = false
        circleView.image = UIImage(named: "mtl_cirle")
        circleView.backgroundColor = .clear
        self.addSubview(circleView)
       
        let treeView = UIImageView(image: UIImage(named: "mtl_tree"))
        treeView.frame = CGRect(x: circleView.Jh_centerX, y: circleView.Jh_centerY, width: 144, height: 253)
        treeView.centerX = circleView.Jh_centerX;
        self.addSubview(treeView)
        self.insertSubview(treeView, at: 0)
        let centerView = UIImageView(image: UIImage(named: "mtl_center"))
        self.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.center.equalTo(circleView.snp.center)
            make.width.height.equalTo(72)
        }
        setup()
    }
    
    private func addCarts() {
        
        let center = CGPoint(x: circleView.bounds.midX, y: circleView.bounds.midY)
        let angleStep = (2 * .pi) / CGFloat(numberOfCarts)
        
        for i in 0..<numberOfCarts {
            let angle = CGFloat(i) * angleStep
            let cartX = center.x + wheelRadius * cos(angle) - cartSize.width / 2
            let cartY = center.y + wheelRadius * sin(angle) - cartSize.height / 2

            let cartView = CarView()
            cartView.frame = CGRect(x: cartX, y: cartY, width: cartSize.width, height: cartSize.height)
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
         circleLayer.strokeColor = UIColor.clear.cgColor
         circleLayer.fillColor = UIColor.clear.cgColor
         circleLayer.lineWidth = 11
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
            imageLayer.contents = UIImage(named: "mtl_line")?.cgImage
            imageLayer.contentsScale = UIScreen.main.scale // 优化：适配屏幕分辨率，避免模糊
            imageLayer.frame = circleView.bounds
            
            // 2. 创建线条图层（作为遮罩）
            let lineLayer = CAShapeLayer()
            lineLayer.path = linePath.cgPath
            lineLayer.strokeColor = UIColor.black.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 11
            lineLayer.contentsScale = UIScreen.main.scale // 优化：遮罩也需要适配分辨率
            
            // 3. 将线条图层设为图片图层的遮罩
            imageLayer.mask = lineLayer
            
            // 4. 添加图片图层到父视图
            circleView.layer.addSublayer(imageLayer)
        }
    
     }
  @objc  func startAnimation() {
      stopAnimation() // 先停止已有动画
            
            lastUpdateTime = CACurrentMediaTime()
            displayLink = CADisplayLink(target: self, selector: #selector(updateRotation))
            displayLink?.add(to: .main, forMode: .common)
      
    }
    // 停止旋转动画
        func stopAnimation() {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        // 实时更新旋转角度
        @objc private func updateRotation() {
            guard let displayLink = displayLink else { return }
            let currentTime = CACurrentMediaTime()
            let deltaTime = currentTime - lastUpdateTime // 时间增量（秒）
            lastUpdateTime = currentTime
            
            // 计算角度增量（一周2π弧度，在animationDuration时间内完成）
            let angleIncrement = 2 * CGFloat.pi * CGFloat(deltaTime) / CGFloat(animationDuration)
            rotationAngle += angleIncrement
            
            // 更新circleView旋转（正向旋转）
            
                circleView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            
            
            // 更新所有cartView反向旋转（抵消circleView的旋转，保持正向）
            for cartView in cartViews {
                // 反向旋转相同角度（-rotationAngle）
                cartView.transform = CGAffineTransform(rotationAngle: -rotationAngle)
            }
        }
    
  
}



class CarView : UIView {
    var currentUserModel :  DeviceModel!
    var kids:[ChildenModel] = []
    var chooseItemBlock : ((_ itemModel:FerrisWheelModel) -> Void)?
    private var bgBtn : UIButton!
    private var layerView : UIView!
    private var animalIcon : UIImageView!
    private var phtotoTypeIcon : UIImageView!
    private  var dayLb : UILabel!
    private var videoTypeIcon : UIImageView!
    private var birthdayView : UIImageView!
    var ferrisModel = FerrisWheelModel() {
        didSet {
            animalIcon.image = UIImage(named: ferrisModel.animalIcon)
         
            if ferrisModel.canTap {
            
                bgBtn.isHidden = false
                layerView.isHidden = false
                let dateStr = ferrisModel.generateDate
                // 使用工具方法判断
                let targetMonthDay = getMonthDay(from: dateStr)
                guard let targetMonthDay = targetMonthDay else {
                    // 处理dateStr格式错误的情况
                    print("dateStr格式不正确: \(dateStr)")
                    let isBirthday = false
                    // 后续处理...
                    return
                }

                let isBirthday = kids.contains { kid in
                    guard let kidMonthDay = getMonthDay(from: kid.birthday) else {
                        // 处理kid.birthday格式错误的情况
                        print("生日格式不正确: \(kid.birthday ?? "")")
                        return false
                    }
                    return kidMonthDay == targetMonthDay
                }

                if isBirthday == true {
                    animalIcon.image = UIImage(named: "birthday_icon")
                    birthdayView.isHidden = false
                    
                }
                
                let dates = dateStr.components(separatedBy: "-")
               
                let weekDay = dayOfWeek(for: dateStr, dateFormat: "yyyy-MM-dd")
                let day = "\(dates[1])/\(dates[2]) \(weekDay ?? "")"
                dayLb.text = day
                let mediaList = ferrisModel.mediaList
                if mediaList.count == 1 {
                    layerView.width = 82
                    let media = mediaList.first
                    if media?.mediaType == 0 {
                        phtotoTypeIcon.isHidden = true
                        videoTypeIcon.isHidden = false
                        videoTypeIcon.snp.makeConstraints { make in
                            make.left.equalTo(dayLb.snp.right).offset(3)
                            make.width.equalTo(14)
                            make.height.equalTo(12)
                            make.centerY.equalToSuperview()
                        }
                    }else{
                        videoTypeIcon.isHidden = true
                        phtotoTypeIcon.isHidden = false
                        phtotoTypeIcon.snp.makeConstraints { make in
                            make.left.equalTo(dayLb.snp.right).offset(3)
                            make.width.equalTo(14)
                            make.height.equalTo(12)
                            make.centerY.equalToSuperview()
                        }
                    }
                }
                if mediaList.count == 2 {
                    layerView.width = 96
                    phtotoTypeIcon.snp.makeConstraints { make in
                        make.left.equalTo(dayLb.snp.right).offset(3)
                        make.width.equalTo(14)
                        make.height.equalTo(12)
                        make.centerY.equalToSuperview()
                    }
                    videoTypeIcon.snp.makeConstraints { make in
                        make.left.equalTo(phtotoTypeIcon.snp.right).offset(3)
                        make.width.equalTo(14)
                        make.height.equalTo(12)
                        make.centerY.equalToSuperview()
                    }
                }
                
            }else{
                bgBtn.isHidden = true
                layerView.isHidden = true
            }
         
        }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        animalIcon = UIImageView(image: UIImage(named: "pic00"))
        self.addSubview(animalIcon)
        animalIcon.frame = CGRect(x: 11, y: 0, width: 60, height: 60)
        
        
        layerView = UIView()
        layerView.isHidden = true
        layerView.layer.cornerRadius = 9
        layerView.clipsToBounds = true
        layerView.backgroundColor = UIColor.hex("#F0FEFF")
        layerView.frame = CGRect(x: 0, y: 61, width: 96, height: 18)
        // fillCode
        let bgLayer1 = CALayer()
        bgLayer1.frame = layerView.bounds
        bgLayer1.backgroundColor = UIColor(red: 0.94, green: 1, blue: 1, alpha: 1).cgColor
        layerView.layer.addSublayer(bgLayer1)
        // shadowCode
        layerView.layer.shadowColor = UIColor(red: 0.33, green: 0.52, blue: 0.64, alpha: 1).cgColor
        layerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        layerView.layer.shadowOpacity = 1
        layerView.layer.shadowRadius = 2
        self.addSubview(layerView)
        
         dayLb = CreateView.newLabel(withFrame: .zero, title: "", color: UIColor.hex("#065090"), font: 11, alignment: 0)
        dayLb.adjustsFontSizeToFitWidth = true
        layerView.addSubview(dayLb)
        
        dayLb.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
        }
        phtotoTypeIcon = UIImageView(image: UIImage(named: "mtl_pic"))
        layerView.addSubview(phtotoTypeIcon)
        
         videoTypeIcon = UIImageView(image: UIImage(named: "mtl_video"))
        layerView.addSubview(videoTypeIcon)
      
        
        birthdayView = UIImageView(image: UIImage(named: "pop_title_icon"))
        birthdayView.isHidden = true
        self.addSubview(birthdayView)
        let contentLb = CreateView.newLabel(withFrame: .zero, title: "宝贝生日快乐!", color: UIColor.hex("#494A4A"), font: 11, alignment: 1)
        birthdayView.addSubview(contentLb)
        contentLb.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalToSuperview()
        }
        birthdayView.frame = CGRectMake(0, -43, 89, 34)
         bgBtn = UIButton()
        bgBtn.isHidden = true
        bgBtn.hx_setEnlargeEdge(withTop: 30, right: 30, bottom: 30, left: 30)
        bgBtn.addTarget(self, action: #selector(chooseItem), for: .touchUpInside)
        self.addSubview(bgBtn)
        bgBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    
        
    }
    
    @objc func chooseItem() {
            let isShare = self.currentUserModel.userId == LoginSingleton.shared.getUserModel().id_count ? false : true
            let ferris = ferrisModel.mj_JSONString()
            let ferrisDic = ["mtlDetail":ferris!,"isShare":isShare] as [String : Any]
            let dic = NSMutableDictionary(dictionary: ferrisDic as [AnyHashable : Any])
            
            FlutterBoostDelegateVC.nativePushRoute(withPageName: "ticketDetail", arguments: dic)
    }

   
     required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


