package uuke.xinfu.wxphoto;


import android.content.Intent;

import uuke.xinfu.wxphoto.intent.PhotoPickerIntent;

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

public class CDVWXPhoto extends CordovaPlugin {

    public CallbackContext callbackContext;


    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("pick")) {
            return pick(args, callbackContext);
        }
        return false;
    }

    protected boolean pick(CordovaArgs args, final CallbackContext callbackContext) {
        this.callbackContext = callbackContext;

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
    }
}
