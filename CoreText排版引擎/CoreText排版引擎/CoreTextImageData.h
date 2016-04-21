//
//  CoreTextImageData.h
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextImageData : NSObject

@property(strong ,nonatomic)NSString *name;
@property(assign ,nonatomic)NSUInteger position;
@property(assign ,nonatomic)CGRect imagePosition;

@end
