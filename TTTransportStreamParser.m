/* $Id$

   This file is part of the HandBrake source code.
   Homepage: <http://handbrake.fr/>.
   It may be used under the terms of the GNU General Public License. */

#import "TTTransportStreamParser.h"

// From HB internal.h
enum
{
    WORK_SYNC_VIDEO = 1,
    WORK_SYNC_AUDIO,
    WORK_DECMPEG2,
    WORK_DECCC608,
    WORK_DECVOBSUB,
    WORK_DECSRTSUB,
    WORK_ENCVOBSUB,
    WORK_RENDER,
    WORK_ENCAVCODEC,
    WORK_ENCX264,
    WORK_ENCTHEORA,
    WORK_DECA52,
    WORK_DECDCA,
    WORK_DECAVCODEC,
    WORK_DECAVCODECV,
    WORK_DECAVCODECVI,
    WORK_DECAVCODECAI,
    WORK_DECLPCM,
    WORK_ENCFAAC,
    WORK_ENCLAME,
    WORK_ENCVORBIS,
    WORK_ENC_CA_AAC,
    WORK_MUX
};

// from HB common.h

/* Audio starts here */
/* Audio Codecs */
#define HB_ACODEC_MASK   0x00FF00
#define HB_ACODEC_FAAC   0x000100
#define HB_ACODEC_LAME   0x000200
#define HB_ACODEC_VORBIS 0x000400
#define HB_ACODEC_AC3    0x000800
#define HB_ACODEC_MPGA   0x001000
#define HB_ACODEC_LPCM   0x002000
#define HB_ACODEC_DCA    0x004000
#define HB_ACODEC_FFMPEG 0x008000
#define HB_ACODEC_CA_AAC 0x010000

// from ffmpeg avcodec.h

enum CodecID {
    CODEC_ID_NONE,
	
    /* video codecs */
    CODEC_ID_MPEG1VIDEO,
    CODEC_ID_MPEG2VIDEO, ///< preferred ID for MPEG-1/2 video decoding
    CODEC_ID_MPEG2VIDEO_XVMC,
    CODEC_ID_H261,
    CODEC_ID_H263,
    CODEC_ID_RV10,
    CODEC_ID_RV20,
    CODEC_ID_MJPEG,
    CODEC_ID_MJPEGB,
    CODEC_ID_LJPEG,
    CODEC_ID_SP5X,
    CODEC_ID_JPEGLS,
    CODEC_ID_MPEG4,
    CODEC_ID_RAWVIDEO,
    CODEC_ID_MSMPEG4V1,
    CODEC_ID_MSMPEG4V2,
    CODEC_ID_MSMPEG4V3,
    CODEC_ID_WMV1,
    CODEC_ID_WMV2,
    CODEC_ID_H263P,
    CODEC_ID_H263I,
    CODEC_ID_FLV1,
    CODEC_ID_SVQ1,
    CODEC_ID_SVQ3,
    CODEC_ID_DVVIDEO,
    CODEC_ID_HUFFYUV,
    CODEC_ID_CYUV,
    CODEC_ID_H264,
    CODEC_ID_INDEO3,
    CODEC_ID_VP3,
    CODEC_ID_THEORA,
    CODEC_ID_ASV1,
    CODEC_ID_ASV2,
    CODEC_ID_FFV1,
    CODEC_ID_4XM,
    CODEC_ID_VCR1,
    CODEC_ID_CLJR,
    CODEC_ID_MDEC,
    CODEC_ID_ROQ,
    CODEC_ID_INTERPLAY_VIDEO,
    CODEC_ID_XAN_WC3,
    CODEC_ID_XAN_WC4,
    CODEC_ID_RPZA,
    CODEC_ID_CINEPAK,
    CODEC_ID_WS_VQA,
    CODEC_ID_MSRLE,
    CODEC_ID_MSVIDEO1,
    CODEC_ID_IDCIN,
    CODEC_ID_8BPS,
    CODEC_ID_SMC,
    CODEC_ID_FLIC,
    CODEC_ID_TRUEMOTION1,
    CODEC_ID_VMDVIDEO,
    CODEC_ID_MSZH,
    CODEC_ID_ZLIB,
    CODEC_ID_QTRLE,
    CODEC_ID_SNOW,
    CODEC_ID_TSCC,
    CODEC_ID_ULTI,
    CODEC_ID_QDRAW,
    CODEC_ID_VIXL,
    CODEC_ID_QPEG,
#if LIBAVCODEC_VERSION_MAJOR < 53
    CODEC_ID_XVID,
#endif
    CODEC_ID_PNG,
    CODEC_ID_PPM,
    CODEC_ID_PBM,
    CODEC_ID_PGM,
    CODEC_ID_PGMYUV,
    CODEC_ID_PAM,
    CODEC_ID_FFVHUFF,
    CODEC_ID_RV30,
    CODEC_ID_RV40,
    CODEC_ID_VC1,
    CODEC_ID_WMV3,
    CODEC_ID_LOCO,
    CODEC_ID_WNV1,
    CODEC_ID_AASC,
    CODEC_ID_INDEO2,
    CODEC_ID_FRAPS,
    CODEC_ID_TRUEMOTION2,
    CODEC_ID_BMP,
    CODEC_ID_CSCD,
    CODEC_ID_MMVIDEO,
    CODEC_ID_ZMBV,
    CODEC_ID_AVS,
    CODEC_ID_SMACKVIDEO,
    CODEC_ID_NUV,
    CODEC_ID_KMVC,
    CODEC_ID_FLASHSV,
    CODEC_ID_CAVS,
    CODEC_ID_JPEG2000,
    CODEC_ID_VMNC,
    CODEC_ID_VP5,
    CODEC_ID_VP6,
    CODEC_ID_VP6F,
    CODEC_ID_TARGA,
    CODEC_ID_DSICINVIDEO,
    CODEC_ID_TIERTEXSEQVIDEO,
    CODEC_ID_TIFF,
    CODEC_ID_GIF,
    CODEC_ID_FFH264,
    CODEC_ID_DXA,
    CODEC_ID_DNXHD,
    CODEC_ID_THP,
    CODEC_ID_SGI,
    CODEC_ID_C93,
    CODEC_ID_BETHSOFTVID,
    CODEC_ID_PTX,
    CODEC_ID_TXD,
    CODEC_ID_VP6A,
    CODEC_ID_AMV,
    CODEC_ID_VB,
    CODEC_ID_PCX,
    CODEC_ID_SUNRAST,
    CODEC_ID_INDEO4,
    CODEC_ID_INDEO5,
    CODEC_ID_MIMIC,
    CODEC_ID_RL2,
    CODEC_ID_8SVX_EXP,
    CODEC_ID_8SVX_FIB,
    CODEC_ID_ESCAPE124,
    CODEC_ID_DIRAC,
    CODEC_ID_BFI,
    CODEC_ID_CMV,
    CODEC_ID_MOTIONPIXELS,
    CODEC_ID_TGV,
    CODEC_ID_TGQ,
    CODEC_ID_TQI,
    CODEC_ID_AURA,
    CODEC_ID_AURA2,
    CODEC_ID_V210X,
    CODEC_ID_TMV,
    CODEC_ID_V210,
    CODEC_ID_DPX,
    CODEC_ID_MAD,
    CODEC_ID_FRWU,
    CODEC_ID_FLASHSV2,
    CODEC_ID_CDGRAPHICS,
    CODEC_ID_R210,
    CODEC_ID_ANM,
    CODEC_ID_BINKVIDEO,
    CODEC_ID_IFF_ILBM,
    CODEC_ID_IFF_BYTERUN1,
    CODEC_ID_KGV1,
    CODEC_ID_YOP,
    CODEC_ID_VP8,
	
