//
//  TTMPEGExporter.m
//  EyeTVEPGParser
//
//  Created by Ryan Walklin on 9/03/11.
//  Copyright 2011 Test Toast. All rights reserved.
//

#import "TTMPEGExporter.h"

#import "TTTransportStreamParser.h"

@interface TTMPEGExporter (Private)

-(NSURL *)applicationSupportFolderURL;

@end

@implementation TTMPEGExporter

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
		_videoPID = 0;
		
	}
	return self;
}

-(UInt16)videoPID
{
	return _videoPID;
}


-(void)updateEPG:(NSTimer *)timer
{
	NSLog(@"Running EPG update");
	if ([self hasValidTSStream])
	{
		NSLog(@"Closing previous EPG dump");
		[self closeTSStream];
	}
	_firstPacketTime = CFAbsoluteTimeGetCurrent();
	_wantPackets = YES;
	_packetCount = 0;
}
							
-(BOOL)hasValidTSStream
{
	return (_streamHandle != nil);
}
			  

-(BOOL)writePackets:(void *)packets count:(UInt32)count
{
	if (!packets || count == 0 || !_wantPackets)
	{
		return NO;
	}
	
	NSData *packetData = [[NSData alloc] initWithBytes:packets length:count];

	//dispatch_async(_streamWriteQueue, ^{
		
		NSURL *streamURL = [[self applicationSupportFolderURL] URLByAppendingPathComponent:@"epg.ts"];
		NSError *err = nil;
		@try 
		{
			if (!_streamHandle)
			{
				// NSFileHandle utils don't like opening new files as streams, so write the first packet directly to disk
				if (![packetData writeToURL:streamURL options:0 error:&err])
				{
					NSLog(@"Packet write failed: %@", [err localizedDescription]);
				}
				_streamHandle = [[NSFileHandle fileHandleForUpdatingURL:streamURL error:&err] retain];
				[_streamHandle seekToEndOfFile];
				NSLog(@"Started writing EPG dump to %@", [streamURL path]);
			}
			else 
			{
				[_streamHandle writeData:packetData];
			}
			_packetCount+= count / sizeof(TransportStreamPacket);
			if (_packetCount % 1000 == 0)
			{
				NSLog(@"%llu packets written", _packetCount);
			}
			
		}
		@catch (NSException * e) 
		{
			NSLog(@"Exception while creating file handle: %@", [e description]);
			[self closeTSStream];
		}
		@finally 
		{
			[packetData release];
		}		
		if (!_streamHandle)
		{
			return;
		}
		CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
		if (now - _firstPacketTime > 65)
		{
			// should be ok to parse PIDs
			[_streamHandle synchronizeFile];
			[_streamHandle seekToFileOffset:0];
			NSDictionary *pidDict = [TTTransportStreamParser parseDSMCC:_streamHandle];
			[_streamHandle seekToEndOfFile];
			if (!pidDict)
			{
				NSLog(@"Error retrieving PIDs from transport stream");
				[self closeTSStream];
				_wantPackets = NO;
				_firstPacketTime = now;
				return;
			}
			_dsmccPID = [[pidDict objectForKey:@"dsmccPID"] shortValue];
			_videoPID = [[pidDict objectForKey:@"dsmccPID"] shortValue];
			[pidDict release];
		}
		
		if (now -_firstPacketTime > 65)
		{
			// parse EPG
			if (_dsmccPID == 0)
			{
				NSLog(@"No DSM-CC object found in carousel, cannot parse EPG");
				return;
			}
			// we have enough packets
			_wantPackets = NO;
			NSLog(@"Stored %llu packets at %@", _packetCount, [streamURL path]);
			[_streamHandle synchronizeFile];
			[self closeTSStream];
			
			// generate config for EPG Collector
			NSURL *iniURL = [[self applicationSupportFolderURL] URLByAppendingPathComponent:@"EyeTVMHEG5.ini"];
			NSString *iniString = [NSString stringWithFormat:@"Output=%@/TVGuide.xml\n\n"
								   "TSFile=%@/epg.ts\nOption=MHEG5PID-%u\n\n"
								   "ScanningFrequency=12456000,MHEG5\n", 
								   [[self applicationSupportFolderURL] path], 
								   [[self applicationSupportFolderURL] path], 
								   _dsmccPID];
			NSError *err = nil;
			if (![iniString writeToURL:iniURL 
							atomically:YES
							  encoding:NSUTF8StringEncoding
								 error:&err])
			{
				NSLog(@"Failed to write EPG Collector configuration - %@", [err localizedDescription]);
				return;
			}
			@try 
			{
				NSTask *monoTask = [[NSTask alloc] init];
				[monoTask setLaunchPath:@"/usr/bin/mono"];
				[monoTask setArguments:[NSArray arrayWithObjects:@"/Library/Application Support/EyeTV/Plugins/EyeTVEPGParser.bundle/Contents/Resources/EPGCollector/EPGCollector.exe",
																	[NSString stringWithFormat:@"/ini=%@", 
																	 [iniURL path]], nil]];
				[monoTask launch];
				[monoTask waitUntilExit];
				
				if ([monoTask terminationStatus] != 0)
				{
					NSLog(@"EPG parse from TS failed");
				}
			}
			@catch (NSException * e) 
			{
				NSLog(@"Exception while launching EPG Collector: %@", [e description]);
			}
			@finally 
			{
				// remove TS
				if (![[NSFileManager defaultManager] removeItemAtURL:[[self applicationSupportFolderURL] URLByAppendingPathComponent:@"epg.ts"] error:&err])
				{
					NSLog(@"Failed to remove epg TS dump - %@", [err localizedDescription]);
				}
			}
			
			// load XML into EyeTV
			
			@try 
			{
				NSTask *importTask = [[NSTask alloc] init];
				[importTask setLaunchPath:@"/usr/bin/open"];
				[importTask setArguments:[NSArray arrayWithObjects:@"-ga",
										  @"/Applications/EyeTV.app",
										  [[[self applicationSupportFolderURL] URLByAppendingPathComponent:@"TVGuide.xml"] path],
										  nil]];
				[importTask launch];
				//[importTask waitUntilExit];
				
				//if ([importTask terminationStatus] != 0)
				{
				//	NSLog(@"Import into EyeTV failed");
				}
			}
			@catch (NSException * e) 
			{
				NSLog(@"Exception while running EyeTV import: %@", [e description]);
			}
			@finally 
			{
				
			}
		}
	//});
	
	return YES;
}


-(BOOL)closeTSStream
{
	NSLog(@"Closing TS Stream");
	if (_streamHandle)
	{
		[_streamHandle closeFile];
	}
	_streamHandle = nil;
	_wantPackets = NO;
	_packetCount = 0;
	return YES;
}

-(void)dealloc
{
	dispatch_release(_streamWriteQueue);
	
	[_updateTimer invalidate];
	[_updateTimer release];
	
	[super dealloc];
}

-(NSURL *)applicationSupportFolderURL
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *appSupportPath = [basePath stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
	NSURL *appSupportURL = [NSURL fileURLWithPath:appSupportPath];
	
	if (![appSupportURL checkResourceIsReachableAndReturnError:nil])
	{
		// create folder if it doesn't exist
		NSError *err = nil;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:appSupportPath withIntermediateDirectories:YES attributes:nil error:&err])
		{
			NSLog(@"Failed to create Application Support directory: %@", [err localizedDescription]);
			return nil;
		}
	}
	return appSupportURL; 
}

@end
