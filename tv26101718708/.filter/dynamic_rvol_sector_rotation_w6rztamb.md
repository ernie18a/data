# Dynamic RVOL Sector Rotation

- url: https://www.tradingview.com/script/W6rzTAmb-Dynamic-RVOL-Sector-Rotation/
- type: indicator
- pine_id: PUB;3f34168d14f14ba3afced22429486430
- version: 1.0

## Description

The Concept: Tracking Institutional Capital Flow
The market is a constant game of musical chairs. Capital doesn't just leave the market; it rotates. When institutions dump Tech (XLK), they are usually parking that capital into defensive sectors like Utilities (XLU) or Healthcare (XLV).

The problem most retail traders face is that they don't spot this rotation until the financial news reports on it hours later. By then, the move has already been made, and the options premiums are blown out.

The Dynamic RVOL Sector Rotation Dashboard was built to solve this. It tracks the 11 major SPDR Sector ETFs simultaneously, scanning for unusual Relative Volume (RVOL) spikes and cross-referencing them against daily trends and daily ATR exhaustion. It dynamically auto-sorts the data on every tick, pushing the sector with the most aggressive capital inflow directly to the top of your screen.

How the Engine Works
This indicator leverages Pine Script v6 arrays to process 44 different data points in real-time. It completely detaches from your active chart's timeframe, allowing you to day-trade on a 1-minute chart while the engine quietly hunts for macro hourly or daily rotations in the background.

The dashboard tracks 5 key metrics:

SECTOR: The 11 core SPDR ETFs (XLK, XLY, XLC, XLF, XLV, XLI, XLE, XLP, XLRE, XLB, XLU).

RVOL (Relative Volume): Compares current volume to the historical moving average. When a sector hits >= 1.5x normal volume, the cell turns Yellow to flag institutional activity.

% CHG: Standard intraday price change.

% ATR (Average True Range Exhaustion): This is the options pricing filter. It calculates how far the daily candle has traveled compared to its normal 14-day ATR. If a sector has already moved 80%+ of its normal daily range, the cell turns Orange, warning you that the move is mathematically exhausted and options premiums are heavily inflated.

TREND: Pulls the Daily 21 EMA to confirm macro direction. If the intraday volume spike aligns with the macro trend, it prints UP (Green). If it is counter-trend, it prints DOWN (Red).

The Playbook (How to Trade It)
Do not buy blindly just because a sector hits the top of the list. Look for data confluence:

The Golden Setup (Continuation): A sector snaps to the top row. RVOL is Yellow (Capital is flowing in). Trend is UP (Aligning with the macro trend). % ATR is White (Under 80% — the move still has room to run). This indicates a high-probability rotation with reasonable options premiums.

The Premium Trap (Exhaustion): A sector hits the top with massive Yellow RVOL, but the % ATR column is Orange (Over 80%). The move is valid, but the daily fuel is gone. Avoid chasing straight long calls here; look for pullbacks or structured spreads.

The Fakeout (Short Covering): A sector spikes to the top with Green price action and Yellow RVOL, but the Trend column is DOWN. This is likely a dead-cat bounce or short-covering rally, not a true macro rotation. Look to short the intraday pop at resistance.

Customization & Alerts

Fully Resizable & Movable: Use the settings menu to snap the dashboard to any corner of your screen and adjust the text size.

Independent Timeframes: You can decouple the scanner from your chart. Set the scanner to look for 1-Hour rotations while you trade on a 5-minute chart.

The "Golden Setup" Alert Engine: You don't need to stare at the screen. Create an alert for this indicator, select "Any alert() function call", and the script will dynamically ping you with a text message (e.g., "GOLDEN SETUP DETECTED: Capital rotating into XLI") ONLY when a sector perfectly aligns with high RVOL, green price action, safe ATR, and an upward macro trend.

Disclaimer: This script is an educational tool for tracking volume and statistical data. It is not financial advice. Always do your own due diligence before deploying capital.

## Source Code

````pine
//@version=6
indicator("Dynamic RVOL Sector Rotation", overlay=true)

