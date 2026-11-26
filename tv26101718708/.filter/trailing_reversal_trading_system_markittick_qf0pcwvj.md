# Trailing Reversal Trading System [MarkitTick]

- url: https://www.tradingview.com/script/qf0pCWVj-Trailing-Reversal-Trading-System-MarkitTick/
- type: indicator
- pine_id: PUB;b8a645f5135a476d97bed2e30df77d5d
- version: 1.0

## Description

💡 The Trailing Reversal Trading System turns one classic, single-variable rule into a complete, rule-based trade workflow on the chart. Price is followed swing by swing: an up swing stays in force until price falls a set percentage from the highest point reached since the swing began, and a down swing stays in force until price rises the same percentage from the lowest point reached. Each confirmed reversal of the swing becomes a potential entry, each entry receives a volatility-based stop and three risk-multiple targets, and every event in the life of a trade, from entry to partial exits to the final close, is drawn on the chart, tracked on a dashboard and available as a structured alert. The goal is to give traders a transparent, mechanical way to follow the dominant swing while ignoring the minor price ripples that do not reach the chosen threshold.

[b]✨ Originality and Utility[/b]
The underlying idea, entering long when price rises n percent from a recent pivot low and selling long and selling short when price falls n percent from a recent pivot high, is documented by Robert W. Colby in his Encyclopedia of Technical Market Indicators, where n is the system's only variable. There is no built-in version of this system in Pine Script, and the description in the literature stops at the rule itself. This script builds the rule into a working tool and adds the parts a trader needs to act on it:
[list]
[*]A precise, state-based swing engine that tracks the running extreme of the current swing bar by bar, records the pivot each swing reversed from, and resolves the rare case where both reversal conditions appear on the same bar with a defined tie-break rather than an arbitrary choice.
[*]A live Reversal Level drawn on the chart, so the exact price that would end the current swing is always visible in advance instead of being discovered after the fact.
[*]A stop that combines two ideas: a distance measured in Average True Range from the entry, capped so it never sits beyond the pivot the swing reversed from. The dashboard states which of the two set the stop on every trade.
[*]Three targets expressed as multiples of the initial risk, automatically sorted nearest to farthest if they are entered out of order, and merged into a single label when two targets round to the same price.
[*]Two optional, independent entry filters (a higher-timeframe trend filter and an ADX trend-strength filter) that only gate new entries and never change the swing or the reversal exit.
[*]Safety checks that refuse to open a trade when the computed levels are invalid, together with counters that report how many reversals were filtered out and how many signals were rejected, so the user can see what the filters and checks are actually doing.
[*]Structured JSON alert messages for entries, partial exits and full exits, with configurable action words for automation workflows.
[/list]

[b]● Why these components belong together[/b]
The script combines a percentage swing rule, ATR, an exponential moving average on a higher timeframe and the ADX. These are not stacked for their own sake; each answers a different question the base rule leaves open:
[list]
[*]The percentage swing rule answers "which way is the dominant swing, and when has it reversed?" It is the only source of signals and exits.
[*]ATR answers "how far away should the stop be for current volatility?" A percentage reversal alone gives no sensible stop distance, because the pivot can be very far from the entry after a large move. ATR sizes the stop to the market's typical bar range, and the pivot cap keeps it from sitting beyond the point that defined the swing.
[*]The higher-timeframe EMA answers "is the larger trend on the same side as this entry?" It lets the user take only reversals aligned with the broader direction.
[*]The ADX answers "is the market trending at all?" Swing reversal rules suffer in sideways markets, where price can reverse back and forth across the threshold; the ADX filter lets the user stand aside when trend strength is low.
[/list]
The swing engine decides direction and timing, ATR and the pivot decide risk, and the two filters decide whether a given reversal is worth taking. Removing any one of them leaves a question unanswered.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/X4HLwB4D/[/image]
[b]• Choosing the price series[/b]
The Extremes setting decides which prices define the swing. In High/Low mode, the swing high is tracked on bar highs, the swing low on bar lows, and a reversal is measured on the opposite extreme: an up swing reverses when a bar's low falls the reversal percentage below the swing high, and a down swing reverses when a bar's high rises the reversal percentage above the swing low. In Close mode, pivots and reversals are all measured on closing prices, which ignores intrabar spikes.
Optionally, both series can be smoothed before anything is measured, using a simple, exponential, Wilder (RMA), weighted or Hull moving average of a chosen length. Smoothing removes small, noisy extremes; the trade-off is lag, and with smoothing on, the pivots and the pivot cap on the stop are smoothed values rather than actual bar highs or lows.

[b]• The swing engine[/b]
The script keeps a swing direction with three states: no swing yet, up swing, and down swing.
[list=1]
[*]While the swing is up (or not yet defined), every new higher value of the high series becomes the new swing high and its bar is recorded.
[*]While the swing is down (or not yet defined), every new lower value of the low series becomes the new swing low and its bar is recorded.
[*]An up swing reverses down when the low series reaches or falls below the swing high multiplied by (1 minus the reversal percentage). A down swing reverses up when the high series reaches or rises above the swing low multiplied by (1 plus the reversal percentage).
[*]A reversal can only be triggered on a bar after the bar that set the extreme, so a single wide bar cannot both set the extreme and reverse from it.
[*]When the swing reverses up, the swing low it reversed from is stored as the pivot low, and tracking of a new swing high starts from the current bar. When it reverses down, the swing high is stored as the pivot high, and tracking of a new swing low starts from the current bar.
[*]Before the first swing exists, both an up and a down reversal can qualify on the same bar. The script resolves this by favouring the extreme that was set more recently; if both were set on the same bar, the close relative to the midpoint of the swing high and swing low decides.
[/list]
The Reversal Level is then simply the swing high times (1 minus the percentage) during an up swing, or the swing low times (1 plus the percentage) during a down swing. Because the swing high can only rise during an up swing, the Reversal Level only moves up in an up swing, and only moves down in a down swing, which is what makes it a trailing level.

[b]• From reversal to entry[/b]
A long signal requires an up reversal, a short signal requires a down reversal, and in both cases the bar must be confirmed (closed). If the higher-timeframe filter is on, a long also requires the previous completed higher-timeframe close to be above its EMA, and a short requires it to be below. If the ADX filter is on, the previous confirmed bar's ADX must be at or above the chosen minimum. A reversal that passes the swing rule but fails a filter opens no trade and is added to the Filtered count.

