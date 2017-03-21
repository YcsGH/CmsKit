//
//  RBUObject.h
//  Pods
//
//  Created by ycs on 17/2/15.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBUObject : NSObject

@property (nonatomic,strong) NSString *objectKey;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,assign) BOOL imageFlag;
@property (nonatomic,strong) NSMutableDictionary *metaData;

// 初始化
-(instancetype)initWithObjectKey:(NSString *)objectKey
                        filePath:(NSString *)filepath
                       imageFlag:(BOOL)imageFlag;


@end
