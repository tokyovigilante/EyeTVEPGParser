
#include "EyeTVPluginDefs.h"

#import <Cocoa/Cocoa.h>
#import "TTMPEGExporter.h"

#define MAX_PIDS			256
#define MAX_ACTIVE_PIDS		256
#define MAX_DEVICES			16

#pragma push
#pragma pack(1)
#pragma pop


#define TVDBG
//#define TVDBG_VERBOSE


/**************************************************************************************
*
*	Structure for holding Information on devices
*
*	(more Information about typedefs and definitions can be found in 'EyeTVPluginDefs.h')
*
**************************************************************************************/
typedef struct {
	EyeTVPluginDeviceID			deviceID;
	EyeTVPluginDeviceType		deviceType;
	
	long						headendID;
	long						transponderID;
	long						serviceID;
									
	long						pidsCount;
	unsigned long				pids[MAX_PIDS];
	
	EyeTVPluginPIDInfo			activePIDs[MAX_ACTIVE_PIDS];
	long						activePIDsCount;
	
} DeviceInfo;


/**************************************************************************************
*
*	Structure for holding global data
*
*	(more Information about typedefs and definitions can be found in 'EyeTVPluginDefs.h')
*
**************************************************************************************/
typedef struct {
	EyeTVPluginCallbackProc			callback;
	long							deviceCount;
	DeviceInfo						devices[MAX_DEVICES];
	TTMPEGExporter					*exporter;
	NSAutoreleasePool				*pool;
	/* Structure to hold current active service */
    EyeTVPluginDeviceID				activeDeviceID;
	long							activePIDsCount; 
    EyeTVPluginPIDInfo				activePIDs[MAX_ACTIVE_PIDS];

} EyeTVEPGParserGlobals;


#pragma mark -
#pragma mark Callback functions
	

/******************************************************************************************
*	EyeTVEPGParserInitialize,
*
*	- **globals : Pointer to the globals 
*	- apiVersion : Version of the API
*
*	Description:
*		Initializes the plug-in.
*
******************************************************************************************/
static long EyeTVEPGParserInitialize(EyeTVEPGParserGlobals** globals, long apiVersion, EyeTVPluginCallbackProc callback)
{
#ifdef TVDBG
	fprintf(stderr, "EyeTVEPGParser: Initialize\n");
#endif
	
    long result = 0;
    
    *globals = (EyeTVEPGParserGlobals *)calloc(1,sizeof(EyeTVEPGParserGlobals));
    ( *globals )->callback = callback;
	(*globals)->pool = [[NSAutoreleasePool alloc] init];

    return result;
}



/******************************************************************************************
*	EyeTVEPGParserTerminate,
*
*	- *globals : the globals
*
*	Description: 
*		Called when the plug-in should terminate
*
******************************************************************************************/
static long EyeTVEPGParserTerminate(EyeTVEPGParserGlobals *globals)
{
#ifdef TVDBG
	fprintf(stderr, "EyeTVEPGParser: Terminate\n");
#endif
	long result = 0;
	[globals->pool drain];
    free( globals );
    return result;
	
}





/******************************************************************************************
*	EyeTVEPGParserGetInformation,
*
*	- *globals : the globals
*	- *outVersion :  Version of the plug-in API
*	- *outName : Name of the plug-in
*	- *outDescription : Description of the plug-in
*
*	Description:
*		EyeTV asks for Information about your plug-in
*
*
******************************************************************************************/
static long EyeTVEPGParserGetInformation(EyeTVEPGParserGlobals *globals, long* outAPIVersion, char* outName, char *outDescription)
{
#ifdef TVDBG
	fprintf(stderr, "EyeTVEPGParser: GetInfo\n");
#endif
	long		result = 0;
	
	if (globals) 
	{
		if (outAPIVersion)
		{
			*outAPIVersion = EYETV_PLUGIN_API_VERSION;
		}
		
		if (outName)
		{
			char* name = "EyeTVEPGParser";
			strcpy(&outName[0], name);
		}
		
		if (outDescription)
		{
			char* desc = "EyeTV MHEG-5 XML EPG Parser";
			strcpy(&outDescription[0], desc);
		}
	}
#ifdef TVDBG
	fprintf(stderr, "%s - %s (API Version %li)\n", outName, outDescription, *outAPIVersion);
#endif
	return result;
}

