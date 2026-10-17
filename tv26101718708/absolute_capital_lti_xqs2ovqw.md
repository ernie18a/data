# Absolute Capital LTI

- url: https://www.tradingview.com/script/xqs2ovqw-Absolute-Capital-LTI/
- type: indicator
- pine_id: PUB;5d50214239a148ea847ca77f8deaf551
- version: 2.0

## Description

⚡ Absolute Capital — Long Term Investment (AC·LTI)

A systematic, long-only Bitcoin allocation rule on the 2-day chart. No discretion. Three states, checked once a day.

LONG: EMA 12 above EMA 21 and price closes above EMA 50. Hold BTC. CAUTION: EMA 12 above EMA 21 but price below EMA 50. Be out, cash ready to re-enter. CASH: EMA 12 below EMA 21. Be out.

Every state change is labelled on the confirmed bar and fires an alert, so nothing repaints.

Backtest, BTC/USD (Coinbase), 2-day bars, 24 Aug 2016 to 25 Sep 2026, 0.15% cost per buy and per sell, long only, no leverage: 72.8% a year against 63.8% for holding. Worst fall from a peak -50% against -84%. 39 closed trades, 41% winners, average winner +67%, average loser -4.8%. Ahead of holding in both halves of the period and in 95% of rolling 4-year windows.

The edge depends on acting on time: acting 2 days after a state change still returned 71.5% a year; acting 4 days late at 0.5% cost returned 61.5%, below holding.

Built for BTC on the 2D timeframe. The EMA lengths and the 2-day chart were chosen on this same history, so the backtest is flattered. Past performance does not predict future results. Education, not financial advice.

## Source Code

````pine
//@version=6
// AC-LTI ¬∑ Absolute Capital Long Term Investment
// Original implementation, 4 Oct 2026. No third-party code.
// THE ONE RULE, identical to the daily #spot-bags post (ac-cron lti_state.py) and the backtest
// (absolute-capital tools/lti-ema-backtest, tools/strategy-shootout):
//   LONG    = EMA 12 above EMA 21 AND close above EMA 50     -> hold BTC
//   CASH    = EMA 12 below EMA 21                            -> out
//   CAUTION = anything else (12 over 21, close under the 50) -> out, cash ready to re-enter (ruled 26 Sep 2026)
// Built for the 2D chart on BTC. Replaces the April 2026 AC¬∑LTS logic (cross-only entry with a grace window, exit on the
// 12/21 cross-under, CAUTION held), which lost to buy-and-hold over 2016-2026 (60.8% vs 63.8% a year).
indicator("Absolute Capital - Long Term Investment (AC¬∑LTI)", shorttitle="AC¬∑LTI", overlay=true, max_labels_count=500)

// ‚îÄ‚îÄ‚îÄ Inputs ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
len12 = input.int(12, minval=1, title="EMA 12", group="Lengths")
len21 = input.int(21, minval=1, title="EMA 21", group="Lengths")
len50 = input.int(50, minval=1, title="EMA 50", group="Lengths")

