# EMA Pro+ Suite

- url: https://www.tradingview.com/script/daoCUXc0-EMA-Pro-Suite/
- type: indicator
- pine_id: PUB;4a356b595d70431abac7c0de24af2189
- version: 2.0

## Description

# EMA Pro+ Suite

**A multi-layer EMA confluence framework for reading market state at a glance.**

---

## What It Is

EMA Pro+ Suite is an overlay indicator built around three exponential moving averages — a Fast (10), Mid (20), and Slow (50) EMA — organized into a structured three-layer state engine that tells you the current market regime, momentum direction, and whether price is in or out of alignment with that regime. Rather than treating each EMA in isolation, the suite reads them together as a system and surfaces a single, coherent market state at all times.

A corner dashboard table updates in real time, giving you an instant read on bias, momentum, alignment, EMA slopes, and price extension — without having to scan the chart manually.

---

## How It Works

The indicator evaluates three distinct layers on every bar:

**Layer 1 — Bias (Trend Regime)**
Defined by price relative to the 50 EMA. Price above = bullish bias. Price below = bearish bias. This is the macro filter — it determines which direction setups should be taken in.

**Layer 2 — Momentum**
Defined by the 10 EMA relative to the 20 EMA. When the fast EMA is above the mid EMA, momentum is bullish. When below, momentum is bearish. Momentum alignment with bias is the confirmation layer.

**Layer 3 — Price vs Fast EMA**
When bias and momentum are aligned but price is on the wrong side of the 10 EMA, the indicator flags a potential pullback or exhaustion condition. In a full bull regime, price dipping below the 10 EMA may represent a high-quality entry opportunity — or an early warning of trend exhaustion. Context determines which.

**Slope Engine**
Each EMA is evaluated for slope using a configurable lookback. RISING / FLAT / FALLING is displayed per EMA in the dashboard. A momentum flip on flat EMAs carries significantly less weight than one on rising or falling EMAs — this is critical for filtering out noise in ranging conditions.

**Price Distance from 50 EMA**
Tracks how extended price is from the slow EMA as a percentage. Large positive or negative readings flag mean reversion risk.

**Bar & Background Coloring**
- Green background + green bars = full bull alignment
- Red background + red bars = full bear alignment
- Yellow bars = conflicting bias and momentum (mixed / transitional state)
- Aqua bars = bull regime, price pulling back below 10 EMA
- Fuchsia bars = bear regime, price popping above 10 EMA

**Cross Signals**
- `M↑` (green) — 10 EMA crossed above 20 EMA in bull zone. Aligned, higher conviction.
- `M↓` (red) — 10 EMA crossed below 20 EMA in bear zone. Aligned, higher conviction.
- `M↑ 🐻` (orange) — Bullish momentum flip firing in bear zone. Counter-trend, lower conviction.
- `M↓ 🐂` (orange) — Bearish momentum flip firing in bull zone. Counter-trend, lower conviction.

**Multi-Timeframe Support**
All three EMAs can be calculated on a higher timeframe and plotted on the current chart. Use this to anchor your bias to the HTF structure while reading entries on a lower timeframe.

---

## Possible Ways to Use It

**Trend Following**
Wait for full alignment — green background, green bars, all three slopes RISING. Only look for long entries. Use the 10 EMA pullback (aqua bars) as a potential entry trigger. Reverse logic for shorts.

**Momentum Flip Entries**
Use aligned `M↑` / `M↓` signals (green/red) as entry triggers when bias and slope confirm. Discard or fade counter-trend orange signals unless you have a specific reason to trade against the regime.

**Regime Filter for Other Systems**
Use the bias layer (price vs 50 EMA) as a filter for another strategy. Only take long signals from your primary system when EMA Pro+ shows bull bias, and vice versa.

**HTF Confluence**
Set the EMA Timeframe to a higher timeframe (e.g. 4H or Daily) while trading on a 15m or 1H chart. The dashboard will show the HTF regime, giving you a structural anchor for your intraday reads.

**Avoiding Chop**
When all three slopes read FLAT and bars are yellow (mixed alignment), the market is in a transitional or ranging state. Consider standing aside or reducing position size until a clear regime re-establishes.

**Mean Reversion Awareness**
When Dist 50 shows a large positive or negative reading, price is extended from the slow EMA. In trending markets this can persist — but it raises the bar for adding to positions and flags potential snapback risk.

---

## Settings

