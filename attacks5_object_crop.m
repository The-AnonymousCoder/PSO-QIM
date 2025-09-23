function name = attacks5_object_crop(shpFile, outshpfile, axis)
    % attacks5_object_crop - 裁剪矢量地图的一半
    %
    % 该函数根据指定的 X 或 Y 轴裁剪矢量地图，将地图切为一半。
    %
    % 输入参数：
    %   shpFile - 输入的 .shp 文件路径
    %   outshpfile - 输出的 .shp 文件名
    %   axis - 裁剪轴方向 ('X' 或 'Y')
    %
    % 输出参数：
    %   name - 保存裁剪后矢量地图文件的完整路径名

    % 尝试读取 .shp 文件，如果路径无效则报错
    try
        shpData = shaperead(shpFile); % 读取输入的矢量地图数据
    catch
        error('无法读取文件，请检查文件路径。');
    end

    % 获取地图数据的边界点，确定中点以用于裁剪
    allX = [];
    allY = [];
    for i = 1:length(shpData)
        allX = [allX, shpData(i).X(~isnan(shpData(i).X))]; % 获取非 NaN 的 X 坐标
        allY = [allY, shpData(i).Y(~isnan(shpData(i).Y))]; % 获取非 NaN 的 Y 坐标
    end

    % 计算中位值，根据指定轴方向进行裁剪
    if strcmpi(axis, 'X')
        midValue = median(allX); % 计算 X 轴的中位值
    elseif strcmpi(axis, 'Y')
        midValue = median(allY); % 计算 Y 轴的中位值
    else
        error('axis 参数无效，请使用 "X" 或 "Y"。');
    end

    % 初始化输出结构为原始数据
    croppedShp = shpData;

    % 遍历每个地理要素并按指定轴方向裁剪
    for i = 1:length(shpData)
        % 获取当前地理要素的 X 和 Y 坐标
        xarray = shpData(i).X;
        yarray = shpData(i).Y;

        % 去除 NaN 值，仅保留有效坐标点
        xarray = xarray(~isnan(xarray));
        yarray = yarray(~isnan(yarray));

        % 裁剪：保留中位线左侧（X 轴）或下方（Y 轴）的点
        if strcmpi(axis, 'X')
            % 保留 X 轴中位线左侧的点
            xarray_crop = xarray(xarray <= midValue);
            yarray_crop = yarray(1:length(xarray_crop)); % 对应保留 Y 坐标
        else
            % 保留 Y 轴中位线下方的点
            yarray_crop = yarray(yarray <= midValue);
            xarray_crop = xarray(1:length(yarray_crop)); % 对应保留 X 坐标
        end

        % 若裁剪结果为空，用 NaN 保留形状
        if isempty(xarray_crop) || isempty(yarray_crop)
            croppedShp(i).X = nan;
            croppedShp(i).Y = nan;
        else
            % 裁剪后的形状数据，加入 NaN 表示形状结束
            croppedShp(i).X = [xarray_crop, nan];
            croppedShp(i).Y = [yarray_crop, nan];
        end
    end

    % 清除所有 X 和 Y 坐标为空的地理要素，确保文件写入无效数据
    validFeatures = arrayfun(@(s) ~all(isnan(s.X)) && ~isempty(s.X), croppedShp);
    croppedShp = croppedShp(validFeatures);

    % 设置输出文件路径
    name = fullfile('attacked', 'cropped', ['half_cropped_', outshpfile]);

    % 写入裁剪后的数据到新文件
    shapewrite(croppedShp, name);
    fprintf('一半裁剪攻击完成，文件已保存到 %s\n', name);
end
