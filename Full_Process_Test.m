clc;            % 清空命令行窗口
clear;          % 清除工作区中的所有变量
close all;      % 关闭所有打开的图形窗口

% 1.Railways Building Landuse  Boundary Road  Lake
originshpfile = '/Users/wangfugui/Desktop/X老师/复现算法/顶点加密算法_PSO/Embed/Embed_pso_20_1_shanghai_landuse.shp';
originshpfile = 'pso_data/Railways.shp';
outshpfile = 'Railways.shp';
watermarkImg = 'M.png';   

% 嵌入水印
% embedshp = 'Embed/Embed_pso_10_20_Landuse.shp';; % 调用嵌入函数替换为实际实现
% embedshp = sdwt_embed_pso(originshpfile, outshpfile, watermarkImg, 10, 40);
% embedshp = sdwt_embed_check(originshpfile, outshpfile, watermarkImg, 0);
embedshp = sdwt_embed_pso(originshpfile, outshpfile, watermarkImg, 10, 10);
    
% 记录每种攻击的名称和对应的 NC 值、BER 值
attack_names = {
    'No Attack', '顶点删除 0.3', '顶点删除 0.5', '对象删除 0.3', '顶点增加 0.1', ...
    '顶点增加 0.3', '顶点噪声增加 0.1', '顶点噪声增加 0.5', ...
    '图片裁剪', '几何攻击 Translation', '几何攻击 Rotation', ...
    '顶点重组', '对象重组', '组合攻击'
};

% 初始化结果存储
attack_indices = (0:13)'; % 包括无攻击索引 0
nc_values = zeros(length(attack_names), 1);
ber_values = zeros(length(attack_names), 1);

% 无攻击的 NC 和 BER 值
[NC_no_attack, BER_no_attack] = sdwt_extract_TS(embedshp, 'M.png');
nc_values(1) = NC_no_attack;
ber_values(1) = BER_no_attack;

% 参数值
c_values = [0.3, 0.5, 0.3, 0.1, 0.3, 0.1, 0.5];

% 逐个进行攻击并计算 NC 和 BER 值
% for i = 1:13
for i = 1:1
    switch i
        case 1
            attackshp = attacks1_vertex_delete(embedshp, outshpfile, c_values(1));
        case 2
            attackshp = attacks1_vertex_delete(embedshp, outshpfile, c_values(2));
        case 3
            attackshp = attacks4_object_delete(embedshp, outshpfile, c_values(3));
        case 4
            attackshp = attacks2_vertex_add(embedshp, outshpfile, c_values(4),1,10^-6);
        case 5
            attackshp = attacks2_vertex_add(embedshp, outshpfile, c_values(5),1,10^-6);
        case 6
            % noisestrength = 0.6
            attackshp = attacks3_vertex_noise(embedshp, outshpfile, c_values(6), 0.6);
        case 7
            % noisestrength = 1.4
            attackshp = attacks3_vertex_noise(embedshp, outshpfile, c_values(7), 1.4);
        case 8
            attackshp = attacks5_object_crop(embedshp, outshpfile, 'X');
        case 9
            % attackshp = attacks7_geometric(embedshp, outshpfile, 0, 0, 10, 10);
            attackshp = attacks7_geometric(embedshp, outshpfile, 0, 1, 10, 10);
        case 10
            attackshp = attacks7_geometric(embedshp, outshpfile, 0, 0.5, 0, 0);
        case 11
            attackshp = attacks6_1_vertex_reorganization(embedshp, outshpfile);
        case 12
            attackshp = attacks6_2_object_reorganization(embedshp, outshpfile);
        case 13
            attackshp = attacks8_compound(embedshp, outshpfile);
                % 提取水印，计算 NC 和 BER
            % [NC, BER] = sdwt_extract_TS(attackshp, 'M.png');  
            % nc_values(i + 1) = NC; % 存储结果，从索引 2 开始
            % ber_values(i + 1) = BER;
    end
        % 提取水印，计算 NC 和 BER
        [NC, BER] = sdwt_extract_TS(attackshp, 'M.png');  
        nc_values(i + 1) = NC; % 存储结果，从索引 2 开始
        ber_values(i + 1) = BER;
    

end

% 显示原始表格结果
T = table(attack_names', attack_indices, nc_values, ber_values, ...
    'VariableNames', {'Attack_Type', 'Index', 'NC_Value', 'BER_Value'});

% 修正后的转置表格
transposed_data = [T.Properties.VariableNames; ...
                   T.Attack_Type, num2cell(T.Index), num2cell(T.NC_Value), num2cell(T.BER_Value)];

% 创建用于控制台打印的表格
T_Transposed = cell2table(transposed_data(2:end, :), ...
                          'VariableNames', transposed_data(1, :));

disp('转置后的表格（用于命令行显示）：');
disp(T_Transposed);

% 转换为横向布局保存到 Excel
excel_headers = [{'Attack_Type'}, attack_names; ...
                 {'Index'}, num2cell(attack_indices'); ...
                 {'NC_Value'}, num2cell(nc_values'); ...
                 {'BER_Value'}, num2cell(ber_values')];
excel_data = cell2table(excel_headers);

% 保存为横向 Excel 文件
writetable(excel_data, 'attack_results_horizontalRoad.xlsx', 'WriteVariableNames', false);
