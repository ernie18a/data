# The Apex Stalker: RVOL & Options Sniper

- url: https://www.tradingview.com/script/8DodEu0q-The-Apex-Stalker-RVOL-Options-Sniper/
- type: indicator
- pine_id: PUB;b387d256be6344afa3cdc62d39d420db
- version: 1.0

## Description

The Concept: Hunting Volatility & Mean Reversion
Most retail traders are reactive. They see a massive green candle on the scanner, chase the breakout blindly, and end up buying the exact top just as institutions start taking profits.

The Apex Stalker is a tactical dashboard built to prevent that. It allows active options and equity traders to stalk a customized watchlist of up to 10 tickers, hunting for two specific, high-probability setups:

The Sniper Entry (Continuation): Catching the exact moment institutional volume steps in to drive a trend.

The Exhaustion Fade (Mean Reversion): Flagging when a momentum stock has mathematically exhausted its normal daily fuel, making it a prime target for a fade or credit spread.

How the Engine Works
This indicator completely detaches from your active chart's timeframe, allowing you to day-trade on a 1-minute chart while the engine quietly hunts for macro hourly or daily setups in the background. It dynamically auto-sorts your watchlist on every tick based on Relative Volume (RVOL).

The dashboard tracks 4 core metrics for each ticker:

RVOL (Relative Volume): Compares current volume to the historical average. When a ticker hits >= 1.5x normal volume, the cell turns Yellow to flag institutional activity.

% ATR (Average True Range Exhaustion): Calculates how far the current candle has traveled compared to its normal 14-day ATR.

TREND: Pulls the Daily 21 EMA. If the intraday price action aligns with the macro trend, it prints UP (Green). If it is counter-trend, it prints DOWN (Red).

The Playbook (How to Trade It)

Setup 1: The Golden Continuation: A ticker snaps to the top of your list. RVOL is Yellow (Capital is flowing in). Trend is UP. Importantly, the % ATR is White (meaning the move still has plenty of room to run before exhausting its daily range). This is a high-probability continuation setup where options premiums are still reasonably priced.

Setup 2: The Mean Reversion Fade: A ticker hits the top with massive Yellow RVOL, but the % ATR column is Orange. The move is valid, but the daily fuel is gone. Options premiums here are heavily inflated. Do not buy straight calls; look for an intraday structural breakdown to short the pop or sell credit spreads.
(Note: Use the settings to adjust your Exhaustion Threshold. Set indices like SPY to ~100% ATR, but give high-beta tech stocks a wider leash of ~130%-150% before fading).

Customization & Dual Alerts

Your Watchlist: Swap out the default tickers for whatever you are actively trading directly in the settings menu.

The Dual Alert Engine: Create a single alert for this indicator ("Any alert() function call"). The script will dynamically ping your phone with a custom text message specifically telling you if a ticker has triggered a "🟢 SNIPER ENTRY" (High Volume + Room to Run) or a "🔴 EXHAUSTION FADE" (High Volume + Premium Blown Out).

Disclaimer: This script is an educational tool for tracking volume and statistical data. It is not financial advice. Always do your own due diligence before deploying capital.

## Source Code

````pine
//@version=6
indicator("The Apex Stalker: RVOL & Options Sniper", overlay=true)

// =========================================================================
// 1. INPUTS & SETUP
// =========================================================================
scanTF    = input.timeframe("", title="Scanner Timeframe (Empty = Chart TF)")
macroTF   = input.timeframe("D", title="Macro Filter Timeframe")

volLength = input.int(20, title="RVOL Moving Average Length")
rvolAlert = input.float(1.5, title="RVOL Highlight Threshold", step=0.1)

atrLength = input.int(14, title="Macro ATR Length")
atrAlert  = input.float(80.0, title="ATR Premium Warning (%)", tooltip="Turns orange when options premium is heavily inflated.")

// --- NEW: Exhaustion Alert Input ---
exhaustAlert = input.float(100.0, title="ATR Mean Reversion Threshold (%)", tooltip="Triggers the Exhaustion Alert when ATR hits this level with high volume.")

emaLength = input.int(21, title="Macro EMA Trend Length")

