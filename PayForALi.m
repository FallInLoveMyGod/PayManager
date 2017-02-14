//
//  PayForALi.m
//  ChiChiPark
//
//  Created by 蔡成汉 on 16/3/23.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "PayForALi.h"
#import <AlipaySDK/AlipaySDK.h>

@interface PayForALi ()

/**
 *  支付宝支付回调
 */
@property (nonatomic , copy) void(^aLiPayCallBack)(PayResult payResult, NSString *description);

@end

@implementation PayForALi

/**
 *  支付宝支付
 *
 *  @param param    商品参数
 *  @param result   支付结果
 *  @param callBack 支付回调
 */
-(void)pay:(NSDictionary *)param result:(void(^)(BOOL success, NSError *error))result callBack:(void(^)(PayResult payResult, NSString *description))callBack
{
    self.aLiPayCallBack = callBack;
    
    /**
     *  支付宝：根据参数，向服务器发送请求，获取订单字符串
     */
    [[ConnectManager shareManager]getWithURLString:[NSString stringWithFormat:@"%@%@",klBaseURL,KlURLForAlipay] param:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject, NSInteger errorCode) {
        if (responseObject != nil && responseObject.count > 0)
        {
            /**
             *  获取订单字符串，调用支付宝SDK支付方法，唤起支付宝支付
             */
            NSString *orderString = [responseObject getStringValueForKey:@"data"];
            [[AlipaySDK defaultService]payOrder:orderString fromScheme:@"thewitnesses" callback:^(NSDictionary *resultDic) {
                result(YES,nil);
                [self payCallBackCheck:resultDic];
            }];
        }
        else
        {
           result(NO,nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        result(NO,error);
    }];
}

/**
 *  支付回调
 *
 *  @param url     url
 *  @param options options
 *
 *  @return YES：数据处理成功；NO：数据处理失败
 */
-(BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options
{
    if ([url.host isEqualToString:@"safepay"])
    {
        /**
         *  支付宝支付 -- block回调，确认订单是否支付成功（支付成功/失败）。
         */
        [[AlipaySDK defaultService]processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            [self payCallBackCheck:resultDic];
        }];
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
 *  支付回调结果检查
 *
 *  @param resultDic 支付结果
 */
-(void)payCallBackCheck:(NSDictionary *)resultDic
{
    NSString *resultStatus =[resultDic getStringValueForKey:@"resultStatus"];
    if ([resultStatus isEqualToString:@"9000"])
    {
        /**
         *  支付成功
         */
        if (self.aLiPayCallBack)
        {
            self.aLiPayCallBack(PaySuccess,@"支付宝支付成功");
        }
    }
    else if ([resultStatus isEqualToString:@"6001"])
    {
        /**
         *  取消支付
         */
        if (self.aLiPayCallBack)
        {
            self.aLiPayCallBack(PayUserCancel,@"支付宝支付取消");
        }
    }
    else
    {
        /**
         *  支付失败
         */
        if (self.aLiPayCallBack)
        {
            self.aLiPayCallBack(PayFail,@"支付宝支付失败");
        }
    }
}

@end
