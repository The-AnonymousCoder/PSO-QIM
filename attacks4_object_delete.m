function name = attacks4_object_delete(originshpfile, outshpfile, deleteRatio)
    % attacks4_object_delete - 实现随机删除地理要素攻击
    % 该函数通过随机删除矢量地图中的地理要素，生成新的地图文件。
    %
    % 输入参数：
    %   originshpfile - 原始矢量地图文件的文件名
    %   outshpfile - 输出矢量地图文件的文件名
    %   deleteRatio - 删除地理要素的比例（0到1之间）
    %
    % 输出参数：
    %   name - 保存新矢量地图文件的完整路径名

    % 设置删除比例和删除比例字符串用于文件命名
    % deletefactorstr = '90';    % 用于文件命名的删除比例字符串 1
    rand('state', 31765871364);          % 设置随机数生成器状态，确保随机性一致

    % 读取矢量地图文件
    originshpfile = shaperead(originshpfile);  % 读取 shapefile 数据

    % 获取地理要素的总数量
    count = length(originshpfile);

    % 确定保留哪些要素，使用随机数和删除比例
    reservedFs = rand(1, count) > deleteRatio; % 保留标记数组，值为 1 的要素将被保留
    indexs = find(reservedFs == 1);            % 获取保留要素的索引
    reservedFe = originshpfile(indexs);        % 提取保留的地理要素

    % 设置输出文件路径，包含删除比例字符串
    name = fullfile('attacked', 'deleteFeature', ['delete_', num2str(deleteRatio), '_', outshpfile]);

    % 保存新的 shapefile
    shapewrite(reservedFe, name);
end
