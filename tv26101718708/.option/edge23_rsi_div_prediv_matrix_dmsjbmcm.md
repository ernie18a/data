# EDGE2.3 RSI DIV PRE-DIV MATRIX

- url: https://www.tradingview.com/script/dmsjbMcm-EDGE2-3-RSI-DIV-PRE-DIV-MATRIX/
- type: indicator
- pine_id: PUB;21c50b5e1bdb48c1968558391d06261e
- version: 1.0

## Description

EDGE 2.3 RSI DIV PRE-DIV MATRIX

EDGE 2.3 RSI DIV PRE-DIV MATRIX is a multi-asset, multi-timeframe scanner built around RSI exhaustion, divergence detection, and pre-divergence pressure analysis.

This script is designed to help traders spot instruments that are not only already diverging, but also those that may be approaching divergence conditions before a full signal appears.

Instead of analyzing only one chart, the script scans a group of markets and shows their current state in a matrix table, making it easier to compare relative strength and weakness across assets and timeframes.

Core idea

Most indicators only react after a signal is already obvious.

This script tries to go one step earlier.

It combines three layers:

RSI extreme location
confirmed RSI divergence
pre-divergence exhaustion score

That means it can classify an instrument not only as “already diverging,” but also as:

merely stretched,
starting to weaken,
entering pre-divergence conditions,
or already producing a stronger divergence-based reversal setup.
What the script scans

The script monitors multiple instruments at once, including:

Natural Gas
WTI
Brent
Cocoa
US30
US500
UK100
CAC40
EURUSD
USDCAD

For each one, it checks four timeframes:

15m
H1
H4
D

All results are displayed in a matrix table in the top-right corner.

Main building blocks
1. RSI engine

The script starts with RSI as the base momentum tool.

It defines two key RSI zones:

Overbought
Oversold

These zones are used as the first filter for potential reversal pressure.

If RSI is high enough, the script starts looking for bearish conditions.
If RSI is low enough, it starts looking for bullish conditions.

2. Divergence engine

The divergence engine tracks whether price is making a new extreme while RSI is failing to confirm it.

Bearish divergence logic

A bearish raw divergence appears when:

RSI is in overbought territory,
price makes a higher high,
but RSI does not make a higher high.
Bullish divergence logic

A bullish raw divergence appears when:

RSI is in oversold territory,
price makes a lower low,
but RSI does not make a lower low.

The script does not stop at one raw divergence.
It counts how many such events occurred within the lookback window.

Only after at least 3 divergence events does it classify the condition as a stronger confirmed divergence state.

This is important because it reduces noise and avoids treating every single mismatch between price and RSI as equally meaningful.

3. Pre-divergence score engine

This is one of the most distinctive parts of the script.

The script tries to measure whether a market is losing force before divergence fully appears.

It does this by combining several exhaustion-style clues into a score.

Inputs used in the pre-divergence score

The score considers:

Body compression
Recent candle bodies are compared against older bodies to see whether momentum is shrinking.
Price continuation with weaker internals
Price may still be pushing higher or lower, but the internals start weakening.
Volume divergence
Price continues moving, but volume is weaker than before.
RSI weakening
RSI is still elevated or depressed, but its rate of change is weakening.
MACD histogram weakening
Momentum may still exist, but the histogram begins fading.
ATR flattening
Volatility expansion starts slowing down.
Distance from EMA
Price becomes stretched away from the 50 EMA, which can suggest reduced sustainability.
Weak follow-through after impulse
Price had a prior impulsive move, but current progress is weak.
Relative volume fade after a spike
Participation cools off after a stronger earlier push.

Each of these pieces contributes points to either a bearish pre-divergence score or a bullish pre-divergence score.

Why this matters

A regular divergence indicator usually tells you:

“Divergence is here.”

This script also tries to tell you:

“The market is starting to behave like divergence may be coming soon.”

That makes the script useful not only for confirmation, but also for watchlist preparation and early market screening.

Signal hierarchy

The script converts all this logic into a ranked signal system.

Each instrument/timeframe gets one signal state:

Signal levels

5 Strong

strongest bullish or bearish condition
RSI extreme plus confirmed divergence

4 Diverg

confirmed divergence is present

3 PreDiv

strong pre-divergence score is active

2 Exhaust

watch-level exhaustion / weakening is active

1 RSI

only RSI extreme is present

NONE

no relevant condition at the moment

These states are directional:

bullish states are shown in green-style colors
bearish states are shown in red/orange-style colors

So the table gives both:

strength
direction
Visual design of the matrix

The matrix is intentionally compact and color-coded.

Header row

The top row shows the names of all scanned instruments.

Left column

The first column shows the timeframe:

15
H1
H4
D
Inner cells

Each cell displays the current state text, such as:

5 Strong
4 Diverg
3 PreDiv
2 Exhaust
1 RSI
NONE

Each cell also has a matching background and text color based on the signal type.

This makes the scanner readable at a glance:

strong bullish conditions stand out in brighter green tones
strong bearish conditions stand out in brighter red/orange tones
weaker or neutral states fade into darker tones
Current chart RSI panel

Besides the matrix scanner, the script also plots RSI for the current chart.

It adds:

layered RSI plotting for a neon-style appearance,
overbought line,
oversold line,
middle line at 50.

So even though the main strength of the script is the scanner table, the current chart still keeps a live RSI reference.

How to interpret the matrix

A simple reading model:

1. RSI only

If a cell says 1 RSI, the market is stretched, but there is no deeper confirmation yet.

This is only an alert to pay attention.

2. Exhaust

If a cell says 2 Exhaust, the market is beginning to lose efficiency internally.

This means the move may be weakening, but divergence is not fully formed yet.

3. PreDiv

If a cell says 3 PreDiv, the script sees stronger internal evidence that a divergence-style condition may be developing.

This is often a more interesting watchlist stage.

4. Diverg

If a cell says 4 Diverg, confirmed divergence logic has already been reached.

This means the mismatch between price and momentum is no longer just a suspicion.

5. Strong

If a cell says 5 Strong, the script sees the strongest alignment:
RSI extreme plus confirmed divergence.

This is the most advanced state in the hierarchy.

Practical use cases

This script can be used in several ways.

Market scanner

You can use it as a dashboard to find which instruments are becoming technically interesting right now.

Cross-market comparison

Because it scans multiple asset classes, it helps compare:

energy
commodities
indices
FX
Reversal preparation

The pre-divergence score is useful for spotting markets that are not yet reversing, but are beginning to show internal weakness.

Timeframe stacking

When the same instrument starts showing stronger states on multiple timeframes, it may deserve closer attention.

For example:

15m = Exhaust
H1 = PreDiv
H4 = Diverg

That kind of progression can be much more useful than looking at one timeframe in isolation.

Strengths of this script
1. It is not limited to plain RSI extremes

A lot of scripts stop at overbought/oversold.
This one goes deeper.

2. It distinguishes early weakness from confirmed divergence

That gives a more nuanced market read.

3. It is multi-asset and multi-timeframe

This makes it practical as a scanner, not just a single-chart tool.

4. It blends momentum, volatility, structure, and participation clues

The pre-divergence engine uses more than one idea, which helps reduce simplistic interpretation.

5. It is visually fast to read

The matrix format is efficient for broad market review.

Things to keep in mind

This script is still a context tool, not a guarantee engine.

It does not promise reversals.
It does not replace execution rules.
It does not replace risk management.

A strong state in the matrix means:

the market is technically interesting,
pressure may be building,
and more detailed chart review may be justified.

But it should still be combined with:

price structure,
risk planning,
trade management,
and broader market context.
In plain English

If explained very simply:

This script asks:

“Is this market only stretched, or is it actually starting to weaken under the surface?”

And then it ranks that answer from:

mild RSI pressure,
to early exhaustion,
to pre-divergence,
to confirmed divergence,
to strongest divergence condition.

It does this across several instruments and several timeframes at once.

Short summary

EDGE2.3 RSI DIV PRE-DIV MATRIX is a market scanner that combines:

RSI extremes
divergence logic
pre-divergence scoring
multi-asset scanning
multi-timeframe matrix visualization

## Source Code

````pine
//@version=5
indicator("EDGE2.3 RSI DIV PRE-DIV MATRIX", overlay=false)

// INPUTS
rsiLength = input.int(14, "RSI Length")
overboughtLevel = input.int(72, "Overbought Level")
oversoldLevel = input.int(28, "Oversold Level")
lookbackBars = input.int(84, "Divergence Lookback", minval=5)

preLookback = input.int(5, "Pre-Div Lookback", minval=2)
preWatchLevel = input.int(35, "Pre-Div Exhaust Score", minval=1, maxval=100)
preStrongLevel = input.int(55, "Pre-Div Strong Score", minval=1, maxval=100)

emaLen = input.int(50, "EMA Length")
atrLen = input.int(14, "ATR Length")
volLen = input.int(20, "Volume Avg Length")

macdFast = input.int(12, "MACD Fast")
macdSlow = input.int(26, "MACD Slow")
macdSignal = input.int(9, "MACD Signal")

// SYMBOLS
symbolNG = input.symbol("NYMEX:NG1!", "NG")
symbolWTI = input.symbol("TVC:USOIL", "WTI")
symbolBrent = input.symbol("TVC:UKOIL", "Brent")
symbolCocoa = input.symbol("ICEUS:CC1!", "Cocoa")
symbolUS30 = input.symbol("OANDA:US30USD", "US30")
symbolUS500 = input.symbol("OANDA:SPX500USD", "US500")
symbolUK100 = input.symbol("OANDA:UK100GBP", "UK100")
symbolCAC40 = input.symbol("OANDA:FR40EUR", "CAC40")
symbolEURUSD = input.symbol("OANDA:EURUSD", "EURUSD")
symbolUSDCAD = input.symbol("OANDA:USDCAD", "USDCAD")

nameNG = input.string("NG", "NG Name")
nameWTI = input.string("WTI", "WTI Name")
nameBrent = input.string("Brent", "Brent Name")
nameCocoa = input.string("Cocoa", "Cocoa Name")
nameUS30 = input.string("US30", "US30 Name")
nameUS500 = input.string("US500", "US500 Name")
nameUK100 = input.string("UK100", "UK100 Name")
nameCAC40 = input.string("CAC40", "CAC40 Name")
nameEURUSD = input.string("EURUSD", "EURUSD Name")
nameUSDCAD = input.string("USDCAD", "USDCAD Name")

tf1 = input.timeframe("15", "TF 1")
tf2 = input.timeframe("60", "TF 2")
tf3 = input.timeframe("240", "TF 3")
tf4 = input.timeframe("D", "TF 4")

tf1Label = "15"
tf2Label = "H1"
tf3Label = "H4"
tf4Label = "D"

// COLORS
neonBlue = color.rgb(120, 220, 255)
headerBg = color.rgb(8, 10, 18)
cellBg = color.rgb(12, 16, 26)

noneBg = color.rgb(8, 10, 16)
noneText = color.rgb(55, 80, 100)

bullRsiBg = color.rgb(6, 30, 26)
bullWatchBg = color.rgb(7, 38, 31)
bullPreBg = color.rgb(5, 50, 38)
bullDivBg = color.rgb(0, 115, 78)
strongBuyBg = color.rgb(0, 190, 115)

bullRsiText = color.rgb(90, 150, 128)
bullWatchText = color.rgb(105, 170, 145)
bullPreText = color.rgb(125, 195, 165)
bullDivText = color.rgb(215, 255, 235)
strongBuyText = color.rgb(245, 255, 248)

bearRsiBg = color.rgb(34, 22, 13)
bearWatchBg = color.rgb(45, 25, 12)
bearPreBg = color.rgb(62, 30, 10)
bearDivBg = color.rgb(145, 45, 28)
strongSellBg = color.rgb(220, 55, 35)

