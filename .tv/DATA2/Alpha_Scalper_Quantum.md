<!-- tradingview-pine-id: PUB;ccc61da063614670a2602f6db8114917 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Alpha Scalper Quantum

Source: https://www.tradingview.com/script/zq3I2bwS-Alpha-Scalper-Quantum/

## Description

ALPHA SCALPER QUANTUM

WHAT IT IS

Alpha Scalper Quantum (ASQ) is a multi-timeframe RSI-based signal engine that combines a custom momentum oscillator with a four-layer macro moving average trend filter. It operates across two timeframes simultaneously — a user-defined macro timeframe that establishes trend context, and the chart's native timeframe where precision entry signals fire. The result is a system that does not generate signals blindly against the trend: every micro entry is validated against a macro structural bias before it reaches the chart.
https://www.tradingview.com/x/1cVAX326/
https://www.tradingview.com/x/KmQTB9uD/
The oscillator itself is not a standard RSI. It uses a custom range-normalized momentum formula that tracks where the current price sits relative to its recent high/low range, weighted optionally by volume. This makes it respond differently to strong-volume impulses versus low-volume noise — something the classic Wilder RSI does not distinguish.

THE RSI ENGINE — HOW IT ACTUALLY WORKS

Standard RSI compares average gains to average losses over N bars. ASQ replaces this with a range-normalized momentum approach: it measures the distance the current bar has moved relative to the highest high and lowest low of the lookback window. The result is scaled to a 0–100 range, centered at 50. This naturally responds more cleanly to sharp moves because it anchors to actual price range extremes, not just close-to-close differences.

When Volume Weighted RSI is enabled, each momentum reading is multiplied by the bar's volume before being smoothed. A candle that moves 30 pips on ten times average volume carries ten times the weight in the oscillator. A whipsaw on paper-thin volume barely registers. This is particularly useful in futures and crypto markets where volume spikes around institutional entries create reliable momentum anchors.

The Higher Timeframe RSI option feeds the micro signal engine with RSI data from a higher timeframe instead of the chart timeframe. This is a structurally different approach from simply showing two RSI plots side by side — the trigger conditions themselves use the HTF oscillator reading, meaning your entry triggers fire based on momentum state at a more macro level while you watch price on a faster chart.

MACRO TREND FILTER — THE FOUR-MA STACK

ASQ uses four moving averages computed on the macro timeframe (default: 15-minute), defaulting to EMA 8, EMA 16, EMA 30, and EMA 50. Each MA type is individually selectable: SMA, EMA, WMA, VWMA, or HMA. You can mix types — for example, an HMA 8 for speed with an SMA 50 as the anchor.
https://www.tradingview.com/x/haJFhA2Z/
https://www.tradingview.com/x/we8P557F/
Macro bullish alignment is declared when MA1 > MA2 > MA3 > MA4 — a clean stack from fastest to slowest, all pointing the same direction. Macro bearish alignment is the exact inverse. This is a strict condition. In a choppy, ranging market, it will not align, and ASQ will not produce macro signals. This is by design: the filter is intentionally conservative to keep signal quality high.

The macro trend condition additionally requires price to close above MA1 (for bull) or below MA1 (for bear). This means an MA stack can be fully aligned but if price is under MA1, the system does not declare a macro uptrend. Trend structure and price position must agree.

The dashboard shows each MA pair relationship individually (8 vs 16, 16 vs 30, 30 vs 50) as green/red cells, so you can see at a glance how close the stack is to full alignment — useful when the market is transitioning.

All four MAs are pulled from the macro timeframe using request.security, meaning even on a 1-minute chart you are looking at the structural alignment of the 15-minute (or whatever macro TF you set) moving average stack. No repainting when "Wait for Macro Candle Close" is enabled.

MICRO SIGNAL ENGINE — THREE DISTINCT TRIGGER PATTERNS

This is where ASQ separates itself from basic RSI crossover indicators. There are three independent micro signal patterns, each targeting a different price behavior.

Signal 1 — Full Cycle Reversal
Trigger: RSI has touched the oversold zone (30 or below), then the same RSI crosses back above the overbought zone (70 or above) while the macro trend is bullish.
https://www.tradingview.com/x/BSKx3D8r/
https://www.tradingview.com/x/bZP70uQ7/
This captures parabolic V-shaped recoveries. The RSI must have genuinely entered oversold territory before this triggers, and it only fires when the momentum swing is so strong that RSI launches directly from below 30 to above 70 without a 50 midline rejection. In strong bull trends this pattern often precedes the sharpest impulse legs. The sell-side equivalent requires RSI to touch overbought then crash directly below 30.

Signal 2 — Failed Breakout Pullback
Trigger: RSI reaches overbought (70 or above), then retreats below 70 (shallow pullback), but has not yet fallen to 50. While RSI is between 50 and 70 during this cooling phase, if it then crosses back above 70 again — signal fires.
https://www.tradingview.com/x/0ICY7eVl/
https://www.tradingview.com/x/Tx8N2wlD/
This is a pullback-to-continuation pattern on the oscillator level. Price pulls back, RSI pulls off extreme territory, but the trend is intact — and when RSI re-enters overbought from this shallow position it signals the next impulse leg is beginning. This is used in trending markets to catch the second and third wave of a move without waiting for a full RSI reset.

Signal 3 — Midline Momentum Confirmation
Trigger: RSI has previously entered overbought (70 or above) and then crossed back below 50, while macro trend is bearish. When RSI then crosses above 50 upward while in this state — signal fires. Inverted for buys: RSI must have been in oversold, crossed above 50, then crossed back below 50 downward in a downtrend.
https://www.tradingview.com/x/4nnWWLcU/
https://www.tradingview.com/x/1991YYWP/
This pattern targets the momentum confirmation at the 50 midline — where RSI often pauses during a trend change. It is the most conservative of the three patterns, firing at the earliest stage of a new directional momentum shift when RSI recrosses the equilibrium level.

All three signals require macro trend alignment at the time of fire. A micro buy only generates in a macro bullish structure. A micro sell only generates in a macro bearish structure. Signals that do not meet both conditions are silently discarded.

MACRO SIGNAL — TREND ALIGNMENT DETECTION

Separate from micro signals, ASQ fires a Macro Buy or Macro Sell signal the moment the four-MA stack first achieves full alignment in either direction. This is a transition event — it fires once when the stack locks into alignment, not on every subsequent bar. It is the structural entry signal: you are being told the macro trend just confirmed.

The macro signal is visualized with a square marker (default) on the RSI sub-pane and simultaneously draws a pivot-based stop line on the main chart. The candle coloring system also activates with the deeper macro colors (darker green for bull, darker red for bear) when a macro signal is active.

DIVERGENCE DETECTION — REGULAR AND HIDDEN

ASQ includes a full divergence detection module that operates independently of the signal engine. It uses pivot highs and pivot lows on both the RSI oscillator and the price series simultaneously. Two conditions are evaluated for each pivot pair.

Regular Bullish Divergence: Price makes a lower low, RSI makes a higher low. Classic exhaustion divergence — momentum is building even as price tests new lows, warning of a reversal.

Regular Bearish Divergence: Price makes a higher high, RSI makes a lower high. Classic topping divergence — momentum is weakening even as price extends higher.

Hidden Bullish Divergence: Price makes a higher low (within an uptrend), RSI makes a lower low. This is a trend continuation pattern — the pullback is shallower in price than in momentum, suggesting the underlying trend is intact and the dip is buyable.

