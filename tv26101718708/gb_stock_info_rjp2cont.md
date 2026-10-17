# GB Stock Info

- url: https://www.tradingview.com/script/rjp2conT-GB-Stock-Info/
- type: indicator
- pine_id: PUB;5feccd5340d34692bb96a11c51231bab
- version: 1.0

## Description

What it shows:

Company — NSE ticker symbol
Sector — from a curated database of NSE stocks
Industry — granular industry classification
M Cap — live market capitalisation calculated as Total Shares Outstanding × LTP, formatted in ₹ Crore / ₹K Cr / ₹L Cr with SEBI-standard cap category (Large / Mid / Small)

## Source Code

````pine
//@version=6
// ————— GB Stock Info — Live MCap + Sector/Industry
indicator("GB Stock Info", overlay=true)

import GEEBEE28/GBStockDB/1
// ————— Inputs
var GRP_TBL = "Display Settings"
posInput = input.string("Top Right", "Position",
     options=["Top Right","Top Left","Bottom Right","Bottom Left","Top Center","Bottom Center"],
     group=GRP_TBL)
szInput = input.string("Small", "Text Size",
     options=["Tiny","Small","Normal"], group=GRP_TBL)

// ————— Constants
float CR        = 10000000.0
int   LARGE_CAP = 20000
int   MID_CAP   = 5000
color BG        = color.black
color FG        = color.white
color VAL       = #daff59

// ————— Functions
fmtMcap(float mcCr) =>
    mcCr >= 100000 ? "₹" + str.tostring(math.round(mcCr / 100000.0, 1)) + "L Cr" :
     mcCr >= 1000  ? "₹" + str.tostring(math.round(mcCr / 1000.0,   1)) + "K Cr" :
     mcCr >  0     ? "₹" + str.tostring(math.round(mcCr, 0))             + " Cr"  : "—"

capCat(float mcCr) =>
    mcCr >= LARGE_CAP ? " · Large Cap" :
     mcCr >= MID_CAP  ? " · Mid Cap"   :
     mcCr >  0        ? " · Small Cap" : ""

tPos(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        =>                 position.top_right

tSz(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

// ————— Calculations
float mcCr     = (syminfo.shares_outstanding_total * close) / CR
string mcapStr = mcCr > 0 ? fmtMcap(mcCr) + capCat(mcCr) : "—"

[stSec, stInd, _mc, stCo] = GBStockDB.getInfo(syminfo.ticker)
// ————— Visuals
var table T = table.new(tPos(posInput), 5, 5,
     border_width=1, border_color=color.new(color.gray, 70),
     frame_color=color.new(color.gray, 50), frame_width=1)

if barstate.islast
    sz = tSz(szInput)
    // Row 0 — headers
    table.cell(T, 0, 0, "Company",  text_color=FG,  text_size=sz, bgcolor=BG, text_halign=text.align_left)
    table.cell(T, 1, 0, "Sector",   text_color=FG,  text_size=sz, bgcolor=BG, text_halign=text.align_left)
    table.cell(T, 2, 0, "Industry", text_color=FG,  text_size=sz, bgcolor=BG, text_halign=text.align_left)
    table.cell(T, 3, 0, "M Cap",    text_color=FG,  text_size=sz, bgcolor=BG, text_halign=text.align_left)
    // Row 1 — values
    table.cell(T, 0, 1, syminfo.ticker,       text_color=VAL, text_size=sz, bgcolor=BG, text_halign=text.align_left)
    table.cell(T, 1, 1, stSec,      text_color=VAL, text_size=sz, bgcolor=BG, text_halign=text.align_left)
    table.cell(T, 2, 1, stInd,      text_color=VAL, text_size=sz, bgcolor=BG, text_halign=text.align_left)
    table.cell(T, 3, 1, mcapStr,    text_color=VAL, text_size=sz, bgcolor=BG, text_halign=text.align_left)
````
