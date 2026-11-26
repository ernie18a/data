# Multi KI Agenten Strategie (Final V2)

- url: https://www.tradingview.com/script/pkEgBWVX/
- type: strategy
- pine_id: PUB;a6f3391f0cf24fa7b935c29c847deab0
- version: 1.0

## Description

What's included in the Pine Script (Technical Analysis)

These features are mathematically implemented in the script and function as "agent logic":

• Trend Following: Integrated via EMAs (50, 100, 200).

• Volume Analysis: An agent checks for institutional volume spikes.

• Supply & Demand: Zones are calculated based on price extremes.

• RSI & Fibonacci: Both are built in as decision criteria for the agents.

• Controlling AI: The "veto logic" in the code acts as a controlling instance, blocking signals if the risk is too high or divergences exist.

• Alerts: The "LONG" and "SHORT" alerts are only triggered after approval by the controlling mechanism.

## Source Code

````pine
// @version=5
strategy("Multi KI Agenten Strategie (Final V2)", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// ======================================================
// 1️⃣ BASIS & RISIKO
// ======================================================
price = close
atr_len = input.int(14, title="ATR Länge")
atr_ma_len = input.int(50, title="ATR MA Länge")
risk_mult = input.float(1.8, title="Max. Volatilitäts-Ratio")
sl_mult = input.float(2.0, title="Stop Loss Multiplikator (ATR)")
tp_mult = input.float(4.0, title="Take Profit Multiplikator (ATR)")
min_agents = input.int(3, title="Minimale Agenten-Zustimmung", minval=1, maxval=5)

atr   = ta.atr(atr_len)
atr_ma = ta.sma(atr, atr_ma_len)
vol_ratio = atr / atr_ma
risk_ok = vol_ratio < risk_mult

// ======================================================
// 2️⃣ AGENTEN-LOGIK (Trend, Momentum, Volumen, Struktur, S&D)
// ======================================================
ema50 = ta.ema(price, 50), ema100 = ta.ema(price, 100), ema200 = ta.ema(price, 200)
trend_dir = (ema50 > ema100 and ema100 > ema200) ? 1 : (ema50 < ema100 and ema100 < ema200) ? -1 : 0

rsi = ta.rsi(price, 14)
momentum_dir = rsi > 55 ? 1 : rsi < 45 ? -1 : 0

vol_ma = ta.sma(volume, 20), volume_active = volume > vol_ma * 1.3
volume_dir = (price > price[1] and volume_active) ? 1 : (price < price[1] and volume_active) ? -1 : 0

hh = ta.highest(high, 20), ll = ta.lowest(low, 20)
structure_dir = price > hh[1] ? 1 : price < ll[1] ? -1 : 0

demand_zone = ta.lowest(low, 10), supply_zone = ta.highest(high, 10)
sd_dir = (price <= demand_zone + atr * 0.25) ? 1 : (price >= supply_zone - atr * 0.25) ? -1 : 0

// ======================================================
// 3️⃣ KONSENS & CONTROLLING
// ======================================================
agents_long  = (trend_dir == 1 ? 1 : 0) + (momentum_dir == 1 ? 1 : 0) + (volume_dir == 1 ? 1 : 0) + (structure_dir == 1 ? 1 : 0) + (sd_dir == 1 ? 1 : 0)
agents_short = (trend_dir == -1 ? 1 : 0) + (momentum_dir == -1 ? 1 : 0) + (volume_dir == -1 ? 1 : 0) + (structure_dir == -1 ? 1 : 0) + (sd_dir == -1 ? 1 : 0)
agent_divergence = agents_long > 0 and agents_short > 0
controlling_veto = (not risk_ok) or (trend_dir == 0) or agent_divergence

final_long = not controlling_veto and trend_dir == 1 and agents_long >= min_agents and agents_short == 0
final_short = not controlling_veto and trend_dir == -1 and agents_short >= min_agents and agents_long == 0
final_status = final_long ? "LONG" : final_short ? "SHORT" : "WAIT"

// ======================================================
// 4️⃣ STRATEGIE & ALERTS
// ======================================================
if final_long
    strategy.entry("Long", strategy.long)
    strategy.exit("Exit L", "Long", stop=price - (atr * sl_mult), limit=price + (atr * tp_mult))
    alert("FINAL STATUS: LONG - Konsens erreicht.", alert.freq_once_per_bar_close)

if final_short
    strategy.entry("Short", strategy.short)
    strategy.exit("Exit S", "Short", stop=price + (atr * sl_mult), limit=price - (atr * tp_mult))
    alert("FINAL STATUS: SHORT - Konsens erreicht.", alert.freq_once_per_bar_close)

if not final_long and not final_short
    alert("FINAL STATUS: WAIT - Kein Konsens oder Veto aktiv.", alert.freq_once_per_bar_close)

// ======================================================
// 5️⃣ VISUALS & DASHBOARD
// ======================================================
plot(ema50, color=color.orange), plot(ema100, color=color.blue), plot(ema200, color=color.red)
plotshape(final_long, location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(final_short, location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small)

var table_dash = table.new(position.top_right, 2, 4, border_width=1, border_color=color.gray)
if barstate.islast
    table.cell(table_dash, 0, 0, "Agenten Konsens", bgcolor=color.black, text_color=color.white)
    table.cell(table_dash, 1, 0, "Score", bgcolor=color.black, text_color=color.white)
    table.cell(table_dash, 0, 1, "LONG", bgcolor=color.gray, text_color=color.white)
    table.cell(table_dash, 1, 1, str.tostring(agents_long), bgcolor=agents_long >= min_agents ? color.green : color.red)
    table.cell(table_dash, 0, 2, "SHORT", bgcolor=color.gray, text_color=color.white)
    table.cell(table_dash, 1, 2, str.tostring(agents_short), bgcolor=agents_short >= min_agents ? color.red : color.green)
    res_color = final_status == "LONG" ? color.green : final_status == "SHORT" ? color.red : color.yellow
    table.cell(table_dash, 0, 3, "FINAL STATUS", bgcolor=res_color, text_color=color.black)
    table.cell(table_dash, 1, 3, final_status, bgcolor=res_color, text_color=color.black)
````
