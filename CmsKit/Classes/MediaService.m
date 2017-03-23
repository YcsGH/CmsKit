//
//  MediaService.m
//  Pods
//
//  Created by ycs on 17/3/21.
//
//

#import "MediaService.h"
#import "HttpHeader.h"

@implementation MediaService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestSerializer.timeoutInterval = 40;
        AFHTTPResponseSerializer *ser = [AFHTTPResponseSerializer serializer];
        ser.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",nil];
        if (self.token != nil) {
            [self.requestSerializer setValue:self.token forHTTPHeaderField:Token];
        }
        self.responseSerializer = ser;
    }
    return self;
}


/**
 *  查看视频信息
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)acquireMediaInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey {
    NSString *url = [NSString stringWithFormat:@"%@/avinfo/%@/%@",self.serviceUrl,bucket,objectKey];
    [[self GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }] resume];

}

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
                 notifyUrl:(NSString *)notifyUrl {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (fops != nil && ![fops isEqualToString:@""]) {
        [parameters setObject:fops forKey:@"fops"];
    }
    if (notifyUrl != nil && ![notifyUrl isEqualToString:@""]) {
        [parameters setObject:notifyUrl forKey:@"notifyURL"];
    }
    NSString *url = [NSString stringWithFormat:@"%@/pfop/%@/%@",self.serviceUrl,bucket,objectKey];
    [[self POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }] resume];
    
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

-(void)succeedHandleImage {
    if (self.successBlock) {
        self.successBlock();
        return;
    }
    NSLog(@"恭喜哈,视频操作成功");
}



@end
