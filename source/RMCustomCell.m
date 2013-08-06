#import "RMCustomCell.h"

@implementation RMCustomCell

@synthesize repoTitle = _repoTitle;
@synthesize repoDescription = _repoDescription;//Do I need these?

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contestIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, 18, 28, 28)];
        self.contestIcon.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:self.contestIcon];
        
        self.repoDescription = [[UILabel alloc] initWithFrame:CGRectMake(38, 25, self.frame.size.width - 43, 25)];
        self.repoDescription.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
        [self addSubview:self.repoDescription];
        
        self.repoTitle = [[UILabel alloc] initWithFrame:CGRectMake(38, 8, self.frame.size.width - 43, 25)];
        self.repoTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
        [self addSubview:self.repoTitle];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
