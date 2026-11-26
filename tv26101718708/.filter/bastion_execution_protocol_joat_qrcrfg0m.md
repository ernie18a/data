# Bastion Execution Protocol [JOAT]

- url: https://www.tradingview.com/script/qrCrfG0m-Bastion-Execution-Protocol-JOAT/
- type: strategy
- pine_id: PUB;db5d7acf015149a7a0ea74b6175dc652
- version: 1.0

## Description

[b]Bastion Execution Protocol [JOAT][/b]

[b]Introduction[/b]

The Bastion Execution Protocol is an open-source automated trading strategy built in Pine Script v6. It combines regime detection, market structure analysis, dual momentum confirmation (RSI + Stochastic Momentum Index), order flow validation (CVD), candle pattern recognition, session filtering, and dynamic risk management into a single institutional-grade execution framework. The strategy is designed to take high-confluence directional trades only when multiple independent factors align — regime, structure, momentum, volume flow, and session — while managing risk through ATR-based stop losses, configurable reward-to-risk ratios, trailing stops, regime-adaptive position sizing, daily trade limits, and end-of-day forced closes.

This is not a "set and forget" black box. It is a transparent, fully configurable framework where every entry condition, risk parameter, and filter can be adjusted. The strategy is published open-source so traders can study the logic, understand why each trade is taken, and adapt the parameters to their instruments and timeframes.

[image]https://www.tradingview.com/x/dYRBN51m/[/image]

[b]Why This Strategy Exists[/b]

Most published strategies on TradingView fall into two categories: overly simple (single indicator crossover) or overly complex (dozens of conditions that overfit to historical data). This strategy occupies the middle ground — it requires meaningful confluence from independent analytical dimensions without over-optimizing to specific historical patterns:

[list]
[*][b]Multi-Factor Entry Gate:[/b] Every trade requires agreement from regime detection, market structure, momentum oscillators, and optionally CVD order flow and candle patterns. No single factor can trigger a trade alone.
[*][b]Regime-Aware Execution:[/b] The strategy only trades in trending regimes by default. It avoids squeeze conditions and can be configured to require specific regime states. Position sizing automatically reduces in volatile or uncertain regimes.
[*][b]Session Intelligence:[/b] Trades are filtered by session (London, New York, Kill Zones) and day of week. The strategy avoids low-quality periods and forces position closure at end of day.
[*][b]Dynamic Risk Management:[/b] ATR-based stop losses adapt to current volatility. Trailing stops activate after a configurable profit threshold. Position sizing is calculated from account equity and risk percentage, then adjusted by regime conditions.
[*][b]Performance Tracking:[/b] Real-time HUD displays win rate, profit factor, max drawdown, daily trade count, and current position status.
[/list]

[b]Strategy Architecture — 9 Modules[/b]

The strategy is organized into 9 sequential modules, each responsible for a specific aspect of the trading process:

[b]Module 1: Regime Detection[/b]

The regime engine classifies the market into four states using SMA alignment and VWAP slope:

[list]
[*][b]Trend Up:[/b] SMA 20 > 50 > 200 (bull alignment) AND positive VWAP slope — clear upward momentum
[*][b]Trend Down:[/b] SMA 20 < 50 < 200 (bear alignment) AND negative VWAP slope — clear downward momentum
[*][b]Squeeze:[/b] Bollinger Band width in the bottom 10th percentile — volatility compression
[*][b]Range:[/b] No SMA alignment and flat VWAP slope — sideways conditions
[/list]

The VWAP slope is normalized by ATR to make it comparable across instruments with different price scales. The regime state directly controls whether trading is allowed — by default, the strategy requires a trending regime.

[b]Module 2: Market Structure[/b]

Swing-based structure tracking identifies the directional bias:

[list]
[*]Pivot highs and lows are detected using configurable lookback
[*]When price closes above the last swing high while structure was bearish or neutral, structure flips bullish
[*]When price closes below the last swing low while structure was bullish or neutral, structure flips bearish
[*]Structure must agree with the regime for entries — regime bullish + structure bullish = long allowed
[/list]

Displacement candle detection identifies aggressive institutional order flow — candles with body >= 70% of range and body >= 1.8x the 20-bar average body. These serve as entry triggers when all other conditions are met.

[b]Module 3: Momentum Confirmation[/b]

Dual momentum confirmation requires both RSI and SMI to agree:

[list]
[*][b]RSI:[/b] Must be above the bull threshold (default 55) for longs, below the bear threshold (default 45) for shorts
[*][b]Stochastic Momentum Index:[/b] Must be positive for longs, negative for shorts. The SMI measures where price sits relative to the midpoint of its recent range, double-smoothed for noise reduction.
[*]Both must agree — RSI bullish AND SMI bullish = momentum confirmed for longs
[/list]

[b]Module 3B: CVD Order Flow Confirmation[/b]

When enabled, Cumulative Volume Delta must support the trade direction:

[list]
[*]Buy volume is estimated from bullish candles (close > open = full volume, otherwise proportional)
[*]Sell volume = total volume minus buy volume
[*]CVD = cumulative sum of (buy volume - sell volume)
[*]CVD must be above its moving average for longs, below for shorts
[*]This ensures that actual volume flow supports the intended trade direction
[/list]

[b]Module 3C: Candle Pattern Detection[/b]

When enabled, the strategy detects institutional candle patterns as entry triggers:

[list]
[*][b]Bullish Engulfing:[/b] Current bullish candle fully engulfs the prior bearish candle's body, with volume above average
[*][b]Bearish Engulfing:[/b] Current bearish candle fully engulfs the prior bullish candle's body, with volume above average
[*][b]Bullish Pin Bar:[/b] Lower wick > 2x body, upper wick < 0.5x body — rejection of lower prices
[*][b]Bearish Pin Bar:[/b] Upper wick > 2x body, lower wick < 0.5x body — rejection of higher prices
[/list]

Patterns serve as alternative entry triggers alongside displacement candles. Either a displacement candle, a pattern, or price above SMA20 + VWAP can trigger entry when all other conditions are met.

