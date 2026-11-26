# Ehlers Adaptive Trend Filter + Consensus Engine v13

- url: https://www.tradingview.com/script/cBJ5WEqN-Ehlers-Adaptive-Trend-Filter-Consensus-Engine-v13/
- type: indicator
- pine_id: PUB;9f2afd361ad24ca1a9d8dcbd9e812a69
- version: 4.0

## Description

Ehlers Adaptive Trend Filter + Consensus Engine

WHAT IT DOES

This screener reads a universe of up to 40 tickers through three independent Ehlers filter pairs running in parallel on every name, then groups the names by how many of the three filters agree the trend is up. The grouping is the "phase"; the intensity and direction of each name's move is the "temperature". It describes the structural state of each name. It does not tell you what to trade.

Because the three filters react at different speeds, the number that agree is a measure of how broadly a trend is confirmed across timescales: a move that only the fastest filter sees is early or fragile; a move all three see is broadly confirmed.

THE THREE FILTERS

Fast (2-pole SuperSmoother): the most reactive. It turns first and catches short-cycle moves, at the cost of more false turns.

Core (3-pole + 2-pole): the balanced middle. Slower to turn, steadier once it does. In most conditions it is the strongest single read.

Adaptive (MAMA/FAMA): retunes itself to the dominant detected cycle rather than using a fixed period. It often turns before the other two at a genuine cycle change, which is why an Adaptive-only signal is treated as an early, unconfirmed one.

THE FOUR PHASES

Heated: all three filters agree the trend is up. The fullest agreement the engine measures.
Liquid: two of three agree; one dissents. The dissenter is where the interest lies.
Thawing: one of three agrees. The earliest single-timescale turn, not yet confirmed.
Frozen: none agree. No bullish consensus.

Within each phase a per-row temperature word (Boiling, Hot, Simmering, Warming, Cooling, Cold, Freezing) describes how far the name sits from its own normal range and whether that separation is rising or falling. Direction is shown by an arrow, so "Boiling" means an extreme move regardless of sign.

READING A ROW

A Heated-phase row might read:

  NVDA (up) 14b  C:1.8  F(up)+12.4 Co(up)+9.1 A(up)+15.2  [+6.3%]  ->  Heated . Boiling (up)

That is: NVDA, 63-bar direction up, 14 bars in its current phase, Calmar 1.8; all three filters bullish with their separations from baseline in percent (Fast +12.4, Core +9.1, Adaptive +15.2); stop distance to the Core baseline +6.3 percent; and the state tag, Heated . Boiling (up) - all three aligned, an extreme-magnitude move, rising.

The engine also flags "clusters": several names dissenting the same way at once (Adaptive turning bearish under apparent strength, or bullish under apparent weakness), which is structural pressure forming across the universe rather than in a single name.

HOW TO READ IT, NOT WHAT TO DO

This tool is descriptive. It reports what the filters show: which names are in which phase, how hot or cold each move is, and where broad pressure is building. It does not generate buy or sell instructions, position sizes, or price targets, and nothing in it should be read as financial advice. What you do with the information is your own decision.

CREDITS

Method: the MAMA/FAMA (MESA Adaptive Moving Average) algorithm and the SuperSmoother filters are John Ehlers' work (MAMA paper: mesasoftware.com/papers/MAMA.pdf).

