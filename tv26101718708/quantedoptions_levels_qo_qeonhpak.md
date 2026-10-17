# quantedOptions Levels [qO]

- url: https://www.tradingview.com/script/qeonhPAK-quantedOptions-Levels-qO/
- type: indicator
- pine_id: PUB;80e63ae20d1c43258b4868326b7e1b82
- version: 11.0

## Description

Official quantedOptions Levels Script.

quantedOptions Levels draws options-positioning levels on any chart from one pasted line of text: the call wall and put wall, the gamma flip, the builder's call-side and put-side gamma maxima (Gamma C / P), the largest positive and negative delta-exposure strikes (DEX C / P), the five largest net-gamma strikes, a shaded zone between the walls, and the strike profile itself as a ladder on the right edge of the chart, one bar per strike sized by net gamma.

HOW TO USE
1. Copy a levels line from a quantedOptions dashboard (quantedTrader for QQQ, SPY and other tickers; quantedGamma for SPX) with "Copy for TradingView".
2. Open this indicator's settings and paste the line into "Paste from quantedOptions".
3. The levels appear with a header showing the ticker, expiry cohort, time and the price at that time. Levels are a snapshot of that moment. Paste again to refresh.

CONVERSION
On the ticker's own chart the levels are drawn as they are. On a related instrument they are rescaled live: QQQ levels on NQ, MNQ or NDX; SPY on ES, MES or SPX; SPX on ES or MES; IWM on RTY or M2K; DIA on YM or MYM; GLD on GC or MGC; SLV on SI or SIL; USO on CL, MCL or QM. Ratios are sampled only on bars where the ETF traded, so an overnight futures move does not shift the lines. Cash-index levels on their futures use the basis instead of a ratio. "Fixed ratio" lets you set your own factor; "Off" draws everything 1:1. Each label shows the level in the chart's price and the original strike.

DISPLAY
Levels that share a strike are drawn once with the names joined, so nothing overlaps. Each group of levels can be switched off. Glow, line start, ladder length and label size are adjustable. Three alert conditions are included: price crossing the call wall, the put wall and the gamma flip.

TRY IT
Paste this line to see the indicator work on a QQQ chart, or on NQ to see the conversion. It is QQQ's front expiry at 11:00 Central on 2026-09-04:

qo1|QQQ|2026-09-04|11:00|717.62|0DTE|net=291.1|cw=720|pw=718|flip=724.53|gc=720|gp=718|dc=715|dp=720|top=720,718,717,722,716|p=682:-0.6,683:-0.7,684:-1.5,685:-2.3,686:-0.8,687:-1.3,688:-1.9,689:-1.7,690:-3.8,691:-2.7,692:-2.0,693:-1.5,694:-3.0,695:-6.4,696:-2.2,697:-3.6,698:-3.6,699:-2.8,700:-20.7,701:-2.8,702:-5.3,703:-9.8,704:-5.8,705:-32.5,706:-7.9,707:-16.1,708:-29.6,709:-19.8,710:-51.3,711:-36.0,712:-35.6,712.5:-26.0,713:-58.2,714:-7.7,715:49.9,716:-135.7,717:-232.0,717.5:5.9,718:-308.2,719:45.3,720:432.7,721:88.5,722:186.0,722.5:111.9,723:36.0,724:83.5,725:126.5,726:20.3,727:19.1,727.5:7.2,728:27.4,729:6.7,730:44.2,731:11.2,732:10.9,732.5:1.5,733:3.6,734:3.3,735:40.7,736:3.4,737:2.2,737.5:0.7,738:0.8,739:2.1,740:4.5,741:4.8,742:0.5,742.5:0.5,743:0.6,744:0.5,745:1.5,746:0.5,747:0.5,748:1.4,749:0.2,750:2.7,751:1.8,752:0.2,753:0.3

