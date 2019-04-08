syms t
f=(@(t)(10*cos(2*pi*1e5.*t+5*sin(3e3*pi.*t)+10*sin(2e3*pi.*t))).^2);
quadgk(f,0,1,'RelTol',1e-10,'AbsTol',1e-6,'MaxIntervalCount',60000000000000000)