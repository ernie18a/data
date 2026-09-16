<!-- tradingview-pine-id: PUB;1ca439d5e6704e88813789d58ae80988 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# COT Cloud

Source: https://www.tradingview.com/script/KcelvBj1-COT-Pulse-Cloud-Trend/

## Description

COT Pulse Cloud Trend — Script Description 
What it does

COT Cloud plots a translucent price cloud whose color and intensity reflect CFTC Commitment of Traders positioning for the chart's own market — large speculators (Non-Commercial) and/or hedgers (Commercial). It auto-detects the market from the chart symbol and pulls the matching weekly CFTC data automatically; no per-chart setup needed for covered markets.

Data source

Pulls straight from TradingView's own CFTC feed via request.security() — the Legacy report's Non-Commercial/Commercial Long and Short symbols (<code>_F_NCP_L/S, <code>_F_CP_L/S), no exchange prefix. This is the same report definition (noncomm_positions_long_all, comm_positions_long_all, etc.) used by CFTC's own Socrata dataset, so it lines up with the official weekly COT report.

Auto-detection

Reads syminfo.basecurrency/syminfo.currency/syminfo.root to identify the market and looks up its CFTC contract code. Covered: EUR, GBP, JPY, AUD, NZD, CAD, CHF; Gold, Silver, Copper, Palladium, Platinum; Wheat, Cotton, Corn, Soybeans, Sugar, Coffee, Cocoa, Live Cattle; WTI Crude Oil, Natural Gas; 2-Year and 10-Year Treasury Notes; Nikkei 225, S&P 500, Nasdaq-100, Dow, Russell 2000, VIX, US Dollar Index, Bitcoin. For USDCAD/USDCHF/USDJPY-style charts (USD as the base currency) and the corresponding CAD/CHF/JPY futures, long and short are swapped so a positive net always means "bullish USD" — CFTC quotes those three the other way round.

