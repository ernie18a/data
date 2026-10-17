# Senbonzakura - Close Probability Curves & the Fed Path

- url: https://www.tradingview.com/script/4e8AlG3y-Senbonzakura-Close-Probability-Curves-the-Fed-Path/
- type: indicator
- pine_id: PUB;10d812c09fc041dd9fce4c293b7a498a
- version: 3.0

## Description

[image]https://www.tradingview.com/x/K1yU3GAq/[/image][image]https://www.tradingview.com/x/8PX1y65r/[/image][b]Senbonzakura[/b] draws two probability distributions. [b]Kageyoshi[/b] shows where today's close is likely to land on Nasdaq, S&P and Russell futures, as sideways curves to the right of price: a historical curve from eight years of 1-minute data next to the curve the options market implies. [b]Senkei[/b], in the indicator's pane, shows the Fed path the market prices from 30-day fed funds futures, meeting by meeting. [i]Both are maps of how far things usually travel, not calls on direction.[/i]
 
Inspired by Interactive Brokers' Probability Lab (the Probability Distribution Builder in TWS), which sets your own distribution beside the market-implied one, and by CME Group's FedWatch Tool, which turns fed funds futures into FOMC odds. Senbonzakura is written from scratch and is not affiliated with either company.
 
 
[b]KAGEYOSHI · WHERE TODAY'S CLOSE LANDS (PRICE CHART)[/b]
 
• [b]Pink bars, historical:[/b] for every trading day Jan 2018 – Oct 2026, the close minus the price at each half hour from 18:00 ET, measured in ADR20 (the average high − low of the previous 20 days). The script takes the current half hour's distribution, scales it to today's ADR20 and centres it on the last price. The curve narrows as the day runs out.
• [b]Blue bell, options-implied:[/b] VIX for ES, VXN for NQ, RVX for RTY. One day's move is the index ÷ √252, spread through the day by the share of the day's variance still ahead (measured from the same data). It is drawn as a lognormal around price.
• [b]Bands:[/b] the historical 25–75% (thick) and 10–90% (thin) ranges, the historical median (dashed), and the implied 10–90% range (blue).
• [b]Close:[/b] the CME trading day's close (17:00 ET, the daily candle) or the RTH close (16:14 bar). After the close, and while the market is shut, the curves show the next session from the last price.
• [b]Header:[/b] the chance of closing up, both 80% ranges, how much wider the implied curve is, the context multiplier, and the four levels below.
 
 
[b]MARKET STRUCTURE[/b]
 
The prior day's high and low ([b]PDH[/b], [b]PDL[/b]), the month's open ([b]MO[/b]) and the all-time high ([b]ATH[/b]) are drawn across the curves. Each carries the odds of the close finishing beyond it, historical / implied, e.g. [i]PDH ▲35 / 37%[/i]. Their colour and line width are adjustable.
 
Where price sits against these levels changes [b]how far[/b] the close usually lands, not [b]which way[/b]. The four were fitted together, and only effects with p < 0.05 that sat on the same side in both 2018–24 and 2025–26 are applied:
• [b]below PDL:[/b] wider, ×1.13–1.30;
• [b]under the month's open:[/b] wider, ×1.05–1.19 for each ADR below it (capped at 3 ADR);
• [b]above PDH:[/b] narrower, ×0.84–0.90 (NQ from 09:30, ES from 12:00);
• [b]over the month's open:[/b] small effects, narrower on ES overnight (×0.93 per ADR) and slightly wider on NQ in the afternoon (×1.05);
• [b]within half an ADR of the ATH after 12:00:[/b] narrower, ×0.87 (NQ, ES).
RTY keeps only the PDL and month's-open effects. Shifts in direction did not hold anywhere, so the centre of the curve is never moved.
 
 
[b]SENKEI · THE FED PATH (PANE)[/b]
 
• Seventeen monthly [b]CBOT 30-day fed funds futures[/b] are read live. Each settles to 100 − the month's average effective fed funds rate. A decision takes effect the next day, so a meeting on day d of an N-day month splits the month d / N − d. Meetings are chained the way CME FedWatch does it, then combined as a probability tree.
• [b]Checked against CME's own FedWatch page for 12 Oct 2026:[/b] within 0.06 percentage points for every meeting shown.
• [b]Right of the last bar:[/b] one column per upcoming meeting, with a block for each 25bp target range shaded by its odds, the expected path through the columns, and a headline such as [i]28 OCT · HOLD 78%[/i].
• [b]Left of the last bar:[/b] the expected rate after each of the next six meetings, worked out bar by bar, so you can see how the market's path has moved. A line's colour matches its date under the columns.
• [b]◆ Fed dots:[/b] the median year-end rate from the Fed's dot plot (Summary of Economic Projections), beside each year's last meeting. The market's gap to it is shown under the column.
 
 
[b] WHAT THE TESTS SHOWED[/b]
 
• [b]Calibration:[/b] curves built on 2018–24 and checked on 2025–26, with context. The 80% band caught [b]82–84%[/b] of closes across NQ, ES and RTY.
• [b]Context fixes the drawdown days:[/b]
  – below PDL, the 80% band went from 73% to [b]79%[/b] of closes on NQ and from 70% to [b]76%[/b] on ES;
  – far under the month's open, from 70% to [b]78%[/b] on NQ and from 67% to [b]76%[/b] on ES.
• [b]Implied vs what followed:[/b] on ES the VIX curve ran [b]1.3×[/b] wider than the historical one at the open and [b]1.55×[/b] by 14:00. Its 80% band held 90% of closes. That is the volatility risk premium: options usually price in more movement than arrives. VXN and RVX were not back-tested.
• [b]Shape:[/b] real closes bunch near the price more than a bell does, with fatter tails, most of all in the afternoon. That is why the pink and blue curves differ in shape as well as width.
• [b]Drift:[/b] NQ's median close sits about 0.07 ADR above the 18:00 price, the carry drift of an index future.
 
 
[b]LAYOUTS[/b]
 
[b]Full[/b] shows every label, up to ten Fed meetings and long curves.
[b]Mobile[/b] (Hakuteiken) folds everything for a phone screen:
• curves 26 bars long with 24 bins;
• a three-line header;
• short level labels;
• five Fed meetings in narrower columns, with month-only dates and the ◆ gap under year-end columns.
Full wording stays in the tooltips. Chart layouts sync across devices, so use a separate layout on the phone with [i]Layout = Mobile[/i].
 
 
[b]HOW TO USE[/b]
 
• Built for [b]NQ / MNQ[/b], [b]ES / MES[/b] and [b]RTY / M2K[/b] (continuous or front month). Other symbols use NQ statistics and the header says so.
• Kageyoshi suits 1 to 60-minute charts. Senkei works on any timeframe.
• Switch Senkei off to keep only the curves on the price chart; the pane can then be made small.
• Bar replay works: "now" never runs past the last bar.
 
 
[b]DATA AND METHOD[/b]
 
• 1-minute data, Jan 2018 – Oct 2026 (ES to Aug 2026): 2,041 NQ, 2,117 ES and 2,157 RTY complete trading days.
• [b]ADR20[/b] = mean (high − low) of the previous 20 trading days. The next-session curve includes the day just finished.
• Higher-timeframe values use the [1] offset with lookahead on (completed days only). The day's high and the month's open are read only on the last bar.
• The all-time high is TradingView's highest daily high before today, plus today's high so far.
• FOMC dates are loaded to Dec 2027; add new years in S_FOMC. Update the dot-plot inputs after each SEP (March, June, September, December).
• Data requests: 17 ZQ months plus 5 others, out of the 40 allowed.
 
 
[b]WHY THE NAMES[/b]
 
Senbonzakura, Byakuya's blade, scatters into a thousand petals. [b]Kageyoshi[/b], its bankai, is the full spread of outcomes. [b]Senkei[/b] lines the blades up in rows, as the Fed's meetings line up in columns. [b]Hakuteiken[/b] folds every blade into one sword, the mobile layout. Part of the Hueco Mundo collection.

 
[b]LIMITATIONS[/b]
 
[i]These are historical frequencies and market-implied odds, not guarantees or signals.[/i]
• The implied curve is a lognormal with no skew.
• FOMC, CPI and NFP days usually run wider than the all-days curve.
• TradingView delays CBOT and CBOE data without the matching subscriptions. When ZQ contracts are missing or stale, Senkei can differ from CME's page.
• Nothing here is financial advice.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Senbonzakura · the distribution of what comes next, in two forms.
// Kageyoshi (price chart): where today's close is likely to land, as sideways curves right of price for ES, NQ and RTY.
//   Pink bars, historical: every trading day Jan 2018 – Oct 2026 (ES to Aug 2026) on 1-minute data, the close minus the
//   price at each half hour from 18:00, in units of the prior 20 days' average range (ADR20), scaled to today's ADR20 and
//   centred on the last price, so the curve narrows as the day runs out. Blue bell, options-implied: VIX (ES), VXN (NQ) or
//   RVX (RTY) ÷ √252 for one day, spread through the day by the share of the day's variance still ahead, lognormal.
//   Market structure: below the prior day's low or under the month's open the close usually lands further away; above
//   the prior day's high or at the all-time high, nearer. The historical curve's width is scaled by the effects that held
//   (p < 0.05, same side in 2018–24 and 2025–26); direction held nowhere, so the centre is never moved. PDH, PDL, the
//   month's open and the ATH are drawn across the curves with the odds of the close finishing beyond each.
//   Tested: built on 2018–24 and checked on 2025–26, the historical 80% band held 83–84% of closes; with context the
//   below-PDL days went from 73% to 79% (NQ) and 70% to 76% (ES). On ES the VIX curve ran 1.3–1.5× wider than what followed.
// Senkei (this pane): the Fed path the market prices, from CBOT 30-day fed funds futures (ZQ) with CME FedWatch's steps
//   (checked on CME's page for 12 Oct 2026: within 0.06 percentage points). Left of the last bar, the expected rate after
//   each of the next six meetings, bar by bar; right of it, a column per meeting with a block for each 25bp target range
//   shaded by its odds, the expected path, and the Fed's year-end dot-plot medians (◆).
// Layout: Desktop, or Mobile (Hakuteiken: every blade folded into one) for a phone screen.
// Keep up to date: FOMC dates are loaded to Dec 2027; the dot-plot inputs change with each SEP. TradingView delays CBOT
// data without a subscription. A map of how far things usually travel, not a call on direction. Part of the Hueco Mundo
// megazord. Written from scratch; Kageyoshi's idea after options probability-distribution tools.

indicator("Senbonzakura", "Senbon", overlay = false, precision = 3, max_boxes_count = 500, max_lines_count = 40, max_labels_count = 150, max_polylines_count = 6)

TZ = "America/New_York"

// ═══════════════════════════════════════════════════════════════ Inputs
grpG   = "View"
paneI  = input.string("Senkei · Fed path", "Pane", options = ["Senkei · Fed path", "Empty"], group = grpG, tooltip = "Senkei: the Fed path the market prices, meeting by meeting. Empty: keep only the curves on the price chart; the pane can then be made small.", display = display.none)
themeI = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = grpG, tooltip = "Auto follows the chart background.", display = display.none)
layI   = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = grpG, tooltip = "Desktop: every label, ten Fed meetings, long curves.\nMobile (Hakuteiken): every blade folded into one for a phone screen. Shorter curves and fewer bins, five Fed meetings in narrower columns, short labels and a three-line header; the full wording stays in the tooltips.", display = display.none)
txtI   = input.string("Small", "Text", options = ["Tiny", "Small", "Normal"], group = grpG, tooltip = "Mobile always uses tiny text.", display = display.none)
showK  = input.bool(true, "Price chart: Kageyoshi (where today's close lands)", group = grpG, display = display.none)
showS  = paneI == "Senkei · Fed path"