| Setting | Description |
|---|---|
| EMA Timeframe | Blank = current chart timeframe. Enter any TF (e.g. 60, 240, D) for MTF mode. |
| Fast / Mid / Slow EMA Length | Default 10 / 20 / 50. Fully adjustable. |
| Slope Lookback | Number of bars used to calculate EMA slope. Increase on lower timeframes to reduce flat readings. |
| Show EMA Lines | Toggle the three EMA plots. |
| Show Bias Background | Toggle the green/red background tint. |
| Color Bars by State | Toggle bar coloring. |
| Show Cross Signals | Toggle M↑ / M↓ labels on chart. |
| Show Dashboard Table | Toggle the corner HUD. |
| Table Position | Top Right / Top Left / Bottom Right / Bottom Left. |
| Bar Close Reminder Alert | Fires a reminder alert on every bar close to check the setup. |

---

## Alerts

- Momentum Flip Bullish — Bull Zone (aligned)
- Momentum Flip Bullish — Bear Zone (counter-trend)
- Momentum Flip Bearish — Bear Zone (aligned)
- Momentum Flip Bearish — Bull Zone (counter-trend)
- Price Reclaimed 50 EMA (bias flipped bullish)
- Price Lost 50 EMA (bias flipped bearish)
- Bull Pullback Signal (bull regime, price below 10 EMA)
- Bear Pullback Signal (bear regime, price above 10 EMA)
- Bar Close Reminder

---

## Disclaimer

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any asset. All trading involves substantial risk of loss. Past performance of any signal, strategy, or system is not indicative of future results.

EMA Pro+ Suite is a tool to assist with technical analysis — it does not predict price, guarantee accuracy, or remove the inherent uncertainty of financial markets. No indicator eliminates risk. You are solely responsible for your own trading decisions.

Always conduct your own research, apply proper risk management, and consider consulting a licensed financial professional before making any trading decisions. Only trade with capital you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RWCS_LTD

//@version=6
indicator("EMA Pro+ Suite", overlay = true)

// ═══════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════
group1 = "EMA Settings"
group2 = "Display"
group3 = "Dashboard"
group4 = "Alerts"

EMA_TF      = input.timeframe("",   "EMA Timeframe (blank = chart)",  group = group1)
ema10Len    = input.int(10,  "Fast EMA Length",  minval = 1, group = group1)
ema20Len    = input.int(20,  "Mid EMA Length",   minval = 1, group = group1)
ema50Len    = input.int(50,  "Slow EMA Length",  minval = 1, group = group1)
ema100Len   = input.int(100,  "Macro1 EMA Length",  minval = 1, group = group1)
ema200Len   = input.int(200,  "Macro2 EMA Length",  minval = 1, group = group1)
slopeLen    = input.int(9,   "Slope Lookback (bars)", minval = 1, group = group1)

showEMAs    = input.bool(true,  "Show EMA Lines",          group = group2)
showMACROs  = input.bool(true,  "Show Macro EMA Lines",          group = group2)
showBG      = input.bool(true,  "Show Bias Background",    group = group2)
showBars    = input.bool(true,  "Color Bars by State",     group = group2)
showSignals = input.bool(true,  "Show Cross Signals",      group = group2)

showDash    = input.bool(true,  "Show Dashboard Table",    group = group3)
dashLoc     = input.string("Bottom Right", "Table Position",
              options = ["Top Right","Top Left","Bottom Right","Bottom Left"],
              group = group3)

// ═══════════════════════════════════════════════════
// MTF EMA FUNCTION
// ═══════════════════════════════════════════════════
f_emas(f, m, s, m1, m2) =>
    e10 = ta.ema(close, f)
    e20 = ta.ema(close, m)
    e50 = ta.ema(close, s)
    e100 = ta.ema(close, m1)
    e200 = ta.ema(close, m2)
    [e10, e20, e50, e100, e200]

[ema10, ema20, ema50, ema100, ema200] = request.security(
  syminfo.tickerid, EMA_TF,
  f_emas(ema10Len, ema20Len, ema50Len, ema100Len, ema200Len),
  lookahead = barmerge.lookahead_off)

// ═══════════════════════════════════════════════════
// SLOPE ENGINE
// ═══════════════════════════════════════════════════
// Slope: positive = rising, negative = falling, flat = within threshold
f_slope(src, len) =>
    diff = src - src[len]
    pct  = diff / src[len] * 100
    pct

