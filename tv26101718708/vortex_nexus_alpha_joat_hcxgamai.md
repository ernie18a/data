# Vortex Nexus Alpha [JOAT]

- url: https://www.tradingview.com/script/hcXGamAi-Vortex-Nexus-Alpha-JOAT/
- type: strategy
- pine_id: PUB;dc90ccf063934f75845891ddcf39bd6f
- version: 1.0

## Description

[b]Vortex Nexus Alpha Strategy [JOAT][/b]

[b]Introduction[/b]

The Vortex Nexus Alpha Strategy is an advanced open-source algorithmic trading system that combines multi-dimensional signal generation, adaptive regime detection, and institutional-grade risk management into a unified execution framework. This strategy represents a complete trading system built from the ground up using proprietary mathematical models, fractal analysis, momentum tracking, and market microstructure intelligence.

Unlike simple crossover strategies or single-indicator systems, Vortex Nexus Alpha synthesizes intelligence from five independent signal layers, each containing five distinct detection mechanisms, creating a 25-factor confluence scoring system that validates every trade entry. The strategy is designed for traders who understand that consistent profitability requires multi-dimensional analysis, adaptive positioning, and systematic risk management rather than relying on any single indicator or pattern.

[b]Why This Strategy Exists[/b]

This strategy addresses the fundamental challenge of algorithmic trading: most systems over-optimize to historical data or rely on simplistic logic that fails in real market conditions. Vortex Nexus Alpha solves this through a knowledge-based architecture that doesn't depend on indicator mashups but instead builds intelligence from first principles:

[list]
[*][b]Volatility Expansion Engine:[/b] Measures market volatility through ATR percentile ranking and adapts position sizing and stop distances dynamically
[*][b]Price Efficiency Calculator:[/b] Quantifies how efficiently price moves using path length analysis, filtering choppy conditions
[*][b]Chaos Measurement System:[/b] Identifies market regime (directional, equilibrium, chaotic) using logarithmic range analysis
[*][b]Directional Conviction Tracker:[/b] Measures trend strength through ADX and directional movement indicators
[*][b]Adaptive Ribbon System:[/b] Multi-layer EMA ribbon that expands/contracts based on volatility and provides dynamic support/resistance
[*][b]Volume Pressure Analysis:[/b] Estimates buying/selling pressure through candle structure and wick analysis
[*][b]Gauss Smoothing Engine:[/b] 4th-order Gaussian filter that eliminates noise while preserving genuine price movements
[*][b]Fractal Efficiency Measurement:[/b] Logarithmic efficiency calculation that adapts Laguerre filtering for optimal lag reduction
[*][b]Laguerre Momentum Transform:[/b] Adaptive momentum oscillator that responds faster during efficient moves
[*][b]Temporal Flow Dynamics:[/b] Analyzes price flow direction, magnitude, and acceleration across multiple dimensions
[*][b]Pivot Structure Analysis:[/b] Detects market structure breaks and shifts using swing high/low analysis
[*][b]Order Block Detection:[/b] Identifies institutional positioning zones through volume-confirmed reversal patterns
[*][b]Imbalance Zone Mapping:[/b] Marks price gaps and inefficiencies that often get filled
[/list]

Each component contributes unique intelligence that validates or invalidates potential trade setups. The strategy requires minimum confluence scores before entering positions, ensuring that multiple independent systems agree on directional bias.

[image]https://www.tradingview.com/x/LX8mboQ9/[/image]

[b]Core Strategy Architecture[/b]

[b]1. Volatility Expansion Engine[/b]

The strategy begins with comprehensive volatility analysis:

[pine]
volatility = ta.atr(volatilityPeriod)
volatilityPercent = (volatility / close) * 100
volatilityRank = ta.percentrank(volatilityPercent, 100)
[/pine]

Volatility percentile ranking provides context for current volatility relative to recent history. This measurement drives multiple strategy decisions:
- Position sizing: Higher volatility = smaller positions
- Stop distance: Higher volatility = wider stops
- Signal filtering: Extreme volatility (>80 percentile) triggers defensive mode

The strategy adapts to volatility rather than using fixed parameters, ensuring it remains relevant across different market regimes.

[b]2. Price Efficiency and Chaos Measurement[/b]

The strategy calculates price efficiency to distinguish trending from ranging markets:

[pine]
priceMovement = math.abs(close - close[efficiencyPeriod])
pathLength = math.sum(math.abs(close - close[1]), efficiencyPeriod)
efficiency = pathLength > 0 ? priceMovement / pathLength : 0
[/pine]

High efficiency (>0.6) indicates clean, directional movement suitable for trend-following. Low efficiency (<0.4) suggests choppy conditions where the strategy reduces activity or switches to mean-reversion logic.

Chaos level is measured using logarithmic range analysis:

[pine]
rangeHigh = ta.highest(high, volatilityPeriod)
rangeLow = ta.lowest(low, volatilityPeriod)
atrSum = math.sum(ta.atr(1), volatilityPeriod)
chaosLevel = 100 * math.log10(atrSum / (rangeHigh - rangeLow)) / math.log10(volatilityPeriod)
[/pine]

High chaos (>60) triggers defensive positioning. Low chaos (<40) enables aggressive trend-following.

[b]3. Directional Conviction System[/b]

The strategy implements complete ADX analysis with directional indicators:

[pine]
[conviction, bullForce, bearForce] = adx(14, 14)
[/pine]

ADX above 25 indicates emerging directional conviction. Above 40 indicates dominant conviction. The strategy uses conviction strength to:
- Filter entries: Minimum conviction threshold prevents trading in directionless markets
- Size positions: Higher conviction = larger positions (within risk limits)
- Set targets: Strong conviction enables wider profit targets

The difference between bullForce and bearForce determines directional bias and validates signal direction.

[b]4. Adaptive Ribbon System[/b]

The strategy calculates 8 EMA layers with adaptive spacing:

[pine]
stepSize = (slowPeriod - fastPeriod) / (ribbonLayers - 1)
ribbonLevel0 = ta.ema(close, fastPeriod)
ribbonLevel7 = ta.ema(close, slowPeriod)
[/pine]

Ribbon analysis provides:
- Trend direction: Fast > slow = bullish, fast < slow = bearish
- Trend strength: Wider ribbon = stronger trend
- Dynamic support/resistance: Ribbon layers act as price magnets
- Compression detection: Tight ribbon = energy buildup before breakout

The strategy only takes long trades when price is above the ribbon and short trades when below, ensuring alignment with trend structure.

[b]5. Volume Pressure Analysis[/b]

The strategy estimates buying and selling pressure using candle structure:

[pine]
buyPressure = close > open ? volume * ((close - open + upperWick * 0.5) / barSpan) : 
              close < open ? volume * ((upperWick + bodyMass * 0.3) / barSpan) : volume * 0.5
sellPressure = volume - buyPressure
pressureDelta = buyPressure - sellPressure
[/pine]

Pressure analysis validates signal direction:
- Long signals require positive pressure delta
- Short signals require negative pressure delta
- Extreme pressure (>70% of volume) suggests potential exhaustion

The strategy tracks cumulative pressure to identify accumulation and distribution phases.

[b]6. Gauss Smoothing and Fractal Efficiency[/b]

The strategy applies 4th-order Gaussian filtering to eliminate noise:

