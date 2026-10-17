# Volatility Prism [JOAT]

- url: https://www.tradingview.com/script/7xp4xp9j-Volatility-Prism-JOAT/
- type: indicator
- pine_id: PUB;486991ea2acd4eeaafad5f4ad4101d61
- version: 1.0

## Description

[b]Volatility Prism [JOAT][/b]

[b]Introduction[/b]

Volatility Prism is an open-source dual Bollinger Band envelope system with percentile-based bandwidth squeeze detection and Stochastic RSI confirmation. It renders two independent envelopes — an inner band at a configurable standard deviation multiplier and an outer band at a wider multiplier — with gradient fills that color dynamically based on whether price is in a bullish or bearish position relative to the moving average basis. When the bandwidth compresses to a historically low percentile, a squeeze state is declared. When the squeeze releases, an expansion signal fires.

The problem Volatility Prism solves is that volatility states are cyclical: periods of compression (squeeze) reliably precede periods of expansion (breakout), and the direction of the breakout is where the opportunity lies. By combining a statistically-based squeeze detector — which uses percentile thresholds rather than fixed bandwidth levels — with Stochastic RSI extreme confirmation, Volatility Prism identifies both the compression state and the likely directional bias of the coming expansion simultaneously.

[image]https://www.tradingview.com/x/7HpjYV6K/[/image]

[b]Core Concepts[/b]

[b]1. Dual Bollinger Band Structure[/b]

Two separate Bollinger Band pairs share the same basis (SMA of the source) but use different standard deviation multipliers. The inner band (default 2.0x) is the primary envelope. The outer band (default 3.0x) defines the extreme extension zone. Price trading beyond the inner band but inside the outer band is in the elevated zone. Price trading beyond the outer band is in a statistical extreme:

[pine]
basis  = ta.sma(src, bbLen)
dev    = ta.stdev(src, bbLen)
upper1 = basis + bbMult1 * dev   // Inner upper
lower1 = basis - bbMult1 * dev   // Inner lower
upper2 = basis + bbMult2 * dev   // Outer upper
lower2 = basis - bbMult2 * dev   // Outer lower
[/pine]

The trend bias is determined by whether the close is above or below the basis. When bullish, all envelope lines and fills render in the bullish color. When bearish, they render in the bearish color. This makes the trend state immediately visible from the envelope color alone.

[b]2. Gradient Envelope Fills[/b]

Four gradient fills create the visual envelope structure. The inner fills gradient from a near-opaque shade at the band edge to a nearly transparent shade at the basis, creating a density effect that visually represents how far price is from the center. The outer fills extend this gradient into the extreme zone at reduced opacity, cleanly separating the normal, elevated, and extreme price zones:

[pine]
fill(basisPlot, upper1Plot, upper1, basis, color.new(envCol, 85), color.new(envCol, 98), "Upper Inner Fill")
fill(upper1Plot, upper2Plot, upper2, upper1, color.new(envCol, 75), color.new(envCol, 88), "Upper Outer Fill")
[/pine]

[b]3. Percentile-Based Bandwidth Squeeze Detection[/b]

The bandwidth (the width of the inner band as a percentage of the basis) is computed on each bar and added to a rolling history array of configurable length. The current bandwidth is compared to the percentile threshold of that history — if the current bandwidth is below the configured percentile (default 15th percentile), the squeeze state is active:

[pine]
bandwidth = basis > 0 ? (upper1 - lower1) / basis * 100 : 0.0

// Sort history and find threshold at configured percentile
threshIdx    = int(array.size(sorted) * sqzPctile / 100) - 1
sqzThreshold = array.get(sorted, threshIdx)
isSqueezing  = bandwidth <= sqzThreshold
[/pine]

This approach adapts to the instrument and timeframe automatically — a 15th percentile squeeze on a low-volatility bond future and on a high-volatility crypto asset will both correctly identify when that specific instrument is in an unusually compressed state relative to its own history.

[b]4. Stochastic RSI Extreme Confirmation[/b]

