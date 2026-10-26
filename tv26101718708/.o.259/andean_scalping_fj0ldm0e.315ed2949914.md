【指標】alpha=2/(50+1)。逐根遞迴，初值取當根 close（平方項取 close²）：
up1=max(close,open,up1前值-(up1前值-close)*alpha)
up2=max(close²,open²,up2前值-(up2前值-close²)*alpha)
dn1=min(close,open,dn1前值+(close-dn1前值)*alpha)
dn2=min(close²,open²,dn2前值+(close²-dn2前值)*alpha)
bull=sqrt(dn2-dn1²)；bear=sqrt(up2-up1²)
signal=EMA(max(bull,bear),9)；thr=SMA(signal,1000)*1.1

【做多】bull>bear 且 bull>signal 且 signal>thr。
【做空】bear>bull 且 bear>signal 且 signal>thr。
【多單出場】bull<signal（READ 預設不啟用此出場，改以下列停損停利出場）。
【空單出場】bear<signal（同上）。
【停損停利】多單：low<=進場價*(1-7.5%) 停損；high>=進場價*(1+10%) 停利。空單：high>=進場價*(1+7.5%) 停損；low<=進場價*(1-10%) 停利。

【選用過濾，READ 預設關閉】EMA 濾網：EMA(close,200)，多單需 close 與 open 皆>EMA，空單需 close 與 open 皆<EMA。ADX 濾網（DI 長度14、平滑14）：ADX>39.4 才允許做多或做空。