grpF  = "Kageyoshi · forecast"
tgtI  = input.string("Trading day (17:00)", "Close", options = ["Trading day (17:00)", "RTH (16:14)"], group = grpF, tooltip = "Which close the curves forecast: the CME trading day's (the daily candle, 17:00 ET) or the RTH close (the 16:14 bar). Between the close and the next 18:00 open, and when the market is shut, the curves show the next session from the last price.", display = display.none)
showH = input.bool(true, "Historical (2018–26 data)", group = grpF, inline = "f1", display = display.none)
showI = input.bool(true, "Options-implied", group = grpF, inline = "f1", display = display.none)
ivES  = input.symbol("CBOE:VIX", "Implied vol: ES", group = grpF, inline = "f2", display = display.none)
ivNQ  = input.symbol("CBOE:VXN", "NQ", group = grpF, inline = "f2", display = display.none)
ivRTY = input.symbol("CBOE:RVX", "RTY", group = grpF, inline = "f2", tooltip = "30-day implied volatility indices for the S&P 500, the Nasdaq-100 and the Russell 2000. One day = the index ÷ √252, spread through the day by the share of the day's variance still ahead.", display = display.none)

grpC   = "Kageyoshi · market structure"
ctxOn  = input.bool(true, "Scale the historical curve by context", group = grpC, tooltip = "Where price sits against the prior day's high and low, the month's open and the all-time high changes how far the close usually lands, not which way: below the prior day's low or under the month's open the day runs wider, above the prior day's high or at the all-time high it runs narrower. Only effects that held (p < 0.05, same side in 2018–24 and 2025–26) are applied; the multiplier shows in the header.", display = display.none)
showLv = input.bool(true, "PDH · PDL · monthly open · ATH", group = grpC, inline = "c1", display = display.none)
cLv    = input.color(#ffb300, "", group = grpC, inline = "c1", display = display.none)
wLv    = input.int(1, "Width", minval = 1, maxval = 5, group = grpC, inline = "c1", tooltip = "Drawn across the curves when they fall inside them, each with the odds of the close finishing beyond it: historical / implied. Colour and line width (1–5) alongside.", display = display.none)

grpL  = "Kageyoshi · layout"
offI  = input.int(6, "Offset", minval = 1, maxval = 100, group = grpL, inline = "l0", display = display.none)
lenI  = input.int(60, "Length", minval = 10, maxval = 300, group = grpL, inline = "l0", display = display.none)
nBin  = input.int(40, "Bins", minval = 15, maxval = 80, group = grpL, inline = "l0", tooltip = "Offset: bars from the last bar to the curves' base. Length: bars from the base to the most likely bin. Bins: across the 1–99% range of both curves. Mobile caps them at 3, 26 and 24.", display = display.none)
showB = input.bool(true, "Bands and median", group = grpL, inline = "l1", display = display.none)
showT = input.bool(true, "Header", group = grpL, inline = "l1", display = display.none)
cH    = input.color(#f06292, "Historical", group = grpL, inline = "l2", display = display.none)
cI    = input.color(#2962ff, "Implied", group = grpL, inline = "l2", display = display.none)

grpZ     = "Senkei · contracts and map"
fdRoot   = input.string("CBOT:ZQ", "30-day fed funds futures", group = grpZ, tooltip = "TradingView prefix of the monthly contracts. The script adds the month code and year (e.g. CBOT:ZQX2026) and reads seventeen calendar months, starting with the one before the current month.", display = display.none)
nAhead   = input.int(10, "Meetings", minval = 2, maxval = 10, group = grpZ, inline = "m0", display = display.none)
minP     = input.float(1.0, "hide blocks under %", minval = 0.0, maxval = 10.0, step = 0.5, group = grpZ, inline = "m0", tooltip = "One column per upcoming meeting. A block per 25bp target range, shaded by its odds after that meeting (the probability tree through every meeting before it). Blocks under this share are left out. Mobile shows five meetings.", display = display.none)
mOff     = input.int(8, "Offset", minval = 2, maxval = 60, group = grpZ, inline = "m1", display = display.none)
mGap     = input.int(10, "Column spacing", minval = 6, maxval = 30, group = grpZ, inline = "m1", tooltip = "In bars: the first column's distance from the last bar, and the distance between columns.", display = display.none)
cCl      = input.color(#ab47bc, "Cloud", group = grpZ, inline = "m2", display = display.none)
showPct  = input.bool(true, "Odds in blocks", group = grpZ, inline = "m2", display = display.none)
showPath = input.bool(true, "Expected path", group = grpZ, inline = "m2", display = display.none)
showBand = input.bool(true, "Current target range", group = grpZ, inline = "m3", display = display.none)
showHL   = input.bool(true, "History lines, last", group = grpZ, inline = "m4", display = display.none)
hBars    = input.int(3000, "bars", minval = 100, maxval = 5000, group = grpZ, inline = "m4", tooltip = "Lines for the next six meetings (as of now), each worked out on every one of the last N bars from that bar's ZQ prices. A line's colour matches its date under the columns.", display = display.none)

grpD    = "Senkei · Fed dots (Summary of Economic Projections)"
showDot = input.bool(true, "Show", group = grpD, inline = "d0", display = display.none)
sepAs   = input.string("16 Sep 2026", "as of", group = grpD, inline = "d0", display = display.none)
sepY    = input.int(2026, "Year-end medians from", minval = 2025, maxval = 2035, group = grpD, inline = "d1", display = display.none)
sep1    = input.float(4.125, "", step = 0.125, group = grpD, inline = "d2", display = display.none)
sep2    = input.float(4.125, "", step = 0.125, group = grpD, inline = "d2", display = display.none)
sep3    = input.float(3.875, "", step = 0.125, group = grpD, inline = "d2", tooltip = "The median federal funds rate the Fed's officials project for the end of the first year, the next and the one after (the dot plot). Drawn as ◆ beside the last meeting of each year, with the market's gap to it under the column. Update after each SEP.", display = display.none)

// ═══════════════════════════════════════════════════════════════ Layout and theme
bool mob  = layI == "Mobile"
int  offK = mob ? math.min(offI, 3) : offI                       // Kageyoshi: offset, length, bins
int  lenK = mob ? math.min(lenI, 26) : lenI
int  binK = mob ? math.min(nBin, 24) : nBin
int  nAh  = mob ? math.min(nAhead, 5) : nAhead                   // Senkei: meetings, offset, spacing, column half-width
int  offS = mob ? math.min(mOff, 4) : mOff
int  gxS  = mob ? math.min(mGap, 7) : mGap
int  hwS  = mob ? 3 : 4
bgLum = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
dark  = themeI == "Dark" or (themeI == "Auto" and bgLum < 128)
cTx   = dark ? #e6e9ef : #131722
cSub  = dark ? #9aa3b5 : #4a5163
cMu   = dark ? #5d6476 : #9aa1b2
cHot  = dark ? #ff8a65 : #d84315
cCold = dark ? #64b5f6 : #1565c0
cNeu  = dark ? #3a3f4b : #d1d4dc
cDot  = dark ? #ffffff : #131722
cBox  = dark ? #161a23 : #f4f6f9
txSz  = mob or txtI == "Tiny" ? size.tiny : txtI == "Small" ? size.small : size.normal
// one colour per upcoming meeting: Senkei's history lines and the dates under its columns
L1 = #e040fb
L2 = #ba68c8
L3 = #9575cd
L4 = #7986cb
L5 = #64b5f6
L6 = #4dd0e1
pf(float v) => str.tostring(v, format.mintick)
p0(float v) => str.tostring(v * 100, "0") + "%"

// ═══════════════════════════════════════════════════════════════ Kageyoshi · data
// Quantiles of (close − price at the half hour) ÷ ADR20, context-free (÷ the context multiplier around the median), for each half hour from 18:00 (46 rows × 23 levels: 1, 2.5, 5, 10,
// 15 … 90, 95, 97.5, 99%), every trading day Jan 2018 – Oct 2026 (ES to Aug 2026), ×1000. F_: the share of the full trading
// day's variance (mean squared return, 18:00 → 17:00 = 1000) still ahead at each half hour, for the implied curve.
Q_NQ_TD = ":&>HB8DzFzHRItK-L,LmMPN8O/OvPnQgR[SpTwV<X`Zf^w:G>{B<E(G*H^IoK.L)LuMNN7O(OhP`Q`RVS[TcV1XDZ9^8:1>[BIE7G1HeImK1L(LkMON5O$OoPcQWRPSWTjV-XIZ6^H9E>dB?E7G4HYI|K3K}LnMRN;NwOnP_QURPSPTaV3X2Z?^9"
     + "9g>KBREHG2HYIxK.K}LiMXN=NyOkPgQORJSDT^V&X0Z/^=90>CBOEDG4H_IzK+K|LfMYNAO!OnPaQJR=SHTKV$X-Z-]|9:>]BPETG<HaIyK(K{LjMZN8O$OjPSQHRDSETEV#WxYz]y9?>uBNEPG@HkI}K%K|LoM^N8O!OmP[Q@RES<T@UwWqYs^("
     + "9q>mB<EPGIHqJ%K.KxLmMYN<O#OjP[QGR8S4TDUrWvYk](9G>tB?E]GKHuJ/K%K|LkMPN8N}OgPXQER0S6TDUdWnYR]39i?9BZEaGPHuJ-K&KwLiMMN8O%OnPZQBR2S8T<UgWiYO]19Y?=BHEbGJHwJ)K$K~LgMNN:O%OiPNQ:R.S/T>UnW_YK]="
     + "9P?IBQEeGHHrJ&K!KwLjMQN5O(OnPHQ<R1S5TCUjWlYT]B9P?6BVEbGMH~J.K&KyLbMNN5O(OkPNQ8R3S6TDUdW`YW[{9N?9BEEfGQHwJ,K/KtLeMSN2O(OkPNQ>R1S0T8UhWTYT]!9p?!BPEfGMHrJ*K0L#LgMQN3O)OgPLQ;R/S/T8UUW_YP[^"
     + "9U?#BREpGQHuJ(K.K}LhMKN5O,OeP@Q8R'S-T:USWHYN[j:'>lB_EgGNHrJ0K6K{LjMSN3NuOZPDQ1Q|S&T9UQWYYM[h:$?/BrEjGNHnJ.K1KzLhMON4NuOSPCQ-Q~RsT6UPW`Yi[y:7@(C9EsGOH~J1K-K}LcMGN.NsOOP@Q)QuRkSqU?W^YQ[R"
     + ":r?qC>ElGXI,J/K3KqLcMEN#NrOTP@Q3QmRfS^U?WQY>[J;%@3C)ErGkI5J9K8L#LcMFN%NuOYP;P|QmRTSiU/W@Y4[Y;J@IC>E{GkI)J2K4L$L`M<N)NqOVP=Q#QgR^SlU!WEY>[c;T@:C:F'GxI+J/K4K}LeMDN)NgOPP<Q(QrR]ScU$W:Y9[n"
     + ";V@EC@F1GpI(J1K)K{LgMJN.NlORP=Q*QgRVSaU%W-Y#[1;Q@LCLF7GvI*J4K:L#LgMLN3NvOSP6Q$QnROS]T~W+Y=[R;q@OC@F:G{I1J<K0K|L[MJN&NmONP5P~QeRKSSTvW(Y0[4<*@^C=F5H-I-J8K*KpL^M<N#NnOPP0PwQaRISSTmVmXw[1"
     + "<0@^CMF<GuI=J8K,KsLaMFN+NnOPP4PsQcROSXTnVkXjZx<C@7CTF2G~I2J9K!KsL`MAN1NsOMP/PrQ[RNSRTrVjXRZr<>@QCPFDG~IGJ=K9L%LiMRN2NmOHP)PnQaRPSDTRVOX&Zf<b@2CWFFGxIBJ>K;L'LjMUN3NkOQP4PwQZRQSHTZVpX4Zx"
     + "=3A|DhG3HpI|JvKVL7LuMMN&N]O+OcPDQ(QeRWSiU_WKYs>JBhESG~IBJ7J~KZL=L{MON%NTO&O]P+PdQ<R%S6T}VXY3?-CFFAHKIYJLKAKwLRM0M^N%NKNwOEOyPRQ,QvRsTXV4XF@7D>FhHqIlJcKRL1L_M0MUM{NFNiO5OcP2P^Q?R:SiUkW|"
     + "B0EDGUI4JMK3KiL=LdM0MRMrN:N]O#OCOpPGPsQeRvTDVSBbEbG|IXJcKHL!LJLpM:MVMvN7NSNqO7OcP+PaQJRkT.UwCiF)H5IpJrKVL-LPLqM6MUMqN1NPNkO0OROuPJQ4RSS}UgD`FsH[J#K&KaL5LXLyM9MRMsN/NMNdN}OCO`P@PuR&SYUW"
     + "D.G<HpJOK;KoL<LYLyM3MMMfN$NAN[NuO4OSO~PcQbRjUDE2H!I]JnKPL!LBLbLzM0MKMdMwN4NHNaO!OCOmPEQDRZTYEIHoI~K.KdL)LELaLyM/MAMTMhM~N8NONiO%OGOyQ&R4SPG@IOJDKML$L@L[LnM&M8MHMVMgM{N0NCNXNqO3OaPNQARH"
     + "IhK0K|LSLiLzM)M4M<MDMNMUM]MeMnMzN&N2NBN]O2P'Q=KHL3L_L|M,M6M=MAMFMJMNMQMUMYM^McMgMnMwN&N>NkO["
Q_NQ_RTH = ":h>bBBE+G#HWIwK'L*LxMTN8O,OpPlQbRPSaTdV4X5ZU]y:_?*BGE/G3HXIuK/L&LoMQN;O&OkP^QTRMSQT]U}X-Y{^&:Z?<BQEGG1HVIyK0K~LmMRN4O!OmP_QPRHSJTRV!X/Yu^#:-?8B)E=G9H`IvK0KzLpMNN4NzOeP]QMRCSKTLV#W}Yr]s"
     + ":.>]BHEOG5H[IxK2L$LjMMN8NxOjP[QRRAS=TQU|WlZ#]J9f>sBCE9G<HdIvK/K|LbMUN=O$OjPYQGR6S=TEUnWpYl^)9`?(BOENGMHgI{K-K|LiMVN8O$OkPTQ@R5S3TBUdWfYb^-9s?6B<EPGKHlJ%K+K~LjMQN8O(OlPQQER8S0T8UUWXYD]i"
     + ":4?JBBESGSHoJ!K.L!LeMVN<O&OePXQ@R.S%T>UaWXY6]7:&?FB?EaGYHyJ-K%K~LjMPN7N{OcPOQ?R,S$T6UVWRY7]F:5?>BXEpGQH}J'J}K~LeMON8NxOhPRQ<R/S0T0USWNY;];:S?KB]EsGVI%J+J~K~LaMJN9O!OfPQQ;R)S$T.UQWCY8]-"
     + ":7?SB`EfGRH~J&J}KzLeMKN6N~OcPKQ?R,S'T-UZW?Y=](:N?MBhEnGYH}J&K'KxLdMIN6O!ObPQQ?R,S(T4UQW=YH[r:M?7BVEeG[HsJ-K&K|LbMJN1N}OdPNQ:R'S$T*UTW<Y?[^:O?QBjEuGRHvJ+K1L!LgMIN4O$ObPGQ:R)RzT'UJWBY/[L"
     + "9{?5BoEyG^H{J(K)L%LiMIN4O#OaPDQ5R#RuT3UHW5YB[K:;?UBjEuGZHzJ.K<K{LeMMN,NuOXPAQ-QtRpT%UBW:YH[1:V?]BlErGRHyJ6K0KwLeMGN1NsOTP@Q'QvRhSyU>W8YF[y9g?sC4EvGQI/J.K/KwLcMIN2NkOJP;Q%QkRVS`U:W3Y2[@"
     + ":^@DC2F(GcI1J3K0KwLaMBN*NkOTP8Q'QcR_SJU-W;Y)[C;'@MC7F$GlI5J;K7K{L`MEN'NoOTP;PxQdRNSQU#W*Xq[7<+@BC:F'GlI0J7K4K{L^M?N!NnOVP9PuQ`RKSPToW5XlZv<!@QC:F-GqI2J2K-K|LaMDN-NiOLP9P{QaRLSLThW4Xk[@"
     + ";d@WCNFAGrI7J1K+K}LgMHN/NmOKP7P~QYRISJTnW$XY[7;m@qCLFAGyI3J9K<L#LiMHN2NoONP8PzQXRGSCTrV}Xu[N<2A%CHF6H%I;J;K9L!LaMGN+NpOMP0PuQXRCS;TgVqXV[3<H@rC?F*H1I6J=K/KpL`MCN!NgOLP(PlQXR@S=T]VXXSZl"
     + "<[@nC[F2H,IBJ>K5KqL`MAN)NmOMP)PpQVRGSKTaVRX<Zw=%@tCfF?H+I;J8K)KxL^MEN3NoOLP(PmQORAS?TZVZX0Zr<|@}CNFMH)INJBK:L'LkMPN1NpOGP&PcQPR;S0TDVMWtZD<a@ZCLFOH*IDJEK8L)LjMNN0NpOKP(PkQIRFS<TLVLX/Zf"
     + "=5BEDrGLHoJ(JoKZL<LxMMN$NSO'OcP9PxQVRISIU<W.X}>OBkEpH3IPJ9J~K_LCLuMNN!NPO$OTO~PRQ0QqR{TvVCX]?]C^F^HOIeJWKMK}LQM.MWN!NJNnO<OoPCPzQ`RaTEUwWp@wDdG#HyI~JmKRL1LeM/MWMwN@NeO/OUO}PTQ.R,SXU9W%"
     + "C#EVGbIOJUK3KjLALjM2MSMrN6NXNvO8ObP8PhQKRcS~V9BzEtH+IkJmKKL!LKLsM6MUMtN3NONlO.OTP!PQQ7RHSgUGCpFVH;IzJyK]L1LRLvM6MNMhN*NDNeO&OJOmPBP{R6SOU'E(G<HiJ;K0KfL5LZL{M:MQMkN)NBN]NuO6OWP%PeQnRwTi"
     + "E6GPI&JYKAKrL9LaL~M7MLMdMzN6NPNjO(OHOmPFQGRJTTF9HGImJ|K^L$LFL_LxM7MMM`MvN-NBNZNtO5ORP)Q'R!SYGPI+J2K8KlL6LOLhM!M4MCMTMfMuN.NCN[NtO0O_P]QPRNHWIrJjK`L-LGL_LuM)M:MHMUMeMtN&N8NLNbN~OFP,PcQh"
     + "K'KqLCLeLvM%M-M5M>MCMJMQMXM_MfMmMwN$N0NCNgO8P1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Q_ES_TD = "8O=JAOD_F{HAIQJkKhL[MJN2O(P%P|QmRaSfU)VaY-Z}^U7T>:ATDgFuHDIZJ_K_LWMBN0O&OwPnQbRZSYToV_XqZ]]|7`>3AZDkFxHFIYJbKiLSMBN1N|OqPnQcRTSVTrVSXbZf^*8->-AJD{FuHLIbJlKkLYMHN.O!OuPpQaRSSSTsVKXUZH]a"
     + "7D>HAqE#FzHOI`JmKjLYMDN0NvOuPmQWROSLT]VDX`Za^,79>2AfE$F{HMIqJmKoL[MDN.O!OwPoQSRISLT`V6XTZb^27H>,AuE0F}HHIjJzKkLTM?N+N}OxPfQTRHSFTYV.X=Zb^07{>CAlE2G3HZIuJwKjLXM?N.N}P#PgQSRLSDTOU~X9ZZ^+"
     + "8w>aASE,G2H_IuJvKkLbMBN%N{P$PmQMR@S9TMUzX;ZR]P7~>;AeE-G+HeI~JrKmL`MDN$NrO{PkQKR@S8TFUwXBZ-]K8O><AhE;G0HjIxJtKiLWMBM~NyOyPkQMR@S9TCUxX>Z3]17p>MA]E3G.HmIyJwKkLUM@N%NyOvPaQJR7S3TBU{X3Z&]A"
     + "8&>sA^E;G(HjIzJtKhLYM=N(NxOwPXQHR7S5TLU}X-Y}]L81?'A`E8G/HwJ$JtKgLVM>N(N|OuPaQLR8S3TEUpX.Z']U8B>yAhE4G<HoI}JzKpLUM:N*NzOqP]QJR5S/T?UkX,Z0]S8l>eAgE-G3HpIuJxKrL_M:N*N{OzP_QOR8S'T=UsWnZ7]S"
     + "7o>5ApE.G0HiIsK'KzLZM9N(O!OqPbQGR1S-T=UZWgZ2]S80>0AoE7G/HdIsJ}KrLWM<N'N{OlPUQAR/S)T:UlW`Z#]87W=IB-E(G/HdIoK%KkLZM?N(NwOmP^QAR-S/TAUjWdZ9]L7R><B*E8G4HrJ)K#KgLXM@M~NrOgPQQ6R(S$T8UZWqY~]N"
     + "87>?BDEEGGHqJ!J{KlL_MAM~NlOdPTQ8R&RsT9USWmYr[g8K>QB:ERGJHyI{JyKvLaM@N&NlO`PDQ,Q{RmT&UBWsYl[x8w>fBAEVGFHlIuK#KqLhMEN*NoOZPJQ(QqRsT+UPWeYV[t93>yBTEfGZHpIwJ{KtL`MFN(NmOQP8Q&QiRoS~UJWGYH]!"
     + "9D>uBPEbGNHkI|JxKkLdMHN,NnORPDQ&QmRjSmU?WJY;[u9j?-BhEhGNHqJ'K)KwLYMFN2NkOXP@Q)QsReSrUDWAY<[p:)?PBWE`GQI#J#K$KnLPM?N)NkOIP6P~QhReSkU4W.Y,]79v?0BVEeGXHzIzJ{KkLOM?N(NoONP/P{QeRXSaU*W.X{[y"
     + "9y?-BnE_G^HzJ+K!KnLTM:N+NnOVP:Q'QkR[S]U'W+Y'[`:1?HBxElG_HzJ)K'KmLQM=N'NkOWP:Q#QoRSS]TtW!Xy[F:N>~BvF)GqHyJ*K,KyLdMNN-NeOGP8PxQZRJSOT]VgXU[O=8A,D/G$HPIkJkKNL;LpMNN(N[O5OtPTQ.QyRiSpUUWHY?"
     + "=9BLDpGOI%J8J}KdLALyMNM}NNN}OSP-PjQ>R$S(U(VsX6>8BuEdH9IEJEK:KpLHL|MKMzNENwODOuPFP~QlRjTAV5XC@/CoFiH[IiJ^KHL&LZM&MIMsN=NmO7O^P4PmQOROT0V$X7@fC|F|HnIyJwKYL6L_M(MNMmN6NXO&OMO~PYQ2R&S[U1WC"
     + "@rD>FdHzJ3JvKUL0LaM%MEMjN4NTO!OIOxPNQ(QsS?TQW&@8D`G&I;JIK0KnL=LeM+MNMoN-NPNtO:OhP=PpQfS'TBVP@NE;GbIOJIK7KvL?LfM-MQMnN.NKNmO2OVP%P^QGRvT#VDA`E~H$IlJ`KIL!LILoM0MNMnN/NLNhO)OKOvPHQ0RVS_Ui"
     + "BQF8HDJ&JyK[L0LRLoM.MJMeM}N?N_N{O:O_P3PyQ~S7USD5GRI=JMK.KgL0LNLnM*MCM]MyN1NLNfO)OLOtPWQlRnU;D{H:ImJeKCKrL8LSLkM%M<MSMhN#N;NYNrO3OWP1Q1RISzFUI+J2K0KgL,LJLcLyM.M@MSMiMzN/NINaNwO>OoPcQMRb"
     + "JDK0KfLELcLsM#M0M9MAMIMRM[MfMnMxN&N4NFNaO6OnPVK>L/LRLsM'M0M7M>MBMFMKMNMRMVM[MbMhMnMxN(NFNiO9"
