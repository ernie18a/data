# GFG MACD + VWAP Chop Identifier by Agaam

- url: https://www.tradingview.com/script/rpilXVxy-GFG-MACD-VWAP-Chop-Identifier-by-Agaam/
- type: indicator
- pine_id: PUB;36e2f591561c45d3b8b59a9a8c4bd932
- version: 1.0

## Description

**GFG MACD Chop Identifier + VWAP Filter by Agaam**

The GFG MACD Chop Identifier + VWAP Filter is designed to help traders recognize when MACD conditions are clean, cautious, or choppy. Instead of only showing a standard MACD, this indicator analyzes the behavior of the MACD line, signal line, histogram, ADX, and VWAP relationship to help identify when the market may not be offering a clean trading environment.

This indicator is especially useful for traders who want help avoiding low-quality setups, sideways movement, weak momentum, and fake MACD signals.

**What the indicator shows**

The indicator displays a MACD panel with:

* MACD line
* Signal line
* MACD histogram
* Zero line
* Chop-colored histogram
* Background warning colors
* Fixed top-right status badge

The status badge shows one of three conditions:

**CLEAN**
MACD conditions are stronger and cleaner. The market may have better directional movement.

**CAUTION**
Some chop or weakness is present. Traders may want extra confirmation before entering.

**CHOP**
MACD is compressed, flat, flipping too often, near the zero line, too close to VWAP, or showing weak trend conditions. This is a warning that the market may be messy or not ideal for trading.

**Main logic**

The indicator checks several conditions:

1. **MACD Histogram Compression**
   If the histogram is very small compared to ATR, the market may be losing momentum.

2. **MACD Near Zero Line**
   When MACD is close to the zero line, price may be in transition or chop.

3. **Flat MACD Slope**
   If the MACD line is not moving strongly, momentum may be weak.

4. **Flat Signal Line**
   A flat signal line can show low momentum or sideways action.

5. **Histogram Flip Chop**
   If the histogram flips above and below zero too many times in a short period, the market may be choppy.

6. **ADX Weak Trend Filter**
   Low ADX can suggest weak trend strength.

7. **VWAP Distance Filter**
   If price is too close to VWAP, the market may be balanced or undecided.

8. **VWAP Cross Chop Filter**
   If price crosses VWAP too many times, it may indicate sideways or messy price action.

**How to use it**

Use this indicator as a market-condition filter.

When the badge says **CLEAN**, the MACD environment may be better for looking for setups.

When the badge says **CAUTION**, wait for more confirmation from price action, supply/demand zones, VWAP, EMA trend, or higher timeframe direction.

When the badge says **CHOP**, consider avoiding new trades or reducing risk. CHOP does not mean price cannot move. It means the current MACD/VWAP structure may be lower quality, more mixed, or more likely to create false signals.

**Good use cases**

This indicator can help identify:

* Choppy MACD conditions
* Weak momentum
* Sideways price action
* Too many histogram flips
* VWAP balance zones
* Low ADX trend strength
* No-trade or caution environments

**Best used with**

This tool is best used together with:

* Supply and demand zones
* VWAP
* EMA 12/26 trend
* Market structure
* Higher timeframe bias
* Key levels such as ORB, premarket high/low, previous day high/low
* News awareness and risk management

**Important note**

This is not a buy or sell signal indicator. It is a condition filter. Its purpose is to help traders recognize when the market may be clean, cautious, or choppy.

**Disclaimer**

This indicator is for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Trading stocks, futures, forex, crypto, and other markets involves risk, and losses can exceed expectations. Always use proper risk management, confirm signals with your own analysis, and trade at your own risk. Past performance does not guarantee future results.

## Source Code

