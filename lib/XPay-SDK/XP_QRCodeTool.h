//
//  XP_QRCodeTool.h
//  XpaySDK
//
//  Created by Casum Leung on 2017/3/23.
//  Copyright © 2017年 Zhimou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XP_QRCodeTool : NSObject

/**
*  生成一张普通的二维码
*
*  @param data                二维码内容
*  @param imageViewWidth      图片的宽度
*  @return                    二维码图片
*/
+ (UIImage *)XP_generateWithDefaultQRCodeData:(NSString *)data imageViewWidth:(CGFloat)imageViewWidth;

/**
 *  生成一张带有logo的二维码
 *
 *  @param data                     二维码内容
 *  @param logoImage                logo
 *  @param logoScaleToSuperView     相对于父视图的缩放比取值范围0-1；0，不显示，1，代表与父视图大小相同
 *  @return                         二维码图片
 */
+ (UIImage *)XP_generateWithLogoQRCodeData:(NSString *)data logoImage:(UIImage *)logoImage logoScaleToSuperView:(CGFloat)logoScaleToSuperView;

@end
