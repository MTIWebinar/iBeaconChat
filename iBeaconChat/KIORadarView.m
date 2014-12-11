//
//  KIOScannerView.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 08.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIORadarView.h"


@interface CAGradientLayer (Gradient)
+ (CAGradientLayer *)horizontalMask;
@end
@implementation CAGradientLayer (Gradient)
+ (CAGradientLayer *)horizontalMask {
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    UIColor *c1 = [UIColor whiteColor];
    UIColor *c2 = [UIColor clearColor];
    
    gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    
    gradientLayer.locations = @[@0.0f, @0.5f, @1.0f];
    gradientLayer.colors = @[(id)c2.CGColor, (id)c1.CGColor, (id)c2.CGColor];
    
    return gradientLayer;
}
@end







@implementation KIORadarView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    CAGradientLayer *bgMask = [CAGradientLayer horizontalMask];
    bgMask.frame = rect;
    self.layer.mask = bgMask;

    CGContextRef context = UIGraphicsGetCurrentContext();

    // bg
    CGContextSetRGBFillColor(context, 0.95, 0.95, 0.95, 0.20);
    CGContextFillRect(context, rect);
    
    CGContextMoveToPoint(context, width/2, .0f);
    CGContextAddLineToPoint(context, width/2, height);
    
    CGContextMoveToPoint(context, .0f, height -_circleWidth*4);
    CGContextAddLineToPoint(context, width, height -_circleWidth*4);
    
    CGContextSetLineWidth(context, _fieldLineWidth);
    CGContextSetStrokeColorWithColor(context, _fieldLineColor.CGColor);
    
    CGContextDrawPath(context, kCGPathFillStroke);

    // radar
    float startAngle = atanf(tanf(height / (width/2)));
    float endAngle = -((float)M_PI + startAngle);
    
    for (int i=1; i<_circleCount+1; i++) {
        CGContextAddArc(context, width/2, height, height/i-_circleWidth*4, startAngle, endAngle, YES);
        CGContextSetLineWidth(context, _circleWidth);
        CGContextSetStrokeColorWithColor(context, _circleColor.CGColor);
        CGContextStrokePath(context);
    }
}


@end
