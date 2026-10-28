# ORB Engine | ANONYCRYPTOUS

- url: https://www.tradingview.com/script/EtwoKss0-ORB-Engine-ANONYCRYPTOUS/
- type: indicator
- pine_id: PUB;fde24daccb3047c98048fed62431ba1d
- version: 1.0

## Description

ORB Engine | Anonycryptous
Description & user manual

Why this indicator is different
The opening range is one of the most studied concepts in intraday trading, and for good reason. The first fifteen minutes after a major session opens concentrates the most institutional activity of the day. Breakouts from that range, followed by a retest of the level, are among the most statistically consistent setups available on lower timeframes.

The problem is execution. Most opening range tools stop at the box. They draw a high and low, and leave the trader to figure out the rest: when to trade, how to confirm direction, where the liquidity sits, how to time the entry. That gap between the concept and a usable trade is where most ORB approaches fall apart in practice.

The ORB Engine closes that gap. It does not just draw a box. It tracks the full sequence from formation through confirmation through entry, enforces a discipline around when trades are allowed, maps the session liquidity levels that the price is most likely to target or react from, and scores each setup against five confluence criteria before a signal fires. The result is a complete framework for opening range trading that works across instruments and timeframes.

Important notice
The ORB Engine generates visual states based on price structure, volume confirmation, session timing, and liquidity context. These states are not financial advice. They do not predict future price movement. They do not guarantee profitability. All trading decisions are made entirely by the user. Always manage your own risk. Always apply your own judgment.

1. Overview
The ORB Engine is an overlay indicator that combines opening range detection, breakout confirmation, three entry modes, session liquidity mapping, and a five-point confluence scoring system into a single framework. It is designed for intraday scalping and day trading on any instrument and any timeframe below one hour.

What it includes:
- Opening range box (configurable start and end times) with high, low, and midpoint lines
- Wait period enforcement that blocks entries until the active window opens
- Master toggle to disable the wait period entirely for pure ORB breakout use
- Volume-confirmed breakout detection, active as soon as the box closes
- Three entry modes: midpoint retest, breakout retest, and immediate
- Stop loss and take profit lines (1:1, 1:2, 1:3) drawn on entry
- Trade close detection: dashboard and background reset when stop or final target is hit
- Session liquidity engine with live (dotted) and locked (solid) levels for Asia, London, and NY sessions
- Previous session levels with automatic P. prefix labeling
- Vertical session boundary lines at each session open and close
- Five-point confluence score shown in the dashboard
- Status background coloring: red during wait period, green after entry fires
- Full timezone support: all time inputs in the user's chosen UTC offset
- Dashboard with all live trade and session context
- Nine alert conditions

2. Core concepts
2.1 The opening range box
The box captures the high and low of a configurable time window at the start of the active trading session. The default is the first fifteen minutes of the New York session (14:00-14:15 Amsterdam / 08:00-08:15 New York), which concentrates the most institutional activity of the intraday day. The box is drawn as soon as it closes, with a solid high line, a solid low line, and a dotted midpoint line that extends as the session progresses.

The box range is shown in the dashboard. A narrow box suggests tight price discovery. A wide box suggests early volatility and may require a wider stop if trading it directly.

2.2 The wait period
Breakouts in the first sixty to ninety minutes after a major open are frequently false. Institutional players test liquidity in both directions before committing. The wait period blocks entries from firing until a configurable time, defaulting to 15:30 Amsterdam / 09:30 New York, when the first significant volume wave of the day typically confirms direction.

Critically, breakout direction is still tracked during the wait period. If price breaks above the box high at 14:30 and the wait ends at 15:30, the system already knows the direction is bullish when the active window opens. The entry trigger then watches for the configured retest from that point, without waiting for a new breakout signal.

The wait period can be disabled entirely with the master toggle. With it off, the entry triggers are active immediately after the box closes, which is useful for strategies that do not rely on the NY open timing.

2.3 Entry modes
Three entry modes cover the main ways traders approach ORB setups.

Midpoint retest: the most conservative mode. After a confirmed breakout, the indicator waits for price to pull back to the box midpoint, close on the correct side of it, and then fires the entry signal. This mode is best when the session shows clear reversion behavior after the initial breakout impulse.

Breakout retest: waits for price to retest the box boundary itself (high for a bull breakout, low for a bear breakout) after the initial breakout bar, and fires on a candle that touches the level and closes on the breakout side. This mode suits trending sessions where price breaks cleanly, pulls back briefly to the level, and then continues.

Immediate: fires directly on the confirmed breakout candle. If the breakout happened during the wait period, the entry fires on the first bar of the active window. This is the most aggressive mode and is appropriate when the trader expects strong directional continuation without a pullback.

2.4 Breakout confirmation
A breakout is not registered on a close outside the box alone. The breakout candle's volume must exceed the average volume by a configurable multiplier (default 1.3x). This filters breakouts driven by thin participation, which are more likely to fail on the retest. The volume average and multiplier are both adjustable.

2.5 Stop loss and take profit
The stop loss is placed beyond the opposite side of the box, with a small ATR-based buffer. The buffer multiplier is configurable, allowing tighter or wider placement depending on the instrument and timeframe.

Take profit targets are calculated at 1:1, 1:2, and 1:3 risk-to-reward ratios from the entry level, each toggleable independently. All active levels are drawn as dashed lines from the entry bar and labeled on the chart. The dashboard shows the price levels for active targets.

When the stop is hit or the final active take profit is reached, the dashboard resets to a neutral state. The chart lines remain as a visual record.

2.6 Retest timeout
The retest modes have a configurable bar-count timeout. If price does not return to the required level within that number of bars after the active window opens (or after the breakout, if the wait period is off), the setup expires. The dashboard shows the expired state. The default is 100 bars, which on a 1-minute chart is 100 minutes and on a 5-minute chart is roughly eight hours, so adjust this per timeframe and strategy.


3. Session liquidity engine
3.1 Why session levels matter
Price does not move randomly between sessions. The high and low of the Asia, London, and NY sessions represent pools of resting orders: stops clustered above highs, stops clustered below lows. These are the levels institutional flow targets first. A breakout above the ORB box that is also pushing toward an untested session high is a very different proposition from a breakout into empty space.

The ORB Engine maps these levels automatically and keeps them visible across the session, so the confluence between the ORB setup and the nearest liquidity pool is always visible at a glance.

3.2 Live and locked levels
While a session is in progress, the indicator draws dotted lines for the developing high and low. These lines update in real time as new extremes are set within the window. If price sweeps through what was the high at 03:00 before London has closed, the dotted line moves up immediately, reflecting the new developing high. This prevents the missed sweep problem where a level was set early and then exceeded without the chart updating.

When a session closes, the dotted lines are replaced by solid locked lines. These represent the final confirmed high and low of that session.

3.3 Tested and untested levels
Once a session closes, its levels are tracked for mitigation. If price returns to a locked level and wicks through it, the level is marked as tested by fading to a configurable transparency. It does not disappear. Tested levels can act as re-entry points or warn that a previous pool has been cleared. The untested level count in the dashboard tells you how many unmitigated levels are still active on the chart.

3.4 Previous session levels
When a new session begins, the previous session's locked levels are relabeled with a P. prefix (e.g., P.Asia.H, P.NY.L) immediately at the start of the new session, not when it closes. This makes it immediately clear which levels are current and which are historical. The show previous day toggle controls whether one additional day of locked levels is retained alongside today's.

3.5 Vertical session lines
Vertical lines mark the open and close of each session window in the session's color. Style (solid or dotted) and width are configurable. The lines appear only for the current day and are cleaned up automatically at the next session start.

4. Confluence score
The dashboard shows a five-point confluence score for the current setup, displayed as a bar-style meter (▰▰▰▱▱) with the numeric value alongside. The five criteria are:

1. Box formed: the opening range has closed and the high, low, and midpoint are locked.
2. Volume confirmed: the breakout candle exceeded the volume threshold.
3. Liquidity bias consistent: the breakout direction aligns with the nearest untested session level in that direction (e.g., a bull breakout with an untested high above is a stronger setup than a bull breakout with no untested level overhead).
4. Retest within time: the entry fired before the timeout expired.
5. Risk-to-reward viable: the stop distance is within a configurable multiple of the box range, confirming the setup is not overextended.

A score of 3 or above indicates a setup where multiple factors are confirming each other. A score of 1 or 2 means fewer criteria are met and the setup carries more uncertainty. The score updates live.

5. Timezone and session configuration
All time inputs in the ORB Engine are entered in the user's own timezone. Set your UTC offset once in the Timezone group at the top of the settings, and then enter box start, box end, active window start, session end, and all session liquidity windows in your local clock time. The indicator converts everything to New York time internally.

The dashboard shows a live local clock (Now), the box and active window times in your timezone (Box / Active), and the current UTC offset in the row label so the conversion is always visible.

This design means users in Amsterdam, Dubai, Singapore, or New York all configure the same indicator the same way, in the time they think in, without manually calculating offsets.

6. Status background coloring
The chart background changes state with the setup:

- No background: before the box forms, or after the session ends.
- Red tint: the box has formed and the wait period is active. Entries are blocked.
- Green tint: an entry has fired and the trade is active.

The background colors, their transparency, and whether they are shown at all are individually configurable. The default transparency is high enough to not obscure the candles.

7. Dashboard reference
The dashboard updates on every bar and shows:

Box Status - forming, formed, or —.
Box Range - the distance between the box high and low in ticks.
Wait Status - waiting with remaining minutes, active, disabled, or —.
Breakout - bull, bear, or none.
Entry Mode - the currently selected entry mode.
Midpoint Retest / Breakout Retest / Entry Trigger - the retest status: waiting, fired, expired, or —.
Entry - long, short, or —.
Confluence Score - the five-point bar meter and numeric value.
TP Levels - price levels for each active take profit target, or — if no trade is open.
Session / Untested - the current session name and the count of untested liquidity levels.
Now (UTC offset) - the current local clock time in the configured timezone.
Box / Active - the box window and active window start times in local time.

