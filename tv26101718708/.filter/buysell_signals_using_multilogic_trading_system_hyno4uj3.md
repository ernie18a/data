# Buy-Sell Signals using Multi-Logic Trading System

- url: https://www.tradingview.com/script/hYNO4UJ3-Buy-Sell-Signals-using-Multi-Logic-Trading-System/
- type: indicator
- pine_id: PUB;742a247955014136be6001d9bce3c055
- version: 1.0

## Description

📈 Advanced Multi-Logic Trading System with Trend, Momentum, Breakout and Risk Management

The **Buy-Sell Signals using Multi-Logic Trend, Momentum & Breakout System** is a multi-condition trading indicator designed to help traders identify structured trading opportunities across different market environments.

Unlike a conventional indicator that depends on only one moving-average crossover or oscillator, Buy-sell with Multi-logic Trading Sytem combines:

✅ Market structure and EMA alignment
✅ Higher-timeframe trend confirmation
✅ Session VWAP positioning
✅ RSI and MACD momentum
✅ Bollinger Band positioning and volatility
✅ Volume expansion and OBV direction
✅ Range-breakout confirmation
✅ Sideways-market mean reversion
✅ Dynamic stop-loss and target calculations
✅ Signal management and cooldown controls

The objective is not to produce the maximum number of signals.

The objective is to filter market noise and highlight situations where multiple independent conditions support the same directional view.

━━━━━━━━━━━━━━━━━━━━

🧠 How the Indicator Reads the Market[/b]

Buy-sell with Multi-logic Trading Sytem continuously classifies the chart into one of four market conditions:

📈 BULLISH TREND

https://www.tradingview.com/x/oe4a5LET/

A bullish trend is identified when:

**Price > Fast EMA > Medium EMA > Slow EMA**

With the default settings, this represents:

**Price > EMA 20 > EMA 50 > EMA 200**

This structure indicates that short-term, medium-term and long-term price positioning is aligned in the bullish direction.

------------------------------------------------

📈 BEARISH TREND

https://www.tradingview.com/x/Pv2xzBWy/

A bearish trend is identified when:

**Price < Fast EMA < Medium EMA < Slow EMA**

With the default settings:

**Price < EMA 20 < EMA 50 < EMA 200**

This indicates complete bearish alignment across the three trend layers.

------------------------------------------------

📈 RANGE / SIDEWAYS

https://www.tradingview.com/x/rtZdXDHF/

The system studies the previous trading range over the selected Range Lookback.

The current candle is excluded from this range calculation. This allows the indicator to identify a genuine close outside the previous range instead of comparing the breakout candle against a range that already includes it.

A market is treated as sideways when:

• The previous range width remains within the selected percentage threshold
• Complete bullish EMA alignment is absent
• Complete bearish EMA alignment is absent

------------------------------------------------

📈 Transition

The Transition condition appears when the market is neither properly trending nor qualifying as a defined range.

This commonly happens when:

• EMAs are crossing or compressing
• Price repeatedly moves around the EMA ribbon
• The previous trend is weakening
• A new trend has not yet become established
• Price is moving between range and trend conditions

Transition is usually the least reliable environment for mechanical signals.

━━━━━━━━━━━━━━━━━━━━

 ⚙️ The Four Entry Logic Engines

https://www.tradingview.com/x/e4Xrh6te/

Buy-sell with Multi-logic Trading System contains four separate entry engines.

Each engine is designed for a different type of market behaviour.

📈 1. Trend-Following Logic

Trend-following logic is designed to participate in an already established directional move.

A bullish trend setup requires:

• Bullish EMA alignment
• Minimum bullish confluence score
• Higher-timeframe bullish permission
• Price above session VWAP

A bearish trend setup requires the opposite conditions.

🔷 Bullish confluence score

The bullish score contains six independent components:

1. Bullish EMA trend alignment
2. RSI positioned between 45 and 72
3. MACD above its signal line with a positive histogram
4. Price above the Bollinger Band basis
5. High volume with bullish OBV behaviour
6. A bullish candle closing above the previous structural swing high

🔷 Bearish confluence score

The bearish score also contains six components:

1. Bearish EMA trend alignment
2. RSI positioned between 28 and 55
3. MACD below its signal line with a negative histogram
4. Price below the Bollinger Band basis
5. High volume with bearish OBV behaviour
6. A bearish candle closing below the previous structural swing low

The **Minimum Trend Confluence** setting determines how many of these six conditions must agree.

🔷 When to use Trend-Following Logic

👉Use it when:

• The EMA ribbon is properly expanded
• Price is making higher highs and higher lows in an uptrend
• Price is making lower highs and lower lows in a downtrend
• Pullbacks are respecting the fast or medium EMA
• Price is consistently holding on the correct side of VWAP
• The higher-timeframe trend supports the trade direction

👉 When to avoid it

Avoid relying on trend logic when:

• EMAs are flat or repeatedly crossing
• Price is trapped inside a narrow range
• The market-condition card shows Transition
• A signal appears directly below major resistance
• A signal appears directly above major support
• Price has already completed a large impulsive move without a pullback

━━━━━━━━━━━━━━━━━━━━

📈 2. Momentum Logic

Momentum logic is designed to detect acceleration before complete trend confluence becomes necessary.

🔷For bullish momentum, the indicator looks for:

• Price above the fast EMA
• RSI above 52
• Positive MACD histogram
• MACD histogram increasing from the previous candle
• Bullish OBV positioning
• Volume confirmation when usable volume is available
• Bullish higher-timeframe permission
• Price above VWAP

🔷Bearish momentum uses the opposite conditions.

Momentum logic can respond earlier than full trend logic because it does not require the complete EMA 20–50–200 alignment or the minimum six-part trend score.

👉 When to use Momentum Logic

Momentum logic is most useful when:

• Price is emerging from consolidation
• A fresh intraday directional move is developing
• Volume is expanding with price
• MACD momentum is accelerating
• Price has reclaimed or rejected VWAP decisively
• A pullback is followed by renewed directional strength
• The higher timeframe already supports the intended direction

👉 When to avoid it

Avoid momentum entries when:

• The momentum candle is unusually extended
• Price is entering a major higher-timeframe supply or demand zone
• Volume expansion is caused by a news spike
• MACD is positive but price structure remains weak
• Price repeatedly crosses VWAP
• The chart has unreliable or unavailable volume data

Momentum logic is especially dependent on meaningful volume and OBV behaviour. It is therefore generally better suited to liquid stocks, indices, futures and other actively traded instruments.

━━━━━━━━━━━━━━━━━━━━

📈 3. Range-Breakout Logic

The breakout engine is designed to identify confirmed movement outside a previously established range.

It does not trigger merely because price trades a few ticks outside the range.

A bullish breakout requires:

• The previous market qualified as a range
• Price closes above the previous range high
• The close exceeds the range by the selected ATR buffer
• The previous candle had not already closed above the range
• The breakout candle closes strongly toward its high
• RSI is above 50
• MACD is bullish
• Volume confirms the move when available and required
• Price is above VWAP

The bearish breakout logic uses the opposite conditions.

🔷 Breakout Confirmation Buffer

The ATR buffer prevents the system from treating a marginal move above or below the boundary as a valid breakout.

A value of **0.15 ATR** means price must close beyond the range boundary by an additional 15% of the current ATR.

Increasing this value creates fewer but more selective breakout signals.

🔷 Breakout Candle Close Position

The candle must also close strongly in the breakout direction.

With a value of **0.60**:

• A bullish breakout candle must close in the upper 40% of its total range
• A bearish breakout candle must close in the lower 40% of its total range

This helps reject candles that break a level intrabar but leave a large rejection wick.

🔷 Important HTF behaviour

The higher-timeframe EMA filter directly controls the Trend and Momentum engines.

The Range-Breakout engine instead uses its own range, ATR, candle-strength, RSI, MACD, volume and VWAP confirmation.

Therefore, traders should still manually inspect the higher-timeframe structure before accepting a breakout signal.

👉 When to use Breakout Logic

Use breakout logic when:

• Price has formed a clean and visible range
• Range boundaries have been tested multiple times
• Bollinger Band width has contracted before expansion
• Volume increases during the breakout
• The breakout candle closes outside the level
• There is sufficient room before the next major structure
• VWAP supports the breakout direction

👉 When to avoid it

Avoid breakout entries when:

• The range is poorly defined
• Price is breaking directly into higher-timeframe resistance or support
• The breakout candle leaves a large rejection wick
• Volume is weak or declining
• Price has already moved far beyond the range before entry
• The breakout occurs during an irregular news candle
• The range threshold is set too loosely and ordinary price movement is being classified as consolidation

━━━━━━━━━━━━━━━━━━━━

📈 4. Sideways Mean-Reversion Logic

Mean reversion is disabled by default because it represents a different trading philosophy from trend-following.

Instead of expecting price to continue moving away from fair value, this engine looks for rejection near the outer areas of a sideways range.

The range is divided into zones:

• Lower reversion area near the bottom 20% of the range
• Upper reversion area near the top 20% of the range

A bullish mean-reversion setup requires:

• Mean-reversion logic enabled
• Market classified as sideways
• Range sufficiently wide relative to ATR
• Price testing the lower reversion zone
• Price closing back above that zone
• A bullish rejection candle
• A sufficiently large lower wick
• RSI below 38
• RSI turning upward when the RSI-turn filter is enabled
• Volume permission

A bearish mean-reversion setup requires the opposite conditions near the upper range zone, with RSI above 62 and turning downward.

🔷 Important Mean-Reversion Behaviour

Mean-reversion trades are intentionally based on sideways-market rejection.

They do not use the higher-timeframe trend or VWAP filter in the same way as the Trend and Momentum engines.

This is logical because a range-fading trade may temporarily move against the prevailing higher-timeframe direction.

However, it also means mean-reversion mode should be activated only when the trader has independently confirmed that the market is genuinely balanced and range-bound.

👉 When to use Mean Reversion

Use it when:

• The market has clear horizontal boundaries
• EMA alignment is absent
• Price repeatedly rejects both sides of the range
• The range is wide enough to offer practical reward
• RSI reaches an extreme and begins turning
• The rejection candle closes back inside the range
• No major breakout catalyst is expected

👉 When not to use it

Disable mean reversion when:

• The market is strongly trending
• The EMA ribbon is expanding
• Price is forming one-sided momentum candles
• Volume is increasing near the range boundary
• A breakout is supported by broader-market direction
• Price is repeatedly pressing one boundary without meaningful rejection

Repeated testing of one range boundary can represent pressure accumulation rather than a reversal opportunity.

━━━━━━━━━━━━━━━━━━━━

🔍 Higher-Timeframe Trend Filter

The higher-timeframe filter compares price with an EMA calculated on the selected higher timeframe.

👉When enabled:

• Long Trend and Momentum setups require bullish HTF positioning
• Short Trend and Momentum setups require bearish HTF positioning

The higher-timeframe calculation is designed to use confirmed information rather than future-looking data.

🔷 Suggested timeframe combinations

https://www.tradingview.com/x/WYgj1IL8/

These are practical starting points and should be tested for each instrument:

• 3-minute chart → 15-minute or 30-minute HTF
• 5-minute chart → 30-minute or 60-minute HTF
• 15-minute chart → 60-minute or 4-hour HTF
• 30-minute chart → 4-hour HTF
• 1-hour chart → 4-hour or Daily HTF
• 4-hour chart → Daily or Weekly HTF

A closer HTF produces more opportunities.

A larger HTF produces fewer but more structurally selective opportunities.

━━━━━━━━━━━━━━━━━━━━

📍 Session VWAP Filter

https://www.tradingview.com/x/AmcKz7IV/

VWAP acts as the indicator’s intraday fair-value reference.

👉When enabled:

• Long Trend, Momentum and Breakout setups require price above VWAP
• Short Trend, Momentum and Breakout setups require price below VWAP

This reduces situations where a bullish technical setup appears below intraday fair value or a bearish setup appears above it.

👉Keep VWAP enabled when:

• Trading intraday
• Trading indices or liquid stocks
• Trading momentum continuation
• Trading opening-range or consolidation breakouts
• Filtering counter-directional entries

👉 Consider disabling VWAP when:

• Trading higher timeframes where session VWAP has less relevance
• Trading instruments with irregular sessions
• Testing a pure swing-trading model
• Using another manually defined fair-value framework

Disabling VWAP increases flexibility but may also increase counter-directional signals.

━━━━━━━━━━━━━━━━━━━━

 📊 Volume and OBV Confirmation

The indicator compares current volume with its moving average.

With the default multiplier of **1.5**, high volume means the current volume is at least 1.5 times the selected average volume.

OBV is then compared with its own moving average to determine whether cumulative volume behaviour supports buyers or sellers.

The system is designed so that missing volume does not automatically block every setup.

However, symbols with reliable exchange volume are preferred, particularly when using Momentum Logic.

🔷 Volume Multiplier Interpretation

• 1.20–1.40: More responsive, but more noise
• 1.50: Balanced default
• 1.70–2.00: Strong expansion required
• Above 2.00: Very selective and mainly suited to exceptional participation

━━━━━━━━━━━━━━━━━━━━

 🛡️ Stop-Loss and Target Engine

https://www.tradingview.com/x/qRwyS9KS/

Every confirmed signal creates an active entry, stop-loss and target.

The indicator provides three stop-loss methods.

🔷 Structure + ATR

👉For a long trade:

The stop is placed below the previous structural swing low with an additional ATR buffer.

👉For a short trade:

The stop is placed above the previous structural swing high with an ATR buffer.

This is generally the preferred method for price-action and structure-based trading.

🔷ATR Stop

The stop is calculated using a fixed ATR multiple from the entry.

This method adapts to current volatility without depending on the location of a previous swing.

It can be useful for:

• Momentum setups
• Instruments with irregular swing structures
• Fast-moving markets
• Systematic risk standardisation

🔷 Fixed Percentage Stop

The stop is placed at a fixed percentage from entry.

This is simple but does not adjust to changing volatility.

It should be used carefully because the same percentage may be too tight in a volatile market and unnecessarily wide in a quiet market.

━━━━━━━━━━━━━━━━━━━━

📈 Target Methods

🔷Risk-to-Reward Target

The target is calculated from the actual distance between entry and stop.

With a 1.5 risk-to-reward ratio, the target is 1.5 times the defined trade risk.

🔷 ATR Target

The target is positioned at a selected ATR multiple from entry.

This can be useful for momentum trades where price expansion is expected.

🔷 Fixed Percentage Target

The target is placed at a fixed percentage from entry.

This is straightforward but less adaptive than ATR or structure-based calculations.

━━━━━━━━━━━━━━━━━━━━

🎯 Preferred Risk Settings

🔷 Structure-Based Intraday Trading

• Stop Method: Structure + ATR
• Structure ATR Buffer: 0.15–0.25
• Target Method: Risk:Reward
• Risk:Reward: 1.5–2.0

🔷 Momentum Trading

• Stop Method: ATR
• Stop ATR Multiplier: 1.2–1.8
• Target Method: ATR or Risk:Reward
• Target ATR Multiplier: 2.0–3.0

🔷 Swing Trading

• Stop Method: Structure + ATR
• Swing Lookback: 10–20
• Structure ATR Buffer: 0.20–0.40
• Target Method: Risk:Reward
• Risk:Reward: 1.5–2.5

🔷 Mean-Reversion Trading

• Stop Method: Structure + ATR or ATR
• Use a stop beyond the rejected range boundary
• Avoid excessively wide targets
• Consider the opposite side or midpoint of the range as practical structure

These values are starting points, not universal settings. Different instruments have different volatility and structural characteristics.

━━━━━━━━━━━━━━━━━━━━

🚦 Signal-Control System

Buy-sell with Multi-logic Trading System includes several controls to prevent repeated or conflicting signals.

👉 Minimum Bars Between Signals

The cooldown prevents the indicator from producing another signal immediately after the previous one.

Default: **5 bars**

Lower values create more frequent signals.

Higher values reduce repeated entries during the same move.

👉 Fresh Setup Only

When enabled, a signal appears only when the complete setup changes from false to true.

It prevents the indicator from repeatedly signalling on every candle while the same condition remains active.

This should normally remain enabled.

👉 Wait for SL or Target Before Next Signal

When enabled, the indicator waits for the active stop or target to be touched before accepting another trade.

This creates a cleaner one-trade-at-a-time workflow.

It is the preferred setting for discretionary traders and alert-based execution.

👉 Allow Opposite Signal

This setting becomes relevant when “Wait for SL/Target” is disabled.

It determines whether an opposite signal can replace the current directional trade before the original levels are completed.

━━━━━━━━━━━━━━━━━━━━

✨ Visual Features

