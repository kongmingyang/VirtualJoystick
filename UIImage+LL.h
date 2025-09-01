/**
 *  UIImage+LL.h
 */
#import <UIKit/UIKit.h>

@interface UIImage (LL)

///右上角加水印图片
+ (instancetype)waterMarkWithImage:(UIImage *)image andMarkImageName:(NSString *)markName;

@end
