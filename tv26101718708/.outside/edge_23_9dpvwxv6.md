# Edge 2.3

- url: https://www.tradingview.com/script/9DPVWxV6-Edge-2-3/
- type: indicator
- pine_id: PUB;5a70404de9614965b0538db8f6f8387a
- version: 1.0

## Description

Edge 2.3

Edge 2.3 is a multi-instrument, multi-timeframe score scanner designed to help traders monitor RSI divergence, MFI divergence, volume exhaustion, volatility expansion, and overall reversal pressure across several major markets at the same time.

It combines:

RSI state
RSI divergence
MFI state
MFI divergence
Volume Exhaust
ATR volatility expansion
Multi-timeframe scoring
Multi-instrument monitoring
Hybrid Glass Gold dashboard
RSI visual zone colouring

The purpose is simple:

to help traders quickly identify where strong reversal conditions may be building across different instruments and timeframes without opening every chart manually.

What this indicator does

Edge 2.3 scans several instruments at once and displays a score for each instrument on several timeframes.

The dashboard currently monitors:

NG
WTI
Brent
Cocoa
US30
US500
UK100
CAC40

Timeframes used:

Current chart timeframe
15m
1H
4H
1D

Each cell in the table shows the current signal strength for that instrument and timeframe.

Main idea

Edge 2.3 is not a random buy or sell arrow system.

It is built as a market radar.

It helps answer:

Where is RSI showing divergence?
Where is MFI showing money-flow divergence?
Where is price showing volume exhaustion?
Where is volatility expanding?
Which instruments deserve attention first?
Which timeframes are showing stronger confluence?

Instead of watching one chart at a time, the trader can observe several markets and several timeframes in one compact visual dashboard.

Score system

The table uses a simple score from 0 to 4.

Score 0

No active setup.

There is no meaningful confluence at the moment.

Score 0 is intentionally very transparent so it does not distract the eye.

Score 1

One active factor.

This is an early warning, but usually not enough on its own.

Score 2

Two active factors.

The setup is becoming more interesting, but still requires confirmation from structure and price action.

Score 3

Strong signal.

Three factors are active.

This level deserves attention, especially on H1, H4, or 1D.

Score 4

Premium signal.

This is the strongest condition in this version.

It means several major components are aligning together:

RSI divergence
MFI divergence
Volume Exhaust
ATR extreme volatility

Score 4 does not mean automatic entry.

It means the instrument and timeframe should be checked immediately for market structure, key levels, liquidity, and risk/reward.

Direction

The dashboard shows direction through colour.

Green cells = bullish / buy-side pressure
Red cells = bearish / sell-side pressure
Gold/brown cells = mixed or conflicting pressure
Transparent dark cells = neutral or weak state

Score 3 and Score 4 are visually stronger than Score 1 and Score 2, making it easier to focus on the most important signals.

Main components

RSI divergence

RSI divergence helps identify moments when price makes a new extreme but momentum does not confirm that move.

Bullish RSI divergence:

price makes a lower low
RSI makes a higher low
RSI is in oversold territory

Bearish RSI divergence:

price makes a higher high
RSI makes a lower high
RSI is in overbought territory

MFI divergence

MFI adds money-flow logic to the system.

RSI measures momentum.

MFI adds volume-weighted pressure.

This is useful because price can continue moving while money flow is already weakening.

Bullish MFI divergence suggests selling pressure may be losing power.

Bearish MFI divergence suggests buying pressure may be losing power.

Volume Exhaust

Volume Exhaust is designed to detect a possible final aggressive movement before reversal.

Buy-side exhaustion looks for:

high volume
long lower wick
RSI below oversold level

Sell-side exhaustion looks for:

high volume
long upper wick
RSI above overbought level

This helps identify moments where the market may be making a final push, while candle structure shows rejection.

ATR volatility expansion

ATR does not create direction by itself.

It only strengthens an existing buy or sell setup.

A divergence signal during expanding volatility may be more meaningful than the same signal during a flat, inactive market.

RSI visual line

Edge 2.3 also includes a clean RSI visual panel.

RSI line colours:

Blue = neutral zone
Red = overbought zone
Green = oversold zone

When RSI divergence appears, the indicator can also show a soft background glow:

red glow for bearish RSI divergence
green glow for bullish RSI divergence

This helps connect the table signal with the current chart condition.

Dashboard design

Edge 2.3 uses a Hybrid Glass Gold dashboard style.

Main visual features:

transparent glass-style cells
soft gold headers
low-distraction neutral states
very faded zero values
stronger colour only when signal quality improves
green premium buy cells
red premium sell cells
compact multi-timeframe layout

The table is designed so the trader’s eye naturally ignores weak areas and focuses on active opportunities.

How to use it

For beginners

Use the dashboard as a market checklist.

Start by looking for Score 3 and Score 4.

Ignore most Score 0 cells.

When a strong score appears:

open that instrument
check the same timeframe
look at support and resistance
check trend structure
check candle reaction
decide whether there is a valid trade setup

Do not enter only because a number appears in the table.

For experienced traders

A practical workflow:

Use 1D and H4 for higher-timeframe reversal zones
Use H1 for structure and confirmation
Use 15m for entry timing
Treat Score 4 as the main watchlist trigger
Treat Score 3 as a strong alert condition
Use Score 1 and Score 2 as early warnings only

