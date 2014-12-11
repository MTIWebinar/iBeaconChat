//
//  KIOScannerView.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 08.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface KIORadarView : UIView

@property (nonatomic) IBInspectable NSInteger circleCount;
@property (nonatomic) IBInspectable NSInteger circleWidth;
@property (nonatomic) IBInspectable UIColor *circleColor;

@property (nonatomic) IBInspectable NSInteger fieldLineCount;
@property (nonatomic) IBInspectable NSInteger fieldLineWidth;
@property (nonatomic) IBInspectable UIColor *fieldLineColor;

@end
