# EMA Volume Trend Signals

- url: https://www.tradingview.com/script/nudfIwcl/
- type: indicator
- pine_id: PUB;3549e9c0b52845f484e1c9bf5868ccc9
- version: 2.0

## Description

# EMA Volume Trend Signals v6

[中文文档](README.md) | English

A Pine Script v6 trend-following indicator for TradingView, designed for altcoin short-to-mid-term swing trading. The script uses **SuperTrend** for trend direction, a multi-layer EMA structure (EMA20 / EMA144·169 / EMA576·696) to identify short-term momentum, core trend zone, and long-term trend zone, combined with volume analysis, ADX/DI health checks, and higher-timeframe filtering to generate staged entry, partial exit, and full exit signals.

> This project is intended for strategy research and signal assistance only. It does not constitute financial advice.

## Features

- Overlays SuperTrend, EMA20, EMA144, EMA169, EMA576, and EMA696 on the main chart.
- Higher-timeframe direction filter (default 4H).
- Generates buy signals based on trend structure, volume, ADX/DI, and pullback conditions.
- Staged position building with up to 4 position units (configurable).
- Supports partial reduce on weakness, core structure breakdown, and full exit on trend reversal.
- Built-in TradingView `alertcondition` for alerts and webhooks.
- Optional background color highlights for breakout, pullback, reduce, and exit zones.

## Quick Start

1. Open TradingView and navigate to any crypto chart.
2. Open the **Pine Editor** panel.
3. Copy the entire content of `tradingview_ema_volume_signal_v6.pine` and paste it in.
4. Click **Add to chart**.
5. Adjust parameters for your trading pair and timeframe.

Recommended timeframes for observation: **30m**, **1h**, **4h**. Lower timeframes tend to produce more noise and wicks on altcoins.

## Signal Types

### Buy Signals

The script displays buy labels when trend conditions are met:

- **Buy 20%** — Default trial or standard add position size (adjustable).
- **Buy 10%** — Default setup add size for earlier probing within a consolidation.
- The first buy may come from a trial entry, breakout, fresh trend initiation, or an early strength reclaim near the core EMA zone.
- Subsequent buys include: move add (price progression), trend add (trend continuation), setup add (consolidation breakout), breakout add (volume breakout), reclaim add (EMA reclaim after pullback), and pullback add (low-volume pullback to EMA support). Each requires volume-price progression relative to the last buy.

Key filters:

- SuperTrend is bullish.
- Higher-timeframe filter passes.
- Price is above EMA20 or breaking through the EMA144/169 core zone.
- Volume meets breakout or pullback thresholds.
- ADX and DI structure is healthy.
- No recent reduce, core breakdown, or bearish risk events.
- Price is not overly extended from EMA20 or SuperTrend.
- The second add uses a tighter ATR progression threshold but requires a volume breakout above recent highs, a buffer above the core zone, and non-weakening EMA slopes. Later adds require the larger `Move Add ATR` distance.
- Setup adds capture consolidation patterns where price holds above EMA20, range compresses, and volume has not yet broken out.
- Reclaim adds trigger when price revisits EMA20/core support and reclaims above EMA20 with strength; blocked if the pullback from recent highs is too deep or EMA20 is weakening.

### Sell Signals

The script displays reduce labels when trend weakens but has not fully reversed:

- **Sell 25%** — Light reduce (default requires structure risk confirmation).
- **Sell 50%** — Core structure breakdown reduce.

Common triggers:

- Consecutive closes below the EMA144/169 core zone.
- Price breaks below EMA20 buffer with confirmation, and structure risk is present.
- DI+ weakening with optional DI− > DI+ crossover requirement.
- SuperTrend still bullish but structural risk has emerged.

### Exit Signal

**Exit 100%** indicates a full trend exit, typically triggered when SuperTrend flips bearish. All position stages are reset, marking the end of a trend cycle.

## Key Parameters

### Trend

| Parameter | Default | Description |
|---|---|---|
| SuperTrend ATR Length | 10 | ATR period for SuperTrend |
| SuperTrend Factor | 3.0 | SuperTrend multiplier |

### EMA Structure

| Parameter | Default | Description |
|---|---|---|
| EMA20 | 20 | Short-term momentum line |
| EMA144 / EMA169 | 144 / 169 | Core trend zone |
| EMA576 / EMA696 | 576 / 696 | Long-term trend zone |

### Multi Timeframe

| Parameter | Default | Description |
|---|---|---|
| Use HTF Filter | true | Enable higher-timeframe direction filter |
| HTF Direction | 240 (4H) | Higher-timeframe resolution in minutes |

### Volume

| Parameter | Default | Description |
|---|---|---|
| Volume MA Length | 20 | Volume moving average period |
| Breakout Volume Multiplier | 1.25 | Volume ratio required for breakout |
| Pullback Max Volume Multiplier | 0.95 | Max volume ratio for low-volume pullback |
| Weak Rally Volume Multiplier | 0.75 | Min volume for trial buy |
| Use Volume Price Filter For Adds | true | Enable volume-price filter for add signals |
| Volume Price Lookback | 3 | Bars to check for recent bearish volume pressure |
| Bear Pressure Volume Multiplier | 1.10 | Volume threshold for bearish candle identification |
| Bull Reclaim Volume Multiplier | 0.95 | Volume required to confirm bullish reclaim |

### ADX Health

| Parameter | Default | Description |
|---|---|---|
| Min ADX For Add | 18.0 | Minimum ADX value for add signals |
| Require ADX Rising For Add | true | ADX must be rising for adds |
| Require DI+ > DI- For Add | true | DI+ must exceed DI− for adds |
| Use Early Sell On Momentum Weakness | true | Enable early sell when momentum fades |

### Signals

