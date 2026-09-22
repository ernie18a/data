<!-- tradingview-pine-id: PUB;47da90a78579436d9b900f6af1da4429 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sniper Risk V4

Source: https://www.tradingview.com/script/BwAeqNAS-Sniper-Risk/

## Description

Sniper Risk V4 is a manual trade planner, not a signal tool: click an entry and a stop on the chart and it detects long or short, projects up to six take-profit levels at your chosen R multiples (1R = the entry-to-stop distance; TP = entry ± R x that distance), and sizes the position as lots = (account x risk %) / (stop distance x contract size x currency conversion rate). 

It also shows the cash lost at the stop, the cash banked at each target according to the % you plan to close there, and the blended R if all targets are hit. Drag either level and everything recalculates; use "Reset points" for a new trade, "Only on symbol" to keep a plan on its own chart, and add the indicator again for a second trade. Optional alerts fire once per level at bar close when the bar's high/low touches it. Unlike TradingView's built-in Long/Short Position tools, which plan one target, it combines multi-target scale-out planning, lot sizing with contract-size presets and account-currency conversion, and per-level alerts, all derived from the single stop distance so they stay consistent. 

Limitations: it is only a calculator with no broker connection. Lines and zones set to "Full line" or "Start N bars back" are drawn over past bars purely visually and are not historical signals. Auto contract size is wrong on most gold, silver and index CFDs (the lot size can be 100 times too large), so set your broker's value and check the "Risk per 1 lot" row. The conversion rate is TradingView's and falls back to 1.0 if unavailable. Spread, commission, swap and slippage are ignored and lots are not rounded to your broker's step. A touch on the chart is not a broker fill. Alerts do not track the trade (a TP alert can fire after the stop was hit), can already be armed if price touched your entry level within the lookback window before you placed the plan, and keep the old levels until you recreate them. Not financial advice.

---

## Source Code

````pine
//@version=6
// ============================================================
// Script Name  : Sniper R-Multiple TP Planner
// Version      : 4.0
// Author       : Sniper Trading
// Description  : Click an entry and a stop-loss level on the chart and the
//                script projects up to six take-profit levels at your chosen
//                R multiples, sizes the position from account equity and
//                risk %, and shows the cash risk and stop distance live above
//                the stop line as you drag.
// Timeframe    : Any (levels are price-based)
// Asset class  : Forex, Metals, Crypto, Futures, Indices, Equities
//
// TO RE-PLACE THE LEVELS FOR A NEW TRADE
//   Right-click the indicator on the chart — or click the "..." beside its
//   name in the chart legend — and choose "RESET POINTS". TradingView then
//   asks you to click Entry and Stop again, exactly like a fresh add.
//   This is a built-in TradingView feature; a script cannot write to its own
//   inputs, so no in-script reset button is possible. Do NOT use
//   Settings -> Defaults -> "Reset settings" for this: it dumps both levels to
//   0, which is off-screen and leaves nothing to grab.
//
// v3 changes   : Per-role line style — Entry, SL, TP, TP zones and the risk
//                zone each get their own extent, dash style, width and colour ·
//                back to a single setup (add the indicator again for a second
//                trade) · symbol filter kept · "Pause plan" switch.
// ============================================================

indicator(
     title            = "Sniper Risk V4",
     shorttitle       = "Sniper Risk",
     overlay          = true,
     max_boxes_count  = 100,
     max_lines_count  = 100,
     max_labels_count = 100)

// ------------------------------------------------------------
// 1. INPUTS
// ------------------------------------------------------------
string G_TRADE = "① Trade Setup"
string G_TP    = "② Take-Profit R Multiples"
string G_SIZE  = "③ Position Sizing"
string G_LINE  = "④ Level Line Style"
string G_VIS   = "⑤ Visuals & Tables"
string G_ALT   = "⑥ Alerts"

string TT_PRICE = "To RE-PLACE this level for a new trade: right-click the indicator on the chart (or the '...' next to its name in the legend) and choose 'Reset points'. TradingView will ask you to click Entry and Stop again, just like a fresh add. You can also simply drag the level, or type a price here."

// --- Trade setup --------------------------------------------------
bool pausePlan = input.bool(false, "Pause plan  (hide everything)", group = G_TRADE,
     tooltip = "Blanks the tool without touching your levels — useful when you are flat. Untick to bring the same plan back.")
string symFilter = input.string("", "Only on symbol", group = G_TRADE,
     tooltip = "Blank = draws on every chart. Otherwise type the symbol this plan belongs to, e.g. XAUUSD, BTCUSD, EURUSD, and it stays hidden on every other chart. Matching ignores the exchange prefix, so 'XAUUSD' also matches 'OANDA:XAUUSD'.")
float inEntry = input.price(0.0, "Entry price", group = G_TRADE, confirm = true, tooltip = TT_PRICE)
float inStop  = input.price(0.0, "Stop loss",   group = G_TRADE, confirm = true, tooltip = TT_PRICE)

