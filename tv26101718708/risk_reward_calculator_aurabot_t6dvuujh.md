# Risk Reward Calculator [Aurabot]

- url: https://www.tradingview.com/script/T6dVUujh-Risk-Reward-Calculator-Aurabot/
- type: indicator
- pine_id: PUB;5846a63aabc44de0944065fbfa1eaac7
- version: 1.0

## Description

Risk Reward Calculator draws your trade plan on the chart before you take it: an entry line, a red stop zone and a green target zone, with the dollar risk, dollar reward and R:R for your contract size.

WHAT IT SHOWS
- Entry line where the trade starts
- Stop zone from entry to your stop, with the price and the dollar amount you lose if it is hit
- Target zone from entry to your target, with the price and the dollar amount you make if it is hit
- Stats panel: dollar risk, dollar reward, R:R, stop distance, contracts, value per point, and percent of account at risk if you enter an account size

HOW IT WORKS
- Pick Long or Short and how many contracts.
- Set the stop and target distance in points, ticks, or as exact prices.
- The box starts at the current price, snaps to a round number, or uses a price you type. It stays frozen where you put it unless you turn on Follow, re-drop it, or set it to re-drop on a new bar or at a session open.
- Dollar values use the contract's point value. On futures, Auto Detect reads the contract's own specs, so micros like MNQ and MGC are priced correctly. On CFD symbols it maps NQ, ES, YM and Gold to full size futures values. Custom lets you type the point value and tick size for anything else.

HOW TO USE IT
Drop the box, set your stop and target, and read the panel. If the stop zone is bigger than the target zone, the trade risks more than it can make. That is the whole point of the tool: see the plan in dollars before you click.

THEMES
Aurabot (default), Neon Cyber, Midnight Aura, Sunset Blaze, Ocean Depth, Ghost Protocol, Classic, Neon Violet, Plasma, Blade Runner, Toxic, Ghost Wire, Midnight Blue, Ember Gold, Stealth Dark, Clean Light (for white charts), or Custom.

NOTES
This is a planning tool. It does not place orders or give signals. Fees and slippage are not included.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AuraSznfx
// Aurabot Risk Reward Calculator
// Draws your stop and target as boxes from an entry price and shows the dollar risk, dollar reward and R:R for your contract size.

