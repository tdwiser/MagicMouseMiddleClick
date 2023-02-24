#include <unistd.h> 
#import <Foundation/Foundation.h> 
#include <CoreFoundation/CoreFoundation.h> 
#include <ApplicationServices/ApplicationServices.h> 

/* 
Reverse engineering of MultitouchSupport.framework by Costantino Pistagna <valvoline@gmail.com> 

Compile with: 

gcc -o <outfile> <infile.m> -F/System/Library/PrivateFrameworks -framework MultitouchSupport \ 
-framework CoreFoundation -framework ApplicationServices -lobjc 

*/ 

/* 
These structs are required, in order to handle some parameters returned from the 
MultiTouchSupport.framework 
*/ 
typedef struct { 
float x; 
float y; 
}mtPoint; 

typedef struct { 
mtPoint position; 
mtPoint velocity; 
}mtReadout; 

/* 
Some reversed engineered informations from MultiTouchSupport.framework 
*/ 
typedef struct 
{ 
int frame; //the current frame 
double timestamp; //event timestamp 
int identifier; //identifier guaranteed unique for life of touch per device 
int state; //the current state (not sure what the values mean) 
int unknown1; //no idea what this does 
int unknown2; //no idea what this does either 
mtReadout normalized; //the normalized position and vector of the touch (0,0 to 1,1) 
float size; //the size of the touch (the area of your finger being tracked) 
int unknown3; //no idea what this does 
float angle; //the angle of the touch -| 
float majorAxis; //the major axis of the touch -|-- an ellipsoid. you can track the angle of each finger! 
float minorAxis; //the minor axis of the touch -| 
mtReadout unknown4; //not sure what this is for 
int unknown5[2]; //no clue 
float unknown6; //no clue 
}Touch; 

//a reference pointer for the multitouch device 
typedef void *MTDeviceRef; 

//the prototype for the callback function 
typedef int (*MTContactCallbackFunction)(int,Touch*,int,double,int); 

//returns a pointer to the default device (the trackpad?) 
MTDeviceRef MTDeviceCreateDefault(); 

//returns a CFMutableArrayRef array of all multitouch devices 
CFMutableArrayRef MTDeviceCreateList(void); 

//registers a device's frame callback to your callback function 
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction); 

//start sending events 
void MTDeviceStart(MTDeviceRef, int); 

//just output debug info. use it to see all the raw infos dumped to screen
void printDebugInfos(int nFingers, Touch *data) {
int i;
for (i=0; i<nFingers; i++) {
Touch *f = &data[i];
printf("Finger: %d, frame: %d, timestamp: %f, ID: %d, state: %d, PosX: %f, PosY: %f, VelX: %f, VelY: %f, Angle: %f, MajorAxis: %f, MinorAxis: %f\n", i,
f->frame,
f->timestamp,
f->identifier,
f->state,
f->normalized.position.x,
f->normalized.position.y,
f->normalized.velocity.x,
f->normalized.velocity.y,
f->angle,
f->majorAxis,
f->minorAxis);
}
}

int threeDown = 0; // store whether we are mid-click or not

int touchCallback(int device, Touch *data, int nFingers, double timestamp, int frame) { 
	if(nFingers < 3) { return 0; }
	Touch *f1 = &data[0];
	Touch *f2 = &data[1];
	Touch *f3 = &data[2];
	if(threeDown && (f1->state == 7 || f2->state == 7 || f3->state == 7)) { // state 7 = finger lifted
		threeDown = 0;
		CGEventRef event = CGEventCreate(NULL); // grabs current pointer location
		CGEventPost(kCGHIDEventTap, CGEventCreateMouseEvent(NULL, kCGEventOtherMouseUp, CGEventGetLocation(event), kCGMouseButtonCenter));
		CFRelease(event);
		return 1;
	} else if (!threeDown) {
		// check for two down (state 4) and one just pressed (state 3)
		int fours = 0;
		int thirdFinger = -1;
		for(int i = 0; i < 3; i++) {
			if(data[i].state == 4) { ++fours; }
			else if(data[i].state == 3) { thirdFinger = i; }
		}
		if(fours == 2 && thirdFinger != -1) {
			float min = fmin(fmin(f1->normalized.position.x, f2->normalized.position.x), f3->normalized.position.x);
			float max = fmax(fmax(f1->normalized.position.x, f2->normalized.position.x), f3->normalized.position.x);
			if(data[thirdFinger].normalized.position.x == min || data[thirdFinger].normalized.position.x == max) {
				return 0;
			}
			threeDown = 1;
			CGEventRef event = CGEventCreate(NULL);
			CGEventPost(kCGHIDEventTap, CGEventCreateMouseEvent(NULL, kCGEventOtherMouseDown, CGEventGetLocation(event), kCGMouseButtonCenter));
			CFRelease(event);
			return 1;
		}
	}
	return 0;
}

int main(void) { 
	int i;
	NSMutableArray* deviceList = (NSMutableArray*)MTDeviceCreateList(); //grab our device list 
	for(i = 0; i<[deviceList count]; i++) { //iterate available devices 
		MTRegisterContactFrameCallback([deviceList objectAtIndex:i], touchCallback); //assign callback for device 
		MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events 
	}
	printf("Ctrl-C to quit\n"); 
	sleep(-1);
	return 0;
}
