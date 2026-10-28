# QARAR EGX Market Map + Rolling Wave Pro [Samir Ayman]

- url: https://www.tradingview.com/script/EBuXGCro-QARAR-EGX-Market-Map-Rolling-Wave-Pro-Samir-Ayman/
- type: indicator
- pine_id: PUB;b8ec6c18c88c4089a9504f3071bb8abd
- version: 1.0

## Description

🚀 QARAR EGX Market Map + Rolling Wave Pro

Today, I’m excited to introduce QARAR EGX Market Map + Rolling Wave Pro — a professional market visualization and trend analysis tool built specifically for the Egyptian Stock Exchange.

This indicator is designed to provide a complete market overview, combining institutional-style market monitoring with advanced trend analysis in a single dashboard.

📊 EGX30 Market Map

The Market Map displays the top 30 EGX companies, ranked by their relative importance within the index.

Each cell shows:

🔹 Company Rank
🔹 Stock Ticker
🔹 Daily Percentage Change

Using a professional heatmap color system inspired by leading market platforms such as:

• Bloomberg
• Finviz
• StockCharts

This allows traders and investors to instantly identify:

🟢 Strong sectors and leading stocks
🔴 Weak areas under selling pressure
⚪ Neutral market zones

All within seconds.

🌊 Rolling Wave Pro

Rolling Wave Pro is a custom trend engine developed to simplify trend analysis while maintaining institutional-level clarity.

Key Features:

✔ Smooth Adaptive Trend Wave
✔ Dynamic Color Gradient System
✔ Trend Strength Visualization
✔ ATR-Based Momentum Analysis
✔ Market Speed Detection (Fast / Slow)
✔ Advanced Trend Dashboard

Instead of stacking multiple indicators on your chart, Rolling Wave Pro delivers:

✅ Trend Direction
✅ Trend Strength
✅ Trend Speed
✅ Market Context

Inside one clean and professional framework.

🎯 Who Is This Indicator For?

✔ Swing Traders
✔ Position Traders
✔ Long-Term Investors
✔ EGX30 Traders
✔ Traders looking for institutional-style market analysis

💡 How To Use It
Step 1

Monitor the Market Map to understand where money is flowing inside the market.

Step 2

Identify stocks showing relative strength compared to the broader market.

Step 3

Use Rolling Wave Pro to evaluate:

• Trend Direction
• Momentum Strength
• Continuation Potential
• Pullback Opportunities

Step 4

Combine stock strength with overall market conditions to make higher-quality trading and investment decisions.

🔥 What Makes It Different?

Unlike traditional indicators that focus only on a single stock, QARAR EGX Market Map + Rolling Wave Pro combines:

📈 Market Breadth Analysis
📈 Relative Strength Monitoring
📈 Trend Structure Visualization
📈 Institutional Heatmap Technology

Giving traders a broader perspective before making decisions.

QARAR

Smart Analysis. Better Decision.

#QARAR
#EGX
#EGX30
#EgyptianStockMarket
#TradingView
#MarketMap
#Heatmap
#SwingTrading
#Investing
#Stocks
#TechnicalAnalysis
#StockMarket
#MarketIntelligence

Developed as part of the QARAR Market Intelligence ecosystem to provide institutional-grade market analysis for Egyptian equities.

## Source Code

