//
//  RBUClient.m
//  Pods
//
//  Created by ycs on 17/2/15.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import "RBUClient.h"
#import "HttpHeader.h"

@interface RBUClient ()
@property (nonatomic,assign) int successFlag;//已上传个数
@property (nonatomic,strong) NSString *currentObjectID;//当前上传对象ID
@property (nonatomic,strong) NSString *filePath;//要上传文件的路径
@property (nonatomic,assign) int needUploadBlocks;//当前对象总块数
@property (nonatomic,assign) int64_t uploadFileSize;//该任务所包含文件的总大小
@property (nonatomic,strong) NSArray *resumeChunkList;//未上传块对象索引
@property (nonatomic,assign) BOOL imageFlag;//是否为图片

@end

@implementation RBUClient

#pragma mark ====== 初始化方法 ======

- (instancetype)init {
    self = [super init];
    if (self) {
        self.partsize = 1024 * 1024;
        self.requestSerializer.timeoutInterval = 40;
        AFHTTPResponseSerializer *ser = [AFHTTPResponseSerializer serializer];
        ser.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/plain",nil];
        self.responseSerializer = ser;
    }
    return self;
}


-(void)uploadObject:(RBUObject *)rbuObject {
    // 1.分析对象
    [self analyzeObject:rbuObject];
    
    // 2.设置http header
    [self setupHttpHeaderForObject:rbuObject];
    
    // 3.开始上传
    [self getProfileWithObjectKey:_currentObjectID];
}

-(void)setupHttpHeaderForObject:(RBUObject *)rbuObject {
    if (self.token != nil) {
        [self.requestSerializer setValue:[self token] forHTTPHeaderField:Token];
    }
    for (NSString *headKey in rbuObject.metaData.allKeys) {
        [self.requestSerializer setValue:rbuObject.metaData[headKey] forHTTPHeaderField:headKey];
    }
}

-(void)analyzeObject:(RBUObject *)rbuObject {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    int64_t uploadFileSize = [[[fm attributesOfItemAtPath:rbuObject.filePath error:&error] objectForKey:NSFileSize] longLongValue];
    int partSize = self.partsize;
    int partCount = (int)(uploadFileSize / partSize) + (uploadFileSize % partSize != 0);//块数
    self.uploadFileSize = uploadFileSize;
    self.filePath = rbuObject.filePath;
    self.currentObjectID = rbuObject.objectKey;
    self.needUploadBlocks = partCount;
    self.imageFlag = rbuObject.imageFlag;
    _successFlag = 0;
}

#pragma mark ====== GET请求 ======

-(void)getProfileWithObjectKey:(NSString *)objectKey {
    [self GET:[self buildGETProfileURL] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self networkCallBackWithResponse:responseObject];
        [self resumeUploadFileWithResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
        NSInteger statusCode = response.statusCode;
        if (statusCode == 404) {
            [self uploadFileWithChunk:0];
        }else{
            [self handleResponseError:error];
        }

    }];
}

/* 文件续传 */
-(void)resumeUploadFileWithResponse:(id)responseObject {
    NSData *retData = (NSData *)responseObject;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSString *rett = [[NSString alloc]initWithData:retData encoding:enc];
    if (rett == nil || [rett isEqualToString:@""]) { //解析失败
        NSError *error = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:NSURLErrorBadServerResponse userInfo:@{NSLocalizedDescriptionKey:@"服务器异常,"}];
        [self handleResponseError:error];
        return;
    }
    self.resumeChunkList = [self fetchNotUploadedChunkIndexsFromStr:rett];
    if (_resumeChunkList.count == 0) { //当前文件已上传成功
        NSString *headKey = [NSString stringWithFormat:@"%@_%@",RBU_CACHE_KEY,self.currentObjectID];
        NSNumber *tag = [[NSUserDefaults standardUserDefaults]objectForKey:headKey];
        if (tag == nil) {
            [self headObjectFile];
        }else{
            if (self.nextUploadBlock) {
                self.nextUploadBlock();
            }
        }
        return;
    }
    self.successFlag = _needUploadBlocks - (int)_resumeChunkList.count;
    int startIndex = [_resumeChunkList[0] intValue];
    [self uploadFileWithChunk:startIndex];
}


