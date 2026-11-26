# Yield Spread Macro

- url: https://www.tradingview.com/script/1i4cH3HX-Yield-Spread-Macro/
- type: indicator
- pine_id: PUB;b902c004bf4c4eb1b5c4bd45a7177067
- version: 1.0

## Description

Yield Spread Macro — Indicator Guide
What it does
This indicator compares the interest rate differential between two countries against the actual FX price of their currency pair, both plotted on the same normalised scale so they can be directly compared. The core idea is that exchange rates are fundamentally driven by the difference in yields between two economies — when one country's rates are significantly higher than another's, capital tends to flow toward the higher-yielding currency, pushing its price up. This indicator tracks whether the FX price is keeping up with that yield story or diverging from it.

What you're looking at on the chart
Blue line — Yield Spread (z-score)
The interest rate differential between the US and the local country, normalised to show where it sits relative to its own history. Above zero means the spread is above average. Below zero means it has compressed.
Aqua line — FX Price (z-score)
The FX pair price, normalised on the same scale as the spread so the two can be directly compared.
Shaded fill between the lines
The gap between the spread and price. When this gap is wide, the two series have diverged — price is not reflecting what the rate differential is saying.
Coloured line (lime/yellow/orange/red) — Rolling Correlation
This is the most important line on the chart. It measures how closely the yield spread and FX price are actually tracking each other over the selected window. Think of it as a trust meter for the spread signal:

🟢 Above 0.80 — strong alignment, spread is a reliable guide right now
🟡 0.40–0.80 — moderate, use alongside other inputs
🟠 0.20–0.40 — weak, something else is driving the pair
🔴 Below 0.20 — regime shift, the spread relationship has broken down entirely

Green background / ▲ DIV label
The yield spread is rising but price has not caught up yet. If correlation is strong this suggests price may follow higher. If correlation is weak, treat it as a tension signal rather than a directional call.
Red background / ▼ DIV label
The yield spread is falling but price has not caught down yet. Price is elevated relative to where the rate differential says it should be. Same caveat — only a strong correlation makes this actionable.
Horizontal dotted lines
The ±1σ and ±2σ bands show historically stretched levels. When either the spread or price z-score pushes beyond ±2, it is statistically extended relative to the lookback window.

Settings explained
Pair Settings
FX Pair
The currency pair you want to analyse. Options are USDJPY, USDCAD, EURUSD, GBPUSD, AUDUSD. Changing this automatically updates all yield series, breakeven data, and FX price feeds — you don't need to change anything else.
Yield Timeframe
The timeframe used to fetch yield data. Default is Daily. Leaving this at D is recommended regardless of what chart timeframe you are on — yield data is most meaningful and cleanest on a daily basis.

General Settings
Normalization Length
The lookback window for the z-score calculation — how many bars of history the indicator uses to compute the average and standard deviation that everything is measured against.

Lower (20–50) — reactive, reflects recent history only, z-score moves frequently
Default (100) — roughly five months on a daily chart, good medium-term context
Higher (200–300) — structural, slow-moving, only flags genuinely historical extremes

If you are a shorter-term trader bring this down. If you want to see where things sit in a multi-year context bring it up.
Spread EMA Smoothing
Applied to the raw yield spread before it gets z-scored. Yield data can print erratic single-day spikes due to auction flows or data feed quirks. This smooths those out.

Lower (3–5) — close to raw spread, more reactive, more noise
Default (10) — removes day-to-day jitter while still tracking real moves
Higher (20–30) — only responds to sustained shifts in the differential, very smooth


Divergence Settings
Divergence Lookback (bars)
How far back the indicator looks when deciding whether the spread and price are moving in opposite directions. A divergence is flagged when the spread has moved one way and price has moved the other way over this window.

Lower (3–5) — very sensitive, signals fire frequently, more noise
Default (10) — roughly two trading weeks on a daily chart
Higher (20–30) — only flags sustained, structural divergences

Min Z-Score Gap to Flag Div
The minimum difference between the spread z-score and price z-score required before a divergence label appears. This prevents the labels from firing when the two lines are close together and the divergence is trivial.

Lower (0.1–0.2) — more signals, lower quality
Default (0.3) — reasonable filter for meaningful gaps
Higher (0.5+) — only the most extreme divergences get flagged


Correlation Settings
Correlation Length (bars)
The rolling window used to measure how tightly the yield spread and FX price are tracking each other. This is the most important setting to understand.

Lower (20–30) — very reactive, correlation shifts quickly, good for seeing regime changes as they happen but noisy
Default (60) — roughly three months on a daily chart, captures a meaningful regime without being too slow
Higher (120–200) — slow-moving, tells you about the long-run structural relationship rather than the current regime

Plot Correlation Line
Toggle the correlation line on or off. If you find the chart visually busy you can turn this off and rely on the table value instead.

