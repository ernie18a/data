# Relative Strength vs Index-SQB

- url: https://www.tradingview.com/script/X3ufYcql-Relative-Strength-vs-Index-SQB/
- type: indicator
- pine_id: PUB;39921fc1888a45b7acbdfda0c15bad9c
- version: 2.0

## Description

What is Relative Strength (RS)?
Imagine you open your chart of Infosys (INFY) and you want to know — is this stock actually strong, or is it just going up because the whole IT sector is going up?
That's exactly what RS tells you.
The formula is simply:

RS = Stock's % change − Index's % change (over same period)


Stock Δ% and Index Δ%
Say you set the lookback to 63 bars (~3 months):

Infosys went up +12% in last 63 days → that's your Stock Δ%
Nifty IT index went up +7% in the same 63 days → that's your Index Δ%
RS Value = 12 − 7 = +5 → Infosys is outperforming its sector by 5%

Another example:

Infosys went up +3%
Nifty IT went up +7%
RS Value = 3 − 7 = −4 → Infosys is underperforming its sector by 4%, even though the price went up

So a stock can be going up in price but still be WEAK if the index is going up faster. This is the key insight RS gives you.

What the RS line on the price chart does
Instead of reading numbers, you get a smooth line plotted on your candle chart — just like a 50 EMA or 200 EMA. When candles are above the RS line, the stock is in a strong phase relative to the index. When candles fall below the RS line, it means relative weakness is setting in. It acts as dynamic support/resistance based on relative momentum.

## Source Code

