# Options Decision Dashboard   CPR, Expected Move & Day Type

- url: https://www.tradingview.com/script/294UHHew-Options-Decision-Dashboard-CPR-Expected-Move-Day-Type/
- type: indicator
- pine_id: PUB;330e8b45cd83429b92fa5ae34a6471eb
- version: 7.0

## Description

Overview

An index option buyer loses to theta unless the day actually moves. So the first question isn't "which way?" — it's "will this session trend at all, and is implied volatility cheap enough to pay for the ride?"

This dashboard answers that in one panel, before the session gets going:


DAY TYPE — from the Central Pivot Range. Narrow CPR historically precedes trending days; wide CPR precedes rangebound ones.
DIRECTION — from where price sits against the CPR, plus the two-day pivot-range relationship.
THE PRICE OF THE BET — from the volatility index: the expected move it's charging you for.
TIME — days to expiry, and the theta context.


It then states a plain-language verdict — BUY CE / BUY PE / SELL PREMIUM / STAY OUT — with the CPR and floor-pivot levels drawn on price, targets and invalidation marked.

What makes it different

Every CPR script asserts that a narrow CPR means a trending day. None of them check.

This one forward-tests its own core claim. Each session's CPR type is logged at the open, and at the close the day is scored as trending or not (by directional efficiency: how much of the day's range price actually closed away from its open). The panel then reports the trend-day hit rate for narrow-CPR sessions against the unconditional base rate, with a Wilson 95% lower bound.

If narrow CPR carries no edge on your instrument, the dashboard says so — and you should discount its day-type logic accordingly. It is built to be able to tell you it doesn't work.

Why the four layers are ONE tool

An option-buying decision needs all four at once:


Day type without volatility pricing tells you to buy an option that may be too expensive.
Volatility pricing without day type tells you it's cheap without telling you whether it will move.
Either without the levels gives you no entry, target or invalidation.
All three without the calibration is just another confident indicator.


Remove one and the decision isn't decidable.

How it works


CPR — Pivot = (H+L+C)/3 · BC = (H+L)/2 · TC = 2·Pivot − BC, from the prior session. Width is normalised as a % of the pivot and rank-scored against its own recent history, so "narrow" means narrow for this instrument — not a hard-coded point value. (10 points is narrow on NIFTY and wide on a mid-cap.)
Two-day relationship — higher / lower / overlapping / inside / outside value: the classic Pivot-Boss classifications, used as the directional prior.
Expected move — EM = Spot × (IV/100) × √t, shown for the day and to expiry, and drawn as a band. If the session stays inside that band, an option buyer typically loses to theta — which is exactly the trap this tool exists to flag.
Verdict — combines day type, direction, IV percentile and days-to-expiry into one call. Expensive IV can veto a buy; expiry-day theta can veto it too.


How to use it

Read it top-down at the open. Day type tells you whether to buy options at all. Direction tells you which side. Expected move tells you whether the premium is worth it. The verdict is the summary; the levels are your entry, target and invalidation.

Then — before you trust any of it — read the calibration row. If narrow CPR has no proven edge on this symbol, the day-type logic isn't carrying its weight here.

This is decision support. It does not place trades and it is not advice.

Data & scope

Built for NSE:NIFTY / BANKNIFTY index futures on intraday timeframes (5m or 15m is the CPR norm). Needs a volatility index for the expected-move layer (NSE:INDIAVIX by default); without one, that layer switches off cleanly and the rest still works.

Strike step, expiry weekday and volatility symbol are all inputs — so it runs on any index-options market. Set the expiry weekday to match your contract: the exchange has changed the index expiry day before, and this script does not assume, it asks.

On a daily+ chart the panel tells you to switch to intraday rather than showing a confident verdict built on a meaningless CPR.

Non-repainting

Prior-session values are requested as [1] on the daily series, so they're settled before the session opens and never move. The calibration harness logs at the session open and resolves at the session close, on confirmed bars only — a session is graded on the first bar of the next session, from completed data. Intraday readings (price vs level, day-so-far range) update as the session forms; that's a live read, not a repaint.

Concept credits

Central Pivot Range and the two-day pivot-range relationships — Frank Ochoa (Secrets of a Pivot Boss). Floor pivots (R1–R3 / S1–S3) — long-standing public trading-floor practice. Expected move from implied volatility — standard option-pricing arithmetic (Black-Scholes-Merton lineage). Wilson score interval — Edwin B. Wilson. ATR — J. Welles Wilder.

The day-type calibration harness, the expected-move comparison and the verdict engine are the author's own. No third-party Pine code is reused.

Honest limits

The CPR day-type claim is folklore until measured — which is exactly why this script measures it. Calibration figures are in-sample, with no costs, and a proven in-sample edge is not a guarantee out-of-sample. The expected move is a one-standard-deviation estimate under a lognormal assumption; real index returns have fat tails and gaps. The verdict describes conditions — it is not a recommendation — and it says nothing about strike selection, position sizing or risk.

Options carry the risk of TOTAL loss of premium. Nothing here predicts price.

Disclaimer

Research and educational tool only. Not financial advice, not a recommendation, no guarantee of results. Options trading carries a risk of total loss. Test out-of-sample and make your own decisions. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// INDIA OPTIONS ENGINE — IV · Premium · Expected Move · CPR & Day-Type                              v2.7
// ────────────────────────────────────────────────────────────────────────────────────────────
//  v2.7 — TWO ADDITIVE ml_india LAYERS on top of v2.6; the IV / RV / VRP / expected-move / CPR /
//    calibration engine and the buyer-decision verdict are UNCHANGED. Every HEADLINE EXP_ export the
//    Master engine and downstream links consume is kept; to stay under TradingView's 64-plot ceiling
//    with the two new layers, 8 low-value DIAGNOSTIC exports were retired (EXP_IVPct, EXP_VRP_Z,
//    EXP_ExpMove2Up/Dn, EXP_Vega, EXP_VRPEdge, EXP_IVHiEdge, EXP_VolCurve) — none is consumed
//    downstream and all remain visible in the Pro dashboard:
//      • OPTION-BUYER RISK GUARD (group 09c, default on): reads the ways a LONG option bleeds —
//        gap-shock IV crush (today's open gapped ≥ a fraction of the priced move), a false-momentum
//        trap on a range-type day, and theta into expiry — and reports a safe-to-buy gate (optionBuyOk)
//        plus a 0..1 quality multiplier. It NEVER changes the buyer verdict; it only annotates a BUY
//        with how safe it is to act on. New "Buy safety" / "Buy-safety guard" dashboard rows,
//        EXP_OptionBuyOk / EXP_OptionQuality / EXP_GapShock, and caution / clean-buy alerts.
//      • SPOT–FUTURES BASIS (group 11, default on): the futures premium/discount the VIX/IV reads
//        don't capture — (fut − spot)/spot, annualized by DTE, with a self-calibrating premium /
//        discount regime. EXP_Basis / EXP_BasisAnn / EXP_BasisState and two alerts. One added
//        request.security; the rest of the engine is untouched.
//  v2.6 — MERGED IN THE BUYER-DECISION LAYER (CPR width-percentile day-type, two-day CPR direction,
//    a forward-tested "narrow CPR → trend" hit-rate with a Wilson lower bound, and a BUY CE / BUY PE /
//    SELL PREMIUM / STAY OUT verdict) so the one tool answers BOTH "how is volatility priced / does
//    selling premium pay?" AND "will the day move, which way, and is the option cheap enough to buy?".
//    The buyer layer consumes ONLY the Engine's already-computed series (CPR, floor pivots, expected
//    move, IV/VRP/environment, DTE) — it adds ZERO new request.security calls (the one extra daily
//    series it needs, the prior-session OPEN, rides the existing merged daily bus). The volatility
//    ENVIRONMENT lean and the buyer DAY-TYPE verdict are reconciled into ONE headline: a single
//    decision line plus a "why" that cites both axes. Brand generified; the EXP_ bus is unchanged.
// ────────────────────────────────────────────────────────────────────────────────────────────
//  v2.5 — ROBUSTNESS, BUDGET & A BIAS-READABLE CHART (from a full audit; EXP_ bus unchanged)
//    • Fix: a manual ATM override (tapeATMin > 0) used to resolve real option tickers on HISTORICAL
//      bars, which — on non-VIX IV modes — could feed phantom option history into IV / VRP / the
//      calibration. The override now applies on the last bar only, so history stays clean.
//    • Fix: with Auto-root ON, the expected-move horizon now uses the SAME auto-detected settlement
//      weekday as the tape (e.g. NIFTY Tuesday, Sensex Thursday) instead of the stale manual default,
//      so weekly / monthly DTE and the EM cone are right per index.
//    • Robustness: the India-VIX requests now use ignore_invalid_symbol, so an unavailable / blank
//      volatility symbol falls back cleanly to the tape / manual IV path instead of erroring.
//    • Budget: realized vol is fetched together with the daily OHLC bus in one merged daily request,
//      and the monthly-CPR request is made only when that (default-OFF) toggle is on — fewer daily
//      security dispatches, more RE10137 headroom, behaviour-identical. Over-sized drawing buffers
//      were right-sized.
//    • Visuals: a faint full-chart VOL-ENVIRONMENT WASH (gold = premium-sell · blue = long-vol ·
//      green = with-trend · red = tail risk) so the environment reads at a glance without opening the
//      panel (toggle "Tint chart by vol environment", default ON). The dashboard action reads as a
//      LEAN (e.g. "PREMIUM-SELL LEAN") rather than an imperative.
//    • The full EXP_ export bus (names, encodings, gating) is UNCHANGED, so a Master engine and
//      any other downstream links keep working exactly as before.
// ────────────────────────────────────────────────────────────────────────────────────────────
//  WHAT IT READS  Not price — the PRICE OF OPTIONALITY. How dear volatility is (IMPLIED, from India
//    VIX with IV rank / percentile), how much the instrument actually moves (REALIZED, Yang-Zhang),
//    and the gap between them (the volatility-risk PREMIUM) — the structural edge sellers harvest and
//    buyers pay. Over that: EXPECTED-MOVE cones (1σ / 2σ) with a days-to-expiry engine, a Black-Scholes
//    ATM model (theoretical straddle, greeks, theta/day, breakevens), and a plain ENVIRONMENT read
//    (premium-sell / buy / directional / neutral — context, never a trade or strike call).
//
//  THE CORE FEATURE — THE HONESTY STACK  A daily-sampled forward test of whether selling rich premium
//    actually pays HERE: did realized stay within the priced 1σ move, and would a short ATM straddle
//    have profited, over the horizon? Scored vs a zone base rate (≈68% if IV is fair), with a Wilson
//    lower bound, an out-of-sample split, a per-filter A/B, and Net-R after cost — rolling into a plain
//    verdict (LEARNING → NO EDGE HERE → UNPROVEN → EDGE CONFIRMED). A TAIL-RISK GUARD disables
//    EDGE CONFIRMED and flags TAIL RISK when IV is in the top percentile or realized vol spikes,
//    because the premium collapses in crises. The tool is built to sometimes say "no edge here."
//
//  ORTHOGONAL TO THE VOLATILITY ENGINE  That engine reads REALIZED-vol REGIME for sizing/gating ("how
//    much is it moving?"). This reads IMPLIED vol and the IV−RV premium ("how much is the market
//    charging, and is that justified?"). Different axis, different job.
//
//  FORWARD PREMIUM (HAR / AR(1))  Beyond trailing IV−RV, it forecasts realized vol over the option
//    horizon (current RV mean-reverting to its long-run level at the data-estimated persistence φ) and
//    reports the FORWARD premium IV − forecast-RV — the edge sellers actually face. Compute-only.
//
//  STANDALONE + MASTER LINK  Works alone. Optionally links the Trend engine's EXP_Regime for the
//    DIRECTIONAL read, and PUBLISHES an EXP_ bus (EXP_EnvState, EXP_Tier, EXP_VRP, EXP_TailRisk, …) so
//    a Master engine can route the volatility environment as a gate.
//
//  REAL-TAPE MODE (optional, ON by default)  Reads the ACTUAL weekly ATM ±3 option ladder (real
//    premium & volume) for a real straddle, an IV proxy (Brenner-Subrahmanyam), a volume PCR, the
//    pin strike and the SKEW (risk-reversal: OTM put vs equidistant OTM call richness — put-rich =
//    downside fear) — a live cross-check to the VIX-derived reads. LIVE-ONLY: Pine can't mint new option
//    symbols per bar, so the ATM ladder is frozen at load (re-add / set ATM if spot drifts >2 strikes),
//    and it deliberately does NOT feed the calibration (which stays on the VIX series for valid history).
//    The pin/PCR ladder samples the round (institutional) strikes; the ATM straddle/IV uses the true nearest strike.
//    It also reads a spot-symmetric SKEW (risk-reversal: OTM put vs equidistant OTM call) and the
//    TERM STRUCTURE (front-week vs next-week ATM straddle IV — backwardation = event priced in front).
//
//  MANUAL OI WALLS & MAX-PAIN (optional, OFF by default)  Per-strike open interest and max-pain are NOT
//    exposed to Pine (TradingView can't read the option chain's OI), so these are user-entered from the
//    broker/NSE chain: the heaviest CE-OI strike (resistance), heaviest PE-OI strike (support) and the
//    max-pain magnet — drawn as levels and read in the panel. Nothing is fabricated; enter 0 to hide.
//
//  CPR REFERENCE (optional, ON by default)  Classic static CPR (Pivot/TC/BC), daily + weekly (monthly
//    optional) with floor pivots AND Camarilla H3/H4·L3/L4 (reversal / breakout levels, optionally shown
//    only on range-lean days), as the price-structure the expected move plays out against — read via
//    the CPR-width day-type, the two-day relationship, an EM-vs-CPR line and a structure×vol confluence.
//    A reference tool, never a signal; it does not feed the calibration.
//
//  NON-REPAINT  IV, realized vol, the premium, the CPR / pivot levels and the calibration are built from
//    confirmed daily / weekly / monthly values via request.security with lookahead off; the live bar is provisional.
//
//  CONCEPT CREDIT (all Pine original)  Whaley (VIX methodology); Parkinson, Garman-Klass, Yang-Zhang
//    (range realized-vol estimators); Black-Scholes / Merton (option pricing & greeks); Bakshi-Kapadia-
//    Madan & Carr-Wu (variance / vol risk premium); Bollerslev (VRP); López de Prado (triple-barrier);
//    Wilson (score interval); practitioner — Natenberg, Sinclair (Volatility Trading).
//
//  DISCLAIMER  Research and education only. NOT financial advice, NOT a signal service, and NOT an
//    option-trade or strike recommendation. Volatility selling carries severe, open-ended tail risk.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("India Options Engine — IV, Premium, Expected Move, CPR & Day-Type", "IND-OPT", overlay = true, max_labels_count = 80, max_lines_count = 60, max_boxes_count = 6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// ── 01 · IMPLIED VOLATILITY SOURCE ────────────────────────────────────────────────────────
g0 = "01 · Implied volatility source"
ivMode  = input.string("Auto (VIX → tape)", "IV source", options = ["Auto (VIX → tape)","India VIX (auto)","Custom IV symbol","Real tape (ATM straddle)","Manual IV %"], group = g0, tooltip = "Auto (default): India VIX for NIFTY, else the index's own ATM-straddle tape IV — so it works across NIFTY / BankNifty / FinNifty / Sensex. India VIX (auto) forces NSE:INDIAVIX. Custom IV symbol reads any IV/VIX symbol you name. Real tape uses the ATM straddle's implied vol. Manual lets you type one IV. If the chosen source is unavailable it falls back automatically (VIX→tape→manual).")
ivSymIn = input.symbol("NSE:INDIAVIX", "IV symbol (auto / custom)", group = g0)
manualIV= input.float(13.0, "Manual IV (annual %)", minval = 0.1, step = 0.5, group = g0)
ivWin   = input.int(252, "IV rank / percentile window (days)", minval = 20, group = g0, tooltip = "Trading-day lookback for IV rank (position in the hi–lo range) and IV percentile (share of days below today). 252 ≈ one year.")

// ── 02 · REALIZED VOLATILITY ──────────────────────────────────────────────────────────────
g1 = "02 · Realized volatility"
rvMode = input.string("Yang-Zhang", "Estimator", options = ["Yang-Zhang","Close-to-close","Parkinson","Garman-Klass"], group = g1, tooltip = "Yang-Zhang (default) is the most efficient — it uses the overnight gap, the open-to-close move and the intraday range, and is drift-independent. Close-to-close is the classic; Parkinson and Garman-Klass are range-based.")
rvLen  = input.int(20, "Realized-vol lookback (days)", minval = 5, maxval = 252, group = g1, tooltip = "Trading days over which realized volatility is measured, annualised to compare with IV.")

