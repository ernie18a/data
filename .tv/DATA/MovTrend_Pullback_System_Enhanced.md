<!-- tradingview-pine-id: PUB;05a03331fac240ff8eb368d137136047 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MovTrend Pullback System - Enhanced

Source: https://www.tradingview.com/script/T5lxS1np-MovTrend-Pullback-System/

## Description

What it is: A trend-following 5 minute indicator built around a linear regression trend line ("MovTrend") with ATR-based volatility bands. It generates four distinct signal types, each answering a different question about price action relative to the trend.

Core components

MovTrend Line (MT) — A linear regression line (ta.linreg) plotted over price, colored by direction: green when sloping up, red when sloping down, gray when flat. This is the trend backbone everything else references.

Slope — The MT line's rate of change over a lookback window, plotted as a histogram in the lower pane. Crossing above/below configurable thresholds marks a "confirmed" up or down trend (green/red bars); values between thresholds are a gray "no-trade zone" where the trend isn't strong enough to trust.

ATR Bands — Upper/lower bands plotted around the MT line at a multiple of ATR, representing a "normal" volatility envelope. Price moving outside these bands is considered stretched/overextended relative to the trend.

The four signals

🟢 Buy Dot / 🔴 Sell Dot (Pullback Touch)
Fires when price dips down and touches the MT line during a confirmed uptrend (buy), or pokes up and touches it during a downtrend (sell), then closes back in the trend's favor. This is the core "buy the dip / sell the rip" signal — a shallow pullback to the trend line that holds.

🟡 Stretch Dot (Mean-Reversion Warning)
Fires when price closes outside the ATR bands — i.e., stretched further from the trend line than normal volatility would suggest. Dot size scales with how extreme the stretch is (tiny = mild, small = moderate, orange/normal = extreme), giving you an at-a-glance read on how overextended price is. This isn't a reversal signal on its own — it's a caution flag that price may be due to snap back toward the MT line. It's filtered by:

Volatility regime — suppressed during low-volatility chop, since a "stretch" in dead conditions is less meaningful
FVG confluence — checks if price is near a fair value gap, adding context to the stretch
Volume — requires above-average volume to confirm real participation, not just a thin drift
Slope deceleration — confirms the trend itself is actually losing momentum, not just that price poked outside the band

🔷 Trend Continuation Diamond (cyan up / magenta down)
Fires on a high-volume push with the trend, away from the MT line — meant to catch strong continuation moves the pullback-touch signal misses (since it only fires on touches, not on strength). It's built specifically to avoid firing at exhaustion tops/bottoms by requiring:

Volume that is not the largest in the recent lookback window (avoids climactic blow-off bars)
Slope that's still accelerating, not flattening
A cooldown between diamonds so one strong leg doesn't spam multiple signals
Filters that apply across signals
Session filter — dims the chart and can gate signals outside your configured trading hours, since overnight/thin-liquidity behavior isn't comparable to regular session action
MTF confirmation — optionally requires a higher timeframe's slope to agree before a buy/sell touch fires, filtering out signals that look right locally but fight the bigger picture
Signal conflict resolution — a Trend Continuation diamond won't fire on the same bar as a Buy/Sell touch, avoiding mixed signals
Performance tracking table

How to read it together

The intended workflow: use the MT line + slope histogram to establish trend context, take Buy/Sell touches as primary pullback entries in the direction of that trend, treat Stretch dots as a caution/take-profit signal rather than a new entry, and use Continuation diamonds as confirmation that a trend still has legs when you're already in a position or considering adding.

---

## Source Code

````pine
//@version=6
indicator("MovTrend Pullback System - Enhanced", overlay = false, max_labels_count = 500, max_boxes_count = 200)

