# Cnagda Liquidit Trading System

- url: https://www.tradingview.com/script/B3qcNZwn-Cnagda-Liquidit-Trading-System/
- type: indicator
- pine_id: PUB;584311a4bf494514ba887d7149358409
- version: 9.0

## Description

Cnagda Liquidit Trading System helps spot where price is likely to trap traders and reverse, then gives simple, actionable Level to entry, place SL, and take profits with confidence. It blends imbalance zones, trend bias, order blocks, liquidity pools, high-probability fake Signal, and context-aware candle patterns into one clean workflow.

🟩🟥 Imbalance boxes: “Crowd rushed, gaps left”
What it is: Green/red boxes mark fast, one-sided moves where price “skipped” orders—think FVG-like zones that often get revisited.

Why it helps: Price frequently pulls back to “fill” these zones, creating clean retest entries with logical stops.

⏩How to use:
Green box = potential demand retest; Red box = potential supply retest. Enter on pullback into box, not on first impulse. Put stop on far side of box and aim first targets at recent swing points.

↕️ Swing bias (HH/HL vs LH/LL): “Which way is the road?”
What it is: Higher-highs/higher-lows = up-bias; Lower-highs/lower-lows = down-bias. system plots Buy/Sell OB levels aligned with that bias.

Why it helps: Trading with the broader flow reduces “hero trades” against institutions. Bias gives clearer entries and cleaner drawdowns.

⏩How to use:
Up-bias: look for long on Buy OB retests. Down-bias: look for short on Sell OB retests. Wait for a small rejection/engulfing to confirm before triggering.

🧱Order blocks: “Where big players remember”
What it is: last opposite-colored candle before an impulsive move—these zones often hold memory and reaction. system plots these as Buy/Sell OB lines.

Why it helps: Many breakouts pull back to the origin. Good entries often happen on retest, not on the breakout chase.

⏩ How to use:
Let price return into the OB, show wick rejection, and decent volume. Enter with stop beyond OB; define risk-reward before entry.

📊Volume coloring: “How Volume is move?”
What it is: Bar color reflects relative volume; inside bars are black. The dashboard also shows Volume and “Volume vs Prev.”

Why it helps: Patterns without volume often fade; volume validates strength and intent of moves.

⏩ How to use:
Favor entries where imbalance/OB/liquidity-grab coincide with higher volume. If volume is weak, reduce size or skip.

🧲 BSL/SSL liquidity pools: “Fishing for stops”
What it is: Equal highs cluster stops above (BSL); equal lows cluster stops below (SSL). system plots these and highlights the nearest one (“magnet”).

Why it helps: Price often sweeps these pools to trigger stops before reversing. This is a prime trap-reversal location.

⏩ How to use:
Watch nearest BSL/SSL. If price wicks through and closes back inside, anticipate a reversal. Trade reaction, not first poke. When price closes beyond, consider that pool mitigated and move on.

🟢🔴 Advanced liquidity grab: “Catch fakeout”
What it is: Bullish grab = makes a new low beyond a prior low but closes back above it, with a long lower wick, small body, and higher volume. Bearish is mirror. Labeled automatically.

Why it helps: It exposes trap moves (stop hunts) and often precedes true direction.

⏩ How to use:
Best when it aligns with a nearby imbalance/OB and supportive volume. Enter on reversal candle break or on retest. Stop goes beyond sweep wick.

🧠 Smart candlestick patterns (only in right place)
What it is: Engulfing, Hammer, Shooting Star, Hanging Man, Doji (with high volume), Morning/Evening Star, Piercing—but marked “effective” only if context (swing/trend/location) agrees.

Why it helps: same pattern in the wrong place is noise; in the right place, it’s signal.

⏩ How to use:
Location first (BSL/SSL/OB/imbalance), then pattern. Treat pattern as trigger/confirmation—one fresh label shows to keep chart clean.

🧭 Dashboard: “Context in a glance”
⏩ Reversal Level: current swing anchor—expect turns or reactions nearby; great for alerts and planning.
⏩ Volume vs Prev + Volume: Strength meter for signal candle—higher adds conviction.
⏩ Nearest Pool: next “magnet” area—look for sweeps/rejections there.

🧩Step-by-step trading flow (with mindset)
⏩ Set bias: HH/HL = long bias, LH/LL = short bias. Counter-trend only on clean sweeps with strong confirmation.
⏩ Find magnet: Check Nearest Pool (BSL/SSL). Focus attention there; it saves screen time.
⏩ Wait for event: Look for a sweep/grab label, or sharp rejection at pool/OB/imbalance. Avoid FOMO.
⏩ Add confluence: Stack 2–3 of these—imbalance box, OB, contextual pattern, supportive volume.
⏩Plan entry: Bullish: trigger above reversal candle high or take retest of FVG/OB. Stop below sweep wick/zone. Target at least 1:1.5–1:2.
Bearish: mirror above.
⏩Manage smartly: Take partials, move to breakeven or trail thoughtfully. Don’t drag stops inside zone out of emotion.

