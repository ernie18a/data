# Trident Screener - Stocks, Themes, Sectors [Galin]

- url: https://www.tradingview.com/script/rjYRpGbY-Trident-Screener-Stocks-Themes-Sectors-Galin/
- type: indicator
- pine_id: PUB;27124f68f64d477282dd73ef6b04dc08
- version: 1.0

## Description

Trident Screener

What it does
One screener, three universes. Run it in the Pine Screener on individual stocks, on thematic and industry ETFs, and on the sector SPDRs — same columns, same saved filters, three watchlists. It combines a Minervini-style trend template, an IBD-style weighted relative strength score, a three-condition leadership flag with same-day rotation detection, and setup-ripeness columns: contraction, volume dry-up, extension. Every plot becomes a filterable, sortable column — the answer arrives as a ranked table, not a chart to eyeball.

The columns

Trend
MM — 0 to 8, one point per rule when true: 1) close above the 150 and 200 SMA · 2) 150 SMA above 200 SMA · 3) 200 SMA rising vs 22 bars ago · 4) 50 SMA above the 150 and 200 · 5) close above the 50 SMA · 6) at least 25% above the 260-bar low · 7) within 25% of the 260-bar high · 8) weighted price-momentum composite above 70. Rule 8 uses a price composite, not an IBD-style rating — that job belongs to RS Score below.

Relative strength
RS Score — IBD-style weighted relative strength vs the benchmark, in percentage points: 40% × 3M + 20% × 6M + 20% × 9M + 20% × 12M. Zero means the symbol moves with the benchmark; leaders typically read +20 to +80. It is a margin, not a 0–99 percentile — sorting the column gives you the ranking over your own watchlist, which is the honest version of a ranking anyway.
RS 1W % / RS 1M % / RS 3M % — relative performance vs the benchmark per window, computed as the change of the symbol/benchmark ratio.

Leadership & rotation
A+ — 1/0. Above the 200-day SMA AND beats the benchmark over 1 month AND over 3 months. Each condition catches what the other two miss: a "strong month" inside a downtrend is a bounce, not a leader.
A+ streak — consecutive days with the A+ flag. 1 = promoted today: your rotation alert. Sort descending to rank the most established leaders. Tip: check RS 1W on fresh promotions — a green week means an organic promotion; a deep red week means the calendar just rolled a crash out of the 1-month window.
Improving — above the 200 SMA and beating the benchmark on 1M but not yet on 3M: the waiting room for tomorrow's leaders.

Early accumulation
RS NH — the RS line (symbol ÷ benchmark) is at a 252-bar high.
RS NH lead — RS NH while price is still more than 2% below its own 260-bar high. Relative strength breaking out before price is a classic accumulation tell: someone is buying the base hard enough to outrun the index without a breakout.

Setup ripeness
xFrom50 — extension from the 50 SMA measured in daily ATRs: the "too extended to chase" gauge.
% vs 20SMA — the pullback radar: an extended leader near its 20 SMA is offering an entry instead of demanding a chase.
% from 20D High / % from 60D High — proximity to the recent high and to the base high.
Tight5 (xATR) — the 5-day range measured in ATRs. Small = contraction.
Vol 5D/50D — volume dry-up ratio; below ~0.8 = quiet base.

Suggested setups (set once — filters stick to the indicator)
Stocks: MM = 8 · xFrom50 0 to 4 · % from 60D High −8 to 0 · Tight5 < 3 · Vol 5D/50D < 0.8 → sort RS Score descending. Result: tight, dry leaders sitting just under their highs. Loosen the last three by ~30% for an "almost ready" second pass.
Themes / sectors: A+ = 1 → sort RS Score descending. The row count is a daily breadth curve — log it. A+ streak = 1 → fresh promotions. Improving = 1 → the waiting room.
Weekly: RS NH lead = 1 → the names where the money arrived before the breakout.

Settings
Benchmark — default SPY. Compare sectors vs SPY, growth themes vs QQQ, breadth vs RSP, or a stock vs its own sector ETF.

