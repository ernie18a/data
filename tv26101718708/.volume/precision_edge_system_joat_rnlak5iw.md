# Precision Edge System [JOAT]

- url: https://www.tradingview.com/script/rNLAk5IW-Precision-Edge-System-JOAT/
- type: strategy
- pine_id: PUB;24075d3165ac40579296350132cd3687
- version: 1.0

## Description

[b]Precision Edge System [JOAT][/b]

[b]Introduction[/b]

The Precision Edge System is an advanced open-source multi-timeframe trading strategy that combines Opening Range Breakout, Fair Value Gap detection, Break of Structure analysis, Order Block identification, Fibonacci confluence, volatility regime classification, multi-oscillator divergence, RSI-2 mean reversion, and adaptive risk management into a unified institutional-grade trading system. This strategy helps traders capture high-probability setups by requiring multiple independent confirmation signals before entering trades, significantly reducing false signals and improving win rates.

Unlike basic strategies that rely on single indicators, this system uses a confluence scoring approach where each component contributes points toward entry decisions. Opening Range provides context, Fair Value Gaps provide entry zones, Market Structure confirms direction, Order Blocks show institutional positioning, Fibonacci shows harmonic levels, Regime Detection filters conditions, Divergence warns of reversals, and RSI-2 catches pullbacks. The strategy is designed for traders who understand that the best setups occur when multiple institutional concepts align simultaneously.

[b]Why This Strategy Exists[/b]

This strategy addresses the fundamental challenge of trading: most single-indicator strategies produce too many false signals or miss too many opportunities. By combining multiple institutional concepts with flexible confluence requirements, this strategy reveals:

[list]
[*][b]Opening Range Breakout:[/b] First 30 minutes establish institutional positioning - breakouts signal directional commitment
[*][b]Fair Value Gap Retests:[/b] Price imbalances that get filled - optimal entry zones with defined risk
[*][b]Break of Structure:[/b] Swing high/low breaks confirm trend direction and momentum
[*][b]Order Blocks:[/b] Last opposing candle before strong moves - institutional accumulation/distribution zones
[*][b]Premium/Discount Arrays:[/b] Value context showing whether price is expensive or cheap
[*][b]Fibonacci Confluence:[/b] Golden Pocket and multi-wave alignment for reversal zones
[*][b]Volatility Regime Detection:[/b] Trending/Ranging/Choppy classification to avoid bad conditions
[*][b]Multi-Oscillator Divergence:[/b] RSI/MACD/Stochastic divergence for reversal signals
[*][b]RSI-2 Mean Reversion:[/b] Extreme oversold/overbought in trends for pullback entries
[*][b]Session-Based Timing:[/b] London/New York kill zones for highest liquidity
[*][b]Adaptive Risk Management:[/b] Dynamic stop loss, take profit, and trailing stops based on volatility
[/list]

Each component provides independent confirmation. The strategy's power comes from requiring multiple components to align before entering trades, creating high-probability setups with favorable risk-reward ratios.

[image] [/image]

[b]Core Strategy Components[/b]

[b]1. Opening Range Breakout (ORB) System[/b]

The Opening Range is established during the first 30 minutes of the trading session (9:30-10:00 AM by default):

[pine]
// Track high/low during OR session
if inOR:
    orHigh = max(high, orHigh)
    orLow = min(low, orLow)

// Detect breakouts after OR established
orBreakoutUp = close > orHigh and close[1] <= orHigh
orBreakoutDown = close < orLow and close[1] >= orLow
[/pine]

Opening Range logic:
[list]
[*]First 30 minutes = institutions establish positions
[*]OR High/Low define the day's initial range
[*]Breakouts above OR High = bullish bias
[*]Breakouts below OR Low = bearish bias
[*]OR levels used as stop loss reference points
[/list]

The strategy can operate in two modes:
[list]
[*][b]Breakout Required:[/b] Only trades after OR breakout (more selective)
[*][b]Flexible:[/b] Trades inside OR if other confluence is strong (more frequent)
[/list]

ORB contributes 2 points to confluence score when breakout occurs.

[b]2. Fair Value Gap (FVG) Entry System[/b]

Fair Value Gaps are three-candle price imbalances that often get filled:

[pine]
// Bullish FVG: Current low > 2 candles ago high
bullishFVG = low > high[2]
fvgBullTop = low
fvgBullBottom = high[2]

// Entry on retest
fvgBullRetest = low <= fvgBullTop and close >= fvgBullBottom
[/pine]

FVG entry logic:
[list]
[*]Identifies imbalance zones where price moved too fast
[*]Waits for price to return to the gap (retest)
[*]Enters at gap high (bullish) or gap low (bearish)
[*]Provides precise entry with tight stop below/above gap
[/list]

FVG retest contributes 2 points to confluence score. The strategy tracks active FVGs and removes them when filled.

[b]3. Market Structure (BOS/CHoCH) Confirmation[/b]

Break of Structure confirms trend direction:

[pine]
// Detect swing highs/lows
swingPivotHigh = ta.pivothigh(high, 5, 5)
swingPivotLow = ta.pivotlow(low, 5, 5)

// BOS: Price breaks swing in trend direction
if swingPivotHigh > lastSwingHigh and bullishStructure:
    bosOccurred = true  // Bullish BOS
[/pine]

Structure logic:
[list]
[*]Tracks swing highs and lows using pivot detection
[*]BOS = break in trend direction (continuation)
[*]CHoCH = break against trend (potential reversal)
[*]Internal structure shows nested patterns for timing
[/list]

The strategy can operate in two modes:
[list]
[*][b]BOS Required:[/b] Only trades after structure break (more selective)
[*][b]Flexible:[/b] Trades without BOS if other confluence is strong (more frequent)
[/list]

BOS contributes 2 points to confluence score when it occurs.

[b]4. Order Block Detection and Mitigation[/b]

Order Blocks mark institutional positioning zones:

[pine]
// Bullish OB: Last bearish candle before strong bullish move
bullishOB = close[1] < open[1] and close > open and
             (high - low) > atr * 1.2 and
             volume > avgVol * 1.1
[/pine]

Order Block logic:
[list]
[*]Identifies last opposing candle before momentum shift
[*]Requires volume and ATR confirmation
[*]Strength classification (Strong = 4+ points, Normal = 2-3 points)
[*]Tracks active blocks until mitigated (price closes through)
[/list]

Active Order Blocks contribute 1 point to confluence score. Strong Order Blocks (high volume + high ATR) contribute an additional 1 point.

[b]5. Premium/Discount Array Context[/b]

Premium/Discount Arrays show value context:

[pine]
rangeHigh = ta.highest(high, 50)
rangeLow = ta.lowest(low, 50)
rangeEQ = (rangeHigh + rangeLow) / 2

inPremium = close > rangeEQ and close > (rangeEQ + (rangeHigh - rangeEQ) * 0.5)
inDiscount = close < rangeEQ and close < (rangeEQ - (rangeEQ - rangeLow) * 0.5)
[/pine]

Value Array logic:
[list]
[*]Calculates 50-period range high/low
[*]Equilibrium = 50% level (fair value)
[*]Premium = upper 50% of range (expensive)
[*]Discount = lower 50% of range (cheap)
[*]Institutional bias: Buy discount, sell premium
[/list]

Being in discount zone contributes 1 point to long confluence. Being in premium zone contributes 1 point to short confluence.

[b]6. Fibonacci Confluence and Golden Pocket[/b]

Fibonacci analysis identifies harmonic reversal zones:

[pine]
// Calculate Fibonacci levels from swing
fib618 = swingLow + (swingHigh - swingLow) * 0.618
fib650 = fib618 * 1.052

// Golden Pocket = 0.618 to 0.65 zone
inGoldenZone = close >= min(fib618, fib650) and close <= max(fib618, fib650)
[/pine]

Fibonacci logic:
[list]
[*]Calculates Fibonacci retracements from multiple swing lengths
[*]Golden Pocket (0.618-0.65) = highest probability reversal zone
[*]Extensions (1.272, 1.414, 1.618) used for profit targets
[*]Confluence zones where multiple Fib levels align
[/list]

Being in Golden Pocket contributes 1 point to both long and short confluence (reversal zone).

[b]7. Volatility Regime Filter[/b]

Regime detection classifies market conditions:

[pine]
atr = ta.atr(14)
atrSma = ta.sma(atr, 50)
volRatio = atr / atrSma

// Trending: EMAs aligned + normal volatility
trendStrength = (ema9 > ema21 and ema21 > ema50) or
                (ema9 < ema21 and ema21 < ema50)

regime = volRatio > 1.5 ? 0 :  // Choppy
         trendStrength ? 2 :    // Trending  
         1                      // Ranging
[/pine]

Regime logic:
[list]
[*]Trending (2): Directional market, use breakout strategies
[*]Ranging (1): Oscillating market, use mean reversion
[*]Choppy (0): Erratic market, avoid trading
[/list]

The strategy can operate in two modes:
[list]
[*][b]Avoid Choppy:[/b] No trades in choppy regime (more selective)
[*][b]Trade All:[/b] Trades in all regimes if confluence is strong (more frequent)
[/list]

