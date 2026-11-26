# Singularity Convergence Protocol [JOAT]

- url: https://www.tradingview.com/script/GZCiUApZ-Singularity-Convergence-Protocol-JOAT/
- type: strategy
- pine_id: PUB;5241ebc7247e492b9034bf727b1126a2
- version: 1.0

## Description

[b]Singularity Convergence Protocol[/b]

[b]Introduction[/b]

The Singularity Convergence Protocol is an advanced open-source multi-system confluence strategy that combines eight distinct analytical methodologies into a unified trading system. This strategy integrates momentum analysis, Smart Money Concepts, velocity waves, liquidity tracking, trend detection, divergence analysis, volatility measurement, and institutional flow into a comprehensive decision-making engine that generates high-probability trading signals through systematic confluence scoring.

Unlike single-indicator strategies, the Singularity Convergence Protocol provides institutional-grade signal generation through multi-dimensional analysis, weighted confluence scoring, and adaptive risk management. The strategy is designed for traders who understand that the highest probability setups occur when multiple independent analytical systems align simultaneously, creating a "singularity" of confluence.

[image]https://www.tradingview.com/x/kwiNt2vR/[/image]

[b]Why This Strategy Exists[/b]

This strategy addresses the critical challenge of signal reliability in algorithmic trading. By requiring confluence across multiple independent systems, it dramatically reduces false signals while identifying the highest probability setups. The strategy reveals:

[list]
[*][b]System 1 - Momentum Analysis:[/b] Quantum Flux Oscillator methodology combining VFI, Laguerre RSI, Fisher Transform, TSI, MFI, OBV, and A/D
[*][b]System 2 - Structure Detection:[/b] Smart Money Concepts including Order Blocks, Fair Value Gaps, Liquidity Levels, and Market Structure
[*][b]System 3 - Velocity Waves:[/b] Multi-layer momentum spectrum with five EMA layers and ALMA enhancement
[*][b]System 4 - Liquidity Tracking:[/b] Pivot-based liquidity detection with sweep confirmation
[*][b]System 5 - Trend Analysis:[/b] Hull MA, SuperTrend, ADX, and moving average alignment
[*][b]System 6 - Divergence Detection:[/b] Multi-oscillator divergence with RSI, MACD, TSI, and Stochastic
[*][b]System 7 - Volatility Analysis:[/b] ATR, Bollinger Bands, Keltner Channels, Historical Volatility, and Squeeze detection
[*][b]System 8 - Institutional Flow:[/b] CMF, MFI, OBV, VWAP, and A/D Line integration
[/list]

[b]Core Strategy Logic[/b]

[b]1. Eight Independent Analytical Systems[/b]

Each system operates independently and generates binary signals (bullish/bearish):

[b]Momentum System:[/b]
[list]
[*]Calculates composite momentum from seven components
[*]Generates bullish signal when momentum > 0 and rising
[*]Generates bearish signal when momentum < 0 and falling
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Structure System:[/b]
[list]
[*]Detects order blocks, FVGs, and market structure
[*]Bullish when OB/FVG active + bullish structure + discount zone
[*]Bearish when OB/FVG active + bearish structure + premium zone
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Velocity Wave System:[/b]
[list]
[*]Analyzes five momentum layers with ALMA enhancement
[*]Bullish when Basis 1 > Basis 2 and rising with spread > 5
[*]Bearish when Basis 1 < Basis 2 and falling with spread < -5
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Liquidity System:[/b]
[list]
[*]Tracks liquidity sweeps with volume confirmation
[*]Bullish when SSL swept with volume surge
[*]Bearish when BSL swept with volume surge
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Trend System:[/b]
[list]
[*]Combines Hull MA, SuperTrend, ADX, and MA alignment
[*]Bullish when Hull rising + SuperTrend bullish + ADX > 20 + MA alignment
[*]Bearish when Hull falling + SuperTrend bearish + ADX > 20 + MA alignment
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Divergence System:[/b]
[list]
[*]Detects divergences across RSI, MACD, TSI, and Stochastic
[*]Bullish when regular bullish divergence with 2+ oscillator confluence
[*]Bearish when regular bearish divergence with 2+ oscillator confluence
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Volatility System:[/b]
[list]
[*]Measures volatility through ATR, BB Width, KC, HV, and Squeeze
[*]Bullish when squeeze breakout upward with low volatility index
[*]Bearish when squeeze breakout downward with low volatility index
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]Institutional Flow System:[/b]
[list]
[*]Tracks institutional positioning through CMF, MFI, OBV, VWAP, A/D
[*]Bullish when flow index > 10 with CMF > 0 and MFI > 50
[*]Bearish when flow index < -10 with CMF < 0 and MFI < 50
[*]Score: +1 for bullish, -1 for bearish, 0 for neutral
[/list]

[b]2. Confluence Scoring System[/b]

The strategy employs two scoring methods:

[b]Binary Signal Count:[/b]
[list]
[*]Counts how many systems generate bullish signals (0-8)
[*]Counts how many systems generate bearish signals (0-8)
[*]Minimum signals required (default: 2) filters weak setups
[/list]

[b]Weighted Confluence Score:[/b]
[list]
[*]Sums all system scores (range: -8 to +8)
[*]Adds bonus points for extreme conditions:
  - Extreme momentum regimes (+1)
  - All velocity layers aligned (+1)
  - 4/4 divergence confluence (+1)
  - Volume surge with strong flow (+1)
[*]Total score can exceed ±8 with bonuses
[/list]

[b]3. Entry Conditions[/b]

