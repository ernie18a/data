# daPisa MA + RSI

- url: https://www.tradingview.com/script/5CSQ1y2w-daPisa-MA-RSI/
- type: indicator
- pine_id: PUB;9da71b55d88e455a8bcbcce96cae4b18
- version: 1.0

## Description

daPisa + Simple RSI Div: Multi-Confluence Trend & Reversal Suite
The daPisa + Simple RSI Div (Pine Script v6) is an all-in-one technical analysis dashboard designed to blend structural trend-following with high-probability momentum exhaustion signals. By housing Dual Moving Averages, Bollinger Bands, an optimized RSI Divergence engine, and a Stochastic Oscillator within a single script, it provides traders with a clean, clutter-free workspace to identify confluence zones, trend reversals, and volatility breakouts.

🛠️ Key Components & Architecture
1. Primary Chart Elements (Force Overlay)
Dual Moving Averages: Tracks structural market direction utilizing a Fast MA (50) and a Slow MA (120). Trend shifts are explicitly highlighted on your main chart using Blue Intersection Marks at crossover/crossunder points.

Price Bollinger Bands: Displays standard volatility bands (20 Length, 2 StdDev) directly on the price chart to gauge squeeze phases and extension targets.

2. Advanced RSI Engine (Sub-Chart)
Native-Style RSI line: Built using TradingView's default algorithm for seamless continuity.

Flexible RSI-Based MA Options: Replicates default TV features by allowing you to choose between SMA, EMA, or Bollinger Bands applied directly to the RSI value. This helps filter out momentum noise and signals line crossovers or volatility bands expansion within the oscillator panel itself.

Filtered Divergence Alerts: Triggers clean Bullish and Bearish divergence markers.

3. Secondary Momentum Panel
Stochastic Oscillator: A fully adjustable Stochastic (%K, %D) line designed to act as a secondary trigger engine for fine-tuning entry windows when price interacts with major support/resistance or structural MA lines.

🎯 What Makes This Script Unique?
Anti-Clutter Divergence Logic: Traditional divergence indicators often suffer from "signal crowding" or over-plotting. This script utilizes precise, micro-pivot lookbacks (pivothigh/low 1, 1). Signals are evaluated exactly at the moment of pivot validation and plotted using a -1 bar offset to align perfectly with the exact price peak/trough.

Strict Exhaustion Filters: Divergences are only displayed if they occur within Overbought (≥70) or Oversold (≤30) territories. This drastically reduces false signals during choppy, sideways markets.

Customizable UI Toggles: Keep your chart workspace clean. You can toggle off the visual displays for the RSI or Stochastic panels individually with simple tick boxes in the settings menu.

💡 How to Trade with This Indicator
Trend Alignment: Identify the macro trend using the Fast and Slow MA crossovers. Look for price pullbacks toward the MA lines or the lower/upper Bollinger Bands.

Reversal Confirmation: Spot potential tops or bottoms when price prints higher highs/lower lows while the RSI plots a strict, overbought/oversold Divergence Arrow.

Execution Trigger: Use the Stochastic crossover (%K crossing %D) inside extreme zones to find the exact execution candle once the macro trend and RSI divergence have aligned.

🔔 Integrated Real-Time Alerts
This indicator comes pre-packaged with 6 essential alert conditions to keep you ahead of the market without constantly staring at the screen:

MA Golden Cross (Fast MA crosses above Slow MA)

MA Death Cross (Fast MA crosses below Slow MA)

RSI Bearish Divergence (Confirmed top reversal setup)

RSI Bullish Divergence (Confirmed bottom reversal setup)

Stoch Bullish Cross (%K crossing above %D)

Stoch Bearish Cross (%K crossing below %D)

Disclaimer: Past performance does not guarantee future results. Always practice proper risk management and utilize this script alongside your broader trading framework.

## Source Code

````pine
//@version=6
indicator("MA+RSI_daPisa", overlay=false, max_labels_count=500)

// =========================================================================
// --- INPUT TOGGLES (CENTANG AKTIF/NONAKTIF) ---
// =========================================================================
bool showRSI   = input.bool(true, title="Tampilkan RSI", group="📌 CHART BAWAH: Toggle On/Off")
bool showStoch = input.bool(true, title="Tampilkan Stochastic", group="📌 CHART BAWAH: Toggle On/Off")