// --- TP R multiples -----------------------------------------------
bool  tp1On = input.bool(true,  "TP 1", inline = "tp1", group = G_TP)
float tp1R  = input.float(0.7,  "R",     inline = "tp1", minval = 0.05, maxval = 100, step = 0.05, group = G_TP)
float tp1A  = input.float(25.0, "% out", inline = "tp1", minval = 0, maxval = 100, step = 5, group = G_TP)

bool  tp2On = input.bool(true,  "TP 2", inline = "tp2", group = G_TP)
float tp2R  = input.float(1.0,  "R",     inline = "tp2", minval = 0.05, maxval = 100, step = 0.05, group = G_TP)
float tp2A  = input.float(25.0, "% out", inline = "tp2", minval = 0, maxval = 100, step = 5, group = G_TP)

bool  tp3On = input.bool(true,  "TP 3", inline = "tp3", group = G_TP)
float tp3R  = input.float(2.0,  "R",     inline = "tp3", minval = 0.05, maxval = 100, step = 0.05, group = G_TP)
float tp3A  = input.float(25.0, "% out", inline = "tp3", minval = 0, maxval = 100, step = 5, group = G_TP)

bool  tp4On = input.bool(true,  "TP 4", inline = "tp4", group = G_TP)
float tp4R  = input.float(3.0,  "R",     inline = "tp4", minval = 0.05, maxval = 100, step = 0.05, group = G_TP)
float tp4A  = input.float(25.0, "% out", inline = "tp4", minval = 0, maxval = 100, step = 5, group = G_TP)

bool  tp5On = input.bool(false, "TP 5", inline = "tp5", group = G_TP)
float tp5R  = input.float(4.0,  "R",     inline = "tp5", minval = 0.05, maxval = 100, step = 0.05, group = G_TP)
float tp5A  = input.float(0.0,  "% out", inline = "tp5", minval = 0, maxval = 100, step = 5, group = G_TP)

bool  tp6On = input.bool(false, "TP 6", inline = "tp6", group = G_TP)
float tp6R  = input.float(5.0,  "R",     inline = "tp6", minval = 0.05, maxval = 100, step = 0.05, group = G_TP)
float tp6A  = input.float(0.0,  "% out", inline = "tp6", minval = 0, maxval = 100, step = 5, group = G_TP)

// --- Position sizing ----------------------------------------------
float  acctSize = input.float(10000.0, "Account size", minval = 0, step = 100, group = G_SIZE)
string acctCur  = input.string("USD", "Account currency",
     options = ["USD","EUR","GBP","CHF","JPY","AUD","CAD","NZD","MXN","COP","BRL"], group = G_SIZE)
float  riskPct  = input.float(1.0, "Risk per trade (%)", minval = 0.01, maxval = 100, step = 0.05, group = G_SIZE)

string csPreset = input.string("Auto (detect from symbol)", "Contract size", group = G_SIZE,
     options = [
     "Auto (detect from symbol)",
     "Forex standard lot — 100,000",
     "Forex mini lot — 10,000",
     "Forex micro lot — 1,000",
     "Gold XAUUSD — 100 oz",
     "Silver XAGUSD — 5,000 oz",
     "Crypto — 1 coin",
     "Index / point-value 1",
     "Custom — use value below"],
     tooltip = "Cash value of a 1.00 price move on one lot/contract. Auto reads syminfo.pointvalue, which is right for spot FX and futures but returns 1 for most gold and index CFDs — on a gold CFD that under-states risk by 100x. When in doubt pick Custom and copy the number from your broker's contract specs.")
float csCustom = input.float(1.0, "Custom contract size", minval = 0.000001, step = 1, group = G_SIZE)

bool  autoFx   = input.bool(true, "Auto FX conversion to account currency", group = G_SIZE)
float manualFx = input.float(1.0, "Manual conversion rate", minval = 0.000001, step = 0.01, group = G_SIZE)

float pipOverride = input.float(0.0, "Pip / point size override", minval = 0, step = 0.00001, group = G_SIZE,
     tooltip = "0 = auto: 0.0001 on FX (0.01 on JPY pairs), and 1.0 everywhere else, so a $5 gold stop reads as 5 points. Set it only for an instrument your broker quotes unusually.")

// --- Level line style: one row per price role ----------------------
// Row layout is  <role>  [ extent ] [ dash ] [ px ] [ colour ]
string EX_TT = "Segment = a fixed-width block beside price.  Ray = starts at the current bar and runs right forever.  Full line = spans the whole chart.  Hidden = do not draw this level."