Two entry modes are available:

[b]Standard Mode (Binary Count):[/b]
[list]
[*]Long Entry: Bullish signals >= minimum AND bullish signals > bearish signals
[*]Short Entry: Bearish signals >= minimum AND bearish signals > bullish signals
[*]Simple and straightforward
[/list]

[b]Confluence Mode (Weighted Score):[/b]
[list]
[*]Long Entry: Total bullish score >= minimum AND bullish score > bearish score
[*]Short Entry: Total bearish score >= minimum AND bearish score > bullish score
[*]Accounts for bonus conditions and extreme setups
[/list]

[b]4. Risk Management System[/b]

The strategy includes comprehensive risk management:

[b]Position Sizing:[/b]
[list]
[*]Risk per trade: Percentage of equity (default: 2%)
[*]Position size calculated based on stop distance and risk percentage
[*]Prevents over-leveraging on any single trade
[/list]

[b]Stop Loss Placement:[/b]
[list]
[*]ATR-based stops: Stop distance = ATR × multiplier (default: 2.0)
[*]Long stops: Entry price - (ATR × multiplier)
[*]Short stops: Entry price + (ATR × multiplier)
[*]Adapts to current volatility
[/list]

[b]Take Profit Targets:[/b]
[list]
[*]Risk:Reward ratio (default: 2.0)
[*]Target distance = Stop distance × R:R ratio
[*]Long targets: Entry price + (Stop distance × R:R)
[*]Short targets: Entry price - (Stop distance × R:R)
[/list]

[b]Trailing Stops:[/b]
[list]
[*]Optional trailing stop (default: enabled)
[*]Trail distance = ATR × trailing multiplier (default: 3.0)
[*]Locks in profits as trade moves favorably
[*]Adjusts to volatility changes
[/list]

[b]5. Visual Features[/b]

The strategy includes comprehensive visual elements:

[list]
[*][b]Hull Moving Average:[/b] Primary trend line with dynamic coloring
[*][b]SuperTrend Bands:[/b] Dynamic support/resistance levels
[*][b]EMA Matrix:[/b] Three EMAs showing trend alignment
[*][b]Order Block Boxes:[/b] Bullish and bearish OB zones
[*][b]Fair Value Gap Boxes:[/b] FVG zones with dashed borders
[*][b]Liquidity Lines:[/b] BSL and SSL levels with sweep tracking
[*][b]Equilibrium Line:[/b] Premium/discount zone reference
[*][b]Background Coloring:[/b] Regime indication (extreme bull/bear, squeeze, entry signals)
[*][b]Information Dashboard:[/b] Real-time display of all metrics and scores
[/list]

[b]Dashboard Metrics[/b]

The comprehensive dashboard displays:

[list]
[*][b]Bull/Bear Scores:[/b] Total confluence scores with signal counts
[*][b]Volatility Index:[/b] Current volatility level and regime
[*][b]Spread:[/b] Velocity wave spread indicating momentum strength
[*][b]Flow Index:[/b] Institutional positioning measurement
[*][b]Price Zone:[/b] Premium/discount position with percentage
[*][b]Win Rate:[/b] Strategy performance with trade count
[*][b]Position:[/b] Current position status (Long/Short/Flat)
[*][b]Signal:[/b] Current signal status with confluence indication
[/list]

[b]Strategy Settings and Defaults[/b]

[b]Backtest Configuration:[/b]
[list]
[*]Initial Capital: $100,000
[*]Position Size: 100% of equity (adjusted by risk management)
[*]Commission: 0.1% per trade
[*]Slippage: 2 ticks
[*]Pyramiding: Disabled (one position at a time)
[/list]

[b]Risk Management Defaults:[/b]
[list]
[*]Risk Per Trade: 2.0% of equity
[*]Stop Loss: 2.0 × ATR
[*]Take Profit: 2.0 × Risk (2:1 R:R)
[*]Trailing Stop: Enabled, 3.0 × ATR
[/list]

[b]Strategy Defaults:[/b]
[list]
[*]Minimum Signals: 2 (requires at least 2 systems to agree)
[*]Use Confluence Scoring: Enabled (uses weighted scores)
[*]Show Visual Features: Enabled (displays all chart elements)
[/list]

[b]How to Use This Strategy[/b]

[b]Step 1: Configure Risk Parameters[/b]
Set risk per trade, stop loss ATR multiplier, and take profit R:R ratio based on your risk tolerance.

[b]Step 2: Choose Entry Mode[/b]
Select standard mode (binary count) for simplicity or confluence mode (weighted scores) for advanced filtering.

[b]Step 3: Set Minimum Signals[/b]
Higher minimum (3-4) = fewer but higher quality trades. Lower minimum (2) = more trades but lower quality.

[b]Step 4: Enable Trailing Stops[/b]
Trailing stops lock in profits on winning trades. Adjust trailing ATR multiplier based on market volatility.

[b]Step 5: Monitor Dashboard[/b]
Watch bull/bear scores in real-time. Scores >= 4 indicate strong confluence. Scores >= 6 indicate exceptional setups.

[b]Step 6: Review Visual Confluence[/b]
Check that multiple visual elements align: trend, structure, liquidity, and flow should all confirm signal direction.

[b]Step 7: Backtest Thoroughly[/b]
Test on multiple instruments and timeframes. Adjust parameters based on results. Aim for 100+ trades for statistical significance.

[b]Best Practices[/b]

