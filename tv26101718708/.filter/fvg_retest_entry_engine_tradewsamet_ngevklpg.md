# FVG Retest Entry Engine [trade_w_samet]

- url: https://www.tradingview.com/script/nGEVkLPG-FVG-Retest-Entry-Engine-trade-w-samet/
- type: indicator
- pine_id: PUB;dafbf052589b4e4eb0207c9e318eaa70
- version: 1.0

## Description

🎯 FVG Retest Entry Engine [trade_w_samet]

FVG Retest Entry Engine [trade_w_samet] is a structured Fair Value Gap retest analysis indicator designed to help traders study confirmed gap reactions, structure alignment, filtered entry conditions, and multi-target visual trade models directly on the price chart.

This script focuses on one main concept:

FVG retest-based entry visualization.

It is not designed to be a simple buy/sell signal generator.

It is not designed to show every possible Fair Value Gap.

It is not designed to create constant chart noise.

Instead, the goal of FVG Retest Entry Engine is to detect confirmed structure events, identify eligible Fair Value Gaps, monitor their retests, apply configurable quality checkpoints, and visualize accepted setups using one entry level, one protective stop, and three take-profit levels.

The indicator includes:

• Bullish and bearish market-structure detection
• BOS and CHoCH classification
• Three-candle Fair Value Gap detection
• Internal FVG memory and invalidation handling
• Structure-linked FVG candidate selection
• FVG quality scoring and setup grading
• Armed-zone retest monitoring
• Multiple retest confirmation models
• Volume, Directional Force, and confirmed HTF bias filters
• FVG Retest Passport
• Blocker Lens state reporting
• Confirmed-close signal commitment
• Optional Live Preview dashboard state
• Gap-protected and ATR-based stop-loss models
• TP1, TP2, and TP3 risk-multiple projections
• Optional breakeven movement after TP1
• Active and historical TP / SL areas
• Executed FVG retest zones
• One-active-trade-at-a-time logic
• Mobile chart layout
• Multiple visual themes
• Advanced entry and lifecycle alerts
• JSON webhook support
• Compact bottom-right dashboard

The purpose of this script is to help users visually study where a structure event and an eligible Fair Value Gap combine with a confirmed retest condition.

It should be treated as a chart-analysis and educational decision-support tool.

It is not financial advice.
It is not an automated trading system.
It does not guarantee profitable trades.
It does not execute broker orders.
It does not replace personal analysis, risk management, or trade validation.

https://www.tradingview.com/x/GFAiru7w/

━━━━━━━━━━━━━━━━━━━━━━
📌 OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━

At a high level, FVG Retest Entry Engine does the following:

• Detects confirmed bullish and bearish structure breaks.
• Classifies structure events as BOS or CHoCH.
• Detects bullish and bearish three-candle Fair Value Gaps.
• Stores valid FVG zones in internal memory.
• Tracks zone direction, boundaries, age, displacement, volume context, and prior interactions.
• Searches for an eligible FVG after a matching structure event.
• Scores and ranks available FVG candidates.
• Arms the best available zone for retest monitoring.
• Waits for the selected minimum retest delay.
• Detects the selected FVG retest pattern.
• Evaluates reaction quality and optional confluence filters.
• Assigns a setup grade such as A+, A, B, or FILTERED.
• Confirms final entry conditions only when the chart candle closes.
• Draws one Entry, one SL, and three TP levels.
• Tracks TP1, TP2, TP3, stop-loss, and breakeven events.
• Allows only one active trade projection at a time.
• Keeps completed trade areas when historical display is enabled.
• Marks completed models as bullish or bearish FVG Retest outcomes.
• Displays the current bias, engine state, and active levels in the dashboard.
• Provides entry, armed-zone, target, stop, breakeven, and webhook alert options.

The script is intentionally built as a structured process.

It does not include machine-learning prediction.

It does not include guaranteed performance claims.

It does not attempt to forecast every future market movement.

It provides a transparent way to study structure-linked FVG retests and their projected trade lifecycle.

━━━━━━━━━━━━━━━━━━━━━━
🧠 CORE IDEA
━━━━━━━━━━━━━━━━━━━━━━

The core idea behind FVG Retest Entry Engine is based on the relationship between market structure and Fair Value Gap reactions.

A Fair Value Gap represents a three-candle price imbalance.

A bullish FVG is formed when the current candle’s low is above the high from two candles earlier.

A bearish FVG is formed when the current candle’s high is below the low from two candles earlier.

The script does not treat every FVG as an entry.

Instead, it waits for a confirmed structure event and then searches for an eligible FVG that matches that directional context.

The selected FVG becomes an armed zone.

Price must later return to that zone and satisfy the chosen retest condition.

The engine can then evaluate:

• gap size relative to ATR
• formation displacement
• formation volume context
• FVG age
• prior zone interactions
• structure-break quality
• retest depth
• reaction-candle quality
• volume participation
• DI / ADX directional force
• confirmed higher-timeframe bias
• minimum setup grade

The goal is not to show more signals.

The goal is to create a documented and understandable process from structure event to confirmed FVG retest model.

━━━━━━━━━━━━━━━━━━━━━━
🧩 WHY THIS SCRIPT IS NOT A SIMPLE BUY/SELL INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

FVG Retest Entry Engine is not intended to be used as a blind buy/sell system.

The script is structured as a visual review workflow:

Structure event is confirmed
→ matching FVG candidates are reviewed
→ one eligible FVG is selected
→ the FVG becomes armed
→ price returns to the armed zone
→ the retest pattern is checked
→ reaction quality is evaluated
→ enabled filters are checked
→ the setup receives a grade
→ the candle must close with all conditions still valid
→ Entry, SL, TP1, TP2, and TP3 are projected
→ the active model is monitored
→ the model closes at TP3, stop loss, targets complete, or breakeven
→ the completed FVG Retest model is archived visually

Each part has a specific purpose.

The structure system identifies a directional event.
The FVG memory system stores imbalance zones.
The candidate-ranking system selects a relevant gap instead of using every gap.
The armed-zone system separates observation from entry.
The retest logic defines what qualifies as a valid return.
The quality checkpoints reduce setups that fail enabled conditions.
The grading system summarizes internal setup quality.
The entry model provides visual planning levels.
The stop model creates a consistent risk reference.
The three-target model provides staged reward references.
The Blocker Lens explains the current engine state.
The Passport explains why an accepted setup qualified.
The alert system supports monitoring of confirmed events.

This makes the script a structured FVG retest analysis tool, not a guaranteed trade signal generator.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE SCRIPT WORKS
━━━━━━━━━━━━━━━━━━━━━━

The script operates through several connected stages.

First, it identifies confirmed swing highs and swing lows.

Price breaking a confirmed swing level can create a bullish or bearish structure event.

The break may be classified as BOS when it continues the current structure bias or CHoCH when it changes that bias.

The engine separately detects three-candle Fair Value Gaps and stores their contextual information.

[pine]
bool tws_bullish_fvg = bar_index >= 2 and low > high[2]
bool tws_bearish_fvg = bar_index >= 2 and high < low[2]

float tws_bullish_fvg_top = low
float tws_bullish_fvg_bottom = high[2]
float tws_bearish_fvg_top = low[2]
float tws_bearish_fvg_bottom = high

float tws_bullish_fvg_size = tws_bullish_fvg_top - tws_bullish_fvg_bottom
float tws_bearish_fvg_size = tws_bearish_fvg_top - tws_bearish_fvg_bottom
[/pine]

When a structure event occurs, the engine reviews matching FVG candidates within the selected distance and timing limits.

The available candidates are compared using the active profile’s rules.

The selected zone becomes armed and remains under observation until:

• a confirmed retest creates an entry
• the setup expires
• the FVG is invalidated
• another structure search replaces it

Once price interacts with the armed zone, the selected retest model and reaction-quality conditions are checked.

Volume, DI / ADX, and higher-timeframe bias can also be required.

Only a setup that passes the active rules and remains valid at candle close can create a permanent entry model.

━━━━━━━━━━━━━━━━━━━━━━
🔵 BULLISH FVG RETEST LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bullish FVG Retest setup begins with bullish structure context.

The script requires a confirmed bullish BOS or CHoCH event and then searches for a directionally matching FVG candidate.

The selected zone must remain valid while the engine waits for price to return.

Depending on the chosen profile and retest model, bullish confirmation may require:

• wick contact with the zone
• real-body contact
• a close inside the zone
• a bullish reaction reclaim
• directional recovery above the zone midpoint
• a close above the relevant FVG edge
• a bullish rejection wick

The engine may then check:

• reaction strength
• volume participation
• positive DI dominance
• minimum ADX strength
• confirmed bullish HTF alignment
• minimum accepted grade

When every enabled condition remains valid at candle close, the script creates:

• a bullish FVG RETEST label
• an executed FVG retest box
• an entry reference at the confirmation close
• a protective stop below the setup reference
• TP1, TP2, and TP3 above entry
• blue reward visualization
• red risk visualization

This does not mean price must continue upward.

It means the script detected a bullish FVG retest condition that satisfied the selected rules at the time of confirmation.

━━━━━━━━━━━━━━━━━━━━━━
🔴 BEARISH FVG RETEST LOGIC
━━━━━━━━━━━━━━━━━━━━━━

A bearish FVG Retest setup begins with bearish structure context.

The script requires a confirmed bearish BOS or CHoCH event and then searches for a directionally matching FVG candidate.

The selected zone must remain valid while the engine waits for price to return.

Depending on the chosen profile and retest model, bearish confirmation may require:

• wick contact with the zone
• real-body contact
• a close inside the zone
• a bearish reaction reclaim
• directional recovery below the zone midpoint
• a close below the relevant FVG edge
• a bearish rejection wick

The engine may then check:

• reaction strength
• volume participation
• negative DI dominance
• minimum ADX strength
• confirmed bearish HTF alignment
• minimum accepted grade

When every enabled condition remains valid at candle close, the script creates:

• a bearish FVG RETEST label
• an executed FVG retest box
• an entry reference at the confirmation close
• a protective stop above the setup reference
• TP1, TP2, and TP3 below entry
• blue reward visualization
• red risk visualization

This does not mean price must continue downward.

It means the script detected a bearish FVG retest condition that satisfied the selected rules at the time of confirmation.

━━━━━━━━━━━━━━━━━━━━━━
💎 FVG QUALITY FILTER SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

The script includes a multi-layer FVG quality system to reduce unnecessary chart signals.

This is important because not every gap has the same context and not every retest should create an entry model.

The quality system may evaluate:

• minimum gap size relative to ATR
• displacement of the formation candle
• gap location inside the recent dealing range
• formation-volume context
• gap age
• previous interactions with the zone
• distance from the matching structure event
• structure-break strength
• reaction-candle strength
• volume participation on retest
• DI / ADX directional force
• confirmed HTF bias
• final setup grade

The exact behavior depends on the selected Engine Style.

Original Sync uses the first validated calibration and star-based acceptance logic.

Balanced Flow uses moderate filtering.

Precision Flow applies stricter FVG and retest requirements.

Fast Flow accepts more active conditions.

Position Flow uses wider structural and timing windows.

Custom Lab exposes the advanced thresholds for manual configuration.

The filter system does not guarantee better future outcomes.

It controls how selective the engine is before creating a confirmed visual model.

━━━━━━━━━━━━━━━━━━━━━━
📏 GAP / ATR FILTER
━━━━━━━━━━━━━━━━━━━━━━

The gap-width filter measures the detected FVG against ATR.

This helps the engine reject extremely small imbalance zones relative to current market volatility.

A higher minimum gap-width value makes FVG storage and candidate selection more selective.

A lower value allows smaller gaps to enter the internal memory.

The filter is volatility-adjusted because the same absolute price distance can have different meaning across symbols and timeframes.

The active threshold depends on the chosen profile or Custom Lab value.

A larger gap is not automatically a better setup.

Gap size is only one component of the complete selection and retest process.

━━━━━━━━━━━━━━━━━━━━━━
🕯️ DISPLACEMENT QUALITY FILTER
━━━━━━━━━━━━━━━━━━━━━━

The displacement filter evaluates the directional body of the candle associated with FVG formation.

The formation body is compared with ATR and converted into a bounded internal score.

This helps the script distinguish a stronger directional imbalance from a gap created during weak or narrow price action.

When the Gap Impulse Check is enabled, an FVG must satisfy the selected displacement threshold before it is stored as a valid candidate.

A higher threshold reduces the number of eligible FVGs.

A lower threshold accepts more moderate formations.

The displacement score is an internal quality measurement.

It does not predict whether the zone will hold in the future.

━━━━━━━━━━━━━━━━━━━━━━
📊 REACTION STRENGTH FILTER
━━━━━━━━━━━━━━━━━━━━━━

The reaction-strength filter evaluates the candle that interacts with the armed FVG.

The score can include:

• close location inside the candle
• directional wick quality
• body size relative to ATR
• bullish or bearish candle direction
• penetration depth inside the FVG

The purpose is to separate a basic touch from a more structured directional response.

A higher minimum reaction-strength value requires a clearer response from the zone.

A lower value accepts more retest conditions.

Original Sync can use its original reaction logic without the same adaptive score requirement.

The reaction score is not a win probability.

It is a standardized way to evaluate whether the retest candle matches the selected profile’s quality requirements.

━━━━━━━━━━━━━━━━━━━━━━
🧼 CONFIRMED RETEST FILTER
━━━━━━━━━━━━━━━━━━━━━━

The confirmed-retest layer requires price to satisfy the active retest model and remain valid at candle close.

Available Original Sync reaction patterns include:

• Any Wick Contact
• Real Body Contact
• Close Within Gap
• Reaction Reclaim

Available adaptive reaction models include:

• First Contact
• Directional Recovery
• Edge Reclaim
• Rejection Wick

First Contact accepts basic interaction with the zone.

Directional Recovery requires directional behavior after the interaction.

Edge Reclaim requires price to close through the relevant boundary.

Rejection Wick applies a stricter wick-and-close response.

The script can also use an interaction margin to tolerate minor boundary differences.

A minimum delay prevents the engine from confirming a retest too soon after the structure event.

An expiry window prevents stale armed zones from producing entries too far from their original context.

Final entry commitment remains bar-close based.

━━━━━━━━━━━━━━━━━━━━━━
🎯 ENTRY MODEL
━━━━━━━━━━━━━━━━━━━━━━

When an armed FVG retest passes all enabled conditions, the script creates a visual entry model.

The entry reference is the close of the candle that confirms the retest.

Permanent entries, labels, boxes, and entry alerts are committed only after candle close.

[pine]
tws_preview_ready := tws_eval_zone_touched and tws_eval_reaction_pass and tws_direction_filters_pass and tws_eval_grade_pass
bool tws_confirmed_entry = tws_preview_ready and barstate.isconfirmed

if tws_confirmed_entry
    tws_long_signal := tws_armed_direction == 1
    tws_short_signal := tws_armed_direction == -1
    tws_entry_event := true

    tws_trade_active := true
    tws_trade_direction := tws_armed_direction
    tws_trade_open_bar := bar_index
    tws_trade_entry := close
[/pine]

Confirmed Close mode waits for the candle to finish before the dashboard treats the setup as an entry.

Live Preview can show that current conditions are ready while the realtime candle is still open.

The preview may change intrabar because the candle is unfinished.

It does not create a permanent historical entry model unless the setup remains valid when the candle closes.

The entry is a visual analysis reference.

It is not a broker order and does not require the user to enter a trade.

━━━━━━━━━━━━━━━━━━━━━━
🛑 ATR STOP-LOSS MODEL
━━━━━━━━━━━━━━━━━━━━━━

The script includes two stop-placement models.

Gap-Protected Stop uses the selected FVG boundary plus an ATR-based protective buffer.

For bullish setups, the stop is projected below the FVG.

For bearish setups, the stop is projected above the FVG.

Volatility Stop projects the stop at an ATR multiple from entry.

A minimum stop-distance percentage can prevent extremely narrow visual stops.

[pine]
float tws_raw_stop =
     tws_stop_mode == "Gap-Protected Stop" ?
     (
         tws_trade_direction == 1 ?
         tws_armed_bottom - tws_atr * tws_fvg_stop_buffer_atr :
         tws_armed_top + tws_atr * tws_fvg_stop_buffer_atr
     ) :
     (
         tws_trade_direction == 1 ?
         tws_trade_entry - tws_atr * tws_atr_stop_multiplier :
         tws_trade_entry + tws_atr * tws_atr_stop_multiplier
     )

float tws_raw_stop_distance = math.abs(tws_trade_entry - tws_raw_stop)
float tws_guaranteed_distance = tws_trade_entry * tws_minimum_stop_percent / 100.0
float tws_final_stop_distance = math.max(tws_raw_stop_distance, tws_guaranteed_distance)
[/pine]

ATR is used because volatility changes across markets and timeframes.

A wider stop changes the projected risk distance and therefore also changes all three target levels.

The displayed SL is a visual planning level only.

It does not place or manage a real broker stop order.

━━━━━━━━━━━━━━━━━━━━━━
🎯 TAKE-PROFIT RR MODEL
━━━━━━━━━━━━━━━━━━━━━━

The script uses three take-profit levels.

Each target is calculated from the distance between entry and the original stop.

[pine]
float tws_trade_risk = math.abs(tws_trade_entry - tws_trade_original_stop)

tws_trade_tp1 := tws_trade_direction == 1 ? tws_trade_entry + tws_trade_risk * tws_tp1_r : tws_trade_entry - tws_trade_risk * tws_tp1_r
tws_trade_tp2 := tws_trade_direction == 1 ? tws_trade_entry + tws_trade_risk * tws_tp2_r : tws_trade_entry - tws_trade_risk * tws_tp2_r
tws_trade_tp3 := tws_trade_direction == 1 ? tws_trade_entry + tws_trade_risk * tws_tp3_r : tws_trade_entry - tws_trade_risk * tws_tp3_r
[/pine]

The default concept is:

TP1 = first risk-multiple target
TP2 = second risk-multiple target
TP3 = final risk-multiple target

The exact R values can be adjusted in Position Architecture.

The script also contains visual position-share percentages for TP1, TP2, and TP3.

These shares are used by the internal lifecycle model.

They do not represent a broker account, real position size, or verified financial performance.

The RR settings only control projected visual distances.

They should not be interpreted as recommendations or guaranteed objectives.

━━━━━━━━━━━━━━━━━━━━━━
📦 ACTIVE TP / SL BOX SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

When a confirmed FVG Retest entry appears, the script can draw a complete visual trade model.

The visual model includes:

• executed FVG retest zone
• entry line
• original stop line
• active stop line
• TP1 line
• TP2 line
• TP3 line
• red risk box
• blue reward box
• Entry price label
• SL price label
• TP1, TP2, and TP3 price labels
• bullish or bearish entry label

The active boxes extend to the right while the model is open.

When the model closes, the right edge is fixed at the closing candle.

If Keep Completed Trade Areas is enabled, completed boxes and lines remain visible for historical review.

The Completed Trade History Limit controls how many previous visual models are retained.

The TP area uses a blue-toned visual palette.

TP price labels use a different, darker background so they remain distinct from the reward box.

The SL area remains red for clearer risk separation.

━━━━━━━━━━━━━━━━━━━━━━
🚦 ONE ACTIVE TRADE AT A TIME
━━━━━━━━━━━━━━━━━━━━━━

The script includes one-active-trade-at-a-time logic.

If a trade model is active, the engine does not create another trade model until the current one closes.

The active model may close through:

• TP3
• targets complete
• stop loss
• breakeven exit

This design separates:

• FVG and structure detection
• trade-model creation permission

The engine can continue calculating market context while a model is active, but another entry model is not opened.

This helps prevent overlapping TP / SL areas and keeps the chart easier to interpret.

The one-active-model rule is a visual management decision.

It is not a restriction on the user’s personal trading activity.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ SAME-CANDLE TP / SL HANDLING
━━━━━━━━━━━━━━━━━━━━━━

If a target and the active stop are both touched on the same candle, standard OHLC data cannot reveal the true intrabar sequence.

The script therefore includes two selectable assumptions:

Protective First
Target First

Protective First assumes the stop is processed before target events.

Target First processes available target events before the stop check.

[pine]
bool tws_conservative_mode =
     tws_intrabar_priority == "Protective First"

if tws_conservative_mode and tws_stop_touched
    tws_trade_remaining_percent := 0.0
    tws_close_trade := true
    tws_close_reason := tws_trade_active_stop == tws_trade_entry ? "BREAKEVEN" : "STOP LOSS"
    tws_final_exit_price := tws_trade_active_stop