3D Gradient Trend Ribbon
Glow Buy and Sell Markers
Signals are generated after the chart candle is confirmed.
Entry Beam
3D Risk and Reward Zones
VWAP Glow Line
Gradient Candle Coloring

━━━━━━━━━━━━━━━━━━━━

📋 Dashboard Explained

The dashboard provides a summary of current chart conditions.

[list]
[*]Market Condition
[*]Bull Score and Bear Score
[*]RSI
[*]ATR Percentage
[*]Volume Ratio
[*]Bollinger Band Width
[*]HTF Trend
[*]VWAP
[*]Active Trade
[*]SL / TP
[*]Win Rate
[/list]

[i]The dashboard win rate is an internal chart-touch statistic based on whether displayed targets or stops were reached.[/i]

For reliable validation, traders should independently review historical trades and conduct proper testing.

━━━━━━━━━━━━━━━━━━━━

🔔 Alert Features

Buy-sell with Multi-logic Trading System provides alert conditions for:

• Confirmed BUY signal
• Confirmed SELL signal
• Active stop-loss touched
• Active target touched

Dynamic BUY and SELL alerts can also include:

• Symbol
• Entry price
• Stop-loss
• Target price

[i]Signals and dynamic alerts are generated once per confirmed candle close.

For TradingView alerts, select the indicator and choose the required alert condition.[/i]

━━━━━━━━━━━━━━━━━━━━

📌 Preferred Logic According to Market View

👉 Strong Bullish Market

Recommended:

• Trend Logic: ON
• Momentum Logic: ON
• Breakout Logic: Optional
• Mean Reversion: OFF
• HTF Filter: ON
• VWAP Filter: ON
• Minimum Confluence: 4 or 5

Focus mainly on long signals, pullbacks and bullish consolidation breakouts.

👉Strong Bearish Market

Recommended:

• Trend Logic: ON
• Momentum Logic: ON
• Breakout Logic: Optional
• Mean Reversion: OFF
• HTF Filter: ON
• VWAP Filter: ON
• Minimum Confluence: 4 or 5

Focus mainly on short signals, failed recoveries and bearish range breakdowns.

👉 Developing Trend

Recommended:

• Trend Logic: ON
• Momentum Logic: ON
• Breakout Logic: ON
• Mean Reversion: OFF
• Minimum Confluence: 4
• Breakout Buffer: 0.10–0.20 ATR

Momentum or breakout logic may identify the move before complete EMA alignment develops.

👉 Established Trend

Recommended:

• Trend Logic: ON
• Momentum Logic: Optional
• Breakout Logic: Optional
• Mean Reversion: OFF
• Minimum Confluence: 4–5
• Structure + ATR stop

Look for continuation after controlled pullbacks rather than chasing extended candles.

👉 Clean Sideways Range

Recommended:

• Trend Logic: OFF or used cautiously
• Momentum Logic: OFF
• Breakout Logic: ON
• Mean Reversion: ON only for confirmed range rejection
• RSI Turn Requirement: ON
• Reversion Wick Ratio: 0.35–0.50

Use either range fading or breakout trading according to price behaviour—but avoid treating both as equally valid at the same moment.

👉 Transition or Choppy Market

Recommended:

• Increase Minimum Confluence
• Increase cooldown bars
• Use HTF and VWAP filters
• Keep Mean Reversion OFF unless a clear range forms
• Wait for structure to become clearer

Sometimes the best setting in a Transition market is simply to avoid trading.

━━━━━━━━━━━━━━━━━━━━

 🧩 Suggested Presets

🔶 Balanced Intraday — 5 or 15 Minutes

• EMA: 20 / 50 / 200
• HTF: 60 minutes
• HTF Filter: ON
• VWAP Filter: ON
• Trend Logic: ON
• Momentum Logic: ON
• Breakout Logic: ON
• Mean Reversion: OFF
• Minimum Confluence: 4
• Volume Multiplier: 1.5
• Breakout Buffer: 0.15 ATR
• Breakout Close Position: 0.60
• Stop: Structure + ATR
• Target: 1.5 Risk:Reward
• Cooldown: 5 bars
• Fresh Setup Only: ON
• Wait for Exit: ON

🔶 Precision Intraday

• HTF Filter: ON
• VWAP Filter: ON
• Minimum Confluence: 5
• Volume Multiplier: 1.7–2.0
• Breakout Buffer: 0.20–0.30 ATR
• Breakout Close Position: 0.70–0.80
• Fresh Setup Only: ON
• Wait for Exit: ON

This preset produces fewer signals but demands stronger confirmation.

🔶 Fast Momentum Trading

• Trend Logic: Optional
• Momentum Logic: ON
• Breakout Logic: ON
• Mean Reversion: OFF
• HTF Filter: ON
• VWAP Filter: ON
• Volume Multiplier: 1.3–1.5
• Cooldown: 2–4 bars
• Stop: ATR
• Target: ATR or Risk:Reward

Fast settings should only be used on liquid instruments because they are more sensitive to lower-timeframe noise.

🔶 Range-Breakout Trading

• Trend Logic: Optional
• Momentum Logic: Optional
• Breakout Logic: ON
• Mean Reversion: OFF
• Breakout Buffer: 0.15–0.30 ATR
• Close Position: 0.65–0.80
• Require Breakout Volume: ON
• Volume Multiplier: 1.5–2.0
• VWAP Filter: ON

Manually confirm that sufficient space exists beyond the range.

🔶 Sideways Mean Reversion

• Trend Logic: OFF
• Momentum Logic: OFF
• Breakout Logic: Optional
• Mean Reversion: ON
• Minimum Range Width: 1.0–1.5 ATR
• Rejection Wick Ratio: 0.35–0.50
• RSI Turn Requirement: ON
• Fresh Setup Only: ON
• Wait for Exit: ON

Do not use this preset when the range boundary is being attacked with expanding volume.

🔶 Swing Trading — 1 Hour or 4 Hours

• EMA: 20 / 50 / 200
• HTF: 4 Hour, Daily or Weekly
• HTF Filter: ON
• VWAP Filter: Optional
• Trend Logic: ON
• Momentum Logic: ON
• Breakout Logic: ON
• Mean Reversion: Usually OFF
• Minimum Confluence: 4–5
• Swing Lookback: 10–20
• Stop: Structure + ATR
• Target: Risk:Reward
• Risk:Reward: 1.5–2.5
• Cooldown: 3–5 bars

━━━━━━━━━━━━━━━━━━━━

⛔ When Not to Use the Indicator

Avoid taking signals mechanically when:

• The market-condition card shows an unstable Transition phase
• Price is moving inside a very narrow and noisy area
• A signal is directly facing major higher-timeframe structure
• Price is highly extended from the EMA ribbon or VWAP
• The signal candle is abnormally large
• A major economic event is creating unpredictable volatility
• The selected instrument is illiquid
• Volume data is unreliable
• Bid–ask spreads are unusually wide
• The chart timeframe is too low for the instrument
• There is insufficient reward before the next support or resistance
• The stop required by structure is larger than the trader’s permitted risk

A technically valid signal is not automatically a good trade.

Location, liquidity, market context and risk remain essential.

━━━━━━━━━━━━━━━━━━━━

✅ Recommended Trading Workflow

[b]Step 1[/b]: Identify the market condition

Determine whether the chart is trending, ranging or transitioning.

[b]Step 2[/b]: Check the higher timeframe

Confirm the broader directional structure before using Trend or Momentum signals.

[b]Step 3[/b]: Check VWAP location

For intraday trading, prefer longs above VWAP and shorts below VWAP.

[b]Step 4[/b]: Read the dashboard

Compare:

• Bull and Bear scores
• RSI
• ATR percentage
• Volume ratio
• Bollinger Band width
• Higher-timeframe trend

[b]Step 5[/b]: Identify which logic suits the market

Do not use mean reversion in a strong trend.

Do not depend only on trend logic in an unstructured range.

[b]Step 6[/b]: Check trade location

Identify nearby support, resistance, previous-day levels, liquidity zones and higher-timeframe structure.

[b]Step 7[/b]: Evaluate risk

Check whether the displayed stop is logically placed and whether sufficient reward is available.

[b]Step 8[/b]: Wait for candle confirmation

Avoid anticipating a signal before the candle closes.

━━━━━━━━━━━━━━━━━━━━

⚠️ Important Notes

[i]Buy-sell with Multi-logic Trading System is a decision-support indicator, not an automatic guarantee of profitable trades.[/i]

The indicator does not know:

• Your account size
• Your maximum permitted risk
• Whether a market-moving announcement is approaching
• Whether a nearby level is personally significant to your analysis
• Whether an option contract has suitable liquidity, delta or implied volatility
• Whether the displayed trade fits your trading plan

When several logic engines are enabled together, a BUY or SELL signal can originate from Trend, Momentum, Breakout or Mean-Reversion conditions.

The current signal marker does not separately label which internal engine generated it. The market condition, dashboard and surrounding price action should therefore be used to interpret the setup.

Always test the indicator on the intended market and timeframe before using it in live trading.

━━━━━━━━━━━━━━━━━━━━

📈 Final Perspective

Buy-sell with Multi-logic Trading System is designed around one central idea:

[i]**Trade according to the current market regime instead of forcing the same strategy into every market.**[/i]

Use Trend Logic when structure is aligned.

Use Momentum Logic when participation and acceleration are increasing.

Use Breakout Logic when price is escaping a well-defined range with confirmation.

Use Mean Reversion only when the market is genuinely balanced and rejecting its boundaries.

The indicator can organise information, filter conditions and define structured risk—but disciplined execution, position sizing and market awareness remain the trader’s responsibility.

------------------------------------------------


**Educational use only. This indicator does not provide financial advice or guarantee future results.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InvestyourAsset

//@version=6
indicator(
     title    = "Buy-Sell Signals using Multi-Logic Trend, Momentum & Breakout System",
     shorttitle = "Buy-sell with multi-logic trading system",
     overlay  = true,
     max_bars_back = 1000,
     max_labels_count = 500,
     max_boxes_count = 500)

// ============================================================================
// INPUTS
// ============================================================================

string GROUP_TREND   = "1. Market Structure & Trend"
string GROUP_HTF      = "2. Higher-Timeframe Filter"
string GROUP_VWAP     = "3. VWAP Filter"
string GROUP_ENTRY   = "4. Entry Logic"
string GROUP_VOLUME  = "5. Volume Confirmation"
string GROUP_RISK    = "6. Stop-Loss & Target"
string GROUP_SIGNAL  = "7. Signal Control"
string GROUP_DISPLAY = "8. Display"
string GROUP_ALERTS  = "9. Alerts"

// Market structure and trend
int fastEmaLength = input.int(20, "Fast EMA", minval = 1, group = GROUP_TREND)
int midEmaLength = input.int(50, "Medium EMA", minval = 2, group = GROUP_TREND)
int slowEmaLength = input.int(200, "Slow EMA", minval = 3, group = GROUP_TREND)
int rangeLength = input.int(30, "Range Lookback", minval = 5, group = GROUP_TREND)
float rangeThresholdPct = input.float(5.0, "Maximum Range Width %", minval = 0.1, step = 0.1, group = GROUP_TREND)

// Higher-timeframe filter
bool useHtfFilter = input.bool(true, "Use Higher-Timeframe Trend Filter", group = GROUP_HTF)
string htfTimeframe = input.timeframe("60", "Higher Timeframe", group = GROUP_HTF)
int htfEmaLength = input.int(50, "HTF EMA Length", minval = 2, group = GROUP_HTF)

// VWAP filter
bool useVwapFilter = input.bool(true, "Use Session VWAP Filter", group = GROUP_VWAP)

// Entry logic
int rsiLength = input.int(14, "RSI Length", minval = 2, group = GROUP_ENTRY)
int macdFastLength = input.int(12, "MACD Fast Length", minval = 1, group = GROUP_ENTRY)
int macdSlowLength = input.int(26, "MACD Slow Length", minval = 2, group = GROUP_ENTRY)
int macdSignalLength = input.int(9, "MACD Signal Length", minval = 1, group = GROUP_ENTRY)
int bbLength = input.int(20, "Bollinger Band Length", minval = 2, group = GROUP_ENTRY)
float bbDeviation = input.float(2.0, "Bollinger Band Deviation", minval = 0.1, step = 0.1, group = GROUP_ENTRY)
int minimumConfluence = input.int(4, "Minimum Trend Confluence", minval = 2, maxval = 6, group = GROUP_ENTRY)
bool enableTrendLogic = input.bool(true, "Enable Trend-Following Logic", group = GROUP_ENTRY)
bool enableMomentumLogic = input.bool(true, "Enable Momentum Logic", group = GROUP_ENTRY)
bool enableBreakoutLogic = input.bool(true, "Enable Range Breakout Logic", group = GROUP_ENTRY)
float breakoutAtrBuffer = input.float(0.15, "Breakout Confirmation Buffer (x ATR)", minval = 0.0, step = 0.05, group = GROUP_ENTRY)
float breakoutMinClosePosition = input.float(0.60, "Breakout Min Close Position In Candle", minval = 0.5, maxval = 1.0, step = 0.05, group = GROUP_ENTRY)
bool requireVolumeForBreakout = input.bool(true, "Require High Volume For Breakout", group = GROUP_ENTRY)
bool enableMeanReversion = input.bool(false, "Enable Sideways Mean-Reversion Logic", group = GROUP_ENTRY)
float minRangeAtrRatio = input.float(1.0, "Mean-Reversion Min Range Width (x ATR)", minval = 0.1, step = 0.1, group = GROUP_ENTRY)
float reversionWickRatio = input.float(0.35, "Mean-Reversion Min Rejection Wick Ratio", minval = 0.1, maxval = 0.9, step = 0.05, group = GROUP_ENTRY)
bool requireRsiTurnForReversion = input.bool(true, "Mean-Reversion Require RSI Turning", group = GROUP_ENTRY)

// Volume confirmation
bool useVolumeFilter = input.bool(true, "Use Volume Filter When Available", group = GROUP_VOLUME)
int volumeMaLength = input.int(20, "Volume MA Length", minval = 1, group = GROUP_VOLUME)
float volumeMultiplier = input.float(1.5, "High-Volume Multiplier", minval = 0.1, step = 0.1, group = GROUP_VOLUME)
int obvMaLength = input.int(14, "OBV MA Length", minval = 1, group = GROUP_VOLUME)

// Risk management
int atrLength = input.int(14, "ATR Length", minval = 1, group = GROUP_RISK)
string stopMethod = input.string("Structure + ATR", "Stop-Loss Method", options = ["Structure + ATR", "ATR", "Fixed %"], group = GROUP_RISK)
string targetMethod = input.string("Risk:Reward", "Target Method", options = ["Risk:Reward", "ATR", "Fixed %"], group = GROUP_RISK)
int swingLookback = input.int(10, "Structure Swing Lookback", minval = 2, group = GROUP_RISK)
float structureAtrBuffer = input.float(0.20, "Structure ATR Buffer", minval = 0.0, step = 0.05, group = GROUP_RISK)
float stopAtrMultiplier = input.float(1.5, "Stop ATR Multiplier", minval = 0.1, step = 0.1, group = GROUP_RISK)
float targetAtrMultiplier = input.float(2.5, "Target ATR Multiplier", minval = 0.1, step = 0.1, group = GROUP_RISK)
float fixedStopPct = input.float(2.5, "Fixed Stop %", minval = 0.1, step = 0.1, group = GROUP_RISK)
float fixedTargetPct = input.float(5.0, "Fixed Target %", minval = 0.1, step = 0.1, group = GROUP_RISK)
float riskRewardRatio = input.float(1.5, "Risk:Reward Ratio", minval = 0.2, step = 0.1, group = GROUP_RISK)
bool clearLevelsOnHit = input.bool(true, "Clear Levels After SL/Target Hit", group = GROUP_RISK)

// Signal control
int cooldownBars = input.int(5, "Minimum Bars Between Signals", minval = 0, group = GROUP_SIGNAL)
bool freshSetupOnly = input.bool(true, "Signal Only When Setup Becomes Fresh", group = GROUP_SIGNAL)
bool requireExitBeforeNextSignal = input.bool(true, "Wait For SL/Target Before Next Signal", group = GROUP_SIGNAL)
bool allowOppositeSignal = input.bool(true, "Allow Opposite Signal Before Exit (if wait is OFF)", group = GROUP_SIGNAL)