[b]• Stop and targets[/b]
The entry price is the close of the signal bar. For a long, the stop candidate is the entry minus ATR times the SL ATR multiplier; the final stop is the higher of that candidate and the pivot low, so the stop is never placed below the pivot the swing reversed from. For a short, the mirror logic applies with the pivot high. Risk is the distance from entry to stop, and the three targets sit at the entry plus (long) or minus (short) risk times each R multiple.
Before a trade opens, the levels must pass several checks: the ATR must be available, the stop and all targets must be above zero, the risk must be larger than one tick, the stop must be on the correct side of the entry, and the first target must round to a price beyond the entry. A signal that fails any check opens no trade and is added to the Rejected count.

[b]• Managing an open trade[/b]
Trade events are checked only on bars after the entry bar:
[list]
[*]A target counts as hit when the bar's high (long) or low (short) touches it. TP1 and TP2 are partial exits; TP3 is the final exit.
[*]The stop counts as hit only when a bar closes beyond it, not when price merely wicks through it. This reduces exits on brief spikes, at the cost of exiting at the close of that bar, which may be beyond the stop price.
[*]An opposite swing reversal on a confirmed bar closes the trade at that bar's close, whether or not any target was reached. This reversal exit is never filtered: even if the filters block the opposite entry, the current trade still closes.
[/list]
A new trade replaces the previous one: the old levels are removed and the new set is drawn.

[b]• Lock Signal[/b]
When Lock Signal is on, the most recent bar cannot open a new trade and cannot close the current trade on a reversal, so the current signal is frozen on screen. Target and stop events are still tracked, and historical bars are not affected.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/uZiXHyZJ/[/image]
[b]• Reversal Level line[/b]
A step line that shows the price whose touch would reverse the current swing. It is drawn in the Bull colour (teal by default) during an up swing, where it sits below price and trails upward, and in the Bear colour (red by default) during a down swing, where it sits above price and trails downward. The line breaks when the swing direction changes, so each swing has its own segment, and it is absent until the first swing forms.

[b]• Swing Candles[/b]
The whole candle, body, wicks and border, is recoloured by swing direction: the Candle Bull colour (teal by default) during an up swing and the Candle Bear colour (red by default) during a down swing. Before the first swing forms, candles keep the chart's own colours. Because these candles are drawn over the chart's candles, the chart's own candle colours are hidden while this is on.

[b]• Trade level lines[/b]
When a trade opens, a set of horizontal lines starts at the signal bar:
[list]
[*]Stop line: solid, thicker, in the SL colour (red by default).
[*]Entry line: dashed, in the Entry colour (blue by default).
[*]TP1, TP2 and TP3 lines: dashed, in the TP colour (teal by default), with TP1 the most transparent and TP3 fully opaque, so the farthest target reads strongest.
[/list]
While the trade is open, the lines extend ten bars past the latest bar; once the trade closes, they stop ten bars after the closing bar, leaving a clear record of where the trade ended.

[b]• Level labels[/b]
At the right end of the lines, each level carries a filled label with white text: the stop label marked with a cross and its price, the entry label marked with a play arrow and its price, and the target labels marked with diamond or star markers and their prices. When two targets round to the same tick, they share one label, for example "TP1 / TP2", and the duplicate label is not drawn. When a level is reached, its label text changes to show it was hit, followed by the percentage move from the entry to that level, for example a positive percentage on a target and typically a negative one on the stop.

[b]• Dashboard[/b]
A two-column table, placed in the corner chosen in the settings. The header shows "TRTS" with the symbol and timeframe. Rows, from top to bottom:
[list]
[*]Lock: ACTIVE in the Bear colour when Lock Signal is on, otherwise OFF.
[*]Swing: Up, Down, or a dash before the first swing, coloured by direction.
[*]Reversal % and Extremes: the current settings.
[*]Swing High and Swing Low: the extreme of the current swing, or the last pivot on the other side.
[*]Reversal Level: the live reversal price, coloured by swing direction.
[*]To Reversal: a ten-block progress bar with a percentage, showing how much of the reversal distance price has already covered from the swing extreme. It is teal at 66% and above, amber from 33% to 65%, and red below 33%. A high reading means the swing is close to reversing.
[*]Signal: Long or Short for the latest trade.
[*]Status: Open, TP1 Hit, TP2 Hit, TP3 Hit, Stopped or Reversed, with "after TP1" or "after TP2" added when targets were reached before a stop or reversal.
[*]Entry, Stop, Stop Basis, TP1, TP2, TP3 and Exit: the trade's prices, with Stop Basis stating whether the ATR distance or the pivot cap set the stop.
[*]Risk: the entry-to-stop distance in price and as a percentage of the entry.
[*]Targets Hit and Bars Since: progress of the trade and bars since its signal.
[*]ATR: the current ATR value.
[*]Filtered and Rejected: running counts of reversals blocked by a filter and signals refused by the safety checks.
[*]Conditional rows: a warning-filled "Targets" row when the R inputs were out of order and have been sorted; an "HTF Filter" row showing Bull or Bear with the higher timeframe, or "Skipped · below chart TF" when the chosen timeframe is lower than the chart's; an "ADX Filter" row with a progress bar of the previous bar's ADX on a 0 to 100 scale; and a "Smoothing" row showing the method and length.
[/list]

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/7Cp5PlWs/[/image]
[list=1]
[*]Choose a Reversal % that suits your timeframe and holding period. Colby's guidance for this system is roughly 1% to 5% for traders and 7% to 15% for investors. Smaller values react sooner and produce more swings; larger values ignore more noise but give back more of each move before reversing.
[*]Read the swing first. Teal candles and a teal Reversal Level below price mean the up swing is in force; red candles and a red level above price mean the down swing is in force.
[*]Watch the Reversal Level and the To Reversal bar. As the bar fills toward 100%, price is approaching the level that would end the swing.
[*]When a reversal confirms at bar close and passes any active filters, the trade levels appear. The entry is the signal bar's close; the stop and targets are fixed at that moment.
[*]Manage the trade with the levels: TP1 and TP2 are natural places to scale out, TP3 is the final target, a close beyond the stop ends the trade, and an opposite reversal ends it regardless of targets.
[*]Use the filters when the base rule is too active. The ADX filter helps avoid reversals in quiet, trendless conditions; the higher-timeframe filter keeps entries on the side of the larger trend. Check the Filtered count to see how many reversals each filter is removing.
[*]If the Rejected count rises, the computed levels are often invalid, for example on very low-priced symbols where the risk falls below one tick, or early in the history before the ATR is available.
[/list]
The system is always in a swing but not always in a trade: a reversal that is filtered or rejected still flips the swing, so the candles and Reversal Level may change direction without a trade opening.

