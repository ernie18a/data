# Relative Strength Index RSI FREE , Multi-Timeframe MTF //BPS

- url: https://www.tradingview.com/script/2JTbjNAv/
- type: indicator
- pine_id: PUB;fb02ba9a1d2b48baa2813ff5e1bb224e
- version: 2.0

## Description

Multi-timeframe RSI with up to three timeframes plotted
simultaneously plus a 10-timeframe trend-confluence dashboard.

📊 WHAT IT SHOWS
• Up to 3 RSI lines on chart from independent timeframes
• 10-timeframe dashboard (D → 1m) with RSI values + direction arrows
• Configurable overbought / oversold / middle levels
• Confluence signals when 2 or 3 TFs agree (BULL ▲ / BEAR ▼)
• Optional background highlight on trend confluence

🎯 HOW TO USE
• Trade in direction of higher TF — only long when 4h+ RSI > 50
• Wait for confluence — all 3 TFs agreeing = high-probability setup
• Look for RSI divergence on HTF combined with oversold on LTF for entries
• Use as a filter, not a trigger — pair with structure breaks

🔑 KEYWORDS
RSI, Relative Strength Index, Multi-Timeframe RSI, MTF RSI, RSI
Divergence, Overbought, Oversold, Confluence, RSI Dashboard,
Wilder, Momentum Oscillator

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// 🚀  Relative Strength Index RSI FREE , Multi-Timeframe MTF Confluence //BPS
// ═══════════════════════════════════════════════════════════════════
//
// ──── COPY-PASTE FOR TRADINGVIEW DESCRIPTION ────────────────────────
//
// FREE version of the BPS Multi-Timeframe RSI. Up to three RSI lines on
// chart plus a multi-timeframe confluence dashboard. The higher
// timeframes (D / 4H / 2H / 1H / 30m) are free; the faster timeframes
// (15m / 10m / 5m / 3m / 1m) are 🔒 PRO.
//
// 📊 WHAT IT SHOWS
//   • Up to 3 RSI lines on chart from independent timeframes (30m+)
//   • Multi-timeframe dashboard (D → 30m) with RSI values + arrows
//   • Configurable overbought / oversold / middle levels
//   • Confluence signals when 2 or 3 TFs agree (BULL ▲ / BEAR ▼)
//   • Optional background highlight on trend confluence
//
// 🎯 HOW TO USE
//   • Trade in direction of higher TF , only long when 4h+ RSI > 50
//   • Wait for confluence , all 3 TFs agreeing = high-probability setup
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
indicator("Relative Strength Index RSI FREE , Multi-Timeframe MTF Confluence //BPS - bestpinescripts.com",
     shorttitle="RSI MTF FREE //BPS",
     overlay=false,
     format=format.price,
     precision=1)

// ─────────────────────────────────────────────────────────────
// ⭐  BPS , Info & Pro Upgrade   (shown at top of settings)
// ─────────────────────────────────────────────────────────────
grp_bps_promo = "⭐ BestPineScripts.com"
_bps_promo    = input.bool(true,
     "FREE version , unlock 15m / 10m / 5m / 3m / 1m + 13 PRO indicators at bestpinescripts.com",
     group=grp_bps_promo,
     tooltip="This is the FREE Multi-TF RSI. The dashboard shows D / 4H / 2H / 1H / 30m. The 5 faster timeframes (15m → 1m) are 🔒 PRO.\n\nUpgrade for full multi-TF + Auto Chart Pattern V2 (14 patterns, alerts & DD-tracking).\n\n→ bestpinescripts.com")

// ─────────────────────────────────────────────────────────────
// 🔧  S E T T I N G S
// ─────────────────────────────────────────────────────────────

grp_rsi = "📊 RSI Settings"
rsiLength = input.int(14,    "RSI Length", minval=2, maxval=100, group=grp_rsi)
rsiSource = input.source(close, "Source",              group=grp_rsi)

grp_zones = "📏 Zones"
obLevel  = input.int(70, "Overbought", minval=50, maxval=95, group=grp_zones)
osLevel  = input.int(30, "Oversold",   minval=5,  maxval=50, group=grp_zones)
midLevel = input.int(50, "Middle Line",                       group=grp_zones)

