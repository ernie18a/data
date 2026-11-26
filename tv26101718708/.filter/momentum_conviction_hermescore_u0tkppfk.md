# Momentum Conviction [HermesCore]

- url: https://www.tradingview.com/script/u0tKPpfk-Momentum-Conviction-HermesCore/
- type: indicator
- pine_id: PUB;b76da01d54c7444e9ae86fe199528c1c
- version: 1.0

## Description

[b]WHAT THIS INDICATOR DOES[/b]

[i]Momentum Conviction[/i] watches two things at the same moment: where price momentum turns, and how much agreement stands behind that turn. The turn is an EMA crossover — the fast EMA (Exponential Moving Average) crossing the slow one — but only when the MACD histogram (Moving Average Convergence Divergence, a standard momentum gauge) is leaning the same way. A LONG fires when the fast EMA crosses above the slow EMA while MACD momentum is positive; a SHORT is the exact mirror. A cross with no momentum behind it is ignored.

Every signal that does fire is then graded 0 to 5 by a conviction score, built from five independent checks the moment the signal prints. You decide how much conviction you require: show every signal, or raise the minimum and keep only the ones with weight behind them.

[b]WHY IT IS DIFFERENT[/b]

Most moving-average tools print an arrow on every cross and leave you to separate the real ones from the noise by eye. My rules are:
[list]
[*]A cross is not a signal on its own. It has to happen while MACD momentum agrees. A large share of the crosses that fail are crosses that fired into flat or opposing momentum; gating on the histogram removes them before they ever reach the chart.
[*]The score is a filter, not decoration. It is not a confidence label added after the fact — it is five yes/no facts, known at signal time, summed. Set a minimum and the weak signals never appear.
[*]The higher timeframe gets a vote, not the final word. One of the five points is HTF agreement, so you can weigh it without being ruled by it.
[*]ADX is deliberately excluded. I tested it repeatedly on the charts this was built for and it did not earn a place.
[*]Everything updates on confirmed bars only. No intrabar flicker, no repainting, and the higher-timeframe reads use no look-ahead.
[/list]
[b]HOW TO READ THE CHART[/b]
[list]
[*]LONG bubble (green, below the bar) and SHORT bubble (red, above it) mark each qualifying signal. Bubble size is adjustable.
[*]The gradient EMA cloud is aqua when the fast EMA sits above the slow one (uptrend lean) and magenta when below. The slow EMA carries a soft gold glow so the spine of the trend is always easy to find.
[*]A faint background tint colours the whole pane in the trend colour — a peripheral regime cue, nothing to act on by itself.
[*]A faint gold background band shows the previous day's and previous week's range, for context on where price sits inside the larger structure.
[/list]
[b]THE CONVICTION SCORE[/b]

Each check is worth one point, decided at signal time, and never changes afterwards:
[list]
[*][b]Momentum strength[/b] — the MACD histogram is larger than its own 50-bar average: the push is bigger than this market's normal push. +1
[*][b]Slope agreement[/b] — the fast EMA is itself moving in the signal's direction, not merely crossing. +1
[*][b]Higher-timeframe trend[/b] — the chosen HTF (4H by default) is trending the same way; its price and 50/200 EMAs agree. +1
[*][b]Not over-extended [/b]— price is within a set ATR (Average True Range, a volatility measure) distance of the slow EMA, so you are not entering after the move has already run. +1
[*][b]RSI room[/b] — RSI (Relative Strength Index, 0–100) is not already at an extreme in the signal's direction; there is room left to travel. +1
[/list]
Five of five is a cross with bigger-than-normal momentum, sloping the right way, aligned with the higher timeframe, entered near value, with room to run. Zero is a bare cross with nothing behind it. The minimum-score input is where you set your own bar.

[b]HOW I USE IT[/b]

The defaults are deliberately fast (EMA 2/12) — a low-timeframe, many-signals setting. Slow the lengths down for swing work and you get fewer, heavier signals.
I treat a high-score signal that agrees with the higher timeframe as the one worth acting on, and a low-score signal as information about the tape rather than a trade. The honest part: this is trend and momentum logic. It earns its keep when the market trends and gives a good deal of it back in ranges. The regime tint and the HTF vote exist to keep you on the right side of that question, not to solve it — be honest with yourself about which regime you are actually in.