The Stochastic RSI (an oscillator that applies Stochastic logic to RSI values) provides momentum extreme confirmation. Overbought and oversold readings from the K and D lines confirm when band extremes coincide with momentum extremes, strengthening band rejection signals:

[pine]
rsiVal   = ta.rsi(src, rsiLen)
stochVal = ta.stoch(rsiVal, rsiVal, rsiVal, stochLen)
kLine    = ta.sma(stochVal, smoothK)
dLine    = ta.sma(kLine, smoothD)

stochOB = kLine > upperLim and dLine > upperLim  // Overbought
stochOS = kLine < lowerLim and dLine < lowerLim  // Oversold
[/pine]

[b]5. Band Rejection Signals and Squeeze Breakout[/b]

Three signal types are generated. Bullish band rejection fires when price was below the inner lower band on the previous bar and closes back above it, with Stochastic RSI confirming oversold — a failed breakdown with momentum confirmation. Bearish band rejection fires on the symmetric condition above the inner upper band. Squeeze Breakout fires on the first bar that transitions from squeeze to non-squeeze state — the moment the bandwidth begins expanding:

[pine]
bearRejection = close[1] > upper1[1] and close <= upper1 and stochOB[1]
bullRejection = close[1] < lower1[1] and close >= lower1 and stochOS[1]
sqzBreakout   = isSqueezing[1] and not isSqueezing
[/pine]

[b]6. Band Price Labels at the Right Edge[/b]

All five band lines (U2, U1, MA, L1, L2) receive price labels at the right edge of the chart. These labels update every bar to show the current price of each level, eliminating the need to hover over lines or read the y-axis to determine band values:

[pine]
if barstate.islast and showBandLbls
    lblU2 := label.new(bar_index + 2, upper2,
         "U2   " + str.tostring(upper2, format.mintick),
         style=label.style_label_right, ...)
[/pine]

[image]https://www.tradingview.com/x/poHVIJ5K/[/image]

[b]Features[/b]

[list]
[*][b]Dual Bollinger Band envelopes:[/b] Inner and outer bands with independently configurable multipliers
[*][b]Adaptive gradient fills:[/b] Four gradient fills (inner upper, inner lower, outer upper, outer lower) color dynamically with trend bias
[*][b]Dynamic trend coloring:[/b] All envelope elements switch between bullish and bearish colors based on close vs. basis
[*][b]Percentile-based squeeze detection:[/b] Bandwidth compared to a configurable percentile of its rolling history — adapts to any instrument's volatility profile
[*][b]Configurable squeeze lookback:[/b] Rolling bandwidth history window from 20 to 500 bars
[*][b]Squeeze background shading:[/b] Optional chart background shading during active squeeze state
[*][b]Stochastic RSI confirmation:[/b] K and D line extreme zones confirm band rejection signal quality
[*][b]Three signal types:[/b] Bull Rejection, Bear Rejection, and Squeeze Breakout markers with distinct shapes
[*][b]Band price labels at right edge:[/b] Live price labels for all five band levels (U2, U1, MA, L1, L2) at bar_index + 2
[*][b]Institutional dashboard (top right):[/b] 11-row table with Volatility state (SQUEEZE/EXPANDING), Bandwidth %, Trend, StochRSI state, K and D values, Basis price, and Envelope range
[*][b]Fully configurable inputs:[/b] BB length, both multipliers, squeeze lookback and percentile, Stochastic RSI parameters, and all colors independently adjustable
[*][b]Alerts:[/b] Bull Rejection, Bear Rejection, Squeeze Breakout, and Squeeze Entry alertconditions
[/list]

[b]Input Parameters[/b]

[b]Bollinger Bands:[/b]
[list]
[*]Source: Price source (default: close)
[*]BB Length: MA and standard deviation period (default: 20)
[*]Inner Mult: Standard deviation multiplier for inner bands (default: 2.0)
[*]Outer Mult: Standard deviation multiplier for outer bands (default: 3.0)
[/list]

