<!-- tradingview-pine-id: PUB;1c24f08d969e405c8c92defbfe252f4e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Regime — nqstats

Source: https://www.tradingview.com/script/90O8rh4b-Market-Regime-NQStats/

## Description

Market Regime — nqstats

A volatility-regime dashboard for NQ (and any symbol). It answers one question: is the market currently moving more, or less, than its own long-term normal — and is that changing? It does not predict direction. It describes the character and intensity of price movement, so you can size positions, place stops, and pick strategies that suit the current environment.

The methodology follows the market-regime framework described at nqstats.com/market_regimes. Big thanks to Chris for publishing this research and full credit to him for this concept. This indicator is simply an independent implementation of that concept, built for TradingView.

1. What it does

Markets cycle between calmer and more turbulent phases. A regime measure captures where you are in that cycle by comparing current volatility against a long-term baseline volatility:

- Ratio above 1.0 → Elevated regime. Moves are larger than normal.
- Ratio below 1.0 → Compressed regime. Moves are smaller than normal.

Knowing the regime matters because most strategies are implicitly tuned to a particular volatility environment. Running a breakout system in a compressed, range-bound regime — or a mean-reversion system in an elevated, trending one — is a common reason live results drift from a backtest. The indicator is a filter and a context tool, not a signal generator.

The output is a compact, monospace, monochrome table — there is no plotted line. That is deliberate: the regime is a daily-returns statistic, so the numbers are identical whether you view them on a 5-minute or a daily chart (see §2). A table reads cleanly on every timeframe; a plotted line would only be meaningful on the daily.

2. How it's calculated (and why)

Return series. It works from daily log returns: ln(close / previous close). Log returns are the standard choice for volatility work — they're additive across time and symmetric around zero. (A simple-returns toggle is provided if you prefer.)

Rolling volatility (the "now"). For each lookback window, it takes the standard deviation of those daily returns. A 10-day SD reflects the last ~2 weeks; a 50-day SD reflects the last ~2.5 months. Each is a snapshot of realized volatility at that horizon.

Baseline volatility (the "normal"). It takes the standard deviation of the same daily-return series over a long trailing window — several years — to represent the market's normal volatility across a full cycle. This is the denominator that defines "normal."

The regime ratio. rolling SD / baseline SD. Above 1 = louder than normal; below 1 = quieter than normal. This ratio is the heart of the framework.

Why standard deviation. Equity-index returns are skewed and fat-tailed, so it's fair to ask whether SD is the right scale. Two design choices handle this: the ratio is relative (rolling and baseline use the identical estimator, so most distributional distortion cancels in the division), and the extremeness read uses a percentile (see below), which is fully non-parametric and doesn't assume any distribution shape. SD is also what keeps this faithful to the reference methodology, and on the rolling side its sensitivity to large moves is a feature — a regime tool should react when a big move lands.

Why it's timeframe-independent. All calculations run on the daily series and are pulled onto your chart, so the table reads the same on any timeframe. This avoids a subtle trap: an intraday return SD is far smaller than a daily one, so comparing intraday volatility against a daily baseline would read "compressed" almost permanently. Keeping numerator and denominator in the same daily units is what makes the ratio meaningful.

Percentile (how extreme). For each lookback, the current rolling SD is ranked against its own history over the baseline window (0–100). A ratio tells you how far from normal; the percentile tells you how rare. A reading of 0.90 at the 5th percentile is a much bigger deal than 0.90 at the 40th. Because it's a rank, it's robust to skew and fat tails.

Compression trend. The change in the ratio over a short trend window tells you which way volatility is moving — whether compression is building (ratio falling) or easing (ratio rising).

A note on estimators: both the rolling and baseline standard deviations use the same population formula, so the two sides of the ratio are always measured identically.

3. Inputs and how to configure them

Regime
- Log returns — on by default. Turn off to use simple percentage returns.
- Lookback 1 / 2 / 3 (bars) — the three rolling windows, in daily bars. Defaults 10 / 20 / 50. These are your short, medium, and long horizons. Note "bars" here means trading days, since the calc runs on the daily series.

Baseline
- Baseline lookback (years) — how many years define "normal." Default 10. Longer = a more stable baseline that includes a fuller cycle (calm stretches and crises alike). Shorter = a baseline that reflects only recent conditions and updates faster. This single input has the largest effect on your readings: a baseline drawn only from a calm period will make current conditions look elevated, while one that includes major volatility events will make the same conditions look compressed. If you want to line up with an external reference, adjust the years until your BASE SD matches theirs.

