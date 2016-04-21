//
//  Utils.h
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CoreTextLinkData;
@class CoreTextData;

@interface CoreTextUtils : NSObject

+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

@end
