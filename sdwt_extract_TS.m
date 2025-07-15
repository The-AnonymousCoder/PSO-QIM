function [NC_Value,BER_Value] = sdwt_extract_TS(originshpfile,watermarkImg)



% clc;        % 清空命令行窗口
% clear;      % 清除工作区中的所有变量
% close all;      % 关闭所有打开的图形窗口


% 选择输入的shapefile文件
% [originshpfilename, cover_pthname] = ...
%     uigetfile('*.shp', 'Select the shp file');      % 弹出对话框选择shapefile文件
% if (originshpfilename ~= 0)                  % 如果选择了文件
%     originshpfile = strcat(cover_pthname, originshpfilename);       % 拼接路径和文件名
%     originshpfile = shaperead(originshpfile);       % 读取shapefile数据
% else
%     return;                 % 如果未选择文件，则退出程序
% end

outpngname = originshpfile;
originshpfile = shaperead(originshpfile);       % 读取shapefile数据

% 选择水印图片
% [watermark_fname, watermark_pthname] = ...
%     uigetfile('*.jpg; *.png; *.tif; *.bmp', 'Select the Watermark Logo');       % 弹出对话框选择水印图像
% if (watermark_fname ~= 0)           % 如果选择了文件
%     w = strcat(watermark_pthname, watermark_fname);         % 拼接路径和文件名
%     w=im2bw(imread(w));         % 读取并转换为二值图像
% else
%     return;         % 如果未选择文件，则退出程序
% end

w=im2bw(imread(watermarkImg)); 

M =size(w);         % 获取水印图像的大小
watermarkLength = M(1)*M(2);        % 计算水印的长度（像素数量）

ww={};          % 初始化一个空的元胞数组，用于保存水印信息
for i=1:watermarkLength
   ww{i}=[];        % 初始化每个水印位的存储数组
end



R=3*10^-2;          % 设置量化参数R，用于水印提取
Mcof = 10^6;        % 设置大系数Mcof，用于调整比率的缩放

geotype = originshpfile(1).Geometry;        % 获取shapefile中第一个形状的几何类型
allP=[];                    % 初始化用于保存所有顶点数据的数组
allEmbed=[];            % 初始化用于保存所有嵌入数据的数组

% 遍历每个形状，进行水印提取
for i=1:length(originshpfile)
    xarray = originshpfile(i).X;        % 提取第i个形状的X坐标
    yarray =  originshpfile(i).Y;       % 提取第i个形状的Y坐标
    xnotnanindex=find(~isnan(xarray));      % 找出X坐标中非NaN值的索引
    ynotnanindex=find(~isnan(yarray));      % 找出Y坐标中非NaN值的索引
    xarray=xarray(xnotnanindex)';       % 去除NaN值并将X坐标转置为列向量
    yarray=yarray(ynotnanindex)';       % 去除NaN值并将Y坐标转置为列向量
   
    xys=[xarray  yarray];       % 将X和Y坐标组合成一个矩阵
 
    if(length(xarray)==0)       % 如果X坐标为空，跳过该形状
        continue
    end
    [LX,HX] = sdwt(xys(:,1)');      % 对X坐标进行离散小波变换，得到低频(LX)和高频(HX)系数
    [LY,HY] = sdwt(xys(:,2)');      % 对Y坐标进行离散小波变换，得到低频(LY)和高频(HY)系数
       

    y_norm = (yarray - min(yarray)) / (max(yarray) - min(yarray)); % 归一化到 [0, 1] 范围
    % y_norm =yarray; % 归一化到 [0, 1] 范围

    pList = [];
    % 遍历每个高频系数，提取水印
    for n=1:length(HX)
        if(HY(n)==0)  % 如果Y的高频系数为0，跳过该点
            continue;
        end  
        
        ratioLXY = HX(n) / HY(n);       % 计算X和Y坐标的高频系数比率
        ratioLXY_forrecord=ratioLXY;        % 记录原始比率用于调试
        p = mod(floor(ratioLXY*100000), watermarkLength) + 1;
        pList = [pList,p];
        ratioLXY = ratioLXY*Mcof;       % 乘以Mcof调整比率
%         p=mod(floor(ratioLXY/100),watermarkLength)+1;
        % p=round(y_norm(n) * (watermarkLength - 1)) + 1; 
        % p=mod(floor(HY(n)*100000000),watermarkLength)+1; % 根据Y坐标计算水印的位置
        % p = mod(floor(ratioLXY/100), watermarkLength) + 1;

        % p=round(y_norm(n) * (watermarkLength - 1)) + 1; % 根据Y坐标计算水印的位置
        
        % 根据比率的值提取水印位
        if mod(ratioLXY,R)<R/2     % 如果比率的模小于等于R/2
            ww{p}=[ww{p},0];        % 提取水印位为0
        else
            ww{p}=[ww{p},1];        % 提取水印位为1
        end
        
    end

end

w2=[];          % 初始化水印提取结果数组
w2(1:watermarkLength)=0;        % 初始化所有水印位为0
% ͶƱ
for i=1:watermarkLength
    v = sum(ww{i})/length(ww{i});       % 计算每个位的投票平均值
    if( v <0.5)             % 如果投票结果小于0.5
      w2(i)=0;              % 将该位设为0
    else
      w2(i)=1;              % 否则设为1
    end
end

w2=reshape(w2,[M(1),M(2)]);             % 将水印位数组重构为水印图像的尺寸
w2=logisticD(w2,0.98);              % 通过logistic解密恢复水印


% figure;                             % 创建图形窗口
% subplot(2, 1, 1);                    % 创建2行1列的子图，第一个子图
% imshow(w);                          % 显示原始水印图像
% title('原始水印');                      % 设置标题为"原始水印"
% subplot(2, 1, 2);                   % 第二个子图
% imshow(w2);                         % 显示提取的水印图像


% 创建保存目录（如果不存在）
saveDir = 'extract_png';
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end

% 构建完整保存路径
[~, baseFileName, ~] = fileparts(outpngname);
outpngname = fullfile(saveDir, [baseFileName, '.png']);

% 保存提取的水印图像
try
    imwrite(w2, outpngname);
    fprintf('水印图像已成功保存至: %s\n', outpngname);
catch e
    fprintf('保存图像时出错: %s\n', e.message);
end


NC_Value =     NC(w2,w);                         % 计算相似性系数（NC）
BER_Value = BER(w2,w);                        % 计算误码率（BER）


end