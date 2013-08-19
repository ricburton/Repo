#import "NSURL+OAuthKit.h"
#import "NSString+OAuthkit.h"

@implementation NSURL (OAuthKit)

- (NSURL *)urlByAddingQueryParams:(NSDictionary *)params {
    if (!params || [params count] == 0) {
        return self;
    }
    
    NSString *newParameterString = [NSString stringWithQueryParams:params];
    
    NSString *absoluteString = [self absoluteString];
    if ([absoluteString rangeOfString:@"?"].location == NSNotFound) {
        absoluteString = [NSString stringWithFormat:@"%@?%@", absoluteString, newParameterString];
    } else {
        absoluteString = [NSString stringWithFormat:@"%@&%@", absoluteString, newParameterString];
    }
    
    return [NSURL URLWithString:absoluteString];
}

- (NSDictionary *)queryParams{
    return [[self query] paramsFromQueryString];
}


- (NSString *)valueForQueryParamKey:(NSString *)key;
{
    return [[self queryParams] objectForKey:key];
}

@end
