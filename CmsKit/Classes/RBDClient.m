//
//  RBDClient.m
//  Temproject
//
//  Created by ycs on 17/2/21.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import "RBDClient.h"
#import "HttpHeader.h"

@interface RBDClient ()
@property (nonatomic,strong) NSURLSessionDownloadTask *ycTask;
@property (nonatomic,strong) NSData *resumeData;//记录上次暂停下载时的记录
@property (nonatomic,strong) NSString *objectIpAddress;
@property (nonatomic,strong) NSString *savedPath;
@end

@implementation RBDClient

- (instancetype)init {
    self = [super init];
    if (self) {
        AFHTTPResponseSerializer *responseSer = [AFHTTPResponseSerializer serializer];
        [responseSer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/plain",@"application/octet-stream", nil]];
        self.requestSerializer.timeoutInterval = 30;
        self.responseSerializer = responseSer;
    }
    return self;
}

-(void)downloadFileWithURL:(NSString *)url savePath:(NSString *)savePath {
    self.objectIpAddress = url;
    if (savePath != nil) {
        self.savedPath = savePath;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    __weak typeof(self) weakSelf = self;
    self.ycTask = [self downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.progressAdapter) {
                self.progressAdapter(downloadProgress);
            }
        });
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (self.savedPath == nil) {
            NSString *destpath = [weakSelf buildSavepathWithUrl:response.suggestedFilename];
            return [NSURL fileURLWithPath:destpath];
        }else{
            return [NSURL fileURLWithPath:self.savedPath];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error == nil) {
            if (self.responseHandler) {
                self.responseHandler(response);
            }
            [self succeedHandleFile];
        }else{ // 被动取消下载任务
            id resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if ([resumeData isKindOfClass:[NSData class]]) {
                self.resumeData = (NSData *)resumeData;
            }
            [self handleResponseError:error];
        }
    }];
    [self.ycTask resume];
}

-(void)resume {
    if (self.resumeData == nil) {
        [self downloadFileWithURL:self.objectIpAddress savePath:self.savedPath];
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.ycTask = [self downloadTaskWithResumeData:self.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
        if (self.progressAdapter) {
            self.progressAdapter(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        if (self.savedPath == nil) {
            NSString *destpath = [weakSelf buildSavepathWithUrl:response.suggestedFilename];
            return [NSURL fileURLWithPath:destpath];
        }else{
            return [NSURL fileURLWithPath:self.savedPath];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error == nil) {
            if (self.responseHandler) {
                self.responseHandler(response);
            }
            [self succeedHandleFile];
        }else{
            id resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if ([resumeData isKindOfClass:[NSData class]]) {
                self.resumeData = (NSData *)resumeData;
            }
            [self handleResponseError:error];
        }

    }];
    [self.ycTask resume];
}

-(void)pause { // 主动暂停下载任务
    __weak typeof(self) weakSelf = self;
    [self.ycTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        weakSelf.ycTask = nil;
    }];
}

#pragma mark ====== 取消本次传输 ======

-(void)invalidateAndCancel {
    [self invalidateSessionCancelingTasks:YES];
}

#pragma mark ====== Helper ======

-(NSString *)buildSavepathWithUrl:(NSString *)uu {
    NSString *fileName = uu;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Download"];
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:cachesDirectory]) {
        [fm createDirectoryAtPath:cachesDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *rett = [cachesDirectory stringByAppendingPathComponent:fileName];
    NSLog(@"file saved path:%@",rett);
    return rett;
}

-(void)moveFileFromSourcePath:(NSString *)sourcePath toDestpath:(NSString *)destpath {
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:destpath]) {
        [fm removeItemAtPath:destpath error:&error];
    }
    [fm moveItemAtPath:sourcePath toPath:destpath error:&error];
    if (error != nil) {
        NSLog(@"your saved path occurs error:%@",error.localizedDescription);
    }
}


#pragma mark ====== Download ======

/**
 *  文件删除
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)simpleDeleteWithBucket:(NSString *)bucket
                    objectKey:(NSString *)objectKey {
    NSString *url = [NSString stringWithFormat:@"%@/object/delete/%@/%@",_serviceUrl,bucket,objectKey];
    [[self DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleFile];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }]resume];
}

/**
 *  文件下载
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param savepath 下载文件保存路径(默认是沙盒的Caches目录)
 */
-(void)downloadObjectWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                       savePath:(NSString *)savepath {
    NSString *url = [NSString stringWithFormat:@"%@/object/download/%@/%@/%@",_serviceUrl,_acckey,bucket,objectKey];
    [self downloadFileWithURL:url savePath:savepath];
}

/**
 *  图片下载
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param savepath 下载文件保存路径(默认是沙盒的Caches目录)
 */
-(void)showImageWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                  savePath:(NSString *)savepath {
    NSString *url = [NSString stringWithFormat:@"%@/object/image/accKey/%@/%@/%@",_serviceUrl,_acckey,bucket,objectKey];
    [self downloadFileWithURL:url savePath:savepath];
}

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
                objectMetadata:(NSDictionary *)metadata {
    NSString *url = [NSString stringWithFormat:@"%@/object/objectId/%@/_search",_serviceUrl,bucket];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSString *name = [metadata objectForKey:@"name"];
    if (name == nil) {
        name = @"";
    }
    NSString *metanamekey = [NSString stringWithFormat:@"%@%@",USER_METADATA_PREFIX,@"name"];
    NSString *pagesizekey = [NSString stringWithFormat:@"%@%@",YCORE_INDEX,@"page-size"];
    NSString *pagenumkey = [NSString stringWithFormat:@"%@%@",YCORE_INDEX,@"page-num"];
    [request setValue:[NSString stringWithFormat:@"%d",pagesize] forHTTPHeaderField:pagesizekey];
    [request setValue:[NSString stringWithFormat:@"%d",pagenum] forHTTPHeaderField:pagenumkey];
    [request setValue:self.acckey forHTTPHeaderField:S3_ACC_KEY];
    [request setValue:self.secretkey forHTTPHeaderField:S3_SECRET_KEY];
    [request setValue:name forHTTPHeaderField:metanamekey];
    [[self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error == nil) {
            [self networkCallBackWithResponse:responseObject];
            [self succeedHandleFile];
        }else{
            [self handleResponseError:error];
        }
    }]resume];
}

#pragma mark ====== helper methods ======

-(void)networkCallBackWithResponse:(id)response {
    if (self.responseHandler) {
        self.responseHandler(response);
    }
}

-(void)handleResponseError:(NSError *)error {
    if (self.suspendBlock) {
        self.suspendBlock(error);
        return;
    }
    NSLog(@"HTTP ERROR:%@",error.localizedDescription);
}

-(void)succeedHandleFile {
    if (self.nextDownloadBlock) {
        self.nextDownloadBlock();
        return;
    }
    NSLog(@"恭喜哈,文件操作成功");
}























@end
