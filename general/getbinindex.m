function out = getbinindex(times, binPeriods)
% out = getbinindex(times, binPeriods)
% Returns a list of indexes into binPeriods rows signifying which bin each
% row of times falls between
% end of one binperiod should not equal start of next bin period

if any(binPeriods(1:end-1,2)-binPeriods(2:end,1)==0)
    error('end of one binperiod should not equal start of next bin period')
end

%changed to lookup2 SP 2.8.18
c1=lookup2(times,binPeriods(:,1), -1); %find start of bin just before each time
c2=lookup2(times,binPeriods(:,2), 1); %find end of bin after each time
c1( (c1-c2)~=0 ) = 0; %exclude times that do not have same start and end bin
c1(logical(~isExcluded(times, binPeriods))) = 0;
out = c1;
