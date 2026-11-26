# ICT SMC H4 FVG Retest M15 Scalping Killzones

- url: https://www.tradingview.com/script/sGBHAnbn-ICT-SMC-H4-FVG-Retest-M15-Scalping-Killzones/
- type: indicator
- pine_id: PUB;6bfc8b1013854fe39be1c0427fee9eee
- version: 15.0

## Description

ICT SMC H4 FVG Retest — M15 Scalping Killzones

Overview

ICT SMC H4 FVG Retest — [b]M15 Scalping Killzones[/b] is a multi-timeframe trading indicator designed to identify structured intraday setups based on:

* Confirmed higher-timeframe Fair Value Gaps
* M15 execution Fair Value Gaps
* ICT-style killzones
* Session highs and lows
* H4 buy-side and sell-side liquidity
* Market or limit-entry models
* Liquidity-based profit targets

The indicator is intended to be used on a 15-minute chart.

Its purpose is not to generate a large number of signals. It is designed to wait for a higher-timeframe imbalance, a valid departure from that zone, and a later retest during an active trading session.

⸻

Core strategy

The standard short setup follows this sequence:

1. A bearish H4 Fair Value Gap is confirmed.
2. Price moves below the H4 FVG.
3. Price later returns to the H4 FVG during an enabled killzone.
4. A bearish M15 FVG forms and overlaps the H4 zone.
5. The M15 candle closes and confirms the setup.
6. The indicator displays the proposed entry, stop-loss and target.

The bullish setup uses the opposite sequence:

1. A bullish H4 FVG is confirmed.
2. Price moves above the H4 FVG.
3. Price later returns to the H4 FVG during an enabled killzone.
4. A bullish M15 FVG forms inside or overlapping the H4 zone.
5. The M15 candle closes and confirms the setup.
6. The indicator displays the proposed entry, stop-loss and target.

The H4 FVG that is created during the initial market displacement is treated as a future retest zone. The indicator does not use the M15 FVGs that formed before the H4 candle was confirmed.

⸻

Non-repainting higher-timeframe logic

The indicator only uses confirmed higher-timeframe candles.

A new H4 FVG is therefore displayed only after the third H4 candle in the three-candle FVG sequence has closed.

This avoids using an H4 imbalance that may appear intrabar and disappear before the H4 candle closes.

The trade-off is intentional:

* the FVG is not shown as confirmed while the H4 candle is still forming;
* once the H4 candle closes, the confirmed zone appears on the M15 chart;
* the indicator then waits for a future retest.

The confirmed HTF FVG is used for signals and alerts. No unconfirmed HTF data is used for trade validation.

⸻

Fair Value Gap definition

Bullish FVG

A bullish FVG exists when the low of the third candle is above the high of the first candle.

The imbalance is the price range between:

* the high of the first candle;
* the low of the third candle.

Bearish FVG

A bearish FVG exists when the high of the third candle is below the low of the first candle.

The imbalance is the price range between:

* the high of the third candle;
* the low of the first candle.

The large middle candle is usually the displacement candle, but its full body is not the FVG. The FVG is only the untraded space between the first and third candles.

⸻

Entry modes

The indicator includes three HTF retest models.

A — Strict retest

Price must first close outside the HTF FVG, then return to the zone.

For a bearish FVG:

* price must close below the FVG;
* price must later return into it.

For a bullish FVG:

* price must close above the FVG;
* price must later return into it.

This is the most selective mode and is the default setting.

A′ — Tolerant retest

A wick outside the HTF FVG is sufficient to validate the departure.

This mode produces more opportunities than the strict model but may accept less decisive departures.

B — Direct tap in killzone

No prior departure from the HTF FVG is required.

A direct touch of the HTF zone during an enabled killzone can become eligible if the remaining entry conditions are satisfied.

This is the least selective mode.

⸻

M15 confirmation

By default, the indicator requires an M15 Fair Value Gap in the same direction as the HTF FVG.

For a short:

* the HTF FVG must be bearish;
* the M15 FVG must also be bearish;
* the M15 FVG must overlap the HTF FVG.

For a long:

* the HTF FVG must be bullish;
* the M15 FVG must also be bullish;
* the M15 FVG must overlap the HTF FVG.

The M15 FVG size filter can be used to ignore very small imbalances.

When Require an M15 FVG is disabled, the indicator can generate a setup from a simple HTF FVG retest during a killzone.

⸻

Candle-close confirmation

The setting:

Validate signals only at M15 close

should normally remain enabled.

When enabled:

* an intrabar M15 FVG is not enough;
* the setup must still be valid when the M15 candle closes;
* triangles and alerts are produced only from confirmed M15 conditions.

This prevents signals from appearing during a candle and disappearing before its close.

⸻

Killzones

Killzones are anchored to the native timezone of each market. They automatically follow daylight-saving changes where applicable.

Asia killzone

Default timezone:

Asia/Tokyo

Default window:

09:00–13:00 Tokyo time

London killzone

Default timezone:

Europe/London

Default window:

07:00–10:00 London time

New York AM killzone

Default timezone:

America/New_York

Default window:

09:30–11:00 New York time

New York PM killzone

Default timezone:

America/New_York

Default window:

13:30–16:00 New York time

Each killzone can be enabled, disabled or adjusted independently.

The background colors only indicate an active trading window. They do not indicate bullish or bearish direction.

⸻

Entry types

Market at close

The proposed entry is the closing price of the confirmed signal candle.

The setup becomes visually active immediately after confirmation.

Limit at FVG edge

The indicator places a theoretical limit entry at the relevant edge of the M15 FVG.

For a bearish setup, the entry is placed at the lower boundary of the bearish M15 FVG.

For a bullish setup, the entry is placed at the upper boundary of the bullish M15 FVG.

If M15 confirmation is disabled, the relevant HTF FVG boundary is used instead.

The limit order remains pending for the selected number of M15 candles. If it is not filled before expiration, the order is cancelled and the HTF zone may become available for a later setup.

⸻

Stop-loss placement

For a bearish setup, the stop-loss is placed:

* above the opposite side of the M15 FVG;
* plus the selected tick buffer.

For a bullish setup, the stop-loss is placed:

* below the opposite side of the M15 FVG;
* minus the selected tick buffer.

When M15 FVG confirmation is disabled, the stop is placed beyond the opposite side of the HTF FVG.

The Stop buffer in ticks setting adds a small safety margin beyond the imbalance boundary.

⸻

Profit targets

The indicator supports two target models.

Liquidity target

When enabled, the indicator searches for the nearest eligible liquidity level in the direction of the trade.

Possible targets include:

* previous Asia session high or low;
* previous London session high or low;
* previous New York session high or low;
* H4 buy-side liquidity;
* H4 sell-side liquidity;
* the current session high or low.

A target must offer at least the selected minimum reward-to-risk ratio.

Fixed R:R fallback

If no eligible liquidity target is available, the indicator uses the selected fixed reward-to-risk ratio.

The default fallback is:

2.0R

⸻

Swept liquidity handling

Two modes are available.

Legacy v3.3

Previously swept session levels and H4 liquidity levels may still be used as targets.

This mode preserves the original behavior of the earlier indicator.

Untouched liquidity only

Once a liquidity occurrence has been swept, it is no longer eligible as a target.

A new pivot or a new completed session may later create a new active liquidity occurrence at the same or a similar price.

This mode is generally more selective because it targets liquidity that has not yet been consumed.

⸻

Session levels

The indicator tracks the highs and lows of:

* Asia
* London
* New York

Each session is calculated in its native timezone, which prevents the levels from drifting when the United Kingdom or the United States changes between standard time and daylight-saving time.

At the end of a session:

* the high and low are frozen;
* their labels remain anchored to the session close;
* the levels can be used as potential liquidity targets.

The number of stored sessions can be adjusted in the settings.

⸻

H4 SSL and BSL levels

The indicator also plots confirmed H4 pivot liquidity.

BSL

Buy-Side Liquidity

Displayed above confirmed H4 swing highs.

SSL

Sell-Side Liquidity

Displayed below confirmed H4 swing lows.

The pivot lookback determines the significance and confirmation delay of these levels.

A larger lookback produces more structurally significant levels, but they are confirmed later.

⸻

Dashboard

The dashboard shows the current state of the setup for both long and short directions.

Three display sizes are available:

* Small
* Medium
* Large

HTF active

A confirmed HTF FVG is currently active in that direction.

HTF departure

Price has moved outside the HTF FVG according to the selected A or A′ departure logic.

In Mode B, a prior departure is not required for the final signal.

HTF retest

The current candle is touching or overlapping the active HTF FVG.

Killzone

The current candle is inside at least one enabled killzone.

M15 FVG

A valid M15 FVG exists in that direction and passes the minimum-size filter.

HTF overlap

The M15 FVG overlaps the active HTF FVG.

M15 close

The current M15 candle is confirmed.

While the live M15 candle is still forming, this field may display No.

Available

No previous trade or pending limit order is currently blocking a new setup.

Raw signal

The structural conditions are satisfied before final trade-availability and candle-close validation.

Signal

All required conditions are satisfied and a valid setup has been produced.

⸻

Signal markers

A confirmed short setup is displayed as:

* a red downward triangle;
* the letter S.

A confirmed long setup is displayed as:

* a green upward triangle;
* the letter L.

The indicator also creates a label containing:

* entry price;
* stop-loss;
* target;
* expected reward-to-risk ratio.

The risk and reward areas are displayed directly on the chart.

⸻

Near-miss labels

The optional Show near misses setting helps diagnose why an otherwise valid-looking setup was rejected.

Possible reasons include:

* LEFT — price has not yet departed from the HTF FVG;
* KZ — the setup is outside an enabled killzone;
* CLOSE — the M15 candle has not yet closed;
* BUSY — a trade or limit order is already active.

Near-miss labels are primarily intended for testing and configuration. They may create visual clutter during normal use.

⸻

Alerts

The indicator provides separate alert conditions for:

* LONG setup detected;
* SHORT setup detected;
* LONG limit order filled;
* SHORT limit order filled;
* target reached;
* stop-loss reached.

For confirmed signals, alerts should be configured to trigger once per bar close.

⸻

Recommended starting configuration

For index futures such as NQ or MNQ:

* Chart timeframe: 15 minutes
* HTF FVG timeframe: 240 minutes
* Entry logic: A — Strict retest
* Require M15 FVG: Enabled
* Validate only at M15 close: Enabled
* Entry type: Limit at FVG edge or Market at close
* Minimum M15 FVG size: adjust to the instrument
* Liquidity mode: Untouched liquidity only
* Minimum target R:R: 1.0–1.5
* Fallback R:R: 2.0
* London killzone: Enabled
* New York AM killzone: Enabled

The Asia and New York PM killzones can be enabled according to the instrument and the trader’s preferred session.

⸻

Practical workflow

1. Apply the indicator to an M15 chart.
2. Confirm that an HTF FVG is active in the dashboard.
3. Wait for price to move away from the HTF FVG.
4. Wait for price to return to the zone during an enabled killzone.
5. Look for a same-direction M15 FVG inside or overlapping the HTF FVG.
6. Wait for the M15 candle to close.
7. Review the proposed entry, stop and target.
8. Confirm the broader market context before placing a trade.

The indicator is best used as a structured decision-support tool rather than as a fully autonomous trading system.

⸻

Important limitations

* A confirmed H4 FVG appears only after the relevant H4 candle closes.
* The indicator will not retrospectively use an M15 FVG that formed before the H4 FVG became confirmed.
* H4 pivot liquidity is confirmed with delay because pivots require candles on both sides.
* If both the stop and target are touched during the same M15 candle, the visual trade logic uses the stop-loss as the conservative outcome.
* The script is an indicator, not a broker emulator or complete backtesting strategy.
* No indicator can guarantee profitability.

⸻

Disclaimer

This indicator is provided for educational and analytical purposes only. It does not constitute financial advice, investment advice or a recommendation to buy or sell any financial instrument.

Trading futures, leveraged products and other financial markets involves substantial risk. Users are responsible for testing the indicator, defining their own risk-management rules and determining whether the methodology is suitable for their trading plan.

## Source Code

