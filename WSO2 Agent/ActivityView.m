/**
 *  Copyright (c) 2011, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 * 	Description : - Activity indicator class
 */

#import "ActivityView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ActivityView

@synthesize activityIndicator;
@synthesize msgLabel;

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
    
    
    self.frame = CGRectMake(100, 200, 120, 120);
    self.layer.cornerRadius = 15;
    self.opaque = NO;
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
    
    self.msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 81, 22)];
    self.msgLabel.text = @"Loading..";
    self.msgLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.msgLabel.textAlignment = UITextAlignmentCenter;
    self.msgLabel.textColor = [UIColor blackColor];
    self.msgLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.msgLabel];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake(42, 54, 37, 37);
    [self.activityIndicator startAnimating];
    
    [self addSubview:self.activityIndicator];
}

@end
