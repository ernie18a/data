# Market Structure Dashboard by @skyderfx

- url: https://www.tradingview.com/script/Y0vPJPQz-Market-Structure-Dashboard-by-skyderfx/
- type: indicator
- pine_id: PUB;4fde19c4bb5e4d1793bfdef34278bf65
- version: 1.0

## Description

Get a clear overview of the current market structure at a glance with the Market Structure Indicator.

This tool analyzes multiple timeframes and clearly shows whether the market is in a Bullish, Bearish, or No Direction structure on each timeframe. This allows you to quickly understand how the market is behaving across different levels.

What you get:

📊 Multi-timeframe market structure
🟢 Bullish structure
🔴 Bearish structure
⚪ No Direction / Neutral structure
🎯 Clear overall bias
⏱️ Multiple timeframes displayed in one dashboard
⚡ Fast and clean overview without unnecessary information

Example of the dashboard:

1M → Bullish
5M → Bullish
15M → Bullish
1H → No Direction
4H → No Direction
1D → No Direction
BIAS → Bullish

The indicator is designed to help traders interpret market structure and multi-timeframe context more efficiently before analyzing a trade.

Disclaimer: This indicator is an analysis tool and does not constitute financial advice. Always use your own strategy, risk management, and market analysis.

## Source Code

````pine
//@version=6
indicator("MTF Market Structure Dashboard", "MTF Structure", overlay = true)

// ═══════════════════════ INSTELLINGEN ═══════════════════════
grpS     = "Structure"
swingLen = input.int(5, "Swing lengte (bars links/rechts)", minval = 1, group = grpS, tooltip = "Hoeveel candles links en rechts lager/hoger moeten zijn om een swing high/low te tellen. Hoger = grotere swings.")
useClose = input.bool(true, "BOS/CHoCH alleen op candle close", group = grpS, tooltip = "Aan = body moet door de swing sluiten. Uit = een wick erdoor telt ook als break.")

mixFilter = input.bool(true, "NO DIRECTION bij gemixte swings", group = grpS, tooltip = "Aan = als de swings tegen elkaar in gaan (HH + LL of LH + HL) is er geen duidelijke trend en toont het dashboard NO DIRECTION.")

grpT      = "Timeframes"
tf0       = input.timeframe("5",   "TF 0 (entry)", group = grpT)
tf1       = input.timeframe("15",  "TF 1", group = grpT)
tf2       = input.timeframe("60",  "TF 2", group = grpT)
tf3       = input.timeframe("240", "TF 3", group = grpT)
tf4       = input.timeframe("D",   "TF 4", group = grpT)
showTf0   = input.bool(true, "TF 0 rij tonen", group = grpT)

