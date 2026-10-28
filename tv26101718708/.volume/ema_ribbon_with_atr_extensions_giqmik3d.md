# EMA Ribbon with ATR Extensions

- url: https://www.tradingview.com/script/Giqmik3d-EMA-Ribbon-with-ATR-Extensions/
- type: indicator
- pine_id: PUB;1f2306b3f45442ba92243984eb7cd300
- version: 5.0

## Description

This indicator is an EMA ribbon framework combined with multi-timeframe trend structure and volatility-normalized distance measurements using ATR.

The core component is a configurable exponential moving average ribbon, allowing multiple EMA lengths to be plotted simultaneously across different timeframes. This includes both intraday EMAs and optional higher-timeframe EMAs such as daily and weekly periods. The purpose of this structure is to provide a layered view of trend behavior across multiple time horizons, helping visualize alignment, compression, and expansion within broader market structure.

In addition to standard EMA visualization, the indicator integrates a volatility context layer using the Average True Range (ATR). This allows price distance from each EMA to be expressed not only in percentage terms, but also in ATR-normalized form. The ATR extension metric is derived from the relationship between percentage deviation from the moving average and current ATR percentage, enabling comparison of movement intensity across different instruments regardless of price scale.

The included table presents a structured breakdown for each selected EMA:

EMA value based on configurable length and timeframe
Percentage distance between price and each EMA
ATR-normalized extension value representing volatility-adjusted deviation

This structure allows users to observe how price interacts with multiple trend references simultaneously, while also understanding whether movement is occurring within normal volatility conditions or represents an expanded deviation relative to recent market behavior.

A visual marker is included to highlight conditions where price is significantly extended above a selected higher timeframe EMA relative to ATR-based expansion. This is intended to assist with quickly identifying periods of elevated trend extension within the broader EMA framework.

The header display optionally shows symbol, description, and active chart timeframe to maintain contextual awareness when analyzing multiple assets or timeframes.

Overall, the tool is designed as a multi-layer trend and volatility visualization system combining moving averages, relative distance metrics, and ATR-based normalization to better contextualize price positioning within ongoing market structure.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MysticMads

