/**
 *  UIImage+LL.m
 */
#import "UIImage+LL.h"
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation UIImage (LL)


//
//+ (instancetype)waterMarkWithImage:(UIImage *)image andMarkImageName:(NSString *)markName{
//    
//    
//    UIImage *watermarkImage = [UIImage imageNamed:markName];
//    if (!watermarkImage) {
//        NSLog(@"水印图片加载失败: %@", markName);
//        return image;
//    }
//    
//    // 获取原图尺寸和方向
//    CGSize originalSize = image.size;
//    BOOL isLandscape = originalSize.width > originalSize.height;
//    
//    // 根据图片方向设置不同的水印比例
//    CGFloat watermarkRatio;
//    if (isLandscape) {
//        watermarkRatio = 0.04; // 横图水印比例
//    } else {
//        watermarkRatio = 0.06; // 竖图水印比例
//    }
//    
//    CGFloat targetWidth = originalSize.width * watermarkRatio;
//    CGFloat scaleFactor = targetWidth / watermarkImage.size.width;
//    CGFloat watermarkWidth = watermarkImage.size.width * scaleFactor;
//    CGFloat watermarkHeight = watermarkImage.size.height * scaleFactor;
//    
//    // 根据方向设置不同的边距
//    CGFloat marginX, marginY;
//    if (isLandscape) {
//        marginX = originalSize.width * 0.02;
//        marginY = originalSize.height * 0.02;
//    } else {
//        marginX = originalSize.width * 0.03;
//        marginY = originalSize.height * 0.03;
//    }
//    // 优化图像分辨率，避免过高分辨率导致图片过大
//       CGFloat targetResolution = 1.0; // 默认分辨率为1.0
//       if (UIScreen.mainScreen.scale > 2.0) {
//           targetResolution = 1.0; // 如果是视网膜屏，降低分辨率
//       }
//    // 创建图像上下文，并设置合适的分辨率
//    CGSize targetSize = CGSizeMake(originalSize.width * targetResolution, originalSize.height * targetResolution);
//    // 创建图像上下文并绘制水印
//    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);
//    [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
//    
//    CGRect watermarkRect = CGRectMake(13,
//                                     marginY-20,
//                                     watermarkWidth,
//                                     watermarkHeight);
//    
//    [watermarkImage drawInRect:watermarkRect blendMode:kCGBlendModeNormal alpha:1.0];
//    
//    UIImage *watermarkedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return watermarkedImage;
//}
+ (instancetype)waterMarkWithImage:(UIImage *)image andMarkImageName:(NSString *)markName {
    // 基础校验：原图/水印图为空直接返回
    if (!image) {
        NSLog(@"原图为空，无法添加水印");
        return nil;
    }
    UIImage *watermarkImage = [self safeLoadWatermarkImage:markName];
    if (!watermarkImage) {
        NSLog(@"水印图片加载失败: %@，返回原图", markName);
        return image;
    }

    // 1. 第一步：计算「安全的绘图尺寸」（核心：避免超大图导致崩溃）
    CGSize safeImageSize = [self calculateSafeImageSize:image.size];
    // 2. 第二步：计算「合理的上下文缩放因子」（平衡质量与内存）
    CGFloat safeScale = [self calculateSafeContextScale:image.size targetSize:safeImageSize];

    // 3. 计算水印尺寸（基于安全尺寸，避免水印过大）
    CGSize watermarkSize = [self calculateWatermarkSizeWithOriginalSize:safeImageSize
                                                           watermarkImage:watermarkImage];
    // 4. 计算水印位置（修正负坐标，确保在图片内）
    CGRect watermarkRect = [self calculateWatermarkRectWithOriginalSize:safeImageSize
                                                           watermarkSize:watermarkSize];

    // 5. 安全创建绘图上下文（用安全尺寸+安全缩放，避免内存溢出）
    UIGraphicsBeginImageContextWithOptions(safeImageSize, NO, safeScale);
    if (!UIGraphicsGetCurrentContext()) {
        NSLog(@"创建绘图上下文失败，返回原图");
        UIGraphicsEndImageContext();
        return image;
    }

    // 6. 绘制原图（用安全尺寸，避免超高清绘制）
    [image drawInRect:CGRectMake(0, 0, safeImageSize.width, safeImageSize.height)];
    // 7. 绘制水印
    [watermarkImage drawInRect:watermarkRect blendMode:kCGBlendModeNormal alpha:1.0];

    // 8. 获取结果图并释放上下文（关键：及时释放内存）
    UIImage *watermarkedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // 9. 最终压缩：按场景控制输出体积（视觉无明显损失）
    watermarkedImage = [self compressImageWithQuality:watermarkedImage quality:0.9];

    return watermarkedImage ?: image;
}