[b]Module 4: Session Filter[/b]

The session filter controls when trading is allowed:

[list]
[*]Four session windows: NY Kill Zone (7-10am), London Kill Zone (2-5am), NY Session (9:30am-4pm), London Session (3am-9:30am)
[*]Each session can be individually enabled/disabled
[*]Day of week filter allows disabling specific days (e.g., avoid Mondays or Fridays)
[*]Configurable timezone (default: America/New_York)
[*]End-of-day forced close at configurable time (default: 3:45pm)
[/list]

[b]Module 5: Daily Trade Counter[/b]

A daily trade counter prevents overtrading:

[list]
[*]Resets at the start of each new day
[*]Configurable maximum trades per day (default: 3)
[*]Combined with squeeze avoidance and regime filtering for comprehensive trade gating
[/list]

[b]Module 6: Entry Signal Generation[/b]

Entry signals require ALL of the following to be true simultaneously:

[pine]
// Long entry requires full confluence:
// 1. Regime = Trend Up
// 2. Structure trend = Bullish (swing break confirmed)
// 3. RSI > bull threshold AND SMI > 0
// 4. CVD above its MA (if enabled)
// 5. Bar is confirmed (barstate.isconfirmed)
// 6. Trade is allowed (daily limit, session, no squeeze)
// 7. Trigger: displacement candle OR pattern OR price > SMA20 + VWAP
[/pine]

This multi-gate approach ensures that trades are only taken when regime, structure, momentum, volume flow, session, and a specific trigger all agree. The probability of a random signal passing all gates is very low, which is by design.

[b]Module 7: Risk Calculations[/b]

Risk is calculated dynamically for each trade:

[list]
[*][b]Stop Loss:[/b] ATR * configurable multiplier (default 1.5x) below entry for longs, above for shorts
[*][b]Take Profit:[/b] SL distance * reward-to-risk ratio (default 2.0x)
[*][b]Position Size:[/b] (Account Equity * Risk Percentage * Regime Multiplier) / SL Distance
[*][b]Regime-Adaptive Sizing:[/b] When enabled, position size is reduced to 50% during squeeze conditions and 70% during non-trending conditions. Full size is used only in trending regimes.
[/list]

[b]Module 8: Trade Execution[/b]

Entries are executed using strategy.entry() with calculated position size. The strategy tracks active trade parameters (entry price, SL, TP) for trailing stop management.

[b]Module 9: Exit Management[/b]

Three exit mechanisms operate simultaneously:

[list]
[*][b]Fixed SL/TP:[/b] strategy.exit() with the calculated stop loss and take profit levels
[*][b]Trailing Stop:[/b] When enabled, activates after price moves a configurable multiple of R in profit (default 1.0R). The trail distance is ATR * configurable multiplier (default 1.0x). The trailing stop only moves in the favorable direction and replaces the fixed SL when it is tighter.
[*][b]End-of-Day Close:[/b] All positions are closed at the configured time to avoid overnight risk
[/list]

[b]Performance Tracking[/b]

The strategy tracks and displays real-time performance metrics:

[list]
[*][b]Win Rate:[/b] Wins / (Wins + Losses) as a percentage
[*][b]Profit Factor:[/b] Gross Profit / Gross Loss — values above 1.5 indicate a healthy edge
[*][b]Max Drawdown:[/b] Peak-to-trough equity decline as a percentage
[*][b]Net P&L:[/b] Total net profit/loss
[*][b]Daily Trade Count:[/b] Current day's trades vs maximum allowed
[/list]

[b]Strategy Settings and Backtesting Notes[/b]

The strategy is configured with realistic default parameters:

[list]
[*][b]Initial Capital:[/b] $100,000
[*][b]Default Position Size:[/b] 2% of equity
[*][b]Risk Per Trade:[/b] 1.5% (configurable)
[*][b]Commission:[/b] Not included by default — users should add commission appropriate to their broker in the strategy settings
[*][b]Slippage:[/b] Not included by default — users should add slippage appropriate to their instrument
[*][b]calc_on_every_tick:[/b] false — the strategy only evaluates on confirmed bar closes to prevent repainting
[*][b]calc_on_order_fills:[/b] true — allows trailing stop updates on fill events
[/list]

[b]Important:[/b] Before evaluating backtest results, users should:
[list]
[*]Add realistic commission for their broker (e.g., $5 per trade for stocks, 0.1% for crypto)
[*]Add realistic slippage (e.g., 1-2 ticks for liquid instruments)
[*]Verify that the backtest period includes different market conditions (trending, ranging, volatile)
[*]Check that the number of trades is sufficient for statistical significance (100+ trades recommended)
[*]Understand that past performance does not guarantee future results
[/list]

[b]Input Parameters[/b]

[b]Risk Management:[/b]
[list]
[*]Risk Per Trade %: Percentage of equity risked per trade (default: 1.5%)
[*]Reward:Risk Ratio: TP distance as multiple of SL distance (default: 2.0)
[*]SL ATR Multiplier: Stop loss distance as ATR multiple (default: 1.5)
[*]ATR Length: Period for ATR calculation (default: 14)
[*]Use Trailing Stop: Enable/disable trailing (default: true)
[*]Trail After X R Profit: Profit threshold to activate trail (default: 1.0R)
[*]Trail ATR Multiplier: Trail distance as ATR multiple (default: 1.0)
[*]Max Trades Per Day: Daily trade limit (default: 3)
[*]Regime-Adaptive Sizing: Reduce size in non-trending conditions (default: true)
[/list]

[b]Regime Filter:[/b]
[list]
[*]VWAP Slope Lookback: Period for slope calculation (default: 20)
[*]Slope Threshold: Normalized threshold for trend detection (default: 0.12)
[*]Bollinger Length/Multiplier: BB parameters for squeeze detection (default: 20/2.0)
[*]Avoid Squeeze Entries: Skip entries during squeeze (default: true)
[*]Require Trend Regime: Only trade in trending conditions (default: true)
[/list]

