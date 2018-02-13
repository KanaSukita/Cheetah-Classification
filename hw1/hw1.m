%% a) Compute the prior probabilities
load('TrainingSamplesDCT_8.mat')

[rowBG columnBG] = size(TrainsampleDCT_BG);
[rowFG columnFG] = size(TrainsampleDCT_FG);
priorBG = rowBG / (rowBG + rowFG)
priorFG = rowFG / (rowBG + rowFG)

%% b) Plot the histogram
XBG = zeros(64,1);
XFG = zeros(64,1);
    %get the X of background
for count = 1: rowBG
    [sortNum sortPosition] = sort(abs(TrainsampleDCT_BG(count, :)));
    %XBG(count) = sortPosition(63); 
    XBG(sortPosition(63)) = XBG(sortPosition(63)) + 1;
end
    %get the X of frontground
for count = 1: rowFG
    [sortNum sortPosition] = sort(abs(TrainsampleDCT_FG(count, :)));
    XFG(sortPosition(63)) = XFG(sortPosition(63)) + 1;
end
    
XBG = XBG ./ rowBG;
XFG = XFG ./ rowFG;
figure;
bar(XFG);
set(get(gca,'YLabel'),'String','P(X|cheetah)','FontSize',10);
set(get(gca,'XLabel'),'String','X(index of 2nd largest)','FontSize',10);
figure;
bar(XBG);
set(get(gca,'YLabel'),'String','P(X|grass)','FontSize',10);
set(get(gca,'XLabel'),'String','X(index of 2nd largest)','FontSize',10);

%% c)
THold = priorBG / priorFG;

[A, B] = imread('cheetah.bmp');
A2 = im2double(A);

a = zeros(263*248, 64);

for i = 1:(270-7)  
    for j = 1:(255-7) 
        temp = A2(j:j+7, i:i+7);
        temp = dct2(temp);
        a((i-1)*248+j, :) = tras264(temp);
    end
end

d = zeros(255,270);
for i = 1:65224
    [sortNum sortPosition] = sort( abs( a(i, :) ) );
    if((XFG(sortPosition(63))) / (XBG(sortPosition(63))) > THold)   
        d(rem(i,248)+1, floor(i/248)+1) = 1;
    end
end

imshow(d);


%Cmask = mat2gray(d);
%imshow(Cmask);


[A2 B2] = imread('cheetah_mask.bmp');
A2 = A2/255;
falseness = sum(sum(xor(A2, d))) / (255*277)