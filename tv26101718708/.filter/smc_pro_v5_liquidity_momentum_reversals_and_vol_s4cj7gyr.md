# SMC Pro V5: Liquidity, Momentum & Reversals and Vol

- url: https://www.tradingview.com/script/s4cJ7GYR-SMC-Pro-V5-Liquidity-Momentum-Reversals-and-Vol/
- type: indicator
- pine_id: PUB;834cfea991b649399a6e28e83a2694c9
- version: 1.0

## Description

lets try this out
That's it — all six alerts kept, just with static const string messages instead of the dynamic concatenated ones. Pine Script v6 strictly requires alertcondition message arguments to be compile-time constants, so the score value has to stay off the alert message and on the chart label/dashboard instead.

## Source Code

````pine
//@version=6
indicator("SMC Pro V5: Liquidity, Momentum & Reversals and Vol", overlay = true, max_boxes_count = 50, max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

grp_ms      = "Market Structure"
pivotLength = input.int(8, "Pivot Length", group = grp_ms, minval = 2, tooltip = "8-15 for daily swing. 20-40 for multi-week/month swing.")

grp_vol       = "Volume"
volMaLength   = input.int(20, "Volume MA Length", group = grp_vol, minval = 1)
volMult       = input.float(1.8, "Volume Multiplier", group = grp_vol, minval = 0.1)
colUp         = input.color(color.rgb(39, 54, 233), "Up Volume Color", group = grp_vol)
colDn         = input.color(color.rgb(222, 50, 174), "Down Volume Color", group = grp_vol)
prevC         = input.bool(true, "Color Based On Previous Close", group = grp_vol)
lwVol         = input.bool(false, "Highlight Low Relative Volume", group = grp_vol)
colLw         = input.color(color.rgb(123, 124, 126), "Low RelVol Color", group = grp_vol)
showVolLabels = input.bool(true, "Show Volume Labels on Peaks", group = grp_vol)
peakLen       = input.int(9, "Peak Volume Label Length", group = grp_vol, minval = 2)
showHVE       = input.bool(true, "Mark HVE / HV1 (Daily/Weekly/Monthly only)", group = grp_vol)

grp_mom       = "Momentum"
rsiLength     = input.int(14, "RSI Length", group = grp_mom, minval = 2)
rsiOverbought = input.int(70, "RSI Overbought", group = grp_mom, minval = 51, maxval = 99)
rsiOversold   = input.int(30, "RSI Oversold", group = grp_mom, minval = 1, maxval = 49)
colorCandles  = input.bool(true, "Color Candles by Momentum", group = grp_mom)

grp_rev          = "Early Reversal Detection"
showRev          = input.bool(true, "Show Reversal Signals", group = grp_rev)
divLookback      = input.int(12, "Reversal Swing Lookback", group = grp_rev, minval = 5)
climaxMult       = input.float(2.2, "Climax Volume Multiplier", group = grp_rev, minval = 1.2)
trendMaLen       = input.int(50, "Trend Filter EMA Length", group = grp_rev, minval = 5)
revCooldown      = input.int(8, "Cooldown (bars)", group = grp_rev, minval = 3)
showSetupDots    = input.bool(false, "Show Setup Watch Dots", group = grp_rev)
revMinScore      = input.int(78, "Minimum Reversal Score", group = grp_rev, minval = 50, maxval = 100)
strongRevMin     = input.int(88, "Strong Reversal Score", group = grp_rev, minval = 60, maxval = 100)
wickMult         = input.float(1.7, "Rejection Wick / Body Ratio", group = grp_rev, minval = 0.5)
atrRejectMult    = input.float(1.6, "ATR Extension Needed", group = grp_rev, minval = 0.5)
useAdxFilter     = input.bool(true, "Avoid Fighting Very Strong Trend (ADX)", group = grp_rev)
mtfStrictness    = input.int(2, "MTF Agreements Needed (1-3)", group = grp_rev, minval = 1, maxval = 3)
chochCooldown    = input.int(10, "Bars to Wait After CHoCH", group = grp_rev, minval = 0)
requireExtension = input.bool(true, "Require Price Extension from Trend MA", group = grp_rev)

grp_atr   = "ATR Bands"
showAtr   = input.bool(true, "Show ATR Bands", group = grp_atr)
atrLength = input.int(14, "ATR Period", group = grp_atr, minval = 1)
atrEmaLen = input.int(20, "Baseline EMA Length", group = grp_atr, minval = 1)
atrMult1  = input.float(1.5, "ATR Multiplier 1", group = grp_atr, minval = 0.1)
atrMult2  = input.float(3.0, "ATR Multiplier 2", group = grp_atr, minval = 0.1)

grp_ob           = "Order Blocks"
showOBMitigation = input.bool(true, "Deactivate OB on Mitigation", group = grp_ob)

grp_dash = "Dashboard"
showDash = input.bool(true, "Show Dashboard", group = grp_dash)
dashPos  = input.string(position.top_right, "Position", options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left], group = grp_dash)

