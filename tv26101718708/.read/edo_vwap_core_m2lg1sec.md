# Edo VWAP Core

- url: https://www.tradingview.com/script/m2lG1SEC-Edo-VWAP-Core/
- type: indicator
- pine_id: PUB;a2edbc698f25452c8ac7cf8eee858a11
- version: 1.0

## Description

Edo VWAP Core — Fair-Value Reading Built on Weekly and Monthly Anchored VWAP with Standard Deviation Bands, Premium/Discount States, Sigma Distance and Information Panel

[image]https://www.tradingview.com/x/FSAG7Nrg/[/image]

[image]https://www.tradingview.com/x/bxNoiQEv/[/image]


The volume-weighted average price is, within any given period, the closest thing to an asset's fair value: it is the price every participant has actually paid, weighted by the volume traded on each candle. Whoever buys well above it is paying a premium relative to the market as a whole; whoever buys below is getting a discount. The session VWAP captures only one day and resets too often to be useful for swing work; anchoring the calculation to a higher horizon turns that same idea into a stable reference for positioning.

Edo VWAP Core builds on that principle by anchoring the VWAP to two horizons at once — the current week and the current month — and framing each line with standard deviation bands. On its own, an anchored VWAP is just a line. With Edo VWAP Core, that line gains a premium/discount state classification, a sigma-distance reading, deviation bands that delimit the cheap and expensive zones, a translucent fill between price and VWAP that switches colour with the active state, and an information panel that condenses the whole quantitative reading. Five coordinated layers on a single overlay, designed to answer one question continuously: is price trading expensive or cheap relative to what the market has actually paid?

WEEKLY AND MONTHLY ANCHORED VWAP

The indicator draws two anchored VWAPs simultaneously. The weekly line resets at the start of each new week and accumulates, candle by candle, the volume-weighted typical price up to the current moment; it is the main operational reference, plotted in blue. The monthly line resets at the start of each new month and accumulates the volume of the entire current month, so it runs slower and more stable, plotted in orange and providing the higher-horizon context. Both are calculated internally with the close of each candle of the active timeframe, so they do not depend on higher-timeframe functions and do not repaint: once a candle closes, its contribution to the VWAP is fixed. The default typical price source is hlc3, the standard input for VWAP.

The relationship between the two lines describes the value structure of the asset. Weekly above monthly with price above both reads as premium with buying pressure dominant across both horizons; weekly below monthly with price below both reads as sustained discount; price caught between the two lines is a transition zone with no clear value bias between the week and the month.

STANDARD DEVIATION BANDS

Around each VWAP the indicator draws two pairs of volume-weighted standard deviation bands, calculated consistently with the VWAP itself: the ±1σ pair delimits the normal fluctuation zone, and the ±2σ pair delimits the extreme zone, where price is statistically very far from fair value. The bands are what turn the VWAP from a simple line into a measurable value scale — they quantify how expensive or cheap price is trading in terms of standard deviations. The area between +1σ and +2σ is shaded warm (the premium zone), the area between −1σ and −2σ is shaded cool (the discount zone), and the central ±1σ band carries a faint tone of the VWAP colour to mark the equilibrium region. Band widths reflect the volatility of the period: the wider the bands, the more volatile the move.

PREMIUM / DISCOUNT STATE CLASSIFICATION

The indicator classifies each bar into one of five exclusive states according to the position of the close relative to the reference VWAP and its bands. Premium Extreme: close above +2σ, upside overextension. Premium: close between +1σ and +2σ, price trading expensive. Neutral: close within ±1σ, fair value around the VWAP. Discount: close between −1σ and −2σ, price trading cheap. Discount Extreme: close below −2σ, downside overextension. The colour code follows the classic premium/discount logic — warm tones for the expensive zone, cool tones for the cheap zone — and the state is reflected simultaneously in the price-VWAP fill, in the panel and, optionally, in the chart background and the candle colouring. The panel accompanies the state with a bar counter showing how many consecutive candles price has spent in it; a high counter inside Premium Extreme or Discount Extreme signals a sustained overextension.