The strongest situations usually occur when several timeframes begin to align in the same direction.

Example bullish setup

If NG shows:

H4 = 4 green
H1 = 3 green
15m = 2 or 3 green

this may suggest that bullish reversal pressure is building across multiple timeframes.

The next step is to open the chart and check:

market structure
support zone
liquidity sweep
rejection candle
risk/reward
confirmation trigger

Example bearish setup

If US500 shows:

D = 3 red
H4 = 4 red
H1 = 3 red

this may suggest that bearish reversal pressure is building.

The trader should then check:

resistance zone
failed breakout
upper wick rejection
trend exhaustion
risk level
possible downside target

Best use cases

This indicator is useful for:

multi-timeframe analysis
multi-instrument monitoring
reversal scanning
divergence analysis
commodity monitoring
index monitoring
volume exhaustion detection
high-volatility reversal setups
watchlist filtering
finding where attention should go first

Main advantages

Edge 2.3 allows traders to monitor several instruments at the same time.

Instead of checking each chart manually, the dashboard shows where the strongest conditions are building.

It helps reduce noise by making weak conditions visually quiet and strong conditions visually clear.

It combines momentum, money flow, volume exhaustion, and volatility into one compact score.

It helps traders focus on quality, not quantity.

Important note

This is not:

a guaranteed entry system
a financial advice tool
a replacement for risk management
a replacement for market structure
a standalone automatic trading system

It is a decision-support scanner.

Use it together with:

trend structure
support and resistance
liquidity context
key levels
candlestick confirmation
risk management
position sizing

Release Notes — Edge 2.3

Converted to Pine Script v6
Added RSI + MFI divergence engine
Added Volume Exhaust logic
Added ATR extreme volatility boost
Built multi-instrument scanner
Built multi-timeframe score table
Added Score 0–4 system
Added premium Score 4 alerts
Added RSI colour-zone visual line
Added RSI divergence background glow
Added Hybrid Glass Gold dashboard design
Added transparent zero-fade cells
Improved readability and reduced visual noise
Designed for fast monitoring of several markets at once

## Source Code

````pine
//@version=6
indicator("EDGE2.8 • MTF SCORE SCANNER • HYBRID GLASS GOLD ZERO FADE", overlay=false)

// =====================
// GROUPS
// =====================
grpCore = "Core"
grpMfi = "MFI"
grpVol = "Volatility / Volume"
grpSymbols = "Symbols"
grpVisual = "Visual"

// =====================
// INPUTS
// =====================
rsiLength = input.int(14, "RSI Length", group=grpCore)
overboughtLevel = input.int(72, "RSI Overbought Level", group=grpCore)
oversoldLevel = input.int(28, "RSI Oversold Level", group=grpCore)
lookbackBars = input.int(84, "Divergence Lookback", minval=5, group=grpCore)

mfiLength = input.int(14, "MFI Length", group=grpMfi)
mfiOverboughtLevel = input.int(80, "MFI Overbought Level", group=grpMfi)
mfiOversoldLevel = input.int(20, "MFI Oversold Level", group=grpMfi)

atrLen = input.int(14, "ATR Length", group=grpVol)
atrAvgLen = input.int(50, "ATR Average Length", group=grpVol)
v1Level = input.float(0.85, "V1 LOW Below", step=0.05, group=grpVol)
v2Level = input.float(1.25, "V2 NORMAL Up To", step=0.05, group=grpVol)
v3Level = input.float(1.60, "V3 HIGH Up To", step=0.05, group=grpVol)

volumeLength = input.int(20, "Volume MA Length", minval=1, group=grpVol)
volumeMultiplier = input.float(1.8, "Volume Exhaust Multiplier", step=0.1, group=grpVol)
wickMin = input.float(0.45, "Wick Exhaust Ratio", minval=0.05, maxval=0.95, step=0.05, group=grpVol)

