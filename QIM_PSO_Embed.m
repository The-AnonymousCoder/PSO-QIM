function [X_embedded,bestParticleGroup, embeddedCoefficients,gBestFitness] = QIM_PSO_Embed(yarray,LX,HX,HY,Mcof, watermark,watermarkLength, Q,gBestFitnessNum, numGroups, maxIter, w, w_min, c1_initial,c1_min,c2_initial,c2_max)


N = length(yarray);  % 高频系数数量

% 1. 初始化参数  % 初始化粒子群位置和速度 (偏移量) 存储个体最优位置和全局最优位置
%    初始化 HX_mod 为长度为 N 的零数组  在迭代前初始化 ratioLXY_list 和 p_list  % 计算 ratioLXY 和 p
positions = zeros(numGroups, N);  % 偏移量M(i)，初始位置
velocities = zeros(numGroups, N);
pBest = positions;
pBestFitness = -inf * ones(numGroups, 1);
gBest = positions(1, :);
gBestFitness = -inf;
HX_mod = zeros(1, N);
ratioLXY_list = zeros(N, 1);
p_list = zeros(N, 1);
for i = 1:N
    if HY(i) ~= 0  % 只有当 HY(i) 不为 0 时才计算
        ratioLXY_list(i) = (HX(i) / HY(i)) * Mcof;  % 计算 ratioLXY  yarray
        p_list(i) = mod(floor((HX(i) / HY(i)) * 100000), watermarkLength) + 1;
        % p_list(i) = mod(floor(ratioLXY_list(i) * 100000), watermarkLength) + 1;  % 计算 p
    end
end

% 2. 初始化粒子群
for g=1:numGroups
    for i = 1:N-1

        if p_list(i) == 0  % 如果Y坐标的高频系数为0，则跳过该点
            continue;
        end

        offset = mod(ratioLXY_list(i), Q/2);
        increaseOffset = rand * (Q/2);
        decreaseOffset= -(rand * (Q/2));

        if watermark(p_list(i)) == 0
            % 如果在正确的上半部分
            if mod(ratioLXY_list(i), Q) < Q/2
                positions(g, i) = - offset + increaseOffset;
            else
                % 随机选择正偏移或负偏移
                if rand > 0.5
                    offset = Q/2 - offset;
                    positions(g, i) =  offset + increaseOffset;
                else
                    positions(g, i) =  -offset + decreaseOffset;
                end
            end
        else
            % 如果在正确的下半部分
            if mod(ratioLXY_list(i), Q) >= Q/2
                positions(g, i) = - offset + increaseOffset;
            else
                % 随机选择正偏移或负偏移
                if rand > 0.5
                    offset = Q/2 - offset;
                    positions(g, i) =  offset + increaseOffset;
                else
                    positions(g, i) =  -offset + decreaseOffset;
                end
            end
        end
    end
end

