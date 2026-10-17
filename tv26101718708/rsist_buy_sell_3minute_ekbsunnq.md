#  RSI/ST Buy & Sell (3-Minute)

- url: https://www.tradingview.com/script/ekBsUNnq-RSI-ST-Buy-Sell-3-Minute/
- type: indicator
- pine_id: PUB;4a96ae05b989408da58c83dde1a77445
- version: 1.0

## Description

This indicator is designed for the 3-Minute chart and generates 
clean Buy and Sell signals based on two powerful confluences:

BUY SIGNAL — Triggered when:
  • Current candle is GREEN (close > open)
  • Supertrend indicator is in BUY mode (price above Supertrend line)

SELL SIGNAL — Triggered when:
  • Current candle is RED (close < open)
  • Supertrend indicator is in SELL mode (price below Supertrend line)

Both conditions must be TRUE at the same time for a signal to appear.
This dual-confirmation approach filters out weak and false signals,
giving you only the highest-probability entries.

## Source Code

````pine
//@version=5
// AI Fiesta — RSI + Supertrend Buy & Sell (3-Minute Version)
indicator("AI Fiesta - RSI/ST Buy & Sell (3-Minute)", overlay=true)

// ======================================================================
// 🔧 User Inputs
// ======================================================================
rsi_len     = input.int(14, title="RSI Length")
rsi_sma_len = input.int(20, title="SMA of RSI Length")
st_atr_len  = input.int(10, title="Supertrend ATR Length")
st_factor   = input.float(1.0, title="Supertrend Factor")
use_fixed_tf = input.bool(true, "Force 3-Minute Timeframe")

// ======================================================================
// 🧮 Indicator Calculations (on 3-Minute timeframe)
// ======================================================================
tf = use_fixed_tf ? "3" : timeframe.period

// RSI and SMA
rsi_val_3m     = request.security(syminfo.tickerid, tf, ta.rsi(close, rsi_len))
rsi_sma_val_3m = request.security(syminfo.tickerid, tf, ta.sma(rsi_val_3m, rsi_sma_len))

// Supertrend
[st_val_3m, st_dir_3m] = request.security(syminfo.tickerid, tf, ta.supertrend(st_factor, st_atr_len))

// ======================================================================
// ⚙️ Signal Logic
// ======================================================================
// --- BUY CONDITIONS ---
cond_rsi_buy_cross = ta.crossover(rsi_val_3m, rsi_sma_val_3m)
cond_st_buy_cross  = ta.crossover(close, st_val_3m)
buy_signal         = cond_rsi_buy_cross and cond_st_buy_cross

// --- SELL CONDITIONS ---
cond_rsi_sell_cross = ta.crossunder(rsi_val_3m, rsi_sma_val_3m)
cond_st_sell_cross  = ta.crossunder(close, st_val_3m)
sell_signal         = cond_rsi_sell_cross and cond_st_sell_cross

// ======================================================================
// 💡 Plot Signals
// ======================================================================
plot(st_val_3m, "Supertrend (3m)", color = st_dir_3m < 0 ? color.green : color.red, linewidth=2)

plotshape(buy_signal, "Buy Signal", style=shape.labelup, location=location.belowbar,
     color=color.new(color.green, 0), size=size.normal, text="BUY (3m)", textcolor=color.white)

plotshape(sell_signal, "Sell Signal", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red, 0), size=size.normal, text="SELL (3m)", textcolor=color.white)

// ======================================================================
// 🧭 Notes
// ======================================================================
// ✅ This script calculates all logic on the 3-minute timeframe regardless of your chart.
// ✅ Uncheck “Force 3-Minute Timeframe” in settings if you want to use chart timeframe.
// ✅ Works well for intraday scalping or Nifty/BankNifty futures.
````