| Parameter | Default | Description |
|---|---|---|
| Stable Closes Above Core EMA | 2 | Bars to confirm price above core zone |
| Signal Cooldown Bars | 3 | Cooldown between same-type signals |
| Stage Cooldown Bars | 12 | Cooldown between staged buys |
| Reclaim Add Cooldown Bars | 8 | Cooldown for reclaim add signals |
| Setup Add Lookback | 4 | Lookback for consolidation range |
| Setup Add Max Range ATR | 1.2 | Max ATR range for setup consolidation |
| Max Position Units | 4 | Maximum staged position units |
| Second Add ATR From Last Buy | 1.2 | Min ATR progression for second add |
| Move Add ATR From Last Buy | 2.0 | Min ATR progression for move add |
| Late Add Max Distance From EMA20 ATR | 1.2 | Max distance from EMA20 for late adds |
| Trend Add Max Distance From EMA20 ATR | 2.2 | Max distance from EMA20 for trend adds |
| Breakout Add Lookback | 20 | Lookback for breakout reference high |
| Breakout Add Max Distance From EMA20 ATR | 3.0 | Max distance from EMA20 for breakout adds |
| Sell Grace Bars After Buy | 8 | Bars to wait after buy before allowing sell |
| EMA20 Sell Buffer ATR | 0.30 | Buffer below EMA20 for light sell |
| EMA20 Sell Confirm Bars | 3 | Bars to confirm EMA20 sell |
| Sell Requires Structure Risk | true | Require structure risk before selling |
| Trial Buy % | 20 | Position size label for trial buy |
| Setup Buy % | 10 | Position size label for setup add |
| Add Buy % | 20 | Position size label for standard add |
| Light Sell % | 25 | Position size label for light reduce |
| Core Sell % | 50 | Position size label for core reduce |

### Visual

| Parameter | Default | Description |
|---|---|---|
| Show Background | true | Display background color highlights |
| Show EMA Lines | true | Display EMA lines on chart |
| Label Offset ATR | 1.0 | Vertical offset of labels from candles in ATR units |

## Alert Configuration

The script includes 3 built-in `alertcondition` definitions:

- **Buy Signal**
- **Sell Reduce Signal**
- **Exit Signal**

Default alert messages:

```text
Buy signal: {{ticker}} {{interval}}
Sell reduce signal: {{ticker}} {{interval}}
Exit signal: {{ticker}} {{interval}}
```

For webhook integration, configure a webhook URL in the TradingView alert dialog and customize the message body with exchange, position size, order side, and other fields as needed.

## Risk Management Notes

- Individual signals should not be treated as full position trades. The script is designed for staged position building by default.
- Altcoins are highly correlated. When holding multiple positions, control overall beta exposure.
- Volume breakouts suit trend initiation; low-volume pullbacks suit trend continuation. Backtest each scenario in different market regimes.
- For high-volatility assets, consider increasing cooldown periods and reducing per-signal position sizes.
- After a full exit signal, wait for the next trend cycle to establish before re-entering. Avoid immediately counter-trading.

## Files

- `tradingview_ema_volume_signal_v6.pine` — TradingView Pine Script v6 indicator source code.
- `README.md` — 中文文档
- `README_EN.md` — English documentation

## Source Code

````pine
//@version=6
indicator("EMA Volume Trend Signals v6", overlay=true, max_labels_count=500)

// ---------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------
groupTrend = "Trend"
stAtrLen = input.int(10, "SuperTrend ATR Length", minval=1, group=groupTrend)
stFactor = input.float(3.0, "SuperTrend Factor", minval=0.1, step=0.1, group=groupTrend)

groupEma = "EMA Structure"
emaFastLen = input.int(20, "EMA20", minval=1, group=groupEma)
emaCore1Len = input.int(144, "EMA144", minval=1, group=groupEma)
emaCore2Len = input.int(169, "EMA169", minval=1, group=groupEma)
emaLong1Len = input.int(576, "EMA576", minval=1, group=groupEma)
emaLong2Len = input.int(696, "EMA696", minval=1, group=groupEma)

groupMtf = "Multi Timeframe"
useHtfFilter = input.bool(true, "Use HTF Filter", group=groupMtf)
htf = input.timeframe("240", "HTF Direction", group=groupMtf)

groupVol = "Volume"
volLen = input.int(20, "Volume MA Length", minval=1, group=groupVol)
breakoutVolMult = input.float(1.25, "Breakout Volume Multiplier", minval=0.1, step=0.05, group=groupVol)
pullbackVolMax = input.float(0.95, "Pullback Max Volume Multiplier", minval=0.1, step=0.05, group=groupVol)
weakVolMax = input.float(0.75, "Weak Rally Volume Multiplier", minval=0.1, step=0.05, group=groupVol)
useVolumePriceFilter = input.bool(true, "Use Volume Price Filter For Adds", group=groupVol)
vpLookback = input.int(3, "Volume Price Lookback", minval=1, maxval=10, group=groupVol)
vpBearVolMult = input.float(1.10, "Bear Pressure Volume Multiplier", minval=0.1, step=0.05, group=groupVol)
vpBullVolMin = input.float(0.95, "Bull Reclaim Volume Multiplier", minval=0.1, step=0.05, group=groupVol)

groupOb = "Order Block / OBV"
useObForBuy = input.bool(true, "Use Bullish OB For Buy Reference", group=groupOb)
obPivotLen = input.int(5, "OB Swing Lookback", minval=2, maxval=20, group=groupOb)
obDisplacementAtr = input.float(0.8, "OB Breakout Displacement ATR", minval=0.1, step=0.1, group=groupOb)
obMaxAge = input.int(80, "Bullish OB Max Age Bars", minval=5, maxval=300, group=groupOb)
obRetestBufferAtr = input.float(0.25, "OB Retest Buffer ATR", minval=0.0, step=0.05, group=groupOb)
referenceAddAtr = input.float(0.8, "OB/OBV Add ATR From Last Buy", minval=0.1, step=0.1, group=groupOb)
showObZones = input.bool(true, "Show Bullish OB Zone", group=groupOb)
useObvDivergenceForBuy = input.bool(true, "Use OBV Bullish Divergence For Buy", group=groupOb)
useObvBearishDivergenceBlock = input.bool(true, "Block Add On Recent OBV Bearish Divergence", group=groupOb)
obvPivotLen = input.int(5, "OBV Divergence Pivot Length", minval=2, maxval=20, group=groupOb)
obvDivergenceMaxAge = input.int(50, "OBV Divergence Max Age Bars", minval=5, maxval=200, group=groupOb)

