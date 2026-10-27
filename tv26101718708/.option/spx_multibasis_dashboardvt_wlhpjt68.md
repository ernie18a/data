# SPX Multi-Basis Dashboard[VT]

- url: https://www.tradingview.com/script/wLHpJT68/
- type: indicator
- pine_id: PUB;76a429faa9e045538f680c197906ea70
- version: 1.0

## Description

Here is a professional and comprehensive English description tailored for your TradingView script. You can use this for the script's publication description or as documentation.
------------------------------
## SPX Multi-Basis Dashboard## Overview
SPX Multi-Basis Dashboard is a high-performance institutional-grade market arbitrage tool designed for Pine Script v6. It calculates and tracks the real-time basis (price discrepancies) among major S&P 500 tracking instruments: SPX, SPY, E-mini Futures (ES!), and Micro E-mini Futures (MES!).
To provide reliable structural market insights and eliminate micro-second price flickering, the dashboard features a 5-minute discrete time-lock mechanism that samples and freezes the basis data at synchronized 5-minute intervals.
------------------------------
## Key Features

* Strict Non-Rounding Decimal Truncation: Built with custom mathematical routines (math.floor) that strictly truncate all market prices and basis values to 2 decimal places without rounding. This preserves the raw precision required for genuine arbitrage analysis.
* Synchronized 5-Minute Time-Lock: Locks the basis computations every 5 minutes to Filter out minor intraday noise and present clear structural premiums or discounts.
* Explicit Positive/Negative Sign Markings: Automatically appends literal + or - symbols prefixing the basis column (+12.45 / -3.10) for instantaneous visibility of premium/discount states.
* Multi-Symbol Price Cross-Reference: Features a 3-column matrix layouts displaying the tracking Formula, real-time Market Prices, and the 5m Time-Locked Basis side by side.
* Premium Transparent Light Theme: Tailor-made for White/Light chart setups. It features a modern, ultra-clean graphite overlay with variable opacity that naturally blends into your chart workspace without blocking background candlesticks.
* Bulletproof Fault Tolerance: Embedded with v6 native compilation guardrails (ignore_invalid_symbol=true) and strict market cap divergence filters to handle contract rollovers smoothly without breaking or throwing runtime errors.

------------------------------
## Column Layout Guide

   1. Formula: Displays the mathematical alignment rule used for the calculation (e.g., SPX - (SPY × 10) to neutralize the SPY ETF 1:10 split ratio).
   2. Market Price: Live streaming quotes fetched directly via unified security channels. (Displays SPX / SPY coupled matrix on row 1, and underlying front-month continuous contract prices for ES! and MES! on rows 2 and 3).
   3. 5m Basis: The synchronized basis reading marked in Teal Green for positive values (Premium) and Wine Red for negative values (Discount).

------------------------------
## Configuration Inputs

* Update Interval (Mins): Customize the basis sampling frequency (Defaults to 5 minutes).
* Dashboard Position: Dynamically anchors the matrix across any corner of your chart workspace (Top Right, Bottom Right, Top Left, Bottom Left).

## Source Code

````pine
//@version=6
indicator("SPX Multi-Basis Dashboard[VT]", overlay=true)

// ============================================
// 1. System Settings
// ============================================
update_minutes = input.int(5, "Update Interval (Mins)", minval=1)
table_position = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"])

// Map table positions
pos = table_position == "Top Right"    ? position.top_right : 
      table_position == "Bottom Right" ? position.bottom_right : 
      table_position == "Top Left"     ? position.top_left : position.bottom_left

// ============================================
// Custom Function: Truncate & Add +/- Sign (No Rounding)
// ============================================
f_truncate_2d_with_sign(float val) =>
    if na(val)
        "-"
    else if val > 0
        // 正數：無條件捨去並加上 "+"
        "+" + str.tostring(math.floor(val * 100) / 100, "#.00")
    else if val < 0
        // 負數：先對絕對值進行捨去，再手動加上 "-" 確保截斷方向一致
        "-" + str.tostring(math.floor(math.abs(val) * 100) / 100, "#.00")
    else
        "0.00"

// 用於普通價格的截斷函數 (不帶正負號)
f_truncate_2d(float val) =>
    na(val) ? "-" : str.tostring(math.floor(val * 100) / 100, "#.00")

// ============================================
// 2. Fetch Cross-Symbol Prices
// ============================================
spx_price = request.security("SPX", "", close, ignore_invalid_symbol=true)
spy_price = request.security("SPY", "", close, ignore_invalid_symbol=true)
es_price  = request.security("CME_MINI:ES1!", "", close, ignore_invalid_symbol=true)
mes_price = request.security("CME_MINI:MES1!", "", close, ignore_invalid_symbol=true)

