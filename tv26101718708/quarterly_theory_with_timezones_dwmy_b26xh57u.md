# Quarterly Theory with Timezones (D/W/M/Y)

- url: https://www.tradingview.com/script/b26XH57u-Quarterly-Theory-with-Timezones-D-W-M-Y/
- type: indicator
- pine_id: PUB;b789a71882df4f5c86140b86ed67f922
- version: 1.0

## Description

[b]Quarterly Theory with Timezones (D/W/M/Y)[/b]

Overlays ICT's six-tier Quarterly Theory cycle structure onto any chart. Six nested cycles — Yearly, Monthly, Weekly, Daily, 90-Minute, and the 22.5-Minute Micro — are anchored to a user-selected timezone, so the structure is native to the instrument's driving session rather than hard-wired to New York.
The daily tier follows the AMDX naming convention: Q1 Accumulation (overnight/Asia), Q2 Manipulation / True Open (session open, midnight in the anchor timezone), Q3 Distribution (morning directional push), and Q4 eXpansion (afternoon continuation or reversal). Each quarter is lit in its own color; the 90-minute and 22.5-minute layers add alternating-opacity shading within each quarter so sub-session boundaries read at a glance without explicit tick marks. The True Open — the price at anchor-timezone midnight — is held as a horizontal step line for the rest of the day.

[b]How it works[/b]

Quarterly Theory in ICT methodology divides time into nested cycles, each subdividing into four quarters with the same AMDX rhythm. The script implements the full hierarchy:[list]
[*]Yearly — Q1 (Jan–Mar), Q2 (Apr–Jun), Q3 (Jul–Sep), Q4 (Oct–Dec)
[*]Monthly — Q1 (days 1–7), Q2 (8–14), Q3 (15–21), Q4 (22+)
[*]Weekly — Q1 (Monday), Q2 (Tuesday), Q3 (Wed–Thu), Q4 (Friday)
[*]Daily — Q1 (18:00–00:00), Q2 (00:00–06:00), Q3 (06:00–12:00), Q4 (12:00–18:00)
[*]90-Minute — four sub-quarters within each daily quarter
[*]22.5-Minute — four micro-quarters within each 90-minute block[/list]

All six tiers compute against the selected anchor timezone — every quarter boundary reflects the chosen session's clock, not the chart's host timezone. The True Open is captured as the open price of the bar where Q2 begins (anchor-TZ midnight) and held as a horizontal step until the next Q2 starts.
Background fills are layered: a base AMDX color for the daily quarter, a slightly more opaque overlay on odd 90-minute slots, and a third opacity layer on odd 22.5-minute slots. Finer subdivisions read as alternating bands within their parent quarter.

[b]How to read it[/b]

Each AMDX quarter has its own color (defaults: indigo Q1, teal Q2, red Q3, amber Q4) carrying its role:[list]
[*]Q1 — Accumulation — overnight session where positions are built quietly
[*]Q2 — Manipulation / True Open — session open, where directional liquidity is taken before the real move
[*]Q3 — Distribution — morning push, often the bulk of the day's directional move
[*]Q4 — eXpansion — afternoon continuation or reversal[/list]

The same colors recur at every tier — yearly Q2 is the same color as monthly Q2 is the same color as daily Q2. This is deliberate: AMDX is fractal in the framework, and matching colors across tiers makes alignment between tiers immediately visible.
The True Open line is the reference price for the day. ICT methodology treats Q2 as the session where price typically takes liquidity above or below the True Open before reversing into the Q3 directional move — making the True Open the level Q2 manipulation trades around.
The right-edge label summarizes the current state: enabled higher-tier quarters (e.g. "YQ2 MQ3 WQ1"), the current daily quarter, the current 90-minute and 22.5-minute slot positions, and the active True Open price.
When tiers align — e.g. daily Q3 inside weekly Q3 inside monthly Q3 — the framework treats this as confluent expansion timing, where the same AMDX role is being expressed at multiple horizons simultaneously.

