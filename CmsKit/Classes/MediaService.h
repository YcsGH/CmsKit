//
//  MediaService.h
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

/// 视频处理请求
@interface MediaService : AFHTTPSessionManager

@property (nonatomic,strong) NSString *serviceUrl;
@property (nonatomic,strong) NSString *acckey;
@property (nonatomic,strong) NSString *secretkey;
@property (nonatomic,copy) ResponseHandler responseHandler;
@property (nonatomic,copy) NetworkSuspendBlock suspendBlock;
@property (nonatomic,copy) CmsSucceedBlock successBlock;

/** Token */
@property (nonatomic,strong) NSString *token;

/**
 *  查看视频信息
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)acquireMediaInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey
                        isPrivate:(BOOL)isPrivate;

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
                 notifyUrl:(NSString *)notifyUrl
                 isPrivate:(BOOL)isPrivate;






@end
