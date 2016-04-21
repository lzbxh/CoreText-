//
//  CTFrameParser.h
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"
#import "CoreTextImageData.h"
#import "CTFrameParserConfig.h"

@interface CTFrameParser : NSObject

//装载NSString
+(CoreTextData *)parseContent:(NSString *)content Config:(CTFrameParserConfig *)config;

//+(CoreTextData *)parseTempLateFile:(NSString *)path config:(CTFrameParserConfig *)config imageArray:(NSMutableArray *)imageArray;
+(CoreTextData *)parseTempLateFile:(NSString *)path config:(CTFrameParserConfig *)config;

//装载NSAttributedString
+(CoreTextData *)parseAttributedContent:(NSAttributedString *)content Config:(CTFrameParserConfig *)config;

+(NSDictionary *)attributesWithConfig:(CTFrameParserConfig *)config;

@end