[b]Inputs[/b]
[list]
[*]Session anchor — timezone all six tiers rebase to. Options: America/New_York, Europe/London, Europe/Berlin, Asia/Tokyo, Australia/Sydney, UTC. Default New York.
[*]Yearly / Monthly / Weekly quarters — toggle higher-tier background tints. All off by default.
[*]Daily AMDX quarters — toggle the four-color daily background. Default on. (Required for the 90-min and 22.5-min layers to be visible.)
[*]90-min sub-sessions — alternating-opacity overlay for 90-minute slots. Default on.
[*]22.5-min micro-sessions — alternating-opacity overlay for 22.5-minute slots. Default off (the finest tier, useful for scalping but visually busy).
[*]True Open level — horizontal step line at anchor-TZ midnight price. Default on.
[*]Right-edge cycle label — current-state summary. Default on.
[*]Colors — one per quarter (Q1–Q4), shared across all six tiers.[/list]

[b]Built-in alerts[/b]
[list]
[*]Q1 Accumulation opened — fires the first bar of each daily Q1
[*]Q2 Manipulation opened — fires the first bar of each daily Q2 (the True Open bar)
[*]Q3 Distribution opened — fires the first bar of each daily Q3
[*]Q4 eXpansion opened — fires the first bar of each daily Q4[/list]

Alerts are bound to the daily tier specifically. The higher tiers update infrequently enough that bar-time awareness works without alerts; the sub-tiers update too rapidly for alerts to be useful.

[b]Notes[/b]

The session anchor is the most important setting. ICT's framework is built around New York time because the equity-index futures it was developed for are NY-anchored. Crypto traders should typically use UTC; FX traders focused on European session dynamics can anchor to London or Frankfurt. Picking the wrong timezone doesn't break the indicator — but it means the AMDX cycles align with whichever city's midnight you've chosen, not with the instrument's actual driving session.
The defaults are tuned for a reasonable starting view: daily quarters lit, 90-minute alternation visible, True Open marked, higher tiers off. Turn yearly/monthly/weekly on if you're trading multi-day swings and want to see how shorter cycles nest inside longer ones. Turn 22.5-minute on for the finest scalping tier — but the chart gets visually busy fast.
The True Open is captured at the open of the bar where Q2 begins — so on a 1-hour chart, you'll see the True Open of the hour bar containing midnight rather than the literal midnight tick price. For exact True Open values, drop the chart timeframe to match Q2's start (1-min for tick-perfect, 15-min close-enough on most instruments).
Quarterly Theory is one of the more contested areas of SMC/ICT teaching. Proponents argue it surfaces a fractal time structure that institutional flow respects; sceptics argue any time-of-day framework will appear meaningful in retrospect. The indicator is purely mechanical: it lights the cycles. Whether the lit boundaries genuinely matter to your instrument and timeframe is something you should verify on your own data before relying on the structure for decisions.
This is a structural tool, not a signal generator. It marks where you are in the AMDX hierarchy on multiple horizons.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

// ─────────────────────────────────────────────────────────────────────────────
//                Quarterly Theory (Time Zone Selector)
//                ─────────────────────────────────────
//   Overlays ICT's six-tier Quarterly Theory cycle structure onto any chart.
//   Six nested cycles — Yearly, Monthly, Weekly, Daily, 90-Minute, and the
//   22.5-Minute Micro — are anchored to a user-selected timezone, so the
//   structure is native to the instrument's driving session rather than
//   hardwired to New York.
//
//   The daily tier follows the AMDX naming convention: Q1 Accumulation
//   (overnight/Asia), Q2 Manipulation / True Open (session open, midnight in
//   the anchor TZ), Q3 Distribution (morning directional push), and Q4
//   eXpansion (afternoon continuation or reversal).  Each quarter is lit in
//   its own color; the 90-minute and 22.5-minute layers add alternating-
//   opacity shading within each quarter so sub-session boundaries read without
//   explicit tick marks.  The True Open — the price at anchor-TZ midnight —
//   is held as a horizontal step line for the rest of the day.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Quarterly Theory with Timezones (D/W/M/Y)", shorttitle="QT", overlay=true, max_lines_count=50, max_labels_count=20)