Q_ES_RTH = "99>/ANDZFsHAI`JlKqLYMFN7O%O{PyQfRVSWTrVIXpZr^q9(>QAjDuFvHTI[JbKgLVMBN.O!OuPjQXROSPTZVRXTZU^67r>SAyDfFzHLIlJgKoLSMEN1O$OuPhQURPSJTZV?XOZN^088>VAqD}FtHYIdJnKoLTMHN/N~OwPhQPRFSHTVV8XQZ<]u"
     + "7~>BArE$G!HSIjJwKjLXM=N3O!OvPaQOR<SCTVV/XTZQ]v8d>[AwE-G&HQIiJyKoL]MAN3NyOxPiQJR?S<TNUyXCZJ^$8Q>_AnE@G*HYIlJ{KkL^MBN+NyO{PXQGR<S<TMUxX3ZH]y8[>aAoE8G2HhIwJvKoL[MBN0NzOrPdQIRCS5TOUpX4ZY]b"
     + "9.>|A`EAG3HmIyJuKsL]MDN,NyOxPaQIR6S5TDUnX,ZY]38r>YAiEDG1HiJ!J}KkLcMHN+NvOrP^QBR6S1T:UqX.Z@]797>FAwE@G8HrJ&JsKeLZMFN)NqOvPgQAR2S.T7UsW}Z-]48g>JAkEFG;HoJ)JsKfLTMBN#NrOwPaQCR(S(T5UoX+Z-]/"
     + "9/>sA`EFG9HmJ!JuKhLZMFN*NrOrPTQ@R+S.T<UpX$Z+]59*>tAjEEG@HxIzJwKhLYMEN-NyOpP[QGR)S*T6UiX$Z2]-9@>aA|E8G3HvI~J~KnLZM=N0NzOlPTQAR'S%T+U`WsZ-]49E>hA|E=G;HqIrK&KtL`M@N0N{OoPWQBR,R|T.U_WZZ0]6"
     + "8S>DB)E;GCHtIvK(KyLZMCN)NyOgP]Q;R#R~T5UYW^Z4]J9%>kA{EHGEHkInK$KvL_M@N'NxOaPNQ8QzR}T.UdWUZ+]38s>@AkE>G7H^I{JzKrLWM>N*NrOdPQQ8R'S)T+UeWVZ*]69D?$B)ERGDHsJ*K(KmL[MBN$NkOfPLQ6QyRnT0UWWaYp]."
     + "9n>rB*ESGXHrJ%K#KqLZM=M}NkOZPMQ8QxReT#UIWTYb[^9L>xB;EcGTI(I~J~KqL_MAN(NlO_PDP}QiR_SvU=WYYa[X:9?9BQEcGWHyI|J}KxL_MKN+NpOUP@Q$QfR_S~UBWRYD[_:8?JBfErGYH}IxJ{KrLUMBN.NjOGP9P~QdRcSuUAWFYD[_"
     + "9w?;B]ErGcHsJ$J}KqLYMJN,NnOMP=Q%QaR`SdU%WKY3[e:8?XB^EqGfHzJ%K'KrL[MDN3NoOOP<PyQhRUSnU)W/Xy[K:O?HBpEeG[I)J,K&KlLUM:N&NkOLP2PuQbR[S^U(W0X{[S:I?<BiEnG]I'J(J}KgLTM?N'NgOLP0PtQURRSdTvVyX^[7"
     + ":7?3BeEuGoI&J+K&KlLTM<N%NjOQP4PzQ^RRSVTlW$XrZt:E?DC,F#GlI(J/K%KiLVM?M~NmOQP5PyQ_RUSNTaVkXw[(:X?IBwF0H&I*J8K1L$LcMBN)NaOGP)PuQRRDSCTMVOXUZp<kA:D.G0HdIlJnKUL4LpMJMzNUO1OlPLQ0QnRaS_U>W2Y9"
     + ">'B1DvGhI.J<K)KeL@LzMLM|NIN|OSP*P_Q5QxRyT}VeX)>KB~E~HOIUJRK9KqLPLzMNMzNHNmO@OlP@PvQ_RXTGV#X&@DD)FfHhItJhKOL*LWM&MNMtN9NfO,O]P0PeQER=T)UDWh@sD8FoI'J+JwKaL4LcM(MIMlN4NVN~OFOuPMQ+QvSOU(Vl"
     + "AuDaFzI-J9K*K^L2L]M!MCMhN2NWNyO?OkPAP{QhS/T;Vy@zDuG@IBJIK5KoL:LjM*MNMoN/NKNjO4OeP/PeQKS!T'V2A4EcGkI]JYKAKzLGLmM+MIMhN&NFNgO.OQOzPMQ8RjSuUPBtFCH*IvJpKNK}LMLqM0MKMjN-NFNbNzO@OfP8Q!R>SKU&"
     + "D*FEH[J:K$K^L-LQLqM0MHMbM{N9NVNsO3OPP%PhQjS%U3E,GnIMJXK7KlL0LQLpM*MCM^M{N2NFN_NzOAObP=QPRLTkF.HkIxJsKRKvL8L[LpM+M>MPMgM~N5NLNeO!OEO{PqR.S_H#IRJLKBKoL4LMLfLzM2MAMRMdMvN)N>NRNnO.OUPNQ,RB"
     + "K;KnL5L[LpL}M*M2M;MCMJMQMXM`MhMoMyN'N5NGNiO,Ol~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