// =========================================================================
// --- INPUT CHART ATAS (MA & BB) ---
// =========================================================================
int fastLen = input.int(50, title="Fast MA Length", minval=1, group="📌 CHART ATAS: Moving Average")
int slowLen = input.int(120, title="Slow MA Length", minval=1, group="📌 CHART ATAS: Moving Average")
int bbLen   = input.int(20, title="BB Length", minval=1, group="📌 CHART ATAS: Bollinger Bands")
float bbMult  = input.float(2.0, title="BB StdDev", minval=0.001, step=0.1, group="📌 CHART ATAS: Bollinger Bands")

// =========================================================================
// --- INPUT CHART BAWAH (RSI DEFAULT) ---
// =========================================================================
int rsiLen   = input.int(14, title="RSI Length", group="📌 CHART BAWAH: RSI Settings")
float rsiOB    = input.float(70.0, title="Overbought Level", group="📌 CHART BAWAH: RSI Settings")
float rsiOS    = input.float(30.0, title="Oversold Level", group="📌 CHART BAWAH: RSI Settings")

// --- INPUT RSI BASED MA (SAMA PERSIS DENGAN DEFAULT TRADINGVIEW) ---
string maType   = input.string("SMA", title="MA Type", options=["SMA", "EMA", "Bollinger Bands"], group="📌 CHART BAWAH: RSI Based MA")
int maLen    = input.int(13, title="MA Length", group="📌 CHART BAWAH: RSI Based MA")
float bbMultRsi= input.float(2.0, title="BB StdDev (If BB)", step=0.1, group="📌 CHART BAWAH: RSI Based MA")

// =========================================================================
// --- INPUT CHART BAWAH (STOCHASTIC OSCILLATOR) ---
// =========================================================================
int kLen     = input.int(14, title="%K Length", group="📌 CHART BAWAH: Stochastic Settings")
int kSmooth  = input.int(3, title="%K Smoothing", group="📌 CHART BAWAH: Stochastic Settings")
int dLen     = input.int(3, title="%D Smoothing", group="📌 CHART BAWAH: Stochastic Settings")
float stochOB  = input.float(80.0, title="Stoch Overbought Level", group="📌 CHART BAWAH: Stochastic Settings")
float stochOS  = input.float(20.0, title="Stoch Oversold Level", group="📌 CHART BAWAH: Stochastic Settings")

// =========================================================================
// --- PERHITUNGAN CHART ATAS (MA & BB) ---
// =========================================================================
float fastMA = ta.sma(close, fastLen)
float slowMA = ta.sma(close, slowLen)
[bbMiddle, bbUpper, bbLower] = ta.bb(close, bbLen, bbMult) // PERBAIKAN ERROR: Menghapus float di dalam kurung siku

// =========================================================================
// --- PERHITUNGAN CHART BAWAH (RSI DEFAULT) ---
// =========================================================================
float rsiVal = ta.rsi(close, rsiLen)

// --- PERHITUNGAN RSI BASED MA ---
float rsiSMA = ta.sma(rsiVal, maLen)
float rsiEMA = ta.ema(rsiVal, maLen)
[rsiBBMid, rsiBBUp, rsiBBLo] = ta.bb(rsiVal, maLen, bbMultRsi) // PERBAIKAN ERROR: Menghapus float di dalam kurung siku

// Logika pemilihan MA
float rsiMA_line = maType == "SMA" ? rsiSMA : maType == "EMA" ? rsiEMA : rsiBBMid

// =========================================================================
// --- LOGIKA DIVERGENCE SEDERHANA + FILTER OB/OS (AKURAT DI TITIK PUNCAK) ---
// =========================================================================
float peakRsi = ta.pivothigh(rsiVal, 1, 1) 
float troughRsi = ta.pivotlow(rsiVal, 1, 1)

bool isPeak = not na(peakRsi)
bool isTrough = not na(troughRsi)

// Menyimpan data puncak (High) secara akurat
var float lastPeakRsi = na
var float lastPeakPrice = na
var float prevPeakRsi = na
var float prevPeakPrice = na

if isPeak
    prevPeakRsi := lastPeakRsi
    prevPeakPrice := lastPeakPrice
    lastPeakRsi := peakRsi
    lastPeakPrice := high[1] // High terjadi di bar sebelum konfirmasi pivot

// Menyimpan data lembah (Low) secara akurat
var float lastTroughRsi = na
var float lastTroughPrice = na
var float prevTroughRsi = na
var float prevTroughPrice = na

if isTrough
    prevTroughRsi := lastTroughRsi
    prevTroughPrice := lastTroughPrice
    lastTroughRsi := troughRsi
    lastTroughPrice := low[1] // Low terjadi di bar sebelum konfirmasi pivot

