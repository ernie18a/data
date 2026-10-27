# Composite Institutional Momentum Oscillator [CMO]

- url: https://www.tradingview.com/script/mL3MpJpp-Composite-Institutional-Momentum-Oscillator-CMO/
- type: indicator
- pine_id: PUB;f07f3f4ed68b4927a548db9c4d547f7e
- version: 2.0

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

## Source Code

````pine
//@version=6
indicator("Composite Institutional Momentum Oscillator (CMO) v9.13", shorttitle="CMO", overlay=false)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
var string G_TIMEFRAME = "Multi-Timeframe Locking Engine"
useTfLock      = input.bool(true, "Enable Timeframe Locking", group=G_TIMEFRAME, tooltip="When enabled, locks the CMO calculation engine to the specified timeframe regardless of chart resolution.")
cmoTf          = input.timeframe("1440", "Locked CMO Calculation Timeframe", group=G_TIMEFRAME, tooltip="Default '1440' sets calculation to 24 Hours (1 Day). Works across 8D, 3D, and intraday charts.")

var string G_TABLE_CTRL = "Dashboard Table Controls (Select Indicators)"
showBuffett    = input.bool(true, "Show Buffett Valuation Meter", group=G_TABLE_CTRL)
showFearGreed  = input.bool(true, "Show Fear & Greed Index", group=G_TABLE_CTRL)
showMacro      = input.bool(true, "Show Macro Baseline (510)", group=G_TABLE_CTRL)
showMicro      = input.bool(true, "Show Micro Baseline (63)", group=G_TABLE_CTRL)
showMomentum   = input.bool(true, "Show Momentum Phase", group=G_TABLE_CTRL)

var string G_CORE      = "Core Framework"
htfResolution  = input.timeframe("1440", "MTF Trend Filter Frame", group=G_CORE)
priceSource    = input.source(ohlc4, "Price Source", group=G_CORE)
macroLength    = input.int(510, "Macro Baseline Lookback", minval=1, group=G_CORE)
MicroLength    = input.int(63, "Micro Baseline Lookback", minval=1, group=G_CORE)
CMOLength      = input.int(12, "CMOLength", minval=1, group=G_CORE)
useCvd         = input.bool(true, "Enable Order Flow Delta Factor", group=G_CORE)
useAbsorp      = input.bool(true, "Enable Stealth Absorption Factor", group=G_CORE)
rsiLen         = input.int(14, "RSI Lookback Period", group=G_CORE)

// Active calculation timeframe logic
string activeTf = useTfLock ? cmoTf : timeframe.period

// ==========================================
// 2. CORE CMO ENGINE FUNCTION
// ==========================================
f_calcCMO() =>
    // --- Order Flow & Stealth Absorption Engine ---
    bullVol   = (priceSource - low) / math.max(high - low, syminfo.mintick) * volume
    bearVol   = (high - priceSource) / math.max(high - low, syminfo.mintick) * volume
    delta     = bullVol - bearVol
    cvdFactor = useCvd ? ta.sma(delta, CMOLength) : 1.0

    candleRange      = math.max(high - low, syminfo.mintick)
    volEfficiency    = volume / candleRange
    avgEfficiency    = ta.sma(volEfficiency, macroLength)
    absorptionWeight = useAbsorp ? (volEfficiency / math.max(avgEfficiency, syminfo.mintick)) : 1.0

    // Composite Weight Formula
    compositeWeight  = math.abs(cvdFactor) * absorptionWeight * volume
    compositeWeight := math.max(compositeWeight, 1.0)

    // --- Macro Cost Basis Anchor ---
    vwma126 = ta.sma(priceSource * compositeWeight, macroLength) / ta.sma(compositeWeight, macroLength)

    // --- Dual-WMA Momentum Core Engine ---
    wmaFast    = ta.wma(priceSource, CMOLength)
    wmaSlow    = ta.wma(priceSource, MicroLength)
    dualWma    = (2 * wmaFast) - wmaSlow
    dualWmaMom = ta.wma(dualWma, math.round(math.sqrt(CMOLength)))

    // Normalized Momentum relative to CIMA Anchor
    rawSignal  = (dualWmaMom - vwma126) / ta.stdev(priceSource, macroLength)
    cimaEngine = ta.ema(rawSignal, 3)

    // --- Liquidity Sweeps Engine ---
    macroHighest = ta.highest(high, macroLength)[1]
    macroLowest  = ta.lowest(low, macroLength)[1]

    bullishSweep = (low < macroLowest) and (priceSource > macroLowest)
    bearishSweep = (high > macroHighest) and (priceSource < macroHighest)

    // --- Synthetic Fear & Greed Engine (0 - 100) ---
    volScore = math.min(math.max((1.0 - (ta.stdev(priceSource, 20) / ta.stdev(priceSource, macroLength))) * 50 + 25, 0), 100)
    momScore = math.min(math.max((cimaEngine + 2.0) / 4.0 * 100, 0), 100)
    rsiVal   = ta.rsi(priceSource, rsiLen)

    fearGreedIndex = (volScore * 0.25) + (momScore * 0.45) + (rsiVal * 0.30)

    [cimaEngine, bullishSweep, bearishSweep, fearGreedIndex, priceSource >= wmaSlow, rsiVal]

