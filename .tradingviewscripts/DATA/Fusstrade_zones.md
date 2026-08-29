<!-- tradingview-pine-id: PUB;270c7e71e5c545e6903b231a80b640b4 -->
<!-- tradingviewscripts-format: 1 -->
# Fusstrade zones 

Source: https://www.tradingview.com/script/G49pPNJy-Fusstrade-zones/

## Description

Zones is a multi-market TradingView indicator that displays manually defined supply, demand, and gap zones for stocks, ETFs, indices, futures, commodities, and major technology symbols. It also includes key market levels such as previous highs/lows, weekly and monthly opens, VWAP, EMA cloud, and TRAMA for additional trend and price-action analysis.

---

## Source Code

````pine
//@version=6
indicator("Fusstrade zones ", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// Colors
colorHigh      = input.color(color.red,    title="Color for High Line and Text")
colorLow       = input.color(color.green,  title="Color for Low Line and Text")
colorDayOpen   = input.color(color.blue,   title="Color for Daily Open Line and Text")
colorWeekOpen  = input.color(color.orange, title="Color for Weekly Open Line and Text")
colorMonthOpen = input.color(color.purple, title="Color for Monthly Open Line and Text")

// Show/Hide
showPDH = input.bool(true, title="Show PDH Level")
showPDL = input.bool(true, title="Show PDL Level")
showPWH = input.bool(true, title="Show PWH Level")
showPWL = input.bool(true, title="Show PWL Level")
showWO  = input.bool(true, title="Show Weekly Open Level")
showMO  = input.bool(true, title="Show Monthly Open Level")

cutOnTouch = input.bool(true, title="Cut line when price touches it")

// Regular session only for PDH/PDL
rthSession = input.session("0930-1600", "Regular Session for PDH/PDL")

// Zone labels
showZonePrices = input.bool(true, "Show Zone Price Labels")
zoneLabelBarsRight = input.int(8, "Zone Label Bars Right", minval=1, maxval=100)

// === helper: touch definition ===
touches(float level) =>
    low <= level and high >= level

endTime(int hitT) =>
    na(hitT) ? time : hitT

fmtPrice(float v) =>
    str.tostring(v, format.mintick)

// ===== Session state =====
inRTH   = not na(time(timeframe.period, rthSession))
rthStart = inRTH and not inRTH[1]
rthEnd   = not inRTH and inRTH[1]

// ===== Previous day/week storage (TIME) =====
var int   pdhTime  = na
var float pdhPrice = na
var int   pdlTime  = na
var float pdlPrice = na
var int   pwhTime  = na
var float pwhPrice = na
var int   pwlTime  = na
var float pwlPrice = na

var int   doStartTime = na
var int   woStartTime = na
var int   moStartTime = na

// ===== Current day/week trackers =====
var int   currentDayHighTime = na
var float currentDayHigh     = na
var int   currentDayLowTime  = na
var float currentDayLow      = na

var int   currentWeekHighTime = na
var float currentWeekHigh     = na
var int   currentWeekLowTime  = na
var float currentWeekLow      = na

// ===== Hit times (first touch) =====
var int pdhHitTime = na
var int pdlHitTime = na
var int pwhHitTime = na
var int pwlHitTime = na
var int doHitTime  = na
var int woHitTime  = na
var int moHitTime  = na

// ===== New Day =====
bool isNewDay = ta.change(time("D")) != 0
if isNewDay
    doStartTime := time
    pdhHitTime := na
    pdlHitTime := na
    doHitTime  := na

// ===== PDH/PDL from previous completed RTH session only =====
if rthStart
    currentDayHighTime := time
    currentDayHigh     := high
    currentDayLowTime  := time
    currentDayLow      := low

if inRTH
    if na(currentDayHigh) or high > currentDayHigh
        currentDayHigh := high
        currentDayHighTime := time
    if na(currentDayLow) or low < currentDayLow
        currentDayLow := low
        currentDayLowTime := time

if rthEnd
    pdhTime  := currentDayHighTime
    pdhPrice := currentDayHigh
    pdlTime  := currentDayLowTime
    pdlPrice := currentDayLow

// ===== New Week =====
bool isNewWeek = ta.change(time("W")) != 0

if isNewWeek
    pwhTime  := currentWeekHighTime
    pwhPrice := currentWeekHigh
    pwlTime  := currentWeekLowTime
    pwlPrice := currentWeekLow

    currentWeekHighTime := time
    currentWeekHigh     := high
    currentWeekLowTime  := time
    currentWeekLow      := low

    woStartTime := time

    pwhHitTime := na
    pwlHitTime := na
    woHitTime  := na
else
    if na(currentWeekHigh) or high > currentWeekHigh
        currentWeekHigh := high
        currentWeekHighTime := time

    if na(currentWeekLow) or low < currentWeekLow
        currentWeekLow := low
        currentWeekLowTime := time

// ===== New Month =====
bool isNewMonth = ta.change(time("M")) != 0
if isNewMonth
    moStartTime := time
    moHitTime := na

// Opens
dayOpen   = request.security(syminfo.tickerid, "D", open[0], lookahead=barmerge.lookahead_on)
weekOpen  = request.security(syminfo.tickerid, "W", open[0], lookahead=barmerge.lookahead_on)
monthOpen = request.security(syminfo.tickerid, "M", open[0], lookahead=barmerge.lookahead_on)

// ===== Touch detection (store first touch TIME) =====
if cutOnTouch and showPDH and na(pdhHitTime) and not na(pdhPrice) and not na(doStartTime) and time >= doStartTime
    if touches(pdhPrice)
        pdhHitTime := time

if cutOnTouch and showPDL and na(pdlHitTime) and not na(pdlPrice) and not na(doStartTime) and time >= doStartTime
    if touches(pdlPrice)
        pdlHitTime := time

if cutOnTouch and showPWH and na(pwhHitTime) and not na(pwhPrice) and not na(woStartTime) and time >= woStartTime
    if touches(pwhPrice)
        pwhHitTime := time

if cutOnTouch and showPWL and na(pwlHitTime) and not na(pwlPrice) and not na(woStartTime) and time >= woStartTime
    if touches(pwlPrice)
        pwlHitTime := time

if cutOnTouch and showWO and na(woHitTime) and not na(weekOpen) and not na(woStartTime) and time > woStartTime
    if touches(weekOpen)
        woHitTime := time

if cutOnTouch and showMO and na(moHitTime) and not na(monthOpen) and not na(moStartTime) and time > moStartTime
    if touches(monthOpen)
        moHitTime := time

// ===== Lines & labels (delete + redraw style) =====
var line  highLine = na
var line  lowLine = na
var line  weekHighLine = na
var line  weekLowLine = na
var line  weekOpenLine = na
var line  monthOpenLine = na

var label highLabel = na
var label lowLabel = na
var label weekHighLabel = na
var label weekLowLabel = na
var label weekOpenLabel = na
var label monthOpenLabel = na

if not na(highLine)
    line.delete(highLine)
if not na(lowLine)
    line.delete(lowLine)
if not na(weekHighLine)
    line.delete(weekHighLine)
if not na(weekLowLine)
    line.delete(weekLowLine)
if not na(weekOpenLine)
    line.delete(weekOpenLine)
if not na(monthOpenLine)
    line.delete(monthOpenLine)

if not na(highLabel)
    label.delete(highLabel)
if not na(lowLabel)
    label.delete(lowLabel)
if not na(weekHighLabel)
    label.delete(weekHighLabel)
if not na(weekLowLabel)
    label.delete(weekLowLabel)
if not na(weekOpenLabel)
    label.delete(weekOpenLabel)
if not na(monthOpenLabel)
    label.delete(monthOpenLabel)

// Draw PDH
if showPDH and not na(pdhTime) and not na(pdhPrice)
    int x2 = cutOnTouch ? endTime(pdhHitTime) : time
    highLine  := line.new(x1=pdhTime, y1=pdhPrice, x2=x2, y2=pdhPrice, xloc=xloc.bar_time, color=colorHigh, width=1)
    highLabel := label.new(x=x2, y=pdhPrice, xloc=xloc.bar_time, yloc=yloc.price, text="PDH " + fmtPrice(pdhPrice), textcolor=colorHigh, style=label.style_none, size=size.normal, textalign=text.align_left)

// Draw PDL
if showPDL and not na(pdlTime) and not na(pdlPrice)
    int x2 = cutOnTouch ? endTime(pdlHitTime) : time
    lowLine  := line.new(x1=pdlTime, y1=pdlPrice, x2=x2, y2=pdlPrice, xloc=xloc.bar_time, color=colorLow, width=1)
    lowLabel := label.new(x=x2, y=pdlPrice, xloc=xloc.bar_time, yloc=yloc.price, text="PDL " + fmtPrice(pdlPrice), textcolor=colorLow, style=label.style_none, size=size.normal, textalign=text.align_left)

// Draw PWH
if showPWH and not na(pwhTime) and not na(pwhPrice)
    int x2 = cutOnTouch ? endTime(pwhHitTime) : time
    weekHighLine  := line.new(x1=pwhTime, y1=pwhPrice, x2=x2, y2=pwhPrice, xloc=xloc.bar_time, color=colorHigh, width=1)
    weekHighLabel := label.new(x=x2, y=pwhPrice, xloc=xloc.bar_time, yloc=yloc.price, text="PWH " + fmtPrice(pwhPrice), textcolor=colorHigh, style=label.style_none, size=size.normal, textalign=text.align_left)

// Draw PWL
if showPWL and not na(pwlTime) and not na(pwlPrice)
    int x2 = cutOnTouch ? endTime(pwlHitTime) : time
    weekLowLine  := line.new(x1=pwlTime, y1=pwlPrice, x2=x2, y2=pwlPrice, xloc=xloc.bar_time, color=colorLow, width=1)
    weekLowLabel := label.new(x=x2, y=pwlPrice, xloc=xloc.bar_time, yloc=yloc.price, text="PWL " + fmtPrice(pwlPrice), textcolor=colorLow, style=label.style_none, size=size.normal, textalign=text.align_left)

// Draw Weekly Open
if showWO and not na(weekOpen) and not na(woStartTime)
    int x2 = cutOnTouch ? endTime(woHitTime) : time
    weekOpenLine  := line.new(x1=woStartTime, y1=weekOpen, x2=x2, y2=weekOpen, xloc=xloc.bar_time, color=colorWeekOpen, width=1)
    weekOpenLabel := label.new(x=x2, y=weekOpen, xloc=xloc.bar_time, yloc=yloc.price, text="W " + fmtPrice(weekOpen), textcolor=colorWeekOpen, style=label.style_none, size=size.normal, textalign=text.align_left)

// Draw Monthly Open
if showMO and not na(monthOpen) and not na(moStartTime)
    int x2 = cutOnTouch ? endTime(moHitTime) : time
    monthOpenLine  := line.new(x1=moStartTime, y1=monthOpen, x2=x2, y2=monthOpen, xloc=xloc.bar_time, color=colorMonthOpen, width=1)
    monthOpenLabel := label.new(x=x2, y=monthOpen, xloc=xloc.bar_time, yloc=yloc.price, text="M " + fmtPrice(monthOpen), textcolor=colorMonthOpen, style=label.style_none, size=size.normal, textalign=text.align_left)
    
// ═════════════════════════════════════════════════════════════════════════════
// ─── EMA 9/21 Cloud + Target Price [SS] ─────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
arraylookback = input.float(500, "ATR Lookback Length")
showlbls      = input.bool(true,  "Show Target Price Labels")

ema9  = ta.ema(close, 9)
ema21 = ta.ema(close, 21)

ema9_cross_ema21 = ta.crossover(ema9,  ema21)
ema21_cross_ema9 = ta.crossover(ema21, ema9)

bool bullish = close >= ema9 and close >= ema21
bool bearish = close <= ema9 and close <= ema21

bull         = color.new(color.lime, 75)
bear         = color.new(color.red, 75)
neutralcolor = color.new(color.gray, 75)
crossovercolor  = color.new(color.purple, 75)
crossundercolor = color.new(color.orange, 75)

color pallette = bullish ? bull : bearish ? bear : neutralcolor
color emacolor = ema9_cross_ema21 ? crossovercolor : ema21_cross_ema9 ? crossundercolor : pallette

filla = plot(ema9,  color=emacolor, linewidth=1)
fillb = plot(ema21, color=emacolor, linewidth=1)
fill(filla, fillb, color=pallette)

bool above_ema  = close >= ema9 and close >= ema21
bool below_ema  = close <  ema9 and close <= ema21
bool crossover  = ema9_cross_ema21
bool crossunder = ema21_cross_ema9

bull_a       = array.new_float()
open_a       = array.new_float()
crossover_a  = array.new_float()
crossunder_a = array.new_float()
bear_a       = array.new_float()

lookback = int(arraylookback)
for i = 0 to lookback
    if above_ema[i]
        array.push(bull_a, close[i])
    if crossover[i]
        array.push(crossover_a, close[i])
        array.push(open_a, open[i])
    if below_ema[i]
        array.push(bear_a, close[i])
    if crossunder[i]
        array.push(crossunder_a, close[i])

max_above      = array.size(bull_a) > 0 ? array.max(bull_a) : na
crossover_avg  = array.size(crossover_a) > 0 ? array.avg(crossover_a) : na
max_below      = array.size(bear_a) > 0 ? array.min(bear_a) : na
crossunder_avg = array.size(crossunder_a) > 0 ? array.avg(crossunder_a) : na

bull_dif1 = not na(max_above) and not na(crossover_avg) ? (max_above - crossover_avg) / 2 : na
bull_dif2 = not na(max_above) and not na(crossover_avg) ? (max_above - crossover_avg) : na
bear_dif1 = not na(crossunder_avg) and not na(max_below) ? (crossunder_avg - max_below) / 2 : na
bear_dif2 = not na(crossunder_avg) and not na(max_below) ? (crossunder_avg - max_below) : na

float op         = 0.0
float bull_tgt   = 0.0
float bull_tgt_2 = 0.0
float bear_tgt   = 0.0
float bear_tgt_2 = 0.0

var label bull_tgt_1_lbl = na
var label bull_tgt_2_lbl = na
var label bear_tgt_1_lbl = na
var label bear_tgt_2_lbl = na
var line  bull_tgt_lin   = na
var line  bull_tgt_lin_2 = na
var line  bear_tgt_lin   = na
var line  bear_tgt_lin_2 = na

if crossover
    if array.size(open_a) > 0
        op := array.get(open_a, 0)
    if not na(bull_dif1)
        bull_tgt   := op + bull_dif1
    if not na(bull_dif2)
        bull_tgt_2 := op + bull_dif2
if crossunder
    if array.size(open_a) > 0
        op := array.get(open_a, 0)
    if not na(bear_dif1)
        bear_tgt   := op - bear_dif1
    if not na(bear_dif2)
        bear_tgt_2 := op - bear_dif2

// ═════════════════════════════════════════════════════════════════════════════
// ─── VWAP — Volume Weighted Average Price ───────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
hideonDWM   = input(false, title="Hide VWAP on 1D or Above", group="VWAP Settings", display=display.none)
var anchor  = input.string("Session", title="Anchor Period",
     options=["Session","Week","Month","Quarter","Year","Decade","Century","Earnings","Dividends","Splits"],
     group="VWAP Settings")
vwap_src    = input.source(hlc3, title="Source", group="VWAP Settings", display=display.none)
vwap_offset = input.int(0, title="Offset", group="VWAP Settings", display=display.none)

cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0 and syminfo.ticker != "VIX"
    runtime.error("No volume is provided by the data vendor.")

isNewPeriod = switch anchor
    "Earnings"  =>
        new_earnings_actual       = request.earnings(syminfo.tickerid, earnings.actual, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_earnings_actual) or not na(new_earnings_standardized)
    "Dividends" =>
        new_dividends = request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_dividends)
    "Splits"    =>
        new_split = request.splits(syminfo.tickerid, splits.denominator, barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_split)
    "Session"   => timeframe.change("D")
    "Week"      => timeframe.change("W")
    "Month"     => timeframe.change("M")
    "Quarter"   => timeframe.change("3M")
    "Year"      => timeframe.change("12M")
    "Decade"    => timeframe.change("12M") and year % 10 == 0
    "Century"   => timeframe.change("12M") and year % 100 == 0
    => false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(vwap_src[1]) and not isEsdAnchor
    isNewPeriod := true

