#ifndef LaunchServices_h
#define LaunchServices_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

void _LSSetArchitecturePreferenceForApplicationURL(NSURL *url, NSString* arch);

NS_ASSUME_NONNULL_END

#endif /* LaunchServices_h */