# SCMF  Structural Candle Momentum

- url: https://www.tradingview.com/script/jOphJjDT-SCMF-Structural-Candle-Momentum/
- type: indicator
- pine_id: PUB;f961d33d5f2d490591dde12a215a8ce0
- version: 1.0

## Description

## Reading the SCMF Dashboard — Complete Reference

---

## The Main Panel (Chart Area)

Before the table — what you're looking at on screen:

**The histogram bars** are the core output. Each daily bar produces one histogram column. Color tells you the classification tier immediately without reading the table. Width tells you nothing — only the height (value) and color matter.

**The faint white line** running through the histogram is CMS Raw — the unpenalised score before quality gates apply. When it sits significantly higher than the histogram bar, the gates are cutting into your score. When they track closely, all gates are passing cleanly.

**The light blue filled band** around the zero line is the SQC band. Its width equals `±SQC × 0.5`. A wide band means high confidence. A narrow band means the indicator is uncertain. When a bar's histogram column sits well outside the band, the signal is strong relative to its own uncertainty.

**The thin coloured lines** are the five dimensions plotting simultaneously. You read them the same way as the histogram — above zero is bullish, below is bearish, and magnitude matters.

---

## Row 1 — CMS Adjusted

This is the single number that summarises everything. Range is `[-1.00, +1.00]`.

It is the weighted sum of all five dimensions, suppressed to `na` (no display) if SQC falls below 0.25 or if the liquidity gate fires.

**What the number means in practice:**

| Value | What the crowd actually did |
|---|---|
| `+0.80` to `+1.00` | Every dimension is bullish and aligned. Rare. Act with conviction |
| `+0.50` to `+0.79` | Strong multi-dimensional bull signal. Most reliable entry zone |
| `+0.20` to `+0.49` | Moderate bullish. One or two dimensions are pulling back |
| `+0.05` to `+0.19` | Marginal. Don't act on CMS alone at this level |
| `-0.05` to `+0.05` | Genuine standoff. No edge in either direction |
| `-0.05` to `-0.19` | Marginal bearish. Same — don't act alone |
| `-0.20` to `-0.49` | Moderate bearish. Check what dimension is driving it |
| `-0.50` to `-0.79` | Strong bear signal |
| `-0.80` to `-1.00` | Full multi-dimensional bearish alignment |

The distance from zero matters more than crossing a threshold. `+0.66` and `+0.64` are not meaningfully different despite sitting on opposite sides of the strong-bull line.

---

## Row 2 — Signal

The text classification of CMS Adjusted. Seven tiers:

```
▲ STRONG BULL    CMS >  0.65
▲ MOD BULL       CMS >  0.35
△ WEAK BULL      CMS >  0.10
◆ NEUTRAL        CMS between -0.10 and +0.10
▽ WEAK BEAR      CMS < -0.10
▼ MOD BEAR       CMS < -0.35
▼ STRONG BEAR    CMS < -0.65
⚠ NO SIGNAL      CMS is na (suppressed by SQC or liquidity gate)
```

The arrow shapes are intentional — filled triangles (▲▼) for strong/moderate, hollow (△▽) for weak, diamond (◆) for neutral. At a glance you know whether you're in a conviction zone or a noise zone.

`⚠ NO SIGNAL` is not a neutral reading. It means the quality gates have decided the data for this bar is unreliable — treat it as if the bar doesn't exist for signal purposes.

---

## Row 3 — CMS Raw

The composite score **before SQC suppression**, but after all five dimensions are computed and weighted. Range `[-1.00, +1.00]`.

**How to use it alongside CMS Adjusted:**