[b]Structure:[/b]
[list]
[*]Swing Lookback: Pivot detection length (default: 5)
[*]Displacement Min Body Ratio: Minimum body/range for displacement (default: 0.7)
[*]Displacement Body Multiplier: Minimum body vs average for displacement (default: 1.8)
[/list]

[b]Momentum:[/b]
[list]
[*]RSI Length/Thresholds: RSI parameters (default: 14, bull 55, bear 45)
[*]SMI Lookback/Smoothing: SMI parameters (default: 13/25/2)
[/list]

[b]Session Filter:[/b]
[list]
[*]Enable Session Filter: Toggle session-based trade gating
[*]Individual session toggles: NY KZ, London KZ, NY, London
[*]Day of week toggles: Monday through Friday
[*]Force Close End of Day: Toggle EOD position closure
[*]Close Hour/Minute: EOD close time (default: 15:45)
[/list]

[b]Order Flow:[/b]
[list]
[*]CVD Confirmation: Require delta direction to match entry (default: true)
[*]CVD Lookback: Period for CVD moving average (default: 10)
[/list]

[b]Candle Patterns:[/b]
[list]
[*]Use Pattern Confirmation: Enable pattern detection as entry trigger (default: true)
[*]Pattern Volume Multiplier: Minimum volume for pattern confirmation (default: 1.3x)
[/list]

[b]How to Use This Strategy[/b]

[b]Step 1: Configure for Your Instrument[/b]
Adjust the ATR multiplier and displacement thresholds for your instrument's volatility. Add realistic commission and slippage in TradingView's strategy settings.

[b]Step 2: Set Your Risk Parameters[/b]
Choose a risk percentage that matches your risk tolerance. The default 1.5% with 2:1 R:R is conservative. Adjust the trailing stop parameters based on your preference for locking in profits vs giving trades room.

[b]Step 3: Configure Sessions[/b]
Enable the sessions relevant to your instrument. For US equities, NY KZ and NY Session are most relevant. For forex, both London and NY Kill Zones are important. Disable days you prefer not to trade.

[b]Step 4: Run the Backtest[/b]
Apply the strategy to your chart and review the backtest results. Check win rate, profit factor, max drawdown, and number of trades. Ensure results are realistic and not the product of overfitting.

[b]Step 5: Forward Test[/b]
Before trading live, run the strategy in paper trading mode for at least 2-4 weeks to verify that live performance matches backtest expectations.

[b]Best Practices[/b]

[list]
[*]Always add commission and slippage before evaluating backtest results
[*]The strategy works best on liquid instruments with reliable volume data
[*]Higher timeframes (15m+) produce fewer but higher-quality trades
[*]The multi-gate entry system means trades are infrequent by design — this is a feature, not a bug
[*]Regime-adaptive sizing is recommended — it automatically reduces exposure in uncertain conditions
[*]The daily trade limit prevents revenge trading and overexposure
[*]End-of-day forced close eliminates overnight gap risk for intraday strategies
[*]Monitor the HUD during live trading for real-time regime, momentum, and session context
[*]If win rate drops below 40% or profit factor drops below 1.0, re-evaluate parameters for current market conditions
[/list]

[b]Limitations[/b]

[list]
[*]The strategy uses lagging indicators (SMAs, RSI, SMI) for entry conditions. Entries occur after the trend has started, not at the exact turn.
[*]Regime detection can lag regime changes. The strategy may miss the first portion of a new trend or take a trade just as a trend is ending.
[*]CVD is estimated from candle direction, not true order flow data. This is an approximation.
[*]Backtest results are hypothetical and do not account for real-world execution issues (partial fills, requotes, connectivity).
[*]The strategy is designed for intraday/swing trading. It is not optimized for scalping or long-term position trading.
[*]Session filtering is based on EST timezone. Instruments traded primarily in other timezones may need different session definitions.
[*]The multi-gate entry system can be too restrictive in some market conditions, producing very few trades. This is intentional — the strategy prioritizes quality over quantity.
[*]Past performance in backtesting does not guarantee future results. Market conditions change, and strategies that worked historically may not work in the future.
[/list]

[b]Technical Implementation[/b]

Built with Pine Script v6 using:
[list]
[*]calc_on_every_tick=false for non-repainting execution
[*]barstate.isconfirmed gating on all signal generation
[*]9-module architecture with clear separation of concerns
[*]ATR-based dynamic stop loss and take profit calculation
[*]Trailing stop with configurable activation threshold and trail distance
[*]Regime-adaptive position sizing with squeeze and non-trending penalties
[*]Session detection with timezone support and day-of-week filtering
[*]Daily trade counter with automatic reset
[*]End-of-day forced close mechanism
[*]Real-time performance tracking (win rate, profit factor, max drawdown)
[*]Dual momentum confirmation (RSI + SMI)
[*]CVD order flow validation
[*]Candle pattern detection (engulfing, pin bar) with volume confirmation
[*]6 alert conditions covering entries, regime changes, EOD close, patterns, and drawdown
[/list]

[b]Originality Statement[/b]

This strategy is original in its multi-dimensional confluence framework. While individual components (RSI, SMI, SMA alignment, session filtering) are established concepts, this strategy is justified because:

[list]
[*]The 9-module architecture creates a clear, auditable decision pipeline where each module's contribution to the final trade decision is transparent
[*]The multi-gate entry system (regime + structure + dual momentum + CVD + session + trigger) requires an unusually high level of confluence, reducing false signals
[*]Regime-adaptive position sizing automatically adjusts exposure based on market conditions, a feature rarely seen in published strategies
[*]The combination of trailing stops with regime-aware sizing creates a dynamic risk framework that adapts to changing conditions
[*]Session filtering with Kill Zone preference and day-of-week controls provides institutional-grade time management
[*]CVD order flow confirmation adds a volume-based validation layer that pure price-based strategies lack
[*]The real-time HUD with performance tracking provides transparency into strategy behavior that most published strategies do not offer
[*]The Volcanic theme provides a cohesive visual identity where every color choice carries meaning (lava = entry, amber = warning, teal = VWAP, crimson = bearish)
[/list]

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Backtested results are hypothetical and do not represent actual trading. Past performance does not guarantee future results. The strategy involves risk of loss, including the potential loss of the entire investment. Commission, slippage, and other real-world execution costs are not included in the default configuration and must be added by the user for realistic evaluation. The author makes no claims about the profitability of this strategy and is not responsible for any losses incurred from its use. Always use proper risk management, trade with capital you can afford to lose, and consider consulting a qualified financial advisor before trading.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Bastion Execution Protocol [JOAT]", "BEP [JOAT]", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=2, initial_capital=100000, currency=currency.USD, calc_on_every_tick=false, calc_on_order_fills=true, max_bars_back=500, max_lines_count=200, max_labels_count=200, max_boxes_count=100)

// ─── PALETTE ── VOLCANIC THEME ──────────────────────────────────────────
color VOLC_CRIMSON  = #D50000   // Deep crimson lava
color VOLC_AMBER    = #FF8F00   // Molten amber
color VOLC_OBSIDIAN = #0D0D0D   // Obsidian black
color VOLC_LAVA     = #FF3D00   // Flowing lava orange
color VOLC_MAGMA    = #FF1744   // Magma red
color VOLC_ASH      = #424242   // Volcanic ash
color VOLC_SMOKE    = #757575   // Smoke grey
color VOLC_EMBER    = #FF6D00   // Glowing ember
color VOLC_GOLD     = #FFD600   // Molten gold
color VOLC_IVORY    = #FFF3E0   // Warm ivory
color VOLC_STEEL    = #37474F   // Cooled steel
color VOLC_TEAL     = #00BFA5   // Cooled mineral teal
color VOLC_VIOLET   = #6A1B9A   // Deep volcanic purple
color VOLC_SULFUR   = #AEEA00   // Sulfur yellow-green
// Legacy aliases
color VERD       = VOLC_AMBER
color CRIM       = VOLC_CRIMSON
color AMBER      = VOLC_GOLD
color COBALT     = VOLC_TEAL
color SLATE      = VOLC_ASH
color IVORY      = VOLC_IVORY
color VIOLET     = VOLC_VIOLET
color GRAPHITE   = VOLC_OBSIDIAN
color TEAL       = VOLC_TEAL
color EMERALD    = VOLC_SULFUR
color ROSE       = VOLC_MAGMA
color SOLAR      = VOLC_GOLD
color NEON_CYAN  = VOLC_EMBER
color NEON_PINK  = VOLC_CRIMSON

// ─── INPUTS: RISK MANAGEMENT ─────────────────────────────────────────────────
string GRP_RISK = "Risk Management"
float  i_riskPct   = input.float(1.5, "Risk Per Trade %", minval=0.1, maxval=5.0, step=0.1, group=GRP_RISK)
float  i_rrRatio   = input.float(2.0, "Reward:Risk Ratio", minval=1.0, maxval=5.0, step=0.5, group=GRP_RISK)
float  i_slATRMult = input.float(1.5, "SL ATR Multiplier", minval=0.5, maxval=4.0, step=0.1, group=GRP_RISK)
int    i_atrLen    = input.int(14, "ATR Length", minval=5, maxval=50, group=GRP_RISK)
bool   i_useTrail  = input.bool(true, "Use Trailing Stop", group=GRP_RISK)
float  i_trailStart = input.float(1.0, "Trail After X R Profit", minval=0.5, maxval=3.0, step=0.25, group=GRP_RISK)
float  i_trailATR  = input.float(1.0, "Trail ATR Multiplier", minval=0.3, maxval=3.0, step=0.1, group=GRP_RISK)
int    i_maxTrades = input.int(3, "Max Trades Per Day", minval=1, maxval=10, group=GRP_RISK)
bool   i_regimeSize = input.bool(true, "Regime-Adaptive Sizing", group=GRP_RISK, tooltip="Reduce size in volatile/squeeze regimes")

// ─── INPUTS: REGIME FILTER ───────────────────────────────────────────────────
string GRP_REG = "Regime Filter"
int    i_vwapLen   = input.int(20, "VWAP Slope Lookback", minval=5, maxval=100, group=GRP_REG)
float  i_slopeThr  = input.float(0.12, "Slope Threshold (normalized)", minval=0.01, maxval=1.0, step=0.01, group=GRP_REG)
int    i_bbLen     = input.int(20, "Bollinger Length", minval=10, maxval=50, group=GRP_REG)
float  i_bbMult    = input.float(2.0, "Bollinger Multiplier", minval=1.0, maxval=4.0, step=0.1, group=GRP_REG)
bool   i_avoidSqz  = input.bool(true, "Avoid Squeeze Entries", group=GRP_REG, tooltip="Skip entries during Bollinger squeeze")
bool   i_regimeFlt = input.bool(true, "Require Trend Regime", group=GRP_REG, tooltip="Only trade when regime is trending")

// ─── INPUTS: STRUCTURE ───────────────────────────────────────────────────────
string GRP_STR = "Structure"
int    i_swingLen  = input.int(5, "Swing Lookback", minval=2, maxval=15, group=GRP_STR)
float  i_dispBody  = input.float(0.7, "Displacement Min Body Ratio", minval=0.5, maxval=0.95, step=0.05, group=GRP_STR)
float  i_dispMult  = input.float(1.8, "Displacement Body Multiplier", minval=1.2, maxval=3.0, step=0.1, group=GRP_STR)

