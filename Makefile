INSTALL_TARGET_PROCESSES = TargetApp

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SampleTweak

SampleTweak_FILES = Tweak.xm ModMenuUI.mm
SampleTweak_CFLAGS = -fobjc-arc
SampleTweak_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
