function name = attacks2_vertex_add(watermarkedshp, outshpfile, addRatio,strength,tolerance)
    % attacks2_vertex_add - 实现随机增点攻击
    % 该函数通过在矢量地图中随机添加顶点来生成新的地图文件。
    %
    % 输入参数：
    %   watermarkedshp - 含水印的矢量地图文件名
    %   outshpfile - 输出矢量地图文件的文件名
    %   addRatio - 增加顶点的比例（0到1之间）
    %
    % 输出参数：
    %   name - 保存新矢量地图文件的完整路径名

    % 设置增点比例
    % addRatio = 0.8;      % 增点的概率（0.8 表示 80% 的点对之间可能插入一个新点）
    % addratiostr = addRatio;  % 用于文件命名的比例字符串

    % 设置随机数生成器状态，确保每次增点操作的随机性一致
    rand('state', 233337);

    % 设置增点强度和容差
    % strength = 0.5;     % 增点的随机偏移强度
    % tolerance = 0.5;    % 增点的偏移容差

    % 读取嵌入水印后的矢量地图
    watermarkedshp = shaperead(watermarkedshp);  % 读取 shapefile 数据

    % 初始化新的矢量地图结构
    newshp = watermarkedshp;

    % 随机增点策略
    for i = 1:length(watermarkedshp)
        % 提取当前形状的 X 和 Y 坐标
        xarray = watermarkedshp(i).X;
        yarray = watermarkedshp(i).Y;

        % 移除 NaN 点，仅保留有效的 X 和 Y 坐标
        xarray = xarray(~isnan(xarray));
        yarray = yarray(~isnan(yarray));

        % 初始化新的坐标数组，包含起始点
        xarraynew = [xarray(1)];
        yarraynew = [yarray(1)];

        % 循环处理每个顶点，随机插入新点
        for j = 2:length(xarray)
            rd1 = rand;  % 决定是否添加新点的随机数
            rd2 = rand;  % 新点的相对位置随机数

            % 根据 addRatio 确定是否插入新点
            if rd1 < addRatio
                % 计算新点的位置，加入随机偏移
                new_x = xarray(j - 1) + rd2 * (xarray(j) - xarray(j - 1)) + strength * tolerance;
                new_y = yarray(j - 1) + rd2 * (yarray(j) - yarray(j - 1)) - strength * tolerance;
                xarraynew = [xarraynew, new_x];
                yarraynew = [yarraynew, new_y];
            end

            % 添加原点
            xarraynew = [xarraynew, xarray(j)];
            yarraynew = [yarraynew, yarray(j)];
        end

        % 将新数组赋值回新矢量地图，添加 NaN 表示断开
        newshp(i).X = [xarraynew, nan];
        newshp(i).Y = [yarraynew, nan];
    end

    % 设置输出文件路径，并使用 addRatio 作为文件命名部分
    name = fullfile('attacked', 'add', ['add_','s', num2str(strength), '_','ratio',num2str(addRatio), '_', outshpfile]);

    % 保存新的 shapefile
    shapewrite(newshp, name);
end
