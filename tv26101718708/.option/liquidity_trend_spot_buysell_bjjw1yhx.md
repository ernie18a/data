# Liquidity & Trend: Spot Buy/Sell

- url: https://www.tradingview.com/script/BjjW1yhX-Liquidity-Trend-Spot-Buy-Sell/
- type: indicator
- pine_id: PUB;176d0fba0dfd441cbc6a6642ffef82fe
- version: 7.0

## Description

[b]Liquidity & Trend: Spot Buy/Sell[/b]

[image]https://www.tradingview.com/x/Yqqht4lU/[/image]

A spot position tool for the daily chart. Long or cash only, no shorting, no leverage. It answers one question: should I be holding this asset right now, or sitting in cash? It does that by reading the global liquidity tide and, for alts, the asset's own price trend, then printing plain BUY and SELL signals.

[b]The idea[/b]

Global liquidity is usually drawn as a line laid over Bitcoin, but the level of money supply next to price is noisy and the relationship drifts in and out. What holds up better is the impulse: the rate of change of liquidity, normalized. This indicator is built entirely on that impulse, and on the long-observed tendency for it to lead Bitcoin by roughly a quarter.

[b]How it works[/b]

Global M2 is built from the M2 money supply of the US, Eurozone, Japan, China, UK and Canada, each converted to USD by its FX rate, then summed.
The impulse: Global M2 is smoothed with a 10-day average, its 90-day rate of change is taken, and that is z-scored against the trailing 365 days. That single z-line is the engine.
Regime: liquidity turns bullish when the impulse z crosses above +0.4 standard deviations and bearish below −0.4, with hysteresis in between and a 14-day confirmation before any flip commits. It is deliberately slow. It is built for cycles, not for days.
Trend leg (for alts): a dual smoothed moving average (Wilder/RMA) cross, lengths 15 and 29, on the chart's own price. It captures the asset's own momentum, which the macro data cannot see.
Minimum hold: one uniform rule for every asset. A position is held at least 2 bars before the opposite signal can fire, which removes next-day round-trip whipsaw on volatile names. It is a structural setting, identical across assets, not tuned per coin.

[b]Three modes[/b]

Liquidity: hold when the liquidity regime is bullish. Best fit for Bitcoin, which tracks the global tide closely.
Trend (SMMA): hold when the price trend is bullish. A pure trend follower for the charted asset.
Combined (OR): hold when either liquidity or price trend is bullish, and move to cash only when both are bearish. Built for altcoins, where the macro read alone is too slow to catch asset-specific moves.
Suggested use: Liquidity mode on BTC, Combined mode on alts.

[image]https://www.tradingview.com/x/ETKALf1p/[/image]

[b]On the chart[/b]

[image]https://www.tradingview.com/x/1V9wvt7j/[/image]

BUY and SELL markers where the position state changes.
Background shading: green when the model says hold, red when it says cash. These signals and the shading always cover the entire chart.
The two trend SMMA lines, colored by direction (optional).
A forward projection ribbon to the right of price: it slides the recent liquidity impulse forward by the lead and paints green for a projected tailwind, red for a projected headwind. It runs on a lightly smoothed version of the raw impulse so it stays earlier than the confirmed signal without flickering. It is context only, since price itself cannot be projected, and it is not a trade trigger.
A live-state table: the active mode, current action, the liquidity state, the price-trend state, the current impulse z, the short-term impulse direction, a three-week z trail, the projected tide, the signal-health status, and days in state.


[b]Signal-health monitor[/b]

Every liquidity relationship eventually decays, so the indicator watches its own edge. It tracks the one-year correlation between the lead-shifted impulse and price momentum, and the two-year gap between average daily returns on liquidity-bullish days versus liquidity-bearish days. If that gap stays negative for a month it flags the model as degraded. The aim is to be told when the relationship stops working, not flattered by it.

[image]https://www.tradingview.com/x/lmFpMWYq/[/image]

[b]Optional backtest[/b]

A simple long-or-cash spot backtest can be switched on in the table (off by default). It shows trades, return, buy-and-hold and max drawdown, measured from a configurable start date (default 2017, the live-data era). It is a basic simulation for context, not a performance promise, and it never affects the buy/sell signals.

[b]Alerts[/b]

BUY signal, SELL signal, liquidity impulse upturn or downturn confirmed (early context, not a trigger), and signal health degraded or recovered.

[b]How to use it[/b]

Run it on the 1D timeframe. Read the green/red state as a position regime, not a precise top or bottom timer. The model confirms turns rather than predicting them, so it tends to be a little late to the exact low and the exact high, by design, in exchange for not whipsawing.

[b]Settings reference[/b]

Impulse window 90 days, smoothing 10 days, z-score window 365 days.
Regime band ±0.4 standard deviations, liquidity confirmation 14 days.
Trend SMMA lengths 15 and 29.
Minimum hold 2 days (uniform anti-whipsaw).
Projection lead 91 days (about 13 weeks), projection smoothing 3 days.
Backtest off by default, with start date, start capital and a per-trade cost.
What it does not do

