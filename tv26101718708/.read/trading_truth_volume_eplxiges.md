# Trading Truth Volume

- url: https://www.tradingview.com/script/EplXIgeS-Trading-Truth-Volume/
- type: indicator
- pine_id: PUB;68cf6668cac547afaad55ea5e4403778
- version: 1.0

## Description

================================================================================
📊 Trading Truth Volume
🎯 Wave Volume Analysis & Volume Slope Detection
================================================================================

This companion indicator extends the Geometric Trading System by providing
advanced volume analysis—wave volume tracking, volume slope detection, and
multi-level standard deviation bands for identifying climax and exhaustion.

================================================================================
🔷 CORE VOLUME CLASSIFICATION SYSTEM
================================================================================

The system classifies each bar's volume relative to a Wilder's Moving Average,
creating a visual heatmap for instant volume intensity recognition.

--------------------------------------------------------------------------------
📊 VOLUME INTENSITY LEVELS
--------------------------------------------------------------------------------

💜 ULTRA HIGH VOLUME (2.2x+ avg)
→ Climax volume—major institutional activity or capitulation
→ Often marks reversals, breakouts, or exhaustion points
→ Color: Purple bars

🔴 VERY HIGH VOLUME (1.8x - 2.2x avg)
→ Strong institutional participation
→ Confirms major trend moves or distribution/accumulation
→ Color: Red bars

🟠 HIGH VOLUME (1.2x - 1.8x avg)
→ Above-average activity
→ Validates breakouts and trend continuation
→ Color: Orange bars

🟢 NORMAL VOLUME (0.8x - 1.2x avg)
→ Healthy trending volume
→ Standard market participation
→ Color: Green bars

🔵 LOW VOLUME (0.4x - 0.8x avg)
→ Weak conviction
→ Pullback or consolidation phase
→ Color: Blue bars

⚪ VERY LOW VOLUME (<0.4x avg)
→ Minimal liquidity—avoid entries
→ Holiday/weekend sessions or dead zones
→ Color: Silver bars

================================================================================
🌊 WAVE VOLUME TRACKING SYSTEM
================================================================================

The indicator tracks cumulative volume within each price wave using Renko-style
direction detection. This reveals whether buyers or sellers are in control.

--------------------------------------------------------------------------------
📈 UPWAVE VOLUME TRACKING
--------------------------------------------------------------------------------

When price creates higher highs (direction = UP):
→ Cumulative volume is tracked for the entire upwave
→ Labels show: [Volume]V (% change | bars)
→ Example: "15420V (2.35% | 12)" = 15420 volume, 2.35% move, 12 bars

--------------------------------------------------------------------------------
📉 DOWNWAVE VOLUME TRACKING
--------------------------------------------------------------------------------

When price creates lower lows (direction = DOWN):
→ Cumulative volume is tracked for the entire downwave
→ Same label format with direction context
→ Compare upwave vs downwave volume for trend strength

--------------------------------------------------------------------------------
🔄 DIRECTION CHANGE DETECTION
--------------------------------------------------------------------------------

The system uses configurable methods to detect wave direction changes:

ATR Method (Default)
→ Uses Average True Range to filter noise
→ Value = ATR period (default: 14)
→ Best for: Volatile markets, crypto

Traditional Method
→ Fixed point value for direction change
→ Value = minimum points to change direction
→ Best for: Stable markets, indices

Part of Price Method
→ Percentage-based direction change
→ Value = divisor (price / value = threshold)
→ Best for: Scaling across different price levels

================================================================================
📐 VOLUME SLOPE ANALYSIS (Advanced)
================================================================================

The slope analysis reveals whether volume is INCREASING or DECREASING within
each wave—critical for identifying climax vs exhaustion.

--------------------------------------------------------------------------------
📈 SLOPE DETECTION METHODS
--------------------------------------------------------------------------------

🔷 SIMPLE METHOD
→ Draws line from lowest volume bar to highest volume bar in wave
→ Shows clear volume trend direction
→ Best for: Quick visual assessment

🔷 LINEAR REGRESSION METHOD
→ Fits a regression line through all volume bars in wave
→ Smoother, more statistically robust
→ Best for: Precise volume trend analysis

--------------------------------------------------------------------------------
🎨 SLOPE INTERPRETATION
--------------------------------------------------------------------------------

🟢 UPWAVE + RISING VOLUME SLOPE
→ Buyers increasing commitment
→ Strong trend continuation signal
→ Look for: Breakout confirmations

🟢 UPWAVE + FALLING VOLUME SLOPE
→ Buyers losing steam
→ Potential exhaustion warning
→ Look for: Pullback or reversal setup

🔴 DOWNWAVE + RISING VOLUME SLOPE
→ Sellers increasing pressure
→ Strong distribution or panic
→ Look for: Capitulation bottoms

🔴 DOWNWAVE + FALLING VOLUME SLOPE
→ Selling pressure diminishing
→ Potential bottoming pattern
→ Look for: Reversal setups

================================================================================
📊 VOLUME STANDARD DEVIATION BANDS
================================================================================