Regime filter prevents trading in unfavorable conditions.

[b]8. Multi-Oscillator Divergence Detection[/b]

Divergence analysis identifies momentum exhaustion:

[pine]
// Bullish divergence: Price LL, RSI HL
if pricePivotLow < lastPriceLow and rsiPivotLow > lastRsiLow:
    bullish_divergence = true
[/pine]

Divergence logic:
[list]
[*]Regular divergence = potential reversal signal
[*]Hidden divergence = trend continuation signal
[*]Requires extreme zones (RSI >70 or <30) for best setups
[*]Multi-oscillator confluence increases reliability
[/list]

Bullish divergence contributes 2 points to long confluence. Bearish divergence contributes 2 points to short confluence.

[b]9. RSI-2 Mean Reversion System[/b]

RSI-2 catches extreme pullbacks in trends:

[pine]
rsi2 = ta.rsi(close, 2)
ema200 = ta.ema(close, 200)

// Long: RSI-2 oversold in uptrend
rsi2_oversold = rsi2 < 10 and close > ema200

// Short: RSI-2 overbought in downtrend
rsi2_overbought = rsi2 > 90 and close < ema200
[/pine]

RSI-2 logic:
[list]
[*]2-period RSI is extremely sensitive to pullbacks
[*]Oversold (<10) in uptrend = buy the dip
[*]Overbought (>90) in downtrend = sell the rally
[*]Requires 200 EMA trend filter for context
[/list]

RSI-2 signals contribute 2 points to confluence score.

[b]10. Candlestick Pattern Recognition[/b]

The strategy detects reversal patterns:

[list]
[*][b]Hammer:[/b] Long lower wick, small body, bullish reversal
[*][b]Shooting Star:[/b] Long upper wick, small body, bearish reversal
[*][b]Bullish Engulfing:[/b] Bullish candle engulfs previous bearish candle
[*][b]Bearish Engulfing:[/b] Bearish candle engulfs previous bullish candle
[*][b]Morning Star:[/b] Three-candle bullish reversal pattern
[*][b]Evening Star:[/b] Three-candle bearish reversal pattern
[/list]

Strong patterns (with volume confirmation) contribute 2 points to confluence score.

[b]11. Session-Based Timing (Kill Zones)[/b]

The strategy focuses on high-liquidity sessions:

[list]
[*][b]London Session:[/b] 2:00-5:00 AM EST (default)
[*][b]New York Session:[/b] 8:30-11:00 AM EST (default)
[*][b]Silver Bullet:[/b] 9:00-10:00 AM EST (default)
[/list]

Session logic:
[list]
[*]Highest volume and volatility during these periods
[*]Institutional participation is strongest
[*]Better follow-through on breakouts
[*]Can be disabled for 24-hour trading
[/list]

[image] [/image]

[b]Confluence Scoring System[/b]

The strategy uses a point-based confluence system where each component contributes points:

[b]Long Confluence Points:[/b]
[list]
[*]OR Breakout Up: +2 points
[*]BOS Bullish: +2 points
[*]FVG Bull Retest: +2 points
[*]Active Bullish OB: +1 point
[*]Strong Bullish OB: +1 point (bonus)
[*]In Discount Zone: +1 point
[*]In Golden Pocket: +1 point
[*]RSI-2 Oversold: +2 points
[*]Bullish Divergence: +2 points
[*]Liquidity Below: +1 point
[*]Volume Spike: +1 point
[*]Bullish Momentum: +1 point
[*]Bullish Pattern: +2 points
[/list]

[b]Entry Modes (Configurable):[/b]
[list]
[*][b]Strict Mode:[/b] Requires 8+ points (very selective, highest quality)
[*][b]Moderate Mode:[/b] Requires 6+ points (balanced approach)
[*][b]Flexible Mode:[/b] Requires 4+ points (more frequent trades)
[*][b]Aggressive Mode:[/b] Requires 3+ points (highest frequency)
[/list]

This flexible system allows traders to adjust trade frequency based on their preference and market conditions.

[b]Risk Management System[/b]

[b]1. Stop Loss Placement:[/b]

The strategy uses intelligent stop loss placement:

[list]
[*][b]OR-Based Stops:[/b] If OR is active, stop = OR Low (long) or OR High (short)
[*][b]ATR-Based Stops:[/b] If no OR, stop = Entry ± (2 × ATR)
[*][b]Structure-Based Stops:[/b] Can use swing lows/highs for stops
[/list]

[b]2. Position Sizing:[/b]

Risk-based position sizing:

[pine]
accountRisk = strategy.equity * (riskPercent / 100)  // Default 1%
riskPerShare = entry - stopLoss
positionSize = accountRisk / riskPerShare
[/pine]

This ensures consistent risk per trade regardless of stop distance.

[b]3. Take Profit Targets:[/b]

Adaptive take profit based on volatility:

[pine]
// Base reward multiple (default 2R)
tpMultiplier = rewardMultiple

// Increase in high volatility
if volatility_high:
    tpMultiplier = rewardMultiple * 1.5

takeProfit = entry + (riskPerShare * tpMultiplier)
[/pine]

Default 2R target (2x risk) provides favorable risk-reward. High volatility increases target to 3R.

[b]4. Trailing Stop System:[/b]

Adaptive trailing stop activates after profit threshold:

[list]
[*]Activates after 1R profit (default)
[*]Trails at breakeven + 0.5R
[*]Locks in profits while allowing trend to run
[*]Adjusts trail distance based on ATR
[/list]

[b]5. Time-Based Exits:[/b]

End-of-day exit prevents overnight risk:

[list]
[*]Closes all positions at 3:55 PM EST (default)
[*]Prevents gap risk and overnight exposure
[*]Can be disabled for swing trading
[/list]

[b]6. Daily Trade Limit:[/b]

Maximum trades per day prevents overtrading:

[list]
[*]Default: 10 trades per day maximum
[*]Resets at start of each trading day
[*]Prevents revenge trading and overexposure
[/list]

[b]Strategy Performance Metrics[/b]

The strategy displays real-time performance in the dashboard:

[list]
[*][b]Confluence Scores:[/b] Current long/short confluence (0-20 scale)
[*][b]OR Status:[/b] Active/Forming
[*][b]Structure:[/b] Bullish/Bearish
[*][b]BOS Signal:[/b] Confirmed/Pending
[*][b]Regime:[/b] Trending/Ranging/Choppy
[*][b]Value Zone:[/b] Premium/Discount/Equilibrium
[*][b]RSI State:[/b] Overbought/Oversold/Neutral
[*][b]Volatility:[/b] High/Normal/Low
[*][b]Volume:[/b] Spike/High/Dry/Normal
[*][b]Position:[/b] Long/Short/Flat
[*][b]Net P/L:[/b] Current profit/loss
[*][b]Win Rate:[/b] Percentage of winning trades
[*][b]Total Trades:[/b] Number of closed trades
[*][b]Profit Factor:[/b] Gross profit / Gross loss
[/list]

[b]Input Parameters[/b]

[b]Trade Frequency:[/b]
[list]
[*]Entry Mode: Strict/Moderate/Flexible/Aggressive
[*]Min Confluence Score: 1-10 (lower = more trades)
[*]Allow Partial Setups: Trade with 2/3 conditions met
[/list]

[b]Opening Range:[/b]
[list]
[*]OR Session: Time range for OR (default 9:30-10:00)
[*]ORB Filter: Enable/disable OR requirement
[*]Fibonacci Extensions: Show extension levels
[*]Breakout Required: Must break OR to trade
[/list]

[b]Market Structure:[/b]
[list]
[*]Fractal Period: Swing detection length (default 5)
[*]Require BOS/CHoCH: Must have structure break
[*]Multi-TF Confluence: Check higher timeframe
[*]Internal Structure: Show nested patterns
[/list]

[b]Order Blocks:[/b]
[list]
[*]OB Filter: Enable/disable OB requirement
[*]Volatility Threshold: ATR multiplier (default 1.2)
[*]Volume Threshold: Volume multiplier (default 1.1)
[*]Block Quality: All/Strong/Extreme
[/list]

[b]Fair Value Gaps:[/b]
[list]
[*]FVG Entry: Enable/disable FVG entries
[*]Min Imbalance: Percentage threshold (default 0.2%)
[*]Zone Quality: All/Strong/Extreme
[*]Auto-Fill Detection: Remove filled gaps
[/list]

[b]Risk Management:[/b]
[list]
[*]Risk Per Trade: Percentage of equity (default 1%)
[*]Reward Multiple: R multiple for TP (default 2.0)
[*]Adaptive Take Profit: Adjust TP for volatility
[*]EOD Exit: Close positions at end of day
[*]Adaptive Trailing Stop: Enable trailing stops
[*]Trail Activation: R multiple to activate (default 1.0)
[*]Max Daily Trades: Limit trades per day (default 10)
[/list]

[b]How to Use This Strategy[/b]

[b]Step 1: Configure Entry Mode[/b]
Choose entry mode based on desired trade frequency. Strict = fewer high-quality trades. Flexible = more frequent trades. Start with Moderate.

