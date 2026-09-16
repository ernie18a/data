<!-- tradingview-pine-id: PUB;42c59f1f6eaf4eb9bb2a13788830c8d3 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volume Evidence Dashboard v2

Source: https://www.tradingview.com/script/oizFDff1-Volume-accumulation-distribution-dashboard/

## Description

# Volume Evidence Dashboard — A Complete Guide

## What this is

Most volume indicators give you a squiggly line and leave you to interpret it. This one reads the volume for you and **writes the answer in plain English** — Bullish, Bearish, or Neutral, row by row — with a background color that tells you at a glance whether recent trading has been accumulation (buyers in control) or distribution (sellers in control).

It is a **reading aid for your own judgment**, not a buy/sell signal generator. It tells you who has been winning the volume war. You decide what to do about it.

**One thing to understand up front:** this tool looks *backward*. It reports what already happened over the recent past. It is a rearview mirror, not a windshield. Used that way, it's honest and useful. Expecting it to predict the next move is the one way to misuse it.

---

## The 10-second read

When you load it, look at two things:

1. **The background color.** Green = the recent tape was accumulation. Red = distribution. No color = contested, no clear winner.
2. **The top line of the table.** It states the current regime in words: "ACCUMULATION — last 20 sessions" or "DISTRIBUTION — last 20 sessions."

That's the headline. Everything else is the finer detail behind it.

---

## The background color, explained

The tool looks at the last 20 sessions and asks one question: **did up-day volume or down-day volume dominate?**

- **Green** — up-day volume won. Buyers were more aggressive. Accumulation.
- **Red** — down-day volume won. Sellers were more aggressive. Distribution.
- **No color** — neither side clearly dominated.

Two important properties:

- **It never repaints.** Each day is painted with that day's verdict and stays that way forever. The tool will never quietly rewrite its own history to look smarter — a trap many indicators fall into.
- **It confirms turns late — on purpose.** Because it averages 20 sessions, it typically flips a few weeks *after* the actual bottom or top. This is the cost of a clean signal that doesn't flip-flop on every wiggle. If you want to catch the exact low, this is the wrong tool. If you want to know which side has controlled the last month without second-guessing every candle, this is built for it.

When the regime flips, a small **green triangle** (turned accumulation) or **red triangle** (turned distribution) marks the exact bar.

---

## The dashboard table, row by row

Each row interprets itself. The colored word is the verdict; the number in parentheses is the raw value for when you want it.

**ACCUMULATION / DISTRIBUTION (top line)** — the current regime and the core buy/sell volume ratio. Above ~1 leans accumulation, below ~1 leans distribution (the exact flip points adapt to each stock — see Auto-Calibration below).

**Evidence leaning** — a simple tally: how many rows lean bullish vs bearish right now. It's counting, not predicting. A quick gut-check on the balance of evidence.

**Buying vs selling volume** — the heart of the tool. Over the window, which side moved more shares. This is what drives the background color.

**Today's volume vs normal** — is *today* heavy or light, and in which direction? Reads as "Strong buying," "Strong selling," "Quiet," or "Normal." Heavy volume on an up day is buying; heavy on a down day is selling; the tool sorts that out for you.

**Up days heavier than down days?** — this asks whether up-days are *bigger*, not just more frequent. Genuine accumulation makes up-days heavier. This row often disagrees with "Buying vs selling volume," and **that disagreement is a real signal**: frequent-but-light buying is weaker than the raw ratio suggests.

**Money flow — day to day** — the running direction of net volume (an OBV-style read). Rising or falling.

**Money flow — closing strength** — money flow weighted by *where price closes within each day's range* (an A/D-style read). Here's the useful part: when "day to day" is **rising** but "closing strength" is **falling**, it means buyers are active during the day but sellers are hitting the close. That split is a common, meaningful tell that a rally is being sold into.

**Where price closes in its range** — over the window, are closes landing near the highs (bullish) or the lows (bearish)?

**Heavy selling days (last 25)** — a count of institutional-style down days (a notable drop on above-average volume). Reads "Calm," "Elevated," or "Warning." Five or more is a classic topping caution.

**Scheduled-event day?** — the row that keeps the tool honest. Explained next.

**Flip bands** — shows whether the tool is auto-calibrated to this symbol or using manual bands, and the resolved numbers.

---

## Scheduled-event days (the feature most tools skip)

On certain days, volume is **mechanical plumbing, not sentiment**:

