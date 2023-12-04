function tiltangle = get_photo_tilt(imgname)

donetilt = false;
img = imread(imgname);
imshow(img);
hold on


while ~donetilt
[x1,y1] = ginput(1);
s1=scatter(x1,y1,18,'r','filled');

[x2,y2] = ginput(1);
s2=scatter(x2,y2,18,'r','filled');
l=line([x1 x2],[y1 y2],'linewidth',2,'color','r');

tiltangle = rad2deg(atan((y1-y2)./(x1-x2)));
cont = input([imgname ': photo tilt angle is ' num2str(tiltangle) ' degrees. Continue? (y/n)'],'s');

if strcmpi(cont,'y')
    donetilt = true;
    close(gcf);
else
    delete(s1); delete(s2); delete(l)
end
end

