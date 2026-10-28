# PV: Perfect Signal - Advanced Trading System

- url: https://www.tradingview.com/script/7kEy3Apf-PV-Perfect-Signal-Advanced-Trading-System/
- type: indicator
- pine_id: PUB;39011b2d34ba4e04bb93e5b830b0c4a9
- version: 1.0

## Description

# Perfect Signal - Advanced Trading System Documentation

## Overview
A comprehensive Pine Script indicator for TradingView designed for both **intraday** and **swing trading**. This system combines institutional-level analysis with volume-centric decision-making to identify high-probability entry and exit points while filtering out fake moves and low-conviction signals.

---

## 🎯 Core Philosophy

### Volume-First Approach
The script prioritizes **volume analysis** as the primary confirmation factor. Price movements without volume support are flagged as fake moves and filtered out, preventing entries on dead-cat bounces or weak pullbacks.

### Multi-Timeframe Context
Supply and demand zones persist across **multiple days** (configurable 1-20 days), incorporating pre-market data to identify institutional levels that smart money respects over time.

### Smart Signal Filtering
- Avoids sideways/choppy markets using ADX
- Requires exceptional volume for counter-trend trades
- Detects volume divergence (price moves without volume)
- Implements momentum confirmation before entry

---

## 🔧 Key Features

### 1. Multi-Day Supply & Demand Zones
**What it does:**
- Identifies pivot highs (supply/resistance) and pivot lows (demand/support) over configurable lookback periods
- Tracks zones across multiple trading days with timestamps
- Automatically expires old zones based on persistence settings
- Distinguishes between "AT" zone and "NEAR" zone for early warnings

**Settings:**
- `Supply/Demand Zone Lookback`: 10 bars (how far back to look for pivots)
- `Zone Persistence (Days)`: 5 days (how long zones remain active)
- `Zone Test Count (Strength)`: 2 tests (minimum touches to validate zone)
- `Zone Tolerance %`: 1.5% (price proximity required)
- `Use Pre-Market Data`: Enabled (includes extended hours)

**Visual Indicators:**
- Red circles: Supply zones (resistance)
- Green circles: Demand zones (support)
- Dark background: Currently AT a zone
- Light background: NEAR a zone (approaching)

### 2. Institutional Activity Detection
**What it does:**
- Identifies "big candles" that are 1.8x larger than ATR
- Requires strong volume (2x normal spike) to confirm institutional participation
- Flags buying at demand zones and selling at supply zones
- Marks extreme volume bars with tiny circles

**Logic:**
```
Big Bull Candle = (Body > ATR * 1.8) AND (Close > Open) AND (Volume > MA * 2.0)
Institutional Buy = Big Bull Candle AT/NEAR Demand Zone
```

**Visual Indicators:**
- Bright green labels: Institutional buying (INST)
- Bright red labels: Institutional selling (INST)
- Lime/red circles: Extreme volume bars
- Orange labels: Counter-trend institutional trades (⚠️)

### 3. Volume Trend Analysis
**What it does:**
- Tracks volume trends over 3 consecutive bars
- Categorizes volume into three tiers: Spike (1.5x), Strong (2.0x), Extreme (3.0x)
- Detects volume divergence (price moves without volume support)
- Requires volume trending UP for V-shape recoveries

**Volume Tiers:**
- **Normal Spike**: 1.5x average volume
- **Strong Volume**: 2.0x average volume (required for most signals)
- **Extreme Volume**: 3.0x average volume (institutional level)

**Divergence Detection:**
- Compares 3-bar price change vs 3-bar average volume
- Flags as fake if price moves but volume < 80% of average
- Blocks all buy/sell signals during divergence
- Shows orange background warning

**Info Panel Display:**
- `1.5x⚡` = Extreme volume
- `1.5x↑` = Strong volume with uptrend
- `1.5x⚠️` = Volume divergence warning
- `Vol Trend: UP ↑` = Volume increasing over 3 bars

### 4. V-Shape Recovery Pattern
**What it does:**
- Detects sharp drops followed by strong recoveries (V-shape up)
- Detects sharp rallies followed by declines (inverse V-shape down)
- Requires RSI confirmation (oversold for buy, overbought for sell)
- Demands strong volume AND volume trending UP

**Buy Signal Requirements:**
- Price dropped at least 3% from recent high
- Recovered at least 1.8% from low
- RSI < 40 (but above extreme oversold 20)
- Strong volume (2.0x average)
- Volume trending UP over 3 bars
- No volume divergence detected

**Sell Signal Requirements:**
- Price rallied at least 3% from recent low
- Declined at least 1.8% from high
- RSI > 60 (but below extreme overbought 80)
- Strong volume (2.0x average)
- Volume trending UP over 3 bars
- No volume divergence detected

**Visual Indicators:**
- Label shows "V-REC" for recoveries
- Label shows "V-DEC" for declines
- Lightning bolt (⚡) for early entries

### 5. RSI Extreme Reversals
**What it does:**
- Catches reversals from extreme RSI levels (< 20 or > 80)
- Waits for momentum shift (2 consecutive bars)
- Requires strong volume confirmation
- Filters out moves with volume divergence

**Recovery Logic (Buy):**
- RSI was below 20 in last 3 bars
- RSI rising for 2 consecutive bars
- Strong volume present
- Price closing higher
- No volume divergence

**Decline Logic (Sell):**
- RSI was above 80 in last 3 bars
- RSI falling for 2 consecutive bars
- Strong volume present
- Price closing lower
- No volume divergence

### 6. Counter-Trend Protection
**What it does:**
- Identifies risky trades (buying in downtrend, selling in uptrend)
- Requires EXCEPTIONAL volume (2.5x average) for counter-trend entries
- Demands volume trending UP (not declining)
- Shows warning symbol (⚠️) on labels
- Uses orange color for counter-trend signals

**Logic:**
```
Counter-Trend Buy = Downtrend AND Bull Score >= 4 AND Volume > MA * 2.5 AND Vol Trend Up
Counter-Trend Sell = Uptrend AND Bear Score >= 4 AND Volume > MA * 2.5 AND Vol Trend Up
```

**Purpose:**
Prevents buying fake recoveries in downtrends or selling weak pullbacks in uptrends unless volume is exceptional, indicating real institutional interest.

### 7. Sideways Market Filter
**What it does:**
- Uses ADX (Average Directional Index) to measure trend strength
- Checks Bollinger Band width for consolidation
- Blocks all signals when market is choppy
- Shows gray background when sideways

**Filter Logic:**
```
Sideways = (ADX < 25) OR (BB Width < 3%)
No Signals Allowed When Sideways = True
```

**Settings:**
- `ADX Period`: 14 bars
- `ADX Threshold`: 25 (below = sideways)
- `Enable Sideways Filter`: True

### 8. Early Entry System
**What it does:**
- Bypasses normal 3-bar wait for strong signals
- Requires institutional or V-shape patterns
- Demands strong momentum and volume
- Allows entry after just 2 bars if conditions are exceptional

**Early Entry Criteria:**
- Institutional signal OR V-shape signal detected
- Strong momentum (price AND EMA rising/falling)
- Strong volume (2.0x average)
- No volume divergence
- Market trending (not sideways)
- For counter-trend: Requires EXTREME volume (3.0x)

