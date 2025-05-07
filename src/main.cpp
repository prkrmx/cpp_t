#include <iostream>

#include <opencv2/core.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

using namespace cv;
using namespace std;


string type2str(int type) {
    string r;
  
    uchar depth = type & CV_MAT_DEPTH_MASK;
    uchar chans = 1 + (type >> CV_CN_SHIFT);
  
    switch ( depth ) {
      case CV_8U:  r = "8U"; break;
      case CV_8S:  r = "8S"; break;
      case CV_16U: r = "16U"; break;
      case CV_16S: r = "16S"; break;
      case CV_32S: r = "32S"; break;
      case CV_32F: r = "32F"; break;
      case CV_64F: r = "64F"; break;
      default:     r = "User"; break;
    }
  
    r += "C";
    r += (chans+'0');
  
    return r;
  }

int main(int argc, char *argv[])
{
    Mat frame;
    VideoCapture cap;
    int deviceID = 0;             // 0 = open default camera

    if(argc > 1)
        deviceID = atoi(argv[1]);

    // std::string deviceID = "rtsp://10.0.0.32:554/test";        // 0 = open default camera
    // int apiID = cv::CAP_ANY; // 0 = autodetect default API
    // cap.open(deviceID, apiID);

    cap.open(deviceID);

    if (!cap.isOpened())
    {
        cerr << "ERROR! Unable to open camera\n";
        return -1;
    }
    //--- GRAB AND WRITE LOOP
    cout << "Start grabbing" << endl
         << "Press any key to terminate" << endl;
    bool print = true;
    for (;;)
    {
        // wait for a new frame from camera and store it into 'frame'
        cap.read(frame);
        // check if we succeeded
        if (frame.empty())
        {
            cerr << "ERROR! blank frame grabbed\n";
            break;
        }
        // show live and wait for a key with timeout long enough to show images
        if (print)
        {
            string ty =  type2str( frame.type() );
            printf("Frame: %s %dx%d \n", ty.c_str(), frame.cols, frame.rows );

            print = false;
        }
        // int w = frame.cols;
        // int h = frame.rows;
        // int s = 40;

        // MyLine(frame, Point(w / 2, h / 2 - s / 2), Point(w / 2, h / 2 + s / 2));
        // MyLine(frame, Point(w / 2 - s / 2, h / 2), Point(w / 2 + s / 2, h / 2));
        imshow("Live", frame);
        if (waitKey(5) >= 0)
            break;
    }
    // the camera will be deinitialized automatically in VideoCapture destructor
    return 0;
}