    /* various PCM "codecs" */
    CODEC_ID_PCM_S16LE= 0x10000,
    CODEC_ID_PCM_S16BE,
    CODEC_ID_PCM_U16LE,
    CODEC_ID_PCM_U16BE,
    CODEC_ID_PCM_S8,
    CODEC_ID_PCM_U8,
    CODEC_ID_PCM_MULAW,
    CODEC_ID_PCM_ALAW,
    CODEC_ID_PCM_S32LE,
    CODEC_ID_PCM_S32BE,
    CODEC_ID_PCM_U32LE,
    CODEC_ID_PCM_U32BE,
    CODEC_ID_PCM_S24LE,
    CODEC_ID_PCM_S24BE,
    CODEC_ID_PCM_U24LE,
    CODEC_ID_PCM_U24BE,
    CODEC_ID_PCM_S24DAUD,
    CODEC_ID_PCM_ZORK,
    CODEC_ID_PCM_S16LE_PLANAR,
    CODEC_ID_PCM_DVD,
    CODEC_ID_PCM_F32BE,
    CODEC_ID_PCM_F32LE,
    CODEC_ID_PCM_F64BE,
    CODEC_ID_PCM_F64LE,
    CODEC_ID_PCM_BLURAY,
	
    /* various ADPCM codecs */
    CODEC_ID_ADPCM_IMA_QT= 0x11000,
    CODEC_ID_ADPCM_IMA_WAV,
    CODEC_ID_ADPCM_IMA_DK3,
    CODEC_ID_ADPCM_IMA_DK4,
    CODEC_ID_ADPCM_IMA_WS,
    CODEC_ID_ADPCM_IMA_SMJPEG,
    CODEC_ID_ADPCM_MS,
    CODEC_ID_ADPCM_4XM,
    CODEC_ID_ADPCM_XA,
    CODEC_ID_ADPCM_ADX,
    CODEC_ID_ADPCM_EA,
    CODEC_ID_ADPCM_G726,
    CODEC_ID_ADPCM_CT,
    CODEC_ID_ADPCM_SWF,
    CODEC_ID_ADPCM_YAMAHA,
    CODEC_ID_ADPCM_SBPRO_4,
    CODEC_ID_ADPCM_SBPRO_3,
    CODEC_ID_ADPCM_SBPRO_2,
    CODEC_ID_ADPCM_THP,
    CODEC_ID_ADPCM_IMA_AMV,
    CODEC_ID_ADPCM_EA_R1,
    CODEC_ID_ADPCM_EA_R3,
    CODEC_ID_ADPCM_EA_R2,
    CODEC_ID_ADPCM_IMA_EA_SEAD,
    CODEC_ID_ADPCM_IMA_EA_EACS,
    CODEC_ID_ADPCM_EA_XAS,
    CODEC_ID_ADPCM_EA_MAXIS_XA,
    CODEC_ID_ADPCM_IMA_ISS,
	
    /* AMR */
    CODEC_ID_AMR_NB= 0x12000,
    CODEC_ID_AMR_WB,
	
    /* RealAudio codecs*/
    CODEC_ID_RA_144= 0x13000,
    CODEC_ID_RA_288,
	
    /* various DPCM codecs */
    CODEC_ID_ROQ_DPCM= 0x14000,
    CODEC_ID_INTERPLAY_DPCM,
    CODEC_ID_XAN_DPCM,
    CODEC_ID_SOL_DPCM,
	
