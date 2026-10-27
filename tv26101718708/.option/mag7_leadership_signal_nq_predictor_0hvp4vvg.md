# Mag7 Leadership Signal [NQ Predictor]

- url: https://www.tradingview.com/script/0hVp4VvG-Mag7-Leadership-Signal-NQ-Predictor/
- type: indicator
- pine_id: PUB;7e5df45592d14ce4b0a4a2e6cb96c4f7
- version: 1.0

## Description

this line averages out the behavior of the mag 7 and displays a buying or selling box when appropriate score is shown. 0-4 selling 6-10 buying

## Source Code

````pine
//@version=6
indicator("Mag7 Leadership Signal [NQ Predictor]", 
          shorttitle="Mag7 Bar", 
          overlay=false, 
          max_bars_back=1000, 
          max_labels_count=500)

// ──────────────────────────────────────────────
// INPUTS
// ──────────────────────────────────────────────
len_rsi      = input.int(14, "RSI Length", minval=1, group="Indicators")
ma_short_len = input.int(5,  "Short MA Length (Breadth)", minval=1, group="Indicators")

show_details = input.bool(true, "Show Extra Details Table", group="Display")
show_spark   = input.bool(true, "Show Score Sparkline",     group="Display")

// ──────────────────────────────────────────────
// DATA FETCH
// ──────────────────────────────────────────────
aapl  = request.security("AAPL",  timeframe.period, close)
amzn  = request.security("AMZN",  timeframe.period, close)
googl = request.security("GOOGL", timeframe.period, close)
meta  = request.security("META",  timeframe.period, close)
msft  = request.security("MSFT",  timeframe.period, close)
nvda  = request.security("NVDA",  timeframe.period, close)
tsla  = request.security("TSLA",  timeframe.period, close)

// Daily % changes
chg_aapl  = (aapl  / aapl[1]  - 1) * 100
chg_amzn  = (amzn  / amzn[1]  - 1) * 100
chg_googl = (googl / googl[1] - 1) * 100
chg_meta  = (meta  / meta[1]  - 1) * 100
chg_msft  = (msft  / msft[1]  - 1) * 100
chg_nvda  = (nvda  / nvda[1]  - 1) * 100
chg_tsla  = (tsla  / tsla[1]  - 1) * 100

// Weighted change (short lines - no long splits)
w1 = chg_aapl * 0.12
w2 = chg_amzn * 0.13
w3 = chg_googl * 0.14
w4 = chg_meta * 0.13
w5 = chg_msft * 0.20
w6 = chg_nvda * 0.22
w7 = chg_tsla * 0.06
weighted_chg = w1 + w2 + w3 + w4 + w5 + w6 + w7

// RSI
rsi_aapl  = ta.rsi(aapl,  len_rsi)
rsi_amzn  = ta.rsi(amzn,  len_rsi)
rsi_googl = ta.rsi(googl, len_rsi)
rsi_meta  = ta.rsi(meta,  len_rsi)
rsi_msft  = ta.rsi(msft,  len_rsi)
rsi_nvda  = ta.rsi(nvda,  len_rsi)
rsi_tsla  = ta.rsi(tsla,  len_rsi)

avg_rsi = (rsi_aapl + rsi_amzn + rsi_googl + rsi_meta + rsi_msft + rsi_nvda + rsi_tsla) / 7

// Breadth
ma_short_aapl  = ta.sma(aapl,  ma_short_len)
ma_short_amzn  = ta.sma(amzn,  ma_short_len)
ma_short_googl = ta.sma(googl, ma_short_len)
ma_short_meta  = ta.sma(meta,  ma_short_len)
ma_short_msft  = ta.sma(msft,  ma_short_len)
ma_short_nvda  = ta.sma(nvda,  ma_short_len)
ma_short_tsla  = ta.sma(tsla,  ma_short_len)

bull_count = 0
bull_count += (aapl  > ma_short_aapl  ? 1 : 0)
bull_count += (amzn  > ma_short_amzn  ? 1 : 0)
bull_count += (googl > ma_short_googl ? 1 : 0)
bull_count += (meta  > ma_short_meta  ? 1 : 0)
bull_count += (msft  > ma_short_msft  ? 1 : 0)
bull_count += (nvda  > ma_short_nvda  ? 1 : 0)
bull_count += (tsla  > ma_short_tsla  ? 1 : 0)

breadth_score = (bull_count - 3.5) * 8

// Final Score
p1 = weighted_chg * 0.40
p2 = (avg_rsi - 50) * 0.30
p3 = breadth_score * 0.20
p4 = weighted_chg[1] * 0.10
score = p1 + p2 + p3 + p4

// ──────────────────────────────────────────────
// SIGNAL LOGIC (your custom rules)
// ──────────────────────────────────────────────
var string signal = "MIXED"
if score >= 6 and score <= 10
    signal := "BUYING"
else if score >= 0 and score <= 4
    signal := "SELLING"
else if score <= -6 and score >= -10
    signal := "SELLING"
else if score <= 0 and score >= -4
    signal := "BUYING"
else
    signal := "MIXED"

// Color for the colored box
var color box_color = color.gray
if signal == "BUYING"
    box_color := color.new(color.green, 0)
else if signal == "SELLING"
    box_color := color.new(color.red, 0)
else
    box_color := color.new(color.gray, 30)

// ──────────────────────────────────────────────
// MAIN COLORED LABEL (no grey box underneath)
// ──────────────────────────────────────────────
var label sig_label = label.new(bar_index, 0, "", 
                                color = box_color, 
                                textcolor = color.white, 
                                size = size.huge, 
                                style = label.style_label_center)

if barstate.islast
    label.set_xy(sig_label, bar_index, score * 0.7)
    label.set_text(sig_label, signal + "\nScore: " + str.tostring(math.round(score)))

// Sparkline
plot(show_spark ? score : na, "Sparkline", color=color.new(color.white, 70), 
     style=plot.style_line, linewidth=2)

// Score columns
plot(score, "Score", color=box_color, style=plot.style_columns, linewidth=12)

// ──────────────────────────────────────────────
// OPTIONAL CLEAN TABLE (transparent background)
// ──────────────────────────────────────────────
var table info_table = table.new(position.top_right, 2, 4, 
                                 bgcolor = na, border_width = 0)

if barstate.islast and show_details
    table.cell(info_table, 0, 0, "Weighted Change", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 0, str.tostring(weighted_chg, "#.##") + "%", text_color=color.white, text_size=size.small)
    
    table.cell(info_table, 0, 1, "Avg RSI", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(avg_rsi, "#.#"), text_color=color.white, text_size=size.small)
    
    table.cell(info_table, 0, 2, "Bullish Stocks", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 2, str.tostring(bull_count) + "/7", text_color=color.white, text_size=size.small)
    
    table.cell(info_table, 0, 3, "Score", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 3, str.tostring(math.round(score)), text_color=color.white, text_size=size.small)
````
