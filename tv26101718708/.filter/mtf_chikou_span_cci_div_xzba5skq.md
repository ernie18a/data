# MTF Chikou Span + CCI Div

- url: https://www.tradingview.com/script/XZba5SkQ/
- type: indicator
- pine_id: PUB;a3f038ecfce24177a63c80530e9dd3e3
- version: 3.0

## Description

[b]When using this strategy, we strongly recommend combining it with an external CCI indicator.[/b]

MTF Chikou Span + CCI Div
Multi-Timeframe Lagging Span + CCI Divergence
A TradingView Indicator for Visual, Informed Entry Timing

1. Overview
MTF Chikou Span + CCI Div is built around one of the most underused components of the Ichimoku Cloud system: the Lagging Span (Chikou Span). While most traders focus on the cloud, the tenkan/kijun cross, or price-to-cloud relationships, the Chikou Span offers something uniquely powerful — a direct visual comparison between current price and historical price at a fixed offset.

This indicator combines:
•	Two Chikou Spans (current timeframe + higher timeframe) for multi-timeframe trend alignment
•	CCI (Commodity Channel Index) for momentum-based entry timing
•	CCI Divergence detection to highlight higher-confidence setups
•	ATR-based Stop Loss line drawn automatically on signal

2. Understanding the Lagging Span (Chikou Span)
2.1 What it is
The Chikou Span is simply the current closing price plotted 26 bars to the left. You are visually overlaying today's price onto the price action from 26 periods ago. When the Chikou Span is above those historical candles, price has risen significantly since that point. When it sits below, it has fallen.

Despite being one of the five components of Ichimoku Kinko Hyo, the Chikou Span is rarely discussed in depth outside of Japanese trading communities. This indicator is designed to bring it to the forefront.

2.2 The Two Lines on Your Chart
Green line (Current TF Chikou): The closing price of the current timeframe, displaced 26 bars back. Shows the short-term trend direction.
Orange line (Higher TF Chikou): The closing price of a higher timeframe, displaced back proportionally. Shows the macro trend direction.

When both lines point upward and price sits clearly above the historical candles they overlap, you have a strong bullish alignment.
When the two lines conflict in direction, the indicator marks this as CONFLICT in the dashboard and withholds signals.

2.3 The Visual Gap — The Most Important Concept
The quality of a signal depends heavily on how much open space exists between the Chikou Span line and the surrounding candlesticks.

Large gap (Chikou in open space): Price has moved far from its historical reference. There is room to run. This is the ideal entry zone.
Small gap (Chikou tangled with candles): Price is near its historical levels. Resistance and support are close. Signals here carry lower follow-through.

Key Principle: The indicator generates CCI signals continuously, but YOU decide which signals to act on based on your visual inspection of the gap.
If the Chikou Span is deeply embedded in past candlestick bodies, wait. If it is floating freely in open space, that is where to pay attention.

This judgment cannot be fully automated — open space is contextual. It depends on what else is in that space: pivots, previous highs/lows, the cloud, the other Chikou line. Your eyes are the final filter.

2.4 When the Chikou Span Approaches a Candle
As price moves forward, the Chikou Span will eventually approach and touch historical candles. This is significant for two reasons:
•	Support / Resistance: The candle it approaches represents a historical price memory. Market participants who acted at that level may react again.
•	Forward prediction: You can visually anticipate where the Chikou Span will meet candles in the near future. A clear run of open space followed by a dense cluster of candles tells you where momentum may stall.

The orange higher-TF Chikou often reveals macro support/resistance levels that are invisible on the current timeframe alone. Watch how it behaves as you switch between timeframes.

3. Timeframe Setup
3.1 Auto-Selection
The indicator automatically selects a higher timeframe based on your current chart:

Current Chart TF	Auto Higher TF
1 min	3 min
3–5 min	15 min
15 min	1 hour
30–60 min	4 hours
2–4 hours	Daily
Daily	Weekly
Weekly / Monthly	Monthly

You can disable auto-selection and manually set both the higher and lower timeframes in the Timeframe Settings group.

3.2 Choosing the Right Timeframe for Entry
This is the core workflow:

1.	Open a small timeframe chart (1m, 3m, or 5m) with the indicator applied.
2.	Check the Chikou Align row in the table. If it shows CONFLICT, do not trade.
3.	Visually inspect the green and orange Chikou lines. Are they floating freely, or hitting candles?
4.	If the gap is insufficient, switch to a larger timeframe and repeat.
5.	On the timeframe with the best gap, wait for a CCI signal aligned with both Chikou directions.
6.	Check the SL line vs. your nearest target. Confirm risk/reward is acceptable.
7.	Enter. Monitor the Chikou Span — if it approaches a dense cluster of historical candles, consider tightening your stop.

