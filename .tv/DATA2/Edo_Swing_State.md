<!-- tradingview-pine-id: PUB;f83895d9a3e54d5d920cacc7f1520529 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Edo Swing State

Source: https://www.tradingview.com/script/kwfAZ2LL-Edo-Swing-State/

## Description

Edo Swing State — Labels Every Swing as HH, HL, LH or LL and Resolves Market Structure into a Single State

[image]https://www.tradingview.com/x/V9716dR1/[/image]

[image]https://www.tradingview.com/x/kdg8Xthh/[/image]

[image]https://www.tradingview.com/x/O88g4yjB/[/image]

Market structure is the skeleton beneath almost every method of technical analysis: an uptrend is a run of higher highs and higher lows, a downtrend a run of lower highs and lower lows, and the moment that sequence breaks is the moment a trend starts to change. Edo Swing State makes that skeleton explicit. It detects each price swing, labels it with its structural role — higher high (HH), higher low (HL), lower high (LH) or lower low (LL) — and combines the last high and last low into one readable market state.

It draws a swing line that connects the confirmed pivots, marks each swing with a coloured HH/HL/LH/LL label, and reads the whole into Bullish, Bearish or Ranging in a compact panel — all validated on closed bars so the indicator does not repaint. It is a self-contained structure reader: the swings, their roles and the resulting state are all derived from the price series on the chart alone, with no dependency on any other tool.

THE HH / HL / LH / LL CLASSIFICATION

The indicator compares each new swing with the previous one of the same type. A swing high above the previous high is a Higher High (HH); below it, a Lower High (LH). A swing low above the previous low is a Higher Low (HL); below it, a Lower Low (LL). Each label is written at the pivot and does not move. Rising highs and rising lows are the signature of buying strength; falling highs and falling lows, the signature of weakness. High labels are drawn above the swing, low labels below it, colour-coded green for the bullish roles and red for the bearish ones.

SWING PROFILES

The sensitivity of the swings is set by a single Swing Profile input: Scalper (5 bars each side) for fast intraday swings on low timeframes, Swing (10 bars, the default) for the balanced 4H and daily read, and Long Term (21 bars) for the major swings on weekly and higher horizons. The larger the length, the more significant a turn has to be, and the fewer but more important the swings that are marked.

THE MARKET STATE

Above the individual labels, Edo Swing State resolves one overall state by combining the role of the last high with that of the last low. Bullish requires a last high of HH and a last low of HL — rising highs and lows. Bearish requires a last high of LH and a last low of LL — falling highs and lows. Any mixed combination is treated as Ranging. Requiring both sides to agree is deliberate: if price makes a higher high but then loses the previous low, the structure is no longer cleanly bullish, and the state turns to Ranging — precisely the transition zone where a trend starts to fail before the full turn is confirmed. The first LH after a run of HHs, or the first HL after a run of LLs, is the earliest crack in a trend, labelled the moment it is confirmed.

THE SWING LINE

The swing line connects the confirmed pivots in a continuous zigzag, tracing only the legs that run from one swing to the next and filtering out the intermediate noise. It reveals the real skeleton of the move — where price accelerates and where it loses momentum. The line and the labels can each be toggled independently, for a cleaner or a more informative chart.

INFORMATION PANEL

The panel condenses the read into a compact table under the indicator header: the overall market state (Bullish / Bearish / Ranging), the role of the most recent confirmed swing, and the role of the last high and the last low, in the same green/red colour code. The state row is the underlying read; the last-high and last-low rows explain why the state is what it is. The panel sits in any of the four chart corners (Top Right by default), comes in three sizes (Tiny / Small / Normal) and two themes (Dark / Light), and can be hidden entirely. To keep the calculation light, it is drawn only on the last bar.

NO REPAINTING

Swings are built on confirmed pivots and the state change is validated on closed bars, so a label never appears or disappears intrabar. There are no higher-timeframe functions: all logic runs on the current chart timeframe, which keeps the indicator lightweight and repaint-free. For a multi-timeframe read, apply it on several charts at once and look for the confluence of states.

CONFIGURATION