The system plots statistical bands around the volume moving average to identify
abnormal volume spikes and exhaustion zones.

--------------------------------------------------------------------------------
📏 BAND LEVELS
--------------------------------------------------------------------------------

⚪ VOLUME MA (Gray Line)
→ Base average volume level
→ Center of the statistical distribution

🔵 STDDEV 1 BAND (Light Blue)
→ 1 standard deviation above MA
→ ~68% of volume bars fall below this level
→ Moderate volume spike threshold

🔵 STDDEV 2 BAND (Medium Blue)
→ 2 standard deviations above MA
→ ~95% of volume bars fall below this level
→ Significant volume spike threshold

🔵 STDDEV 3 BAND (Dark Blue)
→ 3 standard deviations above MA
→ ~99.7% of volume bars fall below this level
→ EXTREME volume—climax or capitulation zone

--------------------------------------------------------------------------------
🎯 BAND TRADING SIGNALS
--------------------------------------------------------------------------------

📊 Volume Touching StdDev 1
→ Above average activity
→ Confirms trend strength
→ Normal for breakouts

📊 Volume Touching StdDev 2
→ Unusual volume spike
→ Institutional activity likely
→ Watch for continuation OR reversal

📊 Volume Touching StdDev 3
→ EXTREME volume event
→ Often marks major turning points
→ Climax tops or capitulation bottoms

================================================================================
⚙️ TRADINGVIEW INPUT SETTINGS
================================================================================

📊 BASIC VOLUME SETTINGS
--------------------------------------------------------------------------------

☑️ Show Volume Moving Average
Default: OFF
→ Plots Wilder's MA line on volume
→ Useful for seeing the dynamic average

📏 Length of MA applied on Volume
Default: 20
Range: 1-200
→ Period for volume moving average calculation
→ Lower = more responsive, Higher = smoother

--------------------------------------------------------------------------------
📈 VOLUME RATIO THRESHOLDS
--------------------------------------------------------------------------------

These ratios define the volume classification boundaries:

🔢 Ultra High Volume Ratio
Default: 2.2
→ Volume >= 2.2x MA = Ultra High (Purple)

🔢 Very High Volume Ratio
Default: 1.8
→ Volume >= 1.8x MA = Very High (Red)

🔢 High Volume Ratio
Default: 1.2
→ Volume >= 1.2x MA = High (Orange)

🔢 Normal Volume Ratio
Default: 0.8
→ Volume >= 0.8x MA = Normal (Green)

🔢 Low Volume Ratio
Default: 0.4
→ Volume >= 0.4x MA = Low (Blue)

🔢 Very Low Volume Ratio
Default: 0.4
→ Volume < 0.4x MA = Very Low (Silver)

💡 TIP: Adjust ratios based on your market's volatility. Crypto may need
higher thresholds (2.5x, 2.0x), while forex may need lower (1.8x, 1.5x).

--------------------------------------------------------------------------------
🌊 WAVE VOLUME SETTINGS
--------------------------------------------------------------------------------

🎨 Up Volume Color
Default: Black
→ Color for upwave volume labels

🎨 Down Volume Color
Default: Black
→ Color for downwave volume labels

📏 Size of Wave Line
Options: 1, 2, 3
Default: 2
→ Line thickness for wave markers

☑️ Plot Wave Volume
Default: OFF
→ Enable to show wave volume labels on chart
→ Shows cumulative volume per wave with % change

--------------------------------------------------------------------------------
🔧 RENKO DIRECTION SETTINGS
--------------------------------------------------------------------------------

📐 Renko Assignment Method
Options: ATR, Traditional, Part of Price
Default: ATR

ATR: Uses Average True Range for direction detection
→ Value = ATR period (e.g., 14)
→ Best for: Adaptive to volatility

Traditional: Fixed point threshold
→ Value = minimum points to change direction
→ Best for: Consistent markets

Part of Price: Percentage-based
→ Value = divisor (price / value = threshold)
→ Best for: Multi-asset strategies

🔢 Value
Default: 14.0
→ Meaning depends on method selected above

📊 Price Source
Options: Close, Open / Close, High / Low
Default: Close
→ Which price to use for direction detection

🔄 Use True Range instead of Volume
Options: Always, Auto, Never
Default: Auto
→ Auto: Uses True Range when volume data unavailable
→ Useful for indices or assets without volume

--------------------------------------------------------------------------------
📏 VOLUME DISPLAY SETTINGS
--------------------------------------------------------------------------------

📐 Size
Options: Tiny, Small, Medium, Large, Huge
Default: Medium
→ Size of wave volume labels

🔢 Volume Scale Down Factor
Options: 1, 10, 100, 1000, ... 1000000000
Default: 1
→ Divides volume figures for readability
→ Use 1000 for stocks, 1000000 for crypto

☑️ Show Pivot Markers
Default: OFF
→ Shows arrow markers at wave pivots

🎨 High Pivot Color
Default: Gray
→ Color for swing high markers

🎨 Low Pivot Color
Default: Black (50% transparency)
→ Color for swing low markers

