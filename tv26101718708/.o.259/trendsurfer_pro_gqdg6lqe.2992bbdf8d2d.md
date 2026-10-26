【共用定義】EMA750=ema(close,750)。MT全多=EMA4>EMA5 且 RSI14>50 且 close>EMA21、SMA50、EMA55、EMA89、EMA750；MT全空為全部反向。StochK=sma(stoch(close,high,low,10),3)。多單進場預設都要求 close>EMA750 且 MT全多（現K線）；空單要求 close<EMA750 且 MT全空。以下進場訊號只列各自的額外條件，多空對稱。

【做多/做空進場（任一成立即可）】
1 主趨勢：EMA4上穿EMA5（空：下穿）、RSI14>50（空<50）、close>EMA21、SMA50、EMA55、EMA89、EMA750（空：全部<），且需 StochK>52 或 close上穿EMA89 或當根為多頭吞噬（空：StochK<48 或 close下穿EMA89 或空頭吞噬）。
吞噬定義：多頭吞噬=前K收<開、當K收>開、當K開<=前收、當K收>=前開，且 close>EMA750；空頭吞噬=前K收>開、當K收<開、當K開>=前收、當K收<=前開，且 close<EMA750。吞噬K本身也指向其方向（多頭吞噬→做多、空頭吞噬→做空）。
2 三角訊號：平滑線 bfr 由 6 次指數平滑得出：c1=2/1.5，c2=1-c1；i1=c1*close+c2*i1[1]，i2=c1*i1+c2*i2[1]，…依序到 i6；bfr=-i6+6*i5-12*i4+8*i3。bfr>前值視為綠、<前值為紅，否則藍。做多：顏色剛由非綠變綠、close>open、close>EMA25、StochK>50、成交量比分數>=6（分數=clamp(round(volume/sma(volume,20)*5),1,10)）。做空：顏色剛變紅、close<open、close<EMA25、StochK<50、分數>=6。
3 流動性掃蕩：用 pivothigh/pivotlow(長度5左5右，右側5根確認)取最近擺動高 SH、低 SL。做多：low<SL 且 close>SL，或前一根close<SL 且當根close>SL。做空：high>SH 且 close<SH，或前一根close>SH 且當根close<SH。
4 訂單塊反應：Δ=close-close[1]，z=(Δ-sma(Δ,20))/stdev(Δ,20)。多頭衝擊K：z>1.5、close>open、close大於前5根收盤最高值、close>EMA750；其前1~5根中取最低 low 的那根，其[low,high]為多頭區（該low需>EMA750；close<區下緣或存活超過100根則失效）。之後某K low落在區內、close>open、(close-low)>區高度*50%、close>EMA750 → 做多。空頭鏡像：z<-1.5、close<open、close小於前5根收盤最低值、close<EMA750；取前1~5根最高 high 那根為空頭區（high需<EMA750；close>區上緣失效）；某K high落在區內、close<open、(high-close)>區高度*50%、close<EMA750 → 做空。
5 Butterworth拒絕：BF=2階Butterworth(長度20,close)：a=exp(-√2π/20)，b=2a*cos(√2π/20)，BF=b*BF[1]-a²*BF[2]+((1-b+a²)/4)*(close+2close[1]+close[2])。做多：close>open、low<=BF、min(open,close)>BF、close>EMA5。做空：close<open、high>=BF、max(open,close)<BF、close<EMA5。
6 VIDYA拒絕：m=close變化；P=近20根max(m,0)總和，N=近20根max(-m,0)總和；cmo=|100*(P-N)/(P+N)|；k=(2/11)*cmo/100；v=k*close+(1-k)*v[1]（初值0）；VIDYA=sma(v,15)。條件同第5項（BF換成VIDYA，EMA5）。
7 EMA750拒絕：做多：close>open、low<=EMA750、min(open,close)>EMA750。做空：close<open、high>=EMA750、max(open,close)<EMA750。
8 主趨勢線拒絕/首次觸碰：記錄第1項訊號K的 open 為水平線，之後25根內有效。做多：low<=線、open>線、close>線、close>EMA750；做空：high>=線、open<線、close<線、close<EMA750。首次觸碰：low<=線<=high 的第一根，close>EMA750 做多、close<EMA750 做空。
9 SuperTrend翻轉：supertrend(因子2,ATR10)方向由下降轉為上升→做多；由上升轉為下降→做空。
10 異常止盈：見下方 TP空訊號且close>EMA750 → 做多；TP多訊號且close<EMA750 → 做空。

【出場（止盈）】分數為下列5項同時成立（需5項全部）。多方TP：RSI25>55；K=sma(stoch(close,high,low,14),3)、D=sma(K,3)，K下穿D且K>80；supertrend(3,ATR10)為上升趨勢；CCI20>100；close>close[5]。空方TP：RSI25<45；K上穿D且K<20；supertrend為下降趨勢；CCI20<-100；close<close[5]。多方TP成立（空方TP不成立時才算空方）→ 多單出場；空方TP成立 → 空單出場。close>=EMA750的多方TP、close<=EMA750的空方TP另需MT全多/MT全空；異常TP（多方TP在close<EMA750、空方TP在close>EMA750）不受MT過濾。