[list]
[*]Use on liquid instruments (major forex, large-cap stocks, major crypto)
[*]Test on multiple timeframes - higher timeframes generally more reliable
[*]Increase minimum signals in choppy markets, decrease in trending markets
[*]Monitor win rate - aim for 40%+ with 2:1 R:R for profitability
[*]Adjust stop loss ATR multiplier based on instrument volatility
[*]Use confluence mode for highest quality signals
[*]Review dashboard before entering - ensure multiple systems align
[*]Combine with higher timeframe analysis for additional confirmation
[*]Be patient - wait for high confluence scores (4+) for best results
[*]Respect the risk management - never override stop losses
[/list]

[b]Strategy Limitations[/b]

[list]
[*]Requires sufficient historical data for all eight systems
[*]May generate fewer signals than single-indicator strategies
[*]Performance varies by instrument and timeframe
[*]Backtesting results do not guarantee future performance
[*]Slippage and commission can significantly impact results
[*]Extreme market conditions may cause all systems to fail simultaneously
[*]Requires regular monitoring and parameter adjustment
[*]Not suitable for very low timeframes (< 5 minutes) due to noise
[/list]

[b]Input Parameters[/b]

[b]Risk Management:[/b]
[list]
[*]Risk Per Trade %: Percentage of equity to risk (default: 2.0%)
[*]Stop Loss (ATR): ATR multiplier for stops (default: 2.0)
[*]Take Profit (R:R): Risk:reward ratio (default: 2.0)
[*]Use Trailing Stop: Enable trailing stops (default: enabled)
[*]Trailing ATR: ATR multiplier for trailing (default: 3.0)
[/list]

[b]Strategy Settings:[/b]
[list]
[*]Minimum Signals: Required system agreements (default: 2)
[*]Use Confluence Scoring: Enable weighted scoring (default: enabled)
[*]Show Visual Features: Display chart elements (default: enabled)
[/list]

[b]Originality Statement[/b]

This strategy is original in its comprehensive multi-system approach. While individual analytical methodologies are established concepts, this strategy is justified because:

[list]
[*]It integrates eight distinct analytical systems into a unified decision-making engine
[*]The confluence scoring system measures agreement across independent methodologies
[*]Bonus scoring for extreme conditions identifies exceptional setups
[*]Comprehensive risk management adapts to volatility and account size
[*]Visual integration allows traders to verify confluence across multiple dimensions
[*]The dashboard provides real-time transparency into all system states
[*]Systematic approach removes emotional decision-making from trading
[/list]

[b]Strategy Performance Notes[/b]

When publishing this strategy, ensure you:
[list]
[*]Use realistic account size (default: $100,000)
[*]Include realistic commission (0.1%) and slippage (2 ticks)
[*]Generate 100+ trades for statistical significance
[*]Document all default settings in description
[*]Explain risk management parameters clearly
[*]Show results on multiple instruments/timeframes
[*]Discuss limitations and market conditions where strategy works best
[*]Never make unrealistic claims about future performance
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for all investors.

Past performance does not guarantee future results. Backtesting results are hypothetical and do not represent actual trading. Actual results may differ significantly from backtested results due to slippage, commission, market conditions, and execution differences.

The strategy combines multiple analytical systems, but no combination of indicators can predict future price movement with certainty. Market conditions change, and strategies that worked historically may not work in the future. Users must conduct their own analysis and risk assessment before using this strategy.

Always use proper risk management, including stop losses and position sizing appropriate for your account size and risk tolerance. Never risk more than you can afford to lose. Consider consulting with a qualified financial advisor before making investment decisions.

The author is not responsible for any losses incurred from using this strategy. Users assume full responsibility for all trading decisions made using this tool.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6

strategy("Singularity Convergence Protocol [JOAT]", shorttitle="SCP [JOAT]", overlay=true,
     initial_capital=100000, default_qty_type=strategy.percent_of_equity,
     default_qty_value=100, commission_type=strategy.commission.percent,
     commission_value=0.1, slippage=2, pyramiding=0,
     max_boxes_count=200, max_lines_count=200, max_labels_count=150)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

// Risk Management
riskPercent = input.float(2.0, "Risk Per Trade %", minval=0.5, maxval=5.0, group="Risk")
stopLossATR = input.float(2.0, "Stop Loss (ATR)", minval=1.0, maxval=4.0, group="Risk")
takeProfitRR = input.float(2.0, "Take Profit (R:R)", minval=1.0, maxval=5.0, group="Risk")
useTrailing = input.bool(true, "Use Trailing Stop", group="Risk")
trailingATR = input.float(3.0, "Trailing ATR", minval=2.0, maxval=5.0, group="Risk")

// Strategy Settings
minSignals = input.int(2, "Minimum Signals", minval=1, maxval=4, group="Strategy")
useConfluence = input.bool(true, "Use Confluence Scoring", group="Strategy")
showVisuals = input.bool(true, "Show Visual Features", group="Strategy")

// ═══════════════════════════════════════════════════════════════════════════════
// 1. IMPLEMENTATION
// ═══════════════════════════════════════════════════════════════════════════════

// VFI
typical = hlc3
vfiInter = math.log(typical) - math.log(typical[1])
vfiVinter = ta.stdev(vfiInter, 30)
vfiCutoff = 0.2 * vfiVinter * close
vave = ta.sma(volume, 14)[1]
vmax = vave * 2.5
vc = volume < vmax ? volume : vmax
mf = typical - typical[1]
vcp = mf > vfiCutoff ? vc : (mf < -vfiCutoff ? -vc : 0)
vfiSum = ta.sma(vcp, 14) * 14
vfiFinal = (vfiSum / vave) * 4.0