#pragma mark - 私有辅助：安全加载水印图（避免重复解码，减少内存）
+ (UIImage *)safeLoadWatermarkImage:(NSString *)markName {
    // 1. 优先从内存缓存加载（UIImage imageNamed: 会缓存，适合重复使用）
    UIImage *watermark = [UIImage imageNamed:markName];
    if (watermark) return watermark;

    // 2. 缓存未命中时，从磁盘安全加载（避免 imageNamed: 无法加载的情况）
    NSString *path = [[NSBundle mainBundle] pathForResource:markName ofType:nil];
    if (!path) return nil;

    // 3. 用 ImageIO 加载（可控制解码方式，减少内存峰值）
    CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], NULL);
    if (!source) return nil;

    // 4. 配置加载参数：延迟解码（避免立即占用大量内存）
    NSDictionary *options = @{
        (__bridge id)kCGImageSourceShouldCacheImmediately: @NO, // 不立即缓存
        (__bridge id)kCGImageSourceCreateThumbnailFromImageIfAbsent: @YES,
        (__bridge id)kCGImageSourceThumbnailMaxPixelSize: @200 // 水印图最大200px（足够清晰，内存小）
    };
    CGImageRef cgWatermark = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    CFRelease(source); // 释放资源

    if (!cgWatermark) return nil;
    UIImage *result = [UIImage imageWithCGImage:cgWatermark scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(cgWatermark); // 释放 CGImage，避免内存泄漏
    return result;
}

#pragma mark - 私有辅助：计算「安全的图片尺寸」（防止大图片崩溃）
+ (CGSize)calculateSafeImageSize:(CGSize)originalSize {
    // 定义内存安全的「最大像素面积」（根据设备内存调整，默认2000万像素：如 5000×4000）
    const CGFloat maxSafePixelArea = 2000 * 10000; // 2000万像素（主流设备可承受）
    // 计算原图像素面积（size × scale，因为 UIImage.size 是逻辑尺寸）
    CGFloat originalPixelArea = originalSize.width * originalSize.height * [UIScreen mainScreen].scale;

    // 若原图未超安全面积，直接返回原尺寸（保证质量）
    if (originalPixelArea <= maxSafePixelArea) {
        return originalSize;
    }

    // 若原图超安全面积，按比例缩小到安全范围（避免崩溃）
    CGFloat scaleRatio = sqrt(maxSafePixelArea / originalPixelArea); // 等比例缩放因子
    return CGSizeMake(originalSize.width * scaleRatio, originalSize.height * scaleRatio);
}

#pragma mark - 私有辅助：计算「安全的上下文缩放因子」（平衡质量与内存）
+ (CGFloat)calculateSafeContextScale:(CGSize)originalSize targetSize:(CGSize)targetSize {
    // 核心逻辑：根据图片最终尺寸动态调整缩放因子，避免 Retina 屏无意义翻倍
    CGFloat screenScale = [UIScreen mainScreen].scale;
    CGFloat originalPixelWidth = originalSize.width * screenScale;
    CGFloat targetPixelWidth = targetSize.width * screenScale;

    // 1. 小图（目标宽度<1000px）：用屏幕缩放（保证清晰度）
    if (targetPixelWidth < 1000) {
        return screenScale;
    }
    // 2. 中图（1000px≤目标宽度<2000px）：用 2.0 缩放（兼顾清晰度和内存）
    else if (targetPixelWidth < 2000) {
        return 2.0;
    }
    // 3. 大图（目标宽度≥2000px）：用 1.0 缩放（内存优先，视觉无明显损失）
    else {
        return 1.0;
    }
}

