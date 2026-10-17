# Session Volume Pulse [TSL]

- url: https://www.tradingview.com/script/x9plPFDr-Session-Volume-Pulse-TSL/
- type: indicator
- pine_id: PUB;2295ecb8d181414eb7bf3ad2bf485077
- version: 1.0

## Description

Session Volume Pulse shows whether the current bar's volume is unusual for this exact time of day — not just compared to the last 20 bars, but compared to the same minute across the last 14 trading sessions (configurable 5–60).
 
Most volume indicators give you raw volume and a moving average. The problem: the 9:30 AM open is always busy, and noon is always quiet. A 3x spike at 9:30 means nothing — that's just what 9:30 looks like. A 3x spike at noon is genuinely unusual. This indicator makes that distinction obvious.
 
═══ WHAT YOU SEE ═══
 
Two visual signals on the volume pane:
 
1. A subtle blue baseline line showing the typical volume for this exact minute of the trading day, averaged across the past 14 sessions. The line curves upward at the open, dips through lunch, rises into the close — because that's what the average session looks like.
 
2. A multiplier label drawn only on bars where volume is ≥ 2.5x the recent 12-bar average (e.g., "2.7"). Most bars don't get a label. The ones that do are the bars worth attention. Position and orientation are both configurable — see the settings reference below.
 
That's it. No divergence tints. No z-score overlay. No nine-row corner table. Two signals, both readable at a glance.
 
═══ HOW TO READ IT ═══
 
- Bar above baseline + no spike label = elevated participation, soft confirmation
- Bar at or below baseline + no spike label = normal session activity, ignore
- Spike label appears = conviction event worth attention
 
The combination matters most: a spike at the cash open is less meaningful than a spike at noon, because the baseline tells you what's typical for each minute.
 
═══ CRITICAL SETTING: BARS PER SESSION ═══
 
This is the only setting most users need to configure for non-default markets. The default of 0 auto-detects assuming 24h trading, which is correct for crypto/forex and close enough for ~23h futures (NQ, ES, MNQ, MES at 15m).
 
For US stocks during regular trading hours (6.5h), override to:
- 1m chart: 390
- 5m chart: 78
- 15m chart: 26
- 30m chart: 13
 
For futures across other timeframes:
- 1m: 1380
- 5m: 276
- 15m: 92 (or leave at 0)
- 30m: 46
- 1h: 23
 
On 4h and higher timeframes, disable "Show time-of-day baseline" — there aren't enough bars per session for the baseline math to be meaningful. The spike detection still works fine.
 
═══ TUNING THE LOOKBACK ═══
 
The "Baseline sessions to average" setting controls how many past sessions feed the time-of-day average. The default is 14, but the right choice depends on your style:
 
- 5–10 sessions: very responsive, adapts fast after regime shifts (vol expansion, holiday weeks). More spike-alert noise.
- 14 sessions: DEFAULT. Two trading weeks of context. Balances responsiveness with stability. Best for active intraday on 15m futures.
- 21 sessions: one calendar month. More stable baseline, fewer false-spike alerts. Slower to adapt to new regimes.
- 30–60 sessions: swing/positioning context. Very stable, very slow to update. Single high-impact event days (FOMC, CPI) linger in the average for weeks.
 
Rule of thumb: too many marginal spike alerts? Increase the lookback. Baseline feels stale after a vol regime change? Decrease it.
 
═══ ALERTS ═══
 
Two alert conditions, both useful:
 
1. "Volume spike" — fires when volume hits the spike threshold. Use for multi-symbol monitoring.
 
2. "Crossed session baseline" — fires when volume transitions from below to above the typical level (or vice versa). Quieter signal indicating regime change.
 
═══ HONEST LIMITATIONS ═══
 
- Does not predict direction. A spike with a green close is bullish confirmation; a spike with a red close is often capitulation or distribution. The indicator surfaces the conviction event; reading direction is on you.
 
- Does not work on symbols without volume. Most spot forex pairs on retail platforms report tick count, not volume. Use the equivalent futures contract (6E, 6J, 6B) for real volume analysis on forex.
 
