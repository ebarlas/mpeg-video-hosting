IFS=$'\n' # use newline delimiter in for loop over find result

src_dir="..."
src_dir_len=${#src_dir}
songs_js="songs.js"
upload="false"
s3_bucket="..."
upload_folder="..."
upload_base="s3://${s3_bucket}/${upload_folder}"
cf_dist="..."
limit="3"
skip="0"
clean_up="false"

echo "songs = [" >$songs_js

count=0
for f in $(find $src_dir -name "*.mpg"); do
  count=$((count + 1))
  if [ "$count" -gt "$limit" ]; then
    break
  fi
  path_len=${#f}
  cut_start=$((src_dir_len + 2))
  cut_end=$((path_len - 4))
  name=$(echo $f | cut -c ${cut_start}-${cut_end})
  echo "count=$count, name=$name"
  echo "  \"$name\"," >>$songs_js
  if [ "$count" -le "$skip" ]; then
    continue
  fi
  ffmpeg -y -i $f -c:v libx264 -crf 17 "${name}.mp4"
  ffmpeg -y -i $f -ss 00:00:11.000 -vframes 1 "${name}.png"
  if [ "$upload" == "true" ]; then
    aws s3 cp "${name}.mp4" "${upload_base}/${name}.mp4"
    aws s3 cp "${name}.png" "${upload_base}/${name}.png"
  fi
  if [ "$clean_up" == "true" ]; then
    rm "${name}.mp4" "${name}.png"
  fi
done

echo "]" >>$songs_js

if [ "$upload" == "true" ]; then
  aws s3 cp "songs.js" "${upload_base}/songs.js"
  aws s3 cp "songs.html" "${upload_base}/songs.html"
  aws s3 cp "play.html" "${upload_base}/play.html"
  aws cloudfront create-invalidation --distribution-id "${cf_dist}" --paths \
    "/${upload_folder}/songs.js" \
    "/${upload_folder}/songs.html" \
    "/${upload_folder}/play.html"
fi