// ── 03 · VOLATILITY RISK PREMIUM ──────────────────────────────────────────────────────────
g2 = "03 · Volatility risk premium"
vrpDays = input.int(120, "VRP standardization window (days)", minval = 20, group = g2, tooltip = "Daily-sampled window used to standardize the IV−RV premium into a robust z-score (median / MAD). ~120 ≈ six months.")
richZ   = input.float(0.5, "Rich / cheap z threshold", minval = 0.1, step = 0.1, group = g2, tooltip = "Above +z the premium is RICH (implied dear vs realized — a premium-selling lean); below −z it is CHEAP (implied under-pricing realized).")

// ── 04 · EXPECTED MOVE & EXPIRY ───────────────────────────────────────────────────────────
g3 = "04 · Expected move & expiry"
showEM    = input.bool(true, "Draw expected-move band", group = g3)
emHorizon = input.string("1 session (1D)", "Horizon", options = ["Weekly expiry (auto)","Monthly expiry (auto)","1 session (1D)","Custom days"], group = g3, tooltip = "Days-to-expiry used in EM = price × IV × √(DTE/365). Default 1 session = the day's expected move. NSE's settlement weekday is set below; if the exchange has revised the rule, use Custom days.")
expWeekday= input.string("Thursday", "Expiry weekday (weekly / monthly)", options = ["Monday","Tuesday","Wednesday","Thursday","Friday"], group = g3, tooltip = "Weekday NSE settles the weekly expiry (and the monthly = the last such weekday of the month). Change if the exchange revises it.")
customDays= input.int(7, "Custom days to expiry", minval = 1, maxval = 400, group = g3)
emAnchor  = input.string("Day open", "Band anchor", options = ["Day open","Prior close","Current price"], group = g3, tooltip = "Price the expected-move band is centred on. Day open (default) keeps the band stable through the session.")
show2sig  = input.bool(true, "Also draw the 2σ band", group = g3)
colEM1    = input.color(#ff5252, "1σ band", inline = "emc", group = g3)
colEM2    = input.color(#b388ff, "2σ band", inline = "emc", group = g3)

// ── 05 · OPTION MODEL (Black-Scholes ATM) ─────────────────────────────────────────────────
g4o = "05 · Option model (Black-Scholes ATM)"
showBS     = input.bool(true, "Compute ATM option model", group = g4o, tooltip = "A theoretical ATM straddle from Black-Scholes given IV, DTE and the rate — for CONTEXT (what an option is 'worth' and how fast it decays), never a strike recommendation.")
rfRate     = input.float(6.5, "Risk-free rate (annual %)", minval = 0.0, step = 0.25, group = g4o, tooltip = "Annual risk-free rate for Black-Scholes. ~6.5% suits India.")
divYld     = input.float(0.0, "Dividend / carry yield (annual %)", minval = 0.0, step = 0.25, group = g4o)
strikeStep = input.float(50.0, "Strike step (ATM rounding)", minval = 0.05, step = 0.05, group = g4o, tooltip = "Option strike spacing, e.g. 50 for NIFTY. The ATM strike is the nearest multiple to spot.")

// ── 06 · ENVIRONMENT ──────────────────────────────────────────────────────────────────────
g5e = "06 · Environment"
ivHiThr   = input.int(50, "IV-rank HIGH threshold", minval = 0, maxval = 100, group = g5e, tooltip = "At/above this IV rank, options are dear — a premium-selling lean (research: IV rank >30 favours selling).")
ivLoThr   = input.int(30, "IV-rank LOW threshold", minval = 0, maxval = 100, group = g5e, tooltip = "At/below this IV rank, options are cheap — a premium-buying lean.")
trnRegSrc = input.source(close, "Trend · EXP_Regime (optional link)", group = g5e, tooltip = "Optional: link a Trend engine's EXP_Regime (+1 trend / 0 range / −1 random). If linked, a trending tape flags a DIRECTIONAL environment. Auto-skipped if left on close.")

// ── 07 · FORWARD CALIBRATION (VRP honesty stack) ──────────────────────────────────────────
g7c = "07 · Forward calibration (honesty stack)"
calibOn   = input.bool(true, "Run forward calibration", group = g7c, tooltip = "Daily-sampled: each day, did realized stay within the priced 1σ move over the horizon, and would a short ATM straddle have profited? Scored against a zone base rate with a Wilson lower bound, an out-of-sample split, a per-filter A/B and Net-R after cost.")
calH      = input.int(5, "Horizon (trading days)", minval = 1, maxval = 60, group = g7c, tooltip = "Trading days ahead each daily observation is resolved.")
calCost   = input.float(0.05, "Round-trip cost (fraction of premium)", minval = 0.0, step = 0.01, group = g7c, tooltip = "Cost per premium-selling trade as a fraction of the collected premium, subtracted from Net-R.")
oosSplit  = input.float(0.70, "In-sample fraction", minval = 0.3, maxval = 0.9, step = 0.05, group = g7c, tooltip = "The first fraction of RICH-premium observations is in-sample; the rest is out-of-sample. Only the out-of-sample edge is trusted for the verdict.")
minN      = input.int(20, "Min signal samples before judging", minval = 5, group = g7c)
tailIVpct = input.int(88, "Tail guard · IV percentile", minval = 50, maxval = 100, group = g7c, tooltip = "At/above this IV percentile — or on a realized-vol spike — the premium-selling edge historically fails in crises, so EDGE CONFIRMED is disabled and TAIL RISK is flagged.")
tailRVmult= input.float(1.6, "Tail guard · RV spike (× median)", minval = 1.0, step = 0.1, group = g7c)

// ── 08 · REAL-TAPE MODE (reads the weekly option chain) ───────────────────────────────────
g8t = "08 · Real-tape mode (reads the option chain)"
useTape    = input.bool(true, "Enable real-tape mode", group = g8t, tooltip = "ON by default. Reads the ACTUAL weekly ATM ±3 option ladder (real premium & volume) for a real straddle, IV proxy, volume PCR and pin — a live cross-check to the VIX-based reads. LIVE-ONLY: the ATM ladder is frozen at load (Pine can't mint option symbols per bar), so set the ATM below or re-add if spot drifts >2 strikes. It does not feed the calibration. Turn OFF for a pure VIX-based read.")
tapeRoot   = input.string("NSE:NIFTY", "Option root", group = g8t, tooltip = "Symbol prefix, e.g. NSE:NIFTY → NSE:NIFTY{YYMMDD}{C|P}{strike}. Set to NSE:BANKNIFTY / NSE:FINNIFTY / NSE:MIDCPNIFTY / BSE:SENSEX / BSE:BANKEX — with 'Auto strikes from root' on, the strike step and settlement weekday auto-configure for the chosen index.")
autoRoot   = input.bool(true, "Auto strikes & expiry from root", group = g8t, tooltip = "ON: detect the index from the root and set the strike step, ladder step and settlement weekday automatically (NIFTY 50 / BankNifty 100 / FinNifty 50 / MidcpNifty 25 / Sensex 100). OFF: use the manual 'Strike step', 'Ladder step' and 'Weekly expiry weekday' below.")
tapeAutoExp= input.bool(true, "Auto next-weekly expiry", group = g8t)
tapeExpDay = input.string("Tuesday", "Weekly expiry weekday", options = ["Monday","Tuesday","Wednesday","Thursday","Friday"], group = g8t, tooltip = "NIFTY weekly = Tuesday (since Sept 2025). SENSEX = Thursday. Change if the exchange revises it; holidays shift expiry earlier — use the manual date then.")
tapeEYY    = input.int(26, "Manual expiry YY", minval = 20, maxval = 99, group = g8t)
tapeEMM    = input.int(1,  "Manual expiry MM", minval = 1,  maxval = 12, group = g8t)
tapeEDD    = input.int(1,  "Manual expiry DD", minval = 1,  maxval = 31, group = g8t)
tapeATMin  = input.float(0, "ATM strike (0 = auto)", minval = 0, group = g8t, tooltip = "0 auto-anchors ATM from spot at load. Setting a value near current spot is the most robust — it pins the ladder so the strikes stay valid.")
ladderStep = input.float(100, "Ladder step (institutional strikes)", minval = 0.5, group = g8t, tooltip = "Spacing of the pin/PCR ladder legs. Default 100 samples the round institutional strikes (heaviest positioning). The ATM straddle / IV always uses the true nearest-'Strike step' ATM regardless, so the volatility read stays accurate.")
showPin    = input.bool(true, "Draw pin & ATM lines", group = g8t)

// ── 09 · CPR REFERENCE LEVELS ─────────────────────────────────────────────────────────────
g9c = "09 · CPR reference levels"
useCPR     = input.bool(true, "Show CPR reference", group = g9c, tooltip = "ON by default. Classic static CPR (Pivot / TC / BC) as a price-structure reference the expected move plays out against. A reference tool, not a signal.")
cprWeekly  = input.bool(true, "Weekly CPR", group = g9c, tooltip = "Overlay the weekly CPR — the structural frame the weekly option expiry rotates within.")
cprMonthly = input.bool(false, "Monthly CPR (positional)", group = g9c)
showFloor  = input.bool(true, "Daily floor pivots (R1-3 / S1-3)", group = g9c)
showCam    = input.bool(true, "Camarilla H3/H4 · L3/L4 (reversal / breakout)", group = g9c, tooltip = "Camarilla pivots from the prior day. H3 / L3 are the REVERSAL levels (price tends to fade back into the range from there); H4 / L4 are the BREAKOUT levels (an accepted move beyond them leans trend). Most useful on range-lean days — read alongside the CPR day-type.")
camRangeOnly = input.bool(true, "Camarilla only on range-lean days", group = g9c, tooltip = "ON (default): draw the Camarilla levels only when the CPR day-type reads wide / normal (range lean) and hide them on narrow (trend-lean) days, where fade levels are least useful. Turn OFF to always show them.")
cprNarrowThr = input.float(0.5, "Narrow-CPR threshold (× avg width)", minval = 0.1, step = 0.05, group = g9c, tooltip = "Daily CPR width below this multiple of its rolling average = NARROW (trend-day lean); above 1/threshold = WIDE (range-day lean).")
colCPR     = input.color(#7c4dff, "Daily CPR", inline = "cprc", group = g9c)
colCPRw    = input.color(#1de9b6, "Weekly / monthly CPR", inline = "cprc", group = g9c)
colPiv     = input.color(#42a5f5, "Floor pivots", inline = "cprc2", group = g9c)
colCam     = input.color(#ffa726, "Camarilla", inline = "cprc2", group = g9c)

// ── 09b · BUYER DECISION LAYER (day-type · direction · verdict) ──────────────────────────────
g9b = "09b · Buyer decision layer"
bdNarrowPct = input.float(30.0, "Narrow-CPR percentile (trend lean)", minval = 5.0, maxval = 49.0, step = 5.0, group = g9b, tooltip = "Daily CPR width at/below this percentile of its own recent history = NARROW → a trending session is the historical lean. Ranked vs this instrument, so 'narrow' means narrow FOR THIS symbol. Reuses the Engine's daily-sampled CPR-width array — no new request.")
bdWidePct   = input.float(70.0, "Wide-CPR percentile (range lean)", minval = 51.0, maxval = 95.0, step = 5.0, group = g9b, tooltip = "Daily CPR width at/above this percentile = WIDE → a rangebound session is the historical lean.")
bdTrendDef  = input.float(0.45, "A day 'trended' if |close−open| ÷ range >", minval = 0.1, maxval = 0.9, step = 0.05, group = g9b, tooltip = "Directional efficiency the day-type call is graded against in the forward test. 0.45 = the session closed at least 45% of its range away from its open, in one direction.")
bdUseIVgate = input.bool(true, "Let rich IV veto option buying", group = g9b, tooltip = "When the volatility environment is rich (IV-rank high or the VRP reads RICH), a BUY CE / BUY PE verdict is downgraded — you would be paying up for a move that may not cover the premium.")
bdUseEMgate = input.bool(true, "Require the target to cover the priced move (EM)", group = g9b, tooltip = "A BUY is withheld when the first structural target (R1 / S1) is CLOSER than the priced 1σ expected move — the Dashboard's 'SELL PREMIUM / STAY OUT' case, now enforced. Turn OFF for the day-type-only verdict.")
bdMinDte    = input.int(0, "Suppress buying inside N days of expiry", minval = 0, maxval = 5, group = g9b, tooltip = "Theta accelerates into expiry. 0 = no suppression; 1 = do not suggest buying on expiry day itself.")
bdCalMinN   = input.int(20, "Min narrow-CPR sessions before rating the day-type edge", minval = 5, group = g9b, tooltip = "The forward test needs at least this many NARROW-CPR sessions before it will call the 'narrow CPR → trend' edge proven or not.")

// ── 10 · MANUAL OI WALLS & MAX-PAIN (from your option chain) ─────────────────────────────────
g10 = "10 · Manual OI walls & max-pain"
oiOn      = input.bool(false, "Show manual OI walls & max-pain", group = g10, tooltip = "OFF by default. Per-strike open interest, OI-PCR and max-pain are NOT exposed to Pine — TradingView cannot read the option chain's OI. Enter the strikes yourself from your broker / NSE option chain: the heaviest-CE-OI strike (a resistance wall), the heaviest-PE-OI strike (a support wall), and the max-pain strike (an expiry magnet). Leave a field 0 to hide that level. Refresh the numbers as positioning shifts.")
callWall1 = input.float(0, "Call-OI wall #1 (highest CE OI) — resistance", minval = 0, group = g10)
callWall2 = input.float(0, "Call-OI wall #2 (2nd CE OI)", minval = 0, group = g10)
putWall1  = input.float(0, "Put-OI wall #1 (highest PE OI) — support", minval = 0, group = g10)
putWall2  = input.float(0, "Put-OI wall #2 (2nd PE OI)", minval = 0, group = g10)
maxPainIn = input.float(0, "Max-pain strike (expiry magnet)", minval = 0, group = g10)
colCallW  = input.color(#e53935, "Call-OI wall (resistance)", inline = "oic", group = g10)
colPutW   = input.color(#43a047, "Put-OI wall (support)", inline = "oic", group = g10)
colMaxP   = input.color(#e040fb, "Max-pain magnet", group = g10)

// ── 11 · VISUALS & THEME ──────────────────────────────────────────────────────────────────
g6 = "11 · Visuals & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
dashMode  = input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g6, tooltip = "Compact (default): a 10-line plain-language glance — the ACTION (sell premium / buy options / go with trend / wait / avoid), whether options are expensive or cheap, today's likely range, where price sits, the chance it stays in range, the magnet level, whether the edge is proven here, the day type (trend/range), the market tilt (puts/calls favored) and whether this week is event-priced. Pro shows the full technical stack (IV/RV/premium/z, greeks, calibration, forecast, tape, CPR and OI).")
panelPos  = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)
showId    = input.bool(true, "Show identity strip", group = g6, tooltip = "The small ticker/timeframe tag at the bottom. Turn OFF for the cleanest publication snapshot.")
showLevels= input.bool(true, "Draw levels (right-edge tags)", group = g6, tooltip = "Draw the EM band, CPR, floor pivots, prior-day high/low and pin as horizontal lines with a NAME + PRICE tag at the right edge.")
autoViz   = input.bool(true, "Auto visuals (show only what matters now)", group = g6, tooltip = "ON (default): declutter automatically — draw only the levels that fit the chart's SCALE (intraday timeframes show the daily CPR, floor pivots, Camarilla and pin; 1h-and-higher show the weekly/monthly CPR instead) AND that sit NEAR the current price (within ~2σ intraday, ~4σ for swing). The visible set updates as price moves and time passes. Turn OFF to draw every level all the time.")
showZones = input.bool(true, "Shade CPR zone & EM band", group = g6, tooltip = "Fill the CPR (TC–BC) zone and the ±1σ expected-move band as translucent boxes.")
tintEnv   = input.bool(true, "Tint chart by vol environment", group = g6, tooltip = "A very faint full-chart wash of the current volatility environment, so it reads at a glance without opening the panel: gold = premium-sell lean · blue = long-vol lean · green = with-trend · red = tail risk. No tint when warming / no edge. Turn off for a plain chart.")
showLegend= input.bool(true, "Show legend key", group = g6)
legendPos = input.string("Bottom right", "Legend position", options = ["Top right","Middle right","Bottom right","Top left","Bottom left"], group = g6)
colPrior  = input.color(#90a4ae, "Prior-day high / low", group = g6)
showEXP   = input.bool(true, "Publish EXP_* outputs", group = g6)
// ── Spot–futures basis (Wave D · U14 — ml_india, inlined) ──
showBasis = input.bool(true, "Read spot–futures basis", group = g6, tooltip = "Fetch the underlying SPOT and read the futures premium/discount (basis) the VIX/IV reads don't capture. (fut − spot)/spot, annualized by DTE, plus a self-calibrating premium/discount regime. Exposed on the Data Window (EXP_Basis*) and via alerts. Adds one request.security call; default on.")
spotSymIn = input.symbol("NSE:NIFTY", "Underlying spot symbol", group = g6, tooltip = "The cash index for the futures you are charting (NIFTY spot for NIFTY1!). ignore_invalid_symbol → na if the symbol is unavailable.")
richCol   = input.color(#f7c948, "Rich (premium dear)", group = g6)
cheapCol  = input.color(#5b8def, "Cheap (premium light)", group = g6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                         HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
f_chipTxt(color col) => f_lum(col) > 140 ? color.rgb(10, 10, 10) : color.white
// vibrant + background-adaptive: on a DARK chart push the hue brighter (mix toward white a touch);
// on a LIGHT chart deepen it (mix toward black) so every line/legend stays high-contrast either way.
f_vib(color c, bool dark) =>
    float r = color.r(c)
    float g = color.g(c)
    float b = color.b(c)
    float k = dark ? 0.18 : -0.42          // +brighten on dark, −deepen on light
    float rr = k >= 0 ? r + (255.0 - r) * k : r * (1.0 + k)
    float gg = k >= 0 ? g + (255.0 - g) * k : g * (1.0 + k)
    float bb = k >= 0 ? b + (255.0 - b) * k : b * (1.0 + k)
    color.rgb(int(math.max(0, math.min(255, math.round(rr)))), int(math.max(0, math.min(255, math.round(gg)))), int(math.max(0, math.min(255, math.round(bb)))))
f_2(int v) => (v < 10 ? "0" : "") + str.tostring(v, "0")
// Wilson score interval LOWER BOUND (proportion) — properly centred on (p + z²/2n)/(1+z²/n),
// not on the raw p, so the bound is genuinely conservative (the value the description advertises).
f_wlb(float w, float n, float zc) =>
    float lb = na
    if n > 0.0
        float p = w / n
        float z2 = zc * zc
        float denom = 1.0 + z2 / n
        float center = (p + z2 / (2.0 * n)) / denom
        float half = (zc * math.sqrt(p * (1.0 - p) / n + z2 / (4.0 * n * n))) / denom
        lb := center - half
    lb

// percentile rank (share of a daily-sampled array strictly below x, in %) — for the buyer layer's
// CPR width-percentile day-type. Fixed loop, no dynamic-length ta.*; na until ≥10 samples.
f_pctlt(array<float> a, float x) =>
    float out = na
    int n = array.size(a)
    if n >= 10 and not na(x)
        int cnt = 0
        for i = 0 to n - 1
            if array.get(a, i) < x
                cnt += 1
        out := cnt / float(n) * 100.0
    out

// annualised realized-vol estimators (all computed every bar; selected at the end — % units)
f_rvest(int n, string mode) =>
    float lnhl  = math.log(high / low)
    float lnco  = math.log(close / open)
    float lnoc1 = math.log(open / close[1])
    float ann   = math.sqrt(252.0)
    float cc = ta.stdev(math.log(close / close[1]), n) * ann
    float pk = math.sqrt(math.max(ta.sma(lnhl * lnhl, n) / (4.0 * math.log(2.0)), 0.0)) * ann
    float gk = math.sqrt(math.max(ta.sma(0.5 * lnhl * lnhl - (2.0 * math.log(2.0) - 1.0) * lnco * lnco, n), 0.0)) * ann
    float k  = 0.34 / (1.34 + (n + 1.0) / (n - 1.0))
    float vo = ta.variance(lnoc1, n) * n / (n - 1.0)
    float vc = ta.variance(lnco,  n) * n / (n - 1.0)
    float rs = ta.sma(math.log(high / close) * math.log(high / open) + math.log(low / close) * math.log(low / open), n)
    float yz = math.sqrt(math.max(vo + k * vc + (1.0 - k) * rs, 0.0)) * ann
    float out = mode == "Close-to-close" ? cc : mode == "Parkinson" ? pk : mode == "Garman-Klass" ? gk : yz
    out * 100.0

// robust z of x vs a daily-sampled array (median / MAD × 1.4826)
f_arrRZ(array<float> a, float x) =>
    int n = array.size(a)
    float z = 0.0
    if n >= 10 and not na(x)
        float med = array.median(a)
        array<float> dev = array.new<float>()
        for i = 0 to n - 1
            array.push(dev, math.abs(array.get(a, i) - med))
        float mad = array.median(dev) * 1.4826
        z := mad > 0 ? (x - med) / mad : 0.0
    z

// linear interpolation of a laddered value array at an arbitrary strike (strikes ASCENDING)
f_interp(array<float> ks, array<float> vs, float k) =>
    float out = na
    int n = array.size(ks)
    if n >= 2 and not na(k)
        for i = 0 to n - 2
            float k0 = array.get(ks, i)
            float k1 = array.get(ks, i + 1)
            float v0 = array.get(vs, i)
            float v1 = array.get(vs, i + 1)
            if not na(v0) and not na(v1) and k1 > k0 and k >= k0 and k <= k1
                out := v0 + (v1 - v0) * (k - k0) / (k1 - k0)
    out

// days-to-expiry helpers (calendar days)
f_dow(string d) => d == "Monday" ? 2 : d == "Tuesday" ? 3 : d == "Wednesday" ? 4 : d == "Thursday" ? 5 : d == "Friday" ? 6 : 5
f_weeklyDTE(string tz, int target) =>
    int cdow = dayofweek(time, tz)
    float((target - cdow + 7) % 7)
f_monthlyDTE(string tz, int target) =>
    int y  = year(time, tz)
    int mo = month(time, tz)
    int ny = mo == 12 ? y + 1 : y
    int nm = mo == 12 ? 1 : mo + 1
    int lastTs  = timestamp(tz, ny, nm, 1, 0, 0) - 86400000
    int lastDom = dayofmonth(lastTs, tz)
    int lastDow = dayofweek(lastTs, tz)
    int expDay  = lastDom - ((lastDow - target + 7) % 7)
    int expTs   = timestamp(tz, y, mo, expDay, 15, 30)
    float d = (expTs - time) / 86400000.0
    if d < 0
        int ny2 = nm == 12 ? ny + 1 : ny
        int nm2 = nm == 12 ? 1 : nm + 1
        int lastTs3  = timestamp(tz, ny2, nm2, 1, 0, 0) - 86400000
        int lastDom3 = dayofmonth(lastTs3, tz)
        int lastDow3 = dayofweek(lastTs3, tz)
        int expDay3  = lastDom3 - ((lastDow3 - target + 7) % 7)
        int expTs3   = timestamp(tz, ny, nm, expDay3, 15, 30)
        d := (expTs3 - time) / 86400000.0
    d

// standard normal pdf and cdf (Zelen & Severo rational approximation — Hull)
f_npdf(float x) => 0.3989422804014327 * math.exp(-x * x / 2.0)
f_ncdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float poly = t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    float p = f_npdf(x) * poly
    x >= 0 ? 1.0 - p : p

// ═════════════════════════════════════════════════════════════════════════════════════════
//        ROOT PRESET + EARLY TAPE  (auto strikes/expiry per index; tape IV for the fallback)
// ═════════════════════════════════════════════════════════════════════════════════════════
string tz = syminfo.timezone
string rootUp = str.upper(tapeRoot)
bool ixBankN = str.contains(rootUp, "BANKNIFTY")
bool ixFinN  = str.contains(rootUp, "FINNIFTY")
bool ixMidcp = str.contains(rootUp, "MIDCP")
bool ixBankx = str.contains(rootUp, "BANKEX")
bool ixSensx = str.contains(rootUp, "SENSEX")
bool ixNifty = str.contains(rootUp, "NIFTY") and not ixBankN and not ixFinN and not ixMidcp
float strikeStepEff = not autoRoot ? strikeStep : ixBankN ? 100.0 : ixFinN ? 50.0 : ixMidcp ? 25.0 : ixSensx ? 100.0 : ixBankx ? 100.0 : ixNifty ? 50.0 : strikeStep
float ladderStepEff = not autoRoot ? ladderStep : (ixBankN or ixSensx or ixBankx) ? 500.0 : ixMidcp ? 50.0 : (ixNifty or ixFinN) ? 100.0 : ladderStep
string expDayEff = not autoRoot ? tapeExpDay : ixSensx ? "Thursday" : ixBankx ? "Monday" : tapeExpDay
// next-weekly expiry date string (v6 series-symbol requests build the option tickers)
int tDowNow = dayofweek(timenow, tz)
int tTarget = expDayEff == "Monday" ? 2 : expDayEff == "Tuesday" ? 3 : expDayEff == "Wednesday" ? 4 : expDayEff == "Thursday" ? 5 : 6
int tDToExp = ((tTarget - tDowNow) % 7 + 7) % 7
int tExpTs  = timenow + tDToExp * 86400000
int txYY = tapeAutoExp ? year(tExpTs, tz) % 100 : tapeEYY
int txMM = tapeAutoExp ? month(tExpTs, tz)      : tapeEMM
int txDD = tapeAutoExp ? dayofmonth(tExpTs, tz) : tapeEDD
string tExpStr = f_2(txYY) + f_2(txMM) + f_2(txDD)
int   tMsToExp = tExpTs > timenow ? tExpTs - timenow : 0
float tYrs = math.max(tMsToExp / (1000.0 * 60 * 60 * 24 * 365.0), 1.0 / (365.0 * 24.0))
// next-weekly expiry (front + 7 days) — for the Stage 6 term-structure read
int   frontTs = tapeAutoExp ? tExpTs : timestamp(tz, 2000 + tapeEYY, tapeEMM, tapeEDD, 15, 30)
int   nextTs  = frontTs + 7 * 86400000
string tExp2Str = f_2(year(nextTs, tz) % 100) + f_2(month(nextTs, tz)) + f_2(dayofmonth(nextTs, tz))
int   t2MsToExp = nextTs > timenow ? nextTs - timenow : 0
float t2Yrs = math.max(t2MsToExp / (1000.0 * 60 * 60 * 24 * 365.0), 1.0 / (365.0 * 24.0))
// monthly expiry (last settlement-weekday of the month, rolled forward if already passed) — 3rd curve point
int myY  = year(timenow, tz)
int myMo = month(timenow, tz)
int myNy = myMo == 12 ? myY + 1 : myY
int myNm = myMo == 12 ? 1 : myMo + 1
int mLastTs = timestamp(tz, myNy, myNm, 1, 0, 0) - 86400000
int mExpDay = dayofmonth(mLastTs, tz) - ((dayofweek(mLastTs, tz) - tTarget + 7) % 7)
int mExpTs  = timestamp(tz, myY, myMo, mExpDay, 15, 30)
if mExpTs < timenow
    int m2Ny = myNm == 12 ? myNy + 1 : myNy
    int m2Nm = myNm == 12 ? 1 : myNm + 1
    int m2LastTs = timestamp(tz, m2Ny, m2Nm, 1, 0, 0) - 86400000
    int m2ExpDay = dayofmonth(m2LastTs, tz) - ((dayofweek(m2LastTs, tz) - tTarget + 7) % 7)
    mExpTs := timestamp(tz, myNy, myNm, m2ExpDay, 15, 30)
string tExpMStr = f_2(year(mExpTs, tz) % 100) + f_2(month(mExpTs, tz)) + f_2(dayofmonth(mExpTs, tz))
int   mMsToExp = mExpTs > timenow ? mExpTs - timenow : 0
float tmYrs = math.max(mMsToExp / (1000.0 * 60 * 60 * 24 * 365.0), 1.0 / (365.0 * 24.0))
// true-ATM frozen at the LAST bar (current price), not the first — else a long history anchors the
// ladder where price used to be. Option symbols must stay constant, so we set it once on the last bar;
// historical bars build an invalid strike (na) and are ignored (the tape is used only on the last bar).
var float tAtmTrueV = na
if barstate.islast and na(tAtmTrueV)
    tAtmTrueV := math.round(close / strikeStepEff) * strikeStepEff
// Manual ATM override applies on the LAST bar only — historical bars must stay na so the option
// tickers keep collapsing to the chart symbol (else a fixed strike resolves phantom option history
// that would feed IV/VRP/calibration on non-VIX IV modes).
float tAtmTrue = (tapeATMin > 0 and barstate.islast) ? math.round(tapeATMin / strikeStepEff) * strikeStepEff : tAtmTrueV
float tAtmLive = math.round(close / strikeStepEff) * strikeStepEff
float tDriftK = na(tAtmTrue) ? 0.0 : math.abs(tAtmLive - tAtmTrue) / strikeStepEff
bool tapeStale = not na(tAtmTrue) and tDriftK > 3
// true-ATM straddle pair (close only) → real straddle + IV proxy (Brenner-Subrahmanyam)
f_atm(string r, string ex, float strike) =>
    // strike is na on every HISTORICAL bar (the anchor is frozen at the last bar).
    // Requesting the chart's own symbol there adds ZERO new unique request.*()
    // calls, so history no longer accumulates phantom "…CNaN" symbols toward the
    // 40-request runtime limit (fixes RE10137 on long / back-adjusted charts).
    string cs = (useTape and not na(strike)) ? r + ex + "C" + str.tostring(strike, "0") : syminfo.tickerid
    string ps = (useTape and not na(strike)) ? r + ex + "P" + str.tostring(strike, "0") : syminfo.tickerid
    float cp = request.security(cs, timeframe.period, close, ignore_invalid_symbol = true)
    float pp = request.security(ps, timeframe.period, close, ignore_invalid_symbol = true)
    [cp, pp]
[tAtmC, tAtmP] = f_atm(tapeRoot, tExpStr, tAtmTrue)
float tapeStraddle = (not useTape or tapeStale or na(tAtmC) or na(tAtmP)) ? na : tAtmC + tAtmP
float tapeIV = (not useTape or tapeStale or na(tapeStraddle)) ? na : tapeStraddle / (0.8 * close * math.sqrt(tYrs)) * 100.0
// STAGE 6 · next-weekly ATM straddle (same true-ATM strike) → term structure vs the front week
[t2AtmC, t2AtmP] = f_atm(tapeRoot, tExp2Str, tAtmTrue)
float tape2Straddle = (not useTape or tapeStale or na(t2AtmC) or na(t2AtmP)) ? na : t2AtmC + t2AtmP
float tapeIV2 = (not useTape or na(tape2Straddle)) ? na : tape2Straddle / (0.8 * close * math.sqrt(t2Yrs)) * 100.0
// MONTHLY ATM straddle → the 3rd point on the term curve (front week / next week / monthly)
[tmAtmC, tmAtmP] = f_atm(tapeRoot, tExpMStr, tAtmTrue)
float tapeMStraddle = (not useTape or tapeStale or na(tmAtmC) or na(tmAtmP)) ? na : tmAtmC + tmAtmP
float tapeIVM = (not useTape or na(tapeMStraddle)) ? na : tapeMStraddle / (0.8 * close * math.sqrt(tmYrs)) * 100.0
// term slope = next-week IV − front-week IV. Backwardation (front dearer) = event/stress priced into
// the front week; contango (front cheaper) = the normal upward-sloping curve.
float termSlope = (not na(tapeIV) and not na(tapeIV2)) ? tapeIV2 - tapeIV : na
string termState = na(termSlope) ? "—" : termSlope < -0.5 ? "front RICH (event)" : termSlope > 0.5 ? "front cheap (normal)" : "flat"
int termSign = na(termSlope) ? 0 : termSlope < -0.5 ? -1 : termSlope > 0.5 ? 1 : 0
// monthly slope + overall curve shape across all three tenors
float monSlope = (not na(tapeIV) and not na(tapeIVM)) ? tapeIVM - tapeIV : na
string curveState = (na(tapeIV) or na(tapeIV2) or na(tapeIVM)) ? "—" : (tapeIV > tapeIV2 and tapeIV2 >= tapeIVM) ? "inverted (event)" : (tapeIVM >= tapeIV2 and tapeIV2 >= tapeIV) ? "rising (normal)" : "mixed / humped"
int curveSign = curveState == "rising (normal)" ? 1 : curveState == "inverted (event)" ? -1 : 0
// ═════════════════════════════════════════════════════════════════════════════════════════
//                          IMPLIED VOLATILITY  (source + automatic fallback)
// ═════════════════════════════════════════════════════════════════════════════════════════
string ivSym = ivSymIn
// ignore_invalid_symbol so an unavailable / blank VIX symbol returns na and falls back cleanly to the
// tape / manual IV path (per the IV-source tooltip) instead of erroring on symbol resolution.
float ivLive = request.security(ivSym, timeframe.period, close, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
[ivD, ivHi, ivLo, ivPr] = request.security(ivSym, "D", [close, ta.highest(close, ivWin), ta.lowest(close, ivWin), ta.percentrank(close, ivWin)], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float ivVix = nz(ivLive, ivD)
// resolve IV with fallback: chosen source → tape → VIX; ivSrc records what actually fed it
float ivPct = na
string ivSrc = "—"
if ivMode == "Manual IV %"
    ivPct := manualIV
    ivSrc := "manual"
else if ivMode == "Real tape (ATM straddle)"
    ivPct := not na(tapeIV) ? tapeIV : ivVix
    ivSrc := not na(tapeIV) ? "tape" : "VIX"
else if ivMode == "Auto (VIX → tape)"
    ivPct := (ixNifty and not na(ivVix)) ? ivVix : not na(tapeIV) ? tapeIV : ivVix
    ivSrc := (ixNifty and not na(ivVix)) ? "VIX" : not na(tapeIV) ? "tape" : "VIX"
else
    ivPct := not na(ivVix) ? ivVix : tapeIV
    ivSrc := not na(ivVix) ? "VIX" : "tape"
bool ivFromVix = ivSrc == "VIX"
float ivRank = (not ivFromVix or na(ivPct) or na(ivHi) or na(ivLo) or ivHi <= ivLo) ? na : math.max(0.0, math.min(100.0, (ivPct - ivLo) / (ivHi - ivLo) * 100.0))
float ivPctile = ivFromVix ? ivPr : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                     REALIZED VOLATILITY
// ═════════════════════════════════════════════════════════════════════════════════════════
// One consolidated daily request carries realized vol AND the daily OHLC bus (today's open + prior
// two sessions' H/L/C) that the EM anchor, calibration and CPR all consume — same symbol/"D"/
// lookahead, so it is one dispatch instead of two, behaviour-identical.
// pdO (prior-session OPEN) is appended to this SAME merged daily request — it rides the existing
// dispatch (one more tuple element, NOT a new request.security), and the buyer layer's day-type
// forward test grades the just-completed session from pdO / pdH / pdL / pdC.
[rvPct, dOpen, pdH, pdL, pdC, pdH2, pdL2, pdC2, pdO] = request.security(syminfo.tickerid, "D", [f_rvest(rvLen, rvMode), open, high[1], low[1], close[1], high[2], low[2], close[2], open[1]], lookahead = barmerge.lookahead_off)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          VOLATILITY RISK PREMIUM  (daily-sampled robust z)
// ═════════════════════════════════════════════════════════════════════════════════════════
float vrp = (not na(ivPct) and not na(rvPct)) ? ivPct - rvPct : na
var array<float> vrpHist = array.new<float>()
var array<float> rvHist  = array.new<float>()
bool isNewDay = timeframe.change("D")
if isNewDay
    if not na(vrp)
        array.push(vrpHist, vrp)
        if array.size(vrpHist) > vrpDays
            array.shift(vrpHist)
    if not na(rvPct)
        array.push(rvHist, rvPct)
        if array.size(rvHist) > vrpDays
            array.shift(rvHist)
var float vrpZ = 0.0
if isNewDay or barstate.islast
    vrpZ := f_arrRZ(vrpHist, vrp)   // robust-z recomputed only when the daily sample changes
string vrpState = na(vrp) ? "warming" : vrpZ > richZ ? "RICH" : vrpZ < -richZ ? "CHEAP" : "fair"
float ivRvRatio = (not na(ivPct) and not na(rvPct) and rvPct > 0) ? ivPct / rvPct : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          EXPECTED MOVE  (1σ / 2σ cones from IV × √(DTE/365))
// ═════════════════════════════════════════════════════════════════════════════════════════
// When Auto-root is on, the expected-move horizon uses the SAME auto-detected settlement weekday as
// the tape (expDayEff), so weekly/monthly DTE is right per index (e.g. NIFTY Tuesday, Sensex Thursday)
// instead of the stale manual default. Auto off → the manual EM weekday input is respected.
int emTarget = f_dow(autoRoot ? expDayEff : expWeekday)
float dteRaw = emHorizon == "Weekly expiry (auto)" ? f_weeklyDTE(tz, emTarget) : emHorizon == "Monthly expiry (auto)" ? f_monthlyDTE(tz, emTarget) : emHorizon == "1 session (1D)" ? 1.0 : float(customDays)
float dte = math.max(dteRaw, 0.1)
// dOpen / pdH / pdL / pdC / pdH2 / pdL2 / pdC2 are fetched with realized vol in one merged daily
// request in the RV section above.
float pdClose = pdC
float anchorPx = emAnchor == "Day open" ? dOpen : emAnchor == "Prior close" ? pdClose : close
float ivDec = na(ivPct) ? na : ivPct / 100.0
float em1 = (na(anchorPx) or na(ivDec) or na(dte)) ? na : anchorPx * ivDec * math.sqrt(dte / 365.0)
float emUp1 = na(em1) ? na : anchorPx + em1
float emDn1 = na(em1) ? na : anchorPx - em1
float emUp2 = na(em1) ? na : anchorPx + 2.0 * em1
float emDn2 = na(em1) ? na : anchorPx - 2.0 * em1
string emPos = na(em1) ? "-" : close > emUp2 ? "beyond +2σ" : close > emUp1 ? "above +1σ" : close < emDn2 ? "beyond −2σ" : close < emDn1 ? "below −1σ" : "inside 1σ"
// (expected-move + CPR + prior-day levels are drawn together in the unified right-edge renderer below)

// ═════════════════════════════════════════════════════════════════════════════════════════
//              CPR REFERENCE  —  classic static CPR (daily / weekly / monthly) + floor pivots
// ═════════════════════════════════════════════════════════════════════════════════════════
float dPivot  = (na(pdH) or na(pdL) or na(pdC)) ? na : (pdH + pdL + pdC) / 3.0
float dBC     = (na(pdH) or na(pdL)) ? na : (pdH + pdL) / 2.0
float dTC     = (na(dPivot) or na(dBC)) ? na : 2.0 * dPivot - dBC
float dPivot0 = (na(pdH2) or na(pdL2) or na(pdC2)) ? na : (pdH2 + pdL2 + pdC2) / 3.0
float dBC0    = (na(pdH2) or na(pdL2)) ? na : (pdH2 + pdL2) / 2.0
float dTC0    = (na(dPivot0) or na(dBC0)) ? na : 2.0 * dPivot0 - dBC0
float pR1 = na(dPivot) ? na : 2.0 * dPivot - pdL
float pS1 = na(dPivot) ? na : 2.0 * dPivot - pdH
float pR2 = na(dPivot) ? na : dPivot + (pdH - pdL)
float pS2 = na(dPivot) ? na : dPivot - (pdH - pdL)
float pR3 = na(dPivot) ? na : pdH + 2.0 * (dPivot - pdL)
float pS3 = na(dPivot) ? na : pdL - 2.0 * (pdH - dPivot)
float cprW = (na(dTC) or na(dBC)) ? na : math.abs(dTC - dBC)
// Camarilla pivots (prior-day OHLC) — H3/L3 reversal (fade), H4/L4 breakout; classic 1.1 constant
float camRange = (na(pdH) or na(pdL)) ? na : pdH - pdL
float camH4 = (na(pdC) or na(camRange)) ? na : pdC + camRange * (1.1 / 2.0)
float camH3 = (na(pdC) or na(camRange)) ? na : pdC + camRange * (1.1 / 4.0)
float camL3 = (na(pdC) or na(camRange)) ? na : pdC - camRange * (1.1 / 4.0)
float camL4 = (na(pdC) or na(camRange)) ? na : pdC - camRange * (1.1 / 2.0)
// manual OI walls & max-pain (user-entered from the option chain — 0 = not set → hidden)
float callW1 = oiOn and callWall1 > 0 ? callWall1 : na
float callW2 = oiOn and callWall2 > 0 ? callWall2 : na
float putW1  = oiOn and putWall1  > 0 ? putWall1  : na
float putW2  = oiOn and putWall2  > 0 ? putWall2  : na
float maxPain = oiOn and maxPainIn > 0 ? maxPainIn : na
float maxPainDist = (na(maxPain) or na(close)) ? na : maxPain - close
// max-pain / wall context: is spot caught between the put-wall (support) and call-wall (resistance)?
string oiZone = (na(callW1) or na(putW1) or na(close)) ? "-" : (close >= putW1 and close <= callW1) ? "pinned in OI range" : close > callW1 ? "above CE wall (breakout)" : "below PE wall (breakdown)"
[wH, wL, wC] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_off)
float wPivot = na(wH) ? na : (wH + wL + wC) / 3.0
float wBC = na(wH) ? na : (wH + wL) / 2.0
float wTC = (na(wPivot) or na(wBC)) ? na : 2.0 * wPivot - wBC
// Monthly CPR is default-OFF and only mPivot is ever drawn (mBC/mTC are unused), so the monthly
// request is made only when the toggle is on — no wasted daily dispatch on the default config.
// (An if-block, not a ternary: Pine ternaries cannot return a tuple — CE10163.)
float mH = na
float mL = na
float mC = na
if cprMonthly
    [mh_, ml_, mc_] = request.security(syminfo.tickerid, "M", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_off)
    mH := mh_
    mL := ml_
    mC := mc_
float mPivot = na(mH) ? na : (mH + mL + mC) / 3.0
float mBC = na(mH) ? na : (mH + mL) / 2.0
float mTC = (na(mPivot) or na(mBC)) ? na : 2.0 * mPivot - mBC
// daily-sampled CPR-width average → day-type
var array<float> cprWHist = array.new<float>()
if isNewDay and not na(cprW)
    array.push(cprWHist, cprW)
    if array.size(cprWHist) > vrpDays
        array.shift(cprWHist)
var float cprWAvg = na
if isNewDay or barstate.islast
    cprWAvg := array.size(cprWHist) >= 10 ? array.median(cprWHist) : na   // median recomputed only when the daily sample changes
string cprType = (na(cprW) or na(cprWAvg) or cprWAvg <= 0) ? "warming" : cprW < cprNarrowThr * cprWAvg ? "narrow" : cprW > (1.0 / cprNarrowThr) * cprWAvg ? "wide" : "normal"
// order the TC/BC pair (TC can sit below BC when the prior close is in the lower half of the range)
float dHi  = (na(dTC) or na(dBC)) ? na : math.max(dTC, dBC)
float dLo  = (na(dTC) or na(dBC)) ? na : math.min(dTC, dBC)
float dHi0 = (na(dTC0) or na(dBC0)) ? na : math.max(dTC0, dBC0)
float dLo0 = (na(dTC0) or na(dBC0)) ? na : math.min(dTC0, dBC0)
string cpr2day = (na(dHi) or na(dLo) or na(dHi0) or na(dLo0)) ? "-" : dLo > dHi0 ? "higher value" : dHi < dLo0 ? "lower value" : (dHi <= dHi0 and dLo >= dLo0) ? "inside" : "overlapping"
string emVsCPR = (na(emUp1) or na(dTC) or na(dBC)) ? "-" : (emUp1 > dTC and emDn1 < dBC) ? "1σ clears CPR (trend priced)" : (emUp1 <= dTC and emDn1 >= dBC) ? "1σ inside CPR (range priced)" : "1σ one-sided"
int cprDayTypeN = cprType == "narrow" ? 1 : cprType == "wide" ? -1 : 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                        BLACK-SCHOLES ATM MODEL  (theoretical straddle, greeks)
// ═════════════════════════════════════════════════════════════════════════════════════════
float bsS  = close
float atmK = (na(bsS) or strikeStepEff <= 0) ? na : math.round(bsS / strikeStepEff) * strikeStepEff
float bsT  = dte / 365.0
float sig  = na(ivDec) ? na : ivDec
float r    = rfRate / 100.0
float q    = divYld / 100.0
bool bsOK  = showBS and not na(atmK) and atmK > 0 and not na(sig) and sig > 0 and bsT > 0
float atmStraddle = na
float atmThetaDay = na
float atmVega = na
float atmGamma = na
float beUp = na
float beDn = na
float probInEM = na
float probInBE = na
float probTouch1 = na
if bsOK
    float sqrtT = math.sqrt(bsT)
    float d1 = (math.log(bsS / atmK) + (r - q + 0.5 * sig * sig) * bsT) / (sig * sqrtT)
    float d2 = d1 - sig * sqrtT
    float nd1 = f_npdf(d1)
    float Nd1 = f_ncdf(d1)
    float Nd2 = f_ncdf(d2)
    float Nnd1 = f_ncdf(-d1)
    float Nnd2 = f_ncdf(-d2)
    float disc_r = math.exp(-r * bsT)
    float disc_q = math.exp(-q * bsT)
    float call = bsS * disc_q * Nd1 - atmK * disc_r * Nd2
    float put  = atmK * disc_r * Nnd2 - bsS * disc_q * Nnd1
    atmStraddle := call + put
    float thetaC = -(bsS * disc_q * nd1 * sig) / (2.0 * sqrtT) - r * atmK * disc_r * Nd2 + q * bsS * disc_q * Nd1
    float thetaP = -(bsS * disc_q * nd1 * sig) / (2.0 * sqrtT) + r * atmK * disc_r * Nnd2 - q * bsS * disc_q * Nnd1
    atmThetaDay := (thetaC + thetaP) / 365.0
    atmVega := bsS * disc_q * nd1 * sqrtT / 100.0
    atmGamma := disc_q * nd1 / (bsS * sig * sqrtT)
    beUp := atmK + atmStraddle
    beDn := atmK - atmStraddle
    // terminal (expiry) probabilities under the risk-neutral lognormal: P(S_T < L) = N(-d2_L)
    float drift = (r - q - 0.5 * sig * sig) * bsT
    float den = sig * sqrtT
    if not na(emUp1) and not na(emDn1) and emUp1 > 0 and emDn1 > 0
        float d2emU = (math.log(bsS / emUp1) + drift) / den
        float d2emD = (math.log(bsS / emDn1) + drift) / den
        probInEM := math.max(0.0, math.min(100.0, (f_ncdf(-d2emU) - f_ncdf(-d2emD)) * 100.0))
        probTouch1 := math.max(0.0, math.min(100.0, 2.0 * f_ncdf(d2emU) * 100.0))   // ≈ P(touch +1σ before expiry)
    if not na(beUp) and not na(beDn) and beDn > 0
        float d2beU = (math.log(bsS / beUp) + drift) / den
        float d2beD = (math.log(bsS / beDn) + drift) / den
        probInBE := math.max(0.0, math.min(100.0, (f_ncdf(-d2beU) - f_ncdf(-d2beD)) * 100.0))
float straddlePctS = (not na(atmStraddle) and not na(bsS) and bsS > 0) ? atmStraddle / bsS * 100.0 : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                    ENVIRONMENT CLASSIFIER  (context — never a trade call)
// ═════════════════════════════════════════════════════════════════════════════════════════
bool trnLinked = not na(trnRegSrc) and trnRegSrc >= -1.5 and trnRegSrc <= 1.5 and trnRegSrc != close
int  trnRegV = trnLinked ? int(math.round(trnRegSrc)) : na
bool ivHigh = not na(ivRank) and ivRank >= ivHiThr
bool ivLow  = not na(ivRank) and ivRank <= ivLoThr
bool rich = vrpState == "RICH"
bool cheap = vrpState == "CHEAP"
bool trending = trnLinked and trnRegV == 1
string env = na(vrp) ? "warming" : trending ? "DIRECTIONAL" : (rich or ivHigh) and not cheap ? "PREMIUM-SELL" : (cheap or ivLow) and not rich ? "PREMIUM-BUY" : "NEUTRAL"
string envCtx = env == "DIRECTIONAL" ? "Trending tape — with-move / long-premium context" : env == "PREMIUM-SELL" ? "IV dear vs realized — theta / premium-selling context" : env == "PREMIUM-BUY" ? "IV cheap vs realized — long-vol / debit context" : env == "NEUTRAL" ? "No vol edge — wait for IV or a trend" : "gathering data"
int envSign = env == "PREMIUM-SELL" ? 2 : env == "PREMIUM-BUY" ? -2 : env == "DIRECTIONAL" ? 1 : 0
// structure × vol confluence: CPR day-type agreeing with the vol environment
bool structAgree = na(vrp) ? false : (cprType == "narrow" and (env == "DIRECTIONAL" or env == "PREMIUM-BUY")) or (cprType == "wide" and env == "PREMIUM-SELL")
string structTxt = (na(vrp) or cprType == "warming") ? "warming" : structAgree ? "structure agrees" : "structure diverges"

// ═════════════════════════════════════════════════════════════════════════════════════════
//              HONESTY STACK  —  daily-sampled VRP forward calibration + tail guard
// ═════════════════════════════════════════════════════════════════════════════════════════
// pending forward observations (FIFO — one per trading day, resolved calH days later)
var int dayN = 0
var array<float> penRef  = array.new<float>()
var array<float> penEM   = array.new<float>()
var array<int>   penDay  = array.new<int>()
var array<int>   penRich = array.new<int>()
var array<int>   penIVHi = array.new<int>()
// resolved outcomes are accumulated incrementally (O(1) per resolve) so the roll-up never rescans
// the full record set every bar. richSeq keeps only the RICH-day win sequence, for the OOS split.
var float accBaseW = 0.0
var float accBaseN = 0.0
var float accRichW = 0.0
var float accRichN = 0.0
var float accRichR = 0.0
var float accIVHiW = 0.0
var float accIVHiN = 0.0
var array<int> richSeq = array.new<int>()

if calibOn and isNewDay
    dayN += 1
    // resolve matured observations from the front (FIFO) — fold each straight into the accumulators
    while array.size(penDay) > 0 and dayN - array.get(penDay, 0) >= calH
        float ref = array.shift(penRef)
        float emh = array.shift(penEM)
        int   pdd = array.shift(penDay)
        int   rc  = array.shift(penRich)
        int   ih  = array.shift(penIVHi)
        float mv = (not na(pdClose) and not na(ref)) ? math.abs(pdClose - ref) : na
        if not na(mv) and not na(emh) and emh > 0
            float straddleH = 0.7979 * emh
            int   win = mv <= emh ? 1 : 0
            float rr  = straddleH > 0 ? (straddleH - mv) / straddleH : 0.0
            accBaseW += win
            accBaseN += 1.0
            if rc == 1
                accRichW += win
                accRichN += 1.0
                accRichR += rr
                array.push(richSeq, win)
            if ih == 1
                accIVHiW += win
                accIVHiN += 1.0
    // push today's observation (anchored on the confirmed prior daily close)
    float emh0 = (not na(pdClose) and not na(ivDec)) ? pdClose * ivDec * math.sqrt(calH / 365.0) : na
    if not na(emh0)
        array.push(penRef, pdClose)
        array.push(penEM, emh0)
        array.push(penDay, dayN)
        array.push(penRich, rich ? 1 : 0)
        array.push(penIVHi, ivHigh ? 1 : 0)

// roll up the resolved records — recomputed only when records change (daily) or on the last bar,
// then persisted via var, so the O(n) scans never run on every historical intraday bar.
var float baseRate = na
var float richRate = na
var float vrpEdge = na
var float ivHiEdge = na
var float netR = na
var float oosEdge = na
var float oosEdgeLB = na
var float richN = 0.0
var float roosN = 0.0
var int   nCv = 0
var float rvMed = na
var float rvPersist = na
var bool  tailFlag = false
var int   tier = 0
var string verdict = "… LEARNING"
if isNewDay or barstate.islast
    nCv := int(accBaseN)
    baseRate := accBaseN > 0 ? accBaseW / accBaseN * 100.0 : na
    richRate := accRichN > 0 ? accRichW / accRichN * 100.0 : na
    richN := accRichN
    vrpEdge := (not na(richRate) and not na(baseRate)) ? richRate - baseRate : na
    float ivhiRate = accIVHiN > 0 ? accIVHiW / accIVHiN * 100.0 : na
    ivHiEdge := (not na(ivhiRate) and not na(baseRate)) ? ivhiRate - baseRate : na
    netR := accRichN > 0 ? accRichR / accRichN - calCost : na
    // out-of-sample: the last (1−oosSplit) fraction of the RICH-day win sequence (small tail scan)
    float roW = 0.0
    float roN = 0.0
    int rsz = array.size(richSeq)
    if rsz > 0
        int cut = int(math.floor(rsz * oosSplit))
        for i = cut to rsz - 1
            roW += array.get(richSeq, i)
            roN += 1.0
    roosN := roN
    float oosRate = roN > 0 ? roW / roN * 100.0 : na
    float oosLB = f_wlb(roW, roN, 1.96) * 100.0
    oosEdge := (not na(oosRate) and not na(baseRate)) ? oosRate - baseRate : na
    oosEdgeLB := (not na(oosLB) and not na(baseRate)) ? oosLB - baseRate : na
    rvMed := array.size(rvHist) >= 10 ? array.median(rvHist) : na
    // AR(1) persistence of daily RV (lag-1 autocorrelation) — drives the mean-reverting RV forecast
    int nR = array.size(rvHist)
    if nR >= 15
        int m = nR - 1
        float mx = 0.0
        float my = 0.0
        for i = 1 to nR - 1
            mx += array.get(rvHist, i)
            my += array.get(rvHist, i - 1)
        mx := mx / m
        my := my / m
        float sxy = 0.0
        float sxx = 0.0
        float syy = 0.0
        for i = 1 to nR - 1
            float dx = array.get(rvHist, i) - mx
            float dy = array.get(rvHist, i - 1) - my
            sxy += dx * dy
            sxx += dx * dx
            syy += dy * dy
        rvPersist := (sxx > 0 and syy > 0) ? sxy / math.sqrt(sxx * syy) : na
    tailFlag := (not na(ivPctile) and ivPctile >= tailIVpct) or (not na(rvMed) and not na(rvPct) and rvPct > tailRVmult * rvMed)
    tier := not calibOn ? 0 : roN < minN ? 0 : (not na(oosEdgeLB) and oosEdgeLB > 0 and not na(netR) and netR > 0 and not tailFlag) ? 3 : (not na(oosEdge) and oosEdge < 0) ? 1 : 2
    verdict := tier == 3 ? "✓ EDGE CONFIRMED" : tier == 1 ? "✗ NO EDGE HERE" : tier == 2 ? "• UNPROVEN" : "… LEARNING"

// ── STAGE 5 · FORWARD RV FORECAST (HAR / AR(1) mean reversion) → forward-looking VRP ────────
// Sellers care about IV vs EXPECTED-FUTURE realized vol, not trailing RV. Current RV reverts to its
// long-run level (rvMed) over the option horizon at the data-estimated persistence φ (lag-1 auto-
// correlation of daily RV). The horizon-average forecast is the AR(1) mean of E[RV_{t+k}] over k=1..H.
// Compute-only — no request.security, no calibration change; it just re-reads the premium forward.
int   Hf  = int(math.max(1.0, math.round(dte)))
float phi = na(rvPersist) ? na : math.max(0.0, math.min(0.999, rvPersist))
float rvFcast = na
if not na(phi) and not na(rvMed) and not na(rvPct)
    float avgDecay = phi >= 0.999 ? 1.0 : phi <= 0.0 ? 0.0 : phi * (1.0 - math.pow(phi, Hf)) / (Hf * (1.0 - phi))
    rvFcast := rvMed + (rvPct - rvMed) * avgDecay
float vrpFwd = (not na(ivPct) and not na(rvFcast)) ? ivPct - rvFcast : na
string rvTrend = (na(rvFcast) or na(rvPct)) ? "-" : rvFcast > rvPct * 1.03 ? "rising" : rvFcast < rvPct * 0.97 ? "falling" : "stable"
string vrpFwdState = na(vrpFwd) ? "warming" : vrpFwd > 0 ? "RICH fwd" : "CHEAP fwd"

// ═════════════════════════════════════════════════════════════════════════════════════════
//        REAL-TAPE MODE  —  round-strike pin / PCR ladder (straddle & IV computed earlier)
// ═════════════════════════════════════════════════════════════════════════════════════════
// ladder anchor frozen at the LAST bar (nearest ladderStepEff round institutional strike)
var float tAtmV = na
if barstate.islast and na(tAtmV)
    tAtmV := math.round(close / ladderStepEff) * ladderStepEff
float tAtm = (tapeATMin > 0 and barstate.islast) ? math.round(tapeATMin / ladderStepEff) * ladderStepEff : tAtmV
// na-safe leg fetch (invalid / illiquid strikes return na and are ignored). Each symbol's price and
// volume are pulled in ONE tuple request (2 per strike, not 4) to stay well under the 40-request limit.
f_leg(string r, string ex, float strike) =>
    // na strike on historical bars -> request the chart symbol (no new unique
    // request), so only the last bar's real strikes count. Fixes RE10137.
    string cs = (useTape and not na(strike)) ? r + ex + "C" + str.tostring(strike, "0") : syminfo.tickerid
    string ps = (useTape and not na(strike)) ? r + ex + "P" + str.tostring(strike, "0") : syminfo.tickerid
    [cp, cv] = request.security(cs, timeframe.period, [close, volume], ignore_invalid_symbol = true)
    [pp, pv] = request.security(ps, timeframe.period, [close, volume], ignore_invalid_symbol = true)
    [cp, cv, pp, pv]
[tcm5P, tcm5V, tpm5P, tpm5V] = f_leg(tapeRoot, tExpStr, tAtm - 5 * ladderStepEff)
[tcm4P, tcm4V, tpm4P, tpm4V] = f_leg(tapeRoot, tExpStr, tAtm - 4 * ladderStepEff)
[tcm3P, tcm3V, tpm3P, tpm3V] = f_leg(tapeRoot, tExpStr, tAtm - 3 * ladderStepEff)
[tcm2P, tcm2V, tpm2P, tpm2V] = f_leg(tapeRoot, tExpStr, tAtm - 2 * ladderStepEff)
[tcm1P, tcm1V, tpm1P, tpm1V] = f_leg(tapeRoot, tExpStr, tAtm - 1 * ladderStepEff)
[tc0P,  tc0V,  tp0P,  tp0V ] = f_leg(tapeRoot, tExpStr, tAtm)
[tcp1P, tcp1V, tpp1P, tpp1V] = f_leg(tapeRoot, tExpStr, tAtm + 1 * ladderStepEff)
[tcp2P, tcp2V, tpp2P, tpp2V] = f_leg(tapeRoot, tExpStr, tAtm + 2 * ladderStepEff)
[tcp3P, tcp3V, tpp3P, tpp3V] = f_leg(tapeRoot, tExpStr, tAtm + 3 * ladderStepEff)
[tcp4P, tcp4V, tpp4P, tpp4V] = f_leg(tapeRoot, tExpStr, tAtm + 4 * ladderStepEff)
[tcp5P, tcp5V, tpp5P, tpp5V] = f_leg(tapeRoot, tExpStr, tAtm + 5 * ladderStepEff)
f_live(float x) => na(x) ? 0 : 1
int tLegs = f_live(tcm5P)+f_live(tcm4P)+f_live(tcm3P)+f_live(tcm2P)+f_live(tcm1P)+f_live(tc0P)+f_live(tcp1P)+f_live(tcp2P)+f_live(tcp3P)+f_live(tcp4P)+f_live(tcp5P) + f_live(tpm5P)+f_live(tpm4P)+f_live(tpm3P)+f_live(tpm2P)+f_live(tpm1P)+f_live(tp0P)+f_live(tpp1P)+f_live(tpp2P)+f_live(tpp3P)+f_live(tpp4P)+f_live(tpp5P)
float tSumCE = nz(tcm5V)+nz(tcm4V)+nz(tcm3V)+nz(tcm2V)+nz(tcm1V)+nz(tc0V)+nz(tcp1V)+nz(tcp2V)+nz(tcp3V)+nz(tcp4V)+nz(tcp5V)
float tSumPE = nz(tpm5V)+nz(tpm4V)+nz(tpm3V)+nz(tpm2V)+nz(tpm1V)+nz(tp0V)+nz(tpp1V)+nz(tpp2V)+nz(tpp3V)+nz(tpp4V)+nz(tpp5V)
float tapePCR = (tapeStale or tSumCE <= 0) ? na : tSumPE / tSumCE
// pin = strike with the greatest total (CE+PE) volume
var float tapePin = na
if barstate.islast and useTape and not tapeStale
    float best = -1.0
    float bk = tAtm
    float tv = nz(tcm5V) + nz(tpm5V)
    if tv > best
        best := tv
        bk := tAtm - 5 * ladderStepEff
    tv := nz(tcm4V) + nz(tpm4V)
    if tv > best
        best := tv
        bk := tAtm - 4 * ladderStepEff
    tv := nz(tcm3V) + nz(tpm3V)
    if tv > best
        best := tv
        bk := tAtm - 3 * ladderStepEff
    tv := nz(tcm2V) + nz(tpm2V)
    if tv > best
        best := tv
        bk := tAtm - 2 * ladderStepEff
    tv := nz(tcm1V) + nz(tpm1V)
    if tv > best
        best := tv
        bk := tAtm - 1 * ladderStepEff
    tv := nz(tc0V) + nz(tp0V)
    if tv > best
        best := tv
        bk := tAtm
    tv := nz(tcp1V) + nz(tpp1V)
    if tv > best
        best := tv
        bk := tAtm + 1 * ladderStepEff
    tv := nz(tcp2V) + nz(tpp2V)
    if tv > best
        best := tv
        bk := tAtm + 2 * ladderStepEff
    tv := nz(tcp3V) + nz(tpp3V)
    if tv > best
        best := tv
        bk := tAtm + 3 * ladderStepEff
    tv := nz(tcp4V) + nz(tpp4V)
    if tv > best
        best := tv
        bk := tAtm + 4 * ladderStepEff
    tv := nz(tcp5V) + nz(tpp5V)
    if tv > best
        best := tv
        bk := tAtm + 5 * ladderStepEff
    tapePin := best > 0 ? bk : na
// (pin is drawn in the unified right-edge renderer below)

// ── STAGE 2 · SKEW (spot-symmetric risk-reversal from the tape ladder) ─────────────────────
// The wing tilt: an OTM PUT vs the EQUIDISTANT-FROM-SPOT OTM CALL, read off the ladder legs
// already fetched — no extra request.security. Because spot rarely sits exactly on a round
// strike, each wing is INTERPOLATED to a strike an equal distance (2 ladder steps) either side of
// spot, so the read is a true moneyness-matched risk-reversal rather than the raw ±k legs (which
// bias whenever spot drifts off the ladder ATM). PUT-RICH = downside fear, CALL-RICH = upside chase.
var float tapeSkew = na
if barstate.islast and useTape and not tapeStale
    array<float> lk = array.from(tAtm - 5.0 * ladderStepEff, tAtm - 4.0 * ladderStepEff, tAtm - 3.0 * ladderStepEff, tAtm - 2.0 * ladderStepEff, tAtm - 1.0 * ladderStepEff, tAtm, tAtm + 1.0 * ladderStepEff, tAtm + 2.0 * ladderStepEff, tAtm + 3.0 * ladderStepEff, tAtm + 4.0 * ladderStepEff, tAtm + 5.0 * ladderStepEff)
    array<float> lp = array.from(tpm5P, tpm4P, tpm3P, tpm2P, tpm1P, tp0P, tpp1P, tpp2P, tpp3P, tpp4P, tpp5P)
    array<float> lc = array.from(tcm5P, tcm4P, tcm3P, tcm2P, tcm1P, tc0P, tcp1P, tcp2P, tcp3P, tcp4P, tcp5P)
    float wing = 2.0 * ladderStepEff
    float pWing = f_interp(lk, lp, close - wing)   // OTM put, 2 steps below spot
    float cWing = f_interp(lk, lc, close + wing)   // OTM call, 2 steps above spot
    if na(pWing) or na(cWing)                        // fall back to the 1-step wings if a 2-step leg is dead
        pWing := f_interp(lk, lp, close - ladderStepEff)
        cWing := f_interp(lk, lc, close + ladderStepEff)
    tapeSkew := (not na(pWing) and not na(cWing) and pWing > 0 and cWing > 0) ? (pWing - cWing) / ((pWing + cWing) / 2.0) * 100.0 : na
string skewState = na(tapeSkew) ? "—" : tapeSkew > 10 ? "put-rich" : tapeSkew < -10 ? "call-rich" : "balanced"
int skewSign = na(tapeSkew) ? 0 : tapeSkew > 10 ? -1 : tapeSkew < -10 ? 1 : 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//              BUYER DECISION LAYER  —  day-type · direction · EM-vs-target · verdict
//   Ported from the Options Decision Dashboard onto the Engine's already-computed series (CPR,
//   floor pivots, expected move, IV / VRP / environment, DTE). Adds NO request.security: the CPR
//   width-percentile reuses the Engine's daily-sampled cprWHist array, and the forward test reuses
//   the honesty-stack daily cadence (isNewDay) and the prior-session OPEN (pdO) from the daily bus.
//   Only strings / ints / bools are computed here (theme colours are not yet defined); the verdict
//   colour is resolved at render time.
// ═════════════════════════════════════════════════════════════════════════════════════════
bool bdIntraOK = timeframe.isintraday
// (1) CPR WIDTH-PERCENTILE DAY-TYPE — narrow width %ile → trend expected, wide → range, ranked
//     against the instrument's own recent daily widths (the Engine's cprWHist, one sample / session).
var float bdWidthPct = na
if isNewDay or barstate.islast
    bdWidthPct := f_pctlt(cprWHist, cprW)              // recomputed only when the daily sample changes
int    bdDayTypeN = na(bdWidthPct) ? 0 : bdWidthPct <= bdNarrowPct ? 1 : bdWidthPct >= bdWidePct ? -1 : 0
string bdDayWord  = bdDayTypeN == 1 ? "narrow→trend" : bdDayTypeN == -1 ? "wide→range" : "neutral"
// (2) DIRECTION — price vs the Engine's ordered CPR top/bottom (dHi/dLo); two-day CPR (cpr2day) as
//     the Pivot-Boss directional prior.
int    bdBias    = (na(dHi) or na(dLo)) ? 0 : close > dHi ? 1 : close < dLo ? -1 : 0
string bdBiasTxt = bdBias == 1 ? "ABOVE CPR (bull)" : bdBias == -1 ? "BELOW CPR (bear)" : "INSIDE CPR"
int    bdRelBias = str.contains(cpr2day, "higher") ? 1 : str.contains(cpr2day, "lower") ? -1 : 0
// (3) DAY-TYPE FORWARD TEST — the core claim "narrow CPR → trend day" measured on THIS instrument.
//     Reuses the honesty-stack daily cadence (isNewDay, confirmed bars only), NO new request. Each
//     session's day-type call is captured at its open and graded at the next open on the settled
//     prior daily O/H/L/C. A session "trended" when |close−open| ÷ range > bdTrendDef.
var int bdPendType = na
var int bdNarrowN  = 0
var int bdNarrowW  = 0
var int bdBaseN    = 0
var int bdBaseW    = 0
if isNewDay and barstate.isconfirmed
    if calibOn and not na(bdPendType) and not na(pdO) and not na(pdH) and not na(pdL) and not na(pdC) and pdH > pdL
        float bdEff = math.abs(pdC - pdO) / (pdH - pdL)
        bool  bdTrd = bdEff > bdTrendDef
        bdBaseN += 1
        bdBaseW += bdTrd ? 1 : 0
        if bdPendType == 1
            bdNarrowN += 1
            bdNarrowW += bdTrd ? 1 : 0
    bdPendType := bdDayTypeN                            // capture today's call, grade it next session
float bdNarrowHit = bdNarrowN > 0 ? bdNarrowW / float(bdNarrowN) * 100.0 : na
float bdBaseHit   = bdBaseN   > 0 ? bdBaseW   / float(bdBaseN)   * 100.0 : na
float bdEdge      = (na(bdNarrowHit) or na(bdBaseHit)) ? na : bdNarrowHit - bdBaseHit
float bdWLo       = f_wlb(bdNarrowW, bdNarrowN, 1.96)   // Wilson 95% lower bound on the narrow-CPR hit rate
bool  bdProven    = not na(bdWLo) and not na(bdBaseHit) and bdNarrowN >= bdCalMinN and (bdWLo * 100.0) > bdBaseHit
// (4) EM-vs-CPR-TARGET GATE — the buyer pays ≈ the priced 1σ move (em1). If the first structural
//     target (R1/S1) is closer than that, even hitting the target may not cover the premium.
float bdTgt1    = bdBias == 1 ? pR1 : bdBias == -1 ? pS1 : na
float bdInval   = bdBias == 1 ? dLo : bdBias == -1 ? dHi : na
float bdCprMove = (not na(bdTgt1) and not na(dOpen)) ? math.abs(bdTgt1 - dOpen) : na
bool  bdEmCoversTgt = (not bdUseEMgate) or na(em1) or na(bdCprMove) or bdCprMove >= em1
// (5) VERDICT — the two axes feed ONE call: STRUCTURE (day-type + direction + the EM-vs-target gate)
//     × VOLATILITY (the Engine's IV richness / VRP: bdIVexp = VRP RICH or IV-rank high). Keeps the
//     Dashboard's "priced move > target → SELL PREMIUM / STAY OUT" gate and the DTE/theta suppression.
bool bdIVexp      = rich or ivHigh
bool bdTrendDay   = bdDayTypeN == 1
bool bdRangeDay   = bdDayTypeN == -1
bool bdDirOK      = bdBias != 0
bool bdNearExpiry = dte < bdMinDte
string bdVerdict = "STAY OUT"
int    bdVCode   = 0
if not bdIntraOK
    bdVerdict := "USE AN INTRADAY CHART"
    bdVCode := 0
else if na(vrp) or cprType == "warming" or na(bdWidthPct)
    bdVerdict := "WARMING UP"
    bdVCode := 0
else if bdRangeDay or (not bdDirOK and not bdTrendDay)
    bdVerdict := bdIVexp ? "SELL PREMIUM (range + rich IV)" : "STAY OUT — range day"
    bdVCode := bdIVexp ? 2 : 0
else if bdTrendDay and bdDirOK and not (bdUseIVgate and bdIVexp) and not bdNearExpiry and bdEmCoversTgt
    bdVerdict := bdBias == 1 ? "BUY CE" : "BUY PE"
    bdVCode := bdBias == 1 ? 1 : -1
else if bdTrendDay and bdDirOK and not (bdUseIVgate and bdIVexp) and not bdNearExpiry and not bdEmCoversTgt
    bdVerdict := "SELL PREMIUM — priced move > target"
    bdVCode := 2
else if bdTrendDay and bdDirOK and bdUseIVgate and bdIVexp
    bdVerdict := "WAIT — IV too rich to buy"
    bdVCode := 0
else if bdNearExpiry
    bdVerdict := "STAY OUT — theta (expiry)"
    bdVCode := 0
else
    bdVerdict := bdDirOK ? (bdBias == 1 ? "Lean CE — weak day type" : "Lean PE — weak day type") : "STAY OUT — no direction"
    bdVCode := 0
// (6) UNIFY — one headline object: the DECISION (the buyer verdict, tail-guarded) plus a WHY that
//     cites BOTH the structure axis (CPR day-type) and the volatility axis (the Engine's environment).
string bdDtWord  = bdDayTypeN == 1 ? "narrow CPR → trend day" : bdDayTypeN == -1 ? "wide CPR → range day" : "neutral CPR"
string bdEnvWord = na(vrp) ? "vol warming" : env == "PREMIUM-SELL" ? "IV rich (premium-sell lean)" : env == "PREMIUM-BUY" ? "IV cheap (long-vol lean)" : env == "DIRECTIONAL" ? "trending tape (with-move lean)" : "no vol edge"
string uniWhy    = bdDtWord + " + " + bdEnvWord

// ═════════════════════════════════════════════════════════════════════════════════════════
//   OPTION-BUYER RISK GUARD  (Wave E · ml_india v2 buyer-protection layer, inlined)
//   ADDITIVE & NON-DESTRUCTIVE: the buyer verdict above (bdVerdict / bdVCode) is UNCHANGED.
//   Option BUYERS bleed in specific ways this reads: an overnight gap that has already spent the
//   day's priced move (IV-crush / mean-reversion risk on fresh long premium), a directional-looking
//   push that is really a fade on a range day (false-momentum trap), and theta bite into expiry.
//   It returns a safe-to-buy gate (optionBuyOk) + a 0..1 quality multiplier that DOWN-WEIGHTS a BUY
//   under adverse conditions. It NEVER turns a non-buy into a buy — protection only.
// ═════════════════════════════════════════════════════════════════════════════════════════
gBuyGuard  = "09c · Option-buyer risk guard (Wave E)"
bgOn       = input.bool(true,  "Option-buyer risk guard", group = gBuyGuard, tooltip = "Reads the ways a long-option position bleeds — gap-shock IV crush, false-momentum traps, theta into expiry — and reports a safe-to-buy gate + a 0..1 quality multiplier. Additive: it never changes the buyer verdict, only annotates a BUY with how safe it is to act on. Default on.")
bgGapThr   = input.float(0.80, "Gap-shock: overnight gap ≥ × expected move", minval = 0.2, maxval = 2.0, step = 0.05, group = gBuyGuard, tooltip = "When today's open gapped by at least this fraction of the priced 1σ move, a fresh long option faces IV crush + mean-reversion — much of the move may already be spent.")
bgThetaDte = input.float(1.0,  "Theta danger: DTE ≤ (days)", minval = 0.0, maxval = 3.0, step = 0.5, group = gBuyGuard, tooltip = "At or below this many days to expiry, theta accelerates and exit liquidity thins — buying premium here is flagged as caution.")
// (a) GAP-SHOCK — today's open gapped by a large fraction of the priced 1σ move.
float bgGapPts   = (not na(dOpen) and not na(pdC)) ? dOpen - pdC : na
float bgGapShock = (not na(bgGapPts) and not na(em1) and em1 > 0.0) ? math.abs(bgGapPts) / em1 : na
bool  bgGapFlag  = bgOn and not na(bgGapShock) and bgGapShock >= bgGapThr
// (b) FALSE-MOMENTUM TRAP — price already stretched beyond the 1σ EM band while the day-type reads
//     RANGE (wide CPR): a directional-looking push likely to revert, trapping a fresh buyer.
bool  bgStretched = (not na(emUp1) and close >= emUp1) or (not na(emDn1) and close <= emDn1)
bool  bgFalseMom  = bgOn and bdRangeDay and bgStretched
// (c) THETA / LIQUIDITY VOID — into expiry theta accelerates and exit liquidity thins.
bool  bgThetaDanger = bgOn and not na(dte) and dte <= bgThetaDte
float bgThetaFrac   = (not na(atmThetaDay) and not na(atmStraddle) and atmStraddle > 0.0) ? math.abs(atmThetaDay) / atmStraddle : na
// (d) OPTION-BUY-OK gate — safe to BUY premium only when no buyer-bleed condition and no tail regime.
bool  optionBuyOk = bgOn and not bgGapFlag and not bgFalseMom and not bgThetaDanger and not tailFlag
// (e) OPTION-QUALITY multiplier ∈ [0,1] — down-weights a BUY under adverse conditions (protection).
float bgGapPen = not na(bgGapShock) ? math.min(0.40, bgGapShock / math.max(bgGapThr, 0.1) * 0.40) : 0.0
float bgThetaRamp = (not na(dte) and dte < 3.0 and dte > bgThetaDte) ? (3.0 - dte) * 0.05 : 0.0
float bgQ = 1.0 - bgGapPen - (bgFalseMom ? 0.30 : 0.0) - (bgThetaDanger ? 0.30 : 0.0) - bgThetaRamp - (tailFlag ? 0.30 : 0.0) - ((rich or ivHigh) ? 0.10 : 0.0)
float optionQualityMult = bgOn ? math.max(0.0, math.min(1.0, bgQ)) : na
// (f) dominant risk reason + guarded read (only meaningful when the verdict is a BUY).
string bgReason  = not bgOn ? "off" : tailFlag ? "tail risk" : bgGapFlag ? "gap-shock (IV crush)" : bgFalseMom ? "false-momentum trap" : bgThetaDanger ? "theta / expiry" : (rich or ivHigh) ? "IV rich (paying up)" : "clear"
bool   bgIsBuy   = bdVCode == 1 or bdVCode == -1
string bgGuardTxt = not bgOn ? "off" : not bgIsBuy ? "n/a (no buy)" : optionBuyOk ? ("OK · Q " + str.tostring(optionQualityMult, "0.00")) : ("CAUTION · " + bgReason + " · Q " + str.tostring(optionQualityMult, "0.00"))
var bool bgCautPrev = false
bool   bgCaution = bgOn and bgIsBuy and not optionBuyOk
bool   bgCautNew = bgCaution and not bgCautPrev
bgCautPrev := bgCaution

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          THEME
// ═════════════════════════════════════════════════════════════════════════════════════════
bool darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color richEff = darkUI ? richCol : color.rgb(176, 132, 0)
color cGreen = darkUI ? color.rgb(46, 189, 133) : color.rgb(14, 124, 90)
color cDn2   = darkUI ? color.rgb(246, 70, 93)  : color.rgb(198, 40, 40)
color stateCol = vrpState == "RICH" ? richEff : vrpState == "CHEAP" ? cheapCol : txtMut
color envCol = env == "PREMIUM-SELL" ? richEff : env == "PREMIUM-BUY" ? cheapCol : env == "DIRECTIONAL" ? cGreen : txtMut
color tierCol = tier == 3 ? cGreen : tier == 1 ? cDn2 : tier == 2 ? richEff : txtMut

// Vol-environment wash — a faint full-chart tint so the environment reads at a glance (gold =
// premium-sell · blue = long-vol · green = with-trend · red = tail risk). Reuses the state already
// computed; stays near-transparent so it never fights the candles.
bgcolor(tintEnv ? (tailFlag ? color.new(cDn2, 90) : env == "PREMIUM-SELL" ? color.new(richEff, 92) : env == "PREMIUM-BUY" ? color.new(cheapCol, 92) : env == "DIRECTIONAL" ? color.new(cGreen, 92) : na) : na, title = "Vol-environment wash")
// background-adaptive, vibrant versions of every level colour (used by both the lines and the legend)
color colEM1e   = f_vib(colEM1, darkUI)
color colEM2e   = f_vib(colEM2, darkUI)
color colCPRe   = f_vib(colCPR, darkUI)
color colCPRwe  = f_vib(colCPRw, darkUI)
color colPive   = f_vib(colPiv, darkUI)
color colCame   = f_vib(colCam, darkUI)
color colPriore = f_vib(colPrior, darkUI)
color colCallWe = f_vib(colCallW, darkUI)
color colPutWe  = f_vib(colPutW, darkUI)
color colMaxPe  = f_vib(colMaxP, darkUI)
color pinColE   = f_vib(color.rgb(255, 214, 0), darkUI)
// AUTO VISUALS — keep only scale-appropriate levels sitting near price (updates as price/time move)
bool  intradayTF = timeframe.in_seconds() < 3600
float autoBand   = na(em1) ? close * (intradayTF ? 0.02 : 0.05) : (intradayTF ? 2.0 : 4.0) * em1
f_flt(float v, bool iOK, bool sOK) =>
    (not autoViz or na(v)) ? v : (((intradayTF and iOK) or (not intradayTF and sOK)) and not na(close) and math.abs(v - close) <= autoBand) ? v : na
f_abTxt(float v) => na(v) ? "warming" : (v >= 0 ? "+" : "") + str.tostring(v, "0.0")
f_abCol(float v) => na(v) ? txtMut : v > 1.0 ? cGreen : v < -1.0 ? cDn2 : txtMut

// ═════════════════════════════════════════════════════════════════════════════════════════
//              LEVELS  —  right-edge NAME + PRICE tags + shaded zones (Options-CPR style)
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<line>  vLines  = array.new<line>()
var array<label> vLabels = array.new<label>()
var array<box>   vBoxes  = array.new<box>()
f_lvl(float v, string name, string suffix, color col, string sty, int w) =>
    if not na(v)
        line ln = line.new(bar_index - 80, v, bar_index + 10, v, xloc = xloc.bar_index, color = color.new(col, 0), width = w, style = sty)
        label lb = label.new(bar_index + 10, v, name + "  " + str.tostring(v, format.mintick) + suffix, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 0), textcolor = f_chipTxt(col), size = size.small)
        array.push(vLines, ln)
        array.push(vLabels, lb)
if showLevels and barstate.islast
    while array.size(vLines) > 0
        line.delete(array.shift(vLines))
    while array.size(vLabels) > 0
        label.delete(array.shift(vLabels))
    while array.size(vBoxes) > 0
        box.delete(array.shift(vBoxes))
    int xL = bar_index - 80
    int xR = bar_index + 10
    if showZones and useCPR and not na(dTC) and not na(dBC) and (not autoViz or (not na(close) and math.abs((dTC + dBC) / 2.0 - close) <= autoBand))
        array.push(vBoxes, box.new(xL, dTC, xR, dBC, xloc = xloc.bar_index, border_color = color.new(colCPRe, 55), bgcolor = color.new(colCPRe, darkUI ? 86 : 90)))
    if showZones and showEM and not na(emUp1) and not na(emDn1)
        array.push(vBoxes, box.new(xL, emUp1, xR, emDn1, xloc = xloc.bar_index, border_color = color.new(colEM1e, 68), bgcolor = color.new(colEM1e, darkUI ? 88 : 92)))
    if showEM
        if show2sig
            f_lvl(f_flt(emUp2, true, true), "Exp. move ▲2σ", "", colEM2e, line.style_dashed, 1)
        f_lvl(f_flt(emUp1, true, true), "Exp. move ▲", "  (±" + str.tostring(em1, "0") + ")", colEM1e, line.style_dashed, 1)
        f_lvl(f_flt(emDn1, true, true), "Exp. move ▼", "", colEM1e, line.style_dashed, 1)
        if show2sig
            f_lvl(f_flt(emDn2, true, true), "Exp. move ▼2σ", "", colEM2e, line.style_dashed, 1)
    if useCPR
        f_lvl(f_flt(dTC, true, true), bdBias == -1 ? "TC ▸ INVAL" : "TC", "", colCPRe, line.style_dotted, 1)
        f_lvl(f_flt(dPivot, true, true), "Pivot", "", colCPRe, line.style_solid, 2)
        f_lvl(f_flt(dBC, true, true), bdBias == 1 ? "BC ▸ INVAL" : "BC", "", colCPRe, line.style_dotted, 1)
        if showFloor
            f_lvl(f_flt(pR3, true, false), "R3", "", colPive, line.style_dashed, 1)
            f_lvl(f_flt(pR2, true, false), "R2", "", colPive, line.style_dashed, 1)
            f_lvl(f_flt(pR1, true, false), bdBias == 1 ? "R1 ▸ TGT" : "R1", "", colPive, line.style_dashed, 1)
            f_lvl(f_flt(pS1, true, false), bdBias == -1 ? "S1 ▸ TGT" : "S1", "", colPive, line.style_dashed, 1)
            f_lvl(f_flt(pS2, true, false), "S2", "", colPive, line.style_dashed, 1)
            f_lvl(f_flt(pS3, true, false), "S3", "", colPive, line.style_dashed, 1)
        if cprWeekly
            f_lvl(f_flt(wTC, false, true), "wTC", "", colCPRwe, line.style_dotted, 1)
            f_lvl(f_flt(wPivot, false, true), "wPivot", "", colCPRwe, line.style_solid, 2)
            f_lvl(f_flt(wBC, false, true), "wBC", "", colCPRwe, line.style_dotted, 1)
        if cprMonthly
            f_lvl(f_flt(mPivot, false, true), "mPivot", "", colCPRwe, line.style_dashed, 2)
    f_lvl(f_flt(pdH, true, true), "Prior high", "", colPriore, line.style_solid, 1)
    f_lvl(f_flt(pdL, true, true), "Prior low", "", colPriore, line.style_solid, 1)
    if showCam and (not camRangeOnly or cprType != "narrow")
        f_lvl(f_flt(camH4, true, false), "H4 brk", "", colCame, line.style_dashed, 1)
        f_lvl(f_flt(camH3, true, false), "H3 rev", "", colCame, line.style_dotted, 1)
        f_lvl(f_flt(camL3, true, false), "L3 rev", "", colCame, line.style_dotted, 1)
        f_lvl(f_flt(camL4, true, false), "L4 brk", "", colCame, line.style_dashed, 1)
    if oiOn
        f_lvl(f_flt(callW1, true, true), "CE wall", "", colCallWe, line.style_solid, 2)
        f_lvl(f_flt(callW2, true, true), "CE wall 2", "", colCallWe, line.style_dotted, 1)
        f_lvl(f_flt(putW1, true, true), "PE wall", "", colPutWe, line.style_solid, 2)
        f_lvl(f_flt(putW2, true, true), "PE wall 2", "", colPutWe, line.style_dotted, 1)
        f_lvl(f_flt(maxPain, true, true), "Max-pain", "", colMaxPe, line.style_dashed, 2)
    if useTape and showPin and not na(tapePin)
        f_lvl(f_flt(tapePin, true, true), "Pin", "", pinColE, line.style_solid, 2)

// legend key — what you're looking at (adapts to the auto-visuals scale: intraday shows floor
// pivots + Camarilla, swing shows the weekly/monthly CPR; both when Auto visuals is OFF)
bool legFloorCam = not autoViz or intradayTF
bool legWkly     = not autoViz or not intradayTF
var table legT = table.new(f_pos(legendPos), 2, 6 + (legFloorCam ? 2 : 0) + (legWkly ? 1 : 0) + (oiOn ? 2 : 0), frame_width = 1, border_width = 1)
f_keyrow(int r, string sym, color sc, string meaning) =>
    table.cell(legT, 0, r, sym, text_color = sc, text_size = size.tiny, text_halign = text.align_center, bgcolor = panelBg)
    table.cell(legT, 1, r, meaning, text_color = txtSub, text_size = size.tiny, text_halign = text.align_left, bgcolor = panelBg)
if showLegend and barstate.islast
    table.set_bgcolor(legT, panelBg)
    table.set_frame_color(legT, frameC)
    table.set_border_color(legT, frameC)
    table.cell(legT, 0, 0, "KEY", text_color = txtMain, text_size = size.tiny, bgcolor = rowAlt)
    table.cell(legT, 1, 0, "what you're looking at", text_color = txtSub, text_size = size.tiny, text_halign = text.align_left, bgcolor = rowAlt)
    int lr = 1
    f_keyrow(lr, "▬", colEM1e, "Expected-move band (±1σ / ±2σ)")
    lr += 1
    f_keyrow(lr, "▬", colCPRe, "Daily CPR zone (TC / Pivot / BC)")
    lr += 1
    if legFloorCam
        f_keyrow(lr, "▬", colPive, "Floor pivots R1-3 / S1-3")
        lr += 1
    if legWkly
        f_keyrow(lr, "▬", colCPRwe, "Weekly / monthly CPR")
        lr += 1
    f_keyrow(lr, "▬", colPriore, "Prior-day high / low")
    lr += 1
    if legFloorCam
        f_keyrow(lr, "▬", colCame, "Camarilla H3/L3 rev · H4/L4 brk")
        lr += 1
    f_keyrow(lr, "▬", pinColE, "Pin (max-volume strike)")
    lr += 1
    f_keyrow(lr, "≈", txtSub, "Narrow CPR = trend · Wide = range")
    lr += 1
    if oiOn
        f_keyrow(lr, "▬", colCallWe, "CE / PE OI wall (manual)")
        lr += 1
        f_keyrow(lr, "▬", colMaxPe, "Max-pain magnet (manual)")
        lr += 1

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
bool proDash = dashMode == "Pro"
int tapeRowsP = useTape ? 8 : 0
int cprRowsP  = useCPR ? 4 : 0
int oiRowsP   = oiOn ? 3 : 0
// Compact is a fixed "what to do" glance (unified decision + why + essentials); Pro carries the full
// stack plus the buyer-decision detail block appended at the end.
int bdRowsP = proDash ? 9 : 0
int nRows = proDash ? (25 + tapeRowsP + cprRowsP + oiRowsP + bdRowsP) : 13
var table T = table.new(f_pos(panelPos), 2, nRows, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color rbg) =>
    table.cell(T, 0, r, k, text_color = txtSub, text_size = size.tiny, text_halign = text.align_left,  bgcolor = rbg)
    table.cell(T, 1, r, v, text_color = vc,     text_size = size.tiny, text_halign = text.align_right, bgcolor = rbg)

if showPanel and barstate.islast
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)
    // UNIFIED HEADLINE — ONE decision object (not two panels): the STRUCTURE axis (CPR day-type,
    // direction, target gate) and the VOLATILITY axis (the Engine's environment / VRP) are already
    // reconciled inside bdVCode; the header states that single decision, the "Why" row cites both axes.
    color  uniCol = tailFlag ? cDn2 : bdVCode == 1 ? cGreen : bdVCode == -1 ? cDn2 : bdVCode == 2 ? richEff : color.rgb(90, 100, 112)
    string uniDecision = tailFlag ? "STAY OUT — tail risk" : bdVerdict
    table.cell(T, 0, 0, "IND-OPT", text_color = f_chipTxt(uniCol), bgcolor = uniCol, text_size = size.tiny)
    table.cell(T, 1, 0, uniDecision, text_color = f_chipTxt(uniCol), bgcolor = uniCol, text_size = size.tiny)
    if proDash
        f_row(1, "Implied vol (IV)", na(ivPct) ? "-" : str.tostring(ivPct, "0.0") + "% · " + ivSrc, txtMain, rowAlt)
        f_row(2, "IV rank", na(ivRank) ? "n/a" : str.tostring(ivRank, "0") + (na(ivPctile) ? "" : "  ·  pct " + str.tostring(ivPctile, "0")), na(ivRank) ? txtMut : ivRank >= 50 ? richEff : cheapCol, panelBg)
        f_row(3, "Realized vol (" + (rvMode == "Yang-Zhang" ? "YZ" : rvMode == "Close-to-close" ? "CC" : rvMode == "Parkinson" ? "PK" : "GK") + ")", na(rvPct) ? "-" : str.tostring(rvPct, "0.0") + "%", txtMain, rowAlt)
        f_row(4, "Premium (IV−RV)", na(vrp) ? "warming" : str.tostring(vrp, "+0.0;-0.0") + " pts", na(vrp) ? txtMut : vrp > 0 ? richEff : cheapCol, panelBg)
        f_row(5, "Vol premium", vrpState + (na(vrp) ? "" : "  (z " + str.tostring(vrpZ, "+0.0") + ")"), stateCol, rowAlt)
        f_row(6, "IV 52w hi / lo", (na(ivHi) ? "-" : str.tostring(ivHi, "0.0")) + " / " + (na(ivLo) ? "-" : str.tostring(ivLo, "0.0")), txtMain, panelBg)
        f_row(7, "IV / RV ratio", na(ivRvRatio) ? "-" : str.tostring(ivRvRatio, "0.00") + "x", na(ivRvRatio) ? txtMut : ivRvRatio > 1 ? richEff : cheapCol, rowAlt)
        f_row(8, "Estimator", rvMode + " · " + str.tostring(rvLen) + "d", txtMut, panelBg)
        f_row(9, "VRP samples", str.tostring(array.size(vrpHist)) + " / " + str.tostring(vrpDays) + " d", txtMut, rowAlt)
        f_row(10, "Exp move ±1σ", na(em1) ? "warming" : "±" + str.tostring(em1, format.mintick) + "  ·  DTE " + str.tostring(dte, "0.#"), na(em1) ? txtMut : txtMain, panelBg)
        f_row(11, "EM band (1σ)", (na(emDn1) ? "-" : str.tostring(emDn1, format.mintick)) + " – " + (na(emUp1) ? "-" : str.tostring(emUp1, format.mintick)), txtMain, rowAlt)
        f_row(12, "Price vs EM", emPos, emPos == "inside 1σ" ? txtMut : str.startswith(emPos, "beyond") ? cheapCol : txtMain, panelBg)
        f_row(13, "ATM " + (na(atmK) ? "-" : str.tostring(atmK, format.mintick)) + " straddle", na(atmStraddle) ? "-" : str.tostring(atmStraddle, format.mintick) + (na(straddlePctS) ? "" : "  (" + str.tostring(straddlePctS, "0.0") + "%)"), txtMain, rowAlt)
        f_row(14, "Straddle breakevens", (na(beDn) ? "-" : str.tostring(beDn, format.mintick)) + " – " + (na(beUp) ? "-" : str.tostring(beUp, format.mintick)), txtMain, panelBg)
        f_row(15, "Theta/day · Vega", (na(atmThetaDay) ? "-" : str.tostring(atmThetaDay, "0.0")) + " · " + (na(atmVega) ? "-" : str.tostring(atmVega, "0.0")), na(atmThetaDay) ? txtMut : cDn2, rowAlt)
        f_row(16, "Environment", na(vrp) ? "warming" : env, envCol, panelBg)
        f_row(17, "Stay ≤1σ (base rate)", na(baseRate) ? "warming (" + str.tostring(nCv) + ")" : str.tostring(baseRate, "0") + "%  (n " + str.tostring(nCv) + ")", na(baseRate) ? txtMut : txtMain, rowAlt)
        f_row(18, "A/B edge rich · IVhi", na(vrpEdge) and na(ivHiEdge) ? "warming" : "rich " + f_abTxt(vrpEdge) + " · IVhi " + f_abTxt(ivHiEdge), f_abCol(vrpEdge), panelBg)
        f_row(19, "Net-R (sell rich)", na(netR) or richN < minN ? "warming" : str.tostring(netR, "+0.00;-0.00") + " R", (na(netR) or richN < minN) ? txtMut : netR > 0 ? cGreen : cDn2, rowAlt)
        f_row(20, "OOS edge (LB)", roosN < minN or na(oosEdge) ? "warming (" + str.tostring(int(roosN)) + ")" : f_abTxt(oosEdge) + " (LB " + f_abTxt(oosEdgeLB) + ")", (roosN < minN or na(oosEdge)) ? txtMut : oosEdgeLB > 0 ? cGreen : cDn2, panelBg)
        f_row(21, "Verdict", (calibOn ? verdict : "off") + (tailFlag ? " · tail" : ""), tierCol, rowAlt)
        f_row(22, "Prob in 1σ · in BE", (na(probInEM) ? "-" : str.tostring(probInEM, "0") + "%") + " · " + (na(probInBE) ? "-" : str.tostring(probInBE, "0") + "%"), na(probInBE) ? txtMut : txtMain, panelBg)
        f_row(23, "RV forecast (" + str.tostring(Hf) + "d φ" + (na(phi) ? "-" : str.tostring(phi, "0.00")) + ")", na(rvFcast) ? "warming" : str.tostring(rvFcast, "0.0") + "% · " + rvTrend, na(rvFcast) ? txtMut : rvTrend == "rising" ? cDn2 : rvTrend == "falling" ? cGreen : txtMain, rowAlt)
        f_row(24, "Fwd premium (IV−RVf)", na(vrpFwd) ? "warming" : str.tostring(vrpFwd, "+0.0;-0.0") + " pts · " + vrpFwdState, na(vrpFwd) ? txtMut : vrpFwd > 0 ? richEff : cheapCol, panelBg)
    else
        // ── COMPACT · unified glance: DECISION (header) + WHY (both axes) + the essentials ──
        f_row(1, "Why (2 axes)", uniWhy, na(vrp) ? txtMut : txtSub, rowAlt)
        string optTxt = tailFlag ? "PRICEY & RISKY" : na(vrp) ? "measuring…" : vrpState == "RICH" ? "EXPENSIVE" : vrpState == "CHEAP" ? "CHEAP" : "FAIR-PRICED"
        f_row(2, "Options are", optTxt, tailFlag ? cDn2 : stateCol, panelBg)
        f_row(3, "Direction → target", bdBiasTxt + (na(bdTgt1) ? "" : "  → " + str.tostring(bdTgt1, format.mintick)), bdBias == 1 ? cGreen : bdBias == -1 ? cDn2 : txtMut, rowAlt)
        f_row(4, "Likely range today", na(em1) ? "warming" : str.tostring(emDn1, "0") + " – " + str.tostring(emUp1, "0") + "  (±" + str.tostring(em1, "0") + ")", na(em1) ? txtMut : txtMain, panelBg)
        f_row(5, "Stays in range", na(probInEM) ? "warming" : str.tostring(probInEM, "0") + "% chance", na(probInEM) ? txtMut : probInEM >= 60 ? cGreen : probInEM <= 40 ? cDn2 : richEff, rowAlt)
        string bdDayTxt = na(bdWidthPct) ? "warming" : str.tostring(bdWidthPct, "0") + "%ile · " + (bdDayTypeN == 1 ? "trend day (ride breaks)" : bdDayTypeN == -1 ? "range day (fade edges)" : "balanced day")
        f_row(6, "Day type", bdDayTxt, bdDayTypeN == 1 ? cGreen : bdDayTypeN == -1 ? richEff : txtMut, panelBg)
        string bdEdgeTxt = not calibOn ? "off" : bdNarrowN < bdCalMinN ? "warming (" + str.tostring(bdNarrowN) + "/" + str.tostring(bdCalMinN) + ")" : (na(bdEdge) ? "—" : (bdEdge >= 0 ? "+" : "") + str.tostring(bdEdge, "0.0") + "pp " + (bdProven ? "✓ proven" : "(not proven)"))
        f_row(7, "Narrow→trend edge", bdEdgeTxt, (not calibOn or bdNarrowN < bdCalMinN) ? txtMut : bdProven ? cGreen : richEff, rowAlt)
        string edgeTxt = not calibOn ? "off" : tier == 3 ? "YES — proven" : tier == 1 ? "NO edge" : tier == 2 ? "not proven yet" : "still learning"
        f_row(8, "Premium-sell edge", edgeTxt + (tailFlag ? " · risky" : ""), tierCol, panelBg)
        float magnet = (useTape and not na(tapePin)) ? tapePin : dPivot
        string magSrc = (useTape and not na(tapePin)) ? "pin" : "pivot"
        f_row(9, "Magnet (" + magSrc + ")", na(magnet) ? "warming" : str.tostring(magnet, format.mintick) + "  (" + str.tostring(magnet - close, "+0;-0") + ")", na(magnet) ? txtMut : txtMain, rowAlt)
        string tiltTxt = na(tapeSkew) ? "n/a" : skewSign < 0 ? "puts favored (fear)" : skewSign > 0 ? "calls favored (greed)" : "balanced"
        f_row(10, "Market tilt", tiltTxt, na(tapeSkew) ? txtMut : skewSign < 0 ? cDn2 : skewSign > 0 ? cGreen : txtMut, panelBg)
        string weekTxt = na(termSlope) ? "n/a" : termSign < 0 ? "event-priced (front rich)" : termSign > 0 ? "calm (normal curve)" : "flat"
        f_row(11, "This week", weekTxt, na(termSlope) ? txtMut : termSign < 0 ? richEff : termSign > 0 ? cGreen : txtMut, rowAlt)
        string bgCompact = not bgOn ? "off" : not bgIsBuy ? "—" : optionBuyOk ? ("safe · Q " + str.tostring(optionQualityMult, "0.00")) : (bgReason + " · Q " + str.tostring(optionQualityMult, "0.00"))
        f_row(12, "Buy safety", bgCompact, (not bgOn or not bgIsBuy) ? txtMut : optionBuyOk ? cGreen : cDn2, panelBg)
    if proDash and useTape
        int rB = 25
        color tapeBg = proDash ? panelBg : rowAlt
        f_row(rB + 0, tapeStale ? "Tape ⚠ stale" : "Tape straddle (wk " + tExpStr + ")", tapeStale ? "set ATM " + str.tostring(tAtmLive, "0") : na(tapeStraddle) ? "—" : str.tostring(tapeStraddle, format.mintick), tapeStale ? cDn2 : na(tapeStraddle) ? txtMut : txtMain, tapeBg)
        f_row(rB + 1, "Tape IV (proxy)", na(tapeIV) ? "—" : str.tostring(tapeIV, "0.0") + "%" + (na(ivPct) ? "" : ivPct > 0 and tapeIV > ivPct ? "  ↑ vs VIX" : "  ↓ vs VIX"), na(tapeIV) ? txtMut : richEff, proDash ? rowAlt : panelBg)
        f_row(rB + 2, "Volume PCR", na(tapePCR) ? "—" : str.tostring(tapePCR, "0.00"), na(tapePCR) ? txtMut : tapePCR > 1.0 ? cGreen : cDn2, tapeBg)
        f_row(rB + 3, "Pin strike", na(tapePin) ? "—" : str.tostring(tapePin, format.mintick) + (na(close) ? "" : "  (" + str.tostring(tapePin - close, "+0;-0") + ")"), na(tapePin) ? txtMut : pinColE, proDash ? panelBg : rowAlt)
        if proDash
            f_row(rB + 4, "Tape coverage", tLegs == 0 ? "unavailable — check root / plan" : "legs " + str.tostring(tLegs) + "/22" + (tDriftK > 2 ? " · set ATM " + str.tostring(tAtmLive, "0") : ""), tLegs == 0 or tDriftK > 2 ? cDn2 : txtMut, rowAlt)
        int rS = rB + 5
        f_row(rS, "Skew (put−call)", na(tapeSkew) ? (tapeStale ? "stale" : "—") : str.tostring(tapeSkew, "+0;-0") + "% · " + skewState, na(tapeSkew) ? txtMut : skewSign < 0 ? cDn2 : skewSign > 0 ? cGreen : txtMut, panelBg)
        f_row(rB + 6, "Term wk→next", na(termSlope) ? (tapeStale ? "stale" : "—") : str.tostring(termSlope, "+0.0;-0.0") + "% · " + termState, na(termSlope) ? txtMut : termSign < 0 ? cDn2 : termSign > 0 ? cGreen : txtMut, rowAlt)
        f_row(rB + 7, "Vol curve wk·nx·mo", (na(tapeIV) ? "—" : str.tostring(tapeIV, "0.0")) + "·" + (na(tapeIV2) ? "—" : str.tostring(tapeIV2, "0.0")) + "·" + (na(tapeIVM) ? "—" : str.tostring(tapeIVM, "0.0")) + "  " + curveState, na(monSlope) ? txtMut : curveSign > 0 ? cGreen : curveSign < 0 ? cDn2 : richEff, panelBg)
    if proDash and useCPR
        int cB = 25 + (useTape ? 8 : 0)
        color cpBg = (cB % 2 == 0) ? panelBg : rowAlt
        color cpBg2 = (cB % 2 == 0) ? rowAlt : panelBg
        f_row(cB + 0, "CPR day-type · 2-day", (cprType == "warming" ? "warming" : cprType) + (cpr2day == "-" ? "" : " · " + cpr2day), cprType == "narrow" ? cGreen : cprType == "wide" ? richEff : txtMut, cpBg)
        f_row(cB + 1, "Structure × vol", structTxt, structAgree ? cGreen : structTxt == "warming" ? txtMut : txtSub, cpBg2)
        if proDash
            f_row(cB + 2, "Daily P / TC / BC", (na(dPivot) ? "-" : str.tostring(dPivot, format.mintick)) + " · " + (na(dTC) ? "-" : str.tostring(dTC, "0")) + "/" + (na(dBC) ? "-" : str.tostring(dBC, "0")), txtMain, cpBg)
            f_row(cB + 3, "EM vs CPR", emVsCPR, emVsCPR == "-" ? txtMut : str.startswith(emVsCPR, "1σ inside") ? richEff : cGreen, cpBg2)
    if proDash and oiOn
        int oB = 25 + (useTape ? 8 : 0) + (useCPR ? 4 : 0)
        color oBg = (oB % 2 == 0) ? panelBg : rowAlt
        color oBg2 = (oB % 2 == 0) ? rowAlt : panelBg
        f_row(oB + 0, "Max-pain · dist", na(maxPain) ? "set in settings" : str.tostring(maxPain, format.mintick) + "  (" + str.tostring(maxPainDist, "+0;-0") + ")", na(maxPain) ? txtMut : colMaxPe, oBg)
        f_row(oB + 1, "OI walls CE / PE", (na(callW1) ? "-" : str.tostring(callW1, "0")) + " / " + (na(putW1) ? "-" : str.tostring(putW1, "0")), (na(callW1) and na(putW1)) ? txtMut : txtMain, oBg2)
        if proDash
            f_row(oB + 2, "Price vs OI walls", oiZone == "-" ? "set walls" : oiZone, oiZone == "-" ? txtMut : oiZone == "pinned in OI range" ? txtMain : str.startswith(oiZone, "above") ? cGreen : cDn2, oBg)
    if proDash
        // ── BUYER-DECISION DETAIL (day-type · direction · target · forward-tested edge) ──
        int   bB   = 25 + tapeRowsP + cprRowsP + oiRowsP
        color bBg  = (bB % 2 == 0) ? panelBg : rowAlt
        color bBg2 = (bB % 2 == 0) ? rowAlt : panelBg
        f_row(bB + 0, "Buyer verdict", bdVerdict, uniCol, bBg)
        f_row(bB + 1, "Why (2 axes)", uniWhy, txtSub, bBg2)
        f_row(bB + 2, "Day type (%ile)", na(bdWidthPct) ? "warming" : str.tostring(bdWidthPct, "0") + "%ile · " + bdDayWord, bdDayTypeN == 1 ? cGreen : bdDayTypeN == -1 ? richEff : txtMut, bBg)
        f_row(bB + 3, "Two-day CPR", cpr2day == "-" ? "warming" : cpr2day, bdRelBias == 1 ? cGreen : bdRelBias == -1 ? cDn2 : txtMut, bBg2)
        f_row(bB + 4, "Direction", bdBiasTxt, bdBias == 1 ? cGreen : bdBias == -1 ? cDn2 : txtMut, bBg)
        f_row(bB + 5, "Target / invalidation", (na(bdTgt1) ? "—" : str.tostring(bdTgt1, format.mintick)) + "  /  " + (na(bdInval) ? "—" : str.tostring(bdInval, format.mintick)), txtMain, bBg2)
        f_row(bB + 6, "EM vs target", (na(em1) or na(bdCprMove)) ? "—" : "±" + str.tostring(em1, "0") + " vs " + str.tostring(bdCprMove, "0") + (bdEmCoversTgt ? " ✓ covers" : " ✗ priced>tgt"), (na(em1) or na(bdCprMove)) ? txtMut : bdEmCoversTgt ? cGreen : richEff, bBg)
        f_row(bB + 7, "Narrow→trend (Wilson)", bdNarrowN < bdCalMinN ? "warming (" + str.tostring(bdNarrowN) + "/" + str.tostring(bdCalMinN) + ")" : str.tostring(bdNarrowHit, "0") + "% vs " + str.tostring(bdBaseHit, "0") + "% base" + (bdProven ? " ✓" : ""), bdNarrowN < bdCalMinN ? txtMut : bdProven ? cGreen : richEff, bBg2)
        f_row(bB + 8, "Buy-safety guard", bgGuardTxt, (not bgOn or not bgIsBuy) ? txtMut : optionBuyOk ? cGreen : cDn2, bBg)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    EXP_ BUS (stubs — grow through the stages)
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(showEXP ? ivPct : na, "EXP_IV", display = display.data_window)
plot(showEXP ? ivRank : na, "EXP_IVRank", display = display.data_window)
plot(showEXP ? rvPct : na, "EXP_RV", display = display.data_window)
plot(showEXP ? vrp : na, "EXP_VRP", display = display.data_window)
plot(showEXP ? (na(vrp) ? na : vrpZ > richZ ? 1.0 : vrpZ < -richZ ? -1.0 : 0.0) : na, "EXP_VRPState", display = display.data_window)
plot(showEXP ? emUp1 : na, "EXP_ExpMoveUp", display = display.data_window)
plot(showEXP ? emDn1 : na, "EXP_ExpMoveDn", display = display.data_window)
plot(showEXP ? dte : na, "EXP_DTE", display = display.data_window)
plot(showEXP ? atmK : na, "EXP_ATMStrike", display = display.data_window)
plot(showEXP ? atmStraddle : na, "EXP_ATMStraddle", display = display.data_window)
plot(showEXP ? atmThetaDay : na, "EXP_ThetaDay", display = display.data_window)
plot(showEXP ? probInEM : na, "EXP_ProbInEM", display = display.data_window)
plot(showEXP ? probInBE : na, "EXP_ProbInBE", display = display.data_window)
plot(showEXP ? envSign : na, "EXP_EnvState", display = display.data_window)
plot(showEXP ? tier : na, "EXP_Tier", display = display.data_window)
plot(showEXP ? netR : na, "EXP_NetR", display = display.data_window)
plot(showEXP ? baseRate : na, "EXP_StayRate", display = display.data_window)
plot(showEXP ? (tailFlag ? 1.0 : 0.0) : na, "EXP_TailRisk", display = display.data_window)
plot(showEXP and useTape ? tapeStraddle : na, "EXP_TapeStraddle", display = display.data_window)
plot(showEXP and useTape ? tapeIV : na, "EXP_TapeIV", display = display.data_window)
plot(showEXP and useTape ? tapePCR : na, "EXP_TapePCR", display = display.data_window)
plot(showEXP and useTape ? tapePin : na, "EXP_TapePin", display = display.data_window)
plot(showEXP and useTape ? tapeSkew : na, "EXP_Skew", display = display.data_window)
plot(showEXP and useTape ? skewSign : na, "EXP_SkewState", display = display.data_window)
plot(showEXP and useTape ? termSlope : na, "EXP_TermSlope", display = display.data_window)
plot(showEXP and useTape ? termSign : na, "EXP_TermStructure", display = display.data_window)
plot(showEXP and useCPR ? dPivot : na, "EXP_CPR_Pivot", display = display.data_window)
plot(showEXP and useCPR ? dTC : na, "EXP_CPR_TC", display = display.data_window)
plot(showEXP and useCPR ? dBC : na, "EXP_CPR_BC", display = display.data_window)
plot(showEXP and useCPR ? cprDayTypeN : na, "EXP_CPR_DayType", display = display.data_window)
plot(showEXP and useCPR and cprWeekly ? wPivot : na, "EXP_WeeklyPivot", display = display.data_window)
plot(showEXP ? rvFcast : na, "EXP_RVForecast", display = display.data_window)
plot(showEXP ? vrpFwd : na, "EXP_VRPFwd", display = display.data_window)
plot(showEXP and oiOn ? maxPain : na, "EXP_MaxPain", display = display.data_window)
plot(showEXP and oiOn ? callW1 : na, "EXP_CallWall", display = display.data_window)
plot(showEXP and oiOn ? putW1 : na, "EXP_PutWall", display = display.data_window)
// buyer-decision layer exports (additive — the existing EXP_ names above are unchanged)
plot(showEXP ? bdVCode : na, "EXP_BuyVerdict", display = display.data_window)
plot(showEXP ? bdWidthPct : na, "EXP_CprWidthPct", display = display.data_window)
plot(showEXP ? bdEdge : na, "EXP_DayTypeEdge", display = display.data_window)
plot(showEXP ? bdBias : na, "EXP_PriceVsCPR", display = display.data_window)
// NOTE: 8 low-value DIAGNOSTIC exports (EXP_IVPct, EXP_VRP_Z, EXP_ExpMove2Up/Dn, EXP_Vega,
//   EXP_VRPEdge, EXP_IVHiEdge, EXP_VolCurve) are retired here to keep the script under TradingView's
//   64-plot ceiling now that the two new layers below are added. None is consumed by the Master
//   engine or any known downstream link (they read the headline EXP_ names, all preserved); the same
//   figures remain visible in the Pro dashboard.
// option-buyer risk guard exports (Wave E · additive)
plot(showEXP ? (optionBuyOk ? 1.0 : 0.0) : na, "EXP_OptionBuyOk", display = display.data_window)
plot(showEXP ? optionQualityMult : na, "EXP_OptionQuality", display = display.data_window)
plot(showEXP ? bgGapShock : na, "EXP_GapShock", display = display.data_window)

// ── Spot–futures basis (Wave D · U14) — the futures premium/discount the VIX/IV reads don't see ──
// request.security called UNCONDITIONALLY (v6-safe), then gated; ta.* likewise unconditional.
float _spotRaw    = request.security(spotSymIn, timeframe.period, close, ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off)
float spotPx      = showBasis ? _spotRaw : na
float basisPct    = (not na(spotPx) and spotPx != 0.0) ? (close - spotPx) / spotPx * 100.0 : na
float basisAnnPct = (not na(basisPct) and not na(dte) and dte > 0.0) ? basisPct * (365.0 / dte) : na
float _bMean = ta.sma(basisPct, 100)
float _bSd   = ta.stdev(basisPct, 100)
float basisZ = (not na(basisPct) and not na(_bMean) and _bSd > 0.0) ? (basisPct - _bMean) / _bSd : na
int   basisState = na(basisZ) ? 0 : basisZ >= 1.0 ? 1 : basisZ <= -1.0 ? -1 : 0   // +1 rich premium · -1 discount/backwardation
plot(showEXP and showBasis ? basisPct     : na, "EXP_Basis",       display = display.data_window)
plot(showEXP and showBasis ? basisAnnPct  : na, "EXP_BasisAnn",    display = display.data_window)
plot(showEXP and showBasis ? basisState   : na, "EXP_BasisState",  display = display.data_window)
alertcondition(showBasis and basisState == 1  and basisState[1] != 1,  "Futures premium rich", "India Options Engine: futures basis in a rich premium vs its history (bullish carry / risk-on context)")
alertcondition(showBasis and basisState == -1 and basisState[1] != -1, "Futures discount",     "India Options Engine: futures basis in discount / backwardation vs its history (risk-off context)")
// ═════════════════════════════════════════════════════════════════════════════════════════
//                                   IDENTITY STRIP + ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
var table idT = table.new(position.bottom_center, 1, 1)
if barstate.islast and showId
    table.cell(idT, 0, 0, "India Options Engine · " + syminfo.ticker + " · " + timeframe.period, text_size = size.tiny, text_color = darkUI ? color.white : color.black, bgcolor = color.new(darkUI ? color.black : color.white, 15))

alertcondition(env == "PREMIUM-SELL" and env[1] != "PREMIUM-SELL", "Premium-sell environment", "India Options Engine: IV dear vs realized — premium-selling environment (context)")
alertcondition(env == "PREMIUM-BUY" and env[1] != "PREMIUM-BUY", "Premium-buy environment", "India Options Engine: IV cheap vs realized — long-vol environment (context)")
alertcondition(tailFlag and not tailFlag[1], "Tail risk on", "India Options Engine: TAIL RISK — IV in the top percentile or realized vol spiking; premium-selling edge disabled")
alertcondition(tier == 3 and tier[1] != 3, "Edge confirmed", "India Options Engine: the VRP premium-selling read reached EDGE CONFIRMED on this chart")
// buyer-decision layer alerts (static strings)
alertcondition(bdVCode == 1 and bdVCode[1] != 1, "Buyer: BUY CE lean", "India Options Engine: day-type + direction lean BUY CE — the priced move covers the structural target (context, not advice)")
alertcondition(bdVCode == -1 and bdVCode[1] != -1, "Buyer: BUY PE lean", "India Options Engine: day-type + direction lean BUY PE — the priced move covers the structural target (context, not advice)")
alertcondition(bdVCode == 2 and bdVCode[1] != 2, "Buyer: SELL PREMIUM / stay out", "India Options Engine: the priced move exceeds the structural target — a premium-sell / stay-out lean (context, not advice)")
alertcondition(isNewDay and bdDayTypeN == 1, "Trend day expected (CPR)", "India Options Engine: narrow CPR — a trending session is the historical expectation (context, not advice)")
alertcondition(isNewDay and bdDayTypeN == -1, "Range day expected (CPR)", "India Options Engine: wide CPR — a rangebound session is the historical expectation (context, not advice)")
// option-buyer risk guard alerts (Wave E)
alertcondition(bgCautNew, "Buyer: risk-guard CAUTION", "India Options Engine: a BUY verdict is firing but the option-buyer risk guard flags caution (gap-shock / false-momentum / theta / tail) — buying premium here is lower quality (context, not advice)")
alertcondition(bgOn and bgIsBuy and optionBuyOk and bdVCode == 1 and bdVCode[1] != 1, "Buyer: clean BUY CE", "India Options Engine: BUY CE with the risk guard clear — no gap-shock / trap / theta / tail flags (context, not advice)")
alertcondition(bgOn and bgIsBuy and optionBuyOk and bdVCode == -1 and bdVCode[1] != -1, "Buyer: clean BUY PE", "India Options Engine: BUY PE with the risk guard clear — no gap-shock / trap / theta / tail flags (context, not advice)")
````
