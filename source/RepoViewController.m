#import "RepoViewController.h"
#import "MBProgressHUD.h"
#import "RootViewController.h"
#import "Reachability.h"
#import "GitHubOAuth.h"
#import "Octokit.h"

@interface RepoViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UIButton *starBtn;

@end

@implementation RepoViewController
{
    MBProgressHUD *hud;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.delegate addItemViewController:self didFinishEnteringItem:NO];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)];
    
    [self.view addSubview:self.webView];
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.animationType = MBProgressHUDAnimationZoomIn;
    hud.labelText = @"Loading";
    
    for (id subView in [self.view subviews]) {
        if ([subView respondsToSelector:@selector(flashScrollIndicators)]) {
            [subView flashScrollIndicators];
        }
    }
    
    self.webView.delegate = self;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
    
    UIImage *removeImg = [UIImage imageNamed:@"x_circle.png"];
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setImage:removeImg forState:UIControlStateNormal];
    [removeBtn setFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width - 133,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
    [removeBtn setContentMode:UIViewContentModeCenter];
    [removeBtn setContentEdgeInsets:UIEdgeInsetsMake(10, 85.5, 10, 14.5)];
    [removeBtn addTarget:self action:@selector(remove:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeBtn];
    
    if (self.client) {//TODO View did appear.
        //Starred already?
        
//        NSData *stargazer = [self gazing:@selector(gazing:completionHandler:) completionHandler:ch];
        self.starBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        BOOL *stargazer = FALSE;
        if (stargazer) {
            UIImage *starImg = [UIImage imageNamed:@"star_circle.png"];
            [self.starBtn setImage:starImg forState:UIControlStateNormal];
            
            [self.starBtn addTarget:self action:@selector(star:) forControlEvents:UIControlEventTouchUpInside];

        } else {
            UIImage *starImg = [UIImage imageNamed:@"unstar_circle.png"];
            [self.starBtn setImage:starImg forState:UIControlStateNormal];
        }
        
        [self.starBtn setFrame: CGRectMake(0,[[UIScreen mainScreen] bounds].size.height - 73.65,133,53)];
        [self.starBtn setContentMode:UIViewContentModeCenter];
        [self.starBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 14.5, 10, 85.5)];
        [self.view addSubview:self.starBtn];
    } else {
        //Not logged in so no starring.
    }
}

- (void) star:(id)sender
{
//    (NSString *)repository client:(OCTClient *)client
    NSString *repository = self.repo;
    OCTClient *client = self.client;

    //PUT /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/%@" stringByAppendingString:repository];
    [client putPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Starred successfully");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful stargazing");
    }];
}

- (void) unstar:(id)sender
{
    NSString *repository = self.repo;
    OCTClient *client = self.client;
    
    //DELETE /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/%@" stringByAppendingString:repository];
    [client deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Unstarred successfully");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful unstarring");
    }];
}

- (BOOL) gazing:(id)sender completionHandler:(void (^)(id))handler
{
    NSString *repository = self.repo;
    OCTClient *client = self.client;
    
    //GET /user/starred/:owner/:repo
    NSString *path = [@"/user/starred/%@" stringByAppendingString:repository];
    [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Unstarred successfully");
        handler(responseObject);
//        handler(return TRUE);
//        NSInteger *status = [operation.response statusCode];
//        return TRUE;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unsuccessful unstarring");
}];
    
    
    
//    -- (void) gazingRepos:(OCTClient *)client completionHandler:(void (^)(id))handler  {
//        -    [client getPath:@"/user/starred" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            -        handler(responseObject);
//            -    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                -        NSLog(@"Gazing request failed.");
//                -    }];
    
//    client.?/
    
//    if (status == 204) {
//        return TRUE;
//    } else {
//        return FALSE;
//    }
    
}


- (void)remove:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:nil];
    [self.webView stopLoading];
    self.webView.delegate = nil;
}
    
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [hud hide: YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)rq
{
    [hud hide: NO];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"readme_load" properties:@{
     @"load": self.url
     }];
}

@end
