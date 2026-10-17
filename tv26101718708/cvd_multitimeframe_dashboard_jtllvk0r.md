# CVD Multi-Timeframe Dashboard

- url: https://www.tradingview.com/script/jTLLVK0r-CVD-Multi-Timeframe-Dashboard/
- type: indicator
- pine_id: PUB;56c1c2836c5a48ebad9ec74dcdbfce1d
- version: 1.0

## Description

CVD Multi-Timeframe Dashboard

[b]═══════════════════════════════════════════
WHAT IT DOES
═══════════════════════════════════════════[/b]
Most CVD tools only show you the timeframe you're standing on. This one shows
you the whole stack at once. Stay on your execution chart — 1m, 3m, 5m,
whatever you trade — and read the net buying vs. selling pressure of the 5m,
15m, 1h, 4h, Daily and Weekly in a single on-chart table.

In one glance you know whether the bigger picture is backing your trade or
fighting it.

[b]═══════════════════════════════════════════
WHY IT'S USEFUL
═══════════════════════════════════════════[/b]
Price can rise while volume delta quietly turns negative — buyers stepping
back even as the candle stays green. That divergence is an early warning, and
it's far more powerful when you can see it line up (or break down) across
multiple timeframes:

- All rows green  → broad, one-sided buying. Trend trades have the wind behind them.
- All rows red    → broad selling pressure. Longs are swimming upstream.
- Mixed rows      → the timeframes disagree — often a pullback, rotation, or a
                    turning point forming.

This turns CVD from a single-timeframe reading into a top-down confluence tool.

[b]═══════════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════════[/b]
Volume Delta = volume hitting the offer (buying) minus volume hitting the bid
(selling). The script uses TradingView's ta.requestVolumeDelta() engine, which
scans lower-timeframe data to approximate that split as accurately as the
data allows.

Each row anchors that engine to a different timeframe and reports the NET delta
of that timeframe's CURRENT, developing bar — i.e. how much net buy/sell flow
has built up since that candle opened. As a higher-timeframe bar progresses,
its value accumulates; when a new bar opens, it resets. That's why the rows
genuinely differ from one another instead of repeating the same number.

[b]═══════════════════════════════════════════
READING THE TABLE
═══════════════════════════════════════════[/b]
TF      → the monitored timeframe
CVD Δ   → net volume delta of its current bar (auto-formatted K / M / B)
Bias    → BUY (positive) or SELL (negative), colour-coded

[b]═══════════════════════════════════════════
SETTINGS
═══════════════════════════════════════════[/b]
- Timeframes to monitor — up to 6 slots, each with its own on/off toggle and
  timeframe. Set them equal to or higher than your chart timeframe.
- Lower timeframe — resolution used to approximate up/down volume. Automatic
  by default; lower = more precise, higher = more history.
- Style — table position, text size, and your own positive/negative colours.

[b]═══════════════════════════════════════════
ALERTS
═══════════════════════════════════════════[/b]
"CVD bias flip" fires the moment any monitored timeframe's delta crosses
between positive and negative — useful for catching a shift in flow without
staring at the screen.

[b]═══════════════════════════════════════════
NOTES & LIMITATIONS
═══════════════════════════════════════════[/b]
- Monitor timeframes ≥ your chart timeframe; lower ones aren't meaningful.
- The symbol must provide volume data, or the script will tell you.
- Lower-timeframe scanning approximates buy/sell volume — it isn't true
  tick or bid/ask data. Use it as a directional gauge, not an exact figure.

Built on TradingView's open-source CVD logic and the ta.requestVolumeDelta()
function from the TradingView/ta library. Open-source — feedback and forks
welcome.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © traderdsr36

//@version=6
indicator("CVD Multi-Timeframe Dashboard", "CVD MTF", overlay = true, format = format.volume)

import TradingView/ta/8 as tav

// ───────────────────────── TIMEFRAME SLOTS ─────────────────────────────
g1 = "Timeframes to monitor"
e1 = input.bool(true,  "", inline = "t1", group = g1)
t1 = input.timeframe("5",   "Slot 1", inline = "t1", group = g1)
e2 = input.bool(true,  "", inline = "t2", group = g1)
t2 = input.timeframe("15",  "Slot 2", inline = "t2", group = g1)
e3 = input.bool(true,  "", inline = "t3", group = g1)
t3 = input.timeframe("60",  "Slot 3", inline = "t3", group = g1)
e4 = input.bool(true,  "", inline = "t4", group = g1)
t4 = input.timeframe("240", "Slot 4", inline = "t4", group = g1)
e5 = input.bool(true,  "", inline = "t5", group = g1)
t5 = input.timeframe("D",   "Slot 5", inline = "t5", group = g1)
e6 = input.bool(false, "", inline = "t6", group = g1)
t6 = input.timeframe("W",   "Slot 6", inline = "t6", group = g1)

