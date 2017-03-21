//
//  RBUClient.h
//  RBUKit
//
//  Created by ycs on 17/2/15.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "RBUObject.h"

typedef void (^ResponseHandler)(id responseObject);
typedef void (^ProgressHandler)(NSProgress *progress);
typedef void (^NextUploadBlock)();
typedef void (^NetworkSuspendBlock)(NSError *error);

@interface RBUClient : AFHTTPSessionManager

/** 文件上传入口 */
-(void)uploadObject:(RBUObject *)rbuObject;

#pragma mark ====== 必填参数 ======
@property (nonatomic,strong) NSString *serviceUrl;//基地址

#pragma mark ====== 选填参数 ======

/** 分块大小,默认是1024x1024,即1M */
@property (nonatomic,assign) int partsize;

/** Token */
@property (nonatomic,strong) NSString *token;

/** 超时时间设置,默认是40秒 */
@property (nonatomic,assign) int timeout;

#pragma mark ====== 回调函数 ======

/** 进度回调 */
@property (nonatomic,copy) ProgressHandler progressAdapter;

/** 网络请求成功回调处理 */
@property (nonatomic,copy) ResponseHandler responseHandler;

/** 网络请求失败回调处理 */
@property (nonatomic,copy) NetworkSuspendBlock suspendBlock;

/** 当前文件上传成功的回调 */
@property (nonatomic,copy) NextUploadBlock nextUploadBlock;




@end