grp_tf = "⏱️ Chart Lines (3 selectable Timeframes , 30m+)"
tf1_enabled = input.bool(true, "TF 1 Active", group=grp_tf, inline="tf1")
tf1 = input.timeframe("60", "TF 1", group=grp_tf, inline="tf1",
     options=["30","60","120","240","D"])
tf2_enabled = input.bool(true, "TF 2 Active", group=grp_tf, inline="tf2")
tf2 = input.timeframe("240", "TF 2", group=grp_tf, inline="tf2",
     options=["30","60","120","240","D"])
tf3_enabled = input.bool(true, "TF 3 Active", group=grp_tf, inline="tf3")
tf3 = input.timeframe("D", "TF 3", group=grp_tf, inline="tf3",
     options=["30","60","120","240","D"])

grp_style = "🎨 Colors & Style"
col_tf1    = input.color(color.new(#0d6efd, 0), "TF 1 Color", group=grp_style, inline="c1")
col_tf2    = input.color(color.new(#FF6D00, 0), "TF 2 Color", group=grp_style, inline="c1")
col_tf3    = input.color(color.new(#22c55e, 0), "TF 3 Color", group=grp_style, inline="c1")
lineWidth1 = input.int(2, "TF 1 Width", minval=1, maxval=4, group=grp_style)
lineWidth2 = input.int(2, "TF 2 Width", minval=1, maxval=4, group=grp_style)
lineWidth3 = input.int(3, "TF 3 Width", minval=1, maxval=4, group=grp_style)

grp_signal = "🚦 Trend Signals"
showSignals     = input.bool(true, "Show Signals",                group=grp_signal)
signalMode      = input.string("All 3 TF Agree", "Signal Mode",
     options=["All 3 TF Agree","At Least 2 TF Agree"],          group=grp_signal)
showBgHighlight = input.bool(true, "Trend Background",            group=grp_signal)

// ── Dashboard & Display ──────────────────────────────────────
grpDB = "📋 Dashboard & Display"
showTable = input.bool(true, "Show Decision Dashboard", group=grpDB,
     tooltip="One-glance verdict: BULL/BEAR CONFLUENCE / OVERBOUGHT / OVERSOLD / NEUTRAL , plus the multi-timeframe context.")
tablePos  = input.string("Bottom Left", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpDB)
tableSize = input.string("Small", "Font Size",
     options=["Tiny","Small","Normal","Large"], group=grpDB)
themeMode = input.string("Auto", "Theme",
     options=["Auto","Dark","Light","Glass"], group=grpDB,
     tooltip="Auto = follow chart background. Glass = semi-transparent overlay.")

// ─────────────────────────────────────────────────────────────
// 📈  R S I   C A L C U L A T I O N S
// ─────────────────────────────────────────────────────────────

calcRSI(tf) =>
    request.security(syminfo.tickerid, tf, ta.rsi(rsiSource, rsiLength),
         lookahead=barmerge.lookahead_off)

// Only the unlocked (higher) timeframes are fetched in the FREE version
rsiD  = calcRSI("D")
rsi4H = calcRSI("240")
rsi2H = calcRSI("120")
rsi1H = calcRSI("60")
rsi30 = calcRSI("30")
// 15m / 10m / 5m / 3m / 1m are 🔒 PRO , not fetched here.

// User-selectable TFs for chart lines (restricted to 30m+)
rsiPlot1 = tf1_enabled ? calcRSI(tf1) : na
rsiPlot2 = tf2_enabled ? calcRSI(tf2) : na
rsiPlot3 = tf3_enabled ? calcRSI(tf3) : na

// ─────────────────────────────────────────────────────────────
// 🚦  T R E N D   D E T E C T I O N
// ─────────────────────────────────────────────────────────────

isBullish(v) => not na(v) and v > midLevel
isBearish(v) => not na(v) and v < midLevel

bull1 = isBullish(rsiPlot1)
bull2 = isBullish(rsiPlot2)
bull3 = isBullish(rsiPlot3)
bear1 = isBearish(rsiPlot1)
bear2 = isBearish(rsiPlot2)
bear3 = isBearish(rsiPlot3)

activeTFs     = (tf1_enabled ? 1 : 0) + (tf2_enabled ? 1 : 0) + (tf3_enabled ? 1 : 0)
bullCount     = (bull1 ? 1 : 0) + (bull2 ? 1 : 0) + (bull3 ? 1 : 0)
bearCount     = (bear1 ? 1 : 0) + (bear2 ? 1 : 0) + (bear3 ? 1 : 0)
requiredCount = signalMode == "All 3 TF Agree" ? activeTFs : math.max(2, activeTFs - 1)

trendBull = bullCount >= requiredCount and activeTFs >= 2
trendBear = bearCount >= requiredCount and activeTFs >= 2

bullSignal = trendBull and not trendBull[1]
bearSignal = trendBear and not trendBear[1]

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
// 📊  P L O T S
// ─────────────────────────────────────────────────────────────

hOB  = hline(obLevel,  "Overbought", color=color.new(color.red,   60), linestyle=hline.style_dashed)
hOS  = hline(osLevel,  "Oversold",   color=color.new(color.green, 60), linestyle=hline.style_dashed)
hMid = hline(midLevel, "Middle",     color=color.new(color.gray,  70), linestyle=hline.style_dotted)
fill(hOB, hOS, color=color.new(color.purple, 95), title="Zone Background")

plot(rsiPlot1, "RSI TF1", color=tf1_enabled ? col_tf1 : na, linewidth=lineWidth1)
plot(rsiPlot2, "RSI TF2", color=tf2_enabled ? col_tf2 : na, linewidth=lineWidth2)
plot(rsiPlot3, "RSI TF3", color=tf3_enabled ? col_tf3 : na, linewidth=lineWidth3)

// ─────────────────────────────────────────────────────────────
// 🔺🔻  S I G N A L S
// ─────────────────────────────────────────────────────────────

plotshape(showSignals and bullSignal ? osLevel - 5 : na,
     title="Bullish Signal", style=shape.triangleup,
     location=location.absolute, color=color.new(#22c55e, 0),
     size=size.normal, text="BULL ▲")

plotshape(showSignals and bearSignal ? obLevel + 5 : na,
     title="Bearish Signal", style=shape.triangledown,
     location=location.absolute, color=color.new(#ef4444, 0),
     size=size.normal, text="BEAR ▼")

// ─────────────────────────────────────────────────────────────
// 🎨  B A C K G R O U N D
// ─────────────────────────────────────────────────────────────

bgColor = showBgHighlight ?
     (trendBull ? color.new(#22c55e, 88) :
      trendBear ? color.new(#ef4444, 88) : na) : na
bgcolor(bgColor, title="Trend Background")

// ═════════════════════════════════════════════════════════════
// 📋  DECISION DASHBOARD
//    Row 0 = VERDICT · Row 1 = Why · Rows 2-4 = TF grid
//    FREE: D / 4H / 2H / 1H / 30m unlocked · 15m and below 🔒 PRO
// ═════════════════════════════════════════════════════════════

// ── Verdict (current bar) ───────────────────────────────────
rsiNow = ta.rsi(rsiSource, rsiLength)
nowOB  = not na(rsiNow) and rsiNow >= obLevel
nowOS  = not na(rsiNow) and rsiNow <= osLevel
nowBull = not na(rsiNow) and rsiNow > midLevel

verdictTxt = ","
verdictTx  = TBL_TEXTDIM
verdictBg  = TBL_BG_ALT
reasonTxt  = ""

if trendBull and nowOB
    verdictTxt := "▲ BULL OVERBOUGHT"
    verdictTx  := TBL_WARN
    verdictBg  := color.new(#f59e0b, 70)
    reasonTxt  := "All TFs bullish but RSI ≥ " + str.tostring(obLevel) + " , pullback risk"
else if trendBear and nowOS
    verdictTxt := "▼ BEAR OVERSOLD"
    verdictTx  := TBL_WARN
    verdictBg  := color.new(#f59e0b, 70)
    reasonTxt  := "All TFs bearish but RSI ≤ " + str.tostring(osLevel) + " , bounce risk"
else if trendBull
    verdictTxt := "▲ BULL CONFLUENCE"
    verdictTx  := TBL_BULL
    verdictBg  := color.new(#22c55e, 70)
    reasonTxt  := str.tostring(bullCount) + "/" + str.tostring(activeTFs) + " TFs bullish , momentum aligned"
else if trendBear
    verdictTxt := "▼ BEAR CONFLUENCE"
    verdictTx  := TBL_BEAR
    verdictBg  := color.new(#ef4444, 70)
    reasonTxt  := str.tostring(bearCount) + "/" + str.tostring(activeTFs) + " TFs bearish , momentum aligned"
else if nowOB
    verdictTxt := "⚠ OVERBOUGHT"
    verdictTx  := TBL_WARN
    verdictBg  := color.new(#f59e0b, 70)
    reasonTxt  := "RSI " + str.tostring(math.round(rsiNow, 1)) + " ≥ " + str.tostring(obLevel) + " , caution longs"
else if nowOS
    verdictTxt := "⚠ OVERSOLD"
    verdictTx  := TBL_WARN
    verdictBg  := color.new(#f59e0b, 70)
    reasonTxt  := "RSI " + str.tostring(math.round(rsiNow, 1)) + " ≤ " + str.tostring(osLevel) + " , bounce possible"
else
    verdictTxt := "◇ NEUTRAL"
    verdictTx  := TBL_TEXTDIM
    verdictBg  := TBL_BG_ALT
    reasonTxt  := "Mixed RSI , no confluence, wait"

if barstate.islast and showTable
    var tbl = table.new(getPos(tablePos), 10, 5,
         bgcolor=TBL_BG,
         border_width=1,
         border_color=TBL_BORDER,
         frame_width=2,
         frame_color=TBL_BORDER)

    tblSize = getSize(tableSize)

    // Row 1: Verdict
    table.merge_cells(tbl, 0, 0, 9, 0)
    table.cell(tbl, 0, 0, verdictTxt, text_color=verdictTx, bgcolor=verdictBg, text_size=tblSize, text_halign=text.align_center)

    // Row 2: Why
    table.merge_cells(tbl, 0, 1, 9, 1)
    table.cell(tbl, 0, 1, reasonTxt,  text_color=TBL_TEXT,  bgcolor=TBL_BG_ALT, text_size=tblSize, text_halign=text.align_center)

    // Rows 3-5: TF grid (5 unlocked + 5 locked)
    tfLabels = array.from("D",   "4H",  "2H",  "1H", "30m", "15m", "10m", "5m", "3m", "1m")
    rsiVals  = array.from(rsiD,  rsi4H, rsi2H, rsi1H, rsi30)

    for i = 0 to 9
        lbl = array.get(tfLabels, i)
        isLocked = i >= 5  // 15m, 10m, 5m, 3m, 1m

        if isLocked
            table.cell(tbl, i, 2, lbl,   text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 3, "🔒",  text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 4, "",    text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
        else
            rv  = array.get(rsiVals, i)

            bull   = not na(rv) and rv > midLevel

            cellBg     = bull ? color.new(#22c55e, 70) : color.new(#ef4444, 70)

            rsiCol     = bull ? TBL_BULL : TBL_BEAR

            arrowCol   = bull  ? TBL_BULL : TBL_BEAR

            rsiStr     = na(rv) ? "," : str.tostring(math.round(rv, 1))
            arrow      = na(rv) ? "," : rv > midLevel ? "▲" : "▼"

            table.cell(tbl, i, 2, lbl,    text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 3, rsiStr, text_color=rsiCol,      text_size=tblSize, bgcolor=cellBg,     text_halign=text.align_center)
            table.cell(tbl, i, 4, arrow,  text_color=arrowCol,    text_size=tblSize, bgcolor=TBL_BG,     text_halign=text.align_center)

// (Branding watermark removed)
````