groupAdx = "ADX Health"
adxLen = input.int(14, "ADX Length", minval=1, group=groupAdx)
adxSmooth = input.int(14, "ADX Smoothing", minval=1, group=groupAdx)
adxMin = input.float(22.0, "Min ADX For Add", minval=1, step=0.5, group=groupAdx)
requireAdxRisingForAdd = input.bool(true, "Require ADX Rising For Add", group=groupAdx)
requireDiForAdd = input.bool(true, "Require DI+ > DI- For Add", group=groupAdx)
useEarlySell = input.bool(true, "Use Early Sell On Momentum Weakness", group=groupAdx)
diWeakBars = input.int(2, "DI Weak Bars For Early Sell", minval=1, maxval=5, group=groupAdx)
earlySellRequireDiCross = input.bool(true, "Early Sell Requires DI- > DI+", group=groupAdx)

useRsiOverboughtFilter = input.bool(true, "Block Add When RSI Overbought", group=groupAdx)
rsiLen = input.int(14, "RSI Length", minval=1, group=groupAdx)
rsiOverbought = input.float(72.0, "RSI Overbought Threshold", minval=50, maxval=95, step=1.0, group=groupAdx)

useDiFallingFilter = input.bool(true, "Block Add When DI+ Falling", group=groupAdx)
diFallingLookback = input.int(3, "DI+ Falling Bars To Block", minval=1, maxval=5, group=groupAdx)

useCycleHighFilter = input.bool(true, "Block Add Near Cycle High", group=groupAdx)
cycleHighLookback = input.int(30, "Cycle High Lookback", minval=5, maxval=100, group=groupAdx)
cycleHighBufferAtr = input.float(0.5, "Cycle High Buffer ATR", minval=0.1, step=0.1, group=groupAdx)

requireAdxForTrial = input.bool(true, "Require ADX For Trial Buy", group=groupAdx)
requireHtfForFreshTrend = input.bool(true, "Require HTF For Fresh Trend Buy", group=groupAdx)
requireAdxForFreshTrend = input.bool(true, "Require ADX For Fresh Trend Buy", group=groupAdx)
trialMinVolRatio = input.float(1.25, "Trial Buy Min Volume Ratio", minval=0.5, step=0.05, group=groupAdx)
diMinSpread = input.float(1.5, "Min DI+ - DI- Spread For Buy", minval=0.0, step=0.1, group=groupAdx)

groupSignal = "Signals"
stableBars = input.int(2, "Stable Closes Above Core EMA", minval=1, maxval=5, group=groupSignal)
pullbackLookback = input.int(5, "Pullback Lookback", minval=1, group=groupSignal)
pullbackAtrDistance = input.float(0.8, "Pullback Distance ATR", minval=0.1, step=0.1, group=groupSignal)
signalCooldown = input.int(8, "Signal Cooldown Bars", minval=0, group=groupSignal)
stageCooldown = input.int(15, "Stage Cooldown Bars", minval=1, group=groupSignal)
reclaimAddCooldown = input.int(8, "Reclaim Add Cooldown Bars", minval=1, group=groupSignal)
setupAddLookback = input.int(4, "Setup Add Lookback", minval=2, group=groupSignal)
setupAddRangeAtr = input.float(1.2, "Setup Add Max Range ATR", minval=0.2, step=0.1, group=groupSignal)
maxBuyStages = input.int(4, "Max Position Units", minval=1, maxval=10, group=groupSignal)
maxSellStages = input.int(2, "Max Reduce Signals Per Trend", minval=1, maxval=3, group=groupSignal)
sellResetOnBuy = input.bool(true, "Reset Sell Stage On New Buy", group=groupSignal)
postSellBuyBlockBars = input.int(10, "Extra Buy Block Bars After Sell", minval=0, maxval=20, group=groupSignal)
secondAddAtr = input.float(1.2, "Second Add ATR From Last Buy", minval=0.2, step=0.1, group=groupSignal)
secondAddBreakoutLookback = input.int(8, "Second Add Breakout Lookback", minval=2, maxval=20, group=groupSignal)
secondAddCoreBufferAtr = input.float(0.20, "Second Add Core Breakout Buffer ATR", minval=0.0, step=0.05, group=groupSignal)
moveAddAtr = input.float(2.0, "Move Add ATR From Last Buy", minval=0.2, step=0.1, group=groupSignal)
lateAddMaxDistanceAtr = input.float(1.2, "Late Add Max Distance From EMA20 ATR", minval=0.2, step=0.1, group=groupSignal)
trendAddMaxDistanceAtr = input.float(2.2, "Trend Add Max Distance From EMA20 ATR", minval=0.5, step=0.1, group=groupSignal)
breakoutAddLookback = input.int(20, "Breakout Add Lookback", minval=2, group=groupSignal)
breakoutAddMaxDistanceAtr = input.float(3.0, "Breakout Add Max Distance From EMA20 ATR", minval=0.5, step=0.1, group=groupSignal)
exitGraceBars = input.int(2, "Exit Grace Bars After Buy", minval=0, maxval=10, group=groupSignal)
sellGraceBars = input.int(12, "Sell Grace Bars After Buy", minval=0, maxval=30, group=groupSignal)
allowEma20LightSell = input.bool(true, "Allow EMA20 Light Sell", group=groupSignal)
ema20SellBufferAtr = input.float(0.30, "EMA20 Sell Buffer ATR", minval=0.0, step=0.05, group=groupSignal)
ema20SellConfirmBars = input.int(3, "EMA20 Sell Confirm Bars", minval=1, maxval=5, group=groupSignal)
sellRequiresStructureRisk = input.bool(true, "Sell Requires Structure Risk", group=groupSignal)
maxPullbackFromHighAtr = input.float(2.2, "No Pullback Buy If Drop From High ATR", minval=0.5, step=0.1, group=groupSignal)
recentRiskBlockBars = input.int(6, "Block Buy After Risk Bars", minval=0, maxval=20, group=groupSignal)
minSupertrendDistanceAtr = input.float(0.20, "Min Distance Above SuperTrend ATR", minval=0.0, step=0.05, group=groupSignal)
trialBuyPct = input.int(20, "Trial Buy %", minval=1, maxval=100, group=groupSignal)
setupBuyPct = input.int(10, "Setup Buy %", minval=1, maxval=100, group=groupSignal)
addBuyPct = input.int(20, "Add Buy %", minval=1, maxval=100, group=groupSignal)
lightSellPct = input.int(25, "Light Sell %", minval=1, maxval=100, group=groupSignal)
coreSellPct = input.int(50, "Core Sell %", minval=1, maxval=100, group=groupSignal)
useMomentumTp = input.bool(true, "Use Momentum Take-Profit", group=groupSignal)
momentumTpDropAtr = input.float(1.5, "Momentum TP Drop From High ATR", minval=0.5, step=0.1, group=groupSignal)
momentumTpSwingLookback = input.int(20, "Momentum TP Swing High Lookback", minval=5, maxval=50, group=groupSignal)
momentumTpMinProfitAtr = input.float(2.0, "Momentum TP Min Profit ATR", minval=0.2, step=0.1, group=groupSignal)
momentumTpPct = input.int(25, "Momentum TP %", minval=1, maxval=100, group=groupSignal)

