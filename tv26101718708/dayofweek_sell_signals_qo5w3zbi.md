# Day-of-Week Sell Signals

- url: https://www.tradingview.com/script/QO5W3zBI-Day-of-Week-Sell-Signals/
- type: indicator
- pine_id: PUB;4a6bcf9b177a46d9a4bab21cd27886eb
- version: 1.0

## Description

[b]Day-of-Week Sell Signals — Indicator Description[/b]
This indicator monitors two day-of-week price patterns on the daily chart of indices, futures and similar assets. When a setup is recognised, a sell signal triggers at the start of the follow-up trading day, and the prior day's low is plotted as the target. The script is built for instruments whose daily session opens around 5pm and closes around 4pm New York time, with the day-of-week derived from the bar's close time so the trading day labels correctly.

[b]Condition 1[/b] — Friday → Monday. If Friday's high is lower than Thursday's high, Monday often revisits Friday's low. The signal fires at Monday's session open with Friday's low as the target.

[b]Condition 2[/b] — Wednesday → Thursday. If Wednesday's high is lower than Monday's high, Thursday often revisits Wednesday's low. The signal fires at Thursday's session open with Wednesday's low as the target.

The script includes a holiday-recency guard so missed sessions don't pollute the comparison, an invalidation toggle that suppresses signals when the new day opens at or beyond the target low, plotted target lines, optional background tinting on signal days, and three alert conditions (Pattern 1, Pattern 2, and any signal).

[b]Statistical Analysis[/b]
A three-year study using one-minute intraday data on ES, NQ, and YM during Regular Trading Hours (9:30 AM – 4:00 PM ET) measured how often the prior day's low was touched during the follow-up session.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TysonT_345

//@version=6
indicator("Day-of-Week Sell Signals", "DoW Sells", overlay=true)

// =============================================================================
// DAY-OF-WEEK SELL SIGNAL INDICATOR
// =============================================================================
// Pattern 1: If Friday's high < Thursday's high
//            → Monday often revisits Friday's low
//            → SELL signal fires on Monday, target = Friday's low
//
// Pattern 2: If Wednesday's high < Monday's high
//            → Thursday often revisits Wednesday's low
//            → SELL signal fires on Thursday, target = Wednesday's low
//
// Designed for the Daily (1D) timeframe.
// Works correctly for instruments whose daily bar opens ~5pm prev day and
// closes ~4pm (futures, forex) — see DAY OF WEEK note below.
// =============================================================================

// === INPUTS ===
grpP = "Patterns"
useP1  = input.bool(true, "Enable Pattern 1 (Fri<Thu → Sell Mon)", group=grpP)
useP2  = input.bool(true, "Enable Pattern 2 (Wed<Mon → Sell Thu)", group=grpP)
useInv = input.bool(true, "Skip signal if day opens at/below target low", group=grpP,
     tooltip="Invalidates the setup when the trading day opens beyond the target low — the move has already played out, no edge in chasing it.")

grpV = "Visuals"
showLbl = input.bool(true, "Show signal labels",      group=grpV)
showTgt = input.bool(true, "Show target low levels",  group=grpV)
tgtBars = input.int(8,    "Target line length (bars)", minval=1, maxval=100, group=grpV)
useBg   = input.bool(true, "Tint background on signal bars", group=grpV)

grpC = "Colors"
c1 = input.color(color.red,    "Pattern 1 (Monday)",   group=grpC)
c2 = input.color(color.orange, "Pattern 2 (Thursday)", group=grpC)

// === DAY OF WEEK ===
// Use the bar's CLOSE time, not its open time. For instruments whose daily
// session opens ~5pm prev day and closes ~4pm (futures, forex), the bar's
// open is on the previous calendar day, so the built-in `dayofweek` (which
// uses bar open) is shifted by one day. Using `time_close` aligns the
// day-of-week with the trading day the bar actually represents.
d = dayofweek(time_close)

// === STORE PRIOR-DAY HIGHS / LOWS ===
// `var` keeps these values alive across bars. On the daily timeframe each bar
// is one full session, so a single assignment captures that day's high/low.
var float thuHigh = na
var float friHigh = na
var float friLow  = na
var float monHigh = na
var float wedHigh = na
var float wedLow  = na

