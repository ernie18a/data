<!-- tradingview-pine-id: PUB;37368e4bad9349ccb77edacde4e299e0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Surge Radar — 2x/4x/8x/16x [sunilp303]

Source: https://www.tradingview.com/script/HR7VSSAZ-Volume-Surge-Radar-2x-4x-8x-16x/

## Description

# Volume Surge Radar — 2x / 4x / 8x / 16x

The goal is simple: don't just find unusual volume—find when unusual volume keeps coming back.

## Overview

**Volume Surge Radar** is designed to identify unusual and **repeated volume activity**, not just isolated volume spikes.

The indicator compares each bar's volume against the **average volume of the previous trading week** and classifies unusual activity into four customizable tiers:

**2x → 4x → 8x → 16x**

It then tracks how often these volume surges occur within a configurable rolling window and combines that information with price behavior to provide a **RISING, FALLING, MIXED, or QUIET bias**.

The idea is simple:

**One volume spike may be noise. Repeated volume surges can tell a much more interesting story.**

---

## Key Features

### 🔹 Relative Volume Multiples

Every bar's volume is compared with its 1-week average volume.

For example:

* **2x** = Volume is at least 2 times the weekly average
* **4x** = Volume is at least 4 times the weekly average
* **8x** = Volume is at least 8 times the weekly average
* **16x** = Volume is at least 16 times the weekly average

The tiers are cumulative. For example, a **9x volume bar qualifies as a 2x, 4x and 8x event**.

---

### 🔹 Dynamic 1-Week Baseline

The indicator can automatically calculate the appropriate number of bars representing approximately one trading week based on the chart timeframe.

For example, the baseline can adapt differently when viewing:

* Daily charts
* Hourly charts
* 15-minute charts
* 5-minute charts

Session minutes and trading days per week are configurable, making the indicator adaptable to different markets.

You can also disable automatic calculation and manually specify the baseline.

---

## 🔹 Repeat Volume Detection

This is one of the main features of Volume Surge Radar.

Instead of only asking:

**"Is volume unusually high right now?"**

the indicator also asks:

**"How many times has unusually high volume appeared recently?"**

For each tier, the dashboard counts how many bars inside the configured rolling window reached:

**2x / 4x / 8x / 16x volume**

This can help distinguish an isolated spike from repeated participation.

For example:

**2x volume once**

may simply represent a single event.

But:

**2x+ volume 4 times within 20 bars**

may deserve significantly more attention.

---

# Understanding the Dashboard

The dashboard provides a compact view of current and recent volume activity.

### NOW

Shows whether the current bar has reached each volume tier.

### Hit Count

Shows how many times each volume threshold has been reached within the configured rolling window.

### Ratio

Displays the exact current volume multiple.

For example:

**3.7x**

means the current bar's volume is approximately **3.7 times the calculated 1-week average volume**.

### Price Change

Displays the percentage price change over the same rolling window used for volume analysis.

### Up / Down Surge Count

Shows how many qualifying high-volume bars closed higher versus lower.

For example:

**5↑ 2↓**

means five qualifying surge bars were positive candles and two were negative candles.

---

# Volume Bias

Volume Surge Radar combines two pieces of information:

1. **Price change over the rolling window**
2. **Whether qualifying volume surges occurred more frequently on up or down bars**

The indicator then produces one of several possible readings.

### 🟢 RISING

Price direction and volume-surge direction both support a bullish interpretation.

Repeated high-volume activity is occurring alongside positive price behavior.

### 🟢 RISING?

Only one of the two measurements supports the bullish interpretation.

Consider this an early or weaker signal rather than confirmation.

### 🔴 FALLING

Price direction and volume-surge direction both support a bearish interpretation.

Repeated high-volume activity is occurring alongside negative price behavior.

### 🔴 FALLING?

Only one measurement supports the bearish interpretation.

Additional confirmation may be useful.

### ⚪ MIXED

Price movement and volume-surge direction disagree.

This may indicate conflicting participation, consolidation, absorption, or a transition period.

### ⚪ QUIET