Trend
- Trend window (days) — how far back the compression trend looks. Default 5. Smaller = more responsive; larger = smoother.
- Trend deadband (ratio) — how much the ratio must move before the trend is called BUILD or EASE rather than HOLD. Default 0.05. Widen it if the trend feels twitchy; tighten it if it sits on HOLD too often.

Table
- Text colour — applied to the whole table (monochrome by design).
- Location — nine on-chart positions.
- Text size — Tiny to Huge; scales the whole table.

4. What the table shows

Columns:

- LOOKBACK — the rolling window (e.g. 10d, 20d, 50d).
- STATE — Elevated (ratio > 1) or Compressed (ratio < 1). Binary at 1.0, matching the reference framework.
- RATIO — rolling SD ÷ baseline SD. The core number.
- %ILE — where current volatility ranks in its own multi-year history. Near 0 = calmer than almost any point in the window; near 100 = hotter than almost everything.
- COMPR — the compression trend: BUILD (compression increasing / volatility contracting), EASE (compression releasing / volatility expanding), or HOLD (inside the deadband).
- ROLLSD — the raw rolling standard deviation, for reference and for comparing against external sources.

Rows:

- One row per lookback.
- OVERALL — a headline read taken from the medium (20d) horizon: COMPRESSING, EXPANDING, or STABLE.
- BASE SD / BARS — the baseline standard deviation and the number of daily bars it was built from (≈ 252 × your years setting). Use BARS to confirm the baseline loaded the history you expect.

5. How to read it

Start with STATE and RATIO. Above 1 means the market is printing larger-than-normal moves (elevated); below 1 means smaller-than-normal (compressed). This says nothing about direction — only about how much the market is moving.

Read the lookbacks as a timeline, not three separate numbers. Because each window only "sees" its own recent slice, the shape across horizons tells a story. When the short window reads lower than the long one (e.g. 10d compressed while 50d still elevated), a volatility event from weeks ago is still inside the long window but has already rolled out of the short one — volatility is decreasing and compression is building. The reverse ordering means the front end is heating up. The shortest lookback always moves first, so watch it as your leading tell.

Use the percentile for extremeness. A compressed reading in the low single-digit percentiles means the market is near its quietest in years — historically these deep-compression phases tend to resolve, sometimes abruptly. A high percentile means an unusually loud environment.

Use COMPR and OVERALL for direction. BUILD means the coil is winding tighter; EASE means it's releasing. The first lookback to flip to EASE is your earliest heads-up that a compression is breaking.

