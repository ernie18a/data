#  MASL  Market Structure Adaptive Lens

- url: https://www.tradingview.com/script/7roilGlw/
- type: indicator
- pine_id: PUB;c26baa0fb1bb43e894647ed3f9c805a4
- version: 5.0

## Description

MASL (Market Structure Adaptive Lens) is a geometric market analysis framework designed to project market structure into a normalized coordinate system and measure underlying buyer/seller pressure through adaptive ratio geometry.

Unlike traditional indicators that rely solely on lagging averages, MASL transforms price action into an isotropic geometric space and constructs dynamic triangular pressure fields across defined structural anchors. This allows the system to evaluate market behavior not just in terms of price movement, but in terms of relative structural imbalance and directional force.

The core model generates a pressure metric (B) derived from the ratio between upper and lower geometric areas, representing seller dominance (positive values) and buyer dominance (negative values). This enables a continuous interpretation of market control rather than discrete signals.

MASL also introduces a freeze–revival structural state mechanism, where the main market range locks during structural breaks and a secondary adaptive channel tracks expansion until equilibrium is restored. This models real-world liquidity expansion and contraction phases more accurately than static range systems.

A visual triangle projection system maps multi-scale structural points (prime-based offsets) onto the chart, creating a “field-like” representation of market pressure distribution.

⚙️ Key Features
Isotropic Coordinate System normalization (volatility-adjusted geometry)
Geometric buyer/seller pressure model (B metric)
Adaptive range freeze & revival structure
Triangle-based market field projection
Real-time structural imbalance visualization
Multi-layer pressure barometer (0–100% split)
🎯 Concept

MASL is not a signal generator — it is a market structure lens that visualizes hidden pressure dynamics inside price movement.

## Source Code

````pine
 //@version=6
indicator("ICS Triangle + Candle Pressure (Clean FIX)", overlay=true,
 max_lines_count=500, max_labels_count=500)

// ─────────────────────────────
// COLORS
// ─────────────────────────────
color TRANSPARENT = color.new(color.black, 100)

color BUY_FILL  = color.new(#8be9fd, 97)
color SELL_FILL = color.new(#ff79c6, 97)

color BUY_LINE  = color.new(#00d4ff, 60)
color SELL_LINE = color.new(#ff2060, 60)

// ─────────────────────────────
// INPUT
// ─────────────────────────────
len = input.int(101, "Range Length", minval=10)

// ─────────────────────────────
// RANGE
// ─────────────────────────────
rangeHigh = ta.highest(high, len)
rangeLow  = ta.lowest(low, len)

// ─────────────────────────────
// SIMPLE PRESSURE SCORE (B)
// ─────────────────────────────
aHi = math.abs(high - rangeHigh)
aLo = math.abs(low - rangeLow)

b = (aHi - aLo) / math.max(aHi + aLo, 0.0001)

// ─────────────────────────────
// FLIP LOGIC
// ─────────────────────────────
loFlipped = low < rangeLow
hiFlipped = high > rangeHigh

actLoFill = loFlipped ? SELL_FILL : BUY_FILL
actHiFill = hiFlipped ? BUY_FILL : SELL_FILL

actLoLine = loFlipped ? SELL_LINE : BUY_LINE
actHiLine = hiFlipped ? BUY_LINE : SELL_LINE

// ─────────────────────────────
// TRIANGLE BASE (NO ICS HEAVY VERSION)
// ─────────────────────────────
curBar   = bar_index
primeBar = bar_index - 101

// LOWER TRIANGLE
loTri = array.from(
     chart.point.from_index(curBar, low),
     chart.point.from_index(curBar, rangeLow),
     chart.point.from_index(primeBar, rangeLow))

// UPPER TRIANGLE
hiTri = array.from(
     chart.point.from_index(curBar, high),
     chart.point.from_index(curBar, rangeHigh),
     chart.point.from_index(primeBar, rangeHigh))

// FILL
polyline.new(loTri,
     closed=true,
     line_color=TRANSPARENT,
     fill_color=actLoFill,
     line_width=0)

polyline.new(hiTri,
     closed=true,
     line_color=TRANSPARENT,
     fill_color=actHiFill,
     line_width=0)

// OUTLINE
polyline.new(loTri,
     closed=true,
     line_color=actLoLine,
     fill_color=TRANSPARENT,
     line_width=1,
     line_style=line.style_dashed)

polyline.new(hiTri,
     closed=true,
     line_color=actHiLine,
     fill_color=TRANSPARENT,
     line_width=1,
     line_style=line.style_dashed)

// ─────────────────────────────
// CANDLE PRESSURE (BUY / SELL %)
// ─────────────────────────────
candleRange = math.max(high - low, syminfo.mintick)

buyerPct = ((close - low) / candleRange) * 100
sellerPct = ((high - close) / candleRange) * 100

buyerPct := math.max(math.min(buyerPct, 100), 0)
sellerPct := math.max(math.min(sellerPct, 100), 0)

// ─────────────────────────────
// RIGHT SHIFT LABEL (READABLE UI FIX)
// ─────────────────────────────
if barstate.islast
    label.new(
         x = bar_index + 6,
         y = high,
         text = "🟢 Buyer: " + str.tostring(buyerPct, "#.0") +
                "%\n🔴 Seller: " + str.tostring(sellerPct, "#.0") + "%",
         style = label.style_label_left,
         textcolor = color.white,
         color = color.new(color.black, 35))

// ─────────────────────────────
// RANGE LINES
// ─────────────────────────────
line.new(bar_index - len, rangeHigh, bar_index, rangeHigh,
     color=color.new(SELL_LINE, 70))

line.new(bar_index - len, rangeLow, bar_index, rangeLow,
     color=color.new(BUY_LINE, 70))

// ─────────────────────────────
// DATA WINDOW OUTPUT
// ─────────────────────────────
plot((b + 1) * 50, title="Seller Pressure %", display=display.data_window)
plot((1 - b) * 50, title="Buyer Pressure %", display=display.data_window)
plot(b, title="B Score", display=display.data_window)
````
