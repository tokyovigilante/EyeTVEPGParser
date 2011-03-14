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
	UInt64 _packetCount;
	UInt16 _dsmccPID, _videoPID;
	dispatch_queue_t _streamWriteQueue;
	
	NSTimer *_updateTimer;
}

// if >0, video PID for current stream
-(UInt16)videoPID;

// Updates EPG based on DSM-CC carousel for current channel
-(void)updateEPG:(NSTimer *)timer;

// returns YES if stream open for writing packets
-(BOOL)hasValidTSStream;

// returns YES if packet written successfully
-(BOOL)writePackets:(void *)packets count:(UInt32)count;

// returns true if stream closed without errors
-(BOOL)closeTSStream;

@end