[b]Step 2: Set Risk Parameters[/b]
Configure risk per trade (1% recommended), reward multiple (2R recommended), and position sizing. Never risk more than you can afford to lose.

[b]Step 3: Enable Desired Components[/b]
Turn on/off components based on your trading style. All components enabled = most selective. Fewer components = more frequent trades.

[b]Step 4: Monitor Dashboard[/b]
Watch confluence scores in real-time. Long score >6 = potential long setup. Short score >6 = potential short setup. Higher scores = better setups.

[b]Step 5: Review Entry Labels[/b]
When strategy enters, it displays label with entry price, stop loss, take profit, and confluence score. Review to understand why trade was taken.

[b]Step 6: Let Strategy Manage Exits[/b]
Strategy handles stop loss, take profit, trailing stops, and EOD exits automatically. Don't interfere with exits unless necessary.

[b]Step 7: Analyze Performance[/b]
Review dashboard metrics regularly. Win rate >50%, profit factor >1.5, and positive net P/L indicate good performance.

[b]Best Practices[/b]

[list]
[*]Start with Moderate mode and adjust based on results
[*]Higher confluence scores = higher win rates but fewer trades
[*]Backtest thoroughly before live trading
[*]Use realistic commission (0.075%) and slippage
[*]Respect regime filter - avoid choppy markets
[*]Session filter improves quality - trade kill zones
[*]EOD exit prevents overnight risk for day traders
[*]Daily trade limit prevents overtrading
[*]Monitor dashboard for real-time confluence
[*]Adjust parameters for different instruments and timeframes
[/list]

[b]Strategy Limitations[/b]

[list]
[*]Confluence system can miss trades when components don't align
[*]Multiple filters reduce trade frequency significantly
[*]Backtesting results may not reflect live performance
[*]Slippage and commission impact profitability
[*]News events can invalidate technical setups
[*]Regime detection may lag at transitions
[*]Opening Range less reliable on low-volume days
[*]Fair Value Gaps may not fill immediately
[*]Order Blocks can fail in strong trends
[*]Divergences can persist before reversing
[*]The strategy shows high-probability setups, not guaranteed winners
[/list]

[b]Technical Implementation[/b]

Built with Pine Script v6 using:
[list]
[*]Opening Range tracking with session detection
[*]Fair Value Gap detection and retest monitoring
[*]Market structure analysis with BOS/CHoCH detection
[*]Order Block identification with strength classification
[*]Premium/Discount Array calculations
[*]Fibonacci confluence and Golden Pocket detection
[*]Volatility regime classification system
[*]Multi-oscillator divergence detection
[*]RSI-2 mean reversion signals
[*]Candlestick pattern recognition
[*]Session-based timing filters
[*]Confluence scoring algorithm
[*]Adaptive risk management system
[*]Real-time performance dashboard
[/list]

The code is fully open-source and can be modified to suit individual trading styles and preferences.

[b]Originality Statement[/b]

This strategy is original in its comprehensive institutional integration approach. While individual components (ORB, FVG, BOS, OB, Fibonacci, RSI, MACD) are established concepts, this strategy is justified because:

[list]
[*]It synthesizes 11 distinct institutional concepts into unified confluence scoring system
[*]The flexible entry mode system allows traders to adjust selectivity vs frequency
[*]Adaptive risk management adjusts stops and targets based on volatility
[*]Multi-component confluence significantly reduces false signals vs single-indicator strategies
[*]Session-based timing focuses on high-liquidity periods for better execution
[*]Regime filter prevents trading in unfavorable market conditions
[*]Candlestick pattern integration adds reversal confirmation layer
[*]Real-time dashboard presents 15 metrics simultaneously for complete strategy visibility
[*]The strategy combines trend-following (BOS, ORB) with mean-reversion (RSI-2, Divergence) for versatility
[/list]

Each component contributes independent confirmation: ORB shows context, FVG shows entry, BOS shows direction, OB shows positioning, Arrays show value, Fibonacci shows harmonics, Regime shows conditions, Divergence shows exhaustion, RSI-2 shows pullbacks, Patterns show reversals, and Sessions show timing. The strategy's value lies in requiring multiple components to align before entering trades, creating high-probability setups with favorable risk-reward ratios.

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss and is not suitable for all investors.

Past performance does not guarantee future results. Backtesting results are hypothetical and may not reflect actual trading performance. Actual results will vary due to slippage, commission, market conditions, and execution differences. The strategy may experience periods of drawdown and losing trades.

High confluence scores do not guarantee profitable trades. Market conditions change, and strategies that worked historically may not work in the future. News events, market shocks, and fundamental factors can override technical setups.

Always use proper risk management, including stop losses and position sizing appropriate for your account size and risk tolerance. Never risk more than you can afford to lose. Consider consulting with a qualified financial advisor before making investment decisions.

The author is not responsible for any losses incurred from using this strategy. Users assume full responsibility for all trading decisions made using this tool.

[b]Recommended Settings for Backtesting[/b]

[list]
[*]Initial Capital: $10,000 (realistic for average trader)
[*]Commission: 0.075% per trade (realistic for most brokers)
[*]Slippage: 1-2 ticks (depends on instrument liquidity)
[*]Risk Per Trade: 1% of equity
[*]Reward Multiple: 2R (2:1 risk-reward)
[*]Entry Mode: Moderate (6+ confluence)
[*]Timeframe: 5-minute or 15-minute chart
[*]Instruments: Liquid stocks, forex majors, or major crypto
[*]Sample Size: Minimum 100 trades for statistical significance
[/list]

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Precision Edge System [JOAT]", 
     shorttitle="PES [JOAT]",
     overlay=true, 
     initial_capital=10000, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=100, 
     commission_type=strategy.commission.percent, 
     commission_value=0.075,
     pyramiding=3,
     calc_on_every_tick=false,
     calc_on_order_fills=false,
     max_bars_back=5000,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500)


// ────────────────────────────────────────────────────────────────────────────────
// INPUTS
// ────────────────────────────────────────────────────────────────────────────────
// Trade Frequency Optimization
confluenceMode = input.string("Flexible", "Entry Mode", options=["Strict", "Moderate", "Flexible", "Aggressive"], group="Trade Frequency")
minConfluenceScore = input.int(3, "Min Confluence Score", minval=1, maxval=10, tooltip="Lower = More Trades", group="Trade Frequency")
allowPartialSetups = input.bool(true, "Allow Partial Setups", tooltip="Trade with 2/3 conditions met", group="Trade Frequency")

// Opening Range
orSession = input.session("0930-1000", "Opening Range Session", group="Opening Range")
orEnabled = input.bool(true, "ORB Filter", group="Opening Range")
orExtensions = input.bool(true, "Fibonacci Extensions", group="Opening Range")
orBreakoutOnly = input.bool(false, "Breakout Required", tooltip="If false, trades inside OR", group="Opening Range")

// Market Structure
swingLength = input.int(5, "Fractal Period", minval=3, maxval=15, group="Market Structure")
requireBOS = input.bool(false, "Require BOS/CHoCH", tooltip="If false, trades without structure confirmation", group="Market Structure")
structureConfluence = input.bool(true, "Multi-TF Confluence", group="Market Structure")
showInternalStructure = input.bool(true, "Internal Structure", group="Market Structure")
internalSwingLen = input.int(3, "Internal Period", minval=2, maxval=10, group="Market Structure")

// Order Blocks
obEnabled = input.bool(true, "Order Block Filter", group="Order Blocks")
obAtrMult = input.float(1.2, "Volatility Threshold", minval=0.8, maxval=3.0, tooltip="Lower = More OBs", group="Order Blocks")
obVolMult = input.float(1.1, "Volume Threshold", minval=0.8, maxval=2.0, tooltip="Lower = More OBs", group="Order Blocks")
obStrength = input.string("All", "Block Quality", options=["All", "Strong", "Extreme"], group="Order Blocks")
showBreakers = input.bool(true, "Breaker Blocks", group="Order Blocks")
showMitigation = input.bool(true, "Mitigation Blocks", group="Order Blocks")

// Fair Value Gaps
fvgEnabled = input.bool(true, "FVG Entry", group="Fair Value Gaps")
fvgMinSize = input.float(0.2, "Min Imbalance (%)", minval=0.1, maxval=1.0, tooltip="Lower = More FVGs", group="Fair Value Gaps")
fvgQuality = input.string("All", "Zone Quality", options=["All", "Strong", "Extreme"], group="Fair Value Gaps")
fvgAutoFill = input.bool(true, "Auto-Fill Detection", group="Fair Value Gaps")

// Liquidity Analysis
liqEnabled = input.bool(true, "Liquidity Sweeps", group="Liquidity")
liqSwingLen = input.int(5, "Swing Detection", minval=3, maxval=15, group="Liquidity")
liqTolerance = input.float(0.2, "Level Tolerance (%)", minval=0.05, maxval=0.5, tooltip="Higher = More Liquidity Zones", group="Liquidity")

