# Range Compression Detector

- url: https://www.tradingview.com/script/DsQ5IsSR-Range-Compression-Detector/
- type: indicator
- pine_id: PUB;d0d0b2fccedd478899358c7cdb01387d
- version: 1.0

## Description

WHAT THIS SCRIPT DOES

This indicator answers one question before you take a trade: is the market currently trending, or is it going sideways?

It does not generate entries. It classifies conditions, so you can tell whether the tools you are about to use are appropriate right now.

The chart is shaded by state — yellow for a range, green for an uptrend, red for a downtrend — and when a range is active the script draws its boundaries and reports its height in both points and percent.


THE MEASUREMENT

Most traders identify a range visually, after it has already cost them several stops. There is an earlier and more mechanical signal.

The script measures the distance between a fast and a slow moving average, expressed as a percentage of price:

separation = |EMA(fast) - EMA(slow)| / close x 100

In a trending market this number expands. Price pulls away from its own average and the two lines fan out. In a range it collapses toward zero — the averages sit on top of each other because price keeps returning to the same area.

Expressing it as a percentage rather than in points is what makes it portable. Fifty points of separation means something very different on an instrument priced at 4,000 than on one priced at 1.10. The percentage normalises that.


WHY IT MATTERS

Almost every pullback or trend-following system contains a version of this condition:

uptrend   = EMA(fast) > EMA(slow)
downtrend = EMA(fast) < EMA(slow)

When the two averages are a fraction of a percent apart, ordinary noise flips that condition back and forth. The system declares an uptrend, fires a long, then declares a downtrend two bars later and fires a short. Both get stopped.

That is not a broken system. It is a system being asked a question it was not built to answer. This indicator is intended to tell you when you are asking it.


THE THREE STATES

Two thresholds create three zones rather than a binary switch.

Range — separation at or below the compression threshold. The averages have converged. Trend logic is unreliable here.

Trend — separation at or above the trend threshold, with direction taken from which average is on top.

Transition — separation between the two thresholds. Neither condition is established. This band exists deliberately: a single line would produce constant flipping at the boundary, which is the same problem the indicator is meant to diagnose.

A state must also hold for a set number of consecutive bars before it is accepted. That adds lag, and it removes almost all of the flicker.

Transition is shaded but not labelled. It is the least actionable of the three, and labelling every entry into it was the single largest source of chart clutter during testing.


TIMEFRAMES DISAGREE, AND THAT IS THE POINT

Running this on three timeframes of the same instrument at the same moment will often give three different answers. In testing on gold, the 15-minute chart read transition, the 4-hour read range, and the daily read trend — simultaneously, with the default thresholds.

None of those is wrong. A market can be trending on the daily while going nowhere on the 4-hour.

The indicator reports the state of the timeframe you are looking at, which is the state that matters for the trade you are about to take on it. If you trade intraday inside a daily uptrend, the daily reading tells you the background; the lower timeframe reading tells you whether your entry tool will work this afternoon.


READING THE PANEL

The panel shows the current state, the live separation figure, your two thresholds for reference, and — once a range has lasted long enough to qualify — its boundaries, its height in points and percent, and how many bars it has run.

The height figure is the useful one for sizing expectations. A range measuring 2% of price gives very different room than one measuring 0.4%.


SETTINGS

Moving averages — the fast and slow lengths. Defaults are 20 and 50.

Classification — compression threshold, trend threshold, minimum bars before a range is drawn, and confirmation bars before a state is accepted.

Display — shading, range boundaries, status panel and state labels can each be turned off independently.

Colours — all three state colours are adjustable.


CALIBRATING THE THRESHOLDS

This is the part that requires work from you, and the defaults will not suit every chart.

The right threshold depends on the instrument's volatility and on the timeframe. Separation naturally widens as bar size grows, so a daily chart produces larger figures than a 15-minute chart of the same instrument.

To calibrate: add the indicator, open the Data Window, and watch the separation value through a period you already recognise as a clear trend, then through a period you recognise as a clear range. The threshold belongs between those two observed bands.

Suggested starting points, from testing on gold:

4-hour      0.10% / 0.25%   (the defaults)
15-minute   0.06% / 0.18%
Daily       0.40% / 1.00%

Only the 4-hour pair was tested in depth. The other two are extrapolated from observed readings and should be verified on your own chart before you rely on them.

If the indicator shows transition almost all of the time, your thresholds are too far apart. If it flips between range and trend, they are too close together or the confirmation period is too short.


LIMITATIONS - PLEASE READ

It is descriptive, not predictive. It tells you what conditions have been, not what they will be. A range can end on the next bar.

It lags. The confirmation period means a state is recognised after it has already been in place for several bars. That is a deliberate trade-off against false classification, and it cannot be removed without reintroducing the flicker.

Thresholds are instrument-specific and timeframe-specific. Using the defaults on an unfamiliar chart will produce misleading classifications. Calibration is not optional.