bearRsiText = color.rgb(150, 110, 80)
bearWatchText = color.rgb(175, 120, 82)
bearPreText = color.rgb(205, 145, 95)
bearDivText = color.rgb(255, 220, 205)
strongSellText = color.rgb(255, 245, 235)

// DIVERGENCE ENGINE
f_divEngine() =>
    _rsi = ta.rsi(close, rsiLength)

    var float _prevHigh = na
    var float _prevRsiH = na
    var int _prevBarHigh = na

    _inOB = _rsi > overboughtLevel
    _rawSell = _inOB and not na(_prevHigh) and high > _prevHigh and _rsi < _prevRsiH

    _sellCount = 0
    for i = 0 to lookbackBars - 1
        _sellCount += _rawSell[i] ? 1 : 0

    _bearDiv = _rawSell and _sellCount >= 3

    if _inOB
        if na(_prevHigh)
            _prevHigh := high
            _prevRsiH := _rsi
            _prevBarHigh := bar_index
        else
            if _rsi > _prevRsiH
                _prevHigh := high
                _prevRsiH := _rsi
                _prevBarHigh := bar_index

    if not na(_prevBarHigh) and bar_index - _prevBarHigh > lookbackBars
        _prevHigh := na
        _prevRsiH := na
        _prevBarHigh := na

    var float _prevLow = na
    var float _prevRsiL = na
    var int _prevBarLow = na

    _inOS = _rsi < oversoldLevel
    _rawBuy = _inOS and not na(_prevLow) and low < _prevLow and _rsi > _prevRsiL

    _buyCount = 0
    for i = 0 to lookbackBars - 1
        _buyCount += _rawBuy[i] ? 1 : 0

    _bullDiv = _rawBuy and _buyCount >= 3

    if _inOS
        if na(_prevLow)
            _prevLow := low
            _prevRsiL := _rsi
            _prevBarLow := bar_index
        else
            if _rsi < _prevRsiL
                _prevLow := low
                _prevRsiL := _rsi
                _prevBarLow := bar_index

    if not na(_prevBarLow) and bar_index - _prevBarLow > lookbackBars
        _prevLow := na
        _prevRsiL := na
        _prevBarLow := na

    [_rsi, _rawSell, _rawBuy, _bearDiv, _bullDiv]

// PRE-DIV SCORE ENGINE
f_preDivScore(_rsi) =>
    _body = math.abs(close - open)
    _bodyNow = ta.sma(_body, 3)
    _bodyPrev = ta.sma(_body[preLookback], 3)
    _bodyCompression = _bodyNow < _bodyPrev

    _priceUp = high > high[preLookback]
    _priceDown = low < low[preLookback]

    _volumeDivBear = _priceUp and volume < volume[preLookback]
    _volumeDivBull = _priceDown and volume < volume[preLookback]

    _rsiDelta = _rsi - _rsi[1]
    _rsiDeltaPrev = _rsi[1] - _rsi[2]
    _rsiWeakBear = _rsi > 65 and _rsiDelta < _rsiDeltaPrev
    _rsiWeakBull = _rsi < 35 and _rsiDelta > _rsiDeltaPrev

    [_macdLine, _signalLine, _macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)
    _macdWeakBear = _macdHist < _macdHist[1]
    _macdWeakBull = _macdHist > _macdHist[1]

    _atr = ta.atr(atrLen)
    _atrFlat = _atr <= _atr[1]

    _ema = ta.ema(close, emaLen)
    _emaDistance = _atr > 0 ? math.abs(close - _ema) / _atr : 0.0
    _farFromEma = _emaDistance > 1.5

    _progressUp = high - high[preLookback]
    _progressDown = low[preLookback] - low
    _weakProgressUp = _progressUp > 0 and _progressUp < _atr
    _weakProgressDown = _progressDown > 0 and _progressDown < _atr

    _emaStallBear = close > _ema and _farFromEma and _weakProgressUp
    _emaStallBull = close < _ema and _farFromEma and _weakProgressDown

    _volAvg = ta.sma(volume, volLen)
    _relVol = _volAvg > 0 ? volume / _volAvg : 0.0
    _hadVolSpike = ta.highest(_relVol, preLookback) > 1.8
    _relVolFade = _hadVolSpike and _relVol < 1.0

    _impulseUp = close[preLookback] > close[preLookback * 2] and close[preLookback] - close[preLookback * 2] > _atr[preLookback] * 2
    _impulseDown = close[preLookback] < close[preLookback * 2] and close[preLookback * 2] - close[preLookback] > _atr[preLookback] * 2

    _failedHigh = _impulseUp and high <= ta.highest(high, preLookback)[1]
    _failedLow = _impulseDown and low >= ta.lowest(low, preLookback)[1]

    _bearScore = 0
    _bearScore += _priceUp and _bodyCompression ? 10 : 0
    _bearScore += _volumeDivBear ? 15 : 0
    _bearScore += _rsiWeakBear ? 15 : 0
    _bearScore += _macdWeakBear ? 15 : 0
    _bearScore += _priceUp and _atrFlat ? 10 : 0
    _bearScore += _emaStallBear ? 10 : 0
    _bearScore += _relVolFade ? 10 : 0
    _bearScore += _failedHigh ? 10 : 0

    _bullScore = 0
    _bullScore += _priceDown and _bodyCompression ? 10 : 0
    _bullScore += _volumeDivBull ? 15 : 0
    _bullScore += _rsiWeakBull ? 15 : 0
    _bullScore += _macdWeakBull ? 15 : 0
    _bullScore += _priceDown and _atrFlat ? 10 : 0
    _bullScore += _emaStallBull ? 10 : 0
    _bullScore += _relVolFade ? 10 : 0
    _bullScore += _failedLow ? 10 : 0

    [_bearScore, _bullScore]