else
    if not tws_tp1_reached and tws_tp1_touched
        tws_tp1_reached := true
        tws_tp1_event := true
[/pine]

Protective First is the more conservative bar-based assumption.

Target First is more optimistic.

Neither option reproduces exact tick-by-tick broker execution.

The model does not include spread, slippage, commissions, latency, or partial-fill behavior.

━━━━━━━━━━━━━━━━━━━━━━
🏷️ FVG RETEST LABELS
━━━━━━━━━━━━━━━━━━━━━━

The script uses clear directional FVG Retest labels.

Bullish entry labels use:

🟢 FVG RETEST
📈 LONG

Bearish entry labels use:

🔴 FVG RETEST
📉 SHORT

Entry labels can also display:

• grade
• setup score
• FVG age
• retest depth
• Passport information

Completed-model labels emphasize that the closed model originated from an FVG retest.

A completed bullish model can display:

🟢 BULLISH FVG RETEST
🔒 MODEL CLOSED
🎯 close reason
⭐ grade
TP1 / TP2 / TP3 status

A completed bearish model uses the corresponding bearish wording and color.

The labels do not display USD profit or account-profit claims.

All chart labels use bold and italic text formatting.

The signal-label size can be adjusted from the settings.

━━━━━━━━━━━━━━━━━━━━━━
📍 FVG ZONE DISPLAY MODES
━━━━━━━━━━━━━━━━━━━━━━

The FVG display system includes three modes:

Hidden
Selected Gap
All Active Gaps

Hidden mode removes active FVG memory boxes from the chart while allowing the engine to continue calculating them internally.

Selected Gap shows only the FVG currently armed for retest monitoring.

All Active Gaps displays every currently stored and valid FVG zone.

Show Executed FVG Retests separately controls whether the FVG zone that created an entry remains highlighted as part of the trade model.

The selected display mode affects visual presentation only.

It does not change the underlying FVG calculations.

For the cleanest chart, Selected Gap is generally the most focused mode.

All Active Gaps can be useful for research but may create more chart density.

━━━━━━━━━━━━━━━━━━━━━━
🧹 FVG INVALIDATION
━━━━━━━━━━━━━━━━━━━━━━

The script can automatically remove invalidated FVG zones.

A bullish FVG may be invalidated when confirmed price action closes through the zone in the opposite direction.

A bearish FVG may be invalidated when confirmed price action closes through its opposite boundary.

An armed zone can also be cleared when:

• its retest window expires
• the zone exceeds the permitted lifetime
• the internal memory limit removes an older gap
• the active structure search is replaced

When an armed FVG becomes invalid, the Blocker Lens can display FVG INVALIDATED.

When the retest window expires, it can display SETUP EXPIRED.

Removing invalidated or stale zones helps prevent outdated FVGs from creating later entries outside their intended context.

Users can disable automatic invalidation removal if they prefer to retain more zones visually.

━━━━━━━━━━━━━━━━━━━━━━
📟 DASHBOARD
━━━━━━━━━━━━━━━━━━━━━━

The script includes a compact dashboard positioned in the bottom-right corner.

The dashboard displays:

• BIAS
• STATE
• ENTRY
• TP1
• TP2
• TP3
• SL

BIAS uses the confirmed higher-timeframe filter when that filter is enabled and valid.

Otherwise, it reflects the current internal structure bias.

STATE is powered by the Blocker Lens.

Possible states include:

• WAITING STRUCTURE
• SCANNING FVG
• NO ELIGIBLE FVG
• FVG ARMED
• RETEST DELAY
• WAITING RETEST
• VOLUME BLOCK
• DI BLOCK
• HTF BLOCK
• WEAK REACTION
• GRADE BLOCK
• LIVE PREVIEW READY
• WAITING BAR CLOSE
• TRADE ACTIVE
• COOLDOWN
• SETUP EXPIRED
• FVG INVALIDATED

The dashboard size can be set to Micro, Compact, or Standard.

The dashboard is designed to summarize engine state and current price references.

It is not a performance report.

It is not a replacement for TradingView Strategy Tester.

━━━━━━━━━━━━━━━━━━━━━━
🚨 ALERT SYSTEM
━━━━━━━━━━━━━━━━━━━━━━

FVG Retest Entry Engine includes advanced alert options for:

• FVG armed
• bullish FVG Retest entry
• bearish FVG Retest entry
• any FVG Retest entry
• TP1 reached
• TP2 reached
• TP3 reached
• breakeven activated
• stop loss
• breakeven exit

Alert packages include:

Off
Qualified Entries
Premium Entries
Full Lifecycle
Webhook JSON

Qualified Entries focuses on confirmed accepted entries.

Premium Entries applies stricter grade-based alert delivery.

Full Lifecycle includes entry and management events.

Webhook JSON sends structured event messages for external processing.

Alert Direction can be limited to Both Directions, Bullish Only, or Bearish Only.

Minimum Alert Grade can be set to All Qualified, A / A+, or A+ Only.

Alert filtering affects alert delivery only.

It does not change the chart’s signal calculations.

[pine]
alertcondition(tws_armed_alert_event, title="trade_w_samet • FVG ARMED", message='trade_w_samet FVG ARMED | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}}')
alertcondition(tws_entry_alert_event and tws_trade_direction == 1, title="trade_w_samet • BULLISH FVG RETEST", message='trade_w_samet BULLISH FVG RETEST | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}} | Entry: {{plot("ENTRY")}} | SL: {{plot("SL")}} | TP1: {{plot("TP1")}} | TP2: {{plot("TP2")}} | TP3: {{plot("TP3")}}')
alertcondition(tws_entry_alert_event and tws_trade_direction == -1, title="trade_w_samet • BEARISH FVG RETEST", message='trade_w_samet BEARISH FVG RETEST | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}} | Entry: {{plot("ENTRY")}} | SL: {{plot("SL")}} | TP1: {{plot("TP1")}} | TP2: {{plot("TP2")}} | TP3: {{plot("TP3")}}')
alertcondition(tws_tp1_alert_event, title="trade_w_samet • TP1 REACHED", message='trade_w_samet TP1 REACHED | {{ticker}} | TP1: {{plot("TP1")}}')
alertcondition(tws_stop_alert_event, title="trade_w_samet • STOP LOSS", message='trade_w_samet STOP LOSS | {{ticker}} | SL: {{plot("SL")}}')
[/pine]

Alerts are monitoring tools only.

They do not execute trades or place broker orders.

━━━━━━━━━━━━━━━━━━━━━━
🔔 HOW TO USE ALERTS
━━━━━━━━━━━━━━━━━━━━━━

A practical alert workflow:

1. Add FVG Retest Entry Engine [trade_w_samet] to the chart.
2. Select the desired Engine Style and confirmation settings.
3. Open TradingView’s alert window.
4. Select the indicator as the alert condition.
5. Choose the desired entry or lifecycle condition.
6. Select the alert frequency appropriate for confirmed-candle monitoring.
7. Use the Alert Package, direction, and grade controls inside the indicator when needed.
8. Add a webhook URL only when using a compatible external workflow.
9. Test the alert configuration before depending on it.
10. Confirm every event with personal analysis and risk management.

For confirmed entry monitoring, users should avoid treating provisional realtime candle conditions as permanent signals.

Entry alerts are designed around the script’s confirmed event variables.

Alert delivery can still depend on TradingView servers, the user’s alert configuration, data availability, and any external webhook destination.

━━━━━━━━━━━━━━━━━━━━━━
🧪 HOW TO USE THE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━

A practical workflow:

1. Add FVG Retest Entry Engine [trade_w_samet] to a standard candlestick chart.
2. Begin with Original Sync or Balanced Flow.
3. Keep Signal Timing on Confirmed Close for the clearest workflow.
4. Use Selected Gap to keep the chart focused.
5. Observe the dashboard STATE value.
6. Wait for a confirmed structure event and an armed FVG.
7. Review the FVG zone before the retest occurs.
8. When price returns, allow the selected retest model and filters to complete.
9. Review the FVG Retest Passport when an entry appears.
10. Use the displayed Entry, SL, TP1, TP2, and TP3 as visual references only.
11. Evaluate whether the setup fits personal structure, liquidity, session, and risk rules.
12. Use alerts for monitoring rather than blind execution.
13. Review completed FVG Retest labels to understand the model lifecycle.
14. Test settings on the exact markets and timeframes personally studied.

The indicator is best used as a structured FVG retest review tool.

It should not be used as an automatic decision-maker.

━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━

⚡ Signal Blueprint

Engine Style
Controls the active configuration profile.

Available profiles:

Original Sync
Balanced Flow
Precision Flow
Fast Flow
Position Flow
Custom Lab

Allow Bullish Setups
Enables or disables bullish FVG Retest models.

Allow Bearish Setups
Enables or disables bearish FVG Retest models.

━━━━━━━━━━━━━━━━━━━━━━

🪪 Retest Experience

FVG Retest Passport
Controls whether Passport information is Off, Compact, or Detailed.

Show Blocker Lens
Shows or hides the engine STATE explanation in the dashboard.

Signal Timing
Selects Confirmed Close or Live Preview behavior.

Live Preview affects the dashboard’s provisional realtime state. Permanent entries remain candle-close confirmed.

━━━━━━━━━━━━━━━━━━━━━━

🧬 Original Sync Engine

Original Signal Calibration
Selects Manual Sync, Bitcoin Map, Ethereum Map, Solana Map, or Gold Map.

Structure Window
Controls pivot sensitivity in Manual Sync.

Minimum Gap Footprint — ATR
Controls the minimum FVG width.

Gap Lifetime
Controls how long stored FVGs remain eligible.

Gap Memory Capacity
Controls the number of stored zones.

Break-to-Gap Distance
Controls the maximum allowed distance between structure context and FVG eligibility.

After-Break Scan Window
Controls how long the engine continues searching after a break.

Reaction Pattern
Selects Any Wick Contact, Real Body Contact, Close Within Gap, or Reaction Reclaim.

Reaction Margin %
Adds tolerance around FVG boundaries.

Minimum Reaction Delay
Controls how many bars must pass before retest confirmation.

Reaction Expiry Bars
Controls how long the armed setup may wait.

Participation Multiplier
Controls the Original Sync volume requirement.

Minimum Directional Force
Controls the Original Sync ADX threshold.

Minimum Sync Rating
Controls the minimum accepted star rating.

Minimum Risk Distance %
Prevents extremely narrow stops.

━━━━━━━━━━━━━━━━━━━━━━

🧭 Structure Pulse

Structure Sensitivity
Controls pivot detection in Custom Lab.

Display Structure Tags
Shows or hides BOS / CHoCH labels.

Close-Lock Breaks
Requires a candle close beyond structure when enabled.

Break Momentum Check
Requires directional expansion on the break candle.

Break Body Threshold — ATR
Controls the required break-candle body size.

Break Clearance — ATR
Adds an ATR-based buffer beyond the structure level.

━━━━━━━━━━━━━━━━━━━━━━

🧱 Gap Intelligence

Minimum Gap Width — ATR
Controls the minimum stored FVG size.

Gap Impulse Check
Enables displacement filtering.

Minimum Gap Impulse
Controls the required formation displacement.

Minimum Gap Score
Controls the minimum candidate-quality score.

Allowed Prior Reactions
Controls how many previous zone interactions are accepted.

Gap Expiry Bars
Controls maximum FVG age.

Active Gap Capacity
Controls stored-zone capacity.

Maximum Structure Link
Controls the maximum structure-to-FVG distance.

Break Follow-Through Window
Controls post-break candidate scanning.

Delete Invalidated Gaps
Removes zones invalidated by confirmed opposite price action.

━━━━━━━━━━━━━━━━━━━━━━

🎯 Reaction Trigger

Reaction Model
Selects First Contact, Directional Recovery, Edge Reclaim, or Rejection Wick.

Gap Interaction Margin %
Adds tolerance around FVG boundaries.

Minimum Reaction Strength
Controls the required retest-candle score.

Reaction Delay Bars
Controls the minimum delay before retest confirmation.

Setup Expiry Bars
Controls how long the armed zone remains available.

Signal Cooldown Bars
Controls the delay after a completed model before another entry is permitted.

━━━━━━━━━━━━━━━━━━━━━━

🛂 Quality Checkpoints

Volume Participation Check
Enables or disables the retest-volume filter.

Volume Baseline Length
Controls the volume moving-average period.

Required Volume Expansion
Controls the required volume multiplier.

Directional Force Check
Enables or disables DI / ADX filtering.

Directional Force Length
Controls the DI period.

Trend Strength Smoothing
Controls ADX smoothing.

Minimum Trend Strength
Controls the required ADX value.

Higher-Timeframe Bias Check
Enables or disables HTF directional alignment.

Bias Timeframe
Selects the higher timeframe.

Bias Fast EMA
Controls the fast HTF EMA length.

Bias Slow EMA
Controls the slow HTF EMA length.

Minimum Setup Grade
Selects B Grade or Better, A Grade or Better, or A+ Only.

The HTF layer uses previous completed higher-timeframe values.

[pine]
float tws_htf_close = request.security(
     syminfo.tickerid,
     tws_htf_timeframe,
     close[1],
     barmerge.gaps_off,
     barmerge.lookahead_on
 )

float tws_htf_fast_ema = request.security(
     syminfo.tickerid,
     tws_htf_timeframe,
     ta.ema(close, tws_htf_fast_length)[1],
     barmerge.gaps_off,
     barmerge.lookahead_on
 )

float tws_htf_slow_ema = request.security(
     syminfo.tickerid,
     tws_htf_timeframe,
     ta.ema(close, tws_htf_slow_length)[1],
     barmerge.gaps_off,
     barmerge.lookahead_on
 )
[/pine]

━━━━━━━━━━━━━━━━━━━━━━

🛡️ Position Architecture

ATR Calculation Length
Controls ATR calculation.

Stop Placement Model
Selects Gap-Protected Stop or Volatility Stop.

Volatility Stop Multiplier
Controls ATR stop distance from entry.

Gap Stop Buffer — ATR
Controls the protective distance beyond the FVG.

Minimum Stop Distance %
Prevents extremely narrow risk zones.

TP1 Risk Multiple
Controls the first target distance.

TP2 Risk Multiple
Controls the second target distance.

TP3 Risk Multiple
Controls the final target distance.

TP1 Position Share %
Controls the internal visual share assigned to TP1.

TP2 Position Share %
Controls the internal visual share assigned to TP2.

TP3 Position Share %
Controls the internal visual share assigned to TP3.

Move Stop to Entry After TP1
Moves the active stop to entry after TP1 according to confirmed lifecycle rules.

Same-Candle Priority
Selects Protective First or Target First.

━━━━━━━━━━━━━━━━━━━━━━

🎨 Chart Design

Color System
Selects Obsidian Signal, Carbon Grid, Ivory Pulse, Neon Voltage, Acid Circuit, or Violet Flux.

Gap Display Mode
Selects Hidden, Selected Gap, or All Active Gaps.

Show Executed FVG Retests
Shows or hides the FVG zone used by a confirmed trade model.

Display TP / SL Areas
Shows or hides the reward and risk boxes.

Keep Completed Trade Areas
Keeps completed model boxes and lines.

Completed Trade History Limit
Controls the maximum historical visual models.

Active Area Projection
Controls the initial right-side projection length.

Chart Layout
Selects Desktop or Mobile.

Signal Label Size
Selects Micro, Compact, Standard, or Large.

Dashboard Size
Selects Micro, Compact, or Standard.

Display Bias EMA
Shows or hides the confirmed HTF fast EMA reference.

Display Setup Dashboard
Shows or hides the bottom-right dashboard.

━━━━━━━━━━━━━━━━━━━━━━

📡 Alert Center

Alert Package
Selects Off, Qualified Entries, Premium Entries, Full Lifecycle, or Webhook JSON.

Alert Direction
Selects Both Directions, Bullish Only, or Bearish Only.

Minimum Alert Grade
Selects All Qualified, A / A+, or A+ Only.

Alert When FVG Is Armed
Enables armed-zone alerts for compatible packages.

Alert When Stop Moves to Entry
Enables breakeven-activation alerts for compatible packages.

━━━━━━━━━━━━━━━━━━━━━━
🧠 WHAT MAKES THIS SCRIPT ORIGINAL
━━━━━━━━━━━━━━━━━━━━━━

FVG Retest Entry Engine uses familiar analytical concepts such as:

• Fair Value Gaps
• swing-point structure
• BOS and CHoCH
• ATR
• volume analysis
• DI / ADX
• higher-timeframe EMA bias
• risk/reward projection
• staged targets
• breakeven management

These concepts are not unique by themselves.

The originality of this script lies in how they are organized into a transparent FVG retest workflow:

Structure confirmation
→ directional FVG memory
→ contextual candidate comparison
→ selected armed zone
→ configurable retest validation
→ reaction-quality evaluation
→ optional volume, DI, and HTF checkpoints
→ setup grading
→ confirmed-close entry commitment
→ three-target visual management
→ optional breakeven movement
→ completed FVG Retest archiving
→ Blocker Lens state reporting
→ Passport explanation
→ lifecycle alerts

Distinctive implementation features include:

• structure-linked FVG selection instead of signaling every gap
• multiple Engine Style profiles
• Original Sync market calibrations
• an armed-zone state before entry
• candidate ranking using several FVG characteristics
• multiple retest models
• a visible reason when an entry is waiting or blocked
• a Passport explaining accepted setup context
• confirmed-close permanent signal commitment
• previous-completed HTF values
• executed FVG zone preservation
• three-stage target management
• Desktop and Mobile display modes
• alert filtering separated from chart calculations

This structure is designed to provide a focused and explainable review process without relying on hidden prediction claims.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ IMPORTANT PRACTICAL NOTES
━━━━━━━━━━━━━━━━━━━━━━

The script’s behavior depends heavily on settings and market conditions.

Signal frequency and visual output may change based on:

• Engine Style
• structure sensitivity
• close-based or wick-based breaks
• break momentum requirements
• minimum FVG width
• displacement filtering
• candidate-score threshold
• previous zone interactions
• FVG lifetime
• retest model
• reaction-strength threshold
• retest delay
• setup expiry
• volume filter settings
• DI / ADX settings
• HTF timeframe and EMA lengths
• minimum setup grade
• stop model
• target multiples
• signal cooldown
• timeframe
• symbol volatility
• market session
• available historical bars

A setting that appears clean on one market may behave differently on another.

A profile that produces suitable frequency on one timeframe may be too strict or too active on another.

Volume behavior can differ across asset classes and data providers.

Higher-timeframe filtering only operates as intended when the selected bias timeframe is genuinely higher than the chart timeframe.

Users should test the exact symbol, timeframe, profile, and session they personally study.

━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS AND SHORTCOMINGS
━━━━━━━━━━━━━━━━━━━━━━

This script has important limitations:

It does not guarantee profitable trades.
It does not predict future price movement.
It does not replace risk management.
It does not execute trades.
It does not place broker orders.
It does not include broker slippage.
It does not include commissions.
It does not include spreads.
It does not include execution delay.
It does not include partial-fill behavior.
It uses bar-based chart data.
Same-candle TP / SL order cannot be known from standard OHLC data.
Same-Candle Priority is a modeling assumption.
Live Preview can change intrabar because the realtime candle is unfinished.
Permanent entry models are committed only after bar close.
Confirmed pivots require future bars before becoming available as confirmed swing points.
The dashboard is not TradingView Strategy Tester.
The internal target-share model is not account-performance reporting.
Historical boxes and completed labels do not guarantee similar future behavior.
Setup grades are internal classifications, not win probabilities.
Filter settings do not guarantee improved future results.
Higher-timeframe values depend on selected timeframe and available data.
Data-feed revisions or chart-history differences can affect historical calculations.
Alert delivery depends on TradingView and the user’s alert configuration.
Webhook delivery also depends on the external destination.
One-active-trade logic is a visual management rule, not broker execution logic.

For these reasons, FVG Retest Entry Engine should be used as an educational decision-support and chart-analysis tool, not as a standalone automated trading strategy.

━━━━━━━━━━━━━━━━━━━━━━
👤 WHO THIS SCRIPT MAY BE USEFUL FOR
━━━━━━━━━━━━━━━━━━━━━━

This script may be useful for traders who:

• study Fair Value Gap retests
• use BOS and CHoCH context
• prefer selected FVGs instead of every raw gap
• want a visible armed-zone workflow
• want to understand why a setup is waiting or blocked
• prefer confirmed-close entries
• want a setup-grade framework
• want Entry, SL, TP1, TP2, and TP3 visualization
• want optional breakeven behavior
• want completed FVG Retest models preserved visually
• use higher-timeframe directional context
• want mobile-friendly chart presentation
• use lifecycle alerts for monitoring
• want a structured educational analysis framework

It may be less suitable for users who:

• want guaranteed buy/sell signals
• want a fully automated trading bot
• want every raw FVG to create an entry
• expect one profile to work on every market
• expect grades to represent guaranteed probability
• require exact tick-level execution simulation
• expect visual projections to match broker fills
• expect alerts to execute trades automatically
• want an indicator to replace independent decision-making

━━━━━━━━━━━━━━━━━━━━━━
🧭 BEST PRACTICE SUGGESTIONS
━━━━━━━━━━━━━━━━━━━━━━

For cleaner review:

• Start with Original Sync or Balanced Flow.
• Keep Signal Timing on Confirmed Close.
• Use Selected Gap to reduce chart clutter.
• Enable Blocker Lens while learning the engine workflow.
• Use Compact Passport for concise context.
• Use Detailed Passport when reviewing why a setup qualified.
• Review the armed FVG before the entry appears.
• Check whether the FVG retest agrees with personal market-structure analysis.
• Evaluate the displayed stop against nearby structure and volatility.
• Treat TP1, TP2, and TP3 as planning references only.
• Keep Protective First when a conservative same-candle assumption is preferred.
• Use Precision Flow when fewer, stricter setups are preferred.
• Use Fast Flow only after understanding its higher signal frequency.
• Use Custom Lab only after learning how each threshold affects the engine.
• Use Mobile layout on smaller screens.
• Use alerts for monitoring, not blind execution.
• Always apply independent analysis, risk management, and position sizing.

━━━━━━━━━━━━━━━━━━━━━━
🔓 PUBLICATION NOTE
━━━━━━━━━━━━━━━━━━━━━━

FVG Retest Entry Engine [trade_w_samet] is published as an educational and visual market-analysis tool.

The purpose of this description is to explain:

• what the script does
• how structure events are confirmed
• how three-candle FVGs are detected
• how FVGs are stored and invalidated
• how structure and FVG candidates are linked
• how an FVG becomes armed
• how retest models work
• how reaction quality is evaluated
• how volume, DI / ADX, and HTF checkpoints operate
• how setup grades are assigned
• how Confirmed Close and Live Preview differ
• how Entry and stop levels are calculated
• how TP1, TP2, and TP3 are projected
• how breakeven and same-candle assumptions work
• how active and completed trade areas behave
• what the Passport and Blocker Lens show
• what the dashboard displays
• what the alert packages do
• what the limitations are
• how the indicator should and should not be used

The script is designed to support structured analysis.

It does not promise profitable results.

It does not remove market risk.

It does not execute trades.

It should not be used as a blind buy/sell system.

It is best used as a visual framework for reviewing structure-linked FVG retests and projected risk/reward behavior.

━━━━━━━━━━━━━━━━━━━━━━
🛡️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━

FVG Retest Entry Engine [trade_w_samet] is provided for educational and informational purposes only.

It does not constitute financial, investment, trading, legal, or tax advice.

No indicator can guarantee future results.

Markets are uncertain, conditions change, and historical behavior does not ensure future performance.

Every user is responsible for their own analysis, validation, risk management, position sizing, alert configuration, trading decisions, and broker execution.

The structure labels, FVG zones, armed-zone states, Passport values, Blocker Lens messages, grades, scores, entry references, stop-loss levels, take-profit levels, TP / SL boxes, dashboard values, completed-model labels, and alerts are visual analysis tools only.

Use this script as a structured decision-support and visual review framework, not as a promise of profitability or a substitute for independent judgment.

## Source Code

````pine
// Dashboard position: bottom-right | Entry and close labels: emoji enabled
//@version=6
indicator(
     "FVG Retest Entry Engine [trade_w_samet]",
     shorttitle="FVG Retest Entry Engine [trade_w_samet]",
     overlay=true,
     behind_chart=false,
     max_bars_back=5000,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500,
     format=format.price
 )

const string TWS_SIGNATURE = "trade_w_samet"

// GROUPS

tws_group_mode    = "⚡ Signal Blueprint"
tws_group_experience = "🪪 Retest Experience"
tws_group_classic = "🧬 Original Sync Engine"
tws_group_structure = "🧭 Structure Pulse"
tws_group_imbalance       = "🧱 Gap Intelligence"
tws_group_return    = "🎯 Reaction Trigger"
tws_group_gate   = "🛂 Quality Checkpoints"
tws_group_defense      = "🛡️ Position Architecture"
tws_group_visuals    = "🎨 Chart Design"
tws_group_delivery    = "📡 Alert Center"

// OPERATING PROFILE

tws_engine_profile = input.string(
     "Original Sync",
     "Engine Style",
     options=["Original Sync", "Balanced Flow", "Precision Flow", "Fast Flow", "Position Flow", "Custom Lab"],
     tooltip="Original Sync preserves the first validated signal map. Balanced Flow, Precision Flow, Fast Flow and Position Flow apply different trade_w_samet sensitivity models. Custom Lab unlocks every advanced parameter.",
     group=tws_group_mode,
     display=display.none
 )

bool tws_classic_profile = tws_engine_profile == "Original Sync"
bool tws_custom_profile = tws_engine_profile == "Custom Lab"

tws_allow_longs = input.bool(
     true,
     "Allow Bullish Setups",
     tooltip="Allows validated bullish gap reactions to create an entry model.",
     group=tws_group_mode,
     display=display.none
 )

tws_allow_shorts = input.bool(
     true,
     "Allow Bearish Setups",
     tooltip="Allows validated bearish gap reactions to create an entry model.",
     group=tws_group_mode,
     display=display.none
 )

// RETEST EXPERIENCE

tws_passport_mode = input.string(
     "Compact",
     "FVG Retest Passport",
     options=["Off", "Compact", "Detailed"],
     tooltip="Adds a clear setup identity to every confirmed retest. Compact shows age and depth; Detailed also shows structure, FVG size and filter status.",
     group=tws_group_experience,
     display=display.none
 )

tws_show_blocker_lens = input.bool(
     true,
     "Show Blocker Lens",
     tooltip="Explains the engine's current state, including waiting for structure, retest delay, volume block, DI block, HTF block, weak reaction, grade block and ready-at-close states.",
     group=tws_group_experience,
     display=display.none
 )

tws_signal_timing_mode = input.string(
     "Confirmed Close",
     "Signal Timing",
     options=["Confirmed Close", "Live Preview"],
     tooltip="Both modes commit entries, labels and alerts only after the chart candle closes. Live Preview only updates the dashboard intrabar, so provisional conditions never become historical signals and do not repaint.",
     group=tws_group_experience,
     display=display.none
 )

// ORIGINAL SYNC ENGINE

tws_classic_preset = input.string(
     "Manual Sync",
     "Original Signal Calibration",
     options=["Manual Sync", "Bitcoin Map", "Ethereum Map", "Solana Map", "Gold Map"],
     tooltip="Recreates the first validated signal calibration. Manual Sync exposes the base values; market maps apply the matching original overrides.",
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_profile
 )

bool tws_classic_manual = tws_classic_profile and tws_classic_preset == "Manual Sync"

