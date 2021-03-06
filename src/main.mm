#include "ofMain.h"
#include "ofApp.h"
#include "GlobalTypes.h"
#include "NKAppDelegate.h"
#include <ofxNodeKitten.h>

int main(int argc, char * argv[])
{
#ifdef OF_BACKED
    ofAppiOSWindow * window = new ofAppiOSWindow();
    
    //window->enableRendererES2();
    window->enableRetina();
    window->enableDepthBuffer();
    //window->enableAntiAliasing(2);
    
    ofSetupOpenGL(1024,768,OF_FULLSCREEN);			// <-------- setup the GL context
    
    ofRunApp(new ofApp());

#else 
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([NKAppDelegate class]));
        }
#endif
}
