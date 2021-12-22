//
//  JoyStickView.h
//  VirtualJoystick
//
//  Created by 中电兴发 on 2021/12/22.
//

#import <UIKit/UIKit.h>
@class JoyStickView;
NS_ASSUME_NONNULL_BEGIN
@protocol JoyStickViewDelegate <NSObject>

- (void)rudderView:(JoyStickView *)rudder didUpdateDragLocation:(CGPoint)dragPoint;

@end
@interface JoyStickView : UIView
@property (nonatomic, weak) id<JoyStickViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