// Display
bool showSignals = input.bool(true, "Show Signal Glow Markers", group = GROUP_DISPLAY)
bool showTradeLevels = input.bool(true, "Show Entry Glow Beam", group = GROUP_DISPLAY)
bool showTradeZones = input.bool(true, "Show 3D Risk / Reward Boxes", group = GROUP_DISPLAY)
bool showHistoricalZones = input.bool(false, "Keep Historical Risk/Reward Boxes On Chart", group = GROUP_DISPLAY)
bool showTrendRibbon = input.bool(true, "Show 3D Gradient Trend Ribbon", group = GROUP_DISPLAY)
bool showVwapLine = input.bool(true, "Show VWAP Glow Line", group = GROUP_DISPLAY)
bool showMarketCondition = input.bool(true, "Show Market-Condition Card", group = GROUP_DISPLAY)
bool showDashboard = input.bool(true, "Show Statistics Dashboard", group = GROUP_DISPLAY)
bool colorTrendCandles = input.bool(false, "Gradient Candle Coloring By Trend Strength", group = GROUP_DISPLAY)

// Alerts
bool enableDynamicAlerts = input.bool(true, "Enable Dynamic alert() Messages", group = GROUP_ALERTS)

// ============================================================================
// PREMIUM COLOR PALETTE (Navy / Gold theme)
// ============================================================================

color colNavy      = #0A1F44
color colNavyLight  = #13315C
color colGold       = #D4AF37
color colBullish    = #00C896
color colBearish    = #FF3B5C
color colNeutral    = #9598A1

// ============================================================================
// CORE CALCULATIONS
// ============================================================================

float atr = ta.atr(atrLength)
float atrPercent = close != 0.0 ? atr / close * 100.0 : na

float emaFast = ta.ema(close, fastEmaLength)
float emaMid = ta.ema(close, midEmaLength)
float emaSlow = ta.ema(close, slowEmaLength)

float rsi = ta.rsi(close, rsiLength)
[macdLine, macdSignal, macdHistogram] = ta.macd(close, macdFastLength, macdSlowLength, macdSignalLength)
[bbBasis, bbUpper, bbLower] = ta.bb(close, bbLength, bbDeviation)
float bbWidthPct = not na(bbBasis) and bbBasis != 0.0 ? (bbUpper - bbLower) / bbBasis * 100.0 : na

// Higher-timeframe trend (non-repainting: confirmed HTF bar only)
float htfEma = request.security(syminfo.tickerid, htfTimeframe, ta.ema(close, htfEmaLength)[barstate.isrealtime ? 1 : 0], lookahead = barmerge.lookahead_off)
bool htfBullish = not na(htfEma) and close > htfEma
bool htfBearish = not na(htfEma) and close < htfEma
bool htfLongOk = not useHtfFilter or htfBullish
bool htfShortOk = not useHtfFilter or htfBearish

// Session VWAP â€” resets automatically at the start of each new session/day.
// Acts as a fair-value anchor: longs are only taken above it, shorts only below it,
// which filters out counter-trend entries that trigger on confluence alone.
float vwapValue = ta.vwap(hlc3)
bool vwapLongOk = not useVwapFilter or (not na(vwapValue) and close > vwapValue)
bool vwapShortOk = not useVwapFilter or (not na(vwapValue) and close < vwapValue)

// The prior range excludes the current candle. This makes confirmed breakouts possible
// and avoids comparing the close against a range that already contains the same candle.
float priorRangeHigh = ta.highest(high, rangeLength)[1]
float priorRangeLow = ta.lowest(low, rangeLength)[1]
float priorRangeWidth = priorRangeHigh - priorRangeLow
float priorRangePct = not na(priorRangeLow) and priorRangeLow != 0.0 ? priorRangeWidth / priorRangeLow * 100.0 : na
bool priorMarketWasRange = not na(priorRangePct) and priorRangePct <= rangeThresholdPct

float priorSwingLow = ta.lowest(low, swingLookback)[1]
float priorSwingHigh = ta.highest(high, swingLookback)[1]

// Volume and manually calculated OBV. The manual form is robust on symbols where
// volume is unavailable and avoids depending on an ambiguous function call syntax.
float averageVolume = ta.sma(volume, volumeMaLength)
bool hasUsableVolume = not na(volume) and not na(averageVolume) and averageVolume > 0.0
float volumeRatio = hasUsableVolume ? volume / averageVolume : na
bool highVolume = hasUsableVolume and volumeRatio >= volumeMultiplier

float signedVolume = close > close[1] ? nz(volume) : close < close[1] ? -nz(volume) : 0.0
float obv = ta.cum(signedVolume)
float obvAverage = ta.sma(obv, obvMaLength)
bool obvBullish = obv > obvAverage
bool obvBearish = obv < obvAverage

// A missing volume feed does not block signals. When volume exists and the filter is
// enabled, momentum and breakout signals require a high-volume candle.
bool volumeGate = not useVolumeFilter or not hasUsableVolume or highVolume

bool bullishTrend = close > emaFast and emaFast > emaMid and emaMid > emaSlow
bool bearishTrend = close < emaFast and emaFast < emaMid and emaMid < emaSlow
bool sidewaysMarket = priorMarketWasRange and not bullishTrend and not bearishTrend

bool bullishCandle = close > open
bool bearishCandle = close < open

// ============================================================================
// CONFLUENCE SCORES
// Each trend score has six independent components.
// ============================================================================

int bullishScore =
     (bullishTrend ? 1 : 0) +
     (rsi > 45.0 and rsi < 72.0 ? 1 : 0) +
     (macdLine > macdSignal and macdHistogram > 0.0 ? 1 : 0) +
     (close > bbBasis ? 1 : 0) +
     (hasUsableVolume and highVolume and obvBullish ? 1 : 0) +
     (bullishCandle and close > priorSwingHigh ? 1 : 0)

int bearishScore =
     (bearishTrend ? 1 : 0) +
     (rsi < 55.0 and rsi > 28.0 ? 1 : 0) +
     (macdLine < macdSignal and macdHistogram < 0.0 ? 1 : 0) +
     (close < bbBasis ? 1 : 0) +
     (hasUsableVolume and highVolume and obvBearish ? 1 : 0) +
     (bearishCandle and close < priorSwingLow ? 1 : 0)

// ============================================================================
// MULTI-LOGIC SETUPS
// ============================================================================

bool bullishTrendSetup = enableTrendLogic and bullishTrend and bullishScore >= minimumConfluence and htfLongOk and vwapLongOk
bool bearishTrendSetup = enableTrendLogic and bearishTrend and bearishScore >= minimumConfluence and htfShortOk and vwapShortOk

bool bullishMomentumSetup =
     enableMomentumLogic and
     close > emaFast and
     rsi > 52.0 and
     macdHistogram > 0.0 and
     macdHistogram > macdHistogram[1] and
     obvBullish and
     volumeGate and
     htfLongOk and
     vwapLongOk

bool bearishMomentumSetup =
     enableMomentumLogic and
     close < emaFast and
     rsi < 48.0 and
     macdHistogram < 0.0 and
     macdHistogram < macdHistogram[1] and
     obvBearish and
     volumeGate and
     htfShortOk and
     vwapShortOk

// Breakout confirmation: price must close a minimum ATR buffer past the range edge
// (not just barely tick through it), the candle must close strongly in the direction
// of the break (not a wick-back), and volume must actually confirm it when available â€”
// the three most common causes of breakout fakeouts.
bool candleRangeValid = (high - low) > 0.0
float closePositionInCandle = candleRangeValid ? (close - low) / (high - low) : na
bool breakoutCandleStrengthBull = candleRangeValid and closePositionInCandle >= breakoutMinClosePosition
bool breakoutCandleStrengthBear = candleRangeValid and closePositionInCandle <= (1.0 - breakoutMinClosePosition)
bool breakoutVolumeOk = not requireVolumeForBreakout or not hasUsableVolume or highVolume

bool bullishRangeBreakout =
     enableBreakoutLogic and
     priorMarketWasRange and
     not na(priorRangeHigh) and
     close > priorRangeHigh + atr * breakoutAtrBuffer and
     close[1] <= priorRangeHigh[1] and
     breakoutCandleStrengthBull and
     rsi > 50.0 and
     macdLine > macdSignal and
     volumeGate and
     breakoutVolumeOk and
     vwapLongOk

bool bearishRangeBreakout =
     enableBreakoutLogic and
     priorMarketWasRange and
     not na(priorRangeLow) and
     close < priorRangeLow - atr * breakoutAtrBuffer and
     close[1] >= priorRangeLow[1] and
     breakoutCandleStrengthBear and
     rsi < 50.0 and
     macdLine < macdSignal and
     volumeGate and
     breakoutVolumeOk and
     vwapShortOk

float lowerReversionZone = priorRangeLow + priorRangeWidth * 0.20
float upperReversionZone = priorRangeHigh - priorRangeWidth * 0.20

