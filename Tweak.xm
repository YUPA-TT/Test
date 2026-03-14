// Tweak.xm
// Logos記法でObjective-C / C++のhookを書く
// %hookでクラスをフック、%origで元の関数を呼ぶ

#import <UIKit/UIKit.h>
#import "ModMenuUI.h"

// ========================================
// 設定フラグ（Mod Menuから切り替える）
// ========================================
BOOL gSpeedHackEnabled  = NO;
BOOL gInfiniteCoinsEnabled = NO;
BOOL gGodModeEnabled    = NO;

// ========================================
// フック例1: ゲームのスコア加算をフック
// クラス名・メソッド名はゲームに合わせて変更する
// ========================================
%hook GameManager

- (void)addScore:(int)amount {
    if (gInfiniteCoinsEnabled) {
        // 元の値を10倍にして渡す
        %orig(amount * 10);
    } else {
        %orig(amount);
    }
}

- (int)getPlayerHP {
    if (gGodModeEnabled) {
        return 99999;
    }
    return %orig;
}

- (float)getPlayerSpeed {
    if (gSpeedHackEnabled) {
        return %orig * 3.0f;
    }
    return %orig;
}

%end

// ========================================
// フック例2: ViewControllerが表示されたタイミングで
//            Mod MenuのボタンをUIに追加する
// ========================================
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);

    // Mod Menuボタンをルートに1回だけ追加
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            ModMenuButton *btn = [[ModMenuButton alloc] init];
            [window addSubview:btn];
        }
    });
}

%end

// ========================================
// コンストラクタ: Tweak読み込み時に実行
// ========================================
%ctor {
    NSLog(@"[SampleTweak] Loaded!");
}

%dtor {
    NSLog(@"[SampleTweak] Unloaded.");
}
