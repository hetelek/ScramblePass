include theos/makefiles/common.mk

BUNDLE_NAME = ScramblePassPreferences
ScramblePassPreferences_FILES = ScramblePassPreferences.mm
ScramblePassPreferences_INSTALL_PATH = /Library/PreferenceBundles
ScramblePassPreferences_FRAMEWORKS = UIKit
ScramblePassPreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ScramblePassPreferences.plist$(ECHO_END)
