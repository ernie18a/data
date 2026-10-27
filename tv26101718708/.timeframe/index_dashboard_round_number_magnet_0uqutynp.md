# INDEX Dashboard + Round Number Magnet

- url: https://www.tradingview.com/script/0uQUTYnp-INDEX-Dashboard-Round-Number-Magnet/
- type: indicator
- pine_id: PUB;adcbdb1efa66491c883dd828bdabe6b2
- version: 1.0

## Description

**INDEX Dashboard + Round Number Magnet**

A dual-purpose indicator that displays a real-time index dashboard and alerts you when price is approaching or pinning a key round number level.

**Dashboard**
Shows a 4x3 grid of the major US indices across Cash, Futures, and ETF categories — DowJones, S&P500, Nasdaq, and Russell 2000. Each cell is color-coded green/red based on the day's percentage change, with intensity scaling to the size of the move. The leading index in each row is marked with a ★. VIX is displayed in the top corner with color-coded risk levels (green below 15, orange below 20, red above).

**Round Number Magnet**
Active on SPX, SPY, QQQ, and US500.F only. Automatically detects the nearest round number level based on the instrument (25-point grid for SPX/ES, 5-point grid for SPY/QQQ) and draws a grid of levels above and below price. When price gets within the proximity threshold of a round number, a flashing banner appears at the top of the chart inside a table. If price stays near the level for several bars, it escalates to a PINNING alert — indicating dealers may be actively defending the strike.

**Alerts included**
- Approaching a round number
- PINNING detected at a round number

## Source Code

````pine
//@version=6
indicator("INDEX Dashboard + Round Number Magnet", overlay=true, max_lines_count=50)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
grpD = "Dashboard"
showTable = input.bool(true, "Show index table", group=grpD)
posStr    = input.string("Bottom Right", "Table position", options=["Bottom Right", "Top Right", "Bottom Left", "Top Left"], group=grpD)

grpR = "Round Number Magnet"
showMagnet = input.bool(true, "Show round number magnet", group=grpR)
incInput   = input.float(0, "Increment (0 = auto)", step=0.5, group=grpR, tooltip="Auto: SPX/ES=25, SPY/QQQ=5. Set manually to override.")
proxPts    = input.float(0.75, "Proximity threshold (points)", step=0.25, group=grpR)
pinBars    = input.int(5, "Bars near level = PINNING", minval=2, group=grpR)
levelsEach = input.int(3, "Grid levels above/below", minval=1, maxval=10, group=grpR)

f_pos(s) =>
    s == "Bottom Right" ? position.bottom_right :
     s == "Top Right"   ? position.top_right :
     s == "Bottom Left" ? position.bottom_left :
     position.top_left

// ─────────────────────────────────────────────
// Magnet symbol filter
// ─────────────────────────────────────────────
t = syminfo.ticker
magnetEnabled = showMagnet and (t == "SPX" or t == "SPY" or t == "QQQ" or t == "US500.F")

// ─────────────────────────────────────────────
// Blink state (toggles on every real-time tick)
// ─────────────────────────────────────────────
var bool blinkState = false
if barstate.isrealtime
    blinkState := not blinkState
blink = blinkState

// ─────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────
f_priceData(simple string sym) =>
    [c, pc] = request.security(sym, "D", [close, close[1]], lookahead=barmerge.lookahead_on)
    chg = (c - pc) / pc * 100
    [c, chg]

f_bgColor(chg) =>
    transp = int(math.max(10, 80 - math.abs(chg) * 40))
    chg > 0 ? color.new(color.green, transp) : chg < 0 ? color.new(color.red, transp) : color.new(color.gray, 80)

// ─────────────────────────────────────────────
// Symbols
// ─────────────────────────────────────────────
col_names  = array.from("DowJones", "S&P500", "Nasdaq", "Russell")
row_names  = array.from("Cash", "Futures", "ETF")
col_colors = array.from(color.blue, color.green, color.purple, color.orange)
row_colors = array.from(color.new(color.blue, 40), color.new(color.purple, 40), color.new(color.orange, 40))

[dji_p,  dji_c]  = f_priceData("DJI")
[spx_p,  spx_c]  = f_priceData("SPX")
[ixic_p, ixic_c] = f_priceData("IXIC")
[rut_p,  rut_c]  = f_priceData("RUT")

[dj30_p,  dj30_c]  = f_priceData("DJ30.F")
[us500_p, us500_c] = f_priceData("US500.F")
[ustec_p, ustec_c] = f_priceData("USTEC.F")
[us2k_p,  us2k_c]  = f_priceData("US2000USD")

[dia_p, dia_c] = f_priceData("DIA")
[spy_p, spy_c] = f_priceData("SPY")
[qqq_p, qqq_c] = f_priceData("QQQ")
[iwm_p, iwm_c] = f_priceData("IWM")

[vix_p, vix_c] = f_priceData("VIX")
vixColor = vix_p < 15 ? color.new(color.green, 20) : vix_p < 20 ? color.new(color.orange, 20) : color.new(color.red, 10)

// ─────────────────────────────────────────────
// Main table
// ─────────────────────────────────────────────
var table tbl = na
if barstate.isfirst
    tbl := table.new(f_pos(posStr), 5, 4, border_width=2)

f_cell(_tbl, col, row, p, chg, leader) =>
    cellText = (leader ? "★ " : "") + str.tostring(p, format.mintick)
    table.cell(_tbl, col, row, cellText,
         text_color = leader ? color.yellow : color.white,
         text_halign = text.align_center, text_size = size.normal,
         bgcolor = f_bgColor(chg),
         tooltip = str.tostring(chg, "#.##") + "%")

