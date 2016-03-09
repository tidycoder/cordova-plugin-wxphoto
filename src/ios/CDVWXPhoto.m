
#import "CDVWXPhoto.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


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

-(long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (void)showAlertWithTitle:(NSString *)title {
//    if (iOS8Later) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
//        [self.viewController presentViewController:alertController animated:YES completion:nil];
//    } else {
        [[[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil] show];
//    }
}
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets infos:(NSArray<NSDictionary *> *)infos isOrigin:(BOOL)isOrigin {
  __weak CDVWXPhoto* weakSelf = self;
  CDVPluginResult* result = nil;
  if (iOS8Later) {
    NSData* data = [photos firstObject];
    PHAsset* asset = [assets firstObject];
    
    if (iOS9Later) {
      NSDictionary* dic = [infos firstObject];
      bool inCloud = [dic objectForKey:@"PHImageResultIsInCloudKey"];
      if (inCloud) {
        if ([data isKindOfClass:[NSNumber class]]) {
          [self showAlertWithTitle:@"照片仅保存在icloud,请打开系统相册查看下载图片后重试"];
          [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
          return;
        }
      }
    }
    //    NSData* data = UIImageJPEGRepresentation(image, 0.5);
    if (data) {
      NSString *fileName = [asset valueForKey:@"filename"];
      NSString * extension = [fileName pathExtension];
      NSString* filePath = [self tempFilePath:extension];
      NSError* err = nil;
      
      // save file
      if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        //            NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
      } else {
        NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              filePath, @"url", [NSNumber numberWithBool:isOrigin], @"isOrigin", [NSNumber numberWithLong:asset.pixelWidth], @"width", [NSNumber numberWithLong:asset.pixelHeight], @"height", nil];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
      }
    }
  }
  else {
    NSData* data = [photos firstObject];
    ALAsset* asset = [assets firstObject];
    if (data) {
      NSString* extension = @"jpg";
      NSString* filePath = [self tempFilePath:extension];
      NSError* err = nil;
      
      if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
        //            NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
      } else {
        NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              filePath, @"url", [NSNumber numberWithBool:YES], @"isOrigin", [NSNumber numberWithLong:asset.defaultRepresentation.dimensions.width], @"width", [NSNumber numberWithLong:asset.defaultRepresentation.dimensions.height], @"height", nil];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
      }
    }
  }
  
  [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.currentCallbackId];
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


