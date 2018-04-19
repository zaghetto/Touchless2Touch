function PATHCYG = currPathNBIS(PATHNAME)

str = pwd;
idx = strfind(str,'\');
PATHCYG = str(idx(end)+1:end);
idx = strfind(PATHNAME,PATHCYG);

PATHCROP = PATHNAME(idx:end);

iCYG = find(PATHCROP == '\');
PATHCYG = PATHCROP;
PATHCYG(iCYG) = '/';
PATHCYG = ['/' PATHCYG];

end