// Fetch MTF Calculation Engine Values
[cimaEngine, bullishSweep, bearishSweep, fearGreedIndex, microBullish, rsiVal] = request.security(syminfo.tickerid, activeTf, f_calcCMO(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// MTF Trend Filter
htfPrice   = request.security(syminfo.tickerid, htfResolution, priceSource, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfVwma    = request.security(syminfo.tickerid, htfResolution, ta.sma(priceSource * volume, macroLength) / ta.sma(volume, macroLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
htfBullish = htfPrice >= htfVwma

// ==========================================
// 3. BUFFETT SENTIMENT & DIVERGENCE METER
// ==========================================
float lowestPricePrev  = ta.lowest(low[1], 20)
float lowestCimaPrev   = ta.lowest(cimaEngine[1], 20)
float highestPricePrev = ta.highest(high[1], 20)
float highestCimaPrev  = ta.highest(cimaEngine[1], 20)

bool bullDivergence = (low < lowestPricePrev) and (cimaEngine > lowestCimaPrev)
bool bearDivergence = (high > highestPricePrev) and (cimaEngine < highestCimaPrev)

float buffettScore = fearGreedIndex

if bullDivergence
    buffettScore := math.max(buffettScore - 15, 0)
if bearDivergence
    buffettScore := math.min(buffettScore + 15, 100)

string buffettText  = "WAIT FOR THE FAT PITCH"
color  buffettColor = #FFD700

if buffettScore <= 25
    buffettText  := "EXTREME FEAR: BE GREEDY (DEEP VALUE)"
    buffettColor := #00E5FF
else if buffettScore <= 42
    buffettText  := "FAT PITCH ACCUMULATION ZONE"
    buffettColor := #00E676
else if buffettScore >= 78
    buffettText  := "EXTREME GREED: BE FEARFUL (DISTRIBUTE)"
    buffettColor := #FF0055
else if buffettScore >= 60
    buffettText  := "MR. MARKET EUPHORIC (TAKE PROFITS)"
    buffettColor := #FF1744
else
    buffettText  := "WAIT FOR THE FAT PITCH (HOLD)"
    buffettColor := #FFD700

// ==========================================
// 4. TWO-PHASE ACCUMULATION RECLAIM ENGINE
// ==========================================
var bool hasCapitulated = false

if cimaEngine < -1.0
    hasCapitulated := true

bool accumulationReclaim = hasCapitulated and (cimaEngine >= -1.0) and (cimaEngine < 0.05)

if cimaEngine >= 0.05
    hasCapitulated := false

// ==========================================
// 5. FEAR & GREED TEXT FORMATTING
// ==========================================
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

// ==========================================
// 6. COLOR & STATE LOGIC
// ==========================================
color impulseColor        = color.gray
string htfStatusText      = htfBullish ? "BULLISH" : "BEARISH"
color htfStatusColor      = htfBullish ? #00E676 : #FF1744

string microStatusText    = microBullish ? "BULLISH" : "BEARISH"
color microStatusColor    = microBullish ? #00E676 : #FF1744

string momentumStatusText  = "NEUTRAL"
color momentumStatusColor = color.gray

string momText1  = "NEUTRAL"
string momText2  = ""
color  momColor1 = color.gray
color  momColor2 = color.new(color.white, 100)

if accumulationReclaim
    impulseColor        := #FF8C00 // Dark Orange line tone
    momText1            := "ACCUMULATION RECLAIM"
    momText2            := "(PROBABLE BASE)"
    momColor1           := #FF8C00 // Dark Orange
    momColor2           := #FFD700 // Gold
else if cimaEngine > 1.0 and htfBullish
    impulseColor        := #00E676 
    momText1            := "BULL EXPANSION"
    momText2            := ""
    momColor1           := #00E676
    momColor2           := color.new(color.white, 100)
else if cimaEngine < -1.0 and not htfBullish
    impulseColor        := #B71C1C 
    momText1            := "BEAR EXPANSION"
    momText2            := "(DEEP DISCOUNT)"
    momColor1           := #B71C1C 
    momColor2           := #00E676 
else if bullishSweep and cimaEngine < 0
    impulseColor        := #00E5FF 
    momText1            := "BULL SWEEP"
    momText2            := ""
    momColor1           := #00E5FF
    momColor2           := color.new(color.white, 100)
else if bearishSweep and cimaEngine > 0
    impulseColor        := #FF007F 
    momText1            := "BEAR SWEEP"
    momText2            := ""
    momColor1           := #FF007F
    momColor2           := color.new(color.white, 100)
else if cimaEngine >= 0.05
    impulseColor        := #0288D1 
    momText1            := "CONSOLIDATION"
    momText2            := "(CONTINUATION / REVERSAL)"
    momColor1           := #0288D1
    momColor2           := color.new(#e805bf, 0)
else if cimaEngine <= -0.05
    impulseColor        := #E53935 
    momText1            := "DISTRIBUTION"
    momText2            := ""
    momColor1           := #E53935
    momColor2           := color.new(color.white, 100)
else
    momText1            := "NEUTRAL"
    momText2            := ""
    momColor1           := color.gray
    momColor2           := color.new(color.white, 100)

// ==========================================
// 7. VISUAL OUTPUTS & PLOTS
// ==========================================
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

// Alert Conditions
alertcondition(ta.crossover(cimaEngine, -1.0) and hasCapitulated[1], title="CMO Buffett Accumulation Trigger", message="CMO Buffett Engine: Reclaim above -1.0 confirmed following Deep Discount Capitulation. Accumulation Zone Open.")

// ==========================================
// 8. DYNAMIC DASHBOARD STATUS TABLE (4 COLUMNS)
// ==========================================
var table infoTable = table.new(position = position.bottom_right, columns = 4, rows = 5, bgcolor = color.new(#363a45, 40), border_width = 1)

if barstate.islast
    int r = 0

    if showBuffett
        table.cell(infoTable, 0, r, "Buffett Valuation Meter:", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, r, buffettText, text_color = buffettColor, text_size = size.small)
        table.cell(infoTable, 2, r, "", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 3, r, "      ", bgcolor = color.new(color.black, 100))
        r += 1

    if showFearGreed
        table.cell(infoTable, 0, r, "Fear & Greed Index:", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, r, fgText, text_color = fgColor, text_size = size.small)
        table.cell(infoTable, 2, r, "", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 3, r, "      ", bgcolor = color.new(color.black, 100))
        r += 1

    if showMacro
        table.cell(infoTable, 0, r, "Macro Baseline (510):", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, r, htfStatusText, text_color = htfStatusColor, text_size = size.small)
        table.cell(infoTable, 2, r, "", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 3, r, "      ", bgcolor = color.new(color.black, 100))
        r += 1
        
    if showMicro
        table.cell(infoTable, 0, r, "Micro Baseline (63):", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, r, microStatusText, text_color = microStatusColor, text_size = size.small)
        table.cell(infoTable, 2, r, "", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 3, r, "      ", bgcolor = color.new(color.black, 100))
        r += 1

    if showMomentum
        table.cell(infoTable, 0, r, "Momentum Phase:", text_color = color.white, text_size = size.small)
        table.cell(infoTable, 1, r, momText1, text_color = momColor1, text_size = size.small)
        table.cell(infoTable, 2, r, momText2, text_color = momColor2, text_size = size.small)
        table.cell(infoTable, 3, r, "      ", bgcolor = color.new(color.black, 100))
        r += 1

    // Safely clear unused remaining rows (indices 0 to 4)
    if r <= 4
        for i = r to 4
            table.cell(infoTable, 0, i, "", text_color = color.new(color.white, 100), bgcolor = color.new(color.black, 100))
            table.cell(infoTable, 1, i, "", text_color = color.new(color.white, 100), bgcolor = color.new(color.black, 100))
            table.cell(infoTable, 2, i, "", text_color = color.new(color.white, 100), bgcolor = color.new(color.black, 100))
            table.cell(infoTable, 3, i, "", bgcolor = color.new(color.black, 100))
````
