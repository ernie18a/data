【做多】指標:
·WVF=(最近18根close最高值−low)/最近18根close最高值×100;上軌=SMA(WVF,16)+2×STDEV(WVF,16);區間高=最近40根WVF最高值×0.85。原始觸發=(前一根WVF≥前一根上軌 或 前一根WVF≥前一根區間高) 且 本根WVF<上軌 且 WVF<區間高。WVF觸發(F)=原始觸發 且 low>前根low 且 close>前根high 且 close>close[2] 且 (close<close[30] 或 close<close[12])。
·BB=SMA(close,20)±2×STDEV(close,20)。
·ADX=ta.dmi(14,14)的ADX。
·VIDYA:動量=close−前根close;上漲和/下跌和取20根;CMO=100×(上漲和−下跌和)/(兩者和),和為0則0;k=|CMO|/100;α=2/11;VIDYA=α×k×close+(1−α×k)×前一VIDYA,首值=close。
·OBV=累加(close≥open?+volume:−volume)。
·DELTA=EMA14(close≥open?volume:−volume)。
·TQI=四項平均:ER=|close−close[20]|/最近20根|close變動|和(上限1);ATRf=ATR20,ATRs=SMA(ATRf,40),量比=ATRf/ATRs,volQ=clamp(量比−0.5,0,1);strQ=clamp(((close−SMA50)/ATRf+2)/4,0,1);momQ=clamp(((close−close[14])/close[14]×100+5)/10,0,1)。
·VOL=ATR10在最近100根的percentrank。
做多流程(逐根):
1.閘門:最近0~3根內曾出現F,取最小距離a(a=最近一次F距今根數);否則無訊號。
2.分數(每項1分):A)EMA9>EMA21在最近0~(a+2)根內任一根成立(且總回看≤5根);B)close>VIDYA同樣在0~(a+2)根內任一根成立;C)OBV>OBV[8](本根);D)EMA14(signed volume)>0在0~(a+2)根內任一根成立;E)TQI≥0.35;F)VOL percentrank≥66.7。FVG不計分。
3.分級:分數<1無訊號;分數≥2且ADX<25=3級(FULL);分數≥2且ADX≥25=2級;分數1=1級。
4.降級:若最近0~(a+2)根(回看≤5根)內曾有close≤BB下軌,且級別>1,級別−1。
5.做多進場=級別>0 且 級別≠前一根級別,以收盤價進場(只在該週期上評估,不用更高週期)。

【出場(僅持多單時)】進場後6根內不觸發;進場後12根內視為持倉有效。三種出場訊號:
·BB Break:close≤SMA20−2×STDEV20。
·WVF Top:V=(最近18根close最低值−high)/最近18根close最低值×100;下軌=SMA(V,16)−2×STDEV(V,16);區間低=最近40根V最低值×0.85;訊號=(前根V≤前根下軌 或 前根V≤前根區間低) 且 V>下軌 且 V>區間低。
·CVI Top:CVI=(close−最近3根low最低)/(最近3根high最高−最近3根low最低),區間0則0.5;訊號=前根CVI≥0.43 且 本根CVI<0.43。
三者各為獨立訊號(新發生才算)。3根窗口內只出現1種=減半出場;3根窗口內出現≥2種不同訊號=全部出場。

【其他多空標示】
·EMA21>EMA200=偏多(▲UP),否則偏空(▼DN)。
·OBV>OBV[8]=多,<=空,相等中性。
·CVI>0.5偏多,否則偏空;CVI下穿0.43(Top)=空訊號;CVI上穿0.57(前根≤0.57且本根>0.57)=多訊號。
·BBAWE多:EMA3上穿SMA20 且 close>SMA20 且 AO≥0 且 AO>前根AO(AO=SMA(hl2,5)−SMA(hl2,34));BBAWE空:EMA3下穿SMA20 且 close<SMA20 且 AO<0 且 AO<前根AO。
·BP=最近20根中close≥open的比例×100:>55偏多,<45偏空。