// ─── INPUTS: MOMENTUM ───────────────────────────────────────────────────────
string GRP_MOM = "Momentum"
int    i_rsiLen    = input.int(14, "RSI Length", minval=5, maxval=50, group=GRP_MOM)
float  i_rsiBull   = input.float(55, "RSI Bull Threshold", minval=50, maxval=70, group=GRP_MOM)
float  i_rsiBear   = input.float(45, "RSI Bear Threshold", minval=30, maxval=50, group=GRP_MOM)
int    i_smiLook   = input.int(13, "SMI Lookback", minval=5, maxval=30, group=GRP_MOM)
int    i_smiSm1    = input.int(25, "SMI Smooth 1", minval=2, maxval=50, group=GRP_MOM)
int    i_smiSm2    = input.int(2, "SMI Smooth 2", minval=1, maxval=10, group=GRP_MOM)

// ─── INPUTS: SESSION ─────────────────────────────────────────────────────────
string GRP_SESS = "Session Filter"
bool   i_sessFilter = input.bool(true, "Enable Session Filter", group=GRP_SESS)
string i_tz        = input.string("America/New_York", "Timezone", group=GRP_SESS)
bool   i_tradeNYKZ = input.bool(true, "Trade NY Kill Zone (7-10)", group=GRP_SESS)
bool   i_tradeLonKZ = input.bool(true, "Trade London KZ (2-5)", group=GRP_SESS)
bool   i_tradeNY   = input.bool(true, "Trade NY Session (9:30-16)", group=GRP_SESS)
bool   i_tradeLon  = input.bool(true, "Trade London (3-9:30)", group=GRP_SESS)
bool   i_forceClose = input.bool(true, "Force Close End of Day", group=GRP_SESS)
int    i_closeHour = input.int(15, "Close Hour", minval=0, maxval=23, group=GRP_SESS)
int    i_closeMin  = input.int(45, "Close Minute", minval=0, maxval=59, group=GRP_SESS)

string GRP_DOW = "Day of Week"
bool   i_tradeMon = input.bool(true, "Monday", group=GRP_DOW)
bool   i_tradeTue = input.bool(true, "Tuesday", group=GRP_DOW)
bool   i_tradeWed = input.bool(true, "Wednesday", group=GRP_DOW)
bool   i_tradeThu = input.bool(true, "Thursday", group=GRP_DOW)
bool   i_tradeFri = input.bool(true, "Friday", group=GRP_DOW)

// ─── INPUTS: VISUAL ──────────────────────────────────────────────────────────
string GRP_VIS = "Visual"
bool   i_showHUD   = input.bool(true, "Show HUD", group=GRP_VIS)
bool   i_showSMA   = input.bool(true, "Show SMA Lines", group=GRP_VIS)
bool   i_showST    = input.bool(true, "Show Regime Background", group=GRP_VIS)

string GRP_PAT = "Candle Patterns"
bool   i_usePat    = input.bool(true, "Use Pattern Confirmation", group=GRP_PAT, tooltip="Engulfing and pin bar patterns boost entry confidence")
float  i_patVolMult = input.float(1.3, "Pattern Volume Multiplier", minval=1.0, maxval=3.0, step=0.1, group=GRP_PAT)

string GRP_CVD = "Order Flow"
bool   i_useCVD   = input.bool(true, "CVD Confirmation", group=GRP_CVD, tooltip="Require delta direction to match entry direction")
int    i_cvdLook  = input.int(10, "CVD Lookback", minval=3, maxval=50, group=GRP_CVD)

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 1: REGIME DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

float atrVal = ta.atr(i_atrLen)
float vwapVal = ta.vwap(hlc3)
float vwapDelta = vwapVal - nz(vwapVal[i_vwapLen], vwapVal)
float normSlope = atrVal > 0 ? vwapDelta / (atrVal * math.sqrt(i_vwapLen)) : 0

bool slopeUp   = normSlope > i_slopeThr
bool slopeDn   = normSlope < -i_slopeThr
bool slopeFlat = not slopeUp and not slopeDn

// SMA alignment
float sma20 = ta.sma(close, 20)
float sma50 = ta.sma(close, 50)
float sma200 = ta.sma(close, 200)
bool smaBull = sma20 > sma50 and sma50 > sma200
bool smaBear = sma20 < sma50 and sma50 < sma200

// Bollinger squeeze detection
[bbMid, bbUp, bbDn] = ta.bb(close, i_bbLen, i_bbMult)
float bbWidth = bbMid > 0 ? (bbUp - bbDn) / bbMid * 100 : 0
float bbPctRnk = ta.percentrank(bbWidth, 120)
bool isSqueeze = bbPctRnk < 10

// Regime classification
string REGIME_UP   = "Trend Up"
string REGIME_DN   = "Trend Down"
string REGIME_RNG  = "Range"
string REGIME_SQZ  = "Squeeze"

var string regime = REGIME_RNG
if isSqueeze
    regime := REGIME_SQZ
else if smaBull and slopeUp
    regime := REGIME_UP
else if smaBear and slopeDn
    regime := REGIME_DN
else if slopeUp or smaBull
    regime := REGIME_UP
else if slopeDn or smaBear
    regime := REGIME_DN
else
    regime := REGIME_RNG

bool regimeBull = regime == REGIME_UP
bool regimeBear = regime == REGIME_DN
bool regimeTrending = regimeBull or regimeBear

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 2: MARKET STRUCTURE
// ═══════════════════════════════════════════════════════════════════════════════

float swH = ta.pivothigh(high, i_swingLen, i_swingLen)
float swL = ta.pivotlow(low, i_swingLen, i_swingLen)

var float lastSH = na
var float lastSL = na
var int structTrend = 0

if not na(swH)
    lastSH := swH
if not na(swL)
    lastSL := swL

// Structure trend via swing breaks
if barstate.isconfirmed
    if not na(lastSH) and close > lastSH and structTrend <= 0
        structTrend := 1
    if not na(lastSL) and close < lastSL and structTrend >= 0
        structTrend := -1

// Displacement candle detection
float body   = math.abs(close - open)
float range_ = high - low
float avgBody = ta.sma(body, 20)
bool isBull = close > open
bool isBear = close < open
float bodyRatio = range_ > 0 ? body / range_ : 0
bool displacement = bodyRatio >= i_dispBody and body >= avgBody * i_dispMult and range_ > 0
bool bullDisp = displacement and isBull and barstate.isconfirmed
bool bearDisp = displacement and isBear and barstate.isconfirmed

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 3: MOMENTUM CONFIRMATION
// ═══════════════════════════════════════════════════════════════════════════════

