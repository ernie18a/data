# Range Box Scalper [DYNA]

- url: https://www.tradingview.com/script/S45u0VmZ-Range-Box-Scalper-DYNA/
- type: indicator
- pine_id: PUB;719792d978914169bd466ae16f428aa5
- version: 1.0

## Description

Range Box Scalper detects when price compresses into a tight consolidation zone and visually draws a box around it in real time. When price breaks out of the box with above-average volume, the indicator marks the exact breakout bar with a directional arrow, so you can act on the expansion move without second-guessing the setup.

Most traders know that consolidation leads to expansion, but spotting the range in real time and confirming the breakout with volume is tedious manual work. Range Box Scalper automates the entire process: it watches for price to stay within an ATR-defined corridor for a minimum number of bars, draws the consolidation zone as a visible box on the chart, and then waits for a decisive close outside the box backed by strong volume before signaling the breakout.


[b]Key Features[/b]

[list]
[*] [b]Automatic Range Detection[/b] -- Identifies consolidation zones based on ATR-calibrated price width and minimum bar count. No manual drawing required.
[*] [b]Live Box Drawing[/b] -- Shaded boxes appear and extend in real time as price continues to range, giving you a clear visual boundary to watch.
[*] [b]Volume-Confirmed Breakouts[/b] -- Breakout arrows only appear when volume exceeds a configurable multiple of the 20-bar average, filtering out weak, low-conviction exits.
[*] [b]Breakout Strength Filter[/b] -- Requires the breakout candle to close a minimum distance (ATR-based) beyond the range boundary, eliminating marginal breakouts.
[*] [b]Built-in Trend Filter[/b] -- Optional EMA-based trend filter ensures breakouts only fire in the direction of the prevailing trend, so you can focus on with-trend setups.
[*] [b]Directional Breakout Arrows[/b] -- Green upward triangles for bullish breakouts, red downward triangles for bearish breakouts, placed right at the breakout bar.
[*] [b]No Repainting[/b] -- All signals use confirmed-bar logic. Once a box or arrow appears, it stays.
[/list]


[b]How It Works[/b]

As price action unfolds, Range Box Scalper continuously monitors whether recent bars are staying within a narrow corridor. The corridor width is derived from ATR, so it automatically adapts to the volatility of whatever instrument you are trading. When price stays inside this corridor for your configured minimum number of bars, a shaded gray box appears on the chart marking the consolidation zone. You will also see a small orange diamond labeled "Range" on the bar where the consolidation is first confirmed.

The box continues to extend to the right as long as price remains inside the boundaries. The moment price closes decisively outside the box and the breakout bar carries above-average volume, the indicator marks the breakout with a colored arrow: a green triangle below the bar for a bullish breakout, or a red triangle above the bar for a bearish breakout. The box border also changes color to match the breakout direction, giving you a quick historical reference for which zones broke which way.

If price drifts out of the range on weak volume, no breakout signal fires. The indicator simply resets and begins looking for the next consolidation. This volume filter is what separates genuine expansion moves from false exits that quickly reverse.

[image]https://www.tradingview.com/x/VZR8LBZh/[/image]
[i]A consolidation box forming over several bars, followed by a bullish breakout arrow when price closes above the range with strong volume.[/i]


[b]Settings[/b]

The core settings control how the indicator defines a consolidation zone. [b]Min Range Bars[/b] (default: 6) sets how long price must stay compressed before a box is drawn -- lower values on fast timeframes, higher values on daily charts. [b]ATR Multiplier[/b] (default: 1.5) controls the maximum allowed range width relative to ATR; lower values mean tighter, more compressed boxes, while higher values detect more consolidation zones. [b]Volume Confirmation[/b] (default: 1.2x) sets the volume threshold for breakout signals; increase this if you want only the strongest breakouts.

[b]Min Breakout Strength[/b] (default: 0.1x ATR) requires the breakout candle to close at least this distance beyond the range boundary, filtering out marginal breakouts that barely clear the box edge. The [b]Trend Filter[/b] (default: off, EMA 50) optionally restricts breakouts to the trend direction -- bullish breakouts only fire above the EMA, bearish breakouts only below. Enable this if you want to filter counter-trend setups.

Visual toggles let you show or hide the consolidation boxes and breakout arrows independently. Each alert type can also be toggled on or off.


[b]Alerts[/b]

