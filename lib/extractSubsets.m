function subsets = extractSubsets(A)  
    % 提取前两列作为唯一性检查的关键
    firstTwoCols = A(:, 1:2);
    
    % 使用unique函数查找唯一行和索引
    [uniqueRows, ~, idx] = unique(firstTwoCols, 'rows', 'stable');
    
    % 统计每个唯一行的出现次数
    counts = accumarray(idx, 1);
    
    % 找到重复的行索引
    repeatedIdx = find(counts > 1);
    
    % 提前分配 cell 数组存储子集
    subsets = cell(length(repeatedIdx), 1);
    
    % 遍历重复的索引，提取子集
    for i = 1:length(repeatedIdx)
        % 提取匹配重复键的所有行
        subset = A(idx == repeatedIdx(i), :);
        subsets{i} = subset;
    end
end