☑️ Show Volume Candles
Default: OFF
→ Colors candles based on volume intensity
→ Green shades for up candles, Red for down

🔢 Volume EMA Period
Default: 20
→ EMA period for volume candle coloring

--------------------------------------------------------------------------------
📐 VOLUME SLOPE ANALYSIS SETTINGS
--------------------------------------------------------------------------------

☑️ Enable Volume Slope Analysis
Default: ON
→ Master toggle for slope detection features

📊 Slope Method
Options: Simple, Linear Regression
Default: Simple

Simple: Line between swing low/high volume points
Linear Regression: Fitted line through all wave bars

☑️ Show Volume Std Dev Bands
Default: ON
→ Displays the statistical deviation bands

🔢 Volume Std Dev Period
Default: 20
→ Period for standard deviation calculation

📏 Slope Line Width
Options: 1, 2, 3, 4
Default: 2
→ Thickness of slope lines

🎨 Upwave Slope Color
Default: Green (30% transparency)
→ Color for rising wave slope lines

🎨 Downwave Slope Color
Default: Red (30% transparency)
→ Color for falling wave slope lines

================================================================================
🟢 BULLISH VOLUME SIGNALS
================================================================================

--------------------------------------------------------------------------------
Signal 1: Climax Volume at Support
--------------------------------------------------------------------------------
Setup: Ultra High volume (purple) at geometric support level

Interpretation: Capitulation selling—smart money absorbing supply

📥 Action: Look for bullish reversal candle

🎯 Target: Previous swing high or midpoint

📊 Confirmation: Volume slope turning up in new wave

--------------------------------------------------------------------------------
Signal 2: Rising Volume in Upwave
--------------------------------------------------------------------------------
Setup: Volume slope trending UP during upwave

Interpretation: Buyers increasing commitment—trend acceleration

📥 Action: Add to long positions on pullbacks

🎯 Target: Extended targets (TP3, TP4)

📊 Confirmation: Each swing low has higher volume than previous

--------------------------------------------------------------------------------
Signal 3: Decreasing Volume on Pullback
--------------------------------------------------------------------------------
Setup: Volume drops to Low/Very Low during downwave correction

Interpretation: Healthy profit-taking, no distribution

📥 Action: Prepare for continuation entry

🎯 Target: New highs

📊 Confirmation: Volume expands when uptrend resumes

================================================================================
🔴 BEARISH VOLUME SIGNALS
================================================================================

--------------------------------------------------------------------------------
Signal 1: Climax Volume at Resistance
--------------------------------------------------------------------------------
Setup: Ultra High volume (purple) at geometric resistance

Interpretation: Blow-off top—smart money distributing

📤 Action: Look for bearish reversal candle

🎯 Target: Previous swing low or midpoint

📊 Confirmation: Volume slope turning down in new wave

--------------------------------------------------------------------------------
Signal 2: Rising Volume in Downwave
--------------------------------------------------------------------------------
Setup: Volume slope trending UP during downwave

Interpretation: Panic selling—trend acceleration down

📤 Action: Add to short positions on rallies

🎯 Target: Extended targets (TP3, TP4)

📊 Confirmation: Each swing high has higher volume than previous

--------------------------------------------------------------------------------
Signal 3: Decreasing Volume on Rally
--------------------------------------------------------------------------------
Setup: Volume drops to Low/Very Low during upwave bounce

Interpretation: Weak buying, no accumulation

📤 Action: Prepare for continuation short entry

🎯 Target: New lows

📊 Confirmation: Volume expands when downtrend resumes

================================================================================
🎯 VOLUME + GEOMETRY CONFLUENCE
================================================================================

The Volume indicator works best when combined with the main Geometric Trading
System indicator. Look for these high-probability setups:

--------------------------------------------------------------------------------
💎 CONFLUENCE SETUP 1: Angle + Volume Spike
--------------------------------------------------------------------------------

Condition: Price touches 1x1 geometric angle
+ Ultra High or Very High volume bar
+ Volume slope diverging from price direction

= HIGH PROBABILITY REVERSAL

--------------------------------------------------------------------------------
💎 CONFLUENCE SETUP 2: Midpoint + Volume Climax
--------------------------------------------------------------------------------

Condition: Price at HTF midpoint level
+ Volume touching StdDev 3 band
+ Wave volume 2x+ previous wave

= MAJOR TURNING POINT

--------------------------------------------------------------------------------
💎 CONFLUENCE SETUP 3: Time Cycle + Volume Exhaustion
--------------------------------------------------------------------------------

Condition: Price at geometric time cycle vertical
+ Declining volume slope in current wave
+ Volume below StdDev 1 band

= TREND EXHAUSTION / REVERSAL ZONE

================================================================================
💎 PRO TRADING NOTES
================================================================================

🎯 VOLUME ANALYSIS HIERARCHY

1. StdDev Bands → Identify abnormal volume events
2. Wave Volume → Compare buying vs selling pressure
3. Volume Slope → Confirm trend strength or exhaustion
4. Color Classification → Quick visual assessment

