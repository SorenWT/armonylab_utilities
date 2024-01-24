function cform = consentform_decode(cform)

cform.raw = cform;

cform.age = str2num(cform.age);

switch cform.sex
    case {'item1','female','woman','F','f','Female','girl','Girl'}
        cform.sex = 'F';
    case {'item2','male','man','M','m','Male','Boy','boy'}
        cform.sex = 'M';
    otherwise
        if any(contains(cform.sex,{'Female','Woman'},'IgnoreCase',true))
            cform.sex = 'F';
        elseif any(contains(cform.sex,{'Male','Man'},'IgnoreCase',true))
            cform.sex = 'M';
        else
            cform.sex = 'O';
        end
end

switch cform.gender
    case 'item1'
        cform.gender = 'F';
    case 'item2'
        cform.gender = 'M';
    otherwise
        cform.gender = 'O';
end

if ischar(cform.handedness)
    switch cform.handedness
        case 'item1'
            cform.handedness = 'R';
        case 'item2'
            cform.handedness = 'L';
        case 'item3'
            cform.handedness = 'A';
    end
    
else
    cform.handscore = NaN(1,4);
    for i = 1:length(fieldnames(cform.handedness))
        try
            cform.handscore(i) = str2num(extractAfter(cform.handedness.(['Row' num2str(i)]),'Column '));
        catch
        end
    end
    
    cform.handval = nanmean(cform.handscore(1:2));
    if cform.handval > 7/2
        cform.handedness = 'R';
    elseif cform.handval < 5/2
        cform.handedness = 'L';
    else
        cform.handedness = 'A';
    end
    
    cform.footval = nanmean(cform.handscore(3:4));
    if cform.footval > 7/2
        cform.footedness = 'R';
    elseif cform.footval < 5/2
        cform.footedness = 'L';
    else
        cform.footedness = 'A';
    end
end

if isfield(cform,'personality_bfi_10')
    for i = 1:10
        try
            cform.bfivals(i) = str2num(extractAfter(cform.personality_bfi_10.(['Row' num2str(i)]),'Column '));
        catch
            cform.bfivals(i) = NaN;
        end
    end
    
    cform.fivefactor.O = (6-cform.bfivals(5))+ cform.bfivals(10);
    cform.fivefactor.C = (6-cform.bfivals(3))+ cform.bfivals(8);
    cform.fivefactor.E = (6-cform.bfivals(1))+ cform.bfivals(6);
    cform.fivefactor.A = (6-cform.bfivals(7))+ cform.bfivals(2);
    cform.fivefactor.N = (6-cform.bfivals(4))+ cform.bfivals(9);
end

if isfield(cform,'panas')
    for i = 1:20
        try
            cform.panasvals(i) = str2num(extractAfter(cform.panas.(['Row' num2str(i)]),'Column '));
        catch
            cform.panasvals(i) = NaN;
        end
    end
    cform.panasscr.statep = nanmean(cform.panasvals([1 3 5 9 10 13 14 16 17 19])).*10;
    cform.panasscr.staten = nanmean(cform.panasvals([2 4 6 7 8 11 13 15 18 20])).*10;
end

end