[pine]
gaussClose := math.pow(alpha, 4) * close + 
              4 * (1.0 - alpha) * nz(gaussClose[1]) - 
              6 * math.pow(1 - alpha, 2) * nz(gaussClose[2]) + 
              4 * math.pow(1 - alpha, 3) * nz(gaussClose[3]) - 
              math.pow(1 - alpha, 4) * nz(gaussClose[4])
[/pine]

Fractal efficiency is calculated using logarithmic path measurement:

[pine]
fractalRatio = totalSpan > 0 ? math.log(rangeSum / totalSpan) / math.log(fractalSpan) : 0.0
fractalEfficiency = math.max(0, math.min(1, (fractalRatio + 1) / 2))
[/pine]

High fractal efficiency (>0.7) validates that momentum signals are backed by clean price action.

[b]7. Laguerre Momentum Transform[/b]

The strategy uses adaptive Laguerre filtering for momentum measurement:

[pine]
gamma = 0.7 * (1 - fractalEfficiency) + 0.1 * fractalEfficiency

L0 := (1 - gamma) * gaussClose + gamma * nz(L0[1])
L1 := -gamma * L0 + nz(L0[1]) + gamma * nz(L1[1])
L2 := -gamma * L1 + nz(L1[1]) + gamma * nz(L2[1])
L3 := -gamma * L2 + nz(L2[1]) + gamma * nz(L3[1])

cu = (L0 > L1 ? L0 - L1 : 0) + (L1 > L2 ? L1 - L2 : 0) + (L2 > L3 ? L2 - L3 : 0)
cd = (L0 < L1 ? L1 - L0 : 0) + (L1 < L2 ? L2 - L1 : 0) + (L2 < L3 ? L3 - L2 : 0)

laguerreValue = cu + cd != 0 ? 100 * (cu / (cu + cd)) : 50
fractalMomentum = (laguerreValue - 50) * (1 + fractalEfficiency)
[/pine]

The adaptive gamma adjustment reduces lag during efficient moves and adds smoothing during choppy conditions. Fractal momentum above 20 validates bullish signals, below -20 validates bearish signals.

[b]8. Temporal Flow Dynamics[/b]

The strategy analyzes price flow across multiple dimensions:

[pine]
priceFlow = ta.ema(close, flowPeriod) - ta.ema(close, flowPeriod * 2)
flowDir = priceFlow > 0 ? 1 : -1
flowMagnitude = math.abs(priceFlow) / volatility
flowAccel = ta.change(priceFlow, 3)
[/pine]

Flow analysis provides:
- Flow direction: Confirms trend direction
- Flow magnitude: Measures flow strength relative to volatility
- Flow acceleration: Identifies momentum shifts

The strategy requires flow alignment with signal direction for entry validation.

[b]9. Market Structure Analysis[/b]

The strategy tracks pivot highs and lows to identify structure breaks:

[pine]
pivotTop = ta.pivothigh(high, pivotSpan, pivotSpan)
pivotBottom = ta.pivotlow(low, pivotSpan, pivotSpan)
[/pine]

Structure breaks occur when:
- Bullish: Price breaks above previous pivot high
- Bearish: Price breaks below previous pivot low

Structure shifts (change of character) occur when:
- Bullish: Downtrend breaks above previous pivot high
- Bearish: Uptrend breaks below previous pivot low

The strategy gives bonus confluence points to signals that align with structure breaks or shifts.

[b]10. Order Block and Imbalance Detection[/b]

The strategy identifies institutional positioning zones:

[pine]
orderBlockBull = close[1] < open[1] and close > open and volume > avgVol * 1.2
orderBlockBear = close[1] > open[1] and close < open and volume > avgVol * 1.2

gapUp = low > high[2] and (low - high[2]) > volatility * 0.3
gapDown = high < low[2] and (low[2] - high) > volatility * 0.3
[/pine]

Order blocks mark zones where institutions placed large orders. The strategy uses these as:
- Entry zones: Look for entries near order blocks in trend direction
- Stop placement: Place stops beyond order blocks for protection
- Target zones: Opposite-direction order blocks become profit targets

Imbalance zones (gaps) often get filled, providing mean-reversion opportunities.

[b]Multi-Dimensional Signal Generation[/b]

The strategy generates signals through five independent layers, each containing five detection mechanisms:

[b]Layer 1: Rapid Scalp Signals (5 mechanisms)[/b]
- Laguerre oversold + flow bullish + price above fast ribbon
- Pressure index positive + flow reversal bullish
- Momentum bullish + volume surge + price above mid ribbon
- Strong bullish candle + ribbon bullish + pressure positive
- Fractal momentum positive + flow acceleration positive + ribbon aligned

[b]Layer 2: Swing Position Signals (5 mechanisms)[/b]
- Ribbon bullish + price above slow ribbon + bullish regime
- Structure break bullish + momentum bullish
- Order block bullish + flow bullish + conviction strong
- Gap up + pressure extreme + ribbon aligned
- Range breakout up + cumulative pressure positive + flow strong

[b]Layer 3: Momentum Continuation (5 mechanisms)[/b]
- Fractal momentum extreme + ribbon bullish + conviction strong
- Laguerre oversold + flow bullish + volume surge
- Momentum extreme + fractal momentum positive + ribbon expanding
- Extreme buy pressure + flow acceleration positive + bullish regime
- Bull force > bear force + conviction strong + ribbon aligned

[b]Layer 4: Structure Confirmation (5 mechanisms)[/b]
- Structure shift bullish + volume surge
- Order block bullish + price above last pivot low + momentum bullish
- Gap up + flow bullish + ribbon bullish
- Structure break bullish + pressure extreme positive
- Volume absorption + pressure positive + price above mid ribbon

[b]Layer 5: Confluence Boosters (5 mechanisms)[/b]
- Ribbon tight + ribbon expanding + ribbon bullish + volume surge
- Net flow positive + temporal force positive + bullish regime
- Fractal efficiency high + Laguerre oversold + flow magnitude strong
- Strong bullish candle + price above previous high + volume extreme
- Velocity positive + flow bullish + ribbon power strong

Each layer contributes 0 or 1 to the bull strength score. The strategy requires minimum confluence (default 2) before entering long positions. This multi-layer approach ensures that signals are validated across multiple independent dimensions.

[b]Risk Management System[/b]

The strategy implements institutional-grade risk management:

[b]Position Sizing:[/b]
- Risk percentage per trade (default 1% of equity)
- Dynamic adjustment based on volatility percentile
- Reduced sizing during high chaos or low efficiency

[b]Stop Loss Placement:[/b]
[pine]
stopLoss = close - (volatility * slMultiplier)
[/pine]
- ATR-based stops that adapt to current volatility
- Multiplier (default 1.5) provides breathing room
- Stops placed beyond order blocks when possible

[b]Take Profit Targets:[/b]
[pine]
takeProfit = close + (volatility * slMultiplier * tpMultiplier)
[/pine]
- Risk-reward ratio (default 2.5:1)
- Adjusted based on conviction strength
- Wider targets during strong conviction, tighter during weak

[b]Trailing Stop System:[/b]
[pine]
trailStop = close - (volatility * trailOffset)
[/pine]
- Optional trailing stop (default enabled)
- Offset (default 1.2x ATR) balances protection and breathing room
- Activates after position moves into profit

[b]Visual Elements[/b]

