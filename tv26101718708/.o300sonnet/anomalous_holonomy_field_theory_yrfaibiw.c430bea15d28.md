【分數】每根收盤K線逐根計算。ROC=(close-close[10])/close[10]*100。VWAP距離=(close-當日錨定VWAP(hlc3,以volume加權))/close*100。EMA20、EMA50取close；HTF=60分鐘K線close的EMA20。ATR=ATR(14)。量均=volume的SMA(20)。
s=0。
若close>HTF且close>EMA20：s+=1.0*(close>EMA50?1.5:1.0)；ROC>0則s+=ROC/10；volume>1.2*量均則s+=0.5。
否則若close<HTF且close<EMA20：s-=1.0*(close<EMA50?1.5:1.0)；ROC<0則s+=ROC/10（為負值）；volume>1.2*量均則s-=0.5。
其餘情況s不變。
接著s+=clamp(VWAP距離,-2,2)。
RSI(14)：s>0時，RSI<30加1.5，否則RSI<40加0.5；s<0時，RSI>70減1.5，否則RSI>60減0.5。
MACD(12,26,9)：MACD線>訊號線且s>0則s+=0.5；MACD線<訊號線且s<0則s-=0.5。
分數=s*50/10。

【門檻】波動=ATR/close*100；p30、p70為最近100根波動的nearest-rank第30、70百分位。門檻T=2.5*(波動<p30?0.7：波動>p70?1.3：1.0)。這是預設Adaptive模式；Conservative乘1.3，Aggressive乘0.7。

【做多】無持倉、分數>=1.2*T，且距上次進場至少5根K線、當日已平倉交易數<12，則於該根收盤進場做多。
【做空】無持倉、分數<=-1.2*T，且同樣的間隔與當日交易數限制成立，則於該根收盤進場做空。
（Conservative模式另加：做多需close>EMA20且30<RSI<70；做空需close<EMA20且30<RSI<70。）

【出場】以下以進場當根的ATR、K線與進場價E計算。
樞紐P=前一根(high+low+close)/3；R10=最近10根最高high-最低low。
多單：支撐=min(最近5根最低low, P-0.382*R10)；停損=max(E-1.5*ATR, 支撐)；停利=E+3*(E-停損)。
空單：壓力=max(最近5根最高high, P+0.382*R10)；停損=min(E+2*ATR, 壓力)；停利=E-3*(停損-E)。
追蹤停損：多單價格自進場價有利方向移動>=2*ATR後啟動，之後自最高價回落0.5*ATR即出場；空單方向相反（自最低價反彈0.5*ATR）。
多單：low<=停損或價格達停利時出場；空單：high>=停損或價格達停利時出場。
持倉超過100根K線則平倉。