# Volume Buyers/Sellers +Delta %

- url: https://www.tradingview.com/script/2VKSpfaq-Volume-Buyers-Sellers-Delta/
- type: indicator
- pine_id: PUB;ed77014472584449973af9c52f513440
- version: 3.0

## Description

salutations .
 MMs , adjust accordingly.
Clear vision of market buyers and sellers in the fight.

## Source Code

````pine
//@version=6
indicator(title="[RG] Vol B/S/Δ — ACES Edition", shorttitle="[RG] Vol B/S/Δ+", overlay=false, max_bars_back=500)

grp_display   = "Display Settings"
showBars      = input.bool(true,  "Show Volume Bars",           group=grp_display)
showTable     = input.bool(true,  "Show Stats Table",           group=grp_display)
showCumDelta  = input.bool(true,  "Show Cumulative Delta Line", group=grp_display)
showSmooth    = input.bool(true,  "Show Smoothed Delta EMA",    group=grp_display)
lookback      = input.int(50,     "Lookback Period (bars)",     group=grp_display, minval=1, maxval=500)
smoothLen     = input.int(9,      "Delta Smoothing (EMA)",      group=grp_display, minval=2, maxval=50)

grp_aces      = "ACES Integration"
acesThresh    = input.float(55.0, "P1 Fire Threshold (%)",     group=grp_aces, step=0.5)
showACESrow   = input.bool(true,  "Show ACES P1 Row in Table", group=grp_aces)

grp_div       = "Divergence Detection"
showDiverg    = input.bool(true,  "Show Divergence Signals",   group=grp_div)
divLookback   = input.int(8,      "Divergence Lookback",       group=grp_div, minval=3, maxval=20)