````pine
//@version=6
// =============================================================================
// ICT SMC HTF FVG RETEST — LTF SCALPING
// v2.16 — FINAL LTF FORMATION BAR ANCHOR
//
// Confirmed HTF Fair Value Gap + LTF execution model.
//
// Core workflow:
//   1. Detect a confirmed, non-repainting HTF FVG.
//   2. Wait for price to leave the HTF zone (departure).
//   3. Wait for price to touch the zone or enter its adaptive near-touch buffer.
//   4. Fire the entry depending on the selected retest trigger:
//        - Wick / near tag : an exact touch or accepted near-touch is enough.
//        - Rejection close : wick tag + close back outside the zone.
//        - LTF FVG         : wick tag + confirming LTF FVG.
//   5. Display entry, stop and target zones.
//
// Killzones are OPTIONAL (informational unless "Restrict entries to killzones").
// Big moves often start outside killzones, so they no longer block entries.
//
// v2.0 CHANGES:
//   - Liquidity targets are now validated against the CURRENT price (refPrice),
//     not just the entry price. A level already swept by the impulse that
//     created the setup (PDH/BSL/session, or a live session high pushed by the
//     current move) can no longer be chosen as a "target already taken".
//     For continuation trades refPrice is the current bar extreme; for retest
//     trades it remains the entry.
//   - When no resting liquidity exists ahead of price, continuation trades use a
//     dedicated fallback R:R and the target is forced beyond the current extreme.
//   - The trade label and the dashboard now show the TARGET TYPE
//     (PDH, HTF BSL, Session High, Fallback...) so a projected target is
//     immediately distinguishable from real resting liquidity.
//
// v2.1 CHANGES:
//   - RETEST ZONE RE-ARM AFTER STOP-OUT. When a retest trade is stopped but the
//     HTF FVG still holds (a wick into the gap that does NOT close fully through
//     it), the zone re-arms. The stopped proposal (SL/TP zones + setup label) is
//     removed and a fresh retest signal with new SL/TP forms on the next genuine
//     tag. Gated by "Re-arm zone after SL" and "Max re-entries per zone".
//     A candle that closes fully through the gap is treated as filled: no re-arm.
//
// v2.1.1 CHANGES:
//   - RETEST TARGET MUST SIT BEYOND THE HTF FVG. A retest long now targets
//     liquidity ABOVE htfTop, a retest short liquidity BELOW htfBottom — never a
//     level inside the very gap being traded (which previously allowed an absurd
//     TP under the top of the FVG). The retest fallback target is likewise forced
//     past the gap. Continuation targets are unchanged (referenced to the current
//     extreme). The live dashboard target now uses the same beyond-gap reference.
//
// v2.2 CHANGES:
//   - RETEST STOP ANCHORED BELOW/ABOVE THE HTF FVG. "Retest stop placement" =
//     "Below HTF FVG" (default) puts the stop just beyond the HTF FVG far edge
//     (below htfBottom for a long, above htfTop for a short) — where the setup is
//     actually invalidated — instead of on the retest wick (which produced
//     absurdly tight stops and inflated R:R). "Tight" keeps the legacy behaviour.
//   - MINIMUM STOP DISTANCE floor (ticks) applied to every trade and to the live
//     preview R:R. Default 20 ticks (5.0 pts on MNQ). 0 disables it.
//   - Defaults changed on request: Strategy Mode = "Both", bullish FVG turquoise
//     and bearish FVG light-yellow, both at 34% transparency.
//
// v2.3 CHANGES:
//   - DIRECT TAP (departure optional). "Allow direct tap" (default ON) lets a
//     first tap into the HTF FVG that rejects trade WITHOUT requiring a prior
//     departure out of the gap. This fixes bearish FVGs that price rallies UP
//     into and rejects (a short), and bullish FVGs price dips into and rejects
//     (a long), which the strict retest model previously ignored because the tag
//     was gated on a departure that never happened. The chosen retest trigger
//     (wick / rejection close / LTF FVG) still defines what a valid tap is.
//     Turn OFF to restore strict "departure required" behaviour. Increases
//     signal frequency.
//   - Default FVG timeframe = M15 (paired with an M5 execution chart).
//
// v2.4 CHANGES:
//   - ⚡ INSTANT TAP ENTRY (default ON). The trade fires the exact instant a wick
//     touches an active HTF FVG (exact touch or accepted near-touch), intrabar —
//     no departure, no rejection, no bar-close wait. Direction follows the FVG
//     (bearish tapped = short, bullish = long). Entry = touch price (always market,
//     even if a limit entry is configured); SL/TP computed as usual; exits already
//     intrabar. Dedicated alerts added: "Instant TAP LONG" / "Instant TAP SHORT".
//     Pair with the existing "Touch / Proximity" alerts to be notified on any tap.
//     Turn OFF to use the standard retest / continuation logic only.
//
// v2.5 CHANGES:
//   - INSTANT TAP FIXED — now fires on EVERY live gap, including ones already
//     consumed by a previous trade. The old tap path relied on the retest
//     engine's proximity flags, which are only set for still-active zones, so a
//     tap on an already-traded FVG produced nothing. A dedicated tap detector now
//     scans every gap whose box still exists, independent of active/triggered
//     state, and re-fires each time the wick leaves and taps again. On a tap it
//     overrides the HTF scalars with that gap's geometry so the normal
//     entry / stop / target machinery builds the trade from the tapped gap.
//   - "Max instant taps per zone" (0 = unlimited) caps re-taps on the same gap.
//
// v2.6 CHANGES:
//   - CONCURRENT SESSION TRACKING. Asia, London and New York now keep separate
//     high/low state, drawings and lifecycle. An overlapping London session no
//     longer delays the New York high/low calculation until London closes.
//   - ACTIVE SESSION LIQUIDITY. Target selection checks every currently active
//     session independently and chooses the nearest valid level.
//
// v2.7 CHANGES:
//   - CLEAN TRADE DISPLAY. The new default "Active only" mode removes obsolete
//     SL/TP boxes and large setup labels as soon as a proposal is replaced,
//     expires, or reaches its SL/TP. Signal logic and alerts are unchanged.
//   - Optional "Latest only" and "Keep all" modes restore more visual history.
//   - Exit labels are capped with a user setting to prevent long-term buildup.
//
// v2.8 CHANGES:
//   - DIRECTIONAL RETEST FILTER. A bearish FVG can trigger a short only when the
//     execution candle approaches from BELOW its lower boundary. A bullish FVG
//     can trigger a long only when the candle approaches from ABOVE its upper
//     boundary. Touches entering from the wrong side are ignored.
//   - The same directional rule now applies to BOTH the standard retest engine
//     and the independent instant-tap detector.
//   - Full-close invalidation is ON by default and is monitored even after a gap
//     has already produced a signal, preventing later taps on an invalidated FVG.
//
// v2.8.1 CHANGES:
//   - EDGE-TOUCH HOTFIX. The directional filter now accepts an execution candle
//     that opens exactly on the FVG boundary (or only slightly inside the already
//     configured near-touch buffer), provided the previous candle closed on the
//     correct exterior side. The old strict `<` / `>` test could miss the first
//     bearish underside retest or bullish topside retest and signal only on a
//     later return. Wrong-side touches and full-close invalidation stay blocked.
//
// v2.9 CHANGES:
//   - CAUSAL FVG DISPLAY. By default an HTF FVG box now starts when the three-
//     candle pattern is actually confirmed and becomes knowable in real time.
//     Previously the box was drawn back from the middle HTF candle (`time[2]`).
//     On an M15 FVG this painted the zone 30 minutes into the past and could make
//     an impossible pre-confirmation "touch" look like a missed trade.
//   - Optional historical-origin extension remains available for visual study,
//     but it never backdates trades or alerts. Doing that would introduce future
//     information and repaint the historical results.
//
// v2.10 CHANGES:
//   - PERSISTENT VALID FVG DISPLAY. Producing a trade no longer freezes the
//     source FVG rectangle at the entry candle. Every confirmed FVG that remains
//     structurally valid keeps extending through the current candle, including
//     zones already used by a signal. It disappears only on true invalidation or
//     when removed by the configured maximum-zone history.
//   - Structural-origin display is restored as the default so an M15 FVG is
//     visually attached to its formation candles on an M5 chart. Signal timing
//     remains confirmation-based and non-repainting.
//   - INSTANT TAP SOURCE LOCK. Instant LONG/SHORT entries are now driven by the
//     direction of the exact selected FVG, not by aggregate proximity flags from
//     every zone touched during the candle. The setup label names its source FVG.
//
// v2.11 CHANGES:
//   - A stopped RETEST is re-armed for the very next valid correct-side touch if
//     its source FVG still holds at the M5 close. Both standard and instant-tap
//     contact latches are reset after the SL bar has already been processed, so
//     no empty "no-touch" candle is required between two attempts.
//   - "Max re-entries per zone" now uses 0 = unlimited (default), allowing fresh
//     brackets until the FVG is genuinely invalidated.
//   - Full-close invalidation is evaluated only on a confirmed execution candle;
//     a wick through the far edge no longer deletes the FVG intrabar.
//
// v2.12 CHANGES:
//   - OPPOSING FVG CONFLICT FILTER. If an execution candle validly touches a live
//     bearish FVG from below, every LONG setup on that candle is blocked, even if
//     a smaller bullish FVG is touched simultaneously underneath. The inverse
//     rule blocks SHORT setups when a live bullish FVG is touched from above.
//   - If the same M5 candle directionally touches both a bullish and bearish FVG,
//     neither direction is traded because OHLC data cannot prove touch order.
//
// v2.13 CHANGES:
//   - Restores independent scalping of every valid FVG: a bullish FVG may produce
//     a LONG below a separate bearish FVG, and vice versa. The v2.12 opposing-zone
//     veto was too restrictive for this multi-zone scalping model.
//   - When a FVG that actually produced a trade is later invalidated, its box is
//     preserved as a frozen, faint, dashed trace instead of being deleted. This
//     keeps the historical source of R-L/R-S signals auditable without preserving
//     every unused gap. Archived traces are never scanned for new trades.
//
// v2.14 CHANGES:
//   - HTF BSL/SSL lines are now created from two distinct bar coordinates at
//     the same price. This removes TradingView's vertical rendering artifact
//     caused by zero-length lines while preserving the horizontal level, sweep
//     detection, target selection and every trading signal unchanged.
//
// v2.15 CHANGES:
//   - The optional structural-origin extension is now a separate faint dotted
//     history box. The normal-colour FVG and its near-touch boundary begin only
//     on the execution bar where the HTF pattern is confirmed and knowable.
//   - This preserves the requested attachment to the formation candles without
//     making a pre-confirmation wick look like a missed tradable retest. Signal
//     timing remains confirmed, causal and non-repainting.
//   - The dashboard's Available row now reflects that Instant Tap entries can
//     operate intrabar; an open execution candle no longer displays a false no.
//
// v2.16 CHANGES:
//   - On an M15→M5 configuration, the historical left edge now begins on the
//     final M5 candle contained in the third M15 candle that confirms the FVG.
//     The old extension back to the middle M15 formation candle is removed.
//   - That single final M5 segment remains faint/dotted because the M15 FVG is
//     knowable only at its close; the normal tradable box starts on the following
//     M5 candle. This makes the visual origin exact without backdating signals.
//
// IMPORTANT:
// This indicator is an analytical tool, not financial advice.
// Past market behavior does not guarantee future results.
// The chart timeframe is always the execution timeframe (LTF).
// Examples: FVG H4 on chart M15, or FVG M15 on chart M5.
// Recreate TradingView alerts after changing the FVG or chart timeframe,
// because running alerts keep a snapshot of the old script context.
// A valid touch is stored for the complete retest validity window, and a
// retest always has priority when retest and continuation overlap.
// =============================================================================

indicator(
     "ICT SMC HTF FVG Retest + Continuation — LTF v2.16",
     shorttitle = "ICT FVG R+C",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count = 500
)

// =============================================================================
// 1. UTILITIES
// =============================================================================

f_inSession(
     bool enabled,
     string timezone,
     int startHour,
     int startMinute,
     int endHour,
     int endMinute
) =>
    if not enabled
        false
    else
        currentMinutes = hour(time, timezone) * 60 + minute(time, timezone)
        startMinutes = startHour * 60 + startMinute
        endMinutes = endHour * 60 + endMinute
        startMinutes <= endMinutes
             ? currentMinutes >= startMinutes and currentMinutes < endMinutes
             : currentMinutes >= startMinutes or currentMinutes < endMinutes

f_lineStyle(string styleName) =>
    styleName == "Dashed"
         ? line.style_dashed
         : styleName == "Dotted"
             ? line.style_dotted
             : line.style_solid

f_textSize(string sizeName) =>
    sizeName == "Tiny"
         ? size.tiny
         : sizeName == "Normal"
             ? size.normal
             : size.small

f_boolText(bool value) =>
    value ? "YES" : "no"

f_boolColor(bool value) =>
    value ? color.lime : color.red

f_statusColor(string status) =>
    status == "READY"
         ? color.lime
         : status == "WAITING"
             ? color.yellow
             : status == "OFF"
                 ? color.gray
                 : status == "N/A"
                     ? color.gray
                     : color.red

f_yesNoNa(bool relevant, bool value) =>
    not relevant ? "N/A" : value ? "YES" : "no"

f_filterText(bool enabled, bool valid) =>
    not enabled ? "OFF" : valid ? "YES" : "no"

// =============================================================================
// 1. STRATEGY MODULES
// =============================================================================

gModules = "01 — Strategy Modules"

strategyMode = input.string(
     "Both",
     "Strategy Mode",
     options = [
         "Retest only",
         "Continuation only",
         "Both"
     ],
     group = gModules,
     tooltip = "Retest only: trades returns into the confirmed HTF FVG.\nContinuation only: trades fresh same-direction LTF FVGs while price continues away from the HTF zone.\nBoth: enables both setup models."
)

enableRetestStrategy =
     strategyMode == "Retest only" or
     strategyMode == "Both"

enableContinuationStrategy =
     strategyMode == "Continuation only" or
     strategyMode == "Both"

// =============================================================================
// 2. GENERAL SETTINGS
// =============================================================================

gGeneral = "02 — General Settings"

confirmExecutionClose = input.bool(
     true,
     "Validate entries only at execution close",
     group = gGeneral,
     tooltip = "The execution timeframe is the chart timeframe. ON: entry setups wait for that candle to close. OFF: entry setups can trigger intrabar. The separate proximity alert has its own timing setting."
)

showDashboard = input.bool(
     true,
     "Show dashboard",
     group = gGeneral
)

dashboardSizeName = input.string(
     "Medium",
     "Dashboard size",
     options = ["Small", "Medium", "Large"],
     group = gGeneral,
     tooltip = "Small = compact, Medium = readable, Large = maximum readability."
)

dashboardTextSize =
     dashboardSizeName == "Small"
         ? size.tiny
         : dashboardSizeName == "Large"
             ? size.normal
             : size.small

dashboardHeaderSize =
     dashboardSizeName == "Small"
         ? size.small
         : dashboardSizeName == "Large"
             ? size.large
             : size.normal

showNearMiss = input.bool(
     false,
     "Show near misses",
     group = gGeneral
)

showProximityMarkers = input.bool(
     true,
     "Show proximity markers",
     group = gGeneral,
     tooltip = "Displays a small P-L or P-S marker when a valid FVG is touched exactly or through the adaptive near-touch buffer."
)

requireKillzone = input.bool(
     false,
     "Restrict entries to killzones",
     group = gGeneral,
     tooltip = "OFF (recommended): entries are allowed at any time. Big moves often start outside killzones. Killzones remain displayed (background + dashboard); they no longer filter entries."
)

blockWhileInTrade = input.bool(
     false,
     "Block new signals while a visual trade is open",
     group = gGeneral,
     tooltip = "OFF (recommended): arrows and alerts keep firing even if a previous visual trade has not hit its SL/TP yet. ON: original behaviour (one visual trade at a time)."
)

gTradeVisuals = "02B — Trade Visuals"

tradeVisualMode = input.string(
     "Active only",
     "Trade plan history",
     options = ["Active only", "Latest only", "Keep all"],
     group = gTradeVisuals,
     tooltip = "Active only (recommended): show SL/TP zones and the large setup label only while the currently tracked trade is pending or active. Latest only: keep the latest plan after exit, then replace it on the next setup. Keep all: legacy behaviour; every historical plan remains visible. This setting changes drawings only, never signals or alerts."
)

preserveTradedFvgTrace = input.bool(
     true,
     "Preserve source FVG after invalidation",
     group = gTradeVisuals,
     tooltip = "ON (recommended): when a FVG that generated a trade is later invalidated, keep its historical rectangle as a faint dashed trace. The archived trace is visual only and can never generate another signal. Unused invalidated FVGs are still removed."
)

maxTradedFvgTraces = input.int(
     20,
     "Maximum preserved source FVGs",
     minval = 1,
     maxval = 100,
     group = gTradeVisuals,
     tooltip = "Limits only the faint historical source traces. The oldest trace is removed first, preventing chart stacking without hiding the recent FVGs that produced trades."
)

showTradePlanZones = input.bool(
     true,
     "Show SL / TP zones",
     group = gTradeVisuals
)

showTradePlanLabel = input.bool(
     true,
     "Show setup details label",
     group = gTradeVisuals
)

maxExitMarkers = input.int(
     8,
     "Maximum TP / SL markers",
     minval = 0,
     maxval = 100,
     group = gTradeVisuals,
     tooltip = "Maximum number of small TP and SL outcome labels kept on the chart. 0 hides them. Signal markers and alerts are unaffected."
)

// =============================================================================
// 3. KILLZONES
// =============================================================================