// Perbandingan Sederhana + Validasi Level Overbought/Oversold:
bool bearDiv = isPeak and lastPeakPrice > prevPeakPrice and lastPeakRsi < prevPeakRsi and (lastPeakRsi >= rsiOB or prevPeakRsi >= rsiOB)
bool bullDiv = isTrough and lastTroughPrice < prevTroughPrice and lastTroughRsi > prevTroughRsi and (lastTroughRsi <= rsiOS or prevTroughRsi <= rsiOS)

// =========================================================================
// --- PERHITUNGAN CHART BAWAH (STOCHASTIC) ---
// =========================================================================
float k = ta.sma(ta.stoch(close, high, low, kLen), kSmooth)
float d = ta.sma(k, dLen)

// =========================================================================
// --- PLOT KE CHART ---
// =========================================================================

// 1. MA & BB (Chart Atas)
plot(fastMA, color=color.orange, linewidth=1, title="Fast MA (50)", force_overlay=true)
plot(slowMA, color=color.red, linewidth=2, title="Slow MA (120)", force_overlay=true)
plot(bbUpper, color=color.new(color.purple, 30), style=plot.style_stepline, title="BB Upper", force_overlay=true)
plot(bbLower, color=color.new(color.purple, 30), style=plot.style_stepline, title="BB Lower", force_overlay=true)
plot(bbMiddle, color=color.new(color.purple, 50), style=plot.style_stepline, title="BB Basis", force_overlay=true)

// 2. RSI (Chart Bawah)
plot(showRSI ? rsiVal : na, color=color.new(color.blue, 0), title="RSI Line", linewidth=2)
plot(showRSI ? rsiMA_line : na, color=color.new(color.orange, 0), title="RSI MA Line", linewidth=1)

// Plot Bollinger Bands on RSI
pRsiBBUp = plot((showRSI and maType == "Bollinger Bands") ? rsiBBUp : na, color=color.new(color.gray, 30), title="RSI BB Upper")
pRsiBBLo = plot((showRSI and maType == "Bollinger Bands") ? rsiBBLo : na, color=color.new(color.gray, 30), title="RSI BB Lower")
fill(pRsiBBUp, pRsiBBLo, color=color.new(color.gray, 90), title="RSI BB Fill")

hline(showRSI ? rsiOB : na, color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(showRSI ? rsiOS : na, color=color.new(color.green, 50), linestyle=hline.style_dashed)

// Tanda Panah Divergence RSI (Muncul dan digeser offset=-1 agar tepat di puncak/lembah aslinya)
plotshape((showRSI and bearDiv) ? rsiVal[1] : na, title="Bearish Div", style=shape.triangledown, location=location.absolute, color=color.red, size=size.small, offset=-1)
plotshape((showRSI and bullDiv) ? rsiVal[1] : na, title="Bullish Div", style=shape.triangleup, location=location.absolute, color=color.green, size=size.small, offset=-1)

// 3. Stochastic Oscillator (Chart Bawah)
plot(showStoch ? k : na, color=color.new(color.aqua, 0), title="Stoch %K", linewidth=1)
plot(showStoch ? d : na, color=color.new(color.orange, 0), title="Stoch %D", linewidth=1)
hline(showStoch ? stochOB : na, color=color.new(color.red, 30), linestyle=hline.style_dotted)
hline(showStoch ? stochOS : na, color=color.new(color.green, 30), linestyle=hline.style_dotted)

// =========================================================================
// --- LOGIKA CROSSOVER MA & TANDA PERPOTONGAN (DI CHART ATAS) ---
// =========================================================================
bool allCross = ta.cross(fastMA, slowMA)
bool goldenCross = ta.crossover(fastMA, slowMA)
bool deathCross  = ta.crossunder(fastMA, slowMA)

plotshape(allCross ? fastMA : na, title="Intersection Mark", style=shape.circle, location=location.absolute, color=color.blue, size=size.tiny, force_overlay=true)

// =========================================================================
// --- ALERTS ---
// =========================================================================
alertcondition(goldenCross, title="MA Golden Cross", message="Fast MA crossed above Slow MA")
alertcondition(deathCross, title="MA Death Cross", message="Fast MA crossed below Slow MA")
alertcondition(bearDiv, title="RSI Bearish Divergence", message="RSI Bearish Divergence Detected (Overbought)!")
alertcondition(bullDiv, title="RSI Bullish Divergence", message="RSI Bullish Divergence Detected (Oversold)!")
alertcondition(ta.crossover(k, d), title="Stoch Bullish Cross", message="Stochastic %K crossed above %D")
alertcondition(ta.crossunder(k, d), title="Stoch Bearish Cross", message="Stochastic %K crossed below %D")
````