- **Ex-dividend days** — the stock opens lower by the dividend amount automatically. It looks like a red day but means nothing about buying or selling pressure.
- **Options expiration** (every third Friday) and **quarterly witching** (Mar/Jun/Sep/Dec) — volume balloons for structural reasons unrelated to conviction.
- **Index rebalancing** (late June) — one of the highest-volume, least-meaningful days of the year.

The tool detects these days, flags them ("YES — ignore today's numbers"), marks them with a small dot, and **automatically excludes them from every calculation**. This is why a scary-looking ex-dividend candle won't fool it — the math already knows to look away.

*(Ex-dividend detection depends on the data feed carrying dividend info for that symbol; not every symbol provides it.)*

---

## Auto-calibration — why it works on any stock

A sleepy utility and a volatile biotech have completely different normal volume behavior. A fixed threshold that fits one will misread the other.

With **Auto-calibrate** on (the default), the tool measures each stock's *own* buy/sell ratio over a long lookback and sets the flip points relative to that stock's normal range. Load it on any US stock and the bands retune themselves. The "Flip bands" row shows you what it settled on, e.g. "Auto — tuned to KO."

You can turn auto-calibration off and set the bands manually if you prefer a fixed standard across everything.

---

## How to use it — a simple workflow

1. **Use it on the daily chart.** That's where the logic is designed to work. Lower timeframes reinterpret "20 sessions" as "20 bars," which changes the meaning.

2. **Read the regime first** (background + top line), then read the rows for texture. The two "money flow" rows and "up days heavier?" often show the tape improving or weakening *before* the background flips — that's your early read.

3. **Watch for disagreement between the rows and the paint.** Rows leaning green under a red background = accumulation may be quietly building ahead of the flip. Rows leaning red under a green background = control may be slipping. The gap is where the early information lives.

4. **Always combine it with price levels.** This is a volume-context tool, not a standalone system. It tells you *who's winning the volume war*; your own support, resistance, and moving averages tell you *where to act*. When a regime flip lines up with a meaningful price level, that's a far stronger read than either alone.

5. **Respect the scheduled-event flag.** On flagged days, ignore the day's fresh numbers — the tool already discounts them, and you should too.

---

## Honest limitations — please read before trusting it

- **It lags at turns by design.** Expect roughly 2–4 weeks late confirming a major bottom or top. Not a bug — the price of a signal that doesn't whipsaw.
- **It produces false signals.** On a trending stock, expect on the order of one fake regime flip per year — a color change that reverses within weeks. No volume tool is immune. **Your price levels are what protect you when it's wrong.**
- **The finer thresholds were tuned on one stock's history.** The flip bands auto-adapt per symbol, but the row-level cutoffs (what counts as a "heavy selling day," etc.) are sensible defaults, not universally validated constants. Adjust and test on what you trade.
- **Volume analysis describes; it does not predict.** Treat every reading as evidence to weigh, never as an order to follow.
- **US equities only.** The scheduled-event calendar is built for US stocks. Don't rely on it for crypto or futures.

---

## The one-sentence summary

**Green means buyers have controlled the last month, red means sellers have — read it late, pair it with your price levels, ignore the scheduled-event days, and never mistake a description of the past for a prediction of the future.**

*This is a reading aid, not financial advice. It reports on volume; it does not know what happens next. Trade your own plan.*

---

## Source Code

````pine
//@version=6
// ============================================================================
// VOLUME EVIDENCE DASHBOARD v2 — plain-English edition
// ----------------------------------------------------------------------------
// Every row interprets itself in plain words — Bullish / Bearish / Neutral, or
// descriptive labels like Strong buying / Quiet / Calm — colored. Raw numbers
// stay in parentheses for the day you want them.
//
// WHAT'S AUDITED vs WHAT'S A READING AID (be honest with yourself):
//   * The background paint + flip bands (1.25/0.80, 20 sessions) were tested
//     on 11 yrs of MCD daily: ~1 flip per 2 months, green 18-21 trading days
//     after the 2020/2022/2026 lows, one false green (Jun-2026, -6.6%).
//   * The per-row Bullish/Bearish cutoffs are sensible defaults, NOT
//     individually audited. They are reading aids. When rows disagree with
//     the paint, that disagreement is the point — it's the early evidence
//     assembling or deteriorating before the rearview verdict flips.
//
// "SCHEDULED-EVENT DAY" (bottom row): days when volume is calendar plumbing,
// not opinion — monthly options expiration (3rd Friday), quarterly witching
// (Mar/Jun/Sep/Dec), the late-June index rebalance, and ex-dividend days.
// These are excluded from all 20-day sums and marked with a grey dot below the
// bar. Ignore signals printed on them.
//
// PORTABILITY: any liquid US stock, DAILY chart. With "Auto-calibrate" on
// (default), the flip bands retune to each symbol's own volume rhythm using
// the median +/- 0.6 std-dev of its 20-day buy/sell ratio (in log space, so the
// bands are symmetric in ratio terms) over 500 bars — so
// the tool adapts to a sleepy utility and a volatile biotech differently.
// Validation note: on MCD the auto method reproduced the hand-tuned lower
// band (0.79 vs 0.80) and ran slightly wide on the upper (1.48 vs 1.25)
// because MCD's ratio is skewed toward selling — the adaptation is real, not
// cosmetic. NOTE: those figures were measured against the earlier MEAN-based
// calibration; the center is now a true median (more outlier-robust) and the
// exact bands need re-measuring on MCD. The scheduled-event calendar is US-equities-specific; do not
// trust it on crypto/futures. Thresholds beyond the bands were audited on
// MCD only — reasonable defaults elsewhere until you test them.
// ============================================================================
indicator("Volume Evidence Dashboard v2", overlay=true, max_labels_count=200)