- Needs history. On a fresh symbol with fewer sessions of historical bars than your lookback setting, the baseline averages whatever's available and may be choppy for the first few sessions.
 
- Not session-aware for time changes. DST transitions or holiday-shortened sessions in the lookback window will offset the baseline by a bar or two until they roll out of the average.
 
═══ WHY OPEN SOURCE ═══
 
Closed-source indicators in finance are a known yellow flag — they often do less than claimed or rely on lookahead bias to look better in backtests. Every line of this script is readable. Audit the math, fork it, modify it for your strategy. The math is straightforward by design.
 
═══ SETTINGS REFERENCE ═══
 
Acceleration lookback (bars): 12 default. How many recent bars feed spike detection. Use 20 for daily charts.
 
Spike threshold (× average): 2.5 default. How far above average a bar must be to get a label. Lower = more labels.
 
Baseline sessions to average: 14 default (range 5–60). See "Tuning the Lookback" above.
 
Bars per session: 0 (auto). See table above.
 
Spike label position: Four options.
- On bar (top) — text floats just inside the top of the orange bar
- On bar (middle) — text centered inside the bar
- On bar (bottom) — text sits at the base of the bar (DEFAULT)
- Below bar (pill) — legacy orange pill anchored below the bar
 
Spike label orientation: Two options.
- Vertical (stacked) — each character on its own line. Best for narrow bars on lower timeframes. DEFAULT.
- Horizontal — standard single-line text. Best for wider bars on higher timeframes or when bar width comfortably fits the ratio.
 
Position and orientation are independent — any of the four positions can use either orientation, giving you eight visual combinations.
 
Colors: Six configurable colors for bars, baseline, and labels.
 
═══════════════════════════════════════════════════════════════
 
Maintained by TrailingStopLoss.com — more free, open-source trading tools at trailingstoploss.com/tradingview-indicators
 
═══════════════════════════════════════════════════════════════
 
Disclaimer: This is an analytical tool that displays publicly available volume data with a time-of-day baseline overlay. It does not predict price direction or guarantee any trading outcome. Volume spikes can precede continuation, reversal, or no follow-through. Trading futures and equities involves substantial risk of loss. For educational purposes only.

## Source Code

````pine
// ============================================================
//  SESSION VOLUME PULSE [TSL]
//  https://trailingstoploss.com
//
//  Two signals, nothing else:
//    1. A subtle baseline line showing the typical volume at this
//       exact time of day, averaged over the trailing N sessions.
//       Tells you whether the current bar is busier or quieter
//       than the same minute on a normal day.
//    2. A spike label on bars where volume is unusually high
//       relative to the recent average — only the rare ones, so
//       the label means something when you see it.
//
//  No divergence tints. No z-score plot. No info table. No
//  alert spam. The chart shows volume in context. That is all.
//
//  Pine Script v5  |  Non-overlay (own pane)
// ============================================================

//@version=5
indicator(title = "Session Volume Pulse [TSL]", shorttitle = "Session Vol", overlay = false, format = format.volume, precision = 0, max_bars_back = 5000, max_labels_count = 100)

// ====================== INPUTS ==============================

grpCore = "Core Settings"
lenAccel  = input.int(12,  "Acceleration lookback (bars)", minval = 2, group = grpCore, tooltip = "How many recent bars to average when deciding whether the current bar is unusually high. Default 12 is tuned for 15m charts (3 hours of context). Use 20 for daily charts.")
spikeMult = input.float(2.5, "Spike threshold (× average)", step = 0.1, minval = 1.1, group = grpCore, tooltip = "Bar is flagged as a spike when volume is at least this many times the recent average. Default 2.5 surfaces only genuinely unusual bars. Lower for more sensitivity.")