// Mean-reversion confirmation: the range must be wide enough relative to ATR to be
// worth fading (skips noisy micro-ranges), the candle must show a genuine rejection
// wick (pin-bar style) rather than just closing back inside the zone, and RSI must
// actually be turning rather than just sitting below/above a static level.
bool rangeWideEnoughForReversion = priorRangeWidth >= atr * minRangeAtrRatio
bool bullishRejectionWick = candleRangeValid and (math.min(open, close) - low) / (high - low) >= reversionWickRatio
bool bearishRejectionWick = candleRangeValid and (high - math.max(open, close)) / (high - low) >= reversionWickRatio
bool rsiTurningUp = not requireRsiTurnForReversion or rsi > rsi[1]
bool rsiTurningDown = not requireRsiTurnForReversion or rsi < rsi[1]

bool bullishMeanReversion =
     enableMeanReversion and
     sidewaysMarket and
     rangeWideEnoughForReversion and
     low <= lowerReversionZone and
     close > lowerReversionZone and
     bullishCandle and
     bullishRejectionWick and
     rsi < 38.0 and
     rsiTurningUp and
     volumeGate

bool bearishMeanReversion =
     enableMeanReversion and
     sidewaysMarket and
     rangeWideEnoughForReversion and
     high >= upperReversionZone and
     close < upperReversionZone and
     bearishCandle and
     bearishRejectionWick and
     rsi > 62.0 and
     rsiTurningDown and
     volumeGate

bool rawBuySetup = bullishTrendSetup or bullishMomentumSetup or bullishRangeBreakout or bullishMeanReversion
bool rawSellSetup = bearishTrendSetup or bearishMomentumSetup or bearishRangeBreakout or bearishMeanReversion

bool freshBuySetup = rawBuySetup and not rawBuySetup[1]
bool freshSellSetup = rawSellSetup and not rawSellSetup[1]
bool buyTrigger = freshSetupOnly ? freshBuySetup : rawBuySetup
bool sellTrigger = freshSetupOnly ? freshSellSetup : rawSellSetup

int requiredBars = math.max(slowEmaLength, math.max(rangeLength + 2, math.max(bbLength, macdSlowLength + macdSignalLength)))
bool enoughData = bar_index >= requiredBars

// ============================================================================
// TRADE STATE, CONFIRMED SIGNALS & PERFORMANCE TRACKING
// ============================================================================

var int lastSignalBar = na
var int tradeDirection = 0       // 1 = long, -1 = short, 0 = flat
var float activeEntry = na
var float activeStop = na
var float activeTarget = na
var int winCount = 0
var int lossCount = 0
var int totalSignals = 0
var bool awaitingExit = false
var array<box> rewardBoxes = array.new<box>()
var array<box> riskBoxes = array.new<box>()

bool longStopHit = tradeDirection == 1 and not na(activeStop) and low <= activeStop
bool longTargetHit = tradeDirection == 1 and not na(activeTarget) and high >= activeTarget
bool shortStopHit = tradeDirection == -1 and not na(activeStop) and high >= activeStop
bool shortTargetHit = tradeDirection == -1 and not na(activeTarget) and low <= activeTarget
bool activeLevelHit = longStopHit or longTargetHit or shortStopHit or shortTargetHit

// Independent of clearLevelsOnHit, so the "wait for exit" gate always unlocks the
// moment SL or Target is actually touched, even if the visual levels are kept on screen.
if activeLevelHit
    awaitingExit := false

if clearLevelsOnHit and activeLevelHit
    if longTargetHit or shortTargetHit
        winCount := winCount + 1
    if longStopHit or shortStopHit
        lossCount := lossCount + 1
    tradeDirection := 0
    activeEntry := na
    activeStop := na
    activeTarget := na

bool cooldownPassed = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
bool longAllowed = requireExitBeforeNextSignal ? not awaitingExit : (allowOppositeSignal or tradeDirection >= 0)
bool shortAllowed = requireExitBeforeNextSignal ? not awaitingExit : (allowOppositeSignal or tradeDirection <= 0)

bool confirmedBuyCandidate = barstate.isconfirmed and enoughData and cooldownPassed and longAllowed and buyTrigger
bool confirmedSellCandidate = barstate.isconfirmed and enoughData and cooldownPassed and shortAllowed and sellTrigger

// Resolve rare conflicts instead of issuing BUY and SELL on the same candle.
bool buySignal = confirmedBuyCandidate and (not confirmedSellCandidate or bullishScore > bearishScore)
bool sellSignal = confirmedSellCandidate and (not confirmedBuyCandidate or bearishScore > bullishScore)

if buySignal
    float fallbackLongStop = close - atr * stopAtrMultiplier
    float structureLongStop = not na(priorSwingLow) ? priorSwingLow - atr * structureAtrBuffer : fallbackLongStop
    float calculatedLongStop = stopMethod == "ATR" ? fallbackLongStop : stopMethod == "Fixed %" ? close * (1.0 - fixedStopPct / 100.0) : structureLongStop
    calculatedLongStop := calculatedLongStop >= close or na(calculatedLongStop) ? fallbackLongStop : calculatedLongStop

    float longRisk = math.max(close - calculatedLongStop, syminfo.mintick)
    float calculatedLongTarget = targetMethod == "ATR" ? close + atr * targetAtrMultiplier : targetMethod == "Fixed %" ? close * (1.0 + fixedTargetPct / 100.0) : close + longRisk * riskRewardRatio

    tradeDirection := 1
    activeEntry := close
    activeStop := calculatedLongStop
    activeTarget := calculatedLongTarget
    lastSignalBar := bar_index
    totalSignals := totalSignals + 1
    awaitingExit := true

    // In historical mode, past zone boxes are simply released from tracking (left
    // frozen on the chart) rather than deleted, so a permanent trade record builds up.
    if not showHistoricalZones and array.size(rewardBoxes) > 0
        for i = 0 to array.size(rewardBoxes) - 1
            box.delete(array.get(rewardBoxes, i))
    if not showHistoricalZones and array.size(riskBoxes) > 0
        for i = 0 to array.size(riskBoxes) - 1
            box.delete(array.get(riskBoxes, i))
    array.clear(rewardBoxes)
    array.clear(riskBoxes)

    if showTradeZones
        float zoneUnit = atr * 0.12
        float rTop = calculatedLongTarget
        float rBottom = close
        float kTop = close
        float kBottom = calculatedLongStop
        // Deep + mid shadow layers stacked behind the glass surface create the 3D depth illusion
        array.push(rewardBoxes, box.new(bar_index, rTop - zoneUnit * 2, bar_index, rBottom - zoneUnit * 2, border_color = na, bgcolor = color.new(colNavy, 94)))
        array.push(rewardBoxes, box.new(bar_index, rTop - zoneUnit, bar_index, rBottom - zoneUnit, border_color = na, bgcolor = color.new(colNavy, 89)))
        array.push(rewardBoxes, box.new(bar_index, rTop, bar_index, rBottom, border_color = colBullish, border_width = 2, bgcolor = color.new(colBullish, 80), text = "TARGET  " + str.tostring(calculatedLongTarget, format.mintick), text_color = colBullish, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_top))
        array.push(rewardBoxes, box.new(bar_index, rTop, bar_index, rTop - zoneUnit * 0.5, border_color = na, bgcolor = color.new(color.white, 72)))

        array.push(riskBoxes, box.new(bar_index, kTop + zoneUnit * 2, bar_index, kBottom + zoneUnit * 2, border_color = na, bgcolor = color.new(colNavy, 94)))
        array.push(riskBoxes, box.new(bar_index, kTop + zoneUnit, bar_index, kBottom + zoneUnit, border_color = na, bgcolor = color.new(colNavy, 89)))
        array.push(riskBoxes, box.new(bar_index, kTop, bar_index, kBottom, border_color = colBearish, border_width = 2, bgcolor = color.new(colBearish, 80), text = "STOP  " + str.tostring(calculatedLongStop, format.mintick), text_color = colBearish, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_bottom))
        array.push(riskBoxes, box.new(bar_index, kBottom + zoneUnit * 0.5, bar_index, kBottom, border_color = na, bgcolor = color.new(color.white, 80)))