Two moving averages are a crude proxy. They capture the most common form of directionless market, but not every one. A market can trend slowly enough that separation stays low, and it can spike violently inside a range and briefly read as trending.

Range boundaries are drawn from the bars observed so far. The box grows as the range develops and reflects what has happened, not where the range will ultimately be contained. The boundaries are also not redrawn retroactively once the range ends.

It produces no entries, no targets and no stops. Combining it with a signal system is left to you, and this publication makes no claim about what that combination would produce.


ON PERFORMANCE CLAIMS

This publication makes no claim about win rate, accuracy or profitability. No such claim can be substantiated for future market conditions. What the script does is make one property of the market measurable and visible so you can decide which of your own tools fits it.


ORIGINALITY

Moving average separation is not a new observation, and neither are EMAs. The original work is in the treatment: a normalised percentage measure rather than a raw distance, a three-state classification with an explicit transition band instead of a binary switch, a confirmation requirement to suppress boundary flicker, a minimum-duration filter so brief pauses are not drawn as ranges, and automatic measurement of the range that the compression identifies — its boundaries, its height in points and percent, and its duration.

The intent is different from most published trend filters as well. This does not filter signals for you or tell you what to trade. It reports a condition and leaves the decision where it belongs. The code is published open-source so every threshold and every rule can be inspected and changed.

## Source Code

````pine
//@version=6
indicator("Range Compression Detector", overlay=true, max_boxes_count=200, max_labels_count=100)

// ── INPUTS ────────────────────────────────────────────────
i_fast    = input.int(20, "Fast EMA", group="Moving averages")
i_slow    = input.int(50, "Slow EMA", group="Moving averages")

i_compTh  = input.float(0.10, "Compression threshold %", step=0.01, group="Classification", tooltip="Separation below this percentage is treated as a range. Tune it per instrument.")
i_trendTh = input.float(0.25, "Trend threshold %", step=0.01, group="Classification", tooltip="Separation above this percentage is treated as a trend. The gap between the two thresholds is the transition zone.")
i_minBars = input.int(8, "Min bars to draw a range", minval=1, group="Classification", tooltip="A range must last at least this many bars before its box is drawn.")
i_confirm = input.int(3, "Confirmation bars", minval=1, group="Classification", tooltip="How many consecutive bars a state must hold before it is accepted.")

i_shade   = input.bool(true, "Shade range periods", group="Display")
i_showBox = input.bool(true, "Draw range boundaries", group="Display")
i_showPnl = input.bool(true, "Show status panel", group="Display")
i_showLbl = input.bool(true, "Label state changes", group="Display")
i_txtSize = input.string("Large", "Panel text size", options=["Small", "Normal", "Large", "Huge"], group="Display", tooltip="Enlarge the status panel for high-resolution screens or screenshots.")

