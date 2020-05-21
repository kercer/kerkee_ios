//
//  KCUtilJson.h
//  kerkee
//
//  Created by zihong on 15/12/10.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCBaseDefine.h"

// JSON serialization/deserialization
KC_EXTERN NSString *KCJSONStringify(id aJsonObject, NSError **error);
KC_EXTERN id KCJSONParse(NSString *aJsonString, NSError **error);
KC_EXTERN id KCJSONParseMutable(NSString *aJsonString, NSError **error);

// Strip non JSON-safe values from an object graph
KC_EXTERN id KCJSONClean(id object);

