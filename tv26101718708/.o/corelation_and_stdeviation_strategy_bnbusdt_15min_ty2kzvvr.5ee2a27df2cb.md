只做多，不做空。以下 P、S 等符號是此筆記自訂的名稱。

【基礎】
P = linreg(close,7,0)。
「價格下跌」= P<P[1]<P[2]<P[3]。
ma9 = ema(hl2,3)。

【綜合指標 S】
對下列每個序列 x 算 f(x) = stdev(x,7) × correlation(x,P,7) × stdev(x − sma(x,5), 7)。
只有 sar 與 supertrend 這兩項沒有最後那個 stdev 項，即 f = stdev(x,7) × correlation(x,P,7)。
S = 所有 f 相加。

x 清單（周期 7 為預設）：
1. sar(0.2,0.2,0.2)
2. supertrend(1,10) 的線值
3. rsi(close,7)
4. mfi(close,7)
5. linreg(((close−open)/(high−low)×100+100)/2, 7, 0)
6. cmo(close,7)
7. cog(close,7)
8. dmi(3,10) 的 ADX
9. linreg(stoch(close,high,low,7), 7, 0)
10. linreg(swma(close), 7, 0)
11. tsi(close,14,28)
12. ema(wpr(7),7)
13. ema(accdist,7)
14. ema(iii,7)
15. ema(nvi,7)
16. ema(pvi,7)
17. wma(obv,7)
18. ema(pvt,7)
19. ema(tr,7)
20. hma(vwap,7)
21. ema(wad,7)
22. ema(wvad,7)
23. sma(close,7) − sma(close,200)
24. ema(close,7) − sma(close,200)
25. cci(close,7)
26. 趨勢角度（見下方）
27. sma(10000×(hl2−hl2[1])×(high−low)/volume, 7)
28. close − sma(close,7)[4]
29. (high − sma(high,7)) + (low − sma(low,7))
30. sma(high,7)
31. sma(low,7)
32. sma(open,7)
33. sma(close,7)

第 26 項趨勢角度：
- e = ema(close,34)。
- span = 25/(highest(high,30) − lowest(low,30)) × lowest(low,30)。
- y = (e[1] − e)/hlc3 × span。
- a = round(180 × acos(1/√(1+y²)) / π)。
- 若 y>0 取 −a，否則取 a。

【衍生序列】
以下 chg2(x) = x − x[2]。

第一組：
- c1 = correlation(S,P,7)
- sd1 = stdev(S,7)
- g2 = S×c1
- g3 = c1×sd1
- g4 = chg2(S)
- g5 = 100×chg2(g4)/g4[1]

第二組（由 g2 衍生）：
- c2 = correlation(g2,P,7)
- g6 = g2×c2
- g7 = c2×stdev(g2,7)
- g8 = chg2(g2)
- g9 = 100×chg2(g8)/g8[1]

第三組（由 g3 衍生）：
- c3 = correlation(g3,P,7)
- sg = stdev(g3,7)
- g11 = c3×sg
- g12 = sg − sg[1]
- g13 = g12 − g12[1]

【做多訊號】
以下每個訊號都要求「價格下跌」同時成立。cross 指同一根 K 棒上穿或下穿。
- b1：g7 下穿 0。
- b2：g11 穿越 0（上穿或下穿皆可）。
- b3：g5、g9、g13 同一根都穿越 0。
- b4：g4、g8、g12 同一根都穿越 0。
- b5：g2、g3、g4 同一根都穿越 0。
- b6：g4 與 g8 相交、g4 與 g12 相交、g12 與 g8 相交，三者同一根發生。

【過濾用的區間點】
- H = highest(high,280)，Lw = lowest(low,280)。
- 每根 K 棒依序檢查 i=1 與 i=0：
  - 若 H[i] < H[i+1]，則 hi_point = H[i+1]。
  - 否則若 Lw[i] > Lw[i+1]，則 low_point = Lw[i+1]。
- 兩者都是會保留上一個值的變數，起始為空。

【進場做多】
- 空手時：(b1 或 b2 或 b3) 且 open < low_point，則做多。
- 已有多單時，加碼條件為下列任一：
  - (b1 或 b2 或 b3 或 b4) 且 ma9 < 持倉均價×0.99，且未平倉筆數 ≤ 最大筆數×0.75。
  - b6 且 ma9 < 持倉均價，且未平倉筆數介於最大筆數×0.75 與最大筆數之間（含上限）。
- 最大筆數預設為 floor(總資金/44) − 1。

【出場平多】
- 令 d = supertrend(1,24) 的方向值，d>0 表示下跌趨勢。
- 賣出指令 = (d[1]<0 且 d>0)，或 (d>0 且 b1~b6 任一成立)。
- 當賣出指令成立，且 持倉均價×1.07 < ma9，且 hi_point[1] 與 low_point 皆已有值（非空、非 0），則全部平倉。