//
//  ReadmeViewController.m
//  CRMultiRowSelector
//
//  Created by Richard Burton on 7/15/13.
//
//

#import "ReadmeViewController.h"

@interface ReadmeViewController ()

@end

@implementation ReadmeViewController

- (id)init {
    self = [super init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width,self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    
    UINavigationBar *myBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
    [self.view addSubview:myBar];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Done"
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(remove:)];
    UINavigationItem *item = [[UINavigationItem alloc]init];
    [item setRightBarButtonItem:backButton];
    [myBar setItems:[NSArray arrayWithObject:item]];

    self.webView.delegate = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];

}

- (void)remove:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error");
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start laoding");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //NS
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finish loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