Hidden Bearish Divergence: Price makes a lower high (within a downtrend), RSI makes a higher high. Trend continuation sell signal on a bounce — momentum already peaked, price is just retesting resistance.

Hidden divergences only activate when the matching macro trend is confirmed (hidden bull requires macro uptrend, hidden bear requires macro downtrend), which prevents you from misreading continuation patterns as reversals.
https://www.tradingview.com/x/wiD6KvWg/
https://www.tradingview.com/x/T6Tw1HjO/
The divergence engine filters by minimum pivot strength (default 0.3 from midline), meaning RSI pivots near the 50 level do not qualify — only pivots with meaningful displacement toward either extreme count. A minimum bar distance between pivots (default 10) prevents duplicate detections on clustered pivots.

Divergence lines are drawn directly on the RSI sub-pane: solid lines for regular divergences, dashed lines for hidden divergences. Marker shapes appear at the divergence pivot location so they are unmistakable on a busy chart.

PIVOT-BASED STOP LOSS LINES

Every time a confirmed micro or macro signal fires, ASQ draws a horizontal stop-loss reference line on the main chart. For buy signals, the line is drawn at the most recent pivot low. For sell signals, at the most recent pivot high. The line extends forward by a configurable number of bars.
https://www.tradingview.com/x/5funY4b3/
https://www.tradingview.com/x/D3QQivPF/
The pivot calculation uses left/right bar parameters (default 3 left, 1 right) which you can adjust based on the timeframe and volatility of the asset. Shorter bar counts produce tighter, more recent pivots. Longer counts identify stronger structural pivots. The suggested stop loss value will appear on the dashboard, this facilitate the trade for scalpers.

This is not a hard stop — it is a reference. The intent is to show you the nearest relevant structural level at the moment the signal fired. Micro buy stops use the micro buy color. Macro buy stops use the macro buy color. This way you can instantly see which timeframe's logic generated the stop reference. A configurable maximum line count keeps older lines from cluttering the chart.

CANDLE COLORING — DUAL-LAYER SYSTEM

ASQ overlays colored candles on the main chart using a layered priority system. There are four possible candle states: macro bull, macro bear, micro bull, and micro bear. Macro signals take visual priority over micro signals when both are active.

Once a signal activates the candle coloring, a secondary filter kicks in: an 8-period EMA is computed on the chart timeframe and candle color is sustained only if price remains above the EMA and the EMA is rising (for bull) or below the EMA and the EMA is falling (for bear). If two consecutive candles violate this filter, the candle coloring resets to inactive. This prevents the color from lingering through a clear reversal.
https://www.tradingview.com/x/6VrU8FO7/
https://www.tradingview.com/x/7qWmHeds/

The four candle color states are independently togglable. You can disable macro candle coloring but keep micro active, or vice versa. Opacity is adjustable from 0 (fully opaque) to 100 (invisible), which lets you layer ASQ's colored candles transparently over a custom candle scheme if you use one.

Candle coloring uses force overlay so it appears on the main chart even though ASQ lives in a sub-pane. No need to move the indicator to the price panel.

DASHBOARD — REAL-TIME STRUCTURAL READOUT
https://www.tradingview.com/x/N6JgqpUd/
https://www.tradingview.com/x/q7DJATLC/
https://www.tradingview.com/x/S69aJapn/
The dashboard is a 2-column, 11-row table drawn on the chart displaying:

Macro Trend — BULL / BEAR / NEUTRAL in color
Macro MA Alignment overview row (8v16, 16v30, 30v50)
MA 8 vs 16 — confirmed or not, with green/red background
MA 16 vs 30 — confirmed or not, with green/red background
MA 30 vs 50 — confirmed or not, with green/red background
Price vs Macro MA8 — ABOVE or BELOW
Macro RSI value — colored green if overbought, red if oversold
Micro RSI value — colored by same threshold logic
Stop Loss value – colored as the most recent pivot
Divergence — type of active divergence or None
Last Signal — BUY / SELL / None

Every row color-codes by state, so the dashboard functions as a quick structural checklist without requiring you to zoom into the oscillator on every bar. You can position it at any of nine screen locations and resize from tiny to huge. Background, border, and all text colors are fully customizable.

REPAINT PROTECTION

The "Wait for Macro Candle Close" setting enforces bar confirmation discipline across the entire system. When enabled, the macro timeframe data uses lookahead_off, meaning macro MA alignment and macro RSI values only update on confirmed macro candle closes — not during the formation of the current macro candle. Micro signals are additionally gated by barstate.isconfirmed on the chart timeframe.

The practical consequence: with this setting on, a signal that appears on the current bar is only plotted and alerted after that bar closes. No signal will appear mid-candle and then disappear. If you are automating via webhooks or using alerts for actual trade execution, enable this. For purely visual real-time monitoring, you may prefer it off for earlier awareness.

ALERTS — FULL GRANULAR COVERAGE

ASQ provides 14 independent alert conditions:

Micro Buy Signal 1 (full-cycle RSI reversal)
Micro Buy Signal 2 (shallow pullback re-entry)
Micro Buy Signal 3 (midline momentum confirmation)
Micro Sell Signal 1, 2, 3 (inverse of above)
Any Micro Buy (any of the three buy patterns)
Any Micro Sell (any of the three sell patterns)
Macro Buy (MA stack locks bullish)
Macro Sell (MA stack locks bearish)
Macro Trend Bullish (trend state turns bullish)
Macro Trend Bearish (trend state turns bearish)
Regular Bullish Divergence
Regular Bearish Divergence
Hidden Bullish Divergence
Hidden Bearish Divergence

Alert messages include ticker, interval, and price at time of trigger. You can wire the "Any Micro Buy" and "Any Micro Sell" alerts to a webhook for automation, while using the individual signal alerts for pattern-specific setups.

SIGNAL SHAPE CUSTOMIZATION

Every signal type (micro buy, micro sell, macro buy, macro sell, bull divergence, bear divergence) has its own independently selectable shape, color, and on/off toggle. Shapes available: Circle, Square, Triangle Up, Triangle Down, Diamond, Cross, Star. Signals are plotted on the RSI sub-pane at fixed Y positions by type (divergences at 0/100, macro signals at 5/95, micro signals at 10/90) to prevent overlap between signal layers.

RSI DISPLAY — ZONE FILLS AND PRICE LINE

The RSI sub-pane shows the oscillator with three reference lines: overbought (default 70, green), oversold (default 30, red), and the 50 midline (black). Each line has independent width and color settings. When RSI crosses into the overbought zone, the area between RSI and the 70 line fills with the bullish fill color. When RSI drops into the oversold zone, the area fills with the bearish fill color. The fill is removed as soon as RSI returns to the neutral zone.

The RSI line color itself changes dynamically: green in overbought territory, red in oversold, and the user-defined base color in between. The "Show RSI Price Line" option enables a horizontal tracking line on the right scale that follows the current RSI value — useful when you want to read the exact RSI level without hovering.

HOW TO USE IT — PRACTICAL WORKFLOW

The cleanest workflow is to first establish macro context from the dashboard, then look for micro entry signals.

Step 1 — Check Macro Trend. Dashboard shows BULL or BEAR. If NEUTRAL, the four-MA stack is not aligned and no macro or micro signals will fire. Respect this. A neutral reading means range or transition — scalping through it blindly is the fastest way to get chopped.

Step 2 — Confirm MA Stack. Check the three green/red cells for 8v16, 16v30, 30v50. If only two of three are green but the third is borderline, you can anticipate the macro signal is close. Full green (or full red) is required for signals to fire.