// ---------- inputs ----------
lenWin   = input.int(20,    "Window (sessions) — audited on DAILY", minval=10)
autoCal  = input.bool(true, "Auto-calibrate flip bands to THIS symbol", group="Flip bands")
calLook  = input.int(500,   "Auto-calibration lookback (bars)", minval=100, group="Flip bands")
calWidth = input.float(0.6, "Auto-calibration width (× std-dev)", step=0.05, minval=0.3, maxval=1.2, group="Flip bands")
hiBandM  = input.float(1.25, "Manual: GREEN when buy/sell vol >=", step=0.05, group="Flip bands")
loBandM  = input.float(0.80, "Manual: RED when buy/sell vol <=", step=0.05, group="Flip bands")
confirmN = input.int(3,     "Confirmation bars for the paint", minval=1)
lenRV    = input.int(21,    "Normal-volume average length", minval=5)
showTbl  = input.bool(true,  "Show dashboard table")
showMech = input.bool(true,  "Shade scheduled-event days")
useDivs  = input.bool(true,  "Use dividend calendar if the feed provides it")

// ---------- scheduled-event days ----------
isFri    = dayofweek == dayofweek.friday
thirdFri = isFri and dayofmonth >= 15 and dayofmonth <= 21
isRecon  = month == 6 and isFri and dayofmonth >= 22 and dayofmonth <= 28   // 4th Friday of June
divAmt   = useDivs ? request.dividends(syminfo.tickerid, dividends.gross, barmerge.gaps_on) : na
isMech   = thirdFri or isRecon or not na(divAmt)
plotshape(showMech and isMech, "Scheduled-event day", shape.circle, location.belowbar, color.new(color.gray, 40), size=size.tiny)

// ---------- measurements ----------
chg     = ta.change(close)
vUp     = (chg > 0 and not isMech) ? volume : 0.0
vDn     = (chg < 0 and not isMech) ? volume : 0.0
sumUp   = math.sum(vUp, lenWin)
sumDn   = math.sum(vDn, lenWin)
udRatio = sumUp / math.max(sumDn, 1.0)

// ---------- self-calibration: bands adapt to THIS symbol's own history ----------
// Uses the log of the ratio (its natural scale) so the up/down bands are
// symmetric in ratio space. Median +/- (width * std-dev) over calLook bars.
logR      = udRatio > 0 ? math.log(udRatio) : na
logCenter = ta.percentile_linear_interpolation(logR, calLook, 50)  // true median (50th pct); was ta.sma = mean
logSd     = ta.stdev(logR, calLook)
hiBandA   = math.exp(logCenter + calWidth * logSd)
loBandA   = math.exp(logCenter - calWidth * logSd)
// Gate on the bands actually being computable, not a raw bar count. ta.median/
// ta.stdev return na until calLook valid observations exist, so this also fixes
// the old off-by-one (bar_index >= calLook) and the na-band blackout.
warmedUp  = not na(hiBandA) and not na(loBandA)
hiBand    = autoCal and warmedUp ? hiBandA : hiBandM
loBand    = autoCal and warmedUp ? loBandA : loBandM