**Visual Indicators:**
- Lightning bolt (⚡) added to signal label
- Shows "INST⚡" or "V-REC⚡"

---

## 📊 Scoring System

### Bullish Score (Max 10 points)
**Base Conditions (1 point each):**
1. **Uptrend**: EMA(9) > EMA(21) AND Close > EMA(50) AND SuperTrend bullish
2. **Price Strength**: Close > EMA(9) AND Close > VWAP
3. **Fresh Momentum**: EMA(9) crossing above EMA(21)
4. **Healthy RSI**: RSI between 50-70 (not overbought)
5. **Volume Confirmation**: Volume > 1.5x average AND no divergence
6. **Above Support**: Low > SuperTrend level

**Advanced Conditions (2 points each):**
7. **Institutional Buying**: Big candle at demand zone (2 points)
8. **V-Shape/RSI Recovery**: Strong recovery pattern (2 points)

### Bearish Score (Max 10 points)
**Base Conditions (1 point each):**
1. **Downtrend**: EMA(9) < EMA(21) AND Close < EMA(50) AND SuperTrend bearish
2. **Price Weakness**: Close < EMA(9) AND Close < VWAP
3. **Fresh Momentum Down**: EMA(9) crossing below EMA(21)
4. **Bearish RSI**: RSI between 30-50 (not oversold)
5. **Volume Confirmation**: Volume > 1.5x average AND no divergence
6. **Below Resistance**: High < SuperTrend level

**Advanced Conditions (2 points each):**
7. **Institutional Selling**: Big candle at supply zone (2 points)
8. **Inverse V-Shape/RSI Decline**: Strong decline pattern (2 points)

### Signal Generation
**Buy Signal:**
- Bull Score ≥ 4/10 (configurable)
- Bear Score < 3/10
- At least 3 bars since last signal
- Market trending (not sideways)
- No volume divergence
- Price AND EMA rising
- If counter-trend: Volume > 2.5x average

**Sell Signal:**
- Bear Score ≥ 4/10 (configurable)
- Bull Score < 3/10
- At least 3 bars since last signal
- Market trending (not sideways)
- No volume divergence
- Price AND EMA falling
- If counter-trend: Volume > 2.5x average

---

## 🎨 Visual System

### Chart Overlays
**Trend Lines:**
- Blue line: Fast EMA (9)
- Orange line: Slow EMA (21)
- Green/Red line: SuperTrend (3.0 multiplier, 10 ATR)
- Yellow dots: VWAP

**Supply/Demand:**
- Red circles: Supply zones (resistance)
- Green circles: Demand zones (support)

**Background Colors:**
- Dark red: AT supply zone
- Dark green: AT demand zone
- Light red: NEAR supply zone
- Light green: NEAR demand zone
- Gray: Sideways market
- Orange: Volume divergence warning

**Signal Labels:**
- Green arrows: BUY signals
- Red arrows: SELL signals
- Text shows reason: INST, V-REC, V-DEC, TREND
- Lightning bolt (⚡): Early entry
- Warning symbol (⚠️): Counter-trend

**Volume Markers:**
- Tiny lime circles: Extreme bullish volume
- Tiny red circles: Extreme bearish volume

### Info Panel (Top Right)
**14-row dashboard showing:**
1. **Trend**: UP ↑ / DN ↓ / FLAT →
2. **Price vs VWAP**: ABOVE / BELOW
3. **RSI**: Current value (colored by level)
4. **Volume**: Ratio with indicators (⚡↑⚠️)
5. **Market**: TRENDING / SIDEWAYS / NEUTRAL
6. **ADX**: Trend strength value
7. **Bull Score**: Current score out of 10
8. **Bear Score**: Current score out of 10
9. **Zone**: SUPPLY / DEMAND / ~SUPPLY / ~DEMAND / NONE
10. **Position**: LONG / SHORT / NONE (tracks last signal)
11. **Signal**: BUY / SELL / HOLD (current condition)
12. **ATR**: Average True Range value
13. **Vol Trend**: UP ↑ / DN ↓ / FLAT (3-bar trend)

---

## ⚙️ Configuration Guide

### For Intraday Trading (5min - 15min charts)
```
Fast EMA: 9
Slow EMA: 21
Trend Filter EMA: 50
Min Score: 4
Min Bars Between Signals: 3
Enable Early Entry: Yes
ADX Threshold: 20 (lower for intraday)
Volume Spike Multiplier: 1.5
Zone Persistence: 2 days
```

### For Swing Trading (1hr - Daily charts)
```
Fast EMA: 9
Slow EMA: 21
Trend Filter EMA: 50
Min Score: 5
Min Bars Between Signals: 5
Enable Early Entry: Yes
ADX Threshold: 25
Volume Spike Multiplier: 1.5
Zone Persistence: 5-10 days
```

### Conservative Settings (Fewer signals, higher quality)
```
Min Score: 6
Big Candle Size: 2.0x ATR
Volume Spike: 2.0x
Counter-Trend Volume: 3.0x
Zone Strength: 3 tests
Enable Sideways Filter: Yes
```

### Aggressive Settings (More signals, faster entries)
```
Min Score: 3
Big Candle Size: 1.5x ATR
Volume Spike: 1.3x
Counter-Trend Volume: 2.0x
Zone Strength: 1 test
Enable Early Entry: Yes
Min Bars Between Signals: 2
```

---

## 🔔 Alert System

### Primary Alerts
1. **Buy Signal**: Regular buy entry (score ≥ 4)
2. **Sell Signal**: Regular sell entry (score ≥ 4)
3. **Early Buy Entry**: Fast institutional/V-shape buy (⚡)
4. **Early Sell Entry**: Fast institutional/V-shape sell (⚡)

### Warning Alerts
5. **Counter-Trend Buy**: Buying in downtrend with exceptional volume (⚠️)
6. **Counter-Trend Sell**: Selling in uptrend with exceptional volume (⚠️)
7. **Volume Divergence Up**: Price rising without volume (fake move)
8. **Volume Divergence Down**: Price falling without volume (fake move)

### Information Alerts
9. **Institutional Buy**: Big candle at demand zone (🏦)
10. **Institutional Sell**: Big candle at supply zone (🏦)
11. **V-Shape Recovery**: Oversold bounce detected (📈)
12. **Inverse V-Shape**: Overbought decline detected (📉)

---

## 🎯 Trading Strategy Guide

### Entry Rules
**For Long (Buy):**
1. Wait for BUY signal label on chart
2. Verify bull score ≥ 4/10 in info panel
3. Confirm volume shows ↑ or ⚡ (not ⚠️)
4. Check market status is TRENDING (not SIDEWAYS)
5. Prefer signals at/near DEMAND zones
6. Look for INST or V-REC labels (stronger signals)
7. Be cautious with ⚠️ counter-trend signals

**For Short (Sell):**
1. Wait for SELL signal label on chart
2. Verify bear score ≥ 4/10 in info panel
3. Confirm volume shows ↑ or ⚡ (not ⚠️)
4. Check market status is TRENDING (not SIDEWAYS)
5. Prefer signals at/near SUPPLY zones
6. Look for INST or V-DEC labels (stronger signals)
7. Be cautious with ⚠️ counter-trend signals

