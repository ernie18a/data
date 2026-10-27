【指標】TR=max(high-low,|high-前收|,|low-前收|)。ATR(n)=TR 的 Wilder RMA。hAtr=ATR(10)。hMa=EMA(close,13)。raw_up=hMa-1.25*hAtr，raw_dn=hMa+1.25*hAtr。ema21=EMA(close,21)，ema55=EMA(close,55)，ema200=EMA(close,200)。HMA(s,L)=WMA(2*WMA(s,floor(L/2))-WMA(s,L),round(sqrt(L)))。HULL=HMA(close,200)，HULL_FAST=HMA(close,21)。hull_bull=HULL>HULL[2]，hull_bear=HULL<HULL[2]；fast_bull/fast_bear 對 HULL_FAST 做同樣比較。

【追蹤線 trail 與 trailTrend】首根：close>hMa 則 trailTrend=1、trail=raw_up；否則 trailTrend=-1、trail=raw_dn。之後逐根更新：
- trailTrend=1：若 close<trail 且 ema21<ema55，則 trailTrend=-1、trail=raw_dn。若 close<trail 但 ema21 不小於 ema55，trail 維持前值。否則 trail=max(raw_up,前 trail)。
- trailTrend=-1：若 close>trail 且 ema21>ema55，則 trailTrend=1、trail=raw_up。若 close>trail 但 ema21 不大於 ema55，trail 維持前值。否則 trail=min(raw_dn,前 trail)。
- flip_bull=本根 trailTrend=1 且前一根為-1；flip_bear 反之。

【Fib 方向】basis=EMA(EMA(hlc3,50),50)。trend_fib 在 basis>前值時為 1，basis<前值時為-1，相等時沿用前值。
- ultron_bull_clear=(trend_fib==1 或 close>ema200)；ultron_bear_clear=(trend_fib==-1 或 close<ema200)。
- 高週期（HTF）：把資料重取樣到更高週期。對應為 1m→5m、3m 與 5m→15m、15m 與 30m→60m、60m→240m、240m→日、日→週，其他→240m。在 HTF 上用同樣公式算 basis 與 trend，取上一根已收完的 HTF 值，得到 htf_trend 與 htf_basis。
- 計算 trend_fib 或 htf_trend 的「距上次翻向的 LTF 根數」，翻向時從 0 起算。
- fib_base_long 需同時成立：htf_trend==1；close>basis；close>htf_basis（htf_basis 為 na 時略過）；(trend_fib==1 或距 LTF 翻向>5 根)；(htf_trend==1 或距 HTF 翻向>8 根)。fib_base_short 為鏡像（-1、close<、<）。

【計分】mom=(close-close[5])/hAtr，mom_bull 為 mom>0.5，mom_bear 為 mom<-0.5。vol_ok=volume>=1.2*SMA(volume,20)。bull_score 為下列成立項數：hull_bull、fast_bull、trailTrend==1、CHoCH 啟用且方向為多、in_aoi 且 CHoCH 方向為多、mom_bull、ultron_bull_clear、vol_ok。bear_score 為鏡像（hull_bear、fast_bear、trailTrend==-1、CHoCH 方向為空、mom_bear、ultron_bear_clear），vol_ok 兩邊都各加 1。
- fib_clear_long=fib_base_long 或 (bull_score>=7 且 trailTrend==1)；fib_clear_short=fib_base_short 或 (bear_score>=7 且 trailTrend==-1)。
- qual_bull=trailTrend==1 且 bull_score>=4 且 ultron_bull_clear 且 fib_clear_long。qual_bear=trailTrend==-1 且 bear_score>=4 且 ultron_bear_clear 且 fib_clear_short。

【CHoCH（結構反轉）】s=5。以 pivothigh(high,5,5) 記錄最新擺動高點 bullLvl 並設為未被突破；以 pivotlow(low,5,5) 記錄 bearLvl 並設為未被突破。
- 多方突破：close>bullLvl 且該高點未被突破。突破後標記為已突破。若突破前 lastBreakDir==-1 且品質過濾通過，則為做多 CHoCH（chochSignal，方向=多）。無論是否通過，lastBreakDir 都設為 1。
- 空方突破：close<bearLvl，鏡像處理。
- 品質過濾（突破當根）：(high-low)>=0.5*hAtr；htf_trend 與方向一致；多方 (close-lowest(low,15))/hAtr<=3，空方 (highest(high,15)-close)/hAtr<=3。
- 成立時，zoneHigh/zoneLow=該根 high/low，zoneRng=zoneHigh-zoneLow，並設 chochActive。方向持續到下一次 CHoCH。
- in_aoi=chochActive 且 (|close-zoneHigh|<=1.5*zoneRng 或 |close-zoneLow|<=1.5*zoneRng)。
- CHoCH 觸發另需區域信心>=0.5。信心=符合項數/9，項目為：MTF(15m) CHoCH 方向一致、fib_base 同向通過、vol_ok、mom 同向、htf_trend 同向、in_aoi 且方向同向，再加上最近流動性、溢價折價位置、時段三項。

【進出場（預設「訊號變化」模式）】
- 做多觸發 trig_bull=(flip_bull 或 (做多 CHoCH 當根且信心>=0.5)) 且 qual_bull。
- 做空觸發 trig_bear=(flip_bear 或 (做空 CHoCH 當根且信心>=0.5)) 且 qual_bear。
- 空手且 K 棒收盤時：trig_bull 以 close 做多，否則 trig_bear 以 close 做空。
- 進場時 entry=close，初始止損=當根 trail，R=|close-trail|。TP1/TP2/TP3 為 entry±1R/1.5R/2R（多方加、空方減）。
- 做多持倉每根更新止損：階段1 止損=trail。
  - 階段1 中 high>=TP1 時進入階段2，止損=max(entry,trail)。
  - 階段2 中 high>=TP2 時進入階段3，止損=max(TP1,trail)。
  - 階段3 中 high>=TP3 時進入階段4，止損=max(trail,前止損)。
  - 止盈價只用來上移止損，不平倉。
- 做多出場：收盤 close<=當前止損，或 flip_bear。
- 做空鏡像：階段2 止損=min(entry,trail)，階段3 止損=min(TP1,trail)，階段4 止損=min(trail,前止損)。出場為 close>=當前止損，或 flip_bull。

【其他方向標示】
- RSI 智慧訊號：rsi=RSI(close,10)，d=EMA(close,3) 的一根變化量。
  - 多：rsi>55 且 rsi<85 且 d>0，同時 trailTrend==1、hull_bull、trend_fib==1，且前一根不成立（上升沿）。
  - 空：rsi<48 且 rsi>20 且 d<0，同時 trailTrend==-1、hull_bear、trend_fib==-1，且前一根不成立（上升沿）。
- 原始翻向標示：flip_bull 標多，flip_bear 標空。若 flip 沒有通過 trig 條件，則是被拒絕的多或空翻向。