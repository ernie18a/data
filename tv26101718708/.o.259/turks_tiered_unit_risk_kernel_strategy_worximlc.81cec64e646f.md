只做多(0~1 倍權重、不做空)。持倉權重 w 逐根收盤計算;w>0 為做多或加碼,w 降低為減碼,w=0 為出場(全平)。

預設判斷:
1. ATR=RMA(TR,14)。對 n∈{20,50,100,200},r_n=clamp((close-SMA_n)/(d_n*ATR),0,1),d_20=2*sqrt(20/200)、d_50=2*sqrt(50/200)、d_100=2*sqrt(100/200)、d_200=2。raw=四個 r_n 的平均。
2. 三階量化:持有值 held 初始為 0。當|raw-held|>=0.25 時,held=round(raw*3)/3,否則 held 不變。unit=held,只可能是 0、1/3、2/3、1。
3. 平滑線 S=Σ_{i=0..30} close[i]*exp(-i²/50)/Σ_{i=0..30} exp(-i²/50)(只用當根與過去的收盤價)。
4. 減碼限制:若 close>=S,則 g=unit;若 close<S,則 g=max(前一根的 g, unit)。也就是收盤在 S 之下不得減碼,但可以加碼。
5. 目標權重 w=g(要求 SMA200 已有值)。g 高於目前權重就買到 g,g 低於目前權重就賣到 g。
6. 做多:g>0。出場:g==0,只可能發生在 close>=S 且 unit=0 時。close 低於全部四條均線不代表出場,出場要等 unit 降到 0,而且 close>=S。

可選模式(同一套 unit):
- 只用 SMA200 的單均線版:raw=clamp((close-SMA200)/(1*ATR),0,1)。
- 二元版:收盤高於 SMA200 連續 5 根才轉為 ON,低於連續 5 根才轉為 OFF;ON 且 SMA200>SMA200[20] 時 unit=1,否則 0。
- 帶狀賣出:E=SMA(|close-S|,499)。上軌=S+3E,下軌=S-2.5E。收盤上穿上軌(close>上軌 且 前一根 close<=前一根上軌)時 sold+1,最多 20。收盤下穿下軌(close<下軌 且 前一根 close>=前一根下軌)時 sold-1,最少 0。cap=1-sold/20。
  - 只用帶狀:w=cap。
  - 兩者都減:w=min(unit,cap)。