[b]● Repainting and data behaviour[/b]
Entries, stop exits and reversal exits are only taken on confirmed bars, and their alerts fire at bar close, so they do not change once the bar closes. The higher-timeframe filter reads the previous completed higher-timeframe bar, so it does not use future data. However, on the live, still-forming bar, the swing state is recalculated with every price update: the candle colour, the Reversal Level and the dashboard's swing values can change during the bar and may differ from what remains once the bar closes. Target hits are detected intrabar on a touch of the high or low and can be reported before the bar closes. Treat any swing flip on an unclosed bar as provisional until the bar confirms.

[b]● Alerts[/b]
Two kinds of alerts are available.
[list]
[*]Named alert conditions: BUY Signal, SELL Signal, TP1 Hit, TP2 Hit, TP3 Hit, Stop Hit and Reversal Close, each with a short fixed message.
[*]Structured messages, available through an "Any alert() function call" alert: each is a JSON object containing an action word, the ticker, the timeframe and the direction. Entry messages also carry the entry, stop, all three targets and the reversal percentage. TP1 and TP2 messages carry the partial-close action and the target reached. TP3, stop and reversal messages carry the close action, the exit price and the reason for the exit.
[/list]
Entry, stop and reversal messages are sent once per bar at bar close; target messages are sent once per bar when the touch occurs.

[b]⚙️ Inputs and Settings[/b]

[b]• Core[/b]
[list]
[*]Reversal %: the move away from the swing extreme that reverses the swing. This is the main control of the whole system.
[*]Extremes: High/Low measures swings on bar highs and lows; Close measures them on closing prices only.
[/list]

[b]• Filters[/b]
[list]
[*]HTF Filter, HTF TF and HTF EMA Len: turn on the higher-timeframe trend filter, choose its timeframe (it must not be lower than the chart's, or it is skipped), and set the EMA length used on that timeframe.
[*]ADX Filter, ADX Min and ADX Len: turn on the trend-strength filter, set the minimum ADX, and set the DI and ADX smoothing length.
[*]Smoothing and Smooth Len: optionally smooth the price series with SMA, EMA, RMA, WMA or HMA before swings are measured, and set the smoothing length.
[/list]

[b]• Trade Tools[/b]
[list]
[*]Lock Signal: freeze the current signal on the latest bar and block new ones.
[*]SL ATR: the stop distance in multiples of ATR, capped at the pivot the swing reversed from.
[*]TP1 R, TP2 R and TP3 R: the targets as multiples of the initial risk. Values entered out of order are sorted automatically.
[*]ATR Len: the ATR length used for the stop distance.
[/list]

[b]• Visuals and Dashboard[/b]
[list]
[*]Reversal Line and Candle Colors: show or hide the Reversal Level and the swing candle colouring.
[*]Show Dashboard and Position: show or hide the table and choose its corner.
[/list]

[b]• Alerts[/b]
[list]
[*]Long Action, Short Action, Close Long Action, Close Short Action, Partial Close Long Action and Partial Close Short Action: the action words written into the structured alert messages, so they can match whatever the receiving system expects.
[/list]

[b]• Colors[/b]
Every colour on the chart and the dashboard can be changed: Bull and Bear states, swing candles, stop, entry, targets, label text, the dashboard header, background and text, the three progress-bar colours, and the warning fill.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]• Percentage filters and the separation of signal from noise[/b]
The system belongs to the family of swing filters described in technical analysis literature: each high and low is examined, and reversals smaller than a minimum percentage are ignored, so that minor movements, the "ripples" of Dow Theory, are filtered out and only the main swings remain. Point and Figure charting is a long-established example of the same principle. Mathematically, the threshold acts as a non-linear filter: unlike a moving average, it does not average prices but makes a binary decision, either a move is large enough to count or it is discarded. This means the system responds with no averaging lag once the threshold is crossed, but it always gives back exactly the reversal percentage from the extreme before acknowledging a turn.

[b]• Why a percentage, not a fixed price distance[/b]
Measuring the reversal as a percentage of the extreme makes the rule scale-invariant: the same setting means the same relative move on a low-priced and a high-priced instrument, and it stays meaningful as one instrument's price changes over time. This reflects the common treatment of price changes in relative or logarithmic terms rather than absolute ones. Note that, because the reference point differs, a fall of n percent from a high and a rise of n percent from a low are not exact mirror images in absolute price.

[b]• The threshold as a trade-off between responsiveness and whipsaw[/b]
Any fixed threshold faces a fundamental trade-off. A small threshold detects turns early but is crossed more often by random fluctuations, producing frequent reversals in sideways markets. A large threshold produces fewer false reversals but surrenders a larger portion of each move at both entry and exit. There is no setting that is best in all conditions, which is why the threshold is exposed as the system's single main parameter and why the ADX filter is offered to stand aside when the market lacks directional strength.

[b]• Volatility normalisation of risk[/b]
The Average True Range, introduced by J. Welles Wilder, Jr. in 1978, measures how much price typically moves per bar, including gaps, as a Wilder-smoothed average of the true range. Using it for the stop distance ties risk to current volatility: in calm markets the stop sits closer, in volatile markets farther away. Expressing targets as multiples of that risk turns every trade into the same structure in risk units, which makes trades on different instruments and in different volatility regimes comparable. ATR measures volatility only, not direction, and its absolute values cannot be compared across instruments at different price levels.

[b]• Trend strength as a regime filter[/b]
The ADX, also from Wilder, measures the strength of a trend on a 0 to 100 scale without regard to its direction, derived from smoothed directional movement relative to the true range. Wilder designed it as a filter to keep traders out of sideways markets. Common readings treat values below about 20 as a weak or absent trend and values above about 25 as a strong one. Because of its heavy smoothing, the ADX lags and needs a long history to settle, so the filter reflects the recent regime rather than the current bar.

[b]• Multi-timeframe confirmation[/b]
The higher-timeframe filter applies the idea that a signal aligned with the larger trend is more consistent with the broader context. The exponential moving average weights recent prices more heavily, reducing lag compared with a simple average, and the script compares the previous completed higher-timeframe close with its EMA to define that larger trend without relying on an unfinished higher-timeframe bar.

[b]• Limitations of the framework[/b]
The rule assumes that swings large enough to cross the threshold tend to continue for some time. In markets that oscillate within a range roughly the size of the threshold, this assumption fails and the system can reverse repeatedly at a loss. Each exit by reversal gives back the full reversal percentage from the extreme, and stops based on bar closes can exit beyond the stop price. None of the filters remove these properties; they only change which reversals are taken.

