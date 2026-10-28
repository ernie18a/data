# Options Strategy V2.0

- url: https://www.tradingview.com/script/ct88NzIm-Options-Strategy-V2-0/
- type: strategy
- pine_id: PUB;b30a87fc1744486fad600e041f7b243f
- version: 1.0

## Description

📈 Options Strategy V2.0 – Intraday Reversal-Resilient Momentum System

Overview:
This strategy is designed specifically for intraday SPY, TSLA, MSFT, etc. options trading (0DTE or 1DTE), using high-probability signals derived from a confluence of technical indicators: EMA crossovers, RSI thresholds, ATR-based risk control, and volume spikes. The strategy aims to capture strong directional moves while avoiding overtrading, thanks to a built-in cooldown logic and optional time/session filters.
⚙️ Core Concept
The strategy executes trades only in the direction of the prevailing trend, determined by short- and long-term Exponential Moving Averages (EMA). Entry signals are generated when the Relative Strength Index (RSI) confirms momentum in the direction of the trend, and volume spikes suggest institutional activity.
To increase adaptability and user control, it includes a highly customizable parameter set for both long and short entries independently.

📌 Key Features
✅ Trend-Following Logic
Long entries are only allowed when EMA(short) > EMA(long)
Short entries are only allowed when EMA(short) < EMA(long)

✅ RSI Confirmation
Long: Requires RSI crossover above a configurable threshold
Short: Requires RSI crossunder below a configurable threshold
Optional rejection filters: Entry blocked above/below specific RSI extremes

✅ Volume Spike Filter
Confirms institutional participation by comparing current volume to an average multiplied by a user-defined factor.

✅ ATR-Based Risk Management
Both Stop Loss (SL) and Take Profit (TP) are dynamically calculated using ATR × a multiplier.
TP/SL ratio is fully configurable.

✅ Cooldown Control
After every trade, the system waits for a set number of bars before allowing new entries.
This prevents overtrading and increases signal quality.
Optionally, cooldown is ignored for reversal trades, ensuring the system can react immediately to a confirmed trend change.

✅ Candle Body Filter (Noise Control)
Avoids trades on candles with too small bodies relative to wicks (often noise or indecision candles).

✅ VWAP Confirmation (Optional)
Ensures price is trading above VWAP for long entries, or below for short entries.

✅ Time & Session Filters
Trades only during regular market hours (09:30–16:00 EST).
No-trade zone (e.g., 14:15–15:45 EST) to avoid low-liquidity traps or late-day whipsaws.

✅ End-of-Day Auto Close
All open positions are force-closed at 15:55 EST, protecting against overnight risk (especially relevant for 0DTE options).

📊 Visual Aids
EMA plots show trend direction
VWAP line provides real-time mean-reversion context
Stop Loss and Take Profit lines appear dynamically with each trade
Alerts notify of entry signals and exit triggers

🔧 Customization Panel
Nearly every element of the strategy can be tailored:
EMA lengths (short and long, for both sides)
RSI thresholds and length
ATR length, SL multiplier, and TP/SL ratio
Volume spike sensitivity
Minimum EMA distance filter
Candle body ratio filter
Session restrictions
Cooldown logic (duration + reversal exception)
This makes the strategy extremely versatile, allowing both conservative and aggressive configurations depending on the trader’s profile and the market context.

📌 Example Use Case: SPY Options (0DTE or 1DTE)
This system was designed and tested specifically for SPY and other intraday options trading, where:
Delta is around 0.50 or higher
Trades are short-lived (often 1–5 candles)
You aim to trade 1–3 signals per day, filtering out weak entries

🚫 Important Notes
It is not a scalping strategy; it relies on confirmed breakouts with trend support
No pyramiding or re-entries without cooldown to preserve risk integrity
Should be used with real-time alerts and manual broker execution 

📈 Alerts Included
📈 Long Entry Signal 
📉 Short Entry Signal

⚠️ Auto-closed all positions at 15:55 EST

✅ Proven Settings – Real Trades + Backtest Results
The current version of the strategy includes the optimal settings I’ve arrived at through extensive backtesting, as well as 3 months of real trading with consistent profitability. These results reflect real-world execution under live market conditions using 0DTE SPY options, with disciplined trade management and risk control.

