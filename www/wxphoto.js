module.exports = {
    pick: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WXPhoto", "pick", []);
    },
    pickVideo: function(successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "WXPhoto", "pickVideo", []);
    },
    compressVideo: function(sourceUrl, destPath, successCallback, errorCallback) {
    	cordova.exec(successCallback, errorCallback, "WXPhoto", "compressVideo", [sourceUrl, destPath]);
    }
}