//
//  UIView+Scanner.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 07.01.15.
//  Copyright (c) 2015 Kirill Osipov. All rights reserved.
//

#import "UIView+Scanner.h"


@implementation UIView (Scanner)

+ (UIView *)pulsingCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    view.center = point;
    view.backgroundColor = color;
    view.layer.cornerRadius = radius;
    
    CABasicAnimation *scaleAnimation;
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @0.0f;
    scaleAnimation.toValue = @1.0f;
    
    CAKeyframeAnimation *opacityAnimation;
    opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[@0.2f, @0.4f, @0.0f];
    opacityAnimation.keyTimes = @[@0.0f, @0.3f, @1.0f];
    opacityAnimation.removedOnCompletion = NO;
    
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = .8f * 4;
    groupAnimation.repeatCount = HUGE_VAL;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.animations = @[opacityAnimation, scaleAnimation];
    
    [view.layer addAnimation:groupAnimation forKey:@"groupAnimation"];
    
    return view;
}

+ (UIView *)scaningCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    view.center = point;
    view.backgroundColor = UIColor.clearColor;
    view.layer.cornerRadius = radius;
    
    
    // radar view for animation
    UIBezierPath *bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint:CGPointMake(view.frame.size.width/2, view.frame.size.height/2 - 50)];
    [bezierPath addLineToPoint:CGPointMake(view.frame.size.width/2, 30)];
    
    CAShapeLayer *mask = CAShapeLayer.layer;
    mask.lineWidth = 2.f;
    mask.lineCap = @"round";
    mask.strokeColor = color.CGColor;
    mask.path = bezierPath.CGPath;
    [view.layer addSublayer:mask];
    
    
    // animation
    float angle = (float)(M_PI_2 - atanf(CGRectGetHeight(view.frame)/(CGRectGetWidth(view.frame)/2)));
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.autoreverses = YES;
    rotationAnimation.duration = 2.3f;
    rotationAnimation.repeatCount = HUGE_VAL;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fromValue = [NSNumber numberWithFloat:-angle];
    rotationAnimation.toValue = [NSNumber numberWithFloat:angle];
    [view.layer addAnimation:rotationAnimation forKey:@"animateLayer"];

    return view;
}

@end