🧠 Final Thoughts
Options Strategy V2.0  is a robust, highly tunable intraday strategy that blends momentum, trend-following, and volume confirmation. It is ideal for disciplined traders focused on SPY or other 0DTE/1DTE options, and it includes guardrails to reduce false signals and improve execution timing.

Perfect for those who seek precision, flexibility, and risk-defined setups—not blind automation.

## Source Code

````pine
// @version=5
strategy("Options Strategy V2.0", overlay=true, initial_capital=100000, 
     default_qty_type=strategy.percent_of_equity, default_qty_value=100, 
     commission_type=strategy.commission.percent, commission_value=0, 
     pyramiding=0, calc_on_every_tick=false, process_orders_on_close=true)

// === GENERAL INPUTS ===
enableEODClose     = input.bool(true,  "Auto-close at 15:55 EST?")
excludeFirst15min  = input.bool(false, "Exclude Trades from 09:30 to 09:45 EST")
enableVWAPFilter   = input.bool(false, "Require Price Over/Under VWAP?")
signalDir          = input.string("Both", "Signal Direction", options=["Long","Short","Both"])
noTradeSession     = input.session("1415-1545", "No-Trade Time")
cooldownBars       = input.int(1, "Cooldown Bars After Exit", minval=1)
ignoreCooldownOnReverse = input.bool(true, "Ignore Cooldown on Reversal Trades?")

// === FILTER CONTROLS ===
useCandleFilter    = input.bool(true,  "Enable Candle Body Filter?")
candleBodyFilter   = input.float(0.15, "Min Candle Body Size (%)", step=0.05)

// === LONG PARAMETERS ===
emaShortLongInput    = input.int(8,      "Long EMA Short Length")
emaLongLongInput     = input.int(23,     "Long EMA Long Length")
rsiLengthLongInput   = input.int(14,     "Long RSI Length")
rsiLongThreshLongIn  = input.int(50,     "Long RSI Min Threshold")
rsiMaxLongInput      = input.int(80,     "Long RSI Max Threshold (Do not fire if above)", minval=50, maxval=100)
atrLengthLongInput   = input.int(12,     "Long ATR Length")
slMultLongInput      = input.float(1.1,  "Long SL Multiplier (× ATR)")
tpSlRatioLongInput   = input.float(2.0,  "Long TP/SL Ratio")
lineExtendLongInput  = input.int(77,     "Long SL/TP Line Extend Bars")
volMaLenLongInput    = input.int(66,     "Long Volume MA Length")
volSpikeMultLong     = input.float(1.2,  "Long Volume Spike Multiplier", step=0.1, minval=0.1)
minEmaDistanceLong   = input.float(0.1,  "Long Min EMA Distance ($)", step=0.01)

// === SHORT PARAMETERS ===
emaShortShortInput    = input.int(8,      "Short EMA Short Length")
emaLongShortInput     = input.int(23,     "Short EMA Long Length")
rsiLengthShortInput   = input.int(14,     "Short RSI Length")
rsiShortThreshShortIn = input.int(39,     "Short RSI Max Threshold")
rsiMinShortInput      = input.int(20,     "Short RSI Min Threshold (Do not fire if below)", minval=0, maxval=39)
atrLengthShortInput   = input.int(12,     "Short ATR Length")
slMultShortInput      = input.float(1.1,  "Short SL Multiplier (× ATR)")
tpSlRatioShortInput   = input.float(2.0,  "Short TP/SL Ratio")
lineExtendShortInput  = input.int(77,     "Short SL/TP Line Extend Bars")
volMaLenShortInput    = input.int(66,     "Short Volume MA Length")
volSpikeMultShort     = input.float(1.2,  "Short Volume Spike Multiplier", step=0.1, minval=0.1)
minEmaDistanceShort   = input.float(0.1,  "Short Min EMA Distance ($)", step=0.01)

// === INDICATORS ===
candleBodyPct = math.abs(close - open) / (high - low + 0.0001)
candleOk = not useCandleFilter or (candleBodyPct >= candleBodyFilter)

