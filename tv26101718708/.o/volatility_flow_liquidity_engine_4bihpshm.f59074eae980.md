只有進場判斷，沒有出場規則。以下全部用單一商品的 OHLCV 計算，不使用波動率指數與配對商品（兩者的因子權重為 0）。

【指標】
- ret = ln(close/前一根 close)。ATR = ATR(20)。
- 壓縮分 fComp = 100 − percentrank(ATR, 120)。
- 凸性分 fCvx = percentrank(|ret − 前一根 ret|, 120)。
- 效率比 er = |close − close[20]| / Σ|close 相鄰差|（20 根）。無效率分 = 100 − 100·er。
- pressure = (fComp + 1.5·fCvx + (100 − 100·er)) / 2.5。
- pPct = percentrank(pressure, 120)。
- loaded = 近 10 根（含當根）pPct 的最高值 ≥ 85。
- release = (high − low)/ATR ≥ 2.0（區間擴張達上限）。
- rawSig = loaded 且 release。

【訊號觸發】
- rawSig 連續成立的根數剛好等於 2 時觸發，即第 2 根連續成立的那根。第 3 根起不再觸發。
- 距上一次觸發至少 10 根。

【方向判斷】
- 20 根高低通道：upTrig = highest(high, 20)，dnTrig = lowest(low, 20)。
- brokeUp = close > 前一根的 upTrig。brokeDn = close < 前一根的 dnTrig。
- clvUp = (close − low) ≥ (high − close)。chg = close − close[3]。
- upScore = 2·brokeUp + clvUp + (chg ≥ 0)。
- dnScore = 2·brokeDn + (非 clvUp) + (chg < 0)。
- upScore ≥ dnScore 時方向向上，否則向下。

【進場】
- 做多：觸發且方向向上。
- 做空：觸發且方向向下。

【過濾（會擋掉訊號）】
- 流動性：不得為 STRESSED。流動性分數 = 100 − 價差、Amihud 與 Kyle 衝擊三者百分位的平均，再與成交額深度加權。STRESSED 指分數 < 20，或 Amihud 單根偏離其 252 根平均 ≥ 3 個標準差。
- 位置：做多時，上方最近的參考位須距 close 至少 0.5·ATR，否則不做多。做空時，下方最近的參考位須距 close 至少 0.5·ATR，否則不做空。參考位包含前一日 POC/VAH/VAL、尚未被觸及的歷史日 POC、錨定 VWAP。上方或下方沒有參考位時視為通過。

【預設只標示、不擋訊號】
- 訂單流（高於 0.5σ 且買賣量差為正，表示偏多；反之偏空）。
- 變異數比率制度。
- 多週期 Ichimoku 共識（預設關閉）。