#pragma mark - 私有辅助：计算水印尺寸（按原图方向自适应）
+ (CGSize)calculateWatermarkSizeWithOriginalSize:(CGSize)originalSize watermarkImage:(UIImage *)watermarkImage {
    BOOL isLandscape = originalSize.width > originalSize.height;
    // 按方向设置水印比例（横图4%，竖图6%，保证水印大小协调）
    CGFloat watermarkRatio = isLandscape ? 0.04 : 0.06;
    CGFloat targetWatermarkWidth = originalSize.width * watermarkRatio;
    // 按水印图原比例计算高度（避免拉伸）
    CGFloat scaleFactor = targetWatermarkWidth / watermarkImage.size.width;
    return CGSizeMake(
        watermarkImage.size.width * scaleFactor,
        watermarkImage.size.height * scaleFactor
    );
}

#pragma mark - 私有辅助：计算水印位置（避免超出图片边界）
+ (CGRect)calculateWatermarkRectWithOriginalSize:(CGSize)originalSize watermarkSize:(CGSize)watermarkSize {
    BOOL isLandscape = originalSize.width > originalSize.height;
    // 按方向设置边距（横图2%，竖图3%）
    CGFloat marginX = isLandscape ? (originalSize.width * 0.02) : (originalSize.width * 0.03);
    CGFloat marginY = isLandscape ? (originalSize.height * 0.02) : (originalSize.height * 0.03);

    // 修正原代码的负坐标问题（避免水印超出图片顶部）
    CGFloat watermarkX = MAX(13, marginX); // 原代码固定X=13，兼容并取较大值
    CGFloat watermarkY = MAX(marginY - 20, 0); // 最低在顶部（Y=0），不超出图片

    // 二次校验：避免水印右/下边缘超出图片
    watermarkX = MIN(watermarkX, originalSize.width - watermarkSize.width);
    watermarkY = MIN(watermarkY, originalSize.height - watermarkSize.height);

    return CGRectMake(watermarkX, watermarkY, watermarkSize.width, watermarkSize.height);
}

#pragma mark - 私有辅助：按质量压缩图片（控制输出体积）
+ (UIImage *)compressImageWithQuality:(UIImage *)image quality:(CGFloat)quality {
    // 质量范围限制（0.7~0.9：视觉无明显损失，体积减少50%+）
    quality = MAX(0.7, MIN(quality, 0.9));

    // 1. 先尝试 JPEG 压缩（体积小，适合照片）
    NSData *jpegData = UIImageJPEGRepresentation(image, quality);
    if (jpegData) {
        UIImage *compressedImage = [UIImage imageWithData:jpegData];
        // 若压缩后图片正常，返回（避免 JPEG 不支持透明导致的问题）
        if (compressedImage) return compressedImage;
    }

    // 2. JPEG 失败（如图片有透明通道），用 PNG 压缩（质量略低，体积稍大）
    NSData *pngData = UIImagePNGRepresentation(image);
    if (pngData) {
        // PNG 压缩无质量参数，通过缩放进一步控制体积（仅当图片过大时）
        if (pngData.length > 1024 * 1024 * 5) { // 若 PNG 超5MB，进一步缩小
            CGSize scaleSize = CGSizeMake(image.size.width * 0.8, image.size.height * 0.8);
            UIGraphicsBeginImageContextWithOptions(scaleSize, NO, 1.0);
            [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
            UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return scaledImage ?: image;
        }
        return [UIImage imageWithData:pngData] ?: image;
    }

    // 3. 压缩失败，返回原图
    return image;
}

@end