NOTES
Nothing is sent anywhere. The only input is the text you paste, and the only data requested are the reference prices of the related tickers for conversion. The levels are derived from listed options open interest and Greeks. They describe where positioning sits; they are not a signal.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// quantedOptions Levels [qO]
//
// Draws the levels copied from quantedOptions — quantedTrader (QQQ, SPY, any
// captured ticker) or quantedGamma / the orderflow plugin (SPX) — via each
// dashboard's "Copy for TradingView", on any TradingView chart:
//   call wall · put wall · gamma flip · Gamma C / P · top-5 strikes,
//   a heatmap (each chosen strike shaded across the chart, brighter the more
//   net gamma it holds — the desktop add-ons' Heatmap setting), an optional
//   shaded zone between the walls, and the strike profile as a ladder on the
//   right edge (one bar per strike, sized by net gamma, puts left of the zero
//   axis in red, calls right of it in cyan).
//
// Conversion: when the chart is a proxy of the pasted ticker the levels are
// rescaled live — QQQ → NQ / MNQ / NDX, SPY → ES / MES / SPX, IWM → RTY / M2K,
// DIA → YM / MYM, GLD → GC / MGC, SLV → SI / SIL, USO → CL / MCL / QM — by the
// ratio of the chart's price to the ETF's price, sampled only on bars where the
// ETF actually traded (so an overnight futures move does not drag the levels).
// NDX levels on NQ and SPX levels on ES / MES use the basis (future − cash)
// instead of a ratio; SPX on SPY uses the ratio.
//
// Nothing leaves TradingView: the only input is the pasted string. Levels are
// a snapshot at the pasted time — paste again to refresh.
//
// String format (qo1; qt1 accepted): qo1|TICKER|YYYY-MM-DD|HH:MM|SPOT|COHORT|net=|cw=|pw=|flip=|gc=|gp=|dc=|dp=|top=|p=
// HH:MM is Eastern (US market time), the same zone the dashboard clock shows.
// dc= / dp= are accepted and ignored. They were drawn as "DEX C / P" until
// 2026-10-08: on delta there is no peak near the money, so largest /
// most-negative just found whichever strike held the most contracts — on SPX it
// picked 7000 and 8000 against a spot of 7657 — and the extension's feed never
// carried them at all. A toggle that draws nothing, or draws nonsense, is worse
// than no toggle.
// ─────────────────────────────────────────────────────────────────────────────
indicator("quantedOptions Levels [qO]", shorttitle = "qO Levels", overlay = true,
     max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// Build date, shown at the end of the conversion line. A published script has no
// version a user can read, and three separate support rounds in 2026-10 were
// spent establishing which copy a chart was running — the NAS100 refusal looked
// identical whether the chart had the pre-CFD script or the CFD script with the
// over-strict stock guard. A date in the header answers it from a screenshot.
// Bump it on every republish.
VER = "2026.10.08"

// ── Inputs ───────────────────────────────────────────────────────────────────
// TradingView echoes input VALUES into the chart legend, so the title read
// "qO Levels  Auto 1 150 2 28 Small". The conversion mode is worth seeing at a
// glance — it says whether the levels are being converted to this chart — so it
// STAYS. The other five are cosmetic settings that tell a trader nothing while
// they are trading: display.data_window keeps them inspectable and out of the
// legend. The title now reads "qO Levels  Auto".
grpL = "Levels"
lv         = input.text_area("", "Paste from quantedOptions", group = grpL,
     tooltip = "quantedTrader (or quantedGamma) → levels strip → Copy for TradingView, then paste the whole line here.")
showWalls  = input.bool(true,  "Call / put wall",            group = grpL)
showFlip   = input.bool(true,  "Gamma flip",                 group = grpL)
showGamma  = input.bool(true,  "Gamma C / P (builder walls)", group = grpL)
showTop    = input.bool(true,  "Top 5 strikes",              group = grpL)
showZone   = input.bool(false, "Shade between the walls",    group = grpL)
showLadder = input.bool(true,  "Strike profile ladder",      group = grpL)

// Heatmap — the desktop add-ons' "Heatmap" setting (core Scene.SelectLevels):
// the same strike choices, the same 20 % and 12 % thresholds, the same "strikes
// each side of price" range. All of it stays out of the legend (see above).
grpH = "Heatmap"
heatMode  = input.string("All strikes", "Shade strikes by size", options = ["Off", "Nearest ±", "Top 3 each side", "Top 5 each side", "Top N each side", "Above 20% of max", "All strikes"], group = grpH, display = display.data_window,
     tooltip = "Paints each chosen strike across the chart, brighter the more net gamma it holds (cyan = positive, red = negative). Off paints none, All strikes paints every one in range, and the Top modes paint a few of the biggest each side. Nearest ±: the closest positive and negative strike holding at least 12% of the largest.")
heatTopN  = input.int(3, "Top N each side (nodes)", minval = 1, maxval = 25, group = grpH, display = display.data_window,
     tooltip = "How many nodes each side 'Top N each side' paints. The fixed Top 3 and Top 5 entries are kept above so a chart already set to one of them does not change.")
heatStyle = input.string("Band", "Heatmap style", options = ["Band", "Fade", "Line"], group = grpH, display = display.data_window,
     tooltip = "Band: the strike's whole slot, opacity = size. Fade: a thinner band that brightens toward the ladder, with a core line. Line: 1–3 px by size.")
heatWidth = input.string("Full", "Heatmap width", options = ["Full", "Right half", "Right third"], group = grpH, display = display.data_window,
     tooltip = "Full starts where the level lines start (Style → Lines start).")
heatRange = input.int(10, "Strikes each side of price (0 = all)", minval = 0, maxval = 80, group = grpH, display = display.data_window,
     tooltip = "Used by 'Above 20% of max' and 'All strikes'.")
heatStr   = input.int(55, "Shade strength (%)", minval = 10, maxval = 100, group = grpH, display = display.data_window,
     tooltip = "Opacity of the largest strike. Tip: indicator menu → Visual order → Send to back puts the shading behind the candles.")
heatLbl   = input.string("Off", "Heatmap labels", options = ["Off", "Value", "Price + value"], group = grpH, display = display.data_window)

grpC = "Conversion"
convMode   = input.string("Auto", "Convert levels to this chart", options = ["Auto", "Off (1:1)", "Fixed ratio"], group = grpC,
     tooltip = "Auto: on the pasted ticker's own chart levels are drawn as-is; on a proxy (QQQ → NQ, SPY → ES, GLD → GC …) they are rescaled by the live price ratio; on any other chart they are drawn 1:1 with a warning. Fixed ratio: multiply every level by the number below.")
fixedRatio = input.float(1.0, "Fixed ratio (chart ÷ levels ticker)", minval = 0.0001, step = 0.01, group = grpC, display = display.data_window)

grpS = "Style"
glow         = input.bool(true, "Glow",                                  group = grpS)
lineBack     = input.int(150,   "Lines start (bars back)",               minval = 10, maxval = 4000, group = grpS, display = display.data_window)
ladderOffset = input.int(2,     "Ladder offset (bars right of last bar)", minval = 0,  maxval = 50,   group = grpS, display = display.data_window)
ladderLen    = input.int(28,    "Ladder max length (bars, each side)",   minval = 5,  maxval = 200,  group = grpS, display = display.data_window)
sizeOpt      = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpS, display = display.data_window)

grpP = "Panel"
panelMode   = input.string("Header", "Info panel", options = ["Off", "Header", "Full"], group = grpP, display = display.data_window,
     tooltip = "Header: the three lines this script has always drawn, top right. Full: the orderflow plugin's data panel — net gamma, the nearest ± nodes with their distance, and the five biggest strikes each way.")
panelCorner = input.string("Bottom left", "Panel corner", options = ["Bottom left", "Top left", "Bottom right", "Top right"], group = grpP, display = display.data_window)
panelSize   = input.int(11, "Panel text size (pt)", minval = 6, maxval = 36, group = grpP, display = display.data_window,
     tooltip = "Table cells take a point size, so the panel scales in single steps rather than the three presets the labels use.")

// ── Colours ──────────────────────────────────────────────────────────────────
// Five themes, the same ones the desktop add-ons carry (AtasTheme.Themes), plus
// Custom. Classic is what this script has always drawn, so an existing chart
// looks the same after an update; the others follow the add-ons' palettes, with
// the flip and neutral tones chosen per theme so nothing collides.
grpT = "Colours"
themeOpt = input.string("Classic", "Theme", options = ["Classic", "Amber", "Fiesta", "Emerald", "Mono", "Custom"], group = grpT, display = display.data_window)
bgOpt    = input.string("Dark", "Chart background", options = ["Dark", "Light"], group = grpT, display = display.data_window,
     tooltip = "Light darkens every colour and turns the header card light, so the lines and numbers read on a white or pale chart.")
uCall = input.color(color.rgb(34, 211, 238),  "Custom · calls / positive", group = grpT, display = display.data_window)
uPut  = input.color(color.rgb(248, 113, 113), "Custom · puts / negative",  group = grpT, display = display.data_window)
uFlip = input.color(color.rgb(251, 191, 36),  "Custom · flip / spot",      group = grpT, display = display.data_window)
uTop  = input.color(color.rgb(212, 212, 216), "Custom · top-5 / neutral",  group = grpT, display = display.data_window)

// slot 0 calls · 1 puts · 2 flip and spot · 4 top-5 and neutral. Slot 3 was the
// DEX walls and retired with them; the numbering stays as it was so the five
// theme rows below keep lining up with the add-ons' palettes.
palette(int slot) =>
    color c = na
    if themeOpt == "Custom"
        if slot == 0
            c := uCall
        else if slot == 1
            c := uPut
        else if slot == 2
            c := uFlip
        else
            c := uTop
    else if themeOpt == "Amber"
        c := slot == 0 ? color.rgb(129, 140, 248) : slot == 1 ? color.rgb(251, 191, 36) : slot == 2 ? color.rgb(167, 139, 250) : slot == 3 ? color.rgb(34, 211, 238) : color.rgb(212, 212, 216)
    else if themeOpt == "Fiesta"
        c := slot == 0 ? color.rgb(0, 178, 169) : slot == 1 ? color.rgb(239, 66, 111) : slot == 2 ? color.rgb(251, 191, 36) : slot == 3 ? color.rgb(168, 85, 247) : color.rgb(212, 212, 216)
    else if themeOpt == "Emerald"
        c := slot == 0 ? color.rgb(52, 211, 153) : slot == 1 ? color.rgb(251, 113, 133) : slot == 2 ? color.rgb(251, 191, 36) : slot == 3 ? color.rgb(163, 230, 53) : color.rgb(212, 212, 216)
    else if themeOpt == "Mono"
        c := slot == 0 ? color.rgb(240, 240, 240) : slot == 1 ? color.rgb(139, 139, 149) : slot == 2 ? color.rgb(212, 212, 216) : slot == 3 ? color.rgb(161, 161, 170) : color.rgb(212, 212, 216)
    else
        c := slot == 0 ? color.rgb(34, 211, 238) : slot == 1 ? color.rgb(248, 113, 113) : slot == 2 ? color.rgb(251, 191, 36) : slot == 3 ? color.rgb(167, 139, 250) : color.rgb(212, 212, 216)
    c

