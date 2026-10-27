# Moneyball MTF Trend Databox [VinnieTheFish]

- url: https://www.tradingview.com/script/j4FShSAs-Moneyball-MTF-Trend-Databox-VinnieTheFish/
- type: indicator
- pine_id: PUB;db1670cc35a74a9e8ad96b3c00108b6f
- version: 1.0

## Description

📊 Moneyball MTF Trend Databox [VinnieTheFish]

The Moneyball MTF Trend Databox is a powerful, lightweight companion dashboard designed specifically to complement the core Moneyball EMA-MACD indicator [VinnieTheFish] ecosystem.

When trading with the Moneyball strategy, keeping track of higher and lower timeframe market structures is vital. Instead of manually flipping through charts, this utility aggregates a comprehensive multi-timeframe (MTF) trend analysis across 8 critical timeframes simultaneously and packs them into a clean, customizable HUD directly on your current chart.

🔍 How It Works

The engine dynamically evaluates the current asset’s trend alignment using a single master trend filter of your choice. A timeframe is marked as BULLISH if the price is trading above your selected Moving Average, and BEARISH if it falls below.

By looking at the dashboard, you can instantly see if your lower-timeframe execution aligns with the higher-timeframe "macro" trend.

⚙️ Key Features:

8 Timeframe Coverage: Scans the 2m, 5m, 15m, 30m, 1h, 4h, Daily, and Weekly intervals concurrently.

4-in-1 Trend Filters: Choose your preferred trend line directly from the settings:

SMA (Simple Moving Average)

EMA (Exponential Moving Average)

DEMA (Double EMA - for faster response time)

TEMA (Triple EMA - ultra-low lag trend tracking)

Fully Customizable Display: Position the dashboard anywhere on your chart (Top Right, Bottom Left, etc.) and fine-tune the background opacity so it never obstructs your price action or candlesticks.

Optimized Execution (Pine Script v6): Built natively on TradingView's newest engine version. The table updates strictly on the live bar (barstate.islast), completely protecting your charts from browser lag or slow calculation times.

📈 How to Use This in Your Trading

Macro-Trend Alignment: Before taking a Moneyball buy or sell signal on your execution chart (e.g., the 5-minute), check the Databox. If the 1H, 4H, and Daily rows are screaming BULLISH, you have massive high-probability wind at your back for long positions.

Confluence Clustering: Look for moments when all (or most) timeframes switch to a single color. A full grid alignment often signals a massive breakout or a strong continuation wave.

Counter-Trend Warning: If you see a buy signal on your lower timeframe but the higher timeframes are strictly BEARISH, the dashboard acts as an early warning system to either pass on the trade or take quick, conservative profits.

🛠️ Recommended Setup

For the truest "Moneyball" alignment, set your configuration input to:

MA Length: 200

MA Type: EMA or DEMA

Pair this dashboard on your layout with the primary Moneyball EMA-MACD indicator [VinnieTheFish] oscillator to experience the full synergy of the trend-following system.

## Source Code

````pine
//@version=6
indicator("Moneyball MTF Trend Databox", overlay=true)

// ============================================================
// 1. INPUTS & CONFIGURATION
// ============================================================
grpMA      = "Moving Average Configuration"
ma_len     = input.int(200, title="MA Length", minval=1, group=grpMA, tooltip="Set the period length for your trend engine (e.g., 50, 200).")
ma_type    = input.string("EMA", title="MA Type", options=["SMA", "EMA", "DEMA", "TEMA"], group=grpMA, tooltip="DMA maps to DEMA; TMA maps to TEMA.")

grpVisual  = "Dashboard Display Settings"
dashPos    = input.string("Top Right", title="Dashboard Position", options=["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Left", "Bottom Center"], group=grpVisual)
bgOpacity  = input.int(15, title="Background Opacity (0-100)", minval=0, maxval=100, group=grpVisual)

// ============================================================
// 2. MULTI-TIMEFRAME ENGINE
// ============================================================
check_trend() =>
    sma_val  = ta.sma(close, ma_len)
    ema_val  = ta.ema(close, ma_len)
    
    // DEMA (Double EMA) Calculation
    dema_e1  = ta.ema(close, ma_len)
    dema_e2  = ta.ema(dema_e1, ma_len)
    dema_val = (2 * dema_e1) - dema_e2
    
    // TEMA (Triple EMA) Calculation
    tema_e1  = ta.ema(close, ma_len)
    tema_e2  = ta.ema(tema_e1, ma_len)
    tema_e3  = ta.ema(tema_e2, ma_len)
    tema_val = (3 * tema_e1) - (3 * tema_e2) + tema_e3
    
    // Version 6 native switch block completely eliminates line-wrap syntax issues
    target_ma = switch ma_type
        "SMA"  => sma_val
        "EMA"  => ema_val
        "DEMA" => dema_val
        => tema_val
                
    close > target_ma

// Fetching the trend status across all 8 requested timeframes
trend_2m  = request.security(syminfo.tickerid, "2",   check_trend())
trend_5m  = request.security(syminfo.tickerid, "5",   check_trend())
trend_15m = request.security(syminfo.tickerid, "15",  check_trend())
trend_30m = request.security(syminfo.tickerid, "30",  check_trend())
trend_1h  = request.security(syminfo.tickerid, "60",  check_trend())
trend_4h  = request.security(syminfo.tickerid, "240", check_trend())
trend_d   = request.security(syminfo.tickerid, "D",   check_trend())
trend_w   = request.security(syminfo.tickerid, "W",   check_trend())

// ============================================================
// 3. TABLE GENERATION (DASHBOARD DRAWING)
// ============================================================
// Explicitly mapping positioning using v6 clean layout structure
tblPos = switch dashPos
    "Top Right"     => position.top_right
    "Top Center"    => position.top_center
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Center" => position.bottom_center
    => position.bottom_left

var table dashTable = table.new(tblPos, 2, 9, bgcolor=color.new(color.black, bgOpacity), border_width=1, border_color=color.gray)

// Row styling helper function unwrapped to protect compiler processing limits
update_row(table tbl, int row_idx, string tf_name, bool is_bullish) =>
    txt     = is_bullish ? "BULLISH" : "BEARISH"
    txt_col = is_bullish ? color.lime : color.red
    bg_col  = is_bullish ? color.new(color.green, 85) : color.new(color.red, 85)
    table.cell(tbl, 0, row_idx, tf_name, text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, row_idx, txt, text_color=txt_col, bgcolor=bg_col, text_size=size.small)

// Only render on the live bar to optimize chart calculations
if barstate.islast
    table.cell(dashTable, 0, 0, "Timeframe", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    table.cell(dashTable, 1, 0, ma_type + " (" + str.tostring(ma_len) + ")", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=size.small)
    
    update_row(dashTable, 1, "2 Min",  trend_2m)
    update_row(dashTable, 2, "5 Min",  trend_5m)
    update_row(dashTable, 3, "15 Min", trend_15m)
    update_row(dashTable, 4, "30 Min", trend_30m)
    update_row(dashTable, 5, "1 Hour", trend_1h)
    update_row(dashTable, 6, "4 Hour", trend_4h)
    update_row(dashTable, 7, "Daily",  trend_d)
    update_row(dashTable, 8, "Weekly", trend_w)
````
