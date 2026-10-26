【共用算法】
週期 P 取日、週、月。用 P 的上一根已完成週期的 H、L、C 計算：CP=(H+L+C)/3，BC=(H+L)/2，TC=2*CP-BC，TOP=max(TC,BC)，BOT=min(TC,BC)。
P 的錨定 VWAP 從該週期第一根開始累計。每根的權重 v 取 volume，volume 為 0 時取 1。VWAP=累計(hlc3*v)/累計(v)，新週期歸零重算。
年 VWAP 從每年 1 月第一根開始累計，累計方式與上面相同。年 σ 是 hlc3 以 v 加權的標準差，即 sqrt(累計(v*(hlc3-該根更新前VWAP)*(hlc3-該根更新後VWAP))/累計(v))，新年歸零。
ATR 取日線 ATR(14)，用前一個已完成日的值。

【多空狀態】逐根判斷，D、W、M 各算一組，Y 另算一組。
先算 dev=close-VWAP。若 |dev|<0.15*ATR，視為 Flat，不做多也不做空。
D、W、M：
- dev>0 且 close>TOP：強多。
- dev>0 且 close<=TOP：回調多。
- dev<0 且 close<BOT：強空。
- dev<0 且 close>=BOT：回調空。
Y：把 TOP、BOT 換成年 VWAP+σ 與年 VWAP-σ，σ>0 才算。
- dev>0 且 close>VWAP+σ：強多；dev>0 但未超過：回調多。
- dev<0 且 close<VWAP-σ：強空；dev<0 但未跌破：回調空。
做多取強多或回調多，做空取強空或回調空。可單用一組，也可多組同向才進場。

【穿越／突破訊號】以收盤價判斷：
- 做多：close>P的CP 且 前一根close<=CP。
- 做空：close<CP 且 前一根close>=CP。
- 做多：close 上穿 P的VWAP、年VWAP 或年VWAP±1σ/2σ/3σ 任一條，即 close>線 且 前一根close<=線。
- 做空：close 下穿同一條線，即 close<線 且 前一根close>=線。
- 做多：high>=上一週期high，即向上突破前高。
- 做空：low<=上一週期low，即向下跌破前低。
週期切換那根（P VWAP 重置、跨年）不算穿越。