// ── Inputs ──────────────────────────────────────────────
mtLen      = input.int(21, "MovTrend Length (LinReg)", minval = 2, group = "MovTrend Line")
atrLen     = input.int(14, "ATR Length", minval = 1, group = "ATR Bands")
atrMult    = input.float(1.5, "ATR Band Multiplier", minval = 0.1, step = 0.1, group = "ATR Bands")
slopeLen   = input.int(5, "Slope Lookback (bars)", minval = 1, group = "Slope / Trend")
upThresh   = input.float(0.50, "Upper Threshold (confirmed uptrend)", group = "Slope / Trend")
dnThresh   = input.float(-0.50, "Lower Threshold (confirmed downtrend)", group = "Slope / Trend")
showBands  = input.bool(true, "Show ATR Bands", group = "Display")
showDots   = input.bool(true, "Show ShowMe Dots", group = "Display")

// >>> ADDED: #1 first-occurrence-only control for stretch dots
dotsFirstOccurrenceOnly = input.bool(true, "Only show first stretch dot per event", group = "Display")

// >>> ADDED: #2 Volatility Regime Filter — suppress stretch signals in low-vol chop
useRegimeFilter   = input.bool(true, "Suppress stretch signals in low-vol regime", group = "Volatility Regime")
regimeHardFilter  = input.bool(true, "Make regime filter mandatory (hides dots, not just alerts)", group = "Volatility Regime")
regimeLookback    = input.int(50, "ATR percentile lookback", minval = 10, group = "Volatility Regime")
regimeMinPctl     = input.float(25, "Min ATR percentile to allow stretch signals", minval = 0, maxval = 100, group = "Volatility Regime")

// >>> ADDED: #3 FVG Confluence Filter
useFvgFilter      = input.bool(true, "Require/highlight FVG confluence on stretch", group = "FVG Confluence")
fvgHardFilter     = input.bool(false, "Make FVG confluence mandatory", group = "FVG Confluence")
fvgProximityATR   = input.float(0.25, "FVG proximity (x ATR)", minval = 0.0, step = 0.05, group = "FVG Confluence")
fvgMaxZones       = input.int(20, "Max stored FVG zones", minval = 5, maxval = 50, group = "FVG Confluence")
showFvgBoxes      = input.bool(false, "Draw FVG zones on chart", group = "FVG Confluence")

// >>> ADDED: #4 Volume Filter — this script had no volume logic at all
useVolumeFilter   = input.bool(true, "Require above-average volume on stretch", group = "Volume Filter")
volHardFilter     = input.bool(false, "Make volume mandatory", group = "Volume Filter")
volLen            = input.int(20, "Volume average length", minval = 1, group = "Volume Filter")
volMult           = input.float(1.0, "Min volume vs average (x)", minval = 0.1, step = 0.1, group = "Volume Filter")

// >>> ADDED: #5 Slope Deceleration Filter — confirm the trend is actually losing steam
useSlopeDecelFilter  = input.bool(true, "Require slope deceleration on stretch", group = "Slope Deceleration")
slopeDecelHardFilter = input.bool(false, "Make slope deceleration mandatory", group = "Slope Deceleration")
slopeDecelLookback   = input.int(3, "Slope comparison lookback (bars)", minval = 1, group = "Slope Deceleration")

// ── MovTrend line (linear regression) + slope ───────────
mt = ta.linreg(close, mtLen, 0)
slope = mt - mt[slopeLen]

confirmedUp   = slope > upThresh
confirmedDown = slope < dnThresh
noTradeZone   = not confirmedUp and not confirmedDown

// ── ATR bands ───────────────────────────────────────────
atrVal = ta.atr(atrLen)
upperBand = mt + atrMult * atrVal
lowerBand = mt - atrMult * atrVal

// >>> ADDED: #2 ATR percentile-rank regime calc (uses the same atrVal so band width and
// regime read stay consistent; swap regimeLookback independently of atrLen if you want
// the regime read to react on a different horizon than the bands themselves)
atrPercentile = ta.percentrank(atrVal, regimeLookback)
regimeOK = not useRegimeFilter or (atrPercentile >= regimeMinPctl)

// >>> ADDED: #3 FVG detection (3-bar gap) + proximity check, current chart timeframe
var float[] fvgTopArr = array.new<float>()
var float[] fvgBotArr = array.new<float>()
var box[] fvgBoxes = array.new<box>()

bool bullFvgNew = low > high[2]
bool bearFvgNew = high < low[2]

if bullFvgNew
    array.push(fvgTopArr, low)
    array.push(fvgBotArr, high[2])