/******************************************************************************************
*	EyeTVEPGParserDeviceAdded,
*
*	- *globals : the globals
*	- deviceID : ID of the added device (see 'EyeTVPluginDefs.h')
*	- deviceType : Type of added device (see 'EyeTVPluginDefs.h')
*	
*	Description: 
*		Called if a device is added. 
*
*
******************************************************************************************/
static long EyeTVEPGParserDeviceAdded(EyeTVEPGParserGlobals *globals, EyeTVPluginDeviceID deviceID, EyeTVPluginDeviceType deviceType)
{
#ifdef TVDBG
	fprintf(stderr, "EyeTVEPGParser: Device with type %i and ID %i added\n", (int)deviceType, (int)deviceID);;
#endif
    
    long result = 0;
	
    return result;
	
}




/******************************************************************************************
*	EyeTVEPGParserDeviceRemoved,
*
*	- *globals : the globals
*	- deviceID : The Device Identifier  
*
*	Description:
*		Called, if a device is removed. 
*
******************************************************************************************/
static long EyeTVEPGParserDeviceRemoved(EyeTVEPGParserGlobals *globals, EyeTVPluginDeviceID deviceID)
{
#ifdef TVDBG
	fprintf(stderr, "EyeTVEPGParser: DeviceRemoved\n");
#endif
	long result = 0;
	
	[globals->exporter release];
	
    return result;
	
}





/******************************************************************************************
*	EyeTVEPGParserPacketsArrived,
*
*	- *globals : The plug-in Globals
*	- deviceID : Id of the active Device
*	- **packets : Pointer to the data
*	- packetsCount : number of packets
*
*	Description:
*		This function is called, whenever packets are received by EyeTV. For reasons of
*		performance, the data is the original data, not a copy. That means, EyeTV waits
*		until this method is finished. Therefore all in this method should be as fast as possible.
*
*
******************************************************************************************/
static long EyeTVEPGParserPacketsArrived(EyeTVEPGParserGlobals *globals, EyeTVPluginDeviceID deviceID, long **packets, long packetsCount)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if(globals && deviceID == globals->activeDeviceID) 
    {
       	//long pidCount = globals->activePIDsCount;
		//if(pidCount)
		//void *packetBuffer = malloc(sizeof(TransportStreamPacket) * packetsCount);
		[globals->exporter writePackets:*packets count:packetsCount];
		return 0;
		{
			//memcpy (packetBuffer, *packets, sizeof(TransportStreamPacket) * packetsCount));
			while(packetsCount)
			{
				/* apply PID filtering, only PIDs in active service for device are sent through */
				//long pid = ntohl(**packets)>>8 & 0x1FFFL;
				/* ignore NULL packets */
				//if( 0x1FFFL != pid )
				{
					//for (SInt32 i=0; i<pidCount; ++i)
					{
						//if( globals->activePIDs[i].pid == pid )
						{
							{
								/* copy packet in our buffer */
								//if (packetAdded < 0)
								{
								//	return 0;
								}
							}
							//if( i > 0 )
							{
								/* if we assume that consecutive packets would have the same PID in most cases,
								 it would therefore speed up filtering to reorder activePIDs list based on pid
								 occurrences */
								//EyeTVPluginPIDInfo swap = globals->activePIDs[i];
								//do
								{
								//	register int c = i--;
								//	globals->activePIDs[c] = globals->activePIDs[i];
								}
								//while( i );
								//globals->activePIDs[i] = swap;
							}
							// disabled - don't block EyeTV from parsing packets - will interrupt stream
#if 0
							if( pid && globals->activePIDs[0].pidType != kEyeTVPIDType_PMT )
							{
								/* to save on CPU, prevent EyeTV from mirroring that program by blocking video & audio packets
								 by changing all packets but PAT and PMT to NULL PID */
#if defined(WORDS_BIGENDIAN)
							//	**packets |= 0x001FFF00L;
#else
							//	**packets |= 0x00FFF800L;
#endif
							}
#endif
							/* done filtering on this packet, move on to next packet */
							++packets;
							packetsCount--;
						//	break;
						}
					}
				}
				
			}
			
            
        }
    }
	[pool release];
    return 0;
}

			