// Light charts: the same 62 % darkening the add-ons' light data panel uses, so a
// palette picked for a black chart still reads on a white one.
lightBg = bgOpt == "Light"
dim62(color c) => color.rgb(math.round(color.r(c) * 0.62), math.round(color.g(c) * 0.62), math.round(color.b(c) * 0.62))
tone(color c) => lightBg ? dim62(c) : c

cPos = tone(palette(0))   // positive gamma / call side
cNeg = tone(palette(1))   // negative gamma / put side
cAmb = tone(palette(2))   // flip / spot accent
cTop = tone(palette(4))   // top-5 / neutral
hdrBg = lightBg ? color.new(color.rgb(246, 247, 249), 12) : color.new(color.black, 25)
lblSize = sizeOpt == "Tiny" ? size.tiny : sizeOpt == "Normal" ? size.normal : size.small

// Panel tones — the add-ons' terminal panel (AtasTheme.Dim / Faint / Bright /
// PanelBg / PanelBorder), with their light-card twins for a pale chart.
pFaint  = lightBg ? color.rgb(122, 129, 140) : color.rgb(116, 123, 136)
pDim    = lightBg ? color.rgb(63, 70, 80)    : color.rgb(184, 190, 200)
pBright = lightBg ? color.rgb(10, 13, 18)    : color.rgb(203, 208, 216)
pBg     = lightBg ? color.new(color.rgb(245, 246, 248), 11) : color.new(color.rgb(10, 12, 18), 11)
pFrame  = lightBg ? color.new(color.rgb(200, 205, 212), 22) : color.new(color.rgb(60, 66, 78), 22)
pAging  = color.rgb(251, 191, 36)    // past the add-ons' FRESH_MAX_S, 2 min
pStale  = color.rgb(240, 112, 96)
pnlPos  = panelCorner == "Top left" ? position.top_left : panelCorner == "Bottom right" ? position.bottom_right : panelCorner == "Top right" ? position.top_right : position.bottom_left

// ── Parse the pasted string once ─────────────────────────────────────────────
var string[] tok  = str.split(lv, "|")
var int      ntok = array.size(tok)
var bool     ok   = ntok >= 6 and (array.get(tok, 0) == "qo1" or array.get(tok, 0) == "qt1")

getv(string key) =>
    string out = ""
    if ok and ntok > 6
        for i = 6 to ntok - 1
            t = array.get(tok, i)
            if str.startswith(t, key + "=")
                out := str.substring(t, str.length(key) + 1)
    out

num(string s) =>
    float v = na
    if s != ""
        v := str.tonumber(s)
    v

var string tkr    = ""
var string sdate  = ""
var string stime  = ""
var string cohort = ""
var float  spot0  = na
var float  netM   = na
var float  cw     = na
var float  pw     = na
var float  flip   = na
var float  gc     = na
var float  gp     = na
var float[] topK  = array.new<float>()
var float[] pk    = array.new<float>()   // profile strikes (ascending)
var float[] pv    = array.new<float>()   // profile net GEX, $M
var bool parsed   = false

if not parsed
    parsed := true
    if ok
        tkr    := str.upper(array.get(tok, 1))
        sdate  := array.get(tok, 2)
        stime  := array.get(tok, 3)
        spot0  := str.tonumber(array.get(tok, 4))
        cohort := array.get(tok, 5)
        netM   := num(getv("net"))
        cw     := num(getv("cw"))
        pw     := num(getv("pw"))
        flip   := num(getv("flip"))
        gc     := num(getv("gc"))
        gp     := num(getv("gp"))
        string[] ts = str.split(getv("top"), ",")
        if array.size(ts) > 0
            for i = 0 to array.size(ts) - 1
                k = str.tonumber(array.get(ts, i))
                if not na(k)
                    array.push(topK, k)
        string[] ps = str.split(getv("p"), ",")
        if array.size(ps) > 0
            for i = 0 to array.size(ps) - 1
                string[] kv = str.split(array.get(ps, i), ":")
                if array.size(kv) == 2
                    k = str.tonumber(array.get(kv, 0))
                    v = str.tonumber(array.get(kv, 1))
                    if not na(k) and not na(v)
                        array.push(pk, k)
                        array.push(pv, v)

// ── Reference prices (constant symbols — requested unconditionally) ──────────
px(string sym) => request.security(sym, timeframe.period, close, ignore_invalid_symbol = true)
tm(string sym) => request.security(sym, timeframe.period, time,  ignore_invalid_symbol = true)

qqq  = px("NASDAQ:QQQ")
qqqT = tm("NASDAQ:QQQ")
spy  = px("AMEX:SPY")
spyT = tm("AMEX:SPY")
iwm  = px("AMEX:IWM")
iwmT = tm("AMEX:IWM")
dia  = px("AMEX:DIA")
diaT = tm("AMEX:DIA")
gld  = px("AMEX:GLD")
gldT = tm("AMEX:GLD")
slv  = px("AMEX:SLV")
slvT = tm("AMEX:SLV")
uso  = px("AMEX:USO")
usoT = tm("AMEX:USO")
ndx  = px("NASDAQ:NDX")
ndxT = tm("NASDAQ:NDX")
spx  = px("SP:SPX")
spxT = tm("SP:SPX")
// A proxy entry is useless without a price series to build the ratio from: these
// three were added to the table with no fetch behind them, so etfPx stayed na and
// every BTC / ETH / bond chart reported "ratio pending" forever. Both lists have
// to move together.
ibit  = px("NASDAQ:IBIT")
ibitT = tm("NASDAQ:IBIT")
tlt   = px("NASDAQ:TLT")
tltT  = tm("NASDAQ:TLT")
etha  = px("NASDAQ:ETHA")
ethaT = tm("NASDAQ:ETHA")

float etfPx = na
int   etfT  = na
if tkr == "QQQ"
    etfPx := qqq
    etfT  := qqqT
else if tkr == "SPY"
    etfPx := spy
    etfT  := spyT
else if tkr == "IWM"
    etfPx := iwm
    etfT  := iwmT
else if tkr == "DIA"
    etfPx := dia
    etfT  := diaT
else if tkr == "GLD"
    etfPx := gld
    etfT  := gldT
else if tkr == "SLV"
    etfPx := slv
    etfT  := slvT
else if tkr == "USO"
    etfPx := uso
    etfT  := usoT
