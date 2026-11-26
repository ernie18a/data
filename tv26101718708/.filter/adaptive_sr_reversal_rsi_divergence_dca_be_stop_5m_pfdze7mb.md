# Adaptive S/R Reversal - RSI Divergence + DCA + BE Stop (5m)

- url: https://www.tradingview.com/script/PFdze7mB-Adaptive-S-R-Reversal-RSI-Divergence-DCA-BE-Stop-5m/
- type: strategy
- pine_id: PUB;5b7a307e780647e4aee092b7cd7c844e
- version: 1.0

## Description

Adaptive S/R Reversal - RSI Divergence + DCA + BE Stop (5m)

DESIGNED FOR: BTCUSDT perpetual · 5-minute timeframe · ONLY.
Other symbols and timeframes have not been validated. The script enforces 5m and warns on any other TF.

A 5-minute mean-reversion strategy for BTCUSDT perpetual futures. Fades touches of yesterday's high/low when momentum confirms via fresh RSI divergence. Averages down once if price moves further against, exits at yesterday's midpoint pre-DCA or a fixed % from first entry post-DCA. Closes flat at 20:00 UTC daily — unless the trade is favorable enough to ride overnight (24-hour hard cap).


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STRATEGY LOGIC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ENTRY (no trend bias)
- LONG: 5m bar low touches prev_day low (within 0.05% zone) AND a fresh BULLISH RSI divergence (price LL, RSI HL) was confirmed within the last 20 bars.
- SHORT: 5m bar high touches prev_day high (within 0.05%) AND a fresh BEARISH RSI divergence (price HH, RSI LH) was confirmed within the last 20 bars.
- Both directions allowed regardless of higher-timeframe trend. The divergence + S/R AND-filter is the edge — neither alone is sufficient.

FILTERS
- Volume confirmation: entry bar volume ≥ 1.1× SMA(20)
- Adaptive S/R range: when prev_day range < 2% (squeeze day), expand lookback to a 2-day rolling H/L band so R:R doesn't collapse
- One cycle per UTC day (configurable up to 5)
- Trade window: entries blocked after 20:00 UTC

DCA
- 1 add at worst_entry × (1 ∓ 0.85%) — total 2 legs per cycle
- Sizing: riskPct of equity is split across DCA levels
- Per-leg quantity capped by leverage × equity / close / dcaLevels

EXITS
- TP (hybrid, default): prev_mid × (1 ∓ 0.1%) pre-DCA → switches to firstEntry × (1 ∓ 4%) once DCA fires (avg entry has shifted, post-DCA leg can ride a wider target).
- SL: worst_entry × (1 ∓ 2%) raw. Once BE arms (+1% favorable from first entry), tightens to firstEntry × (1 ± 0.25%) — locks in real ~0.20% net after fees.
- EOD flatten: closes at 20:00 UTC unless trade is ≥ +1.5% favorable from first entry → holds another 24 hours max.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BEST CONFIGURATION (defaults — tested on BTC 5m)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Risk per cycle:        6%       (4% safer / 8% aggressive)
Leverage cap:          2x       (higher amplifies bad days)
DCA levels:            2        (3+ stretches SL distance)
DCA spacing:           0.85%    (tighter burns SL faster)
SL below worst entry:  2.0%     (pairs with BE-stop ON)
S/R touch zone:        0.05%    (wider hurts win rate)
Volume × avg:          1.1×     (1.0 lets more in / 1.5 over-filters)
RSI period:            14       (standard)
Pivot left/right:      5 / 5    (3/3 noise / 7/7 misses)
Divergence freshness:  20 bars  (~100 min on 5m)
Range floor:           2.0%     (below this R:R collapses)
Max lookback (extend): 2 days   (3+ rarely improves)
TP mode:               hybrid   (prev_mid is more conservative)
Post-DCA TP %:         4%       (best balance hit-rate vs win-size)
BE trigger:            1.0%     (earlier over-triggers)
BE buffer:             0.25%    (covers 2× taker fee + slippage)
EOD close hour:        20:00 UTC
Hold-past-EOD:         ON @ 1.5%
Cycles per day:        1        (more = N× SL exposure on trend days)


CONSERVATIVE VARIANT (lower DD)
- Risk per cycle: 4% (was 6%)
- Leverage cap: 1.5x (was 2x)
- SL below worst: 1.5% (was 2.0%)
- TP mode: prev_mid (caps upside)


AGGRESSIVE VARIANT (higher return, higher DD)
- Risk per cycle: 8%
- Leverage cap: 3x
- TP post-DCA: 6% (lets winners run further)
- Hold-past-EOD: ON @ 1.0% (more frequent overnight holds)


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠ REGIME WARNING — READ BEFORE GOING LIVE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The strategy is regime-favorable, not regime-robust.

IT WORKS when daily H/L levels consistently revert to the mid (chop, range-bound markets, mean-reverting volatility).

