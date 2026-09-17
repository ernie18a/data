<!-- tradingview-pine-id: PUB;28410016a61b4db3824b4da7e3237114 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Tokir Solkar quarter theory

Source: https://www.tradingview.com/script/QPyTONhK-quarter-theory-shortcut/

## Description

Quarter Theory 90M & 6H Cycle
This indicator is based on Quarter Theory and is designed to identify and visualize 90-minute and 6-hour market cycles. It helps traders track important time-based cycle divisions and understand potential accumulation, manipulation, and distribution phases within the market. The 90-minute cycle can be used for intraday analysis, while the 6-hour cycle provides a broader view of market structure and time-based price behavior. This tool can be used across different timeframes for better cycle analysis and trade timing. Always use proper risk management and combine this indicator with your own market analysis before taking any trade.

---

## Source Code

````pine
//@version=6
indicator("Tokir Solkar quarter theory", overlay=true)

// --- Background Logic (Sirf 1-Min timeframe par chalega) ---

get_levels() =>
    // 1. 6-Hour ka Q2
    // 19:30, 01:30, 07:30, 13:30
    is6H = (hour % 6 == 1) and minute == 30

    // 2. Sabhi 90-min cycles ke Q2
    // Group 1: xx:23 wale
    grp1 = (hour % 3 == 0) and minute == 23

    // Group 2: xx:53 wale
    grp2 = (hour % 3 == 1) and minute == 53

    // Dono groups ko combine kiya
    is90m_All = grp1 or grp2

    // Variables
    var float p6 = na
    var float p9 = na

    // Exact minute par price store karna
    if is6H
        p6 := open

    if is90m_All
        p9 := open

    [p6, p9]

// --- Timeframe Independent Fetch ---

[price_6H_Q2, price_90m_All_Q2] = request.security(
    syminfo.tickerid,
    "1",
    get_levels()
)

// --- PLOTTING ---

// 6-Hour Q2 - Blue Solid Line
plot(
    price_6H_Q2,
    title="6-Hour Q2",
    color=color.blue,
    linewidth=2,
    style=plot.style_line
)

// All 90-Min Q2 - Red Circles
plot(
    price_90m_All_Q2,
    title="All 90-Min Q2s",
    color=color.red,
    linewidth=2,
    style=plot.style_circles
)
````