Step 3 — Watch for Macro Signal. When the square marker appears and candles shift to the deeper macro color, you have a structural alignment confirmation. This is a position-building zone, not a scalp trigger. Swing traders and investors can enter here with the pivot stop line as a stop reference.

Step 4 — Layer Micro Signals for Precision Entry. Once macro is confirmed, micro signals (circle markers by default) show precision oscillator-based re-entries within the trend. Signal 1 fires on full RSI cycle completions — highest conviction, least frequent. Signal 2 fires on shallow pullback continuations — good for trend-following scalps. Signal 3 fires at the 50 midline confirmation — earliest entry, slightly lower conviction but gives the best risk/reward if timed right within a strong trend.

Step 5 — Use Pivot Lines as Stop Reference. Each signal automatically draws a stop line at the most recent structural pivot. You do not need to manually find the nearest swing low or high — ASQ draws it for you at the moment the signal fires.

Step 6 — Divergence as Trend Exhaustion Warning. Even when macro trend is bullish and micro signals are firing long, if regular bearish divergence appears in the dashboard or on the RSI, reduce position size or tighten stops. Divergence does not override signals — it adds context. Hidden bullish divergence during a confirmed macro uptrend is a high-probability continuation setup and can be traded alongside micro signals.

WHAT MAKES IT DIFFERENT

Most RSI indicators either show RSI and a static overbought/oversold line, or they add a signal when RSI crosses 50. ASQ does neither in isolation. The three micro signal patterns are specifically engineered to capture different phases of an RSI behavioral cycle: the full reset, the shallow continuation, and the midline confirmation. Each is a distinct market behavior, and treating them as three separate concepts rather than one "RSI crossover" event is what drives their selectivity.

The volume weighting option makes the oscillator structurally different from any standard RSI derivative. Most volume-weighted RSI implementations simply multiply the RSI output by volume. ASQ weights the internal momentum calculation before smoothing — which means the smoothing itself reflects volume pressure, not just the final number.

The dual-timeframe architecture is native to the signal logic, not bolted on as a filter. The macro condition is a prerequisite, not a visual overlay you can choose to ignore. Either the macro agrees and signals fire, or they do not.

The candle coloring with EMA-based auto-reset is not cosmetic. It tells you when the signal state is being structurally sustained versus when it is starting to break down — and it resets automatically rather than requiring you to judge it manually.

MARKETS AND TIMEFRAMES
https://www.tradingview.com/x/rhwiewvc/
https://www.tradingview.com/x/Fii5rVjU/
https://www.tradingview.com/x/dboS9OKF/
https://www.tradingview.com/x/oKc5YDAF/
ASQ works on any market with volume data: crypto, forex, equities, futures, commodities, indices. Volume Weighted RSI is most powerful on assets with reliable volume data — crypto spot/perps, equity futures. On forex spot, standard RSI mode is recommended since tick volume is a proxy, not true market volume.

Recommended Timeframe Configurations by Trading Style:

Pure Scalping (1–5 min entries): Set macro TF to 15min. Chart on 1min or 3min. Use micro signals, Signals 2 and 3 are most active here. Expect higher signal frequency with tighter invalidation. Use pivot stops aggressively as hard stops, not just references.

Intraday Day Trading (5–15 min chart): Set macro TF to 1H or 4H. Macro signal gives you the session bias. Micro signals give you intraday entry points within that bias. This is the primary intended use case.

Swing Trading (1H–4H chart): Set macro TF to Daily. Macro signal identifies multi-day trend confirmation. Signal 1 on the 4H chart within a daily bullish macro alignment is a high-conviction swing entry. Divergences here carry more structural weight.

Position / Investing (Daily chart): Set macro TF to Weekly. Use macro signals and divergences only. The weekly MA stack alignment is a structural trend confirmation. Regular bearish divergence on the daily RSI within a weekly macro bull signal is a classic position-sizing warning.

The indicator is not limited to these configurations — they are starting points. The macro TF and all MA lengths are fully adjustable, so you can calibrate the system to any asset's specific volatility profile.

DISCLAIMER

Alpha Scalper Quantum is a technical analysis tool and is provided for educational and informational purposes only. No indicator guarantees profitable results. Past signal performance does not predict future outcomes. Trading financial instruments involves significant risk of capital loss. Always apply proper risk management and position sizing. This indicator does not constitute financial advice. Use it as one component of a broader decision-making process, not as a standalone signal system.

---

## Source Code

````pine
//@version=6
indicator("Alpha Scalper Quantum", shorttitle="Alpha Scalper Quantum", overlay=false, max_lines_count=500, max_labels_count=500)

// =====================================================================================
// SETTINGS
// =====================================================================================
groupRSI = "RSI Engine"
length = input.int(14, minval=2, title="RSI Length", group=groupRSI, tooltip="Lookback period for RSI calculation. Lower values react faster; higher values smooth noise.")
src = input.source(defval=close, title="Source", group=groupRSI, tooltip="Price source used in the RSI engine.")
useVW = input.bool(false, "Volume Weighted RSI", group=groupRSI, tooltip="When enabled, RSI movement is weighted by volume so high-volume candles have more influence.")
useHTF = input.bool(false, "Use Higher Timeframe RSI", group=groupRSI, tooltip="When enabled, the micro RSI signal engine uses RSI from the selected higher timeframe.")
htf = input.timeframe("60", "HTF Timeframe", group=groupRSI, tooltip="Higher timeframe used when 'Use Higher Timeframe RSI' is enabled.")

