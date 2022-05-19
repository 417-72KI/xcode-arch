#import "LaunchServices.h"

/// https://blog.timac.org/2010/0130-open-in-32-bit-mode-open-using-rosetta/
NSString *getResolvedAliasPathInData(NSData* data)
{
    CFDataRef dataRef = (__bridge CFDataRef) data;
    CFErrorRef err;
    CFURLRef urlRef = CFURLCreateByResolvingBookmarkData(NULL, dataRef, NULL, NULL, NULL, NO, &err);
    return ((__bridge NSURL*)urlRef).path;
}
