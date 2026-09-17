<!-- tradingview-pine-id: PUB;040f7384d69648728a3b9ce24005fa56 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Aurora Flux — VWAP 

Source: https://www.tradingview.com/script/bxlJMSSy-Aurora-FLux-VWAP-V2-Drizzle-ALGO56/

## Description

Aurora Flux is an adaptive VWAP system that combines volume-weighted price analysis, dynamic volatility envelopes, ADX trend filtering, and lower-timeframe wick volume analysis.
The indicator builds a volume-weighted VWAP core and expands its bands using both volume intensity and ADX strength. It then analyzes lower-timeframe data to measure how much volume occurred in the wicks versus the body of each candle. When strong wick volume coincides with price entering the outer zones, multi-layer intensity clouds light up to visualize buying or selling pressure.
The result is a clear visual map of rejection strength around the VWAP structure.

█ How It Works
⚪ Adaptive VWAP Core

Calculates either a Session VWAP or a Rolling VWAP together with volume-weighted variance. Band width is then modulated by two forces at the same time: current volume ratio and normalized ADX strength.
⚪ Wick Volume Analysis

Uses lower-timeframe data to split every chart candle into body volume and wick volume. A smoothed wick-volume ratio is calculated and used as the main intensity driver.
⚪ Intensity Mapping

When price enters the Extreme Zones (or the Main Channel depending on the selected mode), the current wick ratio is converted into an intensity value.

• Upper intensity reflects Sell pressure

• Lower intensity reflects Buy pressure
The intensity directly controls the opacity of the multi-layer clouds.
⚪ Session Average Tracking

A running average of Upper and Lower intensity is maintained throughout the session and displayed in the Dashboard. This shows the dominant rejection bias of the day.

█ How to Use
⚪ Identify Rejection Zones

Strong Extreme Zone clouds highlight price areas where high wick volume rejected the move.

These zones can act as high-quality support or resistance.
⚪ Read Buy vs Sell Pressure

• Rising Upper Intensity = increasing Sell pressure

• Rising Lower Intensity = increasing Buy pressure
Compare the current intensity with the Session Average to judge whether the rejection is stronger or weaker than the day’s average.
⚪ Combine with ADX

When ADX is high, the bands automatically widen. This reduces false signals during strong trends and keeps the focus on mean-reversion environments.
⚪ Classic Stdev Bands

Optional multi-level standard deviation bands can be enabled for additional fixed statistical reference levels.

█ Settings
• VWAP Mode (Rolling / Session)

• Base Deviation Multiplier & Volume Expansion Factor

• ADX Length, Smoothing and Band Multiplier

• Cloud Mode (Extreme Zone / Main VWAP / Both)

• Extreme Zone Offset & Width

• Main Channel and Extreme Zone colors (single color → automatic gradient)

• Automatic or Manual Lower Timeframe

• Wick Volume Ratio Threshold

• Dashboard HUD

█ Development Status
This indicator is still experimental and under active development.
Default settings are a starting point. Optimal results usually require manual fine-tuning of the Volume Expansion Factor, ADX Influence, Wick Threshold and Zone Width depending on the instrument and timeframe.

█ Feedback
Found a bug, have a suggestion, or want a specific improvement?
Feel free to reach out via TradingView private messages or leave a comment under the script. Feedback is highly appreciated.

█ Disclaimer
The content provided in this script is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. Past performance is not indicative of future results. All trading involves risk, and you are solely responsible for your own trading decisions.

---

## Source Code

````pine
//@version=6
indicator("Aurora Flux — VWAP ", shorttitle="AuroraFlux_VWAP",
     overlay=true, max_bars_back=2000, max_labels_count=150,
     dynamic_requests=true, precision=4)

// ══════════════════════════════════════════════════════════════════════════════
// 1. INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── VWAP Engine ──────────────────────────────────────────────────────────────
anchorMode = input.string("Rolling", "VWAP Mode", options=["Rolling", "Session"],
     group="1. VWAP Engine", tooltip="Rolling = fixed-length VWMA. Session = cumulative from day start.")
vwapLen    = input.int(200, "Rolling Window Length", minval=5, group="1. VWAP Engine")

