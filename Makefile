DEBUG = 0
FINALPACKAGE = 1

TARGET = iphone:latest:5.0
ARCHS = armv7 arm64

INSTALL_TARGET_PROCESSES = backboardd

TWEAK_NAME = IconBundles
IconBundles_FILES = Tweak.x
IconBundles_FRAMEWORKS = UIKit
IconBundles_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += iconbundlesprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
