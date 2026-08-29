<!-- tradingview-pine-id: PUB;lXhiurTwkfOocRzqBjKyh1TJNX5Y3PWj -->
<!-- tradingviewscripts-format: 1 -->
# EMA Envelope Max Min Extremes with Range Contraction Signal VII

Source: https://www.tradingview.com/script/fXnublKt-Revolution-Volatility-Bands-With-Range-Contraction-Signal-VII/

## Description

Also one of my favorite indicators. Very simple and easy to use. Essentially volatility bands with a technical analysis pattern, the triangle/wedge, which I have called "contraction signal". Put simply: When price is written in blue, volatility overall is falling. When the outer bands start to fatten up in blue, a contraction signal is forming. Works with any length of your choosing.

---

## Source Code

````pine
//@version=4
study(title="EMA Envelope Max Min Extremes with Range Contraction Signal VII", shorttitle="Env", overlay=true)

len = input(20, title="Length", minval=1)

a = close - ema(close, len)
b = iff(a < 0, a * -1, a)
d = ema(b, len)

basis = ema(close, len)

upper = basis + d
lower = basis - d

max = max(upper, close)
smooth = ema(max, len)
min = min(close, lower)
smooth2 = ema(min, len)

plot(smooth2)
smaa = ema(smooth2, len)
plot(smooth)
smaa2 = ema(smooth, len)

rising = rising(smooth2, len / 5)
falling0 = falling(smooth, len / 5)
wedge = iff(rising and falling0, smooth, na)
wedge2 = iff(rising and falling0, smooth2, na)
plot(wedge, style=plot.style_linebr, linewidth=3)
plot(wedge2, style=plot.style_linebr, linewidth=3)

range = smooth - smooth2
falling = falling(range, len)
falling2 = iff(falling, close, na)
plot(falling2, style=plot.style_linebr, linewidth=3)
````
