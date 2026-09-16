<!-- tradingview-pine-id: PUB;c8c744d74dc549018b713dc457a9fcd2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Matrix Risk/Reward

Source: https://www.tradingview.com/script/CIHwDH7D-Matrix-Risk-Reward/

## Description

Matrix Risk/Reward is a visual trade-planning overlay. Click three points on the chart (entry, stop, target), then drag them. The script converts those prices into dollar risk, dollar reward, tick distance, risk/reward ratio, and live open P&L for the size you set.

It does not read your broker or prop-firm order ticket, and it does not place, modify, or cancel orders. The three points are planning levels you control.

HOW TO USE

1. Add the indicator to the chart.
2. Click Entry, then Stop, then Target.
3. Set Size to your contracts, lots, or units.
4. Click the indicator on the chart so the three points light up, then drag those points, not the dashed rays.
5. Read dollar SL/TP on the labels and in the table.

Direction is detected automatically: stop below entry = long, stop above entry = short. Stop and target must sit on opposite sides of entry for a valid R:R.

WHAT IT SHOWS

- Stop loss in dollars and ticks
- Take profit in dollars and ticks
- Open P&L in dollars
- Reward-to-risk ratio
- Dollars per tick
- Bid / ask / spread when a quote mode is active
- Colored risk and reward zones

OPEN P&L QUOTE

Last +/- spread (default, all plans): bid = last minus half spread, ask = last plus half spread. Longs mark to bid. Shorts mark to ask. Set Spread (ticks) to your market (1 is typical for MES, MNQ, ES, NQ).

Last price: uses the chart close only.

1-tick bid/ask (Ultimate): uses live 1-tick bid and ask. Requires a TradingView Ultimate plan. If those quotes are missing, it falls back to Last +/- spread.

POINT VALUE

Dollar math is price move x point value x size.

Leave Point value override at 0 to auto-detect common futures (MNQ 2, MES 5, NQ 20, ES 50, YM 5, RTY 50, GC 100, MGC 10, CL 1000, MCL 100, MYM 0.5, M2K 0.5). For other symbols the script uses the chart's built-in point value. If dollars look wrong, set the override yourself.

SETTINGS

Position: Size, point value override, open P&L quote mode, spread in ticks.
Levels: Draggable entry, stop, and target.
Display: Table, zone colors, and zone transparency.

NOTES

This is a calculator overlay, not a strategy and not a broker bridge.
If you want the dollars to match a live ticket, drag this tool onto those prices.
1-tick bid/ask is optional. Leave the default quote mode on unless you have Ultimate.
Not financial advice. Size, point value, and spread must match the instrument you are trading.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ICT_Made

//@version=6
indicator("Matrix Risk/Reward", overlay = true, max_labels_count = 10, max_boxes_count = 5, max_lines_count = 10)

// ── Position
string grpPos = "Position"
float qty  = input.float(1.0, "Size (contracts / lots / units)", minval = 0.0001, step = 0.01, tooltip = "Saved in this chart's indicator settings.", group = grpPos)
float ptOv = input.float(0.0, "Point value override (0 = auto)", minval = 0.0, step = 0.01, tooltip = "Leave 0 for auto. MNQ=2, MES=5, NQ=20, ES=50, GC=100, MCL=100.", group = grpPos)
string quoteMode = input.string("Last ± spread", "Open P&L quote", options = ["Last price", "Last ± spread", "1-tick bid/ask (Ultimate)"], tooltip = "Last ± spread works on all plans: bid = last - half spread, ask = last + half spread. 1-tick bid/ask needs an Ultimate plan and is off unless you select it.", group = grpPos)
float spreadTicksIn = input.float(1.0, "Spread (ticks)", minval = 0.0, step = 1.0, tooltip = "Used by Last ± spread, and as fallback if 1-tick quotes are missing. 1 tick is typical for MES/MNQ/ES/NQ.", group = grpPos)

