//
//  CTDisplayView.m
//  CoreText排版引擎
//
//  Created by 伙伴行 on 16/4/21.
//  Copyright © 2016年 伙伴行. All rights reserved.
//

#import "CTDisplayView.h"
#import "CoreTextImageData.h"
#import "CoreTextUtils.h"
#import "CoreTextLinkData.h"

@interface CTDisplayView () <UIGestureRecognizerDelegate>

@end

@implementation CTDisplayView 

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupEvents];
    }
    return self;
}

//点击事件
- (void)setupEvents {
    UIGestureRecognizer * tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(userTapGestureDetected:)];
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled = YES;
}

- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
    for (CoreTextImageData * imageData in self.data.imageArray) {
        // 翻转坐标系，因为 imageData 中的坐标是 CoreText 的坐标系
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y = self.bounds.size.height - imageRect.origin.y
        - imageRect.size.height;
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        // 检测点击位置 Point 是否在 rect 之内
        if (CGRectContainsPoint(rect, point)) {
            // 在这里处理点击后的逻辑
            NSLog(@"bingo");
            break;
        }
    }
    CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:self.data];
    if (linkData) {
        NSLog(@"hint link - %@" ,linkData.url);
        return;
    }
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //转换坐标
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if (self.data) {
        CTFrameDraw(self.data.ctFrame, context);
        [self drawImageWithContext:context];
    }
}

-(void)drawImageWithContext:(CGContextRef)context {
    if (self.data.imageArray) {
        for (CoreTextImageData *imageData in self.data.imageArray) {
            NSString *name = imageData.name;
            CGRect bounds = imageData.imagePosition;
            UIImage *image = [UIImage imageNamed:name];
            CGContextDrawImage(context, bounds, image.CGImage);
        }
    }
}

@end