#pragma mark ====== 块上传 ======

-(void)uploadFileWithChunk:(int)chunk { //chunk:上传块的起始值
    if (chunk == self.needUploadBlocks) return;//表示最后一块已经上传
    NSData *data;
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath];
    if (readHandle == nil) return;//检查文件是否存在
    NSMutableURLRequest *request;
    //NSProgress *progress;
    AFHTTPRequestSerializer *ser = [[AFHTTPRequestSerializer alloc]init];
    ser.timeoutInterval = self.timeout;
    [readHandle seekToFileOffset:_partsize * chunk];
    data = [readHandle readDataOfLength:_partsize];
    if (data == nil) return;//检查data
    request = [ser multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@/%d",[self buildUploadFileWithChunkURL],chunk] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:_currentObjectID mimeType:(_imageFlag ? @"image/png":@"application/octet-stream")]; //
    } error:nil];
    [request setValue:[NSString stringWithFormat:@"%d",self.needUploadBlocks] forHTTPHeaderField:@"X-Ycore-Blocks"];
    if (self.token != nil) {
        [request setValue:self.token forHTTPHeaderField:Token];
    }
    [[self uploadTaskWithStreamedRequest:request progress:^(NSProgress *uploadProgress){
        
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [self handleResponseError:error];
        }
        else{
            [self networkCallBackWithResponse:responseObject];
            [self uploadFileWithChunk:chunk+1];
            self.successFlag++;
        }
    }] resume];
}

#pragma mark ====== 进度处理 ======
-(void)setSuccessFlag:(int)successFlag {
    _successFlag = successFlag;
    // 上传完一个块才统计一个进度,这样比较好控制
    NSProgress *progress = [[NSProgress alloc]init];
    progress.totalUnitCount = self.needUploadBlocks;//因为每个块大小都一样
    progress.completedUnitCount = successFlag;
    if (self.progressAdapter) {
        self.progressAdapter(progress);
    }
    //上传完毕调用HEAD
    if (successFlag == self.needUploadBlocks) {
        [self headObjectFile];
    }
}

#pragma mark ====== HEAD请求 ======

-(void)headObjectFile {
    [self HEAD:[self buildHEADObjectURL] parameters:nil success:^(NSURLSessionDataTask *task) {
        [self networkCallBackWithResponse:task.response];
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)task.response;
        if ([res.allHeaderFields[@"X-Ycore-Blocks-Complete"] isEqualToString:@"yes"]){
            [self putToMergeObject];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self handleResponseError:error];
    }];
    
}

#pragma mark ====== PUT请求 ======

-(void)putToMergeObject {
    [self PUT:[self buildPUTToMergeURL] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //将当前文件的HEAD状态记录在一张表里
        NSString *headKey = [NSString stringWithFormat:@"%@_%@",RBU_CACHE_KEY,self.currentObjectID];
        [[NSUserDefaults standardUserDefaults]setObject:@(1) forKey:headKey];
        if (self.nextUploadBlock) {
            self.nextUploadBlock();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) { //网络请求断在__PUT__
        [self handleResponseError:error];
    }];
    
}
-(void)networkCallBackWithResponse:(id)response {
    if (self.responseHandler) {
        self.responseHandler(response);
    }
}

/** 根据服务器返回的字符串算出没有上传的文件块索引 */
-(NSArray *)fetchNotUploadedChunkIndexsFromStr:(NSString *)response {
    NSMutableArray *resArr = [NSMutableArray array];
    if (response == nil) {
        return [resArr copy];
    }
    for (int i=0; i<response.length; i++) {
        unichar cc = (unichar)[response characterAtIndex:i];
        if (cc == '0') {
            [resArr addObject:@(i)];
        }
    }
    return [resArr copy];
}

#pragma mark ====== 异常处理 ======

-(void)handleResponseError:(NSError *)error {
    NSLog(@"ERROR:%@",error.localizedDescription);
    if (self.suspendBlock) {
        self.suspendBlock(error);
    }
}

#pragma mark ====== URL Config ======