grpTOD = "Session Baseline"
showBaseline    = input.bool(true, "Show time-of-day baseline", group = grpTOD, tooltip = "A subtle line showing typical volume at this exact time of day, averaged over the trailing N sessions. Lets you see whether the current bar is normal for this minute or unusual.")
todSessions     = input.int(14, "Baseline sessions to average", minval = 5, maxval = 60, group = grpTOD, tooltip = "How many past sessions to average for the time-of-day baseline.\n\nPick based on your style:\n  •  5-10  = very responsive, adapts fast after regime shifts (vol expansion, holiday weeks). More spike-alert noise.\n  •  14    = DEFAULT. Two trading weeks of context. Balances responsiveness with stability. Best for active intraday on 15m futures.\n  •  21    = one calendar month. More stable baseline, fewer false-spike alerts. Slower to adapt to new regimes.\n  •  30-60 = swing/positioning context. Very stable, very slow to update. FOMC/CPI pollution lingers for weeks.\n\nIf you're seeing too many marginal spike alerts, increase this. If the baseline feels stale after a vol regime change, decrease it.")
barsPerSession  = input.int(0,  "Bars per session (0 = auto)", minval = 0, maxval = 5000, group = grpTOD, tooltip = "How many bars are in ONE trading session on your chart. Set this so the baseline samples the same time of day each session.\n\nDefaults (0 = auto-detect ≈ 24h):\n  •  Crypto, forex (24/7 or 24/5): leave 0\n  •  Futures (NQ, ES, CL ~23h): leave 0 or set to ~92 at 15m / ~276 at 5m\n  •  US stocks RTH (6.5h): 26 at 15m, 78 at 5m, 390 at 1m, 13 at 30m\n\nIf the baseline line looks noisy or doesn't track the session shape, increase this value to better match your chart's session length.")

grpVis = "Visuals"
showLabels    = input.bool(true, "Show spike labels", group = grpVis)
labelPosition = input.string("On bar (bottom)", "Spike label position", options = ["On bar (top)", "On bar (middle)", "On bar (bottom)", "Below bar (pill)"], group = grpVis, tooltip = "Where the spike ratio label sits relative to the volume bar:\n\n  •  On bar (top)    — text floats just inside the top of the orange bar\n  •  On bar (middle) — text centered inside the bar\n  •  On bar (bottom) — text sits at the base of the bar (default)\n  •  Below bar (pill) — legacy style, orange pill anchored below the bar\n\nAll on-bar styles use plain white text with no background. The pill style adds a colored background and a pointer arrow.")
labelOrientation = input.string("Vertical (stacked)", "Spike label orientation", options = ["Vertical (stacked)", "Horizontal"], group = grpVis, tooltip = "Vertical (stacked): each character on its own line. Best for narrow bars on lower timeframes where horizontal text would overflow. Horizontal: standard single-line text. Best for wider bars on higher timeframes or when bar width comfortably fits the ratio.")

