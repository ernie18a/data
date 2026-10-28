# Volume Z-Score Readout [TSL]

- url: https://www.tradingview.com/script/VT9p8nF1-Volume-Z-Score-Readout-TSL/
- type: indicator
- pine_id: PUB;91c33286b6834ec686fc66f4429cb453
- version: 4.0

## Description

Volume Z-Score Readout shows whether the current bar's volume is statistically unusual for this exact time of day — in plain English, in one small box, with no extra pane.

Most volume indicators give you raw bars and a moving average. The interesting question — "is this volume unusual right now, or just normal for 10:15 AM?" — almost never gets answered well. Intraday volume has a strong time-of-day shape. The cash open is always busy. Noon is always quiet. A 3× spike at 9:30 means almost nothing because that's what 9:30 looks like. A 3× spike at noon is genuinely unusual.

This indicator answers that question with a single box on the chart:

  z=-0.5 · normal for this time
  z=+1.4 · busier than usual
  z=+2.6 · unusual for this time
  z=+3.8 · extreme for this time
  z=-3.0 · unusually quiet

The box color shifts with the band: grey when normal (|z| < 1), blue when notable (|z| < 2), orange when unusual (|z| < 3), red when extreme (|z| ≥ 3).

═══ HOW IT WORKS ═══

For each bar, the script collects the volume at the same time of day from the trailing N sessions, then computes:
  z = (current volume - mean) / standard deviation

A z-score of 0 means exactly average for this time. +1 means one standard deviation above average. +3 means three standard deviations above — genuinely unusual.

Because the calculation uses a time-of-day baseline rather than a rolling N-bar window, the indicator is not fooled by the natural rhythm of the session. The 9:30 open and the lunchtime lull are treated as different distributions, each with their own mean and SD.

═══ WHY OVERLAY ═══

This script overlays on the price chart (not in a separate pane) by design. It's meant to run alongside whatever volume indicator you already use — Session Volume Pulse, native volume, Volume Profile, anything. The readout box sits in a corner you pick. Doesn't eat a pane. Doesn't conflict with your existing setup.

If you want the full kit — volume bars colored by spike state, time-of-day baseline line, spike multiplier labels, AND the z-score readout — see Session Volume Pulse [TSL] instead. This standalone is for users who already have a volume display they like and just want the verdict.

═══ FAST SETUP: THREE PRESETS, NO MATH ═══

The settings panel is preset-driven so most users finish setup in two clicks.

PRESET 1 — Trader style (controls how responsive the baseline is)

• Day trader (responsive): 14 sessions. Adapts fast after vol regime shifts. More noise, more alerts. Best for tight intraday work.
• Swing trader (balanced): 21 sessions (~one month). DEFAULT. Best statistical balance for most users on 15m charts.
• Position trader (very stable): 42 sessions (~two months). Slow to adapt. Best when you want band crossings to be rare and meaningful.
• Custom: ignores the preset and uses the numeric "Sessions to average" input below.

PRESET 2 — Market (auto-computes bars-per-session from chart timeframe)

• Auto-detect (24h): correct for crypto, forex, and most ~24h markets.
• Futures (~23h: NQ, ES, CL, GC): for futures traders. Slightly more accurate than Auto.
• US stocks RTH (6.5h): regular trading hours only. For AAPL, MSFT, SPY, etc.
• Custom: ignores the preset and uses the "Bars per session" input below.

PRESET 3 — Sensitivity (controls how often the alert fires)

• Conservative (|z| >= 2.5, ~1/week): only extreme events.
• Balanced (|z| >= 2.0): DEFAULT. Catches notable → unusual transitions, the most actionable threshold on 15m charts.
• Sensitive (|z| >= 1.5, more alerts): many more alerts; use only if you actively want to monitor the busier-than-usual threshold.
• Custom: ignores the preset and uses the "Alert threshold" input below.

═══ DEFAULT BEHAVIOR (15M FUTURES) ═══

With defaults out of the box:
• Trader style: Swing trader (21 sessions)
• Market preset: Auto-detect (24h)
• Sensitivity: Balanced (|z| >= 2.0)
• Readout position: Top right
• Text size: Normal
• Show 'Time-of-day' label cell: Off (compact pill)

Drop the indicator on a 15m NQ chart and it works immediately. No configuration required for the default case. The two "(only if Custom)" numeric inputs below each preset are escape hatches for power users — leave them alone unless you've picked Custom on the related preset.