The gap between Raw and Adjusted tells you how much the quality gates are penalising the bar. In v1.2, CMS Adjusted = CMS Raw when SQC ≥ 0.25 (they're the same number — the only suppression now is the hard cutoff at 0.25). So the main reason these two diverge is when SQC is very close to 0.25 and the histogram shows a different shade.

More practically: if CMS Raw is `+0.71` but CMS Adjusted shows `⚠ NO SIGNAL`, it means a strong theoretical signal was killed by one of the gates — most likely liquidity (HHI abort) or a doji. Check SQC to know which gate caused it.

---

## Row 4 — SQC + Pip Bars

**The number** is the Signal Quality Coefficient — a multiplicative product of all five quality gates. Range `[0.00, 1.00]`.

**The pip bars** `████ / ███░ / ██░░ / █░░░` give you instant visual confidence:

| Pips | SQC Range | Meaning |
|---|---|---|
| `████` | > 0.75 | All gates clean. Full confidence. Treat signal at face value |
| `███░` | 0.50–0.75 | One gate is degraded. Use signal but be aware of which gate |
| `██░░` | 0.25–0.50 | Two or more gates degraded. Signal valid but reduce position size |
| `█░░░` | < 0.25 | Output suppressed — CMS Adjusted will show `⚠ NO SIGNAL` |

**How to use SQC as a position sizing input:**

Don't use it as a binary pass/fail. Use it as a scale. If your normal position size at `▲ STRONG BULL` is 100%, then at SQC `███░` run 75%, at `██░░` run 50%. The number is literally a confidence weight you can apply directly.

**What kills SQC:**

There are six multiplicative components. Any one of them going low drags the product down hard:

| Component | What lowers it | How much |
|---|---|---|
| `sqc_v` (Validity) | Not on daily/weekly timeframe, or zero volume | Drops to 0 — kills everything |
| `sqc_bvc` (BVC accuracy) | No 5m intraday data, or high HHI | 0.55–0.88 range |
| `sqc_phase` (Event trust) | Gap > 2× ATR, or structural event day | 0.50–0.80 |
| `sqc_liq` (Liquidity) | HHI high (concentration), or high Amihud rank | 0.50–1.00, or 0 if abort |
| `sqc_d` (Doji validity) | Bar range < 10% of ATR | 0.30 |
| `sqc_regi` (Regime) | Transitional regime | 0.90 |

---

## Dimensions Block — D1 through D5

Every dimension runs on the same scale: `[-1.00, +1.00]`. Positive = bullish pressure, negative = bearish pressure, zero = no signal from this dimension. The colour in the cell matches the tier — green shades for positive, grey near zero, red shades for negative.

**`—` or `no 5m data` / `no 30m data`** means the dimension couldn't compute because the required intraday data wasn't available from your broker for this ticker. The weight for that dimension is dropped and the remaining weights renormalise. This is normal behaviour for some EGX names.

---

### D1 — CPI (Close Position Index)

**The number answers:** *Where did price close within today's range?*

```
+1.00  Closed exactly at session high
+0.50  Closed in the upper quarter of range
 0.00  Closed exactly at session midpoint
-0.50  Closed in the lower quarter of range
-1.00  Closed exactly at session low
```

This is the only dimension derived purely from daily OHLC — no intraday data needed. It's always available.

**Reading example:** D1 = `+0.82`. The close was 91% of the way from the session low to the session high. The crowd ended the day with strong upward pressure.

**What it cannot tell you:** It doesn't know if volume supported that close, what time of day the high was made, or whether the close was driven by informed buyers or just thin late-day drift. That's why it carries the lowest weight (0.08–0.15 depending on regime).

---

### D2 — WAM (Wick Absorption Model)

**The number answers:** *Where did the crowd get rejected, and did the other side absorb it with conviction?*

```
+1.00  Long lower wick, large body closing up — heavy selling absorbed with conviction
+0.50  Lower wick present, modest body — absorption occurred, not fully confirmed
 0.00  Wicks are symmetric, or body is tiny — no absorption signal
-0.50  Upper wick present, modest body — buying attempt was absorbed
-1.00  Long upper wick, large body closing down — heavy buying absorbed with conviction
```

**Reading example:** D2 = `+0.63`. There is a meaningful lower wick and a solid body. Someone sold aggressively into a level and got absorbed by buyers who then pushed price to close well above the session low. This is a structural sign of demand at a price level.

**The most important interaction:** WAM is the key dimension for confirming D1. If D1 = `+0.82` (closed high) but D2 = `-0.40` (long upper wick, closed off highs relative to wicks) — that's tension. The close was strong but the wicks tell a different story. The divergence engine watches for exactly this.

---

### D3 — NVD (Net Volume Delta)

**The number answers:** *Across all 54 five-minute candles today, who was the net aggressor — buyers lifting offers, or sellers hitting bids?*

```
+1.00  100% of weighted volume was aggressive buying
+0.50  Buyers were the aggressor on roughly 75% of volume
 0.00  Equal buy and sell aggression — genuine equilibrium
-0.50  Sellers were the aggressor on roughly 75% of volume
-1.00  100% of weighted volume was aggressive selling
```

This is the highest-weight dimension (0.25–0.40 depending on regime) because it is the closest proxy to actual order flow. It does not depend on where price closed — a stock can close at the top of its range while NVD is negative (sellers were hitting bids all day but absorption held price up).

**Reading example:** D3 = `-0.44`. Despite what the candle looks like, sellers were the net aggressors across the intraday session. That number reflects who was initiating trades, not where price ended up.

**When D3 shows `no 5m data`:** The broker doesn't provide 5-minute history for this ticker. NVD is dropped from the composite. This particularly affects thin EGX names. CMS will still compute from D1, D2, D4, D5 with renormalised weights, but loses its most informative dimension — SQC will reflect this via `sqc_bvc` penalty.

---

### D4 — TVD (Temporal Volume Distribution)

**The number answers:** *Did volume concentrate in the conviction phase (13:30–14:30), and did it point in the same direction as price moved during that window?*

```
+1.00  Conviction phase dominated total volume AND conviction-phase price rose
+0.50  Moderate conviction-phase dominance with bullish direction
 0.00  Volume was evenly distributed, or conviction-phase direction was flat
-0.50  Moderate conviction-phase dominance with bearish direction
-1.00  Conviction phase dominated total volume AND conviction-phase price fell
```

**Why this matters more than raw volume:** A candle with 10 million shares traded means nothing if 8 million traded in the first 30 minutes (retail FOMO at open). The same 10 million is very different if 6 million traded between 13:30 and 14:30. Institutional rebalancing happens in the conviction window. TVD measures whether they were there and which direction they pushed.

**On event days** the weighting shifts — opening phase gets higher weight (0.80) because informed traders act at open when news has a time expiry. TVD automatically adjusts, so you don't need to do anything differently.

**Reading example:** D4 = `+0.71`. The conviction window was heavy and price moved upward during that window. Institutional positioning for tomorrow was to the buy side.

---

### D5 — PPT (Price Path Topology)

**The number answers:** *Did the 30-minute closes trace a consistent directional path, and did the pace accelerate or decelerate toward the end?*

```
+1.00  Monotonic grind upward all day, accelerating into the close
+0.50  Mostly directional with some pullbacks, no strong acceleration signal
 0.00  Oscillating path that happened to close up/down — no conviction in the journey
-0.50  Mostly directional downward with some bounces
-1.00  Monotonic grind downward all day, accelerating into the close
```

PPT has two sub-components you can think about separately:

**Path Monotonicity** — what fraction of 30-minute steps pointed in the final direction. A day where 8 of 8 steps went up is different from a day where price went up, down, up, up, down, up, up, up and happened to close up.

**Momentum Acceleration** — did the second half of the session move faster than the first half? Positive acceleration (slow start, fast finish) is institutionally consistent. Deceleration (fast start, slow finish) is exhaustion.

**Reading example:** D5 = `-0.28`. Even though the daily close might look fine, the intraday path decelerated toward the end and had inconsistent step direction. The crowd moved without conviction today. Don't trust tomorrow's follow-through.

**The most useful divergence from D5:** When CMS is strongly positive but D5 is negative — this is the Exhaustion pattern (EX flag). The candle looks great, the crowd was net bullish today, but the path tells you energy is fading. Often appears one to two bars before a reversal.

---

## Context Block

### Regime

Three states, driven by ADX and ATR ratio:

| State | ADX | ATR/SMA(ATR) | Meaning for the indicator |
|---|---|---|---|
| `TRENDING` | > 25 | > 1.0 | NVD and TVD weights are elevated. Institutional order flow dominates price action. CMS is most reliable here |
| `RANGING` | < 20 | < 0.8 | WAM and CPI weights are elevated. Absorption at extremes and close position matter more than delta. Watch for mean-reversion signals |
| `TRANSITIONAL` | Between | Between | Default weights apply. SQC gets a 0.90 modifier — slight confidence reduction because regime is ambiguous |

Regime is critical context for interpreting the signal tier. A `▲ MOD BULL` in `TRENDING` regime with high NVD is a different trade from `▲ MOD BULL` in `RANGING` regime driven by WAM — the first is trend continuation, the second is a bounce candidate.

---

### Event Day

**`No`** — Normal session. Phase weights are standard (opening=0.0, discovery=0.50, conviction=1.00). Informed trading expected at close.

**`▲ YES`** — Either the opening gap exceeded 1× ATR, or the opening 30-minute window had more than 2.5× its 20-day average volume. Phase weights have shifted (opening=0.80, discovery=0.45, conviction=0.35). Informed traders may have front-loaded into the opening on time-sensitive news. SQC is reduced to 0.80 for this bar. If the gap exceeded 2× ATR, SQC drops further to 0.50 and the bar should be treated as structurally unreliable for momentum signals.

On event days: D4 (TVD) is the most affected dimension — its output is driven by dynamically reweighted phases. D3 (NVD) is unaffected since it reads raw order flow regardless of when it happened. Trust D3 and D1 more than D4 and D5 on event days.

---

### Divergence

Shows the active divergence pattern for the current bar. Only one shows at a time (priority order: HD → HA → EX → CM). On the chart these appear as plotshapes directly on the indicator panel.

**`None`** — Dimensions are broadly consistent with the CMS direction. Signal is clean.

**`Hidden Dist` (HD ▼)** — Hidden Distribution. D1 (close) is positive (`> +0.35`) but D3 (NVD) is negative (`< -0.25`) and D4 (TVD) is negative (`< -0.15`). The candle *looks* bullish but the crowd was net selling all day and institutional volume was bearish. Classic smart-money distribution pattern. In a topping market this is the most dangerous candle type — price is being marked up while size is being sold into retail buyers.

**`Hidden Accum` (HA ▲)** — Hidden Accumulation. D1 (close) is negative (`< -0.35`) but D3 (NVD) is positive (`> +0.25`) and D2 (WAM) is positive (`> +0.15`). The candle looks bearish but buyers absorbed all supply and the lower wick confirms a defended level. Smart money is building a position at a discount.

**`Exhaustion` (EX ✕)** — D1 is positive (`> +0.35`) but D5 (PPT) decelerated (`< -0.15`) and D4 conviction-phase volume was absent (`< +0.10`). Strong close, but the path slowed and institutional participation faded late. Not a reversal signal by itself — more a momentum quality warning. Often precedes a flat or weak next session rather than a sharp reversal.

**`Conv Mismatch` (CM ○)** — D3 (NVD) is strongly positive (`> +0.35`) but D4 (TVD) is negative (`< -0.20`). There was aggressive net buying throughout the day, but it happened in the opening phase (retail FOMO), not the conviction phase. Institutional traders were not the buyers. High risk of next-session mean reversion as the weak holders unwind.

---

## The Complete Reading Process — Step by Step

When you open the chart at end of day, read in this order:

**Step 1 — SQC first.** If `█░░░` or `⚠ NO SIGNAL`, stop. The bar is not usable for signals today.

**Step 2 — Regime.** Sets the interpretive frame. Are you looking for trend continuation (TRENDING) or mean reversion (RANGING)?

**Step 3 — Event Day.** If YES, discount D4 and D5 slightly, trust D3 and D1 more.

**Step 4 — CMS Adjusted and Signal tier.** Is this a conviction zone (> ±0.35) or noise (< ±0.10)?

**Step 5 — Divergence.** Does the signal have internal conflict? Hidden Distribution on a `▲ MOD BULL` = danger. Hidden Accumulation on a `▼ MOD BEAR` = potential entry.

**Step 6 — Dimension breakdown.** Which dimensions are driving the CMS? A `+0.58` driven by D3 `+0.80` and D4 `+0.75` (both intraday-dependent dimensions) is much stronger than `+0.58` driven only by D1 `+0.90` and D2 `+0.60` (daily OHLC only) with D3/D4/D5 all near zero.

**Step 7 — CMS Raw vs Adjusted gap.** If they are the same, all gates passed cleanly. If Raw is significantly higher, something penalised the bar — usually a gate between 0.25 and 0.75 SQC.

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
// SCMF — Structural Candle Momentum Framework  v1.2
// Multi-dimensional crowd-behaviour momentum indicator
// Dimensions: CPI · WAM · NVD · TVD · PPT
// Gates:      Validity · Doji · Liquidity · Event · Regime
// Output:     CMS ∈ [-1,+1]  +  SQC quality coefficient ∈ [0,1]
//
// v1.2 fixes over v1.1
// ────────────────────────────────────────────────────────────────────────────
// FIX 1 · GATE 3 — Event phase weights
//   pw_conv was 0.20 — too low. Drops conviction phase nearly to zero even on
//   event days where the 13:30–14:30 window still carries repositioning flow.
//   New values: pw_open 0.80 · pw_disc 0.45 · pw_conv 0.35
//   Rationale: on event days the opening IS the dominant informed window, but
//   conviction phase retains meaningful positional information (institutions
//   that disagreed with the news are still rebalancing at close).
//   0.35 is the minimum theoretically defensible weight for pw_conv.
//
// FIX 2 · D5 PPT — midpoint integer division
//   int(math.round(n30 / 2.0)):  n30 is int, Pine integer-divides first
//   giving math.round(4) = 4 for n30=9 instead of math.round(4.5) = 5.
//   Result: asymmetric early/late split, acceleration measure is biased.
//   Fix: math.floor(n30 / 2) + bounds guard with n30-2 (ensures lb >= 1).
//   For n30=9 → mid=4, eb=4, lb=4. Symmetric. ✓
// ════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("SCMF — Structural Candle Momentum",
  shorttitle    = "SCMF",
  overlay       = false,
  max_bars_back = 500)