4. Signal Types
4.1 Signal Labels
Label	Color	CCI Used	Meaning
BUY	Green triangle	Short CCI (period 5)	Standard long signal
SELL	Red triangle	Short CCI (period 5)	Standard short signal
H-BUY	Blue label	Long CCI (period 14)	Higher-conviction long signal
H-SELL	Maroon label	Long CCI (period 14)	Higher-conviction short signal
BUY+D	Gold triangle	Short CCI + Divergence CCI	Long signal with CCI divergence confirmed
SELL+D	Gold triangle	Short CCI + Divergence CCI	Short signal with CCI divergence confirmed
H-BUY+D	Gold label	Long CCI + Divergence CCI	H-BUY with divergence confirmed
H-SELL+D	Gold label	Long CCI + Divergence CCI	H-SELL with divergence confirmed

+D signals (gold color): Highest-priority signals. An independent Divergence CCI (period 5, separate from the trigger CCI) has confirmed that price and momentum are diverging. These should be given priority over standard signals.

4.2 HTF Alignment Switch
Under Chikou Span Settings, 'Require HTF + Current Chikou Alignment' controls whether both timeframes must agree:
•	ON (default): Both higher TF and current TF Chikou must point the same direction. Fewer signals, higher conviction.
•	OFF: Only current TF Chikou direction is used. More signals. Useful when you want to monitor the higher TF manually or trade a single timeframe.

5. CCI Settings
5.1 Three Independent CCI Calculations
CCI	Default Period	Purpose
Short CCI	5	Fast trigger for BUY/SELL. Sensitive to short-term momentum shifts.
Long CCI	14	Slower trigger for H-BUY/H-SELL. Better for sustained moves.
Divergence CCI	5 (separate)	Used only for divergence detection. Independent from trigger CCI for maximum pivot sensitivity.

Important: The actual ±100 crossover trigger uses the raw CCI value, not the smoothed EMA. The EMA Smoothing value is used for override detection and dashboard display only.

6. Filters
All filters are optional and can be toggled independently. When a filter is OFF, its row is hidden from the dashboard table automatically.

Filter	Default	Description
EMA Trend Filter	ON	BUY requires EMA Fast > EMA Slow. Can be bypassed by extreme CCI EMA (override).
Lower TF Chikou Filter	OFF	Adds a third Chikou check using a sub-timeframe. Recommended for advanced users only.
ATR Volatility Filter	OFF	Only signals when current ATR > average ATR. Prevents entries in dead markets.
Volume Filter	OFF	Requires above-average volume at signal time.
Depth Filter (S/L-EMA)	OFF	Requires CCI EMA <= -30 (buy) or >= +30 (sell). Ensures signals fire after real overextension.

7. Stop Loss Line
When a signal fires, a red dashed line is drawn at:
•	Long signal: entry price - ATR x multiplier (default 1.5)
•	Short signal: entry price + ATR x multiplier (default 1.5)

The line disappears after 10 bars (adjustable). The current SL price appears in the dashboard table while the line is active.

The SL line is a reference tool. Always combine it with your own analysis — pivot levels, recent swing lows/highs, and the Chikou Span gap should all inform your actual stop placement.

8. Dashboard Table
The table in the top-right shows only active components. Disabled filter rows are hidden automatically.

Row	Description
HTF (TF)	Higher timeframe Chikou direction. Blue = up, Red = down.
Curr (TF)	Current timeframe Chikou direction. Green = up, Red = down.
Chikou Align	BULL ALIGN / BEAR ALIGN / CONFLICT.
LTF (TF)	Lower TF Chikou. Shown only when that filter is ON.
EMA Filter	BULL / BEAR / OVERRIDE. Shown when ON.
ATR Filter	HIGH = above-average volatility. Shown when ON.
Volume	HIGH = above-average volume. Shown when ON.
Depth Filter	PASS / BLOCK. Shown when ON.
CCI DIV	Bull DIV or Bear DIV when divergence is active.
CCI L-EMA	Long CCI smoothed value.
CCI S-EMA	Short CCI smoothed value.
Stop Loss	Current SL price. Shown while SL line is active.
Signal	Current signal state.

9. Parameter Reference
Parameter	Default	Notes
Short CCI Period	5	Raise to 9–14 for swing trading.
Short CCI EMA Smoothing	2	Raise to 3–5 to reduce noise.
Long CCI Period	14	Used for H-BUY / H-SELL signals.
Long CCI EMA Smoothing	9	Standard smoothing.
Divergence CCI Period	5	Kept short for pivot sensitivity.
Pivot Lookback Left/Right	5 / 5	Bars on each side to confirm a swing pivot.
Max Lookback Range	60	Maximum bars between pivots for valid divergence.
Min Lookback Range	5	Minimum bars between pivots.
EMA Fast / Slow	9 / 20	For EMA trend filter.
SL ATR Multiplier	1.5	Raise for wider stops, lower for tighter.
SL Line Duration	10	Bars the SL line remains visible.

