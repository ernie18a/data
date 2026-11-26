# Market Bias Dashboard (MBD) [SharpStrat]

- url: https://www.tradingview.com/script/GtXs58u3-Market-Bias-Dashboard-MBD-SharpStrat/
- type: indicator
- pine_id: PUB;e8135d2ff611488e903fb3ba96a9c862
- version: 1.0

## Description

[b]Market Bias Dashboard - MBD 
[/b]
[i]Trading without context is like driving with a blindfold on.
[/i]
You see a bullish signal. You enter. Price reverses immediately. Why? Probably because the signal was real but the context was wrong. You were probably buying at the top of a range into a fading trend against a higher timeframe that was screaming bearish. The signal didn't lie to you. You just didn't have the full picture.

[i]MBD gives you the full picture.
[/i]
It's a context dashboard that sits on your chart and answers the most important question in trading before you even think about entering: What is this market actually doing right now? Not a buy signal. Not a sell signal. Just pure honest market context, measured four different ways, on two timeframes at once, updated every single bar.

The reason it uses four separate components rather than one is deliberate. Any single measurement of the market is incomplete. Structure alone doesn't tell you if the trend has momentum behind it or if it's running out of steam. Momentum alone doesn't tell you where price sits in the bigger range. Volatility alone doesn't tell you the direction. Each component fills in a blind spot that the others have, and together they give you a picture that none of them could give alone.
[image]https://www.tradingview.com/x/wBigqkCK/[/image]

[b]How it was built — the thinking behind it
[/b]
Most context indicators fail because they either use one measurement or they combine things in a way that makes the output a black box. MBD was built differently. Every component measure something completely separate, so if one is broken or noisy the others still give you useful information. And every component's reading is visible individually, so you always know why the combined bias says what it says.

The four things it measures are the four things that define market behaviour at any point in time i.e. direction, position, energy, and state. Take away any one of them and your read of the market is incomplete.

[b]Component 1 — Structure
[/b]
[i]The foundation. Before anything else, you need to know which direction the market is moving.
[/i]
[image]https://www.tradingview.com/x/kOcEOgSx/[/image]
Structure is determined by looking at real swing highs and swing lows actual turning points in price, confirmed by a configurable number of bars on either side. MBD then compares the last two swing highs and the last two swing lows to each other:
[list]
[*]Higher High + Higher Low = price is making upward progress = Bullish structure
[*]Lower High + Lower Low = price is making downward progress = Bearish structure
[*]Mixed = price is going nowhere with conviction = Neutral
[/list]
The key distinction here is that this uses actual pivot points, not a moving average that lags behind price. When price makes a genuine new swing high above the previous one, that is a fact. MBD records it. When structure flips, when a bullish sequence suddenly becomes bearish the dashboard immediately flags it as [i]Transitioning[/i], which is a warning to pay attention even before the other components react.

[b]Component 2 — Range Position
[/b]
[i]Knowing the direction is not enough. You also need to know where price currently sits within the bigger picture.
[/i]
[image]https://www.tradingview.com/x/Hkux5bcU/[/image]
Think of it this way if a stock has been trading between 100 and 150 for the past two months and it is currently at 148, the structure might still say bullish. But you are buying right at the top of a two-month range. That is a very different risk than buying the same stock at 108.

Range Position solves this. It takes the highest high and lowest low over the last 50 bars (configurable) and calculates exactly where the current price sits inside that range as a percentage. It then displays that as a visual progress bar so you can see it instantly without reading a number:
[list]
[*]Above 60% — price is in the upper portion of the range, bullish context
[*]40% to 60% — price is in the middle, neutral, no positional edge
[*]Below 40% — price is in the lower portion of the range, bearish context
[/list]
This component is especially powerful when it contradicts structure. Bullish structure but range position at 90%? That tension is worth knowing. You are buying a bullish trend right at the top of the range the exact level where sellers tend to appear. MBD puts that conflict in front of you so you can decide what to do with it.