SETTINGS THAT MATTER
[list]
[*][b]EMA fast/slow and MACD lengths[/b] — the engine. Defaults are fast; raise them for higher timeframes and fewer, heavier signals.
[*][b]Minimum score (0) [/b]— your conviction bar. 0 shows everything; raise it to thin the chart to signals with agreement behind them.
[*][b]Higher timeframe (4H)[/b] — the trend you check against. Match it to your horizon.
[*][b]Max distance to slow EMA (2.0 ATR)[/b] — how far from value still counts as "not over-extended."
[*][b]RSI overbought/oversold (72/28)[/b] — the "room left" thresholds.
[*]Each score component can be switched off individually if you want to see what it contributes on its own.
[/list]
[b]ALERTS[/b]

Momentum Conviction LONG and Momentum Conviction SHORT, both firing on the confirmed close of the signal bar, with ticker and timeframe in the message.

[b]CALCULATION DETAILS[/b]
[list]
[*]All logic evaluates on confirmed bars. A signal cannot appear or disappear inside a forming candle.
[*]The trigger is the fast/slow EMA cross; the gate is the sign of the MACD histogram on the same close.
[*]The higher-timeframe trend uses that timeframe's prior-bar close and 50/200 EMAs, requested with no look-ahead, so it does not repaint.
[*]The conviction score is computed once, at signal time, from the values listed above.
[/list]
[b]HONEST LIMITATIONS[/b]
[list]
[*]This is trend-following momentum. In a range it will cross back and forth and hand gains back; no filter removes that, it only thins it.
[*]The score is a hypothesis about signal quality, not a measured edge. This indicator does not keep score for you. If you want to know whether higher scores actually perform better on your symbol, run the matching strategy version in the Strategy Tester with realistic costs and read the result yourself.
[*]The defaults trade often. On a live account, slippage and spread on frequent entries matter more than the chart suggests — cost everything before you believe anything.
[*]Signals are evaluated at the close; real fills happen later and worse. Treat the chart as the ideal case.
[*]It runs on any symbol and timeframe, but "runs" is not "has an edge" — whether it works on your market is yours to verify. Past behaviour is not the next signal.
[*]Not financial advice. It manages no positions and places no orders.
[/list]
[b]ORIGINALITY[/b]

The ingredients — EMA crosses, MACD, RSI, ATR — are as old as charting. The momentum-gated trigger, the five-factor conviction score and its use as a hard filter, the regime-aware visual language and the non-repaint construction are my own work in Pine v6. Every value the script uses is recomputable from the rules above.

