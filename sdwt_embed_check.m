function embedshp = sdwt_embed_check(originshpfile, outshpfile, watermarkImg,checkIter)


% 利用虚拟顶点的水印算法
% 适用于线和面

% clc;            % 清空命令行窗口
% clear;          % 清除工作区中的所有变量
% close all;          % 关闭所有打开的图形窗口
tic;            % 开始计时，计算程序运行时间  landuse  hyda3857  building  waterways  output

originshpfile=shaperead(originshpfile);         % 读取shapefile中的形状数据

wo = watermarkImg;                % 设置水印图片的文件名
wo=im2bw(imread(wo));           % 读取水印图片并将其转换为二值图像

M =size(wo);                            % 获取水印图像的尺寸
watermarkLength = M(1)*M(2);            % 计算水印的长度（即像素数）
w=logisticE(wo,0.98);                   % 使用logistic映射生成一个加密的水印序列




% 显示原始水印图像和加密后的水印图像
% figure;                     % 创建一个新的图形窗口
% subplot(2, 1, 1);               % 将图形窗口分成两行一列，在第一个位置显示原始水印图像
% imshow(wo);                 % 显示原始水印图像
%
% subplot(2, 1, 2);           % 在第二个位置显示加密后的水印图像
% imshow(w);                  % 显示加密后的水印图像


virtualCount=3;             % 虚拟顶点的个数，设为奇数
R=3*10^-2;                  % 量化参数R，用于控制水印嵌入的精度
Mcof = 10^6;                % 大系数，用于比例调整
watermarkedShp=originshpfile;        % 初始化水印后的shapefile，先设置为原始shapefile

