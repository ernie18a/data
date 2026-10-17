# Stage 4 Trendline [Vishwajeeth_JK]

- url: https://www.tradingview.com/script/poTq13o0-Stage-4-Trendline-Vishwajeeth-JK/
- type: indicator
- pine_id: PUB;e3e6e58616c74f03abc801371b459263
- version: 2.0

## Description

Stage 4 Trendline [Vishwajeeth_JK]

WHAT IT DOES
This indicator finds deep declines (Stage 4 in stage analysis) and automatically draws the downtrend line from the high. A close above that line is the first signal that the decline may be ending and a Stage 1 base could begin.

HOW IT WORKS
1. Stage 4 detection
A Stage 4 starts when price falls 40% (adjustable) from its all-time high. You can switch the reference to a lookback high, such as the 52-week high. The high is marked as "S4 peak", and the deepest low is labelled with the total decline and the number of bars it took.

2. Automatic trendline
The trendline starts at the peak and is drawn so that no candle body closes above it. Wicks may pierce it, as in a hand-drawn trendline. The line touches the highest lower high that keeps every body below it, and a small dot marks the touch point.

3. Trendline break
A close above the trendline is marked "TL break". This is the point to start watching for a Stage 1 base.

4. Failed breakouts
A break only counts if the low holds. If, after a break, price comes back to the Stage 4 low (within the retest zone, 5% by default) or falls another 40% from the rally high, the break is cancelled. The trendline is then redrawn from the same peak over all candles, so you always see one clean line per decline instead of many short ones.

5. Cycle end
The first point stays fixed until price trades above it. Only then can a new Stage 4 cycle begin.

SETTINGS
- Minimum decline %: the size of fall that defines Stage 4 (default 40).
- Peak (first point): all-time high or lookback high.
- Lookback: number of bars for lookback-high mode (252 = 52 weeks on daily).
- Retest zone %: how close to the Stage 4 low a pullback must come to cancel a breakout. Set it to 0 to require a new lower low.
- Measure on closes: use closing prices instead of high/low for the decline.
- Display options: peak-to-low line, touch point, status table and colors.

ALERTS
- Stage 4 (40% down): a new Stage 4 has started.
- Trendline break: price closed above the trendline.
- Breakout failed: the break was cancelled and the trendline was redrawn.

NOTES
- Best used on daily or weekly charts.
- "All-time high" means the highest price in the data TradingView loads for the symbol.
- The trendline is fitted over a maximum of 5,000 bars.
- Labels and lines can be redrawn while a cycle is still active, because a breakout can later fail. A "TL break" is final only once price stays above the line.

This script is for educational and analysis purposes only and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Vishwajeeth_JK

