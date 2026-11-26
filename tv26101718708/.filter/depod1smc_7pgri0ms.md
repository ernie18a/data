# DEPOD1_SMC

- url: https://www.tradingview.com/script/7PgrI0ms/
- type: indicator
- pine_id: PUB;c8569cb1afd24497bf61b8617108a44c
- version: 1.0

## Description

SMC con FVG, Order Block, BuySide, SellSide, Smooth Trail, Volumen Profile e histórico de estrategia PUPUPU.

## Source Code

````pine
// © DEPOD1-SMC
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Integrations: Liquidity Print visual mejorado (plotcandle wick wrap) · Smooth Trail · Sniper Signals
//@version=6
indicator("DEPOD1_SMC", "DEPOD1_SMC", overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100)

// ══════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════
// ⭐ OBJETIVOS DE PRECIO
// Un botón activa: Fib 0.886/1.13/-0.272/-0.618 · VWAP Anclado
// Apertura Semanal/Mensual · Niveles Psicológicos
// ══════════════════════════════════════════════════════════════
GRP_OBJ      = "⭐ OBJETIVOS DE PRECIO"
show_obj     = input.bool(false, "Activar", group = GRP_OBJ, inline = "o1",
     tooltip = "Activa todo: Fibonacci 0.886 / 1.13 / -0.272 / -0.618  ·  VWAP Anclado al Swing  ·  Apertura Semanal  ·  Apertura Mensual  ·  Niveles Psicológicos automáticos")