IT LOSES in strong trending markets where price punches through prev_day levels and keeps going — every losing trend day costs a full SL, and the small mean-reversion wins don't pay for them.

DO NOT size up based on a few good weeks. Paper-trade for at least 2-4 weeks across different regimes before deploying real capital. Short-window backtests are real but NOT predictive — they're regime artifacts.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. BTCUSDT.P (perp) only — params are tuned to BTC's volatility profile. Spot has different funding/fee structure; alts have different ranges.
2. 5m chart only — script enforces this and warns on other TFs.
3. Paper trade first. Use TV alerts → paper account on Binance Futures testnet, or a dedicated paper-trading bot, for at least 2-4 weeks.
4. Watch the on-chart dashboard (top-right) for live state: position, prev levels, active TP/SL, BE status, EOD hold status.
5. Don't change parameters mid-trade. Re-tune only after a full month of data on a new config.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT'S PLOTTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- prev_day Low (dim green dotted)
- prev_day High (dim red dotted)
- prev_day Mid / TP target (cyan dotted)
- Active SL (solid red, 2px)
- Active TP (solid cyan, 2px)
- Avg entry (yellow dotted, after DCA fires)
- 1h EMA(20) (purple, visual reference only — not used for entries)
- Entry triangle markers when L1/S1 conditions fire
- Bull/Bear divergence diamonds at the pivot bar
- Top-right dashboard: position, prev levels, UTC hour, TP mode, filled count, BE status, RSI div age, equity, EOD-hold status


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TESTED + REJECTED (anti-recipes)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

These were tried during development and removed — saving you the experiments:

- Trend bias filter (1h EMA) — blocks 60%+ of valid entries because bias flips against you exactly when price reaches the S/R level.
- RSI anti-extreme filter as primary gate — redundant with divergence.
- Multi-RSI variants (fast 7 / slow 21) — fast fires on noise, slow on stale moves.
- Trailing stop (post-DCA or full trail) — too many false trail-outs near peaks. BE-stop does the job cleaner.
- Wider S/R zone (0.2%) — fires on near-misses, hurts WR.
- SL on candle close (only fire SL when 5m bar closes beyond SL) — saves wick stops but gives more rope on real trends; net negative.
- Multi-cycle per day (2-3 cycles) — same-day re-entries whipsaw on trend days. 1 cycle/day is the validated default.
- Always-in-market flip on every divergence (no S/R touch required) — built and tested; loses. Divergence alone is not an edge.
- Recycling grid sub-strategies — slippage + risk amplification on dip-buy rungs destroy the math.
- Wait-for-HTF-rejection-candle confirm filter — cuts return ~60% for marginal DD improvement.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Backtest results don't predict live performance. Slippage, funding fees, exchange downtime, latency, and live order routing all affect real-world returns. The TradingView backtester assumes intra-bar fills that may not happen in live trading without resting orders.

This script is shared for educational and research purposes. Use it as one input in your own due diligence — never as a turn-key money-printer. Past performance is not indicative of future results, especially for a strategy this regime-dependent.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────
// Adaptive S/R Reversal — RSI Divergence + DCA + BE Stop (5m)
//
// An intraday mean-reversion strategy for BTCUSDT 5m: enter on touches of
// yesterday's high/low when momentum confirms via fresh RSI divergence,
// average down once if price moves further against, exit at yesterday's
// midpoint or a fixed % from first entry post-DCA. Breakeven stop arms at
// +1% favorable. Closes flat at 20:00 UTC daily — unless trade is +1.5%
// favorable, in which case it rides another 24 hours max.
//
// ⚠ DESIGNED FOR: BTCUSDT perpetual · 5-minute timeframe · ONLY.
//
// ─── Logic ───
//   • Entry: 5m low touches prev_day low (LONG) or 5m high touches prev_day
//     high (SHORT) within a 0.05% zone, AND a fresh RSI divergence pivot
//     was confirmed within the last 20 bars (5/5 pivot, RSI(14)).
//   • Filters: volume ≥ 1.1× SMA(20). NO trend bias filter.
//   • Adaptive S/R: when prev-day range < 2% floor, expand lookback to a
//     2-day rolling H/L band so R:R doesn't collapse on inside days.
//   • DCA: 1 add at worst_entry × (1 ∓ 0.85%)
//   • TP (hybrid): prev_mid pre-DCA → first_entry × (1 ∓ 4%) post-DCA
//   • SL: worst_entry × (1 ∓ 2.0%); tightens to first_entry × (1 ± 0.25%)
//     once BE arms at +1% favorable
//   • EOD: close at 20:00 UTC unless favorable ≥ 1.5% (then hold 24h max)
//   • Max 1 entry/exit cycle per UTC day (configurable)
//
// ─── ⚠ Regime warning ───
//   A 5-year Python backtest of this exact logic returned −94% with 30% of
//   months profitable. The strategy is regime-favorable (mean-reverting
//   chop) and breaks down in strong trending markets where price punches
//   through prev_day levels and keeps going. Recent shorter windows can
//   look great but are not a baseline. Paper-trade until validated on
//   YOUR market conditions.
// ─────────────────────────────────────────────────────────────────────

