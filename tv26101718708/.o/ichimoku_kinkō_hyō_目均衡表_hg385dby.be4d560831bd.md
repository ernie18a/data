【共用計算】price=close 的 SWMA(權重 1,2,2,1 除以 6)。Tenkan=(最高high+最低low)/2,週期為 Tenkan 自適應週期 TL。Kijun 同理,週期為 KL。SenkouA=(Tenkan+Kijun)/2。SenkouB=(最高high+最低low)/2,週期為 SL。雲取 25 根前的 SenkouA 與 SenkouB:kumo_top=兩者較大值,kumo_bottom=兩者較小值。
自適應週期:四條線各自維護。初值=(min+max)/2。每根 K 先判斷自己的條件:OBV>50、ATR(14)>ATR(46)、chikou_trend==1(定義見下),三個條件全部成立才算通過。通過則 len=max(min, len*0.9685),否則 len=min(max, len*1.0315),取整數。範圍:Tenkan 9~30,Kijun 20~60,Senkou 50~120,Chikou 26~50。令 CL 為 Chikou 週期;chikou_past=CL 根前的 price,chikou_past_prev=CL-1 根前的 price。
OBV=累計(sign(close-close[1])*volume)。chikou_trend:price>前 25 根的最高 high(取 25 根前的值)為 +1;price<前 25 根的最低 low(取 25 根前的值)為 -1;否則 0。

【做多判斷】以下 8 項全部成立:
1. OBV>50
2. ATR(14)>ATR(46)
3. Tenkan>Kijun
4. price-chikou_past_prev>0
5. price>chikou_past
6. price>kumo_top
7. price>Tenkan
8. chikou_trend==1
另有替代條件:Tenkan==Kijun 且前一根 Tenkan<Kijun。8 項全成立或替代條件成立皆可。

【做空判斷】以下 8 項全部成立:
1. OBV<50
2. ATR(14)>ATR(46)
3. Tenkan<Kijun
4. price-chikou_past_prev<0
5. price<chikou_past
6. price<kumo_top(進入雲內也算偏空)
7. price<Tenkan
8. chikou_trend==-1
替代條件:Tenkan==Kijun 且前一根 Tenkan>Kijun。

【平盤過濾】多空共用,以下兩者同時成立就禁止所有訊號:
- kumo 厚度=|kumo_top-kumo_bottom|/max(|kumo_top|,|kumo_bottom|)*100<0.3
- ADX(14)<20。ADX 算法:+DM=(high-high[1]>low[1]-low)?max(high-high[1],0):0;-DM=(low[1]-low>high-high[1])?max(low[1]-low,0):0;TR、+DM、-DM 各做 EMA14;DI=100*DM平滑/TR平滑;DX=100*|+DI-(-DI)|/(+DI+(-DI));ADX=EMA14(DX)。

【進出場】
- 做多觸發:做多條件(含過濾)這根成立、前一根不成立,且 bar_index≥120(暖機)。
- 做空觸發:做空條件這根成立、前一根不成立,同樣需過暖機。
- 持倉狀態 regime:出現做多觸發且 regime≤0 時設為多;出現做空觸發且 regime≥0 時設為空。
- 出場:持多遇做空觸發即出場並反手做空;持空遇做多觸發即出場並反手做多。沒有其他出場條件。

【其他標示多空的條件】
- K 棒顏色(預設):close>Tenkan 且 close>Kijun 為多;close<Tenkan 且 close<Kijun 為空;其餘中性。
- 其他 K 棒顏色模式:close>kumo_top 為多,close<kumo_bottom 為空。SenkouA>SenkouB(未平移)為多,SenkouA<SenkouB 為空。
- 面板共識(用 close,Tenkan/Kijun/SenkouB 取預設固定週期 9/26/52,雲取 25 根前;以下 5 項皆用同一組線與雲):
  1. min(Tenkan,Kijun)>雲頂為多,max(Tenkan,Kijun)<雲底為空。
  2. Kijun 在雲上為多,在雲下為空。
  3. close>25 根前 high 為多,close<25 根前 low 為空。
  4. close>雲頂為多,close<雲底為空。
  5. SenkouA>SenkouB 為多,反之為空。
  5 項方向全部一致才算共識,且全為多時為多、全為空時為空。
- 擺動高低點(預設關閉):pivot high(左右各 10 根)確認為偏空標示,pivot low 確認為偏多標示。
- TK 區間突破:當 Tenkan 與 Kijun 的差距≥0.1*ATR(14),且收盤落在兩線之間,連續至少 3 根即成區間。之後收盤脫離該區間,若 close≥區間上緣為向上突破(多),若 close≤區間下緣為向下突破(空)。
- 訊號觸發當根的 high 或 low 為支撐/壓力位:價格於該位下方被收盤突破視為做多,上方被收盤突破視為做空。