float vwapValue = na
if not (hideonDWM and timeframe.isdwm)
    [_vwap, _, __] = ta.vwap(vwap_src, isNewPeriod, 1)
    vwapValue := _vwap

plot(vwapValue, title="VWAP", color=#2962FF, linewidth=2, offset=vwap_offset)

// ═════════════════════════════════════════════════════════════════════════════
// ─── TRAMA — Trend Regularity Adaptive Moving Average [LuxAlgo] ─────────────
// ═════════════════════════════════════════════════════════════════════════════
trama_length = input.int(34, "TRAMA Length")
trama_src    = input.source(close, "TRAMA Source")

var float ama = na
hh  = math.max(math.sign(ta.change(ta.highest(trama_length))), 0)
ll  = math.max(math.sign(ta.change(ta.lowest(trama_length)) * -1), 0)
tc  = math.pow(ta.sma(hh != 0 or ll != 0 ? 1.0 : 0.0, trama_length), 2)
ama := na(ama[1]) ? trama_src : ama[1] + tc * (trama_src - ama[1])
plot(ama, "TRAMA", color=#ff1100, linewidth=2)

supplyColor = input.color(color.new(color.red, 75), "Supply Zone Color")
demandColor = input.color(color.new(color.green, 75), "Demand Zone Color")
gapColor    = input.color(color.new(color.orange, 70), "Gap Zone Color")
borderColor = input.color(color.new(color.gray, 50), "Border Color")

matchesTicker(key) =>
    t = str.upper(syminfo.ticker)
    k = str.upper(key)
    t == k or t == "/" + k or "/" + t == k

drawZone(top, bot, zoneType, labelTxt) =>
    c  = zoneType == "Supply" ? supplyColor : zoneType == "Gap" ? gapColor : demandColor
    lc = zoneType == "Supply" ? color.new(color.red, 20) : zoneType == "Gap" ? color.new(color.orange, 0) : color.new(color.green, 20)
    zoneText = labelTxt != "" ? labelTxt + " | " + fmtPrice(top) + " - " + fmtPrice(bot) : fmtPrice(top) + " - " + fmtPrice(bot)

    leftTime  = time[math.min(bar_index, 4999)]
    rightTime = time + 86400000 * 30
    dt        = bar_index > 0 ? (time - time[1]) : 60000
    labelX    = time + dt * zoneLabelBarsRight

    box.new(leftTime, top, rightTime, bot, border_color=borderColor, bgcolor=c, extend=extend.both, xloc=xloc.bar_time)
    line.new(leftTime, top, rightTime, top, color=lc, width=1, style=line.style_solid, extend=extend.both, xloc=xloc.bar_time)
    line.new(leftTime, bot, rightTime, bot, color=lc, width=1, style=line.style_solid, extend=extend.both, xloc=xloc.bar_time)

    if showZonePrices
        label.new(labelX, (top + bot) / 2, zoneText, xloc=xloc.bar_time, yloc=yloc.price, color=color.new(color.black, 100), textcolor=lc, style=label.style_label_left, size=size.huge)
isSPY   = matchesTicker("SPY")
isQQQ   = matchesTicker("QQQ")
isSMH   = matchesTicker("SMH")
isIGV   = matchesTicker("IGV")
isIWM   = matchesTicker("IWM")
isDRAM  = matchesTicker("DRAM")
isMSFT  = matchesTicker("MSFT")
isAAPL  = matchesTicker("AAPL")
isTSLA  = matchesTicker("TSLA")
isNVDA  = matchesTicker("NVDA")
isAMD   = matchesTicker("AMD")
isAVGO  = matchesTicker("AVGO")
isMU    = matchesTicker("MU")
isMRVL  = matchesTicker("MRVL")
isINTC  = matchesTicker("INTC")
isNBIS  = matchesTicker("NBIS")
isPLTR  = matchesTicker("PLTR")
isAMZN  = matchesTicker("AMZN")
isMETA  = matchesTicker("META")
isGOOGL = matchesTicker("GOOGL")
isGOOG  = matchesTicker("GOOG")
isIREN  = matchesTicker("IREN")
isARM   = matchesTicker("ARM")
isNOW   = matchesTicker("NOW")
isSKHY  = matchesTicker("SKHY")
isSNDK  = matchesTicker("SNDK")
isHOOD  = matchesTicker("HOOD")
isCRWD  = matchesTicker("CRWD")
isCRWV  = matchesTicker("CRWV")
isIBM   = matchesTicker("IBM")
isSPCX  = matchesTicker("SPCX")
isCAT   = matchesTicker("CAT")
isNQ    = matchesTicker("NQ")
isES    = matchesTicker("ES")
isRTY   = matchesTicker("RTY")
isYM    = matchesTicker("YM")
isGC    = matchesTicker("GC")
isGLD   = matchesTicker("GLD")
isCL    = matchesTicker("CL")
isHPE   = matchesTicker("HPE")
isDELL  = matchesTicker("DELL")
isPANW  = matchesTicker("PANW")

var bool zonesDrawn = false

if barstate.islast and not zonesDrawn
    zonesDrawn := true

    if isQQQ
        drawZone(731.33, 728.42, "Supply", "")
        drawZone(710.23, 707.56, "Gap", "")
        drawZone(723.85, 723.18, "Demand", "")
        drawZone(719.32, 718.58, "Demand", "")
        drawZone(698.66, 695.25, "Demand", "")
        drawZone(687.40, 686.37, "Demand", "")
        drawZone(680.05, 677.75, "Demand", "")

    if isSPY
        drawZone(773.41, 772.97, "Demand", "")
        drawZone(769.91, 769.31, "Demand", "")
        drawZone(762.81, 761.46, "Demand", "")
        drawZone(760.40, 756.68, "Demand", "")
        drawZone(750.92, 748.73, "Demand", "")
        drawZone(740.80, 739.35, "Demand", "")
        drawZone(735.87, 734.59, "Demand", "")
        drawZone(724.87, 722.59, "Demand", "")
        drawZone(714.99, 712.39, "Demand", "")

    if isIWM
        drawZone(302.72, 302.23, "Supply", "")
        drawZone(298.12, 297.71, "Demand", "")
        drawZone(295.52, 294.73, "Demand", "")
        drawZone(287.87, 287.05, "Demand", "")
        drawZone(278.28, 277.45, "Demand", "")

    if isSMH
        drawZone(618.21, 614.98, "Supply", "")
        drawZone(595.84, 592.51, "Supply", "")
        drawZone(566.83, 561.44, "Gap", "")
        drawZone(536.81, 527.87, "Demand", "")
        drawZone(501.15, 497.75, "Demand", "")

    if isIGV
        drawZone(108.06, 107.30, "Supply", "")
        drawZone(105.61, 104.48, "Supply", "")
        drawZone(101.26, 100.81, "Demand", "")
        drawZone(97.50, 96.78, "Demand", "")
        drawZone(88.58, 87.08, "Demand", "")

    if isDRAM
        drawZone(60.10, 59.59, "Supply", "")
        drawZone(56.38, 55.38, "Supply", "")
        drawZone(49.00, 48.31, "Demand", "")
        drawZone(43.43, 42.90, "Demand", "")

    if isTSLA
        drawZone(367.71, 364.02, "Supply", "")
        drawZone(342.11, 337.24, "Supply", "")
        drawZone(318.00, 317.00, "Demand", "")
        drawZone(311.16, 309.12, "Demand", "")
        drawZone(300.13, 291.31, "Demand", "")

    if isNVDA
        drawZone(232.28, 231.50, "Supply", "")
        drawZone(227.84, 226.13, "Supply", "")
        drawZone(222.22, 221.60, "Demand", "")
        drawZone(217.49, 217.17, "Demand", "")
        drawZone(214.39, 212.19, "Demand", "")
        drawZone(205.96, 204.81, "Demand", "")
        drawZone(198.96, 197.97, "Demand", "")
        drawZone(190.77, 189.80, "Demand", "")

    if isINTC
        drawZone(132.95, 130.98, "Supply", "")
        drawZone(106.80, 105.76, "Supply", "")
        drawZone(98.33, 97.38, "Demand", "")
        drawZone(80.80, 79.62, "Demand", "")
        drawZone(70.33, 68.20, "Demand", "")

    if isAMD
        drawZone(562.65, 559.50, "Supply", "")
        drawZone(518.15, 515.62, "Supply", "")
        drawZone(460.21, 455.30, "Demand", "")
        drawZone(424.03, 420.20, "Demand", "")

    if isAVGO
        drawZone(442.60, 438.90, "Supply", "")
        drawZone(427.58, 426.48, "Gap", "")
        drawZone(414.64, 412.70, "Demand", "")
        drawZone(399.92, 394.65, "Demand", "")
        drawZone(363.37, 360.64, "Demand", "")

    if isARM
        drawZone(299.87, 296.40, "Supply", "")
        drawZone(268.48, 261.90, "Demand", "")
        drawZone(243.12, 240.38, "Demand", "")
        drawZone(206.38, 193.91, "Demand", "")

    if isMRVL
        drawZone(242.00, 237.20, "Supply", "")
        drawZone(225.14, 223.94, "Supply", "")
        drawZone(201.35, 199.29, "Demand", "")
        drawZone(181.76, 177.51, "Demand", "")
        drawZone(162.85, 158.55, "Demand", "")

    if isMU
        drawZone(1011.77, 994.83, "Supply", "")
        drawZone(933.70, 922.71, "Supply", "")
        drawZone(858.50, 853.73, "Gap", "")
        drawZone(817.71, 804.00, "Demand", "")
        drawZone(747.21, 706.60, "Demand", "")

    if isSNDK
        drawZone(1513.50, 1485.02, "Supply", "")
        drawZone(1325.03, 1277.33, "Supply", "")
        drawZone(1125.00, 1115.25, "Demand", "")
        drawZone(995.00, 980.28, "Demand", "")

    if isSKHY
        drawZone(162.28, 160.66, "Supply", "")
        drawZone(139.25, 137.23, "Supply", "")
        drawZone(118.00, 113.71, "Demand", "")

    if isMETA
        drawZone(599.97, 597.22, "Supply", "")
        drawZone(580.42, 577.07, "Demand", "")
        drawZone(556.68, 553.07, "Demand", "")
        drawZone(540.40, 536.99, "Demand", "")

    if isGOOGL
        drawZone(388.51, 388.00, "Supply", "")
        drawZone(379.72, 378.26, "Supply", "")
        drawZone(373.60, 370.89, "Supply", "")
        drawZone(350.15, 348.66, "Supply", "")
        drawZone(343.20, 341.64, "Supply", "")
        drawZone(330.10, 328.67, "Demand", "")
        drawZone(326.20, 323.98, "Demand", "")
        drawZone(317.50, 317.02, "Demand", "")

    if isAAPL
        drawZone(317.40, 316.53, "Supply", "")
        drawZone(303.20, 300.00, "Demand", "")
        drawZone(288.62, 287.40, "Demand", "")
        drawZone(274.86, 273.23, "Demand", "")
        drawZone(244.07, 241.07, "Demand", "")

    if isAMZN
        drawZone(283.31, 282.79, "Supply", "")
        drawZone(278.56, 277.12, "Supply", "")
        drawZone(271.06, 270.45, "Demand", "")
        drawZone(258.60, 256.48, "Demand", "")
        drawZone(226.31, 225.55, "Demand", "")
        drawZone(207.12, 206.22, "Demand", "")
        drawZone(197.85, 194.69, "Demand", "")

    if isMSFT
        drawZone(493.25, 489.70, "Demand", "")
        drawZone(468.35, 464.89, "Demand", "")
        drawZone(381.71, 380.50, "Demand", "")
        drawZone(376.45, 365.66, "Demand", "")
        drawZone(349.67, 344.79, "Demand", "")

    if isIREN
        drawZone(63.59, 63.00, "Supply", "")
        drawZone(60.18, 58.87, "Supply", "")
        drawZone(53.70, 53.00, "Supply", "")
        drawZone(45.34, 44.00, "Supply", "")
        drawZone(38.08, 37.62, "Demand", "")
        drawZone(33.34, 33.00, "Demand", "")

    if isNBIS
        drawZone(233.73, 230.30, "Supply", "")
        drawZone(186.03, 181.06, "Demand", "")
        drawZone(141.10, 132.30, "Demand", "")

    if isPLTR
        drawZone(166.35, 163.70, "Demand", "")
        drawZone(152.98, 150.76, "Demand", "")
        drawZone(107.00, 105.32, "Demand", "")
        drawZone(99.33, 98.17, "Demand", "")

    if isHOOD
        drawZone(131.78, 129.95, "Supply", "")
        drawZone(124.70, 120.46, "Supply", "")
        drawZone(112.50, 110.73, "Supply", "")
        drawZone(106.83, 105.99, "Supply", "")
        drawZone(103.46, 101.88, "Supply", "")
        drawZone(93.32, 90.70, "Demand", "")

    if isNOW
        drawZone(139.20, 135.73, "Supply", "")
        drawZone(126.67, 124.80, "Supply", "")
        drawZone(113.79, 112.00, "Demand", "")
        drawZone(97.81, 95.75, "Demand", "")

    if isCRWD
        drawZone(217.50, 216.58, "Supply", "")
        drawZone(209.50, 208.25, "Demand", "")
        drawZone(201.75, 200.30, "Demand", "")
        drawZone(196.42, 194.86, "Demand", "")
        drawZone(181.78, 181.00, "Demand", "")
        drawZone(175.54, 173.98, "Demand", "")

    if isCRWV
        drawZone(95.14, 94.21, "Supply", "")
        drawZone(85.19, 84.24, "Demand", "")
        drawZone(80.56, 79.46, "Demand", "")
        drawZone(67.15, 63.80, "Demand", "")

    if isIBM
        drawZone(238.96, 237.99, "Supply", "")
        drawZone(230.97, 229.92, "Demand", "")
        drawZone(224.76, 223.95, "Demand", "")

    if isSPCX
        drawZone(149.34, 147.11, "Supply", "")
        drawZone(130.99, 129.88, "Demand", "")
        drawZone(118.93, 117.50, "Demand", "")
        drawZone(106.75, 104.83, "Demand", "")

    if isCAT
        drawZone(938.18, 931.35, "Supply", "")
        drawZone(850.80, 845.55, "Supply", "")
        drawZone(789.81, 770.61, "Demand", "")

    if isNQ
        drawZone(30361.50, 30293.50, "Supply", "")
        drawZone(30094.00, 29993.25, "Supply", "")
        drawZone(29364.75, 29160.50, "Gap", "")
        drawZone(29702.00, 29688.75, "Demand", "")
        drawZone(28782.00, 28700.00, "Demand", "")
        drawZone(28099.50, 27939.00, "Demand", "")
        drawZone(27337.75, 27195.00, "Demand", "")

    if isES
        drawZone(7786.00, 7780.25, "Demand", "")
        drawZone(7739.50, 7718.75, "Demand", "")
        drawZone(7648.75, 7632.00, "Demand", "")
        drawZone(7563.50, 7542.75, "Demand", "")
        drawZone(7482.75, 7468.50, "Demand", "")
        drawZone(7421.25, 7411.75, "Demand", "")

    if isRTY
        drawZone(3068.40, 3061.90, "Supply", "")
        drawZone(3002.80, 2996.40, "Demand", "")
        drawZone(2943.40, 2932.10, "Demand", "")

    if isYM
        drawZone(53113.00, 52962.00, "Demand", "")
        drawZone(51822.00, 51716.00, "Demand", "")

    if isGC
        drawZone(4558.00, 4547.30, "Supply", "")
        drawZone(4458.80, 4443.80, "Supply", "")
        drawZone(4292.60, 4270.70, "Demand", "")
        drawZone(3960.30, 3901.30, "Demand", "")

    if isGLD
        drawZone(410.80, 410.80, "Supply", "")
        drawZone(403.30, 402.04, "Supply", "")
        drawZone(387.08, 383.60, "Demand", "")
        drawZone(363.33, 360.12, "Demand", "")

    if isCL
        drawZone(93.84, 92.27, "Supply", "")
        drawZone(86.20, 85.78, "Supply", "")
        drawZone(78.43, 77.78, "Demand", "")
        drawZone(74.24, 73.86, "Demand", "")

    if isHPE
        drawZone(54.63, 54.00, "Demand", "")
        drawZone(51.08, 50.20, "Demand", "")

    if isDELL
        drawZone(466.45, 460.50, "Supply", "")
        drawZone(364.62, 357.07, "Demand", "")

    if isPANW
        drawZone(382.12, 379.83, "Supply", "")
        drawZone(368.80, 366.31, "Demand", "")
        drawZone(347.36, 345.01, "Demand", "")
        drawZone(334.03, 331.81, "Demand", "")

    if isGOOG
        drawZone(381.58, 378.80, "Supply", "")
        drawZone(353.00, 350.15, "Demand", "")
        drawZone(330.10, 328.67, "Demand", "")
````