Questions and suggestions are welcome in the comments. Enjoy.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) HermesCore
//@version=6
// =====================================================================
//  Momentum Conviction [HermesCore]  — multi-asset, multi-timeframe
//   - CORE: EMA crossover filtered by MACD histogram direction (momentum trigger)
//   - CONVICTION SCORE 0-5: momentum strength, EMA slope, HTF trend,
//           not over-extended, RSI room. Filter with minScore.
//   - LONG/SHORT bubbles + gradient EMA cloud + day/week range as a zone.
//   - ADX deliberately EXCLUDED.
//  Indicator: fires signals only, no position management.
//  Non-repaint: everything on confirmed bars, HTF with lookahead_off.
// =====================================================================
indicator("Momentum Conviction [HermesCore]", "MC-HC", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ---------------- Core ----------------
gC = "01 Core signal"
emaFastLen = input.int(2,  "EMA fast", group = gC)
emaSlowLen = input.int(12, "EMA slow", group = gC)
mF = input.int(4,  "MACD fast",   group = gC)
mS = input.int(17, "MACD slow",   group = gC)
mSig = input.int(4, "MACD signal", group = gC)

emaF = ta.ema(close, emaFastLen)
emaS = ta.ema(close, emaSlowLen)
[mLine, mSigL, mHist] = ta.macd(close, mF, mS, mSig)
xUp = ta.crossover(emaF, emaS) and mHist > 0
xDn = ta.crossunder(emaF, emaS) and mHist < 0

// ---------------- Conviction score ----------------
gS = "02 Conviction score (each +1)"
useMom  = input.bool(true, "Momentum strength (|MACD hist| above its average)", group = gS)
useSlope= input.bool(true, "Fast EMA slopes with signal direction", group = gS)
useHtf  = input.bool(true, "Higher-timeframe trend agrees", group = gS)
useExt  = input.bool(true, "Not over-extended (close to slow EMA)", group = gS)
useRsi  = input.bool(true, "RSI still has room (not extreme)", group = gS)
extMult = input.float(2.0, "Max distance to slow EMA (x ATR)", step = 0.1, group = gS)
rsiOB = input.int(72, "RSI overbought", group = gS)
rsiOS = input.int(28, "RSI oversold", group = gS)
htfTf = input.timeframe("240", "Higher timeframe", group = gS)
minScore = input.int(0, "Minimum score to fire (0 = all)", minval = 0, maxval = 5, group = gS)

atr = ta.atr(14)
rsi = ta.rsi(close, 14)
histAbsAvg = ta.sma(math.abs(mHist), 50)
he50 = request.security(syminfo.tickerid, htfTf, ta.ema(close,50)[1],  barmerge.gaps_off, barmerge.lookahead_off)
he200= request.security(syminfo.tickerid, htfTf, ta.ema(close,200)[1], barmerge.gaps_off, barmerge.lookahead_off)
hc   = request.security(syminfo.tickerid, htfTf, close[1],             barmerge.gaps_off, barmerge.lookahead_off)
htfBull = hc > he200 and he50 > he200
htfBear = hc < he200 and he50 < he200

f_score(bool isLong) =>
    int sc = 0
    if useMom  and math.abs(mHist) > histAbsAvg
        sc += 1
    if useSlope and (isLong ? emaF > emaF[2] : emaF < emaF[2])
        sc += 1
    if useHtf  and (isLong ? htfBull : htfBear)
        sc += 1
    if useExt  and math.abs(close - emaS) < extMult * atr
        sc += 1
    if useRsi  and (isLong ? rsi < rsiOB : rsi > rsiOS)
        sc += 1
    sc

longSig  = xUp and f_score(true)  >= minScore
shortSig = xDn and f_score(false) >= minScore

// ---------------- Premium visuals ----------------
// palette (cyber aqua / hot magenta / premium gold)
color C_BULL = #00E5FF
color C_BEAR = #FF2E63
color C_GOLD = #F5BE50
color C_INK  = #0A0E14

emaUp = emaF > emaS
// glow layer under the slow EMA
plot(emaS, "EMA glow", color = color.new(C_GOLD, 82), linewidth = 8)
pF = plot(emaF, "EMA fast", color = color.new(emaUp ? C_BULL : C_BEAR, 0), linewidth = 2)
pS = plot(emaS, "EMA slow", color = color.new(C_GOLD, 0), linewidth = 3)
// gradient cloud between the EMAs
fill(pF, pS, emaF, emaS, color.new(emaUp ? C_BULL : C_BEAR, 65), color.new(emaUp ? C_BULL : C_BEAR, 94), title = "Cloud")
// subtle regime tint as background
bgcolor(color.new(emaUp ? C_BULL : C_BEAR, 95))

off = atr * 0.9

// ---------------- Signal labels (LONG/SHORT bubbles) ----------------
color C_LONG  = #00E676
color C_SHORT = #FF1744
labelSize = input.string("large", "Label size", options = ["small","normal","large","huge"], group = "04 Visuals")
bubSize = labelSize == "huge" ? size.huge : labelSize == "large" ? size.large : labelSize == "normal" ? size.normal : size.small

if longSig
    label.new(bar_index, low - off, "LONG", style = label.style_label_up, color = C_LONG, textcolor = C_INK, size = bubSize)
if shortSig
    label.new(bar_index, high + off, "SHORT", style = label.style_label_down, color = C_SHORT, textcolor = color.white, size = bubSize)

// ---------------- Level zones ----------------
gSR = "05 Level zones"
showKeys = input.bool(true, "Previous day/week range as background zone", group = gSR)

// previous day/week high-low
pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)
pwh = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1],  barmerge.gaps_off, barmerge.lookahead_off)
// drawn as a soft background band (no lines)
pdhP = plot(showKeys ? pdh : na, "pdh", color = na, display = display.none)
pdlP = plot(showKeys ? pdl : na, "pdl", color = na, display = display.none)
pwhP = plot(showKeys ? pwh : na, "pwh", color = na, display = display.none)
pwlP = plot(showKeys ? pwl : na, "pwl", color = na, display = display.none)
fill(pwhP, pwlP, color = showKeys ? color.new(C_GOLD, 94) : na, title = "Week zone")
fill(pdhP, pdlP, color = showKeys ? color.new(C_GOLD, 90) : na, title = "Day zone")

// ---------------- Alerts ----------------
alertcondition(longSig,  "MC long",  "Momentum Conviction LONG on {{ticker}} {{interval}} @ {{close}}")
alertcondition(shortSig, "MC short", "Momentum Conviction SHORT on {{ticker}} {{interval}} @ {{close}}")
````
