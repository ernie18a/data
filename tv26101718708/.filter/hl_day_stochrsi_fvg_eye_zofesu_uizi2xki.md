# HL Day + StochRSI + FVG Eye [Zofesu]

- url: https://www.tradingview.com/script/uIZI2XKi-HL-Day-StochRSI-FVG-Eye-Zofesu/
- type: indicator
- pine_id: PUB;c3dd142ebfdf4284b4fd34c0e3147cf9
- version: 1.0

## Description

[b]HL Day + StochRSI + FVG Eye [Zofesu][/b] is an overlay map for intraday traders. It collects yesterday's high and low, the footprint Point of Control and Value Area, Fair Value Gaps from two timeframes and a StochRSI gauge into one chart, and lists every one of those levels in a single price-ordered ladder with its distance from the current price.
 
It is a map, not a signal service. The markers it draws are context. A separate engine inside the script measures whether those markers do better than ordinary bars on the same instrument — and on the defaults shipped here, on XAUUSD M5, the answer at the time of publication is NO EDGE for every group. The table shows that openly instead of hiding it.
 
Each building block is well known: previous-day levels, volume profile, Fair Value Gaps and Stochastic RSI are standard tools. The original part of this script is how they are put together: the StochRSI drawn as a gauge in price space between yesterday's low and high, one ladder that ranks every level by price, a one-shot confluence signal that needs both an oscillator extreme and a zone, and a built-in check of every signal group against its own random baseline.
 
─────────────────────────────────────
[b]01 — What is FVG Eye?[/b]
─────────────────────────────────────
Intraday charts fill up quickly: yesterday's levels, volume levels, gaps from several timeframes, an oscillator in a separate pane. The information is there, but it is hard to see what sits directly above and below price right now.
 
FVG Eye draws all of it on the price chart and then answers that question in a table: which zones are above, which are below, and how far away each one is.
 
The oscillator stays on the price chart too. Instead of a separate pane, it is drawn as a vertical gauge next to the last candle, so you read the level map and the momentum state in one glance.
 
─────────────────────────────────────
[b]02 — Previous Day Levels[/b]
─────────────────────────────────────
[b]PHD[/b] — previous day high (red).
[b]PLD[/b] — previous day low (green).
 
They are taken from the closed daily bar, so they never change during the day and are identical on history and live.
 
─────────────────────────────────────
[b]03 — Footprint POC and Value Area[/b]
─────────────────────────────────────
[b]POC[/b] — the price where the most volume traded (orange).
[b]VAH / VAL[/b] — the upper and lower edge of the value area, where 70% of the day's volume traded (cyan, dashed).
 
[b]Previous Day (Fixed)[/b] — default. Values from the last closed day. Identical on history and live.
[b]Current Day (Live)[/b] — values develop during the day as volume builds. On history TradingView provides a day's profile only once that day has closed, so history shows each day's final profile at its last bar.
 
Row height is set in ticks. Rough guide: XAU 100, BTC 1000, Forex 100, Indices 10. Footprint data is not available on every TradingView plan. If it is missing, the ladder says so in its last row and the rest of the script keeps working.
 
─────────────────────────────────────
[b]04 — Fair Value Gaps on Two Timeframes[/b]
─────────────────────────────────────
A Fair Value Gap is a three-candle pattern where the first and third candle do not overlap, leaving a price range that traded only in one direction.
 
[b]Timeframe 1[/b] — default 15 minutes (green / red boxes).
[b]Timeframe 2[/b] — default 60 minutes (blue / orange boxes).
 
A gap is registered only after its third candle has closed, so no box appears early and none disappears later on history.
 
As price trades back into a gap, the box shrinks to show only the part that is still unfilled. When the gap is completely filled, the box is removed.
 
Set both timeframes equal to or higher than your chart timeframe. A lower FVG timeframe cannot be read from a higher chart, so it is switched off automatically and the ladder tells you which one.
 
─────────────────────────────────────
[b]05 — The StochRSI Gauge[/b]
─────────────────────────────────────
The oscillator is drawn as a vertical scale to the right of the last candle. The bottom of the scale is PLD (0), the top is PHD (100).
 
[b]◈[/b] — the K line. Its colour shows the state: red above 90, orange between 50 and 90, blue between 10 and 50, green below 10.
[b]◇[/b] — the D line, an average of K.
Short marks show the 90, 50 and 10 levels.
 
The defaults 125 / 383 / 5 / 3 are tuned for XAUUSD on the 5-minute chart and describe the higher-timeframe context rather than the last few candles. They are not universal.
 
[b]How to find your own settings:[/b] add TradingView's built-in Stochastic RSI to the same chart, adjust its lengths and its upper and lower lines until the extremes mark the turns you care about, then copy those four numbers into FVG Eye. A starting point that held up across Forex and indices on the Daily chart is 14 / 42 / 5 / 3.
 
─────────────────────────────────────
[b]06 — The Markers[/b]
─────────────────────────────────────
All markers are context, not entries. They appear only on closed bars.
 
[b]90 / 10 labels[/b] — K crossed above 90 or below 10. The oscillator entered an extreme.
 
[b]Breakout return arrows[/b] — price closed outside yesterday's range and then closed back inside it. Arrow down after a return below PHD, arrow up after a return above PLD.
 
[b]Confluence triangles[/b] — an oscillator extreme and a zone line up. K crossing above 90 arms the short side, K crossing below 10 arms the long side. The armed side fires once, the first time a candle closes within 0.5 ATR of the zone (PHD or PLD by default), and then waits for a new extreme.
 
[b]Long / Short Setup[/b] — K crossing back through 50 after the last extreme. These have no marker on the chart. They are available as alerts and they are counted in the validation table.
 
─────────────────────────────────────
[b]07 — The Zone Ladder[/b]
─────────────────────────────────────
The table in the bottom-left corner lists every level from highest to lowest, with the current price inserted at its place.
 
[b]Zone[/b] — PHD, PLD, POC, VAH, VAL, and the middle of each Fair Value Gap (F1 = Timeframe 1, F2 = Timeframe 2).
[b]Price[/b] — the level.
[b]Dist[/b] — distance from the current price.
[b]Side[/b] — ↑ above price, ↓ below price, ● for the POC.
 
When there are more zones than the row limit, only the ones nearest to price are listed. The last row explains anything that is switched off, such as missing footprint data or an FVG timeframe below the chart timeframe.
 
─────────────────────────────────────
[b]08 — Signal Validation (Quick Screen)[/b]
─────────────────────────────────────
Every signal starts a race. A target is placed 1 ATR away in the signal's direction and an opposite level 1 ATR away on the other side. Whichever price touches first decides the race. If neither is touched within 24 bars, or both are touched inside the same bar, the race is not counted.
 
The baseline runs exactly the same race from ordinary bars: every 5th bar without a signal starts one long and one short race. Because both sides of the race are equally far away, a market with no direction would resolve them near 50%.
 
[b]Groups[/b]
LONG — Long Setup and PLD breakout return.
SHORT — Short Setup and PHD breakout return.
CONF long / CONF short — the confluence triangles.
BASE long / BASE short — the baseline. Long groups are compared with BASE long, short groups with BASE short.
 
[b]Columns[/b]
N — number of decided races.
HIT% — share of races that reached the target first.
EDGE — HIT% of the group minus HIT% of its baseline, in percentage points.
 
[b]Verdicts[/b]
BEATS BASELINE — the group reached its target more often than the baseline, beyond what luck explains.
WORSE THAN BASELINE — less often, beyond what luck explains.
NO EDGE — the difference is within what luck can produce.
NOT ENOUGH DATA — fewer than 30 decided races in the group or its baseline.
 
[b]Why +11 pp can still be NO EDGE[/b]
EDGE shows the difference. The verdict asks whether that difference is bigger than chance could produce with this many races. Small groups swing a lot by chance, so they need a bigger difference. With about 45 races, a difference of roughly 15 pp is needed. With about 200 races, roughly 7 pp is enough.
 
[b]What this screen does not do[/b]
Races that start close to each other overlap in time and share the same price move, but the screen counts them as independent. It also tests four groups at once, so one of them can look good by chance. Treat the table as a quick screen, not a final answer.
 
For a rigorous out-of-sample test, connect any of these signals to the separate script Signal Edge Tester [Zofesu]. The breakout return arrows and the confluence triangles can be selected directly as its source, and the Long / Short Setup through their alert conditions.
 
─────────────────────────────────────
[b]09 — Settings[/b]
─────────────────────────────────────
[b]Previous Day Levels[/b]
Show PHD / PLD — default on. Colours, line style, line width.
 