// ── Weighted Variance Envelope ───────────────────────────────────────────────
baseMult   = input.float(2.0, "Base Deviation Multiplier", minval=0.1, step=0.1, group="2. Weighted Variance Envelope")
volSens    = input.float(0.5, "Volume Expansion Factor", minval=0.0, step=0.1, group="2. Weighted Variance Envelope")
bandSmooth = input.int(6, "Band Smoothing (EMA)", minval=1, maxval=30, group="2. Weighted Variance Envelope")
showT2     = input.bool(false, "Show Tier 2 Bands", inline="t2", group="2. Weighted Variance Envelope")
mult2      = input.float(1.28, "×", inline="t2", group="2. Weighted Variance Envelope")
showT3     = input.bool(false, "Show Tier 3 Bands", inline="t3", group="2. Weighted Variance Envelope")
mult3      = input.float(3.09, "×", inline="t3", group="2. Weighted Variance Envelope")

// ── Classic Stdev Bands ──────────────────────────────────────────────────────
showClassic = input.bool(false, "Show Classic Stdev Bands", group="3. Classic VWAP Stdev Bands")
dev1 = input.float(1.28, "Level 1", minval=0.1, step=0.01, group="3. Classic VWAP Stdev Bands")
dev2 = input.float(2.01, "Level 2", minval=0.1, step=0.01, group="3. Classic VWAP Stdev Bands")
dev3 = input.float(2.51, "Level 3", minval=0.1, step=0.01, group="3. Classic VWAP Stdev Bands")
dev4 = input.float(3.09, "Level 4", minval=0.1, step=0.01, group="3. Classic VWAP Stdev Bands")
dev5 = input.float(4.01, "Level 5", minval=0.1, step=0.01, group="3. Classic VWAP Stdev Bands")
showC2 = input.bool(true,  "Show Level 2", group="3. Classic VWAP Stdev Bands")
showC3 = input.bool(true,  "Show Level 3", group="3. Classic VWAP Stdev Bands")
showC4 = input.bool(false, "Show Level 4", group="3. Classic VWAP Stdev Bands")
showC5 = input.bool(false, "Show Level 5", group="3. Classic VWAP Stdev Bands")

// ── ADX ──────────────────────────────────────────────────────────────────────
adxLength    = input.int(14, "ADX Length", minval=1, group="4. ADX Volatility")
adxSmooth    = input.int(14, "ADX Smoothing", minval=1, group="4. ADX Volatility")
adxInfluence = input.float(0.8, "ADX Band Multiplier", minval=0.0, maxval=3.0, step=0.1, group="4. ADX Volatility")
adxStrong    = input.int(25, "Strong Trend Threshold", minval=1, group="4. ADX Volatility")
filterByAdx  = input.bool(true, "Filter Intensity with ADX", group="4. ADX Volatility")

// ── Intensity Clouds ─────────────────────────────────────────────────────────
showClouds   = input.bool(true, "Show Intensity Clouds", group="5. Intensity Clouds")
cloudMode    = input.string("Both", "Cloud Mode", options=["Extreme Zone", "Main VWAP", "Both"], group="5. Intensity Clouds")
zoneOffset   = input.float(0.25, "Extreme Zone Offset", minval=0.0, maxval=2.0, step=0.05, group="5. Intensity Clouds")
zoneWidth    = input.float(1.6, "Extreme Zone Width", minval=0.5, maxval=4.0, step=0.1, group="5. Intensity Clouds")