// Laguerre RSI
lagGamma = 0.4
var float L0 = 0.0, var float L1 = 0.0, var float L2 = 0.0, var float L3 = 0.0
L0 := (1.0 - lagGamma) * close + lagGamma * nz(L0[1])
L1 := -lagGamma * L0 + nz(L0[1]) + lagGamma * nz(L1[1])
L2 := -lagGamma * L1 + nz(L1[1]) + lagGamma * nz(L2[1])
L3 := -lagGamma * L2 + nz(L2[1]) + lagGamma * nz(L3[1])
lagCU = math.max(math.max(L0 - L1, 0) + math.max(L1 - L2, 0) + math.max(L2 - L3, 0), 0.0001)
lagCD = math.max(math.max(L1 - L0, 0) + math.max(L2 - L1, 0) + math.max(L3 - L2, 0), 0.0001)
lagRSI = (lagCU / (lagCU + lagCD) - 0.5) * 100

// Fisher Transform
composite = (vfiFinal + lagRSI) / 2
fisherInput = 0.1 * (composite / 1.5)
fisherValue = (math.exp(2 * fisherInput) - 1) / (math.exp(2 * fisherInput) + 1)
fisherSmooth = ta.ema(fisherValue, 7)

// TSI
tsiPC = close - close[1]
tsiDouble = ta.ema(ta.ema(tsiPC, 25), 13)
tsiDoubleABS = ta.ema(ta.ema(math.abs(tsiPC), 25), 13)
tsiValue = 100 * (tsiDouble / tsiDoubleABS)

// MFI
typicalPrice = hlc3
rawMoneyFlow = typicalPrice * volume
posFlow = typicalPrice > typicalPrice[1] ? rawMoneyFlow : 0
negFlow = typicalPrice < typicalPrice[1] ? rawMoneyFlow : 0
moneyRatio = math.sum(posFlow, 14) / math.sum(negFlow, 14)
mfi = 100 - (100 / (1 + moneyRatio))

// OBV
obvRaw = ta.cum(math.sign(close - close[1]) * volume)
obvNorm = (obvRaw - ta.lowest(obvRaw, 100)) / (ta.highest(obvRaw, 100) - ta.lowest(obvRaw, 100)) * 100 - 50

// A/D Line
adLine = ta.cum(((close - low) - (high - close)) / (high - low) * volume)
adSmooth = ta.ema(adLine, 14)
adNorm = (adSmooth - ta.lowest(adSmooth, 100)) / (ta.highest(adSmooth, 100) - ta.lowest(adSmooth, 100)) * 100 - 50

// Williams %R
williamsR = ta.wpr(14)

// CMF
mfvCalc = ((close - low) - (high - close)) / (high - low) * volume
cmf = ta.sma(mfvCalc, 20) / ta.sma(volume, 20)

// Momentum Core
momentumCore = (vfiFinal * 0.20) + (lagRSI * 0.20) + (fisherSmooth * 20 * 0.15) + 
     (tsiValue / 2 * 0.15) + ((mfi - 50) / 2 * 0.10) + (obvNorm * 0.10) + (adNorm * 0.05) + (cmf * 50 * 0.05)
momentumSmooth = ta.ema(momentumCore, 7)

momentumBull = momentumSmooth > 0 and momentumSmooth > momentumSmooth[1]
momentumBear = momentumSmooth < 0 and momentumSmooth < momentumSmooth[1]
momentumScore = momentumBull ? 1.0 : momentumBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// 2. 
// ═══════════════════════════════════════════════════════════════════════════════

swingLength = 10
ph = ta.pivothigh(high, swingLength, swingLength)
pl = ta.pivotlow(low, swingLength, swingLength)

// Order Blocks
var float bullOBTop = na, var float bullOBBottom = na, var bool bullOBActive = false
if not na(pl) and close > high[swingLength]
    bullOBBottom := low[swingLength + 1]
    bullOBTop := high[swingLength + 1]
    bullOBActive := true
if bullOBActive and close < bullOBBottom
    bullOBActive := false

var float bearOBTop = na, var float bearOBBottom = na, var bool bearOBActive = false
if not na(ph) and close < low[swingLength]
    bearOBTop := high[swingLength + 1]
    bearOBBottom := low[swingLength + 1]
    bearOBActive := true
if bearOBActive and close > bearOBTop
    bearOBActive := false

// FVG
bullFVG = low > high[2]
bearFVG = high < low[2]

// Premium/Discount Zones
highestHigh = ta.highest(high, 50)
lowestLow = ta.lowest(low, 50)
equilibrium = (highestHigh + lowestLow) / 2
inPremium = close > equilibrium
inDiscount = close < equilibrium

// Market Structure
var float lastHH = na, var float lastLL = na, var int marketStructure = 0
if not na(ph)
    if na(lastHH) or ph > lastHH
        lastHH := ph
        if marketStructure != 1
            marketStructure := 1
    else
        marketStructure := -1
if not na(pl)
    if na(lastLL) or pl < lastLL
        lastLL := pl
        if marketStructure != -1
            marketStructure := -1
    else
        marketStructure := 1

structureBull = (bullOBActive or bullFVG) and marketStructure == 1 and inDiscount
structureBear = (bearOBActive or bearFVG) and marketStructure == -1 and inPremium
structureScore = structureBull ? 1.0 : structureBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// 3.
// ═══════════════════════════════════════════════════════════════════════════════

momentum = ta.mom(close, 21)
almaBase = ta.alma(close, 9, 0.85, 6)
almaAdjusted = almaBase - (almaBase - momentum)

