# Edo EMA Core Cross

- url: https://www.tradingview.com/script/PBg6tQaY-Edo-EMA-Core-Cross/
- type: indicator
- pine_id: PUB;09ed28ab6d64455fa8c61ec01b4e47be
- version: 1.0

## Description

Edo EMA Core Cross — Five-EMA Structure with a Three-Tier Cross Hierarchy and Weight-Scaled Markers (Momentum, Structure and Golden/Death Cross)

The exponential moving average (EMA) is one of the most basic elements of technical analysis: a dynamic equilibrium level that weights recent price more heavily. When a fast EMA crosses a slow one, that cross marks a change in the rhythm of the market, and it is one of the oldest and most reliable readings there is. The problem is not the EMA itself, but the handling: plotting five EMAs on the chart, watching by hand which pair has just crossed and remembering how much structural weight each cross carries is noisy, slow and error-prone, especially when what matters is not that there is a cross, but what kind of cross it is.

Edo EMA Core Cross was built to solve that. It does not reinvent the EMA: it organizes five key EMAs into a three-tier cross hierarchy and marks each cross with a visual weight proportional to its structural importance, so the trader tells apart at a glance short-term noise, operating rotation and a larger structural change.

This indicator does not predict price nor generate automatic signals: it visualizes transitions that are already happening so the trader can align with them.

WHAT THE INDICATOR DOES

The indicator plots five EMAs and monitors three cross pairs, assigning each pair a distinct hierarchical level. The five EMAs —9, 20, 50, 100 and 200— represent five speeds of the market, from immediate momentum, read by the 9, to the dominant structural bias, read by the 200. Conceptually, each EMA acts as a dynamic equilibrium level: when a faster EMA crosses above a slower one it signals growing bullish pressure, and when it crosses below, growing bearish pressure. What Edo EMA Core Cross adds is classifying those crosses into three hierarchies according to which averages are involved, because not all crosses carry the same weight.

THE FIVE EMAs

The five averages form a hierarchy of speeds. The EMA 9 reads immediate momentum; the EMA 20, the short term; the EMA 50, intermediate structure; the EMA 100, background structure; and the EMA 200, the dominant structural bias. Plotted together, they let you read the market as a hierarchical system where short-term moves develop inside larger structural layers. The thickness of each line grows with its weight —the 200 is the thickest— to reinforce the hierarchy visually.

THE HIERARCHICAL CROSS SYSTEM

It is the core of the indicator. Each cross pair is marked with a visual weight proportional to its structural relevance. The cross of the EMA 9 with the EMA 20 corresponds to momentum: fast changes and internal transitions within the prevailing structure, flagged with a small marker. The cross of the EMA 20 with the EMA 50 corresponds to structure: deeper operating rotations and possible mid-structure transitions, with a medium marker. The cross of the EMA 50 with the EMA 200 is the Golden Cross or Death Cross, the heaviest event, the classic structural cross that marks a long-term bias change, with a large marker set apart by its macro importance. This gradation is what turns a pile of EMAs into a structured reading: the size of the marker tells you, without measuring anything, whether what just happened is short-term noise, an operating rotation or a larger structural turn.

MARKERS AND LABELS

Each cross is flagged with an X-marker —below the candle if bullish, above if bearish— and with a readable label that identifies the pair and the direction, for example "9 ↑ 20" for a bullish cross of the 9 over the 20 or "50 ↓ 200" for a Death Cross. Each cross hierarchy can be toggled independently, so the trader can keep only the levels of interest, for example hiding the 9/20 noise and watching only the Golden and Death Cross.

ALERTS

Edo EMA Core Cross includes six alert conditions configurable from the standard TradingView alerts dialog, one bullish and one bearish for each of the three cross hierarchies. In the momentum hierarchy, the bullish alert fires when the 9 crosses above the 20 and the bearish one when it crosses below. In the structure hierarchy, when the 20 crosses above or below the 50. And in the major hierarchy, the Golden Cross when the 50 crosses above the 200 and the Death Cross when it crosses below. The alerts are independent of the visual toggles: they fire even if the corresponding hierarchy is hidden on the chart, so the trader can keep the chart clean and still receive the warning for the level of interest.

HOW TO READ IT

It is worth reading the hierarchy first: before reacting to a cross, look at its size, because a small 9/20 marker is momentum and a large 50/200 marker is structure, and the kind of cross matters more than the cross itself. Then align the speeds by checking the order of the EMAs: when they are stacked from fast to slow in bullish order, the 9 over the 20 over the 50 over the 200, the structure is clean, and when they interleave, the market is in transition. The Golden or Death Cross is contextualized: a 50/200 cross confirms a long-term bias change, but it is not an entry trigger, and it gains value when it coincides with structure and with relevant levels on the chart. Overall, the crosses are used as confirmation and not as anticipation: the indicator visualizes transitions that are already happening, and it serves to align with the structural change, not to front-run it blindly.

ORIGINALITY AND MASHUP JUSTIFICATION

EMAs are a public-domain component and this indicator does not pretend otherwise: it neither renames them nor presents them as something proprietary. The value is not in the averages, but in how they are coordinated. Plotting five EMAs by hand leaves the trader the task of identifying which pair crosses, remembering how much structural weight each pair carries and telling a momentum cross apart from a structural change, a manual, slow and error-prone job in real time. Edo EMA Core Cross solves that with one concrete design decision: ranking the crosses into three tiers and scaling the visual weight of each marker to its structural importance, so the three hierarchies —momentum with the 9/20, structure with the 20/50 and Golden or Death Cross with the 50/200— are read simultaneously and told apart at a glance. That visual coordination of the three hierarchies on a single clean overlay, and not the EMAs separately, is what the indicator contributes.

