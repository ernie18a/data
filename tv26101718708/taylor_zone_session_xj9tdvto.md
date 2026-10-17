# Taylor Zone Session

- url: https://www.tradingview.com/script/XJ9tdVTO/
- type: indicator
- pine_id: PUB;2a822848185f40f1a72f40df1df1254b
- version: 2.0

## Description

═══════════════════════════════════════════════════════════
RELEASE NOTES — PDC Fix
═══════════════════════════════════════════════════════════

🐛 BUG FIX — Previous Day Close (PDC)

Fixed an issue where the Previous Day Close line was 
displayed at an incorrect price level on some symbols.

▶ What was happening
The PDC auto-detection used a 1-minute request.security 
call to capture the close at 15:59 NY. Depending on how 
the data feed aligned its 1-minute bars, this could 
capture a price from before the actual session close, 
resulting in a displayed PDC that did not match the real 
16:00 NY close (sometimes off by hundreds of points on 
fast-moving instruments).

▶ What's been fixed
The PDC is now captured by tracking the RTH session 
(09:30–16:00 America/New_York) directly on the chart's 
timeframe. The close of the last bar of the session is 
frozen as the PDC for the next trading day.

This is the same reliable method already used internally 
for the RTH OHLC tracking, and it matches the official 
"Close" value displayed by TradingView in the top-right 
data window.

▶ Impact
- The displayed PDC now matches the real previous day's 
  RTH close — no more discrepancy
- No action required from the user — the fix applies 
  automatically
- Manual override input (Override Previous Day Close) 
  remains available if you prefer to enter the value 
  yourself
- All other features (Taylor Zone, Sell/Buy Levels, 
  PDH/PDL, Trend Table, etc.) are unchanged

## Source Code

