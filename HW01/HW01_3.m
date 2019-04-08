clear

%(1)
imageFilename              =  'face2.jpg';
imagRGB                    =  imread(imageFilename);
imagGrey                   =  rgb2gray(imagRGB);
[rows,cols]                =  size(imagGrey);
figure
subplot(1,2,1);
imshow(imagGrey);
title('Grey');
subplot(1,2,2);
imagNeg=255.-imagGrey;
imshow(imagNeg);
title('Negative');

%(2)
figure
i=1;
for BER=[0.001,0.005,0.01,0.02]
    imagTmp=imagGrey;
    for j=1:rows
        for k=1:cols
            if(rand<BER)
                imagTmp(j,k)=255-imagTmp(j,k);
            end
        end
    end
    subplot(2,2,i);
    i=i+1;
    imshow(imagTmp);
    title(['BER=',num2str(BER)]);
end