obj_col_fib  = input.color(#ffb74d,               "Fib+",  group = GRP_OBJ, inline = "o1")
obj_col_vwap = input.color(#ce93d8,               "VWAP",  group = GRP_OBJ, inline = "o1")
obj_col_open = input.color(#78909c,               "Opens", group = GRP_OBJ, inline = "o2")
obj_col_psyc = input.color(color.new(#455a64, 0), "Psyc",  group = GRP_OBJ, inline = "o2")


windowsis = input.bool(true, "Window", inline = "kla", group = "MARKET STRUCTURE")
mswindow = input.int(5000, "", tooltip = "Limit market structure calculation to improve memory speed time", group = "MARKET STRUCTURE", inline = "kla", minval = 1000)
showSwing = input.bool(true, "Swing", inline = "scss", group = "MARKET STRUCTURE")
swingLimit = input.int(100, "", tooltip = "[INPUT] Limit swing structure to tot bars back", inline = "scss", group = "MARKET STRUCTURE", minval = 10, maxval = 200)
swingcssup = input.color(#089981, "", inline = "scss", group = "MARKET STRUCTURE")
swingcssdn = input.color(#f23645, "", inline = "scss", group = "MARKET STRUCTURE")

showInternal = input.bool(false, "Internal", inline = "icss", group = "MARKET STRUCTURE")
internalDate = input.time(0, "", tooltip = "[INPUT] Start date of the internal structure", inline = "icss", group = "MARKET STRUCTURE", confirm = false)
interncssup = input.color(color.blue, "", inline = "icss", group = "MARKET STRUCTURE")
interncssdn = input.color(color.purple, "", inline = "icss", group = "MARKET STRUCTURE")

showMapping = input.bool(false, "Mapping Structure", inline = "mapping", group = "MARKET STRUCTURE")
mappingStyle = input.string("----", "", options = ["⎯⎯⎯⎯", "----"], inline = "mapping", group = "MARKET STRUCTURE")
mappingcss = input.color(color.silver, "", tooltip = "Display Mapping Structure", inline = "mapping", group = "MARKET STRUCTURE")
candlecss = input.bool(false, "Color Candles", tooltip = "Color candle based on trend detection system", group = "MARKET STRUCTURE", inline = "txt")
mstext = input.string("Tiny", "", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "txt", group = "MARKET STRUCTURE")
showpdzone = input.bool(false, "Premium/Discount", "Show Premium discount zone", "pd", "MARKET STRUCTURE")
zonelen = input.int(20, "", inline = "pd", group = "MARKET STRUCTURE", minval = 5)
fibcss = input.color(#fbc02d, "", inline = "pd", group = "MARKET STRUCTURE")
msmode = input.string("Adjusted Points", "Algorithmic Logic", options = ["Extreme Points", "Adjusted Points"], inline = "node", group = "MARKET STRUCTURE")
mslen = input.int(5, "", inline = "node", group = "MARKET STRUCTURE", minval = 2)
showhl = input.bool(false, "Strong/Weak HL", "Display Volumetric Strong/Weak High and low", "hl", "MARKET STRUCTURE")
buildsweep = input.bool(true, "Build Sweep (x)", "Build sweep on market structure", "znc", "MARKET STRUCTURE")
msbubble = input.bool(true, "Bubbles", tooltip = "Display Circle Bubbles", inline = "bubbles", group = "MARKET STRUCTURE")

obshow = input.bool(true, "Show Last", tooltip = "Show Last number of orderblock", group = "VOLUMETRIC ORDER BLOCKS", inline = "obshow")
oblast = input.int(5, "", group = "VOLUMETRIC ORDER BLOCKS", inline = "obshow", minval = 0)
obupcs = input.color(color.new(#089981, 90), "", inline = "obshow", group = "VOLUMETRIC ORDER BLOCKS")
obdncs = input.color(color.new(#f23645, 90), "", inline = "obshow", group = "VOLUMETRIC ORDER BLOCKS")
obshowactivity = input.bool(true, "Show Buy/Sell Activity", inline = "act", group = "VOLUMETRIC ORDER BLOCKS", tooltip = "Display internal buy and sell activity")
obactup = input.color(color.new(#089981, 50), "", inline = "act", group = "VOLUMETRIC ORDER BLOCKS")
obactdn = input.color(color.new(#f23645, 50), "", inline = "act", group = "VOLUMETRIC ORDER BLOCKS")
obshowbb = input.bool(false, "Show Breakers", inline = "bb", group = "VOLUMETRIC ORDER BLOCKS", tooltip = "Display Breakers")
bbup = input.color(color.new(#089981, 100), "", inline = "bb", group = "VOLUMETRIC ORDER BLOCKS")
bbdn = input.color(color.new(#f23645, 100), "", inline = "bb", group = "VOLUMETRIC ORDER BLOCKS")
obmode = input.string("Length", "Construction ", options = ["Length", "Full"], tooltip = "[Length] Use Length to adjust cordinate of the orderblocks\n[Full] Use whole candle body", inline = "atr", group = "VOLUMETRIC ORDER BLOCKS")
len = input.int(5, "", inline = "atr", group = "VOLUMETRIC ORDER BLOCKS", minval = 1)
obmiti = input.string("Close", "Mitigation Method", options = ["Close", "Wick", "Avg"], tooltip = "Mitigation method for when to trigger order blocks", group = "VOLUMETRIC ORDER BLOCKS")
obtxt = input.string("Normal", "Metric Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], tooltip = "Order block Metrics text size", inline = "txt", group = "VOLUMETRIC ORDER BLOCKS")
showmetric = input.bool(true, "Show Metrics", group = "VOLUMETRIC ORDER BLOCKS")
showline = input.bool(true, "Show Mid-Line", group = "VOLUMETRIC ORDER BLOCKS")
overlap = input.bool(true, "Hide Overlap", group = "VOLUMETRIC ORDER BLOCKS", inline = "ov")
wichlap = input.string("Recent", "", options = ["Recent", "Old"],inline = "ov", group = "VOLUMETRIC ORDER BLOCKS")

fvg_enable = input.bool(false, "", inline = "1", group = "FAIR VALUE GAP", tooltip = "Display fair value gap")
what_fvg = input.string("FVG", "", inline = "1", group = "FAIR VALUE GAP", tooltip = "Display fair value gap", options = ["FVG", "Breakers"])
fvg_num = input.int(5, "Show Last", inline = "1a", group = "FAIR VALUE GAP", tooltip = "Number of fvg to show", minval = 0)
fvg_upcss = input.color(color.new(#089981, 80), "", inline = "1", group = "FAIR VALUE GAP")
fvg_dncss = input.color(color.new(#f23645 , 80), "", inline = "1", group = "FAIR VALUE GAP")
fvgbbup = input.color(color.new(#089981, 100), "", inline = "1", group = "FAIR VALUE GAP")
fvgbbdn = input.color(color.new(#f23645, 100), "", inline = "1", group = "FAIR VALUE GAP")
fvg_src = input.string("Close", "Mitigation", inline = "3", group = "FAIR VALUE GAP", tooltip = "[Close] Use the close of the body as trigger\n\n[Wick] Use the extreme point of the body as trigger", options = ["Close", "Wick", "Avg"])
fvg_tf = input.timeframe("", "Timeframe", inline = "4", group = "FAIR VALUE GAP", tooltip = "Timeframe of the fair value gap")
fvgthresh = input.float(0, "Threshold", tooltip = "Filter out non significative FVG", group = "FAIR VALUE GAP", inline = "asd", minval = 0, maxval = 2, step = 0.1)
fvgoverlap = input.bool(true, "Hide Overlap", "Hide overlapping FVG", group = "FAIR VALUE GAP")
fvgline = input.bool(true, "Show Mid-Line", group = "FAIR VALUE GAP")
fvgextend = input.bool(false, "Extend FVG", group = "FAIR VALUE GAP")
dispraid = input.bool(false, "Display Raids", inline = "raid", group = "FAIR VALUE GAP")

dispSFP = input.bool(false, "Show Last", tooltip = "Display Swing Failure Pattern", inline = "sfp", group = "Swing Failure Pattern")
sfpshow = input.int(5, "", inline = "sfp", group = "Swing Failure Pattern", minval = 0)
showdev = input.bool(false, "Deviation Area", inline = "dev", group = "Swing Failure Pattern")
brsfpcs = input.color(#f23645, "", inline = "sfp", group = "Swing Failure Pattern")
blsfpcs = input.color(#089981, "", inline = "sfp", group = "Swing Failure Pattern")
spfuselen = input.bool(true, "Length", inline = "sfx", group = "Swing Failure Pattern")
sfplen = input.int(5, "", tooltip = "Adjust SFP", group = "Swing Failure Pattern", inline = "sfx", minval = 0)
sfpuse = input.bool(false, "MTF", tooltip = "MTF SFP", inline = "sfp4", group = "Swing Failure Pattern")
sfptf = input.timeframe("", "", inline = "sfp4", group = "Swing Failure Pattern")
sfpfilter = input.string("None", "Filtering", options = ["None", "Trend Following", "Counter Trade"], tooltip = "Filtering for SFP" , inline = "sfp1", group = "Swing Failure Pattern")
sfpthresh = input.float(1, "Threshold", options = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2], tooltip = "Volume Threshold for SFP", inline = "sfp2", group = "Swing Failure Pattern")
devstyle = input.string("⎯⎯⎯⎯", "", options = ["⎯⎯⎯⎯", "----"], inline = "dev", group = "Swing Failure Pattern")
devcss = input.color(#b2b5be, "", tooltip = "Display deviation projection for SFP", inline = "dev", group = "Swing Failure Pattern")
devsize = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large", "Huge", "Auto"], tooltip = "Text Size", inline = "ak", group = "Swing Failure Pattern")
devlvl = input.bool(true, "Show Level", group = "Swing Failure Pattern")
devfill = input.bool(true, "Fill Area", group = "Swing Failure Pattern")

ehlshow = input.bool(true, "Equal H&L", tooltip = "Display EQH and EQL", inline = "ehl", group = "LIQUIDITY CONCEPTS")
ehlmode = input.string("Short-Term", "", options = ["Short-Term", "Mid-Term", "Long-Term"], inline = "ehl", group = "LIQUIDITY CONCEPTS")
ehldowncs = input.color(#089981, "", inline = "ehl", group = "LIQUIDITY CONCEPTS")
ehlupcs = input.color(#f23645, "", inline = "ehl", group = "LIQUIDITY CONCEPTS")
liqprint = input.bool(true, "Liquidity Prints", "Show Liquidity Grabs on the chart", inline = "print", group = "LIQUIDITY CONCEPTS")
printupcs = input.color(#f23645, "", inline = "print", group = "LIQUIDITY CONCEPTS")
printdowncs = input.color(#2962ff, "", inline = "print", group = "LIQUIDITY CONCEPTS")
showside = input.bool(false, "Buyside & Sellside", tooltip = "Display Liquidity side", inline = "side", group = "LIQUIDITY CONCEPTS")
sidemode = input.string("Area", "", ["Area", "Line"], inline = "side", group = "LIQUIDITY CONCEPTS")
buysidecss = input.color(color.new(#089981, 75), "", inline = "side", group = "LIQUIDITY CONCEPTS")
sidesidecss = input.color(color.new(#f23645, 75), "", inline = "side", group = "LIQUIDITY CONCEPTS")
showzone = input.bool(false, "Sweep Area", "Show Sweep liquidation zone", "sz", "LIQUIDITY CONCEPTS")
zonethresh = input.int(10, "", inline = "sz", group = "LIQUIDITY CONCEPTS", minval = 2)
upzone = input.color(color.new(#089981, 80), "", inline = "sz", group = "LIQUIDITY CONCEPTS")
dnzone = input.color(color.new(#f23645, 80), "", inline = "sz", group = "LIQUIDITY CONCEPTS")

lvl_daily = input.bool(false, "Day", inline = "1", group = "HIGHS & LOWS MTF")
lvl_weekly = input.bool(false, "Week", inline = "2", group = "HIGHS & LOWS MTF")
lvl_monthly = input.bool(false, "Month", inline = "3", group = "HIGHS & LOWS MTF")
lvl_quartely = input.bool(false, "Quarterly", inline = "c", group = "HIGHS & LOWS MTF")
lvl_yearly = input.bool(false, "Year", inline = "4", group = "HIGHS & LOWS MTF")
css_d = input.color(#546e7a, "", inline = "1", group = "HIGHS & LOWS MTF")
css_w = input.color(#546e7a, "", inline = "2", group = "HIGHS & LOWS MTF")
css_m = input.color(#546e7a, "", inline = "3", group = "HIGHS & LOWS MTF")
css_q = input.color(#546e7a, "", inline = "c", group = "HIGHS & LOWS MTF")
css_y = input.color(#546e7a, "", inline = "4", group = "HIGHS & LOWS MTF")
s_d = input.string('⎯⎯⎯⎯', '', inline = '1', group = 'HIGHS & LOWS MTF', options = ['⎯⎯⎯⎯', '----', '····'])
s_w = input.string('⎯⎯⎯⎯', '', inline = '2', group = 'HIGHS & LOWS MTF', options = ['⎯⎯⎯⎯', '----', '····'])
s_m = input.string('⎯⎯⎯⎯', '', inline = '3', group = 'HIGHS & LOWS MTF', options = ['⎯⎯⎯⎯', '----', '····'])
s_q = input.string('⎯⎯⎯⎯', '', inline = 'c', group = 'HIGHS & LOWS MTF', options = ['⎯⎯⎯⎯', '----', '····'])
s_y = input.string('⎯⎯⎯⎯', '', inline = '4', group = 'HIGHS & LOWS MTF', options = ['⎯⎯⎯⎯', '----', '····'])

// ──────────────────────────────────────────────────────────────
// NEW: SMOOTH TRAIL
// ──────────────────────────────────────────────────────────────
GRP_ST      = "〰️ SMOOTH TRAIL"
show_smooth = input.bool(true,  "Activate",       group = GRP_ST)
inp1        = input.float(5.7,  "Multiplier",     group = GRP_ST, step = 0.1)
inp2        = input.int(32,     "Length",         group = GRP_ST)
inp3        = input.float(1.0,  "Zone Width",     group = GRP_ST)
smooth_main = input.int(3,      "Smoothing",      group = GRP_ST, minval = 1, maxval = 10)
use_mtf     = input.bool(true,  "MTF",            group = GRP_ST, inline = "mtf")
tf_mtf      = input.timeframe("15", "",           group = GRP_ST, inline = "mtf")
smooth_mtf  = input.int(5,      "MTF Smooth",     group = GRP_ST, minval = 1, maxval = 20)

GRP_TPS      = "🎯 TP/SL Dinámicos"
show_dyn_tps = input.bool(true,  "Show TP/SL",   group = GRP_TPS)
tp1_ratio    = input.float(1.5,  "TP1 Ratio",    group = GRP_TPS, step = 0.5)
tp2_ratio    = input.float(3.0,  "TP2 Ratio",    group = GRP_TPS, step = 0.5)
offset_val   = input.int(-15,    "Line Offset",  group = GRP_TPS)
line_len_in  = input.int(35,     "Line Length",  group = GRP_TPS, minval = 10)

// ──────────────────────────────────────────────────────────────
// NEW: SNIPER SIGNALS
// ──────────────────────────────────────────────────────────────
GRP_SNIP      = "🎯 SNIPER SIGNALS"
show_sig      = input.bool(true,  "Show Signals",  group = GRP_SNIP, inline = "sn0",
     tooltip = "Metodología: Rompe EMA12 con cuerpo de vela → espera retest → entrada confirmada en el retest")
sn_ema_len    = input.int(12,    "EMA",           group = GRP_SNIP, inline = "sn0")
sn_rr         = input.float(1.7, "R:R",           group = GRP_SNIP, inline = "sn0", step = 0.1,
     tooltip = "Ratio Riesgo:Recompensa para el TP")
sn_phase_len  = input.int(20,    "Fase SL",       group = GRP_SNIP, inline = "sn1",
     tooltip = "Barras hacia atrás para calcular el máximo/mínimo de la fase (Stop Loss)")
sn_retest_win = input.int(15,    "Ventana Retest",group = GRP_SNIP, inline = "sn1",
     tooltip = "Barras máximas para esperar el retest después del rompimiento")
sn_tol_pct    = input.float(0.1, "Tolerancia %",  group = GRP_SNIP, inline = "sn2", step = 0.05,
     tooltip = "Tolerancia porcentual para detectar el retest sobre la EMA")
sn_cooldown   = input.int(20,    "Cooldown",      group = GRP_SNIP, inline = "sn2",
     tooltip = "Barras mínimas entre señales")
// Filtros de setup (RSI + MACD — condiciones previas al rompimiento)
sn_rsi_len  = input.int(14,  "RSI", group = GRP_SNIP, inline = "sn3")
sn_rsi_ob   = input.int(70,  "OB",  group = GRP_SNIP, inline = "sn3")
sn_rsi_os   = input.int(30,  "OS",  group = GRP_SNIP, inline = "sn3")
sn_mem      = input.int(10,  "Mem", group = GRP_SNIP, inline = "sn3",
     tooltip = "Barras de memoria para los filtros RSI y MACD")

// ══════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════
direc = input.string("Bullish", "Direction", ['Bullish', 'Bearish', 'Both'], group = "ANY ALERT", inline = "asd")

var array<bool> alertinputs = array.from(
     input.bool(false, "CHoCH", inline = "1", group = "ANY ALERT"),
     input.bool(false, "BOS", inline = "2", group = "ANY ALERT"),
     input.bool(false, "CHoCH Sweep", inline = "3", group = "ANY ALERT"),
     input.bool(false, "BOS Sweep", inline = "4", group = "ANY ALERT"),
     input.bool(false, "OB Mitigated", inline = "5", group = "ANY ALERT"),
     input.bool(false, "Price Inside OB", inline = "6", group = "ANY ALERT"),
     input.bool(false, "FVG Mitigated", inline = "7", group = "ANY ALERT"),
     input.bool(false, "Raid Found", inline = "8", group = "ANY ALERT"),
     input.bool(false, "Pirce Inside FVG", inline = "9", group = "ANY ALERT"),
     input.bool(false, "SFP Created", inline = "10", group = "ANY ALERT"),
     input.bool(false, "Liquidity Print", inline = "11", group = "ANY ALERT"),
     input.bool(false, "Sweep Area", inline = "12", group = "ANY ALERT")
 )

type alert_obj
    bool b = false 
    string d = na 
    string n = na 

method check(array<bool> a) =>
    var bool b = false
    if barstate.isfirst
        for i in a
            if i
                b := true
                break
    b

method add(array<alert_obj> a, int i) =>
    alert_obj c = a.get(i)
    c.b ? c.d + ' ' + c.n : na

method buffer(array<bool> inputs) =>
    array<alert_obj> a = array.new<alert_obj>()
    for i = 0 to inputs.size() - 1
        a.unshift(alert_obj.new())
    a

array<alert_obj> blalerts = alertinputs.buffer()
array<alert_obj> bralerts = alertinputs.buffer()

// ══════════════════════════════════════════════════════════════
// USER DEFINED TYPES (UDTs)
// ══════════════════════════════════════════════════════════════
type hqlzone
    box pbx
    box ebx
    box lbx
    label plb
    label elb
    label lbl

type Zphl
    line top
    line bottom
    label top_label
    label bottom_label
    bool stopcross
    bool sbottomcross
    bool itopcross
    bool ibottomcross
    string txtup
    string txtdn
    float topy
    float bottomy
    float topx
    float bottomx
    float tup
    float tdn
    int tupx
    int tdnx
    float itopy
    float itopx
    float ibottomy
    float ibottomx
    float uV
    float dV

type entered
    bool normal = false
    bool breaker = false

type store
    line[] ln
    label[] lb
    box[] bx
    linefill[] lf

type structure
    int zn
    float zz
    float bos
    float choch
    int loc
    int temp
    int trend
    int start
    float main
    int xloc
    bool upsweep
    bool dnsweep
    string txt = na

type drawms
    int x1
    int x2
    float y
    string txt
    color css
    string style

type ob
    bool bull
    float top
    float btm
    float avg
    int loc
    color css
    float vol
    int dir
    int move
    int blPOS
    int brPOS
    int xlocbl
    int xlocbr
    bool isbb = false
    int bbloc

type FVG
    float top = na
    float btm = na
    int loc = bar_index
    bool isbb = false
    int bbloc = na
    bool israid = false
    float raidy = na
    int raidloc = na
    int raidx2 = na
    bool active = false
    color raidcs = na

type SFP
    float y
    int loc
    float ancor

type sfpbuildlbl
    int x
    float y
    string style
    color css
    string txt

type sfpbuildline
    int x1
    int x2
    float y
    color css
    float ancor
    int loc

type equalbuild
    int x1
    float y1
    int x2
    float y2
    color css
    string style

type equalname
    int x
    float y
    string txt
    color css
    string style

type ehl
    float pt
    int t
    float pb
    int b

type sellbuyside
    float top
    float btm
    int loc
    color css
    string txt
    float vol

type timer
    bool start = false
    int count = 0

var store bin = store.new(array.new<line>(), array.new<label>(), array.new<box>(), array.new<linefill>())

alert_obj blalert = alert_obj.new()
alert_obj bralert = alert_obj.new()
var entered blobenter = entered.new()
var entered brobenter = entered.new()
var entered blfvgenter = entered.new()
var entered brfvgenter = entered.new()
var entered blarea = entered.new()
var entered brarea = entered.new()
var timer lc = timer.new()

if barstate.islast
    for obj in bin.ln
        obj.delete()
    for obj in bin.lb
        obj.delete()
    for obj in bin.bx
        obj.delete()
    for obj in bin.lf
        obj.delete()
    bin.ln.clear()
    bin.lb.clear()
    bin.bx.clear()
    bin.lf.clear()

invcol = #ffffff00
hl() => [high, low]

[pdh, pdl] = request.security(syminfo.tickerid, 'D', hl(), lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, 'W', hl(), lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, 'M', hl(), lookahead = barmerge.lookahead_on)
[pqh, pql] = request.security(syminfo.tickerid, '3M', hl(), lookahead = barmerge.lookahead_on)
[pyh, pyl] = request.security(syminfo.tickerid, '12M', hl(), lookahead = barmerge.lookahead_on)

float atr = (ta.atr(200) / (5/len))
float _g_atr14 = ta.atr(14)  // global para evitar CW10003

// Global extractions for CW10003/CW10018
bool   _g_fvg_cc  = not na(ta.change(time(fvg_tf)))
float  _g_sma_vol = ta.sma(volume, 21)
bool   _g_vol_sfp = (_g_sma_vol * sfpthresh) < volume
bool inZone = time >= internalDate
bool Session = inZone and not inZone[1]

method txSz(string s) =>
    out = switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        "Auto" => size.auto
    out

method lstyle(string style) =>
    out = switch style
        '⎯⎯⎯⎯' => line.style_solid
        '----' => line.style_dashed
        '····' => line.style_dotted

mtfphl(h, l, tf, css, pdhl_style) =>
    var line hl_line = line.new(na, na, na, na, xloc = xloc.bar_time, color = css, style = lstyle(pdhl_style))
    var line ll_line = line.new(na, na, na, na, xloc = xloc.bar_time, color = css, style = lstyle(pdhl_style))
    var label lbl = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}L', tf), color = invcol, textcolor = css, size = size.small, style = label.style_label_left)
    var label hlb = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}H', tf), color = invcol, textcolor = css, size = size.small, style = label.style_label_left)
    hy = ta.valuewhen(h != h[1], h, 1)
    hx = ta.valuewhen(h == high, time, 1)
    ly = ta.valuewhen(l != l[1], l, 1)
    lx = ta.valuewhen(l == low, time, 1)
    if barstate.islast
        extension = time + (time - time[1]) * 20
        line.set_xy1(hl_line, hx, hy)
        line.set_xy2(hl_line, extension, hy)
        label.set_xy(hlb, extension, hy)
        line.set_xy1(ll_line, lx, ly)
        line.set_xy2(ll_line, extension, ly)
        label.set_xy(lbl, extension, ly)

// ta.atr extraído a global (fix CW10003) — se reemplaza fvatr en dFVG con _g_fvg_atr
_g_fvg_atr = request.security(syminfo.tickerid, fvg_tf, ta.atr(200))
ghl() => request.security(syminfo.tickerid, fvg_tf, [high[2], low[2], close[1], open[1], close, open, high, low, high[1], low[1], close])

method IDMIDX(bool use_max, int loc) =>
    min = 99999999.
    max = 0.
    idx = 0
    if use_max
        for i = 0 to (bar_index - loc)
            max := math.max(high[i], max)
            min := max == high[i] ? low[i] : min
            idx := max == high[i] ? i : idx
    else
        for i = 0 to (bar_index - loc)
            min := math.min(low[i], min)
            max := min == low[i] ? high[i] : max
            idx := min == low[i] ? i : idx
    idx

SFPcords(string tf) =>
    indexHighTF = barstate.isrealtime ? 1 : 0
    indexCurrTF = barstate.isrealtime ? 0 : 1
    [h, h1, h2, l, l1, l2, c, v, t, n, t1] = request.security("", tf, [high[indexHighTF], high[1 + indexHighTF], high[2 + indexHighTF], low[indexHighTF], low[1 + indexHighTF], low[2 + indexHighTF], close[indexHighTF], volume[indexHighTF], time[indexHighTF], bar_index[indexHighTF], time[1 + indexHighTF]], lookahead = barmerge.lookahead_off)
    [h[indexCurrTF], h1[indexCurrTF], h2[indexCurrTF], l[indexCurrTF], l1[indexCurrTF], l2[indexCurrTF], c[indexCurrTF], v[indexCurrTF], t[indexCurrTF], n[indexCurrTF], t1[indexCurrTF]]

method find(structure ms, bool use_max, bool sweep, bool useob) =>
    min = 99999999.
    max = 0.
    idx = 0
    if not sweep
        if ((bar_index - ms.loc) - 1) > 0
            if use_max
                for i = 0 to (bar_index - ms.loc) - 1
                    max := math.max(high[i], max)
                    min := max == high[i] ? low[i] : min
                    idx := max == high[i] ? i : idx
                    if useob
                        if high[idx + 1] > high[idx]
                            max := high[idx + 1]
                            min := low [idx + 1]
                            idx := idx + 1
            else
                for i = 0 to (bar_index - ms.loc) - 1
                    min := math.min(low[i], min)
                    max := min == low[i] ? high[i] : max
                    idx := min == low[i] ? i : idx
                    if useob
                        if low[idx + 1] < low[idx]
                            max := high[idx + 1]
                            min := low [idx + 1]
                            idx := idx + 1
    else
        if use_max
            for i = 0 to (bar_index - ms.loc)
                max := math.max(high[i], max)
                min := max == high[i] ? low[i] : min
                idx := max == high[i] ? i : idx
                if useob
                    if high[idx + 1] > high[idx]
                        max := high[idx + 1]
                        min := low [idx + 1]
                        idx := idx + 1
        else
            for i = 0 to (bar_index - ms.loc)
                min := math.min(low[i], min)
                max := min == low[i] ? high[i] : max
                idx := min == low[i] ? i : idx
                if useob
                    if low[idx + 1] < low[idx]
                        max := high[idx + 1]
                        min := low [idx + 1]
                        idx := idx + 1
    idx

method fnOB(ob[] block, bool bull, float cords, int idx) =>
    switch bull
        true =>
            blobenter.normal := false
            blobenter.breaker := false
            block.unshift(ob.new(true, cords, low[idx], math.avg(cords, low[idx]), time[idx], obupcs, volume[idx], close[idx] > open[idx] ? 1 : -1, 1, 1, 1, time[idx]))
        false =>
            brobenter.normal := false
            brobenter.breaker := false
            block.unshift(ob.new(false, high[idx], cords, math.avg(cords, high[idx]), time[idx], obdncs, volume[idx], close[idx] > open[idx] ? 1 : -1, 1, 1, 1, time[idx]))

method mitigated(ob[] block) =>
    if barstate.isconfirmed
        for [i, stuff] in block
            if not stuff.isbb
                if stuff.bull
                    bool is_miti = false
                    if obmiti == "Close"
                        is_miti := math.min(close, open) < stuff.btm
                    else if obmiti == "Wick"
                        is_miti := low < stuff.btm
                    else if obmiti == "Avg"
                        is_miti := low < stuff.avg
                    if is_miti
                        blalerts.set(4, alert_obj.new(true, "Bullish", "OB Mitigated\n"))
                        stuff.isbb := true
                        stuff.bbloc := time
                        if not obshowbb
                            block.remove(i)
                else
                    bool is_miti = false
                    if obmiti == "Close"
                        is_miti := math.max(close, open) > stuff.top
                    else if obmiti == "Wick"
                        is_miti := high > stuff.top
                    else if obmiti == "Avg"
                        is_miti := high > stuff.avg
                    if is_miti
                        bralerts.set(4, alert_obj.new(true, "Bearish", "OB Mitigated\n"))
                        stuff.isbb := true
                        stuff.bbloc := time
                        if not obshowbb
                            block.remove(i)
            else
                if stuff.bull
                    bool is_miti = false
                    if obmiti == "Close"
                        is_miti := math.max(close, open) > stuff.top
                    else if obmiti == "Wick"
                        is_miti := high > stuff.top
                    else if obmiti == "Avg"
                        is_miti := high > stuff.avg
                    if is_miti
                        block.remove(i)
                else
                    bool is_miti = false
                    if obmiti == "Close"
                        is_miti := math.min(close, open) < stuff.btm
                    else if obmiti == "Wick"
                        is_miti := low < stuff.btm
                    else if obmiti == "Avg"
                        is_miti := low < stuff.avg
                    if is_miti
                        block.remove(i)

overlap(ob[] bull, ob[] bear) =>
    if bull.size() > 1
        for i = bull.size() - 1 to 1
            stuff = bull.get(i)
            current = bull.get(0)
            v = wichlap == "Recent" ? i : 0
            switch
                stuff.btm > current.btm and stuff.btm < current.top => bull.remove(v)
                stuff.top < current.top and stuff.btm > current.btm => bull.remove(v)
                stuff.top > current.top and stuff.btm < current.btm => bull.remove(v)
                stuff.top < current.top and stuff.top > current.btm => bull.remove(v)
    if bear.size() > 1
        for i = bear.size() - 1 to 1
            stuff = bear.get(i)
            current = bear.get(0)
            v = wichlap == "Recent" ? i : 0
            switch
                stuff.btm > current.btm and stuff.btm < current.top => bear.remove(v)
                stuff.top < current.top and stuff.btm > current.btm => bear.remove(v)
                stuff.top > current.top and stuff.btm < current.btm => bear.remove(v)
                stuff.top < current.top and stuff.top > current.btm => bear.remove(v)
    if bull.size() > 0 and bear.size() > 0
        for i = bull.size() - 1 to 0
            stuff = bull.get(i)
            current = bear.get(0)
            v = wichlap == "Recent" ? 0 : i
            switch
                stuff.btm > current.btm and stuff.btm < current.top => bull.remove(v)
                stuff.top < current.top and stuff.btm > current.btm => bull.remove(v)
                stuff.top > current.top and stuff.btm < current.btm => bull.remove(v)
                stuff.top < current.top and stuff.top > current.btm => bull.remove(v)
    if bull.size() > 0 and bear.size() > 0
        for i = bear.size() - 1 to 0
            stuff = bear.get(i)
            current = bull.get(0)
            v = wichlap == "Recent" ? 0 : i
            switch
                stuff.btm > current.btm and stuff.btm < current.top => bear.remove(v)
                stuff.top < current.top and stuff.btm > current.btm => bear.remove(v)
                stuff.top > current.top and stuff.btm < current.btm => bear.remove(v)
                stuff.top < current.top and stuff.top > current.btm => bear.remove(v)

overlapFVG(FVG[] blFVG, FVG[] brFVG) =>
    if blFVG.size() > 1
        for i = blFVG.size() - 1 to 1
            stuff = blFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)
    if brFVG.size() > 1
        for i = brFVG.size() - 1 to 1
            stuff = brFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)
    if blFVG.size() > 0 and brFVG.size() > 0
        for i = blFVG.size() - 1 to 0
            stuff = blFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)
    if blFVG.size() > 0 and brFVG.size() > 0
        for i = brFVG.size() - 1 to 0
            stuff = brFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

method umt(ob metric) =>
    switch metric.dir
        1 =>
            switch metric.move
                1 => metric.blPOS := metric.blPOS + 1, metric.move := 2
                2 => metric.blPOS := metric.blPOS + 1, metric.move := 3
                3 => metric.brPOS := metric.brPOS + 1, metric.move := 1
        -1 =>
            switch metric.move
                1 => metric.brPOS := metric.brPOS + 1, metric.move := 2
                2 => metric.brPOS := metric.brPOS + 1, metric.move := 3
                3 => metric.blPOS := metric.blPOS + 1, metric.move := 1
    if (time - time[1]) == (time[1] - time[2])
        metric.xlocbl := metric.loc + (time - time[1]) * metric.blPOS
        metric.xlocbr := metric.loc + (time - time[1]) * metric.brPOS

method display(ob id, ob[] full, int i) =>
    if not id.isbb
        bin.bx.unshift(box.new(top = id.top, bottom = id.btm, left = id.loc, right = time, border_color = na, bgcolor = id.css, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = id.top, bottom = id.btm, left = time, right = time + 1, border_color = na, bgcolor = id.css, xloc = xloc.bar_time, extend = extend.right))
    else
        bin.bx.unshift(box.new(top = id.top, bottom = id.btm, left = id.loc, right = id.bbloc, border_color = na, bgcolor = id.css, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = id.top, bottom = id.btm, left = id.bbloc, right = time, border_color = id.css, bgcolor = id.bull ? bbup : bbdn, xloc = xloc.bar_time, border_width = 2))
        bin.bx.unshift(box.new(top = id.top, bottom = id.btm, left = time, right = time + 1, border_color = id.css, bgcolor = id.bull ? bbup : bbdn, xloc = xloc.bar_time, extend = extend.right))
    if obshowactivity
        bin.bx.unshift(box.new(top = id.top, bottom = id.avg, left = id.loc, right = id.xlocbl, border_color = na, bgcolor = obactup, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = id.avg, bottom = id.btm, left = id.loc, right = id.xlocbr, border_color = na, bgcolor = obactdn, xloc = xloc.bar_time))
    if showline
        bin.ln.unshift(line.new(x1 = id.loc, x2 = time, y1 = id.avg, y2 = id.avg, color = color.new(id.css, 0), xloc = xloc.bar_time, style = line.style_dashed))
    if showmetric
        if i == math.min(oblast - 1, full.size() - 1)
            float tV = 0
            float[] dV = array.new<float>()
            seq = math.min(oblast - 1, full.size() - 1)
            for j = 0 to seq
                cV = full.get(j)
                tV += cV.vol
                if j == seq
                    for y = 0 to seq
                        dV.push(math.floor((full.get(y).vol / tV) * 100))
                        ids = full.get(y)
                        bin.lb.unshift(label.new(bar_index - 1, ids.avg, textcolor = color.new(ids.css, 0), style = label.style_label_left, size = obtxt.txSz(), color = #ffffff00, text = str.tostring(math.round(full.get(y).vol, 3), format = format.volume) + " (" + str.tostring(dV.get(y)) + "%)"))

method dispFVG(FVG fvg, int i, bool bull) =>
    ext = fvgextend ? extend.right : extend.none
    if not fvg.isbb
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = time, border_color = na, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), xloc = xloc.bar_time, color = color.new(bull ? fvg_upcss : fvg_dncss, 0), extend = ext))
        if dispraid
            bin.ln.unshift(line.new(x1 = fvg.raidloc, x2 = fvg.raidx2, y1 = fvg.raidy, y2 = fvg.raidy, xloc = xloc.bar_time, color = fvg.raidcs))
            bin.lb.unshift(label.new(x = int(math.avg(fvg.raidloc, fvg.raidx2)), y = fvg.raidy, text = "x", xloc = xloc.bar_time, textcolor = fvg.raidcs, style = bull ? label.style_label_up : label.style_label_down, size = size.small, color = #ffffff00))
    else
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = fvg.bbloc, border_color = na, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.bbloc, right = time, border_color = bull ? fvg_dncss : fvg_upcss, bgcolor = bull ? fvg_dncss : fvg_upcss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = fvg.bbloc, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_upcss : fvg_dncss, 0), xloc = xloc.bar_time))
            bin.ln.unshift(line.new(x1 = fvg.bbloc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_dncss : fvg_upcss, 0), xloc = xloc.bar_time, extend = ext, style = line.style_dashed))

dFVG(bool is_active) =>
    [h2, l2, c1, o1, c, o, h, l, h1, l1, _unused] = ghl()
    // upfvg/dnfvg y cc deben vivir fuera del if para evitar CW10018/CW10003
    bool upfvg = false
    bool dnfvg = false
    float blth = l1 + (_g_fvg_atr[1] * fvgthresh)
    float brth = h1 - (_g_fvg_atr[1] * fvgthresh)
    if what_fvg == "FVG" or what_fvg == "Breakers"
        if l > h2 and _g_fvg_cc and c1 > blth
            upfvg := true
        if l2 > h and _g_fvg_cc and c1 < brth
            dnfvg := true
    if is_active
        var FVG[] blFVG = array.new<FVG>()
        var FVG[] brFVG = array.new<FVG>()
                
        if upfvg[1]
            if blFVG.size() > 0
                fvg = blFVG.get(0)
                if fvg.israid == true and fvg.active == false
                    fvg.active := true
                    fvg.raidloc := na
                    fvg.raidx2 := na
                    fvg.raidy := na
                    fvg.raidcs := #ffffff00
            blFVG.unshift(FVG.new(l[1], h2[1], time[3], false, na))
            
        if dnfvg[1]
            if brFVG.size() > 0
                fvg = brFVG.get(0)
                if fvg.israid == true and fvg.active == false
                    fvg.active := true
                    fvg.raidloc := na
                    fvg.raidx2 := na
                    fvg.raidy := na
                    fvg.raidcs := #ffffff00
            brFVG.unshift(FVG.new(l2[1], h[1], time[3], false, na))
            
        if blFVG.size() > 0
            for [i, fvg] in blFVG
                if not fvg.isbb
                    bool is_mitigated = false
                    if fvg_src == "Close"
                        is_mitigated := math.min(c, o) < fvg.btm
                    else if fvg_src == "Wick"
                        is_mitigated := l < fvg.btm
                    else if fvg_src == "Avg"
                        is_mitigated := l < math.avg(fvg.top, fvg.btm)
                    if is_mitigated
                        blalerts.set(6, alert_obj.new(true, "Bullish", "FVG Mitigated\n"))
                        fvg.isbb := true
                        fvg.bbloc := time
                        if what_fvg == "FVG"
                            blFVG.remove(i)
                else
                    bool is_mitigated = false
                    if fvg_src == "Close"
                        is_mitigated := math.max(c, o) > fvg.top
                    else if fvg_src == "Wick"
                        is_mitigated := h > fvg.top
                    else if fvg_src == "Avg"
                        is_mitigated := h > math.avg(fvg.top, fvg.btm)
                    if is_mitigated and what_fvg == "Breakers"
                        blFVG.remove(i)
                        
        if brFVG.size() > 0
            for [i, fvg] in brFVG
                if not fvg.isbb
                    bool is_mitigated = false
                    if fvg_src == "Close"
                        is_mitigated := math.max(c, o) > fvg.top
                    else if fvg_src == "Wick"
                        is_mitigated := h > fvg.top
                    else if fvg_src == "Avg"
                        is_mitigated := h > math.avg(fvg.top, fvg.btm)
                    if is_mitigated
                        bralerts.set(6, alert_obj.new(true, "Bearish", "FVG Mitigated\n"))
                        fvg.isbb := true
                        fvg.bbloc := time
                        if what_fvg == "FVG"
                            brFVG.remove(i)
                else
                    bool is_mitigated = false
                    if fvg_src == "Close"
                        is_mitigated := math.min(c, o) < fvg.btm
                    else if fvg_src == "Wick"
                        is_mitigated := l < fvg.btm
                    else if fvg_src == "Avg"
                        is_mitigated := l < math.avg(fvg.top, fvg.btm)
                    if is_mitigated and what_fvg == "Breakers"
                        brFVG.remove(i)
                        
        if fvgoverlap
            overlapFVG(blFVG, brFVG)
            
        if blFVG.size() > 0
            fvg = blFVG.get(0)
            if not fvg.isbb
                if low < fvg.top
                    blalerts.set(8, alert_obj.new(true, "Bullish", "Price Inside FVG\n"))
        if brFVG.size() > 0
            fvg = brFVG.get(0)
            if not fvg.isbb
                if high > fvg.btm
                    bralerts.set(8, alert_obj.new(true, "Bearish", "Price Inside FVG\n"))
                    
        if dispraid
            for [i, fvg] in blFVG
                if not fvg.israid and not fvg.isbb
                    if low < fvg.top and close > fvg.top
                        fvg.israid := true
                        fvg.raidloc := time
                        fvg.raidx2 := time
                        fvg.raidy := low
                        fvg.raidcs := chart.fg_color
                else
                    if low <= fvg.raidy and fvg.active == false and not fvg.isbb
                        blalerts.set(7, alert_obj.new(true, "Bullish", "Raid Found\n"))
                        fvg.active := true
                        fvg.raidx2 := time
                    else
                        if fvg.active == false and not fvg.isbb
                            fvg.raidx2 := time
            for [i, fvg] in brFVG
                if not fvg.israid and not fvg.isbb
                    if high > fvg.btm and close < fvg.btm and not fvg.isbb
                        fvg.israid := true
                        fvg.raidloc := time
                        fvg.raidy := high
                        fvg.raidx2 := time
                        fvg.raidcs := chart.fg_color
                else
                    if high >= fvg.raidy and fvg.active == false and not fvg.isbb
                        bralerts.set(7, alert_obj.new(true, "Bearish", "Raid Found\n"))
                        fvg.active := true
                        fvg.raidx2 := time
                    else
                        if fvg.active == false and not fvg.isbb
                            fvg.raidx2 := time
                            
        if barstate.islast
            if blFVG.size() > 0 and fvg_num > 0
                for i = 0 to math.min(fvg_num - 1, blFVG.size() - 1)
                    fvg = blFVG.get(i)
                    dispFVG(fvg, i, true)
            if brFVG.size() > 0 and fvg_num > 0
                for i = 0 to math.min(fvg_num - 1, brFVG.size() - 1)
                    fvg = brFVG.get(i)
                    dispFVG(fvg, i, false)

mapping(bool is_active) =>
    if is_active
        var float up = na
        var float dn = na
        var float point = na
        var int trend = 0
        var int idx = na
        var int sum = na
        var int project = na
        var chart.point[] charts = array.new<chart.point>()
        if na(up)
            up := high
            idx := bar_index
        if na(dn)
            dn := low
            idx := bar_index
        if high > up
            if trend == -1
                id = IDMIDX(false, idx)
                charts.unshift(chart.point.from_time(time[id], low[id]))
                idx := bar_index
                point := low[id]
                sum := time[id]
            up := high
            dn := low
            project := time
            trend := 1
        if low < dn
            if trend == 1
                id = IDMIDX(true, idx)
                charts.unshift(chart.point.from_time(time[id], high[id]))
                idx := bar_index
                point := high[id]
                sum := time[id]
            up := high
            dn := low
            project := time
            trend := -1
        if barstate.islast
            var line ln = na
            var polyline pl = na
            ln.delete()
            pl.delete()
            ln := line.new(x1 = sum, x2 = project, y1 = point, y2 = trend == 1 ? up : dn, xloc = xloc.bar_time, color = color.red)
            pl := polyline.new(charts, line_color = mappingcss, xloc = xloc.bar_time, line_style = mappingStyle.lstyle())

// ══════════════════════════════════════════════════════════════
// LIQUIDITY PRINTS — versión mejorada con plotcandle wick wrap
// (Reemplaza la antigua posLIQ con plotshape)
// ══════════════════════════════════════════════════════════════
dLiquidity() =>
    var float[] lUp = array.new<float>(1, high)
    var float[] lDn = array.new<float>(1, low)
    var bool upallow = true
    var bool dnallow = true
    bool printup = false
    bool printdn = false
    float ph5 = ta.pivothigh(high, 5, 5)
    float pl5 = ta.pivotlow(low,   5, 5)
    if not na(ph5)
        lUp.set(0, ph5)
    if not na(pl5)
        lDn.set(0, pl5)
    // Bearish grab: mecha sube sobre el pivot y cierra por debajo
    if high > lUp.get(0) and close < lUp.get(0) and upallow and high > high[1]
        bralerts.set(10, alert_obj.new(true, "Bearish", "Liquidity Print\n"))
        upallow := false
        printup := true
    // Bullish grab: mecha baja sobre el pivot y cierra por encima
    if low < lDn.get(0) and close > lDn.get(0) and dnallow and low < low[1]
        blalerts.set(10, alert_obj.new(true, "Bullish", "Liquidity Print\n"))
        dnallow := false
        printdn := true
    if not na(ph5) and not upallow
        upallow := true
    if not na(pl5) and not dnallow
        dnallow := true
    [printup, printdn]

dEHL(bool is_active) =>
    var equalbuild[] bleqal = array.new<equalbuild>()
    var equalbuild[] breqal = array.new<equalbuild>()
    var equalname[] blname = array.new<equalname>()
    var equalname[] brname = array.new<equalname>()
    int pos = 2
    float thresh = 0.1
    switch ehlmode
        "Short-Term" => pos := 2, thresh := 0.1
        "Mid-Term" => pos := 6, thresh := 0.25
        "Long-Term" => pos := 10, thresh := 0.5
    var ehl w = ehl.new(0 , 0, 0 , 0)
    
    float top = ta.pivothigh(high, pos, pos)
    float btm = ta.pivotlow(low, pos, pos)
    float cur_atr = ta.atr(200)
    
    if is_active
        if not na(top)
            mx = math.max(top, w.pt)
            mn = math.min(top, w.pt)
            if mx < mn + cur_atr * thresh
                bleqal.unshift(equalbuild.new(w.t, w.pt, bar_index - pos, top, ehlupcs, line.style_dotted))
                blname.unshift(equalname.new(int(math.avg(bar_index - pos, w.t)), top, "EQH", ehlupcs, label.style_label_down))
            w.pt := top
            w.t := bar_index - pos

        if not na(btm)
            mx = math.max(btm, w.pb)
            mn = math.min(btm, w.pb)
            if mn > mx - cur_atr * thresh
                breqal.unshift(equalbuild.new(w.b, w.pb, bar_index - pos, btm, ehldowncs, line.style_dotted))
                brname.unshift(equalname.new(int(math.avg(bar_index - pos, w.b)), btm, "EQL", ehldowncs, label.style_label_up))
            w.pb := btm
            w.b := bar_index - pos

        if barstate.islast
            if bleqal.size() > 0
                for i = 0 to bleqal.size() - 1
                    draw = bleqal.get(i)
                    labe = blname.get(i)
                    if i < 10
                        bin.ln.unshift(line.new(draw.x1, draw.y1, draw.x2, draw.y2, color = draw.css, style = draw.style))
                        bin.lb.unshift(label.new(x = labe.x, y = labe.y, color = #ffffff00, style = labe.style, textcolor = labe.css, size = mstext.txSz(), text = labe.txt))
            if breqal.size() > 0
                for i = 0 to breqal.size() - 1
                    draw = breqal.get(i)
                    labe = brname.get(i)
                    if i < 10
                        bin.ln.unshift(line.new(draw.x1, draw.y1, draw.x2, draw.y2, color = draw.css, style = draw.style))
                        bin.lb.unshift(label.new(x = labe.x, y = labe.y, color = #ffffff00, style = labe.style, textcolor = labe.css, size = mstext.txSz(), text = labe.txt))

method calc_SFP(structure ms, bool is_active) =>
    [h, h1, h2, l, l1, l2, c, v, t, n, t1] = SFPcords(sfptf)
    if is_active
        if not sfpuse
            h := high
            h1 := high[1]
            h2 := high[2]
            l := low
            l1 := low[1]
            l2 := low[2]
            c := close
            v := volume
            t := time
            n := bar_index
            t1 := time[1]
        string sz = devsize.txSz()
        bool blPrint = true
        bool brPrint = true
        switch sfpfilter
            "Trend Following" =>
                switch ms.trend
                    1 => 
                        blPrint := true
                        brPrint := false
                    -1 => 
                        blPrint := false
                        brPrint := true
            "Counter Trade" =>
                switch ms.trend
                    1 => 
                        blPrint := false
                        brPrint := true
                    -1 => 
                        blPrint := true
                        brPrint := false
            => 
                blPrint := true
                brPrint := true

        var SFP[] BLsfp = array.new<SFP>()
        var SFP[] BRsfp = array.new<SFP>()
        float[] lg = array.new<float>()
        int[] tn = array.new<int>()
        float[] ac = array.new<float>()
        var sfpbuildlbl[] BLlb = array.new<sfpbuildlbl>()
        var sfpbuildlbl[] BRlb = array.new<sfpbuildlbl>()
        var sfpbuildline[] BLln = array.new<sfpbuildline>()
        var sfpbuildline[] BRln = array.new<sfpbuildline>()

        if l > l1 and l1 < l2 and _g_vol_sfp[1]
            BLsfp.clear()
            if spfuselen
                for i = 1 to sfplen
                    lg.unshift(l[i])
                    tn.unshift(t[i])
                    ac.unshift(h[i])
                BLsfp.unshift(SFP.new(lg.min(), tn.get(lg.indexof(lg.min())), ac.get(lg.indexof(lg.min()))))
                if lg.min() != l1
                    BLsfp.unshift(SFP.new(l1, t1, h1))
            else
                BLsfp.unshift(SFP.new(l1, t1, h1))

        if h < h1 and h1 > h2 and _g_vol_sfp[1]
            BRsfp.clear()
            if spfuselen
                for i = 1 to sfplen
                    lg.unshift(h[i])
                    tn.unshift(t[i])
                    ac.unshift(l[i])
                BRsfp.unshift(SFP.new(lg.max(), tn.get(lg.indexof(lg.max())), ac.get(lg.indexof(lg.max()))))
                if lg.max() != h1
                    BRsfp.unshift(SFP.new(h1, t1, l1))
            else
                BRsfp.unshift(SFP.new(h1, t1, l1))

        if BLsfp.size() > 0 and blPrint
            for i = BLsfp.size() - 1 to 0
                sfp = BLsfp.get(i)
                switch
                    c < sfp.y =>
                        BLsfp.remove(i)
                    l < sfp.y and c > sfp.y =>
                        if _g_vol_sfp
                            blalerts.set(9, alert_obj.new(true, "Bullish", "SFP Created\n"))
                            BLlb.unshift(sfpbuildlbl.new(time, (low < sfp.y ? low : sfp.y), label.style_label_up, blsfpcs, "▲\nSFP"))
                            BLln.unshift(sfpbuildline.new(sfp.loc, time, sfp.y, blsfpcs, sfp.ancor, bar_index))
                            BLsfp.remove(i)
                        else
                            BLsfp.remove(i)

        if BRsfp.size() > 0 and brPrint
            for i = BRsfp.size() - 1 to 0
                sfp = BRsfp.get(i)
                switch
                    c > sfp.y =>
                        BRsfp.remove(i)
                    h > sfp.y and c < sfp.y =>
                        if _g_vol_sfp
                            bralerts.set(9, alert_obj.new(true, "Bearish", "SFP Created\n"))
                            BRlb.unshift(sfpbuildlbl.new(time, (high > sfp.y ? high : sfp.y), label.style_label_down, brsfpcs, "SFP\n▼"))
                            BRln.unshift(sfpbuildline.new(sfp.loc, time, sfp.y, brsfpcs, sfp.ancor, bar_index))
                            BRsfp.remove(i)
                        else
                            BRsfp.remove(i)

        if barstate.islast
            if sfpshow > 0 and BLlb.size() > 0
                for i = 0 to math.min(sfpshow - 1, BLlb.size() - 1)
                    x = BLlb.get(i)
                    bin.lb.unshift(label.new(x = x.x, y = x.y, text = x.txt, color = #ffffff00, style = x.style, size = sz, textcolor = x.css, xloc = xloc.bar_time))
            if sfpshow > 0 and BRlb.size() > 0
                for i = 0 to math.min(sfpshow - 1, BRlb.size() - 1)
                    x = BRlb.get(i)
                    bin.lb.unshift(label.new(x = x.x, y = x.y, text = x.txt, color = #ffffff00, style = x.style, size = sz, textcolor = x.css, xloc = xloc.bar_time))
            if sfpshow > 0 and BLln.size() > 0
                for i = 0 to math.min(sfpshow - 1, BLln.size() - 1)
                    x = BLln.get(i)
                    bin.ln.unshift(line.new(x1 = x.x1, x2 = x.x2, y1 = x.y, y2 = x.y, color = x.css, style = line.style_solid, xloc = xloc.bar_time))
            if sfpshow > 0 and BRln.size() > 0
                for i = 0 to math.min(sfpshow - 1, BRln.size() - 1)
                    x = BRln.get(i)
                    bin.ln.unshift(line.new(x1 = x.x1, x2 = x.x2, y1 = x.y, y2 = x.y, color = x.css, style = line.style_solid, xloc = xloc.bar_time))

            if sfpshow > 0 and BLln.size() > 0 and BRln.size() > 0 and showdev
                max_loc = math.max(BLln.get(0).loc, BRln.get(0).loc)
                use = max_loc == BLln.get(0).loc ? BLln.get(0) : BRln.get(0)
                bull = max_loc == BLln.get(0).loc ? true : false
                switch bull
                    false =>
                        bin.ln.unshift(line.new(x1 = use.x1, x2 = time, y1 = use.ancor - 4.0 * (use.y - use.ancor), y2 = use.ancor - 4.0 * (use.y - use.ancor), xloc = xloc.bar_time, color = chart.fg_color, style = devstyle.lstyle()))
                        bin.ln.unshift(line.new(x1 = use.x1, x2 = time, y1 = use.ancor - 2.0 * (use.y - use.ancor), y2 = use.ancor - 2.0 * (use.y - use.ancor), xloc = xloc.bar_time, color = devcss, style = devstyle.lstyle()))
                        bin.ln.unshift(line.new(x1 = use.x1, x2 = time, y1 = use.ancor - 2.5 * (use.y - use.ancor), y2 = use.ancor - 2.5 * (use.y - use.ancor), xloc = xloc.bar_time, color = devcss, style = devstyle.lstyle()))
                        if devfill
                            bin.lf.unshift(linefill.new(bin.ln.get(0), bin.ln.get(1), color = color.new(devcss, 90)))
                        if devlvl
                            bin.lb.unshift(label.new(x = use.x1, y = use.ancor + 4.0 * (use.ancor - use.y), text = str.tostring(4.0 * 100) + "%" + " (" + str.tostring(math.round(use.ancor + 4.0 * (use.ancor - use.y), 2)) + ")", style = label.style_label_right, textcolor = chart.fg_color, color = #ffffff00, size = devsize.txSz(), xloc = xloc.bar_time))
                            bin.lb.unshift(label.new(x = use.x1, y = use.ancor + 2.0 * (use.ancor - use.y), text = str.tostring(2.0 * 100) + "%" + " (" + str.tostring(math.round(use.ancor + 2.0 * (use.ancor - use.y), 2)) + ")", style = label.style_label_right, textcolor = devcss, color = #ffffff00, size = devsize.txSz(), xloc = xloc.bar_time))
                            bin.lb.unshift(label.new(x = use.x1, y = use.ancor + 2.5 * (use.ancor - use.y), text = str.tostring(2.5 * 100) + "%" + " (" + str.tostring(math.round(use.ancor + 2.5 * (use.ancor - use.y), 2)) + ")", style = label.style_label_right, textcolor = devcss, color = #ffffff00, size = devsize.txSz(), xloc = xloc.bar_time))
                    true =>
                        bin.ln.unshift(line.new(x1 = use.x1, x2 = time, y1 = use.ancor + 4.0 * (use.ancor - use.y), y2 = use.ancor + 4.0 * (use.ancor - use.y), xloc = xloc.bar_time, color = chart.fg_color, style = devstyle.lstyle()))
                        bin.ln.unshift(line.new(x1 = use.x1, x2 = time, y1 = use.ancor + 2.0 * (use.ancor - use.y), y2 = use.ancor + 2.0 * (use.ancor - use.y), xloc = xloc.bar_time, color = devcss, style = devstyle.lstyle()))
                        bin.ln.unshift(line.new(x1 = use.x1, x2 = time, y1 = use.ancor + 2.5 * (use.ancor - use.y), y2 = use.ancor + 2.5 * (use.ancor - use.y), xloc = xloc.bar_time, color = devcss, style = devstyle.lstyle()))
                        if devfill
                            bin.lf.unshift(linefill.new(bin.ln.get(0), bin.ln.get(1), color = color.new(devcss, 90)))
                        if devlvl
                            bin.lb.unshift(label.new(x = use.x1, y = use.ancor + 4.0 * (use.ancor - use.y), text = str.tostring(4.0 * 100) + "%" + " (" + str.tostring(math.round(use.ancor + 4.0 * (use.ancor - use.y), 2)) + ")", style = label.style_label_right, textcolor = chart.fg_color, color = #ffffff00, size = devsize.txSz(), xloc = xloc.bar_time))
                            bin.lb.unshift(label.new(x = use.x1, y = use.ancor + 2.0 * (use.ancor - use.y), text = str.tostring(2.0 * 100) + "%" + " (" + str.tostring(math.round(use.ancor + 2.0 * (use.ancor - use.y), 2)) + ")", style = label.style_label_right, textcolor = devcss, color = #ffffff00, size = devsize.txSz(), xloc = xloc.bar_time))
                            bin.lb.unshift(label.new(x = use.x1, y = use.ancor + 2.5 * (use.ancor - use.y), text = str.tostring(2.5 * 100) + "%" + " (" + str.tostring(math.round(use.ancor + 2.5 * (use.ancor - use.y), 2)) + ")", style = label.style_label_right, textcolor = devcss, color = #ffffff00, size = devsize.txSz(), xloc = xloc.bar_time))

structure(color upcss, color dncss, bool draw, bool internal, int limit) =>
    var structure ms = structure.new(start = 0)
    var ob[] blob = array.new<ob>()
    var ob[] brob = array.new<ob>()
    var drawms[] bldw = array.new<drawms>()
    var drawms[] brdw = array.new<drawms>()
    var sellbuyside[] sellside = array.new<sellbuyside>()
    var sellbuyside[] buyside = array.new<sellbuyside>()
    bool crossup = false
    bool crossdn = false
    var float up = na
    var float dn = na
    idbull = ms.find(false, false, true)
    idbear = ms.find(true , false, true)
    btmP = obmode == "Length" ? (high[idbear] - 1 * atr[idbear]) < low[idbear] ? low[idbear] : (high[idbear] - 1 * atr[idbear]) : low[idbear]
    topP = obmode == "Length" ? (low[idbull] + 1 * atr[idbull]) > high[idbull] ? high[idbull] : (low[idbull] + 1 * atr[idbull]) : high[idbull]
    cur_atr = ta.atr(200)
    buy = low + cur_atr
    sel = high - cur_atr
    ph = ta.pivothigh(high, mslen, mslen)
    pl = ta.pivotlow(low , mslen, mslen)
    var int[] phn = array.new<int>(1, na)
    var int[] pln = array.new<int>(1, na)
    var float[] php = array.new<float>(1, na)
    var float[] plp = array.new<float>(1, na)
    
    if internal
        blob.clear()
        brob.clear()
    if not na(ph)
        phn.unshift(bar_index[mslen])
        php.unshift(high[mslen])
    if not na(pl)
        pln.unshift(bar_index[mslen])
        plp.unshift(low[mslen])
    if php.size() > 0
        if high > php.get(0)
            php.clear()
            phn.clear()
    if plp.size() > 0
        if low < plp.get(0)
            plp.clear()
            pln.clear()
    if na(up)
        up := high
    if na(dn)
        dn := low
    if high > up
        up := high
        dn := low
        crossup := true
    if low < dn
        up := high
        dn := low
        crossdn := true
    if ms.start == 0
        ms := structure.new(bar_index, na, high, low , bar_index, bar_index, 0, 1, na, bar_index)
        if draw
            bldw.unshift(drawms.new(time, time, high, "CHoCH", upcss, line.style_dashed))
            brdw.unshift(drawms.new(time, time, low, "CHoCH", dncss, line.style_dashed))
    ms.upsweep := false
    ms.dnsweep := false
    if ms.start == 1
        switch
            low <= ms.choch and close >= ms.choch and buildsweep =>
                bralerts.set(2, alert_obj.new(true, "Bearish", "CHoCH Sweep\n"))
                ms.dnsweep := true
                ms.choch := low
                ms.xloc := bar_index
                if draw
                    if brdw.size() > 0
                        dw = brdw.get(0)
                        dw.x2 := time
                        dw.style := line.style_dotted
                        dw.txt := "x"
                    brdw.unshift(drawms.new(time, time, low, "CHoCH", dncss, line.style_dashed))
            high >= ms.bos and close <= ms.bos and buildsweep =>
                blalerts.set(2, alert_obj.new(true, "Bullish", "CHoCH Sweep\n"))
                ms.upsweep := true
                ms.bos := high
                ms.xloc := bar_index
                if draw
                    if bldw.size() > 0
                        dw = bldw.get(0)
                        dw.x2 := time
                        dw.style := line.style_dotted
                        dw.txt := "x"
                    bldw.unshift(drawms.new(time, time, high, "CHoCH", upcss, line.style_dashed))
            close <= ms.choch =>
                bralerts.set(0, alert_obj.new(true, "Bearish", "CHoCH\n"))
                ms.txt := "choch"
                lc.start := true
                lc.count := 0
                brob.fnOB(false, btmP, idbear)
                ms.trend := -1
                ms.choch := ms.bos
                ms.bos := na
                ms.start := 2
                ms.loc := bar_index
                ms.main := low
                ms.temp := ms.loc
                ms.xloc := bar_index
                if draw
                    if brdw.size() > 0
                        dw = brdw.get(0)
                        dw.x2 := time
                        dw.style := internal ? line.style_dashed : line.style_solid
            close >= ms.bos =>
                blalerts.set(0, alert_obj.new(true, "Bullish", "CHoCH\n"))
                ms.txt := "choch"
                lc.start := true
                lc.count := 0
                blob.fnOB(true, topP, idbull)
                ms.trend := 1
                ms.choch := ms.choch
                ms.bos := na
                ms.start := 2
                ms.loc := bar_index
                ms.main := high
                ms.temp := ms.loc
                ms.xloc := bar_index
                if draw
                    if bldw.size() > 0
                        dw = bldw.get(0)
                        dw.x2 := time
                        dw.style := internal ? line.style_dashed : line.style_solid
    if ms.start == 2
        switch ms.trend
            -1 =>
                if low <= ms.main
                    ms.main := low
                    ms.temp := bar_index
                if bar_index % mslen * 2 == 0
                    if not na(ms.bos) and msmode == "Adjusted Points" and php.size() > 0
                        if php.get(0) < ms.choch
                            ms.choch := php.get(0)
                            ms.loc := phn.get(0)
                            ms.xloc := phn.get(0)
                            ms.temp := phn.get(0)
                            if draw
                                if bldw.size() > 0
                                    choch = bldw.get(0)
                                    choch.x1 := time [bar_index - phn.get(0)]
                                    choch.x2 := time
                                    choch.y := php.get(0)
                if na(ms.bos)
                    if crossup and close > open and close[1] > open[1]
                        ms.bos := ms.main
                        ms.loc := ms.temp
                        ms.xloc := ms.loc
                        if draw
                            brdw.unshift(drawms.new(time[bar_index - ms.loc], time, low[bar_index - ms.loc], "BOS", dncss, line.style_dashed))
                if not na(ms.bos) and draw
                    if brdw.size() > 0
                        dw = brdw.get(0)
                        dw.x2 := time
                if draw
                    if bldw.size() > 0
                        choch = bldw.get(0)
                        choch.x2 := time
                switch
                    low <= ms.bos and close >= ms.bos and not na(ms.bos) and buildsweep =>
                        bralerts.set(3, alert_obj.new(true, "Bearish", "BOS Sweep\n"))
                        ms.dnsweep := true
                        ms.bos := low
                        if draw
                            if brdw.size() > 0
                                dw = brdw.get(0)
                                dw.x2 := time
                                dw.style := line.style_dotted
                                dw.txt := "x"
                            brdw.unshift(drawms.new(time, time, low, "BOS", dncss, line.style_dashed))
                        if showside
                            id = ms.find(true, true, true)
                            btm = (high[id] - cur_atr) > low[id] ? (high[id] - cur_atr) : low[id]
                            sellside.unshift(sellbuyside.new(high[id], btm, time[id], sidesidecss, "Sell Side", volume[id]))
                            brarea.normal := false
                        ms.xloc := bar_index
                    close <= ms.bos and not na(ms.bos) =>
                        bralerts.set(1, alert_obj.new(true, "Bearish", "BOS\n"))
                        ms.txt := "bos"
                        ms.zz := ms.bos
                        ms.zn := bar_index
                        lc.start := true
                        lc.count := 0
                        brob.fnOB(false, btmP, idbear)
                        id = ms.find(true, false, false)
                        ms.xloc := bar_index
                        ms.bos := na
                        ms.choch := high[id]
                        ms.loc := bar_index[id]
                        if draw
                            if brdw.size() > 0
                                dw = brdw.get(0)
                                dw.x2 := time
                                dw.style := internal ? line.style_dashed : line.style_solid
                            if bldw.size() > 0
                                choch = bldw.get(0)
                                choch.x1 := time [id]
                                choch.x2 := time
                                choch.y := high[id]
                switch
                    high >= ms.choch and close <= ms.choch and buildsweep =>
                        blalerts.set(2, alert_obj.new(true, "Bullish", "CHoCH Sweep\n"))
                        ms.upsweep := true
                        ms.choch := high
                        ms.xloc := bar_index
                        if draw
                            if bldw.size() > 0
                                dw = bldw.get(0)
                                dw.x2 := time
                                dw.style := line.style_dotted
                                dw.txt := "x"
                            bldw.unshift(drawms.new(time, time, high, "CHoCH", upcss, line.style_dashed))
                    close >= ms.choch =>
                        blalerts.set(0, alert_obj.new(true, "Bullish", "CHoCH\n"))
                        ms.txt := "choch"
                        ms.zz := ms.choch
                        ms.zn := bar_index
                        lc.start := true
                        lc.count := 0
                        blob.fnOB(true, topP, idbull)
                        id = ms.find(false, false, false)
                        switch
                            na(ms.bos) =>
                                ms.choch := low[id]
                                if draw
                                    brdw.unshift(drawms.new(time, time, low, "BOS", dncss, line.style_dashed))
                                    if brdw.size() > 0
                                        choch = brdw.get(0)
                                        choch.x1 := time[bar_index - ms.temp]
                            => 
                                ms.choch := ms.bos
                        ms.bos := na
                        ms.main := high
                        ms.trend := 1
                        ms.loc := bar_index
                        ms.xloc := bar_index
                        ms.temp := ms.loc
                        if draw
                            if bldw.size() > 0
                                dw = bldw.get(0)
                                dw.x2 := time
                                dw.txt := "CHoCH"
                                dw.style := internal ? line.style_dashed : line.style_solid
                            if brdw.size() > 0
                                choch = brdw.get(0)
                                choch.x2 := time
                                choch.y := ms.choch
                                choch.txt := "CHoCH"
                        if showside
                            id2 = ms.find(false, true, true)
                            top = (low[id2] + cur_atr) < high[id2] ? (low[id2] + cur_atr) : high[id2]
                            buyside.unshift(sellbuyside.new(low[id2], top, time[id2], buysidecss, "Buy Side", volume[id2]))
                        ms.xloc := bar_index
                        blarea.normal := false
            1 =>
                if high >= ms.main
                    ms.main := high
                    ms.temp := bar_index
                if na(ms.bos)
                    if crossdn and close < open and close[1] < open[1]
                        ms.bos := ms.main
                        ms.loc := ms.temp
                        ms.xloc := ms.loc
                        if draw
                            bldw.unshift(drawms.new(time[bar_index - ms.loc], time, high[bar_index - ms.loc], "BOS", upcss, line.style_dashed))
                if bar_index % mslen * 2 == 0
                    if not na(ms.bos) and msmode == "Adjusted Points" and plp.size() > 0
                        if plp.get(0) > ms.choch
                            ms.choch := plp.get(0)
                            ms.loc := pln.get(0)
                            ms.xloc := pln.get(0)
                            ms.temp := pln.get(0)
                            if draw
                                if brdw.size() > 0
                                    choch = brdw.get(0)
                                    choch.x1 := time[bar_index - pln.get(0)]
                                    choch.x2 := time
                                    choch.y := plp.get(0)
                if not na(ms.bos) and draw
                    if bldw.size() > 0
                        dw = bldw.get(0)
                        dw.x2 := time
                if draw
                    if brdw.size() > 0
                        choch = brdw.get(0)
                        choch.x2 := time
                switch
                    high >= ms.bos and close <= ms.bos and not na(ms.bos) and buildsweep =>
                        blalerts.set(3, alert_obj.new(true, "Bullish", "BOS Sweep\n"))
                        ms.upsweep := true
                        ms.bos := high
                        if draw
                            if bldw.size() > 0
                                dw = bldw.get(0)
                                dw.x2 := time
                                dw.style := line.style_dotted
                                dw.txt := "x"
                            bldw.unshift(drawms.new(time, time, high, "BOS", upcss, line.style_dashed))
                        if showside
                            id = ms.find(false, true, true)
                            top = (low[id] + cur_atr) < high[id] ? (low[id] + cur_atr) : high[id]
                            buyside.unshift(sellbuyside.new(low[id], top, time[id], buysidecss, "Buy Side", volume[id]))
                            blarea.normal := false
                        ms.xloc := bar_index
                    close >= ms.bos and not na(ms.bos) =>
                        blalerts.set(1, alert_obj.new(true, "Bullish", "BOS\n"))
                        ms.txt := "bos"
                        ms.zz := ms.bos
                        ms.zn := bar_index
                        lc.start := true
                        lc.count := 0
                        blob.fnOB(true, topP, idbull)
                        id = ms.find(false, false, false)
                        ms.xloc := bar_index
                        ms.bos := na
                        ms.choch := low[id]
                        ms.loc := bar_index[id]
                        if draw
                            if bldw.size() > 0
                                dw = bldw.get(0)
                                dw.x2 := time
                                dw.style := internal ? line.style_dashed : line.style_solid
                            if brdw.size() > 0
                                choch = brdw.get(0)
                                choch.x1 := time[id]
                                choch.x2 := time
                                choch.y := low[id]
                switch
                    low <= ms.choch and close >= ms.choch and buildsweep =>
                        bralerts.set(2, alert_obj.new(true, "Bearish", "CHoCH Sweep\n"))
                        ms.dnsweep := true
                        ms.choch := low
                        ms.xloc := bar_index
                        if draw
                            if brdw.size() > 0
                                dw = brdw.get(0)
                                dw.x2 := time
                                dw.style := line.style_dotted
                                dw.txt := "x"
                            brdw.unshift(drawms.new(time, time, low, "CHoCH", dncss, line.style_dashed))
                    close <= ms.choch =>
                        bralerts.set(0, alert_obj.new(true, "Bearish", "CHoCH\n"))
                        ms.txt := "choch"
                        ms.zz := ms.choch
                        ms.zn := bar_index
                        lc.start := true
                        lc.count := 0
                        brob.fnOB(false, btmP, idbear)
                        id = ms.find(true, false, false)
                        switch
                            na(ms.bos) =>
                                ms.choch := high[id]
                                if draw
                                    bldw.unshift(drawms.new(time, time, high, "BOS", upcss, line.style_dashed))
                                    if bldw.size() > 0
                                        choch = bldw.get(0)
                                        choch.x1 := time[bar_index - ms.temp]
                            => 
                                ms.choch := ms.bos
                        ms.bos := na
                        ms.main := low
                        ms.trend := -1
                        ms.loc := bar_index
                        ms.temp := ms.loc
                        if draw
                            if brdw.size() > 0
                                dw = brdw.get(0)
                                dw.x2 := time
                                dw.txt := "CHoCH"
                                dw.style := internal ? line.style_dashed : line.style_solid
                            if bldw.size() > 0
                                choch = bldw.get(0)
                                choch.y := ms.choch
                                choch.x2 := time
                                choch.txt := "CHoCH"
                        if showside
                            id2 = ms.find(true, true, true)
                            btm = (high[id2] - cur_atr) > low[id2] ? (high[id2] - cur_atr) : low[id2]
                            sellside.unshift(sellbuyside.new(high[id2], btm, time[id2], sidesidecss, "Sell Side", volume[id2]))
                            brarea.normal := false
                        ms.xloc := bar_index

    if blob.size() > 0
        ob_b = blob.get(0)
        if not ob_b.isbb
            if low < ob_b.top
                if blobenter.normal == false
                    blobenter.normal := true
        else
            if high > ob_b.btm
                if blobenter.breaker == false
                    blobenter.breaker := true
    if brob.size() > 0
        ob_b = brob.get(0)
        if not ob_b.isbb
            if high > ob_b.btm
                if brobenter.normal == false
                    brobenter.normal := true
        else
            if low < ob_b.top
                if brobenter.breaker == false
                    brobenter.breaker := true

    if showside
        if buyside.size() > 0
            side = buyside.get(0)
            if low < side.btm
                if blarea.normal == false
                    blarea.normal := true
            if close < side.top
                buyside.remove(0)
        if sellside.size() > 0
            side = sellside.get(0)
            if high > side.btm
                if brarea.normal == false
                    brarea.normal := true
            if close > side.top
                sellside.remove(0)

    if barstate.islast and showside
        if buyside.size() > 0
            side = buyside.get(0)
            float sum_val = side.vol
            if buyside.size() > 0 and sellside.size() > 0
                sum_val := buyside.get(0).vol + sellside.get(0).vol
            if sum_val == 0
                sum_val := 1
            if sidemode == "Area"
                bin.bx.unshift(box.new(top = side.top, bottom = side.btm, left = side.loc, right = time, border_color = na, bgcolor = side.css, xloc = xloc.bar_time))
            bin.ln.unshift(line.new(x1 = side.loc, x2 = time, y1 = side.top, y2 = side.top, xloc = xloc.bar_time, color = color.new(side.css, 0), style = line.style_solid))
            bin.ln.unshift(line.new(x1 = bar_index, x2 = bar_index + 10, y1 = side.top, y2 = side.top, xloc = xloc.bar_index, color = color.new(side.css, 0), style = line.style_dotted))
            bin.lb.unshift(label.new(x = bar_index, y = side.top, color = #ffffff00, style = label.style_label_up, textcolor = color.new(side.css, 0), size = mstext.txSz(), text = "Buyside - " + str.tostring(math.floor((side.vol / sum_val) * 100)) + "%"))
        if sellside.size() > 0
            side = sellside.get(0)
            float sum_val = side.vol
            if buyside.size() > 0 and sellside.size() > 0
                sum_val := buyside.get(0).vol + sellside.get(0).vol
            if sum_val == 0
                sum_val := 1
            if sidemode == "Area"
                bin.bx.unshift(box.new(top = side.top, bottom = side.btm, left = side.loc, right = time, border_color = na, bgcolor = side.css, xloc = xloc.bar_time))
            bin.ln.unshift(line.new(x1 = side.loc, x2 = time, y1 = side.top, y2 = side.top, xloc = xloc.bar_time, color = color.new(side.css, 0), style = line.style_solid))
            bin.ln.unshift(line.new(x1 = bar_index, x2 = bar_index + 10, y1 = side.top, y2 = side.top, xloc = xloc.bar_index, color = color.new(side.css, 0), style = line.style_dotted))
            bin.lb.unshift(label.new(x = bar_index, y = side.top, color = #ffffff00, style = label.style_label_down, textcolor = color.new(side.css, 0), size = mstext.txSz(), text = "Sellside - "+ str.tostring(math.floor((side.vol / sum_val) * 100)) + "%"))

    if obshow and oblast > 0
        if barstate.isconfirmed
            blob.mitigated()
            brob.mitigated()
            if overlap
                overlap(blob, brob)
        if blob.size() > 0
            for [i, metric] in blob
                metric.umt()
        if brob.size() > 0
            for [i, metric] in brob
                metric.umt()
        if barstate.islast
            if blob.size() > 0
                for i = 0 to math.min(oblast - 1, blob.size() - 1)
                    obs = blob.get(i)
                    display(obs, blob, i)
            if brob.size() > 0
                for i = 0 to math.min(oblast - 1, brob.size() - 1)
                    obs = brob.get(i)
                    display(obs, brob, i)

    if barstate.islast and draw and bldw.size() > 0 and brdw.size() > 0
        for i = 0 to bldw.size() - 1
            obj = bldw.get(i)
            if i <= limit
                bin.ln.unshift(line.new(x1 = obj.x1, x2 = obj.x2, y1 = obj.y, y2 = obj.y, color = obj.css, style = obj.style, xloc = xloc.bar_time))
                bin.lb.unshift(label.new(x = int(math.avg(bin.ln.get(0).get_x1(), bin.ln.get(0).get_x2())), y = obj.y, xloc = xloc.bar_time, color = #ffffff00, style = label.style_label_down, textcolor = obj.css, size = mstext.txSz(), text = obj.txt))
                if msbubble
                    bin.lb.unshift(label.new(x = obj.x1, y = obj.y, xloc = xloc.bar_time, color = color.new(obj.css, 80), style = label.style_circle, size = size.tiny))
        for i = 0 to brdw.size() - 1
            obj = brdw.get(i)
            if i <= limit
                bin.ln.unshift(line.new(x1 = obj.x1, x2 = obj.x2, y1 = obj.y, y2 = obj.y, color = obj.css, style = obj.style, xloc = xloc.bar_time))
                bin.lb.unshift(label.new(x = int(math.avg(bin.ln.get(0).get_x1(), bin.ln.get(0).get_x2())), y = obj.y, xloc = xloc.bar_time, color = #ffffff00, style = label.style_label_up, textcolor = obj.css, size = mstext.txSz(), text = obj.txt))
                if msbubble
                    bin.lb.unshift(label.new(x = obj.x1, y = obj.y, xloc = xloc.bar_time, color = color.new(obj.css, 80), style = label.style_circle, size = size.tiny))
    ms

// ══════════════════════════════════════════════════════════════
// NEW: SMOOTH TRAIL CALCULATION
// ══════════════════════════════════════════════════════════════
calc_smooth_trail(mult, slen, zone_w) =>
    atrs = ta.atr(100)
    [supertrend, direction] = ta.supertrend(math.round(math.avg(7, mult)), slen * 2)
    hullup   = ta.hma(high, math.round(math.avg(21, slen))) + atrs * math.round(mult / 2.5)
    hulldown = ta.hma(low,  math.round(math.avg(21, slen))) - atrs * math.round(mult / 2.5)
    hline    = ta.highest(close, slen) + atrs
    lline    = ta.lowest(close,  slen) + atrs
    supert   = 0.0
    supert  := close > supertrend ? math.avg(supertrend, supertrend, supertrend, hulldown, lline) : math.avg(supertrend, supertrend, supertrend, hullup, hline)
    supert2  = 0.0
    supert2 := close > supert ? supert + atrs * zone_w : supert - atrs * zone_w
    [supert, supert2, close > supert]

// ══════════════════════════════════════════════════════════════
// EJECUCIÓN MAESTRA UNCONDICIONAL
// ══════════════════════════════════════════════════════════════
bool is_in_window = windowsis ? (bar_index > last_bar_index - mswindow) : true

structure ms = structure(swingcssup, swingcssdn, showSwing and is_in_window, false, swingLimit)

bool draw_ims = showInternal and is_in_window and inZone
structure ims = structure(interncssup, interncssdn, draw_ims, true, swingLimit)

color css = na
method darkcss(color css_val, float factor) =>
    blue = color.b(css_val) * (1 - factor)
    red = color.r(css_val) * (1 - factor)
    green = color.g(css_val) * (1 - factor)
    color.rgb(red, green, blue, 0)
    
if is_in_window
    css := ms.trend == 1 ? swingcssup : swingcssdn
    css := (ms.txt == "bos" ? css : css.darkcss(0.3))

barcolor(candlecss ? css : na)

if lc.start and showzone and is_in_window
    v = close > open ? volume : -volume
    switch ms.trend
        -1 =>
            if lc.count <= zonethresh
                if high > ms.zz and close < ms.zz
                    lc.count := 0
                if close > ms.zz
                    blalerts.set(11, alert_obj.new(true, "Bullish", "Sweep Area\n"))
                    lc.start := false
                    lc.count := 0
                    float[] pp = array.new<float>()
                    for i = 0 to bar_index - ms.zn
                        pp.unshift(low[i])
                    box.new(top = ms.zz, bottom = pp.min(), left = ms.zn - 1, right = bar_index + 1, border_color = na, bgcolor = dnzone)
                    line.new(x1 = ms.zn, x2 = bar_index, y1 = ms.zz, y2 = ms.zz, color = swingcssdn, style = line.style_dotted)
        1 =>
            if lc.count <= zonethresh
                if low < ms.zz and close > ms.zz
                    lc.count := 0
                if close < ms.zz
                    bralerts.set(11, alert_obj.new(true, "Bearish", "Sweep Area\n"))
                    lc.start := false
                    lc.count := 0
                    float[] pp = array.new<float>()
                    for i = 0 to bar_index - ms.zn
                        pp.unshift(high[i])
                    box.new(top = pp.max(), bottom = ms.zz, left = ms.zn - 1, right = bar_index + 1, border_color = na, bgcolor = upzone)
                    line.new(x1 = ms.zn, x2 = bar_index, y1 = ms.zz, y2 = ms.zz, color = swingcssup, style = line.style_dotted)
    if lc.count > zonethresh
        lc.start := false
        lc.count := 0
    lc.count += 1

dFVG(fvg_enable)
ms.calc_SFP(dispSFP and is_in_window)
dEHL(ehlshow)
mapping(showMapping)

// ── Liquidity Prints mejorados ─────────────────────────────────
// Usa dLiquidity() + plotcandle para envolver la mecha con efecto visual
// En vez de los antiguos plotshape con círculos
[uLIQ, dLIQ] = dLiquidity()

color transp = color.new(color.white, 100)

// Bearish grab: envuelve la mecha SUPERIOR de la vela (del body al high)
plotcandle(uLIQ and liqprint ? math.max(open, close) : na,
     uLIQ and liqprint ? high : na,
     uLIQ and liqprint ? math.max(open, close) : na,
     uLIQ and liqprint ? high : na,
     title  = "Liq Print Bear",
     color  = transp,
     wickcolor = transp,
     bordercolor = uLIQ and liqprint ? printupcs : na)

// Bullish grab: envuelve la mecha INFERIOR de la vela (del low al body)
plotcandle(dLIQ and liqprint ? math.min(open, close) : na,
     dLIQ and liqprint ? math.min(open, close) : na,
     dLIQ and liqprint ? low : na,
     dLIQ and liqprint ? low : na,
     title  = "Liq Print Bull",
     color  = transp,
     wickcolor = transp,
     bordercolor = dLIQ and liqprint ? printdowncs : na)

// MTF levels
if lvl_daily
    mtfphl(pdh, pdl, 'D', css_d, s_d)
if lvl_weekly
    mtfphl(pwh, pwl, 'W', css_w, s_w)
if lvl_monthly
    mtfphl(pmh, pml, 'M', css_m, s_m)
if lvl_quartely
    mtfphl(pqh, pql, 'Q', css_q, s_q)
if lvl_yearly
    mtfphl(pyh, pyl, 'Y', css_y, s_y)

var phl = Zphl.new(na, na, label.new(na, na, color = invcol, textcolor = swingcssdn, style = label.style_label_down, size = size.tiny, text = ""), label.new(na, na, color = invcol, textcolor = swingcssup, style = label.style_label_up, size = size.tiny, text = ""), true, true, true, true, "", "", 0, 0, 0, 0, high, low, 0, 0, 0, 0, 0, 0, na, na)

zhl(len_val)=>
    upper = ta.highest(len_val)
    lower = ta.lowest(len_val)
    var float out = 0
    out := high[len_val] > upper ? 0 : low[len_val] < lower ? 1 : out[1]
    top_val = out == 0 and out[1] != 0 ? high[len_val] : 0
    btm_val = out == 1 and out[1] != 1 ? low[len_val] : 0
    [top_val, btm_val]

[top, btm] = zhl(zonelen)

upphl(bool is_active, int trend) =>
    if is_active
        var label lbl = label.new(na, na, color = invcol, textcolor = swingcssdn, style = label.style_label_down, size = size.small)
        if top != 0
            phl.stopcross := true
            phl.txtup := top > phl.topy ? "HH" : "HL"
            phl.uV := volume[zonelen]
            if showhl
                if not na(phl.top)
                    line.delete(phl.top)
                phl.top := line.new(bar_index - zonelen, top, bar_index, top, color = swingcssdn)
            phl.topy := top
            phl.topx := bar_index - zonelen
            phl.tup := top
            phl.tupx := bar_index - zonelen
        if high > phl.tup
            phl.uV := volume
            phl.tup := math.max(high, phl.tup)
            phl.tupx := phl.tup == high ? bar_index : phl.tupx
        if barstate.islast and showhl
            line.set_xy1(phl.top, phl.tupx, phl.tup)
            line.set_xy2(phl.top, bar_index + 20, phl.tup)
            label.set_x(lbl, bar_index + 20)
            label.set_y(lbl, phl.tup)
            dist = math.abs(phl.uV / (phl.uV + phl.dV)) * 100
            label.set_text(lbl, trend < 0 ? "Strong High | " + str.tostring(phl.uV, format.volume) + " (" + str.tostring(math.round(dist,0)) + "%)" : "Weak High | " + str.tostring(phl.uV, format.volume) + " (" + str.tostring(math.round(dist,0)) + "%)")

dnphl(bool is_active, int trend) =>
    if is_active
        var label lbl = label.new(na, na, color = invcol, textcolor = swingcssup, style = label.style_label_up, size = size.small)
        if btm != 0
            phl.sbottomcross := true
            phl.txtdn := btm > phl.bottomy ? "LH" : "LL"
            phl.dV := volume[zonelen]
            if showhl
                if not na(phl.bottom)
                    line.delete(phl.bottom)
                phl.bottom := line.new(bar_index - 50, btm, bar_index, btm, color = swingcssup)
            phl.bottomy := btm
            phl.bottomx := bar_index - zonelen
            phl.tdn := btm
            phl.tdnx := bar_index - zonelen
        if low < phl.tdn
            phl.dV := volume
        phl.tdn := math.min(low, phl.tdn)
        phl.tdnx := phl.tdn == low ? bar_index : phl.tdnx
        if barstate.islast and showhl
            line.set_xy1(phl.bottom, phl.tdnx, phl.tdn)
            line.set_xy2(phl.bottom, bar_index + 20, phl.tdn)
            label.set_x(lbl, bar_index + 20)
            label.set_y(lbl, phl.tdn)
            dist = math.abs(phl.dV / (phl.uV + phl.dV)) * 100
            label.set_text(lbl, trend > 0 ? "Strong Low | " + str.tostring(phl.dV, format.volume) + " (" + str.tostring(math.round(dist,0)) + "%)" : "Weak Low | " + str.tostring(phl.dV, format.volume) + " (" + str.tostring(math.round(dist,0)) + "%)")

midphl(bool is_active) =>
    if is_active
        if showpdzone
            avg    = math.avg(phl.tdn, phl.tup)
            rng    = phl.tup - phl.tdn
            // Franja gris centrada en el equilibrio (±2.5% del rango, igual que premium/discount)
            eq_top = avg + rng * 0.025
            eq_btm = avg - rng * 0.025
            var box   eq_bx = box.new(na, na, na, na, bgcolor = color.new(#878b94, 70), border_color = na)
            var label lbl   = label.new(na, na, text = "Equilibrium", style = label.style_label_left, color = invcol, textcolor = #878b94, size = size.small)
            if barstate.islast and showpdzone
                more = (phl.tdnx + bar_index + 20) > (phl.tupx + bar_index + 20) ? phl.tupx : phl.tdnx
                box.set_lefttop    (eq_bx, more,          eq_top)
                box.set_rightbottom(eq_bx, bar_index + 20, eq_btm)
                label.set_xy(lbl, bar_index + 20, avg)

hqlzone(bool is_active) =>
    if is_active
        if barstate.islast and showpdzone
            var hqlzone dZone = hqlzone.new(box.new(na, na, na, na, bgcolor = color.new(swingcssdn, 70), border_color = na), na, box.new(na, na, na, na, bgcolor = color.new(swingcssup, 70), border_color = na), label.new(na, na, text = "Premium", color = invcol, textcolor = swingcssdn, style = label.style_label_down, size = size.small), na, label.new(na, na, text = "Discount", color = invcol, textcolor = swingcssup, style = label.style_label_up, size = size.small))
            dZone.pbx.set_lefttop(int(math.max(phl.topx, phl.bottomx)), phl.tup)
            dZone.pbx.set_rightbottom(bar_index + 20, 0.95 * phl.tup + 0.05 * phl.tdn)
            dZone.lbx.set_lefttop(int(math.max(phl.topx, phl.bottomx)), 0.95 * phl.tdn + 0.05 * phl.tup)
            dZone.lbx.set_rightbottom(bar_index + 20, phl.tdn)
            dZone.plb.set_xy(int(math.avg(math.max(phl.topx, phl.bottomx), int(bar_index + 20))), phl.tup)
            dZone.lbl.set_xy(int(math.avg(math.max(phl.topx, phl.bottomx), int(bar_index + 20))), phl.tdn)

upphl(is_in_window, ms.trend)
dnphl(is_in_window, ms.trend)
midphl(is_in_window)
hqlzone(is_in_window)

// ══════════════════════════════════════════════════════════════
// NEW: SMOOTH TRAIL PLOTS
// ══════════════════════════════════════════════════════════════
[st_raw, st2_raw, trend_curr] = calc_smooth_trail(inp1, inp2, inp3)
st_curr  = ta.ema(st_raw,  smooth_main)
st2_curr = ta.ema(st2_raw, smooth_main)

[mtf_st_raw, mtf_st2_raw, mtf_trend] = request.security(syminfo.tickerid, tf_mtf,
     calc_smooth_trail(inp1, inp2, inp3), lookahead = barmerge.lookahead_on)
st_mtf  = ta.ema(mtf_st_raw,  smooth_mtf)
st2_mtf = ta.ema(mtf_st2_raw, smooth_mtf)

col_curr     = trend_curr ? #089981 : #f23645
col_mtf_line = mtf_trend  ? color.new(#089981, 30) : color.new(#f23645, 30)

p_mtf_1 = plot(use_mtf and show_smooth ? st_mtf  : na, "MTF Exterior", color = color.new(col_mtf_line, 0),  linewidth = 2)
p_mtf_2 = plot(use_mtf and show_smooth ? st2_mtf : na, "MTF Interior", color = color.new(col_mtf_line, 80), linewidth = 1)
fill(p_mtf_1, p_mtf_2, color = color.new(col_mtf_line, 85), title = "MTF Fill")

p1 = plot(show_smooth ? st_curr  : na, "Main Exterior", color = color.new(col_curr, 0),  linewidth = 2)
p2 = plot(show_smooth ? st2_curr : na, "Main Interior", color = color.new(col_curr, 80), linewidth = 1)
fill(p1, p2, color = color.new(col_curr, 85), title = "Main Fill")

// ──────────────────────────────────────────────────────────────
// NEW: TP/SL DINÁMICOS (basados en el Smooth Trail)
// ──────────────────────────────────────────────────────────────
width_ch = math.abs(st_curr - st2_curr)
tp1_val  = trend_curr ? close + width_ch * tp1_ratio : close - width_ch * tp1_ratio
tp2_val  = trend_curr ? close + width_ch * tp2_ratio : close - width_ch * tp2_ratio
float sl_near = st2_curr
float sl_far  = st_curr

var line  l_tp1 = na
var line  l_tp2 = na
var line  l_sl1 = na
var line  l_sl2 = na
var label lb_tp1 = na
var label lb_tp2 = na
var label lb_sl1 = na
var label lb_sl2 = na

if barstate.islast and show_dyn_tps and show_smooth
    line.delete(l_tp1)
    line.delete(l_tp2)
    line.delete(l_sl1)
    line.delete(l_sl2)
    label.delete(lb_tp1)
    label.delete(lb_tp2)
    label.delete(lb_sl1)
    label.delete(lb_sl2)
    int x1t = bar_index + offset_val
    int x2t = x1t + line_len_in
    l_tp1  := line.new(x1t, tp1_val, x2t, tp1_val, color = color.new(#089981, 20), style = line.style_dashed, width = 1)
    lb_tp1 := label.new(x2t, tp1_val, "TP1 " + str.tostring(tp1_val, format.mintick),
         color = color.new(#1a1d2e, 90), style = label.style_label_left, textcolor = #089981, size = size.small)
    l_tp2  := line.new(x1t, tp2_val, x2t, tp2_val, color = color.new(#089981, 40), style = line.style_dashed, width = 1)
    lb_tp2 := label.new(x2t, tp2_val, "TP2 " + str.tostring(tp2_val, format.mintick),
         color = color.new(#1a1d2e, 90), style = label.style_label_left, textcolor = #089981, size = size.small)
    l_sl1  := line.new(x1t, sl_near, x2t, sl_near, color = color.new(#f23645, 20), style = line.style_dashed, width = 1)
    lb_sl1 := label.new(x2t, sl_near, "SL1 " + str.tostring(sl_near, format.mintick),
         color = color.new(#1a1d2e, 90), style = label.style_label_left, textcolor = #f23645, size = size.small)
    l_sl2  := line.new(x1t, sl_far, x2t, sl_far, color = color.new(#f23645, 40), style = line.style_dashed, width = 1)
    lb_sl2 := label.new(x2t, sl_far, "SL2 " + str.tostring(sl_far, format.mintick),
         color = color.new(#1a1d2e, 90), style = label.style_label_left, textcolor = #f23645, size = size.small)

// ══════════════════════════════════════════════════════════════
// SNIPER SIGNALS — EMA12 Break + Retest Methodology
// Fase 1: Rompe EMA12 con cuerpo de vela + setup RSI/MACD
// Fase 2: Precio retestea EMA12 → entrada confirmada
// SL: máximo/mínimo de la fase | TP: R:R 1.7
// ══════════════════════════════════════════════════════════════

// ── Indicadores base ──────────────────────────────────────────
ema_gatillo   = ta.ema(close, sn_ema_len)
sn_rsi        = ta.rsi(close, sn_rsi_len)
[sn_macdL, sn_macdS, sn_macdH] = ta.macd(close, 12, 26, 9)

// ── Filtros de setup (precondiciones) ─────────────────────────
sn_macd_bull   = sn_macdH > sn_macdH[1]
sn_macd_bear   = sn_macdH < sn_macdH[1]
// ta.barssince extraídos a globales (fix CW10002)
_g_bs_rsi_os   = ta.barssince(sn_rsi < sn_rsi_os)
_g_bs_rsi_ob   = ta.barssince(sn_rsi > sn_rsi_ob)
_g_bs_macd_bull = ta.barssince(sn_macd_bull)
_g_bs_macd_bear = ta.barssince(sn_macd_bear)
sn_setup_long  = _g_bs_rsi_os    < sn_mem and _g_bs_macd_bull < sn_mem
sn_setup_short = _g_bs_rsi_ob    < sn_mem and _g_bs_macd_bear < sn_mem

// ── Rompimiento con cuerpo de vela ────────────────────────────
// Long:  cuerpo abre bajo la EMA y cierra encima
// Short: cuerpo abre encima de la EMA y cierra debajo
bool sn_break_up   = open < ema_gatillo and close > ema_gatillo
bool sn_break_dn   = open > ema_gatillo and close < ema_gatillo

// ── Máximo/mínimo de la fase para SL ─────────────────────────
// Se calcula desde barstate global (fuera del if) para evitar CW10003
float sn_phase_low  = ta.lowest(low,   sn_phase_len)
float sn_phase_high = ta.highest(high, sn_phase_len)
float sn_ema_tol    = ema_gatillo * (sn_tol_pct / 100.0)

// ── Máquina de estados: Break → espera Retest ─────────────────
var int   sn_state       = 0    // 0=neutral 1=wait_retest_long -1=wait_retest_short
var float sn_sl          = na   // SL del setup activo
var float sn_break_ema   = na   // nivel EMA al momento del rompimiento
var int   sn_break_bar   = 0
var int   sn_last_sig    = 0
var float sn_entry_price = na   // precio de entrada en el retest

bool sn_valid_long  = false
bool sn_valid_short = false

// Fase 1 — Detectar rompimiento con setup activo
if sn_state == 0
    if sn_break_up and sn_setup_long and (bar_index - sn_last_sig) > sn_cooldown
        sn_state     := 1
        sn_sl        := sn_phase_low
        sn_break_ema := ema_gatillo
        sn_break_bar := bar_index
    else if sn_break_dn and sn_setup_short and (bar_index - sn_last_sig) > sn_cooldown
        sn_state     := -1
        sn_sl        := sn_phase_high
        sn_break_ema := ema_gatillo
        sn_break_bar := bar_index

// Expiración: si pasan más de sn_retest_win barras sin retest → invalidar
if sn_state != 0 and (bar_index - sn_break_bar) > sn_retest_win
    sn_state := 0

// Fase 2 — Detectar retest
if sn_state == 1
    // Retest largo: mecha baja toca EMA pero cierra encima → entrada
    if low <= sn_break_ema + sn_ema_tol and close > sn_break_ema
        sn_valid_long  := true
        sn_entry_price := close
        sn_last_sig    := bar_index
        sn_state       := 0
    // Invalidación: cierra por debajo de la EMA
    else if close < sn_break_ema - sn_ema_tol
        sn_state := 0

if sn_state == -1
    // Retest corto: mecha sube toca EMA pero cierra debajo → entrada
    if high >= sn_break_ema - sn_ema_tol and close < sn_break_ema
        sn_valid_short := true
        sn_entry_price := close
        sn_last_sig    := bar_index
        sn_state       := 0
    // Invalidación: cierra por encima de la EMA
    else if close > sn_break_ema + sn_ema_tol
        sn_state := 0

// ── Plot EMA gatillo ──────────────────────────────────────────
plot(show_sig ? ema_gatillo : na, "EMA Sniper",
     color = color.new(#9fa8da, 60), linewidth = 1, style = plot.style_line)

// ── Dibujo de señales ─────────────────────────────────────────
// TP/SL persistentes para la última señal
var line  sn_tp_ln  = na
var line  sn_sl_ln  = na
var label sn_tp_lb  = na
var label sn_sl_lb  = na
var label sn_entry_lb = na

if sn_valid_long and show_sig
    // Eliminar señal anterior
    line.delete(sn_tp_ln)
    line.delete(sn_sl_ln)
    label.delete(sn_tp_lb)
    label.delete(sn_sl_lb)
    label.delete(sn_entry_lb)

    float entry = sn_entry_price
    float sl    = sn_sl
    float risk  = math.abs(entry - sl)
    float tp    = entry + risk * sn_rr

    int x2 = bar_index + 40

    sn_tp_ln  := line.new(bar_index, tp, x2, tp,
         color = color.new(#089981, 20), width = 1, style = line.style_dashed)
    sn_sl_ln  := line.new(bar_index, sl, x2, sl,
         color = color.new(#f23645, 20), width = 1, style = line.style_dashed)
    sn_tp_lb  := label.new(x2, tp,
         text = "TP  " + str.tostring(tp, format.mintick) + "  (1:" + str.tostring(sn_rr, "#.#") + ")",
         style = label.style_label_left, color = color.new(#131722, 85),
         textcolor = #089981, size = size.small)
    sn_sl_lb  := label.new(x2, sl,
         text = "SL  " + str.tostring(sl, format.mintick),
         style = label.style_label_left, color = color.new(#131722, 85),
         textcolor = #f23645, size = size.small)
    // Entry label removed — trade boxes handle visualization

if sn_valid_short and show_sig
    line.delete(sn_tp_ln)
    line.delete(sn_sl_ln)
    label.delete(sn_tp_lb)
    label.delete(sn_sl_lb)
    label.delete(sn_entry_lb)

    float entry = sn_entry_price
    float sl    = sn_sl
    float risk  = math.abs(sl - entry)
    float tp    = entry - risk * sn_rr

    int x2 = bar_index + 40

    sn_tp_ln  := line.new(bar_index, tp, x2, tp,
         color = color.new(#089981, 20), width = 1, style = line.style_dashed)
    sn_sl_ln  := line.new(bar_index, sl, x2, sl,
         color = color.new(#f23645, 20), width = 1, style = line.style_dashed)
    sn_tp_lb  := label.new(x2, tp,
         text = "TP  " + str.tostring(tp, format.mintick) + "  (1:" + str.tostring(sn_rr, "#.#") + ")",
         style = label.style_label_left, color = color.new(#131722, 85),
         textcolor = #089981, size = size.small)
    sn_sl_lb  := label.new(x2, sl,
         text = "SL  " + str.tostring(sl, format.mintick),
         style = label.style_label_left, color = color.new(#131722, 85),
         textcolor = #f23645, size = size.small)
    // Entry label removed — trade boxes handle visualization

// ── Indicador visual de espera (rompimiento sin retest aún) ───
// Punto naranja pequeño en la EMA mientras espera retest
plotshape(show_sig and sn_state == 1  ? ema_gatillo : na,
     "Esperando Retest Long",  shape.circle, location.absolute,
     color.new(#089981, 40), size = size.tiny)
plotshape(show_sig and sn_state == -1 ? ema_gatillo : na,
     "Esperando Retest Short", shape.circle, location.absolute,
     color.new(#f23645, 40), size = size.tiny)

// ── Alertas ───────────────────────────────────────────────────
alertcondition(sn_valid_long,  "Sniper LONG",  "JT SMC PRO: LONG confirmado en retest EMA12")
alertcondition(sn_valid_short, "Sniper SHORT", "JT SMC PRO: SHORT confirmado en retest EMA12")

// ══════════════════════════════════════════════════════════════
// MÓDULO FIBONACCI COMPLETO
// Zigzag automático · Retrocesos · Golden Pocket · Extensiones
// Un solo botón activa todo
// ══════════════════════════════════════════════════════════════
GRP_FIB     = "📐 FIBONACCI"
show_fib    = input.bool(false, "Activar", group = GRP_FIB, inline = "f1",
     tooltip = "Activa: 23.6% · 38.2% · 50% · 61.8% · 65% · 78.6% · 81.2% · 100% · Golden Pocket · 1.272 · 1.414 · 1.618 · 2.0 · 2.618 · 3.618 · 4.236")
fib_col_ret = input.color(color.new(#9fa8da, 0), "Retrocesos",    group = GRP_FIB, inline = "f1")
fib_col_gp  = input.color(color.new(#ffd700, 0), "Golden Pocket", group = GRP_FIB, inline = "f1")
fib_col_ext = input.color(color.new(#4db6ac, 0), "Extensiones",   group = GRP_FIB, inline = "f1")

// Parámetros internos fijos (no visibles en menú)
int    fib_prd     = 23
int    fib_style   = 1
int    fib_lbl_off = 6
string fib_txt_size = "Small"
// Todos los niveles activos por defecto
bool fib_236  = true
bool fib_382  = true
bool fib_500  = true
bool fib_618  = true
bool fib_650  = true
bool fib_786  = true
bool fib_812  = true
bool fib_100  = true
bool fib_e1272 = true
bool fib_e1414 = true
bool fib_e1618 = true
bool fib_e200  = true
bool fib_e2618 = true
bool fib_e3618 = true
bool fib_e4236 = true

// ══════════════════════════════════════════════════════════════
// ZIGZAG — detecta el swing más reciente
// ══════════════════════════════════════════════════════════════
var int          fzz_dir = 0
var array<float> fzz     = array.new<float>(0)

float fzz_ph = ta.highestbars(high, fib_prd) == 0 ? high : na
float fzz_pl = ta.lowestbars(low,  fib_prd) == 0 ? low  : na

fzz_dir_new = bool(fzz_ph) and na(fzz_pl) ? 1 : bool(fzz_pl) and na(fzz_ph) ? -1 : fzz_dir
fzz_dir := fzz_dir_new

fzz_add(val, bidx) =>
    array.unshift(fzz, bidx)
    array.unshift(fzz, val)
    if array.size(fzz) > 12
        array.pop(fzz)
        array.pop(fzz)
        array.size(fzz)
    else
        array.size(fzz)

fzz_update(val, bidx) =>
    if array.size(fzz) == 0
        fzz_add(val, bidx)
    else
        if (fzz_dir == 1 and val > array.get(fzz, 0)) or (fzz_dir == -1 and val < array.get(fzz, 0))
            array.set(fzz, 0, val)
            array.set(fzz, 1, bidx)
            array.size(fzz)
        else
            array.size(fzz)

bool fzz_changed = fzz_dir != fzz_dir[1]
if bool(fzz_ph) or bool(fzz_pl)
    if fzz_changed
        fzz_add(fzz_dir == 1 ? fzz_ph : fzz_pl, bar_index)
    else
        fzz_update(fzz_dir == 1 ? fzz_ph : fzz_pl, bar_index)

// ══════════════════════════════════════════════════════════════
// TIPO Y FUNCIÓN DE NIVELES
// ══════════════════════════════════════════════════════════════
type fib_level
    float ratio
    color css
    string lbl

fib_build_levels() =>
    arr = array.new<fib_level>()
    if fib_236
        array.push(arr, fib_level.new(0.236, fib_col_ret, "23.6%"))
    if fib_382
        array.push(arr, fib_level.new(0.382, fib_col_ret, "38.2%"))
    if fib_500
        array.push(arr, fib_level.new(0.500, fib_col_ret, "50.0%"))
    if fib_618
        array.push(arr, fib_level.new(0.618, fib_col_gp,  "61.8%"))
    if fib_650
        array.push(arr, fib_level.new(0.650, fib_col_gp,  "65.0%"))
    if fib_786
        array.push(arr, fib_level.new(0.786, fib_col_ret, "78.6%"))
    if fib_812
        array.push(arr, fib_level.new(0.812, fib_col_ret, "81.2%"))
    if fib_100
        array.push(arr, fib_level.new(1.000, fib_col_ret, "100%"))
    if fib_e1272
        array.push(arr, fib_level.new(1.272, fib_col_ext, "1.272"))
    if fib_e1414
        array.push(arr, fib_level.new(1.414, fib_col_ext, "1.414"))
    if fib_e1618
        array.push(arr, fib_level.new(1.618, fib_col_ext, "1.618"))
    if fib_e200
        array.push(arr, fib_level.new(2.000, fib_col_ext, "2.0"))
    if fib_e2618
        array.push(arr, fib_level.new(2.618, fib_col_ext, "2.618"))
    if fib_e3618
        array.push(arr, fib_level.new(3.618, fib_col_ext, "3.618"))
    if fib_e4236
        array.push(arr, fib_level.new(4.236, fib_col_ext, "4.236"))
    arr

// ══════════════════════════════════════════════════════════════
// DIBUJO EN barstate.islast
// ══════════════════════════════════════════════════════════════
fib_txt_sz = switch fib_txt_size
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.huge

var array<line>  fib_lines  = array.new<line>(0)
var array<label> fib_labels = array.new<label>(0)
var box   fib_gp_box = box.new(na, na, na, na,
     bgcolor = color.new(#ffd700, 80), border_color = color.new(#ffd700, 0))
var label fib_gp_lbl = label.new(na, na, "Golden Pocket", style = label.style_label_left,
     color = color.new(#131722, 85), textcolor = #ffd700, size = size.tiny)

if show_fib and barstate.islast and array.size(fzz) >= 6
    for ln in fib_lines
        line.delete(ln)
    for lb in fib_labels
        label.delete(lb)
    array.clear(fib_lines)
    array.clear(fib_labels)

    float fzz_A  = array.get(fzz, 2)
    int   fzz_Ax = math.round(array.get(fzz, 3))
    float fzz_B  = array.get(fzz, 0)

    float swing_diff = fzz_A - fzz_B
    int   x_left     = fzz_Ax - 70
    int   x_right    = bar_index + fib_lbl_off

    int   fib_line_end = bar_index + 5       // línea termina aquí
    int   fib_lbl_x    = bar_index + 6       // label empieza aquí (fuera de la línea)

    levels = fib_build_levels()
    for lv in levels
        float lv_price = fzz_B + swing_diff * lv.ratio
        ln = line.new(x_left, lv_price, fib_line_end, lv_price,
             color = color.new(lv.css, 20), width = fib_style, extend = extend.none)
        lb = label.new(fib_lbl_x, lv_price,
             text = lv.lbl + "   " + str.tostring(math.round_to_mintick(lv_price)),
             textcolor = lv.css, style = label.style_label_left,
             color = color.new(#131722, 85), size = fib_txt_sz)
        array.push(fib_lines,  ln)
        array.push(fib_labels, lb)

    // Golden Pocket: caja entre 61.8% y 65.0%
    float gp_top = fzz_B + swing_diff * 0.650
    float gp_btm = fzz_B + swing_diff * 0.618
    float gp_hi  = math.max(gp_top, gp_btm)
    float gp_lo  = math.min(gp_top, gp_btm)
    box.set_lefttop    (fib_gp_box, x_left,      gp_hi)
    box.set_rightbottom(fib_gp_box, fib_line_end, gp_lo)
    label.set_xy(fib_gp_lbl, fib_lbl_x, math.avg(gp_hi, gp_lo))

if not show_fib and barstate.islast
    box.set_lefttop    (fib_gp_box, bar_index, na)
    box.set_rightbottom(fib_gp_box, bar_index, na)
    label.set_text(fib_gp_lbl, "")
    for ln in fib_lines
        line.delete(ln)
    for lb in fib_labels
        label.delete(lb)
    array.clear(fib_lines)
    array.clear(fib_labels)


// ══════════════════════════════════════════════════════════════
// OBJETIVOS DE PRECIO — Cálculo y Dibujo
// ══════════════════════════════════════════════════════════════

// ── Anchored VWAP: se resetea con cada cambio de swing ────────
var float _avwap_pv  = 0.0
var float _avwap_vol = 0.0
if fzz_changed
    _avwap_pv  := 0.0
    _avwap_vol := 0.0
_avwap_vol += volume
_avwap_pv  += hlc3 * volume
float avwap_line = _avwap_vol > 0 ? _avwap_pv / _avwap_vol : na

// ── Week Open / Month Open (sin repaint) ──────────────────────
float obj_wopen = request.security(syminfo.tickerid, "W", open, lookahead = barmerge.lookahead_on)
float obj_mopen = request.security(syminfo.tickerid, "M", open, lookahead = barmerge.lookahead_on)

// ── Step psicológico automático según magnitud del precio ─────
// Para precio=84 → step=5 (80,85,90) | precio=8400 → step=500
float _lp        = math.log(math.max(math.abs(close), 0.0001)) / math.log(10)
float _psyc_step = 5.0 * math.pow(10.0, math.floor(_lp) - 1.0)

// ── Plot VWAP Anclado (continuo — necesita plot()) ─────────────
plot(show_obj ? avwap_line : na, "VWAP Anclado al Swing",
     color = color.new(obj_col_vwap, 20), linewidth = 1, style = plot.style_line)

// ── Objetos persistentes ──────────────────────────────────────
var line[] obj_fib_lns   = array.new<line>()
var label[] obj_fib_lbs  = array.new<label>()
var line[] obj_psyc_lns  = array.new<line>()

var line  obj_wopen_ln  = line.new(na, na, na, na, width = 1, color = color.new(obj_col_open, 20), style = line.style_dashed)
var line  obj_mopen_ln  = line.new(na, na, na, na, width = 1, color = color.new(obj_col_open, 30), style = line.style_dashed)
var label obj_wopen_lb  = label.new(na, na, "W.Open", style = label.style_label_left, color = color.new(#131722, 85), textcolor = obj_col_open, size = size.small)
var label obj_mopen_lb  = label.new(na, na, "M.Open", style = label.style_label_left, color = color.new(#131722, 85), textcolor = obj_col_open, size = size.small)

if barstate.islast
    if show_obj
        // ── Fibonacci extra ───────────────────────────────────
        for ln in obj_fib_lns
            line.delete(ln)
        for lb in obj_fib_lbs
            label.delete(lb)
        array.clear(obj_fib_lns)
        array.clear(obj_fib_lbs)

        if array.size(fzz) >= 4
            float fA   = array.get(fzz, 2)
            float fB   = array.get(fzz, 0)
            int   xA   = math.round(array.get(fzz, 3))
            float diff = fA - fB
            int x_l   = xA - 70
            int x_r   = bar_index + 35
            int lbl_x = bar_index + 20

            xratios = array.from(0.886, 1.13, -0.272, -0.618)
            xlbls   = array.from("0.886", "1.13", "-0.272", "-0.618")
            int obj_line_end = bar_index + 5
            int obj_lbl_x    = bar_index + 6
            for i = 0 to 3
                float lvl   = fB + diff * array.get(xratios, i)
                string txt  = array.get(xlbls, i) + "   " + str.tostring(math.round_to_mintick(lvl))
                array.push(obj_fib_lns, line.new(x_l, lvl, obj_line_end, lvl,
                     color = color.new(obj_col_fib, 20), width = 1, style = line.style_dashed))
                array.push(obj_fib_lbs, label.new(obj_lbl_x, lvl, txt,
                     style = label.style_label_left,
                     color = color.new(#131722, 85), textcolor = obj_col_fib, size = size.small))

        // ── Week Open / Month Open ────────────────────────────
        line.set_xy1(obj_wopen_ln, bar_index - 80, obj_wopen)
        line.set_xy2(obj_wopen_ln, bar_index + 5,  obj_wopen)
        line.set_extend(obj_wopen_ln, extend.none)
        label.set_xy  (obj_wopen_lb, bar_index + 6, obj_wopen)
        label.set_text(obj_wopen_lb, "W.Open   " + str.tostring(obj_wopen, format.mintick))

        line.set_xy1(obj_mopen_ln, bar_index - 80, obj_mopen)
        line.set_xy2(obj_mopen_ln, bar_index + 5,  obj_mopen)
        line.set_extend(obj_mopen_ln, extend.none)
        label.set_xy  (obj_mopen_lb, bar_index + 6, obj_mopen)
        label.set_text(obj_mopen_lb, "M.Open   " + str.tostring(obj_mopen, format.mintick))

        // ── Psicológicos (3 arriba y 3 abajo del precio) ──────
        for ln in obj_psyc_lns
            line.delete(ln)
        array.clear(obj_psyc_lns)

        float psyc_base = math.floor(close / _psyc_step) * _psyc_step
        for i = -3 to 3
            float lvl = psyc_base + i * _psyc_step
            if math.abs(lvl - close) > _psyc_step * 0.001
                array.push(obj_psyc_lns, line.new(bar_index - 50, lvl, bar_index + 1, lvl,
                     color = color.new(obj_col_psyc, 40), width = 1,
                     style = line.style_dotted, extend = extend.right))

    else
        // Ocultar todo cuando está desactivado
        for ln in obj_fib_lns
            line.delete(ln)
        for lb in obj_fib_lbs
            label.delete(lb)
        array.clear(obj_fib_lns)
        array.clear(obj_fib_lbs)
        for ln in obj_psyc_lns
            line.delete(ln)
        array.clear(obj_psyc_lns)
        line.set_xy1(obj_wopen_ln, bar_index, na)
        line.set_xy1(obj_mopen_ln, bar_index, na)
        label.set_text(obj_wopen_lb, "")
        label.set_text(obj_mopen_lb, "")

// ══════════════════════════════════════════════════════════════
// VOLUME PROFILE — Fixed Range · POC · Value Area · HVN/LVN
// Usa arrays var propios (NO comparte bin) → rendering garantizado
// ta.highest / ta.lowest calculados incondicionalmente (fix CW10003)
// ══════════════════════════════════════════════════════════════
GRP_VP    = "📊 VOLUME PROFILE"
show_vp   = input.bool(false, "Activar", group = GRP_VP, inline = "vpA",
     tooltip = "Volume Profile: barras UP/DN · POC rojo · VAH/VAL azul · HVN como cajas sutiles")
vp_lb     = input.int(360,   "Lookback", group = GRP_VP, inline = "vpA", minval = 50, maxval = 1000)
vp_rows   = input.int(100,   "Rows",     group = GRP_VP, inline = "vpB", minval = 30, maxval = 130)
vp_width  = input.float(31,  "Width",    group = GRP_VP, inline = "vpB", minval = 5,  maxval = 150)
vp_hoff   = input.int(180,   "Offset",   group = GRP_VP, inline = "vpC", minval = 20, maxval = 500)
vp_va_pct = input.float(70,  "VA %",     group = GRP_VP, inline = "vpC", minval = 50, maxval = 95)
// Colores alineados a la paleta del indicador
vp_c_up   = input.color(color.new(#089981, 85), "Up",  group = GRP_VP, inline = "vpD")
vp_c_dn   = input.color(color.new(#f23645, 85), "Dn",  group = GRP_VP, inline = "vpD")
vp_c_poc  = input.color(color.new(#f23645, 0),  "POC", group = GRP_VP, inline = "vpD")
vp_c_va   = input.color(color.new(#2962ff, 0),  "VA",  group = GRP_VP, inline = "vpE")
vp_c_hvn  = input.color(color.new(#b2b5be, 70), "HVN", group = GRP_VP, inline = "vpE")
show_va_lines = input.bool(true, "VAH/VAL Lines",       group = GRP_VP, inline = "vpF",
     tooltip = "Mostrar/ocultar las líneas punteadas azules de VAH y VAL")
vp_trans_va   = input.int(65,   "Trans.VA",              group = GRP_VP, inline = "vpF",
     minval = 0, maxval = 95, tooltip = "Transparencia barras DENTRO del Value Area (0=sólido, 95=invisible)")
vp_trans_out  = input.int(85,   "Trans.Out",             group = GRP_VP, inline = "vpF",
     minval = 0, maxval = 95, tooltip = "Transparencia barras FUERA del Value Area (0=sólido, 95=invisible)")

var array<box>   _vp_bx = array.new<box>()
var array<line>  _vp_ln = array.new<line>()
var array<label> _vp_lb = array.new<label>()

float _vp_ph = ta.highest(high, vp_lb)
float _vp_pl = ta.lowest(low,   vp_lb)

if show_vp and barstate.islast
    for o in _vp_bx
        o.delete()
    for o in _vp_ln
        o.delete()
    for o in _vp_lb
        o.delete()
    array.clear(_vp_bx)
    array.clear(_vp_ln)
    array.clear(_vp_lb)

    int   rows = vp_rows
    float ph   = _vp_ph
    float pl   = _vp_pl
    float rng  = ph - pl

    if rng > 0
        float bsz = rng / rows
        array<float> vol_tot = array.new_float(rows, 0.0)
        array<float> vol_up  = array.new_float(rows, 0.0)
        array<float> vol_dn  = array.new_float(rows, 0.0)
        int lb = math.min(vp_lb, bar_index)

        for i = 0 to lb - 1
            float hi = high[i]
            float lo = low[i]
            float v  = volume[i]
            bool  bu = close[i] >= open[i]
            int blo  = math.max(0,   math.min(rows-1, int((lo - pl) / bsz)))
            int bhi  = math.max(blo, math.min(rows-1, int((hi - pl) / bsz)))
            int span = math.max(1, bhi - blo + 1)
            float vb = v / span
            for b = blo to bhi
                if b >= 0 and b < rows
                    array.set(vol_tot, b, array.get(vol_tot, b) + vb)
                    if bu
                        array.set(vol_up, b, array.get(vol_up, b) + vb)
                    else
                        array.set(vol_dn, b, array.get(vol_dn, b) + vb)

        float max_v  = array.max(vol_tot)
        int   poc_i  = math.max(0, math.min(rows-1, array.indexof(vol_tot, max_v)))
        float poc_p  = pl + (poc_i + 0.5) * bsz
        float tot_v  = array.sum(vol_tot)

        float va_v   = max_v
        int   va_lo  = poc_i
        int   va_hi  = poc_i
        float va_tgt = tot_v * (vp_va_pct / 100.0)
        while va_v < va_tgt and (va_lo > 0 or va_hi < rows-1)
            float vd = va_lo > 0      ? array.get(vol_tot, va_lo-1) : 0.0
            float vu = va_hi < rows-1 ? array.get(vol_tot, va_hi+1) : 0.0
            if vu >= vd
                va_hi := math.min(rows-1, va_hi+1)
                va_v  += vu
            else
                va_lo := math.max(0, va_lo-1)
                va_v  += vd
        float vah_p = pl + (va_hi + 1) * bsz
        float val_p = pl +  va_lo      * bsz

        // HVN — picos locales (ventana 9% del total de rows)
        float avg_v  = tot_v / rows
        float std_v  = 0.0
        for b = 0 to rows-1
            float d = array.get(vol_tot, b) - avg_v
            std_v  += d * d
        std_v := math.sqrt(std_v / rows)
        int peak_w   = math.max(1, int(rows * 0.09))
        array<bool> is_hvn = array.new_bool(rows, false)
        for b = peak_w to rows - 1 - peak_w
            float bv = array.get(vol_tot, b)
            if bv < avg_v * 1.2
                continue
            bool ok = true
            for k = 1 to peak_w
                if array.get(vol_tot, b-k) >= bv or array.get(vol_tot, b+k) >= bv
                    ok := false
                    break
            if ok
                array.set(is_hvn, b, true)

        // ── Coordenadas: baseline DERECHA, barras → IZQUIERDA ──
        float max_bw = vp_width * (lb / 100.0)
        int   x_wall = bar_index + vp_hoff
        int   x_far  = x_wall - int(max_bw)
        int   lbl_x  = x_wall + 1

        // ── Baseline vertical ─────────────────────────────────
        array.push(_vp_ln, line.new(
             x1 = x_wall, y1 = ph, x2 = x_wall, y2 = pl,
             color = color.new(#546e7a, 20), width = 1))

        // ── Barras del histograma ─────────────────────────────
        // Capa DN (fondo, rojo) + Capa UP (encima, verde)
        // Dentro del VA: transparencia reducida (más visible = 65%)
        // Fuera del VA: 85% transparente (muy sutil)
        for b = 0 to rows-1
            float bv   = array.get(vol_tot, b)
            float bv_u = array.get(vol_up,  b)
            float blo_p = pl + b       * bsz
            float bhi_p = pl + (b + 1) * bsz
            bool  is_va  = b >= va_lo and b <= va_hi
            bool  is_poc_bin = b == poc_i

            int tot_w = max_v > 0 ? math.max(1, int((bv   / max_v) * max_bw)) : 1
            int up_w  = max_v > 0 ? math.max(0, int((bv_u / max_v) * max_bw)) : 0
            int x_tot = x_wall - tot_w
            int x_up  = x_wall - up_w

            if is_poc_bin
                // POC: rojo más sólido
                array.push(_vp_bx, box.new(
                     left = x_tot, top = bhi_p, right = x_wall, bottom = blo_p,
                     border_color = na,
                     bgcolor = color.new(vp_c_poc, 55)))
            else
                // Capa DN (rojo) — barra completa
                color dn_c = is_va ? color.new(#f23645, vp_trans_va) : color.new(#f23645, vp_trans_out)
                if tot_w > 0
                    array.push(_vp_bx, box.new(
                         left = x_tot, top = bhi_p, right = x_wall, bottom = blo_p,
                         border_color = na, bgcolor = dn_c))
                // Capa UP (verde) — solo porción alcista
                color up_c = is_va ? color.new(#089981, vp_trans_va) : color.new(#089981, vp_trans_out)
                if up_w > 0
                    array.push(_vp_bx, box.new(
                         left = x_up, top = bhi_p, right = x_wall, bottom = blo_p,
                         border_color = na, bgcolor = up_c))

        // ── POC: línea roja que atraviesa todo el lookback ────
        array.push(_vp_ln, line.new(
             x1 = bar_index - lb, y1 = poc_p, x2 = x_wall, y2 = poc_p,
             color = color.new(vp_c_poc, 0), width = 2))
        array.push(_vp_lb, label.new(
             x = lbl_x, y = poc_p,
             text = str.tostring(poc_p, format.mintick),
             style = label.style_label_left,
             color = color.new(#131722, 5), textcolor = vp_c_poc, size = size.small))

        // ── VAH / VAL: controlado por show_va_lines ──────────
        if show_va_lines
            array.push(_vp_ln, line.new(
                 x1 = x_far, y1 = vah_p, x2 = x_wall, y2 = vah_p,
                 color = color.new(vp_c_va, 20), width = 1, style = line.style_dotted))
            array.push(_vp_lb, label.new(
                 x = lbl_x, y = vah_p,
                 text = str.tostring(vah_p, format.mintick),
                 style = label.style_label_left,
                 color = color.new(#131722, 5), textcolor = vp_c_va, size = size.small))
            array.push(_vp_ln, line.new(
                 x1 = x_far, y1 = val_p, x2 = x_wall, y2 = val_p,
                 color = color.new(vp_c_va, 20), width = 1, style = line.style_dotted))
            array.push(_vp_lb, label.new(
                 x = lbl_x, y = val_p,
                 text = str.tostring(val_p, format.mintick),
                 style = label.style_label_left,
                 color = color.new(#131722, 5), textcolor = vp_c_va, size = size.small))

        // ── HVN: cajas muy sutiles que atraviesan el chart ────
        // Altura fina (20% del bin), muy transparente, sin border
        for b = 0 to rows-1
            if array.get(is_hvn, b)
                float blo_p = pl + b       * bsz
                float bhi_p = pl + (b + 1) * bsz
                float mid_p = (blo_p + bhi_p) / 2.0
                float half  = bsz * 0.18
                array.push(_vp_bx, box.new(
                     left   = bar_index - lb,
                     top    = mid_p + half,
                     right  = x_wall,
                     bottom = mid_p - half,
                     border_color = na,
                     bgcolor = vp_c_hvn))

if not show_vp and barstate.islast
    for o in _vp_bx
        o.delete()
    for o in _vp_ln
        o.delete()
    for o in _vp_lb
        o.delete()
    array.clear(_vp_bx)
    array.clear(_vp_ln)
    array.clear(_vp_lb)




// ══════════════════════════════════════════════════════════════
// SNIPER DASHBOARD — Backtesting últimas 20 señales
// Estrategia: EMA12 Break → Retest → Entrada
// SL: máximo/mínimo de la fase  TP: R:R 1.7
// ══════════════════════════════════════════════════════════════
GRP_BT    = "📋 SNIPER BACKTESTING"
show_bt   = input.bool(true,  "Dashboard",    group = GRP_BT, inline = "bt1",
     tooltip = "Tabla de las últimas 20 señales Sniper con Win Rate")
show_bt_boxes = input.bool(true, "Trade Boxes", group = GRP_BT, inline = "bt1",
     tooltip = "Muestra el recuadro de cada operación en el chart (verde=win, rojo=loss)")
bt_max    = input.int(20,     "Mostrar",       group = GRP_BT, inline = "bt2",
     minval = 5, maxval = 50, tooltip = "Número de señales a mostrar en la tabla")
bt_expire = input.int(100,    "Max Barras",    group = GRP_BT, inline = "bt2",
     minval = 10, maxval = 500, tooltip = "Barras máximas antes de expirar un trade abierto (evita que se alarguen al infinito)")

// ── Tipos para almacenar trades ───────────────────────────────
type sn_trade
    bool   is_long
    float  entry
    float  sl
    float  tp
    int    bar_in
    int    bar_out  = -1
    bool   is_win   = false
    bool   closed   = false

// ── Array persistente de trades ───────────────────────────────
var array<sn_trade> sn_trades = array.new<sn_trade>()

// ── Registrar nueva señal ─────────────────────────────────────
if sn_valid_long
    sn_trades.unshift(sn_trade.new(
         is_long = true,
         entry   = sn_entry_price,
         sl      = sn_sl,
         tp      = sn_entry_price + math.abs(sn_entry_price - sn_sl) * sn_rr,
         bar_in  = bar_index))
    if sn_trades.size() > bt_max + 5
        sn_trades.pop()

if sn_valid_short
    sn_trades.unshift(sn_trade.new(
         is_long = false,
         entry   = sn_entry_price,
         sl      = sn_sl,
         tp      = sn_entry_price - math.abs(sn_sl - sn_entry_price) * sn_rr,
         bar_in  = bar_index))
    if sn_trades.size() > bt_max + 5
        sn_trades.pop()

// ── Evaluar si un trade abierto llegó a TP, SL o expiró ─────────
if sn_trades.size() > 0
    for t in sn_trades
        if not t.closed
            // Expirar trades que llevan demasiadas barras abiertos
            if (bar_index - t.bar_in) >= bt_expire
                t.closed  := true
                t.is_win  := false
                t.bar_out := t.bar_in + bt_expire
            else if t.is_long
                if low  <= t.sl
                    t.closed  := true
                    t.is_win  := false
                    t.bar_out := bar_index
                else if high >= t.tp
                    t.closed  := true
                    t.is_win  := true
                    t.bar_out := bar_index
            else
                if high >= t.sl
                    t.closed  := true
                    t.is_win  := false
                    t.bar_out := bar_index
                else if low  <= t.tp
                    t.closed  := true
                    t.is_win  := true
                    t.bar_out := bar_index

// ── Trade Boxes en el chart ───────────────────────────────────
var array<box>   bt_bx_entry = array.new<box>()
var array<box>   bt_bx_tp    = array.new<box>()

var array<line>  bt_ln_entry = array.new<line>()

if show_bt_boxes and barstate.islast
    for o in bt_bx_entry
        o.delete()
    for o in bt_bx_tp
        o.delete()
    for o in bt_ln_entry
        o.delete()
    array.clear(bt_bx_entry)
    array.clear(bt_bx_tp)
    array.clear(bt_ln_entry)

    int shown = 0
    for t in sn_trades
        if shown >= bt_max
            break
        int x1 = t.bar_in
        int x2 = t.closed ? t.bar_out : bar_index
        // Caja SL (riesgo) — siempre ROJA
        array.push(bt_bx_entry, box.new(
             left = x1, top = math.max(t.entry, t.sl),
             right = x2, bottom = math.min(t.entry, t.sl),
             border_color = color.new(#f23645, 50),
             bgcolor = color.new(#f23645, 88), border_width = 1))
        // Caja TP (recompensa) — siempre VERDE (más opaca si ganó)
        color tp_bg  = t.closed ? (t.is_win ? color.new(#089981, 78) : color.new(#089981, 90)) : color.new(#089981, 88)
        color tp_brd2 = color.new(#089981, t.closed and t.is_win ? 40 : 65)
        array.push(bt_bx_tp, box.new(
             left = x1, top = math.max(t.entry, t.tp),
             right = x2, bottom = math.min(t.entry, t.tp),
             border_color = tp_brd2,
             bgcolor = tp_bg, border_width = 1))
        // Línea de entrada
        array.push(bt_ln_entry, line.new(
             x1 = x1, y1 = t.entry, x2 = x2, y2 = t.entry,
             color = color.new(#b2b5be, 30), width = 1,
             style = line.style_dashed))
        shown += 1

// ── Dashboard: WR compacto + Monitor Multi-Activo ────────────
// Helper para obtener datos por activo (request.security)
// ══════════════════════════════════════════════════════════════
// MULTI-ASSET MONITOR — datos por activo via request.security
// Sin tuple destructuring de UDFs — Pine v6 compatible
// ══════════════════════════════════════════════════════════════

// ── Macro para extraer datos de cada activo ───────────────────
// Pine v6: request.security solo con expresiones nativas, sin UDF tuple
// Cada activo necesita sus propias llamadas separadas

// Helper: MACD histogram anterior (fix CE10156 — [2][1] no permitido)
// Se extrae con [1] sobre ta.macd(...)[2] como expresión completa
// ── 1 request.security call per asset (6 total — fix RE10137) ──
// Cada activo retorna: [close, close1, ema12, rsi14, macdh, macdh1]
_asset_tuple() =>
    [_ml, _sl, _mh] = ta.macd(close, 12, 26, 9)
    [close, close[1], ta.ema(close, 12), ta.rsi(close, 14), nz(_mh), nz(_mh[1])]

[_btc_close, _btc_close1, _btc_ema, _btc_rsi, _btc_macdh, _btc_macdh1] = request.security("BINANCE:BTCUSDT.P", timeframe.period, _asset_tuple(), lookahead=barmerge.lookahead_off)
[_eth_close, _eth_close1, _eth_ema, _eth_rsi, _eth_macdh, _eth_macdh1] = request.security("BINANCE:ETHUSDT.P", timeframe.period, _asset_tuple(), lookahead=barmerge.lookahead_off)
[_sol_close, _sol_close1, _sol_ema, _sol_rsi, _sol_macdh, _sol_macdh1] = request.security("BINANCE:SOLUSDT.P", timeframe.period, _asset_tuple(), lookahead=barmerge.lookahead_off)
[_xau_close, _xau_close1, _xau_ema, _xau_rsi, _xau_macdh, _xau_macdh1] = request.security("OANDA:XAUUSD",     timeframe.period, _asset_tuple(), lookahead=barmerge.lookahead_off)
[_nq_close,  _nq_close1,  _nq_ema,  _nq_rsi,  _nq_macdh,  _nq_macdh1]  = request.security("CME_MINI:NQ1!",    timeframe.period, _asset_tuple(), lookahead=barmerge.lookahead_off)
[_spx_close, _spx_close1, _spx_ema, _spx_rsi, _spx_macdh, _spx_macdh1] = request.security("CME_MINI:ES1!",    timeframe.period, _asset_tuple(), lookahead=barmerge.lookahead_off)

// ── Calcular métricas derivadas ───────────────────────────────
// Función helper — Pine v6 compatible (no retorna tuple, solo string+color inline)
// Para bias L/S: en cuántos trades con ese activo (en el TF actual) ganó long vs short
// Aquí lo aproximamos con RSI histórico + EMA trend histórico
// long_bias = más barras con close > EMA que close < EMA en el lookback
_f_chg(float c, float c1) =>
    float pct = c1 != 0 ? (c - c1) / c1 * 100 : 0.0
    pct

_f_setup(float rsi, float macdh, float macdh1, float c, float ema_v) =>
    bool bull_ema = c > ema_v
    bool rsi_ob   = rsi > 70
    bool rsi_os   = rsi < 30
    bool macd_up  = macdh > macdh1
    bool macd_dn  = macdh < macdh1
    // Setup: RSI zona + MACD alineado
    bool set_l = rsi_os and macd_up
    bool set_s = rsi_ob and macd_dn
    // Break EMA con cuerpo (un bar atrás)
    bool brk_l = c[1] > ema_v[1] and c[2] < ema_v[2]
    bool brk_s = c[1] < ema_v[1] and c[2] > ema_v[2]
    // Bias: últimas 50 barras — más tiempo sobre/bajo EMA
    int lb_bias = 50
    int cnt_bull = 0
    int cnt_bear = 0
    for i = 0 to lb_bias - 1
        if c[i] > ema_v[i]
            cnt_bull += 1
        else
            cnt_bear += 1
    string bias = cnt_bull >= cnt_bear ? "L" : "S"
    [bull_ema, set_l, set_s, brk_l, brk_s, bias]

// ── Derivar para cada activo ──────────────────────────────────
_btc_chg = _f_chg(_btc_close, _btc_close1)
[_btc_bull, _btc_sl, _btc_ss, _btc_bl, _btc_bs, _btc_bias] = _f_setup(_btc_rsi, _btc_macdh, _btc_macdh1, _btc_close, _btc_ema)

_eth_chg = _f_chg(_eth_close, _eth_close1)
[_eth_bull, _eth_sl, _eth_ss, _eth_bl, _eth_bs, _eth_bias] = _f_setup(_eth_rsi, _eth_macdh, _eth_macdh1, _eth_close, _eth_ema)

_sol_chg = _f_chg(_sol_close, _sol_close1)
[_sol_bull, _sol_sl, _sol_ss, _sol_bl, _sol_bs, _sol_bias] = _f_setup(_sol_rsi, _sol_macdh, _sol_macdh1, _sol_close, _sol_ema)

_xau_chg = _f_chg(_xau_close, _xau_close1)
[_xau_bull, _xau_sl, _xau_ss, _xau_bl, _xau_bs, _xau_bias] = _f_setup(_xau_rsi, _xau_macdh, _xau_macdh1, _xau_close, _xau_ema)

_nq_chg  = _f_chg(_nq_close,  _nq_close1)
[_nq_bull, _nq_sl, _nq_ss, _nq_bl, _nq_bs, _nq_bias]   = _f_setup(_nq_rsi,  _nq_macdh,  _nq_macdh1,  _nq_close,  _nq_ema)

_spx_chg = _f_chg(_spx_close, _spx_close1)
[_spx_bull, _spx_sl, _spx_ss, _spx_bl, _spx_bs, _spx_bias] = _f_setup(_spx_rsi, _spx_macdh, _spx_macdh1, _spx_close, _spx_ema)

// ── Dashboard ─────────────────────────────────────────────────
if show_bt and barstate.islast
    // Contadores generales
    int   total    = 0
    int   wins     = 0
    int   losses   = 0
    int   open_t   = 0
    float sum_rr   = 0.0
    // Contadores Long
    int   long_tot = 0
    int   long_win = 0
    // Contadores Short
    int   short_tot = 0
    int   short_win = 0

    for t in sn_trades
        if total >= bt_max
            break
        if t.closed
            total  += 1
            if t.is_win
                wins   += 1
                sum_rr += sn_rr
            else
                losses += 1
                sum_rr -= 1.0
            if t.is_long
                long_tot += 1
                long_win += t.is_win ? 1 : 0
            else
                short_tot += 1
                short_win += t.is_win ? 1 : 0
        else
            open_t += 1

    float wr       = total     > 0 ? (wins      / total)     * 100.0 : 0.0
    float wr_long  = long_tot  > 0 ? (long_win  / long_tot)  * 100.0 : 0.0
    float wr_short = short_tot > 0 ? (short_win / short_tot) * 100.0 : 0.0
    float exp_r    = total     > 0 ? sum_rr / total                   : 0.0

    var table bt_dash = table.new(
         position.bottom_right, 7, 11,
         bgcolor      = color.new(#0f0f0f, 5),
         border_color = color.new(#2a2e39, 40),
         border_width = 1,
         frame_color  = color.new(#546e7a, 40),
         frame_width  = 1)

    color hdr_bg  = color.new(#1e2235, 0)
    color row_bg  = color.new(#131722, 5)
    color row_alt = color.new(#161b2e, 5)

    // Row 0: WR General
    string wr_str = "🎯 WR: " + str.tostring(math.round(wr, 1)) + "%  " +
         str.tostring(wins) + "W · " + str.tostring(losses) + "L · " +
         str.tostring(open_t) + " open  |  Exp: " +
         (exp_r >= 0 ? "+" : "") + str.tostring(math.round(exp_r, 2)) + "R"
    table.cell(bt_dash, 0, 0, wr_str,
         text_color = wr >= 50 ? #089981 : #f23645,
         bgcolor = hdr_bg, text_size = size.small)
    table.merge_cells(bt_dash, 0, 0, 6, 0)

    // Row 1: WR Long
    string wrl_str = "▲ Long  WR: " + str.tostring(math.round(wr_long, 1)) +
         "%  (" + str.tostring(long_win) + "W / " + str.tostring(long_tot - long_win) + "L)"
    table.cell(bt_dash, 0, 1, wrl_str,
         text_color = wr_long >= 50 ? #089981 : #f23645,
         bgcolor = color.new(#0a1a0f, 0), text_size = size.tiny)
    table.merge_cells(bt_dash, 0, 1, 6, 1)

    // Row 2: WR Short
    string wrs_str = "▼ Short  WR: " + str.tostring(math.round(wr_short, 1)) +
         "%  (" + str.tostring(short_win) + "W / " + str.tostring(short_tot - short_win) + "L)"
    table.cell(bt_dash, 0, 2, wrs_str,
         text_color = wr_short >= 50 ? #089981 : #f23645,
         bgcolor = color.new(#1a0a0a, 0), text_size = size.tiny)
    table.merge_cells(bt_dash, 0, 2, 6, 2)

    // Row 3: Column headers


    // ── Macro de fila (inline para evitar UDF con tabla) ─────
    // BTC
    string btc_st  = _btc_bl ? "◉ WAIT L" : _btc_bs ? "◉ WAIT S" : _btc_sl ? "● SET L" : _btc_ss ? "● SET S" : "  ─"
    color  btc_stc = _btc_bl or _btc_sl ? #089981 : _btc_bs or _btc_ss ? #f23645 : #546e7a
    string btc_chgs = (_btc_chg >= 0 ? "+" : "") + str.tostring(math.round(_btc_chg, 2)) + "%"
    color  btc_chgc = _btc_chg >= 0 ? #089981 : #f23645
    color  btc_bias_c = _btc_bias == "L" ? #089981 : #f23645
    // Row 3: Column headers
    table.cell(bt_dash, 0, 3, "Asset", text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(bt_dash, 1, 3, "Price", text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(bt_dash, 2, 3, "Chg",   text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(bt_dash, 3, 3, "Trend", text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(bt_dash, 4, 3, "Setup", text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(bt_dash, 5, 3, "RSI",   text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.cell(bt_dash, 6, 3, "Bias",  text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)

    table.cell(bt_dash, 0, 4, "BTC",        text_color = #b2b5be,    bgcolor = row_bg,  text_size = size.small)
    table.cell(bt_dash, 1, 4, str.tostring(_btc_close, format.mintick), text_color = #b2b5be, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 2, 4, btc_chgs,     text_color = btc_chgc,   bgcolor = row_bg,  text_size = size.tiny)
    table.cell(bt_dash, 3, 4, _btc_bull ? "▲ Bull" : "▼ Bear", text_color = _btc_bull ? #089981 : #f23645, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 4, 4, btc_st,       text_color = btc_stc,    bgcolor = row_bg,  text_size = size.tiny)
    table.cell(bt_dash, 5, 4, str.tostring(math.round(_btc_rsi, 1)), text_color = _btc_rsi > 70 ? #f23645 : _btc_rsi < 30 ? #089981 : #b2b5be, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 6, 4, _btc_bias,    text_color = btc_bias_c, bgcolor = row_bg,  text_size = size.small)
    // ETH
    string eth_st  = _eth_bl ? "◉ WAIT L" : _eth_bs ? "◉ WAIT S" : _eth_sl ? "● SET L" : _eth_ss ? "● SET S" : "  ─"
    color  eth_stc = _eth_bl or _eth_sl ? #089981 : _eth_bs or _eth_ss ? #f23645 : #546e7a
    string eth_chgs = (_eth_chg >= 0 ? "+" : "") + str.tostring(math.round(_eth_chg, 2)) + "%"
    color  eth_chgc = _eth_chg >= 0 ? #089981 : #f23645
    color  eth_bias_c = _eth_bias == "L" ? #089981 : #f23645
    table.cell(bt_dash, 0, 5, "ETH",        text_color = #b2b5be,    bgcolor = row_alt, text_size = size.small)
    table.cell(bt_dash, 1, 5, str.tostring(_eth_close, format.mintick), text_color = #b2b5be, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 2, 5, eth_chgs,     text_color = eth_chgc,   bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 3, 5, _eth_bull ? "▲ Bull" : "▼ Bear", text_color = _eth_bull ? #089981 : #f23645, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 4, 5, eth_st,       text_color = eth_stc,    bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 5, 5, str.tostring(math.round(_eth_rsi, 1)), text_color = _eth_rsi > 70 ? #f23645 : _eth_rsi < 30 ? #089981 : #b2b5be, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 6, 5, _eth_bias,    text_color = eth_bias_c, bgcolor = row_alt, text_size = size.small)
    // SOL
    string sol_st  = _sol_bl ? "◉ WAIT L" : _sol_bs ? "◉ WAIT S" : _sol_sl ? "● SET L" : _sol_ss ? "● SET S" : "  ─"
    color  sol_stc = _sol_bl or _sol_sl ? #089981 : _sol_bs or _sol_ss ? #f23645 : #546e7a
    string sol_chgs = (_sol_chg >= 0 ? "+" : "") + str.tostring(math.round(_sol_chg, 2)) + "%"
    color  sol_chgc = _sol_chg >= 0 ? #089981 : #f23645
    color  sol_bias_c = _sol_bias == "L" ? #089981 : #f23645
    table.cell(bt_dash, 0, 6, "SOL",        text_color = #b2b5be,    bgcolor = row_bg,  text_size = size.small)
    table.cell(bt_dash, 1, 6, str.tostring(_sol_close, format.mintick), text_color = #b2b5be, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 2, 6, sol_chgs,     text_color = sol_chgc,   bgcolor = row_bg,  text_size = size.tiny)
    table.cell(bt_dash, 3, 6, _sol_bull ? "▲ Bull" : "▼ Bear", text_color = _sol_bull ? #089981 : #f23645, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 4, 6, sol_st,       text_color = sol_stc,    bgcolor = row_bg,  text_size = size.tiny)
    table.cell(bt_dash, 5, 6, str.tostring(math.round(_sol_rsi, 1)), text_color = _sol_rsi > 70 ? #f23645 : _sol_rsi < 30 ? #089981 : #b2b5be, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 6, 6, _sol_bias,    text_color = sol_bias_c, bgcolor = row_bg,  text_size = size.small)
    // GOLD
    string xau_st  = _xau_bl ? "◉ WAIT L" : _xau_bs ? "◉ WAIT S" : _xau_sl ? "● SET L" : _xau_ss ? "● SET S" : "  ─"
    color  xau_stc = _xau_bl or _xau_sl ? #089981 : _xau_bs or _xau_ss ? #f23645 : #546e7a
    string xau_chgs = (_xau_chg >= 0 ? "+" : "") + str.tostring(math.round(_xau_chg, 2)) + "%"
    color  xau_chgc = _xau_chg >= 0 ? #089981 : #f23645
    color  xau_bias_c = _xau_bias == "L" ? #089981 : #f23645
    table.cell(bt_dash, 0, 7, "GOLD",       text_color = #ffd700,    bgcolor = row_alt, text_size = size.small)
    table.cell(bt_dash, 1, 7, str.tostring(_xau_close, format.mintick), text_color = #b2b5be, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 2, 7, xau_chgs,     text_color = xau_chgc,   bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 3, 7, _xau_bull ? "▲ Bull" : "▼ Bear", text_color = _xau_bull ? #089981 : #f23645, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 4, 7, xau_st,       text_color = xau_stc,    bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 5, 7, str.tostring(math.round(_xau_rsi, 1)), text_color = _xau_rsi > 70 ? #f23645 : _xau_rsi < 30 ? #089981 : #b2b5be, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 6, 7, _xau_bias,    text_color = xau_bias_c, bgcolor = row_alt, text_size = size.small)
    // NQ
    string nq_st   = _nq_bl ? "◉ WAIT L" : _nq_bs ? "◉ WAIT S" : _nq_sl ? "● SET L" : _nq_ss ? "● SET S" : "  ─"
    color  nq_stc  = _nq_bl or _nq_sl ? #089981 : _nq_bs or _nq_ss ? #f23645 : #546e7a
    string nq_chgs  = (_nq_chg >= 0 ? "+" : "") + str.tostring(math.round(_nq_chg, 2)) + "%"
    color  nq_chgc  = _nq_chg >= 0 ? #089981 : #f23645
    color  nq_bias_c = _nq_bias == "L" ? #089981 : #f23645
    table.cell(bt_dash, 0, 8, "NQ",         text_color = #9fa8da,    bgcolor = row_bg,  text_size = size.small)
    table.cell(bt_dash, 1, 8, str.tostring(_nq_close, format.mintick),  text_color = #b2b5be, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 2, 8, nq_chgs,      text_color = nq_chgc,    bgcolor = row_bg,  text_size = size.tiny)
    table.cell(bt_dash, 3, 8, _nq_bull ? "▲ Bull" : "▼ Bear",  text_color = _nq_bull  ? #089981 : #f23645, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 4, 8, nq_st,        text_color = nq_stc,     bgcolor = row_bg,  text_size = size.tiny)
    table.cell(bt_dash, 5, 8, str.tostring(math.round(_nq_rsi, 1)),  text_color = _nq_rsi > 70 ? #f23645 : _nq_rsi < 30 ? #089981 : #b2b5be, bgcolor = row_bg, text_size = size.tiny)
    table.cell(bt_dash, 6, 8, _nq_bias,     text_color = nq_bias_c,  bgcolor = row_bg,  text_size = size.small)
    // ES (S&P 500)
    string spx_st  = _spx_bl ? "◉ WAIT L" : _spx_bs ? "◉ WAIT S" : _spx_sl ? "● SET L" : _spx_ss ? "● SET S" : "  ─"
    color  spx_stc = _spx_bl or _spx_sl ? #089981 : _spx_bs or _spx_ss ? #f23645 : #546e7a
    string spx_chgs = (_spx_chg >= 0 ? "+" : "") + str.tostring(math.round(_spx_chg, 2)) + "%"
    color  spx_chgc = _spx_chg >= 0 ? #089981 : #f23645
    color  spx_bias_c = _spx_bias == "L" ? #089981 : #f23645
    table.cell(bt_dash, 0, 9, "ES",         text_color = #9fa8da,    bgcolor = row_alt, text_size = size.small)
    table.cell(bt_dash, 1, 9, str.tostring(_spx_close, format.mintick), text_color = #b2b5be, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 2, 9, spx_chgs,     text_color = spx_chgc,   bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 3, 9, _spx_bull ? "▲ Bull" : "▼ Bear", text_color = _spx_bull ? #089981 : #f23645, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 4, 9, spx_st,       text_color = spx_stc,    bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 5, 9, str.tostring(math.round(_spx_rsi, 1)), text_color = _spx_rsi > 70 ? #f23645 : _spx_rsi < 30 ? #089981 : #b2b5be, bgcolor = row_alt, text_size = size.tiny)
    table.cell(bt_dash, 6, 9, _spx_bias,    text_color = spx_bias_c, bgcolor = row_alt, text_size = size.small)

    // Row 8: leyenda
    table.cell(bt_dash, 0, 10, "● Setup  ◉ Waiting Retest  Bias=L/S (50 bars vs EMA12)",
         text_color = #546e7a, bgcolor = hdr_bg, text_size = size.tiny)
    table.merge_cells(bt_dash, 0, 10, 6, 10)

// ── Eliminar label de entrada (reemplazado por trade boxes) ───
// sn_entry_lb eliminado — ya no se dibuja el label blanco de entrada
````
