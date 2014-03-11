#!/bin/sh
#
# created by Guoyin Li on 13/08/12
# Copyleft 2013

APP_PATH="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
SOURCE=../sync_resources

touch .filelist

find $SOURCE -type f -name '[^.]*' -print > .tempfilelist
diff .filelist .tempfilelist > .diffresult

cat .diffresult | grep "^<" | cut -d " " -f2- | while read line;do
	filename=`basename "$line"`
	rm "$APP_PATH/$filename"
done

cat .tempfilelist | while read line;do
	rsync -av "$line" "$APP_PATH"
done

rm .diffresult
mv .tempfilelist .filelist
