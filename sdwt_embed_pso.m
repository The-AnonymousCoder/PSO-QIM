function embedshp = sdwt_embed_pso(originshpfile, outshpfile, watermarkImg,numGroups,maxIter)



% 利用虚拟顶点的水印算法
% 适用于线和面

clc;            % 清空命令行窗口
% clear;          % 清除工作区中的所有变量
close all;          % 关闭所有打开的图形窗口
tic;            % 开始计时，计算程序运行时间

% outshpfilename = 'building'; hyda3857 landuse waterways output        % 设置原输出shapefile的路径
% outshpfilename = 'landuse';            % 设置输出shapefile的路径
% 
% originshpfile='vector map/output.shp';
originshpfile=shaperead(originshpfile);         % 读取shapefile中的形状数据

% wo = '猫爪32.png';                % 设置水印图片的文件名
wo=im2bw(imread(watermarkImg));           % 读取水印图片并将其转换为二值图像

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


R=3*10^-2;                  % 量化参数R，用于控制水印嵌入的精度
Mcof = 10^6;                % 大系数，用于比例调整
watermarkedShp=originshpfile;        % 初始化水印后的shapefile，先设置为原始shapefile

% 设置PSO参数范围
% weight_range = 0.6:0.1:0.8;           % weight参数的取值范围
% weight_min_range = 0.2:0.1:0.5;      % weight_min的取值范围
% c1_initial_range = 1.5:0.2:2.5;       % c1_initial的取值范围
% c1_min_range = 0.8:0.2:1.5;           % c1_min的取值范围
% c2_initial_range = 0.8:0.2:1.5;       % c2_initial的取值范围
% c2_max_range = 1:0.2:2.5;           % c2_max的取值范围

% weight_range = [0.6, 0.7, 0.8];           % weight 参数的指定值数组
% weight_min_range = [0.2, 0.4, 0.5];       % weight_min 的指定值数组
% c1_initial_range = [1.2,1.5, 2.0,2.2, 2.4];        % c1_initial 的指定值数组
% c1_min_range = [0.6, 0.8, 1.2, 1.5,2.2];            % c1_min 的指定值数组
% c2_initial_range = [0.6, 0.8, 1.2, 1.5,2.2];        % c2_initial 的指定值数组
% c2_max_range = [1.2,1.5, 2.0,2.2, 2.4];            % c2_max 的指定值数组

weight_range = [0.6];           % weight 参数的指定值数组  0.5,0.6
weight_min_range = [0];       % weight_min 的指定值数组 0
c1_initial_range = [1.8];        % c1_initial 的指定值数组  1.6
c1_min_range = [1.6];            % c1_min 的指定值数组  1.8
c2_initial_range = [1.8];        % c2_initial 的指定值数组 2.2
c2_max_range = [2.2];            % c2_max 的指定值数组  1.8




% 初始最佳值
best_averageFitness = -inf;
best_params = struct('weight', 0, 'weight_min', 0, 'c1_initial', 0, 'c1_min', 0, 'c2_initial', 0, 'c2_max', 0);
current_params = struct('weight', 0, 'weight_min', 0, 'c1_initial', 0, 'c1_min', 0, 'c2_initial', 0, 'c2_max', 0);

% 遍历所有参数组合
for weight = weight_range
    for weight_min = weight_min_range
        for c1_initial = c1_initial_range
            for c1_min = c1_min_range
                for c2_initial = c2_initial_range
                    for c2_max = c2_max_range

                        current_params.weight = weight;
                        current_params.weight_min = weight_min;
                        current_params.c1_initial = c1_initial;
                        current_params.c1_min = c1_min;
                        current_params.c2_initial = c2_initial;
                        current_params.c2_max = c2_max;


                        % 初始化最优适应度数组
                        gBestFitnessArray = [];


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

                            fprintf('对第%d个形状进行迭代', i);
                            % 调用QIM+PSO嵌入函数
                            % 初始化PSO参数

                            gBestFitnessNum = 0;
                            % numGroups = 20;
                            % maxIter = 20;
                            if(length(HX)==0) 
                                continue
                            end;
                             if(length(HY)==0) 
                                 continue
                             end;
                             if(length(yarray)==0) 
                                 continue
                             end;
                            [X_embedded,bestParticleGroup, embeddedCoefficients,gBestFitness] = QIM_PSO_Embed(yarray,LX,HX,HY,Mcof,w,watermarkLength,R,gBestFitnessNum, numGroups, maxIter, weight, weight_min, c1_initial,c1_min,c2_initial,c2_max);

                             % if(gBestFitness~=0) 
                            gBestFitnessArray(end + 1) = gBestFitness;
                             % end;
                            % 存储当前形状的最优适应度
                            
                            fprintf('第%d个形状的最优适应度 = %.4f\n', i, gBestFitness);

                            % 更新水印后的shapefile的X和Y坐标
                            watermarkedShp(i).X = X_embedded;
                            watermarkedShp(i).Y =yarray';

                        end

                        % 计算并打印所有形状的平均适应度
                        averageFitness = mean(gBestFitnessArray);
                        disp('-------当前---------');
                        disp(current_params);
                        fprintf('所有形状的平均适应度 = %.4f\n', averageFitness);

                        disp('-------最优---------');
                        disp(best_params);
                        disp(best_averageFitness);
                        disp('================================');
                        % 检查是否找到更高的gBestFitness
                        if averageFitness > best_averageFitness
                            best_averageFitness = averageFitness;
                            best_params.weight = weight;
                            best_params.weight_min = weight_min;
                            best_params.c1_initial = c1_initial;
                            best_params.c1_min = c1_min;
                            best_params.c2_initial = c2_initial;
                            best_params.c2_max = c2_max;
                        end
                    end
                end
            end
        end
    end
end

% 输出最佳参数组合和最大gBestFitness
disp('最佳参数组合:');
disp(best_params);
disp(['最佳gBestFitness值: ', num2str(best_averageFitness)]);




% 计算水印嵌入前后形状的最大误差和平均误差
[max_error,mean_error,~,~] = SuperError(watermarkedShp,originshpfile)
% 保存嵌入水印后的shapefile
% embedshp=strcat('Embed/Embed_pso_',outshpfile);      % 设置输出文件路径
embedshp = strcat('Embed/Embed_pso_',  num2str(numGroups),'_',num2str(maxIter),  '_', outshpfile);
shapewrite(watermarkedShp,embedshp );           % 写入新的shapefile

toc;            % 结束计时，输出程序运行时间

end


