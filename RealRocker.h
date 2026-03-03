//
//  RealRocker.h
//
//  Created by 阿七 on 2022/6/8.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RockStyle)
{
    RockStyleOpaque = 0,
    RockStyleTranslucent
};

typedef NS_ENUM(NSInteger, RockDirection)
{
    RockDirectionLeft = 0,
    RockDirectionLeftAndUp = 1,
    RockDirectionUp = 2,
    RockDirectionRightAndUp = 3,
    RockDirectionRight = 4,
    RockDirectionRightAndDown = 5,
    RockDirectionDown = 6,
    RockDirectionLeftAndDown = 7,
    RockDirectionCenter =8,
};

@protocol RealRockerDelegate;

#pragma mark 基类
@interface RockerV : UIView

@property (nonatomic, assign) RockDirection direction;

@property (weak ,nonatomic) id <RealRockerDelegate> delegate;
@property(nonatomic,copy)NSString*iconName;
@end

#pragma mark 皮克方的操纵杆
@interface RealRocker : RockerV

- (void)setRockerStyle:(RockStyle)style;

-(void)resetPostion;

@end

@protocol RealRockerDelegate <NSObject>

@optional
- (void)rockerDidChangeDirection:(RockerV *)rocker;


@end
