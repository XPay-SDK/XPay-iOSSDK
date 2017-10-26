//
//  XpassSDK.h
//  XpassSDK
//
//  Created by Casum Leung on 2017/3/13.
//  Copyright © 2017年 Zhimou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XpassErrorOption)
{
    XpassErrInvalidCharge,
    XpassErrInvalidCredential,
    XpassErrInvalidChannel,
    XpassErrWxNotInstalled,
    XpassErrWxAppNotSupported,
    XpassErrCancelled,
    XpassErrUnknownCancel,
    XpassErrViewControllerIsNil,
    XpassErrTestmodeNotifyFailed,
    XpassErrChannelReturnFail,
    XpassErrConnectionError,
    XpassErrUnknownError,
    XpassErrActivation,
    XpassErrRequestTimeOut,
    XpassErrProcessing,
    XpassErrQqNotInstalled,
};

@interface XPassError : NSObject

@property(readonly, assign) XpassErrorOption code;

- (instancetype)initWithCode:(XpassErrorOption)code;
- (NSString *)getMsg;

@end

typedef void (^XpassCompletion)(NSString *result, XPassError *error);

@interface XpassSDK : NSObject

/**
 *  支付调用接口
 *
 *  @param charge           Charge 对象(NSDictionary)
 *  @param viewController   银联渠道需要
 *  @param scheme           URL Scheme，支付宝渠道回调需要
 *  @param completionBlock  支付结果回调 Block
 */
+ (void)createPassment:(NSDictionary *)charge viewController:(UIViewController*)viewController appURLScheme:(NSString *)scheme withCompletion:(XpassCompletion)completionBlock;

/**
 *  回调结果接口(支付宝/微信)
 *
 *  @param url              结果url
 *  @param completionBlock  支付结果回调 Block
 *
 *  @return                 当无法处理 URL 或者 URL 格式不正确时，会返回 NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url withCompletion:(XpassCompletion)completionBlock;

/**
 *  回调结果接口(支付宝/微信)
 *
 *  @param url                结果url
 *  @param sourceApplication  源应用 Bundle identifier
 *  @param completionBlock    支付结果回调 Block
 *
 *  @return                   当无法处理 URL 或者 URL 格式不正确时，会返回 NO。
 */
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication withCompletion:(XpassCompletion)completionBlock;

/**
 *  版本号
 *
 *  @return         Xpass SDK 版本号
 */
+ (NSString *)version;

/**
 *  设置 Debug 模式
 *
 *  @param enabled    是否启用
 */
+ (void)setDebugMode:(BOOL)enabled;

/**
 *  设置 App ID
 *  @param  appId  XPass 的应用 ID
 */
+ (void)setAppId:(NSString *)appId;

/**
 *  XPass 的应用 ID
 *
 *  @return  appId
 */
+ (NSString *)appId;

@end
