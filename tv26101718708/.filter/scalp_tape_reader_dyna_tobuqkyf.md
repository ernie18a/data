# Scalp Tape Reader [DYNA]

- url: https://www.tradingview.com/script/TobUQkYF-Scalp-Tape-Reader-DYNA/
- type: indicator
- pine_id: PUB;f3b7b4ea735f4f508464aea36dc5b472
- version: 1.0

## Description

Scalp Tape Reader gives you an instant visual read on who is in control -- buyers or sellers -- by analyzing volume-weighted price action across a micro window. Instead of guessing from candlestick patterns or lagging oscillators, you see aggression directly on the chart through colored bars that tell you when one side is dominating the tape.

Most volume indicators sit in a separate pane and require interpretation. Scalp Tape Reader removes that friction. It weighs each bar's volume by its body-to-wick ratio -- giving more significance to decisive, full-bodied candles and filtering out indecisive wicks and dojis -- then checks whether buying or selling pressure exceeds your chosen dominance threshold. The result is clean, color-coded bars that let you act without thinking.


[b]Key Features[/b]

[list]
[*] [b]Volume-Weighted Pressure Detection[/b] -- Combines volume with candle conviction (body-to-wick ratio) to separate real aggression from noise
[*] [b]Instant Bar Coloring[/b] -- Teal for buy pressure, red for sell pressure, gray for neutral. No separate pane, no mental math
[*] [b]Background Pressure Zones[/b] -- Subtle teal or red background shading during dominant pressure periods, making streaks visible even when zoomed out
[*] [b]Dominance Flip Markers (debounced)[/b] -- Triangle labels mark the exact bar where pressure shifts, with a 50% midline-cross debounce that suppresses repeat flips when dominance oscillates around the threshold
[*] [b]Extreme Pressure Dots (entry-only)[/b] -- Circle markers fire on the first bar that crosses into extreme dominance (default 80%+), so each dot is an independent event rather than one per bar in a streak
[*] [b]Adjustable Sensitivity[/b] -- Tune the lookback window, dominance threshold, and smoothing to match your trading style and timeframe
[*] [b]Built-In Alerts[/b] -- Get notified the moment buying or selling pressure crosses your threshold, even away from the screen
[/list]


[b]How It Works[/b]

As each bar forms, Scalp Tape Reader calculates how much of the bar's range is body versus wick. Bars where price moved decisively (large body, small wicks) receive a high conviction weight, while indecisive bars (dojis, long wicks) receive a low weight. This conviction weight is then multiplied by the bar's volume to produce a weighted volume reading for each side -- buying if the bar closed above its open, selling if it closed below.

These weighted volumes are accumulated over the lookback window (default 5 bars) and compared. When buying pressure accounts for more than 70% of the total weighted volume, bars turn teal. When selling pressure exceeds 70%, bars turn red. Everything in between stays gray, telling you the market lacks a clear aggressor.

An EMA smoothing layer (default 3) prevents the reading from flickering between states on borderline bars, giving you a steadier signal without adding significant lag. Flip markers are further debounced by requiring dominance to cross back through the 50% midline before a new same-direction flip can fire, so you only see triangles on genuine regime changes. Extreme dots fire only on the first bar that crosses into the extreme zone, keeping the chart uncluttered during sustained pressure streaks.

[image]https://www.tradingview.com/x/zEr3jEED/[/image]
[i]Bars colored by volume-weighted pressure: teal clusters show aggressive buying, red clusters show aggressive selling, gray bars indicate balanced flow.[/i]

Beyond bar coloring, the chart background shades teal or red during dominant pressure zones, so you can spot buying and selling streaks at a glance -- even when zoomed out. When pressure flips from one side to the other, a triangle marker appears with a "BUY" or "SELL" label, pinpointing the exact transition bar. On the strongest bars -- where one side holds more than 80% of weighted volume -- small circle dots appear below (for extreme buying) or above (for extreme selling), highlighting the moments of peak conviction.


[b]Settings[/b]

The default configuration works well for 1-5 minute scalping on crypto and equities. The Lookback Period (default 5) controls how many bars are used to accumulate pressure -- lower values react faster, higher values smooth out noise. The Dominance Threshold (default 70%) sets how much weighted volume one side must hold to be flagged as dominant. Drop it to 60-65% on thinner or more volatile instruments; raise it to 75-80% if you only want the strongest signals.

Smoothing Period (default 3) applies an EMA to the dominance reading before thresholding. Set it to 1 for raw, unsmoothed readings. The "Color Bars by Pressure" toggle lets you disable bar coloring if you only want alerts. Note that TradingView allows only one barcolor indicator per chart -- if bars are not coloring, check for conflicts with other indicators.