[b]Footprint[/b]
Mode — default Previous Day (Fixed)
Ticks per Footprint Row — default 100
Value Area % — default 70
Show POC, Show VAH / VAL — default on. Colours and widths.
 
[b]StochRSI[/b]
Show StochRSI Gauge — default on
RSI Length / Stochastic Length / K Smoothing / D Smoothing — default 125 / 383 / 5 / 3
Upper / Mid / Lower Level — default 90 / 50 / 10
 
[b]Signals & Alerts[/b]
Extreme labels and breakout return arrows — default on. Hiding them does not stop the validation from counting them.
Alert switches — default on.
 
[b]Zone Confluence Signals[/b]
Show confluence signals — default on
Zone anchor — default PHD / PLD. Other options: VAH / VAL, Both.
Zone tolerance — default 0.5 × ATR
 
[b]Signal Validation[/b]
Show validation table — default on, Top Right, Small
Evaluation horizon — default 24 bars
ATR length — default 14
Target distance — default 1.0 × ATR
Baseline sampling interval — default every 5 bars
Minimum sample per group — default 30
 
[b]Zone Dashboard[/b]
Show — default on, Bottom Left, Small
Max zones listed — default 14
 
[b]FVG Timeframe 1 / Timeframe 2[/b]
Timeframe — default 15 / 60
Max bars back — default 500
Delete box after full fill — default on
Extend boxes to the right — default on
Box length when not extending — default 50 bars
Colours, border style and width.
 
─────────────────────────────────────
[b]10 — How To Use[/b]
─────────────────────────────────────
[b]Step 1 — Read the ladder first[/b]
Look at the nearest zone above and below price and how far away each one is. That is the room price has before it meets the next level.
 
[b]Step 2 — Check the gauge[/b]
The gauge shows whether the oscillator is stretched (above 90 or below 10) or neutral, measured against yesterday's range.
 
[b]Step 3 — Treat markers as context[/b]
A marker tells you something happened at a level. It does not tell you to enter.
 
[b]Step 4 — Check the validation table on your own instrument[/b]
Open the chart you trade and read the table there. A result on XAUUSD M5 says nothing about another symbol or timeframe.
 
[b]Step 5 — Adjust for other instruments and timeframes[/b]
Set the StochRSI lengths as described in section 05, the footprint row height for the instrument, and both FVG timeframes equal to or higher than the chart.
 
[b]Step 6 — Test seriously before you rely on anything[/b]
If one group looks promising, test that single signal in Signal Edge Tester with a locked out-of-sample period before trusting it.
 
─────────────────────────────────────
[b]11 — Limitations[/b]
─────────────────────────────────────
[list][*]The validation table is a quick screen. It does not correct for overlapping races or for testing four groups at once.
[*]The numbers are built from the history your chart has loaded and change as new bars arrive. On low timeframes such as M5 they change faster than on H1 and above.
[*]Footprint data is not available on every TradingView plan.
[*]The default StochRSI settings are tuned for XAUUSD M5 and are not universal.
[*]With extreme validation settings (very long horizon and a baseline on every bar) the number of open races can exceed the internal limit of 500, and the oldest are dropped.
[*]The validation table describes the loaded history only. It does not predict how the signals will behave next.[/list]
 
[b]The publication chart[/b] shows XAUUSD M5 with all default settings. At the time of publication the validation table shows NO EDGE for all four groups.
 
Works on all asset classes: Indices, Forex, Gold, Oil, Stocks, Crypto.
Works on all timeframes. Default settings are tuned for XAUUSD M5.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu
// ═══════════════════════════════════════════════════════════════════
// HL DAY + STOCHRSI + FVG EYE - v2.6
//
// A MAP, NOT A SIGNAL SERVICE.
//
// Previous-day levels, footprint POC / Value Area, multi-timeframe Fair
// Value Gaps and a StochRSI gauge drawn in price space, all collected into
// one price-ordered zone ladder that tells you, at a glance, what sits
// above and below the current price and how far away it is.
//
// The markers this script draws are context, not entries. A second and
// completely independent engine measures whether they reach a target
// before an equally distant opposite level more often than ordinary bars
// on the same instrument do, and says so in plain words. On the defaults
// shipped here, on XAUUSD M5, the honest answer at the time of publication
// was NO EDGE for every group. The table keeps measuring as new bars
// arrive, so read the table, not this comment. On a low timeframe such as
// M5 the numbers move faster than on H1 and above, simply because more
// bars arrive every day.
//
// The validation is a quick screen: it does not correct for overlapping
// races and it tests four groups at once. For a rigorous out-of-sample
// verdict on any of these signals, connect them to the separate script
// Signal Edge Tester [Zofesu].
//
// Every multi-timeframe read is shifted to closed bars, so nothing on this
// chart uses information that was not available at that moment in time.
//
// The defaults are tuned for XAUUSD on the 5-minute chart. Every other
// instrument and timeframe deserves its own settings — see the tooltip on
// RSI Length for a way to find them. On a higher chart timeframe, set both
// FVG timeframes equal to or higher than the chart — a lower FVG timeframe
// is switched off automatically.
// ═══════════════════════════════════════════════════════════════════