leverageInput = input.float(2.0, "Leverage cap", minval=1, maxval=10, step=0.5)

strategy("Adaptive S/R Reversal — RSI Div + DCA + BE Stop (5m)", overlay=true, initial_capital=5000,
     default_qty_type=strategy.percent_of_equity, default_qty_value=95,
     pyramiding=3, calc_on_order_fills=false, calc_on_every_tick=false,
     process_orders_on_close=true, commission_type=strategy.commission.percent,
     commission_value=0.04, slippage=3,
     margin_long=0, margin_short=0)

// ─── Risk ───
grpRisk = "⚙️ Risk"
riskPct = input.float(6.0, "Total risk per cycle (%)", minval=0.1, maxval=15, step=0.5, group=grpRisk,
     tooltip="% of equity at risk if all DCA legs fill and SL hits. Drop to 4% for safer; raise to 8% for aggressive.") / 100

// ─── DCA ───
grpDCA = "📊 S/R DCA"
dcaLevels    = input.int(2, "DCA levels", minval=1, maxval=5, group=grpDCA,
     tooltip="Number of legs per cycle (1 entry + N-1 adds). 2 (DEFAULT) tested best on 5m BTC.")
dcaSpacing   = input.float(0.85, "DCA spacing (%)", minval=0.3, maxval=3, step=0.05, group=grpDCA,
     tooltip="Distance from worst entry where the next DCA leg fills. Wider = more breathing room before SL distance shortens past it.") / 100
slBelowWorst = input.float(2.0, "SL below worst entry (%)", minval=0.5, maxval=5, step=0.1, group=grpDCA,
     tooltip="With BE-stop ON, looser SL outperforms tight — BE rescues trades that would have noise-stopped tighter.") / 100
supportZone  = input.float(0.05, "S/R entry zone (%)", minval=0.05, maxval=1, step=0.05, group=grpDCA,
     tooltip="How close to prev_H/prev_L the bar high/low must be to count as a touch. 0.05% = direct touches only — selective.") / 100
useEodFlatten = input.bool(true, "Force flatten at EOD UTC hour", group=grpDCA,
     tooltip="ON: position closes at closeHour UTC and entries are blocked past that hour. OFF: position rides until TP or SL — exposes to overnight regime shifts.")
closeHour    = input.int(20, "Force flatten at UTC hour", minval=12, maxval=23, group=grpDCA,
     tooltip="Only used when EOD flatten is ON. 20 is conservative; 23 lets trades work longer.")
holdPastEodIfFav = input.bool(true, "Hold past EOD if favorable", group=grpDCA,
     tooltip="When ON: at closeHour UTC, if trade is favorable ≥ holdMinFavPct from first entry, skip the EOD close and let it ride. Hard-closes at next day's closeHour (24h cap).")
holdMinFavPct = input.float(1.5, "Min favorable % to hold past EOD", minval=0.3, maxval=3.0, step=0.1, group=grpDCA,
     tooltip="Trade must be at least this favorable from first entry to qualify for holding. With BE armed (1% trigger), an overnight reversal exits at first-entry+buffer instead of full SL.") / 100

// ─── Multi-cycle (opt-in) ───
grpReentry = "🔁 Multi-cycle"
maxCyclesPerDay = input.int(1, "Max cycles per UTC day", minval=1, maxval=5, group=grpReentry,
     tooltip="1 (DEFAULT): one entry/exit cycle per UTC day. >1: after exit, allow re-entry on a fresh prev_H/prev_L touch, up to N cycles. Each cycle re-exposes the full SL — one trend day costs N×SL.")

// ─── Quality filters ───
grpFilter = "🎯 Entry Quality Filters"
useVolumeFilter  = input.bool(true, "Require volume confirmation at entry", group=grpFilter)
volMult          = input.float(1.1, "Volume × 20-bar avg", minval=0.5, maxval=3.0, step=0.1, group=grpFilter,
     tooltip="Entry bar volume must exceed this × SMA(volume, 20). With divergence ON the filter is mostly redundant.")

rsiPeriod = input.int(14, "RSI period (for divergence)", minval=5, maxval=30, step=1, group=grpFilter,
     tooltip="RSI lookback used by divergence detection. 14 is standard.")

// ─── RSI Divergence ───
// SHORT at prev_H requires bearish div (price HH, RSI LH).
// LONG  at prev_L requires bullish div (price LL, RSI HL).
grpDiv = "📉 RSI Divergence"
useRsiDivergence = input.bool(true, "Require RSI divergence at S/R", group=grpDiv,
     tooltip="DEFAULT ON. Only fires entry if a fresh divergence pivot was confirmed within divFreshBars. Cuts trade count ~45% but PF more than doubles and DD halves.")
