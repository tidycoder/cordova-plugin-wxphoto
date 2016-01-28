
#import "CDVWXPhoto.h"
#import "TZImagePickerController.h"


@implementation CDVWXPhoto:CDVPlugin

#define CDV_PHOTO_PREFIX @"cdv_photo_"

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
    // NSDictionary* dic = [infos firstObject];
    // NSURL* nsurl = [dic objectForKey:@"PHImageFileURLKey"];
    // NSString* url = nsurl.absoluteString;
    // NSLog(@"image file url: %@", url);
    
	__weak CDVWXPhoto* weakSelf = self;
    UIImage* image = [photos firstObject];
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    if (data) {
        NSString* extension = @"jpg";
        NSString* filePath = [self tempFilePath:extension];
        NSError* err = nil;
        CDVPluginResult* result = nil;
        
        // save file
        if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
        } else {
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  filePath, @"url", [NSNumber numberWithBool:isOrigin], @"isOrigin", nil];

            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        }
        [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.currentCallbackId];
    }
    
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)tempFilePath:(NSString*)extension
{
    NSString* docsPath = [NSTemporaryDirectory()stringByStandardizingPath];
    NSFileManager* fileMgr = [[NSFileManager alloc] init]; // recommended by Apple (vs [NSFileManager defaultManager]) to be threadsafe
    NSString* filePath;
    
    // generate unique file name
    int i = 1;
    do {
        filePath = [NSString stringWithFormat:@"%@/%@%03d.%@", docsPath, CDV_PHOTO_PREFIX, i++, extension];
    } while ([fileMgr fileExistsAtPath:filePath]);
    
    return filePath;
}
@end


