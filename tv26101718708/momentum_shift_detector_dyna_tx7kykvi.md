# Momentum Shift Detector [DYNA]

- url: https://www.tradingview.com/script/Tx7KyKvI-Momentum-Shift-Detector-DYNA/
- type: indicator
- pine_id: PUB;807dd7d27ee946ab996c667362dbca50
- version: 1.0

## Description

Momentum Shift Detector pinpoints the exact bar where short-term momentum changes direction. Instead of showing every EMA crossover, it applies four independent filters to surface only the shifts that matter -- giving you clean, actionable turning-point signals directly on your price chart.

Most EMA crossover tools flood the chart with signals, many of which occur in the middle of a move when the easy money has already been made. Momentum Shift Detector solves this by requiring four conditions to align simultaneously: the cross itself, a minimum EMA spread threshold to eliminate weak whipsaw crosses, a volume surge confirming real participation, and proximity to a recent swing extreme proving that price actually reversed at a meaningful level.


[b]Key Features[/b]

[list]
[*] [b]Quad-Filter Signal Engine[/b] -- Combines EMA crossover, EMA spread threshold, volume confirmation, and pivot proximity into a single high-conviction signal
[*] [b]Anti-Whipsaw EMA Spread Filter[/b] -- Requires the fast and slow EMAs to separate by a minimum fraction of ATR before a cross counts, eliminating weak crosses that immediately reverse
[*] [b]Swing Pivot Awareness[/b] -- Only fires when the momentum shift occurs near an actual swing high or swing low, filtering out mid-trend noise
[*] [b]Volume Confirmation[/b] -- Requires above-average volume on the crossover bar, ensuring real market participation backs the shift
[*] [b]Confirmed-Bar Logic[/b] -- Signals are calculated on closed bars so they never repaint or disappear after appearing
[*] [b]Trend-Colored EMA Cloud[/b] -- Fast and slow EMAs with a shaded fill that switches between green and red as the trend changes, giving instant directional context
[*] [b]Multi-Layer Visual Feedback[/b] -- Labeled triangle markers, bar coloring that fades over 3 bars, and a background flash on the shift bar so you never miss a signal
[/list]


[b]How It Works[/b]

The indicator runs a fast EMA (default period 3) and a slow EMA (default period 8) on every bar. When the fast EMA crosses above the slow EMA, a potential bullish shift is detected. When it crosses below, a potential bearish shift is detected. But the signal does not fire yet.

Next, the EMA spread filter checks whether the gap between the fast and slow EMAs exceeds a minimum fraction of ATR(14). This prevents whipsaw signals where the EMAs barely cross before reversing -- a common problem on lower timeframes with choppy price action.

Then, the volume filter checks whether the crossover bar had trading volume above the user-defined multiplier (default 1.3x) times the 20-bar average volume. This ensures the shift is backed by genuine market activity, not just thin, random price movement.

Finally, the pivot proximity filter checks whether a recent swing low (for bullish shifts) or swing high (for bearish shifts) was detected within a defined number of bars. This is the key differentiator -- it means the momentum flip is happening at a place where price actually turned around, not somewhere in the middle of an existing trend.

When all four conditions align, a green triangle labeled "SHIFT" appears below the bar for a bullish flip, or a red triangle above the bar for a bearish flip. The bars around the signal are tinted to match and a subtle background flash highlights the exact moment of the shift. Meanwhile, the fast and slow EMAs are plotted with a color-coded cloud fill that shows the prevailing trend direction at a glance -- green when momentum is bullish, red when bearish.

[image]https://www.tradingview.com/x/gqTvdQEd/[/image]
[i]Bullish (green) and bearish (red) momentum shift signals on a 1-minute chart. The EMA cloud provides continuous trend context while triangle markers and bar coloring highlight confirmed shifts.[/i]


[b]Settings[/b]

The core settings control the sensitivity of each filter. The Fast EMA Length (default 3) and Slow EMA Length (default 8) define the crossover speed -- shorter values react faster but may produce more signals. The Min EMA Spread (default 0.1) sets the minimum fast/slow EMA gap as a fraction of ATR(14) -- raise it to 0.2-0.3 on higher timeframes or set to 0 to disable. The Volume Multiplier (default 1.3) sets the minimum volume threshold as a multiple of the 20-bar average; raising it to 1.5 will require even stronger volume confirmation. The Pivot Proximity setting (default 5 bars) controls how close the signal must be to a detected swing pivot. The Volume Average Length (default 20) determines the lookback window for calculating average volume.