By default the state is calculated over the weekly VWAP as the reference. If the corresponding input is disabled, the state is computed over the monthly VWAP instead, and the panel header indicates which one is in use with a "W ref" or "M ref" label.

SIGMA DISTANCE AND PRICE-VWAP FILL

Sigma distance is the central quantitative measure: it expresses how many standard deviations separate the current close from the reference VWAP, computed as the close minus the reference VWAP divided by the reference standard deviation. A positive value means price is above the VWAP (premium), a negative one below (discount). Because it is normalised, it behaves like a z-score — a reading of +2σ means the same on one asset as on any other, regardless of absolute price — which lets the degree of overextension be compared homogeneously across instruments. Between price and the reference VWAP the indicator draws a translucent fill in the colour of the active state, warm in premium, cool in discount, neutral around fair value, so the value condition of the asset is legible at a glance without consulting the panel; its opacity is configurable.

INFORMATION PANEL

The panel condenses the whole reading into a compact three-column table. Its header shows the active reference VWAP. It displays the current State with its colour and consecutive-bar counter; the σ Dist reading in standard deviations; the weekly VWAP value with an up/down arrow depending on whether price is above or below it, plus its ±1σ and ±2σ band levels; and the same block for the monthly VWAP with its own bands. The panel can be placed in any of the four chart corners and resized to Small or Medium, with Dark and Light themes to blend with the chart background. It can also be hidden entirely.

CONFIGURATION

The inputs are grouped by functional block. The Anchors block toggles the weekly and monthly VWAP independently, sets the price source (hlc3 by default) and the line width. The Bands block enables the deviation bands, sets the inner and outer multipliers (1.0 and 2.0 by default), the fill opacity, and which VWAP drives the state classification (weekly by default). The State block governs the visual translation of the state — background colouring, background opacity, candle painting, the price-VWAP fill and its opacity. The Style block exposes the five state colours, the weekly and monthly line colours and the Dark/Light theme, and the Panel block controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures; the only parameter most users touch is the band multipliers when adapting the value scale to a particularly volatile asset.

ALERTS

Nine predefined alert conditions cover every meaningful event: Premium Extreme, Premium, Neutral, Discount and Discount Extreme fire when price enters the corresponding state; Cross Above VWAP and Cross Below VWAP fire when price crosses the reference VWAP; and New Weekly Anchor and New Monthly Anchor fire when a new period begins and the corresponding VWAP resets. The two extreme-state alerts are the most useful for detecting overextensions, the VWAP cross alerts warn of bias changes relative to fair value, and the anchor-reset alerts flag when the reference has refreshed and the context should be reassessed. State-change alerts are best configured on bar close.

HOW TO READ IT

A clean reading combines the layers into common patterns. Mean reversion from an extreme: price reaches Premium Extreme or Discount Extreme beyond ±2σ and the bar counter grows — moves that far from fair value statistically tend to correct back toward the VWAP, so any entry against that direction starts from a high-risk zone. VWAP as dynamic support or resistance: in healthy trends price drifts toward the premium or discount zone, pulls back to the reference VWAP and bounces without losing it, the line acting as dynamic support in an uptrend or resistance in a downtrend, with the fill making the pullbacks visible. Weekly-monthly confluence: when both VWAPs and their bands overlap in the same price zone, that region gains weight — a discount that coincides with the weekly −1σ and the monthly VWAP is a far more solid value zone than one touching a single reference. VWAP reclaim after discount: price trading cheap reclaims the reference VWAP with an impulse candle, the fill flips colour and the state shifts from Discount to Neutral, marking the moment the asset stops trading cheap and returns to fair value — a value-bias change that often accompanies bullish resumptions.

OPEN SOURCE

Edo VWAP Core is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo SuperTrend Core, Edo Multi Stoch, Edo Liquidity Zones, Edo Ichimoku State and more available on TradingView.