dashPos   = input.string("middle_right", title="Dashboard Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"])
textSize  = input.string("small", title="Text Size", options=["auto", "tiny", "small", "normal", "large", "huge"])

// Custom Watchlist Inputs
sym1  = input.symbol("NASDAQ:MRVL", title="Ticker 1", group="Watchlist")
sym2  = input.symbol("NYSE:BE",     title="Ticker 2", group="Watchlist")
sym3  = input.symbol("NASDAQ:NVDA", title="Ticker 3", group="Watchlist")
sym4  = input.symbol("NASDAQ:TSLA", title="Ticker 4", group="Watchlist")
sym5  = input.symbol("NASDAQ:PLTR", title="Ticker 5", group="Watchlist")
sym6  = input.symbol("NASDAQ:AMD",  title="Ticker 6", group="Watchlist")
sym7  = input.symbol("NASDAQ:AAPL", title="Ticker 7", group="Watchlist")
sym8  = input.symbol("NASDAQ:COIN", title="Ticker 8", group="Watchlist")
sym9  = input.symbol("AMEX:SPY",    title="Ticker 9", group="Watchlist")
sym10 = input.symbol("NASDAQ:QQQ",  title="Ticker 10", group="Watchlist")

// =========================================================================
// 2. DATA CALCULATION FUNCTION
// =========================================================================
f_get_data(sym) =>
    [c, c_prev, v, v_avg, t_name] = request.security(sym, scanTF, [close, close[1], volume, ta.sma(volume, volLength), syminfo.ticker])
    [m_c, m_c_prev, m_atr, m_ema] = request.security(sym, macroTF, [close, close[1], ta.atr(atrLength), ta.ema(close, emaLength)])
    
    safe_v_avg = v_avg == 0 ? 1 : v_avg
    rvol = v / safe_v_avg
    pct_chg = ((c - c_prev) / c_prev) * 100
    
    travel = math.abs(m_c - m_c_prev)
    safe_atr = m_atr == 0 ? 1 : m_atr
    atr_pct = (travel / safe_atr) * 100
    
    is_bullish = c > m_ema ? 1 : -1
    
    [t_name, rvol, pct_chg, atr_pct, is_bullish]

// =========================================================================
// 3. PULLING THE WATCHLIST DATA
// =========================================================================
[n1, r1, p1, a1, t1] = f_get_data(sym1)
[n2, r2, p2, a2, t2] = f_get_data(sym2)
[n3, r3, p3, a3, t3] = f_get_data(sym3)
[n4, r4, p4, a4, t4] = f_get_data(sym4)
[n5, r5, p5, a5, t5] = f_get_data(sym5)
[n6, r6, p6, a6, t6] = f_get_data(sym6)
[n7, r7, p7, a7, t7] = f_get_data(sym7)
[n8, r8, p8, a8, t8] = f_get_data(sym8)
[n9, r9, p9, a9, t9] = f_get_data(sym9)
[n10, r10, p10, a10, t10] = f_get_data(sym10)

// =========================================================================
// 4. ARRAYS & DYNAMIC TABLE GENERATION
// =========================================================================
var table dash = table.new(dashPos, 5, 11, bgcolor=color.rgb(15, 15, 15, 20), border_width=1, border_color=color.rgb(80, 80, 80))