[b]Squeeze Detection:[/b]
[list]
[*]Bandwidth Lookback: Rolling history window for percentile calculation (default: 120 bars)
[*]Squeeze Percentile: Bandwidth percentile below which squeeze is active (default: 15th)
[/list]

[b]Stochastic RSI:[/b]
[list]
[*]K Smoothing (default: 3), D Smoothing (default: 3)
[*]RSI Length (default: 14), Stochastic Length (default: 14)
[*]Overbought level (default: 80), Oversold level (default: 20)
[/list]

[b]Display:[/b]
[list]
[*]Show Dashboard toggle
[*]Squeeze Background toggle
[*]Band Price Labels toggle
[*]Bullish Envelope color, Bearish Envelope color, Basis Line color, Squeeze Background color
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Volatility State[/b]
The dashboard's Volatility row shows SQUEEZE (yellow) or EXPANDING (gray). When SQUEEZE is active, the chart background shades yellow. A squeeze state means bandwidth has compressed to a historically low percentile — the market is loading energy for a directional move.

[b]Step 2: Watch for Squeeze Breakout Signals[/b]
The cross (x) marker appears at the first bar that exits a squeeze. This is the moment bandwidth begins expanding. The direction of the breakout bar (bullish or bearish candle) combined with the trend color of the envelope provides the directional lean for the expansion phase.

[b]Step 3: Interpret Envelope Color for Trend Bias[/b]
When all envelope elements are teal, price is above the basis — bullish bias. When all elements are orange, price is below the basis — bearish bias. Use the envelope color as a continuous trend indicator overlaid directly on the price.

[b]Step 4: React to Band Rejection Diamonds[/b]
Diamond markers at the band edge indicate price failed to sustain a move beyond the inner band and recovered inside, with Stochastic RSI confirming the extreme. These are mean-reversion entry signals — price rejected the statistical extreme with momentum confirmation.

[b]Step 5: Reference Band Price Labels[/b]
The right-edge labels show the current price of each band level. Use these when planning take-profit targets (opposite band) or stop-loss placement (outer band beyond entry) without needing to manually read prices from band lines.

[b]Indicator Limitations[/b]

[list]
[*]The squeeze detector requires a minimum of sqzLen bars of bandwidth history to activate. On short charts or immediately after the indicator is applied, the squeeze state will not register until enough history is accumulated
[*]The percentile-based squeeze threshold adapts to the lookback window. A longer lookback produces a more stable threshold; a shorter lookback adapts faster but may produce more frequent squeeze entries and exits
[*]Band rejection signals require the close to recover inside the band on the bar immediately following the outside close. Multi-bar breakouts that recover more slowly are not detected as rejections
[*]Squeeze Breakout markers fire on the first bar exiting a squeeze regardless of candle size or direction. They do not independently confirm the breakout direction — the envelope trend color and Stochastic RSI must be used to assess directional bias
[*]Stochastic RSI is a double-transformed oscillator (RSI → Stochastic). It can reach and hold extreme levels for extended periods in strong trends, producing frequent overbought or oversold readings that reduce the specificity of band rejection confirmation
[/list]

[b]Originality Statement[/b]

Volatility Prism is original in its adaptive, percentile-based squeeze detection combined with a dual-envelope gradient structure and Stochastic RSI extreme confirmation with right-edge band price labels. This indicator is published because:

[list]
[*]Using the rolling percentile of bandwidth history — rather than fixed bandwidth values or the classic Keltner Channel comparison method — for squeeze detection provides an instrument-adaptive and timeframe-adaptive threshold that requires no manual calibration
[*]The dual-envelope structure (inner and outer bands) with four independent gradient fills that change color based on real-time trend bias creates a visually rich, information-dense chart overlay without adding separate indicator panes
[*]The right-edge band price labels for all five band levels eliminate a common usability friction point in Bollinger Band analysis, where traders must hover over lines or estimate prices from the y-axis scale
[*]The three-signal system (Bull Rejection, Bear Rejection, Squeeze Breakout) operating from two independent mechanisms (band geometry + Stochastic RSI for rejections, bandwidth percentile for breakout) provides distinct signal categories suited to different trading styles
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Bollinger Bands and Stochastic RSI readings are historical statistical tools. Squeeze states can persist for extended periods without producing a breakout, and breakouts can occur in either direction. Band rejection signals do not guarantee price will reverse from the band. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volatility Prism [JOAT]", shorttitle="Vol Prism [JOAT]", overlay=true,
     max_boxes_count=100, max_lines_count=100, max_labels_count=200)
