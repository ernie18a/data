# ETFSI Trend Stack

- url: https://www.tradingview.com/script/31UAGUdN-ETFSI-Trend-Stack/
- type: indicator
- pine_id: PUB;d6f8daee467040d993002ecc96cf0189
- version: 1.0

## Description

ETFSI Trend Stack

FOR WEEKLY CHARTS. This indicator is designed and tuned for use on a weekly chart. All lengths are in bars, so on a daily or intraday chart the 20/50/100/200 settings mean something very different and the signals will not read the same way. The panel header turns orange and says 

"DESIGNED FOR WEEKLY CHARTS" if it is loaded on any other timeframe.
Trend Stack reads the trend the way many longer-term traders already look at a weekly chart: four exponential moving averages (20, 50, 100 and 200 weeks) and where price sits relative to them. It turns that picture into a small set of labels and a status panel, so you can see at a glance whether the trend is intact, whether a pullback has finished, and when the trend has actually broken.

WHERE IT WORKS BEST
Broad market indexes (SPY, QQQ, IWM) and sector or thematic ETFs that are trending. It is a trend tool: in sideways, range-bound markets it will flip between Exit and Re-entry, and no setting fully removes that. Seeing those flips is itself information: the trend is not there.

HOW IT READS THE TREND
Stack. When the 20 is above the 50, the 50 above the 100, and the 100 above the 200, the stack is fully bullish. Fully inverted is bearish. Anything else is mixed. The panel also flags when all four EMAs are rising.
Trend on / Break. The trend is switched on when the 20 crosses above the 50 (aqua diamond, "Trend on") and switched off when it crosses below (red X, "Break"). While the trend is off, no re-entry labels appear. This keeps the indicator quiet through bear markets such as 2022.

SIGNALS
Re-entry (green triangle). Two ways a re-entry is marked while the trend is on:
1.	Pullback re-entry: price pulls back to the 50 EMA (the low comes within a set % of it), then closes back above the 20 EMA within a set number of bars.
2.	Trend re-entry: price closes back above the 20 EMA while all four EMAs are sloping up.
Exit (purple label). After a re-entry or Trend on, an Exit is marked on the first weekly close more than 1 ATR (14-week Average True Range) below the 20 EMA. Measuring the buffer in ATR lets it adapt to each chart: on SPY one weekly ATR is roughly 2.5 to 3%, while on a volatile stock or ETF it widens automatically, so ordinary weekly noise does not trigger an exit. Alternative exit rules in settings: a fixed % below the 20, any close below the 20, or N closes in a row below the 20. A Break also ends the position.
Extended (optional, off by default). Marks the first bar of a run where price is more than 15% above the 50 EMA (or the 20 if you choose). Markets can stay extended for a long time, so this is information, not an exit.

PANEL
Stack state and whether all EMAs are rising; distance from the 20 and the 50; extension status; IN / OUT status with bars held and % change since the last signal; and whether a pullback setup is armed or switched off after a Break. Panel position (8 locations) and text size (Tiny to Large) are configurable.

ALERTS
Pullback re-entry, Exit, Trend break, Trend on, Over-extended.

DEFAULT SETTINGS
EMA lengths 20 / 50 / 100 / 200. Pullback touch tolerance 1%, max 8 bars from touch to re-entry, minimum 6 bars between re-entry labels, long-term filter (50 above 200). Exit: close more than 1 ATR (14) below the 20. Slope lookback 3 bars. Extension 15% above the 50 (labels off).

NOTES
Labels are drawn on confirmed (closed) weekly bars only, so they do not repaint once the bar is complete. During the live, unfinished week the panel reflects current prices and can change until the weekly close.
This is a chart-reading tool. It has not been tested as a trading system, and the labels are observations, not recommendations to buy or sell. Past behavior on any chart does not guarantee future results.
Open-source under MPL-2.0. Trade_Logic1019 / ETF Sector Intelligence.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trade_Logic1019
//@version=6
// ETFSI Trend Stack: EMA 20/50/100/200 trend state with pullback re-entries, buffered exits and trend breaks.
// Designed for weekly charts (works on any timeframe; lengths are in bars).
// Signals are visual observations, not trade recommendations.
indicator("ETFSI Trend Stack", shorttitle = "Trend Stack", overlay = true, max_labels_count = 200)

