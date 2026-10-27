【指標】SMA20/50/200=收盤簡單均線；dist20=(close-SMA20)/SMA20；day_chg=close/前收-1；stoch=14根(close-最低low)/(最高high-最低low)*100再取3根SMA；BB20 pos=(close-下軌)/(上軌-下軌)，軌=SMA20±2*stdev20(close)；bbpos50同理用50根；reg50=linreg(close,50)，其上下軌=±2*stdev(close-linreg,50)，regpos50=(close-下)/(上-下)，regslope50=(本根linreg-前一根linreg)/本根linreg；reg20同理用20根得regpos20；MACD(12,26,9)柱狀圖，改善=柱>前一根柱。

【做多】同時成立才做多（距上次做多至少8根）：
1. regslope50>0.003
2. regpos50<=0.25 且 regpos20<=0.20
3. dist20<=0
4. stoch<=40
5. SMA50>SMA200
6. day_chg>-4%
7. close>前收
8. 信心分>=3。信心分每項成立加1：(a) regpos50<=0.10 且 bbpos50<=0.10；(b) MACD柱改善；(c) regslope50>0.003；(d) 錨定回歸：取最近一個已確認的低點樞軸(low為左右各5根最低)，用樞軸到現在的close(根數限制在10~150)做OLS迴歸，通道=迴歸線±2*殘差標準差(殘差平方和/N開根)，close在通道的位置<=0.20；(e) Fib：swing high=最近120根最高high，prior low=該高點之前100根內最低low，retrace=(swing high-close)/(swing high-prior low)，|retrace-0.618|<0.03或|retrace-1|<0.03。

【做空】僅在開啟該功能時才成立（距上次做空至少8根）：同時成立才做空：
1. BB20 pos>=0.95
2. stoch>=80
3. dist20>=10%
4. day_chg<1%
5. close<前收

【出場】無。