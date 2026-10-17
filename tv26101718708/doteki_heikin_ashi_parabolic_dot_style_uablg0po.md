# Doteki Heikin Ashi (Parabolic Dot Style)

- url: https://www.tradingview.com/script/Uablg0Po-Doteki-Heikin-Ashi-Parabolic-Dot-Style/
- type: indicator
- pine_id: PUB;92a3cb24fc134c3185fb20e2db53ad0e
- version: 1.0

## Description

This indicator is an adjustable Heikin Ashi indicator with Parabolic Sar style dots on chart display. It works great as an exit signal but can be used in various ways depending on your strategy.

## Source Code

````pine
//@version=5
indicator(title="Dōteki Heikin Ashi (Parabolic Dot Style)", shorttitle="DHA SAR", overlay=true)

// === Inputs ===
i_period      = input.int(3, "Averaging i_period for Heikin Ashi", minval=1)
i_zeroLag     = input.bool(false, "Use Zero-Lag Exponential Averaging")
showCloseLine = input.bool(false, "Show Standard Close Line")

// === EMA Weight
emaWeight = 2.0 / (i_period + 1.0)

// === Heikin Ashi-like Close (smoothed price)
haClose = (open + high + low + close) / 4

// === EMA / ZEMA Logic
var float ema = na
var float dema = na
var float zema = na

ema := na(ema) ? haClose : ema + (haClose - ema) * emaWeight

if i_zeroLag
    dema := na(dema) ? ema : dema + (ema - dema) * emaWeight
    zema := 2 * ema - dema
else
    zema := ema

// === DHA Price Constructs
dhaOpen  = math.round_to_mintick(zema)
dhaClose = math.round_to_mintick(haClose)
dhaHigh  = math.max(math.max(high, dhaOpen), dhaClose)
dhaLow   = math.min(math.min(low, dhaOpen), dhaClose)

isUp     = dhaClose > dhaOpen
isDown   = dhaClose < dhaOpen
dotColor = isUp ? color.lime : isDown ? color.red : color.gray

// === SAR-like Dot Offset
dotOffset = syminfo.mintick * 5
dhaDot = isUp ? dhaLow - dotOffset : dhaHigh + dotOffset

// === Plot tiny dots like Parabolic SAR
plot(dhaDot, title="DHA SAR Dots", color=dotColor, style=plot.style_circles, linewidth=1)

// === Optional: Standard close line
plot(showCloseLine ? close : na, "Close", color=color.silver, linewidth=1)
````
