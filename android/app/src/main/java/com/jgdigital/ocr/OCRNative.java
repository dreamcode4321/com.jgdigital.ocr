package com.jgdigital.ocr;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class OCRNative implements FlutterPlugin, MethodCallHandler {
    static {
        System.loadLibrary("ocr");
    }

    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "com.jgdigital.ocr/ocr");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("processImage")) {
            String imagePath = call.argument("imagePath");
            String trainedDataPath = call.argument("trainedDataPath");
            String text = processImage(imagePath, trainedDataPath);
            result.success(text);
        } else if (call.method.equals("saveResults")) {
            // You may need to convert Dart List<Map> to Java array
            // This is a stub for saving results
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    // Native methods
    public native String processImage(String imagePath, String trainedDataPath);
    public native void saveResults(Object results, String outputFolder);
}
