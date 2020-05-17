
inputFile_lp1 = fopen ('lp_2_3_loc1.txt','r');
inputFile_lp2 = fopen ('lp_2_3_loc2.txt','r');
inputFile_lpcc1 = fopen ('lpcc_2_3_loc1.txt','r');
inputFile_lpcc2 = fopen ('lpcc_2_3_loc2.txt','r');
inputFile_mfcc1 = fopen ('mfcc_2_3_loc1.txt','r');
inputFile_mfcc2 = fopen ('mfcc_2_3_loc2.txt','r');

lp_coef1 = fscanf(inputFile_lp1, '%f');
lp_coef2 = fscanf(inputFile_lp2, '%f');
lpcc_coef1 = fscanf(inputFile_lpcc1, '%f');
lpcc_coef2 = fscanf(inputFile_lpcc2, '%f');
mfcc_coef1 = fscanf(inputFile_mfcc1, '%f');
mfcc_coef2 = fscanf(inputFile_mfcc2, '%f');

fclose(inputFile_lp1);
fclose(inputFile_lp2);
fclose(inputFile_lpcc1);
fclose(inputFile_lpcc2);
fclose(inputFile_mfcc1);
fclose(inputFile_mfcc2);
%%
figure;
grid on;
subplot(1,3,1);
title("LP");
hold on;
for i=1:(size(lp_coef1)-1)
    plot(lp_coef1(i), lp_coef1(i+1), 'x');
end
hold off;

subplot(1,3,2);
title("LPCC");
hold on;
for i=1:(size(lpcc_coef1)-1)
    plot(lpcc_coef1(i), lpcc_coef1(i+1), 'x');
end
hold off;

subplot(1,3,3);
title("MFCC");
hold on;
for i=1:(size(mfcc_coef1)-1)
    plot(mfcc_coef1(i), mfcc_coef1(i+1), 'x');
end
hold off;

%%
figure;
grid on;
subplot(1,3,1);
title("LP");
hold on;
for i=1:(size(lp_coef2)-1)
    plot(lp_coef2(i), lp_coef2(i+1), 'x');
end
hold off;

subplot(1,3,2);
title("LPCC");
hold on;
for i=1:(size(lpcc_coef2)-1)
    plot(lpcc_coef2(i), lpcc_coef2(i+1), 'x');
end
hold off;

subplot(1,3,3);
title("MFCC");
hold on;
for i=1:(size(mfcc_coef2)-1)
    plot(mfcc_coef2(i), mfcc_coef2(i+1), 'x');
end
hold off;

