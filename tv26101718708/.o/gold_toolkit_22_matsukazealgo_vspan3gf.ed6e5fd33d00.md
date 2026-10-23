通用：ATR14=ta.atr(14)；RSI為Wilder RMA；lowest/highest含當根。各模組獨立，訊號以下為準，無反向訊號時持倉不另設出場（僅模組03有停損停利）。

[01 Supertrend] src=hlc3，atr=ATR(14)，m=1.5。up=src-m*atr，dn=src+m*atr；up=若close[1]>up[1]則max(up,up[1])否則up；dn=若close[1]<dn[1]則min(dn,dn[1])否則dn。dir初值1：dir=-1且close>dn[1]→1；dir=1且close<up[1]→-1。做多：dir由-1轉1，且距上次訊號≥8根，且過去50根內曾有RSI(14)<30。做空：dir由1轉-1，距上次訊號≥8根，且過去50根內曾有RSI(14)>70。

[02 掃流動性反轉] atr=ATR14，上緣U=highest(high[1],34)，下緣D=lowest(low[1],34)，R=max(high-low,mintick)，下影比lw=(min(o,c)-low)/R，上影比uw=(high-max(o,c))/R，收盤位置cl=(close-low)/R，實體比b=|c-o|/R，vr=volume/sma(volume,34)。多方掃描：(D-low)/atr=bp≥0.06且lw≥0.42；分數=min(100,lw*60+bp*30+vr*10)，分數≥46.2才記為待確認（記下D與low），之後確認時分數須≥66。空方掃描：sp=(high-U)/atr≥0.06且uw≥0.42，分數=min(100,uw*60+sp*30+vr*10)，同門檻，記下U與high。待確認狀態在掃描後5根內有效，新掃描覆蓋舊的（多方優先）。做多：待確認為多，且close≥記下的D，cl≥0.58，b≥0.17。做空：待確認為空，且close≤記下的U，cl≤0.42，b≥0.17。確認後清除待確認狀態。

[03 EMA反轉FVG] EMA21(f)、EMA55(m)、EMA200(s)。空頭態=close低於三線且|f-m|≥5；多頭態=close高於三線且|f-m|≥5。setS：空頭態且high≥f時=1，非空頭態時歸0。setL：多頭態且low≤f時=-1，非多頭態時歸0。多頭FVG：low>high[2]且close[1]>open[1]，記high[2]為level；空頭FVG：high<low[2]且close[1]<open[1]，記low[2]為level；各最多留20個。無持倉且距上次出場≥5根才可進場。做空：存在多頭FVG level使close<level（該level移除），且setS=1，且close<f。做多：存在空頭FVG level使close>level（移除），且setL=-1，且close>f。進場時H=highest(high,10)，L=lowest(low,10)。做空：停損H，停利L；high≥H或low≤L出場。做多：停損L，停利H；low≤L或high≥H出場。

[04 SAR] sar=ta.sar(0.02,0.02,0.2)。close>sar為多，否則為空。方向由空轉多→做多；由多轉空→做空。

[05 ACN] base=ema(wma(close,20),20)，sd=stdev(close,20)，coral=base+0.3*sd，上帶zh=coral+0.6*sd，下帶zl=coral-0.6*sd。做多：close上穿coral且close>zh。做空：close下穿coral且close<zl。

[06 Arc動能] rsi=RSI(5)，mom=ema(rsi-50,17)，u=stdev(mom,100)（bar_index>100且u有值才開始）。初始化：arc=mom-3.5u，趨勢tr=true。每根：buf=0.2u；mom<arc-buf→tr=false；mom>arc+buf→tr=true。tr改變時：變多arc=mom-3.5u，變空arc=mom+3.5u，vel=0。若bar_index%5==0：vel+=0.11，arc+=(tr?1:-1)*u*0.15*vel。做多：tr由false轉true。做空：tr由true轉false。另：RSI(5)≥70背景標空方色，RSI(5)≤30標多方色。

[18 非對稱趨勢] a=stdev(close,20)*1.5。ln初值close，d初值0。d≥0時：close>ln+0.3a→ln=max(ln,close-0.25a)、d=1；否則close<ln-a→ln=close+0.25a、d=-1。d<0時：close<ln-0.3a→ln=min(ln,close+0.25a)、d=-1；否則close>ln+a→ln=close-0.25a、d=1。做多：d由-1轉1。做空：d由1轉-1。

[16 RSI擺動結構] r=RSI(7)，超買r≥70，超賣r≤30。狀態st：r≥70後=1，r≤30後=2；hh/ll為持續更新的極值不影響訊號。新高擺動nH=（本根開始前st=2且r≥70）；新低擺動nL=（st=1且r≤30）。nH時：hh=lastH無值或high>lastH；ch=(hh且bias=-1)或(非hh且bias=1)；然後lastH=high，bias=hh?1:-1；ch成立→做多。nL時：hl=lastL無值或low>lastL；ch=(非hl且bias=1)或(hl且bias=-1)；然後lastL=low，bias=hl?1:-1；ch成立→做空。