avgVol  = ta.sma(volume, lenRV)[1]                     // prior-bar baseline: today isn't in its own "normal"
relVol  = avgVol > 0 ? volume / avgVol : na            // guard: no divide-by-zero on dead feeds
rng     = high - low
clv     = rng > 0 ? (2 * close - high - low) / rng : 0.0
// CLV now excludes scheduled-event bars from BOTH numerator and denominator,
// matching the header claim that mechanical days are dropped from 20-day sums.
clvVolC = not isMech ? clv * volume : 0.0
volClean = not isMech ? volume : 0.0
vwCLV   = math.sum(clvVolC, lenWin) / math.max(math.sum(volClean, lenWin), 1.0)
nUp     = math.sum(chg > 0 and not isMech ? 1 : 0, lenWin)
nDn     = math.sum(chg < 0 and not isMech ? 1 : 0, lenWin)
gDen    = nDn > 0 ? sumDn / nDn : na
gOverR  = nUp > 0 and not na(gDen) and gDen > 0 ? (sumUp / nUp) / gDen : na
// OBV and A/D rebuilt as custom accumulators so scheduled-event bars add nothing.
// The 20-bar change (x - x[lenWin]) then genuinely excludes mechanical volume,
// unlike ta.obv / ta.accdist which accumulate every bar.
var float obvClean = 0.0
obvClean := obvClean + (isMech ? 0.0 : (chg > 0 ? volume : chg < 0 ? -volume : 0.0))
var float adClean = 0.0
adClean := adClean + (isMech ? 0.0 : clv * volume)
obvSl   = obvClean - obvClean[lenWin]
adSl    = adClean - adClean[lenWin]
isDD    = close[1] > 0 and chg / close[1] < -0.002 and volume > volume[1] and relVol > 1.0 and not isMech
distCnt = math.sum(isDD ? 1 : 0, 25)

// ---------- rearview paint (the audited part) ----------
var int regime = 0
var int pend   = 0
var int pc     = 0
// Only count a window as evidence if it actually contains up/down volume;
// an empty (all-flat / all-mechanical) window must not read as distribution.
hasEvid = (sumUp + sumDn) > 0
cand = not hasEvid ? regime : udRatio >= hiBand ? 1 : udRatio <= loBand ? -1 : regime
// Advance the state machine only on confirmed (closed) bars so the paint and
// flip signals do not repaint intrabar ("rearview" is only true on closed bars),
// and never on scheduled-event bars so flips don't print on days to ignore.
if barstate.isconfirmed and not isMech
    if cand != regime
        if cand == pend
            pc += 1
        else
            pend := cand
            pc := 1
        if pc >= confirmN
            regime := cand
            pend := 0
            pc := 0
    else
        pend := 0
        pc := 0
flipUp = regime == 1  and regime[1] != 1
flipDn = regime == -1 and regime[1] != -1
bgcolor(regime == 1 ? color.new(color.green, 86) : regime == -1 ? color.new(color.red, 88) : na, title="Regime tint")
plotshape(flipUp, "Turned ACCUMULATION (rearview)", shape.triangleup,   location.belowbar, color.new(color.lime, 0), size=size.small)
plotshape(flipDn, "Turned DISTRIBUTION (rearview)", shape.triangledown, location.abovebar, color.new(color.red, 0),  size=size.small)

// ---------- verdicts ----------
cBull = color.lime
cBear = color.rgb(255, 82, 82)
cNeut = color.silver
cWarn = color.orange
cBg   = color.rgb(15, 15, 38)
cBgSt = regime == 1 ? color.new(color.green, 55) : regime == -1 ? color.new(color.red, 50) : color.new(color.gray, 55)
fmt(x) => str.tostring(x, "#.##")
vmap(v) => [v == 1 ? "Bullish" : v == -1 ? "Bearish" : "Neutral", v == 1 ? cBull : v == -1 ? cBear : cNeut]

