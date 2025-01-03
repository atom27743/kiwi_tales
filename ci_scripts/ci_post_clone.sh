#!/bin/zsh

#  ci_post_clone.sh
#  KiwiTales
#
#  Created by Jina Lee on 1/4/25.
#  

# Check and create GoogleService-Info.plist
if [ -n "$GOOGLE_SERVICE_INFO_PLIST" ]; then
    echo "ENVIRONMENT VARIABLE FOR GOOGLE_SERVICE_INFO_PLIST WAS FOUND."
    echo "$GOOGLE_SERVICE_INFO_PLIST" > "$CI_PRIMARY_REPOSITORY_PATH"/"$CI_PRODUCT"/"$CI_PRODUCT"/GoogleService-Info.plist
    echo "GoogleService-Info.plist was created in the project directory."
else
    echo "ENVIRONMENT VARIABLE FOR GOOGLE_SERVICE_INFO_PLIST WAS NOT FOUND."
fi

# Exit with a success code
exit 0

