function [ childTags ] = getChildTags( handle, tagSearch )
%INPUTS:
%   handle: the handle of the object you want to get the
%   tagSearch:  a cell array of the tags to search for
%
%OUTPUTS:
%   idx: the indices of the tag search

        child= handle.Children;
        tags=cell(size(child));
        for j = 1:size(child,1)
            tags{j}= child(j).Tag;
        end

        idx=zeros(length(tagSearch),1);
        
        for i = 1:length(tagSearch)       
            strTest=strfind(tags,tagSearch{i});
            idx(i)=find(~cellfun(@isempty,strTest));
        end

        childTags=struct();
        childTags.idx=idx;
        childTags.hand= child(idx);
end

