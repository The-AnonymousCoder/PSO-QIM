function [points, indices] = Douglas(points, epsilon)
    % Douglas-Peucker Algorithm for polyline simplification
    %
    % 输入:
    %   points - 一个 N x 2 的矩阵，每行包含一个 [X, Y] 坐标
    %   epsilon - 简化阈值，控制简化的程度
    %
    % 输出:
    %   points - 简化后的点数组
    %   indices - 原始点的索引，表示保留哪些点

    % 找到最大距离点
    dmax = 0;
    index = 0;
    for i = 2:size(points, 1)-1
        d = perpendicularDistance(points(i, :), points(1, :), points(end, :));
        if d > dmax
            index = i;
            dmax = d;
        end
    end

    % 如果最大距离大于阈值，则递归分割
    if dmax > epsilon
        % 递归调用处理左侧和右侧
        [recResults1, recIndices1] = Douglas(points(1:index, :), epsilon);
        [recResults2, recIndices2] = Douglas(points(index:end, :), epsilon);

        % 组合结果
        points = [recResults1; recResults2(2:end, :)];
        indices = [recIndices1; recIndices2(2:end) + index - 1];
    else
        % 否则仅保留端点
        points = [points(1, :); points(end, :)];
        indices = [1; size(points, 1)];
    end
end

function d = perpendicularDistance(point, lineStart, lineEnd)
    % 计算点到线的垂直距离
    if isequal(lineStart, lineEnd)
        d = norm(point - lineStart);
        return;
    end

    % 投影距离计算
    lineVec = lineEnd - lineStart;
    pointVec = point - lineStart;
    lineLen = norm(lineVec);
    proj = dot(pointVec, lineVec) / lineLen;
    if proj <= 0
        d = norm(pointVec);
    elseif proj >= lineLen
        d = norm(point - lineEnd);
    else
        d = norm(pointVec - proj * lineVec / lineLen);
    end
end