═══ READING THE VERDICT ═══

The verdict text is direction-aware:

• |z| < 1 → "normal for this time" (grey)
• 1 ≤ |z| < 2 → "busier than usual" / "quieter than usual" (blue)
• 2 ≤ |z| < 3 → "unusual for this time" / "unusually quiet" (orange)
• |z| ≥ 3 → "extreme for this time" / "extreme silence" (red)

A positive z reads "busier"; a negative z reads "quieter." This matters: z=-2.1 isn't ambiguous — it specifically means today's bar is unusually QUIET for this minute. That's often as important as a spike. Distribution days often start with eerily-quiet volume; reversals often begin with silence.

═══ ALERTS ═══

One alert: "Unusual volume" — fires when |z| crosses the resolved threshold (the value picked by the Sensitivity preset, or the Custom input if you picked Custom). Set up in TradingView's alerts panel after adding the indicator.

═══ HONEST LIMITATIONS ═══

• Does not predict price direction. A spike with a green close is bullish confirmation; the same spike with a red close is often capitulation or distribution. Reading direction is on you.
• Does not work on symbols without volume. Most spot forex pairs on retail platforms report tick count, not real volume. For forex volume analysis, use the equivalent futures contract (6E, 6J, 6B) instead.
• Needs history. On a fresh symbol with fewer than N sessions of data (where N is your Trader style setting), the SD calculation may be unstable for the first few sessions. The verdict will read "insufficient history" until samples accumulate.
• DST transitions and holiday-shortened sessions in the lookback window offset the baseline by a bar or two until those sessions roll out of the average.
• Above 1h timeframes, the verdict becomes unreliable. A 4h chart contains only ~6 four-hour bars per futures session — too coarse for stable time-of-day stats. Treat this as a 1m-to-1h tool.

═══ COMPANION TO SESSION VOLUME PULSE ═══

This indicator pairs with Session Volume Pulse [TSL] — same math foundation, different display. SVP includes a z-score toggle (off by default) for users who want everything in one indicator. This standalone exists for users who already have a volume setup they like and just want the verdict.

Note: SVP defaults to 14 sessions (its baseline is tuned for responsiveness). This standalone defaults to "Swing trader" = 21 sessions (tuned for statistical stability of the band crossings). Both choices are intentional — if you run both indicators side by side and want identical numbers, set SVP's "Baseline sessions" to 21 and this script's Trader style to Custom with the same value.

═══ WHY OPEN SOURCE ═══

Closed-source indicators in finance are a known yellow flag — they often do less than claimed or rely on lookahead bias. Every line of this script is readable. Audit the math, fork it, modify it for your strategy. The calculation is intentionally simple.

Pine Script v6, overlay, no repainting. Source visible on this script page.

Disclaimer: This is an analytical tool that displays publicly available volume data with a time-of-day statistical overlay. It does not predict price direction or guarantee any trading outcome. Volume z-score readings can precede continuation, reversal, or no follow-through. Trading futures and equities involves substantial risk of loss. For educational purposes only.

## Source Code

````pine
// ============================================================
//  VOLUME Z-SCORE READOUT [TSL]
//  https://trailingstoploss.com
//
//  Just the readout. No volume histogram, no baseline line, no
//  spike labels — only the z-score box.
//
//      ┌─────────────────────────────────┐
//      │ z=-0.8 · normal for this time   │
//      └─────────────────────────────────┘
//
//  Designed to overlay on price so it doesn't consume a separate
//  pane. Run it alongside whatever volume indicator you already
//  use (or solo if you just want the verdict).
//
//  v1.1 — Now uses time-based time-of-day matching instead of
//         bar-count strides. Correctly handles weekends, daily
//         breaks, holidays, and DST transitions.
//
//  Pine Script v6  |  Overlay (sits on price chart)
// ============================================================

//@version=6
indicator(title = "Volume Z-Score Readout [TSL]", shorttitle = "Vol Z", overlay = true, max_bars_back = 5000)

// ====================== INPUTS ==============================

// ----- 1. Calculation -----
grpCalc = "1. Calculation"