// ───────────────────────── CALCULATION ─────────────────────────────────
gC = "Calculation"
ltfTip = "Lower timeframe scanned to approximate up/down volume. Auto by default; lower = more precise but less history."
useCustomTF = input.bool(false, "Use custom lower timeframe", group = gC, tooltip = ltfTip)
customTF    = input.timeframe("1", "Lower timeframe", active = useCustomTF, group = gC)

var lowerTimeframe = switch
    useCustomTF          => customTF
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    =>                      "60"

// ───────────────────────── STYLE ───────────────────────────────────────
gS    = "Style"
posIn = input.string("Top Right", "Table position", group = gS,
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"])
szIn  = input.string("Normal", "Text size", group = gS,
     options = ["Tiny", "Small", "Normal", "Large"])
upCol = input.color(color.teal, "Positive Δ", inline = "cc", group = gS)
dnCol = input.color(color.red,  "Negative Δ", inline = "cc", group = gS)

tblPos = switch posIn
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    =>                 position.top_right

tblSz = switch szIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.normal

// ───────────────────── PER-TIMEFRAME CVD ENGINE ────────────────────────
[o1, h1, l1, cvd1] = tav.requestVolumeDelta(lowerTimeframe, t1)
[o2, h2, l2, cvd2] = tav.requestVolumeDelta(lowerTimeframe, t2)
[o3, h3, l3, cvd3] = tav.requestVolumeDelta(lowerTimeframe, t3)
[o4, h4, l4, cvd4] = tav.requestVolumeDelta(lowerTimeframe, t4)
[o5, h5, l5, cvd5] = tav.requestVolumeDelta(lowerTimeframe, t5)
[o6, h6, l6, cvd6] = tav.requestVolumeDelta(lowerTimeframe, t6)

// ───────────────────────── HELPERS ─────────────────────────────────────
f_num(x) =>
    a = math.abs(x)
    sgn = x < 0 ? "-" : ""
    a >= 1e9 ? sgn + str.tostring(a / 1e9, "#.##") + "B" :
     a >= 1e6 ? sgn + str.tostring(a / 1e6, "#.##") + "M" :
     a >= 1e3 ? sgn + str.tostring(a / 1e3, "#.##") + "K" :
     sgn + str.tostring(a, "#.#")

// ───────────────────────── TABLE RENDER ────────────────────────────────
var table dash = table.new(tblPos, 3, 8, border_width = 1, border_color = color.new(color.gray, 60))

f_row(rowIdx, en, tf, val) =>
    if en
        c  = val >= 0 ? upCol : dnCol
        bg = color.new(c, 82)
        table.cell(dash, 0, rowIdx, tf, text_color = chart.fg_color, bgcolor = color.new(color.gray, 90), text_size = tblSz)
        table.cell(dash, 1, rowIdx, f_num(val), text_color = c, bgcolor = bg, text_size = tblSz)
        table.cell(dash, 2, rowIdx, val >= 0 ? "BUY" : "SELL", text_color = c, bgcolor = bg, text_size = tblSz)

if barstate.islast
    table.clear(dash, 0, 0, 2, 7)
    table.cell(dash, 0, 0, "TF",    text_color = chart.fg_color, bgcolor = color.new(color.gray, 70), text_size = tblSz)
    table.cell(dash, 1, 0, "CVD Δ", text_color = chart.fg_color, bgcolor = color.new(color.gray, 70), text_size = tblSz)
    table.cell(dash, 2, 0, "Bias",  text_color = chart.fg_color, bgcolor = color.new(color.gray, 70), text_size = tblSz)
    f_row(1, e1, t1, cvd1)
    f_row(2, e2, t2, cvd2)
    f_row(3, e3, t3, cvd3)
    f_row(4, e4, t4, cvd4)
    f_row(5, e5, t5, cvd5)
    f_row(6, e6, t6, cvd6)

// ───────────────────────── ALERTS ──────────────────────────────────────
flip(en, v) => en and (ta.crossover(v, 0) or ta.crossunder(v, 0))
anyFlip = flip(e1, cvd1) or flip(e2, cvd2) or flip(e3, cvd3) or flip(e4, cvd4) or flip(e5, cvd5) or flip(e6, cvd6)
alertcondition(anyFlip, "CVD bias flip", "A monitored timeframe's CVD delta flipped sign")

// ─────────────────────── VOLUME CHECK ──────────────────────────────────
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
