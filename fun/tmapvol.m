% Compute T maps against baseline for an epi volume and a design volume
% tvol = tmapvol(designvol,epivol,[inds])
%
% inds are indices into uniquelabels (defaults to 1:nlabels)
function tvol = tmapvol(designvol,epivol,inds)

if nargin<3
    inds = 1:designvol.nlabels;
end
nt = length(inds);

% fit
betas = designvol.data' \ epivol.data;

% get variance estimate for t contrast
rss = sum((epivol.data - designvol.data'*betas).^2);
df = epivol.ndata - rank(designvol.data');
mrss = rss / df;
% model covariance matrix
covmat = inv(designvol.data * designvol.data');

% prepare output matrix
tdata = NaN([nt epivol.nfeatures]);
% concessions to parfor to avoid memory overhead (actually, further testing
% suggests you get better performance without parfor here, so disabled for
% now)
colinds = 1:epivol.nfeatures;
labelinds = designvol.labelinds;
% iterate to make t maps
for t = 1:nt
    % make the vector for this label
    cv = (labelinds==inds(t))';
    % mean over standard error
    tdata(t,colinds) = cv * betas ./ sqrt(mrss * (cv * covmat * cv'));
end

% make the Volume instance
tvol = Volume(tdata,epivol,'labels',designvol.uniquelabels(inds));
