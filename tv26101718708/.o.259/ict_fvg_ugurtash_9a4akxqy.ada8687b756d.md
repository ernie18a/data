【共同】每根 K 棒收盤後逐根判斷，只用 OHLC。[k] 表示往前 k 根，[0] 為當根。

【做多】符合任一條件即做多：
1. 看漲 FVG：low[0] > high[2]，且 low[1] <= high[2]，且 high[1] >= low[0]。缺口區 top=low[0]、bottom=high[2]。
2. 看漲 Implied FVG：high[0] > high[2]；low[2] < low[0]；low[0] <= high[2]；high[2]-max(open[2],close[2]) > 該根實體/2；min(open[0],close[0])-low[0] > 當根實體/2；low[0] > low[1]；high[0] > high[1]；close[1] > open[1]；(high[2]+max(open[2],close[2]))/2 < (min(open[0],close[0])+low[0])/2。
3. 看漲 Volume Imbalance（預設 classic 型）：open[0] > close[1]，low[0] <= high[1]，close[0] > open[0]，close[1] > open[1]。advanced 另加兩型：
   - 型2：open[0] < close[1]，close[0] > open[0]，close[1] > open[1]，high[0] >= low[1]。
   - 型3：open[0] != close[1]，close[0] > open[0]，close[1] < open[1]，high[0] >= low[1]，low[0] <= high[1]。
4. 向上跳空：high[1] < low[0]。
5. 看漲 OB：n=10，upper=近 n 根最高 high，lower=近 n 根最低 low。狀態 os：high[n] > upper 則 os=0；否則 low[n] < lower 則 os=1；否則沿用前值。os 由非 0 轉為 0 時，記下 swingHigh=high[n]，標為未用。當 close > swingHigh 且該 swingHigh 未用，就做多，並把該 swingHigh 標為已用（每個擺動點只觸發一次）。可選：close > swingHigh + 係數 × |swingHigh−swingLow|，預設係數為 0。
6. 看跌 FVG 被反轉（Inverse FVG，需啟用，預設關）：看跌 FVG（high[0] < low[2]，high[0] >= low[1]，high[1] >= low[2]；區 top=low[2]、bottom=high[0]）先有某根收盤 close < bottom（armed），之後某根 high >= top 時做多。
7. 看跌 OB 被反轉（Breaker，需啟用，預設關）：看跌 OB 區（見做空第 5 點）建立後，某根 high >= 區 top 時做多。

【做空】為上述的鏡像，符合任一條件即做空：
1. 看跌 FVG：high[0] < low[2]，且 high[0] >= low[1]，且 high[1] >= low[2]。
2. 看跌 Implied FVG：low[0] < low[2]；high[2] > high[0]；high[0] >= low[2]；min(open[2],close[2])-low[2] > 該根實體/2；high[0]-max(open[0],close[0]) > 當根實體/2；high[0] < high[1]；low[0] < low[1]；close[1] < open[1]；(min(open[2],close[2])+low[2])/2 > (high[0]+max(open[0],close[0]))/2。
3. 看跌 Volume Imbalance（classic）：open[0] < close[1]，high[0] >= low[1]，close[0] < open[0]，close[1] < open[1]。advanced 另加兩型：
   - 型2：open[0] > close[1]，close[0] < open[0]，close[1] < open[1]，low[0] <= high[1]。
   - 型3：open[0] != close[1]，close[0] < open[0]，close[1] > open[1]，low[0] <= high[1]，high[0] >= low[1]。
4. 向下跳空：low[1] > high[0]。
5. 看跌 OB：os 由非 1 轉為 1 時，記下 swingLow=low[n]，標為未用。當 close < swingLow 且該 swingLow 未用，就做空，並標為已用。可選：close < swingLow − 係數 × 擺動區間，預設係數為 0。
6. 看漲 FVG 被反轉（Inverse FVG，需啟用，預設關）：看漲 FVG（區 top=low[0]、bottom=high[2]）先有某根收盤 close > top（armed），之後某根 low <= bottom 時做空。
7. 看漲 OB 被反轉（Breaker，需啟用，預設關）：看漲 OB 區（見做多第 5 點）建立後，某根 low <= 區 bottom 時做空。

【OB 區】做多、做空第 5 點的區間用於 Breaker 判斷。
- 看漲 OB 區：往前掃描 min(bar_index−swing 位置−1, 50) 根（不含突破棒），取 low 最低的那根。若它不是陰線（close<open），改用其左右相鄰的陰線，兩側都是陰線則取 low 較低者。區 top=該根 high、bottom=該根 low。
- 看跌 OB 區：往前掃描同樣範圍，取 high 最高的那根。若它不是陽線，改用其左右相鄰的陽線，兩側都是陽線則取 high 較高者。區 top=該根 high、bottom=該根 low。

【出場】無獨立出場判斷；反向訊號即視為翻向。