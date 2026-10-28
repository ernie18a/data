# ROY MTF CHART

- url: https://www.tradingview.com/script/FqET1suG-ROY-MTF-CHART/
- type: indicator
- pine_id: PUB;cb6c841e0a77434f865620901d155b83
- version: 1.0

## Description

ROY MTF CHART is a powerful multi-timeframe trend analysis dashboard designed to help traders instantly identify market direction, trend strength, and timeframe alignment without switching between multiple charts.

The indicator analyzes multiple timeframes simultaneously (H4, H1, M30, M15, M5, and M1) and converts complex market information into a simple visual matrix that is easy to read, even on mobile devices.

Instead of manually checking every timeframe, traders can quickly determine whether the market is bullish, bearish, or ranging and whether all timeframes are moving in the same direction.

Key Features

✅ Multi-Timeframe Trend Analysis

✅ Trend Strength Percentage

✅ Bullish / Bearish / Sideway Detection

✅ Alignment Score System

✅ Market Direction Dashboard

✅ Visual Momentum Bars

✅ Mobile-Friendly Interface

✅ Fast Decision Making

Included Timeframes

• H4 (Higher Trend)

• H1 (Primary Trend)

• M30 (Market Structure)

• M15 (Intraday Trend)

• M5 (Entry Confirmation)

• M1 (Precision Entry)

What Makes It Different?

Most indicators only show signals from a single timeframe.

ROY MTF LIVE MATRIX combines multiple timeframes into a single dashboard and measures how well they agree with each other.

The more timeframes aligned in the same direction, the higher the probability of a stronger market move.

This helps traders avoid taking trades against the dominant trend.

Alignment Score

The Alignment Score measures how many timeframes are moving in the same direction.

100% = All timeframes aligned

83% = 5 out of 6 timeframes aligned

67% = Strong alignment

50% = Mixed market

Below 50% = Weak market conditions

The higher the Alignment Score, the stronger the market consensus.

Overall Market Status

The indicator automatically generates an overall market bias:

BULLISH

BEARISH

MIXED

This allows traders to instantly understand market conditions before entering a trade.

Best Use Cases

• Scalping

• Day Trading

• Intraday Trading

• Trend Following

• Multi-Timeframe Analysis

• Gold Trading (XAUUSD)

• Forex Trading

• Index Trading

• Crypto Trading

Recommended Workflow
Check Overall Bias.
Check Alignment Score.
Confirm H4 and H1 direction.
Wait for M15 and M5 confirmation.
Use M1 for precise entries.
Trade only in the direction of the dominant trend.
Version

ROY MTF LIVE MATRIX

Designed by Roy

Built for traders who want to see the entire market structure at a glance.

## Source Code

````pine
//@version=6
indicator("ROY MTF CHART", overlay=true, max_labels_count=500)

// ================= INPUT =================
showPanel = input.bool(true, "Show MTF Live Matrix")

panelPos = input.string(
     "Top Right",
     "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"]
)

tf1 = input.timeframe("240", "TF 1 - H4")
tf2 = input.timeframe("60",  "TF 2 - H1")
tf3 = input.timeframe("30",  "TF 3 - M30")
tf4 = input.timeframe("15",  "TF 4 - M15")
tf5 = input.timeframe("5",   "TF 5 - M5")
tf6 = input.timeframe("1",   "TF 6 - M1")

emaFastLen = input.int(20, "EMA Fast", minval=1)
emaSlowLen = input.int(50, "EMA Slow", minval=1)
rsiLen     = input.int(14, "RSI Length", minval=1)

bullStrongLevel = input.int(60, "Bull/Bear Minimum Strength", minval=1, maxval=100)

// ================= FUNCTION =================
f_mtfData(tf) =>
    c  = request.security(syminfo.tickerid, tf, close)
    e1 = request.security(syminfo.tickerid, tf, ta.ema(close, emaFastLen))
    e2 = request.security(syminfo.tickerid, tf, ta.ema(close, emaSlowLen))
    r  = request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLen))

    trendBull = c > e1 and e1 > e2
    trendBear = c < e1 and e1 < e2

    strengthRaw = trendBull ? 50 + ((r - 50) * 1.5) :
         trendBear ? 50 + ((50 - r) * 1.5) :
         50

    strength = math.max(0, math.min(100, strengthRaw))

    dir = trendBull and strength >= bullStrongLevel ? 1 :
         trendBear and strength >= bullStrongLevel ? -1 :
         0

    status = dir == 1 ? "BULL" :
         dir == -1 ? "BEAR" :
         "SIDE"

    icon = dir == 1 ? "🟢" :
         dir == -1 ? "🔴" :
         "🟡"

    arrow = dir == 1 and strength >= 75 ? "↑↑↑" :
         dir == 1 ? "↑↑" :
         dir == -1 and strength >= 75 ? "↓↓↓" :
         dir == -1 ? "↓↓" :
         "→"

    spark = dir == 1 and strength >= 75 ? "▃▄▅▆█" :
         dir == 1 ? "▂▃▄▅▆" :
         dir == -1 and strength >= 75 ? "█▆▅▄▃" :
         dir == -1 ? "▇▆▅▄▂" :
         "▅▅▅▅▅"

    [status, icon, strength, spark, arrow, dir]

