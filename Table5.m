clc;            % 清空命令行窗口
clear;          % 清除工作区中的所有变量
close all;          % 关闭所有打开的图形窗口  Embed_pso_shanghai_landuse1

% Railways Building Landuse  Boundary Road  Lake
originshpfile='Embed/Embed_pso_10_40_Railways.shp';
outshpfile = 'Railways.shp'; 
watermarkImg = 'M.png'; 
embedshp = originshpfile;

c_values = 0.1:0.1:0.1;
addRatio_values = 0.1:0.2:0.1;

% 遍历每个 c 值
for i = 1:length(c_values)
% c = 0.1;  % 获取当前的第三个参数值
strength = c_values(i);

for j = 1:length(addRatio_values)
    addRatio = addRatio_values(j);
    attackshp = attacks5_object_crop(embedshp, outshpfile,'X');  % 调用函数并传入第三个参数
    [NC, BER] = sdwt_extract_TS(attackshp, 'M.png'); 
    % disp(strength);
    % disp(addRatio);
    disp(NC);
    disp(BER);
    disp("----------------------");
end

end






