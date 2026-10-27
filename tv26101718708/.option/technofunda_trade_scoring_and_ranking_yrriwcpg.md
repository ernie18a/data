# Technofunda Trade Scoring and Ranking

- url: https://www.tradingview.com/script/yRriwcPG-Technofunda-Trade-Scoring-and-Ranking/
- type: indicator
- pine_id: PUB;5c2bc40375aa464a98481b02d467214e
- version: 1.0

## Description

Technofunda Trade Scoring and Ranking GOOD FOR SWING TRADERS

## Source Code

````pine
// © guru101457
//@version=6
indicator("Technofunda Trade Scoring and Ranking", overlay=true)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
epsGrowth     = input.float(25,  "EPS Growth %",          group="Fundamental")
revenueGrowth = input.float(20,  "Revenue Growth %",      group="Fundamental")
roeVal        = input.float(18,  "ROE %",                 group="Fundamental")
ppLookback    = input.int(8,     "Pocket Pivot Lookback", minval=5, maxval=20, group="Volume")
niftySymbol   = input.symbol("NSE:NIFTY", "Benchmark",    group="RS")
catalystText  = input.string("", "Catalyst Word",         group="Display")
posInput      = input.string("Top Right", "Table Position", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group="Display")

// ─────────────────────────────────────────
// TABLE POSITION
// ─────────────────────────────────────────
tblPos = posInput == "Top Left"      ? position.top_left      :
         posInput == "Top Center"    ? position.top_center    :
         posInput == "Top Right"     ? position.top_right     :
         posInput == "Middle Left"   ? position.middle_left   :
         posInput == "Middle Center" ? position.middle_center :
         posInput == "Middle Right"  ? position.middle_right  :
         posInput == "Bottom Left"   ? position.bottom_left   :
         posInput == "Bottom Center" ? position.bottom_center :
                                       position.bottom_right

// ─────────────────────────────────────────
// AUTO FUNDAMENTALS
// ─────────────────────────────────────────
mcapAuto = request.financial(syminfo.tickerid, "MARKET_CAP_BASIC", "TTM", ignore_invalid_symbol=true)
peAuto   = request.financial(syminfo.tickerid, "PE_RATIO",         "TTM", ignore_invalid_symbol=true)
mcapCr   = na(mcapAuto) ? 0.0 : mcapAuto / 1e7
peVal    = na(peAuto)   ? 0.0 : peAuto

// ─────────────────────────────────────────
// TECHNICAL (4 conditions)
// ─────────────────────────────────────────
price   = close
ma50    = ta.sma(price, 50)
ma150   = ta.sma(price, 150)
ma200   = ta.sma(price, 200)
high52w = ta.highest(high, 252)

cond1 = price > ma50 and price > ma150 and price > ma200
cond2 = ma50 > ma150 and ma150 > ma200
cond3 = ma200 > ma200[20]
cond4 = price >= high52w * 0.75

techScore = (cond1?1:0) + (cond2?1:0) + (cond3?1:0) + (cond4?1:0)

// ─────────────────────────────────────────
// FUNDAMENTAL (3 conditions)
// ─────────────────────────────────────────
cond6 = epsGrowth     > 20
cond7 = revenueGrowth > 15
cond8 = roeVal        > 17

fundScore = (cond6?1:0) + (cond7?1:0) + (cond8?1:0)

// ─────────────────────────────────────────
// IVOL
// ─────────────────────────────────────────
isUpDay    = close >= close[1]
maxDownVol = 0.0
for i = 1 to ppLookback
    dv = close[i] < close[i+1] ? volume[i] : 0.0
    maxDownVol := math.max(maxDownVol, dv)

avgVol8     = ta.sma(volume, ppLookback)
pocketPivot = isUpDay and volume > maxDownVol and volume > 0
instVol2x   = volume >= avgVol8 * 2.0
cond9       = pocketPivot and instVol2x
volRatio    = avgVol8 > 0 ? volume / avgVol8 : 0.0