slope10 = f_slope(ema10, slopeLen)
slope20 = f_slope(ema20, slopeLen)
slope50 = f_slope(ema50, slopeLen)
slope100 = f_slope(ema100, slopeLen)
slope200 = f_slope(ema200, slopeLen)

SLOPE_THRESH = 0.05  // % threshold below which slope is considered flat

f_slopeLabel(s) =>
    math.abs(s) < SLOPE_THRESH ? "FLAT" : s > 0 ? "RISING" : "FALLING"

f_slopeColor(s) =>
    math.abs(s) < SLOPE_THRESH ? color.yellow : s > 0 ? color.green : color.red

// ═══════════════════════════════════════════════════
// STATE ENGINE
// ═══════════════════════════════════════════════════
bull_bias  = close > ema50
bear_bias  = close < ema50
bull_mom   = ema10 > ema20
bear_mom   = ema10 < ema20

bull_div   = bull_bias and bull_mom and close < ema10
bear_div   = bear_bias and bear_mom and close > ema10

full_bull  = bull_bias and bull_mom
full_bear  = bear_bias and bear_mom
mixed      = (bull_bias and bear_mom) or (bear_bias and bull_mom)

dist50     = (close - ema50) / ema50 * 100

macro_bull       = close > ema100 and close > ema200
macro_bear       = close < ema100 and close < ema200
macro_mixed      = not macro_bull and not macro_bear
macro_stack_bull = ema100 > ema200
macro_stack_bear = ema100 < ema200

// ── Bull Score (0–5): how many EMAs is price above? ──
bull_score = (close > ema10  ? 1 : 0) +
             (close > ema20  ? 1 : 0) +
             (close > ema50  ? 1 : 0) +
             (close > ema100 ? 1 : 0) +
             (close > ema200 ? 1 : 0)

cross_bull    = ta.crossover(ema10,  ema20)
cross_bear    = ta.crossunder(ema10, ema20)
price_reclaim = ta.crossover(close,  ema50)
price_lose    = ta.crossunder(close, ema50)

// ═══════════════════════════════════════════════════
// EMA PLOTS
// ═══════════════════════════════════════════════════
plot(showEMAs ? ema10 : na, "10 EMA", color = color.aqua,    linewidth = 2)
plot(showEMAs ? ema20 : na, "20 EMA", color = color.fuchsia, linewidth = 2)
plot(showEMAs ? ema50 : na, "50 EMA", color = color.red,     linewidth = 2)

plot(showMACROs ? ema100 : na, "Macro EMA 1", color = color.lime,   linewidth = 1)
plot(showMACROs ? ema200 : na, "Macro EMA 2", color = color.purple, linewidth = 1)

// ═══════════════════════════════════════════════════
// BACKGROUND TINT — macro-aware opacity
// ═══════════════════════════════════════════════════
// Macro-confirmed bias = stronger tint; macro-opposed = faint tint
bgcolor(showBG and bull_bias and macro_bull  ? color.new(color.green, 88) : na, title = "Strong Bull BG")
bgcolor(showBG and bull_bias and not macro_bull ? color.new(color.green, 96) : na, title = "Weak Bull BG")
bgcolor(showBG and bear_bias and macro_bear  ? color.new(color.red,   88) : na, title = "Strong Bear BG")
bgcolor(showBG and bear_bias and not macro_bear ? color.new(color.red,   96) : na, title = "Weak Bear BG")

// ═══════════════════════════════════════════════════
// BAR COLOR — score-tiered intensity (no new visuals)
// ═══════════════════════════════════════════════════
// Bull side: score 5 = bright green, 4 = medium, 3 = dim
// Bear side: score 0 = bright red,   1 = medium, 2 = dim
// Divergence and mixed states preserved
barcolor(
  showBars ?
    (bull_div  ? color.new(color.aqua,    0) :
     bear_div  ? color.new(color.fuchsia, 0) :
     bull_score == 5 ? color.new(color.green,  0)  :
     bull_score == 4 ? color.new(color.green,  40) :
     bull_score == 3 ? color.new(color.yellow, 20) :
     bull_score == 2 ? color.new(color.yellow, 20) :
     bull_score == 1 ? color.new(color.red,    40) :
                       color.new(color.red,    0))
  : na,
  title = "State Bar Color")

// ═══════════════════════════════════════════════════
// CROSS SIGNALS — zone-aware labels (const string fix)
// ═══════════════════════════════════════════════════