````pine
//@version=5
indicator("GFG MACD + VWAP Chop Identifier by Agaam", overlay=false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupMacd = "MACD Settings"

macdTf = input.timeframe("", "MACD Timeframe Blank = Chart", group=groupMacd)
src = input.source(close, "Source", group=groupMacd)

fastLen = input.int(12, "Fast EMA Length", minval=1, group=groupMacd)
slowLen = input.int(26, "Slow EMA Length", minval=1, group=groupMacd)
signalLen = input.int(9, "Signal Length", minval=1, group=groupMacd)

activeTf = macdTf == "" ? timeframe.period : macdTf

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHOP SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupChop = "Chop Detection"

atrLen = input.int(14, "ATR Length For Normalization", minval=1, group=groupChop)

useHistCompression = input.bool(true, "Use Histogram Compression", group=groupChop)
histCompressionAtr = input.float(0.030, "Histogram Compression ATR", minval=0.001, step=0.001, group=groupChop)

useMacdZeroSqueeze = input.bool(true, "Use MACD Near Zero Squeeze", group=groupChop)
zeroSqueezeAtr = input.float(0.080, "MACD Near Zero ATR", minval=0.001, step=0.001, group=groupChop)

useMacdFlatSlope = input.bool(true, "Use MACD Flat Slope", group=groupChop)
macdSlopeAtr = input.float(0.020, "MACD Flat Slope ATR", minval=0.001, step=0.001, group=groupChop)

useSignalFlatSlope = input.bool(true, "Use Signal Flat Slope", group=groupChop)
signalSlopeAtr = input.float(0.020, "Signal Flat Slope ATR", minval=0.001, step=0.001, group=groupChop)

useFlipChop = input.bool(true, "Use Histogram Flip Chop", group=groupChop)
flipLookback = input.int(12, "Flip Lookback Bars", minval=3, maxval=100, group=groupChop)
flipCountLimit = input.int(4, "CHOP If Histogram Flips At Least", minval=1, maxval=20, group=groupChop)

minChopReasons = input.int(3, "Minimum Reasons For CHOP", minval=1, maxval=8, group=groupChop)
minCautionReasons = input.int(2, "Minimum Reasons For CAUTION", minval=1, maxval=8, group=groupChop)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupVwap = "VWAP Chop Filter"

useVwapFilter = input.bool(true, "Use VWAP Filter", group=groupVwap)
vwapSrc = input.source(hlc3, "VWAP Source", group=groupVwap)

vwapNoTradeAtr = input.float(0.20, "CHOP If Price Is Within This ATR From VWAP", minval=0.01, step=0.01, group=groupVwap)
vwapCautionAtr = input.float(0.40, "CAUTION If Price Is Within This ATR From VWAP", minval=0.01, step=0.01, group=groupVwap)

useVwapCrossChop = input.bool(true, "Use VWAP Cross Chop", group=groupVwap)
vwapCrossLookback = input.int(20, "VWAP Cross Lookback Bars", minval=3, maxval=100, group=groupVwap)
vwapCrossLimit = input.int(5, "CHOP If VWAP Crosses At Least", minval=1, maxval=30, group=groupVwap)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL ADX FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupAdx = "Optional ADX Filter"

useAdxFilter = input.bool(true, "Use ADX Weak Trend Filter", group=groupAdx)
adxLen = input.int(14, "DI Length", minval=1, group=groupAdx)
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=groupAdx)
adxChopLevel = input.float(18.0, "CHOP If ADX Below", minval=1.0, step=0.5, group=groupAdx)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDisplay = "Display"

showMacdLine = input.bool(true, "Show MACD Line", group=groupDisplay)
showSignalLine = input.bool(true, "Show Signal Line", group=groupDisplay)
showHistogram = input.bool(true, "Show Histogram", group=groupDisplay)
showZeroLine = input.bool(true, "Show Zero Line", group=groupDisplay)

showBackground = input.bool(true, "Highlight CHOP Background", group=groupDisplay)