Not enough qualifying volume events have occurred to establish a meaningful bias.

---

# How I Use It

The indicator is particularly useful as a **confirmation and discovery tool** rather than as a standalone buy/sell signal.

### Example 1 — Breakout Confirmation

A stock breaks above an important resistance level.

Instead of looking only at whether the breakout candle has high volume, Volume Surge Radar can show whether **multiple elevated-volume events have appeared around the breakout**.

Repeated 2x or 4x volume combined with a **RISING** bias can provide additional evidence of participation behind the move.

### Example 2 — Finding Unusual Accumulation

Price may initially move only modestly while several unusually high-volume bars appear within a relatively short period.

For example:

**4 separate 2x+ volume events within 20 bars**

can be more interesting than one isolated 4x spike.

The indicator helps make these repeated events easier to identify.

### Example 3 — Distribution / Weakness

Suppose a stock remains near its highs, but repeated high-volume bars increasingly close down.

The dashboard may begin showing more:

**↓ volume surges**

while the bias moves toward **FALLING?** or **FALLING**.

That divergence between price location and volume behavior may deserve additional investigation.

### Example 4 — Extreme Volume Events

An **8x or 16x** volume bar represents an unusually large departure from the recent baseline.

These events can occur around:

* Earnings
* News
* Breakouts
* Gap moves
* Institutional activity
* Capitulation
* Major reversals

The indicator highlights these extreme-volume bars so they can be investigated quickly.

---

# Alerts

Volume Surge Radar includes several built-in alert conditions.

### Single Volume Surge Alerts

Alerts are available when volume reaches:

**2x / 4x / 8x / 16x**

These are useful when monitoring individual extreme-volume events.

### Repeated Volume Alerts

You can also receive alerts when a particular volume tier occurs repeatedly within the rolling window.

For example:

**2x volume reached 4 times within the last 20 bars**

This allows you to detect persistent unusual-volume activity without constantly watching the chart.

### Bias Alerts

Alerts are also available when the volume/price bias changes to:

**RISING**

or

**FALLING**

### Custom Repeat Alert

A configurable alert allows you to choose:

**Volume Tier + Required Hits + Direction**

For example:

**4x Volume + 3 Hits + Rising Bias**

This makes it possible to create alerts around the specific type of volume behavior you want to monitor.

---

# Suggested Workflow

I generally recommend using Volume Surge Radar alongside market structure rather than interpreting volume in isolation.

Look for repeated volume activity around:

* Support and resistance
* Breakouts and breakdowns
* Consolidation ranges
* Moving averages
* Previous highs/lows
* Gap areas
* Earnings or news events

The indicator answers:

**"Is unusual volume appearing repeatedly, and what is price doing while that volume appears?"**

The trader still determines **why that activity matters within the broader chart structure.**

---

# Important Interpretation

High volume is **not automatically bullish**.

A 4x, 8x or even 16x volume event simply tells us that market participation is unusually high compared with the recent baseline.

That activity could represent:

**Accumulation, distribution, breakout participation, profit-taking, capitulation, news-driven trading, or other market activity.**

For this reason, volume should always be interpreted together with **price action and market structure**.

---

# Limitations

Volume Surge Radar is an analytical tool and should not be treated as an automatic trading system.

The RISING/FALLING bias is based on price movement and the direction of qualifying volume bars. It does **not** directly identify institutional buying or selling.

Extremely high volume can also occur because of earnings, news, index rebalancing or other one-time events.

Different assets have different volume characteristics, so the default thresholds and rolling-window settings may need adjustment depending on the instrument and timeframe.

---

## Final Thought

Traditional volume indicators tell you:

**"Volume is high."**

Volume Surge Radar goes one step further:

**"How high is it, how often has it happened recently, and what has price been doing while those volume surges occurred?"**

That is the core idea behind **Volume Surge Radar**.

The goal is simple: don't just find unusual volume—find when unusual volume keeps coming back.

---

## Source Code