// ==========================================
// 1) INPUTS
// ==========================================
grpE = "EMAs"
len1 = input.int(20,  "Fast EMA",   minval = 1, group = grpE)
len2 = input.int(50,  "Pullback EMA", minval = 1, group = grpE)
len3 = input.int(100, "EMA 3",      minval = 1, group = grpE)
len4 = input.int(200, "EMA 4",      minval = 1, group = grpE)

grpP = "Pullback re-entry"
touchTol  = input.float(1.0, "Touch tolerance above pullback EMA %", minval = 0.0, step = 0.25, group = grpP, tooltip = "A bar 'touches' the pullback EMA when its low is at or below the EMA plus this %.")
lookback  = input.int(8, "Max bars from touch to re-entry", minval = 1, group = grpP, tooltip = "The close back above the fast EMA must come within this many bars of the touch.")
needTrend = input.bool(true, "Require long-term uptrend (pullback EMA > EMA 4)", group = grpP)
minGap    = input.int(6, "Min bars between re-entry labels", minval = 0, group = grpP)

grpS = "Exit"
showExit  = input.bool(true, "Mark exit after a re-entry / Trend on", group = grpS)
exitMode  = input.string("Close below fast EMA by ATR multiple", "Exit rule", options = ["Close below fast EMA by ATR multiple", "Close below fast EMA by X%", "Close below fast EMA", "N closes in a row below fast EMA"], group = grpS)
atrLen    = input.int(14, "ATR length (for ATR rule)", minval = 1, group = grpS)
atrMult   = input.float(1.0, "ATR multiple (for ATR rule)", minval = 0.1, step = 0.25, group = grpS, tooltip = "Exit fires on a close more than this many ATRs below the fast EMA. On SPY weekly, 1 ATR is roughly 2.5-3%; on volatile stocks it widens automatically.")
exitBuf   = input.float(3.0, "X% buffer (for 'by X%' rule)", minval = 0.1, step = 0.25, group = grpS)
exitN     = input.int(2, "N closes (for 'N closes in a row' rule)", minval = 2, group = grpS)
slopeBack = input.bool(true, "Re-enter on a close back above the fast EMA when ALL four EMAs are sloping up", group = grpS)
slopeLen  = input.int(3, "Slope lookback (bars): EMA now vs N bars ago", minval = 1, group = grpS)
quickBack = input.bool(false, "Re-enter on any close back above the fast EMA after an exit (ignores slope)", group = grpS)

grpX = "Over-extension (info only)"
showExt  = input.bool(false, "Show Extended labels", group = grpX)
extRef   = input.string("Pullback EMA", "Measure extension from", options = ["Fast EMA", "Pullback EMA"], group = grpX)
extPct   = input.float(15.0, "Over-extended when close is above it by %", minval = 0.5, step = 0.5, group = grpX)
extReset = input.bool(true, "One label per run: re-arm only after a close back at/below the fast EMA", group = grpX)
shadeX   = input.bool(false, "Shade over-extended bars", group = grpX)

grpB = "Trend break"
showBrk = input.bool(true, "Mark fast EMA crossing below pullback EMA", group = grpB)

