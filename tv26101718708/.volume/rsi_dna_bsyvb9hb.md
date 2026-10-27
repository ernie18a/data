# RSI DNA

- url: https://www.tradingview.com/script/bsYvb9Hb-RSI-DNA/
- type: indicator
- pine_id: PUB;d7eb050e5c2f4f559f6a756f774711b5
- version: 1.0

## Description

RSI dna Oscillator is a momentum analysis tool built around RSI, divergence detection, multi-timeframe RSI readings, volume context, failure swings, higher timeframe bias, and RSI compression behavior.

The purpose of this indicator is to help traders read momentum conditions in a structured way. It is designed to show when RSI is bullish, bearish, overbought, oversold, compressed around the midline, or showing divergence against price action.

This script is an indicator only. It does not place trades, does not provide financial advice, and does not guarantee future results. It should be used together with price action, market structure, support and resistance, volume, and personal risk management.

────────────────────────────
MAIN FEATURES
────────────────────────────

RSI Engine
The core of the indicator is a standard RSI calculation. The RSI line, histogram, midline, overbought zone, and oversold zone help identify bullish or bearish momentum conditions.

Divergence Detection
The indicator can detect regular and hidden bullish or bearish divergences between price and RSI. Divergence lines and labels can be displayed directly inside the oscillator panel.

Volume-Confirmed Divergences
An optional volume filter can be used to validate divergences only when volume conditions are present. The filter can use volume spike, absorption wick behavior, volume fade, or a combination of these conditions.

Heiken Ashi RSI Mode
The script includes an optional Heiken Ashi smoothing mode calculated from RSI values. This can help reduce visual noise in the oscillator. Opposite RSI candles can also be masked when they conflict with the smoothed HA direction.

Failure Swing Engine
The indicator includes an optional RSI failure swing module. This is separated from classical divergence detection. It looks for RSI reversal structures based on RSI pivots, break levels, and confirmation.

MTF RSI Matrix
The dashboard can display RSI values from multiple timeframes. This helps compare short-term and higher-timeframe momentum from the same panel.

HTF Bias Filter
Signals can optionally be filtered by a higher timeframe bias using EMA, RSI, or EMA plus RSI. This can help avoid signals that go against the selected higher timeframe condition.

RSI Squeeze Mode
The indicator can detect when RSI compresses around the midline. A squeeze condition suggests that momentum is tight or undecided. Release signals can appear when RSI expands away from the compression area.

Volume Profile Display
A small volume profile-style column display is included in the oscillator panel. It shows relative volume strength compared to its moving average.

Candle Color Mode
The script can optionally color chart candles using different logic modes, including RSI midline, higher timeframe bias, or high/low structure. The high/low structure mode is designed to provide a simple bullish or bearish reading based on price making higher highs and higher lows, or lower highs and lower lows.

Alerts
The script includes alerts for RSI midline crosses, overbought and oversold entries/exits, divergences, Heiken Ashi RSI flips, volume spikes, failure swings, RSI squeeze, and squeeze releases.

────────────────────────────
INPUTS EXPLAINED
────────────────────────────

RSI ENGINE

RSI Length
Controls the RSI calculation period. A lower value makes RSI more reactive. A higher value makes RSI smoother.

Overbought
Defines the upper RSI level used to mark overbought conditions. The default value is commonly set around 70.

Oversold
Defines the lower RSI level used to mark oversold conditions. The default value is commonly set around 30.

Midline
Defines the center level used to separate bullish and bearish RSI zones. The default value is 50.

────────────────────────────
HEIKEN ASHI MODE

Enable HA Smoothing
Turns RSI Heiken Ashi smoothing on or off.

HA Smooth Length
Controls the smoothing length used in the RSI Heiken Ashi calculation.

Mask Opposite Candles
When enabled, the indicator softens or hides RSI candles that move against the current HA RSI direction. This can make the oscillator easier to read in trend conditions.

────────────────────────────
DIVERGENCE

Divergence Lookback
Controls the pivot length used to detect price and RSI pivot points. A smaller value detects more divergences. A larger value is stricter and produces fewer signals.

Show Regular Div
Shows or hides regular bullish and bearish divergences.

Show Hidden Div
Shows or hides hidden bullish and bearish divergences.

Show Divergence Lines
Shows or hides the lines connecting RSI pivot points during divergence signals.

Require Volume-Confirmed Divergence
When enabled, divergences must also match the selected volume confirmation condition.

Volume Confirmation Mode
Selects the type of volume behavior required:

* Spike
* Absorption
* Volume Fade
* Spike or Absorption
* Any

Divergence Volume Spike x MA
Defines how much volume must exceed its moving average to be considered a spike.

Absorption Wick Ratio
Defines the wick size required for absorption-style confirmation.

────────────────────────────
VOLUME PROFILE

Show Volume Profile
Shows or hides the relative volume columns in the oscillator panel.

Volume Profile Length
Controls the volume moving average length used to calculate relative volume.

Profile Bar Width
Controls the visual width of the volume profile columns.

────────────────────────────
DNA VISUAL

Show DNA Strands
Shows or hides the wave-style visual strands in the oscillator panel. This is disabled by default for a cleaner layout.

DNA Wave Frequency
Controls how fast the visual strands oscillate.

DNA Amplitude
Controls how far the visual strands move around the midline.

────────────────────────────
FAILURE SWING ENGINE

Enable Failure Swing Engine
Turns RSI failure swing detection on or off.

Show Failure Swing Break Lines
Shows or hides the break level line used by the failure swing engine.

RSI Failure Swing Pivot
Controls the pivot sensitivity used for failure swing detection.

Require OB/OS Origin
When enabled, bullish failure swings must begin from oversold conditions and bearish failure swings must begin from overbought conditions.

Failure Swing Label Size
Controls the size of failure swing labels.

────────────────────────────
MTF RSI MATRIX

Show MTF RSI Matrix In Dashboard
Shows or hides the multi-timeframe RSI values in the dashboard.

Matrix TF 1
First RSI timeframe displayed in the matrix.

Matrix TF 2
Second RSI timeframe displayed in the matrix.

Matrix TF 3
Third RSI timeframe displayed in the matrix.

Matrix TF 4
Fourth RSI timeframe displayed in the matrix.

Matrix TF 5
Fifth RSI timeframe displayed in the matrix.

These timeframes can be adjusted to match scalping, intraday, swing, or higher-timeframe analysis.

────────────────────────────
HTF BIAS FILTER

