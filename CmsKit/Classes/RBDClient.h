//
//  RBDClient.h
//  Temproject
//
//  Created by ycs on 17/2/21.
//  Copyright © 2017年 yuancore. All rights reserved.
//  

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void (^ResponseHandler)(id responseObject);
typedef void (^ProgressHandler)(NSProgress *progress);
typedef void (^NextDownloadBlock)();
typedef void (^NetworkSuspendBlock)(NSError *error);

/** 断点下载工具类 */
@interface RBDClient : AFHTTPSessionManager

/** 
 * 下载文件入口函数
 * @param url 下载文件的请求地址
 * @param savePath 文件的保存路径,默认是Caches/Download
 *
 */
-(void)downloadFileWithURL:(NSString *)url savePath:(NSString *)savePath;

/** 暂停下载 */
-(void)pause;

/** 恢复下载 */
-(void)resume;

/** 取消下载任务 */
-(void)invalidateAndCancel;

#pragma mark ====== 回调 ======

/** 进度回调 */
@property (nonatomic,copy) ProgressHandler progressAdapter;

/** 网络请求成功回调处理 */
@property (nonatomic,copy) ResponseHandler responseHandler;

/** 网络请求失败回调处理 */
@property (nonatomic,copy) NetworkSuspendBlock suspendBlock;

/** 当前文件下载成功的回调 */
@property (nonatomic,copy) NextDownloadBlock nextDownloadBlock;


@end