// SIGNAL ENGINE
//  1 = green 5 Strong
// -1 = red   5 Strong
//  3 = green 4 Diverg
// -3 = red   4 Diverg
//  4 = green 3 PreDiv
// -4 = red   3 PreDiv
//  5 = green 2 Exhaust
// -5 = red   2 Exhaust
//  2 = green 1 RSI
// -2 = red   1 RSI
//  0 = NONE
f_signalEngine() =>
    [_rsi, _rawSell, _rawBuy, _bearDiv, _bullDiv] = f_divEngine()
    [_bearScore, _bullScore] = f_preDivScore(_rsi)

    _rsiOversold = _rsi < oversoldLevel
    _rsiOverbought = _rsi > overboughtLevel

    _buySignal = _rsiOversold and _bullDiv
    _sellSignal = _rsiOverbought and _bearDiv

    _strongBullPre = _bullScore >= preStrongLevel and _bullScore > _bearScore
    _strongBearPre = _bearScore >= preStrongLevel and _bearScore > _bullScore
    _watchBullPre = _bullScore >= preWatchLevel and _bullScore > _bearScore
    _watchBearPre = _bearScore >= preWatchLevel and _bearScore > _bullScore

    _signal = _buySignal ? 1 : _sellSignal ? -1 : _bullDiv ? 3 : _bearDiv ? -3 : _strongBullPre ? 4 : _strongBearPre ? -4 : _watchBullPre ? 5 : _watchBearPre ? -5 : _rsiOversold ? 2 : _rsiOverbought ? -2 : 0
    [_signal, _rsi]

f_scanSignal() =>
    [_signal, _rsi] = f_signalEngine()
    _signal

// CURRENT CHART RSI VISUAL ONLY
[currentSignal, rsi] = f_signalEngine()