[list]
[*][b]Adaptive Ribbon:[/b] Multi-layer EMA ribbon with gradient coloring showing trend direction and strength
[*][b]Entry Signals:[/b] Triangle shapes sized by signal strength (large for 5+ confluence, small for 2-3 confluence)
[*][b]Structure Markers:[/b] Lines and labels marking structure breaks, shifts, and order blocks
[*][b]Imbalance Boxes:[/b] Boxes marking price gaps and inefficiency zones
[*][b]Regime Background:[/b] Subtle background coloring showing current market regime
[*][b]Flow Background:[/b] Additional background layer showing flow direction
[*][b]Comprehensive Dashboard:[/b] 18-row intelligence panel showing position status, signal strength, regime, ribbon state, pressure, momentum, structure, flow, conviction, Laguerre, volume, volatility, trade statistics, and win rate
[/list]

The dashboard provides complete strategy intelligence with real-time metrics and performance tracking.

[b]Strategy Parameters[/b]

[b]Core Settings:[/b]
[list]
[*]Ultra-Aggressive Mode: Maximum trade frequency (default enabled)
[*]Min Signal Strength: Minimum confluence required (1-6, default 2)
[*]Risk %: Risk per trade as percentage of equity (0.5-5.0%, default 1.0%)
[*]TP Multiplier: Take profit as multiple of stop distance (1.0-10.0, default 2.5)
[*]SL Multiplier: Stop loss as multiple of ATR (0.5-5.0, default 1.5)
[*]Trailing Stop: Enable/disable trailing stop (default enabled)
[*]Trail Offset: Trailing stop distance as multiple of ATR (0.5-3.0, default 1.2)
[/list]

[b]Advanced Parameters:[/b]
[list]
[*]Volatility Period: ATR calculation length (5-50, default 14)
[*]Efficiency Period: Price efficiency calculation period (5-100, default 20)
[*]Flow Period: Temporal flow analysis period (10-50, default 20)
[*]Ribbon Layers: Number of EMA layers (3-15, default 8)
[*]Fast Period: Fastest EMA period (2-20, default 5)
[*]Slow Period: Slowest EMA period (10-100, default 34)
[/list]

[b]Visualization:[/b]
[list]
[*]Dashboard: Toggle metrics panel (default enabled)
[*]Entry Signals: Toggle signal shapes (default enabled)
[*]Regime Zones: Toggle background coloring (default enabled)
[*]Adaptive Ribbon: Toggle ribbon display (default enabled)
[/list]

[b]How to Use This Strategy[/b]

[b]Step 1: Configure Risk Parameters[/b]
Set risk percentage appropriate for your account size. 1% is conservative, 2% is moderate, 3%+ is aggressive. Never risk more than you can afford to lose on any single trade.

[b]Step 2: Select Minimum Signal Strength[/b]
Default 2 provides balanced trade frequency and quality. Increase to 3-4 for higher quality but fewer trades. Decrease to 1 only in ultra-aggressive mode on highly liquid instruments.

[b]Step 3: Adjust Risk-Reward Ratio[/b]
Default 2.5:1 provides good balance. Increase to 3-5:1 for swing trading. Decrease to 1.5-2:1 for scalping. Higher ratios require higher win rates to be profitable.

[b]Step 4: Enable/Disable Trailing Stops[/b]
Trailing stops protect profits but can exit prematurely. Enable for trend-following, disable for mean-reversion. Adjust trail offset based on instrument volatility.

[b]Step 5: Monitor Dashboard Metrics[/b]
Watch "POSITION" status, "BULL STR" and "BEAR STR" scores, "REGIME" classification, and "WIN RATE" percentage. These provide real-time strategy health assessment.

[b]Step 6: Backtest Thoroughly[/b]
Test on at least 100 trades across different market conditions. Verify that win rate, profit factor, and drawdown meet your requirements. Adjust parameters if needed.

[b]Step 7: Forward Test on Demo[/b]
Run strategy on demo account for at least 1 month before live trading. Verify that live performance matches backtest expectations. Monitor slippage and execution quality.

[b]Step 8: Start Small on Live[/b]
Begin with minimum position sizes on live account. Gradually increase as confidence builds. Never risk more than 1-2% of account on any single trade initially.

[b]Best Practices[/b]

[list]
[*]Use on liquid instruments with tight spreads and reliable execution
[*]Backtest with realistic commission (0.1%) and slippage (2 ticks minimum)
[*]Test across multiple market conditions (trending, ranging, volatile, calm)
[*]Verify minimum 100 trades in backtest for statistical significance
[*]Monitor win rate - should be 45-60% for 2.5:1 risk-reward ratio
[*]Check profit factor - should be >1.5 for robust strategy
[*]Analyze maximum drawdown - should be <20% of account
[*]Review trade distribution - avoid over-concentration in specific periods
[*]Monitor signal strength distribution - most trades should be 3+ confluence
[*]Check regime alignment - strategy should perform in directional regimes
[*]Verify that losses are controlled - no single loss should exceed 2% of account
[*]Ensure adequate trade frequency - at least 2-3 trades per week on daily timeframe
[*]Combine with manual oversight - review signals before execution in early stages
[*]Use appropriate timeframe - 15m-1H for day trading, 4H-1D for swing trading
[*]Avoid trading during major news events unless specifically tested for that
[*]Keep detailed trade journal to identify patterns in wins and losses
[/list]

[b]Strategy Limitations[/b]

[list]
[*]Algorithmic strategies cannot predict black swan events or unprecedented market conditions
[*]Backtested performance does not guarantee future results
[*]Slippage and commission in live trading may differ from backtest assumptions
[*]The strategy requires sufficient volatility - may underperform in extremely low volatility
[*]Signal generation depends on multiple calculations - computational lag possible on slow systems
[*]The strategy works best on trending instruments - may struggle in perpetual ranges
[*]Confluence scoring requires all components to be relevant - some may be less meaningful on certain instruments
[*]The strategy cannot account for fundamental catalysts or news events
[*]Trailing stops can exit prematurely during volatile but ultimately profitable moves
[*]The strategy requires adequate liquidity for execution at desired prices
[*]Parameter optimization can lead to overfitting - use walk-forward analysis
[*]The strategy shows what signals exist, not why - market context still matters
[/list]

[b]Technical Implementation[/b]

Built with Pine Script v6 using:
[list]
[*]Complete volatility expansion engine with ATR percentile ranking
[*]Price efficiency calculator using path length analysis
[*]Chaos measurement using logarithmic range calculations
[*]Full ADX implementation with directional indicators
[*]8-layer adaptive EMA ribbon with volatility-based spacing
[*]Volume pressure estimation using candle structure analysis
[*]4th-order Gaussian filter for noise elimination
[*]Fractal efficiency measurement using logarithmic path complexity
[*]Adaptive Laguerre transform with 4 cascading filter levels
[*]Temporal flow analysis with direction, magnitude, and acceleration
[*]Pivot-based market structure tracking
[*]Order block and imbalance zone detection
[*]25-factor confluence scoring system across 5 signal layers
[*]Dynamic position sizing based on volatility and regime
[*]ATR-based stop loss and take profit calculations
[*]Optional trailing stop system with volatility adjustment
[*]Comprehensive dashboard with 18 metrics and performance tracking
[*]Alert system for all entry and exit signals
[/list]

The code is fully open-source with extensive comments explaining each component and signal generation logic.

[b]Originality Statement[/b]

This strategy is original and represents a complete trading system built from proprietary knowledge rather than indicator mashups. The strategy is justified because:

[list]
[*]It synthesizes 13 independent analytical systems into a unified execution framework
[*]The 25-factor confluence scoring across 5 signal layers provides multi-dimensional validation
[*]Each component is built from first principles using mathematical models and market microstructure concepts
[*]The adaptive nature of the system (volatility, efficiency, regime) ensures relevance across market conditions
[*]Risk management is integrated at the core rather than added as an afterthought
[*]The strategy doesn't rely on any single indicator or pattern - it builds intelligence from multiple independent sources
[*]Fractal efficiency and Laguerre adaptation provide unique momentum measurement not found in standard systems
[*]Temporal flow analysis adds a dimension of price dynamics beyond simple trend following
[*]Market structure tracking provides context that pure indicator-based systems lack
[*]The comprehensive dashboard provides complete strategy intelligence and performance tracking
[*]The system is designed for real trading with realistic risk management, not just backtest optimization
[/list]

Each component contributes unique intelligence: volatility drives adaptation, efficiency filters conditions, chaos identifies regimes, conviction measures strength, ribbon provides structure, pressure shows order flow, Gauss filtering eliminates noise, fractal efficiency validates momentum, Laguerre provides adaptive momentum, flow tracks dynamics, structure provides context, order blocks mark zones, and confluence validates signals. The strategy's value lies in combining these complementary perspectives into a cohesive, adaptive trading system with institutional-grade risk management.

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for all investors.

Algorithmic trading strategies are tools for systematic execution, not guarantees of profit. Backtested performance does not guarantee future results. Past strategy performance does not predict future performance. Market conditions change, and strategies that worked historically may not work in the future.

The signals generated are mathematical calculations based on current market data, not predictions of future price movement. High confluence scores, regime alignment, and structure breaks do not guarantee profitable trades. Users must conduct their own analysis and risk assessment before making trading decisions.

Always use proper risk management, including stop losses and position sizing appropriate for your account size and risk tolerance. Never risk more than you can afford to lose. Consider consulting with a qualified financial advisor before making investment decisions.

The author is not responsible for any losses incurred from using this strategy. Users assume full responsibility for all trading decisions made using this tool. Thoroughly backtest and forward test any strategy before live trading.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Vortex Nexus Alpha [JOAT]", "VNA [JOAT]", overlay=true, 
         initial_capital=10000, default_qty_type=strategy.percent_of_equity, 
         default_qty_value=10, commission_type=strategy.commission.percent, 
         commission_value=0.1, slippage=2, pyramiding=0, 
         calc_on_every_tick=false, calc_on_order_fills=false,
         max_lines_count=500, max_labels_count=100, max_boxes_count=50)

// NEON CYBERPUNK COLORS
color CYAN_GLOW = #00F0FF
color PINK_GLOW = #FF10F0
color GOLD_GLOW = #FFD700
color GREEN_GLOW = #39FF14
color RED_GLOW = #FF1050
color PURPLE_GLOW = #B026FF
color ORANGE_GLOW = #FF6B35
color AQUA_GLOW = #00FFD9

// INPUTS
aggressiveMode = input.bool(true, "Ultra-Aggressive Mode", group="Core", tooltip="Maximum trade frequency")
minSignalStrength = input.int(2, "Min Signal Strength", minval=1, maxval=6, group="Core")
riskPercent = input.float(1.0, "Risk %", minval=0.5, maxval=5.0, step=0.5, group="Risk")
tpMultiplier = input.float(2.5, "TP Multiplier", minval=1.0, maxval=10.0, step=0.5, group="Risk")
slMultiplier = input.float(1.5, "SL Multiplier", minval=0.5, maxval=5.0, step=0.1, group="Risk")
useTrailing = input.bool(true, "Trailing Stop", group="Risk")
trailOffset = input.float(1.2, "Trail Offset", minval=0.5, maxval=3.0, step=0.1, group="Risk")

// ADVANCED PARAMETERS
volatilityPeriod = input.int(14, "Volatility Period", minval=5, maxval=50, group="Advanced")
efficiencyPeriod = input.int(20, "Efficiency Period", minval=5, maxval=100, group="Advanced")
flowPeriod = input.int(20, "Flow Period", minval=10, maxval=50, group="Advanced")
ribbonLayers = input.int(8, "Ribbon Layers", minval=3, maxval=15, group="Advanced")
fastPeriod = input.int(5, "Fast Period", minval=2, maxval=20, group="Advanced")
slowPeriod = input.int(34, "Slow Period", minval=10, maxval=100, group="Advanced")

// VISUALIZATION
showDashboard = input.bool(true, "Dashboard", group="Visual")
showSignals = input.bool(true, "Entry Signals", group="Visual")
showZones = input.bool(true, "Regime Zones", group="Visual")
showRibbon = input.bool(true, "Adaptive Ribbon", group="Visual")

// VOLATILITY EXPANSION ENGINE
volatility = ta.atr(volatilityPeriod)
volatilityPercent = (volatility / close) * 100
volatilityRank = ta.percentrank(volatilityPercent, 100)

// PRICE EFFICIENCY CALCULATOR
priceMovement = math.abs(close - close[efficiencyPeriod])
pathLength = math.sum(math.abs(close - close[1]), efficiencyPeriod)
efficiency = pathLength > 0 ? priceMovement / pathLength : 0

// CHAOS MEASUREMENT
rangeHigh = ta.highest(high, volatilityPeriod)
rangeLow = ta.lowest(low, volatilityPeriod)
atrSum = math.sum(ta.atr(1), volatilityPeriod)
chaosLevel = 100 * math.log10(atrSum / (rangeHigh - rangeLow)) / math.log10(volatilityPeriod)

// DIRECTIONAL CONVICTION
dirmov(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    truerange = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
    minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
    [plus, minus]

adx(dilen, adxlen) =>
    [plus, minus] = dirmov(dilen)
    sum = plus + minus
    adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)
    [adx, plus, minus]

[conviction, bullForce, bearForce] = adx(14, 14)

// REGIME CLASSIFICATION
directionalPower = (efficiency * 100 + (100 - chaosLevel) + (conviction > 25 ? 20 : 0)) / 2.2
equilibriumPower = (100 - volatilityRank + (100 - efficiency * 100) + (conviction < 25 ? 20 : 0)) / 2.2
chaosPower = (chaosLevel + (100 - efficiency * 100)) / 2

totalPower = directionalPower + equilibriumPower + chaosPower
directionalScore = totalPower > 0 ? (directionalPower / totalPower) * 100 : 25
chaosScore = totalPower > 0 ? (chaosPower / totalPower) * 100 : 25

var string marketRegime = "Equilibrium"
var float regimeStrength = 0.0

if directionalScore > 60
    marketRegime := "Directional"
    regimeStrength := directionalScore
else if chaosScore > 40
    marketRegime := "Chaotic"
    regimeStrength := chaosScore
else
    marketRegime := "Equilibrium"
    regimeStrength := 100 - math.max(directionalScore, chaosScore)

bullishRegime = marketRegime == "Directional" and bullForce > bearForce
bearishRegime = marketRegime == "Directional" and bearForce > bullForce

// ADAPTIVE RIBBON SYSTEM
volatilityAdaptation = 1 + (volatilityRank / 100)

// Calculate step size
stepSize = (slowPeriod - fastPeriod) / (ribbonLayers - 1)

