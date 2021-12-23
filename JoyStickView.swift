//
//  JoyStickView.swift
//  VirtualJoystick-Swift
//
//  Created by 中电兴发 on 2021/12/22.
//

import UIKit
protocol JoyStickViewDelegate :NSObjectProtocol{
    func rudderView(joyStickView:JoyStickView, didUpdateDragLocation dragPoint:CGPoint);
}


class JoyStickView: UIView {
    var dragImg = UIImageView()
    var curCenterPoint : CGPoint!
    weak var delegate : JoyStickViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let center = self.frame.size.width / 2.0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 62
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.03)
        dragImg = UIImageView.init(image: UIImage.init(named: "video_drap"))
        dragImg.frame = CGRect.init(x: 0, y: 0, width: 62, height: 62)
        dragImg.center = CGPoint.init(x: center, y: center)
        self.addSubview(dragImg)
        curCenterPoint = CGPoint.init(x: center, y: center)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func updateDragViewLocation(toPoint:CGPoint) {
        let size = self.frame.size;
        var updateX  = toPoint.x - curCenterPoint.x
        var updateY = toPoint.y - curCenterPoint.y
        let largestR = (size.width - dragImg.frame.size.width) * 0.5
        let touchR = sqrt(pow(updateX, 2) + pow(updateY, 2))
        if touchR > largestR {
            updateX = updateX / touchR * largestR;
            updateY = updateY / touchR * largestR;
        }
        dragImg.center = CGPoint.init(x: updateX + curCenterPoint.x, y: updateY + curCenterPoint.y)
    }
    
    func feekbackDragPoint(toPoint:CGPoint) {
        let updatePoint = CGPoint.init(x:toPoint.x - curCenterPoint.x, y: toPoint.y - curCenterPoint.y)
        if self.delegate != nil{
            self.delegate?.rudderView(joyStickView: self, didUpdateDragLocation: updatePoint)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let curPoint = touches.first!.location(in: self)
        self.updateDragViewLocation(toPoint: curPoint)
        self.feekbackDragPoint(toPoint: curPoint)
    
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let curPoint = touches.first!.location(in: self)
        self.updateDragViewLocation(toPoint: curPoint)
        self.feekbackDragPoint(toPoint: curPoint)
    
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        let curPoint = touches.first!.location(in: self)
        self.updateDragViewLocation(toPoint: curCenterPoint)
        self.feekbackDragPoint(toPoint: curPoint)
    
    }
    

}
