# MTF Right now [Zofesu]

- url: https://www.tradingview.com/script/gMbYL1bw-MTF-Right-now-Zofesu/
- type: indicator
- pine_id: PUB;74867c3cb7e449ed8826cd7907946101
- version: 1.0

## Description

[b]MTF Right now [Zofesu][/b] - MTF Delta + Volume Ratio + 9-state Verdict table. See what the higher timeframe is doing — right now.
────────────────────────────────────────────────────────────

📊 [b]MTF Right now [Zofesu] — Delta · Trend · Volume Ratio · Verdict[/b]

MTF Right now is a multi-timeframe analysis table that reads three independent data streams from any higher timeframe — volume delta, HMA trend direction, and volume ratio — and combines them into a single actionable verdict. The goal is simple: remove the guesswork of manually reading a higher timeframe chart while you are managing a trade on a lower one.

─────────────────────────────────────────
[b]01 — What problem does this solve?[/b]
─────────────────────────────────────────

Most traders switch between timeframes manually to check trend context. This takes time, breaks focus, and introduces interpretation errors. MTF Right now pulls the key data from your selected higher timeframe and displays it in a compact table directly on your chart — updated in real time on every bar.

─────────────────────────────────────────
[b]02 — How it works[/b]
─────────────────────────────────────────

The indicator calculates three values from the selected higher timeframe:

[b]1. DELTA[/b] — Net buying vs selling pressure per candle.
   Where footprint data is available (supported brokers), the indicator uses real order flow delta via request.footprint(). On standard data feeds, it falls back to the Elder CTI formula: Volume × (2 × Close − High − Low) / (High − Low). The fallback ensures the indicator works on any symbol and broker.

[b]2. TREND[/b] — Direction of the HMA (Hull Moving Average) applied to delta.
   HMA = WMA(2 × WMA(delta, n/2) − WMA(delta, n), √n)
   This smooths delta noise without the lag of a standard EMA. When HMA is rising, delta momentum is bullish. When falling, it is bearish.

[b]3. VOLUME RATIO[/b] — Where the close settled within the high-low range of the candle (0–100%).
   Formula: (Close − Low) / (High − Low) × 100
   Above 60% means buyers controlled the close. Below 40% means sellers controlled it. The indicator averages this over the last N candles for a stable read.

─────────────────────────────────────────
[b]03 — The Verdict system[/b]
─────────────────────────────────────────

The three inputs feed a 9-state verdict engine. Each state is a combination of delta direction, price direction, and volume ratio:

[b]BULL CONFIRMED[/b] — Delta up, price up, close near high. Full alignment. Safe long context.
[b]BEAR CONFIRMED[/b] — Delta down, price down, close near low. Full alignment. Safe short context.
[b]STRONG SUPPORT[/b] — Delta up but price falling. Buyers are absorbing sell pressure. Support holding.
[b]WEAK SUPPORT[/b] — Delta up but close near low. Absorption present but close is struggling.
[b]STRONG RESIST.[/b] — Delta down but price rising. Sellers distributing into strength. Resistance holding.
[b]WEAK RESIST.[/b] — Delta down but close near high. Distribution present but close is holding up.
[b]FADING BULLS [/b] — Delta and price up but close weak. Momentum losing conviction.
[b]FADING BEARS[/b] — Delta and price down but close strong. Selling pressure fading.
[b]NEUTRAL[/b] — No dominant condition detected.

─────────────────────────────────────────
[b]04 — Table layout[/b]
─────────────────────────────────────────

The table has 2 columns and 5 rows:

Row 0  │ TF: [selected]              │ Pure Delta
Row 1  │ State                           │ Delta value
Row 2  │ Trend ▲/▼/▬            │ —
Row 3  │ Verdict                        │ Vol: XX%
Row 4  │ Delta▲/▼ Price▲/▼  │ Up / Down / S Hold / R Hold

All values are sourced from the selected higher timeframe only. The chart timeframe does not affect the calculations.

─────────────────────────────────────────
[b]05 — How to use[/b]
─────────────────────────────────────────

[b]Step 1[/b] — Set your target timeframe in Core Settings. Default is Daily.
         If you trade on H1, set the MTF to H4 or Daily.
         If you trade on M15, set it to H1 or H4.

