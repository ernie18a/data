【指標】ATR=ATR(14)。relVol=volume/SMA(volume,20)。ema9/21/100=收盤EMA。VWAP=hlc3的成交量加權均價。ADX=DMI(14,14)的ADX。RSI7=RSI(close,7)。ER=|close-close[10]|/Σ10根|close-close[1]|。均值ATR=SMA(ATR,50)。上升趨勢=ER>min(0.25*ATR/均值ATR,0.65)且close>close[10]。下降趨勢=ER>同一門檻且close<close[10]。

【做多條件，任一成立】
1. 主訊號：ema9>ema21>ema100，close>VWAP，ADX>25，RSI7在55到78之間且大於前一根，close>前5根最高價(不含當根)且close[1]>再前一根算起的5根最高價，close>前5根最高價+0.2*ATR，relVol>=1.2。
2. 向上BOS：close>前10根最高價(不含當根)且超出幅度>0.5*ATR，relVol>=1.3，close>open，且距上次BOS超過10根。
3. 順勢回測：上升趨勢，low<ema21且close>ema21，近期未形成更低的擺動低點(pivot低點3左3右)。另需下列6項至少2項成立：ADX>25、relVol>=1.2、close>VWAP、實體/(high-low)>0.3、ema9>ema21>ema100的簡化多頭(可略)、10根累積delta上升(無delta資料則略)。
4. 多方訂單塊：close>close[1]+1.5*ATR，close>open，relVol>=1.2，並在前20根內找到最近一根陰線；另需下列至少2項：low>high[2]、relVol>=1.5、close<VWAP。
5. 空頭陷阱(掃低)：low<前20根最低價(不含當根)且close>該最低價；下影線>0.6*ATR；下影線/實體>=1.2(實體為0視為成立)；relVol>=1.7；high-low>1.3*SMA(high-low,20)；下影線>SMA(下影線,20)+1.5*STDEV(下影線,20)。
6. OTE：20根最高最低價區間>2*ATR，且close落在自20根最高點回撤62%到79%之間。

【做多共同過濾】close>ema100+0.3*ATR且ema100>ema100[5]；已持空單時不做多。上述2到6項還要求不在區間頂部：位置=(close-前一根的90根最低)/(前一根的90根最高-最低)，在0到1之間且大於0.8則不做多。

【做空條件，與做多鏡像】
1. 主訊號：ema9<ema21<ema100，close<VWAP，ADX>25，RSI7在22到43之間且小於前一根，close<前5根最低價且close[1]<再前一根算起的5根最低價，relVol>=1.2。
2. 向下BOS：close<前10根最低價且超出幅度>0.5*ATR，relVol>=1.3，close<open，距上次BOS超過10根。
3. 順勢回測：下降趨勢，high>ema21且close<ema21，近期未形成更高的擺動低點；另需同樣至少2項鏡像確認：ADX>25、relVol>=1.2、close<VWAP、實體比>0.3。
4. 空方訂單塊：close<close[1]-1.5*ATR，close<open，relVol>=1.2，並在前20根內找到最近一根陽線；另需至少2項：high<low[2]、relVol>=1.5、close>VWAP。
5. 多頭陷阱(掃高)：high>前20根最高價且close<該最高價；上影線>0.6*ATR；上影線/實體>=1.2；relVol>=1.7；high-low>1.3*SMA(high-low,20)；上影線>SMA(上影線,20)+1.5*STDEV(上影線,20)。
6. OTE：區間>2*ATR，且close落在自20根最低點上漲62%到79%之間。

【做空共同過濾】close<ema100-0.3*ATR且ema100<ema100[5]；已持多單時不做空；位置在0到1之間且小於0.2則不做空；另要求空方動能：relVol>=1.5、close<open且實體>0.3*ATR、close<VWAP-0.5*ATR、ema21<ema21[5]，這幾項加上下降趨勢成立數量至少5(取自8項，缺資料項略過)。

【出場】
- 多單停損約在進場價下方2*ATR(最多3*ATR，最少1*ATR)；停利約在進場價上方1.8到3.6*ATR(最少5點)。空單鏡像，停損上方2*ATR，停利下方1.5到3*ATR。
- 多單型態出場(各算1分，原程式分數達門檻才出場)：high>high[1]且close<close[1]；當根陰線吞噬前一根(close<open，close<open[1]，open>close[1]，且實體大於前一根實體)；前一根relVol>=2.0且為陽線而當根為陰線；high<high[1]且close<open；上影線>1.5*實體且close<close[1]；出現多頭陷阱(掃高)；MACD(12,26,9)的MACD線<訊號線且柱狀圖<0且柱狀圖下降；向下BOS；空頭回測成立。
- 空單型態出場為鏡像：low<low[1]且close>close[1]；當根陽線吞噬前一根；前一根relVol>=2.0且為陰線而當根為陽線；low>low[1]且close>open；下影線>1.5*實體且close>close[1]；出現空頭陷阱(掃低)；MACD線>訊號線且柱狀圖>0且上升；向上BOS；多頭回測成立。
- 這些型態出場在持倉浮盈<0.1*進場ATR，或浮盈已從峰值回吐到峰值的約40%以下時才允許執行。