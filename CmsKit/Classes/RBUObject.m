//
//  RBUObject.m
//  Pods
//
//  Created by ycs on 17/2/15.
//  Copyright © 2017年 yuancore. All rights reserved.
//

#import "RBUObject.h"

@implementation RBUObject


-(instancetype)initWithObjectKey:(NSString *)objectKey
                        filePath:(NSString *)filepath
                       imageFlag:(BOOL)imageFlag{
    self = [super init];
    if (self) {
        self.objectKey = objectKey;
        self.filePath = filepath;
        self.imageFlag = imageFlag;
    }
    return self;
}


@end
