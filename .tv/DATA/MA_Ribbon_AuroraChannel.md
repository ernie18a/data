<!-- tradingview-pine-id: PUB;be7318272d7c49b99f877627eaaf216f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MA Ribbon → Aurora_Channel

Source: https://www.tradingview.com/script/WocMV3dj-MA-Ribbon-Aurora-Channel-V1-DRIZZLE-ALGO56/

## Description

MA Ribbon with Aurora Channels UI [Experimental]
█ Overview
MA Ribbon with Aurora Channels UI is an experimental indicator designed to modernize the classic Moving Average Ribbon. Instead of relying on static trailing averages—which frequently lag during sharp structural shifts—the system fuses custom MA ribbons with Flipped (Inverse) Ribbon Dynamics, Volume Expansion Multipliers, and Asymmetrical Wick Ratios, wrapped inside a real-time HUD interface.

The indicator converts standard ribbon dispersion into a multi-layered, volatility-adaptive envelope (Core Channel, Expansion Envelope, and Trigger Buffer). The channel automatically expands during high-volume momentum breakouts and contracts during low-volatility consolidation phases.

⚠️ Author Note: This project is an experimental research prototype. Optimal performance requires manual tuning of parameter settings (smoothing lengths, volume sensitivity, and width multipliers) based on your target asset, timeframe, and prevailing market regime.

█ How It Works

⚪ Dynamic Midline Engine
The system averages all active moving averages (supporting SMA, EMA, SMMA, WMA, VWMA) to create a central equilibrium reference line.

⚪ Flipped Ribbon & Width Engine
Rather than relying purely on standard moving average distance, the indicator calculates inverse mirror projections for every active ribbon line to measure true structural price dispersion:

[pine]flip = 2 * source - ma[/pine]

The maximum deviation across normal and flipped lines defines the raw channel width, which is then smoothed using an exponential moving average:

[pine]rawWidth = math.max(math.abs(diff1), math.abs(diff2), math.abs(diff3), math.abs(diff4))[/pine]

⚪ Volume-Driven Expansion
Channel width dynamically scales upward when volume participation exceeds its baseline moving average, ensuring bands react instantly to institutional volume spikes:

[pine]volRatio = volume / volMa
volBoost = 1.0 + math.max(0.0, volRatio - 1.0) * volSens[/pine]

⚪ Asymmetrical Wick Balancing
Upper and lower envelope boundaries expand independently based on the ratio of directional wicks relative to ATR. This prevents false boundary breaches caused by one-sided wick rejections:

[pine]upAsym = 1.0 + asymStr * (ur / math.max(atrVal, syminfo.mintick))
dnAsym = 1.0 + asymStr * (lr / math.max(atrVal, syminfo.mintick))[/pine]

⚪ Aurora Multi-Layer Bounds
The engine calculates three distinct volatility zones:

Core Channel: The primary equilibrium zone surrounding the midline.

Expansion Envelope: Outermost normal volatility bounds where directional acceleration occurs.

Trigger Buffer: An extreme extension boundary for mean-reversion cues.

⚪ Signal Engine & HUD Dashboard
The script tracks zone transitions, logging whether a boundary breach represents a 1st Touch or a Retest. The real-time HUD table tracks current zone regime, duration, ribbon compression percentage, active volume boost, and touch history directly on the chart.

█ How to Use

⚪ Volatility Contraction & Compression
When the Ribbon Tightness value on the HUD falls below 30%, the MA ribbon is in deep compression. Price residing strictly inside the Core Channel signals neutral range consolidation prior to a breakout.

⚪ Trend Expansion & Momentum Setup
A candle close outside the Expansion Envelope indicates institutional volume acceleration. Look for 1st Touch (triangle) or Retest (circle) shapes for momentum entries aligned with expanding channel width.

⚪ Mean-Reversion / Profit-Taking Setup
When price reaches or breaches the outer Trigger Buffer, market expansion is overextended. Look for mean-reversion rejections back toward the Core Channel or Midline.

█ Settings

MA Ribbon Inputs
MA #1 – #4: Enable or disable up to four independent moving averages. Select the MA type (SMA, EMA, SMMA, WMA, VWMA), source, length, and plot color.

Display
Show Normal / Flipped Ribbon: Toggle visibility of standard ribbon lines or mirror projections.