// =========================================================================
// 1. INPUTS & SETUP
// =========================================================================
scanTF    = input.timeframe("", title="Scanner Timeframe (Empty = Chart TF)", tooltip="Timeframe for the RVOL and % Change. Leave empty to follow your active chart.")
macroTF   = input.timeframe("D", title="Macro Filter Timeframe", tooltip="Timeframe for the ATR Exhaustion and Trend Filter (e.g., 'D' for Daily, 'W' for Weekly).")

volLength = input.int(20, title="RVOL Moving Average Length")
rvolAlert = input.float(1.5, title="RVOL Highlight Threshold", step=0.1)

atrLength = input.int(14, title="Macro ATR Length")
atrAlert  = input.float(80.0, title="ATR Exhaustion Alert (%)", tooltip="Highlights when a sector has moved this percentage of its macro range.")

emaLength = input.int(21, title="Macro EMA Trend Length")

dashPos   = input.string("middle_right", title="Dashboard Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"])
textSize  = input.string("small", title="Text Size", options=["auto", "tiny", "small", "normal", "large", "huge"])

// =========================================================================
// 2. DATA CALCULATION FUNCTION
// =========================================================================
f_get_sector_data(sym) =>
    [c, c_prev, v, v_avg] = request.security(sym, scanTF, [close, close[1], volume, ta.sma(volume, volLength)])
    [m_c, m_c_prev, m_atr, m_ema] = request.security(sym, macroTF, [close, close[1], ta.atr(atrLength), ta.ema(close, emaLength)])
    
    safe_v_avg = v_avg == 0 ? 1 : v_avg
    rvol = v / safe_v_avg
    pct_chg = ((c - c_prev) / c_prev) * 100
    
    travel = math.abs(m_c - m_c_prev)
    safe_atr = m_atr == 0 ? 1 : m_atr
    atr_pct = (travel / safe_atr) * 100
    
    is_bullish = c > m_ema ? 1 : -1
    
    [rvol, pct_chg, atr_pct, is_bullish]

// =========================================================================
// 3. PULLING THE SECTOR DATA
// =========================================================================
[r_xlk, p_xlk, a_xlk, t_xlk]   = f_get_sector_data("AMEX:XLK")
[r_xly, p_xly, a_xly, t_xly]   = f_get_sector_data("AMEX:XLY")
[r_xlc, p_xlc, a_xlc, t_xlc]   = f_get_sector_data("AMEX:XLC")
[r_xlf, p_xlf, a_xlf, t_xlf]   = f_get_sector_data("AMEX:XLF")
[r_xlv, p_xlv, a_xlv, t_xlv]   = f_get_sector_data("AMEX:XLV")
[r_xli, p_xli, a_xli, t_xli]   = f_get_sector_data("AMEX:XLI")
[r_xle, p_xle, a_xle, t_xle]   = f_get_sector_data("AMEX:XLE")
[r_xlp, p_xlp, a_xlp, t_xlp]   = f_get_sector_data("AMEX:XLP")
[r_xlre, p_xlre, a_xlre, t_xlre] = f_get_sector_data("AMEX:XLRE")
[r_xlb, p_xlb, a_xlb, t_xlb]   = f_get_sector_data("AMEX:XLB")
[r_xlu, p_xlu, a_xlu, t_xlu]   = f_get_sector_data("AMEX:XLU")

// =========================================================================
// 4. ARRAYS & DYNAMIC TABLE GENERATION
// =========================================================================
var table dash = table.new(dashPos, 5, 12, bgcolor=color.rgb(15, 15, 15, 20), border_width=1, border_color=color.rgb(80, 80, 80))

