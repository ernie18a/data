# Pakistan Macro Dashboard [invincible3] 

- url: https://www.tradingview.com/script/J8k8CZLu-Pakistan-Macro-Dashboard-invincible3/
- type: indicator
- pine_id: PUB;b752f9a942944b82877659edc7d37e27
- version: 1.0

## Description

[b]Pakistan Macro Dashboard  [invincible3][/b]

Pakistan Macro Dashboard  is a macroeconomic cycle oscillator and dashboard designed to analyze Pakistan’s equity-market environment using policy-rate, inflation, currency, liquidity, external-balance, commodity, and KSE100 trend conditions.

The core oscillator focuses on Pakistan’s monetary cycle. It uses the Pakistan policy rate, its cumulative historical mean, inflation trend, inflation level, and real-rate balance to create a macro score from 0 to 100. Higher values suggest improving liquidity and a more supportive equity backdrop, while lower values suggest restrictive conditions and elevated macro pressure.

A key feature of this indicator is the policy-rate cycle background. The background color is based on the relationship between the current Pakistan policy rate and its cumulative mean:

Red background: policy rate is above its mean and rising, indicating restrictive tightening.

Orange background: policy rate is above its mean but falling, indicating early easing or potential recovery.

Green background: policy rate is below its mean and falling, indicating liquidity expansion.

Yellow background: policy rate is below its mean but rising, indicating early tightening or late-cycle caution.

The oscillator pane also includes optional curves for the macro oscillator, policy rate, cumulative mean policy rate, and inflation rate. Users can independently enable or disable each curve, each label, the background cycle color, and the horizontal risk levels.

The dashboard is displayed on the main chart and provides a structured macro view of Pakistan’s market conditions. It includes policy and inflation readings, real rates, GDP growth, unemployment, USD/PKR, FX reserves, current account, trade balance, remittances, external debt, Brent oil, DXY, emerging-market risk, gold, KSE100 trend, RSI, and sector tilt readings.

The table is divided into two parallel panels:

Left panel: policy cycle, core macro, growth, liquidity, FX view, inflation action, sector tilt, and final PSX bias.

Right panel: external pressure, global commodity pressure, KSE100 trend, and sector read.

The scoring system uses a simple green/yellow/orange/red color structure:

Green: supportive or improving conditions.

Yellow: neutral, mixed, or transition phase.

Orange: caution or pressure building.

Red: high macro risk or unfavorable condition.

This tool is designed for top-down macro analysis of the Pakistan equity market. It can help traders and investors understand whether the broader environment is supportive, neutral, or defensive before evaluating individual stocks or sectors.

[b]Important:[/b] This indicator is for educational and analytical use only. It is not financial advice and should not be used as a standalone buy or sell signal. Users should combine it with price action, market structure, risk management, and their own independent analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © invincible3