The Visual group also includes toggles for background pressure zones, dominance flip markers, and extreme pressure dots. The Extreme Pressure Threshold (default 80%) controls how strong the dominance must be to trigger the dot markers. All visual elements can be toggled independently so you can customize exactly what appears on your chart.


[b]Alerts[/b]

[list]
[*] [b]Buy Pressure Dominant[/b] -- Fires when buying-side weighted volume exceeds the dominance threshold on a confirmed bar. [i]"Scalp Tape Reader [DYNA]: Aggressive buying pressure detected."[/i]
[*] [b]Sell Pressure Dominant[/b] -- Fires when selling-side weighted volume exceeds the dominance threshold on a confirmed bar. [i]"Scalp Tape Reader [DYNA]: Aggressive selling pressure detected."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Scalp Tape Reader [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Use on low timeframes (1m to 5m) where volume-driven pressure shifts are most visible. Higher timeframes dilute the signal.
[*] Look for clusters of colored bars rather than single-bar flashes. A streak of teal bars is a stronger signal than one isolated teal bar.
[*] Combine with support/resistance levels or your existing entry strategy. Use the tape reading as a confirmation filter, not a standalone signal.
[*] Volume quality matters -- prefer instruments and brokers that provide real volume data. Tick volume works but real volume is better.
[*] If signals feel too noisy, raise the threshold to 75% or increase the lookback. If they feel too slow, drop the lookback to 3 and set smoothing to 1. The defaults (70%, smoothing 3) are tuned for balanced signal density on liquid instruments such as indices and major pairs.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Scalp Tape Reader is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Scalp Tape Reader [DYNA]
// Detects aggressive buying/selling pressure using volume-weighted price action.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Scalp Tape Reader [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500)

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
int   i_lookback   = input.int(5, "Lookback Period", minval = 2, maxval = 20, group = "Core Settings", tooltip = "Number of bars used to accumulate volume-weighted pressure. Lower values react faster; higher values smooth out noise.")
float i_threshold  = input.float(70.0, "Dominance Threshold (%)", minval = 51.0, maxval = 90.0, step = 1.0, group = "Core Settings", tooltip = "Percentage of weighted volume that one side must hold to be considered dominant. 70% filters most noise on intraday indices; drop to 60-65% for high-volatility crypto or single-name equities.")
int   i_smoothing  = input.int(3, "Smoothing Period", minval = 1, maxval = 10, group = "Core Settings", tooltip = "EMA smoothing applied to the dominance percentage before thresholding. 1 = no smoothing; 3 is a good default for intraday noise reduction.")

// --- Visual ---
bool  i_showBarColor  = input.bool(true, "Color Bars by Pressure", group = "Visual", tooltip = "Colors chart bars based on which side dominates. Note: only one barcolor indicator can be active on a chart at a time.")
bool  i_showBgZones   = input.bool(true, "Background Pressure Zones", group = "Visual", tooltip = "Highlights the background when buy or sell pressure is dominant, making pressure streaks easy to spot at a glance.")
bool  i_showFlipLabel = input.bool(true, "Show Dominance Flip Markers", group = "Visual", tooltip = "Places a small triangle when pressure flips from buy-dominant to sell-dominant or vice versa.")
bool  i_showExtreme   = input.bool(true, "Show Extreme Pressure Dots", group = "Visual", tooltip = "Marks bars where pressure is extreme (above the extreme threshold).")
float i_extremePct    = input.float(80.0, "Extreme Pressure Threshold (%)", minval = 65.0, maxval = 95.0, step = 1.0, group = "Visual", tooltip = "Percentage above which pressure is considered extreme. Shown as dots above/below bars.")

// --- Alerts ---
bool i_alertBuy  = input.bool(true, "Alert: Buy Pressure Dominant", group = "Alerts")
bool i_alertSell = input.bool(true, "Alert: Sell Pressure Dominant", group = "Alerts")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Body-to-Wick Ratio ---
// Measures how much of the bar's range is body vs wicks (0 to 1).
// Bars with large bodies relative to their wicks carry more conviction.
float barRange     = math.max(high - low, syminfo.mintick)
float bodySize     = math.abs(close - open)
float bodyWickRatio = bodySize / barRange

// --- Weighted Up/Down Volume ---
// Up bar (close > open): volume is weighted as buying pressure.
// Down bar (close < open): volume is weighted as selling pressure.
// Doji (close == open): treated as neutral (zero weight on both sides).
float upVol   = close > open ? volume * bodyWickRatio : 0.0
float downVol = close < open ? volume * bodyWickRatio : 0.0

// --- Accumulate Over Lookback ---
float totalUp   = math.sum(upVol, i_lookback)
float totalDown = math.sum(downVol, i_lookback)
float totalVol  = math.max(totalUp + totalDown, 1.0)

// --- Dominance Percentage ---
// buyPct ranges from 0 to 1. Values above threshold = buy dominant.
// Values below (1 - threshold) = sell dominant.
float buyPctRaw = totalUp / totalVol
float buyPct    = i_smoothing > 1 ? ta.ema(buyPctRaw, i_smoothing) : buyPctRaw

// --- Threshold Levels ---
float upperThresh = i_threshold / 100.0
float lowerThresh = (100.0 - i_threshold) / 100.0

// --- Dominance States ---
bool isBuyDominant  = buyPct > upperThresh
bool isSellDominant = buyPct < lowerThresh

// --- Extreme Pressure Detection ---
// Extreme state persists while pct stays above/below threshold. Entry signals
// fire only on the first bar of an extreme streak, so dots mark independent
// events rather than flooding the chart while pressure stays pinned.
float extremeUpper       = i_extremePct / 100.0
float extremeLower       = (100.0 - i_extremePct) / 100.0
bool  isBuyExtreme       = buyPct > extremeUpper
bool  isSellExtreme      = buyPct < extremeLower
bool  buyExtremeEntry    = isBuyExtreme  and not isBuyExtreme[1]
bool  sellExtremeEntry   = isSellExtreme and not isSellExtreme[1]

// --- Dominance Flip Detection (with midline-cross debounce) ---
// A raw flip fires whenever the dominant state flips. The debounce requires
// buyPct to have crossed back through the 50% midline before a same-direction
// flip can fire again — this suppresses rapid re-entries when pct oscillates
// just around the threshold without a real regime change.
bool prevBuyDom    = isBuyDominant[1]
bool prevSellDom   = isSellDominant[1]
bool flipToBuyRaw  = isBuyDominant  and not prevBuyDom
bool flipToSellRaw = isSellDominant and not prevSellDom

var bool canFlipBuy  = true
var bool canFlipSell = true
if buyPct <= 0.5
    canFlipBuy := true
if buyPct >= 0.5
    canFlipSell := true

bool flipToBuy  = flipToBuyRaw  and canFlipBuy
bool flipToSell = flipToSellRaw and canFlipSell
if flipToBuy
    canFlipBuy := false
if flipToSell
    canFlipSell := false

// --- Confirmed-Bar Detection (for alerts) ---
bool buyDominantConfirmed  = isBuyDominant[1] and i_alertBuy
bool sellDominantConfirmed = isSellDominant[1] and i_alertSell

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Bar Coloring ---
color barCol = isBuyDominant ? BULL_COLOR : isSellDominant ? BEAR_COLOR : NEUTRAL_COLOR
barcolor(i_showBarColor ? barCol : na, title = "Pressure Bar Color")

// --- Background Pressure Zones ---
color bgCol = isBuyDominant ? color.new(BULL_COLOR, 88) : isSellDominant ? color.new(BEAR_COLOR, 88) : na
bgcolor(i_showBgZones ? bgCol : na, title = "Pressure Zone Background")

// --- Dominance Flip Markers ---
plotshape(i_showFlipLabel and flipToBuy, title = "Flip to Buy", style = shape.triangleup, location = location.belowbar, color = BULL_COLOR, size = size.tiny, text = "BUY", textcolor = BULL_COLOR)
plotshape(i_showFlipLabel and flipToSell, title = "Flip to Sell", style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.tiny, text = "SELL", textcolor = BEAR_COLOR)

// --- Extreme Pressure Dots (fire on entry only) ---
plotshape(i_showExtreme and buyExtremeEntry, title = "Extreme Buy Pressure", style = shape.circle, location = location.belowbar, color = color.new(BULL_COLOR, 20), size = size.tiny)
plotshape(i_showExtreme and sellExtremeEntry, title = "Extreme Sell Pressure", style = shape.circle, location = location.abovebar, color = color.new(BEAR_COLOR, 20), size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(buyDominantConfirmed, "Buy Pressure Dominant", "Scalp Tape Reader [DYNA]: Aggressive buying pressure detected. Buy-side volume dominance exceeded threshold.")
alertcondition(sellDominantConfirmed, "Sell Pressure Dominant", "Scalp Tape Reader [DYNA]: Aggressive selling pressure detected. Sell-side volume dominance exceeded threshold.")
````
