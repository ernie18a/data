<!-- tradingview-pine-id: PUB;0098fd02abda48cc9e1bd39d241a33b2 -->
<!-- tradingviewscripts-format: 1 -->
# Fibonacci Vault [JOAT] 

Source: https://www.tradingview.com/script/L4RcaN6I-Fibonacci-Vault-JOAT/

## Description

JackOfAllTrades presents — Fibonacci Vault [JOAT]

A self-anchoring Fibonacci engine that locks onto the latest impulse leg and keeps the Golden Pocket glowing — no manual drawing.

[image]https://www.tradingview.com/x/yFQVXVYj/[/image]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ WHAT IT IS

Drawing Fibonacci by hand means re-anchoring every time structure changes. Fibonacci Vault does it for you: it identifies the most recent confirmed impulse leg, lays the retracement shelves automatically, and treats the Golden Pocket (0.618–0.65) as a first-class zone rather than a single line. It is a pure confluence tool — it maps levels, it does not print buy/sell signals.

This is 100% original code, written from scratch. It does not reuse any other author's Fibonacci script.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ HOW IT WORKS

1. Leg detection. The tool tracks confirmed swing highs and lows (using your chosen strength) and defines the active leg between the two most recent. Leg direction is inferred from which swing printed first — a low-then-high sequence is an up-impulse, and vice versa.

2. Size filter. A leg is only used if it is large enough — a minimum size expressed in ATR multiples — so the Vault anchors to meaningful impulses and ignores insignificant wiggles. As structure evolves, the anchor re-arms itself automatically.

3. The shelves. From the active leg, the standard retracements are projected: 0.236, 0.382, 0.5, 0.618, 0.65, 0.786, plus the 0 and 1 leg endpoints. Optional extension shelves at 1.272 and 1.618 project continuation targets beyond the leg.

4. The Golden Pocket. The 0.618–0.65 band is rendered as a glowing zone, and price trading inside it can optionally tint the background — the area many traders watch for reactions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ WHAT YOU SEE

 • Auto-anchored retracement shelves with optional price tags
 • A glowing Golden Pocket zone and optional 1.272 / 1.618 extensions
 • An impulse-leg line marking the anchor
 • A resizable dashboard showing the active leg and direction, leg size in ATR, how far price has retraced (with a gauge), the Golden Pocket range and whether price is inside it, the nearest shelf, and the projected extensions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ HOW TO USE IT

 • Use the shelves as confluence for entries, targets and invalidation — not as standalone signals.
 • The Golden Pocket is the tool's focal zone; combine a pocket tap with your own trigger for a pullback entry.
 • Extensions give objective targets once an impulse resumes.
 • The retraced % readout tells you at a glance how deep the current pullback is.
 • Works on all symbols and timeframes. Raise swing strength and the minimum leg size to anchor to larger structure only.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ NOTES & LIMITATIONS

Because the leg re-anchors on confirmed swings, the active leg updates as new structure is validated. Fibonacci levels are reference zones, not predictions — the tool is not financial advice and cannot guarantee a reaction at any level. Use it as confluence within your own method and risk plan.

— made with passion by officialjackofalltrade

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JackOfAllTrades — [JOAT] Series
//
// ─────────────────────────────────────────────────────────────────────────────
//  [JOAT] FIBONACCI VAULT
//  A self-managing Fibonacci engine. The Vault locks onto the most recent
//  confirmed impulse leg, lays retracement shelves automatically, and keeps
//  the Golden Pocket (0.618–0.65) glowing as a first-class zone. Legs re-arm
//  themselves as structure evolves — no manual anchoring, ever. Optional
//  extension shelves (1.272 / 1.618) project continuation targets.
//  Pure confluence tool — no buy/sell signals.
//  Color identity: Vault Gold ladder over charcoal, pocket in molten amber.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator('Fibonacci Vault [JOAT] ', shorttitle='VAULT [JOAT]', overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════ INPUTS ═══════════════════════════════════

// ── Impulse Leg ──
swingLen = input.int(15, 'Swing Strength (bars each side)', minval = 3, maxval = 60, group = 'Impulse Leg',
     tooltip = 'Bars each side needed to confirm the swing points that define the impulse leg.\n\nHigher = larger, slower legs. Lower = faster re-anchoring.')
minLegATR = input.float(2.0, 'Min Leg Size (× ATR)', minval = 0.0, step = 0.5, group = 'Impulse Leg',
     tooltip = 'Legs smaller than this many ATRs are ignored — keeps the Vault anchored to meaningful impulses only. 0 = accept all legs.')