float rsiVal = ta.rsi(close, i_rsiLen)
bool rsiBull = rsiVal > i_rsiBull
bool rsiBear = rsiVal < i_rsiBear

// SMI calculation
float highH = ta.highest(high, i_smiLook)
float lowL  = ta.lowest(low, i_smiLook)
float dist  = close - (highH + lowL) / 2
float rng   = highH - lowL
float sm1n  = ta.ema(dist, i_smiSm1)
float sm2n  = ta.ema(sm1n, i_smiSm2)
float sm1d  = ta.ema(rng, i_smiSm1)
float sm2d  = ta.ema(sm1d, i_smiSm2) * 0.5
float smiVal = sm2d != 0 ? 100.0 * sm2n / sm2d : 0.0

bool smiBull = smiVal > 0
bool smiBear = smiVal < 0

// Combined momentum
bool momBull = rsiBull and smiBull
bool momBear = rsiBear and smiBear

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 3B: CVD ORDER FLOW CONFIRMATION
// ═══════════════════════════════════════════════════════════════════════════════

float buyVol  = close >= open ? volume : volume * (close - low) / math.max(high - low, syminfo.mintick)
float sellVol = volume - buyVol
float delta   = buyVol - sellVol
var float cvd = 0.0
cvd += delta

float cvdMA = ta.sma(cvd, i_cvdLook)
bool cvdBull = cvd > cvdMA
bool cvdBear = cvd < cvdMA

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 3C: CANDLE PATTERN DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

float avgVolPat = ta.sma(volume, 20)
bool highVolPat = volume > avgVolPat * i_patVolMult
float candleBody = math.abs(close - open)
float candleRange = high - low
float lowerWick = math.min(open, close) - low
float upperWick = high - math.max(open, close)

// Bullish engulfing
bool bullEngulf = close > open and close[1] < open[1] and close > open[1] and open < close[1] and candleBody > math.abs(close[1] - open[1]) and highVolPat and barstate.isconfirmed
// Bearish engulfing
bool bearEngulf = close < open and close[1] > open[1] and close < open[1] and open > close[1] and candleBody > math.abs(close[1] - open[1]) and highVolPat and barstate.isconfirmed
// Bullish pin bar
bool bullPin = lowerWick > candleBody * 2 and upperWick < candleBody * 0.5 and candleRange > 0 and barstate.isconfirmed
// Bearish pin bar
bool bearPin = upperWick > candleBody * 2 and lowerWick < candleBody * 0.5 and candleRange > 0 and barstate.isconfirmed

bool bullPattern = i_usePat and (bullEngulf or bullPin)
bool bearPattern = i_usePat and (bearEngulf or bearPin)

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 4: SESSION FILTER
// ═══════════════════════════════════════════════════════════════════════════════

f_inSess(_s) => not na(time(timeframe.period, _s, i_tz))

bool inNYKZ    = f_inSess("0700-1000")
bool inLonKZ   = f_inSess("0200-0500")
bool inNY      = f_inSess("0930-1600")
bool inLondon  = f_inSess("0300-0930")

bool sessionOK = true
if i_sessFilter
    sessionOK := (i_tradeNYKZ and inNYKZ) or (i_tradeLonKZ and inLonKZ) or (i_tradeNY and inNY) or (i_tradeLon and inLondon)

// Day of week filter
int dow = dayofweek(time, i_tz)
bool dowOK = (dow == dayofweek.monday and i_tradeMon) or (dow == dayofweek.tuesday and i_tradeTue) or (dow == dayofweek.wednesday and i_tradeWed) or (dow == dayofweek.thursday and i_tradeThu) or (dow == dayofweek.friday and i_tradeFri)
if not dowOK
    sessionOK := false

// Force close check
bool isCloseTime = false
if i_forceClose
    int cTime = time(timeframe.period, "0000-2400:23456", i_tz)
    if not na(cTime)
        isCloseTime := hour(cTime, i_tz) == i_closeHour and minute(cTime, i_tz) >= i_closeMin

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 5: DAILY TRADE COUNTER
// ═══════════════════════════════════════════════════════════════════════════════

var int dailyTrades = 0
bool isNewDay = ta.change(time("D")) != 0
if isNewDay
    dailyTrades := 0

bool tradeAllowed = dailyTrades < i_maxTrades and sessionOK

// Squeeze filter
if i_avoidSqz and isSqueeze
    tradeAllowed := false

// Regime filter
if i_regimeFlt and not regimeTrending
    tradeAllowed := false

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 6: ENTRY SIGNALS (confirmed bar only)
// ═══════════════════════════════════════════════════════════════════════════════

// CVD filter
bool cvdLongOK = not i_useCVD or cvdBull
bool cvdShortOK = not i_useCVD or cvdBear

// Long signal: regime bull + structure bull + momentum bull + CVD + displacement/pattern
bool longBase = regimeBull and structTrend == 1 and momBull and cvdLongOK and barstate.isconfirmed and tradeAllowed
bool longEntry = longBase and (bullDisp or bullPattern or (close > sma20 and close > vwapVal))

// Short signal: regime bear + structure bear + momentum bear + CVD + displacement/pattern
bool shortBase = regimeBear and structTrend == -1 and momBear and cvdShortOK and barstate.isconfirmed and tradeAllowed
bool shortEntry = shortBase and (bearDisp or bearPattern or (close < sma20 and close < vwapVal))

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 7: RISK CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════

float slDist = atrVal * i_slATRMult
float tpDist = slDist * i_rrRatio

float longSL  = close - slDist
float longTP  = close + tpDist
float shortSL = close + slDist
float shortTP = close - tpDist

// Position sizing based on risk — regime-adaptive
float accountVal = strategy.equity
float riskMult = 1.0
if i_regimeSize
    riskMult := isSqueeze ? 0.5 : not regimeTrending ? 0.7 : 1.0
