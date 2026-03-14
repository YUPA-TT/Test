// ModMenuUI.mm
// Objective-C++ で書いたMod Menu UI
// ドラッグ可能なフローティングボタン + スライドインパネル

#import "ModMenuUI.h"
#import <objc/runtime.h>

// ========================================
// 定数
// ========================================
static const CGFloat kButtonSize   = 52.0f;
static const CGFloat kPanelWidth   = 260.0f;
static const CGFloat kPanelHeight  = 340.0f;
static const CGFloat kRowHeight    = 52.0f;

// ========================================
// トグル行（ラベル + UISwitch）
// ========================================
@interface MenuToggleRow : UIView
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UISwitch *toggle;
- (instancetype)initWithTitle:(NSString *)title
                      enabled:(BOOL)enabled
                       action:(void(^)(BOOL))action;
@end

@implementation MenuToggleRow

- (instancetype)initWithTitle:(NSString *)title
                      enabled:(BOOL)enabled
                       action:(void(^)(BOOL))action {
    self = [super init];
    if (!self) return nil;

    self.backgroundColor = [UIColor clearColor];

    // ラベル
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = title;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];

    // スイッチ
    self.toggle = [[UISwitch alloc] init];
    self.toggle.on = enabled;
    self.toggle.onTintColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0];
    self.toggle.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    self.toggle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.toggle];

    // アクションブロックをスイッチに関連付けて保存
    void(^copiedAction)(BOOL) = [action copy];
    objc_setAssociatedObject(self.toggle, "toggleAction", copiedAction, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.toggle addTarget:self
                    action:@selector(handleToggle:)
          forControlEvents:UIControlEventValueChanged];

    // AutoLayout
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.toggle.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [self.toggle.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
    ]];

    return self;
}

- (void)handleToggle:(UISwitch *)sender {
    void(^action)(BOOL) = objc_getAssociatedObject(sender, "toggleAction");
    if (action) action(sender.isOn);
}

@end

// ========================================
// Mod Menuパネル
// ========================================
@implementation ModMenuPanel {
    UILabel *_titleLabel;
    UIStackView *_stackView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;

    // 背景
    self.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.95];
    self.layer.cornerRadius = 16.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.12].CGColor;
    self.clipsToBounds = YES;

    // タイトルバー
    UIView *titleBar = [[UIView alloc] init];
    titleBar.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:1.0 alpha:0.85];
    titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:titleBar];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"⚙️ Mod Menu";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightBold];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [titleBar addSubview:_titleLabel];

    // スタックビュー（トグル一覧）
    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.distribution = UIStackViewDistributionFillEqually;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_stackView];

    // AutoLayout
    [NSLayoutConstraint activateConstraints:@[
        [titleBar.topAnchor constraintEqualToAnchor:self.topAnchor],
        [titleBar.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [titleBar.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [titleBar.heightAnchor constraintEqualToConstant:44.0f],

        [_titleLabel.leadingAnchor constraintEqualToAnchor:titleBar.leadingAnchor constant:14],
        [_titleLabel.centerYAnchor constraintEqualToAnchor:titleBar.centerYAnchor],

        [_stackView.topAnchor constraintEqualToAnchor:titleBar.bottomAnchor constant:8],
        [_stackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [_stackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [_stackView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
    ]];

    // トグル項目を追加
    [self addToggleWithTitle:@"🚀 Speed Hack"
                    enabled:gSpeedHackEnabled
                     action:^(BOOL on){ gSpeedHackEnabled = on; }];

    [self addToggleWithTitle:@"💰 Infinite Coins"
                    enabled:gInfiniteCoinsEnabled
                     action:^(BOOL on){ gInfiniteCoinsEnabled = on; }];

    [self addToggleWithTitle:@"🛡️ God Mode"
                    enabled:gGodModeEnabled
                     action:^(BOOL on){ gGodModeEnabled = on; }];

    // バージョン表示
    UILabel *ver = [[UILabel alloc] init];
    ver.text = @"v1.0.0  by yourname";
    ver.textColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    ver.font = [UIFont systemFontOfSize:11.0f];
    ver.textAlignment = NSTextAlignmentCenter;
    ver.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:ver];
    [NSLayoutConstraint activateConstraints:@[
        [ver.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-6],
        [ver.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
    ]];

    return self;
}

- (void)addToggleWithTitle:(NSString *)title
                   enabled:(BOOL)enabled
                    action:(void(^)(BOOL))action {
    MenuToggleRow *row = [[MenuToggleRow alloc] initWithTitle:title
                                                      enabled:enabled
                                                       action:action];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    [row.heightAnchor constraintEqualToConstant:kRowHeight].active = YES;
    [_stackView addArrangedSubview:row];
}

@end

// ========================================
// フローティングボタン（ドラッグ可能）
// ========================================
@implementation ModMenuButton {
    ModMenuPanel *_panel;
    BOOL          _panelVisible;
    CGPoint       _dragStart;
    CGPoint       _frameStart;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(20, 120, kButtonSize, kButtonSize)];
    if (!self) return nil;

    self.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:1.0 alpha:0.9];
    self.layer.cornerRadius = kButtonSize / 2.0f;
    self.layer.shadowColor  = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset  = CGSizeMake(0, 3);
    self.layer.shadowRadius  = 6.0f;
    [self setTitle:@"⚙️" forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:22.0f];

    [self addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(onPan:)];
    [self addGestureRecognizer:pan];

    return self;
}

- (void)onTap {
    if (!_panel) {
        UIWindow *window = self.window;
        CGFloat px = self.frame.origin.x + kButtonSize + 8;
        CGFloat py = self.frame.origin.y;
        if (px + kPanelWidth > window.bounds.size.width) {
            px = self.frame.origin.x - kPanelWidth - 8;
        }
        _panel = [[ModMenuPanel alloc] initWithFrame:CGRectMake(px, py, kPanelWidth, kPanelHeight)];
        _panel.alpha = 0;
        _panel.transform = CGAffineTransformMakeScale(0.85, 0.85);
        [window addSubview:_panel];
    }

    _panelVisible = !_panelVisible;
    [UIView animateWithDuration:0.22
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self->_panel.alpha     = self->_panelVisible ? 1.0 : 0.0;
        self->_panel.transform = self->_panelVisible
            ? CGAffineTransformIdentity
            : CGAffineTransformMakeScale(0.85, 0.85);
    } completion:nil];
}

- (void)onPan:(UIPanGestureRecognizer *)pan {
    UIWindow *window = self.window;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _dragStart  = [pan locationInView:window];
        _frameStart = self.frame.origin;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint cur = [pan locationInView:window];
        CGFloat dx = cur.x - _dragStart.x;
        CGFloat dy = cur.y - _dragStart.y;
        CGRect  f  = self.frame;
        f.origin.x = _frameStart.x + dx;
        f.origin.y = _frameStart.y + dy;
        f.origin.x = MAX(0, MIN(f.origin.x, window.bounds.size.width  - kButtonSize));
        f.origin.y = MAX(0, MIN(f.origin.y, window.bounds.size.height - kButtonSize));
        self.frame = f;
    }
}

@end
