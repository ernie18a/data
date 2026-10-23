【指標】MACD=EMA12(close)-EMA26(close)；signal=EMA9(MACD)；hist=MACD-signal；slope=MACD-MACD前一根；accel=slope-slope前一根。ATR=ATR14。Bh=EMA50(|hist|)，Be=EMA50(|hist-hist前一根|)，Bs=EMA50(|slope|)，Ba=EMA50(|accel|)。clamp(x)=限制在0~1。

【做多】只在K線收盤後判斷，下列全部成立才做多：
1. 觸發（任一）：
(a) 零軸上穿：MACD由下往上穿越0，且MACD>signal、hist>0。
(b) 順勢交叉：MACD上穿signal，且MACD>=0。
(c) 反轉交叉：MACD上穿signal，且MACD<0。
(d) 動能再擴張：本根無上述交叉或零軸上穿，且MACD>signal、slope>0、hist>0、hist>hist前一根、hist前一根<=hist前兩根。
2. 動能分數>=75，分數為下列五項相加：
- 對齊：MACD>signal且hist>0得20。
- 強度：hist>0時，25*clamp(|hist|/(Bh*1.25))。
- 擴張：hist>=0且hist>hist前一根時，20*clamp(|hist-hist前一根|/(Be*1.2))。
- 斜率：slope>0時，20*clamp(slope/(Bs*1.2))。
- 加速：accel>0時，15*clamp(accel/(Ba*1.2))。
3. 盤整過濾，分數>=65，分數為下列四項相加：
- 35*clamp(ADX(14,14)/25)。
- 30*clamp(效率/0.35)，效率=|close-close前20根|/(SMA20(|close-close前一根|)*20)。
- 20*clamp(|EMA21(close)-EMA50(close)|/ATR/0.30)。
- 15*clamp((ATR/SMA50(ATR))/0.9)。
4. 進場分數>=75，分數為下列五項相加：
- 實體：12.5*clamp(max(close-open,0)/R/0.6)，R=max(high-low,最小跳動)。
- 收盤位置：12.5*clamp(((close-low)/R)/0.8)。
- 分離：hist>0時，25*clamp(|hist|/(Bh*1.25))。
- 持續：MACD>signal且hist>0時，20*clamp(連續對齊根數/3)；若從未中斷，連續根數取3。
- 衝擊：15*clamp(max(close-close前一根,0)/ATR/0.35)。
- 觸發成立再加15。
5. MACD>0。
6. |hist|/ATR*100>=1.0。
7. close>open。
8. |hist|/Bh>=0.65。
9. MACD>signal且hist>0。
10. 距上一次訊號>=8根K線。
11. 目前沒有持倉，且本根不是剛平倉的那根。

【做空】與做多完全鏡像：
- 觸發：MACD下穿0且MACD<signal、hist<0；MACD下穿signal且MACD<=0（順勢）；MACD下穿signal且MACD>0（反轉）；hist<0、hist<hist前一根、hist前一根>=hist前兩根、MACD<signal、slope<0，且本根無交叉（再擴張）。
- 各項分數、對齊、動能與強度條件全部方向反轉。
- 收盤位置改為(high-close)/R，衝擊改為max(close前一根-close,0)。
- MACD<0，close<open，hist<0。

【出場】
進場價=訊號K線收盤價。ATR模式的停損距離D=1.5*ATR(14)（訊號當根值），TP1/TP2/TP3距離=0.5D/1.0D/1.5D。從進場後下一根K線起逐根檢查：
- 做多：停損=進場價-D，TP=進場價+距離。做空相反。
- 做多：low<=停損則出場；high>=TP3則全部出場，TP1、TP2為分批達標。做空用相反方向。
- 同一根K線同時觸及停損與目標時，先算停損。