Enable HTF Bias Filter
Turns higher timeframe filtering on or off.

HTF Bias Timeframe
Selects the higher timeframe used for bias filtering.

HTF Bias Mode
Selects the filter method:

* EMA
* RSI
* EMA + RSI

HTF EMA Length
Controls the EMA length used for higher timeframe trend bias.

HTF RSI Bull Level
Defines the RSI level required for bullish higher timeframe confirmation.

HTF RSI Bear Level
Defines the RSI level required for bearish higher timeframe confirmation.

────────────────────────────
RSI SQUEEZE MODE

Enable RSI Squeeze Mode
Turns RSI compression detection on or off.

Squeeze Length
Controls the lookback length used to measure RSI compression.

Compression Distance Around Mid
Defines how close RSI must stay around the midline to be considered compressed.

Max RSI StdDev In Squeeze
Defines the maximum RSI standard deviation allowed during compression.

Release Distance From Mid
Defines how far RSI must move away from the midline to mark a release.

Post-Squeeze Release Window
Defines how many bars after compression can still qualify as a squeeze release.

────────────────────────────
CANDLE COLOR MODE

Candle Color Mode
Allows chart candles to be colored using the selected logic.

RSI Midline Mode
Colors candles based on whether RSI is above or below the midline.

HTF Bias Mode
Colors candles based on the selected higher timeframe bias.

High/Low Structure Mode
Colors candles using simple structure logic:

* Bullish when price makes a higher high and higher low
* Bearish when price makes a lower high and lower low

This mode is designed to be easy to read for beginners.

────────────────────────────
MINI TUTORIAL
────────────────────────────

1. Add the indicator to the chart.

2. Start with default settings.

3. Look at the RSI line:

* Above the midline means bullish RSI pressure.
* Below the midline means bearish RSI pressure.
* Above the overbought level means RSI is in an upper extreme zone.
* Below the oversold level means RSI is in a lower extreme zone.

4. Check the dashboard:
   The dashboard shows the current RSI value, trend state, zone state, divergence status, volume behavior, higher timeframe bias, and multi-timeframe RSI values.

5. Watch for divergences:
   A bullish divergence can appear when price makes a lower low while RSI makes a higher low.
   A bearish divergence can appear when price makes a higher high while RSI makes a lower high.

6. Use volume confirmation carefully:
   If volume-confirmed divergence is enabled, the divergence must also match the selected volume condition. This can reduce the number of signals.

7. Use the MTF RSI Matrix:
   If most timeframes show RSI above the midline, momentum is generally stronger on the bullish side.
   If most timeframes show RSI below the midline, momentum is generally weaker or bearish.
   Mixed readings usually mean the market is less clear.

8. Use the HTF Bias Filter:
   When this filter is enabled, signals are filtered by the selected higher timeframe condition. This can help focus only on signals aligned with the larger context.

9. Use RSI Squeeze Mode:
   When RSI compresses around the midline, momentum is quiet. A release can show when RSI expands away from the compression zone.

10. Use candle color mode as a visual guide:
    For beginners, High/Low Structure mode can make the chart easier to read by coloring candles based on simple structure behavior.

────────────────────────────
EXAMPLE USE CASES
────────────────────────────

Example 1: Momentum continuation
RSI is above the midline, the dashboard shows bullish momentum on multiple timeframes, and the HTF filter is bullish. This can help identify conditions where bullish continuation is stronger.

Example 2: Bearish divergence
Price makes a higher high, but RSI makes a lower high. A bearish divergence label appears. If volume confirmation is enabled, the signal must also match the selected volume behavior.

Example 3: Bullish reversal from oversold
RSI moves into oversold territory, then forms a bullish divergence or failure swing. The trader can use this as a warning that downside momentum may be weakening.

Example 4: RSI compression
RSI stays close to the midline and the squeeze background appears. A release signal can appear when RSI moves away from the compression zone.

Example 5: Beginner structure reading
Candle Color Mode is set to High/Low Structure. Candles become easier to read because bullish candles are based on higher highs and higher lows, while bearish candles are based on lower highs and lower lows.

────────────────────────────
BEST PRACTICES
────────────────────────────

Use this indicator as a momentum and context tool, not as a standalone trading system.

Use divergences together with support, resistance, trendlines, liquidity zones, or market structure.

Use higher timeframe confirmation when trading lower timeframes.

Use volume confirmation if you want fewer but more filtered divergence signals.

Avoid relying on signals during low-volume or highly volatile news-driven conditions.

Always test settings on the symbol and timeframe you trade.

────────────────────────────
LIMITATIONS
────────────────────────────

This script is an indicator, not a strategy.

It does not place orders.

It does not guarantee profitable results.

Divergences and failure swings can fail.

Pivot-based signals are confirmed only after the required number of bars.

Multi-timeframe readings depend on the selected timeframes.

Alerts depend on the alert settings selected by the user in TradingView.

Market context remains important. No oscillator should be used alone.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
// 𓋹 𓆣 𓃭  RSI WIZARD OSCILLATOR  ·  ORDER 322 EDITION  𓃭 𓆣 𓋹
// 𓂀════════════════════════════════════════════════════════════════════════𓂀

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║                                                                              ║
// ║                                  𓂀                                           ║
// ║                                                                              ║
// ║                         ____..--------..____                                 ║
// ║                    _.-''                    ``-._                            ║
// ║                _.-'        __..------..__        `-._                        ║
// ║             .-'        _.-'              `-._        `-.                     ║
// ║           .'        .-'      .-""""-.       `-.        `.                    ║
// ║          /        .'       .'  .--.  `.        `.        \                   ║
// ║         /       .'        /   /    \   \         `.       \                  ║
// ║        /      .'         |   |  𓂀  |   |          `.      \                 ║
// ║       /______/___________\   \____/   /_____________\______\                ║
// ║       \      \            `.        .'              /      /                ║
// ║        \      `.            `-.__.-'              .'      /                 ║
// ║         \       `-.                              .-'       /                 ║
// ║          \         `-._                      _.-'         /                  ║
// ║           `.           ``--..________..--''           .'                    ║
// ║             `-._                                  _.-'                      ║
// ║                 `--..__                    __..--'                          ║
// ║                        ``----.      .----''                                  ║
// ║                              /      \                                        ║
// ║                             /        \                                       ║
// ║                            /   .--.   \                                      ║
// ║                           /   /    \   \                                     ║
// ║                          /___/      \___\                                    ║
// ║                             /        \                                       ║
// ║                            /          \                                      ║
// ║                           /            \                                     ║
// ║                          /              \                                    ║
// ║                         /________________\                                   ║
// ║                                                                              ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

