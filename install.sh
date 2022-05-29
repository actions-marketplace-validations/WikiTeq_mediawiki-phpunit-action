#!/bin/sh -l

set -o pipefail

MW_BRANCH=$1
EXTENSION_NAME=$2

wget https://github.com/wikimedia/mediawiki/archive/$MW_BRANCH.tar.gz -nv -q

tar -zxf $MW_BRANCH.tar.gz
mv mediawiki-$MW_BRANCH mediawiki

cd mediawiki

composer -q install
php maintenance/install.php --dbtype sqlite --dbuser root --dbname mw --dbpath $(pwd) --pass AdminPassword WikiName AdminUser > /dev/null

# echo 'error_reporting(E_ALL| E_STRICT);' >> LocalSettings.php
# echo 'ini_set("display_errors", 1);' >> LocalSettings.php
echo '$wgShowExceptionDetails = true;' >> LocalSettings.php
echo '$wgShowDBErrorBacktrace = true;' >> LocalSettings.php
echo '$wgDevelopmentWarnings = true;' >> LocalSettings.php

echo "wfLoadExtension( '$EXTENSION_NAME' );" >> LocalSettings.php

cat <<EOT >> composer.local.json
{
  "require": {

  },
	"extra": {
		"merge-plugin": {
			"merge-dev": true,
			"include": [
				"extensions/*/composer.json"
			]
		}
	}
}
EOT