f_leader(a, b, c, d) =>
    m = math.max(a, math.max(b, math.max(c, d)))
    a == m ? 1 : b == m ? 2 : c == m ? 3 : 4

if barstate.islast and showTable
    table.cell(tbl, 0, 0, "VIX " + str.tostring(vix_p, "#.##"),
         text_color=color.white, text_halign=text.align_center, text_size=size.normal,
         bgcolor=vixColor, tooltip=str.tostring(vix_c, "#.##") + "%")

    for i = 0 to 3
        table.cell(tbl, i + 1, 0, array.get(col_names, i), text_color=color.white, bgcolor=array.get(col_colors, i), text_size=size.normal, text_halign=text.align_center)

    for row = 0 to 2
        table.cell(tbl, 0, row + 1, array.get(row_names, row), text_color=color.white, bgcolor=array.get(row_colors, row), text_size=size.normal, text_halign=text.align_center)

    cashLead = f_leader(dji_c, spx_c, ixic_c, rut_c)
    futLead  = f_leader(dj30_c, us500_c, ustec_c, us2k_c)
    etfLead  = f_leader(dia_c, spy_c, qqq_c, iwm_c)

    f_cell(tbl, 1, 1, dji_p,  dji_c,  cashLead == 1)
    f_cell(tbl, 2, 1, spx_p,  spx_c,  cashLead == 2)
    f_cell(tbl, 3, 1, ixic_p, ixic_c, cashLead == 3)
    f_cell(tbl, 4, 1, rut_p,  rut_c,  cashLead == 4)

    f_cell(tbl, 1, 2, dj30_p,  dj30_c,  futLead == 1)
    f_cell(tbl, 2, 2, us500_p, us500_c, futLead == 2)
    f_cell(tbl, 3, 2, ustec_p, ustec_c, futLead == 3)
    f_cell(tbl, 4, 2, us2k_p,  us2k_c,  futLead == 4)

    f_cell(tbl, 1, 3, dia_p, dia_c, etfLead == 1)
    f_cell(tbl, 2, 3, spy_p, spy_c, etfLead == 2)
    f_cell(tbl, 3, 3, qqq_p, qqq_c, etfLead == 3)
    f_cell(tbl, 4, 3, iwm_p, iwm_c, etfLead == 4)

// ─────────────────────────────────────────────
// Round Number Magnet
// ─────────────────────────────────────────────
r = syminfo.root

autoInc = r == "ES" or t == "SPX" ? 25.0 :
     t == "SPY" or t == "QQQ" or r == "NQ" or t == "IXIC" ? 5.0 :
     close >= 1000 ? 25.0 : close >= 100 ? 5.0 : 1.0
inc = incInput > 0 ? incInput : autoInc

nearest   = math.round(close / inc) * inc
dist      = math.abs(close - nearest)
nearLevel = dist <= proxPts and magnetEnabled

var int pinCount = 0
sameLevel = math.round(close[1] / inc) * inc == nearest
pinCount := nearLevel and sameLevel ? pinCount + 1 : nearLevel ? 1 : 0
isPinning = pinCount >= pinBars

var line[] lns = array.new<line>()
var label  lbl = na

if barstate.islast and magnetEnabled
    for l in lns
        line.delete(l)
    array.clear(lns)

    for i = -levelsEach to levelsEach
        lvl      = nearest + i * inc
        isActive = i == 0 and nearLevel
        lineCol  = isActive ? (blink ? color.new(color.red, 0) : color.new(color.yellow, 0)) : color.new(color.gray, 60)
        array.push(lns, line.new(bar_index - 100, lvl, bar_index, lvl,
             color=lineCol,
             width=isActive ? 2 : 1,
             style=isActive ? line.style_solid : line.style_dotted,
             extend=extend.right))

    if not na(lbl)
        label.delete(lbl)
        lbl := na
    if nearLevel
        txt = (isPinning ? "📌 PINNING " : "→ NEAR ") + str.tostring(nearest, format.mintick) + "\n" + str.tostring(dist, "#.##") + " pts away · " + str.tostring(pinCount) + " bars"
        lbl := label.new(bar_index + 3, nearest, txt,
             style=label.style_label_left,
             color=blink ? color.new(color.red, 0) : color.new(color.yellow, 0),
             textcolor=blink ? color.white : color.black,
             size=size.normal)

// ─────────────────────────────────────────────
// Banner table (flashing inside table only)
// ─────────────────────────────────────────────
var table banner = table.new(position.top_center, 1, 1)
if barstate.islast or barstate.isrealtime
    if magnetEnabled and nearLevel
        bannerBg   = blink ? color.new(color.red, 0) : color.new(color.yellow, 0)
        bannerText = blink ? color.white : color.black
        table.cell(banner, 0, 0,
             (isPinning ? "🧲 PIN @ " : "NEAR ") + str.tostring(nearest, format.mintick),
             bgcolor=bannerBg,
             text_color=bannerText,
             text_size=size.large)
    else
        table.cell(banner, 0, 0, "", bgcolor=color.new(color.gray, 100))

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(nearLevel and not nearLevel[1], "Approaching round number", "{{ticker}} approaching round level")
alertcondition(isPinning and not isPinning[1], "PINNING detected", "{{ticker}} pinning a round number — dealers likely defending the strike")
````