This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

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
indicator("Edo VWAP Core", overlay=true, max_labels_count=500)

// ================== INPUTS — ANCHORS ==================
showWeekly  = input.bool(true,  "Show Weekly Anchored VWAP",  group="Anchors")
showMonthly = input.bool(true,  "Show Monthly Anchored VWAP", group="Anchors")
vwapSrc     = input.source(hlc3, "Source", group="Anchors", tooltip="Typical price (hlc3) is the standard input for VWAP.")
lineWidth   = input.int(2, "Line Width", minval=1, maxval=4, group="Anchors")

// ================== INPUTS — BANDS ==================
showBands     = input.bool(true,  "Show σ Bands", group="Bands")
bandMult1     = input.float(1.0,  "Band 1 (σ)",  step=0.25, minval=0.25, group="Bands")
bandMult2     = input.float(2.0,  "Band 2 (σ)",  step=0.25, minval=0.25, group="Bands", tooltip="Outer band — extreme premium/discount zone.")
bandOpacity   = input.int(88, "Band Fill Opacity", minval=60, maxval=99, group="Bands")
useWeeklyState = input.bool(true, "Use Weekly VWAP for State Classification", group="Bands", tooltip="Otherwise the Monthly VWAP drives the state.")

// ================== INPUTS — STATE ==================
showBackground = input.bool(false, "Color Background by State", group="State")
bgOpacity      = input.int(92, "Background Opacity", minval=70, maxval=98, group="State")
paintCandles   = input.bool(false, "Paint Candles by State",   group="State")
showFill       = input.bool(true,  "Fill Between Price and VWAP", group="State")
fillOpacity    = input.int(90, "Fill Opacity", minval=60, maxval=99, group="State")

// ================== INPUTS — STYLE ==================
colorPremiumX  = input.color(color.rgb(230, 70, 70),    "Premium Extreme", group="Style")
colorPremium   = input.color(color.rgb(240, 160, 140),  "Premium",         group="Style")
colorNeutral   = input.color(color.rgb(150, 150, 160),  "Neutral",         group="Style")
colorDiscount  = input.color(color.rgb(140, 220, 180),  "Discount",        group="Style")
colorDiscountX = input.color(color.rgb(0, 200, 110),    "Discount Extreme",group="Style")
colorWeekly    = input.color(color.rgb(41, 98, 255),    "Weekly VWAP",     group="Style")
colorMonthly   = input.color(color.rgb(255, 152, 0),    "Monthly VWAP",    group="Style")
themeMode      = input.string("Dark", "Theme", options=["Dark", "Light"], group="Style")

// ================== INPUTS — PANEL ==================
showPanel = input.bool(true, "Show Panel", group="Panel")
panelPos  = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Panel")
panelSize = input.string("Medium", "Panel Size", options=["Small", "Medium"], group="Panel")