if sellSignal
    float fallbackShortStop = close + atr * stopAtrMultiplier
    float structureShortStop = not na(priorSwingHigh) ? priorSwingHigh + atr * structureAtrBuffer : fallbackShortStop
    float calculatedShortStop = stopMethod == "ATR" ? fallbackShortStop : stopMethod == "Fixed %" ? close * (1.0 + fixedStopPct / 100.0) : structureShortStop
    calculatedShortStop := calculatedShortStop <= close or na(calculatedShortStop) ? fallbackShortStop : calculatedShortStop

    float shortRisk = math.max(calculatedShortStop - close, syminfo.mintick)
    float calculatedShortTarget = targetMethod == "ATR" ? close - atr * targetAtrMultiplier : targetMethod == "Fixed %" ? close * (1.0 - fixedTargetPct / 100.0) : close - shortRisk * riskRewardRatio

    tradeDirection := -1
    activeEntry := close
    activeStop := calculatedShortStop
    activeTarget := calculatedShortTarget
    lastSignalBar := bar_index
    totalSignals := totalSignals + 1
    awaitingExit := true

    // In historical mode, past zone boxes are simply released from tracking (left
    // frozen on the chart) rather than deleted, so a permanent trade record builds up.
    if not showHistoricalZones and array.size(rewardBoxes) > 0
        for i = 0 to array.size(rewardBoxes) - 1
            box.delete(array.get(rewardBoxes, i))
    if not showHistoricalZones and array.size(riskBoxes) > 0
        for i = 0 to array.size(riskBoxes) - 1
            box.delete(array.get(riskBoxes, i))
    array.clear(rewardBoxes)
    array.clear(riskBoxes)

    if showTradeZones
        float zoneUnit = atr * 0.12
        float rTop = close
        float rBottom = calculatedShortTarget
        float kTop = calculatedShortStop
        float kBottom = close
        array.push(rewardBoxes, box.new(bar_index, rTop + zoneUnit * 2, bar_index, rBottom + zoneUnit * 2, border_color = na, bgcolor = color.new(colNavy, 94)))
        array.push(rewardBoxes, box.new(bar_index, rTop + zoneUnit, bar_index, rBottom + zoneUnit, border_color = na, bgcolor = color.new(colNavy, 89)))
        array.push(rewardBoxes, box.new(bar_index, rTop, bar_index, rBottom, border_color = colBullish, border_width = 2, bgcolor = color.new(colBullish, 80), text = "TARGET  " + str.tostring(calculatedShortTarget, format.mintick), text_color = colBullish, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_bottom))
        array.push(rewardBoxes, box.new(bar_index, rBottom + zoneUnit * 0.5, bar_index, rBottom, border_color = na, bgcolor = color.new(color.white, 72)))

        array.push(riskBoxes, box.new(bar_index, kTop - zoneUnit * 2, bar_index, kBottom - zoneUnit * 2, border_color = na, bgcolor = color.new(colNavy, 94)))
        array.push(riskBoxes, box.new(bar_index, kTop - zoneUnit, bar_index, kBottom - zoneUnit, border_color = na, bgcolor = color.new(colNavy, 89)))
        array.push(riskBoxes, box.new(bar_index, kTop, bar_index, kBottom, border_color = colBearish, border_width = 2, bgcolor = color.new(colBearish, 80), text = "STOP  " + str.tostring(calculatedShortStop, format.mintick), text_color = colBearish, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_top))
        array.push(riskBoxes, box.new(bar_index, kTop, bar_index, kTop - zoneUnit * 0.5, border_color = na, bgcolor = color.new(color.white, 80)))

// Extend every layer of the active zone bar by bar while the trade is open, then freeze
// them the moment it closes â€” leaving a clean 3D visual record of the finished trade.
if showTradeZones and tradeDirection != 0
    if array.size(rewardBoxes) > 0
        for i = 0 to array.size(rewardBoxes) - 1
            box.set_right(array.get(rewardBoxes, i), bar_index)
    if array.size(riskBoxes) > 0
        for i = 0 to array.size(riskBoxes) - 1
            box.set_right(array.get(riskBoxes, i), bar_index)

// ============================================================================
// VISUALS â€” Premium Navy / Gold theme
// ============================================================================

string marketCondition = bullishTrend ? "BULLISH TREND" : bearishTrend ? "BEARISH TREND" : priorMarketWasRange ? "RANGE / SIDEWAYS" : "TRANSITION"
color marketColor = bullishTrend ? colBullish : bearishTrend ? colBearish : priorMarketWasRange ? colGold : colNeutral

// ----------------------------------------------------------------------------
// 3D GRADIENT TREND RIBBON
// Six interpolated bands between the fast and slow EMA, blended with
// color.from_gradient() and layered fills, form a soft glowing "tube" instead
// of flat EMA lines. Kept deliberately low-opacity â€” it's meant to sit quietly
// behind the chart as trend context, not compete with the risk/reward boxes.
// ----------------------------------------------------------------------------
color ribbonNearBase = bullishTrend ? colGold : bearishTrend ? colBearish : colNeutral
color ribbonFarBase = bullishTrend ? colBullish : bearishTrend ? #7A1030 : colNavyLight

float rb0 = emaFast
float rb1 = emaFast + (emaSlow - emaFast) * 0.20
float rb2 = emaFast + (emaSlow - emaFast) * 0.40
float rb3 = emaFast + (emaSlow - emaFast) * 0.60
float rb4 = emaFast + (emaSlow - emaFast) * 0.80
float rb5 = emaSlow

p0 = plot(showTrendRibbon ? rb0 : na, "Ribbon 0", color = color.new(color.from_gradient(0, 0, 5, ribbonNearBase, ribbonFarBase), 65), linewidth = 1)
p1 = plot(showTrendRibbon ? rb1 : na, "Ribbon 1", color = color.new(color.from_gradient(1, 0, 5, ribbonNearBase, ribbonFarBase), 65), linewidth = 1)
p2 = plot(showTrendRibbon ? rb2 : na, "Ribbon 2", color = color.new(color.from_gradient(2, 0, 5, ribbonNearBase, ribbonFarBase), 65), linewidth = 1)
p3 = plot(showTrendRibbon ? rb3 : na, "Ribbon 3", color = color.new(color.from_gradient(3, 0, 5, ribbonNearBase, ribbonFarBase), 65), linewidth = 1)
p4 = plot(showTrendRibbon ? rb4 : na, "Ribbon 4", color = color.new(color.from_gradient(4, 0, 5, ribbonNearBase, ribbonFarBase), 65), linewidth = 1)
p5 = plot(showTrendRibbon ? rb5 : na, "Ribbon 5", color = color.new(color.from_gradient(5, 0, 5, ribbonNearBase, ribbonFarBase), 65), linewidth = 1)

fill(p0, p1, color = showTrendRibbon ? color.new(color.from_gradient(0.5, 0, 5, ribbonNearBase, ribbonFarBase), 92) : na, title = "Ribbon Fill 0-1")
fill(p1, p2, color = showTrendRibbon ? color.new(color.from_gradient(1.5, 0, 5, ribbonNearBase, ribbonFarBase), 92) : na, title = "Ribbon Fill 1-2")
fill(p2, p3, color = showTrendRibbon ? color.new(color.from_gradient(2.5, 0, 5, ribbonNearBase, ribbonFarBase), 92) : na, title = "Ribbon Fill 2-3")
fill(p3, p4, color = showTrendRibbon ? color.new(color.from_gradient(3.5, 0, 5, ribbonNearBase, ribbonFarBase), 92) : na, title = "Ribbon Fill 3-4")
fill(p4, p5, color = showTrendRibbon ? color.new(color.from_gradient(4.5, 0, 5, ribbonNearBase, ribbonFarBase), 92) : na, title = "Ribbon Fill 4-5")

// Faint core highlight riding the fast EMA â€” still traceable, but no longer bright enough to fight the boxes
plot(showTrendRibbon ? emaFast : na, "Ribbon Core Glow", color = color.new(ribbonNearBase, 88), linewidth = 4)
plot(showTrendRibbon ? emaFast : na, "Ribbon Core", color = color.new(ribbonNearBase, 45), linewidth = 1)

// ----------------------------------------------------------------------------
// GLOW SIGNAL MARKERS
// Layered concentric label circles at identical coordinates create a genuine
// halo/glow (plotshape auto-stacks at shared locations, labels do not), with a
// small gold-on-navy tag beneath naming the signal.
// ----------------------------------------------------------------------------
if showSignals and buySignal
    float glowY = low - atr * 0.6
    label.new(bar_index, glowY, style = label.style_circle, size = size.huge, color = color.new(colBullish, 82), text = "")
    label.new(bar_index, glowY, style = label.style_circle, size = size.large, color = color.new(colBullish, 55), text = "")
    label.new(bar_index, glowY, style = label.style_circle, size = size.small, color = colBullish, text = "")
    label.new(bar_index, glowY - atr * 0.55, style = label.style_label_up, size = size.small, color = colNavy, textcolor = colGold, text = "BUY")