/******************************************************************************************
*	EyeTVEPGParserServiceChanged,
*
*	- *globals		: The plug-in Globals
*	- deviceID		: Identifies the active Device
*   - headendID		: The HeadendID, for e300 it's the orbital position of the satelite in 
*					  tenth degrees east
*   - transponderID : The Frequency in kHz
*   - serviceID		: original ServiceID from the DVB-Stream (e300, e400)
*	- pidList		: List of active PIDs	
*
*	Description:
*		Whenever a service changes, this function is called. Service-related plug-in data
*		should be updated here.
*
*
******************************************************************************************/
static long EyeTVEPGParserServiceChanged(EyeTVEPGParserGlobals *globals, 
											EyeTVPluginDeviceID deviceID, 
											long headendID, 
											long transponderID, 
											long serviceID, 
											EyeTVPluginPIDInfo *pidList, 
											long pidsCount)
{
	long		result = 0;
	int			i;
#ifdef TVDBG
	fprintf(stderr, "EyeTVEPGParser: ServiceChanged\n");
#endif
	
	if ([globals->exporter hasValidTSStream])
	{
		NSLog(@"Closing active stream");
		[globals->exporter closeTSStream];
	}
	
	if (globals) 
	{
		// if DeviceID has changed update globals - i think this is an API bug
		if (globals->deviceCount == 1 && globals->devices[0].deviceID != deviceID)
		{
#ifdef TVDBG
			fprintf(stderr, "EyeTVEPGParser: Device ID changed, updating (%li -> %li)\n", (long)globals->devices[0].deviceID, (long)deviceID);
#endif
			globals->devices[0].deviceID = deviceID;
		}
		
		printf("DeviceID: %ld, ", (long)deviceID);
		printf("HeadendID: %ld, ", headendID);
		printf("TransponderID: %ld, ", transponderID);
		printf("ServiceID: %ld\n\n", serviceID);
		
		globals->activeDeviceID = deviceID;
		globals->activePIDsCount = pidsCount;
		
		/* need active PIDs for packet filtering */
		for( i = 0; i < pidsCount; i++ )
		{
			globals->activePIDs[i] = pidList[i];
			printf("Active PID: %ld, type: %ld\n", pidList[i].pid, pidList[i].pidType);
		}	
		// rerun exporter for new channel
		if (!globals->exporter)
		{
			globals->exporter = [[TTMPEGExporter alloc] init];
		}
		[globals->exporter updateEPG:nil];
	}
	
	return result;
}


extern "C" {
	
#pragma mark -
#pragma mark Dispatcher
/******************************************************************************************
*	EyeTVPluginDispatcher,
*
*	- selector : See 'EyeTVPluginDefs.h'
*	- *refCon :  The RefCon to the plug-in-related Data
*	- deviceID : Identifies the Device
*	- params : Parameters for functioncall
*
*	Description:
*		This function is a part of the interface for the communication with EyeTV. If something
*		happens, EyeTV thinks, your plug-in should know of, it calls this function with the 
*		corresponding selector. For more Information see 'EyeTVPluginDefs.h' and the 
*		About the EyeTV Plug-In SDK document.
*
*
******************************************************************************************/
#pragma export on

long EyeTVPluginDispatcher (EyeTVPluginParams* params)
{
	long		result = 0;

	switch (params->selector) 
	{
		case kEyeTVPluginSelector_Initialize:
			result = EyeTVEPGParserInitialize((EyeTVEPGParserGlobals**)params->refCon, 
									params->initialize.apiVersion, params->initialize.callback);
			break;
			
		case kEyeTVPluginSelector_Terminate:
			result = EyeTVEPGParserTerminate((EyeTVEPGParserGlobals*)params->refCon);
			break;

		case kEyeTVPluginSelector_GetInfo:
			result = EyeTVEPGParserGetInformation((EyeTVEPGParserGlobals*)params->refCon, 
									params->info.pluginAPIVersion, params->info.pluginName, params->info.description);
			break;

		case kEyeTVPluginSelector_DeviceAdded:
			result = EyeTVEPGParserDeviceAdded((EyeTVEPGParserGlobals*)params->refCon, 
									params->deviceID, params->deviceAdded.deviceType);
			break;
		
		case kEyeTVPluginSelector_DeviceRemoved:
			result = EyeTVEPGParserDeviceRemoved((EyeTVEPGParserGlobals*)params->refCon, params->deviceID);
			break;

		case kEyeTVPluginSelector_PacketsArrived:
			result = EyeTVEPGParserPacketsArrived((EyeTVEPGParserGlobals*)params->refCon, params->deviceID, 
									params->packetsArrived.packets, params->packetsArrived.packetCount);
			break;

		case kEyeTVPluginSelector_ServiceChanged:
			result = EyeTVEPGParserServiceChanged((EyeTVEPGParserGlobals*)params->refCon, 
									params->deviceID, params->serviceChanged.headendID, 
									params->serviceChanged.transponderID, params->serviceChanged.serviceID, 
									params->serviceChanged.pidList, params->serviceChanged.pidCount);
			break;
	}
	
	return result;
}

};

