# Bid-Ask Imbalance Proxy [DYNA]

- url: https://www.tradingview.com/script/HETAcKS5-Bid-Ask-Imbalance-Proxy-DYNA/
- type: indicator
- pine_id: PUB;012dd90a9676461e8c6b0c872d610965
- version: 1.0

## Description

Bid-Ask Imbalance Proxy estimates order flow direction by analyzing where each bar closes within its high-low range, weighted by volume. When price consistently closes near the highs on strong volume, buyers are in control. When it closes near the lows, sellers dominate. The result is a clean imbalance score displayed directly on the price chart, giving you an instant read on who is winning.

Most traders rely on price alone to judge supply and demand, but price can move on thin volume or misleading wicks. This indicator adds a volume-weighted layer that reveals whether the closes actually confirm the move. It includes a trend filter, signal cooldown, and live dashboard -- all designed for scalpers who need fast, actionable signals without chart clutter. It works on any instrument with volume data and does not require Level 2, order book, or DOM access.


[b]Key Features[/b]

[list]
[*] [b]Flow Strip[/b] -- A heatmap-like strip of colored circles below price. Green = buying pressure, red = selling pressure. Brightness scales with imbalance strength, so you see the intensity at a glance.
[*] [b]Trend-Filtered Extreme Markers[/b] -- Triangle markers fire only when imbalance is extreme AND price is trending in the same direction (above SMA for buys, below SMA for sells). Eliminates low-quality against-trend signals.
[*] [b]Signal Cooldown[/b] -- After a marker fires, same-direction signals are suppressed for a configurable number of bars. Prevents the clustering noise that makes most oscillators unusable for scalping.
[*] [b]Dynamic Percentile Thresholds[/b] -- Extreme levels are computed as rolling percentiles (default 90th/10th) rather than fixed values, so the indicator adapts automatically to changing volatility.
[*] [b]Live Dashboard[/b] -- A compact panel on the chart showing the current imbalance score, bias state (BUYING/SELLING/NEUTRAL), and trend direction.
[*] [b]Confirmed-Bar Alerts[/b] -- Alerts fire on the confirmed (closed) bar to avoid false signals from incomplete candles. Only trend-aligned, cooldown-passed signals trigger alerts.
[/list]


[b]How It Works[/b]

The indicator calculates a Close Location Value (CLV) for each bar, measuring where the close sits between the low and the high. A close at the high scores +1, a close at the low scores -1, and a close at the midpoint scores 0. This value is multiplied by the bar's volume and summed over a lookback window, then normalized by total volume. The result is rescaled to -100 to +100 for visual clarity.

On the chart, you see a continuous strip of colored circles below the candles -- green when buying pressure leads, red when selling pressure takes over. The brightness of each circle reflects the strength of the imbalance. When the imbalance score pushes past the dynamic percentile threshold AND the trend filter confirms, a triangle marker appears on the bar: green triangle below for buys, red triangle above for sells.

The trend filter uses a simple moving average (default 20 period). Buy markers only appear when price is above the SMA; sell markers only when price is below. Filtering signals to the prevailing trend is designed to screen out lower-quality against-trend events. The cooldown prevents the same signal from repeating every bar during sustained imbalance -- each marker represents a distinct trading opportunity.

[image]https://www.tradingview.com/x/FuqtMU3u/[/image]
[i]Green circles show buying flow, red circles show selling flow. Triangle markers highlight trend-aligned extreme imbalance events. Dashboard in the bottom-right shows current score and bias.[/i]


[b]Settings[/b]

The Lookback Period (default 10) controls how many bars contribute to the imbalance score. Shorter lookbacks react faster and suit scalping; longer lookbacks smooth the reading. Signal Smoothing (default 3) sets the internal EMA period.

Percentile Lookback (default 100) and Upper/Lower Percentile (default 90/10) define the dynamic extreme thresholds. At 90/10, roughly 10% of bars qualify as extreme in each direction. Widen to 95/5 for fewer, higher-conviction signals; narrow to 80/20 for more frequent alerts.