[b]Step 2[/b] — Read the Verdict row first. It tells you the current higher timeframe context in one word.

[b]Step 3[/b] — Confirm with the State and Trend rows.
         BULL CONFIRMED + Trend ▲ = strong long context.
         BEAR CONFIRMED + Trend ▼ = strong short context.
         Any FADING or WEAK state = wait, do not enter.

[b]Step 4[/b] — Use Vol % as a secondary filter.
         Above 60% = buyers controlled the last N candles.
         Below 40% = sellers controlled them.
         Between 40–60% = no dominant side, treat as noise.

[b]Step 5[/b] — Set alerts for BULL CONFIRMED, BEAR CONFIRMED, STRONG SUPPORT, or STRONG RESIST. to get notified when the higher timeframe shifts without watching the screen.

─────────────────────────────────────────
[b]06 — Parameters[/b]
─────────────────────────────────────────

[b]Target Timeframe (MTF) [/b] — Higher timeframe to analyze. Default: D (Daily).
[b]Trend Smoothing (HMA Length)[/b] — HMA period for delta trend. Default: 8. Lower = more reactive.
[b]Volume Ratio Length[/b] — Number of MTF candles for average volume ratio. Default: 8.
[b]Table Position[/b] — Place the table anywhere on the chart.
[b]Text Size[/b] — Small / Normal / Large.
[b]Background Opacity[/b] — 0 = fully transparent, 100 = fully opaque.

─────────────────────────────────────────
[b]07 — Alerts[/b]
─────────────────────────────────────────

[b]Bull Confirmed[/b] — Higher TF verdict is BULL CONFIRMED.
[b]Bear Confirmed[/b] — Higher TF verdict is BEAR CONFIRMED.
[b]Strong Support[/b] — Higher TF verdict is STRONG SUPPORT.
[b]Strong Resistance[/b] — Higher TF verdict is STRONG RESIST.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu

//@version=6
indicator("MTF Right now [Zofesu]", shorttitle="[Zofesu] MTF Right now", overlay=true)

// ========================================================================= //
// 1. INPUTS
// ========================================================================= //
grp_core   = "Core Settings"
i_tf       = input.timeframe("D", title="Target Timeframe (MTF)", group=grp_core, tooltip="Select the higher timeframe to analyze. All delta, trend and verdict calculations are based on this timeframe's candles.")
i_trendLen = input.int(6, title="Trend Smoothing (HMA Length)", minval=1, group=grp_core, tooltip="HMA period applied to delta to determine trend direction on the selected timeframe. Lower = more reactive, higher = smoother.")
i_volLen   = input.int(6,  title="Volume Ratio Length", minval=2, maxval=20, group=grp_core, tooltip="Number of MTF candles used to calculate the average volume ratio — where the close settles within the high-low range (0–100%).")

grp_ui      = "UI Settings"
i_tablePos  = input.string("Top Right", title="Table Position", options=["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left", "Bottom Center", "Middle Right", "Middle Left"], group=grp_ui)
i_textSize  = input.string("Normal", title="Text Size", options=["Small", "Normal", "Large"], group=grp_ui)
i_bgOpacity = input.int(80, title="Background Opacity", minval=0, maxval=100, group=grp_ui)

// ========================================================================= //
// 2. CALCULATIONS
// ========================================================================= //
hma(src, len) =>
    ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))

// Universal delta — automatic selection based on available data
footprint fp     = request.footprint(100)
float priceRange = high - low
float elderCTI   = priceRange == 0 ? 0.0 : volume * (2.0 * close - high - low) / priceRange
float chart_delta = not na(fp) ? fp.delta() : elderCTI

// Volume Ratio = where the close settled within the high-low range (0–100%)
calc_vol_ratio() =>
    float pr = high - low
    pr == 0 ? 50.0 : (close - low) / pr * 100.0

tf_logic() =>
    float deltaHma    = hma(chart_delta, i_trendLen)
    float volRatio    = calc_vol_ratio()
    float avgVolRatio = ta.sma(volRatio, i_volLen)
    float priceDir    = close - close[i_volLen]
    [chart_delta, deltaHma, deltaHma[1], volRatio, avgVolRatio, priceDir]

