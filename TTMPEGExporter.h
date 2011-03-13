//
//  TTMPEGExporter.h
//  EyeTVEPGParser
//
//  Created by Ryan Walklin on 9/03/11.
//  Copyright 2011 Test Toast. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/**************************************************************************************
 *
 *	Structure for TS-Packets
 *
 **************************************************************************************/
typedef struct {
	unsigned long			sync_byte : 8,
	transport_error_indicator : 1,
	payload_unit_start_indicator : 1,
	transport_priority : 1,
	PID : 13,
	transport_scrambling_control : 2,
	adaptation_field_control : 2,
	continuity_counter : 4;
	
	unsigned char			data[188-4];
	
} TransportStreamPacket;

@interface TTMPEGExporter : NSObject {
	
	NSFileHandle *_streamHandle;
	
	CFAbsoluteTime _firstPacketTime;
	BOOL _wantPackets;
	dispatch_queue_t _streamWriteQueue;
	
	NSTimer *_updateTimer;
}

+(TTMPEGExporter *)sharedTTMPEGExporter;

// returns YES on successful stream creation
-(BOOL)createTSStream:(NSURL *)streamURL;

// returns YES if stream open for writing packets
-(BOOL)hasValidTSStream;

// returns YES if packet written successfully
-(BOOL)writePacket:(void *)packet;

// returns true if stream closed without errors
-(BOOL)closeTSStream;

@end