//@version=6
indicator("Pakistan Macro Dashboard [invincible3] ", shorttitle="PK", overlay=false, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — OSCILLATOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpOsc = "Oscillator Data"

ecoTf = input.timeframe("M", "Economic Data Timeframe", group=grpOsc)

policySym = input.symbol("ECONOMICS:PKINTR", "Pakistan Policy Rate", group=grpOsc)
inflSym   = input.symbol("ECONOMICS:PKIRYY", "Pakistan Inflation YoY", group=grpOsc)

inflThreshold = input.float(7.0, "Inflation Upper Threshold", step=0.1, group=grpOsc)
inflTarget    = input.float(5.0, "Inflation Target", step=0.1, group=grpOsc)

policyChangeScale = input.float(2.0, "Policy Rate Monthly Change Scale", minval=0.1, step=0.1, group=grpOsc)
policyLevelScale  = input.float(5.0, "Policy Rate Level Pressure Scale", minval=0.5, step=0.5, group=grpOsc)
inflChangeScale   = input.float(5.0, "Inflation Monthly Change Scale", minval=0.5, step=0.5, group=grpOsc)
inflLevelScale    = input.float(7.0, "Inflation Level Pressure Scale", minval=0.5, step=0.5, group=grpOsc)

realNeutral = input.float(1.0, "Neutral Real Rate", step=0.1, group=grpOsc)
realScale   = input.float(8.0, "Real Rate Balance Scale", minval=1.0, step=0.5, group=grpOsc)

smoothLen = input.int(3, "Macro Score Smoothing", minval=1, group=grpOsc)

// Display controls
showOscCurve       = input.bool(true, "Show Macro Oscillator Curve", group=grpOsc)
showPolicyCurve    = input.bool(true, "Show Interest Rate Curve", group=grpOsc)
showMeanCurve      = input.bool(true, "Show Mean Interest Rate Curve", group=grpOsc)
showInflationCurve = input.bool(true, "Show Inflation Rate Curve", group=grpOsc)

showBg             = input.bool(true, "Show Policy Rate Cycle Background", group=grpOsc)
showLevelLines     = input.bool(true, "Show 20/40/50/60/80 Level Lines", group=grpOsc)

showLabels         = input.bool(true, "Show Oscillator Labels", group=grpOsc)
showOscLabel       = input.bool(true, "Show Macro Oscillator Label", group=grpOsc)
showPolicyLabel    = input.bool(true, "Show Interest Rate Label", group=grpOsc)
showMeanLabel      = input.bool(true, "Show Mean Rate Label", group=grpOsc)
showInflLabel      = input.bool(true, "Show Inflation Label", group=grpOsc)

labelOffset        = input.int(3, "Label Offset Bars", minval=1, maxval=30, group=grpOsc)
labelGap           = input.float(1.2, "Label Vertical Gap", step=0.1, group=grpOsc)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — DASHBOARD MARKET SYMBOLS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpMkt = "Dashboard Market Symbols"

oilSym  = input.symbol("TVC:UKOIL", "Brent Oil", group=grpMkt)
pkrSym  = input.symbol("FX_IDC:USDPKR", "USD/PKR", group=grpMkt)
psxSym  = input.symbol("PSX:KSE100", "KSE100 / PSX", group=grpMkt)
goldSym = input.symbol("TVC:GOLD", "Gold", group=grpMkt)
dxySym  = input.symbol("TVC:DXY", "Dollar Index", group=grpMkt)
emSym   = input.symbol("AMEX:EEM", "Emerging Market ETF", group=grpMkt)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — DASHBOARD ECONOMY SYMBOLS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpEco = "Dashboard Pakistan Economy Symbols"

gdpSym  = input.symbol("ECONOMICS:PKGDPQQ", "Pakistan GDP Growth Rate", group=grpEco)
urSym   = input.symbol("ECONOMICS:PKUR", "Pakistan Unemployment Rate", group=grpEco)
fxrSym  = input.symbol("ECONOMICS:PKFER", "Foreign Exchange Reserves", group=grpEco)
remSym  = input.symbol("ECONOMICS:PKREM", "Remittances", group=grpEco)
debtSym = input.symbol("ECONOMICS:PKED", "External Debt Proxy", group=grpEco)
botSym  = input.symbol("ECONOMICS:PKBOT", "Balance of Trade", group=grpEco)
caSym   = input.symbol("ECONOMICS:PKCA", "Current Account", group=grpEco)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — DASHBOARD THRESHOLDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpThr = "Dashboard Scoring Thresholds"

rateGood = input.float(12.0, "Interest Rate Good Below %", group=grpThr)
rateBad  = input.float(18.0, "Interest Rate Bad Above %", group=grpThr)
inflGood = input.float(8.0, "Inflation Good Below %", group=grpThr)
inflBad  = input.float(18.0, "Inflation Bad Above %", group=grpThr)
gdpWeak  = input.float(2.0, "GDP Growth Weak Below %", group=grpThr)
gdpGood  = input.float(4.0, "GDP Growth Strong Above %", group=grpThr)
oilGood  = input.float(70.0, "Oil Supportive Below", group=grpThr)
oilBad   = input.float(95.0, "Oil Stress Above", group=grpThr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS — DASHBOARD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpSet = "Dashboard Settings"

dashPos  = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpSet)
showDash = input.bool(true, "Show Dashboard On Chart", group=grpSet)
fontOpt  = input.string("Small", "Font Size", options=["Tiny", "Small", "Normal"], group=grpSet)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTIONS — GENERAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_clampRange(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_clamp100(float x) =>
    math.max(0.0, math.min(100.0, x))

f_luma(color c) =>
    0.2126 * color.r(c) + 0.7152 * color.g(c) + 0.0722 * color.b(c)

f_fmt(float x, string suffix = "") =>
    na(x) ? "n/a" : str.tostring(x, "#.##") + suffix

f_pos(string p) =>
    p == "Top Right" ? position.top_right :
     p == "Top Left" ? position.top_left :
     p == "Bottom Right" ? position.bottom_right :
     position.bottom_left

f_size(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     size.normal

f_scoreSigned(float x, float scale) =>
    50.0 + 50.0 * f_clampRange(x / scale, -1.0, 1.0)

f_weightedScore(float s1, float w1, float s2, float w2, float s3, float w3, float s4, float w4, float s5, float w5) =>
    float num = 0.0
    float den = 0.0

    if not na(s1) and w1 > 0
        num += s1 * w1
        den += w1

    if not na(s2) and w2 > 0
        num += s2 * w2
        den += w2

    if not na(s3) and w3 > 0
        num += s3 * w3
        den += w3

    if not na(s4) and w4 > 0
        num += s4 * w4
        den += w4

    if not na(s5) and w5 > 0
        num += s5 * w5
        den += w5

    den > 0 ? num / den : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIMPLE GREEN / YELLOW / ORANGE / RED THEME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isDarkTheme = f_luma(chart.bg_color) < 128.0

bgMain    = chart.bg_color
bgSection = color.new(chart.fg_color, isDarkTheme ? 86 : 88)
bgHeader  = color.new(chart.fg_color, isDarkTheme ? 82 : 84)

txtMain  = chart.fg_color
txtMuted = color.new(chart.fg_color, 25)

goodGreen   = color.rgb(28, 145, 85)
softGreen   = color.rgb(86, 170, 95)
neutralYel  = color.rgb(220, 178, 55)
riskOrange  = color.rgb(220, 120, 45)
badRed      = color.rgb(195, 55, 55)

green  = goodGreen
red    = badRed
yellow = neutralYel
orange = riskOrange
gray   = txtMuted
blue   = softGreen

f_scoreColor(float score) =>
    v = na(score) ? 50.0 : math.max(0.0, math.min(100.0, score))
    v >= 75 ? goodGreen :
     v >= 60 ? softGreen :
     v >= 45 ? neutralYel :
     v >= 30 ? riskOrange :
     badRed

f_readableText(color c) =>
    f_luma(c) > 150 ? color.rgb(20, 20, 20) : color.white

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[policyRate, policyPrev, policyTime] = request.security(
     policySym,
     ecoTf,
     [close, close[1], time],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true)

policyMean = request.security(
     policySym,
     ecoTf,
     ta.cum(close) / (bar_index + 1),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true)

[inflation, inflPrev] = request.security(
     inflSym,
     ecoTf,
     [close, close[1]],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR LOGIC — POLICY-RATE MACRO SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
policyChange = policyRate - policyPrev
inflChange   = inflation - inflPrev
realRate     = policyRate - inflation

policyRising  = not na(policyChange) and policyChange > 0
policyFalling = not na(policyChange) and policyChange < 0

inflRising  = not na(inflChange) and inflChange > 0
inflFalling = not na(inflChange) and inflChange < 0

policyTrendScore = f_scoreSigned(-policyChange, policyChangeScale)
policyLevelScore = f_scoreSigned(policyMean - policyRate, policyLevelScale)

inflTrendScore = f_scoreSigned(-inflChange, inflChangeScale)
inflLevelScore = f_scoreSigned(inflThreshold - inflation, inflLevelScale)

realRateScore = not na(realRate) ? 100.0 - 100.0 * f_clampRange(math.abs(realRate - realNeutral) / realScale, 0.0, 1.0) : na

rawScore = f_weightedScore(
     policyTrendScore, 40,
     policyLevelScore, 25,
     inflTrendScore, 12.5,
     inflLevelScore, 12.5,
     realRateScore, 10)

oscScore = ta.ema(rawScore, smoothLen)
oscColor = f_scoreColor(oscScore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// POLICY-RATE-BASED BACKGROUND
// Policy > mean + rising  = red
// Policy > mean + falling = orange / relief
// Policy < mean + falling = green
// Policy < mean + rising  = yellow / caution
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgTransp = isDarkTheme ? 86 : 88

color monthlyCol = na

if not na(policyRate) and not na(policyMean)
    if policyRate > policyMean and policyRising
        monthlyCol := color.new(badRed, bgTransp)
    else if policyRate > policyMean and policyFalling
        monthlyCol := color.new(riskOrange, bgTransp)
    else if policyRate < policyMean and policyFalling
        monthlyCol := color.new(goodGreen, bgTransp)
    else if policyRate < policyMean and policyRising
        monthlyCol := color.new(neutralYel, bgTransp)

var color lastBgCol = na

newPolicyMonth = ta.change(policyTime) != 0

if newPolicyMonth
    if not na(monthlyCol)
        lastBgCol := monthlyCol

if na(lastBgCol) and not na(monthlyCol)
    lastBgCol := monthlyCol

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MONO-COLOR MACRO LINES
// Only oscillator keeps dynamic color.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
policyLineColor = color.rgb(55, 120, 220)
meanLineColor   = color.rgb(230, 155, 45)
inflLineColor   = color.rgb(145, 85, 210)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REGIME TEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
policyRegime =
     policyRate > policyMean and policyRising  ? "Restrictive Tightening" :
     policyRate > policyMean and policyFalling ? "High-Rate Easing" :
     policyRate < policyMean and policyFalling ? "Liquidity Expansion" :
     policyRate < policyMean and policyRising  ? "Early Tightening" :
     "Neutral / Flat"

inflRegime =
     inflation > inflThreshold and inflRising  ? "Inflation Stress" :
     inflation > inflThreshold and inflFalling ? "Disinflation Relief" :
     inflation <= inflThreshold and inflFalling ? "Benign Disinflation" :
     inflation <= inflThreshold and inflRising  ? "Inflation Rebound" :
     "Neutral / Flat"

oscBias =
     oscScore >= 70 ? "Strong Risk-On" :
     oscScore >= 60 ? "Risk-On" :
     oscScore >= 45 ? "Neutral / Transition" :
     oscScore >= 30 ? "Risk-Off" :
     "Strong Risk-Off"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR PLOTS — USER CONTROLLED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgcolor(showBg ? lastBgCol : na)

plot(showOscCurve ? oscScore : na, title="Pakistan Equity Macro Oscillator", color=oscColor, linewidth=3)

plot(showPolicyCurve ? policyRate : na, title="Interest Rate", color=policyLineColor, linewidth=2)
plot(showMeanCurve ? policyMean : na, title="Mean Interest Rate", color=meanLineColor, linewidth=2)
plot(showInflationCurve ? inflation : na, title="Inflation YoY", color=inflLineColor, linewidth=2)

hline(80, "Strong Risk-On", color=showLevelLines ? color.new(goodGreen, 65) : na)
hline(60, "Risk-On", color=showLevelLines ? color.new(softGreen, 70) : na)
hline(50, "Neutral", color=showLevelLines ? color.new(chart.fg_color, 75) : na)
hline(40, "Risk-Off", color=showLevelLines ? color.new(riskOrange, 70) : na)
hline(20, "Strong Risk-Off", color=showLevelLines ? color.new(badRed, 65) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OSCILLATOR LABELS — USER CONTROLLED
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label oscLbl  = na
var label rateLbl = na
var label meanLbl = na
var label inflLbl = na

if barstate.islast
    label.delete(oscLbl)
    label.delete(rateLbl)
    label.delete(meanLbl)
    label.delete(inflLbl)

    if showLabels
        if showOscLabel and showOscCurve
            oscLbl := label.new(
                 bar_index + labelOffset,
                 oscScore,
                 "Macro Osc: " + f_fmt(oscScore) + " | " + oscBias,
                 style=label.style_label_left,
                 color=color.new(oscColor, 0),
                 textcolor=f_readableText(oscColor),
                 yloc=yloc.price)

        if showPolicyLabel and showPolicyCurve
            rateLbl := label.new(
                 bar_index + labelOffset,
                 policyRate + labelGap,
                 "Interest Rate: " + f_fmt(policyRate, "%") + " | " + (policyRising ? "Rising" : policyFalling ? "Falling" : "Flat"),
                 style=label.style_label_left,
                 color=color.new(policyLineColor, 0),
                 textcolor=color.white,
                 yloc=yloc.price)

        if showMeanLabel and showMeanCurve
            meanLbl := label.new(
                 bar_index + labelOffset,
                 policyMean,
                 "Mean Rate: " + f_fmt(policyMean, "%"),
                 style=label.style_label_left,
                 color=color.new(meanLineColor, 0),
                 textcolor=color.white,
                 yloc=yloc.price)

        if showInflLabel and showInflationCurve
            inflLbl := label.new(
                 bar_index + labelOffset,
                 inflation - labelGap,
                 "Inflation YoY: " + f_fmt(inflation, "%") + " | " + (inflRising ? "Rising" : inflFalling ? "Falling" : "Flat"),
                 style=label.style_label_left,
                 color=color.new(inflLineColor, 0),
                 textcolor=color.white,
                 yloc=yloc.price)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[oil, oilMa200] = request.security(oilSym, timeframe.period, [close, ta.sma(close, 200)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[pkr, pkrMa50] = request.security(pkrSym, timeframe.period, [close, ta.sma(close, 50)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[psx, psxMa50, psxMa200, psxRsi] = request.security(psxSym, timeframe.period, [close, ta.sma(close, 50), ta.sma(close, 200), ta.rsi(close, 14)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)

[gold, goldMa200] = request.security(goldSym, timeframe.period, [close, ta.sma(close, 200)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[dxy, dxyMa200] = request.security(dxySym, timeframe.period, [close, ta.sma(close, 200)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[em, emMa200] = request.security(emSym, timeframe.period, [close, ta.sma(close, 200)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)

[rateDash, rateMa12] = request.security(policySym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[inflDash, inflMa12] = request.security(inflSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[gdp, gdpMa4] = request.security(gdpSym, ecoTf, [close, ta.sma(close, 4)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[ur, urMa12] = request.security(urSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)

[fxr, fxrMa12] = request.security(fxrSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[rem, remMa12] = request.security(remSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[debt, debtMa12] = request.security(debtSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[bot, botMa12] = request.security(botSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[ca, caMa12] = request.security(caSym, ecoTf, [close, ta.sma(close, 12)], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dashSize = f_size(fontOpt)

f_score_low(float v, float good, float bad) =>
    na(v) ? 50.0 :
     v <= good ? 85.0 :
     v >= bad ? 25.0 :
     85.0 - ((v - good) / math.max(bad - good, 0.0001)) * 60.0

f_score_high(float v, float weak, float strong) =>
    na(v) ? 50.0 :
     v >= strong ? 85.0 :
     v <= weak ? 25.0 :
     25.0 + ((v - weak) / math.max(strong - weak, 0.0001)) * 60.0

f_score_above_ma(float v, float ma) =>
    na(v) or na(ma) ? 50.0 :
     v > ma ? 70.0 : 40.0

f_score_below_ma(float v, float ma) =>
    na(v) or na(ma) ? 50.0 :
     v < ma ? 70.0 : 40.0

f_score_flow(float v, float ma) =>
    na(v) ? 50.0 :
     v > 0 ? 80.0 :
     not na(ma) and v > ma ? 58.0 :
     35.0

f_bar(float score) =>
    s = na(score) ? 50.0 : score
    blocks = math.round(s / 10)
    out = ""
    for i = 1 to 10
        out += i <= blocks ? "█" : "░"
    out

f_col(float score) =>
    f_scoreColor(score)

f_cell(table tbl, int c, int r, string t, color b, color tc, string tooltip = "") =>
    table.cell(tbl, c, r, t, bgcolor=b, text_color=tc, text_size=dashSize, tooltip=tooltip)

f_sig(table tbl, int c, int r, string t, float score, string tooltip = "") =>
    cBg = f_col(score)
    table.cell(tbl, c, r, t, bgcolor=cBg, text_color=f_readableText(cBg), text_size=dashSize, tooltip=tooltip)

f_headerSpan(table tbl, int c1, int c2, int r, string t) =>
    hBg = r == 0 ? bgHeader : bgSection
    hTxt = r == 0 ? txtMain : txtMuted
    table.cell(tbl, c1, r, t, bgcolor=hBg, text_color=hTxt, text_size=dashSize, text_halign=text.align_center)
    table.merge_cells(tbl, c1, r, c2, r)

f_divider(table tbl, int r) =>
    table.cell(
         tbl,
         4,
         r,
         "",
         bgcolor=color.new(chart.fg_color, 82),
         text_color=chart.fg_color,
         text_size=dashSize)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD SCORING MODEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rateTrendAdj = na(rateDash) or na(rateMa12) ? 0.0 : rateDash < rateMa12 ? 8.0 : rateDash > rateMa12 ? -8.0 : 0.0
rateScore = f_clamp100(f_score_low(rateDash, rateGood, rateBad) + rateTrendAdj)

inflTrendAdj = na(inflDash) or na(inflMa12) ? 0.0 : inflDash < inflMa12 ? 8.0 : inflDash > inflMa12 ? -8.0 : 0.0
inflScore = f_clamp100(f_score_low(inflDash, inflGood, inflBad) + inflTrendAdj)

oilTrendAdj = na(oil) or na(oilMa200) ? 0.0 : oil < oilMa200 ? 5.0 : -5.0
oilScore = f_clamp100(f_score_low(oil, oilGood, oilBad) + oilTrendAdj)

pkrScore = f_score_below_ma(pkr, pkrMa50)

fxrScore  = f_score_above_ma(fxr, fxrMa12)
remScore  = f_score_above_ma(rem, remMa12)
caScore   = f_score_flow(ca, caMa12)
botScore  = f_score_flow(bot, botMa12)
debtScore = f_score_below_ma(debt, debtMa12)

gdpScore = f_score_high(gdp, gdpWeak, gdpGood)
urScore  = f_score_below_ma(ur, urMa12)

dxyScore  = f_score_below_ma(dxy, dxyMa200)
emScore   = f_score_above_ma(em, emMa200)
goldScore = na(gold) or na(goldMa200) ? 50.0 : gold > goldMa200 ? 42.0 : 62.0

psxBaseScore = na(psx) or na(psxMa50) or na(psxMa200) ? 50.0 :
     psx > psxMa50 and psx > psxMa200 ? 82.0 :
     psx > psxMa50 ? 65.0 :
     psx > psxMa200 ? 55.0 :
     32.0

psxRsiAdj = na(psxRsi) ? 0.0 :
     psxRsi > 75 ? -8.0 :
     psxRsi < 30 ? -5.0 :
     psxRsi > 50 ? 5.0 :
     0.0

psxScore = f_clamp100(psxBaseScore + psxRsiAdj)

dashMacroScore = f_clamp100(
     rateScore * 0.16 +
     inflScore * 0.12 +
     oilScore  * 0.12 +
     pkrScore  * 0.10 +
     fxrScore  * 0.10 +
     caScore   * 0.08 +
     botScore  * 0.05 +
     remScore  * 0.04 +
     gdpScore  * 0.09 +
     urScore   * 0.03 +
     debtScore * 0.05 +
     dxyScore  * 0.03 +
     emScore   * 0.03)

equityScore = f_clamp100(dashMacroScore * 0.75 + psxScore * 0.25)

macroRegime = dashMacroScore >= 75 ? "Macro Tailwind" :
     dashMacroScore >= 60 ? "Cautious Bullish" :
     dashMacroScore >= 45 ? "Neutral / Mixed" :
     dashMacroScore >= 30 ? "Macro Pressure" :
     "Crisis Risk"

equityRegime = equityScore >= 75 ? "Accumulation" :
     equityScore >= 60 ? "Buy Dips" :
     equityScore >= 45 ? "Selective" :
     equityScore >= 30 ? "Defensive" :
     "Risk-Off"

rateRegime = rateScore >= 70 ? "Easing Tailwind" :
     rateScore >= 55 ? "Manageable" :
     rateScore >= 40 ? "Valuation Drag" :
     "High Rate Stress"

inflDashRegime = inflScore >= 70 ? "Disinflation" :
     inflScore >= 55 ? "Manageable" :
     inflScore >= 40 ? "Sticky Inflation" :
     "Inflation Shock"

externalAvg = (pkrScore + fxrScore + caScore + botScore) / 4.0

externalRegime = externalAvg >= 60 ? "External Stable" :
     externalAvg >= 45 ? "Watch FX" :
     "External Stress"

psxRegime = psxScore >= 75 ? "Strong Trend" :
     psxScore >= 60 ? "Positive" :
     psxScore >= 45 ? "Neutral" :
     "Weak"

rateSensitiveScore = f_clamp100(rateScore * 0.50 + inflScore * 0.25 + pkrScore * 0.25)
bankScore = f_clamp100(rateScore * 0.25 + inflScore * 0.20 + pkrScore * 0.25 + psxScore * 0.30)
energyScore = f_clamp100((100.0 - oilScore) * 0.35 + psxScore * 0.25 + pkrScore * 0.20 + dashMacroScore * 0.20)
exporterScore = f_clamp100((100.0 - pkrScore) * 0.30 + dxyScore * 0.20 + emScore * 0.20 + dashMacroScore * 0.30)

rateSensitiveSignal = rateSensitiveScore >= 65 ? "Tailwind" : rateSensitiveScore >= 45 ? "Selective" : "Pressure"
bankSignal = bankScore >= 65 ? "Constructive" : bankScore >= 45 ? "Selective" : "Credit Risk"
energySignal = energyScore >= 65 ? "Oil Hedge" : energyScore >= 45 ? "Neutral" : "Weak"
exporterSignal = exporterScore >= 65 ? "Export Hedge" : exporterScore >= 45 ? "Neutral" : "Weak"

psxImpact = equityScore >= 60 and rateScore >= 45 ? "Positive" :
     equityScore >= 45 ? "Selective" :
     "Defensive"

pkrImpact = pkrScore >= 60 and fxrScore >= 55 ? "Stable" :
     externalRegime == "Watch FX" ? "Watch" :
     "Pressure"

bondImpact = rateScore >= 65 ? "Supportive" :
     rateScore >= 45 ? "Cautious" :
     "Pressure"

goldImpact = oilScore < 45 or dxyScore < 45 or pkrScore < 45 ? "Hedge Bid" : "Neutral"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTRA LEFT-PANEL TABLE READINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cycleScore = f_clamp100(oscScore * 0.45 + equityScore * 0.35 + rateScore * 0.20)

policyAction =
     policyRate > policyMean and policyRising  ? "Avoid Leverage" :
     policyRate > policyMean and policyFalling ? "Early Recovery" :
     policyRate < policyMean and policyFalling ? "Risk-On Phase" :
     policyRate < policyMean and policyRising  ? "Late-Cycle Watch" :
     "Neutral"

inflAction =
     inflScore >= 65 ? "Inflation Relief" :
     inflScore >= 45 ? "Sticky Inflation" :
     "Inflation Risk"

liquidityRead =
     rateScore >= 60 and pkrScore >= 55 ? "Liquidity Improving" :
     rateScore >= 45 ? "Mixed Liquidity" :
     "Tight Liquidity"

fxView =
     pkrScore >= 60 and fxrScore >= 55 ? "FX Stable" :
     pkrScore >= 45 ? "FX Watch" :
     "FX Pressure"

sectorTilt =
     bankScore >= rateSensitiveScore and bankScore >= energyScore and bankScore >= exporterScore ? "Banks" :
     rateSensitiveScore >= bankScore and rateSensitiveScore >= energyScore and rateSensitiveScore >= exporterScore ? "Cyclicals" :
     energyScore >= exporterScore ? "Energy" :
     "Exporters"

sectorTiltScore = math.max(math.max(bankScore, rateSensitiveScore), math.max(energyScore, exporterScore))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE — PARALLEL TWO-SECTION DASHBOARD WITH DIVIDER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(
     f_pos(dashPos),
     9,
     19,
     frame_color=color.new(chart.fg_color, 72),
     border_color=color.new(chart.fg_color, 78),
     frame_width=1,
     border_width=1,
     force_overlay=true)

if barstate.islast
    if showDash
        f_headerSpan(dash, 0, 8, 0, "🇵🇰 PAKISTAN MACRO + KSE100 DASHBOARD")

        for r = 1 to 18
            f_divider(dash, r)

        f_headerSpan(dash, 0, 3, 1, "POLICY + CORE MACRO")
        f_headerSpan(dash, 5, 8, 1, "EXTERNAL + MARKET PRESSURE")

        // LEFT PANEL
        f_cell(dash, 0, 2, "Oscillator", bgMain, txtMain)
        f_sig(dash, 1, 2, str.tostring(math.round(oscScore)) + "/100", oscScore)
        f_cell(dash, 2, 2, f_bar(oscScore), bgMain, f_col(oscScore))
        f_sig(dash, 3, 2, oscBias, oscScore)

        f_cell(dash, 0, 3, "Equity Climate", bgMain, txtMain)
        f_sig(dash, 1, 3, str.tostring(math.round(equityScore)) + "/100", equityScore)
        f_cell(dash, 2, 3, f_bar(equityScore), bgMain, f_col(equityScore))
        f_sig(dash, 3, 3, equityRegime, equityScore)

        f_cell(dash, 0, 4, "Macro Score", bgMain, txtMain)
        f_sig(dash, 1, 4, str.tostring(math.round(dashMacroScore)) + "/100", dashMacroScore)
        f_cell(dash, 2, 4, f_bar(dashMacroScore), bgMain, f_col(dashMacroScore))
        f_sig(dash, 3, 4, macroRegime, dashMacroScore)

        f_cell(dash, 0, 5, "Interest Rate", bgMain, txtMain)
        f_cell(dash, 1, 5, f_fmt(rateDash, "%"), bgMain, txtMain)
        f_cell(dash, 2, 5, f_bar(rateScore), bgMain, f_col(rateScore))
        f_sig(dash, 3, 5, rateRegime, rateScore)

        f_cell(dash, 0, 6, "Policy Regime", bgMain, txtMain)
        f_cell(dash, 1, 6, policyRegime, bgMain, txtMain)
        f_cell(dash, 2, 6, f_bar(policyLevelScore), bgMain, f_col(policyLevelScore))
        f_sig(dash, 3, 6, policyRising ? "Rising" : policyFalling ? "Falling" : "Flat", policyTrendScore)

        f_cell(dash, 0, 7, "Inflation YoY", bgMain, txtMain)
        f_cell(dash, 1, 7, f_fmt(inflDash, "%"), bgMain, txtMain)
        f_cell(dash, 2, 7, f_bar(inflScore), bgMain, f_col(inflScore))
        f_sig(dash, 3, 7, inflDashRegime, inflScore)

        f_cell(dash, 0, 8, "Inflation Regime", bgMain, txtMain)
        f_cell(dash, 1, 8, inflRegime, bgMain, txtMain)
        f_cell(dash, 2, 8, f_bar(inflTrendScore), bgMain, f_col(inflTrendScore))
        f_sig(dash, 3, 8, inflRising ? "Rising" : inflFalling ? "Falling" : "Flat", inflTrendScore)

        f_cell(dash, 0, 9, "Real Rate", bgMain, txtMain)
        f_cell(dash, 1, 9, f_fmt(realRate, "%"), bgMain, txtMain)
        f_cell(dash, 2, 9, f_bar(realRateScore), bgMain, f_col(realRateScore))
        f_sig(dash, 3, 9, realRateScore >= 60 ? "Balanced" : "Pressure", realRateScore)

        f_headerSpan(dash, 0, 3, 10, "GROWTH + DOMESTIC DEMAND")

        f_cell(dash, 0, 11, "GDP Growth", bgMain, txtMain)
        f_cell(dash, 1, 11, f_fmt(gdp, "%"), bgMain, txtMain)
        f_cell(dash, 2, 11, f_bar(gdpScore), bgMain, f_col(gdpScore))
        f_sig(dash, 3, 11, gdpScore >= 60 ? "Demand Support" : "Weak Growth", gdpScore)

        f_cell(dash, 0, 12, "Unemployment", bgMain, txtMain)
        f_cell(dash, 1, 12, f_fmt(ur, "%"), bgMain, txtMain)
        f_cell(dash, 2, 12, f_bar(urScore), bgMain, f_col(urScore))
        f_sig(dash, 3, 12, urScore >= 60 ? "Labor Stable" : "Labor Weak", urScore)

        f_headerSpan(dash, 0, 3, 13, "FINAL BIAS")

        f_cell(dash, 0, 14, "PSX Bias", bgMain, txtMain)
        f_sig(dash, 1, 14, psxImpact, equityScore)
        f_cell(dash, 2, 14, "Bonds", bgMain, txtMain)
        f_sig(dash, 3, 14, bondImpact, rateScore)

        f_cell(dash, 0, 15, "Cycle Reading", bgMain, txtMain)
        f_sig(dash, 1, 15, oscBias, oscScore)
        f_cell(dash, 2, 15, "Real Rate", bgMain, txtMain)
        f_sig(dash, 3, 15, realRateScore >= 60 ? "Balanced" : "Pressure", realRateScore)

        f_cell(dash, 0, 16, "Policy Action", bgMain, txtMain)
        f_sig(dash, 1, 16, policyAction, rateScore)
        f_cell(dash, 2, 16, "Inflation", bgMain, txtMain)
        f_sig(dash, 3, 16, inflAction, inflScore)

        f_cell(dash, 0, 17, "Liquidity", bgMain, txtMain)
        f_sig(dash, 1, 17, liquidityRead, cycleScore)
        f_cell(dash, 2, 17, "FX View", bgMain, txtMain)
        f_sig(dash, 3, 17, fxView, pkrScore)

        f_cell(dash, 0, 18, "Sector Tilt", bgMain, txtMain)
        f_sig(dash, 1, 18, sectorTilt, sectorTiltScore)
        f_cell(dash, 2, 18, "Gold", bgMain, txtMain)
        f_sig(dash, 3, 18, goldImpact, goldScore)

        // RIGHT PANEL
        f_cell(dash, 5, 2, "USD/PKR", bgMain, txtMain)
        f_cell(dash, 6, 2, f_fmt(pkr), bgMain, txtMain)
        f_cell(dash, 7, 2, f_bar(pkrScore), bgMain, f_col(pkrScore))
        f_sig(dash, 8, 2, pkrImpact, pkrScore)

        f_cell(dash, 5, 3, "FX Reserves", bgMain, txtMain)
        f_cell(dash, 6, 3, f_fmt(fxr), bgMain, txtMain)
        f_cell(dash, 7, 3, f_bar(fxrScore), bgMain, f_col(fxrScore))
        f_sig(dash, 8, 3, fxrScore >= 60 ? "Improving" : "Weak", fxrScore)

        f_cell(dash, 5, 4, "Current Account", bgMain, txtMain)
        f_cell(dash, 6, 4, f_fmt(ca), bgMain, txtMain)
        f_cell(dash, 7, 4, f_bar(caScore), bgMain, f_col(caScore))
        f_sig(dash, 8, 4, caScore >= 60 ? "Supportive" : "Deficit Risk", caScore)

        f_cell(dash, 5, 5, "Trade Balance", bgMain, txtMain)
        f_cell(dash, 6, 5, f_fmt(bot), bgMain, txtMain)
        f_cell(dash, 7, 5, f_bar(botScore), bgMain, f_col(botScore))
        f_sig(dash, 8, 5, botScore >= 60 ? "Improving" : "Import Pressure", botScore)

        f_cell(dash, 5, 6, "Remittances", bgMain, txtMain)
        f_cell(dash, 6, 6, f_fmt(rem), bgMain, txtMain)
        f_cell(dash, 7, 6, f_bar(remScore), bgMain, f_col(remScore))
        f_sig(dash, 8, 6, remScore >= 60 ? "FX Support" : "Soft", remScore)

        f_cell(dash, 5, 7, "External Debt", bgMain, txtMain)
        f_cell(dash, 6, 7, f_fmt(debt), bgMain, txtMain)
        f_cell(dash, 7, 7, f_bar(debtScore), bgMain, f_col(debtScore))
        f_sig(dash, 8, 7, debtScore >= 60 ? "Cooling" : "Debt Drag", debtScore)

        f_headerSpan(dash, 5, 8, 8, "GLOBAL + COMMODITY PRESSURE")

        f_cell(dash, 5, 9, "Brent Oil", bgMain, txtMain)
        f_cell(dash, 6, 9, f_fmt(oil), bgMain, txtMain)
        f_cell(dash, 7, 9, f_bar(oilScore), bgMain, f_col(oilScore))
        f_sig(dash, 8, 9, oilScore >= 60 ? "Manageable" : "Oil Stress", oilScore)

        f_cell(dash, 5, 10, "DXY", bgMain, txtMain)
        f_cell(dash, 6, 10, f_fmt(dxy), bgMain, txtMain)
        f_cell(dash, 7, 10, f_bar(dxyScore), bgMain, f_col(dxyScore))
        f_sig(dash, 8, 10, dxyScore >= 60 ? "Dollar Soft" : "Dollar Pressure", dxyScore)

        f_cell(dash, 5, 11, "EM Risk", bgMain, txtMain)
        f_cell(dash, 6, 11, f_fmt(em), bgMain, txtMain)
        f_cell(dash, 7, 11, f_bar(emScore), bgMain, f_col(emScore))
        f_sig(dash, 8, 11, emScore >= 60 ? "Risk-On" : "Risk-Off", emScore)

        f_cell(dash, 5, 12, "Gold", bgMain, txtMain)
        f_cell(dash, 6, 12, f_fmt(gold), bgMain, txtMain)
        f_cell(dash, 7, 12, f_bar(goldScore), bgMain, f_col(goldScore))
        f_sig(dash, 8, 12, goldImpact, goldScore)

        f_headerSpan(dash, 5, 8, 13, "KSE100 + SECTOR READ")

        f_cell(dash, 5, 14, "KSE100", bgMain, txtMain)
        f_cell(dash, 6, 14, f_fmt(psx), bgMain, txtMain)
        f_cell(dash, 7, 14, f_bar(psxScore), bgMain, f_col(psxScore))
        f_sig(dash, 8, 14, psxRegime, psxScore)

        f_cell(dash, 5, 15, "RSI 14", bgMain, txtMain)
        f_cell(dash, 6, 15, f_fmt(psxRsi), bgMain, txtMain)
        f_cell(dash, 7, 15, psx > psxMa50 ? "Above 50DMA" : "Below 50DMA", bgMain, psx > psxMa50 ? green : red)
        f_cell(dash, 8, 15, psx > psxMa200 ? "Above 200DMA" : "Below 200DMA", bgMain, psx > psxMa200 ? green : red)

        f_cell(dash, 5, 16, "Banks", bgMain, txtMain)
        f_sig(dash, 6, 16, bankSignal, bankScore)
        f_cell(dash, 7, 16, "Rate + Credit", bgMain, txtMain)
        f_cell(dash, 8, 16, f_bar(bankScore), bgMain, f_col(bankScore))

        f_cell(dash, 5, 17, "Cement / Autos", bgMain, txtMain)
        f_sig(dash, 6, 17, rateSensitiveSignal, rateSensitiveScore)
        f_cell(dash, 7, 17, "Rate Sensitive", bgMain, txtMain)
        f_cell(dash, 8, 17, f_bar(rateSensitiveScore), bgMain, f_col(rateSensitiveScore))

        f_cell(dash, 5, 18, "E&P / Exporters", bgMain, txtMain)
        f_sig(dash, 6, 18, energySignal, energyScore)
        f_sig(dash, 7, 18, exporterSignal, exporterScore)
        f_cell(dash, 8, 18, f_bar((energyScore + exporterScore) / 2.0), bgMain, f_col((energyScore + exporterScore) / 2.0))
    else
        table.clear(dash, 0, 0, 8, 18)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIDDEN PLOTS FOR DATA WINDOW / ALERT USE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(equityScore, "Pakistan Equity Climate Score", display=display.none)
plot(dashMacroScore, "Pakistan Dashboard Macro Score", display=display.none)
plot(rateScore, "Interest Rate Score", display=display.none)
plot(inflScore, "Inflation Score", display=display.none)
plot(pkrScore, "PKR Score", display=display.none)
plot(oilScore, "Oil Score", display=display.none)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(ta.crossover(oscScore, 60), "PK Macro Risk-On", "Pakistan macro oscillator crossed above 60. Liquidity conditions are improving.")
alertcondition(ta.crossunder(oscScore, 40), "PK Macro Risk-Off", "Pakistan macro oscillator crossed below 40. Liquidity conditions are restrictive.")
alertcondition(policyRising and policyRate > policyMean, "Restrictive Tightening", "Policy rate is rising above its historical mean. Bearish pressure for equities.")
alertcondition(policyFalling and policyRate > policyMean, "High-Rate Easing", "Policy rate is falling from a high level. Early recovery condition for equities.")
````
