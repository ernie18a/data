【符號】r=ln(close/close[1])；tanh 為雙曲正切；sig(x)=1/(1+e^-x)；N(x)=sig((x-EMA(x,256))/max(stdev(x,256),1e-10))，輸出 0~1；P(x,p)=x 在最近 500 根的第 p 百分位（線性內插）。

【特徵】
1. Kalman：首根 kx=close、kp=1。之後 xpred=kx[1]，ppred=kp[1]+1e-4，inn=close-xpred，g=ppred/(ppred+1e-2)，kx=xpred+g*inn，kp=(1-g)*ppred。kalmanLock=1-N(|inn/close|)。
2. Markov：s=(stdev(r,100)>P(stdev(r,100),50，窗口 500))?1:0，markov=SMA(|s-s[1]|,50)。
3. 小波：we3=(ln close-2*ln close[4]+ln close[8])^2，wavelet=N(we3)。
4. Hawkes：std50=stdev(r,50)，jump=|r|>1.5*std50 ? |r|/max(std50,1e-6) : 0，h=0.9*h[1]+0.01+jump[1]（h 初值 0.1），hawkes=N(h)。
5. 頻譜：a=|SMA(r,8)-SMA(r,16)|，b=|SMA(r,16)-SMA(r,32)|，c=|SMA(r,32)-SMA(r,64)|，spectral=N(max(a,b,c)/max(stdev(r,128),1e-9))。
6. DFA：cd=cum(r-SMA(r,64))，res=cd-linreg(cd,64,0)，dfaLong=N(stdev(res,64)/max(stdev(r,64),1e-9))。
7. subMass=N(|r|*(1+0.5*we3))；subSpin=tanh(sign(r)*min(h,5)*0.35)；subCharge=tanh(0.25*skew)，skew=SMA((r-SMA(r,50))^3,50)/stdev(r,50)^3（分母<=1e-9 時為 0）；subLife=N(1/max(stdev(r,20),1e-6))。

【模型分量】
vb=max(stdev(r,64),1e-9)。
dfaM=tanh(4*EMA(r,21)/vb)*dfaLong。
kalM=tanh(2*(kx-kx[3])/max(close*vb,1e-9))*kalmanLock*spectral。
waveM=tanh((ln close-ln close[4])/vb*0.125)*wavelet*spectral*(1-0.35*hawkes)。
rsiM=tanh((RSI(close,14)-50)/18)*(0.35+0.65*spectral)。
spinM=subSpin*subMass*(0.5+0.5*subLife)。
chargeM=subCharge*(1-hawkes)*(0.5+0.5*spectral)。
shock=clamp01(0.55*hawkes+0.35*markov+0.10*(1-subLife))。
ens=0.38*spinM+0.26*dfaM+0.18*waveM+0.12*kalM+0.04*chargeM+0.02*rsiM。
conf=clamp01(0.30*kalmanLock+0.24*spectral+0.22*dfaLong+0.14*subMass+0.10*subLife-0.25*shock)。
qtSig=tanh(2.2*ens)*(0.35+0.65*conf)。
thr=clamp(max(0.18,P(|qtSig|,78，窗口 256)),0.03,0.65)。
coord=clamp01(|spinM+dfaM+waveM+kalM|/(|spinM|+|dfaM|+|waveM|+|kalM|))，disp=1-coord。
Q=0.35*coord+0.25*spectral+0.20*dfaLong+0.20*subLife。
stack=tanh(0.65*(spinM+dfaM+waveM+kalM))。
令 d=qtSig>=0?1:-1，帶 Dir 後綴者為該量*d（qtD、kalD、dfaD、spinD、chargeD、waveD）。

【過濾，做多與做空都要同時成立】
- 已過 500 根暖機。
- 狀態：conf>=0.46、shock<=0.74、disp<=0.66、coord>=0.36。
- 12 條件至少一條成立（p 為 P 的百分位）：
 1. kalM>P80 且 dfaM>P70 且 Q>P70
 2. dfaM>P80 且 spinM>P75 且 subMass>P60
 3. kalM>P75 且 kalmanLock<P5 且 spinD>P25
 4. qtD>P50 且 kalmanLock<P20 且 Q>P70
 5. kalD>P40 且 dfaLong>P80 且 spinM>P80
 6. dfaD>P75 且 kalmanLock<P20 且 spinM>P25
 7. kalD>P30 且 dfaLong>P80 且 spinD>P80
 8. qtD>P60 且 spectral>P70 且 shock<P50
 9. Q>P75 且 coord>P60 且 disp<P40 且 subLife>P60
 10. waveD>P60 且 wavelet>P60 且 hawkes<P50 且 kalD>P60
 11. chargeD>P60 且 dfaLong>P70 且 conf>P70 且 shock<P40
 12. dfaD>P70 且 spinD>P70 且 wavelet>P70 且 spectral>P70
 各量皆取自身最近 500 根的百分位。

【做多】過濾通過，且 qtSig 由下往上穿越 thr；或 qtSig>thr 且 stack 由下往上穿越 0。
【做空】過濾通過，且 qtSig 由上往下穿越 -thr；或 qtSig<-thr 且 stack 由上往下穿越 0。
【出場／重置】已過 500 根暖機，且 qtSig 向上或向下穿越 0，就平掉目前持倉（多空皆是）。