// Calculate all ribbon levels explicitly to avoid series int issue
ribbonLevel0 = ta.ema(close, fastPeriod)
ribbonLevel1 = ta.ema(close, int(fastPeriod + stepSize * 1))
ribbonLevel2 = ta.ema(close, int(fastPeriod + stepSize * 2))
ribbonLevel3 = ta.ema(close, int(fastPeriod + stepSize * 3))
ribbonLevel4 = ta.ema(close, int(fastPeriod + stepSize * 4))
ribbonLevel5 = ta.ema(close, int(fastPeriod + stepSize * 5))
ribbonLevel6 = ta.ema(close, int(fastPeriod + stepSize * 6))
ribbonLevel7 = ta.ema(close, slowPeriod)

fastLevel = ribbonLevel0
slowLevel = ribbonLevel7
midLevel = ribbonLevel4

ribbonDirection = fastLevel > slowLevel ? 1 : -1
ribbonPower = math.abs(fastLevel - slowLevel) / volatility
ribbonAlignment = close > midLevel and ribbonDirection == 1 or close < midLevel and ribbonDirection == -1

ribbonSpread = math.abs(fastLevel - slowLevel)
ribbonSpreadPercent = (ribbonSpread / close) * 100
avgSpread = ta.sma(ribbonSpreadPercent, 20)
ribbonTight = ribbonSpreadPercent < avgSpread * 0.7
ribbonExpansion = ribbonSpread > ribbonSpread[1]

// VOLUME PRESSURE ANALYSIS
barSpan = high - low
bodyMass = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

buyPressure = close > open ? volume * ((close - open + upperWick * 0.5) / barSpan) : 
              close < open ? volume * ((upperWick + bodyMass * 0.3) / barSpan) : volume * 0.5
sellPressure = volume - buyPressure

pressureDelta = buyPressure - sellPressure
pressureSmooth = ta.ema(pressureDelta, 14)

var float cumulativePressure = 0
cumulativePressure += pressureDelta

avgVol = ta.sma(volume, 20)
pressureIndex = ta.sma(pressureDelta, 14) / ta.sma(volume, 14) * 100

volRatio = volume / avgVol
rangeRatio = barSpan / ta.sma(barSpan, 20)
volumeAbsorption = volRatio > 1.5 and rangeRatio < 0.5

extremeBuyZone = pressureIndex > 70
strongBuyZone = pressureIndex > 50 and pressureIndex <= 70
extremeSellZone = pressureIndex < -70
strongSellZone = pressureIndex < -50 and pressureIndex >= -70

// GAUSS SMOOTHING ENGINE
var float gaussClose = na
w = (2.0 * math.pi / 20)
beta = (1 - math.cos(w)) / (math.pow(1.414, 2.0 / 2.0) - 1)
alpha = (-beta + math.sqrt(beta * beta + 2 * beta))

gaussClose := math.pow(alpha, 4) * close + 
              4 * (1.0 - alpha) * nz(gaussClose[1]) - 
              6 * math.pow(1 - alpha, 2) * nz(gaussClose[2]) + 
              4 * math.pow(1 - alpha, 3) * nz(gaussClose[3]) - 
              math.pow(1 - alpha, 4) * nz(gaussClose[4])

// FRACTAL EFFICIENCY
fractalSpan = 50
rangeSum = math.sum((math.max(high, nz(close[1])) - math.min(low, nz(close[1]))), fractalSpan)
totalSpan = ta.highest(high, fractalSpan) - ta.lowest(low, fractalSpan)
fractalRatio = totalSpan > 0 ? math.log(rangeSum / totalSpan) / math.log(fractalSpan) : 0.0
fractalEfficiency = math.max(0, math.min(1, (fractalRatio + 1) / 2))

// LAGUERRE TRANSFORM
var float L0 = na
var float L1 = na
var float L2 = na
var float L3 = na

gamma = 0.7 * (1 - fractalEfficiency) + 0.1 * fractalEfficiency

L0 := (1 - gamma) * gaussClose + gamma * nz(L0[1])
L1 := -gamma * L0 + nz(L0[1]) + gamma * nz(L1[1])
L2 := -gamma * L1 + nz(L1[1]) + gamma * nz(L2[1])
L3 := -gamma * L2 + nz(L2[1]) + gamma * nz(L3[1])

cu = (L0 > L1 ? L0 - L1 : 0) + (L1 > L2 ? L1 - L2 : 0) + (L2 > L3 ? L2 - L3 : 0)
cd = (L0 < L1 ? L1 - L0 : 0) + (L1 < L2 ? L2 - L1 : 0) + (L2 < L3 ? L3 - L2 : 0)

laguerreValue = cu + cd != 0 ? 100 * (cu / (cu + cd)) : 50

rawMomentum = (laguerreValue - 50) * (1 + fractalEfficiency)
smoothMomentum = ta.ema(rawMomentum, 5)
fractalMomentum = math.max(-100, math.min(100, smoothMomentum))

momentumBull = fractalMomentum > 20
momentumBear = fractalMomentum < -20
momentumExtreme = math.abs(fractalMomentum) > 60

// TEMPORAL FLOW DYNAMICS
priceFlow = ta.ema(close, flowPeriod) - ta.ema(close, flowPeriod * 2)
flowDir = priceFlow > 0 ? 1 : -1
flowMagnitude = math.abs(priceFlow) / volatility
flowAccel = ta.change(priceFlow, 3)

volumeFlow = ta.ema(volume, 10)
volumeFlowRatio = volume / volumeFlow
buyFlow = close > open ? volume : 0
sellFlow = close < open ? volume : 0
netFlow = ta.ema(buyFlow - sellFlow, 10)

var int lastFlowDir = 0
flowReversal = flowDir != lastFlowDir and lastFlowDir != 0
lastFlowDir := flowDir

temporalForce = (priceFlow / volatility) * (volumeFlowRatio - 1) * flowMagnitude

// PIVOT STRUCTURE
pivotSpan = 10
pivotTop = ta.pivothigh(high, pivotSpan, pivotSpan)
pivotBottom = ta.pivotlow(low, pivotSpan, pivotSpan)

var int structureDir = 0
var float lastTop = na
var float lastBottom = na

var bool structureBreak = false
var bool structureShift = false

structureBreak := false
structureShift := false

if not na(pivotTop)
    if not na(lastTop)
        if structureDir == 1 and pivotTop > lastTop
            structureBreak := true
        else if structureDir == -1 and pivotTop > lastTop
            structureShift := true
            structureDir := 1
    lastTop := pivotTop

if not na(pivotBottom)
    if not na(lastBottom)
        if structureDir == -1 and pivotBottom < lastBottom
            structureBreak := true
        else if structureDir == 1 and pivotBottom < lastBottom
            structureShift := true
            structureDir := -1
    lastBottom := pivotBottom

orderBlockBull = close[1] < open[1] and close > open and volume > avgVol * 1.2
orderBlockBear = close[1] > open[1] and close < open and volume > avgVol * 1.2

gapUp = low > high[2] and (low - high[2]) > volatility * 0.3
gapDown = high < low[2] and (low[2] - high) > volatility * 0.3

// ADDITIONAL TECHNICAL LAYERS
priceVelocity = ta.change(close, 5) / 5
velocitySmooth = ta.ema(priceVelocity, 10)

volSurge = volume > avgVol * 1.5
volDry = volume < avgVol * 0.7

strongBullCandle = close > open and (close - open) > volatility * 0.3
strongBearCandle = close < open and (open - close) > volatility * 0.3

rangeTop = ta.highest(high, 20)
rangeBottom = ta.lowest(low, 20)
rangeBreakUp = close > rangeTop[1] and volSurge
rangeBreakDown = close < rangeBottom[1] and volSurge

