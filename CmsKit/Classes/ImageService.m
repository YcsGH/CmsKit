//
//  ImageService.m
//  Pods
//
//  Created by ycs on 17/3/21.
//
//

#import "ImageService.h"
#import "CmsUtil.h"

@implementation ImageService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestSerializer.timeoutInterval = 30;
        AFHTTPResponseSerializer *ser = [AFHTTPResponseSerializer serializer];
        ser.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",@"application/octet-stream",@"image/gif",@"image/jpeg",@"image/png",nil];
        self.responseSerializer = ser;
    }
    return self;
}


-(void)imageCutWithBucket:(NSString *)bucket
                objectKey:(NSString *)objectKey
                    width:(int)width
                   height:(int)height
                   pointX:(int)px
                   pointY:(int)py
                isPrivate:(BOOL)isPrivate {
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *opt = [CmsUtil encryptAES:content key:self.secretkey];
        url = [NSString stringWithFormat:@"%@/imageCut/private/%@/%@/%d/%d/%d/%d",self.serviceUrl,self.acckey,opt,width,height,px,py];
    }else{
        url = [NSString stringWithFormat:@"%@/imageCut/%@/%@/%@/%d/%d/%d/%d",self.serviceUrl,self.acckey,bucket,objectKey,width,height,px,py];
    }
    
    [[self GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }]resume];
    
}

-(void)imageFormatWithBucket:(NSString *)bucket
                   objectKey:(NSString *)objectKey
                      format:(NSString *)format
                   isPrivate:(BOOL)isPrivate{
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *opt = [CmsUtil encryptAES:content key:self.secretkey];
        url = [NSString stringWithFormat:@"%@/imageFormat/private/%@/%@/%@",self.serviceUrl,self.acckey,opt,format];
    }else{
        url = [NSString stringWithFormat:@"%@/imageFormat/%@/%@/%@/%@",self.serviceUrl,self.acckey,bucket,objectKey,format];
    }
    [[self GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }]resume];
}


-(void)acquireImageInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey
                        isPrivate:(BOOL)isPrivate{
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *opt = [CmsUtil encryptAES:content key:self.secretkey];
        url = [NSString stringWithFormat:@"%@/imageInfo/private/%@",self.serviceUrl,opt];
    }else{
        url = [NSString stringWithFormat:@"%@/imageInfo/%@/%@",self.serviceUrl,bucket,objectKey];
    }
    [[self GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }]resume];

}

-(void)imageThumbnailWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                         format:(NSString *)format
                      isPrivate:(BOOL)isPrivate {
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *opt = [CmsUtil encryptAES:content key:self.secretkey];
        if (format) {
          url = [NSString stringWithFormat:@"%@/imageThumbnail/private/%@/%@/%@",self.serviceUrl,self.acckey,opt,format];
        }else{
          url = [NSString stringWithFormat:@"%@/imageThumbnail/private/%@/%@",self.serviceUrl,self.acckey,opt];
        }
    }else{
        if (format) {
           url = [NSString stringWithFormat:@"%@/imageThumbnail/%@/%@/%@/%@",self.serviceUrl,self.acckey,bucket,objectKey,format];
        }else{
           url = [NSString stringWithFormat:@"%@/imageThumbnail/%@/%@/%@",self.serviceUrl,self.acckey,bucket,objectKey];
        }
    }
    
    [[self GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
    }]resume];
}

-(void)imageViewWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                       opt:(NSString *)opt
                 isPrivate:(BOOL)isPrivate{
    NSString *url;
    if (isPrivate) { /* 加密调阅 */
        NSString *content = [NSString stringWithFormat:@"%@/%@/%@",[CmsUtil buildTimeStamp],bucket,objectKey];
        NSString *passwd = [CmsUtil encryptAES:content key:self.secretkey];
        url = [NSString stringWithFormat:@"%@/imageView/private/%@/%@/%@",self.serviceUrl,self.acckey,passwd,opt];
    }else{
        url = [NSString stringWithFormat:@"%@/imageView/%@/%@/%@/%@",self.serviceUrl,self.acckey,bucket,objectKey,opt];
    }
    [[self GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self succeedHandleImage];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResponseError:error];
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
    NSLog(@"http error:%@",error.localizedDescription);
}

-(void)succeedHandleImage {
    if (self.successBlock) {
        self.successBlock();
        return;
    }
    NSLog(@"恭喜哈,图片操作成功");
}


@end
