# BTC Potential Energy

- url: https://www.tradingview.com/script/s9RAL9EM-BTC-Potential-Energy/
- type: indicator
- pine_id: PUB;2e30721d8de84d7aabea017666c53885
- version: 1.0

## Description

[b]BTC Potential Energy[/b] is a macro-cycle oscillator that tracks how much "dry powder" is sitting in Tether (USDT) relative to its structural baseline — and translates that into a 0–100 potential energy score for Bitcoin. The core idea is simple: when investors are parking abnormal amounts of capital in stablecoins, that capital isn't gone — it's coiled. The higher the stablecoin accumulation above its own historical trend, the greater the potential for a violent rotation back into Bitcoin when sentiment shifts.

The indicator displays as a sub-pane oscillator beneath your BTC chart and is designed primarily for use on the [b]Weekly or Daily timeframe[/b], where macro cycle analysis is most meaningful.


[b]The Concept: Stablecoins as a Coiled Spring[/b]

In crypto markets, Tether Dominance (USDT.D) is the percentage of total crypto market cap held in USDT. It rises when investors flee risk — selling Bitcoin and altcoins into stablecoins — and falls when investors deploy that capital back into the market.

This creates a physics-like analogy:

[b]Compression phase[/b] — USDT.D rises as capital moves to safety. Like compressing a spring, potential energy builds.
[b]Release phase[/b] — USDT.D begins to fall. The spring releases. Capital rotates into BTC, historically preceding or coinciding with the early stages of bull runs.

The further above normal USDT.D is, and the more abruptly it starts declining, the more powerful that rotation tends to be.


[b]The Problem With Naive USDT.D Analysis[/b]

The most obvious approach — ranking the raw USDT.D value over history — fails in practice. Why? Because the stablecoin market has grown enormously since 2017. USDT.D in 2021 was structurally higher in absolute percentage terms than in 2018, simply because more stablecoins exist and are used as a base layer across DeFi and centralised exchanges. This secular uptrend means that if you rank raw USDT.D, the indicator reads "high energy" throughout the 2021 bull market — [i]precisely when energy was already deployed and Bitcoin was already running.[/i] That is the opposite of useful.


[b]The Solution: Detrended Potential Energy[/b]

BTC Potential Energy solves this by ranking the [b]deviation of USDT.D from its own long-term moving average[/b], not the raw level itself. This strips out the structural growth of the stablecoin market and isolates only the [i]anomalous[/i] accumulation — the excess fear-driven or cycle-driven flight to safety that goes beyond what the baseline trend would predict.

[b]Step 1 — Establish the Baseline[/b]
A long Simple Moving Average (default: 100 bars) is computed on USDT.D. On the weekly chart, this represents approximately 2 years — roughly one full Bitcoin market cycle. This MA acts as the "expected" or structural level of stablecoin dominance for any given period. It rises gradually over time as the stablecoin ecosystem matures, automatically adjusting the baseline to the era.

[b]Step 2 — Compute the Deviation[/b]
The deviation is calculated as:

[i]Deviation = USDT.D − Baseline MA[/i]

A [b]positive deviation[/b] means USDT.D is elevated above its own trend — investors are accumulating stablecoins beyond what the baseline predicts. This is abnormal stablecoin hoarding, and it represents genuine potential energy.

A [b]negative deviation[/b] means USDT.D is below trend — capital has already been deployed into risk assets. Energy has been discharged.

[b]Step 3 — Percentile Rank the Deviation[/b]
The current deviation is ranked as a percentile against all deviation values in a rolling lookback window (default: 200 bars). This produces the final Potential Energy score on a 0–100 scale:

[b]100[/b] = The current stablecoin accumulation anomaly is the most extreme it has been in the entire lookback window. Maximum coiled energy.
[b]50[/b] = Deviation is average. Neutral state.
[b]0[/b] = USDT.D is at its most suppressed relative to trend. Capital is fully deployed. Energy is discharged.

This approach is robust across all market eras and does not require re-calibration as the stablecoin ecosystem grows.


[b]The Four Energy States[/b]

The indicator identifies one of four states on every bar, displayed in the live info table and used to determine histogram colour.