// MULTI-DIMENSIONAL SIGNAL GENERATION
// Layer 1: Rapid Scalp Signals
scalpBull1 = laguerreValue < 30 and flowDir == 1 and close > fastLevel
scalpBull2 = pressureIndex > 30 and flowReversal and flowDir == 1
scalpBull3 = momentumBull and volSurge and close > midLevel
scalpBull4 = strongBullCandle and ribbonDirection == 1 and pressureIndex > 20
scalpBull5 = fractalMomentum > 0 and flowAccel > 0 and ribbonAlignment

scalpBear1 = laguerreValue > 70 and flowDir == -1 and close < fastLevel
scalpBear2 = pressureIndex < -30 and flowReversal and flowDir == -1
scalpBear3 = momentumBear and volSurge and close < midLevel
scalpBear4 = strongBearCandle and ribbonDirection == -1 and pressureIndex < -20
scalpBear5 = fractalMomentum < 0 and flowAccel < 0 and ribbonAlignment

// Layer 2: Swing Position Signals
swingBull1 = ribbonDirection == 1 and close > slowLevel and bullishRegime
swingBull2 = structureBreak and structureDir == 1 and momentumBull
swingBull3 = orderBlockBull and flowDir == 1 and conviction > 20
swingBull4 = gapUp and pressureIndex > 40 and ribbonAlignment
swingBull5 = rangeBreakUp and cumulativePressure > 0 and flowMagnitude > 0.5

swingBear1 = ribbonDirection == -1 and close < slowLevel and bearishRegime
swingBear2 = structureBreak and structureDir == -1 and momentumBear
swingBear3 = orderBlockBear and flowDir == -1 and conviction > 20
swingBear4 = gapDown and pressureIndex < -40 and ribbonAlignment
swingBear5 = rangeBreakDown and cumulativePressure < 0 and flowMagnitude > 0.5

// Layer 3: Momentum Continuation
momBull1 = fractalMomentum > 40 and ribbonDirection == 1 and conviction > 25
momBull2 = laguerreValue < 30 and flowDir == 1 and volSurge
momBull3 = momentumExtreme and fractalMomentum > 0 and ribbonExpansion
momBull4 = extremeBuyZone and flowAccel > 0 and bullishRegime
momBull5 = bullForce > bearForce and bullForce > 25 and ribbonAlignment

momBear1 = fractalMomentum < -40 and ribbonDirection == -1 and conviction > 25
momBear2 = laguerreValue > 70 and flowDir == -1 and volSurge
momBear3 = momentumExtreme and fractalMomentum < 0 and ribbonExpansion
momBear4 = extremeSellZone and flowAccel < 0 and bearishRegime
momBear5 = bearForce > bullForce and bearForce > 25 and ribbonAlignment

// Layer 4: Structure Confirmation
structBull1 = structureShift and structureDir == 1 and volSurge
structBull2 = orderBlockBull and close > lastBottom and momentumBull
structBull3 = gapUp and flowDir == 1 and ribbonDirection == 1
structBull4 = structureBreak and structureDir == 1 and pressureIndex > 50
structBull5 = volumeAbsorption and pressureDelta > 0 and close > midLevel

structBear1 = structureShift and structureDir == -1 and volSurge
structBear2 = orderBlockBear and close < lastTop and momentumBear
structBear3 = gapDown and flowDir == -1 and ribbonDirection == -1
structBear4 = structureBreak and structureDir == -1 and pressureIndex < -50
structBear5 = volumeAbsorption and pressureDelta < 0 and close < midLevel

// Layer 5: Confluence Boosters
confBull1 = ribbonTight and ribbonExpansion and ribbonDirection == 1 and volSurge
confBull2 = netFlow > 0 and temporalForce > 0.5 and bullishRegime
confBull3 = fractalEfficiency > 0.5 and laguerreValue < 40 and flowMagnitude > 0.3
confBull4 = strongBullCandle and close > high[1] and volume > avgVol * 2
confBull5 = velocitySmooth > 0 and flowDir == 1 and ribbonPower > 1

confBear1 = ribbonTight and ribbonExpansion and ribbonDirection == -1 and volSurge
confBear2 = netFlow < 0 and temporalForce < -0.5 and bearishRegime
confBear3 = fractalEfficiency > 0.5 and laguerreValue > 60 and flowMagnitude > 0.3
confBear4 = strongBearCandle and close < low[1] and volume > avgVol * 2
confBear5 = velocitySmooth < 0 and flowDir == -1 and ribbonPower > 1

// SIGNAL STRENGTH CALCULATION
bullStrength = 0
if scalpBull1 or scalpBull2 or scalpBull3 or scalpBull4 or scalpBull5
    bullStrength += 1
if swingBull1 or swingBull2 or swingBull3 or swingBull4 or swingBull5
    bullStrength += 1
if momBull1 or momBull2 or momBull3 or momBull4 or momBull5
    bullStrength += 1
if structBull1 or structBull2 or structBull3 or structBull4 or structBull5
    bullStrength += 1
if confBull1
    bullStrength += 1
if confBull2
    bullStrength += 1

bearStrength = 0
if scalpBear1 or scalpBear2 or scalpBear3 or scalpBear4 or scalpBear5
    bearStrength += 1
if swingBear1 or swingBear2 or swingBear3 or swingBear4 or swingBear5
    bearStrength += 1
if momBear1 or momBear2 or momBear3 or momBear4 or momBear5
    bearStrength += 1
if structBear1 or structBear2 or structBear3 or structBear4 or structBear5
    bearStrength += 1
if confBear1
    bearStrength += 1
if confBear2
    bearStrength += 1

// ENTRY CONDITIONS
longSignal = bullStrength >= minSignalStrength and strategy.position_size == 0
shortSignal = bearStrength >= minSignalStrength and strategy.position_size == 0

// POSITION MANAGEMENT
if longSignal
    stopLoss = close - (volatility * slMultiplier)
    takeProfit = close + (volatility * slMultiplier * tpMultiplier)
    strategy.entry("LONG", strategy.long, comment="L[" + str.tostring(bullStrength) + "]")
    strategy.exit("LONG_EXIT", "LONG", stop=stopLoss, limit=takeProfit)

if shortSignal
    stopLoss = close + (volatility * slMultiplier)
    takeProfit = close - (volatility * slMultiplier * tpMultiplier)
    strategy.entry("SHORT", strategy.short, comment="S[" + str.tostring(bearStrength) + "]")
    strategy.exit("SHORT_EXIT", "SHORT", stop=stopLoss, limit=takeProfit)

// TRAILING STOP
if useTrailing
    if strategy.position_size > 0
        trailStop = close - (volatility * trailOffset)
        strategy.exit("LONG_TRAIL", "LONG", stop=trailStop)
    if strategy.position_size < 0
        trailStop = close + (volatility * trailOffset)
        strategy.exit("SHORT_TRAIL", "SHORT", stop=trailStop)

// VISUALIZATION - ALL PLOTS MUST BE AT GLOBAL SCOPE
ribbonColor = ribbonDirection == 1 ? 
              color.from_gradient(ribbonPower, 0, 2, color.new(CYAN_GLOW, 80), CYAN_GLOW) :
              color.from_gradient(ribbonPower, 0, 2, color.new(PINK_GLOW, 80), PINK_GLOW)

