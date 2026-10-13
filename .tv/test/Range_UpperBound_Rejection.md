<!-- tradingview-pine-id: PUB;72fe17dae36d4620bbd5bde63319c86a -->
<!-- tradingviewscripts-format: 1 -->
# Range Upper-Bound Rejection

Source: https://www.tradingview.com/script/JDeofDst-Range-Upper-Bound-Rejection/

## Description

Script scores.
1) 0 for ignore
2) 1 if stock is most at upper bound in rangebound

---

## Source Code

````pine
//@version=6
indicator("Range Upper-Bound Rejection", overlay=true)

// ── Inputs ────────────────────────────────────────────────
lookback = input.int(60, "Range lookback (bars)", minval=20,
     tooltip="How many bars define the range. 60 daily bars ≈ 3 months")
maxWidth = input.float(15.0, "Max range width (%)", minval=3.0,
     tooltip="If high-to-low of the lookback window is wider than this, it's not a range — no signals")
touchTol = input.float(1.5, "Touch tolerance (%)", minval=0.1,
     tooltip="How close to the upper bound counts as a 'touch'")
cooldown = input.int(5, "Min bars between signals", minval=1,
     tooltip="Prevents one rejection from firing on 3 consecutive bars")
minRej   = input.int(2, "Min rejections = 'established' ceiling", minval=1,
     tooltip="How many prior hit-and-fails make the resistance proven")
approachPct = input.float(2.0, "Approach zone (% below range top)", minval=0.5,
     tooltip="Flags stocks this close below the upper bound — pre-rejection watch zone")

// ── Range detection ───────────────────────────────────────
// [1] = exclude current bar so the bound isn't defined by the bar testing it
upperBound = ta.highest(high, lookback)[1]
lowerBound = ta.lowest(low, lookback)[1]
widthPct   = (upperBound - lowerBound) / lowerBound * 100
inRange    = widthPct <= maxWidth

// ── Rejection logic ───────────────────────────────────────
touchZone  = upperBound * (1 - touchTol / 100)
touched    = high >= touchZone                 // price reached the upper bound
failedBack = close < touchZone and close < open // and closed back down, red candle
upperWick  = (high - math.max(open, close)) >= math.abs(close - open) * 0.5
             // rejection wick at least half the body (your pin bar rule)

rawSignal = inRange and touched and failedBack and upperWick

// ── Cooldown so one rejection = one signal ────────────────
var int lastSignalBar = -99999
signal = rawSignal and (bar_index - lastSignalBar >= cooldown)
if signal
    lastSignalBar := bar_index

// ── Count rejections in current range ─────────────────────
var int rejCount = 0
if signal
    rejCount += 1
if not inRange
    rejCount := 0

// ── Plots ─────────────────────────────────────────────────
plot(inRange ? upperBound : na, "Range top",    color=color.new(color.red, 0),   style=plot.style_linebr, linewidth=2)
plot(inRange ? lowerBound : na, "Range bottom", color=color.new(color.green, 0), style=plot.style_linebr, linewidth=2)
plot(inRange ? touchZone : na,  "Touch zone",   color=color.new(color.red, 70),  style=plot.style_linebr)

plotshape(signal, "Rejection", style=shape.triangledown,
     location=location.abovebar, color=color.red, size=size.small, text="FAIL")

if barstate.islast and inRange
    label.new(bar_index, upperBound,
         text="Rejections: " + str.tostring(rejCount) + "\nWidth: " + str.tostring(widthPct, "#.#") + "%",
         style=label.style_label_down, color=color.new(color.red, 80), textcolor=color.white)

// ── Composite setup logic (your three filters in one) ────
distToTop   = (upperBound - close) / close * 100
approaching = inRange and not signal and distToTop > 0 and distToTop <= approachPct

// 3 = rejection NOW at an established ceiling (>= minRej hits)  ← best setup
// 2 = rejection NOW, first/early touch of the range top
// 1 = approaching the top (within approach zone) — set your alert
// 0 = nothing
score = signal and rejCount >= minRej ? 3 : signal ? 2 : approaching ? 1 : 0

// ── Pine Screener outputs (hidden on chart, filterable) ───
plot(score,               "Setup score (3/2/1/0)",    display=display.none)
plot(signal ? 1 : 0,      "Rejection NOW (1=yes)",    display=display.none)
plot(inRange ? 1 : 0,     "In range (1=yes)",         display=display.none)
plot(rejCount,            "Rejections this range",    display=display.none)
plot(widthPct,            "Range width %",            display=display.none)
plot(distToTop,           "Dist to range top %",      display=display.none)

// ── Alert ─────────────────────────────────────────────────
alertcondition(signal, "Upper-bound rejection",
     "{{ticker}}: hit range top {{high}} and failed — closed {{close}}")
alertcondition(approaching, "Approaching range top",
     "{{ticker}}: within approach zone of range top — watch for rejection")
````
