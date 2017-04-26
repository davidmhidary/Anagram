//
//  RatingViewController.m
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RatingView.h"

@implementation RatingView

@synthesize s1, s2, s3, s4, s5;


-(void)setImagesDeselected:(NSString *)deselectedImage
			partlySelected:(NSString *)halfSelectedImage
			  fullSelected:(NSString *)fullSelectedImage
			   andDelegate:(id<RatingViewDelegate>)d {
	unselectedImage = [UIImage imageNamed:deselectedImage];
	partlySelectedImage = halfSelectedImage == nil ? unselectedImage : [UIImage imageNamed:halfSelectedImage];
	fullySelectedImage = [UIImage imageNamed:fullSelectedImage];
	viewDelegate = d;
	
	height=0.0; width=0.0;
    
	if (height < [fullySelectedImage size].height) {
		height = [fullySelectedImage size].height;
	}
	if (height < [partlySelectedImage size].height) {
		height = [partlySelectedImage size].height;
	}
	if (height < [unselectedImage size].height) {
		height = [unselectedImage size].height;
	}
	if (width < [fullySelectedImage size].width) {
		width = [fullySelectedImage size].width;
	}
	if (width < [partlySelectedImage size].width) {
		width = [partlySelectedImage size].width;
	}
	if (width < [unselectedImage size].width) {
		width = [unselectedImage size].width;
	}
//	width=width/2;
//	height=height/2;
	starRating = 0;
	lastRating = 0;
    
    float padding=10.0;
    
    if (!s1)
    {
        s1 = [[UIImageView alloc] initWithImage:unselectedImage];
        [s1 setFrame:CGRectMake(0,0, width, height)];
        [self addSubview:s1];
        [s1 setUserInteractionEnabled:NO];
    }
    if (!s2)
    {
        s2 = [[UIImageView alloc] initWithImage:unselectedImage];
        [s2 setFrame:CGRectMake(width+padding,     0, width, height)];
        [self addSubview:s2];
        [s2 setUserInteractionEnabled:NO];
    }
    if (!s3)
    {
        s3 = [[UIImageView alloc] initWithImage:unselectedImage];
        [s3 setFrame:CGRectMake(2 * (width+padding), 0, width, height)];
        [self addSubview:s3];
        [s3 setUserInteractionEnabled:NO];
    }
    if (!s4)
    {
        s4 = [[UIImageView alloc] initWithImage:unselectedImage];
        [s4 setFrame:CGRectMake(3 * (width+padding), 0, width, height)];
        [self addSubview:s4];
        [s4 setUserInteractionEnabled:NO];
    }
    if (!s5)
    {
        s5 = [[UIImageView alloc] initWithImage:unselectedImage];
        [s5 setFrame:CGRectMake(4 * (width+padding), 0, width, height)];
        [self addSubview:s5];
        [s5 setUserInteractionEnabled:NO];
	}
	
//	[s2 setUserInteractionEnabled:NO];
//	[s3 setUserInteractionEnabled:NO];
//	[s4 setUserInteractionEnabled:NO];
//	[s5 setUserInteractionEnabled:NO];
//	
	
	CGRect frame = [self frame];
	frame.size.width = width * 5+40;
	frame.size.height = height;
	[self setFrame:frame];
}

-(void)displayRating:(float)rating {
	[s1 setImage:unselectedImage];
	[s2 setImage:unselectedImage];
	[s3 setImage:unselectedImage];
	[s4 setImage:unselectedImage];
	[s5 setImage:unselectedImage];
	
	if (rating >= 0.5) {
		[s1 setImage:partlySelectedImage];
	}
	if (rating >= 1) {
		[s1 setImage:fullySelectedImage];
	}
	if (rating >= 1.5) {
		[s2 setImage:partlySelectedImage];
	}
	if (rating >= 2) {
		[s2 setImage:fullySelectedImage];
	}
	if (rating >= 2.5) {
		[s3 setImage:partlySelectedImage];
	}
	if (rating >= 3) {
		[s3 setImage:fullySelectedImage];
	}
	if (rating >= 3.5) {
		[s4 setImage:partlySelectedImage];
	}
	if (rating >= 4) {
		[s4 setImage:fullySelectedImage];
	}
	if (rating >= 4.5) {
		[s5 setImage:partlySelectedImage];
	}
	if (rating >= 5) {
		[s5 setImage:fullySelectedImage];
	}
	
	starRating = rating;
	lastRating = rating;
	[viewDelegate ratingChanged:rating];
}

-(void) touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
{
	[self touchesMoved:touches withEvent:event];
}

-(void) touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
{
	CGPoint pt = [[touches anyObject] locationInView:self];
	float newRating = (float) (pt.x / (width+10)) + 1;
//	if (newRating < 1 || newRating > 5)
//		return;
	if (newRating < 1)
        newRating=1.0;
	
    if (newRating > 5)
        newRating=5.0;

	if (newRating != lastRating)
		[self displayRating:newRating];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[self touchesMoved:touches withEvent:event];
}

-(float)rating {
	return starRating;
}

@end