It does not call tops or bottoms, it does not short or use leverage, and it cannot dodge a one-day shock because the confirmation logic needs more than one bar. It is built for gradual, liquidity-driven cycles and it will sit through deep drawdowns, especially on alts. The macro data updates monthly and on a lag, so treat the liquidity read as a backdrop, not a high-frequency timer.

Originality

Most liquidity tools overlay the level of Global M2 on price. This one works off the impulse, normalizes it into a confirmed regime, fuses that with the asset's own trend for alts, projects the leading edge forward, and monitors whether the liquidity-to-price relationship is still alive. The combination, and the self-check, are the point.

For education and research only. Not financial advice and not a recommendation to buy or sell any asset. Markets are risky and you can lose money. Do your own research.

## Source Code

````pine
//@version=6
indicator("Global Liquidity Crypto Buy/Sell", shorttitle="CryptoLiq", overlay=true, max_bars_back=2000)
// rev 3.5 — trend leg source selectable; DEFAULT = "BTC (market leader)" (2026-08-15) — 2026-08
// tournament (60 configs, train 2020-23 / test 2024-26, mode-ab/results_tournament.txt): BTC's trend
// as the Combined leg beat the alt's own trend on every axis for SOL (full x601 vs x220, test Sharpe
// 0.43 vs 0.33, DD -63 vs -66); alts follow the market leader, whose trend has better signal-to-noise.
// rev 3.4 — renamed for what it is (crypto-only: the liquidity leg needs 24/7 daily bars); plain-
// English table with hover tooltips on every row label; redundant Impulse-z row merged into the
// trail; new "Next signal" row; SMMA lines auto-hidden in pure Liquidity mode.
// rev 3.3 — data-health watchdogs (per-country M2 release calendars, print-spike + ticker-loss detection), bar-close-gated alerts, richer impulse & health rows
// Tested dead ends (2026-08 walk-forward studies — do NOT re-add without new out-of-sample evidence):
// forward lead-shifted execution (destructive at every lead), GLI/M2+CBBS and DXY-adjusted composites,
// ISM gating, shorter or asymmetric confirmation (a 7d confirm sold the COVID-2020 bottom), nowcasting
// the unpublished prints, and 2-of-3 voting with price-trend legs (price legs are bullish at tops by
// construction, so they veto the liquidity leg's early exits as often as they rescue its late ones).
// ─────────── Inputs ───────────
gS = "Signal"
mode     = input.string("Combined (OR)", "Mode", options=["Liquidity", "Trend (SMMA)", "Combined (OR)"], group=gS, tooltip="Liquidity = global-liquidity regime (best on BTC). Trend = dual-SMMA (15/29) cross on this chart's asset (best on alts). Combined = hold if EITHER is bullish, cash only when BOTH bearish (best all-round for alts).")
impLen   = input.int(90,   "Impulse window (RoC, days)", minval=10, group=gS)
smLen    = input.int(10,   "Liquidity smoothing (SMA days)", minval=1, group=gS)
zWin     = input.int(365,  "Z-score window (days)", minval=60, group=gS)
band     = input.float(0.4,"Regime band (±σ)", step=0.1, group=gS)
confDays = input.int(14,   "Liquidity confirmation (days)", minval=0, group=gS)
trFast   = input.int(15,   "Trend fast SMMA", minval=2, group=gS)
trSlow   = input.int(29,   "Trend slow SMMA", minval=3, group=gS)
minHold  = input.int(2,    "Minimum hold (days, uniform anti-whipsaw)", minval=0, group=gS, tooltip="Minimum bars a position is held before the opposite signal can fire. UNIFORM across all assets (no per-asset tuning = no curve-fitting). On daily bars: 2 makes every position last at least ~1 day and removes buy/sell round-trips that reverse the next day; 0 = raw signal; higher = fewer/slower flips. Applied to the FINAL signal, so it is inert where there is no whipsaw (e.g. BTC Liquidity mode).")
gD = "Display"
showBg   = input.bool(true,   "Regime shading (green = hold, red = cash)", group=gD)
showMA   = input.bool(true,   "Show trend SMMA lines", group=gD)
showTbl  = input.bool(true,   "Live-state table", group=gD)
tblPos   = input.string("Top right", "Table position", options=["Top right", "Top center", "Top left", "Middle right", "Middle left", "Bottom right", "Bottom center", "Bottom left"], group=gD, tooltip="Where the live-state stats table sits on the chart.")
showBT   = input.bool(false,  "Backtest rows in table", group=gD, tooltip="OFF by default. Turn ON to add a simple long-or-cash spot backtest (trades, return, buy & hold, max drawdown) to the table. It is a basic simulation for context, not a performance promise. Does NOT affect the buy/sell signals.")
btStart  = input.time(1483228800000, "Backtest start date", group=gD, tooltip="The backtest equity, trade count and drawdown are measured from this date forward. Default = 2017-01-01 (the live-data era for BTC; pre-2017 prices are thin/synthetic). Set it to a cycle start or a recent date to test a window. IMPORTANT: this scopes ONLY the backtest rows. The buy/sell signals and shading always cover the entire chart regardless of this date.")
startCap = input.float(10000, "Backtest start capital ($)", group=gD)
costPct  = input.float(0.1,   "Cost per trade (%)", group=gD) / 100.0
gH = "Health"
showHealth = input.bool(true, "Signal-health monitor", group=gH, tooltip="Continuously tests whether global liquidity still leads THIS chart's asset. Lead correlation = corr(impulse z lead-shifted 91d, asset 90d momentum z, 1y). Regime payoff spread = trailing-2y avg daily return on liquidity-bullish days minus liquidity-bearish days. DEGRADED fires when the spread goes negative for 30 days (never happened 2016-2026 on BTC) or lead-correlation stays below 0 for 90 days while the spread is under 5bp/day. WATCH = early wobble (historically always recovered). Alerts available for DEGRADED and recovery.")
gF = "Data health"
fxStaleLim = input.int(7,  "FX staleness alert (days)", minval=4, group=gF, tooltip="Warn when an FX leg has not printed a new value for this many days. FX prints on weekdays only, so 2-3 day weekend flats are normal on 24/7 crypto charts — never set below 4.")
m2Slack    = input.int(10, "M2 staleness slack (days)", minval=0, group=gF, tooltip="Grace added on top of each country's official release schedule before flagging a leg stale. TV stamps monthly data at the reference-month START; each figure publishes 40-81 days after that stamp, so the freshest print's age normally cycles up to a per-country maximum: US 86d (Fed H.6, 4th Tuesday of the following month), EU 88d (ECB ~month-end), JP 71d (BoJ 9th-14th), CN 99d (PBoC 10th-15th; Jan/Feb prints sometimes bundle mid-March), GB 90d (BoE ~29th), CA 112d (BoC/StatCan ~50 days after month-end). A leg is flagged only when its age exceeds its own baseline + this slack — then the feed has genuinely stalled and is flat-carrying into the composite, silently decaying the impulse z.")
spikeCap   = input.float(15.0, "M2 print spike alert (% MoM)", minval=8, step=1, group=gF, tooltip="Flag a leg when a NEW monthly print differs from the previous print by more than this percentage — far outside any genuine M2 move (the largest real print in this composite's history is ~+6.5% MoM, US April 2020). TV ECONOMICS money-supply series have had documented corruption episodes (JPY, THB); one bad print contaminates the impulse z and its 365-day window for a year. Detection only: the composite and the signal are NEVER auto-corrected.")
trendSrc = input.string("BTC (market leader)", "Trend leg source", options=["This chart", "BTC (market leader)"], group=gS, tooltip="Which price series drives the SMMA trend leg (Trend/Combined modes). BTC (market leader) = default: the trend leg reads BITSTAMP:BTCUSD whatever the chart shows — alts follow the market leader, and BTC's trend has better signal-to-noise than any alt's own price (2026-08 tournament: beat the alt-own-trend leg on every axis for SOL). This chart = classic per-asset behaviour. Irrelevant in pure Liquidity mode. Declared last to keep input ids stable for existing alerts.")