// Bull cross — aligned (green) vs counter-trend (orange)
plotshape(showSignals and cross_bull and bull_bias,
  title    = "Momentum Flip Bull (Bull Zone)",
  location = location.belowbar, style = shape.labelup,
  color    = color.new(color.green, 40),
  text     = "M↑", textcolor = color.white, size = size.small)

plotshape(showSignals and cross_bull and bear_bias,
  title    = "Momentum Flip Bull (Bear Zone)",
  location = location.belowbar, style = shape.labelup,
  color    = color.new(color.orange, 40),
  text     = "M↑ 🐻", textcolor = color.white, size = size.small)

// Bear cross — aligned (red) vs counter-trend (orange)
plotshape(showSignals and cross_bear and bear_bias,
  title    = "Momentum Flip Bear (Bear Zone)",
  location = location.abovebar, style = shape.labeldown,
  color    = color.new(color.red, 40),
  text     = "M↓", textcolor = color.white, size = size.small)

plotshape(showSignals and cross_bear and bull_bias,
  title    = "Momentum Flip Bear (Bull Zone)",
  location = location.abovebar, style = shape.labeldown,
  color    = color.new(color.orange, 40),
  text     = "M↓ 🐂", textcolor = color.white, size = size.small)

// ═══════════════════════════════════════════════════
// DASHBOARD TABLE
// ═══════════════════════════════════════════════════
if showDash and barstate.islast
    tPos = dashLoc == "Top Right"    ? position.top_right    :
           dashLoc == "Top Left"     ? position.top_left     :
           dashLoc == "Bottom Right" ? position.bottom_right :
                                       position.bottom_left

    // 2 cols, 12 rows: label | value
    t = table.new(tPos, columns = 2, rows = 12,
        bgcolor      = color.new(color.black, 80),
        border_color = color.new(color.gray,  50),
        border_width = 1,
        frame_color  = color.gray,
        frame_width  = 1)

    // ── Header ──
    table.cell(t, 0, 0, "EMA PRO+",
        text_color = color.white, text_size = size.small,
        bgcolor    = color.new(color.navy, 40))
    table.cell(t, 1, 0, "",
        bgcolor = color.new(color.navy, 40))

    // ── Bias ──
    table.cell(t, 0, 1, "Bias",       text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 1,
        bull_bias ? "▲ BULL" : "▼ BEAR",
        text_color = bull_bias ? color.green : color.red,
        text_size  = size.small)

    // ── Momentum ──
    table.cell(t, 0, 2, "Momentum",   text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 2,
        bull_mom ? "▲ BULL" : "▼ BEAR",
        text_color = bull_mom ? color.green : color.red,
        text_size  = size.small)

    // ── Alignment (score-based) ──
    table.cell(t, 0, 3, "Alignment",  text_color = color.gray, text_size = size.small)
    alignLabel = bull_score == 5 ? "★ FULL STACK" :
                 bull_score == 4 ? "✦ BULL (4/5)"  :
                 bull_score == 3 ? "⚡ MIXED (3/5)" :
                 bull_score == 2 ? "⚡ MIXED (2/5)" :
                 bull_score == 1 ? "✦ BEAR (1/5)"  :
                                   "★ FULL BEAR"
    alignColor = bull_score == 5 ? color.green  :
                 bull_score == 4 ? color.lime    :
                 bull_score == 3 ? color.yellow  :
                 bull_score == 2 ? color.yellow  :
                 bull_score == 1 ? color.orange  :
                                   color.red
    table.cell(t, 1, 3, alignLabel, text_color = alignColor, text_size = size.small)

    // ── Macro Structure ──
    table.cell(t, 0, 4, "Macro",      text_color = color.gray, text_size = size.small)
    macroLabel = macro_bull and macro_stack_bull ? "▲ BULL + STACK" :
                 macro_bull                      ? "▲ BULL"         :
                 macro_bear and macro_stack_bear ? "▼ BEAR + STACK" :
                 macro_bear                      ? "▼ BEAR"         :
                                                   "⚡ MIXED"
    macroColor = macro_bull ? color.green : macro_bear ? color.red : color.yellow
    table.cell(t, 1, 4, macroLabel, text_color = macroColor, text_size = size.small)

    // ── Signal ──
    table.cell(t, 0, 5, "Signal",     text_color = color.gray, text_size = size.small)
    sigLabel = bull_div ? "↑ PULLBACK?" : bear_div ? "↓ PULLBACK?" :
               cross_bull ? "M FLIP ↑"  : cross_bear ? "M FLIP ↓"  : "—"
    sigColor = bull_div   ? color.aqua   : bear_div   ? color.fuchsia :
               cross_bull ? color.green  : cross_bear ? color.red     : color.gray
    table.cell(t, 1, 5, sigLabel, text_color = sigColor, text_size = size.small)

    // ── 10 EMA Slope ──
    table.cell(t, 0, 6, "10 Slope",  text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 6, f_slopeLabel(slope10),
        text_color = f_slopeColor(slope10), text_size = size.small)

    // ── 20 EMA Slope ──
    table.cell(t, 0, 7, "20 Slope",  text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 7, f_slopeLabel(slope20),
        text_color = f_slopeColor(slope20), text_size = size.small)

    // ── 50 EMA Slope ──
    table.cell(t, 0, 8, "50 Slope",  text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 8, f_slopeLabel(slope50),
        text_color = f_slopeColor(slope50), text_size = size.small)

    // ── 100 EMA Slope ──
    table.cell(t, 0, 9, "100 Slope", text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 9, f_slopeLabel(slope100),
        text_color = f_slopeColor(slope100), text_size = size.small)

    // ── Price Distance from 50 EMA ──
    table.cell(t, 0, 10, "Dist 50",  text_color = color.gray, text_size = size.small)
    distStr  = (dist50 >= 0 ? "+" : "") + str.tostring(dist50, "#.##") + "%"
    distCol  = dist50 > 5 ? color.new(color.green, 20) :
               dist50 < -5 ? color.new(color.red,  20) : color.gray
    table.cell(t, 1, 10, distStr, text_color = distCol, text_size = size.small)

    // ── Timeframe ──
    table.cell(t, 0, 11, "TF",        text_color = color.gray, text_size = size.small)
    table.cell(t, 1, 11,
        EMA_TF == "" ? timeframe.period : EMA_TF,
        text_color = color.white, text_size = size.small)