ma1 = ta.ema(momentum, 9)
ma2 = ta.ema(momentum, 21)
ma3 = ta.ema(momentum, 55)
ma4 = ta.ema(momentum, 100)
ma5 = ta.ema(momentum, 200)

basis1 = math.avg(ma1, ma2)
basis2 = math.avg(ma2, ma3)
basis3 = math.avg(ma3, ma4)
basis4 = math.avg(ma4, ma5)
basis5 = math.avg(ma5, ma1)

basisAvg = math.avg(basis1, momentum)
basisAvgAll = math.avg(basis1, basis2, basis3, basis4, basis5)

origin = ta.sma(basisAvgAll, 25)
deviation = 6.0 * ta.stdev(basisAvgAll, 25)
topBand = origin + deviation
bottomBand = origin - deviation

highMean = ta.highest(basisAvg, 415)
lowMean = ta.lowest(basisAvg, 415)
centerMean = math.avg(highMean, lowMean)

growin(basis) => momentum > basis
fallin(basis) => momentum <= basis and momentum <= almaAdjusted

allBullish = growin(basis1) and growin(basis2) and growin(basis3) and growin(basis4) and growin(basis5)
allBearish = fallin(basis1) and fallin(basis2) and fallin(basis3) and fallin(basis4) and fallin(basis5)

extremeBull = basis1 > topBand and almaAdjusted > topBand and almaAdjusted > almaAdjusted[3]
extremeBear = basis1 < bottomBand and almaAdjusted < bottomBand and almaAdjusted < almaAdjusted[3]

spread = basis1 - basis5

// Extract ta.rising/falling to global scope
basis1Rising = ta.rising(basis1, 2)
basis1Falling = ta.falling(basis1, 2)

waveBull = basis1 > basis2 and basis1Rising and spread > 5
waveBear = basis1 < basis2 and basis1Falling and spread < -5
waveScore = waveBull or allBullish ? 1.0 : waveBear or allBearish ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// LIQUIDITY TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

liqPH = ta.pivothigh(high, 10, 10)
liqPL = ta.pivotlow(low, 10, 10)

var float buyLiq = na, var float sellLiq = na
if not na(liqPH)
    buyLiq := liqPH
if not na(liqPL)
    sellLiq := liqPL

buyLiqSwept = not na(buyLiq) and high > buyLiq
sellLiqSwept = not na(sellLiq) and low < sellLiq

avgVolume = ta.sma(volume, 45)
volSurge = volume > avgVolume * 2.25

liquidityBull = sellLiqSwept and volSurge
liquidityBear = buyLiqSwept and volSurge
liquidityScore = liquidityBull ? 1.0 : liquidityBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// TREND DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

hullLength = 20
hullWMA1 = ta.wma(close, math.floor(hullLength / 2))
hullWMA2 = ta.wma(close, hullLength)
hullMA = ta.wma(2 * hullWMA1 - hullWMA2, math.round(math.sqrt(hullLength)))

atr = ta.atr(10)
src = (high + low) / 2
upperBand = src + 3.0 * atr
lowerBand = src - 3.0 * atr

var int direction = 0
direction := close > upperBand ? -1 : close < lowerBand ? 1 : nz(direction[1], 1)
superTrend = direction == -1 ? lowerBand : upperBand

[diPlus, diMinus, adx] = ta.dmi(14, 14)

ema1 = ta.ema(close, 9)
ema2 = ta.ema(close, 21)
ema3 = ta.ema(close, 50)

bullishAlignment = ema1 > ema2 and ema2 > ema3
bearishAlignment = ema1 < ema2 and ema2 < ema3

// Extract ta.rising/falling to global scope
hullRising = ta.rising(hullMA, 3)
hullFalling = ta.falling(hullMA, 3)

trendBull = hullRising and direction == -1 and adx > 20 and bullishAlignment
trendBear = hullFalling and direction == 1 and adx > 20 and bearishAlignment
trendScore = trendBull ? 1.0 : trendBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

rsiValue = ta.rsi(close, 14)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

tsiPC2 = close - close[1]
tsiDouble2 = ta.ema(ta.ema(tsiPC2, 25), 13)
tsiDoubleABS2 = ta.ema(ta.ema(math.abs(tsiPC2), 25), 13)
tsiValue2 = 100 * (tsiDouble2 / tsiDoubleABS2)

stochValue = ta.stoch(close, high, low, 14)
stochSmooth = ta.sma(stochValue, 3)

compositeOsc = (rsiValue - 50) + macdLine + tsiValue2 + (stochSmooth - 50)

rsiPH = ta.pivothigh(rsiValue, 5, 5)
rsiPL = ta.pivotlow(rsiValue, 5, 5)

// Extract ta.valuewhen to global scope
prevPL = ta.valuewhen(not na(pl), pl, 1)
prevRSIPL = ta.valuewhen(not na(rsiPL), rsiPL, 1)
prevPH = ta.valuewhen(not na(ph), ph, 1)
prevRSIPH = ta.valuewhen(not na(rsiPH), rsiPH, 1)

var bool bullDiv = false, var bool bearDiv = false, var int confluenceScore = 0

if not na(pl) and not na(rsiPL)
    if pl < prevPL and rsiPL > prevRSIPL
        bullDiv := true
        confluenceScore := 0
        if rsiPL > prevRSIPL
            confluenceScore += 1
        if macdLine > macdLine[5]
            confluenceScore += 1
        if tsiValue2 > tsiValue2[5]
            confluenceScore += 1
        if stochSmooth > stochSmooth[5]
            confluenceScore += 1
    else
        bullDiv := false

