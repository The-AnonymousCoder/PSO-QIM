function [X_embedded,bestParticleGroup, embeddedCoefficients,gBestFitness] = QIM_NP_Embed(yarray,LX,HX,HY,Mcof, watermark,watermarkLength, Q,gBestFitnessNum, numGroups, maxIter, w, w_min, c1_initial,c1_min,c2_initial,c2_max)


N = length(yarray);  % 高频系数数量

bestParticleGroup = zeros(1, N);
% y_norm = yarray;
pList = [];
R=Q;
modifiedCoefficients = zeros(N, 1);
% 利用量化索引调制（QIM）嵌入水印
for n=1:length(HX)
    if(HY(n)==0)            % 如果Y坐标的高频系数为0，则跳过该点
        HX_mod(n)=HX(n)*Mcof;        % 将该点的X坐标高频系数乘以Mcof，不做水印修改
        continue;
    end
    ratioLXY = HX(n) / HY(n);           % 计算X和Y坐标高频系数的比率
    ratioLXY_forrecord=ratioLXY;        % 记录原始比率，方便调试和分析
    p = mod(floor(ratioLXY*100000), watermarkLength) + 1;
    pList = [pList,p];
    ratioLXY = ratioLXY*Mcof;           % 比率乘以Mcof进行比例调整
    %         p=mod(floor(ratioLXY/100),watermarkLength)+1;  yarray(n)*100000
    % p = mod(floor(ratioLXY/100), watermarkLength) + 1;
    % 根据水印值调整比率，使得该顶点的X坐标高频系数嵌入水印
    if watermark(p)==0 &&  mod(ratioLXY,R)>R/2         % 如果水印位为0且比率的模大于R/2，减去R/2
        ratioLXY=ratioLXY-R/2;
    elseif watermark(p)==1 && mod(ratioLXY,R)<R/2       % 如果水印位为1且比率的模小于R/2，加上R/2
        ratioLXY=ratioLXY+R/2;
    end
    HX_mod(n)=ratioLXY*HY(n);           % 将修改后的比率乘以Y坐标高频系数，更新X坐标高频系数
    modifiedCoefficients(n) = ratioLXY;
end

% 每组粒子的阴性计数  初始化 高频系数modifiedCoefficients
negative_count = 0;
fitness = 0;



X_embedded = 0;

% 水印嵌入后的高频系数
% for i = 1:N
%     if HY(i) == 0  % 如果Y坐标的高频系数为0，则跳过该点
%         HX_mod(i) = HX(i) * Mcof;  % 将该点的X坐标高频系数乘以Mcof，不做水印修改
%         continue;
%     end
%     HX_mod(i)=modifiedCoefficients(i)*HY(i);
% end

% 计算当前组粒子的阴性概率(适应度)
% HX_mod =  HX_mod/Mcof;              % 将X坐标高频系数除以Mcof，恢复比例
% 该变换会去除H_WVV，去除加水印后的虚拟点
X_embedded = isdwt(LX,HX_mod);      % 通过逆离散小波变换（IDWT）得到修改后的X坐标
[LX_CVV,HX_CVV] = sdwt(X_embedded);         % 对X坐标进行离散小波变换
for i=1:N-1
    H_WVV=modifiedCoefficients(i);
    H_CVV= (HX_CVV(i) / HY(i)) * Mcof;

    label_H_WVV = (mod(H_WVV, Q) >= Q / 2);
    label_H_CVV = (mod(H_CVV, Q) >= Q / 2);
    % 判断两个量化结果是否在同一标签区间
    if label_H_WVV == label_H_CVV
        negative_count = negative_count + 1;
    end
end
fitness = negative_count / N;  % 适应度：阴性概率
gBestFitness = fitness;

% fprintf('   迭代:第%d次，粒子组:第%d组 当前适应度 = %.4f 最优适应度 = %.4f\n', iter,g ,pBestFitness(g),gBestFitness);

fprintf('最优适应度 = %.4f  全局最优位置已第%d次更新\n', gBestFitness,gBestFitnessNum);

% 通过逆离散小波变换（IDWT）得到修改后的X坐标
HX_mod = HX_mod / Mcof;  % 恢复比例
X_embedded = isdwt(LX, HX_mod);  % 使用IDWT恢复X坐标

embeddedCoefficients = modifiedCoefficients;
end
