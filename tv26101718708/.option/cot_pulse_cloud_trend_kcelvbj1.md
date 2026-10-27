# COT Pulse Cloud Trend

- url: https://www.tradingview.com/script/KcelvBj1-COT-Pulse-Cloud-Trend/
- type: indicator
- pine_id: PUB;1ca439d5e6704e88813789d58ae80988
- version: 2.0

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

## Source Code

````pine
//@version=6
// Changelog: extreme-reading triangle now marks only the bar where a
// reading FIRST enters the top/bottom 20% of its own range, not every bar
// it stays there — see the "Extreme reading" section further down.
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
//   Auto — Trend for Non-Commercial/Commercial, Excel for Difference
//     (the only mode that fits a pure difference). No mode here is
//     chosen by measured performance: Trend is the default because it
//     is the easiest to read straight off the data, not because it
//     tested better. See "What the data does and doesn't support".
//   Excel — the same anchoring as the workbook's own conditional
//     formatting on its Net Position / Difference columns: a 3-point
//     color scale anchored at [min, 50th percentile, max] of the value
//     over the History window — red at the low anchor, white at the
//     50th percentile (not the midpoint of min/max — Excel's percentile
//     anchor), green at the high anchor — plus a border colored by sign
//     (dark red below zero, dark green above), mirroring the workbook's
//     font-color rule on top of its fill color scale. The fill color at
//     the anchors is darkened from the workbook's own pastel red/green
//     so the extreme end reads as clearly colored on a chart rather than
//     pale pink/mint. This is the only mode used for Difference (there's
//     no separate Long/Short pair to read a trend or %Long from a pure
//     difference).
//   Trend — white right at net's (Long-Short) own 13-week average,
//     fading to green above it (more long than usual) or red below it
//     (more short than usual) the further it deviates. Blue overrides
//     both when BOTH legs are below their own 13-week average (falling
//     interest on both sides) — darker blue the colder. This is a
//     MOMENTUM reading (net vs. its own recent average), not a who's-
//     bigger reading — it can paint red while Long still far exceeds
//     Short, if net has simply pulled back off a recent peak while
//     staying strongly positive (verified on CAD: NC net ran +31k to
//     +179k through mid-2026, then eased back to +70k — still 2-4x
//     Long over Short throughout, but Trend read red from the point net
//     started easing, because that's below its own now-elevated 13w
//     average). Use Absolute below for a reading of which side is
//     bigger right now, unaffected by its own recent history.
//   Absolute — %Long of the current week's total (Long+Short), same
//     figure as COT Pulse's %Long column. The only mode that reads
//     purely off which side dominates right now, with no comparison to
//     history at all.
//   Relative — where net (Long-Short) sits between its own all-time low
//     and high, 0-100 (the same full-history, History-window-capped
//     anchors Excel uses above, not a fixed trailing window). Used to
//     scan only a fixed trailing Lookback window, mirroring
//     cot/transform.py::_cot_index — on a market that trended hard
//     within that window (the same CAD case above), the window's own
//     high/low moved WITH the trend, so a still-strongly-long net could
//     price out near the middle of its own recent range and read as
//     neutral or red, the same failure mode as Trend just with a wider
//     window. Scanning the full history instead fixes that: a net far
//     from its true all-time low reads as long-dominant regardless of
//     how far it has pulled back from a recent peak. This CAN still
//     read as pale/near-neutral even when a market has been net long
//     for most of its VISIBLE recent history, if the true full-history
//     high sits somewhere further back than that window shows — verified
//     on CHF: current net +29,985 reads as idx=54 (barely above
//     neutral) because the script's own 20-year scan found a true high
//     of +79,331, well above the +49,793 visible in a 5-year table,
//     while the true low (-27,640) happened to already sit inside that
//     same 5-year window. Confirmed correct math, not a bug — a market
//     whose true extreme lies outside whatever window you're eyeballing
//     will always look tamer against its full history than it does
//     against that shorter view.
//   Long %ile / Short %ile — same percentile-anchored scale as Excel
//     above ([min, 50th percentile, max] of the History window, red/
//     white/green), but run on that ONE leg alone instead of Long-Short
//     net. Net can mute a leg's own move — e.g. Short pushing to its
//     own all-time high while Long is rising too holds Net back from
//     looking extreme. These modes show a leg's own extremity directly.
//     Long uses the same convention as Net (high = green, bullish);
//     Short is inverted (high = red, since a bigger short leg is the
//     bearish direction). Both fall back to Excel on Difference, since
//     there's no single Long/Short leg to read from a pure difference.
//
// What the data does and doesn't support
// --------------------------------------
// An earlier version of this header reported a backtest that singled
// out Gold (r ~ 0.32-0.37 at 13 weeks) and hard-wired Auto to pick
// Absolute there. Re-measured against the workbook's own COT history
// and weekly closes, it does not reproduce. Correlation of %Long with
// the forward 13-week return, full sample:
//
//     Gold +0.06   EUR +0.16   GBP -0.05   JPY +0.06   S&P 500 -0.13
//
// Split into four-year sub-periods, every one of the five changes sign
// at least once. Gold is among the least stable, not the most:
// +0.14 (2010-13), -0.33 (2014-17), +0.01 (2018-21), +0.18 (2022-26)
// — its single largest reading points the opposite way to the rest.
// The quintile spread behaves the same: +5.62 / -7.13 / +2.71 / +5.51.
//
// Sample size matters as much as the numbers. Thirteen-week forward
// windows overlap, so ~1000 weekly rows carry only about 1000/13 = 77
// independent observations, and at that size |r| has to reach roughly
// 0.22 before it separates from zero. None of the figures above do.
//
// What does survive is that the DIRECTION differs by market — EUR reads
// as momentum, GBP and S&P 500 mildly contrarian, JPY flat. That is a
// reason not to apply one rule everywhere; it is not a reason to trust
// any of them individually. Read this as slow positioning context to
// set beside your own analysis. It is not a timing trigger, and no mode
// in it was selected because it outperformed another.
// Coverage. Every CFTC code in the table below was read directly from
// the Legacy Futures Only reports on cftc.gov for the 18.08.2026
// release — CME, COMEX, CBOT, NYMEX, ICE Futures U.S. and Cboe — and all
// matched, Bitcoin included (though Bitcoin uses 133742, MICRO BITCOIN, a
// proxy for the standard 133741 BITCOIN contract this indicator's own
// chart tracks — see the Bitcoin note below). The TradingView ROOTS the
// table keys off were not verified the same way; check any new one with
// syminfo.root on a live chart before trusting it, since a root that
// never matches fails silently as "no COT match".
//   Currencies: EUR GBP JPY AUD NZD CAD CHF
//   Metals/ags: Gold Silver Copper Palladium Platinum Wheat(SRW) Cotton
//     Corn Soybeans Sugar Coffee Cocoa Live Cattle — matched on futures
//     root (GC/SI/HG/PA/PL/ZW/CT/ZC/ZS/SB/KC/CC/LE — note Wheat is the
//     modern Globex root ZW, not the old pit code W, same family as
//     ZC/ZS) or, for spot/CFD gold and silver charts, on basecurrency
//     XAU/XAG when the broker sets it (confirmed working on at least one
//     major feed) or, as a fallback for brokers that don't populate
//     basecurrency for CFDs at all (confirmed live: IC Markets' Gold
//     Spot/USD left basecurrency empty and syminfo.root holding the
//     literal ticker "XAUUSD" instead of a short code), on a plain "XAU"/
//     "XAG" substring match against root or ticker — broad but safe,
//     since those two strings aren't likely to appear in an unrelated
//     symbol's ticker
//   Energy: WTI Crude Oil (CL), Natural Gas (NG)
//   Rates: 2-Year Treasury Note (ZT), 10-Year Treasury Note (ZN)
//   Index/other: Nikkei 225, S&P 500 (ES), Nasdaq-100 (NQ), Dow (YM),
//     Russell 2000 (RTY), VIX (VX), US Dollar Index (DX), Bitcoin (BTC —
//     matches on the CME futures root and, mirroring gold/silver, on
//     basecurrency too, so a spot/CFD BTCUSD chart gets the same data;
//     uses CFTC code 133742, MICRO BITCOIN, not 133741's standard-size
//     BITCOIN contract — the standard contract's own Non-Commercial/
//     Commercial breakdown isn't published as a COT symbol on
//     TradingView at all, confirmed live via TradingView's own symbol
//     search; Micro Bitcoin's positioning is used as a proxy instead,
//     same underlying asset but a different, separately-reported
//     contract, not the exact instrument's own numbers. Confirmed live
//     that the fetch itself works (real, distinct Long/Short numbers
//     come back) — but Micro Bitcoin's own COT track record is still
//     very short, so Trend/Relative/Excel (all of which need a real
//     historical range to color against) can currently degenerate to
//     their neutral-midpoint fallback and paint a white, ~92%-
//     transparent cloud that's invisible against the chart background,
//     not because of a bug but because there isn't enough history yet
//     to say "extreme" relative to. Absolute mode doesn't have this
//     problem — %Long needs no history — so it's the one to use for
//     Bitcoin until Micro Bitcoin's own COT history is long enough for
//     the other modes to have a meaningful range.)
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
//
// Retail CFD/broker charts (confirmed on IC Markets): FX pairs match fine
// — brokers set basecurrency/currency for forex the same way real futures
// do — but index and most commodity CFDs (e.g. IC Markets' own S&P 500)
// generally do NOT auto-match, confirmed live. Their syminfo.root usually
// holds the broker's own raw ticker string instead of a short futures-
// style code, and unlike Gold/Silver's fairly universal "XAU"/"XAG",
// index CFD tickers vary too much broker-to-broker (US500, SPX500,
// SP500, USA500...) for one substring rule to catch them without risking
// a false match on an unrelated symbol. Use the manual symbol inputs for
// an index/commodity CFD chart that shows "no COT match".
//
// Week-of-release lag (not a data mismatch, just how weekly bars work):
// request.security(..., "W", ..., lookahead_off) only reveals a weekly bar
// once it CLOSES. CFTC publishes the new week's report Friday afternoon,
// but that week's own bar doesn't close until the week ends — so from
// Friday's release through the weekend, this indicator is still showing
// LAST week's number, while a spreadsheet updated by hand right after the
// Friday release already has the new one. It catches up once the new
// weekly bar closes (next Monday/Tuesday on most feeds). If a fresh number
// looks "one week behind" on a Friday or over the weekend, this is why —
// not a bug.
indicator("COT Cloud", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Inputs ---------------------------------------------------------------
grp_data = "COT data"
autoDetect    = input.bool(true, "Auto-detect market from chart symbol", group = grp_data, tooltip = "Uses the table in the script header. Turns itself off for any market not in that table, falling back to the manual symbols below.")
nc_long_sym   = input.symbol("099741_F_NCP_L", "Manual Non-Commercial Long (fallback)",  group = grp_data, tooltip = "Used when auto-detect is off, or the current chart's market isn't in the auto table. Default is EUR (verified working). No exchange/provider prefix — the bare code resolves, 'COT:' or 'CFTC:' throws 'invalid symbol'.")
nc_short_sym  = input.symbol("099741_F_NCP_S", "Manual Non-Commercial Short (fallback)", group = grp_data)
comm_long_sym  = input.symbol("099741_F_CP_L", "Manual Commercial Long (fallback)",  group = grp_data)
comm_short_sym = input.symbol("099741_F_CP_S", "Manual Commercial Short (fallback)", group = grp_data)
swapMode = input.string("Auto", "Swap long/short", options = ["Auto", "On", "Off"], group = grp_data, tooltip = "The workbook stores CAD/CHF/JPY long/short swapped versus the raw CFTC numbers, unconditionally for those three currencies (matching contracts.py's swap_legs), regardless of which specific chart or quoting direction you're looking at. Auto infers this from the auto-detected market's currency when auto-detect is on and matched, or from the chart's own base/quote currency otherwise — including on the manual-symbol path. Override with On/Off if you're entering manual symbols for a market Auto can't infer correctly.")

grp_calc = "COT index"
position  = input.string("Non-Commercial", "Position", options = ["Non-Commercial", "Commercial", "Difference"], group = grp_calc, tooltip = "Non-Commercial / Commercial: that side's Long-Short. Difference: Non-Commercial net minus Commercial net, matching the workbook's Difference column — always colored with the Excel scale below, since there's no single Long/Short pair to read a trend from.")
colorMode = input.string("Auto", "Color by", options = ["Auto", "Excel", "Trend", "Absolute", "Relative", "Long %ile", "Short %ile"], group = grp_calc, tooltip = "Auto: Trend for Non-Commercial/Commercial, Excel for Difference. Not chosen by measured performance — see the script header. Excel: reproduces the workbook's own conditional-formatting color scale on its Net Position / Difference columns. Trend: green/red by whether net is above/below its own 13W average — a momentum reading, not a who's-bigger reading, so it can go red while Long still far exceeds Short if net has simply pulled back off a recent peak. Absolute: %Long of total this week — the one mode that directly reflects which side currently dominates, unaffected by history. Relative: percentile of net within the full History window (same adaptive full-history anchors as Excel). Long %ile / Short %ile: same percentile-anchored scale as Excel, but run on that ONE leg by itself instead of Long-Short net — shows a leg nearing its own all-time high directly, without it being diluted by netting against the other leg. Falls back to Excel on Difference (Long/Short don't exist for a pure difference).")
lookback   = input.int(52, "Deviation ceiling (weeks, Trend mode only)", minval = 4, group = grp_calc, tooltip = "How many trailing weeks Trend mode scans to find 'how big does a deviation from the 13-week average normally get' — that ceiling sets the color/opacity intensity. No longer used by Relative mode, which now scans the full History window (like Excel) instead of a fixed lookback — see the script header.")
historyLen = input.int(1043, "History window (weeks, Excel/Relative/%ile modes)", minval = 52, group = grp_calc, tooltip = "Cap on how far back Excel, Relative, Long %ile and Short %ile look for their min/50th-percentile/max anchors (Relative reuses Excel's own anchors, so one setting covers all four). This is a ceiling, not a fixed length: the script counts each market's own actual weekly history and uses min(this value, weeks elapsed), so a market with a shorter CFTC history (e.g. AUD, ~13yr) still gets its own full column like the workbook does, without needing a per-market override.")
avgWeeks = input.int(4, "Weeks to average (Monthly+ charts only)", minval = 1, group = grp_calc, tooltip = "On a chart coarser than weekly (Monthly, Quarterly...), request.security() only samples the single latest real week per outer bar by default — this many trailing real weeks get averaged instead. 4 is roughly 'this month', 13 is roughly 'this quarter'. No effect on Daily/Weekly/intraday charts, which already get a fresh real week on every bar.")

grp_look = "Cloud look"
// A fixed % of price makes the band's SIZE depend on each instrument's own
// volatility relative to its price level, not on anything COT-related — 1.5%
// of EURUSD (~1.16) is close to its whole weekly range, so the cloud swallows
// the chart, while 1.5% of Cocoa (~6000) is a small fraction of its own
// (often double-digit %) weekly swings, so the cloud looks tight. ATR mode
// sizes the band off each instrument's own recent price movement instead, so
// clouds end up comparably sized relative to what's normal for that market.
widthMode = input.string("ATR (auto-scaled)", "Cloud width mode", options = ["ATR (auto-scaled)", "% of price"], group = grp_look, tooltip = "ATR (auto-scaled): band = close +/- multiplier x ATR(length), so the cloud's size tracks each instrument's own volatility — a low-swing pair and a high-swing commodity get comparably-sized clouds relative to their own normal range. % of price: the old fixed-percentage band, if you'd rather tune width by hand per chart.")
atrLen  = input.int(14, "ATR length (bars, ATR mode only)", minval = 1, group = grp_look, tooltip = "Standard ATR on the chart's own timeframe — this only sizes the visual band and has nothing to do with the weekly COT data.")
atrMult = input.float(1.5, "ATR multiplier (ATR mode only)", minval = 0.1, step = 0.1, group = grp_look, tooltip = "Raise for a wider cloud, lower for a tighter one.")
bandPct    = input.float(1.5, "Cloud width (% of price, '% of price' mode only)", minval = 0.1, step = 0.1, group = grp_look) / 100
maxOpacity = input.int(70, "Cloud opacity at extremes (0-100, low = solid)", minval = 0, maxval = 100, group = grp_look)
minOpacity = input.int(92, "Cloud opacity at neutral (50)", minval = 0, maxval = 100, group = grp_look)
colorSmooth = input.int(1, "Color smoothing (bars, 1 = off)", minval = 1, group = grp_look, tooltip = "Averages the color-driving reading over this many bars so the cloud's color, its LONG/SHORT/COOLING state (Trend mode), and its opacity all change gradually instead of jumping with each new week or month, instead of flipping abruptly. On Monthly+ charts this stacks on top of the avgWeeks averaging already applied to the underlying data (COT index group). Try 3 for noticeably smoother transitions. Doesn't touch the number shown for Excel/Difference mode — that stays the true current net position; only its color and border smooth.")

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
// Bitcoin: 133741 ("BITCOIN", the standard-size CME contract, matching
// this indicator's own BTC1! chart) was tried first and confirmed dead —
// neither "133741_F_NCP_L" nor bare "133741" resolves to anything in
// TradingView's symbol search, in either the Futures category or "all
// markets". The standard contract's Non-Commercial/Commercial breakdown
// simply isn't published as a COT symbol on TradingView at all (the code
// itself is real, matches the CFTC report, it's just not exposed here).
// 133742 ("MICRO BITCOIN", CME's separate smaller-sized contract on the
// same underlying) IS exposed, confirmed live via TradingView's own
// symbol search: "133742_F_NCP_S" / "133742_F_CP_S" both resolve to
// "(All)" variants (the live/current one, as opposed to the "(Old)" and
// "(Other)" variants also listed). Using Micro Bitcoin's positioning as
// the proxy for "Bitcoin COT sentiment" on a standard BTC1! chart is a
// deliberate substitution — same underlying asset, different contract
// size — not the exact instrument's own breakdown, since that isn't
// available anywhere on TradingView.
// CFD/spot brokers (confirmed live: IC Markets' Gold Spot/USD and its
// EURUSD) don't populate syminfo.basecurrency/root the way real futures
// contracts or the specific broker feed originally tested here do — EUR
// still matched fine (fx == "EUR", from basecurrency, which IC Markets
// DOES set correctly for its forex pairs), but Gold's CFD symbol left fx
// empty and syminfo.root holding the full ticker string ("XAUUSD")
// instead of a short futures-style code, so neither the fx == "XAU" check
// nor any root == "GC"-style check could ever match it. "XAU"/"XAG" are
// fairly universal substrings across brokers' gold/silver ticker naming
// (unlike index CFDs — see the "still uncovered" note below) even when
// basecurrency isn't populated, so falling back to a substring search
// over root/ticker catches this case without weakening the exact-root
// matches above (those still take priority and are unaffected).
xauFallback = str.contains(root, "XAU") or str.contains(syminfo.ticker, "XAU")
xagFallback = str.contains(root, "XAG") or str.contains(syminfo.ticker, "XAG")
code = fx == "EUR" ? "099741" : fx == "GBP" ? "096742" : fx == "JPY" ? "097741" : fx == "AUD" ? "232741" : fx == "NZD" ? "112741" : fx == "CAD" ? "090741" : fx == "CHF" ? "092741" : root == "NIY" ? "240743" : root == "ES" ? "13874A" : root == "GC" ? "088691" : root == "SI" ? "084691" : root == "HG" ? "085692" : root == "PA" ? "075651" : root == "PL" ? "076651" : root == "ZW" ? "001602" : root == "CT" ? "033661" : root == "ZC" ? "002602" : root == "ZS" ? "005602" : root == "SB" ? "080732" : root == "KC" ? "083731" : root == "CC" ? "073732" : root == "LE" ? "057642" : root == "CL" ? "067651" : root == "NG" ? "023651" : root == "ZT" ? "042601" : root == "ZN" ? "043602" : root == "NQ" ? "209742" : root == "YM" ? "124603" : root == "RTY" ? "239742" : root == "VX" ? "1170E1" : root == "DX" ? "098662" : root == "BTC" ? "133742" : fx == "XAU" ? "088691" : fx == "XAG" ? "084691" : fx == "BTC" ? "133742" : xauFallback ? "088691" : xagFallback ? "084691" : na
// contracts.py's swap_legs is a per-CURRENCY flag (CAD/CHF/JPY only, always
// True for those three, False for everyone else) — the workbook stores
// those three's long/short swapped UNCONDITIONALLY, "so those tabs read as
// USDCAD, USDCHF and USDJPY", regardless of which specific instrument or
// chart orientation you're looking at. An earlier version of this line
// instead swapped based on the CHART's own orientation (base == "USD"),
// which happens to agree with the per-currency rule for a synthetic
// USDCAD/USDCHF/USDJPY spot pair (base=USD there) but disagrees for a CAD/
// CHF/JPY FUTURES contract charted in its own natural direction (e.g.
// MCD1! "Micro CAD/USD Futures", base=CAD, quote=USD) — there base!="USD"
// so the old logic never swapped, silently inverting the whole net series
// (confirmed live: the on-chart debug label's hi/lo for CAD were the exact
// same two numbers as the reference COT table's own MAX/LO, sign-flipped
// and role-swapped — the textbook signature of Long/Short swapped the
// wrong way). Basing it on fx (the identified currency) instead of base
// (which side of the pair is USD) fixes this for every CAD/CHF/JPY chart,
// spot or futures, in either quoting direction.
autoSwap = fx == "CAD" or fx == "CHF" or fx == "JPY"
autoLabel = fx != "" ? fx : xauFallback ? "XAU" : xagFallback ? "XAG" : root

haveAuto        = autoDetect and not na(code)
coverageMissing = autoDetect and na(code)
// Swap used to only apply on the auto-detect path (haveAuto and autoSwap) —
// manual symbols on a real USDCAD/USDCHF/USDJPY chart never got swapped,
// a silent orientation bug of the same kind the auto table itself guards
// against. "Auto" now infers the swap from fx even when auto-detect is off
// or the market isn't covered (fx is derived straight from syminfo, so it's
// available either way), so the manual path gets the same currency-based
// default; On/Off let the user override either way.
effSwap = swapMode == "Auto" ? (haveAuto ? autoSwap : (fx == "CAD" or fx == "CHF" or fx == "JPY")) : swapMode == "On"

ncLongSym   = haveAuto ? code + "_F_NCP_L" : nc_long_sym
ncShortSym  = haveAuto ? code + "_F_NCP_S" : nc_short_sym
cpLongSym   = haveAuto ? code + "_F_CP_L"  : comm_long_sym
cpShortSym  = haveAuto ? code + "_F_CP_S"  : comm_short_sym

// --- Fetch weekly CFTC data -------------------------------------------------
// Always called (Pine requires request.* calls unconditional), but only
// the pair matching "Position" ends up driving the cloud.
// On a chart coarser than weekly (Monthly, Quarterly...), request.security()
// only samples the LAST weekly value as of each outer bar's close — one
// week's snapshot standing in for the whole month, not an aggregate. Request
// a trailing average over "avgWeeks" real weeks instead in that case: the
// expression below always runs in the SYMBOL's own true weekly bars
// regardless of the outer chart's resolution, so ta.sma(close, avgWeeks)
// there is a genuine trailing-N-real-week average, not an average of
// monthly snapshots. Daily/Weekly/intraday charts are unaffected — a fresh
// week already lands on every real weekly close there.
// Each call also pulls the TRUE single-latest-real-week value alongside the
// (possibly avgWeeks-averaged) display value — see the note above devScale/
// coldScale below for why: without it, raising avgWeeks smooths a ratio's
// numerator AND denominator together and visibly changes nothing.
// ta.sma(close, avgWeeks) computed INSIDE a first-level request.security()
// call straight to a COT pseudo-symbol (verified live, twice — with and
// without a tuple) never varies with avgWeeks: it stays byte-identical to
// the single latest week no matter the length. netAvg13 below, which
// computes ta.sma() nested around syminfo.tickerid (the chart's own real
// market symbol) instead, DOES behave correctly and visibly differs from
// the raw value — so ta.sma() itself is fine, but a first-level call
// directly to one of these synthetic economic-data symbols doesn't carry
// real multi-bar history into ta.sma() the way an actual tradable
// instrument does. Fix: fetch the true value from the COT symbol (as
// before), then run ta.sma() on THAT via the same syminfo.tickerid-nested
// pattern netAvg13 already uses successfully.
coarserThanWeekly = timeframe.in_seconds() > timeframe.in_seconds("W")
raw_nc_long_true  = request.security(ncLongSym,  "W", close, lookahead = barmerge.lookahead_off)
raw_nc_short_true = request.security(ncShortSym, "W", close, lookahead = barmerge.lookahead_off)
raw_cp_long_true  = request.security(cpLongSym,  "W", close, lookahead = barmerge.lookahead_off)
raw_cp_short_true = request.security(cpShortSym, "W", close, lookahead = barmerge.lookahead_off)
raw_nc_long_avg   = request.security(syminfo.tickerid, "W", ta.sma(raw_nc_long_true, avgWeeks), lookahead = barmerge.lookahead_off)
raw_nc_short_avg  = request.security(syminfo.tickerid, "W", ta.sma(raw_nc_short_true, avgWeeks), lookahead = barmerge.lookahead_off)
raw_cp_long_avg   = request.security(syminfo.tickerid, "W", ta.sma(raw_cp_long_true, avgWeeks), lookahead = barmerge.lookahead_off)
raw_cp_short_avg  = request.security(syminfo.tickerid, "W", ta.sma(raw_cp_short_true, avgWeeks), lookahead = barmerge.lookahead_off)
raw_nc_long   = coarserThanWeekly ? raw_nc_long_avg  : raw_nc_long_true
raw_nc_short  = coarserThanWeekly ? raw_nc_short_avg : raw_nc_short_true
raw_cp_long   = coarserThanWeekly ? raw_cp_long_avg  : raw_cp_long_true
raw_cp_short  = coarserThanWeekly ? raw_cp_short_avg : raw_cp_short_true

nc_long  = effSwap ? raw_nc_short : raw_nc_long
nc_short = effSwap ? raw_nc_long  : raw_nc_short
cp_long  = effSwap ? raw_cp_short : raw_cp_long
cp_short = effSwap ? raw_cp_long  : raw_cp_short
nc_long_true  = effSwap ? raw_nc_short_true : raw_nc_long_true
nc_short_true = effSwap ? raw_nc_long_true  : raw_nc_short_true
cp_long_true  = effSwap ? raw_cp_short_true : raw_cp_long_true
cp_short_true = effSwap ? raw_cp_long_true  : raw_cp_short_true

nc_net     = nc_long - nc_short
cp_net     = cp_long - cp_short
difference = nc_net - cp_net

isDifference = position == "Difference"
activeLong  = position == "Non-Commercial" ? nc_long  : position == "Commercial" ? cp_long  : na
activeShort = position == "Non-Commercial" ? nc_short : position == "Commercial" ? cp_short : na
activeLong_true  = position == "Non-Commercial" ? nc_long_true  : position == "Commercial" ? cp_long_true  : na
activeShort_true = position == "Non-Commercial" ? nc_short_true : position == "Commercial" ? cp_short_true : na
activeNet   = position == "Non-Commercial" ? nc_net   : position == "Commercial" ? cp_net   : difference
activeNet_true = activeLong_true - activeShort_true

// Smoothed copies, used ONLY for color/state decisions below (which mode's
// state to show, how intense the color/opacity is) — cotText's displayed
// number for Excel/Difference still reads the raw activeNet, so the label
// always shows the true current net position even when colorSmooth > 1.
f_smooth(src) => colorSmooth > 1 ? ta.sma(src, colorSmooth) : src
smLong  = f_smooth(activeLong)
smShort = f_smooth(activeShort)
smNet   = f_smooth(activeNet)

// "Auto" resolves to a concrete mode up front so everything below just reads
// resolvedMode — Excel for Difference (the only mode a pure difference can
// use), Trend for everything else.
resolvedMode = colorMode == "Auto" ? (isDifference ? "Excel" : "Trend") : colorMode

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
// "1043" is a CAP, not a fixed length: the workbook's own history isn't
// the same size for every market (e.g. AUD's tab is ~674 weeks, EURO's
// ~996, DXY's ~1130 — a newer contract's CFTC history is just shorter).
// f_excelStats counts the actual weekly bars elapsed (n) inside the "W"
// context itself and caps the lookback at min(historyLen, n+1), so the
// window never reaches past a market's real available history — matching
// "scans its whole column" precisely instead of assuming every market's
// column is the same length.
// f_excelStats takes the source series as an argument (rather than closing
// over activeNet directly) so the SAME function can be called separately for
// Net, Long, and Short below — each call site gets its own independent "var
// n" counter in Pine, so the three don't interfere with each other.
f_excelStats(src, len) =>
    var int n = -1
    n := n + 1
    effLen = math.min(len, n + 1)
    [ta.highest(src, effLen), ta.lowest(src, effLen), ta.percentile_linear_interpolation(src, effLen, 50), effLen]
// Fill-endpoint colors at 100% (max/min) — darkened from the workbook's own
// pastel conditional-formatting colors (248,105,107 / 99,190,123) so the
// extreme end of the scale reads as clearly colored, not just pale pink/mint.
colFillRed   = color.rgb(214, 47, 47)
colFillGreen = color.rgb(46, 139, 87)
[hiExcel, loExcel, p50Excel, effLenExcel] = request.security(syminfo.tickerid, "W", f_excelStats(activeNet, historyLen), lookahead = barmerge.lookahead_off)
belowP50 = smNet <= p50Excel
segLo    = belowP50 ? loExcel : p50Excel
segHi    = belowP50 ? p50Excel : hiExcel
excelColor    = segLo == segHi ? color.white : color.from_gradient(smNet, segLo, segHi, belowP50 ? colFillRed : color.white, belowP50 ? color.white : colFillGreen)
excelBorder   = smNet < 0 ? color.rgb(165, 0, 33) : color.rgb(0, 116, 52)
excelIntensity = segLo == segHi ? 0.0 : math.min(math.abs(smNet - p50Excel) / math.abs(segHi - segLo) * 100.0, 100.0)

// --- Long %ile / Short %ile: same percentile-anchored scale as Excel above,
// but run on the LEG itself instead of the Long-Short net, so "Short is near
// its own all-time high" shows up directly instead of being diluted by
// netting against Long (which can rise at the same time and mute Net's own
// move). Long follows Net's convention (high = green, bullish); Short is
// inverted (high = red, since a bigger short leg is the bearish direction).
[hiLongExcel, loLongExcel, p50LongExcel, effLenLong] = request.security(syminfo.tickerid, "W", f_excelStats(activeLong, historyLen), lookahead = barmerge.lookahead_off)
belowP50Long = smLong <= p50LongExcel
segLoLong    = belowP50Long ? loLongExcel : p50LongExcel
segHiLong    = belowP50Long ? p50LongExcel : hiLongExcel
longColor     = segLoLong == segHiLong ? color.white : color.from_gradient(smLong, segLoLong, segHiLong, belowP50Long ? colFillRed : color.white, belowP50Long ? color.white : colFillGreen)
longBorder    = smLong >= p50LongExcel ? color.rgb(0, 116, 52) : color.rgb(165, 0, 33)
longIntensity = segLoLong == segHiLong ? 0.0 : math.min(math.abs(smLong - p50LongExcel) / math.abs(segHiLong - segLoLong) * 100.0, 100.0)

[hiShortExcel, loShortExcel, p50ShortExcel, effLenShort] = request.security(syminfo.tickerid, "W", f_excelStats(activeShort, historyLen), lookahead = barmerge.lookahead_off)
belowP50Short = smShort <= p50ShortExcel
segLoShort    = belowP50Short ? loShortExcel : p50ShortExcel
segHiShort    = belowP50Short ? p50ShortExcel : hiShortExcel
shortColor     = segLoShort == segHiShort ? color.white : color.from_gradient(smShort, segLoShort, segHiShort, belowP50Short ? colFillGreen : color.white, belowP50Short ? color.white : colFillRed)
shortBorder    = smShort >= p50ShortExcel ? color.rgb(165, 0, 33) : color.rgb(0, 116, 52)
shortIntensity = segLoShort == segHiShort ? 0.0 : math.min(math.abs(smShort - p50ShortExcel) / math.abs(segHiShort - segLoShort) * 100.0, 100.0)

// --- Absolute / Relative (Non-Commercial or Commercial only) -------------
pctLong = (smLong + smShort) == 0 ? 50.0 : smLong / (smLong + smShort) * 100.0
// Relative used to scan only a fixed trailing "lookback" window (52 weeks
// by default, mirroring cot/transform.py::_cot_index) — on a market that
// trended hard within that window (CAD ran net +31k -> +179k and back to
// +70k, Long still 2-4x Short the whole time), the window's own high/low
// moved WITH the trend, so a still-strongly-long net priced out near the
// MIDDLE of its own recent range and read as neutral/red — same failure
// mode as Trend's own-13w-average comparison, just with a wider window.
// Reusing hiExcel/loExcel (the full-history, historyLen-capped anchors
// Excel already computes above) instead fixes this: a net that's still far
// from its true all-time low reads as clearly long-dominant, no matter how
// far it has pulled back from a recent peak.
pctRelative = hiExcel == loExcel ? 50.0 : (smNet - loExcel) / (hiExcel - loExcel) * 100.0

// --- Trend (Non-Commercial or Commercial only) ----------------------------
// "13-week average" only means 13 weeks if ta.sma runs on real weekly
// bars — same "W" resample fix as above, applied to every lookback here.
longAvg13   = request.security(syminfo.tickerid, "W", ta.sma(activeLong, 13), lookahead = barmerge.lookahead_off)
shortAvg13  = request.security(syminfo.tickerid, "W", ta.sma(activeShort, 13), lookahead = barmerge.lookahead_off)
bothCooling = smLong < longAvg13 and smShort < shortAvg13
netAvg13    = request.security(syminfo.tickerid, "W", ta.sma(activeNet, 13), lookahead = barmerge.lookahead_off)
devAbs      = math.abs(smNet - netAvg13)
// devScale/coldScale are the "how big does this deviation normally get"
// ceiling that devAbs/coldAbs get divided by — if that ceiling were built
// from the SAME avgWeeks/colorSmooth-smoothed values as the numerator,
// raising avgWeeks would shrink both together and the resulting % (hence
// the color) would barely move, which is exactly what was reported: no
// visible change even at avgWeeks=24. Building the ceiling from the TRUE
// (always single-latest-real-week) values instead keeps it fixed
// regardless of avgWeeks/colorSmooth, so heavier smoothing on the
// numerator now visibly tames the color, as expected.
devAbsTrue  = math.abs(activeNet_true - netAvg13)
devScale    = request.security(syminfo.tickerid, "W", ta.highest(devAbsTrue, lookback), lookahead = barmerge.lookahead_off)
skew        = devScale == 0 ? 0.0 : devAbs / devScale * 100.0
longDominant = smNet >= netAvg13
coldAbs     = math.max(longAvg13 - smLong, 0) + math.max(shortAvg13 - smShort, 0)
coldAbsTrue = math.max(longAvg13 - activeLong_true, 0) + math.max(shortAvg13 - activeShort_true, 0)
coldScale = request.security(syminfo.tickerid, "W", ta.highest(coldAbsTrue, lookback), lookahead = barmerge.lookahead_off)
coldPct   = coldScale == 0 ? 0.0 : coldAbs / coldScale * 100.0
coldColor = color.from_gradient(coldPct, 0, 100, color.new(#a9d6f5, 0), color.new(#0a2a5e, 0))
trendColor = bothCooling ? coldColor : longDominant ? color.from_gradient(skew, 0, 100, color.white, color.green) : color.from_gradient(skew, 0, 100, color.white, color.red)
trendState = bothCooling ? "COOLING" : longDominant ? "LONG" : "SHORT"
trendIntensity = bothCooling ? coldPct : skew

// --- Pick the active mode --------------------------------------------------
// Long %ile/Short %ile need activeLong/activeShort, which are na for
// Difference (there's no single leg to read) — fall back to Excel there,
// same guard as useExcel already applies to resolvedMode == "Excel".
useExcel      = isDifference or resolvedMode == "Excel"
useLongPctile = not isDifference and resolvedMode == "Long %ile"
useShortPctile = not isDifference and resolvedMode == "Short %ile"
idx = useLongPctile ? longIntensity : useShortPctile ? shortIntensity : resolvedMode == "Absolute" ? pctLong : resolvedMode == "Trend" ? trendIntensity : resolvedMode == "Excel" ? excelIntensity : pctRelative

gradColor  = useExcel ? excelColor : useLongPctile ? longColor : useShortPctile ? shortColor : resolvedMode == "Trend" ? trendColor : idx >= 50 ? color.from_gradient(idx, 50, 100, color.white, color.green) : color.from_gradient(idx, 0, 50, color.red, color.white)
lineColor  = useExcel ? excelBorder : useLongPctile ? longBorder : useShortPctile ? shortBorder : gradColor
opacity    = useExcel ? math.round(minOpacity - excelIntensity / 100 * (minOpacity - maxOpacity)) : useLongPctile ? math.round(minOpacity - longIntensity / 100 * (minOpacity - maxOpacity)) : useShortPctile ? math.round(minOpacity - shortIntensity / 100 * (minOpacity - maxOpacity)) : resolvedMode == "Trend" ? math.round(minOpacity - trendIntensity / 100 * (minOpacity - maxOpacity)) : math.round(minOpacity - math.abs(idx - 50) / 50 * (minOpacity - maxOpacity))

// --- Extreme reading (top/bottom 20% of idx, mode-aware). This says only
// that positioning sits at the edge of its own range. The note that stood
// here cited a quintile spread as evidence of a concentrated edge; that
// spread flips sign by sub-period in every market tested, so it is not
// offered as evidence of anything. Direction, where there is any at all,
// differs by market.
// idx means two different shapes of thing depending on mode, found by
// auditing this exact "idx <= 20" line: Absolute/Relative are a true
// symmetric 0-100 percentile (50 = neutral, 0 = extreme low, 100 =
// extreme high), so both ends genuinely mean "extreme". Excel/Trend/Long
// %ile/Short %ile are a one-sided INTENSITY — 0 at their own median/13w
// average (neutral), 100 at max deviation in EITHER direction (already
// reflected in the color/sign) — for those, a LOW idx means "close to
// neutral", not extreme, so treating idx <= 20 as extreme for them was
// backwards: it fired constantly on ordinary, unremarkable readings
// (anything sitting near its own median/average) rather than on genuine
// extremes, on 4 of the 7 modes including the Trend default.
isIntensityMode = useExcel or useLongPctile or useShortPctile or resolvedMode == "Trend"
isExtreme = not coverageMissing and (idx >= 80 or (not isIntensityMode and idx <= 20))

// --- Cloud around price (na when the market isn't covered, so nothing
// draws instead of silently showing another market's COT data) -----------
bandWidth = widthMode == "ATR (auto-scaled)" ? atrMult * ta.atr(atrLen) : close * bandPct
upperBand = coverageMissing ? na : close + bandWidth
lowerBand = coverageMissing ? na : close - bandWidth

// Upper/Lower are just price offsets (cloud edges), not COT data — kept
// off the status-line hover row and Data Window (display.pane +
// price_scale only) so hovering the chart shows the actual COT numbers
// (COT Index/Active Long/Short/Net below) without two price values ahead
// of them.
upperPlot = plot(upperBand, "Upper", color = lineColor, linewidth = 1, display = display.pane + display.price_scale)
lowerPlot = plot(lowerBand, "Lower", color = lineColor, linewidth = 1, display = display.pane + display.price_scale)
fill(upperPlot, lowerPlot, color = color.new(gradColor, opacity), title = "COT cloud")

// --- Readout ---------------------------------------------------------------
posAbbrev = position == "Non-Commercial" ? "NC" : position == "Commercial" ? "COMM" : "DIFF"
cotText = useExcel ? posAbbrev + " " + str.format("{0,number,#}", activeNet) : useLongPctile ? posAbbrev + " LONG " + str.format("{0,number,#}", activeLong) : useShortPctile ? posAbbrev + " SHORT " + str.format("{0,number,#}", activeShort) : resolvedMode == "Trend" ? posAbbrev + " " + trendState + " " + str.format("{0,number,#}", trendIntensity) : posAbbrev + " " + str.format("{0,number,#}", idx)
// "swapped" used to only ever print on the manual-symbol label branch — on
// the auto-detect path (the far more common case) there was no way to see
// from the chart itself whether a swap was actually applied, which is
// exactly what made the CAD swap-direction bug invisible until debug
// numbers were printed by hand. Now prints on both branches.
labelText = coverageMissing ? "No auto COT match for " + (fx != "" ? fx : root) + " — set manual symbols" : cotText + (haveAuto ? " [" + autoLabel + (effSwap ? ", swapped" : "") + "]" : " [manual" + (effSwap ? ", swapped" : "") + "]") + (coarserThanWeekly ? " avg" + str.tostring(avgWeeks) + "w" : "") + (isExtreme ? " ⚠" : "")
labelColor = coverageMissing ? color.gray : gradColor
// A small extra gap above upperBand, scaled to the cloud's own width
// (not a fixed price offset, so it stays proportionate on any instrument
// at any zoom level) — sitting the label right at the band edge put it
// under/behind candle wicks whenever the cloud was narrow.
labelY = coverageMissing ? close : upperBand + bandWidth * 0.15
var label idxLabel = na
label.delete(idxLabel)
idxLabel := label.new(bar_index, labelY, labelText, style = label.style_label_down, color = color.new(labelColor, 20), textcolor = coverageMissing or useExcel or useLongPctile or useShortPctile or resolvedMode == "Trend" or idx > 60 or idx < 40 ? color.white : color.black, size = size.small)

// Which side the triangle's extreme actually belongs to depends on mode:
// Excel/Difference read off the NET's own position (near its record low
// = short-dominant extreme, near its record high = long-dominant); Long
// %ile/Short %ile already isolate one leg, so it's that leg's own record
// high or low; Trend reads off dominance vs. the 13-week average (or
// "both cooling" when neither leg is currently building); Absolute/
// Relative are the only two where idx itself (>=80 or <=20) directly says
// which side, since those are true symmetric percentiles.
extremeDir = useExcel ? (belowP50 ? "Short-dominant extreme (net near its record low)" : "Long-dominant extreme (net near its record high)") : useLongPctile ? (belowP50Long ? "Long near its own historical low" : "Long near its own historical high") : useShortPctile ? (belowP50Short ? "Short near its own historical low" : "Short near its own historical high") : resolvedMode == "Trend" ? (bothCooling ? "Both Long and Short cooling vs. their own 13-week average" : longDominant ? "Long-dominant vs. its own 13-week average" : "Short-dominant vs. its own 13-week average") : idx >= 80 ? "Long-dominant extreme" : "Short-dominant extreme"
extremeTooltip = extremeDir + "\nLong: " + str.format("{0,number,#}", activeLong) + "   Short: " + str.format("{0,number,#}", activeShort) + "   Net: " + str.format("{0,number,#}", activeNet)
// plotshape() has no tooltip argument in Pine v6 (confirmed: compile
// error CE10120) — only label objects support one. A label per extreme
// bar, never deleted, reproduces the same permanent-historical-marker
// look plotshape had, just with a hover tooltip added; needs
// max_labels_count raised well past its default 50, since a market with
// many historical extremes would otherwise silently drop the oldest
// ones. label.new() has no "location" argument either (that's a
// plotshape/plotchar-only parameter, confirmed: same CE10120) — giving
// it lowerBand directly as y already positions it exactly there, no
// location mode needed.
// Only draw on the bar where the reading FIRST enters extreme territory,
// not on every bar it stays there — an extended extreme episode used to
// draw one triangle per week for its whole length, which is redundant
// (the label's own ⚠ already marks "currently extreme" for as long as it
// lasts). This mirrors the alertcondition below, which already used the
// transition-only pattern. Deliberately not "only on a literal new
// all-time record": idx is itself a rolling percentile (recomputed every
// bar against a rolling window), so comparing it against its own past
// values to detect "a genuinely new max" would reproduce the exact bug
// just fixed in the CHF debug marker — it matched on nearly every bar,
// not just the one true record.
if isExtreme and not isExtreme[1]
    label.new(bar_index, lowerBand, "", style = label.style_triangleup, color = color.new(color.orange, 0), size = size.tiny, tooltip = extremeTooltip)
alertcondition(isExtreme and not isExtreme[1], title = "COT Cloud — extreme reading", message = "COT positioning is in the top or bottom 20% of its own range. This is a range reading, not a directional signal.")

// The 4 values below also carry display.status_line, so they show up in
// the small hover-values row at the top of the pane as you move the
// crosshair across bars — mousing over the cloud reads its numbers
// directly, no need to open Data Window for a quick check. Not added to
// nc_net/cp_net/difference (still Data-Window-only) to keep that row from
// getting crowded; those three stay a Data Window-only detail view.
plot(idx, "COT Index", display = display.data_window + display.status_line)
plot(activeLong, "Active Long", display = display.data_window + display.status_line)
plot(activeShort, "Active Short", display = display.data_window + display.status_line)
plot(activeNet, "Active Net", display = display.data_window + display.status_line)
plot(nc_net, "Non-Commercial Net", display = display.data_window)
plot(cp_net, "Commercial Net", display = display.data_window)
plot(difference, "Difference (NC - Comm)", display = display.data_window)
````
