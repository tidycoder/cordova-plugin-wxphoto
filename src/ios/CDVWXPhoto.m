
#import "CDVWXPhoto.h"
#import "TZImagePickerController.h"


@implementation CDVWXPhoto:CDVPlugin


- (void)pick:(CDVInvokedUrlCommand *)command
{
	// self.currentCallbackId = command.callbackId;
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"success"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
    // TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    // [self presentViewController:imagePickerVc animated:YES completion:nil];
}

/// 用户点击了取消
// - (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
// 	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
//     [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
// }

/// 用户选择好了图片，如果assets非空，则用户选择了原图。
// - (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos{
//     NSString* url = [[infos firstObject] objectForKey:@"PHImageFileURLKey"];
// 	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:url];
//     [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
// }

@end


