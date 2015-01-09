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

@property (nonatomic) IBInspectable UIColor *color;

@property (nonatomic) IBInspectable NSUInteger segmentCount;
@property (nonatomic) IBInspectable NSUInteger segmentWidth;

@property (nonatomic) IBInspectable NSUInteger shadowRadius;

@end
