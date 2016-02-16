package com.foamtrace.photopicker;


import android.content.Intent;

import com.foamtrace.photopicker.intent.PhotoPickerIntent;
import com.xinfu.uuke.MainActivity;

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

        cordova.getThreadPool().execute(new Runnable() {
             @Override
             public void run() {
                PhotoPickerIntent intent = new PhotoPickerIntent(_this.cordova.getActivity());
                intent.setSelectModel(com.foamtrace.photopicker.SelectModel.MULTI);
                intent.setShowCarema(true); // 是否显示拍照
                intent.setMaxTotal(9); // 最多选择照片数量，默认为9
        //intent.setSelectedPaths(imagePaths); // 已选中的照片地址， 用于回显选中状态
        //startActivityForResult(intent, REQUEST_CAMERA_CODE);
                _this.cordova.startActivityForResult((CordovaPlugin) _this, intent, 1);
             }
        });

        PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
        r.setKeepCallback(true);
        callbackContext.sendPluginResult(r);


        return true;
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
        ArrayList<String> res = intent.getStringArrayListExtra(com.foamtrace.photopicker.PhotoPickerActivity.EXTRA_RESULT);

        try {
            JSONObject result = new JSONObject();
            String url = res == null ? "null" : res.get(0);
            result.put("url", url);
            result.put("isOrigin", true);
            this.callbackContext.success(result);
        } catch (JSONException e) {

        }
    }
}
