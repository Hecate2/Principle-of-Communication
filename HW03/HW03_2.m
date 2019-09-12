clear

sizeRnd=1000;
tries=10000;
avg=zeros(tries,1);
for i=1:tries
    rnd=rand(1,sizeRnd);
    avg(i,1)=sum(rnd)/sizeRnd;
end
histogram(avg);