// ─── INPUTS ────────────────────────────────────────────────────────────────────
grpBB = "Bollinger Bands"
bbSrc   = input.source(close, "Source",            group=grpBB)
bbLen   = input.int(20,       "BB Length", minval=1, group=grpBB)
bbMult1 = input.float(2.0,    "Inner Mult",minval=0.1, maxval=10, step=0.1, group=grpBB)
bbMult2 = input.float(3.0,    "Outer Mult",minval=0.1, maxval=10, step=0.1, group=grpBB)

grpSqueeze = "Squeeze Detection"
sqzLen    = input.int(120,  "Bandwidth Lookback", minval=20, maxval=500, group=grpSqueeze,
     tooltip="Period to evaluate whether current bandwidth is at historical lows.")
sqzPctile = input.float(15, "Squeeze Percentile", minval=1,  maxval=50, step=1,  group=grpSqueeze,
     tooltip="Bandwidth below this percentile of recent history triggers squeeze state.")

grpStoch = "Stochastic RSI"
smoothK  = input.int(3,    "K Smoothing",      minval=1, group=grpStoch)
smoothD  = input.int(3,    "D Smoothing",      minval=1, group=grpStoch)
rsiLen   = input.int(14,   "RSI Length",       minval=1, group=grpStoch)
stochLen = input.int(14,   "Stochastic Length",minval=1, group=grpStoch)
upperLim = input.float(80, "Overbought",       minval=50, maxval=99, group=grpStoch)
lowerLim = input.float(20, "Oversold",         minval=1,  maxval=50, group=grpStoch)

grpDisplay = "Display"
showDash      = input.bool(true, "Show Dashboard",       group=grpDisplay)
showSqueezeBg = input.bool(true, "Squeeze Background",   group=grpDisplay)
showBandLbls  = input.bool(true, "Band Price Labels",    group=grpDisplay,
     tooltip="Shows current price of each band line at the right edge of the chart.")