else if tkr == "IBIT"
    etfPx := ibit
    etfT  := ibitT
else if tkr == "TLT"
    etfPx := tlt
    etfT  := tltT
else if tkr == "ETHA"
    etfPx := etha
    etfT  := ethaT
else if tkr == "NDX"
    etfPx := ndx
    etfT  := ndxT
else if tkr == "SPX"
    etfPx := spx
    etfT  := spxT

// ── Which chart is this? ─────────────────────────────────────────────────────
root    = syminfo.root
chartTk = syminfo.ticker
same    = chartTk == tkr
isNq    = root == "NQ" or root == "MNQ"
isEs    = root == "ES" or root == "MES"
// Spot / CFD spellings carry no futures root, so they are matched on the name —
// but a CONTINUOUS CONTRACT is a third spelling again: BIST's gold future is
// ticker "XAUUSD1!" with root "XAUUSD", which matched neither the spot ticker
// nor the metal root, so a gold chart was told "chart XAUUSD1! is not GLD"
// (owner, 2026-09-25). syminfo.root is the contract root on a derivative and
// the plain ticker everywhere else, so matching its PREFIX covers spot, the
// perpetual spellings and every dated or continuous contract at once. The base
// currency is the second, independent way in. "GOLD" and "SILVER" are taken
// only off a non-stock: on a stock they are Barrick Gold and Silvercorp.
isBtcSp = str.startswith(root, "BTCUSD") or root == "XBTUSD" or syminfo.basecurrency == "BTC" or syminfo.basecurrency == "XBT"
isEthSp = str.startswith(root, "ETHUSD") or syminfo.basecurrency == "ETH"
isXau   = root == "XAU" or str.startswith(root, "XAUUSD") or syminfo.basecurrency == "XAU" or (root == "GOLD" and syminfo.type != "stock")
isXag   = root == "XAG" or str.startswith(root, "XAGUSD") or syminfo.basecurrency == "XAG" or (root == "SILVER" and syminfo.type != "stock")
// Broker CFD, spot and crypto-perpetual spellings (2026-10-09), from a sweep of
// TradingView's own symbol search across every broker it lists — a customer on
// SPREADEX:NDX ("US Tech 100") got TSLA levels drawn 1:1. The browser extension
// carries the SAME names (CFD_FAMILIES in content.js) and decides which book to
// fetch; this decides whether the chart may rescale it. Keep the two in step.
// Matched on the ticker with its punctuated contract suffix removed (.P perp,
// .PM, .PI, .F, _V) and any other punctuation dropped: NAS100USDT.P → NAS100USDT,
// US_TECH_100 → USTECH100. Never off a stock, fund or receipt — DOW, GOLD and WTI
// are also Dow Inc., Gold.com and W&T Offshore.
cfdName(string t) =>
    string s = str.upper(t)
    if str.endswith(s, ".PM") or str.endswith(s, ".PI")
        s := str.substring(s, 0, str.length(s) - 3)
    else if str.endswith(s, ".P") or str.endswith(s, ".F") or str.endswith(s, "_V")
        s := str.substring(s, 0, str.length(s) - 2)
    str.replace_all(str.replace_all(str.replace_all(s, "_", ""), ".", ""), "-", "")
var string[] nqNames = array.from("NDX", "NDQ", "NAS100", "NAS100USD", "NAS100USDT", "NAS100USDC",
     "NAS100USD1", "NAS100FT", "NAS100F", "US100", "US100USD", "US100USDT", "USTEC", "USTECF", "NDQUSD",
     "NDQ100", "NASDAQ100USDT", "NDX100USDT", "USTECH100", "USTECH100CFD", "USTECH100MINICFD", "UT100",
     "TECH100USDT", "NQCUSD", "NASDAQ")
var string[] spNames = array.from("US500", "US500F", "SPX500", "SPX500USD", "SPX500USDT", "SP500",
     "SP500USDT", "SP500USDC", "SP500USD1", "SP500FT", "SPXUSD", "SPTRD", "USSP500", "USSP500CFD", "SPCUSD")
var string[] dowNames = array.from("DJI", "US30", "US30F", "US30USD", "US30USDT", "DJ30", "DJ30F", "DJ30FT",
     "DJ30USDT", "WS30", "DJIUSD", "DOWUSD", "DJCUSD", "DOWJONESUSDT", "WALLSTREET30", "WALLSTREETCFD",
     "WALLSTREETMINICFD", "DOW")
var string[] rutNames = array.from("RUT", "US2000", "US2000USD", "US2000USDT", "RUSSELL", "RUSS2000",
     "RUSSUS", "USSMALLCAP2000", "USSMALLCAP2000CFD", "RUSUSD", "RUSSELL2000USDT")
var string[] goldNames = array.from("XAUUSD", "XAU", "XAUUSDT", "XAUUSDC", "XAUUSD247", "XAUUSDMINI",
     "XAUUSDG", "GOLD", "GOLDF", "GOLDUSDT", "GOLDUSDC", "GOLDUSD", "GOLDCASH", "GOLDCFD", "GOLDMINICFD",
     "SPOTGOLD", "GOLDXAUUSDT")
var string[] silverNames = array.from("XAGUSD", "XAG", "XAGUSDT", "XAGUSD247", "XAGUSDMINI", "XAGUSD01",
     "XAGUSD001", "SILVER", "SILVERF", "SILVERUSDT", "SILVERUSDC", "SILVERUSD", "SILVERUSD1", "SILVERCASH",
     "SILVERXAGUSDT")
var string[] wtiNames = array.from("USOIL", "USOILSPOT", "USOILF", "USOILUSDT", "USOILUSD1", "WTI", "WTI247",
     "WTIUSD", "WTICOUSD", "XTIUSD", "XTIUSDT", "USOUSD", "USCRUDEOIL", "USCRUDEOILCFD", "SPOTCRUDE",
     "USWTI", "USWTI247", "CLOIL", "OILLIGHT", "WTIOILUSD", "WTIOILUSDT", "WTIOILUSDC", "OILWTIUSDT",
     "CLUSDT", "CLUSD", "CRUDEF")
var string[] btcNames = array.from("BTCUSD", "BTCUSDT", "XBTUSD", "BTCUSDC", "BTCUSD1", "BTCUSDMINI",
     "BITCOIN")
