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
typedef void (^CmsSucceedBlock)();
typedef void (^NetworkSuspendBlock)(NSError *error);

/** 断点下载工具类 */
@interface RBDClient : AFHTTPSessionManager

/** Token */
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *acckey;
@property (nonatomic,strong) NSString *secretkey;

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
 *  @param savepath 下载文件保存路径(默认是沙盒的Caches目录)
 */
-(void)downloadObjectWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                       savePath:(NSString *)savepath;

/**
 *  图片下载
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param savepath 下载文件保存路径(默认是沙盒的Caches目录)
 */
-(void)showImageWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                  savePath:(NSString *)savepath;
/**
 *  文件搜索
 *  @param bucket bucket
 *  @param pagesize 每页的数目
 *  @param pagenum 请求页数
 *  @param metadata 文件元数据,会放在header中
 */
-(void)searchObjectsWithBucket:(NSString *)bucket
                      pageSize:(int)pagesize
                    pageNumber:(int)pagenum
                objectMetadata:(NSDictionary *)metadata;

/** 
 * 下载文件入口函数
 * @param url 下载文件的请求地址
 * @param savePath 文件的保存路径,默认是Caches/Download
 *
 */
-(void)downloadFileWithURL:(NSString *)url savePath:(NSString *)savePath;

@property (nonatomic,strong) NSString *serviceUrl;


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
@property (nonatomic,copy) CmsSucceedBlock nextDownloadBlock;


@end