Disclaimer
This indicator is provided for educational purposes only and does not constitute financial advice. Past signal performance does not guarantee future results. Always use proper risk management. Never risk more than you can afford to lose.

## Source Code

````pine
//@version=6
indicator(title="Multi-timeframe Chikou Span + CCI Div", shorttitle="MTF Chikou CCI Pro", overlay=true, max_bars_back=500)

// ==========================================
// Timeframe Settings
// ==========================================
tfGroup       = "Timeframe Settings"
useAutoHigher = input.bool(true,  "Auto-select Higher TF", group=tfGroup)
manualHigher  = input.timeframe("60", "Manual Higher TF",  group=tfGroup)
useAutoLower  = input.bool(true,  "Auto-select Lower TF",  group=tfGroup)
manualLower   = input.timeframe("1",  "Manual Lower TF",   group=tfGroup)

getHigherTimeframe() =>
    string res = "60"
    if timeframe.isdaily
        res := "W"
    else if timeframe.isweekly
        res := "M"
    else if timeframe.ismonthly
        res := "M"
    else
        m = timeframe.multiplier
        if m <= 1
            res := "3"
        else if m <= 5
            res := "15"
        else if m <= 15
            res := "60"
        else if m <= 60
            res := "240"
        else if m <= 240
            res := "D"
        else
            res := "D"
    res

getLowerTimeframe() =>
    string res = "1"
    if timeframe.isdaily
        res := "240"
    else if timeframe.isweekly
        res := "D"
    else if timeframe.ismonthly
        res := "W"
    else
        m = timeframe.multiplier
        if m >= 120
            res := "60"
        else if m >= 60
            res := "30"
        else if m >= 30
            res := "15"
        else if m >= 15
            res := "5"
        else if m >= 5
            res := "3"
        else if m >= 3
            res := "1"
        else
            res := "1"
    res

higherTimeframe = useAutoHigher ? getHigherTimeframe() : manualHigher
lowerTimeframe  = useAutoLower  ? getLowerTimeframe()  : manualLower

currSecs = timeframe.in_seconds(timeframe.period)
highSecs = timeframe.in_seconds(higherTimeframe)
tfRatio  = math.max(1, highSecs / currSecs)

// ==========================================
// Chikou Span Settings
// ==========================================
dispGroup      = "Chikou Span Settings"
displacement   = input.int(26, "Base Offset (26)", minval=1, group=dispGroup)
showCurrent    = input.bool(true, "Show Current TF Chikou", group=dispGroup)
showHigher     = input.bool(true, "Show Higher TF Chikou",  group=dispGroup)
requireHTFAlign = input.bool(true, "Require HTF + Current Chikou Alignment",
    group=dispGroup,
    tooltip="ON（デフォルト）: 上位足と現在足の遅行スパンが一致した時のみシグナル。\nOFF: 現在足の遅行スパン方向のみでシグナルを出す（シグナル増加）。")

// ==========================================
// Short-term CCI (BUY/SELL)
// ==========================================
cciSGroup        = "Short-term CCI (BUY/SELL)"
cciSLen          = input.int(5,  "Period",        minval=1, group=cciSGroup)
cciSEmaLen       = input.int(2,  "EMA Smoothing", minval=1, group=cciSGroup)
sCciBuyOverride  = input.int(-60, "Buy Override (S-EMA <=)",  group=cciSGroup)
sCciSellOverride = input.int(60,  "Sell Override (S-EMA >=)", group=cciSGroup)
useEmaXTrigger   = input.bool(false, "Use CCI×EMA Cross as Additional Trigger",
    group=cciSGroup,
    tooltip="OFFで±100クロスのみをメインシグナルに。ONでEMAクロスも追加トリガーになるが発火頻度が増える。")


// ==========================================
// Long-term CCI (H-BUY/H-SELL)
// ==========================================
cciLGroup        = "Long-term CCI (H-BUY/H-SELL)"
cciLLen          = input.int(14, "Period",        minval=1, group=cciLGroup)
cciLEmaLen       = input.int(9,  "EMA Smoothing", minval=1, group=cciLGroup)
lCciBuyOverride  = input.int(-60, "Buy Override (L-EMA <=)",  group=cciLGroup)
lCciSellOverride = input.int(60,  "Sell Override (L-EMA >=)", group=cciLGroup)