[list]
[*] [b]Consolidation Forming[/b] -- Fires when price has ranged for the minimum number of bars and a new consolidation zone is confirmed. [i]"Range Box Scalper: Consolidation zone detected. Price is ranging in a tight range."[/i]
[*] [b]Breakout Up[/b] -- Fires when price closes above the consolidation box with volume confirmation. [i]"Range Box Scalper: Bullish breakout from consolidation zone with volume confirmation."[/i]
[*] [b]Breakout Down[/b] -- Fires when price closes below the consolidation box with volume confirmation. [i]"Range Box Scalper: Bearish breakout from consolidation zone with volume confirmation."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Range Box Scalper [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] On lower timeframes (1m-5m), reduce Min Range Bars to 5-6 to catch shorter consolidation periods that match the faster price action.
[*] On higher timeframes (4H and above), increase Min Range Bars to 12-15 so only significant consolidation zones are flagged.
[*] Increase the Volume Confirmation multiplier or Min Breakout Strength if you are getting too many signals -- this ensures only the strongest breakouts are marked.
[*] The built-in trend filter (EMA 50) ensures breakouts align with the prevailing trend. Disable it if you want to trade counter-trend setups.
[*] After a breakout, the box boundaries (top and bottom) often act as support or resistance on a retest.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Range Box Scalper is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Range Box Scalper [DYNA]
// Draws real-time consolidation boxes and marks breakout direction.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Range Box Scalper [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
int   i_minRangeBars    = input.int(6, "Min Range Bars", minval = 3, maxval = 50, group = "Core Settings", tooltip = "Minimum number of bars price must stay in range to form a consolidation box.")
float i_atrMultiplier   = input.float(1.5, "ATR Multiplier (Range Width)", minval = 0.1, maxval = 5.0, step = 0.1, group = "Core Settings", tooltip = "Maximum allowed range width as a multiple of ATR. Higher = more boxes detected. Lower = tighter consolidations only.")
float i_volMultiplier   = input.float(1.2, "Volume Confirmation (x avg)", minval = 0.5, maxval = 5.0, step = 0.1, group = "Core Settings", tooltip = "Breakout must have volume this many times above the 20-bar average to confirm.")
int   i_atrLength       = input.int(14, "ATR Length", minval = 5, maxval = 50, group = "Core Settings", tooltip = "Lookback period for ATR calculation.")
float i_minBreakoutATR  = input.float(0.1, "Min Breakout Strength (x ATR)", minval = 0.0, maxval = 2.0, step = 0.1, group = "Core Settings", tooltip = "Breakout candle must close at least this fraction of ATR beyond the range boundary. Filters out weak/marginal breakouts.")

// --- Trend Filter ---
bool  i_useTrendFilter  = input.bool(false, "Use Trend Filter", group = "Trend Filter", tooltip = "Only allow breakouts in the direction of the trend (price vs EMA). Disable to allow all breakouts.")
int   i_trendEmaLength  = input.int(50, "Trend EMA Length", minval = 10, maxval = 200, group = "Trend Filter", tooltip = "EMA length used for trend direction filter.")

// --- Visual ---
bool i_showBoxes        = input.bool(true, "Show Consolidation Boxes", group = "Visual")
bool i_showArrows       = input.bool(true, "Show Breakout Arrows", group = "Visual")

// --- Alerts ---
bool i_alertConsolidation = input.bool(true, "Alert: Consolidation Forming", group = "Alerts")
bool i_alertBreakoutUp    = input.bool(true, "Alert: Breakout Up", group = "Alerts")
bool i_alertBreakoutDown  = input.bool(true, "Alert: Breakout Down", group = "Alerts")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- ATR, Volume & Trend ---
float atrVal     = ta.atr(i_atrLength)
float rangeWidth = i_atrMultiplier * nz(atrVal, 0)
float volAvg     = ta.sma(volume, 20)
float trendEma   = ta.ema(close, i_trendEmaLength)

// --- Persistent State ---
var float rangeHigh     = na
var float rangeLow      = na
var int   rangeStartBar = na
var int   rangeBars     = 0
var bool  inRange       = false
var box   activeBox     = na
var bool  boxConfirmed  = false   // tracks whether the box has been drawn

// --- Signals (reset each bar) ---
bool consolidationFormed = false
bool breakoutUp          = false
bool breakoutDown        = false

// --- Confirmed-bar logic: use previous bar's close for signals ---
// All state transitions happen on confirmed bars (current bar's data is confirmed
// at bar close in real-time; on historical bars every bar is confirmed).

