//
//  PMImageUtil.m
//  path_provider_macos
//

#import "PMImageUtil.h"

@implementation PMImageUtil

+ (NSData *)convertToData:(PMImage *)image formatType:(PMThumbFormatType)type quality:(float)quality {
    
#if TARGET_OS_OSX
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSData *resultData;
    if (type == PMThumbFormatTypePNG) {
        resultData = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    } else {
        resultData = [imageRep representationUsingType:NSBitmapImageFileTypeJPEG properties:@{
            NSImageCompressionFactor: @(quality)
        }];
    }
    
    return resultData;
    
#endif
    
#if TARGET_OS_IOS
    NSData *resultData;
    if (type == PMThumbFormatTypePNG) {
        resultData = UIImagePNGRepresentation(image);
    } else {
        //        resultData = UIImageJPEGRepresentation(image, quality);
        resultData = [PMImageUtil compressOriginalImage:image toMaxDataSizeKBytes:10 * 1000];
    }
    
    return resultData;
    
#endif
}

/**
 * 压缩JPG图片到指定文件大小
 *
 * @param image 目标图片
 * @param size 目标大小（最大值）
 *
 * @return 返回的图片文件
 */
+ (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size{
  NSData *data = UIImageJPEGRepresentation(image, 1.0);
  CGFloat dataKBytes = data.length/1000.0;
  CGFloat maxQuality = 0.9f;
  CGFloat lastData = dataKBytes;
  while (dataKBytes > size && maxQuality > 0.01f) {
    maxQuality = maxQuality - 0.01f;
    data = UIImageJPEGRepresentation(image, maxQuality);
    dataKBytes = data.length / 1000.0;
    if (lastData == dataKBytes) {
      break;
    }else{
      lastData = dataKBytes;
    }
  }
  return data;
}

@end
