module.exports = {
    pick: function (successCallback, errorCallback, maxCount) {
        if (!maxCount) maxCount = 1;
        cordova.exec(successCallback, errorCallback, "WXPhoto", "pick", [maxCount]);
    },
    pickVideo: function(successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "WXPhoto", "pickVideo", []);
    },
    compressVideo: function(sourceUrl, destPath, successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "WXPhoto", "compressVideo", [sourceUrl, destPath]);
    },
    initialize: function() {
    	window.supportVideoUpload = true;
    }
}