// ─────────────────────────────────────────
// RS — 21D vs Nifty
// ─────────────────────────────────────────
niftyClose = request.security(niftySymbol, timeframe.period, close)
stockRS    = (price - price[21]) / price[21] * 100
niftyRS    = (niftyClose - niftyClose[21]) / niftyClose[21] * 100
rsSpread   = stockRS - niftyRS
cond10     = rsSpread > 0

// ─────────────────────────────────────────
// TOTAL SCORE (max = 9)
// ─────────────────────────────────────────
totalScore = techScore + fundScore + (cond9?1:0) + (cond10?1:0)

signalLabel =
     totalScore >= 7 ? "STRONG BUY" :
     totalScore >= 5 ? "BUY"        :
     totalScore >= 3 ? "NEUTRAL"    : "WEAK"

signalColor =
     totalScore >= 7 ? color.new(#00c853, 0) :
     totalScore >= 5 ? color.new(#1b5e20, 0) :
     totalScore >= 3 ? color.new(#e65100, 0) :
                       color.new(#b71c1c, 0)

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────
tk(b)  => b ? "▲" : "▼"
tkc(b) => b ? color.new(#00e676,0) : color.new(#ff1744,0)
pct(v) => str.tostring(math.round(v,1)) + "%"
flt(v) => str.tostring(math.round(v,1))
cr(v)  => v > 0 ? str.tostring(math.round(v,0))+"Cr" : "N/A"
pe(v)  => v > 0 ? str.tostring(math.round(v,1))+"x"  : "N/A"

S = size.tiny

// ─────────────────────────────────────────
// COLOURS — high contrast
// ─────────────────────────────────────────
hTech  = color.new(#0d47a1, 0)   // vivid blue
hFund  = color.new(#1b5e20, 0)   // vivid green
hIvol  = color.new(#e65100, 0)   // vivid orange
rowA   = color.new(#0a0d12, 0)
rowB   = color.new(#0d1117, 0)
scoreC = color.new(#1a1f2e, 0)
infoBg = color.new(#050810, 0)
borC   = color.new(#2a3a4a, 0)
tW     = #ffffff
tY     = #ffeb3b
tG     = #b0bec5

// ─────────────────────────────────────────
// TABLE — 6 cols × 8 rows
// ─────────────────────────────────────────
var table tbl = na

if barstate.islast
    table.delete(tbl)
    tbl := table.new(tblPos, 6, 8, border_color=borC, border_width=1, frame_color=borC, frame_width=1)

    // ══ INFO ROW ══
    table.cell(tbl, 0, 0, syminfo.ticker,  text_color=color.new(#ffeb3b,0), bgcolor=infoBg, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 0, flt(price),      text_color=color.new(#69ff47,0), bgcolor=infoBg, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 0, syminfo.sector != "" ? syminfo.sector : "-", text_color=color.new(tG,0), bgcolor=infoBg, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 3, 0, cr(mcapCr),      text_color=color.new(tG,0),  bgcolor=infoBg, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 4, 0, "PE:"+pe(peVal), text_color=color.new(tG,0),  bgcolor=infoBg, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 5, 0, str.tostring(totalScore)+"/9 "+signalLabel, text_color=color.new(tW,0), bgcolor=signalColor, text_size=S, text_halign=text.align_center)

    // ══ SECTION HEADERS ══
    table.cell(tbl, 0, 1, "TECH",  text_color=color.new(tW,0), bgcolor=hTech, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 1, 1, str.tostring(techScore)+"/4", text_color=color.new(tY,0), bgcolor=hTech, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 1, "FUND",  text_color=color.new(tW,0), bgcolor=hFund, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 3, 1, str.tostring(fundScore)+"/3", text_color=color.new(tY,0), bgcolor=hFund, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 4, 1, "IVOL+RS", text_color=color.new(tW,0), bgcolor=hIvol, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 5, 1, str.tostring((cond9?1:0)+(cond10?1:0))+"/2", text_color=color.new(tY,0), bgcolor=hIvol, text_size=S, text_halign=text.align_center)

    // ══ ROW 2 ══
    table.cell(tbl, 0, 2, "P>MA50/150/200", text_color=color.new(tW,0), bgcolor=rowA, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 2, tk(cond1), text_color=tkc(cond1), bgcolor=rowA, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 2, "EPS>20%",  text_color=color.new(tW,0), bgcolor=rowA, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 3, 2, tk(cond6), text_color=tkc(cond6), bgcolor=rowA, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 4, 2, "PktPivot", text_color=color.new(tW,0), bgcolor=rowA, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 5, 2, tk(pocketPivot), text_color=tkc(pocketPivot), bgcolor=rowA, text_size=S, text_halign=text.align_center)

    // ══ ROW 3 ══
    table.cell(tbl, 0, 3, "MA50>150>200", text_color=color.new(tW,0), bgcolor=rowB, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 3, tk(cond2), text_color=tkc(cond2), bgcolor=rowB, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 3, "Rev>15%",      text_color=color.new(tW,0), bgcolor=rowB, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 3, 3, tk(cond7), text_color=tkc(cond7), bgcolor=rowB, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 4, 3, "Vol>2xAvg",    text_color=color.new(tW,0), bgcolor=rowB, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 5, 3, tk(instVol2x), text_color=tkc(instVol2x), bgcolor=rowB, text_size=S, text_halign=text.align_center)

    // ══ ROW 4 ══
    table.cell(tbl, 0, 4, "MA200 Trend",  text_color=color.new(tW,0), bgcolor=rowA, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 4, tk(cond3), text_color=tkc(cond3), bgcolor=rowA, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 4, "ROE>17%",      text_color=color.new(tW,0), bgcolor=rowA, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 3, 4, tk(cond8), text_color=tkc(cond8), bgcolor=rowA, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 4, 4, "IVol",         text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 5, 4, (cond9?"1":"0")+"/1", text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_center)

    // ══ ROW 5 ══
    table.cell(tbl, 0, 5, "P>=75% 52WH",  text_color=color.new(tW,0), bgcolor=rowB, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 5, tk(cond4), text_color=tkc(cond4), bgcolor=rowB, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 5, "Fund",          text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 3, 5, str.tostring(fundScore)+"/3", text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 4, 5, "RS "+pct(rsSpread), text_color=rsSpread>0?color.new(#00e676,0):color.new(#ff1744,0), bgcolor=rowB, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 5, 5, tk(cond10), text_color=tkc(cond10), bgcolor=rowB, text_size=S, text_halign=text.align_center)

    // ══ ROW 6 ══
    table.cell(tbl, 0, 6, "Tech", text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(techScore)+"/4", text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 6, "", bgcolor=rowA)
    table.cell(tbl, 3, 6, "", bgcolor=rowA)
    table.cell(tbl, 4, 6, "RS",  text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 5, 6, (cond10?"1":"0")+"/1", text_color=color.new(tY,0), bgcolor=scoreC, text_size=S, text_halign=text.align_center)

    // ══ TOTAL ROW ══
    table.cell(tbl, 0, 7, "TOTAL", text_color=color.new(tY,0), bgcolor=signalColor, text_size=S, text_halign=text.align_left)
    table.cell(tbl, 1, 7, str.tostring(totalScore)+"/9", text_color=color.new(tY,0), bgcolor=signalColor, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 2, 7, signalLabel, text_color=color.new(tW,0), bgcolor=signalColor, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 3, 7, "", bgcolor=signalColor)
    table.cell(tbl, 4, 7, catalystText != "" ? "⚡"+catalystText : "", text_color=color.new(tY,0), bgcolor=signalColor, text_size=S, text_halign=text.align_center)
    table.cell(tbl, 5, 7, "", bgcolor=signalColor)

// ─────────────────────────────────────────
// STRONG BUY ARROW + CATALYST LABEL
// ─────────────────────────────────────────
strongBuy = totalScore >= 7 and close > open

plotshape(strongBuy, title="Strong Buy", location=location.belowbar,
          style=shape.triangleup, size=size.tiny,
          color=color.new(#00e676, 0), text="")

if strongBuy and catalystText != ""
    label.new(bar_index, low * 0.985, catalystText,
              style=label.style_none,
              textcolor=color.new(#00e676, 0),
              size=size.tiny, yloc=yloc.price)
````
