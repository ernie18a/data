# Gravity Well Trend | Lyro RS

- url: https://www.tradingview.com/script/H80GVoRt-Gravity-Well-Trend-Lyro-RS/
- type: indicator
- pine_id: PUB;b27d0b8ab26a4ab7bd34f97d46871f71
- version: 2.0

## Description

[b]Overview: [/b]
Gravity Well Trend is a volume-weighted mean-reversion and trend tool built around a simple idea: the volume-weighted price center is where the market's "mass" sits, and price orbiting near it is effectively captured. A real trend only exists when price achieves sufficient distance from that center in ATR terms while the center itself is accelerating the same direction — an escape from the well, not just a temporary orbit. Three selectable signal modes let it run as a strict trend filter, a simple midline flip, or a band-reclaim system.

[b]Key Features[/b]
[list]
[*]Volume-Weighted Gravity Center: Calculates a volume-weighted moving average as the "center of mass" for price, forming the core reference line the rest of the indicator is built around.
[*]Escape-Distance Trend Logic: In Trend mode, a bullish or bearish trend only confirms when price is far enough from the center (in ATR units) AND the center itself is moving the same direction — distance alone with a flat center doesn't count.
[*]Three Signal Modes: [b]Trend[/b] — flips only on a confirmed escape from the gravity well. [b]Midline[/b] — simple long/short based on whether price is above or below the center. [b]Bands[/b] — flips long on a cross above the lowest band and stays long until a cross below the highest band flips it short.
[*]Layered Band Envelope: Plots an outer and inner band pair around the center (inner bands at half the outer width), with graded zone fills between center and bands for a clear visual sense of price's position within the well.
[*]Gradient Strength Visualization: The gravity center line and candle coloring use a gradient blend based on how far price has traveled from center relative to the band width, giving an at-a-glance read on trend conviction.
[*]Candle Coloring: Optionally recolors chart candles using the same gradient logic as the center line.
[*]Customizable Visuals: Choose from 4 preset palettes — Classic, Mystic, Accented, Royal — or define your own custom bullish/bearish colors.
[*]Built-In Signals: Automatically plots long/short labels on confirmed trend flips.
[/list]

[b]How It Works[/b]
[list=1]
[*]Center Calculation – Computes a volume-weighted moving average of the source over the chosen length to establish the gravity center.
[*]Distance Measurement – Measures the distance between price and the center in ATR units to gauge how far price has strayed from its center of mass.
[*]Band Construction – Builds an outer band pair at the full Band Width setting and an inner pair at half that width, forming a layered envelope around the center.
[*]Mode-Dependent Trend Logic – Trend mode requires both sufficient escape distance and a rising/falling center; Midline mode simply follows price relative to center; Bands mode uses crosses of the outer bands to flip and hold direction.
[*]Visualization – Plots the gravity center with layered glow, the band envelope with graded fills, flip signal labels, and gradient-based candle coloring.
[/list]

[b]Practical Use[/b]
[list]
[*]Trend Confirmation – Use Trend mode when you want to avoid acting on price simply drifting away from center without real directional follow-through in the center itself.
[*]Simple Directional Bias – Use Midline mode for a straightforward above/below-center read when you want more frequent signals.
[*]Range/Reclaim Trading – Use Bands mode to trade reclaims of extreme levels, holding a position until the opposite extreme is reclaimed.
[*]Zone Awareness – Watch the graded band zones to see how extended price is relative to its recent volume-weighted center before committing to a trade.
[/list]

[b]Customization[/b]
[list]
[*]Switch between Trend, Midline, and Bands signal modes to match your trading style.
[*]Adjust Length to tune how responsive the gravity center is to recent price/volume.
[*]Adjust Escape Distance to control how far price must travel (with a moving center) to confirm a trend in Trend mode.
[*]Adjust Band Width and ATR Length to reshape the band envelope and its sensitivity.
[*]Toggle bands, signal labels, and candle coloring independently.
[*]Pick a preset palette or define fully custom bullish/bearish colors.
[/list]

[b]⚠️Disclaimer[/b]
This indicator is a tool for technical analysis and does not provide guaranteed results. It should be used in conjunction with other analysis methods and proper risk management practices. The creators of this indicator are not responsible for any financial decisions made based on its signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LyroRS