divPivotL    = input.int(5, "Pivot left bars",  minval=1, maxval=10, group=grpDiv,
     tooltip="Bars on the left of the pivot that must be lower (highs) / higher (lows) for it to qualify. 5 catches real swing turns; 3 catches noise.")
divPivotR    = input.int(5, "Pivot right bars", minval=1, maxval=10, group=grpDiv,
     tooltip="Bars on the right that confirm the pivot. 5 = 25 min lag on 5m. Lower confirms faster but pivots can fail to fully form.")
divFreshBars = input.int(20, "Divergence valid for N bars", minval=1, maxval=50, group=grpDiv,
     tooltip="How long after a divergence pivot fires the signal stays usable. 20 = ~100 min on 5m.")

// ─── Adaptive S/R range ───
// On low-range days (prev_day range < floor), prev_mid TP target collapses
// while SL stays full-width — R:R drops below 1. Extend mode widens the
// reference band by rolling N days back until range >= floor.
grpRange = "📏 Adaptive S/R range"
rangeFilterMode = input.string("extend", "Range filter mode", options=["off", "skip", "extend"], group=grpRange,
     tooltip="extend (DEFAULT): when prev_day range < floor, expand lookback to N days until rolling H/L band ≥ floor. off: always use prev_day H/L. skip: gate entries when prev_day range < floor.")
minPrevRangePct = input.float(2.0, "Min prev range (%)", minval=0.5, maxval=5.0, step=0.1, group=grpRange,
     tooltip="Range floor. With 2% SL: 2% range → R:R ~0.5 (break-even at 67% WR); 3% range → R:R ~0.75 (break-even at 58%).") / 100
maxLookbackDays = input.int(2, "Max lookback days (extend mode)", minval=2, maxval=10, group=grpRange,
     tooltip="Cap on how far back to expand the rolling H/L window in extend mode. If even N-day range stays below floor, the widest available is used anyway.")

// ─── Take Profit ───
grpTP = "🎯 Take Profit"
tpMode = input.string("hybrid", "TP target", options=["prev_mid", "hybrid"], group=grpTP,
     tooltip="hybrid (DEFAULT): prev_mid pre-DCA, then switches to firstEntry × (1 ∓ tpPostDcaPct) once DCA fires. prev_mid: yesterday's midpoint, fixed S/R anchor.")
tpPostDcaPct = input.float(4.0, "Hybrid: post-DCA TP distance from first entry (%)", minval=0.1, maxval=10, step=0.1, group=grpTP,
     tooltip="Used by hybrid mode after DCA fires. The post-DCA leg rides further than prev_mid because avg entry has shifted away from prev_mid.") / 100
prevMidOffsetPct = input.float(0.1, "Prev_mid TP offset (%)", minval=-1.0, maxval=1.0, step=0.05, group=grpTP,
     tooltip="Shift the prev_mid TP slightly toward current price for fill reliability. 0.1% = TP fires before exact mid → smaller wins, higher hit rate.") / 100

// ─── Breakeven SL ───
// Locks in profit when fav% > trigger from first entry → SL tightens to
// firstEntry ± buffer. Pairs with looser SL: BE rescues trades that hit
// +1% favorable then reverse, converting "almost wins" into small wins.
grpBE = "🛡️ Breakeven SL"
useBreakeven = input.bool(true, "Enable breakeven SL after favorable threshold", group=grpBE,
     tooltip="DEFAULT ON. Locks in profit when fav% > trigger → SL tightens to firstEntry ± buffer.")
breakevenTriggerPct = input.float(1.0, "BE trigger: favorable % from first entry", minval=0.3, maxval=3.0, step=0.1, group=grpBE,
     tooltip="Once price moves this far in our favor (vs first entry), SL tightens to entry ± buffer. 1.0% = aggressive lock-in; 1.5% = patient.") / 100
breakevenBufferPct = input.float(0.25, "BE buffer above/below entry (%)", minval=0.0, maxval=0.5, step=0.05, group=grpBE,
     tooltip="Tighten SL to firstEntry × (1 ± this%). 0.25% covers ~2× taker fee + slippage cushion → locks in real ~0.20% net profit.") / 100