[mtf_delta, mtf_hma, mtf_hma_prev, mtf_volRatio, mtf_avgVolRatio, mtf_priceDir] = request.security(
  syminfo.tickerid, i_tf, tf_logic(),
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ========================================================================= //
// 3. STATE
// ========================================================================= //
bool trendUp   = mtf_hma > mtf_hma_prev
bool trendDown = mtf_hma < mtf_hma_prev

string state =
  mtf_delta > 0 and trendUp   ? "BUY PRESSURE ▲"  :
  mtf_delta < 0 and trendDown ? "SELL PRESSURE ▼" :
  mtf_delta > 0 and trendDown ? "FADING BULLS"     :
  mtf_delta < 0 and trendUp   ? "FADING BEARS"     : "NEUTRAL"

color stateColor =
  state == "BUY PRESSURE ▲"  ? color.rgb(48, 206, 0) :
  state == "SELL PRESSURE ▼" ? color.rgb(206, 0, 0)  :
  state == "FADING BULLS"    ? color.new(#4bffa8, 0) :
  state == "FADING BEARS"    ? color.new(#ff4c4c, 0) :
  color.gray

// ========================================================================= //
// 4. VERDICT
// ========================================================================= //
// Delta divergence: delta direction vs price direction
bool deltaUp   = mtf_delta > 0
bool deltaDown = mtf_delta < 0
bool priceUp   = mtf_priceDir > 0
bool priceDown = mtf_priceDir < 0

// Volume Ratio interpretation
// > 60% = buyers dominant (close near high)
// < 40% = sellers dominant (close near low)
// 40-60% = neutral
bool volBullish = mtf_avgVolRatio > 60.0
bool volBearish = mtf_avgVolRatio < 40.0
string volStr   = "Vol: " + str.tostring(math.round(mtf_avgVolRatio)) + "%"

// Divergence description
string divStr =
  deltaUp   and priceDown ? "Delta▲ Price▼" :  // sell absorption = support holding
  deltaDown and priceUp   ? "Delta▼ Price▲" :  // distribution = resistance holding
  deltaUp   and priceUp   ? "Delta▲ Price▲" :  // strong impulse up
  deltaDown and priceDown ? "Delta▼ Price▼" :  // strong impulse down
  "Delta — Price —"

// Final verdict
string verdict = ""
color  verdictColor = color.gray

if deltaUp and priceDown and volBullish
    // Buyers absorbing selling, close holds up → strong support
    verdict      := "STRONG SUPPORT"
    verdictColor := color.rgb(48, 206, 0)
else if deltaUp and priceDown and not volBullish
    // Absorption but close near low → support under pressure
    verdict      := "WEAK SUPPORT"
    verdictColor := color.new(#ff4c4c, 0)
else if deltaDown and priceUp and volBearish
    // Sellers distributing, close holds down → strong resistance
    verdict      := "STRONG RESIST."
    verdictColor := color.rgb(206, 0, 0)
else if deltaDown and priceUp and not volBearish
    // Distribution but close near high → weak resistance
    verdict      := "WEAK RESIST."
    verdictColor := color.new(#4bffa8, 0)
else if deltaUp and priceUp and volBullish
    // Everything bullish → strong uptrend, safe long entry
    verdict      := "BULL CONFIRMED"
    verdictColor := color.rgb(48, 206, 0)
else if deltaDown and priceDown and volBearish
    // Everything bearish → strong downtrend, safe short entry
    verdict      := "BEAR CONFIRMED"
    verdictColor := color.rgb(206, 0, 0)
else if deltaUp and priceUp and not volBullish
    // Delta and price up but close weak → momentum fading
    verdict      := "FADING BULLS"
    verdictColor := color.new(#4bffa8, 0)
else if deltaDown and priceDown and not volBearish
    // Delta and price down but close strong → selling fading
    verdict      := "FADING BEARS"
    verdictColor := color.new(#ff4c4c, 0)
else
    verdict      := "NEUTRAL"
    verdictColor := color.gray

// ========================================================================= //
// 5. HELPER FUNCTIONS
// ========================================================================= //
get_position(pos_str) =>
    switch pos_str
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

get_size(size_str) =>
    switch size_str
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

// ========================================================================= //
// 6. TABLE — 2 columns, 5 rows
// ========================================================================= //
var table deltaTable = table.new(
  get_position(i_tablePos), columns=2, rows=5,
  bgcolor=color.new(color.black, i_bgOpacity),
  border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    color  bgColor        = color.new(color.rgb(14, 15, 19), i_bgOpacity)
    string tf_display     = i_tf == "" ? "Chart" : i_tf
    string formattedDelta = str.tostring(mtf_delta, format.volume)
    color  deltaColor     = mtf_delta > 0 ? color.rgb(0, 255, 132) : color.rgb(255, 0, 0)
    string trendLabel     = trendUp ? "Trend ▲" : trendDown ? "Trend ▼" : "Trend ▬"
    color  trendColor     = trendUp ? color.rgb(48, 206, 0) : trendDown ? color.rgb(206, 0, 0) : color.gray

    // Row 0 — header
    table.cell(deltaTable, 0, 0, "TF: " + tf_display,
      text_color=color.white, text_size=get_size(i_textSize),
      text_halign=text.align_left, bgcolor=bgColor)
    table.cell(deltaTable, 1, 0, "Pure Delta",
      text_color=color.white, text_size=get_size(i_textSize),
      text_halign=text.align_center, bgcolor=bgColor)

    // Row 1 — state
    table.cell(deltaTable, 0, 1, state,
      text_color=stateColor, text_size=get_size(i_textSize),
      text_halign=text.align_left, bgcolor=bgColor)
    table.cell(deltaTable, 1, 1, formattedDelta,
      text_color=deltaColor, text_size=get_size(i_textSize),
      text_halign=text.align_center, bgcolor=bgColor)

    // Row 2 — trend
    table.cell(deltaTable, 0, 2, trendLabel,
      text_color=trendColor, text_size=get_size(i_textSize),
      text_halign=text.align_left, bgcolor=bgColor)
    table.cell(deltaTable, 1, 2, "",
      bgcolor=bgColor)

    // Row 3 — verdict
    table.cell(deltaTable, 0, 3, verdict,
      text_color=verdictColor, text_size=get_size(i_textSize),
      text_halign=text.align_left, bgcolor=bgColor)
    table.cell(deltaTable, 1, 3, volStr,
      text_color=mtf_avgVolRatio > 60 ? color.rgb(48, 206, 0) : mtf_avgVolRatio < 40 ? color.rgb(206, 0, 0) : color.gray,
      text_size=get_size(i_textSize), text_halign=text.align_center, bgcolor=bgColor)

    // Row 4 — divergence detail + context
    string ctxStr =
      deltaUp   and priceDown ? "S Hold" :
      deltaDown and priceUp   ? "R Hold" :
      deltaUp   and priceUp   ? "Up"     :
      deltaDown and priceDown ? "Down"   : "—"

    color ctxColor =
      deltaUp   and priceDown ? color.rgb(48, 206, 0) :
      deltaDown and priceUp   ? color.rgb(206, 0, 0)  :
      deltaUp   and priceUp   ? color.rgb(48, 206, 0) :
      deltaDown and priceDown ? color.rgb(206, 0, 0)  : color.gray

    table.cell(deltaTable, 0, 4, divStr,
      text_color=color.new(#ffffff, 15), text_size=get_size(i_textSize),
      text_halign=text.align_left, bgcolor=bgColor)
    table.cell(deltaTable, 1, 4, ctxStr,
      text_color=ctxColor, text_size=get_size(i_textSize),
      text_halign=text.align_center, bgcolor=bgColor)

// ========================================================================= //
// 7. ALERTS
// ========================================================================= //
alertcondition(verdict == "BULL CONFIRMED",  title="Bull Confirmed",    message="[MTF Right Now] BULL CONFIRMED on {{ticker}} ({{interval}})")
alertcondition(verdict == "BEAR CONFIRMED",  title="Bear Confirmed",    message="[MTF Right Now] BEAR CONFIRMED on {{ticker}} ({{interval}})")
alertcondition(verdict == "STRONG SUPPORT",  title="Strong Support",    message="[MTF Right Now] STRONG SUPPORT on {{ticker}} ({{interval}})")
alertcondition(verdict == "STRONG RESIST.",  title="Strong Resistance", message="[MTF Right Now] STRONG RESISTANCE on {{ticker}} ({{interval}})")
````