secTF = "1D"   // liquidity always sampled daily; run on a 1D chart
// Liquidity leg is only calendar-consistent on 24/7 assets. On a stock/forex chart the bar
// calendar (~5 days/week) and asset history differ, so the impulse z & regime are NOT comparable.
isCrypto = syminfo.type == "crypto"

// ─────────── Global liquidity = Global M2 (US + EU + JP + CN + GB + CA, FX-adjusted to USD) ───────────
// ignore_invalid_symbol: if TV renames/retires a ticker, the series goes na and the watchdogs below
// flag it — instead of the whole study erroring out, which would also silently kill every alert on it.
sec(string t) => request.security(t, secTF, close, ignore_invalid_symbol=true)
eurusd = sec("FX:EURUSD")
usdjpy = sec("FX:USDJPY")
usdcny = sec("FX_IDC:USDCNY")
gbpusd = sec("FX:GBPUSD")
usdcad = sec("FX_IDC:USDCAD")
us_m2  = sec("ECONOMICS:USM2")
eu_m2  = sec("ECONOMICS:EUM2")
jp_m2  = sec("ECONOMICS:JPM2")
cn_m2  = sec("ECONOMICS:CNM2")
gb_m2  = sec("ECONOMICS:GBM2")
ca_m2  = sec("ECONOMICS:CAM2")
liq = us_m2 + eu_m2 * eurusd + jp_m2 / usdjpy + cn_m2 / usdcny + gb_m2 * gbpusd + ca_m2 / usdcad

// ─────────── Data-health watchdogs: per-feed staleness + total feed loss ───────────
// A feed that stops printing keeps its last value forever (flat-carry), so the impulse z decays
// toward 0 while every row keeps rendering with confidence. Track the age of each input's last print.
ageOf(float s) => nz(ta.barssince(ta.change(s) != 0), bar_index)
ageEURUSD = ageOf(eurusd)
ageUSDJPY = ageOf(usdjpy)
ageUSDCNY = ageOf(usdcny)
ageGBPUSD = ageOf(gbpusd)
ageUSDCAD = ageOf(usdcad)
ageUSM2   = ageOf(us_m2)
ageEUM2   = ageOf(eu_m2)
ageJPM2   = ageOf(jp_m2)
ageCNM2   = ageOf(cn_m2)
ageGBM2   = ageOf(gb_m2)
ageCAM2   = ageOf(ca_m2)
fxAge = math.max(ageEURUSD, ageUSDJPY, ageUSDCNY, ageGBPUSD, ageUSDCAD)
m2Age = math.max(ageUSM2, ageEUM2, ageJPM2, ageCNM2, ageGBM2, ageCAM2)
anyNaFeed = na(eurusd) or na(usdjpy) or na(usdcny) or na(gbpusd) or na(usdcad) or na(us_m2) or na(eu_m2) or na(jp_m2) or na(cn_m2) or na(gb_m2) or na(ca_m2)
var bool everValid = false
if not na(liq)
    everValid := true
