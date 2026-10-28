# S&P 500 & 11 Sectors Volatility Lines + Compact Legend

- url: https://www.tradingview.com/script/QMuhe1HO-S-P-500-11-Sectors-Volatility-Lines-Compact-Legend/
- type: indicator
- pine_id: PUB;f9315bceb99644e790fb07b7041a1405
- version: 1.0

## Description

How to Read the Chart Across Different Timeframes
1. On a Daily Chart (D) — The Tactical View
What you see: A smooth, continuous line where a new point is plotted every single trading day.

How to read it: This is the most accurate way to use the indicator. It shows you day-to-day spikes, rapid shifts in sector fear, and short-term momentum changes in volatility.

2. On a Weekly Chart (W) — The Macro Trend View
What you see: A sparser line where data points only update once a week (at the close of each week).

How to read it: Think of this as a "zoomed-out" filter. It ignores daily market noise and lets you see multi-week or multi-month volatility trends—such as a sector transitioning from a quiet regime into a sustained high-volatility regime.

## Source Code

````pine
//@version=6
indicator("S&P 500 & 11 Sectors Volatility Lines + Compact Legend", overlay=false, precision=2)

// Input for HV Calculation Length & Table Position
hv_length = input.int(20, minval=1, title="HV Calculation Length (Days)")
tbl_pos   = input.string(position.top_right, title="Legend Position", 
            options=[position.top_left, position.top_right, position.bottom_left, position.bottom_right])

// Securely calculate annualized historical volatility strictly on the Daily timeframe
get_hv(ticker, len) =>
    [c, c_1] = request.security(ticker, "D", [close, close[1]])
    log_ret = c_1 > 0 ? math.log(c / c_1) : 0.0
    ta.stdev(log_ret, len) * math.sqrt(252) * 100

// Fetch volatility for Benchmark + all 11 Sectors
spy_hv  = get_hv("AMEX:SPY", hv_length)  
xlk_hv  = get_hv("AMEX:XLK", hv_length)  
xlf_hv  = get_hv("AMEX:XLF", hv_length)  
xlv_hv  = get_hv("AMEX:XLV", hv_length)  
xle_hv  = get_hv("AMEX:XLE", hv_length)  
xly_hv  = get_hv("AMEX:XLY", hv_length)  
xlp_hv  = get_hv("AMEX:XLP", hv_length)  
xli_hv  = get_hv("AMEX:XLI", hv_length)  
xlb_hv  = get_hv("AMEX:XLB", hv_length)  
xlu_hv  = get_hv("AMEX:XLU", hv_length)  
xlre_hv = get_hv("AMEX:XLRE", hv_length) 
xlc_hv  = get_hv("AMEX:XLC", hv_length)  

// Define exact colors for each line
c_spy  = color.rgb(255, 215, 0)   // Gold
c_xlk  = color.rgb(33, 150, 243)  // Blue
c_xlf  = color.rgb(76, 175, 80)   // Green
c_xlv  = color.rgb(233, 30, 99)   // Pink/Magenta
c_xle  = color.rgb(255, 152, 0)   // Orange
c_xly  = color.rgb(156, 39, 176)  // Purple
c_xlp  = color.rgb(0, 150, 136)   // Teal
c_xli  = color.rgb(121, 85, 72)   // Brown
c_xlb  = color.rgb(96, 125, 139)  // Slate Grey
c_xlu  = color.rgb(0, 188, 212)   // Cyan
c_xlre = color.rgb(205, 220, 57)  // Lime
c_xlc  = color.rgb(244, 67, 54)   // Red

// Plot each sector as a clean line in the subpane
plot(spy_hv,  title="S&P 500 (SPY)",    color=c_spy,  linewidth=2)
plot(xlk_hv,  title="Tech (XLK)",        color=c_xlk)
plot(xlf_hv,  title="Financials (XLF)",  color=c_xlf)
plot(xlv_hv,  title="Health Care (XLV)", color=c_xlv)
plot(xle_hv,  title="Energy (XLE)",      color=c_xle)
plot(xly_hv,  title="Discretionary (XLY)",color=c_xly)
plot(xlp_hv,  title="Staples (XLP)",     color=c_xlp)
plot(xli_hv,  title="Industrials (XLI)", color=c_xli)
plot(xlb_hv,  title="Materials (XLB)",   color=c_xlb)
plot(xlu_hv,  title="Utilities (XLU)",   color=c_xlu)
plot(xlre_hv, title="Real Estate (XLRE)",color=c_xlre)
plot(xlc_hv,  title="Communications (XLC)", color=c_xlc)

// Compact 3-Column Legend Table
var legend_tbl = table.new(tbl_pos, 3, 5, border_width=1, border_color=color.rgb(67, 70, 81), bgcolor=color.new(color.rgb(19, 23, 34), 15))

if barstate.islast
    table.cell(legend_tbl, 0, 0, "Market Volatility Legend", text_color=color.white, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 1, 0, "", text_size=size.small)
    table.cell(legend_tbl, 2, 0, "", text_size=size.small)

    table.cell(legend_tbl, 0, 1, "S&P 500 (SPY)", text_color=c_spy, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 1, 1, "Tech (XLK)", text_color=c_xlk, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 2, 1, "Financials (XLF)", text_color=c_xlf, text_size=size.small, text_formatting=text.format_bold)

    table.cell(legend_tbl, 0, 2, "Health Care (XLV)", text_color=c_xlv, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 1, 2, "Energy (XLE)", text_color=c_xle, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 2, 2, "Discretionary (XLY)", text_color=c_xly, text_size=size.small, text_formatting=text.format_bold)

    table.cell(legend_tbl, 0, 3, "Staples (XLP)", text_color=c_xlp, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 1, 3, "Industrials (XLI)", text_color=c_xli, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 2, 3, "Materials (XLB)", text_color=c_xlb, text_size=size.small, text_formatting=text.format_bold)

    table.cell(legend_tbl, 0, 4, "Utilities (XLU)", text_color=c_xlu, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 1, 4, "Real Estate (XLRE)", text_color=c_xlre, text_size=size.small, text_formatting=text.format_bold)
    table.cell(legend_tbl, 2, 4, "Comms (XLC)", text_color=c_xlc, text_size=size.small, text_formatting=text.format_bold)
````