CONFIGURATION

Show EMA 9 / 20 Cross toggles the momentum hierarchy; Show EMA 20 / 50 Cross, the structure hierarchy; and Show EMA 50 / 200 Cross, the Golden and Death Cross. The colors and thicknesses of the EMAs are customized from the TradingView Style tab.

OPEN SOURCE

Edo EMA Core Cross is published as an open source and free indicator. The full Pine Script is publicly available on TradingView for study, adaptation and integration into any workflow.

This indicator is a technical analysis tool intended exclusively for educational and informational purposes. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading in financial markets carries a significant risk of capital loss. Past results do not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets
//@version=6
// v1.1 — Added alert conditions for the three cross hierarchies (9/20, 20/50, 50/200), both directions
indicator("Edo EMA Core Cross", overlay=true, max_labels_count=500)

// ================== EMAs ==================
ema9   = ta.ema(close, 9)
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

// ================== COLORS ==================
bullColor = color.lime
bearColor = color.rgb(255, 40, 40)

// ================== PLOTS (WITH TITLES) ==================
plot(ema9,   color=color.lime,   linewidth=1, title="EMA 9")
plot(ema20,  color=color.yellow, linewidth=1, title="EMA 20")
plot(ema50,  color=color.blue,   linewidth=2, title="EMA 50")
plot(ema100, color=color.purple, linewidth=2, title="EMA 100")
plot(ema200, color=color.red,    linewidth=3, title="EMA 200")

// ================== INPUTS ==================
show_9_20   = input.bool(true,  "Show EMA 9 / 20 Cross")
show_20_50  = input.bool(true,  "Show EMA 20 / 50 Cross")
show_50_200 = input.bool(true,  "Show EMA 50 / 200 Cross")

// ================== LOGIC ==================
// Crosses extracted to global vars so ta.* runs every bar (v6 short-circuit consistency)
xBull_9_20   = ta.crossover(ema9, ema20)
xBear_9_20   = ta.crossunder(ema9, ema20)
xBull_20_50  = ta.crossover(ema20, ema50)
xBear_20_50  = ta.crossunder(ema20, ema50)
xBull_50_200 = ta.crossover(ema50, ema200)
xBear_50_200 = ta.crossunder(ema50, ema200)

bull_9_20   = show_9_20   and xBull_9_20
bear_9_20   = show_9_20   and xBear_9_20

bull_20_50  = show_20_50  and xBull_20_50
bear_20_50  = show_20_50  and xBear_20_50

bull_50_200 = show_50_200 and xBull_50_200
bear_50_200 = show_50_200 and xBear_50_200

// ================== SHAPES ==================
plotshape(bull_9_20,   style=shape.xcross, location=location.belowbar, color=bullColor, size=size.small)
plotshape(bear_9_20,   style=shape.xcross, location=location.abovebar, color=bearColor, size=size.small)

plotshape(bull_20_50,  style=shape.xcross, location=location.belowbar, color=bullColor, size=size.normal)
plotshape(bear_20_50,  style=shape.xcross, location=location.abovebar, color=bearColor, size=size.normal)

plotshape(bull_50_200, style=shape.xcross, location=location.belowbar, color=bullColor, size=size.large)
plotshape(bear_50_200, style=shape.xcross, location=location.abovebar, color=bearColor, size=size.large)

// ================== LABELS (CONTROLLED) ==================
if bull_9_20
    label.new(bar_index, low, "9 ↑ 20", style=label.style_label_up, textcolor=bullColor, color=color.new(color.black, 100), size=size.normal)

if bear_9_20
    label.new(bar_index, high, "9 ↓ 20", style=label.style_label_down, textcolor=bearColor, color=color.new(color.black, 100), size=size.normal)

if bull_20_50
    label.new(bar_index, low, "20 ↑ 50", style=label.style_label_up, textcolor=bullColor, color=color.new(color.black, 100), size=size.large)

if bear_20_50
    label.new(bar_index, high, "20 ↓ 50", style=label.style_label_down, textcolor=bearColor, color=color.new(color.black, 100), size=size.large)

if bull_50_200
    label.new(bar_index, low, "50 ↑ 200", style=label.style_label_up, textcolor=bullColor, color=color.new(color.black, 100), size=size.large)

if bear_50_200
    label.new(bar_index, high, "50 ↓ 200", style=label.style_label_down, textcolor=bearColor, color=color.new(color.black, 100), size=size.large)

// ================== ALERTS ==================
// Alerts are independent from the visual toggles so they fire even when a hierarchy marker is hidden
alertcondition(xBull_9_20,   title="EMA 9/20 Bullish Cross (Momentum)",   message="Edo EMA Core Cross: EMA 9 crossed ABOVE EMA 20 - bullish momentum")
alertcondition(xBear_9_20,   title="EMA 9/20 Bearish Cross (Momentum)",   message="Edo EMA Core Cross: EMA 9 crossed BELOW EMA 20 - bearish momentum")
alertcondition(xBull_20_50,  title="EMA 20/50 Bullish Cross (Structure)", message="Edo EMA Core Cross: EMA 20 crossed ABOVE EMA 50 - bullish structure")
alertcondition(xBear_20_50,  title="EMA 20/50 Bearish Cross (Structure)", message="Edo EMA Core Cross: EMA 20 crossed BELOW EMA 50 - bearish structure")
alertcondition(xBull_50_200, title="EMA 50/200 Golden Cross",             message="Edo EMA Core Cross: EMA 50 crossed ABOVE EMA 200 - Golden Cross")
alertcondition(xBear_50_200, title="EMA 50/200 Death Cross",              message="Edo EMA Core Cross: EMA 50 crossed BELOW EMA 200 - Death Cross")
````