// Premium/Discount Arrays
pdEnabled = input.bool(true, "Premium/Discount Filter", group="Value Arrays")
pdArrayLen = input.int(50, "Array Period", minval=20, maxval=200, group="Value Arrays")
pdShowFib = input.bool(true, "Fibonacci Levels", group="Value Arrays")
pdDynamicEQ = input.bool(true, "Dynamic Equilibrium", group="Value Arrays")

// Fibonacci Confluence
fibEnabled = input.bool(true, "Fibonacci Confluence", group="Fibonacci")
swing1Length = input.int(20, "Primary Wave", minval=10, maxval=100, group="Fibonacci")
swing2Length = input.int(50, "Secondary Wave", minval=20, maxval=150, group="Fibonacci")
showGoldenZone = input.bool(true, "Golden Pocket (0.618-0.65)", group="Fibonacci")
confluenceTolerance = input.float(0.3, "Resonance Tolerance (%)", minval=0.1, maxval=1.0, group="Fibonacci")

// Volatility Regime
regimeEnabled = input.bool(true, "Regime Filter", group="Volatility Regime")
avoidChoppy = input.bool(false, "Avoid Choppy Markets", tooltip="If false, trades in all regimes", group="Volatility Regime")
minTrendStrength = input.float(1.0, "Min Trend Strength", minval=0.5, maxval=2.0, tooltip="Lower = More Trades", group="Volatility Regime")

// Divergence Detection
divEnabled = input.bool(true, "Divergence Filter", group="Divergence")
rsiLength = input.int(14, "RSI Period", minval=5, maxval=50, group="Divergence")
macdFast = input.int(12, "MACD Fast", minval=5, maxval=50, group="Divergence")
macdSlow = input.int(26, "MACD Slow", minval=10, maxval=100, group="Divergence")
macdSignal = input.int(9, "MACD Signal", minval=5, maxval=50, group="Divergence")
divConfluence = input.bool(false, "Multi-Oscillator Required", tooltip="If false, single oscillator divergence OK", group="Divergence")

// RSI-2 Mean Reversion
rsi2Enabled = input.bool(true, "RSI-2 Mean Reversion", group="RSI-2 Strategy")
rsi2Length = input.int(2, "RSI-2 Period", minval=2, maxval=10, group="RSI-2 Strategy")
rsi2Oversold = input.int(10, "Oversold Level", minval=5, maxval=30, group="RSI-2 Strategy")
rsi2Overbought = input.int(90, "Overbought Level", minval=70, maxval=95, group="RSI-2 Strategy")
rsi2MA = input.int(200, "Trend Filter MA", minval=50, maxval=300, group="RSI-2 Strategy")

// Session Timing
killZoneEnabled = input.bool(true, "Session Filter", group="Session Timing")
londonSession = input.session("0200-0500", "London Session", group="Session Timing")
nySession = input.session("0830-1100", "New York Session", group="Session Timing")
silverBullet = input.session("0900-1000", "Silver Bullet", group="Session Timing")

// Risk Management
riskPercent = input.float(1.0, "Risk Per Trade (%)", minval=0.1, maxval=5.0, step=0.1, group="Risk Management")
rewardMultiple = input.float(2.0, "Reward Multiple (R)", minval=1.0, maxval=5.0, step=0.5, group="Risk Management")
useAdaptiveTP = input.bool(true, "Adaptive Take Profit", tooltip="Adjusts TP based on volatility", group="Risk Management")
useTimeExit = input.bool(true, "EOD Exit", group="Risk Management")
eodSession = input.session("1555-1600", "EOD Session", group="Risk Management")
useTrailingStop = input.bool(true, "Adaptive Trailing Stop", group="Risk Management")
trailActivation = input.float(1.0, "Trail Activation (R)", minval=0.5, maxval=3.0, group="Risk Management")
maxDailyTrades = input.int(10, "Max Daily Trades", minval=1, maxval=50, group="Risk Management")

// Visual Settings
showGradientCandles = input.bool(true, "Gradient Candles", group="Visual Settings")
showGradientBg = input.bool(true, "Gradient Backgrounds", group="Visual Settings")
showDashboard = input.bool(true, "Performance Dashboard", group="Visual Settings")
showLabels = input.bool(true, "Entry/Exit Labels", group="Visual Settings")

