【共用指標：自適應波動停損(vstop)，輸入價=close，對 K 線序列計算】
參數：快=8、慢=30、ER長度n=30、正規化窗口w=100、偏移0.2。
1. ER：er_raw=|close-close[n]|/sum(|close-close[1]|,n)，er=EMA(er_raw,5)。
2. fa=2/9，sa=2/31，alpha=(er*(fa-sa)+sa)^2，len=clamp(1/alpha, 6, 40)。
3. er_norm=(er-lowest(er,w))/(highest(er,w)-lowest(er,w))，K線數不足w時取0.5。mid=SMA(er_norm,w)，sd=stdev(er_norm,w)，off=max(0.2,0.5*sd)，th_hi=min(mid+off,1)，th_lo=max(mid-off,0)。
4. mult：er_norm>=th_hi→1.6；er_norm<=th_lo→2.6；er_norm>mid→1.6+0.4*(th_hi-er_norm)/(th_hi-mid)；否則2.0+0.6*(mid-er_norm)/(mid-th_lo)。
5. ATR=遞迴RMA(true range, len)：atr=atr[1]+(tr-atr[1])/len，首值為tr。
6. 路徑縮放：ret=close-close[1]；fast=EMA(ret^2,10)，slow=EMA(ret^2,60)，activ=sqrt(fast/slow)(slow=0取1)；drift=EMA(ret,10)；dn=drift/atr；raw=activ+(dn<0 ? -dn*0.3 : 0)+(dn>0 ? dn*0.15 : 0)；adj=0.5+0.5*clamp(raw,0.7,1.8)。
7. dist=mult*atr*adj。
8. 停損：初始為上升趨勢。上升時 vstop=max(前vstop, close-dist)，下降時 vstop=min(前vstop, close+dist)。之後若上升且close<vstop→轉下降、vstop=close+dist；若下降且close>vstop→轉上升、vstop=close-dist。up=是否為上升趨勢。

【多週期】同一引擎跑四層：T1=原K線；T2=每3根K線合成一根；T3=每5根合成；T4=每15根合成(取OHLC聚合，用最近一根已完成的合成K線的up與vstop)。
score=(up1?1:-1)+(up2?2:-2)+(up3?3:-3)+(up4?4:-4)，範圍-10~10。

【波動叢集過濾】r=ln(close/close[1])；shock=|r|>2*stdev(r,20)；base=SMA(shock?1:0,100)；lambda=lambda[1]*exp(-0.2)+(shock?0.5:0)；ratio=base>0 ? lambda/base : 0；ratio>3時 lift=2*min(1,(ratio-3)/2)，否則0。floor=min(4,2+lift)。trade_ok=|score|>floor。

【做多】(以下任一成立)
- 大級別：up4 由假轉真(上一根為下降、本根為上升)。無需trade_ok。
- 趨勢級：up3 由假轉真且trade_ok。
- 短線級：up2 由假轉真、trade_ok、且up4為真(up4為假時不做多)；同根若已有大級別或趨勢級做多訊號則不重複。
- 回檔：在 trade_ok 下，相鄰兩層同為上升(T1&T2、T2&T3、T3&T4各一組，對應短線/趨勢/大級別)，帶底=兩層vstop較小者；條件：close>帶底，且close[1]>帶[1]底，且close[2]不>帶[2]底(剛重新站上)，且同級別無對應翻轉訊號。T1&T2組另需up4為真。
- 全週期同向：trade_ok，且up2、up3、up4皆真，上一根並非三者皆真。

【做空】完全鏡像：
- up4 由真轉假；up3 由真轉假且trade_ok；up2 由真轉假、trade_ok且up4為假(up4為真時不做空)。
- 回檔：相鄰兩層同為下降，帶頂=兩層vstop較大者；close<帶頂，close[1]<帶[1]頂，close[2]不<帶[2]頂；T1&T2組另需up4為假。
- 全週期同向：trade_ok，up2、up3、up4皆假，且上一根up2、up3、up4至少一個為真。

【出場】無獨立出場規則；持多遇到上述做空判斷、持空遇到做多判斷即反向/出場。