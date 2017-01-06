# cordova-plugin-wxphoto
a photo picker library similar to wechat


代码说明： 
iOS包涵所有代码。
android中使用了war， 该war的源代码在wxphoto-android-lib中


接口说明：

1. 选取照片

wxphoto.pick(
  function (res) {
	// res is an array of your picked photos
  },
  function (error) {
  },
  9 // max picking 9 photos once.
)

2. 选择视频

wxphoto.pickVideo(function(res) {
	// res is your picked video
}, function(error) {
})

3. 压缩视频

// 在选取完视频后， 得到视频在本地的路径。 在上传服务器之前，最好进行压缩。
// videoUrl: 从pickVideo中选取的地址
// videoName: 希望保存的视频名称

wxphoto.compressVideo(videoUrl, videoName, function(cres) {
	//压缩过后的视频保存地址destUrl
	console.log(cres.destUrl);
})

iOS视频压缩使用iOS本身的接口。 
android视频压缩使用ffmpeg， 具体参数太多， 若需修改，请直接Fork去源代码中去修改