groupRisk = "Take Profit / Stop Loss"
useHardStop = input.bool(true, "Use ATR Hard Stop", group=groupRisk)
hardStopAtr = input.float(2.2, "Hard Stop ATR From Avg Entry", minval=0.5, step=0.1, group=groupRisk)
useTrailingStop = input.bool(true, "Use ATR Trailing Exit", group=groupRisk)
trailingStartAtr = input.float(2.5, "Trailing Start Profit ATR", minval=0.5, step=0.1, group=groupRisk)
trailingStopAtr = input.float(1.8, "Trailing Stop From Peak ATR", minval=0.5, step=0.1, group=groupRisk)
useExtensionTp = input.bool(true, "Use Extension Take-Profit", group=groupRisk)
extensionTpDistanceAtr = input.float(3.0, "Extension TP Distance From EMA20 ATR", minval=0.5, step=0.1, group=groupRisk)
extensionTpMinProfitAtr = input.float(1.5, "Extension TP Min Profit ATR", minval=0.2, step=0.1, group=groupRisk)
extensionTpPct = input.int(25, "Extension TP %", minval=1, maxval=100, group=groupRisk)
showRiskLines = input.bool(true, "Show Stop/Trailing Lines", group=groupRisk)

breakoutHoldBars = input.int(2, "Breakout Hold Bars (anti false-breakout)", minval=1, maxval=5, group=groupSignal)

groupVisual = "Visual"
showBg = input.bool(true, "Show Background", group=groupVisual)
showEma = input.bool(true, "Show EMA Lines", group=groupVisual)
labelOffsetAtr = input.float(1.0, "Label Offset ATR", minval=0.0, step=0.05, group=groupVisual)

// ---------------------------------------------------------------------
// Indicators
// ---------------------------------------------------------------------
[st, stDir] = ta.supertrend(stFactor, stAtrLen)
stBull = stDir < 0
stBear = stDir > 0

ema20 = ta.ema(close, emaFastLen)
ema144 = ta.ema(close, emaCore1Len)
ema169 = ta.ema(close, emaCore2Len)
ema576 = ta.ema(close, emaLong1Len)
ema696 = ta.ema(close, emaLong2Len)
coreUpper = math.max(ema144, ema169)
coreLower = math.min(ema144, ema169)

atr = ta.atr(14)
volMa = ta.sma(volume, volLen)
volRatio = volMa > 0 ? volume / volMa : 0.0
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxSmooth)
rsi = ta.rsi(close, rsiLen)
obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0.0)
cycleHigh = ta.highest(high, cycleHighLookback)
rsiOverboughtNow = useRsiOverboughtFilter and rsi >= rsiOverbought
diPlusFallingCalc = ta.falling(diPlus, diFallingLookback)
diPlusExhausted = useDiFallingFilter and diPlusFallingCalc
nearCycleHigh = useCycleHighFilter and high >= cycleHigh - atr * cycleHighBufferAtr

htfClose = request.security(syminfo.tickerid, htf, close[1], lookahead=barmerge.lookahead_on)
htfEma144 = request.security(syminfo.tickerid, htf, ta.ema(close, emaCore1Len)[1], lookahead=barmerge.lookahead_on)
htfEma169 = request.security(syminfo.tickerid, htf, ta.ema(close, emaCore2Len)[1], lookahead=barmerge.lookahead_on)
htfCore = math.max(htfEma144, htfEma169)
f_htfStDir() =>
    [_, dir] = ta.supertrend(stFactor, stAtrLen)
    dir

htfStDir = request.security(syminfo.tickerid, htf, f_htfStDir()[1], lookahead=barmerge.lookahead_on)
htfBullOk = not useHtfFilter or htfClose > htfCore or htfStDir < 0

// ---------------------------------------------------------------------
// State variables (declared early for use in signal logic)
// ---------------------------------------------------------------------
var int buyStage = 0
var int sellStage = 0
var int lastBuyBar = na
var int lastSellBar = na
var bool coreConfirmed = false
var float lastBuyPrice = na
var bool inLongCycle = false
var float avgBuyPrice = na
var float buyWeightSum = 0.0
var float peakSinceEntry = na
var float lastBullObLow = na
var float lastBullObHigh = na
var int lastBullObBar = na
var float prevPricePivotLow = na
var float prevObvPivotLow = na
var int lastObvBullDivBar = na
var float prevPricePivotHigh = na
var float prevObvPivotHigh = na
var int lastObvBearDivBar = na