--------------------------------------------------------------------------------
📊 VOLUME DIVERGENCE PATTERNS
--------------------------------------------------------------------------------

Price Higher High + Volume Lower High = BEARISH DIVERGENCE
→ Weakening buying pressure, potential top

Price Lower Low + Volume Lower Low = BULLISH DIVERGENCE
→ Weakening selling pressure, potential bottom

Price Flat + Volume Expanding = BREAKOUT IMMINENT
→ Accumulation or distribution complete

--------------------------------------------------------------------------------
🌊 WAVE VOLUME COMPARISONS
--------------------------------------------------------------------------------

Upwave Vol > Downwave Vol = BULLISH BIAS
→ Buyers more aggressive than sellers

Downwave Vol > Upwave Vol = BEARISH BIAS
→ Sellers more aggressive than buyers

Equal Wave Volumes = CONSOLIDATION
→ No clear winner, wait for breakout

--------------------------------------------------------------------------------
📈 VOLUME SLOPE STRATEGIES
--------------------------------------------------------------------------------

Rising Slope + Rising Price = STRONG TREND (ride it)

Falling Slope + Rising Price = EXHAUSTION (prepare exit)

Rising Slope + Falling Price = PANIC (look for bottom)

Falling Slope + Falling Price = WEAK SELLING (potential bounce)

================================================================================
🆘 TROUBLESHOOTING
================================================================================

Q: Volume bars not colored correctly?
A: - Check that volume data is available for your symbol
- Some indices don't have volume—use True Range option
- Adjust ratio thresholds if all bars are same color

Q: Wave volume labels not showing?
A: - Enable "Plot Wave Volume" in settings
- Check that wave colors are not transparent
- Reduce "Volume Scale Down Factor" if numbers are 0

Q: StdDev bands too wide/narrow?
A: - Adjust "Volume Std Dev Period" (higher = wider bands)
- Very volatile assets may need shorter period
- Stable assets may need longer period

Q: Volume slope not visible?
A: - Enable "Enable Volume Slope Analysis"
- Check slope line width is 2 or higher
- Ensure slope colors are not too transparent

Q: Different from main price chart volume?
A: - This indicator uses Wilder's MA (exponential smoothing)
- Built-in TradingView volume uses SMA
- Both are valid—this is more responsive

Q: Works on all markets?
A: - ✅ Crypto (24/7 volume)
- ✅ Stocks (regular hours volume)
- ✅ Futures (tick volume)
- ⚠️ Forex (tick volume, less reliable)
- ⚠️ Indices (may need True Range option)

Q: Best settings for scalping?
A: - Reduce MA Length to 10-14
- Lower StdDev Period to 14
- Use "Part of Price" method with value 100-200

Q: Best settings for swing trading?
A: - Increase MA Length to 30-50
- Higher StdDev Period to 30
- Use "ATR" method with value 20-30

================================================================================
📜 VERSION HISTORY
================================================================================

v1.0 (Current - January 2025)
✅ Volume classification system (6 levels)
✅ Wilder's Moving Average calculation
✅ Wave volume tracking with labels
✅ Renko-style direction detection
✅ Volume slope analysis (Simple & LinReg)
✅ Standard deviation bands (1, 2, 3 sigma)
✅ Customizable ratio thresholds
✅ Volume candle coloring option
✅ Multi-method direction detection
✅ Scale factor for large volume numbers

Planned v2.0
🔜 Volume profile integration
🔜 VWAP deviation bands
🔜 Volume-weighted wave analysis
🔜 Automated divergence detection
🔜 Volume alerts (climax, exhaustion)

================================================================================
🧠 THE SCIENCE BEHIND VOLUME ANALYSIS
================================================================================

Core Volume Principles Applied

1. Volume Precedes Price
→ Major moves are preceded by volume expansion
→ Climax volume marks turning points

2. Volume Confirms Trend
→ Healthy trends have rising volume in trend direction
→ Declining volume = weakening trend

3. Exhaustion Patterns
→ Ultra-high volume at extremes = capitulation
→ Low volume at extremes = no conviction

4. Wave Volume Comparison
→ Compare effort (volume) to result (price movement)
→ High effort + low result = potential reversal

5. Standard Deviation Context
→ Statistical framework for "abnormal" volume
→ 3 sigma events are rare and significant

WHY THIS WORKS

- Smart Money Footprint: Large players can't hide volume

- Confirmation Tool: Volume validates or invalidates price moves

- Early Warning: Volume divergences precede price reversals

- Universal: Same principles work across all markets

================================================================================
⚠️ RISK DISCLAIMER
================================================================================

This indicator is an EDUCATIONAL TOOL for volume analysis. It does NOT
guarantee profits. Markets involve substantial risk of loss.

- Volume analysis is ONE piece of the puzzle
- Always combine with price structure analysis
- Use proper position sizing (1-2% risk per trade)
- Backtest strategies before live trading
- No indicator is 100% accurate

================================================================================
🎓 LEARNING PATH
================================================================================