[b]ACCUMULATING[/b] [i](Blue)[/i]
PE is below 40. USDT.D is near or below its structural baseline. Capital is deployed or neutral. The market is in an active risk-on phase or the bear market has not yet produced meaningful stablecoin accumulation. No elevated potential energy.

[b]BUILDING[/b] [i](Amber)[/i]
PE is between 40 and the Charge Threshold, and is rising. Stablecoin accumulation is growing above the baseline. Investors are beginning to retreat from risk. Potential energy is loading. Worth monitoring but not yet at an actionable level.

[b]CHARGED[/b] [i](Orange/Red)[/i]
PE is above the Charge Threshold (default: 65). USDT.D is historically elevated relative to its own trend. A significant amount of capital is sitting in stablecoins beyond what the baseline predicts. The spring is fully coiled. Bitcoin's potential energy is at its most loaded.

[b]RELEASING[/b] [i](Green)[/i]
PE is above the Charge Threshold AND USDT.D deviation has been declining for N consecutive bars (default: 3). This is the critical state — energy that was compressed is now actively unwinding. Capital is rotating out of stablecoins. Historically, this condition — high stablecoin accumulation followed by a structural reversal — has preceded or coincided with meaningful Bitcoin bull moves.


[b]Release Signal Logic[/b]

The release signal is intentionally conservative. Two conditions must be met simultaneously:

[b]1. Armed:[/b] The Potential Energy score must be at or above the Charge Threshold. The spring must actually be compressed before a "release" means anything. A declining USDT.D from a low base is not a release — it's just noise.

[b]2. Declining:[/b] USDT.D deviation must have been falling for at least N consecutive bars (configurable). This filters out single-bar blips and requires a structural turn, not just a one-week dip.

When both conditions are met, the histogram turns green for the duration of the release phase, and an alert can be triggered on the first bar the signal fires.


[b]Visual Guide[/b]

[b]Histogram colour[/b]
Deep Blue → Sky Blue: Low energy (PE 0–50), capital deployed
Gold: Moderate energy (PE 50–threshold), building phase
Amber/Orange: High energy (PE above threshold), fully charged
Green: Release phase active — deviation unwinding from a high base

[b]Background glow:[/b] Subtly tints the pane background to reflect the current energy state — deep blue at low energy, warming to amber and orange as energy builds.

[b]Dashed orange line:[/b] The Charge Threshold. PE crossing above this line arms the release detector.

[b]Dotted grey line:[/b] The 50 midpoint. PE above 50 means the deviation is in the upper half of its historical range.

[b]Fast MA (blue) / Slow MA (pink):[/b] Moving averages of the USDT.D deviation, projected into the 0–100 PE space. When fast crosses above slow, deviation is accelerating upward — energy building faster. When fast crosses below slow from above the threshold, it can precede a release signal.

[b]Info Table (top right):[/b]
Energy Level — Current PE score out of 100
USDT.D — Raw live Tether Dominance reading
Baseline — The long MA value, the structural floor
Deviation — How many percentage points USDT.D is above or below baseline (+ is elevated, − is deployed)
State — Current energy state in plain text
Trend MA — The baseline length setting in use


[b]Settings Reference[/b]

[b]Percentile Lookback (default: 200)[/b]
The rolling window used to rank the current deviation. Longer lookbacks give more historical context but are slower to respond to structural shifts. 200 bars on the weekly is approximately 4 years — long enough to capture a full bull/bear cycle.

[b]Trend Baseline MA (default: 100)[/b]
The most important parameter. This defines the structural floor. On the weekly chart, 100 bars is roughly 2 years — approximately one Bitcoin market cycle. Shorter values (e.g. 52 bars = 1 year) make the baseline more responsive, which can be useful on the daily chart. Longer values (130–150 bars) create a smoother, slower-moving baseline that irons out mid-cycle noise.

[b]Signal Smoothing (default: 3)[/b]
EMA applied to raw USDT.D before any calculations. Reduces candle-to-candle noise in the source data. Higher values produce a cleaner but more lagged signal.

[b]Charge Threshold (default: 65)[/b]
The PE level that must be reached before the release detector is armed. Raising this to 70–80 produces fewer, higher-conviction signals. Lowering it to 55–60 will trigger signals more frequently but with potentially lower reliability.

