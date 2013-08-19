#import <Foundation/Foundation.h>

@interface NSURL (OAuthKit)

- (NSURL *)urlByAddingQueryParams:(NSDictionary *)params;
- (NSDictionary *)queryParams;
- (NSString *)valueForQueryParamKey:(NSString *)key;

@end