grpD    = "Dashboard"
posIn   = input.string("Rechtsboven", "Positie", options = ["Rechtsboven", "Rechtsonder", "Linksboven", "Linksonder"], group = grpD)
sizeIn  = input.string("Normaal", "Tekstgrootte", options = ["Klein", "Normaal", "Groot"], group = grpD)
bullCol = input.color(#089981, "Bullish kleur", group = grpD)
bearCol = input.color(#F23645, "Bearish kleur", group = grpD)

grpA       = "Alerts"
alertFlip  = input.bool(true, "Alert bij structure flip (CHoCH) op hogere TF's", group = grpA)

// ═══════════════════════ STRUCTURE LOGICA ═══════════════════════
// trend: 1 = bullish, -1 = bearish, 0 = nog onbekend
// event: 1 = BOS, 2 = CHoCH
// hType: 1 = HH, -1 = LH   |   lType: 1 = HL, -1 = LL
f_structure() =>
    var float swingHigh = na
    var float swingLow  = na
    var int   trend     = 0
    var int   event     = 0
    var int   hType     = 0
    var int   lType     = 0
    var bool  hBroken   = false
    var bool  lBroken   = false

    ph = ta.pivothigh(high, swingLen, swingLen)
    pl = ta.pivotlow(low, swingLen, swingLen)

    if not na(ph)
        hType     := na(swingHigh) ? 0 : ph > swingHigh ? 1 : -1
        swingHigh := ph
        hBroken   := false
    if not na(pl)
        lType    := na(swingLow) ? 0 : pl > swingLow ? 1 : -1
        swingLow := pl
        lBroken  := false

    upSrc = useClose ? close : high
    dnSrc = useClose ? close : low

    // Break boven swing high -> bullish BOS of CHoCH
    if not na(swingHigh) and not hBroken and upSrc > swingHigh
        event   := trend == -1 ? 2 : 1
        trend   := 1
        hBroken := true

    // Break onder swing low -> bearish BOS of CHoCH
    if not na(swingLow) and not lBroken and dnSrc < swingLow
        event   := trend == 1 ? 2 : 1
        trend   := -1
        lBroken := true

    [trend, event, swingHigh, swingLow, hType, lType]

// Alleen gesloten HTF candles gebruiken -> geen repaint
f_confirmed() =>
    [t, e, sh, sl, h, l] = f_structure()
    [t[1], e[1], sh[1], sl[1], h[1], l[1]]

[t1, e1, sh1, sl1, h1, l1] = request.security(syminfo.tickerid, tf1, f_confirmed(), lookahead = barmerge.lookahead_on)
[t2, e2, sh2, sl2, h2, l2] = request.security(syminfo.tickerid, tf2, f_confirmed(), lookahead = barmerge.lookahead_on)
[t3, e3, sh3, sl3, h3, l3] = request.security(syminfo.tickerid, tf3, f_confirmed(), lookahead = barmerge.lookahead_on)
[t4, e4, sh4, sl4, h4, l4] = request.security(syminfo.tickerid, tf4, f_confirmed(), lookahead = barmerge.lookahead_on)
// TF 0 (5m): live als je chart op 5m staat, anders opgehaald (hoger of lager dan je chart)
[tC, eC, shC, slC, hC, lC] = f_structure()
[tH, eH, shH, slH, hH, lH] = request.security(syminfo.tickerid, tf0, f_confirmed(), lookahead = barmerge.lookahead_on)
[tL, eL, shL, slL, hL, lL] = request.security(syminfo.tickerid, tf0, f_confirmed(), lookahead = barmerge.lookahead_off)
isChart0 = timeframe.in_seconds(tf0) == timeframe.in_seconds()
isHigher0 = timeframe.in_seconds(tf0) > timeframe.in_seconds()
t0 = isChart0 ? tC : isHigher0 ? tH : tL
e0 = isChart0 ? eC : isHigher0 ? eH : eL
h0 = isChart0 ? hC : isHigher0 ? hH : hL
l0 = isChart0 ? lC : isHigher0 ? lH : lL
sh0 = isChart0 ? shC : isHigher0 ? shH : shL
sl0 = isChart0 ? slC : isHigher0 ? slH : slL

// ═══════════════════════ DASHBOARD ═══════════════════════
tPos = switch posIn
    "Rechtsboven" => position.top_right
    "Rechtsonder" => position.bottom_right
    "Linksboven"  => position.top_left
    => position.bottom_left

tSize = switch sizeIn
    "Klein" => size.small
    "Groot" => size.large
    => size.normal

var table dash = table.new(tPos, 2, 9, bgcolor = color.new(#0B1A33, 5), border_color = color.new(color.gray, 75), border_width = 1, frame_color = color.new(color.gray, 50), frame_width = 1)

f_tfLabel(tf) =>
    s = timeframe.in_seconds(tf)
    s >= 604800 ? str.tostring(math.round(s / 604800)) + "W" : s >= 86400 ? str.tostring(math.round(s / 86400)) + "D" : s >= 3600 ? str.tostring(math.round(s / 3600)) + "H" : str.tostring(math.round(s / 60)) + "m"

f_cell(int c, int r, string txt, color txtCol, color bg) =>
    table.cell(dash, c, r, txt, text_color = txtCol, bgcolor = bg, text_size = tSize)

// 0 = geen duidelijke trend: nog geen break, of swings gemixt (HH/LL of LH/HL)
f_dir(t, h, l) =>
    noTrend = t == 0 or (mixFilter and h != 0 and l != 0 and h != l)
    noTrend ? 0 : t

f_row(r, lbl, tRaw, e, sh, sl, h, l) =>
    t        = f_dir(tRaw, h, l)
    col      = t == 1 ? bullCol : t == -1 ? bearCol : color.new(color.gray, 30)
    trendTxt = t == 1 ? "▲ BULLISH" : t == -1 ? "▼ BEARISH" : "◆ NO DIRECTION"
    f_cell(0, r, lbl, color.white, color.new(#14284D, 0))
    f_cell(1, r, trendTxt, color.white, color.new(col, 20))

if barstate.islast
    hdr = color.new(#14284D, 0)
    f_cell(0, 0, "MARKETSTRUCTURE BY SKYDERFX", color.white, color.new(#0A2A66, 0))
    table.merge_cells(dash, 0, 0, 1, 0)
    f_cell(0, 1, "TF", color.white, hdr)
    f_cell(1, 1, "Structure", color.white, hdr)

    row = 2
    if showTf0
        f_row(row, f_tfLabel(tf0), t0, e0, sh0, sl0, h0, l0)
        row += 1
    f_row(row,     f_tfLabel(tf1), t1, e1, sh1, sl1, h1, l1)
    f_row(row + 1, f_tfLabel(tf2), t2, e2, sh2, sl2, h2, l2)
    f_row(row + 2, f_tfLabel(tf3), t3, e3, sh3, sl3, h3, l3)
    f_row(row + 3, f_tfLabel(tf4), t4, e4, sh4, sl4, h4, l4)

    // Overall bias van de 4 hogere timeframes
    score   = f_dir(t1, h1, l1) + f_dir(t2, h2, l2) + f_dir(t3, h3, l3) + f_dir(t4, h4, l4)
    biasTxt = score == 4 ? "STERK BULLISH (4/4)" : score == -4 ? "STERK BEARISH (4/4)" : score > 0 ? "Bullish bias (" + str.tostring(score) + ")" : score < 0 ? "Bearish bias (" + str.tostring(score) + ")" : "NO DIRECTION"
    biasCol = score > 0 ? bullCol : score < 0 ? bearCol : color.gray
    f_cell(0, row + 4, "BIAS", color.white, hdr)
    f_cell(1, row + 4, biasTxt, color.white, color.new(biasCol, 10))

// ═══════════════════════ ALERTS ═══════════════════════
f_flipAlert(t, lbl) =>
    if alertFlip and t != t[1] and t[1] != 0 and t != 0
        alert(syminfo.ticker + " " + lbl + " structure flip -> " + (t == 1 ? "BULLISH (CHoCH)" : "BEARISH (CHoCH)"), alert.freq_once_per_bar)

f_flipAlert(t1, f_tfLabel(tf1))
f_flipAlert(t2, f_tfLabel(tf2))
f_flipAlert(t3, f_tfLabel(tf3))
f_flipAlert(t4, f_tfLabel(tf4))
````
