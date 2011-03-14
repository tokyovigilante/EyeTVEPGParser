
#import <Foundation/Foundation.h>
#import "TTTransportStreamParser.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSError *err = nil;
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:@"/Volumes/Home/ryan/Desktop/test.ts"] error:&err];
	if (!fileHandle)
	{
		NSLog(@"%@ - %@:", [err localizedDescription], [err localizedFailureReason]);
	}
	UInt16 dsmCCPID = [TTTransportStreamParser hbStreamOpen:fileHandle];
	[pool drain];
    return 0;
}
