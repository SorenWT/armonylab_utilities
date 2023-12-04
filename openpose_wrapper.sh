cd ~/Documents/openpose

#echo "Input the folder where the study results are found (NO trailing slash)"

#read inputdirname

#echo "Input the folder where you want to write the openpose outputs (NO trailing slash)"

#read outputdirname

mkdir "${2}/openpose_output_img"
mkdir "${2}/openpose_output_json"

#./build/examples/openpose/openpose.bin --image_dir ~/Desktop/masters/posestudy/images/posestudy_onedrive --write_images ~/Desktop/masters/posestudy/openpose_output_img --write_json ~/Desktop/masters/posestudy/openpose_output_json

# assumes that the files are found in inputdir/

#for d in ${1}/ ; do
./build/examples/openpose/openpose.bin --display 0 --image-dir $1 --write_images ${2}/openpose_output_img --write_json ${2}/openpose_output_json

#magick ${2}/openpose_output_img/*.png -resize 50%  ${2}/openpose_output_img/%d.jpg
#rm ${2}/openpose_output_img/*.png
#mogrify -resize 50% ${2}/openpose_output_img/*.png
#done


#