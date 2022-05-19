#import "LaunchServices.h"

/// https://blog.timac.org/2010/0130-open-in-32-bit-mode-open-using-rosetta/
NSString *getResolvedAliasPathInData(NSData* data)
{
    NSString *outPath = nil;
    const void *theDataPtr = [data bytes];
    NSUInteger theDataLength = [data length];
    if(theDataPtr != nil && theDataLength > 0) {
        // Create an AliasHandle from the NSData
        AliasHandle theAliasHandle;
        theAliasHandle = (AliasHandle) NewHandle(theDataLength);
        bcopy(theDataPtr, *theAliasHandle, theDataLength);

        FSRef theRef;
        Boolean wChang;
        OSStatus err = noErr;
        err = FSResolveAlias(NULL, theAliasHandle, &theRef, &wChang);
        if(err == noErr) {
            // The path was resolved.
            char path[1024];
            err = FSRefMakePath(&theRef, (UInt8*)path, sizeof(path));
            if(err == noErr)
                outPath = [NSString stringWithUTF8String:path];
        } else {
            // If we can't resolve the alias (file not found),
            // we can still return the path.
            CFStringRef tmpPath = NULL;
            err = FSCopyAliasInfo(theAliasHandle, NULL, NULL,
                                  &tmpPath, NULL, NULL);

            if(err == noErr && tmpPath != NULL)
                outPath = (__bridge NSString*)tmpPath;
        }

        DisposeHandle((Handle)theAliasHandle);
    }
    return outPath;
}
