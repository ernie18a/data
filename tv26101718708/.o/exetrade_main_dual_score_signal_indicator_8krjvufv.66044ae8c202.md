【基礎】ATR=ATR(14)。ADX/DI=DMI(14,14)。EMA/SMA 依 close。KAMA(n)：ER=|close-close[n]|/Σ|close-close[i]|(i=1..n)，sc=(ER*(2/3-2/31)+2/31)^2，kama+=sc*(close-kama)，n=10、21。MACD(12,26,9)。RSI(14)。一目均衡表：tenkan(9)、kijun(26)、senkouA=(tenkan+kijun)/2、senkouB=(52 高低中點)；雲頂/雲底=senkouA、senkouB 往前 26 根的最大/最小值。above_cloud=close>雲頂，below_cloud=close<雲底。uptrend=EMA50>EMA200，downtrend=EMA50<EMA200。adx_ranging=ADX<20。mult_trend=ADX>=30 取1.5、ADX>=20 取1.0、否則0.5。mult_sr=ADX>=30 取0.7、ADX>=20 取1.0、否則1.5。
【最佳均線】14 條均線：SMA/EMA 各取 8、13、20、50、100、200，加 KAMA10、KAMA21。對每條均線，close 由下往上穿越時平空並做多(價差累計)，由上往下穿越時平多並做空。選多方累計獲利最大者為 BL，選空方累計獲利最大者為 BS。
【RSI 背離】RSI 以左右各5根找轉折低/高點。價格低點比前一個轉折低更低、但 RSI 低點更高，視為看漲背離 PD。價格高點更高、但 RSI 高點更低，視為看跌背離 ND。
【BB 擠壓】BB(20,2)。bbwidth=4*stdev(close,20)。bbwidth/ATR<1.5 為擠壓。前一根在擠壓、本根解除，且 close>SMA20 為向上擠壓突破；close<SMA20 為向下擠壓突破。
【支撐壓力】轉折低/高以左右各10根找出。與既有水平相距 <0.3ATR 者視為同一水平，最多保留5個。最近的轉折低為 nearest_sup，最近的轉折高為 nearest_res。below_support=close<nearest_sup-0.1ATR，above_resistance=close>nearest_res+0.1ATR。
【多方分數】
A(上限30)：close>BL 加8；uptrend 加7；KAMA10 比上一根高加5；MACD線>訊號線加5；above_cloud 加5。
B：HTF 最近壓力距離>1% (或無壓力) 加10；close>fib38.2 加8 (fib 以左右各15根的最近轉折高低點為0/100)；above_cloud 加7；close 與最近支撐距離<2ATR 加5；close>上升趨勢線加8；觸及上升通道下緣加7；下降趨勢線被突破加10 (同時有 PD 再加5)；觸及通道上緣減5；向上擠壓突破加10；below_support 減15。B 限制在 0~40。
C(上限20)：RSI<70 加7；PD 加8。
D(上限20)：HTF(較高週期，日線以上)EMA50>EMA200 加10；HTF RSI<70 加5；close 高於 HTF 雲加5；HTF 量>1.2×20均量加3，<0.8× 則減3。
E：以多方 R:R 計算。R:R=(最近壓力-0.2ATR-close)/(close-(最近支撐低點-1ATR))。R:R<=3 時 E=clamp((R:R-1)*5,-5,10)；R:R>3 時 E=min(30,10+(R:R-3)*4)。
多方分數=clamp(A*mult_trend+B*mult_sr+C+D+E,0,100)。
【空方分數】對稱：close<BS 加8；downtrend 加7；KAMA10 下降加5；MACD線<訊號線加5；below_cloud 加5。B：HTF 最近支撐距離>1% 加10；close<fib61.8 加8；below_cloud 加7；最近壓力距離<2ATR 加5；close<下降趨勢線加8；觸及通道上緣加7；上升趨勢線被突破加10 (同時有 ND 再加5)；觸及通道下緣減5；向下擠壓突破加10；above_resistance 減15。C：RSI>30 加7；ND 加8。D：HTF EMA50<EMA200 加10；HTF RSI>30 加5；close 低於 HTF 雲加5；量規則同多方。E 以空方 R:R 計算。
【近距閘門】close 上方 0.5ATR 內(空方為下方)若有壓力(支撐)，則多方分數(空方分數)扣掉這些水平的分數總和，最低為0。
【反彈加分】sup_bounce=最近支撐存在，且 low<=最近支撐+0.2ATR，且 close>最近支撐，且非 below_support。sup_bounce 加15。下影線>2×實體、close>=open 且 sup_bounce (看漲 pin bar)，或陽線吞沒前一根陰線且 sup_bounce，加5。sup_bounce 且多方 R:R>=2 加10。PD 的連續次數相對歷史平均的比例>=1.5 加10，>=1.0 加7，>=0.7 加3。多方加分合計為 bonus_l。空方對稱 (res_bounce、上影線、ND)，合計為 bonus_s。
【做多】用前一根已收盤的分數(L_lock、S_lock)。diff=L_lock-S_lock。
強多 strong_buy：L_lock+bonus_l>=90，ADX>=15，diff>=10，非 below_support，且 HTF 最近壓力距離>1% (或無壓力)。
普通多 normal_buy：L_lock+bonus_l>=75，非 strong_buy，ADX>=20，diff>=10，非 below_support，且 HTF 最近壓力距離>1%。
區間多 range_buy：多方 R:R>=3，且符合以下任一：10根內出現過 PD；sup_bounce；close<=BB下緣+0.2ATR；觸及通道支撐；RSI<30 且 ADX<25；ADX<30 且 RSI 在 30~50 之間。
【做空】與做多對稱：S_lock+bonus_s>=90 且 ADX>=15 且 diff<=-10 為強空；>=75 且 ADX>=20 且 diff<=-10 為普通空。兩者都須非 above_resistance，且 HTF 最近支撐距離>1%。區間空要求空方 R:R>=3，且符合以下任一：10根內出現過 ND；res_bounce；close>=BB上緣-0.2ATR；觸及通道壓力；RSI>70 且 ADX<25；ADX<30 且 RSI 在 50~70 之間。
預設只有強多、強空會進場 (普通與區間可由開關啟用)。
【出場(持倉至少4根後才可出場)】多單：low<=追蹤止損，出場價為追蹤止損價；出現 strong_sell，以 close 平倉。空單：high>=追蹤止損，出場價為追蹤止損價；出現 strong_buy，以 close 平倉。
追蹤止損：多單的初始止損=最近支撐低點-1ATR，若無支撐則為 close-2ATR。ATR 追蹤線=持倉以來最高 high-3ATR-1ATR。止損取兩者較大者，且只能上移。空單對稱：初始止損=最近壓力高點+1ATR (無則 close+2ATR)；追蹤線=最低 low+3ATR+1ATR，止損取較小者，只能下移。
多單浮盈 >= 初始風險(進場價-初始止損)後，改以更近的下一個支撐低點-1ATR 當止損，條件是 K 線最近兩根的最低價高出該止損至少一個初始風險；空單對稱。
反向訊號：持多時出現反向強訊號即平倉並反手；持空時出現強多訊號即平倉並反手。