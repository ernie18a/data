【方向】三組獨立的樞紐長度 L=8、21、34 各自跑下面的趨勢線引擎，任一組出現向上突破就做多，出現向下突破就做空。多空訊號互為反向，沒有其他出場條件。

【樞紐】
- 樞紐高：src_h[t-L] 是區間 [t-2L, t] 內的最大值，於 t 收盤確認。
- 樞紐低：src_l[t-L] 是同區間內的最小值，於 t 確認。
- src_h 取 max(open, close)，src_l 取 min(open, close)。
- 新樞紐高事件 chH：新樞紐高的價格不同於上一個樞紐高，且同一根沒有新樞紐低事件。
- 新樞紐低事件 chL：新樞紐低的價格不同於上一個樞紐低，且同一根沒有新樞紐高事件。
- 記錄 prevPh、prevPl（各含 index 與 price），event 發生時 x=t-L，v=樞紐價，c=close[L 根前]。

【每個 L 的狀態】trend∈{0,1,-1}，初始為 0；另有一條線，含錨點 cp(idx, price)、slope、active。每根 K 先把 active 線的當根線值 Y 加上 slope；線長超過 5000 根就作廢。

【做多：下降壓力線向上突破】
1. 新樞紐高事件，且 trend<1：
   - 若 v>prevPh.price 且 x-prevPh.idx>5：trend=1，建立水平線，Y=prevPl.price，cp=prevPl，slope=0，active。這條線供做空用。
   - 否則若壓力線 active：
     - 算 s=(v-cp.price)/(x-cp.idx)。
     - 條件成立才進一步檢查：v < 線起點 y1 + s，且(v > Y+s 或舊 slope==0)。
     - 條件成立時，若 c < 線在第 x 根的價格，線更新為通過該樞紐：Y=v+s*L，slope=s。
     - 若舊 slope==0，要重新找錨點：在錨點到現在（最多 500 根）中，找 close[i]-線價 最大的一根。若此值大於 0，錨點改為該根的 high，slope 與線重算，再重複找；直到沒有任何 close 高於線。
     - 條件成立但 c ≥ 線價時，線作廢（active=false）；若 trend<1，觸發做多。
   - 最後 prevPh=(x, v)。
2. 該根沒有新樞紐高事件時：若 trend<1 且線 active 且 close>Y，線作廢並觸發做多。

【做空】完全鏡像：樞紐低事件、trend>-1、v<prevPl.price 且 x-prevPl.idx>5 時 trend=-1，建立從 prevPh 出發的水平線。之後依鏡像規則更新上升支撐線（比較方向反轉，重找錨點改用 low、找線高於 close 最多的一根）。支撐線被突破作廢時觸發做空，包含兩種情形：
- 新樞紐低的 c ≤ 線價且 trend>-1。
- 無新樞紐低時 trend>-1、線 active 且 close<Y。

【過濾，預設開啟】
- VWAP 斜率：VWAP 為 hlc3 的成交量加權，每日重置。g=((VWAP-VWAP[10])/10)/ATR(14)，ATR 用 Wilder 法。
- 做多需 g>0.05，做空需 g<-0.05。

【過濾，預設關閉，開啟才套用】
- 結構：該 L 最近兩個樞紐高與兩個樞紐低，做多需高點更高且低點更高，做空需高點更低且低點更低。
- 突破：做多需 close>該 L 最新樞紐高，做空需 close<該 L 最新樞紐低。
- 量：volume ≥ 近 50 根 volume 的 75 百分位（線性內插）。