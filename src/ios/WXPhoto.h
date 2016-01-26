//
//  CDVAlipay.h
//
//  Created by xwang on 01/11/16.
//
//

#import <Cordova/CDV.h>

@interface CDVWXPhoto:CDVPlugin <TZImagePickerControllerDelegate>

@property (nonatomic, strong) NSString *currentCallbackId;

- (void)pick:(CDVInvokedUrlCommand *)command;

@end