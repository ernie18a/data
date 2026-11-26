# Reballo Hindenburg Omen - Breadth Gate

- url: https://www.tradingview.com/script/kvL8UtoT-Reballo-Hindenburg-Omen-Breadth-Gate/
- type: indicator
- pine_id: PUB;73ff21aedd5c4cf1a8535fc2d616f6e5
- version: 1.0

## Description

[b]What it is[/b]

The classic four-condition Hindenburg Omen, computed live from NYSE internals, held active for a set number of bars after it fires, plus a weekly breadth-oversold override. The output is a simple three-state [b]risk gate[/b]:

[list]
[*][b]Red[/b] — Omen active. Internals are split and weakening under a still-rising index. Freeze new risk.
[*][b]Green[/b] — Breadth washed out. Fewer than 30% of S&P 500 stocks above their 200-day. Historically a bad time to be [i]cutting[/i] risk.
[*][b]Nothing[/b] — Clear. Most of the time.
[/list]

This is not a crash predictor. The Omen's track record as a standalone signal is genuinely mixed, and anyone who tells you otherwise is selling something. What it [i]is[/i] good at: catching the specific moment when a market is making new highs while a growing number of stocks are quietly breaking down. That's worth knowing, and worth being able to verify line by line.

[b]The four conditions[/b]

All computed daily from NYSE data, all shown in the table so you can see which ones are holding:

[list]
[*][b]1. Split market:[/b] new 52-week highs AND new 52-week lows both >= 2.2% of issues traded. The core of the Omen. A healthy market doesn't do both at once.
[*][b]2. Still in an uptrend:[/b] NYSE Composite higher than 50 bars ago. The Omen is about divergence, so it only fires while the index is still up.
[*][b]3. Internals weakening:[/b] McClellan Oscillator below zero (19/39 EMA on ratio-adjusted net advances).
[*][b]4. Highs not dominating:[/b] new highs / new lows < 2.
[/list]

When all four hit on the same day, a triangle prints and the gate turns red for 30 bars. Consecutive fires just extend the window.

[b]The override[/b]

A weekly read of S5TH (percent of S&P 500 stocks above their 200-day MA). Below 30, the gate flips green and beats the Omen. The logic: once breadth is that washed out, the "split market" story is over and you're in a different regime where adding risk into weakness has worked far more often than not.

[b]The table[/b]

Top right. One row per condition with the live value, green if met, red if not. When the Omen isn't active you can still see how close it is, which is most of the value.

[b]How I use it[/b]

As a gate on position sizing, not as an entry or exit. Red = don't add. Green = the floor is probably in, don't panic-cut. It sits alongside a slow Ehlers CG and a regime score; when two or three of them agree the picture is usually right. On its own, treat it as one opinion.

Three alerts: Omen fires, Omen expires, breadth goes oversold.

[b]Data requirements (read this)[/b]

[list]
[*]Pulls USI:ADV, USI:DECL, USI:UNCH.NY, INDEX:MAHN, INDEX:MALN, NYA and S5TH. [b]Some of these are not visible on every plan.[/b] If the table shows n/a, that's a data access issue, not a script bug.
[*]All inputs come from index data, so it runs on any chart symbol. Put it on SPY, BTC, whatever you trade. It's telling you about the US market either way.
[*]US stocks only. It has nothing to say about EFA or EEM beyond the fact that US internals tend to lead.
[/list]

[b]Settings[/b]

[list]
[*][b]New Highs AND New Lows >=[/b] — 2.2% — the split-market threshold
[*][b]Index higher than N bars ago[/b] — 50 — the uptrend check
[*][b]Highs / Lows <[/b] — 2.0 — condition 4
[*][b]Keep Omen active for N bars[/b] — 30 — the hold window
[*][b]Breadth Symbol / Oversold Below[/b] — S5TH / 30 — the override
[/list]

Open source. Fork it, break it, tell me what you find.

## Source Code

````pine
// Reballo Hindenburg Omen - Breadth Gate
// Free / open-source component of the Reballo Forecast Stack
//@version=6
indicator('Reballo Hindenburg Omen - Breadth Gate', shorttitle = 'Reballo Omen', overlay = false, precision = 2)

//=============================================================================
// WHAT THIS DOES
//-----------------------------------------------------------------------------
// Classic 4-condition Hindenburg Omen on daily NYSE internals, held active for
// N bars after it fires, plus a weekly breadth-oversold override (S5TH). Output
// is a three-state risk gate:  OMEN ACTIVE (red)  /  OVERSOLD (green)  /  CLEAR.
// Works on any chart symbol; all inputs come from index data, not the chart.
//=============================================================================

//-----------------------------------------------------------------------------
// INPUTS
//-----------------------------------------------------------------------------
GRP_OM = 'Hindenburg Omen'
nlhThresh = input.float(2.2, 'New Highs AND New Lows >= % of issues', minval = 0.5, maxval = 5.0, step = 0.1, group = GRP_OM)
trendLook = input.int(50, 'Index higher than N bars ago', minval = 10, maxval = 250, group = GRP_OM)
hlRatio   = input.float(2.0, 'New Highs / New Lows < x', minval = 1.0, maxval = 5.0, step = 0.1, group = GRP_OM)
omenHold  = input.int(30, 'Keep Omen active for N bars', minval = 1, maxval = 120, group = GRP_OM)

GRP_BR = 'Breadth Oversold Override'
brSym   = input.symbol('S5TH', 'Breadth Symbol (weekly)', group = GRP_BR, tooltip = 'S5TH = % of S&P 500 stocks above their 200-day MA')
brLevel = input.int(30, 'Oversold Below', minval = 5, maxval = 50, group = GRP_BR)

