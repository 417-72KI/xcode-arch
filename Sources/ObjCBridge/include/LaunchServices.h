#ifndef LaunchServices_h
#define LaunchServices_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Set architecture to app.
///
/// In M1 mac, it means check/uncheck `Open Using Rosetta`
///
/// @param url URL to Application (e.g. `/Applications/Xcode.app`)
/// @param arch architecture to set (e.g. `arm64`)
void LSSetArchitecturePreferenceForApplicationURL(NSURL *url, NSString* arch);

NS_ASSUME_NONNULL_END

#endif /* LaunchServices_h */