if showSignals and sellSignal
    float glowY = high + atr * 0.6
    label.new(bar_index, glowY, style = label.style_circle, size = size.huge, color = color.new(colBearish, 82), text = "")
    label.new(bar_index, glowY, style = label.style_circle, size = size.large, color = color.new(colBearish, 55), text = "")
    label.new(bar_index, glowY, style = label.style_circle, size = size.small, color = colBearish, text = "")
    label.new(bar_index, glowY + atr * 0.55, style = label.style_label_down, size = size.small, color = colNavy, textcolor = colGold, text = "SELL")

// ----------------------------------------------------------------------------
// GLOW ENTRY BEAM â€” the 3D zone boxes already show target/stop, so the entry
// only needs a bright thin "beam" (thick soft halo plot behind a crisp core plot).
// ----------------------------------------------------------------------------
plot(showTradeLevels and tradeDirection != 0 ? activeEntry : na, "Entry Beam Glow", color = color.new(colGold, 72), linewidth = 6, style = plot.style_linebr)
plot(showTradeLevels and tradeDirection != 0 ? activeEntry : na, "Entry Beam Core", color = color.new(colGold, 5), linewidth = 1, style = plot.style_linebr)

// ----------------------------------------------------------------------------
// VWAP GLOW LINE â€” same halo trick anchored to session VWAP
// ----------------------------------------------------------------------------
plot(showVwapLine ? vwapValue : na, "VWAP Glow", color = color.new(colGold, 78), linewidth = 6)
plot(showVwapLine ? vwapValue : na, "VWAP Core", color = color.new(colGold, 8), linewidth = 1)

// ----------------------------------------------------------------------------
// GRADIENT CANDLE COLORING (optional) â€” smoothly graded by confluence strength
// instead of a flat two-tone volume color
// ----------------------------------------------------------------------------
int scoreDiff = bullishScore - bearishScore
color trendCandleColor = scoreDiff > 0 ? color.from_gradient(scoreDiff, 0, 6, color.new(colBullish, 65), color.new(colBullish, 0)) : scoreDiff < 0 ? color.from_gradient(math.abs(scoreDiff), 0, 6, color.new(colBearish, 65), color.new(colBearish, 0)) : color.new(colNeutral, 55)
barcolor(colorTrendCandles ? trendCandleColor : na)

// ----------------------------------------------------------------------------
// MARKET-CONDITION GLASS CARD â€” a soft shadow card behind the crisp label on
// top mimics a floating glass panel instead of a flat text tag.
// ----------------------------------------------------------------------------
var label marketCardShadow = na
var label marketCard = na
if barstate.islast
    if not na(marketCard)
        label.delete(marketCard)
        label.delete(marketCardShadow)
        marketCard := na
        marketCardShadow := na
    if showMarketCondition
        marketCardShadow := label.new(
             x = bar_index,
             y = high + atr * 1.25,
             text = marketCondition,
             style = label.style_label_down,
             color = color.new(colNavy, 55),
             textcolor = color.new(colNavy, 55),
             size = size.normal)
        marketCard := label.new(
             x = bar_index,
             y = high + atr,
             text = marketCondition,
             style = label.style_label_down,
             color = color.new(marketColor, 78),
             textcolor = marketColor,
             size = size.normal)

// ============================================================================
// DASHBOARD Navy / Gold premium panel
// ============================================================================

var table dashboard = table.new(position.top_right, 2, 12, border_width = 1, border_color = color.new(colGold, 40))

if barstate.islast
    if showDashboard
        float winRate = (winCount + lossCount) > 0 ? winCount / (winCount + lossCount) * 100.0 : na
        string winRateText = na(winRate) ? "N/A" : str.tostring(winRate, "#.#") + "% (" + str.tostring(winCount + lossCount) + ")"
        string htfText = not useHtfFilter ? "OFF" : htfBullish ? "BULLISH" : htfBearish ? "BEARISH" : "NEUTRAL"
        color htfColor = not useHtfFilter ? colNeutral : htfBullish ? colBullish : htfBearish ? colBearish : colGold

        table.cell(dashboard, 0, 0, "IYA Â· ATS PRO", bgcolor = colNavy, text_color = colGold, text_size = size.small)
        table.cell(dashboard, 1, 0, marketCondition, bgcolor = colNavy, text_color = marketColor, text_size = size.small)

        table.cell(dashboard, 0, 1, "Bull Score", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 1, str.tostring(bullishScore) + " / 6", bgcolor = colNavyLight, text_color = colBullish, text_size = size.small)

        table.cell(dashboard, 0, 2, "Bear Score", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 2, str.tostring(bearishScore) + " / 6", bgcolor = colNavyLight, text_color = colBearish, text_size = size.small)

        table.cell(dashboard, 0, 3, "RSI", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 3, str.tostring(rsi, "#.0"), bgcolor = colNavyLight, text_color = color.white, text_size = size.small)

        table.cell(dashboard, 0, 4, "ATR %", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 4, str.tostring(atrPercent, "#.##") + "%", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)

        table.cell(dashboard, 0, 5, "Volume Ratio", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 5, hasUsableVolume ? str.tostring(volumeRatio, "#.##") + "x" : "N/A", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)

        table.cell(dashboard, 0, 6, "BB Width", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 6, str.tostring(bbWidthPct, "#.##") + "%", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)

        table.cell(dashboard, 0, 7, "HTF Trend", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 7, htfText, bgcolor = colNavyLight, text_color = htfColor, text_size = size.small)

        string vwapText = not useVwapFilter ? "OFF" : na(vwapValue) ? "N/A" : close > vwapValue ? "ABOVE" : "BELOW"
        color vwapColor = not useVwapFilter ? colNeutral : na(vwapValue) ? colNeutral : close > vwapValue ? colBullish : colBearish
        table.cell(dashboard, 0, 8, "VWAP", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 8, vwapText, bgcolor = colNavyLight, text_color = vwapColor, text_size = size.small)

        table.cell(dashboard, 0, 9, "Trade", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 9, tradeDirection == 1 ? "LONG" : tradeDirection == -1 ? "SHORT" : "FLAT", bgcolor = colNavyLight, text_color = tradeDirection == 1 ? colBullish : tradeDirection == -1 ? colBearish : colNeutral, text_size = size.small)

        table.cell(dashboard, 0, 10, "SL / TP", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)
        table.cell(dashboard, 1, 10, tradeDirection != 0 ? str.tostring(activeStop, format.mintick) + " / " + str.tostring(activeTarget, format.mintick) : "-", bgcolor = colNavyLight, text_color = color.white, text_size = size.small)

        table.cell(dashboard, 0, 11, "Win Rate", bgcolor = colNavy, text_color = colGold, text_size = size.small)
        table.cell(dashboard, 1, 11, winRateText, bgcolor = colNavy, text_color = colGold, text_size = size.small)
    else
        table.clear(dashboard, 0, 0, 1, 11)

// ============================================================================
// ALERTS
// ============================================================================

alertcondition(buySignal, title = "ATS Pro BUY", message = "ATS Pro BUY confirmed on {{ticker}} at {{close}}")
alertcondition(sellSignal, title = "ATS Pro SELL", message = "ATS Pro SELL confirmed on {{ticker}} at {{close}}")
alertcondition(longStopHit or shortStopHit, title = "ATS Pro Stop Hit", message = "ATS Pro active stop was touched on {{ticker}}")
alertcondition(longTargetHit or shortTargetHit, title = "ATS Pro Target Hit", message = "ATS Pro active target was touched on {{ticker}}")

if enableDynamicAlerts and buySignal
    alert("ATS PRO BUY | " + syminfo.ticker + " | Entry: " + str.tostring(activeEntry, format.mintick) + " | SL: " + str.tostring(activeStop, format.mintick) + " | Target: " + str.tostring(activeTarget, format.mintick), alert.freq_once_per_bar_close)

if enableDynamicAlerts and sellSignal
    alert("ATS PRO SELL | " + syminfo.ticker + " | Entry: " + str.tostring(activeEntry, format.mintick) + " | SL: " + str.tostring(activeStop, format.mintick) + " | Target: " + str.tostring(activeTarget, format.mintick), alert.freq_once_per_bar_close)
````
