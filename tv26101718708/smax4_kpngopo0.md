# SMAx4

- url: https://www.tradingview.com/script/KPNGOpo0/
- type: indicator
- pine_id: PUB;6eb03dac680141059f0ebd52a2e5a8bd
- version: 1.0

## Description

移動平均線SMAをたくさん表示して「インジケーター表示枠」を無駄に消費していませんか？
見た目スッキリ！SMAを4本出せるインジケーターを作りました！

Are you wasting your "indicator display slots" by using SMA ?
This indicator can display up to four(4) SMAs at once.

## Source Code

````pine
//@version=6
indicator("SMA×4", overlay=true)

len1 = input.int(5,   "SMA1 期間")
len2 = input.int(50,  "SMA2 期間")
len3 = input.int(125, "SMA3 期間")
len4 = input.int(200, "SMA4 期間")

src = input.source(close, "ソース")
ofs = input.int(0, "オフセット")

plot(ta.sma(src, len1), "SMA1", color=#B129FF, linewidth=1, offset=ofs)
plot(ta.sma(src, len2), "SMA2", color=#2296F3, linewidth=1, offset=ofs)
plot(ta.sma(src, len3), "SMA3", color=#66BB6A, linewidth=1, offset=ofs)
plot(ta.sma(src, len4), "SMA4", color=#EC407A, linewidth=1, offset=ofs)
````
