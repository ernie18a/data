RSI=RSI(close,14)。以下判斷都逐根計算，結果指向做多或做空。

1. 三角標記（通道超買超賣引擎）
- 取 L1=5，H=RMA(high,L1)，Lo=RMA(low,L1)。half=(H-Lo)/2，mid=Lo+half。half 為 0 或無值時該根無結果。
- rH=RSI((high-mid)/half,14)，rL=RSI((low-mid)/half,14)。mx=max(rH,rL)，mn=min(rH,rL)。
- chosen 的取法：mx 與 mn 都大於 50 取 mx；都小於 50 取 mn；其餘取離 50 較近者，兩者等距則取 mn。
- 以 chosen[3] 為中心判斷轉折：chosen[3]>=最近 8 根 chosen 的最高值，記為高點轉折；chosen[3]<=最近 8 根 chosen 的最低值，記為低點轉折。
- a=2/(12+1)。高點轉折且 chosen[3]>51.5 時，highEma=a*chosen[3]+(1-a)*前一個 highEma，前一個無值則用 chosen[3] 代替；否則 highEma 沿用前值。
- 低點轉折且 chosen[3]<48.5 時，lowEma=a*chosen[3]+(1-a)*前一個 lowEma，前一個無值則用 chosen[3] 代替；否則 lowEma 沿用前值。
- 做多：highEma>0 且 chosen>highEma。
- 做空：lowEma>0 且 chosen<lowEma。

2. 趨勢通道顏色
- chHigh=RMA(high,34)，chLow=RMA(low,34)，PA=RMA(ohlc4,13)，其中 ohlc4=(open+high+low+close)/4。
- 做多：PA>chHigh。
- 做空：PA<chLow。
- PA 在 chLow 與 chHigh 之間為中性，不指向方向。

3. RSI 區間（K 線顏色與 RSI 列）
- 做多：RSI>=51.5。
- 做空：RSI<=48.5。
- RSI 介於 48.5 與 51.5 之間為中性。

4. RSI 與均線關係（趨勢條各列的多空色）
- fast=SMA(RSI,20)，slow=SMA(RSI,50)。
- RSI>fast 為多，RSI<fast 為空。
- RSI>slow 為多，RSI<slow 為空。
- fast>slow 為多，fast<slow 為空。
- 三列同向時動能一致，說明文字稱此為偏多或偏空對齊。

沒有出場條件，也沒有各判斷之間的相互過濾。