grp_style    = "Style"
bullColor    = input.color(#089981, "Bullish Color", group = grp_style)
bearColor    = input.color(#f23645, "Bearish Color", group = grp_style)
neutralColor = input.color(#888888, "Neutral Color", group = grp_style)
revBullColor = input.color(#00bcd4, "Bull Reversal Color", group = grp_style)
revBearColor = input.color(#ff9800, "Bear Reversal Color", group = grp_style)

// ══════════════════════════════════════════════════════════════════════════════
// CORE INDICATORS
// ══════════════════════════════════════════════════════════════════════════════

momRsi        = ta.rsi(close, rsiLength)
strongBullMom = momRsi >= rsiOverbought
strongBearMom = momRsi <= rsiOversold

avgVol       = ta.sma(volume, volMaLength)
isBullCandle = close >= open
isBearCandle = close  < open
highVolume   = volume > avgVol * volMult

// MarketSmith-style volume coloring
volColor      = prevC ? (close >= close[1] ? colUp : colDn) : (isBullCandle ? colUp : colDn)
lowRVolFlag   = ta.lowest(volume, 10) == volume
volColorFinal = (lwVol and lowRVolFlag) ? colLw : volColor

atrVal    = ta.atr(atrLength)
emaBase   = ta.ema(close, atrEmaLen)
upperAtr1 = emaBase + atrVal * atrMult1
lowerAtr1 = emaBase - atrVal * atrMult1
upperAtr2 = emaBase + atrVal * atrMult2
lowerAtr2 = emaBase - atrVal * atrMult2

trendMa     = ta.ema(close, trendMaLen)
inUptrend   = close > trendMa
inDowntrend = close < trendMa

williamsR     = ta.wpr(14)
wprOversold   = -80.0
wprOverbought = -20.0

// ══════════════════════════════════════════════════════════════════════════════
// MARKETSMITH VOLUME ANALYSIS
// ══════════════════════════════════════════════════════════════════════════════

var float hve = volume
if volume > hve
    hve := volume

oneYear = timeframe.isweekly ? 52 : timeframe.ismonthly ? 12 : 252
hvone   = ta.highest(volume, oneYear)

volBuzz    = avgVol != 0 ? 100.0 * (volume / avgVol) - 100.0 : 0.0
volBuzzStr = volBuzz >= 0 ? "+" + str.tostring(math.round(volBuzz)) + "%" : str.tostring(math.round(volBuzz)) + "%"
buzzColor  = volBuzz >= 0 ? bullColor : bearColor

// Up/Down Volume Ratio (50-bar)
upVol   = close > close[1] ? volume : 0
dnVol   = close < close[1] ? volume : 0
sumUp   = math.sum(upVol, 50)
sumDn   = math.sum(dnVol, 50)
udRatio = sumDn != 0 ? sumUp / sumDn : 1.0
udColor = udRatio >= 1.2 ? bullColor : udRatio <= 0.8 ? bearColor : neutralColor

// Volume formatting helper
formatVol(v) =>
    val    = math.round(v, 0)
    suffix = ""
    if val >= 1000000000
        val    := math.round(val / 1000000000.0, 2)
        suffix := "B"
    else if val >= 1000000
        val    := math.round(val / 1000000.0, 2)
        suffix := "M"
    else if val >= 1000
        val    := math.round(val / 1000.0, 2)
        suffix := "K"
    str.tostring(val, "0.0") + suffix

// Average dollar volume
avgDolVol    = math.round(close * avgVol, 2)
avgDolVolStr = formatVol(avgDolVol)

// Peak volume labels (MarketSmith-style)
pivotVolHigh  = ta.pivothigh(volume, peakLen, peakLen)
varPct        = avgVol[peakLen] != 0 ? 100.0 * (volume[peakLen] / avgVol[peakLen]) - 100.0 : 0.0
showHVEactive = showHVE and (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)

var label peakLabel1 = na
var label peakLabel2 = na

if not na(pivotVolHigh) and varPct > 25 and showVolLabels
    label.delete(peakLabel1)
    label.delete(peakLabel2)
    hvTag = ""
    if showHVEactive
        if volume[peakLen] == hve
            hvTag := "HVE ● "
        else if volume[peakLen] == hvone[peakLen]
            hvTag := "HV1 ● "
    peakLabel1 := label.new(bar_index - peakLen, volume[peakLen], hvTag + formatVol(volume[peakLen]), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, size = size.small, textcolor = color.new(color.white, 0))
    peakLabel2 := label.new(bar_index - peakLen, volume[peakLen], "\n+" + str.tostring(math.round(varPct, 0)) + "%", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_none, size = size.small, textcolor = color.new(bullColor, 0))

isClimax = volume > avgVol * climaxMult
isHVEBar = showHVEactive and volume == hve
isHV1Bar = showHVEactive and volume == hvone and volume < hve

// ══════════════════════════════════════════════════════════════════════════════
// MOMENTUM SCORE (1–100)
// ══════════════════════════════════════════════════════════════════════════════

ema20s  = ta.ema(close, 20)
ema50s  = ta.ema(close, 50)
ema200s = ta.ema(close, 200)
emaScore = ((close > ema20s ? 1.0 : 0.0) + (close > ema50s ? 1.0 : 0.0) + (close > ema200s ? 1.0 : 0.0)) / 3.0

[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
macdAbsMax = ta.highest(math.abs(histLine), 50)
macdNorm   = macdAbsMax != 0 ? math.max(0.0, math.min(1.0, (histLine / (2.0 * macdAbsMax)) + 0.5)) : 0.5

avgVolScore = ta.sma(volume, 20)
volRatio    = avgVolScore != 0 ? math.min(volume / avgVolScore, 3.0) / 3.0 : 0.5
volMomScore = isBullCandle ? volRatio : 1.0 - volRatio

atrBody  = ta.atr(14)
bodySize = math.abs(close - open)
bodyNorm = atrBody != 0 ? math.min(bodySize / atrBody, 1.5) / 1.5 : 0.5
bodyNorm := isBullCandle ? bodyNorm : 1.0 - bodyNorm

udMomScore = math.min(math.max((udRatio - 0.5) / 2.0, 0.0), 1.0)

rsiNorm  = momRsi / 100.0
momScore = math.round(math.max(1.0, math.min(100.0,
 (rsiNorm * 0.28 + emaScore * 0.23 + macdNorm * 0.22 + volMomScore * 0.12 + bodyNorm * 0.10 + udMomScore * 0.05) * 100.0)))
scoreColor = momScore >= 70 ? bullColor : momScore <= 30 ? bearColor : neutralColor

candleColor = momRsi >= rsiOverbought ? color.new(bullColor, 0) : momRsi > 50 ? color.new(bullColor, 40) : momRsi <= rsiOversold ? color.new(bearColor, 0) : color.new(bearColor, 40)
barcolor(colorCandles ? candleColor : na)

// ══════════════════════════════════════════════════════════════════════════════
// ATR BANDS
// ══════════════════════════════════════════════════════════════════════════════

p_ema = plot(showAtr ? emaBase   : na, "Baseline EMA", color = color.new(color.gray, 50))
p_u1  = plot(showAtr ? upperAtr1 : na, "Upper ATR 1",  color = color.new(bearColor, 50))
p_l1  = plot(showAtr ? lowerAtr1 : na, "Lower ATR 1",  color = color.new(bullColor, 50))
p_u2  = plot(showAtr ? upperAtr2 : na, "Upper ATR 2",  color = color.new(bearColor, 80))
p_l2  = plot(showAtr ? lowerAtr2 : na, "Lower ATR 2",  color = color.new(bullColor, 80))
fill(p_u1, p_u2, color.new(bearColor, 90), "Upper ATR Zone")
fill(p_l1, p_l2, color.new(bullColor, 90), "Lower ATR Zone")

// ══════════════════════════════════════════════════════════════════════════════
// MTF SMC TREND — crossover/crossunder moved to local variables (fixes CW10002)
// ══════════════════════════════════════════════════════════════════════════════

get_smc_trend(len) =>
    var float lastH = na
    var float lastL = na
    var int   tr    = 0
    phx       = ta.pivothigh(high, len, len)
    plx       = ta.pivotlow(low,  len, len)
    if not na(phx)
        lastH := phx
    if not na(plx)
        lastL := plx
    crossUp   = ta.crossover(close, lastH)
    crossDown = ta.crossunder(close, lastL)
    if not na(lastH) and crossUp
        tr := 1
    if not na(lastL) and crossDown
        tr := -1
    tr

trend1H = request.security(syminfo.tickerid, "60",  get_smc_trend(pivotLength), lookahead = barmerge.lookahead_off)
trend4H = request.security(syminfo.tickerid, "240", get_smc_trend(pivotLength), lookahead = barmerge.lookahead_off)
trend1D = request.security(syminfo.tickerid, "1D",  get_smc_trend(pivotLength), lookahead = barmerge.lookahead_off)

// ══════════════════════════════════════════════════════════════════════════════
// MARKET STRUCTURE — CHoCH + ORDER BLOCKS
// ══════════════════════════════════════════════════════════════════════════════

var float lastHigh    = na
var float lastLow     = na
var int   lastHighLoc = na
var int   lastLowLoc  = na

ph = ta.pivothigh(high, pivotLength, pivotLength)
pl = ta.pivotlow(low,  pivotLength, pivotLength)

if not na(ph)
    lastHigh    := ph
    lastHighLoc := bar_index[pivotLength]
if not na(pl)
    lastLow    := pl
    lastLowLoc := bar_index[pivotLength]

var int  trend    = 0
var box  obBox    = na
var bool obIsBull = false

// Fix CW10002: declare cross results as globals before use in conditions
crossOverLastHigh  = ta.crossover(close, lastHigh)
crossUnderLastLow  = ta.crossunder(close, lastLow)

bullBreakout = not na(lastHigh) and crossOverLastHigh and trend != 1
bearBreakout = not na(lastLow)  and crossUnderLastLow  and trend != -1

var int lastBullChochBar = na
var int lastBearChochBar = na

if bullBreakout
    trend            := 1
    obIsBull         := true
    lastBullChochBar := bar_index
    volTag = isClimax ? " [Climax Vol]" : highVolume ? " [High Vol]" : ""
    lbl    = "Bull CHoCH" + volTag
    if strongBullMom
        lbl += "\nHigh Mom"
    label.new(bar_index, low, lbl, style = label.style_label_up, color = color.new(bullColor, isClimax ? 0 : highVolume ? 20 : 50), textcolor = color.white, size = size.small)
    if not na(lastLowLoc)
        lb  = bar_index - lastLowLoc
        obt = high[lb]
        obb = low[lb]
        if not na(obt) and not na(obb)
            obBox := box.new(lastLowLoc, obt, bar_index, obb, border_color = color.new(bullColor, 50), bgcolor = color.new(bullColor, 85))

if bearBreakout
    trend            := -1
    obIsBull         := false
    lastBearChochBar := bar_index
    volTag = isClimax ? " [Climax Vol]" : highVolume ? " [High Vol]" : ""
    lbl    = "Bear CHoCH" + volTag
    if strongBearMom
        lbl += "\nHigh Mom"
    label.new(bar_index, high, lbl, style = label.style_label_down, color = color.new(bearColor, isClimax ? 0 : highVolume ? 20 : 50), textcolor = color.white, size = size.small)
    if not na(lastHighLoc)
        lb  = bar_index - lastHighLoc
        obt = high[lb]
        obb = low[lb]
        if not na(obt) and not na(obb)
            obBox := box.new(lastHighLoc, obt, bar_index, obb, border_color = color.new(bearColor, 50), bgcolor = color.new(bearColor, 85))

if not na(obBox)
    obTop     = box.get_top(obBox)
    obBot     = box.get_bottom(obBox)
    mitigated = showOBMitigation and (obIsBull ? close < obTop : close > obBot)
    if not mitigated
        box.set_right(obBox, bar_index)
    else
        obBox := na

plotshape(highVolume and isBullCandle, "High Buy Volume",  style = shape.triangleup,   location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(highVolume and isBearCandle, "High Sell Volume", style = shape.triangledown, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(isHVEBar,                    "HVE Bar",          style = shape.cross,         location = location.abovebar, color = color.new(color.yellow, 0), size = size.small)
plotshape(isHV1Bar,                    "HV1 Bar",          style = shape.diamond,       location = location.abovebar, color = color.new(color.orange, 20), size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// EARLY REVERSAL DETECTION
// ══════════════════════════════════════════════════════════════════════════════

[dip, dim, adxVal] = ta.dmi(14, 14)

revPH = ta.pivothigh(high, divLookback, divLookback)
revPL = ta.pivotlow(low,  divLookback, divLookback)

var float revLastHigh    = na
var float revPrevHigh    = na
var float revLastLow     = na
var float revPrevLow     = na
var float revLastRsiHigh = na
var float revPrevRsiHigh = na
var float revLastRsiLow  = na
var float revPrevRsiLow  = na

if not na(revPH)
    revPrevHigh    := revLastHigh
    revLastHigh    := revPH
    revPrevRsiHigh := revLastRsiHigh
    revLastRsiHigh := momRsi[divLookback]

if not na(revPL)
    revPrevLow    := revLastLow
    revLastLow    := revPL
    revPrevRsiLow := revLastRsiLow
    revLastRsiLow := momRsi[divLookback]

bullDiv = not na(revPrevLow) and not na(revLastLow) and not na(revPrevRsiLow) and not na(revLastRsiLow) and (revLastLow < revPrevLow) and (revLastRsiLow > revPrevRsiLow)
bearDiv = not na(revPrevHigh) and not na(revLastHigh) and not na(revPrevRsiHigh) and not na(revLastRsiHigh) and (revLastHigh > revPrevHigh) and (revLastRsiHigh < revPrevRsiHigh)

bullSweep      = not na(revLastLow)  and (low < revLastLow)  and (close > revLastLow)
bearSweep      = not na(revLastHigh) and (high > revLastHigh) and (close < revLastHigh)
bullSweepValid = bullSweep and inDowntrend
bearSweepValid = bearSweep and inUptrend

body           = math.abs(close - open)
safeBody       = body == 0 ? syminfo.mintick : body
upperWick      = high - math.max(open, close)
lowerWick      = math.min(open, close) - low
bullWickReject = lowerWick > safeBody * wickMult and lowerWick > atrVal * 0.25
bearWickReject = upperWick > safeBody * wickMult and upperWick > atrVal * 0.25

relVol    = avgVol != 0 ? volume / avgVol : 0.0
volClimax = relVol >= climaxMult

bullAtrExtreme = low  < emaBase - atrVal * atrRejectMult
bearAtrExtreme = high > emaBase + atrVal * atrRejectMult
bullBackInside = bullAtrExtreme and close > lowerAtr1
bearBackInside = bearAtrExtreme and close < upperAtr1

priceExtendedDown = close < trendMa
priceExtendedUp   = close > trendMa

bullMomentumFade = momRsi < 45 and momRsi > momRsi[1]
bearMomentumFade = momRsi > 55 and momRsi < momRsi[1]

bullFailedBreakdown = low  < low[1]  and close > low[1]  and close > open
bearFailedBreakout  = high > high[1] and close < high[1] and close < open
bullMicroConfirm = close > high[1] or bullFailedBreakdown
bearMicroConfirm = close < low[1]  or bearFailedBreakout

bullWprHook = (williamsR[1] <= wprOversold)   and (williamsR > williamsR[1])
bearWprHook = (williamsR[1] >= wprOverbought) and (williamsR < williamsR[1])

atrProx       = ta.atr(14)
nearSwingHigh = not na(revLastHigh) and (high >= revLastHigh - atrProx * 2.0)
nearSwingLow  = not na(revLastLow)  and (low  <= revLastLow  + atrProx * 2.0)

bearMtfCount     = (trend1H <= 0 ? 1 : 0) + (trend4H <= 0 ? 1 : 0) + (trend1D <= 0 ? 1 : 0)
bullMtfCount     = (trend1H >= 0 ? 1 : 0) + (trend4H >= 0 ? 1 : 0) + (trend1D >= 0 ? 1 : 0)
mtfAllowsBearRev = bearMtfCount >= mtfStrictness
mtfAllowsBullRev = bullMtfCount >= mtfStrictness

strongBullTrend = close > ema20s and ema20s > ema50s and ema50s > ema200s and adxVal > 30
strongBearTrend = close < ema20s and ema20s < ema50s and ema50s < ema200s and adxVal > 30
allowBearRev    = not useAdxFilter or not strongBullTrend or bearSweepValid or bearBackInside
allowBullRev    = not useAdxFilter or not strongBearTrend or bullSweepValid or bullBackInside

bullRevAfterChoch = chochCooldown == 0 or na(lastBearChochBar) or (bar_index - lastBearChochBar) > chochCooldown or bullSweepValid
bearRevAfterChoch = chochCooldown == 0 or na(lastBullChochBar) or (bar_index - lastBullChochBar) > chochCooldown or bearSweepValid

// ── WEIGHTED SCORE ─────────────────────────────────────────────────────────
bullRevScore = 0
bullRevScore += bullSweepValid                            ? 25 : bullSweep ? 8 : 0
bullRevScore += bullDiv                                   ? 15 : 0
bullRevScore += bullWickReject                            ? 15 : 0
bullRevScore += volClimax                                 ? 12 : 0
bullRevScore += bullBackInside                            ? 15 : 0
bullRevScore += bullMicroConfirm                          ? 10 : 0
bullRevScore += bullWprHook                               ? 10 : 0
bullRevScore += mtfAllowsBullRev                          ?  8 : 0
bullRevScore += nearSwingLow                              ?  5 : 0
bullRevScore += bullMomentumFade                          ?  5 : 0
bullRevScore += udRatio < 0.7                             ?  5 : 0
bullRevScore += (isHVEBar or isHV1Bar) and inDowntrend   ?  8 : 0
bullRevScore := math.min(bullRevScore, 100)

bearRevScore = 0
bearRevScore += bearSweepValid                            ? 25 : bearSweep ? 8 : 0
bearRevScore += bearDiv                                   ? 15 : 0
bearRevScore += bearWickReject                            ? 15 : 0
bearRevScore += volClimax                                 ? 12 : 0
bearRevScore += bearBackInside                            ? 15 : 0
bearRevScore += bearMicroConfirm                          ? 10 : 0
bearRevScore += bearWprHook                               ? 10 : 0
bearRevScore += mtfAllowsBearRev                          ?  8 : 0
bearRevScore += nearSwingHigh                             ?  5 : 0
bearRevScore += bearMomentumFade                          ?  5 : 0
bearRevScore += udRatio > 1.5                             ?  5 : 0
bearRevScore += (isHVEBar or isHV1Bar) and inUptrend     ?  8 : 0
bearRevScore := math.min(bearRevScore, 100)

// ── SIGNAL GATING ─────────────────────────────────────────────────────────
var bool bullRevLocked  = false
var bool bearRevLocked  = false
var int  lastBullRevBar = na
var int  lastBearRevBar = na

if not na(revPL)
    bullRevLocked := false
if not na(revPH)
    bearRevLocked := false

bullCooldownOk = na(lastBullRevBar) or (bar_index - lastBullRevBar) > revCooldown
bearCooldownOk = na(lastBearRevBar) or (bar_index - lastBearRevBar) > revCooldown

bullCore = bullSweep or bullBackInside or bullFailedBreakdown
bearCore = bearSweep or bearBackInside or bearFailedBreakout

extBullOk = not requireExtension or priceExtendedDown or bullBackInside
extBearOk = not requireExtension or priceExtendedUp   or bearBackInside

bullRevSignal = showRev and allowBullRev and bullCore and bullRevScore >= revMinScore and not bullRevLocked and bullCooldownOk and bullRevAfterChoch and extBullOk
bearRevSignal = showRev and allowBearRev and bearCore and bearRevScore >= revMinScore and not bearRevLocked and bearCooldownOk and bearRevAfterChoch and extBearOk

bullStrongRev = bullRevSignal and bullRevScore >= strongRevMin
bearStrongRev = bearRevSignal and bearRevScore >= strongRevMin

if bullRevSignal
    bullRevLocked  := true
    lastBullRevBar := bar_index

if bearRevSignal
    bearRevLocked  := true
    lastBearRevBar := bar_index

// ── LABEL TEXT ─────────────────────────────────────────────────────────────
bullLabelText(score) =>
    t  = score >= strongRevMin ? "Strong Bull Rev" : "Early Bull Rev"
    t += "\nScore: " + str.tostring(score) + "/100"
    t += bullSweepValid                ? "\nSweep"        : bullSweep ? "\nWeak Sweep" : ""
    t += bullDiv                       ? " + RSI Div"     : ""
    t += bullWickReject                ? " + Wick"        : ""
    t += volClimax                     ? " + Vol Climax"  : ""
    t += bullBackInside                ? " + ATR Reclaim" : ""
    t += bullMicroConfirm              ? " + Micro"       : ""
    t += bullWprHook                   ? " + WPR Hook"    : ""
    t += (isHVEBar or isHV1Bar)        ? " + HV Climax"  : ""
    t += udRatio < 0.7                 ? " + U/D Weak"    : ""
    t

bearLabelText(score) =>
    t  = score >= strongRevMin ? "Strong Bear Rev" : "Early Bear Rev"
    t += "\nScore: " + str.tostring(score) + "/100"
    t += bearSweepValid                ? "\nSweep"       : bearSweep ? "\nWeak Sweep" : ""
    t += bearDiv                       ? " + RSI Div"    : ""
    t += bearWickReject                ? " + Wick"       : ""
    t += volClimax                     ? " + Vol Climax" : ""
    t += bearBackInside                ? " + ATR Reject" : ""
    t += bearMicroConfirm              ? " + Micro"      : ""
    t += bearWprHook                   ? " + WPR Hook"   : ""
    t += (isHVEBar or isHV1Bar)        ? " + HV Climax"  : ""
    t += udRatio > 1.5                 ? " + U/D Strong" : ""
    t

if bullRevSignal
    label.new(bar_index, low,  bullLabelText(bullRevScore), style = label.style_label_up,   color = color.new(revBullColor, bullStrongRev ? 0 : 20), textcolor = color.white, size = bullStrongRev ? size.normal : size.small)

if bearRevSignal
    label.new(bar_index, high, bearLabelText(bearRevScore), style = label.style_label_down, color = color.new(revBearColor, bearStrongRev ? 0 : 20), textcolor = color.white, size = bearStrongRev ? size.normal : size.small)

plotshape(bullRevSignal, "Early Bull Reversal", shape.triangleup,   location.belowbar, color.new(revBullColor, 0), size = size.small)
plotshape(bearRevSignal, "Early Bear Reversal", shape.triangledown, location.abovebar, color.new(revBearColor, 0), size = size.small)

bullSetup = showSetupDots and showRev and not bullRevSignal and bullCore and bullRevScore >= 55
bearSetup = showSetupDots and showRev and not bearRevSignal and bearCore and bearRevScore >= 55
plotshape(bullSetup, "Bull Setup Watch", shape.circle, location.belowbar, color.new(revBullColor, 65), size = size.tiny)
plotshape(bearSetup, "Bear Setup Watch", shape.circle, location.abovebar, color.new(revBearColor, 65), size = size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullRevSignal, "Early Bull Reversal",  "SMC Pro v3: Early Bull Reversal signal fired")
alertcondition(bearRevSignal, "Early Bear Reversal",  "SMC Pro v3: Early Bear Reversal signal fired")
alertcondition(bullStrongRev, "Strong Bull Reversal", "SMC Pro v3: Strong Bull Reversal signal fired")
alertcondition(bearStrongRev, "Strong Bear Reversal", "SMC Pro v3: Strong Bear Reversal signal fired")
alertcondition(bullBreakout,  "Bull CHoCH",           "SMC Pro v3: Bull Change of Character")
alertcondition(bearBreakout,  "Bear CHoCH",           "SMC Pro v3: Bear Change of Character")

// ══════════════════════════════════════════════════════════════════════════════
// DXY CORRELATION & HISTORICAL VOLATILITY
// ══════════════════════════════════════════════════════════════════════════════

dxyClose = request.security("TVC:DXY", timeframe.period, close, lookahead = barmerge.lookahead_off)
dxyCorr  = ta.correlation(close, dxyClose, 20)

var int annualPeriods = 252
annualPeriods := syminfo.type == "crypto" ? 365 : 252
hvStat = ta.stdev(math.log(close / close[1]), 30) * math.sqrt(annualPeriods) * 100

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════

trendStr(t) => t == 1 ? "Bullish" : t == -1 ? "Bearish" : "Neutral"
trendCol(t) => t == 1 ? bullColor : t == -1 ? bearColor : neutralColor

var table dash = na

if showDash and barstate.islast
    if na(dash)
        dash := table.new(dashPos, 2, 14, bgcolor = color.new(chart.bg_color, 10), border_width = 1, border_color = color.new(color.gray, 50))

    // Header
    table.cell(dash, 0, 0, "Metric",   text_color = color.black, bgcolor = color.new(color.gray, 50))
    table.cell(dash, 1, 0, "Value",    text_color = color.black, bgcolor = color.new(color.gray, 50))

    // MTF Trends
    table.cell(dash, 0, 1, "SMC 1H",  text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 1, trendStr(trend1H), text_color = color.black, bgcolor = color.new(trendCol(trend1H), 50))

    table.cell(dash, 0, 2, "SMC 4H",  text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 2, trendStr(trend4H), text_color = color.black, bgcolor = color.new(trendCol(trend4H), 50))

    table.cell(dash, 0, 3, "SMC 1D",  text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 3, trendStr(trend1D), text_color = color.black, bgcolor = color.new(trendCol(trend1D), 50))

    // RSI
    rsiColor = momRsi >= rsiOverbought ? bearColor : momRsi <= rsiOversold ? bullColor : momRsi > 50 ? bullColor : bearColor
    table.cell(dash, 0, 4, "RSI (" + str.tostring(rsiLength) + ")", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 4, str.tostring(momRsi, "#.##"), text_color = color.black, bgcolor = color.new(rsiColor, 50))

    // Momentum Score
    momLabel = momScore >= 70 ? "Strong Bull" : momScore <= 30 ? "Strong Bear" : momScore > 50 ? "Mild Bull" : momScore < 50 ? "Mild Bear" : "Neutral"
    table.cell(dash, 0, 5, "Mom Score", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 5, str.tostring(momScore) + "/100 " + momLabel, text_color = color.black, bgcolor = color.new(scoreColor, 50))

    // Reversal Signal
    revStatus = bullRevSignal ? "Bull " + str.tostring(bullRevScore) : bearRevSignal ? "Bear " + str.tostring(bearRevScore) : "None"
    revColor  = bullRevSignal ? revBullColor : bearRevSignal ? revBearColor : neutralColor
    table.cell(dash, 0, 6, "Rev Signal", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 6, revStatus, text_color = color.black, bgcolor = color.new(revColor, 50))

    // Rev Score B/S
    table.cell(dash, 0, 7, "Rev Score B/S", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 7, str.tostring(bullRevScore) + " / " + str.tostring(bearRevScore), text_color = color.black, bgcolor = color.new(neutralColor, 60))

    // Up/Down Volume Ratio (from MarketSmith)
    table.cell(dash, 0, 8, "U/D Vol (50)", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 8, str.tostring(udRatio, "#.##"), text_color = color.black, bgcolor = color.new(udColor, 50))

    // Volume Buzz (from MarketSmith)
    table.cell(dash, 0, 9, "Vol Buzz", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 9, volBuzzStr, text_color = color.black, bgcolor = color.new(buzzColor, 50))

    // Avg $ Volume (from MarketSmith)
    table.cell(dash, 0, 10, "Avg $ Vol", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 10, avgDolVolStr, text_color = color.black, bgcolor = color.new(neutralColor, 70))

    // DXY Correlation
    corrColor = dxyCorr > 0 ? bullColor : bearColor
    table.cell(dash, 0, 11, "DXY Corr", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 11, str.tostring(dxyCorr, "#.##"), text_color = color.black, bgcolor = color.new(corrColor, 50))

    // Historical Volatility
    hvStatColor = hvStat > 50 ? bearColor : hvStat > 20 ? neutralColor : bullColor
    table.cell(dash, 0, 12, "HV30", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 12, str.tostring(hvStat, "#.##") + "%", text_color = color.black, bgcolor = color.new(hvStatColor, 50))

    // Williams %R
    wprColor = williamsR <= wprOversold ? bullColor : williamsR >= wprOverbought ? bearColor : neutralColor
    table.cell(dash, 0, 13, "Williams %R", text_color = color.black, bgcolor = color.new(color.gray, 80))
    table.cell(dash, 1, 13, str.tostring(williamsR, "#.##"), text_color = color.black, bgcolor = color.new(wprColor, 50))
````
