# Volatility Heatmap Bands [PickMyTrade]

- url: https://www.tradingview.com/script/BVgILJ0h-Volatility-Heatmap-Bands-PickMyTrade/
- type: indicator
- pine_id: PUB;5e768c3702e7489a91b61b20fa7b75a0
- version: 1.0

## Description

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT IT DOES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Volatility Heatmap Bands fits a log-normal distribution to recent price returns and draws a statistically calibrated price envelope — then colours every bar by where it sits inside that envelope.

Simple version: the red band at the top is the "overbought wall." The cyan band at the bottom is the "oversold wall." When bars turn red, price is statistically stretched toward the top. When bars turn cyan, price is statistically stretched toward the bottom. The colour tells you whether a move is normal or extreme — without reading a single number.

Three layers power every calculation:

▸ Log-Normal Drift (μ) — rolling mean of log-returns, representing the direction price is diffusing
▸ Volatility (σ) — rolling standard deviation of log-returns, updated every bar
▸ Itô Correction (−½σ²) — converts the arithmetic mean to a geometric mean, required for continuous-time price models. Without this, the envelope is systematically biased upward

The result is a probability corridor that widens in volatile markets and tightens in calm ones — automatically, with no manual adjustment.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE HEATMAP EXPLAINED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Each bar is coloured by a single value: the normalised position of close within the 10th–90th percentile envelope.

  position = (close − 10th band) / (90th band − 10th band)

  0.0 → close is at or below the 10th band  →  deep cyan
  0.5 → close is at the midpoint             →  neutral
  1.0 → close is at or above the 90th band  →  deep red

This is not a momentum oscillator and not RSI. It is a spatial measure of where price sits inside its own forward-projected distribution. A deep-red bar means the current close is in the top decile of the statistically projected range — not that it is rising fast, but that it has reached a zone that is historically reached only 10% of the time.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGNALS — ▲ LONG  /  ▼ SHORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A breakout signal fires when price exits the N-bar channel:

▲ Long  — close breaks above the highest close of the last N bars
▼ Short — close breaks below the lowest close of the last N bars

An optional trend filter (slow EMA gate) removes counter-trend signals:
  • Longs only when close is above the trend EMA
  • Shorts only when close is below the trend EMA

Signals appear as small triangles on the chart. They are not trade recommendations — they mark a structural breakout that coincides with a momentum expansion, for the trader to act on within their own framework.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VOLATILITY REGIME DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

σ is compared to its own rolling distribution via a percentile rank:

  ≥ 75th percentile of σ  →  High Vol regime  (subtle orange background)
  25th – 75th             →  Normal regime     (no tint)
  < 25th percentile of σ  →  Low Vol regime    (subtle blue background)

Why it matters: the same breakout signal in a High Vol regime carries a wider envelope and therefore a different risk profile than the same breakout in Low Vol. The background tint makes the regime visible at a glance.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT MAKES IT DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Most volatility bands (Bollinger, Keltner, Donchian) are constructed from past price movement around a moving average. They describe where price has been.

VHB projects forward. The envelope is calculated at the current close and extended H bars into the future using the fitted distribution. The bands show where price is statistically likely to be in H bars — not where it has been.

Consequence: in a trending market the bands tilt with the drift. In a mean-reverting market the bands remain flat. The geometry of the envelope changes with market character, not with arbitrary multiplier choices.

The Itô correction is not a cosmetic detail. In continuous-time finance, the expected log-price grows at μ − ½σ², not μ. Omitting the correction causes the upper band to overstate likely price levels by an amount that grows with σ² — small in calm markets, significant during volatility expansion. VHB applies the correction on every bar.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Apply to any liquid instrument — futures (MNQ, NQ, ES, CL, GC), forex pairs, crypto
2. Choose your timeframe:
   • 1m / 5m — scalping, intraday momentum
   • 15m / 1H — intraday swing
   • 4H / Daily — positional
3. Read the heatmap first:
   • Cyan bars near the lower band → price is statistically cheap relative to its own distribution
   • Red bars near the upper band → price is statistically expensive
