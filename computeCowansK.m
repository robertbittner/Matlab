function cowansK = computeCowansK(wmLoad, accuracyNoChange, accuracyChange);;
%%% This function calculates Cowan's K, i.e. the number of items stored in
%%% working memory. 
%%% Formula for Cowan's K (Cowan, Behavioral and Brain Sciences, 2001;
%%% Cowan et al., Cognitive Psychology, 2005)
%%% 
%%% k = N * (H + CR -1)
%%% N = number of items presented in array
%%% H = hit rate (correctly identifying an identical array = accuracy NoChange condition)
%%% CR = correct rejections (correctly identifying a change in an array = accuracy change condition)

N = wmLoad;
H = accuracyNoChange;
CR = accuracyChange;
cowansK = N * (H + CR - 1);