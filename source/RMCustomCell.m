#import "RMCustomCell.h"

@implementation RMCustomCell

@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;//Do I need these?

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contestIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 20, 20)];
        self.contestIcon.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:self.contestIcon];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 5, self.frame.size.width - 50, 30)];
        self.textLabel.font = [UIFont fontWithName:@"Arial" size:16.0f];
        [self addSubview:self.textLabel];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 30, self.frame.size.width - 50, 30)];
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:13.0f];
        [self addSubview:self.detailTextLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
