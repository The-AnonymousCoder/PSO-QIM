clc;            % 清空命令行窗口
clear;          % 清除工作区中的所有变量
close all;          % 关闭所有打开的图形窗口  Embed_pso_shanghai_landuse1

% Railways Building Landuse  Boundary Road  Lake
originshpfile='Embed/Embed_pso_10_40_Lake.shp';
outshpfile = 'Lake.shp'; 
watermarkImg = 'M.png'; 
embedshp = originshpfile;


% R
c_values = 0:45:360;
% 遍历每个 c 值
for i = 1:length(c_values)
% c = 0.1;  % 获取当前的第三个参数值
    angle = c_values(i);
    
     % = 45; 
    scale = 0.5;
    attackshp = attacks7_geometric(embedshp, outshpfile, angle, 1, 0, 0);  % 调用函数并传入第三个参数
    [NC1, BER] = sdwt_extract_TS(attackshp, 'M.png'); 
    disp(angle);
    % disp(addRatio);
    disp(NC1);
    disp(BER);
    disp("----------------------");

end

% S

% R
c_values = 0.1:0.4:2.1;
% 遍历每个 c 值
for i = 1:length(c_values)
    % c = 0.1;  % 获取当前的第三个参数值
    scale = c_values(i);
    % angle = 45; 
    % scale = 0.5;
    attackshp1 = attacks7_geometric(embedshp, outshpfile, 0, scale, 0, 0);  % 调用函数并传入第三个参数
    [NC2, BER] = sdwt_extract_TS(attackshp1, 'M.png'); 
    disp(scale);
    % disp(addRatio);
    disp(NC2);
    disp(BER);
    disp("----------------------");

end

% T
c_values = 10:10:60;
% 遍历每个 c 值
for i = 1:length(c_values)
    % c = 0.1;  % 获取当前的第三个参数值
    x_shift = c_values(i); 
    y_shift = c_values(i);
    attackshp3 = attacks7_geometric(embedshp, outshpfile, 0, 1, x_shift, y_shift);  % 调用函数并传入第三个参数
    [NC3, BER] = sdwt_extract_TS(attackshp3, 'M.png');
    disp(x_shift);
    disp(NC3);
    disp(BER);
    disp("----------------------");

end




