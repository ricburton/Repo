#import <UIKit/UIKit.h>

@class RepoViewController;

@protocol RepoViewControllerDelegate <NSObject>
- (void)addItemViewController:(RepoViewController *)controller didFinishEnteringItem:(BOOL)shouldReload;
@end

@interface RepoViewController : UIViewController

@property (strong, nonatomic) NSURL *url;
@property (nonatomic, weak) id <RepoViewControllerDelegate> delegate;

@end