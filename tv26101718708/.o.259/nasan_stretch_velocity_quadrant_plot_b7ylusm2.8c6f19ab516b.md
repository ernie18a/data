方向判斷只看加權速度 V 的正負。

指標計算：
1. P = (high+low+close)/3。
2. 對 P 取 EMA13、EMA21、EMA34，EMA 的 alpha = 2/(n+1)。
3. 取 ATR13、ATR21、ATR34，ATR 為真實波幅 TR 的 Wilder RMA。TR = max(high-low, |high-前收|, |low-前收|)，第一根只用 high-low。
4. 三個速度分量：
   - v13 = (EMA13 - 8 根前的 EMA13) / ATR13
   - v21 = (EMA21 - 13 根前的 EMA21) / ATR21
   - v34 = (EMA34 - 21 根前的 EMA34) / ATR34
5. 原始速度 = 0.25*v13 + 0.5*v21 + 0.25*v34。
6. V = 原始速度再取 EMA(5)。

READ 把平面分成四個象限，並標示多空：
- V>=0 且伸展度>=0：看多（Bullish Expansion）
- V>=0 且伸展度<0：看多（Bullish Reversion）
- V<0 且伸展度>=0：看空（Bearish Reversion）
- V<0 且伸展度<0：看空（Bearish Expansion）

伸展度的計算：對 n=13、21、34，各算 (P - EMAn)/ATRn，再以 0.25、0.5、0.25 加權，最後取 EMA(5)。

四個象限的多空方向只由 V 的正負決定，伸展度不改變方向。

做多：V >= 0。
做空：V < 0。
出場：持多時 V 轉為 < 0，或持空時 V 轉為 >= 0，即方向反轉；READ 沒有其他出場條件。