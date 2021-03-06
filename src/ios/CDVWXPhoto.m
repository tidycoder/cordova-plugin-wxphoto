
#import "CDVWXPhoto.h"
#import "TZImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>


@implementation CDVWXPhoto:CDVPlugin

#define CDV_PHOTO_PREFIX @"cdv_photo_"

- (void)pick:(CDVInvokedUrlCommand *)command
{
  self.currentCallbackId = command.callbackId;
  int maxImageCount = 1;
  if (command.arguments.count > 0) {
      NSString* sMaxImageCount = [command.arguments objectAtIndex:0];
      if (sMaxImageCount != nil) maxImageCount = [sMaxImageCount intValue];
  }

   __weak CDVWXPhoto* weakSelf = self;
  [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
          TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:maxImageCount delegate:self];
          [weakSelf.viewController presentViewController:imagePickerVc animated:YES completion:nil];
        });
  }];
}

- (void)pickVideo:(CDVInvokedUrlCommand*)command
{
  self.currentCallbackId = command.callbackId;
   __weak CDVWXPhoto* weakSelf = self;
  [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
          TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithVideo:self];
          [weakSelf.viewController presentViewController:imagePickerVc animated:YES completion:nil];
        });
  }];
}

- (void)compressVideo:(CDVInvokedUrlCommand*)command
{
    self.currentCallbackId = command.callbackId;
    [self.commandDelegate runInBackground:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* sUrl = [command.arguments objectAtIndex:0];
            NSURL* url = [NSURL URLWithString:sUrl];
            NSString * saveVideopath = [NSString stringWithFormat:@"%@/Library/NBCache/%@/SaveVideo/",NSHomeDirectory(),@"123456789"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:saveVideopath]) {
                NSError * error = nil;
                
                if ([[NSFileManager defaultManager] createDirectoryAtPath:saveVideopath withIntermediateDirectories:YES attributes:nil error:&error]){
                    
                    [self videoCompressionWith:url toVideoSavePath:saveVideopath];
                } else {
                    
                    NSLog(@"%@",error);
                }
            } else {
                [self videoCompressionWith:url toVideoSavePath:saveVideopath];
            }
        });
    }];

}

-(void)videoCompressionWith:(NSURL *)url toVideoSavePath:(NSString*)saveVideopath
{
    __weak CDVWXPhoto* weakSelf = self;

    
    NSString * videoOutputPath = [self tempFilePath:@"mp4"];//[NSString stringWithFormat:@"%@23.mov",saveVideopath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoOutputPath]) {
        
        AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        exportSession.outputURL = [NSURL fileURLWithPath:videoOutputPath];
        NSLog(@"正在压缩");
        
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            CDVPluginResult* result = nil;
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  videoOutputPath, @"destUrl", nil];

            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusUnknown");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusWaiting");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusExporting");
                    break;
                case AVAssetExportSessionStatusCompleted:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusCompleted");
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
                    [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.currentCallbackId];
                    break;
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusFailed");
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"exportSession.status AVAssetExportSessionStatusCancelled");
                    break;
                default:
                    break;
            }
        }];
    } else {
//        [self videoHasExist:url filePath:videoOutputPath];
    }
}


/// 用户点击了取消
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
  CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    __weak CDVWXPhoto* weakSelf = self;
    CDVPluginResult* result = nil;

    NSData* data = UIImageJPEGRepresentation(coverImage, 0.8);
    if (data) {
        NSString* extension = @"jpg";
        NSString* filePath = [self tempFilePath:extension];
        NSError* err = nil;

        if (![data writeToFile:filePath options:NSAtomicWrite error:&err]) {
            //            NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_IO_EXCEPTION messageAsString:[err localizedDescription]];
            [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.currentCallbackId];
            [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            return;
        } else {
            if ([asset isKindOfClass:[PHAsset class]]) {
                PHAsset* phasset = (PHAsset*)asset;
                [[PHImageManager defaultManager] requestAVAssetForVideo:phasset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
                    NSURL *url = (NSURL *)[(AVURLAsset *)avAsset URL];
                    NSLog(@"url = %@", [url absoluteString]);
                    NSLog(@"url = %@", [url relativePath]);
                    
                    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          filePath, @"coverUrl", url.absoluteString, @"url", nil];
                    
                    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
                    
                    [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.currentCallbackId];
                    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
                }];
            } else {
                ALAsset* alasset = (ALAsset*)asset;
                NSURL* url = [[alasset defaultRepresentation] url];

                NSLog(@"url = %@", url);
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      filePath, @"coverUrl", url.absoluteString, @"url", nil];
                
                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
                
                [weakSelf.commandDelegate sendPluginResult:result callbackId:weakSelf.currentCallbackId];
                [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
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
  NSMutableArray *dicts = [NSMutableArray array];
  for (int i = 0; i < photos.count; ++i) {
      if (iOS8Later) {
          NSData* data = [photos objectAtIndex:i];
          PHAsset* asset = [assets objectAtIndex:i];
          
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
                  break;
              } else {
                  NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
                  NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        filePath, @"url", [NSNumber numberWithBool:isOrigin], @"isOrigin", [NSNumber numberWithLong:asset.pixelWidth], @"width", [NSNumber numberWithLong:asset.pixelHeight], @"height", nil];
                  [dicts addObject:dict];

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
                  break;
              } else {
                  NSLog(@"file size: %lld", [self fileSizeAtPath:filePath]);
                  NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        filePath, @"url", [NSNumber numberWithBool:YES], @"isOrigin", [NSNumber numberWithLong:asset.defaultRepresentation.dimensions.width], @"width", [NSNumber numberWithLong:asset.defaultRepresentation.dimensions.height], @"height", nil];
                  [dicts addObject:dict];
                  result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
              }
          }
      }

    }
    
    if (result == nil) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:dicts];
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