Notes
Run the screener on the 1D timeframe — required, because A+ streak and RS NH count chart bars, so one bar must equal one day. Plots are hidden on the chart by design; this is a screener tool. All windows are trading days (5/21/63/126/189/252). Symbols younger than ~12 months show empty RS Score cells until the history exists. MM criteria adapted from the Minervini Trend Template by yogy.frestarahmawan (MPL 2.0). Volume confirms what the screener nominates — for entry confirmation, pair it with my Relative Volume At Time indicator.

## Source Code

````pine
//@version=6
// =====================================================================
//  Trident Screener — stocks · themes · sectors, one screener
//
//  Built for the TradingView Pine Screener. Run it on the 1D
//  timeframe (REQUIRED: "A+ streak" and "RS NH" count chart bars,
//  so one chart bar must equal one trading day). Plots are hidden
//  on the chart by design — this is a screener tool: every plot()
//  becomes a filterable, sortable column.
//
//  Columns:
//    MM              0-8 Minervini trend template score, one point
//                    per rule (rules listed inside f_daily below)
//    RS Score        IBD-style weighted relative strength vs the
//                    benchmark, in % points:
//                    40% 3M + 20% 6M + 20% 9M + 20% 12M.
//                    0 = moves with the benchmark. Main sort column.
//    RS 1W/1M/3M %   relative performance vs benchmark per window
//    A+              above the 200 SMA + beats the benchmark on
//                    1M AND 3M
//    A+ streak       consecutive days with the A+ flag (1 = new today)
//    Improving       above the 200 SMA, beats on 1M, not yet on 3M
//    RS NH           RS line (symbol/benchmark) at a 252-bar high
//    RS NH lead      RS NH while price is still >2% under its own
//                    260-bar high — accumulation before the breakout
//    xFrom50         ATR-normalized extension from the 50 SMA
//    % vs 20SMA      pullback radar
//    % from 20D High / % from 60D High   proximity to recent/base high
//    Tight5 (xATR)   5-day range in ATRs (contraction)
//    Vol 5D/50D      volume dry-up
//
//  request.*() budget: 2 of 5 (symbol daily bundle + benchmark).
//  Credits: MM criteria adapted from the Minervini Trend Template
//  by yogy.frestarahmawan (MPL 2.0).
// =====================================================================
indicator("Trident Screener - Stocks, Themes, Sectors [Galin]", shorttitle = "Trident", overlay = false)

string bench = input.symbol("AMEX:SPY", "Benchmark")

// ── Per-symbol daily bundle (request 1 of 2) ─────────────────────────
f_daily() =>
    c = close
    sma20  = ta.sma(c, 20)
    sma50  = ta.sma(c, 50)
    sma150 = ta.sma(c, 150)
    sma200 = ta.sma(c, 200)
    sma200_22 = sma200[22]
    atr14 = ta.atr(14)
    hi260 = ta.highest(high, 260)
    lo260 = ta.lowest(low, 260)

    // Minervini Trend Template — one point per rule when true:
    // 1) close above 150 & 200 SMA     2) 150 SMA above 200 SMA
    // 3) 200 SMA rising vs 22 bars ago 4) 50 SMA above 150 & 200
    // 5) close above 50 SMA            6) >= 25% above 260-bar low
    // 7) within 25% of 260-bar high    8) momentum composite > 70
    // Rule 8 uses a weighted price-momentum composite (13/26/39/52-bar
    // price ratios), not an IBD-style rating — see RS Score for that.
    mom13 = 0.4 * (c / c[13])
    mom26 = 0.2 * (c / (c[26] * 2))
    mom39 = 0.2 * (c / (c[39] * 3))
    mom52 = 0.2 * (c / (c[52] * 4))
    momComposite = (mom13 + mom26 + mom39 + mom52) * 100
    c_1 = (c > sma150) and (c > sma200) ? 1 : 0
    c_2 = sma150 > sma200 ? 1 : 0
    c_3 = sma200 > sma200_22 ? 1 : 0
    c_4 = (sma50 > sma150) and (sma50 > sma200) ? 1 : 0
    c_5 = c > sma50 ? 1 : 0
    c_6 = ((c / lo260) - 1) * 100 >= 25 ? 1 : 0
    c_7 = (1 - (c / hi260)) * 100 <= 25 ? 1 : 0
    c_8 = momComposite > 70 ? 1 : 0
    mm = c_1 + c_2 + c_3 + c_4 + c_5 + c_6 + c_7 + c_8

    atr14_pct   = c > 0 ? atr14 / c * 100 : na
    ma_gain_pct = sma50 > 0 ? (c - sma50) / sma50 * 100 : na
    xfrom50     = atr14_pct > 0 ? ma_gain_pct / atr14_pct : na
    pct20  = sma20 > 0 ? (c / sma20 - 1) * 100 : na
    dHi20  = (c / ta.highest(high, 20) - 1) * 100
    dHi60  = (c / ta.highest(high, 60) - 1) * 100
    tight5 = atr14 > 0 ? (ta.highest(high, 5) - ta.lowest(low, 5)) / atr14 : na
    vdu    = ta.sma(volume, 5) / ta.sma(volume, 50)

    [float(mm), xfrom50, pct20, dHi20, dHi60, tight5, vdu, hi260,
         c, c[5], c[21], c[63], c[126], c[189], c[252], sma200]