// ─── Prior day levels ───
// Pre-fetch rolling N-day H/L offsets (1..5). request.security calls are
// always evaluated, but cheap; we only USE the lookback the cascade picks.
// [1] shift ensures the current day's bars never leak in (no lookahead).
prevH1 = request.security(syminfo.tickerid, "1D", high[1], lookahead=barmerge.lookahead_off)
prevL1 = request.security(syminfo.tickerid, "1D", low[1],  lookahead=barmerge.lookahead_off)
prevH2 = request.security(syminfo.tickerid, "1D", ta.highest(high, 2)[1], lookahead=barmerge.lookahead_off)
prevL2 = request.security(syminfo.tickerid, "1D", ta.lowest(low,  2)[1],  lookahead=barmerge.lookahead_off)
prevH3 = request.security(syminfo.tickerid, "1D", ta.highest(high, 3)[1], lookahead=barmerge.lookahead_off)
prevL3 = request.security(syminfo.tickerid, "1D", ta.lowest(low,  3)[1],  lookahead=barmerge.lookahead_off)
prevH4 = request.security(syminfo.tickerid, "1D", ta.highest(high, 4)[1], lookahead=barmerge.lookahead_off)
prevL4 = request.security(syminfo.tickerid, "1D", ta.lowest(low,  4)[1],  lookahead=barmerge.lookahead_off)
prevH5 = request.security(syminfo.tickerid, "1D", ta.highest(high, 5)[1], lookahead=barmerge.lookahead_off)
prevL5 = request.security(syminfo.tickerid, "1D", ta.lowest(low,  5)[1],  lookahead=barmerge.lookahead_off)

// In extend mode, walk the cascade 1→5 and stop at the first lookback whose
// range meets the floor (or the max-lookback cap, whichever comes first).
prevH = prevH1
prevL = prevL1
activeLookback = 1
if rangeFilterMode == "extend"
    if (prevH1 - prevL1) / prevL1 < minPrevRangePct and maxLookbackDays >= 2
        prevH := prevH2
        prevL := prevL2
        activeLookback := 2
        if (prevH2 - prevL2) / prevL2 < minPrevRangePct and maxLookbackDays >= 3
            prevH := prevH3
            prevL := prevL3
            activeLookback := 3
            if (prevH3 - prevL3) / prevL3 < minPrevRangePct and maxLookbackDays >= 4
                prevH := prevH4
                prevL := prevL4
                activeLookback := 4
                if (prevH4 - prevL4) / prevL4 < minPrevRangePct and maxLookbackDays >= 5
                    prevH := prevH5
                    prevL := prevL5
                    activeLookback := 5
prevMid = (prevH + prevL) / 2.0

// 1h EMA — chart display only. Strategy does not gate entries on bias.
hourEmaLen = 20
hourEma    = request.security(syminfo.tickerid, "60", ta.ema(close, hourEmaLen)[1], lookahead=barmerge.lookahead_off)

// ─── Time ───
utcH = hour(time, "UTC")
newDay = ta.change(dayofmonth) != 0

// ─── Filter computations ───
volAvg = ta.sma(volume, 20)
volOk = not useVolumeFilter or volume >= volMult * volAvg

rsiVal = ta.rsi(close, rsiPeriod)

// ─── RSI Divergence detection ───
// Track last 2 confirmed price-pivots (hi/lo) and the RSI value AT that
// pivot bar (which is divPivotR bars behind the confirmation bar).
priceHiPivot = ta.pivothigh(high, divPivotL, divPivotR)
priceLoPivot = ta.pivotlow(low,  divPivotL, divPivotR)

var float lastPHigh = na
var float prevPHigh = na
var float lastRAtH  = na
var float prevRAtH  = na
var float lastPLow  = na
var float prevPLow  = na
var float lastRAtL  = na
var float prevRAtL  = na

if not na(priceHiPivot)
    prevPHigh := lastPHigh
    prevRAtH  := lastRAtH
    lastPHigh := priceHiPivot
    lastRAtH  := rsiVal[divPivotR]

if not na(priceLoPivot)
    prevPLow := lastPLow
    prevRAtL := lastRAtL
    lastPLow := priceLoPivot
    lastRAtL := rsiVal[divPivotR]

bearishDivFired = not na(prevPHigh) and not na(priceHiPivot) and lastPHigh > prevPHigh and lastRAtH < prevRAtH
bullishDivFired = not na(prevPLow)  and not na(priceLoPivot) and lastPLow  < prevPLow  and lastRAtL > prevRAtL

var int barsSinceBearDiv = 9999
var int barsSinceBullDiv = 9999
barsSinceBearDiv := bearishDivFired ? 0 : barsSinceBearDiv + 1
barsSinceBullDiv := bullishDivFired ? 0 : barsSinceBullDiv + 1

bearDivOk = not useRsiDivergence or barsSinceBearDiv <= divFreshBars
bullDivOk = not useRsiDivergence or barsSinceBullDiv <= divFreshBars

prevRangePct = (prevH - prevL) / prevL
rangeOk = rangeFilterMode != "skip" or prevRangePct >= minPrevRangePct

// ─── State ───
var int   filledCount = 0
var float firstEntryPx = na
var float worstEntryPx = na
var float cumNotional = na
var float cumQty      = na
avgEntryPx = na(cumQty) or cumQty == 0 ? na : cumNotional / cumQty
var int   cycleClosedOnDay = -1
var int   cyclesToday = 0
var bool  beActivated = false
// eodHeldOnDay: encoded full date (YYYY*10000 + MM*100 + DD) of the day we
// chose to skip the EOD close. Full-date encoding (not dayofmonth alone)
// avoids false matches when a held trade rides past a month boundary.
var int   eodHeldOnDay = -1

