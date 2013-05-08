//
//  DQTextView.m
//  DQTextView
//
//  Created by danielzhao on 8/5/13.
//  Copyright (c) 2013 danqiangzhao. All rights reserved.
//

#import "DQTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface DQTextView ()

@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic, readonly) NSString *realText;

- (void) _configureView;
- (void) checkEditing:(NSNotification*) notification;

@end


@implementation DQTextView

- (void)_configureView{
    
    self.clipsToBounds = YES;
	
	if (!self.backgroundColor)
	{
		self.backgroundColor = [UIColor whiteColor];
	}
    
    if (!self.hightlyColor)
	{
		self.hightlyColor = [UIColor redColor];
	}
	
	if (!self.glowingColor)
	{
		self.glowingColor = [UIColor colorWithRed:(82.f / 255.f) green:(168.f / 255.f) blue:(236.f / 255.f) alpha:0.8];
	}
	
	if (!self.borderColor)
	{
		self.borderColor = [UIColor lightGrayColor];
	}
    
    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 4.f;
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = self.borderColor.CGColor;
	
    self.layer.shadowColor = self.glowingColor.CGColor;
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4.f].CGPath;
    self.layer.shadowOpacity = 0;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 5.f;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    self.alwaysGlowing = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEditing:) name:UITextViewTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    
    self.textColor = [UIColor blackColor];
    self.placeholderColor = [UIColor lightGrayColor];
    
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = self.font;
    _placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _placeholderLabel.textColor = self.placeholderColor;
    [self addSubview:_placeholderLabel];
    
    [self sendSubviewToBack:_placeholderLabel];
        
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _configureView];
        
    }
    return self;
}

- (void)awakeFromNib {
    
    [self _configureView];
    
}

#pragma mark -
#pragma mark Setter/Getters

- (void) setPlaceholder:(NSString *)aPlaceholder {
    
    _placeholder = aPlaceholder;
    
    _placeholderLabel.text = _placeholder;
    
    CGSize maximumLabelSize = self.bounds.size;
    
    CGSize expectedLabelSize = [_placeholder sizeWithFont:_placeholderLabel.font
                                        constrainedToSize:maximumLabelSize
                                            lineBreakMode:_placeholderLabel.lineBreakMode];
    
    _placeholderLabel.frame = CGRectMake(10, 8, expectedLabelSize.width, expectedLabelSize.height);
    
}

- (void) setText:(NSString *)text {
    
    super.text = text;
    
}

- (NSString *) realText {
    return [[self text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) checkEditing:(NSNotification*) notification {
    
    if (![self.realText isEqualToString:@""]) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
    
}

- (void)setGlowingColor:(UIColor *)glowingColor
{
	if ([self isFirstResponder] || self.isGlowing) {
		[self animateBorderColorChangeFrom:(id)self.layer.borderColor to:(id)glowingColor.CGColor shadowOpacityFrom:(id)[NSNumber numberWithFloat:1.f] to:(id)[NSNumber numberWithFloat:1.f]];
	}
	
	_glowingColor = glowingColor;
	self.layer.shadowColor = glowingColor.CGColor;
}

- (void)setBorderColor:(UIColor *)borderColor
{
	_borderColor = borderColor;
	
	if (![self isFirstResponder] && !self.isGlowing)
	{
		self.layer.borderColor = self.borderColor.CGColor;
	}
}

- (void)setAlwaysGlowing:(BOOL)isGlowing
{
	if (_isGlowing && !isGlowing && ![self isFirstResponder]) {
		[self hideGlowing];
	} else if (!_isGlowing && isGlowing && ![self isFirstResponder]) {
		[self showGlowing];
	}
	
	_isGlowing = isGlowing;
}

- (void)animateBorderColorChangeFrom:(id)fromColor to:(id)toColor shadowOpacityFrom:(id)fromOpacity to:(id)toOpacity
{
    CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderColorAnimation.fromValue = fromColor;
    borderColorAnimation.toValue = toColor;
	
    CABasicAnimation *shadowOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowOpacityAnimation.fromValue = fromOpacity;
    shadowOpacityAnimation.toValue = toOpacity;
	
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.0f / 3.0f;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations = @[borderColorAnimation, shadowOpacityAnimation];
	
    [self.layer addAnimation:group forKey:nil];
}

- (BOOL)becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];
	
    if (result && !self.isGlowing)
    {
        [self showGlowing];
    }
    return result;
}

- (BOOL)resignFirstResponder
{
    BOOL result = [super resignFirstResponder];
	
    if (result && !self.isGlowing)
    {
        [self hideGlowing];
    }
    return result;
}

- (void)showHightly
{
	[self animateBorderColorChangeFrom:(id)self.layer.borderColor to:(id)[self.hightlyColor CGColor] shadowOpacityFrom:(id)[NSNumber numberWithFloat:0.f] to:(id)[NSNumber numberWithFloat:1.f]];
}


- (void)showGlowing
{
	[self animateBorderColorChangeFrom:(id)self.layer.borderColor to:(id)self.layer.shadowColor shadowOpacityFrom:(id)[NSNumber numberWithFloat:0.f] to:(id)[NSNumber numberWithFloat:1.f]];
}

- (void)hideGlowing
{
	[self animateBorderColorChangeFrom:(id)self.layer.borderColor to:(id)self.borderColor.CGColor shadowOpacityFrom:(id)[NSNumber numberWithFloat:1.f] to:(id)[NSNumber numberWithFloat:0.f]];
}

@end
