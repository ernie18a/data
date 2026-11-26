# Gold Macro Dashboard [invincible3]

- url: https://www.tradingview.com/script/xrRXASdS-Gold-Macro-Dashboard-invincible3/
- type: indicator
- pine_id: PUB;9fbb1a955b3a4a3d81f680dcc0b97c2d
- version: 1.0

## Description

[b]Gold Macro Indicator Dashboard [Fixed Daily Macro][/b]

A professional macro-driven gold dashboard designed to evaluate the broader gold market regime using automatically sourced TradingView data. The indicator combines real yields, dollar strength, rate expectations, risk-off demand, gold breadth, and confirmation ratios into a single 0–100 Gold Macro Score.

The model uses a fixed daily macro timeframe, so dashboard readings stay consistent across intraday, daily, and weekly charts.

[b]Main Features
[/b]
Fixed Daily macro scoring
0–100 Gold Macro Score oscillator
Macro Regime classification
Macro Strength score
Real Yield driver
DXY / US Dollar driver
Gold liquidity proxy
US 2Y rate outlook
VIX risk-off signal
Cross-currency gold breadth
Gold/Silver ratio
Gold/S&P 500 ratio
Copper/Gold ratio
US 10Y–2Y yield spread
Crypto-style clean dashboard layout
Dark/light theme adaptive colors
No manual macro inputs

[b]Score Interpretation[/b]

80–100: Strong Bull
60–80: Bullish
40–60: Neutral
20–40: Bearish
0–20: Strong Bear

[b]How It Works[/b]

The composite score is weighted as follows:

Real Yield 10Y: 30%
US Dollar DXY: 25%
Gold liquidity proxy: 15%
US 2Y rate outlook: 10%
Risk-Off VIX: 10%
Gold breadth: 10%

Gold breadth checks whether gold is trending higher across major currencies, including XAUUSD, XAUEUR, XAUJPY, XAUGBP, and XAUCNH.

[b]Use Case[/b]

This indicator is designed for traders and investors who want a macro-level view of gold’s trend quality. It can help identify whether gold strength is supported by broad macro conditions or only short-term price movement.

[b]Disclaimer[/b]

This is an educational macro model only. It is not financial advice and should not be used as a standalone buy or sell signal. Always combine it with your own risk management, technical analysis, and market research.

## Source Code

