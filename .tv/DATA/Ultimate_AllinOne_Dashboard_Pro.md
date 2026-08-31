<!-- tradingview-pine-id: PUB;b7f5f39b0b474757b950e59e3e8faa7c -->
<!-- tradingviewscripts-format: 1 -->
# Ultimate All-in-One Dashboard Pro

Source: https://www.tradingview.com/script/eyUOsozo-Ultimate-All-in-One-Dashboard-Pro/

## Description

FeatureStatusQuality Score (A+ / B+ / C)AddedPrevious Day High / LowAddedSession High / LowAddedSMA 50 / 100 / 200AddedAlert choice (A+ Only or A+ & B+)Already thereEntry / Stop / TP / R:RAlready there

---

## Source Code

````pine
//@version=6
indicator("Ultimate All-in-One Dashboard Pro", overlay=true)

// ═══════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════
tablePos      = input.string("top_right", "Table Position", options=["top_right","bottom_right","top_left","bottom_left"])
tableSize     = input.string("small", "Table Size", options=["tiny","small","normal"])
swingLen      = input.int(3, "Swing Length", minval=2, maxval=6)

useHTF        = input.bool(false, "Require Higher Timeframe Confirmation")
htfTF         = input.timeframe("60", "Higher Timeframe")

showWatermark = input.bool(true, "Show ACTION Watermark")
wmSize        = input.string("large", "Watermark Text Size", options=["tiny","small","normal","large","huge"])
wmXOffset     = input.int(0, "Watermark X Offset (bars)", minval=-50, maxval=20)
wmYPos        = input.string("Above Price", "Watermark Vertical Position", options=["Above Price", "At Price", "Below Price"])

ts  = tableSize == "tiny" ? size.tiny : tableSize == "small" ? size.small : size.normal
wms = wmSize == "tiny" ? size.tiny : wmSize == "small" ? size.small : wmSize == "normal" ? size.normal : wmSize == "large" ? size.large : size.huge

// ═══════════════════════════════════════
// CORE
// ═══════════════════════════════════════
atr = ta.atr(14)

volSMA = ta.sma(volume, 20)
rvol   = volSMA > 0 ? volume / volSMA : 1.0
highVol = rvol >= 1.5
lowVol  = rvol <= 0.30
volStatus = highVol ? "HIGH " + str.tostring(rvol,"#.#") + "x" : lowVol ? "LOW " + str.tostring(rvol,"#.#") + "x" : "Normal " + str.tostring(rvol,"#.#") + "x"

ema9   = ta.ema(close, 9)
ema21  = ta.ema(close, 21)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)

// VWAP
var float cumPV = 0.0
var float cumVol = 0.0
if ta.change(time("D")) != 0
    cumPV := 0.0
    cumVol := 0.0
typical = (high + low + close) / 3
cumPV += typical * volume
cumVol += volume
vwap = cumVol != 0 ? cumPV / cumVol : na

// Oscillators
rsi = ta.rsi(close, 14)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
mfi = ta.mfi(hlc3, 14)

hw = ta.ema(close, 7) - ta.ema(close, 14)
hwSignal = ta.sma(hw, 3)
esa = ta.ema(hlc3, 10)
d = ta.ema(math.abs(hlc3 - esa), 10)
ci = d != 0 ? (hlc3 - esa) / (0.015 * d) : 0.0
wt1 = ta.ema(ci, 21)
wt2 = ta.sma(wt1, 4)

bullOsc = 0
bullOsc += rsi > 50 ? 1 : 0
bullOsc += macdLine > signalLine ? 1 : 0
bullOsc += mfi > 50 ? 1 : 0
bullOsc += hw > hwSignal ? 1 : 0
bullOsc += wt1 > wt2 ? 1 : 0

matrixBull = bullOsc >= 3
matrixBear = bullOsc <= 1

// Smart Trail
var float smartTrail = na
var int smartDir = 1
upTrail = low - atr * 1.9
downTrail = high + atr * 1.9

