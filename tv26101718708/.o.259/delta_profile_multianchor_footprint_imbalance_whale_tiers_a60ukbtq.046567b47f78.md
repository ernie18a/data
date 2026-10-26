【單根買賣量與 delta z】賣買量用 K 棒位置估算：買量=volume×(close−low)/(high−low)，賣量=volume×(high−close)/(high−low)。若 high=low，買賣各取 volume×0.5。delta=買量−賣量。z=(delta−近50根 delta 中位數)/(1.4826×近50根 |delta−中位數| 的中位數)。MAD 接近 0 時 z=0。z 夾在 ±4。

【做多／做空：壓力穿越】
- 做多：z 由 ≤1.0 上穿 >1.0。
- 做空：z 由 ≥−1.0 下穿 <−1.0。
- 每個方向每次只觸發一次。觸發後該方向解除武裝，做多要等 z≤0 才重新武裝，做空要等 z≥0。
- 過濾：多週期方向須同向才採用，也就是看多只在多週期偏多時成立，看空只在偏空時成立。只有單一週期資料時，可改成要求 z 同方向，即做多要 z>0，做空要 z<0。

【做多／做空：流向 EMA 交叉】對 z 取 EMA3（快）與 EMA12（慢）。快線上穿慢線偏多，下穿偏空。

【做多／做空：極端壓力】z 在近200根的 percentrank。≥97 為買方高潮（綠色），≤3 為賣方高潮（紅色）。標示本身只標出方向：買方高潮標綠、賣方高潮標紅。

【出場／翻向：ATR 追蹤停損線】ATR14，d=2×ATR14。
- 多頭狀態：停損=max(前停損, close−d)。若 close<停損，轉空頭，停損=close+d。
- 空頭狀態：停損=min(前停損, close+d)。若 close>停損，轉多頭，停損=close−d。
- 由空翻多為做多訊號，也是空單出場。由多翻空為做空訊號，也是多單出場。
- 持多時 close 跌破停損線即出場，持空時 close 突破停損線即出場。

【做多／做空：CVD 背離】CVD=每日重置的 delta 累計。取 close 的 pivot（左右各5根，確認延遲5根）。
- 價格 pivot high 高於前一個 pivot high，且該處 CVD 低於前一個 pivot high 處的 CVD：做空。
- 價格 pivot low 低於前一個 pivot low，且該處 CVD 高於前一個 pivot low 處的 CVD：做多。

【做多／做空：大量棒】volume 達近200根的第97百分位時才成立。close≥open 為大量買盤（偏多），close<open 為大量賣盤（偏空）。

【做多／做空：VSA 事件】百分位皆為近50根的 percentrank。spread=high−low，cp=(close−low)/(high−low)。「前5根」指不含本根的前5根。
- 偏多：
  - 賣出高潮：close<前收，且 volume 為近50根最大、spread 百分位≥70。
  - Shakeout：low≤前5根最低，且 cp≥0.65、量百分位≥60。
  - Stopping volume：close<前收，且 spread 百分位≥60、量百分位≥80、cp≥0.45。
  - No supply：close<前收，且 spread 百分位≤35、量百分位≤35。
- 偏空：
  - 買入高潮：close>前收，且 volume 為近50根最大、spread 百分位≥70。
  - Upthrust：high≥前5根最高，且 cp≤0.35、量百分位≥60。
  - No demand：close>前收，且 spread 百分位≤35、量百分位≤35。