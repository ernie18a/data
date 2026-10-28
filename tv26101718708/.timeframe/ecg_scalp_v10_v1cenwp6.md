# ECG Scalp v1.0

- url: https://www.tradingview.com/script/v1cENwP6-ECG-Scalp-v1-0/
- type: indicator
- pine_id: PUB;2b6c1c077eeb4ebf9d921392a7a8a23d
- version: 1.0

## Description

EMA Scalp — 1–5 Min | LET'S GET RICH, let's go Emil.

When do I enter a trade?
Enter when the chart meets at least 2 of these 3 conditions:

1. EMA 8 (orange) crosses EMA 21 (blue)
Crosses from below upward = LONG. Crosses from above downward = SHORT.

2. RSI confirms buying or selling pressure.
LONG = RSI above 55. SHORT = RSI below 45.

3. 5-minute trend aligns with the crossover direction.
If the 5-min background is red (bearish), prefer shorts. If green (bullish), prefer longs. Trades will appear in both directions regardless — treat this more as added confidence than a hard requirement.

VWAP: Above 50 = LONG, Below 50 = SHORT. Not mandatory, but a solid extra confirmation signal.

When do I exit? Where is my stop loss and profit target?

Look for previous highs and lows — these act as resistance and support levels.
If price was at 100 earlier today and is now at 98 in a bullish setup: either take profit just below 100, or hold for a breakout through 100 toward ~102 (higher reward, higher risk). The same logic applies in reverse for shorts — use previous lows as your target and stop loss reference.

Always aim for at least a 1.5:1 risk/reward ratio, ideally 2:1.
Example: 4% profit target with a 2% stop loss. This means you can lose 50% of your trades and still be net profitable.

Never risk more than 2% of your total capital on a single trade. At that rate, you'd need to lose 50 trades in a row to blow the account.

## Source Code

````pine
//@version=5
indicator("ECG Scalp v1.0", shorttitle="ECG Scalp", overlay=true)

// INPUTS
rsi_len     = input.int(14, "RSI Period",          group="⚡ RSI")
rsi_long    = input.int(54, "RSI Long min",        group="⚡ RSI")
rsi_short   = input.int(46, "RSI Short max",       group="⚡ RSI")
session_end = input.int(19, "Stäng signals (UTC)", group="🕐 Tid")

// BERÄKNINGAR
ema8       = ta.ema(close, 8)
ema21      = ta.ema(close, 21)
rsi        = ta.rsi(close, rsi_len)
in_session = hour(time, "UTC") < session_end

// 5M TRENDFILTER
ema21_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 21), lookahead=barmerge.lookahead_off)
ema50_5m = request.security(syminfo.tickerid, "5", ta.ema(close, 50), lookahead=barmerge.lookahead_off)
bull_5m  = ema21_5m > ema50_5m
bear_5m  = ema21_5m < ema50_5m

// CROSSOVER på nuvarande timeframe (1m)
cross_up   = ta.crossover(ema8,  ema21)
cross_down = ta.crossunder(ema8, ema21)

// SIGNALER
long_signal  = cross_up   and rsi > rsi_long  and in_session
short_signal = cross_down and rsi < rsi_short and in_session

// VISUALISERING
plot(ema8,  "EMA 8",  color=color.new(color.orange, 0), linewidth=2)
plot(ema21, "EMA 21", color=color.new(color.blue,   0), linewidth=2)

bgcolor(bull_5m     ? color.new(color.green, 90) : na)
bgcolor(bear_5m     ? color.new(color.red,   90) : na)
bgcolor(not in_session ? color.new(color.gray, 85) : na, title="Stängd tid")

plotshape(long_signal,  location=location.belowbar, color=color.lime, style=shape.triangleup,   size=size.normal, text="LONG")
plotshape(short_signal, location=location.abovebar, color=color.red,  style=shape.triangledown, size=size.normal, text="SHORT")

// INFO-TABELL
var table info = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 50), border_width=1)
if barstate.islast
    table.cell(info, 0, 0, "INDIKATOR", text_color=color.gray,  text_size=size.small)
    table.cell(info, 1, 0, "STATUS",    text_color=color.gray,  text_size=size.small)
    table.cell(info, 0, 1, "5m Trend",  text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, bull_5m ? "▲ BULL" : "▼ BEAR", text_color=bull_5m ? color.lime : color.red, text_size=size.small)
    table.cell(info, 0, 2, "Session",   text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, in_session ? "✓ Öppen" : "✗ Stängd", text_color=in_session ? color.lime : color.red, text_size=size.small)
    table.cell(info, 0, 3, "EMA 8",     text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, str.tostring(math.round(ema8, 2)),  text_color=color.orange, text_size=size.small)
    table.cell(info, 0, 4, "EMA 21",    text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, str.tostring(math.round(ema21, 2)), text_color=color.blue,   text_size=size.small)
    table.cell(info, 0, 5, "RSI",       text_color=color.white, text_size=size.small)
    table.cell(info, 1, 5, str.tostring(math.round(rsi, 1)), text_color=rsi > 70 ? color.red : rsi < 30 ? color.lime : color.white, text_size=size.small)

// ALERTS
alertcondition(long_signal,  title="🟢 LONG",  message="ECG Scalp: LONG cross på {{ticker}} @ {{close}}")
alertcondition(short_signal, title="🔴 SHORT", message="ECG Scalp: SHORT cross på {{ticker}} @ {{close}}")
````