[b]Consecutive Bars Declining (default: 3)[/b]
The number of consecutive bars that the deviation must be falling before a release is confirmed. Increasing this requires a more sustained reversal and reduces false positives. On the weekly chart, 3 bars is already meaningful — that is 3 weeks of sustained stablecoin outflows.

[b]Fast MA / Slow MA Length (defaults: 14 / 50)[/b]
Moving averages of the deviation plotted in PE space. The crossover of fast above slow while PE is below threshold is worth watching as early warning of building energy. A crossover of fast below slow from above the threshold can precede a release signal.


[b]Recommended Usage[/b]

[b]Timeframe:[/b] Weekly or Daily. This is a macro cycle indicator. Do not use it to time intraday entries — it is not designed for that.

[b]Combine with price structure:[/b] The release signal is most powerful when it aligns with Bitcoin reclaiming a key level, a breakout of a multi-month range, or a bullish divergence on a momentum indicator. The Potential Energy score tells you the setup is primed — price action confirmation tells you it is firing.

[b]Watch the Deviation column:[/b] The live table shows the raw deviation in percentage points. A deviation of +1.5% means USDT.D is 1.5 percentage points above its 2-year average — that is a meaningful anomaly. Watching this number decline from a peak as the state transitions from CHARGED to RELEASING gives an intuitive real-time read of the rotation.

[b]Baseline MA tuning:[/b] On the weekly chart, start with the default 100. On the daily chart, consider reducing the Trend Baseline MA to around 52 bars to keep the baseline responsive to faster-moving daily USDT.D data.


[b]Alerts[/b]

Three alert conditions are available:

[b]BTC PE — Energy Release:[/b] Fires on the first bar the release condition is met. The most actionable alert. USDT.D deviation is actively unwinding from an elevated zone.
[b]BTC PE — Fully Charged:[/b] Fires when PE crosses above the Charge Threshold from below. Signals that potential energy has entered the high zone.
[b]BTC PE — Energy Exiting High Zone:[/b] Fires when PE crosses below the Charge Threshold from above. Useful as a heads-up that the setup may be resolving.


[b]Notes[/b]

This indicator uses [i]request.security("CRYPTOCAP:USDT.D")[/i] to pull Tether Dominance data sourced from CoinMarketCap's crypto market cap feed via TradingView.

[i]This indicator is a research and analysis tool. It does not constitute financial advice. Past correlations between Tether Dominance behaviour and Bitcoin price movements do not guarantee future results. Always combine macro oscillator readings with your own price analysis, risk management framework, and market context.[/i]

## Source Code

````pine
// ============================================================
// BTC POTENTIAL ENERGY
// ============================================================
// Concept: Tether Dominance (USDT.D) acts as a "charge" metric.
// When capital flees into stablecoins beyond the structural
// baseline, potential energy builds for a BTC bull leg.
// When that excess stablecoin dominance unwinds, energy releases.
//
// Key fix — DETRENDED PE:
//  USDT.D has a secular uptrend (stablecoin market grew ~10x
//  since 2018). Ranking raw USDT.D levels keeps energy "high"
//  throughout bull markets, which is misleading.  Instead we
//  rank the DEVIATION of USDT.D from its own long-term MA.
//  This isolates "abnormal stablecoin accumulation" from the
//  structural baseline — energy is only high when USDT.D is
//  genuinely elevated above its own trend, regardless of era.
//
// Components
//  • Trend Baseline  : Long SMA of USDT.D (structural floor)
//  • Deviation       : USDT.D minus its baseline (the signal)
//  • Potential Energy: Percentile rank of deviation (0–100)
//  • Release Signal  : High energy AND deviation turning down
// ============================================================

//@version=5
indicator(title           = "BTC Potential Energy",
          shorttitle      = "BTC PE",
          overlay         = false,
          max_lines_count = 100)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_data   = "Data Settings"
lookback   = input.int(200, "Percentile Lookback (bars)", minval=50, maxval=500, group=grp_data,
     tooltip="Window used to rank the current deviation against history.")
