# Volatility Bands Pro-Read [Indicatr]

- url: https://www.tradingview.com/script/EevVUTrK-Volatility-Bands-Pro-Read-Indicatr/
- type: indicator
- pine_id: PUB;b60e6a62c96947478990cc4d121efe76
- version: 1.0

## Description

[b]Volatility Bands Pro-Read[/b] draws Bollinger Bands, Keltner Channels or Donchian Channels and reads the band behaviour for you: band walk (trend), mean-reversion candidates (no trend) and squeeze - for both directions.

[b]WHAT IT DOES[/b]
A common misreading is "price touches the upper band = sell". In a strong trend price can walk along the band for a long time. This script separates band walks from mean-reversion situations using band position and ADX.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Band type:[/b] Bollinger, Keltner or Donchian. The script calculates where the close sits inside the band (0 = lower, 1 = upper).
[*][b]Band walk:[/b] if ADX shows a trend and several recent closes sit in the outer zone (default 3 of the last 5 above 0.8 or below 0.2), bands and fill are coloured green (walk up) or red (walk down).
[*][b]Mean-reversion candidates:[/b] when ADX shows no trend and price closes back inside the band after closing outside it, a small cross is marked (long below, short above).
[*][b]Squeeze:[/b] when Bollinger Bands are inside the Keltner Channel, dots are shown at the bottom. When the squeeze ends, the release is marked above or below the basis.
[/list]

[b]HOW TO USE[/b]
[list]
[*]Band walk colouring: treat touches of the outer band as trend strength, not as reversal signals.
[*]Mean-reversion marks are only relevant in non-trending conditions.
[*]Squeeze marks show compressed volatility. The release does not predict the size of the move.
[*]Alerts: band walk up/down started, squeeze fired up/down, mean-reversion candidate.
[/list]

[b]THE CHART[/b]
XAUUSD (gold) daily with Bollinger Bands (20, 2). Green sections are band walks up, red sections band walks down, grey sections are neutral. Dots at the bottom mark squeeze phases, triangles the squeeze release, crosses mean-reversion candidates.

[b]WHAT IS ORIGINAL[/b]
Standard band indicators only draw lines. This script classifies band behaviour (walk vs. reversion) using band position and ADX, and adds squeeze detection for any selected band type.

[b]CREDITS[/b]
Bollinger Bands (John Bollinger), Keltner Channel (Chester Keltner, ATR version by Linda Raschke), Donchian Channel (Richard Donchian), squeeze concept (John Carter), ADX (J. Welles Wilder).

[b]LIMITATIONS[/b]
[list]
[*]Classification is based on recent closes and ADX and can change on the current bar.
[*]Squeeze release direction is based on the close relative to the basis and can reverse.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Volatility Bands Pro-Read [Indicatr]", shorttitle="VB Pro-Read [Indicatr]", overlay=true)

// ===== Inputs =====
grpB = "Band"
bType = input.string("Bollinger", "Band type", options=["Bollinger", "Keltner", "Donchian"], group=grpB)
len   = input.int(20, "Length", minval=2, group=grpB)
bbMult = input.float(2.0, "Bollinger multiplier", minval=0.1, step=0.1, group=grpB)
kcMult = input.float(1.5, "Keltner ATR multiplier", minval=0.1, step=0.1, group=grpB)

grpW = "Band walk vs. mean reversion"
walkN   = input.int(5, "Band walk: lookback bars", minval=2, group=grpW)
walkK   = input.int(3, "Band walk: min. closes in outer zone", minval=1, group=grpW)
outerPct = input.float(0.8, "Outer zone (position in band, 0-1)", minval=0.5, maxval=1.0, step=0.05, group=grpW)
adxL    = input.int(14, "ADX length", minval=2, group=grpW)
adxThr  = input.float(20, "ADX trend threshold", minval=1, group=grpW)

grpS = "Squeeze"
showSqz = input.bool(true, "Show squeeze (Bollinger inside Keltner)", group=grpS)

grpD = "Display"
colUp  = input.color(#1B5E40, "Walk up / bullish", group=grpD, inline="c")
colDn  = input.color(#C0412F, "Walk down / bearish", group=grpD, inline="c")
colN   = input.color(#8A8A8A, "Neutral", group=grpD, inline="c")
showMR = input.bool(true, "Mark mean-reversion candidates (no trend)", group=grpD)

// ===== Bands =====
basisSMA = ta.sma(close, len)
dev  = ta.stdev(close, len)
emaB = ta.ema(close, len)
atr  = ta.atr(len)
bbU = basisSMA + bbMult * dev
bbL = basisSMA - bbMult * dev
kcU = emaB + kcMult * atr
kcL = emaB - kcMult * atr
dcU = ta.highest(high, len)
dcL = ta.lowest(low, len)

[upper, lower, basis] = switch bType
    "Bollinger" => [bbU, bbL, basisSMA]
    "Keltner"   => [kcU, kcL, emaB]
    => [dcU, dcL, (dcU + dcL) / 2]

pos = (close - lower) / math.max(upper - lower, syminfo.mintick)

// ===== States =====
[diP, diM, adx] = ta.dmi(adxL, adxL)
trending = adx > adxThr
upCnt = math.sum(pos >= outerPct ? 1 : 0, walkN)
dnCnt = math.sum(pos <= 1 - outerPct ? 1 : 0, walkN)
walkUp = trending and upCnt >= walkK
walkDn = trending and dnCnt >= walkK

// Mean-reversion candidates: no trend, price closes back inside after leaving the band
mrShort = showMR and not trending and close[1] > upper[1] and close < upper
mrLong  = showMR and not trending and close[1] < lower[1] and close > lower

// Squeeze: Bollinger Bands inside Keltner Channel
sqz = bbU < kcU and bbL > kcL
fired = sqz[1] and not sqz
fireUp = fired and close > basis
fireDn = fired and close < basis

// ===== Plots =====
state = walkUp ? 1 : walkDn ? -1 : 0
bandCol = state == 1 ? colUp : state == -1 ? colDn : colN
pU = plot(upper, "Upper", color=bandCol)
pL = plot(lower, "Lower", color=bandCol)
plot(basis, "Basis", color=color.new(colN, 40), style=plot.style_line)
fill(pU, pL, color=state == 1 ? color.new(colUp, 88) : state == -1 ? color.new(colDn, 88) : color.new(colN, 94), title="Band fill")

plotshape(showSqz and sqz, "Squeeze on", shape.circle, location.bottom, color.new(colN, 0), size=size.tiny)
plotshape(showSqz and fireUp, "Squeeze fired up", shape.triangleup, location.belowbar, colUp, size=size.small)
plotshape(showSqz and fireDn, "Squeeze fired down", shape.triangledown, location.abovebar, colDn, size=size.small)
plotshape(mrShort, "Mean-reversion short candidate", shape.xcross, location.abovebar, color.new(colDn, 20), size=size.tiny)
plotshape(mrLong,  "Mean-reversion long candidate",  shape.xcross, location.belowbar, color.new(colUp, 20), size=size.tiny)

alertcondition(walkUp and not walkUp[1], "Band walk up started", "Volatility Bands: band walk up (trend) started")
alertcondition(walkDn and not walkDn[1], "Band walk down started", "Volatility Bands: band walk down (trend) started")
alertcondition(fireUp, "Squeeze fired up", "Volatility Bands: squeeze released above basis")
alertcondition(fireDn, "Squeeze fired down", "Volatility Bands: squeeze released below basis")
alertcondition(mrLong or mrShort, "Mean-reversion candidate", "Volatility Bands: close back inside band, no trend")
````
