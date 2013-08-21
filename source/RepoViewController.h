#import <UIKit/UIKit.h>
#import "Octokit.h"

@class RepoViewController;

@protocol RepoViewControllerDelegate <NSObject>
- (void)addItemViewController:(RepoViewController *)controller didFinishEnteringItem:(BOOL)shouldReload;
@end

@interface RepoViewController : UIViewController

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *repo;
@property (strong, nonatomic) OCTClient *client;
@property (nonatomic, weak) id <RepoViewControllerDelegate> delegate;

@end