# The Fortune Teller PRO

- url: https://www.tradingview.com/script/woqZu1g8-The-Fortune-Teller-PRO/
- type: indicator
- pine_id: PUB;c43bb5efcc05466986c9346e682f7ee7
- version: 1.0

## Description

DASHBOARD tells you about the trend very useful indicator

## Source Code

````pine
//@version=5
indicator("The Fortune Teller PRO", overlay=true, max_labels_count=50)

// =====================
// INPUTS
// =====================
emaFastLen = input.int(50, title="Fast EMA")
emaSlowLen = input.int(200, title="Slow EMA")
volLen     = input.int(20, title="Volume MA")

// =====================
// EMA TREND
// =====================
ema50  = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

plot(ema50,  color=color.blue, linewidth=2, title="EMA 50")
plot(ema200, color=color.red,  linewidth=2, title="EMA 200")

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

// =====================
// VWAP & VOLUME
// =====================
vwapLine = ta.vwap(close)
aboveVWAP = close > vwapLine
belowVWAP = close < vwapLine

volMA = ta.sma(volume, volLen)
strongVolume = volume > volMA

// =====================
// SPACEMAN BTC KEY LEVELS (CLEAN LINES)
// =====================
dOpen = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
pwh   = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl   = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_on)
pmh   = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml   = request.security(syminfo.tickerid, "M", low[1], lookahead=barmerge.lookahead_on)

// Monday High & Low Logic
var float monH = na
var float monL = na
isMon = dayofweek == dayofweek.monday

monH := isMon and not isMon[1] ? high : isMon ? math.max(nz(monH, high), high) : monH
monL := isMon and not isMon[1] ? low  : isMon ? math.min(nz(monL, low), low)   : monL

// Plotting the thin, clean step lines
plot(dOpen, color=color.new(color.aqua, 20),   title="Daily Open", style=plot.style_stepline, linewidth=1)
plot(monH,  color=color.new(color.silver, 20), title="Monday High", style=plot.style_stepline, linewidth=1)
plot(monL,  color=color.new(color.silver, 20), title="Monday Low", style=plot.style_stepline, linewidth=1)
plot(pwh,   color=color.new(color.yellow, 20), title="Prev Week High", style=plot.style_stepline, linewidth=1)
plot(pwl,   color=color.new(color.yellow, 20), title="Prev Week Low", style=plot.style_stepline, linewidth=1)
plot(pmh,   color=color.new(color.green, 20),  title="Prev Month High", style=plot.style_stepline, linewidth=1)
plot(pml,   color=color.new(color.red, 20),    title="Prev Month Low", style=plot.style_stepline, linewidth=1)

// Floating Text Labels on the right side of the chart
var lbl_dOpen = label.new(na, na, "Daily Open", style=label.style_none, textcolor=color.aqua, size=size.normal)
var lbl_monH  = label.new(na, na, "Monday High", style=label.style_none, textcolor=color.silver, size=size.normal)
var lbl_monL  = label.new(na, na, "Monday Low", style=label.style_none, textcolor=color.silver, size=size.normal)
var lbl_pwh   = label.new(na, na, "Prev Week High", style=label.style_none, textcolor=color.yellow, size=size.normal)
var lbl_pwl   = label.new(na, na, "Prev Week Low", style=label.style_none, textcolor=color.yellow, size=size.normal)

if barstate.islast
    label.set_xy(lbl_dOpen, bar_index + 3, dOpen)
    label.set_xy(lbl_monH,  bar_index + 3, monH)
    label.set_xy(lbl_monL,  bar_index + 3, monL)
    label.set_xy(lbl_pwh,   bar_index + 3, pwh)
    label.set_xy(lbl_pwl,   bar_index + 3, pwl)

// =====================
// 4AM ORB LOGIC
// =====================
var float orbHigh = na
var float orbLow  = na
newDay = ta.change(time("D"))

orbHigh := newDay ? high : math.max(nz(orbHigh, high), high)
orbLow  := newDay ? low  : math.min(nz(orbLow, low), low)

// =====================
// SIGNALS: CALLS & PUTS
// =====================
// Trigger exactly when crossing the ORB *OR* bouncing off the 50 EMA with volume
buySignal  = (ta.crossover(close, orbHigh) or ta.crossover(close, ema50)) and bullTrend and strongVolume
sellSignal = (ta.crossunder(close, orbLow) or ta.crossunder(close, ema50)) and bearTrend and strongVolume

plotshape(buySignal,  title="CALLS", style=shape.labelup,   location=location.belowbar, color=color.lime, text="CALLS", textcolor=color.black, size=size.small)
plotshape(sellSignal, title="PUTS",  style=shape.labeldown, location=location.abovebar, color=color.red,  text="PUTS",  textcolor=color.white, size=size.small)

// =====================
// CONFIDENCE DASHBOARD
// =====================
htfEMA50  = request.security(syminfo.tickerid, "60", ta.ema(close, 50))
htfEMA200 = request.security(syminfo.tickerid, "60", ta.ema(close, 200))
htfBull   = htfEMA50 > htfEMA200

int score = (bullTrend ? 20 : 0) + (aboveVWAP ? 20 : 0) + (strongVolume ? 20 : 0) + (htfBull ? 20 : 0) + (close > orbHigh ? 20 : 0)

var table dashboard = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast
    table.cell(dashboard, 0, 0, "Trend",      bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(dashboard, 1, 0, bullTrend ? "BULL" : "BEAR", bgcolor=bullTrend ? color.lime : color.red, text_color=color.black)

    table.cell(dashboard, 0, 1, "VWAP",       bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(dashboard, 1, 1, aboveVWAP ? "ABOVE" : "BELOW", bgcolor=aboveVWAP ? color.lime : color.red, text_color=color.black)

    table.cell(dashboard, 0, 2, "Volume",     bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(dashboard, 1, 2, strongVolume ? "STRONG" : "WEAK", bgcolor=strongVolume ? color.lime : color.orange, text_color=color.black)

    table.cell(dashboard, 0, 3, "HTF (1H)",   bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(dashboard, 1, 3, htfBull ? "BULL" : "BEAR", bgcolor=htfBull ? color.lime : color.red, text_color=color.black)

    table.cell(dashboard, 0, 4, "Confidence", bgcolor=color.new(color.gray, 50), text_color=color.white)
    table.cell(dashboard, 1, 4, str.tostring(score) + "%", bgcolor=score >= 80 ? color.lime : color.orange, text_color=color.black)

// =====================
// ALERTS
// =====================
alertcondition(buySignal,  title="CALLS ALERT", message="Fortune Teller: BUY CALLS")
alertcondition(sellSignal, title="PUTS ALERT",  message="Fortune Teller: BUY PUTS")
````