Q_RTY_TD = ";J>gA~E,FkH.I0J1K-L$LtMoN_OMP<Q1R3SHTYV#X9Zs^S;;>}B$E2FfH)I-J8K#KxLyMaNXOLP9Q,R!S6TWV#X=Zy^;;3?&B(E0FlH)I1J5K$K|LuMkNUOEP/Q+R*S5TQU}X=Zb^;;J>zAzE6FiH+I4J5K+L!LvMlN_OHP4P}R'S.TNU{X3ZI^>"
     + ";E>rA}EAFuH+I8J7K3K~LrMnNSOJP7Q&R*S(TMUoX0ZN^r;E>ZB'E1FtH8I@J:K1L!LvMjN_OLP5Q%QvS'T=UqW{Z7^];e>rB.E9FvH1ICJ=K7L!M!MgN]OKP;PyQ}R~T4UiW{Y}^Q;m>WB-E,F{H?IDJAK6K|M#MoN_OCP:Q(Q{RyT-UeWnYf^Q"
     + "<6>MB.E)G*H;I@J=K>L/M(MvNYOGP3Q#QuRwT%UYWdYu^T<R>EA|E&G,H:I<JAK9L'M(MwNYOHP9Q&QrRgS|UVWxYt^E;{>VB#E)G'H6I=J>K;L*M'MvN[OFP5P~QsRnT*UTWpZ%_%;Q>}B#E)G#H8I?JBK:L'M#MuN`OHP1P~QlRfT%URWiZ!^O"
     + ";c?!B&E)G,H<IBJGK/L*M%MrN^OGP.PzQmRlT3UNWkY~^s;f?%B#E5G!H?I>JBK7L+M/MrNZOAP/P{QmRlT'UMWwZ#^b<)?$B*E3G#H@IAJFK<L4M(MxNYO4P1PwQgRrT*UEWjZ(^A<5?3B2E#G$H?IDJAK;L4M(M|N]OCP.PyQbRjT+UIWXYy^E"
     + ";i?JB1D}G'H>IBJEK8L/M(MvN[OGP0PwQgRiT&U@WUYn^D;T?EB&E.G*HBIIJ@K:L-LxMmNSO@P1PuQ_RXT)U?WOYf^I<:?hBYELG(HRIWJKKDL.L~MoNSO@P+PsQXROSnU1WQYp^#<r@2BIEUG3HPIQJPKHL1L|MmNPOAP!PdQWRXSYTuW5YV]Y"
     + "<t@8BfESG7HRIQJYKFL/L|MjNWOCP'PhQRRSSVTqW+YQ]S<Z@DBhETGBHWIUJ]KCL1L}MgNWO5O{PjQMRESLT{W9YS]'<=@^BvETGKHPI]JYKIL2M$MoNTO1OyPhQMRCSJTfW&YA[t<B@dC(EgGDHXIcJTK@L;M!MgNIO,OkPeQFR9SKTdW)Y.]0"
     + "<^@aCDE[GJHYI_JXKKL9M#MdNFO)OjPWQER2S=T^W!Y7]1<>@zC@ElG?H[IcJYKJL9L~MbNKO%OhPXQGR5SCTiV}Y1]Z<Z@YC5EnGJH^IVJQKBL3LyM^N?O#OiP]QAR5S9TIVnXc]J<aA!C;EwGGHYI[JRKBL/LxMXN:NzObPWQ?R/S1TNVDXS[~"
     + "<A@FC<EsGNHZIfJZK9L,LuM_NAN|OZPTQBR+S1TQV>XP[t<_@{CSF#GMHdIjJOKFL/LsMWN>NuO`PHQ6R%S7TEVSXI[x=eA+CiF3G[HoImJVKIL0LcMLNBO#OYP?Q1QwS$T2VJX2[N=jAwD!FRG|I$I~JgKSL5LtMVN7NwO[P?Q!QnRgSvUrWeZr"
     + "?SB|E.GHHwIqJaKEK{LTM+MXN0NhOEOsPOQ*QuRvTpV[Xu@zCzF@H?IIJAJyK[L5LhM;MfN1N]O)O]P8PnQWRKSxUtWmAdDCF[HhInJ_K?KoLILsM?MiN3NYO'OOOzPJQ-R1S_U:V~BaEDFzI#J$JvKRL-L_M*MGMkN.NPNvO<ObP3PlQaRwTOV0"
     + "C!E}G{IOJRK8KmL9LbM%MBMbN$NANbO'OJOrPDQ1RKSeUAC.FTH/IiJfKIKuLALgM.MHMdN!N@NYNvO9O_P0PwR*S1U?C|FPHSJ1JuKTK~LGLlM)MCMZMvN3NRNrO4OTP&P_QfRbTID;G%HyJHK2KbL.LSLqM,MDM_MwN6NONjO&OFOqPLQ^ROS|"
     + "DPGaI=JQK;KlL8LULpM+MBM]MvN.NCN`NwO8OcP5Q5R(SaEOHQInJ{KXKzLBL]LwM/MEMZMmN&N<NPNfO&OMP!P`QGS!G-I8JHK<KhL.LJLbLyM.MAMQMdMvN+N=NTNnO2OYP<PzQpHyJ/J}KdL-LJL_LrM&M5MEMSMaMnM}N1NDNZNvO5OhPGQB"
     + "K%KgL9LYLpL}M+M7M?MGMNMTM]MeMlMuN!N-N:NMNpO0O`L#LKLeL|M*M1M9M>MCMGMKMNMSMWM]MaMgMmMuN!N6NPNk"
