module.exports = {
    pick: function (successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "WXPhoto", "pick", []);
    }
}