//
//  ImageService.h
//  Pods
//
//  Created by ycs on 17/3/21.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^ResponseHandler)(id responseObject);
typedef void (^CmsSucceedBlock)();
typedef void (^NetworkSuspendBlock)(NSError *error);

/// 图片处理请求
@interface ImageService : AFHTTPSessionManager

@property (nonatomic,strong) NSString *serviceUrl;
@property (nonatomic,strong) NSString *acckey;
@property (nonatomic,copy) ResponseHandler responseHandler;
@property (nonatomic,copy) NetworkSuspendBlock suspendBlock;
@property (nonatomic,copy) CmsSucceedBlock successBlock;

/** Token */
@property (nonatomic,strong) NSString *token;

/**
 *  图片裁剪
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param width 图片裁剪宽度
 *  @param height 图片裁剪高度
 *  @param px 裁剪起点x坐标
 *  @param py 裁剪起点y坐标
 */
-(void)imageCutWithBucket:(NSString *)bucket
                objectKey:(NSString *)objectKey
                    width:(int)width
                   height:(int)height
                   pointX:(int)px
                   pointY:(int)py;
/**
 *  图片格式转换
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)imageFormatWithBucket:(NSString *)bucket
                   objectKey:(NSString *)objectKey
                      format:(NSString *)format;

/**
 *  图片信息查看
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)acquireImageInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey;

/**
 *  图片缩略图
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)imageThumbnailWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                         format:(NSString *)format;

/**
 *  图片多模式
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param opt 模式
 */
-(void)imageViewWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                       opt:(NSString *)opt;


@end
