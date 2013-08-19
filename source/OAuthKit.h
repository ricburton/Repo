#import <Foundation/Foundation.h>
#import <AFHTTPClient.h>
#import <AFJSONRequestOperation.h>

@interface OAuthKit : NSObject

@property NSString* clientID;
@property NSString* clientSecret;
@property NSURL* authorizeURL;
@property NSURL* accessTokenURL;
@property NSString* urlScheme;

- (id) initWithClientID:(NSString*)_clientID clientSecret:(NSString*)_clientSecret authorizeURL:(NSURL*)_authorizeURL accessTokenURL:(NSURL*)_accessTokenURL urlScheme:(NSString*)scheme;
- (void) authorize;
- (void) authorizeWithParams:(NSDictionary*)params;
- (void) requestAccessToken:(NSString*)code completionHandler:(void (^)(NSString*, AFHTTPRequestOperation*, NSError*))handler;

@end