if bearFvgNew
    array.push(fvgTopArr, low[2])
    array.push(fvgBotArr, high)

if array.size(fvgTopArr) > fvgMaxZones
    array.shift(fvgTopArr)
    array.shift(fvgBotArr)

nearFvg = false
if array.size(fvgTopArr) > 0
    for i = 0 to array.size(fvgTopArr) - 1
        float zTop = array.get(fvgTopArr, i)
        float zBot = array.get(fvgBotArr, i)
        float zoneLo = math.min(zTop, zBot) - atrVal * fvgProximityATR
        float zoneHi = math.max(zTop, zBot) + atrVal * fvgProximityATR
        if close >= zoneLo and close <= zoneHi
            nearFvg := true

fvgOK = not useFvgFilter or nearFvg

if showFvgBoxes and barstate.islast
    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            box.delete(array.get(fvgBoxes, i))
        array.clear(fvgBoxes)
    if array.size(fvgTopArr) > 0
        for i = 0 to array.size(fvgTopArr) - 1
            float zTop = array.get(fvgTopArr, i)
            float zBot = array.get(fvgBotArr, i)
            array.push(fvgBoxes, box.new(bar_index - 40, math.max(zTop, zBot), bar_index, math.min(zTop, zBot), border_color = na, bgcolor = color.new(color.blue, 88), force_overlay = true))

// >>> ADDED: #4 volume calc (script had none before)
volAvg = ta.sma(volume, volLen)
hasVolume = not na(volume) and not na(volAvg) and volAvg > 0
volumeOK = not useVolumeFilter or (hasVolume and volume >= volAvg * volMult)

// >>> ADDED: #5 slope-of-slope deceleration calc
slopePrior = mt[slopeDecelLookback] - mt[slopeDecelLookback + slopeLen]
slopeDecelUp   = slope < slopePrior and slope > 0   // uptrend losing steam -> supports downside stretch reversal
slopeDecelDown = slope > slopePrior and slope < 0   // downtrend losing steam -> supports upside stretch reversal
slopeDecelOK_forStretchDown = not useSlopeDecelFilter or slopeDecelUp    // gates stretchUp (price above band, uptrend exhausting)
slopeDecelOK_forStretchUp   = not useSlopeDecelFilter or slopeDecelDown // gates stretchDown (price below band, downtrend exhausting)

// ── Plot MT line + bands on the PRICE chart (forced overlay) ──
mtColor = slope > 0 ? color.new(color.lime, 0) : slope < 0 ? color.new(color.red, 0) : color.new(color.gray, 0)
plot(mt, "MovTrend Line", color = mtColor, linewidth = 2, force_overlay = true)
upperPlot = plot(showBands ? upperBand : na, "Upper ATR Band", color = color.new(color.blue, 60), force_overlay = true)
lowerPlot = plot(showBands ? lowerBand : na, "Lower ATR Band", color = color.new(color.blue, 60), force_overlay = true)
fill(upperPlot, lowerPlot, color = color.new(color.blue, 92))

// ── Signal conditions ───────────────────────────────────
slopeUp   = slope > 0
slopeDown = slope < 0

buyTouch  = low  <= mt and close > mt
sellTouch = high >= mt and close < mt

buySignal  = slopeUp   and buyTouch
sellSignal = slopeDown and sellTouch

stretchUp     = close > upperBand
stretchDown   = close < lowerBand

// >>> ADDED: raw stretch conditions kept separate from the gated/confirmed version below,
// so you can see how much the new filters are cutting vs. the original stretchSignal
stretchUpRaw   = stretchUp
stretchDownRaw = stretchDown
stretchSignalRaw = stretchUpRaw or stretchDownRaw

// >>> ADDED: #2 #3 #4 #5 combined into the confirmed stretch condition
stretchUpConfirmed   = stretchUp   and regimeOK and fvgOK and volumeOK and slopeDecelOK_forStretchDown
stretchDownConfirmed = stretchDown and regimeOK and fvgOK and volumeOK and slopeDecelOK_forStretchUp