[mm, xfrom50, pct20, dHi20, dHi60, tight5, vdu, hi260,
     tC, tC5, tC21, tC63, tC126, tC189, tC252, tS200] =
     request.security(syminfo.tickerid, "D", f_daily(),
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// ── Benchmark (request 2 of 2) ────────────────────────────────────────
[sC, sC5, sC21, sC63, sC126, sC189, sC252] = request.security(bench, "D",
     [close, close[5], close[21], close[63], close[126], close[189], close[252]],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// ── Relative strength vs benchmark ───────────────────────────────────
float rs1w = ((tC / tC5)  / (sC / sC5)  - 1) * 100
float rs1m = ((tC / tC21) / (sC / sC21) - 1) * 100
float rs3m = ((tC / tC63) / (sC / sC63) - 1) * 100

f_rel(float tOld, float sOld) => (tC / tOld) / (sC / sOld) - 1
float rsScore = (0.4 * f_rel(tC63,  sC63)  + 0.2 * f_rel(tC126, sC126) +
                 0.2 * f_rel(tC189, sC189) + 0.2 * f_rel(tC252, sC252)) * 100

// ── A+ / streak / improving ──────────────────────────────────────────
bool above200 = not na(tS200) and tC > tS200
bool aPlus    = above200 and rs1m > 0 and rs3m > 0
bool improv   = above200 and rs1m > 0 and not na(rs3m) and rs3m <= 0

int sinceOff = ta.barssince(not aPlus)
int streak   = aPlus ? sinceOff : 0

// ── RS line new high (chart-scope ratio; needs the 1D timeframe) ─────
float rsLine   = sC > 0 ? tC / sC : na
float rsLineHi = ta.highest(rsLine, 252)
bool  rsNH     = not na(rsLineHi) and rsLine >= rsLineHi
bool  rsNHlead = rsNH and not na(hi260) and tC < hi260 * 0.98

// ── Screener columns ──────────────────────────────────────────────────
plot(mm,               "MM",              display = display.none)
plot(rsScore,          "RS Score",        display = display.none, precision = 1)
plot(rs1w,             "RS 1W %",         display = display.none, precision = 2)
plot(rs1m,             "RS 1M %",         display = display.none, precision = 2)
plot(rs3m,             "RS 3M %",         display = display.none, precision = 2)
plot(aPlus ? 1 : 0,    "A+",              display = display.none)
plot(streak,           "A+ streak",       display = display.none)
plot(improv ? 1 : 0,   "Improving",       display = display.none)
plot(rsNH ? 1 : 0,     "RS NH",           display = display.none)
plot(rsNHlead ? 1 : 0, "RS NH lead",      display = display.none)
plot(xfrom50,          "xFrom50",         display = display.none, precision = 2)
plot(pct20,            "% vs 20SMA",      display = display.none, precision = 2)
plot(dHi20,            "% from 20D High", display = display.none, precision = 2)
plot(dHi60,            "% from 60D High", display = display.none, precision = 2)
plot(tight5,           "Tight5 (xATR)",   display = display.none, precision = 2)
plot(vdu,              "Vol 5D/50D",      display = display.none, precision = 2)
````
