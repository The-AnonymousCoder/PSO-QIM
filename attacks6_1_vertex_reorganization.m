function name = attacks6_1_vertex_reorganization(shpFile,outshpfile)
    % vertex_reorganization_attack - 顶点重组攻击
    % 
    % 参数:
    %   shpFile - 输入的 .shp 文件路径
    %
    % 返回:
    %   newshp - 顶点顺序颠倒后的形状数据结构

    % 读取 .shp 文件
    try
        shpData = shaperead(shpFile); % 读取输入的矢量地图数据
    catch
        error('无法读取文件，请检查文件路径。');
    end

    % 初始化输出结构
    newshp = shpData; % 初始化为原始数据

    % 逐个对象进行顶点顺序颠倒
    for i = 1:length(shpData)
        % 获取当前形状的 X 和 Y 坐标
        xarray = shpData(i).X;
        yarray = shpData(i).Y;

        % 去掉 NaN 值来反转顺序
        xnotnan = xarray(~isnan(xarray)); % 非 NaN 的 X 坐标
        ynotnan = yarray(~isnan(yarray)); % 非 NaN 的 Y 坐标

        % 反转顺序
        xarray_reversed = flip(xnotnan);
        yarray_reversed = flip(ynotnan);

        % 将反转的坐标存入新结构，并加上 NaN 表示结束
        newshp(i).X = [xarray_reversed, nan];
        newshp(i).Y = [yarray_reversed, nan];
    end

    % 输出顶点重组攻击结果
    name = strcat('attacked/object_reorganized/', outshpfile);
    shapewrite(newshp, name); % 写入结果到新文件
    fprintf('顶点重组攻击完成，文件已保存到 %s\n', name);
end