🎛️ Parameter tuning (to reduce human error)
⏩ swingLen: Smaller = faster but noisier; larger = cleaner but slower. Backtest first, then go live.
⏩ Tolerance (ATR or percent): ATR tolerance adapts to volatility (good for fast markets and lower TFs). Start around 0.15–0.30. In calm markets, try percent 0.05–0.15%.
⏩ minBarsGap: Start with 3–5 so equal highs/lows are truly equal—reduces false pools.

❌Common mistakes → ✅ Better habits
⏩Chasing every breakout → Wait for sweep/rejection, then confirm.
⏩Ignoring volume → Validate strength; cut size or skip on weak volume.
⏩Losing history of pools → If reviewing/backtesting, keep mitigated pools visible (dashed/faded).
⏩Over-tight tolerance/too small swingLen → Increases false signals; backtest to find balance.

📝 checklist (before entry)
⏩ Is there a nearby BSL/SSL and did a sweep/grab happen there?
⏩ Is there a close imbalance/OB that price can retest?
⏩ Do we have an effective pattern plus supportive volume?
⏩Is the stop beyond the wick/zone and RR ≥ 1:1.5?

•?((¯°·._.•   🎀  𝐻𝒶𝓅𝓅𝓎 𝒯𝓇𝒶𝒹𝒾𝓃𝑔  🎀   •._.·°¯((?•

## Source Code

````pine
//@version=6
indicator('Cnagda Liquidity Trading System', overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

swingLen         = input.int(7, 'Swing Strength', minval=1)
volLength        = input.int(50, 'Volume Avg Period', minval=1)
showSwingLabels  = input.bool(false, 'Show HH/HL/LH/LL Labels?')
showDashboard    = input.bool(true, 'Show Dashboard?')
showPools        = input.bool(true, 'Show Liquidity Pools (EQH/EQL)?')
useAtrTol        = input.bool(true, 'Use ATR-based tolerance?')
atrLenTol        = input.int(14, 'ATR Length', minval=1)
atrMultTol       = input.float(0.40, 'ATR Multiplier', step=0.01)
pctTol           = input.float(0.70, 'Pct Tol (% of price)', step=0.01)
minBarsGap       = input.int(3, 'Min bars gap between pivots', minval=1)
lookbackPivots   = input.int(300, 'Max pools to remember', minval=2)
persistMitigated = input.bool(true, 'Keep mitigated pools dashed/faded?')
showNearestPools = input.bool(true, 'Show nearest BSL/SSL label?')
showDynTL        = input.bool(true, 'Dynamic Trendline (on liquidity grab)?')
extendRightTL    = input.bool(true, 'Extend Dynamic Trendline Right?')
mtf_tf           = input.timeframe('D', 'Higher TF (MTF confluence)')
vwapType         = input.string('session', 'VWAP Type', options=['session','cumulative'])
twapLen          = input.int(55, 'TWAP Period')
povPct           = input.float(0.07, 'POV thresh, % of session vol')
confirmOnClose   = input.bool(true, 'Confirm on bar close?')
showExitOnBiasFlip = input.bool(true, 'Show EXIT label on bias flip?')
var float adline = na
ad_mfm = (high != low) ? ((close - low) - (high - close)) / (high - low) : 0
ad_mfv = ad_mfm * volume
adline := na(adline[1]) ? ad_mfv : adline[1] + ad_mfv
adline_up   = not na(adline[1]) and adline > adline[1]
adline_down = not na(adline[1]) and adline < adline[1]
minOff = syminfo.mintick * 5
denomVol    = ta.cum(volume)
cumCloseVol = ta.cum(close * volume)
atr3      = ta.atr(3)
atr10     = ta.atr(10)
atrValTol = ta.atr(atrLenTol)
vwapVal = vwapType == 'session' ? ta.vwap(close) : (denomVol > 0 ? cumCloseVol / denomVol : na)
twapVal = ta.sma(close, twapLen)
htf_vwap = request.security(syminfo.tickerid, mtf_tf, ta.vwap(close), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
var float sessVol = na
bool newDay = ta.change(time('D')) != 0
sessVol := newDay ? volume : nz(sessVol) + volume
vol_ok  = volume > sessVol * povPct
plot(vwapVal, color=color.teal, linewidth=2, title='VWAP')
plot(twapVal, color=color.orange, linewidth=1, title='TWAP')
plot(htf_vwap, color=color.gray, linewidth=1, style=plot.style_stepline, title='HTF VWAP')
volRank = 1
for k = 1 to math.max(volLength - 1, 1)
    volRank += volume > volume[k] ? 1 : 0
color barCol = na
if volRank == 1
    barCol := color.orange
else if volRank <= 2
    barCol := color.yellow
else if volRank == volLength
    barCol := color.new(color.blue, 0)
else if volRank == volLength - 1
    barCol := color.new(color.blue, 25)
else if volRank == volLength - 2
    barCol := color.new(color.blue, 50)
else if volRank >= volLength - 4
    barCol := color.new(color.blue, 75)
else
    float p = math.round(100 * (volRank / math.max(volLength - 4, 1)))
    p := math.min(math.max(p, 0), 100)
    barCol := color.new(color.blue, p)
insideBar = high < high[1] and low > low[1]
if insideBar
    barCol := color.black
barcolor(barCol)
var box[] imbalanceBoxes = array.new_box()
for i = 1 to 20
    body        = math.abs(close[i] - open[i])
    candleRange = high[i] - low[i]
    wickTop     = high[i] - math.max(close[i], open[i])
    wickBottom  = math.min(close[i], open[i]) - low[i]
    bodyPerc    = candleRange > 0 ? (body / candleRange) * 100 : 0
    wickPerc    = candleRange > 0 ? wickTop / candleRange * 100 : 0
    bullishImb  = close[i] > open[i] and bodyPerc > 40.0 and wickPerc > 60.0
    wickPercDn  = candleRange > 0 ? wickBottom / candleRange * 100 : 0
    bearishImb  = close[i] < open[i] and bodyPerc > 40.0 and wickPercDn > 60.0
    bool boxExists = false
    nImb = array.size(imbalanceBoxes)
    if nImb > 0
        for j = 0 to nImb - 1
            bb = array.get(imbalanceBoxes, j)
            if not na(bb) and box.get_left(bb) == bar_index - i
                boxExists := true
    if bullishImb and not boxExists
        nb = box.new(bar_index - i, low[i], bar_index - (i - 1), high[i], border_color=color.green, bgcolor=color.new(color.green, 82))
        array.unshift(imbalanceBoxes, nb)
    if bearishImb and not boxExists
        nb = box.new(bar_index - i, low[i], bar_index - (i - 1), high[i], border_color=color.red, bgcolor=color.new(color.red, 82))
        array.unshift(imbalanceBoxes, nb)
if array.size(imbalanceBoxes) > 0
    int jj = array.size(imbalanceBoxes) - 1
    while jj >= 0
        b1 = array.get(imbalanceBoxes, jj)
        if not na(b1) and box.get_right(b1) < bar_index - 20
            box.delete(b1)
            array.remove(imbalanceBoxes, jj)
        jj -= 1
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
hhColor = color.new(color.blue, 0)
hlColor = color.new(color.green, 0)
llColor = color.new(color.red, 0)
lhColor = color.new(color.purple, 0)
var float prevHigh = na
var float prevLow  = na
var int   swingDir = 0
var string lastConfirmedSwing = ''
var float reversalPrice = na
var float buyOB = na
var float sellOB = na
if not na(pl)
    if not na(prevLow)
        if pl > prevLow
            swingDir := 1
            lastConfirmedSwing := 'HL'
            reversalPrice := low[swingLen]
            buyOB := low[swingLen]
            if bar_index >= swingLen and showSwingLabels
                label.new(bar_index, low, 'HL', color=hlColor, textcolor=color.white, style=label.style_label_up)
        else
            if showSwingLabels
                label.new(bar_index, low, 'LL', color=llColor, textcolor=color.white, style=label.style_label_up)
            swingDir := -1
            lastConfirmedSwing := 'LL'
            reversalPrice := low[swingLen]
            buyOB := low[swingLen]
    prevLow := pl
if not na(ph)
    if not na(prevHigh)
        if ph > prevHigh
            swingDir := 1
            lastConfirmedSwing := 'HH'
            reversalPrice := high[swingLen]
            sellOB := high[swingLen]
            if bar_index >= swingLen and showSwingLabels
                label.new(bar_index, high, 'HH', color=hhColor, textcolor=color.white, style=label.style_label_down)
        else
            if showSwingLabels
                label.new(bar_index, high, 'LH', color=lhColor, textcolor=color.white, style=label.style_label_down)
            swingDir := -1
            lastConfirmedSwing := 'LH'
            reversalPrice := high[swingLen]
            sellOB := high[swingLen]
    prevHigh := ph
plot((swingDir == 1 and not na(buyOB)) ? buyOB : na, title='Buy OB', color=color.green, linewidth=2, style=plot.style_linebr)
plot((swingDir == -1 and not na(sellOB)) ? sellOB : na, title='Sell OB', color=color.red, linewidth=2, style=plot.style_linebr)
liqGrabBull   = not na(prevLow) and low < prevLow and close > prevLow
liqGrabBear   = not na(prevHigh) and high > prevHigh and close < prevHigh
wickLargeBull = not na(prevLow)  and (prevLow - low)      > 1.1 * math.abs(open - close)
wickLargeBear = not na(prevHigh) and (high    - prevHigh) > 1.1 * math.abs(open - close)
bodySmallBull = math.abs(open - close) < (high - low) * 0.5
bodySmallBear = math.abs(open - close) < (high - low) * 0.5
volSpike      = volume > ta.sma(volume, 20) * 1.4
advancedLiqGrabBull = liqGrabBull and wickLargeBull and bodySmallBull and volSpike
advancedLiqGrabBear = liqGrabBear and wickLargeBear and bodySmallBear and volSpike
var label lastAdvLiqBull = na
var label lastAdvLiqBear = na
if advancedLiqGrabBull
    if not na(lastAdvLiqBull)
        label.delete(lastAdvLiqBull)
    lastAdvLiqBull := label.new(bar_index, low - atr3 * 0.10, "BULLISH LIQUIDITY\nGRAB", color=color.lime, textcolor=color.black, style=label.style_label_up, size=size.normal)
if advancedLiqGrabBear
    if not na(lastAdvLiqBear)
        label.delete(lastAdvLiqBear)
    lastAdvLiqBear := label.new(bar_index, high + atr3 * 0.10, "BEARISH LIQUIDITY\nGRAB", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)
isSwingLow  = not na(ta.pivotlow(low, swingLen, swingLen))
isSwingHigh = not na(ta.pivothigh(high, swingLen, swingLen))
trendLB         = input.int(13, 'Trend lookback', minval=2)
hasHistShort    = bar_index >= trendLB
downTrendBefore = hasHistShort and close[1] < close
upTrendBefore   = hasHistShort and close[1] > close
bullEngulf            = close > open and close[1] < open[1] and close > open[1] and open < close[1]
effectiveBullEngulf   = bullEngulf and (isSwingLow or downTrendBefore)
bearEngulf            = close < open and close[1] > open[1] and close < open[1] and open > close[1]
effectiveBearEngulf   = bearEngulf and (isSwingHigh or upTrendBefore)
bigDownMove           = (high[1] - low[1]) > atr10
hammer                = (high - low) > 3 * math.abs(open - close) and ((close - low) / (0.001 + high - low)) > 0.6 and ((open - low) / (0.001 + high - low)) > 0.6
effectiveHammer       = hammer and bigDownMove
shootingStar          = (high - low) > 3 * math.abs(open - close) and ((high - close) / (0.001 + high - low)) > 0.6 and ((high - open) / (0.001 + high - low)) > 0.6
effectiveShootingStar = shootingStar and (isSwingHigh or upTrendBefore)
hangingMan            = (high - low) > 3 * math.abs(open - close) and ((close - low) / (0.001 + high - low)) > 0.6 and ((open - low) / (0.001 + high - low)) > 0.6
effectiveHangingMan   = hangingMan and (isSwingHigh or upTrendBefore)
doji                  = math.abs(close - open) <= (high - low) * 0.1
highVol               = volume > ta.sma(volume, 20) * 1.5
effectiveDoji         = doji and highVol
hasHistStar = bar_index >= 12
smallBody(cOpen, cClose, cHigh, cLow) =>
    rng = cHigh - cLow
    rng > 0 ? math.abs(cClose - cOpen) <= rng * 0.3 : false
morningStar = close < open and smallBody(open[1], close[1], high[1], low[1]) and low[1] <= low and close > open and close >= (open + close) / 2 and low > low[1]
effectiveMorningStar = hasHistStar and morningStar and (isSwingLow or downTrendBefore)
eveningStar = close > open and smallBody(open[1], close[1], high[1], low[1]) and high[1] >= high and close < open and close <= (open + close) / 2 and high < high[1]
effectiveEveningStar = hasHistStar and eveningStar and (isSwingHigh or upTrendBefore)
piercing          = close < open and close[1] > open[1] and open < close and close > open[1] and close < open
effectivePiercing = piercing and downTrendBefore
var label lastCandleLabel = na
string patternName  = na
float  patternY     = na
color  patternCol   = na
color  patternTxtCol= color.white
var patternStyle    = label.style_label_up
patternOffset       = math.max(atr3 * 0.10, minOff)
if effectiveBullEngulf
    patternName := 'Bull Engulf'
    patternY := low - patternOffset
    patternCol := color.green
    patternStyle := label.style_label_up
if effectiveBearEngulf
    patternName := 'Bear Engulf'
    patternY := high + patternOffset
    patternCol := color.red
    patternStyle := label.style_label_down
if effectiveHammer
    patternName := 'Hammer'
    patternY := low - patternOffset
    patternCol := color.yellow
    patternTxtCol := color.black
    patternStyle := label.style_label_up
if effectiveShootingStar
    patternName := 'Shooting Star'
    patternY := high + patternOffset
    patternCol := color.purple
    patternStyle := label.style_label_down
if effectiveHangingMan
    patternName := 'Hanging Man'
    patternY := low - patternOffset
    patternCol := color.new(color.orange, 0)
    patternTxtCol := color.black
    patternStyle := label.style_label_up
if effectiveDoji
    patternName := 'Doji'
    patternY := high + patternOffset
    patternCol := color.blue
    patternStyle := label.style_label_down
if effectiveMorningStar
    patternName := 'Morning Star'
    patternY := low - patternOffset
    patternCol := color.lime
    patternStyle := label.style_label_up
if effectiveEveningStar
    patternName := 'Evening Star'
    patternY := high + patternOffset
    patternCol := color.maroon
    patternStyle := label.style_label_down
if effectivePiercing
    patternName := 'Piercing'
    patternY := low - patternOffset
    patternCol := color.teal
    patternStyle := label.style_label_up
if not na(patternName)
    if not na(lastCandleLabel)
        label.delete(lastCandleLabel)
    lastCandleLabel := label.new(bar_index, patternY, patternName, color=patternCol, textcolor=patternTxtCol, style=patternStyle, size=size.small)
tol = useAtrTol ? atrValTol * atrMultTol : close * pctTol * 0.01
var line[]  bslLines      = array.new_line()
var float[] bslPrices     = array.new_float()
var int[]   bslOriginBars = array.new_int()
var bool[]  bslMitigated  = array.new_bool()
var line[]  sslLines      = array.new_line()
var float[] sslPrices     = array.new_float()
var int[]   sslOriginBars = array.new_int()
var bool[]  sslMitigated  = array.new_bool()
var float prevPHPrice = na
var int   prevPHBar   = na
var float prevPLPrice = na
var int   prevPLBar   = na
f_new_pool_line(_y, _isBSL) =>
    clr = _isBSL ? color.new(color.aqua, 0) : color.new(color.fuchsia, 0)
    line.new(bar_index, _y, bar_index + 1, _y, xloc=xloc.bar_index, extend=extend.right, color=color.new(clr, 90), style=line.style_solid, width=2)
f_mark_mitigated(_line, _isBSL) =>
    clrMit = _isBSL ? color.new(color.aqua, 60) : color.new(color.fuchsia, 60)
    line.set_color(_line, color.new(clrMit, 90))
    line.set_style(_line, line.style_dashed)
f_trim_arrays(_isBSL) =>
    if _isBSL
        while array.size(bslLines) > lookbackPivots
            line.delete(array.shift(bslLines))
            array.shift(bslPrices)
            array.shift(bslOriginBars)
            array.shift(bslMitigated)
    else
        while array.size(sslLines) > lookbackPivots
            line.delete(array.shift(sslLines))
            array.shift(sslPrices)
            array.shift(sslOriginBars)
            array.shift(sslMitigated)
removePoolAt(_isBSL, _idx) =>
    if _isBSL
        if _idx >= 0 and _idx < array.size(bslLines)
            ln = array.get(bslLines, _idx)
            if not na(ln)
                line.delete(ln)
            array.remove(bslLines, _idx)
        if _idx >= 0 and _idx < array.size(bslPrices)
            array.remove(bslPrices, _idx)
        if _idx >= 0 and _idx < array.size(bslOriginBars)
            array.remove(bslOriginBars, _idx)
        if _idx >= 0 and _idx < array.size(bslMitigated)
            array.remove(bslMitigated, _idx)
    else
        if _idx >= 0 and _idx < array.size(sslLines)
            ln = array.get(sslLines, _idx)
            if not na(ln)
                line.delete(ln)
            array.remove(sslLines, _idx)
        if _idx >= 0 and _idx < array.size(sslPrices)
            array.remove(sslPrices, _idx)
        if _idx >= 0 and _idx < array.size(sslOriginBars)
            array.remove(sslOriginBars, _idx)
        if _idx >= 0 and _idx < array.size(sslMitigated)
            array.remove(sslMitigated, _idx)
if showPools and not na(ph)
    phIdx   = bar_index - swingLen
    phPrice = high[swingLen]
    isEqHigh = not na(prevPHPrice) and math.abs(phPrice - prevPHPrice) <= tol and (phIdx - nz(prevPHBar)) >= minBarsGap
    if isEqHigh
        lvl = (phPrice + prevPHPrice) / 2.0
        ln  = f_new_pool_line(lvl, true)
        array.push(bslLines, ln), array.push(bslPrices, lvl), array.push(bslOriginBars, phIdx), array.push(bslMitigated, false)
        f_trim_arrays(true)
    prevPHPrice := phPrice
    prevPHBar   := phIdx
if showPools and not na(pl)
    plIdx   = bar_index - swingLen
    plPrice = low[swingLen]
    isEqLow = not na(prevPLPrice) and math.abs(plPrice - prevPLPrice) <= tol and (plIdx - nz(prevPLBar)) >= minBarsGap
    if isEqLow
        lvl = (plPrice + prevPLPrice) / 2.0
        ln  = f_new_pool_line(lvl, false)
        array.push(sslLines, ln), array.push(sslPrices, lvl), array.push(sslOriginBars, plIdx), array.push(sslMitigated, false)
        f_trim_arrays(false)
    prevPLPrice := plPrice
    prevPLBar   := plIdx
if showPools
    nB = math.min(array.size(bslLines), array.size(bslPrices), array.size(bslMitigated), array.size(bslOriginBars))
    if nB > 0
        for i = nB - 1 to 0
            bool hasLn  = i < array.size(bslLines)
            bool hasLvl = i < array.size(bslPrices)
            bool hasMit = i < array.size(bslMitigated)
            line  ln  = hasLn  ? array.get(bslLines, i)     : na
            float lvl = hasLvl ? array.get(bslPrices, i)    : na
            bool  mit = hasMit ? array.get(bslMitigated, i) : false
            if hasLn and hasLvl and hasMit and not na(ln) and not na(lvl)
                if not mit and close > lvl + tol
                    if persistMitigated
                        f_mark_mitigated(ln, true)
                        array.set(bslMitigated, i, true)
                    else
                        removePoolAt(true, i)
    nS = math.min(array.size(sslLines), array.size(sslPrices), array.size(sslMitigated), array.size(sslOriginBars))
    if nS > 0
        for i = nS - 1 to 0
            bool hasLn  = i < array.size(sslLines)
            bool hasLvl = i < array.size(sslPrices)
            bool hasMit = i < array.size(sslMitigated)
            line  ln  = hasLn  ? array.get(sslLines, i)     : na
            float lvl = hasLvl ? array.get(sslPrices, i)    : na
            bool  mit = hasMit ? array.get(sslMitigated, i) : false
            if hasLn and hasLvl and hasMit and not na(ln) and not na(lvl)
                if not mit and close < lvl - tol
                    if persistMitigated
                        f_mark_mitigated(ln, false)
                        array.set(sslMitigated, i, true)
                    else
                        removePoolAt(false, i)
var line  dispBSL = na
var line  dispSSL = na
var label lblBSL  = na
var label lblSSL  = na
var float nearBSL = na
var float nearSSL = na
var float dBSL    = na
var float dSSL    = na
nearBSL := na
nearSSL := na
dBSL    := 1e10
dSSL    := 1e10
nB_near = math.min(array.size(bslPrices), array.size(bslMitigated))
if nB_near > 0
    for i = 0 to nB_near - 1
        bool  hasMit = i < array.size(bslMitigated)
        bool  hasPr  = i < array.size(bslPrices)
        bool  mit    = hasMit ? array.get(bslMitigated, i) : false
        float pr     = hasPr  ? array.get(bslPrices, i)    : na
        if hasPr and not mit and not na(pr)
            _d = math.abs(close - pr)
            if _d < dBSL
                dBSL   := _d
                nearBSL := pr
threshold = atr3 * 0.5
isSMF_bull = (close > open) and ((open - low) > (2 * math.abs(open - close))) and (volume > ta.sma(volume, 20) * 1.4)
nS_near = math.min(array.size(sslPrices), array.size(sslMitigated))
if nS_near > 0
    for i = 0 to nS_near - 1
        bool  hasMit = i < array.size(sslMitigated)
        bool  hasPr  = i < array.size(sslPrices)
        bool  mit    = hasMit ? array.get(sslMitigated, i) : false
        float pr     = hasPr  ? array.get(sslPrices, i)    : na
        if hasPr and not mit and not na(pr)
            _d = math.abs(close - pr)
            if _d < dSSL
                dSSL   := _d
                nearSSL := pr
isSMF_bear = (close < open) and ((high - close) > (2 * math.abs(open - close))) and (volume > ta.sma(volume, 20) * 1.4)
if showPools and showNearestPools
    if not na(nearBSL)
        clrB = color.new(color.aqua, 0)
        if na(dispBSL)
            dispBSL := line.new(bar_index - 1, nearBSL, bar_index + 1, nearBSL, xloc=xloc.bar_index, extend=extend.right, color=clrB, width=2)
        else
            line.set_y1(dispBSL, nearBSL)
            line.set_y2(dispBSL, nearBSL)
            line.set_x2(dispBSL, bar_index + 1)
            line.set_color(dispBSL, clrB)
        if not na(lblBSL)
            label.delete(lblBSL)
            lblBSL := na
        lblBSL := label.new(bar_index, nearBSL, "BSL " + str.tostring(nearBSL) + " | Vol " + str.tostring(volume), style=label.style_label_right, color=color.new(color.gray, 70), textcolor=color.white)
        if math.abs(close - nearBSL) < threshold and isSMF_bear
            label.new(bar_index, nearBSL, "SMF BSL Reversal", color=color.red, style=label.style_label_down, size=size.normal, textcolor=color.white, tooltip="Smart Money + BSL Level")
    if not na(nearSSL)
        clrS = color.new(color.fuchsia, 0)
        if na(dispSSL)
            dispSSL := line.new(bar_index - 1, nearSSL, bar_index + 1, nearSSL, xloc=xloc.bar_index, extend=extend.right, color=clrS, width=2)
        else
            line.set_y1(dispSSL, nearSSL)
            line.set_y2(dispSSL, nearSSL)
            line.set_x2(dispSSL, bar_index + 1)
            line.set_color(dispSSL, clrS)
        if not na(lblSSL)
            label.delete(lblSSL)
            lblSSL := na
        lblSSL := label.new(bar_index, nearSSL, "SSL " + str.tostring(nearSSL) + " | Vol " + str.tostring(volume), style=label.style_label_right, color=color.new(color.gray, 70), textcolor=color.white)
        if math.abs(close - nearSSL) < threshold and isSMF_bull
            label.new(bar_index, nearSSL, "SMF SSL Reversal", color=color.lime, style=label.style_label_up, size=size.normal, textcolor=color.black, tooltip="Smart Money + SSL Level")
if not showPools
    if not na(dispBSL)
        line.delete(dispBSL)
        dispBSL := na
    if not na(dispSSL)
        line.delete(dispSSL)
        dispSSL := na
    if not na(lblBSL)
        label.delete(lblBSL)
        lblBSL := na
    if not na(lblSSL)
        label.delete(lblSSL)
        lblSSL := na
rng      = high - low
rangeOk  = rng > 0
iceberg_bull = volume > ta.sma(volume,volLength)*1.5 and rangeOk and math.abs(close-open)/rng < 0.18 and close > open
iceberg_bear = volume > ta.sma(volume,volLength)*1.5 and rangeOk and math.abs(close-open)/rng < 0.18 and close < open
var label[] icebergBuyLabels  = array.new_label()
var label[] icebergSellLabels = array.new_label()
iceOff = math.max(atr3 * 0.12, minOff)
if iceberg_bull
    lbI = label.new(bar_index, low - iceOff, "ICEBERG BUY", style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.small, tooltip="High vol + tight range (proxy)")
    array.push(icebergBuyLabels, lbI)
    if array.size(icebergBuyLabels) > 2
        oldI = array.shift(icebergBuyLabels)
        if not na(oldI)
            label.delete(oldI)
if iceberg_bear
    lsI = label.new(bar_index, high + iceOff, "ICEBERG SELL", style=label.style_label_down, color=color.fuchsia, textcolor=color.white, size=size.small, tooltip="High vol + tight range (proxy)")
    array.push(icebergSellLabels, lsI)
    if array.size(icebergSellLabels) > 2
        oldS = array.shift(icebergSellLabels)
        if not na(oldS)
            label.delete(oldS)
mtf_ok_buy  = (close > htf_vwap and close > vwapVal and close > twapVal)
mtf_ok_sell = (close < htf_vwap and close < vwapVal and close < twapVal)
confluence_buy  = advancedLiqGrabBull and effectiveBullEngulf and vol_ok and iceberg_bull and mtf_ok_buy
buyScore  = (mtf_ok_buy?1:0) + (advancedLiqGrabBull?1:0) + (vol_ok?1:0) + (iceberg_bull?1:0) + (effectiveBullEngulf?1:0)
confluence_sell = advancedLiqGrabBear and effectiveBearEngulf and vol_ok and iceberg_bear and mtf_ok_sell
sellScore = (mtf_ok_sell?1:0) + (advancedLiqGrabBear?1:0) + (vol_ok?1:0) + (iceberg_bear?1:0) + (effectiveBearEngulf?1:0)
dirBuyScore  = (mtf_ok_buy?1:0) + (advancedLiqGrabBull?1:0) + (iceberg_bull?1:0) + (effectiveBullEngulf?1:0)
dirSellScore = (mtf_ok_sell?1:0) + (advancedLiqGrabBear?1:0) + (iceberg_bear?1:0) + (effectiveBearEngulf?1:0)
scoreNet     = buyScore - sellScore
rawLiteBuy   = buyScore  >= 1
rawLiteSell  = sellScore >= 1
lite_buy     = (scoreNet > 0) or (scoreNet == 0 and rawLiteBuy  and (dirBuyScore  > dirSellScore))
lite_sell    = (scoreNet < 0) or (scoreNet == 0 and rawLiteSell and (dirSellScore > dirBuyScore))
sigOff   = math.max(atr3 * 0.15, minOff)
final_buy  = (confirmOnClose ? barstate.isconfirmed : true) and confluence_buy
final_sell = (confirmOnClose ? barstate.isconfirmed : true) and confluence_sell
var bool prev_lite_buy  = false
var bool prev_lite_sell = false
lite_buy_trig  = lite_buy  and not prev_lite_buy
lite_sell_trig = lite_sell and not prev_lite_sell
prev_lite_buy  := lite_buy
prev_lite_sell := lite_sell
var label[] strongBuyLabels  = array.new_label()
var label[] strongSellLabels = array.new_label()
maxStrong = 5
var int[] sigHist = array.new_int()
histMax = 2
if final_buy
    lbS = label.new(bar_index, low - sigOff, "STRONG BUY", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.large, tooltip="VWAP/TWAP/HTF + POV + Iceberg + Pattern")
    array.push(strongBuyLabels, lbS)
    if array.size(strongBuyLabels) > maxStrong
        rm = array.shift(strongBuyLabels)
        if not na(rm)
            label.delete(rm)
if final_sell
    lsS = label.new(bar_index, high + sigOff, "STRONG SELL", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.large, tooltip="VWAP/TWAP/HTF + POV + Iceberg + Pattern")
    array.push(strongSellLabels, lsS)
    if array.size(strongSellLabels) > maxStrong
        rm2 = array.shift(strongSellLabels)
        if not na(rm2)
            label.delete(rm2)
if lite_buy_trig and adline_up
    array.push(sigHist, 1)
    if array.size(sigHist) > histMax
        array.shift(sigHist)
if lite_sell_trig and adline_down
    array.push(sigHist, -1)
    if array.size(sigHist) > histMax
        array.shift(sigHist)
var int prevBias = 0
int currBias = 0
int b2 = 0
int s2 = 0
int sz2 = array.size(sigHist)
if sz2 > 0
    for i = 0 to sz2 - 1
        int v = array.get(sigHist, i)
        if v == 1
            b2 += 1
        else if v == -1
            s2 += 1
    currBias := b2 > s2 ? 1 : s2 > b2 ? -1 : 0
var label[] exitLabels = array.new_label()
maxExit = 10
exitOff = math.max(atr3 * 0.12, minOff)
bool exitTrig = showExitOnBiasFlip and prevBias != 0 and currBias != 0 and currBias != prevBias
if exitTrig
    float y = currBias == 1 ? low - exitOff : high + exitOff
    exitLbl = label.new(bar_index, y, "EXIT", style=(currBias == 1 ? label.style_label_up : label.style_label_down), color=color.new(color.orange, 0), textcolor=color.black, size=size.normal, tooltip="Signal Bias flipped — exit")
    array.push(exitLabels, exitLbl)
    if array.size(exitLabels) > maxExit
        old = array.shift(exitLabels)
        if not na(old)
            label.delete(old)
prevBias := currBias
var float lastLow1 = na
var float lastLow2 = na
var int   lastLowIdx1 = na
var int   lastLowIdx2 = na
var float lastHigh1 = na
var float lastHigh2 = na
var int   lastHighIdx1 = na
var int   lastHighIdx2 = na
if not na(pl)
    lastLow2    := lastLow1
    lastLowIdx2 := lastLowIdx1
    lastLow1    := pl
    lastLowIdx1 := bar_index - swingLen
if not na(ph)
    lastHigh2    := lastHigh1
    lastHighIdx2 := lastHighIdx1
    lastHigh1    := ph
    lastHighIdx1 := bar_index - swingLen
var line bullTL = na
var line bearTL = na
var extendMode = extend.none
extendMode := extendRightTL ? extend.right : extend.none
if showDynTL and advancedLiqGrabBull and not na(lastLow2) and not na(lastLow1)
    if na(bullTL)
        bullTL := line.new(lastLowIdx2, lastLow2, lastLowIdx1, lastLow1, xloc=xloc.bar_index, color=color.lime, width=2, extend=extendMode)
    else
        line.set_xy1(bullTL, lastLowIdx2, lastLow2)
        line.set_xy2(bullTL, lastLowIdx1, lastLow1)
        line.set_extend(bullTL, extendMode)
if showDynTL and advancedLiqGrabBear and not na(lastHigh2) and not na(lastHigh1)
    if na(bearTL)
        bearTL := line.new(lastHighIdx2, lastHigh2, lastHighIdx1, lastHigh1, xloc=xloc.bar_index, color=color.red, width=2, extend=extendMode)
    else
        line.set_xy1(bearTL, lastHighIdx2, lastHigh2)
        line.set_xy2(bearTL, lastHighIdx1, lastHigh1)
        line.set_extend(bearTL, extendMode)


// === BUY/SELL/EXIT Signal के लिए GLOBAL Bias Calculation ===
int bCnt = 0
int sCnt = 0
int sz = array.size(sigHist)
if sz > 0
    for i = 0 to sz - 1
        int v = array.get(sigHist, i)
        if v == 1
            bCnt += 1
        else if v == -1
            sCnt += 1
string bias = 'NEUTRAL'
if bCnt > sCnt
    bias := 'BUY'
else if sCnt > bCnt
    bias := 'SELL'

// === BUY/SELL/EXIT Chart Signal System ===
var string prevBiasUser = na
var label signalLabel = na

if not na(prevBiasUser) and bias != prevBiasUser
    if not na(signalLabel)
        label.delete(signalLabel)
    if bias == 'BUY'
        signalLabel := label.new(bar_index, low, "BUY", color=color.lime, style=label.style_label_up, textcolor=color.black, size=size.normal, tooltip="Signal Bias: BUY")
    else if bias == 'SELL'
        signalLabel := label.new(bar_index, high, "SELL", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.normal, tooltip="Signal Bias: SELL")
    else
        signalLabel := label.new(bar_index, close, "EXIT", color=color.orange, style=label.style_label_down, textcolor=color.black, size=size.normal, tooltip="Signal Bias: EXIT")
prevBiasUser := bias

var table dash = na
if bar_index == 0 and showDashboard
    dash := table.new(position.top_right, 2, 12, border_width=1, bgcolor=color.new(color.black, 0))
ui_put(_row, _name, _value) =>
    table.cell(dash, 0, _row, _name, text_color=color.white, bgcolor=color.black, text_halign=text.align_left, text_valign=text.align_center, text_size=size.normal)
    table.cell(dash, 1, _row, _value, text_color=color.white, bgcolor=color.black, text_halign=text.align_right, text_valign=text.align_center, text_size=size.normal)
if showDashboard and not na(dash) and barstate.islast
    string volComp = na
    if volume > volume[1]
        volComp := 'High'
    else if volume < volume[1]
        volComp := 'Low'
    else
        volComp := 'Equal'
    string nearestTxt = '—'
    int row = 0
    ui_put(row, 'Reversal',     str.tostring(reversalPrice)) , row += 1
    ui_put(row, 'Vol vs Prev',  volComp) , row += 1
    ui_put(row, 'Buy Power',  str.tostring(buyScore)  + '/5') , row += 1
    ui_put(row, 'Sell Power', str.tostring(sellScore) + '/5') , row += 1
    int bCnt = 0
    int sCnt = 0
    int sz = array.size(sigHist)
    if sz > 0
        for i = 0 to sz - 1
            int v = array.get(sigHist, i)
            if v == 1
                bCnt += 1
            else if v == -1
                sCnt += 1
    string bias = 'NEUTRAL'
    if bCnt > sCnt
        bias := 'BUY'
    else if sCnt > bCnt
        bias := 'SELL'
    ui_put(row, 'Last 2 Signals', 'B ' + str.tostring(bCnt) + ' | S ' + str.tostring(sCnt)) , row += 1
    ui_put(row, 'Signal Bias', bias) , row += 1
````