float riskAmount = accountVal * i_riskPct / 100 * riskMult
float posSize = slDist > 0 ? riskAmount / slDist : 0

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 8: TRADE EXECUTION
// ═══════════════════════════════════════════════════════════════════════════════

// Track active trade for trailing
var float activeEntrySL = na
var float activeEntryTP = na
var float activeEntryPrice = na
var float trailStop = na

if strategy.position_size == 0
    trailStop := na
    activeEntrySL := na
    activeEntryTP := na
    activeEntryPrice := na

// Entry execution
if longEntry and strategy.position_size == 0
    strategy.entry("Long", strategy.long, qty=posSize, comment="BEP Long")
    activeEntrySL := longSL
    activeEntryTP := longTP
    activeEntryPrice := close
    dailyTrades += 1

if shortEntry and strategy.position_size == 0
    strategy.entry("Short", strategy.short, qty=posSize, comment="BEP Short")
    activeEntrySL := shortSL
    activeEntryTP := shortTP
    activeEntryPrice := close
    dailyTrades += 1

// ═══════════════════════════════════════════════════════════════════════════════
// MODULE 9: EXIT MANAGEMENT (SL/TP + Trailing)
// ═══════════════════════════════════════════════════════════════════════════════

if strategy.position_size > 0 and not na(activeEntrySL)
    // Trailing stop logic
    if i_useTrail and not na(activeEntryPrice)
        float profitR = (close - activeEntryPrice) / slDist
        if profitR >= i_trailStart
            float newTrail = close - atrVal * i_trailATR
            if na(trailStop) or newTrail > trailStop
                trailStop := newTrail
            if not na(trailStop) and trailStop > activeEntrySL
                activeEntrySL := trailStop

    strategy.exit("Exit Long", from_entry="Long", stop=activeEntrySL, limit=activeEntryTP, comment="SL/TP Long")

if strategy.position_size < 0 and not na(activeEntrySL)
    // Trailing stop logic
    if i_useTrail and not na(activeEntryPrice)
        float profitR = (activeEntryPrice - close) / slDist
        if profitR >= i_trailStart
            float newTrail = close + atrVal * i_trailATR
            if na(trailStop) or newTrail < trailStop
                trailStop := newTrail
            if not na(trailStop) and trailStop < activeEntrySL
                activeEntrySL := trailStop

    strategy.exit("Exit Short", from_entry="Short", stop=activeEntrySL, limit=activeEntryTP, comment="SL/TP Short")

// Force close at end of day
if isCloseTime and strategy.position_size != 0
    strategy.close_all(comment="EOD Close")

// ═══════════════════════════════════════════════════════════════════════════════
// VISUAL OUTPUT
// ═══════════════════════════════════════════════════════════════════════════════

// SMA lines — volcanic heat gradient
pS20 = plot(i_showSMA ? sma20 : na, "SMA 20", color=color.new(VOLC_LAVA, 40), linewidth=1)
pS50 = plot(i_showSMA ? sma50 : na, "SMA 50", color=color.new(VOLC_AMBER, 45), linewidth=1)
plot(i_showSMA ? sma200 : na, "SMA 200", color=color.new(VOLC_VIOLET, 40), linewidth=2)

// Trend ribbon — lava flow
color ribCol = sma20 > sma50 ? color.new(VOLC_AMBER, 87) : color.new(VOLC_CRIMSON, 87)
fill(pS20, pS50, ribCol, title="Lava Ribbon")

// VWAP — cooled mineral line with glow
plot(vwapVal, "VWAP Glow", color=color.new(VOLC_TEAL, 78), linewidth=3)
plot(vwapVal, "VWAP", color=color.new(VOLC_TEAL, 50), linewidth=1)

// Regime background — volcanic heat map
color regBg = na
if i_showST
    regBg := regimeBull ? color.new(VOLC_AMBER, 95) : regimeBear ? color.new(VOLC_CRIMSON, 95) : isSqueeze ? color.new(VOLC_GOLD, 95) : na
bgcolor(regBg, title="Volcanic BG")

// Entry markers — volcanic eruption signals
plotshape(longEntry and strategy.position_size[1] == 0, "Long Entry", shape.diamond, location.belowbar, color=color.new(VOLC_GOLD, 0), size=size.small)
plotshape(shortEntry and strategy.position_size[1] == 0, "Short Entry", shape.diamond, location.abovebar, color=color.new(VOLC_MAGMA, 0), size=size.small)

// Displacement markers — ember glow
plotshape(bullDisp and not longEntry, "Bull Disp", shape.circle, location.belowbar, color=color.new(VOLC_EMBER, 40), size=size.tiny)
plotshape(bearDisp and not shortEntry, "Bear Disp", shape.circle, location.abovebar, color=color.new(VOLC_VIOLET, 40), size=size.tiny)

