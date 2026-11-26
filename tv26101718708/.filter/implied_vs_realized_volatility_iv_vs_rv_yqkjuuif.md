# Implied vs Realized Volatility (IV vs RV)

- url: https://www.tradingview.com/script/YQKJUUIF-Implied-vs-Realized-Volatility-IV-vs-RV/
- type: indicator
- pine_id: PUB;31887f00bd174b86b566c56aa1080beb
- version: 3.0

## Description

Are options paying more than the market is actually moving?

This indicator plots implied volatility (what the options market is pricing) against realized volatility (what the market is actually delivering), on the same scale, so you can see at a glance whether option premium is rich or thin.

WHAT IT SHOWS
- Green line: Implied volatility, the live vol index (e.g. VIX for the S&P 500).
- Red line: Realized volatility, how much the underlying index has really been moving over the same horizon.
- Shading between the lines: green when implied is above realized (options are pricing more movement than is happening), red when realized is above implied (the market is moving more than options are paying for). The bigger the gap, the brighter the shading.

THE TABLE
- Regime: RICH / FAIR / THIN / NEGATIVE, with the % implied is above or below realized (e.g. RICH +42%).
- Implied and Realized: the live values.
- Premium rank: where today's gap sits compared with the recent past (3M / 6M / 1Y). High = unusually fat premium.
- Seller win rate: over the last 21 days, how often the implied vol that was priced turned out higher than the volatility that actually followed. A reality check on whether premium has really been overpriced lately.

AUTO-PAIRING
Add it to a chart and it picks the right pair automatically. It works on the index, its main ETFs, futures and CFDs:
- S&P 500 (SPX, SPY, ES, US500): VIX
- Nasdaq 100 (NDX, QQQ, NQ): VXN
- Russell 2000 (RUT, IWM, RTY): RVX
- Dow Jones (DJI, DIA, YM): VXD
- ASX 200 (XJO, SPI futures, AUS200): XVI
- Hang Seng: VHSI · Nifty 50: India VIX
You can also choose a market manually, including VIX9D, VIX3M and VIX6M. The realized vol window adjusts automatically to match (e.g. VIX9D compares against roughly 9 days of realized vol, VIX against 21 trading days). Any other pair can be set under Custom.

HOW IT'S CALCULATED
Realized vol is close-to-close volatility of the underlying index, annualized to the same units as the vol index (zero-mean, the same convention used for variance swaps). It's built from completed daily closes plus today's live price, so it updates through the session and reads the same on any timeframe, from 1H to weekly. No repainting.

WHO IT'S FOR
- Option sellers: sell premium when it's rich, be careful when it's thin or negative.
- Option buyers: spot when protection is relatively cheap.
- Anyone wanting a quick read on whether the market is calmer or wilder than options expect.

NOTES
Implied and realized vol measure the size of moves, not their direction. A slow, steady trend can stay "low vol" while still travelling a long way, so use this alongside your own risk management. For educational purposes only, not financial advice.

## Source Code

````pine
//@version=6
indicator("Implied vs Realized Volatility", shorttitle = "IV vs RV", precision = 1)

// =============================================================================
// Implied volatility (a vol index such as VIX or XVI) against the volatility the
// underlying index has ACTUALLY delivered (realized vol).
//
//   IV = the vol index, live.
//   RV = close-to-close realized vol of the underlying, zero-mean (the
//        variance-swap / industry convention: √(average squared daily log
//        return) × √252 × 100), so it's in the same units as the vol index and
//        a one-way trend counts in full. Built from completed daily closes plus TODAY'S LIVE
//        price, so it moves through the session on any chart timeframe.
//
//   The RV window matches the vol index's horizon automatically:
//     VIX9D → 6 trading days · VIX / VXN / RVX / VXD / XVI / VHSI / India VIX
//     → 21 · VIX3M → 63 · VIX6M → 126 · VIX1Y → 252.
//
//   IV above RV (green) = options priced for more movement than the market is
//   delivering: the premium-selling environment.
//   RV above IV (red)   = the market is moving more than options are paying for.
// =============================================================================

D = display.none

