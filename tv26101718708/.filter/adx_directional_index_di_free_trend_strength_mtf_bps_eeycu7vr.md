# ADX Directional Index DI FREE , Trend Strength MTF //BPS

- url: https://www.tradingview.com/script/EeYcU7VR/
- type: indicator
- pine_id: PUB;0ee591cbc9b2409baf049a47b8c2e65b
- version: 2.0

## Description

Trend-strength indicator with classic ADX, Directional Index (DI+ /
DI-), color-coded strength zones, crossover signals and a
10-timeframe dashboard.

📊 WHAT IT SHOWS
• ADX line (0–100) — measures trend strength regardless of direction
• DI+ and DI- lines — show directional pressure (bull vs bear)
• Bullish / bearish crossover signals when DI lines cross
• Multi-timeframe dashboard: D, 4H, 2H, 1H, 30m, 15m, 10m, 5m, 3m, 1m
• Color-coded background highlighting strong trends

🎯 HOW TO USE
• ADX > 20 = trending market → use trend-following strategies
• ADX < 20 = ranging market → mean-reversion / range setups
• DI+ crosses above DI- = bullish bias · DI- above DI+ = bearish
• Use the 10-TF dashboard for instant multi-timeframe context
• Pair with Smart Money for order-block + trend confluence

🔑 KEYWORDS
ADX, Directional Index, DI+, DI-, Trend Strength, Multi-Timeframe,
MTF Dashboard, Wilder, Average Directional Index, Trend Following,
Crossover Signals

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// 🚀  ADX Directional Index DI FREE , Trend Strength MTF Dashboard //BPS 
// ═══════════════════════════════════════════════════════════════════
//
// ──── COPY-PASTE FOR TRADINGVIEW DESCRIPTION ────────────────────────
//
// FREE version of the BPS ADX / Directional Index. Classic ADX, DI+ / DI-,
// color-coded strength zones, crossover signals and a multi-timeframe
// dashboard. The higher timeframes (D / 4H / 2H / 1H / 30m) are free;
// the faster timeframes (15m / 10m / 5m / 3m / 1m) are 🔒 PRO.
//
// 📊 WHAT IT SHOWS
//   • ADX line (0,100) , measures trend strength regardless of direction
//   • DI+ and DI- lines , show directional pressure (bull vs bear)
//   • Bullish / bearish crossover signals when DI lines cross
//   • Multi-timeframe dashboard: D, 4H, 2H, 1H, 30m  (15m and below 🔒 PRO)
//   • Color-coded background highlighting strong trends
//
// 🎯 HOW TO USE
//   • ADX > 20 = trending market → use trend-following strategies
//   • ADX < 20 = ranging market → mean-reversion / range setups
//   • DI+ crosses above DI- = bullish bias · DI- above DI+ = bearish
//   • Unlock the 5 faster timeframes (15m → 1m) with the PRO version
//
// ⭐ Unlock all 10 timeframes + 13 PRO indicators:
//    →  bestpinescripts.com
//
// ──── END COPY-PASTE ────────────────────────────────────────────────
//
// 100% free for all TradingView users , no signup required.
// © GLOMASTCO Ltd. (Cyprus)  •  Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// ═══════════════════════════════════════════════════════════════════
//@version=6
indicator("ADX Directional Index DI FREE , Trend Strength MTF Dashboard //BPS - bestpinescripts.com",
     shorttitle="ADX FREE //BPS",
     overlay=false,
     precision=1)

// ─────────────────────────────────────────────────────────────
// ⭐  BPS , Info & Pro Upgrade   (shown at top of settings)
// ─────────────────────────────────────────────────────────────
grp_bps_promo = "⭐ BestPineScripts.com"
_bps_promo    = input.bool(true,
     "FREE version , unlock 15m / 10m / 5m / 3m / 1m + 13 PRO indicators at bestpinescripts.com",
     group=grp_bps_promo,
     tooltip="This is the FREE ADX. The dashboard shows D / 4H / 2H / 1H / 30m. The 5 faster timeframes (15m → 1m) are 🔒 PRO.\n\nUpgrade for full multi-TF + Auto Chart Pattern V2 (14 patterns, alerts & DD-tracking).\n\n→ bestpinescripts.com")

// ─────────────────────────────────────────────────────────────
// 🔧  S E T T I N G S
// ─────────────────────────────────────────────────────────────

