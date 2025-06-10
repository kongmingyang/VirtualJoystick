@objc protocol DYDirectionProtocol {

    /*
     //这里旋转的是弧度
     colorDirImgView.transform = CGAffineTransform(rotationAngle: angleRadians)
     // 将弧度转换为度数
     let angleDegrees = angleRadians * 180 / .pi
     */
    @objc optional func panBegan()
    @objc optional func panEnded()
    func panChanged(angleDegrees:CGFloat)
    
}
//extension DYDirectionProtocol {
//    func panBegan() {}
//    func panEnded() {}
//}

class DYDirectionView: UIView {
    
    weak var delegate: DYDirectionProtocol?
    //添加手势拖拽的view
    let draggableView = UIView()
    //是否有操作的权限
    var isHaveRight:Bool = true
    //方向背景图
    lazy var rollImgView:UIImageView = {
        let v = UIImageView.init()
        v.image = kImage("icon_dir_back_n")
        return v
    }()
    
    //外圈的箭头图片
    lazy var colorDirImgView:UIImageView = {
        let v = UIImageView.init()
        v.image = kImage("icon_dir_color_dir")
        v.isHidden = true
        return v
    }()
    
    //中心的图标
    lazy var pickImgV:UIImageView = {
        let v = UIImageView.init()
        v.image = kImage("icon_dir_center")
        return v
    }()

    let boundaryRadius: CGFloat = 38 // 大圆的半径
    let draggableRadius: CGFloat = 19 // 小圆的半径
    var boundaryCenter = CGPoint(x: 0, y: 0) // 大圆的中心
    
    
    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 在这里添加初始化代码，例如设置背景颜色、添加子视图等
        self.backgroundColor = .clear
        body()
        initVar()
    }
    
    // 初始化方法（从编码中创建视图）
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // 在这里添加初始化代码，例如设置背景颜色、添加子视图等
    }
    
    func initVar() {
        colorDirImgView.isHidden = true
        boundaryCenter = rollImgView.center
    }
    
    func body() {
        
        //背景图片
        self.addSubview(rollImgView)
        rollImgView.frame = CGRect(x: 36, y: kScreenHeight - 252, width: boundaryRadius * 2, height: boundaryRadius * 2)
        rollImgView.layer.cornerRadius = boundaryRadius

        //中心图标
        self.addSubview(pickImgV)
        pickImgV.frame = CGRect(x: 0, y: 0, width: draggableRadius * 2, height: draggableRadius * 2)
        pickImgV.center = rollImgView.center
        pickImgV.layer.cornerRadius = draggableRadius
        pickImgV.layer.masksToBounds = true
        pickImgV.contentMode = .center
        
        //背景图片
        self.addSubview(colorDirImgView)
        colorDirImgView.frame = CGRect(x: 0, y: 0 , width: 135, height: 135)
//        colorDirImgView.layer.cornerRadius = boundaryRadius
        colorDirImgView.center = rollImgView.center

        // 设置可拖动视图
        draggableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth+300, height: kScreenHeight + 200)
        draggableView.center = rollImgView.center
        self.addSubview(draggableView)
        draggableView.isUserInteractionEnabled = true // 开启用户交互

        
        // 添加 UIPanGestureRecognizer 到可拖动视图
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        draggableView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 获取拖动的偏移量
        let translation = gesture.translation(in: self)
        // 移动视图到新的位置
        if let viewToMove = gesture.view {
            viewToMove.center = CGPoint(x: viewToMove.center.x + translation.x,
                                        y: viewToMove.center.y + translation.y)
            // 限制在边界圆内
            let constrainedCenter = constrainPointToCircle(point: viewToMove.center, center: boundaryCenter, radius: boundaryRadius - draggableRadius)
            pickImgV.center = constrainedCenter
        }
                
        // 重置偏移量
        gesture.setTranslation(.zero, in: self)
        // 打印拖动过程中的状态
        switch gesture.state {
        case .began:
            print("Pan began")
//            rollImgView.image = kImage("icon_dir_back_s")
            colorDirImgView.isHidden = false
            colorDirImgView.isHidden = true
            self.delegate?.panBegan?()
            if isHaveRight == false {
                DispatchQueue.main.async {
                    [weak self] in
                    // 在这里执行需要在主线程上执行的任务
                    MBProgressHUD.showMessage("没有操作权限")
                }
                return
            }
            
        case .changed:
            print("Pan changed")
            self.managerDrag()
        case .ended:
            print("Pan ended")
            colorDirImgView.transform = CGAffineTransform(rotationAngle: 0.0)
            draggableView.center = rollImgView.center
            pickImgV.center = rollImgView.center
            rollImgView.image = kImage("icon_dir_back_n")
            colorDirImgView.isHidden = true
            self.delegate?.panEnded?()
        case .cancelled, .failed:
            print("Pan cancelled or failed")
            colorDirImgView.transform = CGAffineTransform(rotationAngle: 0.0)
            draggableView.center = rollImgView.center
            pickImgV.center = rollImgView.center
            rollImgView.image = kImage("icon_dir_back_n")
            colorDirImgView.isHidden = true
            self.delegate?.panEnded?()
            print(" ")
        default:
            break
        }
    }
    
    func managerDrag() {
        if isHaveRight == false {
            return
        }
        // 定义两个点的坐标
        let point1 = rollImgView.center
        let point2 = draggableView.center

        // 计算水平和垂直方向的差异
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        print("----dx-----\(dx)")

        // 使用 atan2 函数计算角度（以弧度为单位）
        let angleRadians = atan2(dy, dx)
        //这里旋转的是弧度
        colorDirImgView.transform = CGAffineTransform(rotationAngle: angleRadians)
        // 将弧度转换为度数
        let angleDegrees = angleRadians * 180 / .pi
        print("The angle between the points relative to the horizontal axis is \(angleDegrees) degrees")
        
        self.delegate?.panChanged(angleDegrees: angleDegrees)
    }
    
    // 限制一个点到圆内
    func constrainPointToCircle(point: CGPoint, center: CGPoint, radius: CGFloat) -> CGPoint {
        let vector = CGVector(dx: point.x - center.x, dy: point.y - center.y)
        let distance = sqrt(pow(vector.dx, 2) + pow(vector.dy, 2))
        if distance > radius {
            let scale = radius / distance
            let normalizedVector = CGVector(dx: vector.dx * scale, dy: vector.dy * scale)
            return CGPoint(x: center.x + normalizedVector.dx, y: center.y + normalizedVector.dy)
        } else {
            return point
        }
    }
}
