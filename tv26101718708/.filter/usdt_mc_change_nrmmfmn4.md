# USDT MC Change

- url: https://www.tradingview.com/script/nrmMfmN4-USDT-MC-Change/
- type: indicator
- pine_id: PUB;ce02cc6a9daa4d1ea85927b0dabb2082
- version: 1.0

## Description

USDT Market Cap Change indicator

Just like the CryptoQuant one, but without the log outs.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Commandoum

//@version=6
indicator("USDT MC Change", shorttitle= "USDT MC OS", overlay=false)

usdt_mc = request.security("CRYPTOCAP:USDT", "D", close)

mc_60day_change = usdt_mc - usdt_mc[60]

mc_30day_ma = ta.sma(mc_60day_change, 30)

p1 = plot(mc_60day_change, title="Liquidity Momentum", color=#7027b0b9, linewidth=2)
p2 = plot(mc_30day_ma, title="30 SMA", color=color.yellow)

p_zero = plot(0, title="Zero Reference", display=display.none)

fill(p1, p_zero, #583cf67f, title="Momentum Fill")

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
````
