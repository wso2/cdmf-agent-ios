//
//  ActivityView.m
//  WSO2 Agent
//
//  Created by WSO2 on 10/7/13.
//  Copyright (c) 2013 WSO2. All rights reserved.
//

#import "ActivityView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActivityView

@synthesize activityIndicator;
@synthesize msgLabel;
//@synthesize backgroundView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)configureView{
        
    //UIView *loading = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 120, 120)];
    
    self.frame = CGRectMake(100, 200, 120, 120);
    self.layer.cornerRadius = 15;
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    
    self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 81, 22)];
    self.msgLabel.text = @"Loading..";
    self.msgLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.msgLabel.textAlignment = UITextAlignmentCenter;
    //self.msgLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    self.msgLabel.textColor = [UIColor blackColor];
    self.msgLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.msgLabel];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake(42, 54, 37, 37);
    [self.activityIndicator startAnimating];
    
    [self addSubview:self.activityIndicator];
}

@end