// ============ Inputs ============
gMk = "Market"
market = input.string("Auto", "Market", group = gMk, display = D,
     options = ["Auto", "S&P 500 · VIX", "S&P 500 · VIX9D", "S&P 500 · VIX3M", "S&P 500 · VIX6M",
                 "Nasdaq 100 · VXN", "Russell 2000 · RVX", "Dow Jones · VXD", "ASX 200 · XVI",
                 "Hang Seng · VHSI", "Nifty 50 · India VIX", "Custom"],
     tooltip = "Auto reads your chart (index, ETF, futures or CFD) and picks the matching vol index. The realized-vol window follows the vol index's horizon (e.g. VIX9D → 9-day).")
customVol = input.symbol("CBOE:VIX", "Custom vol index", group = gMk, display = D,
     tooltip = "Only used when Market = Custom.")
customUnd = input.symbol("SP:SPX",   "Custom underlying", group = gMk, display = D,
     tooltip = "Only used when Market = Custom. The index the vol index measures.")

pctLbIn = input.string("3M", "Premium rank lookback", options = ["3M", "6M", "1Y"], group = "Stats", display = D,
     tooltip = "How far back today's premium (IV − RV) is ranked against. 3M ≈ 63 trading days, 6M ≈ 126, 1Y ≈ 252.")
pctLb   = pctLbIn == "1Y" ? 252 : pctLbIn == "6M" ? 126 : 63

richT  = input.float(1.30, "RICH at IV ÷ RV ≥", minval = 1.0, step = 0.05, group = "Regime", display = D)
fairT  = input.float(1.10, "FAIR at IV ÷ RV ≥", minval = 1.0, step = 0.05, group = "Regime", display = D,
               tooltip = "Below this down to 1.0 = THIN. Below 1.0 (realized above implied) = NEGATIVE.")

showFill = input.bool(true, "Shading between the lines", group = "Display", display = D)

