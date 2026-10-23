【共用定義】回看期 N=23。波動 σ 用 500 根 Yang-Zhang：對每根算 ro=ln(open/前收)、rc=ln(close/open)、rs=ln(high/open)·ln(high/close)+ln(low/open)·ln(low/close)；σ=sqrt(var500(ro)+k·var500(rc)+(1-k)·sma500(rs))，k=0.34/(1.34+501/499)。
錨點：沒有進行中的結構且資料已足夠（至少 500 根）時，HH=前 N 根（不含當根）的最高 high，LL=前 N 根最低 low，錨點 bar=當前 bar-N+1，結構開始。結構進行中每根：dx=(當前bar-錨點bar)/N；θC=atan((ln(high)-ln(HH))/σ/dx)·180/π；θF=atan((ln(low)-ln(LL))/σ/dx)·180/π。

【突破方向：做多／做空】結構進行中，收盤 close>HH 判為向上突破（做多方向，綠框）；close<LL 判為向下突破（做空方向，紅框）。突破當根記錄 (θC,θF,方向) 並結束結構，下一根重新凍結新的 HH/LL。

【機率模型多空呼叫】用已記錄的歷史突破（最多 500 筆）預測進行中結構往哪個方向突破。每根收盤、結構進行中：
1. 對歷史突破的 θC 與 θF 各算樣本標準差 s，頻寬 h=max(s·n^(-1/6),1e-6)，n 為歷史筆數（至少 2 筆）。
2. 每筆歷史權重 w=exp(-0.5(((θC-θCi)/hC)²+((θF-θFi)/hF)²))。wUp=向上突破者權重和，wDn=向下突破者權重和，S=wUp+wDn，neff=S²/Σw²。
3. a=1+wUp/S·neff，b=1+wDn/S·neff，p=100·a/(a+b)。顯著條件：|a/(a+b)-0.5|≥1.645·sqrt(ab/((a+b)²(a+b+1)))。
4. 抖動 j=最近 3 根 p 值（含當根）的母體標準差。
5. 校準：bin=min(int((max(p,100-p)-50)/5),9)；每個 bin 有衰減計數 hitW、totW。每根顯著且已有 3 筆 p 的收盤 bar，記錄(格子=bin*2+(j<1.5?0:1)，p>50 為押上)；結構突破時，對每筆記錄：hit=(押上==實際向上突破)?1:0，hitW=hitW·0.999+hit，totW=totW·0.999+1。
6. 做多：j<1.5、顯著、totW[bin*2]≥30，r=hitW/totW，且|r-0.5|≥1.645·sqrt(r(1-r)/totW)（r(1-r)下限 1e-9），同時 p>50。做空：同上條件但 p<50。條件不全者不給方向，p=50 也不給方向。

【出場】READ 沒有以進場價或持倉方向定義的出場判斷。