### Exit Rules
**For Long Positions:**
- Exit on SELL signal (label shows "EXIT & SELL")
- Consider partial exit if entering SUPPLY zone
- Trail stop-loss below SuperTrend line
- Exit if volume divergence appears (orange background)
- Exit if market becomes SIDEWAYS for extended period

**For Short Positions:**
- Exit on BUY signal (label shows "EXIT & BUY")
- Consider partial exit if entering DEMAND zone
- Trail stop-loss above SuperTrend line
- Exit if volume divergence appears (orange background)
- Exit if market becomes SIDEWAYS for extended period

### Risk Management
**Stop-Loss Placement:**
- Long: Below recent demand zone or SuperTrend
- Short: Above recent supply zone or SuperTrend
- Use 1.5x ATR as minimum stop distance

**Position Sizing:**
- Regular signals (score 4-6): Standard position
- Strong signals (score 7-8): 1.5x position
- Institutional signals (score 9-10): 2x position
- Counter-trend signals (⚠️): 0.5x position (risky)

---

## 🚫 What to Avoid

### Don't Trade When:
1. **Orange background**: Volume divergence detected (fake move)
2. **Gray background**: Market is sideways/choppy
3. **Volume shows ⚠️**: Volume warning in info panel
4. **Market = SIDEWAYS**: Info panel shows sideways condition
5. **Score < 4**: Both bull and bear scores are low
6. **After hours**: Within 10 minutes of market open (optional setting)

### Be Cautious With:
1. **⚠️ Counter-trend signals**: Orange labels require exceptional volume
2. **Signals far from zones**: Prefer entries at/near supply/demand zones
3. **Low volume conditions**: Volume < 1.0x average
4. **Conflicting signals**: Bull score AND bear score both high
5. **Rapid signal changes**: Multiple signals in short time (increase min_bars)

---

## 🔍 Troubleshooting

### Too Many Signals
- Increase `Min Score` from 4 to 5 or 6
- Increase `Min Bars Between Signals` from 3 to 5
- Disable `Enable Early Entry`
- Increase `Volume Spike Multiplier` to 2.0
- Increase `Big Candle Size` to 2.0 or higher

### Too Few Signals
- Decrease `Min Score` from 4 to 3
- Decrease `Min Bars Between Signals` from 3 to 2
- Enable `Enable Early Entry`
- Decrease `Zone Strength` from 2 to 1
- Widen `Zone Tolerance %` from 1.5% to 2.0%

### False Signals
- Enable `Sideways Filter` if disabled
- Increase `ADX Threshold` from 25 to 30
- Increase `Counter-Trend Volume Required` from 2.5x to 3.0x
- Increase `Zone Strength` from 2 to 3
- Check that `Volume Trend Bars` is set to 3

### Missing Good Trades
- Decrease `Min Score` to 3
- Enable `Enable Early Entry`
- Decrease `Big Candle Size` to 1.5x
- Increase `Zone Persistence` to 10 days
- Decrease `Min Bars Between Signals` to 2

---

## 📈 Best Practices

1. **Confirm with higher timeframe**: Check daily chart for overall trend
2. **Wait for volume**: Never trade without volume confirmation
3. **Respect the zones**: Best signals occur at supply/demand levels
4. **Watch for divergence**: Orange backgrounds are warnings, not entries
5. **Use multiple confirmations**: Prefer signals with high scores (7-10)
6. **Be patient**: Quality over quantity - wait for clear setups
7. **Manage risk**: Always use stop-losses based on ATR or zones
8. **Track performance**: Monitor which signal types work best for your style

---

## 📝 Technical Notes

### Performance Optimization
- Script uses arrays for zone storage (max 30 zones)
- Zones automatically expire after persistence period
- Volume calculations cached for efficiency
- Visual elements are conditional (can be hidden)

### Pine Script Version
- Written in Pine Script v6
- Compatible with TradingView Premium/Pro
- Requires `max_labels_count=500` and `max_lines_count=500`

