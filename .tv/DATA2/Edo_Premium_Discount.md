<!-- tradingview-pine-id: PUB;e522f1f6b31b449193226110a4d77fe2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Edo Premium Discount

Source: https://www.tradingview.com/script/ZgbC7wJt-Edo-Premium-Discount/

## Description

Edo Premium Discount — Splits the Dealing Range into Premium, Equilibrium and Discount Zones with a Live Position Reading

[image]https://www.tradingview.com/x/KncJAu6v/[/image]

[image]https://www.tradingview.com/x/ZqoNgzUG/[/image]

[image]https://www.tradingview.com/x/uCO4RopC/[/image]

Inside the range price moves in, where you enter is not neutral. Buying near the low of the range — in discount — offers a far better risk/reward than buying near the high — in premium. Institutional money accumulates cheap and distributes expensive, and trading with that logic rather than against it is one of the simplest structural edges to add. Edo Premium Discount turns that principle into a direct visual tool: it takes the current dealing range and answers, at all times, one question — is price trading expensive or cheap relative to the range it sits in?

The indicator builds the dealing range from the latest confirmed swing high and swing low, splits it into three zones, and reads where price sits within it. Premium is the expensive upper half (the sell side), discount is the cheap lower half (the buy side), and equilibrium is the fair-value band around the 50% midpoint. Everything is built on confirmed swings, so the indicator does not repaint. It is the relative-value frame of the Edolab structure family, the canvas on which to place liquidity, order blocks and the rest of the read.

THE DEALING RANGE

The range is the foundation: without a reference high and low, there is no premium or discount to measure. The indicator defines it with the most recent confirmed pivots — the last swing high as the range high and the last swing low as the range low. When price breaks out and forms new swings, the range updates to the new leg. The Swing Profile sets the sensitivity of those pivots: Scalper (5 bars each side) for short, reactive ranges on low timeframes, Swing (10 bars, the default) for the balanced 4H and daily read, and Long Term (21 bars) for the major ranges on weekly and higher horizons. The zones extend a configurable number of bars to the right so they project over the forming candles.

THE THREE ZONES

Splitting the range at its midpoint, the indicator draws three zones. Premium: the upper portion, above the equilibrium band, shaded red — price is trading expensive, the zone where sells are sought. Discount: the lower portion, below the equilibrium band, shaded teal — price is trading cheap, the zone where buys are sought. Equilibrium: the central band around the exact 50% midpoint, shaded neutral grey, with a dashed line marking the 50% level — fair value, neutral territory where neither side has a clear location edge. The Equilibrium Band input sets the half-width of that central band as a percentage of the range (5% by default, giving a 45%–55% band); widen it to enlarge the neutral zone, narrow it to expand the two operative zones.

POSITION AND ZONE STATE

On every bar the indicator classifies the close into one of the three zones — Premium above the equilibrium band, Discount below it, Equilibrium inside it — and reads its Position: how high the close sits in the range as a percentage, where 0% is the range low, 100% the range high and 50% the midpoint. The percentage refines the zone read: premium at 55% (just across the midpoint) is a very different proposition from premium at 95% (at the edge of the range high). The state shows in the panel's Zone cell in its colour and fires the matching alert when price enters each zone.

INFORMATION PANEL

The panel condenses the value read into a compact table: the current Zone (PREMIUM / EQUILIBRIUM / DISCOUNT) in its colour, the Position in percent, and the Range High and Range Low levels. It sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely.

NO REPAINTING

The range is built on confirmed pivots: the range high and low only change when a new swing is confirmed, not during the forming candle, so the zones do not shift intrabar. There are no higher-timeframe functions — all logic runs on the current chart timeframe.

CONFIGURATION

The inputs are grouped by block. Range sets the swing profile, the equilibrium band as a percentage of the range and how many bars the zones extend to the right. Style exposes the premium, discount and equilibrium colours, the zone opacity and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the inputs most users touch are the Swing Profile, to size the range to their horizon, and the Equilibrium Band, to set the width of the neutral zone.

ALERTS

Three predefined alerts cover the zone changes: Price entered Premium fires when the close enters the premium zone, Price entered Discount when it enters the discount zone, and Price entered Equilibrium when it returns to the fair-value band. The discount alert flags when price reaches the cheap half of the range — where buys are sought — and the premium alert when it reaches the expensive half. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

The most direct use is location: seek buys when price is in discount and sells when it is in premium, not the other way around — not a signal in itself, but a filter that grades trades by their risk/reward, since a buy in deep discount starts from a far more favourable zone than a buy in premium. Watch the extremes: a Position near 0% or 100% means price is at an edge of the range, and inside a range price tends to revert toward equilibrium, so an extreme reading warns that pushing further from fair value starts from a high-risk zone. Use equilibrium as a hinge: price reclaiming equilibrium from discount, or losing it from premium, marks a change of value half worth watching. And trade in confluence: a liquidity sweep or a quality order block in discount is a far stronger buy reference than the same signal in premium — Edo Premium Discount provides the value frame on which to place the rest of the structure.

OPEN SOURCE

Edo Premium Discount is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem, all available on TradingView.

This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

---

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
indicator("Edo Premium Discount", overlay = true, max_boxes_count = 50, max_lines_count = 50, max_labels_count = 50)

// ================== SETTINGS — RANGE ==================

profile = input.string("Swing", "Swing Profile", options = ["Scalper", "Swing", "Long Term"], group = "Range", tooltip = "Sensitivity of the swings that define the dealing range.")
eqPct   = input.float(5.0, "Equilibrium Band (% of range)", minval = 0.0, maxval = 25.0, step = 1.0, group = "Range", tooltip = "Half-width of the equilibrium band around the 50% midpoint, as a % of the dealing range.")
extendR = input.int(10, "Extend Right (bars)", minval = 0, maxval = 100, group = "Range")

