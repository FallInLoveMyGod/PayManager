//
//  PayManager.m
//  ChiChiPark
//
//  Created by 蔡成汉 on 16/3/23.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "PayManager.h"
#import "PayForALi.h"
#import "PayForWeChat.h"

static PayManager *payManager = nil;

@interface PayManager ()

/**
 *  支付宝支付
 */
@property (nonatomic , strong) PayForALi *aliPay;

/**
 *  微信支付
 */
@property (nonatomic , strong) PayForWeChat *weChatPay;

@end

@implementation PayManager

/**
 *  单例
 *
 *  @return 实例化后的PayManager
 */
+(PayManager *)shareManager
{
    @synchronized (self)
    {
        if (payManager == nil)
        {
            payManager = [[self alloc] init];
        }
    }
    return payManager;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        _aliPay = [[PayForALi alloc]init];
        _weChatPay = [[PayForWeChat alloc]init];
    }
    return self;
}

/**
 *  支付
 *
 *  @param param    商品参数
 *  @param type     支付类型
 *  @param result   支付结果
 *  @param callBack 回调结果
 */
-(void)pay:(NSDictionary *)param type:(PayType)type result:(void(^)(BOOL success, NSError *error))result callBack:(void(^)(PayResult payResult, NSString *description))callBack
{
    if (type == PayTypeALi)
    {
        [_aliPay pay:param result:^(BOOL success, NSError *error) {
            result(success,error);
        } callBack:^(PayResult payResult, NSString *description) {
            callBack(payResult, description);
            
            //插入友盟统计
            if (payResult == PaySuccess)
            {
                //支付成功
                [[TWUMManager sharedManager]signEventWithEventId:UMPaySuccess];
            }
            else
            {
                //支付失败
                [[TWUMManager sharedManager]signEventWithEventId:UMPayFailed];
            }
        }];
    }
    else if (type == PayTypeWeChat)
    {
        [_weChatPay pay:param result:^(BOOL success, NSError *error) {
            result(success,error);
        } callBack:^(PayResult payResult, NSString *description) {
            callBack(payResult, description);
            
            //插入友盟统计
            if (payResult == PaySuccess)
            {
                //支付成功
                [[TWUMManager sharedManager]signEventWithEventId:UMPaySuccess];
            }
            else
            {
                //支付失败
                [[TWUMManager sharedManager]signEventWithEventId:UMPayFailed];
            }
        }];
    }
    else
    {
        result(NO,nil);
    }
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
    return [_aliPay handleOpenURL:url options:options] || [_weChatPay handleOpenURL:url options:options];
}

@end
