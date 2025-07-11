cmake_minimum_required(VERSION 3.10.2)
project(ocr)

add_library(ocr SHARED ocr.cpp)

find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

include_directories(/path/to/tesseract/include)
include_directories(/path/to/leptonica/include)

find_library(log-lib log)

# Link Tesseract, Leptonica, OpenCV
set(TESSERACT_LIB /path/to/tesseract/libtesseract.so)
set(LEPTONICA_LIB /path/to/leptonica/liblept.so)
set(OPENCV_LIBS ${OpenCV_LIBS})

target_link_libraries(ocr ${log-lib} ${TESSERACT_LIB} ${LEPTONICA_LIB} ${OPENCV_LIBS})