The inputs are grouped by block. Structure sets the swing profile and toggles the HH/HL/LH/LL labels and the swing line, listed in the settings as Show structure line (zigzag). Style exposes the bullish and bearish colours, the line colour and width, the label size and the Dark/Light theme. Panel controls panel visibility, position and size. The defaults are calibrated to work without adjustment on stocks, crypto, forex, indices and futures, on any timeframe — the input most users touch is the Swing Profile, to match the swings' sensitivity to their trading horizon.

ALERTS

Six predefined alerts cover the structure read. Four swing alerts — New Higher High, New Higher Low, New Lower High and New Lower Low — fire when each new pivot is confirmed with its role. Two structure alerts — Structure Bullish and Structure Bearish — fire only on the phase turn, when the overall state flips. All alerts fire on bar close, consistent with the indicator's anti-repaint validation.

HOW TO READ IT

Use the state as a context filter: look for longs while structure is Bullish and shorts while it is Bearish, and treat Ranging as caution — the zone where trends run out and false moves cluster. Use the change labels as an early warning: the first LH after a series of HHs, or the first HL after a series of LLs, flags a fading trend before the overall state fully turns. And read it in confluence: a Bullish state on the trading timeframe that sits inside a Bullish state on a higher one is a far more solid trend than an isolated read. Read on its own terms, the sequence of labels is the whole method: the roles say what the market is doing, and the state says whether it is doing it cleanly.

OPEN SOURCE

