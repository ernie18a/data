# ATR Stop Loss Calculator

- url: https://www.tradingview.com/script/ZOCEaX1X-ATR-Stop-Loss-Calculator/
- type: indicator
- pine_id: PUB;15bc317fff5e4c738d08e40d038fc084
- version: 2.0

## Description

This indicator automatically calculates your Stop Loss and Take Profit levels for both Long and Short trades on every candle, using the Average True Range (ATR) as the foundation for risk measurement.

Instead of guessing where to place your stop, this tool gives you a mathematically calculated level based on the actual volatility of the market you are trading. If the market is moving fast and ATR is high, your stop will be wider. If the market is quiet and ATR is low, your stop will be tighter. This keeps your risk decisions consistent and objective across all market conditions.

How it works

The entry point is taken from the open of each candle. The ATR is calculated over a configurable period (default 14) and multiplied by your chosen multiplier to determine the risk distance. The Stop Loss is placed that distance above the entry for Short trades and below the entry for Long trades. The Take Profit is then placed at your chosen Risk:Reward multiple in the opposite direction.

What the table shows

The table in the top right corner displays both Long and Short scenarios side by side on every candle so you can immediately see your levels regardless of which direction you are considering. It shows Entry, Stop Loss, Take Profit, Risk in points, Reward in points, and the current ATR value.

Inputs

ATR Period — the number of candles used to calculate the Average True Range. Default is 14.
ATR Multiplier — how many times the ATR to use as your risk distance. Use 1.0 for a tight stop in a trending market, 1.5 for normal conditions, and 2.0 for choppy or volatile markets.
Risk:Reward Target — your desired R multiple for the Take Profit. Default is 3 for a 1:3 Risk:Reward ratio.

Who this is for

This indicator is built for traders who want to remove emotion from their stop placement and base every trade decision on real market volatility. It works on any asset and any timeframe including Forex, Gold, Crypto, Indices, and Stocks.

## Source Code

````pine
//@version=5
indicator("ATR Stop Loss Calculator", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────
atr_period = input.int(14,    title="ATR Period")
atr_multi  = input.float(1.0, title="ATR Multiplier", step=0.5, minval=0.5, maxval=3.0)
rr_target  = input.float(3.0, title="Risk:Reward Target", step=0.5, minval=1.0)

// ─── CALCULATIONS ─────────────────────────────────────────
atr_value = ta.atr(atr_period)
entry     = close
risk      = atr_value * atr_multi

// Long
long_sl = entry - risk
long_tp = entry + (risk * rr_target)

// Short
short_sl = entry + risk
short_tp = entry - (risk * rr_target)

// ─── TABLE ────────────────────────────────────────────────
var table t = table.new(position.top_right, 3, 7,
     bgcolor      = color.new(color.black, 10),
     border_width = 1,
     border_color = color.gray,
     frame_color  = color.gray,
     frame_width  = 1)

// ── Header ──
table.cell(t, 0, 0, "LEVEL",
     text_color=color.white, text_size=size.small,
     bgcolor=color.new(color.gray, 30))
table.cell(t, 1, 0, "🟢 LONG",
     text_color=color.green, text_size=size.small,
     bgcolor=color.new(color.gray, 30))
table.cell(t, 2, 0, "🔴 SHORT",
     text_color=color.red,   text_size=size.small,
     bgcolor=color.new(color.gray, 30))

// ── Entry ──
table.cell(t, 0, 1, "Entry (Close)", text_color=color.white,  text_size=size.small)
table.cell(t, 1, 1, str.tostring(entry, "#.000"), text_color=color.yellow, text_size=size.small)
table.cell(t, 2, 1, str.tostring(entry, "#.000"), text_color=color.yellow, text_size=size.small)

// ── Stop Loss ──
table.cell(t, 0, 2, "Stop Loss",   text_color=color.white, text_size=size.small)
table.cell(t, 1, 2, str.tostring(long_sl,  "#.000"), text_color=color.red, text_size=size.small)
table.cell(t, 2, 2, str.tostring(short_sl, "#.000"), text_color=color.red, text_size=size.small)

// ── Take Profit ──
table.cell(t, 0, 3, "Take Profit (" + str.tostring(rr_target) + "R)",
     text_color=color.white, text_size=size.small)
table.cell(t, 1, 3, str.tostring(long_tp,  "#.000"), text_color=color.green, text_size=size.small)
table.cell(t, 2, 3, str.tostring(short_tp, "#.000"), text_color=color.green, text_size=size.small)

// ── Risk ──
table.cell(t, 0, 4, "Risk (pts)",  text_color=color.white,  text_size=size.small)
table.cell(t, 1, 4, str.tostring(risk, "#.000"), text_color=color.orange, text_size=size.small)
table.cell(t, 2, 4, str.tostring(risk, "#.000"), text_color=color.orange, text_size=size.small)

// ── Reward ──
table.cell(t, 0, 5, "Reward (pts)", text_color=color.white, text_size=size.small)
table.cell(t, 1, 5, str.tostring(risk * rr_target, "#.000"), text_color=color.orange, text_size=size.small)
table.cell(t, 2, 5, str.tostring(risk * rr_target, "#.000"), text_color=color.orange, text_size=size.small)

// ── ATR ──
table.cell(t, 0, 6, "ATR (" + str.tostring(atr_period) + ")",
     text_color=color.white, text_size=size.small)
table.cell(t, 1, 6, str.tostring(atr_value, "#.000"), text_color=color.orange, text_size=size.small)
table.cell(t, 2, 6, str.tostring(atr_value, "#.000"), text_color=color.orange, text_size=size.small)

// ─── PLOT ATR for reference ────────────────────────────────
plot(atr_value, title="ATR", color=color.orange, linewidth=2)
````
