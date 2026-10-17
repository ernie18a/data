# Intraday Trend Ribbon [DYNA]

- url: https://www.tradingview.com/script/nXeAe9a3-Intraday-Trend-Ribbon-DYNA/
- type: indicator
- pine_id: PUB;7aded8ad676f49a58d910d6109b1a317
- version: 1.0

## Description

Intraday Trend Ribbon plots eight Fibonacci EMAs (8, 13, 21, 34, 55, 89, 144, 233) as a single coloured ribbon stacked on price. When the EMAs are perfectly fanned -- fastest on top -- the ribbon turns green and the chart background lights up bullish. When they are stacked the other way it turns red. Mixed and compressed? The ribbon goes grey and the indicator flags chop. The result is an at-a-glance read on whether the momentum, swing, and trend timeframes agree.

Most ribbon indicators colour every line with a separate state, leaving you to interpret the soup. This one collapses the eight EMAs into three regimes -- fully bullish, fully bearish, chop -- and wraps the chart background in the matching colour, so trend regimes, transitions, and consolidations are obvious without staring at line crossovers.


[b]Key Features[/b]

[list]
[*] [b]Eight Fibonacci EMAs[/b] -- 8, 13, 21, 34, 55, 89, 144, 233 by default; every period is configurable.
[*] [b]Strict Alignment Detection[/b] -- The ribbon registers as bullish or bearish only when all eight EMAs are in strict monotonic order. No half-aligned states, no false trend signals.
[*] [b]Chop Filter[/b] -- A built-in compression detector flags windows where the ribbon collapses into a tight band, using ribbon width / ATR as the yardstick. Tunable via a single threshold input.
[*] [b]Background Regime Highlight[/b] -- Soft green / red when the ribbon is fully aligned, soft amber when chop is active. Toggleable.
[*] [b]Per-Line Transparency Gradient[/b] -- The fastest EMA is opaque; slower EMAs fade gradually so the ribbon reads as a single colour-graded fan rather than eight competing lines.
[*] [b]Three Alerts[/b] -- Bullish flip, bearish flip, chop start. All gated on confirmed bar close, no repainting.
[*] [b]No Repainting[/b] -- Every alert compares the current confirmed bar's state to the previous bar's state. Historical signals never move.
[/list]


[b]How It Works[/b]

The indicator computes eight EMAs of the configured source (default close) at the eight periods. Each bar it checks two conditions:

[i]Fully bullish[/i] = ema8 > ema13 > ema21 > ema34 > ema55 > ema89 > ema144 > ema233
[i]Fully bearish[/i] = the mirror

The ribbon colour is set by which (if any) of these holds. For chop, the ribbon's vertical span (max EMA minus min EMA) is divided by the current ATR; if the result is below the configured ceiling AND the ribbon is mixed (neither bullish nor bearish), the bar is marked as chop. ATR scaling makes the chop threshold work the same way across instruments and timeframes.

Edge events fire only on the first confirmed bar of a new state -- the first bar that becomes fully bullish, the first bar that becomes fully bearish, the first bar that enters chop. Comparing each bar's state to the prior bar's state guarantees no repainting.

[image]https://www.tradingview.com/x/JqJUfXHT/[/image]
[i]The eight-EMA Fibonacci ribbon coloured by alignment state. Green fan = fully bullish, red fan = fully bearish, grey = mixed. Background tints amplify the regime; amber background marks chop windows.[/i]


[b]Settings[/b]

[b]EMA Source[/b] (default: close) sets the price feed for every line. The eight period inputs ([b]EMA 1[/b] through [b]EMA 8[/b], defaults 8 to 233) define the ribbon; replace them with any other set if you prefer non-Fibonacci spacing.

[b]Detect Chop[/b] (default: on) enables the compression detector. [b]Chop ATR Length[/b] (default: 14) sets the ATR period, and [b]Chop Width / ATR Ceiling[/b] (default: 0.5) controls strictness -- raise toward 1.0 for more frequent chop flags, lower toward 0.3 to flag only the tightest compressions.

[b]Show EMA Lines[/b], [b]Shade Between EMAs[/b], and [b]Background When Aligned[/b] are independent visibility toggles. [b]Line Transparency (fastest)[/b] (default: 0) controls the opacity of the fastest line; the slower lines fade gradually from there.

The three alert toggles enable / disable the bullish-flip, bearish-flip, and chop-start alerts independently.


[b]Alerts[/b]

[list]
[*] [b]Ribbon Fully Bullish[/b] -- Fires on the first confirmed bar where the ribbon enters a fully bullish stack. [i]"Intraday Trend Ribbon [DYNA]: Ribbon flipped fully bullish -- all 8 EMAs stacked fast over slow."[/i]
[*] [b]Ribbon Fully Bearish[/b] -- Fires on the first confirmed bar where the ribbon enters a fully bearish stack. [i]"Intraday Trend Ribbon [DYNA]: Ribbon flipped fully bearish -- all 8 EMAs stacked fast under slow."[/i]
[*] [b]Ribbon Tangled (Chop)[/b] -- Fires on the first confirmed bar where the ribbon becomes compressed and unaligned. [i]"Intraday Trend Ribbon [DYNA]: Ribbon entered chop -- EMAs compressed and unaligned."[/i]
[/list]