[b]Component 3 — Momentum
[/b]
[i]A trend can be intact and dying at the same time. Momentum is what tells you which one it is.
[/i]
[image]https://www.tradingview.com/x/IkObCLtw/[/image]
Here is something most beginners don't realize: a market can keep making higher highs while simultaneously running out of steam. The direction is still up. The structure still says bullish. But each successive push is covering less ground than the one before it. That is a trend that is exhausting itself and being in it without knowing that is how you get caught in a reversal you did not see coming.

MBD measures momentum by tracking the size of recent price swings and comparing them to earlier ones. How much distance each swing is covering relative to past swings. Then it smooths that comparison to filter out noise.
[list]
[*]Swings getting bigger = Accelerating. The trend has fuel. It is building, not dying.
[*]Swings roughly the same size = Steady. Trend is continuing at a consistent pace.
[*]Swings getting smaller = Fading. Energy is leaving the move. Proceed with caution.
[/list]
The most powerful combination is Bullish structure + Accelerating momentum. That is a market with direction and energy behind it. The most dangerous combination is Bullish structure + Fading momentum a trend that looks fine on the surface but is quietly breaking down underneath.

[b]Component 4 — Volatility
[/b]
[i]Market cycle between expansion and contraction. This component tells you which phase you're in.[/i]
After a big move, markets tend to calm down and compress. Volatility drops. Ranges tighten. Then at some point the compression end and when it does, the next move tends to be sharp and clean. Understanding where you are in that cycle completely changes how you should be treating the market.

MBD measures this by comparing the current ATR (Average True Range a measure of how much price is actually moving bar to bar) against its own longer-term average. Three states are possible:
[list]
[*]Expanding — the market is moving more than usual. Trends are active and clean. Good environment for trend following entries.
[*]Normal — Volatility is around its historical average. Market is in a typical state, nothing exceptional to flag.
[*]Coiling  — Volatility has contracted significantly below normal. The market is compressing like a spring. It will not stay this quiet forever.
[/list]
When you see Coiling on the dashboard, a breakout is typically approaching. It does not tell you the direction but it tells you to pay attention, tighten your stops if you are in a trade, and have a plan ready. Many of the cleanest, most explosive moves in any market come directly out of a coiling period.

[b]The combined bias 
[/b]
Each component scores +1 for a bullish reading, -1 for bearish, and 0 for neutral. Those scores are added up and the total maps to these labels:
[list]
[*]▲ Strong Bullish — most or all components aligned bullish
[*]▲ Moderate Bullish — clear bullish lean with some components neutral
[*]▲ Weak Bullish — marginal bullish lean, proceed carefully
[*]◆ Ranging — no directional edge at all
[*]▼ Weak / Moderate / Strong Bearish — same logic in the bearish direction
[*]⚡ Coiling — breakout approaching, direction unclear.
[*]↔ Transitioning — structure just flipped. Wait for confirmation.
[/list]
The bias label is visible for both your current timeframe and your higher timeframe simultaneously, so you always have both perspectives in front of you.

[b]Multi-Timeframe[/b]
At the bottom of the component section there is a TF Alignment row. This is arguably the most valuable reading in the entire indicator.
It tells you whether your current timeframe and your higher timeframe are saying the same thing:
[list]
[*]Aligned — both timeframes agree on direction. This is where the highest probability setups live. When you are bullish on the 15-minute and the 4-hour is also bullish, you have the wind at your back.
[*]Conflicting — the timeframes disagree. You might be seeing a bullish setup on your trading timeframe but the higher timeframe is bearish. That does not mean you can't trade   but you are fighting the bigger picture, and that should affect your position size and your expectations. Mixed — partial agreement. Somewhere in between.
[*]The most common mistake beginners make is entering a trade that looks perfect on their timeframe without ever checking the bigger picture. This removes that blind spot entirely.
[/list]
The most common mistake beginners make is entering a trade that looks perfect on their timeframe without ever checking the bigger picture. This removes that blind spot entirely.

