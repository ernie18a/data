【共用指標】ATR=14期Wilder ATR；EMA20、EMA200；RSI14；相對量=volume/SMA(volume,20)；實體比=|close-open|/(high-low)；S高=最近24根(不含當根)最高high，S低=最近24根(不含當根)最低low；EQ=(S高+S低)/2；ATR均=SMA(ATR,24)。
【壓縮結構(用上一根的值判斷)】區間=S高-S低；前區間=high[25..48]最高-low[25..48]最低；成立條件：區間<前區間*0.78 且 ATR<ATR均 且 區間/ATR在2~14，且(下降高點 或 上升低點)。下降高點=linreg(high[1],24,0)-linreg(high[1],24,1)<0；上升低點=linreg(low[1],24,0)-linreg(low[1],24,1)>0。

【做多】任一成立：
A 趨勢回拉：close>EMA200 且 EMA20>EMA20[3]；最近8根內(含當根)曾low<=EMA20；close>EMA20、close>open、close>前根high；RSI>=50、實體比>=0.35、相對量>=0.85。
B 掃低反轉：上一根壓縮結構成立；low<S低-0.15*ATR 且 close>S低 且 close>open；距上次任一方向假突破至少6根。
C 突破：上一根壓縮結構成立，close>S高+0.12*ATR 且前根close<=前根S高+前根0.12*ATR，且多方分數>=65；(C1)當根實體比>=0.7且相對量>=1.3則直接進場；(C2)否則記下突破位=S高，之後1~10根內出現 low<=突破位+0.35*ATR 且 low>=突破位-0.75*ATR 且 close>突破位 且 close>open 時進場；期間close<突破位-0.5*ATR或超過10根或出現反向突破則取消。
多方分數(0~100)=(close>EMA200:8)+(EMA20>EMA20[3]:7)+(EMA200>EMA200[10]:5)+(close>=最近50低+5*ATR且close>EMA20:10)+(效率比>=0.25:5，>=0.15:3；效率比=|close-close[50]|/近50根|close差|總和)+(區間收縮:6)+(ATR收縮:5)+(寬度合格:4)+(下降高點且上升低點:10)+(壓縮成立:5)+(突破條件:8)+(多頭強K:4，即close>open、實體比>=0.45、close>=high-0.25*振幅)+(close>S高+0.25*ATR:3)+(RSI在50~78:5)+5+(low<S低且close>S低:4)+(close<EQ:3)+(|close-EQ|<=0.5*ATR:4)。
共同過濾：close>S高 或 S高-close>=ATR；空手；距上次進場>=3根。

【做空】完全鏡像：
A close<EMA200 且 EMA20<EMA20[3]；最近8根內曾high>=EMA20；close<EMA20、close<open、close<前根low；RSI<=50、實體比>=0.35、相對量>=0.85。
B 掃高反轉：上一根壓縮結構成立；high>S高+0.15*ATR 且 close<S高 且 close<open；假突破間隔>=6根。
C 向下突破：close<S低-0.12*ATR 且前根close>=前根S低-前根0.12*ATR，空方分數>=65(各項鏡像：close<EMA200、EMA20下降、EMA200下降、close<=最近50高-5*ATR且close<EMA20、空頭強K close<=low+0.25*振幅、RSI在22~50、high>S高且close<S高、close>EQ、close<S低-0.25*ATR)；實體比>=0.7且相對量>=1.3直接進，或回測：1~10根內 high>=突破位-0.35*ATR 且 high<=突破位+0.75*ATR 且 close<突破位 且 close<open；close>突破位+0.5*ATR取消。
共同過濾：close<S低 或 close-S低>=ATR。

【出場】進場價=進場K的close。
初始停損：多=min(close-1.7*ATR, 近10根最低low, (C類用突破位，否則S低)-0.25*ATR)；空=max(close+1.7*ATR, 近10根最高high, (C類用突破位，否則S高)+0.25*ATR)。R=|進場價-停損|。
停利：多=進場價+R*{1,2,3,4.5}，空=進場價-R*{1,2,3,4.5}，依序在TP1、TP2、TP3各出25%，剩餘25%在TP4出清。
移動停損：多單high>=TP1後，停損=max(停損, 進場價+0.05*ATR)；high>=TP2後再用 max(停損, close-2*ATR) 上移。空單鏡像(low<=TP1後停損=min(停損, 進場價-0.05*ATR)；low<=TP2後 min(停損, close+2*ATR))。多單low<=停損、空單high>=停損即全部出場。
結構破壞全出：多單close<S低，空單close>S高。
提前減碼警示(TP1達成後，每出現一個新警示升一級：減25%→減75%→全出)：多單警示=上一根壓縮成立且high>S高+0.15*ATR且close<S高且close<open的假突破、close下穿EMA20、獲利中且連續兩根volume<SMA(volume,20)且當根收黑、近5根陽線量總和*1.3<陰線量總和；空單鏡像(假突破=low<S低-0.15*ATR且close>S低且close>open、close上穿EMA20、獲利中連續兩根低量且收紅、近5根陽線量>陰線量*1.3)。