    /* audio codecs */
    CODEC_ID_MP2= 0x15000,
    CODEC_ID_MP3, ///< preferred ID for decoding MPEG audio layer 1, 2 or 3
    CODEC_ID_AAC,
    CODEC_ID_AC3,
    CODEC_ID_DTS,
    CODEC_ID_VORBIS,
    CODEC_ID_DVAUDIO,
    CODEC_ID_WMAV1,
    CODEC_ID_WMAV2,
    CODEC_ID_MACE3,
    CODEC_ID_MACE6,
    CODEC_ID_VMDAUDIO,
    CODEC_ID_SONIC,
    CODEC_ID_SONIC_LS,
    CODEC_ID_FLAC,
    CODEC_ID_MP3ADU,
    CODEC_ID_MP3ON4,
    CODEC_ID_SHORTEN,
    CODEC_ID_ALAC,
    CODEC_ID_WESTWOOD_SND1,
    CODEC_ID_GSM, ///< as in Berlin toast format
    CODEC_ID_QDM2,
    CODEC_ID_COOK,
    CODEC_ID_TRUESPEECH,
    CODEC_ID_TTA,
    CODEC_ID_SMACKAUDIO,
    CODEC_ID_QCELP,
    CODEC_ID_WAVPACK,
    CODEC_ID_DSICINAUDIO,
    CODEC_ID_IMC,
    CODEC_ID_MUSEPACK7,
    CODEC_ID_MLP,
    CODEC_ID_GSM_MS, /* as found in WAV */
    CODEC_ID_ATRAC3,
    CODEC_ID_VOXWARE,
    CODEC_ID_APE,
    CODEC_ID_NELLYMOSER,
    CODEC_ID_MUSEPACK8,
    CODEC_ID_SPEEX,
    CODEC_ID_WMAVOICE,
    CODEC_ID_WMAPRO,
    CODEC_ID_WMALOSSLESS,
    CODEC_ID_ATRAC3P,
    CODEC_ID_EAC3,
    CODEC_ID_SIPR,
    CODEC_ID_MP1,
    CODEC_ID_TWINVQ,
    CODEC_ID_TRUEHD,
    CODEC_ID_MP4ALS,
    CODEC_ID_ATRAC1,
    CODEC_ID_BINKAUDIO_RDFT,
    CODEC_ID_BINKAUDIO_DCT,
	CODEC_ID_AAC_LATM,
	
    /* subtitle codecs */
    CODEC_ID_DVD_SUBTITLE= 0x17000,
    CODEC_ID_DVB_SUBTITLE,
    CODEC_ID_TEXT,  ///< raw UTF-8 text
    CODEC_ID_XSUB,
    CODEC_ID_SSA,
    CODEC_ID_MOV_TEXT,
    CODEC_ID_HDMV_PGS_SUBTITLE,
    CODEC_ID_DVB_TELETEXT,
	
    /* other specific kind of codecs (generally used for attachments) */
    CODEC_ID_TTF= 0x18000,
	
    CODEC_ID_PROBE= 0x19000, ///< codec_id is not known (like CODEC_ID_NONE) but lavf should attempt to identify it
	
    CODEC_ID_MPEG2TS= 0x20000, /**< _FAKE_ codec to indicate a raw MPEG-2 TS
                                * stream (only used by libavformat) */
};

/*
 * This table defines how ISO MPEG stream type codes map to HandBrake
 * codecs. It is indexed by the 8 bit stream type and contains the codec
 * worker object id and a parameter for that worker proc (ignored except
 * for the ffmpeg-based codecs in which case it is the ffmpeg codec id).
 *
 * Entries with a worker proc id of 0 or a kind of 'U' indicate that HB
 * doesn't handle the stream type.
 */
typedef struct {
    enum { N, U, A, V } kind; /* not handled / unknown / audio / video */
    int codec;          /* HB worker object id of codec */
    int codec_param;    /* param for codec (usually ffmpeg codec id) */
    const char* name;   /* description of type */
} stream2codec_t;

#define st(id, kind, codec, codec_param, name) \
 [id] = { kind, codec, codec_param, name }

static const stream2codec_t st2codec[256] = {
    st(0x01, V, WORK_DECMPEG2,     0,              "MPEG1"),
    st(0x02, V, WORK_DECMPEG2,     0,              "MPEG2"),
    st(0x03, A, HB_ACODEC_MPGA,    CODEC_ID_MP2,   "MPEG1"),
    st(0x04, A, HB_ACODEC_MPGA,    CODEC_ID_MP2,   "MPEG2"),
    st(0x05, N, 0,                 0,              "ISO 13818-1 private section"),
    st(0x06, U, 0,                 0,              "ISO 13818-1 PES private data"),
    st(0x07, N, 0,                 0,              "ISO 13522 MHEG"),
    st(0x08, N, 0,                 0,              "ISO 13818-1 DSM-CC"),
    st(0x09, N, 0,                 0,              "ISO 13818-1 auxiliary"),
    st(0x0a, N, 0,                 0,              "ISO 13818-6 encap"),
    st(0x0b, N, 0,                 0,              "ISO 13818-6 DSM-CC U-N msgs"),
    st(0x0c, N, 0,                 0,              "ISO 13818-6 Stream descriptors"),
    st(0x0d, N, 0,                 0,              "ISO 13818-6 Sections"),
    st(0x0e, N, 0,                 0,              "ISO 13818-1 auxiliary"),
    st(0x0f, A, HB_ACODEC_MPGA,    CODEC_ID_AAC,   "ISO 13818-7 AAC Audio"),
    st(0x10, V, WORK_DECAVCODECV,  CODEC_ID_MPEG4, "MPEG4"),
    st(0x11, A, HB_ACODEC_MPGA,    CODEC_ID_AAC_LATM, "MPEG4 LATM AAC"),
    st(0x12, U, 0,                 0,              "MPEG4 generic"),

    st(0x14, N, 0,                 0,              "ISO 13818-6 DSM-CC download"),

    st(0x1b, V, WORK_DECAVCODECV,  CODEC_ID_H264,  "H.264"),

    st(0x80, N, 0,                 0,              "DigiCipher II Video"),
    st(0x81, A, HB_ACODEC_AC3,     0,              "AC-3"),
    st(0x82, A, HB_ACODEC_DCA,     0,              "HDMV DTS"),
    st(0x83, A, HB_ACODEC_LPCM,    0,              "LPCM"),
    st(0x84, A, 0,                 0,              "SDDS"),
    st(0x85, U, 0,                 0,              "ATSC Program ID"),
    st(0x86, A, HB_ACODEC_DCA,     0,              "DTS-HD"),
    st(0x87, A, 0,                 0,              "E-AC-3"),

    st(0x8a, A, HB_ACODEC_DCA,     0,              "DTS"),

    st(0x91, A, HB_ACODEC_AC3,     0,              "AC-3"),
    st(0x92, N, 0,                 0,              "Subtitle"),

    st(0x94, A, 0,                 0,              "SDDS"),
    st(0xa0, V, 0,                 0,              "MSCODEC"),

    st(0xea, V, WORK_DECAVCODECV,  CODEC_ID_VC1,   "VC1"),
};
#undef st