// ---------------------------------------------------------------------
// Signal logic
// ---------------------------------------------------------------------
aboveCoreStable = ta.lowest(close - coreUpper, stableBars) > 0

bearishCandle = close < open
bullishBreakout = close > ta.highest(high[1], obPivotLen) and close - open >= atr * obDisplacementAtr
bullObOffset = ta.barssince(bearishCandle)
newBullOb = useObForBuy and bullishBreakout and not na(bullObOffset) and bullObOffset > 0 and bullObOffset <= obPivotLen
if newBullOb
    lastBullObLow := low[bullObOffset]
    lastBullObHigh := open[bullObOffset]
    lastBullObBar := bar_index - bullObOffset

bullObFresh = useObForBuy and not na(lastBullObBar) and bar_index - lastBullObBar <= obMaxAge
bullObRetest = bullObFresh and not na(lastBullObLow) and low <= lastBullObHigh + atr * obRetestBufferAtr and close >= lastBullObLow - atr * obRetestBufferAtr
bullObReclaim = bullObRetest and close > lastBullObHigh and close > open

pricePivotLow = ta.pivotlow(low, obvPivotLen, obvPivotLen)
obvPivotLow = ta.pivotlow(obv, obvPivotLen, obvPivotLen)
if useObvDivergenceForBuy and not na(pricePivotLow) and not na(obvPivotLow)
    pivotPriceLow = pricePivotLow
    pivotObvLow = obvPivotLow
    if not na(prevPricePivotLow) and not na(prevObvPivotLow) and pivotPriceLow < prevPricePivotLow and pivotObvLow > prevObvPivotLow
        lastObvBullDivBar := bar_index - obvPivotLen
    prevPricePivotLow := pivotPriceLow
    prevObvPivotLow := pivotObvLow

pricePivotHigh = ta.pivothigh(high, obvPivotLen, obvPivotLen)
obvPivotHigh = ta.pivothigh(obv, obvPivotLen, obvPivotLen)
if useObvBearishDivergenceBlock and not na(pricePivotHigh) and not na(obvPivotHigh)
    pivotPriceHigh = pricePivotHigh
    pivotObvHigh = obvPivotHigh
    if not na(prevPricePivotHigh) and not na(prevObvPivotHigh) and pivotPriceHigh > prevPricePivotHigh and pivotObvHigh < prevObvPivotHigh
        lastObvBearDivBar := bar_index - obvPivotLen
    prevPricePivotHigh := pivotPriceHigh
    prevObvPivotHigh := pivotObvHigh

recentObvBullDiv = useObvDivergenceForBuy and not na(lastObvBullDivBar) and bar_index - lastObvBullDivBar <= obvDivergenceMaxAge
recentObvBearDiv = useObvBearishDivergenceBlock and not na(lastObvBearDivBar) and bar_index - lastObvBearDivBar <= obvDivergenceMaxAge
newObvBullDivSignal = recentObvBullDiv and not recentObvBullDiv[1]
newObvBearDivSignal = recentObvBearDiv and not recentObvBearDiv[1]
cycleHighExhausted = nearCycleHigh and (rsiOverboughtNow or diPlusExhausted or recentObvBearDiv)
momentumExhausted = rsiOverboughtNow or diPlusExhausted or cycleHighExhausted

belowEma20Buffered = close < ema20 - atr * ema20SellBufferAtr
ema20SellConfirmed = ta.highest(close - ema20, ema20SellConfirmBars) < -atr * ema20SellBufferAtr

breakoutBuyRaw = htfBullOk and stBull and close > coreUpper and (volRatio >= breakoutVolMult or aboveCoreStable)
coreReduceRaw = close < coreLower and close[1] < coreLower[1]
priceLostSupertrend = stBull and close < st
structureRisk = not sellRequiresStructureRisk or coreReduceRaw or priceLostSupertrend
diPlusFalling = ta.falling(diPlus, diWeakBars)
momentumWeakRaw = useEarlySell and stBull and structureRisk and (not earlySellRequireDiCross or diMinus > diPlus) and diPlusFalling and belowEma20Buffered
ema20LightReduceRaw = allowEma20LightSell and stBull and structureRisk and ema20SellConfirmed
weakRallyRaw = useEarlySell and stBull and structureRisk and close > close[1] and close < ema20 and volRatio <= weakVolMax and diPlusFalling
weakReduceRaw = stBull and (ema20LightReduceRaw or momentumWeakRaw or weakRallyRaw)

riskBarsAgo = ta.barssince(weakReduceRaw or coreReduceRaw or stBear)
sellBarsAgo = ta.barssince(weakReduceRaw or coreReduceRaw)
noRecentRisk = na(riskBarsAgo) or riskBarsAgo > recentRiskBlockBars
noPostSellChurn = na(sellBarsAgo) or sellBarsAgo > postSellBuyBlockBars

// Anti false-breakout: require price to hold above key levels for N bars
heldAboveEma20 = ta.lowest(close - ema20, breakoutHoldBars) > 0

trialBuyRaw = htfBullOk and stBull and heldAboveEma20 and close < coreUpper and volRatio >= trialMinVolRatio and (not requireAdxForTrial or adx >= adxMin) and (diPlus - diMinus) >= diMinSpread and ema20 > ema20[1] and noRecentRisk

