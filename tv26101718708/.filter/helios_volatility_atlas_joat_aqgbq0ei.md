# Helios Volatility Atlas [JOAT]

- url: https://www.tradingview.com/script/AqGBQ0Ei-Helios-Volatility-Atlas-JOAT/
- type: indicator
- pine_id: PUB;4cf06093bf1f4d318524bbafafe581e2
- version: 1.0

## Description

[b]Helios Volatility Atlas [JOAT][/b]

[b]Introduction[/b]

Helios Volatility Atlas is an open-source regime and volatility mapping indicator. It combines an adaptive baseline, DMI/ADX trend strength, volatility scoring, VWAP sigma bands, premium/discount structure, squeeze detection, retest zones, right-side level rails, and a top-right dashboard.

The problem Helios addresses is market context. A trend signal means something different in compression than it does during expansion. A retest means something different near discount than it does at an outer volatility channel. Helios brings those layers into one chart so users can interpret price action with regime, volatility, and location in view.

[image]https://www.tradingview.com/x/DMmTtZ6V/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Baseline[/b]

The baseline blends an EMA-style trend component with an efficiency-ratio adaptive component. When price moves efficiently, the adaptive side reacts more. During choppy movement, the baseline becomes slower and more stable.

[b]2. Volatility Score[/b]

ATR is compared against its own moving average and standard deviation. The result is normalized into a 0-100 volatility score so the dashboard can distinguish low, moderate, and high volatility states.

[b]3. Institutional Channels[/b]

Helios draws a channel around a mean using ATR-based distances. Inner channels describe normal volatility, while outer pockets mark more extended price areas where reversion or continuation context may matter.

[b]4. Squeeze and Expansion State[/b]

The squeeze model compares a Bollinger-style width against a Keltner-style width. When compression releases, the chart highlights a transition from low-energy conditions into expansion.

[b]5. Retest Zones and Rails[/b]

Confirmed retests can create projected zones. Right-side rails label important live references such as baseline, VWAP, channels, premium/discount levels, and previous day levels.

[b]Features[/b]

[list]
[*][b]Adaptive baseline:[/b] Blends trend-following and efficiency-aware smoothing
[*][b]Volatility score:[/b] Converts ATR expansion/compression into a dashboard value
[*][b]Trend cloud:[/b] Fills the space between baseline and VWAP
[*][b]VWAP sigma bands:[/b] Shows price stretch around VWAP
[*][b]Premium/discount map:[/b] Uses a rolling anchor range with equilibrium, discount, and premium levels
[*][b]Squeeze detection:[/b] Highlights compression and release states
[*][b]Retest zones:[/b] Projects confirmed bullish and bearish retest areas
[*][b]Right-side rails:[/b] Labels baseline, VWAP, channels, premium/discount, and day levels
[*][b]Theme presets:[/b] Includes Helios, Consensus Aqua, Sentinel Neon, and Cobalt Risk color families
[*][b]Top-right dashboard:[/b] Shows regime, bias, volatility, squeeze, channel, VWAP sigma, price state, and key levels
[/list]

[b]Input Parameters[/b]

[b]Core Engine:[/b]
[list]
[*]Adaptive Baseline Length
[*]Efficiency Lookback
[*]ATR Length
[*]ADX / DMI Length
[*]Volatility Window
[/list]

[b]Volatility System:[/b]
[list]
[*]Channel Memory
[*]Base Channel ATR Multiple
[*]Outer Channel ATR Multiple
[*]Squeeze Length
[*]Squeeze BB and KC multipliers
[/list]

[b]Display:[/b]
[list]
[*]Show Trend Cloud
[*]Show VWAP Sigma Bands
[*]Show Retest Zones
[*]Show Right-Side Level Rails
[*]Theme Preset
[*]Dashboard Text Size
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the regime[/b]
The dashboard classifies the current state as bullish, bearish, expansion, or range.

[b]Step 2: Check volatility[/b]
Use the volatility score and squeeze row to decide whether the market is compressed or expanding.

[b]Step 3: Compare price to VWAP and channels[/b]
VWAP sigma and ATR channels show whether price is near value, stretched, or reverting from an outer area.

[b]Step 4: Use retest zones as context[/b]
Retest zones mark recent confirmed reactions. They are contextual levels, not automatic entries.

[b]Indicator Limitations[/b]

[list]
[*]Adaptive baselines can lag during sudden reversals
[*]Squeeze release does not define direction by itself
[*]Retest zones can fail in strong momentum conditions
[*]Higher volatility symbols may require adjusted ATR/channel settings
[/list]

[b]Originality Statement[/b]

Helios Volatility Atlas combines adaptive trend state, DMI/ADX confirmation, ATR volatility scoring, VWAP sigma distance, squeeze detection, premium/discount location, projected retest zones, and right-edge rails into a single open-source Pine v6 regime atlas. The components are designed to work as one context engine, not as a loose mashup.

[b]Disclaimer[/b]