var string[] ethNames = array.from("ETHUSD", "ETHUSDT", "ETHUSDC")
cfdTk   = cfdName(chartTk)
// Only THREE of these spellings are also US equity tickers — DOW (Dow Inc.),
// GOLD (Barrick) and WTI (W&T Offshore) — and they are the same three the
// browser extension guards with a price floor. Only they need the instrument
// type checked.
//
// Applying the guard to all of them cost us NAS100 (owner, 2026-10-08): brokers'
// index CFDs do not report a consistent syminfo.type, and on a type this guard
// rejects a correctly-resolved QQQ book refused to convert and drew $600 levels
// on a 30,000 chart — "nothing displays". Guard the ambiguous names, not the
// unambiguous ones.
var string[] stockTraps = array.from("DOW", "GOLD", "WTI")
notStk  = syminfo.type != "stock" and syminfo.type != "fund" and syminfo.type != "dr"
okCfd   = notStk or not array.includes(stockTraps, cfdTk)
isNqCfd = okCfd and array.includes(nqNames, cfdTk)
isSpCfd = okCfd and array.includes(spNames, cfdTk)
isDjCfd = okCfd and array.includes(dowNames, cfdTk)
isRtCfd = okCfd and array.includes(rutNames, cfdTk)
isWtCfd = okCfd and array.includes(wtiNames, cfdTk)
isXau   := isXau or (okCfd and array.includes(goldNames, cfdTk))
isXag   := isXag or (okCfd and array.includes(silverNames, cfdTk))
isBtcSp := isBtcSp or (okCfd and array.includes(btcNames, cfdTk))
isEthSp := isEthSp or (okCfd and array.includes(ethNames, cfdTk))
// This table must cover every root the FEED resolves, or a chart gets levels it
// cannot convert. TLT, IBIT and ETHA were missing: a BTC chart was handed IBIT
// levels — correct book, no way to rescale — and drew a $60 ETF on a $100,000
// chart with "chart BTC is not IBIT". Same for ETH and the bond futures.
// Keep in step with the resolver the add-ons share.
proxy   = (tkr == "QQQ" and (isNq or chartTk == "NDX" or isNqCfd)) or
          (tkr == "NDX" and (isNq or chartTk == "QQQ" or isNqCfd)) or
          (tkr == "SPY" and (isEs or chartTk == "SPX" or isSpCfd)) or
          (tkr == "SPX" and (isEs or chartTk == "SPY" or isSpCfd)) or
          (tkr == "IWM" and (root == "RTY" or root == "M2K" or isRtCfd)) or
          (tkr == "DIA" and (root == "YM"  or root == "MYM" or isDjCfd)) or
          (tkr == "GLD" and (root == "GC"  or root == "MGC" or isXau)) or
          (tkr == "SLV" and (root == "SI"  or root == "SIL" or isXag)) or
          (tkr == "USO" and (root == "CL"  or root == "MCL" or root == "QM" or isWtCfd)) or
          (tkr == "TLT" and (root == "ZB"  or root == "UB")) or
          (tkr == "IBIT" and (root == "BTC" or root == "MBT" or isBtcSp)) or
          (tkr == "ETHA" and (root == "ETH" or root == "MET" or isEthSp))
useBasis = (tkr == "NDX" and isNq) or (tkr == "SPX" and isEs)   // cash index → its future: add the basis, not a ratio

// Live ratio / basis, sampled only on bars where the ETF printed (etfT == time)
// so the levels do not drift with an overnight futures move.
var float liveRatio = na
var float liveBasis = na
var bool  freshNow  = false
var bool  approxRatio = false
freshNow := false
if not na(etfPx) and etfPx != 0 and not na(etfT) and etfT == time
    liveRatio   := close / etfPx
    liveBasis   := close - etfPx
    freshNow    := true
    approxRatio := false

// A chart whose bars never line up with the ETF's — a session offset, a 4-hour
// or daily bar — would otherwise read "ratio pending" forever. Fall back to the
// last ETF close on the last bar and SAY so: this is the one case where an
// overnight move in the chart can drag the levels, so it is labelled "approx",
// never "live".
if barstate.islast and na(liveRatio) and not na(etfPx) and etfPx != 0
    liveRatio   := close / etfPx
    liveBasis   := close - etfPx
    approxRatio := true

float factor = 1.0
bool  converting = false
string convNote = ""
if convMode == "Off (1:1)"
    factor := 1.0
    convNote := "1:1"
else if convMode == "Fixed ratio"
    factor := fixedRatio
    converting := fixedRatio != 1.0
    convNote := "× " + str.tostring(fixedRatio, "#,##0.####") + " (fixed)"
else if same
    factor := 1.0
    convNote := "on " + chartTk
else if proxy and useBasis and not na(liveBasis)
    converting := true
    convNote := "→ " + chartTk + " +" + str.tostring(liveBasis, "#,##0.00") + " basis" + (freshNow ? " · live" : approxRatio ? " · approx" : " · last")
else if proxy and not useBasis and not na(liveRatio)
    factor := liveRatio
    converting := true
    convNote := "→ " + chartTk + " × " + str.tostring(liveRatio, "#,##0.####") + (freshNow ? " · live" : approxRatio ? " · approx" : " · last")
else if proxy
    convNote := "→ " + chartTk + " · ratio pending (no " + tkr + " bar yet)"
else
    // Name the instrument type. The NAS100 refusal above was invisible from the
    // chart for a full round trip because the note said what it would not do and
    // not why; syminfo.type was the whole answer.
    convNote := "chart " + chartTk + " (" + syminfo.type + ") is not " + tkr + " — levels drawn 1:1"

conv(float k) =>
    float y = na
    if not na(k)
        y := useBasis and convMode == "Auto" and proxy and not na(liveBasis) ? k + liveBasis : k * factor
    y

scaleD(float d) => useBasis and convMode == "Auto" and proxy ? d : d * factor

fmtChart(float y) => str.tostring(y, format.mintick)
fmtK(float k)     => str.tostring(k, "#,##0.##")
fmtM(float m)     => (m >= 0 ? "+" : "−") + "$" + str.tostring(math.abs(m), "#,##0.0") + "M"
// The add-ons' magnitude format (Fmt.Signed): +$380M, −$1.2B, +$340K. Values in
// the pasted string are already $M.
fmtSig(float m) =>
    a = math.abs(m)
    string body = a >= 1000 ? str.tostring(a / 1000, "#,##0.0") + "B" : a >= 1 ? str.tostring(a, "#,##0") + "M" : str.tostring(a * 1000, "#,##0") + "K"
    (m >= 0 ? "+$" : "−$") + body

// Seconds since the pasted capture (its stamp is Eastern, to the minute).
pasteAgeSec() =>
    int sec = na
    if str.length(sdate) == 10 and str.length(stime) == 5
        float y  = str.tonumber(str.substring(sdate, 0, 4))
        float mo = str.tonumber(str.substring(sdate, 5, 7))
        float d  = str.tonumber(str.substring(sdate, 8, 10))
        float hh = str.tonumber(str.substring(stime, 0, 2))
        float mi = str.tonumber(str.substring(stime, 3, 5))
        if not na(y) and not na(mo) and not na(d) and not na(hh) and not na(mi)
            sec := int((timenow - timestamp("America/New_York", int(y), int(mo), int(d), int(hh), int(mi), 0)) / 1000)
    sec

ageTxt(int sec) =>
    string out = "—"
    if not na(sec) and sec >= 0
        out := sec < 60 ? str.tostring(sec) + "s" : str.tostring(int(sec / 60)) + "m" + str.tostring(sec % 60, "00") + "s"
    out

// ── Drawing (rebuilt on every update of the last bar so the ratio stays live) ─
var line[]  L  = array.new<line>()
var box[]   B  = array.new<box>()
var label[] LB = array.new<label>()

