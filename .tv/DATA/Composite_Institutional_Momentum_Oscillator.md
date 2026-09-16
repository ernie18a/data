<!-- tradingview-pine-id: PUB;f07f3f4ed68b4927a548db9c4d547f7e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Composite Institutional Momentum Oscillator

Source: https://www.tradingview.com/script/mL3MpJpp-Composite-Institutional-Momentum-Oscillator-CMO/

## Description

📊 Composite Institutional Momentum Oscillator [CMO]

The Composite Institutional Momentum Oscillator (CMO) is an advanced, volume-weighted momentum oscillator originally engineered for Bitcoin and Crypto markets, yet fully optimized to perform seamlessly across all asset classes and sectors—including Stocks, Forex, Indices, and Commodities. 📈

By pairing short-term price velocity with synthetic order flow delta, volume absorption metrics, and multi-timeframe alignment, CMO filters out market noise to isolate true institutional positioning and trend expansion regardless of the traded asset. 🔥

🔍 How Order Flow & Absorption Work Across Markets
Because traditional Pine Script environment variables process completed transactions bar-by-bar rather than raw Level 2 limit order books, CMO utilizes robust algorithmic estimations derived from volume and intra-bar price action:
* ⚡ Synthetic Volume Delta Estimate: Approximates aggressive market buying versus market selling pressure per bar based on the close position within the high-low candle range ($\text{bullVol} \text{ vs. } \text{bearVol}$).
* 🛡️ Stealth Absorption Detection: Identifies hidden limit-order wall absorption by tracking Volume Efficiency ($\frac{\text{Volume}}{\text{Candle Range}}$). Abnormally high volume occurring inside narrow price ranges flags institutional limit orders absorbing aggressive market flow without letting price slip.

⭐ Key Features
* 🌐 Universal Multi-Asset Optimization: Engineered around Bitcoin's high volatility dynamics, making it exceptionally sharp at detecting momentum shifts in standard equities, forex pairs, and commodities.
* ⚖️ Order Flow & Stealth Absorption Weighting: Dynamically scales momentum signals using synthetic delta and volume efficiency ratios to capture true institutional effort.
* 🚀 Dual-WMA Velocity Core: Combines fast and slow Weighted Moving Average calculations to capture responsive directional changes while reducing false breakout signals during sideways consolidation.
* ⚓ Normalized CIMA Anchor: Anchors momentum against a long-term macro cost basis (510-period default) scaled by rolling standard deviation.
* 🎯 Liquidity Sweep Detection: Automatically flags potential institutional stop-hunts when price temporarily breaches macro high/low boundaries before reclaiming them.
* 🧠 Synthetic Fear & Greed Index: Computes a real-time 0–100 market sentiment score integrating volatility ratios, relative momentum positioning, and standard 14-period RSI metrics.
* 🖥️ On-Chart Status Dashboard: Provides an active HUD readout of macro trend alignment, micro trend bias, local momentum phase, and real-time sentiment metrics.

💡 Trading Guidance (Crypto, Stocks, Forex & Commodities)
* 🟢 Bullish / Bearish Expansion: A CMO line breach above +1.0 (or below -1.0) alongside daily MTF alignment confirms high-probability institutional trend expansion.
* 🔄 Accumulation / Distribution: Oscillations between 0.05 and 1.0 signal controlled accumulation phases, while values between -0.05 and -1.0 indicate steady distribution.
* 🧹 Liquidity Sweeps: Highlighted markers identify rapid false breaches of macro highs/lows, offering high-reward mean-reversion entries in the direction of the higher-timeframe trend.
* ⚠️ Extreme Sentiment Reversals: Fear & Greed index values above 75 (Extreme Greed) or below 25 (Extreme Fear) alert traders to overextended leverage and imminent pullback potential.

⚙️ Input Settings
Parameter	Default	Description
MTF Trend Filter Frame	1440 (1D)	Higher timeframe resolution used to establish macro directional trend bias.
Price Source	ohlc4	Calculation source for momentum and volume algorithms.
Macro Baseline Lookback	510	Lookback period for institutional cost basis and standard deviation bounds.
Micro Baseline Lookback	63	Slow period for dual-WMA velocity calculations.
CMO Length	12	Fast period for dual-WMA velocity calculations.
Enable Order Flow Delta	True	Toggles synthetic volume delta weighting in composite momentum formulas.
Enable Stealth Absorption	True	Toggles volume efficiency weighting to detect hidden limit order absorption.

---

## Source Code

````pine
//@version=6
indicator("Composite Institutional Momentum Oscillator", shorttitle="CMO", overlay=false)

