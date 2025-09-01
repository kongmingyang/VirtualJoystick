/**
 *  UIImage+LL.m
 */
#import "UIImage+LL.h"
//#import "LocalizedTool.h"
@implementation UIImage (LL)

+ (instancetype)waterMarkWithImage:(UIImage *)image andMarkImageName:(NSString *)markName{
    
    UIImage *watermarkImage = [UIImage imageNamed:markName];
    if (!watermarkImage) {
        NSLog(@"水印图片加载失败: %@", markName);
        return image;
    }
    
    // 获取原图尺寸和方向
    CGSize originalSize = image.size;
    BOOL isLandscape = originalSize.width > originalSize.height;
    
    // 根据图片方向设置不同的水印比例
    CGFloat watermarkRatio;
    if (isLandscape) {
        watermarkRatio = 0.04; // 横图水印比例
    } else {
        watermarkRatio = 0.06; // 竖图水印比例
    }
    
    CGFloat targetWidth = originalSize.width * watermarkRatio;
    CGFloat scaleFactor = targetWidth / watermarkImage.size.width;
    CGFloat watermarkWidth = watermarkImage.size.width * scaleFactor;
    CGFloat watermarkHeight = watermarkImage.size.height * scaleFactor;
    
    // 根据方向设置不同的边距
    CGFloat marginX, marginY;
    if (isLandscape) {
        marginX = originalSize.width * 0.02;
        marginY = originalSize.height * 0.02;
    } else {
        marginX = originalSize.width * 0.03;
        marginY = originalSize.height * 0.03;
    }
    
    // 创建图像上下文并绘制水印
    UIGraphicsBeginImageContextWithOptions(originalSize, NO, 0);
    [image drawInRect:CGRectMake(0, 0, originalSize.width, originalSize.height)];
    
    CGRect watermarkRect = CGRectMake(13,
                                     marginY-20,
                                     watermarkWidth,
                                     watermarkHeight);
    
    [watermarkImage drawInRect:watermarkRect blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *watermarkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return watermarkedImage;
}

@end
