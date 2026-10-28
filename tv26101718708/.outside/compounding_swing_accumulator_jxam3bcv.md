# Compounding Swing Accumulator

- url: https://www.tradingview.com/script/JxAm3BCV-Compounding-Swing-Accumulator/
- type: indicator
- pine_id: PUB;56e60297ccaf4c38bd7e78619825a881
- version: 2.0

## Description

Tracks the daily macro swing bottoms and tops to compound equity with 100% long/cash status tables.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © eli2k_rodgers

//@version=6
indicator("Compounding Swing Accumulator", overlay=true, max_labels_count=500)

// ──────────────────────────────────────────────
// 1. Inputs & Configuration
// ──────────────────────────────────────────────
ticker_1x      = input.symbol("NASDAQ:QQQ", title="1x Underlying Index")
length_sma     = input.int(200, title="Baseline SMA Length")
length_rsi     = input.int(14,  title="RSI Length")

buy_z_limit    = input.float(-1.8, title="Z-Score Buy Trigger")
buy_rsi_limit  = input.float(35.0, title="RSI Buy Trigger")

sell_z_limit   = input.float(2.0,  title="Z-Score Sell Trigger")
sell_rsi_limit = input.float(80.0, title="RSI Sell Trigger")

show_shapes    = input.bool(true,  title="Show Signal Markers")
show_table     = input.bool(true,  title="Show Simulation Panel")

// ──────────────────────────────────────────────
// 2. Data Fetching & Indicator Calculations
// ──────────────────────────────────────────────
idx_close  = request.security(ticker_1x, timeframe.period, close)
idx_sma    = request.security(ticker_1x, timeframe.period, ta.sma(close, length_sma))
idx_stdev  = request.security(ticker_1x, timeframe.period, ta.stdev(close, length_sma))
idx_rsi    = request.security(ticker_1x, timeframe.period, ta.rsi(close, length_rsi))
idx_ema10  = request.security(ticker_1x, timeframe.period, ta.ema(close, 10))

z_score    = (idx_close - idx_sma) / idx_stdev

// ──────────────────────────────────────────────
// 3. Buy and Sell Conditions
// ──────────────────────────────────────────────
buy_zone   = (z_score <= buy_z_limit) and (idx_rsi <= buy_rsi_limit)
sell_zone  = (z_score >= sell_z_limit) and (idx_rsi >= sell_rsi_limit)

cross_below_ema10 = ta.crossunder(idx_close, idx_ema10)
sell_active       = ta.barssince(sell_zone) < 5

// State Management
var bool in_trade = false
bool buy_signal   = buy_zone and not in_trade
bool sell_signal  = cross_below_ema10 and sell_active and in_trade

if buy_signal
    in_trade := true
if sell_signal
    in_trade := false

// ──────────────────────────────────────────────
// 4. Compounding Swing Backtest Simulation
// ──────────────────────────────────────────────
var float cash = 10000.0
var float shares = 0.0
var float entry_price = 0.0
var int trade_count = 0
var int win_count = 0

if buy_signal and cash > 0.0
    shares      := cash / close
    cash        := 0.0
    entry_price := close
    trade_count := trade_count + 1

if sell_signal and shares > 0.0
    float sell_val = shares * close
    cash           := sell_val
    shares         := 0.0
    if sell_val > (shares * entry_price + cash) // checking profit relative to entry
        win_count  := win_count + 1

float current_equity = cash + (shares * close)
float win_rate       = trade_count > 0 ? (float(win_count) / float(trade_count)) * 100.0 : 100.0

// ──────────────────────────────────────────────
// 5. Drawing Visual Elements
// ──────────────────────────────────────────────
plotshape(show_shapes and buy_signal,  title="Buy Entry",  style=shape.triangleup,   location=location.belowbar, color=color.green, size=size.normal, text="BUY")
plotshape(show_shapes and sell_signal, title="Sell Exit", style=shape.triangledown, location=location.abovebar, color=color.red,   size=size.normal, text="SELL")

bgcolor(buy_zone ? color.new(color.green, 90) : na, title="Buy Accumulation Zone")
bgcolor(sell_zone ? color.new(color.red, 90) : na, title="Euphoria Exit Zone")

// ──────────────────────────────────────────────
// 6. Data Panel Overlay
// ──────────────────────────────────────────────
var table statTable = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast and show_table
    table.cell(statTable, 0, 0, "Metric",             text_color=color.white, text_size=size.small)
    table.cell(statTable, 1, 0, "Value",              text_color=color.white, text_size=size.small)
    
    table.cell(statTable, 0, 1, "Z-Score",             text_color=color.gray,  text_size=size.small)
    table.cell(statTable, 1, 1, str.tostring(z_score, "#.##"), text_color=z_score <= buy_z_limit ? color.green : z_score >= sell_z_limit ? color.red : color.white, text_size=size.small)
    
    table.cell(statTable, 0, 2, "RSI (14)",           text_color=color.gray,  text_size=size.small)
    table.cell(statTable, 1, 2, str.tostring(idx_rsi, "#.##"), text_color=idx_rsi <= buy_rsi_limit ? color.green : idx_rsi >= sell_rsi_limit ? color.red : color.white, text_size=size.small)
    
    table.cell(statTable, 0, 3, "Account Value",      text_color=color.gray,  text_size=size.small)
    table.cell(statTable, 1, 3, "$" + str.tostring(current_equity, "#,###.##"), text_color=color.teal, text_size=size.small, text_formatting=text.format_bold)
    
    table.cell(statTable, 0, 4, "Total Trades",        text_color=color.gray,  text_size=size.small)
    table.cell(statTable, 1, 4, str.tostring(trade_count), text_color=color.white, text_size=size.small)
    
    table.cell(statTable, 0, 5, "Win Rate",           text_color=color.gray,  text_size=size.small)
    table.cell(statTable, 1, 5, str.tostring(win_rate, "#.##") + "%", text_color=win_rate >= 95.0 ? color.green : color.orange, text_size=size.small)

    table.cell(statTable, 0, 6, "Active State",        text_color=color.gray,  text_size=size.small)
    table.cell(statTable, 1, 6, in_trade ? "LONG" : "CASH", text_color=in_trade ? color.green : color.orange, text_size=size.small)
````
