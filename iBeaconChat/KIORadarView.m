//
//  KIOScannerView.m
//  iBeaconChat
//
//  Created by Kirill Osipov on 08.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import "KIORadarView.h"

#define DEGREES(radians)    ((radians)*180/M_PI)
#define RADIANS(degree)     ((degree)*M_PI/180)

@implementation KIORadarView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat radarRadius = rect.size.height;
    CGPoint radarCenter = CGPointMake(rect.size.width/2, radarRadius);
    
    float angle = atanf(radarRadius/(rect.size.width/2));
    float aAngle = (float)(M_PI + angle);
    float bAngle = (float)(M_PI * 2 - angle);
    
    [_color setStroke];
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    float stepLinesAngle = (aAngle-bAngle)/_segmentCount;
    float stepCircls = radarRadius/_segmentCount;

    for (int i=0; i<=_segmentCount; i++) {
        
        // draw radar line
        CGPoint startPoint;
        startPoint.x = radarCenter.x + (stepCircls - _shadowRadius * 2) * cos(aAngle - stepLinesAngle * i);
        startPoint.y = radarCenter.y + (stepCircls - _shadowRadius * 2) * sin(aAngle - stepLinesAngle * i);

        CGPoint endPoint;
        endPoint.x = radarCenter.x + radarRadius * cos(aAngle - stepLinesAngle * i);
        endPoint.y = radarCenter.y + radarRadius * sin(aAngle - stepLinesAngle * i);
        
        UIBezierPath *bezierPathLine = UIBezierPath.bezierPath;
        bezierPathLine.lineWidth = _segmentWidth;
        bezierPathLine.lineCapStyle = kCGLineCapRound;
        [bezierPathLine moveToPoint:startPoint];
        [bezierPathLine addLineToPoint:endPoint];
        
        // draw radar circle
        UIBezierPath *bezierPathCicle = UIBezierPath.bezierPath;
        bezierPathCicle.lineWidth = _segmentWidth;
        bezierPathCicle.lineCapStyle = kCGLineCapRound;
        [bezierPathCicle addArcWithCenter:radarCenter radius:stepCircls*i-_segmentWidth-_shadowRadius startAngle:aAngle endAngle:bAngle clockwise:YES];
        
        // draw shadow
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, CGSizeMake(0.1, -0.1), (float)_shadowRadius, _color.CGColor);

        [bezierPathLine stroke];
        [bezierPathCicle stroke];
    }
    
    CGContextRestoreGState(context);
}


@end