typedef enum {
    hb_stream_type_unknown = 0,
    transport,
    program,
    dvd_program,
    ffmpeg
} hb_stream_type_t;

#define kMaxNumberVideoPIDS 1
#define kMaxNumberAudioPIDS 31
#define kMaxNumberDecodeStreams (kMaxNumberVideoPIDS+kMaxNumberAudioPIDS)
#define kMaxNumberPMTStreams 32

typedef struct hb_stream_s hb_stream_t;

struct hb_stream_s
{
    int     frames;             /* video frames so far */
    int     errors;             /* total errors so far */
    int     last_error_frame;   /* frame # at last error message */
    int     last_error_count;   /* # errors at last error message */
    int     packetsize;         /* Transport Stream packet size */

    uint8_t need_keyframe;      // non-zero if want to start at a keyframe
    uint8_t ts_found_pcr;       // non-zero if we've found at least one input pcr
    int     ts_pcr_out;         // sequence number of most recent output pcr
    int     ts_pcr_in;          // sequence number of most recent input pcr
    int64_t ts_pcr;             // most recent input pcr
    int64_t ts_pcrhist[4];      // circular buffer of output pcrs

    uint8_t *ts_packet;         /* buffer for one TS packet */
    
    
    int      chapter;           /* Chapter that we are currently in */
    int64_t  chapter_end;       /* HB time that the current chapter ends */

    /*
     * Stuff before this point is dynamic state updated as we read the
     * stream. Stuff after this point is stream description state that
     * we learn during the initial scan but cache so it can be
     * reused during the conversion read.
     */
    uint8_t ts_number_video_pids;
    uint8_t ts_number_audio_pids;
    uint8_t ts_flags;           // stream characteristics:
#define         TS_HAS_PCR  (1 << 0)    // at least one PCR seen
#define         TS_HAS_RAP  (1 << 1)    // Random Access Point bit seen
#define         TS_HAS_RSEI (1 << 2)    // "Restart point" SEI seen
    uint8_t ts_IDRs;            // # IDRs found during duration scan

    int16_t ts_video_pids[kMaxNumberVideoPIDS];
    int16_t ts_audio_pids[kMaxNumberAudioPIDS];

    uint32_t ts_format_id[kMaxNumberDecodeStreams];
#define TS_FORMAT_ID_AC3 (('A' << 24) | ('C' << 16) | ('-' << 8) | '3')
    uint8_t ts_stream_type[kMaxNumberDecodeStreams];
    uint8_t ts_multiplexed[kMaxNumberDecodeStreams];

    char    *path;
    NSFileHandle    *file_handle;
    hb_stream_type_t hb_stream_type;
    
    uint8_t ffmpeg_video_id;

    struct {
        int lang_code;
        int flags;
        int rate;
        int bitrate;
    } a52_info[kMaxNumberAudioPIDS];

    struct
    {
        unsigned short program_number;
        unsigned short program_map_PID;
    } pat_info[kMaxNumberPMTStreams];
    int     ts_number_pat_entries;

    struct
    {
        int reading;
        unsigned char *tablebuf;
        unsigned int tablepos;
        unsigned char current_continuity_counter;

        int section_length;
        int program_number;
        unsigned int PCR_PID;
        int program_info_length;
        unsigned char *progam_info_descriptor_data;
        struct
        {
            unsigned char stream_type;
            unsigned short elementary_PID;
            unsigned short ES_info_length;
            unsigned char *es_info_descriptor_data;
        } pmt_stream_info[kMaxNumberPMTStreams];
    } pmt_info;
};

/***********************************************************************
 * Local prototypes
 **********************************************************************/
//static void hb_stream_duration(hb_stream_t *stream, hb_title_t *inTitle);
static void hb_ts_stream_init(hb_stream_t *stream);
static void hb_ts_stream_find_pids(hb_stream_t *stream);
static off_t align_to_next_packet(hb_stream_t *stream);

static int check_ps_sync(const uint8_t *buf)
{
    // a legal MPEG program stream must start with a Pack header in the
    // first four bytes.
    return (buf[0] == 0x00) && (buf[1] == 0x00) &&
           (buf[2] == 0x01) && (buf[3] == 0xba);
}

static int check_ps_sc(const uint8_t *buf)
{
    // a legal MPEG program stream must start with a Pack followed by a
    // some other start code. If we've already verified the pack, this skip
    // it and checks for a start code prefix.
    int pos = 14 + ( buf[13] & 0x7 );   // skip over the PACK
    return (buf[pos+0] == 0x00) && (buf[pos+1] == 0x00) && (buf[pos+2] == 0x01);
}

static int check_ts_sync(const uint8_t *buf)
{
    // must have initial sync byte, no scrambling & a legal adaptation ctrl
    return (buf[0] == 0x47) && ((buf[3] >> 6) == 0) && ((buf[3] >> 4) > 0);
}

static int have_ts_sync(const uint8_t *buf, int psize)
{
    return check_ts_sync(&buf[0*psize]) && check_ts_sync(&buf[1*psize]) &&
           check_ts_sync(&buf[2*psize]) && check_ts_sync(&buf[3*psize]) &&
           check_ts_sync(&buf[4*psize]) && check_ts_sync(&buf[5*psize]) &&
           check_ts_sync(&buf[6*psize]) && check_ts_sync(&buf[7*psize]);
}