Visual toggles let you independently show or hide bullish and bearish shift markers, the EMA lines and cloud fill, bar coloring around shift events, and the background flash highlight. Alert toggles let you enable notifications for each shift type separately.


[b]Alerts[/b]

[list]
[*] [b]Bullish Momentum Shift[/b] -- Fires when a confirmed bullish crossover occurs with volume above threshold near a recent swing low. [i]"Momentum Shift Detector [DYNA]: Bullish momentum shift detected."[/i]
[*] [b]Bearish Momentum Shift[/b] -- Fires when a confirmed bearish crossover occurs with volume above threshold near a recent swing high. [i]"Momentum Shift Detector [DYNA]: Bearish momentum shift detected."[/i]
[/list]

To set up alerts: click the TradingView Alerts button, select "Momentum Shift Detector [DYNA]" from the indicator dropdown, choose "Any alert() function call" as the condition, and set your preferred notification method.


[b]Best Practices[/b]

[list]
[*] Use the dots as confirmation alongside your existing support/resistance levels, trendlines, or other indicators rather than as a standalone entry trigger
[*] On higher timeframes (4H, Daily), consider widening the EMAs to 5/13 for smoother signals suited to swing trading
[*] If signals are too frequent for your style, raise the Volume Multiplier above 1.3 or increase the Min EMA Spread to 0.2-0.3 to require stronger confirmation
[*] Pay attention to signals that cluster at the same price zone across multiple timeframes -- these tend to mark the strongest reversals
[*] The pivot proximity filter is the main quality gate; lowering it to 3 allows faster signals while raising it to 7-10 requires more established swing points
[/list]


[b]Part of the DYNA Ecosystem[/b]

Momentum Shift Detector is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Momentum Shift Detector [DYNA]
// Flags the exact bar where short-term momentum flips direction. Combines a
// fast EMA vs slow EMA crossover with volume confirmation and pivot proximity
// filtering to highlight only the highest-conviction momentum shifts.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Momentum Shift Detector [DYNA]", shorttitle = "MomShift [DYNA]", overlay = true, max_labels_count = 500, max_lines_count = 500)

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
string GRP_CORE = "Core Settings"
int    i_fastLen      = input.int(3,    "Fast EMA Length",    minval = 1,   maxval = 50,   group = GRP_CORE)
int    i_slowLen      = input.int(8,    "Slow EMA Length",    minval = 2,   maxval = 100,  group = GRP_CORE)
float  i_volMult      = input.float(1.3, "Volume Multiplier", minval = 0.1, maxval = 5.0,  step = 0.1, group = GRP_CORE, tooltip = "Cross-bar volume must exceed this multiple of average volume. Higher = fewer but stronger signals.")
int    i_pivotProx    = input.int(5,    "Pivot Proximity (bars)", minval = 1, maxval = 20,  group = GRP_CORE)
int    i_volAvgLen    = input.int(20,   "Volume Average Length",  minval = 5, maxval = 100, group = GRP_CORE)
float  i_emaSpread   = input.float(0.1, "Min EMA Spread (ATR %)", minval = 0.0, maxval = 2.0, step = 0.05, group = GRP_CORE, tooltip = "Minimum fast/slow EMA gap as a fraction of ATR to confirm a cross. Filters out weak, whipsaw-prone crosses.")

// --- Visual ---
string GRP_VIS = "Visual"
bool   i_showBull  = input.bool(true, "Show Bullish Shifts",  group = GRP_VIS)
bool   i_showBear  = input.bool(true, "Show Bearish Shifts",  group = GRP_VIS)
bool   i_showEmas  = input.bool(true, "Show EMAs",            group = GRP_VIS)
bool   i_barColor  = input.bool(true, "Color Bars on Shift",  group = GRP_VIS)
bool   i_bgFlash   = input.bool(true, "Background Flash on Shift", group = GRP_VIS)

// --- Alerts ---
string GRP_ALERT = "Alerts"
bool   i_alertBull = input.bool(true, "Alert: Bullish Momentum Shift", group = GRP_ALERT)
bool   i_alertBear = input.bool(true, "Alert: Bearish Momentum Shift", group = GRP_ALERT)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- EMA calculations ---
float fastEma = ta.ema(close, i_fastLen)
float slowEma = ta.ema(close, i_slowLen)

// --- EMA crossover detection (confirmed-bar logic) ---
// Check the cross on the previous confirmed bar to avoid repainting.
bool bullCross = fastEma[1] > slowEma[1] and fastEma[2] <= slowEma[2]
bool bearCross = fastEma[1] < slowEma[1] and fastEma[2] >= slowEma[2]