// Look and colours (7 Oct 2026, Clint: "change the look and colours of the AC-LTI too, just like the AC Bias").
// Every visual is an input; THE RULE below is untouched.
colLong    = input.color(#00C4A7, title="LONG",    group="Colours", inline="st")
colCaution = input.color(#C9C9C9, title="CAUTION", group="Colours", inline="st")
colCash    = input.color(#888888, title="CASH",    group="Colours", inline="st")
col50      = input.color(#FFFFFF, title="EMA 50",  group="Colours", inline="e50")
tr50       = input.int(50, title="transparency", group="Colours", inline="e50", minval=0, maxval=100)
lblText    = input.color(#000000, title="Label text", group="Colours")

w12        = input.int(2, title="EMA 12 width", group="Lines", inline="w", minval=1, maxval=6)
w21        = input.int(2, title="EMA 21 width", group="Lines", inline="w", minval=1, maxval=6)
w50        = input.int(1, title="EMA 50 width", group="Lines", inline="w", minval=1, maxval=6)
tr12       = input.int(0,  title="EMA 12 transparency", group="Lines", minval=0, maxval=100)
tr21       = input.int(40, title="EMA 21 transparency", group="Lines", minval=0, maxval=100)
show50     = input.bool(true, title="Show EMA 50", group="Lines")

showFill   = input.bool(true, title="Show 12/21 fill", group="Display", inline="f")
fillTr     = input.int(82, title="transparency", group="Display", inline="f", minval=0, maxval=100)
showBars   = input.bool(true, title="Colour the bars by state", group="Display")
showLabels = input.bool(true, title="Label every state change",  group="Display")
lblSize    = input.string("normal", title="Label size", options=["tiny", "small", "normal", "large"], group="Display")

showTable  = input.bool(true, title="Show the state table", group="Table")
tblPos     = input.string("top_right", title="Position", options=["top_right", "top_left", "bottom_right", "bottom_left", "middle_right"], group="Table")
tblSize    = input.string("normal", title="Text size", options=["tiny", "small", "normal", "large"], group="Table")
tblAccent  = input.color(#00C4A7, title="Accent", group="Table", inline="tc")
tblBg      = input.color(#0A0A0A, title="Background", group="Table", inline="tc")
tblText    = input.color(#FFFFFF, title="Text", group="Table", inline="tc")

sizeOf(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal
posOf(s)  => s == "top_left" ? position.top_left : s == "bottom_right" ? position.bottom_right : s == "bottom_left" ? position.bottom_left : s == "middle_right" ? position.middle_right : position.top_right

// ‚îÄ‚îÄ‚îÄ The rule ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
e12 = ta.ema(close, len12)
e21 = ta.ema(close, len21)
e50 = ta.ema(close, len50)

// 2 = LONG, 1 = CAUTION, 0 = CASH
state = e12 > e21 and close > e50 ? 2 : e12 < e21 ? 0 : 1
stateCol  = state == 2 ? colLong : state == 1 ? colCaution : colCash
stateText = state == 2 ? "LONG" : state == 1 ? "CAUTION" : "CASH"
changed   = barstate.isconfirmed and state != state[1]

// ‚îÄ‚îÄ‚îÄ Plots ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
p12 = plot(e12, "EMA 12", color.new(stateCol, tr12), w12)
p21 = plot(e21, "EMA 21", color.new(stateCol, tr21), w21)
plot(show50 ? e50 : na, "EMA 50", color.new(col50, tr50), w50)
fill(p12, p21, showFill ? color.new(stateCol, fillTr) : na, title="12/21 fill")
barcolor(showBars ? stateCol : na)

// ‚îÄ‚îÄ‚îÄ State-change labels (confirmed bars only, so they never repaint) ‚îÄ‚îÄ
atr = ta.atr(14)
if showLabels and changed
    if state == 2
        label.new(bar_index, low - atr * 0.8, "LONG", style=label.style_label_up, color=colLong, textcolor=lblText, size=sizeOf(lblSize))
    else
        label.new(bar_index, high + atr * 0.8, state == 1 ? "CAUTION" : "CASH", style=label.style_label_down, color=stateCol, textcolor=lblText, size=sizeOf(lblSize))

// ‚îÄ‚îÄ‚îÄ State table ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
var table t = table.new(posOf(tblPos), 2, 3, bgcolor=color.new(tblBg, 5), border_color=color.new(tblAccent, 50), border_width=1, frame_color=color.new(tblAccent, 30), frame_width=1)
if showTable and barstate.islast
    table.cell(t, 0, 0, "ABSOLUTE CAPITAL", text_color=tblAccent, text_size=sizeOf(tblSize))
    table.cell(t, 1, 0, "AC¬∑LTI", text_color=tblAccent, text_size=sizeOf(tblSize))
    table.cell(t, 0, 1, "State", text_color=tblText, text_size=sizeOf(tblSize))
    table.cell(t, 1, 1, stateText, text_color=stateCol, text_size=sizeOf(tblSize))
    table.cell(t, 0, 2, "Timeframe", text_color=tblText, text_size=sizeOf(tblSize))
    table.cell(t, 1, 2, timeframe.period == "2D" ? "2 Day" : timeframe.period, text_color=timeframe.period == "2D" ? tblText : #FF4D4D, text_size=sizeOf(tblSize))

// ‚îÄ‚îÄ‚îÄ Alerts (fire once, on the confirmed bar) ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
alertcondition(changed and state == 2, "AC¬∑LTI LONG",    "AC¬∑LTI: LONG. EMA 12 over 21 and price over the 50.")
alertcondition(changed and state == 1, "AC¬∑LTI CAUTION", "AC¬∑LTI: CAUTION. Out, cash ready to re-enter.")
alertcondition(changed and state == 0, "AC¬∑LTI CASH",    "AC¬∑LTI: CASH. EMA 12 under 21.")
alertcondition(changed, "AC¬∑LTI any state change", "AC¬∑LTI state changed.")
````