// Momentum take-profit: lock in partial profit before structure breaks
swingHighSinceBuy = ta.highest(high, momentumTpSwingLookback)
dropFromSwing = (swingHighSinceBuy - close) / atr
profitSinceBuy = not na(lastBuyPrice) ? (close - lastBuyPrice) / atr : 0.0
momentumTpDropOk = dropFromSwing >= momentumTpDropAtr
momentumTpProfitOk = profitSinceBuy >= momentumTpMinProfitAtr
momentumTpDiWeak = diMinus > diPlus or diPlusFalling
momentumTpRaw = useMomentumTp and stBull and buyStage > 0 and momentumTpDropOk and momentumTpProfitOk and momentumTpDiWeak and close > coreUpper

if inLongCycle and buyStage > 0
    peakSinceEntry := na(peakSinceEntry) ? high : math.max(peakSinceEntry, high)

profitFromAvg = not na(avgBuyPrice) ? (close - avgBuyPrice) / atr : 0.0
peakProfitFromAvg = not na(avgBuyPrice) and not na(peakSinceEntry) ? (peakSinceEntry - avgBuyPrice) / atr : 0.0
hardStopLine = not na(avgBuyPrice) ? avgBuyPrice - atr * hardStopAtr : na
trailingStopLine = not na(peakSinceEntry) ? peakSinceEntry - atr * trailingStopAtr : na
hardStopRaw = useHardStop and inLongCycle and buyStage > 0 and not na(hardStopLine) and close <= hardStopLine
trailingStopRaw = useTrailingStop and inLongCycle and buyStage > 0 and peakProfitFromAvg >= trailingStartAtr and not na(trailingStopLine) and close <= trailingStopLine and (close < ema20 or diMinus > diPlus or recentObvBearDiv)
extensionTpRaw = useExtensionTp and inLongCycle and buyStage > 0 and profitFromAvg >= extensionTpMinProfitAtr and close - ema20 >= atr * extensionTpDistanceAtr and (rsiOverboughtNow or diPlusFalling or recentObvBearDiv)

trendExitRaw = stBear or (useHtfFilter and not htfBullOk)

touchedEma20 = ta.lowest(low - ema20, pullbackLookback) <= atr * pullbackAtrDistance
touchedCore = ta.lowest(low - coreUpper, pullbackLookback) <= atr * pullbackAtrDistance
lowVolPullback = volRatio <= pullbackVolMax
recentHigh = ta.highest(high, pullbackLookback)
breakoutRefHigh = ta.highest(high[1], breakoutAddLookback)
setupRange = ta.highest(high, setupAddLookback) - ta.lowest(low, setupAddLookback)
notDeepPullback = (recentHigh - close) <= atr * maxPullbackFromHighAtr
bearPressure = close < open and volRatio >= vpBearVolMult and (close < ema20 or open - close >= atr * 0.35)
bearPressureBarsAgo = ta.barssince(bearPressure)
recentBearPressure = not na(bearPressureBarsAgo) and bearPressureBarsAgo <= vpLookback
bullReclaimVolume = close > open and close > high[1] and volRatio >= vpBullVolMin
volumePriceAddOk = not useVolumePriceFilter or not recentBearPressure or bullReclaimVolume
stSupportive = stBull and st < close
stSafe = stBull and st < close and (close - st) >= atr * minSupertrendDistanceAtr
adxHealthy = adx >= adxMin and (not requireAdxRisingForAdd or adx >= adx[1])
diHealthy = not requireDiForAdd or diPlus > diMinus
addTrendHealthy = stSafe and adxHealthy and diHealthy
reclaimTrendHealthy = stSafe and adx >= adxMin and diHealthy
setupTrendHealthy = stSupportive and diHealthy
addPullbackOk = notDeepPullback and ema20 >= ema20[1]
obvAddRiskOk = not recentObvBearDiv
pullbackBuyRaw = htfBullOk and addTrendHealthy and volumePriceAddOk and close > ema20 and close > open and lowVolPullback and (touchedEma20 or touchedCore) and notDeepPullback and noRecentRisk
notTooExtended = (close - ema20) <= atr * lateAddMaxDistanceAtr
notTooExtendedForTrendAdd = (close - ema20) <= atr * trendAddMaxDistanceAtr
setupHeldAboveEma20 = ta.lowest(close - ema20, setupAddLookback) >= -atr * 0.10
setupSlopeOk = ema20 >= ema20[1] and coreUpper >= coreUpper[1]
reclaimNearEma20 = math.abs(close - ema20) <= atr * lateAddMaxDistanceAtr
reclaimBuyRaw = htfBullOk and reclaimTrendHealthy and volumePriceAddOk and close > ema20 and close > open and (close > high[1] or close > ema20 + atr * 0.2) and (touchedEma20 or touchedCore) and notDeepPullback and reclaimNearEma20 and noRecentRisk
setupAddRaw = htfBullOk and setupTrendHealthy and volumePriceAddOk and close > ema20 and close >= open and setupRange <= atr * setupAddRangeAtr and setupHeldAboveEma20 and setupSlopeOk and (touchedEma20 or touchedCore) and notTooExtended and volRatio <= breakoutVolMult and noRecentRisk
notTooExtendedForBreakout = (close - ema20) <= atr * breakoutAddMaxDistanceAtr
obReferenceBuyRaw = htfBullOk and stBull and heldAboveEma20 and close > ema20 and close > open and noRecentRisk and obvAddRiskOk and (bullObReclaim or recentObvBullDiv)

trendActive = stBull and htfBullOk
trendReset = not htfBullOk and not inLongCycle

if trendReset
    buyStage := 0
    sellStage := 0
    coreConfirmed := false
    lastBuyPrice := na
    avgBuyPrice := na
    buyWeightSum := 0.0
    peakSinceEntry := na
    inLongCycle := false

