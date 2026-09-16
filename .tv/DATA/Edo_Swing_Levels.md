<!-- tradingview-pine-id: PUB;ee0b827f080a4e0b983d134018398793 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Edo Swing Levels

Source: https://www.tradingview.com/script/hzyyjgAQ-Edo-Swing-Levels/

## Description

Edo Swing Levels — Tracks the Swing High and Low, Marks the Strong Level Defending the Trend and Flags the CHoCH When It Breaks

[image]https://www.tradingview.com/x/oFV8CsLL/[/image]

[image]https://www.tradingview.com/x/xTiByBBy/[/image]

[image]https://www.tradingview.com/x/47bL7DHU/[/image]

At any moment, market structure comes down to two prices: the last swing high and the last swing low. But they are not equal. One of them is the level that defends the current trend —the one a trader watches to know whether the trend continues or breaks— and the other is only a matter of time before it is taken. Edo Swing Levels keeps both always in view and, crucially, tells them apart.

It marks the level defending the trend as Strong —a solid, marked line— and the other as Weak —a dashed, faded line. In an uptrend the swing low is Strong (the support that holds) and the high is Weak; in a downtrend the swing high is Strong (the cap that holds) and the low is Weak. When price closes through the Strong level, a change of character (CHoCH) occurs: the structure that held the trend up breaks, the bias flips and the roles swap. Everything is validated on closed bars, so it does not repaint. The strong and weak levels, their roles and the change of character are all resolved on the chart's own series, with nothing else required.

STRONG AND WEAK LEVELS

The indicator keeps the last confirmed swing high and swing low, and classifies them by the bias. In a bullish bias, the low is the Strong level and the high is Weak. In a bearish bias, the high is Strong and the low is Weak. The Strong level is drawn solid, thicker and at full opacity; the Weak level is dashed, thinner and faded. Each line carries a label —Strong High, Weak High, Strong Low or Weak Low— and both are projected to the right by a configurable number of bars so they sit ahead of price as live references. The high level is red and the low level teal by default, with a neutral gray until a trend is defined.

SWING PROFILES

The sensitivity of the levels is set by the Swing Profile: Scalper (5 bars each side) for fast intraday levels on low timeframes, Swing (10 bars, the default) for the balanced 4H and daily read, and Long Term (21 bars) for the major levels on weekly and higher horizons. The larger the length, the more significant a turn has to be, and the more important and spaced out the marked levels are.

BIAS AND CHoCH

The bias is inferred from the breaks of structure and is what decides which level is Strong and which Weak. A close above the last swing high turns the bias bullish; a close below the last swing low turns it bearish. The decisive event is the change of character: when price closes through the Strong level —below the Strong Low in an uptrend, or above the Strong High in a downtrend— the trend that the level defended breaks, the bias flips and the strong level becomes weak. Taking out the Weak level, by contrast, is a simple continuation that confirms the trend without changing it. The solid/dashed distinction separates, at a glance, the decisive level from the one that is a mere target.

INFORMATION PANEL

A compact panel under the indicator header shows the market bias (Bullish / Bearish / Neutral) and, for the high and the low, their exact price and whether each is the Strong or Weak level, in the same red/teal color code. The bias row gives the direction; the High and Low rows give the prices and, above all, which of the two is the Strong level to watch. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely. To keep the calculation light, it is drawn only on the last bar.

NO REPAINTING

Levels are built on confirmed pivots and breaks are validated on closed bars, so a level never appears or disappears intrabar and a wick that pierces a level but closes back on the same side does not count as a break. There are no higher-timeframe functions: all logic runs on the current chart timeframe. For a multi-timeframe read, apply it on several charts at once.

CONFIGURATION

The inputs are grouped by block. Structure sets the swing profile and how many bars the levels are projected to the right. Style exposes the high-level and low-level colors, the neutral color, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the input most users touch is the Swing Profile, to set the sensitivity of the levels to their trading horizon.

ALERTS

Four predefined alerts cover the structure read. Strong High taken and Strong Low taken fire on the change of character —when price closes through the Strong level and the trend turns— and are the context alerts. New swing high and New swing low fire when a new level is fixed. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

