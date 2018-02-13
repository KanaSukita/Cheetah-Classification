load ('TrainingSamplesDCT_8_new.mat');

[rowBG columnBG] = size(TrainsampleDCT_BG);
[rowFG columnFG] = size(TrainsampleDCT_FG);
priorBG = rowBG / (rowBG + rowFG);
priorFG = rowFG / (rowBG + rowFG);

best = [1,11,14,17,23,26,32,40];

sampleBG = zeros(1053, 8);
sampleFG = zeros(250, 8);
for i = 1:8
    sampleBG(:, i) = TrainsampleDCT_BG(:, best(i));
    sampleFG(:, i) = TrainsampleDCT_FG(:, best(i)); 
end
mus1 = sum(sampleBG)/1053;
mus2 = sum(sampleFG)/250;
sigs1 = cov(sampleBG);
sigs2 = cov(sampleFG);

[A, B] = imread('cheetah.bmp');
% A is the degree of the pixels 
%B is the color map from 0-149 degrees
A2 = im2double(A);

% a is the matrix of sliding windows
a = zeros(65224, 8);

for i = 1:(270-7)  %colomns
    for j = 1:(255-7) %rows
        temp = A2(j:j+7, i:i+7);
        temp = dct2(temp);
        for k = 1:8
            temp2 = tras264(temp);
            a((i-1)*248+j, k) = temp2(best(k));
        end
    end
end
d = zeros(255,270);

alphaBG = log(((2 * pi)^8) * det(sigs1)) - 2*log(priorBG);
alphaFG = log(((2 * pi)^8) * det(sigs2)) - 2*log(priorFG);

gBG = zeros(1,65224);
gFG = zeros(1,65224);
g2 = zeros(1,65224);

for count = 1:65224
    gBG(count) = 1/(1+exp(dxy(a(count, :), mus1, sigs1) - dxy(a(count, :), mus2, sigs2) + alphaBG - alphaFG));
    gFG(count) = 1/(1+exp(dxy(a(count, :), mus2, sigs2) - dxy(a(count, :), mus1, sigs1) + alphaFG - alphaBG));
    if(gBG(count) < 0.5)
        d(rem(count,248)+1, floor(count/248)+1) = 1;
    end
end

figure;
Cmask = mat2gray(d);
imshow(Cmask);

[A2 B2] = imread('cheetah_mask.bmp');
falseness2 = sum(sum(xor(A2, d))) / (255*270)
[A2 B2] = imread('cheetah_mask.bmp');
A2 = A2/255;
falseness1 = sum(sum(xor(A2, d))) / (255*270)
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