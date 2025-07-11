#include <jni.h>
#include <string>
#include <vector>
#include <opencv2/opencv.hpp>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>

extern "C" JNIEXPORT jstring JNICALL
Java_com_jgdigital_ocr_OCRNative_processImage(JNIEnv* env, jobject, jstring imagePath, jstring trainedDataPath) {
    const char* imgPath = env->GetStringUTFChars(imagePath, nullptr);
    const char* tessPath = env->GetStringUTFChars(trainedDataPath, nullptr);
    cv::Mat img = cv::imread(imgPath, cv::IMREAD_COLOR);
    cv::Mat gray;
    cv::cvtColor(img, gray, cv::COLOR_BGR2GRAY);
    cv::Mat denoised;
    cv::fastNlMeansDenoising(gray, denoised, 30);
    cv::Mat thresh;
    cv::threshold(denoised, thresh, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    Pix* pix = pixCreate(thresh.cols, thresh.rows, 8);
    for (int y = 0; y < thresh.rows; ++y) {
        for (int x = 0; x < thresh.cols; ++x) {
            pixSetPixel(pix, x, y, thresh.at<uchar>(y, x));
        }
    }
    tesseract::TessBaseAPI tess;
    tess.Init(tessPath, "eng", tesseract::OEM_LSTM_ONLY);
    tess.SetImage(pix);
    char* outText = tess.GetUTF8Text();
    std::string result(outText);
    tess.End();
    pixDestroy(&pix);
    delete[] outText;
    env->ReleaseStringUTFChars(imagePath, imgPath);
    env->ReleaseStringUTFChars(trainedDataPath, tessPath);
    return env->NewStringUTF(result.c_str());
}

extern "C" JNIEXPORT void JNICALL
Java_com_jgdigital_ocr_OCRNative_saveResults(JNIEnv* env, jobject, jobjectArray results, jstring outputFolder) {
    // Implement saving to .xlsx and .docx using open-source C++ libraries (e.g., libxlsxwriter, docxwriter)
    // ...stub...
}