clearAll() =>
    if array.size(L) > 0
        for i = 0 to array.size(L) - 1
            line.delete(array.get(L, i))
    array.clear(L)
    if array.size(B) > 0
        for i = 0 to array.size(B) - 1
            box.delete(array.get(B, i))
    array.clear(B)
    if array.size(LB) > 0
        for i = 0 to array.size(LB) - 1
            label.delete(array.get(LB, i))
    array.clear(LB)

xLeft()  => bar_index - lineBack
xRight() => bar_index + ladderOffset + 2 * ladderLen + 2

// Levels that share a strike (C WALL = GAMMA C = #1 is common) are drawn once,
// with the names joined, so labels never pile up on one line.
var float[]  lvK = array.new<float>()
var string[] lvN = array.new<string>()
var color[]  lvC = array.new<color>()
var string[] lvS = array.new<string>()
var int[]    lvW = array.new<int>()
var float[]  lvV = array.new<float>()

addLevel(float k, color c, string name, string sty, int w, float valM) =>
    if not na(k)
        int idx = -1
        n = array.size(lvK)
        if n > 0
            for i = 0 to n - 1
                if array.get(lvK, i) == k
                    idx := i
        if idx >= 0
            array.set(lvN, idx, array.get(lvN, idx) + " · " + name)
            if na(array.get(lvV, idx)) and not na(valM)
                array.set(lvV, idx, valM)
        else
            array.push(lvK, k)
            array.push(lvN, name)
            array.push(lvC, c)
            array.push(lvS, sty)
            array.push(lvW, w)
            array.push(lvV, valM)

clearLevels() =>
    array.clear(lvK)
    array.clear(lvN)
    array.clear(lvC)
    array.clear(lvS)
    array.clear(lvW)
    array.clear(lvV)

drawLevel(float k, color c, string name, string sty, int w, float valM) =>
    if not na(k)
        y  = conv(k)
        x1 = xLeft()
        x2 = xRight()
        st = sty == "dot" ? line.style_dotted : sty == "dash" ? line.style_dashed : line.style_solid
        if glow
            array.push(L, line.new(x1, y, x2, y, xloc.bar_index, extend.none, color.new(c, 88), line.style_solid, w + 6))
            array.push(L, line.new(x1, y, x2, y, xloc.bar_index, extend.none, color.new(c, 72), line.style_solid, w + 3))
        array.push(L, line.new(x1, y, x2, y, xloc.bar_index, extend.none, c, st, w))
        txt = name + "  " + fmtChart(y) + (converting ? "   " + tkr + " " + fmtK(k) : "") + (na(valM) ? "" : "   " + fmtM(valM))
        array.push(LB, label.new(x2 + 1, y, txt, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, c, lblSize))

profileAt(float k) =>
    float v = na
    n = array.size(pk)
    if n > 0
        for i = 0 to n - 1
            if array.get(pk, i) == k
                v := array.get(pv, i)
    v

// ── Heatmap ──────────────────────────────────────────────────────────────────
lift(color c, int d) =>
    color out = color.rgb(math.min(255, color.r(c) + d), math.min(255, color.g(c) + d), math.min(255, color.b(c) + d))
    if lightBg
        out := color.rgb(math.max(0, color.r(c) - d), math.max(0, color.g(c) - d), math.max(0, color.b(c) - d))
    out

// Half the distance to the neighbouring strike (above when up, below when not),
// falling back to the other neighbour at the ends. A band spans its own slot, so
// uneven spacing (QQQ's 712.5 / 717.5 half strikes) tiles without gaps or overlap.
slotHalf(int i, bool up) =>
    int n = array.size(pk)
    float k = array.get(pk, i)
    float d = na
    bool useUp = up ? i < n - 1 : i == 0
    if useUp and i < n - 1
        d := array.get(pk, i + 1) - k
    else if i > 0
        d := k - array.get(pk, i - 1)
    d / 2

// Which strikes get shaded — Scene.SelectLevels, with the chart's price as spot.
heatSel(float spot, float maxAbs) =>
    int n = array.size(pk)
    bool[] sel = array.new<bool>(n, false)
    if n > 0 and maxAbs > 0 and heatMode != "Off"
        int firstAbove = n
        for i = 0 to n - 1
            if firstAbove == n and conv(array.get(pk, i)) >= spot
                firstAbove := i
        if heatMode == "Nearest ±"
            float thr = maxAbs * 0.12
            int bp = -1
            int bn = -1
            float dpos = na
            float dneg = na
            for i = 0 to n - 1
                v = array.get(pv, i)
                d = math.abs(conv(array.get(pk, i)) - spot)
                if v > 0 and v >= thr and (na(dpos) or d < dpos)
                    dpos := d
                    bp := i
                if v < 0 and -v >= thr and (na(dneg) or d < dneg)
                    dneg := d
                    bn := i
            if bp >= 0
                array.set(sel, bp, true)
            if bn >= 0
                array.set(sel, bn, true)
        else if heatMode == "Top 3 each side" or heatMode == "Top 5 each side" or heatMode == "Top N each side"
            int topN = heatMode == "Top 3 each side" ? 3 : heatMode == "Top 5 each side" ? 5 : heatTopN
            int[] byDesc = array.sort_indices(pv, order.descending)
            int cnt = 0
            for j = 0 to n - 1
                idx = array.get(byDesc, j)
                if cnt < topN and array.get(pv, idx) > 0
                    cnt += 1
                    array.set(sel, idx, true)
            int[] byAsc = array.sort_indices(pv, order.ascending)
            cnt := 0
            for j = 0 to n - 1
                idx = array.get(byAsc, j)
                if cnt < topN and array.get(pv, idx) < 0
                    cnt += 1
                    array.set(sel, idx, true)
        else
            bool everyStrike = heatMode == "All strikes"
            for i = 0 to n - 1
                v = array.get(pv, i)
                inRange = heatRange <= 0 or (i >= firstAbove ? (i - firstAbove) < heatRange : (firstAbove - 1 - i) < heatRange)
                if inRange and (everyStrike ? v != 0 : math.abs(v) >= maxAbs * 0.2)
                    array.set(sel, i, true)
    sel

// Nearest strike to the chart's price with this sign and at least 12 % of the
// largest — the add-ons' Panel.NearestNode, and the same rule the heatmap's
// "Nearest ±" mode uses.
nearestNode(float spot, float maxAbs, bool positive) =>
    int best = -1
    float bd = na
    int n = array.size(pk)
    if n > 0 and maxAbs > 0
        float thr = maxAbs * 0.12
        for i = 0 to n - 1
            v = array.get(pv, i)
            bool keep = positive ? v > 0 and v >= thr : v < 0 and -v >= thr
            if keep
                d = math.abs(conv(array.get(pk, i)) - spot)
                if na(bd) or d < bd
                    bd := d
                    best := i
    best

// "30766.25  −21 pt  $420  +$87M" on a futures chart; no $ column when the
// symbol carries no point value (a stock or an ETF, where it is 1).
nodeTxt(int idx) =>
    string out = "—"
    if idx >= 0
        k = array.get(pk, idx)
        v = array.get(pv, idx)
        y = conv(k)
        d = y - close
        string dollars = syminfo.pointvalue != 1 ? "  $" + str.tostring(math.abs(d) * syminfo.pointvalue, "#,##0") : ""
        out := fmtChart(y) + "  " + (d >= 0 ? "+" : "−") + str.tostring(math.abs(d), format.mintick) + " pt" + dollars + "  " + fmtSig(v)
    out

