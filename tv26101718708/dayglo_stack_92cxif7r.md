# DayGlo Stack

- url: https://www.tradingview.com/script/92CxIf7r-DayGlo-Stack/
- type: indicator
- pine_id: PUB;475697c035d14872864ef17d7f323ead
- version: 1.0

## Description

A version of RSI that indicates bullish or bearish momentum. Blue is good. Pink is bad.

## Source Code

````pine
//@version=6
indicator("DayGlo Stack", shorttitle="DayGlo Stack", overlay=false)

// =========================================================================
// INPUTS 
// =========================================================================
grp_rsi = "RSI OPTIONS"
fastLen = input.int(9,  title="Fast RSI", group=grp_rsi)
midLen  = input.int(14, title="Medium RSI", group=grp_rsi)
slowLen = input.int(24, title="Slow RSI", group=grp_rsi)

grp_band = "BAND BEHAVIOR"
baseThick   = input.float(1.0, title="Base thickness (RSI pts)", group=grp_band)
expStrength = input.float(5.6, title="Expansion strength", group=grp_band)
maxThick    = input.float(12.0, title="Max thickness (RSI pts)", group=grp_band)
bandOpac    = input.int(35, title="Band opacity", group=grp_band)

grp_style = "STYLE"
showRSI     = input.bool(true, title="Show RSI lines", group=grp_style)
lineOpac    = input.int(25, title="Line opacity", group=grp_style)
glowAccents = input.bool(true, title="Glow accents", group=grp_style)
glowOpac    = input.int(80, title="Glow opacity", group=grp_style)

grp_levels = "OPTIONAL LEVELS"
show30 = input.bool(false, title="Show 30 level", group=grp_levels)
show50 = input.bool(false, title="Show 50 level", group=grp_levels)
show70 = input.bool(false, title="Show 70 level", group=grp_levels)

grp_sigils = "WAR SIGILS"
showFlips = input.bool(true, title="Show flip markers", group=grp_sigils)
bullSigil = input.string("★", title="Bull Sigil", group=grp_sigils)
bearSigil = input.string("★", title="Bear Sigil", group=grp_sigils)
bullColor = input.color(#00FFFF, title="Bull Sigil Color", group=grp_sigils) // Cyan
bearColor = input.color(#FF00FF, title="Bear Sigil Color", group=grp_sigils) // Fuchsia
sigilGlow = input.bool(true, title="Sigil glow (single icon, larger)", group=grp_sigils)
maxSigils = input.int(300, title="Max sigils on chart (performance)", group=grp_sigils)

grp_placement = "SIGIL PLACEMENT"
botZoneDist = input.float(2.5, title="Bottom zone distance (x band thickness)", group=grp_placement)
minBotPad   = input.float(10.0, title="Minimum bottom pad (RSI pts)", group=grp_placement)
extraDrop   = input.float(0.15, title="Extra drop below anchor", group=grp_placement)

// =========================================================================
// CALCULATIONS
// =========================================================================
fastRSI = ta.rsi(close, fastLen)
midRSI  = ta.rsi(close, midLen)
slowRSI = ta.rsi(close, slowLen)

bullishStack = fastRSI > midRSI and midRSI > slowRSI
bearishStack = fastRSI < midRSI and midRSI < slowRSI

separation = math.abs(fastRSI - slowRSI)
rawThickness = baseThick + (separation * expStrength)
thickness = math.min(rawThickness, maxThick)

upperBand = midRSI + (thickness / 2)
lowerBand = midRSI - (thickness / 2)

// =========================================================================
// COLORS & STATE
// =========================================================================
c_bull = color.new(#00E676, 0) // Bright Neon Green
c_chop = color.new(#9E9E9E, 0) // Gray for chop/bearish drops

stateColor = bullishStack ? c_bull : c_chop

// Pine Script transparency handling
t_band = 100 - bandOpac
t_line = 100 - lineOpac
t_glow = 100 - glowOpac

// =========================================================================
// PLOTTING (STRICT Z-INDEX REORDERING)
// =========================================================================
// 1. Bottom Layer: Dynamic Band Fill
p_upper = plot(upperBand, color=color.new(stateColor, 100), title="Upper Band limits")
p_lower = plot(lowerBand, color=color.new(stateColor, 100), title="Lower Band limits")
fill(p_upper, p_lower, color=color.new(stateColor, t_band), title="Dynamic Band Fill")

// 2. Next Layer Up: The Glow (Thick line to frame the core line)
plot(glowAccents and showRSI ? midRSI : na, color=color.new(stateColor, t_glow), linewidth=4, title="Mid Layer Glow")

// 3. Middle Layers: Fast and Slow RSIs
// *Fix: Set Slow RSI to explicit gray to match the original "green, white, grey" look
plot(showRSI ? slowRSI : na, color=color.new(color.gray, t_line), linewidth=1, title="Slow RSI")
plot(showRSI ? fastRSI : na, color=color.new(stateColor, t_line), linewidth=1, title="Fast RSI")

// 4. Top Layer: Core Mid RSI 
// *Fix: Forced to 0% transparency (solid) so it cuts cleanly over the glow and background
plot(showRSI ? midRSI : na, color=color.white, linewidth=2, title="Mid RSI (Core)")

// Optional Background Levels
hline(show30 ? 30 : na, color=color.new(color.gray, 50), linestyle=hline.style_dotted, title="30 Level")
hline(show50 ? 50 : na, color=color.new(color.gray, 50), linestyle=hline.style_dotted, title="50 Level")
hline(show70 ? 70 : na, color=color.new(color.gray, 50), linestyle=hline.style_dotted, title="70 Level")

// =========================================================================
// SIGNALS (STATE REVERSAL ENGINE)
// =========================================================================
var int currentSigilState = 0 

actualBullFlip = bullishStack and currentSigilState != 1
actualBearFlip = bearishStack and currentSigilState != -1

if actualBullFlip
    currentSigilState := 1
if actualBearFlip
    currentSigilState := -1

anchorLevel = lowerBand - (thickness * botZoneDist)
finalYLevel = math.max(anchorLevel, minBotPad) - extraDrop

plotchar(showFlips and actualBullFlip and sigilGlow ? finalYLevel : na, title="Bull Sigil (Glow/Larger)", char=bullSigil, location=location.absolute, color=bullColor, size=size.tiny)
plotchar(showFlips and actualBullFlip and not sigilGlow ? finalYLevel : na, title="Bull Sigil (Smaller)", char=bullSigil, location=location.absolute, color=bullColor, size=size.tiny)

plotchar(showFlips and actualBearFlip and sigilGlow ? finalYLevel : na, title="Bear Sigil (Glow/Larger)", char=bearSigil, location=location.absolute, color=bearColor, size=size.tiny)
plotchar(showFlips and actualBearFlip and not sigilGlow ? finalYLevel : na, title="Bear Sigil (Smaller)", char=bearSigil, location=location.absolute, color=bearColor, size=size.tiny)
````