Q_RTY_RTH = ";:>LB,E-FhH$I2J3K-K}LvMmN_OOP>Q-R2SATMV!X2Zc^T;L>ZB7E-FqH!I1J+K*KvLsMiNUOIP1Q*R%S1TOU|X?[.^O;7>XB=E#FvH%I-J/K'K{LwMgNXOFP3Q'R)S3TCUuX/Zo^P;8>tA{E4FyH-I,J1K(L!LvMfN_OFP1P|R#S(TLUvX&ZM^>"
     + ";F>|B(E=F|H3I5J2K/L'LyMlNWOJP0Q#R,S*TFUbWyZI^t;E>KB)E7FpH;I8J8K1L'LtMqNVONP4Q#QwS#T1UfX$ZM^g;y>sA}E:F{H3I8J=K4L$M!MqNWOOP:P~QvS!T'UYWnZ5^b;j>oB,E;F{H>I>J8K8L%L{MuNaOKP8Q*QtR{T)UWW]Yp^^"
     + ";l>iAzE-G,H>I8J=K=L4M&MzN]OGP1Q$QxRzSxUSWaYw^n<.>fB)E)G.H>I5J?K7L+M+M|NZOIP7Q&QsRgSwUSWpZ!^j<(>tB)E/G(H9I7J=K9L-M'MzNXOGP=Q#QnRdS~UIWsZ/^~;v?,B)E'G'H:I=J=K8L.M'MzNZO?P3P~QpRgSyUHWhZ0^H"
     + "<>?)B3E2G.H<ICJ>K2L0M'MsN]OCP6PtQmRjSyUFWkZ5^m;r?3B6E6G'H<IEJCK1L2M)MrNYOCP4P{QmRlS|UEWsZ8^g<+?>B0E'G#H=I:JBK9L;M)MuNYO;P.PxQkRmS{U8WmZ)^><9?-B4E&G#H<IBJ9K>L;M&M{N`O?P4PyQhRfSwU9WMZ3^7"
     + ";w?BB)E,F{H:IBJ<K<L9M'MuNYOBP1PvQfR`SmU<WSZ&^F;z?NB(E*G%HCIHJCKAL1L{MpNUOCP.PtQ^RXS}U7WHZ+^M<T?iBPEKG8HRIVJPK>L2M$MmNNO8P)PlQYRLSeU&WFZ%^7=#@.BZESG9HOIJJLKLL9L}MkNOO=P$PdQORNS[TtW5Y|]d"
     + "=%@&BiENG>HIINJNK?L6L|MkNKO?P$PpQURESTTgW.Ya]a=$@HBpEYG<HOIWJNK@L9M$MfNTO7P!PhQMRCSDThW!YK]<<?@CByETGCHWIXJTKEL<M$MnNOO8O}PjQKR6S8TbW#YM]9<m@`C(EdG9H`IcJTKIL;M'M_NHO-OnP[QAR5S8T`V|YS]f"
     + "<u@RCKE]GDH^I[JYKKL<M%MbNDO(OiPYQDR8S3T[VfY?]P<o@mCGEpG;HaIaJYKHL=M$MdNIO&OlP`QDR0S5TaVlY*]o=(@oC9EoGGH]ISJSKAL6LyM[N>O(OhP[QDR.S$TNVaXj]m<t@fC7E}GGHTI]JOKCL+LvM[N:NyO]PSQCR)S%TGV;XS]d"
     + "<g@OC1E~GMH_IcJZKCL,LwMYNAO!OaPNQCR&S,TGV9XQ]8<|@{C_ExGPHmIfJXKBL*LtM]N@NzO[PFQ8Q|S,TCVFXV]9=)A-CbF.GYHoIsJYKLL-LfMTNAN|OVP;Q+QyR}T.V5X3[P=VAwD+FTGzH|J&JkKVL4LuMSN4NuOUP9Q$QjRkStUjW^Z}"
     + "?!C&E>GEI!IrJ^KAKrLQM*M^N,NdOBOyPMQ(QqRsTgVSY%@DCjFKH<ISJ>J}KZL2LcM8M`N/N]O*O^P0PgQORKSpUqWaB%DfF{HyIpJaK;KtLGLtM@McN,NUO*OQOuPFQ*Q~SXU$VzBxE4G$I%J/JxKWL-LXM(MHMmN-NQNtO7O]P.PfQ[R{T?Uf"
     + "CUF,G}IVJWK9KlL;LdM#MAMbM~N@N`O!OEOkPAQ*RESSU)CbF]H>IkJjKBKsLALhM,MIMfN%N=NYNsO<OZP,PlR!S&TjDMF`HaJ6J{KXL#LJLkM*MEM_MvN2NONqO0OTP#PWQ]RSTFDeG;I(JLK7KiL-LRLnM.MDM^MxN3NINcO&OEOgPBQFR5Sz"
     + "D|GjIKJWK>KsL;LXLsM/MFM[MrN,N?NXNsO0OWP-PxR+SYE~HcIvK/K[L'LCL_LuM,MFMZMmN!N4NKNcN{O>OlPUQCRZG%ILJMKHKsL1LNLiL{M0M?MNM_MoN&N8NMNgO%OKP,PaQhI9JIK2KqL4LMLbLtM'M6MCMQM_MlM{N-N;NPNkO*OZP+Q0"
     + "KkL?LULoL}M*M1M8M>MDMKMQMVM]MeMjMqM|N-N>NXNuO7~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
F_NQ_TD = "XBX2X)X!WvWhWYWEW&V|W$W!W(W$VmVeVcVVVGV!UsUlUdUaUVUJU=U9UBUCTnT]S=RVR/QRQ)PhPNO|O^O>NtNNMpMW"
F_NQ_RTH = "W~WoWdW^WTWFW9W(VgVaVhVfVmVgVOVGVDV9V+UbUWUOUGUDU9U-T}TxU&U'TRTBS#R:QsQ:PqPQP5ObOFO(N^N:M`~~"
F_ES_TD = "XBX/W{WpWiWVWJW9VsVgVoVpVvVrVVVHVIVGV;UuUiUiU]URUMU>U8U)U6U?T^TCSLRjRQQoQFQ&PkP=P%O`O)N_MiMW"
F_ES_RTH = "W{WiWUWJWDW1W(VvVTVJVUVWV^VUV7V)V)V'UwURUHUEU;U2U,TzTsTdTrT{T=T%S1RLR7QVQ2PnPQP#OjOINqNLM]~~"
F_RTY_TD = "XBX<X+WzWqWdW[WLW9W8W=W9W=W;W,W#V}VwVmV@V6V1U{UvUpUhUaUTUaUbTtTZS(R4QsQ7PpPSP9OoOYO,NaN>MfMX"
F_RTY_RTH = "X/X'WsWeW[WNWFW8W&W'W-W)W.W*VwVmVkVeVZV.V&U{UhUcU[UTUMUBUMURTeTLRvR!QbQ%P`PDP%OZOFNyNON.MY~~"
// Context multipliers (log scale; 0 = did not hold): per block 18:00–03:00, 03:00–09:30, 09:30–12:00, 12:00–17:00 the five
// effects above PDH, below PDL, per ADR under the month's open, per ADR over it, within 0.5 ADR of the ATH
var array<float> B_NQ = array.from(0.0000, 0.2006, 0.0975, 0.0000, 0.0000, 0.0000, 0.1230, 0.1045, 0.0000, 0.0000, -0.1004, 0.0000, 0.1339, 0.0000, 0.0000, -0.1460, 0.1687, 0.1563, 0.0527, -0.1440)
var array<float> B_ES = array.from(0.0000, 0.2608, 0.0962, -0.0741, 0.0000, 0.0000, 0.0000, 0.1044, -0.0696, 0.0000, 0.0000, 0.1202, 0.1606, 0.0000, 0.0000, -0.1686, 0.2025, 0.1773, 0.0000, -0.1356)
var array<float> B_RTY = array.from(0.0000, 0.1427, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0467, 0.0000, 0.0000, 0.0000, 0.0000, 0.0906, 0.0000, 0.0000, 0.0000, 0.1310, 0.1113, 0.0000, 0.0000)

// packed two characters per value: (index in P92) × 92 + (index in P92) − 4000, then ÷ 1000; "~~" = no value
P92 = "!#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
unpack(string s) =>
    array<float> out = array.new<float>()
    for i = 0 to int(str.length(s) / 2) - 1
        int u = str.pos(P92, str.substring(s, 2 * i, 2 * i + 1)) * 92 + str.pos(P92, str.substring(s, 2 * i + 1, 2 * i + 2))
        out.push(u == 8463 ? na : (u - 4000) / 1000.0)
    out
var array<float> QL = array.from(0.01, 0.025, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 0.975, 0.99)
NQL = 23
string root = syminfo.root
string symR = root == "ES" or root == "MES" ? "ES" : root == "RTY" or root == "M2K" ? "RTY" : "NQ"
bool   own  = root == "NQ" or root == "MNQ" or root == "ES" or root == "MES" or root == "RTY" or root == "M2K"
bool   rth  = tgtI == "RTH (16:14)"
int    tgtM = rth ? 1334 : 1380                                  // the close, in minutes after 18:00
var array<float> QT = unpack(symR == "ES" ? (rth ? Q_ES_RTH : Q_ES_TD) : symR == "RTY" ? (rth ? Q_RTY_RTH : Q_RTY_TD) : (rth ? Q_NQ_RTH : Q_NQ_TD))
var array<float> FV = unpack(symR == "ES" ? (rth ? F_ES_RTH : F_ES_TD) : symR == "RTY" ? (rth ? F_RTY_RTH : F_RTY_TD) : (rth ? F_NQ_RTH : F_NQ_TD))