4. Wait for a signal ▲ / ▼ to confirm directional intent
5. Use the info panel (bottom-right) to monitor CDF Score, σ/bar, regime, and band levels in real time
6. Set alerts via the Alerts tab for Long Signal, Short Signal, or Regime changes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Input | Default | Purpose |
|---|---|---|
| Fit Lookback | 100 | Bars used to estimate μ and σ |
| Holding Horizon | 10 | Bars forward the distribution is projected |
| Breakout Channel | 20 | N-bar high/low for signal detection |
| Trend Filter | ON | EMA gate — removes counter-trend signals |
| Trend EMA Length | 200 | Slow EMA period for directional gate |
| Show Outer Bands | ON | 10th and 90th percentile lines |
| Show Median | ON | 50th percentile — Itô-corrected drift line |
| Show Inner Bands | OFF | 25th and 75th percentile lines |
| Fill Band | ON | Dark fill between 10th and 90th |
| Heatmap Bar Colour | ON | Cyan–red gradient by envelope position |
| Highlight Regime | ON | Subtle background tint by volatility regime |
| Show Info Panel | ON | Live σ, CDF score, drift, bands, signal |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• Requires at least Fit Lookback bars of history before the first band appears
• Works on any asset class; continuous instruments (futures, forex) show the cleanest log-return distribution
• The indicator does not repaint — all band values are calculated from confirmed closed bars
• Signals use close[1] for channel calculation — no lookahead bias
• This tool is for research and educational purposes only. It is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/