BEGINNER
1. Start with just the colored volume bars
2. Learn to identify Ultra High and Very High volume events
3. Notice how price reacts after volume spikes
4. Track wave volume to see buyer vs seller strength

INTERMEDIATE
5. Enable StdDev bands to quantify "abnormal" volume
6. Use volume slope to confirm trend strength
7. Compare wave volumes for bias direction
8. Look for volume divergences with price

ADVANCED
9. Combine with Geometric Trading System angles
10. Trade volume climax reversals at geometric levels
11. Use wave volume ratios for position sizing
12. Develop volume-based entry/exit rules

================================================================================
💬 FINAL WORDS FROM THE ARCHITECT
================================================================================

"Price tells you WHAT happened. Volume tells you WHO made it happen. When
smart money moves, volume reveals their footprint. Learn to read the
volume story, and you'll see the market's intentions before they unfold."

Volume is the fuel that drives price. Without volume, moves are suspect.
With volume, moves are confirmed. Master volume analysis, and you'll
trade with conviction.

================================================================================

📊 Volume is the Heartbeat of the Market

© 2025 AstroTrade_ | Invite-Only TradingView Script

================================================================================

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// Modified by @ihuman20071997
indicator('Trading Truth Volume', shorttitle = 'Trading Truth Volume', overlay=false, precision = 2)

showMA =                input(defval=false,  title="Show Volume Moving Average")
lengthVolumeMA =        input(defval=20,    title="Length of MA applied on Volume")
ratioUltraVolume =      input(defval=2.2,   title="Ultra High Volume Ratio")
ratioVeryHighVolume =   input(defval=1.8,   title="Very High Volume Ratio")
ratioHighVolume =       input(defval=1.2,   title="High Volume Ratio")
ratioNormalVolume =     input(defval=0.8,   title="Normal Volume Ratio")
ratioLowVolume =        input(defval=0.4,   title="Low Volume Ratio")
ratioVeryLowVolume =    input(defval=0.4,   title="Very Low Volume Ratio")

// WILDERS MA
float volumeMA  = 0
volumeMA := nz(volumeMA[1]) + (volume-nz(volumeMA[1])) / lengthVolumeMA

ultraHighVolumeMin   = volumeMA * ratioUltraVolume
veryHighVolumeMin    = volumeMA * ratioVeryHighVolume
highVolumeMin        = volumeMA * ratioHighVolume
normalVolumeMin      = volumeMA * ratioNormalVolume
lowVolumeMin         = volumeMA * ratioLowVolume
veryLowVolumeMin     = volumeMA * ratioVeryLowVolume

volUltraHigh        = volume >= ultraHighVolumeMin                                      ? true : false
volVeryHigh         = volume >= veryHighVolumeMin   and volume < ultraHighVolumeMin     ? true : false
volHigh             = volume >= highVolumeMin       and volume < veryHighVolumeMin      ? true : false
volNormal           = volume >= normalVolumeMin     and volume < highVolumeMin          ? true : false
volLow              = volume >= lowVolumeMin        and volume < normalVolumeMin        ? true : false
volVeryLow          = volume < lowVolumeMin                                             ? true : false

palette = volUltraHigh ? color.purple : volVeryHigh ? color.red : volHigh ? color.orange : volNormal ? color.green : volLow ? color.blue : color.silver
plot(volume, color = palette, style=plot.style_columns, title="Volume")
plot(showMA ? volumeMA : na, style=plot.style_line, color=color.green, title="Volume MA")

C_JET_BLACK = #000000
C_DEFAULT = color.silver

METHODVALUE_STEP = 1

colorUpWaveVol = input.color(color.new(color.black, 1), 'Up Volume', inline = 'ColorWaveNum')
colorDnWaveVol = input.color(color.new(color.black, 1), 'Down Volume', inline = 'ColorWaveNum')

line_size = input.int(2, title="size of wave line", options=[1, 2, 3])
plot_wave_volume = input.bool(false, "Plot Wave Volume")

method = input.string('ATR', options = ['ATR', 'Traditional', 'Part of Price'], title = 'Renko Assignment Method')
methodvalue = input.float(14.0, minval = 0, title = 'Value')
pricesource = input.string('Close', options = ['Close', 'Open / Close', 'High / Low'], title = 'Price Source')
useTrueRange = input.string('Auto', options = ['Always', 'Auto', 'Never'], title = 'Use True Range instead of Volume')

volumeSize = input.string('Medium', 'Size', options = ['Tiny', 'Small', 'Medium', 'Large', 'Huge'], inline = 'ColorWaveNum')
scaleDownFactor = input.int(1, 'Volume Scale Down Factor', options = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000], inline = 'ScaleDown', tooltip = 'Scale down the volume figures for better readability if the numbers are too lengthy/messy')
isShowMarkers = input.bool(false, 'Show Pivot Markers', inline = 'PivotMarkers')
colorPivotHigh = input.color(color.new(color.gray, 1), 'High', inline = 'PivotMarkers')
colorPivotLow = input.color(color.new(color.black, 50), 'Low', inline = 'PivotMarkers')
isShowVolumeCandles = input.bool(false, 'Show Volume Candles  |', inline = 'Volume Candles')
emaPeriod = input.int(20, 'Volume EMA Period', inline = 'Volume Candles', tooltip = 'Will be used for comparing the average volume when coloring candles ')

