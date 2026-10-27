【做多/做空判斷。出場無獨立規則，皆以反向訊號翻轉。】

1. 分形突破。上分形：第 t-2 根 high 為 t-4..t 共5根最高（pivothigh 2,2）。下分形：t-2 根 low 為5根最低。記下最近上分形高點 U、最近下分形低點 D，各於分形確認時更新。high 上穿 U（前根 high<=U，本根 high>U）為做多。low 下穿 D 為做空。兩者都沒發生就沿用前一次方向，起始方向為多（fr_state）。

2. FVG。low > high[2] 為做多（多方缺口）。high < low[2] 為做空（空方缺口）。沒發生就沿用前一次，起始為多（fvg_state）。

3. 背離。使用 RSI(close,14) 與 25 根回看，hiP=highest(x,25)[1]，loP=lowest(x,25)[1]。
- 做多：(low < lowest(low,25)[1] 且 RSI > lowest(RSI,25)[1])（一般背離），或 (low > lowest(low,25)[1] 且 RSI < lowest(RSI,25)[1])（隱藏背離）。
- 做空：(high > highest(high,25)[1] 且 RSI < highest(RSI,25)[1])，或 (high < highest(high,25)[1] 且 RSI > highest(RSI,25)[1])。
- 價格來源可改為 close，RSI 可改為 MACD(12,26,9) 快線或訊號線。

4. 近12根 L。設兩旗標 longP、shortP 起始皆為 true。
- 做多：low == highest(low,12) 且 shortP。觸發後 longP=true、shortP=false。
- 做空：high == lowest(high,12) 且 longP。觸發後 shortP=true、longP=false。

5. 外包K。o = high>high[1] 且 low<low[1]。o 且 close < low[1] 為做多（綠）。o 且 close > high[1] 為做空（紅）。

6. 掃單K（在下一根標示，條件用 t-1 根）。
- 做空：high[1]>high[2] 且 high[1]>high[3] 且 close[1]<high[2]。
- 做多：low[1]<low[2] 且 low[1]<low[3] 且 close[1]>low[2]。

7. 假突破 Fakey（預設關）。內包K ib(k)=high[k]<high[k+1] 且 low[k]>low[k+1]。
- 做多 = X 或 Y 的新發生（本根成立、前根不成立）。
  - X：k 取 1..4 任一，ib(k) 且 low<low[k] 且 close>high[k]。
  - Y：下列任一。
    - ib(1) 且 low<low[1] 且 close>open[1] 且 close>open。
    - ib(2) 且 close[1]<low[2] 且 close>close[1] 且 high>high[1]。
    - ib(1) 且 low<low[2] 且 close>close[1] 且 close>open。
    - ib(2) 且 close[1]<low[3] 且 close>open 且 close>open[1]。
- 做空 = X' 或 Y' 的新發生，與做多完全鏡像。
  - X'：ib(k) 且 high>high[k] 且 close<low[k]。
  - Y'：下列任一。
    - ib(1) 且 high>high[1] 且 close<open[1] 且 close<open。
    - ib(2) 且 close[1]>high[2] 且 close<close[1] 且 low<low[1]。
    - ib(1) 且 high>high[2] 且 close<open 且 close<close[1]。
    - ib(2) 且 close[1]>high[3] 且 close<open 且 close<close[1]。

8. EMA 雲（預設關）。EMA8 > EMA21 為多，EMA8 < EMA21 為空。

9. MA 斜率色（預設只有 SMA50 線，斜率色預設關）。MA 可選 SMA 或 EMA，長度預設 SMA50，另有 200 可用。MA >= MA[1] 為多（綠），否則為空（紅）。

10. 壓縮箱突破（預設關）。壓縮（見第 11 點的 SQUEEZE）期間記錄最高 high 與最低 low 成箱，壓縮結束後箱鎖定。
- close > 箱頂 且 close[1] <= 箱頂：做多。
- close < 箱底 且 close[1] >= 箱底：做空。
- 下次壓縮開始時重置箱。

11. 偏向 BULL/BEAR（面板、背景、警報）。預設參數 Balanced、Standard。
(a) 週期參數（依圖表週期秒數）：

| 圖表週期 | coreLen | volLen | persist |
|---|---|---|---|
| <=15m | 8 | 50 | 2 |
| >15m 至 <=4h | 13 | 80 | 2 |
| >4h 至 <1D | 21 | 120 | 1 |
| 日線 | 21 | 150 | 1 |
| 週線以上 | 34 | 200 | 1 |

(b) 市場狀態：
- BB(close,20,2)，bbw=(上-下)/中，avgbbw=sma(bbw,volLen)。
- KC：ema(close,20) ± 1.7*atr(20)。squeezeKC = BB上<KC上 且 BB下>KC下。
- ADX = ta.dmi(14,14) 的 ADX。
- SQUEEZE：未啟動時，bbw<0.7*avgbbw 且 squeezeKC 才啟動。啟動後，bbw>1.4*avgbbw 或 not squeezeKC 才解除。
- TREND：未啟動時 ADX>=20 才啟動。啟動後 ADX<10 才解除。
- 候選狀態：SQUEEZE 優先，其次 TREND，否則 RANGE。
- 候選連續 persist 根相同，狀態才切換。
(c) 分數：
- raw=(fr*4 + fvg*wF)/(4+wF+2)，fr、fvg 為第1、2點的狀態（±1）。
- wF=4；若狀態為 SQUEEZE 則 wF=1.4。
- final=clamp(ema(raw,coreLen),-1,1)。
- gate：SQUEEZE 0.4，RANGE 0.7，TREND 1.0。
- adr%>=85 時 gate*=0.85。adr%>=110 時再 *=0.70。
- 分數=50+50*final*gate。
- adr% 在日內圖 = 當日已走 high-low 範圍 / 前20個完整日範圍均值 *100。在非日內圖 = (high-low)/sma(high-low,20)*100。
(d) 狀態機，起始 NEUT，每根收盤更新：
- NEUT 時：分數>=55 連續2根（含本根）轉 BULL。分數<=45 連續2根轉 BEAR。
- BULL 時：分數<=52 即轉 NEUT。
- BEAR 時：分數>=48 即轉 NEUT。
- BULL 與 BEAR 之間必須經過 NEUT。
- BULL=做多偏向，BEAR=做空偏向。