% 遍历shapefile中的每个形状，进行水印嵌入
for i=1:length(originshpfile)


    xarray = originshpfile(i).X;        % 提取第i个形状的X坐标数组
    yarray =  originshpfile(i).Y;       % 提取第i个形状的Y坐标数组
    xnotnanindex=find(~isnan(xarray));  % 找出X坐标中非NaN值的索引
    ynotnanindex=find(~isnan(yarray));  % 找出X坐标中非NaN值的索引
    xarray=xarray(xnotnanindex)';       % 去除X坐标中的NaN值并转置为列向量
    yarray=yarray(ynotnanindex)';       % 去除Y坐标中的NaN值并转置为列向量


    if (length(xarray)==0)          % 如果没有有效的X坐标数据，则跳过这个形状
        continue
    end
    xys=[xarray  yarray];           % 将X和Y坐标组合成一个矩阵


    [LX,HX] = sdwt(xys(:,1)');      % 对X坐标进行离散小波变换，得到低频和高频系数
    [LY,HY] = sdwt(xys(:,2)');      % 对Y坐标进行离散小波变换，得到低频和高频系数

    HX_mod=[];                      % 初始化修改后的X高频系数数组


    y_norm = (yarray - min(yarray)) / (max(yarray) - min(yarray)); % 归一化到 [0, 1] 范围
    % y_norm = yarray;
    pList = [];

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
        if w(p)==0 &&  mod(ratioLXY,R)>R/2         % 如果水印位为0且比率的模大于R/2，减去R/2
            ratioLXY=ratioLXY-R/2;
        elseif w(p)==1 && mod(ratioLXY,R)<R/2       % 如果水印位为1且比率的模小于R/2，加上R/2
            ratioLXY=ratioLXY+R/2;
        end
        HX_mod(n)=ratioLXY*HY(n);           % 将修改后的比率乘以Y坐标高频系数，更新X坐标高频系数
    end


            % p=round(y_norm(n) * (watermarkLength - 1)) + 1;   % 根据当前顶点的Y坐标和水印长度计算嵌入的位置p
        % p = mod(floor(HY(n) * 100000000), watermarkLength) + 1;

    % 测试NP

    % 每组粒子的阴性计数  初始化 高频系数modifiedCoefficients
    % N = length(HX);  % 高频系数数量
    % negative_count = 0;
    % fitness = 0;
    % modifiedCoefficients = ratioLXY;
    % HX_mod = zeros(1, N);
    % X_embedded = 0;
    % 
    % % 水印嵌入后的高频系数
    % for i = 1:N
    %     if HY(i) == 0  % 如果Y坐标的高频系数为0，则跳过该点
    %         HX_mod(i) = HX(i) * Mcof;  % 将该点的X坐标高频系数乘以Mcof，不做水印修改
    %         continue;
    %     end
    %     % modifiedCoefficients(i) = modifiedCoefficients(i) + positions(g, i);
    %     HX_mod(i)=modifiedCoefficients(i)*HY(i);
    % end
    % 
    % % 计算当前组粒子的阴性概率(适应度)
    % HX_mod =  HX_mod/Mcof;              % 将X坐标高频系数除以Mcof，恢复比例
    % % 该变换会去除H_WVV，去除加水印后的虚拟点
    % X_embedded = isdwt(LX,HX_mod);      % 通过逆离散小波变换（IDWT）得到修改后的X坐标
    % [LX_CVV,HX_CVV] = sdwt(X_embedded);         % 对X坐标进行离散小波变换
    % for i=1:N-1
    %     H_WVV=ratioLXY(i);
    %     H_CVV= (HX_CVV(i) / HY(i)) * Mcof;
    % 
    %     label_H_WVV = (mod(H_WVV, R) >= R / 2);
    %     label_H_CVV = (mod(H_CVV, R) >= R / 2);
    %     % 判断两个量化结果是否在同一标签区间
    %     if label_H_WVV == label_H_CVV
    %         negative_count = negative_count + 1;
    %     end
    % end
    % fitness = negative_count / N;  % 适应度：阴性概率
    % 
    % fprintf('NP适应度 = %.4f\n', fitness);

    % 测试NP




    HX_mod =  HX_mod/Mcof;              % 将X坐标高频系数除以Mcof，恢复比例
    X_embedded = isdwt(LX,HX_mod);      % 通过逆离散小波变换（IDWT）得到修改后的X坐标



    if checkIter~=0
        for iter=1:checkIter
            X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);
            % X_embedded = watermarkCoor(X_embedded,yarray,HY,w,watermarkLength,R,Mcof);

        end

    end

    % 确保首尾点一致
    % if strcmp(originshpfile(i).Geometry, 'Polygon')  && ~isequal(X_embedded(1), X_embedded(end))
    %     X_embedded(end+1) = X_embedded(1);  % 将首点添加到尾部
    %     yarray(end+1) = yarray(1);          % 将首点添加到尾部
    % end



    % 更新水印后的shapefile的X和Y坐标
    watermarkedShp(i).X = X_embedded;
    watermarkedShp(i).Y =yarray';

end

% 计算水印嵌入前后形状的最大误差和平均误差
[max_error,mean_error,~,~] = SuperError(watermarkedShp,originshpfile)
% 保存嵌入水印后的shapefile
embedshp=strcat('Embed/Embed_normal_',outshpfile);      % 设置输出文件路径
shapewrite(watermarkedShp,embedshp );           % 写入新的shapefile

toc;            % 结束计时，输出程序运行时间



% 定义watermarkCoor函数，进一步调整嵌入的水印
    function X_embedded = watermarkCoor(xs,ys,HY,w,watermarkLength,R,Mcof)

        [LX_check,HX_check] = sdwt(xs);         % 对X坐标进行离散小波变换
        HX_check_mod  = HX_check;               % 初始化修改后的高频系数数组

        % 对高频系数进行调整，嵌入水印
        for n=1:length(HX_check)
            if(HY(n)==0)  % 如果Y坐标的高频系数为0，则跳过该点
                HX_check_mod(n)=HX_check(n)*Mcof;
                continue;
            end
            % 计算X和Y坐标高频系数的比率
            ratioLXY = HX_check(n) / HY(n);

            p = mod(floor(ratioLXY*100000), watermarkLength) + 1;

            ratioLXY = ratioLXY*Mcof;       % 将比率乘以Mcof进行比例调整
            %         p=mod(floor(ratioLXY/100),watermarkLength)+1;
            %
            % 根据Y坐标和水印长度计算嵌入的位置p
            % p=mod(floor(ys(n)*100000),watermarkLength)+1;


            % 根据水印值调整比率，使得该顶点的X坐标高频系数嵌入水印
            if w(p)==0 &&  mod(ratioLXY,R)>R/2
                ratioLXY=ratioLXY+R/2;      % 如果水印位为0且比率的模大于R/2，减去R/2
            elseif w(p)==1 && mod(ratioLXY,R)<R/2
                ratioLXY=ratioLXY+R/2;      % 如果水印位为1且比率的模小于R/2，加上R/2
            end
            HX_check_mod(n)=ratioLXY*HY(n);     % 将修改后的比率乘以Y坐标高频系数，更新X坐标高频系数
        end
        HX_check_mod =  HX_check_mod/Mcof;      % 将高频系数除以Mcof，恢复比例
        X_embedded = isdwt(LX_check,HX_check_mod);      % 通过逆离散小波变换（IDWT）得到修改后的X坐标

    end

end