grpD = "Display"
showTbl = input.bool(true, "Show panel", group = grpD)
tblPos  = input.string("Top Right", "Panel position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = grpD)
tblSize = input.string("Small", "Panel text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpD)

// ==========================================
// 2) EMAS AND STATE
// ==========================================
e1 = ta.ema(close, len1)
e2 = ta.ema(close, len2)
e3 = ta.ema(close, len3)
e4 = ta.ema(close, len4)

plot(e1, "Fast EMA",     color = color.white,               linewidth = 1)
plot(e2, "Pullback EMA", color = color.orange,              linewidth = 2)
plot(e3, "EMA 3",        color = color.aqua,                linewidth = 1)
plot(e4, "EMA 4",        color = color.new(color.blue, 0),  linewidth = 3)

bool stackBull = e1 > e2 and e2 > e3 and e3 > e4
bool stackBear = e1 < e2 and e2 < e3 and e3 < e4

// Trend state: switched OFF when the fast EMA crosses below the pullback EMA (Break),
// switched back ON when it crosses back above (Trend on). Re-entries only count while ON.
bool crossUp = ta.crossover(e1, e2)
bool crossDn = ta.crossunder(e1, e2)
var bool trendOn = true
if bar_index == 0
    trendOn := e1 >= e2
if crossDn
    trendOn := false
if crossUp
    trendOn := true
bool uptrend = trendOn and (not needTrend or e2 > e4)

// Pullback touch arms a re-entry; a close back above the fast EMA within the lookback fires it
bool touch = low <= e2 * (1 + touchTol / 100.0)
var int touchBar = na
var bool armed = false
if touch and uptrend
    touchBar := bar_index
    armed := true
if armed and not na(touchBar) and bar_index - touchBar > lookback
    armed := false

// Position state (for labels only): ON after a re-entry or Trend on, OFF after an exit or Break
var bool inPos = false
var int lastEntryBar = na
var float lastEntryPx = na
var int lastExitBar = na
var float lastExitPx = na
bool gapOk = na(lastEntryBar) or bar_index - lastEntryBar >= minGap
bool crossAbove1 = close > e1 and close[1] <= e1[1]
bool pullbackEntry = armed and uptrend and gapOk and crossAbove1
bool allUp = e1 > e1[slopeLen] and e2 > e2[slopeLen] and e3 > e3[slopeLen] and e4 > e4[slopeLen]
bool slopeEntry = slopeBack and uptrend and allUp and crossAbove1
bool quickEntry = slopeEntry or (quickBack and uptrend and not na(lastExitBar) and crossAbove1)
bool reentry = barstate.isconfirmed and not inPos and (pullbackEntry or quickEntry)
if reentry
    armed := false
    inPos := true
    lastEntryBar := bar_index
    lastEntryPx := close

// Trend on also starts a position when price is already above the fast EMA
bool trendOnEntry = barstate.isconfirmed and crossUp and not inPos and close > e1
if trendOnEntry
    inPos := true
    lastEntryBar := bar_index
    lastEntryPx := close

// Exit: first close below the fast EMA while in a position; a Break also closes it
var int belowRun = 0
if barstate.isconfirmed
    belowRun := close < e1 ? belowRun + 1 : 0
float atrV = ta.atr(atrLen)
bool exitRule = exitMode == "Close below fast EMA by ATR multiple" ? close < e1 - atrMult * atrV : exitMode == "Close below fast EMA" ? close < e1 : exitMode == "Close below fast EMA by X%" ? close < e1 * (1 - exitBuf / 100.0) : belowRun >= exitN
bool exitSig = barstate.isconfirmed and showExit and inPos and exitRule and not reentry and not trendOnEntry
if barstate.isconfirmed and inPos and (exitRule or crossDn) and not reentry and not trendOnEntry
    inPos := false
    lastExitBar := bar_index
    lastExitPx := close

// Over-extension: fires on the first bar that crosses into the zone
float refLine = extRef == "Fast EMA" ? e1 : e2
float extNow  = (close / refLine - 1) * 100.0
bool extended = extNow >= extPct
var bool extArmed = true
bool extStart = false
if barstate.isconfirmed
    if extended and not extended[1] and (extArmed or not extReset)
        extStart := true
        extArmed := false
    if close <= e1
        extArmed := true

// Trend break
bool brk = barstate.isconfirmed and showBrk and crossDn
bool restored = barstate.isconfirmed and showBrk and crossUp

// ==========================================
// 3) SIGNALS ON CHART
// ==========================================
plotshape(reentry,  "Pullback re-entry", shape.triangleup,   location.belowbar, color.lime,   size = size.small, text = "Re-entry", textcolor = color.lime)
plotshape(showExt and extStart, "Over-extended", shape.triangledown, location.abovebar, color.orange, size = size.small, text = "Extended", textcolor = color.orange)
plotshape(exitSig,  "Exit",              shape.labeldown,    location.abovebar, color.new(color.fuchsia, 0), size = size.tiny, text = "Exit", textcolor = color.white)
plotshape(brk,      "Trend break",       shape.xcross,       location.abovebar, color.red,    size = size.small, text = "Break",    textcolor = color.red)
plotshape(restored, "Trend on",          shape.diamond,      location.belowbar, color.aqua,   size = size.small, text = "Trend on", textcolor = color.aqua)
bgcolor(shadeX and extended ? color.new(color.orange, 88) : na, title = "Over-extended zone")

alertcondition(reentry,  "Pullback re-entry", "Trend Stack: pullback re-entry (close back above fast EMA after touching pullback EMA)")
alertcondition(extStart, "Over-extended",     "Trend Stack: close is over-extended above the reference EMA")
alertcondition(brk,      "Trend break",       "Trend Stack: fast EMA crossed below pullback EMA")
alertcondition(exitSig,  "Exit",              "Trend Stack: weekly close below the fast EMA (exit)")
alertcondition(restored, "Trend on",          "Trend Stack: fast EMA crossed back above pullback EMA (re-entries active again)")

// ==========================================
// 4) PANEL
// ==========================================
f_pos(p) =>
    p == "Top Left" ? position.top_left : p == "Top Center" ? position.top_center : p == "Middle Right" ? position.middle_right : p == "Middle Left" ? position.middle_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Center" ? position.bottom_center : p == "Bottom Left" ? position.bottom_left : position.top_right

f_size(s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

f_pct(v) =>
    na(v) ? "n/a" : (v >= 0 ? "+" : "") + str.tostring(v, "0.0") + "%"

if showTbl and barstate.islast
    var table t = na
    table.delete(t)
    t := table.new(f_pos(tblPos), 2, 7, bgcolor = color.new(#131722, 0), border_width = 1, border_color = color.new(color.gray, 60), frame_color = color.gray, frame_width = 1)
    hdr = color.new(#2a2e39, 0)
    row = color.new(#1e222d, 0)
    stackTxt = stackBull ? "Bullish (20>50>100>200)" : stackBear ? "Bearish (20<50<100<200)" : "Mixed"
    stackBg  = stackBull ? color.new(color.green, 0) : stackBear ? color.new(color.red, 0) : color.new(color.gray, 0)
    d1 = (close / e1 - 1) * 100.0
    d2 = (close / e2 - 1) * 100.0
    sinceTxt = inPos ? "IN since " + str.tostring(bar_index - lastEntryBar) + " bars (" + f_pct((close / lastEntryPx - 1) * 100.0) + ")" : na(lastExitBar) ? "OUT" : "OUT since exit " + str.tostring(bar_index - lastExitBar) + " bars ago (" + f_pct((close / lastExitPx - 1) * 100.0) + " since)"

    table.cell(t, 0, 0, "TREND STACK  " + syminfo.ticker + " " + timeframe.period + (timeframe.isweekly ? "" : "  (DESIGNED FOR WEEKLY CHARTS)"), text_color = timeframe.isweekly ? color.white : color.orange, bgcolor = hdr, text_size = f_size(tblSize), text_halign = text.align_left)
    table.merge_cells(t, 0, 0, 1, 0)
    table.cell(t, 0, 1, "Stack", text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 1, 1, stackTxt + (allUp ? " · all rising" : ""), text_color = color.black, bgcolor = stackBg, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 0, 2, "vs fast EMA", text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 1, 2, f_pct(d1), text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 0, 3, "vs pullback EMA", text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 1, 3, f_pct(d2), text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 0, 4, "Extension", text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 1, 4, extended ? "EXTENDED (" + f_pct(extNow) + " vs " + str.tostring(extPct, "0.0") + "% limit)" : "Normal (" + f_pct(extNow) + ")", text_color = extended ? color.black : color.white, bgcolor = extended ? color.orange : row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 0, 5, "Status", text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 1, 5, sinceTxt, text_color = color.black, bgcolor = inPos ? color.new(color.lime, 0) : color.new(color.gray, 0), text_size = f_size(tblSize), text_halign = text.align_left)
    table.cell(t, 0, 6, "Pullback setup", text_color = color.white, bgcolor = row, text_size = f_size(tblSize), text_halign = text.align_left)
    setupTxt = not trendOn ? "OFF since Break: waiting for fast EMA back above pullback EMA" : armed ? "ARMED: touched pullback EMA, waiting for close above fast EMA" : "Not armed"
    setupBg  = not trendOn ? color.new(color.red, 0) : armed ? color.yellow : row
    table.cell(t, 1, 6, setupTxt, text_color = (not trendOn or armed) ? color.black : color.white, bgcolor = setupBg, text_size = f_size(tblSize), text_halign = text.align_left)
````
