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
                       keyMap:(NSDictionary *)keymap{
    self = [super init];
    if (self) {
        self.objectKey = objectKey;
        self.filePath = filepath;
        self.keymap = keymap;
    }
    return self;
}


@end
