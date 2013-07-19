//
//  ReadmeViewController.h
//  CRMultiRowSelector
//
//  Created by Richard Burton on 7/15/13.
//
//

#import <UIKit/UIKit.h>

@interface ReadmeViewController : UIViewController <UIWebViewDelegate> {
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

@end