showScanner = input.bool(true, "Show MTF Score Scanner", group=grpVisual)
scannerPosition = input.string("Top Right", "Scanner Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpVisual)
useWideCells = input.bool(true, "Wider Glass Cells", group=grpVisual)

showRsiVisual = input.bool(true, "Show RSI Visual Line", group=grpVisual)
showDivergenceGlow = input.bool(true, "Show RSI Divergence Glow", group=grpVisual)

// =====================
// SYMBOLS
// =====================
symbolNG = input.symbol("NYMEX:NG1!", "NG", group=grpSymbols)
symbolWTI = input.symbol("TVC:USOIL", "WTI", group=grpSymbols)
symbolBrent = input.symbol("TVC:UKOIL", "Brent", group=grpSymbols)
symbolCocoa = input.symbol("ICEUS:CC1!", "Cocoa", group=grpSymbols)

symbolUS30 = input.symbol("OANDA:US30USD", "US30", group=grpSymbols)
symbolUS500 = input.symbol("OANDA:SPX500USD", "US500", group=grpSymbols)
symbolUK100 = input.symbol("OANDA:UK100GBP", "UK100", group=grpSymbols)
symbolCAC40 = input.symbol("OANDA:FR40EUR", "CAC40", group=grpSymbols)

// =====================
// NAMES
// =====================
nameNG = input.string("NG", "NG Name", group=grpSymbols)
nameWTI = input.string("WTI", "WTI Name", group=grpSymbols)
nameBrent = input.string("Brent", "Brent Name", group=grpSymbols)
nameCocoa = input.string("Cocoa", "Cocoa Name", group=grpSymbols)

nameUS30 = input.string("US30", "US30 Name", group=grpSymbols)
nameUS500 = input.string("US500", "US500 Name", group=grpSymbols)
nameUK100 = input.string("UK100", "UK100 Name", group=grpSymbols)
nameCAC40 = input.string("CAC40", "CAC40 Name", group=grpSymbols)

// =====================
// HYBRID GLASS GOLD TABLE COLORS
// =====================
cGlassFrame = color.new(color.rgb(34, 40, 52), 88)
cGlassBorder = color.new(color.rgb(34, 40, 52), 96)
cGlassBg = color.new(color.rgb(8, 10, 18), 100)

cHeaderBg = color.new(color.rgb(14, 18, 28), 90)
cLabelBg = color.new(color.rgb(11, 15, 24), 94)
cLabelBg15 = color.new(color.rgb(11, 15, 24), 95)
cLabelBgH1 = color.new(color.rgb(12, 16, 25), 94)
cLabelBgH4 = color.new(color.rgb(13, 17, 26), 93)
cLabelBgD = color.new(color.rgb(14, 18, 28), 92)

cGold = color.rgb(205, 180, 112)
cGoldSoft = color.rgb(170, 148, 92)
cHeaderTxt = color.rgb(190, 170, 110)

// Score 0 made extra transparent / ghost-like
cScore0Bg = color.new(color.rgb(9, 13, 22), 100)
cScore0Txt = color.new(color.rgb(78, 86, 100), 82)

// Score 1/2/3/4 unchanged
cScore1Bg = color.new(color.rgb(9, 13, 22), 96)
cScore2Bg = color.new(color.rgb(9, 13, 22), 92)

cScore1Txt = color.rgb(118, 128, 145)
cScore2Txt = color.rgb(170, 178, 192)

cBuy3Bg = color.new(color.rgb(0, 255, 165), 86)
cBuy3Txt = color.rgb(205, 255, 232)

cSell3Bg = color.new(color.rgb(255, 0, 85), 86)
cSell3Txt = color.rgb(255, 205, 220)

cBuy4Bg = color.new(color.rgb(0, 255, 165), 72)
cBuy4Txt = color.rgb(240, 255, 248)

cSell4Bg = color.new(color.rgb(255, 0, 85), 72)
cSell4Txt = color.rgb(255, 240, 246)

cConflict3Bg = color.new(color.rgb(180, 130, 45), 84)
cConflict3Txt = color.rgb(245, 220, 160)

cConflict4Bg = color.new(color.rgb(220, 160, 55), 74)
cConflict4Txt = color.rgb(255, 235, 170)

// =====================
// RSI VISUAL COLORS
// =====================
neonBlue = color.rgb(0, 220, 255)
rsiRed = color.rgb(255, 60, 90)
rsiGreen = color.rgb(0, 230, 135)

// =====================
// POSITION HELPER
// =====================
f_pos(_p) =>
    _pos = position.top_right
    if _p == "Top Left"
        _pos := position.top_left
    else if _p == "Bottom Right"
        _pos := position.bottom_right
    else if _p == "Bottom Left"
        _pos := position.bottom_left
    _pos

// =====================
// TEXT PADDING HELPER
// =====================
f_pad(_txt) =>
    useWideCells ? "  " + _txt + "  " : _txt

f_score_pad(_txt) =>
    useWideCells ? "   " + _txt + "   " : " " + _txt + " "

// =====================
// MAIN ENGINE
// =====================
f_engine() =>
    _rsi = ta.rsi(close, rsiLength)
    _mfi = ta.mfi(hlc3, mfiLength)

    _inRsiOB = _rsi > overboughtLevel
    _inRsiOS = _rsi < oversoldLevel

    _inMfiOB = _mfi > mfiOverboughtLevel
    _inMfiOS = _mfi < mfiOversoldLevel

    // =====================
    // RSI SELL DIVERGENCE
    // =====================
    var float _prevHighRsi = na
    var float _prevRsiH = na
    var int _prevBarHighRsi = na

    _rawSellRsi = _inRsiOB and not na(_prevHighRsi) and high > _prevHighRsi and _rsi < _prevRsiH

    if _inRsiOB
        if na(_prevHighRsi)
            _prevHighRsi := high
            _prevRsiH := _rsi
            _prevBarHighRsi := bar_index
        else
            if _rsi > _prevRsiH
                _prevHighRsi := high
                _prevRsiH := _rsi
                _prevBarHighRsi := bar_index

    if not na(_prevBarHighRsi) and bar_index - _prevBarHighRsi > lookbackBars
        _prevHighRsi := na
        _prevRsiH := na
        _prevBarHighRsi := na

    // =====================
    // RSI BUY DIVERGENCE
    // =====================
    var float _prevLowRsi = na
    var float _prevRsiL = na
    var int _prevBarLowRsi = na

    _rawBuyRsi = _inRsiOS and not na(_prevLowRsi) and low < _prevLowRsi and _rsi > _prevRsiL

    if _inRsiOS
        if na(_prevLowRsi)
            _prevLowRsi := low
            _prevRsiL := _rsi
            _prevBarLowRsi := bar_index
        else
            if _rsi < _prevRsiL
                _prevLowRsi := low
                _prevRsiL := _rsi
                _prevBarLowRsi := bar_index

    if not na(_prevBarLowRsi) and bar_index - _prevBarLowRsi > lookbackBars
        _prevLowRsi := na
        _prevRsiL := na
        _prevBarLowRsi := na

    // =====================
    // MFI SELL DIVERGENCE
    // =====================
    var float _prevHighMfi = na
    var float _prevMfiH = na
    var int _prevBarHighMfi = na

    _rawSellMfi = _inMfiOB and not na(_prevHighMfi) and high > _prevHighMfi and _mfi < _prevMfiH

    if _inMfiOB
        if na(_prevHighMfi)
            _prevHighMfi := high
            _prevMfiH := _mfi
            _prevBarHighMfi := bar_index
        else
            if _mfi > _prevMfiH
                _prevHighMfi := high
                _prevMfiH := _mfi
                _prevBarHighMfi := bar_index

    if not na(_prevBarHighMfi) and bar_index - _prevBarHighMfi > lookbackBars
        _prevHighMfi := na
        _prevMfiH := na
        _prevBarHighMfi := na

    // =====================
    // MFI BUY DIVERGENCE
    // =====================
    var float _prevLowMfi = na
    var float _prevMfiL = na
    var int _prevBarLowMfi = na

    _rawBuyMfi = _inMfiOS and not na(_prevLowMfi) and low < _prevLowMfi and _mfi > _prevMfiL

    if _inMfiOS
        if na(_prevLowMfi)
            _prevLowMfi := low
            _prevMfiL := _mfi
            _prevBarLowMfi := bar_index
        else
            if _mfi < _prevMfiL
                _prevLowMfi := low
                _prevMfiL := _mfi
                _prevBarLowMfi := bar_index

    if not na(_prevBarLowMfi) and bar_index - _prevBarLowMfi > lookbackBars
        _prevLowMfi := na
        _prevMfiL := na
        _prevBarLowMfi := na

    // =====================
    // ATR VOLATILITY LEVEL
    // =====================
    _atr = ta.atr(atrLen)
    _atrAvg = ta.sma(_atr, atrAvgLen)
    _atrRatio = _atrAvg > 0 ? _atr / _atrAvg : 1.0

    _volLevel = 1
    if _atrRatio < v1Level
        _volLevel := 1
    else if _atrRatio <= v2Level
        _volLevel := 2
    else if _atrRatio <= v3Level
        _volLevel := 3
    else
        _volLevel := 4

    _atrExtreme = _volLevel >= 4

    // =====================
    // VOLUME EXHAUST
    // =====================
    _volAvg = ta.sma(volume, volumeLength)
    _volRatio = _volAvg > 0 ? volume / _volAvg : 0.0
    _highVol = _volRatio >= volumeMultiplier

    _range = high - low
    _upperWick = high - math.max(open, close)
    _lowerWick = math.min(open, close) - low

    _upperWickRatio = _range > 0 ? _upperWick / _range : 0.0
    _lowerWickRatio = _range > 0 ? _lowerWick / _range : 0.0

    _sellExhaust = _highVol and _upperWickRatio >= wickMin and _rsi > overboughtLevel
    _buyExhaust = _highVol and _lowerWickRatio >= wickMin and _rsi < oversoldLevel

    // =====================
    // SCORE LOGIC
    // =====================
    _rsiBuy = _inRsiOS and _rawBuyRsi
    _rsiSell = _inRsiOB and _rawSellRsi

    _mfiBuy = _inMfiOS and _rawBuyMfi
    _mfiSell = _inMfiOB and _rawSellMfi

    _volumeBuy = _buyExhaust
    _volumeSell = _sellExhaust

    _atrScore = _atrExtreme ? 1 : 0

    _buyBase =
         (_rsiBuy ? 1 : 0) +
         (_mfiBuy ? 1 : 0) +
         (_volumeBuy ? 1 : 0)

    _sellBase =
         (_rsiSell ? 1 : 0) +
         (_mfiSell ? 1 : 0) +
         (_volumeSell ? 1 : 0)

    _score = 0
    _scoreDir = 0

    // ATR does NOT create direction by itself.
    // ATR only boosts existing BUY or SELL pressure.
    if _buyBase > 0 and _sellBase == 0
        _score := _buyBase + _atrScore
        _scoreDir := 1
    else if _sellBase > 0 and _buyBase == 0
        _score := _sellBase + _atrScore
        _scoreDir := -1
    else if _buyBase == 0 and _sellBase == 0
        _score := 0
        _scoreDir := 0
    else
        _score := math.max(_buyBase, _sellBase) + _atrScore
        _scoreDir := 0

    _score := math.min(_score, 4)

    [_score, _scoreDir, _rawSellRsi, _rawBuyRsi, _rsi]

// =====================
// CURRENT CHART VALUES FOR RSI PANEL
// =====================
[curScore, curScoreDir, curRawSellRsi, curRawBuyRsi, curRsi] = f_engine()

// =====================
// SECURITY HELPER
// =====================
f_sec(_symbol, _tf) =>
    request.security(_symbol, _tf, f_engine(), barmerge.gaps_off, barmerge.lookahead_off)

// =====================
// SECURITY REQUESTS — CURRENT TF
// =====================
[ngCurScore, ngCurDir, ngCurRawSellRsi, ngCurRawBuyRsi, ngCurRsi] = f_sec(symbolNG, timeframe.period)
[wtiCurScore, wtiCurDir, wtiCurRawSellRsi, wtiCurRawBuyRsi, wtiCurRsi] = f_sec(symbolWTI, timeframe.period)
[brentCurScore, brentCurDir, brentCurRawSellRsi, brentCurRawBuyRsi, brentCurRsi] = f_sec(symbolBrent, timeframe.period)
[cocoaCurScore, cocoaCurDir, cocoaCurRawSellRsi, cocoaCurRawBuyRsi, cocoaCurRsi] = f_sec(symbolCocoa, timeframe.period)

[us30CurScore, us30CurDir, us30CurRawSellRsi, us30CurRawBuyRsi, us30CurRsi] = f_sec(symbolUS30, timeframe.period)
[us500CurScore, us500CurDir, us500CurRawSellRsi, us500CurRawBuyRsi, us500CurRsi] = f_sec(symbolUS500, timeframe.period)
[uk100CurScore, uk100CurDir, uk100CurRawSellRsi, uk100CurRawBuyRsi, uk100CurRsi] = f_sec(symbolUK100, timeframe.period)
[cac40CurScore, cac40CurDir, cac40CurRawSellRsi, cac40CurRawBuyRsi, cac40CurRsi] = f_sec(symbolCAC40, timeframe.period)

// =====================
// SECURITY REQUESTS — 15M
// =====================
[ng15Score, ng15Dir, ng15RawSellRsi, ng15RawBuyRsi, ng15Rsi] = f_sec(symbolNG, "15")
[wti15Score, wti15Dir, wti15RawSellRsi, wti15RawBuyRsi, wti15Rsi] = f_sec(symbolWTI, "15")
[brent15Score, brent15Dir, brent15RawSellRsi, brent15RawBuyRsi, brent15Rsi] = f_sec(symbolBrent, "15")
[cocoa15Score, cocoa15Dir, cocoa15RawSellRsi, cocoa15RawBuyRsi, cocoa15Rsi] = f_sec(symbolCocoa, "15")

[us3015Score, us3015Dir, us3015RawSellRsi, us3015RawBuyRsi, us3015Rsi] = f_sec(symbolUS30, "15")
[us50015Score, us50015Dir, us50015RawSellRsi, us50015RawBuyRsi, us50015Rsi] = f_sec(symbolUS500, "15")
[uk10015Score, uk10015Dir, uk10015RawSellRsi, uk10015RawBuyRsi, uk10015Rsi] = f_sec(symbolUK100, "15")
[cac4015Score, cac4015Dir, cac4015RawSellRsi, cac4015RawBuyRsi, cac4015Rsi] = f_sec(symbolCAC40, "15")

// =====================
// SECURITY REQUESTS — H1
// =====================
[ngH1Score, ngH1Dir, ngH1RawSellRsi, ngH1RawBuyRsi, ngH1Rsi] = f_sec(symbolNG, "60")
[wtiH1Score, wtiH1Dir, wtiH1RawSellRsi, wtiH1RawBuyRsi, wtiH1Rsi] = f_sec(symbolWTI, "60")
[brentH1Score, brentH1Dir, brentH1RawSellRsi, brentH1RawBuyRsi, brentH1Rsi] = f_sec(symbolBrent, "60")
[cocoaH1Score, cocoaH1Dir, cocoaH1RawSellRsi, cocoaH1RawBuyRsi, cocoaH1Rsi] = f_sec(symbolCocoa, "60")

[us30H1Score, us30H1Dir, us30H1RawSellRsi, us30H1RawBuyRsi, us30H1Rsi] = f_sec(symbolUS30, "60")
[us500H1Score, us500H1Dir, us500H1RawSellRsi, us500H1RawBuyRsi, us500H1Rsi] = f_sec(symbolUS500, "60")
[uk100H1Score, uk100H1Dir, uk100H1RawSellRsi, uk100H1RawBuyRsi, uk100H1Rsi] = f_sec(symbolUK100, "60")
[cac40H1Score, cac40H1Dir, cac40H1RawSellRsi, cac40H1RawBuyRsi, cac40H1Rsi] = f_sec(symbolCAC40, "60")

// =====================
// SECURITY REQUESTS — H4
// =====================
[ngH4Score, ngH4Dir, ngH4RawSellRsi, ngH4RawBuyRsi, ngH4Rsi] = f_sec(symbolNG, "240")
[wtiH4Score, wtiH4Dir, wtiH4RawSellRsi, wtiH4RawBuyRsi, wtiH4Rsi] = f_sec(symbolWTI, "240")
[brentH4Score, brentH4Dir, brentH4RawSellRsi, brentH4RawBuyRsi, brentH4Rsi] = f_sec(symbolBrent, "240")
[cocoaH4Score, cocoaH4Dir, cocoaH4RawSellRsi, cocoaH4RawBuyRsi, cocoaH4Rsi] = f_sec(symbolCocoa, "240")

[us30H4Score, us30H4Dir, us30H4RawSellRsi, us30H4RawBuyRsi, us30H4Rsi] = f_sec(symbolUS30, "240")
[us500H4Score, us500H4Dir, us500H4RawSellRsi, us500H4RawBuyRsi, us500H4Rsi] = f_sec(symbolUS500, "240")
[uk100H4Score, uk100H4Dir, uk100H4RawSellRsi, uk100H4RawBuyRsi, uk100H4Rsi] = f_sec(symbolUK100, "240")
[cac40H4Score, cac40H4Dir, cac40H4RawSellRsi, cac40H4RawBuyRsi, cac40H4Rsi] = f_sec(symbolCAC40, "240")

// =====================
// SECURITY REQUESTS — DAILY
// =====================
[ngDScore, ngDDir, ngDRawSellRsi, ngDRawBuyRsi, ngDRsi] = f_sec(symbolNG, "D")
[wtiDScore, wtiDDir, wtiDRawSellRsi, wtiDRawBuyRsi, wtiDRsi] = f_sec(symbolWTI, "D")
[brentDScore, brentDDir, brentDRawSellRsi, brentDRawBuyRsi, brentDRsi] = f_sec(symbolBrent, "D")
[cocoaDScore, cocoaDDir, cocoaDRawSellRsi, cocoaDRawBuyRsi, cocoaDRsi] = f_sec(symbolCocoa, "D")

[us30DScore, us30DDir, us30DRawSellRsi, us30DRawBuyRsi, us30DRsi] = f_sec(symbolUS30, "D")
[us500DScore, us500DDir, us500DRawSellRsi, us500DRawBuyRsi, us500DRsi] = f_sec(symbolUS500, "D")
[uk100DScore, uk100DDir, uk100DRawSellRsi, uk100DRawBuyRsi, uk100DRsi] = f_sec(symbolUK100, "D")
[cac40DScore, cac40DDir, cac40DRawSellRsi, cac40DRawBuyRsi, cac40DRsi] = f_sec(symbolCAC40, "D")

// =====================
// TEXT / COLOR HELPERS
// =====================
f_score_text(_score) =>
    str.tostring(_score)

f_score_bg(_score, _dir) =>
    _bg = cScore0Bg

    if _score == 1
        _bg := cScore1Bg
    else if _score == 2
        _bg := cScore2Bg
    else if _score == 3 and _dir == 1
        _bg := cBuy3Bg
    else if _score == 3 and _dir == -1
        _bg := cSell3Bg
    else if _score == 3 and _dir == 0
        _bg := cConflict3Bg
    else if _score >= 4 and _dir == 1
        _bg := cBuy4Bg
    else if _score >= 4 and _dir == -1
        _bg := cSell4Bg
    else if _score >= 4 and _dir == 0
        _bg := cConflict4Bg

    _bg

f_score_tc(_score, _dir) =>
    _tc = cScore0Txt

    if _score == 1
        _tc := cScore1Txt
    else if _score == 2
        _tc := cScore2Txt
    else if _score == 3 and _dir == 1
        _tc := cBuy3Txt
    else if _score == 3 and _dir == -1
        _tc := cSell3Txt
    else if _score == 3 and _dir == 0
        _tc := cConflict3Txt
    else if _score >= 4 and _dir == 1
        _tc := cBuy4Txt
    else if _score >= 4 and _dir == -1
        _tc := cSell4Txt
    else if _score >= 4 and _dir == 0
        _tc := cConflict4Txt

    _tc

f_label_bg(_block) =>
    _bg = cLabelBg
    if _block == 1
        _bg := cLabelBg15
    else if _block == 2
        _bg := cLabelBgH1
    else if _block == 3
        _bg := cLabelBgH4
    else if _block == 4
        _bg := cLabelBgD
    _bg

// =====================
// TABLE HELPERS — HYBRID GLASS GOLD
// =====================
f_header_cell(_tbl, _col, _row, _txt) =>
    table.cell(
         _tbl,
         _col,
         _row,
         f_pad(_txt),
         text_color=cHeaderTxt,
         bgcolor=cHeaderBg,
         text_size=size.small,
         text_halign=text.align_center,
         text_valign=text.align_center
     )

f_label_cell(_tbl, _col, _row, _txt, _block) =>
    table.cell(
         _tbl,
         _col,
         _row,
         f_pad(_txt),
         text_color=cGoldSoft,
         bgcolor=f_label_bg(_block),
         text_size=size.small,
         text_halign=text.align_center,
         text_valign=text.align_center
     )

f_score_cell(_tbl, _col, _row, _score, _dir) =>
    table.cell(
         _tbl,
         _col,
         _row,
         f_score_pad(f_score_text(_score)),
         text_color=f_score_tc(_score, _dir),
         bgcolor=f_score_bg(_score, _dir),
         text_size=size.normal,
         text_halign=text.align_center,
         text_valign=text.align_center
     )

// =====================
// RSI VISUAL BACKGROUND — CURRENT CHART ONLY
// =====================
bgcolor(showDivergenceGlow and curRawSellRsi ? color.new(rsiRed, 88) : na)
bgcolor(showDivergenceGlow and curRawBuyRsi ? color.new(rsiGreen, 88) : na)

// =====================
// RSI LINE — PREMIUM ZONE COLOR
// =====================
rsiCol = curRsi > overboughtLevel ? rsiRed : curRsi < oversoldLevel ? rsiGreen : neonBlue

plot(showRsiVisual ? curRsi : na, title="RSI Glow Wide", color=color.new(rsiCol, 90), linewidth=8)
plot(showRsiVisual ? curRsi : na, title="RSI Glow Mid", color=color.new(rsiCol, 80), linewidth=5)
plot(showRsiVisual ? curRsi : na, title="RSI Line", color=rsiCol, linewidth=1)

hline(overboughtLevel, "Overbought", color=color.new(color.gray, 78))
hline(oversoldLevel, "Oversold", color=color.new(color.gray, 78))
hline(50, "Middle", color=color.new(color.gray, 88))

// =====================
// MTF SCORE SCANNER TABLE
// =====================
var table scanner = table.new(
     f_pos(scannerPosition),
     9,
     6,
     bgcolor=cGlassBg,
     frame_color=cGlassFrame,
     frame_width=1,
     border_color=cGlassBorder,
     border_width=1
 )

if barstate.islast and showScanner
    // Header
    f_header_cell(scanner, 0, 0, "")
    f_header_cell(scanner, 1, 0, nameNG)
    f_header_cell(scanner, 2, 0, nameWTI)
    f_header_cell(scanner, 3, 0, nameBrent)
    f_header_cell(scanner, 4, 0, nameCocoa)
    f_header_cell(scanner, 5, 0, nameUS30)
    f_header_cell(scanner, 6, 0, nameUS500)
    f_header_cell(scanner, 7, 0, nameUK100)
    f_header_cell(scanner, 8, 0, nameCAC40)

    // Labels
    f_label_cell(scanner, 0, 1, "CUR", 0)
    f_label_cell(scanner, 0, 2, "15", 1)
    f_label_cell(scanner, 0, 3, "H1", 2)
    f_label_cell(scanner, 0, 4, "H4", 3)
    f_label_cell(scanner, 0, 5, "D", 4)

    // CUR row
    f_score_cell(scanner, 1, 1, ngCurScore, ngCurDir)
    f_score_cell(scanner, 2, 1, wtiCurScore, wtiCurDir)
    f_score_cell(scanner, 3, 1, brentCurScore, brentCurDir)
    f_score_cell(scanner, 4, 1, cocoaCurScore, cocoaCurDir)
    f_score_cell(scanner, 5, 1, us30CurScore, us30CurDir)
    f_score_cell(scanner, 6, 1, us500CurScore, us500CurDir)
    f_score_cell(scanner, 7, 1, uk100CurScore, uk100CurDir)
    f_score_cell(scanner, 8, 1, cac40CurScore, cac40CurDir)

    // 15 row
    f_score_cell(scanner, 1, 2, ng15Score, ng15Dir)
    f_score_cell(scanner, 2, 2, wti15Score, wti15Dir)
    f_score_cell(scanner, 3, 2, brent15Score, brent15Dir)
    f_score_cell(scanner, 4, 2, cocoa15Score, cocoa15Dir)
    f_score_cell(scanner, 5, 2, us3015Score, us3015Dir)
    f_score_cell(scanner, 6, 2, us50015Score, us50015Dir)
    f_score_cell(scanner, 7, 2, uk10015Score, uk10015Dir)
    f_score_cell(scanner, 8, 2, cac4015Score, cac4015Dir)

    // H1 row
    f_score_cell(scanner, 1, 3, ngH1Score, ngH1Dir)
    f_score_cell(scanner, 2, 3, wtiH1Score, wtiH1Dir)
    f_score_cell(scanner, 3, 3, brentH1Score, brentH1Dir)
    f_score_cell(scanner, 4, 3, cocoaH1Score, cocoaH1Dir)
    f_score_cell(scanner, 5, 3, us30H1Score, us30H1Dir)
    f_score_cell(scanner, 6, 3, us500H1Score, us500H1Dir)
    f_score_cell(scanner, 7, 3, uk100H1Score, uk100H1Dir)
    f_score_cell(scanner, 8, 3, cac40H1Score, cac40H1Dir)

    // H4 row
    f_score_cell(scanner, 1, 4, ngH4Score, ngH4Dir)
    f_score_cell(scanner, 2, 4, wtiH4Score, wtiH4Dir)
    f_score_cell(scanner, 3, 4, brentH4Score, brentH4Dir)
    f_score_cell(scanner, 4, 4, cocoaH4Score, cocoaH4Dir)
    f_score_cell(scanner, 5, 4, us30H4Score, us30H4Dir)
    f_score_cell(scanner, 6, 4, us500H4Score, us500H4Dir)
    f_score_cell(scanner, 7, 4, uk100H4Score, uk100H4Dir)
    f_score_cell(scanner, 8, 4, cac40H4Score, cac40H4Dir)

    // D row
    f_score_cell(scanner, 1, 5, ngDScore, ngDDir)
    f_score_cell(scanner, 2, 5, wtiDScore, wtiDDir)
    f_score_cell(scanner, 3, 5, brentDScore, brentDDir)
    f_score_cell(scanner, 4, 5, cocoaDScore, cocoaDDir)
    f_score_cell(scanner, 5, 5, us30DScore, us30DDir)
    f_score_cell(scanner, 6, 5, us500DScore, us500DDir)
    f_score_cell(scanner, 7, 5, uk100DScore, uk100DDir)
    f_score_cell(scanner, 8, 5, cac40DScore, cac40DDir)

// =====================
// ALERTS — SCORE 4 PREMIUM
// =====================
anyScore4Buy =
     ngCurScore == 4 and ngCurDir == 1 or wtiCurScore == 4 and wtiCurDir == 1 or brentCurScore == 4 and brentCurDir == 1 or cocoaCurScore == 4 and cocoaCurDir == 1 or us30CurScore == 4 and us30CurDir == 1 or us500CurScore == 4 and us500CurDir == 1 or uk100CurScore == 4 and uk100CurDir == 1 or cac40CurScore == 4 and cac40CurDir == 1 or
     ng15Score == 4 and ng15Dir == 1 or wti15Score == 4 and wti15Dir == 1 or brent15Score == 4 and brent15Dir == 1 or cocoa15Score == 4 and cocoa15Dir == 1 or us3015Score == 4 and us3015Dir == 1 or us50015Score == 4 and us50015Dir == 1 or uk10015Score == 4 and uk10015Dir == 1 or cac4015Score == 4 and cac4015Dir == 1 or
     ngH1Score == 4 and ngH1Dir == 1 or wtiH1Score == 4 and wtiH1Dir == 1 or brentH1Score == 4 and brentH1Dir == 1 or cocoaH1Score == 4 and cocoaH1Dir == 1 or us30H1Score == 4 and us30H1Dir == 1 or us500H1Score == 4 and us500H1Dir == 1 or uk100H1Score == 4 and uk100H1Dir == 1 or cac40H1Score == 4 and cac40H1Dir == 1 or
     ngH4Score == 4 and ngH4Dir == 1 or wtiH4Score == 4 and wtiH4Dir == 1 or brentH4Score == 4 and brentH4Dir == 1 or cocoaH4Score == 4 and cocoaH4Dir == 1 or us30H4Score == 4 and us30H4Dir == 1 or us500H4Score == 4 and us500H4Dir == 1 or uk100H4Score == 4 and uk100H4Dir == 1 or cac40H4Score == 4 and cac40H4Dir == 1 or
     ngDScore == 4 and ngDDir == 1 or wtiDScore == 4 and wtiDDir == 1 or brentDScore == 4 and brentDDir == 1 or cocoaDScore == 4 and cocoaDDir == 1 or us30DScore == 4 and us30DDir == 1 or us500DScore == 4 and us500DDir == 1 or uk100DScore == 4 and uk100DDir == 1 or cac40DScore == 4 and cac40DDir == 1

anyScore4Sell =
     ngCurScore == 4 and ngCurDir == -1 or wtiCurScore == 4 and wtiCurDir == -1 or brentCurScore == 4 and brentCurDir == -1 or cocoaCurScore == 4 and cocoaCurDir == -1 or us30CurScore == 4 and us30CurDir == -1 or us500CurScore == 4 and us500CurDir == -1 or uk100CurScore == 4 and uk100CurDir == -1 or cac40CurScore == 4 and cac40CurDir == -1 or
     ng15Score == 4 and ng15Dir == -1 or wti15Score == 4 and wti15Dir == -1 or brent15Score == 4 and brent15Dir == -1 or cocoa15Score == 4 and cocoa15Dir == -1 or us3015Score == 4 and us3015Dir == -1 or us50015Score == 4 and us50015Dir == -1 or uk10015Score == 4 and uk10015Dir == -1 or cac4015Score == 4 and cac4015Dir == -1 or
     ngH1Score == 4 and ngH1Dir == -1 or wtiH1Score == 4 and wtiH1Dir == -1 or brentH1Score == 4 and brentH1Dir == -1 or cocoaH1Score == 4 and cocoaH1Dir == -1 or us30H1Score == 4 and us30H1Dir == -1 or us500H1Score == 4 and us500H1Dir == -1 or uk100H1Score == 4 and uk100H1Dir == -1 or cac40H1Score == 4 and cac40H1Dir == -1 or
     ngH4Score == 4 and ngH4Dir == -1 or wtiH4Score == 4 and wtiH4Dir == -1 or brentH4Score == 4 and brentH4Dir == -1 or cocoaH4Score == 4 and cocoaH4Dir == -1 or us30H4Score == 4 and us30H4Dir == -1 or us500H4Score == 4 and us500H4Dir == -1 or uk100H4Score == 4 and uk100H4Dir == -1 or cac40H4Score == 4 and cac40H4Dir == -1 or
     ngDScore == 4 and ngDDir == -1 or wtiDScore == 4 and wtiDDir == -1 or brentDScore == 4 and brentDDir == -1 or cocoaDScore == 4 and cocoaDDir == -1 or us30DScore == 4 and us30DDir == -1 or us500DScore == 4 and us500DDir == -1 or uk100DScore == 4 and uk100DDir == -1 or cac40DScore == 4 and cac40DDir == -1

alertcondition(anyScore4Buy, "Any SCORE 4 BUY", "At least one instrument has SCORE 4 BUY on CUR / 15 / H1 / H4 / D")
alertcondition(anyScore4Sell, "Any SCORE 4 SELL", "At least one instrument has SCORE 4 SELL on CUR / 15 / H1 / H4 / D")
````
