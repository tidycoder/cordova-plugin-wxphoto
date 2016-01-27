
#import "CDVWXPhoto.h"
#import "TZImagePickerController.h"


@implementation CDVWXPhoto:CDVPlugin


- (void)pick:(CDVInvokedUrlCommand *)command
{
	self.currentCallbackId = command.callbackId;
	 __weak CDVWXPhoto* weakSelf = self;
	[self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
    	    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    	    [weakSelf.viewController presentViewController:imagePickerVc animated:YES completion:nil];
        });
	}];
}

/// 用户点击了取消
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
	CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
}

/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos isOrigin:(BOOL)isOrigin{
    // NSString* url = [[infos firstObject] objectForKey:@"PHImageFileURLKey"];
    
	 __weak CDVWXPhoto* weakSelf = self;
    dispatch_block_t invoke = ^(void) {
        __block CDVPluginResult* pluginResult = nil;
        NSDictionary* dic = [infos firstObject];
        NSString* url = [[dic objectForKey:@"PHImageFileURLKey"] absoluteString];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
    		url, @"url", [NSNumber numberWithBool:isOrigin], @"isOrigin", nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [weakSelf.commandDelegate sendPluginResult:pluginResult callbackId:weakSelf.currentCallbackId];
    };
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:invoke];
}

@end