% 3. 进行PSO迭代优化  大迭代 每次迭代对所有粒子组求最优解
for iter = 1:maxIter

    % 3.1 动态调整c1和c2，使得初期c1较大，c2较小；后期c1较小，c2较大  动态调整惯性权重
    c1 = c1_initial * (1 - iter / maxIter) + c1_min * (iter / maxIter);
    c2 = c2_initial * (1 - iter / maxIter) + c2_max * (iter / maxIter);
    w = w - (0.5 / maxIter);  % 在每次迭代后减少
    w = max(w, w_min);  % 不小于最小值

    % 定期引入遗传算法操作，例如每3次PSO迭代后应用GA操作
    if iter>90 && mod(iter, 3) == 0
        disp('GA操作开始');
        % 1. 选择操作：选择适应度高的前一半粒子
        [sortedFitness, sortIndex] = sort(pBestFitness, 'descend');
        numSelected = floor(numGroups / 2);
        selectedPositions = positions(sortIndex(1:numSelected), :);

        % 2. 交叉操作：对选择的粒子进行交叉，生成新的粒子
        for k = numSelected+1:numGroups
            parent1 = selectedPositions(randi(numSelected), :);
            parent2 = selectedPositions(randi(numSelected), :);
            crossoverPoint = randi([1, N]);  % 随机交叉点
            positions(sortIndex(k), :) = [parent1(1:crossoverPoint), parent2(crossoverPoint+1:end)];
            % disp('生成的新粒子位置:');
            % disp(positions(sortIndex(k), :));  % 打印生成的新粒子位置
        end

        % 3. 变异操作：对部分粒子进行随机变异
        if iter > 100
            mutationRate = 0.3;
            for g = 1:numGroups
                if rand < mutationRate
                    mutationIndex = randi([1, N]);

                    if p_list(mutationIndex) == 0  % 如果Y坐标的高频系数为0，则跳过该点
                        continue;
                    end

                    offset = mod(ratioLXY_list(mutationIndex), Q/2);
                    increaseOffset = rand * (Q/2);
                    decreaseOffset= -(rand * (Q/2));

                    if watermark(p_list(mutationIndex)) == 0
                        % 如果在正确的上半部分
                        if mod(ratioLXY_list(mutationIndex), Q) < Q/2
                            positions(g, mutationIndex) = - offset + increaseOffset;
                        else
                            % 随机选择正偏移或负偏移
                            if rand > 0.5
                                offset = Q/2 - offset;
                                positions(g, mutationIndex) =  offset + increaseOffset;
                            else
                                positions(g, mutationIndex) =  -offset + decreaseOffset;
                            end
                        end
                    else
                        % 如果在正确的下半部分
                        if mod(ratioLXY_list(mutationIndex), Q) >= Q/2
                            positions(g, mutationIndex) = - offset + increaseOffset;
                        else
                            % 随机选择正偏移或负偏移
                            if rand > 0.5
                                offset = Q/2 - offset;
                                positions(g, mutationIndex) =  offset + increaseOffset;
                            else
                                positions(g, mutationIndex) =  -offset + decreaseOffset;
                            end
                        end
                    end

                    % positions(g, mutationIndex) = positions(g, mutationIndex) + (randn * Q/2);  % 添加随机噪声
                end
            end
        end
        disp('GA操作结束');
    end

    % 3.2 对每组粒子进行迭代   小迭代，第iter次迭代中所有粒子组的迭代
    for g = 1:numGroups

        % 每组粒子的阴性计数  初始化 高频系数modifiedCoefficients
        negative_count = 0;
        fitness = 0;
        modifiedCoefficients = ratioLXY_list;
        HX_mod = zeros(1, N);
        X_embedded = 0;

        % 水印嵌入后的高频系数
        for i = 1:N
            if HY(i) == 0  % 如果Y坐标的高频系数为0，则跳过该点
                HX_mod(i) = HX(i) * Mcof;  % 将该点的X坐标高频系数乘以Mcof，不做水印修改
                continue;
            end
            modifiedCoefficients(i) = modifiedCoefficients(i) + positions(g, i);
            HX_mod(i)=modifiedCoefficients(i)*HY(i);
        end

        % 计算当前组粒子的阴性概率(适应度)
        HX_mod =  HX_mod/Mcof;              % 将X坐标高频系数除以Mcof，恢复比例
        % 该变换会去除H_WVV，去除加水印后的虚拟点
        X_embedded = isdwt(LX,HX_mod);      % 通过逆离散小波变换（IDWT）得到修改后的X坐标
        [LX_CVV,HX_CVV] = sdwt(X_embedded);         % 对X坐标进行离散小波变换
        for i=1:N-1
            H_WVV=modifiedCoefficients(i);
            H_CVV= (HX_CVV(i) / HY(i)) * Mcof;

            label_H_WVV = (mod(H_WVV, Q) >= Q / 2);
            label_H_CVV = (mod(H_CVV, Q) >= Q / 2);
            % 判断两个量化结果是否在同一标签区间
            if label_H_WVV == label_H_CVV
                negative_count = negative_count + 1;
            end
        end
        fitness = negative_count / N;  % 适应度：阴性概率


        % 更新个体最优位置
        if fitness > pBestFitness(g)
            pBest(g, :) = positions(g, :);
            pBestFitness(g) = fitness;  % 更新个体最优适应度
        end
        % 更新全局最优位置
        if fitness > gBestFitness
            gBestFitness = fitness;
            gBest = positions(g, :);
            gBestFitnessNum=gBestFitnessNum+1;
            % fprintf('   ！！！全局最优位置已第%d次更新 为第%d次迭代，第%d组粒子 : 适应度 = %.4f\n',gBestFitnessNum,iter,g, gBestFitness);
        end
        % 重置最优适应度
        fitness = 0;
        % fprintf('   迭代:第%d次，粒子组:第%d组 当前适应度 = %.4f 最优适应度 = %.4f\n', iter,g ,pBestFitness(g),gBestFitness);
    end
    % 3.3 更新速度和位置
    for g = 1:numGroups
        r1 = rand(1, N);
        r2 = rand(1, N);
        % 遍历每个位置，判断是否需要更新
        for i = 1:N
            if positions(g, i) ~= 0  % 只有当位置不为0时才进行更新
                % 更新速度
                velocities(g, i) = w * velocities(g, i) ...
                    + c1 * r1(i) * (pBest(g, i) - positions(g, i)) ...
                    + c2 * r2(i) * (gBest(i) - positions(g, i));

                % 更新位置
                sameInterval=(mod(ratioLXY_list(i)+positions(g, i)+velocities(g, i), Q)>Q/2) == watermark(p_list(i));
                % velocities(g, i) > Q/2 ||
                if ~sameInterval
                    offset = mod(ratioLXY_list(i), Q/2);
                    increaseOffset = rand * (Q/2);
                    decreaseOffset= -(rand * (Q/2));
                    if watermark(p_list(i)) == 0    
                        % 如果在正确的上半部分
                        if mod(ratioLXY_list(i), Q) < Q/2
                            positions(g, i) = - offset + increaseOffset;
                        else
                            % 随机选择正偏移或负偏移
                            if rand > 0.5
                                positions(g, i) =  Q/2 - offset + increaseOffset;
                            else
                                positions(g, i) =  -offset + decreaseOffset;
                            end
                        end
                    else
                        % 如果在正确的下半部分
                        if mod(ratioLXY_list(i), Q) >= Q/2
                            positions(g, i) = - offset + increaseOffset;
                        else
                            % 随机选择正偏移或负偏移
                            if rand > 0.5
                                positions(g, i) =  Q/2 - offset + increaseOffset;
                            else
                                positions(g, i) =  -offset + decreaseOffset;
                            end
                        end
                    end
                else
                    positions(g, i) = positions(g, i) + velocities(g, i);
                end
            end
        end
    end

    % 4. 显示当前迭代的最优适应度  输出最佳粒子群（偏移量）
    bestParticleGroup = gBest;
    fprintf('迭代 %d: 最优适应度 = %.4f  全局最优位置已第%d次更新\n', iter, gBestFitness,gBestFitnessNum);


    % 5. 更新水印嵌入后的高频系数列表
    embeddedCoefficients = ratioLXY_list;
    for i = 1:N
        if HY(i) == 0  % 如果Y坐标的高频系数为0，则跳过该点
            HX_mod(i) = HX(i) * Mcof;  % 将该点的X坐标高频系数乘以Mcof，不做水印修改
            continue;
        end
        embeddedCoefficients(i) = ratioLXY_list(i) + bestParticleGroup(i);
        % 根据最佳偏移量进行水印嵌入
        if watermark(p_list(i)) == 0
            if mod(embeddedCoefficients(i), Q) >= Q/2
                offset = Q/2 - mod(embeddedCoefficients(i), Q);  % 将其移动到 [0, Q/2) 的区域
                embeddedCoefficients(i) = embeddedCoefficients(i) + offset + Q/4;
                positions(g, i) = positions(g, i) + offset + Q/4;
            end
        else
            % 使用 mod 判断是否进入正确的量化区间
            if mod(embeddedCoefficients(i), Q) < Q/2
                offset = Q/2 - mod(embeddedCoefficients(i), Q);
                embeddedCoefficients(i) = embeddedCoefficients(i) + offset + Q/4;
                positions(g, i) = positions(g, i) + offset + Q/4;
            end
        end

        % 更新X坐标高频系数
        HX_mod(i) = embeddedCoefficients(i) * HY(i);
    end

    % 通过逆离散小波变换（IDWT）得到修改后的X坐标
    HX_mod = HX_mod / Mcof;  % 恢复比例
    X_embedded = isdwt(LX, HX_mod);  % 使用IDWT恢复X坐标
end
