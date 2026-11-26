# Key Levels MTF

- url: https://www.tradingview.com/script/nNOOdvMS-Key-Levels-MTF/
- type: indicator
- pine_id: PUB;ce0e1fe29c3b46d7b4b91bcb81f4da37
- version: 2.0

## Description

Key Levels MTF — one indicator for every level that matters
Key Levels MTF collapses a whole toolbox of support/resistance methods into a single, clean overlay. Instead of stacking ten indicators on your chart, it computes every level across 10 timeframes at once, draws only the ones near current price, and merges overlapping levels into a single "confluence" line so you instantly see where the market is really defending.

One indicator. No clutter. Just the levels price actually cares about right now.

What it draws
Every module is multi-timeframe and toggles independently:

Value Area — POC / VAH / VAL from a volume-by-price profile.
Murrey Math — ±1/8 and ±2/8 reversal extremes.
Target Trend — active SL and unhit T1/T2/T3 targets, with direction.
Exhaustion Levels — S/R printed by exhaustion (leledc) bars.
Fib Retracement — 0.5 / 0.618 / 0.786 zone from each TF's swing.
Supertrend — current trailing-stop value per TF.
Period Levels (FBD) — prior Daily/Weekly/Monthly/Quarterly highs & lows.
SMAs — up to four per TF.
What makes it different
🎯 Proximity filter — levels only draw when they're within an ATR band of price, so you never see a monthly line 40% away.
🔗 Confluence merge — nearby levels collapse into one ×N line; hover for the full breakdown.
🧭 Bias Zone — a single 0.5/0.618 "line in the sand" from a TF you choose (default 4H): above the 0.618 stay bullish, below stay bearish, with a bias-flip alert.

Alerts
Price near any key level (+ per-category), and Bias turned bullish/bearish on the 0.618 cross.

Credits
BigBeluga (Target Trend) · Nanda86 (Murrey Math Lines) · InSilico (Leledc exhaustion).

## Source Code

````pine
//@version=6
indicator("Key Levels MTF", overlay=true, max_lines_count=500, max_labels_count=500)

import TradeCandD/lib_murrey/1 as murrey
import TradeCandD/lib_trend_mode/1 as trend
import TradeCandD/lib_failed_breakdown/1 as lel  // leledc exhaustion (powers Exhaustion Levels)

// ============================================================
// TF Configuration — 12M / 6M / 3M / 1M / 1W / 1D / 4H / 2H / 1H / 15m
// ============================================================
tf1On    = input.bool(true,  "Enabled",   group="TF 1", inline="tf1")
tf1      = input.timeframe("12M", "TF",   group="TF 1", inline="tf1")

tf2On    = input.bool(true,  "Enabled",   group="TF 2", inline="tf2")
tf2      = input.timeframe("6M",  "TF",   group="TF 2", inline="tf2")

tf3On    = input.bool(true,  "Enabled",   group="TF 3", inline="tf3")
tf3      = input.timeframe("3M",  "TF",   group="TF 3", inline="tf3")

tf4On    = input.bool(true,  "Enabled",   group="TF 4", inline="tf4")
tf4      = input.timeframe("M",   "TF",   group="TF 4", inline="tf4")

tf5On    = input.bool(true,  "Enabled",   group="TF 5", inline="tf5")
tf5      = input.timeframe("W",   "TF",   group="TF 5", inline="tf5")

tf6On    = input.bool(true,  "Enabled",   group="TF 6", inline="tf6")
tf6      = input.timeframe("D",   "TF",   group="TF 6", inline="tf6")

tf7On    = input.bool(true,  "Enabled",   group="TF 7", inline="tf7")
tf7      = input.timeframe("240", "TF",   group="TF 7", inline="tf7")

tf8On    = input.bool(true,  "Enabled",   group="TF 8", inline="tf8")
tf8      = input.timeframe("120", "TF",   group="TF 8", inline="tf8")

tf9On    = input.bool(true,  "Enabled",   group="TF 9", inline="tf9")
tf9      = input.timeframe("60",  "TF",   group="TF 9", inline="tf9")

tf10On   = input.bool(false, "Enabled",   group="TF 10", inline="tf10")
tf10     = input.timeframe("15",  "TF",   group="TF 10", inline="tf10")

// ============================================================
// Proximity Filter (own ATR config)
// ============================================================
proxTf     = input.timeframe("D", "ATR timeframe",              group="Proximity Filter")
proxAtrLen = input.int(14, "ATR length",                        group="Proximity Filter")
proxMult   = input.float(4.0, "ATR multiplier (draw within)",   minval=0.5, maxval=10.0, step=0.5, group="Proximity Filter")