// ============================================
// 3. 5-Minute Basis Lock Logic
// ============================================
var float basis_spy = na
var float basis_es  = na
var float basis_mes = na

var int last_update_time = 0
is_update_bar = (time - last_update_time) >= (update_minutes * 60 * 1000) or last_update_time == 0

if is_update_bar and not na(spx_price)
    last_update_time := time
    
    if not na(spy_price) and math.abs(spx_price - (spy_price * 10.0)) < 500
        locked_basis_spy = spx_price - (spy_price * 10.0)
        basis_spy := locked_basis_spy
        
    if not na(es_price) and math.abs(es_price - spx_price) < 500
        locked_basis_es = es_price - spx_price
        basis_es := locked_basis_es
        
    if not na(mes_price) and math.abs(mes_price - spx_price) < 500
        locked_basis_mes = mes_price - spx_price
        basis_mes := locked_basis_mes

// ============================================
// 4. Premium Transparent Light Theme (For White Charts)
// ============================================
color_bg_main     = color.new(#f0f3fa, 85)  // 霧面透明冷白底色
color_bg_header   = color.new(#e0e3eb, 70)  // 半透明表頭
color_border      = color.new(#e0e3eb, 50)  // 空氣感邊框

color_text_muted  = color.new(#6a6d78, 0)   // 質感碳灰 (表頭)
color_text_bright = color.new(#131722, 0)   // 深藍灰 (公式與市價)

color_positive    = color.new(#00897b, 0)   // 高級翡翠綠 (正基差)
color_negative    = color.new(#b71c1c, 0)   // 高級酒紅 (負基差)

// ============================================
// 5. Draw Info Table (English Version)
// ============================================
var table info_table = na
if barstate.islast
    info_table := table.new(position=pos, columns=3, rows=4, bgcolor=color_bg_main, border_width=1, border_color=color_border)
    
    // --- Header (Row 0) ---
    table.cell(info_table, 0, 0, "Formula", text_color=color_text_muted, bgcolor=color_bg_header, text_size=size.normal)
    table.cell(info_table, 1, 0, "Market Price", text_color=color_text_muted, bgcolor=color_bg_header, text_size=size.normal)
    table.cell(info_table, 2, 0, str.tostring(update_minutes) + "m Basis", text_color=color_text_muted, bgcolor=color_bg_header, text_size=size.normal)
    
    // --- SPY Row (Row 1) ---
    table.cell(info_table, 0, 1, "SPX - (SPY × 10)", text_color=color_text_bright, text_size=size.normal, text_halign=text.align_left)
    spy_price_text = f_truncate_2d(spx_price) + " / " + f_truncate_2d(spy_price)
    table.cell(info_table, 1, 1, spy_price_text, text_color=color_text_bright, text_size=size.normal, text_halign=text.align_center)
    spy_color = na(basis_spy) ? color_text_muted : (basis_spy >= 0 ? color_positive : color_negative)
    table.cell(info_table, 2, 1, na(basis_spy) ? "Calc..." : f_truncate_2d_with_sign(basis_spy), text_color=spy_color, text_size=size.normal, text_halign=text.align_right)
    
    // --- ES! Row (Row 2) ---
    table.cell(info_table, 0, 2, "ES! - SPX", text_color=color_text_bright, text_size=size.normal, text_halign=text.align_left)
    table.cell(info_table, 1, 2, f_truncate_2d(es_price), text_color=color_text_bright, text_size=size.normal, text_halign=text.align_center)
    es_color = na(basis_es) ? color_text_muted : (basis_es >= 0 ? color_positive : color_negative)
    table.cell(info_table, 2, 2, na(basis_es) ? "Calc..." : f_truncate_2d_with_sign(basis_es), text_color=es_color, text_size=size.normal, text_halign=text.align_right)
    
    // --- MES! Row (Row 3) ---
    table.cell(info_table, 0, 3, "MES! - SPX", text_color=color_text_bright, text_size=size.normal, text_halign=text.align_left)
    table.cell(info_table, 1, 3, f_truncate_2d(mes_price), text_color=color_text_bright, text_size=size.normal, text_halign=text.align_center)
    mes_color = na(basis_mes) ? color_text_muted : (basis_mes >= 0 ? color_positive : color_negative)
    table.cell(info_table, 2, 3, na(basis_mes) ? "Calc..." : f_truncate_2d_with_sign(basis_mes), text_color=mes_color, text_size=size.normal, text_halign=text.align_right)
````
