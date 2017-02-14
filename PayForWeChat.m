//
//  PayForWeChat.m
//  ChiChiPark
//
//  Created by 蔡成汉 on 16/3/23.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import "PayForWeChat.h"
#import "WXApi.h"

@interface PayForWeChat ()<WXApiDelegate>

/**
 *  支付宝支付回调
 */
@property (nonatomic , copy) void(^weChatPayCallBack)(PayResult payResult, NSString *description);

@end

@implementation PayForWeChat

-(id)init
{
    self = [super init];
    if (self)
    {
        /**
         *  注册微信id
         */
        [WXApi registerApp:klWeChatId withDescription:@"幕击者"];
    }
    return self;
}

/**
 *  微信支付
 *
 *  @param param    商品参数
 *  @param result   支付结果
 *  @param callBack 结果回调
 */
-(void)pay:(NSDictionary *)param result:(void(^)(BOOL success, NSError *error))result callBack:(void(^)(PayResult payResult, NSString *description))callBack
{
    self.weChatPayCallBack = callBack;
    
    /**
     *  微信：根据参数，向服务器发送请求，获取订单信息
     */
    [[ConnectManager shareManager]getWithURLString:[NSString stringWithFormat:@"%@%@",klBaseURL,KlURLForWechatPay] param:param success:^(NSURLSessionDataTask *task, NSDictionary *responseObject, NSInteger errorCode) {
        if (responseObject != nil && responseObject.count > 0)
        {
            /**
             *  获取订单信息，调用微信SDK支付方法，唤起微信支付
             */
            NSDictionary *payDic = [responseObject getDictionaryValueForKey:@"data"];
            PayReq *req      = [[PayReq alloc]init];
            req.openID       = WeixinAppId;
            req.partnerId    = [payDic getStringValueForKey:@"partnerid"];
            req.prepayId     = [payDic getStringValueForKey:@"prepayid"];
            req.nonceStr     = [payDic getStringValueForKey:@"noncestr"];
            req.timeStamp    = (UInt32)[[payDic getNumberValueForKey:@"timestamp"] longLongValue];
            req.package      = [payDic getStringValueForKey:@"package"];
            req.sign         = [payDic getStringValueForKey:@"sign"];
            BOOL tpResult    = [WXApi sendReq:req];
            result(tpResult,nil);
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
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate

-(void)onResp:(BaseResp *)resp
{
    /**
     *  block回调 -- 需要根据订单号，请求本地服务器，确认订单是否支付成功（支付成功/失败） -- 此处则为直接根据SDK回调方法进行判断
     */
    if ([resp isKindOfClass:[PayResp class]])
    {
        if (resp.errCode == WXSuccess)
        {
            /**
             *  支付成功
             */
            if (self.weChatPayCallBack)
            {
                self.weChatPayCallBack(PaySuccess,@"微信支付成功");
            }
        }
        else if (resp.errCode == WXErrCodeUserCancel)
        {
            /**
             *  用户取消
             */
            if (self.weChatPayCallBack)
            {
                self.weChatPayCallBack(PayUserCancel,@"微信支付取消");
            }
        }
        else
        {
            /**
             *  支付失败
             */
            if (self.weChatPayCallBack)
            {
                self.weChatPayCallBack(PayFail,@"微信支付失败");
            }
        }
    }
}


@end
