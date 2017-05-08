//
//  MediaService.m
//  Pods
//
//  Created by ycs on 17/3/21.
//
//

#import "MediaService.h"
#import "HttpHeader.h"
#import "CmsUtil.h"

@implementation MediaService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestSerializer.timeoutInterval = 30;
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
                        objectKey:(NSString *)objectKey
                        isPrivate:(BOOL)isPrivate{
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *opt = [CmsUtil encryptAES:content key:self.secretkey];
        url = [NSString stringWithFormat:@"%@/avinfo/private/%@",self.serviceUrl,opt];
        NSLog(@">>> 加密后:%@",url);
    }else{
        url = [NSString stringWithFormat:@"%@/avinfo/%@/%@",self.serviceUrl,bucket,objectKey];
    }
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
                 notifyUrl:(NSString *)notifyUrl
                 isPrivate:(BOOL)isPrivate{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (fops != nil && ![fops isEqualToString:@""]) {
        [parameters setObject:fops forKey:@"fops"];
    }
    if (notifyUrl != nil && ![notifyUrl isEqualToString:@""]) {
        [parameters setObject:notifyUrl forKey:@"notifyURL"];
    }
    
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *opt = [CmsUtil encryptAES:content key:self.secretkey];
        url = [NSString stringWithFormat:@"%@/pfop/private/%@",self.serviceUrl,opt];
        NSLog(@">>> 加密后:%@",url);
    }else{
        url = [NSString stringWithFormat:@"%@/pfop/%@/%@",self.serviceUrl,bucket,objectKey];
    }
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
    NSLog(@"http error:%@",error.localizedDescription);
}

-(void)succeedHandleImage {
    if (self.successBlock) {
        self.successBlock();
        return;
    }
    NSLog(@"恭喜哈,视频操作成功");
}



@end