Display Settings
Show Zero Line — the dashed horizontal line at zero. Useful reference for whether z-scores are above or below their historical average.
Show ±1σ / ±2σ — the dotted band lines. Turn off if you want a cleaner chart.
Show Data Table — the data panel in the top right corner showing all live values including FX price, yields, real yield, implied breakeven, spread in basis points, z-scores, divergence status, and correlation reading. Turn off if you don't need it or are using the indicator on a small screen.

How to read it in practice
The right workflow is to check the correlation first, then the divergence, in that order.

Check correlation. If it is below 0.40 the spread is not currently driving the pair and the divergence signals should be treated with scepticism. Something else — geopolitics, intervention risk, risk sentiment — is dominant.
Check the spread z-score. Is the differential historically stretched or compressed? Above +2 or below −2 is a significant reading.
Check the divergence. Is price keeping up with the spread or lagging it? A green divergence with strong correlation means price may have room to catch up higher. A red divergence with strong correlation means price may have room to correct lower.
Use the real yield toggle. Switching between nominal and real yields shows you how much of the spread is being driven by inflation expectations versus actual rate differentials. If the two modes show very different spreads, inflation expectations are a significant part of the story.

The indicator works best on a daily chart with the yield timeframe set to D. It is a macro context tool, not a precise entry signal — it tells you whether the fundamental backdrop supports a directional bias, and how much to trust that signal right now.

## Source Code

````pine
//@version=6
indicator('Yield Spread Macro', overlay = false)

// ============================================================
// === PAIR SELECTION ===
// ============================================================
grp_pair = 'Pair Settings'
pair_choice = input.string('USDJPY', 'FX Pair', options = ['USDJPY', 'USDCAD', 'EURUSD', 'GBPUSD', 'AUDUSD'], group = grp_pair)
yield_tf = input.timeframe('D', 'Yield Timeframe', group = grp_pair)

// ============================================================
// === GENERAL SETTINGS ===
// ============================================================
grp_general = 'General Settings'
lookback = input.int(100, 'Normalization Length', group = grp_general, minval = 20, maxval = 500)
ema_smooth = input.int(10, 'Spread EMA Smoothing', group = grp_general, minval = 1, maxval = 50)
use_real = input.bool(true, 'Use Real Yields (nominal − breakeven)', group = grp_general, tooltip = 'When enabled, subtracts 10Y breakeven inflation from each nominal yield before computing the spread. More structurally accurate but breakeven data is US-centric — see notes.')

// ============================================================
// === DIVERGENCE SETTINGS ===
// ============================================================
grp_div = 'Divergence Settings'
div_lookback = input.int(10, 'Divergence Lookback (bars)', group = grp_div, minval = 3, maxval = 50)
div_threshold = input.float(0.3, 'Min Z-Score Gap to Flag Div', group = grp_div, minval = 0.0, step = 0.05)

// ============================================================
// === CORRELATION SETTINGS ===
// ============================================================
grp_corr = 'Correlation Settings'
corr_length = input.int(60, 'Correlation Length (bars)', group = grp_corr, minval = 10, maxval = 300)
show_corr_plot = input.bool(true, 'Plot Correlation Line', group = grp_corr)

// ============================================================
// === DISPLAY SETTINGS ===
// ============================================================
grp_display = 'Display'
show_zero = input.bool(true, 'Show Zero Line', group = grp_display)
show_bands = input.bool(true, 'Show ±1σ / ±2σ', group = grp_display)
show_table = input.bool(true, 'Show Data Table', group = grp_display)

// ============================================================
// === PAIR CONFIGURATION MAP ===
// ============================================================
fx_ticker = pair_choice == 'USDJPY' ? 'FX:USDJPY' : pair_choice == 'USDCAD' ? 'FX:USDCAD' : pair_choice == 'EURUSD' ? 'FX:EURUSD' : pair_choice == 'GBPUSD' ? 'FX:GBPUSD' : 'FX:AUDUSD'

local_yield = pair_choice == 'USDJPY' ? 'TVC:JP10Y' : pair_choice == 'USDCAD' ? 'TVC:CA10Y' : pair_choice == 'EURUSD' ? 'TVC:DE10Y' : pair_choice == 'GBPUSD' ? 'TVC:GB10Y' : 'TVC:AU10Y'

// Breakeven inflation series (10Y inflation expectations)
// US:  TVC:USBE10Y  — deep, liquid, reliable
// JP:  TVC:JPBE10Y  — reasonable quality
// CA:  TVC:CABE10Y  — reasonable quality
// DE:  TVC:DEBE10Y  — Eurozone proxy, acceptable for EUR pairs
// GB:  TVC:GBBE10Y  — reasonable quality
// AU:  TVC:AUBE10Y  — thinner than US but usable
// Note: where local breakeven data is thin, the real yield
// approximation is less precise — nominal spread remains available
// via the toggle as a fallback


