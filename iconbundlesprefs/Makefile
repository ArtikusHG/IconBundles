DEBUG = 0
FINALPACKAGE = 1

TARGET := iphone:clang:latest:5.0
ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = IconBundlesPrefs

IconBundlesPrefs_FILES = IBPRootListController.m
IconBundlesPrefs_FRAMEWORKS = UIKit
IconBundlesPrefs_PRIVATE_FRAMEWORKS = Preferences
IconBundlesPrefs_INSTALL_PATH = /Library/PreferenceBundles
IconBundlesPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
