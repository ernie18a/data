# Candle Signal Monitor

- url: https://www.tradingview.com/script/iqunShCp-Candle-Signal-Monitor/
- type: indicator
- pine_id: PUB;ff200d02601f424986b7b3ba21026f01
- version: 1.0

## Description

Candle Signal Monitor is a pattern-based alert indicator designed for traders who wait for specific candle confirmations before entering a setup.

Instead of watching every bar manually, the script continuously monitors the chart and alerts you when a qualifying candle pattern appears. It is intended to be used after identifying a key market area such as support/resistance, breakout zones, or retests.

The indicator detects four short-term candle formations:

• Pin Bars
• Engulfing candles
• Floating Engulfing candles
• Tweezers

[b]Features[/b]

• Detects bullish and bearish signals
• Alerts trigger on confirmed bars only
• Individual pattern selection (enable/disable)
• Displays only the highest-ranked signal per candle
• Optional lookback filter to show markers only on the last N candles

[b]Alerts[/b]

ANY LONG / ANY SHORT
Triggers on any detected bullish or bearish pattern.

SELECTED LONG / SELECTED SHORT
Triggers only for enabled pattern types.

[b]Details[/b]

[i]Pin Bar[/i]

Rejection candle with a small body and a dominant wick.
• Bullish: long lower wick, body near high, lower low vs previous candle
• Bearish: long upper wick, body near low, higher high vs previous candle

[i]Engulfing[/i]

Requires a close beyond the full range of the previous candle.
• Bullish: bullish candle after bearish, closes above previous high
• Bearish: bearish candle after bullish, closes below previous low

[i]Floating Engulfing[/i]

Continuation-style breakout pattern.
• Bullish: bullish after bullish, closes above previous high
• Bearish: bearish after bearish, closes below previous low

[i]Tweezers[/i]

Two-candle rejection pattern with similar highs/lows and meaningful wicks.
Dojis are excluded.

## Source Code

````pine
//@version=6
indicator("Candle Signal Monitor", overlay=true, max_labels_count=500)

// ──────────────────────────────────────
// INPUTS
// ──────────────────────────────────────
showPinBar    = input.bool(true,  title="Show Pin Bars", display = display.none)
showEngulfing = input.bool(true,  title="Show Normal Engulfers", display = display.none)
showFloating  = input.bool(true,  title="Show Floating Engulfers", display = display.none)
showTweezers  = input.bool(true,  title="Show Tweezers", display = display.none)

// NEW: Only show markers on the last N candles
lookbackBars  = input.int(10, "Show markers only for last N candles", minval=0, display = display.none)

// ──────────────────────────────────────
// CONSTANTS
// ──────────────────────────────────────
TWZ_WICK_SIMILARITY_RATIO       = 0.8
TWZ_MIN_WICK_VS_BARSIZE_RATIO   = 0.3

// ──────────────────────────────────────
// DETECTION FUNCTIONS
// ──────────────────────────────────────
detectBullPin() =>
    range_    = high - low
    bodyTop   = math.max(open, close)
    bodyBot   = math.min(open, close)
    lowerWick = bodyBot - low
    isPivot   = low < low[1]
    range_ > 0 and lowerWick > 0.5 * range_ and bodyTop >= high - 0.25 * range_ and isPivot

detectBearPin() =>
    range_     = high - low
    bodyTop    = math.max(open, close)
    bodyBot    = math.min(open, close)
    upperWick  = high - bodyTop
    isPivot    = high > high[1]
    range_ > 0 and upperWick > 0.5 * range_ and bodyBot <= low + 0.25 * range_ and isPivot

detectBullEng() =>
    currBull = close > open
    prevBear = close[1] <= open[1]
    engulfs  = close > high[1]
    range_   = high - low
    closeInUpper25 = close >= high - range_ * 0.25
    prevBear and currBull and engulfs and closeInUpper25

detectBearEng() =>
    currBear = close < open
    prevBull = close[1] >= open[1]
    engulfs  = close < low[1]
    range_   = high - low
    closeInLower25 = close <= low + range_ * 0.25
    prevBull and currBear and engulfs and closeInLower25

detectFloatBullEng() =>
    currBull = close > open
    prevBull = close[1] >= open[1]
    engulfs  = close > high[1]
    range_   = high - low
    closeInUpper25 = close >= high - range_ * 0.25
    currBull and prevBull and engulfs and closeInUpper25

detectFloatBearEng() =>
    currBear = close < open
    prevBear = close[1] <= open[1]
    engulfs  = close < low[1]
    range_   = high - low
    closeInLower25 = close <= low + range_ * 0.25
    currBear and prevBear and engulfs and closeInLower25

detectBullTweezer() =>
    body0 = math.abs(close - open)
    body1 = math.abs(close[1] - open[1])

    dojiExcluded = body0 > 0 and body1 > 0
    if not dojiExcluded
        false
    else
        bodyBot0 = math.min(open, close)
        bodyBot1 = math.min(open[1], close[1])
        range0   = high - low
        range1   = high[1] - low[1]

        lw0 = math.max(bodyBot0 - low, 0.0)
        lw1 = math.max(bodyBot1 - low[1], 0.0)

        longerLW  = math.max(lw0, lw1)

        cond1 = longerLW > 0 and (math.abs(low - low[1]) / longerLW) <= (1 - TWZ_WICK_SIMILARITY_RATIO)

        // 2) each candle: lower wick relative to its body (>=)
        cond2 = range0 > 0 and lw0 >= TWZ_MIN_WICK_VS_BARSIZE_RATIO * range0 and range1 > 0 and lw1 >= TWZ_MIN_WICK_VS_BARSIZE_RATIO * range1

        isPivot   = low[1] < low[2]

        cond1 and cond2 and isPivot