grp_colors    = "Color Settings"
buyColor      = input.color(color.new(#26a69a, 0),  "Buyer Color",        group=grp_colors)
sellColor     = input.color(color.new(#ef5350, 0),  "Seller Color",       group=grp_colors)
deltaColor    = input.color(color.new(#f0b429, 0),  "Delta Color",        group=grp_colors)
cumDeltaColor = input.color(color.new(#ffffff, 20), "Cum Delta Color",    group=grp_colors)
smoothColor   = input.color(color.new(#aa44ff, 0),  "Smooth Delta Color", group=grp_colors)

grp_vol       = "Volume Method"
volMethod     = input.string("Weighted HL", "Volume Attribution",
                 options=["Candle Direction", "High-Low Position", "Weighted HL"],
                 group=grp_vol)

float buyVol  = na
float sellVol = na

if volMethod == "Candle Direction"
    buyVol  := close >= open ? volume : 0.0
    sellVol := close <  open ? volume : 0.0
else if volMethod == "High-Low Position"
    float hlRange = high - low
    float ratio   = hlRange > 0 ? (close - low) / hlRange : 0.5
    buyVol  := volume * ratio
    sellVol := volume * (1.0 - ratio)
else
    float hlRange  = high - low
    float upWick   = hlRange > 0 ? (high  - math.max(open, close)) / hlRange : 0.25
    float downWick = hlRange > 0 ? (math.min(open, close) - low)   / hlRange : 0.25
    float body     = hlRange > 0 ? math.abs(close - open)          / hlRange : 0.50
    float bullBody = close >= open ? body : 0.0
    float bearBody = close <  open ? body : 0.0
    buyVol  := volume * (bullBody + upWick   * 0.5)
    sellVol := volume * (bearBody + downWick * 0.5)

float sumBuy  = math.sum(buyVol,  lookback)
float sumSell = math.sum(sellVol, lookback)
float sumVol  = sumBuy + sumSell

float pctBuy   = sumVol > 0 ? (sumBuy  / sumVol) * 100.0 : 50.0
float pctSell  = sumVol > 0 ? (sumSell / sumVol) * 100.0 : 50.0
float pctDelta = pctBuy - pctSell

var float cumDelta    = 0.0
var float sessionHigh = 0.0
var float sessionLow  = 0.0

if session.isfirstbar
    cumDelta    := 0.0
    sessionHigh := 0.0
    sessionLow  := 0.0

cumDelta    := cumDelta + (buyVol - sellVol)
sessionHigh := math.max(sessionHigh, cumDelta)
sessionLow  := math.min(sessionLow,  cumDelta)

float cumDeltaRange = sessionHigh - sessionLow
float cumDeltaNorm  = cumDeltaRange > 0 ? ((cumDelta - sessionLow) / cumDeltaRange) * 20 - 10 : 0

float smoothDelta = ta.ema(pctDelta, smoothLen)

var int buyBars  = 0
var int sellBars = 0
var int consBuy  = 0
var int consSell = 0

if barstate.isconfirmed
    if close >= open
        buyBars  := buyBars  + 1
        consBuy  := consBuy  + 1
        consSell := 0
    else
        sellBars := sellBars + 1
        consSell := consSell + 1
        consBuy  := 0

if session.isfirstbar
    buyBars  := 0
    sellBars := 0
    consBuy  := 0
    consSell := 0

bool bearDiv = false
bool bullDiv = false

if showDiverg
    bool priceHH = high   > ta.highest(high[1], divLookback)
    bool deltaLH = pctDelta < nz(pctDelta[divLookback])
    bearDiv := priceHH and deltaLH and pctDelta > 0
    bool pricLL  = low    < ta.lowest(low[1], divLookback)
    bool deltaHL = pctDelta > nz(pctDelta[divLookback])
    bullDiv := pricLL and deltaHL and pctDelta < 0

bool p1_long  = pctBuy  >= acesThresh
bool p1_short = pctSell >= acesThresh
bool p1_flip  = p1_long != p1_long[1] or p1_short != p1_short[1]

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(showBars ? buyVol  : na, "Buyer Volume",  style=plot.style_columns, color=buyColor,  linewidth=1)
plot(showBars ? sellVol : na, "Seller Volume", style=plot.style_columns, color=sellColor, linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 70), linestyle=hline.style_solid, linewidth=1)
plot(showCumDelta ? cumDeltaNorm : na, "Cum Delta", color=cumDeltaColor, linewidth=2)

float smoothRescaled = showSmooth ? (smoothDelta / 20) * math.max(math.abs(ta.highest(buyVol, lookback)), math.abs(ta.highest(sellVol, lookback))) : na
plot(smoothRescaled, "Smooth Delta", color=smoothColor, linewidth=1)

plotshape(bearDiv, "Bear Div", shape.triangledown, location.top,    color.new(color.orange, 10), size=size.tiny)
plotshape(bullDiv, "Bull Div", shape.triangleup,   location.bottom, color.new(color.aqua,   10), size=size.tiny)

// ── ACES Stats Table — top right, horizontal ──────────────────────────────────
if showTable and barstate.islast
    color _hbg  = color.new(#0d1f3c, 10)
    color _bg   = color.new(color.black, 85)
    color _p1bg = color.new(#0d1f3c, 20)

    string consStr = consBuy > 2 ? "▲" + str.tostring(consBuy) : consSell > 2 ? "▼" + str.tostring(consSell) : "—"
    color  consCol = consBuy > 2 ? color.lime : consSell > 2 ? color.red : color.gray
    string p1LongTxt  = p1_long  ? "✓ LONG"  : "✗"
    string p1ShortTxt = p1_short ? "✓ SHORT" : "✗"
    color  p1LongCol  = p1_long  ? color.lime : color.new(color.red, 30)
    color  p1ShortCol = p1_short ? color.red  : color.new(color.red, 30)
    color  bBg = p1_long  ? color.new(#26a69a, 70) : _bg
    color  sBg = p1_short ? color.new(#ef5350, 70) : _bg

    int tblCols = showACESrow ? 5 : 4
    var table statsTable = table.new(
         position.top_right, tblCols, 2,
         bgcolor=_bg,
         border_color=color.new(color.gray, 60),
         border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

    // Row 0 — headers
    table.cell(statsTable, 0, 0, "Buyers",  text_color=buyColor,   text_size=size.tiny, text_halign=text.align_center, bgcolor=_hbg)
    table.cell(statsTable, 1, 0, "Sellers", text_color=sellColor,  text_size=size.tiny, text_halign=text.align_center, bgcolor=_hbg)
    table.cell(statsTable, 2, 0, "Δ",       text_color=deltaColor, text_size=size.tiny, text_halign=text.align_center, bgcolor=_hbg)
    table.cell(statsTable, 3, 0, "Bars",    text_color=color.gray, text_size=size.tiny, text_halign=text.align_center, bgcolor=_hbg)
    if showACESrow
        table.cell(statsTable, 4, 0, "ACES P1", text_color=color.gray, text_size=size.tiny, text_halign=text.align_center, bgcolor=_hbg)

    // Row 1 — values
    table.cell(statsTable, 0, 1, str.tostring(pctBuy,   "##.##") + "%", text_color=buyColor,   text_size=size.small, text_halign=text.align_center, bgcolor=bBg)
    table.cell(statsTable, 1, 1, str.tostring(pctSell,  "##.##") + "%", text_color=sellColor,  text_size=size.small, text_halign=text.align_center, bgcolor=sBg)
    table.cell(statsTable, 2, 1, str.tostring(pctDelta, "##.##") + "%", text_color=pctDelta >= 0 ? buyColor : sellColor, text_size=size.small, text_halign=text.align_center, bgcolor=_bg)
    table.cell(statsTable, 3, 1, str.tostring(buyBars) + "/" + str.tostring(sellBars) + " " + consStr, text_color=consCol, text_size=size.tiny, text_halign=text.align_center, bgcolor=_bg)
    if showACESrow
        string p1combined = p1LongTxt + " | " + p1ShortTxt
        color  p1combCol  = p1_long ? color.lime : p1_short ? color.red : color.gray
        table.cell(statsTable, 4, 1, p1combined, text_color=p1combCol, text_size=size.tiny, text_halign=text.align_center, bgcolor=_p1bg)

// ── Status line ───────────────────────────────────────────────────────────────
plot(buyBars,  "Buy Bars",  color=buyColor,   display=display.status_line)
plot(sellBars, "Sell Bars", color=sellColor,  display=display.status_line)
plot(pctDelta, "Delta %",   color=deltaColor, display=display.status_line)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(pctBuy > 60,    "Strong Buying",      "Buyer pressure > 60% — {{ticker}}")
alertcondition(pctSell > 60,   "Strong Selling",     "Seller pressure > 60% — {{ticker}}")
alertcondition(pctDelta > 10,  "Bull Delta",         "Delta > +10% — {{ticker}}")
alertcondition(pctDelta < -10, "Bear Delta",         "Delta < -10% — {{ticker}}")
alertcondition(p1_long  and not p1_long[1],  "ACES P1 Long Fire",  "P1 BUYERS DOMINANT — {{ticker}}")
alertcondition(p1_short and not p1_short[1], "ACES P1 Short Fire", "P1 SELLERS DOMINANT — {{ticker}}")
alertcondition(bearDiv,  "Bear Divergence",   "Price HH / Delta LH — {{ticker}}")
alertcondition(bullDiv,  "Bull Divergence",   "Price LL / Delta HL — {{ticker}}")
alertcondition(consBuy  >= 4, "Sustained Buying",  "4+ consecutive buy bars — {{ticker}}")
alertcondition(consSell >= 4, "Sustained Selling", "4+ consecutive sell bars — {{ticker}}")
alertcondition(p1_flip, "P1 Flip", "P1 direction changed — {{ticker}}")

// ── Bridge Outputs — selectable via ACES v7.2 External Bridge inputs ──────────
// In ACES settings → P1: Use B/S Δ+ Bridge → select "BS Bridge P1"
// value > threshold  = buyers dominant → ACES P1 Long
// value < -threshold = sellers dominant → ACES P1 Short
plot(pctDelta,    "BS Bridge Delta",  display=display.none)
plot(smoothDelta, "BS Bridge Smooth", display=display.none)
plot(p1_long ? 1.0 : p1_short ? -1.0 : 0.0, "BS Bridge P1", display=display.none)
````