// Volume Slope Analysis Settings
volumeSlopeSet = input(false, '═════════ Volume Slope Analysis ════════')
enableVolumeSlope = input.bool(true, 'Enable Volume Slope Analysis', inline = 'VolumeSlope')
volumeSlopeMethod = input.string('Simple', 'Slope Method', options = ['Simple', 'Linear Regression'], inline = 'VolumeSlope', tooltip = 'Simple: Line between swing low/high volume | Linear Regression: Fitted line through wave volume bars')
showVolumeStdDev = input.bool(true, 'Show Volume Std Dev Bands', inline = 'VolumeBands')
volumeStdDevLength = input.int(20, 'Volume Std Dev Period', inline = 'VolumeBands')
volumeSlopeLineWidth = input.int(2, 'Slope Line Width', options=[1, 2, 3, 4], inline = 'SlopeWidth')
colorUpwaveSlope = input.color(color.new(color.green, 30), 'Upwave Slope', inline = 'SlopeColors')
colorDownwaveSlope = input.color(color.new(color.red, 30), 'Downwave Slope', inline = 'SlopeColors')

if not plot_wave_volume
    colorUpWaveVol := color.new(color.black, 100)
    colorDnWaveVol := color.new(color.black, 100)

//************************************************************************************************************
// Colors for Volume Candles
//************************************************************************************************************
g_01 = #dff5df
g_02 = #c8e6c9
g_03 = #03f703
g_04 = #44c649
g_05 = #0ca80c
g_06 = #006700

r_01 = #f4e5e5
r_02 = #f9cdcd
r_03 = #f79b9b
r_04 = #e66161
r_05 = #F30000
r_06 = #9F0000

volumeFraction = volume / ta.ema(volume, emaPeriod)
isUp = close > open
color candleColor = na

// Calculate Volume MA and Standard Deviation
volumeMA_stddev = ta.sma(volume, volumeStdDevLength)
volumeStdDev = ta.stdev(volume, volumeStdDevLength)
volumeStdDev1 = volumeMA_stddev + 1.0 * volumeStdDev
volumeStdDev2 = volumeMA_stddev + 2.0 * volumeStdDev
volumeStdDev3 = volumeMA_stddev + 3.0 * volumeStdDev

useClose = pricesource == 'Close'
useOpenClose = pricesource == 'Open / Close' or useClose

var float cumulVol = 0

var wave_volumes = array.new_int(0)
var no_of_bars_ease_of_movement = array.new_int(0)
var wave_spreads = array.new_float(0)
var swing_high = array.new_float(0)
var swing_low = array.new_float(0)

vol = useTrueRange == 'Always' or useTrueRange == 'Auto' and na(volume) ? ta.tr : volume
op = useClose ? close : open
hi = useOpenClose ? close >= op ? close : op : high
lo = useOpenClose ? close <= op ? close : op : low

methodvalue := method == 'ATR' ? ta.atr(math.round(methodvalue)) : method == 'Part of Price' ? close / methodvalue : methodvalue * METHODVALUE_STEP * syminfo.mintick
close_diff = close > close[1] ? (close - close[1]) / close * 100 : -((close[1] - close) / close[1]) * 100
currclose = float(na)
prevclose = nz(currclose[1])
prevhigh = prevclose + methodvalue
prevlow = prevclose - methodvalue
currclose := hi > prevhigh ? hi : lo < prevlow ? lo : prevclose

direction = int(na)
direction := currclose > prevclose ? 1 : currclose < prevclose ? -1 : nz(direction[1])

directionHasChanged = ta.change(direction) != 0
directionIsUp = direction > 0
directionIsDown = direction < 0

//************************************************************************************************************
// Volume Slope Tracking Variables
//************************************************************************************************************
// Track the lowest and highest volume within each wave
var float waveLowestVolume = na        // Lowest volume in current wave
var int waveLowestVolumeBar = na       // Bar index of lowest volume
var float waveHighestVolume = na       // Highest volume in current wave
var int waveHighestVolumeBar = na      // Bar index of highest volume
var int waveStartBar = na              // Bar where wave started

// Initialize or reset on wave change
if directionHasChanged
    // Reset for new wave
    waveLowestVolume := volume
    waveLowestVolumeBar := bar_index
    waveHighestVolume := volume
    waveHighestVolumeBar := bar_index
    waveStartBar := bar_index
else
    // Update lowest volume in wave
    if volume < waveLowestVolume or na(waveLowestVolume)
        waveLowestVolume := volume
        waveLowestVolumeBar := bar_index
    // Update highest volume in wave
    if volume > waveHighestVolume or na(waveHighestVolume)
        waveHighestVolume := volume
        waveHighestVolumeBar := bar_index