traderStyle = input.string("Swing trader (balanced)", "Trader style", options = ["Day trader (responsive)", "Swing trader (balanced)", "Position trader (very stable)", "Custom (use 'Sessions to average' below)"], group = grpCalc, tooltip = "Pick how responsive the baseline should be:\n\n- Day trader (responsive): 14 sessions. Adapts fast. More noise.\n- Swing trader (balanced): 21 sessions (~one month). DEFAULT.\n- Position trader (very stable): 42 sessions. Slow to adapt.\n- Custom: ignores this preset and uses the 'Sessions to average' input below.")

todSessions = input.int(21, "Sessions to average (only if Custom)", minval = 5, maxval = 60, group = grpCalc, tooltip = "ONLY used when 'Trader style' is set to 'Custom'.")

marketPreset = input.string("Futures (~23h: NQ, ES, CL, GC)", "Market preset", options = ["Auto-detect (24h)", "Futures (~23h: NQ, ES, CL, GC)", "US stocks RTH (6.5h)", "Crypto / forex (24/7)", "Custom (use tolerance below)"], group = grpCalc, tooltip = "Pick your market so the indicator can set the right time-of-day match tolerance for your chart.\n\nThe v1.1 math walks backwards through history matching bars by wall-clock time. Different markets benefit from different tolerance:\n\n- Auto-detect (24h): general purpose, 5-min tolerance.\n- Futures (~23h, DEFAULT): 5-min tolerance. Optimized for NQ, ES, MNQ, MES, CL, MCL, GC, MGC, YM, RTY.\n- US stocks RTH (6.5h): 5-min tolerance, narrow session.\n- Crypto / forex (24/7): 10-min tolerance. 24/7 markets don't need tight matching.\n- Custom: ignores this preset and uses the 'Tolerance' input below.")

todToleranceMin = input.int(5, "Time-of-day tolerance — min (only if Custom)", minval = 0, maxval = 60, group = grpCalc, tooltip = "ONLY used when 'Market preset' is set to 'Custom'.\n\nHow much wall-clock slop is allowed when matching past bars. The script collects bars within ± this many minutes of the current bar's time of day.\n\n- 5: correct for 1m, 5m, 15m charts.\n- 15-30: use for 30m-1h charts.\n- 0: strict matching, only exact-minute hits.")

