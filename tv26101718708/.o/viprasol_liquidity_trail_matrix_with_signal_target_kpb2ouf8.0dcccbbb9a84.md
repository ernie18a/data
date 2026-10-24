【指標】ATR13=ATR(13)（RMA）；ATR14=ATR(14)。RSI14=RSI(close,14)。SMA50=SMA(close,50)。ADX=ta.dmi(14,14)的ADX。倍數 m1..m4=4,5,6,7。
【趨勢帶，逐根遞推，初始 trend=多】上軌k=close-ATR13*mk，下軌k=close+ATR13*mk（k=1..4）。trend=多時：若 close<前一根 ts3 則翻空，並令 tsk=下軌k；否則 tsk=max(上軌k, 前一根tsk)。trend=空時：若 close>前一根 ts3 則翻多，並令 tsk=上軌k；否則 tsk=min(下軌k, 前一根tsk)。翻轉當根為 flip 根。barsInTrend=距最近一次翻轉的根數。bar_index>=60 才允許出訊號。
【RSI 體制】bull原始=close>SMA50 且 40<=RSI14<=80；bear原始=close<SMA50 且 20<=RSI14<=60。原始條件連續成立>=2根才算確認的 bullRegime/bearRegime，否則為中性。
【過濾】做多須 bullRegime 且 ADX>=20；做空須 bearRegime 且 ADX>=20。以下所有進場都要通過此過濾。
【做多/做空判斷（皆在K棒收盤確認）】
A. 趨勢翻轉：翻多根且通過多方過濾→做多；翻空根且通過空方過濾→做空。
B. 回測續勢：
1) 多：trend=多且 low<=ts1 時，深度=low<=ts4?4:low<=ts3?3:low<=ts2?2:1，並令 pendingLong=8，pendingLongDepth=取歷史最大深度；每根 pendingLong 先減1(最低0)，翻轉根歸零。收盤 pendingLong>0、trend=多、close>ts1 且 close>open 為回測確認。空：對稱，trend=空且 high>=ts1(ts4/ts3/ts2) 觸發，確認為 close<ts1 且 close<open。
2) 分數：深度分(深度2=25,3=18,1=15,4=10)＋K棒收位分(多 clr=(close-low)/(high-low)，空 clr=(high-close)/(high-low)，range=0時clr=0.5；clr>0.7=20，>0.5=12，否則5)＋趨勢年齡分(barsInTrend 10~150=15，<10=8，>150=5)＋量能分(volume>前一根SMA20(volume)*1.2=20，>該均量=12，否則5；整段無量則12)＋HTF偏向分(biasDir=前一根close>前一根EMA50(close)?1:-1；多方 biasDir=1給20、0給10、-1給0；空方 biasDir=-1給20、0給10、1給0)＋體制分(多方 bullRegime=25、中性=10、bearRegime=0；空方對稱)。總分=round(合計*100/125)，需>=80。
3) 距上一次回測訊號>=5根。
4) 通過上述過濾後，多方確認→做多，空方確認→做空；觸發後 pending 歸零。
【進場】空手時才進（預設不加碼、不因反向訊號平倉），進場價=該根close。做多止損=min(low-0.25*ATR14, close-0.5*ATR14)；做空止損=max(high+0.25*ATR14, close+0.5*ATR14)。R=|close-止損|。多單 TP1/TP2/TP3=進場價+1R/2R/3R；空單為進場價-1R/2R/3R。止損後可選：停損出場後等N根（預設0）才可再進場。
【出場】從進場後下一根起，以收盤確認逐根判斷：多單 low<=止損、空單 high>=止損→出場（同根同時觸及止損與目標時以止損優先）。多單 high>=TP1（空單 low<=TP1）後，止損移到進場價（保本），從下一根起生效。多單 high>=TP3（空單 low<=TP3）→出場。選用：持倉根數>=N（預設關）則以收盤出場；選用：允許反向時，出現反向進場訊號即平倉並反手。