canNextBuyStage = na(lastBuyBar) or bar_index - lastBuyBar >= stageCooldown
canReclaimAddStage = na(lastBuyBar) or bar_index - lastBuyBar >= reclaimAddCooldown
freshTrendBuyRaw = buyStage == 0 and (not requireHtfForFreshTrend or htfBullOk) and stBull and heldAboveEma20 and close > open and (diPlus - diMinus) >= diMinSpread and (not requireAdxForFreshTrend or adx >= adxMin) and (close > high[1] or close > ema20 + atr * 0.2)
earlyCoreReclaimBuyRaw = buyStage == 0 and htfBullOk and stBull and heldAboveEma20 and close > open and close > coreLower and close >= coreUpper - atr * 0.35 and close > high[1] and volRatio >= trialMinVolRatio and (diPlus - diMinus) >= diMinSpread and adx >= adxMin
trialBuy = buyStage == 0 and trendActive and (trialBuyRaw or breakoutBuyRaw or freshTrendBuyRaw or earlyCoreReclaimBuyRaw or obReferenceBuyRaw)
coreConfirmedNow = breakoutBuyRaw or aboveCoreStable
coreConfirmed := coreConfirmed or coreConfirmedNow
coreReadyForAdd = coreConfirmed or close > coreUpper
secondAddRefHigh = ta.highest(high[1], secondAddBreakoutLookback)
secondAddStructureOk = close > coreUpper + atr * secondAddCoreBufferAtr and ema20 > ema20[1] and coreUpper >= coreUpper[1]
secondAddProgressOk = buyStage == 1 and not na(lastBuyPrice) and secondAddStructureOk and close > lastBuyPrice + atr * secondAddAtr and close > ema20 + atr * 0.2 and close > secondAddRefHigh and close > open and volRatio >= vpBullVolMin
addPriceProgressOk = not na(lastBuyPrice) and close > lastBuyPrice + atr * moveAddAtr
addVolumeProgressOk = (close > high[1] and close > open and volRatio >= vpBullVolMin) or (close > breakoutRefHigh and volRatio >= breakoutVolMult)
laterAddProgressOk = buyStage > 1 and addPriceProgressOk and addVolumeProgressOk
referenceAddProgressOk = buyStage >= 1 and not na(lastBuyPrice) and obReferenceBuyRaw and close > lastBuyPrice + atr * referenceAddAtr
addProgressOk = buyStage == 1 ? (secondAddProgressOk or referenceAddProgressOk) : (laterAddProgressOk or referenceAddProgressOk)
moveAddBuy = buyStage == 1 and buyStage < maxBuyStages and canNextBuyStage and coreConfirmed and addTrendHealthy and volumePriceAddOk and addPullbackOk and addProgressOk and close > ema20 and close > high[1] and notTooExtended and noRecentRisk and obvAddRiskOk and not momentumExhausted
trendAddBuy = buyStage >= 1 and buyStage < maxBuyStages and canNextBuyStage and coreConfirmed and addTrendHealthy and volumePriceAddOk and addPullbackOk and addProgressOk and close > ema20 and close >= close[1] and notTooExtendedForTrendAdd and noRecentRisk and obvAddRiskOk and not momentumExhausted
setupAddBuy = buyStage >= 1 and buyStage < maxBuyStages and canReclaimAddStage and coreConfirmed and addProgressOk and setupAddRaw and obvAddRiskOk and not momentumExhausted
breakoutAddBuy = buyStage >= 1 and buyStage < maxBuyStages and canNextBuyStage and coreConfirmed and addTrendHealthy and addPullbackOk and addProgressOk and close > coreUpper and close > breakoutRefHigh and volRatio >= breakoutVolMult and notTooExtendedForBreakout and noRecentRisk and obvAddRiskOk and not momentumExhausted
reclaimAddBuy = buyStage >= 1 and buyStage < maxBuyStages and canReclaimAddStage and coreReadyForAdd and addPullbackOk and addProgressOk and (reclaimBuyRaw or bullObReclaim) and obvAddRiskOk and not momentumExhausted
pullbackBuy = buyStage >= 1 and buyStage < maxBuyStages and canNextBuyStage and coreConfirmed and addPullbackOk and addProgressOk and (pullbackBuyRaw or bullObReclaim) and obvAddRiskOk and not momentumExhausted

weakReduce = sellStage < maxSellStages and weakReduceRaw and (sellStage == 0 or not coreReduceRaw)
coreReduce = sellStage < maxSellStages and coreReduceRaw
momentumReduce = sellStage < maxSellStages and momentumTpRaw
extensionReduce = sellStage < maxSellStages and extensionTpRaw
exitSignalRaw = inLongCycle and trendExitRaw
forceExitRaw = hardStopRaw or trailingStopRaw

rawBuy = trendActive and buyStage < maxBuyStages and noPostSellChurn and not forceExitRaw and (trialBuy or moveAddBuy or trendAddBuy or setupAddBuy or breakoutAddBuy or reclaimAddBuy or pullbackBuy)
canSellAfterBuy = na(lastBuyBar) or bar_index - lastBuyBar > sellGraceBars
rawExit = exitSignalRaw or forceExitRaw
rawSell = buyStage > 0 and canSellAfterBuy and sellStage < maxSellStages and not rawExit and (coreReduce or weakReduce or momentumReduce or extensionReduce)

buySignal = rawBuy and (na(lastBuyBar) or bar_index - lastBuyBar >= signalCooldown)
sellSignal = rawSell and (na(lastSellBar) or bar_index - lastSellBar >= signalCooldown)
exitSignal = rawExit and (forceExitRaw or na(lastBuyBar) or bar_index - lastBuyBar > exitGraceBars) and (na(lastSellBar) or bar_index - lastSellBar >= 1)

buyPct = trialBuy ? trialBuyPct : setupAddBuy and not moveAddBuy ? setupBuyPct : addBuyPct
sellPct = coreReduce and sellStage == 0 ? coreSellPct : extensionReduce ? extensionTpPct : momentumReduce ? momentumTpPct : lightSellPct
buyWeight = buyPct * 1.0