if barstate.islast
    a_names = array.from(n1, n2, n3, n4, n5, n6, n7, n8, n9, n10)
    a_rvol  = array.from(r1, r2, r3, r4, r5, r6, r7, r8, r9, r10)
    a_pct   = array.from(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
    a_atr   = array.from(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    a_trend = array.from(t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)

    a_indices = array.sort_indices(a_rvol, order.descending)

    table.cell(dash, 0, 0, "TICKER", text_color=color.gray, text_halign=text.align_left, text_size=textSize)
    table.cell(dash, 1, 0, "RVOL", text_color=color.gray, text_size=textSize)
    table.cell(dash, 2, 0, "% CHG", text_color=color.gray, text_size=textSize)
    table.cell(dash, 3, 0, "% ATR", text_color=color.gray, text_size=textSize)
    table.cell(dash, 4, 0, "TREND", text_color=color.gray, text_size=textSize)

    for i = 0 to 9
        idx = array.get(a_indices, i)
        
        name_val  = array.get(a_names, idx)
        rvol_val  = array.get(a_rvol, idx)
        pct_val   = array.get(a_pct, idx)
        atr_val   = array.get(a_atr, idx)
        trend_val = array.get(a_trend, idx)
        
        c_rvol = rvol_val >= rvolAlert ? color.rgb(255, 235, 59) : color.white
        c_pct  = pct_val > 0 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
        c_atr  = atr_val >= atrAlert ? color.rgb(255, 152, 0) : color.white // Still turns orange at 80% to warn you
        c_trend = trend_val == 1 ? color.rgb(76, 175, 80) : color.rgb(244, 67, 54)
        t_text  = trend_val == 1 ? "UP" : "DOWN"
        
        row = i + 1
        table.cell(dash, 0, row, name_val, text_color=color.white, text_halign=text.align_left, text_size=textSize)
        table.cell(dash, 1, row, str.tostring(rvol_val, "#.##"), text_color=c_rvol, text_size=textSize)
        table.cell(dash, 2, row, str.tostring(pct_val, "#.##") + "%", text_color=c_pct, text_size=textSize)
        table.cell(dash, 3, row, str.tostring(atr_val, "#.##") + "%", text_color=c_atr, text_size=textSize)
        table.cell(dash, 4, row, t_text, text_color=c_trend, text_size=textSize)

// =========================================================================
// 5. DUAL ALERT ENGINE (Golden Setup & Mean Reversion)
// =========================================================================
// Engine 1: The Golden Setup (High RVOL, Green, Safe ATR, Macro Trend UP)
f_check_golden(sym_name, rvol, pct, atr, trend) =>
    (rvol >= rvolAlert) and (pct > 0) and (atr < atrAlert) and (trend == 1) ? sym_name + " " : ""

// Engine 2: The Exhaustion / Mean Reversion Trap (High RVOL, Blown out ATR)
f_check_exhaustion(sym_name, rvol, atr) =>
    (rvol >= rvolAlert) and (atr >= exhaustAlert) ? sym_name + " " : ""

if barstate.isrealtime
    string golden_msg = ""
    string exhaust_msg = ""
    
    // Check all tickers for Golden Setup
    golden_msg += f_check_golden(n1, r1, p1, a1, t1)
    golden_msg += f_check_golden(n2, r2, p2, a2, t2)
    golden_msg += f_check_golden(n3, r3, p3, a3, t3)
    golden_msg += f_check_golden(n4, r4, p4, a4, t4)
    golden_msg += f_check_golden(n5, r5, p5, a5, t5)
    golden_msg += f_check_golden(n6, r6, p6, a6, t6)
    golden_msg += f_check_golden(n7, r7, p7, a7, t7)
    golden_msg += f_check_golden(n8, r8, p8, a8, t8)
    golden_msg += f_check_golden(n9, r9, p9, a9, t9)
    golden_msg += f_check_golden(n10, r10, p10, a10, t10)

    // Check all tickers for Mean Reversion
    exhaust_msg += f_check_exhaustion(n1, r1, a1)
    exhaust_msg += f_check_exhaustion(n2, r2, a2)
    exhaust_msg += f_check_exhaustion(n3, r3, a3)
    exhaust_msg += f_check_exhaustion(n4, r4, a4)
    exhaust_msg += f_check_exhaustion(n5, r5, a5)
    exhaust_msg += f_check_exhaustion(n6, r6, a6)
    exhaust_msg += f_check_exhaustion(n7, r7, a7)
    exhaust_msg += f_check_exhaustion(n8, r8, a8)
    exhaust_msg += f_check_exhaustion(n9, r9, a9)
    exhaust_msg += f_check_exhaustion(n10, r10, a10)

    // Trigger Golden Alert
    if str.length(golden_msg) > 0
        alert("🟢 SNIPER ENTRY | Target Acquisition: " + golden_msg, alert.freq_once_per_bar_close)

    // Trigger Exhaustion Alert
    if str.length(exhaust_msg) > 0
        alert("🔴 EXHAUSTION FADE | Premium Blown Out on: " + exhaust_msg, alert.freq_once_per_bar_close)
````