-(NSString *)buildGETProfileURL {
    return [NSString stringWithFormat:@"%@/rbu/%@/profile",_serviceUrl,self.currentObjectID];
}

-(NSString *)buildHEADObjectURL {
    return [NSString stringWithFormat:@"%@/rbu/%@/profile",_serviceUrl,self.currentObjectID];

}

-(NSString *)buildUploadFileWithChunkURL {
    return [NSString stringWithFormat:@"%@/rbu/%@/block",_serviceUrl,self.currentObjectID];

}

-(NSString *)buildPUTToMergeURL {
    return [NSString stringWithFormat:@"%@/rbu/%@/blocks",_serviceUrl,self.currentObjectID];

}

-(void)setServiceUrl:(NSString *)serviceUrl {
    if (serviceUrl == nil) {
        _serviceUrl = @"";
        return;
    }
    if ([serviceUrl hasSuffix:@"/"]) {
        NSString *rr = [serviceUrl substringToIndex:serviceUrl.length-1];
         _serviceUrl = rr;
        return;
    }
    _serviceUrl = serviceUrl;
}

#pragma mark ====== Reserved Methods ======

-(NSString *)buildIPAddressWithURL:(NSString *)restUrl parameters:(NSArray *)parameters {
    int j = 0;//记录path参数索引
    NSMutableString *url = [NSMutableString string];
    [url appendString:self.serviceUrl];
    if ([url hasSuffix:@"/"]) {
        NSString *rr = [url substringToIndex:url.length-1];
        url = [rr mutableCopy];
    }
    NSArray *sep = [restUrl componentsSeparatedByString:@"/"];
    for (int i=0; i<sep.count; i++) {
        NSString *pt = sep[i];
        if ([pt isEqualToString:@""]) {
            continue;
        }
        if([pt isEqualToString:@"%@"]) {
            [url appendString:@"/"];
            if (parameters.count > j) {
                //PathParameterFetchBlock paramFetch = parameters[j];
                NSString *rr = @"";
                if (rr == nil) { rr = @"";}
                [url appendString:rr];
                j++;
            }
        }else{
            [url appendString:@"/"];
            [url appendString:pt];
        }
    }
    if ([url hasSuffix:@"/"]) {
        NSString *rr = [url substringToIndex:url.length-1];
        url = [rr mutableCopy];
    }
    return [url copy];
}

#pragma mark ====== 普通上传接口 ======

-(void)simpleUploadWithBucket:(NSString *)bucket
                    objectKey:(NSString *)objectKey
                     filePath:(NSString *)filePath
                    imageFlag:(BOOL)imageFlag
               objectMetadata:(NSDictionary *)metadata {
    NSString *uu = [NSString stringWithFormat:@"%@/object/upload/%@/%@",_serviceUrl,bucket,objectKey];
    NSLog(@"upload:%@",uu);
    NSData *data;
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:_filePath];
    if (readHandle == nil){
        NSLog(@"要上传的文件不存在!");
        return;
    }
    NSMutableURLRequest *request;
    AFHTTPRequestSerializer *ser = [[AFHTTPRequestSerializer alloc]init];
    ser.timeoutInterval = self.timeout;
    request = [ser multipartFormRequestWithMethod:@"POST" URLString:uu parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:objectKey mimeType:(_imageFlag ? @"image/png":@"application/octet-stream")]; //
    } error:nil];
    for (NSString *headKey in metadata.allKeys) {
        [request setValue:metadata[headKey] forHTTPHeaderField:headKey];
    }
    NSLog(@"header:%@",request.allHTTPHeaderFields);
    [[self uploadTaskWithStreamedRequest:request progress:^(NSProgress *uploadProgress){
        if (self.progressAdapter) {
            self.progressAdapter(uploadProgress);
        }
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [self handleResponseError:error];
        }
        else{
            [self networkCallBackWithResponse:responseObject];
            [self succeedHandleFile];
        }
    }] resume];
    
}

-(void)succeedHandleFile {
    if (self.nextUploadBlock) {
        self.nextUploadBlock();
        return;
    }
    NSLog(@"恭喜哈,文件上传成功");
}

































@end