if barstate.islast
    a_names = array.from("XLK (Tech)", "XLY (Cons Disc)", "XLC (Comm)", "XLF (Financials)", "XLV (Health)", "XLI (Industrials)", "XLE (Energy)", "XLP (Staples)", "XLRE (Real Est)", "XLB (Materials)", "XLU (Utilities)")
    a_rvol  = array.from(r_xlk, r_xly, r_xlc, r_xlf, r_xlv, r_xli, r_xle, r_xlp, r_xlre, r_xlb, r_xlu)
    a_pct   = array.from(p_xlk, p_xly, p_xlc, p_xlf, p_xlv, p_xli, p_xle, p_xlp, p_xlre, p_xlb, p_xlu)
    a_atr   = array.from(a_xlk, a_xly, a_xlc, a_xlf, a_xlv, a_xli, a_xle, a_xlp, a_xlre, a_xlb, a_xlu)
    a_trend = array.from(t_xlk, t_xly, t_xlc, t_xlf, t_xlv, t_xli, t_xle, t_xlp, t_xlre, t_xlb, t_xlu)

    a_indices = array.sort_indices(a_rvol, order.descending)

    table.cell(dash, 0, 0, "SECTOR", text_color=color.gray, text_halign=text.align_left, text_size=textSize)
    table.cell(dash, 1, 0, "RVOL", text_color=color.gray, text_size=textSize)
    table.cell(dash, 2, 0, "% CHG", text_color=color.gray, text_size=textSize)
    table.cell(dash, 3, 0, "% ATR", text_color=color.gray, text_size=textSize)
    table.cell(dash, 4, 0, "TREND", text_color=color.gray, text_size=textSize)

    for i = 0 to 10
        idx = array.get(a_indices, i)
        name_val  = array.get(a_names, idx)
        rvol_val  = array.get(a_rvol, idx)
        pct_val   = array.get(a_pct, idx)
        atr_val   = array.get(a_atr, idx)
        trend_val = array.get(a_trend, idx)
        
        c_rvol = rvol_val >= rvolAlert ? color.rgb(255, 235, 59) : color.white
        c_pct  = pct_val > 0 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
        c_atr  = atr_val >= atrAlert ? color.rgb(255, 152, 0) : color.white
        c_trend = trend_val == 1 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
        t_text  = trend_val == 1 ? "UP" : "DOWN"
        
        row = i + 1
        table.cell(dash, 0, row, name_val, text_color=color.white, text_halign=text.align_left, text_size=textSize)
        table.cell(dash, 1, row, str.tostring(rvol_val, "#.##"), text_color=c_rvol, text_size=textSize)
        table.cell(dash, 2, row, str.tostring(pct_val, "#.##") + "%", text_color=c_pct, text_size=textSize)
        table.cell(dash, 3, row, str.tostring(atr_val, "#.##") + "%", text_color=c_atr, text_size=textSize)
        table.cell(dash, 4, row, t_text, text_color=c_trend, text_size=textSize)

// =========================================================================
// 5. AUTOMATED ALERT ENGINE (The Golden Setup)
// =========================================================================
// Define the logic function in the global scope (Outside the 'if' block)
f_check_golden(sym_name, rvol, pct, atr, trend) =>
    (rvol >= rvolAlert) and (pct > 0) and (atr < atrAlert) and (trend == 1) ? sym_name + " " : ""

// Only process alerts on live, real-time bars to prevent historical spam
if barstate.isrealtime
    string alert_msg = ""
    
    alert_msg += f_check_golden("XLK", r_xlk, p_xlk, a_xlk, t_xlk)
    alert_msg += f_check_golden("XLY", r_xly, p_xly, a_xly, t_xly)
    alert_msg += f_check_golden("XLC", r_xlc, p_xlc, a_xlc, t_xlc)
    alert_msg += f_check_golden("XLF", r_xlf, p_xlf, a_xlf, t_xlf)
    alert_msg += f_check_golden("XLV", r_xlv, p_xlv, a_xlv, t_xlv)
    alert_msg += f_check_golden("XLI", r_xli, p_xli, a_xli, t_xli)
    alert_msg += f_check_golden("XLE", r_xle, p_xle, a_xle, t_xle)
    alert_msg += f_check_golden("XLP", r_xlp, p_xlp, a_xlp, t_xlp)
    alert_msg += f_check_golden("XLRE", r_xlre, p_xlre, a_xlre, t_xlre)
    alert_msg += f_check_golden("XLB", r_xlb, p_xlb, a_xlb, t_xlb)
    alert_msg += f_check_golden("XLU", r_xlu, p_xlu, a_xlu, t_xlu)

    // If any sector met the criteria, trigger the alert
    if str.length(alert_msg) > 0
        // Fires only once per bar close to ensure the candle is fully formed and not a mid-bar fakeout
        alert("GOLDEN SETUP DETECTED: Capital rotating into " + alert_msg, alert.freq_once_per_bar_close)
````
