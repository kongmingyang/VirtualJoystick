//
//  JoyStickView.m
//  VirtualJoystick
//
//  Created by 中电兴发 on 2021/12/22.
//

#import "JoyStickView.h"
#import "UIView+Extension.h"
@interface JoyStickView()


@property (nonatomic, weak) UIImageView *dragImage;
@property(nonatomic,assign)CGPoint     curCenterPoint;
@end
@implementation JoyStickView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat center = self.frame.size.width/2.0;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 62;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.03];
        UIImageView *dragImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_drap"]];
        dragImg.frame = CGRectMake(0, 0, 62, 62);
        dragImg.center = CGPointMake(center, center);
        [self addSubview:dragImg];
        self.dragImage = dragImg;
        self.curCenterPoint = CGPointMake(center, center);
    }
    return self;
}
#pragma mark - Feature

- (void)updateDragViewLocation:(CGPoint)toPoint {
    
    
    // 圆形中
    CGFloat updateX = toPoint.x - self.curCenterPoint.x;
    CGFloat updateY = toPoint.y - self.curCenterPoint.y;
    CGFloat largestR = (self.width - self.dragImage.width) * 0.5;
    double touchR = sqrt(pow(updateX, 2) + pow(updateY, 2));
    if (touchR > largestR) {
        updateX = updateX / touchR * largestR;
        updateY = updateY / touchR * largestR;
    }
    self.dragImage.center = CGPointMake(updateX + self.curCenterPoint.x, updateY + self.curCenterPoint.y);
}

- (void)feekbackDragPoint:(CGPoint)toPoint {
    
    CGPoint updatePoint = CGPointMake(toPoint.x - self.curCenterPoint.x, toPoint.y - self.curCenterPoint.y);
    if ([self.delegate respondsToSelector:@selector(rudderView:didUpdateDragLocation:)]) {
        [self.delegate rudderView:self didUpdateDragLocation:updatePoint];
    }
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //
    CGPoint curPoint = [[touches anyObject] locationInView:self];
    NSLog(@"[%@ %@]\n(x:%f, y:%f)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), curPoint.x, curPoint.y);
    
    [self updateDragViewLocation:curPoint];
    [self feekbackDragPoint:curPoint];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //
    CGPoint curPoint = [[touches anyObject] locationInView:self];
    NSLog(@"[%@ %@]\n(x:%f, y:%f)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), curPoint.x, curPoint.y);
    
    [self updateDragViewLocation:curPoint];
    [self feekbackDragPoint:curPoint];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //
    CGPoint curPoint = [[touches anyObject] locationInView:self];
    NSLog(@"[%@ %@]\n(x:%f, y:%f)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), curPoint.x, curPoint.y);
    NSLog(@"center point: (x:%f, y:%f)", self.center.x, self.center.y);
    
    [self updateDragViewLocation:self.curCenterPoint];
    [self feekbackDragPoint:curPoint];
}

@end
