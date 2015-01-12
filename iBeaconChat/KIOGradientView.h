//
//  Gradient.h
//  iBeaconChat
//
//  Created by Kirill Osipov on 25.12.14.
//  Copyright (c) 2014 Kirill Osipov. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface KIOGradientView : UIView

@property (nonatomic) IBInspectable UIColor *colorA;
@property (nonatomic) IBInspectable UIColor *colorB;

@end
