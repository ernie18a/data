【做多/做空：曲線接觸判斷，只用 OHLC，無 footprint 時只剩幾何部分】
1. 波動 σ（N=20，每根 bar 都算）：
 - 隔夜報酬 ro=ln(open/前一根 close)，日內報酬 rc=ln(close/open)。
 - Rogers-Satchell 項 rs=ln(h/o)*ln(h/c)+ln(l/o)*ln(l/c)。
 - k=0.34/(1.34+21/19)。
 - σ²=var20(ro)+k*var20(rc)+(1-k)*sma20(rs)，var 用母體變異數。
 - σ=sqrt(max(σ²,0))，下限 1e-10。
2. 選出最大波幅 K 棒（最多 3 根）：
 - 從前 1 根（offset=1）往前逐根掃，條件是該棒 high-low 嚴格大於它再前一根的 high-low。取最先找到的 2 根。
 - 再取最近 20 根（offset 1 到 20）裡 high-low 最大的那根。若它與前兩根是同一根就略過。
 - 每根 K 棒取當時的 σm，並令 lnLow=ln(low)。
 - 半徑 R=ln(H/L)/σm/2。上影半徑 rUp=ln(H/max(O,C))/σm/2。下影半徑 rLo=ln(min(O,C)/L)/σm/2。
 - 該 K 棒 bar_index 記為 s。
3. 每根 K 棒有三條擺線，軌跡半徑 r 分別取 R（外圈）、rUp、rLo（r<1e-15 的略過）：
 - 參數式 x(θ)=R*θ+r*sinθ，y=R+r*cosθ。
 - 當前 bar 的 b=bar_index-s，用二分法解 x(θ)=b，取最小的 θ。
 - 曲線價 cy=exp(lnLow+y*σm)。
4. 接觸：令 tol=0.3*σ*close（σ 為當前 bar 的 σ）。符合 |close-cy|<tol 或 low<=cy<=high 即算接觸。
5. 方向分數：
 - 若 low<cy 且 close>=cy，wick=(cy-low)/(high-low)。
 - 若 high>cy 且 close<=cy，wick=-(high-cy)/(high-low)。
 - 其餘情況 wick=0。
 - d=0.7*(close-cy)/max(tol,mintick)+0.5*wick。
 - P(上)=0.5+0.18*(2/(1+exp(-2.5d))-1)。
 - P(上)>0.5（即 d>0）為做多（反彈、突破向上）；P(上)<0.5（即 d<0）為做空（拒絕、向下）。
6. 同一根 bar 多條曲線同時接觸時，取信念分數最高的那條決定方向：
 - 基礎值 cBase：外圈為 0.4，其餘為 0.25+0.15*r/R。
 - 位置 yRel=(y-R)/r，ext=max(0,2/(1+exp(-4*(|yRel|-0.3)))-1)。
 - cZone=1+(0.4+0.1*max(0,yRel))*ext。
 - confN 為所有 K 棒、所有曲線在當前 bar 的價與 cy 相差小於 tol 的條數（含自己）。
 - cConf=1+max(0,2/(1+exp(-3*(confN-1)/2))-1)。
 - 信念分數=cBase*cZone*cConf，截到 [0,1]。
7. 另有一組以 K 棒方向分類的標示（同樣只用本根 OHLC 與 cy，也屬同一個接觸判斷）。判斷順序是先看收盤是否貼近 cy，再看實體是否穿越，最後看影線：
 - 若 |close-cy|<tol/3，為停止，中性。
 - 若 open<cy 且 close>cy，為向上穿越，偏多。
 - 若 open>cy 且 close<cy，為向下穿越，偏空。
 - 若 low<=cy 且 close>cy，為下影反彈，偏多。
 - 若 high>=cy 且 close<cy，為上影拒絕，偏空。
8. 另有「箱體位置」資訊：以 close 相對於各擺線頂點與谷底價位的位置，標示突破或跌破。
 - 價位：頂點 exp(lnLow+(R+r)*σm)，谷底 exp(lnLow+(R-r)*σm)，其中外圈 r=R。
 - close>最近上方價位標為突破（偏多）；close<最近下方價位標為跌破（偏空）。

沒有出場判斷。