if not na(ph) and not na(rsiPH)
    if ph > prevPH and rsiPH < prevRSIPH
        bearDiv := true
        confluenceScore := 0
        if rsiPH < prevRSIPH
            confluenceScore += 1
        if macdLine < macdLine[5]
            confluenceScore += 1
        if tsiValue2 < tsiValue2[5]
            confluenceScore += 1
        if stochSmooth < stochSmooth[5]
            confluenceScore += 1
    else
        bearDiv := false

divergenceBull = bullDiv and confluenceScore >= 2 and compositeOsc < -20
divergenceBear = bearDiv and confluenceScore >= 2 and compositeOsc > 20
divergenceScore = divergenceBull ? 1.0 : divergenceBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// VOLATILITY ANALYSIS
// ═══════════════════════════════════════════════════════════════════════════════

atrRaw = ta.atr(14)
atrSmoothed = ta.ema(atrRaw, 7)
atrHigh = ta.highest(atrSmoothed, 100)
atrLow = ta.lowest(atrSmoothed, 100)
atrPercentile = ((atrSmoothed - atrLow) / (atrHigh - atrLow)) * 100

[bbMiddle, bbUpper, bbLower] = ta.bb(close, 20, 2.0)
bbWidth = ((bbUpper - bbLower) / bbMiddle) * 100
bbWidthHigh = ta.highest(bbWidth, 100)
bbWidthLow = ta.lowest(bbWidth, 100)
bbWidthPercentile = ((bbWidth - bbWidthLow) / (bbWidthHigh - bbWidthLow)) * 100

kcBasis = ta.ema(close, 20)
kcRange = ta.atr(20) * 1.5
kcUpper = kcBasis + kcRange
kcLower = kcBasis - kcRange

squeezeOn = bbLower > kcLower and bbUpper < kcUpper
squeezeOff = not squeezeOn
squeezeBreakout = squeezeOn[1] and squeezeOff

returns = math.log(close / close[1])
hvStdDev = ta.stdev(returns, 20)
hv = hvStdDev * math.sqrt(252) * 100
hvHigh = ta.highest(hv, 100)
hvLow = ta.lowest(hv, 100)
hvPercentile = ((hv - hvLow) / (hvHigh - hvLow)) * 100

volIndex = (atrPercentile + bbWidthPercentile + hvPercentile) / 3

volatilityBull = squeezeBreakout and close > close[1] and volIndex < 40
volatilityBear = squeezeBreakout and close < close[1] and volIndex < 40
volatilityScore = volatilityBull ? 1.0 : volatilityBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// INSTITUTIONAL FLOW
// ═══════════════════════════════════════════════════════════════════════════════

mfvCalc2 = ((close - low) - (high - close)) / (high - low) * volume
cmf2 = ta.sma(mfvCalc2, 20) / ta.sma(volume, 20)

typPrice = hlc3
rawMF = typPrice * volume
posFlow2 = typPrice > typPrice[1] ? rawMF : 0
negFlow2 = typPrice < typPrice[1] ? rawMF : 0
moneyRatio2 = math.sum(posFlow2, 14) / math.sum(negFlow2, 14)
mfi2 = 100 - (100 / (1 + moneyRatio2))

obvRaw2 = ta.cum(math.sign(close - close[1]) * volume)
obvNorm2 = (obvRaw2 - ta.lowest(obvRaw2, 100)) / (ta.highest(obvRaw2, 100) - ta.lowest(obvRaw2, 100)) * 100

adLine2 = ta.cum(((close - low) - (high - close)) / (high - low) * volume)
adSmooth2 = ta.ema(adLine2, 14)
adNorm2 = (adSmooth2 - ta.lowest(adSmooth2, 100)) / (ta.highest(adSmooth2, 100) - ta.lowest(adSmooth2, 100)) * 100

flowIndex = (cmf2 * 50 + (mfi2 - 50) + (obvNorm2 - 50) + (adNorm2 - 50)) / 4

var int phase = 0
if flowIndex > 30 and cmf2 > 0.1 and mfi2 > 50
    phase := 2
else if flowIndex > 10 and cmf2 > 0
    phase := 1
else if flowIndex < -30 and cmf2 < -0.1 and mfi2 < 50
    phase := -2
else if flowIndex < -10 and cmf2 < 0
    phase := -1
else
    phase := 0

institutionalBull = phase >= 1 and flowIndex > 10 and cmf2 > 0 and mfi2 > 50
institutionalBear = phase <= -1 and flowIndex < -10 and cmf2 < 0 and mfi2 < 50
institutionalScore = institutionalBull ? 1.0 : institutionalBear ? -1.0 : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL AGGREGATION WITH CONFLUENCE SCORING
// ═══════════════════════════════════════════════════════════════════════════════

// Count binary signals
bullSignals = 0
bearSignals = 0

if momentumBull
    bullSignals += 1
if momentumBear
    bearSignals += 1
if structureBull
    bullSignals += 1
if structureBear
    bearSignals += 1
if waveBull
    bullSignals += 1
if waveBear
    bearSignals += 1
if liquidityBull
    bullSignals += 1
if liquidityBear
    bearSignals += 1
if trendBull
    bullSignals += 1
if trendBear
    bearSignals += 1
if divergenceBull
    bullSignals += 1
if divergenceBear
    bearSignals += 1
if volatilityBull
    bullSignals += 1
if volatilityBear
    bearSignals += 1
