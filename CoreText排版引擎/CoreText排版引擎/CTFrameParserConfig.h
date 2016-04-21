//
//  CTFrameParserConfig.h
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTFrameParserConfig : NSObject

@property(assign ,nonatomic)CGFloat width;
@property(assign ,nonatomic)CGFloat fontSize;
@property(assign ,nonatomic)CGFloat lineSpace;
@property(strong ,nonatomic)UIColor *textColor;

@end