// ─────────────────────────────────────────────────────────────────────────────
// COLOUR PALETTE
// ─────────────────────────────────────────────────────────────────────────────
color C_SB  = #00c853
color C_MB  = #66bb6a
color C_WB  = #a5d6a7
color C_NEU = #ffd54f
color C_WBR = #ef9a9a
color C_MBR = #e53935
color C_SBR = #b71c1c
color C_CYN = #00bcd4
color C_ORG = #ff9800
color C_GRY = #9e9e9e

color C_D1  = color.new(#5c6bc0, 50)
color C_D2  = color.new(#ab47bc, 50)
color C_D3  = color.new(#ff7043, 50)
color C_D4  = color.new(#00bcd4, 50)
color C_D5  = color.new(#fdd835, 50)


// ─────────────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────
f_cls(float v) =>
    na(v)     ? "⚠ NO SIGNAL"   : v >  0.65 ? "▲ STRONG BULL" :
      v >  0.35 ? "▲ MOD BULL"    : v >  0.10 ? "△ WEAK BULL" :
      v > -0.10 ? "◆ NEUTRAL"     : v > -0.35 ? "▽ WEAK BEAR" :
      v > -0.65 ? "▼ MOD BEAR"    : "▼ STRONG BEAR"

f_tier(float v) =>
    na(v)     ? color.new(color.gray, 50) :
      v >  0.65 ? C_SB  : v >  0.35 ? C_MB  : v >  0.10 ? C_WB  :
      v > -0.10 ? C_NEU : v > -0.35 ? C_WBR : v > -0.65 ? C_MBR : C_SBR

f_dim_bg(float v) =>
    na(v)     ? color.new(C_GRY, 75) :
      v >  0.30 ? color.new(C_SB,  30) : v >  0.05 ? color.new(C_MB,  50) :
      v > -0.05 ? color.new(C_GRY, 65) : v > -0.30 ? color.new(C_MBR, 50) :
      color.new(C_SBR, 30)

f_sqc_bg(float v) =>
    v > 0.75 ? color.new(C_CYN, 25) : v > 0.50 ? color.new(C_ORG, 35) :
      v > 0.25 ? color.new(C_GRY, 55) : color.new(C_MBR, 40)

f_fmt(float v) =>
    na(v) ? " — " : str.tostring(v, "#.###")

f_pips(float v) =>
    v > 0.75 ? "████" : v > 0.50 ? "███░" : v > 0.25 ? "██░░" : "█░░░"

f_row(table t, int r, string lbl, string val, color bg) =>
    table.cell(t, 0, r, lbl,
      text_color = color.new(color.white, 30),
      text_size  = size.small,
      bgcolor    = color.new(#0d1117, 15))
    table.cell(t, 1, r, val,
      text_color = color.white,
      text_size  = size.small,
      bgcolor    = bg)
    table.cell(t, 2, r, "", bgcolor = bg)

f_sep(table t, int r, string txt) =>
    table.cell(t, 0, r, txt,
      text_color = color.new(color.gray, 45),
      text_size  = size.tiny,
      bgcolor    = color.new(color.black, 55))
    table.merge_cells(t, 0, r, 2, r)


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 · INPUTS
// ─────────────────────────────────────────────────────────────────────────────
string GW = "⚖ Dimension Weights"
string GG = "🔒 Gate Thresholds"
string GD = "📊 Display"

float i_w_cpi  = input.float(0.10, "CPI Weight", 0.00, 1.00, 0.01, group = GW)
float i_w_wam  = input.float(0.20, "WAM Weight", 0.00, 1.00, 0.01, group = GW)
float i_w_nvd  = input.float(0.35, "NVD Weight", 0.00, 1.00, 0.01, group = GW)
float i_w_tvd  = input.float(0.20, "TVD Weight", 0.00, 1.00, 0.01, group = GW)
float i_w_ppt  = input.float(0.15, "PPT Weight", 0.00, 1.00, 0.01, group = GW)
bool  i_auto_w = input.bool(true,  "Auto Regime Weights", group = GW)

int   i_atr_len    = input.int(14,     "ATR Length",        2,   100, group = GG)
int   i_adx_len    = input.int(14,     "ADX Length",        2,   100, group = GG)
int   i_amihud_win = input.int(60,     "Amihud Window",     10,  200, group = GG)
float i_doji_atr   = input.float(0.10, "Doji Ratio ×ATR",   0.0, 0.5, 0.01, group = GG)
float i_hhi_liq    = input.float(0.05, "HHI Liquid <",      0.0, 0.5, 0.01, group = GG)
float i_hhi_abort  = input.float(0.30, "HHI Abort >",       0.0, 1.0, 0.01, group = GG)
float i_gap_event  = input.float(1.00, "Event Gap ×ATR",    0.0, 5.0, 0.10, group = GG)
float i_gap_struct = input.float(2.00, "Struct Gap ×ATR",   0.0, 5.0, 0.10, group = GG)
float i_surp_mult  = input.float(2.50, "Phase Surprise ×",  1.0, 10., 0.10, group = GG)

bool  i_show_raw  = input.bool(true, "CMS Raw Line",        group = GD)
bool  i_show_sqc  = input.bool(true, "SQC Confidence Band", group = GD)
bool  i_show_dims = input.bool(true, "Dimension Lines",     group = GD)
bool  i_show_div  = input.bool(true, "Divergence Flags",    group = GD)
bool  i_show_tbl  = input.bool(true, "Dashboard Table",     group = GD)


// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 · LOWER-TIMEFRAME DATA
// ─────────────────────────────────────────────────────────────────────────────
float[] h5  = request.security_lower_tf(syminfo.tickerid, "5",  high)
float[] l5  = request.security_lower_tf(syminfo.tickerid, "5",  low)
float[] c5  = request.security_lower_tf(syminfo.tickerid, "5",  close)
float[] v5  = request.security_lower_tf(syminfo.tickerid, "5",  volume)
float[] c30 = request.security_lower_tf(syminfo.tickerid, "30", close)
float[] v30 = request.security_lower_tf(syminfo.tickerid, "30", volume)

int  n5      = array.size(c5)
int  n30     = array.size(c30)
bool has_5m  = n5  >= 27
bool has_30m = n30 >= 6


// ─────────────────────────────────────────────────────────────────────────────
// GATE 0 · DATA VALIDITY
// ─────────────────────────────────────────────────────────────────────────────
bool  g0_ok = volume > 0 and (timeframe.isdaily or timeframe.isweekly)
float sqc_v = g0_ok ? 1.0 : 0.0

if barstate.islast and not (timeframe.isdaily or timeframe.isweekly)
    label.new(bar_index, 0.0,
      "⚠ SCMF requires a Daily or Weekly chart",
      style     = label.style_label_center,
      color     = color.new(color.red, 15),
      textcolor = color.white,
      size      = size.normal)


// ─────────────────────────────────────────────────────────────────────────────
// GATE 1 · RANGE VALIDITY / DOJI
// ─────────────────────────────────────────────────────────────────────────────
float atr14     = ta.atr(i_atr_len)
float bar_range = high - low
bool  is_doji   = bar_range < (i_doji_atr * atr14)

float gap_raw    = na(close[1]) ? 0.0 : open - close[1]
float cpi_fallbk = math.sign(gap_raw) * 0.30

float sqc_d = is_doji ? 0.30 : 1.00


// ─────────────────────────────────────────────────────────────────────────────
// GATE 2 · LIQUIDITY (HHI + Amihud)
// ─────────────────────────────────────────────────────────────────────────────
float hhi = 1.0 / 54.0
if has_5m
    float tot5 = 0.0
    for i = 0 to n5 - 1
        tot5 += array.get(v5, i)
    if tot5 > 0.0
        hhi := 0.0
        for i = 0 to n5 - 1
            float sh = array.get(v5, i) / tot5
            hhi += sh * sh

bool  g2_abort = hhi > i_hhi_abort
float sqc_hhi  = g2_abort                 ? 0.00 :
                 hhi > i_hhi_abort * 0.50 ? 0.50 :
                 hhi > i_hhi_liq          ? 0.80 : 1.00

float amihud    = volume > 0 and not na(close[1]) ?
                  math.abs(close / close[1] - 1.0) / (volume / 1e6) : 0.0
float amihud_pr = ta.percentrank(amihud, i_amihud_win)
float sqc_ami   = na(amihud_pr) ? 1.0 : amihud_pr > 80.0 ? 0.75 : 1.0

float sqc_liq = sqc_hhi * sqc_ami


// ─────────────────────────────────────────────────────────────────────────────
// GATE 3 · EVENT DETECTION
// ─────────────────────────────────────────────────────────────────────────────
float gap_x    = atr14 > 0.0 ? math.abs(gap_raw) / atr14 : 0.0
bool  ev_gap   = gap_x > i_gap_event
bool  ev_struc = gap_x > i_gap_struct

float vol_open30 = 0.0
float vol_disc30 = 0.0
float vol_conv30 = 0.0
if has_30m
    for i = 0 to n30 - 1
        float vi = array.get(v30, i)
        if i <= 1
            vol_open30 += vi
        else if i <= 6
            vol_disc30 += vi
        else
            vol_conv30 += vi

float open_avg = ta.sma(vol_open30, 20)
bool  ev_vol   = open_avg > 0.0 and (vol_open30 / open_avg) > i_surp_mult
bool  is_event = ev_gap or ev_vol

// ── FIX 1: Event phase weights ────────────────────────────────────────────
// Normal day:  opening=0.00  discovery=0.50  conviction=1.00
//   → informed flow concentrates at close (Admati–Pfleiderer)
// Event day:   opening=0.80  discovery=0.45  conviction=0.35
//   → informed flow shifts to open (news-expiry), but conviction window
//     still carries repositioning flow — minimum weight 0.35, not 0.20
// v1.1 had pw_conv=0.20 (too aggressive) and pw_open=1.00 (no ceiling)
float pw_open = is_event ? 0.80 : 0.00
float pw_disc = is_event ? 0.45 : 0.50
float pw_conv = is_event ? 0.35 : 1.00   // ← was 0.20 in v1.1

float sqc_phase = ev_struc ? 0.50 : is_event ? 0.80 : 1.00


// ─────────────────────────────────────────────────────────────────────────────
// GATE 4 · REGIME (ADX + ATR ratio)
// ─────────────────────────────────────────────────────────────────────────────
[_, _, adx_val] = ta.dmi(i_adx_len, i_adx_len)   // _ discards unused DI+/DI-
float atr_sma20 = ta.sma(atr14, 20)
float atr_ratio = atr_sma20 > 0.0 ? atr14 / atr_sma20 : 1.0

string regime = adx_val > 25.0 and atr_ratio > 1.0 ? "TRENDING" :
  adx_val < 20.0 and atr_ratio < 0.8 ? "RANGING" : "TRANSITIONAL"

float w_cpi = i_auto_w ? (regime == "RANGING" ? 0.15 : regime == "TRENDING" ? 0.08 : i_w_cpi) : i_w_cpi
float w_wam = i_auto_w ? (regime == "RANGING" ? 0.30 : regime == "TRENDING" ? 0.15 : i_w_wam) : i_w_wam
float w_nvd = i_auto_w ? (regime == "RANGING" ? 0.25 : regime == "TRENDING" ? 0.40 : i_w_nvd) : i_w_nvd
float w_tvd = i_auto_w ? (regime == "RANGING" ? 0.15 : regime == "TRENDING" ? 0.25 : i_w_tvd) : i_w_tvd
float w_ppt = i_auto_w ? (regime == "RANGING" ? 0.15 : regime == "TRENDING" ? 0.12 : i_w_ppt) : i_w_ppt

float sqc_regi = regime == "TRANSITIONAL" ? 0.90 : 0.95


// ─────────────────────────────────────────────────────────────────────────────
// D1 · CLOSE POSITION INDEX (CPI)
// ─────────────────────────────────────────────────────────────────────────────
float d1 = na
if g0_ok
    d1 := is_doji ? cpi_fallbk :
      bar_range > 0.0 ? (2.0 * (close - low) / bar_range) - 1.0 : 0.0


// ─────────────────────────────────────────────────────────────────────────────
// D2 · WICK ABSORPTION MODEL (WAM)
// ─────────────────────────────────────────────────────────────────────────────
float d2 = na
if g0_ok
    if not is_doji and bar_range > 0.0
        float bh  = math.max(open, close)
        float bl  = math.min(open, close)
        float upw = high - bh
        float dnw = bl - low
        float bc  = math.abs(close - open) / bar_range
        float wnp = (dnw - upw) / bar_range
        d2 := math.max(-1.0, math.min(1.0, wnp * (1.0 + bc) / 2.0))
    else if is_doji
        float upw = high - math.max(open, close)
        float dnw = math.min(open, close) - low
        float tw  = upw + dnw
        d2 := tw > 0.0 ? math.max(-1.0, math.min(1.0, (dnw - upw) / tw * 0.30)) : 0.0


// ─────────────────────────────────────────────────────────────────────────────
// D3 · NET VOLUME DELTA (NVD — Hybrid BVC + Tick Rule)
// ─────────────────────────────────────────────────────────────────────────────
float d3      = na
float sv_vwap = na

if has_5m and g0_ok
    float buy_s  = 0.0
    float sel_s  = 0.0
    float wt_s   = 0.0
    float vwn    = 0.0
    float vwd    = 0.0
    float avg_r5 = 0.0

    for i = 0 to n5 - 1
        avg_r5 += math.max(0.0, array.get(h5, i) - array.get(l5, i))
    avg_r5 := n5 > 0 ? avg_r5 / n5 : (bar_range > 0.0 ? bar_range / 54.0 : atr14 / 54.0)

    for i = 0 to n5 - 1
        float ci = array.get(c5, i)
        float hi = array.get(h5, i)
        float li = array.get(l5, i)
        float vi = array.get(v5, i)
        float ri = hi - li

        float bvc  = ri > 0.0 ? (ci - li) / ri : 0.5
        float prev = i > 0 ? array.get(c5, i - 1) : nz(close[1], ci)
        float tick = ci > prev ? 1.0 : ci < prev ? 0.0 : bvc
        float hyb  = 0.5 * (bvc + tick)
        float rcon = avg_r5 > 0.0 ? 1.0 / (1.0 + math.max(0.0, ri / avg_r5 - 1.0)) : 0.8

        buy_s += vi * hyb         * rcon
        sel_s += vi * (1.0 - hyb) * rcon
        wt_s  += vi               * rcon

        float typ  = (hi + li + ci) / 3.0
        vwn       += typ * vi
        vwd       += vi

    if wt_s > 0.0
        d3 := (buy_s - sel_s) / wt_s

    sv_vwap := vwd > 0.0 ? vwn / vwd : na
    if not na(sv_vwap) and not na(d3)
        bool nvd_bull = d3 > 0.0
        bool abv_vwap = close > sv_vwap
        if (nvd_bull and not abv_vwap) or (not nvd_bull and abv_vwap)
            d3 *= 0.70


// ─────────────────────────────────────────────────────────────────────────────
// D4 · TEMPORAL VOLUME DISTRIBUTION (TVD)
// ─────────────────────────────────────────────────────────────────────────────
float d4 = na
if has_30m and g0_ok and not na(d1)
    float tot30 = vol_open30 + vol_disc30 + vol_conv30
    if tot30 > 0.0
        float tvd_raw = (pw_open * vol_open30 +
                         pw_disc * vol_disc30 +
                         pw_conv * vol_conv30) / tot30

        int   conv_ref_idx = math.max(0, n30 - 3)
        float conv_ref     = array.get(c30, conv_ref_idx)
        float conv_last    = array.get(c30, n30 - 1)
        float conv_dir     = conv_last > conv_ref ? 1.0 :
                             conv_last < conv_ref ? -1.0 :
                             math.sign(nz(d1, 0.0))

        d4 := math.max(-1.0, math.min(1.0, tvd_raw * conv_dir))


// ─────────────────────────────────────────────────────────────────────────────
// D5 · PRICE PATH TOPOLOGY (PPT)
// ─────────────────────────────────────────────────────────────────────────────
float d5 = na
if has_30m and g0_ok and n30 >= 5
    float cf    = array.get(c30, 0)
    float cl    = array.get(c30, n30 - 1)
    float rsafe = bar_range > 0.0 ? bar_range : atr14
    int   fdir  = cl > cf ? 1 : cl < cf ? -1 : 0

    // Sub-A: Path Monotonicity
    int cons = 0
    for i = 1 to n30 - 1
        float diff = array.get(c30, i) - array.get(c30, i - 1)
        if (diff > 0.0 and fdir == 1) or (diff < 0.0 and fdir == -1)
            cons += 1
    float pm = n30 > 1 ? float(cons) / float(n30 - 1) : 0.5

    // ── FIX 2: Midpoint for momentum acceleration ──────────────────────────
    // v1.1 used int(math.round(n30 / 2.0)) — because n30 is an int, Pine
    // performs integer division before round(), giving math.round(4)=4
    // for n30=9 instead of the intended math.round(4.5)=5. This created an
    // asymmetric early/late split (5 early steps, 3 late) biasing the
    // acceleration measure toward early session behaviour.
    //
    // Fix: math.floor(n30 / 2) forces float division (int/int → float in Pine)
    // then floors. For n30=9 → 4.5 → floor → 4. eb=4, lb=4. Symmetric. ✓
    // Bounds guard uses n30-2 (not n30-1) so lb = n30-1-mid >= 1 always.
    int mid = math.floor(n30 / 2)
    mid     := math.max(1, math.min(n30 - 2, mid))   // ← was n30-1 in v1.1

    float cmid = array.get(c30, mid)
    int   eb   = mid
    int   lb   = n30 - 1 - mid
    float esl  = eb > 0 ? (cmid - cf)  / (float(eb) * rsafe) : 0.0
    float lsl  = lb > 0 ? (cl   - cmid) / (float(lb) * rsafe) : 0.0
    float macc = math.max(-1.0, math.min(1.0, lsl - esl))

    d5 := math.max(-1.0, math.min(1.0, float(fdir) * pm + 0.3 * macc))


// ─────────────────────────────────────────────────────────────────────────────
// SQC · SIGNAL QUALITY COEFFICIENT
// ─────────────────────────────────────────────────────────────────────────────
float coverage5 = math.min(1.0, n5 / 54.0)
float sqc_bvc   = not has_5m ? 0.55 :
                  hhi < 0.03  ? 0.88 * coverage5 :
                  hhi < 0.10  ? 0.78 * coverage5 : 0.65 * coverage5

float sqc = math.max(0.0, math.min(1.0,
  sqc_v     *
  sqc_bvc   *
  sqc_phase *
  sqc_liq   *
  sqc_d     *
  sqc_regi))

bool suppress = sqc < 0.25 or g2_abort or not g0_ok


// ─────────────────────────────────────────────────────────────────────────────
// CMS · COMPOSITE MOMENTUM SCORE
// ─────────────────────────────────────────────────────────────────────────────
float s1 = nz(d1, 0.0)
float s2 = nz(d2, 0.0)
float s3 = nz(d3, 0.0)
float s4 = nz(d4, 0.0)
float s5 = nz(d5, 0.0)

float wsum = 0.0
wsum += not na(d1) ? w_cpi : 0.0
wsum += not na(d2) ? w_wam : 0.0
wsum += not na(d3) ? w_nvd : 0.0
wsum += not na(d4) ? w_tvd : 0.0
wsum += not na(d5) ? w_ppt : 0.0

float cms_raw = na
float cms_adj = na

if g0_ok and wsum > 0.0
    cms_raw := (
      (not na(d1) ? w_cpi * s1 : 0.0) +
      (not na(d2) ? w_wam * s2 : 0.0) +
      (not na(d3) ? w_nvd * s3 : 0.0) +
      (not na(d4) ? w_tvd * s4 : 0.0) +
      (not na(d5) ? w_ppt * s5 : 0.0)
    ) / wsum
    cms_adj := suppress ? na : math.max(-1.0, math.min(1.0, cms_raw))

string cls = f_cls(cms_adj)


// ─────────────────────────────────────────────────────────────────────────────
// DIVERGENCE ENGINE
// ─────────────────────────────────────────────────────────────────────────────
bool dv_ok = g0_ok and not suppress and not na(cms_adj)

bool div_hd = dv_ok and not na(d1) and not na(d3) and not na(d4) and d1 >  0.35 and d3 < -0.25 and d4 < -0.15
bool div_ha = dv_ok and not na(d1) and not na(d3) and not na(d2) and d1 < -0.35 and d3 >  0.25 and d2 >  0.15
bool div_ex = dv_ok and not na(d1) and not na(d5) and not na(d4) and d1 >  0.35 and d5 < -0.15 and d4 <  0.10
bool div_cm = dv_ok and not na(d3) and not na(d4)                 and d3 >  0.35 and d4 < -0.20

bool any_div = div_hd or div_ha or div_ex or div_cm


// ─────────────────────────────────────────────────────────────────────────────
// VISUALIZATION
// ─────────────────────────────────────────────────────────────────────────────
color hist_col = suppress ? color.new(color.gray, 82) : f_tier(cms_adj)
plot(cms_adj, "CMS Adjusted", hist_col, 3, plot.style_histogram)

plot(i_show_raw ? cms_raw : na, "CMS Raw",
     color.new(color.white, 72), 1, plot.style_line)

float sqc_hi = g0_ok and not suppress ?  sqc * 0.5 : na
float sqc_lo = g0_ok and not suppress ? -sqc * 0.5 : na
p_sh = plot(i_show_sqc ? sqc_hi : na, "SQC+", color.new(C_CYN, 93))
p_sl = plot(i_show_sqc ? sqc_lo : na, "SQC-", color.new(C_CYN, 93))
fill(p_sh, p_sl, color.new(C_CYN, 88), "SQC Confidence Band")

plot(i_show_dims and not na(d1) ? s1 : na, "D1 CPI", C_D1, 1)
plot(i_show_dims and not na(d2) ? s2 : na, "D2 WAM", C_D2, 1)
plot(i_show_dims and not na(d3) ? s3 : na, "D3 NVD", C_D3, 1)
plot(i_show_dims and not na(d4) ? s4 : na, "D4 TVD", C_D4, 1)
plot(i_show_dims and not na(d5) ? s5 : na, "D5 PPT", C_D5, 1)

hline( 0.65, "Strong Bull", color.new(C_SB,  40), linestyle = hline.style_dotted)
hline( 0.35, "Mod Bull",    color.new(C_MB,  55), linestyle = hline.style_dotted)
hline( 0.10, "Weak Bull",   color.new(C_GRY, 72), linestyle = hline.style_dotted)
hline( 0.00, "Zero",        color.new(color.white, 35), linestyle = hline.style_solid)
hline(-0.10, "Weak Bear",   color.new(C_GRY, 72), linestyle = hline.style_dotted)
hline(-0.35, "Mod Bear",    color.new(C_MBR, 55), linestyle = hline.style_dotted)
hline(-0.65, "Strong Bear", color.new(C_SBR, 40), linestyle = hline.style_dotted)

plotshape(i_show_div and div_hd, "Hidden Distribution",
          shape.triangledown, location.top,
          color.new(C_SBR, 10), size = size.small, text = "HD", textcolor = color.white)
plotshape(i_show_div and div_ha, "Hidden Accumulation",
          shape.triangleup, location.bottom,
          color.new(C_SB, 10), size = size.small, text = "HA", textcolor = color.white)
plotshape(i_show_div and div_ex, "Exhaustion",
          shape.xcross, location.top,
          color.new(C_ORG, 15), size = size.tiny, text = "EX", textcolor = color.white)
plotshape(i_show_div and div_cm, "Conviction Mismatch",
          shape.circle, location.bottom,
          color.new(color.yellow, 20), size = size.tiny, text = "CM", textcolor = color.black)


// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(not na(cms_adj) and cms_adj >  0.65,
               "SCMF Strong Bull", "SCMF ▲ STRONG BULL — CMS > +0.65")
alertcondition(not na(cms_adj) and cms_adj < -0.65,
               "SCMF Strong Bear", "SCMF ▼ STRONG BEAR — CMS < -0.65")
alertcondition(not na(cms_adj) and cms_adj >  0.35 and (na(cms_adj[1]) or cms_adj[1] <=  0.35),
               "SCMF → Mod Bull",  "SCMF: Crossed into Moderate Bull zone")
alertcondition(not na(cms_adj) and cms_adj < -0.35 and (na(cms_adj[1]) or cms_adj[1] >= -0.35),
               "SCMF → Mod Bear",  "SCMF: Crossed into Moderate Bear zone")
alertcondition(div_ha,  "SCMF Hidden Accum",   "SCMF: Hidden Accumulation detected")
alertcondition(div_hd,  "SCMF Hidden Dist",    "SCMF: Hidden Distribution detected")
alertcondition(any_div, "SCMF Any Divergence", "SCMF: Divergence pattern active")


// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD TABLE
// ─────────────────────────────────────────────────────────────────────────────
if i_show_tbl and barstate.islast
    var table tbl = table.new(position.top_right, 3, 15,
      bgcolor      = color.new(#0a0e1a, 8),
      border_color = color.new(color.gray, 65),
      border_width = 1,
      frame_color  = color.new(color.gray, 50),
      frame_width  = 1)

    table.cell(tbl, 0, 0, " SCMF v1.2 ",
      text_color = color.white,
      text_size  = size.normal,
      bgcolor    = color.new(#1565c0, 15))
    table.merge_cells(tbl, 0, 0, 2, 0)

    f_row(tbl, 1, "CMS Adjusted",         f_fmt(cms_adj), f_tier(cms_adj))
    f_row(tbl, 2, "Signal",               cls,            color.new(f_tier(cms_adj), 35))
    f_row(tbl, 3, "CMS Raw",              f_fmt(cms_raw), color.new(color.gray, 65))
    f_row(tbl, 4, "SQC " + f_pips(sqc),  f_fmt(sqc),     f_sqc_bg(sqc))

    f_sep(tbl, 5, "── Dimensions ─────────────────")
    f_row(tbl, 6,  "D1 CPI", not na(d1) ? f_fmt(d1) : "—",          not na(d1) ? f_dim_bg(d1) : color.new(C_GRY, 80))
    f_row(tbl, 7,  "D2 WAM", not na(d2) ? f_fmt(d2) : "—",          not na(d2) ? f_dim_bg(d2) : color.new(C_GRY, 80))
    f_row(tbl, 8,  "D3 NVD", not na(d3) ? f_fmt(d3) : "no 5m",      not na(d3) ? f_dim_bg(d3) : color.new(C_GRY, 80))
    f_row(tbl, 9,  "D4 TVD", not na(d4) ? f_fmt(d4) : "no 30m",     not na(d4) ? f_dim_bg(d4) : color.new(C_GRY, 80))
    f_row(tbl, 10, "D5 PPT", not na(d5) ? f_fmt(d5) : "no 30m",     not na(d5) ? f_dim_bg(d5) : color.new(C_GRY, 80))

    f_sep(tbl, 11, "── Context ──────────────────────")
    color reg_col = regime == "TRENDING" ? color.new(C_SB, 40) :
      regime == "RANGING" ? color.new(C_ORG, 40) : color.new(C_GRY, 60)

    f_row(tbl, 12, "Regime",    regime, reg_col)
    f_row(tbl, 13, "Event Day",
      is_event ? "▲ YES" : "No",
      is_event ? color.new(C_ORG, 25) : color.new(color.black, 60))

    string dvs = div_hd ? "Hidden Dist" : div_ha ? "Hidden Accum" :
      div_ex ? "Exhaustion"  : div_cm ? "Conv Mismatch" : "None"
    f_row(tbl, 14, "Divergence", dvs,
      any_div ? color.new(C_ORG, 20) : color.new(color.black, 60))
````