if na(smartTrail)
    smartTrail := close > open ? upTrail : downTrail
    smartDir := close > open ? 1 : -1
else
    if smartDir == 1
        smartTrail := math.max(smartTrail, upTrail)
        if close < smartTrail
            smartDir := -1
            smartTrail := downTrail
    else
        smartTrail := math.min(smartTrail, downTrail)
        if close > smartTrail
            smartDir := 1
            smartTrail := upTrail

// Structure
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float lastSwingLow  = na
var int structureDir = 0

if not na(ph)
    lastSwingHigh := ph
if not na(pl)
    lastSwingLow := pl

if not na(lastSwingHigh) and not na(lastSwingLow)
    if close > lastSwingHigh
        structureDir := 1
    if close < lastSwingLow
        structureDir := -1

// ═══════════════════════════════════════
// PREVIOUS DAY + SESSION LEVELS
// ═══════════════════════════════════════
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)

var float sessionHigh = na
var float sessionLow  = na
if ta.change(time("D")) != 0
    sessionHigh := high
    sessionLow  := low
else
    sessionHigh := math.max(nz(sessionHigh, high), high)
    sessionLow  := math.min(nz(sessionLow, low), low)

// ═══════════════════════════════════════
// HTF
// ═══════════════════════════════════════
htfClose = request.security(syminfo.tickerid, htfTF, close, barmerge.gaps_off, barmerge.lookahead_off)
htfEma9  = request.security(syminfo.tickerid, htfTF, ta.ema(close, 9), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfClose > htfEma9
htfBear = htfClose < htfEma9
htfStatus = not useHTF ? "OFF" : htfBull ? "Bullish" : htfBear ? "Bearish" : "Mixed"

// ═══════════════════════════════════════
// ENTRY
// ═══════════════════════════════════════
longSupport = math.max(math.min(ema9, ema21), vwap)
if not na(lastSwingLow) and lastSwingLow < close
    longSupport := math.max(longSupport, lastSwingLow)
longEntry = longSupport - atr * 0.08

shortResistance = math.min(math.max(ema9, ema21), vwap)
if not na(lastSwingHigh) and lastSwingHigh > close
    shortResistance := math.min(shortResistance, lastSwingHigh)
shortEntry = shortResistance + atr * 0.08

// ═══════════════════════════════════════
// DECISION + QUALITY SCORE
// ═══════════════════════════════════════
bool trailBull  = smartDir == 1
bool trailBear  = smartDir == -1
bool structBull = structureDir == 1
bool structBear = structureDir == -1
bool emaBull    = ema9 > ema21
bool emaBear    = ema9 < ema21

bool strongLong  = trailBull and structBull and emaBull and matrixBull and not lowVol and (not useHTF or htfBull)
bool strongShort = trailBear and structBear and emaBear and matrixBear and not lowVol and (not useHTF or htfBear)

bool mildLong  = trailBull and not lowVol and (not useHTF or htfBull) and (structBull or emaBull)
bool mildShort = trailBear and not lowVol and (not useHTF or htfBear) and (structBear or emaBear)

string quality = "C"
if strongLong or strongShort
    quality := "A+"
else if mildLong or mildShort
    quality := "B+"
else
    quality := "C"

string conflictReason = ""
if useHTF and not htfBull and not htfBear
    conflictReason := "HTF Mixed"
else if trailBull and structBear and not emaBull
    conflictReason := "Trail vs Structure"
else if trailBear and structBull and not emaBear
    conflictReason := "Trail vs Structure"
else if not matrixBull and not matrixBear
    conflictReason := "Oscillators Mixed"
else if lowVol
    conflictReason := "Extremely Low Volume"
else
    conflictReason := "No Clear Edge"

string action = ""
string bias = ""
color biasColor = color.orange
float entryPrice = na
float stopPrice = na
float tp1 = na
float rr = 1.7

if strongLong
    action := "LOOK FOR LONGS"
    bias := "STRONG BULLISH"
    biasColor := color.lime
    entryPrice := longEntry
    stopPrice  := entryPrice - atr * 1.25
    tp1 := entryPrice + (entryPrice - stopPrice) * 1.8
    rr := 1.8
else if strongShort
    action := "LOOK FOR SHORTS"
    bias := "STRONG BEARISH"
    biasColor := color.red
    entryPrice := shortEntry
    stopPrice  := entryPrice + atr * 1.25
    tp1 := entryPrice - (stopPrice - entryPrice) * 1.8
    rr := 1.8
else if mildLong
    action := "LONG BIAS – Wait Pullback"
    bias := "BULLISH"
    biasColor := color.lime
    entryPrice := longEntry
    stopPrice  := entryPrice - atr * 1.3
    tp1 := entryPrice + (entryPrice - stopPrice) * 1.5
    rr := 1.5
else if mildShort
    action := "SHORT BIAS – Wait Rally"
    bias := "BEARISH"
    biasColor := color.red
    entryPrice := shortEntry
    stopPrice  := entryPrice + atr * 1.3
    tp1 := entryPrice - (stopPrice - entryPrice) * 1.5
    rr := 1.5
else
    action := "WAIT – " + conflictReason
    bias := "NO CLEAR DIRECTION"
    biasColor := color.orange

// ═══════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════
entryZone = atr * 0.25

nearLongStrong  = strongLong  and math.abs(close - longEntry)  <= entryZone
nearShortStrong = strongShort and math.abs(close - shortEntry) <= entryZone

nearLongMild  = (strongLong or mildLong)  and math.abs(close - longEntry)  <= entryZone
nearShortMild = (strongShort or mildShort) and math.abs(close - shortEntry) <= entryZone

bullConfirm = close > open and (close - open) >= (high - low) * 0.35
bearConfirm = close < open and (open - close) >= (high - low) * 0.35

longAplus  = nearLongStrong  and bullConfirm and not (nearLongStrong[1]  and bullConfirm[1])
shortAplus = nearShortStrong and bearConfirm and not (nearShortStrong[1] and bearConfirm[1])

longABplus  = nearLongMild  and bullConfirm and not (nearLongMild[1]  and bullConfirm[1])
shortABplus = nearShortMild and bearConfirm and not (nearShortMild[1] and bearConfirm[1])

alertcondition(longAplus,   title="Long Entry (A+ Only)",     message="A+ LONG {{ticker}} | Price: {{close}} | Follow Watermark")
alertcondition(shortAplus,  title="Short Entry (A+ Only)",    message="A+ SHORT {{ticker}} | Price: {{close}} | Follow Watermark")
alertcondition(longABplus,  title="Long Entry (A+ and B+)",   message="LONG {{ticker}} | Price: {{close}} | Follow Watermark")
alertcondition(shortABplus, title="Short Entry (A+ and B+)",  message="SHORT {{ticker}} | Price: {{close}} | Follow Watermark")

// ═══════════════════════════════════════
// WATERMARK
// ═══════════════════════════════════════
var label wm = na
if showWatermark and barstate.islast
    label.delete(wm)
    float yPos = wmYPos == "Above Price" ? high + atr * 2.0 : wmYPos == "Below Price" ? low - atr * 2.0 : close
    string wmText = action
    if not na(entryPrice)
        float dist = math.abs(close - entryPrice)
        wmText := quality + "  " + action + "\nEntry: " + str.tostring(entryPrice, "#.##") + " (" + str.tostring(dist, "#.##") + " away)\nStop: " + str.tostring(stopPrice, "#.##") + "\nTP1: " + str.tostring(tp1, "#.##") + "\nR:R 1 : " + str.tostring(rr, "#.#")
    wm := label.new(bar_index + wmXOffset, yPos, wmText, style=label.style_label_center, textcolor=biasColor, color=color.new(color.black, 78), size=wms, textalign=text.align_center)

// ═══════════════════════════════════════
// TABLE
// ═══════════════════════════════════════
var table t = table.new(tablePos, 2, 18, bgcolor=color.new(#0b0e11, 0), border_width=1, border_color=color.new(color.gray, 40))

if barstate.islast
    table.cell(t, 0, 0, "ULTIMATE PRO", text_color=color.white, text_size=ts, bgcolor=color.new(#1565C0, 20))
    table.cell(t, 1, 0, syminfo.ticker + " • " + timeframe.period, text_color=color.white, text_size=ts, bgcolor=color.new(#1565C0, 20))

    table.cell(t, 0, 1, "ACTION", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 1, action, text_color=biasColor, text_size=ts)

    table.cell(t, 0, 2, "QUALITY", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 2, quality, text_color = quality == "A+" ? color.lime : quality == "B+" ? color.yellow : color.gray, text_size=ts)

    table.cell(t, 0, 3, "BIAS", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 3, bias, text_color=biasColor, text_size=ts)

    table.cell(t, 0, 4, "Price", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 4, str.tostring(close, "#.##"), text_color=color.yellow, text_size=ts)

    table.cell(t, 0, 5, "VWAP", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 5, str.tostring(vwap, "#.##") + (close > vwap ? "  Above" : "  Below"), text_color = close > vwap ? color.lime : color.red, text_size=ts)

    table.cell(t, 0, 6, "Volume", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 6, volStatus, text_color = highVol ? color.orange : lowVol ? color.gray : color.white, text_size=ts)

    table.cell(t, 0, 7, "Smart Trail", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 7, (trailBull ? "BULLISH" : "BEARISH") + "  " + str.tostring(smartTrail, "#.##"), text_color = trailBull ? color.lime : color.red, text_size=ts)

    table.cell(t, 0, 8, "Structure", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 8, structBull ? "Bullish Structure" : structBear ? "Bearish Structure" : "No Clear", text_color = structBull ? color.lime : structBear ? color.red : color.yellow, text_size=ts)

    table.cell(t, 0, 9, "OSC MATRIX", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 9, matrixBull ? "BULLISH" : matrixBear ? "BEARISH" : "MIXED", text_color = matrixBull ? color.lime : matrixBear ? color.red : color.yellow, text_size=ts)

    table.cell(t, 0, 10, "HTF Confirm", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 10, htfStatus, text_color = htfStatus == "Bullish" ? color.lime : htfStatus == "Bearish" ? color.red : color.gray, text_size=ts)

    table.cell(t, 0, 11, "EMA 9 / 21", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 11, str.tostring(ema9, "#.##") + "  |  " + str.tostring(ema21, "#.##"), text_color=color.white, text_size=ts)

    table.cell(t, 0, 12, "SMA 50 / 100 / 200", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 12, str.tostring(sma50, "#.##") + " | " + str.tostring(sma100, "#.##") + " | " + str.tostring(sma200, "#.##"), text_color=color.white, text_size=ts)

    table.cell(t, 0, 13, "Prev Day H / L", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 13, str.tostring(prevDayHigh, "#.##") + "  |  " + str.tostring(prevDayLow, "#.##"), text_color=color.white, text_size=ts)

    table.cell(t, 0, 14, "Session H / L", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 14, str.tostring(sessionHigh, "#.##") + "  |  " + str.tostring(sessionLow, "#.##"), text_color=color.white, text_size=ts)

    table.cell(t, 0, 15, "LONG Entry", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 15, str.tostring(longEntry, "#.##"), text_color=color.lime, text_size=ts)

    table.cell(t, 0, 16, "SHORT Entry", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 16, str.tostring(shortEntry, "#.##"), text_color=color.red, text_size=ts)

    table.cell(t, 0, 17, "BOS Levels", text_color=color.silver, text_size=ts)
    table.cell(t, 1, 17, "Bull " + str.tostring(lastSwingHigh, "#.##") + " | Bear " + str.tostring(lastSwingLow, "#.##"), text_color=color.white, text_size=ts)
````