// --- EMA spread filter ---
// Require the EMA gap at the cross bar to exceed a fraction of ATR.
// Kills whipsaw crosses where fast/slow EMAs barely separate.
float atrVal      = ta.atr(14)
float emaGap      = math.abs(fastEma[1] - slowEma[1])
float spreadThresh = i_emaSpread * nz(atrVal[1], syminfo.mintick)
bool  spreadOk    = emaGap >= spreadThresh

// --- Volume filter ---
// Volume must exceed the user-defined multiplier times the average volume.
float volAvg    = ta.sma(volume, i_volAvgLen)
float volThresh = nz(volAvg) == 0 ? 0.0 : i_volMult * volAvg
bool  volOk     = volume[1] > volThresh[1]

// --- Pivot proximity filter ---
// ta.pivotlow and ta.pivothigh return non-na values with a `pivotProx` bar
// delay (they look back AND forward by pivotProx bars). We use ta.barssince
// to check if a pivot was detected within a reasonable lookback window.
// The window is doubled to account for the inherent detection delay.
float pivLow  = ta.pivotlow(low,  i_pivotProx, i_pivotProx)
float pivHigh = ta.pivothigh(high, i_pivotProx, i_pivotProx)

int barsSincePivLow  = ta.barssince(not na(pivLow))
int barsSincePivHigh = ta.barssince(not na(pivHigh))

// For bullish shift: need a recent pivot LOW (price was at a swing low nearby)
bool nearPivotLow  = barsSincePivLow  <= i_pivotProx * 2
// For bearish shift: need a recent pivot HIGH (price was at a swing high nearby)
bool nearPivotHigh = barsSincePivHigh <= i_pivotProx * 2

// --- Final signal conditions ---
bool bullShift = bullCross and volOk and nearPivotLow and spreadOk
bool bearShift = bearCross and volOk and nearPivotHigh and spreadOk

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// --- Trend direction for coloring ---
bool trendUp = fastEma > slowEma

// --- EMA plots with trend-colored lines ---
color emaColor = trendUp ? BULL_COLOR : BEAR_COLOR
plot(i_showEmas ? fastEma : na, "Fast EMA", color = color.new(emaColor, 30), linewidth = 2)
plot(i_showEmas ? slowEma : na, "Slow EMA", color = color.new(emaColor, 60), linewidth = 1, style = plot.style_line)

// --- EMA fill to show trend zone ---
p1 = plot(i_showEmas ? fastEma : na, "Fast EMA Fill", color = color(na), display = display.none)
p2 = plot(i_showEmas ? slowEma : na, "Slow EMA Fill", color = color(na), display = display.none)
fill(p1, p2, color = color.new(emaColor, 88), title = "EMA Cloud")

// --- Signal markers: triangles with text labels ---
plotshape(i_showBull and bullShift ? low : na, "Bullish Shift", style = shape.triangleup, location = location.belowbar, color = BULL_COLOR, size = size.small, text = "SHIFT", textcolor = BULL_COLOR)
plotshape(i_showBear and bearShift ? high : na, "Bearish Shift", style = shape.triangledown, location = location.abovebar, color = BEAR_COLOR, size = size.small, text = "SHIFT", textcolor = BEAR_COLOR)

// --- Bar coloring: highlight bars around momentum shifts ---
// Color the shift bar and the next 2 bars for visibility
var int bullShiftAge = 100
var int bearShiftAge = 100
bullShiftAge := bullShift ? 0 : bullShiftAge + 1
bearShiftAge := bearShift ? 0 : bearShiftAge + 1

color shiftBarCol = na
if i_barColor
    if bullShiftAge <= 2
        shiftBarCol := color.new(BULL_COLOR, bullShiftAge * 25)
    else if bearShiftAge <= 2
        shiftBarCol := color.new(BEAR_COLOR, bearShiftAge * 25)
barcolor(shiftBarCol, title = "Shift Bar Color")

// --- Background flash on shift bar ---
bgcolor(i_bgFlash and bullShift ? color.new(BULL_COLOR, 85) : na, title = "Bullish Shift Flash")
bgcolor(i_bgFlash and bearShift ? color.new(BEAR_COLOR, 85) : na, title = "Bearish Shift Flash")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullShift, title = "Bullish Momentum Shift", message = "Momentum Shift Detector [DYNA]: Bullish momentum shift detected. Fast EMA crossed above slow EMA with volume confirmation near a swing low.")
alertcondition(bearShift, title = "Bearish Momentum Shift", message = "Momentum Shift Detector [DYNA]: Bearish momentum shift detected. Fast EMA crossed below slow EMA with volume confirmation near a swing high.")
````
