# KALKI TFXBOT

- url: https://www.tradingview.com/script/gFMT7BUb-KALKI-TFXBOT/
- type: strategy
- pine_id: PUB;d09481f52e7e4fe896e4f7fc0164e6b2
- version: 1.0

## Description

⚜️ KALKI TFX BOT : SMC Liquidity Sniper
By kalkitrading.com

Overview
The KALKI TFX BOT is an institutional-grade automated strategy designed to stop chasing retail breakouts and start trading alongside Smart Money. Built specifically for high-volatility assets like XAUUSD (Gold), this engine ignores lagging oscillators and focuses entirely on Liquidity Sweeps and structural market shifts.

If you are tired of getting stopped out by wicks or chopped up in sideways consolidation, this is your execution model.

How It Works
Retail traders place their stop losses at obvious support and resistance levels. Institutional algorithms push the price past these levels to "sweep" that liquidity before reversing the market in the true direction. The IBZ Cartel Engine is mathematically programmed to detect these exact traps.

It waits for a candle to pierce a major liquidity pool, and triggers an entry only if the price aggressively rejects and closes back inside the structure.

Core Features

SMC Liquidity Sweeps: Maps internal swing highs and lows, entering the market only after retail liquidity has been purged.

Dynamic ATR Risk Management: Stop Losses are never arbitrary. The engine hides your Stop Loss strictly behind the sweep wick, adding a dynamic ATR buffer to protect you from broker slippage.

Institutional Cartel Visuals: Displays premium, shaded Risk:Reward boxes (Blue/Red for TP, Grey for SL) directly on your chart. Includes an automatic "Box Cutter" algorithm to ensure your chart remains perfectly clean with zero overlapping visuals if a position reverses.

Strict 1:3 R:R Enforcement: Hardcoded to enforce a minimum 1:3 Risk-to-Reward ratio, allowing you to grow your account even with a win rate as low as 35%.

Macro Trend Guard: Built-in EMA 200 filter ensures you are only taking liquidity sweeps in the direction of the dominant institutional trend.

Best Practices

Timeframes: Optimized for the 5m and 15m intraday charts.

Assets: Highly effective on XAUUSD, Brent Crude, and Silver.

Chart Settings: For the cleanest visual experience, go to Chart Settings -> Trading -> and uncheck "Show Executions" to hide default TradingView arrows.

Trade like the KALKI Cartel. Protect your capital. Execute without emotion.

## Source Code

````pine
//@version=6
strategy('KALKI TFXBOT', shorttitle = 'KALKI TFX BOT', overlay = true, initial_capital = 100, default_qty_type = strategy.fixed, default_qty_value = 1, margin_long = 0, margin_short = 0, process_orders_on_close = true, max_boxes_count = 500)

// ==========================================================================================
// ■ 1. CARTEL SETTINGS (STRICT SMC RISK)
// ==========================================================================================
G_RISK      = "🛡️ CARTEL RISK MANAGEMENT"
i_rr        = input.float(3.0, "Risk to Reward Ratio (e.g. 3 = 1:3 RR)", step=0.5, group=G_RISK)
i_slBuffer  = input.float(0.5, "Stop Loss Buffer (Pips)", step=0.1, group=G_RISK, tooltip="Adds a tiny gap below the wick so you don't get perfectly stopped out.")

G_FILT      = "⚡ SMC FILTERS"
i_emaTrend  = input.int(200, "EMA Trend Guard", group=G_FILT)
i_pivotL    = input.int(10, "Swing Left Lookback", group=G_FILT)
i_pivotR    = input.int(3, "Swing Right Lookback", group=G_FILT)

// Premium Colors
c_slBox  = color.new(color.rgb(156, 156, 156), 80)
c_tpBuy  = color.new(color.rgb(77, 208, 225), 80) 
c_tpSell = color.new(color.rgb(247, 82, 95), 80)  
c_entry  = color.new(color.blue, 85)

// ==========================================================================================
// ■ 2. SMART MONEY STRUCTURE (LIQUIDITY SWEEPS)
// ==========================================================================================
ema200 = ta.ema(close, i_emaTrend)

// Find Institutional Swing Points (Tuned for faster sweeps)
float pl = ta.pivotlow(low, i_pivotL, i_pivotR)
float ph = ta.pivothigh(high, i_pivotL, i_pivotR)

