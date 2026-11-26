# Weak Impulse Fib Setup Detector

- url: https://www.tradingview.com/script/E4Upe9QJ-Weak-Impulse-Fib-Setup-Detector/
- type: indicator
- pine_id: PUB;246fcfef86db4d77a19a919462097ce5
- version: 1.0

## Description

Weak Impulse Detection (3 conditions must all be true):

Structure break — uses pivot highs/lows (configurable lookback, default 3 bars each side) to detect when price breaks above a prior swing high (bullish) or below a prior swing low (bearish)
Impulse body — candle body is strictly larger than the total wick (upper + lower combined)
Below-average volume — current bar volume is under the 20-period volume MA

Visuals on trigger:

The weak impulse candle is colored purple
A purple bracket box spans the candle's high→low range and extends right
A red dashed SL line at the -0.2 fib level (above the candle high for bulls, below the candle low for bears)
A green dashed TP line at the 0.5 fib level (midpoint of the candle range)
Labels showing fib level and price for SL, TP, and a directional badge (⚡ WEAK BULL / ⚡ WEAK BEAR)

All key settings are adjustable in the inputs panel:

Volume MA length
SL/TP fib values
Swing lookback bars
Line extension length
All colors

## Source Code

````pine
//@version=5
indicator("Weak Impulse Fib", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
volMaLength     = input.int(20,    "Volume MA Length",         minval=1)
fibSL           = input.float(-0.2, "Stop Loss Fib Level",     step=0.1)
fibTP           = input.float(0.5,  "Take Profit Fib Level",   step=0.1)
showLabels      = input.bool(true,  "Show SL/TP Labels")
colorWeak       = input.color(color.new(color.purple, 0), "Weak Impulse Candle Color")
colorSL         = input.color(color.new(color.red,    0), "Stop Loss Line Color")
colorTP         = input.color(color.new(color.green,  0), "Take Profit Line Color")
colorFibBox     = input.color(color.new(color.purple, 85), "Fib Box Fill Color")
extendBars      = input.int(8, "Extend Fib Lines (bars)", minval=1, maxval=50)

// ─────────────────────────────────────────────
// VOLUME MA
// ─────────────────────────────────────────────
volMA = ta.sma(volume, volMaLength)

// ─────────────────────────────────────────────
// STRUCTURE BREAK DETECTION
// Uses a simple swing high/low approach:
//   Bullish break = current high exceeds the previous swing high
//   Bearish break = current low falls below the previous swing low
// ─────────────────────────────────────────────
swingLen = input.int(3, "Swing Lookback (bars each side)", minval=1, maxval=10,
     tooltip="Number of bars on each side used to confirm a swing high/low for structure detection.")

// Detect prior swing highs and lows (confirmed pivots)
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low,  swingLen, swingLen)

// Track last confirmed swing levels (carry forward)
var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(swingHigh)
    lastSwingHigh := swingHigh
if not na(swingLow)
    lastSwingLow  := swingLow

// Structure break conditions
bullishBreak = not na(lastSwingHigh) and high > lastSwingHigh[swingLen]
bearishBreak = not na(lastSwingLow)  and low  < lastSwingLow[swingLen]

// ─────────────────────────────────────────────
// IMPULSE CANDLE BODY > WICK
// Body must be strictly larger than total wick
// ─────────────────────────────────────────────
body      = math.abs(close - open)
totalWick = (high - math.max(close, open)) + (math.min(close, open) - low)
isImpulse = body > totalWick

// ─────────────────────────────────────────────
// WEAK IMPULSE CONDITIONS
// ─────────────────────────────────────────────
weakBull = bullishBreak and isImpulse and (close > open) and (volume < volMA)
weakBear = bearishBreak and isImpulse and (close < open) and (volume < volMA)
isWeak   = weakBull or weakBear

// ─────────────────────────────────────────────
// COLOR WEAK IMPULSE CANDLES PURPLE
// ─────────────────────────────────────────────
barcolor(isWeak ? colorWeak : na)

// ─────────────────────────────────────────────
// FIB RETRACEMENT BRACKETS
// For a bullish weak impulse: high = 1.0, low = 0.0
//   SL  = high + (high - low) * abs(fibSL)      → below low  (-0.2 ext)
//   TP  = low  + (high - low) * fibTP            → 50% up
// For a bearish weak impulse: low = 1.0, high = 0.0
//   SL  = low  - (high - low) * abs(fibSL)       → above high (-0.2 ext)
//   TP  = high - (high - low) * fibTP            → 50% down
// ─────────────────────────────────────────────
if isWeak
    candleHigh = high
    candleLow  = low
    candleRange = candleHigh - candleLow

    float slLevel = na
    float tpLevel = na

    if weakBull
        // MR: fading the move — SL above the high (-0.2 ext above), TP below at 0.5
        slLevel := candleHigh - candleRange * fibSL   // fibSL is negative → above high
        tpLevel := candleHigh - candleRange * fibTP   // 0.5 → midpoint

    if weakBear
        // MR: fading the move — SL below the low (-0.2 ext below), TP above at 0.5
        slLevel := candleLow  + candleRange * fibSL   // fibSL is negative → below low
        tpLevel := candleLow  + candleRange * fibTP   // 0.5 → midpoint

    startBar = bar_index
    endBar   = bar_index + extendBars

    // ── Fib bracket box (range of candle body for visual reference) ──
    box.new(
         left   = startBar,
         top    = candleHigh,
         right  = endBar,
         bottom = candleLow,
         border_color = color.new(colorWeak, 40),
         border_width = 1,
         bgcolor = colorFibBox)

    // ── Stop Loss line (-0.2 fib) ──
    line.new(
         x1    = startBar,
         y1    = slLevel,
         x2    = endBar,
         y2    = slLevel,
         color = colorSL,
         width = 2,
         style = line.style_dashed)

    // ── Take Profit line (0.5 fib) ──
    line.new(
         x1    = startBar,
         y1    = tpLevel,
         x2    = endBar,
         y2    = tpLevel,
         color = colorTP,
         width = 2,
         style = line.style_dashed)

    // ── Labels ──
    if showLabels
        label.new(
             x      = endBar,
             y      = slLevel,
             text   = "SL  " + str.tostring(fibSL) + " fib\n" + str.tostring(math.round(slLevel, 2)),
             color  = colorSL,
             textcolor = color.white,
             style  = weakBull ? label.style_label_left : label.style_label_left,
             size   = size.small)

        label.new(
             x      = endBar,
             y      = tpLevel,
             text   = "TP  " + str.tostring(fibTP) + " fib\n" + str.tostring(math.round(tpLevel, 2)),
             color  = colorTP,
             textcolor = color.white,
             style  = label.style_label_left,
             size   = size.small)

        // Direction badge on the candle
        label.new(
             x      = startBar,
             y      = weakBull ? candleHigh : candleLow,
             text   = weakBull ? "⚡ WEAK BULL" : "⚡ WEAK BEAR",
             color  = colorWeak,
             textcolor = color.white,
             style  = weakBull ? label.style_label_down : label.style_label_up,
             size   = size.small)

// ─────────────────────────────────────────────
// VOLUME MA PLOT (optional reference)
// ─────────────────────────────────────────────
plot(volMA, title="Vol MA (20)", display=display.none)   // hidden by default; enable in Style tab if desired
````