if newDay
    cycleClosedOnDay := -1
    cyclesToday := 0

cycleDone = cycleClosedOnDay == dayofmonth

// ─── Per-level sizing ───
// Total risk = riskPct of equity; worst-case SL distance from L1 = (N-1)*spacing + slBelow
worstSlDistPct = (dcaLevels - 1) * dcaSpacing + slBelowWorst
totalNotional = strategy.equity * 0.95 * riskPct / worstSlDistPct
perLevelQty = totalNotional / close / dcaLevels
qtyCap = (strategy.equity * 0.95 * leverageInput) / close / dcaLevels
perLevelQty := math.min(perLevelQty, qtyCap)

// ─── L1 entry: touch prev_L (longs) or prev_H (shorts), no bias check ───
inEntryWindow = not useEodFlatten or utcH < closeHour
l1LongOk = not cycleDone and strategy.position_size == 0 and inEntryWindow
     and low <= prevL * (1 + supportZone) and low > prevL * (1 - 0.01)
     and volOk and rangeOk and bullDivOk

l1ShortOk = not cycleDone and strategy.position_size == 0 and inEntryWindow
     and high >= prevH * (1 - supportZone) and high < prevH * (1 + 0.01)
     and volOk and rangeOk and bearDivOk

if l1LongOk and perLevelQty > 0
    entryPx = prevL * (1 + supportZone / 2)
    strategy.entry("L1", strategy.long, qty=perLevelQty, limit=entryPx)
    firstEntryPx := entryPx
    worstEntryPx := entryPx
    cumNotional  := entryPx * perLevelQty
    cumQty       := perLevelQty
    filledCount  := 1

if l1ShortOk and perLevelQty > 0
    entryPx = prevH * (1 - supportZone / 2)
    strategy.entry("S1", strategy.short, qty=perLevelQty, limit=entryPx)
    firstEntryPx := entryPx
    worstEntryPx := entryPx
    cumNotional  := entryPx * perLevelQty
    cumQty       := perLevelQty
    filledCount  := 1

// ─── DCA: add next level when price moves spacing% against us ───
if strategy.position_size > 0 and filledCount >= 1 and filledCount < dcaLevels
    nextDcaPx = worstEntryPx * (1 - dcaSpacing)
    if low <= nextDcaPx
        idStr = "L" + str.tostring(filledCount + 1)
        strategy.entry(idStr, strategy.long, qty=perLevelQty, limit=nextDcaPx)
        worstEntryPx := nextDcaPx
        cumNotional  := cumNotional + nextDcaPx * perLevelQty
        cumQty       := cumQty + perLevelQty
        filledCount  := filledCount + 1

if strategy.position_size < 0 and filledCount >= 1 and filledCount < dcaLevels
    nextDcaPx = worstEntryPx * (1 + dcaSpacing)
    if high >= nextDcaPx
        idStr = "S" + str.tostring(filledCount + 1)
        strategy.entry(idStr, strategy.short, qty=perLevelQty, limit=nextDcaPx)
        worstEntryPx := nextDcaPx
        cumNotional  := cumNotional + nextDcaPx * perLevelQty
        cumQty       := cumQty + perLevelQty
        filledCount  := filledCount + 1

// ─── TP + SL ───
// prev_mid offsets shift target slightly toward current price for fill
// reliability. LONG TP is above current → lower it; SHORT TP is below → raise.
prevMidLong  = prevMid * (1 - prevMidOffsetPct)
prevMidShort = prevMid * (1 + prevMidOffsetPct)

// Hybrid TP: prev_mid pre-DCA, switches to firstEntry × (1 ∓ tpPostDcaPct)
// once DCA fires (avg entry has shifted, post-DCA leg can ride further).
tpPostDcaLong  = na(firstEntryPx) ? na : firstEntryPx * (1 + tpPostDcaPct)
tpPostDcaShort = na(firstEntryPx) ? na : firstEntryPx * (1 - tpPostDcaPct)
tpLongHybrid   = (filledCount > 1 and not na(tpPostDcaLong))  ? tpPostDcaLong  : prevMidLong
tpShortHybrid  = (filledCount > 1 and not na(tpPostDcaShort)) ? tpPostDcaShort : prevMidShort

tpLongPx  = tpMode == "hybrid" ? tpLongHybrid : prevMidLong
tpShortPx = tpMode == "hybrid" ? tpShortHybrid : prevMidShort

// BE activation: once favorable% from FIRST entry exceeds the trigger, lock
// SL to firstEntry ± buffer for the rest of this cycle. Once activated stays
// active until cycle resets — a reversal can only exit at BE, not at raw SL.
if useBreakeven and not beActivated and not na(firstEntryPx) and strategy.position_size != 0
    favLong  = (close - firstEntryPx) / firstEntryPx
    favShort = (firstEntryPx - close) / firstEntryPx
    if (strategy.position_size > 0 and favLong  >= breakevenTriggerPct) or (strategy.position_size < 0 and favShort >= breakevenTriggerPct)
        beActivated := true