//@version=6
indicator("Aurabot Risk Reward Calculator", "R:R Calculator", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//─────────────────────────────────────────────────────────────────────────────
// 1️⃣ YOUR TRADE  —  are you buying or selling?
//─────────────────────────────────────────────────────────────────────────────
_g1 = "1️⃣ Your Trade"
tradeDir = input.string("Long", "Buy or Sell?", options=["Long", "Short"], group=_g1, tooltip="Long = you think price goes UP (buying). Short = you think price goes DOWN (selling).")

lots = input.float(1.0, "How many contracts?", minval=0.01, group=_g1, tooltip="How many you're trading. 1 is normal. The dollar amounts get bigger the more you add.")

//─────────────────────────────────────────────────────────────────────────────
// 2️⃣ FOLLOW OR FREEZE  —  should the box move with price?
//─────────────────────────────────────────────────────────────────────────────
_g2 = "2️⃣ Follow or Freeze"
followMode = input.bool(false, "Follow the price live?", group=_g2, tooltip="OFF = the box stays frozen where you put it (default). ON = the box chases live price up and down.")
reLock     = input.bool(false, "📍 Re-drop the box here", group=_g2, tooltip="Tick this to move your frozen box to wherever price is RIGHT NOW. Then untick it. Like picking the box up and dropping it at the current price.")

//─────────────────────────────────────────────────────────────────────────────
// 3️⃣ STOP LOSS & TARGET  —  where do you get out?
//─────────────────────────────────────────────────────────────────────────────
_g3 = "3️⃣ Stop Loss & Target"
distanceMode = input.string("Points", "Measure by...", options=["Points", "Ticks", "Exact Price"], group=_g3, tooltip="Points = easiest, just how far away. Ticks = tiny steps for fine control. Exact Price = type the exact price you want.")

slDistance = input.float(50.0, "🛑 Stop Loss (how far?)", minval=0.0, group=_g3, tooltip="How far away your safety exit is. This is the RED zone — the most you'll lose if wrong.")
tpDistance = input.float(100.0, "🎯 Target (how far?)", minval=0.0, group=_g3, tooltip="How far away your win goal is. This is the GREEN zone — what you make if right.")

manualSL = input.price(0.0, "↳ Exact Stop price", group=_g3, tooltip="Only used if you picked 'Exact Price' above. Type the exact stop price.")
manualTP = input.price(0.0, "↳ Exact Target price", group=_g3, tooltip="Only used if you picked 'Exact Price' above. Type the exact target price.")

showTP = input.bool(true, "Show the green target zone?", group=_g3)

//─────────────────────────────────────────────────────────────────────────────
// 4️⃣ WHAT ARE YOU TRADING?  —  so the dollars are correct
//─────────────────────────────────────────────────────────────────────────────
_g4 = "4️⃣ What Are You Trading?"
instrument = input.string("Auto Detect", "Pick your market", options=["Auto Detect", "NQ (Nasdaq)", "ES (S&P)", "US30 (Dow)", "GOLD (GC)", "Custom"], group=_g4, tooltip="Auto Detect figures it out for you. Or pick your market so the dollar math is exact.")

customPointValue = input.float(20.0, "↳ Custom: $ per point", minval=0.0, group=_g4, tooltip="Only for 'Custom'. How many dollars is 1 point worth for 1 contract?")
customTickSize    = input.float(0.25, "↳ Custom: tick size", minval=0.0, group=_g4, tooltip="Only for 'Custom'. The smallest price step your market moves in.")

accountSize = input.float(0.0, "💼 Your account size ($)", minval=0.0, group=_g4, tooltip="Optional. Type your account size and it'll show what % you're risking. Leave 0 to skip.")

//─────────────────────────────────────────────────────────────────────────────
// 5️⃣ THE MONEY BOX  —  where it sits & how it looks
//─────────────────────────────────────────────────────────────────────────────
_g5 = "5️⃣ The Money Box"
anchorMode = input.string("Auto (Current Price)", "Where does the box start?", options=["Auto (Current Price)", "Round Number Magnet", "Manual Price"], group=_g5, tooltip="Auto = at current price. Round Number Magnet = snaps to clean numbers. Manual Price = you type where it starts.")
manualEntry = input.price(0.0, "↳ Manual start price", group=_g5, tooltip="Only used if you picked 'Manual Price' above.")
roundStep   = input.float(10.0, "↳ Round to nearest...", minval=0.01, group=_g5, tooltip="Only for 'Round Number Magnet'. Snaps to the nearest multiple. Try 10 for NQ, 5 for Dow, 0.5 for Gold.")

extendLeftBars  = input.int(3, "Box: stretch left", minval=0, maxval=100, group=_g5, tooltip="How far the box reaches to the left.")
extendRightBars = input.int(8, "Box: stretch right", minval=2, maxval=100, group=_g5, tooltip="How far the box reaches to the right.")
borderW         = input.int(1, "Box: border thickness", minval=1, maxval=4, group=_g5)
showEntryLine   = input.bool(true, "Show the entry line?", group=_g5, tooltip="The white/gold line where your trade starts.")
showLevelLabels = input.bool(true, "Show price + $ labels?", group=_g5, tooltip="The little tags showing the stop/target prices and dollar amounts.")
labelSize       = input.string("Small", "Label size", options=["Tiny", "Small", "Normal"], group=_g5)

//─────────────────────────────────────────────────────────────────────────────
// 6️⃣ THE MONEY PANEL  —  your stats readout
//─────────────────────────────────────────────────────────────────────────────
_g6 = "6️⃣ The Money Panel"
showPanel   = input.bool(true, "Show the stats panel?", group=_g6, tooltip="The little scoreboard showing your risk, reward, and R:R.")
panelPos    = input.string("Top Right", "Panel corner", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=_g6, tooltip="Which corner the scoreboard sits in.")
panelTxtSz  = input.string("Small", "Panel text size", options=["Tiny", "Small", "Normal", "Large"], group=_g6)

//─────────────────────────────────────────────────────────────────────────────
// 7️⃣ COLORS & STYLE
//─────────────────────────────────────────────────────────────────────────────
_g7 = "7️⃣ Colors & Style"
theme_choice = input.string("Aurabot", "Color theme", group=_g7, options=["Aurabot", "Neon Cyber", "Midnight Aura", "Sunset Blaze", "Ocean Depth", "Ghost Protocol", "Classic", "Neon Violet", "Plasma", "Blade Runner", "Toxic", "Ghost Wire", "Midnight Blue", "Ember Gold", "Stealth Dark", "Clean Light", "Custom"], tooltip="Pick a vibe. Green = target side, Red = stop side.")
customProfitColor = input.color(#00E676, '↳ Custom green (target)', group=_g7)
customRiskColor   = input.color(#FF1744, '↳ Custom red (stop)', group=_g7)
zoneFillTransp    = input.int(88, 'Box see-through amount', minval=50, maxval=95, group=_g7, tooltip="Higher = more see-through boxes.")
zoneBorderTransp  = input.int(60, 'Border see-through amount', minval=30, maxval=90, group=_g7)

//─────────────────────────────────────────────────────────────────────────────
// 8️⃣ AURABOT TAG
//─────────────────────────────────────────────────────────────────────────────
_g8 = "8️⃣ Aurabot Tag"
showBrand    = input.bool(true, "Show AURABOT tag?", group=_g8, tooltip="A small name tag on top of the box. Turn it off or change the text.")
brandText    = input.string("aurabot", "↳ Tag text", group=_g8, tooltip="Shown in ALL CAPS.")
brandTxtSz   = input.string("Normal", "↳ Tag size", options=["Tiny", "Small", "Normal", "Large"], group=_g8)
brandAnchor  = input.string("Near TP", "↳ Tag sits near...", options=["Near TP", "Near Entry", "Near SL"], group=_g8)


//─────────────────────────────────────────────────────────────────────────────
// 9️⃣ AUTO-LOCK (advanced, optional)
//─────────────────────────────────────────────────────────────────────────────
_g9 = "9️⃣ Auto-Lock (optional)"
autoLock   = input.string("Off", "Auto re-drop box when...", options=["Off", "On New Bar", "On Session Open"], group=_g9, tooltip="Hands-free. Auto re-drops the box on each new bar, or at session open. Leave Off if unsure.")
lockSession = input.session("0930-0930", "↳ Session time", group=_g9, tooltip="Only for 'On Session Open'. 0930 = US market open.")

//─────────────────────────────────────────────────────────────────────────────
// Theme resolution
//─────────────────────────────────────────────────────────────────────────────
_nc_p = #00E676, _nc_r = #FF1744
_ma_p = #6366F1, _ma_r = #F472B6
_sb_p = #FBBF24, _sb_r = #EF4444
_od_p = #22D3EE, _od_r = #F97316
_gp_p = #A1A1AA, _gp_r = #52525B
_cl_p = #089981, _cl_r = #F23645
_nv_p = #B388FF, _nv_r = #FF4081
_pl_p = #00FFF5, _pl_r = #FF006E
_br_p = #FFAB40, _br_r = #448AFF
_tx_p = #76FF03, _tx_r = #D500F9
_gw_p = #84FFFF, _gw_r = #FF8A80
_mb_p = #00B0FF, _mb_r = #FF6B6B
_eg_p = #FFD740, _eg_r = #FF6E40
_sd_p = #A5D6A7, _sd_r = #EF9A9A
_clt_p = #2E7D32, _clt_r = #C62828

profitColor = switch theme_choice
    'Aurabot'        => #00D9FF
    'Neon Cyber'     => _nc_p
    'Midnight Aura'  => _ma_p
    'Sunset Blaze'   => _sb_p
    'Ocean Depth'    => _od_p
    'Ghost Protocol' => _gp_p
    'Classic'        => _cl_p
    'Neon Violet'    => _nv_p
    'Plasma'         => _pl_p
    'Blade Runner'   => _br_p
    'Toxic'          => _tx_p
    'Ghost Wire'     => _gw_p
    'Midnight Blue'  => _mb_p
    'Ember Gold'     => _eg_p
    'Stealth Dark'   => _sd_p
    'Clean Light'    => _clt_p
    'Custom'         => customProfitColor

riskColor = switch theme_choice
    'Aurabot'        => #FF427E
    'Neon Cyber'     => _nc_r
    'Midnight Aura'  => _ma_r
    'Sunset Blaze'   => _sb_r
    'Ocean Depth'    => _od_r
    'Ghost Protocol' => _gp_r
    'Classic'        => _cl_r
    'Neon Violet'    => _nv_r
    'Plasma'         => _pl_r
    'Blade Runner'   => _br_r
    'Toxic'          => _tx_r
    'Ghost Wire'     => _gw_r
    'Midnight Blue'  => _mb_r
    'Ember Gold'     => _eg_r
    'Stealth Dark'   => _sd_r
    'Clean Light'    => _clt_r
    'Custom'         => customRiskColor

color profitFill   = color.new(profitColor, zoneFillTransp)
color profitBorder = color.new(profitColor, zoneBorderTransp)
color riskFill     = color.new(riskColor, zoneFillTransp)
color riskBorder   = color.new(riskColor, zoneBorderTransp)

//─────────────────────────────────────────────────────────────────────────────
// Contract spec resolution
//─────────────────────────────────────────────────────────────────────────────
_sym = str.upper(syminfo.ticker)
_isNQ   = str.contains(_sym, "NQ") or str.contains(_sym, "NAS")
_isES   = str.contains(_sym, "ES") and not str.contains(_sym, "NAS")
_isUS30 = str.contains(_sym, "YM") or str.contains(_sym, "US30") or str.contains(_sym, "DJ") or str.contains(_sym, "DOW")
_isGold = str.contains(_sym, "GC") or str.contains(_sym, "GOLD") or str.contains(_sym, "XAU")

[pointValue, tickSize] = switch instrument
    "NQ (Nasdaq)"  => [20.0, 0.25]
    "ES (S&P)"     => [50.0, 0.25]
    "US30 (Dow)"   => [5.0, 1.0]
    "GOLD (GC)"    => [100.0, 0.1]
    "Custom"       => [customPointValue, customTickSize]
    =>
        switch
            syminfo.type == "futures" => [syminfo.pointvalue, syminfo.mintick]   // real contract specs, micros included
            _isNQ   => [20.0, 0.25]
            _isES   => [50.0, 0.25]
            _isUS30 => [5.0, 1.0]
            _isGold => [100.0, 0.1]
            => [syminfo.pointvalue, syminfo.mintick]

//─────────────────────────────────────────────────────────────────────────────
// Entry resolution — DEFAULT LOCKED, follow is opt-in
//─────────────────────────────────────────────────────────────────────────────
isLong = tradeDir == "Long"

bool _inSession = not na(time(timeframe.period, lockSession))
bool _sessionStart = _inSession and not _inSession[1]
bool _autoLockFire = switch autoLock
    "On New Bar"      => barstate.isnew
    "On Session Open" => _sessionStart
    => false

varip float _anchorPrice = na
varip bool  _initialized = false
varip bool  _reLockPrev  = false

if not _initialized and barstate.isrealtime
    _anchorPrice := close
    _initialized := true
if not _initialized
    _anchorPrice := close

if reLock and not _reLockPrev and barstate.isrealtime
    _anchorPrice := close
_reLockPrev := reLock

if _autoLockFire and barstate.isrealtime
    _anchorPrice := close

float entry = na
if anchorMode == "Manual Price" and manualEntry > 0
    entry := manualEntry
else if anchorMode == "Round Number Magnet"
    entry := math.round((followMode ? close : _anchorPrice) / roundStep) * roundStep
else
    entry := followMode ? close : _anchorPrice

bool _isLocked = not followMode
bool _showLockBadge = _isLocked

//─────────────────────────────────────────────────────────────────────────────
// SL / TP resolution
//─────────────────────────────────────────────────────────────────────────────
float slPriceOffset = distanceMode == "Ticks" ? slDistance * tickSize : slDistance
float tpPriceOffset = distanceMode == "Ticks" ? tpDistance * tickSize : tpDistance

float slLevel = na
float tpLevel = na
if distanceMode == "Exact Price"
    slLevel := manualSL > 0 ? manualSL : na
    tpLevel := manualTP > 0 ? manualTP : na
else
    slLevel := isLong ? entry - slPriceOffset : entry + slPriceOffset
    tpLevel := isLong ? entry + tpPriceOffset : entry - tpPriceOffset

float slPoints = na(slLevel) ? na : math.abs(entry - slLevel)
float tpPoints = na(tpLevel) ? na : math.abs(entry - tpLevel)

float riskDollars   = na(slPoints) ? na : slPoints * pointValue * lots
float profitDollars = na(tpPoints) ? na : tpPoints * pointValue * lots
float rrRatio       = (na(riskDollars) or riskDollars == 0 or na(profitDollars)) ? na : profitDollars / riskDollars

//─────────────────────────────────────────────────────────────────────────────
// Render
//─────────────────────────────────────────────────────────────────────────────
var array<box>   _boxes = array.new<box>()
var array<line>  _lines = array.new<line>()
var array<label> _labels = array.new<label>()

_clearBx(array<box> _a) =>
    if array.size(_a) > 0
        for i = 0 to array.size(_a) - 1
            box.delete(array.get(_a, i))
    array.clear(_a)
_clearLn(array<line> _a) =>
    if array.size(_a) > 0
        for i = 0 to array.size(_a) - 1
            line.delete(array.get(_a, i))
    array.clear(_a)
_clearLb(array<label> _a) =>
    if array.size(_a) > 0
        for i = 0 to array.size(_a) - 1
            label.delete(array.get(_a, i))
    array.clear(_a)

_lbSz = labelSize == "Tiny" ? size.tiny : labelSize == "Normal" ? size.normal : size.small
_panelSz = panelTxtSz == "Tiny" ? size.tiny : panelTxtSz == "Normal" ? size.normal : panelTxtSz == "Large" ? size.large : size.small
_brandSz = brandTxtSz == "Small" ? size.small : brandTxtSz == "Normal" ? size.normal : brandTxtSz == "Large" ? size.large : size.tiny

var table _panel = na

if barstate.islast
    _clearBx(_boxes)
    _clearLn(_lines)
    _clearLb(_labels)

    int _x1 = bar_index - extendLeftBars
    int _x2 = bar_index + extendRightBars

    color _entryClr = _showLockBadge ? color.new(#FFD700, 5) : color.new(#FFFFFF, 10)

    if not na(slLevel)
        box _rBox = box.new(_x1, math.max(entry, slLevel), _x2, math.min(entry, slLevel), border_color=riskBorder, bgcolor=riskFill, border_width=borderW)
        array.push(_boxes, _rBox)
        line _slLn = line.new(_x1, slLevel, _x2, slLevel, color=color.new(riskColor, 20), style=line.style_dashed, width=1)
        array.push(_lines, _slLn)
        if showLevelLabels
            string _slTxt = "SL " + str.tostring(slLevel, format.mintick) + (na(riskDollars) ? "" : "  |  -$" + str.tostring(riskDollars, "#.##"))
            label _slLb = label.new(_x2, slLevel, _slTxt, style=label.style_label_left, color=color.new(#000000, 75), textcolor=color.new(riskColor, 10), size=_lbSz)
            array.push(_labels, _slLb)

    if showTP and not na(tpLevel)
        box _pBox = box.new(_x1, math.max(entry, tpLevel), _x2, math.min(entry, tpLevel), border_color=profitBorder, bgcolor=profitFill, border_width=borderW)
        array.push(_boxes, _pBox)
        line _tpLn = line.new(_x1, tpLevel, _x2, tpLevel, color=color.new(profitColor, 20), style=line.style_dashed, width=1)
        array.push(_lines, _tpLn)
        if showLevelLabels
            string _tpTxt = "TP " + str.tostring(tpLevel, format.mintick) + (na(profitDollars) ? "" : "  |  +$" + str.tostring(profitDollars, "#.##"))
            label _tpLb = label.new(_x2, tpLevel, _tpTxt, style=label.style_label_left, color=color.new(#000000, 75), textcolor=color.new(profitColor, 10), size=_lbSz)
            array.push(_labels, _tpLb)

    if showEntryLine
        line _eLn = line.new(_x1, entry, _x2, entry, color=_entryClr, style=line.style_solid, width=2)
        array.push(_lines, _eLn)
        if showLevelLabels
            string _eTxt = (_showLockBadge ? "🔒 " : "◈ ") + "ENTRY " + str.tostring(entry, format.mintick)
            label _eLb = label.new(_x2, entry, _eTxt, style=label.style_label_left, color=color.new(#000000, 80), textcolor=_entryClr, size=_lbSz)
            array.push(_labels, _eLb)

    if showBrand
        float _brandY = brandAnchor == "Near SL" and not na(slLevel) ? slLevel : brandAnchor == "Near Entry" ? entry : (not na(tpLevel) ? tpLevel : entry)
        color _brandClr = brandAnchor == "Near SL" ? riskColor : profitColor
        string _tagTxt = str.upper(brandText)
        int _xCenter = math.round((_x1 + _x2) / 2)
        label _brandLb = label.new(_xCenter, _brandY, _tagTxt, style=label.style_label_down, color=color.new(#000000, 85), textcolor=color.new(_brandClr, 5), size=_brandSz, textalign=text.align_center)
        array.push(_labels, _brandLb)

    if showPanel
        _pos = panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Bottom Left" ? position.bottom_left : panelPos == "Middle Right" ? position.middle_right : position.top_right

        if na(_panel)
            _panel := table.new(_pos, 2, 9, border_width=1, border_color=color.new(#000000, 60))
        else
            table.clear(_panel, 0, 0, 1, 8)

        table.cell(_panel, 0, 0, "◈ PROFIT CALC", bgcolor=color.new(#000000, 15), text_color=color.new(profitColor, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 0, isLong ? "▲ BUY" : "▼ SELL", bgcolor=color.new(#000000, 15), text_color=isLong ? color.new(profitColor, 0) : color.new(riskColor, 0), text_size=_panelSz)

        string _statusTxt = _isLocked ? "🔒 FROZEN" : "◉ FOLLOWING"
        color  _statusClr = _isLocked ? color.new(#FFD700, 0) : color.new(profitColor, 0)
        table.cell(_panel, 0, 1, "Mode", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 1, _statusTxt, bgcolor=color.new(#000000, 40), text_color=_statusClr, text_size=_panelSz)

        table.cell(_panel, 0, 2, "Entry", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 2, str.tostring(entry, format.mintick), bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz)

        table.cell(_panel, 0, 3, "You Risk", bgcolor=color.new(#000000, 40), text_color=color.new(riskColor, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 3, na(riskDollars) ? "—" : "-$" + str.tostring(riskDollars, "#.##"), bgcolor=color.new(#000000, 40), text_color=color.new(riskColor, 0), text_size=_panelSz)

        table.cell(_panel, 0, 4, "You Make", bgcolor=color.new(#000000, 40), text_color=color.new(profitColor, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 4, na(profitDollars) ? "—" : "+$" + str.tostring(profitDollars, "#.##"), bgcolor=color.new(#000000, 40), text_color=color.new(profitColor, 0), text_size=_panelSz)

        table.cell(_panel, 0, 5, "Risk : Reward", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 5, na(rrRatio) ? "—" : "1 : " + str.tostring(rrRatio, "#.##"), bgcolor=color.new(#000000, 40), text_color=na(rrRatio) ? color.new(#FFFFFF,0) : rrRatio >= 2 ? color.new(profitColor,0) : rrRatio >= 1 ? color.new(#FFD700,0) : color.new(riskColor,0), text_size=_panelSz)

        table.cell(_panel, 0, 6, "Stop Distance", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 6, na(slPoints) ? "—" : str.tostring(slPoints, "#.##") + " pts", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz)

        table.cell(_panel, 0, 7, "Contracts", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 7, str.tostring(lots, "#.##") + " @ $" + str.tostring(pointValue, "#.##") + "/pt", bgcolor=color.new(#000000, 40), text_color=color.new(#FFFFFF, 0), text_size=_panelSz)

        string _acctTxt = (accountSize > 0 and not na(riskDollars)) ? str.tostring(riskDollars / accountSize * 100, "#.##") + "% of acct" : "add account size"
        table.cell(_panel, 0, 8, "% of Account", bgcolor=color.new(#000000, 15), text_color=color.new(#FFFFFF, 0), text_size=_panelSz, text_halign=text.align_left)
        table.cell(_panel, 1, 8, _acctTxt, bgcolor=color.new(#000000, 15), text_color=(accountSize > 0 and not na(riskDollars) and riskDollars/accountSize*100 > 2) ? color.new(riskColor,0) : color.new(#FFFFFF, 0), text_size=_panelSz)
//─────────────────────────────────────────────────────────────────────────────
````
