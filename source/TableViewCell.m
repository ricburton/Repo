// Copyright 2013 Richard Burton.
// Derived from CRTableViewCell by Christian Roman.

/*
 Copyright 2012 Christian H. Roman Mendoza / Daniel Rueda Jimenez
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */


#import "TableViewCell.h"

/* Macro for background colors */
#define colorWithRGBHex(hex)[UIColor colorWithRed:((float)((hex&0xFF0000)>>16))/255.0 green:((float)((hex&0xFF00)>>8))/255.0 blue:((float)(hex&0xFF))/255.0 alpha:1.0]
#define clearColorWithRGBHex(hex)[UIColor colorWithRed:((float)((hex&0xFF0000)>>16))/255.0 green:((float)((hex&0xFF00)>>8))/255.0 blue:((float)(hex&0xFF))/255.0 alpha:1.0]

/* Unselected mark constants */
#define kCircleRadioUnselected      23.0
#define kCircleLeftMargin           13.0
#define kCircleRect                 CGRectMake(3.5, 2.5, 22.0, 22.0)
#define kCircleOverlayRect          CGRectMake(1.5, 12.5, 26.0, 23.0)

/* Mark constants */
#define kStrokeWidth                2.0
#define kShadowRadius               .0
#define kMarkDegrees                70.0
#define kMarkWidth                  3.0
#define kMarkHeight                 6.0
#define kShadowOffset               CGSizeMake(.0, .0)
#define kMarkShadowOffset           CGSizeMake(.0, .0)
#define kMarkImageSize              CGSizeMake(30.0, 30.0)
#define kMarkBase                   CGPointMake(9.0, 13.5)
#define kMarkDrawPoint              CGPointMake(20.0, 9.5)
#define kShadowColor                [UIColor colorWithRed:124 green:124 blue:124 alpha:100]
#define kMarkShadowColor            [UIColor colorWithRed:124 green:124 blue:124 alpha:100]
#define kBlueColor                  0x4686C5
#define kMarkColor                  kBlueColor

/* Colums and cell constants */
#define kColumnPosition             50.0
#define kMarkCell                   60.0
#define kImageRect                  CGRectMake(10.0, 8.0, 30.0, 30.0)

@implementation TableViewCell

// TODO: do these really need to be different ivars than provided by the parent class?
@synthesize textLabel = label;
@synthesize imageView = imageView;

- (void)drawRect:(CGRect)rect
{    
    _isSelected = NO;
    
    CGFloat posY = (rect.size.height/2) - kCircleRadioUnselected/2;
    
    CGRect unselectedCircleRect = CGRectMake(kCircleLeftMargin, posY, kCircleRadioUnselected, kCircleRadioUnselected);
    CGRect imageViewRect = CGRectMake(10, rect.size.height/2 - kCircleLeftMargin - 1, kMarkCell/2, kMarkCell/2);
    
    imageView.frame = imageViewRect; // Center the imageView
    
    UIBezierPath *unselectedCircle = [UIBezierPath bezierPathWithOvalInRect:unselectedCircleRect]; // Unselected circle centered
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /* Unselected circle */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, unselectedCircle.CGPath);
        CGContextSetLineWidth(ctx, kStrokeWidth);
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBStrokeColor(ctx, 229/255.0, 229/255.0, 229/255.0, 1.0);
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
    CGContextRestoreGState(ctx);
    
    /* Column separator */
    CGContextSetRGBStrokeColor(ctx, 224/255.0, 224/255.0, 224/255.0, .0);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextMoveToPoint(ctx, kColumnPosition, .0);
    CGContextAddLineToPoint(ctx, kColumnPosition, self.bounds.size.height);
    CGContextSetShouldAntialias(ctx, NO);
    CGContextStrokePath(ctx);
    
    [super drawRect:rect];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(kMarkCell, .0, self.frame.size.width - kMarkCell, self.frame.size.height)];
        label.textColor = [UIColor blackColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:label];
        
        imageView = [UIImageView new];
        [self.contentView addSubview:imageView];
        
        _renderedMark = [self renderMark];
    }
    return self;
}

#pragma mark - Properties
- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    self.imageView.image = (isSelected) ? _renderedMark : nil;
}

- (UIImage *)renderMark
{
    if(_renderedMark)
        return _renderedMark;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(kMarkImageSize, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(kMarkImageSize);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *markCircle = [UIBezierPath bezierPathWithOvalInRect:kCircleRect];
    
    /* Background */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextSetFillColorWithColor(ctx, clearColorWithRGBHex(kMarkColor).CGColor);
        CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowRadius, kShadowColor.CGColor );
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    
    /* Overlay */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextClip(ctx);
        CGContextAddEllipseInRect(ctx, kCircleOverlayRect);
        CGContextSetFillColorWithColor(ctx, colorWithRGBHex(kMarkColor).CGColor);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    CGContextRestoreGState(ctx);
    
    /* Stroke */
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, markCircle.CGPath);
        CGContextSetLineWidth(ctx, kStrokeWidth);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    CGContextRestoreGState(ctx);
    
    /* Mark */
    CGContextSaveGState(ctx);
    {
        CGContextSetShadowWithColor(ctx, kMarkShadowOffset, .0, kMarkShadowColor.CGColor );
        CGContextMoveToPoint(ctx, kMarkBase.x, kMarkBase.y);
        CGContextAddLineToPoint(ctx, kMarkBase.x + kMarkHeight * sin(kMarkDegrees), kMarkBase.y + kMarkHeight * cos(kMarkDegrees));
        CGContextAddLineToPoint(ctx, kMarkDrawPoint.x, kMarkDrawPoint.y);
        CGContextSetLineWidth(ctx, kMarkWidth);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);
    
    UIImage *selectedMark = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return selectedMark;
}

@end