// ── Inputs ───────────────────────────────────────────────────────────────────
tz = input.string("America/New_York", "Session anchor", options=["America/New_York", "Europe/London", "Europe/Berlin", "Asia/Tokyo", "Australia/Sydney", "UTC"], group="Anchor", tooltip="All six cycle tiers rebase to this timezone. New York is futures-correct for index and energy instruments. Crypto traders should use UTC; FX traders anchored to London or Frankfurt can select those accordingly.")

show_yearly   = input.bool(false, "Yearly quarters",            group="Cycles")
show_monthly  = input.bool(false, "Monthly quarters",           group="Cycles")
show_weekly   = input.bool(false, "Weekly quarters",            group="Cycles")
show_daily    = input.bool(true,  "Daily AMDX quarters",        group="Cycles", tooltip="Colors each of the four 6-hour daily quarters in its own AMDX hue. The 90-min and 22.5-min alternating layers are only visible when this is enabled.")
show_90min    = input.bool(true,  "90-min sub-sessions",        group="Cycles", tooltip="Stacks a slightly more opaque overlay on odd 90-minute slots within each daily quarter, making sub-session boundaries visible without explicit tick marks.")
show_22min    = input.bool(false, "22.5-min micro-sessions",    group="Cycles", tooltip="Adds a third opacity layer on odd 22.5-minute slots within each 90-minute block — the finest resolution in the Quarterly Theory hierarchy.")
show_trueopen = input.bool(true,  "True Open level",            group="Cycles", tooltip="Draws the price at anchor-timezone midnight as a horizontal step line. In ICT's framework this is the daily True Open — the reference price that Q2 manipulation trades around.")
show_label    = input.bool(true,  "Right-edge cycle label",     group="Cycles")