[b]Past Bias Trail 
[/b]
The trail row shows the last 10 bias states the market has moved through, from oldest on the left to newest on the right. Each symbol represents a complete past bias when the bias changed state. This filters out noise and shows you meaningful shifts.
[image]https://www.tradingview.com/x/IJUZNeOm/[/image]
[i]Three patterns to watch for:
[/i]
[list=1]
[*]Consistent — sustained bullish symbols across most of the trail. This tells you the market has been in a clean trend for a while and the current bullish reading is not new it has been the dominant state. Trade with it.
[*]Choppy — random mix of bullish, bearish, and neutral. The market has been going nowhere with conviction for a while. Even if the current bias looks bullish, history says this market cannot hold a direction. Reduce size or sit out.
[*]Reversal — bearish, then ranging, then coiling, then transitioning, then bullish. This is a textbook reversal building over time. Each step makes sense in sequence. This is the kind of trail that tells you a genuine directional shift has happened and the new bias has momentum behind it.
[/list]

[b]How to Use
[/b]
Each step builds context, so following a consistent flow helps you understand not just what the market is doing, but whether it’s worth trading at all.
1: [i]Check Timeframe Alignment[/i] - Start by comparing your current timeframe with the higher timeframe.
When both are aligned, the market has directional agreement and trades carry higher probability. If they conflict, you are trading against the broader trend, which increases risk. Mixed conditions usually indicate uncertainty.
At this stage, you are simply deciding whether the environment is favorable enough to proceed.
2: [i]Read the Overall Bias[/i]- A strong bias means multiple factors are supporting the same direction, while a weak or neutral bias suggests there is no clear edge. This step helps you quickly judge whether the market has conviction or is just moving without structure.
3: [i]Understand the Components[/i] - Look at structure, range position, momentum, and volatility together. These components explain why the bias exists. For example, a bullish bias supported by strong structure and accelerating momentum is very different from a bullish bias where momentum is already fading.
4:[i] Evaluate Entry Location[/i] - Before entering, check where price sits within its range.
Even in a strong trend, entering near extremes increases risk. Good trades come from combining direction with reasonable positioning, not chasing price at the edges.
5: [i]Confirm Momentum[/i]
Momentum tells you if the move still has strength.
Accelerating momentum supports continuation, while fading momentum warns that the move may be weakening. This helps you avoid entering late into exhausted trends.
6: [i]Check Volatility[/i]
Now assess the volatility state.
Expanding volatility supports trending moves, while coiling indicates compression and a potential breakout. During coiling phases, it is usually better to wait for confirmation rather than predict direction.
7: [i]Review Recent History[/i]
Finally, glance at the bias history trail.
A consistent sequence suggests a stable trend, while a mixed sequence indicates choppy conditions. This adds context and helps you judge whether the current state is likely to hold.
[i]Final Decision[/i]
When alignment, bias, components, and conditions all support each other, you have a strong setup. If they conflict, the better decision is often to stay out.

[b]SETTINGS [/b]
[list]
[*]Swing Length — How strict the pivot detection is. Higher = fewer but more significant swings detected (default: 5) 
[*]Range Lookback — How many bars define the recent high/low range (default: 50) 
[*]ATR Period — Bars used to measure current volatility (default: 14) 
[*]ATR Average Period — Volatility baseline (default: 50) 
[*]Coiling Threshold - How compressed volatility must be to trigger the Coiling state (default: 0.75) 
[*]Higher Timeframe —Multi timeframe (default: 240 = 4H) 
[*]History Count — Number of observations in the past bias trail (default: 8) 
[*]Panel Position — Where the dashboard sits on your chart (default: Top Right)
[*]Color Theme — Dark / Light
[/list]

[b]Works everywhere
[/b]
MBD is built to work universally not just on one asset type or one timeframe. The four components it measures are structure, range position, momentum, volatility these exist in every liquid market that has ever traded. Whether you are scalping Bitcoin on the one minute chart, swing trading stocks on the daily, or analyzing forex on the four hour, the dashboard reads the same way and the interpretation is identical.

This is [i]not a signal tool[/i].[i] It is a context tool.[/i] Use it to understand the market before you enter, not to decide for you.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SharpStrat

