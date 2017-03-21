//
//  RBDClient.m
//  Temproject
//
//  Created by ycs on 17/2/21.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import "RBDClient.h"

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
        [responseSer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/plain", nil]];
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
            if (self.nextDownloadBlock) {
                self.nextDownloadBlock();
            }
        }else{ // 被动取消下载任务
            id resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if ([resumeData isKindOfClass:[NSData class]]) {
                self.resumeData = (NSData *)resumeData;
            }
            if (self.suspendBlock) {
                self.suspendBlock(error);
            }
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
            if (self.nextDownloadBlock) {
                self.nextDownloadBlock();
            }
        }else{
            id resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            if ([resumeData isKindOfClass:[NSData class]]) {
                self.resumeData = (NSData *)resumeData;
            }
            if (self.suspendBlock) {
                self.suspendBlock(error);
            }
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


#pragma mark ====== Lazy ======


























@end