trend_len  = input.int(100, "Trend Baseline MA (bars)",   minval=20, maxval=300, group=grp_data,
     tooltip="Long MA defining the structural USDT.D baseline. Deviation above this = energy building. On weekly: 100 bars = ~2 years.")
smoothing  = input.int(3,   "Signal Smoothing (EMA)",     minval=1,  maxval=21,  group=grp_data)

grp_rel    = "Release Signal"
rel_thresh = input.int(65, "Charge Threshold (%)", minval=40, maxval=95, group=grp_rel,
     tooltip="PE must be above this level before a release signal can fire.")
rel_decline = input.int(3, "Consecutive bars declining", minval=1, maxval=10, group=grp_rel)

grp_ma     = "Moving Averages"
show_fast  = input.bool(true, "Show Fast MA", group=grp_ma)
show_slow  = input.bool(true, "Show Slow MA", group=grp_ma)
fast_len   = input.int(14, "Fast MA Length", minval=2,  maxval=50,  group=grp_ma)
slow_len   = input.int(50, "Slow MA Length", minval=10, maxval=200, group=grp_ma)

grp_vis    = "Visuals"
show_zones = input.bool(true, "Show Energy Zones",   group=grp_vis)
show_bg    = input.bool(true, "Show Background Glow", group=grp_vis)

// ─────────────────────────────────────────────
//  FETCH USDT.D
// ─────────────────────────────────────────────
[usdtd_raw, usdtd_vol] = request.security(
     "CRYPTOCAP:USDT.D",
     timeframe.period,
     [close, volume],
     lookahead = barmerge.lookahead_off)

usdtd = ta.ema(usdtd_raw, smoothing)

// ─────────────────────────────────────────────
//  DETREND — subtract the structural baseline
// ─────────────────────────────────────────────
// Removes the secular growth in stablecoin market share.
// Positive deviation = USDT.D abnormally elevated above trend
//                    = genuine stablecoin hoarding = energy
// Negative deviation = USDT.D below its own trend = deployed
usdtd_baseline = ta.sma(usdtd, trend_len)
usdtd_dev      = usdtd - usdtd_baseline

// ─────────────────────────────────────────────
//  POTENTIAL ENERGY  (percentile rank of deviation)
// ─────────────────────────────────────────────
rank_count = 0.0
for i = 1 to lookback
    if usdtd_dev[i] < usdtd_dev
        rank_count += 1.0

pe          = (rank_count / lookback) * 100
pe_roc      = pe - pe[5]
pe_smoothed = ta.ema(pe, 5)

// ─────────────────────────────────────────────
//  MAs of deviation projected into PE space
// ─────────────────────────────────────────────
fast_dev_ma = ta.ema(usdtd_dev, fast_len)
slow_dev_ma = ta.ema(usdtd_dev, slow_len)

dev_min = ta.lowest (usdtd_dev, lookback)
dev_max = ta.highest(usdtd_dev, lookback)
dev_rng = dev_max - dev_min

fast_ma_pe = dev_rng != 0 ? ((fast_dev_ma - dev_min) / dev_rng) * 100 : 50.0
slow_ma_pe = dev_rng != 0 ? ((slow_dev_ma - dev_min) / dev_rng) * 100 : 50.0

// ─────────────────────────────────────────────
//  RELEASE SIGNAL LOGIC
// ─────────────────────────────────────────────
armed = pe >= rel_thresh

consecutive_declines = 0
for j = 0 to rel_decline - 1
    if usdtd_dev[j] < usdtd_dev[j + 1]
        consecutive_declines += 1

release_signal  = armed and (consecutive_declines >= rel_decline)
release_trigger = release_signal and not release_signal[1]

// ─────────────────────────────────────────────
//  COMPRESSION BUILDUP
// ─────────────────────────────────────────────
building = pe >= 40 and pe < rel_thresh and pe_roc > 0

