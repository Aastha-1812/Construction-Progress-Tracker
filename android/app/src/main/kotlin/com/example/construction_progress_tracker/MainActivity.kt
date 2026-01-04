package com.example.construction_progress_tracker

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.provider.MediaStore
import android.speech.RecognizerIntent
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

    private val MEDIA_CHANNEL = "media_channel"
    private val SPEECH_CHANNEL = "speech_channel"

    private val IMAGE_PICK_CODE = 1001
    private val VIDEO_PICK_CODE = 1002
    private val CAMERA_CAPTURE_CODE = 1003
    private val VIDEO_CAPTURE_CODE = 1004
    private val SPEECH_REQUEST = 2001

    private var pendingResult: MethodChannel.Result? = null
    private var pendingMethod: String? = null
    private var speechResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "pickImage" -> {
                        startMediaOperation("pickImage", result)
                        openImageGallery()
                    }

                    "pickVideo" -> {
                        startMediaOperation("pickVideo", result)
                        openVideoGallery()
                    }

                    "captureImage" -> {
                        if (!hasPermission(android.Manifest.permission.CAMERA)) {
                            requestPermissions(arrayOf(android.Manifest.permission.CAMERA), 4000)
                            startMediaOperation("captureImage", result)
                            return@setMethodCallHandler
                        }
                        startMediaOperation("captureImage", result)
                        openCamera()
                    }

                    "captureVideo" -> {

                        if (!hasPermission(android.Manifest.permission.CAMERA)) {
                            requestPermissions(arrayOf(android.Manifest.permission.CAMERA), 5001)
                            startMediaOperation("captureVideo", result)
                            return@setMethodCallHandler
                        }

                        if (!hasPermission(android.Manifest.permission.RECORD_AUDIO)) {
                            requestPermissions(arrayOf(android.Manifest.permission.RECORD_AUDIO), 5002)
                            startMediaOperation("captureVideo", result)
                            return@setMethodCallHandler
                        }

                        startMediaOperation("captureVideo", result)
                        openVideoCamera()
                    }

                    "getImageBytes" -> {
                        val uriStr = call.argument<String>("path")
                        handleImageBytes(uriStr, result)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startListening") {
                    speechResult = result
                    startSpeechToText()
                } else {
                    result.notImplemented()
                }
            }
    }


    private fun startMediaOperation(method: String, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("PENDING", "Another operation already running", null)
            return
        }
        pendingResult = result
        pendingMethod = method
    }

    private fun hasPermission(permission: String): Boolean {
        return checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
    }


    private fun openImageGallery() {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "image/*"
        startActivityForResult(intent, IMAGE_PICK_CODE)
    }

    private fun openVideoGallery() {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "video/*"
        startActivityForResult(intent, VIDEO_PICK_CODE)
    }

    private fun openCamera() {
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        try {
            startActivityForResult(intent, CAMERA_CAPTURE_CODE)
        } catch (e: Exception) {
            pendingResult?.error("CAMERA_ERROR", e.message, null)
            pendingResult = null
        }
    }

    private fun openVideoCamera() {
        val intent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
        try {
            startActivityForResult(intent, VIDEO_CAPTURE_CODE)
        } catch (e: Exception) {
            pendingResult?.error("VIDEO_ERROR", e.message, null)
            pendingResult = null
        }
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {

            4000 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    if (pendingMethod == "captureImage") openCamera()
                } else {
                    pendingResult?.error("CAMERA_DENIED", "Camera denied", null)
                }
            }

            5001 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    if (!hasPermission(android.Manifest.permission.RECORD_AUDIO)) {
                        requestPermissions(arrayOf(android.Manifest.permission.RECORD_AUDIO), 5002)
                    } else {
                        openVideoCamera()
                    }

                } else {
                    pendingResult?.error("CAMERA_DENIED", "Camera denied", null)
                }
            }

            5002 -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    openVideoCamera()
                } else {
                    pendingResult?.error("AUDIO_DENIED", "Audio denied", null)
                }
            }
        }
    }


    private fun startSpeechToText() {

        if (!hasPermission(android.Manifest.permission.RECORD_AUDIO)) {
            requestPermissions(arrayOf(android.Manifest.permission.RECORD_AUDIO), 3000)
            return
        }

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
        intent.putExtra(RecognizerIntent.EXTRA_PROMPT, "Speak...")

        try {
            startActivityForResult(intent, SPEECH_REQUEST)
        } catch (e: Exception) {
            speechResult?.error("SPEECH_ERROR", e.message, null)
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (resultCode != Activity.RESULT_OK || data == null) {
            pendingResult?.error("CANCELLED", "No data returned", null)
            pendingResult = null
            return
        }

        when (requestCode) {

            IMAGE_PICK_CODE -> {
                val uri = data.data!!
                val path = copyUriToFile(uri)
                pendingResult?.success(path)
            }

            VIDEO_PICK_CODE -> {
                val uri = data.data!!
                val path = copyUriToFile(uri)
                pendingResult?.success(path)
            }

            CAMERA_CAPTURE_CODE -> {
                val bitmap = data.extras?.get("data") as? Bitmap
                val file = saveCapturedImage(bitmap)
                pendingResult?.success(file.absolutePath)
            }


            VIDEO_CAPTURE_CODE -> {
                val uri = data.data!!
                val path = copyUriToFile(uri)
                pendingResult?.success(path)
            }

            SPEECH_REQUEST -> {
                val results = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
                speechResult?.success(results?.get(0))
            }
        }

        pendingResult = null
        pendingMethod = null
    }


    private fun saveCapturedImage(bitmap: Bitmap?): File {
        val filename = "captured_${System.currentTimeMillis()}.jpg"
        val file = File(filesDir, filename)

        val output = FileOutputStream(file)
        bitmap?.compress(Bitmap.CompressFormat.JPEG, 90, output)
        output.flush()
        output.close()

        return file
    }



    private fun copyUriToFile(uri: Uri): String {
        val inputStream = contentResolver.openInputStream(uri) ?: return ""
        val filename = "media_${System.currentTimeMillis()}"
        val file = File(filesDir, filename)

        val outputStream = FileOutputStream(file)
        inputStream.copyTo(outputStream)

        inputStream.close()
        outputStream.close()

        return file.absolutePath
    }


    private fun handleImageBytes(uriString: String?, result: MethodChannel.Result) {
        if (uriString == null) {
            result.error("INVALID_URI", "URI is null", null)
            return
        }

        try {
            val inputStream = contentResolver.openInputStream(Uri.parse(uriString))
            val bytes = inputStream?.readBytes()
            inputStream?.close()

            if (bytes != null) result.success(bytes)
            else result.error("READ_FAIL", "Could not read image bytes", null)

        } catch (e: Exception) {
            result.error("IO_ERROR", e.localizedMessage, null)
        }
    }
}