// Pattern markers — lava sparks
plotshape(bullPattern and not longEntry, "Bull Pattern", shape.triangleup, location.belowbar, color=color.new(VOLC_AMBER, 20), size=size.tiny)
plotshape(bearPattern and not shortEntry, "Bear Pattern", shape.triangledown, location.abovebar, color=color.new(VOLC_CRIMSON, 20), size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// HUD TABLE
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// PERFORMANCE TRACKING
// ═══════════════════════════════════════════════════════════════════════════════

var int totalWins = 0
var int totalLosses = 0
var float maxDrawdown = 0.0
var float peakEquity = 0.0

if strategy.equity > peakEquity
    peakEquity := strategy.equity
float currentDD = peakEquity > 0 ? (peakEquity - strategy.equity) / peakEquity * 100 : 0
if currentDD > maxDrawdown
    maxDrawdown := currentDD

if strategy.closedtrades > 0
    totalWins := strategy.wintrades
    totalLosses := strategy.losstrades

float winRate = (totalWins + totalLosses) > 0 ? float(totalWins) / float(totalWins + totalLosses) * 100 : 0
float profitFactor = strategy.grossloss != 0 ? math.abs(strategy.grossprofit / strategy.grossloss) : 0

var table hud = na
if i_showHUD and na(hud)
    hud := table.new(position.top_right, 2, 13, bgcolor=color.new(VOLC_OBSIDIAN, 2), border_color=color.new(VOLC_ASH, 45), border_width=1, frame_color=color.new(VOLC_LAVA, 30), frame_width=2)

if i_showHUD and barstate.islast
    // Title
    table.cell(hud, 0, 0, "BASTION", bgcolor=color.new(VOLC_OBSIDIAN, 0), text_color=VOLC_LAVA, text_size=size.small)
    table.cell(hud, 1, 0, "VOLCANIC", bgcolor=color.new(VOLC_OBSIDIAN, 0), text_color=VOLC_AMBER, text_size=size.small)

    // Regime
    color regCol = regimeBull ? VERD : regimeBear ? CRIM : isSqueeze ? AMBER : SLATE
    table.cell(hud, 0, 1, "Regime", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 1, regime, bgcolor=color.new(GRAPHITE, 0), text_color=regCol, text_size=size.small)

    // Structure
    string strStr = structTrend == 1 ? "Bullish" : structTrend == -1 ? "Bearish" : "Neutral"
    color strCol = structTrend == 1 ? VERD : structTrend == -1 ? CRIM : SLATE
    table.cell(hud, 0, 2, "Structure", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 2, strStr, bgcolor=color.new(GRAPHITE, 0), text_color=strCol, text_size=size.small)

    // Momentum
    string momStr = momBull ? "Bullish" : momBear ? "Bearish" : "Neutral"
    color momCol = momBull ? VERD : momBear ? CRIM : SLATE
    table.cell(hud, 0, 3, "Momentum", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 3, momStr + " (RSI:" + str.tostring(int(rsiVal)) + ")", bgcolor=color.new(GRAPHITE, 0), text_color=momCol, text_size=size.small)

    // Session
    string sessStr = inNYKZ ? "NY KZ" : inLonKZ ? "London KZ" : inNY ? "NY" : inLondon ? "London" : "Off"
    color sessCol = (inNYKZ or inLonKZ) ? VERD : (inNY or inLondon) ? AMBER : CRIM
    table.cell(hud, 0, 4, "Session", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 4, sessStr, bgcolor=color.new(GRAPHITE, 0), text_color=sessCol, text_size=size.small)

    // Position
    string posStr = strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT"
    color posCol = strategy.position_size > 0 ? VERD : strategy.position_size < 0 ? CRIM : SLATE
    table.cell(hud, 0, 5, "Position", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 5, posStr, bgcolor=color.new(GRAPHITE, 0), text_color=posCol, text_size=size.small)

    // Daily trades
    table.cell(hud, 0, 6, "Trades", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(dailyTrades) + " / " + str.tostring(i_maxTrades), bgcolor=color.new(GRAPHITE, 0), text_color=dailyTrades >= i_maxTrades ? CRIM : IVORY, text_size=size.small)

    // Risk info
    table.cell(hud, 0, 7, "SL Dist", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 7, str.tostring(slDist, format.mintick), bgcolor=color.new(GRAPHITE, 0), text_color=AMBER, text_size=size.small)

    // P&L
    float pnl = strategy.netprofit
    color pnlCol = pnl >= 0 ? VERD : CRIM
    table.cell(hud, 0, 8, "Net P&L", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 8, str.tostring(pnl, format.mintick), bgcolor=color.new(GRAPHITE, 0), text_color=pnlCol, text_size=size.small)

    // Win Rate
    color wrCol = winRate >= 55 ? EMERALD : winRate >= 40 ? AMBER : CRIM
    table.cell(hud, 0, 9, "Win Rate", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 9, str.tostring(winRate, "#.#") + "% (" + str.tostring(totalWins) + "W/" + str.tostring(totalLosses) + "L)", bgcolor=color.new(GRAPHITE, 0), text_color=wrCol, text_size=size.small)

    // Profit Factor
    color pfCol = profitFactor >= 1.5 ? EMERALD : profitFactor >= 1.0 ? AMBER : CRIM
    table.cell(hud, 0, 10, "PF", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 10, str.tostring(profitFactor, "#.##"), bgcolor=color.new(GRAPHITE, 0), text_color=pfCol, text_size=size.small)

    // Max Drawdown
    color ddCol = maxDrawdown < 5 ? VERD : maxDrawdown < 15 ? AMBER : CRIM
    table.cell(hud, 0, 11, "Max DD", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
    table.cell(hud, 1, 11, str.tostring(maxDrawdown, "#.#") + "%", bgcolor=color.new(GRAPHITE, 0), text_color=ddCol, text_size=size.small)

    // CVD state
    if i_useCVD
        string cvdStr = cvdBull ? "Bullish" : cvdBear ? "Bearish" : "Neutral"
        color cvdCol = cvdBull ? NEON_CYAN : cvdBear ? NEON_PINK : SLATE
        table.cell(hud, 0, 12, "CVD", bgcolor=color.new(GRAPHITE, 0), text_color=color.new(SLATE, 0), text_size=size.small)
        table.cell(hud, 1, 12, cvdStr, bgcolor=color.new(GRAPHITE, 0), text_color=cvdCol, text_size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(longEntry, "BEP Long Entry", "Bastion: Long entry signal")
alertcondition(shortEntry, "BEP Short Entry", "Bastion: Short entry signal")
alertcondition(regime != regime[1], "Regime Change", "Bastion: Market regime changed")
alertcondition(isCloseTime, "EOD Close", "Bastion: End of day close time")
alertcondition(bullPattern, "Bull Pattern", "Bastion: Bullish candle pattern detected")
alertcondition(bearPattern, "Bear Pattern", "Bastion: Bearish candle pattern detected")
alertcondition(currentDD > 10, "Drawdown Alert", "Bastion: Drawdown exceeds 10%")
````