// ─────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────
energy_color = pe >= 80 ? color.new(#FF4500, 0) : pe >= rel_thresh ? color.new(#FF8C00, 0) : pe >= 50 ? color.new(#FFD700, 0) : pe >= 30 ? color.new(#00BFFF, 30) : color.new(#1E90FF, 20)

hist_color = release_signal ? color.new(#00FF88, 0) : building ? color.new(#FF8C00, 30) : energy_color

bg_color = pe >= rel_thresh ? color.new(#FF4500, 94) : pe >= 50 ? color.new(#FFD700, 96) : color.new(#1E4D7B, 97)

// ─────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────

bgcolor(show_bg ? bg_color : na, title="Energy Glow")

hline(rel_thresh, "Charge Threshold", color.new(#FF4500, 45), linestyle=hline.style_dashed,  linewidth=1)
hline(50,         "Mid",              color.new(color.gray, 70), linestyle=hline.style_dotted, linewidth=1)

r_line = plot(show_zones ? rel_thresh : na, display=display.none)
top    = plot(show_zones ? 100        : na, display=display.none)
fill(r_line, top, color.new(#FF4500, 96), title="High Energy Zone")

plot(pe_smoothed, title="Potential Energy", style=plot.style_histogram, color=hist_color, linewidth=2)
plot(pe_smoothed, title="PE Line",          style=plot.style_line, color=color.new(color.white, 70), linewidth=1)

plot(show_fast ? fast_ma_pe : na, title="Fast MA", color=color.new(#00BFFF, 40), linewidth=1)
plot(show_slow ? slow_ma_pe : na, title="Slow MA", color=color.new(#FF69B4, 40), linewidth=1)

// ─────────────────────────────────────────────
//  INFO TABLE
// ─────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 7,
     bgcolor      = color.new(color.black, 75),
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 40),
     frame_width  = 1)

state_text  = release_signal ? "RELEASING"   :
              armed          ? "CHARGED"      :
              building       ? "BUILDING"     :
                               "ACCUMULATING"

state_color = release_signal ? #00FF88 :
              armed          ? #FF4500 :
              building       ? #FFD700 :
                               #1E90FF

if barstate.islast
    table.cell(info, 0, 0, "BTC POTENTIAL ENERGY", text_color=color.white,
               text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color.black, 60))
    table.cell(info, 1, 0, "", bgcolor=color.new(color.black, 60))

    table.cell(info, 0, 1, "Energy Level", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(info, 1, 1, str.tostring(math.round(pe_smoothed, 1)) + " / 100",
               text_color=color.rgb(255, 220, 100), text_size=size.small)

    table.cell(info, 0, 2, "USDT.D", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(info, 1, 2, str.tostring(math.round(usdtd_raw, 3)) + "%",
               text_color=color.white, text_size=size.small)

    table.cell(info, 0, 3, "Baseline", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(info, 1, 3, str.tostring(math.round(usdtd_baseline, 3)) + "%",
               text_color=color.new(color.gray, 30), text_size=size.small)

    table.cell(info, 0, 4, "Deviation", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(info, 1, 4, (usdtd_dev >= 0 ? "+" : "") + str.tostring(math.round(usdtd_dev, 3)) + "%",
               text_color=usdtd_dev >= 0 ? #FF8C00 : #00BFFF, text_size=size.small)

    table.cell(info, 0, 5, "State", text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(info, 1, 5, state_text, text_color=color.rgb(
               color.r(state_color), color.g(state_color), color.b(state_color)),
               text_size=size.small)

    table.cell(info, 0, 6, "Trend MA", text_color=color.new(color.gray, 40), text_size=size.tiny)
    table.cell(info, 1, 6, str.tostring(trend_len) + " bars",
               text_color=color.new(color.gray, 40), text_size=size.tiny)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(release_trigger,
     title   = "BTC PE — Energy Release",
     message = "BTC Potential Energy is releasing. USDT.D deviation is unwinding from an elevated zone. Watch for a BTC bull leg.")

alertcondition(ta.crossover(pe_smoothed, rel_thresh),
     title   = "BTC PE — Fully Charged",
     message = "USDT.D deviation has entered the HIGH energy zone. Stablecoin accumulation is abnormally elevated above trend.")

alertcondition(ta.crossunder(pe_smoothed, rel_thresh),
     title   = "BTC PE — Energy Exiting High Zone",
     message = "Potential Energy dropping below the charge threshold. Energy may be deploying into BTC.")
````