````pine
//@version=6
indicator("Relative Strength vs Index", shorttitle="RS Pro", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────────
grp1 = "📊 Benchmark Index"
benchmark = input.symbol("NSE:NIFTY", title="Benchmark Index", group=grp1,
     tooltip="NSE:NIFTY | NSE:BANKNIFTY | NSE:CNXIT | NSE:CNXPHARMA | NSE:CNXAUTO | NSE:CNXMETAL")

grp2 = "⚙️ RS Settings"
rs_length  = input.int(63,    title="RS Lookback (bars)", minval=1, maxval=500, group=grp2)
smooth_len = input.int(5,     title="RS Smoothing EMA",   minval=1, maxval=50,  group=grp2)
ma_len     = input.int(20,    title="Signal MA Length",   minval=1, maxval=200, group=grp2)
show_ma    = input.bool(true, title="Show Signal MA",     group=grp2)

grp3 = "🎨 Colors"
show_signals = input.bool(true, title="Show Crossover Signals", group=grp3)
bull_col     = input.color(#26a69a, title="Outperform Color",   group=grp3)
bear_col     = input.color(#ef5350, title="Underperform Color", group=grp3)

// ─── DATA ─────────────────────────────────────────────────────
bench_close = request.security(benchmark, timeframe.period, close,
              lookahead=barmerge.lookahead_off)

// ─── RS CALCULATION ───────────────────────────────────────────
stock_chg = (close       - close[rs_length])       / close[rs_length]       * 100
bench_chg = (bench_close - bench_close[rs_length]) / bench_close[rs_length] * 100

rs_raw  = stock_chg - bench_chg
rs_line = ta.ema(rs_raw, smooth_len)
rs_ma   = ta.ema(rs_line, ma_len)

// ─── CLASSIFICATION ───────────────────────────────────────────
rs_above_zero = rs_line > 0
rs_above_ma   = rs_line > rs_ma
rs_rising     = rs_line > rs_line[1]

strong    = rs_above_zero and rs_above_ma and rs_rising
weak      = not rs_above_zero and not rs_above_ma and not rs_rising
improving = not rs_above_zero and rs_rising
weakening = rs_above_zero and not rs_rising

bar_col = strong    ? bull_col :
          weak      ? bear_col :
          improving ? color.new(bull_col, 40) :
                      color.new(bear_col, 40)

// ─── REFERENCE LINES ──────────────────────────────────────────
hline(0,   "Zero",  color=color.new(color.white, 30), linewidth=1)
hline(5,   "+5%",   color=color.new(bull_col, 65), linestyle=hline.style_dashed)
hline(-5,  "-5%",   color=color.new(bear_col, 65), linestyle=hline.style_dashed)
hline(10,  "+10%",  color=color.new(bull_col, 80), linestyle=hline.style_dotted)
hline(-10, "-10%",  color=color.new(bear_col, 80), linestyle=hline.style_dotted)

// ─── PLOTS ────────────────────────────────────────────────────
plot(rs_line, title="RS Histogram",
     style=plot.style_columns, color=color.new(bar_col, 35))

rs_plot = plot(rs_line, title="RS Line",  color=bar_col, linewidth=2)
ma_plot = plot(show_ma ? rs_ma : na, title="Signal MA",
               color=color.new(color.yellow, 10), linewidth=1)

fill(rs_plot, ma_plot,
     color=rs_line > rs_ma ? color.new(bull_col, 78) : color.new(bear_col, 78))

// ─── SIGNALS ──────────────────────────────────────────────────
cross_up        = ta.crossover(rs_line,  rs_ma)
cross_down      = ta.crossunder(rs_line, rs_ma)
zero_cross_up   = ta.crossover(rs_line,  0)
zero_cross_down = ta.crossunder(rs_line, 0)

plotshape(show_signals and cross_up,
          style=shape.triangleup,   location=location.bottom, color=bull_col, size=size.small)
plotshape(show_signals and cross_down,
          style=shape.triangledown, location=location.top,    color=bear_col, size=size.small)
plotshape(show_signals and zero_cross_up,
          style=shape.circle, location=location.bottom, color=color.new(bull_col, 20), size=size.tiny)
plotshape(show_signals and zero_cross_down,
          style=shape.circle, location=location.top,    color=color.new(bear_col, 20), size=size.tiny)

// ─── ALERTS ───────────────────────────────────────────────────
alertcondition(cross_up,        "RS Crossed Above Signal MA",  "{{ticker}} gaining strength vs benchmark!")
alertcondition(cross_down,      "RS Crossed Below Signal MA",  "{{ticker}} losing strength vs benchmark!")
alertcondition(zero_cross_up,   "RS Crossed Above Zero",       "{{ticker}} now outperforming benchmark!")
alertcondition(zero_cross_down, "RS Crossed Below Zero",       "{{ticker}} now underperforming benchmark!")

// ─── INFO TABLE ───────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 9,
     bgcolor=color.new(color.black, 15), border_color=color.new(color.gray, 50),
     border_width=1, frame_color=color.new(color.gray, 20), frame_width=1)

if barstate.islast
    status_txt = strong    ? "🟢 STRONG"    :
                 weak      ? "🔴 WEAK"      :
                 improving ? "🟡 IMPROVING" :
                 weakening ? "🟠 WEAKENING" : "⚪ NEUTRAL"
    status_col = strong    ? bull_col :
                 weak      ? bear_col :
                 improving ? color.new(color.yellow, 0) : color.orange
    rs_explain = rs_line >= 0
                 ? "Stock +" + str.tostring(math.round(math.abs(rs_line),1)) + "% ahead of index"
                 : "Stock "  + str.tostring(math.round(math.abs(rs_line),1)) + "% behind index"

    t.cell(0,0,"RELATIVE STRENGTH", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy,10))
    t.cell(1,0,"vs  " + benchmark,  text_color=color.new(color.yellow,0), text_size=size.small, bgcolor=color.new(color.navy,10))
    t.cell(0,1,"Status",      text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,1, status_txt,   text_color=status_col, text_size=size.small)
    t.cell(0,2,"Meaning",     text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,2, rs_explain,   text_color=rs_line >= 0 ? bull_col : bear_col, text_size=size.small)
    t.cell(0,3,"RS Value",    text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,3, str.tostring(math.round(rs_line,2)), text_color=rs_line >= 0 ? bull_col : bear_col, text_size=size.small)
    t.cell(0,4,"Stock Δ%",   text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,4, str.tostring(math.round(stock_chg,2)) + "%", text_color=stock_chg >= 0 ? bull_col : bear_col, text_size=size.small)
    t.cell(0,5,"Index Δ%",   text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,5, str.tostring(math.round(bench_chg,2)) + "%", text_color=bench_chg >= 0 ? bull_col : bear_col, text_size=size.small)
    t.cell(0,6,"vs Signal MA", text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,6, rs_above_ma ? "Above ↑ Bullish" : "Below ↓ Bearish", text_color=rs_above_ma ? bull_col : bear_col, text_size=size.small)
    t.cell(0,7,"RS Direction", text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,7, rs_rising ? "Rising ↗" : "Falling ↘", text_color=rs_rising ? bull_col : bear_col, text_size=size.small)
    t.cell(0,8,"Lookback",    text_color=color.new(color.white,40), text_size=size.small)
    t.cell(1,8, str.tostring(rs_length) + " bars (~" + str.tostring(math.round(rs_length/21)) + " months)", text_color=color.white, text_size=size.small)
````
