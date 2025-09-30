function [EEG] = biopac_sound2event(EEG,soundchan,parflag)

soundEEG = pop_select(EEG,'channel',soundchan);


sounddat = eeglab2fieldtrip_swt(soundEEG,'preprocessing','none');

cfg = []; cfg.output = 'pow'; cfg.channel = 'all'; cfg.method = 'mtmconvol';
cfg.foi = 60:20:900; cfg.t_ftimwin = repmat(0.1,1,length(cfg.foi));
cfg.toi = sounddat.time{1}(1:4:end); % all times, but downsampled by 4 to save memory since we're going to be downsampling to 500Hz anyways
cfg.taper = 'hanning'; cfg.keeptrial = 'yes';
freq = ft_freqanalysis(cfg,sounddat);

anyfreq = sum(squeeze(freq.powspctrm),1);

[evpeaks,eventsindx] = findpeaks(anyfreq.*(anyfreq>2));

eventsindx(zscore(evpeaks)>10) = [];

%eventsindx(evpeaks>150) = [];

sounddat = ft_resampledata(struct('resamplefs',500),sounddat);
freq = ft_struct2single(freq); sounddat = ft_struct2single(sounddat);



EEG = pop_resample(EEG,500);

events = struct;
parfor i = 1:length(eventsindx)
    % we find the peak of the sound with this, but subtract 50 ms because
    % the onset will be 50 ms before this
     events(i).latency = FindClosest(sounddat.time{1},freq.time(eventsindx(i))-0.05,1);
     [~,tmp] = max(squeeze(freq.powspctrm(1,:,eventsindx(i))));
     events(i).type = round(freq.freq(tmp));
     events(i).urevent = i;
end

EEG.event = events;