detectBearTweezer() =>
    body0 = math.abs(close - open)
    body1 = math.abs(close[1] - open[1])

    dojiExcluded = body0 > 0 and body1 > 0
    if not dojiExcluded
        false
    else
        bodyTop0 = math.max(open, close)
        bodyTop1 = math.max(open[1], close[1])
        range0   = high - low
        range1   = high[1] - low[1]

        uw0 = math.max(high - bodyTop0, 0.0)
        uw1 = math.max(high[1] - bodyTop1, 0.0)

        longerUW  = math.max(uw0, uw1)

        cond1 = longerUW > 0 and (math.abs(high - high[1]) / longerUW) <= (1 - TWZ_WICK_SIMILARITY_RATIO)

        // 2) each candle: upper wick relative to its body (>=)
        cond2 = range0 > 0 and uw0 >= TWZ_MIN_WICK_VS_BARSIZE_RATIO * range0 and range1 > 0 and uw1 >= TWZ_MIN_WICK_VS_BARSIZE_RATIO * range1

        isPivot = high[1] > high[2]

        cond1 and cond2 and isPivot

// ──────────────────────────────────────
// RAW DETECTIONS
// ──────────────────────────────────────
bullPin     = detectBullPin()
bearPin     = detectBearPin()
bullEng     = detectBullEng()
bearEng     = detectBearEng()
bullFloat   = detectFloatBullEng()
bearFloat   = detectFloatBearEng()
bullTweezer = detectBullTweezer()
bearTweezer = detectBearTweezer()

// ──────────────────────────────────────
// RANKING, DISPLAY THE HIGHEST RANKED
// ──────────────────────────────────────
bullFloatPlt    = bullFloat and not bullTweezer and not bullPin and not bullEng
bullEngPlt      = bullEng and not bullTweezer and not bullPin
bullPinPlt      = bullPin and not bullTweezer
bullTweezerPlt  = bullTweezer

bearFloatPlt    = bearFloat and not bearTweezer and not bearPin and not bearEng
bearEngPlt      = bearEng and not bearTweezer and not bearPin
bearPinPlt      = bearPin and not bearTweezer
bearTweezerPlt  = bearTweezer

// ──────────────────────────────────────
// LAST-N FILTER (only plot on last N candles)
// ──────────────────────────────────────
inLookback = lookbackBars == 0 or bar_index >= (last_bar_index - (lookbackBars - 1))

// ──────────────────────────────────────
// PLOTSHAPES
// ──────────────────────────────────────
plotshape(inLookback and bullPinPlt and showPinBar, title="Bullish Pin Bar",
     style=shape.triangleup, location=location.belowbar, color=color.lime,
     size=size.tiny, textcolor=color.gray, text="P", display=display.pane)

plotshape(inLookback and bearPinPlt and showPinBar, title="Bearish Pin Bar",
     style=shape.triangledown, location=location.abovebar, color=color.red,
     size=size.tiny, textcolor=color.gray, text="P", display=display.pane)

plotshape(inLookback and bullEngPlt and showEngulfing, title="Bullish Engulfing",
     style=shape.triangleup, location=location.belowbar, color=color.green,
     size=size.tiny, textcolor=color.gray, text="E", display=display.pane)

plotshape(inLookback and bearEngPlt and showEngulfing, title="Bearish Engulfing",
     style=shape.triangledown, location=location.abovebar, color=color.orange,
     size=size.tiny, textcolor=color.gray, text="E", display=display.pane)

plotshape(inLookback and bullFloatPlt and showFloating, title="Bull Floating Engulfing",
     style=shape.triangleup, location=location.belowbar, color=color.olive,
     size=size.tiny, textcolor=color.gray, text="F", display=display.pane)

plotshape(inLookback and bearFloatPlt and showFloating, title="Bear Floating Engulfing",
     style=shape.triangledown, location=location.abovebar, color=color.fuchsia,
     size=size.tiny, textcolor=color.gray, text="F", display=display.pane)

plotshape(inLookback and bullTweezerPlt and showTweezers, title="Bullish Tweezer",
     style=shape.triangleup, location=location.belowbar, color=color.aqua,
     size=size.tiny, textcolor=color.gray, text="T", display=display.pane)

plotshape(inLookback and bearTweezerPlt and showTweezers, title="Bearish Tweezer",
     style=shape.triangledown, location=location.abovebar, color=color.purple,
     size=size.tiny, textcolor=color.gray, text="T", display=display.pane)

// ──────────────────────────────────────
// ALERTS – only on confirmed bars
// ──────────────────────────────────────
anyLongSignal  = bullPin or bullEng or bullFloat or bullTweezer
anyShortSignal = bearPin or bearEng or bearFloat or bearTweezer

alertcondition(anyLongSignal  and barstate.isconfirmed, title="ANY LONG",  message="LONG Entry Signal")
alertcondition(anyShortSignal and barstate.isconfirmed, title="ANY SHORT", message="SHORT Entry Signal")

selLongSignal  = (bullPin and showPinBar) or (bullEng and showEngulfing) or (bullFloat and showFloating) or (bullTweezer and showTweezers)
selShortSignal = (bearPin and showPinBar) or (bearEng and showEngulfing) or (bearFloat and showFloating) or (bearTweezer and showTweezers)

alertcondition(selLongSignal  and barstate.isconfirmed, title="SELECTED LONG",  message="LONG Entry Signal")
alertcondition(selShortSignal and barstate.isconfirmed, title="SELECTED SHORT", message="SHORT Entry Signal")
````