// --- Inputs ---
htfResolution  = input.timeframe("1440", "MTF Trend Filter Frame", tooltip="Higher timeframe resolution used to determine overall directional trend bias.")
priceSource    = input.source(ohlc4, "Price Source", tooltip="Select price calculation source.")
macroLength    = input.int(510, "Macro Baseline Lookback", minval=1, tooltip="Lookback window for calculating the institutional CIMA anchor and standard deviation bounds.")
MicroLength    = input.int(63, "Micro Baseline Lookback", minval=1, tooltip="Slow period for the Dual-WMA velocity calculation.")
CMOLength      = input.int(12, "CMOLength", minval=1, tooltip="Fast period for the Dual-WMA velocity calculation.")
useCvd         = input.bool(true, "Enable Order Flow Delta Factor", tooltip="Toggles cumulative volume delta weighting in the composite baseline.")
useAbsorp      = input.bool(true, "Enable Stealth Absorption Factor", tooltip="Toggles volume efficiency ratio weighting to detect hidden limit order absorption.")

// --- 1. Order Flow & Stealth Absorption Engine ---
bullVol   = (priceSource - low) / math.max(high - low, syminfo.mintick) * volume
bearVol   = (high - priceSource) / math.max(high - low, syminfo.mintick) * volume
delta     = bullVol - bearVol
cvdFactor = useCvd ? ta.sma(delta, CMOLength) : 1.0

candleRange      = math.max(high - low, syminfo.mintick)
volEfficiency    = volume / candleRange
avgEfficiency    = ta.sma(volEfficiency, macroLength)
absorptionWeight = useAbsorp ? (volEfficiency / math.max(avgEfficiency, syminfo.mintick)) : 1.0

// Composite Institutional Weight Formula
compositeWeight  = math.abs(cvdFactor) * absorptionWeight * volume
compositeWeight := math.max(compositeWeight, 1.0)

// --- 2. Macro Cost Basis Anchor ---
vwma126 = ta.sma(priceSource * compositeWeight, macroLength) / ta.sma(compositeWeight, macroLength)

// --- 3. Dual-WMA Momentum Core Engine ---
wmaFast    = ta.wma(priceSource, CMOLength)
wmaSlow    = ta.wma(priceSource, MicroLength)
dualWma    = (2 * wmaFast) - wmaSlow
dualWmaMom = ta.wma(dualWma, math.round(math.sqrt(CMOLength)))

// Normalized Momentum relative to CIMA Anchor
rawSignal  = (dualWmaMom - vwma126) / ta.stdev(priceSource, macroLength)
cimaEngine = ta.ema(rawSignal, 3)

// --- 4. Multi-Timeframe (MTF) Alignment Security Call ---
htfPrice   = request.security(syminfo.tickerid, htfResolution, priceSource, gaps=barmerge.gaps_off)
htfVwma    = request.security(syminfo.tickerid, htfResolution, ta.sma(priceSource * volume, macroLength) / ta.sma(volume, macroLength), gaps=barmerge.gaps_off)
htfBullish = htfPrice >= htfVwma

// --- 5. Liquidity Sweeps Engine ---
macroHighest = ta.highest(high, macroLength)[1]
macroLowest  = ta.lowest(low, macroLength)[1]

bullishSweep = (low < macroLowest) and (priceSource > macroLowest)
bearishSweep = (high > macroHighest) and (priceSource < macroHighest)

// --- 6. Synthetic Fear & Greed Engine (0 - 100) ---
volScore = math.min(math.max((1.0 - (ta.stdev(priceSource, 20) / ta.stdev(priceSource, macroLength))) * 50 + 25, 0), 100)
momScore = math.min(math.max((cimaEngine + 2.0) / 4.0 * 100, 0), 100)
rsiVal   = ta.rsi(priceSource, 14)

fearGreedIndex = (volScore * 0.25) + (momScore * 0.45) + (rsiVal * 0.30)

string fgText = "NEUTRAL"
color fgColor = #FFD700

if fearGreedIndex >= 75
    fgText  := "EXTREME GREED (" + str.tostring(math.round(fearGreedIndex)) + ")"
    fgColor := #FF0055
else if fearGreedIndex >= 55
    fgText  := "GREED (" + str.tostring(math.round(fearGreedIndex)) + ")"
    fgColor := #00E676
else if fearGreedIndex <= 25
    fgText  := "EXTREME FEAR (" + str.tostring(math.round(fearGreedIndex)) + ")"
    fgColor := #00E5FF
else if fearGreedIndex <= 45
    fgText  := "FEAR (" + str.tostring(math.round(fearGreedIndex)) + ")"
    fgColor := #FF1744