// ==========================================
// Filter Configuration
// ==========================================
filterGroup    = "Filter Configuration"
useLtfFilter   = input.bool(false, "Use Lower TF Chikou Filter", group=filterGroup)
useEmaFilter   = input.bool(true,  "Use EMA Trend Filter",       group=filterGroup)
emaFastLen     = input.int(9,  "EMA Fast Length", minval=1, group=filterGroup)
emaSlowLen     = input.int(20, "EMA Slow Length", minval=1, group=filterGroup)
useAtrFilter   = input.bool(false, "Use ATR Volatility Filter",  group=filterGroup)
atrLen         = input.int(14, "ATR Length",         minval=1, group=filterGroup)
atrSmaLen      = input.int(20, "ATR Average Length", minval=1, group=filterGroup)
useVolFilter   = input.bool(true, "Use Volume Filter",          group=filterGroup)
volSmaLen      = input.int(26, "Volume Average Length", minval=1, group=filterGroup)
useDepthFilter = input.bool(false, "Use S/L-EMA Depth Filter",   group=filterGroup)
buyDepthLevel  = input.int(-30, "Buy Min Depth (EMA <=)",  group=filterGroup,
    tooltip="この値以下のEMAからの反転のみ許可。-30〜-50推奨。")
sellDepthLevel = input.int(30,  "Sell Min Depth (EMA >=)", group=filterGroup,
    tooltip="この値以上のEMAからの反転のみ許可。30〜50推奨。")

// ==========================================
// Stop Loss Settings
// ==========================================
slGroup      = "Stop Loss"
useSlLine    = input.bool(true,  "Show SL Line on Chart", group=slGroup)
slAtrLen     = input.int(14, minval=1, title="ATR Period for SL", group=slGroup)
slMult       = input.float(1.5, minval=0.5, step=0.25, title="SL ATR Multiplier",
    group=slGroup,
    tooltip="SL = エントリー価格 ± ATR × この値。1.5 = 1.5ATR分の余裕。")
slBars       = input.int(10, minval=5, maxval=200, title="SL Line Duration (bars)",
    group=slGroup,
    tooltip="シグナル発生後この本数だけSLラインを表示する。")

// ==========================================
// CCI Divergence Filter
// ==========================================
divGroup     = "CCI Divergence Filter"
useDivFilter = input.bool(true, "Divergence Filter（シグナル強調）", group=divGroup,
    tooltip="ONにすると、ダイバージェンス確認済みシグナルを金色で強調表示する")
divCciLen    = input.int(5, minval=2, maxval=20, title="CCI Period (Divergence)", group=divGroup,
    tooltip="ダイバージェンス検出専用の短期CCI。メインCCIと分離。推奨: 5")
lbL          = input.int(5, minval=1, maxval=20, title="Pivot Lookback Left",  group=divGroup)
lbR          = input.int(5, minval=1, maxval=20, title="Pivot Lookback Right", group=divGroup)
rangeUpper   = input.int(60, minval=10, maxval=200, title="Max Lookback Range", group=divGroup)
rangeLower   = input.int(5,  minval=1,  maxval=50,  title="Min Lookback Range", group=divGroup)
plotHidBull  = input.bool(false, "Hidden Bullish Divergence 有効", group=divGroup)
plotHidBear  = input.bool(false, "Hidden Bearish Divergence 有効", group=divGroup)

// ==========================================
// Calculations
// ==========================================
emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
atrVal   = ta.atr(atrLen)
atrSma   = ta.sma(atrVal, atrSmaLen)
volSma   = ta.sma(volume, volSmaLen)
slAtrVal = ta.atr(slAtrLen)   // SL専用ATR

calc_cci(len, emaLen) =>
    sma_val = ta.sma(hl2, len)
    cci_val = (hl2 - sma_val) / (0.015 * ta.dev(hl2, len))
    ema_val = ta.ema(cci_val, emaLen)
    [cci_val, ema_val]

[sCci, sCciEma] = calc_cci(cciSLen, cciSEmaLen)
[lCci, lCciEma] = calc_cci(cciLLen, cciLEmaLen)

[lowClose,  lowCloseDisp]  = request.security(syminfo.tickerid, lowerTimeframe,  [close, close[displacement - 1]], barmerge.gaps_off, barmerge.lookahead_off)
[highClose, highCloseDisp] = request.security(syminfo.tickerid, higherTimeframe, [close, close[displacement - 1]], barmerge.gaps_off, barmerge.lookahead_off)

currOffset = displacement - 1
highOffset = int(currOffset * tfRatio)

// ==========================================
// CCI Divergence Detection
// ==========================================
divCciMa = ta.sma(hl2, divCciLen)
divCci   = (hl2 - divCciMa) / (0.015 * ta.dev(hl2, divCciLen))