Implementation: the MAMA/FAMA Pine derives from [url=https://www.tradingview.com/script/foQxLbU3-Ehlers-MESA-Adaptive-Moving-Average-LazyBear/]Ehlers MESA Adaptive Moving Average by LazyBear[/url], an open-source script, refactored here from series form into a per-ticker state architecture. Credit and thanks to LazyBear for the original.

Original in this script: the multi-ticker consensus engine, the phase and temperature classification, and the cluster detection are my own work. Released open-source under MPL-2.0.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendMatrix_Labs
// ════════════════════════════════════════════════════════════════════════════
// EHLERS ADAPTIVE TREND FILTER + CONSENSUS ENGINE
// ════════════════════════════════════════════════════════════════════════════
// ── ATTRIBUTION ─────────────────────────────────────────────────────────────
// METHOD: MAMA/FAMA (MESA Adaptive Moving Average) by John F. Ehlers.
//   Reference: "MESA Adaptive Moving Average", Stocks & Commodities, Aug 2001;
//   mesasoftware.com/papers/MAMA.pdf. SuperSmoother filters also per Ehlers.
// IMPLEMENTATION: the MAMA/FAMA Pine derives from LazyBear's open-source
//   "Ehlers MESA Adaptive Moving Average [LazyBear]"
//   (tradingview.com/script/foQxLbU3-Ehlers-MESA-Adaptive-Moving-Average-LazyBear/),
//   refactored here from series-indexed form into a per-ticker UDT/state
//   architecture with history-buffer indexing.
// ORIGINAL: the multi-ticker consensus engine (three weighted filter pairs),
//   the phase classification (Heated/Liquid/Thawing/Frozen), the temperature
//   scale, and the Adapt-cluster detection are the author's own work.
// This derivative work licensed MPL-2.0; LazyBear original credited as source.
// ────────────────────────────────────────────────────────────────────────────
// WHAT THIS DOES:
//   Screens a universe of tickers through three independent Ehlers filter
//   pairs (Fast 2p+2p, Core 3p+2p, Adaptive MAMA/FAMA) run in parallel on
//   every name. It groups names by how many filters agree (the phase) and
//   describes the intensity and trend of each move (the temperature). It
//   reports structural state; it does not issue trade instructions.
// ════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Ehlers Adaptive Trend Filter + Consensus Engine v14", shorttitle="EATF+CE v14", overlay=true, precision=2)

// =============================================================================
// 1. CALIBRATION INPUTS
// =============================================================================
auto_mode = input.bool(true, "Enable Auto-Optimization", group="Calibration",
     tooltip="Automatically scales the FAST signal period and slow ANCHOR baseline period to match your chart's timeframe, so the indicator behaves consistently across daily, weekly, and intraday charts.\n\nON (recommended):\n  • Weekly: 52 signal / 104 anchor (~1 year)\n  • Daily:  126 signal / 252 anchor (~half year + year)\n  • Hourly: 60 / 120 (~1 trading week)\n  • <1H:    60 / 90\n\nOFF: Manual override inputs unlock below. Use only with a tested reason.\n\nNote: No effect on MAMA/FAMA mode — that filter is self-adaptive to the dominant detected cycle.")

var int dynamic_anchor = 181
var int dynamic_detox  = 90

if auto_mode
    dynamic_detox := timeframe.isweekly ? 52 :
                     timeframe.isdaily  ? 126 :
                     timeframe.isintraday and timeframe.multiplier < 60 ? 60 : 90
    dynamic_anchor := dynamic_detox * 2
else
    dynamic_anchor := input.int(181, "Manual Anchor (Baseline Period)", group="Calibration",
         tooltip="The slow baseline period. Defines how far back the indicator looks to establish 'normal' price behavior — the line price must stay above to register as 'in trend'.\n\nRule of thumb: 2× the Signal Period.\n\nLonger values = smoother baseline, slower to react to regime change, fewer whipsaws.\nShorter values = more responsive, more false signals.\n\nDefault 181 ≈ ~9 months on daily charts. Common alternatives: 126 (half year), 252 (full year).")
    dynamic_detox  := input.int(90, "Manual Signal (Filter Period)", group="Calibration",
         tooltip="The faster signal period. Defines how reactive the smoothed price line is to recent moves.\n\nRule of thumb: half the Anchor Period.\n\nShorter values catch trend changes earlier but produce more false signals.\nLonger values lag price but filter noise more aggressively.\n\nDefault 90 ≈ one quarter on daily charts — a balanced 'medium-term trend' setting.")

int m_anchor  = dynamic_anchor
int m_detox   = dynamic_detox
baseline_mult = input.float(1.0, "Baseline Height Multiplier", minval=0.1, maxval=5.0, step=0.05, group="Calibration",
     tooltip="Scales the support baseline above its raw computed value, demanding more price strength to qualify as 'in trend'.\n\n1.0 = unmodified (default).\n> 1.0 = raises the floor → stricter, fewer false uptrend signals, but late entries.\n< 1.0 = lowers the floor → more permissive, more whipsaws.\n\nUseful when screening high-noise assets (small caps, crypto) where the default baseline is crossed too easily.\n\nNo effect on MAMA/FAMA mode — that filter computes its own adaptive floor (FAMA).")
float PI = 2 * math.asin(1.0)

filter_config = input.string("MAMA/FAMA (Adaptive)", "Chart Filter Configuration",
     options=["2p+2p (Fast)", "3p+2p (Hybrid)", "3p+3p (Smooth)", "MAMA/FAMA (Adaptive)"],
     group="Calibration",
     tooltip="Selects the filter pair used to draw the line and floor on the CHART ticker only.\n\n  • 2p+2p (Fast): ~62 bars lag. Most reactive, noisiest. For active trading.\n  • 3p+2p (Hybrid): ~70 bars lag. Balanced default — reactive but stable.\n  • 3p+3p (Smooth): ~88 bars lag. Cleanest line, slowest signals. For long-term holding.\n  • MAMA/FAMA: Auto-adapts to the dominant detected market cycle. Best for choppy or regime-shifting markets.\n\nIMPORTANT: Does NOT affect the screener.\nThe Consensus Engine always runs all THREE filter pairs (FAST = 2p+2p, CORE = 3p+2p, ADAPTIVE = MAMA/FAMA) in parallel for every universe ticker. That's how it derives consensus — by checking whether multiple independent filters agree.")

float mama_FastLimit = input.float(0.5,  "MAMA Fast Limit (α max)", minval=0.01, maxval=0.99, step=0.01, group="Calibration",
     tooltip="MAMA's maximum smoothing constant (α-max). Controls how fast MAMA can react when it detects a clean cycle change.\n\n0.5 = Ehlers' published default. Most documented setups use this.\nHigher (→0.99) = more reactive, less smoothing — catches turns faster but more false flips.\nLower (→0.1) = slower response, smoother output — less false signals but late.\n\nAffects BOTH the chart in MAMA/FAMA mode AND the Adaptive filter in the screener (used for every ticker).")
float mama_SlowLimit = input.float(0.05, "MAMA Slow Limit (α min)", minval=0.001, maxval=0.5,  step=0.005, group="Calibration",
     tooltip="MAMA's minimum smoothing constant (α-min). Acts as a floor on responsiveness — the slowest MAMA can move during sideways or low-cycle periods.\n\n0.05 = Ehlers' published default.\nHigher (→0.5) = faster minimum response, less max smoothing during chop.\nLower (→0.001) = allows very deep smoothing in sideways markets, very slow turns.\n\nAffects BOTH the chart in MAMA/FAMA mode AND the Adaptive filter in the screener.")

// =============================================================================
// 2. UNIVERSE INPUT
// =============================================================================

// ── Hardcoded preset constants ─────────────────────────────────────────────
string DEF_NASDAQ = "NASDAQ:NVDA, NASDAQ:AVGO, NASDAQ:AMD, NASDAQ:ARM, NASDAQ:MU, NASDAQ:SNDK, NASDAQ:MRVL, NYSE:TSM, NASDAQ:LRCX, NASDAQ:AMAT, NASDAQ:KLAC, NASDAQ:ASML, NYSE:ANET, NASDAQ:SMCI, NYSE:DELL, NYSE:HPE, NASDAQ:MSFT, NASDAQ:GOOGL, NASDAQ:META, NASDAQ:AMZN, NYSE:ORCL, NYSE:VRT, NYSE:ETN, NYSE:PWR, NYSE:HUBB, NYSE:JCI, NYSE:TT, NYSE:GEV, NASDAQ:CEG, NYSE:VST, NYSE:CCJ, NASDAQ:EQIX, NYSE:DLR, NASDAQ:QQQ, NASDAQ:SMH, AMEX:SPY"
string DEF_GOLD   = "NYSE:NEM, NYSE:GOLD, NYSE:AEM, NYSE:AU, NASDAQ:AYA, NYSE:GFI, NYSE:KGC, ASX:NST, ASX:EVN, NYSE:AGI, NYSE:EGO, TSX:VZLA, NYSE:IAG, NYSE:HMY, AMEX:EQX, NYSE:CGAU, NASDAQ:SSRM, NYSE:CDE, AMEX:BTG, NYSE:SBSW, ASX:WGX, ASX:RMS, ASX:RRL, ASX:GMD, NYSE:PAAS, NYSE:HL, NYSE:FSM, NYSE:FNV, NYSE:WPM, NASDAQ:RGLD, NYSE:OR, AMEX:GDX, AMEX:GDXJ, AMEX:SIL, AMEX:SILJ, NASDAQ:AUGO"
string DEF_BIO    = "NYSE:LLY, NYSE:PFE, NYSE:JNJ, NYSE:MRK, NYSE:ABBV, NYSE:BMY, NYSE:AZN, NYSE:NVO, NYSE:NVS, NYSE:GSK, NASDAQ:AMGN, NASDAQ:GILD, NASDAQ:VRTX, NASDAQ:REGN, NASDAQ:BIIB, NASDAQ:ILMN, NASDAQ:MRNA, NASDAQ:ALNY, NASDAQ:ARGX, NASDAQ:BNTX, NASDAQ:RPRX, NASDAQ:SRPT, NASDAQ:INCY, NASDAQ:BMRN, NASDAQ:NBIX, NASDAQ:EXEL, NASDAQ:JAZZ, NASDAQ:UTHR, NASDAQ:NTRA, NASDAQ:HALO, NASDAQ:CRSP, NASDAQ:NTLA, NASDAQ:BEAM, NASDAQ:IBB, AMEX:XBI, AMEX:ARKG"
string DEF_NRG    = "NYSE:OVV, NYSE:XOM, NYSE:CVX, NYSE:COP, NYSE:OXY, NYSE:EQNR, NASDAQ:FANG, NYSE:DVN, NYSE:EOG, NYSE:PR, NASDAQ:APA, NYSE:CNQ, NYSE:CVE, NYSE:SU, NYSE:VLO, NYSE:MPC, NYSE:PSX, NYSE:DINO, NYSE:SLB, NYSE:HAL, NASDAQ:BKR, NYSE:NOV, NASDAQ:WFRD, NYSE:ENB, NYSE:WMB, NYSE:KMI, NYSE:OKE, NYSE:TRGP, NYSE:LNG, NYSE:EQT, NYSE:AR, AMEX:XLE, AMEX:OIH, AMEX:XOP, AMEX:USO, AMEX:UNG"

// ── Active universe selector ──────────────────────────────────────────────
universe_select = input.string("NASDAQ", "Active Universe",
     options=["NASDAQ", "Gold Miners", "Bioscience", "Energy"], group="Universe",
     tooltip="Picks which universe the Consensus Engine actually screens on this chart.\n\nEach universe has its own Mode toggle and a custom text-area slot below — the selector chooses which of those four resolved strings feeds the parser.\n\nOnly the SELECTED universe consumes request.security() calls — the others sit dormant in inputs until you switch.\n\n40-ticker cap applies per active universe AFTER Mode resolution + chart-symbol prepend, with automatic deduplication so duplicate tickers never double-bill against the cap.")

// ── Per-slot Mode toggles ─────────────────────────────────────────────────
mode_nasdaq = input.string("Default", "NASDAQ — Mode",
     options=["Default", "Custom", "Merge"], group="Universe",
     tooltip="Controls how the NASDAQ universe is resolved:\n\n  • Default — uses the hardcoded DEF_NASDAQ list only (36 tickers: 33 curated AI/power/data-center names + QQQ, SMH, XLU, IBB, SPY benchmarks); the Custom text area is ignored (your edits stay saved but inactive). Use this to run the curated baseline without having to clear custom edits.\n  • Custom — uses ONLY whatever is in the Custom text area below; hardcoded list ignored. If you leave the text area empty, the universe is empty.\n  • Merge — concatenates hardcoded + Custom (hardcoded first, then Custom). Useful for adding 2-3 tactical names to the baseline without rewriting it.\n\nDedup is automatic across hardcoded + custom + chart-symbol — no double-billing of the request.security() budget.")

mode_gold = input.string("Default", "Gold Miners — Mode",
     options=["Default", "Custom", "Merge"], group="Universe",
     tooltip="Same semantics as NASDAQ Mode. Default uses DEF_GOLD only; Custom uses your text area only; Merge concatenates both (with automatic dedup at parse time).")

mode_bio = input.string("Default", "Bioscience — Mode",
     options=["Default", "Custom", "Merge"], group="Universe",
     tooltip="Same semantics as NASDAQ Mode. Default uses DEF_BIO only; Custom uses your text area only; Merge concatenates both (with automatic dedup at parse time).")

mode_nrg = input.string("Default", "Energy — Mode",
     options=["Default", "Custom", "Merge"], group="Universe",
     tooltip="Same semantics as NASDAQ Mode. Default uses DEF_NRG only; Custom uses your text area only; Merge concatenates both (with automatic dedup at parse time).")

// ── Custom text-area slots ────────────────────────────────────────────────
custom_nasdaq = input.text_area("", "NASDAQ — Custom Tickers", group="Universe",
     tooltip="Your custom NASDAQ list — active only when Mode = Custom or Merge.\n\nFormat: one ticker per line OR comma-separated on one line (the parser handles both). Use full TradingView codes: EXCHANGE:TICKER (e.g. NASDAQ:NVDA, NYSE:VRT).\n\nLeave empty if you only ever use Default Mode for this slot.")

custom_gold = input.text_area("", "Gold Miners — Custom Tickers", group="Universe",
     tooltip="Your custom Gold Miners list — active only when Mode = Custom or Merge.\n\nSame format rules as the NASDAQ slot.")

custom_bio = input.text_area("", "Bioscience — Custom Tickers", group="Universe",
     tooltip="Your custom Bioscience list — active only when Mode = Custom or Merge.\n\nSame format rules as the NASDAQ slot.")

custom_nrg = input.text_area("", "Energy — Custom Tickers", group="Universe",
     tooltip="Your custom Energy list — active only when Mode = Custom or Merge.\n\nSame format rules as the NASDAQ slot.")

// ── Mode resolution helper ─────────────────────────────────────────────────
f_resolve(string mode, string def_str, string custom_str) =>
    string out = mode == "Default" ? def_str :
                 mode == "Custom"  ? custom_str :
                                     def_str + "," + custom_str
    out

string active_nasdaq = f_resolve(mode_nasdaq, DEF_NASDAQ, custom_nasdaq)
string active_gold   = f_resolve(mode_gold,   DEF_GOLD,   custom_gold)
string active_bio    = f_resolve(mode_bio,    DEF_BIO,    custom_bio)
string active_nrg    = f_resolve(mode_nrg,    DEF_NRG,    custom_nrg)

string universe_in_raw = switch universe_select
    "NASDAQ"      => active_nasdaq
    "Bioscience"  => active_bio
    "Gold Miners" => active_gold
    "Energy"      => active_nrg
    => active_nasdaq

// ── Chart symbol auto-include ──────────────────────────────────────────────
include_chart_sym = input.bool(false, "Include Chart Symbol", group="Universe",
     tooltip="Auto-prepends the current chart symbol (syminfo.tickerid, e.g. 'NASDAQ:NVDA') to the screened universe.\n\nGuarantees the ticker you're looking at always appears in the screener regardless of which universe is active — useful for instantly checking how the chart symbol ranks against its peer group.\n\nDedup is automatic: if the chart symbol is already in the resolved universe, no extra request.security() call is made and the 40-ticker cap is not consumed twice.")

string universe_in = include_chart_sym ? syminfo.tickerid + "," + universe_in_raw : universe_in_raw

max_per_state = input.int(20, "Max Tickers Shown Per State", minval=1, maxval=35, group="Universe",
     tooltip="Maximum tickers shown in each ranked state list (Elite, Confirmed, Emerging).\n\nDefault 10 keeps the screener compact. Increase to see deeper rankings; decrease for a top-N focused view.\n\nDoes NOT affect the Bear list (always shown as compact comma-separated row).\n\nRanking within each state is by RankVal (Calmar-adjusted weighted filter separation) descending.")

// =============================================================================
// 3. CONSENSUS ENGINE WEIGHTS
// =============================================================================
w_fast  = input.float(0.20, "Weight: FAST (2p+2p)",     minval=0.0, maxval=1.0, step=0.05, group="Consensus Engine",
     tooltip="Weight assigned to the FAST filter (2p+2p Ehlers SuperSmoother) in the RankVal calculation.\n\nThe FAST filter is most reactive — it captures short-cycle moves and short pullbacks. Default 0.20 (20%).\n\nHigher weight → ranking favors stocks with strong short-term separations (good for active trading).\nLower weight → de-emphasizes short-term moves (good for position trading).\n\nNote: Weights F + Co + A do NOT have to sum to 1.0; the engine does not normalize. Over-weighting any one filter is your choice but biases the rank order.")
w_core  = input.float(0.50, "Weight: CORE (3p+2p)",     minval=0.0, maxval=1.0, step=0.05, group="Consensus Engine",
     tooltip="Weight assigned to the CORE filter (3p+2p Ehlers Hybrid) in the RankVal calculation.\n\nThe CORE filter is the balanced default — half-trend, half-stabilized. It's the strongest single signal in most regimes. Default 0.50 (50%).\n\nHigher weight → ranking heavily favors confirmed medium-term trends.\nLower weight → balances ranking toward fast or adaptive signals.\n\nDecreasing this weight while increasing FAST or ADAPTIVE shifts the engine toward shorter-term or cycle-based signals respectively.")
w_adapt = input.float(0.30, "Weight: ADAPTIVE (MAMA)",  minval=0.0, maxval=1.0, step=0.05, group="Consensus Engine",
     tooltip="Weight assigned to the ADAPTIVE filter (MAMA/FAMA, Ehlers cycle-adaptive) in the RankVal calculation.\n\nThe ADAPTIVE filter detects dominant cycle changes — it often catches reversals before slower filters confirm. Default 0.30 (30%).\n\nHigher weight → ranking favors cycle-change detection (good for choppy or transitional markets).\nLower weight → de-emphasizes adaptive signals in favor of pure trend persistence.\n\nMost interesting in EMERGING tier (where Adapt is the lone bullish filter — potential bottom signal) and CONFIRMED tier (where Adapt is the dissenter — potential top warning).")

show_emerging = input.bool(true, "Show Emerging state in detail", group="Consensus Engine",
     tooltip="Show the EMERGING tier (1 of 3 filters bullish) in the detailed ranked list.\n\nEmerging is the most epistemically interesting tier for finding early signals — particularly when the lone bullish filter is the Adaptive (MAMA/FAMA), which can detect cycle bottoms before slower filters confirm.\n\nTurn OFF to declutter the screener if you only want to see established trends (Elite + Confirmed).")
show_bear     = input.bool(true, "Show Bear list (compact)", group="Consensus Engine",
     tooltip="Show the BEAR list (0 of 3 filters bullish) as a compact comma-separated row at the bottom of the screener.\n\nBear stocks have no bullish filter consensus — pure downtrends. Useful as:\n  • A 'do not enter' watchlist\n  • Regime confirmation (high Bear count = breadth weakness)\n  • Reversal candidates (when Bear count starts dropping)\n\nTurn OFF if you only want bullish-leaning information.")
show_tags     = input.bool(true, "Show interpretation tags", group="Consensus Engine",
     tooltip="Toggle the INTERPRETATION ENGINE — adds two layers of automated reading to the screener.\n\nON:\n  • Each ranked row gets a state tag appended after a '→' arrow, in the form\n    Phase · Temperature ▲/▼ (e.g. Heated · Boiling ▲, Liquid · Cooling ▼,\n    Thawing · Warming ▲, Frozen ▼). Phase = how many filters agree;\n    Temperature = intensity and trend of the move; the arrow = direction.\n  • A TOP READ synthesis line appears at the top of the screener, describing\n    the most notable structural configuration across the universe.\n\nPriority of Top Read:\n  1. Liquid-phase + Adapt-bearish pressure (degrading, most notable)\n  2. Thawing-phase + Adapt-only-bullish (bottoming)\n  3. Fresh strengthening Heated names\n  4. Breadth fallback\n\nThese describe state; they are not trade instructions.\n\nOFF: Cleaner display, raw consensus only.")
highlight_add = input.bool(true, "Highlight strengthening Heated rows", group="Consensus Engine",
     tooltip="Add a subtle background highlight to Heated-phase rows that are strengthening (rank rising) and not yet mature — so they stand out from the rest of the phase at a glance.\n\nThe highlight marks Heated rows where rank_trend is positive and bars_in_state is in the mid-range (8–50). It describes which names are gaining separation; it is a visual aid, not a recommendation.\n\nWhen a bearish Adapt-cluster is active, the highlight colour shifts (green → amber → red as the cluster matures) to show the regime pressure those names sit under.\n\nOFF: All Heated rows use uniform background.")
float min_add_rankval = input.float(19.0, "Min RankVal for strengthening highlight", minval=0.0, maxval=200.0, step=1.0, group="Consensus Engine",
     tooltip="Minimum RankVal for the strengthening-row highlight to apply.\n\nDefault 19 is the floor below which Calmar-adjusted weighted separations sit in noise territory. Highlighting only names above this threshold marks the higher-separation subset at a glance and filters out marginal ones.\n\nSet to 0 to highlight every strengthening row regardless of separation.\nRaise to 50+ to highlight only the highest-separation names.\n\nThe state tag still appears on all rows — only the background highlight is gated by this threshold.")
float min_primary_rankval = input.float(19.0, "Min RankVal for Primary Read", minval=-100.0, maxval=200.0, step=1.0, group="Consensus Engine",
     tooltip="Minimum RankVal threshold for a candidate to qualify as the Primary Read.\n\nWithout this gate, the system can pick structurally-interesting but low-conviction signals — e.g. an Emerging stock with Adapt-only-bull but deeply negative overall RankVal that you wouldn't act on regardless.\n\nDefault 19 matches the ADD highlight threshold for consistency.\n\nSet to 0 (or negative) to allow ANY structurally-interesting signal regardless of conviction.")
float min_early_adapt_sep = input.float(15.0, "Min Adapt Sep for Early Reversal Read", minval=0.0, maxval=100.0, step=1.0, group="Consensus Engine",
     tooltip="Minimum adapt_sep (%) for the 'early reversal' Primary Read to fire.\n\nDefault 15.0% ensures only substantial MAMA-led cycle signals qualify. A name with adapt_sep=3% is technically Adapt-only-bull but the MAMA signal is weak.\n\nApplies in addition to Min RankVal — both gates must pass.")
int min_cluster_count = input.int(3, "Adapt-Cluster Threshold (Bearish & Bullish)", minval=2, maxval=10, group="Consensus Engine",
     tooltip="Minimum number of names required to trigger a cluster signal, applied symmetrically to both bearish and bullish cluster detection.\n\nBEARISH cluster: Confirmed-tier names with Adapt-bearish dissent. When MAMA/FAMA flips bearish on multiple Elite-leader names simultaneously while slower filters still see uptrends, that's structural pressure forming under apparent strength — leading indicator of regime turn DOWN.\n\nBULLISH cluster: Emerging-tier names with Adapt-only-bullish. When MAMA/FAMA flips bullish on multiple stocks simultaneously while slower filters still see downtrends, that's cycle bottoms forming under apparent weakness — leading indicator of regime turn UP.\n\nBoth catch regime shifts EARLIER than individual-name signals (which require 10+ bars persistence on single stocks). Clusters fire on simultaneity, not maturity.\n\nDefault 3 fires when 3+ names show the relevant pattern.\n\nLower (2) for tighter sensitivity in smaller universes.\nHigher (5+) for noise-tolerance in large universes.")

// =============================================================================
// 4. OTHER UI INPUTS (chart pipeline)
// =============================================================================
grp_vol              = "Adaptive Thresholds"
bool enable_adaptive = input.bool(true, "Enable Volatility-Adaptive Thresholds", group=grp_vol,
     tooltip="Use volatility-adaptive thresholds for the Price Deviation, Safety Margin, and Technical Rating classifications shown in the top panel.\n\nON (recommended):\n  Thresholds scale with the asset's actual volatility — appropriate for crypto, biotech, micro-caps, and any high-vol instruments. Lower-vol assets get tighter thresholds; high-vol gets looser.\n\nOFF: Uses fixed percentage thresholds (Extended >25%, Perfect >12%, etc.). Only appropriate if you only ever screen comparable-vol assets.")
bool auto_vol_lb     = input.bool(true, "Auto-Scale Lookback by Timeframe", group=grp_vol,
     tooltip="Automatically scales the volatility lookback window based on the chart's timeframe.\n\nON (recommended):\n  • Daily: 252 bars (1 trading year)\n  • Weekly: 52 bars (1 year)\n  • 4H: 63 bars\n  • 1H: 252 bars\n  • <1H: 500 bars\n  • Other: 252\n\nOFF: Uses the manual lookback input below.")
int manual_vol_lb    = input.int(252, "Manual Volatility Lookback", minval=10, maxval=500, group=grp_vol,
     tooltip="Manual volatility lookback window in bars. Only used when Auto-Scale Lookback (above) is OFF.\n\nLonger window = smoother volatility baseline, less reactive to recent spikes.\nShorter window = adapts faster but more whipsaw-prone on threshold classifications.")
float vol_percentile = input.float(0.75, "Volatility Percentile", minval=0.25, maxval=0.95, step=0.05, group=grp_vol,
     tooltip="Which percentile of recent rolling volatility to use as the 'baseline' against which adaptive thresholds scale.\n\n0.50 = median volatility (50th percentile)\n0.75 = default — represents the 'higher than normal' band, useful for typical equity assets\n0.95 = only the most extreme recent volatility sets the baseline\n\nHigher percentile → stricter thresholds (looser definitions of Extended/Perfect — needs more move to qualify).\nLower percentile → more sensitive thresholds.")

grp_mom         = "Momentum Analysis"
int momentum_lb = input.int(5, "Momentum Lookback (bars)", minval=1, maxval=50, group=grp_mom,
     tooltip="Number of bars used to compute the momentum reading shown in the top panel ('Strong / Steady / Weak / Opposing').\n\nDefault 5 captures very short-term acceleration.\nIncrease for smoother momentum readings (less reactive).\nDecrease for the most recent move only.\n\nThe indicator AUTO-ADJUSTS this upward to compensate for filter lag:\n  • Hybrid filter: ×1.15\n  • Smooth filter: ×1.45\n  • Fast/MAMA: unchanged\n\nThis ensures the momentum reading roughly tracks the same time period of price action regardless of which filter you use on the chart.")

grp_vis  = "Plot Styling"
c_raw    = input.color(#A0A0A0, "Raw Price Color", group=grp_vis,
     tooltip="Color of the lightly-smoothed raw asset price line shown beneath the main signal line. Provides visual reference for actual price vs the smoothed Ehlers output.")
t_fill   = input.int(70, "Zone Transparency", minval=0, maxval=100, step=5, group=grp_vis,
     tooltip="Transparency of the colored zone fill between the smoothed signal line and the support baseline.\n\n0 = opaque (strong visual but may hide candles)\n100 = invisible (effectively no fill)\n\nDefault 70 is a balance — clearly visible but doesn't dominate.")
t_base   = input.int(10, "Baseline Transparency", minval=0, maxval=100, step=5, group=grp_vis,
     tooltip="Transparency of the support baseline line itself.\n\n0 = solid line (default)\n100 = invisible\n\nLower = bolder baseline visualization. Useful if you want the baseline more prominent than the fill.")
p_smooth = input.int(5, "Price Line Smoothing", minval=1, group=grp_vis,
     tooltip="EMA period used to lightly smooth the raw asset price line for display.\n\nHigher = smoother raw line, less candle-by-candle noise visible.\nLower = closer to actual close price.\n\nDoes NOT affect any calculation. Display only.")

grp_ui        = "Interface Layout"
string t_size = input.string("Small", "Text Size", options=["Tiny","Small","Normal","Large"], group=grp_ui,
     tooltip="Text size for DATA rows in the top panel and screener rankings. Section headers and footers use fixed sizes for consistency.\n\nTiny: Maximum density, smallest text.\nSmall (default): Compact but readable.\nNormal: Larger, fewer rows visible at once.\nLarge: Maximum readability, takes more screen space.")
bool show_main_table = input.bool(true, "Show Ehlers Filter Table", group=grp_ui,
     tooltip="Show or hide the top metrics panel (Trend Status, Momentum, Safety Margin, etc.).\n\nTurn OFF to reclaim vertical screen space when you only want the screener.\nTurn ON to see the chart ticker's full Ehlers diagnostic alongside the universe screener.")
bool show_screener = input.bool(true, "Show Screener Panel", group=grp_ui,
     tooltip="Show or hide the Consensus Engine screener panel beneath the top metrics panel.\n\nTurn OFF to use this indicator purely as a single-ticker Ehlers Adaptive Trend Filter without multi-ticker screening. Saves significant vertical space.")
bool show_resolved = input.bool(true, "Show Resolved Read row", group=grp_ui,
     tooltip="One line that compares THIS CHART'S STOCK against its own daily structure, then against the universe tide (cluster pressure), and states the resolved relationship as one fact.\n\nThis is the only chart-specific line in the table. It is prefixed with the ticker so it cannot be mistaken for a universe read.")

grp_theme      = "Terminal Theme"
color C_BG     = input.color(#0D1117,               "Base (cool dark)",  group=grp_theme,
     tooltip="Background color for the table. Deep cool-dark base (GitHub-dark style) for high contrast on dark chart themes.")
color C_HEAD   = input.color(#161B22,               "Header surface",    group=grp_theme,
     tooltip="Background color for section header rows (titles, phase labels, regime line, etc.). A raised surface, slightly lighter than the body background.")
color C_BORDER = input.color(color.new(#30363D,50), "Border",            group=grp_theme,
     tooltip="Color of the table border. Semi-transparent cool gray to avoid overpowering the layout.")
color C_GOLD   = input.color(#FBBF24,               "Amber",             group=grp_theme,
     tooltip="Accent color used for titles, key metrics, the Top Read line, and filter config text. Amber, designed to draw attention.")
color C_TXT    = input.color(#E6EDF3,               "Warm White",        group=grp_theme,
     tooltip="Primary text color for labels and most readable content.")
color C_DIM    = input.color(#88919E,               "Cool Gray",         group=grp_theme,
     tooltip="Dimmed text color for secondary content (column headers, footnotes, 'none' placeholders).")
color C_ACTION = input.color(#FB923C,               "Orange Accent",     group=grp_theme,
     tooltip="Color for the Price Deviation and Regime line. A soft orange, distinct from the amber and cyan accents for visual separation.")
color C_SKY    = input.color(#22D3EE,               "Cyan",              group=grp_theme,
     tooltip="Color for the Liquid phase in the screener and for system-status footers. Distinct from emerald (Heated) and amber (Thawing).")
color C_UP     = input.color(#34D399,               "Emerald (Up)",      group=grp_theme,
     tooltip="Color for up states — line above baseline, Heated phase, positive momentum directions.")
color C_DOWN   = input.color(#FB7185,               "Rose (Down)",       group=grp_theme,
     tooltip="Color for down states — line below baseline, Frozen phase, below-baseline margin, security budget warnings.")
color C_FALL   = input.color(#FBBF24,               "Amber (Thawing)",   group=grp_theme,
     tooltip="Color for the Thawing phase and transitional states (Transition / Thin margin, etc.).")

// =============================================================================
// 4.5 TIMEFRAME ROLE DETECTION + SCALING
// =============================================================================
// The indicator commits to a multi-timeframe workflow:
//   • Daily charts: primary detection. Cluster signals + Top Read drive action.
//   • 4H charts: verification. Individual tags lead daily by 1-3 sessions.
//   • Other timeframes: scaled signals; cluster persistence requires more bars
//     to compensate for shorter real-time intervals. Faster than 4H typically
//     too noisy for reliable cluster detection.

// Detect current timeframe in minutes for scaling
int tf_minutes = timeframe.in_seconds() / 60

// Persistence scale factor — keeps "fresh/sustained/mature" stages roughly
// real-time equivalent across timeframes. Daily = 1× (current behavior).
// 4H = ~1.5×. 1H = ~6×. 15M = ~26×. 5M = ~78×.
float tf_scale_factor = tf_minutes >= 1440 ? 1.0 : tf_minutes >= 240  ? 1.5 : tf_minutes >= 60   ? 6.0 : tf_minutes >= 15   ? 26.0 : 78.0                              // Faster (effectively disabled)

// Scaled thresholds for cluster persistence stages
int tf_fresh_to_sustained = math.round(3.0 * tf_scale_factor)
int tf_sustained_to_mature = math.round(10.0 * tf_scale_factor)

// Timeframe role classification for contextual notes
string tf_role = tf_minutes >= 1440 ? "primary detection" :
                 tf_minutes >= 240  ? "verification" :
                 tf_minutes >= 60   ? "fast monitoring (scaled signals)" :
                                      "intraday (signals suppressed by scaling)"

// =============================================================================
// 5. PARSING + UTILITY HELPERS
// =============================================================================
f_clean(string s) =>
    string out = str.replace_all(s, " ", "")
    out := str.replace_all(out, "\t", "")
    out := str.replace_all(out, "\r", "")
    out

f_split_str(string s) =>
    array<string> out = array.new<string>()
    if str.length(s) > 0
        string norm = str.replace_all(s, "\n", ",")
        array<string> parts = str.split(norm, ",")
        for i = 0 to array.size(parts) - 1
            string v = f_clean(array.get(parts, i))
            if str.length(v) > 0 and array.indexof(out, v) == -1
                array.push(out, v)
    out

// =============================================================================
// 6. UDTs — Filter state per ticker
// =============================================================================
type SS3State
    float p1   = 0.0
    float p2   = 0.0
    float f1   = 0.0
    float f2   = 0.0
    float f3   = 0.0
    int   bars = 0

method update(SS3State this, float price, int freq) =>
    float filt = 0.0
    if this.bars < 3
        filt := price
    else if this.bars == 3
        filt := (price + this.p1 + this.p2) / 3.0
    else
        float r3    = 1.73205081
        float arg   = PI / freq
        float a1    = math.exp(-arg)
        float b1    = 2.0 * a1 * math.cos(r3 * arg)
        float c1v   = math.pow(a1, 2)
        float coef2 = b1 + c1v
        float coef3 = -(c1v + b1 * c1v)
        float coef4 = math.pow(c1v, 2)
        float coef1 = 1.0 - coef2 - coef3 - coef4
        filt := coef1 * price + coef2 * this.f1 + coef3 * this.f2 + coef4 * this.f3
    this.p2 := this.p1
    this.p1 := price
    this.f3 := this.f2
    this.f2 := this.f1
    this.f1 := filt
    this.bars := this.bars + 1
    filt

type SS2State
    float p1   = 0.0
    float f1   = 0.0
    float f2   = 0.0
    int   bars = 0

method update(SS2State this, float price, int freq) =>
    float filt = 0.0
    if this.bars < 2
        filt := price
    else
        float a1  = math.exp(-PI * math.sqrt(2) / freq)
        float c2  = 2.0 * a1 * math.cos(math.sqrt(2) * PI / freq)
        float c3  = -math.pow(a1, 2)
        float c1v = 1.0 - c2 - c3
        filt := c1v * (price + this.p1) / 2.0 + c2 * this.f1 + c3 * this.f2
    this.p1 := price
    this.f2 := this.f1
    this.f1 := filt
    this.bars := this.bars + 1
    filt

type MAMAState
    array<float> msH
    array<float> mdetH
    array<float> mI1H
    array<float> mQ1H
    float c1        = 0.0
    float c2        = 0.0
    float c3        = 0.0
    float mI2_prev  = 0.0
    float mQ2_prev  = 0.0
    float mRe_prev  = 0.0
    float mIm_prev  = 0.0
    float mPer_prev = 15.0
    float mPh_prev  = 0.0
    float mama_out  = 0.0
    float fama_out  = 0.0
    int   bars      = 0

init_mama_state() =>
    MAMAState m = MAMAState.new()
    m.msH   := array.new<float>()
    m.mdetH := array.new<float>()
    m.mI1H  := array.new<float>()
    m.mQ1H  := array.new<float>()
    m

f_hist_get(array<float> arr, int idx) =>
    array.size(arr) > idx ? array.get(arr, idx) : 0.0

method update(MAMAState this, float price, float fastLim, float slowLim) =>
    float mama = price
    float fama = price

    if this.bars >= 6
        float ms = (4.0*price + 3.0*this.c1 + 2.0*this.c2 + this.c3) / 10.0
        array.unshift(this.msH, ms)
        if array.size(this.msH) > 7
            array.pop(this.msH)

        float dc = 0.075 * this.mPer_prev + 0.54

        float ms_0 = f_hist_get(this.msH, 0)
        float ms_2 = f_hist_get(this.msH, 2)
        float ms_4 = f_hist_get(this.msH, 4)
        float ms_6 = f_hist_get(this.msH, 6)
        float mdet = (0.0962*ms_0 + 0.5769*ms_2 - 0.5769*ms_4 - 0.0962*ms_6) * dc
        array.unshift(this.mdetH, mdet)
        if array.size(this.mdetH) > 7
            array.pop(this.mdetH)

        float mdet_0 = f_hist_get(this.mdetH, 0)
        float mdet_2 = f_hist_get(this.mdetH, 2)
        float mdet_4 = f_hist_get(this.mdetH, 4)
        float mdet_6 = f_hist_get(this.mdetH, 6)
        float mQ1 = (0.0962*mdet_0 + 0.5769*mdet_2 - 0.5769*mdet_4 - 0.0962*mdet_6) * dc
        float mI1 = f_hist_get(this.mdetH, 3)

        array.unshift(this.mQ1H, mQ1)
        if array.size(this.mQ1H) > 7
            array.pop(this.mQ1H)
        array.unshift(this.mI1H, mI1)
        if array.size(this.mI1H) > 7
            array.pop(this.mI1H)

        float mI1_0 = f_hist_get(this.mI1H, 0)
        float mI1_2 = f_hist_get(this.mI1H, 2)
        float mI1_4 = f_hist_get(this.mI1H, 4)
        float mI1_6 = f_hist_get(this.mI1H, 6)
        float mjI = (0.0962*mI1_0 + 0.5769*mI1_2 - 0.5769*mI1_4 - 0.0962*mI1_6) * dc

        float mQ1_0 = f_hist_get(this.mQ1H, 0)
        float mQ1_2 = f_hist_get(this.mQ1H, 2)
        float mQ1_4 = f_hist_get(this.mQ1H, 4)
        float mQ1_6 = f_hist_get(this.mQ1H, 6)
        float mjQ = (0.0962*mQ1_0 + 0.5769*mQ1_2 - 0.5769*mQ1_4 - 0.0962*mQ1_6) * dc

        float i2r = mI1 - mjQ
        float q2r = mQ1 + mjI
        float mI2 = 0.2*i2r + 0.8*this.mI2_prev
        float mQ2 = 0.2*q2r + 0.8*this.mQ2_prev

        float rer = mI2 * this.mI2_prev + mQ2 * this.mQ2_prev
        float imr = mI2 * this.mQ2_prev - mQ2 * this.mI2_prev
        float mRe = 0.2*rer + 0.8*this.mRe_prev
        float mIm = 0.2*imr + 0.8*this.mIm_prev

        float prev = this.mPer_prev
        float p0 = mIm != 0.0 and mRe != 0.0 ? 2.0 * PI / math.atan(mIm/mRe) : prev
        float p1 = p0 > 1.5*prev  ? 1.5*prev  : p0
        float p2 = p1 < 0.67*prev ? 0.67*prev : p1
        float p3 = math.max(6.0, math.min(50.0, p2))
        float mPer = 0.2*p3 + 0.8*prev

        float ph_raw = mI1 != 0.0 ? math.atan(mQ1/mI1) * 180.0/PI : this.mPh_prev
        float dph = math.max(1.0, this.mPh_prev - ph_raw)
        float alph = math.max(slowLim, fastLim/dph)

        mama := alph*price + (1.0 - alph) * this.mama_out
        fama := 0.5*alph*mama + (1.0 - 0.5*alph) * this.fama_out

        this.mI2_prev  := mI2
        this.mQ2_prev  := mQ2
        this.mRe_prev  := mRe
        this.mIm_prev  := mIm
        this.mPer_prev := mPer
        this.mPh_prev  := ph_raw

    this.mama_out := mama
    this.fama_out := fama

    this.c3 := this.c2
    this.c2 := this.c1
    this.c1 := price
    this.bars := this.bars + 1
    mama

type TickerState
    SS2State fast_sig
    SS2State fast_base
    SS3State core_sig
    SS2State core_base
    MAMAState adapt
    array<float> pHist
    array<float> drHist
    array<float> rankHist

    float c            = 0.0
    float fast_lp      = 0.0
    float fast_sf      = 0.0
    float fast_sep     = 0.0
    bool  fast_bull    = false
    float core_lp      = 0.0
    float core_sf      = 0.0
    float core_sep     = 0.0
    bool  core_bull    = false
    float adapt_lp     = 0.0
    float adapt_sf     = 0.0
    float adapt_sep    = 0.0
    bool  adapt_bull   = false
    float ret63        = 0.0
    float vol63        = 0.0
    float cal          = 0.0
    int   consensus    = 0
    float weighted_sep = 0.0
    float rank_value   = 0.0

    int   prev_consensus = -1
    int   bars_in_state  = 0
    float rank_5ago      = 0.0
    float rank_trend     = 0.0
    float stop_dist      = 0.0

init_ticker_state() =>
    TickerState ts = TickerState.new()
    ts.fast_sig  := SS2State.new()
    ts.fast_base := SS2State.new()
    ts.core_sig  := SS3State.new()
    ts.core_base := SS2State.new()
    ts.adapt     := init_mama_state()
    ts.pHist     := array.new<float>()
    ts.drHist    := array.new<float>()
    ts.rankHist  := array.new<float>()
    ts

method tick(TickerState this, float price, int detox, int anchor, float bmult,
            float fastLim, float slowLim, float wF, float wC, float wA) =>
    this.c := price

    this.fast_lp  := this.fast_sig.update(price, detox)
    this.fast_sf  := this.fast_base.update(this.fast_lp, anchor) * bmult
    this.fast_sep := this.fast_sf > 0 ? (this.fast_lp - this.fast_sf) / this.fast_sf * 100.0 : 0.0
    this.fast_bull := this.fast_lp > this.fast_sf

    this.core_lp  := this.core_sig.update(price, detox)
    this.core_sf  := this.core_base.update(this.core_lp, anchor) * bmult
    this.core_sep := this.core_sf > 0 ? (this.core_lp - this.core_sf) / this.core_sf * 100.0 : 0.0
    this.core_bull := this.core_lp > this.core_sf

    this.adapt.update(price, fastLim, slowLim)
    this.adapt_lp  := this.adapt.mama_out
    this.adapt_sf  := this.adapt.fama_out
    this.adapt_sep := this.adapt_sf > 0 ? (this.adapt_lp - this.adapt_sf) / this.adapt_sf * 100.0 : 0.0
    this.adapt_bull := this.adapt_lp > this.adapt_sf

    array.unshift(this.pHist, price)
    if array.size(this.pHist) > 65
        array.pop(this.pHist)
    float c63 = array.size(this.pHist) > 63 ? array.get(this.pHist, 63) : 0.0
    this.ret63 := c63 > 0 ? (price - c63) / c63 * 100.0 : 0.0

    float c1v = array.size(this.pHist) > 1 ? array.get(this.pHist, 1) : 0.0
    float dr  = c1v > 0 ? (price - c1v) / c1v * 100.0 : 0.0
    array.unshift(this.drHist, dr)
    if array.size(this.drHist) > 63
        array.pop(this.drHist)
    this.vol63 := array.size(this.drHist) >= 10 ? array.stdev(this.drHist) : 0.0
    this.cal   := this.vol63 > 0 ? this.ret63 / this.vol63 : 0.0

    int cc = (this.fast_bull ? 1 : 0) + (this.core_bull ? 1 : 0) + (this.adapt_bull ? 1 : 0)
    this.consensus := cc

    this.weighted_sep := wF * this.fast_sep + wC * this.core_sep + wA * this.adapt_sep
    float cal_factor = math.max(0.1, math.min(1.0, (this.cal + 2.0) / 5.0))
    this.rank_value := this.weighted_sep * cal_factor

    if this.prev_consensus == this.consensus
        this.bars_in_state := this.bars_in_state + 1
    else
        this.bars_in_state := 1
    this.prev_consensus := this.consensus

    array.unshift(this.rankHist, this.rank_value)
    if array.size(this.rankHist) > 7
        array.pop(this.rankHist)
    this.rank_5ago  := array.size(this.rankHist) > 5 ? array.get(this.rankHist, 5) : this.rank_value
    this.rank_trend := this.rank_value - this.rank_5ago

    this.stop_dist := price > 0 ? (price - this.core_sf) / price * 100.0 : 0.0

// =============================================================================
// 7. CHART FILTER FUNCTIONS
// =============================================================================
f_ss2_logic(float price, int freq) =>
    var float filt = 0.0
    if bar_index < 2
        filt := price
    else
        float a1 = math.exp(-PI * math.sqrt(2) / freq)
        float c2 = 2 * a1 * math.cos(math.sqrt(2) * PI / freq)
        float c3 = -math.pow(a1, 2)
        float c1 = 1 - c2 - c3
        filt := c1 * (price + nz(price[1])) / 2 + c2 * nz(filt[1]) + c3 * nz(filt[2])
    filt

f_ss3_logic(float price, int freq) =>
    var float filt = 0.0
    if bar_index < 3
        filt := price
    else if bar_index == 3
        filt := (price + price[1] + price[2]) / 3
    else
        float r3    = 1.73205081
        float arg   = PI / freq
        float a1    = math.exp(-arg)
        float b1    = 2 * a1 * math.cos(r3 * arg)
        float c1    = math.pow(a1, 2)
        float coef2 = b1 + c1
        float coef3 = -(c1 + b1 * c1)
        float coef4 = math.pow(c1, 2)
        float coef1 = 1 - coef2 - coef3 - coef4
        filt := coef1 * price + coef2 * nz(filt[1]) + coef3 * nz(filt[2]) + coef4 * nz(filt[3])
    filt

// =============================================================================
// 8. MAMA/FAMA (CHART ONLY)
// =============================================================================
var float _ms   = 0.0
var float _mdet = 0.0
var float _mI1  = 0.0
var float _mQ1  = 0.0
var float _mjI  = 0.0
var float _mjQ  = 0.0
var float _mI2  = 0.0
var float _mQ2  = 0.0
var float _mRe  = 0.0
var float _mIm  = 0.0
var float _mPer = 15.0
var float _mPh  = 0.0
var float _mama = close
var float _fama = close

if bar_index >= 6
    _ms := (4.0*close + 3.0*close[1] + 2.0*close[2] + close[3]) / 10.0
    float _dc = 0.075 * nz(_mPer[1], 15.0) + 0.54
    _mdet := (0.0962*_ms + 0.5769*nz(_ms[2]) - 0.5769*nz(_ms[4]) - 0.0962*nz(_ms[6])) * _dc
    _mQ1 := (0.0962*_mdet + 0.5769*nz(_mdet[2]) - 0.5769*nz(_mdet[4]) - 0.0962*nz(_mdet[6])) * _dc
    _mI1 := nz(_mdet[3])
    _mjI := (0.0962*_mI1 + 0.5769*nz(_mI1[2]) - 0.5769*nz(_mI1[4]) - 0.0962*nz(_mI1[6])) * _dc
    _mjQ := (0.0962*_mQ1 + 0.5769*nz(_mQ1[2]) - 0.5769*nz(_mQ1[4]) - 0.0962*nz(_mQ1[6])) * _dc
    float _i2r = _mI1 - _mjQ
    float _q2r = _mQ1 + _mjI
    _mI2 := 0.2*_i2r + 0.8*nz(_mI2[1])
    _mQ2 := 0.2*_q2r + 0.8*nz(_mQ2[1])
    float _rer = _mI2*nz(_mI2[1]) + _mQ2*nz(_mQ2[1])
    float _imr = _mI2*nz(_mQ2[1]) - _mQ2*nz(_mI2[1])
    _mRe := 0.2*_rer + 0.8*nz(_mRe[1])
    _mIm := 0.2*_imr + 0.8*nz(_mIm[1])
    float _prev = nz(_mPer[1], 15.0)
    float _p0   = _mIm != 0.0 and _mRe != 0.0 ? 2.0*PI / math.atan(_mIm/_mRe) : _prev
    float _p1   = _p0 > 1.5*_prev  ? 1.5*_prev  : _p0
    float _p2   = _p1 < 0.67*_prev ? 0.67*_prev : _p1
    float _p3   = math.max(6.0, math.min(50.0, _p2))
    _mPer := 0.2*_p3 + 0.8*_prev
    float _ph_raw = _mI1 != 0.0 ? math.atan(_mQ1/_mI1) * 180.0/PI : nz(_mPh[1])
    float _dph    = math.max(1.0, nz(_mPh[1]) - _ph_raw)
    float _alph   = math.max(mama_SlowLimit, mama_FastLimit/_dph)
    _mPh  := _ph_raw
    _mama := _alph*close + (1.0 - _alph)*nz(_mama[1], close)
    _fama := 0.5*_alph*_mama + (1.0 - 0.5*_alph)*nz(_fama[1], close)
else
    _mama := close
    _fama := close

// =============================================================================
// 9. SYSTEM LOOKBACK + ADAPTIVE VOLATILITY (chart)
// =============================================================================

int  vol_lookback = manual_vol_lb

if auto_vol_lb
    if timeframe.ismonthly
        vol_lookback := 12
    else if timeframe.isweekly
        vol_lookback := 52
    else if timeframe.isdaily
        vol_lookback := 252
    else if timeframe.isintraday
        if timeframe.multiplier == 240
            vol_lookback := 63
        else if timeframe.multiplier == 60
            vol_lookback := 252
        else if timeframe.multiplier < 60
            vol_lookback := 500
        else
            vol_lookback := 252
    else
        vol_lookback := 252

vol_lookback := math.min(vol_lookback, 500)

float daily_returns          = ta.change(close) / close * 100
float rolling_vol            = ta.stdev(daily_returns, math.min(vol_lookback, bar_index + 1))
int   effective_vol_lookback = math.min(vol_lookback, bar_index + 1)
bool  vol_ready              = effective_vol_lookback >= 50
float vol_baseline           = vol_ready ? ta.percentile_linear_interpolation(rolling_vol, effective_vol_lookback, vol_percentile) : rolling_vol

float adaptive_extended      = enable_adaptive ? vol_baseline * 1.50 : 25.0
float adaptive_expanding     = enable_adaptive ? vol_baseline * 0.75 :  5.0
float adaptive_lagging       = enable_adaptive ? vol_baseline * -0.5 : -5.0
float adaptive_perfect       = enable_adaptive ? vol_baseline * 1.20 : 12.0
float adaptive_transition    = enable_adaptive ? vol_baseline * 0.60 :  5.0

// =============================================================================
// 10. MAIN CHART PIPELINE
// =============================================================================
l_path = switch filter_config
    "2p+2p (Fast)"         => f_ss2_logic(close, m_detox)
    "3p+2p (Hybrid)"       => f_ss3_logic(close, m_detox)
    "3p+3p (Smooth)"       => f_ss3_logic(close, m_detox)
    "MAMA/FAMA (Adaptive)" => _mama
    => f_ss3_logic(close, m_detox)

s_floor = switch filter_config
    "2p+2p (Fast)"         => f_ss2_logic(l_path, m_anchor) * baseline_mult
    "3p+2p (Hybrid)"       => f_ss2_logic(l_path, m_anchor) * baseline_mult
    "3p+3p (Smooth)"       => f_ss3_logic(l_path, m_anchor) * baseline_mult
    "MAMA/FAMA (Adaptive)" => _fama
    => f_ss2_logic(l_path, m_anchor) * baseline_mult

int effective_mom_lb = switch filter_config
    "2p+2p (Fast)"         => math.max(momentum_lb, 3)
    "3p+2p (Hybrid)"       => math.max(math.ceil(momentum_lb * 1.15), 4)
    "3p+3p (Smooth)"       => math.max(math.ceil(momentum_lb * 1.45), 6)
    "MAMA/FAMA (Adaptive)" => math.max(momentum_lb, 3)
    => momentum_lb

bool  mom_ready    = bar_index >= effective_mom_lb and nz(l_path[effective_mom_lb]) != 0
float w_force_val  = mom_ready ? (l_path - l_path[effective_mom_lb]) / l_path[effective_mom_lb] * 100 : na
asset_mission      = l_path > s_floor ? "Above" : "Below"

string w_force_label = na(w_force_val) ? "Warming Up" :
     w_force_val > 1.0 ? "Strong" : w_force_val > 0.2 ? "Steady" :
     w_force_val > 0   ? "Weak"   : "Opposing"

c_slope = s_floor[1] != 0 ? (s_floor - s_floor[1]) / s_floor[1] * 100 : 0

c_diff = math.abs(l_path - s_floor)
p_diff = math.abs(l_path[3] - s_floor[3])
float trend_pct_change = p_diff != 0 ? ((c_diff - p_diff) / p_diff) * 100 : 0
w_trend1 = trend_pct_change > 2.0 ? "Increasing" : trend_pct_change < -2.0 ? "Decreasing" : "Stable"

var int   e_bar   = 0
var float e_price = 0.0
if bar_index == 0
    e_bar   := 0
    e_price := s_floor
else if ta.crossover(l_path, s_floor)
    e_bar   := bar_index
    e_price := s_floor

a_potential = ta.sma(c_slope, 30) * m_anchor
i_today     = e_price != 0 ? (e_price + (e_price * (a_potential / 100) / m_anchor * (bar_index - e_bar))) : l_path
d_var       = i_today != 0 ? ((l_path - i_today) / i_today) * 100 : 0

d_status      = d_var > adaptive_extended  ? "Extended"  : d_var > adaptive_expanding ? "Expanding" : d_var > adaptive_lagging   ? "On Course" : "Lagging"
string d_sign = d_var > 0 ? "+" : ""
h_clear       = (l_path - s_floor) / s_floor * 100
a_safety      = asset_mission == "Below" ? "Below baseline" : h_clear > adaptive_perfect ? "Wide" : h_clear > adaptive_transition ? "Transition" : "Thin"

// =============================================================================
// 11. PLOTS
// =============================================================================
p_draw = ta.ema(close, p_smooth)
plot(p_draw, "Actual Asset Price", color=c_raw, linewidth=1, style=plot.style_linebr)

color C_PATH = l_path > l_path[1] ? C_UP : C_DOWN
p_path  = plot(l_path,  "Smoothed Signal Path", color=C_PATH, linewidth=3)
p_floor = plot(s_floor, "Support Baseline", color=color.new(C_DOWN, t_base), style=plot.style_line)
fill(p_path, p_floor,
     color = l_path > s_floor ? color.new(C_UP, t_fill) : color.new(C_DOWN, t_fill),
     title = "Price Zone Fill")

// =============================================================================
// 12. PARSE UNIVERSE
// =============================================================================
array<string> tickers = f_split_str(universe_in)
int n = array.size(tickers)
bool sec_ok = n <= 40

// =============================================================================
// 13. PER-TICKER STATE (init on bar 0)
// =============================================================================
var array<TickerState> states = array.new<TickerState>()

if bar_index == 0
    if n > 0
        for i = 0 to n - 1
            array.push(states, init_ticker_state())

// =============================================================================
// 14. FETCH PRICES + RUN PER-TICKER PIPELINE
// =============================================================================
if n > 0
    for i = 0 to n - 1
        string sym = array.get(tickers, i)
        float px   = nz(request.security(sym, timeframe.period, close), 0.0)
        TickerState ts = array.get(states, i)
        ts.tick(px, m_detox, m_anchor, baseline_mult,
                mama_FastLimit, mama_SlowLimit, w_fast, w_core, w_adapt)

// =============================================================================
// 15. STATE-GROUPED RANKING
// =============================================================================
get_state_indices(int target_state) =>
    array<int>   idxs = array.new<int>()
    array<float> rvs  = array.new<float>()
    if n > 0
        for i = 0 to n - 1
            TickerState ts = array.get(states, i)
            if ts.consensus == target_state
                array.push(idxs, i)
                array.push(rvs,  ts.rank_value)
    int sz = array.size(idxs)
    if sz > 1
        for i = 0 to sz - 2
            int   max_j = i
            float max_v = array.get(rvs, i)
            for j = i + 1 to sz - 1
                if array.get(rvs, j) > max_v
                    max_v := array.get(rvs, j)
                    max_j := j
            if max_j != i
                int   ti = array.get(idxs, i)
                float tv = array.get(rvs, i)
                array.set(idxs, i,     array.get(idxs, max_j))
                array.set(rvs,  i,     array.get(rvs,  max_j))
                array.set(idxs, max_j, ti)
                array.set(rvs,  max_j, tv)
    idxs

array<int> elite_idxs    = get_state_indices(3)
array<int> confirmed_idxs = get_state_indices(2)
array<int> emerging_idxs = get_state_indices(1)
array<int> bear_idxs     = get_state_indices(0)

int n_elite     = array.size(elite_idxs)
int n_confirmed = array.size(confirmed_idxs)
int n_emerging  = array.size(emerging_idxs)
int n_bear      = array.size(bear_idxs)

// Adapt-cluster persistence tracking — bearish and bullish, both run every bar to maintain state across history

// Bearish cluster: Confirmed-tier names with Adapt-bearish dissent (cycle weakness under apparent strength)
int curr_cluster_count = 0
if n > 0
    for i = 0 to n - 1
        TickerState ts = array.get(states, i)
        if ts.consensus == 2 and not ts.adapt_bull
            curr_cluster_count := curr_cluster_count + 1

var int cluster_bars_active = 0
if curr_cluster_count >= min_cluster_count
    cluster_bars_active := cluster_bars_active + 1
else
    cluster_bars_active := 0

// Bullish cluster: Emerging-tier names with Adapt-only-bullish (cycle bottoms forming under apparent weakness)
int curr_bull_cluster_count = 0
if n > 0
    for i = 0 to n - 1
        TickerState ts = array.get(states, i)
        if ts.consensus == 1 and ts.adapt_bull and not ts.fast_bull and not ts.core_bull
            curr_bull_cluster_count := curr_bull_cluster_count + 1

var int bull_cluster_bars_active = 0
if curr_bull_cluster_count >= min_cluster_count
    bull_cluster_bars_active := bull_cluster_bars_active + 1
else
    bull_cluster_bars_active := 0

// Cluster stage classification using timeframe-scaled thresholds
int curr_cluster_stage = curr_cluster_count >= min_cluster_count ?
     (cluster_bars_active >= tf_sustained_to_mature ? 3 :
      cluster_bars_active >= tf_fresh_to_sustained ? 2 : 1) : 0

int curr_bull_cluster_stage = curr_bull_cluster_count >= min_cluster_count ?
     (bull_cluster_bars_active >= tf_sustained_to_mature ? 3 :
      bull_cluster_bars_active >= tf_fresh_to_sustained ? 2 : 1) : 0

// State machine: track previous stages for transition detection
var int prev_cluster_stage = 0
var int prev_bull_cluster_stage = 0

bool cluster_advancing = curr_cluster_stage > prev_cluster_stage and tf_minutes >= 1440
bool cluster_retreating = curr_cluster_stage < prev_cluster_stage and tf_minutes >= 1440
bool bull_cluster_advancing = curr_bull_cluster_stage > prev_bull_cluster_stage and tf_minutes >= 1440
bool bull_cluster_retreating = curr_bull_cluster_stage < prev_bull_cluster_stage and tf_minutes >= 1440

// Alert conditions for state machine transitions (fire only on daily charts)
alertcondition(cluster_advancing, title="Bearish cluster (turn-down) advance",
    message="EATF+CE: Bearish cluster (turn-down) advanced on daily chart. Fast frame leads; daily structure has not confirmed.")
alertcondition(cluster_retreating, title="Bearish cluster (turn-down) retreat",
    message="EATF+CE: Bearish cluster (turn-down) retreated on daily chart. Pressure easing; daily structure has not confirmed.")
alertcondition(bull_cluster_advancing, title="Bullish cluster (turn-up) advance",
    message="EATF+CE: Bullish cluster (turn-up) advanced on daily chart. Fast frame leads; daily structure has not confirmed.")
alertcondition(bull_cluster_retreating, title="Bullish cluster (turn-up) retreat",
    message="EATF+CE: Bullish cluster retreated — turn-up setup weakening on daily chart. Verify on 4H.")

// Recency window — show notification banner if transition occurred in last 2 bars
var int bars_since_transition = 999
if cluster_advancing or cluster_retreating or bull_cluster_advancing or bull_cluster_retreating
    bars_since_transition := 0
else
    bars_since_transition := bars_since_transition + 1

// Update previous stages for next bar (only on daily, where state machine is active)
if tf_minutes >= 1440
    prev_cluster_stage := curr_cluster_stage
    prev_bull_cluster_stage := curr_bull_cluster_stage

// Capture transition descriptors for notification (only set when transition occurred)
var string last_transition_text = ""
if cluster_advancing
    last_transition_text := "⚠ Bearish cluster (turn-down) advanced — stage " + str.tostring(curr_cluster_stage) + " · fast frame leads; daily structure has not confirmed"
else if cluster_retreating
    last_transition_text := "ℹ Bearish cluster (turn-down) retreated — stage " + str.tostring(curr_cluster_stage) + " · pressure easing; daily structure has not confirmed"
else if bull_cluster_advancing
    last_transition_text := "✦ Bullish cluster (turn-up) advanced — stage " + str.tostring(curr_bull_cluster_stage) + " · fast frame leads; daily structure has not confirmed"
else if bull_cluster_retreating
    last_transition_text := "ℹ Bullish cluster (turn-up) retreated — stage " + str.tostring(curr_bull_cluster_stage) + " · setup weakening; daily structure has not confirmed"

// =============================================================================
// 15.5 RESOLVED READ — chart stock vs its own daily, vs the universe tide
// =============================================================================
// Three inputs, one sentence out:
//   A) this chart's read of the stock  (asset_mission on chart timeframe)
//   B) the stock's own daily structure (fetched once — the fixed anchor)
//   C) the universe tide               (bear/bull cluster, sustained or better)
// On a daily chart A == B, so the verdict collapses to stock-vs-tide.
// On 4H, A vs B carries the turning/pullback distinction as before.

[rr_d_mission, rr_d_trend] = request.security(syminfo.tickerid, "1D",
     [asset_mission, w_trend1], lookahead=barmerge.lookahead_off)

bool rr_chart_up   = asset_mission == "Above"
bool rr_daily_up   = rr_d_mission == "Above"
bool rr_daily_fade = rr_d_trend == "Decreasing"
bool rr_bear_tide  = curr_cluster_count >= min_cluster_count and cluster_bars_active >= tf_fresh_to_sustained
bool rr_bull_tide  = curr_bull_cluster_count >= min_cluster_count and bull_cluster_bars_active >= tf_fresh_to_sustained

string rr_sym = "●"
color  rr_col = C_DIM
string rr_txt = "no clear read."
string rr_fade = rr_daily_fade ? " and fading" : ""

if rr_chart_up and rr_daily_up
    if rr_bear_tide
        rr_sym := "▲⚠"
        rr_col := C_FALL
        rr_txt := "UP · UNIVERSE TURNING DOWN — this stock's daily is aligned up. Broad downward pressure is building across the universe.\n The strength is this stock's own, not broad."
    else if rr_bull_tide
        rr_sym := "▲✦"
        rr_col := C_UP
        rr_txt := "UP · UNIVERSE ALSO TURNING UP — aligned up, and broad bottoming is forming behind it."
    else
        rr_sym := "▲"
        rr_col := C_UP
        rr_txt := "CONFIRMED UP — fast frame and daily structure agree: up."
else if rr_chart_up and not rr_daily_up
    if rr_bear_tide
        rr_sym := "◐⚠"
        rr_col := C_FALL
        rr_txt := "TURNING, NOT CONFIRMED · UNIVERSE TURNING DOWN — fast frame up, but the daily is still below baseline" + rr_fade + ",\n and the universe points the other way."
    else if rr_bull_tide
        rr_sym := "◐✦"
        rr_col := C_FALL
        rr_txt := "TURNING, NOT CONFIRMED · UNIVERSE ALSO TURNING UP — fast frame up, daily still below baseline" + rr_fade + ".\n Broad bottoming is forming with it. The daily has not turned."
    else
        rr_sym := "◐"
        rr_col := C_FALL
        rr_txt := "TURNING, NOT CONFIRMED — fast frame up, but the daily is still below baseline" + rr_fade + "."
else if not rr_chart_up and rr_daily_up
    if rr_bear_tide
        rr_sym := "◑⚠"
        rr_col := C_FALL
        rr_txt := "PULLBACK · UNIVERSE TURNING DOWN — daily still above baseline, but this dip and the broad downward pressure point the same way."
    else
        rr_sym := "◑"
        rr_col := C_FALL
        rr_txt := "PULLBACK — fast frame dipping; daily still above baseline. A dip within the trend, not the end of it."
else
    if rr_bull_tide
        rr_sym := "▼✦"
        rr_col := C_DOWN
        rr_txt := "DOWN · UNIVERSE BOTTOMING — this stock is aligned down while broad bottoming forms in the universe.\n The weakness is this stock's own read; the group is turning under it."
    else if rr_bear_tide
        rr_sym := "▼"
        rr_col := C_DOWN
        rr_txt := "CONFIRMED DOWN · WITH THE UNIVERSE — aligned down" + rr_fade + ", and the universe is turning down too."
    else
        rr_sym := "▼"
        rr_col := C_DOWN
        rr_txt := "CONFIRMED DOWN — fast frame and daily agree: down" + rr_fade + "."

// =============================================================================
// 16. INTERPRETATION ENGINE  (descriptive recast — states, not commands)
// =============================================================================
// Row highlights, regime classification, and the Primary Read synthesis.
// Each describes structural state (filter agreement, duration, separation
// trend, cluster context); none instructs the reader to act. The phase name
// (Heated/Liquid/Thawing/Frozen) carries the consensus gradient; per-row
// state tags are built in Section 17 (f_state_tag).

is_add_strengthening(TickerState ts) =>
    ts.consensus == 3 and ts.bars_in_state > 8 and ts.bars_in_state < 50 and ts.rank_trend > 0.5

// Cluster-aware highlight color for Elite-tier rows
// Returns the appropriate background color based on structural state and cluster context
elite_row_highlight(TickerState ts, color base_green, color amber, color red) =>
    color out = na
    if highlight_add and is_add_strengthening(ts) and ts.rank_value >= min_add_rankval
        if cluster_bars_active >= tf_sustained_to_mature
            out := color.new(red, 80)
        else if cluster_bars_active >= tf_fresh_to_sustained
            out := color.new(amber, 82)
        else if curr_cluster_count >= min_cluster_count
            out := color.new(amber, 85)
        else
            out := color.new(base_green, 85)
    out

emerging_row_highlight(TickerState ts, color entry_cyan) =>
    color out = na
    if ts.consensus == 1 and ts.adapt_bull and not ts.fast_bull and not ts.core_bull
        if bull_cluster_bars_active >= tf_sustained_to_mature and ts.rank_trend > 0.5
            out := color.new(entry_cyan, 80)
        else if bull_cluster_bars_active >= tf_fresh_to_sustained and ts.rank_trend > 0.5 and ts.bars_in_state >= 20
            out := color.new(entry_cyan, 85)
    out

classify_regime(int ne, int nc, int nem, int nb, int total) =>
    if total == 0
        "(no data)"
    else
        float pct_elite = float(ne) / total * 100.0
        float pct_bull  = float(ne + nc) / total * 100.0
        float pct_bear  = float(nb) / total * 100.0
        if pct_elite > 60.0
            "Broad Uptrend — Elite signal less selective"
        else if pct_bull > 60.0
            "Distributed Uptrend — healthy breadth"
        else if pct_bear > 40.0
            "Risk-Off — breadth deteriorating"
        else
            "Transitional — mixed regime"

primary_read() =>
    // Adapt-bearish pressure in Liquid phase — count only, not specific names
    int warn_count = 0
    if n > 0
        for i = 0 to n - 1
            TickerState ts = array.get(states, i)
            if ts.consensus == 2 and not ts.adapt_bull and ts.bars_in_state >= 10 and ts.rank_value >= min_primary_rankval
                warn_count := warn_count + 1

    // Strengthening Heated names — count + RankVal range
    int   add_count    = 0
    float add_max_rank = -1.0e9
    float add_min_rank = 1.0e9
    if n > 0
        for i = 0 to n - 1
            TickerState ts = array.get(states, i)
            if is_add_strengthening(ts) and ts.rank_value >= min_primary_rankval
                add_count := add_count + 1
                if ts.rank_value > add_max_rank
                    add_max_rank := ts.rank_value
                if ts.rank_value < add_min_rank
                    add_min_rank := ts.rank_value

    // Early-reversal pattern in Thawing phase
    int early_count = 0
    if n > 0
        for i = 0 to n - 1
            TickerState ts = array.get(states, i)
            if ts.consensus == 1 and ts.adapt_bull and not ts.fast_bull and not ts.core_bull and ts.rank_trend > 0 and ts.adapt_sep >= min_early_adapt_sep and ts.rank_value >= min_primary_rankval
                early_count := early_count + 1

    // Fresh Heated names
    int fresh_count = 0
    if n > 0
        for i = 0 to n - 1
            TickerState ts = array.get(states, i)
            if ts.consensus == 3 and ts.bars_in_state <= 10 and ts.rank_trend > 0.5 and ts.rank_value >= min_primary_rankval
                fresh_count := fresh_count + 1

    string out = ""
    if add_count > 0
        string base = ""
        if curr_cluster_count >= min_cluster_count
            if cluster_bars_active >= tf_sustained_to_mature
                base := "Top read: strengthening Heated thinning under mature cluster — " + str.tostring(add_count) + " names\n - individual names weakening · breadth turning down"
            else if cluster_bars_active >= tf_fresh_to_sustained
                base := "Top read: strengthening Heated holding under cluster pressure — " + str.tostring(add_count) + " names\n - cluster sustained; possible turn-down forming; cluster " + str.tostring(cluster_bars_active) + "b active"
            else
                base := "Top read: strengthening Heated under fresh cluster pressure — " + str.tostring(add_count) + " names · top-RankVal names are the most extended"
        else
            base := "Top read: strengthening Heated — " + str.tostring(add_count) + " names aligned and rising · RankVal +" + str.tostring(add_min_rank, "#.0") + " to +" + str.tostring(add_max_rank, "#.0")
        out := warn_count > 0 ? base + "   ⚠ " + str.tostring(warn_count) + " Adapt-bearish in Liquid — see Liquid phase" : base
    else if warn_count > 0
        out := "Top read: ⚠ " + str.tostring(warn_count) + " Adapt-bearish divergence" + (warn_count > 1 ? "s" : "") + " in Liquid phase"
    else if curr_bull_cluster_count >= min_cluster_count
        if bull_cluster_bars_active >= tf_sustained_to_mature
            out := "Top read: ✦ Bull cluster mature — " + str.tostring(curr_bull_cluster_count) + " names · turn-up setup across multiple names\n · Thawing phase shows the early-stage names"
        else if bull_cluster_bars_active >= tf_fresh_to_sustained
            out := "Top read: ✦ Bull cluster sustained — " + str.tostring(curr_bull_cluster_count) + " names · possible turn-up forming · slower filters not yet aligned; cluster " + str.tostring(bull_cluster_bars_active) + "b active"
        else
            out := "Top read: ✦ Bull cluster forming — " + str.tostring(curr_bull_cluster_count) + " Thawing names, Adapt-only bullish · fast frame only; daily structure has not turned"
    else if early_count > 0
        out := "Top read: " + str.tostring(early_count) + " early-reversal signal" + (early_count > 1 ? "s" : "") + " in Thawing phase"
    else if fresh_count > 0
        out := "Top read: " + str.tostring(fresh_count) + " fresh Heated entrant" + (fresh_count > 1 ? "s" : "") + " — see ranked rows"
    else
        if n_elite > n / 2
            out := "Top read: Heated phase saturated — low discrimination among top names; broad alignment"
        else if n_bear > n / 3
            out := "Top read: breadth weak — universe skewed to the Frozen phase"
        else
            out := "Top read: no standout configuration — universe is mixed across phases"
    out

// =============================================================================
// 17. DISPLAY HELPERS  (with temperature/phase state tags)
// =============================================================================
// PASTE ORDER MATTERS (Pine v6 declare-before-use):
//   f_sep_str, f_bull_arrow, f_trend_arrow  (existing — unchanged)
//   f_temperature                            (new)
//   f_phase, f_state_tag                     (new)
//   build_row_detail                         (modified tail)
//   build_score_cell, build_bear_list        (existing — unchanged)
// This block is the ENTIRE Section 17. Replace your current Section 17 with it.

f_sep_str(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "#.0")

f_bull_arrow(bool bull) =>
    bull ? "↑" : "↓"

f_trend_arrow(float trend) =>
    trend > 0.5 ? "↑" : trend < -0.5 ? "↓" : "→"

// ── Temperature: intensity + trend, on the rank_value axis only ─────────────
// Boiling >=40 (extreme, ~2x conviction floor); Hot/Simmering >=19 (the
// existing conviction floor) split by trend; mid-range Warming/Cooling/Warm;
// near-zero Tepid; negative Cold/Freezing. Direction is carried by the ▲▼
// arrow, so Boiling = extreme magnitude regardless of sign.
f_temperature(TickerState ts) =>
    string temp = ""
    if ts.rank_value >= 40.0
        temp := "Boiling"
    else if ts.rank_value >= 19.0
        temp := ts.rank_trend > 0.5 ? "Hot" : "Simmering"
    else if ts.rank_value >= 5.0
        temp := ts.rank_trend > 0.5 ? "Warming" : ts.rank_trend < -0.5 ? "Cooling" : "Warm"
    else if ts.rank_value >= -5.0
        temp := ts.rank_trend > 0.5 ? "Warming" : ts.rank_trend < -0.5 ? "Cooling" : "Tepid"
    else
        temp := ts.rank_trend < -0.5 ? "Freezing" : "Cold"
    temp

// ── Phase: filter-count state (matches the renamed tier headers) ────────────
f_phase(int consensus) =>
    consensus == 3 ? "Heated" :
     consensus == 2 ? "Liquid" :
     consensus == 1 ? "Thawing" :
                      "Frozen"

// ── State tag: phase · temperature · direction ──────────────────────────────
// Universe-level cluster pressure is NOT stamped here — it lives once in the
// Regime line. A name's own Adapt dissent is already visible in its F/Co/A
// arrows. Frozen drops the redundant temp word unless actively freezing.
f_state_tag(TickerState ts, string arrow) =>
    string phase = f_phase(ts.consensus)
    string temp  = f_temperature(ts)
    string out = ""
    if ts.consensus == 0
        out := temp == "Freezing" ? phase + " · Freezing " + arrow : phase + " " + arrow
    else
        out := phase + " · " + temp + " " + arrow
    out

// ── Row detail — tail now emits the state tag ──
build_row_detail(string tkr, string ret_dir, TickerState ts) =>
    string base = " " + tkr + " " + ret_dir + " " + str.tostring(ts.bars_in_state, "#") + "b" +
         "  C:" + str.tostring(ts.cal, "#.0") +
         "  F"  + f_bull_arrow(ts.fast_bull)  + f_sep_str(ts.fast_sep) +
         " Co"  + f_bull_arrow(ts.core_bull)  + f_sep_str(ts.core_sep) +
         " A"   + f_bull_arrow(ts.adapt_bull) + f_sep_str(ts.adapt_sep) +
         "  [" + (ts.stop_dist >= 0 ? "+" : "") + str.tostring(ts.stop_dist, "#.0") + "%]"
    show_tags ? base + "  →  " + f_state_tag(ts, ret_dir) : base

build_score_cell(TickerState ts) =>
    f_sep_str(ts.rank_value) + " " + f_trend_arrow(ts.rank_trend)

build_bear_list(array<int> idxs) =>
    string out = ""
    int sz = array.size(idxs)
    if sz > 0
        for i = 0 to sz - 1
            int idx = array.get(idxs, i)
            string tkr = array.get(tickers, idx)
            string sep = i == 0 ? "" : ", "
            int colon = str.pos(tkr, ":")
            string short = na(colon) ? tkr : str.substring(tkr, colon + 1)
            out := out + sep + short
    out


// =============================================================================
// 18. TABLE ARCHITECTURE
//   4 columns × 8.25% each = 33% of canvas width.
//   Top panel: Label | Value | Label | Value (symmetric, every row).
//   Screener:  Rank  | Detail (cols 1+2 merged = 16.5%) | RankVal
//   Both panels render at exactly the same 33% width.
// =============================================================================

string table_pos_select = input.string("Top Right", "Table Position",
     options=["Top Left", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Right"],
     group="Display",
     tooltip="Position the dashboard table in any corner or middle edge of the chart. Useful when running multiple indicators to avoid overlap.")

map_pos = switch table_pos_select
    "Top Left"      => position.top_left
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Right"  => position.bottom_right
    => position.top_right

map_size = t_size == "Tiny"   ? size.tiny   :
           t_size == "Normal" ? size.normal :
           t_size == "Large"  ? size.large  : size.small

var table n_table = table.new(map_pos, 4, 100, bgcolor=C_BG, border_color=C_BORDER, border_width=1)

if barstate.islast
    int r = 0

    // ══════════════════════════════════════════════════════════════
    // TOP PANEL — Symmetric 4-column layout
    // Every row uses Label | Value | Label | Value (no merges in body)
    // ══════════════════════════════════════════════════════════════
    if show_resolved
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, " " + rr_sym + "  " + syminfo.ticker + ": " + rr_txt,
            text_color=rr_col, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left,
            tooltip="RESOLVED READ — the one chart-specific line in this table, prefixed with the ticker.\n\nIt compares three things and states the result as one fact:\n  1. This chart's read of the stock (fast frame)\n  2. The stock's own daily structure (the fixed anchor)\n  3. The universe tide — cluster pressure across all names\n\nWhen the stock and the universe disagree, the line says so and names whose strength or weakness it is. Both can be true at once: one stock aligned up while the group turns down. The line reports the relationship; it is not a trade instruction.\n\nEverything below this line is universe-level and identical on every chart.")
        r := r + 1

    if show_main_table
        // Title (spans full width)
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, "◈ Ehlers Adaptive Trend Filter ◈",
             text_color=C_GOLD, bgcolor=C_HEAD, text_size=size.normal)
        r := r + 1

        // Row: Trend Status / Technical Rating
        table.cell(n_table, 0, r, "Trend Status",         text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 1, r, asset_mission,           text_size=map_size, text_color=asset_mission == "Above" ? C_UP : C_DOWN, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 2, r, "Baseline Margin",       text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, a_safety,                text_size=map_size, text_color=a_safety == "Wide" ? C_UP : a_safety == "Below baseline" ? C_DOWN : C_FALL, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Row: Momentum / Momentum Trend
        string mom_lbl = momentum_lb != effective_mom_lb ? "Momentum (adj " + str.tostring(effective_mom_lb) + "b)" : "Momentum (" + str.tostring(momentum_lb) + "b)"
        table.cell(n_table, 0, r, mom_lbl,                 text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 1, r, w_force_label + " (" + str.tostring(w_force_val, "#.##") + "%)", text_size=map_size, text_color=C_GOLD, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 2, r, "Momentum Trend",        text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, w_trend1,                text_size=map_size, text_color=C_TXT, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Row: Support Slope (full width pair kept; left cell now shows slope label)
        table.cell(n_table, 0, r, "Support Slope",         text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 1, r, (c_slope > 0.01 ? "Positive" : c_slope < -0.01 ? "Negative" : "Neutral") + " (" + str.tostring(c_slope, "#.##") + "%)", text_size=map_size, text_color=C_TXT, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 2, r, "",                      text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, "",                      text_size=map_size, text_color=C_TXT, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Row: Safety Margin / Price Deviation
        table.cell(n_table, 0, r, "Safety Margin",         text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 1, r, str.tostring(h_clear, "#.##") + "%", text_size=map_size, text_color=C_GOLD, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 2, r, "Price Deviation",       text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, d_status + " (" + d_sign + str.tostring(d_var, "#.##") + "%)", text_size=map_size, text_color=C_ACTION, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Row: Volatility / Vol Baseline (compact values to fit symmetric layout)
        table.cell(n_table, 0, r, "Volatility",            text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 1, r, str.tostring(rolling_vol, "#.##") + "%", text_size=map_size, text_color=C_SKY, text_halign=text.align_left, width=8.25)
        string vol_lb_txt = auto_vol_lb ? "Auto" : str.tostring(vol_lookback) + "b"
        table.cell(n_table, 2, r, "Vol Baseline (" + vol_lb_txt + ")", text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, str.tostring(vol_baseline, "#.##") + "% @ " + str.tostring(int(vol_percentile * 100)) + "%ile", text_size=map_size, text_color=C_SKY, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Row: Thresholds / Analysis Mode
        string mode_desc = filter_config == "MAMA/FAMA (Adaptive)" ? "MAMA/FAMA" : auto_mode ? "Auto (" + str.tostring(m_detox) + "/" + str.tostring(m_anchor) + ")" : "Manual"
        table.cell(n_table, 0, r, "Thresholds",            text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        string thresh_txt = (enable_adaptive ? "Adap" : "Fix") + " Ext:" + str.tostring(adaptive_extended, "#.#") + "% Pf:" + str.tostring(adaptive_perfect, "#.#") + "%"
        table.cell(n_table, 1, r, thresh_txt,              text_size=map_size, text_color=enable_adaptive ? C_GOLD : C_DIM, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 2, r, "Analysis Mode",         text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, mode_desc,               text_size=map_size, text_color=C_GOLD, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Row: Filter Config / MAMA Cycle
        string filter_short = filter_config == "2p+2p (Fast)" ? "2p+2p Fast" : filter_config == "3p+2p (Hybrid)" ? "3p+2p Hybrid" : filter_config == "MAMA/FAMA (Adaptive)" ? "MAMA/FAMA" : "3p+3p Smooth"
        table.cell(n_table, 0, r, "Filter Config",         text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 1, r, filter_short,            text_size=map_size, text_color=C_GOLD, text_halign=text.align_left, width=8.25)
        string mama_cyc_lbl = filter_config == "MAMA/FAMA (Adaptive)" ? "MAMA Cycle" : "Filter Lag"
        string mama_cyc_val = filter_config == "MAMA/FAMA (Adaptive)" ? str.tostring(math.round(_mPer), "#") + " bars" : filter_config == "2p+2p (Fast)" ? "~62 bars" : filter_config == "3p+2p (Hybrid)" ? "~70 bars" : "~88 bars"
        table.cell(n_table, 2, r, mama_cyc_lbl,            text_color=C_TXT, text_size=map_size, text_halign=text.align_left, width=8.25)
        table.cell(n_table, 3, r, mama_cyc_val,            text_size=map_size, text_color=C_GOLD, text_halign=text.align_left, width=8.25)
        r := r + 1

        // Status footer banner (spans full width)
        table.merge_cells(n_table, 0, r, 3, r)
        string sys_stat  = enable_adaptive ? "Adaptive" : "Fixed"
        string mama_stat = filter_config == "MAMA/FAMA (Adaptive)" ? " · MAMA cyc:" + str.tostring(math.round(_mPer),"#") + "b" : ""
        table.cell(n_table, 0, r, "System Active · " + sys_stat + " · " + (vol_ready ? "Vol Ready" : "Warming Up") + mama_stat, text_color=C_SKY, text_size=size.small)
        r := r + 1

    // ══════════════════════════════════════════════════════════════
    // SCREENER PANEL — Consensus Engine v14
    // 3-region layout matching 33% canvas:
    //   col 0       = Rank      (8.25%)
    //   cols 1+2    = Detail    (16.5% via merge)
    //   col 3       = RankVal   (8.25%)
    // ══════════════════════════════════════════════════════════════
    if show_screener
        // Title (spans full width) — includes active universe name + ticker count
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, "◈ Consensus Engine — " + universe_select + " (" + str.tostring(n) + " tickers) ◈", text_color=C_GOLD, bgcolor=C_HEAD, text_size=size.normal)
        r := r + 1

        if not sec_ok
            table.merge_cells(n_table, 0, r, 3, r)
            table.cell(n_table, 0, r, " ⚠ Security budget exceeded: " + str.tostring(n) + "/40. Reduce ticker count.", text_color=C_DOWN, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left)
            r := r + 1

        // State summary (spans full width)
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, " Heated " + str.tostring(n_elite) + "  ·  Liquid " + str.tostring(n_confirmed) + "  ·  Thawing " + str.tostring(n_emerging) + "  ·  Frozen " + str.tostring(n_bear) + "   |   Weights F:" + str.tostring(w_fast,"#.##") + " Co:" + str.tostring(w_core,"#.##") + " A:" + str.tostring(w_adapt,"#.##"), text_color=C_DIM, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left)
        r := r + 1

        // Timeframe role note — surfaces the indicator's multi-timeframe design
        table.merge_cells(n_table, 0, r, 3, r)
        string tf_note = "Timeframe: " + str.tostring(tf_minutes) + "m · role: " + tf_role
        color tf_note_color = tf_minutes >= 1440 ? C_GOLD :
                              tf_minutes >= 240  ? C_SKY :
                              tf_minutes >= 60   ? C_FALL :
                                                   C_DOWN
        table.cell(n_table, 0, r, " " + tf_note, text_color=tf_note_color, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left,
             tooltip="Multi-timeframe workflow:\n\n  • DAILY (1440m+): primary detection. Cluster signals and Top Read drive action recommendations. State machine fires transition alerts.\n\n  • 4H (240-1439m): verification. Individual stock tags (CAUTION, TRIM) lead daily-chart tag transitions by 1-3 sessions. Use this timeframe to confirm daily-chart structural signals.\n\n  • 1H (60-239m): fast monitoring. Signals are scaled to compensate for shorter bars but still noisier than daily/4H.\n\n  • Faster than 1H: signals suppressed via scaling. Cluster persistence requires real-time equivalents of 1+ trading day to register as 'fresh', preventing intraday noise from triggering false signals.\n\nThis design commits the indicator to a primary→verification workflow. Other timeframes work but produce less reliable signals.")
        r := r + 1

        // State machine transition banner — shows for 2 bars after a daily transition
        if tf_minutes >= 1440 and bars_since_transition <= 2 and str.length(last_transition_text) > 0
            table.merge_cells(n_table, 0, r, 3, r)
            color banner_color = cluster_advancing or cluster_retreating ? C_ACTION : C_SKY
            table.cell(n_table, 0, r, " " + last_transition_text, text_color=C_BG, bgcolor=banner_color, text_size=size.normal, text_halign=text.align_left,
                 tooltip="Cluster stage transition detected on daily chart. This is your prompt to verify on the 4H chart:\n\n  • Open the 4H chart with this same indicator\n  • Check whether individual stock tags (CAUTION, TRIM, WATCH) on cluster names are escalating in the same direction\n  • If 4H confirms: structural turn is broadly aligned across timeframes, action implications strengthen\n  • If 4H diverges: the daily transition may be early or noise; wait for further confirmation\n\nNotification persists for 2 bars after the transition. Fires only on daily charts (state machine is calibrated to primary-detection timeframe).")
            r := r + 1

// Regime row (spans full width) — with Adapt-cluster (bearish + bullish) + persistence stages
        string regime_text = classify_regime(n_elite, n_confirmed, n_emerging, n_bear, n)

        // Regime parenthetical — resolves cognitive dissonance when regime classification and cluster direction diverge
        bool regime_is_bullish = str.contains(regime_text, "Uptrend")
        bool regime_is_bearish = str.contains(regime_text, "Risk-Off")
        bool bearish_pressure_meaningful = curr_cluster_count >= min_cluster_count and cluster_bars_active >= tf_fresh_to_sustained
        bool bullish_pressure_meaningful = curr_bull_cluster_count >= min_cluster_count and bull_cluster_bars_active >= tf_fresh_to_sustained
        string regime_qualifier = ""
        if regime_is_bullish and bearish_pressure_meaningful
            regime_qualifier := " (turning down)"
        else if regime_is_bearish and bullish_pressure_meaningful
            regime_qualifier := " (turning up)"
        if str.length(regime_qualifier) > 0
            regime_text := str.replace(regime_text, " — ", regime_qualifier + " — ", 0)

        string cluster_descriptor = cluster_bars_active >= tf_sustained_to_mature ? "mature — regime turn-down underway" : cluster_bars_active >= tf_fresh_to_sustained ? "sustained — possible turn-down forming" : "fresh — fast frame only, not yet in the daily structure"
        string cluster_part = curr_cluster_count >= min_cluster_count ? "⚠ Adapt cluster: " + str.tostring(curr_cluster_count) + " names · " + str.tostring(cluster_bars_active) + "b active · " + cluster_descriptor : ""
        string bull_cluster_descriptor = bull_cluster_bars_active >= tf_sustained_to_mature ? "mature — regime turn-up setup confirmed" : bull_cluster_bars_active >= tf_fresh_to_sustained ? "sustained — possible turn-up forming" : "fresh — fast frame only, not yet in the daily structure"
        string bull_cluster_part = curr_bull_cluster_count >= min_cluster_count ? "✦ Bull cluster: " + str.tostring(curr_bull_cluster_count) + " names · " + str.tostring(bull_cluster_bars_active) + "b active · " + bull_cluster_descriptor : ""
        // Cluster breadth ratio — embedded as trailing annotation on bull cluster line when both clusters are active
        string ratio_text = ""
        if curr_cluster_count >= min_cluster_count and curr_bull_cluster_count >= min_cluster_count
            float ratio = float(curr_cluster_count) / curr_bull_cluster_count
            float inv_ratio = float(curr_bull_cluster_count) / curr_cluster_count
            string lean = ratio >= 2.0 ? "strong lean toward turn-down" :
                          ratio >= 1.5 ? "moderate lean toward turn-down" :
                          inv_ratio >= 2.0 ? "strong lean toward turn-up" :
                          inv_ratio >= 1.5 ? "moderate lean toward turn-up" :
                                             "balanced breadth"
            ratio_text := "\n ·  Breadth Ratio " + str.tostring(curr_cluster_count) + ":" + str.tostring(curr_bull_cluster_count) + " (" + lean + ")"
        string cluster_line1 = str.length(cluster_part) > 0 ? "\n " + cluster_part : ""
        string cluster_line2 = str.length(bull_cluster_part) > 0 ? "\n " + bull_cluster_part + ratio_text : ""
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, " Regime: " + regime_text + cluster_line1 + cluster_line2, text_color=C_ACTION, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left,
             tooltip="REGIME ROW — structural read of the universe at the current bar.\n\nLine 1: regime classification based on breadth distribution across the four tiers (Elite, Confirmed, Emerging, Bear). Categories include Broad Uptrend (Elite-dominant), Distributed Uptrend (broad participation), Narrow Leadership, Defensive Posture, Distributed Weakness, and Broad Downtrend.\n\nLine 2 (when active): ⚠ Adapt cluster — names in the Confirmed tier (2 of 3 filters bullish) where the Adapt filter has flipped bearish while Fast and Core remain bullish. This is early structural pressure on names that are still officially in good standing. Persistence stages:\n  • fresh (1-2 bars): initial detection, verify\n  • sustained (3-9 bars): pressure holding, possible turn-down forming\n  • mature (10+ bars): individual warnings now firing, regime turn-down underway\n\nLine 3 (when active): ✦ Bull cluster — names in the Emerging tier (1 of 3 filters bullish) where only the Adapt filter is bullish. These are cycle bottoms forming under apparent weakness. Persistence stages:\n  • fresh: initial detection, verify\n  • sustained: bottoming setup forming, possible turn-up forming\n  • mature: bottoming pattern confirmed across multiple names, regime turn-up setup confirmed (note: setup ≠ turn — slower filters haven't caught up yet)\n\nBreadth ratio annotation (when both clusters active, appended to line 3): the relative breadth of structural pressure in each direction. A 2:1 ratio toward turn-down means the degrading side has twice the breadth of the bottoming side. This is interpretive context, not prediction:\n  • >= 2:1 either way: strong lean\n  • 1.5:1 to 2:1: moderate lean\n  • < 1.5:1: balanced breadth\n\nThe two clusters are NOT contradictory — they describe different tiers responding to the same regime transition. The bearish cluster catches Confirmed-tier names degrading; the bullish cluster catches Emerging-tier names bottoming. In a healthy regime turn, both can fire simultaneously: some names rolling over while others bottom out at different cycle stages.\n\nPersistence thresholds auto-scale to the chart's timeframe. On daily charts, fresh/sustained/mature use 1-2/3-9/10+ bars. On faster timeframes, the bar counts are scaled up to keep the real-time meaning roughly constant.")
        r := r + 1

        // Primary Read row (spans full width) — synthesis line, situation-aware
        if show_tags
            string primary = primary_read()
            table.merge_cells(n_table, 0, r, 3, r)
            table.cell(n_table, 0, r, " " + primary, text_color=C_GOLD, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left)
            r := r + 1

        // Column headers
        table.cell(n_table, 0, r, " Rank", text_color=C_DIM, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_center, width=8.25)
        string col1_hdr = show_tags ? " Ticker ▲▼ Nb  |  C=Calmar  F/Co/A↑↓=sep  [stop%]  →  State" : " Ticker ▲▼ Nb  |  C=Calmar  F/Co/A↑↓=sep  [stop%]"
        table.merge_cells(n_table, 1, r, 2, r)
        table.cell(n_table, 1, r, col1_hdr, text_color=C_DIM, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left)
        table.cell(n_table, 3, r, " RankVal ↑↓", text_color=C_DIM, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_center, width=8.25)
        r := r + 1

        // ELITE
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, " ◆ HEATED (" + str.tostring(n_elite) + ") — all 3 filters aligned bullish",
             text_color=C_UP, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left,
             tooltip="HEATED PHASE — all three Ehlers filters (Fast 2p+2p, Core 3p+2p, Adaptive MAMA/FAMA) agree the trend is up at every timescale. The fullest consensus the engine measures.\n\nThe per-row temperature describes intensity and trend within this phase:\n  • Boiling — extreme separation (RankVal >= 40)\n  • Hot / Simmering — strong separation (RankVal >= 19), rising or not\n  • Warming / Cooling — mid-range, rising or falling\n\nWhen a bearish Adapt-cluster is active on the Regime line, the row background tint shifts (green → amber → red as the cluster matures) to show the structural pressure these names sit under. The temperature still describes each name's own move; the cluster pressure is reported separately on the Regime line and as the background tint. The two are independent: a Boiling name can sit under a mature cluster — strong on its own terms, with broad pressure building beneath.")
        r := r + 1

        if n_elite > 0
            int show_e = math.min(max_per_state, n_elite)
            for k = 0 to show_e - 1
                int idx = array.get(elite_idxs, k)
                TickerState ts = array.get(states, idx)
                string tkr = array.get(tickers, idx)
                string dir = ts.ret63 > 0 ? "▲" : "▼"
                color row_bg = elite_row_highlight(ts, C_UP, C_FALL, C_DOWN)
                // Text color also shifts under mature cluster — red text on red bg communicates the regime turn explicitly
                color row_text = cluster_bars_active >= tf_sustained_to_mature and is_add_strengthening(ts) and ts.rank_value >= min_add_rankval ? C_DOWN : C_UP
                table.cell(n_table, 0, r, " #" + str.tostring(k + 1), text_color=row_text, bgcolor=row_bg, text_size=map_size, text_halign=text.align_center, width=8.25)
                table.merge_cells(n_table, 1, r, 2, r)
                table.cell(n_table, 1, r, build_row_detail(tkr, dir, ts), text_color=row_text, bgcolor=row_bg, text_size=map_size, text_halign=text.align_left)
                table.cell(n_table, 3, r, build_score_cell(ts), text_color=row_text, bgcolor=row_bg, text_size=map_size, text_halign=text.align_center, width=8.25)
                r := r + 1
        else
            table.merge_cells(n_table, 0, r, 3, r)
            table.cell(n_table, 0, r, "   (none)", text_color=C_DIM, text_size=map_size, text_halign=text.align_left)
            r := r + 1

        // CONFIRMED
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, " ◆ LIQUID (" + str.tostring(n_confirmed) + ") — 2 of 3 filters bullish",
             text_color=C_SKY, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left,
             tooltip="LIQUID PHASE — two of three filters bullish, one dissenting. The dissenting filter is where the meaning lives:\n\n  • Adapt bearish: the cycle detector flipped first while slower filters still see the uptrend — structural pressure under apparent strength.\n\n  • Fast bearish: a short-term pullback inside a longer uptrend — often resolves back to the Heated phase.\n\n  • Core bearish (rare): a cross-period transition, sometimes an early-stage Heated phase forming.\n\nCheck the F/Co/A arrows on each row to see which filter is the dissenter. The temperature still describes each name's intensity and trend within the phase.")
        r := r + 1

        if n_confirmed > 0
            int show_c = math.min(max_per_state, n_confirmed)
            for k = 0 to show_c - 1
                int idx = array.get(confirmed_idxs, k)
                TickerState ts = array.get(states, idx)
                string tkr = array.get(tickers, idx)
                string dir = ts.ret63 > 0 ? "▲" : "▼"
                table.cell(n_table, 0, r, " #" + str.tostring(k + 1), text_color=C_SKY, text_size=map_size, text_halign=text.align_center, width=8.25)
                table.merge_cells(n_table, 1, r, 2, r)
                table.cell(n_table, 1, r, build_row_detail(tkr, dir, ts), text_color=C_SKY, text_size=map_size, text_halign=text.align_left)
                table.cell(n_table, 3, r, build_score_cell(ts), text_color=C_SKY, text_size=map_size, text_halign=text.align_center, width=8.25)
                r := r + 1
        else
            table.merge_cells(n_table, 0, r, 3, r)
            table.cell(n_table, 0, r, "   (none)", text_color=C_DIM, text_size=map_size, text_halign=text.align_left)
            r := r + 1

        // EMERGING
        if show_emerging
            table.merge_cells(n_table, 0, r, 3, r)
            table.cell(n_table, 0, r, " ◆ THAWING (" + str.tostring(n_emerging) + ") — 1 of 3 filters bullish",
                 text_color=C_FALL, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left,
                 tooltip="THAWING PHASE — only one of three filters has flipped bullish while the others remain bearish. The earliest stage of a possible turn at a single timescale, not yet confirmed across the others.\n\nWhich filter is the lone bull determines the meaning:\n\n  • Adapt-only bullish: MAMA detected a cycle bottom before slower filters caught up — the notable subset.\n\n  • Fast-only bullish: a short-cycle bounce, usually noise.\n\n  • Core-only bullish: a rare medium-period anomaly.\n\nWhen multiple Adapt-only-bull names appear simultaneously, that is a bullish cluster — the symmetric counterpart to the bearish cluster, describing the universe bottoming rather than degrading. The row highlight (cyan) marks Adapt-only-bull names with rising rank while a bull cluster is sustained or mature. The temperature still describes each name's own intensity and trend.")
            r := r + 1

            if n_emerging > 0
                int show_em = math.min(max_per_state, n_emerging)
                for k = 0 to show_em - 1
                    int idx = array.get(emerging_idxs, k)
                    TickerState ts = array.get(states, idx)
                    string tkr = array.get(tickers, idx)
                    string dir = ts.ret63 > 0 ? "▲" : "▼"
                    color em_row_bg = emerging_row_highlight(ts, C_SKY)
                    // Text color shifts to cyan for mature bullish cluster entry candidates
                    color em_row_text = bull_cluster_bars_active >= tf_sustained_to_mature and ts.consensus == 1 and ts.adapt_bull and not ts.fast_bull and not ts.core_bull and ts.rank_trend > 0.5 ? C_SKY : C_FALL
                    table.cell(n_table, 0, r, " #" + str.tostring(k + 1), text_color=em_row_text, bgcolor=em_row_bg, text_size=map_size, text_halign=text.align_center, width=8.25)
                    table.merge_cells(n_table, 1, r, 2, r)
                    table.cell(n_table, 1, r, build_row_detail(tkr, dir, ts), text_color=em_row_text, bgcolor=em_row_bg, text_size=map_size, text_halign=text.align_left)
                    table.cell(n_table, 3, r, build_score_cell(ts), text_color=em_row_text, bgcolor=em_row_bg, text_size=map_size, text_halign=text.align_center, width=8.25)
                    r := r + 1
            else
                table.merge_cells(n_table, 0, r, 3, r)
                table.cell(n_table, 0, r, "   (none)", text_color=C_DIM, text_size=map_size, text_halign=text.align_left)
                r := r + 1

        // BEAR
        if show_bear
            table.merge_cells(n_table, 0, r, 3, r)
            table.cell(n_table, 0, r, " ◆ FROZEN (" + str.tostring(n_bear) + ") — 0 filters bullish",
                 text_color=C_DOWN, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left,
                 tooltip="FROZEN PHASE — no bullish consensus; all three Ehlers filters see a downtrend at every timescale. Inert.\n\nThree ways to read it:\n\n  • A list of names with no bullish filter agreement.\n\n  • A breadth gauge — a high Frozen count describes universe-wide weakness.\n\n  • A thaw watch — when names start leaving the Frozen phase (moving to Thawing or higher), that is the earliest structural change the engine surfaces.\n\nNo per-row temperature gradient is shown here because the phase is uniformly inert; what matters is the count and which names occupy it.")
            r := r + 1

            table.merge_cells(n_table, 0, r, 3, r)
            string bear_listing = n_bear > 0 ? "   " + build_bear_list(bear_idxs) : "   (none)"
            table.cell(n_table, 0, r, bear_listing, text_color=C_DOWN, text_size=map_size, text_halign=text.align_left)
            r := r + 1

        // Footers
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, "Nb=bars in state · C=Calmar · F/Co/A↑↓=filter bull/bear+sep% · [%]=stop dist to CORE baseline · → tag=structural state", text_color=C_SKY, text_size=size.small)
        r := r + 1

        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, "Consensus Engine | " + str.tostring(n + 1) + "/40 security calls (incl. daily fetch) | Interpretation tags toggleable in 'Consensus Engine' settings", text_color=C_DIM, text_size=size.small)
    else
        table.merge_cells(n_table, 0, r, 3, r)
        table.cell(n_table, 0, r, "◈ Consensus Engine: Off  (enable in 'Screener Panel' settings) ◈", text_color=C_DIM, bgcolor=C_HEAD, text_size=size.small)
````