showStatusBadge = input.bool(true, "Show Top Right Status Badge", group=groupDisplay)
showReasonsInBadge = input.bool(false, "Show Reasons In Badge", group=groupDisplay)
statusBadgeSizeInput = input.string("Large", "Status Badge Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupDisplay)

macdLineWidth = input.int(2, "MACD Line Width", minval=1, maxval=5, group=groupDisplay)
signalLineWidth = input.int(2, "Signal Line Width", minval=1, maxval=5, group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupColors = "Colors"

macdColor = input.color(color.aqua, "MACD Line Color", group=groupColors)
signalColor = input.color(color.orange, "Signal Line Color", group=groupColors)

bullHistColor = input.color(color.lime, "Bull Histogram Color", group=groupColors)
bearHistColor = input.color(color.red, "Bear Histogram Color", group=groupColors)
chopHistColor = input.color(color.gray, "CHOP Histogram Color", group=groupColors)

cleanColor = input.color(color.lime, "CLEAN Color", group=groupColors)
cautionColor = input.color(color.yellow, "CAUTION Color", group=groupColors)
chopColor = input.color(color.red, "CHOP Color", group=groupColors)

badgeTextColor = input.color(color.black, "Badge Text Color", group=groupColors)
bgTransp = input.int(88, "Background Transparency", minval=0, maxval=100, group=groupColors)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_text_size(_s) =>
    _s == "Tiny" ? size.tiny : _s == "Small" ? size.small : _s == "Normal" ? size.normal : _s == "Large" ? size.large : size.huge

f_vwap_cross_count() =>
    math.sum(ta.cross(close, ta.vwap(vwapSrc)) ? 1.0 : 0.0, vwapCrossLookback)

badgeTextSize = f_text_size(statusBadgeSizeInput)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MACD / ATR / ADX CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[macdLine, signalLine, histLine] = request.security(syminfo.tickerid, activeTf, ta.macd(src, fastLen, slowLen, signalLen), barmerge.gaps_off, barmerge.lookahead_off)
atrv = request.security(syminfo.tickerid, activeTf, ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)
tfClose = request.security(syminfo.tickerid, activeTf, close, barmerge.gaps_off, barmerge.lookahead_off)
[diPlus, diMinus, adxValue] = request.security(syminfo.tickerid, activeTf, ta.dmi(adxLen, adxSmooth), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vwapValue = request.security(syminfo.tickerid, activeTf, ta.vwap(vwapSrc), barmerge.gaps_off, barmerge.lookahead_off)
vwapCrossCount = request.security(syminfo.tickerid, activeTf, f_vwap_cross_count(), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NORMALIZED MACD MEASUREMENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
safeAtr = math.max(atrv, syminfo.mintick)

histAbsAtr = math.abs(histLine) / safeAtr
macdZeroAtr = math.abs(macdLine) / safeAtr
macdSlope = math.abs(macdLine - macdLine[1]) / safeAtr
signalSlope = math.abs(signalLine - signalLine[1]) / safeAtr

histSign = histLine > 0 ? 1 : histLine < 0 ? -1 : 0
histFlip = histSign != 0 and histSign[1] != 0 and histSign != histSign[1]
flipCount = math.sum(histFlip ? 1.0 : 0.0, flipLookback)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP MEASUREMENTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
vwapDistanceAtr = not na(vwapValue) ? math.abs(tfClose - vwapValue) / safeAtr : 999.0

vwapNearChop = useVwapFilter and vwapDistanceAtr <= vwapNoTradeAtr
vwapNearCaution = useVwapFilter and vwapDistanceAtr > vwapNoTradeAtr and vwapDistanceAtr <= vwapCautionAtr
vwapCrossChop = useVwapFilter and useVwapCrossChop and vwapCrossCount >= vwapCrossLimit

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHOP CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
histCompressed = useHistCompression and histAbsAtr <= histCompressionAtr
zeroSqueeze = useMacdZeroSqueeze and macdZeroAtr <= zeroSqueezeAtr
macdFlat = useMacdFlatSlope and macdSlope <= macdSlopeAtr
signalFlat = useSignalFlatSlope and signalSlope <= signalSlopeAtr
flipChop = useFlipChop and flipCount >= flipCountLimit
adxChop = useAdxFilter and adxValue < adxChopLevel

int chopScore = 0

if histCompressed
    chopScore += 1
if zeroSqueeze
    chopScore += 1
if macdFlat
    chopScore += 1
if signalFlat
    chopScore += 1
if flipChop
    chopScore += 1
if adxChop
    chopScore += 1
if vwapNearChop
    chopScore += 1
if vwapNearCaution
    chopScore += 1
if vwapCrossChop
    chopScore += 1

isChop = chopScore >= minChopReasons
isCaution = not isChop and chopScore >= minCautionReasons
isClean = not isChop and not isCaution

statusText = isChop ? "CHOP" : isCaution ? "CAUTION" : "CLEAN"
statusColor = isChop ? chopColor : isCaution ? cautionColor : cleanColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REASON TEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string reasonText = ""

if histCompressed
    reasonText += "Hist compressed\n"
if zeroSqueeze
    reasonText += "MACD near zero\n"
if macdFlat
    reasonText += "MACD flat\n"
if signalFlat
    reasonText += "Signal flat\n"
if flipChop
    reasonText += "Too many MACD flips\n"
if adxChop
    reasonText += "ADX weak\n"
if vwapNearChop
    reasonText += "Price too close to VWAP\n"
if vwapNearCaution
    reasonText += "Price near VWAP\n"
if vwapCrossChop
    reasonText += "Too many VWAP crosses\n"

if isClean
    reasonText := "MACD has cleaner movement"

badgeText = showReasonsInBadge ? statusText + "\n" + reasonText : statusText

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTOGRAM COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
histColor = isChop ? chopHistColor : histLine >= 0 ? bullHistColor : bearHistColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showHistogram ? histLine : na, title="MACD Histogram", style=plot.style_columns, color=histColor)
plot(showMacdLine ? macdLine : na, title="MACD Line", color=macdColor, linewidth=macdLineWidth)
plot(showSignalLine ? signalLine : na, title="Signal Line", color=signalColor, linewidth=signalLineWidth)
plot(showZeroLine ? 0 : na, title="Zero Line", color=color.new(color.white, 70), linewidth=1)

bgcolor(showBackground and isChop ? color.new(chopColor, bgTransp) : na)
bgcolor(showBackground and isCaution ? color.new(cautionColor, bgTransp) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TOP RIGHT STATUS BADGE — WHERE TABLE USED TO BE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table statusBadge = na

if barstate.islast
    if showStatusBadge
        if na(statusBadge)
            statusBadge := table.new(position.top_right, 1, 1, border_width=1, frame_width=1)
        table.cell(statusBadge, 0, 0, badgeText, bgcolor=statusColor, text_color=badgeTextColor, text_size=badgeTextSize)
    else
        if not na(statusBadge)
            table.delete(statusBadge)
            statusBadge := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(isChop, title="GFG MACD CHOP", message="MACD CHOP on {{ticker}} {{interval}}")
alertcondition(isCaution, title="GFG MACD CAUTION", message="MACD CAUTION on {{ticker}} {{interval}}")
alertcondition(isClean, title="GFG MACD CLEAN", message="MACD CLEAN on {{ticker}} {{interval}}")
````
