#import <UIKit/UIKit.h>

@class ReadmeViewController;

@protocol ReadmeViewControllerDelegate <NSObject>
- (void)addItemViewController:(ReadmeViewController *)controller didFinishEnteringItem:(BOOL)shouldReload;
@end

@interface ReadmeViewController : UIViewController

@property (strong, nonatomic) NSURL *url;
@property (nonatomic, weak) id <ReadmeViewControllerDelegate> delegate;

@end