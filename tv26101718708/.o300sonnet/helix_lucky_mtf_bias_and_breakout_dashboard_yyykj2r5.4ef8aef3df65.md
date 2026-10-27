【做多/做空/出場判斷】

1. UT Bot 買賣（主要訊號）
指標：xATR=ATR(7)（RMA）；momentum=(close-close[5])/close；volRatio=volume/SMA(volume,20)；trailDist=xATR*1.2*(1+|momentum|*2)*clamp(volRatio,0.8,1.2)。
追蹤停損 stop：首根=close；prev=stop[前一根]。若 close>prev 且 close[1]>prev，stop=max(prev, close-trailDist)；若 close<prev 且 close[1]<prev，stop=min(prev, close+trailDist)；否則若 close>prev，stop=close-trailDist；否則 stop=close+trailDist。
做多：close 上穿 stop（前根 close<=前根 stop 且本根 close>stop），且 volRatio>0.8，且 close>最近8根 close 最低值*1.01。
做空：close 下穿 stop，且 volRatio>0.8，且 close<最近8根 close 最高值*0.99。
可選過濾（預設關）：近2根確認；做多需 close>ZLSMA、做空需 close<ZLSMA。

2. 均線交叉 Market LONG/SHORT
做多：EMA(10) 上穿 EMA(20)，且 |EMA10-EMA20|/EMA20*100>0.2，且 |MACD(12,26,9)線-信號線|>0.1*ATR(14)，且 close>open。
做空：EMA(10) 下穿 EMA(20)，同樣的距離與 MACD 分離條件，且 close<open。
可選過濾（預設關）：做多需 MACD線>0、做空需 MACD線<0；成交量>=SMA(volume,20)*1.2；ADX(14)>=下限且做多 +DI>-DI、做空 -DI>+DI；RSI(14) 在回檔區（做多40~55、做空45~60）；Donchian 突破（做多 close>前20根最高價、做空 close<前20根最低價）。

3. Supertrend 翻向
ATR(10)(RMA)；mult=2.0*(0.8+0.4*|correlation(close, bar_index,10)|)*sqrt(max(0.1, volume/SMA(volume,10)))；up=hl2-ATR*mult，dn=hl2+ATR*mult。
upLine=close>upLine[1]? max(up,upLine[1]) : up；dnLine=close<dnLine[1]? min(dn,dnLine[1]) : dn。
方向 dir 初始=close>=hl2?1:-1；若 dir==-1 且 close>dnLine[前一根]，dir=1；若 dir==1 且 close<upLine[前一根]，dir=-1。
dir 翻為 1 → 做多；翻為 -1 → 做空。

4. 流動性掃蕩
refHigh=最近15根（不含本根）最高價；refLow=對應最低價。
做空（SweepHigh）：high>refHigh 且 close<refHigh 且 high-refHigh>=0.2*ATR(14)。
做多（SweepLow）：low<refLow 且 close>refLow 且 refLow-low>=0.2*ATR(14)。

5. K線型態（皆需 |close-open|/close*100>=0.25）
- 看多吞噬：前根收黑，open<前收 且 close>前開 且 close>open，RSI(5)<55，volume>SMA(volume,10)*1.3 → 做多。
- 看空吞噬：前根收紅，open>前收 且 close<前開 且 close<open，RSI(5)>45，volume>SMA(volume,10) → 做空。
- Hammer：下影>=2*實體 且 上影<=0.3*全距；low<=前一根起算20根最低價*1.005；前根收黑；RSI(7)>前根RSI(7) 且 <50；volume>SMA(volume,5) → 做多。
- Shooting Star：上影>=2*實體 且 下影<=0.3*全距；high>=前一根起算20根最高價*0.99；前根收紅；RSI(7)<前根RSI(7) 且 >50；volume<SMA(volume,5)*1.1 → 做空。
- Morning Star：bar[2]收黑且實體>0.5*ATR(5)；RSI(14)[2]<35；(close-close[2])/close[2]*100>1.5；volume[1]<SMA(volume,20)*0.7 且 volume>SMA(volume,20)*1.2；low[1]<low[2]；close>high[1]；且（MACD上穿信號線 或 close>EMA20）→ 做多。
- Evening Star：bar[2]收紅且實體>0.5*ATR(5)；RSI(14)[2]>65；(close-close[2])/close[2]*100<-1.5；量能條件同上；high[1]>high[2]；close<low[1]；且（MACD下穿信號線 或 close<EMA20）→ 做空。
- Tweezer Top：|high-high[1]|<=min(0.3*ATR(5), close*0.0005)；close[1]>close[3] 且 close>close[2]；前根收紅；本根 high>max(open,close) 且 close<=open；high>=前10根最高價*0.995 → 做空。
- Tweezer Bottom：|low-low[1]|<=同上容差；close[1]<close[3] 且 close<close[2]；前根收黑；本根 low<min(open,close) 且 close>=open；low<=前10根最低價*1.005 → 做多。
- Dragonfly Doji：實體/全距*100<=0.07，下影>=0.6*全距，上影<=0.1*全距 → 做多。
- Gravestone Doji：實體/全距*100<=0.07，上影>=0.6*全距，下影<=0.1*全距 → 做空。

【出場】（以進場價 entry=訊號收盤價與持倉方向）
- 反向 UT Bot 訊號出現 → 平倉並反手。
- 停損價（多）：取以下低於 entry 者的最大值：UT stop、Supertrend upLine（dir=1時）、最近8根最低價、SMA(200)；再減 0.1*ATR(7)。若無任何候選則 entry-1.5*ATR(7)。若停損價>=entry 則改為 entry-1.6*ATR(7)；若 entry-停損價<0.75*ATR(7) 則改為 entry-0.75*ATR(7)。空方向鏡像（取高於 entry 者的最小值，加 0.1*ATR(7)，距離不足則 entry+0.75*ATR(7)）。
- 多單 low<=停損價、空單 high>=停損價 → 停損出場。
- 風險 R=|entry-停損價|；多單 high>=entry+2R、空單 low<=entry-2R → 停利出場（亦可在 1R 部分停利）。