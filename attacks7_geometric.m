function name = attacks7_geometric(shpFile, outshpfile, angle, scaleFactor, xShift, yShift)
    % attacks7_geometric - 对矢量图进行组合几何攻击（旋转、缩放、平移）
    %
    % 输入参数：
    %   shpFile      - 输入的 .shp 文件路径
    %   outshpfile   - 输出的 .shp 文件名
    %   angle        - 旋转角度（单位：度）
    %   scaleFactor  - 缩放比例（>1 放大，<1 缩小）
    %   xShift       - X 方向平移距离
    %   yShift       - Y 方向平移距离
    %
    % 输出参数：
    %   name - 保存经过变换后的新矢量地图文件的完整路径名

    try
        shpData = shaperead(shpFile);
    catch
        error('无法读取文件，请检查文件路径。');
    end

    theta = deg2rad(angle);
    newshp = shpData;

    for i = 1:length(shpData)
        % 直接使用原始坐标（保留NaN）
        x_original = shpData(i).X;
        y_original = shpData(i).Y;

        % 旋转变换（修正公式）
        x_rot = x_original * cos(theta) - y_original * sin(theta);
        y_rot = x_original * sin(theta) + y_original * cos(theta);

        % 缩放变换
        x_scaled = x_rot * scaleFactor;
        y_scaled = y_rot * scaleFactor;

        % 平移变换
        x_trans = x_scaled + xShift;
        y_trans = y_scaled + yShift;

        % 保留原始NaN结构
        newshp(i).X = x_trans;
        newshp(i).Y = y_trans;
    end

    % 构建输出路径并创建目录
    name = fullfile('attacked', 'geometric_combined', ...
                   [num2str(angle), '_', num2str(scaleFactor), '_', ...
                    num2str(xShift), '_', num2str(yShift), '_', outshpfile]);
    outputDir = fileparts(name);
    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    % 写入文件
    shapewrite(newshp, name);
    fprintf('组合几何攻击完成，文件已保存到 %s\n', name);
end