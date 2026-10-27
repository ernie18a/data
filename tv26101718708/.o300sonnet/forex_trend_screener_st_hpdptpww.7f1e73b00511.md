指標 FT：src=(high+low+close)/3；esa=EMA(src,9)；de=EMA(|src-esa|,9)；ci=(src-esa)/(0.015*de)；FT=EMA(ci,12)。
做多：FT>0。做空：FT<0。FT=0 時不做多也不做空。

做多、做空都要通過以下過濾，沒過就不進場：
1. 前一根 FT 與當根 FT 的正負號必須相同，即 sign(FT)==sign(FT[1])。
2. |FT|>10。
3. 進場分數大於 30。算法如下：
 - strength=min(|FT|/60,1)。
 - 設 s=FT 的前一根序列，slope=3*(linreg(s,3,0)-linreg(s,3,1))。
 - 做多時 fresh=slope，做空時 fresh=-slope。
 - freshRatio=clamp((fresh+20)/40,0,1)。
 - 如果近 5 根的 fresh 最小值<=0，而且當根 fresh>0，freshRatio=min(freshRatio+0.15,1)。
 - 進場分數=(0.2*freshRatio+0.8*strength)*100。