plFound = not na(ta.pivotlow(divCci,  lbL, lbR))
phFound = not na(ta.pivothigh(divCci, lbL, lbR))

var float cciPL1 = na
var float cciPL2 = na
var float prPL1  = na
var float prPL2  = na
var int   plBar1 = na
var int   plBar2 = na
var float cciPH1 = na
var float cciPH2 = na
var float prPH1  = na
var float prPH2  = na
var int   phBar1 = na
var int   phBar2 = na

if plFound
    cciPL2 := cciPL1
    prPL2  := prPL1
    plBar2 := plBar1
    cciPL1 := divCci[lbR]
    prPL1  := low[lbR]
    plBar1 := bar_index - lbR

if phFound
    cciPH2 := cciPH1
    prPH2  := prPH1
    phBar2 := phBar1
    cciPH1 := divCci[lbR]
    prPH1  := high[lbR]
    phBar1 := bar_index - lbR

bullInRange = not na(plBar1) and not na(plBar2) and (plBar1 - plBar2) >= rangeLower and (plBar1 - plBar2) <= rangeUpper
bearInRange = not na(phBar1) and not na(phBar2) and (phBar1 - phBar2) >= rangeLower and (phBar1 - phBar2) <= rangeUpper

bullDivRaw    = plFound and not na(cciPL1) and not na(cciPL2) and not na(prPL1) and not na(prPL2) and cciPL1 > cciPL2 and prPL1 < prPL2 and bullInRange
bearDivRaw    = phFound and not na(cciPH1) and not na(cciPH2) and not na(prPH1) and not na(prPH2) and cciPH1 < cciPH2 and prPH1 > prPH2 and bearInRange
hidBullDivRaw = plotHidBull and plFound and not na(cciPL1) and not na(cciPL2) and not na(prPL1) and not na(prPL2) and cciPL1 < cciPL2 and prPL1 > prPL2 and bullInRange
hidBearDivRaw = plotHidBear and phFound and not na(cciPH1) and not na(cciPH2) and not na(prPH1) and not na(prPH2) and cciPH1 > cciPH2 and prPH1 < prPH2 and bearInRange

bullDivActive = bullDivRaw or hidBullDivRaw
bearDivActive = bearDivRaw or hidBearDivRaw

// ==========================================
// Trend Logic
// ==========================================
isLtfUp   = not useLtfFilter or (lowClose > lowCloseDisp)
isLtfDown = not useLtfFilter or (lowClose < lowCloseDisp)
isCurrUp  = close > close[displacement - 1]
isCurrDown = close < close[displacement - 1]
isHighUp  = highClose > highCloseDisp
isHighDown = highClose < highCloseDisp

isEmaBullish = emaFast > emaSlow
isEmaBearish = emaFast < emaSlow

// ==========================================
// Filters
// ==========================================
passAtrFilter = not useAtrFilter or (atrVal > atrSma)
passVolFilter = not useVolFilter or (volume > volSma)

passDepthLongS  = not useDepthFilter or (sCciEma <= buyDepthLevel)
passDepthShortS = not useDepthFilter or (sCciEma >= sellDepthLevel)
passDepthLongL  = not useDepthFilter or (lCciEma <= buyDepthLevel)
passDepthShortL = not useDepthFilter or (lCciEma >= sellDepthLevel)

sBuyOverride  = sCciEma <= sCciBuyOverride
sSellOverride = sCciEma >= sCciSellOverride
lBuyOverride  = lCciEma <= lCciBuyOverride
lSellOverride = lCciEma >= lCciSellOverride

passEmaLongS  = not useEmaFilter or (sBuyOverride  or isEmaBullish)
passEmaShortS = not useEmaFilter or (sSellOverride or isEmaBearish)
passEmaLongL  = not useEmaFilter or (lBuyOverride  or isEmaBullish)
passEmaShortL = not useEmaFilter or (lSellOverride or isEmaBearish)

// ==========================================
// Triggers
// ==========================================

// ±100 クロス（生CCI）
sLongMain  = ta.crossover(sCci,  -100)
sShortMain = ta.crossunder(sCci,  100)
lLongMain  = ta.crossover(lCci,  -100)
lShortMain = ta.crossunder(lCci,  100)

// EMAクロストリガー（オプション）
sLongEmaX  = useEmaXTrigger and ta.crossover(sCci,  sCciEma)
sShortEmaX = useEmaXTrigger and ta.crossunder(sCci,  sCciEma)
lLongEmaX  = useEmaXTrigger and ta.crossover(lCci,  lCciEma)
lShortEmaX = useEmaXTrigger and ta.crossunder(lCci,  lCciEma)

