【通用定義】hl2=(high+low)/2；ohlc4=(open+high+low+close)/4；RMA=Wilder 平滑；ATR(n)=TR 的 RMA(n)，TR 取 max(high-low,|high-前close|,|low-前close|)。

【指標】
1. MLMA 通道（多、空各算一組）。多：src=low，W=16，F=3，sigma=0.43，mult=0.6，MA=SMA，趨勢源=close。空：src=high，W=16，F=3，sigma=0.44，mult=0.5，MA=EMA，趨勢源=low。
- 核函數 k(i,j)=exp(-(i-j)^2/(2W^2))*(1+0.5*exp(-|i-j|/(0.5W)))。
- Ktrain 為 i,j∈0..W-1 的 k 矩陣加 sigma^2*I，取其偽逆。Kstar 為 i∈0..W-1、j∈0..W+F-1 的 k 矩陣。
- K_row=(Kstar^T · pinv(Ktrain)) 的第 W+F-1 列，長度 W。
- mean=MA(src,W)。dot=Σ_{i=0..W-1} K_row[i]*(src[W-1-i]-mean)*(1+0.5*(W-1-i)/W)。
- out=dot+mean+0.2*(src[1]-out[1])，out[1] 不存在時修正項為 0。
- volw=clamp(ATR14/MA(ATR14,50),0.5,1.5)，MA 用該方向的 MA 類型。
- mae=MA(|src-out|,W)*mult*volw。upper=out+mae，lower=out-mae。
- trend 為狀態變數，初值 0。趨勢源>upper 且 out>out[1] 時設 1；趨勢源<lower 且 out<out[1] 時設 0；否則維持前值。
- 多方用多組的 upper 與 trend，空方用空組的 lower 與 trend。
2. Pivot SuperTrend：src=hl2，period=25，factor=2.2，ATR 週期 41。
- ph=pivothigh(hl2,25,25)，pl=pivotlow(hl2,25,25)。出現 ph 或 pl 時（ph 優先）取為 pp；第一次 center=pp，之後 center=(2*center+pp)/3。
- up=center-2.2*ATR41，dn=center+2.2*ATR41。
- TUp=若 close[1]>TUp[1] 則 max(up,TUp[1])，否則 up。TDown=若 close[1]<TDown[1] 則 min(dn,TDown[1])，否則 dn。
- pt=若 close>TDown[1] 則 1；否則若 close<TUp[1] 則 -1；否則沿用前值（初值 1）。
3. W=WMA(ohlc4,15)。
4. DMI(len,sm)：upMove=high-high[1]，dnMove=low[1]-low。+DM=upMove>dnMove 且 upMove>0 時取 upMove，否則 0。-DM=dnMove>upMove 且 dnMove>0 時取 dnMove，否則 0。DI±=100*RMA(±DM,len)/RMA(TR,len)。ADX=100*RMA(|DI+-DI-|/(DI++DI-，為 0 時取 1),sm)。進場用 DMI(28,34)，出場用 DMI(60,60) 的 DI±。
5. RSI(ohlc4,15)。
6. 量比=HMA(volume,18)/HMA(volume,5)。
7. KEMAD：先做 Kalman。狀態與協方差各 6 組（6 組演算結果相同，用 1 組即可），初值為首根 close 與 1.0。每根 P=cov+0.35，kg=P/(P+24)，state+=kg*(close-state)，cov=(1-kg)*P，filtered=state。ema=EMA(filtered,14)。upperK=ema+2*ATR8，lowerK=ema-2.7*ATR8。ks 初值 0：close>upperK 設 1；close<lowerK 設 -1；否則維持前值。
8. OBV=累加 sign(ohlc4-ohlc4[1])*volume。OBVma=HMA(OBV,22)。

【做多】同時成立：
- hl2 上穿多組 upper（前一根 hl2<=upper，這根 hl2>upper）。
- 多組 trend==1。
- pt==1。
- hl2>W。
- 過濾條件：DMI(28,34) 的 DI+>DI- 且 ADX>19；RSI<71；量比>0.4；ks==1。
- 目前沒有多單（持倉<=0）。

【做空】同時成立：
- hl2 下穿空組 lower（前一根 hl2>=lower，這根 hl2<lower）。
- 空組 trend==0。
- pt==-1。
- hl2<W。
- 過濾條件：DI->DI+ 且 ADX>19；RSI>23；量比>0.4；ks==-1。
- 目前沒有空單（持倉>=0）。

反向訊號出現時，先平掉反向單再進場。

【出場】
- 多單出場，任一成立即出：
  - OBV 下穿 OBVma，且 DMI(60,60) 的 DI+<DI-。
  - pt 由 1 變 -1。
  - 價格<=進場價*(1-1.5%)。
  - 價格>=進場價*(1+1.5%*1.9)。
  - 獲利達 1.4% 後啟動追蹤停損，停損價=持倉期間最高價-max(close-多組 lower,0)。
- 空單出場，任一成立即出：
  - OBV 上穿 OBVma，且 DMI(60,60) 的 DI+>DI-。
  - pt 由 -1 變 1。
  - 價格>=進場價*(1+1.5%)。
  - 價格<=進場價*(1-1.5%*1.9)。
  - 獲利達 1.4% 後啟動追蹤停損，停損價=持倉期間最低價+max(空組 upper-close,0)。

【預設關閉的選用過濾】
- 布林：多單要求 close<SMA(close,20)+2*stdev，空單要求 close>SMA(close,20)-2*stdev。
- 波動：ATR8/SMA(ATR8,8)<1.3，多空皆適用。