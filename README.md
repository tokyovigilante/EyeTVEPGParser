# EyeTVEPGParser

## About

Plugin for EyeTV using the official SDK to parse out MHEG-5 EPG (Electronic Program Guide) data and convert it, using the excellent [EPG Collector](http://www.geekzone.co.nz/freitasm/7220) to xmltv format, and then import it into EyeTV automatically. 

This is entirely legal and does not violate copyright, as the EPG data is provided in the DVB-T stream to your decoder for your personal use.

It runs automatically every hour and when the channel is changed. It should not interfere with live TV or recordings (apart from the issues below, which are being worked on), is completely passive and does not require internet access.

## Usage

1. The EPG Collector port relies on [Mono](http://www.mono-project.com/Main_Page) so [grab it](http://ftp.novell.com/pub/mono/archive/2.10.1/macos-10-x86/3/MonoFramework-2.10.1_3.macos10.novell.x86.dmg) and install it first.
2. Copy the [EyeTVEPGParser bundle](https://github.com/downloads/tokyovigilante/EyeTVEPGParser/EyeTVEPGParser.bundle.zip) into /Library/Application Support/EyeTV/Plugins (you'll probably have to create the Plugins folder. Note the plugin can't go in ~/L/AS/EyeTV.
3. Restart EyeTV and watch one channel (any channel) for two minutes or so. After that the plugin should have parsed the EPG, and you should be able to select xmltv in the channel listings, and map the channels to the generated XML.

## Issues

The code is very early, and may cause EyeTV to stutter temporarily as the data is collected and parsed (no more than a minute). This is due to current complete lack of threads, and is being worked on. There are some crashing bugs, but if the parser completes the XML data is imported. Restart EyeTV and set up channel mappings as before (these aren't saved till a clean exit from EyeTV - Sorry).

Currently settings for NZ DVB-T are hardcoded. I need DVB-S and international testers, and I'll work on modifying the code to be more flexible.

Intel-only, if anyone needs a PPC build ask me, or alternatively the code should work fine recompiled.

Logging is only to stdout for now, check Console.app for output. I'm working on file logging and maybe GUI feedback via Growl.

## Building

I've tested with Xcode 3.2 on OS X 10.6 (Intel). You're on your own otherwise (although I can't see a reason this wouldn't work on 10.5/PPC).

You can't debug plugins directly, you need to run the EyeTV executable from within Xcode after building the plugin and copying it to /L/AS/EyeTV/Plugins. EyeTV prevents the debugger attaching using [PT_DENY_ATTACH](http://landonf.bikemonkey.org/code/macosx/Leopard_PT_DENY_ATTACH.20080122.html). This needs to be overridden using [this kernel extension](https://github.com/dwalters/pt_deny_attach) (Thanks to [Landon Fuller](http://landonf.bikemonkey.org/) and [Dan Walters](https://github.com/dwalters)). 

## Feedback

Welcome and requested - to the [Issues page](https://github.com/tokyovigilante/EyeTVEPGParser/issues) here, on the [Geekzone forums](http://www.geekzone.co.nz/forums.asp?forumid=126&topicid=79270), or by [email](https://github.com/inbox/new).