````pine
//@version=6
// ============================================================================
//  Volume Surge Radar  —  2x / 4x / 8x / 16x vs 1-Week Average Volume
//
//  Author : sunilp303
//  License: Mozilla Public License 2.0  https://mozilla.org/MPL/2.0/
//  © sunilp303
//
//  Divides each bar's volume by the average volume of the last trading week
//  and buckets it into tiers. The table shows the current bar's tier, how many
//  times each tier fired inside a rolling window, and a green/red bias when
//  surges repeat. Hover any table cell for an explanation.
//
//  ALERTS (right-click chart > Add alert > Condition = "Surge Radar")
//   Ready-made, nothing to configure:
//     "2x repeated in window"    "4x repeated in window"
//     "8x repeated in window"    "16x repeated in window"
//     "Single bar 2x / 4x / 8x / 16x"
//     "Bias turned RISING" / "Bias turned FALLING"
//   Fully configurable (set tier + hit count + direction in indicator settings):
//     "CUSTOM repeat alert"   or   "Any alert() function call" for rich text
// ============================================================================
indicator("Volume Surge Radar — 2x/4x/8x/16x [sunilp303]", "Surge Radar", overlay = false, format = format.volume)

// ─────────────────────────── Inputs ───────────────────────────
gB = "1-Week Baseline"
autoLen = input.bool(true, "Auto-size baseline to 1 week", group = gB,
     tooltip = "ON: baseline length derived from your chart timeframe (5 bars on daily, 78 on 5-min for a 390-minute session). OFF: uses the manual length below.")
manLen  = input.int(5, "Manual baseline (bars)", minval = 1, group = gB)
sessMin = input.int(390, "Session minutes per day", minval = 1, group = gB,
     tooltip = "US equities = 390. NSE/BSE = 375. Crypto / 24h = 1440. Intraday charts only.")
wkDays  = input.int(5, "Trading days per week", minval = 1, maxval = 7, group = gB)
exclCur = input.bool(true, "Exclude current bar from average", group = gB,
     tooltip = "ON: a spike is compared against the bars BEFORE it, so it cannot inflate its own baseline.")

gT = "Multiples"
m1 = input.float(2.0,  "Tier 1", minval = 1.0, step = 0.5, inline = "a", group = gT)
m2 = input.float(4.0,  "Tier 2", minval = 1.0, step = 0.5, inline = "a", group = gT)
m3 = input.float(8.0,  "Tier 3", minval = 1.0, step = 0.5, inline = "b", group = gT)
m4 = input.float(16.0, "Tier 4", minval = 1.0, step = 0.5, inline = "b", group = gT,
     tooltip = "Tiers are cumulative: a 9x bar counts as a hit on Tier 1, 2 and 3.")

gW = "Rolling Window"
winLen  = input.int(20, "Window length (bars)", minval = 2, group = gW)
minHits = input.int(3,  "Min hits to call a trend", minval = 1, group = gW,
     tooltip = "Below this many hits the Bias row stays QUIET.")
hitAt   = input.string("2x", "Count hits at or above", options = ["2x", "4x", "8x", "16x"], group = gW,
     tooltip = "Which tier drives the Bias verdict and the up/down surge split.")

gA = "Custom Alert"
alTier = input.string("2x", "Tier", options = ["2x", "4x", "8x", "16x"], group = gA,
     tooltip = "Used by the 'CUSTOM repeat alert' condition and the alert() message. Example: tier 2x + 4 hits fires when 4 bars in the window reached 2x.")
alHits = input.int(4, "Hits needed inside window", minval = 1, group = gA)
alDir  = input.string("Any", "Require bias", options = ["Any", "Rising only", "Falling only"], group = gA)
alDyn  = input.bool(true, "Emit rich alert() message", group = gA,
     tooltip = "Choose 'Any alert() function call' in the alert dialog to receive a message containing ticker, ratio, hit count, price change and bias — good for webhooks.")
readyHits = input.int(4, "Ready-made alerts: hits needed", minval = 1, group = gA,
     tooltip = "Hit count used by the four ready-made '<tier> repeated in window' conditions.")

