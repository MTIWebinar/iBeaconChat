//
//  UIView+Scanner.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 07.01.15.
//  Copyright (c) 2015 Kirill Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Scanner)
+ (UIView *)pulsingCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color;
+ (UIView *)scaningCircleWithRadius:(CGFloat)radius position:(CGPoint)point color:(UIColor *)color;
@end