````pine
//@version=6
indicator("Gold Macro Dashboard [invincible3]", overlay=false, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIXED MACRO TIMEFRAME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
macroTf = "D"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// THEME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
chartLuma = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
isLightTheme = chartLuma > 128

bgMain   = isLightTheme ? color.rgb(255,255,255,0) : color.rgb(18,18,20,5)
bgPanel  = isLightTheme ? color.rgb(243,244,246,0) : color.rgb(24,24,27,8)
bgPanel2 = isLightTheme ? color.rgb(229,231,235,0) : color.rgb(39,39,42,12)

txtMain  = isLightTheme ? color.rgb(17,24,39) : color.rgb(250,250,250)
txtMute  = isLightTheme ? color.rgb(107,114,128) : color.rgb(161,161,170)

green1   = isLightTheme ? color.rgb(5,150,105) : color.rgb(16,185,129)
green2   = isLightTheme ? color.rgb(16,185,129) : color.rgb(52,211,153)
yellow1  = isLightTheme ? color.rgb(217,119,6) : color.rgb(251,191,36)
orange1  = isLightTheme ? color.rgb(234,88,12) : color.rgb(251,146,60)
red1     = isLightTheme ? color.rgb(220,38,38) : color.rgb(248,113,113)

goldCol = yellow1
sz      = size.small
szBig   = size.normal

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clamp(x) =>
    math.max(0.0, math.min(100.0, x))

f_norm(src, len, inverse) =>
    lo = ta.lowest(src, len)
    hi = ta.highest(src, len)
    raw = hi == lo ? 50.0 : 100.0 * (src - lo) / (hi - lo)
    inverse ? 100.0 - raw : raw

f_status(score) =>
    score >= 80 ? "STRONG BULL" :
     score >= 60 ? "BULLISH" :
     score >= 40 ? "NEUTRAL" :
     score >= 20 ? "BEARISH" : "STRONG BEAR"

f_col(score) =>
    score >= 80 ? green1 :
     score >= 60 ? green2 :
     score >= 40 ? yellow1 :
     score >= 20 ? orange1 :
     red1

f_meterText(score, width) =>
    filled = int(math.round(f_clamp(score) / 100.0 * width))
    out = ""
    for i = 0 to width - 1
        out += i < filled ? "█" : "░"
    out

f_trend(src) =>
    ema50 = ta.ema(src, 50)
    ema200 = ta.ema(src, 200)
    src > ema200 and ema50 > ema200

f_techScore(src) =>
    ema50 = ta.ema(src, 50)
    ema200 = ta.ema(src, 200)
    rsi = ta.rsi(src, 14)
    (src > ema200 ? 40 : 0) + (ema50 > ema200 ? 40 : 0) + (rsi > 50 ? 20 : 0)

f_secClose(sym) =>
    request.security(sym, macroTf, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_secScore(sym, inverse) =>
    request.security(sym, macroTf, f_norm(close, 252, inverse), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_secTrend(sym) =>
    request.security(sym, macroTf, f_trend(close) ? 1 : 0, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_secTech(sym) =>
    request.security(sym, macroTf, f_techScore(close), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DAILY DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
gold   = f_secClose("OANDA:XAUUSD")
silver = f_secClose("OANDA:XAGUSD")
dxy    = f_secClose("TVC:DXY")
us10y  = f_secClose("TVC:US10Y")
us02y  = f_secClose("TVC:US02Y")
vix    = f_secClose("CBOE:VIX")
spx    = f_secClose("SP:SPX")
copper = f_secClose("COMEX:HG1!")

goldSilver = gold / silver
goldSPX    = gold / spx
copperGold = copper / gold
yieldCurve = us10y - us02y

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DAILY SCORES — FIXED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
realYieldScore = f_secScore("TVC:US10Y", true)
dxyScore       = f_secScore("TVC:DXY", true)
liquidityScore = f_secScore("OANDA:XAUUSD", false)
rateScore      = f_secScore("TVC:US02Y", true)
riskScore      = f_secScore("CBOE:VIX", false)

b1 = f_secTrend("OANDA:XAUUSD")
b2 = f_secTrend("OANDA:XAUEUR")
b3 = f_secTrend("OANDA:XAUJPY")
b4 = f_secTrend("OANDA:XAUGBP")
b5 = f_secTrend("PEPPERSTONE:XAUCNH")

breadthCount = b1 + b2 + b3 + b4 + b5
breadthScore = breadthCount / 5.0 * 100.0

goldSilverScore = f_secScore("OANDA:XAGUSD", true)
goldSPXScore    = f_secScore("SP:SPX", true)
copperGoldScore = f_secScore("COMEX:HG1!", false)
yieldCurveScore = f_secScore("TVC:US10Y", false)

techScore = f_secTech("OANDA:XAUUSD")

composite =
     realYieldScore * 0.30 +
     dxyScore       * 0.25 +
     liquidityScore * 0.15 +
     rateScore      * 0.10 +
     riskScore      * 0.10 +
     breadthScore   * 0.10

macroStrength = composite * 0.70 + techScore * 0.30
scoreColor = f_col(composite)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
smoothScore = ta.ema(composite, 10)

pScore = plot(composite, "Gold Macro Score", color=scoreColor, linewidth=3)
pSmooth = plot(smoothScore, "Smoothed Score", color=color.new(txtMain, 40), linewidth=2)
pBase = plot(0, display=display.none)

fill(pScore, pBase, color=color.new(scoreColor, 84))

hline(80, "Strong Bull", color=color.new(green1, 35), linestyle=hline.style_dashed)
hline(60, "Bull", color=color.new(green2, 45), linestyle=hline.style_dashed)
hline(50, "Neutral", color=color.new(yellow1, 45), linestyle=hline.style_dashed)
hline(40, "Negative", color=color.new(orange1, 45), linestyle=hline.style_dashed)
hline(20, "Bear", color=color.new(red1, 40), linestyle=hline.style_dashed)

bgcolor(color.new(scoreColor, 92))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right, 20, 28, bgcolor=bgMain, frame_width=0, border_width=0, force_overlay=true)

f_driverRow(row, name, weight, score) =>
    table.cell(dash, 0, row, name, text_color=txtMain, bgcolor=bgMain, text_size=sz, text_halign=text.align_left)
    table.merge_cells(dash, 0, row, 3, row)
    table.cell(dash, 4, row, weight, text_color=txtMute, bgcolor=bgMain, text_size=sz)
    table.cell(dash, 5, row, f_status(score), text_color=f_col(score), bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 5, row, 8, row)
    table.cell(dash, 9, row, f_meterText(score, 16), text_color=f_col(score), bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 9, row, 18, row)
    table.cell(dash, 19, row, str.tostring(math.round(score)), text_color=f_col(score), bgcolor=bgMain, text_size=sz)

f_pairRow(row, pair, desc, bull) =>
    col = bull ? green1 : red1
    table.cell(dash, 0, row, pair, text_color=txtMain, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 0, row, 2, row)
    table.cell(dash, 3, row, desc, text_color=txtMute, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 3, row, 8, row)
    table.cell(dash, 9, row, bull ? "↗" : "↘", text_color=col, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 9, row, 10, row)
    table.cell(dash, 11, row, bull ? "STRONG" : "WEAK", text_color=col, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 11, row, 14, row)
    table.cell(dash, 15, row, bull ? "BULLISH" : "BEARISH", text_color=col, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 15, row, 19, row)

f_metricRow(row, name, val, score) =>
    table.cell(dash, 0, row, name, text_color=txtMain, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 0, row, 6, row)
    table.cell(dash, 7, row, val, text_color=txtMain, bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 7, row, 10, row)
    table.cell(dash, 11, row, str.tostring(math.round(score)), text_color=f_col(score), bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 11, row, 13, row)
    table.cell(dash, 14, row, f_status(score), text_color=f_col(score), bgcolor=bgMain, text_size=sz)
    table.merge_cells(dash, 14, row, 19, row)

if barstate.islast
    table.clear(dash, 0, 0, 19, 27)

    table.cell(dash, 0, 0, "GOLD MACRO by invincible3", text_color=goldCol, bgcolor=bgPanel2, text_size=szBig, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 19, 0)

    table.cell(dash, 0, 2, "GOLD MACRO SCORE\n\n" + str.tostring(math.round(composite)) + " / 100\n" + f_status(composite), text_color=scoreColor, bgcolor=bgPanel, text_size=szBig, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.merge_cells(dash, 0, 2, 5, 4)

    table.cell(dash, 6, 2, "MACRO REGIME\n\n" + f_status(composite) + "\n" + f_meterText(composite, 18), text_color=scoreColor, bgcolor=bgPanel, text_size=szBig, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.merge_cells(dash, 6, 2, 13, 4)

    table.cell(dash, 14, 2, "MACRO STRENGTH\n\n" + str.tostring(math.round(macroStrength)) + "%\n" + f_status(macroStrength), text_color=f_col(macroStrength), bgcolor=bgPanel, text_size=szBig, text_halign=text.align_center, text_font_family=font.family_monospace)
    table.merge_cells(dash, 14, 2, 19, 4)

    table.cell(dash, 0, 5, "MACRO DRIVER TABLE + DRIVER HEATMAP", text_color=txtMain, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 0, 5, 19, 5)

    table.cell(dash, 0, 6, "DRIVER", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 0, 6, 3, 6)
    table.cell(dash, 4, 6, "WT", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.cell(dash, 5, 6, "STATUS", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 5, 6, 8, 6)
    table.cell(dash, 9, 6, "METER", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 9, 6, 18, 6)
    table.cell(dash, 19, 6, "SCORE", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)

    f_driverRow(7, "Real Yield 10Y", "30%", realYieldScore)
    f_driverRow(8, "US Dollar DXY", "25%", dxyScore)
    f_driverRow(9, "Gold Liquidity Proxy", "15%", liquidityScore)
    f_driverRow(10, "Rate Outlook 2Y", "10%", rateScore)
    f_driverRow(11, "Risk-Off VIX", "10%", riskScore)
    f_driverRow(12, "Gold Breadth", "10%", breadthScore)

    table.cell(dash, 0, 13, "TOTAL", text_color=txtMain, bgcolor=bgPanel, text_size=sz)
    table.merge_cells(dash, 0, 13, 3, 13)
    table.cell(dash, 4, 13, "100%", text_color=txtMain, bgcolor=bgPanel, text_size=sz)
    table.cell(dash, 5, 13, f_status(composite), text_color=scoreColor, bgcolor=bgPanel, text_size=sz)
    table.merge_cells(dash, 5, 13, 8, 13)
    table.cell(dash, 9, 13, f_meterText(composite, 16), text_color=scoreColor, bgcolor=bgPanel, text_size=sz)
    table.merge_cells(dash, 9, 13, 18, 13)
    table.cell(dash, 19, 13, str.tostring(math.round(composite)), text_color=scoreColor, bgcolor=bgPanel, text_size=sz)

    table.cell(dash, 0, 15, "GOLD BREADTH — CROSS-CURRENCY", text_color=txtMain, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 0, 15, 19, 15)

    table.cell(dash, 0, 16, "PAIR", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 0, 16, 2, 16)
    table.cell(dash, 3, 16, "MARKET", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 3, 16, 8, 16)
    table.cell(dash, 9, 16, "TREND", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 9, 16, 10, 16)
    table.cell(dash, 11, 16, "STRENGTH", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 11, 16, 14, 16)
    table.cell(dash, 15, 16, "STATUS", text_color=txtMute, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 15, 16, 19, 16)

    f_pairRow(17, "XAUUSD", "Gold / US Dollar", b1 == 1)
    f_pairRow(18, "XAUEUR", "Gold / Euro", b2 == 1)
    f_pairRow(19, "XAUJPY", "Gold / Yen", b3 == 1)
    f_pairRow(20, "XAUGBP", "Gold / Pound", b4 == 1)
    f_pairRow(21, "XAUCNH", "Gold / Yuan", b5 == 1)

    table.cell(dash, 0, 22, "BREADTH SCORE", text_color=txtMain, bgcolor=bgPanel, text_size=sz)
    table.merge_cells(dash, 0, 22, 4, 22)
    table.cell(dash, 5, 22, str.tostring(breadthCount) + " / 5", text_color=f_col(breadthScore), bgcolor=bgPanel, text_size=szBig)
    table.merge_cells(dash, 5, 22, 8, 22)
    table.cell(dash, 9, 22, f_meterText(breadthScore, 16), text_color=f_col(breadthScore), bgcolor=bgPanel, text_size=sz)
    table.merge_cells(dash, 9, 22, 18, 22)
    table.cell(dash, 19, 22, f_status(breadthScore), text_color=f_col(breadthScore), bgcolor=bgPanel, text_size=sz)

    table.cell(dash, 0, 23, "OTHER CONFIRMATION METRICS", text_color=txtMain, bgcolor=bgPanel2, text_size=sz)
    table.merge_cells(dash, 0, 23, 19, 23)

    f_metricRow(24, "Gold / Silver", str.tostring(goldSilver, "#.##"), goldSilverScore)
    f_metricRow(25, "Gold / S&P 500", str.tostring(goldSPX, "#.####"), goldSPXScore)
    f_metricRow(26, "Copper / Gold", str.tostring(copperGold, "#.####"), copperGoldScore)
    f_metricRow(27, "US 10Y - 2Y", str.tostring(yieldCurve, "#.##") + "%", yieldCurveScore)
````