[b]● Credits[/b]
The trailing reversal rule set and its typical settings follow the Trailing Reversal Trading System as described by Robert W. Colby in The Encyclopedia of Technical Market Indicators. Average True Range and the Directional Movement Index with ADX were developed by J. Welles Wilder, Jr. The Hull Moving Average smoothing option is based on the work of Alan Hull.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Trailing Reversal Trading System [MarkitTick]", overlay = true, behind_chart = false)

// ── INPUTS ──────────────────────────────────────────────────
var string GRP_CORE  = "⚙️ Core"
var string GRP_FILT  = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS   = "🎨 Visuals"
var string GRP_DASH  = "📊 Dashboard"
var string GRP_WH    = "🔔 Alerts"
var string GRP_COL   = "🌈 Colors"
i_revPct          = input.float(3.0, "Reversal %", minval = 0.1, maxval = 50, step = 0.1, group = GRP_CORE, tooltip = "Move away from the last pivot extreme that reverses the swing · Colby: 1–5% for traders, 7–15% for investors")
i_src             = input.string("High/Low", "Extremes", options = ["High/Low", "Close"], group = GRP_CORE, tooltip = "High/Low: pivots on bar highs and lows, the reversal on the opposite extreme · Close: pivots and reversal on closes")
i_htfOn           = input.bool(false, "HTF Filter", group = GRP_FILT, tooltip = "A long entry needs the HTF close above its EMA · a short below. The swing and the reversal exit are not filtered")
i_htfTf           = input.timeframe("D", "HTF TF", group = GRP_FILT, tooltip = "Not lower than the chart timeframe · a lower one is skipped and shown on the dashboard")
i_htfLen          = input.int(50, "HTF EMA Len", minval = 1, maxval = 500, group = GRP_FILT, tooltip = "EMA length on the HTF")
i_adxOn           = input.bool(false, "ADX Filter", group = GRP_FILT, tooltip = "An entry needs the previous confirmed bar's ADX at or above the minimum")
i_adxThr          = input.float(20.0, "ADX Min", minval = 0, maxval = 100, step = 0.5, group = GRP_FILT, tooltip = "ADX threshold")
i_adxLen          = input.int(14, "ADX Len", minval = 1, maxval = 100, group = GRP_FILT, tooltip = "DI and ADX smoothing length")
i_smooth          = input.string("None", "Smoothing", options = ["None", "SMA", "EMA", "RMA", "WMA", "HMA"], group = GRP_FILT, tooltip = "Smooths the extreme series before pivots and reversals are measured · the stop then sits on the smoothed pivot")
i_smLen           = input.int(3, "Smooth Len", minval = 2, maxval = 100, group = GRP_FILT, tooltip = "Smoothing length")
i_lockSignal      = input.bool(false, "Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_slAtr           = input.float(1.5, "SL ATR", minval = 0.1, maxval = 20, step = 0.1, group = GRP_TRADE, tooltip = "Stop sits this many ATR from the entry, never beyond the pivot the swing reversed from · no trade opens until the ATR is ready")
i_r1              = input.float(1.0, "TP1 R", minval = 0.1, maxval = 20, step = 0.1, group = GRP_TRADE, tooltip = "TP1 in multiples of risk · risk runs from the entry to the stop · targets out of order are sorted nearest to farthest and the dashboard says so")
i_r2              = input.float(2.0, "TP2 R", minval = 0.1, maxval = 20, step = 0.1, group = GRP_TRADE, tooltip = "TP2 in multiples of risk · risk runs from the entry to the stop · targets out of order are sorted nearest to farthest and the dashboard says so")
i_r3              = input.float(3.0, "TP3 R", minval = 0.1, maxval = 20, step = 0.1, group = GRP_TRADE, tooltip = "TP3 in multiples of risk · risk runs from the entry to the stop · targets out of order are sorted nearest to farthest and the dashboard says so")
i_atrLen          = input.int(14, "ATR Len", minval = 1, maxval = 200, group = GRP_TRADE, tooltip = "ATR length for the stop distance")
i_showRev         = input.bool(true, "Reversal Line", group = GRP_VIS, tooltip = "Live level whose break reverses the swing")
i_candles         = input.bool(true, "Candle Colors", group = GRP_VIS, tooltip = "Colours the whole candle — body, wicks and border — by swing direction, drawn over the chart's own candles · up swing in the bull candle colour, down swing in the bear candle colour, no swing yet left as is")
i_showDash        = input.bool(true, "Show Dashboard", group = GRP_DASH, tooltip = "Show the dashboard")
i_dashPos         = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH, tooltip = "Dashboard position")
i_actLong         = input.string("long", "↑ Long Action", group = GRP_WH, tooltip = "Webhook action for a long entry")
i_actShort        = input.string("short", "↓ Short Action", group = GRP_WH, tooltip = "Webhook action for a short entry")
i_actCloseLong    = input.string("closelong", "✕ Close Long Action", group = GRP_WH, tooltip = "Webhook action that closes a long: TP3, the stop or a reversal")
i_actCloseShort   = input.string("closeshort", "✕ Close Short Action", group = GRP_WH, tooltip = "Webhook action that closes a short: TP3, the stop or a reversal")
i_actPartLong     = input.string("partialcloselong", "✕ Partial Close Long Action", group = GRP_WH, tooltip = "Webhook action when TP1 or TP2 of a long is hit")
i_actPartShort    = input.string("partialcloseshort", "✕ Partial Close Short Action", group = GRP_WH, tooltip = "Webhook action when TP1 or TP2 of a short is hit")
C_SUP             = input.color(#26a69a, "Bull", group = GRP_COL, tooltip = "Bullish state and the reversal line in an up swing")
C_RES             = input.color(#ef5350, "Bear", group = GRP_COL, tooltip = "Bearish state and the reversal line in a down swing")
C_CDL_BULL        = input.color(#26a69a, "Candle Bull", group = GRP_COL, tooltip = "Candle colour in an up swing")
C_CDL_BEAR        = input.color(#ef5350, "Candle Bear", group = GRP_COL, tooltip = "Candle colour in a down swing")
C_SL              = input.color(#ef5350, "SL", group = GRP_COL, tooltip = "Stop line and label")
C_ENTRY           = input.color(#2196f3, "Entry", group = GRP_COL, tooltip = "Entry line and label")
C_TP              = input.color(#26a69a, "TP", group = GRP_COL, tooltip = "Target lines and labels")
C_LBL_TXT         = input.color(#ffffff, "Label Text", group = GRP_COL, tooltip = "Text on the level labels")
C_DASH_HDR        = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL, tooltip = "Dashboard header fill")
C_DASH_BG         = input.color(color.new(#0a0f1a, 10), "Dash BG", group = GRP_COL, tooltip = "Dashboard background")
C_DASH_TXT        = input.color(#ffffff, "Dash Text", group = GRP_COL, tooltip = "Dashboard text")
C_BAR_HI          = input.color(#26a69a, "Bar High", group = GRP_COL, tooltip = "Progress bar at 66% and above")
C_BAR_MID         = input.color(#f9a825, "Bar Mid", group = GRP_COL, tooltip = "Progress bar from 33% to 65%")
C_BAR_LO          = input.color(#ef5350, "Bar Low", group = GRP_COL, tooltip = "Progress bar under 33%")
C_WARN            = input.color(color.new(#f9a825, 80), "Warning", group = GRP_COL, tooltip = "Fill of a dashboard row that warns")

// ── CORE LOGIC ──────────────────────────────────────────────
f_smooth(float src, simple int len, string m) =>
    float _sma = ta.sma(src, len)
    float _ema = ta.ema(src, len)
    float _rma = ta.rma(src, len)
    float _wma = ta.wma(src, len)
    float _hma = ta.hma(src, len)
    switch m
        "SMA" => _sma
        "EMA" => _ema
        "RMA" => _rma
        "WMA" => _wma
        "HMA" => _hma
        => src
f_tfFmt(string tf) =>
    int    _len  = str.length(tf)
    string _unit = _len > 0 ? str.substring(tf, _len - 1, _len) : ""
    bool   _hasU = _unit == "T" or _unit == "S" or _unit == "D" or _unit == "W" or _unit == "M"
    string _num  = _hasU ? str.substring(tf, 0, _len - 1) : tf
    string _m    = _num == "" ? "1" : _num
    float  _mins = str.tonumber(_m)
    string _out  = switch _unit
        "T" => _m + "T"
        "S" => _m + "s"
        "D" => _m + "D"
        "W" => _m + "W"
        "M" => _m + "M"
        => not na(_mins) and _mins % 60 == 0 ? str.tostring(_mins / 60, "#") + "H" : _m + "m"
    _out
f_num(float v) =>
    string _o = "—"
    if not na(v)
        float _a = math.abs(v)
        string _sg = v < 0 ? "-" : ""
        float _k = math.round(_a / 1000, 1)
        float _m = math.round(_a / 1000000, 1)
        _o := math.round(_a, 2) < 1000 ? str.tostring(math.round(v, 2)) : _k < 1000 ? _sg + str.tostring(_k, "#.#") + "K" : _m < 1000 ? _sg + str.tostring(_m, "#.#") + "M" : _sg + str.tostring(math.round(_a / 1000000000, 1), "#.#") + "B"
    _o
f_px(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)
f_pctTxt(float lvl, float entry, bool isLong) =>
    float _p = (isLong ? lvl - entry : entry - lvl) / entry * 100
    (_p >= 0 ? "+" : "") + str.tostring(_p, "#.00") + "%"
f_bar(float val, float maxVal) =>
    float _v = math.max(val, 0)
    int filled = math.round(math.min(_v / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(math.min(_v / maxVal, 1.0) * 100)) + "%"
f_barColor(float pct) =>
    pct >= 0.66 ? C_BAR_HI : pct >= 0.33 ? C_BAR_MID : C_BAR_LO
f_esc(string s) =>
    str.replace_all(str.replace_all(s, "\\", "\\\\"), "\"", "\\\"")
f_n1(bool m12, bool m23) =>
    "TP1" + (m12 ? " / TP2" + (m23 ? " / TP3" : "") : "")
f_n2(bool m23) =>
    "TP2" + (m23 ? " / TP3" : "")
float _rawHi = i_src == "Close" ? close : high
float _rawLo = i_src == "Close" ? close : low
float hiS    = f_smooth(_rawHi, i_smLen, i_smooth)
float loS    = f_smooth(_rawLo, i_smLen, i_smooth)
float _n     = i_revPct / 100
var int   swingDir = 0
var float extHi    = float(na)
var int   extHiBar = int(na)
var float extLo    = float(na)
var int   extLoBar = int(na)
var float pivHi    = float(na)
var float pivLo    = float(na)
bool _srcOk = not na(hiS) and not na(loS)
if _srcOk and swingDir >= 0 and (na(extHi) or hiS > extHi)
    extHi    := hiS
    extHiBar := bar_index
if _srcOk and swingDir <= 0 and (na(extLo) or loS < extLo)
    extLo    := loS
    extLoBar := bar_index
bool _upRaw = _srcOk and swingDir <= 0 and not na(extLo) and bar_index > extLoBar and hiS >= extLo * (1 + _n)
bool _dnRaw = _srcOk and swingDir >= 0 and not na(extHi) and bar_index > extHiBar and loS <= extHi * (1 - _n)
bool _tieUp = extLoBar > extHiBar or (extLoBar == extHiBar and close >= (extHi + extLo) / 2)
bool flipUp = _upRaw and (not _dnRaw or _tieUp)
bool flipDn = _dnRaw and (not _upRaw or not _tieUp)
if flipUp
    pivLo    := extLo
    swingDir := 1
    extHi    := hiS
    extHiBar := bar_index
if flipDn
    pivHi    := extHi
    swingDir := -1
    extLo    := loS
    extLoBar := bar_index
float revLvl = swingDir == 1 ? extHi * (1 - _n) : swingDir == -1 ? extLo * (1 + _n) : na
bool   _htfValid = timeframe.in_seconds(i_htfTf) >= timeframe.in_seconds(timeframe.period)
bool   _htfAct   = i_htfOn and _htfValid
string _htfSym   = chart.is_standard ? syminfo.tickerid : ticker.standard(syminfo.tickerid)
float  _htfC     = na
float  _htfE     = na
if _htfAct
    [_c, _e] = request.security(_htfSym, i_htfTf, [close[1], ta.ema(close, i_htfLen)[1]], lookahead = barmerge.lookahead_on)
    _htfC := _c
    _htfE := _e
bool _htfBull    = not na(_htfC) and not na(_htfE) and _htfC > _htfE
bool _htfBear    = not na(_htfC) and not na(_htfE) and _htfC < _htfE
bool _htfLongOk  = not _htfAct or _htfBull
bool _htfShortOk = not _htfAct or _htfBear
[_diP, _diM, _adx] = ta.dmi(i_adxLen, i_adxLen)
float _adxPrev = _adx[1]
bool  _adxOk   = not i_adxOn or (not na(_adxPrev) and _adxPrev >= i_adxThr)
bool longSignal  = flipUp and _htfLongOk and _adxOk and barstate.isconfirmed
bool shortSignal = flipDn and _htfShortOk and _adxOk and barstate.isconfirmed
float _rA    = math.min(i_r1, math.min(i_r2, i_r3))
float _rC    = math.max(i_r1, math.max(i_r2, i_r3))
float _rB    = i_r1 + i_r2 + i_r3 - _rA - _rC
bool  _reord = i_r1 > i_r2 or i_r2 > i_r3
float _atrV  = ta.atr(i_atrLen)
var bool   isLong     = false
var float  entryPrice = float(na)
var float  slPrice    = float(na)
var float  tp1Price   = float(na)
var float  tp2Price   = float(na)
var float  tp3Price   = float(na)
var float  exitPrice  = float(na)
var int    _sigBar    = int(na)
var int    _closeBar  = int(na)
var int    _filtCnt   = 0
var int    _rejCnt    = 0
var string _slBasis   = "—"
var bool   _m12       = false
var bool   _m23       = false
var bool   tp1Hit     = false
var bool   tp2Hit     = false
var bool   tp3Hit     = false
var bool   slHit      = false
var bool   revClosed  = false
var line   slLine     = na
var line   entryLine  = na
var line   tp1Line    = na
var line   tp2Line    = na
var line   tp3Line    = na
var label  slLbl      = na
var label  entryLbl   = na
var label  tp1Lbl     = na
var label  tp2Lbl     = na
var label  tp3Lbl     = na
f_deleteLevels() =>
    line.delete(slLine), line.delete(entryLine)
    line.delete(tp1Line), line.delete(tp2Line), line.delete(tp3Line)
    label.delete(slLbl), label.delete(entryLbl)
    label.delete(tp1Lbl), label.delete(tp2Lbl), label.delete(tp3Lbl)
string _dirTxt  = isLong ? "long" : "short"
string _tk      = f_esc(syminfo.tickerid)
string _tf      = f_esc(timeframe.period)
string _pTp1    = ""
string _pTp2    = ""
string _pTp3    = ""
string _pSl     = ""
string _pRev    = ""
bool _live     = not na(entryPrice) and bar_index > _sigBar and not revClosed
bool _tp1Cross = isLong ? high >= tp1Price : low <= tp1Price
bool _tp2Cross = isLong ? high >= tp2Price : low <= tp2Price
bool _tp3Cross = isLong ? high >= tp3Price : low <= tp3Price
bool _slCross  = barstate.isconfirmed and (isLong ? close < slPrice : close > slPrice)
bool _tp1Evt = _live and not slHit and not tp1Hit and _tp1Cross
if _tp1Evt
    tp1Hit := true
    label.set_text(tp1Lbl, f_n1(_m12, _m23) + " ✓ HIT " + f_pctTxt(tp1Price, entryPrice, isLong))
    _pTp1 := str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","sl":"{5}","tp":"{6}","target":"TP1"', f_esc(isLong ? i_actPartLong : i_actPartShort), _tk, _tf, _dirTxt, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick))
bool _tp2Evt = _live and not slHit and not tp2Hit and _tp2Cross
if _tp2Evt
    tp2Hit := true
    if not na(tp2Lbl)
        label.set_text(tp2Lbl, f_n2(_m23) + " ✓ HIT " + f_pctTxt(tp2Price, entryPrice, isLong))
    _pTp2 := str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","sl":"{5}","tp":"{6}","target":"TP2"', f_esc(isLong ? i_actPartLong : i_actPartShort), _tk, _tf, _dirTxt, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp2Price, format.mintick))
bool _tp3Evt = _live and not slHit and not tp3Hit and _tp3Cross
if _tp3Evt
    tp3Hit    := true
    exitPrice := tp3Price
    if not na(tp3Lbl)
        label.set_text(tp3Lbl, "TP3 ✓ HIT " + f_pctTxt(tp3Price, entryPrice, isLong))
    _pTp3 := str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","exit":"{5}","reason":"tp3"', f_esc(isLong ? i_actCloseLong : i_actCloseShort), _tk, _tf, _dirTxt, str.tostring(entryPrice, format.mintick), str.tostring(tp3Price, format.mintick))
bool _slEvt = _live and not slHit and not tp3Hit and _slCross
if _slEvt
    slHit     := true
    exitPrice := close
    label.set_text(slLbl, "SL ✓ HIT " + f_pctTxt(close, entryPrice, isLong))
    _pSl := str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","exit":"{5}","reason":"stop"', f_esc(isLong ? i_actCloseLong : i_actCloseShort), _tk, _tf, _dirTxt, str.tostring(entryPrice, format.mintick), str.tostring(close, format.mintick))
bool _locked    = i_lockSignal and barstate.islast
bool _tradeOpen = not na(entryPrice) and not slHit and not tp3Hit and not revClosed
bool _revEvt    = _tradeOpen and barstate.isconfirmed and not _locked and (isLong ? flipDn : flipUp)
if _revEvt
    revClosed := true
    exitPrice := close
    _pRev := str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":"{4}","exit":"{5}","reason":"reversal"', f_esc(isLong ? i_actCloseLong : i_actCloseShort), _tk, _tf, _dirTxt, str.tostring(entryPrice, format.mintick), str.tostring(close, format.mintick))
bool _finalTpHit  = tp3Hit
bool _tradeClosed = slHit or _finalTpHit or revClosed
if not na(slLine) and _tradeClosed and na(_closeBar)
    _closeBar := bar_index
bool _extUpdate = _tradeClosed ? _closeBar == bar_index : barstate.islast
if not na(slLine) and _extUpdate
    int _extX = _tradeClosed ? _closeBar + 10 : last_bar_index + 10
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    label.set_x(tp1Lbl, _extX)
    if not na(tp2Lbl)
        label.set_x(tp2Lbl, _extX)
    if not na(tp3Lbl)
        label.set_x(tp3Lbl, _extX)
bool  _newLong  = longSignal and not _locked
bool  _newShort = shortSignal and not _locked
float _cEntry   = close
float _atrStL   = _cEntry - _atrV * i_slAtr
float _atrStS   = _cEntry + _atrV * i_slAtr
float _cStop    = na(_atrV) ? na : _newLong ? math.max(pivLo, _atrStL) : _newShort ? math.min(pivHi, _atrStS) : na
float _cRisk    = math.abs(_cEntry - _cStop)
float _cT1      = _newLong ? _cEntry + _cRisk * _rA : _cEntry - _cRisk * _rA
float _cT2      = _newLong ? _cEntry + _cRisk * _rB : _cEntry - _cRisk * _rB
float _cT3      = _newLong ? _cEntry + _cRisk * _rC : _cEntry - _cRisk * _rC
bool  _lvlOk    = not na(_cStop) and not na(_cRisk) and _cStop > 0 and _cT1 > 0 and _cT2 > 0 and _cT3 > 0 and _cRisk > syminfo.mintick
bool  _sideOk   = _newLong ? _cStop < _cEntry and math.round_to_mintick(_cT1) > math.round_to_mintick(_cEntry) : _cStop > _cEntry and math.round_to_mintick(_cT1) < math.round_to_mintick(_cEntry)
bool  _safe     = _lvlOk and _sideOk
bool  _armL     = _newLong and _safe
bool  _armS     = _newShort and _safe
if (flipUp and not longSignal or flipDn and not shortSignal) and barstate.isconfirmed
    _filtCnt += 1
if (_newLong or _newShort) and not _safe
    _rejCnt += 1
if _armL or _armS
    f_deleteLevels()
    tp1Hit     := false
    tp2Hit     := false
    tp3Hit     := false
    slHit      := false
    revClosed  := false
    _closeBar  := na
    exitPrice  := na
    isLong     := _armL
    entryPrice := _cEntry
    slPrice    := _cStop
    _slBasis   := (_armL ? _atrStL <= pivLo : _atrStS >= pivHi) ? "Pivot" : "ATR"
    tp1Price   := _cT1
    tp2Price   := _cT2
    tp3Price   := _cT3
    _sigBar    := bar_index
    _m12       := math.round_to_mintick(tp2Price) == math.round_to_mintick(tp1Price)
    _m23       := math.round_to_mintick(tp3Price) == math.round_to_mintick(tp2Price)
    int _x2     = bar_index + 10
    slLine     := line.new(bar_index, slPrice, _x2, slPrice, color = C_SL, style = line.style_solid, width = 2)
    entryLine  := line.new(bar_index, entryPrice, _x2, entryPrice, color = C_ENTRY, style = line.style_dashed, width = 1)
    tp1Line    := line.new(bar_index, tp1Price, _x2, tp1Price, color = color.new(C_TP, 40), style = line.style_dashed, width = 1)
    tp2Line    := line.new(bar_index, tp2Price, _x2, tp2Price, color = color.new(C_TP, 20), style = line.style_dashed, width = 1)
    tp3Line    := line.new(bar_index, tp3Price, _x2, tp3Price, color = color.new(C_TP, 0), style = line.style_dashed, width = 1)
    slLbl      := label.new(_x2, slPrice, "✕ SL " + str.tostring(slPrice, format.mintick), style = label.style_label_left, color = color.new(C_SL, 0), textcolor = C_LBL_TXT, size = size.small)
    entryLbl   := label.new(_x2, entryPrice, "▶ Entry " + str.tostring(entryPrice, format.mintick), style = label.style_label_left, color = color.new(C_ENTRY, 0), textcolor = C_LBL_TXT, size = size.small)
    tp1Lbl     := label.new(_x2, tp1Price, "◆ " + f_n1(_m12, _m23) + " " + str.tostring(tp1Price, format.mintick), style = label.style_label_left, color = color.new(C_TP, 0), textcolor = C_LBL_TXT, size = size.small)
    tp2Lbl     := _m12 ? na : label.new(_x2, tp2Price, "✦ " + f_n2(_m23) + " " + str.tostring(tp2Price, format.mintick), style = label.style_label_left, color = color.new(C_TP, 0), textcolor = C_LBL_TXT, size = size.small)
    tp3Lbl     := _m23 ? na : label.new(_x2, tp3Price, "◆ TP3 " + str.tostring(tp3Price, format.mintick), style = label.style_label_left, color = color.new(C_TP, 0), textcolor = C_LBL_TXT, size = size.small)

// ── ALERTS ──────────────────────────────────────────────────
if _tp1Evt
    alert("{" + _pTp1 + "}", alert.freq_once_per_bar)
if _tp2Evt
    alert("{" + _pTp2 + "}", alert.freq_once_per_bar)
if _tp3Evt
    alert("{" + _pTp3 + "}", alert.freq_once_per_bar)
if _slEvt
    alert("{" + _pSl + "}", alert.freq_once_per_bar_close)
if _revEvt
    alert("{" + _pRev + "}", alert.freq_once_per_bar_close)
if _armL and barstate.isconfirmed
    string _lInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","reversal":"{8}"', f_esc(i_actLong), _tk, _tf, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick), str.tostring(i_revPct))
    alert("{" + _lInner + "}", alert.freq_once_per_bar_close)
if _armS and barstate.isconfirmed
    string _sInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","reversal":"{8}"', f_esc(i_actShort), _tk, _tf, str.tostring(entryPrice, format.mintick), str.tostring(slPrice, format.mintick), str.tostring(tp1Price, format.mintick), str.tostring(tp2Price, format.mintick), str.tostring(tp3Price, format.mintick), str.tostring(i_revPct))
    alert("{" + _sInner + "}", alert.freq_once_per_bar_close)
alertcondition(_armL and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(_armS and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(_tp1Evt, "TP1 Hit", "MarkitTick — TP1 Reached")
alertcondition(_tp2Evt, "TP2 Hit", "MarkitTick — TP2 Reached")
alertcondition(_tp3Evt, "TP3 Hit", "MarkitTick — TP3 Reached")
alertcondition(_slEvt, "Stop Hit", "MarkitTick — Stop Hit")
alertcondition(_revEvt, "Reversal Close", "MarkitTick — Trade Closed on Reversal")

// ── VISUALS ─────────────────────────────────────────────────
plot(revLvl, "Reversal Level", color = i_showRev ? (swingDir == 1 ? C_SUP : C_RES) : na, style = plot.style_steplinebr, linewidth = 1)
color _cdlCol = i_candles ? (swingDir == 1 ? C_CDL_BULL : swingDir == -1 ? C_CDL_BEAR : na) : na
plotcandle(open, high, low, close, title = "Swing Candles", color = _cdlCol, wickcolor = _cdlCol, bordercolor = _cdlCol)

// ── DASHBOARD ───────────────────────────────────────────────
string _posC = switch i_dashPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right
var table _tb = i_showDash ? table.new(_posC, 2, 28, bgcolor = C_DASH_BG, frame_color = color.new(#3a2a6d, 40), frame_width = 1, border_color = color.new(#2a3040, 40), border_width = 1) : na
f_row(table t, int r, string lbl, string val, color vc, bool warn, string tip) =>
    color _bg = warn ? C_WARN : r % 2 == 1 ? C_DASH_BG : color.new(C_DASH_BG, 40)
    table.cell(t, 0, r, "  " + lbl, text_color = color.new(C_DASH_TXT, 25), text_halign = text.align_left, text_size = size.small, bgcolor = _bg, tooltip = tip)
    table.cell(t, 1, r, val + "  ", text_color = vc, text_halign = text.align_right, text_size = size.small, bgcolor = _bg, tooltip = tip)
if barstate.islast and i_showDash
    float  _risk    = na(entryPrice) ? na : math.abs(entryPrice - slPrice)
    float  _riskPct = na(_risk) ? na : _risk / entryPrice * 100
    int    _tpCnt   = (tp1Hit ? 1 : 0) + (tp2Hit ? 1 : 0) + (tp3Hit ? 1 : 0)
    float  _prog    = swingDir == 1 and extHi > revLvl ? (extHi - loS) / (extHi - revLvl) : swingDir == -1 and revLvl > extLo ? (hiS - extLo) / (revLvl - extLo) : na
    float  _progC   = na(_prog) ? na : math.max(0.0, math.min(1.0, _prog))
    string _swTxt   = swingDir == 1 ? "Up" : swingDir == -1 ? "Down" : "—"
    color  _swCol   = swingDir == 1 ? C_SUP : swingDir == -1 ? C_RES : C_DASH_TXT
    string _sigTxt  = na(entryPrice) ? "—" : isLong ? "Long" : "Short"
    color  _sigCol  = na(entryPrice) ? C_DASH_TXT : isLong ? C_SUP : C_RES
    string _after   = _tpCnt > 0 ? " after TP" + str.tostring(_tpCnt) : ""
    string _status  = na(entryPrice) ? "—" : revClosed ? "Reversed" + _after : slHit ? "Stopped" + _after : tp3Hit ? "TP3 Hit" : tp2Hit ? "TP2 Hit" : tp1Hit ? "TP1 Hit" : "Open"
    color  _statCol = na(entryPrice) ? C_DASH_TXT : slHit ? C_RES : _tpCnt > 0 ? C_SUP : C_DASH_TXT
    string _htfTxt  = not _htfValid ? "Skipped · below chart TF" : (_htfBull ? "Bull" : _htfBear ? "Bear" : "—") + " · " + f_tfFmt(i_htfTf)
    color  _htfCol  = not _htfValid ? C_DASH_TXT : _htfBull ? C_SUP : _htfBear ? C_RES : C_DASH_TXT
    table.cell(_tb, 0, 0, "TRTS", text_color = C_DASH_TXT, text_halign = text.align_left, text_size = size.small, bgcolor = C_DASH_HDR)
    table.cell(_tb, 1, 0, syminfo.ticker + "  ·  " + f_tfFmt(timeframe.period), text_color = C_DASH_TXT, text_halign = text.align_right, text_size = size.small, bgcolor = C_DASH_HDR)
    int r = 1
    f_row(_tb, r, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? C_RES : C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Swing", _swTxt, _swCol, false, "No swing until price first moves the reversal % away from an extreme")
    r += 1
    f_row(_tb, r, "Reversal %", str.tostring(i_revPct, "#.0#") + "%", C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Extremes", i_src, C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Swing High", f_px(extHi), C_RES, false, "Highest point of the current up swing, or the last pivot high in a down swing")
    r += 1
    f_row(_tb, r, "Swing Low", f_px(extLo), C_SUP, false, "Lowest point of the current down swing, or the last pivot low in an up swing")
    r += 1
    f_row(_tb, r, "Reversal Level", f_px(revLvl), _swCol, false, "Price whose touch reverses the swing")
    r += 1
    f_row(_tb, r, "To Reversal", na(_progC) ? "—" : f_bar(_progC, 1), na(_progC) ? C_DASH_TXT : f_barColor(_progC), false, "Share of the reversal % already covered from the swing extreme")
    r += 1
    f_row(_tb, r, "Signal", _sigTxt, _sigCol, false, "")
    r += 1
    f_row(_tb, r, "Status", _status, _statCol, false, "")
    r += 1
    f_row(_tb, r, "Entry", f_px(entryPrice), C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Stop", f_px(slPrice), C_RES, false, "ATR distance from the entry, capped at the pivot the swing reversed from")
    r += 1
    f_row(_tb, r, "Stop Basis", _slBasis, C_DASH_TXT, false, "ATR: the ATR distance set the stop · Pivot: the cap at the pivot set it")
    r += 1
    f_row(_tb, r, "TP1", f_px(tp1Price), C_SUP, false, "")
    r += 1
    f_row(_tb, r, "TP2", f_px(tp2Price), C_SUP, false, "")
    r += 1
    f_row(_tb, r, "TP3", f_px(tp3Price), C_SUP, false, "")
    r += 1
    f_row(_tb, r, "Exit", f_px(exitPrice), C_DASH_TXT, false, "Price the last trade closed at")
    r += 1
    f_row(_tb, r, "Risk", na(_risk) ? "—" : f_px(_risk) + " · " + str.tostring(_riskPct, "#.00") + "%", C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Targets Hit", na(entryPrice) ? "—" : str.tostring(_tpCnt), C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Bars Since", na(_sigBar) ? "—" : f_num(bar_index - _sigBar), C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "ATR", f_px(_atrV), C_DASH_TXT, false, "")
    r += 1
    f_row(_tb, r, "Filtered", f_num(_filtCnt), C_DASH_TXT, false, "Swing reversals that opened no trade because a filter blocked the entry")
    r += 1
    f_row(_tb, r, "Rejected", f_num(_rejCnt), C_DASH_TXT, false, "Signals that opened no trade because a level failed the safety checks or the ATR was not ready")
    r += 1
    if _reord
        f_row(_tb, r, "Targets", "Sorted nearest to farthest", C_DASH_TXT, true, "TP R inputs were out of order")
        r += 1
    if i_htfOn
        f_row(_tb, r, "HTF Filter", _htfTxt, _htfCol, not _htfValid, "")
        r += 1
    if i_adxOn
        f_row(_tb, r, "ADX Filter", na(_adxPrev) ? "—" : f_bar(_adxPrev, 100), na(_adxPrev) ? C_DASH_TXT : f_barColor(_adxPrev / 100), false, "Previous confirmed bar's ADX against the minimum")
        r += 1
    if i_smooth != "None"
        f_row(_tb, r, "Smoothing", i_smooth + " · " + str.tostring(i_smLen), C_DASH_TXT, false, "")
````