Take the Strong level as your invalidation line: while price respects it, trading with the bias has the wind at its back, and its close-through is the signal that the trend has broken. Take the Weak level as your target: in an uptrend price tends to go for the weak high, in a downtrend for the weak low, and the distance between the two levels gives the room available inside the current structure. And treat the taking of the Strong level as the cleanest turn warning —it often marks the start of a new leg in the opposite direction. Pairing it with the HH/HL/LH/LL sequence classification reinforces the read.

OPEN SOURCE

Edo Swing Levels is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem, all available on TradingView.

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
indicator("Edo Swing Levels", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ================== SETTINGS — STRUCTURE ==================

profile  = input.string("Swing", "Swing Profile", options = ["Scalper", "Swing", "Long Term"], group = "Structure", tooltip = "Scalper: fast swings (intraday)\nSwing: balanced (4H / D)\nLong Term: major swings only (W)")
extendR  = input.int(12, "Extend levels (bars)", minval = 0, maxval = 100, group = "Structure", tooltip = "How far to project the active Strong/Weak levels to the right.")

swingLen = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

highCol   = input.color(#ef5350, "High level", inline = "c1", group = "Style")
lowCol    = input.color(#26a69a, "Low level",  inline = "c1", group = "Style")
neutCol   = input.color(#787b86, "Neutral",    group = "Style")
labelSize = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = "Style")
themeMode = input.string("Dark",  "Theme Mode", options = ["Dark", "Light"], group = "Style", tooltip = "Match your TradingView background theme.")

// ================== SETTINGS — PANEL ==================

showPanel = input.bool(true, "Show Panel", group = "Panel")
panelPos  = input.string("Top Right", "Panel Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Panel")
panelSize = input.string("Small", "Panel Size", options = ["Tiny", "Small", "Normal"], group = "Panel")

// ================== THEME ==================

isDark   = themeMode == "Dark"
textCol  = isDark ? #ffffff : #131722
headerBg = isDark ? #2a2e39 : #d1d4dc
subBg    = isDark ? #363a45 : #e0e3eb
cellBg   = isDark ? #1e222d : #f0f3fa
cellTxt  = isDark ? #d1d4dc : #363a45

lblSizeTxt = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : size.small
panSizeTxt = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : size.small

// ================== SWING DETECTION ==================

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float upperLevel  = na   // last confirmed swing high (resistance)
var int   upperBar    = na
var float lowerLevel  = na   // last confirmed swing low  (support)
var int   lowerBar    = na
var bool  upperBroken = false
var bool  lowerBroken = false

newHigh = false
newLow  = false

if not na(ph)
    upperLevel  := ph
    upperBar    := bar_index - swingLen
    upperBroken := false
    newHigh     := true

if not na(pl)
    lowerLevel  := pl
    lowerBar    := bar_index - swingLen
    lowerBroken := false
    newLow      := true

// ================== MARKET STRUCTURE — trend via break of structure ==================
// A Strong level is the one defending the current trend; breaking it flips the trend (CHoCH)
// and the level becomes Weak (taken). Breaks validated on closed bars to avoid repainting.

var int trend = 0   // 1 = bullish, -1 = bearish

bullBreak = barstate.isconfirmed and not na(upperLevel) and not upperBroken and close > upperLevel
bearBreak = barstate.isconfirmed and not na(lowerLevel) and not lowerBroken and close < lowerLevel

strongHighTaken = false
strongLowTaken  = false

if bullBreak
    strongHighTaken := trend < 0   // breaking the defended high in a bearish trend = CHoCH up
    trend       := 1
    upperBroken := true

if bearBreak
    strongLowTaken := trend > 0    // breaking the defended low in a bullish trend = CHoCH down
    trend       := -1
    lowerBroken := true

// ================== DYNAMIC STRONG / WEAK LEVELS ==================
// Bullish trend  -> Low is Strong (support that holds), High is Weak (will be taken).
// Bearish trend  -> High is Strong (cap that holds),    Low is Weak.

var line  hiLine = na
var label hiLbl  = na
var line  loLine = na
var label loLbl  = na

if barstate.islast
    rightX = bar_index + extendR

    // ---- HIGH level ----
    if not na(upperLevel)
        hiStrong = trend < 0
        hiTxt = trend < 0 ? "Strong High" : trend > 0 ? "Weak High" : "High"
        hiC   = trend == 0 ? neutCol : highCol
        hiOp  = hiStrong ? 0 : 45
        hiW   = hiStrong ? 2 : 1
        hiSty = hiStrong ? line.style_solid : line.style_dashed
        if na(hiLine)
            hiLine := line.new(upperBar, upperLevel, rightX, upperLevel, color = color.new(hiC, hiOp), width = hiW, style = hiSty)
            hiLbl  := label.new(rightX, upperLevel, hiTxt, style = label.style_label_left, color = color.new(hiC, 85), textcolor = hiC, size = lblSizeTxt)
        else
            line.set_xy1(hiLine, upperBar, upperLevel)
            line.set_xy2(hiLine, rightX, upperLevel)
            line.set_color(hiLine, color.new(hiC, hiOp))
            line.set_width(hiLine, hiW)
            line.set_style(hiLine, hiSty)
            label.set_xy(hiLbl, rightX, upperLevel)
            label.set_text(hiLbl, hiTxt)
            label.set_textcolor(hiLbl, hiC)
            label.set_color(hiLbl, color.new(hiC, 85))

    // ---- LOW level ----
    if not na(lowerLevel)
        loStrong = trend > 0
        loTxt = trend > 0 ? "Strong Low" : trend < 0 ? "Weak Low" : "Low"
        loC   = trend == 0 ? neutCol : lowCol
        loOp  = loStrong ? 0 : 45
        loW   = loStrong ? 2 : 1
        loSty = loStrong ? line.style_solid : line.style_dashed
        if na(loLine)
            loLine := line.new(lowerBar, lowerLevel, rightX, lowerLevel, color = color.new(loC, loOp), width = loW, style = loSty)
            loLbl  := label.new(rightX, lowerLevel, loTxt, style = label.style_label_left, color = color.new(loC, 85), textcolor = loC, size = lblSizeTxt)
        else
            line.set_xy1(loLine, lowerBar, lowerLevel)
            line.set_xy2(loLine, rightX, lowerLevel)
            line.set_color(loLine, color.new(loC, loOp))
            line.set_width(loLine, loW)
            line.set_style(loLine, loSty)
            label.set_xy(loLbl, rightX, lowerLevel)
            label.set_text(loLbl, loTxt)
            label.set_textcolor(loLbl, loC)
            label.set_color(loLbl, color.new(loC, 85))

// ================== PANEL ==================

if showPanel and barstate.islast
    panelPosTV = switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    var table panel = table.new(panelPosTV, 2, 4, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    biasTxt = trend > 0 ? "▲ BULLISH" : trend < 0 ? "▼ BEARISH" : "• NEUTRAL"
    biasCol = trend > 0 ? lowCol : trend < 0 ? highCol : cellTxt
    hiTag   = trend < 0 ? "Strong" : trend > 0 ? "Weak" : "—"
    loTag   = trend > 0 ? "Strong" : trend < 0 ? "Weak" : "—"
    hiVal   = na(upperLevel) ? "—" : str.tostring(upperLevel, format.mintick) + "  (" + hiTag + ")"
    loVal   = na(lowerLevel) ? "—" : str.tostring(lowerLevel, format.mintick) + "  (" + loTag + ")"

    table.cell(panel, 0, 0, "EDO SWING LEVELS", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Bias", text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, biasTxt, text_color = biasCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "High", text_color = color.new(highCol, 0), bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, hiVal,  text_color = color.new(highCol, 0), bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Low", text_color = color.new(lowCol, 0), bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, loVal, text_color = color.new(lowCol, 0), bgcolor = cellBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(strongHighTaken, "Strong High taken", "Edo Swing Levels — Strong High taken (CHoCH up) on {{ticker}}")
alertcondition(strongLowTaken,  "Strong Low taken",  "Edo Swing Levels — Strong Low taken (CHoCH down) on {{ticker}}")
alertcondition(newHigh,         "New swing high",    "Edo Swing Levels — New swing high formed on {{ticker}}")
alertcondition(newLow,          "New swing low",     "Edo Swing Levels — New swing low formed on {{ticker}}")
````
