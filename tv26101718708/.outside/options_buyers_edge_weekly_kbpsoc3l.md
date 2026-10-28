# Options Buyer's Edge Weekly

- url: https://www.tradingview.com/script/KBPsOC3L-Options-Buyer-s-Edge-Weekly/
- type: indicator
- pine_id: PUB;a55dd013171c488db0e945a6a6e93851
- version: 2.0

## Description

Overview

Options Buyer's Edge — Weekly is a decision-support panel for the weekly index option buyer. Most option tools chase directional "smart-money flow," but on retail-dominated weeklies that flow is largely uninformed — so the durable edge for a buyer isn't direction, it's the premium environment you actually pay for: is implied volatility cheap or rich, is it expanding or crushing, how hard is theta biting toward expiry, and where is the pin magnet pulling price. This script auto-builds an ATM strike ladder for the current weekly, reads the option tape directly, adds a skew-gated directional layer, and then tests every call it makes against your own history. It is a context-and-timing map for buying premium — not a signal generator.

Why these components are ONE tool (mashup justification)

This is a deliberate dependency chain, not a stack of independent indicators. Each layer answers a question the previous one leaves open, and the buyer needs all of them to price what they're doing:


IV / straddle state (primary). The buyer's number-one enemy is paying rich premium into a crush. The ATM straddle gives an IV proxy (percentiled so "rich/cheap" is relative to this instrument's own history) and its slope tells you whether IV is expanding (tailwind) or crushing (bleed). A second read, Prem vs RV, compares that implied vol against realized vol — the variance-risk-premium — so "rich" means rich relative to what the market is actually delivering, not just rich in the abstract.
Theta clock (primary). Premium decays non-linearly into expiry. The panel converts hours-to-weekly-expiry into an escalating decay zone (Normal → Elevated → High → Extreme) so you know when time decay alone makes a long option a bad trade regardless of direction.
Pin magnet (primary). Option volume concentrates at a strike that price tends to gravitate toward near expiry. The tool finds the max-volume strike and draws it — the level a buyer is fighting against.
Underlying character (confirming). Futures basis pulse and India VIX behaviour describe whether the underlying move carries conviction or is unwinding — a cross-check on the directional read.
Directional flow (secondary, gated). A delta-weighted signed CE/PE buyer-pressure imbalance, gated by option skew and trusted only when the calibration Edge for it is positive. Directional option flow predicts returns mainly from informed traders and reverses at longer horizons; on retail weeklies it may be noise — so it earns trust from measured Edge, never from assertion.
The calibration harness (the honesty layer). Two forward tests run continuously: an underlying test (did a strong directional read actually precede a k×ATR move, versus the unconditional base rate?) and a thinner option-outcome test (did the ATM option gain the target % over the horizon?). Both resolve only on confirmed bars, and both are shown as Hit / Base / Edge so you can see whether any layer is carrying information on your instrument right now.


Remove any one layer and the buyer is flying on premium they can't price. The straddle is a picture; theta and pin are mechanics; flow is a hypothesis; the harness is the proof.

How it works