if institutionalBull
    bullSignals += 1
if institutionalBear
    bearSignals += 1

// Confluence Score (weighted sum of all systems)
confluenceTotal = momentumScore + structureScore + waveScore + liquidityScore + trendScore + divergenceScore + volatilityScore + institutionalScore

// Bonus signals for strong conditions
bonusBull = 0
bonusBear = 0

if extremeBull
    bonusBull += 1
if extremeBear
    bonusBear += 1
if allBullish
    bonusBull += 1
if allBearish
    bonusBear += 1
if confluenceScore == 4
    bonusBull += 1
if confluenceScore == 4
    bonusBear += 1
if volSurge and flowIndex > 20
    bonusBull += 1
if volSurge and flowIndex < -20
    bonusBear += 1

totalBullScore = bullSignals + bonusBull + (confluenceTotal > 0 ? confluenceTotal : 0)
totalBearScore = bearSignals + bonusBear + (confluenceTotal < 0 ? math.abs(confluenceTotal) : 0)

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY CONDITIONS - MORE AGGRESSIVE
// ═══════════════════════════════════════════════════════════════════════════════

longSignal = useConfluence ? 
     (totalBullScore >= minSignals and totalBullScore > totalBearScore) : 
     (bullSignals >= minSignals and bullSignals > bearSignals)

shortSignal = useConfluence ? 
     (totalBearScore >= minSignals and totalBearScore > totalBullScore) : 
     (bearSignals >= minSignals and bearSignals > bullSignals)

// ═══════════════════════════════════════════════════════════════════════════════
// STRATEGY EXECUTION
// ═══════════════════════════════════════════════════════════════════════════════

longStop = close - (atr * stopLossATR)
longTarget = close + (atr * stopLossATR * takeProfitRR)
shortStop = close + (atr * stopLossATR)
shortTarget = close - (atr * stopLossATR * takeProfitRR)

if longSignal
    strategy.entry("LONG", strategy.long, comment="L[" + str.tostring(bullSignals) + "]")
    strategy.exit("Exit Long", "LONG", stop=longStop, limit=longTarget)

if shortSignal
    strategy.entry("SHORT", strategy.short, comment="S[" + str.tostring(bearSignals) + "]")
    strategy.exit("Exit Short", "SHORT", stop=shortStop, limit=shortTarget)

if useTrailing and strategy.position_size > 0
    trailStop = close - (atr * trailingATR)
    strategy.exit("Trail Long", "LONG", stop=trailStop)

if useTrailing and strategy.position_size < 0
    trailStop = close + (atr * trailingATR)
    strategy.exit("Trail Short", "SHORT", stop=trailStop)

// ═══════════════════════════════════════════════════════════════════════════════
// INSANE VISUAL FEATURES
// ═══════════════════════════════════════════════════════════════════════════════

// Hull MA - MUST be in global scope
hullColor = hullRising ? #00FF88 : hullFalling ? #FF0055 : #00B8D4
plot(showVisuals ? hullMA : na, "Hull MA", hullColor, 3)