//@version=6
indicator("RSI DNA", shorttitle="RSI DNA", overlay=false, max_labels_count=500, max_lines_count=500)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓂀 𓆣 01 · TABLETS OF SETTINGS 𓆣 𓂀
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
g1 = "RSI ENGINE"
rsiLen    = input.int(14, "RSI Length", group=g1, minval=2)
rsiOB     = input.float(70, "Overbought", group=g1, minval=60, maxval=95)
rsiOS     = input.float(30, "Oversold", group=g1, minval=5, maxval=40)
rsiMid    = input.float(50, "Midline", group=g1, minval=30, maxval=70)

g2 = "HEIKEN ASHI MODE"
useHA     = input.bool(false, "Enable HA Smoothing", group=g2)
haLen     = input.int(5, "HA Smooth Length", group=g2, minval=1, maxval=20)
haMaskOpp = input.bool(true, "Mask opposite candles", group=g2, tooltip="Hides RSI candles opposite to the HA trend (example: red candles during an uptrend)")

g3 = "DIVERGENCE"
divLookback = input.int(10, "Divergence Lookback", group=g3, minval=3, maxval=30)
showRegDiv  = input.bool(true, "Show Regular Div", group=g3)
showHidDiv  = input.bool(true, "Show Hidden Div", group=g3)
showDivLine = input.bool(true, "Show Divergence Lines", group=g3)
useVolDiv   = input.bool(false, "Require Volume-Confirmed Divergence", group=g3)
divVolMode  = input.string("Any", "Volume Confirmation Mode", options=["Spike", "Absorption", "Volume Fade", "Spike or Absorption", "Any"], group=g3)
divVolMult  = input.float(1.50, "Divergence Volume Spike x MA", group=g3, minval=0.50, maxval=5.00, step=0.05)
divAbsWick  = input.float(0.38, "Absorption Wick Ratio", group=g3, minval=0.10, maxval=0.90, step=0.01)

g4 = "VOLUME PROFILE"
showVolP    = input.bool(true, "Show Volume Profile", group=g4)
volPLen     = input.int(50, "Volume Profile Length", group=g4, minval=10, maxval=200)
volPBars    = input.int(8, "Profile Bar Width", group=g4, minval=1, maxval=20)

g5 = "DNA VISUAL"
showDNA     = input.bool(false, "Show DNA Strands", group=g5)
dnaFreq     = input.float(0.3, "DNA Wave Frequency", group=g5, step=0.05, minval=0.05, maxval=1.0)
dnaAmp      = input.float(8.0, "DNA Amplitude", group=g5, step=0.5, minval=1.0, maxval=20.0)

g6 = "FAILURE SWING ENGINE"
showFS      = input.bool(false, "Enable Failure Swing Engine", group=g6)
showFSLine  = input.bool(true, "Show Failure Swing Break Lines", group=g6)
fsPivotLen  = input.int(2, "RSI Failure Swing Pivot", group=g6, minval=1, maxval=10)
fsUseOBOS   = input.bool(true, "Require OB/OS Origin", group=g6)
fsLabelSize = input.string("Small", "Failure Swing Label Size", options=["Tiny", "Small", "Normal"], group=g6)

g7 = "MTF DNA MATRIX"
showMtfMatrix = input.bool(true, "Show MTF DNA Matrix In Dashboard", group=g7)
mtfTf1 = input.timeframe("5", "Matrix TF 1", group=g7)
mtfTf2 = input.timeframe("15", "Matrix TF 2", group=g7)
mtfTf3 = input.timeframe("30", "Matrix TF 3", group=g7)
mtfTf4 = input.timeframe("60", "Matrix TF 4", group=g7)
mtfTf5 = input.timeframe("240", "Matrix TF 5", group=g7)
mtfTf6 = input.timeframe("D", "Matrix TF 6", group=g7)

g8 = "HTF BIAS FILTER"
useHTFFilter = input.bool(false, "Enable HTF Bias Filter", group=g8)
htfTf        = input.timeframe("240", "HTF Bias Timeframe", group=g8)
htfMode      = input.string("EMA + RSI", "HTF Bias Mode", options=["EMA", "RSI", "EMA + RSI"], group=g8)
htfEmaLen    = input.int(100, "HTF EMA Length", minval=5, maxval=300, group=g8)
htfRsiBull   = input.float(52.0, "HTF RSI Bull Level", minval=40.0, maxval=70.0, step=0.5, group=g8)
htfRsiBear   = input.float(48.0, "HTF RSI Bear Level", minval=30.0, maxval=60.0, step=0.5, group=g8)

g9 = "RSI SQUEEZE MODE"
showSqueeze  = input.bool(false, "Enable RSI Squeeze Mode", group=g9)
sqLen        = input.int(20, "Squeeze Length", minval=5, maxval=100, group=g9)
sqMidBand    = input.float(5.0, "Compression Distance Around Mid", minval=1.0, maxval=20.0, step=0.5, group=g9)
sqStdMax     = input.float(3.5, "Max RSI StdDev In Squeeze", minval=0.5, maxval=15.0, step=0.1, group=g9)
sqRelease    = input.float(7.0, "Release Distance From Mid", minval=2.0, maxval=25.0, step=0.5, group=g9)
sqWindow     = input.int(8, "Post-Squeeze Release Window", minval=1, maxval=30, group=g9)

