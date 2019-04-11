#!/bin/bash
clear
echo =====================================================
echo "Hello, I will make video backgrounds of arbitrary length for all your podcasts"
echo =====================================================
echo
if [ -d "edited" ]; then
    rmdir "edited" && mkdir "edited"
else
    mkdir "edited"
fi
used=""
files=( src/* )
counter=0
for f in mp3/*.mp3; do
    audio=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$f" | awk '{print int($0)}');
    if <<< "$used" grep -q -x ${files[counter]}; then
       continue
    fi
    video=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${files[counter]}" | awk '{print int($0)}');
    used+=${files[counter]}$'\n'
    (( counter++ ))
    if (( audio >= video )); then
        for i in `seq 1 $(( audio / video + 2 ))`; do printf '%s\n' "file ${files[counter]}" >> list.txt; done
        ffmpeg -f concat -i list.txt -i $f -c copy -t $audio "edited/$(basename -- ${f%.*})".mp4""
        > list.txt
    else
        ffmpeg -i ${files[counter]} -i $f -c copy -t $audio "edited/$(basename -- ${f%.*})".mp4""
    fi
done