//
//  CoreTextData.h
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextData : NSObject

@property(assign ,nonatomic)CTFrameRef ctFrame;
@property(assign ,nonatomic)CGFloat height;
@property(strong ,nonatomic)NSMutableArray *imageArray;
@property(strong ,nonatomic)NSMutableArray *linkArray;

@end
