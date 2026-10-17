# Momentum Cascade | Lyro RS

- url: https://www.tradingview.com/script/gnAGO9QR-Momentum-Cascade-Lyro-RS/
- type: indicator
- pine_id: PUB;e6a18e57ddee49deb9398cf9830a0c87
- version: 1.0

## Description

[b]Overview:[/b]
Momentum Cascade is a rate-of-change momentum tool that passes a single momentum reading through three sequential smoothing stages to filter out early, unconfirmed moves. Rather than reacting to the first sign of a shift, it waits for the momentum signal to "cascade" through instant, reactive, and committed stages before confirming a trend, giving a cleaner read on when a move has genuine follow-through.

[b]Key Features[/b]
[list]
[*]Three-Stage Cascade Engine: Calculates a rate-of-change momentum value, then passes it through two successive EMA smoothing stages. Stage 1 is the raw instant impulse, Stage 2 is the first reactive smoothing, and Stage 3 is the fully committed signal.
[*]Trend Confirmation Score: Each stage contributes +1 or -1 depending on its direction. A trend only confirms when all three stages agree (score of +3 or -3), filtering out momentum blips that fade before they cascade through.
[*]Gradient Strength Visualization: The committed Stage 3 line and candle coloring use a gradient blend based on how strong the current agreement is across all three stages, giving an at-a-glance read on conviction.
[*]Multi-Layer Plotting: Displays all three cascade stages simultaneously (thin instant line, mid-weight reactive line, and a glow-effect committed line) so you can see momentum building in real time, not just the final confirmation.
[*]Candle Coloring: Optionally recolors chart candles using the same gradient logic as the oscillator, aligning price action visually with the cascade's current trend strength.
[*]Customizable Visuals: Choose from 4 preset palettes — Classic, Mystic, Accented, Royal — or define your own custom bullish/bearish colors.
[*]Built-In Signals: Automatically plots long/short labels on confirmed trend flips (when the score crosses into full +3 or -3 agreement).
[/list]

[b]How It Works[/b]
[list=1]
[*]Momentum Calculation – Computes rate-of-change of price over the chosen length as the raw momentum impulse (Stage 1).
[*]Cascade Smoothing – Passes that momentum through an EMA to produce Stage 2 (reactive), then smooths again to produce Stage 3 (committed).
[*]Scoring – Assigns +1/-1 per stage based on sign, summing to a score between -3 and +3.
[*]Trend Confirmation – A trend state only flips when the score reaches full agreement (+3 or -3), meaning all three stages point the same direction.
[*]Signal Plotting – Trend flips are marked with long/short labels, and candle/line coloring reflects both direction and agreement strength via gradient.
[/list]

[b]Practical Use[/b]
[list]
[*]Trend Confirmation – Use full cascade agreement (score of ±3) as confirmation that a momentum shift has enough follow-through to be tradeable, rather than acting on Stage 1 alone.
[*]Early Warning – Watch Stage 1 and Stage 2 for early signs of a potential shift before the full cascade confirms, useful for anticipating entries.
[*]Conviction Reading – Use the gradient strength on Stage 3 and candles to gauge how strongly the current trend is holding versus weakening.
[*]Combine with Structure – Pair cascade confirmations with support/resistance or market structure levels for higher-quality entries.
[/list]

[b]Customization[/b]
[list]
[*]Adjust Momentum Length and Stage Smoothing independently to tune responsiveness vs. lag.
[*]Toggle signal labels and candle coloring on/off.
[*]Pick a preset palette or define fully custom bullish/bearish colors.
[/list]

[b]⚠️Disclaimer[/b]
This indicator is a tool for technical analysis and does not provide guaranteed results. It should be used in conjunction with other analysis methods and proper risk management practices. The creators of this indicator are not responsible for any financial decisions made based on its signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LyroRS

//@version=6
indicator("Momentum Cascade | Lyro RS", overlay=false)

import LyroRS/LMAs/1 as DynamicMAs

// ╔══════════════════════════════════════════════════╗
// ║                INPUT GROUPS                      ║
// ╚══════════════════════════════════════════════════╝
settings_g = '𝗦𝗘𝗧𝗧𝗜𝗡𝗚𝗦'
features_g = '𝗙𝗘𝗔𝗧𝗨𝗥𝗘𝗦'
color_g    = '𝗖𝗢𝗟𝗢𝗥'

// ╔══════════════════════════════════════════════════╗
// ║               CORE SETTINGS                      ║
// ╚══════════════════════════════════════════════════╝
length = input.int(14, "𝗠𝗼𝗺𝗲𝗻𝘁𝘂𝗺 𝗟𝗲𝗻𝗴𝘁𝗵", minval=2, group=settings_g, tooltip="Rate-of-change length feeding the cascade.")
stage  = input.int(14, "𝗦𝘁𝗮𝗴𝗲 𝗦𝗺𝗼𝗼𝘁𝗵𝗶𝗻𝗴", minval=2, group=settings_g, tooltip="EMA length of each cascade stage. The same momentum is passed through three stages — instant, reactive, and committed. A trend requires all three to agree.")