// ── Cloud Colors ─────────────────────────────────────────────────────────────
colMainUp = input.color(#00BCD4, "Main Channel Upper", group="6. Cloud Colors")
colMainDn = input.color(#AB47BC, "Main Channel Lower", group="6. Cloud Colors")
colExtUp  = input.color(#FF5252, "Extreme Zone Upper (Sell)", group="6. Cloud Colors")
colExtDn  = input.color(#69F0AE, "Extreme Zone Lower (Buy)", group="6. Cloud Colors")

// ── Lower TF & Wick Volume ───────────────────────────────────────────────────
autoLtf      = input.bool(true, "Automatic Lower Timeframe", group="7. Lower Timeframe Data")
manualLtf    = input.timeframe("1", "Manual Lower Timeframe", group="7. Lower Timeframe Data")
wickThresh   = input.float(0.80, "Wick Volume Ratio Threshold", minval=0.5, maxval=0.99, step=0.01, group="7. Lower Timeframe Data")
smoothLen    = input.int(5, "Wick Ratio Smoothing", minval=1, group="7. Lower Timeframe Data")

// ── Visuals, Confluence & Clean Mode ─────────────────────────────────────────
showDash        = input.bool(true, "Show Dashboard HUD", group="8. Visual Settings")
showMid         = input.bool(true, "Show VWAP Line", group="8. Visual Settings")
showBands       = input.bool(true, "Show Weighted Bands", group="8. Visual Settings")
cleanMode       = input.bool(false, "★ Clean Mode (Clouds Only)", group="8. Visual Settings",
     tooltip="Hides all lines, bands and dashboard — only intensity clouds remain.")
showConfluence  = input.bool(true, "Show Confluence Score on HUD", group="8. Visual Settings")

colUpper = input.color(#00E5FF, "Upper Band", group="9. Colors")
colLower = input.color(#E040FB, "Lower Band", group="9. Colors")
colMid   = input.color(#FF00E5, "VWAP", group="9. Colors")

// ══════════════════════════════════════════════════════════════════════════════
// 2. HELPERS
// ══════════════════════════════════════════════════════════════════════════════

autoTf() =>
    s = timeframe.in_seconds(timeframe.period)
    if na(s)
        "1"
    else if s <= 60
        "1"
    else if s <= 900
        "1"
    else if s <= 3600
        "5"
    else if s <= 14400
        "15"
    else if s <= 86400
        "60"
    else
        "240"

f_wickBody(float bodyHi, float bodyLo, array<float> arrH, array<float> arrL, array<float> arrV) =>
    n = array.size(arrH)
    float bodyVol = 0.0
    float wickVol = 0.0
    if n > 0
        for i = 0 to n - 1
            ih = array.get(arrH, i)
            il = array.get(arrL, i)
            iv = array.get(arrV, i)
            ohi = math.min(ih, bodyHi)
            olo = math.max(il, bodyLo)
            orng = math.max(ohi - olo, 0.0)
            trng = math.max(ih - il, syminfo.mintick)
            bf   = orng / trng
            bodyVol += iv * bf
            wickVol += iv * (1.0 - bf)
    else
        trng = math.max(high - low, syminfo.mintick)
        bf   = (bodyHi - bodyLo) / trng
        bodyVol := nz(volume, 0.0) * bf
        wickVol := nz(volume, 0.0) * (1.0 - bf)
    [bodyVol, wickVol]

f_grad(color base, float intensity, int layer) =>
    float t = 88 - intensity * 28 - layer * 7
    color.new(base, math.max(35, math.min(92, t)))

// ══════════════════════════════════════════════════════════════════════════════
// 3. ADX
// ══════════════════════════════════════════════════════════════════════════════

[diPlus, diMinus, adx] = ta.dmi(adxLength, adxSmooth)
adxNormalized = nz(adx, 0) / 100.0
adxMultiplier = 1.0 + (adxNormalized * adxInfluence)
trendStrong   = adx >= adxStrong
bullishTrend  = diPlus > diMinus

// ══════════════════════════════════════════════════════════════════════════════
// 4. VWAP + WEIGHTED VARIANCE
// ══════════════════════════════════════════════════════════════════════════════

var float vwapSum = 0.0
var float volSum  = 0.0
var float v2Sum   = 0.0

newSession = timeframe.change("D")

float myvwap   = na
float variance = na

if anchorMode == "Session"
    if newSession
        vwapSum := hl2 * volume
        volSum  := volume
        v2Sum   := volume * hl2 * hl2
    else
        vwapSum += hl2 * volume
        volSum  += volume
        v2Sum   += volume * hl2 * hl2
    myvwap   := volSum > 0 ? vwapSum / volSum : hl2
    variance := volSum > 0 ? v2Sum / volSum - myvwap * myvwap : 0.0
else
    myvwap   := ta.vwma(hl2, vwapLen)
    variance := ta.vwma(hl2 * hl2, vwapLen) - myvwap * myvwap

dev = math.sqrt(math.max(nz(variance, 0.0), 0.0))

volMa    = ta.sma(volume, 20)
volRatio = volMa > 0 ? volume / volMa : 1.0
dynMult  = baseMult * (1.0 + math.max(0.0, volRatio - 1.0) * volSens) * adxMultiplier

rawUpper1 = myvwap + dynMult * dev
rawLower1 = myvwap - dynMult * dev
rawUpper2 = myvwap + mult2 * dev * adxMultiplier
rawLower2 = myvwap - mult2 * dev * adxMultiplier
rawUpper3 = myvwap + mult3 * dev * adxMultiplier
rawLower3 = myvwap - mult3 * dev * adxMultiplier

upper1 = ta.ema(rawUpper1, bandSmooth)
lower1 = ta.ema(rawLower1, bandSmooth)
upper2 = ta.ema(rawUpper2, bandSmooth)
lower2 = ta.ema(rawLower2, bandSmooth)
upper3 = ta.ema(rawUpper3, bandSmooth)
lower3 = ta.ema(rawLower3, bandSmooth)

cU1 = myvwap + dev1 * dev
cD1 = myvwap - dev1 * dev
cU2 = myvwap + dev2 * dev
cD2 = myvwap - dev2 * dev
cU3 = myvwap + dev3 * dev
cD3 = myvwap - dev3 * dev
cU4 = myvwap + dev4 * dev
cD4 = myvwap - dev4 * dev
cU5 = myvwap + dev5 * dev
cD5 = myvwap - dev5 * dev

// ══════════════════════════════════════════════════════════════════════════════
// 5. WICK / BODY VOLUME (your original engine)
// ══════════════════════════════════════════════════════════════════════════════

tf = autoLtf ? autoTf() : manualLtf
[lO, lH, lL, lC, lV] = request.security_lower_tf(syminfo.tickerid, tf,
     [open, high, low, close, nz(volume, 0.0)], ignore_invalid_timeframe=true)

bodyHi = math.max(open, close)
bodyLo = math.min(open, close)
[bVol, wVol] = f_wickBody(bodyHi, bodyLo, lH, lL, lV)
totalVol     = bVol + wVol
wickRatioRaw = totalVol > 0 ? wVol / totalVol : 0.0
wickRatio    = ta.sma(wickRatioRaw, smoothLen)

// ══════════════════════════════════════════════════════════════════════════════
// 6. INTENSITY + CONFLUENCE
// ══════════════════════════════════════════════════════════════════════════════

rawIntensity = math.min(1.0, math.max(0.0, (wickRatio - 0.55) / 0.45))

intensityGate = filterByAdx ? (adx >= adxStrong * 0.7 ? 1.0 : 0.45) : 1.0

inUpperExtreme = high > upper1 + zoneOffset * dev
inLowerExtreme = low  < lower1 - zoneOffset * dev
inMainChannel  = close <= upper1 and close >= lower1

upperIntensity = inUpperExtreme ? rawIntensity * intensityGate : 0.0
lowerIntensity = inLowerExtreme ? rawIntensity * intensityGate : 0.0
mainIntensity  = inMainChannel  ? rawIntensity * 0.70 * intensityGate : 0.0

// Session averages
var float sumUpperInt = 0.0
var float sumLowerInt = 0.0
var int   barCount    = 0

if newSession
    sumUpperInt := 0.0
    sumLowerInt := 0.0
    barCount    := 0

sumUpperInt += upperIntensity
sumLowerInt += lowerIntensity
barCount    += 1

avgUpperInt = barCount > 0 ? sumUpperInt / barCount : 0.0
avgLowerInt = barCount > 0 ? sumLowerInt / barCount : 0.0

// Confluence Score (0–100)
distFromVwap = math.abs(close - myvwap) / math.max(dev, syminfo.mintick)
distScore    = math.min(1.0, distFromVwap / 3.0)
adxScore     = math.min(1.0, adx / 50.0)
wickScore    = rawIntensity

confluence   = math.round((wickScore * 0.40 + adxScore * 0.30 + distScore * 0.30) * 100.0)

// ══════════════════════════════════════════════════════════════════════════════
// 7. PLOTS & FILLS
// ══════════════════════════════════════════════════════════════════════════════

bool drawLines = not cleanMode

pMid = plot(showMid and drawLines ? myvwap : na, "VWAP", color=color.new(colMid, 15), linewidth=2)
pU1  = plot(showBands and drawLines ? upper1 : na, "Upper Band", color=color.new(colUpper, 10), linewidth=1)
pL1  = plot(showBands and drawLines ? lower1 : na, "Lower Band", color=color.new(colLower, 10), linewidth=1)

plot(showT2 and showBands and drawLines ? upper2 : na, "Upper Band 2", color=color.new(colUpper, 55), linewidth=1)
plot(showT2 and showBands and drawLines ? lower2 : na, "Lower Band 2", color=color.new(colLower, 55), linewidth=1)
plot(showT3 and showBands and drawLines ? upper3 : na, "Upper Band 3", color=color.new(colUpper, 75), linewidth=1)
plot(showT3 and showBands and drawLines ? lower3 : na, "Lower Band 3", color=color.new(colLower, 75), linewidth=1)

plot(showClassic and drawLines ? cU1 : na, "Classic Upper 1", color=color.new(#FFFFFF, 55), linewidth=1, style=plot.style_linebr)
plot(showClassic and drawLines ? cD1 : na, "Classic Lower 1", color=color.new(#FFFFFF, 55), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC2 and drawLines ? cU2 : na, "Classic Upper 2", color=color.new(#FFFFFF, 65), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC2 and drawLines ? cD2 : na, "Classic Lower 2", color=color.new(#FFFFFF, 65), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC3 and drawLines ? cU3 : na, "Classic Upper 3", color=color.new(#FFFFFF, 75), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC3 and drawLines ? cD3 : na, "Classic Lower 3", color=color.new(#FFFFFF, 75), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC4 and drawLines ? cU4 : na, "Classic Upper 4", color=color.new(#FFFFFF, 82), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC4 and drawLines ? cD4 : na, "Classic Lower 4", color=color.new(#FFFFFF, 82), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC5 and drawLines ? cU5 : na, "Classic Upper 5", color=color.new(#FFFFFF, 88), linewidth=1, style=plot.style_linebr)
plot(showClassic and showC5 and drawLines ? cD5 : na, "Classic Lower 5", color=color.new(#FFFFFF, 88), linewidth=1, style=plot.style_linebr)

// ── Main Channel clouds ──────────────────────────────────────────────────────
useMain = cloudMode == "Main VWAP" or cloudMode == "Both"

cloudA_Upper = myvwap + (upper1 - myvwap) * 0.25
cloudB_Upper = myvwap + (upper1 - myvwap) * 0.50
cloudC_Upper = myvwap + (upper1 - myvwap) * 0.75
cloudA_Lower = myvwap + (lower1 - myvwap) * 0.25
cloudB_Lower = myvwap + (lower1 - myvwap) * 0.50
cloudC_Lower = myvwap + (lower1 - myvwap) * 0.75

pUA = plot(showClouds and useMain ? cloudA_Upper : na, display=display.none)
pUB = plot(showClouds and useMain ? cloudB_Upper : na, display=display.none)
pUC = plot(showClouds and useMain ? cloudC_Upper : na, display=display.none)
pLA = plot(showClouds and useMain ? cloudA_Lower : na, display=display.none)
pLB = plot(showClouds and useMain ? cloudB_Lower : na, display=display.none)
pLC = plot(showClouds and useMain ? cloudC_Lower : na, display=display.none)

fill(pMid, pUA, color=showClouds and useMain ? f_grad(colMainUp, mainIntensity, 0) : na)
fill(pUA,  pUB, color=showClouds and useMain ? f_grad(colMainUp, mainIntensity, 1) : na)
fill(pUB,  pUC, color=showClouds and useMain ? f_grad(colMainUp, mainIntensity, 2) : na)
fill(pUC,  pU1, color=showClouds and useMain ? f_grad(colMainUp, mainIntensity, 3) : na)

fill(pMid, pLA, color=showClouds and useMain ? f_grad(colMainDn, mainIntensity, 0) : na)
fill(pLA,  pLB, color=showClouds and useMain ? f_grad(colMainDn, mainIntensity, 1) : na)
fill(pLB,  pLC, color=showClouds and useMain ? f_grad(colMainDn, mainIntensity, 2) : na)
fill(pLC,  pL1, color=showClouds and useMain ? f_grad(colMainDn, mainIntensity, 3) : na)

// ── Extreme Zone clouds ──────────────────────────────────────────────────────
useExtreme = cloudMode == "Extreme Zone" or cloudMode == "Both"

topBot = upper1 + zoneOffset * dev
topTop = topBot + zoneWidth * dev
botTop = lower1 - zoneOffset * dev
botBot = botTop - zoneWidth * dev

envA_Up = topBot + (topTop - topBot) * 0.25
envB_Up = topBot + (topTop - topBot) * 0.50
envC_Up = topBot + (topTop - topBot) * 0.75
envA_Dn = botTop - (botTop - botBot) * 0.25
envB_Dn = botTop - (botTop - botBot) * 0.50
envC_Dn = botTop - (botTop - botBot) * 0.75

pEUA  = plot(showClouds and useExtreme ? envA_Up  : na, display=display.none)
pEUB  = plot(showClouds and useExtreme ? envB_Up  : na, display=display.none)
pEUC  = plot(showClouds and useExtreme ? envC_Up  : na, display=display.none)
pELA  = plot(showClouds and useExtreme ? envA_Dn  : na, display=display.none)
pELB  = plot(showClouds and useExtreme ? envB_Dn  : na, display=display.none)
pELC  = plot(showClouds and useExtreme ? envC_Dn  : na, display=display.none)
pETop = plot(showClouds and useExtreme ? topTop   : na, display=display.none)
pEBot = plot(showClouds and useExtreme ? botBot   : na, display=display.none)

fill(pU1,  pEUA,  color=showClouds and useExtreme ? f_grad(colExtUp, upperIntensity, 0) : na)
fill(pEUA, pEUB,  color=showClouds and useExtreme ? f_grad(colExtUp, upperIntensity, 1) : na)
fill(pEUB, pEUC,  color=showClouds and useExtreme ? f_grad(colExtUp, upperIntensity, 2) : na)
fill(pEUC, pETop, color=showClouds and useExtreme ? f_grad(colExtUp, upperIntensity, 3) : na)

fill(pL1,  pELA,  color=showClouds and useExtreme ? f_grad(colExtDn, lowerIntensity, 0) : na)
fill(pELA, pELB,  color=showClouds and useExtreme ? f_grad(colExtDn, lowerIntensity, 1) : na)
fill(pELB, pELC,  color=showClouds and useExtreme ? f_grad(colExtDn, lowerIntensity, 2) : na)
fill(pELC, pEBot, color=showClouds and useExtreme ? f_grad(colExtDn, lowerIntensity, 3) : na)

// ══════════════════════════════════════════════════════════════════════════════
// 8. DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════

var table hud = table.new(position.top_right, 2, 10,
     bgcolor=color.new(#0D0B14, 10),
     border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast and showDash and not cleanMode
    table.cell(hud, 0, 0, "VWAP Mode",          text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 0, anchorMode,           text_color=colMid,      text_size=size.small)

    table.cell(hud, 0, 1, "Wick Volume %",      text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 1, str.tostring(wickRatio * 100, "#.#") + "%",
         text_color=wickRatio >= wickThresh ? #FF465E : color.gray, text_size=size.small)

    table.cell(hud, 0, 2, "Upper Intensity",    text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(upperIntensity * 100, "#") + "%",
         text_color=upperIntensity > 0.4 ? colExtUp : color.gray, text_size=size.small)

    table.cell(hud, 0, 3, "Lower Intensity",    text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(lowerIntensity * 100, "#") + "%",
         text_color=lowerIntensity > 0.4 ? colExtDn : color.gray, text_size=size.small)

    table.cell(hud, 0, 4, "Avg Upper (Sess)",   text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(avgUpperInt * 100, "#.#") + "%",
         text_color=avgUpperInt > 0.25 ? colExtUp : color.gray, text_size=size.small)

    table.cell(hud, 0, 5, "Avg Lower (Sess)",   text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(avgLowerInt * 100, "#.#") + "%",
         text_color=avgLowerInt > 0.25 ? colExtDn : color.gray, text_size=size.small)

    table.cell(hud, 0, 6, "ADX",                text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(adx, "#.#") + (trendStrong ? " Strong" : ""),
         text_color=trendStrong ? color.orange : color.gray, text_size=size.small)

    table.cell(hud, 0, 7, "Trend Bias",         text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 7, bullishTrend ? "Bullish" : "Bearish",
         text_color=bullishTrend ? #00DCA5 : #FF465E, text_size=size.small)

    table.cell(hud, 0, 8, "Vol Ratio",          text_color=color.white, text_size=size.small)
    table.cell(hud, 1, 8, str.tostring(volRatio, "#.##") + "×",
         text_color=volRatio > 1.5 ? color.orange : color.gray, text_size=size.small)

    table.cell(hud, 0, 9, "Confluence",         text_color=color.white, text_size=size.small)
    confColor = confluence >= 70 ? #00E676 : confluence >= 45 ? #FFD600 : color.gray
    table.cell(hud, 1, 9, str.tostring(confluence) + " / 100", text_color=confColor, text_size=size.small)
else if barstate.islast and cleanMode
    table.clear(hud, 0, 0, 1, 9)

// ══════════════════════════════════════════════════════════════════════════════
// 9. ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(upperIntensity > 0.6 and wickRatio >= wickThresh,
     title="High Sell Intensity",
     message="AuroraFlux: Strong upper-zone rejection + high wick volume")

alertcondition(lowerIntensity > 0.6 and wickRatio >= wickThresh,
     title="High Buy Intensity",
     message="AuroraFlux: Strong lower-zone rejection + high wick volume")

alertcondition(confluence >= 75,
     title="High Confluence",
     message="AuroraFlux: Confluence ≥ 75")
````