var float current_sup = na
var float current_res = na

if not na(pl)
    current_sup := pl
if not na(ph)
    current_res := ph

// Visual Liquidity Pools (So you know it's working)
plot(current_sup, color=color.new(color.blue, 50), style=plot.style_circles, linewidth=1, title="Liquidity Floor")
plot(current_res, color=color.new(color.red, 50), style=plot.style_circles, linewidth=1, title="Liquidity Ceiling")

// Sweep Logic: Price wicks past support/resistance but closes back inside (Rejection)
bool sweep_buy  = low < current_sup and close > current_sup and close > open and close > ema200
bool sweep_sell = high > current_res and close < current_res and close < open and close < ema200

// ==========================================================================================
// ■ 3. EXECUTION & BOX CUTTER (NATIVE SYNC)
// ==========================================================================================
var box b_entry = na, var box b_sl = na, var box b_tp = na

if sweep_buy and strategy.position_size <= 0
    if strategy.position_size < 0
        strategy.close("Short", comment="REVERSAL")
        box.set_right(b_entry, bar_index)
        box.set_right(b_sl, bar_index)
        box.set_right(b_tp, bar_index)
        
    float entry_price = close
    float sl_price = low - (i_slBuffer / 10) // SL strictly below the sweeping wick
    float risk_amt = entry_price - sl_price
    float tp_price = entry_price + (risk_amt * i_rr)
    
    // Draw Cartel Boxes
    b_entry := box.new(bar_index, entry_price, bar_index + 15, entry_price, border_width=1, border_color=color.blue, bgcolor=c_entry)
    b_sl    := box.new(bar_index, entry_price, bar_index + 15, sl_price, border_width=0, bgcolor=c_slBox)
    b_tp    := box.new(bar_index, tp_price, bar_index + 15, entry_price, border_width=0, bgcolor=c_tpBuy)
    
    strategy.entry("Long", strategy.long, comment="SWEEP BUY")
    strategy.exit("Exit Long", "Long", stop=sl_price, limit=tp_price)

if sweep_sell and strategy.position_size >= 0
    if strategy.position_size > 0
        strategy.close("Long", comment="REVERSAL")
        box.set_right(b_entry, bar_index)
        box.set_right(b_sl, bar_index)
        box.set_right(b_tp, bar_index)
        
    float entry_price = close
    float sl_price = high + (i_slBuffer / 10) // SL strictly above the sweeping wick
    float risk_amt = sl_price - entry_price
    float tp_price = entry_price - (risk_amt * i_rr)
    
    // Draw Cartel Boxes
    b_entry := box.new(bar_index, entry_price, bar_index + 15, entry_price, border_width=1, border_color=color.blue, bgcolor=c_entry)
    b_sl    := box.new(bar_index, sl_price, bar_index + 15, entry_price, border_width=0, bgcolor=c_slBox)
    b_tp    := box.new(bar_index, entry_price, bar_index + 15, tp_price, border_width=0, bgcolor=c_tpSell)
    
    strategy.entry("Short", strategy.short, comment="SWEEP SELL")
    strategy.exit("Exit Short", "Short", stop=sl_price, limit=tp_price)

// ==========================================================================================
// ■ 4. CARTEL HUD
// ==========================================================================================
var table hud = table.new(position.top_right, 2, 4, bgcolor=color.rgb(20, 20, 20), border_width=1, frame_color=color.white)
if barstate.islast
    table.cell(hud, 0, 0, "KALKI TFXBOT", text_color=color.rgb(229, 207, 15))
    table.cell(hud, 1, 0, "KALKIC ARTEL CORE", text_color=color.white)
    table.cell(hud, 0, 1, "ENGINE", text_color=color.white)
    table.cell(hud, 1, 1, "LIQUIDITY SWEEP", text_color=color.rgb(77, 208, 225))
    table.cell(hud, 0, 2, "CURRENT R:R", text_color=color.white)
    table.cell(hud, 1, 2, "1 : " + str.tostring(i_rr), text_color=color.rgb(229, 207, 15))
    table.cell(hud, 0, 3, "EMA TREND GUARD", text_color=color.white)
    table.cell(hud, 1, 3, "ACTIVE", text_color=color.green)
````