else
    fgText  := "NEUTRAL (" + str.tostring(math.round(fearGreedIndex)) + ")"
    fgColor := #FFD700

// --- Color & State Logic ---
color impulseColor        = color.gray
string htfStatusText      = htfBullish ? "BULLISH" : "BEARISH"
color htfStatusColor      = htfBullish ? #00E676 : #FF1744

bool microBullish         = priceSource >= wmaSlow
string microStatusText    = microBullish ? "BULLISH" : "BEARISH"
color microStatusColor    = microBullish ? #00E676 : #FF1744

string momentumStatusText  = "NEUTRAL"
color momentumStatusColor = color.gray

if cimaEngine > 1.0 and htfBullish
    impulseColor        := #00E676 // Strong MTF Bullish Expansion
    momentumStatusText  := "BULL EXPANSION"
    momentumStatusColor := #00E676
else if cimaEngine < -1.0 and not htfBullish
    impulseColor        := #FF1744 // Strong MTF Bearish Expansion
    momentumStatusText  := "BEAR EXPANSION"
    momentumStatusColor := #FF1744
else if bullishSweep and cimaEngine < 0
    impulseColor        := #00E5FF // Cyan Sweep
    momentumStatusText  := "BULL SWEEP"
    momentumStatusColor := #00E5FF
else if bearishSweep and cimaEngine > 0
    impulseColor        := #FF007F // Magenta Sweep
    momentumStatusText  := "BEAR SWEEP"
    momentumStatusColor := #FF007F
else if cimaEngine >= 0.05
    impulseColor        := #0288D1 // Blue Line
    momentumStatusText  := "ACCUMULATION"
    momentumStatusColor := #0288D1
else if cimaEngine <= -0.05
    impulseColor        := #E53935 // Red Line
    momentumStatusText  := "DISTRIBUTION"
    momentumStatusColor := #E53935
else
    impulseColor        := color.gray
    momentumStatusText  := "CONSOLIDATION"
    momentumStatusColor := color.gray

// --- Visual Outputs ---
plot(cimaEngine, "CMO Signal Curve", color=impulseColor, linewidth=2)

// Pure Momentum Histogram
histCol = cimaEngine > 0 ? color.new(#00E676, 75) : color.new(#FF1744, 75)
plot(cimaEngine, "CMO Momentum", color=histCol, style=plot.style_columns, histbase=0)

// Reference Bounds
hline(0, "Equilibrium", color=color.new(#818678, 60))
hUpper = hline(1.0, "Upper Bound (+1σ)", color=color.new(#00E676, 50), linestyle=hline.style_dashed)
hLower = hline(-1.0, "Lower Bound (-1σ)", color=color.new(#FF1744, 50), linestyle=hline.style_dashed)

fill(hUpper, hLower, color=#2196f30a, title="Equilibrium Zone")

// Sweeps
plotshape(bullishSweep, title="Bullish Liquidity Sweep", style=shape.triangleup, location=location.bottom, color=#00e5ff00, size=size.small)
plotshape(bearishSweep, title="Bearish Liquidity Sweep", style=shape.triangledown, location=location.top, color=#ff008000, size=size.small)

// --- Dashboard Status Table ---
var table infoTable = table.new(position = position.bottom_right, columns = 3, rows = 4, bgcolor = color.new(#363a45, 50), border_width = 1)

if barstate.islast
    // Row 0: Macro Baseline
    table.cell(infoTable, 0, 0, "Macro Baseline (" + str.tostring(macroLength) + "):", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 0, htfStatusText, text_color = htfStatusColor, text_size = size.small)
    
    // Row 1: Micro Baseline Anchor (63 WMA)
    table.cell(infoTable, 0, 1, "Micro Baseline (" + str.tostring(MicroLength) + "):", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 1, microStatusText, text_color = microStatusColor, text_size = size.small)

    // Row 2: Local Momentum Engine State
    table.cell(infoTable, 0, 2, "Momentum Phase:", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 2, momentumStatusText, text_color = momentumStatusColor, text_size = size.small)
    
    // Row 3: Fear & Greed Index
    table.cell(infoTable, 0, 3, "Fear & Greed:", text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 3, fgText, text_color = fgColor, text_size = size.small)

    // Artificial Margin Column
    table.cell(infoTable, 2, 0, "      ", bgcolor = color.new(color.black, 100))
    table.cell(infoTable, 2, 1, "      ", bgcolor = color.new(color.black, 100))
    table.cell(infoTable, 2, 2, "      ", bgcolor = color.new(color.black, 100))
    table.cell(infoTable, 2, 3, "      ", bgcolor = color.new(color.black, 100))
````