// hard-filter gating mirrors the pattern used elsewhere: each filter can be "soft" (visual/alert
// distinction only) or "hard" (actually removes the raw signal)
stretchUpFinal = stretchUpRaw and
     (not regimeHardFilter or regimeOK) and
     (not fvgHardFilter or fvgOK) and
     (not volHardFilter or volumeOK) and
     (not slopeDecelHardFilter or slopeDecelOK_forStretchDown)

stretchDownFinal = stretchDownRaw and
     (not regimeHardFilter or regimeOK) and
     (not fvgHardFilter or fvgOK) and
     (not volHardFilter or volumeOK) and
     (not slopeDecelHardFilter or slopeDecelOK_forStretchUp)

stretchSignal = stretchUpFinal or stretchDownFinal

// >>> ADDED: #1 first-occurrence-only logic — only flag the first bar of a stretch event
stretchSignalFirst = stretchSignal and not (stretchUpFinal[1] or stretchDownFinal[1])
stretchSignalToPlot = dotsFirstOccurrenceOnly ? stretchSignalFirst : stretchSignal

// ── ShowMe dots on the PRICE chart (forced overlay) ─────
plotshape(showDots and buySignal  ? low  : na, title = "Buy Dot",  style = shape.circle, location = location.belowbar, color = color.new(color.lime, 0),  size = size.tiny, force_overlay = true)
plotshape(showDots and sellSignal ? high : na, title = "Sell Dot", style = shape.circle, location = location.abovebar, color = color.new(color.red, 0),   size = size.tiny, force_overlay = true)

// confirmed stretch dot (passed all active filters) — bright yellow
plotshape(showDots and stretchSignalToPlot and not buySignal and not sellSignal ? (stretchUp ? high : low) : na,
     title = "Stretch Dot (Confirmed)", style = shape.circle,
     location = location.absolute, color = color.new(color.yellow, 0), size = size.tiny, force_overlay = true)

// >>> ADDED: raw-but-unconfirmed stretch dot, dimmer, so you can visually compare
// how much the new filters are trimming vs. the original always-on stretch dot
stretchRawOnlyUp   = stretchUpRaw   and not stretchUpFinal
stretchRawOnlyDown = stretchDownRaw and not stretchDownFinal
plotshape(showDots and (stretchRawOnlyUp or stretchRawOnlyDown) and not buySignal and not sellSignal ? (stretchUp ? high : low) : na,
     title = "Stretch Dot (Unconfirmed)", style = shape.circle,
     location = location.absolute, color = color.new(color.yellow, 70), size = size.tiny, force_overlay = true)

// ── Slope histogram in THIS script's own separate pane ──
barColor = confirmedUp ? color.new(color.lime, 0) : confirmedDown ? color.new(color.red, 0) : color.new(color.gray, 40)
plot(slope, "Slope", style = plot.style_columns, color = barColor)
hline(upThresh, "Upper Threshold", color = color.new(color.lime, 0), linestyle = hline.style_dashed)
hline(dnThresh, "Lower Threshold", color = color.new(color.red, 0), linestyle = hline.style_dashed)
hline(0, "Zero", color = color.new(color.gray, 70))
bgcolor(noTradeZone ? color.new(color.gray, 88) : na, title = "No-Trade Zone")

// >>> ADDED: gray tint in the slope pane when the regime filter is actively suppressing
// stretch signals — quick visual read on whether you're in a low-vol chop stretch
bgcolor(useRegimeFilter and not regimeOK ? color.new(color.orange, 90) : na, title = "Low-Vol Regime Suppression")

// ── Alerts ───────────────────────────────────────────────
alertcondition(buySignal,     "MT Buy Signal",        "MovTrend: pullback BUY signal")
alertcondition(sellSignal,    "MT Sell Signal",       "MovTrend: pullback SELL signal")
alertcondition(stretchSignalToPlot, "MT Stretch Warning",   "MovTrend: price stretched beyond ATR band")
alertcondition(confirmedUp,   "Slope: Confirmed Up",  "MovTrend slope confirmed uptrend")
alertcondition(confirmedDown, "Slope: Confirmed Down","MovTrend slope confirmed downtrend")
````