c_range   = input.color(color.new(#F0C040, 88), "Range shading", group="Colours")
c_trendUp = input.color(color.new(#6DC230, 90), "Uptrend shading", group="Colours")
c_trendDn = input.color(color.new(#FF6464, 90), "Downtrend shading", group="Colours")

// ── CORE MEASUREMENT ──────────────────────────────────────
emaF = ta.ema(close, i_fast)
emaS = ta.ema(close, i_slow)
sep  = math.abs(emaF - emaS) / close * 100.0

plot(emaF, "Fast EMA", color=color.new(color.yellow, 30), linewidth=1)
plot(emaS, "Slow EMA", color=color.new(#1E90FF, 30), linewidth=1)

// ── STATE CLASSIFICATION ──────────────────────────────────
rawState = sep <= i_compTh ? 0 : sep >= i_trendTh ? 1 : 2

var int state     = 2
var int holdCount = 0
var int pendState = 2

if rawState == pendState
    holdCount += 1
else
    pendState := rawState
    holdCount := 1

stateChanged = false
if holdCount >= i_confirm and state != pendState
    state := pendState
    stateChanged := true

isRange = state == 0
isTrend = state == 1
isTrans = state == 2
trendUp = isTrend and emaF > emaS
trendDn = isTrend and emaF < emaS

// ── BACKGROUND SHADING ────────────────────────────────────
bgCol = not i_shade ? na : isRange ? c_range : trendUp ? c_trendUp : trendDn ? c_trendDn : na
bgcolor(bgCol, title="State shading")

// ── RANGE BOUNDARIES ──────────────────────────────────────
var float rngHi    = na
var float rngLo    = na
var int   rngStart = na
var box   rngBox   = na
var int   rngBars  = 0

if barstate.isconfirmed
    if isRange
        if na(rngStart)
            rngStart := bar_index
            rngHi := high
            rngLo := low
            rngBars := 1
        else
            rngHi := math.max(rngHi, high)
            rngLo := math.min(rngLo, low)
            rngBars += 1
            if i_showBox and na(rngBox) and rngBars >= i_minBars
                rngBox := box.new(rngStart, rngHi, bar_index, rngLo, border_color=color.new(#F0C040, 40), border_width=1, bgcolor=color.new(#F0C040, 94))
            if i_showBox and not na(rngBox)
                box.set_right(rngBox, bar_index)
                box.set_top(rngBox, rngHi)
                box.set_bottom(rngBox, rngLo)
    else
        rngStart := na
        rngBox := na
        rngBars := 0

rngHeight = (not na(rngHi) and not na(rngLo)) ? rngHi - rngLo : na
rngPct    = not na(rngHeight) ? rngHeight / close * 100.0 : na

// ── STATE CHANGE LABELS ───────────────────────────────────
if i_showLbl and stateChanged and barstate.isconfirmed and not isTrans
    txt  = isRange ? "RANGE" : trendUp ? "TREND UP" : "TREND DOWN"
    col  = isRange ? #F0C040 : trendUp ? #6DC230 : #FF6464
    sty  = trendUp ? label.style_label_up : label.style_label_down
    yPos = trendUp ? low : high
    label.new(bar_index, yPos, txt, color=color.new(col, 20), textcolor=color.black, style=sty, size=size.small)

// ── STATUS PANEL ──────────────────────────────────────────
var table pnl = table.new(position.top_right, 2, 6, bgcolor=#0D1117, border_width=1, border_color=#2A2D4A, frame_width=2, frame_color=#2A2D4A)

szBig = i_txtSize == "Small" ? size.normal : i_txtSize == "Normal" ? size.large : i_txtSize == "Large" ? size.huge : size.huge
szMid = i_txtSize == "Small" ? size.small : i_txtSize == "Normal" ? size.normal : i_txtSize == "Large" ? size.large : size.huge
szSml = i_txtSize == "Small" ? size.tiny : i_txtSize == "Normal" ? size.small : i_txtSize == "Large" ? size.normal : size.large

if i_showPnl and barstate.islast
    stTxt = isRange ? "RANGE" : trendUp ? "TREND UP" : trendDn ? "TREND DOWN" : "TRANSITION"
    stCol = isRange ? #F0C040 : trendUp ? #6DC230 : trendDn ? #FF6464 : #8899AA
    hdrBg = #1A1E3A
    rowBg = #0D1117
    thTxt = str.tostring(i_compTh, "#.##") + "% / " + str.tostring(i_trendTh, "#.##") + "%"
    qual  = isRange and rngBars >= i_minBars
    bandTxt = qual and not na(rngHeight) ? str.tostring(rngLo, format.mintick) + " - " + str.tostring(rngHi, format.mintick) : "-"
    sizeTxt = qual and not na(rngPct) ? str.tostring(rngHeight, format.mintick) + "  (" + str.tostring(rngPct, "#.##") + "%)  " + str.tostring(rngBars) + " bars" : "-"

    table.cell(pnl, 0, 0, "COMPRESSION", text_color=#8AB4FF, text_size=szMid, bgcolor=hdrBg, text_halign=text.align_left)
    table.cell(pnl, 1, 0, "", bgcolor=hdrBg)
    table.cell(pnl, 0, 1, stTxt, text_color=stCol, text_size=szBig, bgcolor=rowBg, text_halign=text.align_center)
    table.cell(pnl, 1, 1, "", bgcolor=rowBg)
    table.cell(pnl, 0, 2, "Separation", text_color=#BBBBBB, text_size=szMid, bgcolor=rowBg, text_halign=text.align_left)
    table.cell(pnl, 1, 2, str.tostring(sep, "#.###") + "%", text_color=color.white, text_size=szMid, bgcolor=rowBg, text_halign=text.align_right)
    table.cell(pnl, 0, 3, "Range / Trend", text_color=#BBBBBB, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
    table.cell(pnl, 1, 3, thTxt, text_color=#9AAABB, text_size=szSml, bgcolor=rowBg, text_halign=text.align_right)
    table.cell(pnl, 0, 4, "Band", text_color=#BBBBBB, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
    table.cell(pnl, 1, 4, bandTxt, text_color=#F0C040, text_size=szSml, bgcolor=rowBg, text_halign=text.align_right)
    table.cell(pnl, 0, 5, "Height", text_color=#BBBBBB, text_size=szSml, bgcolor=rowBg, text_halign=text.align_left)
    table.cell(pnl, 1, 5, sizeTxt, text_color=#8AB4FF, text_size=szSml, bgcolor=rowBg, text_halign=text.align_right)

// ── ALERTS ────────────────────────────────────────────────
alertcondition(stateChanged and isRange, "Range detected", "Moving average separation has collapsed - market is ranging.")
alertcondition(stateChanged and isTrend, "Trend detected", "Moving average separation has expanded - market is trending.")

plot(sep, "Separation %", color=color.new(color.purple, 100), display=display.data_window)
````
