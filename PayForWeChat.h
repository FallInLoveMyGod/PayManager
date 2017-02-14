//
//  PayForWeChat.h
//  ChiChiPark
//
//  Created by 蔡成汉 on 16/3/23.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayForWeChat : NSObject

/**
*  微信支付
*
*  @param param    商品参数
*  @param result   支付结果
*  @param callBack 结果回调
*/
-(void)pay:(NSDictionary *)param result:(void(^)(BOOL success, NSError *error))result callBack:(void(^)(PayResult payResult, NSString *description))callBack;

/**
 *  支付回调
 *
 *  @param url     url
 *  @param options options
 *
 *  @return YES：数据处理成功；NO：数据处理失败
 */
-(BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options;

@end