q1_col = input.color(#5c6bc0, "Q1 — Accumulation", group="Colors")
q2_col = input.color(#26a69a, "Q2 — Manipulation",  group="Colors")
q3_col = input.color(#ef5350, "Q3 — Distribution",  group="Colors")
q4_col = input.color(#f59e0b, "Q4 — eXpansion",     group="Colors")

// ── Daily AMDX session detection ─────────────────────────────────────────────
in_q1 = not na(time(timeframe.period, "1800-0000", tz))
in_q2 = not na(time(timeframe.period, "0000-0600", tz))
in_q3 = not na(time(timeframe.period, "0600-1200", tz))
in_q4 = not na(time(timeframe.period, "1200-1800", tz))
daily_in = in_q1 or in_q2 or in_q3 or in_q4

// ── Sub-session position (time arithmetic in anchor TZ) ───────────────────────
hr_a  = hour(time, tz)
mn_a  = minute(time, tz)
tod   = hr_a * 60 + mn_a
tod_s = (tod + 360) % 1440
qpos  = tod_s % 360
sub_i = int(math.floor(float(qpos) / 90.0))
mic_i = int(math.floor(float(qpos % 90) / 22.5))

// ── Higher cycle detection ────────────────────────────────────────────────────
yr_q = month(time, tz) <= 3 ? 1 : month(time, tz) <= 6 ? 2 : month(time, tz) <= 9 ? 3 : 4
mo_q = dayofmonth(time, tz) <= 7 ? 1 : dayofmonth(time, tz) <= 14 ? 2 : dayofmonth(time, tz) <= 21 ? 3 : 4
wk_q = dayofweek(time, tz) == 2 ? 1 : dayofweek(time, tz) == 3 ? 2 : dayofweek(time, tz) <= 5 ? 3 : 4

// ── True Open ─────────────────────────────────────────────────────────────────
var float true_open = na
if in_q2 and not in_q2[1]
    true_open := open

// ── Background fills ──────────────────────────────────────────────────────────
// Higher cycle backgrounds
yr_bg = yr_q == 1 ? color.new(q1_col, 95) : yr_q == 2 ? color.new(q2_col, 95) : yr_q == 3 ? color.new(q3_col, 95) : color.new(q4_col, 95)
mo_bg = mo_q == 1 ? color.new(q1_col, 93) : mo_q == 2 ? color.new(q2_col, 93) : mo_q == 3 ? color.new(q3_col, 93) : color.new(q4_col, 93)
wk_bg = wk_q == 1 ? color.new(q1_col, 91) : wk_q == 2 ? color.new(q2_col, 91) : wk_q == 3 ? color.new(q3_col, 91) : color.new(q4_col, 91)

bgcolor(show_yearly  ? yr_bg : na, title="Yearly quarter")
bgcolor(show_monthly ? mo_bg : na, title="Monthly quarter")
bgcolor(show_weekly  ? wk_bg : na, title="Weekly quarter")

// Daily AMDX base fill
amdx_bg = in_q1 ? color.new(q1_col, 88) : in_q2 ? color.new(q2_col, 88) : in_q3 ? color.new(q3_col, 88) : color.new(q4_col, 88)
bgcolor(show_daily and daily_in ? amdx_bg : na, title="AMDX quarter")

// 90-minute alternating overlay (odd slots only — stacks on the AMDX base)
sub_bg = in_q1 ? color.new(q1_col, 82) : in_q2 ? color.new(q2_col, 82) : in_q3 ? color.new(q3_col, 82) : color.new(q4_col, 82)
bgcolor(show_90min and show_daily and daily_in and sub_i % 2 != 0 ? sub_bg : na, title="90-min sub-session")

// 22.5-minute alternating overlay (odd micro slots only — stacks further)
mic_bg = in_q1 ? color.new(q1_col, 78) : in_q2 ? color.new(q2_col, 78) : in_q3 ? color.new(q3_col, 78) : color.new(q4_col, 78)
bgcolor(show_22min and show_daily and daily_in and mic_i % 2 != 0 ? mic_bg : na, title="22.5-min micro")

// ── True Open step line ───────────────────────────────────────────────────────
plot(show_trueopen ? true_open : na, "True Open", color=color.new(q2_col, 20), linewidth=1, style=plot.style_stepline)

// ── Right-edge label ──────────────────────────────────────────────────────────
lbl_bg = in_q1 ? color.new(q1_col, 15) : in_q2 ? color.new(q2_col, 15) : in_q3 ? color.new(q3_col, 15) : in_q4 ? color.new(q4_col, 15) : color.new(color.gray, 15)

var label _lbl = na
if show_label and barstate.islast
    label.delete(_lbl)
    q_name  = in_q1 ? "Q1 · Accumulation" : in_q2 ? "Q2 · Manipulation" : in_q3 ? "Q3 · Distribution" : in_q4 ? "Q4 · eXpansion" : "Off-session"
    sub_str = "90m " + str.tostring(sub_i + 1) + "/4  ·  22m " + str.tostring(mic_i + 1) + "/4"
    to_str  = na(true_open) ? "" : "\nTrue Open  " + str.tostring(true_open, format.mintick)
    ctx_str = (show_yearly ? "  YQ" + str.tostring(yr_q) : "") + (show_monthly ? "  MQ" + str.tostring(mo_q) : "") + (show_weekly ? "  WQ" + str.tostring(wk_q) : "")
    top_str = str.length(ctx_str) > 0 ? str.trim(ctx_str) + "\n" : ""
    lbl_txt = top_str + q_name + "\n" + sub_str + to_str
    _lbl   := label.new(bar_index + 2, close, lbl_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=lbl_bg, textcolor=color.white, size=size.small)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(in_q1 and not in_q1[1], "Q1 Accumulation opened", "{{ticker}} — Q1 Accumulation session opened on {{interval}}")
alertcondition(in_q2 and not in_q2[1], "Q2 Manipulation opened", "{{ticker}} — Q2 Manipulation / True Open on {{interval}}")
alertcondition(in_q3 and not in_q3[1], "Q3 Distribution opened", "{{ticker}} — Q3 Distribution session opened on {{interval}}")
alertcondition(in_q4 and not in_q4[1], "Q4 eXpansion opened",    "{{ticker}} — Q4 eXpansion session opened on {{interval}}")
````
