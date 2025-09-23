
% shanghai_landuse  shanghai_railways  shanghai_water
% BOUL      BRGA        VEGA
clc;            % 清空命令行窗口
clear;          % 清除工作区中的所有变量
close all;          % 关闭所有打开的图形窗口  Embed_pso_shanghai_landuse1

% Railways Building Landuse  Boundary Road  Lake
% 1.源文件
originshpfile='Embed/Embed_pso_10_40_Road.shp';
% originshpfile='/Users/wangfugui/Desktop/X老师/复现算法/顶点加密算法_PSO/Embed/Embed_pso_20_1_shanghai_landuse.shp';

% originshpfile='pso_data/shanghai_landuse';
outshpfile = 'Road.shp'; 
watermarkImg = 'M.png'; 

% 2.水印嵌入
embedshp = originshpfile;
% embedshp = sdwt_embed_pso(originshpfile, outshpfile, watermarkImg,20,1);
% embedshp = sdwt_embed_check(originshpfile, outshpfile, watermarkImg,0);


% 3.鲁棒测试 
attackshp = embedshp;

% [NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
% 定义 c 的范围和步长（0.1 到 0.5，步长 0.1）
c_values = 0.1:0.1:0.5;

% 遍历每个 c 值
for i = 1:length(c_values)
% c = 0.1;  % 获取当前的第三个参数值
c = c_values(i);
attackshp = attacks1_vertex_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC, BER] = sdwt_extract_TS(attackshp, 'M.png'); 
disp(c_values(i));
disp(NC);
disp(BER);
disp("----------------------");
end
% % 1.  顶点删除  0.3
% c = 0.3;  % 获取当前的第三个参数值
% attackshp = attacks1_vertex_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
% [NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
% fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值
% 
% % 2.  顶点删除  0.5
% c = 0.5;  % 获取当前的第三个参数值
% attackshp = attacks1_vertex_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
% [NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
% fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值
% 
% % 3.  顶点删除  0.3
% c = 0.3;  % 获取当前的第三个参数值
% attackshp = attacks4_object_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
% [NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
% fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值





