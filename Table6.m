clc;            % 清空命令行窗口
clear;          % 清除工作区中的所有变量
close all;          % 关闭所有打开的图形窗口  Embed_pso_shanghai_landuse1

% Railways Building Landuse  Boundary Road  Lake
originshpfile='embedData_40_pso/Embed_pso_withoutGA10_40_Lake.shp';
originshpfile='Embed/Embed_pso_10_40_Railways.shp';
outshpfile = 'Railways.shp'; 
watermarkImg = 'M.png'; 
embedshp = originshpfile;

attackshp = attacks8_compound(embedshp, outshpfile);  % 调用函数并传入第三个参数
[NC, BER] = sdwt_extract_TS(attackshp, 'M.png'); 
disp(NC);
% disp(BER);
disp("----------------------");






