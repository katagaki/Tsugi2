#!/bin/sh

#  ci_post_clone.sh
#  Buses 2
#
#  Created by 堅書 on 3/3/23.
#

set -e

echo "Appending LTA DataMall API key to APIKeys.plist."
echo $APIKEY_LTADATAMALL

cd $CI_WORKSPACE/Buses
plutil -create xml1 APIKeys.plist
plutil -insert LTA -string $APIKEY_LTADATAMALL APIKeys.plist

cat APIKeys.plist

echo "Post-clone script completed."
exit 0