string exEntry = input.string("Segment", "Entry", options = ["Segment","Ray →","Full line","Hidden"], inline = "le", group = G_LINE, tooltip = EX_TT)
string dsEntry = input.string("Solid", "", options = ["Solid","Dashed","Dotted"], inline = "le", group = G_LINE)
int    wEntry  = input.int(2, "", minval = 1, maxval = 4, inline = "le", group = G_LINE)
color  cEntry  = input.color(#b2b5be, "", inline = "le", group = G_LINE)

string exSl = input.string("Segment", "SL   ", options = ["Segment","Ray →","Full line","Hidden"], inline = "ls", group = G_LINE)
string dsSl = input.string("Solid", "", options = ["Solid","Dashed","Dotted"], inline = "ls", group = G_LINE)
int    wSl  = input.int(2, "", minval = 1, maxval = 4, inline = "ls", group = G_LINE)
color  cSl  = input.color(#f23645, "", inline = "ls", group = G_LINE)

string exTp = input.string("Segment", "TP   ", options = ["Segment","Ray →","Full line","Hidden"], inline = "lt", group = G_LINE)
string dsTp = input.string("Dashed", "", options = ["Solid","Dashed","Dotted"], inline = "lt", group = G_LINE)
int    wTp  = input.int(1, "", minval = 1, maxval = 4, inline = "lt", group = G_LINE)
color  cTp  = input.color(#089981, "", inline = "lt", group = G_LINE)

string exZtp = input.string("Segment", "TP zones  ", options = ["Segment","Ray →","Full line","Hidden"], inline = "z1", group = G_LINE,
     tooltip = "Shaded blocks between the levels. Set to Hidden for a clean line-only look, or when using Full line, which otherwise tints the whole chart history.")
color  cZtp  = input.color(color.new(#089981, 80), "", inline = "z1", group = G_LINE)

string exZsl = input.string("Segment", "Risk zone", options = ["Segment","Ray →","Full line","Hidden"], inline = "z2", group = G_LINE)
color  cZsl  = input.color(color.new(#f23645, 80), "", inline = "z2", group = G_LINE)

bool showTags = input.bool(true, "Show levels in the price scale", group = G_LINE,
     tooltip = "Axis tags for entry, SL and each active TP. If nothing appears, switch on chart Settings → Scales → 'Indicators and financials value labels'.")

// --- Visuals & tables ---------------------------------------------
bool showLbls   = input.bool(true, "Level labels", group = G_VIS)
bool showSlInfo = input.bool(true, "Risk readout above SL line", group = G_VIS,
     tooltip = "Stop distance in pips/points, position size in lots and cash at risk, floating above the stop line. Recomputes as you drag the entry or the stop.")
string slInfoAt = input.string("Left", "Risk readout side", options = ["Left","Right"], group = G_VIS)
bool showTblPos = input.bool(true, "Position-plan table", group = G_VIS)
bool showTblTp  = input.bool(true, "TP / P&L table", group = G_VIS)

int boxBack = input.int(0,  "Start N bars back", minval = 0, maxval = 500, group = G_VIS)
int boxFwd  = input.int(40, "Width / label offset (bars right)", minval = 5, maxval = 500, group = G_VIS,
     tooltip = "Sets the drawn width in Segment mode. In Ray and Full-line mode the lines run past this point, but it still decides where the labels sit.")

string lblSize = input.string("normal", "Label size", options = ["tiny","small","normal","large"], group = G_VIS)
// Two tables may never share an anchor — TradingView renders only one of them.
string tblPos  = input.string("Top right", "Plan table position",
     options = ["Top right","Middle right","Top left","Middle left","Bottom left"], group = G_VIS)
string tblPos2 = input.string("Bottom right", "TP table position",
     options = ["Bottom right","Bottom center","Top center"], group = G_VIS)

// --- Alerts -------------------------------------------------------
bool alertsOn    = input.bool(true, "Fire dynamic alert() calls", group = G_ALT,
     tooltip = "One alert per event, once only. Create the alert in TradingView with condition = this indicator, then 'Any alert() function call'.")
bool requireFill = input.bool(true, "Only alert on TP/SL after entry is touched", group = G_ALT)
int  fillWindow  = input.int(500, "Entry-fill lookback (bars)", minval = 1, maxval = 5000, group = G_ALT,
     tooltip = "How far back a touch of the entry level still counts as 'filled'. Without this window, any price your entry level happened to cross months ago would arm the TP and SL alerts permanently and the switch above would do nothing. 500 bars is about three weeks on a 1H chart.")

// ------------------------------------------------------------
// 2. HELPERS
// ------------------------------------------------------------
fmt(p)  => str.tostring(p, format.mintick)
cash(v) => str.tostring(v, "#,###.##")

normSym(s) => str.replace_all(str.upper(s), " ", "")

// Blank filter = every chart. Otherwise substring match on the full ticker id,
// so "XAUUSD" matches "OANDA:XAUUSD" and the user need not know the prefix.
symMatch(s) =>
    string t = str.trim(s)
    str.length(t) == 0 or str.contains(normSym(syminfo.tickerid), normSym(t))

// Per-role extent and visibility
extOf(s) =>
    switch s
        "Ray →"     => extend.right
        "Full line" => extend.both
        => extend.none

vis(s) => s != "Hidden"

dash(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

lblSizeVal = switch lblSize
    "tiny"  => size.tiny
    "small" => size.small
    "large" => size.large
    => size.normal

posVal = switch tblPos
    "Top right"    => position.top_right
    "Middle right" => position.middle_right
    "Top left"     => position.top_left
    "Middle left"  => position.middle_left
    => position.bottom_left

posVal2 = switch tblPos2
    "Bottom center" => position.bottom_center
    "Top center"    => position.top_center
    => position.bottom_right

// ------------------------------------------------------------
// 3. TRADE PARAMETERS
// ------------------------------------------------------------
float entryPx = inEntry
float stopPx  = inStop

bool levelsSet = entryPx > 0 and stopPx > 0 and entryPx != stopPx
bool haveSetup = levelsSet and not pausePlan and symMatch(symFilter)

bool  isLong   = entryPx > stopPx
float riskDist = haveSetup ? math.abs(entryPx - stopPx) : na

lvl(r) => haveSetup ? (isLong ? entryPx + r * riskDist : entryPx - r * riskDist) : float(na)

float tp1 = lvl(tp1R)
float tp2 = lvl(tp2R)
float tp3 = lvl(tp3R)
float tp4 = lvl(tp4R)
float tp5 = lvl(tp5R)
float tp6 = lvl(tp6R)

// ------------------------------------------------------------
// 4. POSITION SIZING
// ------------------------------------------------------------
bool isFx = syminfo.type == "forex"

// Auto guess: right for spot FX and futures (pointvalue is the real multiplier:
// NQ 20, GC 100, MGC 10). Returns 1 for most CFDs — the preset list exists for that.
float csAuto = isFx ? 100000.0 : nz(syminfo.pointvalue, 1.0)

float contractSize = switch csPreset
    "Forex standard lot — 100,000" => 100000.0
    "Forex mini lot — 10,000"      => 10000.0
    "Forex micro lot — 1,000"      => 1000.0
    "Gold XAUUSD — 100 oz"         => 100.0
    "Silver XAGUSD — 5,000 oz"     => 5000.0
    "Crypto — 1 coin"              => 1.0
    "Index / point-value 1"        => 1.0
    "Custom — use value below"     => csCustom
    => csAuto

// ignore_invalid_currency = true is essential: without it an unsupported pair
// (USDT, exotic legs) raises a runtime error and halts the whole script.
float autoRate = nz(request.currency_rate(syminfo.currency, acctCur, ignore_invalid_currency = true), 1.0)
float fxRate   = autoFx ? autoRate : manualFx

// Core sizing identity:
//   risk per 1 lot = stop distance x contract size x FX rate   (account ccy)
//   lots           = cash you are willing to lose / risk per lot
float riskCash   = acctSize * riskPct / 100.0
float riskPerLot = haveSetup ? riskDist * contractSize * fxRate : na
float lots       = (not na(riskPerLot) and riskPerLot > 0) ? riskCash / riskPerLot : na
float qtyUnits   = na(lots) ? na : lots * contractSize

// A pip is 0.0001 on FX, 0.01 on JPY-quoted FX — by definition, not by feed
// digits, so this is right on both 4-digit and 5-digit feeds. Everywhere else a
// "point" is one full price unit: a $5 stop on gold is 5 points, not 500 ticks.
float pipAuto = isFx ? (syminfo.currency == "JPY" ? 0.01 : 0.0001) : 1.0
float pipSize = pipOverride > 0 ? pipOverride : pipAuto

string distUnit  = isFx ? "pips" : "pts"
float  riskDistU = haveSetup and pipSize > 0 ? riskDist / pipSize : na

string unitWord = switch csPreset
    "Gold XAUUSD — 100 oz"     => "oz"
    "Silver XAGUSD — 5,000 oz" => "oz"
    "Crypto — 1 coin"          => "coins"
    => "units"

// ------------------------------------------------------------
// 5. PARTIAL-EXIT MATH
// ------------------------------------------------------------
array<float> arrR   = array.from(tp1R,  tp2R,  tp3R,  tp4R,  tp5R,  tp6R)
array<float> arrA   = array.from(tp1A,  tp2A,  tp3A,  tp4A,  tp5A,  tp6A)
array<bool>  arrOn  = array.from(tp1On, tp2On, tp3On, tp4On, tp5On, tp6On)
array<float> arrLvl = array.from(tp1,   tp2,   tp3,   tp4,   tp5,   tp6)

float allocSum = 0.0
float blendedR = 0.0
for i = 0 to 5
    if array.get(arrOn, i)
        allocSum := allocSum + array.get(arrA, i)
        blendedR := blendedR + array.get(arrA, i) / 100.0 * array.get(arrR, i)

float blendedCash = riskCash * blendedR

// ------------------------------------------------------------
// 6. DRAWING
// ------------------------------------------------------------
var array<box>   gBoxes  = array.new<box>()
var array<line>  gLines  = array.new<line>()
var array<label> gLabels = array.new<label>()

clearDraw() =>
    while array.size(gBoxes) > 0
        box.delete(array.pop(gBoxes))
    while array.size(gLines) > 0
        line.delete(array.pop(gLines))
    while array.size(gLabels) > 0
        label.delete(array.pop(gLabels))

if barstate.islast
    clearDraw()

    int xL = math.max(0, bar_index - boxBack)   // guard short-history charts
    int xR = bar_index + boxFwd

    if haveSetup
        // --- risk zone ---------------------------------------
        if vis(exZsl)
            box rb = box.new(xL, math.max(entryPx, stopPx), xR, math.min(entryPx, stopPx), border_color = color.new(cSl, 45), bgcolor = cZsl, extend = extOf(exZsl))
            array.push(gBoxes, rb)

        // --- TP zones stacked outward from entry -------------
        float prevLvl = entryPx
        for i = 0 to 5
            if array.get(arrOn, i)
                float lv = array.get(arrLvl, i)
                float rv = array.get(arrR, i)
                float av = array.get(arrA, i)

                if vis(exZtp)
                    box tb = box.new(xL, math.max(prevLvl, lv), xR, math.min(prevLvl, lv), border_color = color.new(cTp, 60), bgcolor = cZtp, extend = extOf(exZtp))
                    array.push(gBoxes, tb)

                if vis(exTp)
                    line tl = line.new(xL, lv, xR, lv, color = cTp, width = wTp, style = dash(dsTp), extend = extOf(exTp))
                    array.push(gLines, tl)

                if showLbls
                    string pnl = av > 0 ? "   |   " + str.tostring(av, "#.#") + "% out  →  " + cash(riskCash * rv * av / 100.0) + " " + acctCur : ""
                    string txt = "TP" + str.tostring(i + 1) + "   " + str.tostring(rv, "#.##") + "R   " + fmt(lv) + pnl
                    label tlb = label.new(xR, lv, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cTp, size = lblSizeVal)
                    array.push(gLabels, tlb)

                prevLvl := lv

        // --- entry & stop lines ------------------------------
        if vis(exEntry)
            line el = line.new(xL, entryPx, xR, entryPx, color = cEntry, width = wEntry, style = dash(dsEntry), extend = extOf(exEntry))
            array.push(gLines, el)

        if vis(exSl)
            line sll = line.new(xL, stopPx, xR, stopPx, color = cSl, width = wSl, style = dash(dsSl), extend = extOf(exSl))
            array.push(gLines, sll)

        if showLbls
            string et = "ENTRY   " + fmt(entryPx) + "   (" + (isLong ? "LONG" : "SHORT") + ")"
            label elb = label.new(xR, entryPx, et, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cEntry, size = lblSizeVal)
            label slb = label.new(xR, stopPx, "SL   " + fmt(stopPx), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(color.black, 100), textcolor = cSl, size = lblSizeVal)
            array.push(gLabels, elb)
            array.push(gLabels, slb)

        // --- live risk readout, floating ABOVE the SL line ----
        // label.style_label_down puts the body above the anchor point.
        if showSlInfo
            string l1 = str.tostring(riskDistU, "#.#") + " " + distUnit + " risk"
            string l2 = (na(lots) ? "— lots" : str.tostring(lots, "#,###.####") + " lots") + "   ·   −" + cash(riskCash) + " " + acctCur + "   (" + str.tostring(riskPct, "#.##") + "%)"
            int xi = slInfoAt == "Right" ? xR : xL
            label li = label.new(xi, stopPx, l1 + "\n" + l2, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(#1e222d, 12), textcolor = cSl, size = lblSizeVal, textalign = text.align_left)
            array.push(gLabels, li)

    // --- not configured: say so, and say how to fix it --------
    // input.price handles sit at their literal price, so a level left at 0 is
    // off-screen and ungrabbable. Naming "Reset points" here is the whole fix.
    else if not pausePlan
        string why = levelsSet ? "This plan is filtered to another symbol.\nClear 'Only on symbol' in settings to show it here." : "No levels placed yet.\n\nRight-click the indicator → Reset points\nthen click your Entry, then your Stop."
        label hint = label.new(bar_index, close, "R-TP PLANNER\n\n" + why, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(#1e222d, 12), textcolor = #d1d4dc, size = size.small, textalign = text.align_left)
        array.push(gLabels, hint)

// ------------------------------------------------------------
// 7. PRICE-SCALE TAGS  (plot() must be at global scope)
// ------------------------------------------------------------
// display.price_scale keeps these OUT of the chart pane, so nothing is drawn
// twice over the lines and the pane's autoscale is untouched.
tagOk(on, v) => showTags and haveSetup and on ? v : na

plot(tagOk(vis(exEntry), entryPx), "Entry tag", color = cEntry, display = display.price_scale, editable = false)
plot(tagOk(vis(exSl),    stopPx),  "SL tag",    color = cSl,    display = display.price_scale, editable = false)
plot(tagOk(tp1On, tp1), "TP1 tag", color = cTp, display = display.price_scale, editable = false)
plot(tagOk(tp2On, tp2), "TP2 tag", color = cTp, display = display.price_scale, editable = false)
plot(tagOk(tp3On, tp3), "TP3 tag", color = cTp, display = display.price_scale, editable = false)
plot(tagOk(tp4On, tp4), "TP4 tag", color = cTp, display = display.price_scale, editable = false)
plot(tagOk(tp5On, tp5), "TP5 tag", color = cTp, display = display.price_scale, editable = false)
plot(tagOk(tp6On, tp6), "TP6 tag", color = cTp, display = display.price_scale, editable = false)

// ------------------------------------------------------------
// 8. TABLES
// ------------------------------------------------------------
color cHdrBg = color.new(#2a2e39, 10)
color cRowBg = color.new(#131722, 15)
color cTxt   = #d1d4dc
color cMuted = #787b86
color cWarn  = #f7931a

var table tPos = table.new(posVal, 2, 13, border_width = 1, frame_width = 1, frame_color = color.new(#787b86, 55), border_color = color.new(#787b86, 70))
var table tTp  = table.new(posVal2, 5, 9, border_width = 1, frame_width = 1, frame_color = color.new(#787b86, 55), border_color = color.new(#787b86, 70))

kvRow(t, r, k, v, vc) =>
    table.cell(t, 0, r, k, text_color = cMuted, text_size = size.small, text_halign = text.align_left,  bgcolor = cRowBg)
    table.cell(t, 1, r, v, text_color = vc,     text_size = size.small, text_halign = text.align_right, bgcolor = cRowBg)

if barstate.islast
    if showTblPos
        table.cell(tPos, 0, 0, "POSITION PLAN", text_color = cTxt, text_size = size.small, text_halign = text.align_left, bgcolor = cHdrBg)
        table.cell(tPos, 1, 0, haveSetup ? (isLong ? "LONG" : "SHORT") : (pausePlan ? "PAUSED" : "NOT SET"), text_color = haveSetup ? (isLong ? cTp : cSl) : cMuted, text_size = size.small, text_halign = text.align_right, bgcolor = cHdrBg)

        kvRow(tPos, 1,  "Entry",          haveSetup ? fmt(entryPx) : "—", cEntry)
        kvRow(tPos, 2,  "Stop loss",      haveSetup ? fmt(stopPx)  : "—", cSl)
        kvRow(tPos, 3,  "Stop distance",  haveSetup ? str.tostring(riskDistU, "#.#") + " " + distUnit : "—", cTxt)
        kvRow(tPos, 4,  "Account",        cash(acctSize) + " " + acctCur, cTxt)
        kvRow(tPos, 5,  "Risk %",         str.tostring(riskPct, "#.##") + " %", cTxt)
        kvRow(tPos, 6,  "Risk (1R)",      cash(riskCash) + " " + acctCur, cSl)
        kvRow(tPos, 7,  "Contract size",  str.tostring(contractSize, "#,###.##"), cTxt)
        kvRow(tPos, 8,  "Risk per 1 lot", na(riskPerLot) ? "—" : cash(riskPerLot) + " " + acctCur, cWarn)
        kvRow(tPos, 9,  "Size (lots)",    na(lots) ? "—" : str.tostring(lots, "#,###.####"), cTp)
        kvRow(tPos, 10, "Notional (" + unitWord + ")", na(qtyUnits) ? "—" : cash(qtyUnits), cMuted)
        kvRow(tPos, 11, "FX → " + acctCur, str.tostring(fxRate, "#.#####"), cMuted)
        kvRow(tPos, 12, "Allocated",      str.tostring(allocSum, "#.#") + " %", math.abs(allocSum - 100.0) < 0.01 ? cTp : cWarn)

    if showTblTp
        table.cell(tTp, 0, 0, "TP",    text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 1, 0, "R",     text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 2, 0, "Price", text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 3, 0, "% out", text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 4, 0, "P&L " + acctCur, text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)

        for i = 0 to 5
            int r = i + 1
            bool on = array.get(arrOn, i)
            color tc = on ? cTxt : color.new(cMuted, 50)
            table.cell(tTp, 0, r, "TP" + str.tostring(i + 1), text_color = tc, text_size = size.tiny, bgcolor = cRowBg)
            table.cell(tTp, 1, r, str.tostring(array.get(arrR, i), "#.##"), text_color = tc, text_size = size.tiny, bgcolor = cRowBg)
            table.cell(tTp, 2, r, haveSetup ? fmt(array.get(arrLvl, i)) : "—", text_color = tc, text_size = size.tiny, bgcolor = cRowBg)
            table.cell(tTp, 3, r, str.tostring(array.get(arrA, i), "#.#") + "%", text_color = tc, text_size = size.tiny, bgcolor = cRowBg)
            table.cell(tTp, 4, r, on ? cash(riskCash * array.get(arrR, i) * array.get(arrA, i) / 100.0) : "—", text_color = on ? cTp : color.new(cMuted, 50), text_size = size.tiny, bgcolor = cRowBg)

        table.cell(tTp, 0, 7, "ALL HIT", text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 1, 7, str.tostring(blendedR, "#.##") + "R", text_color = cTp, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 2, 7, "", bgcolor = cHdrBg)
        table.cell(tTp, 3, 7, str.tostring(allocSum, "#.#") + "%", text_color = math.abs(allocSum - 100.0) < 0.01 ? cTxt : cWarn, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 4, 7, cash(blendedCash), text_color = cTp, text_size = size.tiny, bgcolor = cHdrBg)

        table.cell(tTp, 0, 8, "SL HIT", text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 1, 8, "−1.00R", text_color = cSl, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 2, 8, "", bgcolor = cHdrBg)
        table.cell(tTp, 3, 8, "100%", text_color = cTxt, text_size = size.tiny, bgcolor = cHdrBg)
        table.cell(tTp, 4, 8, "−" + cash(riskCash), text_color = cSl, text_size = size.tiny, bgcolor = cHdrBg)

// ------------------------------------------------------------
// 9. EVENT DETECTION
// ------------------------------------------------------------
// "Touched" = the bar's range reached the level in the trade direction.
touched(lvlPx) =>
    bool res = false
    if haveSetup and not na(lvlPx)
        res := isLong ? high >= lvlPx : low <= lvlPx
    res

bool entryTouch = haveSetup and high >= entryPx and low <= entryPx

// Entry-FILL latch. It must look at history — a trade filled before the chart
// went live, or before the last reload, still needs to be armed — but only
// within a recent window. Scanning all history would latch on some bar years
// ago that happened to cross this price, permanently arming the alerts and
// making the switch above meaningless.
var bool filled = false
if entryTouch and bar_index >= last_bar_index - fillWindow
    filled := true

bool armed = not requireFill or filled

bool slTouch = haveSetup and armed and (isLong ? low <= stopPx : high >= stopPx)
bool tp1Hit  = tp1On and armed and touched(tp1)
bool tp2Hit  = tp2On and armed and touched(tp2)
bool tp3Hit  = tp3On and armed and touched(tp3)
bool tp4Hit  = tp4On and armed and touched(tp4)
bool tp5Hit  = tp5On and armed and touched(tp5)
bool tp6Hit  = tp6On and armed and touched(tp6)

// ------------------------------------------------------------
// 10. ALERTS
// ------------------------------------------------------------
// One-shot ALERT latches, separate from the fill latch above. These run on
// real-time confirmed bars only, so history never pre-trips them.
var bool fEntry = false
var bool fSl    = false
var bool f1     = false
var bool f2     = false
var bool f3     = false
var bool f4     = false
var bool f5     = false
var bool f6     = false

fire(msg) =>
    if alertsOn
        alert(msg, alert.freq_once_per_bar_close)

string tag = syminfo.ticker + " " + timeframe.period + " — "

if barstate.isrealtime and barstate.isconfirmed and haveSetup
    if entryTouch and not fEntry
        fEntry := true
        fire(tag + "ENTRY touched @ " + fmt(entryPx) + " (" + (isLong ? "LONG" : "SHORT") + ")")
    if slTouch and not fSl
        fSl := true
        fire(tag + "STOP LOSS hit @ " + fmt(stopPx) + "  (−1R, −" + cash(riskCash) + " " + acctCur + ")")
    if tp1Hit and not f1
        f1 := true
        fire(tag + "TP1 hit @ " + fmt(tp1) + "  (" + str.tostring(tp1R, "#.##") + "R)")
    if tp2Hit and not f2
        f2 := true
        fire(tag + "TP2 hit @ " + fmt(tp2) + "  (" + str.tostring(tp2R, "#.##") + "R)")
    if tp3Hit and not f3
        f3 := true
        fire(tag + "TP3 hit @ " + fmt(tp3) + "  (" + str.tostring(tp3R, "#.##") + "R)")
    if tp4Hit and not f4
        f4 := true
        fire(tag + "TP4 hit @ " + fmt(tp4) + "  (" + str.tostring(tp4R, "#.##") + "R)")
    if tp5Hit and not f5
        f5 := true
        fire(tag + "TP5 hit @ " + fmt(tp5) + "  (" + str.tostring(tp5R, "#.##") + "R)")
    if tp6Hit and not f6
        f6 := true
        fire(tag + "TP6 hit @ " + fmt(tp6) + "  (" + str.tostring(tp6R, "#.##") + "R)")

// Static alertcondition entries (appear in the TradingView alert dialog)
alertcondition(entryTouch, "Entry touched", "{{ticker}} {{interval}} — Entry level touched @ {{close}}")
alertcondition(slTouch,    "Stop loss hit", "{{ticker}} {{interval}} — STOP LOSS hit @ {{close}}")
alertcondition(tp1Hit,     "TP1 hit",       "{{ticker}} {{interval}} — TP1 reached @ {{close}}")
alertcondition(tp2Hit,     "TP2 hit",       "{{ticker}} {{interval}} — TP2 reached @ {{close}}")
alertcondition(tp3Hit,     "TP3 hit",       "{{ticker}} {{interval}} — TP3 reached @ {{close}}")
alertcondition(tp4Hit,     "TP4 hit",       "{{ticker}} {{interval}} — TP4 reached @ {{close}}")
alertcondition(tp5Hit,     "TP5 hit",       "{{ticker}} {{interval}} — TP5 reached @ {{close}}")
alertcondition(tp6Hit,     "TP6 hit",       "{{ticker}} {{interval}} — TP6 reached @ {{close}}")
alertcondition(tp1Hit or tp2Hit or tp3Hit or tp4Hit or tp5Hit or tp6Hit, "Any TP hit", "{{ticker}} {{interval}} — A take-profit level was reached @ {{close}}")

// ============================================================
// NOTES & WARNINGS
// ------------------------------------------------------------
// RESETTING THE LEVELS
//   Right-click the indicator on the chart, or click "..." beside its name in
//   the chart legend, and choose "Reset points". TradingView re-runs the
//   click-to-place flow: click Entry, then click Stop. That is the reset
//   button, and it is TradingView's own — a Pine script cannot write to its
//   own inputs, so an in-script reset is not possible at any price.
//   Avoid Settings -> Defaults -> "Reset settings": it sets both levels to 0,
//   which is off the visible scale, leaving two handles you cannot grab.
//   "Pause plan" is the soft alternative — it blanks the tool while keeping
//   your levels, for when you are flat.
//
// SEVERAL TRADES AT ONCE
//   Add the indicator a second and third time; each copy keeps its own levels,
//   sizing and styling. Set "Only on symbol" on each copy so a plan stays
//   hidden on charts it does not belong to — TradingView stores indicator
//   settings per chart, not per symbol, so without the filter a gold plan
//   follows you onto BTC with gold's prices still in it.
//
// LINE STYLE
//   Entry, SL, TP, TP zones and the risk zone each have their own row:
//   extent (Segment / Ray / Full line / Hidden), dash style, width and colour.
//   Hidden replaces the old show/hide toggles. "Width / label offset" still
//   places the labels in Ray and Full-line mode. Set the zones to Hidden, or
//   to Segment, when the lines are Full line — otherwise the shading tints the
//   whole chart history.
//
// Repainting : No. Levels come from static user inputs plus the current bar's
//              OHLC. Drawings are rebuilt on the last bar only, which is normal
//              for a planning tool and never alters historical values.
// Lookahead  : None. The single request.* call is request.currency_rate(),
//              used only to express P&L in the account currency.
// Direction  : Inferred — stop below entry = LONG, stop above entry = SHORT.
// Sizing     : riskPerLot = |entry − SL| x contractSize x fxRate
//              lots       = (account x risk%) / riskPerLot
//              CONTRACT SIZE IS THE INPUT THAT MATTERS: FX 100,000 · Gold 100
//              oz · Silver 5,000 oz · Bitcoin 1 · index CFD 1 ($1 per point) ·
//              NQ 20 · MNQ 2 · GC 100 · MGC 10. "Auto" reads
//              syminfo.pointvalue, correct for spot FX and futures but 1 for
//              most CFDs — on a gold CFD that under-states risk 100x.
//              Sanity check before every trade: the "Risk per 1 lot" row should
//              match what your platform quotes for a 1-lot position with that
//              stop. If it does not, the contract size is wrong.
// Distance   : Shown in pips on FX (0.0001, or 0.01 on JPY pairs — by
//              definition, so 4-digit and 5-digit feeds both read correctly)
//              and in points elsewhere, where a point is one full price unit:
//              a $5.00 gold stop reads 5.0 pts, not 500 ticks.
// Alerts     : "Touched" = the bar's high/low reached the level; on high
//              timeframes a wick touch may not equal a real fill. Two latch
//              sets, deliberately different. The entry-FILL latch looks back
//              over history — a trade filled before the chart went live still
//              needs arming — but only within "Entry-fill lookback (bars)";
//              unbounded, it would latch on some bar years ago that crossed
//              this price and the require-fill switch would do nothing. The
//              one-shot ALERT latch runs on real-time bars only, so history
//              never pre-trips it. One-shot applies to the alert() path; an
//              alertcondition() stays true on every bar the level is being
//              touched — use TradingView's "Once per bar" there.
// Tables     : The two tables must sit at different anchors; TradingView
//              renders only one table per position, so the option lists are
//              deliberately non-overlapping.
// Budget     : 8 price-scale plots (x2 for series colour) + 9 alertcondition
//              = 25 of TradingView's 64-plot limit.
// Known issue: If the quote currency has no conversion pair,
//              request.currency_rate() returns na (it will not halt the script)
//              and fxRate falls back to 1.0 — switch off "Auto FX conversion"
//              and enter the rate manually.
// ============================================================
````
