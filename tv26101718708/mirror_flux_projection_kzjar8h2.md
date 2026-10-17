# Mirror Flux Projection 

- url: https://www.tradingview.com/script/kzjar8h2/
- type: indicator
- pine_id: PUB;4ff3129012744c409aec468499cfc51f
- version: 1.0

## Description

**Mirror Flux Projection System**

This indicator is a dynamic market structure model built on a combination of trend, volatility, and momentum behavior. It is designed for visual analysis of price movement, not for automated execution.

The core structure is based on a smoothed EMA trend framework combined with a mirrored price projection model. The “mirror” component represents an inverse pressure of price action around the EMA, helping to visualize potential equilibrium shifts and directional bias.

The system adapts its behavior using ATR-based volatility scaling and OBV-driven flow bias. This allows the structure to expand during high volatility regimes and contract during low volatility conditions, creating a dynamic adaptive channel around price.

A forward projection component extends the current market structure into the future by a fixed number of bars. These projected lines are **not predictions**, but scenario-based estimations of possible trend continuation paths derived from current slope and volatility conditions.

Within this projected zone, a dynamic Fibonacci framework is applied. The Fib levels (0.236, 0.382, 0.5, 0.618, 0.786) are calculated based on the projected upper and lower boundaries of the future band. These levels represent potential equilibrium and reaction zones where price may react during continuation or retracement phases.

The color heatmap reflects distance from the central equilibrium line:

* Green zones indicate bullish pressure above equilibrium
* Red zones indicate bearish pressure below equilibrium
* Intensity increases with deviation strength from the center

This tool is designed for:

* Trend structure visualization
* Volatility expansion/contraction analysis
* Dynamic support/resistance projection
* Market regime interpretation

⚠️ Note: Forward projection lines are hypothetical scenario paths based on current conditions and should not be interpreted as guaranteed future price movement.

---

**[ SHARE INDICATOR ]**

## Source Code

````pine
//@version=5
indicator("Mirror Flux Projection FIXED FINAL", overlay=true, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
len     = input.int(200, "Trend Length")
projLen = input.int(28, "Projection Length")
atrLen  = input.int(14)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaBase  = ta.ema(close, len)
priceMid = ta.ema(close, 34)

// merkez artık fiyat bazlı
center = priceMid

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MIRROR (SIGNAL ONLY)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
mirror = emaBase * 2 - close
mirrorBull = mirror > emaBase

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR BAND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
width = atr * 2.2

upper = center + width
lower = center - width

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SLOPE PROJECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
baseSlope = emaBase - emaBase[1]
slope = baseSlope * (mirrorBull ? 1.2 : 0.8)

midFut   = center + slope * projLen
upperFut = midFut + width
lowerFut = midFut - width

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEATMAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
dist = close - center
norm = atr != 0 ? dist / atr : 0.0

strength = math.min(math.abs(norm), 2)
transp = 90 - int(strength * 35)
transp := math.max(10, math.min(95, transp))

col = norm >= 0 ?
     color.new(color.lime, transp) :
     color.new(color.red, transp)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT BAND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
p1 = plot(upper, color=color.new(color.green, 60))
p2 = plot(lower, color=color.new(color.red, 60))
fill(p1, p2, col)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUTURE BAND (VISIBLE PROJECTION)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
p3 = plot(upperFut, offset=projLen, color=color.new(color.green, 70), linewidth=1)
p4 = plot(lowerFut, offset=projLen, color=color.new(color.red, 70), linewidth=1)

fill(p3, p4, color=color.new(col, 20))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROJECTION LINES (IMPORTANT PART FIX)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line midLine = na
var line upLine  = na
var line lowLine = na

// ilk oluşum
if na(midLine)
    midLine := line.new(bar_index, center, bar_index + projLen, midFut, width=2, color=color.white)
    upLine  := line.new(bar_index, upper,  bar_index + projLen, upperFut, color=color.lime)
    lowLine := line.new(bar_index, lower,  bar_index + projLen, lowerFut, color=color.red)

// güncelleme
line.set_xy1(midLine, bar_index, center)
line.set_xy2(midLine, bar_index + projLen, midFut)

line.set_xy1(upLine, bar_index, upper)
line.set_xy2(upLine, bar_index + projLen, upperFut)

line.set_xy1(lowLine, bar_index, lower)
line.set_xy2(lowLine, bar_index + projLen, lowerFut)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(center, color=color.white, linewidth=2)
plot(emaBase, color=color.gray)
plot(mirror, color=mirrorBull ? color.lime : color.red)
````