````pine
//@version=6
indicator("Taylor Zone Session", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ===== INPUTS =====
avg_sell   = input.float(6000, title="Taylor Avg Sell / Selling Zone")
avg_buy    = input.float(6000, title="Taylor Avg Buy / Buying Zone")

// ----- Previous Day Close -----
use_manual_pdc = input.bool(false, "Override Previous Day Close (manuel)")
manual_pdc     = input.float(0.0,  "Previous Day Close (manuel)", tooltip="Activez 'Override' ci-dessus pour utiliser cette valeur")

// ----- Rectangle -----
rect_color_input = input.color(color.red, "Rectangle Color")
rect_opacity     = input.int(85, "Rectangle Opacity", minval=0, maxval=100)

// ----- Lignes Sell / Buy / PDC -----
sell_color  = input.color(color.red,   "Sell Line Color")
buy_color   = input.color(color.green, "Buy Line Color")
pdc_color   = input.color(color.blue,  "Previous Day Close Color")
line_width  = input.int(2, "Line Width", minval=1, maxval=4)

// ----- Midline -----
show_midline     = input.bool(true,         "Show Midline")
midline_color_in = input.color(color.white, "Midline Color")
midline_opacity  = input.int(0,             "Midline Opacity", minval=0, maxval=100)
midline_width    = input.int(1,             "Midline Width",   minval=1, maxval=4)

// ----- Label "Taylor Zone" -----
show_label       = input.bool(true,         "Show 'Taylor Zone' Label")
label_text_color = input.color(color.white, "Label Text Color")
label_opacity    = input.int(0,             "Label Opacity", minval=0, maxval=100)

// ----- Heure de début configurable -----
start_hour   = input.int(9,  "Session Start Hour (NY)",   minval=0, maxval=23)
start_minute = input.int(30, "Session Start Minute (NY)", minval=0, maxval=59)

// ═══════════════════════════════════════════════════════════════
// ===== NEXT DAY SELL LEVELS — 4 RÉSISTANCES =====
// ═══════════════════════════════════════════════════════════════
show_sell_levels = input.bool(true, "═══ Show Sell Levels (ST1 / ST2 / High / Piv.Buy)", group="Next Day — Sell Levels")

st1_value     = input.float(0.0, "ST1 — Sell Target 1",  group="Next Day — Sell Levels", tooltip="L + Avg Rally 3J")
st1_color     = input.color(color.new(color.orange, 0),  "ST1 Color",       group="Next Day — Sell Levels")
st1_style_inp = input.string("dashed", "ST1 Line Style", options=["solid","dashed","dotted"], group="Next Day — Sell Levels")
st1_width     = input.int(1, "ST1 Line Width", minval=1, maxval=4, group="Next Day — Sell Levels")

st2_value     = input.float(0.0, "ST2 — Sell Target 2",  group="Next Day — Sell Levels", tooltip="H + Avg BuyHigh 3J")
st2_color     = input.color(color.new(color.red, 0),     "ST2 Color",       group="Next Day — Sell Levels")
st2_style_inp = input.string("dashed", "ST2 Line Style", options=["solid","dashed","dotted"], group="Next Day — Sell Levels")
st2_width     = input.int(1, "ST2 Line Width", minval=1, maxval=4, group="Next Day — Sell Levels")

high_day_value = input.float(0.0, "High Day",  group="Next Day — Sell Levels", tooltip="High de la séance J")
high_day_color = input.color(color.new(color.gray, 0),   "High Day Color",  group="Next Day — Sell Levels")
high_day_style = input.string("dotted", "High Day Style", options=["solid","dashed","dotted"], group="Next Day — Sell Levels")
high_day_width = input.int(1, "High Day Width", minval=1, maxval=4, group="Next Day — Sell Levels")

piv_buy_value = input.float(0.0, "Pivot Buy",  group="Next Day — Sell Levels", tooltip="ROUND(2*(H+L+C)/3 - L, 0)")
piv_buy_color = input.color(color.new(color.yellow, 0),  "Pivot Buy Color", group="Next Day — Sell Levels")
piv_buy_style = input.string("dotted", "Pivot Buy Style", options=["solid","dashed","dotted"], group="Next Day — Sell Levels")
piv_buy_width = input.int(1, "Pivot Buy Width", minval=1, maxval=4, group="Next Day — Sell Levels")

// ═══════════════════════════════════════════════════════════════
// ===== NEXT DAY BUY LEVELS — 4 SUPPORTS =====
// ═══════════════════════════════════════════════════════════════
show_buy_levels = input.bool(true, "═══ Show Buy Levels (BT1 / BT2 / Low / Piv.Sell)", group="Next Day — Buy Levels")

bt1_value     = input.float(0.0, "BT1 — Buy Target 1",  group="Next Day — Buy Levels", tooltip="H - Avg Decline 3J")
bt1_color     = input.color(color.new(color.lime, 0),   "BT1 Color",        group="Next Day — Buy Levels")
bt1_style_inp = input.string("dashed", "BT1 Line Style", options=["solid","dashed","dotted"], group="Next Day — Buy Levels")
bt1_width     = input.int(1, "BT1 Line Width", minval=1, maxval=4, group="Next Day — Buy Levels")

bt2_value     = input.float(0.0, "BT2 — Buy Target 2",  group="Next Day — Buy Levels", tooltip="L - Avg BuyUnder 3J")
bt2_color     = input.color(color.new(color.green, 0),  "BT2 Color",        group="Next Day — Buy Levels")
bt2_style_inp = input.string("dashed", "BT2 Line Style", options=["solid","dashed","dotted"], group="Next Day — Buy Levels")
bt2_width     = input.int(1, "BT2 Line Width", minval=1, maxval=4, group="Next Day — Buy Levels")

low_day_value = input.float(0.0, "Low Day",  group="Next Day — Buy Levels", tooltip="Low de la séance J")
low_day_color = input.color(color.new(color.gray, 0),   "Low Day Color",    group="Next Day — Buy Levels")
low_day_style = input.string("dotted", "Low Day Style", options=["solid","dashed","dotted"], group="Next Day — Buy Levels")
low_day_width = input.int(1, "Low Day Width", minval=1, maxval=4, group="Next Day — Buy Levels")

piv_sell_value = input.float(0.0, "Pivot Sell",  group="Next Day — Buy Levels", tooltip="ROUND(2*(H+L+C)/3 - H, 0)")
piv_sell_color = input.color(color.new(color.aqua, 0),  "Pivot Sell Color", group="Next Day — Buy Levels")
piv_sell_style = input.string("dotted", "Pivot Sell Style", options=["solid","dashed","dotted"], group="Next Day — Buy Levels")
piv_sell_width = input.int(1, "Pivot Sell Width", minval=1, maxval=4, group="Next Day — Buy Levels")

// ═══════════════════════════════════════════════════════════════
// ===== PREVIOUS DAY HIGH / LOW (24h Daily) =====
// ═══════════════════════════════════════════════════════════════
// ----- Previous Day High -----
show_pdh       = input.bool(true,                       "Show Previous Day High",  group="Previous Day H/L")
pdh_label_text = input.string("PDH",                    "PDH Label Text",          group="Previous Day H/L")
pdh_label_pos  = input.string("Left", "PDH Label Position", options=["Left","Center","Right"], group="Previous Day H/L")
pdh_color      = input.color(color.new(color.fuchsia, 0), "PDH Color",             group="Previous Day H/L")
pdh_style_inp  = input.string("dashed", "PDH Line Style", options=["solid","dashed","dotted"], group="Previous Day H/L")
pdh_width      = input.int(1, "PDH Line Width", minval=1, maxval=4, group="Previous Day H/L")

// ----- Previous Day Low -----
show_pdl       = input.bool(true,                       "Show Previous Day Low",   group="Previous Day H/L")
pdl_label_text = input.string("PDL",                    "PDL Label Text",          group="Previous Day H/L")
pdl_label_pos  = input.string("Left", "PDL Label Position", options=["Left","Center","Right"], group="Previous Day H/L")
pdl_color      = input.color(color.new(color.purple, 0), "PDL Color",              group="Previous Day H/L")
pdl_style_inp  = input.string("dashed", "PDL Line Style", options=["solid","dashed","dotted"], group="Previous Day H/L")
pdl_width      = input.int(1, "PDL Line Width", minval=1, maxval=4, group="Previous Day H/L")

// ═══════════════════════════════════════════════════════════════
// ===== ASIA SESSION HIGH / LOW =====
// ═══════════════════════════════════════════════════════════════
asia_start_h   = input.int(20, "Asia Session Start Hour (NY)",   minval=0, maxval=23, group="Asia Session H/L")
asia_start_m   = input.int(0,  "Asia Session Start Minute (NY)", minval=0, maxval=59, group="Asia Session H/L")
asia_end_h     = input.int(0,  "Asia Session End Hour (NY)",     minval=0, maxval=23, group="Asia Session H/L")
asia_end_m     = input.int(0,  "Asia Session End Minute (NY)",   minval=0, maxval=59, group="Asia Session H/L")

show_ah        = input.bool(true,                       "Show Asia High",          group="Asia Session H/L")
ah_label_text  = input.string("AH",                     "Asia High Label Text",    group="Asia Session H/L")
ah_label_pos   = input.string("Left", "Asia High Label Position", options=["Left","Center","Right"], group="Asia Session H/L")
ah_color       = input.color(color.new(#FF9800, 0),     "Asia High Color",         group="Asia Session H/L")
ah_style_inp   = input.string("dashed", "Asia High Line Style", options=["solid","dashed","dotted"], group="Asia Session H/L")
ah_width       = input.int(1, "Asia High Line Width", minval=1, maxval=4, group="Asia Session H/L")

show_al        = input.bool(true,                       "Show Asia Low",           group="Asia Session H/L")
al_label_text  = input.string("AL",                     "Asia Low Label Text",     group="Asia Session H/L")
al_label_pos   = input.string("Left", "Asia Low Label Position", options=["Left","Center","Right"], group="Asia Session H/L")
al_color       = input.color(color.new(#FFB74D, 0),     "Asia Low Color",          group="Asia Session H/L")
al_style_inp   = input.string("dashed", "Asia Low Line Style", options=["solid","dashed","dotted"], group="Asia Session H/L")
al_width       = input.int(1, "Asia Low Line Width", minval=1, maxval=4, group="Asia Session H/L")

// ═══════════════════════════════════════════════════════════════
// ===== LONDON SESSION HIGH / LOW =====
// ═══════════════════════════════════════════════════════════════
london_start_h = input.int(2, "London Session Start Hour (NY)",   minval=0, maxval=23, group="London Session H/L")
london_start_m = input.int(0, "London Session Start Minute (NY)", minval=0, maxval=59, group="London Session H/L")
london_end_h   = input.int(5, "London Session End Hour (NY)",     minval=0, maxval=23, group="London Session H/L")
london_end_m   = input.int(0, "London Session End Minute (NY)",   minval=0, maxval=59, group="London Session H/L")

show_lh        = input.bool(true,                       "Show London High",        group="London Session H/L")
lh_label_text  = input.string("LH",                     "London High Label Text",  group="London Session H/L")
lh_label_pos   = input.string("Left", "London High Label Position", options=["Left","Center","Right"], group="London Session H/L")
lh_color       = input.color(color.new(#00BCD4, 0),     "London High Color",       group="London Session H/L")
lh_style_inp   = input.string("dashed", "London High Line Style", options=["solid","dashed","dotted"], group="London Session H/L")
lh_width       = input.int(1, "London High Line Width", minval=1, maxval=4, group="London Session H/L")

show_ll        = input.bool(true,                       "Show London Low",         group="London Session H/L")
ll_label_text  = input.string("LL",                     "London Low Label Text",   group="London Session H/L")
ll_label_pos   = input.string("Left", "London Low Label Position", options=["Left","Center","Right"], group="London Session H/L")
ll_color       = input.color(color.new(#4DD0E1, 0),     "London Low Color",        group="London Session H/L")
ll_style_inp   = input.string("dashed", "London Low Line Style", options=["solid","dashed","dotted"], group="London Session H/L")
ll_width       = input.int(1, "London Low Line Width", minval=1, maxval=4, group="London Session H/L")

// ═══════════════════════════════════════════════════════════════
// ===== TREND TABLE — CADRE BAS À DROITE =====
// ═══════════════════════════════════════════════════════════════
show_trend_table   = input.bool(true,                        "Show Trend Table",   group="Trend Table — Bottom Right")
trend_bull_color   = input.color(color.new(color.lime,   0), "Bullish Color",      group="Trend Table — Bottom Right")
trend_bear_color   = input.color(color.new(color.red,    0), "Bearish Color",      group="Trend Table — Bottom Right")
trend_neut_color   = input.color(color.new(color.gray,   0), "Neutral Color",      group="Trend Table — Bottom Right")
trend_bg_color     = input.color(color.new(color.black, 60), "Background Color",   group="Trend Table — Bottom Right")
trend_border_color = input.color(color.new(color.gray,  40), "Border Color",       group="Trend Table — Bottom Right")
trend_txt_size     = input.string("normal", "Text Size",     options=["tiny","small","normal","large","huge"], group="Trend Table — Bottom Right")

// ═══════════════════════════════════════════════════════════════
// ===== RTH PREVIOUS DAY OHLC PANEL — HAUT À DROITE =====
// ═══════════════════════════════════════════════════════════════
show_rth_panel    = input.bool(true,                  "Show RTH Previous Day OHLC Panel", group="RTH Previous Day OHLC Panel")
rth_openColor     = input.color(color.gray,           "Open Color",   group="RTH Previous Day OHLC Panel")
rth_highColor     = input.color(color.red,            "High Color",   group="RTH Previous Day OHLC Panel")
rth_lowColor      = input.color(color.green,          "Low Color",    group="RTH Previous Day OHLC Panel")
rth_closeColor    = input.color(color.blue,           "Close Color",  group="RTH Previous Day OHLC Panel")
rth_dateColor     = input.color(color.white,          "Date Color",   group="RTH Previous Day OHLC Panel")
rth_textSizeInput = input.string("normal", "Text Size", options=["tiny","small","normal","large"], group="RTH Previous Day OHLC Panel")

rth_txtSize = rth_textSizeInput == "tiny"  ? size.tiny  : rth_textSizeInput == "small" ? size.small : rth_textSizeInput == "large" ? size.large : size.normal

// ===== PREVIOUS DAY CLOSE NY (close à 16:00 NY = dernière bougie de la session RTH) =====
// On suit en temps réel la session RTH 9h30-16h NY et on capture le close
// de la dernière bougie. À la fin de la session, on fige cette valeur dans pdc_auto.
nyRTHSessionPDC = not na(time(timeframe.period, "0930-1600", "America/New_York"))

var float rth_running_close = na  // close en cours de session (suit chaque bougie)
var float pdc_auto           = na  // PDC figé à la fin de la session

bool rth_session_start = nyRTHSessionPDC and not nyRTHSessionPDC[1]
bool rth_session_end   = not nyRTHSessionPDC and nyRTHSessionPDC[1]

if nyRTHSessionPDC
    rth_running_close := close

// À la première bougie HORS session après la fin de la session RTH,
// on fige le dernier close capturé comme PDC du jour qui vient de se terminer
if rth_session_end
    pdc_auto := rth_running_close

float prev_close = use_manual_pdc ? manual_pdc : pdc_auto

// ===== PREVIOUS DAY HIGH / LOW (Daily 24h) =====
// On récupère H et L du jour précédent clôturé via le timeframe Daily standard
float pdh_value = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
float pdl_value = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)

// ===== TIME LOGIC =====
nyHour   = hour(time,   "America/New_York")
nyMinute = minute(time, "America/New_York")

nyCurrentMinutes  = nyHour * 60 + nyMinute
startTotalMinutes = start_hour * 60 + start_minute
endTotalMinutes   = 16 * 60
tf_minutes        = timeframe.multiplier
bars_total        = math.round((endTotalMinutes - startTotalMinutes) / tf_minutes)

// ===== COULEURS =====
rectColor     = color.new(rect_color_input, rect_opacity)
midlineColor  = color.new(midline_color_in, midline_opacity)
labelTxtColor = color.new(label_text_color, label_opacity)

// ===== MIDLINE =====
float midPrice = (math.max(avg_sell, avg_buy) + math.min(avg_sell, avg_buy)) / 2.0

// ===== HELPER : string → line.style =====
f_style(s) =>
    s == "dotted" ? line.style_dotted : s == "dashed" ? line.style_dashed : line.style_solid

// ===== HELPER : string → text size =====
f_txt_size(s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large :
     s == "huge"  ? size.huge  : size.normal

// ===== HELPER : position label =====
f_lbl_style(p) =>
    p == "Right" ? label.style_label_left : p == "Center" ? label.style_label_center : label.style_label_right

f_lbl_x(p, x_left, x_mid, x_right) =>
    p == "Right" ? x_right : p == "Center" ? x_mid : x_left

// ═══════════════════════════════════════════════════════════════
// ===== ASIA / LONDON SESSION TRACKING =====
// ═══════════════════════════════════════════════════════════════
asiaStartMins   = asia_start_h   * 60 + asia_start_m
asiaEndMins     = asia_end_h     * 60 + asia_end_m
londonStartMins = london_start_h * 60 + london_start_m
londonEndMins   = london_end_h   * 60 + london_end_m

bool inAsiaSession = false
if asiaStartMins < asiaEndMins
    inAsiaSession := nyCurrentMinutes >= asiaStartMins and nyCurrentMinutes < asiaEndMins
else if asiaStartMins > asiaEndMins
    inAsiaSession := nyCurrentMinutes >= asiaStartMins or nyCurrentMinutes < asiaEndMins
else
    inAsiaSession := true

bool inLondonSession = false
if londonStartMins < londonEndMins
    inLondonSession := nyCurrentMinutes >= londonStartMins and nyCurrentMinutes < londonEndMins
else if londonStartMins > londonEndMins
    inLondonSession := nyCurrentMinutes >= londonStartMins or nyCurrentMinutes < londonEndMins
else
    inLondonSession := true

var float asiaHighLive = na
var float asiaLowLive  = na
var float asiaHigh     = na
var float asiaLow      = na

bool asiaStart = inAsiaSession and not inAsiaSession[1]
bool asiaEnd   = not inAsiaSession and inAsiaSession[1]

if asiaStart
    asiaHighLive := high
    asiaLowLive  := low

if inAsiaSession
    asiaHighLive := na(asiaHighLive) ? high : math.max(asiaHighLive, high)
    asiaLowLive  := na(asiaLowLive)  ? low  : math.min(asiaLowLive,  low)

if asiaEnd
    asiaHigh := asiaHighLive
    asiaLow  := asiaLowLive

var float londonHighLive = na
var float londonLowLive  = na
var float londonHigh     = na
var float londonLow      = na

bool londonStart = inLondonSession and not inLondonSession[1]
bool londonEnd   = not inLondonSession and inLondonSession[1]

if londonStart
    londonHighLive := high
    londonLowLive  := low

if inLondonSession
    londonHighLive := na(londonHighLive) ? high : math.max(londonHighLive, high)
    londonLowLive  := na(londonLowLive)  ? low  : math.min(londonLowLive,  low)

if londonEnd
    londonHigh := londonHighLive
    londonLow  := londonLowLive

float asiaHighDisplay   = inAsiaSession   ? asiaHighLive   : asiaHigh
float asiaLowDisplay    = inAsiaSession   ? asiaLowLive    : asiaLow
float londonHighDisplay = inLondonSession ? londonHighLive : londonHigh
float londonLowDisplay  = inLondonSession ? londonLowLive  : londonLow

// ═══════════════════════════════════════════════════════════════
// ===== RTH SESSION OHLC TRACKING (pour le panneau OHLC) =====
// On réutilise la même détection que pour le PDC pour assurer
// une parfaite cohérence entre la ligne PDC et le panneau OHLC.
// ═══════════════════════════════════════════════════════════════
var float rthOpen  = na
var float rthHigh  = na
var float rthLow   = na
var float rthClose = na

var float prevDayOpen  = na
var float prevDayHigh  = na
var float prevDayLow   = na
var float prevDayClose = na

var int prevDayYear  = na
var int prevDayMonth = na
var int prevDayDay   = na

if rth_session_start
    rthOpen  := open
    rthHigh  := high
    rthLow   := low
    rthClose := close

if nyRTHSessionPDC
    rthHigh  := math.max(rthHigh, high)
    rthLow   := math.min(rthLow,  low)
    rthClose := close

if rth_session_end
    prevDayOpen  := rthOpen
    prevDayHigh  := rthHigh
    prevDayLow   := rthLow
    prevDayClose := rthClose
    prevDayYear  := year(time,        "America/New_York")
    prevDayMonth := month(time,       "America/New_York")
    prevDayDay   := dayofmonth(time,  "America/New_York")

prevDateStr = str.tostring(prevDayDay) + "/" + str.tostring(prevDayMonth) + "/" + str.tostring(prevDayYear)

// ═══════════════════════════════════════════════════════════════
// ===== LOGIQUE TENDANCE =====
// Bullish  : close > Pivot Buy
// Bearish  : close < Pivot Sell
// Neutral  : entre les deux
// Si un seul pivot est renseigné, on utilise uniquement celui-là
// ═══════════════════════════════════════════════════════════════
bool piv_buy_set  = piv_buy_value  != 0.0
bool piv_sell_set = piv_sell_value != 0.0

string trend_text  = "Neutral —"
color  trend_color = trend_neut_color

if piv_buy_set and piv_sell_set
    if close > piv_buy_value
        trend_text  := "Bullish  ▲"
        trend_color := trend_bull_color
    else if close < piv_sell_value
        trend_text  := "Bearish  ▼"
        trend_color := trend_bear_color
    else
        trend_text  := "Neutral  —"
        trend_color := trend_neut_color
else if piv_buy_set and not piv_sell_set
    if close > piv_buy_value
        trend_text  := "Bullish  ▲"
        trend_color := trend_bull_color
    else
        trend_text  := "Neutral  —"
        trend_color := trend_neut_color
else if piv_sell_set and not piv_buy_set
    if close < piv_sell_value
        trend_text  := "Bearish  ▼"
        trend_color := trend_bear_color
    else
        trend_text  := "Neutral  —"
        trend_color := trend_neut_color

// ===== VARIABLES =====
var table trendTable  = na
var box   sessionBox  = na
var line  midLine     = na
var line  line_sell   = na
var line  line_buy    = na
var line  line_pdc    = na
var label lbl_sell    = na
var label lbl_buy     = na
var label lbl_pdc     = na
var label lbl_mid     = na

var line  line_st1      = na
var line  line_st2      = na
var line  line_high_day = na
var line  line_piv_buy  = na
var line  line_bt1      = na
var line  line_bt2      = na
var line  line_low_day  = na
var line  line_piv_sell = na

var label lbl_st1      = na
var label lbl_st2      = na
var label lbl_high_day = na
var label lbl_piv_buy  = na
var label lbl_bt1      = na
var label lbl_bt2      = na
var label lbl_low_day  = na
var label lbl_piv_sell = na

// ----- Variables Previous Day H/L -----
var line  line_pdh = na
var line  line_pdl = na
var label lbl_pdh  = na
var label lbl_pdl  = na

// ----- Variables Asia / London H/L -----
var line  line_ah = na
var line  line_al = na
var line  line_lh = na
var line  line_ll = na
var label lbl_ah  = na
var label lbl_al  = na
var label lbl_lh  = na
var label lbl_ll  = na

// ----- Variable RTH OHLC Panel -----
var table rthPanel = na

// ===== DESSIN EN TEMPS RÉEL =====
if barstate.islast

    // — Suppression objets originaux —
    if not na(sessionBox)
        box.delete(sessionBox)
    if not na(midLine)
        line.delete(midLine)
    if not na(line_sell)
        line.delete(line_sell)
    if not na(line_buy)
        line.delete(line_buy)
    if not na(line_pdc)
        line.delete(line_pdc)
    if not na(lbl_sell)
        label.delete(lbl_sell)
    if not na(lbl_buy)
        label.delete(lbl_buy)
    if not na(lbl_pdc)
        label.delete(lbl_pdc)
    if not na(lbl_mid)
        label.delete(lbl_mid)

    // — Suppression nouvelles lignes —
    if not na(line_st1)
        line.delete(line_st1)
    if not na(line_st2)
        line.delete(line_st2)
    if not na(line_high_day)
        line.delete(line_high_day)
    if not na(line_piv_buy)
        line.delete(line_piv_buy)
    if not na(line_bt1)
        line.delete(line_bt1)
    if not na(line_bt2)
        line.delete(line_bt2)
    if not na(line_low_day)
        line.delete(line_low_day)
    if not na(line_piv_sell)
        line.delete(line_piv_sell)
    if not na(lbl_st1)
        label.delete(lbl_st1)
    if not na(lbl_st2)
        label.delete(lbl_st2)
    if not na(lbl_high_day)
        label.delete(lbl_high_day)
    if not na(lbl_piv_buy)
        label.delete(lbl_piv_buy)
    if not na(lbl_bt1)
        label.delete(lbl_bt1)
    if not na(lbl_bt2)
        label.delete(lbl_bt2)
    if not na(lbl_low_day)
        label.delete(lbl_low_day)
    if not na(lbl_piv_sell)
        label.delete(lbl_piv_sell)

    // — Suppression Previous Day H/L —
    if not na(line_pdh)
        line.delete(line_pdh)
    if not na(line_pdl)
        line.delete(line_pdl)
    if not na(lbl_pdh)
        label.delete(lbl_pdh)
    if not na(lbl_pdl)
        label.delete(lbl_pdl)

    // — Suppression Asia / London H/L —
    if not na(line_ah)
        line.delete(line_ah)
    if not na(line_al)
        line.delete(line_al)
    if not na(line_lh)
        line.delete(line_lh)
    if not na(line_ll)
        line.delete(line_ll)
    if not na(lbl_ah)
        label.delete(lbl_ah)
    if not na(lbl_al)
        label.delete(lbl_al)
    if not na(lbl_lh)
        label.delete(lbl_lh)
    if not na(lbl_ll)
        label.delete(lbl_ll)

    // — Calcul positions temporelles —
    int barsToStart = math.round((startTotalMinutes - nyCurrentMinutes) / tf_minutes)
    int bar_start   = bar_index + barsToStart
    int bar_end_raw = bar_start + bars_total
    // CORRECTION : Pine Script v5 interdit de dessiner à plus de 500 bougies dans le futur
    // (xloc.bar_index). On plafonne bar_end pour respecter cette limite TradingView.
    int bar_end     = math.min(bar_end_raw, bar_index + 500)

    if nyCurrentMinutes < endTotalMinutes

        // ── DESSIN ORIGINAL (100% inchangé) ──
        sessionBox := box.new(left=bar_start, top=math.max(avg_sell, avg_buy), right=bar_end, bottom=math.min(avg_sell, avg_buy), border_color=na, bgcolor=rectColor, extend=extend.none)

        if show_label
            box.set_text(sessionBox, "Taylor Zone")
            box.set_text_size(sessionBox, size.normal)
            box.set_text_color(sessionBox, labelTxtColor)
            box.set_text_halign(sessionBox, text.align_center)
            box.set_text_valign(sessionBox, text.align_center)

        if show_midline
            midLine := line.new(x1=bar_start, y1=midPrice, x2=bar_end, y2=midPrice, color=midlineColor, width=midline_width, style=line.style_dashed, extend=extend.none)

        line_sell := line.new(x1=bar_start, y1=avg_sell,   x2=bar_end, y2=avg_sell,   color=sell_color, width=line_width, style=line.style_solid, extend=extend.none)
        line_buy  := line.new(x1=bar_start, y1=avg_buy,    x2=bar_end, y2=avg_buy,    color=buy_color,  width=line_width, style=line.style_solid, extend=extend.none)
        line_pdc  := line.new(x1=bar_start, y1=prev_close, x2=bar_end, y2=prev_close, color=pdc_color,  width=line_width, style=line.style_solid, extend=extend.none)

        lbl_sell := label.new(x=bar_start, y=avg_sell,   text="Avg Sell",       color=color.new(color.black,100), textcolor=sell_color, style=label.style_label_right, size=size.small)
        lbl_buy  := label.new(x=bar_start, y=avg_buy,    text="Avg Buy",        color=color.new(color.black,100), textcolor=buy_color,  style=label.style_label_right, size=size.small)
        lbl_pdc  := label.new(x=bar_start, y=prev_close, text="Prev Day Close", color=color.new(color.black,100), textcolor=pdc_color,  style=label.style_label_right, size=size.small)

        if show_midline
            lbl_mid := label.new(x=bar_start, y=midPrice, text="Mid", color=color.new(color.black,100), textcolor=midlineColor, style=label.style_label_right, size=size.small)

        // ── LIGNES SELL (ST1 / ST2 / High Day / Pivot Buy) ──
        if show_sell_levels
            if st1_value != 0.0
                line_st1 := line.new(x1=bar_start, y1=st1_value, x2=bar_end, y2=st1_value, color=st1_color, width=st1_width, style=f_style(st1_style_inp), extend=extend.none)
                lbl_st1  := label.new(x=bar_start, y=st1_value, text="ST1", color=color.new(color.black,100), textcolor=st1_color, style=label.style_label_right, size=size.small)

            if st2_value != 0.0
                line_st2 := line.new(x1=bar_start, y1=st2_value, x2=bar_end, y2=st2_value, color=st2_color, width=st2_width, style=f_style(st2_style_inp), extend=extend.none)
                lbl_st2  := label.new(x=bar_start, y=st2_value, text="ST2", color=color.new(color.black,100), textcolor=st2_color, style=label.style_label_right, size=size.small)

            if high_day_value != 0.0
                line_high_day := line.new(x1=bar_start, y1=high_day_value, x2=bar_end, y2=high_day_value, color=high_day_color, width=high_day_width, style=f_style(high_day_style), extend=extend.none)
                lbl_high_day  := label.new(x=bar_start, y=high_day_value, text="High Day", color=color.new(color.black,100), textcolor=high_day_color, style=label.style_label_right, size=size.small)

            if piv_buy_value != 0.0
                line_piv_buy := line.new(x1=bar_start, y1=piv_buy_value, x2=bar_end, y2=piv_buy_value, color=piv_buy_color, width=piv_buy_width, style=f_style(piv_buy_style), extend=extend.none)
                lbl_piv_buy  := label.new(x=bar_start, y=piv_buy_value, text="Piv.Buy", color=color.new(color.black,100), textcolor=piv_buy_color, style=label.style_label_right, size=size.small)

        // ── LIGNES BUY (BT1 / BT2 / Low Day / Pivot Sell) ──
        if show_buy_levels
            if bt1_value != 0.0
                line_bt1 := line.new(x1=bar_start, y1=bt1_value, x2=bar_end, y2=bt1_value, color=bt1_color, width=bt1_width, style=f_style(bt1_style_inp), extend=extend.none)
                lbl_bt1  := label.new(x=bar_start, y=bt1_value, text="BT1", color=color.new(color.black,100), textcolor=bt1_color, style=label.style_label_right, size=size.small)

            if bt2_value != 0.0
                line_bt2 := line.new(x1=bar_start, y1=bt2_value, x2=bar_end, y2=bt2_value, color=bt2_color, width=bt2_width, style=f_style(bt2_style_inp), extend=extend.none)
                lbl_bt2  := label.new(x=bar_start, y=bt2_value, text="BT2", color=color.new(color.black,100), textcolor=bt2_color, style=label.style_label_right, size=size.small)

            if low_day_value != 0.0
                line_low_day := line.new(x1=bar_start, y1=low_day_value, x2=bar_end, y2=low_day_value, color=low_day_color, width=low_day_width, style=f_style(low_day_style), extend=extend.none)
                lbl_low_day  := label.new(x=bar_start, y=low_day_value, text="Low Day", color=color.new(color.black,100), textcolor=low_day_color, style=label.style_label_right, size=size.small)

            if piv_sell_value != 0.0
                line_piv_sell := line.new(x1=bar_start, y1=piv_sell_value, x2=bar_end, y2=piv_sell_value, color=piv_sell_color, width=piv_sell_width, style=f_style(piv_sell_style), extend=extend.none)
                lbl_piv_sell  := label.new(x=bar_start, y=piv_sell_value, text="Piv.Sell", color=color.new(color.black,100), textcolor=piv_sell_color, style=label.style_label_right, size=size.small)

        // ── PREVIOUS DAY HIGH / LOW (24h Daily) ──
        int bar_mid = (bar_start + bar_end) / 2
        if show_pdh and not na(pdh_value)
            line_pdh := line.new(x1=bar_start, y1=pdh_value, x2=bar_end, y2=pdh_value, color=pdh_color, width=pdh_width, style=f_style(pdh_style_inp), extend=extend.none)
            lbl_pdh  := label.new(x=f_lbl_x(pdh_label_pos, bar_start, bar_mid, bar_end), y=pdh_value, text=pdh_label_text, color=color.new(color.black,100), textcolor=pdh_color, style=f_lbl_style(pdh_label_pos), size=size.small)

        if show_pdl and not na(pdl_value)
            line_pdl := line.new(x1=bar_start, y1=pdl_value, x2=bar_end, y2=pdl_value, color=pdl_color, width=pdl_width, style=f_style(pdl_style_inp), extend=extend.none)
            lbl_pdl  := label.new(x=f_lbl_x(pdl_label_pos, bar_start, bar_mid, bar_end), y=pdl_value, text=pdl_label_text, color=color.new(color.black,100), textcolor=pdl_color, style=f_lbl_style(pdl_label_pos), size=size.small)

        // ── ASIA SESSION HIGH / LOW ──
        if show_ah and not na(asiaHighDisplay)
            line_ah := line.new(x1=bar_start, y1=asiaHighDisplay, x2=bar_end, y2=asiaHighDisplay, color=ah_color, width=ah_width, style=f_style(ah_style_inp), extend=extend.none)
            lbl_ah  := label.new(x=f_lbl_x(ah_label_pos, bar_start, bar_mid, bar_end), y=asiaHighDisplay, text=ah_label_text, color=color.new(color.black,100), textcolor=ah_color, style=f_lbl_style(ah_label_pos), size=size.small)

        if show_al and not na(asiaLowDisplay)
            line_al := line.new(x1=bar_start, y1=asiaLowDisplay, x2=bar_end, y2=asiaLowDisplay, color=al_color, width=al_width, style=f_style(al_style_inp), extend=extend.none)
            lbl_al  := label.new(x=f_lbl_x(al_label_pos, bar_start, bar_mid, bar_end), y=asiaLowDisplay, text=al_label_text, color=color.new(color.black,100), textcolor=al_color, style=f_lbl_style(al_label_pos), size=size.small)

        // ── LONDON SESSION HIGH / LOW ──
        if show_lh and not na(londonHighDisplay)
            line_lh := line.new(x1=bar_start, y1=londonHighDisplay, x2=bar_end, y2=londonHighDisplay, color=lh_color, width=lh_width, style=f_style(lh_style_inp), extend=extend.none)
            lbl_lh  := label.new(x=f_lbl_x(lh_label_pos, bar_start, bar_mid, bar_end), y=londonHighDisplay, text=lh_label_text, color=color.new(color.black,100), textcolor=lh_color, style=f_lbl_style(lh_label_pos), size=size.small)

        if show_ll and not na(londonLowDisplay)
            line_ll := line.new(x1=bar_start, y1=londonLowDisplay, x2=bar_end, y2=londonLowDisplay, color=ll_color, width=ll_width, style=f_style(ll_style_inp), extend=extend.none)
            lbl_ll  := label.new(x=f_lbl_x(ll_label_pos, bar_start, bar_mid, bar_end), y=londonLowDisplay, text=ll_label_text, color=color.new(color.black,100), textcolor=ll_color, style=f_lbl_style(ll_label_pos), size=size.small)

    // ── TREND TABLE — BAS À DROITE ──
    // Dessinée en dehors du bloc "nyCurrentMinutes" pour rester visible toute la journée
    if show_trend_table
        if not na(trendTable)
            table.delete(trendTable)

        trendTable := table.new(
             position     = position.bottom_right,
             columns      = 1,
             rows         = 2,
             bgcolor      = trend_bg_color,
             border_color = trend_border_color,
             border_width = 1,
             frame_color  = trend_border_color,
             frame_width  = 1)

        // Ligne 0 : titre "Taylor Trend" (blanc fixe)
        table.cell(trendTable, 0, 0,
             text       = "Taylor Trend",
             text_color = color.new(color.white, 20),
             text_size  = f_txt_size(trend_txt_size),
             bgcolor    = color.new(color.black, 50))

        // Ligne 1 : Bullish ▲ / Bearish ▼ / Neutral — avec couleur dynamique
        table.cell(trendTable, 0, 1,
             text       = trend_text,
             text_color = trend_color,
             text_size  = f_txt_size(trend_txt_size),
             bgcolor    = trend_bg_color)

    // ── RTH PREVIOUS DAY OHLC PANEL — HAUT À DROITE ──
    if show_rth_panel
        if not na(rthPanel)
            table.delete(rthPanel)

        rthPanel := table.new(position.top_right, 1, 5)

        table.cell(rthPanel, 0, 0, "Date: "  + prevDateStr,                                 text_color=rth_dateColor,  text_size=rth_txtSize)
        table.cell(rthPanel, 0, 1, "Open: "  + str.tostring(prevDayOpen,  format.mintick),  text_color=rth_openColor,  text_size=rth_txtSize)
        table.cell(rthPanel, 0, 2, "High: "  + str.tostring(prevDayHigh,  format.mintick),  text_color=rth_highColor,  text_size=rth_txtSize)
        table.cell(rthPanel, 0, 3, "Low: "   + str.tostring(prevDayLow,   format.mintick),  text_color=rth_lowColor,   text_size=rth_txtSize)
        table.cell(rthPanel, 0, 4, "Close: " + str.tostring(prevDayClose, format.mintick),  text_color=rth_closeColor, text_size=rth_txtSize)
````
