【做多/做空】每根K線判斷一次。只取 Tier 1/2 訊號：信心 ≥0.70 且方向為多或空。信心 ≥0.40 時只算「有方向」，不算 Tier 1/2。後驗機率 P 大於 0.5 為做多，小於 0.5 為做空。反向訊號出現時反手或平倉；READ 沒有其他出場規則。

〔單根K線的買賣方向 s〕
- close>open 時 s=+1，close<open 時 s=-1。
- 兩者相等時，close>前收 則 s=+1，close<前收 則 s=-1。
- 仍相等時，沿用前一根的 s（起始為 +1）。
- delta=s*volume。deltaNorm=s。barAir=s。
- cvd=累計 delta，每個日曆日歸零。cvdNorm=x/(1+|x|)，其中 x=cvd/(20根volume均值*50)。

〔平滑與加速〕
- ER=|close-close[10]| / Σ_{k=1..10}|close[k-1]-close[k]|，限制在 0~1。
- a=0.05+0.35*ER。airSm 初始為 barAir，之後 airSm+=a*(barAir-airSm)。
- accel=airSm-airSm[3]。accelNorm=clamp(4*accel,-1,1)。

〔Hawkes 方向強度〕
- lamBuy、lamSell 每根乘以 0.8。
- 若 |delta| > 1.2*SMA20(|delta|)：delta>0 時 lamBuy+=1，delta<0 時 lamSell+=1。
- hawkes=(lamBuy-lamSell)/(lamBuy+lamSell)，總和為 0 時取 0。

〔吸收訊號〕
- pred=ATR14*sqrt(|delta|/SMA20(volume))。ratio=|close-open|/pred（pred>0 才算）。
- absorb=sign(delta)*clamp(ratio-1,-1,1)。

〔去相關縮放 k〕
- 取 airSm、deltaNorm、cvdNorm、accelNorm 四者，兩兩計算 20 根滾動相關。
- 每個相關值限制在 0~1，na 視為 0。
- rho=這六個相關值的總和/10。k=(1/(1+4*rho))。

〔後驗機率〕
- LO=k*(3*0.7*airSm + 3*0.6*deltaNorm + 2.5*0.4*cvdNorm + 2.5*0.45*accelNorm) + 2.5*0.45*hawkes + 2.5*0.40*absorb。
- 每一項都限制在 ±6.9 內。
- P=1/(1+e^-LO)。信心 conf=2*|P-0.5|。

〔多週期共識〕
- 計算 P 的 EMA8 與 EMA21。
- 三者同在 0.5 同一側時 bonus=+0.10。
- 短期與中期，或短期與長期，在 0.5 兩側時 bonus=-0.10。
- 其餘情況 bonus=0。

〔震盪懲罰〕
- regime=airSm + 0.8*deltaNorm + 0.5*cvdNorm + 0.6*accelNorm。
- regime≥0.7 的方向為 +1，regime≤-0.7 的方向為 -1，其餘為 0。
- 對 k=0..9，比較第 k 根與第 k+1 根的方向：
  - 一正一負：ev=1。
  - 一個為 0、另一個不為 0：ev=0.5。
  - 其餘：ev=0。
- thrash=min(1, Σ ev*0.85^k / 4)。

〔最終信心〕
- confidence=clamp(conf - 0.5*thrash + bonus, 0, 1)。
- 做多：P>0.5 且 confidence≥0.70。
- 做空：P<0.5 且 confidence≥0.70。