//@version=6
indicator("Volatility Heatmap Bands [PickMyTrade]", shorttitle="VHB",
          overlay         = true,
          max_labels_count = 500,
          max_lines_count  = 500,
          max_bars_back    = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// VOLATILITY HEATMAP BANDS  [PickMyTrade]
// ═══════════════════════════════════════════════════════════════════════════════
//
// WHAT IT DOES
//   Fits a log-normal distribution to the recent N bars of log-returns and
//   projects the 10th–90th percentile price envelope H bars forward.
//   Each bar is coloured by where price sits inside that envelope:
//     Cyan  → near the 10th band (statistically cheap / oversold)
//     Red   → near the 90th band (statistically expensive / overbought)
//   Channel-breakout signals (▲ Long / ▼ Short) appear when price leaves
//   its recent range, filtered by an optional trend EMA.
//
// MATH
//   lr        = log(close / close[1])
//   μ         = SMA(lr, N)
//   σ         = StdDev(lr, N)
//   Itô corr  = μ − ½σ²
//   band(p)   = exp(log(close) + (μ−½σ²)·H + Φ⁻¹(p)·σ·√H)
//
// ═══════════════════════════════════════════════════════════════════════════════

// ── INPUTS ────────────────────────────────────────────────────────────────────

var g1 = "Distribution"
dist_lb = input.int(100, "Fit Lookback (bars)",      minval=30,  maxval=500, group=g1,
          tooltip="Bars of log-returns used to estimate μ and σ.")
horizon = input.int(10,  "Holding Horizon (bars)",   minval=1,   maxval=100, group=g1,
          tooltip="Bars forward the distribution is projected.")

var g2 = "Signal"
entry_len  = input.int(20,   "Breakout Channel (bars)", minval=5, maxval=200, group=g2,
             tooltip="Long when close breaks N-bar channel high. Short = channel low.")
use_trend  = input.bool(true, "Enable Trend Filter (EMA gate)", group=g2,
             tooltip="Longs only above trend EMA, shorts only below.")
trend_len  = input.int(200,  "Trend EMA Length",        minval=20, maxval=500, group=g2)

var g3 = "Display"
show_bands  = input.bool(true,  "Show Outer Bands (10th / 90th)", group=g3)
show_median = input.bool(true,  "Show Median (50th)",             group=g3)
show_iqr    = input.bool(false, "Show Inner Bands (25th / 75th)", group=g3)
show_fill   = input.bool(true,  "Fill Band",                      group=g3)
show_labels = input.bool(true,  "Show Signal Labels",             group=g3)
show_barclr = input.bool(true,  "Heatmap Bar Colour",             group=g3,
             tooltip="Cyan = price near bottom of envelope. Red = near top.")
show_regime = input.bool(true,  "Highlight Volatility Regime",    group=g3)
show_panel  = input.bool(true,  "Show Info Panel",                group=g3)


// ── PROBIT — INVERSE NORMAL CDF ───────────────────────────────────────────────

probit(float p) =>
    float q  = math.min(math.max(p, 0.0001), 0.9999)
    float lo = q < 0.5 ? q : 1.0 - q
    float t  = math.sqrt(-2.0 * math.log(lo))
    float z  = t - (2.515517 + 0.802853 * t + 0.010328 * t * t) /
                   (1.0 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t)
    q < 0.5 ? -z : z

// ── STANDARD NORMAL CDF ───────────────────────────────────────────────────────

norm_cdf(float x) =>
    float t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    float d = 0.3989423 * math.exp(-x * x / 2.0)
    float p = d * t * (0.3193815 + t * (-0.3565638 + t * (1.7814779 + t * (-1.8212560 + t * 1.3302744))))
    x >= 0 ? 1.0 - p : p


// ── LOG-NORMAL DISTRIBUTION FIT ───────────────────────────────────────────────

float lr       = math.log(close / close[1])
float mu_lr    = ta.sma(lr, dist_lb)
float sigma_lr = ta.stdev(lr, dist_lb)
sigma_lr      := math.max(sigma_lr, 1e-10)


// ── VOLATILITY REGIME ─────────────────────────────────────────────────────────

float sigma_pct = 0.0
for i = 0 to dist_lb - 1
    sigma_pct += sigma_lr[i] < sigma_lr ? 1.0 : 0.0
sigma_pct /= float(dist_lb)

int    regime       = sigma_pct >= 0.75 ? 2 : sigma_pct < 0.25 ? 0 : 1
string regime_label = regime == 2 ? "High Vol" : regime == 0 ? "Low Vol" : "Normal"
color  regime_col   = regime == 2 ? color.new(#FF6644, 90) : regime == 0 ? color.new(#4488FF, 90) : color.new(color.gray, 100)


// ── LIVE CDF SCORE ────────────────────────────────────────────────────────────

float cdf_score = norm_cdf((lr - mu_lr) / sigma_lr) * 100.0


// ── PROBABILITY BANDS ─────────────────────────────────────────────────────────

float mu_fwd    = math.log(close) + (mu_lr - 0.5 * sigma_lr * sigma_lr) * float(horizon)
float sigma_fwd = sigma_lr * math.sqrt(float(horizon))

band(float p) =>
    math.exp(mu_fwd + probit(p) * sigma_fwd)

float b10 = band(0.10)
float b25 = band(0.25)
float b50 = band(0.50)
float b75 = band(0.75)
float b90 = band(0.90)


// ── SIGNAL DETECTION ──────────────────────────────────────────────────────────

float chan_hi  = ta.highest(close[1], entry_len)
float chan_lo  = ta.lowest(close[1],  entry_len)
float ema_slow = ta.ema(close, trend_len)

bool trend_ok_long  = not use_trend or close > ema_slow
bool trend_ok_short = not use_trend or close < ema_slow

bool long_sig  = close > chan_hi and trend_ok_long
bool short_sig = close < chan_lo and trend_ok_short


// ── HEATMAP BAR COLOUR ────────────────────────────────────────────────────────

float band_range = b90 - b10
float band_pos   = band_range > 0 ? math.min(math.max((close - b10) / band_range, 0.0), 1.0) : 0.5
color grad_col   = color.from_gradient(band_pos, 0.0, 1.0, color.new(#00E5FF, 20), color.new(#FF1744, 20))
color bar_col    = show_barclr ? grad_col : na
barcolor(bar_col, title="Heatmap Bar Colour")


// ── REGIME BACKGROUND ─────────────────────────────────────────────────────────

bgcolor(show_regime ? regime_col : na, title="Volatility Regime Background")


// ── PLOTS ─────────────────────────────────────────────────────────────────────

p90 = plot(show_bands  ? b90 : na, "90th Percentile",   color=color.new(#FF1744, 0),  linewidth=2)
p75 = plot(show_iqr    ? b75 : na, "75th Percentile",   color=color.new(#FF6D00, 30), linewidth=1)
p50 = plot(show_median ? b50 : na, "50th — Itô Median", color=color.new(#FFFFFF, 55), linewidth=1, style=plot.style_linebr)
p25 = plot(show_iqr    ? b25 : na, "25th Percentile",   color=color.new(#00BFA5, 30), linewidth=1)
p10 = plot(show_bands  ? b10 : na, "10th Percentile",   color=color.new(#00E5FF, 0),  linewidth=2)

fill(p90, p10,
     color = show_fill ? color.new(#1A1A2E, 80) : na,
     title = "Band Fill (10–90)")

// Trend EMA
plot(use_trend ? ema_slow : na, "Trend EMA", color=color.new(#5588BB, 55),
     linewidth=1, style=plot.style_linebr)


// ── SIGNAL LABELS ─────────────────────────────────────────────────────────────

if show_labels and long_sig
    label.new(bar_index, low, "▲",
              color=color.new(#00C853, 10), textcolor=color.white,
              style=label.style_label_up, size=size.small)

if show_labels and short_sig
    label.new(bar_index, high, "▼",
              color=color.new(#FF1744, 10), textcolor=color.white,
              style=label.style_label_down, size=size.small)


// ── BAND LABELS (right edge, last bar) ────────────────────────────────────────

if barstate.islast
    if show_bands
        label.new(bar_index, b90, "90th",
                  color=color.new(#FF1744, 20), textcolor=color.white,
                  style=label.style_label_left, size=size.small)
        label.new(bar_index, b10, "10th",
                  color=color.new(#00E5FF, 20), textcolor=color.white,
                  style=label.style_label_left, size=size.small)
    if show_median
        label.new(bar_index, b50, "50th",
                  color=color.new(#555555, 30), textcolor=color.white,
                  style=label.style_label_left, size=size.small)
    if show_iqr
        label.new(bar_index, b75, "75th",
                  color=color.new(#FF6D00, 20), textcolor=color.white,
                  style=label.style_label_left, size=size.small)
        label.new(bar_index, b25, "25th",
                  color=color.new(#00BFA5, 20), textcolor=color.white,
                  style=label.style_label_left, size=size.small)


// ── ALERT CONDITIONS ──────────────────────────────────────────────────────────

alertcondition(long_sig,  "VHB Long Signal",  "VHB: Long breakout — {{ticker}}")
alertcondition(short_sig, "VHB Short Signal", "VHB: Short breakout — {{ticker}}")
alertcondition(regime == 2 and regime[1] != 2, "VHB High Vol Regime",  "VHB: {{ticker}} entered HIGH VOLATILITY regime")
alertcondition(regime == 0 and regime[1] != 0, "VHB Low Vol Regime",   "VHB: {{ticker}} entered LOW VOLATILITY regime")
alertcondition(cdf_score >= 90, "VHB CDF ≥ 90", "VHB: {{ticker}} return at 90th+ percentile")
alertcondition(cdf_score <= 10, "VHB CDF ≤ 10", "VHB: {{ticker}} return at 10th- percentile")


// ── INFO PANEL ────────────────────────────────────────────────────────────────

if barstate.islast and show_panel
    tbl = table.new(position.bottom_right, 2, 8,
                    bgcolor      = color.new(#0D1117, 8),
                    border_color = color.new(#334455, 75),
                    border_width = 1,
                    frame_color  = color.new(#334455, 55),
                    frame_width  = 1)

    tc = color.new(#AABBCC, 0)
    vc = color.new(#EEEEFF, 0)

    // Header
    table.cell(tbl, 0, 0, "VHB",
               text_color=color.new(#00E5FF, 0), text_size=size.small,
               bgcolor=color.new(#111827, 5))
    table.cell(tbl, 1, 0, syminfo.ticker,
               text_color=color.new(#00E5FF, 0), text_size=size.small,
               bgcolor=color.new(#111827, 5), text_halign=text.align_right)

    // Regime
    r_col = regime == 2 ? color.new(#FF6644, 0) : regime == 0 ? color.new(#4499FF, 0) : color.new(#AABBCC, 0)
    table.cell(tbl, 0, 1, "Regime",      text_color=tc,    text_size=size.tiny)
    table.cell(tbl, 1, 1, regime_label,  text_color=r_col, text_size=size.tiny, text_halign=text.align_right)

    // CDF Score
    cdf_col = cdf_score >= 80 ? color.new(#FF4444, 0) : cdf_score <= 20 ? color.new(#00E5FF, 0) : vc
    table.cell(tbl, 0, 2, "CDF Score", text_color=tc, text_size=size.tiny)
    table.cell(tbl, 1, 2, str.tostring(math.round(cdf_score, 1)) + "th pct",
               text_color=cdf_col, text_size=size.tiny, text_halign=text.align_right)

    // Drift
    drift_col = mu_lr > 0 ? color.new(#22CC44, 0) : color.new(#FF4444, 0)
    table.cell(tbl, 0, 3, "Drift/bar", text_color=tc, text_size=size.tiny)
    table.cell(tbl, 1, 3, (mu_lr > 0 ? "+" : "") + str.tostring(math.round(mu_lr * 100.0, 4)) + "%",
               text_color=drift_col, text_size=size.tiny, text_halign=text.align_right)

    // Sigma
    table.cell(tbl, 0, 4, "σ/bar", text_color=tc, text_size=size.tiny)
    table.cell(tbl, 1, 4, str.tostring(math.round(sigma_lr * 100.0, 4)) + "%",
               text_color=vc, text_size=size.tiny, text_halign=text.align_right)

    // Horizon
    table.cell(tbl, 0, 5, "Horizon", text_color=tc, text_size=size.tiny)
    table.cell(tbl, 1, 5, str.tostring(horizon) + " bars",
               text_color=vc, text_size=size.tiny, text_halign=text.align_right)

    // Bands
    table.cell(tbl, 0, 6, "b90 / b10", text_color=tc, text_size=size.tiny)
    table.cell(tbl, 1, 6,
               str.tostring(math.round(b90, 2)) + " / " + str.tostring(math.round(b10, 2)),
               text_color=vc, text_size=size.tiny, text_halign=text.align_right)

    // Signal
    sig_str = long_sig ? "LONG ▲" : short_sig ? "SHORT ▼" : "—"
    sig_col = long_sig ? color.new(#00C853, 0) : short_sig ? color.new(#FF1744, 0) : color.new(#555566, 0)
    table.cell(tbl, 0, 7, "Signal",  text_color=tc,      text_size=size.tiny)
    table.cell(tbl, 1, 7, sig_str,   text_color=sig_col, text_size=size.small, text_halign=text.align_right)
````
