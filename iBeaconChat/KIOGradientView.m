//
//  Gradient.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 25.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIOGradientView.h"

@implementation KIOGradientView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
//    CGFloat gradientRadius = rect.size.height;
//    CGPoint gradientCenter = CGPointMake(rect.size.width/2, gradientRadius);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat gradientLocations[] = {0, 1};
    UIColor *c1 = _colorA;
    UIColor *c2 = _colorB;
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(id)c1.CGColor, (id)c2.CGColor], gradientLocations);
        
    CGContextSaveGState(context);
    
    CGPoint pointInside = CGPointMake(CGRectGetMidX(rect), CGRectGetHeight(rect) * 0.9f);
    CGPoint pointOutside = CGPointMake(CGRectGetMidX(rect), CGRectGetHeight(rect) * 0.75f);
    
    CGContextDrawRadialGradient(context, gradient,
                                pointInside, 0.f,
                                pointOutside, MAX(CGRectGetMidX(rect), CGRectGetMidY(rect)),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