8. Alerts
Nine alert conditions are available:

- Bull breakout: a volume-confirmed close above the box high.
- Bear breakout: a volume-confirmed close below the box low.
- Long entry signal: a long entry trigger has fired.
- Short entry signal: a short entry trigger has fired.
- Long stop loss hit: the long trade stop has been reached.
- Short stop loss hit: the short trade stop has been reached.
- Long final TP hit: the long trade reached the final active take profit.
- Short final TP hit: the short trade reached the final active take profit.
- Near untested liquidity level: price is within a configurable ATR distance of an untested session level.

9. How to use
9.1 Basic workflow

Set your timezone. Enter the box and session times in your local clock. The wait period defaults to the New York 09:30 open equivalent in your timezone, which is when the most reliable ORB confirmations historically occur.

Let the box form. The dashboard shows the forming state during the box window and transitions to formed when it closes. The box range gives you an immediate read on how much price discovery happened.

Observe the breakout. The system detects breakouts as soon as the box closes, even during the wait period. The dashboard shows the breakout direction and a dot appears on the breakout candle. With the wait period on, the background turns red and entries are blocked.

Wait for the active window. When the wait period ends, the background stays neutral and the entry trigger activates. Depending on the entry mode, it is now watching for a midpoint touch, a boundary retest, or it already fired immediately at the open of the active window.

Check the score. A confluence score of 3 or above with a clean entry signal in the context of a nearby untested session level is the strongest combination the system can produce.

9.2 Entry mode selection
Use midpoint retest on sessions that show clear pullback behavior after the initial breakout impulse. Use breakout retest on sessions that trend strongly but pause briefly at the broken level before continuing. Use immediate when price is moving fast and a retest is unlikely, or when you want to be positioned as early as possible in the active window.

9.3 Session levels as context
Before entering any signal, check which session levels are nearby. An entry directly into an untested opposite-side level is likely to stall or reverse at that level. An entry away from all untested levels, in the direction of the next unmitigated pool, is a cleaner setup. The dashboard untested count and the live chart lines give you this context without any additional tools.

9.4 Illustrative bull scenario
Educational example only. Not a trading recommendation.

The opening range forms between 14:00 and 14:15 with a 20-point range. At 14:35, a candle closes above the box high on 1.6 times average volume. The breakout is confirmed as bull, and the wait period background turns red. At 15:30 the active window opens. Price is still above the box high and the midpoint retest mode is active. At 15:42, price dips back to the midpoint, wicks it, and closes above. The entry fires long. Score is 4/5: box formed, volume confirmed, retest in time, and RR viable. The NY.L below is the nearest untested level, well below the stop, so it is not a concern. TP1 is hit 18 minutes later.

9.5 Illustrative bear scenario
Educational example only. Not a trading recommendation.

A narrow 12-point box forms and breaks below the low at 14:28 on heavy volume. The breakout retest mode is selected. The wait period holds entries. At 15:30, price is trading 30 points below the box low. The system begins watching for a pullback back to the box low. At 15:44, price rallies back to the box low, taps it, and closes below. Short entry fires. Score is 3/5. Stop is placed above the box high with ATR buffer. TP2 is reached before the session ends.


10. Settings reference
Timezone: UTC offset selector for all time inputs and the dashboard clock.

Opening range box: start hour, start minute, end hour, end minute (all in local timezone), box color, box fill transparency, max box history in days.

Wait period: enable toggle, active window start hour and minute, session end hour and minute.

Entry settings: breakout volume multiplier, volume average length, retest timeout in bars, ATR length, stop loss ATR buffer, TP 1:1/1:2/1:3 toggles, SL/TP line projection in bars.

Session liquidity: show toggles for Asia, London, and NY with individual start and end times, colors, tested level transparency, line extend bars, show previous day toggle, label text size, show session vertical lines toggle, vertical line style and width, proximity alert toggle and ATR distance.

Confluence score: maximum risk-to-reward sanity check multiplier.

Dashboard: show toggle, position, text size.

Visualization: wait period background show, color, and transparency; entry active background show, color, and transparency.

11. Known limitations
The ORB Engine is designed for sessions that produce a directional move after the opening range. It performs best when the market has a clear bias — a breakout in one direction that holds and then retests cleanly before continuing.

In choppy, sideways price action, the indicator will produce repeated stop loss hits. If the opening range is narrow and price oscillates around the box boundaries without committing to a direction, a breakout in one direction can be followed immediately by a breakout in the opposite direction. Because the system locks breakout direction on the first confirmed move, subsequent reversals are not re-evaluated as a new setup within the same session. The result in choppy conditions is typically one or two stop loss hits before the session ends without a valid directional move.

This is not a flaw in the indicator — it reflects the reality that opening range strategies depend on directional follow-through. On days where the market is consolidating at the session open, no ORB approach will perform well. The confluence score provides some protection: a score below 3 indicates fewer confirming factors and may warrant sitting on the sidelines. The session liquidity levels can also help — if there is no clear untested level in the breakout direction, the setup has no obvious target and the probability of follow-through is lower.

The volume confirmation filter reduces false breakouts in thin conditions, but it does not eliminate them on highly volatile instruments where even noise candles can exceed the volume threshold. On assets with very low liquidity, the breakout volume multiplier should be raised above the default 1.3 to filter more aggressively.

On very low timeframes such as 1-minute charts, the retest timeout in bars covers fewer minutes. A timeout of 100 bars on a 1-minute chart gives 100 minutes of window. Adjust the timeout per timeframe to reflect how long a valid retest can realistically take on the instrument you are trading.

12. Disclaimer
This indicator is provided for educational and informational purposes only. Nothing in this document or in the indicator output constitutes financial advice or any form of recommendation. Trading financial instruments involves substantial risk of loss. Past performance is not indicative of future results. You may lose all of your invested capital. Anonycryptous accepts no responsibility or liability for any losses incurred as a result of using this indicator.

## Source Code

````pine
//@version=6
indicator('ORB Engine | ANONYCRYPTOUS', shorttitle='ORBE | ANONYCRYPTOUS', overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200, max_bars_back=2000)

// BRAND COLORS — consistent with the rest of the ANONYCRYPTOUS suite
const color C_BULL   = #00ff00
const color C_BEAR   = #ff0000
const color C_GOLD   = #f5c518
const color C_PURP   = #bb86fc
const color C_CYAN   = #15f4ee
const color C_BG     = #0d1117
const color C_PANEL  = #161b22
const color C_BORDER = #30363d
const color C_MUTED  = #8b949e

// Tijdzone/sessie detectie, Box Formation, Wait Period Enforcement

// INPUT GROUPS
G_TZ   = 'Timezone'
G_BOX  = 'Opening Range Box'
G_WAIT = 'Wait Period'
G_ENTRY = 'Entry Settings'
G_LIQ  = 'Session Liquidity'
G_SCORE = 'Confluence Score'
G_DASH = 'Dashboard'
G_VIS  = 'Visualization'