static int hb_stream_check_for_ts(const uint8_t *buf)
{
    // transport streams should have a sync byte every 188 bytes.
    // search the first 8KB of buf looking for at least 8 consecutive
    // correctly located sync patterns.
    int offset = 0;

    for ( offset = 0; offset < 8*1024-8*188; ++offset )
    {
        if ( have_ts_sync( &buf[offset], 188) )
            return 188 | (offset << 8);
        if ( have_ts_sync( &buf[offset], 192) )
            return 192 | (offset << 8);
        if ( have_ts_sync( &buf[offset], 204) )
            return 204 | (offset << 8);
        if ( have_ts_sync( &buf[offset], 208) )
            return 208 | (offset << 8);
    }
    return 0;
}

static int hb_stream_check_for_ps(const uint8_t *buf)
{
    // program streams should start with a PACK then some other mpeg start
    // code (usually a SYS but that might be missing if we only have a clip).
    return check_ps_sync(buf) && check_ps_sc(buf);
}

static int hb_stream_check_for_dvd_ps(const uint8_t *buf)
{
    // DVD program streams should have a Pack header every 2048 bytes.
    // check that we have 4 of these in a row.
    return check_ps_sync(&buf[0*2048]) && check_ps_sync(&buf[1*2048]) &&
           check_ps_sync(&buf[2*2048]) && check_ps_sync(&buf[3*2048]);
}

static int hb_stream_get_type(hb_stream_t *stream)
{
	uint8_t buf[2048*4];
	NSData *bufData = [stream->file_handle readDataOfLength:sizeof(buf)];
	if ([bufData length] < sizeof(buf))
	{
		return 0;
	}
	[bufData getBytes:&buf length:sizeof(buf)];
	int psize;
	if ( ( psize = hb_stream_check_for_ts(buf) ) != 0 )
	{
		int offset = psize >> 8;
		psize &= 0xff;
		NSLog(@"file is MPEG Transport Stream with %d byte packets"
			   " offset %d bytes", psize, offset);
		stream->packetsize = psize;
		stream->hb_stream_type = transport;
		hb_ts_stream_init(stream);
		if ( !stream->ts_number_video_pids || !stream->ts_number_audio_pids )
		{
			return 0;
		}
		return 1;
	}
	if ( hb_stream_check_for_dvd_ps(buf) != 0 )
	{
		NSLog(@"file is MPEG DVD Program Stream");
		stream->hb_stream_type = dvd_program;
		return 1;
	}
	if ( hb_stream_check_for_ps(buf) != 0 )
	{
		NSLog(@"file is MPEG Program Stream");
		stream->hb_stream_type = program;
		return 1;
	}
	return 0;
}

static void hb_stream_delete_dynamic( hb_stream_t *d )
{
    if( d->file_handle )
    {
		[d->file_handle closeFile];
		[d->file_handle release];
		d->file_handle = NULL;
    }

    if ( d->ts_packet )
    {
        free( d->ts_packet );
        d->ts_packet = NULL;
    }
}

static void hb_stream_delete( hb_stream_t *d )
{
    hb_stream_delete_dynamic( d );
    free( d->path );
    free( d );
}


/***********************************************************************
 * hb_stream_close
 ***********************************************************************
 * Closes and frees everything
 **********************************************************************/
void hb_stream_close( hb_stream_t ** _d )
{
    hb_stream_t *stream = * _d;

    if ( stream->hb_stream_type == ffmpeg )
    {
        //ffmpeg_close( stream );
        hb_stream_delete( stream );
        *_d = NULL;
        return;
    }

    if ( stream->frames )
    {
        NSLog(@"stream: %d good frames, %d errors (%.0f%%)", stream->frames,
                stream->errors, (double)stream->errors * 100. /
                (double)stream->frames );
    }

    /*
     * if the stream was opened for a scan, cache the result, otherwise delete
     * the state.
     */
    {
        hb_stream_delete( stream );
    }
    *_d = NULL;
}

static int index_of_pid(int pid, hb_stream_t *stream)
{
    int i;

    if ( pid == stream->ts_video_pids[0] )
        return 0;

    for ( i = 0; i < stream->ts_number_audio_pids; ++i )
        if ( pid == stream->ts_audio_pids[i] )
            return i + 1;

    return -1;
}

/*
 * read the next transport stream packet from 'stream'. Return NULL if
 * we hit eof & a pointer to the sync byte otherwise.
 */
static const uint8_t *next_packet( hb_stream_t *stream )
{
    uint8_t *buf = stream->ts_packet + stream->packetsize - 188;

    while ( 1 )
    {
		NSData *packetData = [stream->file_handle readDataOfLength:stream->packetsize];
		if ([packetData length] != stream->packetsize)
		{
			return NULL;
		}
		[packetData getBytes:stream->ts_packet length:stream->packetsize];
        
        if (buf[0] == 0x47)
        {
            return buf;
        }
        // lost sync - back up to where we started then try to re-establish.
        off_t pos = [stream->file_handle offsetInFile] - stream->packetsize;
        off_t pos2 = align_to_next_packet(stream);
        if ( pos2 == 0 )
        {
            NSLog(@"next_packet: eof while re-establishing sync @ %llu", pos );
            return NULL;
        }
        NSLog(@"next_packet: sync lost @ %llu, regained after %llu bytes", pos, pos2 );
    }
}

/***********************************************************************
 * hb_ts_stream_init
 ***********************************************************************
 *
 **********************************************************************/

static void hb_ts_stream_init(hb_stream_t *stream)
{
	int i;

	for (i=0; i < kMaxNumberDecodeStreams; i++)
	{
		//stream->ts_streamcont[i] = -1;
	}
	stream->ts_video_pids[0] = -1;
    for ( i = 0; i < stream->ts_number_audio_pids; i++ )
    {
        stream-> ts_audio_pids[i] = -1;
    }

    stream->ts_packet = malloc( stream->packetsize );

	// Find the audio and video pids in the stream
	hb_ts_stream_find_pids(stream);
}

#define MAX_HOLE 208*80

