function name = attacks9_simplify(originshpfile, outshpfile, charug)
    % attacks9_simplify - 使用道格拉斯-普克算法简化矢量地图
    %
    % 该函数对输入的矢量地图文件执行压缩简化操作，以减少点数。
    %
    % 输入参数：
    %   originshpfile - 输入的 .shp 文件路径
    %   outshpfile - 输出的 .shp 文件名
    %   charug - 简化的阈值参数，用于控制道格拉斯-普克算法的简化程度
    %
    % 输出参数：
    %   name - 保存经过简化后的新矢量地图文件的完整路径名

    originshpfile = shaperead(originshpfile);

    % 设置压缩阈值
    % if nargin < 3
    %     charug = 5; % 默认阈值，如果未指定
    % end

    % 初始化计数器
    oCount = 0; % 原始点总数
    sCount = 0; % 简化后的点总数
    simplifiedShp = originshpfile; % 初始化简化后的数据结构

    % 遍历每个地理要素并进行简化
    for i = 1:length(originshpfile)
        % 提取当前地理要素的 X 和 Y 坐标，排除 NaN 值
        xarray = originshpfile(i).X(~isnan(originshpfile(i).X))';
        yarray = originshpfile(i).Y(~isnan(originshpfile(i).Y))';

        % 合并 X 和 Y 坐标为二维点数组
        xys = [xarray, yarray];

        % 使用道格拉斯-普克算法提取简化后的特征点
        [pts, ids] = Douglas(xys, charug); % 调用 Douglas 函数
        ids = ids'; % 转置 ids 以便使用

        % 更新原始和简化后的点计数
        oCount = oCount + length(yarray);
        sCount = sCount + length(ids);

        % 将简化后的坐标赋值给简化的地理要素结构
        simplifiedShp(i).X = xarray(ids);
        simplifiedShp(i).Y = yarray(ids);
    end

    % 计算压缩比例
    deletefactorstr = 1 - sCount / oCount;

    % 设置输出文件路径，包含简化比例信息
    name = fullfile('attacked', 'simplify', ['simplify_', num2str(deletefactorstr), '_', outshpfile]);

    % 保存简化后的 shapefile 文件
    shapewrite(simplifiedShp, name);
    fprintf('矢量地图简化完成，文件已保存到 %s\n', name);
end
