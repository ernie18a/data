#  MTF Bias Table

- url: https://www.tradingview.com/script/SUdZGjpT-MTF-Bias-Table/
- type: indicator
- pine_id: PUB;613571cff6dd428d8f90c1b15ada27f1
- version: 1.0

## Description

Script name
QE — MTF Bias Table

Short description
Multi‑timeframe trend bias dashboard. Compares fast vs. slow MA alignment across 5m through 1M to classify each timeframe as bullish or bearish at a glance.

Description
QE — MTF Bias Table is a non‑repainting, multi‑timeframe trend dashboard built for traders who need higher timeframe context before entering lower timeframe setups. It evaluates fast vs. slow moving average alignment across eight timeframes (5m, 15m, 30m, 1H, 4H, 1D, 1W, 1M) and prints a clean, color‑coded table directly on the chart.

The indicator is intentionally designed to pair with order‑flow, structure, and liquidity tools. It does not predict direction; it answers one question: “Is this timeframe aligned bullish or bearish?”

How it works
Fast MA > Slow MA = Bullish alignment (green “▲ BULL”)

Fast MA < Slow MA = Bearish alignment (red “▼ BEAR”)

All MTF requests use lookahead disabled to prevent repainting. The script reads a fresh close‑based value at each higher timeframe candle, so the bias state is stable and reflects the confirmed bar, not the developing one.

Configurable inputs
Fast MA Length (default 20)

Slow MA Length (default 50)

MA Type (EMA or SMA)

Why use this
Instantly see if your entry timeframe aligns with the daily/weekly bias

Avoid counter‑trend entries when the HTF is stacked against you

Use it as a filter: only trade setups that agree with the higher timeframe bias

Compact table design with minimal chart clutter

Tags
multi-timeframe

trend

bias

dashboard

Usage note
This is a bias filter, not an entry system. Combine it with your own structure, liquidity, and confirmation models for a complete trading plan.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Quantum Edge Capital LLC

//@version=6
indicator('QE — MTF Bias Table', overlay = true)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grp = '▸ MTF Bias Settings'
fastLen = input.int(20, title = 'Fast MA Length', group = grp, minval = 1)
slowLen = input.int(50, title = 'Slow MA Length', group = grp, minval = 1)
maType = input.string('EMA', title = 'MA Type', group = grp, options = ['EMA', 'SMA'])

// ══════════════════════════════════════════════════════════════════════════════
// MA FUNCTION
// ══════════════════════════════════════════════════════════════════════════════
f_ma(src_, len_) =>
    maType == 'EMA' ? ta.ema(src_, len_) : ta.sma(src_, len_)

// ══════════════════════════════════════════════════════════════════════════════
// MTF BIAS ENGINE
// fast MA > slow MA = Bull | fast MA < slow MA = Bear
// lookahead_off — zero repainting
// ══════════════════════════════════════════════════════════════════════════════
fast_5m = request.security(syminfo.tickerid, '5', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_5m = request.security(syminfo.tickerid, '5', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_15m = request.security(syminfo.tickerid, '15', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_15m = request.security(syminfo.tickerid, '15', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_30m = request.security(syminfo.tickerid, '30', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_30m = request.security(syminfo.tickerid, '30', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_1h = request.security(syminfo.tickerid, '60', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_1h = request.security(syminfo.tickerid, '60', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_4h = request.security(syminfo.tickerid, '240', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_4h = request.security(syminfo.tickerid, '240', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_1d = request.security(syminfo.tickerid, '1D', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_1d = request.security(syminfo.tickerid, '1D', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_1w = request.security(syminfo.tickerid, '1W', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_1w = request.security(syminfo.tickerid, '1W', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

fast_1mo = request.security(syminfo.tickerid, '1M', f_ma(close, fastLen), lookahead = barmerge.lookahead_off)
slow_1mo = request.security(syminfo.tickerid, '1M', f_ma(close, slowLen), lookahead = barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════════════════
// BIAS BOOLEANS
// ══════════════════════════════════════════════════════════════════════════════
bull_5m = fast_5m >= slow_5m
bull_15m = fast_15m >= slow_15m
bull_30m = fast_30m >= slow_30m
bull_1h = fast_1h >= slow_1h
bull_4h = fast_4h >= slow_4h
bull_1d = fast_1d >= slow_1d
bull_1w = fast_1w >= slow_1w
bull_1mo = fast_1mo >= slow_1mo

// ══════════════════════════════════════════════════════════════════════════════
// TABLE — declared as var so it persists, cells updated every bar
// Using indicator() guarantees render on all symbols including CME futures
// ══════════════════════════════════════════════════════════════════════════════
var table t = table.new(position.top_right, 2, 9, bgcolor = color.new(#0A0A0A, 5), border_width = 1, border_color = color.new(color.gray, 55), frame_width = 1, frame_color = color.new(color.gray, 35))

// Colors
C_TF_BG = color.new(#111111, 5)
C_HEADER = color.new(#0A0A0A, 0)
C_BULL_BG = color.new(#00C9A7, 15)
C_BEAR_BG = color.new(#8B0000, 15)
C_TF_TEXT = color.new(color.silver, 0)
C_HEAD_TX = color.new(#00C9A7, 0)

// Write all cells every bar — no barstate.islast restriction in indicators
// Header
table.cell(t, 0, 0, 'TIMEFRAME', text_color = C_HEAD_TX, text_size = size.small, bgcolor = C_HEADER)
table.cell(t, 1, 0, 'BIAS', text_color = C_HEAD_TX, text_size = size.small, bgcolor = C_HEADER)

// 5m
table.cell(t, 0, 1, '5m', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 1, bull_5m ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_5m ? C_BULL_BG : C_BEAR_BG)

// 15m
table.cell(t, 0, 2, '15m', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 2, bull_15m ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_15m ? C_BULL_BG : C_BEAR_BG)

// 30m
table.cell(t, 0, 3, '30m', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 3, bull_30m ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_30m ? C_BULL_BG : C_BEAR_BG)

// 1H
table.cell(t, 0, 4, '1H', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 4, bull_1h ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_1h ? C_BULL_BG : C_BEAR_BG)

// 4H
table.cell(t, 0, 5, '4H', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 5, bull_4h ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_4h ? C_BULL_BG : C_BEAR_BG)

// 1D
table.cell(t, 0, 6, '1D', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 6, bull_1d ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_1d ? C_BULL_BG : C_BEAR_BG)

// 1W
table.cell(t, 0, 7, '1W', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 7, bull_1w ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_1w ? C_BULL_BG : C_BEAR_BG)

// 1M
table.cell(t, 0, 8, '1M', text_color = C_TF_TEXT, text_size = size.small, bgcolor = C_TF_BG)
table.cell(t, 1, 8, bull_1mo ? '▲ BULL' : '▼ BEAR', text_color = color.white, text_size = size.small, bgcolor = bull_1mo ? C_BULL_BG : C_BEAR_BG)
````
