# Mark Minervini's Trend Template for CNX500/Nifty500 stocks(v6)

- url: https://www.tradingview.com/script/V2iPjXyp-Mark-Minervini-s-Trend-Template-for-CNX500-Nifty500-stocks-v6/
- type: indicator
- pine_id: PUB;e047e0d8fee44d2c9274a206d96b49bd
- version: 2.0

## Description

Mark Minervini's Trend Template with benchmark index as CNX500/Nifty500

## Source Code

````pine
//@version=6
indicator("Mark Minervini Trend Template (Locked Daily Filters v6)", overlay=true)

// ==========================================
// 1. INPUTS & POSITION CONTROLS
// ==========================================
srcInput       = input.source(close, title="Price Source")
maType         = input.string("SMA", title="Moving Average Type", options=["SMA", "EMA"])
table_y_offset = input.int(2, title="Table Position Lift (Upside)", minval=0, maxval=10)

// ==========================================
// 2. FORCED DAILY TIMEFRAME FETCHING ("1D")
// ==========================================
getDailyMA(string type, float src, int length) =>
    maSeries = (type == "SMA") ? ta.sma(src, length) : ta.ema(src, length)
    request.security(syminfo.tickerid, "1D", maSeries, barmerge.gaps_off, barmerge.lookahead_off)

daily_close = request.security(syminfo.tickerid, "1D", srcInput, barmerge.gaps_off, barmerge.lookahead_off)
daily_ma50  = getDailyMA(maType, close, 50)
daily_ma150 = getDailyMA(maType, close, 150)
daily_ma200 = getDailyMA(maType, close, 200)

// Force the 200 Daily MA trend check (20 trading days = 1 month of time)
ma200_past_series = ta.sma(close, 200)[20]
ma200_past   = request.security(syminfo.tickerid, "1D", ma200_past_series, barmerge.gaps_off, barmerge.lookahead_off)
ma200_trending_up = daily_ma200 > ma200_past

// Force the 52-Week (252 Trading Days) Channels to remain Daily
daily_high52 = request.security(syminfo.tickerid, "1D", ta.highest(high, 252), barmerge.gaps_off, barmerge.lookahead_off)
daily_low52  = request.security(syminfo.tickerid, "1D", ta.lowest(low, 252), barmerge.gaps_off, barmerge.lookahead_off)

// ==========================================
// 3. RS PERFORMANCE LIFT FROM 52-WEEK LOW (VS NIFTY 500)
// ==========================================
// 1. Calculate how much your stock has gained from its own 52-week low
stock_gain_from_low = daily_low52 != 0.0 ? ((daily_close - daily_low52) / daily_low52) * 100.0 : 0.0

// 2. Track the Nifty 500 Index performance over the same 52-week period
cnx500_close = request.security("NSE:CNX500", "1D", close, barmerge.gaps_off, barmerge.lookahead_off)
cnx500_low52 = request.security("NSE:CNX500", "1D", ta.lowest(low, 252), barmerge.gaps_off, barmerge.lookahead_off)
cnx500_gain_from_low = cnx500_low52 != 0.0 ? ((cnx500_close - cnx500_low52) / cnx500_low52) * 100.0 : 0.0

// 3. The RS score measures the structural outperformance margin between the stock and index 
float relative_strength_score = stock_gain_from_low - cnx500_gain_from_low

// True if the stock has outpaced the Nifty 500 by at least 60% from the bottom
bool rs_is_strong = relative_strength_score >= 60.0

// ==========================================
// 4. TREND TEMPLATE EVALUATION METHOD
// ==========================================
int c1 = (daily_close > daily_ma150) ? 1 : 0
int c2 = (daily_close > daily_ma200) ? 1 : 0
int c3 = (daily_ma150 > daily_ma200) ? 1 : 0
int c4 = ma200_trending_up ? 1 : 0
int c5 = (daily_ma50 > daily_ma150 and daily_ma50 > daily_ma200) ? 1 : 0
int c6 = (daily_close > daily_ma50) ? 1 : 0
int c7 = (daily_close >= (daily_low52 * 1.25)) ? 1 : 0
int c8 = (daily_close >= (daily_high52 * 0.75)) ? 1 : 0
int c9 = rs_is_strong ? 1 : 0 

int totalScore = c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9
bool templatePassed = (totalScore == 9)

bgcolor(templatePassed ? color.new(color.green, 90) : na)

// ==========================================
// 5. VISUAL DASHBOARD MATRIX (OPAQUE)
// ==========================================
int total_rows = 10 + table_y_offset
var table statusTable = table.new(position.bottom_left, 2, total_rows, bgcolor=color.new(color.black, 0), border_width=1, border_color=color.gray)

if barstate.islast
    // Header
    table.cell(statusTable, 0, 0, "Minervini Criteria (Daily Context)", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.navy, 0))
    table.cell(statusTable, 1, 0, "Status", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.navy, 0))
    
    // Rows
    table.cell(statusTable, 0, 1, "Price > 150-D MA", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 1, c1 == 1 ? "PASSED" : "FAILED", bgcolor=c1 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 2, "Price > 200-D MA", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 2, c2 == 1 ? "PASSED" : "FAILED", bgcolor=c2 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 3, "150-D MA > 200-D MA", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 3, c3 == 1 ? "PASSED" : "FAILED", bgcolor=c3 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 4, "200-D MA Up (1M+)", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 4, c4 == 1 ? "PASSED" : "FAILED", bgcolor=c4 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 5, "50-D > 150-D & 200-D", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 5, c5 == 1 ? "PASSED" : "FAILED", bgcolor=c5 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 6, "Price > 50-D MA", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 6, c6 == 1 ? "PASSED" : "FAILED", bgcolor=c6 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 7, "Price >= 25% from Low", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 7, c7 == 1 ? "PASSED" : "FAILED", bgcolor=c7 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 8, "Price within 25% High", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 8, c8 == 1 ? "PASSED" : "FAILED", bgcolor=c8 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)
    
    table.cell(statusTable, 0, 9, "RS vs Nifty 500 (>=60% Lift)", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 9, c9 == 1 ? "STRONG" : "LAGGING", bgcolor=c9 == 1 ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)

    // Lift padding logic
    if table_y_offset > 0
        for i = 10 to total_rows - 1
            table.cell(statusTable, 0, i, "", bgcolor=color.new(color.black, 100))
            table.cell(statusTable, 1, i, "", bgcolor=color.new(color.black, 100))
````
