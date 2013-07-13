#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *langLabel;
@property (nonatomic, weak) IBOutlet UILabel *subLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) NSString *url;

//@pro//

@end
//Is this the way the code should work?


