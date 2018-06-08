//
//  ARImageTrackable+AJName.m
//  CMS Demo
//
//  Created by sanmao on 2018/3/12.
//  Copyright © 2018年 Kudan. All rights reserved.
//

#import "ARImageTrackable+AJName.h"

#import <objc/message.h>
@implementation ARImageTrackable (AJName)
-(void)AJ_changeName:(NSString*)name
{
    NSLog(@"运行时的名字%@",name);
    [self AJ_changeName:@"jun"];
}

-(NSString*)AJ_name
{
    return [self AJ_name];
}
+(void)load
{
    // 所有方法保存到类
    // Class:获取哪个类方法
    // SEL:获取哪个方法
       Method strNameMethod = class_getInstanceMethod(self, @selector(setValue:forKey:));
    
    Method aj_strNameMethod = class_getInstanceMethod(self, @selector(AJ_setValue:forKey:));
    // 交换imageNamed和xmg_imageNamed实现
    // 交换方法跟方法有关
//      method_exchangeImplementations(strNameMethod, aj_strNameMethod);
    
}




@end