showLegLine = input.bool(true, 'Show Impulse Leg Line', group = 'Impulse Leg')

// ── Retracement Shelves ──
show236 = input.bool(true, 'Show 0.236 Shelf', group = 'Retracement Shelves')
show382 = input.bool(true, 'Show 0.382 Shelf', group = 'Retracement Shelves')
show500 = input.bool(true, 'Show 0.500 Shelf', group = 'Retracement Shelves')
show786 = input.bool(true, 'Show 0.786 Shelf', group = 'Retracement Shelves')
showPocket = input.bool(true, 'Show Golden Pocket (0.618–0.65)', group = 'Retracement Shelves',
     tooltip = 'The institutional entry pocket — rendered as a glowing zone instead of a single line.')
showExt = input.bool(true, 'Show Extensions (1.272 / 1.618)', group = 'Retracement Shelves',
     tooltip = 'Projects continuation shelves beyond the leg terminus.')
showPriceTags = input.bool(true, 'Show Price Tags On Shelves', group = 'Retracement Shelves')
rightOffset = input.int(12, 'Shelf Right Extension (bars)', minval = 2, maxval = 60, group = 'Retracement Shelves')

// ── Vault Palette ──
goldColor = input.color(#d4af37, 'Vault Gold', group = 'Vault Palette')
amberColor = input.color(#f59e0b, 'Molten Amber (Pocket)', group = 'Vault Palette')
steelColor = input.color(#8b9dc3, 'Steel Accent (0.5 / leg)', group = 'Vault Palette')
extColor = input.color(#22c55e, 'Extension Color', group = 'Vault Palette')
pocketTransp = input.int(72, 'Pocket Transparency', minval = 0, maxval = 100, group = 'Vault Palette')
shelfTransp = input.int(30, 'Shelf Transparency', minval = 0, maxval = 100, group = 'Vault Palette')
tintPocketTouch = input.bool(true, 'Highlight Bars Inside Pocket', group = 'Vault Palette',
     tooltip = 'Paints a faint amber background while price trades inside the Golden Pocket.')

// ── Vault Dashboard ──
showDash = input.bool(true, 'Show Vault Dashboard', group = 'Vault Dashboard')
dashPos = input.string('Bottom Right', 'Dashboard Position',
     options = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Top Center', 'Bottom Center', 'Middle Left', 'Middle Right'],
     group = 'Vault Dashboard')
dashSize = input.string('Normal', 'Dashboard Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Vault Dashboard')

// ══════════════════════════════ LEG ENGINE ══════════════════════════════════

float atrV = ta.atr(14)
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var float swHigh = na
var int swHighBar = na
var float swLow = na
var int swLowBar = na

if not na(ph)
    swHigh := ph
    swHighBar := bar_index - swingLen
if not na(pl)
    swLow := pl
    swLowBar := bar_index - swingLen

// Active leg: between the two most recent confirmed swings.
// Direction: up-leg if the low was printed before the high (impulse up), else down-leg.
bool haveLeg = not na(swHigh) and not na(swLow) and not na(swHighBar) and not na(swLowBar) and swHigh > swLow
bool legIsUp = haveLeg and swLowBar < swHighBar
float legSize = haveLeg ? swHigh - swLow : na
bool legBigEnough = haveLeg and (minLegATR <= 0 or (not na(atrV) and legSize >= atrV * minLegATR))
bool vaultActive = haveLeg and legBigEnough

// Fib price for a ratio measured against retracement of the leg:
// up-leg → 0 at the high (terminus), 1 at the low (origin); shelves descend from the high.
f_fibPrice(float ratio) =>
    vaultActive ? (legIsUp ? swHigh - legSize * ratio : swLow + legSize * ratio) : na

float f000 = f_fibPrice(0.0)
float f236 = f_fibPrice(0.236)
float f382 = f_fibPrice(0.382)
float f500 = f_fibPrice(0.5)
float f618 = f_fibPrice(0.618)
float f650 = f_fibPrice(0.65)
float f786 = f_fibPrice(0.786)
float f100 = f_fibPrice(1.0)
float fExt1 = f_fibPrice(-0.272)
float fExt2 = f_fibPrice(-0.618)

// ═══════════════════════════ SHELF DRAWING ══════════════════════════════════

var line legLine = na
var line ln000 = na
var line ln236 = na
var line ln382 = na
var line ln500 = na
var line ln786 = na
var line ln100 = na
var line lnExt1 = na
var line lnExt2 = na
var box pocketBox = na
var label tag000 = na
var label tag236 = na
var label tag382 = na
var label tag500 = na
var label tagPocket = na
var label tag786 = na
var label tag100 = na
var label tagExt1 = na
var label tagExt2 = na

f_shelf(line ln, bool show, int x1, float price, color col, string style) =>
    line result = ln
    if not show or na(price)
        if not na(result)
            line.delete(result)
            result := na
        result
    else
        if na(result)
            result := line.new(x1, price, bar_index + rightOffset, price, color = col, width = 1,
                 style = style == 'dot' ? line.style_dotted : style == 'dash' ? line.style_dashed : line.style_solid)
        else
            line.set_xy1(result, x1, price)
            line.set_xy2(result, bar_index + rightOffset, price)
            line.set_color(result, col)
        result

f_tag(label lb, bool show, float price, string txt, color col) =>
    label result = lb
    if not show or na(price)
        if not na(result)
            label.delete(result)
            result := na
        result
    else
        if na(result)
            result := label.new(bar_index + rightOffset, price, txt, style = label.style_label_left,
                 color = color.new(#000000, 100), textcolor = col, size = size.small)
        else
            label.set_xy(result, bar_index + rightOffset, price)
            label.set_text(result, txt)
            label.set_textcolor(result, col)
        result

int legOriginBar = vaultActive ? (legIsUp ? swLowBar : swHighBar) : bar_index
int legEndBar = vaultActive ? (legIsUp ? swHighBar : swLowBar) : bar_index
int shelfLeft = vaultActive ? legEndBar : bar_index

f_priceTxt(string lvl, float p) =>
    showPriceTags and not na(p) ? lvl + '  ' + str.tostring(p, format.mintick) : lvl

// Leg line
if vaultActive and showLegLine
    if na(legLine)
        legLine := line.new(legOriginBar, legIsUp ? swLow : swHigh, legEndBar, legIsUp ? swHigh : swLow,
             color = color.new(steelColor, 35), width = 2, style = line.style_dashed)
    else
        line.set_xy1(legLine, legOriginBar, legIsUp ? swLow : swHigh)
        line.set_xy2(legLine, legEndBar, legIsUp ? swHigh : swLow)
else if not na(legLine)
    line.delete(legLine)
    legLine := na

color goldSoft = color.new(goldColor, shelfTransp)
color steelSoft = color.new(steelColor, shelfTransp)
color extSoft = color.new(extColor, shelfTransp + 10 > 100 ? 100 : shelfTransp + 10)

ln000 := f_shelf(ln000, vaultActive, shelfLeft, f000, color.new(goldColor, 10), 'solid')
ln236 := f_shelf(ln236, vaultActive and show236, shelfLeft, f236, goldSoft, 'dot')
ln382 := f_shelf(ln382, vaultActive and show382, shelfLeft, f382, goldSoft, 'dot')
ln500 := f_shelf(ln500, vaultActive and show500, shelfLeft, f500, steelSoft, 'dash')
ln786 := f_shelf(ln786, vaultActive and show786, shelfLeft, f786, goldSoft, 'dot')
ln100 := f_shelf(ln100, vaultActive, shelfLeft, f100, color.new(goldColor, 10), 'solid')
lnExt1 := f_shelf(lnExt1, vaultActive and showExt, shelfLeft, fExt1, extSoft, 'dot')
lnExt2 := f_shelf(lnExt2, vaultActive and showExt, shelfLeft, fExt2, extSoft, 'dot')

// Golden pocket zone
if vaultActive and showPocket and not na(f618) and not na(f650)
    float pTop = math.max(f618, f650)
    float pBot = math.min(f618, f650)
    if na(pocketBox)
        pocketBox := box.new(shelfLeft, pTop, bar_index + rightOffset, pBot,
             border_color = color.new(amberColor, 40), border_width = 1,
             bgcolor = color.new(amberColor, pocketTransp))
    else
        box.set_lefttop(pocketBox, shelfLeft, pTop)
        box.set_rightbottom(pocketBox, bar_index + rightOffset, pBot)
else if not na(pocketBox)
    box.delete(pocketBox)
    pocketBox := na

// Price tags
tag000 := f_tag(tag000, vaultActive, f000, f_priceTxt('0', f000), color.new(goldColor, 5))
tag236 := f_tag(tag236, vaultActive and show236, f236, f_priceTxt('0.236', f236), goldSoft)
tag382 := f_tag(tag382, vaultActive and show382, f382, f_priceTxt('0.382', f382), goldSoft)
tag500 := f_tag(tag500, vaultActive and show500, f500, f_priceTxt('0.5', f500), steelSoft)
tagPocket := f_tag(tagPocket, vaultActive and showPocket, f618, f_priceTxt('◆ GP', f618), color.new(amberColor, 5))
tag786 := f_tag(tag786, vaultActive and show786, f786, f_priceTxt('0.786', f786), goldSoft)
tag100 := f_tag(tag100, vaultActive, f100, f_priceTxt('1', f100), color.new(goldColor, 5))
tagExt1 := f_tag(tagExt1, vaultActive and showExt, fExt1, f_priceTxt('1.272', fExt1), extSoft)
tagExt2 := f_tag(tagExt2, vaultActive and showExt, fExt2, f_priceTxt('1.618', fExt2), extSoft)

// ─── Pocket touch tint ───
bool inPocket = vaultActive and not na(f618) and not na(f650) and low <= math.max(f618, f650) and high >= math.min(f618, f650)
bgcolor(tintPocketTouch and inPocket ? color.new(amberColor, 90) : na, title = 'Pocket Touch Tint')

// ═══════════════════════════ VAULT DASHBOARD ════════════════════════════════

finalDashPos =
     dashPos == 'Top Left' ? position.top_left :
     dashPos == 'Top Right' ? position.top_right :
     dashPos == 'Bottom Left' ? position.bottom_left :
     dashPos == 'Bottom Right' ? position.bottom_right :
     dashPos == 'Top Center' ? position.top_center :
     dashPos == 'Bottom Center' ? position.bottom_center :
     dashPos == 'Middle Left' ? position.middle_left :
     dashPos == 'Middle Right' ? position.middle_right : position.bottom_right
finalDashSize =
     dashSize == 'Tiny' ? size.tiny :
     dashSize == 'Small' ? size.small :
     dashSize == 'Large' ? size.large : size.normal

f_retraceGauge(float r) =>
    int seg = math.round(math.max(math.min(r, 1.0), 0.0) * 10)
    string g = ''
    for i = 1 to 10
        g += i <= seg ? '▰' : '▱'
    g

var table dash = na
if barstate.islast and showDash
    if not na(dash)
        table.delete(dash)
        dash := na
    dash := table.new(finalDashPos, columns = 3, rows = 10, bgcolor = color.new(#1a1610, 8),
         border_width = 1, border_color = color.new(#000000, 100),
         frame_width = 2, frame_color = color.new(goldColor, 30))

    color rowBg = color.new(#201a10, 22)
    color rowBgAlt = color.new(#17130b, 22)
    color lblCol = color.new(color.white, 18)

    string legTxt = not vaultActive ? 'SCANNING…' : legIsUp ? '▲ IMPULSE UP' : '▼ IMPULSE DOWN'
    color legBg = not vaultActive ? rowBg : legIsUp ? color.new(#22c55e, 45) : color.new(#ef4444, 45)

    float retrace = vaultActive ? (legIsUp ? (swHigh - close) / legSize : (close - swLow) / legSize) : na
    string retraceTxt = na(retrace) ? '—' : str.tostring(retrace * 100, '#.#') + '%'
    string pocketTxt = not vaultActive ? '—' : inPocket ? '● PRICE INSIDE' : close > math.max(f618, f650) and legIsUp ? 'above pocket' : close < math.min(f618, f650) and legIsUp ? 'below pocket' : 'outside'

    // nearest shelf to price
    string nearLvl = '—'
    float nearDist = na
    if vaultActive
        if show236 and (na(nearDist) or math.abs(close - f236) < nearDist)
            nearDist := math.abs(close - f236)
            nearLvl := '0.236'
        if show382 and (na(nearDist) or math.abs(close - f382) < nearDist)
            nearDist := math.abs(close - f382)
            nearLvl := '0.382'
        if show500 and (na(nearDist) or math.abs(close - f500) < nearDist)
            nearDist := math.abs(close - f500)
            nearLvl := '0.5'
        if showPocket and (na(nearDist) or math.abs(close - f618) < nearDist)
            nearDist := math.abs(close - f618)
            nearLvl := 'Golden Pocket'
        if show786 and (na(nearDist) or math.abs(close - f786) < nearDist)
            nearDist := math.abs(close - f786)
            nearLvl := '0.786'

    // ── Title band (gold ladder) ──
    table.cell(dash, 0, 0, '◆ FIBONACCI VAULT', text_color = color.rgb(26, 20, 5), bgcolor = color.new(goldColor, 15), text_size = finalDashSize)
    table.cell(dash, 1, 0, '', bgcolor = color.new(goldColor, 35), text_size = finalDashSize)
    table.cell(dash, 2, 0, syminfo.ticker + ' · ' + timeframe.period, text_color = color.white, bgcolor = color.new(amberColor, 35), text_size = finalDashSize)
    // ── Gradient accent strip ──
    table.cell(dash, 0, 1, '', bgcolor = color.new(goldColor, 75), text_size = size.tiny)
    table.cell(dash, 1, 1, '', bgcolor = color.new(goldColor, 50), text_size = size.tiny)
    table.cell(dash, 2, 1, '', bgcolor = color.new(amberColor, 30), text_size = size.tiny)
    // ── Leg ──
    table.cell(dash, 0, 2, 'Active Leg', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 2, legTxt, text_color = color.white, bgcolor = legBg, text_size = finalDashSize)
    table.cell(dash, 2, 2, not vaultActive ? '' : 'anchor ' + str.tostring(legIsUp ? swLow : swHigh, format.mintick), text_color = color.new(color.white, 40), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 0, 3, 'Leg Size', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 3, not vaultActive ? '—' : str.tostring(legSize, format.mintick), text_color = color.new(color.white, 15), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 3, not vaultActive or na(atrV) or atrV <= 0 ? '' : str.tostring(legSize / atrV, '0.0') + '× ATR', text_color = color.new(goldColor, 20), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Retrace + gauge ──
    table.cell(dash, 0, 4, 'Retraced', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 4, retraceTxt, text_color = color.new(goldColor, 10), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 4, na(retrace) ? '' : f_retraceGauge(retrace), text_color = color.new(goldColor, 20), bgcolor = rowBg, text_size = finalDashSize)
    // ── Golden pocket ──
    table.cell(dash, 0, 5, 'Golden Pocket', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 5, pocketTxt, text_color = inPocket ? color.rgb(26, 20, 5) : color.new(color.white, 35), bgcolor = inPocket ? color.new(amberColor, 25) : rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 5, not vaultActive ? '' : str.tostring(math.min(f618, f650), format.mintick) + ' → ' + str.tostring(math.max(f618, f650), format.mintick), text_color = color.new(amberColor, 15), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Nearest shelf ──
    table.cell(dash, 0, 6, 'Nearest Shelf', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 6, nearLvl, text_color = nearLvl == 'Golden Pocket' ? amberColor : color.new(goldColor, 15), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 6, na(nearDist) or na(atrV) or atrV <= 0 ? '' : str.tostring(nearDist / atrV, '0.0') + 'x ATR away', text_color = color.new(color.white, 40), bgcolor = rowBg, text_size = finalDashSize)
    // ── Extensions ──
    table.cell(dash, 0, 7, 'Extensions', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 7, not vaultActive or not showExt ? '—' : '1.272 ' + str.tostring(fExt1, format.mintick), text_color = color.new(extColor, 20), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 7, not vaultActive or not showExt ? '' : '1.618 ' + str.tostring(fExt2, format.mintick), text_color = color.new(extColor, 20), bgcolor = rowBgAlt, text_size = finalDashSize)
    // ── Leg endpoints ──
    table.cell(dash, 0, 8, 'Leg High / Low', text_color = lblCol, bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 1, 8, not vaultActive ? '—' : str.tostring(swHigh, format.mintick), text_color = color.new(#22c55e, 20), bgcolor = rowBg, text_size = finalDashSize)
    table.cell(dash, 2, 8, not vaultActive ? '' : str.tostring(swLow, format.mintick), text_color = color.new(#ef4444, 20), bgcolor = rowBg, text_size = finalDashSize)
    // ── Settings footer ──
    table.cell(dash, 0, 9, 'Swing Strength', text_color = lblCol, bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 1, 9, str.tostring(swingLen) + ' bars', text_color = color.new(color.white, 30), bgcolor = rowBgAlt, text_size = finalDashSize)
    table.cell(dash, 2, 9, 'min leg ' + str.tostring(minLegATR, '0.0') + '× ATR', text_color = color.new(color.white, 40), bgcolor = rowBgAlt, text_size = finalDashSize)

// ════════════════════════════════ ALERTS ════════════════════════════════════

alertcondition(inPocket and not inPocket[1], title = 'Golden Pocket Touch', message = '[JOAT] Fibonacci Vault — {{ticker}} entered the Golden Pocket ({{interval}})')
alertcondition(vaultActive and ta.cross(close, f500), title = '0.5 Shelf Cross', message = '[JOAT] Fibonacci Vault — {{ticker}} crossed the 0.5 shelf ({{interval}})')
alertcondition(vaultActive and ta.cross(close, f786), title = '0.786 Shelf Cross', message = '[JOAT] Fibonacci Vault — {{ticker}} crossed the 0.786 shelf ({{interval}})')
````