//@version=6
indicator("HL Day + StochRSI + FVG Eye [Zofesu]", shorttitle="[Zofesu] FVG Eye", overlay=true,
  max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

grp_pdl = "Previous Day Levels"
show_phd_pld   = input.bool(true,  "Show PHD / PLD",  group=grp_pdl)
phd_color      = input.color(color.new(#ff1744, 0), "PHD Color", group=grp_pdl)
pld_color      = input.color(color.new(#00e676, 0), "PLD Color", group=grp_pdl)
pdl_line_style = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=grp_pdl)
pdl_line_width = input.int(1, "Line Width", minval=1, maxval=4, group=grp_pdl)

grp_fp = "Footprint Settings (POC / VAH / VAL)"
fp_mode   = input.string("Previous Day (Fixed)", "Mode",
  options=["Current Day (Live)", "Previous Day (Fixed)"], group=grp_fp,
  tooltip="Current Day: POC/VAH/VAL develop during the day and move as volume builds — live only. On historical bars TradingView provides a day's profile only once that day has closed, so history shows each day's final profile at its last bar. Previous Day: fixed values from the last closed day, identical on history and live. Neither looks into the future.")
fp_ticks  = input.int(100, "Ticks per Footprint Row", minval=1, group=grp_fp,
  tooltip="Row height in ticks. XAU=100, BTC=1000, Forex=100, Indices=10. Too few rows = coarse POC, too many = slow.")
fp_va_pct = input.int(70,  "Value Area %", minval=1, maxval=100, group=grp_fp,
  tooltip="Share of the day's volume that forms the value area. 70 is the standard. VAH and VAL are its upper and lower edge.")
show_poc  = input.bool(true, "Show POC",       group=grp_fp)
show_va   = input.bool(true, "Show VAH / VAL", group=grp_fp)
poc_color = input.color(color.new(#ff9800, 0), "POC Color",     group=grp_fp)
va_color  = input.color(color.new(#00bcd4, 0), "VAH/VAL Color", group=grp_fp)
poc_width = input.int(2, "POC Line Width",     minval=1, maxval=4, group=grp_fp)
va_width  = input.int(1, "VAH/VAL Line Width", minval=1, maxval=4, group=grp_fp)

grp_srsi = "StochRSI Settings"
srsi_show = input.bool(true, "Show StochRSI Gauge", group=grp_srsi,
  tooltip="Draws the oscillator as a vertical gauge on the right of the chart, scaled between PLD and PHD.")
rsi_len   = input.int(125, "RSI Length",        group=grp_srsi,
  tooltip="These defaults (125 / 383 / 5 / 3) were tuned for XAUUSD on the 5-minute chart and describe the higher-timeframe context rather than the last few candles. They are NOT universal. HOW TO FIND YOUR OWN: add TradingView's built-in Stochastic RSI to the same chart, adjust its lengths and its upper/lower lines until the extremes mark the turns you actually care about, then copy those four numbers here. A starting point that held up across Forex and indices on the Daily chart: 14 / 42 / 5 / 3.")
stoch_len = input.int(383, "Stochastic Length", group=grp_srsi,
  tooltip="How many RSI values the stochastic compares. Longer = a slower gauge that reacts only to bigger swings.")
smooth_k  = input.int(5,  "K Smoothing",       group=grp_srsi,
  tooltip="Smoothing of the K line (the ◈ marker on the gauge). Higher = calmer, but later.")
smooth_d  = input.int(3,  "D Smoothing",       group=grp_srsi,
  tooltip="Smoothing of the D line (the ◇ marker on the gauge), an average of K.")
lvl_upper = input.int(90, "Upper Level", minval=51, maxval=99, group=grp_srsi,
  tooltip="K crossing above this level marks an overbought extreme (label 90) and arms the short side.")
lvl_mid   = input.int(50, "Mid Level",   minval=10, maxval=90, group=grp_srsi,
  tooltip="K falling below this line after an overbought extreme is a Short Setup. K rising above it after an oversold extreme is a Long Setup.")
lvl_lower = input.int(10, "Lower Level", minval=1,  maxval=49, group=grp_srsi,
  tooltip="K crossing below this level marks an oversold extreme (label 10) and arms the long side.")
col_upper = input.color(color.new(#e53935, 0), "Upper Level Color", group=grp_srsi)
col_mid   = input.color(color.new(#9e9e9e, 0), "Mid Level Color",   group=grp_srsi)
col_lower = input.color(color.new(#43a047, 0), "Lower Level Color", group=grp_srsi)

grp_sig = "Signals & Alerts"
show_srsi_sig   = input.bool(true, "Show StochRSI Extreme Signals (K cross 90/10)", group=grp_sig,
  tooltip="Context markers, not entries. They mark the moment the oscillator entered an extreme — what price does next is exactly what the validation table measures. Turning this off only hides them; the statistics keep running.")
sig_col_bear    = input.color(color.new(#e53935, 0), "Bear Signal Color (K>90)", group=grp_sig)
sig_col_bull    = input.color(color.new(#43a047, 0), "Bull Signal Color (K<10)", group=grp_sig)
show_br_ret     = input.bool(true, "Show PHD/PLD Breakout Return Arrows", group=grp_sig,
  tooltip="Marks price closing back inside yesterday's range after having closed outside it. Context, not an entry. Turning this off only hides the arrows; the statistics keep running.")
br_col_bull     = input.color(color.new(#00e676, 0), "Breakout Return Bull Arrow", group=grp_sig)
br_col_bear     = input.color(color.new(#ff1744, 0), "Breakout Return Bear Arrow", group=grp_sig)
alert_k90       = input.bool(true, "Alert: K crosses above 90",               group=grp_sig)
alert_k10       = input.bool(true, "Alert: K crosses below 10",               group=grp_sig)
alert_short_set = input.bool(true, "Alert: K below 50 from 90 — Short Setup", group=grp_sig)
alert_long_set  = input.bool(true, "Alert: K above 50 from 10 — Long Setup",  group=grp_sig)
alert_br        = input.bool(true, "Alert: PHD/PLD Breakout Return",          group=grp_sig)

grp_conf = "Zone Confluence Signals"
conf_show   = input.bool(true, "Show confluence signals", group=grp_conf,
  tooltip="Fires when the oscillator is at an extreme AND price has reached a chosen zone. Crossing 90 arms the short branch, crossing 10 arms the long branch; the branch fires once when price reaches the zone, then waits for a new extreme. This is a narrowing filter, not an entry — it cuts the raw signal count roughly fivefold, which also means its sample grows slowly and its verdict needs a long history. Turning this off only hides the markers; the statistics keep running.")
conf_anchor = input.string("PHD / PLD", "Zone anchor",
  options=["PHD / PLD", "VAH / VAL", "Both"], group=grp_conf,
  tooltip="Which levels count as the zone. PHD/PLD are yesterday's high and low. VAH/VAL are the edges of the value area — in Current Day mode these move as volume builds, which makes the signal noisier than a fixed level.")
conf_tol    = input.float(0.5, "Zone tolerance (× ATR)", minval=0.1, maxval=5.0, step=0.1, group=grp_conf,
  tooltip="How close price must be to the zone to count as reaching it. Wider tolerance = more signals, looser meaning.")
conf_col_bull = input.color(color.new(#00e5ff, 0), "Confluence Long Color",  group=grp_conf)
conf_col_bear = input.color(color.new(#ffea00, 0), "Confluence Short Color", group=grp_conf)
alert_conf    = input.bool(true, "Alert: Zone Confluence", group=grp_conf)

grp_val = "Signal Validation"
val_show       = input.bool(true, "Show validation table", group=grp_val,
  tooltip="Measures whether the directional signals reach a target before an equally distant opposite level more often than ordinary bars on this same instrument do. It never changes a signal — it only measures. It is a quick screen without cluster correction; for a rigorous out-of-sample test use Signal Edge Tester [Zofesu].")
val_pos        = input.string("Top Right", "Validation table position",
  options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right", "Middle Left", "Middle Center", "Middle Right"],
  group=grp_val)
val_size       = input.string("Small", "Validation text size",
  options=["Tiny", "Small", "Normal", "Large"], group=grp_val)
val_horizon    = input.int(24, "Evaluation horizon (bars)", minval=5, maxval=500, step=1, group=grp_val,
  tooltip="How long a race may run. If neither the target nor the opposite level is touched within this many bars, the race is discarded instead of being counted as a loss.")
val_atr_len    = input.int(14, "ATR length for target distance", minval=5, maxval=100, group=grp_val,
  tooltip="ATR length used for the race distance and for the zone tolerance of the confluence signals.")
val_atr_mult   = input.float(1.0, "Target distance (× ATR)", minval=0.2, maxval=10.0, step=0.1, group=grp_val,
  tooltip="Target and opposite level are both placed this far from the signal close. Because both sides are equally distant, a market with no directional information would resolve these races near 50%.")
val_base_every = input.int(5, "Baseline sampling interval (bars)", minval=1, maxval=100, group=grp_val,
  tooltip="Every N-th bar without a signal starts one long and one short control race. Lower = larger control group and a more reliable verdict.")
val_min_sample = input.int(30, "Minimum sample per group", minval=10, maxval=500, step=5, group=grp_val,
  tooltip="Both the signal group and its matching baseline must reach this many decided races before a verdict appears. Below it the table says NOT ENOUGH DATA rather than showing noise.")

grp_dash = "Zone Dashboard"
dash_show = input.bool(true, "Show Zone Dashboard", group=grp_dash)
dash_pos  = input.string("Bottom Left", "Position",
  options=["Top Left", "Top Center", "Bottom Left", "Bottom Center", "Middle Left", "Middle Center"],
  group=grp_dash,
  tooltip="The right edge of the chart is used by the StochRSI gauge — keep the ladder on the left.")
dash_size = input.string("Small", "Text Size",
  options=["Tiny", "Small", "Normal", "Large"], group=grp_dash)
dash_max_zones = input.int(14, "Max zones listed", minval=4, maxval=26, group=grp_dash,
  tooltip="Upper limit of rows in the table. When more zones exist than this, only the ones nearest to the current price are listed. TradingView caps a table at a fixed number of rows, so this keeps the dashboard inside that limit.")

// ── FVG TF1 ─────────────────────────────────────────────────────
grp_fvg1 = "FVG — Timeframe 1"
fvg1_show      = input.bool(true,  "Show FVG TF1", group=grp_fvg1)
fvg1_tf        = input.timeframe("15", "Timeframe 1", group=grp_fvg1,
  tooltip="Set this to your chart timeframe or higher. When the chart timeframe is HIGHER than this setting, TF1 is switched off automatically — a lower timeframe cannot be read meaningfully from a higher one.")
fvg1_max_bars  = input.int(500, "Max bars back", minval=10, maxval=500, group=grp_fvg1,
  tooltip="Delete FVG boxes older than this many chart bars.")
fvg1_del_fill  = input.bool(true,  "Delete box after full fill", group=grp_fvg1,
  tooltip="When price has filled the whole gap, the box is removed. Off = the box stays as a thin line at the filled edge.")
fvg1_extend    = input.bool(true,  "Extend boxes to the right", group=grp_fvg1,
  tooltip="The box keeps growing to the right until it is filled. Off = fixed length set below.")
fvg1_box_len   = input.int(50, "Box length (bars, when not extending)", minval=1, group=grp_fvg1)
fvg1_bull_col  = input.color(color.new(#00c853, 70), "Bull box color", group=grp_fvg1)
fvg1_bear_col  = input.color(color.new(#d50000, 70), "Bear box color", group=grp_fvg1)
fvg1_bull_brd  = input.color(color.new(#00c853, 0),  "Bull border color", group=grp_fvg1)
fvg1_bear_brd  = input.color(color.new(#d50000, 0),  "Bear border color", group=grp_fvg1)
fvg1_brd_style = input.string("Solid", "Border style", options=["Solid","Dashed","Dotted"], group=grp_fvg1)
fvg1_brd_width = input.int(1, "Border width", minval=1, maxval=4, group=grp_fvg1)

// ── FVG TF2 (custom TF) ─────────────────────────────────────────
grp_fvg2 = "FVG — Timeframe 2 (Custom)"
fvg2_show      = input.bool(true,  "Show FVG TF2", group=grp_fvg2)
fvg2_tf        = input.timeframe("60", "Timeframe 2", group=grp_fvg2,
  tooltip="Higher-timeframe context. When the chart timeframe is HIGHER than this setting, TF2 is switched off automatically.")
fvg2_max_bars  = input.int(500, "Max bars back", minval=10, maxval=500, group=grp_fvg2)
fvg2_del_fill  = input.bool(true,  "Delete box after full fill", group=grp_fvg2,
  tooltip="When price has filled the whole gap, the box is removed. Off = the box stays as a thin line at the filled edge.")
fvg2_extend    = input.bool(true,  "Extend boxes to the right", group=grp_fvg2,
  tooltip="The box keeps growing to the right until it is filled. Off = fixed length set below.")
fvg2_box_len   = input.int(50, "Box length (bars, when not extending)", minval=1, group=grp_fvg2)
fvg2_bull_col  = input.color(color.new(#00b0ff, 70), "Bull box color", group=grp_fvg2)
fvg2_bear_col  = input.color(color.new(#ff6d00, 70), "Bear box color", group=grp_fvg2)
fvg2_bull_brd  = input.color(color.new(#00b0ff, 0),  "Bull border color", group=grp_fvg2)
fvg2_bear_brd  = input.color(color.new(#ff6d00, 0),  "Bear border color", group=grp_fvg2)
fvg2_brd_style = input.string("Solid", "Border style", options=["Solid","Dashed","Dotted"], group=grp_fvg2)
fvg2_brd_width = input.int(1, "Border width", minval=1, maxval=4, group=grp_fvg2)

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

f_ls(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_pos(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        "Middle Left"   => position.middle_left
        "Middle Right"  => position.middle_right
        =>                 position.middle_center

f_sz(s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.small

f_brd(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

f_pct(won_n, total_n) =>
    total_n > 0 ? str.tostring(math.round(won_n / total_n * 100)) + "%" : "—"

// ═══════════════════════════════════════════════════════════════════
// STOCHRSI
// ═══════════════════════════════════════════════════════════════════

rsi1 = ta.rsi(close, rsi_len)
stch = ta.stoch(rsi1, rsi1, rsi1, stoch_len)
k    = ta.sma(stch, smooth_k)
d    = ta.sma(k, smooth_d)

// ═══════════════════════════════════════════════════════════════════
// FOOTPRINT
//
// lookahead_off: no future data. With lookahead_on the script would have
// seen the finished day's POC in the middle of that day on historical
// bars — perfect on history, impossible in real time.
// On history a day's profile arrives only at that day's last bar; live it
// develops bar by bar. Previous Day mode therefore reads the value from
// the LAST bar of yesterday (fp_cur_*[1]) — the finished profile of the
// previous day, identical on history and live.
// ═══════════════════════════════════════════════════════════════════

fp_both() =>
    footprint fp      = request.footprint(fp_ticks, fp_va_pct)
    float cur_poc = na
    float cur_vah = na
    float cur_val = na
    if not na(fp)
        volume_row r = fp.poc()
        cur_poc := (r.up_price() + r.down_price()) / 2.0
        cur_vah := fp.vah().up_price()
        cur_val := fp.val().down_price()
    [cur_poc, cur_vah, cur_val]

[fp_cur_poc, fp_cur_vah, fp_cur_val] = request.security(
  syminfo.tickerid, "D", fp_both(),
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Previous day High/Low — [1] together with lookahead_on is the documented
// non-repainting pattern for a value that is already final.
[d1_high_raw, d1_low_raw] = request.security(
  syminfo.tickerid, "D", [high[1], low[1]],
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════════════
// PERSISTENT LEVEL STORAGE
// ═══════════════════════════════════════════════════════════════════

var float phd_val = na
var float pld_val = na
var float poc_val = na
var float vah_val = na
var float val_val = na

bool new_day      = ta.change(time("D")) != 0
bool use_prev_day = fp_mode == "Previous Day (Fixed)"

if new_day
    if not na(d1_high_raw)
        phd_val := d1_high_raw
    if not na(d1_low_raw)
        pld_val := d1_low_raw
    if use_prev_day
        if not na(fp_cur_poc[1])
            poc_val := fp_cur_poc[1]
        if not na(fp_cur_vah[1])
            vah_val := fp_cur_vah[1]
        if not na(fp_cur_val[1])
            val_val := fp_cur_val[1]
    else
        poc_val := na
        vah_val := na
        val_val := na

if not use_prev_day and not new_day and barstate.isconfirmed
    if not na(fp_cur_poc)
        poc_val := fp_cur_poc
    if not na(fp_cur_vah)
        vah_val := fp_cur_vah
    if not na(fp_cur_val)
        val_val := fp_cur_val

bool fp_missing = na(poc_val) and na(vah_val) and na(val_val)

// ═══════════════════════════════════════════════════════════════════
// STATIC LEVEL LINES
// ═══════════════════════════════════════════════════════════════════

var line ln_phd = na
var line ln_pld = na
var line ln_poc = na
var line ln_vah = na
var line ln_val = na
var label lb_phd = na
var label lb_pld = na
var label lb_poc = na
var label lb_vah = na
var label lb_val = na

bool redraw = use_prev_day ? new_day : barstate.isconfirmed

if redraw
    line.delete(ln_phd), line.delete(ln_pld)
    line.delete(ln_poc), line.delete(ln_vah), line.delete(ln_val)
    label.delete(lb_phd), label.delete(lb_pld)
    label.delete(lb_poc), label.delete(lb_vah), label.delete(lb_val)

    ls = f_ls(pdl_line_style)

    if show_phd_pld and not na(phd_val)
        ln_phd := line.new(bar_index, phd_val, bar_index + 1, phd_val,
          extend=extend.right, color=phd_color, width=pdl_line_width, style=ls)
        lb_phd := label.new(bar_index, phd_val,
          "PHD  " + str.tostring(phd_val, format.mintick),
          color=color(na), textcolor=phd_color,
          style=label.style_label_right, size=size.small)

    if show_phd_pld and not na(pld_val)
        ln_pld := line.new(bar_index, pld_val, bar_index + 1, pld_val,
          extend=extend.right, color=pld_color, width=pdl_line_width, style=ls)
        lb_pld := label.new(bar_index, pld_val,
          "PLD  " + str.tostring(pld_val, format.mintick),
          color=color(na), textcolor=pld_color,
          style=label.style_label_right, size=size.small)

    if show_poc and not na(poc_val)
        ln_poc := line.new(bar_index, poc_val, bar_index + 1, poc_val,
          extend=extend.right, color=poc_color, width=poc_width, style=line.style_solid)
        lb_poc := label.new(bar_index, poc_val,
          "POC  " + str.tostring(poc_val, format.mintick),
          color=color(na), textcolor=poc_color,
          style=label.style_label_right, size=size.small)

    if show_va and not na(vah_val)
        ln_vah := line.new(bar_index, vah_val, bar_index + 1, vah_val,
          extend=extend.right, color=va_color, width=va_width, style=line.style_dashed)
        lb_vah := label.new(bar_index, vah_val,
          "VAH  " + str.tostring(vah_val, format.mintick),
          color=color(na), textcolor=va_color,
          style=label.style_label_right, size=size.small)

    if show_va and not na(val_val)
        ln_val := line.new(bar_index, val_val, bar_index + 1, val_val,
          extend=extend.right, color=va_color, width=va_width, style=line.style_dashed)
        lb_val := label.new(bar_index, val_val,
          "VAL  " + str.tostring(val_val, format.mintick),
          color=color(na), textcolor=va_color,
          style=label.style_label_right, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// STOCHRSI GAUGE — the oscillator drawn in price space
// ═══════════════════════════════════════════════════════════════════

var line  g_axis    = na
var line  g_upper   = na
var line  g_mid     = na
var line  g_lower   = na
var label g_lbl_hdr = na
var label g_lbl_k   = na
var label g_lbl_kv  = na
var label g_lbl_d   = na
var label g_lbl_u   = na
var label g_lbl_m   = na
var label g_lbl_l   = na

if srsi_show and not na(phd_val) and not na(pld_val) and phd_val > pld_val
    line.delete(g_axis),  line.delete(g_upper)
    line.delete(g_mid),   line.delete(g_lower)
    label.delete(g_lbl_hdr), label.delete(g_lbl_k)
    label.delete(g_lbl_kv),  label.delete(g_lbl_d)
    label.delete(g_lbl_u),   label.delete(g_lbl_m)
    label.delete(g_lbl_l)

    if barstate.islast
        float hl   = phd_val - pld_val
        float unit = hl / 100.0
        float p_k   = pld_val + unit * k
        float p_d   = pld_val + unit * d
        float p_up  = pld_val + unit * lvl_upper
        float p_mid = pld_val + unit * lvl_mid
        float p_low = pld_val + unit * lvl_lower

        color k_col =
          k >= lvl_upper ? col_upper :
          k <= lvl_lower ? col_lower :
          k >  lvl_mid   ? color.new(#ff9800, 0) :
                           color.new(#2196f3, 0)

        int xb = bar_index + 4
        int xe = bar_index + 6

        g_axis := line.new(xb + 1, phd_val, xb + 1, pld_val,
          color=color.new(color.gray, 55), style=line.style_arrow_both)
        g_upper := line.new(xb, p_up, xe, p_up, color=col_upper)
        g_lbl_u := label.new(xe + 1, p_up, str.tostring(lvl_upper),
          color=color(na), textcolor=col_upper,
          style=label.style_label_left, size=size.tiny)
        g_mid := line.new(xb, p_mid, xe, p_mid, color=col_mid, style=line.style_dashed)
        g_lbl_m := label.new(xe + 1, p_mid, str.tostring(lvl_mid),
          color=color(na), textcolor=col_mid,
          style=label.style_label_left, size=size.tiny)
        g_lower := line.new(xb, p_low, xe, p_low, color=col_lower)
        g_lbl_l := label.new(xe + 1, p_low, str.tostring(lvl_lower),
          color=color(na), textcolor=col_lower,
          style=label.style_label_left, size=size.tiny)
        g_lbl_k := label.new(xb + 1, p_k, "◈",
          color=color(na), textcolor=k_col,
          style=label.style_label_center, size=size.large)
        g_lbl_kv := label.new(xe + 1, p_k,
          "K " + str.tostring(k, "#.#"),
          color=color(na), textcolor=chart.fg_color,
          style=label.style_label_left, size=size.small)
        g_lbl_d := label.new(xb + 1, p_d, "◇",
          color=color(na), textcolor=color.new(color.gray, 20),
          style=label.style_label_center, size=size.normal)
        g_lbl_hdr := label.new(xb + 1, phd_val, "StochRSI",
          color=color(na), textcolor=chart.fg_color,
          style=label.style_label_down, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// STOCHRSI SIGNALS
// ═══════════════════════════════════════════════════════════════════

bool k_cross_90 = ta.crossover(k,  lvl_upper) and barstate.isconfirmed
bool k_cross_10 = ta.crossunder(k, lvl_lower) and barstate.isconfirmed

// Mode is state — it must only change on a closed bar, otherwise an
// intrabar spike would arm a setup that never actually happened.
var int srsi_mode = 0
if barstate.isconfirmed
    if k >= lvl_upper
        srsi_mode := 1
    if k <= lvl_lower
        srsi_mode := -1

bool short_setup = ta.crossunder(k, lvl_mid) and srsi_mode == 1  and barstate.isconfirmed
bool long_setup  = ta.crossover(k,  lvl_mid) and srsi_mode == -1 and barstate.isconfirmed

plotshape(show_srsi_sig and k_cross_90,
  title="StochRSI K>90 Signal",
  style=shape.labeldown, location=location.abovebar,
  color=sig_col_bear, textcolor=color.white,
  text="90", size=size.tiny)

plotshape(show_srsi_sig and k_cross_10,
  title="StochRSI K<10 Signal",
  style=shape.labelup, location=location.belowbar,
  color=sig_col_bull, textcolor=color.white,
  text="10", size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
// PHD / PLD BREAKOUT RETURN
// ═══════════════════════════════════════════════════════════════════

var bool broke_phd = false
var bool broke_pld = false

// A new day brings new PHD/PLD values — a breakout of yesterday's level
// says nothing about today's.
if new_day
    broke_phd := false
    broke_pld := false

if barstate.isconfirmed and not na(phd_val) and not na(pld_val)
    if close[1] > phd_val
        broke_phd := true
    if close <= phd_val and close[1] <= phd_val
        broke_phd := false
    if close[1] < pld_val
        broke_pld := true
    if close >= pld_val and close[1] >= pld_val
        broke_pld := false

// The signal itself is computed regardless of the display switch — hiding
// an arrow must never silently stop the validation engine from counting it.
bool ret_bear = broke_phd and close <= phd_val and barstate.isconfirmed
bool ret_bull = broke_pld and close >= pld_val and barstate.isconfirmed

if ret_bear
    broke_phd := false
if ret_bull
    broke_pld := false

plotshape(show_br_ret and ret_bear,
  title="PHD Breakout Return (Bear)",
  style=shape.arrowdown, location=location.abovebar,
  color=br_col_bear, size=size.normal)

plotshape(show_br_ret and ret_bull,
  title="PLD Breakout Return (Bull)",
  style=shape.arrowup, location=location.belowbar,
  color=br_col_bull, size=size.normal)

// ═══════════════════════════════════════════════════════════════════
// ZONE CONFLUENCE
//
// An oscillator extreme on its own says only that price moved a lot. A
// zone on its own says only where price is. This fires when both line up:
// the oscillator reached an extreme, and price has since travelled to the
// level where the opposite side is expected to defend.
//
// Crossing 90 arms the short branch and crossing 10 arms the long branch.
// The armed branch fires ONCE, the first time price reaches the zone, then
// disarms and waits for the next extreme. Without that one-shot rule the
// signal would repeat on every bar price spends near the level.
// ═══════════════════════════════════════════════════════════════════

float conf_ref_atr = ta.atr(val_atr_len)
float conf_band    = nz(conf_ref_atr, 0.0) * conf_tol

f_at_zone(float z, float band) =>
    not na(z) and band > 0 and math.abs(close - z) <= band

bool use_pd = conf_anchor == "PHD / PLD" or conf_anchor == "Both"
bool use_va = conf_anchor == "VAH / VAL" or conf_anchor == "Both"

bool res_zone = (use_pd and f_at_zone(phd_val, conf_band)) or (use_va and f_at_zone(vah_val, conf_band))
bool sup_zone = (use_pd and f_at_zone(pld_val, conf_band)) or (use_va and f_at_zone(val_val, conf_band))

var bool conf_s_armed = false
var bool conf_l_armed = false

if k_cross_90
    conf_s_armed := true
    conf_l_armed := false
if k_cross_10
    conf_l_armed := true
    conf_s_armed := false

bool conf_short = conf_s_armed and res_zone and barstate.isconfirmed
bool conf_long  = conf_l_armed and sup_zone and barstate.isconfirmed

if conf_short
    conf_s_armed := false
if conf_long
    conf_l_armed := false

plotshape(conf_show and conf_short,
  title="Zone Confluence Short",
  style=shape.triangledown, location=location.abovebar,
  color=conf_col_bear, size=size.small)

plotshape(conf_show and conf_long,
  title="Zone Confluence Long",
  style=shape.triangleup, location=location.belowbar,
  color=conf_col_bull, size=size.small)

// ═══════════════════════════════════════════════════════════════════
// SIGNAL VALIDATION
//
// Each directional signal starts a race: a target one ATR-multiple away in
// the signal's direction, and an opposite level exactly as far on the other
// side. Whichever price reaches first decides it. Neither within the
// horizon, or both inside the same bar, discards the race.
//
// The baseline runs the same race from ordinary bars that produced no
// signal. Long and short baselines are kept SEPARATE on purpose: at one
// bar a long race wins exactly when the short one loses, so pooling them
// would always return 50% and measure nothing. Kept apart they measure the
// instrument's drift, which is what has to be subtracted before a signal
// can be called better than nothing.
// ═══════════════════════════════════════════════════════════════════

type Race
    int   bar_idx
    float tgt
    float opp
    bool  up
    int   grp      // see the group map on v_total below

var array<Race> races = array.new<Race>()

// [decided, won] per group:
// 0 = long signal, 1 = short signal, 2 = base long, 3 = base short,
// 4 = confluence long, 5 = confluence short
var int[] v_total = array.from(0, 0, 0, 0, 0, 0)
var int[] v_won   = array.from(0, 0, 0, 0, 0, 0)

float v_atr = conf_ref_atr

bool sig_long_any  = long_setup  or ret_bull
bool sig_short_any = short_setup or ret_bear

f_open_race(int grp, bool up) =>
    float dist = nz(v_atr, 0.0) * val_atr_mult
    if dist > 0
        Race r = Race.new(
             bar_idx = bar_index,
             tgt     = up ? close + dist : close - dist,
             opp     = up ? close - dist : close + dist,
             up      = up,
             grp     = grp)
        array.push(races, r)
        if array.size(races) > 500
            array.shift(races)
    int(na)

if barstate.isconfirmed
    if sig_long_any
        f_open_race(0, true)
    if sig_short_any
        f_open_race(1, false)
    if conf_long
        f_open_race(4, true)
    if conf_short
        f_open_race(5, false)
    // Control bars: no signal of any kind, sampled periodically, both directions
    if not sig_long_any and not sig_short_any and not conf_long and not conf_short and bar_index % val_base_every == 0
        f_open_race(2, true)
        f_open_race(3, false)

if barstate.isconfirmed and array.size(races) > 0
    for i = array.size(races) - 1 to 0
        if i < array.size(races)
            Race r  = array.get(races, i)
            int  age = bar_index - r.bar_idx
            if age >= 1
                bool hit_tgt = r.up ? high >= r.tgt : low  <= r.tgt
                bool hit_opp = r.up ? low  <= r.opp : high >= r.opp
                bool finish  = false

                if hit_tgt and hit_opp
                    // Order inside one bar is unknown — discard
                    finish := true
                else if hit_tgt
                    array.set(v_total, r.grp, array.get(v_total, r.grp) + 1)
                    array.set(v_won,   r.grp, array.get(v_won,   r.grp) + 1)
                    finish := true
                else if hit_opp
                    array.set(v_total, r.grp, array.get(v_total, r.grp) + 1)
                    finish := true
                else if age >= val_horizon
                    finish := true

                if finish
                    array.remove(races, i)

// Two-proportion test: signal group against its own-direction baseline
f_verdict(int sig_grp, int base_grp, string tag) =>
    int n1 = array.get(v_total, sig_grp)
    int n2 = array.get(v_total, base_grp)
    int w1 = array.get(v_won,   sig_grp)
    int w2 = array.get(v_won,   base_grp)

    string txt = "NOT ENOUGH DATA"
    color  bgc = color.new(#2b2b2b, 0)
    color  fgc = color.new(#999999, 0)
    float  edg = na

    if n1 >= val_min_sample and n2 >= val_min_sample
        float p1 = w1 / n1
        float p2 = w2 / n2
        float pp = (w1 + w2) / (n1 + n2)
        float se = math.sqrt(pp * (1 - pp) * (1 / n1 + 1 / n2))
        edg := (p1 - p2) * 100.0
        float z = se > 0 ? (p1 - p2) / se : na
        if not na(z)
            if z >= 1.96
                txt := tag + " BEATS BASELINE"
                bgc := color.new(#0b5d1e, 0)
                fgc := color.new(#b9f6ca, 0)
            else if z <= -1.96
                txt := tag + " WORSE THAN BASELINE"
                bgc := color.new(#7f0b18, 0)
                fgc := color.new(#ffcdd2, 0)
            else
                txt := tag + ": NO EDGE"
                bgc := color.new(#2b2b2b, 0)
                fgc := color.new(#bbbbbb, 0)
    [txt, bgc, fgc, edg]

var table vtab = table.new(f_pos(val_pos), 4, 14,
  bgcolor=color.new(#0a0a0a, 10),
  border_color=color.new(#333333, 0), border_width=1,
  frame_color=color.new(#444444, 0), frame_width=1)

if val_show and barstate.islast
    [txt_l, bg_l, fg_l, edge_l] = f_verdict(0, 2, "LONG")
    [txt_s, bg_s, fg_s, edge_s] = f_verdict(1, 3, "SHORT")
    [txt_cl, bg_cl, fg_cl, edge_cl] = f_verdict(4, 2, "CONF LONG")
    [txt_cs, bg_cs, fg_cs, edge_cs] = f_verdict(5, 3, "CONF SHORT")

    vsz = f_sz(val_size)

    table.cell(vtab, 0, 0, "SIGNAL VALIDATION", text_color=color.new(#ffffff, 0), text_size=vsz, bgcolor=color.new(#1a1a2e, 0))
    table.merge_cells(vtab, 0, 0, 3, 0)

    table.cell(vtab, 0, 1, "GROUP", text_color=color.new(#aaaaaa, 0), text_size=vsz, bgcolor=color.new(#111122, 0))
    table.cell(vtab, 1, 1, "N",     text_color=color.new(#aaaaaa, 0), text_size=vsz, bgcolor=color.new(#111122, 0))
    table.cell(vtab, 2, 1, "HIT%",  text_color=color.new(#aaaaaa, 0), text_size=vsz, bgcolor=color.new(#111122, 0))
    table.cell(vtab, 3, 1, "EDGE",  text_color=color.new(#aaaaaa, 0), text_size=vsz, bgcolor=color.new(#111122, 0))

    string e_l = na(edge_l) ? "—" : (edge_l > 0 ? "+" : "") + str.tostring(math.round(edge_l, 1)) + " pp"
    string e_s = na(edge_s) ? "—" : (edge_s > 0 ? "+" : "") + str.tostring(math.round(edge_s, 1)) + " pp"
    color  c_l = na(edge_l) ? color.new(#666666, 0) : edge_l > 0 ? color.lime : edge_l < 0 ? color.red : color.yellow
    color  c_s = na(edge_s) ? color.new(#666666, 0) : edge_s > 0 ? color.lime : edge_s < 0 ? color.red : color.yellow

    table.cell(vtab, 0, 2, "LONG signals",  text_color=color.new(#43a047, 0), text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 1, 2, str.tostring(array.get(v_total, 0)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 2, 2, f_pct(array.get(v_won, 0), array.get(v_total, 0)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 3, 2, e_l, text_color=c_l, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))

    table.cell(vtab, 0, 3, "SHORT signals", text_color=color.new(#e53935, 0), text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 1, 3, str.tostring(array.get(v_total, 1)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 2, 3, f_pct(array.get(v_won, 1), array.get(v_total, 1)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 3, 3, e_s, text_color=c_s, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))

    string e_cl = na(edge_cl) ? "—" : (edge_cl > 0 ? "+" : "") + str.tostring(math.round(edge_cl, 1)) + " pp"
    string e_cs = na(edge_cs) ? "—" : (edge_cs > 0 ? "+" : "") + str.tostring(math.round(edge_cs, 1)) + " pp"
    color  c_cl = na(edge_cl) ? color.new(#666666, 0) : edge_cl > 0 ? color.lime : edge_cl < 0 ? color.red : color.yellow
    color  c_cs = na(edge_cs) ? color.new(#666666, 0) : edge_cs > 0 ? color.lime : edge_cs < 0 ? color.red : color.yellow

    table.cell(vtab, 0, 4, "CONF long",  text_color=conf_col_bull, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 1, 4, str.tostring(array.get(v_total, 4)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 2, 4, f_pct(array.get(v_won, 4), array.get(v_total, 4)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 3, 4, e_cl, text_color=c_cl, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))

    table.cell(vtab, 0, 5, "CONF short", text_color=conf_col_bear, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 1, 5, str.tostring(array.get(v_total, 5)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 2, 5, f_pct(array.get(v_won, 5), array.get(v_total, 5)), text_color=color.white, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))
    table.cell(vtab, 3, 5, e_cs, text_color=c_cs, text_size=vsz, bgcolor=color.new(#0a0a0a, 0))

    table.cell(vtab, 0, 6, "BASE long",  text_color=color.new(#9fa8da, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))
    table.cell(vtab, 1, 6, str.tostring(array.get(v_total, 2)), text_color=color.new(#9fa8da, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))
    table.cell(vtab, 2, 6, f_pct(array.get(v_won, 2), array.get(v_total, 2)), text_color=color.new(#9fa8da, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))
    table.cell(vtab, 3, 6, "—", text_color=color.new(#444444, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))

    table.cell(vtab, 0, 7, "BASE short", text_color=color.new(#9fa8da, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))
    table.cell(vtab, 1, 7, str.tostring(array.get(v_total, 3)), text_color=color.new(#9fa8da, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))
    table.cell(vtab, 2, 7, f_pct(array.get(v_won, 3), array.get(v_total, 3)), text_color=color.new(#9fa8da, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))
    table.cell(vtab, 3, 7, "—", text_color=color.new(#444444, 0), text_size=vsz, bgcolor=color.new(#14141f, 0))

    table.cell(vtab, 0, 8, txt_l, text_color=fg_l, text_size=vsz, bgcolor=bg_l)
    table.merge_cells(vtab, 0, 8, 3, 8)

    table.cell(vtab, 0, 9, txt_s, text_color=fg_s, text_size=vsz, bgcolor=bg_s)
    table.merge_cells(vtab, 0, 9, 3, 9)

    table.cell(vtab, 0, 10, txt_cl, text_color=fg_cl, text_size=vsz, bgcolor=bg_cl)
    table.merge_cells(vtab, 0, 10, 3, 10)

    table.cell(vtab, 0, 11, txt_cs, text_color=fg_cs, text_size=vsz, bgcolor=bg_cs)
    table.merge_cells(vtab, 0, 11, 3, 11)

    table.cell(vtab, 0, 12, "Anchor: " + conf_anchor + "  •  quick screen on loaded history — not a win rate",
      text_color=color.new(#777777, 0), text_size=size.tiny, bgcolor=color.new(#0a0a0a, 0))
    table.merge_cells(vtab, 0, 12, 3, 12)

// ═══════════════════════════════════════════════════════════════════
// FVG — FAIR VALUE GAP
//
// Bullish FVG: low > high[2]  → gap top = low,    bottom = high[2]
// Bearish FVG: high < low[2]  → gap top = low[2], bottom = high
//
// The whole pattern is read one bar back ([1] / [3]) so the gap is only
// registered once its third candle has CLOSED. Combined with lookahead_on
// this is the standard non-repainting MTF pattern: on history the script
// sees exactly what it would have seen live.
//
// Partial fill (H/L) — the box always shows the part still UNFILLED:
//   Bullish: price comes down into the gap, candle low enters → top moves down
//   Bearish: price comes up into the gap, candle high enters  → bottom moves up
//   Fully filled → deleted (when del_fill = true)
// ═══════════════════════════════════════════════════════════════════

fvg_detect() =>
    bool  bull     = low[1] > high[3]
    bool  bear     = high[1] < low[3]
    float bull_top = low[1]
    float bull_bot = high[3]
    float bear_top = low[3]
    float bear_bot = high[1]
    [bull, bear, bull_top, bull_bot, bear_top, bear_bot]

[tf1_bull, tf1_bear, tf1_bull_top, tf1_bull_bot,
 tf1_bear_top, tf1_bear_bot] = request.security(
  syminfo.tickerid, fvg1_tf, fvg_detect(),
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[tf2_bull, tf2_bear, tf2_bull_top, tf2_bull_bot,
 tf2_bear_top, tf2_bear_bot] = request.security(
  syminfo.tickerid, fvg2_tf, fvg_detect(),
  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Requesting a LOWER timeframe from a HIGHER chart returns only the last
// value of that period — the pattern cannot be reconstructed. Equal
// timeframe is fine, so the guard is strictly greater-than.
bool tf1_unusable = timeframe.in_seconds() > timeframe.in_seconds(fvg1_tf)
bool tf2_unusable = timeframe.in_seconds() > timeframe.in_seconds(fvg2_tf)

bool tf1_active = fvg1_show and not tf1_unusable
bool tf2_active = fvg2_show and not tf2_unusable

// ── Storage — separate arrays for TF1 and TF2 ────────────────────
var box[]  fvg1_boxes   = array.new<box>()
var bool[] fvg1_is_bull = array.new<bool>()
var int[]  fvg1_created = array.new<int>()

var box[]  fvg2_boxes   = array.new<box>()
var bool[] fvg2_is_bull = array.new<bool>()
var int[]  fvg2_created = array.new<int>()

// ── Create a box ─────────────────────────────────────────────────
f_new_fvg_box(float top, float bot, bool is_bull, bool use_extend, int box_len,
              color bull_col, color bear_col, color bull_brd, color bear_brd,
              string brd_style, int brd_w) =>
    color bg  = is_bull ? bull_col : bear_col
    color brd = is_bull ? bull_brd : bear_brd
    int right_x = bar_index + box_len
    box.new(left=bar_index - 2, top=top, right=right_x, bottom=bot,
      xloc=xloc.bar_index, bgcolor=bg,
      border_color=brd, border_width=brd_w,
      border_style=f_brd(brd_style),
      extend=use_extend ? extend.right : extend.none)

// ── Partial fill + delete + extend + colour sync ─────────────────
// Colours are rewritten every bar, otherwise a change in the settings
// would never reach boxes that already exist.
f_update_fvg(box[] boxes, bool[] is_bull_arr, int[] created_arr,
             bool del_fill, bool use_extend, int box_len,
             color bull_col, color bear_col, color bull_brd, color bear_brd) =>
    int sz_upd = array.size(boxes)
    if sz_upd > 0
        for i = sz_upd - 1 to 0
            if i < array.size(boxes)
                box   b       = array.get(boxes, i)
                bool  is_bull = array.get(is_bull_arr, i)
                float btop    = box.get_top(b)
                float bbot    = box.get_bottom(b)

                box.set_bgcolor(b,       is_bull ? bull_col : bear_col)
                box.set_border_color(b,  is_bull ? bull_brd : bear_brd)

                if use_extend
                    box.set_right(b, bar_index + 1)

                if is_bull
                    if low < btop
                        if low <= bbot
                            if del_fill
                                box.delete(b)
                                array.remove(boxes, i)
                                array.remove(is_bull_arr, i)
                                array.remove(created_arr, i)
                            else
                                box.set_top(b, bbot)
                        else
                            box.set_top(b, low)
                else
                    if high > bbot
                        if high >= btop
                            if del_fill
                                box.delete(b)
                                array.remove(boxes, i)
                                array.remove(is_bull_arr, i)
                                array.remove(created_arr, i)
                            else
                                box.set_bottom(b, btop)
                        else
                            box.set_bottom(b, high)
    int(na)

// ── Delete boxes older than the limit ────────────────────────────
f_purge_old(box[] boxes, bool[] is_bull_arr, int[] created_arr, int max_bars) =>
    int sz = array.size(boxes)
    if sz > 0
        for i = sz - 1 to 0
            if i < array.size(boxes)
                if bar_index - array.get(created_arr, i) > max_bars
                    box.delete(array.get(boxes, i))
                    array.remove(boxes, i)
                    array.remove(is_bull_arr, i)
                    array.remove(created_arr, i)
    int(na)

// ta.change must be evaluated on every bar — skipping bars corrupts its state
bool tf1_bar_changed = ta.change(time(fvg1_tf)) != 0
bool tf2_bar_changed = ta.change(time(fvg2_tf)) != 0

if tf1_active and tf1_bar_changed and barstate.isconfirmed
    if tf1_bull
        b = f_new_fvg_box(tf1_bull_top, tf1_bull_bot, true,
          fvg1_extend, fvg1_box_len,
          fvg1_bull_col, fvg1_bear_col,
          fvg1_bull_brd, fvg1_bear_brd,
          fvg1_brd_style, fvg1_brd_width)
        array.push(fvg1_boxes,   b)
        array.push(fvg1_is_bull, true)
        array.push(fvg1_created, bar_index)

    if tf1_bear
        b = f_new_fvg_box(tf1_bear_top, tf1_bear_bot, false,
          fvg1_extend, fvg1_box_len,
          fvg1_bull_col, fvg1_bear_col,
          fvg1_bull_brd, fvg1_bear_brd,
          fvg1_brd_style, fvg1_brd_width)
        array.push(fvg1_boxes,   b)
        array.push(fvg1_is_bull, false)
        array.push(fvg1_created, bar_index)

if tf2_active and tf2_bar_changed and barstate.isconfirmed
    if tf2_bull
        b = f_new_fvg_box(tf2_bull_top, tf2_bull_bot, true,
          fvg2_extend, fvg2_box_len,
          fvg2_bull_col, fvg2_bear_col,
          fvg2_bull_brd, fvg2_bear_brd,
          fvg2_brd_style, fvg2_brd_width)
        array.push(fvg2_boxes,   b)
        array.push(fvg2_is_bull, true)
        array.push(fvg2_created, bar_index)

    if tf2_bear
        b = f_new_fvg_box(tf2_bear_top, tf2_bear_bot, false,
          fvg2_extend, fvg2_box_len,
          fvg2_bull_col, fvg2_bear_col,
          fvg2_bull_brd, fvg2_bear_brd,
          fvg2_brd_style, fvg2_brd_width)
        array.push(fvg2_boxes,   b)
        array.push(fvg2_is_bull, false)
        array.push(fvg2_created, bar_index)

// ── Update + purge on every closed bar ──────────────────────────
if barstate.isconfirmed
    if tf1_active
        f_update_fvg(fvg1_boxes, fvg1_is_bull, fvg1_created,
          fvg1_del_fill, fvg1_extend, fvg1_box_len,
          fvg1_bull_col, fvg1_bear_col, fvg1_bull_brd, fvg1_bear_brd)
        f_purge_old(fvg1_boxes, fvg1_is_bull, fvg1_created, fvg1_max_bars)

    if tf2_active
        f_update_fvg(fvg2_boxes, fvg2_is_bull, fvg2_created,
          fvg2_del_fill, fvg2_extend, fvg2_box_len,
          fvg2_bull_col, fvg2_bear_col, fvg2_bull_brd, fvg2_bear_brd)
        f_purge_old(fvg2_boxes, fvg2_is_bull, fvg2_created, fvg2_max_bars)

// ═══════════════════════════════════════════════════════════════════
// ZONE DASHBOARD — every level on one price-ordered ladder
// ═══════════════════════════════════════════════════════════════════

f_dist(float zone_price) =>
    float diff = zone_price - close
    string sign = diff >= 0 ? "+" : ""
    sign + str.tostring(diff, format.mintick)

var table dash = table.new(f_pos(dash_pos), 4, 30,
  bgcolor=color.new(#0d0d0d, 10),
  border_color=color.new(#333333, 0), border_width=1,
  frame_color=color.new(#444444, 0), frame_width=1)

if dash_show and barstate.islast
    float[]  z_prices = array.new<float>()
    string[] z_names  = array.new<string>()

    if not na(phd_val)
        array.push(z_prices, phd_val)
        array.push(z_names,  "PHD")
    if not na(vah_val)
        array.push(z_prices, vah_val)
        array.push(z_names,  "VAH")
    if not na(poc_val)
        array.push(z_prices, poc_val)
        array.push(z_names,  "POC")
    if not na(val_val)
        array.push(z_prices, val_val)
        array.push(z_names,  "VAL")
    if not na(pld_val)
        array.push(z_prices, pld_val)
        array.push(z_names,  "PLD")

    if tf1_active and array.size(fvg1_boxes) > 0
        for i = 0 to array.size(fvg1_boxes) - 1
            box  b  = array.get(fvg1_boxes, i)
            bool ib = array.get(fvg1_is_bull, i)
            float mid = (box.get_top(b) + box.get_bottom(b)) / 2.0
            array.push(z_prices, mid)
            array.push(z_names,  ib ? "F1 bull" : "F1 bear")

    if tf2_active and array.size(fvg2_boxes) > 0
        for i = 0 to array.size(fvg2_boxes) - 1
            box  b  = array.get(fvg2_boxes, i)
            bool ib = array.get(fvg2_is_bull, i)
            float mid = (box.get_top(b) + box.get_bottom(b)) / 2.0
            array.push(z_prices, mid)
            array.push(z_names,  ib ? "F2 bull" : "F2 bear")

    // Keep only the zones nearest to price. A table has a fixed row count;
    // without this cap a busy chart overflows it and the script stops.
    int n_all = array.size(z_prices)
    if n_all > dash_max_zones
        for p = 0 to n_all - 2
            for q = 0 to n_all - 2 - p
                if math.abs(array.get(z_prices, q) - close) > math.abs(array.get(z_prices, q + 1) - close)
                    float  tp = array.get(z_prices, q)
                    string tn = array.get(z_names,  q)
                    array.set(z_prices, q,     array.get(z_prices, q + 1))
                    array.set(z_names,  q,     array.get(z_names,  q + 1))
                    array.set(z_prices, q + 1, tp)
                    array.set(z_names,  q + 1, tn)
        while array.size(z_prices) > dash_max_zones
            array.pop(z_prices)
            array.pop(z_names)

    int n = array.size(z_prices)

    table.clear(dash, 0, 0, 3, 29)
    sz = f_sz(dash_size)

    table.cell(dash, 0, 0, "Zone",  text_color=color.new(#aaaaaa, 0), text_size=sz, bgcolor=color.new(#1a1a1a, 0))
    table.cell(dash, 1, 0, "Price", text_color=color.new(#aaaaaa, 0), text_size=sz, bgcolor=color.new(#1a1a1a, 0))
    table.cell(dash, 2, 0, "Dist",  text_color=color.new(#aaaaaa, 0), text_size=sz, bgcolor=color.new(#1a1a1a, 0))
    table.cell(dash, 3, 0, "Side",  text_color=color.new(#aaaaaa, 0), text_size=sz, bgcolor=color.new(#1a1a1a, 0))

    if n > 0
        // Sort descending by price — the ladder
        for i = 0 to n - 2
            for j = 0 to n - 2 - i
                if array.get(z_prices, j) < array.get(z_prices, j + 1)
                    float  tp = array.get(z_prices, j)
                    string tn = array.get(z_names,  j)
                    array.set(z_prices, j,     array.get(z_prices, j + 1))
                    array.set(z_names,  j,     array.get(z_names,  j + 1))
                    array.set(z_prices, j + 1, tp)
                    array.set(z_names,  j + 1, tn)

        int insert_pos = n
        for i = 0 to n - 1
            if close >= array.get(z_prices, i)
                insert_pos := i
                break

        int row = 1
        bool price_drawn = false

        for i = 0 to n - 1
            if row > 28
                break

            if i == insert_pos and not price_drawn
                table.cell(dash, 0, row, "──", text_color=color.new(#ffffff, 10), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
                table.cell(dash, 1, row, str.tostring(close, format.mintick), text_color=color.new(#ffffff, 0), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
                table.cell(dash, 2, row, "●",  text_color=color.new(#ffffff, 10), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
                table.cell(dash, 3, row, "",   text_color=color.new(#ffffff, 10), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
                row         += 1
                price_drawn := true

            if row > 28
                break

            float  zp = array.get(z_prices, i)
            string zn = array.get(z_names,  i)
            color row_col = str.contains(zn, "POC") ? poc_color : zp > close ? color.new(#00b600, 0) : color.new(#be0000, 0)
            string side   = str.contains(zn, "POC") ? "●" : zp > close ? "↑" : "↓"

            table.cell(dash, 0, row, zn, text_color=row_col, text_size=sz, bgcolor=color.new(#111111, 0))
            table.cell(dash, 1, row, str.tostring(zp, format.mintick), text_color=row_col, text_size=sz, bgcolor=color.new(#111111, 0))
            table.cell(dash, 2, row, f_dist(zp), text_color=row_col, text_size=sz, bgcolor=color.new(#111111, 0))
            table.cell(dash, 3, row, side,       text_color=row_col, text_size=sz, bgcolor=color.new(#111111, 0))
            row += 1

        if not price_drawn and row <= 28
            table.cell(dash, 0, row, "──", text_color=color.new(#ffffff, 20), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
            table.cell(dash, 1, row, str.tostring(close, format.mintick), text_color=color.new(#ffffff, 0), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
            table.cell(dash, 2, row, "●",  text_color=color.new(#ffffff, 30), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
            table.cell(dash, 3, row, "",   text_color=color.new(#ffffff, 30), text_size=sz, bgcolor=color.new(#1a1a2e, 0))
            row += 1

        // Status row — what is switched off and why
        string st = ""
        if fp_missing
            st := "POC/VA: no footprint data"
        else if tf1_unusable and tf2_unusable
            st := "FVG off — chart TF above both"
        else if tf1_unusable
            st := "FVG TF1 off — chart TF above TF1"
        else if tf2_unusable
            st := "FVG TF2 off — chart TF above TF2"

        if st != "" and row <= 29
            table.cell(dash, 0, row, st, text_color=color.new(#ff9100, 0), text_size=sz, bgcolor=color.new(#111111, 0))
            table.merge_cells(dash, 0, row, 3, row)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(alert_k90 and k_cross_90,
  title="K crosses above 90",
  message="[FVG Eye] K crossed ABOVE 90 — {{ticker}} {{interval}} — Overbought")

alertcondition(alert_k10 and k_cross_10,
  title="K crosses below 10",
  message="[FVG Eye] K crossed BELOW 10 — {{ticker}} {{interval}} — Oversold")

alertcondition(alert_short_set and short_setup,
  title="SHORT Setup — K below 50 from 90 zone",
  message="[FVG Eye] SHORT SETUP — {{ticker}} {{interval}} — K crossed below 50 after overbought")

alertcondition(alert_long_set and long_setup,
  title="LONG Setup — K above 50 from 10 zone",
  message="[FVG Eye] LONG SETUP — {{ticker}} {{interval}} — K crossed above 50 after oversold")

alertcondition(alert_br and ret_bear,
  title="PHD Breakout Return (Bear)",
  message="[FVG Eye] BEAR RETURN — {{ticker}} {{interval}} — Closed back below PHD")

alertcondition(alert_br and ret_bull,
  title="PLD Breakout Return (Bull)",
  message="[FVG Eye] BULL RETURN — {{ticker}} {{interval}} — Closed back above PLD")

alertcondition(alert_conf and conf_long,
  title="Zone Confluence LONG",
  message="[FVG Eye] CONFLUENCE LONG — {{ticker}} {{interval}} — Oversold extreme reached the support zone")

alertcondition(alert_conf and conf_short,
  title="Zone Confluence SHORT",
  message="[FVG Eye] CONFLUENCE SHORT — {{ticker}} {{interval}} — Overbought extreme reached the resistance zone")
````
