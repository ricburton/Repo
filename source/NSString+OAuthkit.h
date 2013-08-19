#import <Foundation/Foundation.h>

@interface NSString (OAuthkit)

+ (NSString*) stringWithQueryParams:(NSDictionary*)params;
- (NSDictionary *) paramsFromQueryString;
- (NSString*) urlDecodedString;
- (NSString*) urlEncodedString;

@end