[22 VWAP] 週別錨定（週轉換時累計歸零），vwap=Σ(hlc3*volume)/Σvolume。做多：close上穿vwap；做空：close下穿vwap。

[14 機構量] avg=sma(volume,20)，rv=volume/avg，高量hv=rv≥1.8，R=high-low，實體%=|c-o|/R*100，下影%、上影%同理。多K=hv且((實體%≥55且close>open)或(下影%≥45且close≥low+0.5R))；空K=hv且((實體%≥55且close<open)或(上影%≥45且close≤high-0.5R))。取最近15根（含當根）：tot=多K+空K根數，多比=多K數/tot*100，空比同理。做多：tot≥3且多比≥60且close>EMA200且上一根未成立。做空：tot≥3且空比≥60且close<EMA200且上一根未成立。

[17 OB] pivH=ta.pivothigh(high,7,1)有值：從j=2..20找最近一根close[j]>open[j]，若high[j]-low[1]≥1.3*ATR14且close<EMA20→做空。pivL=ta.pivotlow(low,7,1)有值：找最近close[j]<open[j]，若high[1]-low[j]≥1.3*ATR14且close>EMA20→做多。

[19 向量SMC] avgV=sma(volume,10)，clx=volume*(high-low)，vec=volume≥1.5avgV或clx≥highest(clx,10)。pivot(5,5)最近擺動低lSL、擺動高lSH（擺動點確認時更新）。做多：vec[1]且close[1]<open[1]且low[1]<lSL且close>open[1]。做空：vec[1]且close[1]>open[1]且high[1]>lSH且close<open[1]。另FVG色塊：vec且low>high[2]且low-high[2]>0.05ATR14標多；vec且high<low[2]且low[2]-high>0.05ATR14標空。

[12 FVG] 多：low>high[2]且low-high[2]>0.1*ATR14→做多；空：high<low[2]且low[2]-high>0.1*ATR14→做空。

[08 SwingRegress] lPH/lPL=最近已確認pivot(10,10)的高/低。趨勢tr初值0。CHoCH多：tr≤0且close[1]>lPH→做多，tr=1；CHoCH空：tr≥0且close[1]<lPL→做空，tr=-1。BOS標示：tr=1且close[1]>lPH標多；tr=-1且close[1]<lPL標空。

[09 通道] pivot(30,30)高低點交替成段：新pivot與上一pivot類型不同、相距≥8根、價差≥2.5*ATR14才接受為新起點，否則保留舊起點；起點為高→巨觀方向下，為低→上。巨觀通道：起點到close[1]的直線，base=起點價+斜率*(bar_index-起點bar)，寬hw=max(1.1*段內high/low對直線最大偏離, ATR14)，上緣=base+hw，下緣=base-hw。微觀通道：近20根close線性回歸，回歸線末端值±2*殘差標準差(sqrt(SSres/18))為上下緣，R²≥0.2才有效。同類訊號間隔≥15根。突破(BRK)：巨觀下且close上穿巨觀上緣→做多；巨觀上且close下穿巨觀下緣→做空。回測(PB)：巨觀上、close≤下緣+0.2ATR14且≥下緣、前一根不在該區→做多；巨觀下、close≥上緣-0.2ATR14且≤上緣、前一根不在該區→做空。延續(CONT)：段起點距今3~25根、R²有效；巨觀上且close上穿微觀上緣→做多；巨觀下且close下穿微觀下緣→做空。

[11 諧波] pivot(5,5)，保留最近20高20低，每10根掃描一次；容差t=15%，inR(v,lo,hi)=lo*0.85≤v≤hi*1.15。多方：依時間序X低<A高<B低<C高<D低，A>X，B<A，C<A，D<C；xa=A-X，ab=(A-B)/xa，bc=(C-B)/(A-B)，xd=(A-D)/xa。依序判定：Bat(ab.382~.5, bc.382~.886, xd.786~.886)；Gartley(ab.618, bc.382~.886, xd.786)；Butterfly(ab.786, bc.382~.886, xd1.27~1.618)；Crab(ab.382~.618, bc.382~.886, xd1.618)；Shark(ab.382~.618, bc1.13~1.618, xd.886~1.13)；符合任一且該D未追蹤過→做多。空方鏡像：X高、A低、B高、C低、D高，A<X，B>A，C>A，D>C；xa=X-A，ab=(B-A)/xa，bc=(B-C)/(B-A)，xd=(D-A)/xa；僅Bat/Gartley/Butterfly/Crab，符合→做空。

[10 支撐壓力區] pivot(15,8)；以0.9*ATR(50)內的同側pivot聚類（成員間隔≥20根、≥2個），中心=加權平均，區間=中心±0.25*ATR(50)；低點成支撐區，高點成壓力區；close跌破支撐區下緣或突破壓力區上緣視為失效。做多：有效支撐區，low≤上緣且close≥下緣且close≥open。做空：有效壓力區，high≥下緣且close≤上緣且close≤open。同一區中心近期已發訊號則不重複。再測：壓力區被突破後30根內，low≤上緣、close≥下緣、close≥open→標多；支撐區被跌破後30根內，high≥下緣、close≤上緣、close≤open→標空。