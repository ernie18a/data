# Volume Pulse FREE , Momentum Divergence Spike Detection //BPS

- url: https://www.tradingview.com/script/M2oX90VD/
- type: indicator
- pine_id: PUB;68618d96984c4dbf8a670abec5cc4582
- version: 2.0

## Description

Volume oscillator with spike detection, momentum line and automatic
bullish/bearish divergence markers — to confirm price action with
real volume flow.

📊 WHAT IT SHOWS
• Volume momentum oscillator (cumulative signed volume)
• Spike markers when volume exceeds the average by your multiplier
• Pivot-based bullish & bearish divergence labels (price vs volume)
• Trend-band overlay showing volume-flow direction
• 10-timeframe momentum dashboard

🎯 HOW TO USE
• High-volume breakout = confirmed move · low-volume breakout = likely fail
• Bearish divergence at highs = potential reversal short
• Bullish divergence at lows = potential reversal long
• Volume spike on reversal candle = strong setup
• On Forex, volume = broker-only — use as bias, not main signal

🔑 KEYWORDS
Volume, Volume Oscillator, Volume Momentum, Volume Divergence,
Volume Spike, On Balance Volume, OBV, Volume Profile, Volume
Analysis, Smart Money Volume, Accumulation Distribution

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// 🚀  Volume Pulse FREE , Momentum Divergence Spike Detection //BPS 
// ═══════════════════════════════════════════════════════════════════
//
// ──── COPY-PASTE FOR TRADINGVIEW DESCRIPTION ────────────────────────
//
// FREE version of the BPS Volume Pulse. Volume oscillator with spike
// detection, momentum line and automatic bullish/bearish divergence
// markers. The higher timeframes (D / 4H / 2H / 1H / 30m) of the
// momentum dashboard are free; the faster ones (15m / 10m / 5m / 3m /
// 1m) are 🔒 PRO.
//
// 📊 WHAT IT SHOWS
//   • Volume momentum oscillator (cumulative signed volume)
//   • Spike markers when volume exceeds the average by your multiplier
//   • Pivot-based bullish & bearish divergence labels (price vs volume)
//   • Trend-band overlay showing volume-flow direction
//   • Multi-timeframe momentum dashboard (D → 30m · 15m and below 🔒 PRO)
//
// 🎯 HOW TO USE
//   • High-volume breakout = confirmed move · low-volume breakout = likely fail
//   • Bearish divergence at highs = potential reversal short
//   • Bullish divergence at lows = potential reversal long
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
indicator("Volume Pulse FREE , Momentum Divergence Spike Detection //BPS - bestpinescripts.com",
     shorttitle="Volume FREE //BPS",
     overlay=false,
     precision=2)

// ─────────────────────────────────────────────────────────────
// ⭐  BPS , Info & Pro Upgrade   (shown at top of settings)
// ─────────────────────────────────────────────────────────────
grp_bps_promo = "⭐ BestPineScripts.com"
_bps_promo    = input.bool(true,
     "FREE version , unlock 15m / 10m / 5m / 3m / 1m + 13 PRO indicators at bestpinescripts.com",
     group=grp_bps_promo,
     tooltip="This is the FREE Volume Pulse. The momentum dashboard shows D / 4H / 2H / 1H / 30m. The 5 faster timeframes (15m → 1m) are 🔒 PRO.\n\nUpgrade for full multi-TF + Auto Chart Pattern V2 (14 patterns, alerts & DD-tracking).\n\n→ bestpinescripts.com")

// ─────────────────────────────────────────────────────────────
// 🔧  S E T T I N G S
// ─────────────────────────────────────────────────────────────

grp_vol = "📊 Volume Engine"
volWindow  = input.int(28, "Volatility Window", minval=5, maxval=100, group=grp_vol,
     tooltip="Lookback for price spread normalization")
volSmooth  = input.int(14, "Volume Smoothing",  minval=2, maxval=50,  group=grp_vol)
obvSmooth  = input.int(1,  "OBV Smoothing",     minval=1, maxval=20,  group=grp_vol)

