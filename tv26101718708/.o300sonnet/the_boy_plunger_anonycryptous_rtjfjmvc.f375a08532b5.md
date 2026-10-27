【共用計算】ATR=14期ATR。快線/慢線=收盤價的EMA(9)/EMA(21)（可換HMA 8/21或EMA 21/89）。量均=volume的20期SMA。量能突增=volume>量均×1.5。實體比=|close-open|/(high-low)，實體強=實體比>=0.55。水平=用回測資料本身的K線算pivot：high為左右各5根的最高點即pivot high，low為左右各5根的最低點即pivot low，各取最近4個（pivot確認後才可用）。最近水平=這8個價位中離close最近者。接近水平=|close-最近水平|<=1.5×ATR。

【做多】同時成立：close>最近水平；close>=open；接近水平；volume突增；快線>慢線；距上次任何方向訊號已>=10根；|close-快線|<=3×ATR。預設不要求實體強。
【做空】同時成立：close<最近水平；close<open；接近水平；volume突增；快線<慢線；冷卻與距離條件同上。
【預設以外的過濾組合】只換「是否要求」，其餘條件不變。livermore（EMA21/89）：不要求快慢線方向，要求接近水平、量突增、實體強。boy plunger（HMA8/21）：要求快慢線方向、接近水平、量突增、實體強。ribbon：只要求快慢線方向，不要求接近水平與量突增。sensitive：只要求接近水平與量突增。持倉中不重複進場。

【均線交叉】快線上穿慢線偏多；快線下穿慢線偏空。

【RSI背離】RSI=14期RSI。low的pivot low（左5右2）與RSI的pivot low（左5右2）出現在同一根時，若與前一次同時成立的低點相距1~60根，且新低點low更低、RSI更高，偏多。high與RSI的pivot high同理，新高更高、RSI更低，偏空。

【出場】進場價entry、方向dir。多單停損 origSL=min(entry-1.5×ATR, 近10根最低low)；空單 origSL=max(entry+1.5×ATR, 近10根最高high)。R=|entry-origSL|。TP1=entry+dir×0.5R，TP2=entry+dir×1R，TP3=entry+dir×2R。進場那根之後逐根檢查：
1) 多單 high>=TP3（空單 low<=TP3）出場。
2) 否則多單 low<=現行停損（空單 high>=現行停損）出場。
現行停損初始=origSL；high（空單low）曾觸及TP1後，現行停損上移（空單下移）到不劣於entry；曾觸及TP2後，再不劣於「快線-0.2×ATR」（空單「快線+0.2×ATR」）；停損只往有利方向移動。
3) 失敗突破：多單進場後第1~3根內close<進場訊號當時的最近水平，視為多單失敗出場（空單為close>該水平）。