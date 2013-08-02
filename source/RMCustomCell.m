#import "RMCustomCell.h"

@implementation RMCustomCell

@synthesize textLabel = _textLabel;
@synthesize detailTextLabel = _detailTextLabel;//Do I need these?

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contestIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 18, 28, 28)];
        self.contestIcon.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:self.contestIcon];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 25, self.frame.size.width - 43, 25)];
        self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
        [self addSubview:self.detailTextLabel];
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 8, self.frame.size.width - 43, 25)];
        self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        [self addSubview:self.textLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