// ── Draggable points (price + time pairs = real chart handles)
// Add the script, click Entry, then Stop, then Target.
// After that: click this indicator on the chart and drag the 3 points.
string grpLvls = "Levels (click on add, then drag the points)"
int   eTime = input.time(0, "Entry",  inline = "e", group = grpLvls, confirm = true)
float ePx   = input.price(0.0, "",    inline = "e", group = grpLvls, confirm = true)
int   sTime = input.time(0, "Stop",   inline = "s", group = grpLvls, confirm = true)
float sPx   = input.price(0.0, "",    inline = "s", group = grpLvls, confirm = true)
int   tTime = input.time(0, "Target", inline = "t", group = grpLvls, confirm = true)
float tPx   = input.price(0.0, "",    inline = "t", group = grpLvls, confirm = true)

// ── Display
string grpShow = "Display"
bool showTbl   = input.bool(true, "Show table", group = grpShow)
bool showZones = input.bool(true, "Show risk / reward zones", group = grpShow)
color riskCol = input.color(color.red, "Risk zone", inline = "zone", group = grpShow)
color rewCol  = input.color(color.green, "Reward zone", inline = "zone", group = grpShow)
int zoneTransp = input.int(60, "Zone transparency", minval = 0, maxval = 100, tooltip = "0 = solid, 100 = invisible fill.", group = grpShow)
string tblPosIn = input.string("Top right", "Table position", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = grpShow)
int borderT = math.max(0, zoneTransp - 35)
color riskFill = color.new(riskCol, zoneTransp)
color rewFill  = color.new(rewCol, zoneTransp)
color riskBord = color.new(riskCol, borderT)
color rewBord  = color.new(rewCol, borderT)

// ── Point value
string root = str.upper(syminfo.root)
float autoPv = nz(syminfo.pointvalue, 1.0)
if str.contains(root, "MNQ")
    autoPv := 2.0
else if str.contains(root, "MES")
    autoPv := 5.0
else if str.contains(root, "MYM")
    autoPv := 0.5
else if str.contains(root, "M2K")
    autoPv := 0.5
else if str.contains(root, "MGC")
    autoPv := 10.0
else if str.contains(root, "MCL")
    autoPv := 100.0
else if root == "NQ"
    autoPv := 20.0
else if root == "ES"
    autoPv := 50.0
else if root == "YM"
    autoPv := 5.0
else if root == "RTY"
    autoPv := 50.0
else if root == "GC"
    autoPv := 100.0
else if root == "CL"
    autoPv := 1000.0
float pv = ptOv > 0.0 ? ptOv : (autoPv == 0.0 ? 1.0 : autoPv)

// ── Levels
float entry = ePx
float sl    = sPx
float tp    = tPx
int   eT    = eTime != 0 ? eTime : time
int   sT    = sTime != 0 ? sTime : time
int   tT    = tTime != 0 ? tTime : time

bool entryOk = not na(entry) and entry != 0.0
bool slOk    = not na(sl) and sl != 0.0 and sl != entry
bool tpOk    = not na(tp) and tp != 0.0 and tp != entry

bool isLong  = entryOk and slOk ? sl < entry : entryOk and tpOk ? tp > entry : false
bool isShort = entryOk and slOk ? sl > entry : entryOk and tpOk ? tp < entry : false
bool dirOk   = isLong or isShort
bool rrOk    = entryOk and slOk and tpOk and ((isLong and tp > entry) or (isShort and tp < entry))

float slMove  = slOk ? math.abs(entry - sl) : na
float tpMove  = tpOk ? math.abs(entry - tp) : na
float slUsd   = slOk ? slMove * pv * qty : na
float tpUsd   = tpOk ? tpMove * pv * qty : na
float rr      = rrOk and slUsd > 0.0 ? tpUsd / slUsd : na
float tickVal = nz(syminfo.mintick, 0.0) * pv * qty
float slTicks = slOk and syminfo.mintick > 0.0 ? slMove / syminfo.mintick : na
float tpTicks = tpOk and syminfo.mintick > 0.0 ? tpMove / syminfo.mintick : na

float qBid = close
float qAsk = close
string mtmSrc = "last"
bool haveBbo = false
bool wantTicks = quoteMode == "1-tick bid/ask (Ultimate)"

// Default uses the chart timeframe (all plans). "1T" is only requested if Ultimate mode is selected.
string qTf = wantTicks ? "1T" : timeframe.period
[tickBid, tickAsk] = request.security(syminfo.tickerid, qTf, [bid, ask], ignore_invalid_symbol = true)
if wantTicks and not na(tickBid) and not na(tickAsk) and tickAsk >= tickBid
    qBid := tickBid
    qAsk := tickAsk
    haveBbo := true
    mtmSrc := "1T bid/ask"