// Per-country staleness baselines = researched max normal print age (release calendar + month length)
m2AnyStale = ageUSM2 > 86 + m2Slack or ageEUM2 > 88 + m2Slack or ageJPM2 > 71 + m2Slack or ageCNM2 > 99 + m2Slack or ageGBM2 > 90 + m2Slack or ageCAM2 > 112 + m2Slack
feedStale = everValid and (anyNaFeed or fxAge > fxStaleLim or m2AnyStale)
// Print-spike guard: remember each M2 leg's latest month-over-month print change. Genuine M2 moves
// are a few percent; a decimal-shift or corrupt print is orders of magnitude off and poisons the
// impulse z and its 365-day window for a year. Detection only — the signal is never auto-corrected.
stepPct(float s) =>
    var float p = 0.0
    if ta.change(s) != 0 and not na(s[1]) and s[1] != 0
        p := (s / s[1] - 1) * 100
    p
spUSM2 = stepPct(us_m2)
spEUM2 = stepPct(eu_m2)
spJPM2 = stepPct(jp_m2)
spCNM2 = stepPct(cn_m2)
spGBM2 = stepPct(gb_m2)
spCAM2 = stepPct(ca_m2)
m2SpikeMax = math.max(math.abs(spUSM2), math.abs(spEUM2), math.abs(spJPM2), math.abs(spCNM2), math.abs(spGBM2), math.abs(spCAM2))
m2SpikeFlag = everValid and m2SpikeMax > spikeCap
// Total loss: a dead ticker (with ignore_invalid_symbol) sends liq na; the regime state is var-held
// and FREEZES at its last value. 3 consecutive na bars after a valid history = feed lost, not warmup.
var int liqNaRun = 0
liqNaRun := na(liq) ? liqNaRun + 1 : 0
feedLost = everValid and liqNaRun >= 3
alertcondition(barstate.isconfirmed and feedStale and not feedStale[1], "Liquidity feed STALE", "A liquidity input stopped printing beyond its normal cadence — the impulse z is decaying on flat-carried data. See the Feed health table row for the offending series; verify the feed before acting on liquidity signals.")
alertcondition(barstate.isconfirmed and not feedStale and feedStale[1], "Liquidity feed fresh again", "All liquidity inputs are printing on schedule again.")
alertcondition(barstate.isconfirmed and feedLost and not feedLost[1], "Liquidity feed LOST", "A liquidity data feed stopped resolving (ticker removed or renamed?). The liquidity regime is FROZEN at its last value — BUY/SELL cannot update until the feed is fixed. Check the Feed health table row.")
alertcondition(barstate.isconfirmed and not feedLost and feedLost[1], "Liquidity feed RESTORED", "Liquidity data feed restored; the regime is updating live again.")
alertcondition(barstate.isconfirmed and m2SpikeFlag and not m2SpikeFlag[1], "Liquidity print SPIKE", "An M2 series just printed a month-over-month change far outside any genuine range — likely feed corruption (documented before on TV ECONOMICS). The impulse z and its 365-day window are contaminated until the print is corrected. Check the Feed health row and treat liquidity signals with caution.")
alertcondition(barstate.isconfirmed and not m2SpikeFlag and m2SpikeFlag[1], "Liquidity print normalized", "The spiking M2 series printed back inside its normal range (or the bad print was corrected).")

// ─────────── Liquidity regime: impulse z vs trend, ±band, confirmation ───────────
m2s  = ta.sma(liq, smLen)
prev = m2s[impLen]
roc  = (not na(prev) and prev != 0) ? (m2s - prev) / math.abs(prev) : na
mu   = ta.sma(roc[1], zWin)
sd   = ta.stdev(roc[1], zWin, false)
z    = (not na(roc) and not na(sd) and sd > 0) ? (roc - mu) / sd : na
// LOAD-BEARING STICKINESS: rawreg updates only on a band cross and HOLDS its value inside the band,
// so the confirmation below counts on the sticky state — effectively a fixed 13-bar delay that only
// an opposite-band re-cross aborts. Backtested 2013-2026 this beats strict consecutive-days
// confirmation at every length tested, and confDays=14 beats 7/10/21/28 (a 7-day confirm sold the
// COVID-2020 bottom). Do not "fix" the stickiness or re-tune confDays without walk-forward evidence.
var int rawreg = 0
if not na(z)
    if z > band
        rawreg := 1
    else if z < -band
        rawreg := -1
var int st = 0
var int cand = 0
var int run = 0
if confDays <= 0
    st := rawreg != 0 ? rawreg : st