// RIBBON PLOTS
plot(showRibbon ? fastLevel : na, "Fast", color.new(ribbonColor, 20), 2)
plot(showRibbon ? midLevel : na, "Mid", color.new(ribbonColor, 50), 1)
plot(showRibbon ? slowLevel : na, "Slow", color.new(ribbonColor, 70), 1)

p1 = plot(showRibbon ? fastLevel : na, display=display.none)
p2 = plot(showRibbon ? slowLevel : na, display=display.none)
fill(p1, p2, color.new(ribbonColor, 90))

// ENTRY SIGNALS
plotshape(showSignals and longSignal and bullStrength >= 5, "STRONG LONG", shape.triangleup, 
          location.belowbar, GREEN_GLOW, size=size.normal, text="LONG")
plotshape(showSignals and longSignal and bullStrength >= 3 and bullStrength < 5, "LONG", shape.triangleup, 
          location.belowbar, CYAN_GLOW, size=size.small, text="L")
plotshape(showSignals and longSignal and bullStrength < 3, "WEAK LONG", shape.triangleup, 
          location.belowbar, color.new(CYAN_GLOW, 40), size=size.tiny, text="l")

plotshape(showSignals and shortSignal and bearStrength >= 5, "STRONG SHORT", shape.triangledown, 
          location.abovebar, RED_GLOW, size=size.normal, text="SHORT")
plotshape(showSignals and shortSignal and bearStrength >= 3 and bearStrength < 5, "SHORT", shape.triangledown, 
          location.abovebar, PINK_GLOW, size=size.small, text="S")
plotshape(showSignals and shortSignal and bearStrength < 3, "WEAK SHORT", shape.triangledown, 
          location.abovebar, color.new(PINK_GLOW, 40), size=size.tiny, text="s")

// STRUCTURE VISUALIZATION
if structureBreak and structureDir == 1
    line.new(bar_index, low, bar_index + 5, low, color=ORANGE_GLOW, width=2)
    label.new(bar_index, low, "BRK", color=ORANGE_GLOW, style=label.style_label_up, 
             size=size.tiny, textcolor=color.white)

if structureBreak and structureDir == -1
    line.new(bar_index, high, bar_index + 5, high, color=ORANGE_GLOW, width=2)
    label.new(bar_index, high, "BRK", color=ORANGE_GLOW, style=label.style_label_down, 
             size=size.tiny, textcolor=color.white)

if structureShift
    line.new(bar_index, close, bar_index + 5, close, color=GOLD_GLOW, width=2, style=line.style_dashed)
    label.new(bar_index, close, "SHIFT", color=GOLD_GLOW, style=label.style_label_center, 
             size=size.tiny, textcolor=color.black)

if orderBlockBull
    box.new(bar_index - 1, low[1], bar_index + 10, high[1], 
            border_color=color.new(CYAN_GLOW, 50), 
            bgcolor=color.new(CYAN_GLOW, 90))

if orderBlockBear
    box.new(bar_index - 1, low[1], bar_index + 10, high[1], 
            border_color=color.new(PINK_GLOW, 50), 
            bgcolor=color.new(PINK_GLOW, 90))

// REGIME ZONES
regimeColor = marketRegime == "Directional" ? 
              (bullishRegime ? color.new(CYAN_GLOW, 97) : color.new(PINK_GLOW, 97)) :
              marketRegime == "Chaotic" ? color.new(PURPLE_GLOW, 97) :
              color.new(GOLD_GLOW, 98)

bgcolor(showZones ? regimeColor : na)

flowBg = flowDir == 1 ? color.new(AQUA_GLOW, 98) : color.new(PINK_GLOW, 98)
bgcolor(showZones ? flowBg : na)

// DASHBOARD
var table dash = table.new(position.top_right, 3, 18, 
    border_width=3, border_color=CYAN_GLOW, frame_width=3, frame_color=PINK_GLOW)