// Drawn before the ladder and the level lines so both sit on top of it.
// Band opacity = strength × (6 % + 94 % × size^0.8); Fade and Line follow the
// desktop marks (fade peak 30 % + 70 % × size at the default 55 % strength,
// 12 steps easing toward the ladder; line 1–3 px).
heatDraw(float spot) =>
    int n = array.size(pk)
    if n > 1 and heatMode != "Off"
        float maxAbs = 0.0
        for i = 0 to n - 1
            maxAbs := math.max(maxAbs, math.abs(array.get(pv, i)))
        if maxAbs > 0
            bool[] sel = heatSel(spot, maxAbs)
            int cnt = 0
            for i = 0 to n - 1
                if array.get(sel, i)
                    cnt += 1
            int back = heatWidth == "Right half" ? int(lineBack / 2) : heatWidth == "Right third" ? int(lineBack / 3) : lineBack
            int x0 = bar_index - back
            int x1 = showLadder ? bar_index + math.max(0, ladderOffset - 1) : xRight()
            if x1 <= x0
                x1 := x0 + 1
            // Fade takes up to 12 boxes a strike: keep inside max_boxes_count with the ladder's share reserved
            int budget = 480 - array.size(B) - (showLadder ? n : 0)
            int steps = heatStyle == "Fade" and cnt > 0 ? math.max(1, math.min(12, int(budget / cnt))) : 1
            float s = heatStr / 100.0
            for i = 0 to n - 1
                if array.get(sel, i)
                    k = array.get(pk, i)
                    v = array.get(pv, i)
                    w = math.abs(v) / maxAbs
                    c = v >= 0 ? cPos : cNeg
                    y = conv(k)
                    yHi = conv(k + slotHalf(i, true))
                    yLo = conv(k - slotHalf(i, false))
                    if heatStyle == "Band"
                        a = s * (0.06 + 0.94 * math.pow(w, 0.8))
                        array.push(B, box.new(x0, yHi, x1, yLo, border_color = color.new(c, 100), bgcolor = color.new(c, math.round(100 - 100 * a))))
                    else if heatStyle == "Fade"
                        th = (yHi - yLo) * (0.18 + 0.32 * w) / 2
                        peak = math.min(0.95, s / 0.55 * (0.30 + 0.70 * w))
                        for j = 0 to steps - 1
                            xa = x0 + int((x1 - x0) * j / steps)
                            xb = x0 + int((x1 - x0) * (j + 1) / steps)
                            aj = peak * math.pow((j + 1.0) / steps, 1.7)
                            if xb > xa
                                array.push(B, box.new(xa, y + th, xb, y - th, border_color = color.new(c, 100), bgcolor = color.new(c, math.round(100 - 100 * aj))))
                        array.push(L, line.new(x0, y, x1, y, xloc.bar_index, extend.none, color.new(lift(c, 60), math.round(100 - 100 * math.min(1.0, peak + 0.24))), line.style_solid, 1))
                    else
                        array.push(L, line.new(x0, y, x1, y, xloc.bar_index, extend.none, color.new(c, 10), line.style_solid, 1 + math.round(2 * w)))
                    if heatLbl != "Off"
                        t = (heatLbl == "Price + value" ? fmtChart(y) + "  " : "") + fmtM(v)
                        array.push(LB, label.new(x1, y, t, xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_right, c, lblSize))

if barstate.islast
    clearAll()
    clearLevels()
    if ok
        // zone between the walls, tinted by the cohort's net gamma sign
        if showZone and not na(cw) and not na(pw) and cw > pw
            zc = na(netM) or netM >= 0 ? cPos : cNeg
            array.push(B, box.new(left = xLeft(), top = conv(cw), right = xRight(), bottom = conv(pw),
                 border_color = color.new(zc, 100), bgcolor = color.new(zc, 93)))
        // heatmap: strikes shaded by size, under everything else
        heatDraw(close)
        // ladder: the strike profile on the right edge
        np = array.size(pk)
        if showLadder and np > 1
            float step = na
            float maxAbs = 0.0
            for i = 0 to np - 1
                a = math.abs(array.get(pv, i))
                if a > maxAbs
                    maxAbs := a
                if i > 0
                    d = array.get(pk, i) - array.get(pk, i - 1)
                    if d > 0 and (na(step) or d < step)
                        step := d
            if maxAbs > 0 and not na(step)
                hh = scaleD(step) * 0.42
                // Zero axis sits in the MIDDLE of the ladder region: negative
                // (put) gamma grows LEFT of it, positive (call) grows right,
                // the way the dashboard's profile reads. The region still
                // begins at bar_index + ladderOffset, so nothing overlaps the
                // candles; it is ladderLen wide on each side.
                xMid = bar_index + ladderOffset + ladderLen
                array.push(L, line.new(xMid, conv(array.get(pk, 0)) - hh, xMid, conv(array.get(pk, np - 1)) + hh, xloc.bar_index, extend.none, color.new(cTop, 65), line.style_solid, 1))
                for i = 0 to np - 1
                    k = array.get(pk, i)
                    v = array.get(pv, i)
                    y = conv(k)
                    len = math.max(1, math.round(ladderLen * math.abs(v) / maxAbs))
                    c = v >= 0 ? cPos : cNeg
                    xa = v >= 0 ? xMid : xMid - len
                    xb = v >= 0 ? xMid + len : xMid
                    isWall = (not na(cw) and k == cw) or (not na(pw) and k == pw)
                    alpha = isWall ? 12 : math.round(78 - 50 * math.abs(v) / maxAbs)
                    array.push(B, box.new(left = xa, top = y + hh, right = xb, bottom = y - hh,
                         border_color = isWall ? c : color.new(c, 100), border_width = 1, bgcolor = color.new(c, alpha)))
        // lines + labels (drawn after the ladder so labels sit on top)
        if showWalls
            addLevel(cw, cPos, "C WALL", "solid", 2, profileAt(cw))
            addLevel(pw, cNeg, "P WALL", "solid", 2, profileAt(pw))
        if showFlip
            addLevel(flip, cAmb, "FLIP", "dot", 1, na)
        if showGamma
            addLevel(gc, cPos, "GAMMA C", "dash", 1, na)
            addLevel(gp, cNeg, "GAMMA P", "dash", 1, na)
        if showTop and array.size(topK) > 0
            for i = 0 to array.size(topK) - 1
                k = array.get(topK, i)
                v = profileAt(k)
                addLevel(k, na(v) ? cTop : v >= 0 ? cPos : cNeg, "#" + str.tostring(i + 1), "dot", 1, v)
        nl = array.size(lvK)
        if nl > 0
            for i = 0 to nl - 1
                drawLevel(array.get(lvK, i), array.get(lvC, i), array.get(lvN, i), array.get(lvS, i), array.get(lvW, i), array.get(lvV, i))
        // spot at the time of the paste
        if not na(spot0)
            ys = conv(spot0)
            array.push(L, line.new(xLeft(), ys, bar_index, ys, xloc.bar_index, extend.none, color.new(cAmb, 60), line.style_dotted, 1))
            array.push(LB, label.new(xLeft(), ys, "spot @ " + stime + " ET  " + fmtChart(ys), xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_right, color.new(cAmb, 20), lblSize))