else if rawreg != 0
    if rawreg == st
        run := 0
        cand := 0
    else if rawreg == cand
        run += 1
        if run >= confDays
            st := rawreg
            run := 0
            cand := 0
    else
        cand := rawreg
        run := 1
reg = st != 0 ? st : rawreg          // +1 liquidity bullish · -1 bearish
liqBull = reg == 1

// ─────────── Impulse direction (early tell): 7d slope of z, 14d confirmation ───────────
// The leading edge: the impulse turns before the confirmed regime does. Shown in the table in words.
zsl = z - z[7]
dirRaw = na(zsl) ? 0 : zsl > 0 ? 1 : zsl < 0 ? -1 : 0
var int dirSt   = 0
var int dirCand = 0
var int dirRun  = 0
if dirRaw != 0
    if dirRaw == dirSt
        dirRun  := 0
        dirCand := 0
    else if dirRaw == dirCand
        dirRun += 1
        if dirRun >= 14
            dirSt   := dirRaw
            dirRun  := 0
            dirCand := 0
    else
        dirCand := dirRaw
        dirRun  := 1
daysDir = ta.barssince(dirSt != dirSt[1])
alertcondition(barstate.isconfirmed and dirSt == 1 and dirSt[1] != 1,   "Impulse upturn confirmed",   "Liquidity impulse upturn confirmed (14d). EARLY TELL only, not a BUY: watch for z to cross +0.4 and hold.")
alertcondition(barstate.isconfirmed and dirSt == -1 and dirSt[1] != -1, "Impulse downturn confirmed", "Liquidity impulse downturn confirmed (14d). Early warning only, not a SELL.")

// ─────────── Signal-health monitor: is liquidity still leading this asset? ───────────
healthLead = 91
roc_b = close[impLen] != 0 ? (close - close[impLen]) / close[impLen] : na
mu_b  = ta.sma(roc_b[1], zWin)
sd_b  = ta.stdev(roc_b[1], zWin, false)
bz    = (not na(roc_b) and not na(sd_b) and sd_b > 0) ? (roc_b - mu_b) / sd_b : na
leadCorr = ta.correlation(z[healthLead], bz, 365)
r1      = close[1] != 0 ? close / close[1] - 1 : 0.0
bullR1  = reg[1] ==  1 ? r1 : 0.0
bearR1  = reg[1] == -1 ? r1 : 0.0
bullN   = math.sum(reg[1] ==  1 ? 1.0 : 0.0, 730)
bearN   = math.sum(reg[1] == -1 ? 1.0 : 0.0, 730)
bullSum = math.sum(bullR1, 730)
bearSum = math.sum(bearR1, 730)
spreadBp = (bullN > 30 and bearN > 30) ? (bullSum / bullN - bearSum / bearN) * 10000 : na
var int corrBadDays   = 0
var int spreadBadDays = 0
corrBadDays   := (not na(leadCorr) and leadCorr < 0) ? corrBadDays + 1 : 0
spreadBadDays := (not na(spreadBp) and spreadBp < 0) ? spreadBadDays + 1 : 0
degraded = spreadBadDays >= 30 or (corrBadDays >= 90 and not na(spreadBp) and spreadBp < 5)
watchHl  = not degraded and ((not na(leadCorr) and leadCorr < 0.2) or (not na(spreadBp) and spreadBp < 10))
plot(leadCorr, "Health: lead correlation (1y)", display=display.data_window)
plot(spreadBp, "Health: regime spread (bp/day, 2y)", display=display.data_window)
alertcondition(barstate.isconfirmed and degraded and not degraded[1], "Signal health DEGRADED", "Liquidity link breakdown: the liquidity regime has stopped paying on this asset (2y bull-bear return spread negative for 30d, or lead-correlation below 0 for 90d with spread under 5bp). Treat liquidity-based signals with caution.")
alertcondition(barstate.isconfirmed and not degraded and degraded[1], "Signal health RECOVERED", "Liquidity link restored: regime payoff spread and lead-correlation back in normal range.")

// ─────────── Trend (dual SMMA cross) on the selected trend source ───────────
btcTrendClose = request.security("BITSTAMP:BTCUSD", timeframe.period, close, ignore_invalid_symbol=true)
trendClose = trendSrc == "BTC (market leader)" ? btcTrendClose : close
smmaF = ta.rma(trendClose, trFast)
smmaS = ta.rma(trendClose, trSlow)
// if the BTC feed ever fails, smmaF/S go na -> trBull false -> Combined degrades to the liquidity leg alone
trBull = not na(smmaF) and not na(smmaS) and smmaF > smmaS

// ─────────── Combine → raw spot hold/cash state, then enforce a uniform minimum hold ───────────
// Liquidity: hold when liqBull · Trend: hold when trBull · Combined: hold if EITHER, cash only if BOTH bearish
rawOn = mode == "Liquidity" ? liqBull : mode == "Trend (SMMA)" ? trBull : (liqBull or trBull)
// minimum-hold: the opposite signal cannot fire until the current position is at least minHold bars old.
var bool posOn   = false
var int  barsHeld = 0
if barstate.isfirst
    posOn := rawOn
    barsHeld := 0