// ============================================================
// Style (single color for everything)
// ============================================================
lineColor  = input.color(color.new(color.gray, 20), "Line color",       group="Style")
lineStyle  = input.string("Solid", "Line style", options=["Solid", "Dashed", "Dotted"], group="Style")
lblBgColor = input.color(color.new(#1E222D, 10), "Label background", group="Style")
lblTxColor = input.color(#D1D4DC,                "Label text",       group="Style")
lblSizeIn  = input.string("Normal", "Label size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Style")
lineWidth  = input.int(1, "Line width", minval=1, maxval=4, group="Style",
             tooltip="Base thickness for all levels. Merged confluence lines get progressively bolder above this.")
lineGap    = input.int(3, "Line gap from price (bars)", minval=0, maxval=50, group="Style",
             tooltip="Start the level lines this many bars to the right of the current candle so they don't crowd recent price action.")

// ============================================================
// Value Area
// ============================================================
vaOn       = input.bool(false, "Enable",                         group="Value Area")
lookback   = input.int(300,   "Lookback bars (per TF)",         minval=50,  maxval=2000, group="Value Area")
numBins    = input.int(100,   "Resolution",                     minval=30,  maxval=300,  group="Value Area")
valuePct   = input.float(70,  "Value area %",                   minval=30,  maxval=95, step=5, group="Value Area")
showVALabels = input.bool(true, "Labels",                       group="Value Area")

// ============================================================
// Murrey Math
// ============================================================
mOn        = input.bool(true,  "Enable",                        group="Murrey Math")
mFrame     = input.int(64,     "Frame",                          minval=2, maxval=256, group="Murrey Math")
mMult      = input.float(1.5,  "Multiplier",                    minval=0.5, maxval=5.0, step=0.5, group="Murrey Math")
showMLabels = input.bool(true, "Labels",                        group="Murrey Math")

// ============================================================
// Target Trend
// ============================================================
tOn        = input.bool(true,  "Enable",                        group="Target Trend")
tLen       = input.int(10,     "Trend length",                   minval=5, maxval=20, group="Target Trend")
tTgt       = input.int(0,      "Target offset",                  minval=0, maxval=10, group="Target Trend")
showTLabels = input.bool(true, "Labels",                        group="Target Trend")

// ============================================================
// Exhaustion Levels
// ============================================================
exOn        = input.bool(true,  "Enable",                       group="Exhaustion Levels")
exSwingLen  = input.int(40,     "Swing length",                  minval=5, maxval=200, group="Exhaustion Levels")
exBars      = input.int(10,     "Exhaustion bar count",          minval=1, maxval=50, group="Exhaustion Levels")
exLastN     = input.int(3,      "Show last N levels (per side)", minval=1, maxval=10, group="Exhaustion Levels")
showELabels = input.bool(true,  "Labels",                       group="Exhaustion Levels")

// ============================================================
// Fib Retracement (per TF swing)
// ============================================================
fibOn           = input.bool(true,  "Enable",                     group="Fib Retracement")
fibLb           = input.int(100,     "Swing lookback",             minval=5, maxval=500, group="Fib Retracement")
fibRequireTrend = input.bool(false, "Require uptrend structure",  group="Fib Retracement",
                  tooltip="When on, levels are hidden unless the swing high is more recent than the swing low.")
fibShow786      = input.bool(true,  "Show 0.786 (stop)",          group="Fib Retracement")
showFibLabels   = input.bool(true,  "Labels",                     group="Fib Retracement")

// ============================================================
// Supertrend (per TF)
// ============================================================
stOn         = input.bool(true,  "Enable",           group="Supertrend")
stFactor     = input.float(3.0,  "ATR multiplier",   minval=1.0, step=0.1, group="Supertrend")
stPd         = input.int(10,     "ATR period",       minval=1, maxval=100, group="Supertrend")
showSTLabels = input.bool(true,  "Labels",           group="Supertrend")

// ============================================================
// Bias Zone (line in the sand) — Fib 0.5 / 0.618 of one higher TF
// Hold above 0.618 = stay bullish; lose it = stay bearish.
// Always drawn (not proximity-filtered, not merged), in its own style.
// ============================================================
biasOn         = input.bool(true,    "Enable",         group="Bias Zone")
biasTf         = input.timeframe("1D","Timeframe",   group="Bias Zone",
                 tooltip="Anchor the zone to a higher TF so it rarely reshapes.")
biasLb         = input.int(100,       "Swing lookback", minval=5, maxval=500, group="Bias Zone")
biasColor      = input.color(color.blue, "Line color", group="Bias Zone")
biasStyle      = input.string("Solid", "Line style", options=["Solid", "Dashed", "Dotted"], group="Bias Zone")
biasWidth      = input.int(1,        "Line width",     minval=1, maxval=4, group="Bias Zone")
showBiasLabels = input.bool(true,    "Labels",         group="Bias Zone")

// ============================================================
// ATR Extremes — mean-reversion zones (basis ± mult × ATR)
// When price stretches this many ATRs from its mean it's an extreme:
// the upper line is a short zone, the lower line a buy zone.
// Always drawn (not proximity-filtered, not merged).
// ============================================================
atrExOn        = input.bool(true,  "Enable",                 group="ATR Extremes")
atrExTf        = input.timeframe("", "Timeframe",            group="ATR Extremes", tooltip="Blank = chart timeframe.")
atrExBasisLen  = input.int(50,     "Basis SMA length",       minval=1, maxval=500, group="ATR Extremes")
atrExAtrLen    = input.int(14,     "ATR length",             minval=1, maxval=100, group="ATR Extremes")
atrExMult      = input.float(7.0,  "ATR multiplier",         minval=0.5, maxval=20.0, step=0.5, group="ATR Extremes")
atrExUpColor   = input.color(color.red,   "Upper (short)", inline="atrexc", group="ATR Extremes")
atrExDnColor   = input.color(color.green, "Lower (buy)",   inline="atrexc", group="ATR Extremes")
atrExStyle     = input.string("Dashed", "Line style", options=["Solid", "Dashed", "Dotted"], group="ATR Extremes")
atrExWidth     = input.int(1,      "Line width",             minval=1, maxval=4, group="ATR Extremes")
atrExShowMid   = input.bool(false, "Show basis (mean) line", group="ATR Extremes")
showAtrExLabels = input.bool(true, "Labels",                 group="ATR Extremes")

// ============================================================
// Period Levels (FBD) — prior D/W/M/Q highs & lows
// A "failed breakdown" is just price flushing one of these prior-period
// extremes and holding above/below it, so the level itself is what matters.
// ============================================================
plOn         = input.bool(false, "Enable",                     group="Period Levels (FBD)")
plBars       = input.int(2,     "Last N periods",             minval=1, maxval=3, group="Period Levels (FBD)",
               tooltip="How many completed periods back to show, per period type. 2 = prior + one before it.")
plHi         = input.bool(true, "Show highs",  inline="plhl", group="Period Levels (FBD)")
plLo         = input.bool(true, "Show lows",   inline="plhl", group="Period Levels (FBD)")
plD          = input.bool(true, "Daily",       inline="plp1", group="Period Levels (FBD)")
plW          = input.bool(true, "Weekly",      inline="plp1", group="Period Levels (FBD)")
plM          = input.bool(true, "Monthly",     inline="plp2", group="Period Levels (FBD)")
plQ          = input.bool(true, "Quarterly",   inline="plp2", group="Period Levels (FBD)")
showPLLabels = input.bool(true, "Labels",                     group="Period Levels (FBD)")

// ============================================================
// SMAs
// ============================================================
smaOn      = input.bool(true,  "Enable",                        group="SMA")
sma1Len    = input.int(20,     "SMA 1 length",                  minval=1, maxval=500, group="SMA")
sma1On     = input.bool(true, "SMA 1 enabled",                 group="SMA")
sma2Len    = input.int(50,     "SMA 2 length",                  minval=1, maxval=500, group="SMA")
sma2On     = input.bool(false, "SMA 2 enabled",                 group="SMA")
sma3Len    = input.int(89,     "SMA 3 length",                  minval=1, maxval=500, group="SMA")
sma3On     = input.bool(false,  "SMA 3 enabled",                 group="SMA")
sma4Len    = input.int(200,    "SMA 4 length",                  minval=1, maxval=500, group="SMA")
sma4On     = input.bool(true,  "SMA 4 enabled",                 group="SMA")
showSLabels = input.bool(true, "Labels",                        group="SMA")

// ============================================================
// Confluence (merge nearby levels)
// ============================================================
confluenceOn = input.bool(true,  "Merge nearby levels into one line", group="Confluence",
               tooltip="When on, every level within the merge distance below collapses to a single line labelled with how many levels aligned (confluence).")
mergeMult    = input.float(0.2,  "Merge within (x ATR)",              minval=0.01, maxval=1.0, step=0.01, group="Confluence",
               tooltip="Levels closer than this (as a fraction of the proximity ATR) are treated as one. 0.1 = one tenth of an ATR.")

// ============================================================
// Alerts
// ============================================================
alertProxPct = input.float(0.15, "Alert proximity % of price",  minval=0.01, maxval=2.0, step=0.01, group="Alerts")

// ============================================================
// Helpers
// ============================================================
getLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

getLblSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

lblSize = getLblSize(lblSizeIn)

// Proximity ATR from its own TF
proxAtr = request.security(syminfo.tickerid, proxTf, ta.atr(proxAtrLen), lookahead=barmerge.lookahead_off)
float proxRange = proxAtr * proxMult
float priceMid = close

isNear(float lvl) =>
    not na(lvl) and math.abs(lvl - priceMid) <= proxRange

drawLine(float lvl, int width, string txt, bool showLbl, int lblOffset) =>
    if isNear(lvl)
        line.new(bar_index + lineGap, lvl, bar_index + lineGap + 1, lvl, color=lineColor, width=width,
             style=getLineStyle(lineStyle), extend=extend.right)
        if showLbl
            label.new(bar_index + lineGap + lblOffset, lvl, txt,
                 style=label.style_label_left, color=lblBgColor, textcolor=lblTxColor, size=lblSize)

// Alert proximity check (tighter than draw proximity, % based)
isAlertNear(float lvl) =>
    not na(lvl) and math.abs(lvl - close) <= close * alertProxPct * 0.01

// ------------------------------------------------------------
// Confluence collector — every level is routed through emit().
// In merge mode it is stashed here and clustered on the last bar;
// otherwise it is drawn immediately (original one-line-per-level).
// ------------------------------------------------------------
var float[]  cPx  = array.new_float()
var string[] cTag = array.new_string()
var int[]    cW   = array.new_int()

emit(float lvl, int width, string tag, bool showLbl, int lblOffset) =>
    // Merge mode: stash the level for clustering on the last bar
    if confluenceOn and isNear(lvl)
        array.push(cPx, lvl)
        array.push(cW, width)
        array.push(cTag, showLbl ? tag : "")
    // Direct mode: draw the level immediately (one line per level)
    if not confluenceOn
        drawLine(lvl, width, showLbl ? str.format("{0}  {1,number,#.##}", tag, lvl) : "", showLbl, lblOffset)

// Cluster all collected levels and draw one line per cluster.
drawConfluence() =>
    int n = array.size(cPx)
    if n > 0
        float mergeDist = proxAtr * mergeMult
        bool[] used = array.new_bool(n, false)
        for i = 0 to n - 1
            if not array.get(used, i)
                float seed = array.get(cPx, i)
                float sum  = 0.0
                int   cnt  = 0
                int   maxW = 1
                string tags = ""
                for j = i to n - 1
                    if not array.get(used, j) and math.abs(array.get(cPx, j) - seed) <= mergeDist
                        array.set(used, j, true)
                        sum  += array.get(cPx, j)
                        cnt  += 1
                        maxW := math.max(maxW, array.get(cW, j))
                        string tg = array.get(cTag, j)
                        if tg != ""
                            tags := tags + (tags == "" ? "" : "  •  ") + tg
                float mid = sum / cnt
                // Count conveys confluence — keep the line the base width (no bolding).
                // Merged clusters show a compact "xN  price"; the full tag list lives
                // in the tooltip (hover the label) so the chart stays clean.
                string txt = cnt > 1 ? str.format("x{0}  {1,number,#.##}", cnt, mid) :
                             (tags == "" ? "" : str.format("{0}  {1,number,#.##}", tags, mid))
                string tip = cnt > 1 ? tags : ""
                line.new(bar_index + lineGap, mid, bar_index + lineGap + 1, mid, color=lineColor, width=maxW,
                     style=getLineStyle(lineStyle), extend=extend.right)
                if txt != ""
                    label.new(bar_index + lineGap, mid, txt,
                         style=label.style_label_left, color=lblBgColor, textcolor=lblTxColor, size=lblSize, tooltip=tip)

// ============================================================
// Combined data fetch — ONE request.security per TF
// Murrey + Trend + Exhaustion + SMAs + VA + Fib + Supertrend
// ============================================================
getAllData() =>
    // Murrey
    [_e8, _f4, _z0, _zone, p18, m18, inc] = murrey.get_murrey_levels(mFrame, mMult)
    float p28 = p18 + inc
    float m28 = m18 - inc
    // Trend
    [tr, sl, entry, t1, t2, t3, t1h, t2h, t3h] = trend.get_trend_data(tLen, tTgt)
    // Exhaustion
    float exSig = float(lel.lelec(exBars, exSwingLen))
    // SMAs
    float sa1 = ta.sma(close, sma1Len)
    float sa2 = ta.sma(close, sma2Len)
    float sa3 = ta.sma(close, sma3Len)
    float sa4 = ta.sma(close, sma4Len)

    // Fib retracement from swing hi/lo over the lookback
    float fHi    = ta.highest(high, fibLb)
    float fLo    = ta.lowest(low, fibLb)
    float fHiOff = ta.highestbars(high, fibLb)
    float fLoOff = ta.lowestbars(low, fibLb)
    float fRng   = fHi - fLo
    bool  fTrendOK = not fibRequireTrend or fHiOff > fLoOff
    bool  fHas   = fRng > 0 and fTrendOK
    float f50    = fHas ? fHi - fRng * 0.5   : na
    float f618   = fHas ? fHi - fRng * 0.618 : na
    float f786   = fHas ? fHi - fRng * 0.786 : na

    // Supertrend — RMA-ATR default (matches source "Default SuperTrend=RMA")
    [stVal, stDir] = ta.supertrend(stFactor, stPd)

    // Completed bar data for VA
    float prevH = high[1]
    float prevL = low[1]
    float prevV = volume[1]
    [p18, p28, m18, m28, tr, sl, entry, t1, t2, t3, t1h, t2h, t3h, exSig, high, low, sa1, sa2, sa3, sa4, prevH, prevL, prevV, f50, f618, f786, stVal, stDir]

// TF 1
[m1p18, m1p28, m1m18, m1m28, tr1, sl1, en1, t1_1, t1_2, t1_3, t1h1, t1h2, t1h3, exSig1, exH1, exL1, sa1_1, sa2_1, sa3_1, sa4_1, vaH1, vaL1, vaV1, f50_1, f618_1, f786_1, stV1, stD1] = request.security(syminfo.tickerid, tf1, getAllData(), lookahead=barmerge.lookahead_off)
// TF 2
[m2p18, m2p28, m2m18, m2m28, tr2, sl2, en2, t2_1, t2_2, t2_3, t2h1, t2h2, t2h3, exSig2, exH2, exL2, sa1_2, sa2_2, sa3_2, sa4_2, vaH2, vaL2, vaV2, f50_2, f618_2, f786_2, stV2, stD2] = request.security(syminfo.tickerid, tf2, getAllData(), lookahead=barmerge.lookahead_off)
// TF 3
[m3p18, m3p28, m3m18, m3m28, tr3, sl3, en3, t3_1, t3_2, t3_3, t3h1, t3h2, t3h3, exSig3, exH3, exL3, sa1_3, sa2_3, sa3_3, sa4_3, vaH3, vaL3, vaV3, f50_3, f618_3, f786_3, stV3, stD3] = request.security(syminfo.tickerid, tf3, getAllData(), lookahead=barmerge.lookahead_off)
// TF 4
[m4p18, m4p28, m4m18, m4m28, tr4, sl4, en4, t4_1, t4_2, t4_3, t4h1, t4h2, t4h3, exSig4, exH4, exL4, sa1_4, sa2_4, sa3_4, sa4_4, vaH4, vaL4, vaV4, f50_4, f618_4, f786_4, stV4, stD4] = request.security(syminfo.tickerid, tf4, getAllData(), lookahead=barmerge.lookahead_off)
// TF 5
[m5p18, m5p28, m5m18, m5m28, tr5, sl5, en5, t5_1, t5_2, t5_3, t5h1, t5h2, t5h3, exSig5, exH5, exL5, sa1_5, sa2_5, sa3_5, sa4_5, vaH5, vaL5, vaV5, f50_5, f618_5, f786_5, stV5, stD5] = request.security(syminfo.tickerid, tf5, getAllData(), lookahead=barmerge.lookahead_off)
// TF 6
[m6p18, m6p28, m6m18, m6m28, tr6, sl6, en6, t6_1, t6_2, t6_3, t6h1, t6h2, t6h3, exSig6, exH6, exL6, sa1_6, sa2_6, sa3_6, sa4_6, vaH6, vaL6, vaV6, f50_6, f618_6, f786_6, stV6, stD6] = request.security(syminfo.tickerid, tf6, getAllData(), lookahead=barmerge.lookahead_off)
// TF 7
[m7p18, m7p28, m7m18, m7m28, tr7, sl7, en7, t7_1, t7_2, t7_3, t7h1, t7h2, t7h3, exSig7, exH7, exL7, sa1_7, sa2_7, sa3_7, sa4_7, vaH7, vaL7, vaV7, f50_7, f618_7, f786_7, stV7, stD7] = request.security(syminfo.tickerid, tf7, getAllData(), lookahead=barmerge.lookahead_off)
// TF 8
[m8p18, m8p28, m8m18, m8m28, tr8, sl8, en8, t8_1, t8_2, t8_3, t8h1, t8h2, t8h3, exSig8, exH8, exL8, sa1_8, sa2_8, sa3_8, sa4_8, vaH8, vaL8, vaV8, f50_8, f618_8, f786_8, stV8, stD8] = request.security(syminfo.tickerid, tf8, getAllData(), lookahead=barmerge.lookahead_off)
// TF 9
[m9p18, m9p28, m9m18, m9m28, tr9, sl9, en9, t9_1, t9_2, t9_3, t9h1, t9h2, t9h3, exSig9, exH9, exL9, sa1_9, sa2_9, sa3_9, sa4_9, vaH9, vaL9, vaV9, f50_9, f618_9, f786_9, stV9, stD9] = request.security(syminfo.tickerid, tf9, getAllData(), lookahead=barmerge.lookahead_off)
// TF 10
[m10p18, m10p28, m10m18, m10m28, tr10, sl10, en10, t10_1, t10_2, t10_3, t10h1, t10h2, t10h3, exSig10, exH10, exL10, sa1_10, sa2_10, sa3_10, sa4_10, vaH10, vaL10, vaV10, f50_10, f618_10, f786_10, stV10, stD10] = request.security(syminfo.tickerid, tf10, getAllData(), lookahead=barmerge.lookahead_off)

// ============================================================
// Period levels — prior D/W/M/Q highs & lows (plain history, reliable)
// high[1]/low[1] = the last completed period; [2]/[3] = further back.
// ============================================================
[pdH1, pdH2, pdH3, pdL1, pdL2, pdL3] = request.security(syminfo.tickerid, "D",  [high[1], high[2], high[3], low[1], low[2], low[3]], lookahead=barmerge.lookahead_off)
[pwH1, pwH2, pwH3, pwL1, pwL2, pwL3] = request.security(syminfo.tickerid, "W",  [high[1], high[2], high[3], low[1], low[2], low[3]], lookahead=barmerge.lookahead_off)
[pmH1, pmH2, pmH3, pmL1, pmL2, pmL3] = request.security(syminfo.tickerid, "M",  [high[1], high[2], high[3], low[1], low[2], low[3]], lookahead=barmerge.lookahead_off)
[pqH1, pqH2, pqH3, pqL1, pqL2, pqL3] = request.security(syminfo.tickerid, "3M", [high[1], high[2], high[3], low[1], low[2], low[3]], lookahead=barmerge.lookahead_off)

// ============================================================
// Bias zone — Fib 0.5 / 0.618 of the chosen TF (its own swing lookback)
// ============================================================
biasSwing() =>
    float bHi  = ta.highest(high, biasLb)
    float bLo  = ta.lowest(low, biasLb)
    float bRng = bHi - bLo
    float b50  = bRng > 0 ? bHi - bRng * 0.5   : na
    float b618 = bRng > 0 ? bHi - bRng * 0.618 : na
    [b50, b618]
[bias50, bias618] = request.security(syminfo.tickerid, biasTf, biasSwing(), lookahead=barmerge.lookahead_off)

// ============================================================
// ATR extremes — basis SMA ± multiplier × ATR on the chosen TF
// ============================================================
atrExData() =>
    [ta.sma(close, atrExBasisLen), ta.atr(atrExAtrLen)]
[atrBasis, atrVal] = request.security(syminfo.tickerid, atrExTf == "" ? timeframe.period : atrExTf, atrExData(), lookahead=barmerge.lookahead_off)
float atrUp = not na(atrBasis) and not na(atrVal) ? atrBasis + atrExMult * atrVal : na
float atrDn = not na(atrBasis) and not na(atrVal) ? atrBasis - atrExMult * atrVal : na

// ============================================================
// VA: Accumulate completed HTF bars into arrays
// ============================================================
var float[] h1H = array.new_float(), var float[] h1L = array.new_float(), var float[] h1V = array.new_float()
var float[] h2H = array.new_float(), var float[] h2L = array.new_float(), var float[] h2V = array.new_float()
var float[] h3H = array.new_float(), var float[] h3L = array.new_float(), var float[] h3V = array.new_float()
var float[] h4H = array.new_float(), var float[] h4L = array.new_float(), var float[] h4V = array.new_float()
var float[] h5H = array.new_float(), var float[] h5L = array.new_float(), var float[] h5V = array.new_float()
var float[] h6H = array.new_float(), var float[] h6L = array.new_float(), var float[] h6V = array.new_float()
var float[] h7H = array.new_float(), var float[] h7L = array.new_float(), var float[] h7V = array.new_float()
var float[] h8H = array.new_float(), var float[] h8L = array.new_float(), var float[] h8V = array.new_float()
var float[] h9H = array.new_float(), var float[] h9L = array.new_float(), var float[] h9V = array.new_float()
var float[] h10H = array.new_float(), var float[] h10L = array.new_float(), var float[] h10V = array.new_float()

accumulateVA(bool tfOn, string tf, float htfH, float htfL, float htfV, float[] aH, float[] aL, float[] aV) =>
    if tfOn and vaOn and ta.change(time(tf)) != 0 and not na(htfH)
        array.push(aH, htfH)
        array.push(aL, htfL)
        array.push(aV, htfV)
        if array.size(aH) > lookback
            array.shift(aH)
            array.shift(aL)
            array.shift(aV)

accumulateVA(tf1On,  tf1,  vaH1,  vaL1,  vaV1,  h1H,  h1L,  h1V)
accumulateVA(tf2On,  tf2,  vaH2,  vaL2,  vaV2,  h2H,  h2L,  h2V)
accumulateVA(tf3On,  tf3,  vaH3,  vaL3,  vaV3,  h3H,  h3L,  h3V)
accumulateVA(tf4On,  tf4,  vaH4,  vaL4,  vaV4,  h4H,  h4L,  h4V)
accumulateVA(tf5On,  tf5,  vaH5,  vaL5,  vaV5,  h5H,  h5L,  h5V)
accumulateVA(tf6On,  tf6,  vaH6,  vaL6,  vaV6,  h6H,  h6L,  h6V)
accumulateVA(tf7On,  tf7,  vaH7,  vaL7,  vaV7,  h7H,  h7L,  h7V)
accumulateVA(tf8On,  tf8,  vaH8,  vaL8,  vaV8,  h8H,  h8L,  h8V)
accumulateVA(tf9On,  tf9,  vaH9,  vaL9,  vaV9,  h9H,  h9L,  h9V)
accumulateVA(tf10On, tf10, vaH10, vaL10, vaV10, h10H, h10L, h10V)

// ============================================================
// Exhaustion: Accumulate levels into arrays
// ============================================================
var float[] ex1R = array.new_float(), var float[] ex1S = array.new_float()
var float[] ex2R = array.new_float(), var float[] ex2S = array.new_float()
var float[] ex3R = array.new_float(), var float[] ex3S = array.new_float()
var float[] ex4R = array.new_float(), var float[] ex4S = array.new_float()
var float[] ex5R = array.new_float(), var float[] ex5S = array.new_float()
var float[] ex6R = array.new_float(), var float[] ex6S = array.new_float()
var float[] ex7R = array.new_float(), var float[] ex7S = array.new_float()
var float[] ex8R = array.new_float(), var float[] ex8S = array.new_float()
var float[] ex9R = array.new_float(), var float[] ex9S = array.new_float()
var float[] ex10R = array.new_float(), var float[] ex10S = array.new_float()

accumulateEx(bool tfOn, float sig, float htfH, float htfL, float[] resArr, float[] supArr) =>
    bool newRes = sig == -1.0 and nz(sig[1]) != -1.0
    bool newSup = sig == 1.0  and nz(sig[1]) != 1.0
    if tfOn and exOn
        if newRes and not na(htfH)
            array.push(resArr, htfH)
            if array.size(resArr) > exLastN
                array.shift(resArr)
        if newSup and not na(htfL)
            array.push(supArr, htfL)
            if array.size(supArr) > exLastN
                array.shift(supArr)

accumulateEx(tf1On,  exSig1,  exH1,  exL1,  ex1R,  ex1S)
accumulateEx(tf2On,  exSig2,  exH2,  exL2,  ex2R,  ex2S)
accumulateEx(tf3On,  exSig3,  exH3,  exL3,  ex3R,  ex3S)
accumulateEx(tf4On,  exSig4,  exH4,  exL4,  ex4R,  ex4S)
accumulateEx(tf5On,  exSig5,  exH5,  exL5,  ex5R,  ex5S)
accumulateEx(tf6On,  exSig6,  exH6,  exL6,  ex6R,  ex6S)
accumulateEx(tf7On,  exSig7,  exH7,  exL7,  ex7R,  ex7S)
accumulateEx(tf8On,  exSig8,  exH8,  exL8,  ex8R,  ex8S)
accumulateEx(tf9On,  exSig9,  exH9,  exL9,  ex9R,  ex9S)
accumulateEx(tf10On, exSig10, exH10, exL10, ex10R, ex10S)

// ============================================================
// VA computation
// ============================================================
calcVA(float[] highs, float[] lows, float[] vols) =>
    int lb = array.size(highs)
    float pocP = na
    float vahP = na
    float valP = na
    if lb > 0
        float hh = array.get(highs, 0)
        float ll = array.get(lows, 0)
        for i = 1 to lb - 1
            hh := math.max(hh, array.get(highs, i))
            ll := math.min(ll, array.get(lows, i))
        float rng = math.max(hh - ll, hh * 0.01)
        float binSz = rng / numBins
        float[] hist = array.new_float(numBins, 0.0)
        float totalVol = 0.0
        for j = 0 to lb - 1
            float vol = math.max(array.get(vols, j), 1.0)
            totalVol += vol
            int bLo = int(math.max(math.floor((array.get(lows, j) - ll) / binSz), 0))
            int bHi = int(math.min(math.floor((array.get(highs, j) - ll) / binSz), numBins - 1))
            int binsHit = bHi - bLo + 1
            float volPerBin = vol / binsHit
            for k = bLo to bHi
                array.set(hist, k, array.get(hist, k) + volPerBin)
        float pocVol = 0.0
        int   pocIdx = 0
        for i = 0 to numBins - 1
            if array.get(hist, i) > pocVol
                pocVol := array.get(hist, i)
                pocIdx := i
        float areaVol = pocVol
        float target  = totalVol * valuePct / 100.0
        int   vaLow   = pocIdx
        int   vaHigh  = pocIdx
        for _step = 0 to numBins - 1
            if areaVol >= target
                break
            float volBelow = vaLow > 0          ? array.get(hist, vaLow - 1)  : 0.0
            float volAbove = vaHigh < numBins - 1 ? array.get(hist, vaHigh + 1) : 0.0
            if volBelow == 0 and volAbove == 0
                break
            if volBelow >= volAbove
                vaLow  -= 1
                areaVol += volBelow
            else
                vaHigh += 1
                areaVol += volAbove
        pocP := ll + (pocIdx + 0.5) * binSz
        vahP := ll + (vaHigh + 1)   * binSz
        valP := ll + vaLow          * binSz
    [pocP, vahP, valP]

// ============================================================
// Draw all for one TF
// ============================================================
drawTF(string tf, int width, bool enabled, int lblOffset,
       float[] vaH, float[] vaL, float[] vaV,
       float mp18, float mp28, float mm18, float mm28,
       float tr, float sl, float en, float tt1, float tt2, float tt3,
       float th1, float th2, float th3,
       float[] exRes, float[] exSup,
       float s1, float s2, float s3, float s4,
       float f50, float f618, float f786,
       float stV, float stD) =>

    string tfLbl = tf

    // Value Area
    if vaOn and enabled
        [poc, vah, val] = calcVA(vaH, vaL, vaV)
        emit(poc, width, str.format("POC ({0})", tfLbl), showVALabels, lblOffset)
        emit(vah, width, str.format("VAH ({0})", tfLbl), showVALabels, lblOffset)
        emit(val, width, str.format("VAL ({0})", tfLbl), showVALabels, lblOffset)

    // Murrey
    if mOn and enabled
        emit(mp18, width, str.format("+1/8 ({0})", tfLbl), showMLabels, lblOffset)
        emit(mp28, width, str.format("+2/8 ({0})", tfLbl), showMLabels, lblOffset)
        emit(mm18, width, str.format("-1/8 ({0})", tfLbl), showMLabels, lblOffset)
        emit(mm28, width, str.format("-2/8 ({0})", tfLbl), showMLabels, lblOffset)

    // Target Trend — SL + unhit targets only
    if tOn and enabled
        string dir = tr >= 1.0 ? "BUY" : "SELL"
        emit(sl, width, str.format("SL ({0} {1})", tfLbl, dir), showTLabels, lblOffset)
        if th1 < 1.0
            emit(tt1, width, str.format("T1 ({0})", tfLbl), showTLabels, lblOffset)
        if th2 < 1.0
            emit(tt2, width, str.format("T2 ({0})", tfLbl), showTLabels, lblOffset)
        if th3 < 1.0
            emit(tt3, width, str.format("T3 ({0})", tfLbl), showTLabels, lblOffset)

    // Exhaustion Levels
    if exOn and enabled
        if array.size(exRes) > 0
            for i = 0 to array.size(exRes) - 1
                emit(array.get(exRes, i), width, str.format("ExR ({0})", tfLbl), showELabels, lblOffset)
        if array.size(exSup) > 0
            for i = 0 to array.size(exSup) - 1
                emit(array.get(exSup, i), width, str.format("ExS ({0})", tfLbl), showELabels, lblOffset)

    // Fib Retracement
    if fibOn and enabled
        emit(f50,  width, str.format("Fib .5 ({0})",   tfLbl), showFibLabels, lblOffset)
        emit(f618, width, str.format("Fib .618 ({0})", tfLbl), showFibLabels, lblOffset)
        if fibShow786
            emit(f786, width, str.format("Fib .786 ({0})", tfLbl), showFibLabels, lblOffset)

    // Supertrend — current trailing-stop value
    if stOn and enabled
        string sdir = stD < 0 ? "up" : "dn"
        emit(stV, width, str.format("ST ({0} {1})", tfLbl, sdir), showSTLabels, lblOffset)

    // SMAs
    if smaOn and enabled
        if sma1On
            emit(s1, width, str.format("SMA{0} ({1})", sma1Len, tfLbl), showSLabels, lblOffset)
        if sma2On
            emit(s2, width, str.format("SMA{0} ({1})", sma2Len, tfLbl), showSLabels, lblOffset)
        if sma3On
            emit(s3, width, str.format("SMA{0} ({1})", sma3Len, tfLbl), showSLabels, lblOffset)
        if sma4On
            emit(s4, width, str.format("SMA{0} ({1})", sma4Len, tfLbl), showSLabels, lblOffset)

// ============================================================
// Draw one period's prior highs & lows (last N periods)
// ============================================================
drawPeriod(bool on, string lbl, float h1, float h2, float h3, float l1, float l2, float l3) =>
    if plOn and on
        if plHi
            emit(h1, lineWidth, str.format("{0}H1", lbl), showPLLabels, 2)
            if plBars >= 2
                emit(h2, lineWidth, str.format("{0}H2", lbl), showPLLabels, 2)
            if plBars >= 3
                emit(h3, lineWidth, str.format("{0}H3", lbl), showPLLabels, 2)
        if plLo
            emit(l1, lineWidth, str.format("{0}L1", lbl), showPLLabels, 2)
            if plBars >= 2
                emit(l2, lineWidth, str.format("{0}L2", lbl), showPLLabels, 2)
            if plBars >= 3
                emit(l3, lineWidth, str.format("{0}L3", lbl), showPLLabels, 2)

// ============================================================
// Draw on last bar only
// ============================================================
if barstate.islast
    if array.size(line.all) > 0
        for i = array.size(line.all) - 1 to 0
            line.delete(array.get(line.all, i))
    if array.size(label.all) > 0
        for i = array.size(label.all) - 1 to 0
            label.delete(array.get(label.all, i))

    // Reset the confluence collector for this redraw
    array.clear(cPx)
    array.clear(cTag)
    array.clear(cW)

    int chartSec = timeframe.in_seconds(timeframe.period)

    if tf1On and timeframe.in_seconds(tf1) >= chartSec
        drawTF(tf1, lineWidth, true, 2, h1H, h1L, h1V,
               m1p18, m1p28, m1m18, m1m28,
               tr1, sl1, en1, t1_1, t1_2, t1_3, t1h1, t1h2, t1h3,
               ex1R, ex1S,
               sa1_1, sa2_1, sa3_1, sa4_1,
               f50_1, f618_1, f786_1,
               stV1, stD1)

    if tf2On and timeframe.in_seconds(tf2) >= chartSec
        drawTF(tf2, lineWidth, true, 12, h2H, h2L, h2V,
               m2p18, m2p28, m2m18, m2m28,
               tr2, sl2, en2, t2_1, t2_2, t2_3, t2h1, t2h2, t2h3,
               ex2R, ex2S,
               sa1_2, sa2_2, sa3_2, sa4_2,
               f50_2, f618_2, f786_2,
               stV2, stD2)

    if tf3On and timeframe.in_seconds(tf3) >= chartSec
        drawTF(tf3, lineWidth, true, 22, h3H, h3L, h3V,
               m3p18, m3p28, m3m18, m3m28,
               tr3, sl3, en3, t3_1, t3_2, t3_3, t3h1, t3h2, t3h3,
               ex3R, ex3S,
               sa1_3, sa2_3, sa3_3, sa4_3,
               f50_3, f618_3, f786_3,
               stV3, stD3)

    if tf4On and timeframe.in_seconds(tf4) >= chartSec
        drawTF(tf4, lineWidth, true, 32, h4H, h4L, h4V,
               m4p18, m4p28, m4m18, m4m28,
               tr4, sl4, en4, t4_1, t4_2, t4_3, t4h1, t4h2, t4h3,
               ex4R, ex4S,
               sa1_4, sa2_4, sa3_4, sa4_4,
               f50_4, f618_4, f786_4,
               stV4, stD4)

    if tf5On and timeframe.in_seconds(tf5) >= chartSec
        drawTF(tf5, lineWidth, true, 42, h5H, h5L, h5V,
               m5p18, m5p28, m5m18, m5m28,
               tr5, sl5, en5, t5_1, t5_2, t5_3, t5h1, t5h2, t5h3,
               ex5R, ex5S,
               sa1_5, sa2_5, sa3_5, sa4_5,
               f50_5, f618_5, f786_5,
               stV5, stD5)

    if tf6On and timeframe.in_seconds(tf6) >= chartSec
        drawTF(tf6, lineWidth, true, 52, h6H, h6L, h6V,
               m6p18, m6p28, m6m18, m6m28,
               tr6, sl6, en6, t6_1, t6_2, t6_3, t6h1, t6h2, t6h3,
               ex6R, ex6S,
               sa1_6, sa2_6, sa3_6, sa4_6,
               f50_6, f618_6, f786_6,
               stV6, stD6)

    if tf7On and timeframe.in_seconds(tf7) >= chartSec
        drawTF(tf7, lineWidth, true, 62, h7H, h7L, h7V,
               m7p18, m7p28, m7m18, m7m28,
               tr7, sl7, en7, t7_1, t7_2, t7_3, t7h1, t7h2, t7h3,
               ex7R, ex7S,
               sa1_7, sa2_7, sa3_7, sa4_7,
               f50_7, f618_7, f786_7,
               stV7, stD7)

    if tf8On and timeframe.in_seconds(tf8) >= chartSec
        drawTF(tf8, lineWidth, true, 72, h8H, h8L, h8V,
               m8p18, m8p28, m8m18, m8m28,
               tr8, sl8, en8, t8_1, t8_2, t8_3, t8h1, t8h2, t8h3,
               ex8R, ex8S,
               sa1_8, sa2_8, sa3_8, sa4_8,
               f50_8, f618_8, f786_8,
               stV8, stD8)

    if tf9On and timeframe.in_seconds(tf9) >= chartSec
        drawTF(tf9, lineWidth, true, 82, h9H, h9L, h9V,
               m9p18, m9p28, m9m18, m9m28,
               tr9, sl9, en9, t9_1, t9_2, t9_3, t9h1, t9h2, t9h3,
               ex9R, ex9S,
               sa1_9, sa2_9, sa3_9, sa4_9,
               f50_9, f618_9, f786_9,
               stV9, stD9)

    if tf10On and timeframe.in_seconds(tf10) >= chartSec
        drawTF(tf10, lineWidth, true, 92, h10H, h10L, h10V,
               m10p18, m10p28, m10m18, m10m28,
               tr10, sl10, en10, t10_1, t10_2, t10_3, t10h1, t10h2, t10h3,
               ex10R, ex10S,
               sa1_10, sa2_10, sa3_10, sa4_10,
               f50_10, f618_10, f786_10,
               stV10, stD10)

    // Period levels — prior D/W/M/Q highs & lows
    drawPeriod(plD, "D", pdH1, pdH2, pdH3, pdL1, pdL2, pdL3)
    drawPeriod(plW, "W", pwH1, pwH2, pwH3, pwL1, pwL2, pwL3)
    drawPeriod(plM, "M", pmH1, pmH2, pmH3, pmL1, pmL2, pmL3)
    drawPeriod(plQ, "Q", pqH1, pqH2, pqH3, pqL1, pqL2, pqL3)

    // Merge-mode: everything collected above is clustered and drawn here
    if confluenceOn
        drawConfluence()

    // Bias zone — the line in the sand. Always drawn (no proximity filter,
    // no confluence merge), in its own style so it reads as THE reference.
    if biasOn
        if not na(bias50)
            line.new(bar_index - 1, bias50, bar_index, bias50, color=biasColor, width=biasWidth, style=getLineStyle(biasStyle), extend=extend.both)
            if showBiasLabels
                label.new(chart.left_visible_bar_time, bias50, str.format("Bias 0.5 ({0})", biasTf),
                     xloc=xloc.bar_time, style=label.style_label_right, color=color.new(biasColor, 80), textcolor=biasColor, size=lblSize)
        if not na(bias618)
            line.new(bar_index - 1, bias618, bar_index, bias618, color=biasColor, width=biasWidth, style=getLineStyle(biasStyle), extend=extend.both)
            if showBiasLabels
                label.new(chart.left_visible_bar_time, bias618, str.format("Bias 0.618 ({0})  defend", biasTf),
                     xloc=xloc.bar_time, style=label.style_label_right, color=color.new(biasColor, 80), textcolor=biasColor, size=lblSize)

    // ATR extremes — mean-reversion zones (basis ± mult × ATR). Not proximity-
    // filtered: by design these sit far from price, marking stretch extremes.
    if atrExOn
        if atrExShowMid and not na(atrBasis)
            line.new(bar_index + lineGap, atrBasis, bar_index + lineGap + 1, atrBasis, color=lineColor, width=atrExWidth, style=getLineStyle(atrExStyle), extend=extend.right)
        if not na(atrUp)
            line.new(bar_index + lineGap, atrUp, bar_index + lineGap + 1, atrUp, color=atrExUpColor, width=atrExWidth, style=getLineStyle(atrExStyle), extend=extend.right)
            if showAtrExLabels
                label.new(bar_index + lineGap, atrUp, str.format("ATR +{0,number,#.#}x short", atrExMult),
                     style=label.style_label_left, color=color.new(atrExUpColor, 80), textcolor=atrExUpColor, size=lblSize)
        if not na(atrDn)
            line.new(bar_index + lineGap, atrDn, bar_index + lineGap + 1, atrDn, color=atrExDnColor, width=atrExWidth, style=getLineStyle(atrExStyle), extend=extend.right)
            if showAtrExLabels
                label.new(bar_index + lineGap, atrDn, str.format("ATR -{0,number,#.#}x buy", atrExMult),
                     style=label.style_label_left, color=color.new(atrExDnColor, 80), textcolor=atrExDnColor, size=lblSize)

// ============================================================
// Alerts — computed on every bar (not just barstate.islast)
// ============================================================

// Helper: check if price is near any level in an array
isNearAnyInArray(float[] arr) =>
    bool result = false
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if isAlertNear(array.get(arr, i))
                result := true
    result

// Murrey proximity (any TF)
nearMurrey = (mOn and tf1On  and (isAlertNear(m1p18)  or isAlertNear(m1p28)  or isAlertNear(m1m18)  or isAlertNear(m1m28)))  or
             (mOn and tf2On  and (isAlertNear(m2p18)  or isAlertNear(m2p28)  or isAlertNear(m2m18)  or isAlertNear(m2m28)))  or
             (mOn and tf3On  and (isAlertNear(m3p18)  or isAlertNear(m3p28)  or isAlertNear(m3m18)  or isAlertNear(m3m28)))  or
             (mOn and tf4On  and (isAlertNear(m4p18)  or isAlertNear(m4p28)  or isAlertNear(m4m18)  or isAlertNear(m4m28)))  or
             (mOn and tf5On  and (isAlertNear(m5p18)  or isAlertNear(m5p28)  or isAlertNear(m5m18)  or isAlertNear(m5m28)))  or
             (mOn and tf6On  and (isAlertNear(m6p18)  or isAlertNear(m6p28)  or isAlertNear(m6m18)  or isAlertNear(m6m28)))  or
             (mOn and tf7On  and (isAlertNear(m7p18)  or isAlertNear(m7p28)  or isAlertNear(m7m18)  or isAlertNear(m7m28)))  or
             (mOn and tf8On  and (isAlertNear(m8p18)  or isAlertNear(m8p28)  or isAlertNear(m8m18)  or isAlertNear(m8m28)))  or
             (mOn and tf9On  and (isAlertNear(m9p18)  or isAlertNear(m9p28)  or isAlertNear(m9m18)  or isAlertNear(m9m28)))  or
             (mOn and tf10On and (isAlertNear(m10p18) or isAlertNear(m10p28) or isAlertNear(m10m18) or isAlertNear(m10m28)))

// Target/SL proximity (any TF)
nearTarget = (tOn and tf1On  and (isAlertNear(sl1)  or isAlertNear(t1_1)  or isAlertNear(t1_2)  or isAlertNear(t1_3)))  or
             (tOn and tf2On  and (isAlertNear(sl2)  or isAlertNear(t2_1)  or isAlertNear(t2_2)  or isAlertNear(t2_3)))  or
             (tOn and tf3On  and (isAlertNear(sl3)  or isAlertNear(t3_1)  or isAlertNear(t3_2)  or isAlertNear(t3_3)))  or
             (tOn and tf4On  and (isAlertNear(sl4)  or isAlertNear(t4_1)  or isAlertNear(t4_2)  or isAlertNear(t4_3)))  or
             (tOn and tf5On  and (isAlertNear(sl5)  or isAlertNear(t5_1)  or isAlertNear(t5_2)  or isAlertNear(t5_3)))  or
             (tOn and tf6On  and (isAlertNear(sl6)  or isAlertNear(t6_1)  or isAlertNear(t6_2)  or isAlertNear(t6_3)))  or
             (tOn and tf7On  and (isAlertNear(sl7)  or isAlertNear(t7_1)  or isAlertNear(t7_2)  or isAlertNear(t7_3)))  or
             (tOn and tf8On  and (isAlertNear(sl8)  or isAlertNear(t8_1)  or isAlertNear(t8_2)  or isAlertNear(t8_3)))  or
             (tOn and tf9On  and (isAlertNear(sl9)  or isAlertNear(t9_1)  or isAlertNear(t9_2)  or isAlertNear(t9_3)))  or
             (tOn and tf10On and (isAlertNear(sl10) or isAlertNear(t10_1) or isAlertNear(t10_2) or isAlertNear(t10_3)))

// SMA proximity (any TF)
nearSMA = (smaOn and tf1On  and ((sma1On and isAlertNear(sa1_1))  or (sma2On and isAlertNear(sa2_1))  or (sma3On and isAlertNear(sa3_1))  or (sma4On and isAlertNear(sa4_1))))  or
          (smaOn and tf2On  and ((sma1On and isAlertNear(sa1_2))  or (sma2On and isAlertNear(sa2_2))  or (sma3On and isAlertNear(sa3_2))  or (sma4On and isAlertNear(sa4_2))))  or
          (smaOn and tf3On  and ((sma1On and isAlertNear(sa1_3))  or (sma2On and isAlertNear(sa2_3))  or (sma3On and isAlertNear(sa3_3))  or (sma4On and isAlertNear(sa4_3))))  or
          (smaOn and tf4On  and ((sma1On and isAlertNear(sa1_4))  or (sma2On and isAlertNear(sa2_4))  or (sma3On and isAlertNear(sa3_4))  or (sma4On and isAlertNear(sa4_4))))  or
          (smaOn and tf5On  and ((sma1On and isAlertNear(sa1_5))  or (sma2On and isAlertNear(sa2_5))  or (sma3On and isAlertNear(sa3_5))  or (sma4On and isAlertNear(sa4_5))))  or
          (smaOn and tf6On  and ((sma1On and isAlertNear(sa1_6))  or (sma2On and isAlertNear(sa2_6))  or (sma3On and isAlertNear(sa3_6))  or (sma4On and isAlertNear(sa4_6))))  or
          (smaOn and tf7On  and ((sma1On and isAlertNear(sa1_7))  or (sma2On and isAlertNear(sa2_7))  or (sma3On and isAlertNear(sa3_7))  or (sma4On and isAlertNear(sa4_7))))  or
          (smaOn and tf8On  and ((sma1On and isAlertNear(sa1_8))  or (sma2On and isAlertNear(sa2_8))  or (sma3On and isAlertNear(sa3_8))  or (sma4On and isAlertNear(sa4_8))))  or
          (smaOn and tf9On  and ((sma1On and isAlertNear(sa1_9))  or (sma2On and isAlertNear(sa2_9))  or (sma3On and isAlertNear(sa3_9))  or (sma4On and isAlertNear(sa4_9))))  or
          (smaOn and tf10On and ((sma1On and isAlertNear(sa1_10)) or (sma2On and isAlertNear(sa2_10)) or (sma3On and isAlertNear(sa3_10)) or (sma4On and isAlertNear(sa4_10))))

// Exhaustion proximity (any TF)
nearExhaustion = (exOn and tf1On  and (isNearAnyInArray(ex1R)  or isNearAnyInArray(ex1S)))  or
                 (exOn and tf2On  and (isNearAnyInArray(ex2R)  or isNearAnyInArray(ex2S)))  or
                 (exOn and tf3On  and (isNearAnyInArray(ex3R)  or isNearAnyInArray(ex3S)))  or
                 (exOn and tf4On  and (isNearAnyInArray(ex4R)  or isNearAnyInArray(ex4S)))  or
                 (exOn and tf5On  and (isNearAnyInArray(ex5R)  or isNearAnyInArray(ex5S)))  or
                 (exOn and tf6On  and (isNearAnyInArray(ex6R)  or isNearAnyInArray(ex6S)))  or
                 (exOn and tf7On  and (isNearAnyInArray(ex7R)  or isNearAnyInArray(ex7S)))  or
                 (exOn and tf8On  and (isNearAnyInArray(ex8R)  or isNearAnyInArray(ex8S)))  or
                 (exOn and tf9On  and (isNearAnyInArray(ex9R)  or isNearAnyInArray(ex9S)))  or
                 (exOn and tf10On and (isNearAnyInArray(ex10R) or isNearAnyInArray(ex10S)))

// Fib proximity (any TF)
nearFib = (fibOn and tf1On  and (isAlertNear(f50_1)  or isAlertNear(f618_1)  or (fibShow786 and isAlertNear(f786_1))))  or
          (fibOn and tf2On  and (isAlertNear(f50_2)  or isAlertNear(f618_2)  or (fibShow786 and isAlertNear(f786_2))))  or
          (fibOn and tf3On  and (isAlertNear(f50_3)  or isAlertNear(f618_3)  or (fibShow786 and isAlertNear(f786_3))))  or
          (fibOn and tf4On  and (isAlertNear(f50_4)  or isAlertNear(f618_4)  or (fibShow786 and isAlertNear(f786_4))))  or
          (fibOn and tf5On  and (isAlertNear(f50_5)  or isAlertNear(f618_5)  or (fibShow786 and isAlertNear(f786_5))))  or
          (fibOn and tf6On  and (isAlertNear(f50_6)  or isAlertNear(f618_6)  or (fibShow786 and isAlertNear(f786_6))))  or
          (fibOn and tf7On  and (isAlertNear(f50_7)  or isAlertNear(f618_7)  or (fibShow786 and isAlertNear(f786_7))))  or
          (fibOn and tf8On  and (isAlertNear(f50_8)  or isAlertNear(f618_8)  or (fibShow786 and isAlertNear(f786_8))))  or
          (fibOn and tf9On  and (isAlertNear(f50_9)  or isAlertNear(f618_9)  or (fibShow786 and isAlertNear(f786_9))))  or
          (fibOn and tf10On and (isAlertNear(f50_10) or isAlertNear(f618_10) or (fibShow786 and isAlertNear(f786_10))))

// Supertrend proximity (any TF)
nearSupertrend = (stOn and tf1On  and isAlertNear(stV1))  or
                 (stOn and tf2On  and isAlertNear(stV2))  or
                 (stOn and tf3On  and isAlertNear(stV3))  or
                 (stOn and tf4On  and isAlertNear(stV4))  or
                 (stOn and tf5On  and isAlertNear(stV5))  or
                 (stOn and tf6On  and isAlertNear(stV6))  or
                 (stOn and tf7On  and isAlertNear(stV7))  or
                 (stOn and tf8On  and isAlertNear(stV8))  or
                 (stOn and tf9On  and isAlertNear(stV9))  or
                 (stOn and tf10On and isAlertNear(stV10))

// Period-level proximity (prior D/W/M/Q highs & lows)
nearPeriodOne(bool on, float h1, float h2, float h3, float l1, float l2, float l3) =>
    plOn and on and (
      (plHi and (isAlertNear(h1) or (plBars >= 2 and isAlertNear(h2)) or (plBars >= 3 and isAlertNear(h3)))) or
      (plLo and (isAlertNear(l1) or (plBars >= 2 and isAlertNear(l2)) or (plBars >= 3 and isAlertNear(l3)))))

nearPeriod = nearPeriodOne(plD, pdH1, pdH2, pdH3, pdL1, pdL2, pdL3) or
             nearPeriodOne(plW, pwH1, pwH2, pwH3, pwL1, pwL2, pwL3) or
             nearPeriodOne(plM, pmH1, pmH2, pmH3, pmL1, pmL2, pmL3) or
             nearPeriodOne(plQ, pqH1, pqH2, pqH3, pqL1, pqL2, pqL3)

// Combined
nearAnyLevel = nearMurrey or nearTarget or nearSMA or nearExhaustion or nearFib or nearSupertrend or nearPeriod

alertcondition(nearAnyLevel,    title="Price near any key level",      message="Price is near a key level")
alertcondition(nearMurrey,      title="Price near Murrey extreme",     message="Price is near a Murrey Math extreme level")
alertcondition(nearTarget,      title="Price near Target/SL",          message="Price is near a Target Trend level")
alertcondition(nearSMA,         title="Price near SMA",                message="Price is near an SMA level")
alertcondition(nearExhaustion,  title="Price near exhaustion level",   message="Price is near an exhaustion support/resistance level")
alertcondition(nearFib,         title="Price near Fib level",          message="Price is near a Fib retracement level")
alertcondition(nearSupertrend,  title="Price near Supertrend",         message="Price is near a Supertrend stop level")
alertcondition(nearPeriod,      title="Price near period high/low",    message="Price is near a prior period high/low (potential failed breakdown)")

// Bias flip — cross of the defended 0.618 line
alertcondition(biasOn and ta.crossover(close, bias618),  title="Bias turned bullish", message="Price reclaimed the bias 0.618 line — stay bullish")
alertcondition(biasOn and ta.crossunder(close, bias618), title="Bias turned bearish", message="Price lost the bias 0.618 line — stay bearish")

// ATR extreme reached — mean-reversion zones
alertcondition(atrExOn and ta.crossover(close, atrUp),  title="Upper ATR extreme (short zone)", message="Price stretched to the upper ATR extreme — mean-reversion short zone")
alertcondition(atrExOn and ta.crossunder(close, atrDn), title="Lower ATR extreme (buy zone)",   message="Price stretched to the lower ATR extreme — mean-reversion buy zone")
````