// ================= DATA =================
[s1, i1, p1, sp1, ar1, d1] = f_mtfData(tf1)
[s2, i2, p2, sp2, ar2, d2] = f_mtfData(tf2)
[s3, i3, p3, sp3, ar3, d3] = f_mtfData(tf3)
[s4, i4, p4, sp4, ar4, d4] = f_mtfData(tf4)
[s5, i5, p5, sp5, ar5, d5] = f_mtfData(tf5)
[s6, i6, p6, sp6, ar6, d6] = f_mtfData(tf6)

// ================= ALIGNMENT =================
bullCount = (d1 == 1 ? 1 : 0) + (d2 == 1 ? 1 : 0) + (d3 == 1 ? 1 : 0) + (d4 == 1 ? 1 : 0) + (d5 == 1 ? 1 : 0) + (d6 == 1 ? 1 : 0)
bearCount = (d1 == -1 ? 1 : 0) + (d2 == -1 ? 1 : 0) + (d3 == -1 ? 1 : 0) + (d4 == -1 ? 1 : 0) + (d5 == -1 ? 1 : 0) + (d6 == -1 ? 1 : 0)
sideCount = 6 - bullCount - bearCount

dominantDir = bullCount > bearCount and bullCount > sideCount ? 1 :
     bearCount > bullCount and bearCount > sideCount ? -1 :
     0

dominantCount = math.max(bullCount, math.max(bearCount, sideCount))
alignment = dominantCount / 6.0 * 100.0

avgPower = (p1 + p2 + p3 + p4 + p5 + p6) / 6.0

overallText = dominantDir == 1 and alignment >= 67 ? "BULLISH" :
     dominantDir == -1 and alignment >= 67 ? "BEARISH" :
     "MIXED"

starText = alignment >= 85 ? "★★★★★" :
     alignment >= 70 ? "★★★★☆" :
     alignment >= 55 ? "★★★☆☆" :
     alignment >= 40 ? "★★☆☆☆" :
     "★☆☆☆☆"

// ================= TABLE POSITION =================
pos = panelPos == "Top Left" ? position.top_left :
     panelPos == "Bottom Right" ? position.bottom_right :
     panelPos == "Bottom Left" ? position.bottom_left :
     position.top_right

// 5 column, 9 row
var table panel = table.new(pos, 5, 9, border_width=1)

// ================= ROW FUNCTION =================
f_row(row, tfName, icon, status, percent, spark, arrow) =>
    bg = status == "BULL" ? color.new(color.green, 78) :
         status == "BEAR" ? color.new(color.red, 78) :
         color.new(color.orange, 78)

    table.cell(panel, 0, row, tfName, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(panel, 1, row, icon, text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(panel, 2, row, status + " " + str.tostring(math.round(percent)) + "%", text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(panel, 3, row, spark, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(panel, 4, row, arrow, text_color=color.white, bgcolor=bg, text_size=size.small)

// ================= DRAW PANEL =================
if barstate.islast
    if showPanel
        table.cell(panel, 0, 0, "ROY", text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)
        table.cell(panel, 1, 0, "MTF", text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)
        table.cell(panel, 2, 0, "LIVE MATRIX", text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)
        table.cell(panel, 3, 0, "FLOW", text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)
        table.cell(panel, 4, 0, "DIR", text_color=color.white, bgcolor=color.new(color.blue, 15), text_size=size.small)

        f_row(1, "H4",  i1, s1, p1, sp1, ar1)
        f_row(2, "H1",  i2, s2, p2, sp2, ar2)
        f_row(3, "M30", i3, s3, p3, sp3, ar3)
        f_row(4, "M15", i4, s4, p4, sp4, ar4)
        f_row(5, "M5",  i5, s5, p5, sp5, ar5)
        f_row(6, "M1",  i6, s6, p6, sp6, ar6)

        overallBg = overallText == "BULLISH" ? color.new(color.green, 70) :
             overallText == "BEARISH" ? color.new(color.red, 70) :
             color.new(color.orange, 70)

        table.cell(panel, 0, 7, "ALIGN", text_color=color.white, bgcolor=color.new(color.purple, 65), text_size=size.small)
        table.cell(panel, 1, 7, str.tostring(math.round(alignment)) + "%", text_color=color.white, bgcolor=color.new(color.purple, 65), text_size=size.small)
        table.cell(panel, 2, 7, starText, text_color=color.white, bgcolor=color.new(color.purple, 65), text_size=size.small)
        table.cell(panel, 3, 7, "AVG", text_color=color.white, bgcolor=color.new(color.purple, 65), text_size=size.small)
        table.cell(panel, 4, 7, str.tostring(math.round(avgPower)) + "%", text_color=color.white, bgcolor=color.new(color.purple, 65), text_size=size.small)

        table.cell(panel, 0, 8, "OVERALL", text_color=color.white, bgcolor=overallBg, text_size=size.small)
        table.cell(panel, 1, 8, overallText, text_color=color.white, bgcolor=overallBg, text_size=size.small)
        table.cell(panel, 2, 8, "B:" + str.tostring(bullCount), text_color=color.white, bgcolor=overallBg, text_size=size.small)
        table.cell(panel, 3, 8, "S:" + str.tostring(sideCount), text_color=color.white, bgcolor=overallBg, text_size=size.small)
        table.cell(panel, 4, 8, "R:" + str.tostring(bearCount), text_color=color.white, bgcolor=overallBg, text_size=size.small)
````
