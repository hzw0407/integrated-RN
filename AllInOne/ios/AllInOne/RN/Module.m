//
//  Module.m
//  falala
//
//  Created by 何志武 on 2022/3/11.
//

//#import "Module.h"
//
//@interface RCT_EXTERN_MODULE(IntentModule, NSObject)
//
//RCT_EXPORT_METHOD(navigateBack){
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModuleNavigateBack" object:nil];
//}
//
//@end
//
//@implementation Module
//
//- (dispatch_queue_t)methodQueue {
//    return dispatch_get_main_queue();
//}
//
//
//
//@end

#import "Module.h"

@implementation Module

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(navigateBack){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ModuleNavigateBack" object:nil];
}

@end