// REQUESTS: NG
ngTf1 = request.security(symbolNG, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
ngTf2 = request.security(symbolNG, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
ngTf3 = request.security(symbolNG, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
ngTf4 = request.security(symbolNG, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: WTI
wtiTf1 = request.security(symbolWTI, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
wtiTf2 = request.security(symbolWTI, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
wtiTf3 = request.security(symbolWTI, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
wtiTf4 = request.security(symbolWTI, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: BRENT
brentTf1 = request.security(symbolBrent, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
brentTf2 = request.security(symbolBrent, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
brentTf3 = request.security(symbolBrent, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
brentTf4 = request.security(symbolBrent, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: COCOA
cocoaTf1 = request.security(symbolCocoa, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
cocoaTf2 = request.security(symbolCocoa, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
cocoaTf3 = request.security(symbolCocoa, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
cocoaTf4 = request.security(symbolCocoa, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: US30
us30Tf1 = request.security(symbolUS30, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
us30Tf2 = request.security(symbolUS30, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
us30Tf3 = request.security(symbolUS30, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
us30Tf4 = request.security(symbolUS30, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: US500
us500Tf1 = request.security(symbolUS500, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
us500Tf2 = request.security(symbolUS500, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
us500Tf3 = request.security(symbolUS500, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
us500Tf4 = request.security(symbolUS500, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: UK100
uk100Tf1 = request.security(symbolUK100, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
uk100Tf2 = request.security(symbolUK100, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
uk100Tf3 = request.security(symbolUK100, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
uk100Tf4 = request.security(symbolUK100, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: CAC40
cac40Tf1 = request.security(symbolCAC40, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
cac40Tf2 = request.security(symbolCAC40, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
cac40Tf3 = request.security(symbolCAC40, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
cac40Tf4 = request.security(symbolCAC40, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: EURUSD
eurusdTf1 = request.security(symbolEURUSD, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
eurusdTf2 = request.security(symbolEURUSD, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
eurusdTf3 = request.security(symbolEURUSD, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
eurusdTf4 = request.security(symbolEURUSD, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// REQUESTS: USDCAD
usdcadTf1 = request.security(symbolUSDCAD, tf1, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
usdcadTf2 = request.security(symbolUSDCAD, tf2, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
usdcadTf3 = request.security(symbolUSDCAD, tf3, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)
usdcadTf4 = request.security(symbolUSDCAD, tf4, f_scanSignal(), barmerge.gaps_off, barmerge.lookahead_off)

// TABLE HELPERS
f_sigText(sig) =>
    sig == 1 or sig == -1 ? "5 Strong" : sig == 3 or sig == -3 ? "4 Diverg" : sig == 4 or sig == -4 ? "3 PreDiv" : sig == 5 or sig == -5 ? "2 Exhaust" : sig == 2 or sig == -2 ? "1 RSI" : "NONE"

f_sigBg(sig) =>
    sig == 1 ? strongBuyBg : sig == -1 ? strongSellBg : sig == 3 ? bullDivBg : sig == -3 ? bearDivBg : sig == 4 ? bullPreBg : sig == -4 ? bearPreBg : sig == 5 ? bullWatchBg : sig == -5 ? bearWatchBg : sig == 2 ? bullRsiBg : sig == -2 ? bearRsiBg : noneBg

f_sigTextColor(sig) =>
    sig == 1 ? strongBuyText : sig == -1 ? strongSellText : sig == 3 ? bullDivText : sig == -3 ? bearDivText : sig == 4 ? bullPreText : sig == -4 ? bearPreText : sig == 5 ? bullWatchText : sig == -5 ? bearWatchText : sig == 2 ? bullRsiText : sig == -2 ? bearRsiText : noneText

// SECONDARY RSI VISUAL
plot(rsi, color=color.new(neonBlue, 88), linewidth=8)
plot(rsi, color=color.new(neonBlue, 76), linewidth=5)
plot(rsi, color=neonBlue, linewidth=1)

hline(overboughtLevel, "Overbought", color=color.new(neonBlue, 80))
hline(oversoldLevel, "Oversold", color=color.new(neonBlue, 80))
hline(50, "Middle", color=color.new(color.gray, 88))

// TABLE
var table scannerTbl = table.new(position.top_right, 12, 5, border_width=2)

f_cell(_tbl, _col, _row, _txt, _bg, _tc) =>
    table.cell(_tbl, _col, _row, _txt, text_color=_tc, bgcolor=_bg)

f_spacer(_tbl, _col, _row) =>
    table.cell(_tbl, _col, _row, " ", text_color=noneText, bgcolor=noneBg, width=8)

if barstate.islast
    f_cell(scannerTbl, 0, 0, "TF", headerBg, color.white)
    f_cell(scannerTbl, 1, 0, nameNG, headerBg, neonBlue)
    f_cell(scannerTbl, 2, 0, nameWTI, headerBg, neonBlue)
    f_cell(scannerTbl, 3, 0, nameBrent, headerBg, neonBlue)
    f_cell(scannerTbl, 4, 0, nameCocoa, headerBg, neonBlue)
    f_cell(scannerTbl, 5, 0, nameUS30, headerBg, neonBlue)
    f_cell(scannerTbl, 6, 0, nameUS500, headerBg, neonBlue)
    f_cell(scannerTbl, 7, 0, nameUK100, headerBg, neonBlue)
    f_cell(scannerTbl, 8, 0, nameCAC40, headerBg, neonBlue)
    f_cell(scannerTbl, 9, 0, nameEURUSD, headerBg, neonBlue)
    f_cell(scannerTbl, 10, 0, nameUSDCAD, headerBg, neonBlue)
    f_spacer(scannerTbl, 11, 0)

    f_cell(scannerTbl, 0, 1, tf1Label, cellBg, neonBlue)
    f_cell(scannerTbl, 1, 1, f_sigText(ngTf1), f_sigBg(ngTf1), f_sigTextColor(ngTf1))
    f_cell(scannerTbl, 2, 1, f_sigText(wtiTf1), f_sigBg(wtiTf1), f_sigTextColor(wtiTf1))
    f_cell(scannerTbl, 3, 1, f_sigText(brentTf1), f_sigBg(brentTf1), f_sigTextColor(brentTf1))
    f_cell(scannerTbl, 4, 1, f_sigText(cocoaTf1), f_sigBg(cocoaTf1), f_sigTextColor(cocoaTf1))
    f_cell(scannerTbl, 5, 1, f_sigText(us30Tf1), f_sigBg(us30Tf1), f_sigTextColor(us30Tf1))
    f_cell(scannerTbl, 6, 1, f_sigText(us500Tf1), f_sigBg(us500Tf1), f_sigTextColor(us500Tf1))
    f_cell(scannerTbl, 7, 1, f_sigText(uk100Tf1), f_sigBg(uk100Tf1), f_sigTextColor(uk100Tf1))
    f_cell(scannerTbl, 8, 1, f_sigText(cac40Tf1), f_sigBg(cac40Tf1), f_sigTextColor(cac40Tf1))
    f_cell(scannerTbl, 9, 1, f_sigText(eurusdTf1), f_sigBg(eurusdTf1), f_sigTextColor(eurusdTf1))
    f_cell(scannerTbl, 10, 1, f_sigText(usdcadTf1), f_sigBg(usdcadTf1), f_sigTextColor(usdcadTf1))
    f_spacer(scannerTbl, 11, 1)

    f_cell(scannerTbl, 0, 2, tf2Label, cellBg, neonBlue)
    f_cell(scannerTbl, 1, 2, f_sigText(ngTf2), f_sigBg(ngTf2), f_sigTextColor(ngTf2))
    f_cell(scannerTbl, 2, 2, f_sigText(wtiTf2), f_sigBg(wtiTf2), f_sigTextColor(wtiTf2))
    f_cell(scannerTbl, 3, 2, f_sigText(brentTf2), f_sigBg(brentTf2), f_sigTextColor(brentTf2))
    f_cell(scannerTbl, 4, 2, f_sigText(cocoaTf2), f_sigBg(cocoaTf2), f_sigTextColor(cocoaTf2))
    f_cell(scannerTbl, 5, 2, f_sigText(us30Tf2), f_sigBg(us30Tf2), f_sigTextColor(us30Tf2))
    f_cell(scannerTbl, 6, 2, f_sigText(us500Tf2), f_sigBg(us500Tf2), f_sigTextColor(us500Tf2))
    f_cell(scannerTbl, 7, 2, f_sigText(uk100Tf2), f_sigBg(uk100Tf2), f_sigTextColor(uk100Tf2))
    f_cell(scannerTbl, 8, 2, f_sigText(cac40Tf2), f_sigBg(cac40Tf2), f_sigTextColor(cac40Tf2))
    f_cell(scannerTbl, 9, 2, f_sigText(eurusdTf2), f_sigBg(eurusdTf2), f_sigTextColor(eurusdTf2))
    f_cell(scannerTbl, 10, 2, f_sigText(usdcadTf2), f_sigBg(usdcadTf2), f_sigTextColor(usdcadTf2))
    f_spacer(scannerTbl, 11, 2)

    f_cell(scannerTbl, 0, 3, tf3Label, cellBg, neonBlue)
    f_cell(scannerTbl, 1, 3, f_sigText(ngTf3), f_sigBg(ngTf3), f_sigTextColor(ngTf3))
    f_cell(scannerTbl, 2, 3, f_sigText(wtiTf3), f_sigBg(wtiTf3), f_sigTextColor(wtiTf3))
    f_cell(scannerTbl, 3, 3, f_sigText(brentTf3), f_sigBg(brentTf3), f_sigTextColor(brentTf3))
    f_cell(scannerTbl, 4, 3, f_sigText(cocoaTf3), f_sigBg(cocoaTf3), f_sigTextColor(cocoaTf3))
    f_cell(scannerTbl, 5, 3, f_sigText(us30Tf3), f_sigBg(us30Tf3), f_sigTextColor(us30Tf3))
    f_cell(scannerTbl, 6, 3, f_sigText(us500Tf3), f_sigBg(us500Tf3), f_sigTextColor(us500Tf3))
    f_cell(scannerTbl, 7, 3, f_sigText(uk100Tf3), f_sigBg(uk100Tf3), f_sigTextColor(uk100Tf3))
    f_cell(scannerTbl, 8, 3, f_sigText(cac40Tf3), f_sigBg(cac40Tf3), f_sigTextColor(cac40Tf3))
    f_cell(scannerTbl, 9, 3, f_sigText(eurusdTf3), f_sigBg(eurusdTf3), f_sigTextColor(eurusdTf3))
    f_cell(scannerTbl, 10, 3, f_sigText(usdcadTf3), f_sigBg(usdcadTf3), f_sigTextColor(usdcadTf3))
    f_spacer(scannerTbl, 11, 3)

    f_cell(scannerTbl, 0, 4, tf4Label, cellBg, neonBlue)
    f_cell(scannerTbl, 1, 4, f_sigText(ngTf4), f_sigBg(ngTf4), f_sigTextColor(ngTf4))
    f_cell(scannerTbl, 2, 4, f_sigText(wtiTf4), f_sigBg(wtiTf4), f_sigTextColor(wtiTf4))
    f_cell(scannerTbl, 3, 4, f_sigText(brentTf4), f_sigBg(brentTf4), f_sigTextColor(brentTf4))
    f_cell(scannerTbl, 4, 4, f_sigText(cocoaTf4), f_sigBg(cocoaTf4), f_sigTextColor(cocoaTf4))
    f_cell(scannerTbl, 5, 4, f_sigText(us30Tf4), f_sigBg(us30Tf4), f_sigTextColor(us30Tf4))
    f_cell(scannerTbl, 6, 4, f_sigText(us500Tf4), f_sigBg(us500Tf4), f_sigTextColor(us500Tf4))
    f_cell(scannerTbl, 7, 4, f_sigText(uk100Tf4), f_sigBg(uk100Tf4), f_sigTextColor(uk100Tf4))
    f_cell(scannerTbl, 8, 4, f_sigText(cac40Tf4), f_sigBg(cac40Tf4), f_sigTextColor(cac40Tf4))
    f_cell(scannerTbl, 9, 4, f_sigText(eurusdTf4), f_sigBg(eurusdTf4), f_sigTextColor(eurusdTf4))
    f_cell(scannerTbl, 10, 4, f_sigText(usdcadTf4), f_sigBg(usdcadTf4), f_sigTextColor(usdcadTf4))
    f_spacer(scannerTbl, 11, 4)
````