// Track when each was last updated so we can sanity-check against holidays
var int thuBar = na
var int friBar = na
var int monBar = na
var int wedBar = na

if d == dayofweek.thursday
    thuHigh := high
    thuBar  := bar_index
if d == dayofweek.friday
    friHigh := high
    friLow  := low
    friBar  := bar_index
if d == dayofweek.monday
    monHigh := high
    monBar  := bar_index
if d == dayofweek.wednesday
    wedHigh := high
    wedLow  := low
    wedBar  := bar_index

// === SIGNAL CONDITIONS ===
// Pattern 1 — Monday: last Friday's high < last Thursday's high
// Friday should be ~1 bar ago, Thursday ~2 bars ago on daily TF.
// Allow some slack for holidays.
// Invalidation: skip if Monday's open is at/below Friday's low.
p1Fresh = not na(friBar) and not na(thuBar) and (bar_index - friBar) <= 3 and (bar_index - thuBar) <= 4
sigP1   = useP1 and d == dayofweek.monday and p1Fresh and friHigh < thuHigh and (not useInv or open > friLow)

// Pattern 2 — Thursday: this-week's Wed high < this-week's Mon high
// Wednesday ~1 bar ago, Monday ~3 bars ago on daily TF.
// Invalidation: skip if Thursday's open is at/below Wednesday's low.
p2Fresh = not na(wedBar) and not na(monBar) and (bar_index - wedBar) <= 2 and (bar_index - monBar) <= 4
sigP2   = useP2 and d == dayofweek.thursday and p2Fresh and wedHigh < monHigh and (not useInv or open > wedLow)

// === PLOT SIGNAL SHAPES ===
// Pine v6 requires `text` to be a const string, so we split into two calls
// per pattern (with/without label) and toggle via the boolean condition.
plotshape(sigP1 and showLbl,     title="P1 Sell (Mon) w/ label", style=shape.triangledown, location=location.abovebar, color=c1, size=size.normal, text="SELL\nP1", textcolor=color.white)
plotshape(sigP1 and not showLbl, title="P1 Sell (Mon)",          style=shape.triangledown, location=location.abovebar, color=c1, size=size.normal)
plotshape(sigP2 and showLbl,     title="P2 Sell (Thu) w/ label", style=shape.triangledown, location=location.abovebar, color=c2, size=size.normal, text="SELL\nP2", textcolor=color.white)
plotshape(sigP2 and not showLbl, title="P2 Sell (Thu)",          style=shape.triangledown, location=location.abovebar, color=c2, size=size.normal)

// === DRAW TARGET LEVELS (line + price label) ===
if showTgt and sigP1
    line.new(bar_index, friLow, bar_index + tgtBars, friLow, color=c1, width=2, style=line.style_dashed)
    label.new(bar_index + tgtBars, friLow, "Friday Low\n" + str.tostring(friLow, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c1, 80), textcolor=c1, size=size.small)

if showTgt and sigP2
    line.new(bar_index, wedLow, bar_index + tgtBars, wedLow, color=c2, width=2, style=line.style_dashed)
    label.new(bar_index + tgtBars, wedLow, "Wed Low\n" + str.tostring(wedLow, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c2, 80), textcolor=c2, size=size.small)

// === OPTIONAL BACKGROUND TINT ===
bgcolor(useBg and sigP1 ? color.new(c1, 88) : na, title="P1 BG")
bgcolor(useBg and sigP2 ? color.new(c2, 88) : na, title="P2 BG")

// === ALERTS ===
alertcondition(sigP1, "Pattern 1 Sell (Monday)",
     "DoW Pattern 1: Friday's high was below Thursday's high. Monday sell setup — target = Friday's low.")
alertcondition(sigP2, "Pattern 2 Sell (Thursday)",
     "DoW Pattern 2: Wednesday's high was below Monday's high. Thursday sell setup — target = Wednesday's low.")
alertcondition(sigP1 or sigP2, "Any DoW Sell Signal",
     "Day-of-Week sell signal triggered.")
````