groupLevels = "Levels Settings"
ob = input.int(70, "Overbought Level (Green)", group=groupLevels, tooltip="Upper RSI threshold used for overbought-state tracking and trigger logic.")
os = input.int(30, "Oversold Level (Red)", group=groupLevels, tooltip="Lower RSI threshold used for oversold-state tracking and trigger logic.")
colRsi  = input.color(color.white, "RSI Line Color", group=groupLevels, tooltip="Base RSI line color when RSI is between overbought and oversold zones.")
colOb   = input.color(#00ff00, "70 Level Color", group=groupLevels, tooltip="Color for the overbought threshold line.")
colOs   = input.color(#ff0000, "30 Level Color", group=groupLevels, tooltip="Color for the oversold threshold line.")
colMid  = input.color(#000000, "50 Midline Color", group=groupLevels, tooltip="Color for the 50 midline.")
obWidth  = input.int(4, "70 Level Width", minval=1, group=groupLevels, tooltip="Line width of the overbought level.")
osWidth  = input.int(4, "30 Level Width", minval=1, group=groupLevels, tooltip="Line width of the oversold level.")
midWidth = input.int(4, "50 Midline Width", minval=1, group=groupLevels, tooltip="Line width of the 50 midline.")
colFillBull = input.color(#00ff00, "Bullish Fill Color", group=groupLevels, tooltip="Fill color used when RSI is above the overbought threshold.")
colFillBear = input.color(#ff0000, "Bearish Fill Color", group=groupLevels, tooltip="Fill color used when RSI is below the oversold threshold.")
showRsiPriceLine = input.bool(true, "Show RSI Price Line", group=groupLevels, tooltip="Shows a horizontal RSI price line on the right scale. It always inherits the active RSI plot color.")

groupMTF = "Multi-Timeframe Settings"
macroTF = input.timeframe("15", "Macro Timeframe (Trend Filter)", group=groupMTF, tooltip="Timeframe used for macro trend filters and macro signal conditions.")
waitConfirmation = input.bool(false, "Wait for Macro Candle Close (Non-Repaint)", group=groupMTF, tooltip="When enabled, plotted and alerted signals require confirmed bar close to reduce repaint risk.")

groupMacroMA = "Macro Moving Averages"
ma1Type = input.string("EMA", "MA1 Type (8)", group=groupMacroMA, options=["SMA", "EMA", "WMA", "VWMA", "HMA"], tooltip="Type of the first macro moving average.")
ma1Len = input.int(8, "MA1 Length", minval=1, group=groupMacroMA, tooltip="Length of the first macro moving average.")
ma2Type = input.string("EMA", "MA2 Type (16)", group=groupMacroMA, options=["SMA", "EMA", "WMA", "VWMA", "HMA"], tooltip="Type of the second macro moving average.")
ma2Len = input.int(16, "MA2 Length", minval=1, group=groupMacroMA, tooltip="Length of the second macro moving average.")
ma3Type = input.string("EMA", "MA3 Type (30)", group=groupMacroMA, options=["SMA", "EMA", "WMA", "VWMA", "HMA"], tooltip="Type of the third macro moving average.")
ma3Len = input.int(30, "MA3 Length", minval=1, group=groupMacroMA, tooltip="Length of the third macro moving average.")
ma4Type = input.string("EMA", "MA4 Type (50)", group=groupMacroMA, options=["SMA", "EMA", "WMA", "VWMA", "HMA"], tooltip="Type of the fourth macro moving average.")
ma4Len = input.int(50, "MA4 Length", minval=1, group=groupMacroMA, tooltip="Length of the fourth macro moving average.")

groupSignals = "Signal Style & Customization"
showMicroBuy    = input.bool(true, "Enable Micro Buy Signal", group=groupSignals, tooltip="Shows micro buy signal marker when any micro buy trigger is active.")
microBuyShape   = input.string("Circle", "Micro Buy Shape", options=["Circle", "Square", "Triangle Up", "Triangle Down", "Diamond", "Cross", "Star"], group=groupSignals, tooltip="Shape used for micro buy marker.")
microBuyColor   = input.color(#00ff00, "Micro Buy Color", group=groupSignals, tooltip="Color used for micro buy marker.")

showMicroSell   = input.bool(true, "Enable Micro Sell Signal", group=groupSignals, tooltip="Shows micro sell signal marker when any micro sell trigger is active.")
microSellShape  = input.string("Circle", "Micro Sell Shape", options=["Circle", "Square", "Triangle Up", "Triangle Down", "Diamond", "Cross", "Star"], group=groupSignals, tooltip="Shape used for micro sell marker.")
microSellColor  = input.color(#ff0000, "Micro Sell Color", group=groupSignals, tooltip="Color used for micro sell marker.")

showMacroBuy    = input.bool(true, "Enable Macro Buy Signal", group=groupSignals, tooltip="Shows macro buy marker when bullish macro alignment activates.")
macroBuyShape   = input.string("Square", "Macro Buy Shape", options=["Circle", "Square", "Triangle Up", "Triangle Down", "Diamond", "Cross", "Star"], group=groupSignals, tooltip="Shape used for macro buy marker.")
macroBuyColor   = input.color(#09b110, "Macro Buy Color", group=groupSignals, tooltip="Color used for macro buy marker.")

showMacroSell   = input.bool(true, "Enable Macro Sell Signal", group=groupSignals, tooltip="Shows macro sell marker when bearish macro alignment activates.")
macroSellShape  = input.string("Square", "Macro Sell Shape", options=["Circle", "Square", "Triangle Up", "Triangle Down", "Diamond", "Cross", "Star"], group=groupSignals, tooltip="Shape used for macro sell marker.")
macroSellColor  = input.color(#a51212, "Macro Sell Color", group=groupSignals, tooltip="Color used for macro sell marker.")

showDivBull     = input.bool(true, "Enable Bullish Divergence Shape", group=groupSignals, tooltip="Shows bullish divergence marker when regular or hidden bullish divergence is detected.")
divBullShape    = input.string("Triangle Up", "Bull Div Shape", options=["Circle", "Square", "Triangle Up", "Triangle Down", "Diamond", "Cross", "Star"], group=groupSignals, tooltip="Shape used for bullish divergence marker.")
divBullColor    = input.color(#00ff00, "Bull Div Color", group=groupSignals, tooltip="Color used for bullish divergence marker.")

showDivBear     = input.bool(true, "Enable Bearish Divergence Shape", group=groupSignals, tooltip="Shows bearish divergence marker when regular or hidden bearish divergence is detected.")
divBearShape    = input.string("Triangle Down", "Bear Div Shape", options=["Circle", "Square", "Triangle Up", "Triangle Down", "Diamond", "Cross", "Star"], group=groupSignals, tooltip="Shape used for bearish divergence marker.")
divBearColor    = input.color(#ff0000, "Bear Div Color", group=groupSignals, tooltip="Color used for bearish divergence marker.")

groupCandles = "Candle Coloring"
enableCandleColor = input.bool(true, "Enable Macro Candle Coloring", group=groupCandles, tooltip="When enabled, macro signal state can color candles on the main chart.")
bullCandleColor = input.color(#09b110, "Macro Bull Candle Color", group=groupCandles, tooltip="Candle color for macro bullish state.")
bearCandleColor = input.color(#a51212, "Macro Bear Candle Color", group=groupCandles, tooltip="Candle color for macro bearish state.")
enableMicroCandleColor = input.bool(true, "Enable Micro Candle Coloring", group=groupCandles, tooltip="When enabled, micro signal state can color candles on the main chart.")
microBullCandleColor = input.color(#00ff00, "Micro Bull Candle Color", group=groupCandles, tooltip="Candle color for micro bullish state.")
microBearCandleColor = input.color(#ff0000, "Micro Bear Candle Color", group=groupCandles, tooltip="Candle color for micro bearish state.")
candleOpacity = input.int(0, "Opacity", minval=0, maxval=100, group=groupCandles, tooltip="Transparency applied to overlay candles. 0 is opaque and 100 is fully transparent.")

groupPivot = "Pivot Stop Loss"
showPivotLines = input.bool(true, "Show Pivot Lines", group=groupPivot, tooltip="Draws horizontal pivot-based stop reference lines after signal events.")
pivotLeft = input.int(3, "Pivot Left Bars", minval=1, group=groupPivot, tooltip="Left bars used to confirm pivot points.")
pivotRight = input.int(1, "Pivot Right Bars", minval=1, group=groupPivot, tooltip="Right bars used to confirm pivot points.")
pivotLineLength = input.int(20, "Line Length (Bars)", minval=1, group=groupPivot, tooltip="Forward extension length for each pivot line.")
maxPivotLines = input.int(100, "Max Pivot Lines Kept", minval=10, maxval=200, group=groupPivot, tooltip="Maximum number of pivot lines kept on chart before oldest lines are removed.")

groupDiv = "Divergence Detection"
showDiv = input.bool(false, "Show Regular Divergences", group=groupDiv, tooltip="Plots regular bullish and bearish divergences.")
showHiddenDiv = input.bool(false, "Show Hidden Divergences", group=groupDiv, tooltip="Plots hidden bullish and bearish divergences.")
divPivotLen = input.int(2, "Pivot Lookback (Left/Right)", minval=1, group=groupDiv, tooltip="Pivot strength window used for divergence detection.")
divMinStrength = input.float(0.3, "Minimum Pivot Strength", minval=0, group=groupDiv, tooltip="Minimum RSI pivot displacement from midline required to qualify divergence.")
divMinDistance = input.int(10, "Minimum Pivot Distance (Bars)", minval=1, group=groupDiv, tooltip="Minimum bar distance between pivots to reduce clustered false detections.")
regBullDivLineCol = input.color(#00ff88, "Regular Bull Divergence Color", group=groupDiv, tooltip="Line color for regular bullish divergence.")
regBearDivLineCol = input.color(#ff0044, "Regular Bear Divergence Color", group=groupDiv, tooltip="Line color for regular bearish divergence.")
hidBullDivLineCol = input.color(#00cc44, "Hidden Bull Divergence Color", group=groupDiv, tooltip="Line color for hidden bullish divergence.")
hidBearDivLineCol = input.color(#cc0033, "Hidden Bear Divergence Color", group=groupDiv, tooltip="Line color for hidden bearish divergence.")

groupDash = "Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=groupDash, tooltip="Displays a compact dashboard with macro trend, MA alignment, RSI states, stop loss value, divergence state, and last signal.")
dashPosition = input.string("top_right", "Dashboard Position", group=groupDash, options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], tooltip="Screen position of the dashboard.")
dashSize = input.string("small", "Dashboard Size", group=groupDash, options=["tiny", "small", "normal", "large", "huge"], tooltip="Text size used in dashboard cells.")
dashBgColor = input.color(color.new(#000000, 0), "Dashboard Background Color", group=groupDash, tooltip="Background color of the dashboard.")
dashBorderColor = input.color(color.new(#808080, 0), "Dashboard Border Color", group=groupDash, tooltip="Border color of the dashboard.")
dashBorderWidth = input.int(1, "Dashboard Border Width", minval=0, maxval=5, group=groupDash, tooltip="Border width of the dashboard.")
dashTextColor = input.color(color.white, "Dashboard Text Color", group=groupDash, tooltip="Base text color in dashboard labels.")
dashBullColor = input.color(#00ff00, "Dashboard Bull Color", group=groupDash, tooltip="Text or state color for bullish dashboard values.")
dashBearColor = input.color(#ff0000, "Dashboard Bear Color", group=groupDash, tooltip="Text or state color for bearish dashboard values.")
dashNeutralColor = input.color(#808080, "Dashboard Neutral Color", group=groupDash, tooltip="Text color for neutral dashboard values.")

// =====================================================================================
// HELPER FUNCTIONS
// =====================================================================================
safeDiv(num, den, fallback) =>
    den == 0 or na(den) ? fallback : num / den

getMA(source, len, maType) =>
    switch maType
        "SMA" => ta.sma(source, len)
        "EMA" => ta.ema(source, len)
        "WMA" => ta.wma(source, len)
        "VWMA" => ta.vwma(source, len)
        "HMA" => ta.hma(source, len)
        => ta.ema(source, len)

getShapeChar(shapeStr) =>
    switch shapeStr
        "Circle"        => "●"
        "Square"        => "■"
        "Triangle Up"   => "▲"
        "Triangle Down" => "▼"
        "Diamond"       => "◆"
        "Cross"         => "✚"
        "Star"          => "★"
        => "●"

calcRsi(src_input, len, use_vol) =>
    upper = ta.highest(src_input, len)
    lower = ta.lowest(src_input, len)
    rng = upper - lower
    d = src_input - src_input[1]
    diff = upper > upper[1] ? rng : lower < lower[1] ? -rng : d
    vol_mult = use_vol ? volume : 1.0
    num = ta.rma(diff * vol_mult, len)
    den = ta.rma(math.abs(diff) * vol_mult, len)
    safeDiv(num, den, 0.0) * 50 + 50

arsiBase = calcRsi(src, length, useVW)
htfRsi   = request.security(syminfo.tickerid, htf, calcRsi(src, length, useVW), lookahead=barmerge.lookahead_off)
arsi     = useHTF ? htfRsi : arsiBase

barConfirmed = not waitConfirmation or barstate.isconfirmed

// =====================================================================================
// MACRO TIMEFRAME DATA & TREND CONDITIONS
// =====================================================================================
lookaheadMode = waitConfirmation ? barmerge.lookahead_off : barmerge.lookahead_on

macroClose = request.security(syminfo.tickerid, macroTF, close, lookahead=lookaheadMode)
macroRSI = request.security(syminfo.tickerid, macroTF, calcRsi(src, length, useVW), lookahead=lookaheadMode)

macroMA1 = request.security(syminfo.tickerid, macroTF, getMA(close, ma1Len, ma1Type), lookahead=lookaheadMode)
macroMA2 = request.security(syminfo.tickerid, macroTF, getMA(close, ma2Len, ma2Type), lookahead=lookaheadMode)
macroMA3 = request.security(syminfo.tickerid, macroTF, getMA(close, ma3Len, ma3Type), lookahead=lookaheadMode)
macroMA4 = request.security(syminfo.tickerid, macroTF, getMA(close, ma4Len, ma4Type), lookahead=lookaheadMode)

priceAboveMA = macroClose > macroMA1
priceBelowMA = macroClose < macroMA1

maAlignedBull = macroMA1 > macroMA2 and macroMA2 > macroMA3 and macroMA3 > macroMA4
maAlignedBear = macroMA1 < macroMA2 and macroMA2 < macroMA3 and macroMA3 < macroMA4

macroUptrend = priceAboveMA and maAlignedBull
macroDowntrend = priceBelowMA and maAlignedBear

macroSignalBull = maAlignedBull
macroSignalBear = maAlignedBear

// =====================================================================================
// MICRO RSI SIGNAL LOGIC
// =====================================================================================
var bool rsiWasBelow30 = false
var bool rsiWasAbove70 = false
var bool rsiShallowBull = false
var bool rsiShallowBear = false
var bool rsiMediumBull = false
var bool rsiMediumBear = false

rsiCrossOver70  = ta.crossover(arsi, ob)
rsiCrossUnder30 = ta.crossunder(arsi, os)
rsiCrossOver50  = ta.crossover(arsi, 50)
rsiCrossUnder50 = ta.crossunder(arsi, 50)

sig1Buy  = macroUptrend and rsiWasBelow30 and rsiCrossOver70
sig1Sell = macroDowntrend and rsiWasAbove70 and rsiCrossUnder30

sig2Buy  = macroUptrend and rsiShallowBull and rsiCrossOver70
sig2Sell = macroDowntrend and rsiShallowBear and rsiCrossUnder30

sig3Buy  = macroUptrend and rsiMediumBull and rsiCrossOver50
sig3Sell = macroDowntrend and rsiMediumBear and rsiCrossUnder50

if arsi <= os
    rsiWasBelow30 := true
    rsiWasAbove70 := false
    rsiShallowBull := false
    rsiMediumBull := false

if arsi >= ob
    rsiWasAbove70 := true
    rsiWasBelow30 := false
    rsiShallowBear := false
    rsiMediumBear := false

if ta.crossunder(arsi, ob)
    rsiShallowBull := true
if arsi <= 50 or arsi >= ob
    rsiShallowBull := false

if ta.crossover(arsi, os)
    rsiShallowBear := true
if arsi >= 50 or arsi <= os
    rsiShallowBear := false

if rsiWasAbove70 and ta.crossunder(arsi, 50)
    rsiMediumBull := true
if arsi <= os or arsi >= ob
    rsiMediumBull := false

if rsiWasBelow30 and ta.crossover(arsi, 50)
    rsiMediumBear := true
if arsi >= ob or arsi <= os
    rsiMediumBear := false

if sig1Buy or sig2Buy or sig3Buy
    rsiWasBelow30 := false
    rsiShallowBull := false
    rsiMediumBull := false

if sig1Sell or sig2Sell or sig3Sell
    rsiWasAbove70 := false
    rsiShallowBear := false
    rsiMediumBear := false

macBuy  = macroSignalBull and not macroSignalBull[1]
macSell = macroSignalBear and not macroSignalBear[1]

anyBuyMicro  = sig1Buy or sig2Buy or sig3Buy
anySellMicro = sig1Sell or sig2Sell or sig3Sell

sig1BuyConfirmed = sig1Buy and barConfirmed
sig1SellConfirmed = sig1Sell and barConfirmed
sig2BuyConfirmed = sig2Buy and barConfirmed
sig2SellConfirmed = sig2Sell and barConfirmed
sig3BuyConfirmed = sig3Buy and barConfirmed
sig3SellConfirmed = sig3Sell and barConfirmed

macBuyConfirmed = macBuy and barConfirmed
macSellConfirmed = macSell and barConfirmed
anyBuyMicroConfirmed = anyBuyMicro and barConfirmed
anySellMicroConfirmed = anySellMicro and barConfirmed

// =====================================================================================
// DIVERGENCE DETECTION (SUB-PANE)
// =====================================================================================
oscPivH = ta.pivothigh(arsi, divPivotLen, divPivotLen)
oscPivL = ta.pivotlow(arsi, divPivotLen, divPivotLen)
srcPivH = ta.pivothigh(src, divPivotLen, divPivotLen)
srcPivL = ta.pivotlow(src, divPivotLen, divPivotLen)

var float lastOscH1 = na
var float lastOscH2 = na
var float lastSrcH1 = na
var float lastSrcH2 = na
var int   lastTimeH1 = na
var int   lastTimeH2 = na
var int   lastBarH1 = na

var float lastOscL1 = na
var float lastOscL2 = na
var float lastSrcL1 = na
var float lastSrcL2 = na
var int   lastTimeL1 = na
var int   lastTimeL2 = na
var int   lastBarL1 = na

if not na(oscPivH) and not na(srcPivH) and math.abs(oscPivH - 50) >= divMinStrength
    barDistanceH = bar_index[divPivotLen] - lastBarH1
    if na(lastBarH1) or barDistanceH >= divMinDistance
        lastOscH2 := lastOscH1
        lastSrcH2 := lastSrcH1
        lastTimeH2 := lastTimeH1
        lastOscH1 := oscPivH
        lastSrcH1 := srcPivH
        lastTimeH1 := bar_index[divPivotLen]
        lastBarH1 := bar_index[divPivotLen]

if not na(oscPivL) and not na(srcPivL) and math.abs(oscPivL - 50) >= divMinStrength
    barDistanceL = bar_index[divPivotLen] - lastBarL1
    if na(lastBarL1) or barDistanceL >= divMinDistance
        lastOscL2 := lastOscL1
        lastSrcL2 := lastSrcL1
        lastTimeL2 := lastTimeL1
        lastOscL1 := oscPivL
        lastSrcL1 := srcPivL
        lastTimeL1 := bar_index[divPivotLen]
        lastBarL1 := bar_index[divPivotLen]

bool bearDiv = showDiv and not na(oscPivH) and not na(lastOscH2) and srcPivH > lastSrcH2 and oscPivH < lastOscH2 and math.abs(oscPivH - 50) >= divMinStrength
bool bullDiv = showDiv and not na(oscPivL) and not na(lastOscL2) and srcPivL < lastSrcL2 and oscPivL > lastOscL2 and math.abs(oscPivL - 50) >= divMinStrength

bool hiddenBullDiv = showHiddenDiv and not na(oscPivL) and not na(lastOscL2) and srcPivL > lastSrcL2 and oscPivL < lastOscL2 and macroUptrend and math.abs(oscPivL - 50) >= divMinStrength
bool hiddenBearDiv = showHiddenDiv and not na(oscPivH) and not na(lastOscH2) and srcPivH < lastSrcH2 and oscPivH > lastOscH2 and macroDowntrend and math.abs(oscPivH - 50) >= divMinStrength

if bearDiv
    line.new(lastTimeH2, lastOscH2, bar_index[divPivotLen], oscPivH, color=regBearDivLineCol, width=3, style=line.style_solid)

if bullDiv
    line.new(lastTimeL2, lastOscL2, bar_index[divPivotLen], oscPivL, color=regBullDivLineCol, width=3, style=line.style_solid)

if hiddenBullDiv
    line.new(lastTimeL2, lastOscL2, bar_index[divPivotLen], oscPivL, color=hidBullDivLineCol, width=3, style=line.style_dashed)

if hiddenBearDiv
    line.new(lastTimeH2, lastOscH2, bar_index[divPivotLen], oscPivH, color=hidBearDivLineCol, width=3, style=line.style_dashed)

var bool activeDivergence = false
var string divType = ""

if bearDiv or bullDiv or hiddenBullDiv or hiddenBearDiv
    activeDivergence := true
    divType := bearDiv ? "Bear Reg" : bullDiv ? "Bull Reg" : hiddenBullDiv ? "Hidden Bull" : "Hidden Bear"
else if barstate.isconfirmed
    activeDivergence := false

// =====================================================================================
// RSI PLOTTING (SUB-PANE)
// =====================================================================================
plot70 = plot(ob, title="70 Threshold Level", color=colOb, linewidth=obWidth)
plot30 = plot(os, title="30 Threshold Level", color=colOs, linewidth=osWidth)
plot50 = plot(50, title="50 Midline", color=colMid, linewidth=midWidth)

plot70Fill = plot(ob, title="70 Fill Anchor", color=color.new(colOb, 100), display=display.none)
plot30Fill = plot(os, title="30 Fill Anchor", color=color.new(colOs, 100), display=display.none)

rsiPlotColor = arsi > ob ? colFillBull : arsi < os ? colFillBear : colRsi
plotRsi = plot(arsi, title="RSI", color=rsiPlotColor, linewidth=1, trackprice=showRsiPriceLine, display=display.all)

fill(plotRsi, plot70Fill, color = arsi > ob ? color.new(colFillBull, 0) : na, title="Bullish Overbought Shadow")
fill(plotRsi, plot30Fill, color = arsi < os ? color.new(colFillBear, 0) : na, title="Bearish Oversold Shadow")

// =====================================================================================
// SIGNAL SHAPES (SUB-PANE)
// =====================================================================================
if (bullDiv or hiddenBullDiv) and showDivBull and barConfirmed
    label.new(bar_index, 0, getShapeChar(divBullShape), color=color.new(divBullColor, 0), textcolor=divBullColor, style=label.style_none, size=size.large, yloc=yloc.price)

if macBuyConfirmed and showMacroBuy
    label.new(bar_index, 5, getShapeChar(macroBuyShape), color=color.new(macroBuyColor, 0), textcolor=macroBuyColor, style=label.style_none, size=size.large, yloc=yloc.price)

if anyBuyMicroConfirmed and showMicroBuy
    label.new(bar_index, 10, getShapeChar(microBuyShape), color=color.new(microBuyColor, 0), textcolor=microBuyColor, style=label.style_none, size=size.large, yloc=yloc.price)

if (bearDiv or hiddenBearDiv) and showDivBear and barConfirmed
    label.new(bar_index, 100, getShapeChar(divBearShape), color=color.new(divBearColor, 0), textcolor=divBearColor, style=label.style_none, size=size.large, yloc=yloc.price)

if macSellConfirmed and showMacroSell
    label.new(bar_index, 95, getShapeChar(macroSellShape), color=color.new(macroSellColor, 0), textcolor=macroSellColor, style=label.style_none, size=size.large, yloc=yloc.price)

if anySellMicroConfirmed and showMicroSell
    label.new(bar_index, 90, getShapeChar(microSellShape), color=color.new(microSellColor, 0), textcolor=microSellColor, style=label.style_none, size=size.large, yloc=yloc.price)

// =====================================================================================
// PIVOT STOP LOSS (MAIN CHART OVERLAY)
// =====================================================================================
pLow  = ta.pivotlow(low, pivotLeft, pivotRight)
pHigh = ta.pivothigh(high, pivotLeft, pivotRight)

var float lastPivotLow    = na
var float lastPivotHigh   = na
var int   lastPivotLowBar  = na
var int   lastPivotHighBar = na
var line[] pivotLines = array.new<line>()

if not na(pLow)
    lastPivotLow := pLow
    lastPivotLowBar := bar_index - pivotRight

if not na(pHigh)
    lastPivotHigh := pHigh
    lastPivotHighBar := bar_index - pivotRight

var float lastActiveStop = na
var color lastActiveStopColor = na

if anyBuyMicroConfirmed and not na(lastPivotLow)
    lastActiveStop := lastPivotLow
    lastActiveStopColor := microBuyColor

if anySellMicroConfirmed and not na(lastPivotHigh)
    lastActiveStop := lastPivotHigh
    lastActiveStopColor := microSellColor

if macBuyConfirmed and not na(lastPivotLow)
    lastActiveStop := lastPivotLow
    lastActiveStopColor := macroBuyColor

if macSellConfirmed and not na(lastPivotHigh)
    lastActiveStop := lastPivotHigh
    lastActiveStopColor := macroSellColor

addPivotLine(int x1, float y1, color col) =>
    ln = line.new(x1, y1, x1 + pivotLineLength, y1, color=col, width=3, force_overlay=true)
    array.push(pivotLines, ln)
    if array.size(pivotLines) > maxPivotLines
        line.delete(array.shift(pivotLines))

if showPivotLines and barConfirmed
    if anyBuyMicroConfirmed and not na(lastPivotLow) and not na(lastPivotLowBar)
        addPivotLine(lastPivotLowBar, lastPivotLow, microBuyColor)

    if anySellMicroConfirmed and not na(lastPivotHigh) and not na(lastPivotHighBar)
        addPivotLine(lastPivotHighBar, lastPivotHigh, microSellColor)

    if macBuyConfirmed and not na(lastPivotLow) and not na(lastPivotLowBar)
        addPivotLine(lastPivotLowBar, lastPivotLow, macroBuyColor)

    if macSellConfirmed and not na(lastPivotHigh) and not na(lastPivotHighBar)
        addPivotLine(lastPivotHighBar, lastPivotHigh, macroSellColor)

// =====================================================================================
// CANDLE COLORING (MAIN CHART OVERLAY)
// =====================================================================================
var int activeCandleSignal = 0
var int signalFailCount = 0

if macBuyConfirmed
    activeCandleSignal := 3
    signalFailCount := 0
else if anyBuyMicroConfirmed
    activeCandleSignal := 1
    signalFailCount := 0

if macSellConfirmed
    activeCandleSignal := 4
    signalFailCount := 0
else if anySellMicroConfirmed
    activeCandleSignal := 2
    signalFailCount := 0

if not macroUptrend and not macroDowntrend
    activeCandleSignal := 0

colorFilterEma = ta.ema(close, 8)
bullColorFilter = close > colorFilterEma and colorFilterEma > colorFilterEma[1]
bearColorFilter = close < colorFilterEma and colorFilterEma < colorFilterEma[1]

if activeCandleSignal == 1 or activeCandleSignal == 3
    if not bullColorFilter
        signalFailCount += 1
    else
        signalFailCount := 0
else if activeCandleSignal == 2 or activeCandleSignal == 4
    if not bearColorFilter
        signalFailCount += 1
    else
        signalFailCount := 0
else
    signalFailCount := 0

if signalFailCount >= 2
    activeCandleSignal := 0

microBullColorValue = color.new(microBullCandleColor, candleOpacity)
microBearColorValue = color.new(microBearCandleColor, candleOpacity)
macroBullColorValue = color.new(bullCandleColor, candleOpacity)
macroBearColorValue = color.new(bearCandleColor, candleOpacity)

overlayDisplayNoScale = display.all - display.price_scale

plotcandle(activeCandleSignal == 1 and enableMicroCandleColor ? open : na, activeCandleSignal == 1 and enableMicroCandleColor ? high : na, activeCandleSignal == 1 and enableMicroCandleColor ? low : na, activeCandleSignal == 1 and enableMicroCandleColor ? close : na, color=microBullColorValue, wickcolor=microBullColorValue, bordercolor=microBullColorValue, title="Micro Bull Signal Candles", force_overlay=true, display=overlayDisplayNoScale)
plotcandle(activeCandleSignal == 2 and enableMicroCandleColor ? open : na, activeCandleSignal == 2 and enableMicroCandleColor ? high : na, activeCandleSignal == 2 and enableMicroCandleColor ? low : na, activeCandleSignal == 2 and enableMicroCandleColor ? close : na, color=microBearColorValue, wickcolor=microBearColorValue, bordercolor=microBearColorValue, title="Micro Bear Signal Candles", force_overlay=true, display=overlayDisplayNoScale)
plotcandle(activeCandleSignal == 3 and enableCandleColor ? open : na, activeCandleSignal == 3 and enableCandleColor ? high : na, activeCandleSignal == 3 and enableCandleColor ? low : na, activeCandleSignal == 3 and enableCandleColor ? close : na, color=macroBullColorValue, wickcolor=macroBullColorValue, bordercolor=macroBullColorValue, title="Macro Bull Signal Candles", force_overlay=true, display=overlayDisplayNoScale)
plotcandle(activeCandleSignal == 4 and enableCandleColor ? open : na, activeCandleSignal == 4 and enableCandleColor ? high : na, activeCandleSignal == 4 and enableCandleColor ? low : na, activeCandleSignal == 4 and enableCandleColor ? close : na, color=macroBearColorValue, wickcolor=macroBearColorValue, bordercolor=macroBearColorValue, title="Macro Bear Signal Candles", force_overlay=true, display=overlayDisplayNoScale)

// =====================================================================================
// ALERTS
// =====================================================================================
macroTrendBullConfirmed = macroUptrend and not macroUptrend[1] and barConfirmed
macroTrendBearConfirmed = macroDowntrend and not macroDowntrend[1] and barConfirmed

bullDivConfirmed = bullDiv and barConfirmed
bearDivConfirmed = bearDiv and barConfirmed
hiddenBullDivConfirmed = hiddenBullDiv and barConfirmed
hiddenBearDivConfirmed = hiddenBearDiv and barConfirmed

alertcondition(sig1BuyConfirmed, title="ASQ Micro Buy Signal 1", message="ASQ: Micro Buy Signal 1 confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(sig2BuyConfirmed, title="ASQ Micro Buy Signal 2", message="ASQ: Micro Buy Signal 2 confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(sig3BuyConfirmed, title="ASQ Micro Buy Signal 3", message="ASQ: Micro Buy Signal 3 confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(sig1SellConfirmed, title="ASQ Micro Sell Signal 1", message="ASQ: Micro Sell Signal 1 confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(sig2SellConfirmed, title="ASQ Micro Sell Signal 2", message="ASQ: Micro Sell Signal 2 confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(sig3SellConfirmed, title="ASQ Micro Sell Signal 3", message="ASQ: Micro Sell Signal 3 confirmed on {{ticker}} {{interval}} at {{close}}")

alertcondition(anyBuyMicroConfirmed, title="ASQ Any Micro Buy", message="ASQ: Any micro buy trigger confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(anySellMicroConfirmed, title="ASQ Any Micro Sell", message="ASQ: Any micro sell trigger confirmed on {{ticker}} {{interval}} at {{close}}")

alertcondition(macBuyConfirmed, title="ASQ Macro Buy", message="ASQ: Macro buy alignment confirmed on {{ticker}} {{interval}} at {{close}}")
alertcondition(macSellConfirmed, title="ASQ Macro Sell", message="ASQ: Macro sell alignment confirmed on {{ticker}} {{interval}} at {{close}}")

alertcondition(macroTrendBullConfirmed, title="ASQ Macro Trend Bullish", message="ASQ: Macro trend turned bullish on {{ticker}} {{interval}}")
alertcondition(macroTrendBearConfirmed, title="ASQ Macro Trend Bearish", message="ASQ: Macro trend turned bearish on {{ticker}} {{interval}}")

alertcondition(bullDivConfirmed, title="ASQ Regular Bullish Divergence", message="ASQ: Regular bullish divergence detected on {{ticker}} {{interval}}")
alertcondition(bearDivConfirmed, title="ASQ Regular Bearish Divergence", message="ASQ: Regular bearish divergence detected on {{ticker}} {{interval}}")
alertcondition(hiddenBullDivConfirmed, title="ASQ Hidden Bullish Divergence", message="ASQ: Hidden bullish divergence detected on {{ticker}} {{interval}}")
alertcondition(hiddenBearDivConfirmed, title="ASQ Hidden Bearish Divergence", message="ASQ: Hidden bearish divergence detected on {{ticker}} {{interval}}")

// =====================================================================================
// DASHBOARD
// =====================================================================================
if showDashboard and barstate.islast
    var table dashboard = table.new(position = dashPosition == "top_left" ? position.top_left : dashPosition == "top_center" ? position.top_center : dashPosition == "top_right" ? position.top_right : dashPosition == "middle_left" ? position.middle_left : dashPosition == "middle_center" ? position.middle_center : dashPosition == "middle_right" ? position.middle_right : dashPosition == "bottom_left" ? position.bottom_left : dashPosition == "bottom_center" ? position.bottom_center : position.bottom_right, columns = 2, rows = 11, bgcolor = dashBgColor, border_color = dashBorderColor, border_width = dashBorderWidth)

    tableSize = dashSize == "tiny" ? size.tiny : dashSize == "small" ? size.small : dashSize == "normal" ? size.normal : dashSize == "large" ? size.large : size.huge

    table.cell(dashboard, 0, 0, "Macro Trend", text_color=dashTextColor, text_size=tableSize)
    macroTrendColor = macroUptrend ? dashBullColor : macroDowntrend ? dashBearColor : dashNeutralColor
    macroTrendText = macroUptrend ? "BULL" : macroDowntrend ? "BEAR" : "NEUTRAL"
    table.cell(dashboard, 1, 0, macroTrendText, text_color=macroTrendColor, text_size=tableSize)

    table.cell(dashboard, 0, 1, "Macro MA Alignment", text_color=dashTextColor, text_size=tableSize)
    ma1vs2 = macroMA1 > macroMA2
    ma2vs3 = macroMA2 > macroMA3
    ma3vs4 = macroMA3 > macroMA4

    ma1Color = ma1vs2 ? dashBullColor : dashBearColor
    ma2Color = ma2vs3 ? dashBullColor : dashBearColor
    ma3Color = ma3vs4 ? dashBullColor : dashBearColor

    table.cell(dashboard, 1, 1, "8v16 | 16v30 | 30v50", text_color=dashTextColor, text_size=tableSize)
    table.cell(dashboard, 0, 2, "Macro MA 8 vs 16", text_color=dashTextColor, text_size=tableSize)
    table.cell(dashboard, 1, 2, ma1vs2 ? "✓" : "✗", bgcolor=ma1Color, text_color=color.black, text_size=tableSize)

    table.cell(dashboard, 0, 3, "Macro MA 16 vs 30", text_color=dashTextColor, text_size=tableSize)
    table.cell(dashboard, 1, 3, ma2vs3 ? "✓" : "✗", bgcolor=ma2Color, text_color=color.black, text_size=tableSize)

    table.cell(dashboard, 0, 4, "Macro MA 30 vs 50", text_color=dashTextColor, text_size=tableSize)
    table.cell(dashboard, 1, 4, ma3vs4 ? "✓" : "✗", bgcolor=ma3Color, text_color=color.black, text_size=tableSize)

    table.cell(dashboard, 0, 5, "Price vs Macro MA" + str.tostring(ma1Len), text_color=dashTextColor, text_size=tableSize)
    priceVsMA = priceAboveMA ? "ABOVE" : "BELOW"
    priceVsMAColor = priceAboveMA ? dashBullColor : dashBearColor
    table.cell(dashboard, 1, 5, priceVsMA, text_color=priceVsMAColor, text_size=tableSize)

    table.cell(dashboard, 0, 6, "Macro RSI", text_color=dashTextColor, text_size=tableSize)
    macroRsiTextColor = macroRSI > ob ? dashBullColor : macroRSI < os ? dashBearColor : dashTextColor
    table.cell(dashboard, 1, 6, str.tostring(math.round(macroRSI, 1)), text_color=macroRsiTextColor, text_size=tableSize)

    table.cell(dashboard, 0, 7, "Micro RSI", text_color=dashTextColor, text_size=tableSize)
    microRsiTextColor = arsi > ob ? dashBullColor : arsi < os ? dashBearColor : dashTextColor
    table.cell(dashboard, 1, 7, str.tostring(math.round(arsi, 1)), text_color=microRsiTextColor, text_size=tableSize)

    table.cell(dashboard, 0, 8, "Stop Loss", text_color=dashTextColor, text_size=tableSize)
    stopTxt = na(lastActiveStop) ? "None" : str.tostring(lastActiveStop, format.mintick)
    stopClr = na(lastActiveStop) ? dashNeutralColor : lastActiveStopColor
    table.cell(dashboard, 1, 8, stopTxt, text_color=stopClr, text_size=tableSize)

    table.cell(dashboard, 0, 9, "Divergence", text_color=dashTextColor, text_size=tableSize)
    divText = activeDivergence ? divType : "None"
    divColor = activeDivergence ? (str.contains(divType, "Bull") ? dashBullColor : dashBearColor) : dashNeutralColor
    table.cell(dashboard, 1, 9, divText, text_color=divColor, text_size=tableSize)

    anyBuySignal = anyBuyMicroConfirmed or macBuyConfirmed
    anySellSignal = anySellMicroConfirmed or macSellConfirmed
    table.cell(dashboard, 0, 10, "Last Signal", text_color=dashTextColor, text_size=tableSize)
    lastSig = anyBuySignal ? "BUY" : anySellSignal ? "SELL" : "None"
    lastSigColor = anyBuySignal ? dashBullColor : anySellSignal ? dashBearColor : dashNeutralColor
    table.cell(dashboard, 1, 10, lastSig, text_color=lastSigColor, text_size=tableSize)
````
