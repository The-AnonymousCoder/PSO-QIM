
% shanghai_landuse  shanghai_railways  shanghai_water
% BOUL      BRGA        VEGA
clc;            % 清空命令行窗口
clear;          % 清除工作区中的所有变量
close all;          % 关闭所有打开的图形窗口  Embed_pso_shanghai_landuse1


% 1.源文件
originshpfile='/Users/wangfugui/Desktop/X老师/复现算法/顶点加密算法_PSO/Embed/Embed_pso_20_1_shanghai_landuse.shp';
% originshpfile='pso_data/shanghai_landuse';
outshpfile = 'shanghai_landuse.shp'; 
watermarkImg = '猫爪32.png'; 

% 2.水印嵌入
embedshp = originshpfile;
% embedshp = sdwt_embed_pso(originshpfile, outshpfile, watermarkImg,20,1);
% embedshp = sdwt_embed_check(originshpfile, outshpfile, watermarkImg,0);


% 3.鲁棒测试 
attackshp = embedshp;


% 1.  顶点删除  0.3
c = 0.3;  % 获取当前的第三个参数值
attackshp = attacks1_vertex_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 2.  顶点删除  0.5
c = 0.5;  % 获取当前的第三个参数值
attackshp = attacks1_vertex_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 3.  顶点删除  0.3
c = 0.3;  % 获取当前的第三个参数值
attackshp = attacks4_object_delete(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 4.顶点增加 0.1
c = 0.1;  % 获取当前的第三个参数值
attackshp = attacks2_vertex_add(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 5.顶点增加 0.3
c = 0.1;  % 获取当前的第三个参数值
attackshp = attacks2_vertex_add(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 6.顶点噪声增加
c = 0.1;  % 获取当前的第三个参数值
attackshp = attacks3_vertex_noise(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 7.顶点噪声增加
c = 0.5;  % 获取当前的第三个参数值
attackshp = attacks3_vertex_noise(embedshp, outshpfile, c);  % 调用函数并传入第三个参数
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png');  % 调用第二个函数
fprintf('Processed with c = %.1f\n', c);  % 打印当前参数值

% 8. 图片裁剪
attackshp = attacks5_object_crop(embedshp,outshpfile,'Y');
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png'); 

% 9. 几何攻击 Translation by 10 units
attackshp = attacks7_geometric(embedshp,outshpfile,45, 0.8, 1, 1);
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png'); 

% 10. 几何攻击 旋转 45 度  0.8缩小为 80%  X 和 Y 方向的平移距离。例如 10 和 15 表示分别平移 10 和 15 个单位
attackshp = attacks7_geometric(embedshp,outshpfile,0, 0.9, 0, 0);
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png'); 

% 11. 顶点重组
attackshp = attacks6_1_vertex_reorganization(embedshp,outshpfile);
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png'); 

% 12. 对象重组
attackshp = attacks6_2_object_reorganization(embedshp,outshpfile);
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png'); 

% 13.组合攻击
attackshp = attacks8_compound(embedshp,outshpfile);
[NC,BER] = sdwt_extract_TS(attackshp, '猫爪32.png'); 



