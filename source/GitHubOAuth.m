#import "GitHubOAuth.h"
#import "Tokens.h"

@implementation GitHubOAuth

+ (GitHubOAuth *)sharedClient {
    static GitHubOAuth *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[GitHubOAuth alloc] initWithClientID:GITHUB_CLIENT_ID
                                                 clientSecret:GITHUB_CLIENT_SECRET
                                                 authorizeURL:[NSURL URLWithString:@"https://github.com/login/oauth/authorize"]
                                               accessTokenURL:[NSURL URLWithString:@"https://github.com/login/oauth/access_token"]
                                                    urlScheme:@"Repo"];
    });
    
    return _sharedClient;
}

@end