//@version=6
indicator("Market Bias Dashboard ", shorttitle="MBD", overlay=true)

// INPUTS
grpStructure   = "Structure Settings"
swingLen       = input.int(5,"Swing Detection Length", minval=2, maxval=20,group=grpStructure)
grpRange       = "Range Position Settings"
rangeLookback  = input.int(50,"Range Lookback (bars)", minval=10, maxval=300,group=grpRange)
grpMomentum    = "Momentum Settings"
momSmooth      = input.int(3,"Momentum Smoothing", minval=1, maxval=10,group=grpMomentum)
grpVolatility  = "Volatility Settings"
atrLen         = input.int(14, "ATR Period", minval=5,  maxval=50, group=grpVolatility)
atrAvgLen      = input.int(50,"ATR Average Period", minval=20, maxval=200, group=grpVolatility)
coilThresh     = input.float(0.75,"Coiling Threshold", minval=0.3,maxval=0.95,group=grpVolatility,step=0.05)
grpMTF         = "Multi-Timeframe Settings"
showMTF        = input.bool(true, "Show HTF Bias Column", group=grpMTF)
htfTF          = input.timeframe("240", "Higher Timeframe",group=grpMTF)
grpHistory     = "Bias History Settings"
showHistory    = input.bool(true, "Show Bias History Trail", group=grpHistory)
grpDisplay     = "Display Settings"
showStructure  = input.bool(true, "Show Structure Row", group=grpDisplay)
showRange      = input.bool(true, "Show Range Position Row", group=grpDisplay)
showMomentum   = input.bool(true, "Show Momentum Row", group=grpDisplay)
showVolatility = input.bool(true, "Show Volatility Row",group=grpDisplay)
panelPos       = input.string("Top Right", "Panel Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpDisplay)
colorTheme     = input.string("Dark", "Color Theme",options=["Dark","Light"], group=grpDisplay)


// COLORS
isDark       = colorTheme == "Dark"
C_BG         = isDark ? color.new(color.gray, 85) : color.new(color.white, 20)
C_BORDER     = color.new(color.gray, 60)
C_HEADER_BG  = isDark ? color.new(color.gray, 70) : color.new(color.gray, 30)
C_HEADER_TXT = color.white
C_LABEL_TXT  = isDark ? color.new(color.white, 20) : color.new(color.black, 20)
C_BULL       = color.new(#26a69a, 0)
C_BEAR       = color.new(#ef5350, 0)
C_NEUTRAL    = color.new(#b0bec5, 0)
C_WARN       = color.new(#ffa726, 0)
C_COIL       = color.new(#ab47bc, 0)
C_BULL_WEAK  = color.new(#80cbc4, 0)
C_BEAR_WEAK  = color.new(#ef9a9a, 0)

// COLUMN LAYOUT 
TOTAL_COLS = 11
COL_CUR_S  = 1   
COL_CUR_E  = 5   
COL_HTF_S  = 6   
COL_HTF_E  = 10  
DOT_COUNT  = 10  

// HELPERS
buildRangeBar(pct) =>
    filled = math.round(pct / 10)
    bar    = ""
    for i = 0 to 9
        bar := bar + (i < filled ? "█" : "░")
    bar + " " + str.tostring(math.round(pct)) + "%"

getBiasLabel(sc, vCoil, sFlipped) =>
    lbl = "◆ Ranging"
    if sFlipped
        lbl := "↔ Transitioning"
    else if vCoil
        lbl := "⚡ Coiling"
    else if sc >= 3
        lbl := "▲ Strong Bullish"
    else if sc == 2
        lbl := "▲ Moderate Bullish"
    else if sc == 1
        lbl := "▲ Weak Bullish"
    else if sc == 0
        lbl := "◆ Ranging"
    else if sc == -1
        lbl := "▼ Weak Bearish"
    else if sc == -2
        lbl := "▼ Moderate Bearish"
    else if sc <= -3
        lbl := "▼ Strong Bearish"
    lbl

getBiasColor(sc, vCoil, sFlipped) =>
    clr = C_NEUTRAL
    if sFlipped
        clr := C_WARN
    else if vCoil
        clr := C_COIL
    else if sc >= 2
        clr := C_BULL
    else if sc == 1
        clr := C_WARN
    else if sc == 0
        clr := C_NEUTRAL
    else if sc == -1
        clr := C_WARN
    else if sc <= -2
        clr := C_BEAR
    clr

encodeState(sc, vCoil, sFlip) =>
    enc = 1
    if sFlip
        enc := -1
    else if vCoil
        enc := 0
    else if sc >= 2
        enc := 3
    else if sc == 1
        enc := 2
    else if sc == 0
        enc := 1
    else if sc == -1
        enc := -2
    else
        enc := -3
    enc

dotColorFromCode(code) =>
    clr = C_NEUTRAL
    if code == 3
        clr := C_BULL
    else if code == 2
        clr := C_BULL_WEAK
    else if code == 1
        clr := C_NEUTRAL
    else if code == 0
        clr := C_COIL
    else if code == -1
        clr := C_WARN
    else if code == -2
        clr := C_BEAR_WEAK
    else if code == -3
        clr := C_BEAR
    clr

dotSymbolFromCode(code) =>
    sym = "◆"
    if code == 3
        sym := "▲"
    else if code == 2
        sym := "△"
    else if code == 1
        sym := "◆"
    else if code == 0
        sym := "⚡"
    else if code == -1
        sym := "↔"
    else if code == -2
        sym := "▽"
    else if code == -3
        sym := "▼"
    sym

// BIAS CALCULATOR
calcBias(src_high, src_low, src_close, sLen, rLookback, mSmooth, aLen, aAvgLen, cThresh) =>
    sHigh = ta.pivothigh(src_high, sLen, sLen)
    sLow  = ta.pivotlow(src_low,  sLen, sLen)
    var float _sh1 = na
    var float _sh2 = na
    var float _sl1 = na
    var float _sl2 = na
    if not na(sHigh)
        _sh2 := _sh1
        _sh1 := sHigh
    if not na(sLow)
        _sl2 := _sl1
        _sl1 := sLow
    sBull = not na(_sh1) and not na(_sh2) and not na(_sl1) and not na(_sl2) and _sh1 > _sh2 and _sl1 > _sl2
    sBear = not na(_sh1) and not na(_sh2) and not na(_sl1) and not na(_sl2) and _sh1 < _sh2 and _sl1 < _sl2
    rHigh = ta.highest(src_high, rLookback)
    rLow  = ta.lowest(src_low,  rLookback)
    rSize = rHigh - rLow
    rPct  = rSize > 0 ? (src_close - rLow) / rSize * 100 : 50.0
    rawSwing = math.abs(src_close - src_close[sLen])
    smSwing  = ta.ema(rawSwing, mSmooth)
    prvSwing = ta.ema(rawSwing[sLen], mSmooth)
    mAccel   = smSwing > prvSwing * 1.05
    mFading  = smSwing < prvSwing * 0.95
    atrV  = ta.atr(aLen)
    atrA  = ta.sma(atrV, aAvgLen)
    atrR  = atrA > 0 ? atrV / atrA : 1.0
    vExp  = atrR >= 1.1
    vCoil = atrR <= cThresh
    sc = 0
    sc := sc + (sBull ? 1 : sBear    ? -1 : 0)
    sc := sc + (rPct > 55 ? 1 : rPct < 45 ? -1 : 0)
    sc := sc + (mAccel ? 1 : mFading ? -1 : 0)
    sc := sc + (vExp   ? 1 : 0)
    [sc, sBull, sBear, rPct, mAccel, mFading, vExp, vCoil]

// CURRENT TIMEFRAME
[curScore, curSBull, curSBear, curRPct, curMAccel, curMFading, curVExp, curVCoil] =
     calcBias(high, low, close, swingLen, rangeLookback, momSmooth, atrLen, atrAvgLen, coilThresh)

var bool _prevSBull = false
var bool _prevSBear = false
curFlipped  = (curSBull and _prevSBear) or (curSBear and _prevSBull)
_prevSBull := curSBull
_prevSBear := curSBear

curStructLabel = curSBull ? "▲ Bullish": curSBear? "▼ Bearish" : "◆ Neutral"
curStructColor = curSBull ? C_BULL: curSBear? C_BEAR: C_NEUTRAL
curRangeLabel  = buildRangeBar(curRPct)
curRangeColor  = curRPct >= 60 ? C_BULL: curRPct <= 40 ? C_BEAR: C_NEUTRAL
curMomLabel    = curMAccel ? "▲ Accelerating" : curMFading ? "▼ Fading": "◆ Steady"
curMomColor    = curMAccel ? C_BULL: curMFading ? C_BEAR: C_NEUTRAL
curVolLabel    = curVExp? "▲ Expanding": curVCoil? "◆ Coiling": "◆ Normal"
curVolColor    = curVExp? C_BULL: curVCoil? C_COIL: C_NEUTRAL
curBiasLabel   = getBiasLabel(curScore, curVCoil, curFlipped)
curBiasColor   = getBiasColor(curScore, curVCoil, curFlipped)

// HIGHER TIMEFRAME
htfHigh  = request.security(syminfo.tickerid, htfTF, high,lookahead=barmerge.lookahead_off)
htfLow   = request.security(syminfo.tickerid, htfTF, low,lookahead=barmerge.lookahead_off)
htfClose = request.security(syminfo.tickerid, htfTF, close,lookahead=barmerge.lookahead_off)

[htfScore, htfSBull, htfSBear, htfRPct, htfMAccel, htfMFading, htfVExp, htfVCoil] =
     calcBias(htfHigh, htfLow, htfClose, swingLen, rangeLookback, momSmooth, atrLen, atrAvgLen, coilThresh)

htfStructLabel = htfSBull ? "▲ Bullish": htfSBear? "▼ Bearish"  : "◆ Neutral"
htfStructColor = htfSBull ? C_BULL: htfSBear? C_BEAR: C_NEUTRAL
htfRangeLabel  = buildRangeBar(htfRPct)
htfRangeColor  = htfRPct >= 60 ? C_BULL: htfRPct <= 40 ? C_BEAR: C_NEUTRAL
htfMomLabel    = htfMAccel ? "▲ Accelerating" : htfMFading ? "▼ Fading" : "◆ Steady"
htfMomColor    = htfMAccel ? C_BULL: htfMFading ? C_BEAR: C_NEUTRAL
htfVolLabel    = htfVExp? "▲ Expanding": htfVCoil ? "◆ Coiling": "◆ Normal"
htfVolColor    = htfVExp  ? C_BULL: htfVCoil ? C_COIL: C_NEUTRAL
htfBiasLabel   = getBiasLabel(htfScore, htfVCoil, false)
htfBiasColor   = getBiasColor(htfScore, htfVCoil, false)

curBullish  = curScore > 0 and not curVCoil and not curFlipped
curBearish  = curScore < 0 and not curVCoil and not curFlipped
htfBullish  = htfScore > 0 and not htfVCoil
htfBearish  = htfScore < 0 and not htfVCoil
aligned     = (curBullish and htfBullish) or (curBearish and htfBearish)
conflicting = (curBullish and htfBearish) or (curBearish and htfBullish)
alignLabel  = aligned ? "✅ Aligned" : conflicting ? "⚠️ Conflicting" : "◆ Mixed"
alignColor  = aligned ? C_BULL: conflicting ? C_WARN: C_NEUTRAL

// BIAS HISTORY
var array<int> biasHistory = array.new<int>(0)
var int lastCode = 999
curCode = encodeState(curScore, curVCoil, curFlipped)

if curCode != lastCode
    array.push(biasHistory, curCode)
    if array.size(biasHistory) > DOT_COUNT
        array.shift(biasHistory)
    lastCode := curCode

// TABLE
compRows  = (showStructure ? 1 : 0) + (showRange ? 1 : 0) + (showMomentum ? 1 : 0) + (showVolatility ? 1 : 0)
totalRows = 2 + compRows + 1 + (showMTF ? 1 : 0) + (showHistory ? 1 : 0)

tblPos = panelPos == "Top Right"    ? position.top_right    :
         panelPos == "Top Left"     ? position.top_left     :
         panelPos == "Bottom Right" ? position.bottom_right :
         position.bottom_left

var table dash = na

if barstate.islast
    dash := table.new(tblPos, columns=TOTAL_COLS, rows=totalRows,
         bgcolor=C_BG, border_color=C_BORDER, border_width=1,
         frame_color=C_BORDER, frame_width=1)

    // Header 
    for c = 0 to TOTAL_COLS - 1
        table.cell(dash, c, 0, "", bgcolor=C_HEADER_BG)
    table.cell(dash, 0, 0, "MARKET BIAS DASHBOARD",
         text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG,
         text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, TOTAL_COLS - 1, 0)

    // Column header labels 
    for c = 0 to TOTAL_COLS - 1
        table.cell(dash, c, 1, "", bgcolor=C_HEADER_BG)
    table.cell(dash, 0, 1, "Component",
         text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG,
         text_size=size.small, text_halign=text.align_center)
    table.cell(dash, COL_CUR_S, 1, "Current TF",
         text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG,
         text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, COL_CUR_S, 1, COL_CUR_E, 1)
    table.cell(dash, COL_HTF_S, 1, htfTF + " HTF",
         text_color=C_HEADER_TXT, bgcolor=C_HEADER_BG,
         text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dash, COL_HTF_S, 1, COL_HTF_E, 1)
    row = 2

    //Structure
    if showStructure
        for c = 0 to TOTAL_COLS - 1
            table.cell(dash, c, row, "", bgcolor=C_BG)
        table.cell(dash, 0, row, "Structure",
             text_color=C_LABEL_TXT, text_size=size.normal,
             text_halign=text.align_left, bgcolor=C_BG)
        table.cell(dash, COL_CUR_S, row, curStructLabel,
             text_color=curStructColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_CUR_S, row, COL_CUR_E, row)
        table.cell(dash, COL_HTF_S, row, htfStructLabel,
             text_color=htfStructColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_HTF_S, row, COL_HTF_E, row)
        row += 1

    //Range Position
    if showRange
        for c = 0 to TOTAL_COLS - 1
            table.cell(dash, c, row, "", bgcolor=C_BG)
        table.cell(dash, 0, row, "Range Pos",
             text_color=C_LABEL_TXT, text_size=size.normal,
             text_halign=text.align_left, bgcolor=C_BG)
        table.cell(dash, COL_CUR_S, row, curRangeLabel,
             text_color=curRangeColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_CUR_S, row, COL_CUR_E, row)
        table.cell(dash, COL_HTF_S, row, htfRangeLabel,
             text_color=htfRangeColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_HTF_S, row, COL_HTF_E, row)
        row += 1

    //Momentum
    if showMomentum
        for c = 0 to TOTAL_COLS - 1
            table.cell(dash, c, row, "", bgcolor=C_BG)
        table.cell(dash, 0, row, "Momentum",
             text_color=C_LABEL_TXT, text_size=size.normal,
             text_halign=text.align_left, bgcolor=C_BG)
        table.cell(dash, COL_CUR_S, row, curMomLabel,
             text_color=curMomColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_CUR_S, row, COL_CUR_E, row)
        table.cell(dash, COL_HTF_S, row, htfMomLabel,
             text_color=htfMomColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_HTF_S, row, COL_HTF_E, row)
        row += 1

    // Volatility
    if showVolatility
        for c = 0 to TOTAL_COLS - 1
            table.cell(dash, c, row, "", bgcolor=C_BG)
        table.cell(dash, 0, row, "Volatility",
             text_color=C_LABEL_TXT, text_size=size.normal,
             text_halign=text.align_left, bgcolor=C_BG)
        table.cell(dash, COL_CUR_S, row, curVolLabel,
             text_color=curVolColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_CUR_S, row, COL_CUR_E, row)
        table.cell(dash, COL_HTF_S, row, htfVolLabel,
             text_color=htfVolColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_HTF_S, row, COL_HTF_E, row)
        row += 1

    //Bias
    for c = 0 to TOTAL_COLS - 1
        table.cell(dash, c, row, "", bgcolor=C_BG)
    table.cell(dash, 0, row, "Bias",
         text_color=C_LABEL_TXT, text_size=size.normal,
         text_halign=text.align_left, bgcolor=C_BG)
    table.cell(dash, COL_CUR_S, row, curBiasLabel,
         text_color=curBiasColor, text_size=size.normal,
         text_halign=text.align_center,
         bgcolor=color.new(curBiasColor, 82))
    table.merge_cells(dash, COL_CUR_S, row, COL_CUR_E, row)
    table.cell(dash, COL_HTF_S, row, htfBiasLabel,
         text_color=htfBiasColor, text_size=size.normal,
         text_halign=text.align_center,
         bgcolor=color.new(htfBiasColor, 82))
    table.merge_cells(dash, COL_HTF_S, row, COL_HTF_E, row)
    row += 1

    // TF Alignment
    if showMTF
        for c = 0 to TOTAL_COLS - 1
            table.cell(dash, c, row, "", bgcolor=C_BG)
        table.cell(dash, 0, row, "TF Align",
             text_color=C_LABEL_TXT, text_size=size.normal,
             text_halign=text.align_left, bgcolor=C_BG)
        table.cell(dash, COL_CUR_S, row, alignLabel,
             text_color=alignColor, text_size=size.normal,
             text_halign=text.align_center, bgcolor=C_BG)
        table.merge_cells(dash, COL_CUR_S, row, COL_HTF_E, row)
        row += 1

    // Past Bias Trail
    if showHistory
        histSize = array.size(biasHistory)
        table.cell(dash, 0, row, "Past Bias",
             text_color=C_LABEL_TXT, text_size=size.normal,
             text_halign=text.align_left, bgcolor=C_BG)
        for d = 0 to DOT_COUNT - 1
            dotCol  = d + 1
            slotIdx = d - (DOT_COUNT - histSize)
            if slotIdx >= 0 and slotIdx < histSize
                code   = array.get(biasHistory, slotIdx)
                dotClr = dotColorFromCode(code)
                dotSym = dotSymbolFromCode(code)
                table.cell(dash, dotCol, row, dotSym,
                     text_color=dotClr,
                     bgcolor=color.new(dotClr, 80),
                     text_size=size.large,
                     text_halign=text.align_center)
            else
                table.cell(dash, dotCol, row, "○",
                     text_color=color.new(C_NEUTRAL, 60),
                     bgcolor=C_BG,
                     text_size=size.large,
                     text_halign=text.align_center)

// ALERTS
alertcondition(curFlipped,
     title="Structure Shift",
     message="CBD Pro: Market structure has shifted.")
alertcondition(curVCoil and not curVCoil[1],
     title="Coiling — Breakout Likely",
     message="CBD Pro: Market is coiling — breakout may be imminent.")
alertcondition(curScore >= 3 and curScore[1] < 3,
     title="Strong Bullish Bias",
     message="CBD Pro: Bias shifted to Strong Bullish.")
alertcondition(curScore <= -3 and curScore[1] > -3,
     title="Strong Bearish Bias",
     message="CBD Pro: Bias shifted to Strong Bearish.")
alertcondition(aligned and not aligned[1],
     title="MTF Alignment Achieved",
     message="CBD Pro: Timeframes aligned — high conviction setup.")
alertcondition(conflicting and not conflicting[1],
     title="MTF Conflict Detected",
     message="CBD Pro: Timeframes conflicting — avoid new entries.")
alertcondition(curScore == 0 and math.abs(curScore[1]) >= 2,
     title="Bias Neutralised",
     message="CBD Pro: Bias dropped to Neutral.")
````
