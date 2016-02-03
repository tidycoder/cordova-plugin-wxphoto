package com.foamtrace.photopicker;


import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CDVWXPhoto extends CordovaPlugin {

    public CallbackContext callbackContext;

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();

        Log.d(TAG, "wxphoto plugin initialized.");
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        if(action.equals("pick")) {
            return pick(args, callbackContext);
        }
        return false;
    }

    protected boolean pick(CordovaArgs args, final CallbackContext callbackContext) {
        this.callbackContext = callbackContext;

        // cordova.getThreadPool().execute(new Runnable() {
        //     @Override
        //     public void run() {
            	PhotoPickerIntent intent = new PhotoPickerIntent(null);
                intent.setSelectModel(SelectModel.MULTI);
                intent.setShowCarema(true); // 是否显示拍照
                intent.setMaxTotal(9); // 最多选择照片数量，默认为9
                intent.setSelectedPaths(imagePaths); // 已选中的照片地址， 用于回显选中状态
                startActivityForResult(intent, REQUEST_CAMERA_CODE);
            	this.cordova.startActivityForResult((CordovaPlugin) this, intent, 1);
        //     }
        // });

        PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
        r.setKeepCallback(true);
        callbackContext.sendPluginResult(r);


        return true;
    }

    /**
     * Called when the camera view exits.
     *
     * @param requestCode       The request code originally supplied to startActivityForResult(),
     *                          allowing you to identify who this result came from.
     * @param resultCode        The integer result code returned by the child activity through its setResult().
     * @param intent            An Intent, which can return result data to the caller (various data can be attached to Intent "extras").
     */
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
		intent.getStringArrayListExtra(PhotoPickerActivity.EXTRA_RESULT)
		this.callbackContext.success("result");
    }