// ═══════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════
alertcondition(cross_bull and bull_bias,  title = "Momentum Flip Bull (Bull Zone)",
  message = "EMA Pro+: 10 crossed ABOVE 20 while price above 50 EMA — aligned bull momentum.")
alertcondition(cross_bull and bear_bias,  title = "Momentum Flip Bull (Bear Zone)",
  message = "EMA Pro+: 10 crossed ABOVE 20 but price still below 50 EMA — counter-trend, low conviction.")
alertcondition(cross_bear and bear_bias,  title = "Momentum Flip Bear (Bear Zone)",
  message = "EMA Pro+: 10 crossed BELOW 20 while price below 50 EMA — aligned bear momentum.")
alertcondition(cross_bear and bull_bias,  title = "Momentum Flip Bear (Bull Zone)",
  message = "EMA Pro+: 10 crossed BELOW 20 but price still above 50 EMA — counter-trend, low conviction.")
alertcondition(price_reclaim, title = "Price Reclaimed 50 EMA",
  message = "EMA Pro+: Price crossed ABOVE 50 EMA — bias flipped bullish.")
alertcondition(price_lose,    title = "Price Lost 50 EMA",
  message = "EMA Pro+: Price crossed BELOW 50 EMA — bias flipped bearish.")
alertcondition(bull_div,      title = "Bull Pullback Signal",
  message = "EMA Pro+: Bullish regime but price below 10 EMA — pullback or exhaustion.")
alertcondition(bear_div,      title = "Bear Pullback Signal",
  message = "EMA Pro+: Bearish regime but price above 10 EMA — pullback or exhaustion.")
alertcondition(ta.crossover(close, ema200),  title = "Price Reclaimed 200 EMA",
  message = "EMA Pro+: Price crossed ABOVE 200 EMA — major macro level reclaimed.")
alertcondition(ta.crossunder(close, ema200), title = "Price Lost 200 EMA",
  message = "EMA Pro+: Price crossed BELOW 200 EMA — major macro support lost.")
alertcondition(ta.crossover(ema100, ema200), title = "Macro Golden Cross",
  message = "EMA Pro+: 100 crossed ABOVE 200 — long-term bullish structure.")
alertcondition(ta.crossunder(ema100, ema200), title = "Macro Death Cross",
  message = "EMA Pro+: 100 crossed BELOW 200 — long-term bearish structure.")

if barstate.isconfirmed 
    alert("🔍 Bar closed. EMA Pro+ — check bias, momentum, slope, distance. Is there a setup?", alert.freq_once_per_bar_close)
````