vRatio = udRatio >= hiBand ? 1 : udRatio <= loBand ? -1 : 0
vGvR   = na(gOverR) ? 0 : gOverR > 1.05 ? 1 : gOverR < 0.95 ? -1 : 0
vObv   = na(obvSl) ? 0 : obvSl > 0 ? 1 : obvSl < 0 ? -1 : 0   // flat/na is neutral, not bearish
vAd    = na(adSl) ? 0 : adSl > 0 ? 1 : adSl < 0 ? -1 : 0
vClv   = vwCLV > 0.10 ? 1 : vwCLV < -0.10 ? -1 : 0
vDD    = distCnt >= 5 ? -1 : 0    // absence of distribution is not bullish evidence
vRv    = (not isMech and relVol > 1.3) ? (close > open ? 1 : close < open ? -1 : 0) : 0
[tRatio, kRatio] = vmap(vRatio)
[tGvR,   kGvR]   = vmap(vGvR)
[tObv,   kObv]   = vmap(vObv)
[tAd,    kAd]    = vmap(vAd)
[tClv,   kClv]   = vmap(vClv)
tRv = isMech ? "Scheduled - ignore" : relVol > 1.3 and close > open ? "Strong buying" : relVol > 1.3 and close < open ? "Strong selling" : relVol < 0.8 ? "Quiet" : "Normal"
kRv = isMech ? cNeut : relVol > 1.3 and close > open ? cBull : relVol > 1.3 and close < open ? cBear : cNeut
tDD = distCnt >= 5 ? "Warning" : distCnt >= 3 ? "Elevated" : "Calm"
kDD = distCnt >= 5 ? cBear : distCnt >= 3 ? cWarn : cBull
nB  = (vRatio == 1 ? 1 : 0) + (vRv == 1 ? 1 : 0) + (vGvR == 1 ? 1 : 0) + (vObv == 1 ? 1 : 0) + (vAd == 1 ? 1 : 0) + (vClv == 1 ? 1 : 0)
nS  = (vRatio == -1 ? 1 : 0) + (vRv == -1 ? 1 : 0) + (vGvR == -1 ? 1 : 0) + (vObv == -1 ? 1 : 0) + (vAd == -1 ? 1 : 0) + (vClv == -1 ? 1 : 0) + (vDD == -1 ? 1 : 0)

// ---------- table ----------
var table t = table.new(position.top_right, 2, 11, border_width=1, border_color=color.rgb(60, 60, 90))
if barstate.islast and showTbl
    stTxt = regime == 1 ? "ACCUMULATION — last " + str.tostring(lenWin) + " sessions" : regime == -1 ? "DISTRIBUTION — last " + str.tostring(lenWin) + " sessions" : "CONTESTED — no side dominant"
    table.cell(t, 0, 0, stTxt, bgcolor=cBgSt, text_color=color.white)
    table.cell(t, 1, 0, "(" + fmt(udRatio) + ")", bgcolor=cBgSt, text_color=color.white)
    table.cell(t, 0, 1, "Evidence leaning", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(nB) + " bullish / " + str.tostring(nS) + " bearish", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "Buying vs selling volume", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, tRatio + " (" + fmt(udRatio) + ")", bgcolor=cBg, text_color=kRatio, text_size=size.small)
    table.cell(t, 0, 3, "Today's volume vs normal", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, tRv + " (" + fmt(relVol) + "x)", bgcolor=cBg, text_color=kRv, text_size=size.small)
    table.cell(t, 0, 4, "Up days heavier than down days?", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, tGvR + " (" + (na(gOverR) ? "-" : fmt(gOverR)) + ")", bgcolor=cBg, text_color=kGvR, text_size=size.small)
    table.cell(t, 0, 5, "Money flow — day to day", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, tObv, bgcolor=cBg, text_color=kObv, text_size=size.small)
    table.cell(t, 0, 6, "Money flow — closing strength", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 6, tAd, bgcolor=cBg, text_color=kAd, text_size=size.small)
    table.cell(t, 0, 7, "Where price closes in its range", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 7, tClv + " (" + fmt(vwCLV) + ")", bgcolor=cBg, text_color=kClv, text_size=size.small)
    table.cell(t, 0, 8, "Heavy selling days (last 25)", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 8, tDD + " (" + str.tostring(distCnt, "#") + ")", bgcolor=cBg, text_color=kDD, text_size=size.small)
    table.cell(t, 0, 9, "Scheduled-event day?", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 9, isMech ? "YES — ignore today's numbers" : "No — clean read", bgcolor=cBg, text_color=isMech ? cWarn : cNeut, text_size=size.small)
    calTxt = autoCal and warmedUp ? "Auto — tuned to " + syminfo.ticker : autoCal ? "Auto — warming up, using manual" : "Manual"
    table.cell(t, 0, 10, "Flip bands", bgcolor=cBg, text_color=color.white, text_size=size.small)
    table.cell(t, 1, 10, calTxt + " (" + fmt(hiBand) + " / " + fmt(loBand) + ")", bgcolor=cBg, text_color=cNeut, text_size=size.small)

// ---------- alerts ----------
alertcondition(flipUp, "Turned ACCUMULATION", "Rearview regime flipped GREEN — last 20 sessions net accumulation")
alertcondition(flipDn, "Turned DISTRIBUTION", "Rearview regime flipped RED — last 20 sessions net distribution")
````