To set up alerts: open TradingView's Alerts panel, choose "Intraday Trend Ribbon [DYNA]" from the condition dropdown, pick one of the three alert variants, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Trade only with the regime. When the green or red background is active, the ribbon agrees on direction -- this is the highest-edge environment for trend setups. Use counter-trend setups only when there is no background tint.
[*] Treat the slower EMAs (89, 144, 233) as dynamic trailing stops in a clean trend. A close that decisively crosses and stays beyond the 233 EMA usually marks the end of a regime.
[*] Use ribbon-width changes to read momentum. A widening fan = accelerating trend; a contracting fan = trend losing energy.
[*] Skip trades during the amber chop background. The compression flag catches typical midday consolidations and news-pause windows that most trend systems struggle with.
[*] Match the timeframe to your holding period. 1m / 5m flips often, 1h / 4h flips rarely. Pick the one whose flip cadence matches the trades you actually take.
[*] On instruments with very low volatility (post-close FX, holiday sessions), raise the Chop Width / ATR Ceiling so the chop filter does not stay active permanently.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Intraday Trend Ribbon is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Intraday Trend Ribbon [DYNA]
// Eight-EMA Fibonacci ribbon that visualises intraday trend strength: a fully fanned ribbon = strong trend, a tangled ribbon = chop.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Intraday Trend Ribbon [DYNA]", shorttitle = "Ribbon [DYNA]", overlay = true)

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

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
i_source        = input.source(close, "EMA Source", group = GRP_CORE, tooltip = "Price source used for every EMA in the ribbon. Default close keeps the ribbon comparable across instruments.")
int  i_p1       = input.int(8,   "EMA 1 (fastest)", minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Period of the fastest EMA. Defaults follow the Fibonacci sequence.")
int  i_p2       = input.int(13,  "EMA 2",           minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Second EMA period.")
int  i_p3       = input.int(21,  "EMA 3",           minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Third EMA period.")
int  i_p4       = input.int(34,  "EMA 4",           minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Fourth EMA period.")
int  i_p5       = input.int(55,  "EMA 5",           minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Fifth EMA period.")
int  i_p6       = input.int(89,  "EMA 6",           minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Sixth EMA period.")
int  i_p7       = input.int(144, "EMA 7",           minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Seventh EMA period.")
int  i_p8       = input.int(233, "EMA 8 (slowest)", minval = 1, maxval = 500, group = GRP_CORE, tooltip = "Period of the slowest EMA. The default 233 is the eighth Fibonacci number.")
bool i_chopDetect    = input.bool(true, "Detect Chop (compressed ribbon)", group = GRP_CORE, tooltip = "Mark the ribbon as choppy when it is mixed (not aligned) and compressed below a fraction of ATR.")
int  i_atrLen        = input.int(14, "Chop ATR Length", minval = 2, maxval = 100, group = GRP_CORE, tooltip = "ATR period used to scale ribbon width when measuring compression.")
float i_chopThreshold = input.float(0.5, "Chop Width / ATR Ceiling", minval = 0.05, maxval = 5.0, step = 0.05, group = GRP_CORE, tooltip = "Ribbon is treated as choppy when (max EMA − min EMA) / ATR is below this ratio. Lower = stricter chop definition.")

// --- Visual ---
bool i_showEmas        = input.bool(true, "Show EMA Lines",      group = GRP_VIS, tooltip = "Toggle visibility of the eight EMA lines.")
bool i_showFills       = input.bool(true, "Shade Between EMAs",  group = GRP_VIS, tooltip = "Fill each adjacent pair of EMAs with a translucent ribbon band.")
bool i_showBg          = input.bool(true, "Background When Aligned", group = GRP_VIS, tooltip = "Tint the chart background when all EMAs are perfectly stacked bullish or bearish.")
int  i_lineTransparency = input.int(0, "Line Transparency (fastest)", minval = 0, maxval = 80, group = GRP_VIS, tooltip = "Transparency for the fastest EMA line. Slower EMAs fade gradually toward this baseline + a per-line step.")

// --- Alerts ---
bool i_alertBullFlip = input.bool(true, "Alert: Ribbon Fully Bullish", group = GRP_ALERT, tooltip = "Fire when the ribbon transitions into a fully bullish stack (fast > … > slow).")
bool i_alertBearFlip = input.bool(true, "Alert: Ribbon Fully Bearish", group = GRP_ALERT, tooltip = "Fire when the ribbon transitions into a fully bearish stack (fast < … < slow).")
bool i_alertChop     = input.bool(true, "Alert: Ribbon Tangled (Chop)", group = GRP_ALERT, tooltip = "Fire when the ribbon enters a compressed, mixed (chop) state.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Eight EMAs ---
float ema1 = ta.ema(i_source, i_p1)
float ema2 = ta.ema(i_source, i_p2)
float ema3 = ta.ema(i_source, i_p3)
float ema4 = ta.ema(i_source, i_p4)
float ema5 = ta.ema(i_source, i_p5)
float ema6 = ta.ema(i_source, i_p6)
float ema7 = ta.ema(i_source, i_p7)
float ema8 = ta.ema(i_source, i_p8)

// --- Alignment state (strict monotonic stacks) ---
bool bullAligned = ema1 > ema2 and ema2 > ema3 and ema3 > ema4 and ema4 > ema5 and ema5 > ema6 and ema6 > ema7 and ema7 > ema8
bool bearAligned = ema1 < ema2 and ema2 < ema3 and ema3 < ema4 and ema4 < ema5 and ema5 < ema6 and ema6 < ema7 and ema7 < ema8
bool mixed       = not bullAligned and not bearAligned

// --- Ribbon width vs ATR (for chop) ---
float ribbonHigh = math.max(ema1, ema2, ema3, ema4, ema5, ema6, ema7, ema8)
float ribbonLow  = math.min(ema1, ema2, ema3, ema4, ema5, ema6, ema7, ema8)
float ribbonWidth = ribbonHigh - ribbonLow
float atr        = ta.atr(i_atrLen)
float atrSafe    = math.max(nz(atr), syminfo.mintick)
float compRatio  = ribbonWidth / atrSafe

bool chop = i_chopDetect and mixed and compRatio < i_chopThreshold

// --- Edge events on confirmed bars (no repaint) ---
bool confirmed = barstate.isconfirmed
bool bullFlip  = confirmed and bullAligned and not bullAligned[1]
bool bearFlip  = confirmed and bearAligned and not bearAligned[1]
bool chopStart = confirmed and chop        and not chop[1]

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

color stateColor = bullAligned ? BULL_COLOR : bearAligned ? BEAR_COLOR : NEUTRAL_COLOR

// --- Per-line transparency: fastest fully opaque, slowest most faded ---
int baseT = i_lineTransparency
int stepT = 4
color c1 = color.new(stateColor, math.min(baseT + stepT * 0, 95))
color c2 = color.new(stateColor, math.min(baseT + stepT * 1, 95))
color c3 = color.new(stateColor, math.min(baseT + stepT * 2, 95))
color c4 = color.new(stateColor, math.min(baseT + stepT * 3, 95))
color c5 = color.new(stateColor, math.min(baseT + stepT * 4, 95))
color c6 = color.new(stateColor, math.min(baseT + stepT * 5, 95))
color c7 = color.new(stateColor, math.min(baseT + stepT * 6, 95))
color c8 = color.new(stateColor, math.min(baseT + stepT * 7, 95))

float plot1 = i_showEmas ? ema1 : na
float plot2 = i_showEmas ? ema2 : na
float plot3 = i_showEmas ? ema3 : na
float plot4 = i_showEmas ? ema4 : na
float plot5 = i_showEmas ? ema5 : na
float plot6 = i_showEmas ? ema6 : na
float plot7 = i_showEmas ? ema7 : na
float plot8 = i_showEmas ? ema8 : na

p1 = plot(plot1, title = "EMA 1", color = c1, linewidth = 2)
p2 = plot(plot2, title = "EMA 2", color = c2, linewidth = 1)
p3 = plot(plot3, title = "EMA 3", color = c3, linewidth = 1)
p4 = plot(plot4, title = "EMA 4", color = c4, linewidth = 1)
p5 = plot(plot5, title = "EMA 5", color = c5, linewidth = 1)
p6 = plot(plot6, title = "EMA 6", color = c6, linewidth = 1)
p7 = plot(plot7, title = "EMA 7", color = c7, linewidth = 1)
p8 = plot(plot8, title = "EMA 8", color = c8, linewidth = 2)

// --- Ribbon fills between adjacent EMAs ---
color fillCol = color.new(stateColor, 85)
fill(p1, p2, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 1 → 2")
fill(p2, p3, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 2 → 3")
fill(p3, p4, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 3 → 4")
fill(p4, p5, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 4 → 5")
fill(p5, p6, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 5 → 6")
fill(p6, p7, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 6 → 7")
fill(p7, p8, color = i_showFills and i_showEmas ? fillCol : na, title = "EMA 7 → 8")

// --- Background tint when ribbon is fully aligned (or chopped) ---
color bgCol = bullAligned ? color.new(BULL_COLOR, 92) : bearAligned ? color.new(BEAR_COLOR, 92) : chop ? color.new(WARNING_COLOR, 94) : na
bgcolor(i_showBg ? bgCol : na, title = "Alignment Background")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullFlip and i_alertBullFlip, title = "Ribbon Fully Bullish",
    message = "Intraday Trend Ribbon [DYNA]: Ribbon flipped fully bullish — all 8 EMAs stacked fast over slow.")
alertcondition(bearFlip and i_alertBearFlip, title = "Ribbon Fully Bearish",
    message = "Intraday Trend Ribbon [DYNA]: Ribbon flipped fully bearish — all 8 EMAs stacked fast under slow.")
alertcondition(chopStart and i_alertChop,    title = "Ribbon Tangled (Chop)",
    message = "Intraday Trend Ribbon [DYNA]: Ribbon entered chop — EMAs compressed and unaligned.")
````
