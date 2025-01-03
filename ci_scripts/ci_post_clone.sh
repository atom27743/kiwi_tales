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

# Check and create GenerativeAI-Info.plist
if [ -n "$GENERATIVE_AI_INFO_PLIST" ]; then
    echo "ENVIRONMENT VARIABLE FOR GENERATIVE_AI_INFO_PLIST WAS FOUND."
    echo "$GENERATIVE_AI_INFO_PLIST" > "$CI_PRIMARY_REPOSITORY_PATH"/"$CI_PRODUCT"/"$CI_PRODUCT"/GenerativeAI-Info.plist
    echo "GenerativeAI-Info.plist was created in the project directory."
else
    echo "ENVIRONMENT VARIABLE FOR GENERATIVE_AI_INFO_PLIST WAS NOT FOUND."
fi

# Check and create Development.xcconfig
if [ -n "$DEVELOPMENT_XCCONFIG" ]; then
    echo "ENVIRONMENT VARIABLE FOR DEVELOPMENT_XCCONFIG WAS FOUND."
    echo "$DEVELOPMENT_XCCONFIG" > "$CI_PRIMARY_REPOSITORY_PATH"/"$CI_PRODUCT"/"$CI_PRODUCT"/Development.xcconfig
    echo "Development.xcconfig was created in the project directory."
else
    echo "ENVIRONMENT VARIABLE FOR DEVELOPMENT_XCCONFIG WAS NOT FOUND."
fi

# Exit with a success code
exit 0

