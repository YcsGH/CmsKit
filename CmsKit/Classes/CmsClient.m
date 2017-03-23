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
#import "MediaService.h"
#import "ImageService.h"
#import "RBDClient.h"

@interface CmsClient ()

@property (nonatomic,strong) RBUClient *rbuClient;
@property (nonatomic,strong) RBUObject *rbuObject;
@property (nonatomic,strong) NSString *serviceURL;
@property (nonatomic,strong) NSString *acckey;
@property (nonatomic,strong) NSString *secretKey;
@property (nonatomic,assign) int partsize;
@property (nonatomic,strong) RBDClient *rbdClient;
@property (nonatomic,strong) ImageService *imService;
@property (nonatomic,strong) MediaService *mediaService;

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

/**
 *  上传文件函数(普通上传)
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 *  @param filePath 文件所在路径
 *  @param imageFlag 是否为图片
 *  @param metadata 文件信息
 *  metadata 最终会放在http header中
 */
-(void)simpleUploadWithBucket:(NSString *)bucket
                    objectKey:(NSString *)objectKey
                     filePath:(NSString *)filePath
                    imageFlag:(BOOL)imageFlag
               objectMetadata:(NSDictionary *)metadata {
    NSMutableDictionary *mm = [self addAmzMetaPrefix:metadata];
    [mm setObject:self.acckey forKey:S3_ACC_KEY];
    [mm setObject:self.secretKey forKey:S3_SECRET_KEY];
    [self.rbuClient simpleUploadWithBucket:bucket objectKey:objectKey filePath:filePath imageFlag:imageFlag objectMetadata:mm];
}

#pragma mark ====== 下载 API ======
/**
 *  文件删除
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)simpleDeleteWithBucket:(NSString *)bucket
                    objectKey:(NSString *)objectKey {
    [self.rbdClient simpleDeleteWithBucket:bucket objectKey:objectKey];
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
    [self.rbdClient downloadObjectWithBucket:bucket objectKey:objectKey savePath:savepath];
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
    [self.rbdClient showImageWithBucket:bucket objectKey:objectKey savePath:savepath];
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
    [self.rbdClient searchObjectsWithBucket:bucket pageSize:pagesize pageNumber:pagenum objectMetadata:metadata];
}

#pragma mark ====== 视频处理 ======

/**
 *  查看视频信息
 *  @param bucket bucket
 *  @param objectKey 对象唯一ID
 */
-(void)acquireMediaInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey {
    [self.mediaService acquireMediaInfoWithBucket:bucket objectKey:objectKey];
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
    [self.mediaService pfopMediaWithBucket:bucket objectKey:objectKey fops:fops notifyUrl:notifyUrl];
}

#pragma mark ====== 图片处理 ======

/**
 *  图片裁剪
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param width 图片裁剪宽度
 *  @param height 图片裁剪高度
 *  @param px 裁剪起点x坐标
 *  @param py 裁剪起点y坐标
 */
-(void)imageCutWithBucket:(NSString *)bucket
                objectKey:(NSString *)objectKey
                    width:(int)width
                   height:(int)height
                   pointX:(int)px
                   pointY:(int)py {
    [self.imService imageCutWithBucket:bucket objectKey:objectKey width:width height:height pointX:px pointY:py];
}
/**
 *  图片格式转换
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)imageFormatWithBucket:(NSString *)bucket
                   objectKey:(NSString *)objectKey
                      format:(NSString *)format {
    [self.imService imageFormatWithBucket:bucket objectKey:objectKey format:format];
}

/**
 *  图片信息查看
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)acquireImageInfoWithBucket:(NSString *)bucket
                        objectKey:(NSString *)objectKey {
    [self.imService acquireImageInfoWithBucket:bucket objectKey:objectKey];
}

/**
 *  图片缩略图
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param format 目标图片格式
 */
-(void)imageThumbnailWithBucket:(NSString *)bucket
                      objectKey:(NSString *)objectKey
                         format:(NSString *)format {
    [self.imService imageThumbnailWithBucket:bucket objectKey:objectKey format:format];
}

/**
 *  图片多模式
 *  @param bucketName bucket
 *  @param objectKey 对象唯一ID
 *  @param opt 模式
 */
-(void)imageViewWithBucket:(NSString *)bucket
                 objectKey:(NSString *)objectKey
                       opt:(NSString *)opt {
    [self.imService imageViewWithBucket:bucket objectKey:objectKey opt:opt];
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
        return;
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
        _rbuClient.nextUploadBlock = self.successBlock;
        _rbuClient.token = self.token;
    }
    return _rbuClient;
}

-(RBDClient *)rbdClient {
    if (!_rbdClient) {
        _rbdClient = [[RBDClient alloc]init];
        _rbdClient.serviceUrl = self.serviceURL;
        _rbdClient.progressAdapter = self.progressAdapter;
        _rbdClient.responseHandler = self.responseHandler;
        _rbdClient.suspendBlock = self.suspendBlock;
        _rbdClient.nextDownloadBlock = self.successBlock;
        _rbdClient.acckey = self.acckey;
    }
    return _rbdClient;
}

-(ImageService *)imService {
    if (!_imService) {
        _imService = [[ImageService alloc]init];
        _imService.serviceUrl = self.serviceURL;
        _imService.suspendBlock = self.suspendBlock;
        _imService.responseHandler = self.responseHandler;
        _imService.successBlock = self.successBlock;
        _imService.token = self.token;
        _imService.acckey = self.acckey;
    }
    return _imService;
}

-(MediaService *)mediaService {
    if (!_mediaService) {
        _mediaService = [[MediaService alloc]init];
        _mediaService.serviceUrl = self.serviceURL;
        _mediaService.suspendBlock = self.suspendBlock;
        _mediaService.responseHandler = self.responseHandler;
        _mediaService.successBlock = self.successBlock;
        _mediaService.token = self.token;
    }
    return _mediaService;
}


#pragma mark ====== 清理缓存 ======

-(void)cleanUserDefaultsKeyWithObjectId:(NSString *)objectId {
    NSString *headKey = [NSString stringWithFormat:@"%@_%@",RBU_CACHE_KEY,objectId];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:headKey];
}

-(void)invalidateAndCancel {
    if (_rbuClient) {
        [_rbuClient.session invalidateAndCancel];
    }
    if (_rbdClient) {
        [_rbdClient.session invalidateAndCancel];
    }
}















@end
