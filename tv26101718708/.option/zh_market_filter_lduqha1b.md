# ZH Market Filter

- url: https://www.tradingview.com/script/ldUqhA1B-ZH-Market-Filter/
- type: indicator
- pine_id: PUB;87405329ed924423a702c8854079c6fc
- version: 1.0

## Description

Background coloring (the core filter) paints the chart by market regime, based on Qullamaggie's MA idea. It compares a fast MA (10) and slow MA (20), and checks whether each is trending up versus 5 bars ago:
* Dark green — 10 above 20, both trending up (strongest)
* Light green — 10 above 20, only the 10 trending up (early/weakening)
* Yellow — 10 above 20, neither trending up (stalling)
* Black — anything else (downtrend or chop)
Plotted lines: the 10-MA (red) and 20-MA (black), plus three toggleable reference SMAs — 50 (blue), 100 (orange), 200 (purple).
Range-bound override lets you mark a consolidation manually. You enter four things: Range Top, Range Bottom, Start Date, and Range Color. From the start date forward, the background paints your chosen color — overriding the MA coloring — because you've called it range-bound. It ends automatically on the first candle that closes above the top or below the bottom, then reverts to the normal MA coloring for good. It's one range per start date (move the date forward to mark a new one), and it triggers on closes, not wick pokes.
Metrics table (top-right) shows two readouts, pulled exactly from your ZH indicator:
* QQQ — QQQ's daily % change
* BRD — breadth, calculated as (new highs − new lows) / new lows × 100 from ATHI.US and ATLO.US
Labels are white; values are green when positive, red when negative.
A few practical notes: it's Pine v6, the metrics need ATHI.US/ATLO.US data on your plan (they work in your ZH script, so you're set), and if you leave the range prices at 0 it simply won't paint — no more flattened chart. One thing to keep in mind on the range start date: it has to be a date that exists on the chart, not in the future, or nothing paints.

## Source Code

````pine
//@version=6

indicator(title="ZH Market Filter", shorttitle="ZH Filter", overlay=true)

yourmama = input.string("SMA", title="MA Type", options=["SMA", "EMA"], group="Moving Averages Type")

ma1_len = input.int(10, minval=1, title="First MA length")
src1    = input.source(close, title="First MA Source")
ma1     = yourmama == "SMA" ? ta.sma(src1, ma1_len) : ta.ema(src1, ma1_len)

ma2_len = input.int(20, minval=1, title="Second MA length")
src2    = input.source(close, title="Second MA Source")
ma2     = yourmama == "SMA" ? ta.sma(src2, ma2_len) : ta.ema(src2, ma2_len)

trendlen = input.int(5, minval=1, title="number of bars to determine uptrend")

ma1up = ma1 > ma1[trendlen]
ma2up = ma2 > ma2[trendlen]

green      = ma1 > ma2 and ma1up and ma2up
lightgreen = ma1 > ma2 and ma1up and not ma2up
yellow     = ma1 > ma2 and not ma1up and not ma2up

plot(ma1, color=color.red, title="First MA")
plot(ma2, color=color.black, title="Second MA")

show50  = input.bool(true, title="Show SMA 50")
show100 = input.bool(true, title="Show SMA 100")
show200 = input.bool(true, title="Show SMA 200")

col50  = input.color(color.blue,   title="SMA 50 Color")
col100 = input.color(color.orange, title="SMA 100 Color")
col200 = input.color(color.purple, title="SMA 200 Color")

sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)

plot(show50  ? sma50  : na, color=col50,  linewidth=1, title="SMA 50")
plot(show100 ? sma100 : na, color=col100, linewidth=1, title="SMA 100")
plot(show200 ? sma200 : na, color=col200, linewidth=2, title="SMA 200")

// ── Range-bound zone ─────────────────────────────────────────────────────────
// Top, Bottom, Start Date, Color. Paints your color from the start date forward,
// overriding the normal filter. Ends on the first candle that closes above the
// top or below the bottom.
rangeTop   = input.price(0.0, title="Range Top",    group="Range-bound Zone")
rangeBot   = input.price(0.0, title="Range Bottom", group="Range-bound Zone")
rangeStart = input.time(timestamp("2026-06-01"), title="Start Date", group="Range-bound Zone")
rangeColor = input.color(color.new(color.gray, 60), title="Range Color", group="Range-bound Zone")

rangeSet   = rangeTop > 0 and rangeBot > 0
afterStart = time >= rangeStart

var bool rangeResolved = false
if afterStart and rangeSet and (close > rangeTop or close < rangeBot)
    rangeResolved := true

rangebound = rangeSet and afterStart and not rangeResolved

bgColor = rangebound ? rangeColor                           :
          green      ? color.new(color.rgb(0, 150, 0), 50)  :
          lightgreen ? color.new(color.rgb(0, 255, 0), 80)  :
          yellow     ? color.new(color.yellow, 80)          :
          na
bgcolor(color=bgColor)

// ── Metrics: QQQ daily % and Breadth (top-right) ─────────────────────────────
grp_metrics = "Metrics"
show_metrics = input.bool(true, title="Show QQQ / Breadth", group=grp_metrics)
met_size     = input.string("Small", title="Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_metrics)
met_bg       = input.color(color.new(color.black, 100), title="Background Color", group=grp_metrics)
met_lbl      = input.color(color.white, title="Label Color", group=grp_metrics)
met_txt      = input.color(color.orange, title="Value Fallback Color", group=grp_metrics)

// QQQ daily % change
qqqClose = request.security("QQQ", "D", close)
qqqPrev  = request.security("QQQ", "D", close[1])
qqqPct   = not na(qqqClose) and not na(qqqPrev) and qqqPrev != 0 ? (qqqClose - qqqPrev) / qqqPrev * 100 : na

// Breadth: (new highs - new lows) / new lows * 100, from ATHI.US / ATLO.US
athiClose = request.security("ATHI.US", "1", close)
atloClose = request.security("ATLO.US", "1", close)
breadth   = not na(athiClose) and not na(atloClose) and atloClose != 0 ? (athiClose - atloClose) / atloClose * 100 : na

met_sz = switch met_size
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

col_qqq = not na(qqqPct)  ? (qqqPct  > 0 ? color.green : color.red) : met_txt
col_brd = not na(breadth) ? (breadth > 0 ? color.green : color.red) : met_txt

var table t_top = table.new(position.top_right, 2, 2, bgcolor=met_bg, border_width=0, frame_width=0)

if show_metrics and barstate.islast
    qqq_str = not na(qqqPct)  ? (qqqPct  > 0 ? "+" : "") + str.tostring(qqqPct,  "0.00") + "%" : "N/A"
    brd_str = not na(breadth) ? (breadth > 0 ? "+" : "") + str.tostring(breadth, "0.00") + "%" : "N/A"

    table.cell(t_top, 0, 0, "QQQ",   text_color=met_lbl, bgcolor=met_bg, text_size=met_sz, text_halign=text.align_center)
    table.cell(t_top, 1, 0, "BRD",   text_color=met_lbl, bgcolor=met_bg, text_size=met_sz, text_halign=text.align_center)
    table.cell(t_top, 0, 1, qqq_str, text_color=col_qqq, bgcolor=met_bg, text_size=met_sz, text_halign=text.align_center)
    table.cell(t_top, 1, 1, brd_str, text_color=col_brd, bgcolor=met_bg, text_size=met_sz, text_halign=text.align_center)
````