spread_sign = pair_choice == 'EURUSD' ? -1 : pair_choice == 'GBPUSD' ? -1 : pair_choice == 'AUDUSD' ? -1 : 1

local_label = pair_choice == 'USDJPY' ? 'JP10Y' : pair_choice == 'USDCAD' ? 'CA10Y' : pair_choice == 'EURUSD' ? 'DE10Y' : pair_choice == 'GBPUSD' ? 'GB10Y' : 'AU10Y'

local_be_label = pair_choice == 'USDJPY' ? 'JPBE10Y' : pair_choice == 'USDCAD' ? 'CABE10Y' : pair_choice == 'EURUSD' ? 'DEBE10Y' : pair_choice == 'GBPUSD' ? 'GBBE10Y' : 'AUBE10Y'

// ============================================================
// === DATA FETCH ===
// ============================================================
us10y = request.security('TVC:US10Y', yield_tf, close)
local10y = request.security(local_yield, yield_tf, close)
fx_price = request.security(fx_ticker, timeframe.period, close)

// US 10Y real yield — direct from FRED (nominal minus TIPS breakeven)
// This is the cleanest real yield series available on TradingView
us_real_direct = request.security('FRED:DFII10', yield_tf, close)

// Local real yields — approximated where direct series unavailable
// JP: use nominal JP10Y minus Tokyo CPI YoY as inflation proxy
// CA: use nominal CA10Y minus Bank of Canada CPI target band midpoint
// DE/GB/AU: nominal only — clean breakeven series not reliably available
// In all local cases we use nominal yield as the best available proxy
// and let the US real yield carry the adjustment on the US side
local_real_approx = local10y

// ============================================================
// === REAL YIELD CALCULATION ===
// Two modes:
// REAL  — US real yield (FRED:DFII10) minus local nominal
//         This captures the most important part of the adjustment:
//         US inflation expectations, which dominate the differential
//         for all these pairs. Local real yield data is unreliable
//         enough that using local nominal is the honest choice.
// NOMINAL — straight US10Y minus local10Y, no adjustment
// ============================================================
us_active = use_real ? us_real_direct : us10y
local_active = local_real_approx // nominal in both modes for local

raw_spread_nominal = (us10y - local10y) * spread_sign
raw_spread_real = (us_active - local_active) * spread_sign

raw_spread = use_real ? raw_spread_real : raw_spread_nominal
spread = ta.ema(raw_spread, ema_smooth)

// For table display
us_be_display = use_real ? us10y - us_real_direct : 0.0

// ============================================================
// === NORMALIZATION ===
// ============================================================
zscore(src, len) =>
    mean = ta.sma(src, len)
    std = ta.stdev(src, len)
    std != 0 ? (src - mean) / std : 0.0

norm_spread = zscore(spread, lookback)
norm_price = zscore(fx_price, lookback)

// ============================================================
// === ROLLING CORRELATION ===
// Run on raw series, not z-scores
// ============================================================
corr = ta.correlation(spread, fx_price, corr_length)

corr_strong = corr >= 0.80
corr_moderate = corr >= 0.40 and corr < 0.80
corr_weak = corr >= 0.20 and corr < 0.40
corr_negative = corr < 0.20

corr_color = corr_strong ? color.new(color.lime, 0) : corr_moderate ? color.new(color.yellow, 0) : corr_weak ? color.new(color.orange, 0) : color.new(color.red, 0)

corr_label = corr_strong ? 'Strong (' + str.tostring(corr, '#.##') + ')' : corr_moderate ? 'Moderate (' + str.tostring(corr, '#.##') + ')' : corr_weak ? 'Weak (' + str.tostring(corr, '#.##') + ')' : 'Regime Shift (' + str.tostring(corr, '#.##') + ')'

// ============================================================
// === DIVERGENCE DETECTION ===
// ============================================================
spread_up = norm_spread > norm_spread[div_lookback]
spread_dn = norm_spread < norm_spread[div_lookback]
price_up = norm_price > norm_price[div_lookback]
price_dn = norm_price < norm_price[div_lookback]
gap = math.abs(norm_spread - norm_price)

bull_div = spread_up and price_dn and gap >= div_threshold
bear_div = spread_dn and price_up and gap >= div_threshold

// ============================================================
// === REFERENCE LINES ===
// ============================================================
hline(show_zero ? 0 : na, 'Zero', color = color.new(color.white, 55), linestyle = hline.style_dashed)
hline(show_bands ? 1 : na, '+1σ', color = color.new(color.white, 75), linestyle = hline.style_dotted)
hline(show_bands ? -1 : na, '−1σ', color = color.new(color.white, 75), linestyle = hline.style_dotted)
hline(show_bands ? 2 : na, '+2σ', color = color.new(color.gray, 75), linestyle = hline.style_dotted)
hline(show_bands ? -2 : na, '−2σ', color = color.new(color.gray, 75), linestyle = hline.style_dotted)