static off_t align_to_next_packet(hb_stream_t *stream)
{
    uint8_t buf[MAX_HOLE];
	off_t pos = 0;
    off_t start = [stream->file_handle offsetInFile];

    if ( start >= stream->packetsize ) 
	{
        start -= stream->packetsize;
		[stream->file_handle seekToFileOffset:start];
    }

	NSData *bufData = [stream->file_handle readDataOfLength:sizeof(buf)];
	if (bufData && [bufData length] == sizeof(buf))
	{
		[bufData getBytes:&buf length:sizeof(buf)];
        const uint8_t *bp = buf;
        int i;

        for ( i = sizeof(buf); --i >= 0; ++bp )
        {
            if ( have_ts_sync( bp, stream->packetsize ) )
            {
                break;
            }
        }
        if ( i >= 0 )
        {
            pos = ( bp - buf ) - stream->packetsize + 188;
            if ( pos < 0 )
                pos = 0;
        }
	}
	[stream->file_handle seekToFileOffset:start+pos];
	return pos;
}


typedef struct {
    uint8_t *buf;
    uint32_t val;
    int pos;
} bitbuf_t;

static const unsigned int bitmask[] = {
	0x0,0x1,0x3,0x7,0xf,0x1f,0x3f,0x7f,0xff,
	0x1ff,0x3ff,0x7ff,0xfff,0x1fff,0x3fff,0x7fff,0xffff,
	0x1ffff,0x3ffff,0x7ffff,0xfffff,0x1fffff,0x3fffff,0x7fffff,0xffffff,
	0x1ffffff,0x3ffffff,0x7ffffff,0xfffffff,0x1fffffff,0x3fffffff,0x7fffffff,0xffffffff};

static inline void set_buf(bitbuf_t *bb, uint8_t* buf, int bufsize, int clear)
{
	bb->pos = 0;
	bb->buf = buf;
	bb->val = (bb->buf[0] << 24) | (bb->buf[1] << 16) |
              (bb->buf[2] << 8) | bb->buf[3];
	if (clear)
		memset(bb->buf, 0, bufsize);
}

static inline int buf_size(bitbuf_t *bb)
{
	return bb->pos >> 3;
}

static inline unsigned int get_bits(bitbuf_t *bb, int bits)
{
	unsigned int val;
	int left = 32 - (bb->pos & 31);

	if (bits < left)
	{
		val = (bb->val >> (left - bits)) & bitmask[bits];
		bb->pos += bits;
	}
	else
	{
		val = (bb->val & bitmask[left]) << (bits - left);
		bb->pos += left;
		bits -= left;

		int pos = bb->pos >> 3;
		bb->val = (bb->buf[pos] << 24) | (bb->buf[pos + 1] << 16) | (bb->buf[pos + 2] << 8) | bb->buf[pos + 3];

		if (bits > 0)
		{
			val |= (bb->val >> (32 - bits)) & bitmask[bits];
			bb->pos += bits;
		}
	}

	return val;
}

static const char *stream_type_name (uint8_t stream_type)
{
    return st2codec[stream_type].name? st2codec[stream_type].name : "Unknown";
}

// extract what useful information we can from the elementary stream
// descriptor list at 'dp' and add it to the stream at 'esindx'.
// Descriptors with info we don't currently use are ignored.
// The descriptor list & descriptor item formats are defined in
// ISO 13818-1 (2000E) section 2.6 (pg. 62).
static void decode_element_descriptors(hb_stream_t* stream, int esindx,
                                       const uint8_t *dp, uint8_t dlen)
{
    const uint8_t *ep = dp + dlen;
	
    while (dp < ep)
    {
        switch (dp[0])
        {
            case 5:    // Registration descriptor
                stream->ts_format_id[esindx+1] = (dp[2] << 24) | (dp[3] << 16) |
				(dp[4] << 8)  | dp[5];
                break;
				
            case 10:    // ISO_639_language descriptor
                //stream->a52_info[esindx].lang_code = lang_to_code(lang_for_code2((const char *)&dp[2]));
                break;
				
            case 0x6a:  // DVB AC-3 descriptor
                stream->ts_stream_type[esindx+1] = 0x81;
                break;
				
            default:
                break;
        }
        dp += dp[1] + 2;
    }
}

int decode_program_map(hb_stream_t* stream)
{
    bitbuf_t bb;
	set_buf(&bb, stream->pmt_info.tablebuf, stream->pmt_info.tablepos, 0);

    get_bits(&bb, 8);  // table_id
    get_bits(&bb, 4);
    unsigned int section_length = get_bits(&bb, 12);
    stream->pmt_info.section_length = section_length;

    unsigned int program_number = get_bits(&bb, 16);
    stream->pmt_info.program_number = program_number;
    get_bits(&bb, 2);
    get_bits(&bb, 5);  // version_number
    get_bits(&bb, 1);
    get_bits(&bb, 8);  // section_number
    get_bits(&bb, 8);  // last_section_number
    get_bits(&bb, 3);
    unsigned int PCR_PID = get_bits(&bb, 13);
    stream->pmt_info.PCR_PID = PCR_PID;
    get_bits(&bb, 4);
    unsigned int program_info_length = get_bits(&bb, 12);
    stream->pmt_info.program_info_length = program_info_length;

	int i=0;
	unsigned char *descriptor_buf = (unsigned char *) malloc(program_info_length);
	for (i = 0; i < program_info_length; i++)
	{
	  descriptor_buf[i] = get_bits(&bb, 8);
	}

	int cur_pos =  9 /* data after the section length field*/ + program_info_length;
	int done_reading_stream_types = 0;
	while (!done_reading_stream_types)
    {
        unsigned char stream_type = get_bits(&bb, 8);
        get_bits(&bb, 3);
        unsigned int elementary_PID = get_bits(&bb, 13);
        get_bits(&bb, 4);
        unsigned int ES_info_length = get_bits(&bb, 12);

        int i=0;
        unsigned char *ES_info_buf = (unsigned char *) malloc(ES_info_length);
        for (i=0; i < ES_info_length; i++)
        {
            ES_info_buf[i] = get_bits(&bb, 8);
        }


        if ( index_of_pid( elementary_PID, stream ) < 0 )
        {
            // don't have this pid yet
            if (stream->ts_number_video_pids == 0 && 
                st2codec[stream_type].kind == V )
            {
                stream->ts_video_pids[0] = elementary_PID;
                stream->ts_stream_type[0] = stream_type;
                stream->ts_number_video_pids = 1;
            }
            else
            {
                // Defined audio stream types are 0x81 for AC-3/A52 audio 
                // and 0x03 for mpeg audio. But content producers seem to 
                // use other values (0x04 and 0x06 have both been observed) 
                // so at this point we say everything that isn't a video 
                // pid is audio then at the end of hb_stream_title_scan 
                // we'll figure out which are really audio by looking at 
                // the PES headers.
                i = stream->ts_number_audio_pids;
                if (i < kMaxNumberAudioPIDS)
                {
                    stream->ts_audio_pids[i] = elementary_PID;
                    stream->ts_stream_type[1 + i] = stream_type;
                    if (ES_info_length > 0)
                    {
                        decode_element_descriptors(stream, i, ES_info_buf,
                                                ES_info_length);
                    }
                    ++stream->ts_number_audio_pids;
                }
            }
        }

        cur_pos += 5 /* stream header */ + ES_info_length;

        free(ES_info_buf);

        if (cur_pos >= section_length - 4 /* stop before the CRC */)
            done_reading_stream_types = 1;
    }

	free(descriptor_buf);
	return 1;
}