grpColors = "Colors"
colNorm     = input.color(color.new(#8b949e, 25), "Normal volume bar", group = grpColors)
colSpike    = input.color(color.new(#f0883e, 0),  "Spike bar",         group = grpColors)
colBaseline = input.color(color.new(#58a6ff, 30), "Baseline line",     group = grpColors)

// ====================== ACCELERATION ========================

avgVol = ta.sma(volume, lenAccel)
accelRatio = avgVol > 0 ? volume / avgVol : 0.0
isSpike = accelRatio >= spikeMult

// ====================== TIME-OF-DAY BASELINE ================
// Average volume at this exact time-of-day across the trailing N sessions.
// Stride backwards by bars-per-session to land on the same time of day
// in past sessions, then average those volumes.

// Determine stride length:
//   - If user set barsPerSession explicitly (> 0), use that.
//   - Otherwise auto-derive from 24h / bar-interval. Correct for 24h
//     markets (crypto, forex), close enough for ~23h futures, but
//     wrong for shorter-session markets like US stocks RTH (6.5h).
//     Stock traders should override via the input.
secondsPerBar = timeframe.in_seconds("")
autoStride = secondsPerBar > 0 ? math.round(86400.0 / secondsPerBar) : 0
stride = barsPerSession > 0 ? barsPerSession : autoStride

sumTOD = 0.0
countTOD = 0
if stride > 0 and showBaseline
    for s = 1 to todSessions
        offset = s * stride
        if bar_index >= offset
            v = volume[offset]
            if not na(v)
                sumTOD := sumTOD + v
                countTOD := countTOD + 1

baseline = countTOD > 0 ? sumTOD / countTOD : na

// ====================== PLOTS ===============================

// Volume bars — color-coded for spikes vs normal.
// Only two colors total: normal (subtle grey) and spike (orange).
barCol = isSpike ? colSpike : colNorm
plot(volume, title = "Volume", style = plot.style_columns, color = barCol)

// Time-of-day baseline line. Subtle, thin, low-key.
plot(showBaseline ? baseline : na, title = "Session baseline", color = colBaseline, linewidth = 1, style = plot.style_line)

// ====================== SPIKE LABELS ========================

// Helper: stack each character of a string on its own line, returning
// the vertical form. "2.7×" -> "2\n.\n7\n×"
verticalize(s) =>
    result = ""
    len = str.length(s)
    for j = 0 to len - 1
        ch = str.substring(s, j, j + 1)
        result := j == 0 ? ch : result + "\n" + ch
    result

if showLabels and isSpike
    // Resolve position-dependent visual properties.
    isOnBarTop    = labelPosition == "On bar (top)"
    isOnBarMid    = labelPosition == "On bar (middle)"
    isOnBarBot    = labelPosition == "On bar (bottom)"
    isPill        = labelPosition == "Below bar (pill)"
    isOnBar       = isOnBarTop or isOnBarMid or isOnBarBot

    // Anchor Y: depends on position.
    //  • Top:    near the top of the bar (95% of volume)
    //  • Middle: at the bar's midpoint
    //  • Bottom: at the base
    //  • Pill:   at zero, with style_label_up so it sits below
    anchorY = isOnBarTop ? volume * 0.95 : isOnBarMid ? volume / 2 : 0.0

    // Style: on-bar uses style_none (no pointer); pill uses style_label_up.
    labelStyleResolved = isOnBar ? label.style_none : label.style_label_up

    // Build the ratio string. Pill style keeps the × suffix (legacy).
    // On-bar styles drop it for cleaner inline reading.
    ratioStr = isOnBar ? str.tostring(accelRatio, "#.0") : str.tostring(accelRatio, "#.0") + "×"

    // Orientation: vertical stacks each character on its own line,
    // horizontal leaves the string as-is.
    isVertical = labelOrientation == "Vertical (stacked)"
    txtFinal = isVertical ? verticalize(ratioStr) : ratioStr

    // Background color: fully transparent for on-bar styles (text floats
    // inside or against the bar), semi-transparent orange pill for legacy.
    labelBg = isOnBar ? color.new(color.black, 100) : color.new(colSpike, 55)

    // Build tooltip text in pieces, then concatenate on one line
    baselineText = not na(baseline) ? "\nSession baseline: " + str.tostring(baseline, "#") : ""
    tipText = "Volume: " + str.tostring(volume, "#") + "\nAvg(" + str.tostring(lenAccel) + "): " + str.tostring(avgVol, "#") + "\nRatio: " + str.tostring(accelRatio, "#.00") + "×" + baselineText

    label.new(x = bar_index, y = anchorY, text = txtFinal, color = labelBg, textcolor = color.white, style = labelStyleResolved, size = size.small, tooltip = tipText)

// ====================== ALERTS ==============================
// Two alerts only: spike detected, and volume crossing the session
// baseline (signal of regime change vs typical session pattern).
//
// Note: alertcondition() requires `message` to be a compile-time
// constant string, so the spike threshold cannot be embedded
// dynamically. Users can see the actual ratio on the chart label.

baselineCross = showBaseline and not na(baseline) and not na(baseline[1]) and ((volume > baseline and volume[1] <= baseline[1]) or (volume < baseline and volume[1] >= baseline[1]))

alertcondition(isSpike, title = "Volume spike", message = "Volume spike detected on {{ticker}} — check chart for ratio.")
alertcondition(baselineCross, title = "Crossed session baseline", message = "Volume crossed time-of-day baseline on {{ticker}}.")
````