emaShortLong = ta.ema(close, emaShortLongInput)
emaLongLong = ta.ema(close, emaLongLongInput)
rsiLong = ta.rsi(close, rsiLengthLongInput)
atrLong = ta.atr(atrLengthLongInput)
volMaLong = ta.sma(volume, volMaLenLongInput)
volSpikeLong = volume >= volMaLong * volSpikeMultLong
enoughSeparationLong = math.abs(emaShortLong - emaLongLong) >= minEmaDistanceLong

emaShortShort = ta.ema(close, emaShortShortInput)
emaLongShort = ta.ema(close, emaLongShortInput)
rsiShort = ta.rsi(close, rsiLengthShortInput)
atrShort = ta.atr(atrLengthShortInput)
volMaShort = ta.sma(volume, volMaLenShortInput)
volSpikeShort = volume >= volMaShort * volSpikeMultShort
enoughSeparationShort = math.abs(emaShortShort - emaLongShort) >= minEmaDistanceShort

vwapVal = ta.vwap
isTrendLong = emaShortLong > emaLongLong
isTrendShort = emaShortShort < emaLongShort

rsiCrossLong = ta.crossover(rsiLong, rsiLongThreshLongIn)
rsiAboveLong = rsiLong >= rsiLongThreshLongIn
rsiCrossShort = ta.crossunder(rsiShort, rsiShortThreshShortIn)
rsiBelowShort = rsiShort <= rsiShortThreshShortIn

isMarketOpen = not na(time(timeframe.period, "0930-1600", "America/New_York"))
inNoTrade = not na(time(timeframe.period, noTradeSession, "America/New_York"))
inExcludedWindow = excludeFirst15min and not na(time(timeframe.period, "0930-0945", "America/New_York"))

// === COOLDOWN HANDLING ===
var int cooldownUntilBar = na
var int lastTradeDir = na // 1 = long, -1 = short
if strategy.closedtrades > 0
    lastClosed = strategy.closedtrades - 1
    lastTradeDir := strategy.closedtrades.size(lastClosed) > 0 ? 1 : -1
    thisExitBar = strategy.closedtrades.exit_bar_index(lastClosed)
    if na(cooldownUntilBar) or thisExitBar > cooldownUntilBar - cooldownBars
        cooldownUntilBar := thisExitBar + cooldownBars

reversalPossible = ignoreCooldownOnReverse and ((lastTradeDir == 1 and isTrendShort and (rsiCrossShort or rsiBelowShort)) or (lastTradeDir == -1 and isTrendLong and (rsiCrossLong or rsiAboveLong)))

inCooldown = not reversalPossible and not na(cooldownUntilBar) and bar_index <= cooldownUntilBar

// === ENTRY SIGNALS ===
canEnterLong = signalDir != "Short" and isTrendLong and 
               (rsiCrossLong or (rsiAboveLong and not inCooldown)) and 
               rsiLong <= rsiMaxLongInput and 
               volSpikeLong and enoughSeparationLong and candleOk and 
               (not enableVWAPFilter or close > vwapVal)

canEnterShort = signalDir != "Long" and isTrendShort and (rsiCrossShort or (rsiBelowShort and not inCooldown)) and rsiShort >= rsiMinShortInput and volSpikeShort and enoughSeparationShort and candleOk and (not enableVWAPFilter or close < vwapVal)

// === SL/TP VARIABLES ===
var line slLine = na
var line tpLine = na
var float slVal = na
var float tpVal = na

// ⚠️ ================== ALERT SECTION 1 (Auto-Close) ==================
if enableEODClose
    nyHour = hour(time, "America/New_York")
    nyMinute = minute(time, "America/New_York")
    if nyHour == 15 and nyMinute == 55 and barstate.isconfirmed
        strategy.close_all()
        alert("⚠️ Auto-closed all positions at 15:55 EST", alert.freq_once_per_bar)