This script is for educational and informational use only. It is not financial advice and does not predict future price direction. Use independent analysis and risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Helios Volatility Atlas [JOAT]", shorttitle="HVA [JOAT]", overlay=true, max_bars_back=5000, max_labels_count=300, max_lines_count=250, max_boxes_count=120)

// -----------------------------------------------------------------------------
// Helios Volatility Atlas [JOAT]
// Institutional regime map for volatility, fair-value, VWAP deviation, squeeze
// release, and retest behavior. Visual language is a clean rewrite inspired by
// the local JOAT knowledgebase: consensus-band sigma coloring, Sentinel-style
// right-side rails, VWAP deviation bands, and compact dark dashboards.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
groupCalc     = "Core Engine"
groupLevels   = "Key Levels"
groupVol      = "Volatility Channels"
groupRetest   = "Retest Zones"
groupRails    = "Right-Side Rails"
groupVisual   = "Visuals"
groupDash     = "Dashboard"

baselineLen = input.int(34, "Adaptive Baseline Length", minval=5, maxval=300, group=groupCalc)
kamaLen     = input.int(14, "Efficiency Lookback", minval=2, maxval=100, group=groupCalc)
fastLen     = input.int(2, "Fast Period", minval=2, maxval=20, group=groupCalc)
slowLen     = input.int(30, "Slow Period", minval=3, maxval=100, group=groupCalc)
baselineSmo = input.int(5, "Baseline Smoothing", minval=1, maxval=50, group=groupCalc)
atrLen      = input.int(14, "ATR Length", minval=2, maxval=100, group=groupCalc)
adxLen      = input.int(14, "ADX / DMI Length", minval=2, maxval=100, group=groupCalc)
volLen      = input.int(50, "Volatility Window", minval=10, maxval=300, group=groupCalc)
momentumLen = input.int(14, "Momentum Window", minval=5, maxval=100, group=groupCalc)

anchorLen      = input.int(120, "Premium / Discount Anchor", minval=20, maxval=500, group=groupLevels)
showPD         = input.bool(true, "Show Premium / Discount", group=groupLevels)
showVWAP       = input.bool(true, "Show VWAP", group=groupLevels)
showVWAPBands  = input.bool(true, "Show VWAP Sigma Bands", group=groupLevels)
showPDH_PDL    = input.bool(true, "Show Previous Day High / Low Rails", group=groupLevels)
showPWH_PWL    = input.bool(false, "Show Previous Week High / Low", group=groupLevels)

channelLen     = input.int(80, "Channel Memory", minval=20, maxval=400, group=groupVol)
channelAtrMult = input.float(1.65, "Base Channel ATR Multiple", minval=0.25, maxval=8.0, step=0.05, group=groupVol)
extremeAtrMult = input.float(2.65, "Outer Channel ATR Multiple", minval=0.5, maxval=12.0, step=0.05, group=groupVol)
squeezeLen     = input.int(20, "Squeeze Length", minval=5, maxval=100, group=groupVol)
squeezeBBMult  = input.float(2.0, "Squeeze BB Mult", minval=0.5, maxval=5.0, step=0.1, group=groupVol)
squeezeKCMult  = input.float(1.5, "Squeeze KC Mult", minval=0.5, maxval=5.0, step=0.1, group=groupVol)
showChannels   = input.bool(true, "Show Institutional Channels", group=groupVol)
showSqueezeBg  = input.bool(true, "Highlight Compression / Expansion", group=groupVol)

retestLen      = input.int(18, "Retest Memory", minval=5, maxval=100, group=groupRetest)
retestCooldown = input.int(12, "Retest Cooldown", minval=0, maxval=100, group=groupRetest)
zoneExtend     = input.int(32, "Zone Projection Bars", minval=5, maxval=200, group=groupRetest)
zoneMax        = input.int(8, "Max Retest Zones", minval=1, maxval=40, group=groupRetest)
showRetests    = input.bool(true, "Show Retest Zones", group=groupRetest)
showRetestTags = input.bool(true, "Show Retest Tags", group=groupRetest)

showRails      = input.bool(true, "Show Right-Side Level Rails", group=groupRails)
railOffset     = input.int(24, "Rail Label Offset", minval=5, maxval=120, group=groupRails)
railBack       = input.int(12, "Rail Start Back", minval=1, maxval=120, group=groupRails)

showCloud      = input.bool(true, "Show Trend Cloud", group=groupVisual)
showCandles    = input.bool(true, "Color Candles", group=groupVisual)
showFullCandle = input.bool(false, "Full Candle Overlay (High Plot Cost)", group=groupVisual)
showBg         = input.bool(true, "Regime Background", group=groupVisual)
showGlow       = input.bool(true, "Show Regime Glow Markers", group=groupVisual)