// Check if adding this bar keeps total range within allowed width
float potentialHigh  = inRange and not na(rangeHigh) ? math.max(rangeHigh, high) : high
float potentialLow   = inRange and not na(rangeLow)  ? math.min(rangeLow, low)   : low
float potentialRange = potentialHigh - potentialLow
bool  barFitsRange   = inRange and not na(rangeHigh) and not na(rangeLow) and potentialRange <= rangeWidth

// Check for breakout conditions (only if we have a confirmed range)
bool volConfirmed   = nz(volAvg, 0) > 0 ? volume > i_volMultiplier * volAvg : true
bool trendBullish   = not i_useTrendFilter or close > trendEma
bool trendBearish   = not i_useTrendFilter or close < trendEma
float minBoDistance  = i_minBreakoutATR * nz(atrVal, syminfo.mintick)
bool isBreakoutUp   = inRange and boxConfirmed and rangeBars >= i_minRangeBars and close > rangeHigh and (close - rangeHigh) >= minBoDistance and volConfirmed and trendBullish
bool isBreakoutDown = inRange and boxConfirmed and rangeBars >= i_minRangeBars and close < rangeLow  and (rangeLow - close) >= minBoDistance and volConfirmed and trendBearish

// Check if price leaves range without volume confirmation
bool rangeBreakNoVol = inRange and not barFitsRange and not isBreakoutUp and not isBreakoutDown

if barstate.isconfirmed
    if not inRange
        // Start tracking a new potential range
        rangeHigh     := high
        rangeLow      := low
        rangeStartBar := bar_index
        rangeBars     := 1
        inRange       := true
        boxConfirmed  := false
    else
        if isBreakoutUp
            // --- Breakout UP ---
            breakoutUp := true
            if not na(activeBox) and i_showBoxes
                box.set_right(activeBox, bar_index)
                box.set_border_color(activeBox, BULL_COLOR)
            // Reset state
            inRange      := false
            rangeBars    := 0
            boxConfirmed := false
            activeBox    := na

        else if isBreakoutDown
            // --- Breakout DOWN ---
            breakoutDown := true
            if not na(activeBox) and i_showBoxes
                box.set_right(activeBox, bar_index)
                box.set_border_color(activeBox, BEAR_COLOR)
            // Reset state
            inRange      := false
            rangeBars    := 0
            boxConfirmed := false
            activeBox    := na

        else if barFitsRange
            // --- Bar fits in range, extend it ---
            rangeBars := rangeBars + 1
            rangeHigh := math.max(rangeHigh, high)
            rangeLow  := math.min(rangeLow, low)

            // First time reaching minimum bars: confirm and draw box
            if rangeBars == i_minRangeBars and not boxConfirmed
                consolidationFormed := true
                boxConfirmed        := true
                if i_showBoxes
                    activeBox := box.new(rangeStartBar, rangeHigh, bar_index, rangeLow, border_color = NEUTRAL_COLOR, border_width = 1, bgcolor = color.new(NEUTRAL_COLOR, 85))

            // Extend existing box
            if boxConfirmed and not na(activeBox) and i_showBoxes
                box.set_right(activeBox, bar_index)
                box.set_top(activeBox, rangeHigh)
                box.set_bottom(activeBox, rangeLow)

        else
            // --- Bar doesn't fit and no valid breakout: reset ---
            inRange      := false
            rangeBars    := 0
            boxConfirmed := false
            activeBox    := na

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// Breakout arrows
plotshape(i_showArrows and breakoutUp   ? true : false, title = "Breakout Up",   style = shape.triangleup,   location = location.belowbar, color = BULL_COLOR, size = size.small, text = "BO", textcolor = BULL_COLOR)
plotshape(i_showArrows and breakoutDown ? true : false, title = "Breakout Down", style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.small, text = "BO", textcolor = BEAR_COLOR)

// Consolidation forming marker (small diamond on the bar that confirms the range)
plotshape(i_showArrows and consolidationFormed ? true : false, title = "Consolidation Formed", style = shape.diamond, location = location.abovebar, color = WARNING_COLOR, size = size.tiny, text = "Range", textcolor = WARNING_COLOR)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(consolidationFormed and i_alertConsolidation, title = "Consolidation Forming", message = "Range Box Scalper [DYNA]: Consolidation zone detected. Price is ranging in a tight range.")
alertcondition(breakoutUp and i_alertBreakoutUp,             title = "Breakout Up",           message = "Range Box Scalper [DYNA]: Bullish breakout from consolidation zone with volume confirmation.")
alertcondition(breakoutDown and i_alertBreakoutDown,         title = "Breakout Down",         message = "Range Box Scalper [DYNA]: Bearish breakout from consolidation zone with volume confirmation.")
````