g10 = "CANDLE COLOR MODE"
useCandleColor = input.bool(true, "Color Main Chart Candles", group=g10, tooltip="Colors the main chart candles from this oscillator, even when the script runs in a separate pane.")
candleColorMode = input.string("High/Low Structure", "Candle Color Logic", options=["RSI Midline", "HTF Bias", "High/Low Structure"], group=g10, tooltip="High/Low Structure is the beginner-friendly mode: bullish when the current high and low are above the previous high and low; bearish when both are below the previous high and low.")
colorNeutralBars = input.bool(false, "Color Neutral Bars", group=g10)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓇳 𓋹 02 · TEMPLE PIGMENTS 𓋹 𓇳
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
C_BULL      = color.new(#00E676, 0)
C_BULL_D    = color.new(#00E676, 35)
C_BULL_G    = color.new(#00E676, 68)
C_BULL_GG   = color.new(#00E676, 86)
C_BEAR      = color.new(#FF1744, 0)
C_BEAR_D    = color.new(#FF1744, 35)
C_BEAR_G    = color.new(#FF1744, 68)
C_BEAR_GG   = color.new(#FF1744, 86)
C_CYAN      = color.new(#00E5FF, 0)
C_CYAN_D    = color.new(#00E5FF, 35)
C_CYAN_G    = color.new(#00E5FF, 72)
C_GOLD      = color.new(#FFD600, 0)
C_GOLD_D    = color.new(#FFD600, 35)
C_PURP      = color.new(#CE93D8, 0)
C_PURP_D    = color.new(#CE93D8, 35)
C_ORNG      = color.new(#FF9100, 0)
C_ORNG_D    = color.new(#FF9100, 35)
C_WHITE     = color.new(#ECEFF1, 0)
C_DIM       = color.new(#37474F, 0)
C_DARK      = color.new(#0A1628, 0)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓁿 𓊹 03 · SCRIBE TOOLS 𓊹 𓁿
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
f_lbl_size(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small
f_rsi_col(float v) => v > rsiOB ? C_BEAR : v < rsiOS ? C_BULL : v > rsiMid ? C_BULL_D : C_BEAR_D
f_rsi_state(float v) => v > rsiOB ? "OB" : v < rsiOS ? "OS" : v > rsiMid ? "BULL" : "BEAR"
f_fmt1(float v) => str.tostring(math.round(v * 10.0) / 10.0)
f_mtf_rsi(string tf) => request.security(syminfo.tickerid, tf, ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓇌 𓂀 04 · SACRED RSI CORE 𓂀 𓇌
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
rsiRaw = ta.rsi(close, rsiLen)
rsiEMA = ta.ema(rsiRaw, 3)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓃭 𓄿 05 · RSI NILE HA CANDLES 𓄿 𓃭
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
haRsiC = ta.ema(rsiRaw, haLen)

var float haRsiO = rsiRaw
haRsiO := (nz(haRsiO[1]) + nz(haRsiC[1])) / 2

haRsiH = math.max(rsiRaw, math.max(haRsiO, haRsiC))
haRsiL = math.min(rsiRaw, math.min(haRsiO, haRsiC))

haBull = haRsiC > haRsiO
haBear = haRsiC < haRsiO

rsiDisplay = useHA ? haRsiC : rsiRaw

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓃀 𓃭 06 · BULL / BEAR REALMS 𓃭 𓃀
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
inOB   = rsiDisplay >= rsiOB
inOS   = rsiDisplay <= rsiOS
inBull = rsiDisplay > rsiMid
inBear = rsiDisplay < rsiMid

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓏲 𓈖 07 · VOLUME OFFERINGS & CONFIRMATIONS 𓈖 𓏲
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
volSMA   = ta.sma(volume, volPLen)
volRat   = volSMA > 0 ? volume / volSMA : 1.0
volNorm  = math.min(volRat * 5, 15.0)
volSpike = volume > volSMA * 1.5

pivotVol = volume[divLookback]
pivotVolMA = volSMA[divLookback]
pivotRange = math.max(high[divLookback] - low[divLookback], syminfo.mintick)
pivotUpperWick = high[divLookback] - math.max(open[divLookback], close[divLookback])
pivotLowerWick = math.min(open[divLookback], close[divLookback]) - low[divLookback]
pivotVolSpike = pivotVolMA > 0 ? pivotVol > pivotVolMA * divVolMult : false
pivotVolFade = not na(volume[divLookback + 2]) and volume[divLookback] < volume[divLookback + 1] and volume[divLookback + 1] < volume[divLookback + 2]
pivotBullAbs = pivotVolSpike and pivotLowerWick / pivotRange >= divAbsWick
pivotBearAbs = pivotVolSpike and pivotUpperWick / pivotRange >= divAbsWick
volOkBullDiv = not useVolDiv or divVolMode == "Spike" and pivotVolSpike or divVolMode == "Absorption" and pivotBullAbs or divVolMode == "Volume Fade" and pivotVolFade or divVolMode == "Spike or Absorption" and (pivotVolSpike or pivotBullAbs) or divVolMode == "Any" and (pivotVolSpike or pivotBullAbs or pivotVolFade)
volOkBearDiv = not useVolDiv or divVolMode == "Spike" and pivotVolSpike or divVolMode == "Absorption" and pivotBearAbs or divVolMode == "Volume Fade" and pivotVolFade or divVolMode == "Spike or Absorption" and (pivotVolSpike or pivotBearAbs) or divVolMode == "Any" and (pivotVolSpike or pivotBearAbs or pivotVolFade)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓆓 𓂀 08 · MTF MATRIX & PHARAOH BIAS 𓂀 𓆓
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
htfClose = request.security(syminfo.tickerid, htfTf, close[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
htfEma = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfEmaLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
htfRsi = request.security(syminfo.tickerid, htfTf, ta.rsi(close, rsiLen)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
htfEmaBull = htfClose > htfEma
htfEmaBear = htfClose < htfEma
htfRsiOkBull = htfRsi >= htfRsiBull
htfRsiOkBear = htfRsi <= htfRsiBear
htfBull = htfMode == "EMA" ? htfEmaBull : htfMode == "RSI" ? htfRsiOkBull : htfEmaBull and htfRsiOkBull
htfBear = htfMode == "EMA" ? htfEmaBear : htfMode == "RSI" ? htfRsiOkBear : htfEmaBear and htfRsiOkBear
bullFilterOk = not useHTFFilter or htfBull
bearFilterOk = not useHTFFilter or htfBear

mtfRsi1 = showMtfMatrix ? f_mtf_rsi(mtfTf1) : na
mtfRsi2 = showMtfMatrix ? f_mtf_rsi(mtfTf2) : na
mtfRsi3 = showMtfMatrix ? f_mtf_rsi(mtfTf3) : na
mtfRsi4 = showMtfMatrix ? f_mtf_rsi(mtfTf4) : na
mtfRsi5 = showMtfMatrix ? f_mtf_rsi(mtfTf5) : na
mtfRsi6 = showMtfMatrix ? f_mtf_rsi(mtfTf6) : na

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓊃 𓇋 09 · DIVERGENCE MIRAGES 𓇋 𓊃
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
pivH_price = ta.pivothigh(high, divLookback, divLookback)
pivL_price = ta.pivotlow(low, divLookback, divLookback)

var float ph1 = na
var float ph2 = na
var float pl1 = na
var float pl2 = na
var float rh1 = na
var float rh2 = na
var float rl1 = na
var float rl2 = na
var int   phBar1 = na
var int   phBar2 = na
var int   plBar1 = na
var int   plBar2 = na

newHighPivot = not na(pivH_price)
newLowPivot  = not na(pivL_price)

if newHighPivot
    ph2 := ph1
    ph1 := pivH_price
    rh2 := rh1
    rh1 := rsiDisplay[divLookback]
    phBar2 := phBar1
    phBar1 := bar_index - divLookback

if newLowPivot
    pl2 := pl1
    pl1 := pivL_price
    rl2 := rl1
    rl1 := rsiDisplay[divLookback]
    plBar2 := plBar1
    plBar1 := bar_index - divLookback

regDivBearRaw = showRegDiv and newHighPivot and not na(ph1) and not na(ph2) and not na(rh1) and not na(rh2) and ph1 > ph2 and rh1 < rh2
regDivBullRaw = showRegDiv and newLowPivot  and not na(pl1) and not na(pl2) and not na(rl1) and not na(rl2) and pl1 < pl2 and rl1 > rl2
hidDivBearRaw = showHidDiv and newHighPivot and not na(ph1) and not na(ph2) and not na(rh1) and not na(rh2) and ph1 < ph2 and rh1 > rh2
hidDivBullRaw = showHidDiv and newLowPivot  and not na(pl1) and not na(pl2) and not na(rl1) and not na(rl2) and pl1 > pl2 and rl1 < rl2

regDivBear = regDivBearRaw and volOkBearDiv and bearFilterOk
regDivBull = regDivBullRaw and volOkBullDiv and bullFilterOk
hidDivBear = hidDivBearRaw and volOkBearDiv and bearFilterOk
hidDivBull = hidDivBullRaw and volOkBullDiv and bullFilterOk

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓈌 𓂀 10 · SACRED DIVERGENCE LINES 𓂀 𓈌
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
if showDivLine and regDivBull and not na(plBar1) and not na(plBar2) and not na(rl1) and not na(rl2)
    line.new(plBar2, rl2, plBar1, rl1, xloc=xloc.bar_index, extend=extend.none, color=color.new(#00E676, 0), width=1)

if showDivLine and regDivBear and not na(phBar1) and not na(phBar2) and not na(rh1) and not na(rh2)
    line.new(phBar2, rh2, phBar1, rh1, xloc=xloc.bar_index, extend=extend.none, color=color.new(#FF1744, 0), width=1)

if showDivLine and hidDivBull and not na(plBar1) and not na(plBar2) and not na(rl1) and not na(rl2)
    line.new(plBar2, rl2, plBar1, rl1, xloc=xloc.bar_index, extend=extend.none, color=color.new(#00E5FF, 0), width=1, style=line.style_dashed)

if showDivLine and hidDivBear and not na(phBar1) and not na(phBar2) and not na(rh1) and not na(rh2)
    line.new(phBar2, rh2, phBar1, rh1, xloc=xloc.bar_index, extend=extend.none, color=color.new(#CE93D8, 0), width=1, style=line.style_dashed)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓄿 𓃭 11 · FAILURE SWING MECHANISM 𓃭 𓄿
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
rsiPH = ta.pivothigh(rsiDisplay, fsPivotLen, fsPivotLen)
rsiPL = ta.pivotlow(rsiDisplay, fsPivotLen, fsPivotLen)
newRsiPH = not na(rsiPH)
newRsiPL = not na(rsiPL)

var int fsBullState = 0
var float fsBullLow = na
var float fsBullBreak = na
var float fsBullHL = na
var int fsBullLowBar = na
var int fsBullBreakBar = na
var int fsBullHLBar = na

var int fsBearState = 0
var float fsBearHigh = na
var float fsBearBreak = na
var float fsBearLH = na
var int fsBearHighBar = na
var int fsBearBreakBar = na
var int fsBearLHBar = na

bool fsBullRaw = false
bool fsBearRaw = false

if showFS and newRsiPL
    bool lowOriginOk = not fsUseOBOS or rsiPL <= rsiOS
    if lowOriginOk
        fsBullState := 1
        fsBullLow := rsiPL
        fsBullLowBar := bar_index - fsPivotLen
        fsBullBreak := na
        fsBullHL := na
    else if fsBullState == 2 and rsiPL > fsBullLow and rsiPL > rsiOS
        fsBullState := 3
        fsBullHL := rsiPL
        fsBullHLBar := bar_index - fsPivotLen

if showFS and newRsiPH
    bool highOriginOk = not fsUseOBOS or rsiPH >= rsiOB
    if highOriginOk
        fsBearState := 1
        fsBearHigh := rsiPH
        fsBearHighBar := bar_index - fsPivotLen
        fsBearBreak := na
        fsBearLH := na
    else if fsBearState == 2 and rsiPH < fsBearHigh and rsiPH < rsiOB
        fsBearState := 3
        fsBearLH := rsiPH
        fsBearLHBar := bar_index - fsPivotLen
    if fsBullState == 1 and rsiPH > rsiOS
        fsBullState := 2
        fsBullBreak := rsiPH
        fsBullBreakBar := bar_index - fsPivotLen

if showFS and newRsiPL and fsBearState == 1 and rsiPL < rsiOB
    fsBearState := 2
    fsBearBreak := rsiPL
    fsBearBreakBar := bar_index - fsPivotLen

fsBullCross = ta.crossover(rsiDisplay, fsBullBreak)
fsBearCross = ta.crossunder(rsiDisplay, fsBearBreak)
fsBullRaw := showFS and fsBullState == 3 and not na(fsBullBreak) and fsBullCross
fsBearRaw := showFS and fsBearState == 3 and not na(fsBearBreak) and fsBearCross
fsBull = fsBullRaw and bullFilterOk
fsBear = fsBearRaw and bearFilterOk

if fsBull
    if showFSLine and not na(fsBullBreakBar)
        line.new(fsBullBreakBar, fsBullBreak, bar_index, fsBullBreak, xloc=xloc.bar_index, extend=extend.none, color=C_GOLD, width=2, style=line.style_dashed)
    label.new(bar_index, rsiDisplay - 1.0, "FS+", color=color.new(#FFD600, 0), textcolor=color.new(#001A1F, 0), style=label.style_label_up, size=size.tiny)
    fsBullState := 0

if fsBear
    if showFSLine and not na(fsBearBreakBar)
        line.new(fsBearBreakBar, fsBearBreak, bar_index, fsBearBreak, xloc=xloc.bar_index, extend=extend.none, color=C_ORNG, width=2, style=line.style_dashed)
    label.new(bar_index, rsiDisplay + 1.0, "FS-", color=color.new(#FF9100, 0), textcolor=color.new(#001A1F, 0), style=label.style_label_down, size=size.tiny)
    fsBearState := 0

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓏏 𓂀 12 · RSI COMPRESSION CHAMBER 𓂀 𓏏
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
rsiStd = ta.stdev(rsiDisplay, sqLen)
rsiMidDev = math.abs(rsiDisplay - rsiMid)
rsiSqueeze = showSqueeze and rsiMidDev <= sqMidBand and rsiStd <= sqStdMax
barsSinceSq = ta.barssince(rsiSqueeze)
sqBullCross = ta.crossover(rsiDisplay, rsiMid + sqRelease)
sqBearCross = ta.crossunder(rsiDisplay, rsiMid - sqRelease)
sqReleaseBull = showSqueeze and not rsiSqueeze and barsSinceSq > 0 and barsSinceSq <= sqWindow and sqBullCross and bullFilterOk
sqReleaseBear = showSqueeze and not rsiSqueeze and barsSinceSq > 0 and barsSinceSq <= sqWindow and sqBearCross and bearFilterOk

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓆣 𓋹 13 · SACRED HELIX CALCULATION 𓋹 𓆣
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
dnaPhase   = bar_index * dnaFreq
dnaMid     = rsiMid
dnaStrand1 = dnaMid + math.sin(dnaPhase) * dnaAmp
dnaStrand2 = dnaMid + math.sin(dnaPhase + math.pi) * dnaAmp
dnaRung    = math.round(bar_index % 7) == 0

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓎛 𓇳 14 · RSI COLOR VEIL 𓇳 𓎛
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
rsiBaseColor = rsiDisplay > rsiMid ? C_BULL_D : C_BEAR_D

rsiMasked  = useHA and haMaskOpp and haBull and rsiDisplay < rsiMid
rsiMasked2 = useHA and haMaskOpp and haBear and rsiDisplay > rsiMid

rsiColor = color.new(color.gray, 100)

if rsiMasked
    rsiColor := color.new(#00E676, 60)
else if rsiMasked2
    rsiColor := color.new(#FF1744, 60)
else if inOB
    rsiColor := C_BEAR
else if inOS
    rsiColor := C_BULL
else if inBull
    rsiColor := C_BULL_D
else
    rsiColor := C_BEAR_D

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓊖 𓂀 15 · BACKGROUND FRESCOES 𓂀 𓊖
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
bgcolor(inOB ? color.new(#FF1744, 88) : na, title="OB Zone")
bgcolor(inOS ? color.new(#00E676, 88) : na, title="OS Zone")
bgcolor(inBull and not inOB ? color.new(#00E676, 93) : na)
bgcolor(inBear and not inOS ? color.new(#FF1744, 93) : na)
bgcolor(rsiSqueeze ? color.new(#FFD600, 93) : na, title="RSI Squeeze Background")

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓆣 𓊹 16 · TEMPLE VISUAL HELICES 𓊹 𓆣
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
plot(showDNA ? dnaStrand1 : na, "DNA 1", color=C_CYAN_D, linewidth=2, style=plot.style_line)
plot(showDNA ? dnaStrand2 : na, "DNA 2", color=C_PURP_D, linewidth=2, style=plot.style_line)
plot(showDNA and dnaRung ? dnaStrand1 : na, "DNA Rung1", color=C_CYAN, linewidth=2, style=plot.style_circles)
plot(showDNA and dnaRung ? dnaStrand2 : na, "DNA Rung2", color=C_PURP, linewidth=2, style=plot.style_circles)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓇌 𓇳 17 · ROYAL RSI LINE 𓇳 𓇌
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
rsiHist   = rsiDisplay - rsiMid
histColor = rsiHist >= 0 ? (rsiMasked ? color.new(#00E676, 78) : C_BULL_G) : (rsiMasked2 ? color.new(#FF1744, 88) : C_BEAR_G)

plot(rsiHist, "RSI Histogram", color=histColor, style=plot.style_columns, linewidth=3)
plot(rsiDisplay, "RSI", color=rsiColor, linewidth=3)
plot(useHA ? rsiRaw : na, "RSI Raw", color=color.new(#546E7A, 35), linewidth=2, style=plot.style_line)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓏏 𓂀 18 · RSI COMPRESSION DOTS 𓂀 𓏏
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
plot(rsiSqueeze ? rsiMid : na, "RSI Squeeze Dot", color=C_GOLD, linewidth=3, style=plot.style_circles)
plot(sqReleaseBull ? rsiMid + sqRelease : na, "RSI Squeeze Bull Release", color=C_BULL, linewidth=4, style=plot.style_circles)
plot(sqReleaseBear ? rsiMid - sqRelease : na, "RSI Squeeze Bear Release", color=C_BEAR, linewidth=4, style=plot.style_circles)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓈙 𓊃 19 · NILE HORIZONTAL THRESHOLDS 𓊃 𓈙
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
hline(rsiOB, "OB", color=color.new(#FF1744, 35), linestyle=hline.style_dashed, linewidth=1)
hline(rsiOS, "OS", color=color.new(#00E676, 35), linestyle=hline.style_dashed, linewidth=1)
hline(rsiMid, "Mid", color=color.new(#546E7A, 35), linestyle=hline.style_dotted, linewidth=1)
hline(60, "60", color=color.new(#FF9100, 55), linestyle=hline.style_dotted, linewidth=1)
hline(40, "40", color=color.new(#00B0FF, 55), linestyle=hline.style_dotted, linewidth=1)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓏲 𓈖 20 · VOLUME COLUMNS 𓈖 𓏲
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
volPlotVal   = showVolP ? volNorm : na
volPlotColor = volSpike ? color.new(#FFD600, 40) : color.new(#546E7A, 65)
plot(volPlotVal, "Volume Profile", color=volPlotColor, style=plot.style_columns, linewidth=volPBars)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓁹 𓂀 21 · SIGNAL ORACLES 𓂀 𓁹
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
crossBullRaw  = ta.crossover(rsiDisplay, rsiMid)
crossBearRaw  = ta.crossunder(rsiDisplay, rsiMid)
crossBull  = crossBullRaw and bullFilterOk
crossBear  = crossBearRaw and bearFilterOk
enterOB    = ta.crossover(rsiDisplay, rsiOB)
exitOB     = ta.crossunder(rsiDisplay, rsiOB)
enterOS    = ta.crossunder(rsiDisplay, rsiOS)
exitOS     = ta.crossover(rsiDisplay, rsiOS)
haBullFlip = useHA and haBull and not haBull[1] and bullFilterOk
haBearFlip = useHA and haBear and not haBear[1] and bearFilterOk

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓁹 𓊹 22 · MAIN CHART CANDLE COLORS 𓊹 𓁹
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
hlStructBull = high > high[1] and low > low[1]
hlStructBear = high < high[1] and low < low[1]
candleModeBull = candleColorMode == "RSI Midline" ? inBull : candleColorMode == "HTF Bias" ? htfBull : hlStructBull
candleModeBear = candleColorMode == "RSI Midline" ? inBear : candleColorMode == "HTF Bias" ? htfBear : hlStructBear
color mainCandleColor = na
if candleModeBull
    mainCandleColor := color.new(#5C7C70, 0)
else if candleModeBear
    mainCandleColor := color.new(#8A5F5F, 0)
else if colorNeutralBars
    mainCandleColor := color.new(#546E7A, 55)
barcolor(useCandleColor ? mainCandleColor : na, title="RSI Wizard Main Chart Candle Color")

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓅓 𓇋 22 · OB / OS SEALS 𓇋 𓅓
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
if enterOB
    label.new(bar_index, rsiOB + 1, "OB", color=color.new(#FF1744, 10), textcolor=color.new(#FFFFFF, 0), style=label.style_label_down, size=size.tiny)

if enterOS
    label.new(bar_index, rsiOS - 1, "OS", color=color.new(#00E676, 10), textcolor=color.new(#000000, 0), style=label.style_label_up, size=size.tiny)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓊃 𓅓 23 · DIVERGENCE SEALS 𓅓 𓊃
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
if regDivBull and not na(plBar1) and not na(rl1)
    label.new(plBar1, rl1 - 1.0, useVolDiv ? "DIV+ V" : "DIV+", color=color.new(#00E676, 0), textcolor=color.new(#000000, 0), style=label.style_label_up, size=size.tiny)

if regDivBear and not na(phBar1) and not na(rh1)
    label.new(phBar1, rh1 + 1.0, useVolDiv ? "DIV- V" : "DIV-", color=color.new(#FF1744, 0), textcolor=color.new(#FFFFFF, 0), style=label.style_label_down, size=size.tiny)

if hidDivBull and not na(plBar1) and not na(rl1)
    label.new(plBar1, rl1 - 1.0, useVolDiv ? "hDIV+ V" : "hDIV+", color=color.new(#00E5FF, 0), textcolor=color.new(#000000, 0), style=label.style_label_up, size=size.tiny)

if hidDivBear and not na(phBar1) and not na(rh1)
    label.new(phBar1, rh1 + 1.0, useVolDiv ? "hDIV- V" : "hDIV-", color=color.new(#CE93D8, 0), textcolor=color.new(#000000, 0), style=label.style_label_down, size=size.tiny)

if sqReleaseBull
    label.new(bar_index, rsiMid + sqRelease - 1.0, "SQ+", color=color.new(#00E676, 0), textcolor=color.new(#000000, 0), style=label.style_label_up, size=size.tiny)

if sqReleaseBear
    label.new(bar_index, rsiMid - sqRelease + 1.0, "SQ-", color=color.new(#FF1744, 0), textcolor=color.new(#FFFFFF, 0), style=label.style_label_down, size=size.tiny)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓃭 𓎛 24 · HA CANDLE HIEROGLYPHS 𓎛 𓃭
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
haBodyTop   = math.max(haRsiO, haRsiC)
haBodyBot   = math.min(haRsiO, haRsiC)
haBodyColor = haBull ? color.new(#00E676, 15) : color.new(#FF1744, 15)

plot(useHA ? haBodyTop : na, "HA Body Top", color=color.new(#000000, 100), display=display.none)
plot(useHA ? haBodyBot : na, "HA Body Bot", color=color.new(#000000, 100), display=display.none)
plot(useHA ? haRsiH : na, "HA High", color=haBodyColor, linewidth=2, style=plot.style_circles)
plot(useHA ? haRsiL : na, "HA Low", color=haBodyColor, linewidth=2, style=plot.style_circles)
plot(useHA ? haRsiO : na, "HA Open", color=color.new(#fffb00, 60), linewidth=2, style=plot.style_line)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓂀 𓊝 25 · ROYAL COMMAND TABLE 𓊝 𓂀
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
var table dash = table.new(position.top_right, 2, 13, border_color=color.new(#129412, 35), border_width=1, frame_color=color.new(#129412, 35), frame_width=1)

if barstate.islast
    table.cell(dash, 0, 0, "RSI OSC", bgcolor=color.new(#0dff00, 35), text_color=color.new(#001A1F, 0), text_size=size.tiny)
    table.cell(dash, 1, 0, "v2.0", bgcolor=color.new(#0dff00, 35), text_color=color.new(#001A1F, 0), text_size=size.tiny)
    rsiRounded = math.round(rsiDisplay * 10.0) / 10.0
    rsiCol = rsiDisplay > rsiOB ? C_BEAR : rsiDisplay < rsiOS ? C_BULL : rsiDisplay > rsiMid ? C_BULL_D : C_BEAR_D
    table.cell(dash, 0, 1, "RSI", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(rsiRounded), bgcolor=color.new(#0A1628, 12), text_color=rsiCol, text_size=size.tiny)
    trendStr = inBull ? "BULL" : "BEAR"
    trendCol = inBull ? C_BULL : C_BEAR
    table.cell(dash, 0, 2, "TREND", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
    table.cell(dash, 1, 2, trendStr, bgcolor=color.new(#0A1628, 12), text_color=trendCol, text_size=size.tiny)
    zoneStr = inOB ? "OVERBOUGHT" : inOS ? "OVERSOLD" : inBull ? "bull zone" : "bear zone"
    zoneCol = inOB ? C_BEAR : inOS ? C_BULL : inBull ? C_BULL_D : C_BEAR_D
    zoneBg  = inOB ? color.new(#FF1744, 78) : inOS ? color.new(#00E676, 78) : color.new(#0A1628, 12)
    table.cell(dash, 0, 3, "ZONE", bgcolor=zoneBg, text_color=color.new(#546E7A, 0), text_size=size.tiny)
    table.cell(dash, 1, 3, zoneStr, bgcolor=zoneBg, text_color=zoneCol, text_size=size.tiny)
    divStr = regDivBull ? "DIV+" : regDivBear ? "DIV-" : hidDivBull ? "hDIV+" : hidDivBear ? "hDIV-" : "none"
    divStr := useVolDiv and divStr != "none" ? divStr + " V" : divStr
    divCol = regDivBull ? C_BULL : regDivBear ? C_BEAR : hidDivBull ? C_CYAN_D : hidDivBear ? C_PURP_D : color.new(#546E7A, 0)
    table.cell(dash, 0, 4, "DIV", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
    table.cell(dash, 1, 4, divStr, bgcolor=color.new(#0A1628, 12), text_color=divCol, text_size=size.tiny)
    volRounded = math.round(volRat * 100.0) / 100.0
    volStr2 = str.tostring(volRounded) + "x" + (volSpike ? " SPIKE" : "")
    volCol2 = volSpike ? C_GOLD : color.new(#546E7A, 0)
    table.cell(dash, 0, 5, "VOL", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
    table.cell(dash, 1, 5, volStr2, bgcolor=color.new(#0A1628, 12), text_color=volCol2, text_size=size.tiny)
    htfStr = useHTFFilter ? (htfBull ? "BULL" : htfBear ? "BEAR" : "MIXED") : "OFF"
    htfCol = htfBull ? C_BULL : htfBear ? C_BEAR : color.new(#546E7A, 0)
    table.cell(dash, 0, 6, "HTF", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
    table.cell(dash, 1, 6, htfStr + " " + htfTf, bgcolor=color.new(#0A1628, 12), text_color=useHTFFilter ? htfCol : color.new(#546E7A, 0), text_size=size.tiny)
    if showMtfMatrix
        table.cell(dash, 0, 7, "RSI " + mtfTf1, bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 7, f_fmt1(mtfRsi1) + " " + f_rsi_state(mtfRsi1), bgcolor=color.new(#0A1628, 12), text_color=f_rsi_col(mtfRsi1), text_size=size.tiny)
        table.cell(dash, 0, 8, "RSI " + mtfTf2, bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 8, f_fmt1(mtfRsi2) + " " + f_rsi_state(mtfRsi2), bgcolor=color.new(#0A1628, 12), text_color=f_rsi_col(mtfRsi2), text_size=size.tiny)
        table.cell(dash, 0, 9, "RSI " + mtfTf3, bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 9, f_fmt1(mtfRsi3) + " " + f_rsi_state(mtfRsi3), bgcolor=color.new(#0A1628, 12), text_color=f_rsi_col(mtfRsi3), text_size=size.tiny)
        table.cell(dash, 0, 10, "RSI " + mtfTf4, bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 10, f_fmt1(mtfRsi4) + " " + f_rsi_state(mtfRsi4), bgcolor=color.new(#0A1628, 12), text_color=f_rsi_col(mtfRsi4), text_size=size.tiny)
        table.cell(dash, 0, 11, "RSI " + mtfTf5, bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 11, f_fmt1(mtfRsi5) + " " + f_rsi_state(mtfRsi5), bgcolor=color.new(#0A1628, 12), text_color=f_rsi_col(mtfRsi5), text_size=size.tiny)
        table.cell(dash, 0, 12, "RSI " + mtfTf6, bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 12, f_fmt1(mtfRsi6) + " " + f_rsi_state(mtfRsi6), bgcolor=color.new(#0A1628, 12), text_color=f_rsi_col(mtfRsi6), text_size=size.tiny)
    else
        table.cell(dash, 0, 7, "MTF", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 7, "OFF", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 0, 8, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 8, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 0, 9, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 9, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 0, 10, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 10, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 0, 11, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 11, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 0, 12, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)
        table.cell(dash, 1, 12, "", bgcolor=color.new(#0A1628, 12), text_color=color.new(#546E7A, 0), text_size=size.tiny)

// 𓂀════════════════════════════════════════════════════════════════════════𓂀
//        𓁹 𓇳 26 · TEMPLE SENTINELS 𓇳 𓁹
// 𓂀════════════════════════════════════════════════════════════════════════𓂀
alertcondition(crossBull,  "DNA OSC — Bull Midline Cross",         "RSI crosses above the midline")
alertcondition(crossBear,  "DNA OSC — Bear Midline Cross",         "RSI crosses below the midline")

alertcondition(enterOB,    "DNA OSC — Enter Overbought",           "RSI enters overbought")
alertcondition(exitOB,     "DNA OSC — Exit Overbought",            "RSI exits overbought")
alertcondition(enterOS,    "DNA OSC — Enter Oversold",             "RSI enters oversold")
alertcondition(exitOS,     "DNA OSC — Exit Oversold",              "RSI exits oversold")

alertcondition(regDivBull, "DNA OSC — Regular Bull Divergence",    "Regular Bull Divergence detected")
alertcondition(regDivBear, "DNA OSC — Regular Bear Divergence",    "Regular Bear Divergence detected")
alertcondition(hidDivBull, "DNA OSC — Hidden Bull Divergence",     "Hidden Bull Divergence detected")
alertcondition(hidDivBear, "DNA OSC — Hidden Bear Divergence",     "Hidden Bear Divergence detected")

alertcondition(haBullFlip, "DNA OSC — HA Bull Flip",               "Heiken Ashi RSI flips bullish")
alertcondition(haBearFlip, "DNA OSC — HA Bear Flip",               "Heiken Ashi RSI flips bearish")

alertcondition(volSpike,   "DNA OSC — Volume Spike",               "Volume spike detected")

alertcondition(rsiMasked,  "DNA OSC — RSI Bear Masked By HA Bull", "Opposite bearish RSI candle masked while HA is bullish")
alertcondition(rsiMasked2, "DNA OSC — RSI Bull Masked By HA Bear", "Opposite bullish RSI candle masked while HA is bearish")

alertcondition(fsBull, "DNA OSC — Bull Failure Swing", "Bullish RSI failure swing confirmed")
alertcondition(fsBear, "DNA OSC — Bear Failure Swing", "Bearish RSI failure swing confirmed")
alertcondition(rsiSqueeze, "DNA OSC — RSI Squeeze", "RSI is compressed around the midline")
alertcondition(sqReleaseBull, "DNA OSC — RSI Squeeze Bull Release", "RSI releases upward after squeeze")
alertcondition(sqReleaseBear, "DNA OSC — RSI Squeeze Bear Release", "RSI releases downward after squeeze")
alertcondition(useHTFFilter and not bullFilterOk and not bearFilterOk, "DNA OSC — HTF Mixed Bias", "HTF bias filter is mixed or neutral")
````
