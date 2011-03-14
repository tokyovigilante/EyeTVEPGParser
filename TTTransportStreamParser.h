/*
 *  TTTransportStreamParser.h
 *  EyeTVEPGParser
 *
 *  Created by Ryan Walklin on 14/03/11.
 *  Copyright 2011 Test Toast. All rights reserved.
 *
 * Based on heavily modified stream.c from Handbrake - www.handbrake.fr.  Licenced under GPL 2.0.
 */

#import <Foundation/Foundation.h>

@interface TTTransportStreamParser : NSObject
{

}

+(NSMutableDictionary *)parseDSMCC:(NSFileHandle *)fileHandle;

@end
