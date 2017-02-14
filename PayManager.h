//
//  PayManager.h
//  ChiChiPark
//
//  Created by 蔡成汉 on 16/3/23.
//  Copyright © 2016年 上海泰侠网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  支付类型
 */
typedef NS_ENUM(NSInteger,PayType) {
    /**
     *  微信支付
     */
    PayTypeWeChat = 1,
    
    /**
     *  支付宝支付
     */
    PayTypeALi= 2
};

/**
 *  支付结果
 */
typedef NS_ENUM(NSInteger,PayResult) {
    /**
     *  支付成功
     */
    PaySuccess = 0,
    /**
     *  支付失败
     */
    PayFail = 1,
    /**
     *  用户取消
     */
    PayUserCancel = 2
};

@interface PayManager : NSObject

/**
 *  单例
 *
 *  @return 实例化后的PayManager
 */
+(PayManager *)shareManager;

/**
 *  支付
 *
 *  @param param    商品参数
 *  @param type     支付类型
 *  @param result   支付结果
 *  @param callBack 回调结果
 */
-(void)pay:(NSDictionary *)param type:(PayType)type result:(void(^)(BOOL success, NSError *error))result callBack:(void(^)(PayResult payResult, NSString *description))callBack;

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