hline(0.8, 'Strong Corr', color = color.new(color.lime, 85), linestyle = hline.style_dotted)
hline(0.2, 'Weak Corr', color = color.new(color.orange, 85), linestyle = hline.style_dotted)
hline(0.0, 'Corr Zero', color = color.new(color.red, 85), linestyle = hline.style_dotted)

// ============================================================
// === PLOTS ===
// ============================================================
p1 = plot(norm_spread, title = 'Yield Spread (z)', color = color.new(color.blue, 0), linewidth = 2)
p2 = plot(norm_price, title = 'FX Price (z)', color = color.new(color.aqua, 0), linewidth = 2)

fill(p1, p2, color = color.new(color.blue, 90), title = 'Spread-Price Gap')

plot(show_corr_plot ? corr : na, title = 'Rolling Correlation', color = corr_color, linewidth = 2, style = plot.style_line)

// ============================================================
// === BACKGROUND ===
// ============================================================
bgcolor(bull_div ? color.new(color.green, 88) : na, title = 'Bull Divergence')
bgcolor(bear_div ? color.new(color.red, 90) : na, title = 'Bear Divergence')

// ============================================================
// === LABELS ===
// ============================================================
if bull_div and not bull_div[1]
    label.new(bar_index, norm_spread + 0.2, '▲ DIV', style = label.style_label_down, color = color.new(color.green, 20), textcolor = color.white, size = size.small)

if bear_div and not bear_div[1]
    label.new(bar_index, norm_spread - 0.2, '▼ DIV', style = label.style_label_up, color = color.new(color.red, 20), textcolor = color.white, size = size.small)

// ============================================================
// === DATA TABLE ===
// ============================================================
if show_table and barstate.islast
    var table t = table.new(position.top_right, 2, 11, bgcolor = color.new(color.black, 55), border_color = color.new(color.white, 70), border_width = 1, frame_color = color.new(color.white, 50), frame_width = 1)

    // Header
    mode_str = use_real ? 'Real Yields' : 'Nominal Yields'
    table.cell(t, 0, 0, pair_choice + ' · ' + mode_str, text_color = color.aqua, text_size = size.small, bgcolor = color.new(color.navy, 20))
    table.cell(t, 1, 0, 'Value', text_color = color.white, text_size = size.small, bgcolor = color.new(color.navy, 20))

    // FX price
    table.cell(t, 0, 1, 'FX Price', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 1, str.tostring(fx_price, '#.####'), text_color = color.aqua, text_size = size.small)

    // Nominal yields
    table.cell(t, 0, 2, 'US10Y', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 2, str.tostring(us10y, '#.##') + '%', text_color = color.aqua, text_size = size.small)

    table.cell(t, 0, 3, local_label, text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 3, str.tostring(local10y, '#.##') + '%', text_color = color.aqua, text_size = size.small)

    // Implied US breakeven (derived: nominal minus real)
    table.cell(t, 0, 4, 'US Implied BE', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 4, use_real ? str.tostring(us_be_display, '#.##') + '%' : '—', text_color = color.yellow, text_size = size.small)

    // Local note
    table.cell(t, 0, 5, local_be_label + ' (n/a)', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 5, 'Nominal used', text_color = color.new(color.gray, 30), text_size = size.small)

    // US real yield
    table.cell(t, 0, 6, 'US Real Yield', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 6, use_real ? str.tostring(us_real_direct, '#.##') + '%' : '—', text_color = us_real_direct > 0 ? color.lime : color.red, text_size = size.small)

    // Local yield (nominal, labelled honestly)
    table.cell(t, 0, 7, 'Local Nominal', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 7, str.tostring(local10y, '#.##') + '%', text_color = color.aqua, text_size = size.small)

    // Active spread in bps
    table.cell(t, 0, 8, 'Spread (bps)', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 8, str.tostring(raw_spread * 100, '#') + 'bp', text_color = raw_spread > 0 ? color.lime : color.red, text_size = size.small)

    // Spread and price z-scores
    table.cell(t, 0, 9, 'Spread Z / Price Z', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 9, str.tostring(norm_spread, '#.##') + ' / ' + str.tostring(norm_price, '#.##'), text_color = color.aqua, text_size = size.small)

    // Correlation
    table.cell(t, 0, 10, 'Corr (' + str.tostring(corr_length) + 'b)', text_color = color.silver, text_size = size.small)
    table.cell(t, 1, 10, corr_label, text_color = corr_color, text_size = size.small)
````
