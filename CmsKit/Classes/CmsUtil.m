//
//  CmsUtil.m
//  Pods
//
//  Created by ycs on 2017/5/5.
//
//

#import "CmsUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation CmsUtil

NSString* data2hexString(NSData *data)
{
    NSUInteger bytesCount = data.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = data.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

+(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return [[NSString stringWithFormat:            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ]lowercaseString];
}

+ (NSString *)encryptAES:(NSString *)content key:(NSString *)key {
    if (content == nil || key == nil || [content isEqualToString:@""] || [key isEqualToString:@""]){
        return @"";
    }
    /* 目前改成了RC4加密 */
    return [self HloveyRC4:content key:key];
}

+(NSString *)buildTimeStamp {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970] * 1000;  //  *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%ld", (long)a]; //转为字符型
    return timeString;

}

+(NSString*) HloveyRC4:(NSString*)aInput key:(NSString*)aKey {
    const void *vplainText;
    size_t plainTextBufferSize;
    plainTextBufferSize = [aInput length];
    NSData *data = [aInput dataUsingEncoding:NSUTF8StringEncoding];
    vplainText = [data bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    NSString *key = aKey;
    const void *vkey = (const void *) [key UTF8String];
    
    size_t keyLength = [[key dataUsingEncoding:NSUTF8StringEncoding] length];
    ccStatus = CCCrypt(kCCEncrypt,
                       kCCAlgorithmRC4,
                       0,
                       vkey,
                       keyLength,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    NSData *rettdata = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    NSString *reet = [data2hexString(rettdata) lowercaseString];
    return reet;
    
}





















@end