swingLen = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

premCol   = input.color(#ef5350, "Premium (sell zone)",  inline = "c1", group = "Style")
discCol   = input.color(#26a69a, "Discount (buy zone)",   inline = "c1", group = "Style")
eqCol     = input.color(#787b86, "Equilibrium", group = "Style")
fillOpac  = input.int(88, "Zone Opacity %", minval = 60, maxval = 97, step = 1, group = "Style")
themeMode = input.string("Dark",  "Theme Mode", options = ["Dark", "Light"], group = "Style", tooltip = "Match your TradingView background theme.")

// ================== SETTINGS — PANEL ==================

showPanel = input.bool(true, "Show Panel", group = "Panel")
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Panel")
panelSize = input.string("Small", "Panel Size", options = ["Tiny", "Small", "Normal"], group = "Panel")

// ================== THEME ==================

isDark   = themeMode == "Dark"
textCol  = isDark ? #ffffff : #131722
headerBg = isDark ? #2a2e39 : #d1d4dc
cellBg   = isDark ? #1e222d : #f0f3fa
cellTxt  = isDark ? #d1d4dc : #363a45

panSizeTxt = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : size.small

// ================== DEALING RANGE (from confirmed swings) ==================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float rangeHigh = na
var int   rangeHighBar = na
var float rangeLow  = na
var int   rangeLowBar = na

if not na(ph)
    rangeHigh    := ph
    rangeHighBar := bar_index - swingLen
if not na(pl)
    rangeLow    := pl
    rangeLowBar := bar_index - swingLen

// ================== ZONE OBJECTS ==================

var box  premBox = na
var box  discBox = na
var box  eqBox   = na
var line midLine = na

validRange = not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow

mid     = validRange ? (rangeHigh + rangeLow) / 2 : na
rng     = validRange ? rangeHigh - rangeLow : na
eqHalf  = validRange ? eqPct / 100.0 * rng : na
premBtm = validRange ? mid + eqHalf : na
discTop = validRange ? mid - eqHalf : na

if validRange
    xLeft  = math.min(rangeHighBar, rangeLowBar)
    xRight = bar_index + extendR

    if na(premBox)
        premBox := box.new(xLeft, rangeHigh, xRight, premBtm, border_color = color.new(premCol, 55), bgcolor = color.new(premCol, fillOpac), border_width = 1)
        discBox := box.new(xLeft, discTop,  xRight, rangeLow, border_color = color.new(discCol, 55), bgcolor = color.new(discCol, fillOpac), border_width = 1)
        eqBox   := box.new(xLeft, premBtm,  xRight, discTop,  border_color = color.new(eqCol, 70),  bgcolor = color.new(eqCol, math.min(fillOpac + 6, 97)), border_width = 1)
        midLine := line.new(xLeft, mid, xRight, mid, color = color.new(eqCol, 10), width = 1, style = line.style_dashed)
    else
        box.set_lefttop(premBox, xLeft, rangeHigh),  box.set_rightbottom(premBox, xRight, premBtm)
        box.set_lefttop(discBox, xLeft, discTop),    box.set_rightbottom(discBox, xRight, rangeLow)
        box.set_lefttop(eqBox,   xLeft, premBtm),    box.set_rightbottom(eqBox,   xRight, discTop)
        line.set_xy1(midLine, xLeft, mid),           line.set_xy2(midLine, xRight, mid)

// ================== ZONE STATE ==================

zoneId = validRange ? (close > premBtm ? 2 : close < discTop ? 0 : 1) : -1   // 2 premium, 1 equilibrium, 0 discount
posPct = validRange and rng != 0 ? (close - rangeLow) / rng * 100 : na

enterPrem = barstate.isconfirmed and zoneId == 2 and zoneId[1] != 2
enterDisc = barstate.isconfirmed and zoneId == 0 and zoneId[1] != 0
enterEq   = barstate.isconfirmed and zoneId == 1 and zoneId[1] != 1

// ================== PANEL ==================

if showPanel and barstate.islast
    panelPosTV = switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    var table panel = table.new(panelPosTV, 2, 5, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    zoneTxt = zoneId == 2 ? "PREMIUM" : zoneId == 1 ? "EQUILIBRIUM" : zoneId == 0 ? "DISCOUNT" : "—"
    zoneCol = zoneId == 2 ? premCol : zoneId == 1 ? eqCol : zoneId == 0 ? discCol : cellTxt
    posTxt  = na(posPct) ? "—" : str.tostring(posPct, "#.#") + "%"
    hiTxt   = na(rangeHigh) ? "—" : str.tostring(rangeHigh, format.mintick)
    loTxt   = na(rangeLow)  ? "—" : str.tostring(rangeLow, format.mintick)

    table.cell(panel, 0, 0, "EDO PREMIUM / DISCOUNT", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Zone",     text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, zoneTxt,    text_color = zoneCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Position", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, posTxt,     text_color = textCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Range High", text_color = color.new(premCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, hiTxt,        text_color = color.new(premCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Range Low",  text_color = color.new(discCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, loTxt,        text_color = color.new(discCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(enterPrem, "Price entered Premium",     "Edo Premium Discount — Price entered the PREMIUM zone on {{ticker}}")
alertcondition(enterDisc, "Price entered Discount",    "Edo Premium Discount — Price entered the DISCOUNT zone on {{ticker}}")
alertcondition(enterEq,   "Price entered Equilibrium", "Edo Premium Discount — Price entered the EQUILIBRIUM zone on {{ticker}}")
````
