//
//  DQTextView.h
//  DQTextView
//
//  Created by danielzhao on 8/5/13.
//  Copyright (c) 2013 danqiangzhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DQTextView : UITextView

@property(nonatomic, retain) NSString *placeholder;

@property (nonatomic, assign) BOOL isGlowing;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *glowingColor;
@property (nonatomic, strong) UIColor *hightlyColor;

- (void)showHightly;

@end
