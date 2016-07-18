//
//  CDVAlipay.h
//
//  Created by xwang on 01/11/16.
//
//

#import <Cordova/CDV.h>
#import "TZImagePickerController.h"

@interface CDVWXPhoto:CDVPlugin <TZImagePickerControllerDelegate>

@property (nonatomic, strong) NSString *currentCallbackId;

- (void)pick:(CDVInvokedUrlCommand *)command;
- (void)pickVideo:(CDVInvokedUrlCommand*)command;
- (void)compressVideo:(CDVInvokedUrlCommand*)command;
@end