// ----- 2. Display -----
grpLayout = "2. Display"
tablePos       = input.string("Top right", "Readout position", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpLayout)
tableSize      = input.string("Normal", "Text size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpLayout)
showLabelCell  = input.bool(false, "Show 'Time-of-day' label cell", group = grpLayout, tooltip = "On: two-cell box with 'Time-of-day' on the left and the value on the right. Off (default): single-cell box with just the verdict, more compact.")

// ----- 3. Colors -----
grpColors = "3. Colors"
colNormal  = input.color(#8b949e, "Normal (|z| < 1)",      group = grpColors)
colNotable = input.color(#58a6ff, "Notable (1 <= |z| < 2)", group = grpColors)
colUnusual = input.color(#f0883e, "Unusual (2 <= |z| < 3)", group = grpColors)
colExtreme = input.color(#f85149, "Extreme (|z| >= 3)",     group = grpColors)
colBg      = input.color(#1c2230, "Background",             group = grpColors)
colBorder  = input.color(#2a3140, "Border",                 group = grpColors)
colLabel   = input.color(#8b949e, "'Time-of-day' label color", group = grpColors)

// ----- 4. Alerts -----
grpAlerts = "4. Alerts"

sensitivity = input.string("Balanced (|z| >= 2.0)", "Sensitivity preset", options = ["Conservative (|z| >= 2.5, ~1/week)", "Balanced (|z| >= 2.0)", "Sensitive (|z| >= 1.5, more alerts)", "Custom (use threshold below)"], group = grpAlerts, tooltip = "Pick how often the 'Unusual volume' alert should fire:\n\n- Conservative: alerts only on extreme events (|z| >= 2.5).\n- Balanced (DEFAULT): catches notable → unusual transitions at |z| >= 2.0.\n- Sensitive: alerts at |z| >= 1.5. Many more alerts.\n- Custom: ignores this preset and uses the threshold input below.")

alertThreshold = input.float(2.0, "Alert threshold (only if Custom)", step = 0.1, minval = 1.0, group = grpAlerts, tooltip = "ONLY used when 'Sensitivity preset' is set to 'Custom'.")

// ====================== RESOLVE PRESETS =====================

resolvedTodSessions = switch traderStyle
    "Day trader (responsive)"              => 14
    "Swing trader (balanced)"              => 21
    "Position trader (very stable)"        => 42
    "Custom (use 'Sessions to average' below)" => todSessions
    => 21

resolvedTolerance = switch marketPreset
    "Auto-detect (24h)"                       => 5
    "Futures (~23h: NQ, ES, CL, GC)"          => 5
    "US stocks RTH (6.5h)"                    => 5
    "Crypto / forex (24/7)"                   => 10
    "Custom (use tolerance below)"            => todToleranceMin
    => 5

resolvedAlertThreshold = switch sensitivity
    "Conservative (|z| >= 2.5, ~1/week)"   => 2.5
    "Balanced (|z| >= 2.0)"                => 2.0
    "Sensitive (|z| >= 1.5, more alerts)"  => 1.5
    "Custom (use threshold below)"         => alertThreshold
    => 2.0

// ====================== TIME-BASED TOD SAMPLING =============
// v1.1: time-based time-of-day matching. Walks backwards through
// history and collects bars whose wall-clock time-of-day matches
// the current bar's time-of-day within ±tolerance minutes.

currentMinuteOfDay = hour(time) * 60 + minute(time)

var array<float> samples = array.new<float>()
array.clear(samples)

maxLookback = math.min(2500, bar_index)

int found = 0
int b = 1
while b <= maxLookback and found < resolvedTodSessions
    pastTime = time[b]
    if not na(pastTime)
        pastMinute = hour(pastTime) * 60 + minute(pastTime)
        diff = math.abs(pastMinute - currentMinuteOfDay)
        wrappedDiff = math.min(diff, 1440 - diff)
        if wrappedDiff <= resolvedTolerance
            v = volume[b]
            if not na(v)
                array.push(samples, v)
                found += 1
    b += 1

count = array.size(samples)
todMean = count > 0 ? array.avg(samples) : na
todSD   = count > 1 ? array.stdev(samples) : na
zscore  = (not na(todMean) and not na(todSD) and todSD > 0) ? (volume - todMean) / todSD : na

// ====================== VERDICT LOGIC =======================

getVerdict(float z) =>
    string txt = "insufficient history"
    color col = colNormal
    if not na(z)
        absZ = math.abs(z)
        if absZ < 1
            txt := "normal for this time"
            col := colNormal
        else if absZ < 2
            txt := z > 0 ? "busier than usual" : "quieter than usual"
            col := colNotable
        else if absZ < 3
            txt := z > 0 ? "unusual for this time" : "unusually quiet"
            col := colUnusual
        else
            txt := z > 0 ? "extreme for this time" : "extreme silence"
            col := colExtreme
    [txt, col]

[verdictText, verdictColor] = getVerdict(zscore)

zString = na(zscore) ? "—" : str.format("z={0,number,0.0}", zscore)
valueString = na(zscore) ? "insufficient history" : zString + " · " + verdictText

// ====================== POSITION + SIZE MAPPING =============

getPosition(string p) =>
    switch p
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle center" => position.middle_center
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        "Bottom right"  => position.bottom_right
        =>                 position.top_right

getSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ====================== READOUT RENDER ======================

var table readout = table.new(getPosition(tablePos), columns = 2, rows = 1, bgcolor = colBg, border_color = colBorder, border_width = 1, frame_color = colBorder, frame_width = 1)

if barstate.islast
    sz = getSize(tableSize)
    if showLabelCell
        table.cell(readout, 0, 0, " Time-of-day ", text_color = colLabel, bgcolor = colBg, text_size = sz, text_halign = text.align_center, text_valign = text.align_center)
        table.cell(readout, 1, 0, " " + valueString + " ", text_color = verdictColor, bgcolor = colBg, text_size = sz, text_halign = text.align_left, text_valign = text.align_center)
    else
        table.cell(readout, 0, 0, "", bgcolor = color.new(color.black, 100), text_size = size.tiny)
        table.cell(readout, 1, 0, " " + valueString + " ", text_color = verdictColor, bgcolor = colBg, text_size = sz, text_halign = text.align_left, text_valign = text.align_center)

// ====================== ALERTS ==============================

crossedThreshold = not na(zscore) and not na(zscore[1]) and math.abs(zscore) >= resolvedAlertThreshold and math.abs(zscore[1]) < resolvedAlertThreshold

alertcondition(crossedThreshold, title = "Unusual volume", message = "Volume z-score crossed threshold on {{ticker}} — check the readout box.")
````