gSty    = "Style"
ivCol   = input.color(#2fd47a, "Implied (IV)",  group = gSty, inline = "c", display = D)
rvCol   = input.color(#ff5252, "Realized (RV)", group = gSty, inline = "c", display = D)
lineW   = input.int(3, "Line width", minval = 1, maxval = 5, group = gSty, display = D)
fillStr = input.string("Normal", "Shading intensity", options = ["Subtle", "Normal", "Strong"], group = gSty, display = D)

gRd     = "Readout"
showTbl = input.bool(true, "Show stats table", group = gRd, display = D)
tblPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gRd, display = D)
tblSize = input.string("Normal", "Text size", options = ["Small", "Normal", "Large", "Extra large"], group = gRd, display = D)
regSize = input.string("One size larger", "Regime label size", options = ["Same as table", "One size larger", "Two sizes larger"], group = gRd, display = D)
regBold = input.bool(true, "Bold regime label", group = gRd, display = D)
tblOpac = input.int(75, "Background opacity %", minval = 0, maxval = 100, step = 5, group = gRd, display = D)

// ============ Market resolution ============
// Auto: match the chart to an index family. Covers the index itself, the main
// ETFs, futures (by root) and common CFD names.
inList(simple string s, simple string lst) =>
    str.contains(lst, "|" + s + "|")

tk = syminfo.ticker
rt = syminfo.root

autoKey = inList(tk, "|SPX|SPY|VOO|IVV|US500|SPX500|SPX500USD|SP500|US500USD|") or inList(rt, "|ES|MES|SPX|") ? "SPX" :
          inList(tk, "|NDX|QQQ|US100|NAS100|NAS100USD|USTEC|") or inList(rt, "|NQ|MNQ|") ? "NDX" :
          inList(tk, "|RUT|IWM|US2000|RUS2000|") or inList(rt, "|RTY|M2K|") ? "RUT" :
          inList(tk, "|DJI|DIA|US30|") or inList(rt, "|YM|MYM|") ? "DJI" :
          inList(tk, "|XJO|AUS200|AU200|AU200AUD|AUS200AUD|STW|IOZ|") or inList(rt, "|AP|") ? "XJO" :
          inList(tk, "|HSI|HK50|") or inList(rt, "|HSI|") ? "HSI" :
          inList(tk, "|NIFTY|NIFTY50|") or inList(rt, "|NIFTY|") ? "NIFTY" : "NONE"

autoMiss = market == "Auto" and autoKey == "NONE"

key = market == "Auto"                 ? (autoMiss ? "SPX" : autoKey) :
      market == "S&P 500 · VIX"        ? "SPX"   :
      market == "S&P 500 · VIX9D"      ? "SPX9D" :
      market == "S&P 500 · VIX3M"      ? "SPX3M" :
      market == "S&P 500 · VIX6M"      ? "SPX6M" :
      market == "Nasdaq 100 · VXN"     ? "NDX"   :
      market == "Russell 2000 · RVX"   ? "RUT"   :
      market == "Dow Jones · VXD"      ? "DJI"   :
      market == "ASX 200 · XVI"        ? "XJO"   :
      market == "Hang Seng · VHSI"     ? "HSI"   :
      market == "Nifty 50 · India VIX" ? "NIFTY" : "CUSTOM"

volSym = key == "SPX"   ? "CBOE:VIX"   : key == "SPX9D" ? "CBOE:VIX9D" : key == "SPX3M" ? "CBOE:VIX3M" :
         key == "SPX6M" ? "CBOE:VIX6M" : key == "NDX"   ? "CBOE:VXN"   : key == "RUT"   ? "CBOE:RVX"   :
         key == "DJI"   ? "CBOE:VXD"   : key == "XJO"   ? "ASX:XVI"    : key == "HSI"   ? "HSI:VHSI"   :
         key == "NIFTY" ? "NSE:INDIAVIX" : customVol
undSym = key == "SPX" or key == "SPX9D" or key == "SPX3M" or key == "SPX6M" ? "SP:SPX" :
         key == "NDX"   ? "NASDAQ:NDX" : key == "RUT" ? "TVC:RUT" : key == "DJI" ? "TVC:DJI" :
         key == "XJO"   ? "ASX:XJO"    : key == "HSI" ? "HSI:HSI" : key == "NIFTY" ? "NSE:NIFTY" : customUnd

// RV window = the vol index's horizon in trading days
is1D  = str.contains(volSym, "VIX1D")
RV_N  = str.contains(volSym, "VIX9D") ? 6   :
         str.contains(volSym, "VIX3M") ? 63  :
         str.contains(volSym, "VIX6M") ? 126 :
         str.contains(volSym, "VIX1Y") ? 252 : 21
SCORE_N = 21       // seller win rate is scored over the last 21 days

// ============ Constants ============
ANN   = math.sqrt(252) * 100
cGrey = #9598a1
cNorm = #787b86

shade(color c, float f) =>
    color.rgb(color.r(c) * f, color.g(c) * f, color.b(c) * f)

// ============ Daily engine ============
// Runs on the underlying's DAILY bars. Everything it returns is as of the
// PREVIOUS completed day ([1] / pushed one bar late), and it's requested with
// lookahead_on: the standard no-repaint pattern. Today's live move is added
// on the chart side, so the result is identical on 1h, 4h, D or W.
dailyEngine(simple string vSym, simple int lb, simple int n) =>
    float r  = math.log(close / close[1])
    float s2 = math.sum(r * r, n - 1)        // squared returns, last n-1 completed days

    // Completed-day RV (zero-mean) and the vol index's close on the same day
    float rvD  = math.sqrt(math.sum(r * r, n) / n) * ANN
    float ivD  = request.security(vSym, "D", close, ignore_invalid_symbol = true)
    float prem = ivD - rvD

    // Daily premium history (for the live premium rank)
    var array<float> premHist = array.new_float()
    if not na(prem[1])
        array.push(premHist, prem[1])
        if array.size(premHist) > lb
            array.shift(premHist)

    // Seller win rate: the IV priced n days earlier vs the RV actually realized
    // over those n days (the RV window ending that day covers exactly them).
    // Scored over the last 21 completed days → % of the time IV beat RV.
    float ivLag = ivD[n]
    var array<float> hits = array.new_float()
    if not na(ivLag[1]) and not na(rvD[1])
        array.push(hits, ivLag[1] > rvD[1] ? 1.0 : 0.0)
        if array.size(hits) > SCORE_N
            array.shift(hits)
    float hitRate = array.size(hits) > 0 ? array.avg(hits) * 100 : na

    [close[1], s2[1], premHist, hitRate]

[prevC, s2, premHist, hitRate] =
     request.security(undSym, "D", dailyEngine(volSym, pctLb, RV_N), lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

// Live values on the chart's own timeframe. fixnan carries the last value
// through bars where that market is closed (e.g. a futures chart overnight).
undRaw = request.security(undSym, timeframe.period, close, ignore_invalid_symbol = true)
ivRaw  = request.security(volSym, timeframe.period, close, ignore_invalid_symbol = true)
undC   = fixnan(undRaw)
iv     = fixnan(ivRaw)

// ============ Realized vol: completed days + today's live move ============
// Zero-mean: √(average of the n squared returns) — n-1 completed days + today's live one.
rvFrom(int n, float S2, float rT) =>
    float res = na
    if not na(S2) and not na(rT)
        res := math.sqrt((S2 + rT * rT) / n) * ANN
    res

rToday = na(prevC) or na(undC) or prevC <= 0 ? na : math.log(undC / prevC)
rv     = is1D ? na : rvFrom(RV_N, s2, rToday)

// ============ Premium, ratio, regime ============
prem  = na(iv) or na(rv) ? na : iv - rv
ratio = na(iv) or na(rv) or rv <= 0 ? na : iv / rv

regime = na(ratio)      ? "n/a"      :
         ratio >= richT ? "RICH"     :
         ratio >= fairT ? "FAIR"     :
         ratio >= 1.0   ? "THIN"     : "NEGATIVE"
regCol = regime == "RICH" ? ivCol : regime == "FAIR" ? shade(ivCol, 0.65) :
         regime == "THIN" ? cNorm : regime == "NEGATIVE" ? rvCol : cNorm

// Live premium vs the chosen lookback of daily premiums
float premPct = na
if not na(prem) and not na(premHist)
    int n = array.size(premHist)
    if n > 0
        int nBelow = 0
        for v in premHist
            nBelow += v < prem ? 1 : 0
        premPct := 100.0 * nBelow / n

// ============ Lines + shading ============
// Shading strength follows the size of the gap relative to IV: faint when the
// lines are close, full strength once the gap reaches ~40% of IV. The fill is a
// darker shade of the line colour and is capped well short of solid, so the
// lines always stay readable on top of it, even in extreme vol spikes.
fStrong = fillStr == "Strong" ? 45 : fillStr == "Subtle" ? 65 : 55   // transparency at full gap (cap)
fFaint  = fillStr == "Strong" ? 82 : fillStr == "Subtle" ? 93 : 88   // transparency at no gap
gapFrac = na(prem) or na(iv) or iv <= 0 ? 0.0 : math.min(math.abs(prem) / (0.40 * iv), 1.0)
gapCol  = na(prem) ? color(na) : shade(prem >= 0 ? ivCol : rvCol, 0.7)
fillCol = showFill and not na(prem) ? color.new(gapCol, fFaint - (fFaint - fStrong) * gapFrac) : color(na)

pRV = plot(rv, "Realized vol", color = rvCol, linewidth = lineW, editable = false)
pIV = plot(iv, "Implied vol",  color = ivCol, linewidth = lineW, editable = false)
fill(pIV, pRV, color = fillCol, title = "Premium shading", editable = false)

// ============ Data checks ============
var bool ivSeen  = false
var bool undSeen = false
if not na(ivRaw)
    ivSeen := true
if not na(undRaw)
    undSeen := true

string problem = is1D ? "1-day vol indices aren't supported: realized vol needs at least 5 days. Pick another Market." :
     not ivSeen  ? "No data for " + volSym + " on TradingView. Pick another Market, or set a Custom pair." :
     not undSeen ? "No data for " + undSym + " on TradingView. Pick another Market, or set a Custom pair." : ""

// ============ Stats table ============
bgHead = color.new(#131722, math.max(0, 100 - tblOpac - 20))
bgRow  = color.new(#131722, 100 - tblOpac)

// Text sizes as a ladder so the regime label can sit one or two steps above the table text
sizeAt(int i) =>
    i <= 0 ? size.tiny : i == 1 ? size.small : i == 2 ? size.normal : i == 3 ? size.large : size.huge
tIdx   = tblSize == "Small" ? 0 : tblSize == "Large" ? 2 : tblSize == "Extra large" ? 3 : 1   // "Normal" = TradingView's small
rIdx   = tIdx + (regSize == "Two sizes larger" ? 2 : regSize == "One size larger" ? 1 : 0)
tsz    = sizeAt(tIdx)
rsz    = sizeAt(rIdx)
rFmt   = regBold ? text.format_bold : text.format_none
pos    = tblPos == "Top Right" ? position.top_right : tblPos == "Top Left" ? position.top_left :
         tblPos == "Bottom Left" ? position.bottom_left : position.bottom_right

// Colour bands for the 0–100% stats: wide neutral middle, colour only at the extremes
cFluoro = #00ff7f
cDeepRd = #d50000
bandCol(float v) =>
    na(v) ? cGrey : v >= 90 ? cFluoro : v > 75 ? ivCol : v >= 25 ? cGrey : v > 10 ? rvCol : cDeepRd

fmt(float v, string f) =>
    na(v) ? "—" : str.tostring(v, f)

row(table tb, int r, string lbl, string val, color vc, string tip) =>
    table.cell(tb, 0, r, lbl, text_color = cGrey, bgcolor = bgRow, text_size = tsz, text_halign = text.align_left, tooltip = tip)
    table.cell(tb, 1, r, val, text_color = vc,    bgcolor = bgRow, text_size = tsz, text_halign = text.align_right, tooltip = tip)

// Short display name of the vol index, e.g. "CBOE:VIX9D" → "VIX9D"
volName = str.replace_all(str.replace_all(str.replace_all(str.replace_all(str.replace_all(
     volSym, "CBOE:", ""), "ASX:", ""), "HSI:", ""), "NSE:", ""), "TVC:", "")

var table t = table.new(pos, 2, 6, border_width = 0, frame_width = 0)

if showTbl and barstate.islast
    table.clear(t, 0, 0, 1, 5)
    string head = volName + " · " + str.tostring(RV_N) + "d"
    if problem != ""
        table.cell(t, 0, 0, head, text_color = cGrey, bgcolor = bgHead, text_size = tsz, text_halign = text.align_left)
        table.cell(t, 1, 0, " NO DATA ", text_color = color.white, bgcolor = cNorm, text_size = rsz, text_formatting = rFmt)
        table.cell(t, 0, 1, problem, text_color = color.white, bgcolor = bgRow, text_size = tsz, text_halign = text.align_left)
        table.merge_cells(t, 0, 1, 1, 1)
    else
        table.cell(t, 0, 0, head, text_color = cGrey, bgcolor = bgHead, text_size = tsz, text_halign = text.align_left,
             tooltip = volSym + " vs " + str.tostring(RV_N) + "-day realized vol of " + undSym)
        float  diffPct = na(ratio) ? na : (ratio - 1) * 100
        string pill    = na(diffPct) ? regime : regime + "  " + (diffPct >= 0 ? "+" : "") + str.tostring(diffPct, "0") + "%"
        table.cell(t, 1, 0, " " + pill + " ", text_color = color.white, bgcolor = regCol, text_size = rsz, text_formatting = rFmt,
             tooltip = "How much higher (+) or lower (−) implied vol is than realized vol. RICH ≥ +" + str.tostring((richT - 1) * 100, "0") + "%, FAIR ≥ +" + str.tostring((fairT - 1) * 100, "0") + "%, THIN ≥ 0%, NEGATIVE below 0%.")
        row(t, 1, "Implied",  fmt(iv, "0.00"), ivCol, "The vol index, live.")
        row(t, 2, "Realized", fmt(rv, "0.00"), rvCol,
             str.tostring(RV_N) + "-day close-to-close realized vol of the underlying (zero-mean), including today's live move.")
        row(t, 3, "Premium rank", na(premPct) ? "—" : str.tostring(premPct, "0") + "%", bandCol(premPct),
             "Where today's premium (IV − RV) sits against the last " + pctLbIn + ". High = unusually fat premium.")
        row(t, 4, "Seller win rate", na(hitRate) ? "—" : str.tostring(hitRate, "0") + "%", bandCol(hitRate),
             "Last 21 days: how often the IV priced " + str.tostring(RV_N) + " days earlier was above the realized vol that actually followed over those " + str.tostring(RV_N) + " days.")
        if autoMiss
            table.cell(t, 0, 5, "Chart not recognised: showing S&P 500 / VIX. Pick a Market in settings.",
                 text_color = cGrey, bgcolor = bgRow, text_size = size.tiny, text_halign = text.align_left)
            table.merge_cells(t, 0, 5, 1, 5)
````
