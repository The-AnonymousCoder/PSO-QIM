function name = attacks3_vertex_noise(originshpfile, outshpfile,randratio,noisestrength)
    % attacks3_vertex_noise - 实现随机噪声攻击
    % 该函数通过向矢量地图的顶点位置添加噪声，生成新的地图文件。
    %
    % 输入参数：
    %   originshpfile - 原始矢量地图文件名
    %   randratio - 编辑噪声的比例（0到1之间），表示添加噪声的概率
    %
    % 输出参数：
    %   name - 保存新矢量地图文件的完整路径名

    % 设置编辑强度和噪声强度
    % randratio = 0.1;           % 添加噪声的概率
    % noisestrength = 0.6e-6;    % 噪声强度，控制噪声偏移的量级
    % noisestrengthstr = '000';  % 用于文件命名的噪声强度字符串

    % 读取矢量地图文件
    originshpfile = shaperead(originshpfile); % 读取 shapefile 数据
    newshp = originshpfile; % 初始化新矢量地图数据

    % 遍历所有的形状对象，添加噪声
    for i = 1:length(originshpfile)
        % 提取当前形状的 X 和 Y 坐标
        xarray = originshpfile(i).X;
        yarray = originshpfile(i).Y;

        % 移除 NaN 点，仅保留有效的 X 和 Y 坐标
        xarray = xarray(~isnan(xarray));
        yarray = yarray(~isnan(yarray));

        % 遍历每个顶点，根据随机数判断是否添加噪声
        for j = 1:length(xarray)
            rd1 = rand;  % 随机数用于确定是否添加噪声
            rd2 = rand;  % 随机噪声偏移

            % 生成噪声偏移值
            noisex = -noisestrength + (2 * noisestrength) * rd2;
            noisey = -noisestrength + (2 * noisestrength) * rd2;

            % 判断是否在当前顶点添加噪声
            if rd1 < randratio
                xarray(j) = xarray(j) + noisex; % 添加噪声到 X 坐标
                yarray(j) = yarray(j) + noisey; % 添加噪声到 Y 坐标
            end
        end

        % 更新新的矢量地图，加入 NaN 表示断开
        newshp(i).X = [xarray nan];
        newshp(i).Y = [yarray nan];
    end

    % 设置输出文件路径并命名
    name = fullfile('attacked', 'noise', ['noise_',num2str(noisestrength),'_', num2str(randratio), '_', outshpfile]);

    % 保存新的 shapefile
    shapewrite(newshp, name);
end
