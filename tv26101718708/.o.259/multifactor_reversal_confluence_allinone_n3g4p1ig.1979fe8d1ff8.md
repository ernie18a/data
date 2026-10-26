【反轉單，預設只在 CONFIRMED 進場，方向＝逆著前一段走勢】
以下 ATR 為 14 根 ATR；ret 為 log(close/前一根close)；z 為標準化。

五個訊號各給出帶方向的強度，正值做多（抄底），負值做空（摸頂）：
1. 不穩定：把最近 50 根 ret 與其前 50 根 ret 各自由小到大排序，逐位取差的絕對值平均，再除以 stdev(ret,50)。取此值在近 200 根的百分位排名（0~100）。方向＝−sign(EMA(ret,20))，即逆著漂移。強度＝方向×排名，|強度|≥15 才算同意。
2. 變點：z＝(ret−SMA(ret,50))/stdev(ret,50)，限制在±5。gP＝max(0,gP+z−0.5)，gN＝min(0,gN+z+0.5)，vP＝max(0,vP+z²−1−0.5)。gP>3 或 gN<−3 為均值突破，vP>4 為變異突破，觸發後各自歸零。突破當根，若 EMA(ret,5) 與 EMA(ret,20) 同號且 |EMA5|>|EMA20|（加速）則不給方向，否則方向＝−sign(EMA(ret,20))。強度＝100×(0.25×min(|z|/4,1)+0.25×min(max(gP,−gN)/5,1))，最低 20。之後每根衰減×0.75，5 根後清零。|強度|≥15 才算同意。
3. 衰竭：ER(n)＝|close−close[n]|/Σ|逐根close變化|（n 根）。慢 ER(30)≥0.30 且 close>close[30] 為上升段，close<close[30] 為下降段。同時要求 ER(10)<ER(10)[3]，且 |close−close[10]|/ATR 的 100 根百分位≥70。上升段滿足為做空，下降段滿足為做多。強度＝40+0.6×該百分位，之後每根×0.8，5 根後清零。|強度|≥12 才算同意。
4. 高潮：vol z（50 根）≥2、(high−low) 的 z（50 根）≥1.5，且 clv＝((close−low)−(high−close))/(high−low)。clv≥0.35 為做多，clv≤−0.35 為做空。（另要求綜合分數超過自適應分位數。）此狀態最多保留 12 根。做多時 low<高潮低點−0.25ATR（做空時 high>高潮高點+0.25ATR）即失效。強度≥20 才算同意。
5. 結構：pivot 左右各 8 根。low<最近 pivot low 且 close>該 pivot low 為多方掃單，high>最近 pivot high 且 close<該 pivot high 為空方掃單。15 根內出現突破才成立：做多要 close>最近 pivot high 且 |close−前close|/ATR≥1，做空要 close<最近 pivot low 且同樣位移≥1。突破後訊號保留 8 根，強度≥18 才算同意。止損＝掃單那根的 low（做多）或 high（做空）。

狀態：
- ARMED：同方向至少 2 個訊號達門檻，候選方向取多數方向。25 根內未升級則作廢。
- EXTREME：ARMED 後高潮訊號與候選方向一致。此為早期提示。
- CONFIRMED：ARMED 或 EXTREME 後結構訊號與候選方向一致。這根收盤進場，候選為做多就做多，候選為做空就做空。

過濾（任一不過就不進場）：
- 均值回歸閘門＝0.5×max(0,−corr(close[1]−SMA(close,30)[1], ret, 30))+0.5×regimeRev。其中 VR＝var(連續 4 根 ret 之和,100)/(4×var(ret,100))，VR<1 時 regimeRev＝min((1−VR)/0.5,1)，否則為 0。閘門值需≥0.20。
- 亂流閘門：shock＝|ret|>2×stdev(ret,100)。cnt＝近 5 根 shock 之和。fano＝var(cnt,50)/SMA(cnt,50)。branch＝clamp(1−1/√max(fano,1),0,1)。cascade＝branch≥0.6 且 branch≥前一根 branch。cascade 時閘門＝max(0,1−0.7×(branch−0.6)/0.4)，否則為 1，需≥0.35。

出場：止損如上，無結構止損時用進場價∓1ATR。TP1＝進場價＋方向×1×風險，TP2＝進場價＋方向×2×風險，風險＝|進場價−止損|（至少 0.1ATR）。

【順勢單（趨勢段回檔再續）】
趨勢：DEMA(x)＝2×EMA(close,x)−EMA(EMA(close,x),x)。快線＝DEMA(9)，慢線＝DEMA(21)。快>慢且慢線≥前一根為上升趨勢，快<慢且慢線≤前一根為下降趨勢。
- 做多：上升趨勢，且 max(high,10)−low≥0.5ATR（有回檔），且 close 向上穿越快 DEMA。
- 做空：下降趨勢，且 high−min(low,10)≥0.5ATR，且 close 向下穿越快 DEMA。
- 亂流閘門需≥0.35。
- 止損：做多為 min(最近10根最低價, close−1ATR)，做空為 max(最近10根最高價, close+1ATR)。TP 同上，1R 與 2R。
- 若同一根已有反轉單，以反轉單為準。