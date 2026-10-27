【定義】RSI(x,n)=Wilder RMA 算法，平均跌幅為0時=100、平均漲幅為0時=0。CCI(x,n)=(x-SMA)/(0.015×平均絕對離差)。crossover(a,b)=a>b 且 前一根 a<=b；crossunder 反之。Stoch(x,n)=(x-n根最低)/(n根最高-n根最低)×100，收高低用 close/high/low。

【實際進出場】
多條件L = FL5 或 FL2 或 FL6；空條件S = (FS5 且 FS2) 或 FS6。
- FL2：r=以 RMA(20) 算的 RSI(close)，e=EMA(r,40)；成立條件 r+1.8>e。FS2：r-1.8<e。
- c=CCI(close,2)，m=EMA(c,2)，實體濾網=|open-close|<=0.2。
- 低檔上穿 = crossover(c,m) 且 c[1]<-55 且實體濾網成立。高檔下穿 = crossunder(c,m) 且 c[1]>65 且實體濾網成立。
- FL6 = RSI(close[1],2)<33 且 低檔上穿。FS6 = RSI(close[1],2)>67 且 高檔下穿。
- HalfTrend(振幅1、通道偏差2)：狀態 trend(0=多,1=空)、nextTrend 初始0；maxLow 初值=前一根low，minHigh 初值=前一根high。每根：若 nextTrend==1，則 maxLow=max(low,maxLow)；若 high<maxLow 且 close<前一根low，則 trend=1、nextTrend=0、minHigh=high。否則 minHigh=min(high,minHigh)；若 low>minHigh 且 close>前一根high，則 trend=0、nextTrend=1、maxLow=low。trend 由1變0=翻多，由0變1=翻空。
- FL5 = 低檔上穿 且 最近一次 HalfTrend 翻轉為翻多 且 翻轉不在當根。FS5 = 高檔下穿 且 最近一次翻轉為翻空 且 翻轉不在當根。
- 出場旗標 ExitL = 空方分數(見下)>=6 且 k<d；ExitS = 多方分數>=6 且 k>d。k=EMA(Stoch(RSI(close,21),21),3)，d=EMA(k,3)。
- 做多：L 且非 ExitL；做空：S 且非 ExitS；持反向倉時進場即反手。
- 多單平倉：ExitL 且非 L；空單平倉：ExitS 且非 S。

【多空分數】逐項成立才加權重，總和>=6 即成立，多空各算一份。
多方：
- 2：close>EMA200
- 2：EMA21>前一根EMA21 且 EMA55<前一根EMA55
- 4：Supertrend(ATR週期10、倍數3)由下降翻為上升
- 3：SAR(0.02,0.01,0.2)<close 且 前一根SAR>前一根close
- 1：HMA100<close，其中 HMA(n)=WMA(2×WMA(c,n/2)-WMA(c,n),floor(√n))
- 3：HMA100>前一根 且 前一根<前兩根
- 4：當根或前2根內出現 RSI(14) 看漲背離
- 1：RSI14 >50 且(前1根或前2根<50)
- 1：MACD(12,26,9)柱狀 hist>前一根 且 前一根<前兩根 且 hist<0
- 1：macd>signal 且 前一根macd<前一根signal 且 signal<0
- 4：wt1>wt2 且 前一根wt1<前一根wt2 且 wt2<-10
- 1：Stoch看漲背離
- 1：k14>d14 且 前一根k14<前一根d14
- 1：ATR追蹤停損翻多
- 3：rvi>25 且 前一根rvi<40
- 4：RVI看漲背離
- 4：關鍵位上穿
空方為鏡像：close<EMA200→2；EMA21下降且EMA55上升→2；Supertrend翻空→4；SAR>close 且 前一根SAR<前一根close→3；HMA100>close→1；HMA100<前一根 且 前一根>前兩根→3；RSI看跌背離→4；RSI14 <50 且(前1根或前2根>50)→1；hist<前一根 且 前一根>前兩根 且 hist>0→1；macd<signal 且 前一根macd>前一根signal 且 signal>0→1；wt1<wt2 且 前一根wt1>前一根wt2 且 wt2>10→4；Stoch看跌背離→1；k14<d14 且 前一根k14>前一根d14→1；ATR追蹤停損翻空→1；rvi<75 且 前一根rvi>60→3；RVI看跌背離→4；關鍵位下穿→4。
其餘各項權重為0，不計。

分數用到的指標算法：
- WaveTrend：ap=(H+L+C)/3，esa=EMA(ap,9)，d=EMA(|ap-esa|,9)，ci=(ap-esa)/(0.015×d)，wt1=EMA(ci,12)，wt2=SMA(wt1,4)。
- Stoch k14=SMA(Stoch(close,14),3)，d14=SMA(k14,3)。
- RVI：sd=STDEV(close,12)；up=EMA(change(close)<=0?0:sd,14)；dn=EMA(change(close)>0?0:sd,14)；rvi=up/(up+dn)×100。
- ATR追蹤停損：tr=1.85×真實波幅(ATR長度1)；longStop=high-tr，若前一根close>前一根longStop 則 longStop=max(longStop,前一根longStop)；shortStop=low+tr，若前一根close<前一根shortStop 則 shortStop=min(shortStop,前一根shortStop)；dir 初值1，close>前一根shortStop→1，close<前一根longStop→-1，否則維持。dir由-1變1=翻多，由1變-1=翻空。
- 背離(左6右2根)：以該振盪值的樞紐點(osc[2]為前6後2根內的極值)確認當根。看跌：osc樞紐高點，osc[2]<前一個樞紐高點的osc[2]，兩樞紐相距5~60根，且 high[2]>前一個樞紐高點的high[2]。看漲：osc樞紐低點，osc[2]>前一個樞紐低點的osc[2]，相距5~60根，且 low[2]<前一個樞紐低點的low[2]。
- 關鍵位：以 close 求樞紐。快速樞紐高/低(左200右5)取最近一個，記為 level1、level2。一般樞紐高(左200右20)取最近三個，記為 level3、5、7。一般樞紐低取最近三個，記為 level4、6、8。HMA9 上穿任一 level(HMA9>level 且 前一根HMA9<前一根level)且 close>close[2]，為上穿；HMA9 下穿任一 level 且 close<close[2]，為下穿。

【標示多空的圖形】
- 弱訊號三角：多方分數>=6 標多、空方分數>=6 標空，逐根判斷。
- 強訊號 LONG/SHORT 標籤：持倉狀態 pos 初值0；多分數>=6 且 pos<=0 則 pos=1；接著空分數>=6 且 pos>=0 則 pos=-1。pos 轉為1的那根標多，轉為-1的那根標空。若啟用只順勢交易，標多需 EMA200>前一根，標空需 EMA200<前一根。
- 止損警示標籤：多單 close 由上往下穿越 進場價×0.975 標出場；空單 close 由下往上穿越 進場價×1.025 標出場。
- Stoch-CCI 區域填色：k=SMA(Stoch(CCI(close,20),20),7)，ma=SMA(k,3)。ma<20 為多區，ma>80 為空區。
- 線色：close>HMA100 為多色，反之為空色；EMA9/21/55/100/200 上升為多色，下降為空色。