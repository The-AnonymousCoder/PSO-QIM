function name = attacks8_compound(embedshp, outshpfile)
    % attacks8_compound: 组合攻击函数
    % 包含以下攻击：
    % 1. 顶点删除
    % 3. 对象删除
    % 4. 顶点增加
    % 6. 顶点噪声增加
    % 9. 几何攻击（平移）
    % 10. 几何攻击（旋转）
    % 11. 顶点重组
    % 12. 对象重组

    % 创建保存复合攻击结果的目录
    output_dir = fullfile('attacked', 'compound');
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    % 设置输出文件路径
    compound_outshpfile = fullfile(output_dir, ['compound_', outshpfile]);

    % 开始执行复合攻击
    fprintf('开始执行复合攻击...\n');

    % 1. 顶点删除（c = 0.3）
    c_vertex_delete = 0.3;
    tempshp1 = attacks1_vertex_delete(embedshp, outshpfile, c_vertex_delete);
    
    % 3. 对象删除（c = 0.3）
    c_object_delete = 0.3;
    tempshp2 = attacks4_object_delete(tempshp1, outshpfile, c_object_delete);
    
    % 4. 顶点增加（c = 0.1）
    c_vertex_add = 0.1;
    tempshp3 = attacks2_vertex_add(tempshp2, outshpfile, c_vertex_add,1,0.01);
    
    % 6. 顶点噪声增加（c = 0.1 strengh = 0.6）
    c_vertex_noise = 0.2;
    tempshp4 = attacks3_vertex_noise(tempshp3, outshpfile, c_vertex_noise,0.6);
    
    % 9. 几何攻击：平移（x_shift = 10, y_shift = 10）
    x_shift = 10; 
    y_shift = 10;
    tempshp5 = attacks7_geometric(tempshp4, outshpfile, 0, 1, x_shift, y_shift);
    
    % 10. 几何攻击：缩放，旋转0（angle = 45, scale = 0.5）
    angle = 45; 
    scale = 0.5;
    tempshp6 = attacks7_geometric(tempshp5, outshpfile, 0, scale, 0, 0);
    
    % 11. 顶点重组
    tempshp7 = attacks6_1_vertex_reorganization(tempshp6, outshpfile);
    
    % 12. 对象重组
    finalshp = attacks6_2_object_reorganization(tempshp7, outshpfile);
   
    % 返回结果文件路径
    name = finalshp;

    % % 写入最终复合攻击结果到文件
    % shapewrite(finalshp, outshpfile);

    % 输出日志
    fprintf('复合攻击完成，结果已保存到 %s\n', name);
end
