# Svopex Pullback Level

- url: https://www.tradingview.com/script/EwZMT1QF-Svopex-Pullback-Level/
- type: indicator
- pine_id: PUB;ec125d255ece45ffaee6438788d9611a
- version: 1.0

## Description

Svopex Pullback Level
  
  A pullback-break indicator that detects valid retracement levels using body-based pivot logic and confirms breakouts with higher-timeframe RSI momentum
  confluence. Designed to mark the precise body extreme where a counter-trend move began — and signal when the original trend resumes.

  What it does

  When price makes a new N-bar low with a red body and the next bar closes green, the indicator walks back through the consecutive red candles and draws a
  horizontal line at the highest body of that down-move — your short pullback level. The mirror logic plots a long pullback level at the lowest body of an
  up-move that just printed a new N-bar high.

  A break of the level (body close beyond it) closes the line and optionally triggers a confluence signal:

  - Bullish break of a short level + HTF RSI ≥ HTF RSI-SMA → green dot below the bar + alert
  - Bearish break of a long level + HTF RSI ≤ HTF RSI-SMA → red dot above the bar + alert

  This filters out countertrend breakouts that happen against higher-timeframe momentum.

  Why body extremes (not wicks)

  Wick-based pivot levels are noisy — they reset on every false sweep. By tracking only candle bodies, the indicator captures the decision points where the move
   actually consolidated, producing levels that act as cleaner support/resistance.

  Inputs

  Detection

  - Lookback for new low/high (bars) — how many bars back must be cleared to qualify (default 20)
  - Max bars for walk-back — cap on how far the body-walk searches for the move's origin (default 50)
  - Detect short levels — toggle pullback levels from down-moves
  - Detect long levels — toggle pullback levels from up-moves

  Style

  - Short level color / Long level color — independent color pickers
  - Line width — 1 to 4

  RSI confluence (HTF)

  - Mark break + HTF RSI vs SMA filter — master toggle for the confluence dots and alerts
  - HTF multiplier — higher timeframe = current TF × multiplier (default 2× — e.g., 1H chart → 2H RSI)
  - RSI length — default 14
  - RSI SMA length — default 14 (the trigger line)
  - Bullish / Bearish confluence colors — independent

  Outputs

  - Horizontal lines at every pullback level until it breaks
  - Green circles below the bar on bullish confluence breakouts
  - Red circles above the bar on bearish confluence breakouts
  - Alerts with full context: ticker, timeframe, break price, level price, HTF RSI value, HTF RSI-SMA value

  How to use

  1. Trend trading — wait for a confluence dot to appear at a key support/resistance level (use higher-timeframe structure or your own zones). The HTF RSI
  filter ensures you're trading with momentum.
  2. Trade management — un-broken pullback levels often act as targets for the next leg.
  3. Pullback entries — when price retraces into a fresh pullback level on a lower timeframe, you have a defined invalidation (the level itself) and a defined
  target (recent high/low).

  Tips

  - Tune lookback bars to your timeframe: shorter values (10–15) for scalping, longer (25–40) for swing.
  - The HTF multiplier of 2× is a balanced default; increase to 3–5 for stricter momentum filtering, decrease to 1.5 to keep the filter close to the trading TF.
  - Levels that get broken without confluence are still useful as price magnets — they just don't qualify as high-probability entries by this strategy.

  Credits

  Built by Svopex. Open source — fork and adapt.

## Source Code

````pine
//@version=5
indicator("Svopex Pullback Level", "Svp PL", overlay=true, max_lines_count=500)

// === Inputs ===
gDet = "Detekce"
lookbackBars = input.int(20, "Lookback pro nové low/high (bary)", minval=2, group=gDet)
maxWalk      = input.int(50, "Max bary pro walk-back", minval=2, maxval=200, group=gDet)
showShort    = input.bool(true, "Detekuj short úrovně (down moves)", group=gDet)
showLong     = input.bool(true, "Detekuj long úrovně (up moves)", group=gDet)

gSty = "Styl"
colShort = input.color(color.new(color.green, 20), "Barva short úrovně", group=gSty)
colLong  = input.color(color.new(color.red,   20), "Barva long úrovně", group=gSty)
lineW    = input.int(2, "Šířka linie", minval=1, maxval=4, group=gSty)

gRsi = "RSI confluence (HTF)"
useRsi       = input.bool(true, "Označit break + HTF RSI vs SMA filter", group=gRsi)
htfMult      = input.float(2, "HTF multiplier (X × current TF)", minval=1, maxval=30, group=gRsi)
rsiLength    = input.int(14, "RSI length", minval=1, group=gRsi)
smaLength    = input.int(14, "RSI SMA length", minval=1, group=gRsi)
colConfirmUp = input.color(color.green, "Barva bullish confluence (pod svíčkou)", group=gRsi)
colConfirmDn = input.color(color.red,   "Barva bearish confluence (nad svíčkou)", group=gRsi)

