# Roy Ichimoku MTF Trend Pocket

- url: https://www.tradingview.com/script/uYfNBUOI-Roy-Ichimoku-MTF-Trend-Pocket/
- type: indicator
- pine_id: PUB;aaf37615477b4201b83248d0c56fe62f
- version: 1.0

## Description

Roy Ichimoku MTF Trend Pocket is a combination of the classic Ichimoku Cloud system with a compact Multi-Timeframe (MTF) Trend & Pocket Table designed to help traders quickly identify overall market direction across multiple timeframes.

This indicator displays the standard Ichimoku components directly on the chart:

• Tenkan Sen
• Kijun Sen
• Chikou Span
• Senkou Span A & B (Kumo Cloud)

In addition, a compact MTF table is included at the top-right corner of the chart to monitor trend conditions from multiple timeframes simultaneously.

━━━━━━━━━━━━━━━━━━
MTF TABLE FEATURES
━━━━━━━━━━━━━━━━━━

Supported Timeframes:
• M1
• M5
• M15
• M30
• H1
• H4
• D
• W

Trend Status:
• BULL (Blue/Teal)
→ Price has closed above the Ichimoku Cloud.

• BEAR (Red)
→ Price has closed below the Ichimoku Cloud.

• SIDE (Orange)
→ Price is inside or touching the cloud area.

Pocket Status:
• OUT (Gray)
→ Price has completely exited the cloud zone.

• INSIDE (Yellow)
→ Price is currently inside the cloud.

━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━

The indicator automatically analyzes the relationship between price and the Ichimoku Cloud on every selected timeframe.

This allows traders to:
• Detect bullish or bearish trend alignment.
• Identify consolidation zones inside the cloud.
• Monitor higher timeframe confirmation quickly.
• Avoid entering against major trend direction.
• Improve multi-timeframe trend reading efficiency.

━━━━━━━━━━━━━━━━━━
BEST USAGE
━━━━━━━━━━━━━━━━━━

This indicator works well for:
• Trend Following
• Scalping
• Intraday Trading
• Swing Trading
• Multi-Timeframe Confirmation

Recommended approach:
Use higher timeframe trend direction (H1/H4/D) as market bias and lower timeframe (M1/M5/M15) for precise entries.

━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━

Customizable Inputs:
• Tenkan Length
• Kijun Length
• Senkou Span B Length
• Displacement
• Timeframe Selection

━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━

• This indicator is designed for trend confirmation and market structure analysis.
• Stronger signals usually occur when multiple timeframes align in the same direction.
• Works best in trending markets.
• Can be combined with price action, support/resistance, volume, or confirmation indicators.

## Source Code

````pine
//@version=5
indicator("Roy Ichimoku MTF Trend Pocket", overlay=true)

// === Input Ichimoku ===
tenkanLen = input.int(9, "Tenkan Sen")
kijunLen  = input.int(26, "Kijun Sen")
spanBLen  = input.int(52, "Senkou Span B")
displace  = input.int(26, "Displacement")

// === Ichimoku Chart Utama ===
tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
kijun  = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2
spanA  = (tenkan + kijun) / 2
spanB  = (ta.highest(high, spanBLen) + ta.lowest(low, spanBLen)) / 2
chikou = close

plot(tenkan, "Tenkan Sen", color=color.blue)
plot(kijun, "Kijun Sen", color=color.red)
plot(chikou, "Chikou Span", color=color.green, offset=-displace)

pA = plot(spanA, "Senkou Span A", color=color.new(color.green, 0), offset=displace)
pB = plot(spanB, "Senkou Span B", color=color.new(color.red, 0), offset=displace)

fill(pA, pB, color = spanA > spanB ? color.new(color.green, 82) : color.new(color.red, 82))

// === Timeframe ===
tf1 = input.timeframe("1", "M1")
tf2 = input.timeframe("5", "M5")
tf3 = input.timeframe("15", "M15")
tf4 = input.timeframe("30", "M30")
tf5 = input.timeframe("60", "H1")
tf6 = input.timeframe("240", "H4")
tf7 = input.timeframe("D", "D")
tf8 = input.timeframe("W", "W")

// === Function Status MTF ===
f_status() =>
    t = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
    k = (ta.highest(high, kijunLen) + ta.lowest(low, kijunLen)) / 2
    a = (t + k) / 2
    b = (ta.highest(high, spanBLen) + ta.lowest(low, spanBLen)) / 2

    top = math.max(a[displace], b[displace])
    bot = math.min(a[displace], b[displace])

    bull = close > top
    bear = close < bot
    inside = close <= top and close >= bot

    trend = bull ? "BULL" : bear ? "BEAR" : "SIDE"
    pocket = inside ? "INSIDE" : "OUT"

    trendColor = bull ? color.teal : bear ? color.red : color.orange
    pocketColor = inside ? color.yellow : color.new(color.gray, 25)

    [trend, pocket, trendColor, pocketColor]

// === Data MTF ===
[t1, p1, c1, pc1] = request.security(syminfo.tickerid, tf1, f_status())
[t2, p2, c2, pc2] = request.security(syminfo.tickerid, tf2, f_status())
[t3, p3, c3, pc3] = request.security(syminfo.tickerid, tf3, f_status())
[t4, p4, c4, pc4] = request.security(syminfo.tickerid, tf4, f_status())
[t5, p5, c5, pc5] = request.security(syminfo.tickerid, tf5, f_status())
[t6, p6, c6, pc6] = request.security(syminfo.tickerid, tf6, f_status())
[t7, p7, c7, pc7] = request.security(syminfo.tickerid, tf7, f_status())
[t8, p8, c8, pc8] = request.security(syminfo.tickerid, tf8, f_status())

// === Table Kecil ===
var table mtfTable = table.new(position.top_right, 3, 9, border_width=1)

f_row(row, tfName, trend, pocket, trendCol, pocketCol) =>
    table.cell(mtfTable, 0, row, tfName, text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(mtfTable, 1, row, trend, text_color=color.white, bgcolor=trendCol, text_size=size.small)
    table.cell(mtfTable, 2, row, pocket, text_color=color.white, bgcolor=pocketCol, text_size=size.small)

if barstate.islast
    table.cell(mtfTable, 0, 0, "TF", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(mtfTable, 1, 0, "Trend", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(mtfTable, 2, 0, "Pocket", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)

    f_row(1, "M1", t1, p1, c1, pc1)
    f_row(2, "M5", t2, p2, c2, pc2)
    f_row(3, "M15", t3, p3, c3, pc3)
    f_row(4, "M30", t4, p4, c4, pc4)
    f_row(5, "H1", t5, p5, c5, pc5)
    f_row(6, "H4", t6, p6, c6, pc6)
    f_row(7, "D", t7, p7, c7, pc7)
    f_row(8, "W", t8, p8, c8, pc8)
````
