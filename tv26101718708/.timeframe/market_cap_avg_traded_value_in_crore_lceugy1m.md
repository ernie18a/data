# Market Cap + Avg Traded Value In Crore

- url: https://www.tradingview.com/script/lceUGY1M-Market-Cap-Avg-Traded-Value-In-Crore/
- type: indicator
- pine_id: PUB;2e3b4ed3fbba4af6aff84c4e7ae28c00
- version: 1.0

## Description

A minimal market overview indicator that displays two important stock metrics directly on the chart:

• Market Capitalization (₹ Crore)
• 20-Day Average Traded Value (₹ Crore)

Designed for quick stock analysis and liquidity assessment, especially for Indian equities.

Features:
✓ Market cap calculated dynamically using current price and shares outstanding
✓ 20-day average daily traded value calculated from daily data
✓ Works across intraday and higher timeframes
✓ Minimal floating table with customizable position
✓ Custom value color
✓ TradingView status line support for fast scanning
✓ Indian number formatting with Cr suffix

Average Traded Value (ADV) represents the average rupee value traded per day, helping traders compare liquidity across stocks regardless of share price.

Useful for:
• Stock screening
• Liquidity filtering
• Watchlist analysis
• Swing trading preparation
• Long-term investment research

This indicator is designed as a clean companion tool for traders who want essential stock information without cluttering their charts.

Note:
Market data availability depends on TradingView's supported financial data sources.

## Source Code

````pine
//@version=6
indicator(
     "Market Cap + Avg Traded Value In Crore",
     shorttitle="MC + ADV",
     overlay=true
)

//────────────────────────────────────────────
// INPUTS
// Hidden from status line
//────────────────────────────────────────────

avgDays = input.int(
     20,
     "Average Days",
     minval=1,
     display=display.none
)

showTable = input.bool(
     true,
     "Show Table",
     display=display.none
)

posInput = input.string(
     "Top Right",
     "Table Position",
     options=[
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     display=display.none
)

valueColor = input.color(
     color.rgb(41, 98, 255),
     "Value Color",
     display=display.none
)


//────────────────────────────────────────────
// TABLE POSITION
//────────────────────────────────────────────

tblPos = switch posInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right


//────────────────────────────────────────────
// INDIAN NUMBER FORMAT
// 1234567 → 12,34,567
//────────────────────────────────────────────

indianFormat(float value) =>
    if na(value)
        "N/A"
    else
        string s = str.tostring(int(math.round(value)))
        int n = str.length(s)

        if n <= 3
            s
        else
            string last3 = str.substring(s, n - 3, n)
            string head  = str.substring(s, 0, n - 3)

            int headLen = str.length(head)
            int firstLen = headLen % 2
            string result = ""

            if firstLen == 1
                result := str.substring(head, 0, 1)

            int i = firstLen

            while i < headLen
                if str.length(result) > 0
                    result += ","

                result += str.substring(head, i, i + 2)
                i += 2

            result + "," + last3


//────────────────────────────────────────────
// MARKET CAP — ₹ CRORE
//────────────────────────────────────────────

float marketCapCr =
     syminfo.shares_outstanding_total * close / 1e7


//────────────────────────────────────────────
// AVG DAILY TRADED VALUE — ₹ CRORE
// Always based on daily bars
//────────────────────────────────────────────

float avgValueCr = request.security(
     syminfo.tickerid,
     "D",
     ta.sma(volume * close, avgDays) / 1e7
)


//────────────────────────────────────────────
// STATUS LINE
// Values enabled, no chart plots / scale labels
//────────────────────────────────────────────

plot(
     marketCapCr,
     title="MC",
     color=valueColor,
     display=display.status_line,
     format=format.price,
     precision=0
)

plot(
     avgValueCr,
     title="ADV",
     color=valueColor,
     display=display.status_line,
     format=format.price,
     precision=0
)


//────────────────────────────────────────────
// MINIMAL TABLE
//────────────────────────────────────────────

var table t = table.new(
     tblPos,
     2,
     2,
     bgcolor=color.new(chart.bg_color, 5),
     frame_color=color.new(chart.fg_color, 90),
     frame_width=1,
     border_width=0
)

if barstate.islast
    table.set_position(t, tblPos)

    if showTable
        table.cell(
             t, 0, 0,
             "mCap",
             text_color=color.new(chart.fg_color, 45),
             text_size=size.small,
             text_halign=text.align_left
        )

        table.cell(
             t, 1, 0,
             na(marketCapCr) ? "N/A" : "₹" + indianFormat(marketCapCr) + " Cr",
             text_color=valueColor,
             text_size=size.small,
             text_halign=text.align_right
        )

        table.cell(
             t, 0, 1,
             "ADV" + str.tostring(avgDays),
             text_color=color.new(chart.fg_color, 45),
             text_size=size.small,
             text_halign=text.align_left
        )

        table.cell(
             t, 1, 1,
             na(avgValueCr) ? "N/A" : "₹" + indianFormat(avgValueCr) + " Cr",
             text_color=valueColor,
             text_size=size.small,
             text_halign=text.align_right
        )

    else
        table.clear(t, 0, 0, 1, 1)
````