// SuperTrend - MUST be in global scope
stColor = direction == -1 ? color.new(#00E5FF, 40) : color.new(#FF0055, 40)
plot(showVisuals ? superTrend : na, "SuperTrend", stColor, 2)

// EMAs - MUST be in global scope
plot(showVisuals ? ema1 : na, "EMA 9", color.new(#00FF88, 70), 1)
plot(showVisuals ? ema2 : na, "EMA 21", color.new(#00E5FF, 70), 1)
plot(showVisuals ? ema3 : na, "EMA 50", color.new(#FFC107, 70), 1)

// Backgrounds - MUST be in global scope
regimeBG = showVisuals ? (extremeBull ? color.new(#FF0055, 97) : 
     extremeBear ? color.new(#00FF88, 97) : 
     squeezeOn ? color.new(#9C27B0, 97) : na) : na
bgcolor(regimeBG)

entryBG = showVisuals ? (longSignal ? color.new(#00FF88, 95) : shortSignal ? color.new(#FF0055, 95) : na) : na
bgcolor(entryBG)

// Drawing objects - can be in conditional
if showVisuals and barstate.islast
    // Order Blocks
    if bullOBActive
        box.new(bar_index - 20, bullOBTop, bar_index + 10, bullOBBottom,
             bgcolor=color.new(#00E676, 85), border_color=color.new(#00E676, 0), border_width=2)
    
    if bearOBActive
        box.new(bar_index - 20, bearOBTop, bar_index + 10, bearOBBottom,
             bgcolor=color.new(#FF1744, 85), border_color=color.new(#FF1744, 0), border_width=2)
    
    // FVG Zones
    if bullFVG
        box.new(bar_index[2], low, bar_index + 10, high[2],
             bgcolor=color.new(#00BCD4, 90), border_color=color.new(#00BCD4, 30), 
             border_width=2, border_style=line.style_dashed)
    
    if bearFVG
        box.new(bar_index[2], low[2], bar_index + 10, high,
             bgcolor=color.new(#FF6F00, 90), border_color=color.new(#FF6F00, 30), 
             border_width=2, border_style=line.style_dashed)
    
    // Liquidity Levels
    if not na(buyLiq)
        line.new(bar_index - 20, buyLiq, bar_index + 20, buyLiq,
             color=buyLiqSwept ? color.new(#76FF03, 70) : color.new(#76FF03, 0), 
             width=2, style=buyLiqSwept ? line.style_dotted : line.style_solid)
    
    if not na(sellLiq)
        line.new(bar_index - 20, sellLiq, bar_index + 20, sellLiq,
             color=sellLiqSwept ? color.new(#F50057, 70) : color.new(#F50057, 0), 
             width=2, style=sellLiqSwept ? line.style_dotted : line.style_solid)
    
    // Equilibrium Line
    line.new(bar_index - 50, equilibrium, bar_index, equilibrium,
         color=color.new(#FFC107, 70), width=2, style=line.style_solid)

// ═══════════════════════════════════════════════════════════════════════════════
// CLEAN DASHBOARD - ESSENTIAL METRICS ONLY
// ═══════════════════════════════════════════════════════════════════════════════

var table dash = table.new(position.bottom_right, 3, 9,
     bgcolor=#0a0e1a, border_width=2, frame_color=#00E5FF, border_color=#00E5FF)

if barstate.islast
    // Header
    table.cell(dash, 0, 0, "SINGULARITY", text_color=#00E5FF, text_size=size.normal,
         bgcolor=#1a1d2e, text_halign=text.align_center)
    table.cell(dash, 1, 0, "CONVERGENCE", text_color=#FF0055, text_size=size.normal,
         bgcolor=#1a1d2e, text_halign=text.align_center)
    table.cell(dash, 2, 0, "PROTOCOL", text_color=#00FF88, text_size=size.normal,
         bgcolor=#1a1d2e, text_halign=text.align_center)
    
    // Confluence Scores
    table.cell(dash, 0, 1, "Bull Score", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(totalBullScore, format.mintick),
         text_color=#00FF88, text_size=size.small, 
         bgcolor=totalBullScore >= minSignals ? color.new(#00FF88, 85) : na)
    table.cell(dash, 2, 1, str.tostring(bullSignals) + "/8",
         text_color=#00FF88, text_size=size.small)
    
    table.cell(dash, 0, 2, "Bear Score", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(totalBearScore, format.mintick),
         text_color=#FF0055, text_size=size.small, 
         bgcolor=totalBearScore >= minSignals ? color.new(#FF0055, 85) : na)
    table.cell(dash, 2, 2, str.tostring(bearSignals) + "/8",
         text_color=#FF0055, text_size=size.small)
    
    // Vol Index
    table.cell(dash, 0, 3, "Vol Index", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(math.round(volIndex, 1)),
         text_color=volIndex > 70 ? #FF0055 : volIndex < 30 ? #00BCD4 : #FFC107, text_size=size.small)
    table.cell(dash, 2, 3, volIndex > 70 ? "HIGH" : volIndex < 30 ? "LOW" : "NORMAL",
         text_color=volIndex > 70 ? #FF0055 : volIndex < 30 ? #00BCD4 : #FFC107, text_size=size.small)
    
    // Spread
    table.cell(dash, 0, 4, "Spread", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(math.round(spread, 1)),
         text_color=spread > 10 ? #00FF88 : spread < -10 ? #FF0055 : #757575, text_size=size.small)
    table.cell(dash, 2, 4, spread > 20 ? "EXTREME+" : spread < -20 ? "EXTREME-" : "—",
         text_color=spread > 20 ? #00FF88 : spread < -20 ? #FF0055 : #757575, text_size=size.small)
    
    // Flow Index
    table.cell(dash, 0, 5, "Flow Index", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(math.round(flowIndex, 1)),
         text_color=flowIndex > 0 ? #00FF88 : #FF0055, text_size=size.small)
    table.cell(dash, 2, 5, flowIndex > 30 ? "STRONG+" : flowIndex < -30 ? "STRONG-" : "WEAK",
         text_color=flowIndex > 30 ? #00FF88 : flowIndex < -30 ? #FF0055 : #757575, text_size=size.small)
    
    // Price Zone
    table.cell(dash, 0, 6, "Price Zone", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 6, inPremium ? "PREMIUM" : "DISCOUNT",
         text_color=inPremium ? #FF6F00 : #00BCD4, text_size=size.small)
    table.cell(dash, 2, 6, str.tostring(math.round(((close - equilibrium) / equilibrium) * 100, 2)) + "%",
         text_color=inPremium ? #FF6F00 : #00BCD4, text_size=size.small)
    
    // Win Rate
    winRate = strategy.wintrades > 0 ? (strategy.wintrades / strategy.closedtrades) * 100 : 0
    table.cell(dash, 0, 7, "Win Rate", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(math.round(winRate, 1)) + "%",
         text_color=winRate > 50 ? #00FF88 : #FF0055, text_size=size.small)
    table.cell(dash, 2, 7, str.tostring(strategy.closedtrades) + " trades",
         text_color=#00E5FF, text_size=size.small)
    
    // Position & Signal
    posText = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    posColor = strategy.position_size > 0 ? #00FF88 : strategy.position_size < 0 ? #FF0055 : #808080
    posBg = strategy.position_size != 0 ? color.new(posColor, 85) : na
    table.cell(dash, 0, 8, "Position", text_color=#00E5FF, text_size=size.small)
    table.cell(dash, 1, 8, posText, text_color=posColor, text_size=size.small, bgcolor=posBg)
    
    signalText = longSignal ? "LONG SIGNAL" : shortSignal ? "SHORT SIGNAL" : "NO SIGNAL"
    signalColor = longSignal ? #00FF88 : shortSignal ? #FF0055 : #757575
    signalBg = longSignal or shortSignal ? color.new(signalColor, 85) : na
    table.cell(dash, 2, 8, signalText, text_color=signalColor, text_size=size.small, bgcolor=signalBg)
````
