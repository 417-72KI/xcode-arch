#ifndef LaunchServices_h
#define LaunchServices_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

void _LSSetArchitecturePreferenceForApplicationURL(NSURL *url, NSString* arch);

NSString * _Nullable getResolvedAliasPathInData(NSData* data);

NS_ASSUME_NONNULL_END

#endif /* LaunchServices_h */
