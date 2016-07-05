package uuke.xinfu.wxphoto;


import android.content.Context;
import android.content.Intent;

import uuke.xinfu.wxphoto.intent.PhotoPickerIntent;
import uuke.xinfu.wxphoto.intent.VideoPickerIntent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;


import android.Manifest;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.MediaScannerConnection;
import android.media.MediaScannerConnection.MediaScannerConnectionClient;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.content.pm.PackageManager;

import com.netcompss.ffmpeg4android.GeneralUtils;
import com.netcompss.loader.LoadJNI;

public class CDVWXPhoto extends CordovaPlugin {

    public CallbackContext callbackContext;

    public static final int PERMISSION_DENIED_ERROR = 20;
    protected final static String[] permissions = { Manifest.permission.READ_EXTERNAL_STORAGE };

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("pick")) {
            return pick(args, callbackContext);
        }
        else if (action.equals("pickVideo")) {
            return pickVideo(args, callbackContext);
        }
        else if (action.equals("compressVideo")) {
            return compressVideo(args, callbackContext);
        }
        return false;
    }

    protected boolean pick(CordovaArgs args, final CallbackContext callbackContext) {

        final CDVWXPhoto _this = this;

        if(!PermissionHelper.hasPermission(this, permissions[0])) {
            PermissionHelper.requestPermission(this, 0, Manifest.permission.READ_EXTERNAL_STORAGE);
        } else {
            this.getPicture();
        }
        // cordova.getThreadPool().execute(new Runnable() {
        //      @Override
        //      public void run() {
        //         PhotoPickerIntent intent = new PhotoPickerIntent(_this.cordova.getActivity());
        //         intent.setSelectModel(SelectModel.MULTI);
        //         intent.setShowCarema(true); // 是否显示拍照
        //         intent.setMaxTotal(1); // 最多选择照片数量，默认为9
        //         //intent.setSelectedPaths(imagePaths); // 已选中的照片地址， 用于回显选中状态
        //         //startActivityForResult(intent, REQUEST_CAMERA_CODE);
        //         _this.cordova.startActivityForResult((CordovaPlugin) _this, intent, 1);
        //      }
        // });

        PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
        r.setKeepCallback(true);
        callbackContext.sendPluginResult(r);


        return true;
    }

   protected boolean pickVideo(CordovaArgs args, final CallbackContext callbackContext) {
        this.callbackContext = callbackContext;

        final CDVWXPhoto _this = this;

        if(!PermissionHelper.hasPermission(this, permissions[0])) {
            PermissionHelper.requestPermission(this, 0, Manifest.permission.READ_EXTERNAL_STORAGE);
        } else {
            this.getVideo();
        }

        PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
        r.setKeepCallback(true);
        callbackContext.sendPluginResult(r);

        return true;
    }

    protected boolean compressVideo(CordovaArgs args, final CallbackContext callbackContext) {
        // GeneralUtils.checkForPermissionsMAndAbove(Main.this, true);
        LoadJNI vk = new LoadJNI();
        try {
            String src = args.getString(0);
            String name = args.getString(1);
            String workFolder = this.cordova.getActivity().getApplicationContext().getFilesDir().getAbsolutePath();
            String path = Environment.getExternalStorageDirectory().getAbsolutePath() + "/uuke";

            String[] complexCommand = {"ffmpeg","-y", "-i", src, "-strict","experimental","-s",
                    "160x120","-r","25", "-vcodec", "mpeg4", "-b", "150k", "-ab","48000", "-ac", "2",
                    "-ar", "22050", path+"/"+name};
            Context context=this.cordova.getActivity().getApplicationContext();
            vk.run(complexCommand, workFolder, context);
            JSONObject result = new JSONObject();
            result.put("destUrl", path+"/"+name);
            this.callbackContext.success(result);
            Log.i("test", "ffmpeg4android finished successfully");
        } catch (Throwable e) {
            Log.e("test", "vk run exception.", e);
        }

        return true;
    }

    public void getPicture() {
        final CDVWXPhoto _this = this;
        PhotoPickerIntent intent = new PhotoPickerIntent(_this.cordova.getActivity());
        intent.setSelectModel(SelectModel.MULTI);
        intent.setShowCarema(true); // 是否显示拍照
        intent.setMaxTotal(1); // 最多选择照片数量，默认为9
        //intent.setSelectedPaths(imagePaths); // 已选中的照片地址， 用于回显选中状态
        //startActivityForResult(intent, REQUEST_CAMERA_CODE);
        _this.cordova.startActivityForResult((CordovaPlugin) _this, intent, 1);
    }

    public void getVideo() {
        final CDVWXPhoto _this = this;
        VideoPickerIntent intent = new VideoPickerIntent(_this.cordova.getActivity());
        _this.cordova.startActivityForResult((CordovaPlugin) _this, intent, 2);
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException
    {
        for(int r:grantResults)
        {
            if(r == PackageManager.PERMISSION_DENIED)
            {
                this.callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR));
                return;
            }
        }
        getPicture();
    }

    /**
     * Called when the camera view exits.
     *
     * @param requestCode The request code originally supplied to startActivityForResult(),
     *                    allowing you to identify who this result came from.
     * @param resultCode  The integer result code returned by the child activity through its setResult().
     * @param intent      An Intent, which can return result data to the caller (various data can be attached to Intent "extras").
     */
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {

        if (intent == null)
            return;

        if (requestCode == 1) {
            ArrayList<String> res = intent.getStringArrayListExtra(PhotoPickerActivity.EXTRA_RESULT);
            Boolean isOrigin = intent.getBooleanExtra(PhotoPickerActivity.EXTRA_ORIGIN, false);

            try {
                JSONObject result = new JSONObject();
                String url = res == null ? "null" : res.get(0);
                result.put("url", url);
                result.put("isOrigin", isOrigin);
                this.callbackContext.success(result);
            } catch (JSONException e) {

            }
        } else if (requestCode == 2) {
            Video video = intent.getParcelableExtra("video");
            String coverUrl = intent.getStringExtra("coverUrl");

            try {
                JSONObject result = new JSONObject();
                result.put("url", video.path);
                result.put("coverUrl", coverUrl);
                result.put("duration", video.duration);
                this.callbackContext.success(result);
            } catch (JSONException e) {

            }
        }

    }
}