gAsiaKz = "03 — Asia Killzone"
asiaKzEnabled = input.bool(true, "Enable", group = gAsiaKz, inline = "a1")
asiaKzColor = input.color(color.new(#2962FF, 90), "", group = gAsiaKz, inline = "a1")
asiaKzStartHour = input.int(9, "From", 0, 23, group = gAsiaKz, inline = "a2")
asiaKzStartMinute = input.int(0, ":", 0, 59, group = gAsiaKz, inline = "a2")
asiaKzEndHour = input.int(13, "To", 0, 23, group = gAsiaKz, inline = "a2")
asiaKzEndMinute = input.int(0, ":", 0, 59, group = gAsiaKz, inline = "a2")

gLondonKz = "04 — London Killzone"
londonKzEnabled = input.bool(true, "Enable", group = gLondonKz, inline = "l1")
londonKzColor = input.color(color.new(#FF9800, 90), "", group = gLondonKz, inline = "l1")
londonKzStartHour = input.int(7, "From", 0, 23, group = gLondonKz, inline = "l2")
londonKzStartMinute = input.int(0, ":", 0, 59, group = gLondonKz, inline = "l2")
londonKzEndHour = input.int(10, "To", 0, 23, group = gLondonKz, inline = "l2")
londonKzEndMinute = input.int(0, ":", 0, 59, group = gLondonKz, inline = "l2")

gNyMorningKz = "05 — New York AM Killzone"
nyMorningKzEnabled = input.bool(true, "Enable", group = gNyMorningKz, inline = "n1")
nyMorningKzColor = input.color(color.new(#00E676, 90), "", group = gNyMorningKz, inline = "n1")
nyMorningKzStartHour = input.int(9, "From", 0, 23, group = gNyMorningKz, inline = "n2")
nyMorningKzStartMinute = input.int(30, ":", 0, 59, group = gNyMorningKz, inline = "n2")
nyMorningKzEndHour = input.int(11, "To", 0, 23, group = gNyMorningKz, inline = "n2")
nyMorningKzEndMinute = input.int(0, ":", 0, 59, group = gNyMorningKz, inline = "n2")

gNyAfternoonKz = "06 — New York PM Killzone"
nyAfternoonKzEnabled = input.bool(true, "Enable", group = gNyAfternoonKz, inline = "p1")
nyAfternoonKzColor = input.color(color.new(#E040FB, 90), "", group = gNyAfternoonKz, inline = "p1")
nyAfternoonKzStartHour = input.int(13, "From", 0, 23, group = gNyAfternoonKz, inline = "p2")
nyAfternoonKzStartMinute = input.int(30, ":", 0, 59, group = gNyAfternoonKz, inline = "p2")
nyAfternoonKzEndHour = input.int(16, "To", 0, 23, group = gNyAfternoonKz, inline = "p2")
nyAfternoonKzEndMinute = input.int(0, ":", 0, 59, group = gNyAfternoonKz, inline = "p2")

inAsiaKz = f_inSession(
     asiaKzEnabled, "Asia/Tokyo",
     asiaKzStartHour, asiaKzStartMinute,
     asiaKzEndHour, asiaKzEndMinute
)

inLondonKz = f_inSession(
     londonKzEnabled, "Europe/London",
     londonKzStartHour, londonKzStartMinute,
     londonKzEndHour, londonKzEndMinute
)

inNyMorningKz = f_inSession(
     nyMorningKzEnabled, "America/New_York",
     nyMorningKzStartHour, nyMorningKzStartMinute,
     nyMorningKzEndHour, nyMorningKzEndMinute
)

inNyAfternoonKz = f_inSession(
     nyAfternoonKzEnabled, "America/New_York",
     nyAfternoonKzStartHour, nyAfternoonKzStartMinute,
     nyAfternoonKzEndHour, nyAfternoonKzEndMinute
)

inKillzone = inAsiaKz or inLondonKz or inNyMorningKz or inNyAfternoonKz

bgcolor(inAsiaKz ? asiaKzColor : na)
bgcolor(inLondonKz ? londonKzColor : na)
bgcolor(inNyMorningKz ? nyMorningKzColor : na)
bgcolor(inNyAfternoonKz ? nyAfternoonKzColor : na)

// =============================================================================
// 4. CONFIRMED HTF FVG
// =============================================================================

gHtf = "07 — HTF FVG"

htf = input.timeframe("15", "FVG timeframe", group = gHtf)
htfBullColor = input.color(color.new(#26C6DA, 34), "Bullish FVG", group = gHtf)
htfBearColor = input.color(color.new(#FFF176, 34), "Bearish FVG", group = gHtf)

extendFvgBackToFormation = input.bool(
     true,
     "Show final LTF formation candle",
     group = gHtf,
     tooltip = "ON: begin the visual FVG on the final chart-timeframe candle contained in the HTF candle that confirms it (for M15→M5, the third and final M5 candle). This one-candle segment is faint because the FVG becomes tradable only at its close. OFF begins the display directly on the following tradable candle."
)

maxTrackedFvgs = input.int(
     10,
     "Maximum tracked FVGs",
     minval = 1,
     maxval = 30,
     group = gHtf,
     tooltip = "Keeps several confirmed FVGs alive at the same time. This is especially important when the FVG timeframe is M15."
)

enableNearTouch = input.bool(
     true,
     "Accept near-touch",
     group = gHtf,
     tooltip = "Accepts a wick that stops just outside the FVG, within the adaptive buffer below. Exact touches remain valid."
)

nearTouchMinTicks = input.int(
     2,
     "Near-touch minimum (ticks)",
     minval = 0,
     maxval = 100,
     group = gHtf
)

nearTouchAtrPercent = input.float(
     3.0,
     "Near-touch buffer (% execution ATR)",
     minval = 0.0,
     maxval = 25.0,
     step = 0.25,
     group = gHtf,
     tooltip = "The accepted distance is the larger of this ATR fraction and the minimum tick distance. ATR is calculated on the chart/execution timeframe. Suggested starting point: 3%."
)

nearTouchAtrLength = input.int(
     14,
     "Near-touch ATR length",
     minval = 2,
     maxval = 100,
     group = gHtf
)

showNearTouchBoundary = input.bool(
     true,
     "Show near-touch boundary",
     group = gHtf,
     tooltip = "Draws a dotted yellow extension outside every active FVG so accepted proximity is visually auditable."
)

proximityAlertTiming = input.string(
     "Intrabar",
     "Proximity alert timing",
     options = ["Intrabar", "Execution close"],
     group = gHtf,
     tooltip = "Intrabar is the earliest warning; create the TradingView alert with Once per bar frequency. Execution close waits for the chart candle to close. Entry alerts still follow the separate execution-close setting."
)

invalidateOnFullClose = input.bool(
     true,
     "Invalidate on full close through the zone",
     group = gHtf,
     tooltip = "ON (recommended): a bearish FVG is invalidated by a close above its upper boundary; a bullish FVG by a close below its lower boundary. The check remains active even after the zone has already produced a signal."
)

// The last confirmed HTF candle is [1].
// The candle two HTF periods before it is [3].
// lookahead_on is safe here because all requested values are offset.
f_confirmedHtfFvg() =>
    bull = low[1] > high[3]
    bear = high[1] < low[3]

    float zoneTop = na
    float zoneBottom = na
    int direction = 0
    int middleTime = na

    if bull
        zoneTop := low[1]
        zoneBottom := high[3]
        direction := 1
        middleTime := time[2]
    else if bear
        zoneTop := low[3]
        zoneBottom := high[1]
        direction := -1
        middleTime := time[2]

    [zoneTop, zoneBottom, direction, middleTime]

[htfTopSeries, htfBottomSeries, htfDirectionSeries, htfMiddleTimeSeries] =
     request.security(
         syminfo.tickerid,
         htf,
         f_confirmedHtfFvg(),
         lookahead = barmerge.lookahead_on
     )

chartTimeframeSeconds = timeframe.in_seconds()
fvgTimeframeSeconds = timeframe.in_seconds(htf)
validTimeframePair =
     not na(chartTimeframeSeconds) and
     not na(fvgTimeframeSeconds) and
     fvgTimeframeSeconds > chartTimeframeSeconds

if barstate.isfirst and not validTimeframePair
    runtime.error("The FVG timeframe must be higher than the chart/execution timeframe. Examples: H4 FVG on M15, or M15 FVG on M5.")

// =============================================================================
// 6. RETEST STRATEGY — LTF FVG / ENTRY
// =============================================================================

gEntry = "08 — Retest Strategy"

useMinimumLTFSize = input.bool(true, "Filter small LTF FVGs", group = gEntry)
minimumLTFPoints = input.float(6.0, "Minimum size in points", 0, step = 0.25, group = gEntry)
stopBufferTicks = input.int(2, "Stop buffer in ticks", 0, group = gEntry)

retestStopMode = input.string(
     "Below HTF FVG",
     "Retest stop placement",
     options = ["Below HTF FVG", "Tight (LTF FVG / wick)"],
     group = gEntry,
     tooltip = "Below HTF FVG (recommended): the stop is anchored just beyond the HTF FVG far edge (below htfBottom for a long, above htfTop for a short), i.e. where the setup is actually invalidated. Tight: legacy behaviour — stop at the LTF FVG edge or the retest wick, which can be only a few ticks and inflates R:R."
)

minStopTicks = input.int(
     20,
     "Minimum stop distance (ticks)",
     minval = 0,
     maxval = 400,
     group = gEntry,
     tooltip = "Floor applied to every trade's stop distance. If the anchored stop is closer than this, the stop is widened to this distance. 20 ticks = 5.0 points on MNQ. Set 0 to disable."
)

limitExpirationBars = input.int(12, "Limit order expiration in bars", 1, group = gEntry)

allowReentryAfterSl = input.bool(
     true,
     "Re-arm zone after SL",
     group = gEntry,
     tooltip = "When a RETEST trade is stopped out but the HTF FVG still holds (wick into the gap, close that does NOT go fully through it), the zone is re-armed. The stopped proposal is removed and a fresh retest signal — with new SL/TP — can form on the next genuine tag. If the candle closes fully through the gap, the zone is considered filled and is NOT re-armed."
)

maxReentriesPerZone = input.int(
     0,
     "Max re-entries per zone (0 = unlimited)",
     minval = 0,
     maxval = 50,
     group = gEntry,
     tooltip = "How many times a valid HTF FVG may be re-armed after a stop-out. 0 (recommended) = unlimited fresh attempts until a confirmed candle invalidates the FVG. 1 = one additional attempt after the initial trade."
)

retestValidBars = input.int(
     8,
     "Retest validity window (bars)",
     minval = 1,
     maxval = 50,
     group = gEntry,
     tooltip = "After price tags the HTF FVG or its near-touch buffer, every retest trigger — including Wick tag — stays armed for this many execution/chart bars. Example: 8 means 120 minutes on M15, or 40 minutes on M5."
)

requireLTFFvg = input.bool(
     true,
     "Require an LTF FVG",
     group = gEntry,
     tooltip = "Applies to the Direct (B) entry logic. The Retest logic (A/A') is driven by the 'Retest trigger' selector below."
)

allowDirectTap = input.bool(
     true,
     "Allow direct tap (departure optional)",
     group = gEntry,
     tooltip = "ON (default): a first tap into the HTF FVG that rejects is enough to trade, even if price never left the gap first. This catches a bearish FVG that price rallies UP into and rejects (a short), or a bullish FVG price dips into and rejects (a long), without waiting for a prior departure. The chosen 'Retest trigger' still decides what counts as a valid tap (wick / rejection close / LTF FVG). OFF: strict retest — a departure out of the gap is required before any entry (legacy behaviour). Note: ON increases signal frequency."
)

requireDirectionalRetest = input.bool(
     true,
     "Require retest from the correct side",
     group = gEntry,
     tooltip = "ON (recommended): bearish FVG short only when the previous close is below/on the lower boundary and the current candle opens below/on it (a small opening overlap no larger than the configured near-touch buffer is accepted), followed by a wick upward into/near the boundary. Bullish FVG long uses the exact inverse rule. OFF restores the legacy any-side touch behaviour."
)

retestTrigger = input.string(
     "Wick tag",
     "Retest trigger",
     options = ["Wick tag", "Rejection close", "LTF FVG"],
     group = gEntry,
     tooltip = "Drives the RETEST trigger (modes A/A'):\nWick tag: an exact touch or accepted near-touch is enough.\nRejection close: fresh tag + close back outside the zone.\nLTF FVG: fresh tag + execution-timeframe FVG in the trade direction."
)

entryType = input.string(
     "Market at close",
     "Entry type",
     options = ["Market at close", "Limit at FVG edge"],
     group = gEntry
)

useLimitEntry = entryType == "Limit at FVG edge"

instantTapEntry = input.bool(
     true,
     "⚡ Instant tap entry (fire on wick touch)",
     group = gEntry,
     tooltip = "ON: the trade fires the exact moment a wick touches an active HTF FVG (exact touch OR accepted near-touch), intrabar — no departure, no rejection, no bar-close wait. Direction follows the FVG (bearish FVG touched = short, bullish = long). Entry = touch price, SL/TP still computed normally. Works on EVERY live gap, including ones already traded, and re-fires each time the wick leaves and taps again. OFF: use the standard retest / continuation logic only."
)

maxTapsPerZone = input.int(
     0,
     "Max instant taps per zone (0 = unlimited)",
     minval = 0,
     maxval = 50,
     group = gEntry,
     tooltip = "How many instant-tap trades a single FVG may generate. 0 = unlimited (every fresh tap fires). Set e.g. 2 to cap re-taps on the same gap."
)

entryLogic = input.string(
     "A — Strict retest",
     "Entry logic",
     options = [
         "A — Strict retest",
         "A' — Tolerant retest",
         "B — Direct tap in killzone"
     ],
     group = gEntry,
     tooltip = "A: an execution candle must close outside the HTF FVG before a return.\nA': a wick outside is enough to validate departure.\nB: no prior departure is required. 'Tolerant' concerns departure; near-touch is configured separately."
)

modeStrict = entryLogic == "A — Strict retest"
modeTolerant = entryLogic == "A' — Tolerant retest"
modeDirect = entryLogic == "B — Direct tap in killzone"

ltfBull = low > high[2]
ltfBear = high < low[2]

ltfBullTop = low
ltfBullBottom = high[2]
ltfBearTop = low[2]
ltfBearBottom = high

ltfBullHeight = ltfBullTop - ltfBullBottom
ltfBearHeight = ltfBearTop - ltfBearBottom

ltfBullSizeOk = not useMinimumLTFSize or ltfBullHeight >= minimumLTFPoints
ltfBearSizeOk = not useMinimumLTFSize or ltfBearHeight >= minimumLTFPoints

barConfirmed = not confirmExecutionClose or barstate.isconfirmed

// =============================================================================
// 7. CONTINUATION STRATEGY
// =============================================================================

gContinuation = "09 — Continuation Strategy"

enableBullContinuation = input.bool(
     true,
     "Enable Bullish Continuation",
     group = gContinuation
)

enableBearContinuation = input.bool(
     true,
     "Enable Bearish Continuation",
     group = gContinuation
)

continuationRequireKillzone = input.bool(
     false,
     "Require an active killzone",
     group = gContinuation
)

continuationRequireStructureBreak = input.bool(
     false,
     "Require local structure break",
     group = gContinuation,
     tooltip = "Bullish: close above the recent local high. Bearish: close below the recent local low."
)

continuationStructureLookback = input.int(
     4,
     "Structure lookback",
     minval = 2,
     maxval = 20,
     group = gContinuation
)

continuationMaxBars = input.int(
     16,
     "Maximum LTF bars after HTF FVG confirmation",
     minval = 1,
     maxval = 96,
     group = gContinuation,
     tooltip = "Prevents continuation entries too long after the HTF FVG was confirmed."
)

continuationAtrLength = input.int(
     14,
     "ATR length",
     minval = 2,
     maxval = 100,
     group = gContinuation
)

continuationMaxDistanceAtr = input.float(
     3.0,
     "Maximum distance from HTF FVG in ATR",
     minval = 0.25,
     maxval = 20.0,
     step = 0.25,
     group = gContinuation,
     tooltip = "Avoids chasing a continuation after price has moved too far away from the HTF FVG. For a momentum style, 1.0–1.5 is stricter and avoids late entries."
)

continuationEntryType = input.string(
     "Limit at LTF FVG edge",
     "Continuation entry type",
     options = ["Market at close", "Limit at LTF FVG edge"],
     group = gContinuation
)

continuationUseLimitEntry = continuationEntryType == "Limit at LTF FVG edge"

continuationFallbackRr = input.float(
     3.0,
     "Continuation fallback R:R (no fresh liquidity)",
     minval = 0.5,
     step = 0.1,
     group = gContinuation,
     tooltip = "Used when no resting liquidity exists BEYOND the current price. The target is projected at this R:R from the entry and forced past the current extreme, so it is never marked 'already taken'."
)

continuationLongColor = input.color(
     #00C853,
     "Bullish marker color",
     group = gContinuation,
     inline = "cc"
)

continuationShortColor = input.color(
     #FF1744,
     "Bearish marker color",
     group = gContinuation,
     inline = "cc"
)

// =============================================================================
// 8. TARGETS AND LIQUIDITY
// =============================================================================

gTargets = "10 — Targets"

useLiquidityTarget = input.bool(true, "Target liquidity", group = gTargets)
fallbackRr = input.float(2.0, "Fallback fixed R:R", 0.5, step = 0.1, group = gTargets)
minimumTargetRr = input.float(1.0, "Minimum target R:R", 0.5, step = 0.1, group = gTargets)
keepSessions = input.int(3, "Stored sessions", 1, 10, group = gTargets)
htfSwingLength = input.int(10, "HTF pivot lookback", 2, 30, group = gTargets)
keepSwings = input.int(3, "Stored HTF SSL/BSL levels", 1, 10, group = gTargets)
labelOffset = input.int(2, "Label offset", 0, 100, group = gTargets)

liquidityMode = input.string(
     "Legacy v3.3",
     "Swept liquidity handling",
     options = [
         "Legacy v3.3",
         "Untouched liquidity only"
     ],
     group = gTargets,
     tooltip = "Legacy: previously swept levels may still be used as targets.\nUntouched only: a swept occurrence is disabled. A new pivot or session may create a new active occurrence at the same price.\nNote: since v2.0, a target must in any case sit BEYOND the current price, which already excludes most swept levels."
)

intactOnly = liquidityMode == "Untouched liquidity only"

// =============================================================================
// 7. SESSION LEVELS DISPLAY
// =============================================================================

gSessionVisual = "11 — Session Levels"

showSessionLevels = input.bool(true, "Show levels", group = gSessionVisual)
showSessionLabels = input.bool(true, "Show labels", group = gSessionVisual)

asiaLevelColor = input.color(#2962FF, "Asia", group = gSessionVisual, inline = "sc")
londonLevelColor = input.color(#8D6E63, "London", group = gSessionVisual, inline = "sc")
nyLevelColor = input.color(#EF5350, "NY", group = gSessionVisual, inline = "sc")

differentiateHighLow = input.bool(false, "Differentiate High/Low by style", group = gSessionVisual)

sessionLineWidth = input.int(1, "Line width", 1, 4, group = gSessionVisual, inline = "sl")
sessionStyleName = input.string("Dashed", "High style", options = ["Solid", "Dashed", "Dotted"], group = gSessionVisual, inline = "sl")
sessionTextSizeName = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gSessionVisual)

sessionHighStyle = f_lineStyle(sessionStyleName)
sessionLowStyle = differentiateHighLow ? line.style_dotted : sessionHighStyle
sessionTextSize = f_textSize(sessionTextSizeName)

f_sessionColor(string sessionName) =>
    sessionName == "Asia"
         ? asiaLevelColor
         : sessionName == "London"
             ? londonLevelColor
             : nyLevelColor

// =============================================================================
// 8. SSL / BSL DISPLAY
// =============================================================================

gSwingVisual = "12 — HTF SSL / BSL"

showSwingLevels = input.bool(true, "Show levels", group = gSwingVisual)
showSwingLabels = input.bool(true, "Show labels", group = gSwingVisual)
bslColor = input.color(#AB47BC, "BSL", group = gSwingVisual, inline = "c")
sslColor = input.color(#5C6BC0, "SSL", group = gSwingVisual, inline = "c")
swingLineWidth = input.int(1, "Line width", 1, 4, group = gSwingVisual, inline = "w")
swingStyleName = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = gSwingVisual, inline = "w")
swingTextSizeName = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gSwingVisual)

swingStyle = f_lineStyle(swingStyleName)
swingTextSize = f_textSize(swingTextSizeName)

// =============================================================================
// 8B. PREVIOUS DAY HIGH / LOW
// =============================================================================

gPreviousDay = "13 — Previous Day High / Low"

showPreviousDayLevels = input.bool(
     true,
     "Show PDH / PDL",
     group = gPreviousDay
)

showPreviousDayLabels = input.bool(
     true,
     "Show labels",
     group = gPreviousDay
)

usePreviousDayAsTarget = input.bool(
     true,
     "Use PDH / PDL as liquidity targets",
     group = gPreviousDay
)

pdhColor = input.color(
     #FFB300,
     "PDH color",
     group = gPreviousDay,
     inline = "pdc"
)

pdlColor = input.color(
     #00ACC1,
     "PDL color",
     group = gPreviousDay,
     inline = "pdc"
)

previousDayLineWidth = input.int(
     2,
     "Line width",
     minval = 1,
     maxval = 4,
     group = gPreviousDay,
     inline = "pdw"
)

previousDayStyleName = input.string(
     "Dashed",
     "Line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = gPreviousDay,
     inline = "pdw"
)

previousDayTextSizeName = input.string(
     "Small",
     "Text size",
     options = ["Tiny", "Small", "Normal"],
     group = gPreviousDay
)

previousDayStyle = f_lineStyle(previousDayStyleName)
previousDayTextSize = f_textSize(previousDayTextSizeName)

// Confirmed previous daily candle.
// lookahead_on is safe because the requested values are offset by [1].
previousDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     lookahead = barmerge.lookahead_on
)

previousDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     lookahead = barmerge.lookahead_on
)

newTradingDay = ta.change(time("D")) != 0

var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na
var bool pdhActive = true
var bool pdlActive = true

if barstate.isfirst or newTradingDay
    pdhActive := true
    pdlActive := true

    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdhLabel)
        label.delete(pdhLabel)
    if not na(pdlLabel)
        label.delete(pdlLabel)

    pdhLine := showPreviousDayLevels
         ? line.new(
             bar_index,
             previousDayHigh,
             bar_index + 1,
             previousDayHigh,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = pdhColor,
             width = previousDayLineWidth,
             style = previousDayStyle
         )
         : na

    pdlLine := showPreviousDayLevels
         ? line.new(
             bar_index,
             previousDayLow,
             bar_index + 1,
             previousDayLow,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = pdlColor,
             width = previousDayLineWidth,
             style = previousDayStyle
         )
         : na

    pdhLabel := showPreviousDayLevels and showPreviousDayLabels
         ? label.new(
             bar_index + labelOffset,
             previousDayHigh,
             "PDH  " + str.tostring(previousDayHigh, format.mintick),
             color = color.new(pdhColor, 20),
             textcolor = color.white,
             style = label.style_label_left,
             size = previousDayTextSize
         )
         : na

    pdlLabel := showPreviousDayLevels and showPreviousDayLabels
         ? label.new(
             bar_index + labelOffset,
             previousDayLow,
             "PDL  " + str.tostring(previousDayLow, format.mintick),
             color = color.new(pdlColor, 20),
             textcolor = color.white,
             style = label.style_label_left,
             size = previousDayTextSize
         )
         : na

if showPreviousDayLevels
    if not na(pdhLabel)
        label.set_x(pdhLabel, bar_index + labelOffset)
        label.set_y(pdhLabel, previousDayHigh)
        label.set_text(pdhLabel, "PDH  " + str.tostring(previousDayHigh, format.mintick))

    if not na(pdlLabel)
        label.set_x(pdlLabel, bar_index + labelOffset)
        label.set_y(pdlLabel, previousDayLow)
        label.set_text(pdlLabel, "PDL  " + str.tostring(previousDayLow, format.mintick))

// Mark each daily level as swept for the current trading day.
if pdhActive and high >= previousDayHigh
    pdhActive := false

    if not na(pdhLine)
        line.set_extend(pdhLine, extend.none)
        line.set_x2(pdhLine, bar_index)
        line.set_color(pdhLine, color.new(pdhColor, 75))
        line.set_style(pdhLine, line.style_dotted)

    if not na(pdhLabel)
        label.set_color(pdhLabel, color.new(pdhColor, 75))

if pdlActive and low <= previousDayLow
    pdlActive := false

    if not na(pdlLine)
        line.set_extend(pdlLine, extend.none)
        line.set_x2(pdlLine, bar_index)
        line.set_color(pdlLine, color.new(pdlColor, 75))
        line.set_style(pdlLine, line.style_dotted)

    if not na(pdlLabel)
        label.set_color(pdlLabel, color.new(pdlColor, 75))

// =============================================================================
// 9. MARKET SESSIONS — DST AWARE
// =============================================================================

gSessions = "14 — Session Windows"

asiaSessionStartHour = input.int(8, "Asia de H", 0, 23, group = gSessions, inline = "as")
asiaSessionStartMinute = input.int(0, ":", 0, 59, group = gSessions, inline = "as")
asiaSessionEndHour = input.int(15, "To", 0, 23, group = gSessions, inline = "as")
asiaSessionEndMinute = input.int(0, ":", 0, 59, group = gSessions, inline = "as")

londonSessionStartHour = input.int(7, "London de H", 0, 23, group = gSessions, inline = "ls")
londonSessionStartMinute = input.int(0, ":", 0, 59, group = gSessions, inline = "ls")
londonSessionEndHour = input.int(16, "To", 0, 23, group = gSessions, inline = "ls")
londonSessionEndMinute = input.int(30, ":", 0, 59, group = gSessions, inline = "ls")

nySessionStartHour = input.int(9, "New York from", 0, 23, group = gSessions, inline = "ns")
nySessionStartMinute = input.int(30, ":", 0, 59, group = gSessions, inline = "ns")
nySessionEndHour = input.int(16, "To", 0, 23, group = gSessions, inline = "ns")
nySessionEndMinute = input.int(0, ":", 0, 59, group = gSessions, inline = "ns")

inAsiaSession = f_inSession(
     true, "Asia/Tokyo",
     asiaSessionStartHour, asiaSessionStartMinute,
     asiaSessionEndHour, asiaSessionEndMinute
)

inLondonSession = f_inSession(
     true, "Europe/London",
     londonSessionStartHour, londonSessionStartMinute,
     londonSessionEndHour, londonSessionEndMinute
)

inNySession = f_inSession(
     true, "America/New_York",
     nySessionStartHour, nySessionStartMinute,
     nySessionEndHour, nySessionEndMinute
)

// =============================================================================
// 10. CONCURRENT SESSION STATE
// =============================================================================

var array<string> frozenNames = array.new_string()

var array<float> frozenHighPrices = array.new_float()
var array<bool> frozenHighActive = array.new_bool()
var array<line> frozenHighLines = array.new_line()
var array<label> frozenHighLabels = array.new_label()

var array<float> frozenLowPrices = array.new_float()
var array<bool> frozenLowActive = array.new_bool()
var array<line> frozenLowLines = array.new_line()
var array<label> frozenLowLabels = array.new_label()

f_freezeSession(
     string name,
     float highPrice,
     float lowPrice,
     line highLine,
     line lowLine,
     label highLabel,
     label lowLabel
) =>
    array.push(frozenNames, name)

    array.push(frozenHighPrices, highPrice)
    array.push(frozenHighActive, true)
    array.push(frozenHighLines, highLine)
    array.push(frozenHighLabels, highLabel)

    array.push(frozenLowPrices, lowPrice)
    array.push(frozenLowActive, true)
    array.push(frozenLowLines, lowLine)
    array.push(frozenLowLabels, lowLabel)

    if array.size(frozenNames) > keepSessions
        array.shift(frozenNames)

        array.shift(frozenHighPrices)
        array.shift(frozenHighActive)
        oldHighLine = array.shift(frozenHighLines)
        oldHighLabel = array.shift(frozenHighLabels)

        array.shift(frozenLowPrices)
        array.shift(frozenLowActive)
        oldLowLine = array.shift(frozenLowLines)
        oldLowLabel = array.shift(frozenLowLabels)

        if not na(oldHighLine)
            line.delete(oldHighLine)
        if not na(oldHighLabel)
            label.delete(oldHighLabel)
        if not na(oldLowLine)
            line.delete(oldLowLine)
        if not na(oldLowLabel)
            label.delete(oldLowLabel)

// Each market owns an independent state object. This is essential because the
// London and New York windows overlap for several hours every trading day.
type SessionTracker
    float sessionHigh = na
    float sessionLow = na
    int startBar = na
    line highLine = na
    line lowLine = na
    label highLabel = na
    label lowLabel = na

var SessionTracker asiaSession = SessionTracker.new()
var SessionTracker londonSession = SessionTracker.new()
var SessionTracker nySession = SessionTracker.new()

f_updateSession(
     SessionTracker tracker,
     string sessionName,
     bool inSession
) =>
    sessionStarted = inSession and not inSession[1]
    sessionEnded = not inSession and inSession[1]

    if sessionEnded and not na(tracker.sessionHigh) and not na(tracker.sessionLow)
        if not na(tracker.highLabel)
            label.set_x(tracker.highLabel, bar_index[1] + labelOffset)

        if not na(tracker.lowLabel)
            label.set_x(tracker.lowLabel, bar_index[1] + labelOffset)

        f_freezeSession(
             sessionName,
             tracker.sessionHigh,
             tracker.sessionLow,
             tracker.highLine,
             tracker.lowLine,
             tracker.highLabel,
             tracker.lowLabel
        )

        tracker.sessionHigh := na
        tracker.sessionLow := na
        tracker.startBar := na
        tracker.highLine := na
        tracker.lowLine := na
        tracker.highLabel := na
        tracker.lowLabel := na

    if sessionStarted
        tracker.sessionHigh := high
        tracker.sessionLow := low
        tracker.startBar := bar_index

        sessionColor = f_sessionColor(sessionName)

        tracker.highLine := showSessionLevels
             ? line.new(
                 bar_index, high, bar_index, high,
                 xloc = xloc.bar_index,
                 color = sessionColor,
                 width = sessionLineWidth,
                 style = sessionHighStyle,
                 extend = extend.right
             )
             : na

        tracker.lowLine := showSessionLevels
             ? line.new(
                 bar_index, low, bar_index, low,
                 xloc = xloc.bar_index,
                 color = sessionColor,
                 width = sessionLineWidth,
                 style = sessionLowStyle,
                 extend = extend.right
             )
             : na

        tracker.highLabel := showSessionLevels and showSessionLabels
             ? label.new(
                 bar_index + labelOffset,
                 high,
                 sessionName + " H  " + str.tostring(high, format.mintick),
                 color = color.new(sessionColor, 20),
                 textcolor = color.white,
                 style = label.style_label_left,
                 size = sessionTextSize
             )
             : na

        tracker.lowLabel := showSessionLevels and showSessionLabels
             ? label.new(
                 bar_index + labelOffset,
                 low,
                 sessionName + " L  " + str.tostring(low, format.mintick),
                 color = color.new(sessionColor, 20),
                 textcolor = color.white,
                 style = label.style_label_left,
                 size = sessionTextSize
             )
             : na

    else if inSession
        tracker.sessionHigh := na(tracker.sessionHigh)
             ? high
             : math.max(tracker.sessionHigh, high)
        tracker.sessionLow := na(tracker.sessionLow)
             ? low
             : math.min(tracker.sessionLow, low)

        if not na(tracker.highLine)
            line.set_xy1(tracker.highLine, tracker.startBar, tracker.sessionHigh)
            line.set_xy2(tracker.highLine, bar_index, tracker.sessionHigh)

        if not na(tracker.lowLine)
            line.set_xy1(tracker.lowLine, tracker.startBar, tracker.sessionLow)
            line.set_xy2(tracker.lowLine, bar_index, tracker.sessionLow)

        if not na(tracker.highLabel)
            label.set_xy(tracker.highLabel, bar_index + labelOffset, tracker.sessionHigh)
            label.set_text(
                 tracker.highLabel,
                 sessionName + " H  " + str.tostring(tracker.sessionHigh, format.mintick)
            )

        if not na(tracker.lowLabel)
            label.set_xy(tracker.lowLabel, bar_index + labelOffset, tracker.sessionLow)
            label.set_text(
                 tracker.lowLabel,
                 sessionName + " L  " + str.tostring(tracker.sessionLow, format.mintick)
            )

    tracker

f_updateSession(asiaSession, "Asia", inAsiaSession)
f_updateSession(londonSession, "London", inLondonSession)
f_updateSession(nySession, "NY", inNySession)

// =============================================================================
// 11. HTF SSL / BSL
// =============================================================================

f_htfPivots() =>
    pivotHigh = ta.pivothigh(high, htfSwingLength, htfSwingLength)
    pivotLow = ta.pivotlow(low, htfSwingLength, htfSwingLength)
    [pivotHigh, pivotLow]

[htfPivotHigh, htfPivotLow] =
     request.security(
         syminfo.tickerid,
         htf,
         f_htfPivots(),
         lookahead = barmerge.lookahead_off
     )

var array<float> bslPrices = array.new_float()
var array<bool> bslActive = array.new_bool()
var array<line> bslLines = array.new_line()
var array<label> bslLabels = array.new_label()

var array<float> sslPrices = array.new_float()
var array<bool> sslActive = array.new_bool()
var array<line> sslLines = array.new_line()
var array<label> sslLabels = array.new_label()

newBsl = not na(htfPivotHigh) and (na(htfPivotHigh[1]) or htfPivotHigh != htfPivotHigh[1])
newSsl = not na(htfPivotLow) and (na(htfPivotLow[1]) or htfPivotLow != htfPivotLow[1])

if newBsl
    newLine = showSwingLevels
         ? line.new(
             bar_index, htfPivotHigh, bar_index + 1, htfPivotHigh,
             xloc = xloc.bar_index,
             color = bslColor,
             width = swingLineWidth,
             style = swingStyle,
             extend = extend.right
         )
         : na

    newLabel = showSwingLevels and showSwingLabels
         ? label.new(
             bar_index + labelOffset,
             htfPivotHigh,
             "BSL HTF  " + str.tostring(htfPivotHigh, format.mintick),
             color = color.new(bslColor, 20),
             textcolor = color.white,
             style = label.style_label_left,
             size = swingTextSize
         )
         : na

    array.push(bslPrices, htfPivotHigh)
    array.push(bslActive, true)
    array.push(bslLines, newLine)
    array.push(bslLabels, newLabel)

    if array.size(bslPrices) > keepSwings
        array.shift(bslPrices)
        array.shift(bslActive)
        oldLine = array.shift(bslLines)
        oldLabel = array.shift(bslLabels)

        if not na(oldLine)
            line.delete(oldLine)
        if not na(oldLabel)
            label.delete(oldLabel)

if newSsl
    newLine = showSwingLevels
         ? line.new(
             bar_index, htfPivotLow, bar_index + 1, htfPivotLow,
             xloc = xloc.bar_index,
             color = sslColor,
             width = swingLineWidth,
             style = swingStyle,
             extend = extend.right
         )
         : na

    newLabel = showSwingLevels and showSwingLabels
         ? label.new(
             bar_index + labelOffset,
             htfPivotLow,
             "SSL HTF  " + str.tostring(htfPivotLow, format.mintick),
             color = color.new(sslColor, 20),
             textcolor = color.white,
             style = label.style_label_left,
             size = swingTextSize
         )
         : na

    array.push(sslPrices, htfPivotLow)
    array.push(sslActive, true)
    array.push(sslLines, newLine)
    array.push(sslLabels, newLabel)

    if array.size(sslPrices) > keepSwings
        array.shift(sslPrices)
        array.shift(sslActive)
        oldLine = array.shift(sslLines)
        oldLabel = array.shift(sslLabels)

        if not na(oldLine)
            line.delete(oldLine)
        if not na(oldLabel)
            label.delete(oldLabel)

// =============================================================================
// 12. SWEPT LIQUIDITY
// =============================================================================

if intactOnly
    if array.size(frozenHighPrices) > 0
        for i = 0 to array.size(frozenHighPrices) - 1
            levelPrice = array.get(frozenHighPrices, i)
            levelActive = array.get(frozenHighActive, i)

            if levelActive and high >= levelPrice
                array.set(frozenHighActive, i, false)

                levelLine = array.get(frozenHighLines, i)
                levelLabel = array.get(frozenHighLabels, i)

                if not na(levelLine)
                    line.set_extend(levelLine, extend.none)
                    line.set_x2(levelLine, bar_index)
                    line.set_color(levelLine, color.new(asiaLevelColor, 75))
                    line.set_style(levelLine, line.style_dotted)

                if not na(levelLabel)
                    label.set_color(levelLabel, color.new(color.gray, 75))

    if array.size(frozenLowPrices) > 0
        for i = 0 to array.size(frozenLowPrices) - 1
            levelPrice = array.get(frozenLowPrices, i)
            levelActive = array.get(frozenLowActive, i)

            if levelActive and low <= levelPrice
                array.set(frozenLowActive, i, false)

                levelLine = array.get(frozenLowLines, i)
                levelLabel = array.get(frozenLowLabels, i)

                if not na(levelLine)
                    line.set_extend(levelLine, extend.none)
                    line.set_x2(levelLine, bar_index)
                    line.set_color(levelLine, color.new(asiaLevelColor, 75))
                    line.set_style(levelLine, line.style_dotted)

                if not na(levelLabel)
                    label.set_color(levelLabel, color.new(color.gray, 75))

    if array.size(bslPrices) > 0
        for i = 0 to array.size(bslPrices) - 1
            levelPrice = array.get(bslPrices, i)
            levelActive = array.get(bslActive, i)

            if levelActive and high >= levelPrice
                array.set(bslActive, i, false)

                levelLine = array.get(bslLines, i)
                levelLabel = array.get(bslLabels, i)

                if not na(levelLine)
                    line.set_extend(levelLine, extend.none)
                    // Keep two distinct X coordinates even when the newly
                    // confirmed pivot is swept on its creation bar.
                    bslEndBar = math.max(bar_index, line.get_x1(levelLine) + 1)
                    line.set_x2(levelLine, bslEndBar)
                    line.set_color(levelLine, color.new(bslColor, 75))
                    line.set_style(levelLine, line.style_dotted)

                if not na(levelLabel)
                    label.set_color(levelLabel, color.new(bslColor, 75))

    if array.size(sslPrices) > 0
        for i = 0 to array.size(sslPrices) - 1
            levelPrice = array.get(sslPrices, i)
            levelActive = array.get(sslActive, i)

            if levelActive and low <= levelPrice
                array.set(sslActive, i, false)

                levelLine = array.get(sslLines, i)
                levelLabel = array.get(sslLabels, i)

                if not na(levelLine)
                    line.set_extend(levelLine, extend.none)
                    // Symmetric zero-length protection for SSL levels.
                    sslEndBar = math.max(bar_index, line.get_x1(levelLine) + 1)
                    line.set_x2(levelLine, sslEndBar)
                    line.set_color(levelLine, color.new(sslColor, 75))
                    line.set_style(levelLine, line.style_dotted)

                if not na(levelLabel)
                    label.set_color(levelLabel, color.new(sslColor, 75))

// =============================================================================
// 13. TARGET SELECTION
// =============================================================================

f_levelUsable(bool active) =>
    not intactOnly or active

// v2.0: refPrice = the reference the target must sit BEYOND.
// For continuation, callers pass the current bar extreme (high/low), so a level
// already swept by the impulse — or a live session high that the current move is
// itself pushing — can no longer be chosen. The R:R distance is still measured
// from entryPrice. minimumTargetRr still guarantees enough room from the entry.
f_pickTarget(
     bool isShort,
     float entryPrice,
     float risk,
     float refPrice
) =>
    float bestTarget = na
    string bestType = "None"
    minimumDistance = minimumTargetRr * risk

    if isShort
        if array.size(frozenLowPrices) > 0
            for i = 0 to array.size(frozenLowPrices) - 1
                levelPrice = array.get(frozenLowPrices, i)
                active = array.get(frozenLowActive, i)

                if f_levelUsable(active) and
                   levelPrice < refPrice and
                   entryPrice - levelPrice >= minimumDistance
                    if na(bestTarget) or levelPrice > bestTarget
                        bestTarget := levelPrice
                        bestType := "Session Low"

        if array.size(sslPrices) > 0
            for i = 0 to array.size(sslPrices) - 1
                levelPrice = array.get(sslPrices, i)
                active = array.get(sslActive, i)

                if f_levelUsable(active) and
                   levelPrice < refPrice and
                   entryPrice - levelPrice >= minimumDistance
                    if na(bestTarget) or levelPrice > bestTarget
                        bestTarget := levelPrice
                        bestType := "HTF SSL"

        if usePreviousDayAsTarget and
           f_levelUsable(pdlActive) and
           previousDayLow < refPrice and
           entryPrice - previousDayLow >= minimumDistance
            if na(bestTarget) or previousDayLow > bestTarget
                bestTarget := previousDayLow
                bestType := "PDL"

        if not na(asiaSession.sessionLow) and
           asiaSession.sessionLow < refPrice and
           entryPrice - asiaSession.sessionLow >= minimumDistance
            if na(bestTarget) or asiaSession.sessionLow > bestTarget
                bestTarget := asiaSession.sessionLow
                bestType := "Current Asia Low"

        if not na(londonSession.sessionLow) and
           londonSession.sessionLow < refPrice and
           entryPrice - londonSession.sessionLow >= minimumDistance
            if na(bestTarget) or londonSession.sessionLow > bestTarget
                bestTarget := londonSession.sessionLow
                bestType := "Current London Low"

        if not na(nySession.sessionLow) and
           nySession.sessionLow < refPrice and
           entryPrice - nySession.sessionLow >= minimumDistance
            if na(bestTarget) or nySession.sessionLow > bestTarget
                bestTarget := nySession.sessionLow
                bestType := "Current NY Low"

    else
        if array.size(frozenHighPrices) > 0
            for i = 0 to array.size(frozenHighPrices) - 1
                levelPrice = array.get(frozenHighPrices, i)
                active = array.get(frozenHighActive, i)

                if f_levelUsable(active) and
                   levelPrice > refPrice and
                   levelPrice - entryPrice >= minimumDistance
                    if na(bestTarget) or levelPrice < bestTarget
                        bestTarget := levelPrice
                        bestType := "Session High"

        if array.size(bslPrices) > 0
            for i = 0 to array.size(bslPrices) - 1
                levelPrice = array.get(bslPrices, i)
                active = array.get(bslActive, i)

                if f_levelUsable(active) and
                   levelPrice > refPrice and
                   levelPrice - entryPrice >= minimumDistance
                    if na(bestTarget) or levelPrice < bestTarget
                        bestTarget := levelPrice
                        bestType := "HTF BSL"

        if usePreviousDayAsTarget and
           f_levelUsable(pdhActive) and
           previousDayHigh > refPrice and
           previousDayHigh - entryPrice >= minimumDistance
            if na(bestTarget) or previousDayHigh < bestTarget
                bestTarget := previousDayHigh
                bestType := "PDH"

        if not na(asiaSession.sessionHigh) and
           asiaSession.sessionHigh > refPrice and
           asiaSession.sessionHigh - entryPrice >= minimumDistance
            if na(bestTarget) or asiaSession.sessionHigh < bestTarget
                bestTarget := asiaSession.sessionHigh
                bestType := "Current Asia High"

        if not na(londonSession.sessionHigh) and
           londonSession.sessionHigh > refPrice and
           londonSession.sessionHigh - entryPrice >= minimumDistance
            if na(bestTarget) or londonSession.sessionHigh < bestTarget
                bestTarget := londonSession.sessionHigh
                bestType := "Current London High"

        if not na(nySession.sessionHigh) and
           nySession.sessionHigh > refPrice and
           nySession.sessionHigh - entryPrice >= minimumDistance
            if na(bestTarget) or nySession.sessionHigh < bestTarget
                bestTarget := nySession.sessionHigh
                bestType := "Current NY High"

    [bestTarget, bestType]

// =============================================================================
// 14. HTF STATE MACHINE
// =============================================================================

type FvgZone
    float top
    float bottom
    int direction
    int middleTime
    int createdBar
    bool active
    bool triggered
    bool left
    bool tagged
    int tagBar
    float extremeHigh
    float extremeLow
    int mitigationCount
    bool wasTouching
    box formationBox
    box zoneBox
    box proximityBox
    int reentries
    bool tapWasTouching
    int tapCount
    bool everTraded
    box traceBox

var array<FvgZone> fvgZones = array.new<FvgZone>()
var array<box> tradedFvgTraceBoxes = array.new_box()
var int lastHtfMiddleTime = na

executionAtr = ta.atr(nearTouchAtrLength)
nearTouchBuffer =
     enableNearTouch
         ? math.max(
             nearTouchMinTicks * syminfo.mintick,
             nz(executionAtr, 0.0) * nearTouchAtrPercent / 100.0
         )
         : 0.0

continuationAtrState = ta.atr(continuationAtrLength)
priorContinuationHighState = ta.highest(high[1], continuationStructureLookback)
priorContinuationLowState = ta.lowest(low[1], continuationStructureLookback)
continuationBullStructureState =
     not continuationRequireStructureBreak or
     close > priorContinuationHighState
continuationBearStructureState =
     not continuationRequireStructureBreak or
     close < priorContinuationLowState

newHtfFvg =
     not na(htfMiddleTimeSeries) and
     htfDirectionSeries != 0 and
     (na(lastHtfMiddleTime) or htfMiddleTimeSeries != lastHtfMiddleTime)

if newHtfFvg
    lastHtfMiddleTime := htfMiddleTimeSeries

    newTop = math.max(htfTopSeries, htfBottomSeries)
    newBottom = math.min(htfTopSeries, htfBottomSeries)
    newDirection = htfDirectionSeries
    // `time[1]` is the final execution candle contained in the just-confirmed
    // HTF candle. It visually anchors the FVG to the correct M5 bar without
    // allowing any signal before that candle has closed.
    box newFormationBox =
         extendFvgBackToFormation and not na(time[1])
             ? box.new(
                 left = time[1],
                 top = newTop,
                 right = time,
                 bottom = newBottom,
                 xloc = xloc.bar_time,
                 border_color = color.new(color.gray, 55),
                 border_style = line.style_dotted,
                 bgcolor = color.new(newDirection == 1 ? htfBullColor : htfBearColor, 88)
             )
             : na

    box newZoneBox = box.new(
         left = time,
         top = newTop,
         right = time_close,
         bottom = newBottom,
         xloc = xloc.bar_time,
         border_color = color.gray,
         border_style = line.style_dashed,
         bgcolor = newDirection == 1 ? htfBullColor : htfBearColor
     )

    proximityTop = newDirection == 1 ? newTop + nearTouchBuffer : newBottom
    proximityBottom = newDirection == 1 ? newTop : newBottom - nearTouchBuffer

    box newProximityBox =
         showNearTouchBoundary and enableNearTouch
             ? box.new(
                 left = time,
                 top = proximityTop,
                 right = time_close,
                 bottom = proximityBottom,
                 xloc = xloc.bar_time,
                 border_color = color.new(color.yellow, 20),
                 border_style = line.style_dotted,
                 bgcolor = color.new(color.yellow, 94)
             )
             : na

    FvgZone newZone = FvgZone.new(
         newTop,
         newBottom,
         newDirection,
         htfMiddleTimeSeries,
         bar_index,
         true,
         false,
         false,
         false,
         na,
         na,
         na,
         0,
         false,
         newFormationBox,
         newZoneBox,
         newProximityBox,
         0,
         false,
         0,
         false,
         na
    )

    array.unshift(fvgZones, newZone)

while array.size(fvgZones) > maxTrackedFvgs
    FvgZone removedZone = array.pop(fvgZones)
    if not na(removedZone.formationBox)
        box.delete(removedZone.formationBox)
    if not na(removedZone.zoneBox)
        box.delete(removedZone.zoneBox)
    if not na(removedZone.proximityBox)
        box.delete(removedZone.proximityBox)

// Keep invalidation alive for every visually live gap, including zones already
// consumed by a prior signal. Without this pass, the independent instant-tap
// scanner could later reuse a FVG after price had closed completely through it.
if invalidateOnFullClose and array.size(fvgZones) > 0
    for zoneIndex = 0 to array.size(fvgZones) - 1
        FvgZone zone = array.get(fvgZones, zoneIndex)

        zoneInvalidatedNow =
             not na(zone.zoneBox) and
             barstate.isconfirmed and
             (
                 zone.direction == -1
                     ? close > zone.top
                     : close < zone.bottom
             )

        if zoneInvalidatedNow
            if preserveTradedFvgTrace and zone.everTraded
                // Move the original box out of the live scanner and retain it as
                // a frozen historical source trace.
                zone.traceBox := zone.zoneBox
                box.set_right(zone.traceBox, time_close)
                box.set_extend(zone.traceBox, extend.none)
                box.set_border_color(
                     zone.traceBox,
                     color.new(zone.direction == 1 ? htfBullColor : htfBearColor, 35)
                )
                box.set_border_style(zone.traceBox, line.style_dashed)
                box.set_border_width(zone.traceBox, 2)
                box.set_bgcolor(
                     zone.traceBox,
                     color.new(zone.direction == 1 ? htfBullColor : htfBearColor, 88)
                )
                array.push(tradedFvgTraceBoxes, zone.traceBox)
                while array.size(tradedFvgTraceBoxes) > maxTradedFvgTraces
                    box oldestTrace = array.shift(tradedFvgTraceBoxes)
                    if not na(oldestTrace)
                        box.delete(oldestTrace)
                zone.zoneBox := na
            else
                box.delete(zone.zoneBox)
                zone.zoneBox := na

            if not na(zone.proximityBox)
                box.delete(zone.proximityBox)
                zone.proximityBox := na

            if not na(zone.formationBox) and not (preserveTradedFvgTrace and zone.everTraded)
                box.delete(zone.formationBox)
                zone.formationBox := na

            zone.active := false
            zone.triggered := true
            zone.tagged := false
            zone.tapWasTouching := false

// Drawing lifecycle is independent from signal availability. A zone may be
// active, reserved, already traded or re-armed; as long as its box still exists,
// it remains structurally valid and must stay visible through the current bar.
if array.size(fvgZones) > 0
    for zoneIndex = 0 to array.size(fvgZones) - 1
        FvgZone zone = array.get(fvgZones, zoneIndex)

        if not na(zone.zoneBox)
            box.set_right(zone.zoneBox, time_close)

        if not na(zone.proximityBox)
            zoneProximityTop = zone.direction == 1 ? zone.top + nearTouchBuffer : zone.bottom
            zoneProximityBottom = zone.direction == 1 ? zone.top : zone.bottom - nearTouchBuffer
            box.set_right(zone.proximityBox, time_close)
            box.set_top(zone.proximityBox, zoneProximityTop)
            box.set_bottom(zone.proximityBox, zoneProximityBottom)

// The scalar HTF variables below represent the best zone for the current bar.
// Every zone keeps its own independent state in fvgZones.
box htfBox = na
float htfTop = na
float htfBottom = na
int htfDirection = 0
bool htfActive = false
bool htfTriggered = false
bool htfLeft = false
int htfCreatedBar = na
int mitigationCount = 0
bool wasTouchingHtf = false
bool retestTagged = false
int retestTagBar = na
float retestExtremeHigh = na
float retestExtremeLow = na
int selectedZoneTime = na
int selectedZoneIndex = na
int selectedZoneRank = 100
float selectedZoneDistance = na
bool selectedExactTouch = false
bool selectedNearTouch = false
bool selectedAcceptedTouch = false
bool selectedNewTouch = false
float selectedGapTicks = na
bool proximityLongRaw = false
bool proximityShortRaw = false
int activeFvgCount = 0

if array.size(fvgZones) > 0
    for zoneIndex = 0 to array.size(fvgZones) - 1
        FvgZone zone = array.get(fvgZones, zoneIndex)

        if zone.active and not zone.triggered
            departedNow =
                 modeTolerant
                     ? (
                         zone.direction == -1
                             ? low < zone.bottom
                             : high > zone.top
                     )
                     : (
                         zone.direction == -1
                             ? close < zone.bottom
                             : close > zone.top
                     )

            if departedNow
                zone.left := true

            fullyFilledNow =
                 invalidateOnFullClose and
                 barstate.isconfirmed and
                 (
                     zone.direction == -1
                         ? close > zone.top
                         : close < zone.bottom
                 )

            if fullyFilledNow
                if not na(zone.zoneBox)
                    if preserveTradedFvgTrace and zone.everTraded
                        zone.traceBox := zone.zoneBox
                        box.set_right(zone.traceBox, time_close)
                        box.set_extend(zone.traceBox, extend.none)
                        box.set_border_color(
                             zone.traceBox,
                             color.new(zone.direction == 1 ? htfBullColor : htfBearColor, 35)
                        )
                        box.set_border_style(zone.traceBox, line.style_dashed)
                        box.set_border_width(zone.traceBox, 2)
                        box.set_bgcolor(
                             zone.traceBox,
                             color.new(zone.direction == 1 ? htfBullColor : htfBearColor, 88)
                        )
                        array.push(tradedFvgTraceBoxes, zone.traceBox)
                        while array.size(tradedFvgTraceBoxes) > maxTradedFvgTraces
                            box oldestTrace = array.shift(tradedFvgTraceBoxes)
                            if not na(oldestTrace)
                                box.delete(oldestTrace)
                        zone.zoneBox := na
                    else
                        box.delete(zone.zoneBox)
                        zone.zoneBox := na
                if not na(zone.proximityBox)
                    box.delete(zone.proximityBox)
                    zone.proximityBox := na
                if not na(zone.formationBox) and not (preserveTradedFvgTrace and zone.everTraded)
                    box.delete(zone.formationBox)
                    zone.formationBox := na
                zone.active := false
            else
                activeFvgCount += 1

                if not na(zone.zoneBox)
                    box.set_right(zone.zoneBox, time_close)

                if not na(zone.proximityBox)
                    zoneProximityTop = zone.direction == 1 ? zone.top + nearTouchBuffer : zone.bottom
                    zoneProximityBottom = zone.direction == 1 ? zone.top : zone.bottom - nearTouchBuffer
                    box.set_right(zone.proximityBox, time_close)
                    box.set_top(zone.proximityBox, zoneProximityTop)
                    box.set_bottom(zone.proximityBox, zoneProximityBottom)

                rawExactTouchNow =
                     high >= zone.bottom and
                     low <= zone.top

                rawNearBullTouchNow =
                     enableNearTouch and
                     zone.direction == 1 and
                     low > zone.top and
                     low <= zone.top + nearTouchBuffer

                rawNearBearTouchNow =
                     enableNearTouch and
                     zone.direction == -1 and
                     high < zone.bottom and
                     high >= zone.bottom - nearTouchBuffer

                // Directional approach is evaluated from information known at
                // the start of the execution candle. The previous close must be
                // on the correct exterior side. Equality at the boundary is
                // valid, and the current open may overlap the edge only by the
                // already configured near-touch buffer. This catches a genuine
                // first underside/topside retest without restoring wrong-side
                // signals from deep inside or beyond the FVG.
                correctSideNow =
                     not requireDirectionalRetest or
                     (
                         zone.direction == -1
                             ? (
                                 close[1] <= zone.bottom and
                                 open <= zone.bottom + nearTouchBuffer
                             )
                             : (
                                 close[1] >= zone.top and
                                 open >= zone.top - nearTouchBuffer
                             )
                     )

                exactTouchNow = correctSideNow and rawExactTouchNow
                nearTouchNow =
                     correctSideNow and
                     (rawNearBullTouchNow or rawNearBearTouchNow)
                acceptedTouchNow = exactTouchNow or nearTouchNow
                newTouchNow = acceptedTouchNow and not zone.wasTouching

                if newTouchNow
                    zone.mitigationCount += 1

                if (zone.left or allowDirectTap) and acceptedTouchNow
                    zone.tagged := true
                    zone.tagBar := bar_index
                    zone.extremeHigh := na(zone.extremeHigh) ? high : math.max(zone.extremeHigh, high)
                    zone.extremeLow := na(zone.extremeLow) ? low : math.min(zone.extremeLow, low)

                if enableRetestStrategy and newTouchNow and (modeDirect or zone.left or allowDirectTap)
                    if zone.direction == 1
                        proximityLongRaw := true
                    else
                        proximityShortRaw := true

                zone.wasTouching := acceptedTouchNow

                tagFreshNow =
                     zone.tagged and
                     not na(zone.tagBar) and
                     bar_index - zone.tagBar <= retestValidBars

                touchEligibleNow = acceptedTouchNow and (modeDirect or zone.left or allowDirectTap)
                zoneShortRejectionNow = close < zone.bottom
                zoneLongRejectionNow = close > zone.top
                zoneShortCoreNow =
                     retestTrigger == "Wick tag"
                         ? ((zone.left or allowDirectTap) and tagFreshNow)
                         : retestTrigger == "Rejection close"
                             ? (tagFreshNow and zoneShortRejectionNow)
                             : (tagFreshNow and ltfBear and ltfBearSizeOk)
                zoneLongCoreNow =
                     retestTrigger == "Wick tag"
                         ? ((zone.left or allowDirectTap) and tagFreshNow)
                         : retestTrigger == "Rejection close"
                             ? (tagFreshNow and zoneLongRejectionNow)
                             : (tagFreshNow and ltfBull and ltfBullSizeOk)
                zoneDirectReadyNow =
                     modeDirect and
                     acceptedTouchNow and
                     (
                         zone.direction == 1
                             ? (not requireLTFFvg or (ltfBull and ltfBullSizeOk))
                             : (not requireLTFFvg or (ltfBear and ltfBearSizeOk))
                     )
                zoneRetestReadyNow =
                     enableRetestStrategy and
                     (not requireKillzone or inKillzone) and
                     (
                         zoneDirectReadyNow or
                         (
                             not modeDirect and
                             (
                                 zone.direction == 1
                                     ? zoneLongCoreNow
                                     : zoneShortCoreNow
                             )
                         )
                     )
                zoneContinuationAgeNow =
                     bar_index - zone.createdBar <= continuationMaxBars
                zoneBullContinuationReadyNow =
                     enableContinuationStrategy and
                     enableBullContinuation and
                     zone.direction == 1 and
                     close > zone.top and
                     (not continuationRequireKillzone or inKillzone) and
                     zoneContinuationAgeNow and
                     math.max(0.0, close - zone.top) <= continuationAtrState * continuationMaxDistanceAtr and
                     continuationBullStructureState and
                     ltfBull and
                     ltfBullSizeOk
                zoneBearContinuationReadyNow =
                     enableContinuationStrategy and
                     enableBearContinuation and
                     zone.direction == -1 and
                     close < zone.bottom and
                     (not continuationRequireKillzone or inKillzone) and
                     zoneContinuationAgeNow and
                     math.max(0.0, zone.bottom - close) <= continuationAtrState * continuationMaxDistanceAtr and
                     continuationBearStructureState and
                     ltfBear and
                     ltfBearSizeOk
                zoneContinuationReadyNow =
                     zoneBullContinuationReadyNow or
                     zoneBearContinuationReadyNow
                newRetestTouchReadyNow = zoneRetestReadyNow and newTouchNow
                zoneRank =
                     newRetestTouchReadyNow
                         ? 0
                         : zoneRetestReadyNow
                             ? 1
                             : zoneContinuationReadyNow
                                 ? 2
                                 : touchEligibleNow
                                     ? 3
                                     : tagFreshNow
                                         ? 4
                                         : 5
                zoneDistance =
                     close > zone.top
                         ? close - zone.top
                         : close < zone.bottom
                             ? zone.bottom - close
                             : 0.0
                zoneTouchGap =
                     exactTouchNow
                         ? 0.0
                         : zone.direction == 1
                             ? math.max(0.0, low - zone.top)
                             : math.max(0.0, zone.bottom - high)
                zoneSelectionDistance =
                     newRetestTouchReadyNow
                         ? zoneTouchGap
                         : zoneDistance

                chooseZone =
                     na(selectedZoneIndex) or
                     zoneRank < selectedZoneRank or
                     (
                         zoneRank == selectedZoneRank and
                         (na(selectedZoneDistance) or zoneSelectionDistance < selectedZoneDistance)
                     )

                if chooseZone
                    selectedZoneIndex := zoneIndex
                    selectedZoneRank := zoneRank
                    selectedZoneDistance := zoneSelectionDistance
                    selectedExactTouch := exactTouchNow
                    selectedNearTouch := nearTouchNow
                    selectedAcceptedTouch := acceptedTouchNow
                    selectedNewTouch := newTouchNow
                    selectedGapTicks :=
                         exactTouchNow
                             ? 0.0
                             : zone.direction == 1
                                 ? math.max(0.0, (low - zone.top) / syminfo.mintick)
                                 : math.max(0.0, (zone.bottom - high) / syminfo.mintick)

if not na(selectedZoneIndex)
    FvgZone selectedZone = array.get(fvgZones, selectedZoneIndex)
    htfBox := selectedZone.zoneBox
    htfTop := selectedZone.top
    htfBottom := selectedZone.bottom
    htfDirection := selectedZone.direction
    htfActive := selectedZone.active
    htfTriggered := selectedZone.triggered
    htfLeft := selectedZone.left
    htfCreatedBar := selectedZone.createdBar
    mitigationCount := selectedZone.mitigationCount
    wasTouchingHtf := selectedZone.wasTouching
    retestTagged := selectedZone.tagged
    retestTagBar := selectedZone.tagBar
    retestExtremeHigh := selectedZone.extremeHigh
    retestExtremeLow := selectedZone.extremeLow
    selectedZoneTime := selectedZone.middleTime

// =============================================================================
// 14B. INSTANT TAP DETECTOR (independent of the retest engine)
// Scans EVERY live gap (active or already consumed) and fires the instant a wick
// touches it, re-firing each time the wick leaves and taps again. When a tap is
// chosen, it overrides the HTF scalars with the tapped gap's geometry so the
// normal entry / stop / target machinery builds the trade from THAT gap.
// =============================================================================

int tapChosenIndex = na
float tapChosenDistance = na
int tapChosenDir = 0
float tapChosenTop = na
float tapChosenBottom = na
int tapChosenTime = na

if instantTapEntry and array.size(fvgZones) > 0
    for zi = 0 to array.size(fvgZones) - 1
        FvgZone z = array.get(fvgZones, zi)

        // A gap is "live" as long as its box still exists (not fully deleted).
        if not na(z.zoneBox)
            tapRawExact = high >= z.bottom and low <= z.top
            tapRawNearBull =
                 enableNearTouch and z.direction == 1 and
                 low > z.top and low <= z.top + nearTouchBuffer
            tapRawNearBear =
                 enableNearTouch and z.direction == -1 and
                 high < z.bottom and high >= z.bottom - nearTouchBuffer

            tapCorrectSide =
                 not requireDirectionalRetest or
                 (
                     z.direction == -1
                         ? (
                             close[1] <= z.bottom and
                             open <= z.bottom + nearTouchBuffer
                         )
                         : (
                             close[1] >= z.top and
                             open >= z.top - nearTouchBuffer
                         )
                 )

            zoneTapNow =
                 tapCorrectSide and
                 (tapRawExact or tapRawNearBull or tapRawNearBear)

            zoneNewTap = zoneTapNow and not z.tapWasTouching
            z.tapWasTouching := zoneTapNow

            capOk = maxTapsPerZone == 0 or z.tapCount < maxTapsPerZone

            if zoneNewTap and capOk
                tapDist = math.abs(close - (z.top + z.bottom) / 2.0)
                if na(tapChosenDistance) or tapDist < tapChosenDistance
                    tapChosenDistance := tapDist
                    tapChosenIndex := zi
                    tapChosenDir := z.direction
                    tapChosenTop := z.top
                    tapChosenBottom := z.bottom
                    tapChosenTime := z.middleTime

// Fire: override the HTF scalars with the exact tapped gap and arm its event.
tapFired = not na(tapChosenIndex)
if tapFired
    FvgZone zc = array.get(fvgZones, tapChosenIndex)
    zc.tapCount += 1

    htfTop := tapChosenTop
    htfBottom := tapChosenBottom
    htfDirection := tapChosenDir
    htfActive := true
    htfTriggered := false
    selectedZoneTime := tapChosenTime

    if tapChosenDir == 1
        proximityLongRaw := true
    else
        proximityShortRaw := true

// =============================================================================
// 15. SIGNAL CONDITIONS
// =============================================================================

bearOverlap = ltfBearBottom <= htfTop and ltfBearTop >= htfBottom
bullOverlap = ltfBullBottom <= htfTop and ltfBullTop >= htfBottom

ltfBearSignal = ltfBear and bearOverlap and ltfBearSizeOk
ltfBullSignal = ltfBull and bullOverlap and ltfBullSizeOk

exactTouchHtfZone = htfActive and selectedExactTouch
nearTouchHtfZone = htfActive and selectedNearTouch
touchHtfZone = htfActive and selectedAcceptedTouch
newMitigationTouch = htfActive and selectedNewTouch
touchGapTicks = htfActive ? selectedGapTicks : na

proximityTimingOk =
     proximityAlertTiming == "Intrabar" or
     barstate.isconfirmed

proximityLongEvent = proximityLongRaw and proximityTimingOk
proximityShortEvent = proximityShortRaw and proximityTimingOk

htfRange = math.max(htfTop - htfBottom, syminfo.mintick)

longMitigationDepth =
     htfActive and htfDirection == 1
         ? math.max(0.0, math.min(100.0, (htfTop - low) / htfRange * 100.0))
         : na

shortMitigationDepth =
     htfActive and htfDirection == -1
         ? math.max(0.0, math.min(100.0, (high - htfBottom) / htfRange * 100.0))
         : na

htfAgeBars =
     htfActive and not na(htfCreatedBar)
         ? bar_index - htfCreatedBar
         : na

// Killzone is now optional (informational unless requireKillzone = true).
killzoneOk = not requireKillzone or inKillzone

// Rejection = price closed back OUTSIDE the zone, in the trade direction.
shortRejection = close < htfBottom
longRejection = close > htfTop

// The retest tag (wick into the zone) is still recent enough to trade.
retestFresh = retestTagged and not na(retestTagBar) and (bar_index - retestTagBar <= retestValidBars)

// --- Mode B : direct tap (no departure required) ---
shortDirect =
     modeDirect and
     htfActive and not htfTriggered and htfDirection == -1 and
     killzoneOk and touchHtfZone and
     (not requireLTFFvg or (ltfBear and ltfBearSizeOk))

longDirect =
     modeDirect and
     htfActive and not htfTriggered and htfDirection == 1 and
     killzoneOk and touchHtfZone and
     (not requireLTFFvg or (ltfBull and ltfBullSizeOk))

// --- Modes A / A' : retest, driven by retestTrigger ---
retestModeWick = retestTrigger == "Wick tag"
retestModeReject = retestTrigger == "Rejection close"
retestModeFvg = retestTrigger == "LTF FVG"

// Wick tag        : exact touch or accepted near-touch (departure optional if allowDirectTap).
// Rejection close : fresh tag + close back outside the zone.
// LTF FVG         : fresh tag + LTF FVG in the trade direction.
shortRetestCore =
     retestModeWick
         ? ((htfLeft or allowDirectTap) and retestFresh)
         : retestModeReject
             ? (retestFresh and shortRejection)
             : (retestFresh and ltfBear and ltfBearSizeOk)

longRetestCore =
     retestModeWick
         ? ((htfLeft or allowDirectTap) and retestFresh)
         : retestModeReject
             ? (retestFresh and longRejection)
             : (retestFresh and ltfBull and ltfBullSizeOk)

shortRetest =
     not modeDirect and
     htfActive and not htfTriggered and htfDirection == -1 and
     killzoneOk and shortRetestCore

longRetest =
     not modeDirect and
     htfActive and not htfTriggered and htfDirection == 1 and
     killzoneOk and longRetestCore

shortSignal = enableRetestStrategy and (shortDirect or shortRetest)
longSignal = enableRetestStrategy and (longDirect or longRetest)

// -----------------------------------------------------------------------------
// CONTINUATION MODULE
// -----------------------------------------------------------------------------

continuationAtr = ta.atr(continuationAtrLength)

continuationAgeOk =
     not na(htfCreatedBar) and
     bar_index - htfCreatedBar <= continuationMaxBars

bullDistanceFromHtf = math.max(0.0, close - htfTop)
bearDistanceFromHtf = math.max(0.0, htfBottom - close)

bullContinuationDistanceOk =
     bullDistanceFromHtf <= continuationAtr * continuationMaxDistanceAtr

bearContinuationDistanceOk =
     bearDistanceFromHtf <= continuationAtr * continuationMaxDistanceAtr

priorContinuationHigh = ta.highest(high[1], continuationStructureLookback)
priorContinuationLow = ta.lowest(low[1], continuationStructureLookback)

bullContinuationStructureOk =
     not continuationRequireStructureBreak or
     close > priorContinuationHigh

bearContinuationStructureOk =
     not continuationRequireStructureBreak or
     close < priorContinuationLow

continuationKillzoneOk =
     not continuationRequireKillzone or inKillzone

bullContinuationRaw =
     enableContinuationStrategy and
     enableBullContinuation and
     htfActive and
     not htfTriggered and
     htfDirection == 1 and
     close > htfTop and
     continuationKillzoneOk and
     continuationAgeOk and
     bullContinuationDistanceOk and
     bullContinuationStructureOk and
     ltfBull and
     ltfBullSizeOk

bearContinuationRaw =
     enableContinuationStrategy and
     enableBearContinuation and
     htfActive and
     not htfTriggered and
     htfDirection == -1 and
     close < htfBottom and
     continuationKillzoneOk and
     continuationAgeOk and
     bearContinuationDistanceOk and
     bearContinuationStructureOk and
     ltfBear and
     ltfBearSizeOk

// =============================================================================
// 16. VISUAL TRADE STATE
// =============================================================================

var float plannedEntry = na
var float plannedStop = na
var float plannedTarget = na
var int setupBar = na
var bool pendingOrder = false
var bool tradeActive = false
var int tradeDirection = 0
var string tradeModel = ""
var int tradeZoneTime = na
var string lastTargetType = "None"   // v2.0: exposed for dashboard readout

// v2.1: references to the CURRENT proposal's drawings, so a stopped-out retest
// proposal can be removed and replaced when the zone re-arms.
var box tradeStopBox = na
var box tradeTargetBox = na
var label tradeSetupLabel = na
var array<label> tradeExitMarkers = array.new_label()

// Drawing-only helpers. They never modify setup detection, order state or alerts.
f_deleteTradeDrawings(
     box stopBox,
     box targetBox,
     label setupLabel
) =>
    if not na(stopBox)
        box.delete(stopBox)
    if not na(targetBox)
        box.delete(targetBox)
    if not na(setupLabel)
        label.delete(setupLabel)
    true

f_storeExitMarker(label marker) =>
    array.push(tradeExitMarkers, marker)
    while array.size(tradeExitMarkers) > maxExitMarkers
        oldMarker = array.shift(tradeExitMarkers)
        if not na(oldMarker)
            label.delete(oldMarker)
    marker

canTrade = not blockWhileInTrade or (not tradeActive and not pendingOrder)

// Live preview metrics for the current bar.
// These are informational only and do not change signal generation.
// Preview reference = the entry itself (unchanged behaviour).
previewLongEntry = close
previewShortEntry = close

previewLongStop =
     requireLTFFvg and ltfBull
         ? ltfBullBottom - stopBufferTicks * syminfo.mintick
         : htfBottom - stopBufferTicks * syminfo.mintick

previewShortStop =
     requireLTFFvg and ltfBear
         ? ltfBearTop + stopBufferTicks * syminfo.mintick
         : htfTop + stopBufferTicks * syminfo.mintick

previewLongRisk = math.max(previewLongEntry - previewLongStop, minStopTicks > 0 ? minStopTicks * syminfo.mintick : syminfo.mintick)
previewShortRisk = math.max(previewShortStop - previewShortEntry, minStopTicks > 0 ? minStopTicks * syminfo.mintick : syminfo.mintick)

// v2.1b: a retest target must sit BEYOND the HTF FVG in the trade direction.
// Long → above htfTop, Short → below htfBottom. Never inside the traded gap.
previewLongRef =
     htfActive and not na(htfTop)
         ? math.max(previewLongEntry, htfTop)
         : previewLongEntry
previewShortRef =
     htfActive and not na(htfBottom)
         ? math.min(previewShortEntry, htfBottom)
         : previewShortEntry

[previewLongTarget, previewLongTargetType] =
     f_pickTarget(false, previewLongEntry, previewLongRisk, previewLongRef)

[previewShortTarget, previewShortTargetType] =
     f_pickTarget(true, previewShortEntry, previewShortRisk, previewShortRef)

previewLongRr =
     not na(previewLongTarget)
         ? (previewLongTarget - previewLongEntry) / previewLongRisk
         : fallbackRr

previewShortRr =
     not na(previewShortTarget)
         ? (previewShortEntry - previewShortTarget) / previewShortRisk
         : fallbackRr

previewLongTargetTypeFinal =
     na(previewLongTarget)
         ? "Fallback R:R"
         : previewLongTargetType

previewShortTargetTypeFinal =
     na(previewShortTarget)
         ? "Fallback R:R"
         : previewShortTargetType

f_roomQuality(float rrValue) =>
    rrValue >= 2.0
         ? "Strong"
         : rrValue >= 1.5
             ? "OK"
             : "Low"

previewLongRoomQuality = f_roomQuality(previewLongRr)
previewShortRoomQuality = f_roomQuality(previewShortRr)

// v2.10 — INSTANT TAP ENTRY is locked to the exact FVG selected by the
// independent tap scanner. Aggregate proximity events remain available for
// notifications, but can no longer assign a trade to the opposite zone when one
// large execution candle touches bullish and bearish gaps simultaneously.
instantTapShort = instantTapEntry and tapFired and tapChosenDir == -1 and canTrade
instantTapLong  = instantTapEntry and tapFired and tapChosenDir == 1  and canTrade

takeRetestShort = ((shortSignal and barConfirmed) or instantTapShort) and canTrade
takeRetestLong  = ((longSignal  and barConfirmed) or instantTapLong)  and canTrade

retestTakesPriority = takeRetestShort or takeRetestLong

takeContinuationShort =
     bearContinuationRaw and
     canTrade and
     barConfirmed and
     not retestTakesPriority

takeContinuationLong =
     bullContinuationRaw and
     canTrade and
     barConfirmed and
     not retestTakesPriority

takeShort = takeRetestShort or takeContinuationShort
takeLong = takeRetestLong or takeContinuationLong

buffer = stopBufferTicks * syminfo.mintick

bool retestLongSetupEvent = false
bool retestShortSetupEvent = false
bool continuationLongSetupEvent = false
bool continuationShortSetupEvent = false
bool longFillEvent = false
bool shortFillEvent = false
bool takeProfitEvent = false
bool stopLossEvent = false

if takeShort or takeLong
    retestLongSetupEvent := takeRetestLong
    retestShortSetupEvent := takeRetestShort
    continuationLongSetupEvent := takeContinuationLong
    continuationShortSetupEvent := takeContinuationShort

    isContinuationTrade =
         not retestTakesPriority and
         (takeContinuationLong or takeContinuationShort)
    tradeModel := isContinuationTrade ? "Continuation" : "Retest"

    // v2.4: instant-tap trades always fill at the touch price (market), even if
    // the user configured a limit entry.
    isTapTrade = instantTapShort or instantTapLong

    // v2.0: final target type made visible outside the branch (label + dashboard).
    string finalTargetType = "Fallback R:R"

    if takeShort
        tradeDirection := -1

        if tradeModel == "Continuation"
            plannedEntry := continuationUseLimitEntry
                 ? ltfBearBottom
                 : close
            plannedStop := ltfBearTop + buffer
        else
            plannedEntry := (useLimitEntry and not isTapTrade) ? ((ltfBear and ltfBearSizeOk) ? ltfBearBottom : htfBottom) : close
            // Wick reference of the retest (fallback anchor).
            shortWickRef = na(retestExtremeHigh) ? high : math.max(retestExtremeHigh, high)
            shortStopAnchor =
                 retestStopMode == "Below HTF FVG"
                     ? (not na(htfTop) ? math.max(htfTop, shortWickRef) : shortWickRef)
                     : ((ltfBear and ltfBearSizeOk) ? ltfBearTop : shortWickRef)
            plannedStop := shortStopAnchor + buffer

        // Minimum stop distance floor (applies to both models).
        minStopDist = minStopTicks * syminfo.mintick
        if minStopTicks > 0 and (plannedStop - plannedEntry) < minStopDist
            plannedStop := plannedEntry + minStopDist

        risk = plannedStop - plannedEntry

        float chosenTarget = na
        string chosenTargetType = "None"

        if useLiquidityTarget
            // Continuation reference = current low (target below the current extreme).
            // Retest reference = below the HTF FVG (a retest short targets liquidity
            // BELOW the gap, never inside it).
            shortRef =
                 tradeModel == "Continuation"
                     ? low
                     : (not na(htfBottom) ? math.min(plannedEntry, htfBottom) : plannedEntry)
            [pickedTarget, pickedTargetType] = f_pickTarget(true, plannedEntry, risk, shortRef)
            chosenTarget := pickedTarget
            chosenTargetType := pickedTargetType

        if na(chosenTarget)
            // No fresh resting liquidity below → projected target forced past the gap / extreme.
            plannedTarget := tradeModel == "Continuation"
                 ? math.min(plannedEntry - continuationFallbackRr * risk, low - buffer)
                 : math.min(plannedEntry - fallbackRr * risk, (not na(htfBottom) ? htfBottom : plannedEntry) - buffer)
            finalTargetType := tradeModel == "Continuation" ? "Fallback C-RR" : "Fallback R:R"
        else
            plannedTarget := chosenTarget
            finalTargetType := chosenTargetType

    else
        tradeDirection := 1

        if tradeModel == "Continuation"
            plannedEntry := continuationUseLimitEntry
                 ? ltfBullTop
                 : close
            plannedStop := ltfBullBottom - buffer
        else
            plannedEntry := (useLimitEntry and not isTapTrade) ? ((ltfBull and ltfBullSizeOk) ? ltfBullTop : htfTop) : close
            // Wick reference of the retest (fallback anchor).
            longWickRef = na(retestExtremeLow) ? low : math.min(retestExtremeLow, low)
            longStopAnchor =
                 retestStopMode == "Below HTF FVG"
                     ? (not na(htfBottom) ? math.min(htfBottom, longWickRef) : longWickRef)
                     : ((ltfBull and ltfBullSizeOk) ? ltfBullBottom : longWickRef)
            plannedStop := longStopAnchor - buffer

        // Minimum stop distance floor (applies to both models).
        minStopDistL = minStopTicks * syminfo.mintick
        if minStopTicks > 0 and (plannedEntry - plannedStop) < minStopDistL
            plannedStop := plannedEntry - minStopDistL

        risk = plannedEntry - plannedStop

        float chosenTarget = na
        string chosenTargetType = "None"

        if useLiquidityTarget
            // Continuation reference = current high (target above the current extreme).
            // Retest reference = above the HTF FVG (a retest long targets liquidity
            // ABOVE the gap, never inside it).
            longRef =
                 tradeModel == "Continuation"
                     ? high
                     : (not na(htfTop) ? math.max(plannedEntry, htfTop) : plannedEntry)
            [pickedTarget, pickedTargetType] = f_pickTarget(false, plannedEntry, risk, longRef)
            chosenTarget := pickedTarget
            chosenTargetType := pickedTargetType

        if na(chosenTarget)
            // No fresh resting liquidity above → projected target forced past the gap / extreme.
            plannedTarget := tradeModel == "Continuation"
                 ? math.max(plannedEntry + continuationFallbackRr * risk, high + buffer)
                 : math.max(plannedEntry + fallbackRr * risk, (not na(htfTop) ? htfTop : plannedEntry) + buffer)
            finalTargetType := tradeModel == "Continuation" ? "Fallback C-RR" : "Fallback R:R"
        else
            plannedTarget := chosenTarget
            finalTargetType := chosenTargetType

    lastTargetType := finalTargetType
    setupBar := bar_index

    selectedLimitEntry =
         isTapTrade
             ? false
             : tradeModel == "Continuation"
                 ? continuationUseLimitEntry
                 : useLimitEntry

    pendingOrder := selectedLimitEntry
    tradeActive := not selectedLimitEntry
    tradeZoneTime := selectedZoneTime

    // The zone is reserved while the limit order is pending.
    // It is permanently consumed only if the order is filled
    // or if the entry is a market entry.
    htfTriggered := true
    htfActive := false

    if not na(tradeZoneTime) and array.size(fvgZones) > 0
        for zoneIndex = 0 to array.size(fvgZones) - 1
            FvgZone zone = array.get(fvgZones, zoneIndex)
            if zone.middleTime == tradeZoneTime
                zone.everTraded := true
                zone.triggered := true
                zone.active := false
                if not na(zone.zoneBox)
                    box.set_right(zone.zoneBox, time_close)
                if not na(zone.proximityBox)
                    box.set_right(zone.proximityBox, time_close)
                break

    if not na(htfBox)
        box.set_right(htfBox, time_close)

    // The logic tracks one current visual trade state. In compact modes, remove
    // the obsolete drawings before attaching the new proposal to that state.
    if tradeVisualMode != "Keep all"
        f_deleteTradeDrawings(tradeStopBox, tradeTargetBox, tradeSetupLabel)
        tradeStopBox := na
        tradeTargetBox := na
        tradeSetupLabel := na

    tradeStopBox := showTradePlanZones
         ? box.new(
             bar_index,
             math.max(plannedEntry, plannedStop),
             bar_index + 20,
             math.min(plannedEntry, plannedStop),
             xloc = xloc.bar_index,
             border_color = color.new(color.red, 40),
             bgcolor = color.new(color.red, 85)
         )
         : na

    tradeTargetBox := showTradePlanZones
         ? box.new(
             bar_index,
             math.max(plannedEntry, plannedTarget),
             bar_index + 20,
             math.min(plannedEntry, plannedTarget),
             xloc = xloc.bar_index,
             border_color = color.new(color.green, 40),
             bgcolor = color.new(color.green, 85)
         )
         : na

    riskValue = math.abs(plannedEntry - plannedStop)
    rewardValue = math.abs(plannedTarget - plannedEntry)
    rrValue = riskValue > 0 ? rewardValue / riskValue : na

    sourceFvgText =
         tradeModel == "Retest"
             ? (htfDirection == 1 ? " · BULL FVG" : " · BEAR FVG")
             : ""

    setupText =
         (tradeModel == "Continuation" ? "CONTINUATION " : "RETEST ") +
         (tradeDirection == 1 ? "LONG" : "SHORT") + sourceFvgText +
         "\nE " + str.tostring(plannedEntry, format.mintick) +
         "\nSL " + str.tostring(plannedStop, format.mintick) +
         "\nTP " + str.tostring(plannedTarget, format.mintick) +
         "  [" + finalTargetType + "]" +
         "\nRR " + str.tostring(rrValue, "#.##")

    tradeSetupLabel := showTradePlanLabel
         ? label.new(
             bar_index,
             plannedStop,
             setupText,
             xloc = xloc.bar_index,
             style = tradeDirection == -1
                 ? label.style_label_down
                 : label.style_label_up,
             color = tradeDirection == -1
                 ? color.new(color.red, 20)
                 : color.new(color.green, 20),
             textcolor = color.white,
             size = size.small
         )
         : na

// =============================================================================
// 17. LIMIT ORDER
// =============================================================================

if pendingOrder and not tradeActive
    limitFilled =
         tradeDirection == -1
             ? high >= plannedEntry
             : low <= plannedEntry

    if limitFilled
        tradeActive := true
        pendingOrder := false
        longFillEvent := tradeDirection == 1
        shortFillEvent := tradeDirection == -1

    else if bar_index - setupBar > limitExpirationBars
        // No fill: the HTF zone becomes available again
        // if it was not invalidated by a full close through the zone.
        expiredZoneTime = tradeZoneTime
        pendingOrder := false
        tradeDirection := 0
        tradeModel := ""
        plannedEntry := na
        plannedStop := na
        plannedTarget := na
        setupBar := na

        if not na(expiredZoneTime) and array.size(fvgZones) > 0
            for zoneIndex = 0 to array.size(fvgZones) - 1
                FvgZone zone = array.get(fvgZones, zoneIndex)
                if zone.middleTime == expiredZoneTime
                    zoneStillValid =
                         not invalidateOnFullClose or
                         (
                             zone.direction == -1
                                 ? close <= zone.top
                                 : close >= zone.bottom
                         )

                    if zoneStillValid
                        zone.active := true
                        zone.triggered := false
                    break

        tradeZoneTime := na

        if tradeVisualMode == "Active only"
            f_deleteTradeDrawings(tradeStopBox, tradeTargetBox, tradeSetupLabel)
            tradeStopBox := na
            tradeTargetBox := na
            tradeSetupLabel := na

// =============================================================================
// 18. VISUAL EXIT
// =============================================================================

if tradeActive
    hitStop =
         tradeDirection == -1
             ? high >= plannedStop
             : low <= plannedStop

    hitTarget =
         tradeDirection == -1
             ? low <= plannedTarget
             : high >= plannedTarget

    // If SL and TP are both touched within the same LTF candle, SL has conservative priority.
    if hitStop
        stopLossEvent := true
        tradeActive := false

        // v2.1 — RE-ARM after a stopped-out RETEST, if the HTF FVG still holds.
        // Validity: the candle must NOT close fully through the gap
        //   bullish  → close >= zone.bottom  (gap held, wick only)
        //   bearish  → close <= zone.top
        // On re-arm the retest tracking is reset so a NEW genuine tag is required,
        // and the stopped proposal (SL box, TP box, setup label) is removed.
        bool zoneReArmed = false

        if allowReentryAfterSl and barstate.isconfirmed and tradeModel == "Retest" and not na(tradeZoneTime) and array.size(fvgZones) > 0
            for zoneIndex = 0 to array.size(fvgZones) - 1
                FvgZone zone = array.get(fvgZones, zoneIndex)
                if zone.middleTime == tradeZoneTime
                    zoneHolds =
                         zone.direction == 1
                             ? close >= zone.bottom
                             : close <= zone.top

                    reentryCapOk =
                         maxReentriesPerZone == 0 or
                         zone.reentries < maxReentriesPerZone

                    if zoneHolds and reentryCapOk
                        zone.reentries += 1
                        zone.triggered := false
                        zone.active := true
                        // Require a fresh tag for the next attempt.
                        zone.tagged := false
                        zone.tagBar := na
                        zone.extremeHigh := na
                        zone.extremeLow := na
                        // Detection passes have already run for this SL bar.
                        // Reset both latches now so the NEXT execution bar may
                        // create a fresh bracket immediately if it approaches
                        // again from the correct side. This cannot re-fire on the
                        // current bar because signal detection is earlier.
                        zone.wasTouching := false
                        zone.tapWasTouching := false
                        // Departure already established: keep left = true.
                        if not na(zone.zoneBox)
                            box.set_right(zone.zoneBox, time_close)
                        zoneReArmed := true
                    break

        if zoneReArmed
            // Replace the previous proposal: clear its SL/TP zones and setup label.
            if not na(tradeStopBox)
                box.delete(tradeStopBox)
                tradeStopBox := na
            if not na(tradeTargetBox)
                box.delete(tradeTargetBox)
                tradeTargetBox := na
            if not na(tradeSetupLabel)
                label.delete(tradeSetupLabel)
                tradeSetupLabel := na

        slExitMarker = label.new(
             bar_index,
             plannedStop,
             "SL",
             style = tradeDirection == -1
                 ? label.style_label_up
                 : label.style_label_down,
             color = color.new(color.red, 10),
             textcolor = color.white,
             size = size.tiny
        )
        f_storeExitMarker(slExitMarker)

        if tradeVisualMode == "Active only"
            f_deleteTradeDrawings(tradeStopBox, tradeTargetBox, tradeSetupLabel)
            tradeStopBox := na
            tradeTargetBox := na
            tradeSetupLabel := na

    else if hitTarget
        takeProfitEvent := true
        tradeActive := false

        tpExitMarker = label.new(
             bar_index,
             plannedTarget,
             "TP",
             style = tradeDirection == -1
                 ? label.style_label_down
                 : label.style_label_up,
             color = color.new(color.green, 10),
             textcolor = color.white,
             size = size.tiny
        )
        f_storeExitMarker(tpExitMarker)

        if tradeVisualMode == "Active only"
            f_deleteTradeDrawings(tradeStopBox, tradeTargetBox, tradeSetupLabel)
            tradeStopBox := na
            tradeTargetBox := na
            tradeSetupLabel := na

// =============================================================================
// 19. DISPLAY
// =============================================================================

plotshape(
     showProximityMarkers and proximityShortEvent,
     title = "FVG touch / proximity SHORT",
     style = shape.circle,
     location = location.abovebar,
     color = color.yellow,
     size = size.tiny,
     text = "P-S",
     textcolor = color.black
)

plotshape(
     showProximityMarkers and proximityLongEvent,
     title = "FVG touch / proximity LONG",
     style = shape.circle,
     location = location.belowbar,
     color = color.yellow,
     size = size.tiny,
     text = "P-L",
     textcolor = color.black
)

plotshape(
     takeRetestShort,
     title = "Retest SHORT",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.small,
     text = "R-S"
)

plotshape(
     takeRetestLong,
     title = "Retest LONG",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.green,
     size = size.small,
     text = "R-L"
)

plotshape(
     takeContinuationShort,
     title = "Continuation SHORT",
     style = shape.triangledown,
     location = location.abovebar,
     color = continuationShortColor,
     size = size.small,
     text = "C-S"
)

plotshape(
     takeContinuationLong,
     title = "Continuation LONG",
     style = shape.triangleup,
     location = location.belowbar,
     color = continuationLongColor,
     size = size.small,
     text = "C-L"
)

// =============================================================================
// 20. NEAR MISS
// =============================================================================

shortNearMiss =
     showNearMiss and
     proximityShortEvent and
     not takeRetestShort

longNearMiss =
     showNearMiss and
     proximityLongEvent and
     not takeRetestLong

f_nearMissReason(
     bool leftOk,
     bool triggerOk,
     bool killOk,
     bool closeOk,
     bool availableOk
) =>
    string reason = ""

    if not leftOk
        reason += "LEFT "

    if not triggerOk
        reason += "WAIT_TRIGGER "

    if not killOk
        reason += "KZ "

    if not closeOk
        reason += "CLOSE "

    if not availableOk
        reason += "BUSY "

    reason

if shortNearMiss
    label.new(
         bar_index,
         high,
         "SHORT not entered\n" +
         (nearTouchHtfZone ? "NEAR " : "EXACT ") +
         (not na(touchGapTicks) ? str.tostring(touchGapTicks, "#.##") + "t\n" : "\n") +
         f_nearMissReason(
             modeDirect or htfLeft,
             modeDirect ? (not requireLTFFvg or (ltfBear and ltfBearSizeOk)) : shortRetestCore,
             killzoneOk,
             barConfirmed,
             canTrade
         ),
         style = label.style_label_down,
         color = color.new(color.orange, 10),
         textcolor = color.white,
         size = size.tiny
    )

if longNearMiss
    label.new(
         bar_index,
         low,
         "LONG not entered\n" +
         (nearTouchHtfZone ? "NEAR " : "EXACT ") +
         (not na(touchGapTicks) ? str.tostring(touchGapTicks, "#.##") + "t\n" : "\n") +
         f_nearMissReason(
             modeDirect or htfLeft,
             modeDirect ? (not requireLTFFvg or (ltfBull and ltfBullSizeOk)) : longRetestCore,
             killzoneOk,
             barConfirmed,
             canTrade
         ),
         style = label.style_label_up,
         color = color.new(color.orange, 10),
         textcolor = color.white,
         size = size.tiny
    )

// =============================================================================
// 21. ALERTS
// =============================================================================

alertcondition(
     proximityLongEvent,
     "ICT SMC FVG — Touch / Proximity LONG",
     "{{ticker}} {{interval}}: bullish HTF FVG exact touch or accepted near-touch."
)

alertcondition(
     proximityShortEvent,
     "ICT SMC FVG — Touch / Proximity SHORT",
     "{{ticker}} {{interval}}: bearish HTF FVG exact touch or accepted near-touch."
)

alertcondition(
     instantTapLong,
     "ICT SMC FVG — Instant TAP LONG",
     "{{ticker}} {{interval}}: bullish HTF FVG tapped — instant LONG entry."
)

alertcondition(
     instantTapShort,
     "ICT SMC FVG — Instant TAP SHORT",
     "{{ticker}} {{interval}}: bearish HTF FVG tapped — instant SHORT entry."
)

alertcondition(
     retestLongSetupEvent,
     "ICT SMC FVG — Retest LONG",
     "{{ticker}} {{interval}}: retest LONG setup detected."
)

alertcondition(
     retestShortSetupEvent,
     "ICT SMC FVG — Retest SHORT",
     "{{ticker}} {{interval}}: retest SHORT setup detected."
)

alertcondition(
     continuationLongSetupEvent,
     "ICT SMC FVG — Continuation LONG",
     "{{ticker}} {{interval}}: continuation LONG setup detected."
)

alertcondition(
     continuationShortSetupEvent,
     "ICT SMC FVG — Continuation SHORT",
     "{{ticker}} {{interval}}: continuation SHORT setup detected."
)

alertcondition(
     longFillEvent,
     "ICT SMC FVG — LONG filled",
     "{{ticker}} {{interval}}: LONG limit order has been filled."
)

alertcondition(
     shortFillEvent,
     "ICT SMC FVG — SHORT filled",
     "{{ticker}} {{interval}}: SHORT limit order has been filled."
)

alertcondition(
     takeProfitEvent,
     "ICT SMC FVG — Target reached",
     "{{ticker}} {{interval}}: target has been reached."
)

alertcondition(
     stopLossEvent,
     "ICT SMC FVG — Stop reached",
     "{{ticker}} {{interval}}: stop has been reached."
)

// =============================================================================
// 22. LONG / SHORT DASHBOARD
// =============================================================================

var table dashboard = table.new(
     position.top_right,
     3,
     24,
     border_width = 1
)

f_dashboardSingleRow(
     int row,
     string name,
     string valueText,
     color valueColor
) =>
    table.cell(
         dashboard,
         0,
         row,
         name,
         text_color = color.white,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         row,
         valueText,
         text_color = valueColor,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         row,
         "",
         text_color = color.white,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

f_dashboardTextRow(
     int row,
     string name,
     string longText,
     string shortText,
     color longColor,
     color shortColor
) =>
    table.cell(
         dashboard,
         0,
         row,
         name,
         text_color = color.white,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         row,
         longText,
         text_color = longColor,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         row,
         shortText,
         text_color = shortColor,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

f_dashboardRow(
     int row,
     string name,
     bool longValue,
     bool shortValue
) =>
    table.cell(
         dashboard,
         0,
         row,
         name,
         text_color = color.white,
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         row,
         f_boolText(longValue),
         text_color = f_boolColor(longValue),
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         row,
         f_boolText(shortValue),
         text_color = f_boolColor(shortValue),
         bgcolor = color.new(color.black, 15),
         text_size = dashboardTextSize
    )

if showDashboard and barstate.islast
    activeBias =
         htfActive
             ? htfDirection == 1
                 ? "LONG"
                 : "SHORT"
             : "NONE"

    activeBiasColor =
         activeBias == "LONG"
             ? color.lime
             : activeBias == "SHORT"
                 ? color.red
                 : color.gray

    activeKillzone =
         inAsiaKz
             ? "ASIA"
             : inLondonKz
                 ? "LONDON"
                 : inNyMorningKz
                     ? "NY AM"
                     : inNyAfternoonKz
                         ? "NY PM"
                         : "NONE"

    longRelevant = htfActive and htfDirection == 1
    shortRelevant = htfActive and htfDirection == -1

    retestRelevant = enableRetestStrategy and htfActive
    continuationRelevant = enableContinuationStrategy and htfActive

    retestReadyLong =
         longRelevant and
         ((modeDirect and touchHtfZone and (not requireLTFFvg or (ltfBull and ltfBullSizeOk))) or (not modeDirect and longRetestCore)) and
         killzoneOk and
         barConfirmed and
         canTrade

    retestReadyShort =
         shortRelevant and
         ((modeDirect and touchHtfZone and (not requireLTFFvg or (ltfBear and ltfBearSizeOk))) or (not modeDirect and shortRetestCore)) and
         killzoneOk and
         barConfirmed and
         canTrade

    retestStatus =
         not enableRetestStrategy
             ? "OFF"
             : not htfActive
                 ? "NO ACTIVE HTF FVG"
                 : htfDirection == 1
                     ? retestReadyLong
                         ? "READY"
                         : not htfLeft and not modeDirect and not allowDirectTap
                             ? "WAITING FOR DEPARTURE"
                             : not retestTagged and not modeDirect
                                 ? "WAITING FOR RETEST"
                                 : retestModeReject and not longRejection and not modeDirect
                                     ? "WAITING FOR REJECTION"
                                     : retestModeFvg and not (ltfBull and ltfBullSizeOk) and not modeDirect
                                         ? "NO LTF FVG"
                                         : not retestModeWick and not retestFresh and not modeDirect
                                             ? "RETEST EXPIRED"
                                             : requireKillzone and not inKillzone
                                                 ? "OUTSIDE KILLZONE"
                                                 : not barConfirmed
                                                     ? "WAITING FOR LTF CLOSE"
                                                     : not canTrade
                                                         ? "BUSY"
                                                         : "WAITING"
                     : retestReadyShort
                         ? "READY"
                         : not htfLeft and not modeDirect and not allowDirectTap
                             ? "WAITING FOR DEPARTURE"
                             : not retestTagged and not modeDirect
                                 ? "WAITING FOR RETEST"
                                 : retestModeReject and not shortRejection and not modeDirect
                                     ? "WAITING FOR REJECTION"
                                     : retestModeFvg and not (ltfBear and ltfBearSizeOk) and not modeDirect
                                         ? "NO LTF FVG"
                                         : not retestModeWick and not retestFresh and not modeDirect
                                             ? "RETEST EXPIRED"
                                             : requireKillzone and not inKillzone
                                                 ? "OUTSIDE KILLZONE"
                                                 : not barConfirmed
                                                     ? "WAITING FOR LTF CLOSE"
                                                     : not canTrade
                                                         ? "BUSY"
                                                         : "WAITING"

    continuationReadyLong =
         longRelevant and
         bullContinuationRaw and
         barConfirmed and
         canTrade

    continuationReadyShort =
         shortRelevant and
         bearContinuationRaw and
         barConfirmed and
         canTrade

    continuationStatus =
         not enableContinuationStrategy
             ? "OFF"
             : not htfActive
                 ? "NO ACTIVE HTF FVG"
                 : htfDirection == 1
                     ? continuationReadyLong
                         ? "READY"
                         : not (close > htfTop)
                             ? "NOT ALIGNED"
                             : not continuationKillzoneOk
                                 ? "OUTSIDE KILLZONE"
                                 : not continuationAgeOk
                                     ? "TOO OLD"
                                     : not bullContinuationDistanceOk
                                         ? "TOO EXTENDED"
                                         : not (ltfBull and ltfBullSizeOk)
                                             ? "NO LTF FVG"
                                             : continuationRequireStructureBreak and not bullContinuationStructureOk
                                                 ? "NO STRUCTURE BREAK"
                                                 : not barConfirmed
                                                     ? "WAITING FOR LTF CLOSE"
                                                     : not canTrade
                                                         ? "BUSY"
                                                         : "WAITING"
                     : continuationReadyShort
                         ? "READY"
                         : not (close < htfBottom)
                             ? "NOT ALIGNED"
                             : not continuationKillzoneOk
                                 ? "OUTSIDE KILLZONE"
                                 : not continuationAgeOk
                                     ? "TOO OLD"
                                     : not bearContinuationDistanceOk
                                         ? "TOO EXTENDED"
                                         : not (ltfBear and ltfBearSizeOk)
                                             ? "NO LTF FVG"
                                             : continuationRequireStructureBreak and not bearContinuationStructureOk
                                                 ? "NO STRUCTURE BREAK"
                                                 : not barConfirmed
                                                     ? "WAITING FOR LTF CLOSE"
                                                     : not canTrade
                                                         ? "BUSY"
                                                         : "WAITING"

    table.cell(
         dashboard,
         0,
         0,
         "STATE",
         text_color = color.yellow,
         bgcolor = color.new(color.black, 0),
         text_size = dashboardHeaderSize
    )

    table.cell(
         dashboard,
         1,
         0,
         "LONG",
         text_color = color.lime,
         bgcolor = color.new(color.black, 0),
         text_size = dashboardHeaderSize
    )

    table.cell(
         dashboard,
         2,
         0,
         "SHORT",
         text_color = color.red,
         bgcolor = color.new(color.black, 0),
         text_size = dashboardHeaderSize
    )

    f_dashboardTextRow(1, "Strategy mode", strategyMode, strategyMode, color.aqua, color.aqua)
    f_dashboardTextRow(
         2,
         "Active HTF bias",
         longRelevant ? "LONG" : "N/A",
         shortRelevant ? "SHORT" : "N/A",
         longRelevant ? color.lime : color.gray,
         shortRelevant ? color.red : color.gray
    )
    f_dashboardTextRow(
         3,
         "Active killzone",
         activeKillzone,
         activeKillzone,
         activeKillzone == "NONE" ? color.gray : color.yellow,
         activeKillzone == "NONE" ? color.gray : color.yellow
    )
    f_dashboardTextRow(
         4,
         "HTF FVG age",
         longRelevant and not na(htfAgeBars) ? str.tostring(htfAgeBars) + " bars" : "N/A",
         shortRelevant and not na(htfAgeBars) ? str.tostring(htfAgeBars) + " bars" : "N/A",
         longRelevant ? color.silver : color.gray,
         shortRelevant ? color.silver : color.gray
    )
    dashboardAvailableNow = canTrade and (instantTapEntry or barConfirmed)

    f_dashboardTextRow(
         5,
         "Available",
         longRelevant ? (dashboardAvailableNow ? "YES" : "no") : "N/A",
         shortRelevant ? (dashboardAvailableNow ? "YES" : "no") : "N/A",
         longRelevant ? (dashboardAvailableNow ? color.lime : color.red) : color.gray,
         shortRelevant ? (dashboardAvailableNow ? color.lime : color.red) : color.gray
    )

    f_dashboardTextRow(
         6,
         "RETEST STATUS",
         longRelevant ? retestStatus : "N/A",
         shortRelevant ? retestStatus : "N/A",
         longRelevant ? f_statusColor(retestStatus) : color.gray,
         shortRelevant ? f_statusColor(retestStatus) : color.gray
    )
    f_dashboardTextRow(
         7,
         "HTF departure",
         f_yesNoNa(longRelevant, htfLeft or modeDirect or allowDirectTap),
         f_yesNoNa(shortRelevant, htfLeft or modeDirect or allowDirectTap),
         longRelevant ? f_boolColor(htfLeft or modeDirect or allowDirectTap) : color.gray,
         shortRelevant ? f_boolColor(htfLeft or modeDirect or allowDirectTap) : color.gray
    )
    f_dashboardTextRow(
         8,
         "Retest tagged",
         f_yesNoNa(longRelevant, retestTagged or (modeDirect and touchHtfZone)),
         f_yesNoNa(shortRelevant, retestTagged or (modeDirect and touchHtfZone)),
         longRelevant ? f_boolColor(retestTagged or (modeDirect and touchHtfZone)) : color.gray,
         shortRelevant ? f_boolColor(retestTagged or (modeDirect and touchHtfZone)) : color.gray
    )
    f_dashboardTextRow(
         9,
         "LTF FVG",
         f_yesNoNa(longRelevant, ltfBull and ltfBullSizeOk),
         f_yesNoNa(shortRelevant, ltfBear and ltfBearSizeOk),
         longRelevant ? f_boolColor(ltfBull and ltfBullSizeOk) : color.gray,
         shortRelevant ? f_boolColor(ltfBear and ltfBearSizeOk) : color.gray
    )
    f_dashboardTextRow(
         10,
         "Rejection",
         f_yesNoNa(longRelevant, longRejection),
         f_yesNoNa(shortRelevant, shortRejection),
         longRelevant ? f_boolColor(longRejection) : color.gray,
         shortRelevant ? f_boolColor(shortRejection) : color.gray
    )

    f_dashboardTextRow(
         11,
         "CONTINUATION STATUS",
         longRelevant ? continuationStatus : "N/A",
         shortRelevant ? continuationStatus : "N/A",
         longRelevant ? f_statusColor(continuationStatus) : color.gray,
         shortRelevant ? f_statusColor(continuationStatus) : color.gray
    )
    f_dashboardTextRow(
         12,
         "HTF aligned",
         f_yesNoNa(longRelevant, close > htfTop),
         f_yesNoNa(shortRelevant, close < htfBottom),
         longRelevant ? f_boolColor(close > htfTop) : color.gray,
         shortRelevant ? f_boolColor(close < htfBottom) : color.gray
    )
    f_dashboardTextRow(
         13,
         "Fresh LTF FVG",
         f_yesNoNa(longRelevant, ltfBull and ltfBullSizeOk),
         f_yesNoNa(shortRelevant, ltfBear and ltfBearSizeOk),
         longRelevant ? f_boolColor(ltfBull and ltfBullSizeOk) : color.gray,
         shortRelevant ? f_boolColor(ltfBear and ltfBearSizeOk) : color.gray
    )
    f_dashboardTextRow(
         14,
         "Structure filter",
         longRelevant ? f_filterText(continuationRequireStructureBreak, bullContinuationStructureOk) : "N/A",
         shortRelevant ? f_filterText(continuationRequireStructureBreak, bearContinuationStructureOk) : "N/A",
         longRelevant ? (continuationRequireStructureBreak ? f_boolColor(bullContinuationStructureOk) : color.gray) : color.gray,
         shortRelevant ? (continuationRequireStructureBreak ? f_boolColor(bearContinuationStructureOk) : color.gray) : color.gray
    )
    f_dashboardTextRow(
         15,
         "Age valid",
         f_yesNoNa(longRelevant, continuationAgeOk),
         f_yesNoNa(shortRelevant, continuationAgeOk),
         longRelevant ? f_boolColor(continuationAgeOk) : color.gray,
         shortRelevant ? f_boolColor(continuationAgeOk) : color.gray
    )
    f_dashboardTextRow(
         16,
         "Distance valid",
         f_yesNoNa(longRelevant, bullContinuationDistanceOk),
         f_yesNoNa(shortRelevant, bearContinuationDistanceOk),
         longRelevant ? f_boolColor(bullContinuationDistanceOk) : color.gray,
         shortRelevant ? f_boolColor(bearContinuationDistanceOk) : color.gray
    )

    longDepthText = longRelevant and not na(longMitigationDepth) ? str.tostring(longMitigationDepth, "#.0") + "%" : "N/A"
    shortDepthText = shortRelevant and not na(shortMitigationDepth) ? str.tostring(shortMitigationDepth, "#.0") + "%" : "N/A"

    f_dashboardTextRow(17, "Mitigation depth", longDepthText, shortDepthText, color.aqua, color.aqua)
    f_dashboardSingleRow(18, "Mitigation count", htfActive ? str.tostring(mitigationCount) : "N/A", color.yellow)

    // v2.0: live target preview per side so a projected target (Fallback) is
    // visible BEFORE any entry is taken, not only on the trade label.
    longTargetPreviewText =
         longRelevant
             ? previewLongTargetTypeFinal + " @ " + str.tostring(previewLongTarget, format.mintick)
             : "N/A"
    shortTargetPreviewText =
         shortRelevant
             ? previewShortTargetTypeFinal + " @ " + str.tostring(previewShortTarget, format.mintick)
             : "N/A"

    f_dashboardTextRow(
         19,
         "Target (live)",
         longTargetPreviewText,
         shortTargetPreviewText,
         longRelevant ? (na(previewLongTarget) ? color.orange : color.lime) : color.gray,
         shortRelevant ? (na(previewShortTarget) ? color.orange : color.red) : color.gray
    )

    timeframePairText = htf + " → " + timeframe.period
    touchTypeText =
         exactTouchHtfZone
             ? "EXACT"
             : nearTouchHtfZone
                 ? "NEAR"
                 : "NONE"
    gapText =
         htfActive and not na(touchGapTicks)
             ? str.tostring(touchGapTicks, "#.##") + " ticks"
             : "N/A"
    bufferTicksText = str.tostring(nearTouchBuffer / syminfo.mintick, "#.##") + " ticks"

    f_dashboardSingleRow(20, "Timeframes", timeframePairText, validTimeframePair ? color.aqua : color.red)
    f_dashboardSingleRow(21, "Tracked active FVGs", str.tostring(activeFvgCount), color.yellow)
    f_dashboardSingleRow(22, "Current touch", touchTypeText, exactTouchHtfZone ? color.lime : nearTouchHtfZone ? color.yellow : color.gray)
    f_dashboardSingleRow(23, "Gap / buffer", gapText + " / " + bufferTicksText, color.silver)

if not showDashboard and barstate.islast
    table.clear(dashboard, 0, 0, 2, 23)
````
