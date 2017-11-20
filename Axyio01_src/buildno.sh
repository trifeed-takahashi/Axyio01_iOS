#!/bin/sh

#  buildno.sh
#  Axyio01
#
#  Created by 高橋聖二 on 2017/11/20.
#  Copyright © 2017年 trifeed inc. All rights reserved.
build_number=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
build_number=$(($build_number + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "${PROJECT_DIR}/${INFOPLIST_FILE}"

