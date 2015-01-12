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
    
    CGPoint p1 = CGPointMake(CGRectGetMidX(rect), CGRectGetHeight(rect) * 0.9f);
    CGPoint p2 = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGContextDrawRadialGradient(context, gradient, p1, 0.f, p2, MAX(CGRectGetMidX(rect), CGRectGetMidY(rect)),
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
