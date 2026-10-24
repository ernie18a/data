【做多】動能向下且信號數達門檻且距上次任何多空信號超過5根：收盤價<EMA9 且 RSI14<50，且下列三個分量達門檻（預設 Confluence：至少2個；Aggressive 至少1個；Conservative 3個全成立），且 當前bar序號−上次信號bar序號>5。
【做空】動能向上且信號數達門檻且間隔同上：收盤價>EMA9 且 RSI14>50，信號數門檻與間隔條件同做多。
（READ 的 BUY/SELL 標籤、顏色與警報把「動能向下」那組標為BUY、「動能向上」那組標為SELL，故方向如上。）
兩方向共用三個分量，各自為布林值：
分量A（波動）= 跳躍 或 Hawkes強度>0.2×0.7(=0.14)。
 跳躍：取N=50。依序計算序列 s0=stdev(報酬率,N)，報酬率=(close−close[1])/close[1]；s1=stdev((volume−SMA(volume,N))/SMA(volume,N),N)；s2=stdev((high−low)/close,N)。（預設只用前3維；維度數可為2~5，s3=stdev(correlation(close,volume,N),N)，s4=stdev((close−(high+low)/2)/(high−low+0.0001),N)。）每個序列用前1~N根（不含當根）的值取平均與母體標準差；z=(當前值−平均)/標準差（標準差為0則該維不計）；距離=sqrt(各維z²總和/維數)。原始跳躍=距離>3.0×0.7(=2.1)。有效跳躍=原始跳躍 且 當前bar序號−上次有效跳躍bar序號>5。Hawkes強度：有效跳躍時設為1，否則上一根值×0.85，初值0。
分量B（Hurst，依制度）：
 先算Hurst：取最近N=50根對數報酬 ln(close/close[1])（i=0為當根），mean為平均，依序累加(值−mean)得累積偏差序列，R=累積序列最大−最小，S=母體標準差，H=ln(R/S)/ln(50)（R/S≤0時H=0.5），再取EMA10得Hs。
 制度狀態（初值random）：Hs>0.62→trending，計數歸0；Hs<0.38→reverting，計數歸0；否則計數+1，計數>10→random，其餘維持原制度。
 trending：close>SMA20(close) 且 close>close[1]。
 reverting：close>布林上軌(20,2) 或 close<布林下軌。
 random：布林帶寬(上軌−下軌)/中軌<0.1 且（close>前一根上軌 或 close<前一根下軌）。
分量C（熵）= 成交量領先 或 價格領先 或 volume>SMA(volume,20)×(1+0.7×0.1)。
 轉移熵TE(來源序列,目標序列,lag=5)：bar數不足(lag+N)時為0。兩序列取最近N=50根（i=0為當根），來源用ln(volume+1)或報酬率，目標用報酬率或ln(volume+1)。各自依自身最小最大值分10箱：箱=int((值−最小)/(最大−最小)×9)（任一範圍為0則TE=0）。對i=lag..N−1，比較來源[i−lag]的箱與目標[i]的箱，相同則計1，p=相同次數/總次數；TE=−p·ln p−(1−p)·ln(1−p)（p不在0~1之間則0）。TE量→價=TE(ln(volume+1)→報酬率)，TE價→量=TE(報酬率→ln(volume+1))，各取EMA5，淨流=TE量→價−TE價→量。成交量領先=淨流>0.15×0.7(=0.105)；價格領先=淨流<−0.105。
【出場】依持倉方向計損益% = 多單(close−進場價)/進場價、空單(進場價−close)/進場價；空手時才進場；持倉後符合任一即出場：持有超過15根bar、損益%>3%、損益%<−1.5%。