Turning it into decisions (following the reference framework's guidance):

- Elevated regime — expect larger, more extended moves. Stops are better placed wider to accommodate the range, and position size reduced accordingly. Trend and continuation approaches tend to work better here.
- Compressed regime — the market tends to mean-revert and range. Breakout and trend strategies are less reliable. Realized volatility is low, so stops can often be tighter — but remember compression doesn't last, and it can release quickly.
- As a filter — before taking a trade, check that the strategy you're about to use suits the regime you're actually in. This is the single most valuable use of the tool.

Notes

- Built with NQ in mind but works on any symbol with sufficient daily history.
- Requires enough loaded history for the baseline; if BARS reads far below years × 252, extend your chart history or reduce the baseline years.
- This is an analysis tool, not financial advice, and does not generate buy/sell signals. Regimes describe volatility conditions; they do not predict direction.
- Concept credit: the market-regime framework at nqstats.com/market_regimes. This is an independent implementation.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © lucymatos

//@version=6
indicator("Market Regime — nqstats", overlay=true, max_bars_back=5000)

// ================= Regime inputs =================
useLog = input.bool(true, "Log returns", group="Regime")
L1 = input.int(10, "Lookback 1 (bars)", minval=2, group="Regime")
L2 = input.int(20, "Lookback 2 (bars)", minval=2, group="Regime")
L3 = input.int(50, "Lookback 3 (bars)", minval=2, group="Regime")

// ================= Baseline =================
baseYears = input.float(10.0, "Baseline lookback (years)", minval=0.5, step=0.5, group="Baseline")

// ================= Trend =================
trendWin = input.int(5,    "Trend window (days)",   minval=1,   group="Trend")
trendThr = input.float(0.05,"Trend deadband (ratio)", minval=0.0, step=0.01, group="Trend")

// ================= Table style =================
txtColor = input.color(color.new(#000000, 0), "Text colour", group="Table")
posSel   = input.string("Bottom Right", "Location", group="Table", options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"])
sizeSel  = input.string("Small", "Text size", group="Table", options=["Tiny","Small","Normal","Large","Huge"])

f_pos(s) =>
    s=="Top Left"?position.top_left : s=="Top Center"?position.top_center : s=="Top Right"?position.top_right : s=="Middle Left"?position.middle_left : s=="Middle Center"?position.middle_center : s=="Middle Right"?position.middle_right : s=="Bottom Left"?position.bottom_left : s=="Bottom Center"?position.bottom_center : position.bottom_right
f_size(s) =>
    s=="Tiny"?size.tiny : s=="Small"?size.small : s=="Large"?size.large : s=="Huge"?size.huge : size.normal

trailLen = math.max(30, math.round(baseYears * 252))

// ================= Per-lookback calc (on daily series) =================
f_one(r, L, baseSD) =>
    sd = ta.stdev(r, L)
    q  = na(baseSD) or baseSD == 0 ? na : sd / baseSD
    p  = ta.percentrank(sd, trailLen)          // percentile of current vol vs its own history
    tr = q - q[trendWin]                        // ratio change over the trend window
    [sd, q, p, tr]

f_calc() =>
    r = useLog ? math.log(close / close[1]) : close / close[1] - 1.0
    baseSD = ta.stdev(r, trailLen)
    nB = math.min(bar_index + 1, trailLen)
    [s1, q1, p1, t1] = f_one(r, L1, baseSD)
    [s2, q2, p2, t2] = f_one(r, L2, baseSD)
    [s3, q3, p3, t3] = f_one(r, L3, baseSD)
    [baseSD, nB, s1,q1,p1,t1, s2,q2,p2,t2, s3,q3,p3,t3]

[baseSD, nB, s1,q1,p1,t1, s2,q2,p2,t2, s3,q3,p3,t3] = request.security(syminfo.tickerid, "D", f_calc(), lookahead=barmerge.lookahead_off)

// ================= Formatting helpers =================
f_state(x)  => na(x) ? "--" : x > 1.0 ? "Elevated" : "Compressed"
// COMPR reads compression, not ratio: ratio falling => vol contracting => compression BUILDing
f_compr(tr) => na(tr) ? "--" : tr < -trendThr ? "BUILD" : tr > trendThr ? "EASE" : "HOLD"
f_num(x, fmt) => na(x) ? "--" : str.tostring(x, fmt)
f_pct(x)    => na(x) ? "--" : str.tostring(math.round(x)) + "%"

head = na(t2) ? "--" : t2 < -trendThr ? "COMPRESSING" : t2 > trendThr ? "EXPANDING" : "STABLE"

// ================= Table =================
tCol = txtColor
tSz  = f_size(sizeSel)
var table t = table.new(f_pos(posSel), 6, 6, border_width=0, frame_width=0)
f_cell(c, row, s) => table.cell(t, c, row, s, text_color=tCol, text_size=tSz, text_font_family=font.family_monospace, bgcolor=color.new(color.black, 100))

if barstate.islast
    f_cell(0,0,"LOOKBACK"), f_cell(1,0,"STATE"), f_cell(2,0,"RATIO"), f_cell(3,0,"%ILE"), f_cell(4,0,"COMPR"), f_cell(5,0,"ROLLSD")
    f_cell(0,1,str.tostring(L1)+"d"), f_cell(1,1,f_state(q1)), f_cell(2,1,f_num(q1,"#.##")), f_cell(3,1,f_pct(p1)), f_cell(4,1,f_compr(t1)), f_cell(5,1,f_num(s1,"#.####"))
    f_cell(0,2,str.tostring(L2)+"d"), f_cell(1,2,f_state(q2)), f_cell(2,2,f_num(q2,"#.##")), f_cell(3,2,f_pct(p2)), f_cell(4,2,f_compr(t2)), f_cell(5,2,f_num(s2,"#.####"))
    f_cell(0,3,str.tostring(L3)+"d"), f_cell(1,3,f_state(q3)), f_cell(2,3,f_num(q3,"#.##")), f_cell(3,3,f_pct(p3)), f_cell(4,3,f_compr(t3)), f_cell(5,3,f_num(s3,"#.####"))
    f_cell(0,4,"OVERALL"), f_cell(1,4,head), f_cell(2,4,""), f_cell(3,4,""), f_cell(4,4,""), f_cell(5,4,"")
    f_cell(0,5,"BASE SD"), f_cell(1,5,f_num(baseSD,"#.####")), f_cell(2,5,"BARS"), f_cell(3,5,str.tostring(nB)), f_cell(4,5,""), f_cell(5,5,"")
````