static int build_program_map(const uint8_t *buf, hb_stream_t *stream)
{
    // Get adaption header info
    int adapt_len = 0;
    int adaption = (buf[3] & 0x30) >> 4;
    if (adaption == 0)
            return 0;
    else if (adaption == 0x2)
            adapt_len = 184;
    else if (adaption == 0x3)
            adapt_len = buf[4] + 1;
    if (adapt_len > 184)
            return 0;

    // Get payload start indicator
    int start;
    start = (buf[1] & 0x40) != 0;

    // Get pointer length - only valid in packets with a start flag
    int pointer_len = 0;

	if (start)
	{
		pointer_len = buf[4 + adapt_len] + 1;
		stream->pmt_info.tablepos = 0;
	}
	// Get Continuity Counter
	int continuity_counter = buf[3] & 0x0f;
	if (!start && (stream->pmt_info.current_continuity_counter + 1 != continuity_counter))
	{
		NSLog(@"build_program_map - Continuity Counter %d out of sequence - expected %d", continuity_counter, stream->pmt_info.current_continuity_counter+1);
		return 0;
	}
	stream->pmt_info.current_continuity_counter = continuity_counter;
	stream->pmt_info.reading |= start;

    // Add the payload for this packet to the current buffer
	int amount_to_copy = 184 - adapt_len - pointer_len;
    if (stream->pmt_info.reading && (amount_to_copy > 0))
    {
			stream->pmt_info.tablebuf = realloc(stream->pmt_info.tablebuf, stream->pmt_info.tablepos + amount_to_copy);

            memcpy(stream->pmt_info.tablebuf + stream->pmt_info.tablepos, buf + 4 + adapt_len + pointer_len, amount_to_copy);
            stream->pmt_info.tablepos += amount_to_copy;
    }
    if (stream->pmt_info.tablepos > 3)
    {
        // We have enough to check the section length
        int length;
        length = ((stream->pmt_info.tablebuf[1] << 8) + 
                  stream->pmt_info.tablebuf[2]) & 0xFFF;
        if (stream->pmt_info.tablepos > length + 1)
        {
            // We just finished a bunch of packets - parse the program map details
            int decode_ok = 0;
            if (stream->pmt_info.tablebuf[0] == 0x02)
                decode_ok = decode_program_map(stream);
            free(stream->pmt_info.tablebuf);
            stream->pmt_info.tablebuf = NULL;
            stream->pmt_info.tablepos = 0;
            stream->pmt_info.reading = 0;
            if (decode_ok)
                return decode_ok;
        }

    }

    return 0;
}

static int decode_PAT(const uint8_t *buf, hb_stream_t *stream)
{
    unsigned char tablebuf[1024];
    unsigned int tablepos = 0;

    int reading = 0;


    // Get adaption header info
    int adapt_len = 0;
    int adaption = (buf[3] & 0x30) >> 4;
    if (adaption == 0)
            return 0;
    else if (adaption == 0x2)
            adapt_len = 184;
    else if (adaption == 0x3)
            adapt_len = buf[4] + 1;
    if (adapt_len > 184)
            return 0;

    // Get pointer length
    int pointer_len = buf[4 + adapt_len] + 1;

    // Get payload start indicator
    int start;
    start = (buf[1] & 0x40) != 0;

    if (start)
            reading = 1;

    // Add the payload for this packet to the current buffer
    if (reading && (184 - adapt_len) > 0)
    {
            if (tablepos + 184 - adapt_len - pointer_len > 1024)
            {
                    NSLog(@"decode_PAT - Bad program section length (> 1024)");
                    return 0;
            }
            memcpy(tablebuf + tablepos, buf + 4 + adapt_len + pointer_len, 184 - adapt_len - pointer_len);
            tablepos += 184 - adapt_len - pointer_len;
    }

    if (start && reading)
    {
            memcpy(tablebuf + tablepos, buf + 4 + adapt_len + 1, pointer_len - 1);


            unsigned int pos = 0;
            //while (pos < tablepos)
            {
                    bitbuf_t bb;
                    set_buf(&bb, tablebuf + pos, tablepos - pos, 0);

                    unsigned char section_id	= get_bits(&bb, 8);
                    get_bits(&bb, 4);
                    unsigned int section_len	= get_bits(&bb, 12);
                    get_bits(&bb, 16); // transport_id
                    get_bits(&bb, 2);
                    get_bits(&bb, 5);  // version_num
                    get_bits(&bb, 1);  // current_next
                    get_bits(&bb, 8);  // section_num
                    get_bits(&bb, 8);  // last_section

                    switch (section_id)
                    {
                      case 0x00:
                        {
                          // Program Association Section
                          section_len -= 5;    // Already read transport stream ID, version num, section num, and last section num
                          section_len -= 4;   // Ignore the CRC
                          int curr_pos = 0;
						  stream->ts_number_pat_entries = 0;
                          while ((curr_pos < section_len) && (stream->ts_number_pat_entries < kMaxNumberPMTStreams))
                          {
                            unsigned int pkt_program_num = get_bits(&bb, 16);
							stream->pat_info[stream->ts_number_pat_entries].program_number = pkt_program_num;

                            get_bits(&bb, 3);  // Reserved
                            if (pkt_program_num == 0)
                            {
                              get_bits(&bb, 13); // pkt_network_id
                            }
                            else
                            {
                              unsigned int pkt_program_map_PID = get_bits(&bb, 13);
                                stream->pat_info[stream->ts_number_pat_entries].program_map_PID = pkt_program_map_PID;
                            }
                            curr_pos += 4;
							stream->ts_number_pat_entries++;
                          }
                        }
                        break;
                      case 0xC7:
                            {
                                    break;
                            }
                      case 0xC8:
                            {
                                    break;
                            }
                    }

                    pos += 3 + section_len;
            }

            tablepos = 0;
    }
    return 1;
}