````pine
//@version=6
indicator("QARAR EGX Market Map + Rolling Wave Pro", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMain = "QARAR EGX Heatmap"
showDash  = input.bool(true, "Show EGX Heatmap", group=groupMain)
dashPosIn = input.string("Top Right", "Heatmap Position", options=["Top Right", "Middle Right", "Bottom Right", "Bottom Left"], group=groupMain)
themeMode = input.string("Dark", "Theme Mode", options=["Dark", "Light"], group=groupMain)

groupSymbols = "EGX30 Symbols Ordered By Index Weight"
s01 = input.string("COMI", "01", group=groupSymbols)
s02 = input.string("TMGH", "02", group=groupSymbols)
s03 = input.string("ETEL", "03", group=groupSymbols)
s04 = input.string("EGAL", "04", group=groupSymbols)
s05 = input.string("EAST", "05", group=groupSymbols)
s06 = input.string("ABUK", "06", group=groupSymbols)
s07 = input.string("ORAS", "07", group=groupSymbols)
s08 = input.string("EFIH", "08", group=groupSymbols)
s09 = input.string("ADIB", "09", group=groupSymbols)
s10 = input.string("FWRY", "10", group=groupSymbols)
s11 = input.string("HRHO", "11", group=groupSymbols)
s12 = input.string("VLMRA", "12", group=groupSymbols)
s13 = input.string("SWDY", "13", group=groupSymbols)
s14 = input.string("JUFO", "14", group=groupSymbols)
s15 = input.string("MFPC", "15", group=groupSymbols)
s16 = input.string("SKPC", "16", group=groupSymbols)
s17 = input.string("PHDC", "17", group=groupSymbols)
s18 = input.string("HELI", "18", group=groupSymbols)
s19 = input.string("ORWE", "19", group=groupSymbols)
s20 = input.string("CCAP", "20", group=groupSymbols)
s21 = input.string("RAYA", "21", group=groupSymbols)
s22 = input.string("AMOC", "22", group=groupSymbols)
s23 = input.string("EFID", "23", group=groupSymbols)
s24 = input.string("CLHO", "24", group=groupSymbols)
s25 = input.string("CIEB", "25", group=groupSymbols)
s26 = input.string("ISPH", "26", group=groupSymbols)
s27 = input.string("ORHD", "27", group=groupSymbols)
s28 = input.string("MASR", "28", group=groupSymbols)
s29 = input.string("OLFI", "29", group=groupSymbols)
s30 = input.string("ALCN", "30", group=groupSymbols)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ROLLING WAVE INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupRoll = "Rolling Wave Pro"
showRolling           = input.bool(true, "Show Rolling Wave", group=groupRoll)
showRollingPanel      = input.bool(true, "Show Rolling Dashboard", group=groupRoll)
rollingPanelPos       = input.string("Middle Right", "Rolling Dashboard Position", options=["Top Right", "Middle Right", "Bottom Right", "Bottom Left"], group=groupRoll)
fastLengthInput       = input.int(5, "Fast Slope Length", minval=1, group=groupRoll)
slowLengthInput       = input.int(10, "Slow Slope Length", minval=1, group=groupRoll)
atrLengthInput        = input.int(200, "ATR Length", minval=1, group=groupRoll)
fastThresholdInput    = input.float(1.0, "Fast Threshold ATR", minval=0, step=0.1, group=groupRoll)
reverseThresholdInput = input.float(2.0, "Reverse Threshold ATR", minval=0, step=0.1, group=groupRoll)
waveSmoothLen         = input.int(8, "Wave Smoothness", minval=1, maxval=50, group=groupRoll)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isLight = themeMode == "Light"

qPanelHead = color.rgb(17, 24, 39)
qPanelBody = isLight ? color.rgb(248, 250, 252) : color.rgb(11, 18, 32)
qBorder    = isLight ? color.rgb(148, 163, 184) : color.rgb(36, 50, 71)
qText      = isLight ? color.rgb(15, 23, 42) : color.rgb(248, 250, 252)
qWhiteText = color.rgb(248, 250, 252)
qMuted     = isLight ? color.rgb(71, 85, 105) : color.rgb(203, 213, 225)

// StockCharts-style heat scale
heatBear5   = color.rgb(120, 0, 0)
heatBear4   = color.rgb(170, 20, 30)
heatBear3   = color.rgb(220, 55, 65)
heatBear2   = color.rgb(242, 110, 120)
heatNeutral = color.rgb(95, 102, 118)
heatBull2   = color.rgb(70, 170, 120)
heatBull3   = color.rgb(25, 135, 84)
heatBull4   = color.rgb(0, 100, 60)
heatBull5   = color.rgb(0, 70, 45)

// Rolling colors
qRollBearStrong = heatBear3
qRollBearMid    = heatBear2
qRollNeutral    = color.rgb(212, 167, 86)
qRollBullMid    = heatBull2
qRollBullStrong = color.rgb(94, 234, 212)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ROLLING WAVE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrRoll = ta.atr(atrLengthInput)

var float rollRaw = close
var int rollTrend = 1
var float activeSlope = 0.0
var bool isFastMode = false

bullReversal = false
bearReversal = false

if not na(atrRoll)
    distFromSeg = close - rollRaw
    bullReversal := rollTrend == -1 and distFromSeg > reverseThresholdInput * atrRoll
    bearReversal := rollTrend == 1 and -distFromSeg > reverseThresholdInput * atrRoll

    if bullReversal
        rollTrend := 1
    else if bearReversal
        rollTrend := -1

    newIsFastMode = math.abs(distFromSeg) > fastThresholdInput * atrRoll
    speedChanged = newIsFastMode != isFastMode

    if bullReversal or bearReversal or speedChanged or activeSlope == 0.0
        isFastMode := newIsFastMode
        activeSlope := isFastMode ? atrRoll / fastLengthInput : atrRoll / slowLengthInput

    rollRaw := rollRaw + rollTrend * activeSlope
else
    rollRaw := close

rollWave = ta.ema(rollRaw, waveSmoothLen)

distATR = atrRoll > 0 ? math.abs(close - rollWave) / atrRoll : 0.0
strength01 = math.min(distATR, 3.0) / 3.0

slopeWave = rollWave - rollWave[1]
slopeText = (slopeWave > 0 ? "+" : "") + str.tostring(slopeWave, format.mintick)
distText = (close - rollWave > 0 ? "+" : "") + str.tostring(close - rollWave, format.mintick) + " (" + str.tostring(distATR, "#.##") + " ATR)"
trendText = rollTrend == 1 ? "BULLISH" : "BEARISH"
modeText = isFastMode ? "FAST" : "SLOW"

waveColor = rollTrend == 1 ? color.from_gradient(strength01, 0, 1, qRollNeutral, qRollBullStrong) : color.from_gradient(strength01, 0, 1, qRollNeutral, qRollBearStrong)

fillTop = rollTrend == 1 ? color.new(qRollBullStrong, 72) : color.new(qRollNeutral, 92)
fillBottom = rollTrend == 1 ? color.new(qRollNeutral, 92) : color.new(qRollBearStrong, 72)

pWave  = plot(showRolling ? rollWave : na, "QARAR Rolling Wave", color=waveColor, linewidth=4)
pPrice = plot(showRolling ? close : na, "Price Reference", display=display.none)

fill(
     pPrice,
     pWave,
     top_value=math.max(close, rollWave),
     bottom_value=math.min(close, rollWave),
     top_color=close >= rollWave ? fillTop : fillBottom,
     bottom_color=close >= rollWave ? fillBottom : fillTop,
     title="Rolling Wave Gradient Zone"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_cleanSymbol(string sym) =>
    str.trim(sym)

f_ticker(string sym) =>
    str.replace_all(str.replace_all(str.trim(sym), "EGX:", ""), "EGX_", "")

f_dailyChange(string sym) =>
    request.security(f_cleanSymbol(sym), "D", (close / close[1] - 1.0) * 100.0, barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

f_signed(float v) =>
    na(v) ? "N/A" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

f_cellColor(float ch) =>
    na(ch) ? heatNeutral :
     ch <= -5.0 ? heatBear5 :
     ch <= -3.0 ? heatBear4 :
     ch <= -1.5 ? heatBear3 :
     ch <= -0.5 ? heatBear2 :
     ch < 0.5 ? heatNeutral :
     ch < 1.5 ? heatBull2 :
     ch < 3.0 ? heatBull3 :
     ch < 5.0 ? heatBull4 :
     heatBull5

f_drawCell(table t, int col, int row, int rank, string sym) =>
    ch = f_dailyChange(sym)
    label = "#" + str.tostring(rank) + "  " + f_ticker(sym) + "\n" + f_signed(ch)
    table.cell(t, col, row, label, text_color=qWhiteText, bgcolor=f_cellColor(ch), text_size=size.small, text_halign=text.align_center, text_valign=text.align_center)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEATMAP DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dashPos =
     dashPosIn == "Top Right" ? position.top_right :
     dashPosIn == "Middle Right" ? position.middle_right :
     dashPosIn == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table dash = table.new(dashPos, 5, 7, bgcolor=qPanelBody, frame_color=qBorder, frame_width=2, border_color=qBorder, border_width=1)

if barstate.islast
    if showDash
        table.cell(dash, 0, 0, "QARAR EGX30 MARKET MAP | Daily Change + Rolling Context", bgcolor=qPanelHead, text_color=qWhiteText, text_size=size.small)
        table.merge_cells(dash, 0, 0, 4, 0)

        f_drawCell(dash, 0, 1, 1,  s01), f_drawCell(dash, 1, 1, 2,  s02), f_drawCell(dash, 2, 1, 3,  s03), f_drawCell(dash, 3, 1, 4,  s04), f_drawCell(dash, 4, 1, 5,  s05)
        f_drawCell(dash, 0, 2, 6,  s06), f_drawCell(dash, 1, 2, 7,  s07), f_drawCell(dash, 2, 2, 8,  s08), f_drawCell(dash, 3, 2, 9,  s09), f_drawCell(dash, 4, 2, 10, s10)
        f_drawCell(dash, 0, 3, 11, s11), f_drawCell(dash, 1, 3, 12, s12), f_drawCell(dash, 2, 3, 13, s13), f_drawCell(dash, 3, 3, 14, s14), f_drawCell(dash, 4, 3, 15, s15)
        f_drawCell(dash, 0, 4, 16, s16), f_drawCell(dash, 1, 4, 17, s17), f_drawCell(dash, 2, 4, 18, s18), f_drawCell(dash, 3, 4, 19, s19), f_drawCell(dash, 4, 4, 20, s20)
        f_drawCell(dash, 0, 5, 21, s21), f_drawCell(dash, 1, 5, 22, s22), f_drawCell(dash, 2, 5, 23, s23), f_drawCell(dash, 3, 5, 24, s24), f_drawCell(dash, 4, 5, 25, s25)
        f_drawCell(dash, 0, 6, 26, s26), f_drawCell(dash, 1, 6, 27, s27), f_drawCell(dash, 2, 6, 28, s28), f_drawCell(dash, 3, 6, 29, s29), f_drawCell(dash, 4, 6, 30, s30)

        
        

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ROLLING DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rollPanelPosition =
     rollingPanelPos == "Top Right" ? position.top_right :
     rollingPanelPos == "Middle Right" ? position.middle_right :
     rollingPanelPos == "Bottom Right" ? position.bottom_right :
     position.bottom_left

var table rollPanel = table.new(rollPanelPosition, 10, 11, bgcolor=qPanelBody, frame_color=qBorder, frame_width=2, border_color=qBorder, border_width=1)

f_row(string title, string value, int row, color valueColor) =>
    table.cell(rollPanel, 0, row, title, text_color=qMuted, bgcolor=qPanelBody, text_size=size.small, text_halign=text.align_left)
    table.merge_cells(rollPanel, 0, row, 3, row)
    table.cell(rollPanel, 4, row, value, text_color=valueColor, bgcolor=qPanelBody, text_size=size.small, text_halign=text.align_left)
    table.merge_cells(rollPanel, 4, row, 9, row)

f_gradCell(int col, int row, color bg, string txt) =>
    table.cell(rollPanel, col, row, txt, bgcolor=bg, text_color=qWhiteText, text_size=size.tiny, text_halign=text.align_center)

if barstate.islast
    if showRollingPanel
        table.cell(rollPanel, 0, 0, "ROLLING WAVE PRO", bgcolor=qPanelHead, text_color=qWhiteText, text_size=size.small, text_halign=text.align_center)
        table.merge_cells(rollPanel, 0, 0, 9, 0)

        f_row("Trend:", trendText, 1, waveColor)
        f_row("Mode:", modeText, 2, waveColor)
        f_row("Slope:", slopeText, 3, waveColor)
        f_row("Distance:", distText, 4, waveColor)
        f_row("ATR(" + str.tostring(atrLengthInput) + "):", str.tostring(atrRoll, format.mintick), 5, qText)

        table.cell(rollPanel, 0, 6, "TREND STRENGTH", bgcolor=qPanelHead, text_color=qWhiteText, text_size=size.small, text_halign=text.align_center)
        table.merge_cells(rollPanel, 0, 6, 9, 6)

        markerIndex = int(math.round(strength01 * 9))

        for i = 0 to 9
            gColor = i <= 2 ? color.from_gradient(i, 0, 2, qRollBearStrong, qRollBearMid) :
                     i <= 5 ? color.from_gradient(i, 3, 5, qRollBearMid, qRollNeutral) :
                     i <= 7 ? color.from_gradient(i, 6, 7, qRollNeutral, qRollBullMid) :
                     color.from_gradient(i, 8, 9, qRollBullMid, qRollBullStrong)

            mTxt = i == markerIndex ? "▼" : ""
            f_gradCell(i, 7, gColor, mTxt)

        table.cell(rollPanel, 0, 8, "Weak", text_color=qRollBearStrong, bgcolor=qPanelBody, text_size=size.tiny, text_halign=text.align_left)
        table.merge_cells(rollPanel, 0, 8, 2, 8)

        table.cell(rollPanel, 3, 8, "Medium", text_color=qRollNeutral, bgcolor=qPanelBody, text_size=size.tiny, text_halign=text.align_center)
        table.merge_cells(rollPanel, 3, 8, 6, 8)

        table.cell(rollPanel, 7, 8, "Strong", text_color=qRollBullStrong, bgcolor=qPanelBody, text_size=size.tiny, text_halign=text.align_right)
        table.merge_cells(rollPanel, 7, 8, 9, 8)

        strengthBg = color.from_gradient(strength01, 0, 1, qRollBearStrong, qRollBullStrong)
        table.cell(rollPanel, 0, 9, "Strength: " + str.tostring(strength01 * 100, "#") + "%", text_color=qWhiteText, bgcolor=color.new(strengthBg, 15), text_size=size.small, text_halign=text.align_center)
        table.merge_cells(rollPanel, 0, 9, 9, 9)

        table.cell(rollPanel, 0, 10, rollTrend == 1 ? "Momentum favors buyers while price holds above the wave" : "Momentum favors sellers while price trades below the wave", text_color=qMuted, bgcolor=qPanelBody, text_size=size.tiny, text_halign=text.align_center)
        table.merge_cells(rollPanel, 0, 10, 9, 10)
    else
        table.clear(rollPanel, 0, 0, 9, 10)
````