//@version=6
indicator("Gravity Well Trend | Lyro RS", "Gravity Well | Lyro RS", overlay=true)

// ╔══════════════════════════════════════════════════╗
// ║                INPUT GROUPS                      ║
// ╚══════════════════════════════════════════════════╝
settings_g = '𝗦𝗘𝗧𝗧𝗜𝗡𝗚𝗦'
features_g = '𝗙𝗘𝗔𝗧𝗨𝗥𝗘𝗦'
color_g    = '𝗖𝗢𝗟𝗢𝗥'

// ╔══════════════════════════════════════════════════╗
// ║               CORE SETTINGS                      ║
// ╚══════════════════════════════════════════════════╝
src     = input.source(close, "𝗦𝗼𝘂𝗿𝗰𝗲", group=settings_g)
sigMode = input.string("Trend", "𝗦𝗶𝗴𝗻𝗮𝗹 𝗠𝗼𝗱𝗲", options=["Trend", "Midline", "Bands"], group=settings_g, tooltip="Trend — flips only when price is far enough from the center and the center is turning the same way.\n\nMidline — long while price sits above the middle line, short while it sits below.\n\nBands — a cross above the lowest band turns it long and it stays long until a cross below the highest band turns it short.")

length   = input.int(50, "𝗟𝗲𝗻𝗴𝘁𝗵", minval=5, group=settings_g, tooltip="Window for the volume-weighted price center — the bottom of the gravity well.")
mult     = input.float(2.0, "𝗘𝘀𝗰𝗮𝗽𝗲 𝗗𝗶𝘀𝘁𝗮𝗻𝗰𝗲", step=0.25, minval=0.5, maxval=5, group=settings_g, tooltip="Distance from the center, in ATR units, price must reach — with the center itself moving the same way — to escape the well and flip the trend.")
bandMult = input.float(3.0, "𝗕𝗮𝗻𝗱 𝗪𝗶𝗱𝘁𝗵", step=0.25, minval=0.5, maxval=10, group=settings_g, tooltip="Width of the outermost bands. The inner pair sits at half this distance.")
atrLen   = input.int(14, "𝗔𝗧𝗥 𝗟𝗲𝗻𝗴𝘁𝗵", minval=1, group=settings_g)

// ╔══════════════════════════════════════════════════╗
// ║                 FEATURES                         ║
// ╚══════════════════════════════════════════════════╝
showSignals = input.bool(true, "𝗦𝗵𝗼𝘄 𝗦𝗶𝗴𝗻𝗮𝗹𝘀", group=features_g)
showBands   = input.bool(true, "𝗦𝗵𝗼𝘄 𝗕𝗮𝗻𝗱𝘀", group=features_g, tooltip="Displays the band envelope around the center, fading outward.")
candleColor = input.bool(true, "𝗖𝗮𝗻𝗱𝗹𝗲 𝗖𝗼𝗹𝗼𝗿𝗶𝗻𝗴", group=features_g)