// ================== THEME ==================
isDark        = themeMode == "Dark"
panelBg       = isDark ? color.new(#1A1A2E, 10)     : color.new(color.white, 5)
panelHeader   = isDark ? color.new(#2A2E39, 0)      : color.new(#D1D4DC, 0)
panelSubBg    = isDark ? color.new(#363A45, 0)      : color.new(#E0E3EB, 0)
panelText     = isDark ? color.new(color.white, 0)  : color.new(color.black, 0)
panelTextSub  = isDark ? color.new(color.white, 30) : color.new(color.black, 30)
panelBorder   = color.new(color.gray, 50)
panSize       = panelSize == "Small" ? size.tiny : size.small

// ================== ANCHORED VWAP CORE ==================
// Reset accumulators at start of each new period.
isNewWeek  = timeframe.change("W")
isNewMonth = timeframe.change("M")

var float wkPV    = 0.0
var float wkV     = 0.0
var float wkPV2   = 0.0
var float moPV    = 0.0
var float moV     = 0.0
var float moPV2   = 0.0

if isNewWeek
    wkPV  := 0.0
    wkV   := 0.0
    wkPV2 := 0.0
if isNewMonth
    moPV  := 0.0
    moV   := 0.0
    moPV2 := 0.0

vol = nz(volume, 0)
wkPV  := wkPV  + vwapSrc * vol
wkV   := wkV   + vol
wkPV2 := wkPV2 + vwapSrc * vwapSrc * vol
moPV  := moPV  + vwapSrc * vol
moV   := moV   + vol
moPV2 := moPV2 + vwapSrc * vwapSrc * vol

vwapWeekly  = wkV > 0 ? wkPV / wkV : na
vwapMonthly = moV > 0 ? moPV / moV : na

// Variance-based standard deviation (volume-weighted)
varWeekly  = wkV > 0 ? math.max(0.0, wkPV2 / wkV  - vwapWeekly  * vwapWeekly)  : 0.0
varMonthly = moV > 0 ? math.max(0.0, moPV2 / moV  - vwapMonthly * vwapMonthly) : 0.0
sdWeekly   = math.sqrt(varWeekly)
sdMonthly  = math.sqrt(varMonthly)

wkUp1 = vwapWeekly + sdWeekly * bandMult1
wkDn1 = vwapWeekly - sdWeekly * bandMult1
wkUp2 = vwapWeekly + sdWeekly * bandMult2
wkDn2 = vwapWeekly - sdWeekly * bandMult2

moUp1 = vwapMonthly + sdMonthly * bandMult1
moDn1 = vwapMonthly - sdMonthly * bandMult1
moUp2 = vwapMonthly + sdMonthly * bandMult2
moDn2 = vwapMonthly - sdMonthly * bandMult2

// ================== STATE CLASSIFICATION (5 states) ==================
// 4 = Premium Extreme   → close > Band 2 upper
// 3 = Premium           → close between Band 1 upper and Band 2 upper
// 2 = Neutral VWAP      → close between Band 1 lower and Band 1 upper
// 1 = Discount          → close between Band 2 lower and Band 1 lower
// 0 = Discount Extreme  → close < Band 2 lower
refVwap = useWeeklyState ? vwapWeekly  : vwapMonthly
refUp1  = useWeeklyState ? wkUp1       : moUp1
refDn1  = useWeeklyState ? wkDn1       : moDn1
refUp2  = useWeeklyState ? wkUp2       : moUp2
refDn2  = useWeeklyState ? wkDn2       : moDn2

state = na(refVwap) ? 2 :
       close > refUp2 ? 4 :
       close > refUp1 ? 3 :
       close < refDn2 ? 0 :
       close < refDn1 ? 1 : 2

stateColor = state == 4 ? colorPremiumX : state == 3 ? colorPremium : state == 2 ? colorNeutral : state == 1 ? colorDiscount : colorDiscountX
stateText  = state == 4 ? "Premium Extreme" : state == 3 ? "Premium" : state == 2 ? "Neutral VWAP" : state == 1 ? "Discount" : "Discount Extreme"

var int stateBars = 0
stateBars := state != state[1] ? 1 : stateBars + 1

// Deviation from VWAP in σ units
sdRef     = useWeeklyState ? sdWeekly : sdMonthly
sigmaDist = sdRef > 0 ? (close - refVwap) / sdRef : 0.0

// ================== PLOTS — VWAPS ==================
wkPlot = plot(showWeekly  ? vwapWeekly  : na, "Weekly VWAP",  color=color.new(colorWeekly,  0), linewidth=lineWidth)
moPlot = plot(showMonthly ? vwapMonthly : na, "Monthly VWAP", color=color.new(colorMonthly, 0), linewidth=lineWidth)

// ================== PLOTS — BANDS ==================
wkUp1Plot = plot(showBands and showWeekly ? wkUp1 : na, "Wk +1σ", color=color.new(colorWeekly, 60), linewidth=1)
wkDn1Plot = plot(showBands and showWeekly ? wkDn1 : na, "Wk -1σ", color=color.new(colorWeekly, 60), linewidth=1)
wkUp2Plot = plot(showBands and showWeekly ? wkUp2 : na, "Wk +2σ", color=color.new(colorWeekly, 40), linewidth=1)
wkDn2Plot = plot(showBands and showWeekly ? wkDn2 : na, "Wk -2σ", color=color.new(colorWeekly, 40), linewidth=1)
fill(wkUp1Plot, wkDn1Plot, color=showBands and showWeekly ? color.new(colorWeekly, bandOpacity) : na, title="Weekly σ1 Fill")
fill(wkUp2Plot, wkUp1Plot, color=showBands and showWeekly ? color.new(colorPremiumX,  bandOpacity + 4) : na, title="Weekly Premium Zone")
fill(wkDn1Plot, wkDn2Plot, color=showBands and showWeekly ? color.new(colorDiscountX, bandOpacity + 4) : na, title="Weekly Discount Zone")

moUp1Plot = plot(showBands and showMonthly ? moUp1 : na, "Mo +1σ", color=color.new(colorMonthly, 60), linewidth=1)
moDn1Plot = plot(showBands and showMonthly ? moDn1 : na, "Mo -1σ", color=color.new(colorMonthly, 60), linewidth=1)
moUp2Plot = plot(showBands and showMonthly ? moUp2 : na, "Mo +2σ", color=color.new(colorMonthly, 40), linewidth=1)
moDn2Plot = plot(showBands and showMonthly ? moDn2 : na, "Mo -2σ", color=color.new(colorMonthly, 40), linewidth=1)
fill(moUp1Plot, moDn1Plot, color=showBands and showMonthly ? color.new(colorMonthly,  bandOpacity)     : na, title="Monthly σ1 Fill")
fill(moUp2Plot, moUp1Plot, color=showBands and showMonthly ? color.new(colorPremiumX,  bandOpacity + 4) : na, title="Monthly Premium Zone")
fill(moDn1Plot, moDn2Plot, color=showBands and showMonthly ? color.new(colorDiscountX, bandOpacity + 4) : na, title="Monthly Discount Zone")

// ================== STATE VISUALS ==================
pricePlot = plot(close, "Price (hidden)", display=display.none)
refPlot   = plot(showFill ? refVwap : na, "Ref VWAP (hidden)", display=display.none)
fill(pricePlot, refPlot, color=showFill ? color.new(stateColor, fillOpacity) : na, title="Price-VWAP Fill")

bgcolor(showBackground ? color.new(stateColor, bgOpacity) : na, title="State Background")
barcolor(paintCandles ? stateColor : na)

// ================== PANEL ==================
pos = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(pos, 3, 9, border_width=1, border_color=panelBorder, bgcolor=panelBg, frame_color=panelBorder)

sigSign = sigmaDist > 0 ? "+" : ""

if showPanel and barstate.islast
    table.cell(dash, 0, 0, "EDO VWAP CORE", text_color=panelText, text_size=panSize, bgcolor=panelHeader)
    table.cell(dash, 1, 0, "",              bgcolor=panelHeader)
    table.cell(dash, 2, 0, useWeeklyState ? "W ref" : "M ref", text_color=panelTextSub, text_size=panSize, bgcolor=panelHeader)

    table.cell(dash, 0, 1, "State",     text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 1, stateText,   text_color=stateColor, text_size=panSize)
    table.cell(dash, 2, 1, str.tostring(stateBars) + "b", text_color=panelTextSub, text_size=panSize)

    table.cell(dash, 0, 2, "σ Dist",    text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 2, sigSign + str.tostring(sigmaDist, "#.##") + "σ", text_color=stateColor, text_size=panSize)
    table.cell(dash, 2, 2, "",          text_size=panSize)

    table.cell(dash, 0, 3, "Wk VWAP",   text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 3, na(vwapWeekly) ? "—" : str.tostring(vwapWeekly, format.mintick), text_color=colorWeekly, text_size=panSize)
    table.cell(dash, 2, 3, na(vwapWeekly) ? "·" : close > vwapWeekly ? "↑" : close < vwapWeekly ? "↓" : "·", text_color=na(vwapWeekly) ? panelTextSub : close > vwapWeekly ? colorDiscountX : colorPremiumX, text_size=panSize)

    table.cell(dash, 0, 4, "Wk ±1σ",    text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 4, na(wkDn1) ? "—" : str.tostring(wkDn1, format.mintick) + " / " + str.tostring(wkUp1, format.mintick), text_color=panelText, text_size=panSize)
    table.cell(dash, 2, 4, "",          text_size=panSize)

    table.cell(dash, 0, 5, "Wk ±2σ",    text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 5, na(wkDn2) ? "—" : str.tostring(wkDn2, format.mintick) + " / " + str.tostring(wkUp2, format.mintick), text_color=panelText, text_size=panSize)
    table.cell(dash, 2, 5, "",          text_size=panSize)

    table.cell(dash, 0, 6, "Mo VWAP",   text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 6, na(vwapMonthly) ? "—" : str.tostring(vwapMonthly, format.mintick), text_color=colorMonthly, text_size=panSize)
    table.cell(dash, 2, 6, na(vwapMonthly) ? "·" : close > vwapMonthly ? "↑" : close < vwapMonthly ? "↓" : "·", text_color=na(vwapMonthly) ? panelTextSub : close > vwapMonthly ? colorDiscountX : colorPremiumX, text_size=panSize)

    table.cell(dash, 0, 7, "Mo ±1σ",    text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 7, na(moDn1) ? "—" : str.tostring(moDn1, format.mintick) + " / " + str.tostring(moUp1, format.mintick), text_color=panelText, text_size=panSize)
    table.cell(dash, 2, 7, "",          text_size=panSize)

    table.cell(dash, 0, 8, "Mo ±2σ",    text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 8, na(moDn2) ? "—" : str.tostring(moDn2, format.mintick) + " / " + str.tostring(moUp2, format.mintick), text_color=panelText, text_size=panSize)
    table.cell(dash, 2, 8, "",          text_size=panSize)

// ================== ALERTS ==================
toPremiumX  = state == 4 and state[1] != 4
toPremium   = state == 3 and state[1] != 3
toNeutral   = state == 2 and state[1] != 2
toDiscount  = state == 1 and state[1] != 1
toDiscountX = state == 0 and state[1] != 0
crossVwapUp     = ta.crossover(close,  refVwap)
crossVwapDown   = ta.crossunder(close, refVwap)
weekReset       = isNewWeek
monthReset      = isNewMonth

alertcondition(toPremiumX,    "VWAP Core — Premium Extreme",   "Edo VWAP Core: Premium Extreme on {{ticker}} {{interval}}")
alertcondition(toPremium,     "VWAP Core — Premium",           "Edo VWAP Core: Premium on {{ticker}} {{interval}}")
alertcondition(toNeutral,     "VWAP Core — Neutral",           "Edo VWAP Core: back to Neutral VWAP on {{ticker}} {{interval}}")
alertcondition(toDiscount,    "VWAP Core — Discount",          "Edo VWAP Core: Discount on {{ticker}} {{interval}}")
alertcondition(toDiscountX,   "VWAP Core — Discount Extreme",  "Edo VWAP Core: Discount Extreme on {{ticker}} {{interval}}")
alertcondition(crossVwapUp,   "VWAP Core — Cross Above VWAP",  "Edo VWAP Core: price crossed above the reference VWAP on {{ticker}} {{interval}}")
alertcondition(crossVwapDown, "VWAP Core — Cross Below VWAP",  "Edo VWAP Core: price crossed below the reference VWAP on {{ticker}} {{interval}}")
alertcondition(weekReset,     "VWAP Core — New Weekly Anchor", "Edo VWAP Core: weekly VWAP reset on {{ticker}} {{interval}}")
alertcondition(monthReset,    "VWAP Core — New Monthly Anchor","Edo VWAP Core: monthly VWAP reset on {{ticker}} {{interval}}")
````
