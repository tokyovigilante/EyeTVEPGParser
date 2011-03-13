//
//  TTMPEGExporter.m
//  EyeTVEPGParser
//
//  Created by Ryan Walklin on 9/03/11.
//  Copyright 2011 Test Toast. All rights reserved.
//

#import "TTMPEGExporter.h"

#import "SynthesizeSingleton.h"

@implementation TTMPEGExporter

SYNTHESIZE_SINGLETON_FOR_CLASS(TTMPEGExporter)

-(id)init
{
	self = [super init];
	if (self)
	{
		_streamHandle = nil;
		
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:3600
														target:self 
													  selector:@selector(updateEPG:) 
													  userInfo:nil
													   repeats:YES];
		_streamWriteQueue = dispatch_queue_create(NULL, NULL);
		_wantPackets = NO;
		
	}
	return self;
}

-(void)updateEPG:(NSTimer *)timer
{
	dispatch_async(_streamWriteQueue, ^{
		
		 if (![self createTSStream:[[NSURL alloc] initWithString:@"/Volumes/Home/ryan/epg.ts"]])
		 {
			 return;
		 }
		_firstPacketTime = CFAbsoluteTimeGetCurrent();
		_wantPackets = YES;
	});

}
						
-(BOOL)createTSStream:(NSURL *)streamURL
{
	if (!streamURL || ![streamURL isFileURL])
	{
		NSLog(@"No/invalid stream URL");
		return NO;
	}
	NSError *err = nil;
	@try 
	{
		_streamHandle = [NSFileHandle fileHandleForWritingToURL:streamURL error:&err];

	}
	@catch (NSException * e) 
	{
		NSLog(@"Exception while creating file handle: %@", [e description]);
		_streamHandle = nil;
		return NO;
	}
	@finally 
	{
		if (_streamHandle) 
		{
			 NSLog(@"Stream handle creation failed with error: %@", [err localizedDescription]);
			 return NO;
		}
	}
	return (_streamHandle != nil);
}
	
-(BOOL)hasValidTSStream
{
	return (_streamHandle != nil);
}
			  

-(BOOL)writePacket:(void *)packet
{
	if (!_streamHandle || !packet || !_wantPackets)
	{
		return NO;
	}
	
	NSData *packetData = [[NSData alloc] initWithBytes:packet length:sizeof(TransportStreamPacket)];

	dispatch_async(_streamWriteQueue, ^{
		@try 
		{
			[_streamHandle writeData:packetData];
			[packetData release];
		}
		@catch (NSException * e) 
		{
			NSLog(@"Write to stream failed: %@", [e description]);
			return;
		}		
	});
	
	return YES;
}


-(BOOL)closeTSStream
{
	[_streamHandle closeFile];
	_streamHandle = nil;
	return YES;
}

-(void)dealloc
{
	dispatch_release(_streamWriteQueue);
	
	[super dealloc];
}

@end