grp_ma = "📈 Fast MA"
maType   = input.string("DEMA", "MA Type", group=grp_ma,
     options=["EMA","DEMA","TEMA","HMA","ZLEMA","ZLDEMA","ZLTEMA","DZLEMA","WMA"])
maLength = input.int(9, "MA Length", minval=2, maxval=100, group=grp_ma)

grp_slow = "📉 Slow Baseline"
slowLength = input.int(26, "Slow EMA Length", minval=5, maxval=200, group=grp_slow)

grp_signal = "🚦 Signal & Trend"
regLen      = input.int(2, "Regression Length", minval=1, maxval=20, group=grp_signal,
     tooltip="Linear regression smoothing for the momentum line")
trendSens   = input.float(1.0, "Trend Sensitivity", minval=0.1, maxval=5.0, step=0.1,
     group=grp_signal, tooltip="Multiplier for adaptive channel , higher = less sensitive")
showCrosses = input.bool(false, "Show Cross Signals", group=grp_signal)

grp_div = "🔄 Divergence Detection"
showDivots = input.bool(true, "Show Pivot Points",  group=grp_div)
divPeriod  = input.int(50,  "Lookback Period",      minval=10, maxval=200, group=grp_div)

grp_style = "🎨 Colors"
colBull = input.color(color.new(#0d6efd, 0), "Bullish", group=grp_style, inline="c")
colBear = input.color(color.new(#ef4444, 0), "Bearish", group=grp_style, inline="c")

// ── Dashboard & Display ──────────────────────────────────────
grpDB = "📋 Dashboard & Display"
showTable = input.bool(true, "Show Decision Dashboard", group=grpDB,
     tooltip="One-glance verdict: VOL SPIKE BULL/BEAR / DIVERGENCE / NORMAL , plus the multi-timeframe momentum context.")
tablePos  = input.string("Bottom Left", "Position",
     options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grpDB)
tableSize = input.string("Small", "Font Size",
     options=["Tiny","Small","Normal","Large"], group=grpDB)
themeMode = input.string("Auto", "Theme",
     options=["Auto","Dark","Light","Glass"], group=grpDB)

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
// 🛠️  M A   F U N C T I O N S
// ─────────────────────────────────────────────────────────────

calcDEMA(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    2 * e1 - e2

calcTEMA(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    3 * (e1 - e2) + e3

calcHMA(src, len) =>
    halfLen = math.max(math.round(len / 2), 1)
    sqrtLen = math.max(math.round(math.sqrt(len)), 1)
    ta.wma(2 * ta.wma(src, halfLen) - ta.wma(src, len), sqrtLen)

calcZLEMA(src, len) =>
    lag = math.round((len - 1) / 2)
    ta.ema(src + (src - nz(src[lag])), len)

calcZLDEMA(src, len) =>
    lag = math.round((len - 1) / 2)
    calcDEMA(src + (src - nz(src[lag])), len)

calcZLTEMA(src, len) =>
    lag = math.round((len - 1) / 2)
    calcTEMA(src + (src - nz(src[lag])), len)

calcDZLEMA(src, len) =>
    z1 = calcZLEMA(src, len)
    2 * z1 - calcZLEMA(z1, len)

getMA(src, len, typ) =>
    switch typ
        "EMA"    => ta.ema(src, len)
        "DEMA"   => calcDEMA(src, len)
        "TEMA"   => calcTEMA(src, len)
        "HMA"    => calcHMA(src, len)
        "ZLEMA"  => calcZLEMA(src, len)
        "ZLDEMA" => calcZLDEMA(src, len)
        "ZLTEMA" => calcZLTEMA(src, len)
        "DZLEMA" => calcDZLEMA(src, len)
        "WMA"    => ta.wma(src, len)
        => calcDEMA(src, len)

// ─────────────────────────────────────────────────────────────
// 📊  C O R E   M O M E N T U M   F U N C T I O N  (multi-TF)
// ─────────────────────────────────────────────────────────────

calcMomentum() =>
    sv          = ta.cum(math.sign(ta.change(close)) * volume)
    vma         = ta.sma(sv, volSmooth)
    pSpread     = ta.stdev(high - low, volWindow)
    vSpread     = ta.stdev(sv - vma, volWindow)
    shad        = vSpread != 0 ? (sv - vma) / vSpread * pSpread : 0.0
    proj        = shad > 0 ? high + shad : low + shad
    obvL        = ta.ema(proj, obvSmooth)
    fast        = getMA(obvL, maLength, maType)
    slow        = ta.ema(close, slowLength)
    mom         = fast - slow
    reg         = ta.linreg(mom, math.max(regLen, 2), 0)
    dir         = reg > 0 ? 1 : -1
    [reg, dir]

// Only the unlocked (higher) timeframes are fetched in the FREE version
[regD,   dirD]   = request.security(syminfo.tickerid, "D",   calcMomentum(), lookahead=barmerge.lookahead_off)
[reg4H,  dir4H]  = request.security(syminfo.tickerid, "240", calcMomentum(), lookahead=barmerge.lookahead_off)
[reg2H,  dir2H]  = request.security(syminfo.tickerid, "120", calcMomentum(), lookahead=barmerge.lookahead_off)
[reg1H,  dir1H]  = request.security(syminfo.tickerid, "60",  calcMomentum(), lookahead=barmerge.lookahead_off)
[reg30,  dir30]  = request.security(syminfo.tickerid, "30",  calcMomentum(), lookahead=barmerge.lookahead_off)
// 15m / 10m / 5m / 3m / 1m are 🔒 PRO , not fetched here.

// ─────────────────────────────────────────────────────────────
// 📊  V O L U M E   M O M E N T U M   E N G I N E  (chart)
// ─────────────────────────────────────────────────────────────

signedVol   = ta.cum(math.sign(ta.change(close)) * volume)
volMA       = ta.sma(signedVol, volSmooth)
priceSpread = ta.stdev(high - low, volWindow)
volSpread   = ta.stdev(signedVol - volMA, volWindow)

shadow    = volSpread != 0 ? (signedVol - volMA) / volSpread * priceSpread : 0.0
projected = shadow > 0 ? high + shadow : low + shadow
obvLine   = ta.ema(projected, obvSmooth)

fastLine = getMA(obvLine, maLength, maType)
slowLine = ta.ema(close, slowLength)
momentum = fastLine - slowLine

// ─────────────────────────────────────────────────────────────
// 📐  L I N E A R   R E G R E S S I O N
// ─────────────────────────────────────────────────────────────

calcLinReg(src, len) =>
    sumX  = 0.0
    sumY  = 0.0
    sumXY = 0.0
    sumX2 = 0.0
    for idx = 0 to len - 1
        xVal  = float(idx + 1)
        yVal  = nz(src[len - 1 - idx])
        sumX  += xVal
        sumY  += yVal
        sumXY += xVal * yVal
        sumX2 += xVal * xVal
    slope     = (len * sumXY - sumX * sumY) / (len * sumX2 - sumX * sumX)
    intercept = sumY / len - slope * sumX / len + slope
    intercept + slope * len

regLine = calcLinReg(momentum, regLen)

// ─────────────────────────────────────────────────────────────
// 🔀  A D A P T I V E   T R E N D   C H A N N E L
// ─────────────────────────────────────────────────────────────

var float trendBand = 0.0
var int   trendDir  = 0

cumN   = ta.cum(1.0) - 1
avgDev = cumN > 0 ?
     ta.cum(math.abs(regLine - nz(trendBand[1], regLine))) / cumN * trendSens : 0.0

trendBand := regLine > nz(trendBand[1], regLine) + avgDev ? regLine :
             regLine < nz(trendBand[1], regLine) - avgDev ? regLine :
             nz(trendBand[1], regLine)

trendDir  := ta.change(trendBand) > 0 ? 1 :
             ta.change(trendBand) < 0 ? -1 : nz(trendDir[1])

trendCol = trendDir == 1 ? colBull : colBear

// ─────────────────────────────────────────────────────────────
// 🔄  P I V O T   D E T E C T I O N
// ─────────────────────────────────────────────────────────────

hBars = ta.highestbars(regLine, divPeriod)
lBars = ta.lowestbars(regLine,  divPeriod)

var float pivHigh = na
var float pivLow  = na

pivHigh := hBars == 0 ? regLine : nz(pivHigh[1], regLine)
pivLow  := lBars == 0 ? regLine : nz(pivLow[1],  regLine)

if regLine > pivHigh
    pivHigh := regLine
if regLine < pivLow
    pivLow := regLine

isPivotH = pivHigh == pivHigh[2] and pivHigh[2] != pivHigh[3]
isPivotL = pivLow  == pivLow[2]  and pivLow[2]  != pivLow[3]

// ─────────────────────────────────────────────────────────────
// 📊  P L O T S
// ─────────────────────────────────────────────────────────────

hline(0, "Zero", color=color.new(color.gray, 50), linewidth=2)
plot(trendBand, "Trend Band", color=trendCol, linewidth=4)

bullFlip = ta.change(trendDir) > 0
bearFlip = ta.change(trendDir) < 0

plotshape(showCrosses and bullFlip ? regLine : na,
     title="Bullish Flip", style=shape.cross,
     location=location.absolute, color=colBull, size=size.small)

plotshape(showCrosses and bearFlip ? regLine : na,
     title="Bearish Flip", style=shape.cross,
     location=location.absolute, color=colBear, size=size.small)

plotshape(showDivots and isPivotH ? pivHigh + 2 : na,
     title="Pivot High", style=shape.labeldown,
     location=location.absolute, color=colBear, size=size.tiny,
     text="P", textcolor=color.white)

plotshape(showDivots and isPivotL ? pivLow - 2 : na,
     title="Pivot Low", style=shape.labelup,
     location=location.absolute, color=colBull, size=size.tiny,
     text="P", textcolor=color.white)

// ═════════════════════════════════════════════════════════════
// 📋  DECISION DASHBOARD
//    FREE: D / 4H / 2H / 1H / 30m unlocked · 15m and below 🔒 PRO
// ═════════════════════════════════════════════════════════════

// ── Verdict computation ─────────────────────────────────────
bullTFs = (dirD == 1 ? 1 : 0) + (dir4H == 1 ? 1 : 0) + (dir1H == 1 ? 1 : 0) + (dir30 == 1 ? 1 : 0)
bearTFs = (dirD == -1 ? 1 : 0) + (dir4H == -1 ? 1 : 0) + (dir1H == -1 ? 1 : 0) + (dir30 == -1 ? 1 : 0)
isRecentBullDiv = isPivotL and regLine < nz(pivLow[1], regLine)
isRecentBearDiv = isPivotH and regLine > nz(pivHigh[1], regLine)
hasVolumeSpike  = volume > ta.sma(volume, 20) * 2

verdictTxt = ","
verdictTx  = TBL_TEXTDIM
verdictBg  = TBL_BG_ALT
reasonTxt  = ""

if isRecentBearDiv and trendDir == 1
    verdictTxt := "⚠ BEAR DIVERGENCE"
    verdictTx  := color.new(#f0f3f8, 0)
    verdictBg  := color.new(#f59e0b, 20)
    reasonTxt  := "Price up but volume momentum down , reversal warning"
else if isRecentBullDiv and trendDir == -1
    verdictTxt := "⚠ BULL DIVERGENCE"
    verdictTx  := color.new(#f0f3f8, 0)
    verdictBg  := color.new(#f59e0b, 20)
    reasonTxt  := "Price down but volume momentum up , bottom warning"
else if hasVolumeSpike and trendDir == 1
    verdictTxt := "▲ VOL SPIKE BULL"
    verdictTx  := color.new(#f0f3f8, 0)
    verdictBg  := color.new(#22c55e, 20)
    reasonTxt  := "Volume " + str.tostring(math.round(volume / ta.sma(volume,20),1)) + "× avg with bullish momentum"
else if hasVolumeSpike and trendDir == -1
    verdictTxt := "▼ VOL SPIKE BEAR"
    verdictTx  := color.new(#f0f3f8, 0)
    verdictBg  := color.new(#ef4444, 20)
    reasonTxt  := "Volume " + str.tostring(math.round(volume / ta.sma(volume,20),1)) + "× avg with bearish momentum"
else if bullTFs >= 3
    verdictTxt := "▲ STRONG BULL FLOW"
    verdictTx  := TBL_BULL
    verdictBg  := color.new(#22c55e, 70)
    reasonTxt  := str.tostring(bullTFs) + "/4 HTFs (D,4H,1H,30m) bullish volume momentum"
else if bearTFs >= 3
    verdictTxt := "▼ STRONG BEAR FLOW"
    verdictTx  := TBL_BEAR
    verdictBg  := color.new(#ef4444, 70)
    reasonTxt  := str.tostring(bearTFs) + "/4 HTFs (D,4H,1H,30m) bearish volume momentum"
else
    verdictTxt := "◇ NORMAL"
    verdictTx  := TBL_TEXTDIM
    verdictBg  := TBL_BG_ALT
    reasonTxt  := "No spike, no divergence, no MTF flow alignment , wait"

if barstate.islast and showTable
    var tbl = table.new(getPos(tablePos), 10, 5,
         bgcolor=TBL_BG, border_width=1, border_color=TBL_BORDER,
         frame_width=2, frame_color=TBL_BORDER)

    tblSize = getSize(tableSize)

    // Row 1: Verdict
    table.merge_cells(tbl, 0, 0, 9, 0)
    table.cell(tbl, 0, 0, verdictTxt, text_color=verdictTx, bgcolor=verdictBg, text_size=tblSize, text_halign=text.align_center)

    // Row 2: Why
    table.merge_cells(tbl, 0, 1, 9, 1)
    table.cell(tbl, 0, 1, reasonTxt, text_color=TBL_TEXT, bgcolor=TBL_BG_ALT, text_size=tblSize, text_halign=text.align_center)

    // Rows 3-5: TF momentum grid (5 unlocked + 5 locked)
    tfLabels = array.from("D",   "4H",  "2H",  "1H", "30m","15m","10m","5m","3m","1m")
    regVals  = array.from(regD,  reg4H, reg2H, reg1H, reg30)
    dirVals  = array.from(dirD,  dir4H, dir2H, dir1H, dir30)

    for i = 0 to 9
        lbl = array.get(tfLabels, i)
        isLocked = i >= 5  // 15m, 10m, 5m, 3m, 1m

        if isLocked
            table.cell(tbl, i, 2, lbl,   text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 3, "🔒",  text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 4, "",    text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
        else
            rv  = array.get(regVals, i)
            dv  = array.get(dirVals, i)

            isBull = dv == 1
            cellBg = isBull ? color.new(#22c55e, 70) : color.new(#ef4444, 70)
            valCol = isBull ? TBL_BULL : TBL_BEAR
            arrow  = na(rv) ? "," : isBull ? "▲" : "▼"
            valStr = na(rv) ? "," : str.tostring(math.round(rv, 1))

            table.cell(tbl, i, 2, lbl,    text_color=TBL_TEXTDIM, text_size=tblSize, bgcolor=TBL_BG_ALT, text_halign=text.align_center)
            table.cell(tbl, i, 3, valStr, text_color=valCol,      text_size=tblSize, bgcolor=cellBg,     text_halign=text.align_center)
            table.cell(tbl, i, 4, arrow,  text_color=valCol,      text_size=tblSize, bgcolor=TBL_BG,     text_halign=text.align_center)

// (Branding watermark removed)
````
