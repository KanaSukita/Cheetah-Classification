load('trainingSamplesDCT_8_new.mat');

[rowBG,columnBG] = size(TrainsampleDCT_BG);
[rowFG,columnFG] = size(TrainsampleDCT_FG);

priorBG = rowBG / (rowBG + rowFG);
priorFG = rowFG / (rowBG + rowFG);
prior = [priorBG, priorFG];
counts = [rowBG, rowFG];

figure;
bar(counts);
set(get(gca,'YLabel'),'String','Number of observations');
set(get(gca,'XLabel'),'String','Prior of grass and cheetah');
title('Histogram of number of observations');

figure;
bar(prior);
set(get(gca,'YLabel'),'String','Probability');
set(get(gca,'XLabel'),'String','Prior of grass and cheetah');
title('Histogram estimates of the prior');

mu1 = sum(TrainsampleDCT_BG) / rowBG;
mu2 = sum(TrainsampleDCT_FG) / rowFG;

var1 = std(TrainsampleDCT_BG);
var2 = std(TrainsampleDCT_FG);

for i = 1:64
    x1(i,:) = (mu1(i) - 5*var1(i)):(var1(i)/60):(mu1(i)+5*var1(i));
    y1(i, :) = normpdf(x1(i,:),mu1(i), var1(i));
    
    x2(i,:) = (mu2(i) - 5*var2(i)):(var2(i)/60):(mu2(i)+5*var2(i));
    y2(i, :) = normpdf(x2(i,:),mu2(i), var2(i));
end

for k = 0:3
    figure;
    for i = 1:16
        subplot(4,4,i);
        plot(x1(i+16*k, :),y1(i+16*k, :),'-b',x2(i+16*k, :),y2(i+16*k, :),'-r');
        title(['dimension ',num2str(i+16*k)]);
    end
end

best = [1,11,14,17,23,26,32,40];
worst = [3,4,5,59,60,62,63,64];


figure;
for i = 1:8
    count = best(i);
    
    subplot(2,4,i);
    plot(x1(count,:),y1(count, :),'-b',x2(count,:),y2(count, :),'-r');
    title(['dimension ',num2str(count)]);

end

figure;
for i = 1:8
    count = worst(i);
    
    subplot(2,4,i);
    plot(x1(count,:),y1(count, :),'-b',x2(count,:),y2(count, :),'-r');
    title(['dimension ',num2str(count)]);

end

sig1 = cov(TrainsampleDCT_BG);
sig2 = cov(TrainsampleDCT_FG);

[A, B] = imread('cheetah.bmp');
A2 = im2double(A);

a = zeros(65224, 64);
for i = 1:(270-7)  %colomns
    for j = 1:(255-7) %rows
        temp = A2(j:j+7, i:i+7);
        temp = dct2(temp);
        a((i-1)*248+j, :) = tras264(temp);
    end
end
d = zeros(255,270);

alphaBG = log(((2 * pi)^64) * det(sig1)) - 2*log(priorBG);
alphaFG = log(((2 * pi)^64) * det(sig2)) - 2*log(priorFG);
gBG = zeros(1,65224);
gFG = zeros(1,65224);

for count = 1:65224
    gBG(count) = 1/(1+exp(dxy(a(count, :), mu1, sig1) - dxy(a(count, :), mu2, sig2) + alphaBG - alphaFG));
    gFG(count) = 1/(1+exp(dxy(a(count, :), mu2, sig2) - dxy(a(count, :), mu1, sig1) + alphaFG - alphaBG));
    if(gBG(count) < 0.5)
        d(rem(count,248)+1, floor(count/248)+1) = 1;
    end
end
figure;
Cmask = mat2gray(d);
imshow(Cmask);


[A2 B2] = imread('cheetah_mask.bmp');
A2 = A2/255;
falseness1 = sum(sum(xor(A2, d))) / (255*270);
trueFG = 0;
trueBG = 0;
countFG = 0;
countBG = 0;
for i = 1:255
    for j = 1:270
        if(A2(i,j) == 1)
            if(d(i,j) == 1)
                trueFG = trueFG + 1;
            end
            countFG = countFG+1;
        end
        if(A2(i,j) == 0)
            if(d(i,j) == 0)
                trueBG = trueBG + 1;
            end
            countBG = countBG + 1;
        end   
    end
end
trueBG = trueBG / countBG
trueFG = trueFG / countFG
falseness2 = priorBG * (1-trueBG) + priorFG * (1-trueFG)
falseness = sum(sum(xor(A2, d))) / (255*270)