if buySignal
    avgBuyPrice := na(avgBuyPrice) or buyWeightSum <= 0 ? close : (avgBuyPrice * buyWeightSum + close * buyWeight) / (buyWeightSum + buyWeight)
    buyWeightSum += buyWeight
    peakSinceEntry := na(peakSinceEntry) ? high : math.max(peakSinceEntry, high)
    lastBuyBar := bar_index
    lastBuyPrice := close
    inLongCycle := true
    buyStage += 1
    if sellResetOnBuy and buyStage > 1
        sellStage := 0

if sellSignal
    lastSellBar := bar_index
    sellStage += 1
    buyStage := math.max(buyStage - 1, 0)

if exitSignal
    buyStage := 0
    sellStage := 0
    avgBuyPrice := na
    buyWeightSum := 0.0
    peakSinceEntry := na
    inLongCycle := false

// Signal reasons for alert text.
buyReason =
     moveAddBuy ? "move_add" :
     trendAddBuy ? "trend_add" :
     setupAddBuy ? "setup_add" :
     breakoutAddBuy ? "breakout_add" :
     reclaimAddBuy ? "reclaim_add" :
     obReferenceBuyRaw ? "ob_obv_reference" :
     pullbackBuy ? "add" :
     "trial"

sellReason =
     coreReduce ? "core_reduce" :
     extensionReduce ? "extension_tp" :
     momentumReduce ? "momentum_tp" :
     weakRallyRaw ? "weak_rally" :
     ema20LightReduceRaw ? "ema20_reduce" :
     "reduce"

exitReason = hardStopRaw ? "hard_stop" : trailingStopRaw ? "trailing_stop" : useHtfFilter and not htfBullOk ? "htf_exit" : "supertrend_exit"

buyText = "Buy " + str.tostring(buyPct) + "%"
sellText = "Sell " + str.tostring(sellPct) + "%"
exitText = hardStopRaw ? "Stop 100%" : trailingStopRaw ? "Trail 100%" : "Exit 100%"

// ---------------------------------------------------------------------
// Plots
// ---------------------------------------------------------------------
plot(st, "SuperTrend", color=stBull ? color.lime : color.red, linewidth=2)
plot(showEma ? ema20 : na, "EMA20", color=color.white)
plot(showEma ? ema144 : na, "EMA144", color=color.teal, linewidth=2)
plot(showEma ? ema169 : na, "EMA169", color=color.new(color.teal, 35), linewidth=2)
plot(showEma ? ema576 : na, "EMA576", color=color.orange, linewidth=2)
plot(showEma ? ema696 : na, "EMA696", color=color.new(color.orange, 40), linewidth=2)
plot(showRiskLines and buyStage > 0 ? avgBuyPrice : na, "Avg Entry", color=color.new(color.yellow, 20), style=plot.style_linebr)
plot(showRiskLines and useHardStop and buyStage > 0 ? hardStopLine : na, "ATR Hard Stop", color=color.new(color.red, 15), style=plot.style_linebr)
plot(showRiskLines and useTrailingStop and buyStage > 0 and peakProfitFromAvg >= trailingStartAtr ? trailingStopLine : na, "ATR Trailing Stop", color=color.new(color.fuchsia, 20), style=plot.style_linebr)
obZoneHighPlot = plot(showObZones and bullObFresh ? lastBullObHigh : na, "Bullish OB High", color=color.new(color.lime, 25), style=plot.style_linebr)
obZoneLowPlot = plot(showObZones and bullObFresh ? lastBullObLow : na, "Bullish OB Low", color=color.new(color.lime, 45), style=plot.style_linebr)
fill(obZoneHighPlot, obZoneLowPlot, color=color.new(color.lime, 90), title="Bullish OB Zone")
plotshape(newObvBullDivSignal, title="OBV Bullish Divergence", style=shape.triangleup, location=location.belowbar, color=color.aqua, text="OBV", textcolor=color.white, size=size.tiny)
plotshape(newObvBearDivSignal, title="OBV Bearish Divergence", style=shape.triangledown, location=location.abovebar, color=color.fuchsia, text="OBV", textcolor=color.white, size=size.tiny)

if buySignal
    label.new(bar_index, low - atr * labelOffsetAtr, buyText, style=label.style_label_up, color=color.lime, textcolor=color.white, size=size.normal, tooltip=buyReason)

if sellSignal
    label.new(bar_index, high + atr * labelOffsetAtr, sellText, style=label.style_label_down, color=color.red, textcolor=color.white, size=size.normal, tooltip=sellReason)

if exitSignal
    label.new(bar_index, high + atr * labelOffsetAtr, exitText, style=label.style_label_down, color=color.maroon, textcolor=color.white, size=size.normal, tooltip=exitReason)

bgcolor(showBg and breakoutBuyRaw ? color.new(color.lime, 88) : na)
bgcolor(showBg and pullbackBuyRaw ? color.new(color.aqua, 90) : na)
bgcolor(showBg and bullObRetest ? color.new(color.green, 90) : na)
bgcolor(showBg and recentObvBullDiv ? color.new(color.aqua, 94) : na)
bgcolor(showBg and extensionTpRaw ? color.new(color.orange, 90) : na)
bgcolor(showBg and rawSell ? color.new(color.red, 92) : na)
bgcolor(showBg and forceExitRaw ? color.new(color.maroon, 82) : na)
bgcolor(showBg and exitSignal ? color.new(color.maroon, 88) : na)

// Alerts. Use these to build webhook signals.
alertcondition(buySignal, title="Buy Signal", message="Buy signal: {{ticker}} {{interval}}")
alertcondition(sellSignal, title="Sell Reduce Signal", message="Sell reduce signal: {{ticker}} {{interval}}")
alertcondition(exitSignal, title="Exit Signal", message="Exit signal: {{ticker}} {{interval}}")
alertcondition(exitSignal and hardStopRaw, title="Hard Stop Signal", message="Hard stop signal: {{ticker}} {{interval}}")
alertcondition(exitSignal and trailingStopRaw, title="Trailing Stop Signal", message="Trailing stop signal: {{ticker}} {{interval}}")
````