// context multipliers (log scale) per time block 18:00–03:00 · 03:00–09:30 · 09:30–12:00 · 12:00–17:00, five each:
// above PDH, below PDL, ADR under the month's open (capped at 3), ADR over it (capped at 3), within 0.5 ADR of the ATH
var array<float> BT = symR == "ES" ? B_ES : symR == "RTY" ? B_RTY : B_NQ
[pdH, pdL, dH, dL] = request.security(syminfo.tickerid, "D", [high[1], low[1], high, low], lookahead = barmerge.lookahead_on)
float athP  = request.security(syminfo.tickerid, "D", ta.max(high)[1], lookahead = barmerge.lookahead_on)
float mOpen = request.security(syminfo.tickerid, "M", open, lookahead = barmerge.lookahead_on)

// ADR20 of completed days (the [1] offset with lookahead_on: never the day in progress) and the implied volatility index
[adr, adrT] = request.security(syminfo.tickerid, "D", [ta.sma(high - low, 20)[1], ta.sma(high - low, 20)], lookahead = barmerge.lookahead_on)   // adrT: with today, for the next session
string ivSym = symR == "ES" ? ivES : symR == "RTY" ? ivRTY : ivNQ
string ivNm  = symR == "ES" ? "VIX" : symR == "RTY" ? "RVX" : "VXN"
float  iv    = request.security(ivSym, timeframe.isintraday ? timeframe.period : "D", close, ignore_invalid_symbol = true)

// ═══════════════════════════════════════════════════════════════ Kageyoshi · helpers
// standard normal CDF (Abramowitz & Stegun 7.1.26, error under 1.5e-7)
ncdf(float z) =>
    float x = math.abs(z) / math.sqrt(2.0)
    float t = 1.0 / (1.0 + 0.3275911 * x)
    float y = 1.0 - ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * math.exp(-x * x)
    z >= 0 ? 0.5 * (1.0 + y) : 0.5 * (1.0 - y)
// piecewise-linear CDF through the (price, probability) knots, and its inverse
cdfAt(array<float> xs, array<float> ps, float v) =>
    int   n   = xs.size()
    float out = v <= xs.get(0) ? 0.0 : 1.0
    if v > xs.get(0) and v < xs.get(n - 1)
        for i = 1 to n - 1
            if v <= xs.get(i)
                float a = xs.get(i - 1)
                float b = xs.get(i)
                out := ps.get(i - 1) + (b > a ? (v - a) / (b - a) : 0.0) * (ps.get(i) - ps.get(i - 1))
                break
    out
qInv(array<float> xs, array<float> ps, float p) =>
    float out = xs.get(xs.size() - 1)
    for i = 1 to xs.size() - 1
        if p <= ps.get(i)
            float a = ps.get(i - 1)
            float b = ps.get(i)
            out := xs.get(i - 1) + (b > a ? (p - a) / (b - a) : 0.0) * (xs.get(i) - xs.get(i - 1))
            break
    out

// ═══════════════════════════════════════════════════════════════ Senkei · FOMC decision days (ET)
// Verified 11 Oct 2026. UPDATE ONCE A YEAR: add the next year's dates (federalreserve.gov, out by mid-year).
S_FOMC = "20180131,20180321,20180502,20180613,20180801,20180926,20181108,20181219,"
     + "20190130,20190320,20190501,20190619,20190731,20190918,20191030,20191211,"
     + "20200129,20200429,20200610,20200729,20200916,20201105,20201216,20210127,"
     + "20210317,20210428,20210616,20210728,20210922,20211103,20211215,20220126,"
     + "20220316,20220504,20220615,20220727,20220921,20221102,20221214,20230201,"
     + "20230322,20230503,20230614,20230726,20230920,20231101,20231213,20240131,"
     + "20240320,20240501,20240612,20240731,20240918,20241107,20241218,20250129,"
     + "20250319,20250507,20250618,20250730,20250917,20251029,20251210,20260128,"
     + "20260318,20260429,20260617,20260729,20260916,20261028,20261209,20270127,"
     + "20270317,20270428,20270609,20270728,20270915,20271027,20271208"

parseDates(string s) =>
    array<int> out = array.new<int>()
    for p in str.split(s, ",")
        out.push(int(str.tonumber(p)))
    out
var array<int> FO = parseDates(S_FOMC)
dateKey(int t) => year(t, TZ) * 10000 + month(t, TZ) * 100 + dayofmonth(t, TZ)
keyTime(int k) => timestamp(TZ, int(k / 10000), int(k / 100) % 100, k % 100, 12, 0)
// "now" for the map: the clock, but never past the last bar's close (so bar replay reads the replay date). On a daily chart
// the last bar opens at 18:00 the evening before, so the bar's own time would miss a decision made today.
int tNow = math.min(timenow, last_bar_time + int(timeframe.in_seconds() * 1000))
int nowK = dateKey(tNow)
int nowM = hour(tNow, TZ) * 60 + minute(tNow, TZ)

// ═══════════════════════════════════════════════════════════════ Senkei · the ZQ grid
// Seventeen calendar months from the one before the last bar's month, fixed when the script loads, so the same contracts
// are requested on every bar.
FDN = 17
var int fdY = year(last_bar_time, TZ)
var int fdM = month(last_bar_time, TZ)
fdYM(int i) =>
    int t = fdY * 12 + fdM - 2 + i
    [int(math.floor(t / 12)), t % 12 + 1]
fdTk(int i) =>
    [y, m] = fdYM(i)
    fdRoot + str.substring("FGHJKMNQUVXZ", m - 1, m) + str.tostring(y)
fdDim(int y, int m) => m == 2 ? (y % 4 == 0 ? 29 : 28) : m == 4 or m == 6 or m == 9 or m == 11 ? 30 : 31
fdDay(int y, int m) =>
    int d = 0
    for k in FO
        if int(k / 10000) == y and int(k / 100) % 100 == m
            d := k % 100
    d
// one dynamic request per month (Pine v6 runs request.security() inside loops); seventeen of the forty allowed
array<float> fdZ = array.new<float>(FDN, na)
for i = 0 to FDN - 1
    fdZ.set(i, request.security(fdTk(i), timeframe.period, close, ignore_invalid_symbol = true))
// the grid's calendar, worked out once: meeting day (0 = none), days in the month, meeting key (yyyymmdd)
var array<int> FMD = array.new<int>()
var array<int> FND = array.new<int>()
var array<int> FKY = array.new<int>()
if barstate.isfirst
    for i = 0 to FDN - 1
        [y, m] = fdYM(i)
        int d = fdDay(y, m)
        FMD.push(d)
        FND.push(fdDim(y, m))
        FKY.push(y * 10000 + m * 100 + d)

// ═══════════════════════════════════════════════════════════════ Senkei · CME FedWatch's steps
// Start and end rate (%) of every meeting month in the grid. CME's chaining (checked on its 12 Oct 2026 screen to 0.06 pp):
// the end rate comes from the next month (its average when it has no meeting, else its start solved from its own contract,
// chained back from the next month without a meeting); the start is the prior month's average when that month has no
// meeting, else solved from the meeting month itself.
fdRates(array<float> Z) =>
    array<float> A = array.new<float>(FDN, na)
    for i = 0 to FDN - 1
        if Z.size() > i
            float p = Z.get(i)
            A.set(i, na(p) ? na : 100.0 - p)
    array<float> S  = array.new<float>(FDN, na)
    array<float> E  = array.new<float>(FDN, na)
    array<float> SS = array.new<float>(FDN, na)
    for i = FDN - 1 to 0
        int   d = FMD.get(i)
        float a = A.get(i)
        if d > 0 and not na(a)
            float en = na
            if i < FDN - 1
                en := FMD.get(i + 1) == 0 ? A.get(i + 1) : SS.get(i + 1)
            if not na(en)
                E.set(i, en)
                SS.set(i, (a * FND.get(i) - en * (FND.get(i) - d)) / d)
    for i = 0 to FDN - 1
        int   d = FMD.get(i)
        float a = A.get(i)
        if d > 0 and not na(a)
            float st = SS.get(i)
            if i > 0
                if FMD.get(i - 1) == 0 and not na(A.get(i - 1))
                    st := A.get(i - 1)
            S.set(i, st)
            if na(E.get(i)) and not na(st) and FND.get(i) > d
                E.set(i, (a * FND.get(i) - st * d) / (FND.get(i) - d))
    [S, E]
// one meeting: the two nearest move sizes (in 25bp steps) and their odds
fdNode(float dl) =>
    float st = dl / 0.25
    float k  = math.floor(math.abs(st))
    float r  = math.abs(st) - k
    int   sg = st >= 0 ? 1 : -1
    [int(sg * k), int(sg * (k + 1)), 1.0 - r, r]
// the tree: odds over the total change (−20 … +20 steps of 25bp) after one more meeting
fdStep(array<float> p, float dl) =>
    [k1, k2, w1, w2] = fdNode(dl)
    array<float> q = array.new<float>(41, 0.0)
    for x = 0 to 40
        float v = p.get(x)
        if v > 0
            int a = x + k1
            int b = x + k2
            if a >= 0 and a <= 40
                q.set(a, q.get(a) + v * w1)
            if b >= 0 and b <= 40
                q.set(b, q.get(b) + v * w2)
    q
fdWord(int k) => na(k) ? "—" : k == 0 ? "hold" : k < 0 ? "cut " + str.tostring(-25 * k) : "hike " + str.tostring(25 * k)
fdRng(float lo0, int k) => na(lo0) or na(k) ? "—" : str.tostring((lo0 + 0.25 * k) * 100, "0") + "–" + str.tostring((lo0 + 0.25 * (k + 1)) * 100, "0")
fdSg(float v, string f) => na(v) ? "—" : (v >= 0 ? "+" : "−") + str.tostring(math.abs(v), f)
fdDate(int k) => str.upper(str.format_time(keyTime(k), "dd MMM", TZ))
// a meeting still ahead: a later day, or today before the 14:00 statement
ahead(int ky) => ky % 100 > 0 and (ky > nowK or (ky == nowK and nowM < 840))

// ═══════════════════════════════════════════════════════════════ Senkei · history: the next six meetings, bar by bar
var array<int> FMI = array.new<int>()
if barstate.isfirst
    for i = 0 to FDN - 1
        if ahead(FKY.get(i)) and FMI.size() < 6
            FMI.push(i)
hAt(array<float> E, int j) => FMI.size() > j ? E.get(FMI.get(j)) : na
float h1 = na
float h2 = na
float h3 = na
float h4 = na
float h5 = na
float h6 = na
if showS and showHL and last_bar_index - bar_index < hBars
    [hS, hE] = fdRates(fdZ)
    h1 := hAt(hE, 0)
    h2 := hAt(hE, 1)
    h3 := hAt(hE, 2)
    h4 := hAt(hE, 3)
    h5 := hAt(hE, 4)
    h6 := hAt(hE, 5)
plot(h1, "Next meeting", color = L1, linewidth = 2, style = plot.style_linebr)
plot(h2, "Meeting 2", color = L2, linewidth = 1, style = plot.style_linebr)
plot(h3, "Meeting 3", color = L3, linewidth = 1, style = plot.style_linebr)
plot(h4, "Meeting 4", color = L4, linewidth = 1, style = plot.style_linebr)
plot(h5, "Meeting 5", color = L5, linewidth = 1, style = plot.style_linebr)
plot(h6, "Meeting 6", color = L6, linewidth = 1, style = plot.style_linebr)

