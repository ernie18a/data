做多/做空判斷（Pine 原標示 ▲/▼ 進場訊號；BOS/CHoCH 與 FVG 標示同理）：

一、結構轉折（internal 用 N=5，swing 用 N=50）
- 每根 K 棒：若 high[N] > 最近 N 根（bar 0..N-1）的最高 high，leg=0（空腿）。否則若 low[N] < 最近 N 根的最低 low，leg=1（多腿）。其餘情況沿用前一個 leg。
- leg 由 0 變 1：樞紐低點 = low[N]。leg 由 1 變 0：樞紐高點 = high[N]。每個新樞紐的 crossed 重設為 false。
- 多方突破：close 上穿目前樞紐高點，且該樞紐尚未 crossed。internal 另需 internal 樞紐高點不等於 swing 樞紐高點。成立後 crossed=true，趨勢 bias 設為多。若突破前 bias 為空，標 CHoCH（轉多）；否則標 BOS（續多）。
- 空方突破：close 下穿樞紐低點，條件與上面對稱。突破前 bias 為多則標 CHoCH（轉空），否則標 BOS（續空）。
- 預設的 internal 與 swing 標示都指向多或空。

二、AI 進場訊號（▲ 做多、▼ 做空，預設啟用）
- 觸發事件是 internal（N=5）CHoCH：轉多為做多候選，轉空為做空候選。記下該棒的 O/H/L/C 與突破的樞紐價位 level。
- 候選有效期為該棒起 3 根內，之後作廢，新的 CHoCH 會取代舊候選。
- 立即確認（CHoCH 當根）需同時滿足：
  - 不是極端影線棒。多方看上影線 =（high − max(open,close)），空方看下影線 =（min(open,close) − low）。若影線/(high−low) > 0.82 且 |close−open|/(high−low) < 0.06，視為極端影線棒而排除。
  - 不是過小棒：high−low >= 0.12×ATR(14)。
- 延遲確認（CHoCH 之後 1~3 根內）：
  - 做多：close > level + 0.002×ATR(14)，且 close >= CHoCH 棒的 close。
  - 做空：close < level − 0.002×ATR(14)，且 close <= CHoCH 棒的 close。
- 確認成立的那一根，依 CHoCH 方向出做多（▲）或做空（▼）訊號。
- 可選的位移濾網預設關閉。
  - 多方：close>open，range>=1.2×ATR(14)，(close−open)/range>=0.6，(high−close)<=0.2×range。
  - 空方對稱：close<open，其餘同上，且 (close−low)<=0.2×range。

三、FVG 缺口（綠或藍＝多，紅或橙＝空；同週期時 bar 0 為當前棒）
- 多方缺口：low > high[2]，且 close[1] > high[2]，且 (close[1]−open[1])/(open[1]×100) > threshold。
- 空方缺口：high < low[2]，且 close[1] < low[2]，且 −(close[1]−open[1])/(open[1]×100) > threshold。
- threshold = 2 ×（各棒 |(close[1]−open[1])/(open[1]×100)| 的累計和 / bar_index）。

四、表格方向
- EMA200 斜率：EMA(200) 比前一根高為 BULLISH（多），低為 BEARISH（空）。
- EMA 排列：EMA9 > EMA20 > EMA200 為多排列（綠）。EMA9 < EMA20 < EMA200 為空排列（紅）。
- Next Trade 以 HTF bias 與 LTF bias（internal 趨勢）判斷，bias 為多/空/中性：
  - 兩者相同且為多：Short PB（回檔做空）。
  - 兩者相同且為空：Long PB（回檔做多）。
  - 兩者不同，HTF 為多：Long CON（順勢做多）。
  - 兩者不同，HTF 為空：Short CON（順勢做空）。