### Data Requirements
- Works on any timeframe (tested 5min to Daily)
- Requires volume data (won't work on Heikin Ashi without volume)
- Pre-market data optional (enabled by default)
- Historical data needed for zone persistence

---

## 🎓 Understanding the Signals

### Signal Label Legend
- **TREND**: Basic trend-following signal (6 base conditions met)
- **INST**: Institutional activity at zone (big candle + volume)
- **V-REC**: V-shape recovery pattern (oversold bounce)
- **V-DEC**: Inverse V-shape decline (overbought drop)
- **⚡**: Early entry (bypass normal wait time)
- **⚠️**: Counter-trend warning (risky trade)

### Score Interpretation
- **3-4**: Marginal signal, wait for confirmation
- **5-6**: Good signal, standard entry
- **7-8**: Strong signal, increase position size
- **9-10**: Exceptional signal, maximum conviction

### Volume Interpretation
- **1.0x**: Below average, avoid trading
- **1.5x**: Spike, minimum for entry
- **2.0x↑**: Strong, ideal for entries
- **3.0x⚡**: Extreme, institutional level
- **⚠️**: Divergence, fake move detected

---

## 💡 Tips for Success

1. **Start conservative**: Begin with min_score=5 and adjust down if needed
2. **Backtest first**: Test on historical data before live trading
3. **Use with other tools**: Combine with your existing analysis
4. **Adapt to market**: Adjust settings for current volatility
5. **Trust the volume**: When volume says no, don't trade
6. **Respect the zones**: Best trades happen at key levels
7. **Keep it simple**: Don't override too many signals manually
8. **Review performance**: Track which patterns work best for you

---

## 📧 Support & Questions

This indicator is designed to be self-contained and comprehensive. All logic is transparent and documented within the code comments. Modify settings to match your trading style and risk tolerance.

**Remember**: No indicator is perfect. Always use proper risk management and combine technical analysis with fundamental research.

---

*Version: 2.0 - Volume-Centric Advanced Trading System*
*Last Updated: 2026*

## Source Code

````pine
//@version=6
indicator("Perfect Signal - Advanced Trading System", shorttitle="Perfect Signal v2", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================================
// TRADING STRATEGY
// ============================================================================
// This system generates BUY/SELL signals for both:
// 1. INTRADAY: Enter and exit same day based on momentum
// 2. SWING: Hold positions for multiple days when trend continues
// 
// NEW FEATURES:
// - Multi-Day Supply & Demand Zones: Tracks zones across multiple days (configurable persistence)
// - Pre-Market Data Support: Uses extended hours for better zone identification
// - Big Candle Detection: Spots institutional buying/selling with strong volume
// - V-Shape Recovery: Identifies oversold bounces with volume confirmation
// - RSI Extreme Conditions: Catches extreme reversals with volume
// - Sideways Filter: Avoids choppy markets (ADX-based)
// - Early Entry: Fast signals on strong institutional/V-shape setups
// - Near Zone Detection: Catches action approaching key levels
// 
// VOLUME-CENTRIC APPROACH:
// - Volume Trend Analysis: Multi-bar volume trends (increasing/decreasing)
// - Volume Divergence Detection: Warns when price moves without volume support (FAKE moves)
// - Counter-Trend Protection: Requires 2.5x volume for buying in downtrends or selling in uptrends
// - Strong Volume Tiers: Normal spike (1.5x), Strong (2x), Extreme (3x)
// - Filters fake recoveries and small pullbacks without volume confirmation
// 
// OPTIMIZATIONS FOR FASTER SIGNALS:
// - Relaxed momentum confirmation (1 bar vs 3 bars)
// - Reduced min bars between signals (3 vs 5)
// - Wider zone tolerance (1.5% configurable)
// - Early entry mode for strong signals
// - More responsive V-shape detection
// 
// Signals wait 10 minutes after market open (9:40 AM) to avoid volatility
// Each day is analyzed independently for fresh opportunities
// BUY = Enter Long (hold hours or days until SELL signal)
// SELL = Exit Long or Enter Short position
// ============================================================================

// ============================================================================
// INPUT PARAMETERS
// ============================================================================

// Trend Indicators
ema_fast = input.int(9, "Fast EMA", minval=1, group="Trend Analysis")
ema_slow = input.int(21, "Slow EMA", minval=1, group="Trend Analysis")
ema_filter = input.int(50, "Trend Filter EMA", minval=1, group="Trend Analysis")
st_atr = input.int(10, "SuperTrend ATR Period", minval=1, group="Trend Analysis")
st_mult = input.float(3.0, "SuperTrend Multiplier", minval=0.1, step=0.1, group="Trend Analysis")

// Momentum & Volume
rsi_period = input.int(14, "RSI Period", minval=1, group="Momentum & Volume")
rsi_ob = input.float(70, "RSI Overbought", minval=50, maxval=90, group="Momentum & Volume")
rsi_os = input.float(30, "RSI Oversold", minval=10, maxval=50, group="Momentum & Volume")
rsi_extreme_ob = input.float(80, "RSI Extreme Overbought", minval=70, maxval=95, group="Momentum & Volume")
rsi_extreme_os = input.float(20, "RSI Extreme Oversold", minval=5, maxval=30, group="Momentum & Volume")
vol_period = input.int(20, "Volume MA Period", minval=1, group="Momentum & Volume")
vol_mult = input.float(1.5, "Volume Spike Multiplier", minval=1.0, step=0.1, group="Momentum & Volume")
vol_trend_bars = input.int(3, "Volume Trend Bars", minval=2, maxval=10, group="Momentum & Volume", tooltip="Check volume trend over multiple bars")
vol_counter_trend_mult = input.float(2.5, "Counter-Trend Volume Required", minval=2.0, maxval=5.0, step=0.1, group="Momentum & Volume", tooltip="Higher volume needed for counter-trend signals")

// Supply & Demand Zones
pivot_lookback = input.int(10, "Supply/Demand Zone Lookback", minval=5, maxval=50, group="Supply & Demand")
zone_days_persist = input.int(5, "Zone Persistence (Days)", minval=1, maxval=20, group="Supply & Demand", tooltip="Keep zones active for multiple days")
zone_strength = input.int(2, "Zone Test Count (Strength)", minval=1, maxval=10, group="Supply & Demand", tooltip="Number of times price must test a zone")
zone_tolerance_pct = input.float(1.5, "Zone Tolerance %", minval=0.5, maxval=3.0, step=0.1, group="Supply & Demand", tooltip="How close price needs to be to zone")
big_candle_mult = input.float(1.8, "Big Candle Size (ATR Multiple)", minval=1.2, maxval=5.0, step=0.1, group="Supply & Demand")
use_extended_hours = input.bool(true, "Use Pre-Market Data", group="Supply & Demand", tooltip="Include pre-market/after-hours for zones")

// V-Shape Recovery
v_lookback = input.int(5, "V-Shape Lookback Bars", minval=3, maxval=20, group="V-Shape Pattern")
v_recovery_pct = input.float(3.0, "V-Recovery Threshold %", minval=1.0, maxval=10.0, step=0.5, group="V-Shape Pattern")

// Sideways Detection
adx_period = input.int(14, "ADX Period (Trend Strength)", minval=7, maxval=30, group="Sideways Filter")
adx_threshold = input.float(25, "ADX Threshold", minval=15, maxval=40, step=1, group="Sideways Filter", tooltip="Below this = sideways market")
enable_sideways_filter = input.bool(true, "Enable Sideways Filter", group="Sideways Filter")

// Signal Quality Control
min_score = input.int(4, "Minimum Score for Signal", minval=3, maxval=10, group="Signal Settings", tooltip="Higher = fewer but better signals")
min_bars = input.int(3, "Min Bars Between Signals", minval=1, maxval=20, group="Signal Settings")
enable_early_entry = input.bool(true, "Enable Early Entry (Strong Signals)", group="Signal Settings", tooltip="Allow immediate entry on institutional/V-shape signals")
avoid_open = input.bool(true, "Avoid First 10 Min After Market Open", group="Signal Settings", tooltip="No signals before 9:40 AM EST")
market_open_time = input.int(930, "Market Open Time", minval=0, maxval=2359, group="Signal Settings", tooltip="Default: 930 = 9:30 AM")
wait_minutes = input.int(10, "Wait Minutes After Open", minval=5, maxval=60, group="Signal Settings")

// Display Options
show_trend = input.bool(true, "Show Trend Lines", group="Display")
show_signals = input.bool(true, "Show Buy/Sell Labels", group="Display")
show_levels = input.bool(true, "Show Supply/Demand Zones", group="Display")
show_info = input.bool(true, "Show Info Panel", group="Display")


// ============================================================================
// CORE INDICATORS
// ============================================================================

// Trend Detection
ema_f = ta.ema(close, ema_fast)
ema_s = ta.ema(close, ema_slow)
ema_trend = ta.ema(close, ema_filter)
[supertrend, direction] = ta.supertrend(st_mult, st_atr)
vwap = ta.vwap(close)

// Momentum & Volume
rsi = ta.rsi(close, rsi_period)
vol_ma = ta.sma(volume, vol_period)
atr = ta.atr(14)

// Volume Analysis - Multi-bar trends and divergence
vol_trend_up = true
vol_trend_down = true
for i = 1 to vol_trend_bars - 1
    vol_trend_up := vol_trend_up and volume > volume[i]
    vol_trend_down := vol_trend_down and volume < volume[i]

// Volume confirmation levels
vol_spike = volume > vol_ma * vol_mult
vol_strong = volume > vol_ma * (vol_mult * 1.3)  // 1.3x the normal spike
vol_extreme = volume > vol_ma * (vol_mult * 2.0)  // 2x the normal spike

// Volume divergence - price moves without volume support (FAKE moves)
price_up_3bar = close > close[3]
price_down_3bar = close < close[3]
avg_vol_3bar = (volume + volume[1] + volume[2]) / 3
vol_divergence_up = price_up_3bar and avg_vol_3bar < vol_ma * 0.8  // Price up but volume declining
vol_divergence_down = price_down_3bar and avg_vol_3bar < vol_ma * 0.8  // Price down but volume declining

// Session Analysis - Track new trading day for signal reset
session_start = ta.change(time("D")) != 0

// Time Filter - Avoid opening volatility
current_mins = hour * 60 + minute
market_open_mins = math.floor(market_open_time / 100) * 60 + (market_open_time % 100)
mins_since_open = current_mins - market_open_mins
trading_allowed = not avoid_open or mins_since_open >= wait_minutes

// Trend Confirmation
uptrend = ema_f > ema_s and close > ema_trend and direction < 0
downtrend = ema_f < ema_s and close < ema_trend and direction > 0

// ============================================================================
// SUPPLY & DEMAND ZONES - Institutional Levels
// ============================================================================

// Identify pivot highs and lows for supply/demand zones
pivot_high = ta.pivothigh(high, pivot_lookback, pivot_lookback)
pivot_low = ta.pivotlow(low, pivot_lookback, pivot_lookback)

// Store recent supply and demand zones with timestamps for persistence
var float[] supply_zones = array.new_float(0)
var float[] demand_zones = array.new_float(0)
var int[] supply_tests = array.new_int(0)
var int[] demand_tests = array.new_int(0)
var int[] supply_time = array.new_int(0)  // Track when zone was created
var int[] demand_time = array.new_int(0)  // Track when zone was created

// Days in milliseconds for zone expiry
zone_expiry_ms = zone_days_persist * 24 * 60 * 60 * 1000

// Add new supply zone when pivot high is detected
if not na(pivot_high)
    array.push(supply_zones, pivot_high)
    array.push(supply_tests, 0)
    array.push(supply_time, time)
    // Keep only recent 30 zones (increased for multi-day tracking)
    if array.size(supply_zones) > 30
        array.shift(supply_zones)
        array.shift(supply_tests)
        array.shift(supply_time)

// Add new demand zone when pivot low is detected
if not na(pivot_low)
    array.push(demand_zones, pivot_low)
    array.push(demand_tests, 0)
    array.push(demand_time, time)
    // Keep only recent 30 zones (increased for multi-day tracking)
    if array.size(demand_zones) > 30
        array.shift(demand_zones)
        array.shift(demand_tests)
        array.shift(demand_time)

// Check if current price is near a zone (configurable tolerance)
zone_tolerance = close * (zone_tolerance_pct / 100)

// Find nearest supply zone (only use zones within persistence period)
var float nearest_supply = na
var int supply_test_count = 0
nearest_supply_distance = 9999999.0
if array.size(supply_zones) > 0
    for i = 0 to array.size(supply_zones) - 1
        zone_time_created = array.get(supply_time, i)
        // Check if zone is still valid (within persistence period)
        if time - zone_time_created <= zone_expiry_ms
            zone_price = array.get(supply_zones, i)
            distance = math.abs(close - zone_price)
            if distance < nearest_supply_distance
                nearest_supply_distance := distance
                nearest_supply := zone_price
                supply_test_count := array.get(supply_tests, i)
                // Increment test count if price is testing this zone
                if distance < zone_tolerance and close < zone_price * 1.02
                    array.set(supply_tests, i, supply_test_count + 1)

// Find nearest demand zone (only use zones within persistence period)
var float nearest_demand = na
var int demand_test_count = 0
nearest_demand_distance = 9999999.0
if array.size(demand_zones) > 0
    for i = 0 to array.size(demand_zones) - 1
        zone_time_created = array.get(demand_time, i)
        // Check if zone is still valid (within persistence period)
        if time - zone_time_created <= zone_expiry_ms
            zone_price = array.get(demand_zones, i)
            distance = math.abs(close - zone_price)
            if distance < nearest_demand_distance
                nearest_demand_distance := distance
                nearest_demand := zone_price
                demand_test_count := array.get(demand_tests, i)
                // Increment test count if price is testing this zone
                if distance < zone_tolerance and close > zone_price * 0.98
                    array.set(demand_tests, i, demand_test_count + 1)

// Check if at supply or demand zone (using tolerance)
zone_pct = zone_tolerance_pct / 100
at_supply_zone = not na(nearest_supply) and close >= nearest_supply * (1 - zone_pct) and close <= nearest_supply * (1 + zone_pct) and supply_test_count >= zone_strength
at_demand_zone = not na(nearest_demand) and close <= nearest_demand * (1 + zone_pct) and close >= nearest_demand * (1 - zone_pct) and demand_test_count >= zone_strength

// Near zones (approaching) - for early detection
near_supply_zone = not na(nearest_supply) and close >= nearest_supply * (1 - zone_pct * 1.5) and close <= nearest_supply * (1 + zone_pct * 0.5)
near_demand_zone = not na(nearest_demand) and close <= nearest_demand * (1 + zone_pct * 1.5) and close >= nearest_demand * (1 - zone_pct * 0.5)

// ============================================================================
// BIG CANDLE DETECTION - Institutional Activity
// ============================================================================

// Calculate candle body size
candle_body = math.abs(close - open)
candle_range = high - low

// Big candle = body is larger than ATR * multiplier
is_big_candle = candle_body > atr * big_candle_mult

// Bullish big candle (green/white) - requires strong volume
big_bull_candle = is_big_candle and close > open and vol_strong

// Bearish big candle (red/black) - requires strong volume
big_bear_candle = is_big_candle and close < open and vol_strong

// Institutional buying at demand zone (including approaching zone)
institutional_buy = (at_demand_zone or near_demand_zone) and big_bull_candle

// Institutional selling at supply zone (including approaching zone)
institutional_sell = (at_supply_zone or near_supply_zone) and big_bear_candle

// ============================================================================
// V-SHAPE RECOVERY DETECTION - Oversold Bounces
// ============================================================================

// Calculate price change over lookback period
price_change_pct = ((close - close[v_lookback]) / close[v_lookback]) * 100

// Find the lowest point in the lookback period
lowest_in_period = ta.lowest(low, v_lookback)
highest_in_period = ta.highest(high, v_lookback)

// V-shape up: Price dropped significantly, then recovered with volume
drop_from_high = ((close - highest_in_period) / highest_in_period) * 100
recovery_from_low = ((close - lowest_in_period) / lowest_in_period) * 100

// Conditions for V-shape recovery (buy signal) - STRONG volume confirmation required
v_shape_down_occurred = drop_from_high < -v_recovery_pct  // Dropped at least threshold
v_shape_recovery = recovery_from_low > v_recovery_pct * 0.6 and rsi < 40 and rsi > rsi_extreme_os  // Recovering from low
v_shape_volume = vol_strong and vol_trend_up  // Strong volume AND increasing

// More responsive - check if drop occurred within lookback window, not exactly at that bar
v_shape_buy = v_shape_recovery and v_shape_volume and close > close[1] and drop_from_high < -v_recovery_pct and not vol_divergence_up

// Inverse V-shape (sell signal): Price rallied significantly, then dropped with volume
rise_from_low = ((close - lowest_in_period) / lowest_in_period) * 100
decline_from_high = ((close - highest_in_period) / highest_in_period) * 100

// Conditions for inverse V-shape (sell signal) - STRONG volume confirmation required
inv_v_shape_up_occurred = rise_from_low > v_recovery_pct  // Rallied at least threshold
inv_v_shape_decline = decline_from_high < -v_recovery_pct * 0.6 and rsi > 60 and rsi < rsi_extreme_ob  // Declining from high
inv_v_shape_volume = vol_strong and vol_trend_up  // Strong volume AND increasing

// More responsive - check if rise occurred within lookback window, not exactly at that bar
inv_v_shape_sell = inv_v_shape_decline and inv_v_shape_volume and close < close[1] and rise_from_low > v_recovery_pct and not vol_divergence_down

// ============================================================================
// RSI EXTREME CONDITIONS WITH RECOVERY
// ============================================================================

// RSI was extremely oversold and now showing recovery - needs STRONG volume
rsi_was_extreme_os = rsi[1] < rsi_extreme_os or rsi[2] < rsi_extreme_os or rsi[3] < rsi_extreme_os
rsi_recovering = rsi > rsi[1] and rsi[1] > rsi[2]  // RSI rising for 2 bars
rsi_recovery_signal = rsi_was_extreme_os and rsi_recovering and vol_strong and close > close[1] and not vol_divergence_up

// RSI was extremely overbought and now showing decline - needs STRONG volume
rsi_was_extreme_ob = rsi[1] > rsi_extreme_ob or rsi[2] > rsi_extreme_ob or rsi[3] > rsi_extreme_ob
rsi_declining = rsi < rsi[1] and rsi[1] < rsi[2]  // RSI falling for 2 bars
rsi_decline_signal = rsi_was_extreme_ob and rsi_declining and vol_strong and close < close[1] and not vol_divergence_down

// ============================================================================
// SIDEWAYS MARKET DETECTION - Avoid Choppy Conditions
// ============================================================================

// Calculate ADX (Average Directional Index) - measures trend strength
[diPlus, diMinus, adx] = ta.dmi(adx_period, adx_period)

// Market is trending when ADX is above threshold
is_trending = adx > adx_threshold

// Alternative: Bollinger Band width check for consolidation
bb_basis = ta.sma(close, 20)
bb_dev = ta.stdev(close, 20)
bb_upper = bb_basis + 2 * bb_dev
bb_lower = bb_basis - 2 * bb_dev
bb_width_pct = ((bb_upper - bb_lower) / bb_basis) * 100

// Sideways when BB width is narrow or ADX is low
is_sideways = bb_width_pct < 3 or (enable_sideways_filter and not is_trending)

// ============================================================================
// COMBINED ADVANCED SIGNALS
// ============================================================================

// Enhanced buy conditions with new logic
institutional_buy_signal = institutional_buy and not is_sideways
v_recovery_buy_signal = (v_shape_buy or rsi_recovery_signal) and not is_sideways

// Enhanced sell conditions with new logic
institutional_sell_signal = institutional_sell and not is_sideways
v_decline_sell_signal = (inv_v_shape_sell or rsi_decline_signal) and not is_sideways

// ============================================================================
// SIGNAL SCORING - Enhanced with Advanced Conditions
// ============================================================================

// BULLISH Conditions (1 point each + advanced signals worth 2 points)
bull_trend = uptrend                                    // Strong uptrend
bull_price = close > ema_f and close > vwap            // Price strength
bull_cross = ta.crossover(ema_f, ema_s)                // Fresh momentum
bull_rsi = rsi > 50 and rsi < rsi_ob                   // Healthy momentum
bull_volume = vol_spike and not vol_divergence_up      // Volume confirmation WITHOUT divergence
bull_support = low > supertrend                        // Above support
bull_institutional = institutional_buy_signal          // Institutional buying (2 points)
bull_v_recovery = v_recovery_buy_signal                // V-shape or RSI recovery (2 points)

bull_score = (bull_trend ? 1 : 0) + (bull_price ? 1 : 0) + (bull_cross ? 1 : 0) + 
             (bull_rsi ? 1 : 0) + (bull_volume ? 1 : 0) + (bull_support ? 1 : 0) +
             (bull_institutional ? 2 : 0) + (bull_v_recovery ? 2 : 0)

// BEARISH Conditions (1 point each + advanced signals worth 2 points)
bear_trend = downtrend                                  // Strong downtrend
bear_price = close < ema_f and close < vwap            // Price weakness
bear_cross = ta.crossunder(ema_f, ema_s)               // Fresh momentum down
bear_rsi = rsi < 50 and rsi > rsi_os                   // Bearish momentum
bear_volume = vol_spike and not vol_divergence_down    // Volume confirmation WITHOUT divergence
bear_resistance = high < supertrend                    // Below resistance
bear_institutional = institutional_sell_signal         // Institutional selling (2 points)
bear_v_decline = v_decline_sell_signal                 // Inverse V or RSI decline (2 points)

bear_score = (bear_trend ? 1 : 0) + (bear_price ? 1 : 0) + (bear_cross ? 1 : 0) + 
             (bear_rsi ? 1 : 0) + (bear_volume ? 1 : 0) + (bear_resistance ? 1 : 0) +
             (bear_institutional ? 2 : 0) + (bear_v_decline ? 2 : 0)

// ============================================================================
// SIGNAL GENERATION - Only Alert on Direction Change
// ============================================================================

var int last_signal = 0
var string last_direction = "NONE"  // Track last signal direction
bars_passed = bar_index - last_signal

// Reset direction at start of each new day
if session_start
    last_direction := "NONE"
    last_signal := bar_index

// Momentum confirmation - relaxed for faster signals
ema9_rising = ema_f > ema_f[1]  // Just needs to be rising now (was requiring 3 bars)
ema9_falling = ema_f < ema_f[1]  // Just needs to be falling now
price_rising = close > close[1]
price_falling = close < close[1]

// Strong momentum for early entry - requires strong volume and no divergence
strong_momentum_up = ema9_rising and price_rising and close > open and vol_strong and not vol_divergence_up
strong_momentum_down = ema9_falling and price_falling and close < open and vol_strong and not vol_divergence_down

// Counter-trend detection - buying in downtrend or selling in uptrend (risky)
is_counter_trend_buy = downtrend and bull_score >= min_score
is_counter_trend_sell = uptrend and bear_score >= min_score

// Counter-trend trades need EXCEPTIONAL volume (2.5x or more)
counter_trend_vol_ok_buy = volume > vol_ma * vol_counter_trend_mult and vol_trend_up
counter_trend_vol_ok_sell = volume > vol_ma * vol_counter_trend_mult and vol_trend_up

// Quality filter: minimum score + time spacing + trading time + DIRECTIONAL MOMENTUM + NOT SIDEWAYS + VOLUME RULES
// For counter-trend: require exceptional volume, otherwise skip (avoid fake recoveries/pullbacks)
buy_condition = bull_score >= min_score and bars_passed >= min_bars and bear_score < 3 and trading_allowed and ema9_rising and price_rising and not is_sideways and not vol_divergence_up and (not is_counter_trend_buy or counter_trend_vol_ok_buy)
sell_condition = bear_score >= min_score and bars_passed >= min_bars and bull_score < 3 and trading_allowed and ema9_falling and price_falling and not is_sideways and not vol_divergence_down and (not is_counter_trend_sell or counter_trend_vol_ok_sell)

// Early entry conditions - bypass min_bars requirement for strong signals with EXCEPTIONAL volume
// Counter-trend early entries require even higher volume confirmation
early_buy = enable_early_entry and (institutional_buy_signal or v_recovery_buy_signal) and strong_momentum_up and not is_sideways and trading_allowed and last_direction != "BUY" and bars_passed >= 2 and not vol_divergence_up and (not is_counter_trend_buy or vol_extreme)
early_sell = enable_early_entry and (institutional_sell_signal or v_decline_sell_signal) and strong_momentum_down and not is_sideways and trading_allowed and last_direction != "SELL" and bars_passed >= 2 and not vol_divergence_down and (not is_counter_trend_sell or vol_extreme)

// Trigger on direction change OR early entry
buy_signal = (buy_condition and not buy_condition[1] and last_direction != "BUY") or early_buy
sell_signal = (sell_condition and not sell_condition[1] and last_direction != "SELL") or early_sell

// Update tracking when signals fire
if buy_signal
    last_signal := bar_index
    last_direction := "BUY"

if sell_signal
    last_signal := bar_index
    last_direction := "SELL"


// ============================================================================
// VISUAL DISPLAY
// ============================================================================

// Trend Lines
trend_color = uptrend ? color.new(color.green, 0) : downtrend ? color.new(color.red, 0) : color.new(color.gray, 50)
plot(show_trend ? ema_f : na, "Fast EMA", color=color.new(color.blue, 0), linewidth=2)
plot(show_trend ? ema_s : na, "Slow EMA", color=color.new(color.orange, 0), linewidth=2)
plot(show_trend ? supertrend : na, "SuperTrend", color=trend_color, linewidth=3)
plot(show_trend ? vwap : na, "VWAP", color=color.new(color.yellow, 30), linewidth=1, style=plot.style_circles)

// Supply and Demand Zones
plot(show_levels and not na(nearest_supply) ? nearest_supply : na, "Supply Zone", color=color.new(color.red, 70), linewidth=2, style=plot.style_circles)
plot(show_levels and not na(nearest_demand) ? nearest_demand : na, "Demand Zone", color=color.new(color.green, 70), linewidth=2, style=plot.style_circles)

// Background highlights
bgcolor(at_supply_zone ? color.new(color.red, 90) : na, title="At Supply Zone")
bgcolor(at_demand_zone ? color.new(color.green, 90) : na, title="At Demand Zone")
bgcolor(near_supply_zone and not at_supply_zone ? color.new(color.red, 97) : na, title="Near Supply Zone")
bgcolor(near_demand_zone and not at_demand_zone ? color.new(color.green, 97) : na, title="Near Demand Zone")
bgcolor(is_sideways ? color.new(color.gray, 98) : na, title="Sideways Market")
bgcolor(vol_divergence_up ? color.new(color.orange, 98) : na, title="Volume Divergence Up")
bgcolor(vol_divergence_down ? color.new(color.orange, 98) : na, title="Volume Divergence Down")

// BUY/SELL Text on Candles
plotchar(show_signals and buy_signal, "Buy", "BUY", location.belowbar, color=color.new(color.green, 0), size=size.small, text="BUY")
plotchar(show_signals and sell_signal, "Sell", "SELL", location.abovebar, color=color.new(color.red, 0), size=size.small, text="SELL")

// Volume markers for extreme volume bars (institutional activity)
plotshape(vol_extreme and close > open, "Extreme Vol Up", shape.circle, location.belowbar, color.new(color.lime, 50), size=size.tiny)
plotshape(vol_extreme and close < open, "Extreme Vol Down", shape.circle, location.abovebar, color.new(color.red, 50), size=size.tiny)

// Buy Signals - Labels with signal reason and counter-trend warning
if show_signals and buy_signal
    signal_reason = ""
    is_early = early_buy
    if institutional_buy_signal
        signal_reason := is_early ? "INST⚡" : "INST"
    else if v_recovery_buy_signal
        signal_reason := is_early ? "V-REC⚡" : "V-REC"
    else
        signal_reason := "TREND"
    
    // Add warning if counter-trend (buying in downtrend)
    if is_counter_trend_buy
        signal_reason := signal_reason + "⚠️"
    
    buy_label_text = last_direction[1] == "SELL" ? "EXIT & BUY\n" + signal_reason + " " + str.tostring(bull_score) + "/10" : "BUY\n" + signal_reason + " " + str.tostring(bull_score) + "/10"
    label.new(bar_index, low - atr * 0.3, buy_label_text, 
              style=label.style_label_up, 
              color=institutional_buy_signal ? color.new(#00FF00, 0) : is_counter_trend_buy ? color.new(color.orange, 0) : color.new(color.green, 0), 
              textcolor=color.white, 
              size=size.small)
    if show_levels
        line.new(bar_index, low - atr * 1.5, bar_index + 10, low - atr * 1.5, 
                 color=color.new(color.red, 40), style=line.style_dashed, width=1)

// Sell Signals - Labels with signal reason and counter-trend warning
if show_signals and sell_signal
    signal_reason = ""
    is_early = early_sell
    if institutional_sell_signal
        signal_reason := is_early ? "INST⚡" : "INST"
    else if v_decline_sell_signal
        signal_reason := is_early ? "V-DEC⚡" : "V-DEC"
    else
        signal_reason := "TREND"
    
    // Add warning if counter-trend (selling in uptrend)
    if is_counter_trend_sell
        signal_reason := signal_reason + "⚠️"
    
    sell_label_text = last_direction[1] == "BUY" ? "EXIT & SELL\n" + signal_reason + " " + str.tostring(bear_score) + "/10" : "SELL\n" + signal_reason + " " + str.tostring(bear_score) + "/10"
    label.new(bar_index, high + atr * 0.3, sell_label_text, 
              style=label.style_label_down, 
              color=institutional_sell_signal ? color.new(#FF0000, 0) : is_counter_trend_sell ? color.new(color.orange, 0) : color.new(color.red, 0), 
              textcolor=color.white, 
              size=size.small)
    if show_levels
        line.new(bar_index, high + atr * 1.5, bar_index + 10, high + atr * 1.5, 
                 color=color.new(color.red, 40), style=line.style_dashed, width=1)

// ============================================================================
// INFO PANEL
// ============================================================================

if show_info
    var table info = table.new(position.top_right, 2, 14, border_width=1)
    
    // Header
    table.cell(info, 0, 0, "Indicator", bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, "Status", bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.small)
    
    // Trend
    table.cell(info, 0, 1, "Trend", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, uptrend ? "UP ↑" : downtrend ? "DN ↓" : "FLAT →", 
               bgcolor=uptrend ? color.new(color.green, 70) : downtrend ? color.new(color.red, 70) : color.new(color.gray, 70), 
               text_color=color.white, text_size=size.small)
    
    // Price vs VWAP
    table.cell(info, 0, 2, "Price vs VWAP", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, close > vwap ? "ABOVE" : "BELOW", 
               bgcolor=close > vwap ? color.new(color.green, 70) : color.new(color.red, 70), 
               text_color=color.white, text_size=size.small)
    
    // RSI
    table.cell(info, 0, 3, "RSI", text_color=color.white, text_size=size.small)
    rsi_color = rsi > rsi_ob ? color.new(color.red, 70) : rsi < rsi_os ? color.new(color.green, 70) : color.new(color.gray, 70)
    table.cell(info, 1, 3, str.tostring(math.round(rsi, 1)), bgcolor=rsi_color, text_color=color.white, text_size=size.small)
    
    // Volume
    table.cell(info, 0, 4, "Volume", text_color=color.white, text_size=size.small)
    vol_ratio = volume / vol_ma
    vol_status = vol_extreme ? str.tostring(math.round(vol_ratio, 1)) + "x⚡" : vol_strong ? str.tostring(math.round(vol_ratio, 1)) + "x↑" : vol_spike ? str.tostring(math.round(vol_ratio, 1)) + "x" : str.tostring(math.round(vol_ratio, 1)) + "x"
    vol_bg = vol_extreme ? color.new(color.lime, 50) : vol_strong ? color.new(color.green, 60) : vol_spike ? color.new(color.green, 70) : color.new(color.gray, 70)
    if vol_divergence_up or vol_divergence_down
        vol_bg := color.new(color.orange, 70)
        vol_status := str.tostring(math.round(vol_ratio, 1)) + "x⚠️"
    table.cell(info, 1, 4, vol_status, bgcolor=vol_bg, text_color=color.white, text_size=size.small)
    
    // Market Condition
    table.cell(info, 0, 5, "Market", text_color=color.white, text_size=size.small)
    market_status = is_sideways ? "SIDEWAYS" : is_trending ? "TRENDING" : "NEUTRAL"
    market_col = is_sideways ? color.new(color.gray, 70) : is_trending ? color.new(color.blue, 70) : color.new(color.gray, 70)
    table.cell(info, 1, 5, market_status, bgcolor=market_col, text_color=color.white, text_size=size.small)
    
    // ADX
    table.cell(info, 0, 6, "ADX", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 6, str.tostring(math.round(adx, 1)), 
               bgcolor=adx > adx_threshold ? color.new(color.green, 70) : color.new(color.gray, 70), 
               text_color=color.white, text_size=size.small)
    
    // Bull Score
    table.cell(info, 0, 7, "Bull Score", bgcolor=color.new(color.blue, 70), text_color=color.white, text_size=size.small)
    table.cell(info, 1, 7, str.tostring(bull_score) + "/10", 
               bgcolor=bull_score >= min_score ? color.new(color.green, 50) : color.new(color.gray, 70), 
               text_color=color.white, text_size=size.small)
    
    // Bear Score
    table.cell(info, 0, 8, "Bear Score", bgcolor=color.new(color.maroon, 70), text_color=color.white, text_size=size.small)
    table.cell(info, 1, 8, str.tostring(bear_score) + "/10", 
               bgcolor=bear_score >= min_score ? color.new(color.red, 50) : color.new(color.gray, 70), 
               text_color=color.white, text_size=size.small)
    
    // Supply/Demand Zone
    table.cell(info, 0, 9, "Zone", text_color=color.white, text_size=size.small)
    zone_status = at_supply_zone ? "SUPPLY" : at_demand_zone ? "DEMAND" : near_supply_zone ? "~SUPPLY" : near_demand_zone ? "~DEMAND" : "NONE"
    zone_col = at_supply_zone ? color.new(color.red, 70) : at_demand_zone ? color.new(color.green, 70) : near_supply_zone ? color.new(color.red, 85) : near_demand_zone ? color.new(color.green, 85) : color.new(color.gray, 70)
    table.cell(info, 1, 9, zone_status, bgcolor=zone_col, text_color=color.white, text_size=size.small)
    
    // Position
    table.cell(info, 0, 10, "Position", bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.small)
    position_txt = last_direction == "BUY" ? "LONG" : last_direction == "SELL" ? "SHORT" : "NONE"
    position_col = last_direction == "BUY" ? color.new(color.green, 50) : last_direction == "SELL" ? color.new(color.red, 50) : color.new(color.gray, 70)
    table.cell(info, 1, 10, position_txt, bgcolor=position_col, text_color=color.white, text_size=size.small)
    
    // Current Signal
    table.cell(info, 0, 11, "Signal", bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.small)
    signal_txt = buy_condition ? "BUY" : sell_condition ? "SELL" : "HOLD"
    signal_col = buy_condition ? color.new(color.green, 50) : sell_condition ? color.new(color.red, 50) : color.new(color.gray, 70)
    table.cell(info, 1, 11, signal_txt, bgcolor=signal_col, text_color=color.white, text_size=size.small)
    
    // ATR
    table.cell(info, 0, 12, "ATR", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 12, str.tostring(atr, format.mintick), text_color=color.white, text_size=size.small)
    
    // Volume Trend
    table.cell(info, 0, 13, "Vol Trend", text_color=color.white, text_size=size.small)
    vol_trend_txt = vol_trend_up ? "UP ↑" : vol_trend_down ? "DN ↓" : "FLAT"
    vol_trend_col = vol_trend_up ? color.new(color.green, 70) : vol_trend_down ? color.new(color.red, 70) : color.new(color.gray, 70)
    table.cell(info, 1, 13, vol_trend_txt, bgcolor=vol_trend_col, text_color=color.white, text_size=size.small)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(buy_signal, title="Buy Signal", message="🟢 BUY SIGNAL - Score: {{plot_0}}/10 - Enter Long Position")
alertcondition(sell_signal, title="Sell Signal", message="🔴 SELL SIGNAL - Score: {{plot_1}}/10 - Enter Short Position")
alertcondition(early_buy, title="Early Buy Entry", message="⚡ EARLY BUY - Strong institutional/recovery signal!")
alertcondition(early_sell, title="Early Sell Entry", message="⚡ EARLY SELL - Strong institutional/decline signal!")
alertcondition(is_counter_trend_buy and buy_signal, title="Counter-Trend Buy", message="⚠️ COUNTER-TREND BUY - Buying in downtrend with exceptional volume!")
alertcondition(is_counter_trend_sell and sell_signal, title="Counter-Trend Sell", message="⚠️ COUNTER-TREND SELL - Selling in uptrend with exceptional volume!")
alertcondition(institutional_buy_signal, title="Institutional Buy", message="🏦 INSTITUTIONAL BUY - Big candle at demand zone!")
alertcondition(institutional_sell_signal, title="Institutional Sell", message="🏦 INSTITUTIONAL SELL - Big candle at supply zone!")
alertcondition(v_recovery_buy_signal, title="V-Shape Recovery", message="📈 V-SHAPE RECOVERY - Oversold bounce detected!")
alertcondition(v_decline_sell_signal, title="Inverse V-Shape", message="📉 INVERSE V-SHAPE - Overbought decline detected!")
alertcondition(vol_divergence_up, title="Volume Divergence Up", message="⚠️ FAKE MOVE UP - Price rising without volume support!")
alertcondition(vol_divergence_down, title="Volume Divergence Down", message="⚠️ FAKE MOVE DOWN - Price falling without volume support!")

// Background coloring
bg_color = buy_condition ? color.new(color.green, 97) : sell_condition ? color.new(color.red, 97) : na
bgcolor(bg_color)

// Plot scores for alert messages
plot(bull_score, "Bull Score", display=display.none)
plot(bear_score, "Bear Score", display=display.none)
````