gD = "Display"
theme    = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gD,
     tooltip = "Auto reads your chart background. The table always paints its own solid panel so it stays readable on grey, gradient or image backgrounds.")
tPos     = input.string("Top Right", "Table position", group = gD,
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"])
tSize    = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
panelOp  = input.int(0, "Panel transparency", minval = 0, maxval = 90, group = gD,
     tooltip = "0 = fully solid, which is what keeps 8x / 16x / Ratio legible over a grey chart. Raise it only if you want to see through the table.")
showLvl  = input.bool(true, "Plot multiple levels", group = gD)
showMrk  = input.bool(true, "Mark 8x / 16x bars", group = gD)
showFire = input.bool(true, "Mark bars where the custom alert fires", group = gD)
showCred = input.bool(true, "Show author credit in table", group = gD,
     tooltip = "Adds a footer row with the script author.")

// ─────────────────────────── Helpers ───────────────────────────
fmtVol(float v) =>
    na(v)     ? "n/a" :
     v >= 1e9 ? str.tostring(v / 1e9, "#.##") + "B" :
     v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" :
     v >= 1e3 ? str.tostring(v / 1e3, "#.#")  + "K" : str.tostring(v, "#")

// ────────────────────── Theme / contrast ──────────────────────
float bgLum = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  dark  = theme == "Dark" ? true : theme == "Light" ? false : bgLum < 140
// Mid-grey backgrounds wash out both pale and deep hues, so on-chart marks get
// a punchier palette than the table does.
bool  midBg = theme == "Auto" and bgLum >= 70 and bgLum <= 190

// Table palette — drawn on our own opaque panel, so it only has to suit itself.
color pPanel = dark ? color.rgb(20, 24, 31) : color.rgb(253, 253, 254)
color pRow   = dark ? color.rgb(28, 33, 41) : color.rgb(244, 245, 247)
color pText  = dark ? color.rgb(236, 238, 241) : color.rgb(24, 28, 34)
color pDim   = dark ? color.rgb(154, 161, 170) : color.rgb(99, 106, 116)
color pIdle  = dark ? color.rgb(96, 104, 114) : color.rgb(163, 170, 179)
color pGrid  = dark ? color.rgb(58, 65, 75) : color.rgb(214, 218, 223)
color pUp    = dark ? color.rgb(46, 209, 168) : color.rgb(9, 138, 94)
color pDn    = dark ? color.rgb(247, 100, 120) : color.rgb(199, 46, 62)
color pT1    = dark ? color.rgb(255, 205, 92)  : color.rgb(163, 114, 0)
color pT2    = dark ? color.rgb(255, 154, 61)  : color.rgb(196, 96, 0)
color pT3    = dark ? color.rgb(248, 118, 211) : color.rgb(176, 24, 122)
color pT4    = dark ? color.rgb(174, 148, 255) : color.rgb(98, 48, 200)
color chipTx = color.rgb(255, 255, 255)

// Chart palette — must survive whatever the chart background is.
color kUp = midBg ? color.rgb(0, 168, 132) : dark ? color.rgb(38, 198, 166) : color.rgb(12, 145, 100)
color kDn = midBg ? color.rgb(226, 45, 70)  : dark ? color.rgb(239, 90, 111) : color.rgb(198, 52, 68)
color kT1 = midBg ? color.rgb(214, 150, 0)  : dark ? color.rgb(255, 209, 102) : color.rgb(176, 124, 0)
color kT2 = midBg ? color.rgb(235, 110, 0)  : dark ? color.rgb(255, 159, 67)  : color.rgb(207, 106, 0)
color kT3 = midBg ? color.rgb(233, 20, 140) : dark ? color.rgb(244, 114, 208) : color.rgb(176, 32, 118)
color kT4 = midBg ? color.rgb(103, 40, 214) : dark ? color.rgb(167, 139, 250) : color.rgb(104, 58, 199)
color kAvg = midBg ? color.rgb(60, 66, 74) : dark ? color.rgb(190, 196, 204) : color.rgb(110, 116, 124)

// ────────────────────── Baseline length ──────────────────────
float tfMin = timeframe.in_seconds(timeframe.period) / 60.0
int autoBars = timeframe.isintraday ? int(math.round(sessMin * wkDays / tfMin)) :
               timeframe.isdaily    ? wkDays : 1
int baseLen = math.min(math.max(autoLen ? autoBars : manLen, 1), 5000)

float avgVol = exclCur ? ta.sma(volume[1], baseLen) : ta.sma(volume, baseLen)
float ratio  = avgVol > 0 ? volume / avgVol : 0.0

// ───────────────────────── Tier logic ─────────────────────────
int  tier  = ratio >= m4 ? 4 : ratio >= m3 ? 3 : ratio >= m2 ? 2 : ratio >= m1 ? 1 : 0
bool upBar = close > open
bool dnBar = close < open

hitsAt(int lvl) => math.sum(tier >= lvl ? 1.0 : 0.0, winLen)
float h1 = hitsAt(1)
float h2 = hitsAt(2)
float h3 = hitsAt(3)
float h4 = hitsAt(4)

tierIdx(string s) => s == "16x" ? 4 : s == "8x" ? 3 : s == "4x" ? 2 : 1
hitsOf(int i)     => i == 4 ? h4 : i == 3 ? h3 : i == 2 ? h2 : h1

int   selTier = tierIdx(hitAt)
float hits    = hitsOf(selTier)
float upH     = math.sum(tier >= selTier and upBar ? 1.0 : 0.0, winLen)
float dnH     = math.sum(tier >= selTier and dnBar ? 1.0 : 0.0, winLen)

float refClose = nz(close[winLen], close)
float pctChg   = refClose > 0 ? (close - refClose) / refClose * 100 : 0.0

bool active = hits >= minHits
int  score  = (pctChg > 0 ? 1 : pctChg < 0 ? -1 : 0) + (upH > dnH ? 1 : upH < dnH ? -1 : 0)
bool bull   = active and score > 0
bool bear   = active and score < 0

string verdict = not active ? "QUIET" :
                 score >=  2 ? "RISING"  : score ==  1 ? "RISING?"  :
                 score <= -2 ? "FALLING" : score == -1 ? "FALLING?" : "MIXED"
string arrow = bull ? "▲" : bear ? "▼" : "•"
color  pBias = bull ? pUp : bear ? pDn : pDim

// ───────────────────── Alert conditions ─────────────────────
// Ready-made: one named condition per tier, no configuration needed.
bool rep1 = h1 >= readyHits and h1[1] < readyHits
bool rep2 = h2 >= readyHits and h2[1] < readyHits
bool rep3 = h3 >= readyHits and h3[1] < readyHits
bool rep4 = h4 >= readyHits and h4[1] < readyHits

// Custom: tier + count + direction from the settings panel.
int   alIdx = tierIdx(alTier)
float alCnt = hitsOf(alIdx)
bool  dirOK = alDir == "Any" ? true : alDir == "Rising only" ? bull : bear
bool  armed = alCnt >= alHits and dirOK
bool  fired = armed and not armed[1]
int   sinceFire = na(ta.barssince(fired)) ? -1 : ta.barssince(fired)

// Exposed for {{plot("...")}} placeholders in alert messages and the Data Window.
plot(ratio,  "Ratio",       display = display.data_window)
plot(tier,   "Tier",        display = display.data_window)
plot(alCnt,  "Custom hits", display = display.data_window)
plot(pctChg, "Window %",    display = display.data_window)
plot(h1, "Hits 2x",  display = display.data_window)
plot(h2, "Hits 4x",  display = display.data_window)
plot(h3, "Hits 8x",  display = display.data_window)
plot(h4, "Hits 16x", display = display.data_window)

alertcondition(rep1, "2x repeated in window",  'Volume: 2x reached the required number of times on {{ticker}} — ratio {{plot("Ratio")}}, window change {{plot("Window %")}}%')
alertcondition(rep2, "4x repeated in window",  'Volume: 4x reached the required number of times on {{ticker}} — ratio {{plot("Ratio")}}, window change {{plot("Window %")}}%')
alertcondition(rep3, "8x repeated in window",  'Volume: 8x reached the required number of times on {{ticker}} — ratio {{plot("Ratio")}}, window change {{plot("Window %")}}%')
alertcondition(rep4, "16x repeated in window", 'Volume: 16x reached the required number of times on {{ticker}} — ratio {{plot("Ratio")}}, window change {{plot("Window %")}}%')

alertcondition(tier >= 1 and tier[1] < 1, "Single bar 2x",  'Volume spike on {{ticker}} — {{plot("Ratio")}}x the 1-week average')
alertcondition(tier >= 2 and tier[1] < 2, "Single bar 4x",  'Volume spike on {{ticker}} — {{plot("Ratio")}}x the 1-week average')
alertcondition(tier >= 3 and tier[1] < 3, "Single bar 8x",  'Volume spike on {{ticker}} — {{plot("Ratio")}}x the 1-week average')
alertcondition(tier >= 4 and tier[1] < 4, "Single bar 16x", 'Volume spike on {{ticker}} — {{plot("Ratio")}}x the 1-week average')

alertcondition(fired, "CUSTOM repeat alert",
     'Volume repeat trigger on {{ticker}} — {{plot("Custom hits")}} hits in the window, ratio {{plot("Ratio")}}, window change {{plot("Window %")}}%')

alertcondition(bull and not bull[1], "Bias turned RISING",  "Repeated volume surges with price rising on {{ticker}}")
alertcondition(bear and not bear[1], "Bias turned FALLING", "Repeated volume surges with price falling on {{ticker}}")

if alDyn and fired
    alert(syminfo.ticker + " — " + alTier + " volume hit " + str.tostring(alCnt, "#") +
         " times within the last " + str.tostring(winLen) + " bars. Ratio now " + str.tostring(ratio, "#.0") +
         "x, price " + str.tostring(pctChg, "#.#") + "% over the window, surges " +
         str.tostring(upH, "#") + " up / " + str.tostring(dnH, "#") + " down. Bias: " + verdict,
         alert.freq_once_per_bar_close)

// ─────────────────────────── Plots ───────────────────────────
color kBar   = upBar ? kUp : dnBar ? kDn : kAvg
int   transp = tier == 4 ? 0 : tier == 3 ? 10 : tier == 2 ? 28 : tier == 1 ? 48 : (midBg ? 66 : dark ? 76 : 68)

plot(volume, "Volume", color = color.new(kBar, transp), style = plot.style_columns)
plot(avgVol, "1-week average", color = color.new(kAvg, 25), linewidth = 1)
plot(avgVol * m1, "Tier 1 level", color = showLvl ? color.new(kT1, 48) : na)
plot(avgVol * m2, "Tier 2 level", color = showLvl ? color.new(kT2, 40) : na)
plot(avgVol * m3, "Tier 3 level", color = showLvl ? color.new(kT3, 30) : na)
plot(avgVol * m4, "Tier 4 level", color = showLvl ? color.new(kT4, 20) : na)

plotshape(showMrk and tier == 3, "8x bar", style = shape.triangleup, location = location.top,
     color = kT3, size = size.tiny)
plotshape(showMrk and tier == 4, "16x bar", style = shape.diamond, location = location.top,
     color = kT4, size = size.small)
plotshape(showFire and fired, "Custom alert fired", style = shape.flag, location = location.bottom,
     color = bull ? kUp : bear ? kDn : kT2, size = size.tiny, text = "!")

// ─────────────────────────── Table ───────────────────────────
var table t = table.new(
     tPos == "Top Left"     ? position.top_left :
     tPos == "Bottom Right" ? position.bottom_right :
     tPos == "Bottom Left"  ? position.bottom_left :
     tPos == "Middle Right" ? position.middle_right : position.top_right,
     3, 10, border_width = 1, border_color = pGrid, bgcolor = color.new(pPanel, panelOp))

string sz = tSize == "Tiny" ? size.tiny : tSize == "Normal" ? size.normal : tSize == "Large" ? size.large : size.small
color  cellBg = color.new(pPanel, panelOp)
color  altBg  = color.new(pRow, panelOp)

tierRow(int row, float mult, int lvl, float cnt, color accent) =>
    bool on   = tier >= lvl
    string mx = str.tostring(mult, "#.#") + "x"
    string tipL = mx + " tier — a bar trading at least " + mx + " the 1-week average (" + fmtVol(avgVol) + "), i.e. " + fmtVol(avgVol * mult) + " or more."
    string tipN = on ? "This bar IS at " + mx + " or higher. Current ratio " + str.tostring(ratio, "#.0") + "x." :
                       "This bar is below " + mx + ". Current ratio " + str.tostring(ratio, "#.0") + "x."
    string tipC = str.tostring(cnt, "#") + " of the last " + str.tostring(winLen) + " bars reached " + mx + " or higher. Turns colored at your minimum of " + str.tostring(minHits) + " — the difference between one isolated spike and a real pattern."
    table.cell(t, 0, row, mx, text_color = accent, text_size = sz, text_halign = text.align_left,
         bgcolor = cellBg, tooltip = tipL)
    table.cell(t, 1, row, on ? "HIT" : "–", text_color = on ? chipTx : pIdle,
         bgcolor = on ? accent : altBg, text_size = sz, tooltip = tipN)
    table.cell(t, 2, row, str.tostring(cnt, "#"), text_color = cnt >= minHits ? chipTx : pIdle,
         bgcolor = cnt >= minHits ? pBias : altBg, text_size = sz, tooltip = tipC)

if barstate.islast
    string tipHead = "VOLUME MULTIPLES — each bar's volume divided by the average of the last trading week (" + str.tostring(baseLen) + " bars = " + fmtVol(avgVol) + "). Rows are the tiers, NOW is this bar, the right column counts hits in the last " + str.tostring(winLen) + " bars. Hover any cell for detail."
    table.cell(t, 0, 0, "VOL vs 1W", text_color = pText, text_size = sz, text_halign = text.align_left, bgcolor = altBg, tooltip = tipHead)
    table.cell(t, 1, 0, "NOW", text_color = pText, text_size = sz, bgcolor = altBg,
         tooltip = "Whether the CURRENT bar reaches each tier. Tiers are cumulative, so a 9x bar shows HIT on 2x, 4x and 8x.")
    table.cell(t, 2, 0, "×" + str.tostring(winLen), text_color = pText, text_size = sz, bgcolor = altBg,
         tooltip = "Hit count over the rolling window of the last " + str.tostring(winLen) + " bars.")

    tierRow(1, m1, 1, h1, pT1)
    tierRow(2, m2, 2, h2, pT2)
    tierRow(3, m3, 3, h3, pT3)
    tierRow(4, m4, 4, h4, pT4)

    color ratioChip = tier == 4 ? pT4 : tier == 3 ? pT3 : tier == 2 ? pT2 : tier == 1 ? pT1 : altBg
    table.cell(t, 0, 5, "Ratio", text_color = pDim, text_size = sz, text_halign = text.align_left, bgcolor = cellBg,
         tooltip = "Exact multiple for the current bar, and the baseline it is measured against.")
    table.cell(t, 1, 5, str.tostring(ratio, "#.0") + "x", text_color = tier > 0 ? chipTx : pText,
         bgcolor = ratioChip, text_size = sz,
         tooltip = "This bar traded " + fmtVol(volume) + ", which is " + str.tostring(ratio, "#.00") + " times the 1-week average. The chip takes the color of the tier it has reached.")
    table.cell(t, 2, 5, fmtVol(avgVol), text_color = pDim, text_size = sz, bgcolor = cellBg,
         tooltip = "1-week average volume: mean of the last " + str.tostring(baseLen) + " bars" + (exclCur ? ", excluding the current bar." : ", including the current bar."))

    table.cell(t, 0, 6, "Chg " + str.tostring(winLen) + "b", text_color = pDim, text_size = sz, text_halign = text.align_left, bgcolor = cellBg,
         tooltip = "Price behaviour across the same window the hits are counted over.")
    table.cell(t, 1, 6, str.tostring(pctChg, "#.#") + "%", text_color = pctChg > 0 ? pUp : pctChg < 0 ? pDn : pDim,
         text_size = sz, bgcolor = cellBg,
         tooltip = "Close-to-close change over the last " + str.tostring(winLen) + " bars. One of the two votes behind the Bias verdict.")
    table.cell(t, 2, 6, str.tostring(upH, "#") + "↑ " + str.tostring(dnH, "#") + "↓",
         text_color = upH > dnH ? pUp : dnH > upH ? pDn : pDim, text_size = sz, bgcolor = cellBg,
         tooltip = "Of the bars reaching " + hitAt + " in this window, " + str.tostring(upH, "#") + " closed up and " + str.tostring(dnH, "#") + " closed down. Heavy volume on down closes while price rises often means selling into strength. The second vote behind Bias.")

    string tipBias = "BIAS combines two votes: price change over the window, and the up/down split of the surge bars." +
         "\n\nRISING / FALLING = both votes agree." +
         "\nRISING? / FALLING? = only one agrees." +
         "\nMIXED = the votes contradict." +
         "\nQUIET = fewer than " + str.tostring(minHits) + " hits at " + hitAt + "." +
         "\n\nNow: " + str.tostring(hits, "#") + " hits at " + hitAt + ", price " + str.tostring(pctChg, "#.#") + "%, surges " + str.tostring(upH, "#") + "↑/" + str.tostring(dnH, "#") + "↓."
    table.cell(t, 0, 7, "Bias", text_color = pText, text_size = sz, text_halign = text.align_left, bgcolor = cellBg, tooltip = tipBias)
    table.cell(t, 1, 7, verdict, text_color = active ? chipTx : pDim, text_size = sz,
         bgcolor = active ? pBias : altBg, tooltip = tipBias)
    table.cell(t, 2, 7, arrow, text_color = pBias, text_size = sz, bgcolor = cellBg, tooltip = tipBias)

    string statusTxt = fired ? "FIRED" : armed ? "ON" : str.tostring(alCnt, "#") + "/" + str.tostring(alHits)
    color  statusBg  = fired ? pT2 : armed ? pBias : altBg
    color  statusTx  = fired or armed ? chipTx : (alCnt >= alHits - 1 ? pT1 : pIdle)
    string tipAlert = "CUSTOM ALERT — configured in settings as: " + alTier + " reached " + str.tostring(alHits) +
         " times inside " + str.tostring(winLen) + " bars" + (alDir == "Any" ? "" : ", bias must be " + alDir) + "." +
         "\n\nProgress right now: " + str.tostring(alCnt, "#") + " of " + str.tostring(alHits) + " hits." +
         "\nON = condition currently true. FIRED = triggered on this bar." +
         (sinceFire >= 0 ? "\nLast fired " + str.tostring(sinceFire) + " bars ago." : "\nHas not fired on this chart yet.") +
         "\n\nTo receive it: Add alert > Condition = VolX > 'CUSTOM repeat alert', or 'Any alert() function call' for the full message."
    table.cell(t, 0, 8, "Alert", text_color = pDim, text_size = sz, text_halign = text.align_left, bgcolor = cellBg, tooltip = tipAlert)
    table.cell(t, 1, 8, alTier + " ×" + str.tostring(alHits), text_color = pText, text_size = sz, bgcolor = cellBg, tooltip = tipAlert)
    table.cell(t, 2, 8, statusTxt, text_color = statusTx, bgcolor = statusBg, text_size = sz, tooltip = tipAlert)

    if showCred
        table.cell(t, 0, 9, "sunilp303", text_color = pIdle, text_size = size.tiny,
             text_halign = text.align_left, bgcolor = altBg,
             tooltip = "Volume Surge Radar — 2x/4x/8x/16x by sunilp303. Measures participation, not direction — the bias reading is context for your own entries, not a signal.")
        table.cell(t, 1, 9, "", bgcolor = altBg)
        table.cell(t, 2, 9, "", bgcolor = altBg)
````