// SL composition: raw (worst entry × (1 ∓ slBelowWorst)). Once BE is armed,
// tighten to firstEntry ± buffer (whichever is tighter wins).
slLongPxRaw  = worstEntryPx * (1 - slBelowWorst)
slShortPxRaw = worstEntryPx * (1 + slBelowWorst)
slLongPxBE   = na(firstEntryPx) ? na : firstEntryPx * (1 + breakevenBufferPct)
slShortPxBE  = na(firstEntryPx) ? na : firstEntryPx * (1 - breakevenBufferPct)

slLongCandidate  = slLongPxRaw
slShortCandidate = slShortPxRaw
if useBreakeven and beActivated and not na(slLongPxBE)
    slLongCandidate  := math.max(slLongCandidate,  slLongPxBE)
    slShortCandidate := math.min(slShortCandidate, slShortPxBE)
slLongPx  = slLongCandidate
slShortPx = slShortCandidate

if strategy.position_size > 0 and not na(worstEntryPx)
    strategy.exit("xL1", from_entry="L1", limit=tpLongPx, stop=slLongPx)
    if filledCount >= 2
        strategy.exit("xL2", from_entry="L2", limit=tpLongPx, stop=slLongPx)
    if filledCount >= 3
        strategy.exit("xL3", from_entry="L3", limit=tpLongPx, stop=slLongPx)

if strategy.position_size < 0 and not na(worstEntryPx)
    strategy.exit("xS1", from_entry="S1", limit=tpShortPx, stop=slShortPx)
    if filledCount >= 2
        strategy.exit("xS2", from_entry="S2", limit=tpShortPx, stop=slShortPx)
    if filledCount >= 3
        strategy.exit("xS3", from_entry="S3", limit=tpShortPx, stop=slShortPx)

// ─── EOD flatten (with optional conditional hold) ───
// At closeHour UTC: close unless hold-if-fav is enabled and trade is
// favorable ≥ holdMinFavPct AND we haven't already held this trade past
// one EOD. On the day after a hold, eodHeldOnDay no longer matches today
// → force close (24h cap).
todayKey = year(time, "UTC") * 10000 + month(time, "UTC") * 100 + dayofmonth(time, "UTC")
if useEodFlatten and utcH >= closeHour and strategy.position_size != 0
    sameDayAsHold = eodHeldOnDay == todayKey
    if not sameDayAsHold
        canHold = holdPastEodIfFav and eodHeldOnDay == -1 and not na(firstEntryPx)
        favPct = na(firstEntryPx) ? 0.0 : (strategy.position_size > 0 ? (close - firstEntryPx) / firstEntryPx : (firstEntryPx - close) / firstEntryPx)
        if canHold and favPct >= holdMinFavPct
            eodHeldOnDay := todayKey
        else
            strategy.close_all(comment="EOD flatten")

// ─── Cycle reset after exit ───
if strategy.position_size == 0 and strategy.position_size[1] != 0
    cyclesToday := cyclesToday + 1
    eodForced = useEodFlatten and utcH >= closeHour
    if cyclesToday >= maxCyclesPerDay or eodForced
        cycleClosedOnDay := dayofmonth
    filledCount     := 0
    firstEntryPx    := na
    worstEntryPx    := na
    cumNotional     := na
    cumQty          := na
    beActivated     := false
    eodHeldOnDay    := -1

// ─── Visuals ───
plot(prevH, "Prev H",   color=color.new(color.red,   50), style=plot.style_linebr)
plot(prevL, "Prev L",   color=color.new(color.green, 50), style=plot.style_linebr)
plot(prevMid, "Prev Mid (TP)", color=color.new(color.aqua, 30), style=plot.style_linebr)
plot(strategy.position_size != 0 and not na(worstEntryPx)
     ? (strategy.position_size > 0 ? slLongPx : slShortPx) : na,
     "Active SL", color=color.new(color.red, 20), style=plot.style_linebr, linewidth=2)

plot(strategy.position_size != 0 and not na(firstEntryPx)
     ? (strategy.position_size > 0 ? tpLongPx : tpShortPx) : na,
     "Active TP", color=color.new(color.aqua, 0), style=plot.style_linebr, linewidth=2)

plot(strategy.position_size != 0 and not na(avgEntryPx) ? avgEntryPx : na,
     "Avg Entry", color=color.new(color.yellow, 30), style=plot.style_linebr, linewidth=1)

plot(hourEma, "1h EMA", color=color.new(color.purple, 20), linewidth=2)

plotshape(l1LongOk,  "L1",  shape.triangleup,   location.belowbar, color.green, size=size.small)
plotshape(l1ShortOk, "S1",  shape.triangledown, location.abovebar, color.red,   size=size.small)

