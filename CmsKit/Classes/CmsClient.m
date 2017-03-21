//
//  CmsClient.m
//  Pods
//
//  Created by ycs on 17/2/15.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import "CmsClient.h"
#import "RBUClient.h"
#import "RBUObject.h"
#import "HttpHeader.h"

@interface CmsClient ()

@property (nonatomic,strong) RBUClient *rbuClient;
@property (nonatomic,strong) RBUObject *rbuObject;
@property (nonatomic,strong) NSString *serviceURL;
@property (nonatomic,strong) NSString *acckey;
@property (nonatomic,strong) NSString *secretKey;
@property (nonatomic,assign) int partsize;

@end

@implementation CmsClient

-(instancetype)initWithBaseURL:(NSString *)baseUrl
                        accKey:(NSString *)acckey
                     secretKey:(NSString *)secretKey {
    self = [super init];
    if (self) {
        self.serviceURL = baseUrl;
        self.acckey = acckey;
        self.secretKey = secretKey;
        self.partsize = 1024 * 1024;
    }
    return self;
}

-(void)putObjectViaRBU:(NSString *)bucketName
             objectKey:(NSString *)objectKey
              filePath:(NSString *)filePath
             imageFlag:(BOOL)imageFlag
        objectMetadata:(NSDictionary *)metadata {
    self.rbuObject = [[RBUObject alloc]initWithObjectKey:objectKey filePath:filePath imageFlag:imageFlag];
    _rbuObject.metaData = [self addAmzMetaPrefix:metadata];
    [_rbuObject.metaData setObject:self.acckey forKey:S3_ACC_KEY];
    [_rbuObject.metaData setObject:self.secretKey forKey:S3_SECRET_KEY];
    if(bucketName == nil) bucketName = @"";
    [_rbuObject.metaData setObject:bucketName forKey:S3_BUCKET_KEY];
    [self.rbuClient uploadObject:_rbuObject];
}

#pragma mark ====== Helper Methods ======

-(NSMutableDictionary *)addAmzMetaPrefix:(NSDictionary *)metadata {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *key in metadata.allKeys) {
        NSString *newKey = [NSString stringWithFormat:@"%@%@",USER_METADATA_PREFIX,key];
        [dict setObject:metadata[key] forKey:newKey];
    }
    return dict;
}

#pragma mark ====== Lazy ======

-(void)setServiceURL:(NSString *)serviceURL {
    if (serviceURL == nil) {
        _serviceURL = @"";
        return;
    }
    _serviceURL = serviceURL;
}

-(void)setAcckey:(NSString *)acckey {
    if (acckey == nil) {
        _acckey = @"";
        return;
    }
    _acckey = acckey;
}

-(void)setSecretKey:(NSString *)secretKey {
    if (secretKey == nil) {
        _secretKey = @"";
    }
    _secretKey = secretKey;
}

-(RBUClient *)rbuClient {
    if (!_rbuClient) {
        _rbuClient = [[RBUClient alloc]init];
        _rbuClient.serviceUrl = self.serviceURL;
        _rbuClient.progressAdapter = self.progressAdapter;
        _rbuClient.responseHandler = self.responseHandler;
        _rbuClient.suspendBlock = self.suspendBlock;
        _rbuClient.nextUploadBlock = self.nextUploadBlock;
        _rbuClient.token = self.token;
    }
    return _rbuClient;
}


#pragma mark ====== 清理缓存 ======

-(void)cleanUserDefaultsKeyWithObjectId:(NSString *)objectId {
    NSString *headKey = [NSString stringWithFormat:@"%@_%@",RBU_CACHE_KEY,objectId];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:headKey];
}

-(void)invalidateAndCancel {
    [self.rbuClient.session invalidateAndCancel];
}















@end