// === HTF resolution ===
f_minToTf(simple int m) =>
    string r = m < 1440 ? str.tostring(m) : m < 10080 ? str.tostring(m / 1440) + "D" : str.tostring(m / 10080) + "W"
    r

htfMinutes = math.max(1, math.round(timeframe.in_seconds(timeframe.period) * htfMult / 60))
htfTf      = f_minToTf(htfMinutes)

// === HTF RSI vs SMA ===
htfRsi      = request.security(syminfo.tickerid, htfTf, ta.rsi(close, rsiLength), lookahead=barmerge.lookahead_on)
htfRsiSma   = request.security(syminfo.tickerid, htfTf, ta.sma(ta.rsi(close, rsiLength), smaLength), lookahead=barmerge.lookahead_on)
htfRsiAbove = htfRsi >= htfRsiSma
htfRsiBelow = htfRsi <= htfRsiSma

// === Body helpers ===
isRedBody   = close < open
isGreenBody = close > open
bodyHi      = math.max(open, close)
bodyLo      = math.min(open, close)

lowestBodyLo  = ta.lowest(bodyLo,  lookbackBars)
highestBodyHi = ta.highest(bodyHi, lookbackBars)

f_walkBackRed(int start, int maxN) =>
    int last = start
    bool stop = false
    for j = start to start + maxN
        if not stop
            if close[j] < open[j]
                last := j
            else
                stop := true
    last

f_walkBackGreen(int start, int maxN) =>
    int last = start
    bool stop = false
    for j = start to start + maxN
        if not stop
            if close[j] > open[j]
                last := j
            else
                stop := true
    last

// === Per-bar signal flags ===
var bool confluenceBullSig = false
var bool confluenceBearSig = false
confluenceBullSig := false
confluenceBearSig := false

// === SHORT ===
var line  shortLn     = na
var float shortLvl    = na
var bool  shortActive = false

if barstate.isconfirmed and showShort and bar_index > lookbackBars
    priorRed    = close[1] < open[1]
    priorNewLow = bodyLo[1] < lowestBodyLo[2]
    currGreen   = close > open
    if priorRed and priorNewLow and currGreen
        oldestRed = f_walkBackRed(1, maxWalk)
        newLvl    = bodyHi[oldestRed]
        if not na(shortLn) and shortActive
            line.set_x2(shortLn, bar_index)
            line.set_extend(shortLn, extend.none)
        shortLvl    := newLvl
        shortActive := true
        shortLn     := line.new(bar_index - oldestRed, newLvl, bar_index + 1, newLvl, color=colShort, width=lineW, extend=extend.right)

if barstate.isconfirmed and shortActive and not na(shortLvl) and isGreenBody and bodyHi > shortLvl
    if useRsi and htfRsiAbove
        confluenceBullSig := true
        alert("BULL pullback break · " + syminfo.ticker + " " + timeframe.period + " · @ " + str.tostring(close, format.mintick) + " · level " + str.tostring(shortLvl, format.mintick) + " · HTF RSI " + str.tostring(htfRsi, "#.#") + " > SMA " + str.tostring(htfRsiSma, "#.#"), alert.freq_once_per_bar_close)
    if not na(shortLn)
        line.set_x2(shortLn, bar_index)
        line.set_extend(shortLn, extend.none)
    shortActive := false

// === LONG ===
var line  longLn     = na
var float longLvl    = na
var bool  longActive = false

if barstate.isconfirmed and showLong and bar_index > lookbackBars
    priorGreen   = close[1] > open[1]
    priorNewHigh = bodyHi[1] > highestBodyHi[2]
    currRed      = close < open
    if priorGreen and priorNewHigh and currRed
        oldestGreen = f_walkBackGreen(1, maxWalk)
        newLvl      = bodyLo[oldestGreen]
        if not na(longLn) and longActive
            line.set_x2(longLn, bar_index)
            line.set_extend(longLn, extend.none)
        longLvl    := newLvl
        longActive := true
        longLn     := line.new(bar_index - oldestGreen, newLvl, bar_index + 1, newLvl, color=colLong, width=lineW, extend=extend.right)

if barstate.isconfirmed and longActive and not na(longLvl) and isRedBody and bodyLo < longLvl
    if useRsi and htfRsiBelow
        confluenceBearSig := true
        alert("BEAR pullback break · " + syminfo.ticker + " " + timeframe.period + " · @ " + str.tostring(close, format.mintick) + " · level " + str.tostring(longLvl, format.mintick) + " · HTF RSI " + str.tostring(htfRsi, "#.#") + " < SMA " + str.tostring(htfRsiSma, "#.#"), alert.freq_once_per_bar_close)
    if not na(longLn)
        line.set_x2(longLn, bar_index)
        line.set_extend(longLn, extend.none)
    longActive := false

// === Confluence dots ===
plotshape(confluenceBullSig, title="Bull conf", style=shape.circle, location=location.belowbar, color=colConfirmUp, size=size.tiny)
plotshape(confluenceBearSig, title="Bear conf", style=shape.circle, location=location.abovebar, color=colConfirmDn, size=size.tiny)
````