// ╔══════════════════════════════════════════════════╗
// ║                   COLOR                          ║
// ╚══════════════════════════════════════════════════╝
ColMode = input.string("Mystic", "Custom Color Palette", inline="drop", options=["Classic", "Mystic", "Accented", "Royal"], display=display.none, group=color_g)
cpyn   = input.bool(false, "Use Custom Palette", group=color_g, display=display.none)
cp_UpC = input.color(#00ff00, "Custom Up", inline="Custom Palette", group=color_g, display=display.none)
cp_DnC = input.color(#ff0000, "Custom Down", inline="Custom Palette", group=color_g, display=display.none)

color UpC = na
color DnC = na

switch ColMode
    "Classic" =>
        UpC := #00E676
        DnC := #880E4F
    "Mystic" =>
        UpC := #30FDCF
        DnC := #E117B7
    "Accented" =>
        UpC := #9618F7
        DnC := #FF0078
    "Royal" =>
        UpC := #FFC107
        DnC := #673AB7

if cpyn
    UpC := cp_UpC
    DnC := cp_DnC

// ╔══════════════════════════════════════════════════╗
// ║              GRAVITY ENGINE                      ║
// ╚══════════════════════════════════════════════════╝
// The volume-weighted mean is where the market's mass sits. Price
// orbiting near it is captured; a trend is an ESCAPE — sufficient
// distance from the center while the center itself accelerates
// the same way. Distance alone with a flat center is just an orbit.
center = ta.sma(src * volume, length) / ta.sma(volume, length)
atr    = ta.atr(atrLen)
dist   = (src - center) / atr

// Band ladder — outer pair at full width, inner pair at half
bandHi  = center + bandMult * atr
bandHiM = center + bandMult * 0.5 * atr
bandLoM = center - bandMult * 0.5 * atr
bandLo  = center - bandMult * atr

// ╔══════════════════════════════════════════════════╗
// ║                 TREND ENGINE                     ║
// ╚══════════════════════════════════════════════════╝
reclaimUp = ta.crossover(src, bandLo)
reclaimDn = ta.crossunder(src, bandHi)

var int trend = 0
if sigMode == "Trend"
    if dist > mult and center > center[1]
        trend := 1
    else if dist < -mult and center < center[1]
        trend := -1
else if sigMode == "Midline"
    trend := src > center ? 1 : src < center ? -1 : trend
else
    if reclaimUp
        trend := 1
    else if reclaimDn
        trend := -1

flipUp   = trend == 1  and trend[1] != 1
flipDown = trend == -1 and trend[1] != -1


// ╔══════════════════════════════════════════════════╗
// ║                   VISUALS                        ║
// ╚══════════════════════════════════════════════════╝
trendCol = trend == 1 ? UpC : trend == -1 ? DnC : color.gray

strength = math.min(math.abs(dist) / bandMult, 1.0)
gradCol  = color.from_gradient(strength, 0, 1, color.new(trendCol, 65), trendCol)

// Center with layered glow
plot(center, "Center [Outer Glow]", color=color.new(trendCol, 90), linewidth=10, editable=false)
plot(center, "Center [Glow]", color=color.new(trendCol, 78), linewidth=5, editable=false)
pC = plot(center, "Gravity Center", color=gradCol, linewidth=2)

// Band envelope — glow layers, then edges, then graded fills


pHi  = plot(showBands ? bandHi  : na, "Highest Band", color=color.new(DnC, 35), linewidth=1)
pHiM = plot(showBands ? bandHiM : na, "Upper Band", color=color.new(DnC, 65), linewidth=1)
pLoM = plot(showBands ? bandLoM : na, "Lower Band", color=color.new(UpC, 65), linewidth=1)
pLo  = plot(showBands ? bandLo  : na, "Lowest Band", color=color.new(UpC, 35), linewidth=1)

fill(pHi,  pHiM, bandHi,  bandHiM, color.new(DnC, 58), color.new(DnC, 91), title="Upper Outer Zone")
fill(pHiM, pC,   bandHiM, center,  color.new(DnC, 91), color.new(DnC, 99), title="Upper Inner Zone")
fill(pC,   pLoM, center,  bandLoM, color.new(UpC, 99), color.new(UpC, 91), title="Lower Inner Zone")
fill(pLoM, pLo,  bandLoM, bandLo,  color.new(UpC, 91), color.new(UpC, 58), title="Lower Outer Zone")

plotshape(showSignals and flipUp, "Buy Signal", style=shape.labelup, location=location.belowbar, color=UpC, text="𝓛𝓸𝓷𝓰", textcolor=#000000, size=size.small)
plotshape(showSignals and flipDown, "Sell Signal", style=shape.labeldown, location=location.abovebar, color=DnC, text="𝓢𝓱𝓸𝓻𝓽", textcolor=#000000, size=size.small)

plotcandle(open, high, low, close, "Candle Plot", candleColor ? gradCol : na, candleColor ? gradCol : na, true, bordercolor=candleColor ? gradCol : na, display=display.pane, force_overlay=true)

// ╔══════════════════════════════════════════════════╗
// ║                    ALERTS                        ║
// ╚══════════════════════════════════════════════════╝
alertcondition(flipUp, "Bullish Signal", "Gravity Well | Lyro RS: Bullish signal on {{ticker}} ({{interval}})")
alertcondition(flipDown, "Bearish Signal", "Gravity Well | Lyro RS: Bearish signal on {{ticker}} ({{interval}})")
alertcondition(flipUp or flipDown, "Any Signal", "Gravity Well | Lyro RS: Signal flip on {{ticker}} ({{interval}})")
````
