# 8AM ORB + Rejection Master

- url: https://www.tradingview.com/script/60QhZ1JQ-8AM-ORB-Rejection-Master/
- type: indicator
- pine_id: PUB;1eaf0aad2b5546efad081c9ea95c78a5
- version: 1.0

## Description

test for claude redevlopment process in the 8am orb and rejction edits

## Source Code

````pine
//@version=6
indicator("8AM ORB + Rejection Master", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ================================================================
// INPUTS
// ================================================================

newsOff      = input.bool(false,  "News Filter - Disable All Signals",   group="ORB Strategy")
midZonePct   = input.float(0.25,  "Bounce Zone (pct of ORB range)",       group="ORB Strategy", minval=0.05, maxval=0.5, step=0.05)
useRej       = input.bool(true,   "Enable Rejection Trades",             group="Rejection Strategy")
atrMult      = input.float(0.35,  "SL Buffer beyond level (ATR x)",      group="Rejection Strategy", minval=0.1, maxval=1.0, step=0.05)
proxMult     = input.float(0.5,   "Level Proximity (ATR x)",             group="Rejection Strategy", minval=0.1, maxval=2.0, step=0.1)
minRejScore  = input.int(50,      "Min Score to Signal (0-100)",         group="Rejection Strategy", minval=0, maxval=100)
maxRejPerDay = input.int(2,       "Max Rejection Trades Per Day",        group="Rejection Strategy", minval=1, maxval=5)
panelMode    = input.string("ORB", "Panel Mode", options=["ORB", "Rejection"], group="Display")
showTP1      = input.bool(true,   "Show TP1 (1R)",                       group="Display")
showTP2      = input.bool(true,   "Show TP2 (2R)",                       group="Display")
showTP3      = input.bool(true,   "Show TP3 (3R)",                       group="Display")
showBox      = input.bool(true,   "Show ORB Build Box",                  group="Display")
showPanel    = input.bool(true,   "Show Panel",                          group="Display")
extLen       = input.int(50,      "Level Line Length (bars)",            group="Display", minval=10, maxval=300)
cLong        = input.color(#00c853, "Long",       group="Colors")
cShort       = input.color(#d50000, "Short",      group="Colors")
cORB         = input.color(#ff9800, "ORB Levels", group="Colors")
cSL          = input.color(#ef5350, "Stop Loss",  group="Colors")
cTP1c        = input.color(#81c784, "TP1",        group="Colors")
cTP2c        = input.color(#43a047, "TP2",        group="Colors")
cTP3c        = input.color(#1b5e20, "TP3",        group="Colors")
cRej         = input.color(#2962ff, "HTF Levels", group="Colors")

// ================================================================
// CORE INDICATORS
// ================================================================

ema200 = ta.ema(close, 200)
atr14  = ta.atr(14)
vSMA   = ta.sma(volume, 20)
volOK  = volume > vSMA * 1.2
rsi14  = ta.rsi(close, 14)

// ================================================================
// HTF LEVELS (no repaint)
// ================================================================

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)
pmh = request.security(syminfo.tickerid, "M", high[1], lookahead=barmerge.lookahead_on)
pml = request.security(syminfo.tickerid, "M", low[1],  lookahead=barmerge.lookahead_on)

// ── PREVIOUS SESSION HIGH/LOW TRACKING ────────────────────────────────────
// Sessions (New York time):
//   Asia    — 8:00 PM to 11:59 PM ET (prior evening)
//   London  — 12:00 AM to 6:59 AM ET
//   New York — 9:30 AM to 4:00 PM ET
// We track each session while it's building, then on close we snapshot
// the completed H/L into "prev" vars which persist as the key levels.

inAsia   = not na(time(timeframe.period, "2000-2359:23456", "America/New_York"))
inLondon = not na(time(timeframe.period, "0000-0659:23456", "America/New_York"))
inNY     = not na(time(timeframe.period, "0930-1600:23456", "America/New_York"))

// Live accumulators — build while session is active
var float asiaHLive  = na
var float asiaLLive  = na
var float ldnHLive   = na
var float ldnLLive   = na
var float nyHLive    = na
var float nyLLive    = na

// Completed previous session levels — these are the key levels drawn on chart
var float prevAsiaH  = na
var float prevAsiaL  = na
var float prevLdnH   = na
var float prevLdnL   = na
var float prevNYH    = na
var float prevNYL    = na

var bool prevInAsia   = false
var bool prevInLondon = false
var bool prevInNY     = false

// Accumulate live during each session
if inAsia
    asiaHLive := na(asiaHLive) ? high : math.max(asiaHLive, high)
    asiaLLive := na(asiaLLive) ? low  : math.min(asiaLLive, low)

if inLondon
    ldnHLive  := na(ldnHLive)  ? high : math.max(ldnHLive, high)
    ldnLLive  := na(ldnLLive)  ? low  : math.min(ldnLLive, low)

if inNY
    nyHLive   := na(nyHLive)   ? high : math.max(nyHLive, high)
    nyLLive   := na(nyLLive)   ? low  : math.min(nyLLive, low)

// On session close — snapshot into prev vars and reset live accumulators
if not inAsia and prevInAsia and not na(asiaHLive)
    prevAsiaH := asiaHLive
    prevAsiaL := asiaLLive
    asiaHLive := na
    asiaLLive := na

if not inLondon and prevInLondon and not na(ldnHLive)
    prevLdnH  := ldnHLive
    prevLdnL  := ldnLLive
    ldnHLive  := na
    ldnLLive  := na

if not inNY and prevInNY and not na(nyHLive)
    prevNYH   := nyHLive
    prevNYL   := nyLLive
    nyHLive   := na
    nyLLive   := na

prevInAsia   := inAsia
prevInLondon := inLondon
prevInNY     := inNY

// Draw HTF levels on last bar only to prevent duplicates
var line lPDH  = na
var line lPDL  = na
var line lPWH  = na
var line lPWL  = na
var line lPMH  = na
var line lPML  = na
var line lAsiaH = na
var line lAsiaL = na
var line lLdnH  = na
var line lLdnL  = na
var line lNYH   = na
var line lNYL   = na
var label bPDH = na
var label bPDL = na
var label bPWH = na
var label bPWL = na
var label bPMH = na
var label bPML = na
var label bAsiaH = na
var label bAsiaL = na
var label bLdnH  = na
var label bLdnL  = na
var label bNYH   = na
var label bNYL   = na

if barstate.islast and useRej
    // Delete and redraw all HTF lines
    line.delete(lPDH)
    line.delete(lPDL)
    line.delete(lPWH)
    line.delete(lPWL)
    line.delete(lPMH)
    line.delete(lPML)
    line.delete(lAsiaH)
    line.delete(lAsiaL)
    line.delete(lLdnH)
    line.delete(lLdnL)
    line.delete(lNYH)
    line.delete(lNYL)
    label.delete(bPDH)
    label.delete(bPDL)
    label.delete(bPWH)
    label.delete(bPWL)
    label.delete(bPMH)
    label.delete(bPML)
    label.delete(bAsiaH)
    label.delete(bAsiaL)
    label.delete(bLdnH)
    label.delete(bLdnL)
    label.delete(bNYH)
    label.delete(bNYL)
    // Previous Day — solid, brightest (most recent)
    lPDH  := line.new(bar_index - extLen, pdh, bar_index + extLen, pdh, color=color.new(cRej, 10), width=2, style=line.style_solid)
    lPDL  := line.new(bar_index - extLen, pdl, bar_index + extLen, pdl, color=color.new(cRej, 10), width=2, style=line.style_solid)
    bPDH  := label.new(bar_index + extLen, pdh, "PDH  " + str.tostring(pdh, format.mintick), color=color.new(cRej, 25), textcolor=color.white, style=label.style_label_left, size=size.small)
    bPDL  := label.new(bar_index + extLen, pdl, "PDL  " + str.tostring(pdl, format.mintick), color=color.new(cRej, 25), textcolor=color.white, style=label.style_label_left, size=size.small)
    // Previous Week — dashed, slightly muted
    lPWH  := line.new(bar_index - extLen, pwh, bar_index + extLen, pwh, color=color.new(cRej, 35), width=1, style=line.style_dashed)
    lPWL  := line.new(bar_index - extLen, pwl, bar_index + extLen, pwl, color=color.new(cRej, 35), width=1, style=line.style_dashed)
    bPWH  := label.new(bar_index + extLen, pwh, "PWH  " + str.tostring(pwh, format.mintick), color=color.new(cRej, 45), textcolor=color.white, style=label.style_label_left, size=size.small)
    bPWL  := label.new(bar_index + extLen, pwl, "PWL  " + str.tostring(pwl, format.mintick), color=color.new(cRej, 45), textcolor=color.white, style=label.style_label_left, size=size.small)
    // Previous Month — dotted, most muted (macro level)
    if not na(pmh)
        lPMH  := line.new(bar_index - extLen, pmh, bar_index + extLen, pmh, color=color.new(cRej, 55), width=2, style=line.style_dotted)
        bPMH  := label.new(bar_index + extLen, pmh, "PMH  " + str.tostring(pmh, format.mintick), color=color.new(cRej, 60), textcolor=color.white, style=label.style_label_left, size=size.small)
    if not na(pml)
        lPML  := line.new(bar_index - extLen, pml, bar_index + extLen, pml, color=color.new(cRej, 55), width=2, style=line.style_dotted)
        bPML  := label.new(bar_index + extLen, pml, "PML  " + str.tostring(pml, format.mintick), color=color.new(cRej, 60), textcolor=color.white, style=label.style_label_left, size=size.small)
    // Prev Asia Session — dotted teal
    if not na(prevAsiaH)
        lAsiaH := line.new(bar_index - extLen, prevAsiaH, bar_index + extLen, prevAsiaH, color=color.new(#26c6da, 30), width=1, style=line.style_dotted)
        bAsiaH := label.new(bar_index + extLen, prevAsiaH, "Prev Asia H  " + str.tostring(prevAsiaH, format.mintick), color=color.new(#26c6da, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(prevAsiaL)
        lAsiaL := line.new(bar_index - extLen, prevAsiaL, bar_index + extLen, prevAsiaL, color=color.new(#26c6da, 30), width=1, style=line.style_dotted)
        bAsiaL := label.new(bar_index + extLen, prevAsiaL, "Prev Asia L  " + str.tostring(prevAsiaL, format.mintick), color=color.new(#26c6da, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    // Prev London Session — dotted gold
    if not na(prevLdnH)
        lLdnH  := line.new(bar_index - extLen, prevLdnH, bar_index + extLen, prevLdnH, color=color.new(#ffd600, 30), width=1, style=line.style_dotted)
        bLdnH  := label.new(bar_index + extLen, prevLdnH, "Prev Ldn H  " + str.tostring(prevLdnH, format.mintick), color=color.new(#ffd600, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(prevLdnL)
        lLdnL  := line.new(bar_index - extLen, prevLdnL, bar_index + extLen, prevLdnL, color=color.new(#ffd600, 30), width=1, style=line.style_dotted)
        bLdnL  := label.new(bar_index + extLen, prevLdnL, "Prev Ldn L  " + str.tostring(prevLdnL, format.mintick), color=color.new(#ffd600, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    // Prev New York Session — dotted purple
    if not na(prevNYH)
        lNYH   := line.new(bar_index - extLen, prevNYH, bar_index + extLen, prevNYH, color=color.new(#ab47bc, 30), width=1, style=line.style_dotted)
        bNYH   := label.new(bar_index + extLen, prevNYH, "Prev NY H  " + str.tostring(prevNYH, format.mintick), color=color.new(#ab47bc, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)
    if not na(prevNYL)
        lNYL   := line.new(bar_index - extLen, prevNYL, bar_index + extLen, prevNYL, color=color.new(#ab47bc, 30), width=1, style=line.style_dotted)
        bNYL   := label.new(bar_index + extLen, prevNYL, "Prev NY L  " + str.tostring(prevNYL, format.mintick), color=color.new(#ab47bc, 50), textcolor=color.white, style=label.style_label_left, size=size.tiny)

// ================================================================
// ORB BUILD (8:00-8:15 AM New York time)
// ================================================================

var bool prevInORB = false

hourNY   = hour(time, "America/New_York")
minuteNY = minute(time, "America/New_York")
isInORB  = hourNY == 8 and minuteNY >= 0 and minuteNY < 15
endORB   = not isInORB and prevInORB

var float orbH          = na
var float orbL          = na
var float orbMid        = na
var bool  orbReady      = false
var bool  orbDrawn      = false
var int   orbTradeToday = 0
var int   rejTradeToday = 0

if ta.change(dayofmonth) != 0
    orbH          := na
    orbL          := na
    orbMid        := na
    orbReady      := false
    orbDrawn      := false
    prevInORB     := false
    orbTradeToday := 0
    rejTradeToday := 0

if isInORB and not orbReady
    orbH := na(orbH) ? high : math.max(orbH, high)
    orbL := na(orbL) ? low  : math.min(orbL, low)

if endORB and not orbReady
    orbMid   := (orbH + orbL) / 2
    orbReady := true

prevInORB := isInORB

float orbRange = na(orbH) or na(orbL) ? na : orbH - orbL
float bZone    = na(orbRange) ? 0.0 : orbRange * midZonePct

if orbReady and not orbDrawn
    orbDrawn := true
    if showBox
        box.new(bar_index - 3, orbH, bar_index, orbL, bgcolor=color.new(cORB, 88), border_color=color.new(cORB, 45), border_width=1)
    line.new(bar_index, orbH,   bar_index + extLen, orbH,   color=cORB, width=1, style=line.style_dashed)
    line.new(bar_index, orbL,   bar_index + extLen, orbL,   color=cORB, width=1, style=line.style_dashed)
    line.new(bar_index, orbMid, bar_index + extLen, orbMid, color=color.new(cORB, 35), width=2, style=line.style_dotted)
    label.new(bar_index, orbH,   "ORB High " + str.tostring(orbH,   format.mintick), color=color.new(cORB, 55), textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index, orbMid, "Midpoint " + str.tostring(orbMid, format.mintick), color=color.new(cORB, 68), textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index, orbL,   "ORB Low  " + str.tostring(orbL,   format.mintick), color=color.new(cORB, 55), textcolor=color.white, style=label.style_label_left, size=size.small)

// ================================================================
// ORB SIGNALS
// ================================================================

// ── ORB SIGNAL FILTERS ───────────────────────────────────────────────────
// F1: Only after 9:30 AM — skip chaotic open scramble
afterOpen = (hourNY > 9 or (hourNY == 9 and minuteNY >= 30)) and hourNY < 12

// F2: Body must be >= 40% of candle range — kills doji and spinning tops
orbCandleRange    = high - low
orbBodySize       = math.abs(close - open)
orbBodyPct        = orbCandleRange > 0 ? orbBodySize / orbCandleRange : 0.0
orbBodyOK         = orbBodyPct >= 0.40

// F3: Prior candle must have genuinely touched the midpoint zone
prevTouchedMid    = not na(orbMid) and low[1] <= orbMid + bZone * 0.5 and high[1] >= orbMid - bZone * 0.5

// F4: Two consecutive closes on same side of mid — prevents single weak close
twoClosesLong     = close > orbMid and close[1] > orbMid
twoClosesShort    = close < orbMid and close[1] < orbMid

// F5: Close must be in top 60pct of candle for longs, bottom 60pct for shorts
closeInTopHalf    = orbCandleRange > 0 and (close - low)  / orbCandleRange >= 0.60
closeInBottomHalf = orbCandleRange > 0 and (high - close) / orbCandleRange >= 0.60

// F6: Minimum 2pt risk to SL — avoids nonsense tight-range setups
minTick4          = syminfo.mintick * 4
orbRiskLong       = not na(orbMid) and not na(orbL) and (orbMid - orbL) >= 2.0 * minTick4
orbRiskShort      = not na(orbMid) and not na(orbH) and (orbH - orbMid) >= 2.0 * minTick4

canOrbTrade = orbReady and not newsOff and not isInORB and orbTradeToday == 0 and afterOpen
orbLong     = canOrbTrade and prevTouchedMid and twoClosesLong  and close > open and close > ema200 and volOK and orbBodyOK and closeInTopHalf    and orbRiskLong
orbShort    = canOrbTrade and prevTouchedMid and twoClosesShort and close < open and close < ema200 and volOK and orbBodyOK and closeInBottomHalf and orbRiskShort

if orbLong
    orbTradeToday := 1
    en   = close
    sl   = orbL
    risk = en - sl
    tp1  = en + risk
    tp2  = en + risk * 2.0
    tp3  = en + risk * 3.0
    pad  = na(orbRange) ? syminfo.mintick * 3 : orbRange * 0.04
    label.new(bar_index, low - pad, "ORB LONG\n" + str.tostring(en, format.mintick), color=cLong, textcolor=color.white, style=label.style_label_up, size=size.normal)
    line.new(bar_index, sl, bar_index + extLen, sl, color=cSL, width=2, style=line.style_dashed)
    label.new(bar_index + extLen, sl, "SL " + str.tostring(sl, format.mintick), color=cSL, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP1
        line.new(bar_index, tp1, bar_index + extLen, tp1, color=cTP1c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp1, "TP1 " + str.tostring(tp1, format.mintick), color=cTP1c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP2
        line.new(bar_index, tp2, bar_index + extLen, tp2, color=cTP2c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp2, "TP2 " + str.tostring(tp2, format.mintick), color=cTP2c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP3
        line.new(bar_index, tp3, bar_index + extLen, tp3, color=cTP3c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp3, "TP3 " + str.tostring(tp3, format.mintick), color=cTP3c, textcolor=color.white, style=label.style_label_left, size=size.small)

if orbShort
    orbTradeToday := 1
    en   = close
    sl   = orbH
    risk = sl - en
    tp1  = en - risk
    tp2  = en - risk * 2.0
    tp3  = en - risk * 3.0
    pad  = na(orbRange) ? syminfo.mintick * 3 : orbRange * 0.04
    label.new(bar_index, high + pad, "ORB SHORT\n" + str.tostring(en, format.mintick), color=cShort, textcolor=color.white, style=label.style_label_down, size=size.normal)
    line.new(bar_index, sl, bar_index + extLen, sl, color=cSL, width=2, style=line.style_dashed)
    label.new(bar_index + extLen, sl, "SL " + str.tostring(sl, format.mintick), color=cSL, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP1
        line.new(bar_index, tp1, bar_index + extLen, tp1, color=cTP1c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp1, "TP1 " + str.tostring(tp1, format.mintick), color=cTP1c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP2
        line.new(bar_index, tp2, bar_index + extLen, tp2, color=cTP2c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp2, "TP2 " + str.tostring(tp2, format.mintick), color=cTP2c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP3
        line.new(bar_index, tp3, bar_index + extLen, tp3, color=cTP3c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp3, "TP3 " + str.tostring(tp3, format.mintick), color=cTP3c, textcolor=color.white, style=label.style_label_left, size=size.small)

// ================================================================
// REJECTION LOGIC
// ================================================================

prox  = atr14 * proxMult
slBuf = atr14 * atrMult

nearPDH   = high >= pdh - prox and high <= pdh + prox
nearPDL   = low  <= pdl + prox and low  >= pdl - prox
nearPWH   = high >= pwh - prox and high <= pwh + prox
nearPWL   = low  <= pwl + prox and low  >= pwl - prox
nearPMH   = not na(pmh) and high >= pmh - prox and high <= pmh + prox
nearPML   = not na(pml) and low  <= pml + prox and low  >= pml - prox
nearAsiaH = not na(prevAsiaH) and high >= prevAsiaH - prox and high <= prevAsiaH + prox
nearAsiaL = not na(prevAsiaL) and low  <= prevAsiaL + prox and low  >= prevAsiaL - prox
nearLdnH  = not na(prevLdnH)  and high >= prevLdnH  - prox and high <= prevLdnH  + prox
nearLdnL  = not na(prevLdnL)  and low  <= prevLdnL  + prox and low  >= prevLdnL  - prox
nearNYH   = not na(prevNYH)   and high >= prevNYH   - prox and high <= prevNYH   + prox
nearNYL   = not na(prevNYL)   and low  <= prevNYL   + prox and low  >= prevNYL   - prox

atRes = nearPDH or nearPWH or nearPMH or nearAsiaH or nearLdnH or nearNYH
atSup = nearPDL or nearPWL or nearPML or nearAsiaL or nearLdnL or nearNYL

upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low
bodySize    = math.abs(close - open)
candleRange = high - low
bodyQuality = candleRange > 0 ? bodySize / candleRange : 0.0

bearWick  = upperWick > bodySize and upperWick > lowerWick
bullWick  = lowerWick > bodySize and lowerWick > upperWick
bearClose = close < open
bullClose = close > open
bearTrend = close < ema200
bullTrend = close > ema200
rsiBearOK = rsi14 > 55
rsiBullOK = rsi14 < 45
goodBody  = bodyQuality >= 0.25

// Score 0-100
float scoreBear = 0.0
float scoreBull = 0.0

if atRes
    scoreBear := scoreBear + 20.0
if bearWick and bearClose
    scoreBear := scoreBear + 20.0
if bearTrend
    scoreBear := scoreBear + 20.0
if volOK
    scoreBear := scoreBear + 15.0
if rsiBearOK
    scoreBear := scoreBear + 10.0
if goodBody
    scoreBear := scoreBear + 10.0
if nearPWH or nearPMH
    scoreBear := scoreBear + 5.0

if atSup
    scoreBull := scoreBull + 20.0
if bullWick and bullClose
    scoreBull := scoreBull + 20.0
if bullTrend
    scoreBull := scoreBull + 20.0
if volOK
    scoreBull := scoreBull + 15.0
if rsiBullOK
    scoreBull := scoreBull + 10.0
if goodBody
    scoreBull := scoreBull + 10.0
if nearPWL or nearPML
    scoreBull := scoreBull + 5.0

// ── REJECTION EXTRA FILTERS ──────────────────────────────────────────────
// RF1: Level must have been tested on the prior candle too — confirms the
//      level is actually in play, not just a first touch spike through
priorTouchedRes   = high[1] >= pwh - prox or high[1] >= pdh - prox or (not na(pmh) and high[1] >= pmh - prox) or (not na(prevAsiaH) and high[1] >= prevAsiaH - prox) or (not na(prevLdnH) and high[1] >= prevLdnH - prox) or (not na(prevNYH) and high[1] >= prevNYH - prox)
priorTouchedSup   = low[1]  <= pwl + prox or low[1]  <= pdl + prox or (not na(pml) and low[1]  <= pml + prox) or (not na(prevAsiaL) and low[1]  <= prevAsiaL + prox) or (not na(prevLdnL) and low[1]  <= prevLdnL + prox) or (not na(prevNYL) and low[1]  <= prevNYL + prox)

// RF2: RSI must be turning — for shorts RSI falling (rsi < rsi[1]),
//      for longs RSI rising — confirms momentum shifting at the level
rsiTurningBear    = rsi14 < rsi14[1]
rsiTurningBull    = rsi14 > rsi14[1]

// RF3: Candle wick must dominate total range — wick > 35pct of full range
rejCandleRange    = high - low
wickDomBear       = rejCandleRange > 0 and upperWick / rejCandleRange >= 0.35
wickDomBull       = rejCandleRange > 0 and lowerWick / rejCandleRange >= 0.35

// RF4: Price must close back inside the prior candle range after the wick
//      This confirms the level held — rejection candle closes inside prev range
closedInsidePrev  = close <= high[1] and close >= low[1]

canRej   = useRej and not newsOff and rejTradeToday < maxRejPerDay
rejLong  = canRej and atSup and bullWick and bullClose and bullTrend and scoreBull >= minRejScore and priorTouchedSup and rsiTurningBull and wickDomBull and closedInsidePrev
rejShort = canRej and atRes and bearWick and bearClose and bearTrend and scoreBear >= minRejScore and priorTouchedRes and rsiTurningBear and wickDomBear and closedInsidePrev

if rejLong
    rejTradeToday := rejTradeToday + 1
    en     = close
    sl     = low - slBuf
    risk   = en - sl
    tp1    = en + risk
    tp2    = en + risk * 2.0
    tp3    = en + risk * 3.0
    lvlStr = nearPML ? "PML" : nearPWL ? "PWL" : nearAsiaL ? "Prev Asia L" : nearLdnL ? "Prev Ldn L" : nearNYL ? "Prev NY L" : "PDL"
    scStr  = str.tostring(int(scoreBull))
    label.new(bar_index, low - atr14 * 0.3, "REJ LONG " + scStr + "%\n" + lvlStr + " @ " + str.tostring(en, format.mintick), color=cLong, textcolor=color.white, style=label.style_label_up, size=size.normal)
    line.new(bar_index, sl, bar_index + extLen, sl, color=cSL, width=2, style=line.style_dashed)
    label.new(bar_index + extLen, sl, "SL " + str.tostring(sl, format.mintick), color=cSL, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP1
        line.new(bar_index, tp1, bar_index + extLen, tp1, color=cTP1c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp1, "TP1 " + str.tostring(tp1, format.mintick), color=cTP1c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP2
        line.new(bar_index, tp2, bar_index + extLen, tp2, color=cTP2c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp2, "TP2 " + str.tostring(tp2, format.mintick), color=cTP2c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP3
        line.new(bar_index, tp3, bar_index + extLen, tp3, color=cTP3c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp3, "TP3 " + str.tostring(tp3, format.mintick), color=cTP3c, textcolor=color.white, style=label.style_label_left, size=size.small)

if rejShort
    rejTradeToday := rejTradeToday + 1
    en     = close
    sl     = high + slBuf
    risk   = sl - en
    tp1    = en - risk
    tp2    = en - risk * 2.0
    tp3    = en - risk * 3.0
    lvlStr = nearPMH ? "PMH" : nearPWH ? "PWH" : nearAsiaH ? "Prev Asia H" : nearLdnH ? "Prev Ldn H" : nearNYH ? "Prev NY H" : "PDH"
    scStr  = str.tostring(int(scoreBear))
    label.new(bar_index, high + atr14 * 0.3, "REJ SHORT " + scStr + "%\n" + lvlStr + " @ " + str.tostring(en, format.mintick), color=cShort, textcolor=color.white, style=label.style_label_down, size=size.normal)
    line.new(bar_index, sl, bar_index + extLen, sl, color=cSL, width=2, style=line.style_dashed)
    label.new(bar_index + extLen, sl, "SL " + str.tostring(sl, format.mintick), color=cSL, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP1
        line.new(bar_index, tp1, bar_index + extLen, tp1, color=cTP1c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp1, "TP1 " + str.tostring(tp1, format.mintick), color=cTP1c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP2
        line.new(bar_index, tp2, bar_index + extLen, tp2, color=cTP2c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp2, "TP2 " + str.tostring(tp2, format.mintick), color=cTP2c, textcolor=color.white, style=label.style_label_left, size=size.small)
    if showTP3
        line.new(bar_index, tp3, bar_index + extLen, tp3, color=cTP3c, width=1, style=line.style_dashed)
        label.new(bar_index + extLen, tp3, "TP3 " + str.tostring(tp3, format.mintick), color=cTP3c, textcolor=color.white, style=label.style_label_left, size=size.small)

// ================================================================
// ALERTS (constant strings only - no series)
// ================================================================

alertcondition(orbLong,   "ORB Long",        "ORB LONG signal fired")
alertcondition(orbShort,  "ORB Short",       "ORB SHORT signal fired")
alertcondition(rejLong,   "Rejection Long",  "REJECTION LONG signal fired")
alertcondition(rejShort,  "Rejection Short", "REJECTION SHORT signal fired")

// ================================================================
// HELPER FUNCTIONS
// ================================================================

f_chk(b) => b ? "PASS" : "FAIL"
f_col(b) => b ? color.new(#00c853, 0) : color.new(#ef5350, 0)

f_scorebar(float sc) =>
    filled = int(math.min(math.round(sc / 10.0), 10))
    empty  = 10 - filled
    result = ""
    if filled >= 1
        for _f = 1 to filled
            result := result + "|"
    if empty >= 1
        for _e = 1 to empty
            result := result + "."
    result

// ================================================================
// PANEL (switches between ORB and Rejection via Settings)
// ================================================================

var table T = table.new(position.top_right, 3, 12, bgcolor=color.new(#0f172a, 60), border_width=1, border_color=color.new(#334155, 55), frame_width=1, frame_color=#334155)

if showPanel and barstate.islast
    cBg    = color.new(#1e293b, 50)
    cBgAlt = color.new(#1e293b, 65)
    cHead  = color.new(#1e3a5f, 15)
    cMuted = color.new(color.white, 45)

    if panelMode == "ORB"
        hasSig  = orbLong or orbShort
        dirOK   = (orbLong and close > orbMid) or (orbShort and close < orbMid)
        allGood = orbReady and not newsOff and prevTouchedMid and hasSig and dirOK
        noNews  = not newsOff
        sigText = orbLong ? "LONG" : orbShort ? "SHORT" : "NO TRADE"
        sigBg   = orbLong ? color.new(#00c853, 55) : orbShort ? color.new(#d50000, 55) : color.new(#1e293b, 55)
        sigCol  = orbLong ? color.new(#00c853, 0)  : orbShort ? color.new(#ef5350, 0)  : color.new(#9e9e9e, 0)
        trendOK = not hasSig or (orbLong and close > ema200) or (orbShort and close < ema200)

        table.cell(T, 0, 0, "8AM ORB - ENTRY CHECKLIST", text_color=color.white, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)
        table.merge_cells(T, 0, 0, 2, 0)
        table.cell(T, 0, 1, "SIGNAL", text_color=color.white, text_size=size.small, bgcolor=sigBg)
        table.cell(T, 1, 1, sigText, text_color=sigCol, text_size=size.small, bgcolor=sigBg, text_halign=text.align_center)
        table.cell(T, 2, 1, "", bgcolor=sigBg)
        table.cell(T, 0, 2, "ORB Built", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 2, f_chk(orbReady), text_color=f_col(orbReady), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 2, orbReady ? str.tostring(orbH, format.mintick) + " / " + str.tostring(orbL, format.mintick) : "Waiting 8:00-8:15", text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 3, "No News Event", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 3, f_chk(noNews), text_color=f_col(noNews), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 3, noNews ? "Clear" : "FILTER ON", text_color=noNews ? color.new(#00c853, 0) : color.new(#ffd600, 0), text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 4, "Bounce at Mid", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 4, f_chk(prevTouchedMid), text_color=f_col(prevTouchedMid), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 4, orbReady ? "Mid: " + str.tostring(orbMid, format.mintick) : "--", text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 5, "Reversal Candle", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 5, f_chk(hasSig), text_color=f_col(hasSig), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 5, hasSig ? (orbLong ? "Bullish close" : "Bearish close") : "Watching...", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 6, "200 EMA Trend", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 6, f_chk(trendOK), text_color=f_col(trendOK), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 6, close > ema200 ? "Above EMA" : "Below EMA", text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 7, "Volume +20% Avg", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 7, f_chk(volOK), text_color=f_col(volOK), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 7, volOK ? "Confirmed" : "Weak", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 8, "1 Trade/Day Gate", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 8, f_chk(orbTradeToday == 0), text_color=f_col(orbTradeToday == 0), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 8, orbTradeToday == 0 ? "Open" : "TAKEN", text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 9, "H | Mid | L", text_color=color.new(cORB, 0), text_size=size.tiny, bgcolor=color.new(#0f172a, 50))
        table.cell(T, 1, 9, orbReady ? str.tostring(orbH, format.mintick) + " | " + str.tostring(orbMid, format.mintick) + " | " + str.tostring(orbL, format.mintick) : "Building...", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#0f172a, 50), text_halign=text.align_center)
        table.cell(T, 2, 9, "", bgcolor=color.new(#0f172a, 50))
        table.cell(T, 0, 10, "1min & 3min Agree", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 10, "CHECK", text_color=color.new(#ffd600, 0), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 10, "Manual confirm", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 11, newsOff ? "News filter ON" : allGood ? "ALL CLEAR - confirm 1min/3min" : "Waiting for setup...", text_color=newsOff ? color.new(#ffd600, 0) : allGood ? color.new(#00c853, 0) : color.new(#9e9e9e, 0), text_size=size.tiny, bgcolor=color.new(#0f172a, 50), text_halign=text.align_center)
        table.merge_cells(T, 0, 11, 2, 11)

    else
        activeScore = atRes ? scoreBear : atSup ? scoreBull : 0.0
        hasRejSig   = rejLong or rejShort
        rejDir      = rejLong ? "LONG" : rejShort ? "SHORT" : "WATCHING"
        rejSigBg    = rejLong ? color.new(#00c853, 55) : rejShort ? color.new(#d50000, 55) : color.new(#1e293b, 55)
        rejSigCol   = rejLong ? color.new(#00c853, 0) : rejShort ? color.new(#ef5350, 0) : color.new(#9e9e9e, 0)
        scoreColor  = activeScore >= 75 ? color.new(#00c853, 0) : activeScore >= 50 ? color.new(#ffd600, 0) : color.new(#ef5350, 0)
        lvlHit      = atRes or atSup
        lvlName     = nearPMH ? "PMH" : nearPWH ? "PWH" : nearPDH ? "PDH" : nearPML ? "PML" : nearPWL ? "PWL" : nearPDL ? "PDL" : nearAsiaH ? "Prev Asia H" : nearAsiaL ? "Prev Asia L" : nearLdnH ? "Prev Ldn H" : nearLdnL ? "Prev Ldn L" : nearNYH ? "Prev NY H" : nearNYL ? "Prev NY L" : "--"
        wickOK      = (atRes and bearWick) or (atSup and bullWick)
        closeOK     = (atRes and bearClose) or (atSup and bullClose)
        trendAlign  = (atRes and bearTrend) or (atSup and bullTrend)
        rsiOK       = (atRes and rsiBearOK) or (atSup and rsiBullOK)
        rejLeft     = maxRejPerDay - rejTradeToday

        table.cell(T, 0, 0, "REJECTION - CHECKLIST", text_color=color.white, text_size=size.small, bgcolor=cHead, text_halign=text.align_center)
        table.merge_cells(T, 0, 0, 2, 0)
        table.cell(T, 0, 1, "SIGNAL", text_color=color.white, text_size=size.small, bgcolor=rejSigBg)
        table.cell(T, 1, 1, rejDir, text_color=rejSigCol, text_size=size.small, bgcolor=rejSigBg, text_halign=text.align_center)
        table.cell(T, 2, 1, "", bgcolor=rejSigBg)
        table.cell(T, 0, 2, "CONFIDENCE", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 2, f_scorebar(activeScore), text_color=scoreColor, text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 2, str.tostring(int(activeScore)) + "%", text_color=scoreColor, text_size=size.small, bgcolor=cBg)
        table.cell(T, 0, 3, "At Key Level", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 3, f_chk(lvlHit), text_color=f_col(lvlHit), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 3, lvlName, text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 4, "Wick > Body", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 4, f_chk(wickOK), text_color=f_col(wickOK), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 4, wickOK ? "Strong wick" : "Weak/none", text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 5, "Closes Away from Level", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 5, f_chk(closeOK), text_color=f_col(closeOK), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 5, closeOK ? "Confirmed" : "Waiting", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 6, "200 EMA Aligned", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 6, f_chk(trendAlign), text_color=f_col(trendAlign), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 6, trendAlign ? "Trend OK" : "Against trend", text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 7, "Volume +20% Avg", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 7, f_chk(volOK), text_color=f_col(volOK), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 7, volOK ? "Confirmed" : "Weak", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 8, "RSI Confirmation", text_color=color.white, text_size=size.small, bgcolor=cBg)
        table.cell(T, 1, 8, f_chk(rsiOK), text_color=f_col(rsiOK), text_size=size.small, bgcolor=cBg, text_halign=text.align_center)
        table.cell(T, 2, 8, "RSI " + str.tostring(math.round(rsi14, 1)), text_color=cMuted, text_size=size.tiny, bgcolor=cBg)
        table.cell(T, 0, 9, "Rejection Slots Left", text_color=color.white, text_size=size.small, bgcolor=cBgAlt)
        table.cell(T, 1, 9, str.tostring(rejLeft), text_color=rejLeft > 0 ? color.new(#00c853, 0) : color.new(#ef5350, 0), text_size=size.small, bgcolor=cBgAlt, text_halign=text.align_center)
        table.cell(T, 2, 9, rejLeft > 0 ? "Slot open" : "Max reached", text_color=cMuted, text_size=size.tiny, bgcolor=cBgAlt)
        table.cell(T, 0, 10, "Key Levels", text_color=color.new(cRej, 0), text_size=size.tiny, bgcolor=color.new(#0f172a, 50))
        table.cell(T, 1, 10, "PDH " + str.tostring(pdh, format.mintick) + "  PDL " + str.tostring(pdl, format.mintick) + "  PMH " + str.tostring(pmh, format.mintick) + "  PML " + str.tostring(pml, format.mintick), text_color=color.white, text_size=size.tiny, bgcolor=color.new(#0f172a, 50), text_halign=text.align_center)
        table.cell(T, 2, 10, "", bgcolor=color.new(#0f172a, 50))
        table.cell(T, 0, 11, not useRej ? "Rejections disabled" : hasRejSig ? "SIGNAL FIRED - check chart" : lvlHit ? "Near level - building score..." : "No key level in proximity", text_color=not useRej ? color.new(#9e9e9e, 0) : hasRejSig ? color.new(#00c853, 0) : lvlHit ? color.new(#ffd600, 0) : color.new(#9e9e9e, 0), text_size=size.tiny, bgcolor=color.new(#0f172a, 50), text_halign=text.align_center)
        table.merge_cells(T, 0, 11, 2, 11)
````
