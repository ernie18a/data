【參數】N=34,mult=1.25,平滑s1=5,s2=4,pivot=3,minMom=0.08,結構突破=0.10,maxStretch=1.05,breakStretch=1.30,revExtreme=1.15,ATR14=atr14。不使用 HTF(視為中性)。
【指標】lag=floor((N-1)/2);basis=EMA(close+(close-close[lag]),N);vol=highest(ATR(N),3N)*mult;upper/lower=basis±vol。trend 為持續狀態:close 上穿 upper 設 1,下穿 lower 設 -1。rawOsc=(close-basis)/vol;osc=EMA(rawOsc,s1);sig=EMA(osc,s2);hist=osc-sig。BullConfirm=osc>sig 且 hist>hist[1];BearConfirm=osc<sig 且 hist<hist[1]。momBull=osc>minMom 且 BullConfirm;momBear=osc<-minMom 且 BearConfirm。chop=|rawOsc|<0.25 且 |hist|<0.6*minMom。
結構:最近 pivot 高/低(左右各 3 根)。close 上穿最近 pivot 高點(close[1]<=該點),且 close-該點>0.10*ATR(N),且距上次結構突破>=6 根 → structure=1;下破 pivot 低點同理 → structure=-1,否則維持原值。
hotBull=trend=1 且 hist>hist[1] 且 osc>sig 且 close>basis 且 |hist|>0.8*minMom 且 |basis-basis[1]|>0.01*ATR(N);hotBear 為鏡像(trend=-1)。
strongBear=basis<basis[1] 且 close<basis 且 close<lower;strongBull 為鏡像。
註:以下 close>basis 這類比較式,做空條件取鏡像。
Regime:ADX(14,14);fast=EMA(ATR14,10),slow=EMA(ATR14,40)。趨勢候選=ADX>=20 且 |rawOsc|>=0.2(fast>slow 為 2,否則 1);否則 ADX<17 或 chop 為 -1;其餘為 0。同一候選連續 3 根才採用。Range=-1,Trend=1或2。
分數:trend 方向符合+20;structure 方向符合+20;momBull+15(僅 BullConfirm+8);rawOsc<maxStretch+10;regime Trend+10/過渡(0)+5/Range+0;符合突破/衝刺/早期reclaim/反轉任一+5。總和/80*100(做空用 -maxStretch<rawOsc、momBear、BearConfirm、structure=-1)。

【做多】需空手、分數達標、收盤確認(close>=close[1]),且該根符合 A 或 B:
A(分數>=80),任一:
1)續勢:trend=1,basis>basis[1],momBull,structure≠-1,close 上穿 basis,osc>0,rawOsc<1.05,且 regime≠Range。
2)突破:trend=1,structure=1,close>upper,close>high[1],osc>sig,hist>hist[1],rawOsc<1.30,非 chop,regime 為 Trend。
3)衝刺:trend=1,structure=1,close>basis,BullConfirm,hist>0,((close>close[1] 且 hist>hist[1]) 或 hotBull),rawOsc<1.30,非 chop,regime 為 Trend。
4)早期reclaim:trend=1,structure=1,close>basis,close[1]<=basis,osc>sig,hist>hist[1],osc>0,rawOsc<1.05,非 chop。
5)反轉:osc[1]<-1.15,osc>sig,hist>hist[1],osc>osc[1],close 上穿 basis,close>open 且 (close-open)>0.4*(high-low),非 strongBear。
B(分數>=50,Trend regime 才可):背景=trend=1,basis>basis[1],close>basis,rawOsc<1.30,非(structure=-1 且 strongBear)。出現「新事件」(trend 剛轉1、close 上穿 basis、動能轉折剛成立[close>basis,osc>osc[1],hist>hist[1],hist>-0.75*minMom]、或回測 basis 後 3 根內陽線且 osc、hist 上升)時記下該根 high/low/basis 為設定。之後 5 根內,於後續某根觸發:(close>設定high 且 close>open 且 hist>hist[1])或(low<=設定basis+0.2*ATR14 且 close>設定basis 且 close>open 且 osc、hist 上升);同時該根 (high-low)/ATR14<=1.25 且 (close-basis)/ATR14<=0.85。設定在 trend=-1 或 close<設定low 時作廢。與上次 B 訊號至少隔 4 根,A 隔 6 根。
C(只有 All Grades 才下單;其餘只為標示):trend=-1 且 BullConfirm 且 hist>hist[1] 且 close>basis 且 structure≠1(或 hotBear 且 BullConfirm 且 close>basis),且非 chop,hist>2*minMom,osc>sig,|basis-basis[1]|>0.003*ATR(N);與上次 C 隔 10 根。

【做空】上述做多條件鏡像(trend=-1,close<basis,close 下穿 lower/basis,structure=-1,momBear,反轉用 osc[1]>1.15 與 close<open 且 (open-close)>0.3*(high-low),non strongBull;close<=close[1]),另 C 空:trend=1 且 BearConfirm 且 hist<hist[1] 且 close<basis 且 structure≠-1(或 hotBull 且 BearConfirm 且 close<basis),hist<-2*minMom,osc<sig,非 chop,|basis-basis[1]|>0.003*ATR(N)。多空同根同時成立則都不做。持倉中不再進場。

【出場】ATR=ATR14(進場時固定為 atr0),entry=進場收盤價。TP1/TP2/TP3=entry±atr0*1.0/1.75/2.5。
初始止損(多):若最近 pivot 低<entry,stop=該 pivot 低-0.2*atr0,否則 entry-1.25*atr0;並取不低於 entry-1.75*atr0。空為鏡像(pivot 高+0.2*atr0,否則 entry+1.25*atr0;不高於 entry+1.75*atr0)。
進場之後的每根:多單 low<=保護價 即出場(止損優先於同根止盈),high>=TP3 出場;空單 high>=保護價、low<=TP3 出場。TP2 觸及(多 high>=TP2、空 low<=TP2)後的下一根起,止損移到 entry,並啟動追蹤:多單追蹤價=TP2 後最高 high-1.75*atr0,只升不降;空單追蹤價=TP2 後最低 low+1.75*atr0,只降不升;保護價=止損與追蹤價中較有利者(多取大、空取小)。
反向 A/B/C 訊號只是警示,預設不出場。