// Calculate bars since wave started
var int barsSinceWaveStart = 0
barsSinceWaveStart := directionHasChanged ? 1 : barsSinceWaveStart + 1

//************************************************************************************************************
// Labels and Wave Volume Tracking
//************************************************************************************************************
var label currentWaveLabel = na
var color labelColor = C_DEFAULT
var color textColor = C_DEFAULT
var string labelText = ''
labelStyle = label.style_none
labelSize = size.tiny
xloc = bar_index
yloc = yloc.abovebar
labelSize := volumeSize == 'Tiny' ? size.tiny : volumeSize == 'Small' ? size.small : volumeSize == 'Medium' ? size.normal : volumeSize == 'Large' ? size.large : size.huge

label.delete(currentWaveLabel)
close_diff := not directionHasChanged ? close_diff[1] + close_diff : close_diff
bar_count = 0
highest_high = 0.0
lowest_low = 0.0

bar_count := not directionHasChanged ? bar_count[1] + 1 : bar_count

highest_high := directionHasChanged ? highest_high[1] : high
lowest_low := directionHasChanged ? lowest_low[1] : low

if directionHasChanged and directionIsDown
    cumulVol := vol
    array.push(wave_volumes, int(cumulVol[1] / scaleDownFactor))
    array.push(no_of_bars_ease_of_movement, int(bar_count[1]))
    array.push(wave_spreads, float(math.round(close_diff[1], 2)))
    array.push(swing_high, highest_high[1])

    array_size = array.size(wave_volumes) - 1
    labelText := str.tostring(int(cumulVol[1] / scaleDownFactor)) + 'V' + '\n(' + str.tostring(float(math.round(close_diff[1], 2))) + '%' + '|' + str.tostring(bar_count[1]) + ')'
    labelStyle := isShowMarkers ? label.style_arrowdown : label.style_none
    labelColor := colorPivotHigh
    textColor := colorUpWaveVol
    xloc := bar_index[1]
    yloc := yloc.abovebar
    // label.new(xloc, volume[1], yloc = yloc, color = labelColor, textcolor = textColor, size = labelSize, style = labelStyle, text = labelText)
    labelStyle := isShowMarkers ? label.style_arrowup : label.style_none
    labelText := str.tostring(int(cumulVol / scaleDownFactor)) + 'V' + str.tostring('_')
    // currentWaveLabel := label.new(bar_index, volume, yloc = yloc.belowbar, color = colorPivotLow, textcolor = colorDnWaveVol, size = labelSize, style = labelStyle, text = labelText)
    // currentWaveLabel
else if directionHasChanged and directionIsUp
    cumulVol := vol
    array.push(wave_volumes, int(cumulVol[1] / scaleDownFactor))
    array.push(no_of_bars_ease_of_movement, int(bar_count[1]))
    array.push(wave_spreads, float(math.round(close_diff[1], 2)))
    array.push(swing_low, lowest_low[1])

    array_size = array.size(wave_volumes) - 1
    labelText := str.tostring(int(cumulVol[1] / scaleDownFactor)) + 'V' + '\n(' + str.tostring(float(math.round(close_diff[1], 2))) + '%' + '|' + str.tostring(bar_count[1]) + ')'
    labelStyle := isShowMarkers ? label.style_arrowup : label.style_none
    labelColor := colorPivotLow
    textColor := colorDnWaveVol
    xloc := bar_index[1]
    yloc := yloc.belowbar
    // label.new(xloc, volume[1], yloc = yloc, color = labelColor, textcolor = textColor, size = labelSize, style = labelStyle, text = labelText)
    labelStyle := isShowMarkers ? label.style_arrowdown : label.style_none
    labelText := str.tostring(int(cumulVol / scaleDownFactor)) + 'V' + str.tostring('_')
    // currentWaveLabel := label.new(bar_index, volume, yloc = yloc.abovebar, color = colorPivotHigh, textcolor = colorUpWaveVol, size = labelSize, style = labelStyle, text = labelText)
    // currentWaveLabel
else if directionIsDown
    vol := not directionHasChanged ? vol[1] + vol : vol
    cumulVol := vol
    labelText := str.tostring(int(cumulVol / scaleDownFactor)) + 'V' + str.tostring('_') + '\n(' + str.tostring(float(math.round(close_diff[1], 2))) + '%' + '|' + str.tostring(bar_count[1]) + ')'
    labelStyle := isShowMarkers ? label.style_arrowup : label.style_none
    labelColor := colorPivotLow
    textColor := colorDnWaveVol
    xloc := bar_index
    yloc := yloc.belowbar
    // currentWaveLabel := label.new(xloc, volume, yloc = yloc, color = labelColor, textcolor = textColor, size = labelSize, style = labelStyle, text = labelText)
    // currentWaveLabel