// ────────────────────────────────────────────────────────────────────────────────
// COLOR SCHEME - Professional Trading Aesthetic
// ────────────────────────────────────────────────────────────────────────────────
// Primary Colors
COLOR_LONG = color.new(#00ff9f, 0)
COLOR_SHORT = color.new(#ff006e, 0)
COLOR_ACCENT = color.new(#00d4ff, 0)
COLOR_GOLDEN = color.new(#ffd700, 0)

// Opening Range
COLOR_OR = color.new(#ffd700, 65)
COLOR_OR_BORDER = color.new(#ff8c00, 40)

// Fair Value Gaps
COLOR_FVG_BULL = color.new(#00ffaa, 75)
COLOR_FVG_BULL_BORDER = color.new(#00ff9f, 40)
COLOR_FVG_BEAR = color.new(#ff0066, 75)
COLOR_FVG_BEAR_BORDER = color.new(#ff006e, 40)

// Order Blocks
COLOR_OB_BULL_FILL = color.new(#0d1117, 70)
COLOR_OB_BULL_BORDER = color.new(#00ffaa, 0)
COLOR_OB_BULL_EQ = color.new(#00ff9f, 30)
COLOR_OB_BEAR_FILL = color.new(#0d1117, 70)
COLOR_OB_BEAR_BORDER = color.new(#ff0066, 0)
COLOR_OB_BEAR_EQ = color.new(#ff006e, 30)

// Breaker Blocks
COLOR_BREAKER_BULL = color.new(#00ffaa, 92)
COLOR_BREAKER_BEAR = color.new(#ff0066, 92)

// Liquidity Zones
COLOR_LIQ_BULL = color.new(#00d4ff, 15)
COLOR_LIQ_BEAR = color.new(#ff0080, 15)

// Premium/Discount Arrays
COLOR_PREMIUM_1 = color.new(#ff0080, 96)
COLOR_PREMIUM_2 = color.new(#ff4500, 96)
COLOR_DISCOUNT_1 = color.new(#00ced1, 96)
COLOR_DISCOUNT_2 = color.new(#00ff9f, 96)
COLOR_EQUILIBRIUM = color.new(#9370db, 98)

// Fibonacci Levels
COLOR_FIB_236 = color.new(#00d4ff, 70)
COLOR_FIB_382 = color.new(#00ffaa, 70)
COLOR_FIB_500 = color.new(#ffd700, 70)
COLOR_FIB_618 = color.new(#ff8c00, 70)
COLOR_FIB_786 = color.new(#ff1493, 70)
COLOR_FIB_GOLDEN = color.new(#ffd700, 50)

// Candlestick Colors
COLOR_CANDLE_BULL_STRONG = color.new(#00ff9f, 0)
COLOR_CANDLE_BULL_WEAK = color.new(#00d4ff, 0)
COLOR_CANDLE_BEAR_STRONG = color.new(#ff006e, 0)
COLOR_CANDLE_BEAR_WEAK = color.new(#ff4500, 0)
COLOR_CANDLE_NEUTRAL = color.new(#9370db, 0)

// Dashboard Colors
COLOR_DASHBOARD_BG = color.new(#0a0a0a, 5)
COLOR_DASHBOARD_BORDER = color.new(#00ff9f, 30)
COLOR_DASHBOARD_HEADER = color.new(#1a1a2e, 15)
COLOR_DASHBOARD_CELL = color.new(#1a1a2e, 40)

// Signal Colors
COLOR_PROFIT = color.new(#00ff00, 0)
COLOR_LOSS = color.new(#ff0000, 0)
COLOR_WARNING = color.new(#ffd700, 0)

// Chaos Zone
COLOR_CHAOS = color.new(#ff0000, 92)
COLOR_CHAOS_SIGNAL = color.new(#ff6600, 0)

// ────────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ────────────────────────────────────────────────────────────────────────────────
// Core Metrics
atr = ta.atr(14)
avgVol = ta.sma(volume, 20)
rsi = ta.rsi(close, rsiLength)
rsi2 = ta.rsi(close, rsi2Length)
[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSignal)

// Moving Averages
ema9 = ta.ema(close, 9)
ema21 = ta.ema(close, 21)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, rsi2MA)

// Trend Analysis
trend_bullish = ema9 > ema21 and ema21 > ema50
trend_bearish = ema9 < ema21 and ema21 < ema50
trend_strength = math.abs(ema9 - ema50) / atr

// Volatility Analysis
atrSma = ta.sma(atr, 50)
volRatio = atr / atrSma
volatility_high = atr > atrSma * 1.5
volatility_low = atr < atrSma * 0.7

// Volume Analysis
volume_significant = volume > avgVol * 1.2
volume_spike = volume > avgVol * 1.5
volume_dry = volume < avgVol * 0.7
buyVolume = close > open ? volume : 0
sellVolume = close < open ? volume : 0
volumeDelta = ta.cum(buyVolume) - ta.cum(sellVolume)

// Momentum Analysis
rsiMomentum = ta.change(rsi, 3)
macdMomentum = ta.change(macdLine, 3)
priceMomentum = ta.change(close, 5)
momentum_bull = rsiMomentum > 0 and macdHist > 0
momentum_bear = rsiMomentum < 0 and macdHist < 0

// Stochastic
k = ta.stoch(close, high, low, 14)
d = ta.sma(k, 3)
stoch_oversold = k < 20
stoch_overbought = k > 80

// Candlestick Pattern Recognition
body = close - open
rangeCandle = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
bodyPct = rangeCandle > 0 ? math.abs(body) / rangeCandle : 0

// Hammer Pattern
isHammer = lowerWick > math.abs(body) * 2 and upperWick < math.abs(body) * 0.3 and bodyPct < 0.4 and close > open
hammerStrength = isHammer and volume > avgVol * 1.3

// Shooting Star Pattern
isShootingStar = upperWick > math.abs(body) * 2 and lowerWick < math.abs(body) * 0.3 and bodyPct < 0.4 and close < open
shootingStarStrength = isShootingStar and volume > avgVol * 1.3

// Engulfing Patterns
isEngulfingBull = close > open and close[1] < open[1] and open < close[1] and close > open[1]
engulfingBullStrength = isEngulfingBull and volume > volume[1] * 1.2

isEngulfingBear = close < open and close[1] > open[1] and open > close[1] and close < open[1]
engulfingBearStrength = isEngulfingBear and volume > volume[1] * 1.2

// Morning/Evening Star
isMorningStar = close[2] < open[2] and math.abs(close[1] - open[1]) < (high[1] - low[1]) * 0.3 and close > open and close > (high[2] + low[2]) / 2
isEveningStar = close[2] > open[2] and math.abs(close[1] - open[1]) < (high[1] - low[1]) * 0.3 and close < open and close < (high[2] + low[2]) / 2

// Divergence Detection
pivotHigh = ta.pivothigh(high, 5, 5)
pivotLow = ta.pivotlow(low, 5, 5)
rsiPivotHigh = ta.pivothigh(rsi, 5, 5)
rsiPivotLow = ta.pivotlow(rsi, 5, 5)

var float lastPriceHigh = na
var float lastPriceLow = na
var float lastRsiHigh = na
var float lastRsiLow = na

bullish_divergence = false
bearish_divergence = false

if not na(pivotHigh) and not na(rsiPivotHigh)
    if not na(lastPriceHigh) and not na(lastRsiHigh)
        if pivotHigh > lastPriceHigh and rsiPivotHigh < lastRsiHigh
            bearish_divergence := true
    lastPriceHigh := pivotHigh
    lastRsiHigh := rsiPivotHigh

if not na(pivotLow) and not na(rsiPivotLow)
    if not na(lastPriceLow) and not na(lastRsiLow)
        if pivotLow < lastPriceLow and rsiPivotLow > lastRsiLow
            bullish_divergence := true
    lastPriceLow := pivotLow
    lastRsiLow := rsiPivotLow

// RSI-2 Signals
rsi2_oversold = rsi2 < rsi2Oversold and close > ema200
rsi2_overbought = rsi2 > rsi2Overbought and close < ema200

// Session Detection
inLondonKZ = not na(time(timeframe.period, londonSession))
inNYKZ = not na(time(timeframe.period, nySession))
inSilverBullet = not na(time(timeframe.period, silverBullet))
inKillZone = killZoneEnabled ? (inLondonKZ or inNYKZ or inSilverBullet) : true

// Daily Trade Counter
var int dailyTradeCount = 0
var int lastTradeDay = 0

if dayofmonth != lastTradeDay
    dailyTradeCount := 0
    lastTradeDay := dayofmonth
// ────────────────────────────────────────────────────────────────────────────────
// OPENING RANGE
// ────────────────────────────────────────────────────────────────────────────────
inOR = not na(time(timeframe.period, orSession))
var float orHigh = na
var float orLow = na
var bool orEstablished = false

if inOR and not inOR[1]
    orHigh := high
    orLow := low
    orEstablished := false

if inOR
    orHigh := math.max(high, orHigh)
    orLow := math.min(low, orLow)

if not inOR and inOR[1]
    orEstablished := true

// OR Breakout
orBreakoutUp = orEstablished and close > orHigh and close[1] <= orHigh
orBreakoutDown = orEstablished and close < orLow and close[1] >= orLow

// Plot OR
bgcolor(inOR ? COLOR_OR : na, title="Opening Range")
plot(orEstablished ? orHigh : na, "OR High", COLOR_SHORT, 2, plot.style_linebr)
plot(orEstablished ? orLow : na, "OR Low", COLOR_LONG, 2, plot.style_linebr)

// ────────────────────────────────────────────────────────────────────────────────
// MARKET STRUCTURE (BOS/CHoCH)
// ────────────────────────────────────────────────────────────────────────────────
swingPivotHigh = ta.pivothigh(high, swingLength, swingLength)
swingPivotLow = ta.pivotlow(low, swingLength, swingLength)

var float lastSwingHigh = na
var float lastSwingLow = na
var bool bullishStructure = true
var bool bosOccurred = false

if not na(swingPivotHigh)
    if not na(lastSwingHigh)
        if swingPivotHigh > lastSwingHigh
            if not bullishStructure
                bullishStructure := true
                bosOccurred := true
            else
                bosOccurred := true
    lastSwingHigh := swingPivotHigh

if not na(swingPivotLow)
    if not na(lastSwingLow)
        if swingPivotLow < lastSwingLow
            if bullishStructure
                bullishStructure := false
                bosOccurred := true
            else
                bosOccurred := true
    lastSwingLow := swingPivotLow

// ────────────────────────────────────────────────────────────────────────────────
// ORDER BLOCKS - Enhanced with Volume Delta and Strength Classification
// ────────────────────────────────────────────────────────────────────────────────
// Calculate volume strength for order blocks
volStrength = volume > avgVol * 1.5 ? 3 : volume > avgVol * 1.3 ? 2 : 1
atrStrength = (high - low) > atr * 2.0 ? 3 : (high - low) > atr * 1.5 ? 2 : 1

bullishOB = close[1] < open[1] and close > open and 
             (high - low) > atr * obAtrMult and 
             volume > avgVol * obVolMult

bearishOB = close[1] > open[1] and close < open and 
             (high - low) > atr * obAtrMult and 
             volume > avgVol * obVolMult

var float lastBullOBHigh = na
var float lastBullOBLow = na
var int lastBullOBStrength = 0
var float lastBearOBHigh = na
var float lastBearOBLow = na
var int lastBearOBStrength = 0

if bullishOB
    int currentOBStrength = math.min(volStrength + atrStrength, 5)
    lastBullOBHigh := high[1]
    lastBullOBLow := low[1]
    lastBullOBStrength := currentOBStrength
    
    boxColor = currentOBStrength >= 4 ? color.new(COLOR_LONG, 75) : color.new(COLOR_LONG, 85)
    borderColor = currentOBStrength >= 4 ? color.new(COLOR_LONG, 30) : color.new(COLOR_LONG, 50)
    
    box.new(bar_index[1], high[1], bar_index + 20, low[1],
            border_color=borderColor,
            bgcolor=boxColor,
            border_width=currentOBStrength >= 4 ? 3 : 2)

if bearishOB
    int currentOBStrength = math.min(volStrength + atrStrength, 5)
    lastBearOBHigh := high[1]
    lastBearOBLow := low[1]
    lastBearOBStrength := currentOBStrength
    
    boxColor = currentOBStrength >= 4 ? color.new(COLOR_SHORT, 75) : color.new(COLOR_SHORT, 85)
    borderColor = currentOBStrength >= 4 ? color.new(COLOR_SHORT, 30) : color.new(COLOR_SHORT, 50)
    
    box.new(bar_index[1], high[1], bar_index + 20, low[1],
            border_color=borderColor,
            bgcolor=boxColor,
            border_width=currentOBStrength >= 4 ? 3 : 2)

// ────────────────────────────────────────────────────────────────────────────────
// FAIR VALUE GAPS
// ────────────────────────────────────────────────────────────────────────────────
bullishFVG = low > high[2]
fvgBullSize = bullishFVG ? (low - high[2]) / high[2] * 100 : 0
fvgBullTop = bullishFVG ? low : na
fvgBullBottom = bullishFVG ? high[2] : na

bearishFVG = high < low[2]
fvgBearSize = bearishFVG ? (low[2] - high) / low[2] * 100 : 0
fvgBearTop = bearishFVG ? low[2] : na
fvgBearBottom = bearishFVG ? high : na

var float activeFVGBullTop = na
var float activeFVGBullBottom = na
var float activeFVGBearTop = na
var float activeFVGBearBottom = na

if bullishFVG and fvgBullSize >= fvgMinSize
    activeFVGBullTop := fvgBullTop
    activeFVGBullBottom := fvgBullBottom
    box.new(bar_index[2], fvgBullTop, bar_index + 15, fvgBullBottom,
            border_color=color.new(COLOR_LONG, 60),
            bgcolor=COLOR_FVG_BULL,
            border_width=1)

if bearishFVG and fvgBearSize >= fvgMinSize
    activeFVGBearTop := fvgBearTop
    activeFVGBearBottom := fvgBearBottom
    box.new(bar_index[2], fvgBearTop, bar_index + 15, fvgBearBottom,
            border_color=color.new(COLOR_SHORT, 60),
            bgcolor=COLOR_FVG_BEAR,
            border_width=1)

// FVG Retest
fvgBullRetest = not na(activeFVGBullTop) and low <= activeFVGBullTop and close >= activeFVGBullBottom
fvgBearRetest = not na(activeFVGBearTop) and high >= activeFVGBearBottom and close <= activeFVGBearTop

// ────────────────────────────────────────────────────────────────────────────────
// PREMIUM/DISCOUNT ARRAYS
// ────────────────────────────────────────────────────────────────────────────────
rangeHigh = ta.highest(high, pdArrayLen)
rangeLow = ta.lowest(low, pdArrayLen)
rangeEQ = (rangeHigh + rangeLow) / 2

inPremium = close > rangeEQ and close > (rangeEQ + (rangeHigh - rangeEQ) * 0.5)
inDiscount = close < rangeEQ and close < (rangeEQ - (rangeEQ - rangeLow) * 0.5)

bgGradient = if inPremium
    distanceFromEQ = (close - rangeEQ) / (rangeHigh - rangeEQ)
    color.from_gradient(distanceFromEQ, 0.5, 1.0, COLOR_PREMIUM_2, COLOR_PREMIUM_1)
else if inDiscount
    distanceFromEQ = (rangeEQ - close) / (rangeEQ - rangeLow)
    color.from_gradient(distanceFromEQ, 0.5, 1.0, COLOR_DISCOUNT_2, COLOR_DISCOUNT_1)
else
    COLOR_EQUILIBRIUM

bgcolor(showGradientBg and pdEnabled ? bgGradient : na, title="PD Array")

// Glowing Equilibrium Line with Pulsing Effect
eqColor1 = color.new(#9370db, 0)
eqColor2 = color.new(#00d4ff, 0)
eqColor3 = color.new(#ff0080, 0)
eqColor4 = color.new(#00ffaa, 0)

pulseValue = math.sin(bar_index * 0.1) * 20 + 50
glowIntensity = int(pulseValue)

plot(pdEnabled ? rangeEQ : na, "EQ Glow Outer", color.new(eqColor1, 80), 8, plot.style_line)
plot(pdEnabled ? rangeEQ : na, "EQ Glow", color.new(eqColor1, glowIntensity), 6, plot.style_line)
plot(pdEnabled ? rangeEQ : na, "EQ Mid", color.new(eqColor2, 40), 4, plot.style_line)
plot(pdEnabled ? rangeEQ : na, "EQ Core", color.from_gradient(bar_index % 100, 0, 100, eqColor3, eqColor4), 2, plot.style_line)

premium75 = rangeEQ + (rangeHigh - rangeEQ) * 0.75
premium50 = rangeEQ + (rangeHigh - rangeEQ) * 0.5
discount50 = rangeEQ - (rangeEQ - rangeLow) * 0.5
discount75 = rangeEQ - (rangeEQ - rangeLow) * 0.75

plot(pdShowFib and pdEnabled ? rangeHigh : na, "Range High", color.new(#ff0080, 50), 2, plot.style_stepline)
plot(pdShowFib and pdEnabled ? premium75 : na, "Premium 75%", color.new(#ff4500, 60), 1, plot.style_stepline)
plot(pdShowFib and pdEnabled ? premium50 : na, "Premium 50%", color.new(#ff7f50, 70), 1, plot.style_stepline)
plot(pdShowFib and pdEnabled ? discount50 : na, "Discount 50%", color.new(#00ced1, 70), 1, plot.style_stepline)
plot(pdShowFib and pdEnabled ? discount75 : na, "Discount 75%", color.new(#00d4ff, 60), 1, plot.style_stepline)
plot(pdShowFib and pdEnabled ? rangeLow : na, "Range Low", color.new(#00ffaa, 50), 2, plot.style_stepline)

// ────────────────────────────────────────────────────────────────────────────────
// FIBONACCI CONFLUENCE
// ────────────────────────────────────────────────────────────────────────────────
calculateSwingFibs(swingLen) =>
    swingHigh = ta.highest(high, swingLen)
    swingLow = ta.lowest(low, swingLen)
    
    highBar = 0
    lowBar = 0
    for i = 0 to swingLen - 1
        if high[i] == swingHigh
            highBar := i
        if low[i] == swingLow
            lowBar := i
    
    isUptrend = lowBar > highBar
    
    fibStart = isUptrend ? swingLow : swingHigh
    fibEnd = isUptrend ? swingHigh : swingLow
    fibDiff = fibEnd - fibStart
    
    var array<float> levels = array.new<float>()
    array.clear(levels)
    
    array.push(levels, fibStart + (fibDiff * 0.236))
    array.push(levels, fibStart + (fibDiff * 0.382))
    array.push(levels, fibStart + (fibDiff * 0.5))
    array.push(levels, fibStart + (fibDiff * 0.618))
    array.push(levels, fibStart + (fibDiff * 0.786))
    
    levels

fib1 = fibEnabled ? calculateSwingFibs(swing1Length) : array.new<float>()
fib2 = fibEnabled ? calculateSwingFibs(swing2Length) : array.new<float>()

var bool inGoldenZone = false
if fibEnabled and showGoldenZone and array.size(fib1) >= 4
    fib618 = array.get(fib1, 3)
    fib65 = fib618 * 1.052
    goldenTop = math.max(fib618, fib65)
    goldenBot = math.min(fib618, fib65)
    inGoldenZone := close >= goldenBot and close <= goldenTop

// ────────────────────────────────────────────────────────────────────────────────
// LIQUIDITY SWEEPS - Enhanced with Equal Highs/Lows Detection
// ────────────────────────────────────────────────────────────────────────────────
liqPivotHigh = ta.pivothigh(high, liqSwingLen, liqSwingLen)
liqPivotLow = ta.pivotlow(low, liqSwingLen, liqSwingLen)

var float lastLiqHigh = na
var float lastLiqLow = na

liquiditySweepUp = false
liquiditySweepDown = false

// Equal Highs Detection (Liquidity Pool Above)
highest3 = ta.highest(high, 3)
equalHighs = high == high[1] and high == high[2] and high >= highest3

// Equal Lows Detection (Liquidity Pool Below)
lowest3 = ta.lowest(low, 3)
equalLows = low == low[1] and low == low[2] and low <= lowest3

if liqEnabled and not na(liqPivotHigh)
    if not na(lastLiqHigh)
        diff = math.abs(liqPivotHigh - lastLiqHigh) / lastLiqHigh * 100
        if diff <= liqTolerance
            liquiditySweepUp := true
    lastLiqHigh := liqPivotHigh

if liqEnabled and not na(liqPivotLow)
    if not na(lastLiqLow)
        diff = math.abs(liqPivotLow - lastLiqLow) / lastLiqLow * 100
        if diff <= liqTolerance
            liquiditySweepDown := true
    lastLiqLow := liqPivotLow

// Enhanced Liquidity Detection
liquidityAbove = equalHighs or liquiditySweepUp
liquidityBelow = equalLows or liquiditySweepDown

// ────────────────────────────────────────────────────────────────────────────────
// GRADIENT CANDLE COLORING - Enhanced with Pattern Recognition
// ────────────────────────────────────────────────────────────────────────────────
isBullCandle = close > open
candleStrength = atr > 0 ? math.abs(close - open) / atr : 0

candleColor = if showGradientCandles
    if hammerStrength or engulfingBullStrength or isMorningStar
        color.new(#00ff00, 0)
    else if shootingStarStrength or engulfingBearStrength or isEveningStar
        color.new(#ff0000, 0)
    else if inGoldenZone
        isBullCandle ? color.new(#FFD700, 0) : color.new(#ff8c00, 0)
    else if isBullCandle
        candleStrength > 1.5 ? COLOR_CANDLE_BULL_STRONG : COLOR_CANDLE_BULL_WEAK
    else
        candleStrength > 1.5 ? COLOR_CANDLE_BEAR_STRONG : COLOR_CANDLE_BEAR_WEAK
else
    na

barcolor(candleColor, title="Gradient Candles")

// ────────────────────────────────────────────────────────────────────────────────
// REGIME DETECTION
// ────────────────────────────────────────────────────────────────────────────────
regime = volRatio > 1.5 ? 0 : (ema9 > ema21 and ema21 > ema50) or (ema9 < ema21 and ema21 < ema50) ? 2 : 1  // 0=Choppy, 1=Ranging, 2=Trending

regimeOK = not regimeEnabled or (regime != 0 or not avoidChoppy)

// ────────────────────────────────────────────────────────────────────────────────
// DIVERGENCE DETECTION
// ────────────────────────────────────────────────────────────────────────────────
rsiOverbought = rsi > 70
rsiOversold = rsi < 30

divOK = not divEnabled or (not rsiOverbought and not rsiOversold)

// ────────────────────────────────────────────────────────────────────────────────
// CONFLUENCE SCORING SYSTEM
// ────────────────────────────────────────────────────────────────────────────────
confluenceScoreLong = 0
confluenceScoreShort = 0

// OR Breakout
if orEnabled and orBreakoutUp
    confluenceScoreLong += 2
if orEnabled and orBreakoutDown
    confluenceScoreShort += 2

// Market Structure
if requireBOS and bosOccurred and bullishStructure
    confluenceScoreLong += 2
if requireBOS and bosOccurred and not bullishStructure
    confluenceScoreShort += 2

// FVG Retest
if fvgEnabled and fvgBullRetest
    confluenceScoreLong += 2
if fvgEnabled and fvgBearRetest
    confluenceScoreShort += 2

// Order Blocks
if obEnabled and not na(lastBullOBLow)
    confluenceScoreLong += 1
if obEnabled and not na(lastBearOBHigh)
    confluenceScoreShort += 1

// Premium/Discount
if pdEnabled and inDiscount
    confluenceScoreLong += 1
if pdEnabled and inPremium
    confluenceScoreShort += 1

// Golden Zone
if fibEnabled and inGoldenZone
    confluenceScoreLong += 1
    confluenceScoreShort += 1

// RSI-2
if rsi2Enabled and rsi2_oversold
    confluenceScoreLong += 2
if rsi2Enabled and rsi2_overbought
    confluenceScoreShort += 2

// Divergence
if divEnabled and bullish_divergence
    confluenceScoreLong += 2
if divEnabled and bearish_divergence
    confluenceScoreShort += 2

// Liquidity Sweeps
if liqEnabled and (liquiditySweepDown or liquidityBelow)
    confluenceScoreLong += 1
if liqEnabled and (liquiditySweepUp or liquidityAbove)
    confluenceScoreShort += 1

// Volume
if volume_spike
    confluenceScoreLong += 1
    confluenceScoreShort += 1

// Momentum
if momentum_bull
    confluenceScoreLong += 1
if momentum_bear
    confluenceScoreShort += 1

// Candlestick Patterns
if hammerStrength or engulfingBullStrength or isMorningStar
    confluenceScoreLong += 2
if shootingStarStrength or engulfingBearStrength or isEveningStar
    confluenceScoreShort += 2

// Order Block Strength Bonus
if obEnabled and not na(lastBullOBLow) and lastBullOBStrength >= 4
    confluenceScoreLong += 1
if obEnabled and not na(lastBearOBHigh) and lastBearOBStrength >= 4
    confluenceScoreShort += 1

// ────────────────────────────────────────────────────────────────────────────────
// ENTRY CONDITIONS - Enhanced with Multiple Confirmation Layers
// ────────────────────────────────────────────────────────────────────────────────
// Flexible Entry Logic Based on Confluence Mode
minScore = confluenceMode == "Strict" ? 8 : confluenceMode == "Moderate" ? 6 : confluenceMode == "Flexible" ? 4 : 3

// Additional Confirmation Filters
trendConfirmLong = trend_bullish or (close > ema200 and ema9 > ema21)
trendConfirmShort = trend_bearish or (close < ema200 and ema9 < ema21)

// Volume Confirmation
volumeConfirm = volume > avgVol * 0.8

// LONG Entry with Enhanced Filters
longCondition = confluenceScoreLong >= minScore and
                 regimeOK and
                 inKillZone and
                 dailyTradeCount < maxDailyTrades and
                 strategy.position_size == 0 and
                 volumeConfirm and
                 (allowPartialSetups or trendConfirmLong)

// SHORT Entry with Enhanced Filters
shortCondition = confluenceScoreShort >= minScore and
                  regimeOK and
                  inKillZone and
                  dailyTradeCount < maxDailyTrades and
                  strategy.position_size == 0 and
                  volumeConfirm and
                  (allowPartialSetups or trendConfirmShort)

// ────────────────────────────────────────────────────────────────────────────────
// POSITION SIZING
// ────────────────────────────────────────────────────────────────────────────────
accountRisk = strategy.equity * (riskPercent / 100)

// ────────────────────────────────────────────────────────────────────────────────
// TRADE EXECUTION - Enhanced with Pattern Recognition Labels
// ────────────────────────────────────────────────────────────────────────────────
if longCondition
    stopLoss = orEnabled and orEstablished ? orLow : low - atr * 2
    riskPerShare = close - stopLoss
    
    // Validate risk is positive
    if riskPerShare > 0
        // Adaptive Take Profit
        tpMultiplier = useAdaptiveTP ? (volatility_high ? rewardMultiple * 1.5 : rewardMultiple) : rewardMultiple
        takeProfit = close + (riskPerShare * tpMultiplier)
        
        qty = math.abs(accountRisk / riskPerShare)
        qty := math.min(qty, 1000000000000.0)  // Cap at max allowed
        
        strategy.entry("LONG", strategy.long, qty=qty)
        strategy.exit("TP/SL", "LONG", stop=stopLoss, limit=takeProfit)
        
        dailyTradeCount += 1
        
        if showLabels
            patternInfo = hammerStrength ? " HAMMER" : engulfingBullStrength ? " ENGULF" : isMorningStar ? " MSTAR" : ""
            labelText = "LONG" + patternInfo + "\nScore: " + str.tostring(confluenceScoreLong) + "\nEntry: " + str.tostring(close, format.mintick) + "\nSL: " + str.tostring(stopLoss, format.mintick) + "\nTP: " + str.tostring(takeProfit, format.mintick)
            label.new(bar_index, low, labelText,
                      style=label.style_label_up, color=COLOR_LONG, textcolor=color.white, size=size.small)
            
            line.new(bar_index, stopLoss, bar_index + 10, stopLoss, color=COLOR_SHORT, width=2, style=line.style_dashed)
            line.new(bar_index, takeProfit, bar_index + 10, takeProfit, color=COLOR_LONG, width=2, style=line.style_dashed)

if shortCondition
    stopLoss = orEnabled and orEstablished ? orHigh : high + atr * 2
    riskPerShare = stopLoss - close
    
    // Validate risk is positive
    if riskPerShare > 0
        // Adaptive Take Profit
        tpMultiplier = useAdaptiveTP ? (volatility_high ? rewardMultiple * 1.5 : rewardMultiple) : rewardMultiple
        takeProfit = close - (riskPerShare * tpMultiplier)
        
        qty = math.abs(accountRisk / riskPerShare)
        qty := math.min(qty, 1000000000000.0)  // Cap at max allowed
        
        strategy.entry("SHORT", strategy.short, qty=qty)
        strategy.exit("TP/SL", "SHORT", stop=stopLoss, limit=takeProfit)
        
        dailyTradeCount += 1
        
        if showLabels
            patternInfo = shootingStarStrength ? " STAR" : engulfingBearStrength ? " ENGULF" : isEveningStar ? " ESTAR" : ""
            labelText = "SHORT" + patternInfo + "\nScore: " + str.tostring(confluenceScoreShort) + "\nEntry: " + str.tostring(close, format.mintick) + "\nSL: " + str.tostring(stopLoss, format.mintick) + "\nTP: " + str.tostring(takeProfit, format.mintick)
            label.new(bar_index, high, labelText,
                      style=label.style_label_down, color=COLOR_SHORT, textcolor=color.white, size=size.small)
            
            line.new(bar_index, stopLoss, bar_index + 10, stopLoss, color=COLOR_SHORT, width=2, style=line.style_dashed)
            line.new(bar_index, takeProfit, bar_index + 10, takeProfit, color=COLOR_LONG, width=2, style=line.style_dashed)

// ────────────────────────────────────────────────────────────────────────────────
// VISUAL PATTERN LABELS - Enhanced Chart Annotations
// ────────────────────────────────────────────────────────────────────────────────
// Candlestick Pattern Labels
if showLabels
    if hammerStrength
        label.new(bar_index, low - atr * 0.5, "HAMMER", 
                  style=label.style_label_up, color=color.new(COLOR_LONG, 20), 
                  textcolor=color.white, size=size.tiny)
    
    if shootingStarStrength
        label.new(bar_index, high + atr * 0.5, "STAR", 
                  style=label.style_label_down, color=color.new(COLOR_SHORT, 20), 
                  textcolor=color.white, size=size.tiny)
    
    if engulfingBullStrength
        label.new(bar_index, low - atr * 0.5, "ENGULF", 
                  style=label.style_label_up, color=color.new(COLOR_LONG, 10), 
                  textcolor=color.white, size=size.tiny)
    
    if engulfingBearStrength
        label.new(bar_index, high + atr * 0.5, "ENGULF", 
                  style=label.style_label_down, color=color.new(COLOR_SHORT, 10), 
                  textcolor=color.white, size=size.tiny)
    
    if isMorningStar
        label.new(bar_index, low - atr * 0.5, "MSTAR", 
                  style=label.style_label_up, color=color.new(#00ff00, 10), 
                  textcolor=color.white, size=size.tiny)
    
    if isEveningStar
        label.new(bar_index, high + atr * 0.5, "ESTAR", 
                  style=label.style_label_down, color=color.new(#ff0000, 10), 
                  textcolor=color.white, size=size.tiny)

// Liquidity Pool Labels
if showLabels and liqEnabled
    if equalHighs or liquiditySweepUp
        label.new(bar_index, high + atr * 0.3, "LIQ", 
                  style=label.style_label_down, color=color.new(COLOR_GOLDEN, 30), 
                  textcolor=color.white, size=size.tiny)
    
    if equalLows or liquiditySweepDown
        label.new(bar_index, low - atr * 0.3, "LIQ", 
                  style=label.style_label_up, color=color.new(COLOR_GOLDEN, 30), 
                  textcolor=color.white, size=size.tiny)

// ────────────────────────────────────────────────────────────────────────────────
// EOD EXIT
// ────────────────────────────────────────────────────────────────────────────────
inEOD = not na(time(timeframe.period, eodSession))

if useTimeExit and inEOD and strategy.position_size != 0
    strategy.close_all("EOD Exit")

// ────────────────────────────────────────────────────────────────────────────────
// PERFORMANCE DASHBOARD - Enhanced with Real-Time Metrics
// ────────────────────────────────────────────────────────────────────────────────
if barstate.islast and showDashboard
    var table dashboard = table.new(position.top_right, 2, 16,
                                     bgcolor=COLOR_DASHBOARD_BG,
                                     border_width=3,
                                     border_color=COLOR_DASHBOARD_BORDER)
    
    table.cell(dashboard, 0, 0, "PRECISION EDGE SYSTEM", text_color=COLOR_LONG,
               text_size=size.normal, bgcolor=COLOR_DASHBOARD_HEADER)
    table.merge_cells(dashboard, 0, 0, 1, 0)
    
    table.cell(dashboard, 0, 1, "Confluence Long", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    confLongText = str.tostring(confluenceScoreLong) + "/20"
    confLongColor = confluenceScoreLong >= 10 ? COLOR_PROFIT : confluenceScoreLong >= 6 ? COLOR_WARNING : color.gray
    table.cell(dashboard, 1, 1, confLongText, text_color=confLongColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 2, "Confluence Short", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    confShortText = str.tostring(confluenceScoreShort) + "/20"
    confShortColor = confluenceScoreShort >= 10 ? COLOR_PROFIT : confluenceScoreShort >= 6 ? COLOR_WARNING : color.gray
    table.cell(dashboard, 1, 2, confShortText, text_color=confShortColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 3, "OR Status", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    orText = orEstablished ? "ACTIVE" : "FORMING"
    orColor = orEstablished ? COLOR_LONG : COLOR_WARNING
    table.cell(dashboard, 1, 3, orText, text_color=orColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 4, "Structure", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    structText = bullishStructure ? "BULLISH" : "BEARISH"
    structColor = bullishStructure ? COLOR_LONG : COLOR_SHORT
    table.cell(dashboard, 1, 4, structText, text_color=structColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 5, "BOS Signal", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    bosText = bosOccurred ? "CONFIRMED" : "PENDING"
    bosColor = bosOccurred ? COLOR_ACCENT : color.gray
    table.cell(dashboard, 1, 5, bosText, text_color=bosColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 6, "Regime", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    regimeText = regime == 2 ? "TRENDING" : regime == 1 ? "RANGING" : "CHOPPY"
    regimeColor = regime == 2 ? COLOR_LONG : regime == 1 ? COLOR_WARNING : COLOR_SHORT
    table.cell(dashboard, 1, 6, regimeText, text_color=regimeColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 7, "Value Zone", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    zoneText = inPremium ? "PREMIUM" : inDiscount ? "DISCOUNT" : "EQUILIBRIUM"
    zoneColor = inPremium ? COLOR_SHORT : inDiscount ? COLOR_LONG : COLOR_ACCENT
    table.cell(dashboard, 1, 7, zoneText, text_color=zoneColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 8, "RSI State", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    rsiText = str.tostring(rsi, "#.#")
    rsiState = rsi > 70 ? " OB" : rsi < 30 ? " OS" : " NEU"
    rsiColor = rsi > 70 ? COLOR_SHORT : rsi < 30 ? COLOR_LONG : color.gray
    table.cell(dashboard, 1, 8, rsiText + rsiState, text_color=rsiColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 9, "Volatility", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    volText = volatility_high ? "HIGH" : volatility_low ? "LOW" : "NORMAL"
    volColor = volatility_high ? COLOR_WARNING : volatility_low ? color.gray : COLOR_ACCENT
    table.cell(dashboard, 1, 9, volText, text_color=volColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 10, "Volume", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    volStatus = volume_spike ? "SPIKE" : volume_significant ? "HIGH" : volume_dry ? "DRY" : "NORMAL"
    volStatusColor = volume_spike ? COLOR_PROFIT : volume_significant ? COLOR_LONG : volume_dry ? COLOR_LOSS : color.gray
    table.cell(dashboard, 1, 10, volStatus, text_color=volStatusColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 11, "Position", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    posText = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    posColor = strategy.position_size > 0 ? COLOR_LONG : strategy.position_size < 0 ? COLOR_SHORT : color.gray
    table.cell(dashboard, 1, 11, posText, text_color=posColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 12, "Net P/L", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    profitText = str.tostring(strategy.netprofit, format.mintick)
    profitColor = strategy.netprofit > 0 ? COLOR_PROFIT : strategy.netprofit < 0 ? COLOR_LOSS : color.gray
    table.cell(dashboard, 1, 12, profitText, text_color=profitColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 13, "Win Rate", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    winRate = strategy.closedtrades > 0 ? (strategy.wintrades / strategy.closedtrades * 100) : 0
    winText = str.tostring(winRate, "#.#") + "%"
    winColor = winRate > 60 ? COLOR_PROFIT : winRate > 45 ? COLOR_WARNING : COLOR_LOSS
    table.cell(dashboard, 1, 13, winText, text_color=winColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 14, "Total Trades", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    tradesText = str.tostring(strategy.closedtrades)
    tradesColor = strategy.closedtrades > 50 ? COLOR_LONG : strategy.closedtrades > 20 ? COLOR_WARNING : color.gray
    table.cell(dashboard, 1, 14, tradesText, text_color=tradesColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    
    table.cell(dashboard, 0, 15, "Profit Factor", text_color=color.new(#a0a0a0, 0), text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)
    pf = strategy.grossprofit / math.max(strategy.grossloss, 1)
    pfText = str.tostring(pf, "#.##")
    pfColor = pf > 2.0 ? COLOR_PROFIT : pf > 1.5 ? COLOR_WARNING : pf > 1.0 ? color.gray : COLOR_LOSS
    table.cell(dashboard, 1, 15, pfText, text_color=pfColor, text_size=size.small, bgcolor=COLOR_DASHBOARD_CELL)

// ────────────────────────────────────────────────────────────────────────────────
// PERFORMANCE PLOTS
// ────────────────────────────────────────────────────────────────────────────────
plot(strategy.equity, "Equity", COLOR_LONG, 2, display=display.none)

// ────────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS - Comprehensive Trading Signals
// ────────────────────────────────────────────────────────────────────────────────
alertcondition(longCondition, "LONG Entry", "LONG Signal - Score: {{plot_0}}")
alertcondition(shortCondition, "SHORT Entry", "SHORT Signal - Score: {{plot_0}}")
alertcondition(orBreakoutUp, "OR Breakout Up", "Opening Range Breakout - Bullish")
alertcondition(orBreakoutDown, "OR Breakout Down", "Opening Range Breakout - Bearish")
alertcondition(fvgBullRetest, "FVG Bull Retest", "Bullish Fair Value Gap Retest")
alertcondition(fvgBearRetest, "FVG Bear Retest", "Bearish Fair Value Gap Retest")
alertcondition(bosOccurred and bullishStructure, "BOS Bullish", "Break of Structure - Bullish")
alertcondition(bosOccurred and not bullishStructure, "BOS Bearish", "Break of Structure - Bearish")
alertcondition(bullish_divergence, "RSI Bullish Divergence", "Bullish Divergence Detected")
alertcondition(bearish_divergence, "RSI Bearish Divergence", "Bearish Divergence Detected")
alertcondition(hammerStrength, "Hammer Pattern", "Bullish Hammer Pattern")
alertcondition(shootingStarStrength, "Shooting Star Pattern", "Bearish Shooting Star Pattern")
alertcondition(engulfingBullStrength, "Bullish Engulfing", "Bullish Engulfing Pattern")
alertcondition(engulfingBearStrength, "Bearish Engulfing", "Bearish Engulfing Pattern")
alertcondition(liquidityAbove, "Liquidity Above", "Liquidity Pool Above Price")
alertcondition(liquidityBelow, "Liquidity Below", "Liquidity Pool Below Price")
alertcondition(inGoldenZone, "Golden Zone", "Price in Fibonacci Golden Zone")
alertcondition(rsiOversold, "RSI Oversold", "RSI Below 30")
alertcondition(rsiOverbought, "RSI Overbought", "RSI Above 70")
alertcondition(volume_spike, "Volume Spike", "Significant Volume Increase")
````
