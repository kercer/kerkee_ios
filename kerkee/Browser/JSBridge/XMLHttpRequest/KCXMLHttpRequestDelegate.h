//
//  KCXMLHttpRequestDelegate.h
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
@class KCXMLHttpRequest;
@protocol KCXMLHttpRequestDelegate <NSObject>

-(void)fetchReceiveData:(KCXMLHttpRequest*)xmlHttpRequest didReceiveData:(NSData *)data;
-(void)fetchComplete:(KCXMLHttpRequest*)xmlHttpRequest responseData:(NSDictionary*)aResponseData;
-(void)fetchFailed:(KCXMLHttpRequest*)xmlHttpRequest didFailWithError:(NSError *)error;

@end