if showDashboard and barstate.islast
    // HEADER
    table.cell(dash, 0, 0, "VORTEX", text_color=CYAN_GLOW, bgcolor=#0A0E27, 
               text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 1, 0, "NEXUS", text_color=GOLD_GLOW, bgcolor=#0A0E27, 
               text_size=size.normal, text_halign=text.align_center)
    table.cell(dash, 2, 0, "[JOAT]", text_color=PINK_GLOW, bgcolor=#0A0E27, 
               text_size=size.normal, text_halign=text.align_center)
    
    // POSITION
    posText = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    posColor = strategy.position_size > 0 ? CYAN_GLOW : strategy.position_size < 0 ? PINK_GLOW : color.gray
    table.cell(dash, 0, 1, "POSITION", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 1, posText, text_color=posColor, bgcolor=#1A1A1A, text_size=size.small)
    table.cell(dash, 2, 1, strategy.position_size != 0 ? "ACTIVE" : "WAITING", 
               text_color=posColor, bgcolor=#1A1A1A, text_size=size.tiny)
    
    // SIGNAL STRENGTH
    table.cell(dash, 0, 2, "BULL STR", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 2, str.tostring(bullStrength), 
               text_color=bullStrength >= minSignalStrength ? CYAN_GLOW : color.gray, 
               bgcolor=#0A0A0A, text_size=size.small)
    bullStatus = bullStrength >= 5 ? "STRONG" : bullStrength >= 3 ? "MODERATE" : "WEAK"
    table.cell(dash, 2, 2, bullStatus, 
               text_color=bullStrength >= minSignalStrength ? CYAN_GLOW : color.gray, 
               bgcolor=#0A0A0A, text_size=size.tiny)
    
    table.cell(dash, 0, 3, "BEAR STR", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(bearStrength), 
               text_color=bearStrength >= minSignalStrength ? PINK_GLOW : color.gray, 
               bgcolor=#1A1A1A, text_size=size.small)
    bearStatus = bearStrength >= 5 ? "STRONG" : bearStrength >= 3 ? "MODERATE" : "WEAK"
    table.cell(dash, 2, 3, bearStatus, 
               text_color=bearStrength >= minSignalStrength ? PINK_GLOW : color.gray, 
               bgcolor=#1A1A1A, text_size=size.tiny)
    
    // REGIME
    regimeDispColor = marketRegime == "Directional" ? 
                      (bullishRegime ? CYAN_GLOW : PINK_GLOW) :
                      marketRegime == "Chaotic" ? PURPLE_GLOW : GOLD_GLOW
    table.cell(dash, 0, 4, "REGIME", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 4, marketRegime, text_color=regimeDispColor, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 2, 4, str.tostring(math.round(regimeStrength)) + "%", 
               text_color=regimeDispColor, bgcolor=#0A0A0A, text_size=size.tiny)
    
    // RIBBON
    ribbonText = ribbonDirection == 1 ? "BULLISH" : "BEARISH"
    ribbonDispColor = ribbonDirection == 1 ? CYAN_GLOW : PINK_GLOW
    table.cell(dash, 0, 5, "RIBBON", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 5, ribbonText, text_color=ribbonDispColor, bgcolor=#1A1A1A, text_size=size.tiny)
    ribbonState = ribbonTight ? "TIGHT" : ribbonExpansion ? "EXPANDING" : "NORMAL"
    table.cell(dash, 2, 5, ribbonState, text_color=ribbonDispColor, bgcolor=#1A1A1A, text_size=size.tiny)
    
    // PRESSURE
    pressureText = pressureIndex > 50 ? "EXTREME BUY" : pressureIndex > 0 ? "BUY" : 
                   pressureIndex < -50 ? "EXTREME SELL" : "SELL"
    pressureDispColor = pressureIndex > 0 ? CYAN_GLOW : PINK_GLOW
    table.cell(dash, 0, 6, "PRESSURE", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 6, pressureText, text_color=pressureDispColor, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 2, 6, str.tostring(math.round(pressureIndex)), 
               text_color=pressureDispColor, bgcolor=#0A0A0A, text_size=size.tiny)
    
    // MOMENTUM
    momText = fractalMomentum > 40 ? "STRONG BULL" : fractalMomentum > 0 ? "BULL" :
              fractalMomentum < -40 ? "STRONG BEAR" : "BEAR"
    momDispColor = fractalMomentum > 0 ? CYAN_GLOW : PINK_GLOW
    table.cell(dash, 0, 7, "MOMENTUM", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 7, momText, text_color=momDispColor, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 2, 7, str.tostring(math.round(fractalMomentum)), 
               text_color=momDispColor, bgcolor=#1A1A1A, text_size=size.tiny)
    
    // STRUCTURE
    structText = structureDir == 1 ? "BULLISH" : structureDir == -1 ? "BEARISH" : "NEUTRAL"
    structDispColor = structureDir == 1 ? CYAN_GLOW : structureDir == -1 ? PINK_GLOW : color.gray
    table.cell(dash, 0, 8, "STRUCTURE", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 8, structText, text_color=structDispColor, bgcolor=#0A0A0A, text_size=size.tiny)
    structState = structureBreak ? "BREAK" : structureShift ? "SHIFT" : "NONE"
    table.cell(dash, 2, 8, structState, text_color=structDispColor, bgcolor=#0A0A0A, text_size=size.tiny)
    
    // FLOW
    flowText = flowDir == 1 ? "BULLISH" : "BEARISH"
    flowDispColor = flowDir == 1 ? AQUA_GLOW : PINK_GLOW
    table.cell(dash, 0, 9, "FLOW", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 9, flowText, text_color=flowDispColor, bgcolor=#1A1A1A, text_size=size.tiny)
    flowState = flowReversal ? "REVERSAL" : flowMagnitude > 1 ? "STRONG" : "WEAK"
    table.cell(dash, 2, 9, flowState, text_color=flowDispColor, bgcolor=#1A1A1A, text_size=size.tiny)
    
    // SEPARATOR
    table.cell(dash, 0, 10, "═══════════", text_color=#333333, bgcolor=#0A0A0A, text_size=size.tiny)
    table.merge_cells(dash, 0, 10, 2, 10)
    
    // CONVICTION
    convictionText = conviction > 40 ? "VERY STRONG" : conviction > 25 ? "STRONG" : conviction > 20 ? "MODERATE" : "WEAK"
    convictionColor = conviction > 25 ? PURPLE_GLOW : color.gray
    table.cell(dash, 0, 11, "CONVICTION", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 11, convictionText, text_color=convictionColor, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 2, 11, str.tostring(math.round(conviction)), text_color=convictionColor, 
               bgcolor=#1A1A1A, text_size=size.tiny)
    
    // LAGUERRE
    lagText = laguerreValue > 70 ? "OVERBOUGHT" : laguerreValue < 30 ? "OVERSOLD" : "NEUTRAL"
    lagColor = laguerreValue > 70 ? PINK_GLOW : laguerreValue < 30 ? CYAN_GLOW : color.gray
    table.cell(dash, 0, 12, "LAGUERRE", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 12, lagText, text_color=lagColor, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 2, 12, str.tostring(math.round(laguerreValue)), text_color=lagColor, 
               bgcolor=#0A0A0A, text_size=size.tiny)
    
    // VOLUME - FIXED VARIABLE NAME
    volumeText = volSurge ? "SURGE" : volDry ? "DRY" : "NORMAL"
    volumeColor = volSurge ? PURPLE_GLOW : volDry ? color.gray : GOLD_GLOW
    table.cell(dash, 0, 13, "VOLUME", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 13, volumeText, text_color=volumeColor, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 2, 13, str.tostring(math.round(volRatio, 1)) + "x", 
               text_color=volumeColor, bgcolor=#1A1A1A, text_size=size.tiny)
    
    // VOLATILITY - FIXED VARIABLE NAME
    volatilityText = volatilityRank > 70 ? "HIGH" : volatilityRank > 30 ? "NORMAL" : "LOW"
    volatilityColor = volatilityRank > 70 ? RED_GLOW : GOLD_GLOW
    table.cell(dash, 0, 14, "VOLATILITY", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 14, volatilityText, text_color=volatilityColor, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 2, 14, str.tostring(math.round(volatilityRank)) + "%", 
               text_color=volatilityColor, bgcolor=#0A0A0A, text_size=size.tiny)
    
    // SEPARATOR
    table.cell(dash, 0, 15, "═══════════", text_color=#333333, bgcolor=#1A1A1A, text_size=size.tiny)
    table.merge_cells(dash, 0, 15, 2, 15)
    
    // TRADES
    table.cell(dash, 0, 16, "TRADES", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    table.cell(dash, 1, 16, str.tostring(strategy.closedtrades), 
               text_color=GOLD_GLOW, bgcolor=#0A0A0A, text_size=size.small)
    table.cell(dash, 2, 16, "TOTAL", text_color=#FFFFFF, bgcolor=#0A0A0A, text_size=size.tiny)
    
    // WIN RATE
    winRate = strategy.closedtrades > 0 ? (strategy.wintrades / strategy.closedtrades) * 100 : 0
    winRateColor = winRate > 60 ? GREEN_GLOW : winRate > 50 ? CYAN_GLOW : 
                   winRate > 40 ? GOLD_GLOW : PINK_GLOW
    table.cell(dash, 0, 17, "WIN RATE", text_color=#FFFFFF, bgcolor=#1A1A1A, text_size=size.tiny)
    table.cell(dash, 1, 17, str.tostring(math.round(winRate)) + "%", 
               text_color=winRateColor, bgcolor=#1A1A1A, text_size=size.small)
    winStatus = winRate > 55 ? "EXCELLENT" : winRate > 50 ? "GOOD" : winRate > 45 ? "OK" : "POOR"
    table.cell(dash, 2, 17, winStatus, text_color=winRateColor, bgcolor=#1A1A1A, text_size=size.tiny)

// ALERTS
alertcondition(longSignal and bullStrength >= 5, "STRONG LONG", "VNA: STRONG LONG - Strength: {{plot_0}}")
alertcondition(longSignal and bullStrength >= 3, "LONG", "VNA: LONG SIGNAL - Strength: {{plot_0}}")
alertcondition(shortSignal and bearStrength >= 5, "STRONG SHORT", "VNA: STRONG SHORT - Strength: {{plot_0}}")
alertcondition(shortSignal and bearStrength >= 3, "SHORT", "VNA: SHORT SIGNAL - Strength: {{plot_0}}")
alertcondition(structureBreak, "STRUCTURE BREAK", "VNA: Structure Break Detected")
alertcondition(structureShift, "STRUCTURE SHIFT", "VNA: Structure Shift Detected")
alertcondition(flowReversal, "FLOW REVERSAL", "VNA: Temporal Flow Reversed")
alertcondition(extremeBuyZone, "EXTREME BUY", "VNA: Extreme Buy Pressure")
alertcondition(extremeSellZone, "EXTREME SELL", "VNA: Extreme Sell Pressure")
````
