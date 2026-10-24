【指標】TR=true range。ATR(n)=TR 的 RMA(n)。
(A)樞紐 SuperTrend(週期1、倍數1)：樞紐高=high[1] 為 high[2]、high[1]、high 三根最高時取 high[1]，樞紐低同理取 low[1]。本根有樞紐時（先看高、再看低）：center=首次取該值，之後 center=(center*2+樞紐)/3。Up=center-TR，Dn=center+TR。TUp=若前收>前TUp 則 max(Up,前TUp) 否則 Up。TDn=若前收<前TDn 則 min(Dn,前TDn) 否則 Dn。趨勢=close>前TDn 則 1；否則 close<前TUp 則 -1；否則沿用前值（初值1）。趨勢由 -1 變 1 為買點 a，由 1 變 -1 為賣點 a。
(B)SuperTrend：ATR(10)，src=(high+low)/2，倍數1。up=src-ATR，dn=src+ATR。up1=若前收>前up1 則 max(up,前up1) 否則 up。dn1=若前收<前dn1 則 min(dn,前dn1) 否則 dn。趨勢初值1：趨勢=-1 且 close>前dn1 轉1；趨勢=1 且 close<前up1 轉 -1。轉1為買點 b，轉-1為賣點 b。
(C)Chandelier(週期1、倍數1.5)：L=close-1.5*TR，若前收>前L 則 L=max(L,前L)。S=close+1.5*TR，若前收<前S 則 S=min(S,前S)。方向：close>前S 則 1；close<前L 則 -1；否則沿用（初值1）。轉1為買點 c，轉-1為賣點 c。
(D)Twin Range：sr(t,m)=EMA(EMA(|close-close[1]|,t),2t-1)*m。r=(sr(12,1)+sr(4,2))/2。濾線 f：若 close>前f，f=max(close-r,前f)；否則 f=min(close+r,前f)。up計數：f>前f 則+1，f<前f 則歸0，否則不變；down計數對稱。多條件=close>f 且 up計數>0；空條件=close<f 且 down計數>0。狀態=多條件?1:空條件?-1:沿用前值。買點 d=多條件且前一根狀態=-1；賣點 d=空條件且前一根狀態=1。
(E)RSI 帶 band(len)：ep=2*len-1，auc=EMA(max(close-close[1],0),ep)，adc=EMA(max(close[1]-close,0),ep)。x1=(len-1)*(adc*65/35-auc)，上帶=x1>=0?close+x1:close+x1*35/65。x2=(len-1)*(adc*40/60-auc)，下帶=x2>=0?close+x2:close+x2*60/40。len=10 得進場上、下帶；len=20 得 TP 上、下帶。
(F)WaveTrend：esa=EMA(hlc3,10)，d=EMA(|hlc3-esa|,10)，wt=EMA((hlc3-esa)/(0.015*d),10)。

【進場，僅在空手時判斷，優先順序如下】
1.做多(強)：本根與前1根（共2根）內，A、B、C、D 的買點出現次數合計>=2，且本根至少1個買點；近5根（含本根）內任一根 low<=該根進場下帶；近4根內任一根 wt<=-53。
2.做空(強)：本根與前1根內 A、B、C、D 的賣點次數合計>=2，且本根至少1個賣點；近5根內任一根 high>=該根進場上帶；近4根內任一根 wt>=53。
3.做多(趨勢)：未觸發做多(強)，且 close>EMA(close,7)，low<=進場下帶，近4根內任一根 wt<=-53。
4.做空(趨勢)：未觸發做空(強)，且 close<EMA(close,7)，high>=進場上帶，近4根內任一根 wt>=53。
進場價=收盤價。

【出場，進場後下一根起逐根判斷，先判停損】
停損價於進場時固定：強訊號做多=min(low[1],low[2])，強訊號做空=max(high[1],high[2])；趨勢做多=進場價-0.5*ATR(14)，趨勢做空=進場價+0.5*ATR(14)。
多單：close<=停損價則出場；否則 high>=當根 TP 上帶(len20) 則於該帶價位全部出場。
空單：close>=停損價則出場；否則 low<=當根 TP 下帶(len20) 則於該帶價位全部出場。