If the chart's market isn't in this table, the script does not silently fall back to whatever is in the manual-symbol fields (that would plot a different market's COT data without warning) — it shows a gray "no COT match" label instead. Turn auto-detect off and enter symbols manually to use it on an uncovered market.

Position (what feeds the cloud)

Non-Commercial — large speculators' net (Long − Short)
Commercial — hedgers' net
Difference — Non-Commercial net minus Commercial net
Color by (how it's colored)

Auto (default) — picks the mode a backtest found works best per market: Absolute for Gold, Trend everywhere else, Excel for Difference.
Excel — a 3-point color scale anchored at [min, 50th percentile, max] of the value over a configurable history window: red at the low anchor, white at the median, green at the high anchor, plus a sign-colored border.
Trend — white at the position's own 13-week average, fading to green (more long than usual) or red (more short than usual) with distance from it; blue when both legs are below their own 13-week average ("cooling" interest on both sides).
Absolute — %Long of the current week's total (Long + Short).
Relative — where net positioning sits within its own trailing lookback window (0–100 percentile).
Extreme-reading marker

A small orange triangle appears below the cloud, plus an alert condition, whenever the active reading is in the top or bottom 20% of its scale. A backtest (COT signal vs. forward price return, 1/4/13/26 weeks ahead, across five markets back to 2007) found this is where the spread between the best- and worst-performing readings was consistently widest — i.e. where whatever edge COT positioning carries actually concentrates. It flags "pay attention," not a direction: the same extreme reading preceded further trend continuation in Gold/EUR but reversals in GBP/S&P 500, so read it in the context of the specific market, not as a universal buy/sell signal.

Honest limitations

The backtest behind Auto mode and the extreme marker covered 5 of the many markets this script auto-detects (EUR, GBP, USDJPY, Gold, S&P 500), not all of them — treat the defaults as a reasonable starting point, not a validated rule for every market.
Even where tested, the edge was weak (correlation ~0.1–0.25, hit rate ~50–62%) and only showed up at 13–26 week horizons; a single week's change in positioning carried essentially no signal.
CFTC codes beyond EUR and Gold's Non-Commercial/Commercial symbols were cross-checked across public sources but not individually re-verified live on TradingView — if a market's cloud looks off, search <code>_F_N in TradingView's symbol search to confirm.
This is a slow, structural positioning indicator meant to add context to other analysis — not a standalone timing signal.

---

## Source Code

````pine
//@version=6
// COT Cloud — standalone indicator, no dependency on the COT Pulse backend.
// Auto-detects the market from the chart symbol (syminfo.basecurrency for FX,
// syminfo.root for futures) and pulls Legacy-report Non-Commercial and
// Commercial long/short straight from TradingView's own CFTC feed
// ("_F_NCP_L/S" and "_F_CP_L/S") — the same report cot/cftc.py reads
// (F_NC_LONG = noncomm_positions_long_all, F_COMM_LONG = comm_positions_
// long_all), so this matches the workbook and COT Pulse exactly, unlike an
// earlier version that used the TFF/Disaggregated reports' Leveraged
// Money / Managed Money buckets as a stand-in. Falls back to the manual
// symbol inputs for any market not in the table below.
//
// "Position" picks what feeds the cloud: Non-Commercial, Commercial, or
// Difference (Non-Commercial net minus Commercial net, matching the
// workbook's own Difference column).
//
// "Color by" picks how it's colored:
//   Auto — picks the mode a backtest found works best for the chart's own
//     market (see "Backtest findings" below): Absolute for Gold, Trend
//     everywhere else covered, Excel for Difference (the only mode that
//     fits a pure difference). Falls back to Trend for an uncovered
//     manual-symbol market, since Trend had the most consistent direction
//     across the markets tested.
//   Excel — reproduces the workbook's own conditional formatting on its
//     Net Position / Difference columns exactly, as read from the
//     workbook's conditional-formatting rules: a 3-point color scale
//     anchored at [min, 50th percentile, max] of the value over the
//     History window — red at the low anchor, white at the 50th
//     percentile (not the midpoint of min/max — Excel's percentile
//     anchor), green at the high anchor — plus a border colored by sign
//     (dark red below zero, dark green above), mirroring the workbook's
//     font-color rule on top of its fill color scale. This is the only
//     mode used for Difference (there's no separate Long/Short pair to
//     read a trend or %Long from a pure difference).
//   Trend — white right at net's (Long-Short) own 13-week average,
//     fading to green above it (more long than usual) or red below it
//     (more short than usual) the further it deviates. Blue overrides
//     both when BOTH legs are below their own 13-week average (falling
//     interest on both sides) — darker blue the colder.
//   Absolute — %Long of the current week's total (Long+Short), same
//     figure as COT Pulse's %Long column.
//   Relative — where net (Long-Short) sits within its own trailing
//     Lookback window, 0-100, mirroring cot/transform.py::_cot_index.
//
// Backtest findings (correlated each mode's reading against forward price
// return, 1/4/13/26 weeks out, on EUR/GBP/USDJPY/Gold/SP500 back to 2007 —
// see the project's cot_backtest.py for the methodology): the edge is weak
// everywhere (correlations ~0.1-0.25, hit rate ~50-62%) and only shows up
// at 13-26 week horizons — a week's positioning change alone (COT "flow")
// carried essentially no signal at any horizon. More importantly, the
// SIGN flips by market: high Non-Commercial positioning led further
// upside in Gold and EUR (momentum) but preceded reversals in GBP and
// S&P 500 (contrarian), and USDJPY showed almost no relationship either
// way — so no single mode/threshold is a universal buy/sell rule. Trend
// and Relative (52w) had the most consistent DIRECTION across markets
// (4-5 of 5 agreed) despite a smaller edge; Excel and Absolute had the
// LARGEST edge but only agreed in direction on 3 of 5 markets — Gold
// being the standout, where Absolute/Excel-style %Long reached its
// strongest and most consistent reading (r≈0.32-0.37 at 13 weeks). Bottom
// line: read this as slow positioning context to combine with other
// analysis, not a standalone timing trigger — and interpret its direction
// per market rather than assuming one universal rule.
// Coverage (CFTC codes sourced from public CFTC filings and cross-checked
// across independent sources; EUR and Gold's Non-Commercial/Commercial
// symbols were additionally confirmed live on a chart — everything else
// shares the same code and suffix pattern but isn't individually
// re-verified against TradingView's own symbol search):
//   Currencies: EUR GBP JPY AUD NZD CAD CHF
//   Metals/ags: Gold Silver Copper Palladium Platinum Wheat(SRW) Cotton
//     Corn Soybeans Sugar Coffee Cocoa Live Cattle — matched on futures
//     root (GC/SI/HG/PA/PL/W/CT/ZC/ZS/SB/KC/CC/LE) or, for spot/CFD gold
//     and silver charts (XAUUSD, XAGUSD), on basecurrency XAU/XAG
//   Energy: WTI Crude Oil (CL), Natural Gas (NG)
//   Rates: 2-Year Treasury Note (ZT), 10-Year Treasury Note (ZN)
//   Index/other: Nikkei 225, S&P 500 (ES), Nasdaq-100 (NQ), Dow (YM),
//     Russell 2000 (RTY), VIX (VX), US Dollar Index (DX), Bitcoin (BTC)
// Still uncovered on a chart (5-Year Treasury Note, 30-Year Bond, Soybean
// Meal, Ether, and anything not listed above) has no auto match — a CFTC
// code for these wasn't confirmed clearly enough this round to be worth
// guessing at (a wrong-but-valid code would silently plot the wrong
// market's COT data, which is worse than no match at all). When a market
// isn't covered, this script does NOT silently fall back to whatever is
// in the manual inputs either, for the same reason — it shows a gray "no
// COT match" label instead. Turn auto-detect off and set the manual
// symbols yourself to use either of these anyway.
// Re-verifying or adding a market: TradingView symbol search
// "<CFTC code>_F_N" lists that market's Non-Commercial variants, "_F_C"
// its Commercial ones.
indicator("COT Cloud", overlay = true, max_lines_count = 500)

// --- Inputs ---------------------------------------------------------------
grp_data = "COT data"
autoDetect    = input.bool(true, "Auto-detect market from chart symbol", group = grp_data, tooltip = "Uses the table in the script header. Turns itself off for any market not in that table, falling back to the manual symbols below.")
nc_long_sym   = input.symbol("099741_F_NCP_L", "Manual Non-Commercial Long (fallback)",  group = grp_data, tooltip = "Used when auto-detect is off, or the current chart's market isn't in the auto table. Default is EUR (verified working). No exchange/provider prefix — the bare code resolves, 'COT:' or 'CFTC:' throws 'invalid symbol'.")
nc_short_sym  = input.symbol("099741_F_NCP_S", "Manual Non-Commercial Short (fallback)", group = grp_data)
comm_long_sym  = input.symbol("099741_F_CP_L", "Manual Commercial Long (fallback)",  group = grp_data)
comm_short_sym = input.symbol("099741_F_CP_S", "Manual Commercial Short (fallback)", group = grp_data)

grp_calc = "COT index"
position  = input.string("Non-Commercial", "Position", options = ["Non-Commercial", "Commercial", "Difference"], group = grp_calc, tooltip = "Non-Commercial / Commercial: that side's Long-Short. Difference: Non-Commercial net minus Commercial net, matching the workbook's Difference column — always colored with the Excel scale below, since there's no single Long/Short pair to read a trend from.")
colorMode = input.string("Auto", "Color by", options = ["Auto", "Excel", "Trend", "Absolute", "Relative"], group = grp_calc, tooltip = "Auto: backtest-picked mode per market (Absolute for Gold, Trend elsewhere, Excel for Difference) — see the script header for the findings behind this. Excel: reproduces the workbook's own conditional-formatting color scale on its Net Position / Difference columns. Trend: green/red by which leg dominates vs its own 13W average, blue when both are cooling. Absolute: %Long of total this week. Relative: percentile of net within its own trailing Lookback window.")
lookback   = input.int(52, "Lookback (weeks, Relative mode only)", minval = 4, group = grp_calc, tooltip = "52 = 1yr percentile, matching nc_idx_52w in the COT Pulse pipeline. Use 156 for the 3yr view.")
historyLen = input.int(1043, "History window (weeks, Excel mode only)", minval = 52, group = grp_calc, tooltip = "How far back the Excel color scale looks for its min/50th-percentile/max anchors — the workbook scans its whole column (~20 years of weekly data). Lower this if the market's history is shorter.")

grp_look = "Cloud look"
bandPct    = input.float(1.5, "Cloud width (% of price)", minval = 0.1, step = 0.1, group = grp_look) / 100
maxOpacity = input.int(70, "Cloud opacity at extremes (0-100, low = solid)", minval = 0, maxval = 100, group = grp_look)
minOpacity = input.int(92, "Cloud opacity at neutral (50)", minval = 0, maxval = 100, group = grp_look)

// --- Auto-detect table (syminfo.* is available immediately, no bar needed) -
// One CFTC code per market — the Legacy report's Non-Commercial/Commercial
// suffixes are uniform across financials and commodities, unlike the
// TFF/Disaggregated report split the previous version used.
base  = syminfo.basecurrency
quote = syminfo.currency
root  = syminfo.root
// CAD/CHF/JPY are conventionally quoted as USDxxx (base=="USD", the
// foreign currency is the QUOTE side) — EUR/GBP/AUD/NZD as xxxUSD (base
// is already the foreign currency). "fx" is whichever side isn't USD, so
// the same code branches below work for both quoting directions.
fx = base == "USD" ? quote : base
code = fx == "EUR" ? "099741" : fx == "GBP" ? "096742" : fx == "JPY" ? "097741" : fx == "AUD" ? "232741" : fx == "NZD" ? "112741" : fx == "CAD" ? "090741" : fx == "CHF" ? "092741" : root == "NIY" ? "240743" : root == "ES" ? "13874A" : root == "GC" ? "088691" : root == "SI" ? "084691" : root == "HG" ? "085692" : root == "PA" ? "075651" : root == "PL" ? "076651" : root == "W" ? "001602" : root == "CT" ? "033661" : root == "ZC" ? "002602" : root == "ZS" ? "005602" : root == "SB" ? "080732" : root == "KC" ? "083731" : root == "CC" ? "073732" : root == "LE" ? "057642" : root == "CL" ? "067651" : root == "NG" ? "023651" : root == "ZT" ? "042601" : root == "ZN" ? "043602" : root == "NQ" ? "209742" : root == "YM" ? "124603" : root == "RTY" ? "239742" : root == "VX" ? "1170E1" : root == "DX" ? "098662" : root == "BTC" ? "133741" : fx == "XAU" ? "088691" : fx == "XAG" ? "084691" : na
// CFTC quotes CAD/CHF/JPY futures as the foreign currency vs USD, the
// opposite of how USDCAD/USDCHF/USDJPY charts read — swap long/short so a
// positive net still means "bullish USDxxx", matching contracts.py. This
// is really about the CHART's own orientation (is USD the base side?),
// not about which specific currency it is.
autoSwap = base == "USD"
autoLabel = fx != "" ? fx : root

haveAuto        = autoDetect and not na(code)
coverageMissing = autoDetect and na(code)
// Only Gold gets a special-cased Auto mode below — it's the only market the
// backtest actually singled out as behaving differently (a clear, consistent
// momentum edge). Extending that guess to Silver/Copper/etc. without testing
// them would be exactly the kind of unverified claim this script tries to avoid.
isGoldMarket = haveAuto and (fx == "XAU" or root == "GC")

ncLongSym   = haveAuto ? code + "_F_NCP_L" : nc_long_sym
ncShortSym  = haveAuto ? code + "_F_NCP_S" : nc_short_sym
cpLongSym   = haveAuto ? code + "_F_CP_L"  : comm_long_sym
cpShortSym  = haveAuto ? code + "_F_CP_S"  : comm_short_sym

// --- Fetch weekly CFTC data -------------------------------------------------
// Always called (Pine requires request.* calls unconditional), but only
// the pair matching "Position" ends up driving the cloud.
raw_nc_long  = request.security(ncLongSym,  "W", close, lookahead = barmerge.lookahead_off)
raw_nc_short = request.security(ncShortSym, "W", close, lookahead = barmerge.lookahead_off)
raw_cp_long  = request.security(cpLongSym,  "W", close, lookahead = barmerge.lookahead_off)
raw_cp_short = request.security(cpShortSym, "W", close, lookahead = barmerge.lookahead_off)

nc_long  = haveAuto and autoSwap ? raw_nc_short : raw_nc_long
nc_short = haveAuto and autoSwap ? raw_nc_long  : raw_nc_short
cp_long  = haveAuto and autoSwap ? raw_cp_short : raw_cp_long
cp_short = haveAuto and autoSwap ? raw_cp_long  : raw_cp_short

nc_net     = nc_long - nc_short
cp_net     = cp_long - cp_short
difference = nc_net - cp_net

isDifference = position == "Difference"
activeLong  = position == "Non-Commercial" ? nc_long  : position == "Commercial" ? cp_long  : na
activeShort = position == "Non-Commercial" ? nc_short : position == "Commercial" ? cp_short : na
activeNet   = position == "Non-Commercial" ? nc_net   : position == "Commercial" ? cp_net   : difference

// "Auto" resolves to a concrete mode up front so everything below just reads
// resolvedMode — Excel for Difference (the only mode a pure difference can
// use), Absolute for Gold, Trend for every other covered or manual market.
resolvedMode = colorMode == "Auto" ? (isDifference ? "Excel" : isGoldMarket ? "Absolute" : "Trend") : colorMode

// --- Excel mode: reproduce the workbook's own colorScale rule -------------
// [min, 50th percentile, max] over History window -> [red, white, green],
// piecewise-linear by value between anchors (Excel's percentile anchor,
// not a plain min/max midpoint) — plus a sign-colored border, mirroring
// the workbook's separate font-color rule (negative/positive).
// ta.highest/lowest/percentile count CHART bars, not weeks — on a Daily
// chart "1043" would span ~1043 days (~4yr), not 1043 weeks (~20yr) like
// the workbook. Re-running the stat through request.security() on "W"
// resamples activeNet onto its own real weekly bars first, so the window
// means the same number of weeks on any chart timeframe.
p50Excel = request.security(syminfo.tickerid, "W", ta.percentile_linear_interpolation(activeNet, historyLen, 50), lookahead = barmerge.lookahead_off)
hiExcel  = request.security(syminfo.tickerid, "W", ta.highest(activeNet, historyLen), lookahead = barmerge.lookahead_off)
loExcel  = request.security(syminfo.tickerid, "W", ta.lowest(activeNet, historyLen), lookahead = barmerge.lookahead_off)
belowP50 = activeNet <= p50Excel
segLo    = belowP50 ? loExcel : p50Excel
segHi    = belowP50 ? p50Excel : hiExcel
excelColor    = segLo == segHi ? color.white : color.from_gradient(activeNet, segLo, segHi, belowP50 ? color.rgb(248, 105, 107) : color.white, belowP50 ? color.white : color.rgb(99, 190, 123))
excelBorder   = activeNet < 0 ? color.rgb(165, 0, 33) : color.rgb(0, 116, 52)
excelIntensity = segLo == segHi ? 0.0 : math.min(math.abs(activeNet - p50Excel) / math.abs(segHi - segLo) * 100.0, 100.0)

// --- Absolute / Relative (Non-Commercial or Commercial only) -------------
// Same chart-bars-vs-weeks issue as Excel mode above — hiRel/loRel go
// through the "W" resample too so Lookback means real weeks.
pctLong = (activeLong + activeShort) == 0 ? 50.0 : activeLong / (activeLong + activeShort) * 100.0
hiRel = request.security(syminfo.tickerid, "W", ta.highest(activeNet, lookback), lookahead = barmerge.lookahead_off)
loRel = request.security(syminfo.tickerid, "W", ta.lowest(activeNet, lookback), lookahead = barmerge.lookahead_off)
pctRelative = hiRel == loRel ? 50.0 : (activeNet - loRel) / (hiRel - loRel) * 100.0

// --- Trend (Non-Commercial or Commercial only) ----------------------------
// "13-week average" only means 13 weeks if ta.sma runs on real weekly
// bars — same "W" resample fix as above, applied to every lookback here.
longAvg13   = request.security(syminfo.tickerid, "W", ta.sma(activeLong, 13), lookahead = barmerge.lookahead_off)
shortAvg13  = request.security(syminfo.tickerid, "W", ta.sma(activeShort, 13), lookahead = barmerge.lookahead_off)
bothCooling = activeLong < longAvg13 and activeShort < shortAvg13
netAvg13    = request.security(syminfo.tickerid, "W", ta.sma(activeNet, 13), lookahead = barmerge.lookahead_off)
devAbs      = math.abs(activeNet - netAvg13)
devScale    = request.security(syminfo.tickerid, "W", ta.highest(devAbs, lookback), lookahead = barmerge.lookahead_off)
skew        = devScale == 0 ? 0.0 : devAbs / devScale * 100.0
longDominant = activeNet >= netAvg13
coldAbs   = math.max(longAvg13 - activeLong, 0) + math.max(shortAvg13 - activeShort, 0)
coldScale = request.security(syminfo.tickerid, "W", ta.highest(coldAbs, lookback), lookahead = barmerge.lookahead_off)
coldPct   = coldScale == 0 ? 0.0 : coldAbs / coldScale * 100.0
coldColor = color.from_gradient(coldPct, 0, 100, color.new(#a9d6f5, 0), color.new(#0a2a5e, 0))
trendColor = bothCooling ? coldColor : longDominant ? color.from_gradient(skew, 0, 100, color.white, color.green) : color.from_gradient(skew, 0, 100, color.white, color.red)
trendState = bothCooling ? "COOLING" : longDominant ? "LONG" : "SHORT"
trendIntensity = bothCooling ? coldPct : skew

// --- Pick the active mode --------------------------------------------------
useExcel = isDifference or resolvedMode == "Excel"
idx = resolvedMode == "Absolute" ? pctLong : resolvedMode == "Trend" ? trendIntensity : resolvedMode == "Excel" ? excelIntensity : pctRelative

gradColor  = useExcel ? excelColor : resolvedMode == "Trend" ? trendColor : idx >= 50 ? color.from_gradient(idx, 50, 100, color.white, color.green) : color.from_gradient(idx, 0, 50, color.red, color.white)
lineColor  = useExcel ? excelBorder : gradColor
opacity    = useExcel ? math.round(minOpacity - excelIntensity / 100 * (minOpacity - maxOpacity)) : resolvedMode == "Trend" ? math.round(minOpacity - trendIntensity / 100 * (minOpacity - maxOpacity)) : math.round(minOpacity - math.abs(idx - 50) / 50 * (minOpacity - maxOpacity))

// --- Extreme reading (top/bottom 20% of idx) — the backtest's quintile
// spread (avg forward return in the top 20% of a reading minus the bottom
// 20%) was consistently the widest gap in the data, i.e. this is where
// whatever edge COT positioning has actually concentrates. Direction still
// depends on the market (see header) — this only flags "pay attention",
// it does not assert which way.
isExtreme = not coverageMissing and (idx >= 80 or idx <= 20)

// --- Cloud around price (na when the market isn't covered, so nothing
// draws instead of silently showing another market's COT data) -----------
upperBand = coverageMissing ? na : close * (1 + bandPct)
lowerBand = coverageMissing ? na : close * (1 - bandPct)

upperPlot = plot(upperBand, "Upper", color = lineColor, linewidth = 1)
lowerPlot = plot(lowerBand, "Lower", color = lineColor, linewidth = 1)
fill(upperPlot, lowerPlot, color = color.new(gradColor, opacity), title = "COT cloud")

// --- Readout ---------------------------------------------------------------
posAbbrev = position == "Non-Commercial" ? "NC" : position == "Commercial" ? "COMM" : "DIFF"
cotText = useExcel ? posAbbrev + " " + str.format("{0,number,#}", activeNet) : resolvedMode == "Trend" ? posAbbrev + " " + trendState + " " + str.format("{0,number,#}", trendIntensity) : posAbbrev + " " + str.format("{0,number,#}", idx)
labelText = coverageMissing ? "No auto COT match for " + (fx != "" ? fx : root) + " — set manual symbols" : cotText + (haveAuto ? " [" + autoLabel + "]" : " [manual]") + (isExtreme ? " ⚠" : "")
labelColor = coverageMissing ? color.gray : gradColor
labelY = coverageMissing ? close : upperBand
var label idxLabel = na
label.delete(idxLabel)
idxLabel := label.new(bar_index, labelY, labelText, style = label.style_label_down, color = color.new(labelColor, 20), textcolor = coverageMissing or useExcel or resolvedMode == "Trend" or idx > 60 or idx < 40 ? color.white : color.black, size = size.small)

plotshape(isExtreme ? lowerBand : na, "Extreme reading", style = shape.triangleup, location = location.absolute, color = color.new(color.orange, 0), size = size.tiny)
alertcondition(isExtreme and not isExtreme[1], title = "COT Cloud — extreme reading", message = "COT positioning entered the top/bottom 20% zone — check direction against the market before acting (see indicator notes).")

plot(idx, "COT Index", display = display.data_window)
plot(activeLong, "Active Long", display = display.data_window)
plot(activeShort, "Active Short", display = display.data_window)
plot(activeNet, "Active Net", display = display.data_window)
plot(nc_net, "Non-Commercial Net", display = display.data_window)
plot(cp_net, "Commercial Net", display = display.data_window)
plot(difference, "Difference (NC - Comm)", display = display.data_window)
````
