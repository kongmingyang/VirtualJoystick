//
//  RealRocker.m
//
//  Created by 阿七 on 2022/6/8.
//

#import "RealRocker.h"
#import "UIView+classify.h"


#define kRadius ([self bounds].size.width * 0.5f)
#define kTrackRadius kRadius * 0.7f    // 控制中心点偏移量

@interface RealRocker ()
{
    CGFloat _x;
    CGFloat _y;
}

@property (strong, nonatomic) UIImageView *handleImageView;

@property (strong, nonatomic)UIImageView *imgV;


@end

@implementation RockerV

@end

@implementation RealRocker

@synthesize direction;

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    self.imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"live_operate_rocker_bg"]];
   self.imgV.size = self.bounds.size;
   [self addSubview:self.imgV];
   self.imgV.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    [self setRockerStyle:RockStyleOpaque];
    
    self.direction = RockDirectionCenter;
    
    if (!_handleImageView) {
        UIImage *handleImage = [UIImage imageNamed:@"live_operate_center"];
        
        _handleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width*0.5f-handleImage.size.width*0.5f,
                                                                         self.bounds.size.height*0.5f-handleImage.size.height*0.5f,
                                                                         self.bounds.size.width*0.3f,
                                                                         self.bounds.size.height*0.3f)];
        _handleImageView.image = handleImage;
        
        [self addSubview:_handleImageView];
    }
    
    _x = 0;
    _y = 0;
    
    [self resetHandle];
}

- (void)setRockerStyle:(RockStyle)style
{
//    NSArray *imageNames = @[@"rockerOpaqueBg",@"rockerTranslucentBg"];
//    self.userInteractionEnabled = YES;
//    self.image = [UIImage imageNamed:@"live_operate_bg"];
//    [self setBackgroundColor:[UIColor colorWithPatternImage:[self scaleToSize:[UIImage imageNamed:@"live_operate_bg"] size:CGSizeMake(105, 105)]]];
//    [self setBackgroundColor:[UIColor colorWithPatternImage:[self scaleToSize:[UIImage imageNamed:@"live_operate_rocker_bg"] size:self.bounds.size]]];

}

-(void)resetPostion{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.imgV.size = self.bounds.size;
        self.imgV.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        self.handleImageView.size = CGSizeMake(self.frame.size.width*0.3, self.frame.size.height*0.3);
        self.handleImageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    });
   

}
-(void)setIconName:(NSString *)iconName{
    [self.imgV setImage:[UIImage imageNamed:iconName]];
}
- (void)resetHandle
{
    // _handleImageView.image = [UIImage imageNamed:@"setting_btn_yaogan_yellow"];
    
    _x = 0.0;
    _y = 0.0;
    
    CGRect handleImageFrame = [_handleImageView frame];
    handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) * 0.5f,
                                          ([self bounds].size.height - [_handleImageView bounds].size.height) * 0.5f);
    [_handleImageView setFrame:handleImageFrame];
}

- (void)setHandlePositionWithLocation:(CGPoint)location
{
    _x = location.x - kRadius;
    _y = -(location.y - kRadius);
    
    float r = sqrt(_x * _x + _y * _y);
    
    if (r >= kTrackRadius) {
        
        _x = kTrackRadius * (_x / r);
        _y = kTrackRadius * (_y / r);
        
        location.x = _x + kRadius;
        location.y = -_y + kRadius;
        
        [self rockerValueChanged];
    }
    
    CGRect handleImageFrame = [_handleImageView frame];
    handleImageFrame.origin = CGPointMake(location.x - ([_handleImageView bounds].size.width * 0.5f),
                                          location.y - ([_handleImageView bounds].size.width * 0.5f));
    [_handleImageView setFrame:handleImageFrame];
    
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0,0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    //返回新的改变大小后的图片
    return scaledImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _handleImageView.image = [UIImage imageNamed:@"live_operate_center"];
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    [self setHandlePositionWithLocation:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    [self setHandlePositionWithLocation:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetHandle];
    
    [self rockerValueChanged];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetHandle];
    
    [self rockerValueChanged];
}

- (void)rockerValueChanged
{
    NSInteger rockerDirection = -1;
    // 根据坐标计算夹角
    float arc = atan2f(_y,_x);
    
//    [MBProgressHUD showMessage:[NSString stringWithFormat:@"x = %f y = %f",_x,_y]];
//    [MBProgressHUD showMessage:[NSString stringWithFormat:@"夹角 = %f",arc]];
    
    if (_x == 0 && _y == 0) {
        rockerDirection = RockDirectionCenter;

    }else if (arc < (1.0f/8.0f) *M_PI && arc > -(1.0f/8.0f) *M_PI) {
        rockerDirection = RockDirectionRight;
    }else if (arc < -(1.0f/8.0f) * M_PI && arc > -(3.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionRightAndDown;
    }else if (arc < -(3.0f/8.0f) * M_PI && arc > -(5.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionDown;
    }else if (arc < -(5.0f/8.0f) * M_PI && arc > -(7.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionLeftAndDown;
    }else if (arc < -(7.0f/8.0f) * M_PI || arc > (7.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionLeft;
    }else if (arc < (7.0f/8.0f) * M_PI && arc > (5.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionLeftAndUp;
    }else if (arc < (5.0f/8.0f) * M_PI && arc > (3.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionUp;
    }else if (arc < (3.0f/8.0f) * M_PI && arc > (1.0f/8.0f) * M_PI){
        rockerDirection = RockDirectionRightAndUp;
    }

    
    
    if (-1 != rockerDirection && rockerDirection != self.direction) {
        self.direction = rockerDirection;
        NSLog(@"方向 = %ld",self.direction);
//        [MBProgressHUD showMessage:[NSString stringWithFormat:@"方向 = %ld",self.direction]];
        if ([self.delegate respondsToSelector:@selector(rockerDidChangeDirection:)])
        {
            [self.delegate rockerDidChangeDirection:self];
        }
    }
}

    
    
//    if ((arc > (3.0f/4.0f)*M_PI &&  arc < M_PI) || (arc < -(3.0f/4.0f)*M_PI &&  arc > -M_PI)) {
//        rockerDirection = RockDirectionLeft;
//    }else if (arc > (1.0f/4.0f)*M_PI &&  arc < (3.0f/4.0f)*M_PI) {
//        rockerDirection = RockDirectionUp;
//    }else if ((arc > 0 &&  arc < (1.0f/4.0f)*M_PI) || (arc < 0 &&  arc > -(1.0f/4.0f)*M_PI)) {
//        rockerDirection = RockDirectionRight;
//    }else if (arc > -(3.0f/4.0f)*M_PI &&  arc < -(1.0f/4.0f)*M_PI) {
//        rockerDirection = RockDirectionDown;
//    }else if (0 == _x && 0 == _y)
//    {
//        rockerDirection = RockDirectionCenter;
//    }
//
//    if (-1 != rockerDirection && rockerDirection != self.direction) {
//        self.direction = rockerDirection;
//
//        if ([self.delegate respondsToSelector:@selector(rockerDidChangeDirection:)])
//        {
//            [self.delegate rockerDidChangeDirection:self];
//        }
//    }
//}

@end
