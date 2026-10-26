【參數】N(訊號週期)、M(基線週期=2N)依週期取：週線52/104，日線126/252，分鐘線<60分60/120，其餘(小時以上日內等)90/180。
【濾波】SS2(x,P)：a=exp(-π√2/P)，c2=2a·cos(√2π/P)，c3=-a²，c1=1-c2-c3，f=c1·(x+x[1])/2+c2·f[1]+c3·f[2]，前2根f=x。SS3(x,P)：arg=π/P，a=exp(-arg)，b=2a·cos(√3·arg)，c=a²，k2=b+c，k3=-(c+b·c)，k4=c²，k1=1-k2-k3-k4，f=k1·x+k2·f[1]+k3·f[2]+k4·f[3]，前3根f=x，第4根f=最近3根x平均。
【三組多空旗標，皆以close計算】
1) Fast：lp=SS2(close,N)，base=SS2(lp,M)；lp>base為多，否則為空。
2) Core：lp=SS3(close,N)，base=SS2(lp,M)；lp>base為多，否則為空。
3) Adaptive：MAMA/FAMA，FastLimit=0.5，SlowLimit=0.05，前6根mama=fama=close、週期初值15。ms=(4c+3c[1]+2c[2]+c[3])/10；dc=0.075·週期前值+0.54；det=(0.0962·ms+0.5769·ms[2]-0.5769·ms[4]-0.0962·ms[6])·dc；Q1=同樣的4項濾波套在det上再乘dc；I1=det[3]；jI、jQ=同樣4項濾波分別套在I1、Q1上再乘dc；I2=0.2(I1-jQ)+0.8·I2前值；Q2=0.2(Q1+jI)+0.8·Q2前值；Re=0.2(I2·I2前值+Q2·Q2前值)+0.8·Re前值；Im=0.2(I2·Q2前值-Q2·I2前值)+0.8·Im前值；週期p=(Im、Re皆不為0)?2π/atan(Im/Re):前值，p限制在前值的0.67~1.5倍，再限制在6~50，週期=0.2p+0.8·前值；相位=atan(Q1/I1)換算成度(I1=0時用前值)；dphase=max(1,相位前值-相位)；alpha=max(0.05,0.5/dphase)；mama=alpha·close+(1-alpha)·mama前值；fama=0.5·alpha·mama+(1-0.5·alpha)·fama前值。mama>fama為多，否則為空。
【共識數】consensus=三個旗標中為多的個數。
【判斷】
做多：consensus==3(三者全多，最完整的多頭共識)。
做空(看跌方向)：consensus==0(三者全空，無任何多頭共識)。
consensus為1或2時只是分歧/過渡，不指向多或空。
【出場】持多時consensus<3即出場(不再全多)；持空時consensus>0即出場；出現反向判斷(多轉consensus==0、空轉consensus==3)則反手。
【單線版(圖上顏色)】只看Adaptive時：mama>fama視為偏多(綠)，mama<=fama視為偏空(紅)，與上面同一計算。
【方向箭頭】close與63根前close比較，大於為上(▲)，否則為下(▼)，僅作方向標示。