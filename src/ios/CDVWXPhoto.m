
#import "CDVWXPhoto.h"
#import "TZImagePickerController.h"


@implementation CDVWXPhoto:CDVPlugin


- (void)pick:(CDVInvokedUrlCommand *)command
{
	self.currentCallbackId = command.callbackId;
	 __weak CDVCamera* weakSelf = self;
	[self.commandDelegate runInBackground:^{
	    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
	    [self.viewController presentViewController:imagePickerVc animated:YES completion:nil];
	}];
}

/// 用户点击了取消
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
}

/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos{
    // NSString* url = [[infos firstObject] objectForKey:@"PHImageFileURLKey"];
    NSDictionary* dic = [infos firstObject];
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
}

@end


