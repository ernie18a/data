# Average Directional Index v2

- url: https://www.tradingview.com/script/7Ijtq4XE-Average-Directional-Index-v2/
- type: strategy
- pine_id: PUB;96e4a83a42044f4f838e0e9e82febadc
- version: 1.0

## Description

This script uses another method of obtaining the price with each tick. The combination of gap settings and price data provide a good ADXx plot that does not repaint by default.

## Source Code

````pine
//@version=5
strategy("Average Directional Index", shorttitle="ADXx", format=format.price, precision=2, calc_on_every_tick=true)

hlTimeframe = input.timeframe("", title="HL Time Frame")
// https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html
hlGaps = input.bool(true, "HL Gaps")
hlLookahead = input.bool(true, "HL Lookahead")

adxlen = input(1, title="ADX Smoothing")
dilen = input(5, title="DI Length")

adxTarget = input(25, title="Minimum Line")
hline(adxTarget, title="Minimum Line", color=color.green, linestyle=hline.style_solid)

adxMaximum = input(75, title="Maximum Line")
hline(adxMaximum, title="Maximum Line", color=color.red, linestyle=hline.style_solid)



dirmov(len) =>

	up = ta.change(request.security(syminfo.tickerid, hlTimeframe, high, gaps=hlGaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead=hlLookahead ? barmerge.lookahead_on : barmerge.lookahead_off))
	down = -ta.change(request.security(syminfo.tickerid, hlTimeframe, low, gaps=hlGaps ? barmerge.gaps_on : barmerge.gaps_off, lookahead=hlLookahead ? barmerge.lookahead_on : barmerge.lookahead_off))
	plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
	minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
	truerange = ta.rma(ta.tr, len)
	plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
	minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
	[plus, minus]
adx(dilen, adxlen) =>
	[plus, minus] = dirmov(dilen)
	sum = plus + minus
	adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)
sig = adx(dilen, adxlen)
plot(sig, color=color.teal, title="ADXx")
````
