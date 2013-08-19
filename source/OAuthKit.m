#import "OAuthKit.h"
#import "NSURL+OAuthKit.h"

@implementation OAuthKit

@synthesize clientID, clientSecret, authorizeURL, accessTokenURL, urlScheme;

- (id) initWithClientID:(NSString*)_clientID
           clientSecret:(NSString*)_clientSecret
           authorizeURL:(NSURL*)_authorizeURL
         accessTokenURL:(NSURL*)_accessTokenURL
              urlScheme:(NSString*)_urlScheme {
    
    self = [super init];
    if (self == nil) return self;
    
    self.clientID       = _clientID;
    self.clientSecret   = _clientSecret;
    self.authorizeURL   = _authorizeURL;
    self.accessTokenURL = _accessTokenURL;
    self.urlScheme      = _urlScheme;
    
    return self;
}

- (void) authorizeWithParams:(NSDictionary*)params {
    NSMutableDictionary* queryParams = [NSMutableDictionary dictionary];
    
    [queryParams setObject:self.clientID forKey:@"client_id"];
    [queryParams setObject:[NSString stringWithFormat:@"%@://authorize", self.urlScheme] forKey:@"redirect_uri"];
    
    if (params) {
        [queryParams addEntriesFromDictionary:params];
    }
    
    NSURL* url = [self.authorizeURL urlByAddingQueryParams:queryParams];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) authorize {
    [self authorizeWithParams:nil];
}

- (void) requestAccessToken:(NSString*)code completionHandler:(void (^)(NSString*, AFHTTPRequestOperation*, NSError*))handler {
    NSDictionary *params = @{@"client_id": self.clientID, @"client_secret": self.clientSecret, @"code": code};
    
    NSURL *hostURL = [[NSURL URLWithString:@"/" relativeToURL:self.accessTokenURL] absoluteURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:hostURL];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client postPath:[self.accessTokenURL path] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* token = [responseObject valueForKeyPath:@"access_token"];
        handler(token, operation, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(nil, operation, error);
    }];
}

@end