sLongTrigger  = sLongMain  or sLongEmaX
sShortTrigger = sShortMain or sShortEmaX
lLongTrigger  = lLongMain  or lLongEmaX
lShortTrigger = lShortMain or lShortEmaX

// ==========================================
// Signal Logic
// 上位足Chikou × 現在足Chikou の方向一致
// BUY=短期CCI、H-BUY=長期CCI
// ==========================================
// requireHTFAlign ON: 上位足+現在足の一致 / OFF: 現在足のみ
chikouBullish = requireHTFAlign ? (isHighUp   and isCurrUp)   : isCurrUp
chikouBearish = requireHTFAlign ? (isHighDown and isCurrDown) : isCurrDown

ltfBullOk = not useLtfFilter or isLtfUp
ltfBearOk = not useLtfFilter or isLtfDown

shortTermBuyRaw  = chikouBullish and ltfBullOk and passEmaLongS  and passAtrFilter and passVolFilter and passDepthLongS  and sLongTrigger
shortTermSellRaw = chikouBearish and ltfBearOk and passEmaShortS and passAtrFilter and passVolFilter and passDepthShortS and sShortTrigger
longTermBuyRaw   = chikouBullish and ltfBullOk and passEmaLongL  and passAtrFilter and passVolFilter and passDepthLongL  and lLongTrigger
longTermSellRaw  = chikouBearish and ltfBearOk and passEmaShortL and passAtrFilter and passVolFilter and passDepthShortL and lShortTrigger

shortTermBuy  = shortTermBuyRaw  and not shortTermBuyRaw[1]
shortTermSell = shortTermSellRaw and not shortTermSellRaw[1]
longTermBuy   = longTermBuyRaw   and not longTermBuyRaw[1]
longTermSell  = longTermSellRaw  and not longTermSellRaw[1]

shortBuyWithDiv  = shortTermBuy  and bullDivActive and useDivFilter
shortSellWithDiv = shortTermSell and bearDivActive and useDivFilter
longBuyWithDiv   = longTermBuy   and bullDivActive and useDivFilter
longSellWithDiv  = longTermSell  and bearDivActive and useDivFilter

// ==========================================
// Stop Loss Calculation
// ==========================================
var float slLineVal  = na   // SL価格を保持
var int   slBarsSince = 999

if shortTermBuy or longTermBuy
    slLineVal   := close - slAtrVal * slMult
    slBarsSince := 0
else if shortTermSell or longTermSell
    slLineVal   := close + slAtrVal * slMult
    slBarsSince := 0
else
    slBarsSince := slBarsSince + 1

// 有効期間内のみ値を返し、期間外は na → linebr で線が途切れる
slLine    = useSlLine and slBarsSince <= slBars ? slLineVal : na
showSlNow = not na(slLine)

// ==========================================
// Plot — EMA
// ==========================================
plot(series=emaFast, title="EMA Fast", color=color.new(color.gray, 50))
plot(series=emaSlow, title="EMA Slow", color=color.new(color.gray, 70))

// ==========================================
// Plot — Chikou Span（両方ステップライン・不透明度70%・線幅最小）
// ==========================================
plot(series=showCurrent ? close     : na,
    title="Current Chikou",
    color=color.new(color.lime, 30),
    offset=-currOffset,
    linewidth=1,
    style=plot.style_stepline)