tws_classic_structure_len_input = input.int(
     8,
     "Structure Window",
     minval=5,
     maxval=19,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_min_fvg_atr_input = input.float(
     0.20,
     "Minimum Gap Footprint — ATR",
     minval=0.01,
     maxval=3.00,
     step=0.01,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_max_fvg_age_input = input.int(
     150,
     "Gap Lifetime",
     minval=10,
     maxval=1000,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_max_fvg_zones_input = input.int(
     30,
     "Gap Memory Capacity",
     minval=5,
     maxval=100,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_max_fvg_distance_input = input.int(
     30,
     "Break-to-Gap Distance",
     minval=1,
     maxval=200,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_post_break_scan_input = input.int(
     4,
     "After-Break Scan Window",
     minval=0,
     maxval=20,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_retest_mode_input = input.string(
     "Reaction Reclaim",
     "Reaction Pattern",
     options=["Any Wick Contact", "Real Body Contact", "Close Within Gap", "Reaction Reclaim"],
     tooltip="Chooses how Original Sync recognizes a valid return into the selected gap.",
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_profile
 )

tws_classic_touch_tolerance_input = input.float(
     0.025,
     "Reaction Margin %",
     minval=0.000,
     maxval=1.000,
     step=0.001,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_min_retest_delay_input = input.int(
     2,
     "Minimum Reaction Delay",
     minval=1,
     maxval=50,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_max_bars_to_wait_input = input.int(
     20,
     "Reaction Expiry Bars",
     minval=2,
     maxval=200,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_volume_multiplier_input = input.float(
     1.00,
     "Participation Multiplier",
     minval=0.10,
     maxval=5.00,
     step=0.05,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_minimum_adx_input = input.float(
     10.0,
     "Minimum Directional Force",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

tws_classic_minimum_stars = input.int(
     1,
     "Minimum Sync Rating",
     minval=1,
     maxval=4,
     tooltip="Sets the minimum Original Sync rating required before a signal is released.",
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_profile
 )

tws_classic_minimum_stop_input = input.float(
     1.00,
     "Minimum Risk Distance %",
     minval=0.00,
     maxval=20.00,
     step=0.05,
     group=tws_group_classic,
     display=display.none,
     active=tws_classic_manual
 )

// STRUCTURE PULSE INPUTS

tws_structure_len_input = input.int(
     8,
     "Structure Sensitivity",
     minval=5,
     maxval=19,
     tooltip="Controls how quickly Custom Lab recognizes confirmed swing points.",
     group=tws_group_structure,
     display=display.none,
     active=tws_custom_profile
 )

tws_show_structure = input.bool(
     false,
     "Display Structure Tags",
     tooltip="Shows optional structure-break tags on the chart. This is disabled by default for a cleaner layout.",
     group=tws_group_structure,
     display=display.none
 )

tws_require_body_close = input.bool(
     true,
     "Close-Lock Breaks",
     tooltip="Requires a candle close beyond structure. Disable it to allow wick-based breaks.",
     group=tws_group_structure,
     display=display.none
 )

tws_use_break_displacement = input.bool(
     true,
     "Break Momentum Check",
     tooltip="Requires visible momentum on the candle that clears the swing level.",
     group=tws_group_structure,
     display=display.none
 )

tws_minimum_break_body_atr_input = input.float(
     0.35,
     "Break Body Threshold — ATR",
     minval=0.00,
     maxval=3.00,
     step=0.05,
     tooltip="Custom Lab minimum body expansion for a valid structure break.",
     group=tws_group_structure,
     display=display.none,
     active=tws_custom_profile and tws_use_break_displacement
 )

tws_break_buffer_atr_input = input.float(
     0.02,
     "Break Clearance — ATR",
     minval=0.00,
     maxval=1.00,
     step=0.01,
     tooltip="Adds volatility-based distance beyond the swing before confirmation.",
     group=tws_group_structure,
     display=display.none,
     active=tws_custom_profile
 )

// GAP INTELLIGENCE INPUTS

tws_min_fvg_atr_input = input.float(
     0.20,
     "Minimum Gap Width — ATR",
     minval=0.01,
     maxval=3.00,
     step=0.01,
     tooltip="Custom Lab minimum three-candle gap width relative to ATR.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_use_fvg_displacement_filter = input.bool(
     true,
     "Gap Impulse Check",
     tooltip="Filters gaps that form without a strong directional impulse.",
     group=tws_group_imbalance,
     display=display.none
 )

tws_minimum_fvg_displacement_input = input.float(
     0.25,
     "Minimum Gap Impulse",
     minval=0.00,
     maxval=1.00,
     step=0.05,
     tooltip="Custom Lab minimum impulse score required at gap creation.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile and tws_use_fvg_displacement_filter
 )

tws_minimum_zone_quality_input = input.float(
     0.42,
     "Minimum Gap Score",
     minval=0.00,
     maxval=1.00,
     step=0.01,
     tooltip="Lowest internal gap score allowed into the reaction engine.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_maximum_prior_touches_input = input.int(
     1,
     "Allowed Prior Reactions",
     minval=0,
     maxval=10,
     tooltip="Controls how many previous reactions a gap may contain before rejection.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_max_fvg_age_input = input.int(
     150,
     "Gap Expiry Bars",
     minval=10,
     maxval=1000,
     tooltip="Removes active gaps after the selected candle count.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_max_fvg_zones_input = input.int(
     24,
     "Active Gap Capacity",
     minval=5,
     maxval=100,
     tooltip="Limits active gap objects to protect TradingView performance.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_max_fvg_distance_input = input.int(
     30,
     "Maximum Structure Link",
     minval=1,
     maxval=200,
     tooltip="Limits how far a gap may form from its linked structure event.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_post_break_scan_bars_input = input.int(
     4,
     "Break Follow-Through Window",
     minval=0,
     maxval=20,
     tooltip="Keeps scanning for a matching gap after the break is confirmed.",
     group=tws_group_imbalance,
     display=display.none,
     active=tws_custom_profile
 )

tws_remove_invalid_fvgs = input.bool(
     true,
     "Delete Invalidated Gaps",
     tooltip="Deletes a bullish gap after a close below it and a bearish gap after a close above it.",
     group=tws_group_imbalance,
     display=display.none
 )

// REACTION TRIGGER INPUTS

tws_retest_mode_input = input.string(
     "Directional Recovery",
     "Reaction Model",
     options=["First Contact", "Directional Recovery", "Edge Reclaim", "Rejection Wick"],
     tooltip="First Contact accepts overlap. Directional Recovery requires movement back with the setup. Edge Reclaim requires a close through the gap boundary. Rejection Wick applies the strictest rejection model.",
     group=tws_group_return,
     display=display.none,
     active=tws_custom_profile
 )

tws_touch_tolerance_input = input.float(
     0.025,
     "Gap Interaction Margin %",
     minval=0.000,
     maxval=1.000,
     step=0.001,
     tooltip="Adds a small price margin around the selected gap boundary.",
     group=tws_group_return,
     display=display.none,
     active=tws_custom_profile
 )

tws_minimum_reaction_score_input = input.float(
     0.35,
     "Minimum Reaction Strength",
     minval=0.00,
     maxval=1.00,
     step=0.01,
     tooltip="Sets the minimum reaction-candle quality required by Custom Lab.",
     group=tws_group_return,
     display=display.none,
     active=tws_custom_profile
 )

tws_min_retest_delay_input = input.int(
     2,
     "Reaction Delay Bars",
     minval=1,
     maxval=50,
     tooltip="Blocks reactions that occur too soon after the structure event.",
     group=tws_group_return,
     display=display.none,
     active=tws_custom_profile
 )

tws_max_bars_to_wait_input = input.int(
     20,
     "Setup Expiry Bars",
     minval=2,
     maxval=200,
     tooltip="Cancels the selected setup when no valid reaction appears in time.",
     group=tws_group_return,
     display=display.none,
     active=tws_custom_profile
 )

tws_cooldown_after_close = input.int(
     0,
     "Signal Cooldown Bars",
     minval=0,
     maxval=100,
     tooltip="Prevents immediate re-entry after the previous trade model closes.",
     group=tws_group_return,
     display=display.none
 )

// QUALITY CHECKPOINT INPUTS

tws_use_volume_filter = input.bool(
     true,
     "Volume Participation Check",
     tooltip="Requires confirmation-candle volume to expand above its baseline.",
     group=tws_group_gate,
     display=display.none
 )

tws_volume_length = input.int(
     21,
     "Volume Baseline Length",
     minval=2,
     maxval=200,
     tooltip="Defines the moving-average length used by the volume check.",
     group=tws_group_gate,
     display=display.none
 )

tws_volume_multiplier_input = input.float(
     1.00,
     "Required Volume Expansion",
     minval=0.10,
     maxval=5.00,
     step=0.05,
     tooltip="Custom Lab volume requirement relative to the selected baseline.",
     group=tws_group_gate,
     display=display.none,
     active=tws_custom_profile and tws_use_volume_filter
 )

tws_use_di_filter = input.bool(
     true,
     "Directional Force Check",
     tooltip="Requires DI direction and trend strength to support the setup.",
     group=tws_group_gate,
     display=display.none
 )

tws_di_length = input.int(
     14,
     "Directional Force Length",
     minval=2,
     maxval=100,
     group=tws_group_gate,
     display=display.none
 )

tws_adx_smoothing = input.int(
     14,
     "Trend Strength Smoothing",
     minval=2,
     maxval=100,
     group=tws_group_gate,
     display=display.none
 )

tws_minimum_adx_input = input.float(
     10.0,
     "Minimum Trend Strength",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     tooltip="Custom Lab minimum ADX strength required by the directional check.",
     group=tws_group_gate,
     display=display.none,
     active=tws_custom_profile and tws_use_di_filter
 )

tws_use_htf_filter = input.bool(
     true,
     "Higher-Timeframe Bias Check",
     tooltip="Allows entries only when the selected higher timeframe confirms the same bias.",
     group=tws_group_gate,
     display=display.none
 )

tws_htf_timeframe = input.timeframe(
     "60",
     "Bias Timeframe",
     tooltip="Select a timeframe above the chart timeframe. Equal or lower selections are ignored.",
     group=tws_group_gate,
     display=display.none
 )

tws_htf_fast_length = input.int(
     50,
     "Bias Fast EMA",
     minval=2,
     maxval=500,
     group=tws_group_gate,
     display=display.none
 )

tws_htf_slow_length = input.int(
     200,
     "Bias Slow EMA",
     minval=3,
     maxval=1000,
     group=tws_group_gate,
     display=display.none
 )

tws_minimum_grade_input = input.string(
     "B Grade or Better",
     "Minimum Setup Grade",
     options=["B Grade or Better", "A Grade or Better", "A+ Only"],
     tooltip="Selects the lowest setup grade allowed to create a trade model.",
     group=tws_group_gate,
     display=display.none,
     active=tws_custom_profile
 )

// POSITION ARCHITECTURE INPUTS

tws_atr_length = input.int(
     14,
     "ATR Calculation Length",
     minval=2,
     maxval=200,
     group=tws_group_defense,
     display=display.none
 )

tws_stop_mode = input.string(
     "Gap-Protected Stop",
     "Stop Placement Model",
     options=["Gap-Protected Stop", "Volatility Stop"],
     tooltip="Gap-Protected Stop places protection beyond the selected gap. Volatility Stop measures distance directly from entry.",
     group=tws_group_defense,
     display=display.none
 )

tws_atr_stop_multiplier = input.float(
     1.50,
     "Volatility Stop Multiplier",
     minval=0.10,
     maxval=10.00,
     step=0.05,
     group=tws_group_defense,
     display=display.none
 )

tws_fvg_stop_buffer_atr = input.float(
     0.15,
     "Gap Stop Buffer — ATR",
     minval=0.00,
     maxval=5.00,
     step=0.05,
     tooltip="Adds ATR-based clearance beyond the selected gap boundary.",
     group=tws_group_defense,
     display=display.none
 )

tws_minimum_stop_percent_input = input.float(
     0.80,
     "Minimum Stop Distance %",
     minval=0.00,
     maxval=20.00,
     step=0.05,
     tooltip="Prevents unrealistically tight stops in Custom Lab.",
     group=tws_group_defense,
     display=display.none,
     active=tws_custom_profile
 )

tws_tp1_r = input.float(
     1.0,
     "TP1 Risk Multiple",
     minval=0.10,
     maxval=20.00,
     step=0.10,
     group=tws_group_defense,
     display=display.none
 )

tws_tp2_r = input.float(
     2.0,
     "TP2 Risk Multiple",
     minval=0.20,
     maxval=30.00,
     step=0.10,
     group=tws_group_defense,
     display=display.none
 )

tws_tp3_r = input.float(
     3.0,
     "TP3 Risk Multiple",
     minval=0.30,
     maxval=50.00,
     step=0.10,
     group=tws_group_defense,
     display=display.none
 )

tws_tp1_close_percent = input.float(
     60.0,
     "TP1 Position Share %",
     minval=0.0,
     maxval=100.0,
     step=0.1,
     group=tws_group_defense,
     display=display.none
 )

tws_tp2_close_percent = input.float(
     25.0,
     "TP2 Position Share %",
     minval=0.0,
     maxval=100.0,
     step=0.1,
     group=tws_group_defense,
     display=display.none
 )

tws_tp3_close_percent = input.float(
     15.0,
     "TP3 Position Share %",
     minval=0.0,
     maxval=100.0,
     step=0.1,
     tooltip="TP3 closes any remaining simulated position share.",
     group=tws_group_defense,
     display=display.none
 )

tws_move_to_breakeven = input.bool(
     true,
     "Move Stop to Entry After TP1",
     tooltip="Moves the active stop to entry on the candle after TP1 is reached.",
     group=tws_group_defense,
     display=display.none
 )

tws_intrabar_priority = input.string(
     "Protective First",
     "Same-Candle Priority",
     options=["Protective First", "Target First"],
     tooltip="Protective First assumes the stop is hit first. Target First assumes targets are processed first.",
     group=tws_group_defense,
     display=display.none
 )

// CHART DESIGN INPUTS

tws_theme_input = input.string(
     "Ivory Pulse",
     "Color System",
     options=["Obsidian Signal", "Carbon Grid", "Ivory Pulse", "Neon Voltage", "Acid Circuit", "Violet Flux"],
     tooltip="Switches the full visual identity. The new themes add high-contrast, crazy color packs for a more aggressive design.",
     group=tws_group_visuals,
     display=display.none
 )

tws_fvg_display_mode = input.string(
     "Selected Gap",
     "Gap Display Mode",
     options=["Hidden", "Selected Gap", "All Active Gaps"],
     tooltip="Selected Gap shows only the gap linked to the current setup. All Active Gaps displays every valid stored gap.",
     group=tws_group_visuals,
     display=display.none
 )

tws_show_executed_fvg_retests = input.bool(
     true,
     "Show Executed FVG Retests",
     tooltip="Keeps only the Fair Value Gaps that produced a confirmed retest entry. Each retained box ends on the exact entry candle.",
     group=tws_group_visuals,
     display=display.none
 )

tws_show_trade_boxes = input.bool(
     true,
     "Display TP / SL Areas",
     group=tws_group_visuals,
     display=display.none
 )

tws_show_historical_trade_boxes = input.bool(
     true,
     "Keep Completed Trade Areas",
     tooltip="Preserves completed TP and SL areas for later chart review.",
     group=tws_group_visuals,
     display=display.none,
     active=tws_show_trade_boxes
 )

tws_max_historical_trades = input.int(
     40,
     "Completed Trade History Limit",
     minval=1,
     maxval=150,
     tooltip="Limits retained completed trade areas to protect chart performance.",
     group=tws_group_visuals,
     display=display.none,
     active=tws_show_trade_boxes and tws_show_historical_trade_boxes
 )

tws_trade_projection_bars = input.int(
     35,
     "Active Area Projection",
     minval=5,
     maxval=200,
     group=tws_group_visuals,
     display=display.none
 )

tws_layout_mode = input.string(
     "Desktop",
     "Chart Layout",
     options=["Desktop", "Mobile"],
     tooltip="Mobile enlarges the dashboard and signal marker while showing only Entry, TP3 and SL price tags to reduce chart clutter.",
     group=tws_group_visuals,
     display=display.none
 )

tws_signal_label_size_input = input.string(
     "Compact",
     "Signal Label Size",
     options=["Micro", "Compact", "Standard", "Large"],
     group=tws_group_visuals,
     display=display.none
 )

tws_dashboard_size_input = input.string(
     "Compact",
     "Dashboard Size",
     options=["Micro", "Compact", "Standard"],
     group=tws_group_visuals,
     display=display.none
 )

tws_show_htf_trend = input.bool(
     false,
     "Display Bias EMA",
     group=tws_group_visuals,
     display=display.none
 )

tws_show_engine_dashboard = input.bool(
     true,
     "Display Setup Dashboard",
     tooltip="Shows confirmed bias, Blocker Lens state, Entry, TP1, TP2, TP3 and active SL prices.",
     group=tws_group_visuals,
     display=display.none
 )

// ALERT CENTER INPUTS

tws_alert_package = input.string(
     "Qualified Entries",
     "Alert Package",
     options=["Off", "Qualified Entries", "Premium Entries", "Full Lifecycle", "Webhook JSON"],
     tooltip="Qualified Entries sends confirmed entries. Premium Entries restricts entries to A/A+. Full Lifecycle adds armed, TP, breakeven and exit events. Webhook JSON sends the same lifecycle in structured JSON.",
     group=tws_group_delivery,
     display=display.none
 )

tws_alert_direction = input.string(
     "Both Directions",
     "Alert Direction",
     options=["Both Directions", "Bullish Only", "Bearish Only"],
     tooltip="Limits alert delivery without changing chart signals.",
     group=tws_group_delivery,
     display=display.none,
     active=tws_alert_package != "Off"
 )

tws_alert_minimum_grade = input.string(
     "All Qualified",
     "Minimum Alert Grade",
     options=["All Qualified", "A / A+", "A+ Only"],
     tooltip="Filters alerts by setup grade without changing the indicator's entry logic.",
     group=tws_group_delivery,
     display=display.none,
     active=tws_alert_package != "Off"
 )

tws_alert_on_armed_setup = input.bool(
     false,
     "Alert When FVG Is Armed",
     tooltip="Sends an early notification when a structure-linked FVG becomes armed. Available in Full Lifecycle and Webhook JSON packages.",
     group=tws_group_delivery,
     display=display.none,
     active=tws_alert_package == "Full Lifecycle" or tws_alert_package == "Webhook JSON"
 )

tws_alert_on_breakeven = input.bool(
     true,
     "Alert When Stop Moves to Entry",
     tooltip="Sends a lifecycle notification when TP1 has activated the breakeven rule.",
     group=tws_group_delivery,
     display=display.none,
     active=tws_alert_package == "Full Lifecycle" or tws_alert_package == "Webhook JSON"
 )

// OPERATING PROFILE RESOLUTION

bool tws_profile_balanced = tws_engine_profile == "Balanced Flow"
bool tws_profile_precision = tws_engine_profile == "Precision Flow"
bool tws_profile_scalping = tws_engine_profile == "Fast Flow"
bool tws_profile_swing = tws_engine_profile == "Position Flow"

bool tws_classic_btc = tws_classic_profile and tws_classic_preset == "Bitcoin Map"
bool tws_classic_eth = tws_classic_profile and tws_classic_preset == "Ethereum Map"
bool tws_classic_sol = tws_classic_profile and tws_classic_preset == "Solana Map"
bool tws_classic_xau = tws_classic_profile and tws_classic_preset == "Gold Map"

int tws_structure_len =
     tws_classic_profile ?
         (tws_classic_btc ? 8 : tws_classic_eth ? 9 : tws_classic_sol ? 7 : tws_classic_xau ? 12 : tws_classic_structure_len_input) :
     tws_profile_precision ? 12 :
     tws_profile_scalping ? 6 :
     tws_profile_swing ? 14 :
     tws_profile_balanced ? 8 :
     tws_structure_len_input

float tws_minimum_break_body_atr =
     tws_classic_profile ? 0.0 :
     tws_profile_precision ? 0.55 :
     tws_profile_scalping ? 0.20 :
     tws_profile_swing ? 0.45 :
     tws_profile_balanced ? 0.35 :
     tws_minimum_break_body_atr_input

float tws_break_buffer_atr =
     tws_classic_profile ? 0.0 :
     tws_profile_precision ? 0.05 :
     tws_profile_scalping ? 0.00 :
     tws_profile_swing ? 0.04 :
     tws_profile_balanced ? 0.02 :
     tws_break_buffer_atr_input

float tws_min_fvg_atr =
     tws_classic_profile ?
         (tws_classic_btc ? 0.25 : tws_classic_eth ? 0.22 : tws_classic_sol ? 0.30 : tws_classic_xau ? 0.18 : tws_classic_min_fvg_atr_input) :
     tws_profile_precision ? 0.35 :
     tws_profile_scalping ? 0.12 :
     tws_profile_swing ? 0.28 :
     tws_profile_balanced ? 0.20 :
     tws_min_fvg_atr_input

float tws_minimum_fvg_displacement =
     tws_classic_profile ? 0.0 :
     tws_profile_precision ? 0.40 :
     tws_profile_scalping ? 0.15 :
     tws_profile_swing ? 0.30 :
     tws_profile_balanced ? 0.25 :
     tws_minimum_fvg_displacement_input

float tws_minimum_zone_quality =
     tws_classic_profile ? 0.0 :
     tws_profile_precision ? 0.58 :
     tws_profile_scalping ? 0.34 :
     tws_profile_swing ? 0.50 :
     tws_profile_balanced ? 0.42 :
     tws_minimum_zone_quality_input

int tws_maximum_prior_touches =
     tws_classic_profile ? 1000000 :
     tws_profile_precision ? 0 :
     tws_profile_scalping ? 2 :
     tws_profile_swing ? 1 :
     tws_profile_balanced ? 1 :
     tws_maximum_prior_touches_input

int tws_max_fvg_age =
     tws_classic_profile ?
         (tws_classic_btc ? 160 : tws_classic_eth ? 149 : tws_classic_sol ? 196 : tws_classic_xau ? 200 : tws_classic_max_fvg_age_input) :
     tws_profile_precision ? 120 :
     tws_profile_scalping ? 90 :
     tws_profile_swing ? 240 :
     tws_profile_balanced ? 150 :
     tws_max_fvg_age_input

int tws_max_fvg_zones =
     tws_classic_profile ?
         (tws_classic_btc ? 20 : tws_classic_eth ? 14 : tws_classic_sol ? 22 : tws_classic_xau ? 25 : tws_classic_max_fvg_zones_input) :
     tws_profile_precision ? 18 :
     tws_profile_scalping ? 28 :
     tws_profile_swing ? 24 :
     tws_profile_balanced ? 24 :
     tws_max_fvg_zones_input

int tws_max_fvg_distance =
     tws_classic_profile ?
         (tws_classic_btc ? 28 : tws_classic_eth ? 30 : tws_classic_sol ? 22 : tws_classic_xau ? 35 : tws_classic_max_fvg_distance_input) :
     tws_profile_precision ? 18 :
     tws_profile_scalping ? 18 :
     tws_profile_swing ? 45 :
     tws_profile_balanced ? 30 :
     tws_max_fvg_distance_input

int tws_post_break_scan_bars =
     tws_classic_profile ? tws_classic_post_break_scan_input :
     tws_profile_precision ? 3 :
     tws_profile_scalping ? 3 :
     tws_profile_swing ? 6 :
     tws_profile_balanced ? 4 :
     tws_post_break_scan_bars_input

string tws_retest_mode =
     tws_classic_profile ? tws_classic_retest_mode_input :
     tws_profile_precision ? "Rejection Wick" :
     tws_profile_scalping ? "First Contact" :
     tws_profile_swing ? "Edge Reclaim" :
     tws_profile_balanced ? "Directional Recovery" :
     tws_retest_mode_input

float tws_touch_tolerance_percent =
     tws_classic_profile ?
         (tws_classic_btc ? 0.030 : tws_classic_eth ? 0.025 : tws_classic_sol ? 0.035 : tws_classic_xau ? 0.050 : tws_classic_touch_tolerance_input) :
     tws_profile_precision ? 0.015 :
     tws_profile_scalping ? 0.050 :
     tws_profile_swing ? 0.020 :
     tws_profile_balanced ? 0.025 :
     tws_touch_tolerance_input

float tws_minimum_reaction_score =
     tws_classic_profile ? 0.0 :
     tws_profile_precision ? 0.55 :
     tws_profile_scalping ? 0.20 :
     tws_profile_swing ? 0.45 :
     tws_profile_balanced ? 0.35 :
     tws_minimum_reaction_score_input

int tws_min_retest_delay =
     tws_classic_profile ? tws_classic_min_retest_delay_input :
     tws_profile_precision ? 2 :
     tws_profile_scalping ? 1 :
     tws_profile_swing ? 3 :
     tws_profile_balanced ? 2 :
     tws_min_retest_delay_input

int tws_max_bars_to_wait =
     tws_classic_profile ?
         (tws_classic_btc ? 18 : tws_classic_eth ? 20 : tws_classic_sol ? 14 : tws_classic_xau ? 25 : tws_classic_max_bars_to_wait_input) :
     tws_profile_precision ? 14 :
     tws_profile_scalping ? 10 :
     tws_profile_swing ? 32 :
     tws_profile_balanced ? 20 :
     tws_max_bars_to_wait_input

float tws_volume_multiplier =
     tws_classic_profile ?
         (tws_classic_btc ? 1.00 : tws_classic_eth ? 1.05 : tws_classic_sol ? 1.15 : tws_classic_xau ? 0.90 : tws_classic_volume_multiplier_input) :
     tws_profile_precision ? 1.20 :
     tws_profile_scalping ? 0.80 :
     tws_profile_swing ? 1.00 :
     tws_profile_balanced ? 1.00 :
     tws_volume_multiplier_input

float tws_minimum_adx =
     tws_classic_profile ? tws_classic_minimum_adx_input :
     tws_profile_precision ? 18.0 :
     tws_profile_scalping ? 8.0 :
     tws_profile_swing ? 14.0 :
     tws_profile_balanced ? 10.0 :
     tws_minimum_adx_input

string tws_minimum_grade =
     tws_profile_precision ? "A Grade or Better" :
     tws_profile_scalping ? "B Grade or Better" :
     tws_profile_swing ? "A Grade or Better" :
     tws_profile_balanced ? "B Grade or Better" :
     tws_minimum_grade_input

float tws_minimum_stop_percent =
     tws_classic_profile ?
         (tws_classic_btc ? 1.20 : tws_classic_eth ? 1.10 : tws_classic_sol ? 1.50 : tws_classic_xau ? 0.35 : tws_classic_minimum_stop_input) :
     tws_profile_precision ? 0.90 :
     tws_profile_scalping ? 0.35 :
     tws_profile_swing ? 1.20 :
     tws_profile_balanced ? 0.80 :
     tws_minimum_stop_percent_input

// THEME RESOLUTION

bool tws_theme_obsidian = tws_theme_input == "Obsidian Signal"
bool tws_theme_terminal = tws_theme_input == "Carbon Grid"
bool tws_theme_ivory = tws_theme_input == "Ivory Pulse"
bool tws_theme_neon = tws_theme_input == "Neon Voltage"
bool tws_theme_toxic = tws_theme_input == "Acid Circuit"
bool tws_theme_ultra = tws_theme_input == "Violet Flux"

bool tws_is_dark_theme = not tws_theme_ivory
bool tws_header_dark_text = tws_theme_terminal or tws_theme_toxic
bool tws_label_dark_text = tws_theme_obsidian or tws_theme_terminal or tws_theme_ivory or tws_theme_toxic

color tws_panel_color =
     tws_theme_obsidian ? color.rgb(8, 8, 10) :
     tws_theme_terminal ? color.rgb(0, 0, 0) :
     tws_theme_ivory ? color.rgb(246, 243, 239) :
     tws_theme_neon ? color.rgb(14, 8, 26) :
     tws_theme_toxic ? color.rgb(10, 14, 8) :
     color.rgb(17, 8, 34)

color tws_panel_alt_color =
     tws_theme_obsidian ? color.rgb(18, 18, 22) :
     tws_theme_terminal ? color.rgb(14, 14, 16) :
     tws_theme_ivory ? color.rgb(226, 221, 216) :
     tws_theme_neon ? color.rgb(26, 14, 42) :
     tws_theme_toxic ? color.rgb(18, 24, 14) :
     color.rgb(28, 16, 50)

color tws_border_color =
     tws_theme_obsidian ? color.rgb(224, 22, 48) :
     tws_theme_terminal ? color.rgb(245, 245, 245) :
     tws_theme_ivory ? color.rgb(180, 12, 36) :
     tws_theme_neon ? color.rgb(0, 245, 255) :
     tws_theme_toxic ? color.rgb(214, 255, 64) :
     color.rgb(173, 85, 255)

color tws_primary_text_color =
     tws_is_dark_theme ? color.rgb(248, 248, 248) : color.rgb(18, 18, 20)

color tws_muted_text_color =
     tws_theme_obsidian ? color.rgb(145, 145, 152) :
     tws_theme_terminal ? color.rgb(170, 170, 176) :
     tws_theme_ivory ? color.rgb(96, 92, 90) :
     tws_theme_neon ? color.rgb(214, 175, 255) :
     tws_theme_toxic ? color.rgb(174, 210, 120) :
     color.rgb(198, 174, 255)

color tws_bullish_color =
     tws_theme_obsidian ? color.rgb(242, 242, 244) :
     tws_theme_terminal ? color.rgb(242, 242, 244) :
     tws_theme_ivory ? color.rgb(20, 20, 22) :
     tws_theme_neon ? color.rgb(255, 70, 200) :
     tws_theme_toxic ? color.rgb(214, 255, 64) :
     color.rgb(122, 245, 255)

color tws_bearish_color =
     tws_theme_obsidian ? color.rgb(224, 22, 48) :
     tws_theme_terminal ? color.rgb(224, 22, 48) :
     tws_theme_ivory ? color.rgb(224, 22, 48) :
     tws_theme_neon ? color.rgb(0, 245, 255) :
     tws_theme_toxic ? color.rgb(255, 106, 0) :
     color.rgb(255, 86, 166)

color tws_entry_color =
     tws_theme_obsidian ? color.white :
     tws_theme_terminal ? color.white :
     tws_theme_ivory ? color.rgb(18, 18, 20) :
     tws_theme_neon ? color.rgb(255, 240, 84) :
     tws_theme_toxic ? color.rgb(255, 255, 255) :
     color.rgb(255, 255, 255)

color tws_stop_color =
     tws_theme_obsidian ? color.rgb(224, 22, 48) :
     tws_theme_terminal ? color.rgb(224, 22, 48) :
     tws_theme_ivory ? color.rgb(224, 22, 48) :
     tws_theme_neon ? color.rgb(255, 120, 0) :
     tws_theme_toxic ? color.rgb(255, 64, 64) :
     color.rgb(255, 86, 166)

color tws_breakeven_color =
     tws_theme_obsidian ? color.rgb(190, 190, 196) :
     tws_theme_terminal ? color.rgb(190, 190, 196) :
     tws_theme_ivory ? color.rgb(65, 65, 70) :
     tws_theme_neon ? color.rgb(168, 255, 71) :
     tws_theme_toxic ? color.rgb(0, 255, 209) :
     color.rgb(183, 153, 255)

color tws_closed_profit_fill = tws_theme_neon ? color.rgb(36, 14, 58) : tws_theme_toxic ? color.rgb(24, 30, 14) : tws_theme_ultra ? color.rgb(28, 16, 50) : color.rgb(12, 12, 15)
color tws_closed_loss_fill = tws_stop_color
color tws_closed_flat_fill = tws_theme_neon ? color.rgb(48, 30, 68) : tws_theme_toxic ? color.rgb(46, 54, 28) : tws_theme_ultra ? color.rgb(44, 30, 70) : color.rgb(52, 52, 58)
color tws_grade_a_plus_color = tws_border_color
color tws_grade_a_color = tws_bullish_color
color tws_grade_b_color = tws_is_dark_theme ? color.rgb(165, 165, 172) : color.rgb(85, 85, 90)
color tws_filtered_color = tws_muted_text_color

color tws_bull_fvg_fill = color.new(tws_bullish_color, tws_theme_neon or tws_theme_toxic or tws_theme_ultra ? 88 : 93)
color tws_bear_fvg_fill = color.new(tws_bearish_color, tws_theme_neon or tws_theme_toxic or tws_theme_ultra ? 84 : 89)
// Dedicated TP palette. This is intentionally separated from bullish signal colors
// so the reward zone, target lines and TP labels remain vivid in every theme.
color tws_target_guide_color =
     tws_theme_obsidian ? color.rgb(38, 154, 255) :
     tws_theme_terminal ? color.rgb(0, 191, 255) :
     tws_theme_ivory ? color.rgb(45, 135, 255) :
     tws_theme_neon ? color.rgb(0, 225, 255) :
     tws_theme_toxic ? color.rgb(60, 170, 255) :
     color.rgb(92, 142, 255)

// TP price labels deliberately use a darker blue than the reward zone.
// This keeps labels readable and visually separated from the box itself.
color tws_target_label_fill =
     tws_theme_obsidian ? color.rgb(12, 54, 118) :
     tws_theme_terminal ? color.rgb(0, 58, 92) :
     tws_theme_ivory ? color.rgb(24, 72, 145) :
     tws_theme_neon ? color.rgb(20, 42, 112) :
     tws_theme_toxic ? color.rgb(22, 64, 132) :
     color.rgb(45, 34, 124)

color tws_reward_fill = color.new(
     tws_target_guide_color,
     tws_theme_ivory ? 80 : tws_theme_neon or tws_theme_toxic or tws_theme_ultra ? 82 : 84
 )

color tws_risk_fill =
     tws_theme_obsidian ? color.new(tws_bearish_color, 88) :
     tws_theme_terminal ? color.new(tws_bearish_color, 88) :
     tws_theme_ivory ? color.new(tws_bearish_color, 86) :
     tws_theme_neon ? color.new(color.rgb(255, 120, 0), 84) :
     tws_theme_toxic ? color.new(color.rgb(255, 64, 64), 84) :
     color.new(color.rgb(255, 86, 166), 84)
int tws_box_border_width = tws_theme_neon or tws_theme_toxic or tws_theme_ultra ? 2 : 1
int tws_major_line_width = tws_theme_neon or tws_theme_toxic or tws_theme_ultra ? 3 : 2
int tws_minor_line_width = tws_theme_neon or tws_theme_toxic or tws_theme_ultra ? 2 : 1

bool tws_mobile_layout = tws_layout_mode == "Mobile"
bool tws_live_preview_mode = tws_signal_timing_mode == "Live Preview"

string tws_signal_label_size =
     tws_mobile_layout ? size.normal :
     tws_signal_label_size_input == "Micro" ? size.tiny :
     tws_signal_label_size_input == "Standard" ? size.normal :
     tws_signal_label_size_input == "Large" ? size.large :
     size.small

string tws_dashboard_text_size =
     tws_mobile_layout ? size.normal :
     tws_dashboard_size_input == "Micro" ? size.tiny :
     tws_dashboard_size_input == "Standard" ? size.normal :
     size.small

// MARKET DATA LAYER

float tws_atr = ta.atr(tws_atr_length)
float tws_volume_average = ta.sma(volume, tws_volume_length)
bool tws_volume_available = not na(volume) and not na(tws_volume_average) and tws_volume_average > 0

[tws_plus_di, tws_minus_di, tws_adx_value] = ta.dmi(tws_di_length, tws_adx_smoothing)

float tws_htf_close = request.security(
     syminfo.tickerid,
     tws_htf_timeframe,
     close[1],
     barmerge.gaps_off,
     barmerge.lookahead_on
 )

float tws_htf_fast_ema = request.security(
     syminfo.tickerid,
     tws_htf_timeframe,
     ta.ema(close, tws_htf_fast_length)[1],
     barmerge.gaps_off,
     barmerge.lookahead_on
 )

float tws_htf_slow_ema = request.security(
     syminfo.tickerid,
     tws_htf_timeframe,
     ta.ema(close, tws_htf_slow_length)[1],
     barmerge.gaps_off,
     barmerge.lookahead_on
 )

float tws_chart_seconds = timeframe.in_seconds()
float tws_selected_htf_seconds = timeframe.in_seconds(tws_htf_timeframe)

bool tws_valid_higher_timeframe =
     na(tws_chart_seconds) or
     na(tws_selected_htf_seconds) or
     tws_selected_htf_seconds > tws_chart_seconds

plot(
     tws_show_htf_trend and tws_valid_higher_timeframe ? tws_htf_fast_ema : na,
     title="Bias Fast EMA",
     color=color.new(tws_border_color, 15),
     linewidth=2,
     display=display.pane
 )

// INTERNAL UTILITIES

tws_bound(float tws_value, float tws_minimum, float tws_maximum) =>
    math.max(tws_minimum, math.min(tws_maximum, tws_value))

tws_weighted_result(
     int tws_direction,
     float tws_entry_price,
     float tws_exit_price,
     float tws_close_percent
 ) =>
    float tws_fraction = tws_close_percent / 100.0
    float tws_price_change =
         tws_direction == 1 ?
         (tws_exit_price - tws_entry_price) / tws_entry_price :
         (tws_entry_price - tws_exit_price) / tws_entry_price

    tws_price_change * tws_fraction

tws_quality_tier(float tws_score) =>
    tws_score >= 0.82 ? "A+" :
     tws_score >= 0.68 ? "A" :
     tws_score >= 0.55 ? "B" :
     "FILTERED"

tws_tier_allowed(string tws_grade, string tws_required_grade) =>
    tws_required_grade == "A+ Only" ? tws_grade == "A+" :
     tws_required_grade == "A Grade or Better" ? tws_grade == "A+" or tws_grade == "A" :
     tws_grade == "A+" or tws_grade == "A" or tws_grade == "B"

tws_tier_color(string tws_grade) =>
    tws_grade == "A+" ? tws_grade_a_plus_color :
     tws_grade == "A" ? tws_grade_a_color :
     tws_grade == "B" ? tws_grade_b_color :
     tws_filtered_color

tws_alert_grade_allowed(string tws_grade, string tws_required_grade) =>
    tws_required_grade == "A+ Only" ? tws_grade == "A+" :
     tws_required_grade == "A / A+" ? tws_grade == "A+" or tws_grade == "A" :
     tws_grade == "A+" or tws_grade == "A" or tws_grade == "B"

tws_alert_direction_allowed(int tws_direction, string tws_direction_filter) =>
    tws_direction_filter == "Bullish Only" ? tws_direction == 1 :
     tws_direction_filter == "Bearish Only" ? tws_direction == -1 :
     true

tws_filter_status(bool tws_enabled, bool tws_available, bool tws_passed) =>
    not tws_enabled ? "BYPASS" :
     not tws_available ? "NO DATA" :
     tws_passed ? "PASS" :
     "BLOCK"

tws_zone_contact(
     int tws_direction,
     float tws_zone_top,
     float tws_zone_bottom,
     string tws_selected_mode,
     float tws_tolerance
 ) =>
    float tws_zone_mid = (tws_zone_top + tws_zone_bottom) / 2.0
    float tws_body_high = math.max(open, close)
    float tws_body_low = math.min(open, close)
    float tws_candle_range = math.max(high - low, syminfo.mintick)
    float tws_lower_wick = math.min(open, close) - low
    float tws_upper_wick = high - math.max(open, close)

    bool tws_wick_overlap =
         low <= tws_zone_top + tws_tolerance and
         high >= tws_zone_bottom - tws_tolerance

    bool tws_body_overlap =
         tws_body_low <= tws_zone_top + tws_tolerance and
         tws_body_high >= tws_zone_bottom - tws_tolerance

    bool tws_directional_recovery =
         tws_direction == 1 ?
         tws_wick_overlap and close >= tws_zone_mid and close > open :
         tws_wick_overlap and close <= tws_zone_mid and close < open

    bool tws_boundary_reclaim =
         tws_direction == 1 ?
         low <= tws_zone_top + tws_tolerance and close > tws_zone_top :
         high >= tws_zone_bottom - tws_tolerance and close < tws_zone_bottom

    bool tws_strict_rejection =
         tws_direction == 1 ?
         tws_boundary_reclaim and close > open and tws_lower_wick / tws_candle_range >= 0.30 :
         tws_boundary_reclaim and close < open and tws_upper_wick / tws_candle_range >= 0.30

    tws_selected_mode == "First Contact" ? tws_wick_overlap :
     tws_selected_mode == "Directional Recovery" ? tws_directional_recovery or (tws_body_overlap and tws_boundary_reclaim) :
     tws_selected_mode == "Edge Reclaim" ? tws_boundary_reclaim :
     tws_strict_rejection

tws_classic_zone_contact(
     int tws_direction,
     float tws_zone_top,
     float tws_zone_bottom,
     string tws_selected_mode,
     float tws_tolerance
 ) =>
    float tws_body_high = math.max(open, close)
    float tws_body_low = math.min(open, close)

    bool tws_wick_touch =
         low <= tws_zone_top + tws_tolerance and
         high >= tws_zone_bottom - tws_tolerance

    bool tws_body_touch =
         tws_body_low <= tws_zone_top + tws_tolerance and
         tws_body_high >= tws_zone_bottom - tws_tolerance

    bool tws_close_inside =
         close <= tws_zone_top + tws_tolerance and
         close >= tws_zone_bottom - tws_tolerance

    bool tws_mixed_long =
         low <= tws_zone_top + tws_tolerance and
         close > tws_zone_top and
         close > open

    bool tws_mixed_short =
         high >= tws_zone_bottom - tws_tolerance and
         close < tws_zone_bottom and
         close < open

    tws_selected_mode == "Any Wick Contact" ? tws_wick_touch :
     tws_selected_mode == "Real Body Contact" ? tws_body_touch :
     tws_selected_mode == "Close Within Gap" ? tws_close_inside :
     tws_direction == 1 ? tws_mixed_long : tws_mixed_short

tws_return_strength(
     int tws_direction,
     float tws_zone_top,
     float tws_zone_bottom
 ) =>
    float tws_candle_range = math.max(high - low, syminfo.mintick)
    float tws_body_size = math.abs(close - open)
    float tws_lower_wick = math.min(open, close) - low
    float tws_upper_wick = high - math.max(open, close)
    float tws_close_location = tws_direction == 1 ? (close - low) / tws_candle_range : (high - close) / tws_candle_range
    float tws_wick_quality = tws_direction == 1 ? tws_lower_wick / tws_candle_range : tws_upper_wick / tws_candle_range
    float tws_body_quality = tws_bound(tws_body_size / math.max(tws_atr * 0.75, syminfo.mintick), 0.0, 1.0)
    float tws_directional_quality = tws_direction == 1 ? (close > open ? 1.0 : 0.0) : (close < open ? 1.0 : 0.0)
    float tws_zone_height = math.max(tws_zone_top - tws_zone_bottom, syminfo.mintick)
    float tws_penetration = tws_direction == 1 ? tws_bound((tws_zone_top - low) / tws_zone_height, 0.0, 1.0) : tws_bound((high - tws_zone_bottom) / tws_zone_height, 0.0, 1.0)
    float tws_penetration_quality = 1.0 - math.abs(tws_penetration - 0.50) * 2.0

    tws_bound(
         tws_close_location * 0.25 +
         tws_wick_quality * 0.25 +
         tws_body_quality * 0.20 +
         tws_directional_quality * 0.20 +
         tws_bound(tws_penetration_quality, 0.0, 1.0) * 0.10,
         0.0,
         1.0
     )

// STRUCTURE MAP

float tws_pivot_high = ta.pivothigh(high, tws_structure_len, tws_structure_len)
float tws_pivot_low = ta.pivotlow(low, tws_structure_len, tws_structure_len)

var float tws_last_swing_high = na
var float tws_last_swing_low = na
var int tws_last_swing_high_bar = na
var int tws_last_swing_low_bar = na
var bool tws_swing_high_broken = false
var bool tws_swing_low_broken = false
var int tws_structure_bias = 0

if not na(tws_pivot_high)
    tws_last_swing_high := tws_pivot_high
    tws_last_swing_high_bar := bar_index - tws_structure_len
    tws_swing_high_broken := false

if not na(tws_pivot_low)
    tws_last_swing_low := tws_pivot_low
    tws_last_swing_low_bar := bar_index - tws_structure_len
    tws_swing_low_broken := false

float tws_break_body_atr = tws_atr > 0 ? math.abs(close - open) / tws_atr : 0.0
float tws_bullish_break_level = not na(tws_last_swing_high) ? tws_last_swing_high + tws_atr * tws_break_buffer_atr : na
float tws_bearish_break_level = not na(tws_last_swing_low) ? tws_last_swing_low - tws_atr * tws_break_buffer_atr : na

bool tws_bullish_price_break =
     not na(tws_last_swing_high) and
     not tws_swing_high_broken and
     (
         tws_require_body_close ?
         close > tws_bullish_break_level and close[1] <= tws_bullish_break_level :
         high > tws_bullish_break_level and high[1] <= tws_bullish_break_level
     )

bool tws_bearish_price_break =
     not na(tws_last_swing_low) and
     not tws_swing_low_broken and
     (
         tws_require_body_close ?
         close < tws_bearish_break_level and close[1] >= tws_bearish_break_level :
         low < tws_bearish_break_level and low[1] >= tws_bearish_break_level
     )

bool tws_bullish_break = tws_bullish_price_break and (tws_classic_profile or not tws_use_break_displacement or tws_break_body_atr >= tws_minimum_break_body_atr)
bool tws_bearish_break = tws_bearish_price_break and (tws_classic_profile or not tws_use_break_displacement or tws_break_body_atr >= tws_minimum_break_body_atr)

float tws_bullish_break_expansion = tws_bullish_break and tws_atr > 0 ? math.max(close - tws_last_swing_high, 0.0) / tws_atr : 0.0
float tws_bearish_break_expansion = tws_bearish_break and tws_atr > 0 ? math.max(tws_last_swing_low - close, 0.0) / tws_atr : 0.0

float tws_bullish_break_strength = tws_bound(tws_bound(tws_break_body_atr / 1.50, 0.0, 1.0) * 0.65 + tws_bound(tws_bullish_break_expansion / 0.50, 0.0, 1.0) * 0.35, 0.0, 1.0)
float tws_bearish_break_strength = tws_bound(tws_bound(tws_break_body_atr / 1.50, 0.0, 1.0) * 0.65 + tws_bound(tws_bearish_break_expansion / 0.50, 0.0, 1.0) * 0.35, 0.0, 1.0)

string tws_bullish_break_type = tws_structure_bias == -1 ? "CHoCH" : "BOS"
string tws_bearish_break_type = tws_structure_bias == 1 ? "CHoCH" : "BOS"

if barstate.isconfirmed and tws_bullish_break
    tws_swing_high_broken := true
    tws_structure_bias := 1

    if tws_show_structure
        label.new(
             bar_index,
             high,
             "BULLISH " + tws_bullish_break_type + "\nQ " + str.tostring(tws_bullish_break_strength * 100.0, "#") + "%",
             style=label.style_label_down,
             color=tws_target_guide_color,
             textcolor=tws_label_dark_text ? color.black : color.white,
             size=size.tiny,
             tooltip="Structure confirmation\nConfirmed bullish " + tws_bullish_break_type + "\nBreak quality: " + str.tostring(tws_bullish_break_strength * 100.0, "#.0") + "%",
             text_formatting=text.format_bold + text.format_italic
         )

if barstate.isconfirmed and tws_bearish_break
    tws_swing_low_broken := true
    tws_structure_bias := -1

    if tws_show_structure
        label.new(
             bar_index,
             low,
             "BEARISH " + tws_bearish_break_type + "\nQ " + str.tostring(tws_bearish_break_strength * 100.0, "#") + "%",
             style=label.style_label_up,
             color=tws_bearish_color,
             textcolor=color.white,
             size=size.tiny,
             tooltip="Structure confirmation\nConfirmed bearish " + tws_bearish_break_type + "\nBreak quality: " + str.tostring(tws_bearish_break_strength * 100.0, "#.0") + "%",
             text_formatting=text.format_bold + text.format_italic
         )

// FVG MEMORY & QUALITY DATA

var float[] tws_fvg_tops = array.new_float()
var float[] tws_fvg_bottoms = array.new_float()
var int[] tws_fvg_directions = array.new_int()
var int[] tws_fvg_birth_bars = array.new_int()
var float[] tws_fvg_displacement_scores = array.new_float()
var float[] tws_fvg_volume_scores = array.new_float()
var int[] tws_fvg_touch_counts = array.new_int()
var bool[] tws_fvg_was_touching = array.new_bool()
var box[] tws_fvg_boxes = array.new_box()

bool tws_bullish_fvg = bar_index >= 2 and low > high[2]
bool tws_bearish_fvg = bar_index >= 2 and high < low[2]

float tws_bullish_fvg_top = low
float tws_bullish_fvg_bottom = high[2]
float tws_bearish_fvg_top = low[2]
float tws_bearish_fvg_bottom = high

float tws_bullish_fvg_size = tws_bullish_fvg_top - tws_bullish_fvg_bottom
float tws_bearish_fvg_size = tws_bearish_fvg_top - tws_bearish_fvg_bottom

float tws_formation_atr = math.max(nz(tws_atr[1], tws_atr), syminfo.mintick)
float tws_formation_body = math.abs(close[1] - open[1])
float tws_formation_displacement_score = tws_bound(tws_formation_body / (tws_formation_atr * 1.50), 0.0, 1.0)
float tws_formation_volume_score = tws_volume_available and not na(tws_volume_average[1]) and tws_volume_average[1] > 0 ? tws_bound(volume[1] / (tws_volume_average[1] * 2.0), 0.0, 1.0) : 0.50

bool tws_valid_bullish_fvg =
     tws_bullish_fvg and
     tws_bullish_fvg_size >= tws_atr * tws_min_fvg_atr and
     (tws_classic_profile or not tws_use_fvg_displacement_filter or tws_formation_displacement_score >= tws_minimum_fvg_displacement)

bool tws_valid_bearish_fvg =
     tws_bearish_fvg and
     tws_bearish_fvg_size >= tws_atr * tws_min_fvg_atr and
     (tws_classic_profile or not tws_use_fvg_displacement_filter or tws_formation_displacement_score >= tws_minimum_fvg_displacement)

bool tws_show_all_fvgs = tws_fvg_display_mode == "All Active Gaps"

if barstate.isconfirmed and tws_valid_bullish_fvg
    box tws_bullish_box = box.new(
         left=bar_index - 2,
         top=tws_bullish_fvg_top,
         right=bar_index,
         bottom=tws_bullish_fvg_bottom,
         xloc=xloc.bar_index,
         bgcolor=tws_show_all_fvgs ? tws_bull_fvg_fill : color.new(tws_bullish_color, 100),
         border_color=tws_show_all_fvgs ? color.new(tws_bullish_color, 55) : color.new(tws_bullish_color, 100),
         border_width=1
     )

    array.push(tws_fvg_tops, tws_bullish_fvg_top)
    array.push(tws_fvg_bottoms, tws_bullish_fvg_bottom)
    array.push(tws_fvg_directions, 1)
    array.push(tws_fvg_birth_bars, bar_index)
    array.push(tws_fvg_displacement_scores, tws_formation_displacement_score)
    array.push(tws_fvg_volume_scores, tws_formation_volume_score)
    array.push(tws_fvg_touch_counts, 0)
    array.push(tws_fvg_was_touching, false)
    array.push(tws_fvg_boxes, tws_bullish_box)

if barstate.isconfirmed and tws_valid_bearish_fvg
    box tws_bearish_box = box.new(
         left=bar_index - 2,
         top=tws_bearish_fvg_top,
         right=bar_index,
         bottom=tws_bearish_fvg_bottom,
         xloc=xloc.bar_index,
         bgcolor=tws_show_all_fvgs ? tws_bear_fvg_fill : color.new(tws_bearish_color, 100),
         border_color=tws_show_all_fvgs ? color.new(tws_bearish_color, 55) : color.new(tws_bearish_color, 100),
         border_width=1
     )

    array.push(tws_fvg_tops, tws_bearish_fvg_top)
    array.push(tws_fvg_bottoms, tws_bearish_fvg_bottom)
    array.push(tws_fvg_directions, -1)
    array.push(tws_fvg_birth_bars, bar_index)
    array.push(tws_fvg_displacement_scores, tws_formation_displacement_score)
    array.push(tws_fvg_volume_scores, tws_formation_volume_score)
    array.push(tws_fvg_touch_counts, 0)
    array.push(tws_fvg_was_touching, false)
    array.push(tws_fvg_boxes, tws_bearish_box)

// IMBALANCE MEMORY MAINTENANCE & TOUCH TRACKING

int tws_cleanup_index = array.size(tws_fvg_tops) - 1

while tws_cleanup_index >= 0
    float tws_stored_top = array.get(tws_fvg_tops, tws_cleanup_index)
    float tws_stored_bottom = array.get(tws_fvg_bottoms, tws_cleanup_index)
    int tws_stored_direction = array.get(tws_fvg_directions, tws_cleanup_index)
    int tws_stored_birth = array.get(tws_fvg_birth_bars, tws_cleanup_index)
    int tws_stored_touch_count = array.get(tws_fvg_touch_counts, tws_cleanup_index)
    bool tws_was_touching = array.get(tws_fvg_was_touching, tws_cleanup_index)
    box tws_stored_box = array.get(tws_fvg_boxes, tws_cleanup_index)

    bool tws_touching_now =
         bar_index > tws_stored_birth and
         low <= tws_stored_top and
         high >= tws_stored_bottom

    if barstate.isconfirmed and tws_touching_now and not tws_was_touching
        tws_stored_touch_count += 1
        array.set(tws_fvg_touch_counts, tws_cleanup_index, tws_stored_touch_count)

    array.set(tws_fvg_was_touching, tws_cleanup_index, tws_touching_now)

    bool tws_expired = bar_index - tws_stored_birth > tws_max_fvg_age
    bool tws_invalidated =
         barstate.isconfirmed and
         tws_remove_invalid_fvgs and
         (
             tws_stored_direction == 1 ?
             close < tws_stored_bottom :
             close > tws_stored_top
         )

    if tws_expired or tws_invalidated
        box.delete(tws_stored_box)
        array.remove(tws_fvg_tops, tws_cleanup_index)
        array.remove(tws_fvg_bottoms, tws_cleanup_index)
        array.remove(tws_fvg_directions, tws_cleanup_index)
        array.remove(tws_fvg_birth_bars, tws_cleanup_index)
        array.remove(tws_fvg_displacement_scores, tws_cleanup_index)
        array.remove(tws_fvg_volume_scores, tws_cleanup_index)
        array.remove(tws_fvg_touch_counts, tws_cleanup_index)
        array.remove(tws_fvg_was_touching, tws_cleanup_index)
        array.remove(tws_fvg_boxes, tws_cleanup_index)
    else
        box.set_right(tws_stored_box, bar_index)
        box.set_bgcolor(tws_stored_box, tws_show_all_fvgs ? tws_stored_direction == 1 ? tws_bull_fvg_fill : tws_bear_fvg_fill : color.new(color.black, 100))
        box.set_border_color(tws_stored_box, tws_show_all_fvgs ? color.new(tws_stored_direction == 1 ? tws_bullish_color : tws_bearish_color, 55) : color.new(color.black, 100))

    tws_cleanup_index -= 1

while array.size(tws_fvg_tops) > tws_max_fvg_zones
    box tws_oldest_box = array.shift(tws_fvg_boxes)
    box.delete(tws_oldest_box)
    array.shift(tws_fvg_tops)
    array.shift(tws_fvg_bottoms)
    array.shift(tws_fvg_directions)
    array.shift(tws_fvg_birth_bars)
    array.shift(tws_fvg_displacement_scores)
    array.shift(tws_fvg_volume_scores)
    array.shift(tws_fvg_touch_counts)
    array.shift(tws_fvg_was_touching)

// STRUCTURE EVENT QUEUE

var bool tws_pending_break = false
var int tws_pending_direction = 0
var int tws_pending_break_bar = na
var float tws_pending_break_price = na
var float tws_pending_break_strength = na
var string tws_pending_break_type = "—"

bool tws_armed_event = false
bool tws_no_eligible_fvg_event = false
bool tws_setup_expired_event = false
bool tws_fvg_invalidated_event = false

var bool tws_setup_armed = false
var int tws_armed_direction = 0
var int tws_armed_break_bar = na
var int tws_armed_fvg_birth_bar = na
var float tws_armed_top = na
var float tws_armed_bottom = na
var float tws_armed_score = na
var int tws_armed_stars = 0
var int tws_armed_prior_touches = 0
var string tws_armed_break_type = "—"
var float tws_armed_break_strength = na

var box tws_selected_fvg_box = na
var int tws_last_trade_close_bar = na

bool tws_cooldown_complete = na(tws_last_trade_close_bar) or bar_index - tws_last_trade_close_bar >= tws_cooldown_after_close

if barstate.isconfirmed and tws_bullish_break and tws_allow_longs and tws_cooldown_complete
    tws_pending_break := true
    tws_pending_direction := 1
    tws_pending_break_bar := bar_index
    tws_pending_break_price := tws_last_swing_high
    tws_pending_break_strength := tws_bullish_break_strength
    tws_pending_break_type := tws_bullish_break_type
    tws_setup_armed := false

    if not na(tws_selected_fvg_box)
        box.delete(tws_selected_fvg_box)
        tws_selected_fvg_box := na

if barstate.isconfirmed and tws_bearish_break and tws_allow_shorts and tws_cooldown_complete
    tws_pending_break := true
    tws_pending_direction := -1
    tws_pending_break_bar := bar_index
    tws_pending_break_price := tws_last_swing_low
    tws_pending_break_strength := tws_bearish_break_strength
    tws_pending_break_type := tws_bearish_break_type
    tws_setup_armed := false

    if not na(tws_selected_fvg_box)
        box.delete(tws_selected_fvg_box)
        tws_selected_fvg_box := na

// MULTI-FACTOR FVG SCORING

int tws_range_lookback = math.max(tws_structure_len * 4, 20)
float tws_dealing_range_high = ta.highest(high, tws_range_lookback)
float tws_dealing_range_low = ta.lowest(low, tws_range_lookback)
float tws_dealing_range_mid = (tws_dealing_range_high + tws_dealing_range_low) / 2.0
float tws_dealing_range_half = math.max((tws_dealing_range_high - tws_dealing_range_low) / 2.0, syminfo.mintick)

if tws_pending_break and not tws_setup_armed
    bool tws_pending_expired = bar_index - tws_pending_break_bar > tws_post_break_scan_bars

    if tws_pending_expired
        tws_pending_break := false
        tws_no_eligible_fvg_event := barstate.isconfirmed
    else
        float tws_best_score = na
        int tws_best_index = na
        int tws_candidate_index = 0

        while tws_candidate_index < array.size(tws_fvg_tops)
            float tws_candidate_top = array.get(tws_fvg_tops, tws_candidate_index)
            float tws_candidate_bottom = array.get(tws_fvg_bottoms, tws_candidate_index)
            int tws_candidate_direction = array.get(tws_fvg_directions, tws_candidate_index)
            int tws_candidate_birth = array.get(tws_fvg_birth_bars, tws_candidate_index)
            float tws_candidate_displacement = array.get(tws_fvg_displacement_scores, tws_candidate_index)
            float tws_candidate_volume = array.get(tws_fvg_volume_scores, tws_candidate_index)
            int tws_candidate_touches = array.get(tws_fvg_touch_counts, tws_candidate_index)

            bool tws_direction_matches = tws_candidate_direction == tws_pending_direction
            bool tws_within_distance = tws_candidate_birth >= tws_pending_break_bar - tws_max_fvg_distance and tws_candidate_birth <= bar_index
            bool tws_touch_quality_pass = tws_classic_profile or tws_candidate_touches <= tws_maximum_prior_touches

            if tws_direction_matches and tws_within_distance and tws_touch_quality_pass
                float tws_zone_height = tws_candidate_top - tws_candidate_bottom
                float tws_zone_center = (tws_candidate_top + tws_candidate_bottom) / 2.0
                float tws_break_distance = math.abs(tws_zone_center - tws_pending_break_price)
                float tws_timing_distance = math.abs(tws_candidate_birth - tws_pending_break_bar)

                float tws_timing_score = 1.0 - tws_bound(tws_timing_distance / math.max(tws_max_fvg_distance, 1), 0.0, 1.0)
                float tws_size_score = tws_bound(tws_zone_height / math.max(tws_atr * 1.50, syminfo.mintick), 0.0, 1.0)
                float tws_proximity_score = 1.0 - tws_bound(tws_break_distance / math.max(tws_atr * 5.0, syminfo.mintick), 0.0, 1.0)
                float tws_freshness_score = 1.0 - tws_bound((bar_index - tws_candidate_birth) / math.max(tws_max_fvg_age, 1), 0.0, 1.0)

                bool tws_favorable_location = tws_candidate_direction == 1 ? tws_zone_center <= tws_dealing_range_mid : tws_zone_center >= tws_dealing_range_mid
                float tws_location_distance = tws_bound(math.abs(tws_zone_center - tws_dealing_range_mid) / tws_dealing_range_half, 0.0, 1.0)
                float tws_location_score = tws_favorable_location ? 0.65 + tws_location_distance * 0.35 : (1.0 - tws_location_distance) * 0.35

                float tws_untouched_score = 1.0 - tws_bound(tws_candidate_touches / math.max(tws_maximum_prior_touches + 1.0, 1.0), 0.0, 1.0)

                float tws_candidate_score =
                     tws_classic_profile ?
                     (
                         tws_timing_score * 0.30 +
                         tws_size_score * 0.25 +
                         tws_proximity_score * 0.30 +
                         tws_freshness_score * 0.15
                     ) :
                     (
                         tws_proximity_score * 0.18 +
                         tws_timing_score * 0.12 +
                         tws_size_score * 0.12 +
                         tws_freshness_score * 0.10 +
                         tws_candidate_displacement * 0.16 +
                         tws_candidate_volume * 0.08 +
                         tws_location_score * 0.12 +
                         tws_untouched_score * 0.06 +
                         nz(tws_pending_break_strength, 0.50) * 0.06
                     )

                bool tws_candidate_quality_pass = tws_classic_profile or tws_candidate_score >= tws_minimum_zone_quality

                if tws_candidate_quality_pass and (na(tws_best_score) or tws_candidate_score > tws_best_score)
                    tws_best_score := tws_candidate_score
                    tws_best_index := tws_candidate_index

            tws_candidate_index += 1

        if not na(tws_best_index) and barstate.isconfirmed
            tws_armed_top := array.get(tws_fvg_tops, tws_best_index)
            tws_armed_bottom := array.get(tws_fvg_bottoms, tws_best_index)
            tws_armed_direction := array.get(tws_fvg_directions, tws_best_index)
            tws_armed_fvg_birth_bar := array.get(tws_fvg_birth_bars, tws_best_index)
            tws_armed_prior_touches := array.get(tws_fvg_touch_counts, tws_best_index)
            tws_armed_break_bar := tws_pending_break_bar
            tws_armed_break_type := tws_pending_break_type
            tws_armed_break_strength := tws_pending_break_strength
            tws_armed_score := tws_best_score
            tws_armed_stars :=
                 tws_armed_score >= 0.80 ? 4 :
                 tws_armed_score >= 0.65 ? 3 :
                 tws_armed_score >= 0.50 ? 2 :
                 1
            tws_setup_armed := true
            tws_pending_break := false
            tws_armed_event := barstate.isconfirmed

            if not na(tws_selected_fvg_box)
                box.delete(tws_selected_fvg_box)

            if tws_fvg_display_mode != "Hidden"
                tws_selected_fvg_box := box.new(
                     left=tws_armed_fvg_birth_bar - 2,
                     top=tws_armed_top,
                     right=bar_index,
                     bottom=tws_armed_bottom,
                     xloc=xloc.bar_index,
                     bgcolor=color.new(tws_armed_direction == 1 ? tws_bullish_color : tws_bearish_color, 82),
                     border_color=tws_armed_direction == 1 ? tws_bullish_color : tws_bearish_color,
                     border_width=2,
                     text="ARMED ZONE\n" + tws_quality_tier(tws_armed_score),
                     text_color=tws_primary_text_color,
                     text_size=size.tiny,
                     text_halign=text.align_right,
                     text_valign=text.align_center,
                     text_formatting=text.format_bold + text.format_italic
                 )
            else
                tws_selected_fvg_box := na

// ARMED ZONE LIFECYCLE

if tws_setup_armed
    if not na(tws_selected_fvg_box)
        box.set_right(tws_selected_fvg_box, bar_index)

    bool tws_setup_timed_out = bar_index - tws_armed_break_bar > tws_max_bars_to_wait
    bool tws_zone_invalidated = tws_armed_direction == 1 ? close < tws_armed_bottom : close > tws_armed_top

    if barstate.isconfirmed and (tws_setup_timed_out or tws_zone_invalidated)
        tws_setup_expired_event := tws_setup_timed_out
        tws_fvg_invalidated_event := tws_zone_invalidated
        tws_setup_armed := false

        if not na(tws_selected_fvg_box)
            box.delete(tws_selected_fvg_box)
            tws_selected_fvg_box := na

// CONFLUENCE GATE & QUALITY SCORES

bool tws_volume_filter_pass = not tws_use_volume_filter or not tws_volume_available or volume >= tws_volume_average * tws_volume_multiplier
bool tws_classic_volume_filter_pass = not tws_use_volume_filter or volume >= tws_volume_average * tws_volume_multiplier
bool tws_effective_volume_filter_pass = tws_classic_profile ? tws_classic_volume_filter_pass : tws_volume_filter_pass
bool tws_di_filter_long = not tws_use_di_filter or (tws_plus_di > tws_minus_di and tws_adx_value >= tws_minimum_adx)
bool tws_di_filter_short = not tws_use_di_filter or (tws_minus_di > tws_plus_di and tws_adx_value >= tws_minimum_adx)

bool tws_htf_filter_long =
     not tws_use_htf_filter or
     not tws_valid_higher_timeframe or
     (tws_htf_close > tws_htf_fast_ema and tws_htf_fast_ema > tws_htf_slow_ema)

bool tws_htf_filter_short =
     not tws_use_htf_filter or
     not tws_valid_higher_timeframe or
     (tws_htf_close < tws_htf_fast_ema and tws_htf_fast_ema < tws_htf_slow_ema)

float tws_volume_quality_score = not tws_volume_available ? 0.50 : tws_bound(volume / math.max(tws_volume_average * 1.75, syminfo.mintick), 0.0, 1.0)
float tws_di_long_quality_score = tws_bound(((tws_plus_di - tws_minus_di) / 35.0) * 0.60 + (tws_adx_value / 40.0) * 0.40, 0.0, 1.0)
float tws_di_short_quality_score = tws_bound(((tws_minus_di - tws_plus_di) / 35.0) * 0.60 + (tws_adx_value / 40.0) * 0.40, 0.0, 1.0)

// POSITION STATE

var bool tws_trade_active = false
var int tws_trade_direction = 0
var int tws_trade_open_bar = na

var float tws_trade_entry = na
var float tws_trade_original_stop = na
var float tws_trade_active_stop = na
var float tws_trade_tp1 = na
var float tws_trade_tp2 = na
var float tws_trade_tp3 = na

var float tws_trade_remaining_percent = 0.0
var float tws_current_trade_pnl = 0.0

var bool tws_tp1_reached = false
var bool tws_tp2_reached = false
var bool tws_tp3_reached = false
var int tws_breakeven_activation_bar = na

var float tws_current_trade_score = na
var string tws_current_trade_grade = "—"

var string tws_current_passport_structure = "—"
var int tws_current_passport_age = na
var float tws_current_passport_fvg_atr = na
var float tws_current_passport_depth = na
var string tws_current_passport_volume = "—"
var string tws_current_passport_di = "—"
var string tws_current_passport_htf = "—"
var bool tws_breakeven_applied = false
var bool tws_current_trade_alert_eligible = false

bool tws_entry_event = false
bool tws_tp1_event = false
bool tws_tp2_event = false
bool tws_tp3_event = false
bool tws_breakeven_event = false
bool tws_stop_event = false
bool tws_breakeven_exit_event = false
bool tws_trade_closed_event = false
string tws_trade_closed_reason_event = ""
float tws_trade_event_price = na

var box tws_reward_box = na
var box tws_risk_box = na
var box[] tws_historical_trade_boxes = array.new_box()
var box[] tws_executed_fvg_boxes = array.new_box()
var line[] tws_historical_trade_lines = array.new_line()

var line tws_entry_line = na
var line tws_stop_line = na
var line tws_original_stop_line = na
var line tws_tp1_line = na
var line tws_tp2_line = na
var line tws_tp3_line = na
var line tws_breakeven_line = na

var label tws_trade_signal_label = na
var label tws_entry_price_label = na
var label tws_stop_price_label = na
var label tws_tp1_price_label = na
var label tws_tp2_price_label = na
var label tws_tp3_price_label = na

// FVG RETEST ENTRY & QUALITY TIER

bool tws_long_signal = false
bool tws_short_signal = false
float tws_live_setup_score = na
string tws_live_setup_grade = "—"
float tws_live_reaction_score = na

bool tws_eval_retest_delay_complete = false
bool tws_eval_zone_touched = false
bool tws_eval_volume_pass = true
bool tws_eval_di_pass = true
bool tws_eval_htf_pass = true
bool tws_eval_reaction_pass = true
bool tws_eval_grade_pass = true
bool tws_preview_ready = false
float tws_eval_retest_depth = na

if tws_setup_armed and not tws_trade_active
    float tws_touch_tolerance = close * tws_touch_tolerance_percent / 100.0
    tws_eval_retest_delay_complete := bar_index - tws_armed_break_bar >= tws_min_retest_delay and bar_index > tws_armed_fvg_birth_bar
    tws_eval_zone_touched :=
         tws_eval_retest_delay_complete and
         (
             tws_classic_profile ?
             tws_classic_zone_contact(tws_armed_direction, tws_armed_top, tws_armed_bottom, tws_retest_mode, tws_touch_tolerance) :
             tws_zone_contact(tws_armed_direction, tws_armed_top, tws_armed_bottom, tws_retest_mode, tws_touch_tolerance)
         )

    tws_live_reaction_score := tws_return_strength(tws_armed_direction, tws_armed_top, tws_armed_bottom)

    tws_eval_volume_pass := tws_effective_volume_filter_pass
    tws_eval_di_pass := tws_armed_direction == 1 ? tws_di_filter_long : tws_di_filter_short
    tws_eval_htf_pass := tws_armed_direction == 1 ? tws_htf_filter_long : tws_htf_filter_short
    bool tws_direction_filters_pass = tws_eval_volume_pass and tws_eval_di_pass and tws_eval_htf_pass

    float tws_eval_zone_height = math.max(tws_armed_top - tws_armed_bottom, syminfo.mintick)
    tws_eval_retest_depth := tws_armed_direction == 1 ?
         tws_bound((tws_armed_top - low) / tws_eval_zone_height, 0.0, 1.0) :
         tws_bound((high - tws_armed_bottom) / tws_eval_zone_height, 0.0, 1.0)

    float tws_directional_score = tws_armed_direction == 1 ? tws_di_long_quality_score : tws_di_short_quality_score
    float tws_htf_quality_score =
         not tws_use_htf_filter or not tws_valid_higher_timeframe ? 0.50 :
         tws_armed_direction == 1 ? (tws_htf_filter_long ? 1.0 : 0.0) :
         (tws_htf_filter_short ? 1.0 : 0.0)

    tws_live_setup_score :=
         tws_classic_profile ?
         tws_armed_score :
         tws_bound(
             tws_armed_score * 0.55 +
             tws_live_reaction_score * 0.25 +
             tws_volume_quality_score * 0.08 +
             tws_directional_score * 0.07 +
             tws_htf_quality_score * 0.05,
             0.0,
             1.0
         )

    tws_live_setup_grade := tws_quality_tier(tws_live_setup_score)

    tws_eval_reaction_pass := tws_classic_profile or tws_live_reaction_score >= tws_minimum_reaction_score
    tws_eval_grade_pass := tws_classic_profile ? tws_armed_stars >= tws_classic_minimum_stars : tws_tier_allowed(tws_live_setup_grade, tws_minimum_grade)
    tws_preview_ready := tws_eval_zone_touched and tws_eval_reaction_pass and tws_direction_filters_pass and tws_eval_grade_pass
    bool tws_confirmed_entry = tws_preview_ready and barstate.isconfirmed

    if tws_confirmed_entry
        tws_long_signal := tws_armed_direction == 1
        tws_short_signal := tws_armed_direction == -1
        tws_entry_event := true

        tws_trade_active := true
        tws_trade_direction := tws_armed_direction
        tws_trade_open_bar := bar_index
        tws_trade_entry := close

        float tws_raw_stop =
             tws_stop_mode == "Gap-Protected Stop" ?
             (
                 tws_trade_direction == 1 ?
                 tws_armed_bottom - tws_atr * tws_fvg_stop_buffer_atr :
                 tws_armed_top + tws_atr * tws_fvg_stop_buffer_atr
             ) :
             (
                 tws_trade_direction == 1 ?
                 tws_trade_entry - tws_atr * tws_atr_stop_multiplier :
                 tws_trade_entry + tws_atr * tws_atr_stop_multiplier
             )

        float tws_raw_stop_distance = math.abs(tws_trade_entry - tws_raw_stop)
        float tws_guaranteed_distance = tws_trade_entry * tws_minimum_stop_percent / 100.0
        float tws_final_stop_distance = math.max(tws_raw_stop_distance, tws_guaranteed_distance)

        tws_trade_original_stop := tws_trade_direction == 1 ? tws_trade_entry - tws_final_stop_distance : tws_trade_entry + tws_final_stop_distance
        tws_trade_active_stop := tws_trade_original_stop

        float tws_trade_risk = math.abs(tws_trade_entry - tws_trade_original_stop)

        tws_trade_tp1 := tws_trade_direction == 1 ? tws_trade_entry + tws_trade_risk * tws_tp1_r : tws_trade_entry - tws_trade_risk * tws_tp1_r
        tws_trade_tp2 := tws_trade_direction == 1 ? tws_trade_entry + tws_trade_risk * tws_tp2_r : tws_trade_entry - tws_trade_risk * tws_tp2_r
        tws_trade_tp3 := tws_trade_direction == 1 ? tws_trade_entry + tws_trade_risk * tws_tp3_r : tws_trade_entry - tws_trade_risk * tws_tp3_r

        tws_trade_remaining_percent := 100.0
        tws_current_trade_pnl := 0.0
        tws_tp1_reached := false
        tws_tp2_reached := false
        tws_tp3_reached := false
        tws_breakeven_activation_bar := na
        tws_current_trade_score := tws_live_setup_score
        tws_current_trade_grade := tws_classic_profile ? (tws_armed_stars == 4 ? "A+" : tws_armed_stars == 3 ? "A" : "B") : tws_live_setup_grade
        tws_current_passport_structure := tws_armed_break_type
        tws_current_passport_age := bar_index - tws_armed_fvg_birth_bar
        tws_current_passport_fvg_atr := (tws_armed_top - tws_armed_bottom) / math.max(tws_atr, syminfo.mintick)
        tws_current_passport_depth := tws_eval_retest_depth
        tws_current_passport_volume := tws_filter_status(tws_use_volume_filter, tws_volume_available, tws_eval_volume_pass)
        tws_current_passport_di := tws_filter_status(tws_use_di_filter, true, tws_eval_di_pass)
        tws_current_passport_htf := tws_filter_status(tws_use_htf_filter and tws_valid_higher_timeframe, true, tws_eval_htf_pass)
        tws_breakeven_applied := false
        tws_current_trade_alert_eligible :=
             tws_alert_package != "Off" and
             tws_alert_direction_allowed(tws_trade_direction, tws_alert_direction) and
             tws_alert_grade_allowed(tws_current_trade_grade, tws_alert_minimum_grade) and
             (tws_alert_package != "Premium Entries" or tws_current_trade_grade == "A+" or tws_current_trade_grade == "A")
        tws_setup_armed := false

        // Preserve the exact FVG that generated this confirmed retest entry.
        if not na(tws_selected_fvg_box)
            box.delete(tws_selected_fvg_box)
            tws_selected_fvg_box := na

        if tws_show_executed_fvg_retests
            color tws_executed_fvg_color = tws_trade_direction == 1 ? tws_bullish_color : tws_bearish_color
            color tws_executed_fvg_text_color = tws_trade_direction == 1 and tws_label_dark_text ? color.black : color.white
            string tws_executed_fvg_text = (tws_trade_direction == 1 ? "BULLISH" : "BEARISH") + " FVG RETEST"

            box tws_executed_fvg_box = box.new(
                 left=tws_armed_fvg_birth_bar - 2,
                 top=tws_armed_top,
                 right=bar_index,
                 bottom=tws_armed_bottom,
                 xloc=xloc.bar_index,
                 bgcolor=color.new(tws_executed_fvg_color, 78),
                 border_color=tws_executed_fvg_color,
                 border_width=3,
                 text=tws_executed_fvg_text,
                 text_color=tws_executed_fvg_text_color,
                 text_size=size.tiny,
                 text_halign=text.align_right,
                 text_valign=text.align_center,
                 text_formatting=text.format_bold + text.format_italic
             )

            array.push(tws_executed_fvg_boxes, tws_executed_fvg_box)

            while array.size(tws_executed_fvg_boxes) > tws_max_historical_trades
                box tws_oldest_executed_fvg = array.shift(tws_executed_fvg_boxes)
                box.delete(tws_oldest_executed_fvg)

        if not tws_show_historical_trade_boxes
            if not na(tws_reward_box)
                box.delete(tws_reward_box)
            if not na(tws_risk_box)
                box.delete(tws_risk_box)
        if not tws_show_historical_trade_boxes
            if not na(tws_entry_line)
                line.delete(tws_entry_line)
            if not na(tws_stop_line)
                line.delete(tws_stop_line)
            if not na(tws_original_stop_line)
                line.delete(tws_original_stop_line)
            if not na(tws_tp1_line)
                line.delete(tws_tp1_line)
            if not na(tws_tp2_line)
                line.delete(tws_tp2_line)
            if not na(tws_tp3_line)
                line.delete(tws_tp3_line)
            if not na(tws_breakeven_line)
                line.delete(tws_breakeven_line)

        // A new position must own a fresh breakeven guide. Historical guides remain on-chart through the array.
        tws_breakeven_line := na

        if not na(tws_trade_signal_label)
            label.delete(tws_trade_signal_label)
        if not na(tws_entry_price_label)
            label.delete(tws_entry_price_label)
        if not na(tws_stop_price_label)
            label.delete(tws_stop_price_label)
        if not na(tws_tp1_price_label)
            label.delete(tws_tp1_price_label)
        if not na(tws_tp2_price_label)
            label.delete(tws_tp2_price_label)
        if not na(tws_tp3_price_label)
            label.delete(tws_tp3_price_label)

        int tws_visual_right_bar = bar_index + tws_trade_projection_bars

        if tws_show_trade_boxes
            tws_reward_box := box.new(
                 left=bar_index,
                 top=tws_trade_direction == 1 ? tws_trade_tp3 : tws_trade_entry,
                 right=tws_visual_right_bar,
                 bottom=tws_trade_direction == 1 ? tws_trade_entry : tws_trade_tp3,
                 xloc=xloc.bar_index,
                 bgcolor=tws_reward_fill,
                 border_color=tws_target_guide_color,
                 border_width=tws_box_border_width
             )

            tws_risk_box := box.new(
                 left=bar_index,
                 top=tws_trade_direction == 1 ? tws_trade_entry : tws_trade_original_stop,
                 right=tws_visual_right_bar,
                 bottom=tws_trade_direction == 1 ? tws_trade_original_stop : tws_trade_entry,
                 xloc=xloc.bar_index,
                 bgcolor=tws_risk_fill,
                 border_color=tws_stop_color,
                 border_width=tws_box_border_width
             )

            if tws_show_historical_trade_boxes
                array.push(tws_historical_trade_boxes, tws_reward_box)
                array.push(tws_historical_trade_boxes, tws_risk_box)

                while array.size(tws_historical_trade_boxes) > tws_max_historical_trades * 2
                    box tws_oldest_trade_box = array.shift(tws_historical_trade_boxes)
                    box.delete(tws_oldest_trade_box)

        tws_entry_line := line.new(bar_index, tws_trade_entry, tws_visual_right_bar, tws_trade_entry, xloc=xloc.bar_index, color=tws_entry_color, width=tws_major_line_width)
        tws_stop_line := line.new(bar_index, tws_trade_active_stop, tws_visual_right_bar, tws_trade_active_stop, xloc=xloc.bar_index, color=tws_stop_color, width=tws_major_line_width)
        tws_original_stop_line := line.new(bar_index, tws_trade_original_stop, tws_visual_right_bar, tws_trade_original_stop, xloc=xloc.bar_index, color=tws_stop_color, style=line.style_dotted, width=tws_minor_line_width)
        tws_tp1_line := line.new(bar_index, tws_trade_tp1, tws_visual_right_bar, tws_trade_tp1, xloc=xloc.bar_index, color=tws_target_guide_color, style=line.style_dashed, width=tws_minor_line_width)
        tws_tp2_line := line.new(bar_index, tws_trade_tp2, tws_visual_right_bar, tws_trade_tp2, xloc=xloc.bar_index, color=tws_target_guide_color, style=line.style_dashed, width=tws_minor_line_width)
        tws_tp3_line := line.new(bar_index, tws_trade_tp3, tws_visual_right_bar, tws_trade_tp3, xloc=xloc.bar_index, color=tws_target_guide_color, width=tws_major_line_width)

        if tws_show_historical_trade_boxes
            array.push(tws_historical_trade_lines, tws_entry_line)
            array.push(tws_historical_trade_lines, tws_stop_line)
            array.push(tws_historical_trade_lines, tws_original_stop_line)
            array.push(tws_historical_trade_lines, tws_tp1_line)
            array.push(tws_historical_trade_lines, tws_tp2_line)
            array.push(tws_historical_trade_lines, tws_tp3_line)

            while array.size(tws_historical_trade_lines) > tws_max_historical_trades * 7
                line tws_oldest_trade_line = array.shift(tws_historical_trade_lines)
                line.delete(tws_oldest_trade_line)

        string tws_signal_title = tws_trade_direction == 1 ? "🟢 FVG RETEST" : "🔴 FVG RETEST"
        string tws_signal_direction = tws_trade_direction == 1 ? "📈 LONG" : "📉 SHORT"
        string tws_passport_compact =
             "AGE " + str.tostring(tws_current_passport_age) +
             " • DEPTH " + str.tostring(tws_current_passport_depth * 100.0, "#") + "%"
        string tws_passport_detailed =
             tws_current_passport_structure + " • FVG " + str.tostring(tws_current_passport_fvg_atr, "#.##") + " ATR\n" +
             tws_passport_compact + "\n" +
             "VOL " + tws_current_passport_volume + " • DI " + tws_current_passport_di + " • HTF " + tws_current_passport_htf
        string tws_signal_text =
             tws_signal_title + "\n" +
             tws_signal_direction + " • " + tws_current_trade_grade + " | " + str.tostring(tws_current_trade_score * 100.0, "#") + "%" +
             (tws_passport_mode == "Off" ? "" : (tws_mobile_layout or tws_passport_mode == "Compact" ? "\n" + tws_passport_compact : "\n" + tws_passport_detailed))
        string tws_signal_tooltip = tws_passport_mode == "Off" ?
             "Confirmed FVG retest\nDirection: " + tws_signal_direction + "\nGrade: " + tws_current_trade_grade + "\nTiming: BAR-CLOSE CONFIRMED" :
             "FVG RETEST PASSPORT\n" +
             "Direction: " + tws_signal_direction + "\n" +
             "Structure: " + tws_current_passport_structure + "\n" +
             "Break Strength: " + str.tostring(nz(tws_armed_break_strength, 0.0) * 100.0, "#.0") + "%\n" +
             "FVG Range: " + str.tostring(tws_armed_bottom, format.mintick) + " — " + str.tostring(tws_armed_top, format.mintick) + "\n" +
             "FVG Size: " + str.tostring(tws_current_passport_fvg_atr, "#.##") + " ATR\n" +
             "FVG Age: " + str.tostring(tws_current_passport_age) + " bars\n" +
             "Retest Depth: " + str.tostring(tws_current_passport_depth * 100.0, "#.0") + "%\n" +
             "Volume: " + tws_current_passport_volume + "\n" +
             "Directional Force: " + tws_current_passport_di + "\n" +
             "Confirmed HTF Bias: " + tws_current_passport_htf + "\n" +
             "Grade: " + tws_current_trade_grade + "\n" +
             "Score: " + str.tostring(tws_current_trade_score * 100.0, "#.0") + "%\n" +
             "Timing: BAR-CLOSE CONFIRMED"

        tws_trade_signal_label := label.new(
             bar_index,
             tws_trade_direction == 1 ? low : high,
             tws_signal_text,
             style=tws_trade_direction == 1 ? label.style_label_up : label.style_label_down,
             color=tws_trade_direction == 1 ? tws_bullish_color : tws_bearish_color,
             textcolor=tws_trade_direction == 1 ? (tws_label_dark_text ? color.black : color.white) : color.white,
             size=tws_signal_label_size,
             tooltip=tws_signal_tooltip,
             text_formatting=text.format_bold + text.format_italic
         )

        tws_entry_price_label := label.new(
             tws_visual_right_bar,
             tws_trade_entry,
             "E  " + str.tostring(tws_trade_entry, format.mintick),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=tws_entry_color,
             textcolor=tws_label_dark_text ? color.black : color.white,
             size=size.tiny,
             tooltip="Execution reference created by the confirmed FVG retest model",
             text_formatting=text.format_bold + text.format_italic
         )

        tws_stop_price_label := label.new(
             tws_visual_right_bar,
             tws_trade_original_stop,
             "S  " + str.tostring(tws_trade_original_stop, format.mintick),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=tws_stop_color,
             textcolor=color.white,
             size=size.tiny,
             tooltip="Initial protection reference",
             text_formatting=text.format_bold + text.format_italic
         )

        if not tws_mobile_layout
            tws_tp1_price_label := label.new(
                 tws_visual_right_bar,
                 tws_trade_tp1,
                 "T1  " + str.tostring(tws_trade_tp1, format.mintick),
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=tws_target_label_fill,
                 textcolor=color.white,
                 size=size.tiny,
                 tooltip="First partial target",
                 text_formatting=text.format_bold + text.format_italic
             )

        else
            tws_tp1_price_label := na

        if not tws_mobile_layout
            tws_tp2_price_label := label.new(
                 tws_visual_right_bar,
                 tws_trade_tp2,
                 "T2  " + str.tostring(tws_trade_tp2, format.mintick),
                 xloc=xloc.bar_index,
                 style=label.style_label_left,
                 color=tws_target_label_fill,
                 textcolor=color.white,
                 size=size.tiny,
                 tooltip="Second partial target",
                 text_formatting=text.format_bold + text.format_italic
             )

        else
            tws_tp2_price_label := na

        tws_tp3_price_label := label.new(
             tws_visual_right_bar,
             tws_trade_tp3,
             "T3  " + str.tostring(tws_trade_tp3, format.mintick),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=tws_target_label_fill,
             textcolor=color.white,
             size=size.tiny,
             tooltip="Final target",
             text_formatting=text.format_bold + text.format_italic
         )

// POSITION LIFECYCLE

if tws_trade_active
    int tws_updated_right_bar =
         bar_index + tws_trade_projection_bars

    if tws_show_trade_boxes
        box.set_right(tws_reward_box, tws_updated_right_bar)
        box.set_right(tws_risk_box, tws_updated_right_bar)

    line.set_x2(tws_entry_line, tws_updated_right_bar)
    line.set_x2(tws_stop_line, tws_updated_right_bar)
    line.set_x2(tws_original_stop_line, tws_updated_right_bar)
    line.set_x2(tws_tp1_line, tws_updated_right_bar)
    line.set_x2(tws_tp2_line, tws_updated_right_bar)
    line.set_x2(tws_tp3_line, tws_updated_right_bar)

    if not na(tws_entry_price_label)
        label.set_x(tws_entry_price_label, tws_updated_right_bar)
    if not na(tws_stop_price_label)
        label.set_x(tws_stop_price_label, tws_updated_right_bar)
    if not na(tws_tp1_price_label)
        label.set_x(tws_tp1_price_label, tws_updated_right_bar)
    if not na(tws_tp2_price_label)
        label.set_x(tws_tp2_price_label, tws_updated_right_bar)
    if not na(tws_tp3_price_label)
        label.set_x(tws_tp3_price_label, tws_updated_right_bar)

    if
         tws_move_to_breakeven and
         tws_tp1_reached and
         not na(tws_breakeven_activation_bar) and
         bar_index > tws_breakeven_activation_bar and
         barstate.isconfirmed and
         not tws_breakeven_applied

        tws_trade_active_stop := tws_trade_entry
        tws_breakeven_applied := true
        tws_breakeven_event := true
        tws_trade_event_price := tws_trade_entry

        line.set_y1(tws_stop_line, tws_trade_active_stop)
        line.set_y2(tws_stop_line, tws_trade_active_stop)
        line.set_color(tws_stop_line, tws_breakeven_color)

        if not na(tws_stop_price_label)
            label.set_y(tws_stop_price_label, tws_trade_active_stop)
            label.set_text(
                 tws_stop_price_label,
                 "BE: " + str.tostring(tws_trade_active_stop, format.mintick)
             )
            label.set_color(tws_stop_price_label, tws_breakeven_color)

        if na(tws_breakeven_line)
            tws_breakeven_line := line.new(
                 tws_trade_open_bar,
                 tws_trade_entry,
                 tws_updated_right_bar,
                 tws_trade_entry,
                 xloc=xloc.bar_index,
                 color=tws_breakeven_color,
                 width=tws_major_line_width
             )

            if tws_show_historical_trade_boxes
                array.push(tws_historical_trade_lines, tws_breakeven_line)

                while array.size(tws_historical_trade_lines) > tws_max_historical_trades * 7
                    line tws_oldest_trade_line = array.shift(tws_historical_trade_lines)
                    line.delete(tws_oldest_trade_line)
        else
            line.set_x2(tws_breakeven_line, tws_updated_right_bar)

    if bar_index > tws_trade_open_bar and barstate.isconfirmed
        bool tws_stop_touched =
             tws_trade_direction == 1 ?
             low <= tws_trade_active_stop :
             high >= tws_trade_active_stop

        bool tws_tp1_touched =
             tws_trade_direction == 1 ?
             high >= tws_trade_tp1 :
             low <= tws_trade_tp1

        bool tws_tp2_touched =
             tws_trade_direction == 1 ?
             high >= tws_trade_tp2 :
             low <= tws_trade_tp2

        bool tws_tp3_touched =
             tws_trade_direction == 1 ?
             high >= tws_trade_tp3 :
             low <= tws_trade_tp3

        bool tws_close_trade = false
        string tws_close_reason = ""
        float tws_final_exit_price = na

        bool tws_conservative_mode =
             tws_intrabar_priority == "Protective First"

        if tws_conservative_mode and tws_stop_touched
            tws_current_trade_pnl += tws_weighted_result(
                 tws_trade_direction,
                 tws_trade_entry,
                 tws_trade_active_stop,
                 tws_trade_remaining_percent
             )

            tws_trade_remaining_percent := 0.0
            tws_close_trade := true
            tws_close_reason := tws_trade_active_stop == tws_trade_entry ? "BREAKEVEN" : "STOP LOSS"
            tws_final_exit_price := tws_trade_active_stop
        else
            if not tws_tp1_reached and tws_tp1_touched
                float tws_tp1_quantity =
                     math.min(
                         tws_tp1_close_percent,
                         tws_trade_remaining_percent
                     )

                tws_current_trade_pnl += tws_weighted_result(
                     tws_trade_direction,
                     tws_trade_entry,
                     tws_trade_tp1,
                     tws_tp1_quantity
                 )

                tws_trade_remaining_percent -= tws_tp1_quantity
                tws_tp1_reached := true
                tws_tp1_event := true
                tws_trade_event_price := tws_trade_tp1
                tws_breakeven_activation_bar := bar_index

                if not na(tws_tp1_price_label)
                    label.set_text(
                         tws_tp1_price_label,
                         "TP1 ✓ " +
                         str.tostring(tws_trade_tp1, format.mintick)
                     )

            if not tws_tp2_reached and tws_tp2_touched
                float tws_tp2_quantity =
                     math.min(
                         tws_tp2_close_percent,
                         tws_trade_remaining_percent
                     )

                tws_current_trade_pnl += tws_weighted_result(
                     tws_trade_direction,
                     tws_trade_entry,
                     tws_trade_tp2,
                     tws_tp2_quantity
                 )

                tws_trade_remaining_percent -= tws_tp2_quantity
                tws_tp2_reached := true
                tws_tp2_event := true
                tws_trade_event_price := tws_trade_tp2

                if not na(tws_tp2_price_label)
                    label.set_text(
                         tws_tp2_price_label,
                         "TP2 ✓ " +
                         str.tostring(tws_trade_tp2, format.mintick)
                     )

            if not tws_tp3_reached and tws_tp3_touched
                float tws_tp3_quantity =
                     tws_trade_remaining_percent

                tws_current_trade_pnl += tws_weighted_result(
                     tws_trade_direction,
                     tws_trade_entry,
                     tws_trade_tp3,
                     tws_tp3_quantity
                 )

                tws_trade_remaining_percent := 0.0
                tws_tp3_reached := true
                tws_tp3_event := true
                tws_trade_event_price := tws_trade_tp3

                if not na(tws_tp3_price_label)
                    label.set_text(
                         tws_tp3_price_label,
                         "TP3 ✓ " +
                         str.tostring(tws_trade_tp3, format.mintick)
                     )

                tws_close_trade := true
                tws_close_reason := "TP3"
                tws_final_exit_price := tws_trade_tp3

            if
                 not tws_conservative_mode and
                 not tws_close_trade and
                 tws_stop_touched

                tws_current_trade_pnl += tws_weighted_result(
                     tws_trade_direction,
                     tws_trade_entry,
                     tws_trade_active_stop,
                     tws_trade_remaining_percent
                 )

                tws_trade_remaining_percent := 0.0
                tws_close_trade := true
                tws_close_reason := tws_trade_active_stop == tws_trade_entry ? "BREAKEVEN" : "STOP LOSS"
                tws_final_exit_price := tws_trade_active_stop

            if tws_trade_remaining_percent <= 0.0001 and not tws_close_trade
                tws_close_trade := true
                tws_close_reason := tws_tp3_reached ? "TP3" : "TARGETS COMPLETE"
                tws_final_exit_price := tws_tp3_reached ? tws_trade_tp3 : tws_trade_tp2

        if tws_close_trade
            tws_trade_closed_event := true
            tws_trade_closed_reason_event := tws_close_reason
            tws_trade_event_price := tws_final_exit_price
            tws_stop_event := tws_close_reason == "STOP LOSS"
            tws_breakeven_exit_event := tws_close_reason == "BREAKEVEN"

            // Lock every price guide to the exact same right edge as the closed TP/SL boxes.
            // This prevents lines from extending beyond historical trade zones.
            if tws_show_trade_boxes
                box.set_right(tws_reward_box, bar_index)
                box.set_right(tws_risk_box, bar_index)

            if not na(tws_entry_line)
                line.set_x2(tws_entry_line, bar_index)
            if not na(tws_stop_line)
                line.set_x2(tws_stop_line, bar_index)
            if not na(tws_original_stop_line)
                line.set_x2(tws_original_stop_line, bar_index)
            if not na(tws_tp1_line)
                line.set_x2(tws_tp1_line, bar_index)
            if not na(tws_tp2_line)
                line.set_x2(tws_tp2_line, bar_index)
            if not na(tws_tp3_line)
                line.set_x2(tws_tp3_line, bar_index)
            if not na(tws_breakeven_line)
                line.set_x2(tws_breakeven_line, bar_index)

            if not na(tws_entry_price_label)
                label.set_x(tws_entry_price_label, bar_index)
            if not na(tws_stop_price_label)
                label.set_x(tws_stop_price_label, bar_index)
            if not na(tws_tp1_price_label)
                label.set_x(tws_tp1_price_label, bar_index)
            if not na(tws_tp2_price_label)
                label.set_x(tws_tp2_price_label, bar_index)
            if not na(tws_tp3_price_label)
                label.set_x(tws_tp3_price_label, bar_index)

            tws_trade_active := false
            tws_last_trade_close_bar := bar_index

            label.new(
                 tws_trade_open_bar,
                 tws_trade_entry,
                 (
                     tws_trade_direction == 1 ?
                     "🟢 BULLISH FVG RETEST" :
                     "🔴 BEARISH FVG RETEST"
                 ) +
                 "\n🔒 MODEL CLOSED" +
                 "\n" +
                 (tws_close_reason == "STOP LOSS" ? "🛑 " : tws_close_reason == "BREAKEVEN" ? "🔵 " : "🎯 ") +
                 tws_close_reason +
                 "\n⭐ GRADE: " + tws_current_trade_grade +
                 "\n🎯 TP1: " +
                 (tws_tp1_reached ? "✓" : "—") +
                 " | TP2: " +
                 (tws_tp2_reached ? "✓" : "—") +
                 " | TP3: " +
                 (tws_tp3_reached ? "✓" : "—"),
                 xloc=xloc.bar_index,
                 style=
                     tws_current_trade_pnl >= 0 ?
                     label.style_label_up :
                     label.style_label_down,
                 color=
                     tws_current_trade_pnl > 0 ?
                     tws_closed_profit_fill :
                     tws_current_trade_pnl < 0 ?
                     tws_closed_loss_fill :
                     tws_closed_flat_fill,
                 textcolor=color.white,
                 size=tws_signal_label_size,
                 tooltip="Completed FVG retest model\nDirection: " + (tws_trade_direction == 1 ? "BULLISH" : "BEARISH") + "\nGrade: " + tws_current_trade_grade + "\nOutcome: " + (tws_current_trade_pnl > 0 ? "POSITIVE" : tws_current_trade_pnl < 0 ? "NEGATIVE" : "FLAT"),
                 text_formatting=text.format_bold + text.format_italic
             )

// BLOCKER LENS

string tws_blocker_text =
     not tws_show_blocker_lens ? "OFF" :
     tws_trade_active ? "TRADE ACTIVE" :
     tws_no_eligible_fvg_event ? "NO ELIGIBLE FVG" :
     tws_setup_expired_event ? "SETUP EXPIRED" :
     tws_fvg_invalidated_event ? "FVG INVALIDATED" :
     not tws_cooldown_complete ? "COOLDOWN" :
     tws_pending_break ? "SCANNING FVG" :
     tws_setup_armed and not tws_eval_retest_delay_complete ? "RETEST DELAY" :
     tws_setup_armed and not tws_eval_zone_touched ? "WAITING RETEST" :
     tws_setup_armed and not tws_eval_volume_pass ? "VOLUME BLOCK" :
     tws_setup_armed and not tws_eval_di_pass ? "DI BLOCK" :
     tws_setup_armed and not tws_eval_htf_pass ? "HTF BLOCK" :
     tws_setup_armed and not tws_eval_reaction_pass ? "WEAK REACTION" :
     tws_setup_armed and not tws_eval_grade_pass ? "GRADE BLOCK" :
     tws_setup_armed and tws_preview_ready and not barstate.isconfirmed ? (tws_live_preview_mode ? "LIVE PREVIEW READY" : "WAITING BAR CLOSE") :
     tws_setup_armed ? "FVG ARMED" :
     "WAITING STRUCTURE"

color tws_blocker_color =
     tws_blocker_text == "TRADE ACTIVE" ? tws_target_guide_color :
     tws_blocker_text == "LIVE PREVIEW READY" or tws_blocker_text == "WAITING BAR CLOSE" ? tws_breakeven_color :
     str.contains(tws_blocker_text, "BLOCK") or tws_blocker_text == "WEAK REACTION" or tws_blocker_text == "NO ELIGIBLE FVG" or tws_blocker_text == "SETUP EXPIRED" or tws_blocker_text == "FVG INVALIDATED" ? tws_stop_color :
     tws_blocker_text == "FVG ARMED" or tws_blocker_text == "SCANNING FVG" ? tws_border_color :
     tws_muted_text_color

// ADVANCED ALERT ROUTER

bool tws_alert_lifecycle_enabled = tws_alert_package == "Full Lifecycle" or tws_alert_package == "Webhook JSON"
bool tws_alert_json_enabled = tws_alert_package == "Webhook JSON"
bool tws_entry_alert_event = tws_entry_event and tws_current_trade_alert_eligible
bool tws_armed_alert_event = tws_armed_event and tws_alert_lifecycle_enabled and tws_alert_on_armed_setup and tws_alert_direction_allowed(tws_armed_direction, tws_alert_direction) and tws_alert_grade_allowed(tws_quality_tier(tws_armed_score), tws_alert_minimum_grade)
bool tws_tp1_alert_event = tws_tp1_event and tws_alert_lifecycle_enabled and tws_current_trade_alert_eligible
bool tws_tp2_alert_event = tws_tp2_event and tws_alert_lifecycle_enabled and tws_current_trade_alert_eligible
bool tws_tp3_alert_event = tws_tp3_event and tws_alert_lifecycle_enabled and tws_current_trade_alert_eligible
bool tws_breakeven_alert_event = tws_breakeven_event and tws_alert_lifecycle_enabled and tws_alert_on_breakeven and tws_current_trade_alert_eligible
bool tws_stop_alert_event = tws_stop_event and tws_alert_lifecycle_enabled and tws_current_trade_alert_eligible
bool tws_breakeven_exit_alert_event = tws_breakeven_exit_event and tws_alert_lifecycle_enabled and tws_current_trade_alert_eligible

if barstate.isconfirmed
    if tws_armed_alert_event
        string tws_armed_message = tws_alert_json_enabled ?
             '{"brand":"trade_w_samet","event":"fvg_armed","ticker":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","direction":"' + (tws_armed_direction == 1 ? "long" : "short") + '","grade":"' + tws_quality_tier(tws_armed_score) + '","score":' + str.tostring(tws_armed_score * 100.0, "#.0") + '}' :
             '[' + TWS_SIGNATURE + '] FVG ARMED | ' + syminfo.ticker + ' | TF ' + timeframe.period + ' | ' + (tws_armed_direction == 1 ? "LONG" : "SHORT") + ' | Grade ' + tws_quality_tier(tws_armed_score)
        alert(tws_armed_message, alert.freq_all)

    if tws_entry_alert_event
        string tws_entry_message = tws_alert_json_enabled ?
             '{"brand":"trade_w_samet","event":"entry","ticker":"' + syminfo.ticker + '","timeframe":"' + timeframe.period + '","direction":"' + (tws_trade_direction == 1 ? "long" : "short") + '","grade":"' + tws_current_trade_grade + '","score":' + str.tostring(tws_current_trade_score * 100.0, "#.0") + ',"entry":' + str.tostring(tws_trade_entry, format.mintick) + ',"sl":' + str.tostring(tws_trade_original_stop, format.mintick) + ',"tp1":' + str.tostring(tws_trade_tp1, format.mintick) + ',"tp2":' + str.tostring(tws_trade_tp2, format.mintick) + ',"tp3":' + str.tostring(tws_trade_tp3, format.mintick) + '}' :
             '[' + TWS_SIGNATURE + '] FVG RETEST ' + (tws_trade_direction == 1 ? "LONG" : "SHORT") + ' | ' + syminfo.ticker + ' | TF ' + timeframe.period + ' | Grade ' + tws_current_trade_grade + ' | Entry ' + str.tostring(tws_trade_entry, format.mintick) + ' | SL ' + str.tostring(tws_trade_original_stop, format.mintick) + ' | TP1 ' + str.tostring(tws_trade_tp1, format.mintick) + ' | TP2 ' + str.tostring(tws_trade_tp2, format.mintick) + ' | TP3 ' + str.tostring(tws_trade_tp3, format.mintick)
        alert(tws_entry_message, alert.freq_all)

    if tws_tp1_alert_event
        alert(tws_alert_json_enabled ? '{"brand":"trade_w_samet","event":"tp1","ticker":"' + syminfo.ticker + '","price":' + str.tostring(tws_trade_tp1, format.mintick) + '}' : '[' + TWS_SIGNATURE + '] TP1 REACHED | ' + syminfo.ticker + ' | ' + str.tostring(tws_trade_tp1, format.mintick), alert.freq_all)
    if tws_tp2_alert_event
        alert(tws_alert_json_enabled ? '{"brand":"trade_w_samet","event":"tp2","ticker":"' + syminfo.ticker + '","price":' + str.tostring(tws_trade_tp2, format.mintick) + '}' : '[' + TWS_SIGNATURE + '] TP2 REACHED | ' + syminfo.ticker + ' | ' + str.tostring(tws_trade_tp2, format.mintick), alert.freq_all)
    if tws_tp3_alert_event
        alert(tws_alert_json_enabled ? '{"brand":"trade_w_samet","event":"tp3","ticker":"' + syminfo.ticker + '","price":' + str.tostring(tws_trade_tp3, format.mintick) + '}' : '[' + TWS_SIGNATURE + '] TP3 REACHED | ' + syminfo.ticker + ' | ' + str.tostring(tws_trade_tp3, format.mintick), alert.freq_all)
    if tws_breakeven_alert_event
        alert(tws_alert_json_enabled ? '{"brand":"trade_w_samet","event":"breakeven_activated","ticker":"' + syminfo.ticker + '","price":' + str.tostring(tws_trade_entry, format.mintick) + '}' : '[' + TWS_SIGNATURE + '] BREAKEVEN ACTIVE | ' + syminfo.ticker + ' | ' + str.tostring(tws_trade_entry, format.mintick), alert.freq_all)
    if tws_stop_alert_event
        alert(tws_alert_json_enabled ? '{"brand":"trade_w_samet","event":"stop_loss","ticker":"' + syminfo.ticker + '","price":' + str.tostring(tws_trade_event_price, format.mintick) + '}' : '[' + TWS_SIGNATURE + '] STOP LOSS | ' + syminfo.ticker + ' | ' + str.tostring(tws_trade_event_price, format.mintick), alert.freq_all)
    if tws_breakeven_exit_alert_event
        alert(tws_alert_json_enabled ? '{"brand":"trade_w_samet","event":"breakeven_exit","ticker":"' + syminfo.ticker + '","price":' + str.tostring(tws_trade_event_price, format.mintick) + '}' : '[' + TWS_SIGNATURE + '] BREAKEVEN EXIT | ' + syminfo.ticker + ' | ' + str.tostring(tws_trade_event_price, format.mintick), alert.freq_all)

// ALERT DATA CHANNELS

plot(tws_trade_active or tws_entry_event ? tws_trade_original_stop : tws_stop_event or tws_breakeven_exit_event ? tws_trade_event_price : na, title="SL", display=display.none)
plot(tws_trade_active or tws_entry_event or tws_tp1_event ? tws_trade_tp1 : na, title="TP1", display=display.none)
plot(tws_trade_active or tws_entry_event or tws_tp2_event ? tws_trade_tp2 : na, title="TP2", display=display.none)
plot(tws_trade_active or tws_entry_event or tws_tp3_event ? tws_trade_tp3 : na, title="TP3", display=display.none)
plot(tws_trade_active or tws_entry_event or tws_breakeven_event or tws_breakeven_exit_event ? tws_trade_entry : na, title="ENTRY", display=display.none)
plot(tws_entry_event ? tws_current_trade_score * 100.0 : tws_armed_event ? tws_armed_score * 100.0 : na, title="SIGNAL_SCORE", display=display.none)

// SIGNAL DELIVERY CONDITIONS

alertcondition(tws_armed_alert_event, title="trade_w_samet • FVG ARMED", message='trade_w_samet FVG ARMED | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}}')
alertcondition(tws_entry_alert_event and tws_trade_direction == 1, title="trade_w_samet • BULLISH FVG RETEST", message='trade_w_samet BULLISH FVG RETEST | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}} | Entry: {{plot("ENTRY")}} | SL: {{plot("SL")}} | TP1: {{plot("TP1")}} | TP2: {{plot("TP2")}} | TP3: {{plot("TP3")}}')
alertcondition(tws_entry_alert_event and tws_trade_direction == -1, title="trade_w_samet • BEARISH FVG RETEST", message='trade_w_samet BEARISH FVG RETEST | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}} | Entry: {{plot("ENTRY")}} | SL: {{plot("SL")}} | TP1: {{plot("TP1")}} | TP2: {{plot("TP2")}} | TP3: {{plot("TP3")}}')
alertcondition(tws_entry_alert_event, title="trade_w_samet • ANY FVG RETEST", message='trade_w_samet FVG RETEST | {{ticker}} | TF: {{interval}} | Score: {{plot("SIGNAL_SCORE")}} | Entry: {{plot("ENTRY")}} | SL: {{plot("SL")}} | TP1: {{plot("TP1")}} | TP2: {{plot("TP2")}} | TP3: {{plot("TP3")}}')
alertcondition(tws_tp1_alert_event, title="trade_w_samet • TP1 REACHED", message='trade_w_samet TP1 REACHED | {{ticker}} | TP1: {{plot("TP1")}}')
alertcondition(tws_tp2_alert_event, title="trade_w_samet • TP2 REACHED", message='trade_w_samet TP2 REACHED | {{ticker}} | TP2: {{plot("TP2")}}')
alertcondition(tws_tp3_alert_event, title="trade_w_samet • TP3 REACHED", message='trade_w_samet TP3 REACHED | {{ticker}} | TP3: {{plot("TP3")}}')
alertcondition(tws_breakeven_alert_event, title="trade_w_samet • BREAKEVEN ACTIVE", message='trade_w_samet BREAKEVEN ACTIVE | {{ticker}} | Entry: {{plot("ENTRY")}}')
alertcondition(tws_stop_alert_event, title="trade_w_samet • STOP LOSS", message='trade_w_samet STOP LOSS | {{ticker}} | SL: {{plot("SL")}}')
alertcondition(tws_breakeven_exit_alert_event, title="trade_w_samet • BREAKEVEN EXIT", message='trade_w_samet BREAKEVEN EXIT | {{ticker}} | Entry: {{plot("ENTRY")}}')

// CONTROL PANEL STATE

int tws_resolved_market_bias =
     tws_use_htf_filter and tws_valid_higher_timeframe ?
     tws_htf_fast_ema > tws_htf_slow_ema and tws_htf_close > tws_htf_fast_ema ? 1 :
     tws_htf_fast_ema < tws_htf_slow_ema and tws_htf_close < tws_htf_fast_ema ? -1 :
     0 :
     tws_structure_bias

string tws_market_bias_text =
     tws_resolved_market_bias == 1 ? "BULLISH" :
     tws_resolved_market_bias == -1 ? "BEARISH" :
     "NEUTRAL"

color tws_market_bias_color =
     tws_resolved_market_bias == 1 ? tws_bullish_color :
     tws_resolved_market_bias == -1 ? tws_bearish_color :
     tws_muted_text_color

string tws_dashboard_entry_text =
     tws_trade_active ? str.tostring(tws_trade_entry, format.mintick) : "—"

string tws_dashboard_tp1_text =
     tws_trade_active ? str.tostring(tws_trade_tp1, format.mintick) : "—"

string tws_dashboard_tp2_text =
     tws_trade_active ? str.tostring(tws_trade_tp2, format.mintick) : "—"

string tws_dashboard_tp3_text =
     tws_trade_active ? str.tostring(tws_trade_tp3, format.mintick) : "—"

string tws_dashboard_sl_text =
     tws_trade_active ? str.tostring(tws_trade_active_stop, format.mintick) : "—"

// LEVEL DASHBOARD

var table tws_engine_dashboard = table.new(
     position.bottom_right,
     2,
     8,
     bgcolor=tws_panel_color,
     frame_color=tws_border_color,
     frame_width=2,
     border_color=color.new(tws_border_color, 35),
     border_width=1
 )

if barstate.isfirst
    table.merge_cells(tws_engine_dashboard, 0, 0, 1, 0)

if barstate.islast and tws_show_engine_dashboard
    table.cell(
         tws_engine_dashboard,
         0,
         0,
         "📍 FVG RETEST LEVELS",
         bgcolor=tws_border_color,
         text_color=tws_header_dark_text ? color.black : color.white,
         text_size=tws_dashboard_text_size,
         text_formatting=text.format_bold + text.format_italic
     )

    table.cell(tws_engine_dashboard, 0, 1, "BIAS", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 1, tws_market_bias_text, bgcolor=tws_panel_alt_color, text_color=tws_market_bias_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)

    table.cell(tws_engine_dashboard, 0, 2, "STATE", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 2, tws_blocker_text, bgcolor=tws_panel_alt_color, text_color=tws_blocker_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)

    table.cell(tws_engine_dashboard, 0, 3, "ENTRY", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 3, tws_dashboard_entry_text, bgcolor=tws_panel_alt_color, text_color=tws_trade_active ? tws_entry_color : tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)

    table.cell(tws_engine_dashboard, 0, 4, "TP1", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 4, tws_dashboard_tp1_text, bgcolor=tws_panel_alt_color, text_color=tws_trade_active ? tws_target_guide_color : tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)

    table.cell(tws_engine_dashboard, 0, 5, "TP2", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 5, tws_dashboard_tp2_text, bgcolor=tws_panel_alt_color, text_color=tws_trade_active ? tws_target_guide_color : tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)

    table.cell(tws_engine_dashboard, 0, 6, "TP3", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 6, tws_dashboard_tp3_text, bgcolor=tws_panel_alt_color, text_color=tws_trade_active ? tws_target_guide_color : tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)

    table.cell(tws_engine_dashboard, 0, 7, "SL", bgcolor=tws_panel_color, text_color=tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
    table.cell(tws_engine_dashboard, 1, 7, tws_dashboard_sl_text, bgcolor=tws_panel_alt_color, text_color=tws_trade_active ? tws_stop_color : tws_muted_text_color, text_size=tws_dashboard_text_size, text_formatting=text.format_bold + text.format_italic)
````