GRP_UI = 'Display'
showTable = input.bool(true, 'Show Condition Table', group = GRP_UI)
showBg    = input.bool(true, 'Shade Gate State', group = GRP_UI)

//-----------------------------------------------------------------------------
// DAILY NYSE INTERNALS
//-----------------------------------------------------------------------------
adv  = request.security('USI:ADV',     'D', close, barmerge.gaps_off, barmerge.lookahead_off)
dec  = request.security('USI:DECL',    'D', close, barmerge.gaps_off, barmerge.lookahead_off)
unc  = request.security('USI:UNCH.NY', 'D', close, barmerge.gaps_off, barmerge.lookahead_off)
newH = request.security('INDEX:MAHN',  'D', close, barmerge.gaps_off, barmerge.lookahead_off)
newL = request.security('INDEX:MALN',  'D', close, barmerge.gaps_off, barmerge.lookahead_off)
nya  = request.security('NYA',         'D', close, barmerge.gaps_off, barmerge.lookahead_off)

totalIssues = adv + dec + unc
pctNewH     = totalIssues > 0 ? newH / totalIssues * 100.0 : na
pctNewL     = totalIssues > 0 ? newL / totalIssues * 100.0 : na

// McClellan Oscillator on ratio-adjusted net advances
ranaNet = adv + dec > 0 ? 1000.0 * (adv - dec) / (adv + dec) : 0.0
mcc     = ta.ema(ranaNet, 19) - ta.ema(ranaNet, 39)

//-----------------------------------------------------------------------------
// THE FOUR CONDITIONS
//-----------------------------------------------------------------------------
c1 = pctNewH >= nlhThresh and pctNewL >= nlhThresh     // split market: lots of new highs AND new lows
c2 = nya >= nya[trendLook]                              // in an uptrend, not already broken
c3 = mcc < 0                                            // internals weakening
c4 = newL > 0 ? newH / newL < hlRatio : false           // new highs not dominating

omenFire   = c1 and c2 and c3 and c4
barsSince  = ta.barssince(omenFire)
omenActive = not na(barsSince) and barsSince <= omenHold

//-----------------------------------------------------------------------------
// WEEKLY BREADTH OVERSOLD OVERRIDE
//-----------------------------------------------------------------------------
brWeekly   = request.security(brSym, 'W', close, barmerge.gaps_off, barmerge.lookahead_off)
brOversold = brWeekly < brLevel

//-----------------------------------------------------------------------------
// GATE STATE
//   0 = clear, 1 = omen active (freeze adds), 2 = oversold (override, allow longs)
//-----------------------------------------------------------------------------
gateState = brOversold ? 2 : omenActive ? 1 : 0

//-----------------------------------------------------------------------------
// PLOTS
//-----------------------------------------------------------------------------
cRed   = color.rgb(242, 54, 69)
cGreen = color.rgb(8, 153, 129)
cGrey  = color.rgb(150, 150, 150)

plot(mcc, 'McClellan Oscillator', color = mcc >= 0 ? color.new(cGreen, 30) : color.new(cRed, 30), style = plot.style_columns)
plot(brWeekly, 'Breadth % (weekly)', color = color.new(cGrey, 0), linewidth = 1)
hline(brLevel, 'Oversold Level', color = color.new(cGreen, 50), linestyle = hline.style_dotted)
hline(0, 'Zero', color = cGrey, linestyle = hline.style_dashed)

plotshape(omenFire, 'Omen Fires', style = shape.triangledown, location = location.top, color = cRed, size = size.small)
plot(gateState, 'Gate State (0/1/2)', display = display.data_window)
plot(pctNewH,   'New Highs %',         display = display.data_window)
plot(pctNewL,   'New Lows %',          display = display.data_window)

bgcolor(showBg ? (gateState == 2 ? color.new(cGreen, 88) : gateState == 1 ? color.new(cRed, 88) : na) : na, title = 'Gate Shading')

//-----------------------------------------------------------------------------
// CONDITION TABLE
//-----------------------------------------------------------------------------
var tbl = table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 80), border_width = 1, border_color = color.new(cGrey, 70))

f_cell(int row, string label, bool ok, string val) =>
    table.cell(tbl, 0, row, label, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, row, val, text_color = ok ? cGreen : cRed, text_size = size.small, bgcolor = color.new(ok ? cGreen : cRed, 85))

if showTable and barstate.islast
    table.cell(tbl, 0, 0, 'Hindenburg Omen', text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, 0, omenActive ? 'ACTIVE' : 'clear', text_color = color.white, text_size = size.small, bgcolor = omenActive ? cRed : color.new(cGrey, 60))
    f_cell(1, 'New H & L >= ' + str.tostring(nlhThresh) + '%', c1, str.tostring(pctNewH, '0.0') + ' / ' + str.tostring(pctNewL, '0.0'))
    f_cell(2, 'NYA > ' + str.tostring(trendLook) + ' bars ago', c2, c2 ? 'yes' : 'no')
    f_cell(3, 'McClellan < 0', c3, str.tostring(mcc, '0'))
    f_cell(4, 'Highs / Lows < ' + str.tostring(hlRatio), c4, newL > 0 ? str.tostring(newH / newL, '0.0') : 'n/a')
    f_cell(5, 'Breadth oversold < ' + str.tostring(brLevel), brOversold, str.tostring(brWeekly, '0'))

//-----------------------------------------------------------------------------
// ALERTS
//-----------------------------------------------------------------------------
alertcondition(omenFire,                          'Omen Fires',           'Hindenburg Omen: all four conditions met')
alertcondition(not omenActive and omenActive[1],  'Omen Expires',         'Hindenburg Omen: hold window ended')
alertcondition(brOversold and not brOversold[1],  'Breadth Oversold',     'Breadth: weekly % above 200MA dropped below threshold')
````