//@version=6
indicator("MA Ribbon with ATR Extensions", shorttitle="MA Ribbon", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

calcTicker = syminfo.tickerid

src    = input.source(close, "Source")
maType = input.string("EMA", "MA Type", options=["EMA", "SMA"], group="MA System")

showTable       = input.bool(true, "Show MA Table", group="Display")
showHeaderTable = input.bool(true, "Show Symbol + Timeframe Header", group="Display")

maTableSizeInput = input.string("Small", "MA Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Display")
tablePositionInput = input.string("Top Right", "MA Table Position", options=["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"], group="Display")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Context Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showContextTable = input.bool(false, "Show Context Table", group="Context Table")

contextTableSizeInput = input.string("Small", "Context Table Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Context Table")

adrLen = input.int(20, "ADR% Length", minval=1, group="Context Table")
volLen = input.int(50, "Volume MA Length", minval=1, group="Context Table")
udLen  = input.int(50, "U/D Ratio Length", minval=1, group="Context Table")

showContextADR         = input.bool(true, "Show ADR%", group="Context Table")
showContextATR         = input.bool(true, "Show ATR%", group="Context Table")
showContextLOD         = input.bool(true, "Show LoD Context", group="Context Table")
showContextIntradayATR = input.bool(true, "Show Intraday ATR Position", group="Context Table")
showContextVol         = input.bool(true, "Show Volume Context", group="Context Table")
showContext52W         = input.bool(true, "Show 52W Context", group="Context Table")
showContextUD          = input.bool(true, "Show U/D Ratio", group="Context Table")
showContextInfo        = input.bool(true, "Show Sector / Industry", group="Context Table")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showSessionVWAP  = input.bool(true, "Show Session VWAP Intraday Only", group="VWAP")
sessionVWAPColor = input.color(color.rgb(80, 200, 255), "Session VWAP Color", group="VWAP")
sessionVWAPWidth = input.int(2, "Session VWAP Width", minval=1, maxval=5, group="VWAP")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Base MAs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showMa1 = input.bool(true, "Show MA 1", group="Base MAs")
len1    = input.int(10, "MA 1 Length", minval=1, group="Base MAs")
tf1     = input.timeframe("", "MA 1 Timeframe", group="Base MAs")

showMa2 = input.bool(true, "Show MA 2", group="Base MAs")
len2    = input.int(20, "MA 2 Length", minval=1, group="Base MAs")
tf2     = input.timeframe("", "MA 2 Timeframe", group="Base MAs")

showMa3 = input.bool(true, "Show MA 3", group="Base MAs")
len3    = input.int(50, "MA 3 Length", minval=1, group="Base MAs")
tf3     = input.timeframe("", "MA 3 Timeframe", group="Base MAs")

showMa4 = input.bool(true, "Show MA 4", group="Base MAs")
len4    = input.int(100, "MA 4 Length", minval=1, group="Base MAs")
tf4     = input.timeframe("", "MA 4 Timeframe", group="Base MAs")

showMa5 = input.bool(true, "Show MA 5", group="Base MAs")
len5    = input.int(200, "MA 5 Length", minval=1, group="Base MAs")
tf5     = input.timeframe("", "MA 5 Timeframe", group="Base MAs")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF MAs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showD10  = input.bool(false, "Enable 10D MA", group="HTF MAs")
showD20  = input.bool(false, "Enable 20D MA", group="HTF MAs")
showD21  = input.bool(false, "Enable 21D MA", group="HTF MAs")
showD50  = input.bool(false, "Enable 50D MA", group="HTF MAs")
showD100 = input.bool(false, "Enable 100D MA", group="HTF MAs")
showD200 = input.bool(false, "Enable 200D MA", group="HTF MAs")

showW10  = input.bool(false, "Enable Weekly 10 MA", group="HTF MAs")
showW20  = input.bool(false, "Enable Weekly 20 MA", group="HTF MAs")
showW50  = input.bool(false, "Enable Weekly 50 MA", group="HTF MAs")
showW200 = input.bool(false, "Enable Weekly 200 MA", group="HTF MAs")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrLen = input.int(20, "ATR Length", minval=1, group="ATR")
atrTf  = input.timeframe("", "ATR Timeframe For Table", group="ATR")

showDailyExtensionDot = input.bool(true, "Show 1D 50MA ATR Extension Dot", group="ATR Extension Dot")
dailyDotThreshold     = input.float(10.0, "Daily Dot Threshold", step=0.25, group="ATR Extension Dot")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_ma(_source, _len) =>
    maType == "EMA" ? ta.ema(_source, _len) : ta.sma(_source, _len)

f_tf_ma(_tf, _len) =>
    _tf == "" ?
         f_ma(src, _len) :
         request.security(
             calcTicker,
             _tf,
             f_ma(src, _len),
             barmerge.gaps_off,
             barmerge.lookahead_off
         )

f_table_size(_size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

f_table_position(_pos) =>
    switch _pos
        "Top Right"    => position.top_right
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Middle Left"  => position.middle_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_chart_tf_label() =>
    mult = timeframe.multiplier
    timeframe.isseconds ? str.tostring(mult) + "s" :
     timeframe.isminutes ? str.tostring(mult) + "m" :
     timeframe.isdaily ? str.tostring(mult) + "d" :
     timeframe.isweekly ? str.tostring(mult) + "w" :
     timeframe.ismonthly ? str.tostring(mult) + "M" :
     timeframe.period

f_tf_label(_tf) =>
    _tf == "" ? "Chart" : _tf

f_price_text(_price) =>
    na(_price) ? "n/a" : str.tostring(_price, format.mintick)

f_pct_text(_pct) =>
    na(_pct) ? "n/a" : str.tostring(_pct, "#.##") + "%"

f_atr_text(_atrExt) =>
    na(_atrExt) ? "n/a" : str.tostring(_atrExt, "#.##") + " ATR"

f_pct_away(_ma) =>
    na(_ma) or _ma == 0 ? na : ((close - _ma) / _ma) * 100

f_large_text(_v) =>
    absV = math.abs(_v)
    absV >= 1000000000 ? str.tostring(_v / 1000000000, "#.##") + "B" :
     absV >= 1000000 ? str.tostring(_v / 1000000, "#.##") + "M" :
     absV >= 1000 ? str.tostring(_v / 1000, "#.##") + "K" :
     str.tostring(_v, "#.##")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ma1 = f_tf_ma(tf1, len1)
ma2 = f_tf_ma(tf2, len2)
ma3 = f_tf_ma(tf3, len3)
ma4 = f_tf_ma(tf4, len4)
ma5 = f_tf_ma(tf5, len5)

maD10  = request.security(calcTicker, "D", f_ma(src, 10),  barmerge.gaps_off, barmerge.lookahead_off)
maD20  = request.security(calcTicker, "D", f_ma(src, 20),  barmerge.gaps_off, barmerge.lookahead_off)
maD21  = request.security(calcTicker, "D", f_ma(src, 21),  barmerge.gaps_off, barmerge.lookahead_off)
maD50  = request.security(calcTicker, "D", f_ma(src, 50),  barmerge.gaps_off, barmerge.lookahead_off)
maD100 = request.security(calcTicker, "D", f_ma(src, 100), barmerge.gaps_off, barmerge.lookahead_off)
maD200 = request.security(calcTicker, "D", f_ma(src, 200), barmerge.gaps_off, barmerge.lookahead_off)

maW10  = request.security(calcTicker, "W", f_ma(src, 10),  barmerge.gaps_off, barmerge.lookahead_off)
maW20  = request.security(calcTicker, "W", f_ma(src, 20),  barmerge.gaps_off, barmerge.lookahead_off)
maW50  = request.security(calcTicker, "W", f_ma(src, 50),  barmerge.gaps_off, barmerge.lookahead_off)
maW200 = request.security(calcTicker, "W", f_ma(src, 200), barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isIntradayChart = timeframe.isintraday
sessionVWAP = isIntradayChart ? ta.vwap(src) : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrRequestTf = atrTf == "" ? timeframe.period : atrTf

atrVal = request.security(
     calcTicker,
     atrRequestTf,
     ta.atr(atrLen),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

atrClose = request.security(
     calcTicker,
     atrRequestTf,
     close,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

atrPct = atrClose != 0 ? (atrVal / atrClose) * 100 : na

f_atr_ext(_ma) =>
    pctAway = f_pct_away(_ma)
    na(_ma) or na(pctAway) or na(atrPct) or atrPct == 0 ? na : pctAway / atrPct

dailyClose = request.security(calcTicker, "D", close, barmerge.gaps_off, barmerge.lookahead_off)
dailyATR   = request.security(calcTicker, "D", ta.atr(atrLen), barmerge.gaps_off, barmerge.lookahead_off)
dailyMA50  = request.security(calcTicker, "D", f_ma(src, 50), barmerge.gaps_off, barmerge.lookahead_off)

dailyAtrPct = dailyClose != 0 ? (dailyATR / dailyClose) * 100 : na
dailyPct50  = dailyMA50 != 0 ? ((dailyClose - dailyMA50) / dailyMA50) * 100 : na
dailyExt50  = dailyAtrPct != 0 ? dailyPct50 / dailyAtrPct : na

isDailyExtensionDot =
     showDailyExtensionDot and
     timeframe.isdaily and
     timeframe.multiplier == 1 and
     dailyClose > dailyMA50 and
     dailyExt50 > dailyDotThreshold

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Context Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

adrPct = request.security(
     calcTicker,
     "D",
     100 * (ta.sma(high / low, adrLen) - 1),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

contextAtr = request.security(
     calcTicker,
     "D",
     ta.atr(atrLen),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

contextClose = request.security(
     calcTicker,
     "D",
     close,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

contextHigh = request.security(
     calcTicker,
     "D",
     high,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

contextLow = request.security(
     calcTicker,
     "D",
     low,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

contextAtrPct = contextClose != 0 ? (contextAtr / contextClose) * 100 : na

dayRange = contextHigh - contextLow

lodDist = contextAtr != 0 ? 100 * (contextClose - contextLow) / contextAtr : na
lodPrice = contextLow

dayAtrUsedPct = contextAtr != 0 ? 100 * dayRange / contextAtr : na
priceFromLowAtrPct = contextAtr != 0 ? 100 * (contextClose - contextLow) / contextAtr : na
priceFromHighAtrPct = contextAtr != 0 ? 100 * (contextHigh - contextClose) / contextAtr : na
priceRangePositionPct = dayRange != 0 ? 100 * (contextClose - contextLow) / dayRange : na

avgVol = request.security(
     calcTicker,
     "D",
     ta.sma(volume, volLen),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

avgDollarVol = avgVol * contextClose

relVol = request.security(
     calcTicker,
     "D",
     volume / ta.sma(volume, volLen) * 100,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

volBuzz = relVol - 100

upDnRatio = request.security(
     calcTicker,
     "D",
     math.sum(close > close[1] ? volume : 0, udLen) / math.max(math.sum(close < close[1] ? volume : 0, udLen), 1),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

fiftyTwoWeekHigh = request.security(
     calcTicker,
     "W",
     ta.highest(high, 52),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

fiftyTwoWeekLow = request.security(
     calcTicker,
     "W",
     ta.lowest(low, 52),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

off52High = fiftyTwoWeekHigh != 0 ? 100 * (contextClose / fiftyTwoWeekHigh - 1) : na
above52Low = fiftyTwoWeekLow != 0 ? 100 * (contextClose / fiftyTwoWeekLow - 1) : na

sectorText = na(syminfo.sector) ? "N/A" : syminfo.sector
industryText = na(syminfo.industry) ? "N/A" : syminfo.industry

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table Values
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pct1 = f_pct_away(ma1)
pct2 = f_pct_away(ma2)
pct3 = f_pct_away(ma3)
pct4 = f_pct_away(ma4)
pct5 = f_pct_away(ma5)

atrExt1 = f_atr_ext(ma1)
atrExt2 = f_atr_ext(ma2)
atrExt3 = f_atr_ext(ma3)
atrExt4 = f_atr_ext(ma4)
atrExt5 = f_atr_ext(ma5)

pctD10  = f_pct_away(maD10)
pctD20  = f_pct_away(maD20)
pctD21  = f_pct_away(maD21)
pctD50  = f_pct_away(maD50)
pctD100 = f_pct_away(maD100)
pctD200 = f_pct_away(maD200)

atrExtD10  = f_atr_ext(maD10)
atrExtD20  = f_atr_ext(maD20)
atrExtD21  = f_atr_ext(maD21)
atrExtD50  = f_atr_ext(maD50)
atrExtD100 = f_atr_ext(maD100)
atrExtD200 = f_atr_ext(maD200)

pctW10  = f_pct_away(maW10)
pctW20  = f_pct_away(maW20)
pctW50  = f_pct_away(maW50)
pctW200 = f_pct_away(maW200)

atrExtW10  = f_atr_ext(maW10)
atrExtW20  = f_atr_ext(maW20)
atrExtW50  = f_atr_ext(maW50)
atrExtW200 = f_atr_ext(maW200)

pctVWAP    = f_pct_away(sessionVWAP)
atrExtVWAP = f_atr_ext(sessionVWAP)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ma1Color = color.rgb(255, 235, 59)
ma2Color = color.rgb(255, 183, 77)
ma3Color = color.rgb(255, 167, 38)
ma4Color = color.rgb(255, 112, 67)
ma5Color = color.rgb(255, 87, 74)

htfD10Color  = color.new(color.rgb(255, 235, 59), 25)
htfD20Color  = color.new(color.rgb(255, 183, 77), 25)
htfD21Color  = color.new(color.rgb(255, 167, 38), 25)
htfD50Color  = color.new(color.rgb(255, 112, 67), 25)
htfD100Color = color.new(color.rgb(255, 87, 74), 25)
htfD200Color = color.new(color.rgb(211, 47, 47), 25)

htfW10Color  = color.new(color.rgb(255, 235, 59), 5)
htfW20Color  = color.new(color.rgb(255, 183, 77), 5)
htfW50Color  = color.new(color.rgb(255, 112, 67), 5)
htfW200Color = color.new(color.rgb(211, 47, 47), 5)

darkBg    = color.new(color.black, 0)
headerBg  = color.rgb(20, 20, 20)
posBg     = color.new(color.rgb(0, 170, 90), 75)
negBg     = color.new(color.rgb(220, 60, 50), 75)
neutralBg = color.new(color.gray, 82)
warnBg    = color.new(color.rgb(255, 167, 38), 65)
dangerBg  = color.new(color.rgb(211, 47, 47), 60)
vwapBg    = color.new(color.rgb(0, 120, 180), 78)
contextBg = color.new(color.rgb(10, 10, 10), 0)

f_pct_bg(_pct) =>
    na(_pct) ? neutralBg :
     _pct > 0 ? posBg :
     _pct < 0 ? negBg :
     neutralBg

f_atr_bg(_atrExt) =>
    absVal = math.abs(_atrExt)
    na(_atrExt) ? neutralBg :
     absVal >= 3.0 ? dangerBg :
     absVal >= 2.0 ? warnBg :
     _atrExt > 0 ? posBg :
     _atrExt < 0 ? negBg :
     neutralBg

f_relvol_bg(_rv) =>
    na(_rv) ? neutralBg :
     _rv >= 150 ? posBg :
     _rv >= 100 ? neutralBg :
     color.new(color.gray, 88)

f_buzz_bg(_buzz) =>
    na(_buzz) ? neutralBg :
     _buzz > 50 ? posBg :
     _buzz > 0 ? neutralBg :
     color.new(color.gray, 88)

f_lod_bg(_lod) =>
    na(_lod) ? neutralBg :
     _lod >= 100 ? posBg :
     _lod >= 50 ? neutralBg :
     negBg

f_range_pos_bg(_pos) =>
    na(_pos) ? neutralBg :
     _pos >= 70 ? posBg :
     _pos >= 40 ? neutralBg :
     negBg

f_day_atr_used_bg(_used) =>
    na(_used) ? neutralBg :
     _used >= 150 ? dangerBg :
     _used >= 100 ? warnBg :
     neutralBg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(showMa1 ? ma1 : na, title="MA 1", color=ma1Color, linewidth=2)
plot(showMa2 ? ma2 : na, title="MA 2", color=ma2Color, linewidth=2)
plot(showMa3 ? ma3 : na, title="MA 3", color=ma3Color, linewidth=2)
plot(showMa4 ? ma4 : na, title="MA 4", color=ma4Color, linewidth=2)
plot(showMa5 ? ma5 : na, title="MA 5", color=ma5Color, linewidth=2)

plot(showSessionVWAP and isIntradayChart ? sessionVWAP : na, title="Session VWAP", color=sessionVWAPColor, linewidth=sessionVWAPWidth, style=plot.style_linebr)

plot(showD10 ? maD10 : na, title="10D MA", color=htfD10Color, linewidth=2)
plot(showD20 ? maD20 : na, title="20D MA", color=htfD20Color, linewidth=2)
plot(showD21 ? maD21 : na, title="21D MA", color=htfD21Color, linewidth=2)
plot(showD50 ? maD50 : na, title="50D MA", color=htfD50Color, linewidth=2)
plot(showD100 ? maD100 : na, title="100D MA", color=htfD100Color, linewidth=2)
plot(showD200 ? maD200 : na, title="200D MA", color=htfD200Color, linewidth=2)

plot(showW10 ? maW10 : na, title="10W MA", color=htfW10Color, linewidth=3)
plot(showW20 ? maW20 : na, title="20W MA", color=htfW20Color, linewidth=3)
plot(showW50 ? maW50 : na, title="50W MA", color=htfW50Color, linewidth=3)
plot(showW200 ? maW200 : na, title="200W MA", color=htfW200Color, linewidth=3)

plotshape(
     isDailyExtensionDot,
     title="1D 50MA ATR Extension Dot",
     style=shape.circle,
     location=location.abovebar,
     color=color.yellow,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

maTableTextSize = f_table_size(maTableSizeInput)
contextTableTextSize = f_table_size(contextTableSizeInput)
tablePosition = f_table_position(tablePositionInput)
maLabel = maType

f_add_row(_table, _row, _name, _lenText, _price, _pct, _atrExt, _tfText, _txtColor, _nameBg) =>
    table.cell(_table, 0, _row, _name, text_color=_txtColor, bgcolor=_nameBg, text_size=maTableTextSize)
    table.cell(_table, 1, _row, _lenText, text_color=color.white, bgcolor=darkBg, text_size=maTableTextSize)
    table.cell(_table, 2, _row, f_price_text(_price), text_color=color.white, bgcolor=darkBg, text_size=maTableTextSize)
    table.cell(_table, 3, _row, f_pct_text(_pct), text_color=color.white, bgcolor=f_pct_bg(_pct), text_size=maTableTextSize)
    table.cell(_table, 4, _row, f_atr_text(_atrExt), text_color=color.white, bgcolor=f_atr_bg(_atrExt), text_size=maTableTextSize)
    table.cell(_table, 5, _row, _tfText, text_color=color.white, bgcolor=darkBg, text_size=maTableTextSize)

var table t = table.new(tablePosition, 6, 18, border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 5, 17)

if barstate.islast and showTable
    table.cell(t, 0, 0, maLabel, text_color=color.white, bgcolor=headerBg, text_size=maTableTextSize)
    table.cell(t, 1, 0, "Length", text_color=color.white, bgcolor=headerBg, text_size=maTableTextSize)
    table.cell(t, 2, 0, "Price", text_color=color.white, bgcolor=headerBg, text_size=maTableTextSize)
    table.cell(t, 3, 0, "% Away", text_color=color.white, bgcolor=headerBg, text_size=maTableTextSize)
    table.cell(t, 4, 0, "ATR", text_color=color.white, bgcolor=headerBg, text_size=maTableTextSize)
    table.cell(t, 5, 0, "TF", text_color=color.white, bgcolor=headerBg, text_size=maTableTextSize)

    int row = 1

    if showMa1
        f_add_row(t, row, maLabel + " 1", str.tostring(len1), ma1, pct1, atrExt1, f_tf_label(tf1), ma1Color, darkBg)
        row += 1
    if showMa2
        f_add_row(t, row, maLabel + " 2", str.tostring(len2), ma2, pct2, atrExt2, f_tf_label(tf2), ma2Color, darkBg)
        row += 1
    if showMa3
        f_add_row(t, row, maLabel + " 3", str.tostring(len3), ma3, pct3, atrExt3, f_tf_label(tf3), ma3Color, darkBg)
        row += 1
    if showMa4
        f_add_row(t, row, maLabel + " 4", str.tostring(len4), ma4, pct4, atrExt4, f_tf_label(tf4), ma4Color, darkBg)
        row += 1
    if showMa5
        f_add_row(t, row, maLabel + " 5", str.tostring(len5), ma5, pct5, atrExt5, f_tf_label(tf5), ma5Color, darkBg)
        row += 1

    if showSessionVWAP and isIntradayChart
        f_add_row(t, row, "VWAP", "-", sessionVWAP, pctVWAP, atrExtVWAP, "Session", sessionVWAPColor, vwapBg)
        row += 1

    if showD10
        f_add_row(t, row, "10D " + maLabel, "10", maD10, pctD10, atrExtD10, "D", htfD10Color, darkBg)
        row += 1
    if showD20
        f_add_row(t, row, "20D " + maLabel, "20", maD20, pctD20, atrExtD20, "D", htfD20Color, darkBg)
        row += 1
    if showD21
        f_add_row(t, row, "21D " + maLabel, "21", maD21, pctD21, atrExtD21, "D", htfD21Color, darkBg)
        row += 1
    if showD50
        f_add_row(t, row, "50D " + maLabel, "50", maD50, pctD50, atrExtD50, "D", htfD50Color, darkBg)
        row += 1
    if showD100
        f_add_row(t, row, "100D " + maLabel, "100", maD100, pctD100, atrExtD100, "D", htfD100Color, darkBg)
        row += 1
    if showD200
        f_add_row(t, row, "200D " + maLabel, "200", maD200, pctD200, atrExtD200, "D", htfD200Color, darkBg)
        row += 1

    if showW10
        f_add_row(t, row, "10W " + maLabel, "10", maW10, pctW10, atrExtW10, "W", htfW10Color, darkBg)
        row += 1
    if showW20
        f_add_row(t, row, "20W " + maLabel, "20", maW20, pctW20, atrExtW20, "W", htfW20Color, darkBg)
        row += 1
    if showW50
        f_add_row(t, row, "50W " + maLabel, "50", maW50, pctW50, atrExtW50, "W", htfW50Color, darkBg)
        row += 1
    if showW200
        f_add_row(t, row, "200W " + maLabel, "200", maW200, pctW200, atrExtW200, "W", htfW200Color, darkBg)
        row += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Context Table — fixed bottom right
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_context_row(_table, _row, _name, _value, _valueBg) =>
    table.cell(_table, 0, _row, _name, text_color=color.white, bgcolor=contextBg, text_size=contextTableTextSize)
    table.cell(_table, 1, _row, _value, text_color=color.white, bgcolor=_valueBg, text_size=contextTableTextSize)

var table contextTable = table.new(position.bottom_right, 2, 18, border_width=1)

if barstate.islast
    table.clear(contextTable, 0, 0, 1, 17)

if barstate.islast and showContextTable
    table.cell(contextTable, 0, 0, "Context", text_color=color.white, bgcolor=headerBg, text_size=contextTableTextSize)
    table.cell(contextTable, 1, 0, "Value", text_color=color.white, bgcolor=headerBg, text_size=contextTableTextSize)

    int cRow = 1

    if showContextADR
        f_context_row(contextTable, cRow, "ADR%", f_pct_text(adrPct), neutralBg)
        cRow += 1

    if showContextATR
        f_context_row(contextTable, cRow, "ATR%", f_pct_text(contextAtrPct), neutralBg)
        cRow += 1

    if showContextLOD
        f_context_row(contextTable, cRow, "LoD Dist.", na(lodDist) ? "n/a" : str.tostring(lodDist, "#") + "%", f_lod_bg(lodDist))
        cRow += 1
        f_context_row(contextTable, cRow, "LoD Price", f_price_text(lodPrice), neutralBg)
        cRow += 1

    if showContextIntradayATR
        f_context_row(contextTable, cRow, "Day ATR Used", na(dayAtrUsedPct) ? "n/a" : str.tostring(dayAtrUsedPct, "#") + "%", f_day_atr_used_bg(dayAtrUsedPct))
        cRow += 1
        f_context_row(contextTable, cRow, "From Low ATR", na(priceFromLowAtrPct) ? "n/a" : str.tostring(priceFromLowAtrPct, "#") + "%", f_lod_bg(priceFromLowAtrPct))
        cRow += 1
        f_context_row(contextTable, cRow, "From High ATR", na(priceFromHighAtrPct) ? "n/a" : str.tostring(priceFromHighAtrPct, "#") + "%", neutralBg)
        cRow += 1
        f_context_row(contextTable, cRow, "Range Position", na(priceRangePositionPct) ? "n/a" : str.tostring(priceRangePositionPct, "#") + "%", f_range_pos_bg(priceRangePositionPct))
        cRow += 1

    if showContextVol
        f_context_row(contextTable, cRow, "Avg $ Vol", "$" + f_large_text(avgDollarVol), neutralBg)
        cRow += 1
        f_context_row(contextTable, cRow, "Avg Vol", f_large_text(avgVol), neutralBg)
        cRow += 1
        f_context_row(contextTable, cRow, "Rel Vol", na(relVol) ? "n/a" : str.tostring(relVol, "#") + "%", f_relvol_bg(relVol))
        cRow += 1
        f_context_row(contextTable, cRow, "Vol Buzz", na(volBuzz) ? "n/a" : str.tostring(volBuzz, "#") + "%", f_buzz_bg(volBuzz))
        cRow += 1

    if showContext52W
        f_context_row(contextTable, cRow, "Off 52W High", f_pct_text(off52High), f_pct_bg(off52High))
        cRow += 1
        f_context_row(contextTable, cRow, "Above 52W Low", f_pct_text(above52Low), f_pct_bg(above52Low))
        cRow += 1

    if showContextUD
        f_context_row(contextTable, cRow, "U/D Ratio", na(upDnRatio) ? "n/a" : str.tostring(upDnRatio, "#.##"), neutralBg)
        cRow += 1

    if showContextInfo
        f_context_row(contextTable, cRow, "Sector", sectorText, neutralBg)
        cRow += 1
        f_context_row(contextTable, cRow, "Industry", industryText, neutralBg)
        cRow += 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Header
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

chartTfLabel = f_chart_tf_label()
symbolLabel  = syminfo.ticker
symbolDesc   = syminfo.description
headerText   = symbolLabel + "  |  " + symbolDesc + "  |  " + chartTfLabel

var table headerTable = table.new(position.top_center, 1, 1, border_width=1)

if barstate.islast
    table.clear(headerTable, 0, 0, 0, 0)

if barstate.islast and showHeaderTable
    table.cell(headerTable, 0, 0, headerText, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.normal)
````
