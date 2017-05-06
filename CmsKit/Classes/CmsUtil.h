//
//  CmsUtil.h
//  Pods
//
//  Created by ycs on 2017/5/5.
//
//

#import <Foundation/Foundation.h>

@interface CmsUtil : NSObject

/** md5加密 */
+(NSString *)md5:(NSString *)str;

/** aes加密 */
+(NSString *)encryptAES:(NSString *)content key:(NSString *)key;

/** 获取当前时间戳 */
+(NSString *)buildTimeStamp;

@end