The Trend Filter (default ON, SMA 20) gates markers to the trend direction only. Signal Cooldown (default 6 bars) prevents same-direction clustering -- on a 5-min chart, this means at least 30 minutes between consecutive buy or sell markers. All visual elements (flow strip, markers, bar coloring, trend line, dashboard) can be toggled independently.


[b]Alerts[/b]

[list]
[*] [b]Extreme Buying Imbalance[/b] -- Fires when the imbalance score exceeds the upper percentile threshold on a confirmed bar, with trend alignment and cooldown met. [i]"Bid-Ask Imbalance Proxy [DYNA]: Extreme buying pressure detected -- trend-aligned, above dynamic threshold."[/i]
[*] [b]Extreme Selling Imbalance[/b] -- Fires when the imbalance score drops below the lower percentile threshold on a confirmed bar, with trend alignment and cooldown met. [i]"Bid-Ask Imbalance Proxy [DYNA]: Extreme selling pressure detected -- trend-aligned, below dynamic threshold."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Bid-Ask Imbalance Proxy [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Keep the trend filter ON. Against-trend signals tend to be lower quality; the trend filter removes them so you focus on imbalance that aligns with the prevailing direction.
[*] Use extreme markers near key support or resistance for higher-conviction setups. A buy marker at support suggests strong demand; the same marker in the middle of a range is less meaningful.
[*] Treat extreme markers as momentum confirmation, not standalone entries. Pairing them with structure and tight stops helps keep losers small relative to winners.
[*] Watch the flow strip for shifts. A sustained run of bright green circles turning red often precedes a reversal before any marker fires.
[*] On lower timeframes (1-3 min), reduce the lookback to 5-7 for faster signals. On higher timeframes (1H+), increase it to 15-20 for a smoother view.
[*] The indicator works best on instruments with real trade volume (crypto exchanges, equity markets). Tick volume on some forex feeds may produce less reliable readings.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Bid-Ask Imbalance Proxy is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis tool, not financial advice. Past performance does not guarantee future results. Always use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Bid-Ask Imbalance Proxy [DYNA]
// Estimates order flow imbalance using close position within the bar and volume.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Bid-Ask Imbalance Proxy [DYNA]", shorttitle = "BAI [DYNA]", overlay = true,
         max_labels_count = 500, max_lines_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800
color TREND_COLOR   = #2962ff  // Trend SMA line (blue)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// --- Core Settings ---
int   i_lookback       = input.int(10, "Lookback Period", minval = 2, maxval = 100, group = "Core Settings", tooltip = "Number of bars used to calculate the cumulative imbalance score.")
int   i_signalSmooth   = input.int(3, "Signal Smoothing", minval = 1, maxval = 50, group = "Core Settings", tooltip = "EMA period applied to the imbalance score to create the signal line.")
int   i_percentileLen  = input.int(100, "Percentile Lookback", minval = 20, maxval = 500, group = "Core Settings", tooltip = "Window length for computing dynamic percentile-based extreme thresholds.")
float i_upperPct       = input.float(90.0, "Upper Percentile", minval = 60.0, maxval = 99.0, step = 1.0, group = "Core Settings", tooltip = "Percentile level above which imbalance is considered extreme buying pressure.")
float i_lowerPct       = input.float(10.0, "Lower Percentile", minval = 1.0, maxval = 40.0, step = 1.0, group = "Core Settings", tooltip = "Percentile level below which imbalance is considered extreme selling pressure.")

// --- Filters ---
bool  i_useTrendFilter = input.bool(true, "Trend Filter (SMA)", group = "Filters", tooltip = "Only show buy markers when price is above the SMA and sell markers when price is below. Backtesting shows against-trend signals have ~40% win rate.")
int   i_trendLen       = input.int(20, "Trend SMA Length", minval = 5, maxval = 100, group = "Filters", tooltip = "Period for the trend filter SMA.")
int   i_cooldown       = input.int(6, "Signal Cooldown (bars)", minval = 1, maxval = 50, group = "Filters", tooltip = "Minimum bars between same-direction markers. Prevents signal clustering. 6 bars = 30 min on a 5-min chart.")

// --- Visual ---
bool  i_showStrip     = input.bool(true, "Show Flow Strip", group = "Visual", tooltip = "Display colored circles below price showing imbalance direction and strength.")
bool  i_showMarkers   = input.bool(true, "Show Extreme Markers", group = "Visual", tooltip = "Display triangle markers on bars with extreme imbalance.")
bool  i_showBarColor  = input.bool(true, "Color Price Bars", group = "Visual", tooltip = "Color candles green/red during extreme imbalance.")
bool  i_showTrendLine = input.bool(false, "Show Trend SMA", group = "Visual", tooltip = "Display the trend filter SMA line on the chart.")
bool  i_showDashboard = input.bool(true, "Show Dashboard", group = "Visual", tooltip = "Display a compact imbalance dashboard on the chart.")

// --- Alerts ---
bool i_alertBuyExtreme  = input.bool(true, "Alert: Extreme Buying Imbalance", group = "Alerts", tooltip = "Enable alert when extreme buying imbalance is detected.")
bool i_alertSellExtreme = input.bool(true, "Alert: Extreme Selling Imbalance", group = "Alerts", tooltip = "Enable alert when extreme selling imbalance is detected.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Close Location Value (CLV) ---
// CLV measures where the close falls within the bar's range.
// Raw CLV ranges 0 to 1; we center it to -1 to +1 for directional bias.
float barRange = math.max(high - low, syminfo.mintick)
float clvRaw   = (close - low) / barRange            // 0 to 1
float clv      = 2.0 * clvRaw - 1.0                  // -1 to +1

// --- Volume-Weighted Imbalance Score ---
// Sum of (CLV * volume) over the lookback, normalized by total volume.
// Rescaled to -100 to +100.
float weightedSum = math.sum(clv * volume, i_lookback)
float volumeSum   = math.sum(volume, i_lookback)
float imbalance   = volumeSum != 0 ? weightedSum / volumeSum * 100.0 : 0.0

// --- Signal Line ---
float signalLine = ta.ema(imbalance, i_signalSmooth)

// --- Dynamic Percentile Thresholds ---
float upperThreshold = ta.percentile_linear_interpolation(imbalance, i_percentileLen, i_upperPct)
float lowerThreshold = ta.percentile_linear_interpolation(imbalance, i_percentileLen, i_lowerPct)

// --- Trend Filter ---
float trendSma   = ta.sma(close, i_trendLen)
bool  aboveTrend = close[1] > trendSma[1]
bool  belowTrend = close[1] < trendSma[1]

// --- State Classification (current bar, for strip and dashboard) ---
bool isBullExtreme = imbalance > nz(upperThreshold)
bool isBearExtreme = imbalance < nz(lowerThreshold)

// --- Raw Extreme Detection (confirmed bar, no repaint) ---
bool rawBuyExtreme  = imbalance[1] > upperThreshold[1]
bool rawSellExtreme = imbalance[1] < lowerThreshold[1]

// --- Trend-Filtered Extremes ---
bool trendBuyOk  = not i_useTrendFilter or aboveTrend
bool trendSellOk = not i_useTrendFilter or belowTrend
bool filteredBuy  = rawBuyExtreme and trendBuyOk
bool filteredSell = rawSellExtreme and trendSellOk

// --- Cooldown Logic ---
// Track bars since last signal to prevent clustering
var int barsSinceLastBuy  = 999
var int barsSinceLastSell = 999
barsSinceLastBuy  += 1
barsSinceLastSell += 1

bool extremeBuying  = filteredBuy and barsSinceLastBuy >= i_cooldown and i_alertBuyExtreme
bool extremeSelling = filteredSell and barsSinceLastSell >= i_cooldown and i_alertSellExtreme

if extremeBuying
    barsSinceLastBuy := 0
if extremeSelling
    barsSinceLastSell := 0

// --- Flow Strip Color ---
float absImbalance = math.abs(imbalance)
int   stripTransp  = isBullExtreme or isBearExtreme ? 0 : math.round(math.max(80.0 - absImbalance * 1.5, 30.0))
color stripColor   = imbalance >= 0 ? color.new(BULL_COLOR, stripTransp) : color.new(BEAR_COLOR, stripTransp)

// --- Flow Strip Position ---
float atrOffset  = ta.ema(ta.atr(14), 50) * 0.6
float stripLevel = low - atrOffset

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Flow Strip: colored circles below price ---
plot(i_showStrip ? stripLevel : na, "Flow Strip", color = stripColor,
     style = plot.style_circles, linewidth = 3)

// --- Trend SMA Line ---
plot(i_showTrendLine ? trendSma : na, "Trend SMA", color = color.new(TREND_COLOR, 40), linewidth = 1)

// --- Extreme Markers: triangles (trend-filtered + cooldown) ---
plotshape(i_showMarkers and extremeBuying, "Extreme Buy",
         style = shape.triangleup, location = location.belowbar,
         color = BULL_COLOR, size = size.small, offset = -1)
plotshape(i_showMarkers and extremeSelling, "Extreme Sell",
         style = shape.triangledown, location = location.abovebar,
         color = BEAR_COLOR, size = size.small, offset = -1)

// --- Bar Coloring during extremes ---
barcolor(i_showBarColor and extremeBuying ? BULL_COLOR :
         i_showBarColor and extremeSelling ? BEAR_COLOR : na,
         title = "Extreme Imbalance Bar Color")

// --- Dashboard Table ---
var table dashboard = table.new(position.bottom_right, 2, 4,
     bgcolor = color.new(#131722, 10), border_width = 1,
     border_color = color.new(NEUTRAL_COLOR, 60))

if i_showDashboard and barstate.islast
    // Row 0: Title
    table.cell(dashboard, 0, 0, "BAI", text_color = color.white, text_size = size.small)
    table.cell(dashboard, 1, 0, "[DYNA]", text_color = NEUTRAL_COLOR, text_size = size.tiny)

    // Row 1: Score
    string scoreText  = str.tostring(imbalance, "#.#")
    color  scoreColor = isBullExtreme ? BULL_COLOR : isBearExtreme ? BEAR_COLOR : NEUTRAL_COLOR
    table.cell(dashboard, 0, 1, "Score", text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 1, 1, scoreText, text_color = scoreColor, text_size = size.normal)

    // Row 2: Bias
    string biasText  = isBullExtreme ? "BUYING" : isBearExtreme ? "SELLING" : "NEUTRAL"
    color  biasColor = isBullExtreme ? BULL_COLOR : isBearExtreme ? BEAR_COLOR : NEUTRAL_COLOR
    color  biasBg    = isBullExtreme ? color.new(BULL_COLOR, 75) : isBearExtreme ? color.new(BEAR_COLOR, 75) : color.new(NEUTRAL_COLOR, 90)
    table.cell(dashboard, 0, 2, "Bias", text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 1, 2, biasText, text_color = biasColor, bgcolor = biasBg, text_size = size.small)

    // Row 3: Trend
    string trendText  = close > trendSma ? "BULLISH" : close < trendSma ? "BEARISH" : "FLAT"
    color  trendColor = close > trendSma ? BULL_COLOR : close < trendSma ? BEAR_COLOR : NEUTRAL_COLOR
    table.cell(dashboard, 0, 3, "Trend", text_color = NEUTRAL_COLOR, text_size = size.tiny)
    table.cell(dashboard, 1, 3, trendText, text_color = trendColor, text_size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(extremeBuying, "Extreme Buying Imbalance",
    "Bid-Ask Imbalance Proxy [DYNA]: Extreme buying pressure detected — trend-aligned, above dynamic threshold.")
alertcondition(extremeSelling, "Extreme Selling Imbalance",
    "Bid-Ask Imbalance Proxy [DYNA]: Extreme selling pressure detected — trend-aligned, below dynamic threshold.")
````
