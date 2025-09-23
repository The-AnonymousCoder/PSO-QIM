function name = attacks1_vertex_delete(originshpfile, outshpfile, deletefactor)
    % attacks1_vertex_delete - 实现随机删点攻击
    % 该函数通过随机删除矢量地图中的顶点来生成新的地图文件。
    %
    % 输入参数：
    %   originshpfile - 原始矢量地图文件的文件名
    %   outshpfile - 输出矢量地图文件的文件名
    %   deletefactor - 删除顶点的概率（0到1之间）
    %
    % 输出参数：
    %   name - 保存新矢量地图文件的完整路径名

    % 设置随机数生成器状态
    rand('state', 1);

    % 读取矢量地图
    originshpfile = shaperead(originshpfile); % 读取 shapefile 数据
    newshp = originshpfile; % 初始化新矢量地图数据

    % 统计矢量地图中所有顶点的个数
    totalvalue = []; % 初始化存储所有顶点的数组
    for i = 1:length(originshpfile)
        % 获取非 NaN 的 X 和 Y 坐标
        xarray = originshpfile(i).X(~isnan(originshpfile(i).X));
        yarray = originshpfile(i).Y(~isnan(originshpfile(i).Y));
        totalvalue = [totalvalue, xarray]; % 将 X 坐标加入总数组
    end

    % 计算总顶点数
    ocount = length(totalvalue);

    % 随机删除顶点：生成一个逻辑数组，表示是否保留每个顶点
    flag = rand(1, ocount) < deletefactor; % < 符号表示保留顶点的概率

    % 初始化变量
    cluster = 1; % 顶点索引，用于遍历整个地图的所有顶点

    % 开始遍历每个元素并删除指定比例的顶点
    for i = 1:length(originshpfile)
        % 获取当前元素的非 NaN X 和 Y 坐标
        xarray = originshpfile(i).X(~isnan(originshpfile(i).X));
        yarray = originshpfile(i).Y(~isnan(originshpfile(i).Y));
        xarray2 = []; % 新的 X 坐标数组
        yarray2 = []; % 新的 Y 坐标数组

        % 遍历顶点，根据标记数组决定是否保留顶点
        for j = 1:length(xarray)
            if flag(cluster) == 0  % 保留该顶点
                xarray2 = [xarray2, xarray(j)];
                yarray2 = [yarray2, yarray(j)];
            end
            cluster = cluster + 1; % 更新顶点索引
        end

        % 将删除后剩余的顶点赋给新地图
        newshp(i).X = xarray2;
        newshp(i).Y = yarray2;

        % 如果顶点全部被删除，保留首尾点
        if isempty(xarray2)
            newshp(i).X = [xarray(1), xarray(end)];
            newshp(i).Y = [yarray(1), yarray(end)];
        end
    end

    % 统计保留后的顶点总数
    finalCount = length([newshp(:).X]);

    % 生成输出文件的完整路径
    name = fullfile('attacked', 'delete', ['delete_', num2str(deletefactor), outshpfile]);

    % 保存新的矢量地图
    shapewrite(newshp, name);
end