plot(series=showHigher  ? highClose : na,
    title="Higher Chikou",
    color=color.new(#FF9800, 30),
    offset=-highOffset,
    linewidth=1,
    style=plot.style_stepline)

// ==========================================
// Plot — Entry Signals
// ==========================================

// 通常シグナル
plotshape(shortTermBuy  and not shortBuyWithDiv,  title="Short Buy",      style=shape.triangleup,   location=location.belowbar, color=color.lime,               size=size.small, text="BUY")
plotshape(shortTermSell and not shortSellWithDiv, title="Short Sell",     style=shape.triangledown, location=location.abovebar, color=color.red,                size=size.small, text="SELL")
plotshape(longTermBuy   and not longBuyWithDiv,   title="Long Buy",       style=shape.labelup,      location=location.belowbar, color=color.blue,               size=size.tiny,  text="H-BUY",   textcolor=color.white)
plotshape(longTermSell  and not longSellWithDiv,  title="Long Sell",      style=shape.labeldown,    location=location.abovebar, color=color.maroon,             size=size.tiny,  text="H-SELL",  textcolor=color.white)

// ダイバージェンス確認済みシグナル（金色強調）
plotshape(shortBuyWithDiv,  title="Short Buy +DIV",  style=shape.triangleup,   location=location.belowbar, color=color.new(#FF6F00, 0), size=size.normal, text="BUY+D")
plotshape(shortSellWithDiv, title="Short Sell +DIV", style=shape.triangledown, location=location.abovebar, color=color.new(#FF6F00, 0), size=size.normal, text="SELL+D")
plotshape(longBuyWithDiv,   title="Long Buy +DIV",   style=shape.labelup,      location=location.belowbar, color=color.new(#FF6F00, 0), size=size.small,  text="H-BUY+D",  textcolor=color.white)
plotshape(longSellWithDiv,  title="Long Sell +DIV",  style=shape.labeldown,    location=location.abovebar, color=color.new(#FF6F00, 0), size=size.small,  text="H-SELL+D", textcolor=color.white)

// SL Line
plot(slLine,
    title="Stop Loss",
    color=color.new(#EF5350, 0),
    linewidth=1,
    style=plot.style_linebr)

// ==========================================
// Dashboard Table（動的行数：OFFの項目は非表示）
// ==========================================
c_bg    = color.new(color.black, 30)
c_gray  = color.new(color.gray,  60)
c_blue  = color.new(color.blue,  40)
c_red   = color.new(color.red,   40)
c_green = color.new(color.green, 40)
c_warn  = color.new(color.orange,40)
c_gold  = color.new(#FF6F00,     40)
c_teal  = color.new(#FF9800,     40)

// 動的行数計算（常時表示 + ONのフィルターのみカウント）
// 常時: HTF Chikou, Curr Chikou, Chikou Align, Chikou TF, CCI L-EMA, CCI S-EMA, Signal = 7行
// 条件付き: LTF, EMA Filter, EMA×Trigger, ATR, Volume, Depth, CCI DIV = 最大7行
// dynRows: 行数は table.new の固定値14で確保済み（動的行は r 変数で管理）

var table tbl = table.new(position.top_right, 2, 16, bgcolor=c_bg, border_color=color.gray, border_width=1)

if barstate.islast
    isAnyOverride = sBuyOverride or sSellOverride or lBuyOverride or lSellOverride

    // 時間足ラベルを変数に事前定義
    htfLabel  = "HTF (" + higherTimeframe + ")"
    currLabel = "Curr (" + timeframe.period + ")"
    ltfLabel  = "LTF (" + lowerTimeframe + ")"

    // 動的行インデックス管理
    var int r = 0
    r := 0

    // ── 常時表示 ──

    // HTF Chikou（時間足名付き）
    table.cell(tbl, 0, r, htfLabel, text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, r, isHighUp ? "▲ UP" : isHighDown ? "▼ DOWN" : "— FLAT", bgcolor=isHighUp ? c_blue : isHighDown ? c_red : c_gray, text_color=color.white, text_size=size.small)
    r := r + 1

    // Current Chikou（時間足名付き）
    table.cell(tbl, 0, r, currLabel, text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, r, isCurrUp ? "▲ UP" : isCurrDown ? "▼ DOWN" : "— FLAT", bgcolor=isCurrUp ? c_green : isCurrDown ? c_red : c_gray, text_color=color.white, text_size=size.small)
    r := r + 1

    // Chikou Align
    alignLabel       = requireHTFAlign ? "Chikou Align" : "Curr Chikou"
    alignTextHTF     = chikouBullish ? "▲ BULL ALIGN" : chikouBearish ? "▼ BEAR ALIGN" : "— CONFLICT"
    alignTextCurr    = chikouBullish ? "▲ BULL (Curr)" : chikouBearish ? "▼ BEAR (Curr)" : "— FLAT"
    chikouAlignText  = requireHTFAlign ? alignTextHTF : alignTextCurr
    chikouAlignColor = chikouBullish ? c_green : chikouBearish ? c_red : c_gray
    table.cell(tbl, 0, r, alignLabel, text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, r, chikouAlignText, bgcolor=chikouAlignColor, text_color=color.white, text_size=size.small)
    r := r + 1

    // ── 条件付き表示（ONのものだけ） ──

    if useLtfFilter
        table.cell(tbl, 0, r, ltfLabel, text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, isLtfUp ? "▲ UP" : isLtfDown ? "▼ DOWN" : "—", bgcolor=isLtfUp ? c_green : isLtfDown ? c_red : c_gray, text_color=color.white, text_size=size.small)
        r := r + 1

    if useEmaFilter
        table.cell(tbl, 0, r, "EMA Filter", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, isAnyOverride ? "OVERRIDE" : isEmaBullish ? "BULL" : isEmaBearish ? "BEAR" : "—", bgcolor=isAnyOverride ? c_warn : isEmaBullish ? c_green : c_red, text_color=color.white, text_size=size.small)
        r := r + 1

    if useEmaXTrigger
        table.cell(tbl, 0, r, "EMA×Trigger", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, "ON", bgcolor=c_warn, text_color=color.white, text_size=size.small)
        r := r + 1

    if useAtrFilter
        table.cell(tbl, 0, r, "ATR Filter", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, atrVal > atrSma ? "HIGH" : "LOW", bgcolor=atrVal > atrSma ? c_green : c_red, text_color=color.white, text_size=size.small)
        r := r + 1

    if useVolFilter
        table.cell(tbl, 0, r, "Volume", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, volume > volSma ? "HIGH" : "LOW", bgcolor=volume > volSma ? c_green : c_red, text_color=color.white, text_size=size.small)
        r := r + 1

    if useDepthFilter
        sDepthOk = sCciEma <= buyDepthLevel or sCciEma >= sellDepthLevel
        lDepthOk = lCciEma <= buyDepthLevel or lCciEma >= sellDepthLevel
        table.cell(tbl, 0, r, "Depth Filter", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, sDepthOk or lDepthOk ? "PASS" : "BLOCK", bgcolor=sDepthOk or lDepthOk ? c_green : c_red, text_color=color.white, text_size=size.small)
        r := r + 1

    if useDivFilter
        divText  = bullDivActive ? "★ Bull DIV" : bearDivActive ? "★ Bear DIV" : "-"
        divColor = bullDivActive or bearDivActive ? c_gold : c_gray
        table.cell(tbl, 0, r, "CCI DIV", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, divText, bgcolor=divColor, text_color=color.white, text_size=size.small)
        r := r + 1

    // ── 常時表示（下部固定） ──

    table.cell(tbl, 0, r, "CCI L-EMA", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, r, str.tostring(lCciEma, "#.##"), text_color=lCciEma > 0 ? color.lime : color.red, text_size=size.small)
    r := r + 1

    table.cell(tbl, 0, r, "CCI S-EMA", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, r, str.tostring(sCciEma, "#.##"), text_color=sCciEma > 0 ? color.lime : color.red, text_size=size.small)
    r := r + 1

    if showSlNow
        slText = str.tostring(slLine, "#.####")
        table.cell(tbl, 0, r, "Stop Loss", text_color=color.white, text_size=size.small)
        table.cell(tbl, 1, r, slText, bgcolor=color.new(#EF5350, 50), text_color=color.white, text_size=size.small)
        r := r + 1

    sigText  = shortBuyWithDiv ? "▲ BUY+D" : shortSellWithDiv ? "▽ SELL+D" : longBuyWithDiv ? "▲ H-BUY+D" : longSellWithDiv ? "▽ H-SELL+D" : shortTermBuy ? "▲ BUY" : shortTermSell ? "▽ SELL" : longTermBuy ? "▲ H-BUY" : longTermSell ? "▽ H-SELL" : "-"
    sigBg    = shortBuyWithDiv or longBuyWithDiv ? c_gold : shortSellWithDiv or longSellWithDiv ? c_gold : shortTermBuy or longTermBuy ? c_green : shortTermSell or longTermSell ? c_red : c_gray
    table.cell(tbl, 0, r, "Signal", text_color=color.white, text_size=size.small)
    table.cell(tbl, 1, r, sigText, bgcolor=sigBg, text_color=color.white, text_size=size.small)

// ==========================================
// Alerts
// ==========================================
alertcondition(shortTermBuy  or longTermBuy,           title="Entry Buy",         message="Entry Long Signal")
alertcondition(shortTermSell or longTermSell,           title="Entry Sell",        message="Entry Short Signal")
alertcondition(shortBuyWithDiv or longBuyWithDiv,       title="Entry Buy +DIV ★",  message="Entry Long + CCI Divergence Confirmed")
alertcondition(shortSellWithDiv or longSellWithDiv,     title="Entry Sell +DIV ★", message="Entry Short + CCI Divergence Confirmed")

if shortTermBuy or longTermBuy
    alert("Entry Long Signal", alert.freq_once_per_bar_close)
if shortTermSell or longTermSell
    alert("Entry Short Signal", alert.freq_once_per_bar_close)
if shortBuyWithDiv or longBuyWithDiv
    alert("Entry Long +DIV ★", alert.freq_once_per_bar_close)
if shortSellWithDiv or longSellWithDiv
    alert("Entry Short +DIV ★", alert.freq_once_per_bar_close)

// SL到達アラート（SLラインが有効な期間中に価格が触れた時）
slActive   = showSlNow
slHitLong  = slActive and low  <= slLine and slBarsSince > 0
slHitShort = slActive and high >= slLine and slBarsSince > 0
alertcondition(slHitLong,  title="SL Hit (Long)",  message="Stop Loss Hit — Long position exit")
alertcondition(slHitShort, title="SL Hit (Short)", message="Stop Loss Hit — Short position exit")
````