The ATM strike is anchored from spot at the start of the calculation window and held constant (Pine can't mint new option symbols per bar, and request symbols must be fixed, not per-bar series). A ±3 ladder of CE/PE symbols is auto-built for the weekly expiry and each leg's price and volume are requested; invalid or illiquid strikes simply return nothing and are ignored. From the ladder the tool derives the straddle and IV proxy, the IV slope, volume PCR, the pin strike, an OTM skew read, and the delta-weighted buyer-pressure imbalance. Futures basis and India VIX add the underlying-character read, and an optional lower-timeframe slice (the finest your plan serves) sharpens it.

How to use it

Read the guidance panel top to bottom: the verdict (CE-buyable / PE-buyable / Avoid–crush or decay / Wait), the premium environment (IV cheap/rich, expanding/crushing), Prem vs RV, VIX behaviour, the theta zone, the pin, PCR, and the two Edge readings. Lean toward buying premium in a direction only when the environment is supportive and the theta zone isn't extreme. The flow-side (Option) Edge tells you whether the directional layer is working here; if it's near zero, ignore the flow and lean on IV / theta / pin. Everything is descriptive context — it never tells you to trade.

Plan-adaptive & data note

Intrabar precision auto-selects the finest slice your plan serves (seconds on Premium+, else 1-minute, else chart bar) and every stream is na-safe — any leg or feed your plan or the market doesn't serve simply contributes nothing, and the panel shows live leg coverage (x/14). The tool needs an underlying with real option data; on a symbol without it, the legs read empty. It is fully self-contained (nothing exported), so the whole request budget serves accuracy.

Non-repainting & honesty

The script works on confirmed closed bars with no higher-timeframe lookahead, and both calibration harnesses log and resolve only on confirmed bars, so their statistics never repaint intrabar. Important limits, stated plainly: NSE exposes no per-strike option OI, no tick tape and no greeks to scripts, so IV, skew and delta here are OHLCV proxies and flow is a buyer-pressure proxy. Option streams are session-anchored — re-add the script if spot travels more than ~2 strikes (a drift warning fires). The option-outcome Edge is inherently thin because a weekly contract lives only ~5 days; the underlying Edge matures faster. All Edge figures are in-sample, forward-measured at a fixed horizon, with no costs — a study aid, not a backtest.

Originality

The building blocks are public: volume-concentration (pin/max-pain) analysis, put-call flow, value-area logic, the ATM-straddle implied-volatility approximation, and the variance-risk-premium comparison. What's original is the integration for the buyer specifically — the auto-built weekly ATM ladder read directly off the option tape, the skew-gated directional layer that is trusted only on measured Edge, and the dual forward-calibration harness (underlying + option-outcome) that scores every call against its own base rate. This is a clean-room implementation; no third-party script code is reused.

Concept credits


ATM-straddle → implied-volatility approximation — Brenner & Subrahmanyam
Variance-risk-premium framing (implied vs realized vol) — standard volatility-research technique
Pin / max-pain volume concentration, put-call ratio, value-area analysis, option skew — standard public options techniques


Disclaimer

Research and education only. Not financial advice, no recommendation, no guarantee. Options carry the risk of total loss of premium, and time decay works against buyers. The Edge figures are in-sample with no costs and do not predict price. Test out-of-sample and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                   MPL-2.0
// OPTIONS BUYER'S EDGE — WEEKLY                                                               v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   Built for the weekly index option BUYER. Its durable edge is not "follow smart-money flow" —
//   on retail-dominated weeklies that flow is largely uninformed — it is timing the PREMIUM
//   ENVIRONMENT you actually pay for: is implied volatility cheap or rich, is it expanding or
//   CRUSHING, how hard is theta biting into expiry, and where is the pin magnet pulling price. It
//   auto-builds an ATM strike ladder for the current weekly, reads the option tape directly, adds
//   a skew-gated directional flow layer, and then TESTS every call it makes on your own history.
//   It is a context and timing map for buying premium — not a signal generator.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool)
//   PRIMARY (mechanical, true regardless of who trades):
//     - IV / STRADDLE state: cheap vs rich + expanding vs crushing — the buyer's #1 enemy.
//     - THETA CLOCK: hours to weekly expiry with an escalating decay warning.
//     - PIN magnet: where option volume concentrates — the level price is dragged toward.
//   CONFIRMING:
//     - Underlying character: futures-basis pulse + India VIX behaviour (conviction vs unwind).
//   SECONDARY (research-supported but harness-gated):
//     - Delta-weighted signed CE/PE buyer pressure, GATED by option skew and only trusted when the
//       calibration Edge is positive. Directional option flow predicts returns mainly from informed
//       traders and reverses at longer horizons; on retail weeklies it may be noise — so it earns
//       trust only from measured Edge, never from assertion.
//   The straddle is a picture; theta and pin are mechanics; flow is a hypothesis; the harness is
//   the honesty. Remove any one and the buyer is flying on premium they can't price.
//
// HOW IT WORKS
//   The ATM strike is anchored from spot at each session and held (Pine can't mint new option
//   symbols on live bars); a ±3 ladder of CE/PE symbols is auto-built for the weekly expiry and
//   their price+volume are requested (invalid/illiquid strikes return na and are ignored). From
//   these: the ATM straddle and an IV proxy (straddle ÷ spot, percentiled); its slope (IV expand
//   vs crush); volume PCR; the max-volume pin strike; an OTM skew read; and a delta-weighted signed
//   buyer-pressure imbalance. Underlying character adds futures basis and VIX behaviour. Optional
//   lower-timeframe slices (finest available on your plan) sharpen the underlying read.
//
// HOW TO USE
//   Read the guidance panel: the verdict (CE-buyable / PE-buyable / Avoid — crush or decay / Wait),
//   the premium environment (IV cheap/rich, expanding/crushing), the VIX behaviour, the theta zone,
//   the pin, and the two Edge readings. Buy premium with the direction only when the environment is
//   supportive and the theta zone isn't extreme. The FLOW-side Edge tells you whether the directional
//   layer is working on this instrument now; if it's near zero, ignore the flow and lean on IV/theta/pin.
//
// PLAN-ADAPTIVE  (works on the highest plan, degrades cleanly on lower)
//   Intrabar precision auto-selects the finest slice your plan serves (seconds on Premium+, else
//   1-minute, else chart bar). Every stream is na-safe: any leg/feed your plan or the market does
//   not serve contributes nothing, and the panel shows live coverage. Nothing here is exposed for
//   other scripts — it is fully self-contained, so the whole request budget serves accuracy.
//
// NON-REPAINT / HONESTY / LIMITATIONS
//   Confirmed closed bars, no HTF lookahead; the calibration harnesses log AND resolve only on
//   barstate.isconfirmed, so their statistics never repaint intrabar. NSE exposes no per-strike
//   option OI, no tick tape and no greeks to scripts, so IV/skew/delta are OHLCV proxies and flow
//   is a buyer-pressure proxy. Option streams are session-anchored (re-add if spot travels >2
//   strikes — a drift warning fires). The option-outcome Edge is inherently thin (a weekly contract
//   lives ~5 days); the underlying Edge matures faster. Edge figures are IN-SAMPLE — a study aid,
//   not a backtest.
//
// EDGE IS NOW BOUNDED, NOT ASSERTED  (v1.1)
//   A raw Edge is a POINT ESTIMATE. On a small sample a +4 pt reading and pure noise are
//   indistinguishable, and the option-side sample is thin by construction (a weekly contract lives
//   about five days). Both harnesses now report a WILSON 95% LOWER BOUND alongside the point
//   estimate: Edge LB = wilsonLo(hit rate) − base rate. The panel turns green only when that LOWER
//   BOUND clears zero with an adequate sample — a positive point estimate alone is no longer
//   treated as evidence, and a wide interval on a thin sample now looks as uncertain as it is.
//
// COSTS ARE CHARGED TO THE OPTION TEST  (v1.1)
//   Weekly option spreads are wide relative to premium, so a gross winner is frequently a net
//   loser. The option-outcome test now requires the ATM option to clear the gain threshold PLUS a
//   round-trip cost (spread crossed both ways, brokerage and taxes, as a percent of premium;
//   default 4%). The charge is applied to the SIGNAL and the BASE RATE alike, so the comparison
//   stays fair — it raises the bar for both, and only a genuine edge survives it. Set it to your
//   own execution reality; further-OTM or illiquid strikes are considerably worse than ATM.
//   CONCEPT CREDIT: standard techniques (kernel/volume concentration, put-call flow, value-area and
//   implied-volatility analysis; ATM-straddle IV approximation after Brenner & Subrahmanyam);
//   full credits in the published description. Nothing predicts price.
//
// DISCLAIMER
//   Research and education only. NOT financial advice, NO recommendation, NO guarantee. Options
//   carry the risk of total loss of premium; time decay works against buyers. Test out-of-sample
//   and make your own decisions. The author accepts no liability for any use of this script.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Options Buyer's Edge — Weekly", "Buyer's Edge", overlay = true, calc_bars_count = 250, max_labels_count = 100, max_lines_count = 50, max_boxes_count = 50)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g0       = "01 · Underlying & strikes"
root     = input.string("NSE:NIFTY", "Option root", group = g0, tooltip = "Symbol prefix used to build option tickers, e.g. NSE:NIFTY → NSE:NIFTY{YYMMDD}{C|P}{strike}. Change for BANKNIFTY/FINNIFTY/etc.")
futSym   = input.symbol("NSE:NIFTY1!", "Futures (for basis)", group = g0)
vixSym   = input.symbol("NSE:INDIAVIX", "Volatility index", group = g0)
step     = input.float(50, "Strike step", minval = 0.5, group = g0, tooltip = "Strike spacing. NIFTY = 50.")
atmIn    = input.float(0, "ATM strike (0 = auto)", minval = 0, group = g0, tooltip = "0 auto-anchors ATM from spot at the start of the calc window. Set a value near current spot to pin the ladder manually — most robust, especially on a trending week.")

g1       = "02 · Weekly expiry"
autoExp  = input.bool(true, "Auto next-weekly expiry", group = g1, tooltip = "Auto = the coming weekly-expiry weekday below. NIFTY weekly = Tuesday since Sept 2025. Holidays shift expiry to the prior day; override with the manual date if the auto date is wrong.")
expDay   = input.string("Tuesday", "Weekly expiry weekday", options = ["Monday","Tuesday","Wednesday","Thursday","Friday"], group = g1, tooltip = "NIFTY weekly = Tuesday. BSE Sensex = Thursday. Change here if NSE revises the day again.")
eYY      = input.int(26, "Manual expiry YY", minval = 20, maxval = 99, group = g1)
eMM      = input.int(1,  "Manual expiry MM", minval = 1,  maxval = 12, group = g1)
eDD      = input.int(1,  "Manual expiry DD", minval = 1,  maxval = 31, group = g1)

g2       = "03 · Precision & plan"
ltfMode  = input.string("Auto (finest available)", "Intrabar precision", options = ["Auto (finest available)","Seconds","1-minute","Off"], group = g2, tooltip = "Auto tries seconds (Premium+), falls back to 1-minute, then chart bar. Sharpens the underlying conviction read; degrades cleanly on lower plans.")

g3       = "04 · IV / premium & pin"
ivLen    = input.int(100, "IV percentile window", minval = 20, group = g3)
ivEma    = input.int(14,  "IV slope window", minval = 2, group = g3, tooltip = "Straddle vs its EMA → IV expanding (tailwind) vs crushing (bleed).")
rvLen    = input.int(20,  "Realized-vol window", minval = 5, group = g3, tooltip = "Bars used for realized volatility in the IV-vs-RV (variance-risk-premium) read.")

g4       = "05 · Flow (secondary, gated)"
flowOn   = input.bool(true, "Use directional flow layer", group = g4)
skewGate = input.bool(true, "Gate flow by skew", group = g4, tooltip = "Trust directional flow only when option skew agrees — research: flow predicts returns mainly when the smirk is pronounced.")

g5       = "06 · Underlying character"
basisLen = input.int(20, "Basis / VIX window", minval = 5, group = g5)

g6       = "07 · Calibration harness"
horizon  = input.int(10,  "Forward horizon (bars)", minval = 2, maxval = 100, group = g6)
kATR     = input.float(1.0,"Underlying move (× ATR)", minval = 0.1, step = 0.1, group = g6)
optGain  = input.float(15, "Option-gain test (%)", minval = 1, step = 1, group = g6, tooltip = "An option-outcome 'hit' = the ATM option gains at least this % over the horizon, net of decay.")
gate     = input.float(0.35,"Direction gate", minval = 0.05, maxval = 0.95, step = 0.05, group = g6)
useOptCost = input.bool(true, "Charge round-trip cost to the option test", group = g6, tooltip = "ON: an option-outcome 'hit' must clear the gain threshold PLUS your round-trip cost. Weekly option spreads are wide relative to premium, so a gross winner is often a net loser. Applied to both the signal and the base rate, so the comparison stays fair.")
optCostPct = input.float(4.0, "Round-trip cost (% of premium)", minval = 0.0, maxval = 50.0, step = 0.5, group = g6, tooltip = "Bid-ask spread crossed on entry and exit, plus brokerage and taxes, as a percent of the option premium. On liquid weekly ATM strikes 3-6% is typical; further OTM or illiquid strikes are far worse.")

g7       = "08 · Display & tables"
showGuide= input.bool(true, "Guidance panel (main)", group = g7)
showLadr = input.bool(false,"Option ladder table", group = g7)
showCal  = input.bool(false,"Calibration table", group = g7)
showPin  = input.bool(true, "Draw pin & ATM lines", group = g7)
posGuide = input.string("Top right", "Guidance position", options = ["Top right","Middle right","Bottom right","Top left","Bottom left"], group = g7)
theme    = input.string("Auto","Theme", options = ["Auto","Dark","Light"], group = g7)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                      PALETTE / HELPERS
// ═════════════════════════════════════════════════════════════════════════════════════════
GRN = #2ebd85
RED = #f6465d
YEL = #ffd600
AMB = #ff9800

f_luma(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
isLight  = theme == "Light" or (theme == "Auto" and f_luma(chart.bg_color) > 140)
txtCol   = isLight ? color.new(#0b0f14, 0) : color.new(#e8edf2, 0)
mutCol   = isLight ? color.new(#5b6673, 0) : color.new(#8b95a1, 0)
rowA     = isLight ? color.new(#f2f4f7, 0) : color.new(#11161c, 0)
rowB     = isLight ? color.new(#e7ebf0, 0) : color.new(#171d24, 0)
hdrCol   = isLight ? color.new(#d9dee5, 0) : color.new(#0c1116, 0)
frameCol = isLight ? color.new(#c8cfd8, 0) : color.new(#2a323c, 0)
f_pos(string s) => s == "Top right" ? position.top_right : s == "Middle right" ? position.middle_right : s == "Bottom right" ? position.bottom_right : s == "Top left" ? position.top_left : position.bottom_left
f_2(int v) => (v < 10 ? "0" : "") + str.tostring(v, "0")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  EXPIRY & ATM (session-anchored)
// ═════════════════════════════════════════════════════════════════════════════════════════
string tz = syminfo.timezone
int dowNow = dayofweek(timenow, tz)                 // 1=Sun .. 7=Sat
int targetDow = expDay == "Monday" ? 2 : expDay == "Tuesday" ? 3 : expDay == "Wednesday" ? 4 : expDay == "Thursday" ? 5 : 6
int dToExp = ((targetDow - dowNow) % 7 + 7) % 7
int expTs  = timenow + dToExp * 86400000
int xYY = autoExp ? year(expTs, tz) % 100 : eYY
int xMM = autoExp ? month(expTs, tz)      : eMM
int xDD = autoExp ? dayofmonth(expTs, tz) : eDD
string expStr = f_2(xYY) + f_2(xMM) + f_2(xDD)
// time to expiry (reused by IV normalisation and the theta clock)
int   msToExp  = expTs > timenow ? expTs - timenow : 0
float hrsToExp = msToExp / 3600000.0
float yrsToExp = math.max(msToExp / (1000.0 * 60 * 60 * 24 * 365.0), 1.0 / (365.0 * 24.0))

// ATM frozen ONCE at the start of the calc window, so the auto-built option symbols stay
// constant across history (a per-bar-varying ATM would resolve dozens of tickers and exceed
// Pine's unique-request limit; request symbols must also be simple, not per-bar series). Live
// ATM is shown for reference; set the manual ATM input if the anchor drifts far from spot.
var float atmV = na
if na(atmV)
    atmV := math.round(close / step) * step
float atm = atmIn > 0 ? atmIn : atmV
float atmLive = math.round(close / step) * step
float driftK = na(atm) ? 0.0 : math.abs(atmLive - atm) / step

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  OPTION LADDER (auto-built, na-safe)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_leg(string r, string ex, float strike) =>
    string cs = r + ex + "C" + str.tostring(strike, "0")
    string ps = r + ex + "P" + str.tostring(strike, "0")
    float cp = request.security(cs, timeframe.period, close,  ignore_invalid_symbol = true)
    float cv = request.security(cs, timeframe.period, volume, ignore_invalid_symbol = true)
    float pp = request.security(ps, timeframe.period, close,  ignore_invalid_symbol = true)
    float pv = request.security(ps, timeframe.period, volume, ignore_invalid_symbol = true)
    [cp, cv, pp, pv]

[cm3P, cm3V, pm3P, pm3V] = f_leg(root, expStr, atm - 3 * step)
[cm2P, cm2V, pm2P, pm2V] = f_leg(root, expStr, atm - 2 * step)
[cm1P, cm1V, pm1P, pm1V] = f_leg(root, expStr, atm - 1 * step)
[c0P,  c0V,  p0P,  p0V ] = f_leg(root, expStr, atm)
[cp1P, cp1V, pp1P, pp1V] = f_leg(root, expStr, atm + 1 * step)
[cp2P, cp2V, pp2P, pp2V] = f_leg(root, expStr, atm + 2 * step)
[cp3P, cp3V, pp3P, pp3V] = f_leg(root, expStr, atm + 3 * step)

// coverage (how many legs the plan/market actually served)
f_live(float x) => na(x) ? 0 : 1
int legsLive = f_live(cm3P)+f_live(cm2P)+f_live(cm1P)+f_live(c0P)+f_live(cp1P)+f_live(cp2P)+f_live(cp3P) + f_live(pm3P)+f_live(pm2P)+f_live(pm1P)+f_live(p0P)+f_live(pp1P)+f_live(pp2P)+f_live(pp3P)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  CONTEXT SERIES
// ═════════════════════════════════════════════════════════════════════════════════════════
atr  = ta.atr(14)
fut  = request.security(futSym, timeframe.period, close, ignore_invalid_symbol = true)
vix  = request.security(vixSym, timeframe.period, close, ignore_invalid_symbol = true)
basis = na(fut) ? na : fut - close

// plan-adaptive lower-timeframe underlying volume character
ltfTF = ltfMode == "Seconds" ? "1S" : ltfMode == "1-minute" ? "1" : ltfMode == "Off" ? "" : (timeframe.in_seconds() >= 3600 ? "1" : "1S")
var float upVol = na
var float dnVol = na
if ltfMode != "Off"
    arrC = request.security_lower_tf(syminfo.tickerid, ltfTF, close)
    arrV = request.security_lower_tf(syminfo.tickerid, ltfTF, volume)
    float u = 0.0
    float d = 0.0
    int n = int(math.min(array.size(arrC), array.size(arrV)))
    if n > 1
        for i = 1 to n - 1
            float ch = array.get(arrC, i) - array.get(arrC, i - 1)
            float vv = nz(array.get(arrV, i), 0.0)
            u += ch >= 0 ? vv : 0.0
            d += ch <  0 ? vv : 0.0
    upVol := u
    dnVol := d
float ltfImb = (nz(upVol) + nz(dnVol)) > 0 ? (upVol - dnVol) / (upVol + dnVol) : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  OPTION-DERIVED READS
// ═════════════════════════════════════════════════════════════════════════════════════════
// straddle & IV
float straddle = (na(c0P) or na(p0P)) ? na : c0P + p0P
// Brenner–Subrahmanyam: ATM straddle ≈ 0.8·S·σ·√T ⇒ σ ≈ straddle / (0.8·S·√T).
// Normalising by √T removes the mechanical shrink of the straddle into expiry, so the
// IV percentile reflects genuine implied-vol richness, not just time-to-expiry.
float ivProxy  = na(straddle) ? na : straddle / (0.8 * close * math.sqrt(yrsToExp)) * 100.0
// ta.percentrank and ta.ema are STATEFUL: they must be evaluated on every bar or their
// internal history is broken by the bars they were skipped on. Call them unconditionally
// and mask the result afterwards, rather than calling them inside a ternary.
float ivPctRaw   = ta.percentrank(ivProxy, ivLen)
float ivEmaRaw   = ta.ema(ivProxy, ivEma)
float ivPct    = na(ivProxy) ? na : ivPctRaw
float ivSlope  = na(ivProxy) ? na : ivProxy - ivEmaRaw   // >0 expanding, <0 crush
// variance risk premium: annualized implied (from straddle) vs annualized realized vol.
// IV well above RV = premium expensive (buyer headwind); IV near/below RV = premium cheap.
float rvBar    = ta.stdev(math.log(close / close[1]), rvLen)
float barsPerYr= 5625000.0 / math.max(timeframe.in_seconds(), 1)   // ≈ 375 min/day × 250 days
float rvAnnual = na(rvBar) ? na : rvBar * math.sqrt(barsPerYr) * 100.0
float vrpRatio = (na(ivProxy) or na(rvAnnual) or rvAnnual <= 0) ? na : ivProxy / rvAnnual

// volume PCR + pin
float sumCEv = nz(cm3V)+nz(cm2V)+nz(cm1V)+nz(c0V)+nz(cp1V)+nz(cp2V)+nz(cp3V)
float sumPEv = nz(pm3V)+nz(pm2V)+nz(pm1V)+nz(p0V)+nz(pp1V)+nz(pp2V)+nz(pp3V)
float pcr    = sumCEv > 0 ? sumPEv / sumCEv : na

// pin = strike with the greatest total (CE+PE) volume
f_tot(float a, float b) => nz(a) + nz(b)
var float pinK = na
if barstate.islast
    float best = -1.0
    float bk = atm
    tv = f_tot(cm3V, pm3V)
    if tv > best
        best := tv
        bk := atm - 3*step
    tv := f_tot(cm2V, pm2V)
    if tv > best
        best := tv
        bk := atm - 2*step
    tv := f_tot(cm1V, pm1V)
    if tv > best
        best := tv
        bk := atm - 1*step
    tv := f_tot(c0V, p0V)
    if tv > best
        best := tv
        bk := atm
    tv := f_tot(cp1V, pp1V)
    if tv > best
        best := tv
        bk := atm + 1*step
    tv := f_tot(cp2V, pp2V)
    if tv > best
        best := tv
        bk := atm + 2*step
    tv := f_tot(cp3V, pp3V)
    if tv > best
        best := tv
        bk := atm + 3*step
    pinK := best > 0 ? bk : na

// skew: equidistant OTM put vs OTM call (put richer = downside skew)
float skew = (na(pm2P) or na(cp2P)) ? na : pm2P - cp2P

// delta-weighted signed buyer pressure (bull = CE bought / PE sold ; bear = opposite)
f_press(float p, float pPrev, float v, float w) => (na(p) or na(v) or na(pPrev)) ? 0.0 : (p > pPrev ? v : -v) * w
float ceP = f_press(cm3P,cm3P[1],cm3V,0.3)+f_press(cm2P,cm2P[1],cm2V,0.5)+f_press(cm1P,cm1P[1],cm1V,0.8)+f_press(c0P,c0P[1],c0V,1.0)+f_press(cp1P,cp1P[1],cp1V,0.8)+f_press(cp2P,cp2P[1],cp2V,0.5)+f_press(cp3P,cp3P[1],cp3V,0.3)
float peP = f_press(pm3P,pm3P[1],pm3V,0.3)+f_press(pm2P,pm2P[1],pm2V,0.5)+f_press(pm1P,pm1P[1],pm1V,0.8)+f_press(p0P,p0P[1],p0V,1.0)+f_press(pp1P,pp1P[1],pp1V,0.8)+f_press(pp2P,pp2P[1],pp2V,0.5)+f_press(pp3P,pp3P[1],pp3V,0.3)
float flowRaw = ceP - peP
float flowNorm = (math.abs(ceP) + math.abs(peP)) > 0 ? flowRaw / (math.abs(ceP) + math.abs(peP)) : 0.0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  DIRECTION & VERDICT
// ═════════════════════════════════════════════════════════════════════════════════════════
float priceMom = ta.change(close, 3) / math.max(atr, 1e-9)
float basisChg   = ta.change(basis, basisLen)
float vixChg     = ta.change(vix, basisLen)
float basisPulse = na(basis) ? 0.0 : basisChg / math.max(atr, 1e-9)
bool  vixUp = not na(vix) and vixChg > 0
// flow gated by skew agreement (down-skew supports bearish flow, up-skew bullish) and toggle
bool  skewOK = not skewGate or na(skew) or (flowNorm > 0 and skew <= 0) or (flowNorm < 0 and skew >= 0)
float flowContrib = (flowOn and skewOK) ? flowNorm : 0.0
float ltfContrib = na(ltfImb) ? 0.0 : ltfImb
float dirScore = 0.40 * math.sign(priceMom) * math.min(math.abs(priceMom), 1.0) + 0.25 * math.max(math.min(basisPulse, 1.0), -1.0) + 0.20 * flowContrib + 0.15 * ltfContrib

bool crush = not na(ivSlope) and ivSlope < 0
// theta zone from hours to weekly expiry (msToExp/hrsToExp computed in the expiry section)
string thetaZone = hrsToExp <= 6 ? "EXTREME" : hrsToExp <= 30 ? "HIGH" : hrsToExp <= 78 ? "ELEVATED" : "NORMAL"

bool up = dirScore > gate
bool dn = dirScore < -gate
string verdict = (thetaZone == "EXTREME" and not (up or dn)) ? "AVOID — decay zone, no edge" : (crush and (up or dn)) ? "CAUTION — direction ok, IV bleeding" : (up and not crush) ? "CE-BUYABLE" : (dn and not crush) ? "PE-BUYABLE" : crush ? "AVOID — IV crush / theta trap" : "WAIT — balanced"
color vCol = up and not crush ? GRN : dn and not crush ? RED : (crush or thetaZone == "EXTREME") ? AMB : mutCol

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              CALIBRATION HARNESSES (na-safe, non-repaint)
// ═════════════════════════════════════════════════════════════════════════════════════════
// WILSON 95% LOWER BOUND on a hit rate. A raw Edge is a point estimate: with a
// small sample a +4 pt reading and pure noise look identical. The lower bound
// answers the only question that matters — what is the WORST the hit rate
// plausibly is, given this many observations? Edge LB = wilsonLo(hit) - base.
// Only a POSITIVE lower bound is evidence; a positive point estimate is not.
f_wilsonLo(int hits, int n) =>
    float outv = na
    if n > 0
        float ph = hits / float(n)
        float z  = 1.96
        float ctr = ph + z * z / (2.0 * n)
        float hlf = z * math.sqrt((ph * (1.0 - ph) + z * z / (4.0 * n)) / n)
        outv := math.max(0.0, (ctr - hlf) / (1.0 + z * z / n)) * 100.0
    outv

// A) underlying-side (deep): strong direction → did price travel k·ATR in that direction?
// Both harnesses accumulate ONLY on barstate.isconfirmed so each bar contributes exactly once
// and the live (forming) bar never double-counts across ticks.
var int uN = 0
var int uHit = 0
var int uBaseT = 0
var int uBaseU = 0
var int uBaseD = 0
warmU = bar_index > horizon + basisLen + 20
if barstate.isconfirmed and warmU and not na(close[horizon]) and not na(atr[horizon])
    float thr = kATR * atr[horizon]
    float mv  = close - close[horizon]
    uBaseT += 1
    uBaseU += mv >=  thr ? 1 : 0
    uBaseD += -mv >= thr ? 1 : 0
    float dPast = dirScore[horizon]
    if not na(dPast) and math.abs(dPast) >= gate
        uN += 1
        uHit += (dPast > 0 and mv >= thr) or (dPast < 0 and -mv >= thr) ? 1 : 0
float uHitP  = uN > 0 ? uHit * 100.0 / uN : na
float uBaseP = uBaseT > 0 ? (uBaseU + uBaseD) * 100.0 / (2.0 * uBaseT) : na
float uEdge  = (not na(uHitP) and not na(uBaseP)) ? uHitP - uBaseP : na
float uLo    = f_wilsonLo(uHit, uN)
float uEdgeLB = (not na(uLo) and not na(uBaseP)) ? uLo - uBaseP : na
bool  uProven = not na(uEdgeLB) and uEdgeLB > 0 and uN >= 20

// B) option-outcome (thin): CE/PE-buyable → did the ATM option gain optGain% over horizon?
var int oN = 0
var int oHit = 0
var int oBaseT = 0
var int oBaseH = 0
bool ceSig = verdict == "CE-BUYABLE"
bool peSig = verdict == "PE-BUYABLE"
if barstate.isconfirmed and not na(c0P[horizon]) and not na(p0P[horizon]) and c0P[horizon] > 0 and p0P[horizon] > 0
    // base: unconditional chance either ATM option gains optGain% over horizon
    oBaseT += 1
    // NET of round-trip cost: an option buyer pays spread + brokerage on both
    // legs, expressed as a percent of premium. The gain must clear cost first.
    float needGain = optGain + (useOptCost ? optCostPct : 0.0)
    bool baseHit = (c0P - c0P[horizon]) / c0P[horizon] * 100.0 >= needGain or (p0P - p0P[horizon]) / p0P[horizon] * 100.0 >= needGain
    oBaseH += baseHit ? 1 : 0
    if ceSig[horizon]
        oN += 1
        oHit += (c0P - c0P[horizon]) / c0P[horizon] * 100.0 >= needGain ? 1 : 0
    if peSig[horizon]
        oN += 1
        oHit += (p0P - p0P[horizon]) / p0P[horizon] * 100.0 >= needGain ? 1 : 0
float oHitP  = oN > 0 ? oHit * 100.0 / oN : na
float oBaseP = oBaseT > 0 ? oBaseH * 100.0 / oBaseT : na
float oEdge  = (not na(oHitP) and not na(oBaseP)) ? oHitP - oBaseP : na
float oLo    = f_wilsonLo(oHit, oN)
float oEdgeLB = (not na(oLo) and not na(oBaseP)) ? oLo - oBaseP : na
bool  oProven = not na(oEdgeLB) and oEdgeLB > 0 and oN >= 15

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                  DRAW: pin / ATM lines
// ═════════════════════════════════════════════════════════════════════════════════════════
var line pinLine = na
var line atmLine = na
var label pinLbl = na
if showPin and barstate.islast and not na(atm)
    line.delete(pinLine)
    line.delete(atmLine)
    label.delete(pinLbl)
    int xL = bar_index - 60
    int xR = bar_index + 15
    atmLine := line.new(xL, atm, xR, atm, xloc = xloc.bar_index, color = color.new(mutCol, 30), style = line.style_dotted)
    if not na(pinK)
        pinLine := line.new(xL, pinK, xR, pinK, xloc = xloc.bar_index, color = YEL, width = 2)
        pinLbl  := label.new(xR, pinK, "PIN", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(YEL, 15), textcolor = #0b0f14, size = size.small)

// signal marks
plotshape(up and not crush and not up[1], "CE-buyable", shape.triangleup, location.belowbar, color.new(GRN, 0), size = size.tiny)
plotshape(dn and not crush and not dn[1], "PE-buyable", shape.triangledown, location.abovebar, color.new(RED, 0), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        TABLES
// ═════════════════════════════════════════════════════════════════════════════════════════
f_cell(table t, int c, int r, string s, color tc, color bg, string ha) =>
    table.cell(t, c, r, s, text_size = size.small, text_color = tc, text_halign = ha, bgcolor = bg)

// guidance (main)
var table gT = table.new(f_pos(posGuide), 2, 11, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
if showGuide and barstate.islast
    string ivTxt = na(ivPct) ? "—" : (ivPct > 80 ? "rich " : ivPct < 20 ? "cheap " : "mid ") + str.tostring(ivPct, "0") + "%" + (na(ivSlope) ? "" : ivSlope < 0 ? " ↓crush" : " ↑expand")
    string pcrTxt = na(pcr) ? "—" : str.tostring(pcr, "0.00")
    string pinTxt = na(pinK) ? "—" : str.tostring(pinK, format.mintick) + (na(atm) ? "" : "  (" + str.tostring(pinK - close, "+0;-0") + ")")
    string uEdgeTxt = uN < 20 ? "warming…" : str.tostring(uEdge, "+0.0;-0.0") + " / LB " + str.tostring(uEdgeLB, "+0.0;-0.0") + " (n" + str.tostring(uN) + ")"
    string oEdgeTxt = oN < 15 ? "warming…" : str.tostring(oEdge, "+0.0;-0.0") + " / LB " + str.tostring(oEdgeLB, "+0.0;-0.0") + " (n" + str.tostring(oN) + ")"
    string vrpTxt = na(vrpRatio) ? "—" : str.tostring(vrpRatio, "0.0") + "× RV · " + (vrpRatio > 1.5 ? "rich" : vrpRatio < 1.1 ? "cheap" : "fair")
    color  vrpCol = na(vrpRatio) ? mutCol : vrpRatio > 1.5 ? RED : vrpRatio < 1.1 ? GRN : mutCol
    string vixTxt = na(vix) ? "—" : str.tostring(vix, "0.0") + (vixUp ? "  ↑ expanding" : "  ↓ easing")
    color  vixCol = na(vix) ? mutCol : vixUp ? GRN : AMB
    color tzCol = thetaZone == "EXTREME" ? RED : thetaZone == "HIGH" ? AMB : thetaZone == "ELEVATED" ? YEL : mutCol
    f_cell(gT, 0, 0, "OPTIONS BUYER'S EDGE", txtCol, hdrCol, text.align_left)
    f_cell(gT, 1, 0, "wk " + expStr, txtCol, hdrCol, text.align_right)
    f_cell(gT, 0, 1, "Verdict", mutCol, rowA, text.align_left)
    f_cell(gT, 1, 1, verdict, vCol, rowA, text.align_right)
    f_cell(gT, 0, 2, "Premium (IV)", mutCol, rowB, text.align_left)
    f_cell(gT, 1, 2, ivTxt, na(ivSlope) ? mutCol : ivSlope < 0 ? RED : GRN, rowB, text.align_right)
    f_cell(gT, 0, 3, "Prem vs RV", mutCol, rowA, text.align_left)
    f_cell(gT, 1, 3, vrpTxt, vrpCol, rowA, text.align_right)
    f_cell(gT, 0, 4, "Vol (VIX)", mutCol, rowB, text.align_left)
    f_cell(gT, 1, 4, vixTxt, vixCol, rowB, text.align_right)
    f_cell(gT, 0, 5, "Theta zone", mutCol, rowA, text.align_left)
    f_cell(gT, 1, 5, thetaZone + " (" + str.tostring(hrsToExp, "0") + "h)", tzCol, rowA, text.align_right)
    f_cell(gT, 0, 6, "Pin magnet", mutCol, rowB, text.align_left)
    f_cell(gT, 1, 6, pinTxt, YEL, rowB, text.align_right)
    f_cell(gT, 0, 7, "PCR (vol)", mutCol, rowA, text.align_left)
    f_cell(gT, 1, 7, pcrTxt, txtCol, rowA, text.align_right)
    f_cell(gT, 0, 8, "Dir Edge / LB", mutCol, rowB, text.align_left)
    f_cell(gT, 1, 8, uEdgeTxt, na(uEdge) or uN < 20 ? mutCol : uProven ? GRN : uEdgeLB < -3 ? RED : mutCol, rowB, text.align_right)
    f_cell(gT, 0, 9, "Option Edge / LB", mutCol, rowA, text.align_left)
    f_cell(gT, 1, 9, oEdgeTxt, na(oEdge) or oN < 15 ? mutCol : oProven ? GRN : oEdgeLB < -3 ? RED : mutCol, rowA, text.align_right)
    string cov = "legs " + str.tostring(legsLive) + "/14" + (driftK > 2 ? " · set ATM " + str.tostring(atmLive, "0") : "")
    f_cell(gT, 0, 10, "Coverage", mutCol, rowB, text.align_left)
    f_cell(gT, 1, 10, cov, driftK > 2 ? AMB : mutCol, rowB, text.align_right)

// ladder
var table lT = table.new(position.bottom_right, 3, 8, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
f_ladr(int r, float k, float cp, float pp) =>
    color bg = r % 2 == 0 ? rowA : rowB
    f_cell(lT, 0, r, str.tostring(k, "0"), math.abs(k - atm) < step / 2 ? YEL : mutCol, bg, text.align_left)
    f_cell(lT, 1, r, na(cp) ? "—" : str.tostring(cp, "0.0"), txtCol, bg, text.align_right)
    f_cell(lT, 2, r, na(pp) ? "—" : str.tostring(pp, "0.0"), txtCol, bg, text.align_right)
if showLadr and barstate.islast
    f_cell(lT, 0, 0, "STRIKE", txtCol, hdrCol, text.align_left)
    f_cell(lT, 1, 0, "CE", GRN, hdrCol, text.align_right)
    f_cell(lT, 2, 0, "PE", RED, hdrCol, text.align_right)
    f_ladr(1, atm+3*step, cp3P, pp3P)
    f_ladr(2, atm+2*step, cp2P, pp2P)
    f_ladr(3, atm+1*step, cp1P, pp1P)
    f_ladr(4, atm,        c0P,  p0P)
    f_ladr(5, atm-1*step, cm1P, pm1P)
    f_ladr(6, atm-2*step, cm2P, pm2P)
    f_ladr(7, atm-3*step, cm3P, pm3P)

// calibration
var table cT = table.new(position.bottom_left, 2, 6, border_width = 1, border_color = frameCol, frame_color = frameCol, frame_width = 1)
if showCal and barstate.islast
    f_cell(cT, 0, 0, "CALIBRATION", txtCol, hdrCol, text.align_left)
    f_cell(cT, 1, 0, "tested", txtCol, hdrCol, text.align_right)
    f_cell(cT, 0, 1, "Dir signals (n)", mutCol, rowA, text.align_left)
    f_cell(cT, 1, 1, str.tostring(uN), txtCol, rowA, text.align_right)
    f_cell(cT, 0, 2, "Dir Hit/Base", mutCol, rowB, text.align_left)
    f_cell(cT, 1, 2, uN < 20 ? "warming…" : str.tostring(uHitP,"0")+" / "+str.tostring(uBaseP,"0"), uN < 20 ? mutCol : txtCol, rowB, text.align_right)
    f_cell(cT, 0, 3, "Dir Edge / LB", mutCol, rowA, text.align_left)
    f_cell(cT, 1, 3, uN < 20 ? "warming…" : str.tostring(uEdge,"+0.0;-0.0") + " / " + str.tostring(uEdgeLB,"+0.0;-0.0"), na(uEdge) or uN<20 ? mutCol : uProven ? GRN : uEdgeLB<-3?RED:mutCol, rowA, text.align_right)
    f_cell(cT, 0, 4, "Opt signals (n)", mutCol, rowB, text.align_left)
    f_cell(cT, 1, 4, str.tostring(oN), txtCol, rowB, text.align_right)
    f_cell(cT, 0, 5, "Opt Edge / LB", mutCol, rowA, text.align_left)
    f_cell(cT, 1, 5, oN < 15 ? "warming…" : str.tostring(oEdge,"+0.0;-0.0") + " / " + str.tostring(oEdgeLB,"+0.0;-0.0"), na(oEdge) or oN<15 ? mutCol : oProven ? GRN : oEdgeLB<-3?RED:mutCol, rowA, text.align_right)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(up and not crush and not up[1], "CE-buyable", "Buyer's Edge: CE-buyable — up bias with supportive premium.")
alertcondition(dn and not crush and not dn[1], "PE-buyable", "Buyer's Edge: PE-buyable — down bias with supportive premium.")
alertcondition(crush and not crush[1], "IV crush", "Buyer's Edge: IV crushing — premium bleeding, avoid new long options.")
````
