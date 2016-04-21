//
//  CTFrameParser.m
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import "CTFrameParser.h"
#import "CoreTextLinkData.h"

@implementation CTFrameParser

//使用NSString生成CoreTextData
+(CoreTextData *)parseContent:(NSString *)content Config:(CTFrameParserConfig *)config {
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc]initWithString:content attributes:attributes];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    
    //获得要绘制区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    CoreTextData *data = [[CoreTextData alloc]init];
    data.ctFrame = frame;
    data.height = textHeight;
    
    //释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}

//从指定文件中解析CoreTextData
+(CoreTextData *)parseTempLateFile:(NSString *)path config:(CTFrameParserConfig *)config {
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    CoreTextData *data = [self parseAttributedContent:content Config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return data;
}

//装载NSAttributedString
+(CoreTextData *)parseAttributedContent:(NSAttributedString *)content Config:(CTFrameParserConfig *)config {
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    //获得要绘制区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    CoreTextData *data = [[CoreTextData alloc]init];
    data.ctFrame = frame;
    data.height = textHeight;
    
    //释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    return data;
}

//从JSON数据中取得需要的排版信息
+(NSAttributedString *)loadTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config imageArray:(NSMutableArray *)imageArray linkArray:(NSMutableArray *)linkArray {
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]init];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dic in array) {
                NSString *type = dic[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *as = [self parseAttributedContentFromNSDictonary:dic config:config];
                    [result appendAttributedString:as];
                }else if ([type isEqualToString:@"img"]) {
                    //创建CoreTextImageData
                    CoreTextImageData *imageData = [[CoreTextImageData alloc]init];
                    imageData.name = dic[@"name"];
                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    //创建空白占位符，并设置它的CTRunDelegate信息
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dic config:config];
                    [result appendAttributedString:as];
                }else if ([type isEqualToString:@"link"]) {
                    NSUInteger startPos = result.length;
                    NSAttributedString *as =
                    [self parseAttributedContentFromNSDictonary:dic
                                                          config:config];
                    [result appendAttributedString:as];
                    // 创建 CoreTextLinkData
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    CoreTextLinkData *linkData = [[CoreTextLinkData alloc] init];
                    linkData.title = dic[@"content"];
                    linkData.url = dic[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return result;
}

//解析图片信息
static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

//从字典中解析图片并使用空白字符串填充图片位置，并设置空白字符串的代理方法
+(NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict config:(CTFrameParserConfig *)config {
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
#warning 查询下这个方法
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)dict);
    
    //使用0xFFFC作为空白占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    //空白符也要遵循config的定义
    NSDictionary *attributes = [self attributesWithConfig:config];
    //填充字符
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc]initWithString:content attributes:attributes];
    //设置富文本的代理方法
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

//使用JSON解析出得dict生成NSAttributedString
+(NSAttributedString *)parseAttributedContentFromNSDictonary:(NSDictionary *)dict config:(CTFrameParserConfig *)config {
    NSMutableDictionary *attributes = [[self attributesWithConfig:config]mutableCopy];
    //set Color
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (__bridge id)color.CGColor;
    }
    
    //set font
    CGFloat fontSize = [dict[@"size"]floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc]initWithString:content attributes:attributes];
}

//提取config中信息
+(NSDictionary *)attributesWithConfig:(CTFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
    CGFloat lineSpacing = config.lineSpace;
    UIColor *configTextColor = config.textColor;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    
    const CFIndex kNumberOfSettings = 3;
    
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacing ,sizeof(CGFloat) ,&lineSpacing},
        {kCTParagraphStyleSpecifierMaximumLineSpacing ,sizeof(CGFloat) ,&lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing ,sizeof(CGFloat) ,&lineSpacing}
    };
    
    CTParagraphStyleRef theParagrapRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor *textColor = configTextColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[(id)kCTForegroundColorAttributeName] = (__bridge id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagrapRef;
    
    CFRelease(theParagrapRef);
    CFRelease(fontRef);
    return dict;
}

//使用framesetter创建frame
+(CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter config:(CTFrameParserConfig *)config height:(CGFloat)height {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

//根据文本颜色生成UIColor
+(UIColor *)colorFromTemplate:(NSString *)name {
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    }else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    }else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    }else if ([name isEqualToString:@"default"]) {
        return [UIColor lightGrayColor];
    }
    else {
        return nil;
    }
}

@end