else if directionIsUp
    vol := not directionHasChanged ? vol[1] + vol : vol
    cumulVol := vol
    labelText := str.tostring(int(cumulVol / scaleDownFactor)) + str.tostring('_') + '\n(' + str.tostring(float(math.round(close_diff[1], 2))) + '%' + '|' + str.tostring(bar_count[1]) + ')'
    labelStyle := isShowMarkers ? label.style_arrowdown : label.style_none
    labelColor := colorPivotHigh
    textColor := colorUpWaveVol
    xloc := bar_index
    yloc := yloc.abovebar
    // currentWaveLabel := label.new(xloc, volume, yloc = yloc, color = labelColor, textcolor = textColor, size = labelSize, style = labelStyle, text = labelText)
    // currentWaveLabel

// Volume Candle Colors
// if isShowVolumeCandles
//     if bool(volume) and isUp
//         candleColor := volumeFraction > 2 ? g_06 : volumeFraction > 1.5 ? g_05 : volumeFraction > 1.2 ? g_04 : volumeFraction > 0.8 ? g_03 : volumeFraction > 0.4 ? g_02 : g_01
//         candleColor
//     else if bool(volume)
//         candleColor := volumeFraction > 2 ? r_06 : volumeFraction > 1.5 ? r_05 : volumeFraction > 1.2 ? r_04 : volumeFraction > 0.8 ? r_03 : volumeFraction > 0.4 ? r_02 : r_01
//         candleColor

// barcolor(candleColor)

//************************************************************************************************************
// Volume Slope Analysis Plots
//************************************************************************************************************
// Plot Volume Standard Deviation Bands
plot(showVolumeStdDev ? volumeMA_stddev : na, color=color.new(color.gray, 50), style=plot.style_line, linewidth=1, title="Volume MA")
plot(showVolumeStdDev ? volumeStdDev1 : na, color=color.new(color.blue, 70), style=plot.style_line, linewidth=1, title="Volume StdDev 1")
plot(showVolumeStdDev ? volumeStdDev2 : na, color=color.new(color.blue, 60), style=plot.style_line, linewidth=1, title="Volume StdDev 2")
plot(showVolumeStdDev ? volumeStdDev3 : na, color=color.new(color.blue, 50), style=plot.style_line, linewidth=1, title="Volume StdDev 3")

// Fill between bands for better visualization
plotStdDev1 = plot(showVolumeStdDev ? volumeStdDev1 : na, color=na, display=display.none)
plotStdDev2 = plot(showVolumeStdDev ? volumeStdDev2 : na, color=na, display=display.none)
plotStdDev3 = plot(showVolumeStdDev ? volumeStdDev3 : na, color=na, display=display.none)
plotVolumeMA = plot(showVolumeStdDev ? volumeMA_stddev : na, color=na, display=display.none)
plotZero = plot(showVolumeStdDev ? 0 : na, color=na, display=display.none)

fill(plotVolumeMA, plotStdDev1, color=color.new(color.gray, 90), title="Fill MA to StdDev1")
fill(plotStdDev1, plotStdDev2, color=color.new(color.blue, 85), title="Fill StdDev1 to StdDev2")
fill(plotStdDev2, plotStdDev3, color=color.new(color.blue, 75), title="Fill StdDev2 to StdDev3")

//************************************************************************************************************
// Volume Slope Line Plot
//************************************************************************************************************
// Calculate the slope line interpolating from lowest volume bar to highest volume bar in the wave
// The slope shows if volume is trending up or down within the wave

float volumeSlopeValue = na

if enableVolumeSlope and not na(waveLowestVolumeBar) and not na(waveHighestVolumeBar)
    // Determine which comes first - lowest or highest volume bar
    int startBar = waveLowestVolumeBar < waveHighestVolumeBar ? waveLowestVolumeBar : waveHighestVolumeBar
    int endBar = waveLowestVolumeBar < waveHighestVolumeBar ? waveHighestVolumeBar : waveLowestVolumeBar
    float startVol = waveLowestVolumeBar < waveHighestVolumeBar ? waveLowestVolume : waveHighestVolume
    float endVol = waveLowestVolumeBar < waveHighestVolumeBar ? waveHighestVolume : waveLowestVolume
    
    int totalBars = endBar - startBar
    
    if totalBars > 0 and bar_index >= startBar and bar_index <= endBar
        int offsetBars = bar_index - startBar
        // Linear interpolation between lowest and highest volume points
        volumeSlopeValue := startVol + (endVol - startVol) * float(offsetBars) / float(totalBars)

// Alternative: Use ta.linreg for smoother line fitting through all volume bars in wave
float volumeLinReg = na
if enableVolumeSlope and barsSinceWaveStart > 1
    volumeLinReg := ta.linreg(volume, barsSinceWaveStart, 0)

// Determine slope color based on current wave direction
slopeLineColor = directionIsUp ? colorUpwaveSlope : colorDownwaveSlope

// Plot based on method selection
// plot(enableVolumeSlope and volumeSlopeMethod == 'Simple' ? volumeSlopeValue : na, color=slopeLineColor, style=plot.style_line, linewidth=2, title="Volume Slope (Simple)")
// plot(enableVolumeSlope and volumeSlopeMethod == 'Linear Regression' ? volumeLinReg : na, color=slopeLineColor, style=plot.style_line, linewidth=2, title="Volume Slope (LinReg)")
````
