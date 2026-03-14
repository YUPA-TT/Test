#pragma once
#import <UIKit/UIKit.h>

// 外部フラグ（Tweak.xmと共有）
extern BOOL gSpeedHackEnabled;
extern BOOL gInfiniteCoinsEnabled;
extern BOOL gGodModeEnabled;

// ドラッグ可能なフローティングボタン
@interface ModMenuButton : UIButton
@end

// Mod Menuパネル本体
@interface ModMenuPanel : UIView
- (instancetype)initWithFrame:(CGRect)frame;
@end