if not haveBbo
    if quoteMode == "Last price"
        qBid := close
        qAsk := close
        mtmSrc := "last"
    else
        float half = spreadTicksIn * 0.5 * nz(syminfo.mintick, 0.0)
        qBid := close - half
        qAsk := close + half
        haveBbo := spreadTicksIn > 0.0
        mtmSrc := haveBbo ? (wantTicks ? "spread fallback" : "last ± spread") : "last"

float liveBid = qBid
float liveAsk = qAsk
float spreadPx  = haveBbo ? qAsk - qBid : na
float spreadUsd = haveBbo ? spreadPx * pv * qty : na

float mtm = close
if dirOk and mtmSrc != "last"
    mtm := isLong ? qBid : qAsk

float livePnl = entryOk and dirOk ? (isLong ? (mtm - entry) * pv * qty : (entry - mtm) * pv * qty) : na

money(float x, bool withSign) =>
    string prefix = x >= 0.0 ? (withSign ? "+$" : "$") : "-$"
    prefix + str.tostring(math.abs(x), "#,##0.00")

statusText() =>
    if not entryOk or not slOk or not tpOk
        "Add script, click Entry, Stop, Target. Then click this indicator and drag the 3 points."
    else if not rrOk
        "Put stop and target on opposite sides of entry"
    else
        ""

// ── Drawings (thin rays from the points; drag the POINTS, not these rays)
var line eLn = na
var line sLn = na
var line tLn = na
var box  riskBox = na
var box  rewBox  = na
var label eLb = na
var label sLb = na
var label tLb = na

if barstate.islast
    if na(eLn)
        eLn := line.new(eT, close, time, close, xloc = xloc.bar_time, extend = extend.right, color = color.gray, width = 1, style = line.style_solid)
        sLn := line.new(sT, close, time, close, xloc = xloc.bar_time, extend = extend.right, color = riskCol, width = 1, style = line.style_dashed)
        tLn := line.new(tT, close, time, close, xloc = xloc.bar_time, extend = extend.right, color = rewCol, width = 1, style = line.style_dashed)
        riskBox := box.new(eT, close, time, close, xloc = xloc.bar_time, bgcolor = riskFill, border_color = riskBord, border_width = 1)
        rewBox  := box.new(eT, close, time, close, xloc = xloc.bar_time, bgcolor = rewFill, border_color = rewBord, border_width = 1)
        eLb := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)
        sLb := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(riskCol, 10), textcolor = color.white, size = size.small)
        tLb := label.new(time, close, "", xloc = xloc.bar_time, style = label.style_label_left, color = color.new(rewCol, 10), textcolor = color.white, size = size.small)

    line.set_xy1(eLn, eT, entryOk ? entry : close)
    line.set_xy2(eLn, time, entryOk ? entry : close)
    line.set_color(eLn, entryOk ? color.gray : na)

    line.set_xy1(sLn, sT, slOk ? sl : close)
    line.set_xy2(sLn, time, slOk ? sl : close)
    line.set_color(sLn, slOk ? riskCol : na)

    line.set_xy1(tLn, tT, tpOk ? tp : close)
    line.set_xy2(tLn, time, tpOk ? tp : close)
    line.set_color(tLn, tpOk ? rewCol : na)

    if showZones and entryOk and slOk
        box.set_left(riskBox, eT)
        box.set_right(riskBox, time)
        box.set_top(riskBox, math.max(entry, sl))
        box.set_bottom(riskBox, math.min(entry, sl))
        box.set_bgcolor(riskBox, riskFill)
        box.set_border_color(riskBox, riskBord)
    else
        box.set_bgcolor(riskBox, na)
        box.set_border_color(riskBox, na)

    if showZones and entryOk and tpOk
        box.set_left(rewBox, eT)
        box.set_right(rewBox, time)
        box.set_top(rewBox, math.max(entry, tp))
        box.set_bottom(rewBox, math.min(entry, tp))
        box.set_bgcolor(rewBox, rewFill)
        box.set_border_color(rewBox, rewBord)
    else
        box.set_bgcolor(rewBox, na)
        box.set_border_color(rewBox, na)

    string eTxt = entryOk ? "Entry  " + str.tostring(entry, format.mintick) + (not na(livePnl) ? "\nOpen  " + money(livePnl, true) : "") : ""
    string sTxt = slOk ? "SL  -" + money(slUsd, false) + (not na(slTicks) ? "  (" + str.tostring(slTicks, "#,##0") + " ticks)" : "") : ""
    string tTxt = tpOk ? "TP  +" + money(tpUsd, false) + (not na(tpTicks) ? "  (" + str.tostring(tpTicks, "#,##0") + " ticks)" : "") + (rrOk ? "  R:R " + str.tostring(rr, "#.00") : "") : ""

    label.set_xy(eLb, time, entryOk ? entry : close)
    label.set_text(eLb, eTxt)
    label.set_color(eLb, entryOk ? color.new(color.gray, 20) : na)
    label.set_textcolor(eLb, entryOk ? color.white : na)

    label.set_xy(sLb, time, slOk ? sl : close)
    label.set_text(sLb, sTxt)
    label.set_color(sLb, slOk ? color.new(riskCol, 10) : na)
    label.set_textcolor(sLb, slOk ? color.white : na)

    label.set_xy(tLb, time, tpOk ? tp : close)
    label.set_text(tLb, tTxt)
    label.set_color(tLb, tpOk ? color.new(rewCol, 10) : na)
    label.set_textcolor(tLb, tpOk ? color.white : na)

