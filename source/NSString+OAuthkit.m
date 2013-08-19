#import "NSString+OAuthkit.h"

@implementation NSString (OAuthkit)

+ (NSString*) stringWithQueryParams:(NSDictionary*)params {
    NSMutableArray *parameterPairs = [NSMutableArray array];
    for (NSString *key in [params allKeys]) {
        NSString *pair = [NSString stringWithFormat:@"%@=%@", [key urlEncodedString], [[params objectForKey:key] urlEncodedString]];
        [parameterPairs addObject:pair];
    }
    return [parameterPairs componentsJoinedByString:@"&"];
}

- (NSDictionary *)paramsFromQueryString;
{
    NSArray *components = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *component in components) {
        NSArray *subcomponents = [component componentsSeparatedByString:@"="];
        [parameters setObject:[[subcomponents objectAtIndex:1] urlDecodedString]
                       forKey:[[subcomponents objectAtIndex:0] urlDecodedString]];
    }
    
    return parameters;
}

- (NSString*) urlDecodedString {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
         
- (NSString*) urlEncodedString {
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