grpColors = "Colors"
bullEnvCol = input.color(color.new(#0097A7, 0), "Bullish Envelope",   group=grpColors)
bearEnvCol = input.color(color.new(#E65100, 0), "Bearish Envelope",   group=grpColors)
basisCol   = input.color(color.new(#546E7A, 0), "Basis Line",         group=grpColors)
sqzBgCol   = input.color(color.new(#FFB300, 95),"Squeeze Background", group=grpColors)

// ─── BOLLINGER BANDS ───────────────────────────────────────────────────────────
basis  = ta.sma(bbSrc, bbLen)
dev    = ta.stdev(bbSrc, bbLen)
upper1 = basis + bbMult1 * dev
lower1 = basis - bbMult1 * dev
upper2 = basis + bbMult2 * dev
lower2 = basis - bbMult2 * dev

// Trend bias: price above basis = bull, below = bear
trendBull = close > basis
envCol    = trendBull ? bullEnvCol : bearEnvCol

// ─── BANDWIDTH & SQUEEZE ───────────────────────────────────────────────────────
bandwidth = basis > 0 ? (upper1 - lower1) / basis * 100 : 0.0

var float[] bwHistory = array.new_float(0)
if not na(bandwidth)
    array.push(bwHistory, bandwidth)
    if array.size(bwHistory) > sqzLen
        array.shift(bwHistory)

isSqueezing = false
if array.size(bwHistory) >= sqzLen
    sortedBW   = array.copy(bwHistory)
    array.sort(sortedBW, order.ascending)
    threshIdx    = math.max(0, int(array.size(sortedBW) * sqzPctile / 100) - 1)
    sqzThreshold = array.get(sortedBW, threshIdx)
    isSqueezing := bandwidth <= sqzThreshold

bgcolor(showSqueezeBg and isSqueezing ? sqzBgCol : na, title="Squeeze Shading")

// ─── STOCHASTIC RSI ────────────────────────────────────────────────────────────
rsiVal   = ta.rsi(bbSrc, rsiLen)
stochVal = ta.stoch(rsiVal, rsiVal, rsiVal, stochLen)
kLine    = ta.sma(stochVal, smoothK)
dLine    = ta.sma(kLine, smoothD)

stochOB = kLine > upperLim and dLine > upperLim
stochOS = kLine < lowerLim and dLine < lowerLim

// ─── SIGNALS ───────────────────────────────────────────────────────────────────
// Band rejection: price was outside inner band, crossed back, StochRSI extreme confirms
bearRejection = close[1] > upper1[1] and close <= upper1 and stochOB[1] and barstate.isconfirmed
bullRejection = close[1] < lower1[1] and close >= lower1 and stochOS[1] and barstate.isconfirmed

// Squeeze breakout: squeeze released, bandwidth now expanding
sqzBreakout = isSqueezing[1] and not isSqueezing and barstate.isconfirmed

// ─── PLOTS ─────────────────────────────────────────────────────────────────────
basisPlot  = plot(basis,  "Basis",   color=basisCol,              linewidth=1)
upper1Plot = plot(upper1, "Upper 1", color=color.new(envCol, 30), linewidth=1)
lower1Plot = plot(lower1, "Lower 1", color=color.new(envCol, 30), linewidth=1)
upper2Plot = plot(upper2, "Upper 2", color=color.new(envCol, 60), linewidth=1, style=plot.style_linebr)
lower2Plot = plot(lower2, "Lower 2", color=color.new(envCol, 60), linewidth=1, style=plot.style_linebr)

// Gradient fills — inner envelope
fill(basisPlot, upper1Plot, upper1, basis, color.new(envCol, 85), color.new(envCol, 98), "Upper Inner Fill")
fill(basisPlot, lower1Plot, basis, lower1, color.new(envCol, 98), color.new(envCol, 85), "Lower Inner Fill")

// Gradient fills — outer envelope
fill(upper1Plot, upper2Plot, upper2, upper1, color.new(envCol, 75), color.new(envCol, 88), "Upper Outer Fill")
fill(lower1Plot, lower2Plot, lower1, lower2, color.new(envCol, 88), color.new(envCol, 75), "Lower Outer Fill")

// Signal markers
plotshape(bearRejection, "Bear Rejection",  shape.diamond, location.abovebar, color=color.new(bearEnvCol, 20), size=size.small)
plotshape(bullRejection, "Bull Rejection",  shape.diamond, location.belowbar, color=color.new(bullEnvCol, 20), size=size.small)
plotshape(sqzBreakout,   "Squeeze Breakout", shape.cross, location.abovebar, color=color.new(#FFB300, 0), size=size.small)

// ─── BAND PRICE LABELS AT CURRENT BAR ─────────────────────────────────────────
// Each band gets a labeled price tag at the right edge of the chart.
var label lblU2    = na
var label lblU1    = na
var label lblBasis = na
var label lblL1    = na
var label lblL2    = na

if barstate.islast and showBandLbls
    label.delete(lblU2)
    label.delete(lblU1)
    label.delete(lblBasis)
    label.delete(lblL1)
    label.delete(lblL2)

    envC = trendBull ? bullEnvCol : bearEnvCol

    lblU2    := label.new(bar_index + 2, upper2,
         "U2   " + str.tostring(upper2, format.mintick),
         style=label.style_label_right, color=color.new(#0D1117, 20),
         textcolor=color.new(envC, 20), size=size.tiny)
    lblU1    := label.new(bar_index + 2, upper1,
         "U1   " + str.tostring(upper1, format.mintick),
         style=label.style_label_right, color=color.new(#0D1117, 20),
         textcolor=envC, size=size.tiny)
    lblBasis := label.new(bar_index + 2, basis,
         "MA   " + str.tostring(basis, format.mintick),
         style=label.style_label_right, color=color.new(#0D1117, 20),
         textcolor=basisCol, size=size.tiny)
    lblL1    := label.new(bar_index + 2, lower1,
         "L1   " + str.tostring(lower1, format.mintick),
         style=label.style_label_right, color=color.new(#0D1117, 20),
         textcolor=envC, size=size.tiny)
    lblL2    := label.new(bar_index + 2, lower2,
         "L2   " + str.tostring(lower2, format.mintick),
         style=label.style_label_right, color=color.new(#0D1117, 20),
         textcolor=color.new(envC, 20), size=size.tiny)

// ─── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 11,
     bgcolor=color.new(#0D1117, 5),
     border_color=color.new(#1A2332, 0),
     border_width=1,
     frame_color=color.new(#0097A7, 45),
     frame_width=1)

if barstate.islast and showDash
    color DARK_BG = color.new(#0D1117, 0)
    color SEP_BG  = color.new(#080D13, 0)
    color LBL_C   = color.new(#546E7A, 0)

    string volState = isSqueezing ? "SQUEEZE" : "EXPANDING"
    color  volCol   = isSqueezing ? color.new(#FFB300, 0) : color.new(#78909C, 0)

    string trendStr = trendBull ? "ABOVE BASIS" : "BELOW BASIS"
    color  trendCol = trendBull ? color.new(#0097A7, 0) : color.new(#E65100, 0)

    string stochStr = stochOB ? "OVERBOUGHT" : stochOS ? "OVERSOLD" : "NEUTRAL"
    color  stochCol = stochOB ? color.new(#E65100, 0) : stochOS ? color.new(#00897B, 0) : color.new(#546E7A, 0)

    // Row 0: Header
    table.cell(dash, 0, 0, "VOLATILITY PRISM", text_color=color.new(#ECEFF1, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[JOAT]",           text_color=color.new(#0097A7, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 1: Separator
    table.cell(dash, 0, 1, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 1, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 2: Volatility state (prominent)
    table.cell(dash, 0, 2, "Volatility",  text_color=LBL_C,  text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 2, volState,      text_color=volCol, text_size=size.normal,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 3: Bandwidth
    table.cell(dash, 0, 3, "Bandwidth",   text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(bandwidth, "#.##") + "%",
         text_color=color.new(#78909C, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 4: Separator
    table.cell(dash, 0, 4, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 4, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 5: Trend
    table.cell(dash, 0, 5, "Trend",       text_color=LBL_C,    text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 5, trendStr,      text_color=trendCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 6: StochRSI
    table.cell(dash, 0, 6, "StochRSI",    text_color=LBL_C,    text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 6, stochStr,      text_color=stochCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 7: K / D values
    table.cell(dash, 0, 7, "K / D",       text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 7,
         str.tostring(kLine, "#.#") + " / " + str.tostring(dLine, "#.#"),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 8: Separator
    table.cell(dash, 0, 8, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 8, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 9: Basis price
    table.cell(dash, 0, 9, "Basis (" + str.tostring(bbLen) + ")",
         text_color=LBL_C, text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(basis, format.mintick),
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 10: Envelope range
    table.cell(dash, 0, 10, "Envelope",   text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 10,
         str.tostring(upper1, format.mintick) + " / " + str.tostring(lower1, format.mintick),
         text_color=color.new(#546E7A, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(bullRejection, "Bullish Band Rejection", "Volatility Prism: Bullish rejection from lower band")
alertcondition(bearRejection, "Bearish Band Rejection", "Volatility Prism: Bearish rejection from upper band")
alertcondition(sqzBreakout,   "Squeeze Breakout",       "Volatility Prism: Squeeze released — volatility expanding")
alertcondition(isSqueezing and not isSqueezing[1], "Squeeze Entry", "Volatility Prism: Entered squeeze state")
````
