% Help with ChatGPT
function absTransforms = RecalcAbsT(relTransforms, hierarchy)
    numBones = length(relTransforms);
    absTransforms = cell(numBones,1);
    for i = 1:numBones
        T_abs = eye(4);
        current = i;
        while true
            T_abs = relTransforms{current} * T_abs;
            if isempty(hierarchy(current).parent)
                break;
            end
            current = hierarchy(current).parent;
        end
        absTransforms{i} = T_abs;
    end
end