else
    barsHeld += 1
    if rawOn != posOn and barsHeld >= minHold
        posOn := rawOn
        barsHeld := 0
daysIn = ta.barssince(posOn != posOn[1])
var int flipT = na
if posOn != posOn[1]
    flipT := time
buySig  = posOn and not posOn[1]
sellSig = not posOn and posOn[1]
inBt = time >= btStart   // scopes the BACKTEST + trade-count ONLY (signals/shading are full-chart)

// ─────────── Whipsaw meter: total flips + 'quick' flips (segments lasting <= 3 days), within the backtest window ───────────
var int nTrades = 0
var int nQuick  = 0
var int segLen  = 1
if inBt and bar_index > 0
    if posOn != posOn[1]
        nTrades += 1
        if segLen <= 3
            nQuick += 1
        segLen := 1
    else
        segLen += 1

// ─────────── Plots, shading, alerts (FULL CHART) ───────────
// Alerts are gated on barstate.isconfirmed: they evaluate on the daily close only, so an intrabar
// z wiggle from partial FX/M2 data can never fire a phantom push regardless of the alert-dialog mode.
plotshape(buySig,  title="Buy",  style=shape.triangleup,   location=location.belowbar, color=color.new(#10b981, 0), size=size.small, text="BUY",  textcolor=color.white)
plotshape(sellSig, title="Sell", style=shape.triangledown, location=location.abovebar, color=color.new(#ef4444, 0), size=size.small, text="SELL", textcolor=color.white)
bgcolor(showBg ? (posOn ? color.new(#10b981, 90) : color.new(#ef4444, 90)) : na, title="Hold/Cash")
// SMMA lines draw only when the trend leg actually participates (Trend/Combined modes) — in pure
// Liquidity mode they would suggest an input the signal does not use.
plot(showMA and mode != "Liquidity" and trendSrc == "This chart" ? smmaF : na, "Trend SMMA fast (15)", color=trBull ? color.new(#10b981, 0) : color.new(#ef4444, 0), linewidth=2)
plot(showMA and mode != "Liquidity" and trendSrc == "This chart" ? smmaS : na, "Trend SMMA slow (29)", color=color.new(color.gray, 0), linewidth=1)
plot(z, "Liquidity impulse z", display=display.data_window)
alertcondition(barstate.isconfirmed and buySig,  "BUY signal",  "Liquidity & Trend: BUY (enter spot)")
alertcondition(barstate.isconfirmed and sellSig, "SELL signal", "Liquidity & Trend: SELL (move to cash)")

// ─────────── Spot backtest: own the asset while in 'hold' state, cash otherwise (no leverage, no shorting) ───────────
// Measured from btStart forward (default 2017). This block changes NOTHING about the signals above.
held     = posOn[1]
heldPrev = posOn[2]
var float eq     = startCap
var float peakEq = startCap
var float maxDD  = 0.0
var float bh0    = na
var bool  btOn   = false
if inBt
    if not btOn
        btOn   := true
        eq     := startCap
        peakEq := startCap
        maxDD  := 0.0
        bh0    := close
    else
        if held != heldPrev
            eq := eq * (1 - costPct)
        if held
            eq := eq * (1 + (close / close[1] - 1))
        peakEq := math.max(peakEq, eq)
        maxDD  := math.min(maxDD, eq / peakEq - 1)
bhEq = na(bh0) ? startCap : startCap * close / bh0

// ─────────── Live-state + backtest table ───────────
fz(float zz) => na(zz) ? "-" : str.tostring(zz, "0.00")
tPos = tblPos == "Top center" ? position.top_center : tblPos == "Top left" ? position.top_left : tblPos == "Middle right" ? position.middle_right : tblPos == "Middle left" ? position.middle_left : tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom center" ? position.bottom_center : tblPos == "Bottom left" ? position.bottom_left : position.top_right
var table tbl = table.new(tPos, 2, showBT ? 14 : 10, frame_color=color.new(color.gray, 40), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)
if showTbl and barstate.islast
    nowtxt  = posOn ? "HOLDING" : "CASH (await BUY)"
    nowcol  = posOn ? color.new(#10b981, 10) : color.new(#ef4444, 10)
    liqtxt  = feedLost ? "FROZEN (feed lost)" : reg == 1 ? "BULLISH" : reg == -1 ? "BEARISH" : "warming up"
    liqcol  = feedLost ? color.new(#ef4444, 10) : reg == 1 ? color.new(#10b981, 30) : reg == -1 ? color.new(#ef4444, 30) : color.new(color.gray, 40)
    trtxt   = trBull ? "BULLISH" : "BEARISH"
    trcol   = trBull ? color.new(#10b981, 30) : color.new(#ef4444, 30)
    htxt    = degraded ? "DEGRADED" : watchHl ? "WATCH" : "HEALTHY"
    hcol    = degraded ? color.new(#ef4444, 15) : watchHl ? color.new(color.orange, 30) : color.new(#10b981, 45)
    hdet    = (na(leadCorr) ? "" : " · corr " + str.tostring(leadCorr, "0.00")) + (na(spreadBp) ? "" : " · " + (spreadBp >= 0 ? "+" : "") + str.tostring(spreadBp, "0") + "bp/d")
    toFlip  = reg == 1 ? z + band : reg == -1 ? band - z : na
    nxttxt  = na(toFlip) ? "-" : (reg == 1 ? "SELL when z drops to " + str.tostring(-band, "0.0#") : "BUY when z climbs to +" + str.tostring(band, "0.0#")) + " (gap " + str.tostring(toFlip, "0.00") + ") + " + str.tostring(confDays) + "d hold"
    dbase   = dirSt == 1 ? "RISING" : dirSt == -1 ? "FALLING" : "flat"
    formtxt = dirCand != 0 and dirCand != dirSt and dirRun > 0 ? "  ·  " + (dirCand == 1 ? "upturn" : "downturn") + " forming " + str.tostring(dirRun) + "/14d" : ""
    dirtxt  = dbase + (dirSt != 0 ? " · confirmed " + str.tostring(daysDir) + "d ago" : "") + formtxt
    dircol  = dirSt == 1 ? color.new(#10b981, 45) : dirSt == -1 ? color.new(#ef4444, 45) : color.new(color.gray, 50)
    trailtxt = fz(z[21]) + " > " + fz(z[14]) + " > " + fz(z[7]) + " > " + fz(z) + " sd"
    liqmark = isCrypto ? "" : " ⚠"
    liqbg   = isCrypto ? liqcol : color.new(color.orange, 15)
    // Feed health row: name the worst offender relative to its class cadence (FX daily vs M2 monthly)
    fdNames = array.from("EURUSD", "USDJPY", "USDCNY", "GBPUSD", "USDCAD", "USM2", "EUM2", "JPM2", "CNM2", "GBM2", "CAM2")
    fdAges  = array.from(ageEURUSD, ageUSDJPY, ageUSDCNY, ageGBPUSD, ageUSDCAD, ageUSM2, ageEUM2, ageJPM2, ageCNM2, ageGBM2, ageCAM2)
    fdLims  = array.from(fxStaleLim, fxStaleLim, fxStaleLim, fxStaleLim, fxStaleLim, 86 + m2Slack, 88 + m2Slack, 71 + m2Slack, 99 + m2Slack, 90 + m2Slack, 112 + m2Slack)
    fdVals  = array.from(eurusd, usdjpy, usdcny, gbpusd, usdcad, us_m2, eu_m2, jp_m2, cn_m2, gb_m2, ca_m2)
    naList = ""
    worstIdx = 0
    worstRatio = 0.0
    for i = 0 to 10
        if na(array.get(fdVals, i))
            naList := naList + (naList == "" ? "" : ", ") + array.get(fdNames, i)
        r = array.get(fdAges, i) * 1.0 / math.max(array.get(fdLims, i), 1)
        if r > worstRatio
            worstRatio := r
            worstIdx := i
    stalePct = math.min(array.get(fdAges, worstIdx), impLen) * 100.0 / impLen
    spVals  = array.from(math.abs(spUSM2), math.abs(spEUM2), math.abs(spJPM2), math.abs(spCNM2), math.abs(spGBM2), math.abs(spCAM2))
    spSigned = array.from(spUSM2, spEUM2, spJPM2, spCNM2, spGBM2, spCAM2)
    spNames = array.from("USM2", "EUM2", "JPM2", "CNM2", "GBM2", "CAM2")
    spIdx   = math.max(0, array.indexof(spVals, array.max(spVals)))
    feedtxt = feedLost ? "LOST " + str.tostring(liqNaRun) + "d — regime frozen" : naList != "" ? "NA: " + naList : m2SpikeFlag ? "SPIKE: " + array.get(spNames, spIdx) + " " + (array.get(spSigned, spIdx) >= 0 ? "+" : "") + str.tostring(array.get(spSigned, spIdx), "0.0") + "% MoM print" : feedStale ? "STALE: " + array.get(fdNames, worstIdx) + " " + str.tostring(array.get(fdAges, worstIdx)) + "d (" + str.tostring(stalePct, "0") + "% of RoC win)" : "11/11 fresh · oldest M2 " + str.tostring(m2Age) + "d"
    feedcol = feedLost or naList != "" or m2SpikeFlag ? color.new(#ef4444, 10) : feedStale ? color.new(color.orange, 25) : color.new(color.gray, 70)
    table.cell(tbl, 0, 0, "Spot Signal", text_color=color.white, bgcolor=color.new(color.blue, 35), text_size=size.small, tooltip="Which engine drives the buy/sell signal. Liquidity = the global money-supply regime (best on BTC). Trend = price averages on this chart's coin (best on alts). Combined = hold if either is bullish.")
    table.cell(tbl, 1, 0, mode, text_color=color.new(color.white, 10), bgcolor=color.new(color.blue, 35), text_size=size.small)
    table.cell(tbl, 0, 1, "Action now", text_color=color.gray, text_size=size.small, tooltip="The current instruction. HOLDING = own the coin. CASH = stay out and wait for the next BUY.")
    table.cell(tbl, 1, 1, nowtxt, text_color=color.white, bgcolor=nowcol, text_size=size.small)
    table.cell(tbl, 0, 2, "Liquidity", text_color=color.gray, text_size=size.small, tooltip="The confirmed global-liquidity regime. BULLISH = money-supply momentum held above the +0.4 band for 14 days. BEARISH = held below -0.4 for 14 days.")
    table.cell(tbl, 1, 2, liqtxt + liqmark, text_color=color.white, bgcolor=liqbg, text_size=size.small)
    table.cell(tbl, 0, 3, trendSrc == "BTC (market leader)" ? "Price trend · BTC" : "Price trend", text_color=color.gray, text_size=size.small, tooltip="The fast price gauge: 15-day vs 29-day smoothed averages of the selected trend source (this chart, or BTC when the market-leader option is on). It only drives the signal in Trend and Combined modes.")
    table.cell(tbl, 1, 3, trtxt, text_color=color.white, bgcolor=trcol, text_size=size.small)
    table.cell(tbl, 0, 4, "Next signal", text_color=color.gray, text_size=size.small, tooltip="What has to happen before the next BUY/SELL prints: how far the liquidity momentum score (z) still has to travel to reach the band, then how many days it must hold there.")
    table.cell(tbl, 1, 4, nxttxt, text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 5, "Impulse trend", text_color=color.gray, text_size=size.small, tooltip="Which way the liquidity momentum is heading - the early tell that usually turns weeks before the regime flips. A turn needs 14 days to confirm; 'confirmed Nd ago' counts from that confirmation.")
    table.cell(tbl, 1, 5, dirtxt, text_color=color.white, bgcolor=dircol, text_size=size.small)
    table.cell(tbl, 0, 6, "Impulse z (3wk → now)", text_color=color.gray, text_size=size.small, tooltip="Liquidity momentum as a z-score, from three weeks ago through today (rightmost = now). The signal fires on +-0.4 crossings held for 14 days.")
    table.cell(tbl, 1, 6, trailtxt, text_color=color.new(color.white, 15), text_size=size.small)
    table.cell(tbl, 0, 7, "Signal health", text_color=color.gray, text_size=size.small, tooltip="Is global liquidity still leading this coin? corr = 1-year lead correlation (higher is better). bp/d = how much better bullish-regime days have paid than bearish-regime days over the past 2 years.")
    table.cell(tbl, 1, 7, showHealth ? htxt + hdet : "off", text_color=color.white, bgcolor=showHealth ? hcol : color.new(color.gray, 60), text_size=size.small)
    table.cell(tbl, 0, 8, "Days in state", text_color=color.gray, text_size=size.small, tooltip="How long the current HOLDING/CASH state has lasted, and the date it started.")
    table.cell(tbl, 1, 8, str.tostring(daysIn) + "d" + (na(flipT) ? "" : " · since " + str.format_time(flipT, "dd MMM")), text_color=color.white, text_size=size.small)
    table.cell(tbl, 0, 9, "Feed health", text_color=color.gray, text_size=size.small, tooltip="Are all 11 data inputs printing on schedule? Flags stalled feeds, suspicious print spikes (likely data corruption), and dead tickers - the cases where the signal would quietly be running on bad data.")
    table.cell(tbl, 1, 9, feedtxt, text_color=color.white, bgcolor=feedcol, text_size=size.small)
    if showBT
        bttxt = "$" + str.tostring(math.round(eq)) + " (" + (eq >= startCap ? "+" : "") + str.tostring((eq / startCap - 1) * 100, "0") + "%)"
        table.cell(tbl, 0, 10, "Trades (quick <=3d)", text_color=color.gray, text_size=size.small)
        table.cell(tbl, 1, 10, str.tostring(nTrades) + " (" + str.tostring(nQuick) + ")", text_color=color.white, bgcolor=nQuick >= 8 ? color.new(color.orange, 40) : color.new(color.gray, 70), text_size=size.small)
        table.cell(tbl, 0, 11, "Backtest (from " + str.format_time(btStart, "yyyy") + ")", text_color=color.gray, text_size=size.small)
        table.cell(tbl, 1, 11, bttxt, text_color=color.white, text_size=size.small)
        table.cell(tbl, 0, 12, "Buy & Hold", text_color=color.gray, text_size=size.small)
        table.cell(tbl, 1, 12, "$" + str.tostring(math.round(bhEq)), text_color=color.new(color.white, 20), text_size=size.small)
        table.cell(tbl, 0, 13, "Max drawdown", text_color=color.gray, text_size=size.small)
        table.cell(tbl, 1, 13, str.tostring(maxDD * 100, "0") + "%", text_color=color.white, text_size=size.small)

if barstate.islast and timeframe.period != secTF
    label.new(bar_index, high, "Run on the 1D timeframe", style=label.style_label_down, color=color.orange, textcolor=color.black, size=size.small)

if barstate.islast and not isCrypto
    label.new(bar_index, high, "⚠ Liquidity leg is calibrated for 24/7 crypto.\nOn this asset's trading calendar the impulse z and liquidity regime\nare NOT calendar-consistent with other charts — read the liquidity rows with caution.", yloc=yloc.abovebar, style=label.style_label_down, color=color.new(color.orange, 0), textcolor=color.white, size=size.small)
````