//@version=6
indicator("Stage 4 Trendline", shorttitle="Stage 4 ", overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ───────────── Inputs ─────────────
dropPct   = input.float(40.0, "Minimum decline %", minval=1, step=1)
peakMode  = input.string("All-time high", "Peak (first point)", options=["All-time high", "Lookback high"], tooltip="All-time high: the trendline always starts at the ATH. Lookback high: starts at the highest high of the lookback window (252 bars = 52-week high on daily). In both modes the first point stays fixed until price trades above it.")
lookback  = input.int(252, "Lookback (bars) - for Lookback high mode", minval=10, maxval=4999)
retestPct = input.float(5.0, "Retest zone above Stage 4 low %", minval=0, step=0.5, tooltip="After a trendline break, a low within this % above the latest Stage 4 low (or below it) cancels the break and the trendline is redrawn from the same peak. 0 = only a new lower low cancels it.")
useClose  = input.bool(false, "Measure decline on closes (instead of high/low)")
showPL    = input.bool(false, "Show peak-to-low line")
showTouch = input.bool(true, "Mark trendline touch point")
showZone  = input.bool(false, "Shade Stage 4 zone")
showTable = input.bool(true, "Show status table")
s4Color   = input.color(color.red, "Stage 4 color")
tlColor   = input.color(color.blue, "Trendline color")
brkColor  = input.color(color.green, "Breakout color")

useATH  = peakMode == "All-time high"
srcHigh = useClose ? close : high
srcLow  = useClose ? close : low
bodyTop = math.max(open, close)

// ───────────── Trendline fit ─────────────
// The line starts at the peak high. Among all candle highs after the peak, choose the one
// giving the tightest line that no candle BODY rises above (wicks may poke through).
f_fitTrendline(int p0, float P) =>
    int   n      = math.min(bar_index - p0, 4999)
    float sBody  = na
    float sLine  = na
    int   anchor = na
    if n >= 1
        for i = 0 to n - 1
            int   dist = bar_index - i - p0
            float bs   = (math.max(open[i], close[i]) - P) / dist
            sBody := na(sBody) ? bs : math.max(sBody, bs)
        for i = 0 to n - 1
            int   dist = bar_index - i - p0
            float hs   = (high[i] - P) / dist
            if hs >= sBody and (na(sLine) or hs < sLine)
                sLine  := hs
                anchor := bar_index - i
    [sLine, sBody, anchor]

// ───────────── State ─────────────
var int   state     = 0      // 0 = no open Stage 4, 1 = Stage 4 (below trendline), 2 = trendline broken (provisional)
var float s4Peak    = na     // first point of the trendline (ATH / lookback high)
var int   s4PeakBar = na
var float s4Low     = na     // deepest low of the whole cycle
var int   s4LowBar  = na
var float waveLow   = na     // latest Stage 4 low (used for the retest rule)
var float rallyHigh = na     // highest high since the last trendline break
var int   refStart  = na
var int   brkBar    = na
var float tlSlope   = na
var float tlBody    = na
var int   tlAnchor  = na
var line  tlLine    = na
var line  plLine    = na
var label lowLabel  = na
var label touchLbl  = na
var label brkLabel  = na
var int   s4Count   = 0

f_tlAt(int x) => s4Peak + tlSlope * (x - s4PeakBar)

f_lowText() =>
    "-" + str.tostring((s4Peak - s4Low) / s4Peak * 100, "#.0") + "% in " + str.tostring(s4LowBar - s4PeakBar) + " bars"

// ───────────── All-time high ─────────────
var float ath    = na
var int   athBar = na
if na(ath) or srcHigh > ath
    ath    := srcHigh
    athBar := bar_index

// ───────────── Peak candidate ─────────────
lenRaw    = na(refStart) ? bar_index + 1 : bar_index - refStart
winLen    = math.max(1, math.min(lookback, lenRaw))
lbHigh    = ta.highest(srcHigh, winLen)
lbOffset  = ta.highestbars(srcHigh, winLen)
peakPrice = useATH ? ath : lbHigh
candBar   = useATH ? athBar : bar_index + lbOffset
dd        = (peakPrice - srcLow) / peakPrice * 100
freshPeak = na(s4LowBar) or candBar > s4LowBar
trig      = not na(dd) and dd >= dropPct and freshPeak

newS4    = false
tlBreak  = false
s4Resume = false
handled  = false

// ───────────── 1) After a break: close the cycle, or shift the trendline ─────────────
if state == 2
    rallyHigh := math.max(rallyHigh, srcHigh)
    isRetest  = srcLow <= waveLow * (1 + retestPct / 100)
    isNewWave = (rallyHigh - srcLow) / rallyHigh * 100 >= dropPct
    if srcHigh > s4Peak
        // Price traded above the first point: cycle finished
        state := 0
    else if isRetest or isNewWave
        // Failed breakout: redraw the trendline from the same peak over all candles
        s4Resume := true
        handled  := true
        state    := 1
        label.delete(brkLabel)
        waveLow  := isRetest ? math.min(waveLow, srcLow) : srcLow
        if srcLow < s4Low
            s4Low    := srcLow
            s4LowBar := bar_index
            refStart := bar_index
            label.set_xy(lowLabel, s4LowBar, s4Low)
            if showPL
                line.set_xy2(plLine, s4LowBar, s4Low)
        label.set_text(lowLabel, f_lowText())
        [s, b, a] = f_fitTrendline(s4PeakBar, s4Peak)
        tlSlope  := s
        tlBody   := b
        tlAnchor := a
        line.set_xy2(tlLine, bar_index, f_tlAt(bar_index))
        if showTouch
            label.set_xy(touchLbl, tlAnchor, f_tlAt(tlAnchor))

// ───────────── 2) New Stage 4 (only when no cycle is open) ─────────────
if state == 0 and trig
    newS4     := true
    state     := 1
    s4Count   += 1
    s4Peak    := peakPrice
    s4PeakBar := candBar
    s4Low     := srcLow
    s4LowBar  := bar_index
    waveLow   := srcLow
    refStart  := bar_index
    [s, b, a] = f_fitTrendline(s4PeakBar, s4Peak)
    tlSlope   := s
    tlBody    := b
    tlAnchor  := a
    y2 = na(tlSlope) ? s4Peak : f_tlAt(bar_index)
    tlLine    := line.new(s4PeakBar, s4Peak, bar_index, y2, color=tlColor, width=2)
    label.new(s4PeakBar, s4Peak, "S4 #" + str.tostring(s4Count) + " peak", style=label.style_label_down, color=s4Color, textcolor=color.white, size=size.small)
    lowLabel  := label.new(s4LowBar, s4Low, f_lowText(), style=label.style_label_up, color=s4Color, textcolor=color.white, size=size.small)
    if showPL
        plLine := line.new(s4PeakBar, s4Peak, s4LowBar, s4Low, color=s4Color, width=1, style=line.style_dashed)
    if showTouch
        touchLbl := label.new(na(tlAnchor) ? s4PeakBar : tlAnchor, na(tlAnchor) ? s4Peak : f_tlAt(tlAnchor), "", style=label.style_circle, color=tlColor, size=size.tiny)

// ───────────── 3) Active Stage 4 ─────────────
else if state == 1 and not handled
    dist  = bar_index - s4PeakBar
    tlNow = na(tlSlope) ? na : f_tlAt(bar_index)
    if not na(tlNow) and close > tlNow
        // Close above the trendline -> provisional breakout, stop the line here
        tlBreak   := true
        state     := 2
        brkBar    := bar_index
        rallyHigh := srcHigh
        line.set_xy2(tlLine, bar_index, tlNow)
        brkLabel  := label.new(bar_index, low, "TL break", style=label.style_label_up, color=brkColor, textcolor=color.white, size=size.small)
    else
        // Track the lows
        if srcLow < waveLow
            waveLow := srcLow
        if srcLow < s4Low
            s4Low    := srcLow
            s4LowBar := bar_index
            refStart := bar_index
            label.set_xy(lowLabel, s4LowBar, s4Low)
            if showPL
                line.set_xy2(plLine, s4LowBar, s4Low)
        label.set_text(lowLabel, f_lowText())

        // Update the trendline with this candle
        bs = (bodyTop - s4Peak) / dist
        hs = (high - s4Peak) / dist
        if na(tlSlope)
            tlSlope  := hs
            tlBody   := bs
            tlAnchor := bar_index
        else if bs > tlSlope
            // Body opened above the line but closed below it: refit over all candles
            [s, b, a] = f_fitTrendline(s4PeakBar, s4Peak)
            tlSlope  := s
            tlBody   := b
            tlAnchor := a
        else
            tlBody := math.max(tlBody, bs)
            if hs >= tlBody and hs < tlSlope
                tlSlope  := hs
                tlAnchor := bar_index
        line.set_xy2(tlLine, bar_index, f_tlAt(bar_index))
        if showTouch
            label.set_xy(touchLbl, tlAnchor, f_tlAt(tlAnchor))

// ───────────── Visuals & alerts ─────────────
bgcolor(showZone and state == 1 ? color.new(s4Color, 92) : na, title="Stage 4 zone")
plotshape(newS4, "Stage 4 trigger", shape.triangledown, location.abovebar, s4Color, text="S4", textcolor=s4Color, size=size.tiny)
alertcondition(newS4, "Stage 4 (40% down)", "{{ticker}}: new Stage 4 - price is down 40%+ from its high")
alertcondition(tlBreak, "Trendline break", "{{ticker}}: closed above the Stage 4 trendline - watch for Stage 1")
alertcondition(s4Resume, "Breakout failed", "{{ticker}}: breakout failed - Stage 4 continues, trendline redrawn from the peak")

var table t = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 80), border_width=1)
if showTable and barstate.islast
    statusTxt = state == 1 ? "Stage 4 - below trendline" : state == 2 ? "TL broken " + str.tostring(bar_index - brkBar) + " bars ago - watch Stage 1" : "No active Stage 4"
    statusCol = state == 1 ? color.red : state == 2 ? color.green : color.gray
    tlVal     = state == 1 and not na(tlSlope) ? f_tlAt(bar_index) : na
    table.cell(t, 0, 0, "Status", text_color=color.white)
    table.cell(t, 1, 0, statusTxt, text_color=statusCol)
    table.cell(t, 0, 1, "First point (" + (useATH ? "ATH" : "lookback high") + ")", text_color=color.white)
    table.cell(t, 1, 1, na(s4Peak) or state == 0 ? "n/a" : str.tostring(s4Peak, format.mintick), text_color=color.white)
    table.cell(t, 0, 2, "Decline peak -> low", text_color=color.white)
    table.cell(t, 1, 2, na(s4Peak) ? "n/a" : str.tostring((s4Peak - s4Low) / s4Peak * 100, "#.0") + "%", text_color=color.white)
    table.cell(t, 0, 3, "Trendline (distance)", text_color=color.white)
    table.cell(t, 1, 3, na(tlVal) ? "n/a" : str.tostring(tlVal, format.mintick) + " (" + str.tostring((tlVal - close) / close * 100, "#.0") + "% above price)", text_color=color.white)
    table.cell(t, 0, 4, "Stage 4 events", text_color=color.white)
    table.cell(t, 1, 4, str.tostring(s4Count), text_color=color.white)
````