Edo Swing State is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem, all available on TradingView.

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
indicator("Edo Swing State", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ================== SETTINGS — STRUCTURE ==================

profile    = input.string("Swing", "Swing Profile", options = ["Scalper", "Swing", "Long Term"], group = "Structure", tooltip = "Scalper: fast swings (intraday)\nSwing: balanced (4H / D)\nLong Term: major swings only (W)")
showLabels = input.bool(true,  "Show HH / HL / LH / LL labels", group = "Structure")
showZig    = input.bool(true,  "Show structure line (zigzag)",  group = "Structure")

swingLen   = profile == "Scalper" ? 5 : profile == "Long Term" ? 21 : 10

// ================== SETTINGS — STYLE ==================

bullCol   = input.color(#26a69a, "Bullish", inline = "c1", group = "Style")
bearCol   = input.color(#ef5350, "Bearish", inline = "c1", group = "Style")
zigCol    = input.color(#787b86, "Structure line", group = "Style")
zigWidth  = input.int(1, "Line width", minval = 1, maxval = 3, group = "Style")
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

var float prevHigh = na   // last confirmed swing high value
var float prevLow  = na   // last confirmed swing low value

// ================== STRUCTURE STATE — HH / HL / LH / LL ==================

var string lastHighType = "—"   // "HH" or "LH"
var string lastLowType  = "—"   // "HL" or "LL"
var string lastSwing    = "—"   // most recent swing tag

newHH = false
newLH = false
newHL = false
newLL = false

// zigzag bookkeeping (updated inline — Pine forbids mutating globals inside functions)
var int   zzDir   = 0    // 1 = last anchored point is a high, -1 = a low
var float zzPrice = na
var int   zzBar   = na
var line  zzLine  = na

if not na(ph)
    bx = bar_index - swingLen
    isHH = na(prevHigh) or ph > prevHigh
    lastHighType := isHH ? "HH" : "LH"
    lastSwing    := lastHighType
    newHH := isHH
    newLH := not isHH
    if showLabels
        label.new(bx, ph, lastHighType, style = label.style_label_down, color = color.new(bullCol, 80), textcolor = bullCol, size = lblSizeTxt)
    // zigzag update for a high
    if zzDir == 0
        zzDir   := 1
        zzPrice := ph
        zzBar   := bx
    else if zzDir == 1
        if ph > zzPrice
            zzPrice := ph
            zzBar   := bx
            if showZig and not na(zzLine)
                line.set_xy2(zzLine, bx, ph)
    else
        if showZig
            zzLine := line.new(zzBar, zzPrice, bx, ph, color = color.new(zigCol, 0), width = zigWidth, style = line.style_solid)
        zzDir   := 1
        zzPrice := ph
        zzBar   := bx
    prevHigh := ph

if not na(pl)
    bx = bar_index - swingLen
    isLL = na(prevLow) or pl < prevLow
    lastLowType := isLL ? "LL" : "HL"
    lastSwing   := lastLowType
    newLL := isLL
    newHL := not isLL
    if showLabels
        label.new(bx, pl, lastLowType, style = label.style_label_up, color = color.new(bearCol, 80), textcolor = bearCol, size = lblSizeTxt)
    // zigzag update for a low
    if zzDir == 0
        zzDir   := -1
        zzPrice := pl
        zzBar   := bx
    else if zzDir == -1
        if pl < zzPrice
            zzPrice := pl
            zzBar   := bx
            if showZig and not na(zzLine)
                line.set_xy2(zzLine, bx, pl)
    else
        if showZig
            zzLine := line.new(zzBar, zzPrice, bx, pl, color = color.new(zigCol, 0), width = zigWidth, style = line.style_solid)
        zzDir   := -1
        zzPrice := pl
        zzBar   := bx
    prevLow := pl

// ================== MARKET STRUCTURE CLASSIFICATION ==================
// Bullish = higher highs AND higher lows. Bearish = lower highs AND lower lows.
// Anything else (mixed) is treated as Ranging / in transition.

structure = lastHighType == "HH" and lastLowType == "HL" ? 1 : lastHighType == "LH" and lastLowType == "LL" ? -1 : 0

var int prevStructure = 0
turnedBull = structure == 1 and prevStructure != 1
turnedBear = structure == -1 and prevStructure != -1
if barstate.isconfirmed
    prevStructure := structure

// ================== PANEL ==================

if showPanel and barstate.islast
    panelPosTV = switch panelPos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

    var table panel = table.new(panelPosTV, 2, 5, frame_color = isDark ? #363a45 : #b2b5be, frame_width = 1, border_color = isDark ? #434651 : #c8cbda, border_width = 1)

    structTxt = structure > 0 ? "▲ BULLISH" : structure < 0 ? "▼ BEARISH" : "• RANGING"
    structCol = structure > 0 ? bullCol : structure < 0 ? bearCol : cellTxt
    highCol   = lastHighType == "HH" ? bullCol : lastHighType == "LH" ? bearCol : cellTxt
    lowCol    = lastLowType == "HL"  ? bullCol : lastLowType == "LL"  ? bearCol : cellTxt
    swingCol  = lastSwing == "HH" or lastSwing == "HL" ? bullCol : lastSwing == "LH" or lastSwing == "LL" ? bearCol : cellTxt

    table.cell(panel, 0, 0, "EDO SWING STATE", text_color = textCol, bgcolor = headerBg, text_size = panSizeTxt)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Structure",  text_color = cellTxt,   bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 1, structTxt,    text_color = structCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 2, "Last Swing", text_color = cellTxt,  bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 2, lastSwing,    text_color = swingCol, bgcolor = subBg, text_size = panSizeTxt)

    table.cell(panel, 0, 3, "Last High",  text_color = cellTxt, bgcolor = cellBg, text_size = panSizeTxt)
    table.cell(panel, 1, 3, lastHighType, text_color = highCol, bgcolor = cellBg, text_size = panSizeTxt)

    table.cell(panel, 0, 4, "Last Low",   text_color = cellTxt, bgcolor = subBg, text_size = panSizeTxt)
    table.cell(panel, 1, 4, lastLowType,  text_color = lowCol,  bgcolor = subBg, text_size = panSizeTxt)

// ================== ALERTS ==================

alertcondition(newHH,      "New Higher High",   "Edo Swing State — New Higher High (HH) on {{ticker}}")
alertcondition(newHL,      "New Higher Low",    "Edo Swing State — New Higher Low (HL) on {{ticker}}")
alertcondition(newLH,      "New Lower High",    "Edo Swing State — New Lower High (LH) on {{ticker}}")
alertcondition(newLL,      "New Lower Low",     "Edo Swing State — New Lower Low (LL) on {{ticker}}")
alertcondition(turnedBull, "Structure Bullish", "Edo Swing State — Structure turned BULLISH on {{ticker}}")
alertcondition(turnedBear, "Structure Bearish", "Edo Swing State — Structure turned BEARISH on {{ticker}}")
````
