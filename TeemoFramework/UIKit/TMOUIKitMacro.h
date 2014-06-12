//
//  TMOUIKitMacro.h
//  TeemoV2
//
//  Created by 崔明辉 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

//TMO_UIKIT_DEVICE_ 与机器相关，与应用无关
//TMO_UIKIT_APP_    与应用相关，无机器无关

/**
 * 屏幕宽度
 * @return Float
 * @value 320.0,640.0,768.0,1536.0
 **/
#define TMO_UIKIT_DEVICE_WIDTH [UIScreen mainScreen].currentMode.size.width

/**
 * 屏幕高度
 * @return Float
 * @value 640.0,960.0,1136.0,1024.0,2048.0
 **/
#define TMO_UIKIT_DEVICE_HEIGHT [UIScreen mainScreen].currentMode.size.height

/**
 * 屏幕是否为高清屏
 * @return Bool
 **/
#define TMO_UIKIT_DEVICE_IS_RETINA (TMO_UIKIT_DEVICE_WIDTH == 640.0 || TMO_UIKIT_DEVICE_WIDTH == 1536.0)

/**
 * 主界面宽度
 * @return Float
 * @value 320.0,768.0
 **/
#define TMO_UIKIT_APP_WIDTH [UIScreen mainScreen].bounds.size.width

/**
 * 主界面高度
 * @return Float
 * @value 480.0,568.0,1024.0
 **/
#define TMO_UIKIT_APP_HEIGHT [UIScreen mainScreen].bounds.size.height

/**
 * 界面是否为iPad风格
 * @return Bool
 **/
#define TMO_UIKIT_APP_IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/**
 * 界面是否为iOS7风格
 * @return Bool
 **/
#define TMO_UIKIT_APP_IS_IOS7 ((__IPHONE_OS_VERSION_MAX_ALLOWED >= 70000) && ([UIDevice currentDevice].systemVersion.floatValue >= 7.0))

/**
 * 界面是否为4英寸屏模式
 * @return Bool
 **/
#define TMO_UIKIT_APP_IS_4_0INCH TMO_UIKIT_APP_HEIGHT == 568.0

/**
 * 界面是否为3.5英寸屏模式
 * @return Bool
 **/
#define TMO_UIKIT_APP_IS_3_5INCH TMO_UIKIT_APP_HEIGHT == 480.0


@interface TMOUIKitMacro : NSObject

@end