// ═══════════════════════════════════════════════════════════════ Senkei · the map, right of the last bar in this pane
var array<box>      MB = array.new<box>()
var array<label>    MT = array.new<label>()
var array<polyline> MP = array.new<polyline>()
var float mapLo = na
var float mapHi = na
if barstate.islast
    for b in MB
        b.delete()
    for t in MT
        t.delete()
    for p in MP
        p.delete()
    MB.clear()
    MT.clear()
    MP.clear()
    [S, E] = fdRates(fdZ)
    array<int> up = array.new<int>()
    for i = 0 to FDN - 1
        if ahead(FKY.get(i)) and not na(S.get(i)) and not na(E.get(i)) and up.size() < nAh
            up.push(i)
    if not showS
        mapLo := na
        mapHi := na
    else if up.size() == 0
        MT.push(label.new(bar_index, 0.0, "Senkei: no " + fdRoot + " prices for the coming months on this chart", style = label.style_label_left, color = #00000000, textcolor = cMu, size = size.small))
    else
        float base = S.get(up.get(0))                                    // the rate now (start of the next meeting's month)
        float lo0  = math.floor((base + 0.0001) / 0.25) * 0.25           // lower bound of the current target range
        int   x0   = bar_index + offS
        int   xL   = math.max(0, bar_index - (mob ? 60 : 300))
        int   xR   = x0 + gxS * (up.size() - 1) + 6
        if showBand
            MB.push(box.new(xL, lo0 + 0.25, xR, lo0, border_color = #00000000, bgcolor = color.new(cTx, 92), text = (mob ? "" : "target now ") + fdRng(lo0, 0), text_color = cMu, text_size = txSz, text_halign = text.align_left, text_valign = text.align_bottom))
        array<chart.point> pts = array.new<chart.point>()
        pts.push(chart.point.from_index(bar_index, base))
        array<float> P = array.new<float>(41, 0.0)
        P.set(20, 1.0)
        float yMin = lo0
        float yMax = lo0 + 0.25
        // the columns: the probability tree after each meeting, one block per target range
        for j = 0 to up.size() - 1
            int i  = up.get(j)
            int xc = x0 + gxS * j
            P := fdStep(P, E.get(i) - S.get(i))
            for x = 0 to 40
                float p = P.get(x)
                if p > 0 and p >= minP / 100
                    float yl = lo0 + 0.25 * (x - 20)
                    MB.push(box.new(xc - hwS, yl + 0.25, xc + hwS, yl, border_color = chart.bg_color, border_width = 1, bgcolor = color.from_gradient(p, 0.0, 0.6, color.new(cCl, 88), color.new(cCl, 0)), text = showPct and p >= (mob ? 0.10 : 0.04) ? str.tostring(100 * p, "0") + "%" : "", text_color = p >= 0.3 ? #ffffff : cTx, text_size = txSz))
                    yMin := math.min(yMin, yl)
                    yMax := math.max(yMax, yl + 0.25)
            pts.push(chart.point.from_index(xc, E.get(i)))
        if showPath
            MP.push(polyline.new(pts, curved = false, line_color = color.new(cTx, 15), line_width = 2))
        // dates, moves, the Fed's dots
        for j = 0 to up.size() - 1
            int    i    = up.get(j)
            int    ky   = FKY.get(i)
            int    xc   = x0 + gxS * j
            int    yr   = int(ky / 10000)
            bool   eoy  = int(ky / 100) % 100 == 12                       // last meeting of its year
            if j < up.size() - 1
                eoy := int(FKY.get(up.get(j + 1)) / 10000) != yr
            float  sep  = yr == sepY ? sep1 : yr == sepY + 1 ? sep2 : yr == sepY + 2 ? sep3 : na
            bool   dot_ = showDot and eoy and not na(sep)
            color  lc   = j == 0 ? L1 : j == 1 ? L2 : j == 2 ? L3 : j == 3 ? L4 : j == 4 ? L5 : j == 5 ? L6 : cSub
            float  e    = E.get(i)
            if showPath
                MT.push(label.new(xc, e, "", color = cTx, style = label.style_circle, size = size.tiny, tooltip = fdDate(ky) + ": expected " + str.tostring(e, "0.000") + "% · " + fdSg(100 * (e - base), "0") + "bp from now"))
            if dot_
                MT.push(label.new(xc + hwS + 1, sep, "", style = label.style_diamond, color = cDot, size = size.small, tooltip = "Fed dot plot (SEP " + sepAs + "): median end-" + str.tostring(yr) + " rate " + str.tostring(sep, "0.000") + "%"))
            MT.push(label.new(xc, yMin - 0.02, (mob ? str.upper(str.format_time(keyTime(ky), "MMM", TZ)) + "\n" + fdSg(100 * (e - base), "0") + (dot_ ? "\n◆" + fdSg(100 * (e - sep), "0") : "") : fdDate(ky) + "\n" + fdSg(100 * (e - base), "0") + "bp" + (dot_ ? "\nFed " + str.tostring(sep, "0.000") + "\nmkt " + fdSg(100 * (e - sep), "0") + "bp" : "")), style = label.style_label_up, color = #00000000, textcolor = lc, size = txSz, tooltip = dot_ ? "◆ the Fed's dot plot (SEP " + sepAs + "): median year-end " + str.tostring(yr) + " rate " + str.tostring(sep, "0.000") + "%. The market prices " + str.tostring(e, "0.000") + "% after the " + fdDate(ky) + " meeting, " + fdSg(100 * (e - sep), "0") + "bp " + (e >= sep ? "above" : "below") + " the Fed's own median." : j < 6 ? "This date's colour matches its line on the left." : "Expected rate after this meeting against the rate now."))
        // headline: the next meeting's most likely outcome
        [k1, k2, w1, w2] = fdNode(E.get(up.get(0)) - S.get(up.get(0)))
        int   kA = w1 >= w2 ? k1 : k2
        float pA = math.max(w1, w2)
        MT.push(label.new(x0, yMax + 0.02, fdDate(FKY.get(up.get(0))) + " · " + str.upper(fdWord(kA)) + " " + p0(pA), style = label.style_label_down, color = kA == 0 ? cNeu : kA < 0 ? cCold : cHot, textcolor = kA == 0 ? cTx : #ffffff, size = size.small, tooltip = "Next meeting: " + fdWord(k1) + " " + p0(w1) + ", " + fdWord(k2) + " " + p0(w2) + "."))
        if not mob
            MT.push(label.new(xL, yMax + 0.02, "SENKEI · lines: each meeting's expected rate, bar by bar · blocks: odds of each target range per meeting" + (showDot ? " · ◆ the Fed's dots (SEP " + sepAs + ")" : ""), style = label.style_label_lower_left, color = #00000000, textcolor = cMu, size = txSz, tooltip = "From CBOT 30-day fed funds futures with CME FedWatch's steps (checked on CME's own page for 12 Oct 2026: within 0.06 pp). TradingView delays CBOT data without a subscription."))
        // room on the pane's scale for the labels under the columns and the headline above them
        mapLo := yMin - (mob ? 0.3 : 0.35)
        mapHi := yMax + 0.12
plot(barstate.islast ? mapLo : na, "", color = #00000000, editable = false, display = display.pane)
plot(barstate.islast ? mapHi : na, "", color = #00000000, editable = false, display = display.pane)

// ═══════════════════════════════════════════════════════════════ Kageyoshi · the curves, right of the last bar on the price chart
var array<box>      SB = array.new<box>()
var array<line>     SL = array.new<line>()
var array<label>    ST = array.new<label>()
var array<polyline> SP = array.new<polyline>()
if barstate.islast
    for b in SB
        b.delete()
    for l in SL
        l.delete()
    for t in ST
        t.delete()
    for p in SP
        p.delete()
    SB.clear()
    SL.clear()
    ST.clear()
    SP.clear()
    // where we are in the day: minutes after 18:00; past the close, or with the market shut, the next session from 18:00
    int  tRef  = math.min(timenow, time_close)
    bool shut  = timenow - time_close > 30 * 60000
    int  e     = ((hour(tRef, TZ) * 60 + minute(tRef, TZ)) - 1080 + 1440) % 1440
    bool nextS = shut or e >= tgtM
    if nextS
        e := 0
    int   j   = math.min(45, int(math.floor(e / 30)))
    int   tN  = math.min(30 * (j + 1), tgtM)                      // the next half-hour mark, or the close itself
    bool  zN  = 30 * (j + 1) >= tgtM                              // at the close everything is known: a zero-width row
    float w   = tN > 30 * j ? float(e - 30 * j) / (tN - 30 * j) : 1.0
    float P   = close
    float adrU = nextS and not na(adrT) ? adrT : adr                // the next session: ADR20 including today
    // historical: this half hour's quantile row blended toward the next one by the time elapsed, in ADR20, around price
    // market structure now (for the next session the prior day is today)
    float pdh  = nextS ? dH : pdH
    float pdl  = nextS ? dL : pdL
    float ath  = math.max(nz(athP), nz(dH))
    bool  okA  = not na(adrU) and adrU > 0
    float z0   = not na(pdh) and P > pdh ? 1.0 : 0.0
    float z1   = not na(pdl) and P < pdl ? 1.0 : 0.0
    float z2   = okA and not na(mOpen) ? math.max(0.0, math.min(3.0, (mOpen - P) / adrU)) : 0.0
    float z3   = okA and not na(mOpen) ? math.max(0.0, math.min(3.0, (P - mOpen) / adrU)) : 0.0
    float z4   = okA and ath > 0 and (ath - P) / adrU <= 0.5 ? 1.0 : 0.0
    int   blk  = j <= 17 ? 0 : j <= 30 ? 1 : j <= 35 ? 2 : 3
    float sCtx = ctxOn ? math.exp(BT.get(blk * 5) * z0 + BT.get(blk * 5 + 1) * z1 + BT.get(blk * 5 + 2) * z2 + BT.get(blk * 5 + 3) * z3 + BT.get(blk * 5 + 4) * z4) : 1.0
    array<float> xs = array.new<float>()
    array<float> ps = array.new<float>()
    bool hOk = showH and okA and not na(QT.get(j * NQL))
    if hOk
        array<float> row = array.new<float>()
        for k = 0 to NQL - 1
            float a = QT.get(j * NQL + k)
            float b = 0.0
            if not zN
                b := QT.get((j + 1) * NQL + k)
            row.push(a + (b - a) * w)
        float med = row.get(11)
        for k = 0 to NQL - 1
            xs.push(P + adrU * (med + (row.get(k) - med) * sCtx))
            ps.push(QL.get(k))
        float tLo = xs.get(0) - 2 * (xs.get(1) - xs.get(0))      // tails past 1% / 99%: straight out to twice the last step
        float tHi = xs.get(NQL - 1) + 2 * (xs.get(NQL - 1) - xs.get(NQL - 2))
        xs.unshift(tLo)
        ps.unshift(0.0)
        xs.push(tHi)
        ps.push(1.0)
        hOk := xs.get(NQL) - xs.get(1) >= 4 * syminfo.mintick
    // implied: lognormal around price, one day = index ÷ √252, times √(share of the day's variance still ahead)
    float fN  = 0.0
    if not zN
        fN := FV.get(j + 1)
    float f   = FV.get(j) + (fN - FV.get(j)) * w
    bool  iOk = showI and not na(iv) and iv > 0 and not na(f) and f > 0
    float sg  = iOk ? iv / 100 / math.sqrt(252) * math.sqrt(f) : na
    if iOk
        iOk := P * (math.exp(2.326 * sg) - 1) >= 2 * syminfo.mintick
    if showK and (hOk or iOk)
        // bins across the 1–99% range of both curves
        float lo = na
        float hi = na
        if hOk
            lo := xs.get(1)
            hi := xs.get(NQL)
        if iOk
            lo := na(lo) ? P * math.exp(-2.326 * sg) : math.min(lo, P * math.exp(-2.326 * sg))
            hi := na(hi) ? P * math.exp(2.326 * sg) : math.max(hi, P * math.exp(2.326 * sg))
        float bw = math.ceil(math.max(syminfo.mintick, (hi - lo) / binK) / syminfo.mintick) * syminfo.mintick
        float b0 = math.floor(lo / bw) * bw
        int   nb = int(math.ceil((hi - b0) / bw))
        array<float> pH = array.new<float>(nb, 0.0)
        array<float> pI = array.new<float>(nb, 0.0)
        for i = 0 to nb - 1
            float a = b0 + i * bw
            float b = a + bw
            if hOk
                pH.set(i, cdfAt(xs, ps, b) - cdfAt(xs, ps, a))
            if iOk
                pI.set(i, ncdf(math.log(b / P) / sg) - ncdf(math.log(a / P) / sg))
        // the bars are smoothed over neighbouring bins (1-4-6-4-1) for display; bands, median and odds use the exact curve
        if hOk
            array<float> sm = array.new<float>(nb, 0.0)
            for i = 0 to nb - 1
                float acc = 0.0
                for k = -2 to 2
                    int ii = i + k
                    if ii >= 0 and ii < nb
                        acc += pH.get(ii) * (k == 0 ? 6.0 : k == 1 or k == -1 ? 4.0 : 1.0) / 16.0
                sm.set(i, acc)
            pH := sm
        float pmax = 0.0
        int   iMax = 0
        for i = 0 to nb - 1
            float m = math.max(pH.get(i), pI.get(i))
            if m > pmax
                pmax := m
                iMax := i
        int x0 = bar_index + offK
        // implied: a filled bell (probability per bin from the lognormal density), drawn first so the bars sit on top
        if iOk
            array<chart.point> pts = array.new<chart.point>()
            pts.push(chart.point.from_index(x0, b0))
            for i = 0 to nb - 1
                float y = b0 + (i + 0.5) * bw
                float z = math.log(y / P) / sg
                float d = math.exp(-0.5 * z * z) / (math.sqrt(2 * math.pi) * sg * y) * bw
                pts.push(chart.point.from_index(x0 + int(math.round(d / pmax * lenK)), y))
            pts.push(chart.point.from_index(x0, b0 + nb * bw))
            SP.push(polyline.new(pts, curved = false, closed = true, line_color = cI, line_width = 2, fill_color = color.new(cI, 85), force_overlay = true))
        // historical: one bar per bin
        if hOk
            for i = 0 to nb - 1
                int L = int(math.round(pH.get(i) / pmax * lenK))
                if L >= 1
                    SB.push(box.new(x0, b0 + (i + 1) * bw, x0 + L, b0 + i * bw, border_color = color.new(cH, 20), border_width = 1, bgcolor = color.new(cH, 55), force_overlay = true))
        // price now, carried across the curves
        SL.push(line.new(bar_index, P, x0 + lenK + 2, P, color = color.new(cTx, 45), style = line.style_dotted, force_overlay = true))
        float h10 = na
        float h90 = na
        float i10 = na
        float i90 = na
        if hOk
            h10 := qInv(xs, ps, 0.10)
            h90 := qInv(xs, ps, 0.90)
        if iOk
            i10 := P * math.exp(-1.2816 * sg)
            i90 := P * math.exp(1.2816 * sg)
        if showB
            if hOk
                float h25 = qInv(xs, ps, 0.25)
                float h50 = qInv(xs, ps, 0.50)
                float h75 = qInv(xs, ps, 0.75)
                SL.push(line.new(x0 - 2, h10, x0 - 2, h90, color = color.new(cH, 35), width = 1, force_overlay = true))
                SL.push(line.new(x0 - 2, h25, x0 - 2, h75, color = cH, width = 4, force_overlay = true))
                SL.push(line.new(x0, h50, x0 + lenK, h50, color = cH, style = line.style_dashed, force_overlay = true))
                if not mob
                    ST.push(label.new(x0 - 2, h90, "80% " + pf(h90), style = label.style_label_right, color = #00000000, textcolor = cH, size = txSz, tooltip = "Historical 80% band: 10% of days closed above this.", force_overlay = true))
                    ST.push(label.new(x0 - 2, h10, "80% " + pf(h10), style = label.style_label_right, color = #00000000, textcolor = cH, size = txSz, tooltip = "Historical 80% band: 10% of days closed below this.", force_overlay = true))
                ST.push(label.new(x0 + lenK, h50, (mob ? "med " : "median ") + (h50 >= P ? "+" : "−") + pf(math.abs(h50 - P)), style = label.style_label_left, color = #00000000, textcolor = cH, size = txSz, tooltip = "Half of days closed above this price, half below (historical).", force_overlay = true))
            if iOk
                SL.push(line.new(x0 - 4, i10, x0 - 4, i90, color = color.new(cI, 30), width = 2, force_overlay = true))
        // PDH · PDL · the month's open · ATH, with the odds of the close finishing beyond each (historical / implied)
        string lvT = ""
        if showLv
            for li = 0 to 3
                float  lv = li == 0 ? pdh : li == 1 ? pdl : li == 2 ? mOpen : ath
                string ln = li == 0 ? "PDH" : li == 1 ? "PDL" : li == 2 ? "MO" : "ATH"
                if not na(lv) and lv > 0
                    bool   up_ = lv >= P
                    float  ph  = hOk ? (up_ ? 1 - cdfAt(xs, ps, lv) : cdfAt(xs, ps, lv)) : na
                    float  pi_ = iOk ? (up_ ? 1 - ncdf(math.log(lv / P) / sg) : ncdf(math.log(lv / P) / sg)) : na
                    string od  = (up_ ? "▲" : "▼") + (na(ph) ? "—" : str.tostring(ph * 100, "0")) + (mob ? "/" : " / ") + (na(pi_) ? "—" : str.tostring(pi_ * 100, "0")) + "%"
                    lvT += (lvT == "" ? "" : " · ") + ln + " " + pf(lv) + " " + od
                    if lv >= b0 and lv <= b0 + nb * bw
                        SL.push(line.new(x0 - 6, lv, x0 + lenK, lv, color = color.new(cLv, li == 3 ? 0 : 25), style = li == 2 ? line.style_dotted : li == 3 ? line.style_solid : line.style_dashed, width = wLv, force_overlay = true))
                        ST.push(label.new(x0 - 6, lv, ln + " " + od, style = label.style_label_right, color = #00000000, textcolor = cLv, size = txSz, tooltip = ln + " " + pf(lv) + ": the close finishes " + (up_ ? "above" : "below") + " it on " + (na(ph) ? "—" : p0(ph)) + " (historical" + (ctxOn ? ", context-scaled" : "") + ") / " + (na(pi_) ? "—" : p0(pi_)) + " (implied) of days like this.", force_overlay = true))
        // the most likely bin: how much probability one bin holds
        float yM = b0 + (iMax + 0.5) * bw
        if not mob
            ST.push(label.new(x0 + lenK, yM, str.tostring(pmax * 100, "0.0") + "% per " + pf(bw), style = label.style_label_left, color = #00000000, textcolor = cSub, size = size.tiny, tooltip = "Probability held by the most likely bin; bin height " + pf(bw) + " points.", force_overlay = true))
        if showT
            int    left = tgtM - e
            string whn  = nextS ? "next session's " + (rth ? "RTH close (16:14)" : "close (17:00)") : (rth ? "RTH close 16:14" : "close 17:00") + " · " + str.tostring(int(left / 60)) + "h " + str.tostring(left % 60, "00") + "m left"
            string hL   = hOk ? "historical  up " + p0(1 - cdfAt(xs, ps, P)) + " · 80% " + pf(h10) + " – " + pf(h90) : showH ? "historical  needs 20 days of history" : ""
            string iL   = iOk ? "implied (" + ivNm + " " + str.tostring(iv, "0.0") + ")  80% " + pf(i10) + " – " + pf(i90) + (hOk and h90 > h10 ? " · " + str.tostring((i90 - i10) / (h90 - h10), "0.0") + "× wider" : "") : showI ? "implied  no " + ivNm + " data" : ""
            string cxL  = ""
            if ctxOn and hOk
                string pr = (z0 > 0 ? "above PDH · " : "") + (z1 > 0 ? "below PDL · " : "") + (z2 > 0 ? str.tostring(z2, "0.0") + " ADR under MO · " : z3 > 0 ? str.tostring(z3, "0.0") + " ADR over MO · " : "") + (z4 > 0 ? "at the ATH · " : "")
                cxL := "context  width ×" + str.tostring(sCtx, "0.00") + (pr == "" ? " · inside PD range, at MO" : " · " + str.substring(pr, 0, str.length(pr) - 3))
            string tip  = "Historical: every trading day Jan 2018 – Oct 2026 (ES to Aug 2026) on " + symR + " 1-minute data: the close minus the price at this half hour, in ADR20 units, scaled to today's ADR20 (" + pf(adrU) + ") around the last price. Built on 2018–24 and checked on 2025–26, its 80% band held 83–84% of closes and its 90% band 90–92%. Context (PDH / PDL, the month's open, the ATH) scales its width; on 2025–26 it brought the 80% band on below-PDL days from 73% to 79% of closes on NQ (70% to 76% on ES) and on days far under the month's open from 70% to 78% (67% to 76%)." + "\nImplied: " + ivNm + " ÷ √252 for one day, times √(share of the day's variance still ahead: " + str.tostring(f * 100, "0") + "% now), lognormal around the last price. On ES the VIX curve ran 1.3–1.5× wider than what followed (its 80% band held 90% of closes): implied volatility usually prices in more movement than arrives." + (own ? "" : "\nThis chart is " + root + ": the curves use " + symR + " statistics.")
            string hdr  = "SENBONZAKURA · " + symR + (own ? "" : " DATA") + " · " + whn + (hL == "" ? "" : "\n" + hL) + (iL == "" ? "" : "\n" + iL) + (cxL == "" ? "" : "\n" + cxL) + (lvT == "" ? "" : "\n" + lvT)
            if mob
                string mW = (rth ? "16:14" : "17:00") + (nextS ? " next" : " " + str.tostring(int(left / 60)) + "h" + str.tostring(left % 60, "00"))
                hdr := "SBZ " + symR + " · " + mW + (hOk ? "\nhist ▲" + p0(1 - cdfAt(xs, ps, P)) + " · " + pf(h10) + "–" + pf(h90) : "") + (iOk or (ctxOn and hOk) ? "\n" + (iOk and hOk and h90 > h10 ? "impl ×" + str.tostring((i90 - i10) / (h90 - h10), "0.0") : iOk ? "impl " + pf(i10) + "–" + pf(i90) : "") + (ctxOn and hOk ? (iOk ? " · " : "") + "ctx ×" + str.tostring(sCtx, "0.00") : "") : "")
            ST.push(label.new(x0, b0 + nb * bw + bw, hdr, style = label.style_label_lower_left, color = color.new(cBox, 10), textcolor = cTx, size = txSz, text_font_family = font.family_monospace, textalign = text.align_left, tooltip = tip, force_overlay = true))
````
