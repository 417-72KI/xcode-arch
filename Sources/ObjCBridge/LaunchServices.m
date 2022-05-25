#import "LaunchServices.h"
#import "LaunchServices+Private.h"

void LSSetArchitecturePreferenceForApplicationURL(NSURL *url, NSString* arch)
{
    _LSSetArchitecturePreferenceForApplicationURL(url, arch);
}
