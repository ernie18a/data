【定義】TK=(9根最高+9根最低)/2；KJ=(26根最高+26根最低)/2；SB=(52根最高+52根最低)/2；SA=(TK+KJ)/2；雲上緣=max(SA,SB)往前25根的值，雲下緣=min(SA,SB)往前25根的值。以下皆逐根比較，預設用狀態式（條件成立即為訊號），若採交叉模式則改用上穿/下穿。

【做多/做空進場，可擇一或多個以OR組合】
1 Ichimoku：close>KJ多/<KJ空；close>雲上緣多/close<雲下緣空；SA>SB多/<空；close>high[25]多/close<low[25]空；close>雲上緣[25]多/close<雲下緣[25]空；close>TK多/<空；TK>雲上緣多/TK<雲下緣空；TK>KJ多/<空。
2 B1多：TK>=KJ、high>雲上緣、close>high[25]、close>雲上緣[25]、SA>SB全成立；S1空：TK<=KJ、low<雲下緣、close<low[25]、close<雲下緣[25]、SA<SB。B2多＝B1前三項(TK>=KJ、high>雲上緣、close>high[25])；B2空＝S1前三項。
3 K線：close>high[1]多/close<low[1]空；high>high[1]多/low<low[1]空；low>low[1]多/high<high[1]空；每根K都可多空。內包線：high[1]<high[2]且low[1]>low[2]，close>high[1]多/close<low[1]空。外包線：high[1]>high[2]且low[1]<low[2]，high>high[1]多/low<low[1]空。三明治：high[2]<high[3]且low[2]>low[3]且high[1]>high[2]且low[1]<low[2]，high>high[1]多/low<low[1]空。
4 Pin bar：實體=|open-close|，上影=high-max(open,close)，下影=min(open,close)-low。空：((high-open>0.6*實體且close<open)或(high-close>0.6*實體且close>open))且high>high[1]且上影>下影。多：((open-low>0.6*實體且close>open)或(close-low>0.6*實體且close<open))且low<low[1]且上影<下影。
5 反轉分形：空＝[high>前3根high且陰線且前一根陽線]或[high[1]>其前4根high且high[1]>=high且陰線且前一根陽線]或[high[1]>其前4根high且high[1]>=high且high<high[1]且陽線且前一根陽線]。多為鏡像（low取代high、陰陽互換、low>low[1]且連兩根陰線）。
6 分形：以左右各2根的高低點為分形；high>最近上分形高點多，low<最近下分形低點空。分形趨勢線：連最近兩個上分形高點外推到當根，high>線值多；連最近兩個下分形低點外推，low<線值空。
7 Segments：前一根已出現連續三段墊高低點（每段在10根內找到較低的舊低點，且當時low>low[1]）且本根high>high[1]多；對稱的三段壓低高點且low<low[1]空。
8 DMI(10,10)得DI+、DI-、ADX：古典：DI+>DI-且ADX>25多/DI+<DI-且ADX>25空；修正：DI+>DI-且DI-<ADX<DI+多/DI+<DI-且DI+<ADX<DI-空；ADX斜率：ADX上升(>前值)且DI+>DI-、前一根不滿足時才多；ADX上升且DI+<DI-、前一根不滿足時才空。
9 close[2]>SMA50多/close[2]<SMA50空；EMA10上穿EMA20多/下穿空；RSI14>50多/<50空；SAR(0.02,0.02,0.2)：high>SAR多/low<SAR空；SuperTrend(ATR長6、倍數3)：high>線多/low<線空。
10 斜率轉向：TRIX(10)=10000*ln(close)三重EMA(10)的一期變化；HMA(100)；ALMA(9,0.85,6)；MACD(12,26,9)的MACD線。指標對前一根上升且前一根未上升→多；下降且前一根未下降→空。
11 CB/CS綜合分數＝下列19項相加：EMA21>SMA20=1、<=0；SMA50>SMA200；EMA50>EMA200；high>KJ=1、low<KJ=0；TK>KJ；B1=1、S1=0；B2=1、S2=0；high>=SAR=1、low<=SAR=0；high>最近上分形=1、low<最近下分形=0；MACD線>訊號線；RSI14>50；DI+>DI-(DMI 7,7)；Klinger訊號線>0(sv=hlc3上升?volume:-volume，EMA34-EMA55，再EMA13)；Vortex(14) VI+>VI-(VMP=Σ|high-low[1]|，VMM=Σ|low-high[1]|，除以Σ ATR(1)，皆14根)；high>SuperTrend(5,2)=1、low<線=0；high>TK=1、low<TK=0；HMA(15)上升=2否則-1；ALMA(9,0.85,6)上升=2否則-1；MACD線上升=1否則0。各項（有雙條件者）兩條件皆不成立時沿用前值。分數>12做多，<8做空。
12 IB/IS分數＝下列11項相加（雙條件皆不成立時沿用前值）：TK>雲上緣=1、TK<雲下緣=0；close>high[25]=1、close<low[25]=0；close>雲上緣[25]=1、close<雲下緣[25]=0；high>TK=1、low<TK=0；high>KJ=1、low<KJ=0；TK>KJ；SA>SB；high>雲上緣=1、low<雲下緣=0；close>KJ[25]；close>TK[25]；KJ>雲上緣=1否則0。分數>5做多，<5做空。

【進場過濾（最多兩個，AND）】做多須對應多方條件成立、做空須空方條件成立，可用上述1、2、3(K線突破類)、5、6、7、9、10的水平條件（斜率類用「對前一根上升」為多、否則為空；SMA/EMA/RSI/SAR/SuperTrend用水平比較），另有：MACD>訊號線多/<空；ADX>25（多空皆需）；DMI：DI+>DI-多/DI+<DI-空；RSI Stoch：RSI14取14根隨機值，K=3SMA，D=3SMA(K)，多＝K>20且D>20且非(K<D且K<80且D<80)，空＝K<80且D<80且非(K>D且K>80且D>80)。

【出場】多單遇下列任一（OR）出場，空單遇鏡像條件出場，出場條件成立時同方向不進場；反向進場訊號也平倉反手：陰線(close<open)；反轉分形空；low<low[1]；close[1]下穿SMA50；MACD線下穿訊號線；MACD線斜率剛轉下降；RSI14下穿50；RSI Stoch空條件；TRIX/HMA(100)斜率剛轉下降；EMA10下穿EMA20；low下穿最近下分形低點；low下穿SuperTrend(5,2)；low下穿SAR；ADX(10,10)下穿25（多空皆是）；low下穿雲下緣；low下穿KJ；IB/IS空條件由不成立轉成立。空單出場對應：陽線；反轉分形多；high>high[1]；close[1]上穿SMA50；MACD上穿；斜率剛轉上升；RSI上穿50；high上穿最近上分形；high上穿SuperTrend/SAR/雲上緣/KJ；IB/IS多條件剛成立等。