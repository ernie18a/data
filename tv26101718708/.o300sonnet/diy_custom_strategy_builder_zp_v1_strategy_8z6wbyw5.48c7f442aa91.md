【進出場】信號＝主指標條件 且 所有啟用的確認條件同時成立。主指標條件連續成立的根數須 ≤3（超過就失效）。交替限制：只有上一個已成立的條件是做空時才做多，反之亦然（初始無狀態，第一個信號要等到出現過反向條件才會觸發）。做多時若持有空單就先平空；做空同理。
做多進場價為收盤價。止損取最近一個已確認的擺動低點（low 是前後各5根內最低，要等5根後才確認）；若該低點低於收盤價就用它，否則用收盤價−1.5×ATR(14)。止損距離須大於0。止盈＝進場價＋1.5×止損距離。做空相反：止損取最近擺動高點（須高於收盤價，否則用收盤價＋1.5×ATR），止盈＝進場價−1.5×止損距離。持倉中若出現反向信號則平倉反手。

【預設】主指標＝Range Filter，確認＝RQK，其餘確認預設關閉。

【Range Filter（預設型）】r=EMA(EMA(|close−close[1]|,100),199)×3。濾線 f：close>f[1] 時 f=max(close−r,f[1])；否則 f=min(close+r,f[1])。upward 計數：f>f[1] 加1、f<f[1] 歸0、持平不變；downward 反之。多：close>f 且 upward>0；空：close<f 且 downward>0。
【RQK】yhat=Σ(i=0..26) close[i]·w_i/Σw_i，w_i=(1+i²/(2·8·8²))^−8。多：yhat>yhat[1]；空：yhat<yhat[1]。

【其他可選主指標或確認條件，多空對稱】
- EMA 過濾：多 close>EMA(close,200)；空 close<EMA。
- 2 EMA 交叉(50,200)：多＝EMA50 上穿 EMA200；空＝下穿。
- 3 EMA(9,21,55)：多＝快>中>慢（兩兩皆大於）；空相反。
- Supertrend(hl2, ATR10, ×3)：收盤價突破上軌轉多，跌破下軌轉空，多空看目前趨勢方向。
- Half Trend(振幅2)：趨勢為多則做多，為空則做空。
- Donchian(15)：close>前15根最高價轉多、close<前15根最低價轉空，沿用上一趨勢。
- ROC(9)：多 >0，空 <0。
- TSI(25,13，信號13)：多 TSI>信號線；空 TSI<信號線。「零軸」型另加 TSI>0 或 <0。
- McGinley(14)：多 close>MG；空 close<MG。
- DPO(10)：多 close−SMA(close,10)[6]>0；空 <0。
- Ichimoku(9,26,52)：多＝轉換線>基準線，且先行帶A>B，且收盤高於位移後的A、B，且遲行線高於 A[50]、B[50]；空反之。
- MACD(12,26,9)：多 MACD>信號線；空 MACD<信號線。零軸型另加 MACD>0 或 <0。
- Stochastic(14,3,3)：多 %K 上穿 %D；空 %K 下穿 %D。另有只在超賣區/超買區交叉的版本，以及 %K>%D / %K<%D 的版本。
- RSI(14)：多 RSI>其 SMA14；空 RSI<其 SMA14。另有「RSI>50 / <50」版本，以及「RSI 由下往上穿越20」為多、「由上往下穿越80」為空的版本。RSI 限制：多 RSI≥40，空 RSI≤60；RSI 的 MA 方向限制：多 MA≥前值，空 MA≤前值。
- CCI(20,hlc3)：多 CCI>100；空 CCI<−100。
- Chandelier(22,×3)：多空看目前方向。close>空方停損線→多，close<多方停損線→空。
- SSL(10)：close>SMA(high,10) 為多，close<SMA(low,10) 為空；多空看目前狀態。
- Chaikin CMF(20)：多 >0；空 <0。
- Vortex(14)：多 VI+>VI−；空 VI+<VI−。
- Wolfpack：多 EMA3(close)>EMA8(close)；空 <。
- Waddah：多＝MACD(20,40)差值×150（正值）>布林帶寬（20, 2σ）且>死區；空為對應的負向值。
- Volatility Oscillator：spike=close−open，多 spike>stdev(spike,100)；空 spike<−stdev。
- Awesome Oscillator：多 SMA(hl2,5)−SMA(hl2,34)>0；空 <0。
- Hull(55)：多 HMA>HMA[2]；空 HMA<HMA[2]。
- VWAP：多 close>VWAP；空 close<VWAP。
- Parabolic SAR(0.02,0.02,0.2)：多 SAR<close；空 SAR>close。
- ADX/DMI：多 +DI>−DI 且 ADX≥20；空 −DI>+DI 且 ADX≥20。
- BBPT：多＝（最近50根最高價−close）/ATR5 的負值＋2 >0，且 Trend≥2，其中 Trend=(close−最近50根最低價)/ATR5−(最近50根最高價−close)/ATR5；空反之，且 Trend≤−2。
- 成交量：多空皆為 volume>SMA(volume,20)。
- Damiani 波動度：多空皆須波動度>門檻（不分方向）。
- Choppiness(14)：指數<61.8 才放行多空。
- STC(23,50,10)：多 STC≥75；空 STC≤25。
- Range Detector：多 close>區間上緣；空 close<區間下緣。