// ── Table
tblCorner = tblPosIn == "Top left" ? position.top_left : tblPosIn == "Top right" ? position.top_right : tblPosIn == "Bottom left" ? position.bottom_left : position.bottom_right

var table tbl = table.new(tblCorner, 2, 15, bgcolor = color.new(#0f172a, 10), border_width = 1, border_color = color.new(color.gray, 60), frame_width = 1, frame_color = color.new(color.gray, 50))

fillRow(int r, string k, string v, color vc) =>
    table.cell(tbl, 0, r, k, text_color = color.new(color.white, 20), text_halign = text.align_left,  text_size = size.small)
    table.cell(tbl, 1, r, v, text_color = vc, text_halign = text.align_right, text_size = size.small)

if barstate.islast
    table.set_position(tbl, tblCorner)
    table.clear(tbl, 0, 0, 1, 14)
    if showTbl
        string dirTxt = isLong ? "Long" : isShort ? "Short" : "—"
        table.cell(tbl, 0, 0, "SL / TP $", text_color = color.white, text_size = size.normal)
        table.cell(tbl, 1, 0, dirTxt + "  x" + str.tostring(qty), text_color = color.silver, text_size = size.small)

        string st = statusText()
        if st != ""
            fillRow(1, "Status", st, color.orange)
        else
            fillRow(1, "Stop loss",   "-" + money(slUsd, false), color.red)
            fillRow(2, "Take profit", "+" + money(tpUsd, false), color.lime)
            fillRow(3, "Open P&L",    money(livePnl, true), livePnl >= 0.0 ? color.lime : color.red)
            fillRow(4, "Marked to",   mtmSrc, mtmSrc == "last (no bid/ask)" ? color.orange : color.silver)
            fillRow(5, "Bid",         haveBbo ? str.tostring(liveBid, format.mintick) : "—", color.silver)
            fillRow(6, "Ask",         haveBbo ? str.tostring(liveAsk, format.mintick) : "—", color.silver)
            fillRow(7, "Spread $",    haveBbo ? money(spreadUsd, false) : "—", color.silver)
            fillRow(8, "R : R",       rrOk ? "1 : " + str.tostring(rr, "#.00") : "—", color.white)
            fillRow(9, "$ / tick",    money(tickVal, false), color.silver)
            fillRow(10, "SL ticks",   str.tostring(slTicks, "#,##0"), color.silver)
            fillRow(11, "TP ticks",   str.tostring(tpTicks, "#,##0"), color.silver)
            fillRow(12, "Point value", str.tostring(pv, "#,##0.####"), color.silver)
            fillRow(13, "Size",       str.tostring(qty, "#,##0.####"), color.silver)
            fillRow(14, "Drag",       "Click indicator, drag 3 points", color.silver)
````
