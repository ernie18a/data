# Echelon Trend Filter [JOAT]

- url: https://www.tradingview.com/script/KuHToemr-Echelon-Trend-Filter-JOAT/
- type: indicator
- pine_id: PUB;3d24dc15eec14b53ae39d5e3a659f4d3
- version: 1.0

## Description

[b]Echelon Trend Filter [JOAT][/b]

[b]Introduction[/b]

Echelon Trend Filter is a recursive digital trend filter that creates a clean trend spine, optional step-state transitions, EMA context, and pivot zones.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/9dE0ltzY/[/image]

[b]Core Concepts[/b]

[b]1. Recursive Filter[/b]

The source is smoothed recursively to reduce minor bar noise.

[b]2. Step-State Transitions[/b]

Optional step mode holds the trend state until a meaningful transition occurs.

[b]3. EMA Context[/b]

A long EMA gives broader context for the filtered state.

[b]4. Pivot Context Zones[/b]

Recent pivots create reference zones around prior turning areas.

[pine]
state = step > step[1] ? 1 : step < step[1] ? -1 : state[1]
[/pine]

[b]Features[/b]

[list]
[*]Digital trend spine
[*]Optional step-state behavior
[*]EMA cloud context
[*]Pivot context zones
[*]Confirmed transition alerts
[/list]

[b]Input Parameters[/b]

[list]
[*]Filter length and source
[*]Step mode toggle
[*]Institutional EMA length
[*]Pivot length and zone width
[*]Cloud, candle, and panel toggles
[/list]


[b]How to Use This Script[/b]

Use the spine as trend context. Long and short transition labels mark confirmed state changes, while the EMA cloud helps judge broader alignment.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

Echelon is original in combining recursive smoothing, held state transitions, EMA context, and pivot zones into a minimal trend overlay.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Echelon Trend Filter [JOAT]", shorttitle="ETF [JOAT]", overlay=true, max_lines_count=140, max_labels_count=120, max_boxes_count=40)

// Echelon Trend Filter [JOAT]
// Original recursive digital trend filter with persistent step states, EMA cloud, pivot context, and clean trend diagnostics.

string gCore = "Digital Filter"
string gViz = "Visual System"
int len = input.int(12, "Filter length", minval=2, maxval=80, group=gCore)
float srcInput = input.source(close, "Source", group=gCore)
bool stepMode = input.bool(true, "Use step state", group=gCore)
int emaLen = input.int(200, "Institutional EMA", minval=20, maxval=400, group=gViz)
int pivotLen = input.int(10, "Pivot context length", minval=2, maxval=40, group=gViz)
int srWidth = input.int(60, "Context zone width", minval=10, maxval=250, group=gViz)
bool showCloud = input.bool(true, "Show EMA cloud", group=gViz)
bool paintBars = input.bool(true, "Paint trend candles", group=gViz)
bool showPanel = input.bool(true, "Show panel", group=gViz)

color C_BULL = #00ddff
color C_BEAR = #ae00ff
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b
color C_GOLD = #ffeb3b

float a = math.exp(-1.414 * math.pi / len)
float b = 2.0 * a * math.cos(1.414 * math.pi / len)
float c2 = b
float c3 = -a * a
float c1 = 1.0 - c2 - c3
var float filt = na
filt := c1 * srcInput + c2 * nz(filt[1], srcInput) + c3 * nz(filt[2], srcInput)
var float step = na
bool rising = filt > filt[1]
bool falling = filt < filt[1]
step := stepMode ? rising or falling ? filt : nz(step[1], filt) : filt
var int state = 0
if step > step[1]
    state := 1
else if step < step[1]
    state := -1
else
    state := nz(state[1], 0)

float ema = ta.ema(close, emaLen)
bool emaBull = close > ema
bool longFlip = barstate.isconfirmed and state == 1 and nz(state[1]) != 1 and emaBull
bool shortFlip = barstate.isconfirmed and state == -1 and nz(state[1]) != -1 and not emaBull
color stateColor = state == 1 ? C_BULL : state == -1 ? C_BEAR : C_MUTED
plot(step, "ETF digital spine", color=stateColor, linewidth=3)
pEma = plot(ema, "ETF institutional EMA", color=color.new(C_TEXT, 35), linewidth=2)
pClose = plot(showCloud ? close : na, "ETF close cloud anchor", color=color.new(C_TEXT, 100))
fill(pEma, pClose, color=showCloud ? emaBull ? color.new(C_BULL, 88) : color.new(C_BEAR, 88) : na, title="ETF EMA cloud")
plotshape(longFlip, "ETF long transition", shape.labelup, location.belowbar, color=color.new(C_BULL, 8), text="ETF", textcolor=C_BG, size=size.tiny)
plotshape(shortFlip, "ETF short transition", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 8), text="ETF", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? state == 1 ? color.new(C_BULL, 35) : state == -1 ? color.new(C_BEAR, 35) : na : na)

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)
var box[] zones = array.new_box()
if not na(ph)
    array.push(zones, box.new(bar_index - pivotLen, high[pivotLen], bar_index - pivotLen + srWidth, low[pivotLen], bgcolor=color.new(C_BEAR, 92), border_color=color.new(C_BEAR, 72), text="ETF supply", text_color=color.new(C_TEXT, 45), text_size=size.tiny))
if not na(pl)
    array.push(zones, box.new(bar_index - pivotLen, high[pivotLen], bar_index - pivotLen + srWidth, low[pivotLen], bgcolor=color.new(C_BULL, 92), border_color=color.new(C_BULL, 72), text="ETF demand", text_color=color.new(C_TEXT, 45), text_size=size.tiny))
while array.size(zones) > 18
    box.delete(array.shift(zones))

float slope = step - step[5]
float atr = ta.atr(14)
float impulse = atr > 0 ? math.abs(slope) / atr : 0
var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 2, 7, bgcolor=color.new(C_BG, 5), border_color=color.new(C_TEXT, 82), border_width=1)
    table.cell(panel, 0, 0, "ECHELON", text_color=C_TEXT, bgcolor=color.new(stateColor, 72), text_size=size.small)
    table.cell(panel, 1, 0, "ETF", text_color=C_TEXT, bgcolor=color.new(stateColor, 72), text_size=size.small)
    table.cell(panel, 0, 1, "State", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 1, state == 1 ? "Bull" : state == -1 ? "Bear" : "Flat", text_color=stateColor, text_size=size.small)
    table.cell(panel, 0, 2, "EMA gate", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 2, emaBull ? "Above" : "Below", text_color=emaBull ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 0, 3, "Impulse", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 3, str.tostring(impulse, "#.##"), text_color=impulse > 0.50 ? C_GOLD : C_TEXT, text_size=size.small)
    table.cell(panel, 0, 4, "Slope", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 4, str.tostring(slope, format.mintick), text_color=slope >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(panel, 0, 5, "Filter", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 5, str.tostring(step, format.mintick), text_color=stateColor, text_size=size.small)
    table.cell(panel, 0, 6, "Zones", text_color=color.new(C_TEXT, 25), text_size=size.small)
    table.cell(panel, 1, 6, str.tostring(array.size(zones)), text_color=C_TEXT, text_size=size.small)

alertcondition(longFlip, "ETF Long Transition [JOAT]", "Echelon Trend Filter long transition")
alertcondition(shortFlip, "ETF Short Transition [JOAT]", "Echelon Trend Filter short transition")
````
