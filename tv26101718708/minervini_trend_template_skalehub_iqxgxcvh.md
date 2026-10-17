# Minervini Trend Template [SkaleHub]

- url: https://www.tradingview.com/script/iQxgxcVh-Minervini-Trend-Template-SkaleHub/
- type: indicator
- pine_id: PUB;6a1ba29321f94314a71777f71a12947b
- version: 1.0

## Description

Overview
A real-time, mathematically strict dashboard that instantly checks any stock against Mark Minervini’s legendary "Trend Template." It removes human bias, verifying if an asset is in a legitimate Phase 2 markup before you risk capital.

The Edge
Amateurs constantly buy stocks that are broken, hoping to catch a falling knife. This dashboard prevents that entirely. If the table says "REJECTED," you move on. It saves hours of manual chart analysis and forces you to only trade assets with confirmed, institutional momentum.

Key Features:

Instant Phase 2 Verification: Automatically calculates all 7 major moving average and price-structure criteria required for a true Minervini setup.

Live Dashboard Readout: Displays a clean, scannable table on your chart indicating exactly which criteria are passing (Green) or failing (Red).

Capital Protection: Acts as a ruthless gatekeeper. By refusing to trade assets that fail the template, you mathematically eliminate the majority of low-probability, sideways, or downtrending charts from your radar.

How to Use

Apply the indicator to a Daily timeframe chart (the template relies heavily on the 200-day moving average and 52-week data).

Look at the dashboard in the corner.

If the header reads "❌ REJECTED," the stock is not in a confirmed Phase 2 uptrend. Avoid taking long positions.

If the header reads "✅ QUALIFIED," the asset meets the strict structural requirements. You can now drop to lower timeframes to look for specific entry setups (like volatility contractions or breakouts).

Author's Note
This indicator is part of the SkaleHub Advanced library. It is designed to systemize your stock screening process, ensuring you only hunt for setups in markets where the macro trend is heavily stacked in your favor.

## Source Code

````pine
//@version=5
indicator("Minervini Trend Template [SkaleHub]", overlay=true)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
posStr = input.string("Top Right", title="Dashboard Position", options=["Top Right", "Top Center", "Top Left", "Bottom Right", "Bottom Left"], group="Visuals")
c_bg   = input.color(color.new(#131722, 10), title="Dashboard Background", group="Visuals")
c_text = input.color(color.white, title="Text Color", group="Visuals")
c_pass = input.color(#00ff00, title="Pass Color", group="Visuals")
c_fail = input.color(#ff0000, title="Fail Color", group="Visuals")

get_pos(p) =>
    p == "Top Right" ? position.top_right :
     p == "Top Center" ? position.top_center :
     p == "Top Left" ? position.top_left :
     p == "Bottom Right" ? position.bottom_right : position.bottom_left

// =========================================================================
// 2. MATH & DATA FETCHING
// =========================================================================
// Moving Averages
sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

// 52-Week High and Low (Approx. 250 trading days)
high52 = ta.highest(high, 250)
low52  = ta.lowest(low, 250)

// =========================================================================
// 3. MINERVINI TREND TEMPLATE CONDITIONS
// =========================================================================
// 1. Current Price > 150 SMA and 200 SMA
cond1 = close > sma150 and close > sma200

// 2. 150 SMA > 200 SMA
cond2 = sma150 > sma200

// 3. 200 SMA is trending up for at least 1 month (20 trading days)
cond3 = sma200 > sma200[20]

// 4. 50 SMA > 150 SMA and 200 SMA
cond4 = sma50 > sma150 and sma50 > sma200

// 5. Current Price > 50 SMA
cond5 = close > sma50

// 6. Current Price is at least 30% above its 52-week low
cond6 = close >= (low52 * 1.30)

// 7. Current Price is within 25% of its 52-week high
cond7 = close >= (high52 * 0.75)

// Master Condition
allPass = cond1 and cond2 and cond3 and cond4 and cond5 and cond6 and cond7

// =========================================================================
// 4. DASHBOARD RENDERING
// =========================================================================
var table tb = table.new(get_pos(posStr), 2, 9, bgcolor=c_bg, border_width=1, border_color=color.new(color.gray, 80))

// Helper function to return Pass/Fail text and color
get_status(cond) =>
    cond ? "PASS" : "FAIL"

get_color(cond) =>
    cond ? c_pass : c_fail

if barstate.islast
    // Header
    table.cell(tb, 0, 0, "Minervini Trend Template", text_color=c_text, text_halign=text.align_left, text_size=size.small, bgcolor=color.new(color.gray, 80))
    table.cell(tb, 1, 0, allPass ? "✅ QUALIFIED" : "❌ REJECTED", text_color=allPass ? c_pass : c_fail, text_halign=text.align_right, text_size=size.small, bgcolor=color.new(color.gray, 80))
    
    // Row 1
    table.cell(tb, 0, 1, "1. Price > 150 & 200 SMA", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 1, get_status(cond1), text_color=get_color(cond1), text_halign=text.align_right, text_size=size.small)
    
    // Row 2
    table.cell(tb, 0, 2, "2. 150 SMA > 200 SMA", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 2, get_status(cond2), text_color=get_color(cond2), text_halign=text.align_right, text_size=size.small)
    
    // Row 3
    table.cell(tb, 0, 3, "3. 200 SMA Trending Up (1M)", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 3, get_status(cond3), text_color=get_color(cond3), text_halign=text.align_right, text_size=size.small)
    
    // Row 4
    table.cell(tb, 0, 4, "4. 50 SMA > 150 & 200 SMA", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 4, get_status(cond4), text_color=get_color(cond4), text_halign=text.align_right, text_size=size.small)
    
    // Row 5
    table.cell(tb, 0, 5, "5. Price > 50 SMA", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 5, get_status(cond5), text_color=get_color(cond5), text_halign=text.align_right, text_size=size.small)
    
    // Row 6
    table.cell(tb, 0, 6, "6. Price 30%+ Above 52W Low", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 6, get_status(cond6), text_color=get_color(cond6), text_halign=text.align_right, text_size=size.small)
    
    // Row 7
    table.cell(tb, 0, 7, "7. Price within 25% of 52W High", text_color=c_text, text_halign=text.align_left, text_size=size.small)
    table.cell(tb, 1, 7, get_status(cond7), text_color=get_color(cond7), text_halign=text.align_right, text_size=size.small)
````