// ── Panel ────────────────────────────────────────────────────────────────────
// "Header" is the three lines this script has always drawn, top right. "Full"
// is the orderflow plugin's data panel (core Panel.Build) as far as the pasted
// string reaches: the header line, net gamma, the nearest ± nodes with their
// distance in points and dollars, and the five biggest strikes each way. The
// plugin's change windows (1 / 5 / 15 / 30 min) need the session's history and
// its "Model —" line needs a field the string does not carry, so neither is
// here rather than faked.
var table hdr = table.new(position.top_right, 1, 3, bgcolor = hdrBg, border_width = 0)
var table pnl = table.new(pnlPos, 4, 14, bgcolor = pBg, frame_color = pFrame, frame_width = 1, border_width = 0)

pcell(int c, int r, string txt, color tint, string halign, bool bold) =>
    table.cell(pnl, c, r, txt, text_color = tint, text_size = panelSize, text_halign = halign, text_font_family = font.family_monospace)
    if bold
        table.cell_set_text_formatting(pnl, c, r, text.format_bold)

rule(int r) =>
    pcell(0, r, "──────────", pFrame, text.align_left, false)
    pcell(1, r, "──────", pFrame, text.align_right, false)
    pcell(2, r, "──────────", pFrame, text.align_left, false)
    pcell(3, r, "──────", pFrame, text.align_right, false)

if barstate.islast
    table.clear(hdr, 0, 0, 0, 2)
    table.clear(pnl, 0, 0, 3, 13)
    if panelMode == "Header"
        if ok
            table.cell(hdr, 0, 0, "quantedOptions levels · " + tkr + " · " + cohort, text_color = cAmb, text_size = lblSize, text_halign = text.align_left)
            table.cell(hdr, 0, 1, sdate + " " + stime + " ET · spot " + fmtK(spot0) + (na(netM) ? "" : " · net " + fmtM(netM)), text_color = color.new(cTop, 15), text_size = lblSize, text_halign = text.align_left)
            table.cell(hdr, 0, 2, convNote + "  ·  v" + VER, text_color = (proxy or same or convMode != "Auto") ? color.new(cTop, 35) : cNeg, text_size = lblSize, text_halign = text.align_left)
        else
            table.cell(hdr, 0, 0, "quantedOptions levels", text_color = cAmb, text_size = lblSize, text_halign = text.align_left)
            table.cell(hdr, 0, 1, lv == "" ? "Paste the string from quantedOptions (levels strip → Copy for TradingView) in the indicator settings." : "Could not read that string — copy it again from quantedOptions.", text_color = color.new(cTop, 15), text_size = lblSize, text_halign = text.align_left)
            table.cell(hdr, 0, 2, "", text_size = lblSize)
    else if panelMode == "Full"
        if not ok
            pcell(0, 0, "quantedOptions Profile", cAmb, text.align_left, true)
            pcell(0, 1, lv == "" ? "Paste the string from quantedOptions (levels strip → Copy for TradingView) in the indicator settings." : "Could not read that string — copy it again from quantedOptions.", pDim, text.align_left, false)
        else
            string mmdd = str.length(sdate) == 10 ? str.substring(sdate, 5, 10) : ""
            string left = converting ? chartTk + " · from " + tkr + " " + cohort : tkr + " · " + cohort
            pcell(0, 0, left + (mmdd == "" ? "" : " " + mmdd), pDim, text.align_left, false)
            pcell(3, 0, tkr + " " + fmtK(spot0) + (converting ? " → " + chartTk + " " + fmtChart(conv(spot0)) : ""), pBright, text.align_right, false)
            // No status dot (owner, 2026-09-29): the age carries the same thing,
            // and only says so in colour once it is worth saying — dim while
            // fresh, amber past 2 minutes, red past 5.
            int age = pasteAgeSec()
            color freshCol = na(age) ? pFaint : age > 300 ? pStale : age > 120 ? pAging : pDim
            pcell(0, 1, ageTxt(age), freshCol, text.align_left, false)
            pcell(3, 1, stime + " ET", pFaint, text.align_right, false)
            rule(2)
            pcell(0, 3, "Net " + cohort + " GEX", pDim, text.align_left, false)
            pcell(3, 3, na(netM) ? "—" : fmtSig(netM), na(netM) or netM >= 0 ? cPos : cNeg, text.align_right, true)
            int np2 = array.size(pk)
            float maxAbs2 = 0.0
            if np2 > 0
                for i = 0 to np2 - 1
                    maxAbs2 := math.max(maxAbs2, math.abs(array.get(pv, i)))
            int ip = nearestNode(close, maxAbs2, true)
            int inn = nearestNode(close, maxAbs2, false)
            pcell(0, 4, "Nearest + node", pDim, text.align_left, false)
            pcell(3, 4, nodeTxt(ip), cPos, text.align_right, false)
            pcell(0, 5, "Nearest − node", pDim, text.align_left, false)
            pcell(3, 5, nodeTxt(inn), cNeg, text.align_right, false)
            rule(6)
            pcell(0, 7, "Highest Positive GEX", pFaint, text.align_left, false)
            pcell(2, 7, "Highest Negative GEX", pFaint, text.align_left, false)
            if np2 > 0
                int[] byDesc2 = array.sort_indices(pv, order.descending)
                int[] byAsc2  = array.sort_indices(pv, order.ascending)
                for r = 0 to 4
                    if r < np2
                        ipos = array.get(byDesc2, r)
                        if array.get(pv, ipos) > 0
                            pcell(0, 8 + r, fmtChart(conv(array.get(pk, ipos))), pBright, text.align_left, false)
                            pcell(1, 8 + r, fmtSig(array.get(pv, ipos)), cPos, text.align_right, false)
                        ineg = array.get(byAsc2, r)
                        if array.get(pv, ineg) < 0
                            pcell(2, 8 + r, fmtChart(conv(array.get(pk, ineg))), pBright, text.align_left, false)
                            pcell(3, 8 + r, fmtSig(array.get(pv, ineg)), cNeg, text.align_right, false)

// ── Alerts (levels are plotted invisibly so TradingView alerts see them) ─────
cwY   = conv(cw)
pwY   = conv(pw)
flipY = conv(flip)
plot(cwY,   "Call wall", display = display.none)
plot(pwY,   "Put wall",  display = display.none)
plot(flipY, "Flip",      display = display.none)
xCw   = ta.cross(close, cwY)
xPw   = ta.cross(close, pwY)
xFlip = ta.cross(close, flipY)
alertcondition(not na(cwY)   and xCw,   "Price crosses the call wall",  "quantedOptions: price crossed the call wall")
alertcondition(not na(pwY)   and xPw,   "Price crosses the put wall",   "quantedOptions: price crossed the put wall")
alertcondition(not na(flipY) and xFlip, "Price crosses the gamma flip", "quantedOptions: price crossed the gamma flip")
````