// ╔══════════════════════════════════════════════════╗
// ║                 FEATURES                         ║
// ╚══════════════════════════════════════════════════╝
showSignals = input.bool(true, "𝗦𝗵𝗼𝘄 𝗦𝗶𝗴𝗻𝗮𝗹𝘀", group=features_g)
candleColor = input.bool(true, "𝗖𝗮𝗻𝗱𝗹𝗲 𝗖𝗼𝗹𝗼𝗿𝗶𝗻𝗴", group=features_g)

// ╔══════════════════════════════════════════════════╗
// ║                   COLOR                          ║
// ╚══════════════════════════════════════════════════╝
ColMode = input.string("Mystic", "Custom Color Palette", inline="drop", options=["Classic", "Mystic", "Accented", "Royal"], display=display.none, group=color_g)
cpyn   = input.bool(true, "Use Custom Palette", group=color_g, display=display.none)
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
// ║               CASCADE ENGINE                     ║
// ╚══════════════════════════════════════════════════╝
// One momentum, three reaction speeds. Stage 1 is the raw impulse,
// stage 2 is its first smoothing, stage 3 the second. Early in a
// move only stage 1 has turned; a real trend is when the turn has
// cascaded all the way down to stage 3.
m1 = ta.roc(close, length)
m2 = DynamicMAs.EMA(m1, stage)
m3 = DynamicMAs.EMA(m2, stage)

score = (m1 > 0 ? 1 : -1) + (m2 > 0 ? 1 : -1) + (m3 > 0 ? 1 : -1)

// ╔══════════════════════════════════════════════════╗
// ║                 TREND ENGINE                     ║
// ╚══════════════════════════════════════════════════╝
var int trend = 0
if score == 3
    trend := 1
else if score == -3
    trend := -1

flipUp   = trend == 1  and trend[1] != 1
flipDown = trend == -1 and trend[1] != -1

// ╔══════════════════════════════════════════════════╗
// ║                   VISUALS                        ║
// ╚══════════════════════════════════════════════════╝
trendCol = trend == 1 ? UpC : trend == -1 ? DnC : color.gray

strength = math.abs(score) / 3.0
gradCol  = color.from_gradient(strength, 0, 1, color.new(trendCol, 65), trendCol)

// Cascade stages — thin instant, mid reactive, committed with glow
plot(m1, "Stage 1 [Instant]", color=color.new(trendCol, 70), linewidth=1)
plot(m2, "Stage 2 [Reactive]", color=color.new(trendCol, 45), linewidth=1)
plot(m3, "Stage 3 [Glow]", color=color.new(trendCol, 78), linewidth=8, editable=false)
pMain = plot(m3, "Stage 3 [Committed]", color=gradCol, linewidth=2)
pZero = plot(0, "Zero Anchor", color=na, editable=false)
// fill(pMain, pZero, color=color.new(trendCol, 88 - math.round(15 * strength)), title="Cascade Fill")
fill(pMain, pZero, 0, m3, color.new(chart.bg_color, 45), color.new(trendCol, 35), editable=false)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)

plotshape(showSignals and flipUp, "Buy Signal", style=shape.labelup, location=location.belowbar, color=UpC, text="𝓛𝓸𝓷𝓰", textcolor=#000000, size=size.small, force_overlay=true, display=display.pane)
plotshape(showSignals and flipDown, "Sell Signal", style=shape.labeldown, location=location.abovebar, color=DnC, text="𝓢𝓱𝓸𝓻𝓽", textcolor=#000000, size=size.small, force_overlay=true, display=display.pane)

plotcandle(open, high, low, close, "Candle Plot", candleColor ? gradCol : na, candleColor ? gradCol : na, true, bordercolor=candleColor ? gradCol : na, display=display.pane, force_overlay=true)

// ╔══════════════════════════════════════════════════╗
// ║                    ALERTS                        ║
// ╚══════════════════════════════════════════════════╝
alertcondition(flipUp, "Bullish Trend Flip", "Cascade | Lyro RS: Bullish cascade complete on {{ticker}} ({{interval}})")
alertcondition(flipDown, "Bearish Trend Flip", "Cascade | Lyro RS: Bearish cascade complete on {{ticker}} ({{interval}})")
alertcondition(flipUp or flipDown, "Any Trend Flip", "Cascade | Lyro RS: Trend flip on {{ticker}} ({{interval}})")
````
