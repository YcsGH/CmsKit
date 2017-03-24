//
//  CmsClient.h
//  CmsKit
//
//  Created by ycs on 17/2/15.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ResponseHandler)(id responseObject);
typedef void (^ProgressHandler)(NSProgress *progress);
typedef void (^CmsSucceedBlock)();
typedef void (^NetworkSuspendBlock)(NSError *error);

@interface CmsClient : NSObject

#pragma mark ====== Init ======

/** cms 指定的初始化方法 */
-(instancetype)initWithBaseURL:(NSString *)baseUrl
                        accKey:(NSString *)acckey
                     secretKey:(NSString *)secretKey;

#pragma mark ====== 上传 & 下载 ======

/**
 *  上传文件入口函数(断点上传)
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param filePath 文件所在路径
 *  @param metadata 文件信息
 */
-(void)putObjectViaRBU:(NSString *)bucketName
             objectKey:(NSString *)objectKey
              filePath:(NSString *)filePath
        objectMetadata:(NSDictionary *)metadata;

/**
 *  上传文件函数(普通上传)
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param filePath 文件所在路径
 *  @param metadata 文件元数据,格式为 @{@"name":@"文件名"}
 */
-(void)simpleUploadWithBucket:(NSString *)bucket
                          objectKey:(NSString *)objectKey
                           filePath:(NSString *)filePath
                     objectMetadata:(NSDictionary *)metadata;

/**
 *  文件删除
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)simpleDeleteWithBucket:(NSString *)bucket
                    objectKey:(NSString *)objectKey;

/**
 *  文件下载
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param savepath 下载文件保存路径(默认是沙盒的Caches/Download目录)
 */
-(void)downloadObjectWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                       savePath:(NSString *)savepath;

/**
 *  图片下载
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)showImageWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey;

/**
 *  文件搜索
 *  @param bucket bucket
 *  @param pagesize 每页的数目
 *  @param pagenum 请求页数
 *  @param metadata 文件元数据,格式为 @{@"name":@"文件名"}
 */
-(void)searchObjectsWithBucket:(NSString *)bucket
                      pageSize:(int)pagesize
                    pageNumber:(int)pagenum
                objectMetadata:(NSDictionary *)metadata;

#pragma mark ====== 视频处理 ======

/**
 *  查看视频信息
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)acquireMediaInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey;

/**
 *  视频处理
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param fops 操作参数
 *  @param notifyUrl 同步地址
 */
-(void)pfopMediaWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                      fops:(NSString *)fops
                 notifyUrl:(NSString *)notifyUrl;

#pragma mark ====== 图片处理 ======

/**
 *  图片裁剪
 *  @param bucket bucket
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
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)imageFormatWithBucket:(NSString *)bucket
                   objectKey:(NSString *)objectKey
                      format:(NSString *)format;

/**
 *  图片信息查看
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)acquireImageInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey;

/**
 *  图片缩略图
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)imageThumbnailWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                         format:(NSString *)format;

/**
 *  图片多模式处理
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param opt 模式
 */
-(void)imageViewWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                    opt:(NSString *)opt;

#pragma mark ====== 其他参数 ======

/** 分块大小:1024x1024,即1M */
@property (nonatomic,assign,readonly) int partsize;
@property (nonatomic,strong,readonly) NSString *acckey;
@property (nonatomic,strong,readonly) NSString *secretKey;

#pragma mark ====== 回调函数 ======

/** 进度回调 */
@property (nonatomic,copy) ProgressHandler progressAdapter;

/** 网络请求成功,主要是对HttpResponse的处理 */
@property (nonatomic,copy) ResponseHandler responseHandler;

/** 网络请求失败回调处理 */
@property (nonatomic,copy) NetworkSuspendBlock suspendBlock;

/** 当前文件操作成功的回调 */
@property (nonatomic,copy) CmsSucceedBlock successBlock;

#pragma mark ====== 断开当前Socket连接 ======

//断开网络请求
-(void)invalidateAndCancel;

#pragma mark ====== 清理缓存数据 ======

/** 
  * 不再需要记录某文件的上传状态时(断点上传),
  * 可清除该文件保存在NSUserDefaults中的信息
  * @param objectId 上传对象的ID
*/
-(void)cleanUserDefaultsKeyWithObjectId:(NSString *)objectId;


@end