grp_main = "📊 ADX Settings"
adxPeriod    = input.int(14, "ADX Period",    minval=1, maxval=100, group=grp_main)
adxThreshold = input.int(20, "Trend Threshold", minval=5, maxval=50, group=grp_main,
     tooltip="ADX above this level indicates a trending market")
adxSmoothing = input.int(14, "ADX Smoothing", minval=1, maxval=50, group=grp_main)

grp_style = "🎨 Colors & Style"
colDIPlus  = input.color(color.new(#22c55e, 0), "DI+ Color", group=grp_style, inline="di")
colDIMinus = input.color(color.new(#ef4444, 0), "DI- Color", group=grp_style, inline="di")
colADX     = input.color(color.new(#0d6efd, 0), "ADX Color", group=grp_style)
adxWidth   = input.int(2, "ADX Line Width", minval=1, maxval=4, group=grp_style)
diWidth    = input.int(1, "DI Line Width",  minval=1, maxval=4, group=grp_style)

grp_extras = "⚙ Extras"
showFill    = input.bool(true, "Fill DI+/DI- Area",       group=grp_extras)
showSignals = input.bool(true, "Show Crossover Signals",   group=grp_extras)
showBg      = input.bool(true, "Highlight Strong Trend",   group=grp_extras,
     tooltip="Background color when ADX is above threshold")

// ── Dashboard & Display ──────────────────────────────────────
grpDB = "📋 Dashboard & Display"
showTable = input.bool(true, "Show Decision Dashboard", group=grpDB,
     tooltip="One-glance verdict: STRONG TREND ▲/▼ / WEAK TREND / NO TREND , plus the multi-timeframe context.")
tablePos  = input.string("Bottom Left", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpDB)
tableSize = input.string("Small", "Font Size",
     options=["Tiny","Small","Normal","Large"], group=grpDB)
themeMode = input.string("Auto", "Theme",
     options=["Auto","Dark","Light","Glass"], group=grpDB,
     tooltip="Auto = follow chart background. Glass = semi-transparent overlay.")

// ─────────────────────────────────────────────────────────────
// 🛠️  H E L P E R
// ─────────────────────────────────────────────────────────────

getPos(p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.bottom_left

getSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>         size.small

// ── BPS Theme Module ────────────────────────────────────────
isLightChartBg() =>
    bg  = chart.bg_color
    lum = (color.r(bg) * 0.299 + color.g(bg) * 0.587 + color.b(bg) * 0.114) / 255.0
    lum > 0.5

useDark  = themeMode == "Dark"  or (themeMode == "Auto" and not isLightChartBg())
useGlass = themeMode == "Glass"

TBL_BG       = useGlass ? color.new(color.black,  82) : useDark ? color.new(#141a2e, 0) : color.new(#f0f3f8, 0)
TBL_BG_ALT   = useGlass ? color.new(color.black,  72) : useDark ? color.new(#1a2138, 0) : color.new(#f0f3f8, 0)
TBL_BORDER   = useGlass ? color.new(color.gray,   60) : useDark ? color.new(#2a3554, 0) : color.new(#c5cdd9, 0)
TBL_TEXT     = useGlass ? color.new(color.white,   0) : useDark ? color.new(#f0f3f8, 0) : color.new(#0a0e1a, 0)
TBL_TEXTDIM  = useGlass ? color.new(color.white,  35) : useDark ? color.new(#8b94a8, 0) : color.new(#8b94a8, 0)
TBL_HEADER   = color.new(#0d6efd, 0)
TBL_HEADERTX = color.new(#f0f3f8, 0)
TBL_BULL     = color.new(#22c55e, 0)
TBL_BEAR     = color.new(#ef4444, 0)
TBL_WARN     = color.new(#f59e0b, 0)

// ─────────────────────────────────────────────────────────────
// 📈  A D X   C A L C U L A T I O N   (function per TF)
// ─────────────────────────────────────────────────────────────

calcADX(tf) =>
    [_di_plus, _di_minus, _adx] = request.security(syminfo.tickerid, tf,
         ta.dmi(adxPeriod, adxSmoothing),
         lookahead=barmerge.lookahead_off)
    [_di_plus, _di_minus, _adx]

// Chart calculation (current TF) for plots
tr = math.max(high - low,
     math.max(math.abs(high - nz(close[1])), math.abs(low - nz(close[1]))))

dmUp   = high - nz(high[1]) > nz(low[1]) - low ?
         math.max(high - nz(high[1]), 0.0) : 0.0
dmDown = nz(low[1]) - low > high - nz(high[1]) ?
         math.max(nz(low[1]) - low, 0.0) : 0.0

var float smoothTR     = 0.0
var float smoothDMUp   = 0.0
var float smoothDMDown = 0.0

smoothTR     := nz(smoothTR[1])     - nz(smoothTR[1])     / adxPeriod + tr
smoothDMUp   := nz(smoothDMUp[1])   - nz(smoothDMUp[1])   / adxPeriod + dmUp
smoothDMDown := nz(smoothDMDown[1]) - nz(smoothDMDown[1]) / adxPeriod + dmDown

diPlus  = smoothTR != 0 ? smoothDMUp   / smoothTR * 100 : 0.0
diMinus = smoothTR != 0 ? smoothDMDown / smoothTR * 100 : 0.0

diSum = diPlus + diMinus
dx    = diSum != 0 ? math.abs(diPlus - diMinus) / diSum * 100 : 0.0
adx   = ta.sma(dx, adxSmoothing)

// ─────────────────────────────────────────────────────────────
// 🚦  S I G N A L S
// ─────────────────────────────────────────────────────────────

bullCross   = ta.crossover(diPlus, diMinus)
bearCross   = ta.crossunder(diPlus, diMinus)
strongTrend = adx > adxThreshold

// ─────────────────────────────────────────────────────────────
// 📊  P L O T S
// ─────────────────────────────────────────────────────────────

pDIPlus  = plot(diPlus,  "DI+", color=colDIPlus,  linewidth=diWidth)
pDIMinus = plot(diMinus, "DI-", color=colDIMinus, linewidth=diWidth)
plot(adx, "ADX", color=colADX, linewidth=adxWidth)

hline(adxThreshold, "Threshold",
     color=color.new(color.gray, 50), linestyle=hline.style_dashed)

fillCol = showFill ?
     (diPlus > diMinus ? color.new(colDIPlus, 88) :
                         color.new(colDIMinus, 88)) : na
fill(pDIPlus, pDIMinus, color=fillCol, title="DI Fill")

bgCol = showBg and strongTrend ?
     (diPlus > diMinus ? color.new(colDIPlus,  92) :
                         color.new(colDIMinus, 92)) : na
bgcolor(bgCol, title="Trend Background")

plotshape(showSignals and bullCross ? diPlus  : na,
     title="Bullish DI Cross", style=shape.triangleup,
     location=location.absolute, color=colDIPlus,  size=size.tiny)

plotshape(showSignals and bearCross ? diMinus : na,
     title="Bearish DI Cross", style=shape.triangledown,
     location=location.absolute, color=colDIMinus, size=size.tiny)

// ═════════════════════════════════════════════════════════════
// 📋  DECISION DASHBOARD
//    Row 0 = VERDICT · Row 1 = Why · Rows 2-4 = TF grid
//    FREE: D / 4H / 2H / 1H / 30m unlocked · 15m and below 🔒 PRO
// ═════════════════════════════════════════════════════════════

// Only fetch the unlocked (higher) timeframes in the FREE version
[dpD,   dmD,   adxD]   = calcADX("D")
[dp4H,  dm4H,  adx4H]  = calcADX("240")
[dp2H,  dm2H,  adx2H]  = calcADX("120")
[dp1H,  dm1H,  adx1H]  = calcADX("60")
[dp30,  dm30,  adx30]  = calcADX("30")
// 15m / 10m / 5m / 3m / 1m are 🔒 PRO , not fetched here.

// ── Verdict computation (current TF) ────────────────────────
adxNow  = adx
diBull  = diPlus > diMinus
strongTrendNow = adxNow > adxThreshold
veryStrong     = adxNow > adxThreshold * 2

verdictTxt = ","
verdictTx  = TBL_TEXTDIM
verdictBg  = TBL_BG_ALT
reasonTxt  = ""

if not na(adxNow)
    if veryStrong and diBull
        verdictTxt := "▲ STRONG UPTREND"
        verdictTx  := color.new(#f0f3f8, 0)
        verdictBg  := color.new(#22c55e, 20)
        reasonTxt  := "ADX " + str.tostring(math.round(adxNow, 1)) + " (very strong) and DI+ leads"
    else if veryStrong and not diBull
        verdictTxt := "▼ STRONG DOWNTREND"
        verdictTx  := color.new(#f0f3f8, 0)
        verdictBg  := color.new(#ef4444, 20)
        reasonTxt  := "ADX " + str.tostring(math.round(adxNow, 1)) + " (very strong) and DI- leads"
    else if strongTrendNow and diBull
        verdictTxt := "▲ UPTREND"
        verdictTx  := TBL_BULL
        verdictBg  := color.new(#22c55e, 70)
        reasonTxt  := "ADX " + str.tostring(math.round(adxNow, 1)) + " > " + str.tostring(adxThreshold) + " and DI+ > DI-"
    else if strongTrendNow and not diBull
        verdictTxt := "▼ DOWNTREND"
        verdictTx  := TBL_BEAR
        verdictBg  := color.new(#ef4444, 70)
        reasonTxt  := "ADX " + str.tostring(math.round(adxNow, 1)) + " > " + str.tostring(adxThreshold) + " and DI- > DI+"
    else
        verdictTxt := "◇ NO TREND"
        verdictTx  := TBL_TEXTDIM
        verdictBg  := TBL_BG_ALT
        reasonTxt  := "ADX " + str.tostring(math.round(adxNow, 1)) + " < " + str.tostring(adxThreshold) + " , ranging market, avoid trend-following"

if barstate.islast and showTable
    var tbl = table.new(getPos(tablePos), 10, 5,
         bgcolor=TBL_BG,
         border_width=1,
         border_color=TBL_BORDER,
         frame_width=2,
         frame_color=TBL_BORDER)

    tblSize = getSize(tableSize)

    // Row 1: Verdict (merged across all 10 cols)
    table.merge_cells(tbl, 0, 0, 9, 0)
    table.cell(tbl, 0, 0, verdictTxt,   text_color=verdictTx, bgcolor=verdictBg, text_size=tblSize, text_halign=text.align_center)

    // Row 2: Why
    table.merge_cells(tbl, 0, 1, 9, 1)
    table.cell(tbl, 0, 1, reasonTxt,    text_color=TBL_TEXT, bgcolor=TBL_BG_ALT, text_size=tblSize, text_halign=text.align_center)

    // Rows 3-5: TF grid (5 unlocked + 5 locked)
    tfLabels = array.from("D",   "4H",  "2H",  "1H", "30m","15m","10m","5m","3m","1m")
    adxVals  = array.from(adxD,  adx4H, adx2H, adx1H, adx30)
    dpVals   = array.from(dpD,   dp4H,  dp2H,  dp1H,  dp30)
    dmVals   = array.from(dmD,   dm4H,  dm2H,  dm1H,  dm30)

    for i = 0 to 9
        lbl = array.get(tfLabels, i)
        isLocked = i >= 5  // 15m, 10m, 5m, 3m, 1m

        if isLocked
            table.cell(tbl, i, 2, lbl,   text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 3, "🔒",  text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 4, "",    text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
        else
            av  = array.get(adxVals,  i)
            dp  = array.get(dpVals,   i)
            dm  = array.get(dmVals,   i)

            bullDir  = not na(dp) and not na(dm) and dp > dm
            strong   = not na(av) and av > adxThreshold

            cellBg = strong and bullDir       ? color.new(#22c55e, 70) :
                     strong and not bullDir    ? color.new(#ef4444, 70) :
                                                 TBL_BG_ALT

            adxCol = strong ? TBL_WARN : TBL_TEXTDIM
            arrow      = na(dp) or na(dm) ? "," : bullDir ? "▲" : "▼"
            arrowCol   = bullDir ? TBL_BULL : TBL_BEAR
            adxStr     = na(av) ? "," : str.tostring(math.round(av, 1))

            table.cell(tbl, i, 2, lbl,    text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT,   text_halign=text.align_center)
            table.cell(tbl, i, 3, adxStr, text_color=adxCol,      text_size=tblSize, bgcolor=cellBg,       text_halign=text.align_center)
            table.cell(tbl, i, 4, arrow,  text_color=arrowCol,    text_size=tblSize, bgcolor=TBL_BG,       text_halign=text.align_center)

// (Branding watermark removed)
````
