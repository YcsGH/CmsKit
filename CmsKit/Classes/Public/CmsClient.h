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
typedef void (^NextUploadBlock)();
typedef void (^NetworkSuspendBlock)(NSError *error);

/** cms上传工具类 */
@interface CmsClient : NSObject

/** cms client 指定的初始化方法 */
-(instancetype)initWithBaseURL:(NSString *)baseUrl
                        accKey:(NSString *)acckey
                     secretKey:(NSString *)secretKey;

/**
 *  上传文件入口函数
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param filePath 文件所在路径
 *  @param imageFlag 是否为图片
 *  @param metadata 文件信息
 *  metadata 最终会放在http header中
 */
-(void)putObjectViaRBU:(NSString *)bucketName
             objectKey:(NSString *)objectKey
              filePath:(NSString *)filePath
             imageFlag:(BOOL)imageFlag
        objectMetadata:(NSDictionary *)metadata;

#pragma mark ====== 可能需要设置的参数 ======

/** Token */
@property (nonatomic,strong) NSString *token;

#pragma mark ====== 其他参数 ======

/** 分块大小:1024x1024,即1M */
@property (nonatomic,assign,readonly) int partsize;
@property (nonatomic,strong,readonly) NSString *acckey;
@property (nonatomic,strong,readonly) NSString *secretKey;

#pragma mark ====== 回调函数 ======

/** 进度回调 */
@property (nonatomic,copy) ProgressHandler progressAdapter;

/** 网络请求成功回调处理 */
@property (nonatomic,copy) ResponseHandler responseHandler;

/** 网络请求失败回调处理 */
@property (nonatomic,copy) NetworkSuspendBlock suspendBlock;

/** 当前文件上传成功的回调 */
@property (nonatomic,copy) NextUploadBlock nextUploadBlock;

#pragma mark ====== 断开当前Socket连接 ======
-(void)invalidateAndCancel;

#pragma mark ====== 清理缓存数据 ======

/** 不再需要记录某文件的上传状态时,请清除该文件保存在NSUserDefaults中的信息 */
-(void)cleanUserDefaultsKeyWithObjectId:(NSString *)objectId;


@end