// === ENTRY CONDITIONS ===
if isMarketOpen and not inNoTrade and not inExcludedWindow and strategy.position_size == 0 and not inCooldown
    if canEnterLong
        if not na(slLine)
            line.delete(slLine)
        if not na(tpLine)
            line.delete(tpLine)
        strategy.entry("Long", strategy.long)
        // ⚠️ ================== ALERT SECTION 2 (LONG ENTRY) ==================
        alert("📈 LONG Entry Signal on SPY", alert.freq_once_per_bar)
        slVal := close - atrLong * slMultLongInput
        tpVal := close + atrLong * slMultLongInput * tpSlRatioLongInput
        slLine := line.new(bar_index, slVal, bar_index + lineExtendLongInput, slVal, extend=extend.none, color=color.red)
        tpLine := line.new(bar_index, tpVal, bar_index + lineExtendLongInput, tpVal, extend=extend.none, color=color.green)

    if canEnterShort
        if not na(slLine)
            line.delete(slLine)
        if not na(tpLine)
            line.delete(tpLine)
        strategy.entry("Short", strategy.short)
        // ⚠️ ================== ALERT SECTION 3 (SHORT ENTRY) ==================
        alert("📉 SHORT Entry Signal on SPY", alert.freq_once_per_bar)
        slVal := close + atrShort * slMultShortInput
        tpVal := close - atrShort * slMultShortInput * tpSlRatioShortInput
        slLine := line.new(bar_index, slVal, bar_index + lineExtendShortInput, slVal, extend=extend.none, color=color.red)
        tpLine := line.new(bar_index, tpVal, bar_index + lineExtendShortInput, tpVal, extend=extend.none, color=color.green)

strategy.exit("Exit Long", from_entry="Long", stop=slVal, limit=tpVal)
strategy.exit("Exit Short", from_entry="Short", stop=slVal, limit=tpVal)
// === END OF DAY CLOSE ===
if enableEODClose
    nyHour = hour(time, "America/New_York")
    nyMinute = minute(time, "America/New_York")
    if nyHour == 15 and nyMinute == 55 and barstate.isconfirmed
        strategy.close_all()

// === ENTRY CONDITIONS ===
if isMarketOpen and not inNoTrade and not inExcludedWindow and strategy.position_size == 0 and not inCooldown
    if canEnterLong
        if not na(slLine)
            line.delete(slLine)
        if not na(tpLine)
            line.delete(tpLine)
        strategy.entry("Long", strategy.long)
        slVal := close - atrLong * slMultLongInput
        tpVal := close + atrLong * slMultLongInput * tpSlRatioLongInput
        slLine := line.new(bar_index, slVal, bar_index + lineExtendLongInput, slVal, extend=extend.none, color=color.red)
        tpLine := line.new(bar_index, tpVal, bar_index + lineExtendLongInput, tpVal, extend=extend.none, color=color.green)

    if canEnterShort
        if not na(slLine)
            line.delete(slLine)
        if not na(tpLine)
            line.delete(tpLine)
        strategy.entry("Short", strategy.short)
        slVal := close + atrShort * slMultShortInput
        tpVal := close - atrShort * slMultShortInput * tpSlRatioShortInput
        slLine := line.new(bar_index, slVal, bar_index + lineExtendShortInput, slVal, extend=extend.none, color=color.red)
        tpLine := line.new(bar_index, tpVal, bar_index + lineExtendShortInput, tpVal, extend=extend.none, color=color.green)

strategy.exit("Exit Long", from_entry="Long", stop=slVal, limit=tpVal)
strategy.exit("Exit Short", from_entry="Short", stop=slVal, limit=tpVal)

// === PLOTS ===
plot(emaShortLong,  title="EMA Short (Long)",  color=color.orange, linewidth=2)
plot(emaLongLong,   title="EMA Long (Long)",   color=color.blue, linewidth=2)
plot(emaShortShort, title="EMA Short (Short)", color=color.new(color.orange, 50))
plot(emaLongShort,  title="EMA Long (Short)",  color=color.new(color.blue, 50))
plot(vwapVal,       title="VWAP", color=color.purple, linewidth=2)

// === ALERTS ===
alertcondition(canEnterLong, title="Long Entry", message="LONG signal triggered on SPY")
alertcondition(canEnterShort, title="Short Entry", message="SHORT signal triggered on SPY")
alertcondition(strategy.position_size == 0, title="Position Closed", message="Position closed on SPY")
````