plotshape(useRsiDivergence and bullishDivFired, "Bull div", shape.diamond, location.belowbar, color.lime,   size=size.tiny, offset=-divPivotR)
plotshape(useRsiDivergence and bearishDivFired, "Bear div", shape.diamond, location.abovebar, color.orange, size=size.tiny, offset=-divPivotR)

wrongTf = timeframe.period != "5"
if barstate.islast and wrongTf
    var table tfWarn = table.new(position.bottom_center, 1, 1, border_width=2, border_color=color.red)
    table.cell(tfWarn, 0, 0,
         "⚠ Chart TF is " + timeframe.period + " — designed for 5m",
         bgcolor=color.new(color.red, 15), text_color=color.white, text_size=size.normal)

// Dashboard
if barstate.islast
    var table dash = table.new(position.top_right, 2, 14, border_width=1)
    table.cell(dash, 0, 0, "Adaptive S/R", bgcolor=color.gray, text_color=color.white)
    table.cell(dash, 1, 0, "5m", bgcolor=color.teal, text_color=color.white)
    table.cell(dash, 0, 1, "EOD")
    table.cell(dash, 1, 1, useEodFlatten ? str.tostring(closeHour) + ":00 UTC" : "OFF", text_color=useEodFlatten ? color.green : color.gray)
    table.cell(dash, 0, 2, "Prev H / L / Mid")
    table.cell(dash, 1, 2, str.tostring(prevL, "#.##") + " / " + str.tostring(prevMid, "#.##") + " / " + str.tostring(prevH, "#.##") + "  (" + str.tostring(activeLookback) + "d, " + str.tostring(prevRangePct*100, "#.##") + "%)")
    table.cell(dash, 0, 3, "UTC hour")
    table.cell(dash, 1, 3, str.tostring(utcH) + ":00")
    table.cell(dash, 0, 4, "TP mode")
    table.cell(dash, 1, 4, tpMode + (tpMode == "hybrid" ? "  post-DCA " + str.tostring(tpPostDcaPct*100, "#.#") + "%" : ""))
    table.cell(dash, 0, 5, "Filled")
    table.cell(dash, 1, 5, str.tostring(filledCount) + "/" + str.tostring(dcaLevels))
    table.cell(dash, 0, 6, "Position")
    table.cell(dash, 1, 6, strategy.position_size > 0 ? "LONG" : strategy.position_size < 0 ? "SHORT" : "FLAT",
         text_color=strategy.position_size > 0 ? color.green : strategy.position_size < 0 ? color.red : color.gray)
    table.cell(dash, 0, 7, "Avg entry")
    table.cell(dash, 1, 7, na(avgEntryPx) ? "—" : str.tostring(avgEntryPx, "#.##"))
    table.cell(dash, 0, 8, "Worst entry")
    table.cell(dash, 1, 8, na(worstEntryPx) ? "—" : str.tostring(worstEntryPx, "#.##"))
    table.cell(dash, 0, 9, "Active TP / SL src")
    tpStr  = strategy.position_size == 0 ? "—" : str.tostring(strategy.position_size > 0 ? tpLongPx : tpShortPx, "#.##")
    slSrc  = strategy.position_size == 0 ? "" : (useBreakeven and beActivated ? "  [BE]" : "")
    table.cell(dash, 1, 9, tpStr + slSrc, text_color=(useBreakeven and beActivated) ? color.yellow : color.aqua)
    table.cell(dash, 0, 10, "Cycles today")
    table.cell(dash, 1, 10, str.tostring(cyclesToday) + "/" + str.tostring(maxCyclesPerDay) + (cycleDone ? " (done)" : ""))
    bearAge = barsSinceBearDiv > divFreshBars ? "—" : str.tostring(barsSinceBearDiv) + "b"
    bullAge = barsSinceBullDiv > divFreshBars ? "—" : str.tostring(barsSinceBullDiv) + "b"
    table.cell(dash, 0, 11, "RSI div (bear/bull)")
    table.cell(dash, 1, 11, useRsiDivergence ? bearAge + " / " + bullAge : "OFF",
         text_color=useRsiDivergence ? color.aqua : color.gray)
    table.cell(dash, 0, 12, "Equity")
    table.cell(dash, 1, 12, "$" + str.tostring(strategy.equity, "#,###"))
    table.cell(dash, 0, 13, "EOD hold")
    eodHoldStatus = not holdPastEodIfFav ? "OFF" : eodHeldOnDay >= 0 ? "HELD (24h cap @ next " + str.tostring(closeHour) + ":00)" : "armed (≥" + str.tostring(holdMinFavPct*100, "#.#") + "%)"
    table.cell(dash, 1, 13, eodHoldStatus,
         text_color=eodHeldOnDay >= 0 ? color.yellow : (holdPastEodIfFav ? color.aqua : color.gray))
````