static void hb_ts_stream_find_pids(hb_stream_t *stream)
{
    // To be different from every other broadcaster in the world, New Zealand TV
    // changes PMTs (and thus video & audio PIDs) when 'programs' change. Since
    // we may have the tail of the previous program at the beginning of this
    // file, take our PMT from the middle of the file.
	
    //uint64_t fsize = [stream->file_handle seekToEndOfFile];
	//[stream->file_handle seekToFileOffset:fsize >> 1];

	// Read the Transport Stream Packets (188 bytes each) looking at first for PID 0 (the PAT PID), then decode that
	// to find the program map PID and then decode that to get the list of audio and video PIDs

	for (;;)
	{
        const uint8_t *buf = next_packet( stream );

        if ( buf == NULL )
        {
			NSLog(@"hb_ts_stream_find_pids - end of file");
			break;
		}

		// Get pid
		int pid = (((buf[1] & 0x1F) << 8) | buf[2]) & 0x1FFF;

        if ((pid == 0x0000) && (stream->ts_number_pat_entries == 0))
		{
		  decode_PAT(buf, stream);
		  continue;
		}

		int pat_index = 0;
		for (pat_index = 0; pat_index < stream->ts_number_pat_entries; pat_index++)
		{
			// There are some streams where the PAT table has multiple entries as if their are
			// multiple programs in the same transport stream, and yet there's actually only one
			// program really in the stream. This seems to be true for transport streams that
			// originate in the HDHomeRun but have been output by EyeTV's export utility. What I think
			// is happening is that the HDHomeRun is sending the entire transport stream as broadcast,
			// but the EyeTV is only recording a single (selected) program number and not rewriting the
			// PAT info on export to match what's actually on the stream.
			// Until we have a way of handling multiple programs per transport stream elegantly we'll match
			// on the first pat entry for which we find a matching program map PID.  The ideal solution would
			// be to build a title choice popup from the PAT program number details and then select from
			// their - but right now the API's not capable of that.
            if (stream->pat_info[pat_index].program_number != 0 &&
                pid == stream->pat_info[pat_index].program_map_PID)
			{
			  if (build_program_map(buf, stream) > 0)
				break;
			}
		}
		// Keep going  until we have a complete set of PIDs
		if (stream->ts_number_video_pids > 0)
		  break;
	}

	NSLog(@"hb_ts_stream_find_pids - found the following PIDS");
	NSLog(@"    Video PIDS : ");
    int i;
	for (i=0; i < stream->ts_number_video_pids; i++)
	{
        NSLog(@"      0x%x type %s (0x%x)", 
                stream->ts_video_pids[i],
                stream_type_name(stream->ts_stream_type[i]),
                stream->ts_stream_type[i]);
	}
	NSLog(@"    Audio PIDS : ");
	for (i = 0; i < stream->ts_number_audio_pids; i++)
	{
        NSLog(@"      0x%x type %s (0x%x)", 
                stream->ts_audio_pids[i],
                stream_type_name(stream->ts_stream_type[i+1]),
                stream->ts_stream_type[i+1] );
	}
 }

@implementation TTTransportStreamParser

+(NSMutableDictionary *)parseDSMCC:(NSFileHandle *)fileHandle
{
	if (!fileHandle)
	{
		NSLog(@"No file stream given to TS parser");
		return nil;
	}
	
    hb_stream_t *d = calloc( sizeof( hb_stream_t ), 1 );
    if ( d == NULL )
    {
		NSLog(@"hb_stream_open: can't allocate space for stream state");
        return nil;
    }
	
    d->file_handle = fileHandle;

    if ( hb_stream_get_type( d ) != 0 )
	{
		NSMutableDictionary *pidDict = [[NSMutableDictionary alloc] initWithCapacity:2];
		
		if (d->ts_number_video_pids)
		{
			[pidDict setObject:[NSNumber numberWithShort:d->ts_video_pids[0]] forKey:@"videoPID"];
		}
		else 
		{
			[pidDict setObject:[NSNumber numberWithShort:0] forKey:@"videoPID"];
		}


		if (d->hb_stream_type == transport)
		{
			UInt32 i;
			[pidDict setObject:[NSNumber numberWithShort:0] forKey:@"videoPID"];
			for ( i=0; i<d->ts_number_audio_pids; i++)
			{
				if (d->ts_stream_type[i+1] == 0x0b)
				{
					NSLog(@"Selected DSM-CC PID 0x%x (%u)", 
						  d->ts_audio_pids[i],
						  d->ts_audio_pids[i]);
					[pidDict setObject:[NSNumber numberWithShort:d->ts_audio_pids[i]] forKey:@"dsmccPID"];
					break;
				}
			}
		}
		return pidDict;
	}
	d->file_handle = NULL;
	
	NSLog(@"hb_stream_open failed");
    free( d );
    return nil;
}

@end

