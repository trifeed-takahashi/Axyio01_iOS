#!/bin/sh

#  buildno.sh
#  Axyio01
#
#  Created by 高橋聖二 on 2017/11/20.
#  Copyright © 2017年 trifeed inc. All rights reserved.
if [ ${CONFIGURATION} = "Debug" ]; then

plistBuddy="/usr/libexec/PlistBuddy"
infoPlistFileSource="${SRCROOT}/${INFOPLIST_FILE}"
infoPlistFileDestination="${TEMP_DIR}/Preprocessed-Info.plist"

currentVersion=$($plistBuddy -c "Print CFBundleVersion" $infoPlistFileSource)

versionPrefix="dev-"
lastCommitDate=$(git log -1 --format='%ci')
versionSuffix=" ($lastCommitDate)"

versionString=$versionPrefix$currentVersion$versionSuffix

$plistBuddy -c "Set :CFBundleVersion $versionString" $infoPlistFileDestination

fi