// INPUTS — BOX
// INPUTS — TIMEZONE
// Every time input below (Box, Wait, Liquidity sessions) is entered
// in THIS timezone — set it to your own UTC offset once, then enter
// all session times in your own local clock. The script converts
// everything to EST/New York internally, since that's where the
// actual market session logic needs to run.
displayTimezone = input.string("UTC+0", "Your Timezone (UTC Offset)", options = ["UTC-12", "UTC-11", "UTC-10", "UTC-9:30", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3:30", "UTC-3", "UTC-2", "UTC-1", "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+3:30", "UTC+4", "UTC+4:30", "UTC+5", "UTC+5:30", "UTC+5:45", "UTC+6", "UTC+6:30", "UTC+7", "UTC+8", "UTC+8:45", "UTC+9", "UTC+9:30", "UTC+10", "UTC+10:30", "UTC+11", "UTC+12", "UTC+12:45", "UTC+13", "UTC+14"], group = G_TZ, tooltip = "Set this to your own UTC offset (e.g. UTC+2 for Amsterdam in summer). ALL time inputs in this indicator — Box, Wait, and Session Liquidity — are entered in this timezone. The script converts them to EST/New York internally for the actual session logic.")

utcOffsetMinutes(string sel) =>
    switch sel
        "UTC-12" => -720
        "UTC-11" => -660
        "UTC-10" => -600
        "UTC-9:30" => -570
        "UTC-9" => -540
        "UTC-8" => -480
        "UTC-7" => -420
        "UTC-6" => -360
        "UTC-5" => -300
        "UTC-4" => -240
        "UTC-3:30" => -210
        "UTC-3" => -180
        "UTC-2" => -120
        "UTC-1" => -60
        "UTC+0" => 0
        "UTC+1" => 60
        "UTC+2" => 120
        "UTC+3" => 180
        "UTC+3:30" => 210
        "UTC+4" => 240
        "UTC+4:30" => 270
        "UTC+5" => 300
        "UTC+5:30" => 330
        "UTC+5:45" => 345
        "UTC+6" => 360
        "UTC+6:30" => 390
        "UTC+7" => 420
        "UTC+8" => 480
        "UTC+8:45" => 525
        "UTC+9" => 540
        "UTC+9:30" => 570
        "UTC+10" => 600
        "UTC+10:30" => 630
        "UTC+11" => 660
        "UTC+12" => 720
        "UTC+12:45" => 765
        "UTC+13" => 780
        "UTC+14" => 840
        => 0

displayOffsetMin = utcOffsetMinutes(displayTimezone)

boxStartHour = input.int(8, "Box Start Hour (Local)", minval = 0, maxval = 23, group = G_BOX, tooltip = "Hour (24h, in your selected Timezone) when the opening range box begins forming.")
boxStartMin  = input.int(0, "Box Start Minute (Local)", minval = 0, maxval = 59, group = G_BOX, tooltip = "Minute when the opening range box begins forming.")
boxEndHour   = input.int(8, "Box End Hour (Local)", minval = 0, maxval = 23, group = G_BOX, tooltip = "Hour (24h, in your selected Timezone) when the opening range box closes.")
boxEndMin    = input.int(15, "Box End Minute (Local)", minval = 0, maxval = 59, group = G_BOX, tooltip = "Minute when the opening range box closes.")
boxColor     = input.color(color.new(#FFBF00, 0), "Box Color", group = G_BOX, tooltip = "Color used for the opening range box border, fill, and level lines.")
boxTransp    = input.int(85, "Box Fill Transparency", minval = 0, maxval = 99, group = G_BOX, tooltip = "Transparency of the opening range box fill. 0 = fully opaque, 99 = almost invisible. Border and lines are always solid.")
maxBoxHistory = input.int(2, "Max Box History (days)", minval = 1, maxval = 20, group = G_BOX, tooltip = "Number of past opening range boxes to keep drawn on the chart. Older boxes are automatically removed to prevent clutter.")

// INPUTS — WAIT
useWaitPeriod  = input.bool(true, "Enable Wait Period", group = G_WAIT, tooltip = "When ON, entries are blocked until the Active Window Start time — the indicator waits for the NY session open before allowing signals. When OFF, entries fire immediately after the box closes, with no waiting period. The box still forms at the configured times regardless of this setting.")
waitEndHour = input.int(9, "Active Window Start Hour (Local)", minval = 0, maxval = 23, group = G_WAIT, tooltip = "Hour (24h, in your selected Timezone) when the wait period ends and the active confirmation window begins.")
waitEndMin  = input.int(30, "Active Window Start Minute (Local)", minval = 0, maxval = 59, group = G_WAIT, tooltip = "Minute when the wait period ends and the active confirmation window begins.")
sessionEndHour = input.int(16, "Session End Hour (Local)", minval = 0, maxval = 23, group = G_WAIT, tooltip = "Hour (24h, in your selected Timezone) when the active trading session ends for the day.")
sessionEndMin  = input.int(0, "Session End Minute (Local)", minval = 0, maxval = 59, group = G_WAIT, tooltip = "Minute when the active trading session ends for the day.")

// INPUTS — ENTRY (breakout, retest, SL/TP)
volMultiplier = input.float(1.3, "Breakout Volume Multiplier", minval = 1.0, step = 0.1, group = G_ENTRY, tooltip = "Breakout candle volume must be at least this multiple of the average volume to be considered confirmed.")
volAvgLength  = input.int(20, "Volume Average Length", minval = 5, group = G_ENTRY, tooltip = "Number of bars used to calculate the average volume for the breakout confirmation filter.")
retestTimeoutBars = input.int(100, "Midpoint Retest Timeout (bars)", minval = 1, group = G_ENTRY, tooltip = "Number of bars after a confirmed breakout within which price must retest the midpoint, or the setup expires. Not used in Immediate entry mode.")
entryMode = input.string("Midpoint Retest", "Entry Mode", options = ["Midpoint Retest", "Breakout Retest", "Immediate"], group = G_ENTRY, tooltip = "Midpoint Retest: waits for a pullback to the box midpoint after breakout (conservative, may miss strong trending breakouts). Breakout Retest: waits for price to retest the box high/low boundary itself. Immediate: enters directly on the confirmed breakout candle, no retest required (most aggressive, catches strong trends that never pull back).")
atrLength = input.int(14, "ATR Length", minval = 1, group = G_ENTRY, tooltip = "Number of bars used to calculate the Average True Range for the stop loss buffer.")
atrBufferMult = input.float(0.2, "Stop Loss ATR Buffer", minval = 0.0, step = 0.1, group = G_ENTRY, tooltip = "Additional buffer added beyond the box high/low for the stop loss, expressed as a multiple of ATR.")
useRR1 = input.bool(true, "Enable TP 1:1", group = G_ENTRY, tooltip = "Enable the first take profit target at a 1:1 risk-to-reward ratio.")
useRR2 = input.bool(true, "Enable TP 1:2", group = G_ENTRY, tooltip = "Enable the second take profit target at a 1:2 risk-to-reward ratio.")
useRR3 = input.bool(true, "Enable TP 1:3", group = G_ENTRY, tooltip = "Enable the third take profit target at a 1:3 risk-to-reward ratio.")
projectBars = input.int(30, "SL/TP Line Projection (bars)", minval = 1, group = G_ENTRY, tooltip = "Number of bars the stop loss and take profit lines extend forward from the entry candle.")

// INPUTS — SESSION LIQUIDITY
showAsia   = input.bool(true, "Show Asia Session Levels", group = G_LIQ, tooltip = "Show the high and low of the Asia session as untested liquidity levels.")
asiaStartHour = input.int(20, "Asia Start Hour (Local)", minval = 0, maxval = 23, group = G_LIQ, tooltip = "Hour (24h, in your selected Timezone) when the Asia session window begins.")
asiaStartMin  = input.int(0, "Asia Start Minute (Local)", minval = 0, maxval = 59, group = G_LIQ, tooltip = "Minute when the Asia session window begins.")
asiaEndHour   = input.int(0, "Asia End Hour (Local)", minval = 0, maxval = 23, group = G_LIQ, tooltip = "Hour (24h, in your selected Timezone) when the Asia session window ends.")
asiaEndMin    = input.int(0, "Asia End Minute (Local)", minval = 0, maxval = 59, group = G_LIQ, tooltip = "Minute when the Asia session window ends.")
asiaColor     = input.color(color.purple, "Asia Session Color", group = G_LIQ, tooltip = "Color used for Asia session high/low liquidity lines.")

showLondon = input.bool(true, "Show London Session Levels", group = G_LIQ, tooltip = "Show the high and low of the London session as untested liquidity levels.")
londonStartHour = input.int(3, "London Start Hour (Local)", minval = 0, maxval = 23, group = G_LIQ, tooltip = "Hour (24h, in your selected Timezone) when the London session window begins.")
londonStartMin  = input.int(0, "London Start Minute (Local)", minval = 0, maxval = 59, group = G_LIQ, tooltip = "Minute when the London session window begins.")
londonEndHour   = input.int(8, "London End Hour (Local)", minval = 0, maxval = 23, group = G_LIQ, tooltip = "Hour (24h, in your selected Timezone) when the London session window ends.")
londonEndMin    = input.int(0, "London End Minute (Local)", minval = 0, maxval = 59, group = G_LIQ, tooltip = "Minute when the London session window ends.")
londonColor     = input.color(color.blue, "London Session Color", group = G_LIQ, tooltip = "Color used for London session high/low liquidity lines.")

showNY = input.bool(true, "Show NY Session Levels", group = G_LIQ, tooltip = "Show the high and low of the previous NY session as untested liquidity levels.")
nyStartHour = input.int(9, "NY Start Hour (Local)", minval = 0, maxval = 23, group = G_LIQ, tooltip = "Hour (24h, in your selected Timezone) when the NY session window begins.")
nyStartMin  = input.int(30, "NY Start Minute (Local)", minval = 0, maxval = 59, group = G_LIQ, tooltip = "Minute when the NY session window begins.")
nyEndHour   = input.int(16, "NY End Hour (Local)", minval = 0, maxval = 23, group = G_LIQ, tooltip = "Hour (24h, in your selected Timezone) when the NY session window ends.")
nyEndMin    = input.int(0, "NY End Minute (Local)", minval = 0, maxval = 59, group = G_LIQ, tooltip = "Minute when the NY session window ends.")
nyColor     = input.color(color.orange, "NY Session Color", group = G_LIQ, tooltip = "Color used for previous NY session high/low liquidity lines.")

testedAlpha = input.int(45, "Tested Level Transparency", minval = 0, maxval = 99, group = G_LIQ, tooltip = "Transparency applied to a session liquidity level once price has touched it. Higher values fade the level more, but it stays visible.")
lineExtendBars = input.int(20, "Line Extend (bars)", minval = 1, group = G_LIQ, tooltip = "Number of bars each session liquidity line extends to the right of the current bar. Updated every bar.")
showPrevDay = input.bool(false, "Show Previous Day's Levels", group = G_LIQ, tooltip = "When ON, keeps today's and yesterday's session levels visible. When OFF, only today's levels are shown. Older levels are always removed automatically.")
textSize = input.string("Tiny", "Liquidity Label Text Size", options = ["Tiny", "Small"], group = G_LIQ, tooltip = "Text size for the session liquidity level labels on the chart.")
showSessionVLines = input.bool(true, "Show Session Start/End Vertical Lines", group = G_LIQ, tooltip = "Draw a full-height vertical line at the start and end of each session window, in that session's color.")
vlineStyle = input.string("Solid", "Vertical Line Style", options = ["Solid", "Dotted"], group = G_LIQ, tooltip = "Line style used for the session start/end vertical lines.")
vlineWidth = input.int(1, "Vertical Line Width", minval = 1, maxval = 4, group = G_LIQ, tooltip = "Line width used for the session start/end vertical lines.")
liqProximityAlert = input.bool(false, "Alert When Price Nears Untested Level", group = G_LIQ, tooltip = "Trigger an alert condition when price approaches an untested session liquidity level.")
liqProximityATR = input.float(0.5, "Proximity Distance (ATR×)", minval = 0.1, step = 0.1, group = G_LIQ, tooltip = "Distance from an untested level, expressed as an ATR multiple, within which the proximity alert triggers.")

// INPUTS — CONFLUENCE SCORE
riskSanityMult = input.float(1.5, "Max Risk vs Box Range (×)", minval = 0.5, step = 0.1, group = G_SCORE, tooltip = "Stop loss distance must not exceed this multiple of the box range for the RR Setup score point to be awarded.")

// INPUTS — DASHBOARD
showDashboard = input.bool(true, "Show Dashboard", group = G_DASH, tooltip = "Show the on-chart dashboard table with live setup status.")
dashPosition = input.string("Bottom Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = G_DASH, tooltip = "Screen position of the dashboard table.")
dashTextSize = input.string("Tiny", "Dashboard Text Size", options = ["Tiny", "Small", "Normal"], group = G_DASH, tooltip = "Text size used inside the dashboard table.")

// INPUTS — VISUALIZATION (status background)
showWaitBg   = input.bool(true, "Show Wait Period Background", group = G_VIS, tooltip = "Show a subtle background tint during the wait period to indicate that no entries are allowed.")
waitBgColor  = input.color(C_BEAR, "Wait Period Background Color", group = G_VIS, tooltip = "Base color used for the wait period background tint. Transparency is controlled separately.")
waitBgTransp = input.int(85, "Wait Period Background Transparency", minval = 50, maxval = 99, group = G_VIS, tooltip = "Transparency percentage for the wait period background tint. Higher values are more subtle.")
showEntryBg   = input.bool(true, "Show Entry Active Background", group = G_VIS, tooltip = "Show a background tint after the midpoint reclaim entry fires, confirming the setup is active.")
entryBgColor  = input.color(C_BULL, "Entry Active Background Color", group = G_VIS, tooltip = "Base color used for the background tint once an entry has fired. Transparency is controlled separately.")
entryBgTransp = input.int(85, "Entry Active Background Transparency", minval = 50, maxval = 99, group = G_VIS, tooltip = "Transparency percentage for the entry active background tint. Higher values are more subtle.")

// TIMEZONE / SESSION DETECTION UTILITY
// that's the actual market event time and must not shift. But the
// Box/Wait/Liquidity inputs above are entered in the user's own
// Timezone setting (G_TZ), so we convert them to EST-minutes-of-day
// here before they're used for window comparisons. The EST-UTC
// offset is derived live from the current bar, so DST (EDT vs EST)
// is handled automatically — no manual adjustment needed.

estHour = hour(time, "America/New_York")
estMin  = minute(time, "America/New_York")
estTimeInMinutes = estHour * 60 + estMin

utcHourNow = hour(time, "UTC")
utcMinNow  = minute(time, "UTC")

// breaks whenever EST and UTC fall on different calendar dates (e.g.
// UTC 00:00-04:00, when EST is still on the previous day) — the hour
// values wrap around independently and produce a wildly wrong offset
// for that window. Fix: build a fake UTC timestamp out of the EST
// clock reading (date included) and diff it against the real bar
// timestamp. This is correct across midnight in either direction.
estYear  = year(time, "America/New_York")
estMonth = month(time, "America/New_York")
estDay   = dayofmonth(time, "America/New_York")
estAsUtcMs = timestamp("UTC", estYear, estMonth, estDay, estHour, estMin, 0)
estUtcOffsetMin = int((estAsUtcMs - time) / 60000)

// Converts a LOCAL clock time (in the user's Timezone setting) to
// EST-minutes-of-day (0-1439), wrapping correctly across midnight.
localToEstMinutes(int localH, int localM) =>
    totalLocalMin = localH * 60 + localM
    totalUtcMin = totalLocalMin - displayOffsetMin
    totalEstMin = totalUtcMin + estUtcOffsetMin
    wrapped = totalEstMin % 1440
    wrapped < 0 ? wrapped + 1440 : wrapped

boxStartMinutes = localToEstMinutes(boxStartHour, boxStartMin)
boxEndMinutes   = localToEstMinutes(boxEndHour, boxEndMin)
waitEndMinutes  = localToEstMinutes(waitEndHour, waitEndMin)
sessionEndMinutes = localToEstMinutes(sessionEndHour, sessionEndMin)

inBoxWindow    = estTimeInMinutes >= boxStartMinutes and estTimeInMinutes < boxEndMinutes
inWaitWindow   = useWaitPeriod and estTimeInMinutes >= boxEndMinutes and estTimeInMinutes < waitEndMinutes
inActiveWindow = useWaitPeriod ? (estTimeInMinutes >= waitEndMinutes and estTimeInMinutes < sessionEndMinutes) : (estTimeInMinutes >= boxEndMinutes and estTimeInMinutes < sessionEndMinutes)

nowLocalMin = utcHourNow * 60 + utcMinNow + displayOffsetMin
nowLocalWrapped = nowLocalMin % 1440
nowLocalWrapped := nowLocalWrapped < 0 ? nowLocalWrapped + 1440 : nowLocalWrapped
nowDisplayTime = str.format("{0,number,00}:{1,number,00}", nowLocalWrapped / 60, nowLocalWrapped % 60)

// Box/Wait inputs are already entered in the user's local Timezone,
// so the dashboard can just format them directly — no conversion
// needed here (unlike nowDisplayTime, which derives from the live bar).
boxStartDisplay = str.format("{0,number,00}:{1,number,00}", boxStartHour, boxStartMin)
boxEndDisplay = str.format("{0,number,00}:{1,number,00}", boxEndHour, boxEndMin)
waitEndDisplay = str.format("{0,number,00}:{1,number,00}", waitEndHour, waitEndMin)
sessionEndDisplay = str.format("{0,number,00}:{1,number,00}", sessionEndHour, sessionEndMin)

// New trading day detection (EST calendar day), used to reset
// box/wait state each session.
estDateNow = year(time, "America/New_York") * 10000 + month(time, "America/New_York") * 100 + dayofmonth(time, "America/New_York")
var int estDatePrev = na
isNewEstDay = na(estDatePrev) or estDateNow != estDatePrev
estDatePrev := estDateNow

// On chart timeframes >= 1H the box high/low cannot be reliably
// isolated to the 8:00-8:15 window.
showTfWarning = timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds("60")

var label tfWarningLabel = na
if showTfWarning and barstate.islast and na(tfWarningLabel)
    tfWarningLabel := label.new(bar_index, high, "ORB Engine: chart timeframe too large for accurate box detection (use < 1H)", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white, size = size.small)
if showTfWarning and barstate.islast and not na(tfWarningLabel)
    label.set_xy(tfWarningLabel, bar_index, high)
if not showTfWarning and not na(tfWarningLabel)
    label.delete(tfWarningLabel)
    tfWarningLabel := na

// CLEANUP HELPERS — keep chart history bounded, prevent clutter
pruneLines(array<line> arr, int maxN) =>
    while array.size(arr) > maxN
        line.delete(array.shift(arr))

pruneLabels(array<label> arr, int maxN) =>
    while array.size(arr) > maxN
        label.delete(array.shift(arr))

pruneBoxes(array<box> arr, int maxN) =>
    while array.size(arr) > maxN
        box.delete(array.shift(arr))

extendLineHist(array<line> arr, int x2) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.set_x2(array.get(arr, i), x2)

extendLabelHist(array<label> arr, int x2) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.set_x(array.get(arr, i), x2)

relabelPrev(array<label> arr, string prevText) =>
    if array.size(arr) > 0
        label.set_text(array.get(arr, array.size(arr) - 1), prevText)

var float boxHigh = na
var float boxLow  = na
var float boxMid  = na
var bool  boxFormed = false
var int   boxStartBar = na
var int   boxEndBar = na
var array<box>   boxHistory = array.new<box>()
var array<line>  midLineHistory = array.new<line>()
var array<line>  boxHighLineHistory = array.new<line>()
var array<line>  boxLowLineHistory = array.new<line>()
var line  midLine = na
var line  boxHighLine = na
var line  boxLowLine = na

if isNewEstDay
    boxHigh := na
    boxLow := na
    boxMid := na
    boxFormed := false
    boxStartBar := na
    boxEndBar := na

if inBoxWindow
    if na(boxStartBar)
        boxStartBar := bar_index
    boxHigh := na(boxHigh) ? high : math.max(boxHigh, high)
    boxLow  := na(boxLow) ? low : math.min(boxLow, low)
    boxEndBar := bar_index

// Finalize box on the first bar after the box window closes
boxJustClosed = not inBoxWindow and not na(boxEndBar) and not boxFormed and (inWaitWindow or inActiveWindow)

if boxJustClosed
    boxMid := (boxHigh + boxLow) / 2
    boxFormed := true
    newBox = box.new(left = boxStartBar, top = boxHigh, right = boxEndBar, bottom = boxLow, border_color = boxColor, bgcolor = color.new(boxColor, boxTransp), extend = extend.none)
    midLine := line.new(x1 = boxStartBar, y1 = boxMid, x2 = boxEndBar, y2 = boxMid, color = boxColor, style = line.style_dotted, extend = extend.none)
    boxHighLine := line.new(x1 = boxStartBar, y1 = boxHigh, x2 = boxEndBar, y2 = boxHigh, color = boxColor, style = line.style_solid, width = 1)
    boxLowLine := line.new(x1 = boxStartBar, y1 = boxLow, x2 = boxEndBar, y2 = boxLow, color = boxColor, style = line.style_solid, width = 1)
    array.push(boxHistory, newBox)
    array.push(midLineHistory, midLine)
    array.push(boxHighLineHistory, boxHighLine)
    array.push(boxLowLineHistory, boxLowLine)
    pruneBoxes(boxHistory, maxBoxHistory)
    pruneLines(midLineHistory, maxBoxHistory)
    pruneLines(boxHighLineHistory, maxBoxHistory)
    pruneLines(boxLowLineHistory, maxBoxHistory)

// Extend the midline + high/low lines as new bars come in
if boxFormed and not na(midLine)
    line.set_xy2(midLine, bar_index, boxMid)
    extendLineHist(boxHighLineHistory, bar_index)
    extendLineHist(boxLowLineHistory, bar_index)

// breakout dots/triangles, and dashboard already communicate this
// state. Avoids the label clutter that stacks up across many days.
waitActive = boxFormed and inWaitWindow
// Entry-fired / expired state is set by Module 4 below (midpoint
// retest entry). Declared here so Module 2/3 logic and the status
// background can reference it consistently.
var bool entryFired = false

if isNewEstDay
    entryFired := false

volAvg = ta.sma(volume, volAvgLength)
volConfirmed = volume >= volAvg * volMultiplier

var string breakoutDir = na
var int breakoutBar = na

bullBreakoutRaw = boxFormed and not inBoxWindow and barstate.isconfirmed and na(breakoutDir) and close > boxHigh and volConfirmed
bearBreakoutRaw = boxFormed and not inBoxWindow and barstate.isconfirmed and na(breakoutDir) and close < boxLow and volConfirmed

if isNewEstDay
    breakoutDir := na
    breakoutBar := na

if bullBreakoutRaw
    breakoutDir := "BULL"
    breakoutBar := bar_index

if bearBreakoutRaw
    breakoutDir := "BEAR"
    breakoutBar := bar_index

bullBreakout = bullBreakoutRaw
bearBreakout = bearBreakoutRaw

plotshape(bullBreakout, "Bull Breakout", shape.circle, location.belowbar, color = color.new(C_BULL, 0), size = size.tiny)
plotshape(bearBreakout, "Bear Breakout", shape.circle, location.abovebar, color = color.new(C_BEAR, 0), size = size.tiny)
// direction, and stacking a label per breakout cluttered the chart.

atrVal = ta.atr(atrLength)

var string retestStatus = na  // "WAITING" / "FIRED" / "EXPIRED"
var float entryPrice = na
var float slPrice = na
var float riskDistance = na
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

if isNewEstDay
    retestStatus := na
    entryPrice := na
    slPrice := na
    riskDistance := na
    tp1Price := na
    tp2Price := na
    tp3Price := na
    // Clear yesterday's trade visualization — it should not linger
    // into a new session if no new entry has fired yet.
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    slLine := na
    tp1Line := na
    tp2Line := na
    tp3Line := na
    slLabel := na
    tp1Label := na
    tp2Label := na
    tp3Label := na

if bullBreakout or bearBreakout
    retestStatus := "WAITING"

// window isn't wasted while entries are still blocked.
var int activeWindowStartBar = na
if not useWaitPeriod
    activeWindowStartBar := na
else if inActiveWindow and not inActiveWindow[1]
    activeWindowStartBar := bar_index
if isNewEstDay
    activeWindowStartBar := na

timeoutRefBar = useWaitPeriod and not na(breakoutBar) and not na(activeWindowStartBar) and breakoutBar < activeWindowStartBar ? activeWindowStartBar : not useWaitPeriod ? breakoutBar : na
retestExpired = entryMode != "Immediate" and retestStatus == "WAITING" and not na(timeoutRefBar) and (bar_index - timeoutRefBar) > retestTimeoutBars

if retestExpired
    retestStatus := "EXPIRED"

// de eerste bar van de active window. Als breakout pas na 15:30 komt,
// vuur direct op de breakout-bar zelf.
immediateCondBull = entryMode == "Immediate" and breakoutDir == "BULL" and not na(breakoutBar) and (bullBreakout or (inActiveWindow and not inActiveWindow[1]))
immediateCondBear = entryMode == "Immediate" and breakoutDir == "BEAR" and not na(breakoutBar) and (bearBreakout or (inActiveWindow and not inActiveWindow[1]))

longRetestTrigger = inActiveWindow and breakoutDir == "BULL" and barstate.isconfirmed and (entryMode == "Immediate" ? immediateCondBull : retestStatus == "WAITING" and (entryMode == "Midpoint Retest" ? (bar_index > breakoutBar and low <= boxMid and close > boxMid) : entryMode == "Breakout Retest" ? (bar_index > breakoutBar and high >= boxHigh and low <= boxHigh and close > boxHigh) : false))
shortRetestTrigger = inActiveWindow and breakoutDir == "BEAR" and barstate.isconfirmed and (entryMode == "Immediate" ? immediateCondBear : retestStatus == "WAITING" and (entryMode == "Midpoint Retest" ? (bar_index > breakoutBar and high >= boxMid and close < boxMid) : entryMode == "Breakout Retest" ? (bar_index > breakoutBar and low <= boxLow and high >= boxLow and close < boxLow) : false))

if longRetestTrigger
    retestStatus := "FIRED"
    entryFired := true
    entryPrice := close
    slPrice := boxLow - atrVal * atrBufferMult
    riskDist = entryPrice - slPrice
    riskDistance := riskDist
    tp1Price := entryPrice + riskDist * 1
    tp2Price := entryPrice + riskDist * 2
    tp3Price := entryPrice + riskDist * 3

if shortRetestTrigger
    retestStatus := "FIRED"
    entryFired := true
    entryPrice := close
    slPrice := boxHigh + atrVal * atrBufferMult
    riskDist = slPrice - entryPrice
    riskDistance := riskDist
    tp1Price := entryPrice - riskDist * 1
    tp2Price := entryPrice - riskDist * 2
    tp3Price := entryPrice - riskDist * 3

plotshape(longRetestTrigger, "Long Entry", shape.triangleup, location.belowbar, color = color.new(C_BULL, 0), size = size.tiny)
plotshape(shortRetestTrigger, "Short Entry", shape.triangledown, location.abovebar, color = color.new(C_BEAR, 0), size = size.tiny)

if longRetestTrigger or shortRetestTrigger
    // Clear previous trade's SL/TP drawings before drawing the new one
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)
    entryBar = bar_index
    entryProjEnd = entryBar + projectBars
    slLine := line.new(entryBar, slPrice, entryProjEnd, slPrice, color = color.new(C_BEAR, 0), style = line.style_dashed)
    slLabel := label.new(entryProjEnd, slPrice, "SL", style = label.style_label_left, color = color.new(C_BEAR, 0), textcolor = color.white, size = size.small)
    if useRR1
        tp1Line := line.new(entryBar, tp1Price, entryProjEnd, tp1Price, color = color.new(C_BULL, 0), style = line.style_dashed)
        tp1Label := label.new(entryProjEnd, tp1Price, "TP1", style = label.style_label_left, color = color.new(C_BULL, 0), textcolor = color.black, size = size.small)
    if useRR2
        tp2Line := line.new(entryBar, tp2Price, entryProjEnd, tp2Price, color = color.new(C_BULL, 0), style = line.style_dashed)
        tp2Label := label.new(entryProjEnd, tp2Price, "TP2", style = label.style_label_left, color = color.new(C_BULL, 0), textcolor = color.black, size = size.small)
    if useRR3
        tp3Line := line.new(entryBar, tp3Price, entryProjEnd, tp3Price, color = color.new(C_BULL, 0), style = line.style_dashed)
        tp3Label := label.new(entryProjEnd, tp3Price, "TP3", style = label.style_label_left, color = color.new(C_BULL, 0), textcolor = color.black, size = size.small)

// TRADE CLOSE DETECTION — reset dashboard once SL or the final TP
// (TP3, or the highest enabled TP if TP3 is off) is hit. The chart
// lines stay as a visual record, but the dashboard shouldn't keep
// showing a SHORT/LONG entry and TP levels for a trade that's done.
finalTpPrice = useRR3 ? tp3Price : useRR2 ? tp2Price : useRR1 ? tp1Price : na

tradeClosed = false
if retestStatus == "FIRED" and not na(slPrice)
    if breakoutDir == "BULL"
        if low <= slPrice or (not na(finalTpPrice) and high >= finalTpPrice)
            tradeClosed := true
    if breakoutDir == "BEAR"
        if high >= slPrice or (not na(finalTpPrice) and low <= finalTpPrice)
            tradeClosed := true

if tradeClosed
    retestStatus := na
    entryFired := false
    entryPrice := na
    slPrice := na
    riskDistance := na
    tp1Price := na
    tp2Price := na
    tp3Price := na

// the exact candle where the session high/low was set (not at
// session close), extends lineExtendBars to the right, and updates
// every bar. A level becomes "tested" the first time price wicks
// through it after the session closes — the line fades (testedAlpha)
// rather than disappearing. History is capped to today (+ yesterday
// if showPrevDay is on); anything older is removed automatically.

liqTextSizeVal = textSize == "Tiny" ? size.tiny : size.small
vlineStyleVal = vlineStyle == "Dotted" ? line.style_dotted : line.style_solid
maxLiqKeep = showPrevDay ? 2 : 1

asiaStartMinutes = localToEstMinutes(asiaStartHour, asiaStartMin)
asiaEndMinutes   = localToEstMinutes(asiaEndHour, asiaEndMin)
inAsiaWindow = asiaStartMinutes > asiaEndMinutes ? (estTimeInMinutes >= asiaStartMinutes or estTimeInMinutes < asiaEndMinutes) : (estTimeInMinutes >= asiaStartMinutes and estTimeInMinutes < asiaEndMinutes)

var line asiaStartVLine = na
var line asiaEndVLine = na

var float asiaHi = na
var float asiaLo = na
var int   asiaHiBar = na
var int   asiaLoBar = na
var bool  asiaLocked = false
var bool  asiaHiTested = false
var bool  asiaLoTested = false
var line  asiaHiLine = na
var line  asiaLoLine = na
var label asiaHiLabel = na
var label asiaLoLabel = na
var array<line>  asiaHiLineHist = array.new<line>()
var array<line>  asiaLoLineHist = array.new<line>()
var array<label> asiaHiLabelHist = array.new<label>()
var array<label> asiaLoLabelHist = array.new<label>()
var line  asiaHiLiveLine = na
var line  asiaLoLiveLine = na
var label asiaHiLiveLabel = na
var label asiaLoLiveLabel = na

// would otherwise have its start line wiped by the midnight day
// relabels the still-displayed level to "P." (previous) immediately
// — it represents the last COMPLETED session, and a new one has now
if showAsia and showSessionVLines and inAsiaWindow and not inAsiaWindow[1]
    line.delete(asiaStartVLine)
    line.delete(asiaEndVLine)
    asiaStartVLine := line.new(bar_index, low, bar_index, high, extend = extend.both, color = asiaColor, style = vlineStyleVal, width = vlineWidth)

if showAsia and inAsiaWindow and not inAsiaWindow[1]
    relabelPrev(asiaHiLabelHist, "P.Asia.H")
    relabelPrev(asiaLoLabelHist, "P.Asia.L")
    // The live (dotted) line now represents "today" — so the locked
    // history array only needs to hold maxLiqKeep-1 PAST sessions.
    // Without this, an old entry lingers until the new one locks in,
    // and with Previous Day off it wouldn't disappear until then either.
    pruneLines(asiaHiLineHist, math.max(maxLiqKeep - 1, 0))
    pruneLines(asiaLoLineHist, math.max(maxLiqKeep - 1, 0))
    pruneLabels(asiaHiLabelHist, math.max(maxLiqKeep - 1, 0))
    pruneLabels(asiaLoLabelHist, math.max(maxLiqKeep - 1, 0))

if showAsia and showSessionVLines and not inAsiaWindow and inAsiaWindow[1]
    asiaEndVLine := line.new(bar_index, low, bar_index, high, extend = extend.both, color = asiaColor, style = vlineStyleVal, width = vlineWidth)

if not showSessionVLines and (not na(asiaStartVLine) or not na(asiaEndVLine))
    line.delete(asiaStartVLine)
    line.delete(asiaEndVLine)
    asiaStartVLine := na
    asiaEndVLine := na

if inAsiaWindow
    if asiaLocked
        asiaHi := na
        asiaLo := na
        asiaHiBar := na
        asiaLoBar := na
        asiaLocked := false
        asiaHiTested := false
        asiaLoTested := false
    if na(asiaHi) or high > asiaHi
        asiaHi := high
        asiaHiBar := bar_index
    if na(asiaLo) or low < asiaLo
        asiaLo := low
        asiaLoBar := bar_index

// a sweep mid-session is visible immediately instead of waiting for
// the session to close.
if showAsia and inAsiaWindow and not na(asiaHi)
    if na(asiaHiLiveLine)
        asiaHiLiveLine := line.new(asiaHiBar, asiaHi, bar_index, asiaHi, color = asiaColor, style = line.style_dotted, width = 1)
        asiaLoLiveLine := line.new(asiaLoBar, asiaLo, bar_index, asiaLo, color = asiaColor, style = line.style_dotted, width = 1)
        asiaHiLiveLabel := label.new(bar_index, asiaHi, "Asia.H", style = label.style_label_left, color = color.new(color.black, 100), textcolor = asiaColor, size = liqTextSizeVal)
        asiaLoLiveLabel := label.new(bar_index, asiaLo, "Asia.L", style = label.style_label_left, color = color.new(color.black, 100), textcolor = asiaColor, size = liqTextSizeVal)
    line.set_xy1(asiaHiLiveLine, asiaHiBar, asiaHi)
    line.set_xy2(asiaHiLiveLine, bar_index, asiaHi)
    line.set_xy1(asiaLoLiveLine, asiaLoBar, asiaLo)
    line.set_xy2(asiaLoLiveLine, bar_index, asiaLo)
    label.set_x(asiaHiLiveLabel, bar_index)
    label.set_y(asiaHiLiveLabel, asiaHi)
    label.set_x(asiaLoLiveLabel, bar_index)
    label.set_y(asiaLoLiveLabel, asiaLo)

if showAsia and not inAsiaWindow and not na(asiaHiLiveLine)
    line.delete(asiaHiLiveLine)
    line.delete(asiaLoLiveLine)
    label.delete(asiaHiLiveLabel)
    label.delete(asiaLoLiveLabel)
    asiaHiLiveLine := na
    asiaLoLiveLine := na

if showAsia and not inAsiaWindow and not asiaLocked and not na(asiaHi)
    asiaLocked := true
    asiaHiLine := line.new(asiaHiBar, asiaHi, bar_index + lineExtendBars, asiaHi, color = asiaColor, style = line.style_solid, width = 1)
    asiaLoLine := line.new(asiaLoBar, asiaLo, bar_index + lineExtendBars, asiaLo, color = asiaColor, style = line.style_solid, width = 1)
    asiaHiLabel := label.new(bar_index + lineExtendBars, asiaHi, "Asia.H", style = label.style_label_left, color = color.new(color.black, 100), textcolor = asiaColor, size = liqTextSizeVal)
    asiaLoLabel := label.new(bar_index + lineExtendBars, asiaLo, "Asia.L", style = label.style_label_left, color = color.new(color.black, 100), textcolor = asiaColor, size = liqTextSizeVal)
    array.push(asiaHiLineHist, asiaHiLine)
    array.push(asiaLoLineHist, asiaLoLine)
    array.push(asiaHiLabelHist, asiaHiLabel)
    array.push(asiaLoLabelHist, asiaLoLabel)
    pruneLines(asiaHiLineHist, maxLiqKeep)
    pruneLines(asiaLoLineHist, maxLiqKeep)
    pruneLabels(asiaHiLabelHist, maxLiqKeep)
    pruneLabels(asiaLoLabelHist, maxLiqKeep)

if asiaLocked and not asiaHiTested and high >= asiaHi
    asiaHiTested := true
    line.set_color(asiaHiLine, color.new(asiaColor, testedAlpha))
    label.set_textcolor(asiaHiLabel, color.new(asiaColor, testedAlpha))

if asiaLocked and not asiaLoTested and low <= asiaLo
    asiaLoTested := true
    line.set_color(asiaLoLine, color.new(asiaColor, testedAlpha))
    label.set_textcolor(asiaLoLabel, color.new(asiaColor, testedAlpha))

// Extend every kept Asia line/label (today + previous day if shown)
// to the current bar, not just the most recent one.
if showAsia
    extendLineHist(asiaHiLineHist, bar_index + lineExtendBars)
    extendLineHist(asiaLoLineHist, bar_index + lineExtendBars)
    extendLabelHist(asiaHiLabelHist, bar_index + lineExtendBars)
    extendLabelHist(asiaLoLabelHist, bar_index + lineExtendBars)

if not showAsia and array.size(asiaHiLineHist) > 0
    pruneLines(asiaHiLineHist, 0)
    pruneLines(asiaLoLineHist, 0)
    pruneLabels(asiaHiLabelHist, 0)
    pruneLabels(asiaLoLabelHist, 0)
    asiaHiLine := na
    asiaLoLine := na

londonStartMinutes = localToEstMinutes(londonStartHour, londonStartMin)
londonEndMinutes   = localToEstMinutes(londonEndHour, londonEndMin)
inLondonWindow = londonStartMinutes > londonEndMinutes ? (estTimeInMinutes >= londonStartMinutes or estTimeInMinutes < londonEndMinutes) : (estTimeInMinutes >= londonStartMinutes and estTimeInMinutes < londonEndMinutes)

var line londonStartVLine = na
var line londonEndVLine = na

var float londonHi = na
var float londonLo = na
var int   londonHiBar = na
var int   londonLoBar = na
var bool  londonLocked = false
var bool  londonHiTested = false
var bool  londonLoTested = false
var line  londonHiLine = na
var line  londonLoLine = na
var label londonHiLabel = na
var label londonLoLabel = na
var array<line>  londonHiLineHist = array.new<line>()
var array<line>  londonLoLineHist = array.new<line>()
var array<label> londonHiLabelHist = array.new<label>()
var array<label> londonLoLabelHist = array.new<label>()
var line  londonHiLiveLine = na
var line  londonLoLiveLine = na
var label londonHiLiveLabel = na
var label londonLoLiveLabel = na

if showLondon and showSessionVLines and inLondonWindow and not inLondonWindow[1]
    line.delete(londonStartVLine)
    line.delete(londonEndVLine)
    londonStartVLine := line.new(bar_index, low, bar_index, high, extend = extend.both, color = londonColor, style = vlineStyleVal, width = vlineWidth)

if showLondon and inLondonWindow and not inLondonWindow[1]
    relabelPrev(londonHiLabelHist, "P.London.H")
    relabelPrev(londonLoLabelHist, "P.London.L")
    pruneLines(londonHiLineHist, math.max(maxLiqKeep - 1, 0))
    pruneLines(londonLoLineHist, math.max(maxLiqKeep - 1, 0))
    pruneLabels(londonHiLabelHist, math.max(maxLiqKeep - 1, 0))
    pruneLabels(londonLoLabelHist, math.max(maxLiqKeep - 1, 0))

if showLondon and showSessionVLines and not inLondonWindow and inLondonWindow[1]
    londonEndVLine := line.new(bar_index, low, bar_index, high, extend = extend.both, color = londonColor, style = vlineStyleVal, width = vlineWidth)

if not showSessionVLines and (not na(londonStartVLine) or not na(londonEndVLine))
    line.delete(londonStartVLine)
    line.delete(londonEndVLine)
    londonStartVLine := na
    londonEndVLine := na

if inLondonWindow
    if londonLocked
        londonHi := na
        londonLo := na
        londonHiBar := na
        londonLoBar := na
        londonLocked := false
        londonHiTested := false
        londonLoTested := false
    if na(londonHi) or high > londonHi
        londonHi := high
        londonHiBar := bar_index
    if na(londonLo) or low < londonLo
        londonLo := low
        londonLoBar := bar_index

if showLondon and inLondonWindow and not na(londonHi)
    if na(londonHiLiveLine)
        londonHiLiveLine := line.new(londonHiBar, londonHi, bar_index, londonHi, color = londonColor, style = line.style_dotted, width = 1)
        londonLoLiveLine := line.new(londonLoBar, londonLo, bar_index, londonLo, color = londonColor, style = line.style_dotted, width = 1)
        londonHiLiveLabel := label.new(bar_index, londonHi, "London.H", style = label.style_label_left, color = color.new(color.black, 100), textcolor = londonColor, size = liqTextSizeVal)
        londonLoLiveLabel := label.new(bar_index, londonLo, "London.L", style = label.style_label_left, color = color.new(color.black, 100), textcolor = londonColor, size = liqTextSizeVal)
    line.set_xy1(londonHiLiveLine, londonHiBar, londonHi)
    line.set_xy2(londonHiLiveLine, bar_index, londonHi)
    line.set_xy1(londonLoLiveLine, londonLoBar, londonLo)
    line.set_xy2(londonLoLiveLine, bar_index, londonLo)
    label.set_x(londonHiLiveLabel, bar_index)
    label.set_y(londonHiLiveLabel, londonHi)
    label.set_x(londonLoLiveLabel, bar_index)
    label.set_y(londonLoLiveLabel, londonLo)

if showLondon and not inLondonWindow and not na(londonHiLiveLine)
    line.delete(londonHiLiveLine)
    line.delete(londonLoLiveLine)
    label.delete(londonHiLiveLabel)
    label.delete(londonLoLiveLabel)
    londonHiLiveLine := na
    londonLoLiveLine := na

if showLondon and not inLondonWindow and not londonLocked and not na(londonHi)
    londonLocked := true
    londonHiLine := line.new(londonHiBar, londonHi, bar_index + lineExtendBars, londonHi, color = londonColor, style = line.style_solid, width = 1)
    londonLoLine := line.new(londonLoBar, londonLo, bar_index + lineExtendBars, londonLo, color = londonColor, style = line.style_solid, width = 1)
    londonHiLabel := label.new(bar_index + lineExtendBars, londonHi, "London.H", style = label.style_label_left, color = color.new(color.black, 100), textcolor = londonColor, size = liqTextSizeVal)
    londonLoLabel := label.new(bar_index + lineExtendBars, londonLo, "London.L", style = label.style_label_left, color = color.new(color.black, 100), textcolor = londonColor, size = liqTextSizeVal)
    array.push(londonHiLineHist, londonHiLine)
    array.push(londonLoLineHist, londonLoLine)
    array.push(londonHiLabelHist, londonHiLabel)
    array.push(londonLoLabelHist, londonLoLabel)
    pruneLines(londonHiLineHist, maxLiqKeep)
    pruneLines(londonLoLineHist, maxLiqKeep)
    pruneLabels(londonHiLabelHist, maxLiqKeep)
    pruneLabels(londonLoLabelHist, maxLiqKeep)

if londonLocked and not londonHiTested and high >= londonHi
    londonHiTested := true
    line.set_color(londonHiLine, color.new(londonColor, testedAlpha))
    label.set_textcolor(londonHiLabel, color.new(londonColor, testedAlpha))

if londonLocked and not londonLoTested and low <= londonLo
    londonLoTested := true
    line.set_color(londonLoLine, color.new(londonColor, testedAlpha))
    label.set_textcolor(londonLoLabel, color.new(londonColor, testedAlpha))

if showLondon
    extendLineHist(londonHiLineHist, bar_index + lineExtendBars)
    extendLineHist(londonLoLineHist, bar_index + lineExtendBars)
    extendLabelHist(londonHiLabelHist, bar_index + lineExtendBars)
    extendLabelHist(londonLoLabelHist, bar_index + lineExtendBars)

if not showLondon and array.size(londonHiLineHist) > 0
    pruneLines(londonHiLineHist, 0)
    pruneLines(londonLoLineHist, 0)
    pruneLabels(londonHiLabelHist, 0)
    pruneLabels(londonLoLabelHist, 0)
    londonHiLine := na
    londonLoLine := na

// --- NY session (previous session's range — today's NY session is the
// active trading window for this indicator itself, so the displayed
// level is always the most recently completed NY session) ---
nyStartMinutes = localToEstMinutes(nyStartHour, nyStartMin)
nyEndMinutes   = localToEstMinutes(nyEndHour, nyEndMin)
inNyWindow = nyStartMinutes > nyEndMinutes ? (estTimeInMinutes >= nyStartMinutes or estTimeInMinutes < nyEndMinutes) : (estTimeInMinutes >= nyStartMinutes and estTimeInMinutes < nyEndMinutes)

var line nyStartVLine = na
var line nyEndVLine = na

var float nyHi = na
var float nyLo = na
var int   nyHiBar = na
var int   nyLoBar = na
var bool  nyLocked = false
var bool  nyHiTested = false
var bool  nyLoTested = false
var line  nyHiLine = na
var line  nyLoLine = na
var label nyHiLabel = na
var label nyLoLabel = na
var array<line>  nyHiLineHist = array.new<line>()
var array<line>  nyLoLineHist = array.new<line>()
var array<label> nyHiLabelHist = array.new<label>()
var array<label> nyLoLabelHist = array.new<label>()
var line  nyHiLiveLine = na
var line  nyLoLiveLine = na
var label nyHiLiveLabel = na
var label nyLoLiveLabel = na

if showNY and showSessionVLines and inNyWindow and not inNyWindow[1]
    line.delete(nyStartVLine)
    line.delete(nyEndVLine)
    nyStartVLine := line.new(bar_index, low, bar_index, high, extend = extend.both, color = nyColor, style = vlineStyleVal, width = vlineWidth)

if showNY and inNyWindow and not inNyWindow[1]
    relabelPrev(nyHiLabelHist, "P.NY.H")
    relabelPrev(nyLoLabelHist, "P.NY.L")
    pruneLines(nyHiLineHist, math.max(maxLiqKeep - 1, 0))
    pruneLines(nyLoLineHist, math.max(maxLiqKeep - 1, 0))
    pruneLabels(nyHiLabelHist, math.max(maxLiqKeep - 1, 0))
    pruneLabels(nyLoLabelHist, math.max(maxLiqKeep - 1, 0))

if showNY and showSessionVLines and not inNyWindow and inNyWindow[1]
    nyEndVLine := line.new(bar_index, low, bar_index, high, extend = extend.both, color = nyColor, style = vlineStyleVal, width = vlineWidth)

if not showSessionVLines and (not na(nyStartVLine) or not na(nyEndVLine))
    line.delete(nyStartVLine)
    line.delete(nyEndVLine)
    nyStartVLine := na
    nyEndVLine := na

if inNyWindow
    if nyLocked
        nyHi := na
        nyLo := na
        nyHiBar := na
        nyLoBar := na
        nyLocked := false
        nyHiTested := false
        nyLoTested := false
    if na(nyHi) or high > nyHi
        nyHi := high
        nyHiBar := bar_index
    if na(nyLo) or low < nyLo
        nyLo := low
        nyLoBar := bar_index

if showNY and inNyWindow and not na(nyHi)
    if na(nyHiLiveLine)
        nyHiLiveLine := line.new(nyHiBar, nyHi, bar_index, nyHi, color = nyColor, style = line.style_dotted, width = 1)
        nyLoLiveLine := line.new(nyLoBar, nyLo, bar_index, nyLo, color = nyColor, style = line.style_dotted, width = 1)
        nyHiLiveLabel := label.new(bar_index, nyHi, "NY.H", style = label.style_label_left, color = color.new(color.black, 100), textcolor = nyColor, size = liqTextSizeVal)
        nyLoLiveLabel := label.new(bar_index, nyLo, "NY.L", style = label.style_label_left, color = color.new(color.black, 100), textcolor = nyColor, size = liqTextSizeVal)
    line.set_xy1(nyHiLiveLine, nyHiBar, nyHi)
    line.set_xy2(nyHiLiveLine, bar_index, nyHi)
    line.set_xy1(nyLoLiveLine, nyLoBar, nyLo)
    line.set_xy2(nyLoLiveLine, bar_index, nyLo)
    label.set_x(nyHiLiveLabel, bar_index)
    label.set_y(nyHiLiveLabel, nyHi)
    label.set_x(nyLoLiveLabel, bar_index)
    label.set_y(nyLoLiveLabel, nyLo)

if showNY and not inNyWindow and not na(nyHiLiveLine)
    line.delete(nyHiLiveLine)
    line.delete(nyLoLiveLine)
    label.delete(nyHiLiveLabel)
    label.delete(nyLoLiveLabel)
    nyHiLiveLine := na
    nyLoLiveLine := na

if showNY and not inNyWindow and not nyLocked and not na(nyHi)
    nyLocked := true
    nyHiLine := line.new(nyHiBar, nyHi, bar_index + lineExtendBars, nyHi, color = nyColor, style = line.style_solid, width = 1)
    nyLoLine := line.new(nyLoBar, nyLo, bar_index + lineExtendBars, nyLo, color = nyColor, style = line.style_solid, width = 1)
    nyHiLabel := label.new(bar_index + lineExtendBars, nyHi, "NY.H", style = label.style_label_left, color = color.new(color.black, 100), textcolor = nyColor, size = liqTextSizeVal)
    nyLoLabel := label.new(bar_index + lineExtendBars, nyLo, "NY.L", style = label.style_label_left, color = color.new(color.black, 100), textcolor = nyColor, size = liqTextSizeVal)
    array.push(nyHiLineHist, nyHiLine)
    array.push(nyLoLineHist, nyLoLine)
    array.push(nyHiLabelHist, nyHiLabel)
    array.push(nyLoLabelHist, nyLoLabel)
    pruneLines(nyHiLineHist, maxLiqKeep)
    pruneLines(nyLoLineHist, maxLiqKeep)
    pruneLabels(nyHiLabelHist, maxLiqKeep)
    pruneLabels(nyLoLabelHist, maxLiqKeep)

if nyLocked and not nyHiTested and high >= nyHi
    nyHiTested := true
    line.set_color(nyHiLine, color.new(nyColor, testedAlpha))
    label.set_textcolor(nyHiLabel, color.new(nyColor, testedAlpha))

if nyLocked and not nyLoTested and low <= nyLo
    nyLoTested := true
    line.set_color(nyLoLine, color.new(nyColor, testedAlpha))
    label.set_textcolor(nyLoLabel, color.new(nyColor, testedAlpha))

if showNY
    extendLineHist(nyHiLineHist, bar_index + lineExtendBars)
    extendLineHist(nyLoLineHist, bar_index + lineExtendBars)
    extendLabelHist(nyHiLabelHist, bar_index + lineExtendBars)
    extendLabelHist(nyLoLabelHist, bar_index + lineExtendBars)

if not showNY and array.size(nyHiLineHist) > 0
    pruneLines(nyHiLineHist, 0)
    pruneLines(nyLoLineHist, 0)
    pruneLabels(nyHiLabelHist, 0)
    pruneLabels(nyLoLabelHist, 0)
    nyHiLine := na
    nyLoLine := na

untestedCount = (showAsia and asiaLocked and not asiaHiTested ? 1 : 0) + (showAsia and asiaLocked and not asiaLoTested ? 1 : 0) + (showLondon and londonLocked and not londonHiTested ? 1 : 0) + (showLondon and londonLocked and not londonLoTested ? 1 : 0) + (showNY and nyLocked and not nyHiTested ? 1 : 0) + (showNY and nyLocked and not nyLoTested ? 1 : 0)

// Proximity alert conditions for untested levels
nearAsiaHi = liqProximityAlert and showAsia and asiaLocked and not asiaHiTested and math.abs(close - asiaHi) <= atrVal * liqProximityATR
nearAsiaLo = liqProximityAlert and showAsia and asiaLocked and not asiaLoTested and math.abs(close - asiaLo) <= atrVal * liqProximityATR
nearLondonHi = liqProximityAlert and showLondon and londonLocked and not londonHiTested and math.abs(close - londonHi) <= atrVal * liqProximityATR
nearLondonLo = liqProximityAlert and showLondon and londonLocked and not londonLoTested and math.abs(close - londonLo) <= atrVal * liqProximityATR
nearNyHi = liqProximityAlert and showNY and nyLocked and not nyHiTested and math.abs(close - nyHi) <= atrVal * liqProximityATR
nearNyLo = liqProximityAlert and showNY and nyLocked and not nyLoTested and math.abs(close - nyLo) <= atrVal * liqProximityATR

alertcondition(nearAsiaHi or nearAsiaLo or nearLondonHi or nearLondonLo or nearNyHi or nearNyLo, title = "Near Untested Liquidity Level", message = "ORB Engine: price approaching an untested session liquidity level.")
alertcondition(bullBreakout, title = "Bull Breakout", message = "ORB Engine: confirmed bull breakout above the opening range box.")
alertcondition(bearBreakout, title = "Bear Breakout", message = "ORB Engine: confirmed bear breakout below the opening range box.")
alertcondition(longRetestTrigger, title = "Long Entry Signal", message = "ORB Engine: long entry triggered — retest confirmed, price reclaimed the entry level.")
alertcondition(shortRetestTrigger, title = "Short Entry Signal", message = "ORB Engine: short entry triggered — retest confirmed, price reclaimed the entry level.")
alertcondition(tradeClosed and breakoutDir == "BULL" and not na(slPrice) and low <= slPrice, title = "Long Stop Loss Hit", message = "ORB Engine: long trade stopped out — price hit the stop loss level.")
alertcondition(tradeClosed and breakoutDir == "BEAR" and not na(slPrice) and high >= slPrice, title = "Short Stop Loss Hit", message = "ORB Engine: short trade stopped out — price hit the stop loss level.")
alertcondition(tradeClosed and not na(finalTpPrice) and breakoutDir == "BULL" and high >= finalTpPrice, title = "Long Final TP Hit", message = "ORB Engine: long trade reached the final take profit target.")
alertcondition(tradeClosed and not na(finalTpPrice) and breakoutDir == "BEAR" and low <= finalTpPrice, title = "Short Final TP Hit", message = "ORB Engine: short trade reached the final take profit target.")

score1_boxFormed = boxFormed
score2_volConfirmed = not na(breakoutDir)
liqBiasBull = breakoutDir == "BULL" and ((showAsia and asiaLocked and not asiaHiTested and asiaHi > close) or (showLondon and londonLocked and not londonHiTested and londonHi > close) or (showNY and nyLocked and not nyHiTested and nyHi > close))
liqBiasBear = breakoutDir == "BEAR" and ((showAsia and asiaLocked and not asiaLoTested and asiaLo < close) or (showLondon and londonLocked and not londonLoTested and londonLo < close) or (showNY and nyLocked and not nyLoTested and nyLo < close))
score3_liqBias = liqBiasBull or liqBiasBear
score4_retestInTime = retestStatus == "FIRED"
score5_rrViable = not na(riskDistance) and boxFormed and riskDistance <= (boxHigh - boxLow) * riskSanityMult

confluenceScore = (score1_boxFormed ? 1 : 0) + (score2_volConfirmed ? 1 : 0) + (score3_liqBias ? 1 : 0) + (score4_retestInTime ? 1 : 0) + (score5_rrViable ? 1 : 0)

scoreBarString(n) =>
    string s = ""
    for i = 0 to 4
        s := s + (i < n ? "▰" : "▱")
    s

var table dash = table.new(dashPosition == "Top Left" ? position.top_left : dashPosition == "Top Right" ? position.top_right : dashPosition == "Bottom Left" ? position.bottom_left : position.bottom_right, 2, 14, bgcolor = color.new(C_BG, 10), border_color = color.new(C_BORDER, 20), border_width = 1, frame_color = color.new(C_BORDER, 40), frame_width = 1)

dashSize = dashTextSize == "Tiny" ? size.tiny : dashTextSize == "Normal" ? size.normal : size.small

boxStatusText = boxFormed ? "FORMED" : inBoxWindow ? "FORMING" : "—"
boxRangeText = boxFormed ? str.tostring(boxHigh - boxLow, format.mintick) : "—"
waitMinutesLeft = waitActive ? waitEndMinutes - estTimeInMinutes : 0
waitStatusText = not useWaitPeriod ? "DISABLED" : waitActive ? "WAITING (" + str.tostring(waitMinutesLeft) + "m)" : inActiveWindow ? "ACTIVE" : "—"
breakoutStatusText = breakoutDir == "BULL" ? "BULL" : breakoutDir == "BEAR" ? "BEAR" : "NONE"
retestStatusText = na(retestStatus) ? "—" : retestStatus
entryStatusText = retestStatus == "FIRED" ? (breakoutDir == "BULL" ? "LONG" : "SHORT") : "—"
sessionText = inAsiaWindow ? "ASIA" : inLondonWindow ? "LONDON" : inNyWindow ? "NY" : "—"

cPanel = color.new(C_PANEL, 0)
cMuted = color.new(C_MUTED, 0)
cWhite = color.new(color.white, 0)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "ORB Engine", bgcolor = color.new(C_PURP, 70), text_color = color.new(C_GOLD, 0), text_size = dashSize)
    table.cell(dash, 1, 0, "v1.0", bgcolor = color.new(C_PURP, 70), text_color = color.new(C_GOLD, 0), text_size = dashSize)

    table.cell(dash, 0, 1, "Box Status", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 1, boxStatusText, bgcolor = cPanel, text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 2, "Box Range", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 2, boxRangeText, bgcolor = cPanel, text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 3, "Wait Status", bgcolor = waitActive ? color.new(C_MUTED, 70) : cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 3, waitStatusText, bgcolor = waitActive ? color.new(C_MUTED, 70) : cPanel, text_color = waitActive ? cMuted : cWhite, text_size = dashSize)

    table.cell(dash, 0, 4, "Breakout", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 4, breakoutStatusText, bgcolor = cPanel, text_color = breakoutDir == "BULL" ? color.new(C_BULL, 0) : breakoutDir == "BEAR" ? color.new(C_BEAR, 0) : cWhite, text_size = dashSize)

    table.cell(dash, 0, 5, "Entry Mode", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 5, entryMode, bgcolor = cPanel, text_color = color.new(C_CYAN, 0), text_size = dashSize)

    retestRowLabel = entryMode == "Immediate" ? "Entry Trigger" : entryMode == "Breakout Retest" ? "Breakout Retest" : "Midpoint Retest"
    table.cell(dash, 0, 6, retestRowLabel, bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 6, retestStatusText, bgcolor = cPanel, text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 7, "Entry", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 7, entryStatusText, bgcolor = cPanel, text_color = entryStatusText == "LONG" ? color.new(C_BULL, 0) : entryStatusText == "SHORT" ? color.new(C_BEAR, 0) : cWhite, text_size = dashSize)

    table.cell(dash, 0, 8, "Confluence Score", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 8, scoreBarString(confluenceScore) + "  " + str.tostring(confluenceScore) + "/5", bgcolor = cPanel, text_color = color.new(C_GOLD, 0), text_size = dashSize)

    tpStatusText = na(tp1Price) ? "—" : (useRR1 ? "1:1 " + str.tostring(tp1Price, format.mintick) : "") + (useRR2 ? "  1:2 " + str.tostring(tp2Price, format.mintick) : "") + (useRR3 ? "  1:3 " + str.tostring(tp3Price, format.mintick) : "")
    table.cell(dash, 0, 9, "TP Levels", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 9, tpStatusText, bgcolor = cPanel, text_color = color.new(C_BULL, 0), text_size = dashSize)

    table.cell(dash, 0, 10, "Session / Untested", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 10, sessionText + "  (" + str.tostring(untestedCount) + ")", bgcolor = cPanel, text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 11, "Now (" + displayTimezone + ")", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 11, nowDisplayTime, bgcolor = cPanel, text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 12, "Box / Active", bgcolor = cPanel, text_color = cMuted, text_size = dashSize)
    table.cell(dash, 1, 12, boxStartDisplay + "-" + boxEndDisplay + "  →  " + waitEndDisplay, bgcolor = cPanel, text_color = cWhite, text_size = dashSize)

    table.cell(dash, 0, 13, "ANONYCRYPTOUS", bgcolor = color.new(C_PURP, 70), text_color = color.new(C_GOLD, 0), text_size = dashSize, text_halign = text.align_center)
    table.cell(dash, 1, 13, "", bgcolor = color.new(C_PURP, 70))
    table.merge_cells(dash, 0, 13, 1, 13)

// STATUS BACKGROUND (chart-first visual state)
bgcolor(showEntryBg and entryFired ? color.new(entryBgColor, entryBgTransp) : showWaitBg and waitActive ? color.new(waitBgColor, waitBgTransp) : na)
````