themePreset = input.string("Helios Teal", "Theme Preset", options=["Helios Teal", "Consensus Aqua", "Sentinel Neon", "Cobalt Risk"], group=groupVisual)
bullInput   = input.color(#12d6c1, "Bull Core", group=groupVisual)
bearInput   = input.color(#ff5c7a, "Bear Core", group=groupVisual)
accentInput = input.color(#f4b942, "Neutral Accent", group=groupVisual)
vwapInput   = input.color(#2196F3, "VWAP Core", group=groupVisual)
panelBg     = input.color(color.new(#0d1117, 0), "Panel Background", group=groupDash)
panelBorder = input.color(color.new(#334155, 0), "Panel Border", group=groupDash)
textMuted   = input.color(#9ca3af, "Muted Text", group=groupDash)

showDash    = input.bool(true, "Show Dashboard", group=groupDash)
dashSizeSel = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=groupDash)

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_div(float num, float den) =>
    den != 0.0 ? num / den : 0.0

f_tanh(float x) =>
    float ex = math.exp(2.0 * x)
    f_div(ex - 1.0, ex + 1.0)

f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_efficiency_ratio(series float src, int len) =>
    float change = math.abs(src - src[len])
    float vol = math.sum(math.abs(src - src[1]), len)
    f_div(change, vol)

f_adaptive_baseline(series float src, int len, int kamaLookback, int fastPer, int slowPer, int smoothLen) =>
    float emaLine = ta.ema(src, len)
    float er = f_efficiency_ratio(src, kamaLookback)
    float fastSC = 2.0 / (fastPer + 1.0)
    float slowSC = 2.0 / (slowPer + 1.0)
    float sc = math.pow(er * (fastSC - slowSC) + slowSC, 2.0)
    var float kamaLine = na
    kamaLine := na(kamaLine[1]) ? src : kamaLine[1] + sc * (src - kamaLine[1])
    float blended = emaLine + (kamaLine - emaLine) * f_clamp(er, 0.0, 1.0)
    smoothLen > 1 ? ta.ema(blended, smoothLen) : blended

f_state_text(int state) =>
    state == 2 ? "Bull Trend" :
     state == 1 ? "Bull Expansion" :
     state == -1 ? "Bear Expansion" :
     state == -2 ? "Bear Trend" : "Range"

f_state_color(int state, color bull, color bear, color accent) =>
    state == 2 ? bull :
     state == 1 ? color.new(bull, 18) :
     state == -1 ? color.new(bear, 18) :
     state == -2 ? bear : accent

f_num_txt(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_pct_txt(float x) =>
    na(x) ? "n/a" : str.tostring(x, "#.0") + "%"

f_push_box(box[] bx, box b, int maxCount) =>
    array.push(bx, b)
    if array.size(bx) > maxCount
        box old = array.shift(bx)
        box.delete(old)

f_push_label(label[] lb, label l, int maxCount) =>
    array.push(lb, l)
    if array.size(lb) > maxCount
        label old = array.shift(lb)
        label.delete(old)

f_theme_bull(string preset, color customBull) =>
    preset == "Consensus Aqua" ? #00E5FF : preset == "Sentinel Neon" ? #00ff00 : preset == "Cobalt Risk" ? #00E676 : customBull

f_theme_bear(string preset, color customBear) =>
    preset == "Consensus Aqua" ? #FF1744 : preset == "Sentinel Neon" ? #ff0000 : preset == "Cobalt Risk" ? #FF1744 : customBear

f_theme_accent(string preset, color customAccent) =>
    preset == "Consensus Aqua" ? #0b7788 : preset == "Sentinel Neon" ? #808080 : preset == "Cobalt Risk" ? #FFD740 : customAccent

f_nearest_distance(float price, float a, float b, float c, float d, float e, float f) =>
    float dist = 10e10
    dist := not na(a) ? math.min(dist, math.abs(price - a)) : dist
    dist := not na(b) ? math.min(dist, math.abs(price - b)) : dist
    dist := not na(c) ? math.min(dist, math.abs(price - c)) : dist
    dist := not na(d) ? math.min(dist, math.abs(price - d)) : dist
    dist := not na(e) ? math.min(dist, math.abs(price - e)) : dist
    dist := not na(f) ? math.min(dist, math.abs(price - f)) : dist
    dist

f_rail_label_text(string name, float price, float ref) =>
    string pct = not na(price) and ref != 0.0 ? "  " + str.tostring(((price - ref) / ref) * 100.0, "0.00") + "%" : ""
    name + "  " + f_num_txt(price) + pct

// -----------------------------------------------------------------------------
// Theme and core calculations
// -----------------------------------------------------------------------------
bullBase = f_theme_bull(themePreset, bullInput)
bearBase = f_theme_bear(themePreset, bearInput)
accentBase = f_theme_accent(themePreset, accentInput)
vwapBase = vwapInput

atrVal  = ta.atr(atrLen)
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
atrBase = ta.sma(atrVal, volLen)
atrDev  = ta.stdev(atrVal, volLen)
volZ    = f_div(atrVal - atrBase, atrDev)
volScore = f_clamp(50.0 + 50.0 * f_tanh(volZ / 2.0), 0.0, 100.0)
volRatio = f_div(atrVal, atrBase)

baseline = f_adaptive_baseline(close, baselineLen, kamaLen, fastLen, slowLen, baselineSmo)
baselineSlope = baseline - baseline[1]
baselineUp = baselineSlope > 0
baselineDown = baselineSlope < 0

emaFast = ta.ema(close, 9)
emaSlow = ta.ema(close, 21)
impulseUp = emaFast > emaSlow
impulseDown = emaFast < emaSlow

sessionVWAPRaw = ta.vwap(hlc3)
sessionVWAP = na(sessionVWAPRaw) ? ta.ema(hlc3, 34) : sessionVWAPRaw
vwapDeviationRaw = hlc3 - sessionVWAP
vwapSigma = math.max(ta.stdev(vwapDeviationRaw, channelLen), syminfo.mintick)
vwapUpper1 = sessionVWAP + vwapSigma
vwapLower1 = sessionVWAP - vwapSigma
vwapUpper2 = sessionVWAP + vwapSigma * 2.0
vwapLower2 = sessionVWAP - vwapSigma * 2.0
vwapDistance = f_div(close - sessionVWAP, vwapSigma)

rangeHigh = ta.highest(high, anchorLen)
rangeLow  = ta.lowest(low, anchorLen)
rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
equilibrium = rangeLow + rangeSpan * 0.5
discount25 = rangeLow + rangeSpan * 0.25
premium75  = rangeLow + rangeSpan * 0.75

pricePos = f_clamp(f_div(close - rangeLow, rangeSpan), 0.0, 1.0)
priceSigma = pricePos * 2.0 - 1.0

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

vwapAbove = close > sessionVWAP
vwapBelow = close < sessionVWAP
discountState = close < equilibrium and close < premium75
premiumState = close > equilibrium and close > discount25

trendPower = f_clamp((math.abs(baselineSlope) / math.max(atrVal, syminfo.mintick)) * 1.8 + (adxVal / 40.0), 0.0, 2.0)
trendUp = close > baseline and baselineUp and impulseUp
trendDown = close < baseline and baselineDown and impulseDown
rangeRegime = adxVal < 18 and trendPower < 0.8

int regimeState = rangeRegime ? 0 : trendUp and volScore >= 55 ? 2 : trendDown and volScore >= 55 ? -2 : trendUp ? 1 : trendDown ? -1 : 0
string regimeText = f_state_text(regimeState)
color regimeColor = f_state_color(regimeState, bullBase, bearBase, accentBase)

// -----------------------------------------------------------------------------
// Institutional volatility channels and squeeze engine
// -----------------------------------------------------------------------------
dynamicMult = channelAtrMult * (0.75 + f_clamp(volScore / 100.0, 0.0, 1.0))
outerMult = extremeAtrMult * (0.85 + f_clamp(volScore / 140.0, 0.0, 0.85))
centerLine = (baseline + sessionVWAP) * 0.5
channelMean = ta.ema(centerLine, math.max(5, int(channelLen / 4)))
channelUpper = channelMean + atrVal * dynamicMult
channelLower = channelMean - atrVal * dynamicMult
channelOuterUpper = channelMean + atrVal * outerMult
channelOuterLower = channelMean - atrVal * outerMult
channelMidUpper = channelMean + atrVal * dynamicMult * 0.5
channelMidLower = channelMean - atrVal * dynamicMult * 0.5

bbBasis = ta.sma(close, squeezeLen)
bbDev = ta.stdev(close, squeezeLen) * squeezeBBMult
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev
kcBasis = ta.ema(close, squeezeLen)
kcRange = ta.ema(ta.tr(true), squeezeLen) * squeezeKCMult
kcUpper = kcBasis + kcRange
kcLower = kcBasis - kcRange
squeezeOn = bbUpper < kcUpper and bbLower > kcLower
squeezeRelease = barstate.isconfirmed and not squeezeOn and squeezeOn[1]
squeezeExpansion = squeezeRelease and volScore > 50
squeezeText = squeezeOn ? "Compression" : squeezeExpansion ? "Expansion" : volScore >= 70 ? "Open Range" : "Normal"

nearUpperChannel = high >= channelUpper and close < channelOuterUpper
nearLowerChannel = low <= channelLower and close > channelOuterLower
outerRejectBear = barstate.isconfirmed and high > channelOuterUpper and close < channelUpper
outerRejectBull = barstate.isconfirmed and low < channelOuterLower and close > channelLower

// -----------------------------------------------------------------------------
// Retest and price-action zones
// -----------------------------------------------------------------------------
basisCrossUp = ta.crossover(close, baseline)
basisCrossDown = ta.crossunder(close, baseline)
vwapCrossUp = ta.crossover(close, sessionVWAP)
vwapCrossDown = ta.crossunder(close, sessionVWAP)

var int lastBullRetestBar = na
var int lastBearRetestBar = na
canBullRetest = na(lastBullRetestBar) or bar_index - lastBullRetestBar > retestCooldown
canBearRetest = na(lastBearRetestBar) or bar_index - lastBearRetestBar > retestCooldown

bullRetestRaw = trendUp and low <= math.max(baseline, channelMidLower) and close > baseline and close > open and canBullRetest
bearRetestRaw = trendDown and high >= math.min(baseline, channelMidUpper) and close < baseline and close < open and canBearRetest
bullRetest = barstate.isconfirmed and bullRetestRaw
bearRetest = barstate.isconfirmed and bearRetestRaw

var box[] retestBoxes = array.new<box>()
var label[] retestLabels = array.new<label>()

if showRetests and bullRetest
    lastBullRetestBar := bar_index
    float top = math.max(close, baseline + atrVal * 0.25)
    float bot = math.min(low, baseline - atrVal * 0.18)
    box b = box.new(bar_index, top, bar_index + zoneExtend, bot, border_color=color.new(bullBase, 55), bgcolor=color.new(bullBase, 88), border_width=1)
    f_push_box(retestBoxes, b, zoneMax)
    if showRetestTags
        label l = label.new(bar_index, bot, "HVA RETEST\n" + f_num_txt(bot), color=color.new(#161b22, 5), textcolor=color.new(bullBase, 0), style=label.style_label_up, size=size.tiny)
        f_push_label(retestLabels, l, zoneMax)

if showRetests and bearRetest
    lastBearRetestBar := bar_index
    float top = math.max(high, baseline + atrVal * 0.18)
    float bot = math.min(close, baseline - atrVal * 0.25)
    box b = box.new(bar_index, top, bar_index + zoneExtend, bot, border_color=color.new(bearBase, 55), bgcolor=color.new(bearBase, 88), border_width=1)
    f_push_box(retestBoxes, b, zoneMax)
    if showRetestTags
        label l = label.new(bar_index, top, "HVA RETEST\n" + f_num_txt(top), color=color.new(#161b22, 5), textcolor=color.new(bearBase, 0), style=label.style_label_down, size=size.tiny)
        f_push_label(retestLabels, l, zoneMax)

// -----------------------------------------------------------------------------
// Visual structure: baseline, VWAP, premium/discount, channels, and gradients
// -----------------------------------------------------------------------------
baselinePlot = plot(baseline, "Adaptive Baseline", color=regimeColor, linewidth=2)
vwapPlot = plot(showVWAP ? sessionVWAP : na, "VWAP", color=color.new(vwapBase, 0), linewidth=2)
eqPlot = plot(showPD ? equilibrium : na, "Equilibrium", color=color.new(accentBase, 20), linewidth=1, style=plot.style_line)
premiumPlot = plot(showPD ? premium75 : na, "Premium", color=color.new(bearBase, 20), linewidth=1, style=plot.style_line)
discountPlot = plot(showPD ? discount25 : na, "Discount", color=color.new(bullBase, 20), linewidth=1, style=plot.style_line)

cloudTop = plot(showCloud ? math.max(baseline, sessionVWAP) : na, "Cloud Top", display=display.none)
cloudBot = plot(showCloud ? math.min(baseline, sessionVWAP) : na, "Cloud Bot", display=display.none)
fill(cloudTop, cloudBot, color.new(regimeColor, 85), title="Trend Cloud")

fill(eqPlot, premiumPlot, color.new(bearBase, 92), title="Premium Fill")
fill(discountPlot, eqPlot, color.new(bullBase, 92), title="Discount Fill")
fill(baselinePlot, vwapPlot, color.new(regimeColor, 90), title="Baseline VWAP Band")

vwapU1Plot = plot(showVWAP and showVWAPBands ? vwapUpper1 : na, "VWAP +1 Sigma", color=color.new(vwapBase, 50), linewidth=1)
vwapL1Plot = plot(showVWAP and showVWAPBands ? vwapLower1 : na, "VWAP -1 Sigma", color=color.new(vwapBase, 50), linewidth=1)
vwapU2Plot = plot(showVWAP and showVWAPBands ? vwapUpper2 : na, "VWAP +2 Sigma", color=color.new(vwapBase, 75), linewidth=1)
vwapL2Plot = plot(showVWAP and showVWAPBands ? vwapLower2 : na, "VWAP -2 Sigma", color=color.new(vwapBase, 75), linewidth=1)
fill(vwapU1Plot, vwapL1Plot, color.new(vwapBase, 93), title="VWAP Inner Deviation")
fill(vwapU2Plot, vwapU1Plot, color.new(bearBase, 94), title="VWAP Upper Stretch")
fill(vwapL1Plot, vwapL2Plot, color.new(bullBase, 94), title="VWAP Lower Stretch")

chUPlot = plot(showChannels ? channelUpper : na, "Institutional Channel High", color=color.new(bearBase, 35), linewidth=1)
chLPlot = plot(showChannels ? channelLower : na, "Institutional Channel Low", color=color.new(bullBase, 35), linewidth=1)
chOUPlot = plot(showChannels ? channelOuterUpper : na, "Outer Channel High", color=color.new(bearBase, 70), linewidth=1)
chOLPlot = plot(showChannels ? channelOuterLower : na, "Outer Channel Low", color=color.new(bullBase, 70), linewidth=1)
chMPlot = plot(showChannels ? channelMean : na, "Institutional Channel Mean", color=color.new(accentBase, 55), linewidth=1)
fill(chUPlot, chOUPlot, color.new(bearBase, 93), title="Upper Expansion Pocket")
fill(chOLPlot, chLPlot, color.new(bullBase, 93), title="Lower Expansion Pocket")
fill(chLPlot, chUPlot, color.new(regimeColor, 96), title="Core Volatility Channel")

// -----------------------------------------------------------------------------
// Candle and background regime mapping
// -----------------------------------------------------------------------------
mixBull = color.from_gradient(f_clamp(priceSigma, -1.0, 1.0), -1.0, 1.0, color.new(bullBase, 82), bullBase)
mixBear = color.from_gradient(f_clamp(priceSigma, -1.0, 1.0), -1.0, 1.0, bearBase, color.new(bearBase, 82))
mixRange = color.from_gradient(f_clamp(volScore, 0.0, 100.0), 0.0, 100.0, color.new(accentBase, 80), color.new(accentBase, 55))
sigmaGlow = color.from_gradient(f_clamp(vwapDistance, -2.0, 2.0), -2.0, 2.0, bearBase, bullBase)

barCol =
     regimeState == 2 ? color.new(mixBull, int(math.round(70 - trendPower * 20))) :
     regimeState == 1 ? color.new(bullBase, int(math.round(82 - trendPower * 18))) :
     regimeState == -1 ? color.new(bearBase, int(math.round(82 - trendPower * 18))) :
     regimeState == -2 ? color.new(mixBear, int(math.round(70 - trendPower * 20))) :
     mixRange

candleBody = showCandles and showFullCandle ? color.new(barCol, 12) : na
candleWick = showCandles and showFullCandle ? color.new(sigmaGlow, 0) : na
candleBorder = showCandles and showFullCandle ? color.new(regimeColor, 0) : na

barcolor(showCandles and not showFullCandle ? barCol : na, title="Regime Candles")
// Full overlay candles are intentionally omitted to keep the script below TradingView's plot limit.
bgcolor(showBg ? color.new(regimeColor, 92 - int(math.round(f_clamp(trendPower, 0.0, 1.0) * 18.0))) : na, title="Regime Background")
bgcolor(showSqueezeBg and squeezeOn ? color.new(accentBase, 92) : na, title="Compression Background")
bgcolor(showSqueezeBg and squeezeExpansion ? color.new(regimeColor, 88) : na, title="Expansion Background")

plotshape(showGlow and bullRetest ? low - atrVal * 0.18 : na, "Bull Retest Core", shape.circle, location.absolute, color.new(bullBase, 0), size=size.tiny)
plotshape(showGlow and bearRetest ? high + atrVal * 0.18 : na, "Bear Retest Core", shape.circle, location.absolute, color.new(bearBase, 0), size=size.tiny)

// -----------------------------------------------------------------------------
// Confirmed state signals
// -----------------------------------------------------------------------------
bullRegimeShift = barstate.isconfirmed and regimeState > 0 and regimeState[1] <= 0
bearRegimeShift = barstate.isconfirmed and regimeState < 0 and regimeState[1] >= 0
volExpansion = barstate.isconfirmed and volScore >= 70 and volScore[1] < 70
pdTransitionBull = barstate.isconfirmed and close > equilibrium and close[1] <= equilibrium and close < premium75
pdTransitionBear = barstate.isconfirmed and close < equilibrium and close[1] >= equilibrium and close > discount25

// -----------------------------------------------------------------------------
// Right-side rail and label projection
// -----------------------------------------------------------------------------
var line railBaseline = na
var line railVWAP = na
var line railUpper = na
var line railLower = na
var line railOuterUpper = na
var line railOuterLower = na
var line railPremium = na
var line railDiscount = na
var line railPDH = na
var line railPDL = na
var label lblBaseline = na
var label lblVWAP = na
var label lblUpper = na
var label lblLower = na
var label lblOuterUpper = na
var label lblOuterLower = na
var label lblPremium = na
var label lblDiscount = na
var label lblPDH = na
var label lblPDL = na

if barstate.islast
    line.delete(railBaseline)
    line.delete(railVWAP)
    line.delete(railUpper)
    line.delete(railLower)
    line.delete(railOuterUpper)
    line.delete(railOuterLower)
    line.delete(railPremium)
    line.delete(railDiscount)
    line.delete(railPDH)
    line.delete(railPDL)
    label.delete(lblBaseline)
    label.delete(lblVWAP)
    label.delete(lblUpper)
    label.delete(lblLower)
    label.delete(lblOuterUpper)
    label.delete(lblOuterLower)
    label.delete(lblPremium)
    label.delete(lblDiscount)
    label.delete(lblPDH)
    label.delete(lblPDL)
    int xStart = bar_index - railBack
    int xEnd = bar_index + railOffset
    if showRails
        railBaseline := line.new(xStart, baseline, xEnd, baseline, color=color.new(regimeColor, 0), style=line.style_dotted, width=1)
        lblBaseline := label.new(xEnd, baseline, f_rail_label_text("BASE", baseline, close), color=color.new(color.white, 100), textcolor=color.new(regimeColor, 0), style=label.style_label_left, size=size.small)
        railVWAP := line.new(xStart, sessionVWAP, xEnd + 2, sessionVWAP, color=color.new(vwapBase, 0), style=line.style_dotted, width=1)
        lblVWAP := label.new(xEnd + 2, sessionVWAP, f_rail_label_text("VWAP", sessionVWAP, close), color=color.new(color.white, 100), textcolor=color.new(vwapBase, 0), style=label.style_label_left, size=size.small)
        railUpper := line.new(xStart, channelUpper, xEnd + 4, channelUpper, color=color.new(bearBase, 18), style=line.style_dashed, width=1)
        lblUpper := label.new(xEnd + 4, channelUpper, f_rail_label_text("CH-H", channelUpper, close), color=color.new(color.white, 100), textcolor=color.new(bearBase, 0), style=label.style_label_left, size=size.small)
        railLower := line.new(xStart, channelLower, xEnd + 4, channelLower, color=color.new(bullBase, 18), style=line.style_dashed, width=1)
        lblLower := label.new(xEnd + 4, channelLower, f_rail_label_text("CH-L", channelLower, close), color=color.new(color.white, 100), textcolor=color.new(bullBase, 0), style=label.style_label_left, size=size.small)
        railOuterUpper := line.new(xStart, channelOuterUpper, xEnd + 6, channelOuterUpper, color=color.new(bearBase, 42), style=line.style_dotted, width=1)
        lblOuterUpper := label.new(xEnd + 6, channelOuterUpper, f_rail_label_text("EXT-H", channelOuterUpper, close), color=color.new(color.white, 100), textcolor=color.new(bearBase, 0), style=label.style_label_left, size=size.tiny)
        railOuterLower := line.new(xStart, channelOuterLower, xEnd + 6, channelOuterLower, color=color.new(bullBase, 42), style=line.style_dotted, width=1)
        lblOuterLower := label.new(xEnd + 6, channelOuterLower, f_rail_label_text("EXT-L", channelOuterLower, close), color=color.new(color.white, 100), textcolor=color.new(bullBase, 0), style=label.style_label_left, size=size.tiny)
        railPremium := line.new(xStart, premium75, xEnd + 8, premium75, color=color.new(bearBase, 48), style=line.style_dotted, width=1)
        lblPremium := label.new(xEnd + 8, premium75, f_rail_label_text("PREM", premium75, close), color=color.new(color.white, 100), textcolor=color.new(bearBase, 0), style=label.style_label_left, size=size.tiny)
        railDiscount := line.new(xStart, discount25, xEnd + 8, discount25, color=color.new(bullBase, 48), style=line.style_dotted, width=1)
        lblDiscount := label.new(xEnd + 8, discount25, f_rail_label_text("DISC", discount25, close), color=color.new(color.white, 100), textcolor=color.new(bullBase, 0), style=label.style_label_left, size=size.tiny)
        if showPDH_PDL
            railPDH := line.new(xStart, pdh, xEnd + 10, pdh, color=color.new(bearBase, 55), style=line.style_dashed, width=1)
            lblPDH := label.new(xEnd + 10, pdh, f_rail_label_text("PDH", pdh, close), color=color.new(color.white, 100), textcolor=color.new(bearBase, 0), style=label.style_label_left, size=size.tiny)
            railPDL := line.new(xStart, pdl, xEnd + 10, pdl, color=color.new(bullBase, 55), style=line.style_dashed, width=1)
            lblPDL := label.new(xEnd + 10, pdl, f_rail_label_text("PDL", pdl, close), color=color.new(color.white, 100), textcolor=color.new(bullBase, 0), style=label.style_label_left, size=size.tiny)

// -----------------------------------------------------------------------------
// Dashboard diagnostics
// -----------------------------------------------------------------------------
nearestLevelDist = f_nearest_distance(close, baseline, sessionVWAP, channelUpper, channelLower, pdh, pdl)
nearestLevelATR = f_div(nearestLevelDist, atrVal)
momentumScore = f_clamp(50.0 + ta.roc(close, momentumLen) * 3.0, 0.0, 100.0)
structureText = close > premium75 ? "Premium" : close < discount25 ? "Discount" : close > equilibrium ? "Upper EQ" : "Lower EQ"
channelText = close > channelOuterUpper ? "Above Extreme" : close > channelUpper ? "Upper Stretch" : close < channelOuterLower ? "Below Extreme" : close < channelLower ? "Lower Stretch" : "Inside Channel"
retestText = bullRetest ? "Bull Retest" : bearRetest ? "Bear Retest" : "Waiting"
signalText = bullRegimeShift ? "Bull Shift" : bearRegimeShift ? "Bear Shift" : squeezeExpansion ? "Release" : outerRejectBull ? "Low Reclaim" : outerRejectBear ? "High Reject" : "No Event"
signalColor = bullRegimeShift or bullRetest or outerRejectBull ? bullBase : bearRegimeShift or bearRetest or outerRejectBear ? bearBase : squeezeExpansion ? accentBase : textMuted

var table dash = table.new(position.top_right, 2, 15, bgcolor=color.new(panelBg, 8), border_color=color.new(panelBorder, 0), border_width=1, frame_color=color.new(panelBorder, 0), frame_width=1)

if showDash and barstate.islast
    dashSize = f_size(dashSizeSel)
    biasTxt = trendUp ? "Bullish" : trendDown ? "Bearish" : "Neutral"
    vwapTxt = vwapAbove ? "Above VWAP" : vwapBelow ? "Below VWAP" : "At VWAP"
    levelTxt = "PDH " + f_num_txt(pdh) + " / PDL " + f_num_txt(pdl)
    weekTxt = "PWH " + f_num_txt(pwh) + " / PWL " + f_num_txt(pwl)
    table.cell(dash, 0, 0, "HELIOS VOLATILITY ATLAS", text_color=color.white, bgcolor=color.new(regimeColor, 70), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 0, "HVA", text_color=color.white, bgcolor=color.new(regimeColor, 70), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 1, "Regime", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeText, text_color=regimeColor, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Bias", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, biasTxt, text_color=trendUp ? bullBase : trendDown ? bearBase : accentBase, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Volatility", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(volScore, "#.0") + " / 100", text_color=color.from_gradient(volScore, 0, 100, color.new(accentBase, 0), color.new(bearBase, 0)), bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Squeeze", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, squeezeText, text_color=squeezeOn ? accentBase : squeezeExpansion ? regimeColor : color.white, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Channel", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, channelText, text_color=close > channelUpper ? bearBase : close < channelLower ? bullBase : color.white, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 6, "VWAP Sigma", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, (vwapDistance >= 0 ? "+" : "") + str.tostring(vwapDistance, "#.00") + " stdev", text_color=sigmaGlow, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 7, "Price State", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, structureText, text_color=discountState ? bullBase : premiumState ? bearBase : accentBase, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 8, "Retest", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, retestText, text_color=bullRetest ? bullBase : bearRetest ? bearBase : textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 9, "Nearest Rail", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(nearestLevelATR, "#.00") + " ATR", text_color=nearestLevelATR < 0.35 ? accentBase : color.white, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 10, "Momentum", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 10, f_pct_txt(momentumScore), text_color=color.from_gradient(momentumScore, 0, 100, bearBase, bullBase), bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 11, "VWAP", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 11, vwapTxt, text_color=vwapAbove ? bullBase : vwapBelow ? bearBase : accentBase, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 12, "Event", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 12, signalText, text_color=signalColor, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 13, "Key Levels", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 13, levelTxt, text_color=color.white, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)
    table.cell(dash, 0, 14, "Week Range", text_color=textMuted, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_left)
    table.cell(dash, 1, 14, weekTxt, text_color=color.white, bgcolor=color.new(panelBg, 0), text_size=dashSize, text_halign=text.align_right)

// -----------------------------------------------------------------------------
// Data-window exports for diagnostics and downstream strategy design
// -----------------------------------------------------------------------------
// Extra diagnostics are shown in the dashboard rather than hidden plots to preserve plot budget.

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
alertcondition(bullRegimeShift, title="HVA Bull Regime Shift", message="Helios Volatility Atlas: bullish confirmed shift on {{ticker}} ({{interval}})")
alertcondition(bearRegimeShift, title="HVA Bear Regime Shift", message="Helios Volatility Atlas: bearish confirmed shift on {{ticker}} ({{interval}})")
alertcondition(volExpansion, title="HVA Volatility Expansion", message="Helios Volatility Atlas: volatility expansion on {{ticker}} ({{interval}})")
alertcondition(squeezeExpansion, title="HVA Squeeze Release", message="Helios Volatility Atlas: confirmed compression release on {{ticker}} ({{interval}})")
alertcondition(bullRetest, title="HVA Bullish Retest", message="Helios Volatility Atlas: bullish retest zone on {{ticker}} ({{interval}})")
alertcondition(bearRetest, title="HVA Bearish Retest", message="Helios Volatility Atlas: bearish retest zone on {{ticker}} ({{interval}})")
alertcondition(pdTransitionBull, title="HVA Equilibrium Recovery", message="Helios Volatility Atlas: recovery through equilibrium on {{ticker}}")
alertcondition(pdTransitionBear, title="HVA Equilibrium Rejection", message="Helios Volatility Atlas: rejection through equilibrium on {{ticker}}")
````