Show Core / Envelope / Trigger: Toggle individual channel layer visibility.

Show Dashboard & Position: Enable the real-time HUD and select its chart overlay anchor.

Show Signal Shapes: Enable breakout and retest signal markers.

Channel Engine
Core Multiplier: Sets the width multiplier for the inner fair-value channel.

Envelope Multiplier: Controls the distance of the momentum envelope bounds.

Trigger Buffer Multiplier: Controls the outer overextension boundary.

Width & Edge Smoothing: Sets the EMA smoothing applied to raw dispersion and final channel edges.

Volume MA Length & Sensitivity: Adjusts how strongly volume spikes expand channel boundaries.

Asymmetry Strength: Controls how aggressively upper/lower bounds deform in response to long wicks.

Colors
Core Upper / Lower: Custom colors for the inner channel clouds.

Envelope / Trigger / Midline: Color selection for boundary lines and fill layers.

Cloud Transparency: Adjusts the opacity gradient of background fills.

Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.  

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

---

## Source Code

````pine
//@version=6
indicator("MA Ribbon → Aurora_Channel", shorttitle = "MA_Aurora", overlay = true, max_bars_back = 500)

// ══════════════════════════════════════════════════════════════════════════════
// MA FUNCTION
// ══════════════════════════════════════════════════════════════════════════════
ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS – MA RIBBON
// ══════════════════════════════════════════════════════════════════════════════
show_ma1   = input.bool(true,  "MA #1", inline = "MA1")
ma1_type   = input.string("EMA", "", inline = "MA1", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input.source(close, "", inline = "MA1")
ma1_length = input.int(9, "", inline = "MA1", minval = 1)
ma1_color  = input.color(#f6c309, "", inline = "MA1")

show_ma2   = input.bool(true,  "MA #2", inline = "MA2")
ma2_type   = input.string("EMA", "", inline = "MA2", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input.source(close, "", inline = "MA2")
ma2_length = input.int(15, "", inline = "MA2", minval = 1)
ma2_color  = input.color(#fb9800, "", inline = "MA2")

show_ma3   = input.bool(true,  "MA #3", inline = "MA3")
ma3_type   = input.string("EMA", "", inline = "MA3", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input.source(close, "", inline = "MA3")
ma3_length = input.int(21, "", inline = "MA3", minval = 1)
ma3_color  = input.color(#fb6500, "", inline = "MA3")

show_ma4   = input.bool(true,  "MA #4", inline = "MA4")
ma4_type   = input.string("EMA", "", inline = "MA4", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input.source(close, "", inline = "MA4")
ma4_length = input.int(50, "", inline = "MA4", minval = 1)
ma4_color  = input.color(#f60c0c, "", inline = "MA4")

// ── Display ───────────────────────────────────────────────────────────────────
show_normal  = input.bool(true,  "Show Normal Ribbon", group = "Display")
show_flipped = input.bool(false, "Show Flipped Ribbon", group = "Display")
show_core    = input.bool(true,  "Show Core Channel", group = "Display")
show_envelope= input.bool(true,  "Show Expansion Envelope", group = "Display")
show_trigger = input.bool(false, "Show Trigger Buffer", group = "Display")
showDash     = input.bool(true,  "Show Dashboard", group = "Display")
dashPos      = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = "Display")
showSignals  = input.bool(true,  "Show Signal Shapes", group = "Display")

// ── Channel Engine ────────────────────────────────────────────────────────────
baseMult     = input.float(1.00, "Core Multiplier", minval = 0.1, step = 0.05, group = "Channel Engine")
envMult      = input.float(0.55, "Envelope Multiplier", minval = 0.1, step = 0.05, group = "Channel Engine")
trigMult     = input.float(0.22, "Trigger Buffer Multiplier", minval = 0.0, step = 0.05, group = "Channel Engine")
widthSmooth  = input.int(12, "Width Smoothing", minval = 1, group = "Channel Engine")
edgeSmooth   = input.int(5,  "Final Edge Smoothing", minval = 1, group = "Channel Engine")
volLen       = input.int(20, "Volume MA Length", minval = 1, group = "Channel Engine")
volSens      = input.float(0.40, "Volume Expansion Sensitivity", minval = 0.0, step = 0.05, group = "Channel Engine")
asymStr      = input.float(0.15, "Asymmetry Strength", minval = 0.0, maxval = 0.5, step = 0.02, group = "Channel Engine")

// ── Colors ────────────────────────────────────────────────────────────────────
colCoreUpper = input.color(#E040FB, "Core Upper", group = "Colors")
colCoreLower = input.color(#00E5FF, "Core Lower", group = "Colors")
colEnv       = input.color(#FF9800, "Envelope", group = "Colors")
colTrig      = input.color(#00B0FF, "Trigger", group = "Colors")
colMid       = input.color(#FF00E5, "Midline", group = "Colors")
cloudTransp  = input.int(80, "Cloud Transparency", minval = 50, maxval = 95, group = "Colors")

// ══════════════════════════════════════════════════════════════════════════════
// CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════
ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

flip1 = show_ma1 ? 2 * ma1_source - ma1 : na
flip2 = show_ma2 ? 2 * ma2_source - ma2 : na
flip3 = show_ma3 ? 2 * ma3_source - ma3 : na
flip4 = show_ma4 ? 2 * ma4_source - ma4 : na

diff1 = show_ma1 ? flip1 - ma1 : na
diff2 = show_ma2 ? flip2 - ma2 : na
diff3 = show_ma3 ? flip3 - ma3 : na
diff4 = show_ma4 ? flip4 - ma4 : na

// Smooth Midline
float midSum = 0.0
int   midCnt = 0
if show_ma1
    midSum += ma1
    midCnt += 1
if show_ma2
    midSum += ma2
    midCnt += 1
if show_ma3
    midSum += ma3
    midCnt += 1
if show_ma4
    midSum += ma4
    midCnt += 1
midLine = midCnt > 0 ? midSum / midCnt : close

// Width Engine
rawWidth    = math.max(math.abs(nz(diff1)), math.abs(nz(diff2)), math.abs(nz(diff3)), math.abs(nz(diff4)))
smoothWidth = ta.ema(rawWidth, widthSmooth)

volMa    = ta.sma(volume, volLen)
volRatio = volMa > 0 ? volume / volMa : 1.0
volBoost = 1.0 + math.max(0.0, volRatio - 1.0) * volSens

uw = math.max(0.0, high - math.max(open, close))
dw = math.max(0.0, math.min(open, close) - low)
ur = ta.rma(uw, 14)
lr = ta.rma(dw, 14)
atrVal = ta.atr(14)

upAsym = 1.0 + asymStr * (ur / math.max(atrVal, syminfo.mintick))
dnAsym = 1.0 + asymStr * (lr / math.max(atrVal, syminfo.mintick))

// Core
coreHalf     = (smoothWidth * 0.5 * baseMult) * volBoost
rawCoreUpper = midLine + coreHalf * upAsym
rawCoreLower = midLine - coreHalf * dnAsym
coreUpper    = ta.ema(rawCoreUpper, edgeSmooth)
coreLower    = ta.ema(rawCoreLower, edgeSmooth)

// Envelope
envOffset    = (smoothWidth * 0.5 * envMult) * volBoost
rawEnvUpper  = coreUpper + envOffset * upAsym
rawEnvLower  = coreLower - envOffset * dnAsym
envUpper     = ta.ema(rawEnvUpper, edgeSmooth)
envLower     = ta.ema(rawEnvLower, edgeSmooth)

// Trigger
trigOffset = (smoothWidth * trigMult) * volBoost
trigUpper  = envUpper + trigOffset
trigLower  = envLower - trigOffset

// ══════════════════════════════════════════════════════════════════════════════
// ZONE & DURATION LOGIC
// ══════════════════════════════════════════════════════════════════════════════
bool inCore      = close <= coreUpper and close >= coreLower
bool inUpperEnv  = close > coreUpper and close <= envUpper
bool inLowerEnv  = close < coreLower and close >= envLower
bool outsideUp   = close > envUpper
bool outsideDn   = close < envLower

string currentZone = outsideUp ? "OUTSIDE UP" :
                     outsideDn ? "OUTSIDE DN" :
                     inUpperEnv ? "UPPER ENVELOPE" :
                     inLowerEnv ? "LOWER ENVELOPE" : "CORE"

// Bars in current zone
var int barsInZone = 0
var string prevZone = ""
if currentZone == prevZone
    barsInZone += 1
else
    barsInZone := 1
prevZone := currentZone

// Ribbon tightness (0–100%, lower = tighter)
ribbonRange = math.max(nz(ma1), nz(ma2), nz(ma3), nz(ma4)) - math.min(nz(ma1), nz(ma2), nz(ma3), nz(ma4))
tightness   = smoothWidth > 0 ? math.min(100, (ribbonRange / smoothWidth) * 100) : 0

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL LOGIC (First touch / Re-test / Break)
// ══════════════════════════════════════════════════════════════════════════════
var int touchCountUp = 0
var int touchCountDn = 0
var int barsSinceTouchUp = 999
var int barsSinceTouchDn = 999

bool firstTouchUp = ta.crossover(close, envUpper)
bool firstTouchDn = ta.crossunder(close, envLower)
bool retestUp     = close > envUpper and close[1] <= envUpper and touchCountUp >= 1
bool retestDn     = close < envLower and close[1] >= envLower and touchCountDn >= 1

if firstTouchUp or retestUp
    touchCountUp += 1
    barsSinceTouchUp := 0
else
    barsSinceTouchUp += 1

if firstTouchDn or retestDn
    touchCountDn += 1
    barsSinceTouchDn := 0
else
    barsSinceTouchDn += 1

// Reset touch counters after longer time
if barsSinceTouchUp > 30
    touchCountUp := 0
if barsSinceTouchDn > 30
    touchCountDn := 0

bool signalUp = showSignals and (firstTouchUp or retestUp)
bool signalDn = showSignals and (firstTouchDn or retestDn)

// ══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════════
plot(show_normal and show_ma1 ? ma1 : na, "MA #1", ma1_color)
plot(show_normal and show_ma2 ? ma2 : na, "MA #2", ma2_color)
plot(show_normal and show_ma3 ? ma3 : na, "MA #3", ma3_color)
plot(show_normal and show_ma4 ? ma4 : na, "MA #4", ma4_color)

plot(show_flipped and show_ma1 ? flip1 : na, "Flip #1", color.new(ma1_color, 45))
plot(show_flipped and show_ma2 ? flip2 : na, "Flip #2", color.new(ma2_color, 45))
plot(show_flipped and show_ma3 ? flip3 : na, "Flip #3", color.new(ma3_color, 45))
plot(show_flipped and show_ma4 ? flip4 : na, "Flip #4", color.new(ma4_color, 45))

pMid   = plot(midLine, "Midline", color = color.new(colMid, 60), linewidth = 1)
pCoreU = plot(show_core ? coreUpper : na, "Core Upper", color = color.new(colCoreUpper, 10), linewidth = 1)
pCoreL = plot(show_core ? coreLower : na, "Core Lower", color = color.new(colCoreLower, 10), linewidth = 1)
pEnvU  = plot(show_envelope ? envUpper : na, "Envelope Upper", color = color.new(colEnv, 35), linewidth = 1)
pEnvL  = plot(show_envelope ? envLower : na, "Envelope Lower", color = color.new(colEnv, 35), linewidth = 1)
pTrigU = plot(show_trigger ? trigUpper : na, "Trigger Upper", color = color.new(colTrig, 55), linewidth = 1)
pTrigL = plot(show_trigger ? trigLower : na, "Trigger Lower", color = color.new(colTrig, 55), linewidth = 1)

// Clouds
cA_U = midLine + (coreUpper - midLine) * 0.35
cB_U = midLine + (coreUpper - midLine) * 0.70
cA_L = midLine + (coreLower - midLine) * 0.35
cB_L = midLine + (coreLower - midLine) * 0.70

pCAU = plot(show_core ? cA_U : na, display = display.none)
pCBU = plot(show_core ? cB_U : na, display = display.none)
pCAL = plot(show_core ? cA_L : na, display = display.none)
pCBL = plot(show_core ? cB_L : na, display = display.none)

fill(pMid, pCAU,  color = show_core ? color.new(colCoreUpper, cloudTransp + 8) : na)
fill(pCAU, pCBU,  color = show_core ? color.new(colCoreUpper, cloudTransp) : na)
fill(pCBU, pCoreU, color = show_core ? color.new(colCoreUpper, cloudTransp - 8) : na)
fill(pMid, pCAL,  color = show_core ? color.new(colCoreLower, cloudTransp + 8) : na)
fill(pCAL, pCBL,  color = show_core ? color.new(colCoreLower, cloudTransp) : na)
fill(pCBL, pCoreL, color = show_core ? color.new(colCoreLower, cloudTransp - 8) : na)

eA_U = coreUpper + (envUpper - coreUpper) * 0.5
eA_L = coreLower + (envLower - coreLower) * 0.5
pEAU = plot(show_envelope ? eA_U : na, display = display.none)
pEAL = plot(show_envelope ? eA_L : na, display = display.none)

fill(pCoreU, pEAU, color = show_envelope ? color.new(colEnv, cloudTransp + 4) : na)
fill(pEAU, pEnvU,  color = show_envelope ? color.new(colEnv, cloudTransp - 6) : na)
fill(pCoreL, pEAL, color = show_envelope ? color.new(colEnv, cloudTransp + 4) : na)
fill(pEAL, pEnvL,  color = show_envelope ? color.new(colEnv, cloudTransp - 6) : na)

fill(pEnvU, pTrigU, color = show_trigger ? color.new(colTrig, 88) : na)
fill(pEnvL, pTrigL, color = show_trigger ? color.new(colTrig, 88) : na)

// Signals
plotshape(signalUp and touchCountUp == 1, title = "1st Touch Up", style = shape.triangleup, location = location.belowbar, size = size.small, color = color.lime)
plotshape(signalUp and touchCountUp > 1,  title = "Retest Up",    style = shape.circle,     location = location.belowbar, size = size.small, color = color.lime)

plotshape(signalDn and touchCountDn == 1, title = "1st Touch Dn", style = shape.triangledown, location = location.abovebar, size = size.small, color = color.red)
plotshape(signalDn and touchCountDn > 1,  title = "Retest Dn",    style = shape.circle,       location = location.abovebar, size = size.small, color = color.red)

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════
tablePos = switch dashPos
    "Top Right"      => position.top_right
    "Top Center"     => position.top_center
    "Top Left"       => position.top_left
    "Middle Right"   => position.middle_right
    "Middle Center"  => position.middle_center
    "Middle Left"    => position.middle_left
    "Bottom Right"   => position.bottom_right
    "Bottom Center"  => position.bottom_center
    "Bottom Left"    => position.bottom_left
    => position.top_right

var table hud = table.new(tablePos, 2, 8, bgcolor = color.new(#0D0B14, 15), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast and showDash
    table.set_position(hud, tablePos)
    
    // Zone
    zoneColor = outsideUp or outsideDn ? color.red : inUpperEnv or inLowerEnv ? color.orange : color.lime
    table.cell(hud, 0, 0, "Current Zone", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 0, currentZone, text_color = zoneColor, text_size = size.small)

    // Duration
    table.cell(hud, 0, 1, "Bars in Zone", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 1, str.tostring(barsInZone), text_color = color.yellow, text_size = size.small)

    // Tightness
    tightColor = tightness < 30 ? color.lime : tightness < 60 ? color.yellow : color.orange
    table.cell(hud, 0, 2, "Ribbon Tightness", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 2, str.tostring(tightness, "#.#") + "%", text_color = tightColor, text_size = size.small)

    // Width
    table.cell(hud, 0, 3, "Channel Width", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 3, str.tostring(smoothWidth, "#.##"), text_color = color.aqua, text_size = size.small)

    // Volume Boost
    table.cell(hud, 0, 4, "Volume Boost", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 4, str.tostring(volBoost, "#.##") + "x", text_color = color.silver, text_size = size.small)

    // Signals
    table.cell(hud, 0, 5, "Last Up Touch", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 5, touchCountUp == 0 ? "—" : (touchCountUp == 1 ? "1st Touch" : "Retest #" + str.tostring(touchCountUp)), text_color = color.lime, text_size = size.small)

    table.cell(hud, 0, 6, "Last Dn Touch", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 6, touchCountDn == 0 ? "—" : (touchCountDn == 1 ? "1st Touch" : "Retest #" + str.tostring(touchCountDn)), text_color = color.red, text_size = size.small)

    table.cell(hud, 0, 7, "Bars since Touch", text_color = color.white, text_size = size.small)
    table.cell(hud, 1, 7, "Up:" + str.tostring(barsSinceTouchUp) + "  Dn:" + str.tostring(barsSinceTouchDn), text_color = color.gray, text_size = size.small)
````
