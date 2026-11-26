# Zone Flow S/R Strategy

- url: https://www.tradingview.com/script/9IoAQC1M-Zone-Flow-S-R-Strategy/
- type: strategy
- pine_id: PUB;8c2c272eb9ed490db64a120688728fd3
- version: 2.0

## Description

Zone Flow S/R Strategy

📌 Strategy Overview

Zone Flow is a multi‑timeframe support/resistance strategy that uses dynamic pivot‑derived zones to identify high‑probability reversal and breakout setups.

Unlike static support/resistance lines, this 9‑level zone system (R4–R1, P, S1–S4) automatically adapts to market structure changes at each new period (Daily/Weekly/Monthly). Each zone has a configurable width (Percentage, ATR, or Fixed) to account for volatility, and a breakout threshold to filter out minor wicks.

# Unique Synergy 

Most pivot strategies treat levels as static lines, leading to false breakouts. Most engulfing strategies ignore the bigger picture, catching falling knives. This strategy solves both problems by combining these components in a specific sequence:

1- Dynamic Zones + Gap State Machine (The Context)
Instead of just drawing lines, we create zones (R1-R4, P, S1-S4) with adaptive width. More importantly, the Gap State Machine tracks which gap price sits in (e.g., between R1 and Pivot). This tells us exactly where we are in the market structure. If price moves from upper Gap to lower Gap, the strategy instantly switches sentiment from Bullish to Bearish.
- Why this matters: It prevents the strategy from trading blindly; it only trades when price is transitioning between structural levels, and price retrace to the zone drastically reducing false signals in the middle of nowhere.

2- Pin Bar Sweep + Engulfing Combo (The Momentum Trigger)
A standard pin bar alone is a weak reversal signal. A standard engulfing pattern alone is common. However, when a Pin Bar sweeps the N-bar high/low (proving a breakout attempt failed) and is immediately followed by an Engulfing pattern on the next candle, this combo represents a "double confirmation" of exhaustion.
Crucially, this specific combo overrides the EMA confirmation. 
- Why this matters: Strong momentum sweeps often happen against the short-term EMA trend. By allowing this specific combo to bypass the EMA, the strategy captures powerful reversals that pure trend-following strategies miss.

3- Dynamic Zone Width (The Volatility Adaptation)
Instead of using fixed support/resistance, the zone width changes based on the selected Period's ATR or Percentage. 

- Why this matters: This ensures the strategy scales perfectly across any asset (Gold, Crypto, Forex) without manual width adjustments, making it robust across different volatility regimes.

4- Selective Zone Activation (The Manual Override)
Unlike standard pivot systems that force trades on every level, the Zone Selection inputs allow users to disable specific zones (e.g., turn off R3 if price often fakes out there or turn off S4 market is always get exhausted lower probability trade). 

- Why this matters: This turns the strategy from a rigid algorithm into a customizable framework where the user can apply their own discretion based on historical price behavior.

5. Hierarchical EMA Architecture (The Structural Governor)

This strategy does not treat all EMAs equally. It uses a two-tier EMA system with a strict hierarchy:

Lower TF EMA (Optional & Overrideable): The Lower TF EMA on the current timeframe acts as a micro-trend filter. However, as explained above, the Pin Bar Sweep + Engulfing Combo can override this filter. Why? Because strong institutional reversals often happen against the short-term trend, and we want to capture them.

Higher TF EMA (Absolute & Non-Negotiable): Higher TF EMA on the selected Higher Timeframe  acts as an "Absolute Structural Governor." Unlike the lower EMA, this filter cannot be overridden by any pattern.

For Long entries: Price must be above this HTF EMA.

For Short entries: Price must be below this HTF EMA.

Most strategies either ignore the HTF entirely. By making the HTF EMA absolute and the LTF EMA overrideable, this strategy achieves the perfect balance:

The HTF EMA prevents catastrophic drawdowns by keeping you on the right side of the bigger trend.

The LTF EMA override allows you to catch sharp, high-probability reversals within that trend without being delayed by a slow-moving micro-filter.


6. Optional Risk Architecture (The Management Layer)

The strategy includes a built-in partial-take-profit and breakeven module. By default, this module is disabled to provide a clean, straightforward 1:3 risk-reward backtest without the complexity of multiple exit orders.
This default setting allows users to evaluate the core entry logic (zones + patterns) without interference from partial exits.
However, for traders who want to reduce psychological pressure or manage Gold's notorious retracements, they can enable Allow Breakeven and Allow Partial TP. When activated, the strategy closes a percentage of the position (e.g., 50%) at a lower R:R threshold (TP1) and moves the remaining position to breakeven—locking in early profits while letting the rest of the trade run.

# Zone Calculation

The strategy calculates 9 zones using a modified pivot point formula from the selected period (Daily, Weekly, Monthly, Quarterly, Yearly):
The pivot formula can be one of 5 methods: Classic, Fibonacci, Woodie, Camarilla, or DM.
The Classic Pivot (shown below) is the most widely used and serves as the default:

Pivot (P) = (H + L + C) / 3
R1 = (2 × P) – L
S1 = (2 × P) – H
R2 = P + (H – L)
S2 = P – (H – L)
(R3, R4, S3, S4 are logical extensions of this same principle)

Additional Methods (Briefly Explained):

Fibonacci: Uses the golden ratio multipliers (0.382, 0.618, 1.000, 1.618) to place support/resistance levels between the pivot and the high/low range.

Woodie: Gives extra weight to the closing price (Formula: P = (H + L + 2C) / 4), making it more sensitive to the current session's momentum.

Camarilla: Uses multipliers based on the previous range to place levels very close to the current price, ideal for range-bound trading and scalping.

DM: Adjusts the pivot formula conditionally based on whether the close was higher or lower than the open, making it adaptive to daily sentiment.

From these, the strategy derives:

- 4 Resistance Zones (R4, R3, R2, R1) – above the pivot
- 1 Pivot Zone (P)
- 4 Support Zones (S1, S2, S3, S4) – below the pivot

Each zone is expanded by a Zone Width to create a buffer, making the levels more practical.


# Zone Width Calculation

Three modes:

- Percentage – zone width as a percentage of current price 
- ATR Multiplier – width = ATR × Multiplier 
- Fixed – fixed price distance 



# Gap Index Mapping (0–9):

Gap 0 – Above R4 → Aggressive (no trades)
Gap 1 – Between R4 and R3 → Bearish near R4, Bullish near R3
Gap 2 – Between R3 and R2 → Bearish near R3, Bullish near R2
Gap 3 – Between R2 and R1 → Bearish near R2, Bullish near R1
Gap 4 – Between R1 and Pivot → Bearish near R1, Bullish near Pivot
Gap 5 – Between Pivot and S1 → Bearish near Pivot, Bullish near S1
Gap 6 – Between S1 and S2 → Bearish near S1, Bullish near S2
Gap 7 – Between S2 and S3 → Bearish near S2, Bullish near S3
Gap 8 – Between S3 and S4 → Bearish near S3, Bullish near S4
Gap 9 – Below S4 → Aggressive (no trades)

Based on the gap index and price action, the strategy sets allowLong or allowShort – and displays the status on the info table.

Market Status Displayed:

- Bullish – near support zones; long trades allowed
- Bearish – near resistance zones; short trades allowed
- Waiting – new period started; zones recalculating; no trades
- Aggressive – above R4 or below S4; no trades
- Zone disabled – manually disabled zone; no trades



# Entry Signals

1. Engulfing Patterns
Detects bullish and bearish engulfing with filters:

- Body Only – if true, only bodies must engulf (not full range)
- Min/Max Range – can be Percentage, ATR Multiplier, or Fixed
- Gap Allowance – max price gap between previous close and current open 
- Previous or Prior Candle – at least one of the last two candles must be the opposite. color (bearish for bullish engulf; bullish for bearish engulf).
This is not a random condition. The strategy only considers trades when price is near a strong structural zone (support/resistance). Because the zone itself provides the primary context for a potential reversal, the immediate previous candle does not need to be strictly opposite in color.By relaxing the requirement to "at least one of the last two," the strategy captures valid reversals at key levels that a strict, textbook rule would miss—while remaining highly selective because it only trades near strong zones.

2. Pin Bar + Engulfing Combo (EMA Override)
Identifies hammers/shooting stars with:

- Wick/Body Ratio (Wick 3× body)Requires a clearly defined pin bar with a very small body.

- Max Body/Range (Body is at most 20% of range) Ensures the body is genuinely small relative to the total range. This is the textbook definition of a pin bar/hammer. Captures true rejection candles.

- Min Wick/Range (70% of range) This is the classic pin bar definition. A 70%+ wick means price aggressively rejected the level and reversed.

- Sweep Lookback – bullish pinbar must break the lowest low of the previous N bars;
bearish must break the highest high 

a pin bar that sweeps a recent extreme (lookback) and the very next candle forms an engulfing pattern in the same direction. This combo overrides the Lower TF EMA confirmation – a unique feature that captures strong momentum after a sweep.


Combined Entry Requirements
All of the following must be true:

1. Valid engulfing or pin+engulf combo
2. Pattern occurs near a zone (open inside zone boundaries or crossing it)
3. Market status aligns with trade direction
4. Daily trade limit not exceeded (default: 2)
5. Relevant zone is enabled
6. Price is on the correct side of EMAs (unless overridden by combo)
7. HTF EMA confirms (if enabled)
8. RSI not overbought/oversold (if enabled)
9. Not within the no‑trade window (if enabled)

-----------------------------------------------------
# Confirmation Filters

Current TF EMA – ensures micro‑trend alignment. Overridden by pin+engulf combo.

Higher TF EMA (default 150 on 1H) – filters out counter‑trend moves in the bigger picture.

RSI – prevents buying above 70 and selling below 30.

Bollinger Bands – blocks trades when volatility is too low (BB width below threshold).This filter is specifically designed for assets that range heavily—choppy, sideways markets.

No‑Trade Window – avoids end‑of‑day volatility (active only for timeframes ≤15min).

# Risk & Position Management

1- Position Sizing:

- Risk per trade – percentage of equity for first trade, separate for second 

- Position size = (Account Risk) / (Entry – SL distance).

- Second trade does not increment the daily trade counter:
This is a deliberate design choice. The daily trade counter tracks new trade initiations, not total positions. The second trade (pyramiding) is considered a continuation of the existing position, not a new independent decision. This ensures the strategy can scale into strong trends without consuming the daily limit, while still respecting the maximum number of new entries per session.

2-Stop Loss Options:

- Low-High – entry bar low/high ± buffer Tight, reactive stops. Best for scalping or when you want the SL to follow the immediate price action of the entry candle.

- Swing high/low – N-bar low/high ± buffer Broader, structural stops. Ideal for swing trading or when you want the SL to respect recent market structure rather than a single bar.

- Zone – zone boundary ± buffer Structural stops aligned with pivot levels. Best when you want the SL to be placed exactly at the structural support/resistance level that defines the trade.

- Fixed distance – fixed price distance Simple, static stops. Useful when you know your exact risk tolerance in dollar/pip terms and want a consistent SL distance regardless of volatility.

- ATR Multiplier – entry ± (ATR × multiplier) Volatility-adaptive stops. Best for Gold's changing volatility—widens during news/high volatility, tightens during calm periods.

3- Take Profit:

- Main R:R ratio – main R:R ratio (default 1:3), plus optional partial TP and breakeven at a lower R:R ratio.
- Partial TP – close a percentage of position at a lower R:R (TP1) 
- Breakeven – optionally move stop to entry at TP1

4- Trade Counter Reset:

- For TF ≤ 15m: resets at NY (9:30 AM) and London (3:30 AM) starts (configurable)
This aligns with Gold's session-specific volatility and allows fresh participation in each session while preventing over-trading within a single session.

- For TF > 15m: resets once per day at session start (Every new day) Session-specific behavior is less relevant on higher timeframes, and a simple daily cap is more appropriate for swing trading.

5- No‑Trade Window:

- Avoids high‑volatility periods (e.g., end of day)
- Active only for TF ≤ 15m (16:00 PM – 18:30 PM NY time, configurable) End-of-day volatility spikes can cause excessive slippage and erratic price action on short timeframes. on TF > 15 The window is too short to be meaningful; higher timeframe traders are less affected by brief volatility spikes. 

6- Session Close:

- TF ≤ 15m: can close at day end and/or week end (configurable). Scalping trades on 1m–15m charts typically last minutes to a few hours. These trades are highly sensitive to Overnight gaps, Weekend gaps  

- 15m < TF ≤ 10h: only week end. Swing trading on 30m–4H charts typically lasts hours to several days.

- TF > 10h: feature disabled. Position trading on daily+ charts lasts days to weeks. These trades aim to capture large macro moves.



# Chart Display

- Zone boxes – semi‑transparent red/pink with labels (R4…S4), auto‑cleanup (max 55 periods)
- Trade management lines – entry (white), SL (red), TP (green), TP1/breakeven (dashed),
with green/red fills; auto‑cleanup ((4) * max 125)
- Info table (top‑right) :
 1. shows Market Status(Bullish/Bearish/Aggressive/Waiting). 
 2. EMA confirmations.
 3. Zone Width, Breakout threshold. 
 4. Engulf range max min.
 5. SL settings(SL refrence, sL bufer)
- EMA plots – light blue (lower TF) and light red (higher TF)
- Signal shapes – hidden by default (can be enabled via style settings)
- arrowdown shapes - "Reset trade counter" 
- Background 1 color – yellow during no‑trade window
- Background 2 color – white close all position on week/day end.
 
UI Note: Inputs are hidden from the status line to keep your chart clean. All settings (zones, EMAs, risk, patterns) remain fully adjustable in Settings → Inputs.

# Default Settings – Optimized for XAUUSD (Gold)

All default values have been calibrated specifically for Gold's typical volatility and intraday structure.

(Setting   :    Default      :  Why This Works for Gold)
----------------------------------------------------------------------------------------
Period     :  Daily  :    Gold respects daily highs/lows as key structural levels.

-----------------------------------------------------------------------------------------
Pivot Type     :    Classic    :   Most widely used and reliable for Gold.

-----------------------------------------------------------------------------------------
Zone Width     :  ATR (0.053× ATR(14)) :    ATR(14) provides a stable, week-to-week view of Gold's volatility (roughly two trading weeks of data).Adapts to Gold's daily volatility (Zone Width often $4–$10 range).

-----------------------------------------------------------------------------------------
Breakout Threshold :  7% of zone width  : Zone width ≈ $3.00–$10.00 (Daily ATR × 0.053). 7% ≈ $0.21–$0.70 (21–70 ticks)—filters noise wicks, captures genuine breaks.Prevents false transitions caused by standard stop-hunting wicks
-----------------------------------------------------------------------------------------
Engulfing Range    :   ATR(14) (0.375× – 2.5×)   :   ATR(14) sits in the "sweet spot"—responsive enough to capture shifts in Gold's volatility relatively quickly, yet long enough to smooth out the daily noise and provide a reliable, consistent measure. Captures meaningful moves $3–$15—ensures candle has enough size to be meaningful, rejecting tiny $0.30–$0.50 noise patterns, while filtering out massive blow-off spikes (> $20–$25 on 15m).

-----------------------------------------------------------------------------------------
Pin Bar Sweep       :  12 bars   :  12 bars – Calibrated for Gold's 3-hour intraday cycle and session transitions. Long enough to capture genuine liquidity grabs, short enough to avoid outdated levels. 

-----------------------------------------------------------------------------------------
Risk per trade  :  2% (1st), 1% (2nd)   :  Balances risk with Gold's occasional false breakouts. For Gold's volatile nature, 2%-1%  provides the best balance between survival and growth.
-----------------------------------------------------------------------------------------
Risk:Reward   :    1:3    :  Gold routinely moves 1.5–2× its ATR in a single directional push. A 1:3 target is well within Gold's typical daily range.

-----------------------------------------------------------------------------------------
Stop-Loss Reference    : ATR Multiplier :    For Gold's volatile nature, a static stop-loss (Fixed or Low-High) cannot adapt to changing volatility. ATR-based SL scales with market conditions—widening during high volatility (news, session opens) and tightening during calm periods. This ensures the stop-loss is always "fair" relative to current market conditions, preventing premature stops during normal volatility spikes

-----------------------------------------------------------------------------------------
Stop-Loss Multiplier    : 1.8× ATR(14)    :    A 1.8× ATR(14) stop-loss represents 1.8 times Gold's average 14-period range.  Why 1.8× and not 2.0× or 1.5×? Backtesting revealed that 1.8× is the "sweet spot"—wide enough to survive Gold's normal volatility spikes without being stopped out by noise, yet tight enough to limit losses 

-----------------------------------------------------------------------------------------
Current TF EMA   :  21 (Enabled, Overrideable)   : On 15m chart = 5.25 hours—perfectly captures Gold's average intraday move length. Can be overridden by Pin Bar + Engulfing Combo to catch institutional reversals that occur against the short-term trend.
-----------------------------------------------------------------------------------------

Higher TF EMA    :  150 on 1H  :     On Gold, a 150-period EMA on a 1H chart represents roughly 6.5 days (one full trading week) of data. By making this filter absolute, the strategy guarantees it will never take a counter-trend trade against the weekly macro-structure.trend.

-----------------------------------------------------------------------------------------
Filter (RSI)    :    length 12    :    Most traders default to RSI(14), but RSI(12) is intentionally faster for Gold's volatile intraday moves. Gold often spikes into overbought/oversold territory and reverses quickly. A 12-period RSI reacts ~15% faster than RSI(14), catching these reversals earlier while remaining smooth enough to avoid excessive whipsaws.

-----------------------------------------------------------------------------------------
 Filter (Bollinger Bands)    :    Disabled by default    :    Gold is historically a trending asset with strong directional moves. A low-volatility filter would unnecessarily block valid entries during these trends. Designed for range-bound assets (choppy crypto, certain forex crosses)—enable it only if your market consolidates heavily.
-----------------------------------------------------------------------------------------

These values are a starting point – you may adjust them for other assets or personal risk tolerance.

# Important Notes on Backtest Realism

 - Commission  – Most ECN/raw-spread brokers charge $3.00–$3.50 per side (round-turn commission of $6.00- $7.00) for 1 standard lot (100 oz) of XAUUSD. Standard accounts usually build the fee into a wider spread instead of charging a separate cash. This strategy deducts $3.50 per entry and $3.50 per exit ($0.035 × 100 oz)round-turn commission of  $7.00. Adjust this  to match your broker's exact fees.

- 4 ticks Slippage - For XAUUSD, 1 tick = $0.01 per ounce. 4 ticks = **$0.04 per ounce (unit)**. Accounts for real-world price . Prevents overly optimistic backtest equity curves.

Always adjust the commission value to your broker's exact fee structure before relying on the results.

"A backtest without realistic commission and slippage is a fantasy. A backtest with realistic commission and slippage is a truthful reflection of what you can expect when trading live."

- Intra-Bar Execution: The strategy uses calc_on_every_tick = true, meaning it recalculates on every price tick during real-time trading. This allows the breakeven and partial TP logic to trigger immediately when price hits TP1, protecting the trade from intra-bar reversals.

Note: Backtests use OHLC data only, so intra-bar fills and breakeven triggers cannot be perfectly simulated. Real-time performance may differ from backtest results due to this limitation

 # The Core Innovation (Why This Isn't Just a Mashup)
This strategy is built on a three-layer validation system. Each layer solves a specific problem that the other layers cannot solve alone.

Layer 1 (The Structure): Dynamic Pivot Zones
Layer 2 (The Trigger): Pin-Bar Sweep + Engulfing Combo
Layer 3 (The Execution): Gap State Machine

Here is how they interdepend to create a unique edge:

1.  Adaptive Pivot Mathematics (The "Regime Matching" Logic)
Instead of offering multiple pivot types just for the sake of it, this strategy provides them so the trader can match the mathematical formula to the market's current behavioral regime:

Why this matters: Most strategies lock you into one formula. This strategy acknowledges that price dynamics change, and it gives you the mathematical weapon to adapt without rewriting the entire code.

2.  The "Liquidity Grab" Trigger (Sweep + Engulfing Combo)
This is the most critical edge of the strategy. A standard Engulfing pattern is common. A standard Pin Bar is common. But when they occur sequentially—a Pin Bar that sweeps the 12-bar extreme, immediately followed by an Engulfing candle—it represents a textbook institutional "liquidity grab."

- The Logic: Large players often push price to sweep obvious stop-losses (above highs or below lows) before reversing the trend.

- The Override: Crucially, this specific combo overrides the Lower TF EMA confirmation.

- Why this is a breakthrough: Standard trend-following strategies with a hard EMA filter will miss these reversals because price is moving against the EMA in the short term. By programming this specific override, the strategy captures the exact moment of institutional reversal—catching the move before the EMA flips and the trend-followers finally enter.

3.  The Gap State Machine (Dynamic Sentiment Tracking)
Unlike static support/resistance scripts that just plot lines and wait for touches, this strategy features a state machine that tracks which of the 9 gaps (between R4-R1, Pivot, S1-S4) the price currently occupies.

- The Mechanism: A Breakout Threshold (default 7% of zone width) acts as a "dead-zone" filter. Price must exceed this threshold to officially transition from one gap to another.

- The Alpha: This prevents the strategy from whipsawing during minor noise. When price crosses from Gap 4 (between R1 and Pivot) into Gap 3 (between R2 and R1), the strategy instantly and autonomously switches market status from "Bearish" to "Bullish" or vice versa. 

4. Selective Zone Activation (Strategic Discretion)
 - This strategy allows the user to completely disable specific zones (e.g., turn off R3).

- The Value: By disabling a weak level, the user forces the strategy to wait for the next stronger level, instantly increasing the win rate and filtering out historically weak signals without altering any other code.

5. Non-Invasive Risk Architecture (Clean Defaults)

For traders who want to reduce psychological pressure or optimize for Gold's notorious retracements, they can enable these modules. When activated, the strategy closes % of the position at a lower R:R threshold and moves the remaining position to breakeven—locking in profits while letting the rest run.

In Summary: The "Mashup" Justification
This is not a random collection of indicators.

1. The State Machine provides the structural context.

2. The Pin+Engulf combo provides the high-conviction trigger that overrides slow-moving filters.

3. The Selectable Pivot Types provide the mathematical adaptability to different assets.

4. The Selectable Zones provide the manual discretion to avoid historical losing levels.

5. The Disabled TP/BE by default provides a clean baseline for evaluating the core logic.

Author: Awab_Hassan

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Awab_Hassan

//@version=6
strategy("Zone Flow S/R Strategy",
         overlay = true, margin_short = 0 , 
         margin_long = 0, pyramiding = 2, 
         close_entries_rule = "ANY", use_bar_magnifier = false, 
         process_orders_on_close = false, max_bars_back = 500, 
         max_lines_count = 500, max_boxes_count = 500, 
         max_labels_count = 500, calc_on_every_tick = true, 
         initial_capital = 10000, commission_type = strategy.commission.cash_per_contract, 
         currency = "USD",
         commission_value = 0.035 , slippage = 4)

// Inputs
//Historical data to keep on chart--------------------------------------------------------------------Historical data to keep on chart--------------------------------------------------------------------Historical data to keep on chart-------------------------------------------------------------------------------------------------------
max_days        = input.int      (33,               "   Historical Period",                     minval=1 ,      maxval=55,      step=1,         group="Historical data to keep on chart",                   display=display.none,                                               tooltip="Number of historical Period zones to show. (max 55).\n\nAll default values below are calibrated for XAUUSD (Gold) on 15m. See doc")
trades_to_keep  = input.int      (111,              "   Historical Trades",                     minval=1,       maxval=125,     step=1,         group="Historical data to keep on chart",                   display=display.none,                                               tooltip="Number of historical trades to keep on the chart. (max 125)")

//------------Zones Settings----------------------------------------------Zones Settings--------------------------------------------------------------Zones Settings----------------------------------------------------------Zones Settings---------------------------------------------Zones Settings-----------------------------------------------------
pivotPeriod     = input.string   ("Daily",          "   Period",                options=["Daily", "Weekly", "Monthly", "Quarterly", "Yearly"],  group="Zones Settings",                                                                                                         tooltip="Pivot timeframe for zone generation. \nHigher periods produce broader, more significant structural levels.")
TypePeriod      = input.string   ("Classic",        "   Type",                  options=["Classic", "Fibonacci", "Woodie (Extended)", "Custom Camarilla", "DM"],  
                                                                                                                                                group="Zones Settings",                                                                                                         tooltip="Pivot calculation method.")

zoneWidthMode   = input.string   ("ATR Multiplier", "   Zone Width Mode",               options=["Percentage", "ATR Multiplier", "Fixed"],      group="Zones Settings",                                     display=display.none,                                               tooltip="How to calculate Width of Zone requirements.")

ZoneatrLength   = input.int      (14,               "   Zones ATR Length",                      minval=1, step=1,                               group="Zones Settings",                                     display=display.none, active=(zoneWidthMode=="ATR Multiplier"),     tooltip="ATR length from the selected Period above.\nFor example, if Period is 'Daily', this uses the Daily ATR.")
zoneATRMultip   = input.float    (0.053,            "   Zone width ATR Multiplier",             minval=0.0000001, maxval=50.0,  step=0.1,       group="Zones Settings",                                     display=display.none, active=(zoneWidthMode=="ATR Multiplier"),     tooltip="Width of Zone as multiple of ATR.")
zoneWidthPct    = input.float    (0.12,             "   Zone width (%)",                        minval=0.0000001, maxval=50.0,  step=0.001,     group="Zones Settings",                                     display=display.none, active=(zoneWidthMode=="Percentage"),         tooltip="Width of Zone as percentage of current price")
zoneWidthFixed  = input.float    (5.5,              "   Zone width (Fixed)",                    minval=0,                                       group="Zones Settings",                                     display=display.none, active=(zoneWidthMode=="Fixed"),              tooltip="Fixed Width of Zone in price units")

ThresholdPct    = input.float    (7,                "   Breakout threshold (%)",                minval=0,                       step=0.0001,    group="Zones Settings",                                     display=display.none,                                               tooltip="Percentage of zone width to determine the breakout threshold.\n\nMinimum distance price must exceed beyond a zone's top/bottom to trigger a zone transition and switch direction (e.g., from Sell to Buy or from Buy to Sell).\nPrevents false triggers on minor move.")
//Zoffset         = input.int      (1,                "   Price Offset (bars)",                   minval=0,         maxval=10,    step=1,         group="Zones Settings",                                     display=display.none,                                               tooltip="Number of bars to look back when checking price relative to zones.\n\nDefault = 1 uses the previous bar's close. This gives the zone logic a stable reference.\n\nSet to 0 to use the current bar's close (more sensitive to real‑time moves).")
// Engulf settings-------------------------------------------------------------Engulf settings ----------------------------------------------------------------------------Engulf settings ------------------------------------------------------Engulf settings ------------------------------------------------Engulf settings ---------------------------------------------------------------------------------------------------- 
engulfBodyOnly  = input.bool     (true,             "Engulfing: Body only",                                                                     group="Candlestick Settings (Engulf)",                      display=display.none,                                               tooltip="If true, only body must engulf. If false, full range (high/low) must engulf.")
engulfMode      = input.string   ("ATR Multiplier", "   Engulf Range Mode",             options=["Percentage", "ATR Multiplier", "Fixed"],      group="Candlestick Settings (Engulf)",                      display=display.none,                                               tooltip="How to calculate engulfing candle range requirements.\nSmaller timeframes (1m-5m) typically need smaller values ; larger TFs (30m-4h) need bigger values.\n\nHelps filter out small, low-volatility engulfing patterns while adapting to market conditions.")

// Engulf Percentage mode------------------------------------------------------Engulf Percentage mode--------------------------------------------------Engulf Percentage mode---------------------------------------------------------Engulf Percentage mode------------------------------------------------------Engulf Percentage mode---------------------------------------------------------------------------------------------
engulfPct       = input.float    (0.112,            "   Engulf: Min Range (%)",                 minval=0.000001,maxval=50.0,    step=0.001,     group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="Percentage"),            tooltip="Minimum engulfing candle range as percentage of current price")
maxEngulfPct    = input.float    (0.55,             "   Engulf: Max Range (%)",                 minval=0.000001,maxval=200.0,   step=0.001,     group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="Percentage"),            tooltip="Maximum engulfing candle range as percentage of current price")

// Engulf ATR mode--------------------------------------------------------------Engulf ATR mode---------------------------------------------------------------Engulf ATR mode---------------------------------------------------------------Engulf ATR mode---------------------------------------------------------------Engulf ATR mode-------------------------------------------------------------------------------------  
EngulfatrLength = input.int      (14,               "   Engulf: ATR Length",                    minval=2,                                       group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="ATR Multiplier"),        tooltip="Uses the ATR of the current chart timeframe." )
engulfATR       = input.float    (0.375,            "   Engulf: Min ATR Multiplier",            minval=0.000001,maxval=50.0,    step=0.1,       group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="ATR Multiplier"),        tooltip="Minimum range as multiple of ATR")
maxEngulfATR    = input.float    (2.5,              "   Engulf: Max ATR Multiplier",            minval=0.000001,maxval=200.0,   step=0.1,       group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="ATR Multiplier"),        tooltip="Maximum range as multiple of ATR")

// Engulf Fixed mode--------------------------------------------------------------Engulf Fixed mode-------------------------------------------------------------- Engulf Fixed mode-------------------------------------------------------------- Engulf Fixed mode--------------------------------------------------------------Engulf Fixed mode-------------------------------------------------------------- -                                                               Fixed mode                                                                   Fixed mode
engulfFixed     = input.float   (3.8,               "   Engulf: Min Range (Fixed)",             minval=0,                                       group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="Fixed"),                 tooltip="Fixed minimum range in price units")
maxEngulfFixed  = input.float   (25,                "   Engulf: Max Range (Fixed)",             minval=0,                                       group="Candlestick Settings (Engulf)",                      display=display.none, active=(engulfMode=="Fixed"),                 tooltip="Fixed maximum range in price units")

// Pin Bar settings-------------------------------------------------------------Pin Bar settings------------------------------------------------------------- Pin Bar settings------------------------------------------------------------- Pin Bar settings------------------------------------------------------------- Pin Bar settings-------------------------------------------------------------                                                               // Pin Bar settings                                                    // Pin Bar settings                                                                             // Pin Bar settings                                                                                                                                      
pinWickRatio    = input.float   (3.0,               "   Pin Bar: Wick / Body Ratio",            minval=1.0,                     step=0.1,       group="Candlestick Settings (Pin Bar)",                     display=display.none,                                               tooltip="Minimum ratio of the longer wick to the body size.\n\nPinbar must sweeps the N-bar high/low and FOLLOWED by an engulfing pattern on the next bar to considered valid.")
pinBodyMax      = input.float   (0.20,              "   Pin Bar: Max Body / Range",             minval=0.0,     maxval=1.0,     step=0.05,      group="Candlestick Settings (Pin Bar)",                     display=display.none,                                               tooltip="Maximum body size relative to the total range (high-low).")
pinWickMin      = input.float   (0.70,              "   Pin Bar: Min Wick / Range",             minval=0.0,     maxval=1.0,     step=0.05,      group="Candlestick Settings (Pin Bar)",                     display=display.none,                                               tooltip="Minimum length of the longer wick relative to total range.")
SweepLookback   = input.int     (12,                "   Pin Bar Sweep Lookback (bars)",         minval=1,       maxval=500,     step=1,         group="Candlestick Settings (Pin Bar)",                     display=display.none,                                               tooltip="Number of bars to look back for the sweep condition.\n\nA bullish pinbar must have its low below the lowest low of this many previous bars.\nA bearish pinbar must have its high above the highest high of this many previous bars.")
// Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------                                                                    Gap & previous Range                                                             Gap & previous Range 
gapAllowance    = input.int     (15,                "   Gap Allowance (ticks)",                 minval=0,                       step=1,         group="Candlestick Settings (Gap)",                         display=display.none,                                               tooltip="Maximum allowed price gap in the direction that invalidates the pattern.\n\nFor a bullish engulf:\n- Limits how far the current OPEN can be ABOVE the previous CLOSE (prevents invalid upward gaps).\n- Downward gaps (current open below previous close) are ALWAYS allowed.\n\nFor a bearish engulf:\n- Limits how far the current OPEN can be BELOW the previous CLOSE (prevents invalid downward gaps).\n- Upward gaps (current open above previous close) are ALWAYS allowed.")

//------------Risk & Reward Settings -------------------------------------------------------------------------------------------------Risk & Reward Settings-------------------------------------------------------------------------------------------------Risk & Reward Settings--------------------------------------------------------------------------------------------------------------
maxTrades       = input.int     (2,                 "   Maximum number of trades per session",  minval=1,       maxval=10,      step= 1,        group="Risk & Reward Settings",                             display=display.none,                                               tooltip="")
ResetTC_freqly  = input.bool    (true,              "Reset trade counter at NY & LON start",                                                    group="Risk & Reward Settings",                             display=display.none,                                               tooltip="The trade counter reset frequency adapts to selected timeframe. \n\nFor timeframes of 15 minutes or less, the counter resets at the beginning of each major session (First bar of new day, London, and New York) to capitalize on intra-session volatility. \n\nNot valid for timeframes greater than 15 minutes, the counter resets only once per day at the daily session start(First bar of new day).")
NY_h            = input.int     (9,                 "     NY Start Time  :"  + "   Hour",       minval=0,       maxval=23,                      group="Risk & Reward Settings", inline="NY_start",          display=display.none, active=ResetTC_freqly,                        tooltip="")
NY_m            = input.int     (30,                "  Min",                                    minval=0,       maxval=59,                      group="Risk & Reward Settings", inline="NY_start",          display=display.none, active=ResetTC_freqly,                        tooltip="(NY time zone) \nReset tradeCounter on New_York session start time")
LON_h           = input.int     (3,                 "     LON Start Time :" + "   Hour",        minval=0,       maxval=23,                      group="Risk & Reward Settings", inline="LON_start",         display=display.none, active=ResetTC_freqly,                        tooltip="")
LON_m           = input.int     (30,                "  Min",                                    minval=0,       maxval=59,                      group="Risk & Reward Settings", inline="LON_start",         display=display.none, active=ResetTC_freqly,                        tooltip="(NY time zone) \nReset tradeCounter on London session start time")
riskTradepct1   = input.float   (2,                 "   Risk per trade (%)",                                                    step=0.01,      group="Risk & Reward Settings",                             display=display.none,                                               tooltip="Risk percentage per. (strategy.equity * (Risk per trade / 100.0))")
risk_reward     = input.float   (3,                 "   Risk to Reward Ratio",                  minval=0.1,                     step=0.01,      group="Risk & Reward Settings",                             display=display.none)
BarsNewEntries  = input.int     (4,                 "   Min bars between entries",              minval=0,       maxval=50,      step=1,         group="Risk & Reward Settings",                             display=display.none,                                               tooltip="Minimum number of bars that must pass between consecutive entries.\n\nPrevents multiple entries on the same bar or too close together.\nSet to 0 to allow entries on consecutive bars.\n\nThis applies to both long and short entries.")

//---------------------------------second trade-------------------------------------------second trade-----------------------------------------------------second trade------------------------------    
allow_two_trade = input.bool    (true,              "Allow second trade",                                                                       group="Risk & Reward Settings - 2nd Trade",                 display=display.none,                                               tooltip="Allow another trade in the same direction.")
riskTradepct2   = input.float   (1,                 "   Risk per trade (%)(second trade)",      minval=0.01,    maxval=100,     step=0.01,      group="Risk & Reward Settings - 2nd Trade",                 display=display.none, active=allow_two_trade,                       tooltip="Risk per trade for a second entry (strategy.equity * (Risk per trade / 100.0)). Active when 'Allow two trade' is enabled.\n\nThis entry does not increment the session trade counter – only the first entry counts towards 'Maximum number of trades per session'")
risk_reward2    = input.float   (3,                 "   Risk to Reward Ratio (second trade)",   minval=0.5,                     step=0.01,      group="Risk & Reward Settings - 2nd Trade",                 display=display.none, active=allow_two_trade)

//  Risk & Reward Settings (Stop-Loss------------------------------------------------------------------Risk & Reward Settings (Stop-Loss------------------------------------------------------------------Risk & Reward Settings (Stop-Loss------------------------------------------------------------------Risk & Reward Settings (Stop-Loss------------------------------------------------------------------                                                                                                                          Risk & Reward Settings (Stop-Loss                                                                                           Risk & Reward Settings (Stop-Loss)-----------------------------------                                                                                                     Risk & Reward Settings (Stop-Loss
stopLoseLevel   = input.string  ("ATR Multiplier",  "   Stop-Loss Reference", options=["Low-High","Swing high/low", "Zone","Fixed distance", "ATR Multiplier"], group="Risk & Reward Settings (Stop-Loss)", display=display.none,                                               tooltip="Determines how the stop loss price is sourced.\n'Low-High' bases it on the low/high of the entry bar (+/-) Stop-loss buffer.\n\nSwing high/low Number of bars to look back for the highest high and lowest low (+/-) Stop-loss buffer.\n\n'Zone' uses the upper/lower Zone Top/Bottom (+/-) Stop-loss buffer.\n\n'fix price' lets you input a specific price distance.\n\n'ATR Multiplier' SL distance as multiple of ATR (entryprice (+/-) (SLatrValue * Stop-loss Multiplier))")

showSLfixDistance     = stopLoseLevel == "Fixed distance"
showSLATR_Multiplier  = stopLoseLevel == "ATR Multiplier"
showSLHigh_Low_swings = stopLoseLevel == "Swing high/low"
showSLofset           = not showSLfixDistance and not showSLATR_Multiplier

high_maxcont    = input.int     (10,                "   Highest price bar",                     minval=0,                       step=1,         group="Risk & Reward Settings (Stop-Loss)",                 display=display.none, active=showSLHigh_Low_swings,                 tooltip="Number of bars to look back for the highest high. This value (plus the SL buffer) sets the initial stop-loss for SHORT positions.")
low_maxcount    = input.int     (10,                "   Lowest price bars",                     minval=0,                       step=1,         group="Risk & Reward Settings (Stop-Loss)",                 display=display.none, active=showSLHigh_Low_swings,                 tooltip="Number of bars to look back for the lowest low.\nThis value (minus the SL buffer) sets the initial stop-loss for LONG positions.")
slbuf           = input.float   (0.5,               "   Stop-Loss buffer",                      minval=0,                       step=0.001,     group="Risk & Reward Settings (Stop-Loss)",                 display=display.none, active=showSLofset,                           tooltip="Adds a safety buffer below low (for longs) or above high (for shorts) to prevent stop-loss from being triggered by minor wicks, spread, or market noise.")
SLfixDistance   = input.float   (20,                "   Stop-Loss distance",                    minval=0.001,                   step=0.001,     group="Risk & Reward Settings (Stop-Loss)",                 display=display.none, active=showSLfixDistance,                     tooltip="Sets the stop loss price when 'Fixed distance' is chosen as the SL reference. Enter a price distance from entry.")
SLatrLength     = input.int     (14,                "   Stop-Loss ATR Length",                  minval=2,                                       group="Risk & Reward Settings (Stop-Loss)",                 display=display.none, active=showSLATR_Multiplier,                  tooltip="Uses the ATR of the current chart timeframe")
SLatrMultiplier = input.float   (1.8,               "   Stop-Loss ATR Multiplier",              minval=0.1,                     step=0.1,       group="Risk & Reward Settings (Stop-Loss)",                 display=display.none, active=showSLATR_Multiplier,                  tooltip="Stop-Loss distance as multiple of ATR")

//Manage Risk-----------------------------------------------------------------Manage Risk---------------------------------------------------------------Manage Risk-----------------------------------------------------------------------Manage Risk--------------------------------------------------------------Manage Risk---------------------------------------------
Tp_division     = input.bool    (false,              "Allow Partial TP   ",                                                 inline="Tp_division",group="Manage Risk - Partial TP & Break even",             display=display.none,                                               tooltip="Allow Partial TP: closing part of the trade at (Risk to Reward Ratio for TP1).\n\nAllow Break even: move stop loss to breakeven when reaching (Risk to Reward Ratio for TP1).")
breakeven       = input.bool    (false,             "Allow Break even",                                                    inline="Tp_division",group="Manage Risk - Partial TP & Break even",              display=display.none)
risk_reward_BE  = input.float   (2,                 "   Risk to Reward Ratio for TP1",          minval=0.1,                     step=0.1,       group="Manage Risk - Partial TP & Break even",              display=display.none, active=breakeven or Tp_division)
tp_pct          = input.float   (50,                "   close % of the position at TP1",        minval=0,       maxval=100,     step=10,        group="Manage Risk - Partial TP & Break even",              display=display.none, active=Tp_division,                           tooltip="Closing percentage of the position when (Risk to Reward Ratio for TP1) is triggered.")

closeDayWeekEnd = input.bool    (true,              "Close Trades Before Week/Dayend",                                                          group="Manage Risk - Week/Dayend closing",                  display=display.none,                                               tooltip="Executes trade exits at the opening of the last candle before the daily or weekly session ends.\n\nRules based on chart timeframe (TF):\n• TF ≤ 15m → Day & Week end active.\n• 15m < TF ≤ 10h → Week end only active (Day end disabled).\n• TF > 10h → Feature completely disabled.\n\n⚠️ Does NOT include early market closings.")
closeonDayEnd   = input.bool    (false,             "Close on Dayend",                                                     inline="DialyClose", group="Manage Risk - Week/Dayend closing",                  display=display.none, active=closeDayWeekEnd,                       tooltip="")
closeonWeekEnd  = input.bool    (true,              "Close on Weekend",                                                    inline="DialyClose", group="Manage Risk - Week/Dayend closing",                  display=display.none, active=closeDayWeekEnd and not closeonDayEnd, tooltip="")
TradeEndHour    = input.int     (17,                "      Day End Time :" + "  Hour",          minval=0,       maxval=23, inline="time_end",   group="Manage Risk - Week/Dayend closing",                  display=display.none, active=closeDayWeekEnd)
TradeEndMin     = input.int     (00,                "  Min",                                    minval=0,       maxval=59, inline="time_end",   group="Manage Risk - Week/Dayend closing",                  display=display.none, active=closeDayWeekEnd ,                      tooltip="Set the official End-of-Day (EOD) closing time. Must be in New York time zone.")

//Manage Risk no trades win -----------------------------------------------------------------Manage Risk no trades win -----------------------------------------------------------------Manage Risk no trades win -----------------------------------------------------------------
activNoTradeWin = input.bool    (true,              "Enable No-Trades Window",                                                                  group="Manage Risk - No Trade Windows",                                                                                         tooltip="Prevents trading during high volatility, end of the day, excessive slippage periods. \nWhen enabled, trading will be blocked during specified time window.\n\n⚠️ This (No-Trades Window) is only valid when the timeframe is 15 minutes or less (timeframe ≤ 15m).")
noTradeStartH1  = input.int     (16,                "       Time Start :" + "    Hour",         minval=0,       maxval=23, inline="win_start",  group="Manage Risk - No Trade Windows",                     display=display.none, active=activNoTradeWin,                       tooltip="")
noTradeStartM1  = input.int     (00,                "  Min",                                    minval=0,       maxval=59, inline="win_start",  group="Manage Risk - No Trade Windows",                     display=display.none, active=activNoTradeWin,                       tooltip="(NY time zone) \nno-trades window start time (start at the end of the day by default)")
noTradeEndH1    = input.int     (18,                "       Time End  :"  + "    Hour",         minval=0,       maxval=23, inline="win_end",    group="Manage Risk - No Trade Windows",                     display=display.none, active=activNoTradeWin,                       tooltip="")
noTradeEndM1    = input.int     (30,                "  Min",                                    minval=0,       maxval=59, inline="win_end",    group="Manage Risk - No Trade Windows",                     display=display.none, active=activNoTradeWin,                       tooltip="(NY time zone) \nno-trades window end time (end 30m after opening by default)")

//--Filter Settings (EMA)---------------------------------------------------Filter Settings (EMA)--------------------------------------------------------Filter Settings (EMA)---------------------------------------------Filter Settings (EMA)-------------------------------------------------Filter Settings (EMA)-----------------------------------------
allowEMAConf    = input.bool    (true,              "Allow EMA confirmation",                                                                   group="Filter Settings (EMA)",                              display=display.none,                                               tooltip="Requires EMA alignment to confirm the move.\n\nEXCEPTION: If a pinbar sweeps the Number-bars (Pin Bar Sweep Lookback) high/low and is IMMEDIATELY FOLLOWED by an engulfing pattern on the next bar, this sequential combo counts as the required 'two confirmations', overriding the EMA filter.")
lenofEMA        = input.int     (21,                "   EMA length",                            minval=1,                       step= 1,        group="Filter Settings (EMA)",                              display=display.none, active=allowEMAConf,                          tooltip="The length of the EMA.")
src1            = input         (close,             "   Source",                                                                                group="Filter Settings (EMA)",                              display=display.none, active=allowEMAConf)
offsetlower     = input.int     (0,                 "   Offset",                                minval=-500,    maxval=500,     step= 1,        group="Filter Settings (EMA)",                              display=display.none, active=allowEMAConf)

allowHT_EMAConf = input.bool    (true,              "Allow Higher Timeframe EMA confirmation",                                                  group="Filter Settings (EMA)",                              display=display.none,                                               tooltip="Enables the Higher Timeframe EMA confirmation filter.\nTrades are only allowed if they align with the trend defined by the HTF EMA value.")
HT_Input        = input.string  ("1H",              "   Higher timeframe",
                                                         options=["1m","5m","10m","15m","30m","1H","2H","4H","8H","1D","1W","1M","3M","1Year"], group="Filter Settings (EMA)",                              display=display.none, active=allowHT_EMAConf,                       tooltip="Higher timeframe for EMA calculation.\n\nThis EMA will reflect trends from the selected timeframe regardless of the chart's current timeframe.")
lenHTEMA        = input.int     (150,               "   Higher Timeframe EMA length",           minval=1,                       step= 1,        group="Filter Settings (EMA)",                              display=display.none, active=allowHT_EMAConf,                       tooltip="The length of the Higher Timeframe EMA.")
srcHT           = input         (close,             "   Source",                                                                                group="Filter Settings (EMA)",                              display=display.none, active=allowHT_EMAConf)
offsetHT        = input.int     (0,                 "   Offset",                                minval=-500,    maxval=500,     step= 1,        group="Filter Settings (EMA)",                              display=display.none, active=allowHT_EMAConf)

//---filtering Settings (RSI)---------------------------------------------------filtering Settings (RSI)---------------------------------------------------------filtering Settings (RSI)------------------------------------------------------filtering Settings (RSI)------------------------------------filtering Settings (RSI)----------------------------
usingRSI        = input.bool    (true,              "Use RSI (Over bought/sold)",                                                               group="Filter Settings (RSI)",                              display=display.none,                                               tooltip="Prevent trads when (overbought > 70 , oversold < 30)")
RSI_len         = input.int     (12,                "   RSI Length",                            minval=1,                       step= 1,        group="Filter Settings (RSI)",                              display=display.none, active = usingRSI)

//----Filter Settings (BB)------------------------------------------------------------Filter Settings (BB)----------------------------------------------------------------Filter Settings (BB)-----------------------------------------------------------------Filter Settings (BB)----------------------------------------------------------------------------
BB_enabled      = input.bool    (false,             "Use Bollinger Band (Low Volatility)",                                                      group="Filter Settings (BB)",                               display=display.none,                                               tooltip="Prevent trads when low volatility")
bb_len          = input.int     (20,                "   BB Length",                             minval=1,                       step=1,         group="Filter Settings (BB)",                               display=display.none, active = BB_enabled)
bb_mult         = input.float   (2.0,               "   BB Multiplier",                         minval=0.5,                     step=0.1,       group="Filter Settings (BB)",                               display=display.none, active = BB_enabled)
bbThreshold     = input.float   (0.002,             "   BB Width Threshold (below = sideways)",                                 step=0.0001,    group="Filter Settings (BB)",                               display=display.none, active = BB_enabled,                          tooltip="Lower = tighter range")

//----------Zone Selection----------------------------------------------------------------------Zone Selection------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
r1_enabled      = input.bool    (true,              "Enable at (R1)      ",                                                                     group="Zone Selection", inline="RS1",                       display=display.none, tooltip="Enable trades at R1/S1")
r2_enabled      = input.bool    (true,              "Enable at (R2)      ",                                                                     group="Zone Selection", inline="RS2",                       display=display.none, tooltip="Enable trades at R2/S2")
r3_enabled      = input.bool    (true,              "Enable at (R3)      ",                                                                     group="Zone Selection", inline="RS3",                       display=display.none, tooltip="Enable trades at R3/S3")
r4_enabled      = input.bool    (true,              "Enable at (R4)      ",                                                                     group="Zone Selection", inline="RS4",                       display=display.none, tooltip="Enable trades at R4/S4")

s1_enabled      = input.bool    (true,              "Enable at (S1)",                                                                           group="Zone Selection", inline="RS1",                       display=display.none, tooltip="")
s2_enabled      = input.bool    (true,              "Enable at (S2)",                                                                           group="Zone Selection", inline="RS2",                       display=display.none, tooltip="")
s3_enabled      = input.bool    (true,              "Enable at (S3)",                                                                           group="Zone Selection", inline="RS3",                       display=display.none, tooltip="XXXX")
s4_enabled      = input.bool    (true,              "Enable at (S4)",                                                                           group="Zone Selection", inline="RS4",                       display=display.none, tooltip="")

p_enabled       = input.bool    (true,              "Enable at (P)",                                                                            group="Zone Selection", inline="RS",                        display=display.none, tooltip="Enable trades at Pivot")

offset  = 1 // for levels calculation
Zoffset = 1 // for breakout

in_long  = strategy.position_size > 0
in_short = strategy.position_size < 0

// zones range & engulf calculation based on chosen mode
engulfatrValue = ta.atr(EngulfatrLength)
SLatrValue     = ta.atr(SLatrLength)

// zone zoneATRMultip of current timeframe
// zoneatrValue   = ta.atr(ZoneatrLength)
// zonerang       = zoneWidthMode == "Percentage" ? close * (zoneWidthPct / 100) :
//                  zoneWidthMode == "ATR Multiplier" ? zoneatrValue * zoneATRMultip : zoneWidthFixed

engulfrange    = engulfMode == "Percentage" ? close * (engulfPct / 100) :
                 engulfMode == "ATR Multiplier" ? engulfatrValue * engulfATR : engulfFixed

maxengulfrange = engulfMode == "Percentage" ? close * (maxEngulfPct / 100) :
                 engulfMode == "ATR Multiplier" ? engulfatrValue * maxEngulfATR : maxEngulfFixed  


Higher_TF = switch HT_Input
    "1m"    => "1"
    "3m"    => "3"
    "5m"    => "5"
    "10m"   => "10"
    "15m"   => "15"
    "30m"   => "30"
    "1H"    => "60"
    "2H"    => "120"
    "4H"    => "240"
    "8H"    => "480"
    "1D"    => "1440"
    "1W"    => "W" 
    "1M"    => "M"
    "3M"    => "3M"
    "1Year" => "12M"

// Time configuration
ny_tz         = "America/New_York"
currentTime   = time(timeframe.period, ny_tz)
dayOfWeek     = dayofweek(currentTime)
Timesec       = timeframe.in_seconds()
isFirstBar    = session.isfirstbar
allWeekDays   = (dayOfWeek == dayofweek.friday or dayOfWeek == dayofweek.monday or dayOfWeek == dayofweek.tuesday or dayOfWeek == dayofweek.wednesday or dayOfWeek == dayofweek.thursday or dayOfWeek == dayofweek.sunday or dayOfWeek == dayofweek.saturday)
isFriday      = (dayOfWeek == dayofweek.friday)
bar_end_time  = currentTime + (Timesec * 1000)
chartTF       = Timesec / 60 
scalping      = chartTF <= 15

// the opening time of the last bar
target_time     = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), TradeEndHour, TradeEndMin, 0) - (chartTF + 1) * 60000

// the NY session start
target_time_NY  = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), NY_h, NY_m, 0) - (chartTF) * 60000

// the LON session start
target_time_LON = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), LON_h, LON_m, 0) - (chartTF) * 60000

// the notradewin start and end
target_t_notradewin_Start = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), noTradeStartH1, noTradeStartM1, 0) - (chartTF) * 60000
target_t_notradewin_End   = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), noTradeEndH1, noTradeEndM1, 0) - (chartTF) * 60000

lastMinute  = currentTime <= target_time and bar_end_time > target_time

Close_Time  = (closeDayWeekEnd ? closeonDayEnd and scalping ? allWeekDays and lastMinute
              : closeonWeekEnd ? isFriday and lastMinute : false : false) 

isFirst15NY   = ResetTC_freqly and scalping ? currentTime <= target_time_NY and bar_end_time > target_time_NY   : false   //ResetTC_freqly ? (hour(t1, ny_tz) == NY_h) and (minute(t1, ny_tz) == NY_m)   : false
isFirst15lon  = ResetTC_freqly and scalping ? currentTime <= target_time_LON and bar_end_time > target_time_LON : false   //ResetTC_freqly ? (hour(t1, ny_tz) == LON_h) and (minute(t1, ny_tz) == LON_m) : false            

noTradesWinOn = activNoTradeWin and scalping ? currentTime >= target_t_notradewin_Start and currentTime <= target_t_notradewin_End : false 
resetTradeContr = isFirstBar or isFirst15NY or isFirst15lon


int max_boxes = max_days * 9

var int foundGapIdx     = 4
var int Todaytrades     = 0
var int tradeCounter    = 0
var int positions       = 0
var int positionallowed = 2
var int lastEntryBar    = -1

// Variables storing the levels & zones 
var float swaplevel     = na
//var float zone1         = na 
var float zone1_Top     = na 
var float zone1_Bottom  = na
//var float zone2         = na
var float zone2_Top     = na
var float zone2_Bottom  = na
//var float zone3         = na
var float zone3_Top     = na
var float zone3_Bottom  = na
//var float zone4         = na
var float zone4_Top     = na
var float zone4_Bottom  = na
//var float zone5         = na
var float zone5_Top     = na
var float zone5_Bottom  = na
//var float zone6         = na
var float zone6_Top     = na
var float zone6_Bottom  = na
//var float zone7         = na
var float zone7_Top     = na
var float zone7_Bottom  = na
//var float zone8         = na
var float zone8_Top     = na
var float zone8_Bottom  = na
//var float zone9         = na
var float zone9_Top     = na
var float zone9_Bottom  = na
var float zonerang      = na
//var float avgSpacing    = na
var float slzone        = na
var float entryPrice1   = na
var float entryPrice2   = na
var float SH1tpPrice    = na
var float L1tpPrice     = na
var float SH2tpPrice    = na
var float L2tpPrice     = na
var float long1TP1      = na
var float short1TP1     = na
var float long2TP1      = na
var float short2TP1     = na

var bool allowLong     = false
var bool allowShort    = false
var bool TP1triggered1 = false
var bool TP1triggered2 = false 

var string marketStatuse = ""
var string activeID1     = na
var string activeID2     = na
mainExitID               = "EX: " 
breakevenExitID          = "BE: "
PartialExitID            = "PL: "

// array for zone's bottom&top levels
var float[] zoneTop = array.new_float(9)   
var float[] zoneBot = array.new_float(9)

// lines entry/TP/SL
var line[] position_lines = array.new_line()

// array for Bxes
var box[] zoneBoxes = array.new_box()

var infoTable = table.new(position.top_right, 2, 9, 
                   bgcolor=color.new(#0e0e0e, 80),
                   border_color=color.rgb(255, 82, 82, 40),
                   border_width=2 
     ) 

// update which gap price is in
// find location of current price ex: between r4 & r3 foundIdx = 1, between s1 & s2 foundIdx = 6 , above r4  foundIdx = 0 , below s4  foundIdx = 9
updateGapIndex(price) =>
    int gap = 4  // default fallback (gap between R1 and Pivot)

    if price > array.get(zoneTop, 0) + swaplevel   // above R4 no trade
        gap := 0
    else if price < array.get(zoneBot, 8) - swaplevel   // below S4 no trade
        gap := 9
    else
        // Find which gap price is in
        for i = 0 to 7
            if price <= array.get(zoneBot, i) - swaplevel and price >= array.get(zoneTop, i + 1) + swaplevel
                gap := i + 1
                break
    gap

// Returns true if zone number (1..9) is enabled
isZoneEnabled(zoneNum) =>
              zoneNum == 0 ? r4_enabled :
              zoneNum == 1 ? r3_enabled :
              zoneNum == 2 ? r2_enabled :
              zoneNum == 3 ? r1_enabled :
              zoneNum == 4 ? p_enabled  :
              zoneNum == 5 ? s1_enabled :
              zoneNum == 6 ? s2_enabled :
              zoneNum == 7 ? s3_enabled :
              zoneNum == 8 ? s4_enabled : false
         
// Create a box for the current day
createBox(startime, _top, _bottom, endtime, _text) =>
    box.new(
            left= startime, 
            top=_top, 
            right=endtime, 
            bottom=_bottom, 
            bgcolor=color.rgb(255, 82, 82, 85),
            border_color=color.rgb(255, 82, 82, 85),
            border_width=1,
            text=_text,
            text_color=color.rgb(182, 182, 182, 34),
            text_size=size.small,
            text_halign=text.align_left,
            xloc=xloc.bar_time
                )
// clean up old boxs
cleanupOldBox(boxes_array, max_number) =>
    while array.size(boxes_array) > max_number 
        box.delete(array.shift(boxes_array))

// clean up old lines
cleanupOldlines(lines_array, max_number) =>
        // deleting the OLDEST line 
    while array.size(lines_array) > max_number
        // Remove the first + deletes its child linefill
        oldest_line = array.shift(lines_array) 
        line.delete(oldest_line)

// Candlestick calculation engulf detection      
isBullish(_open, _close) => 
    _close > _open

isBearish(_open, _close) => 
    _close < _open

// ispriveousinrange(_opeN, _closE) => 
//     math.abs(_closE - _opeN) < prevranratio 

isinRange(value1, value2, _min, _max) => 
    math.abs(value1 - value2) >= _min and math.abs(value1 - value2) <= _max

bullishEngulf(prevIdx2Open, prevIdx2Close, prevOpen, prevClose, prevHigh, prevLow, currOpen, currClose, currHigh, currLow, bodyOnly) =>
    _prev_Level = isBearish(prevOpen, prevClose) ? prevOpen : prevHigh
    // Previous candle must be bearish, current candle bullish
    (isBearish(prevOpen, prevClose) or isBearish(prevIdx2Open, prevIdx2Close)) 
         and isBullish(currOpen, currClose) 
         and (bodyOnly ? (currOpen <= prevClose + (syminfo.mintick * gapAllowance) 
         and currClose > _prev_Level) : (currLow < prevLow 
         and currHigh > prevHigh))

bearishEngulf(prevIdx2Open, prevIdx2Close, prevOpen, prevClose, prevHigh, prevLow, currOpen, currClose, currHigh, currLow, bodyOnly) =>
    _prev_Level = isBullish(prevOpen, prevClose) ? prevOpen : prevLow
    // Previous candle must be bullish, current candle bearish
    (isBullish(prevOpen, prevClose) or isBullish(prevIdx2Open, prevIdx2Close)) 
         and isBearish(currOpen, currClose) 
         and (bodyOnly ?  (currOpen >= prevClose - (syminfo.mintick * gapAllowance) 
         and currClose < _prev_Level) : (currLow < prevLow 
         and currHigh > prevHigh))

// Pin Bar detection
pinBar(Open_, Close_, High_, Low_, wickRatio, bodyMax, wickMin) => //,minRange) =>

    range_ = High_ - Low_
    if range_ == 0 //and range_ > minRange
        "none"
    else
        body = math.abs(Close_ - Open_)
        bodyPct = body / range_
        // body must be small relative to range
        if bodyPct > bodyMax
            "none"
        else
            upperWick   = High_ - math.max(Open_, Close_)
            lowerWick   = math.min(Open_, Close_) - Low_
            // determine longer wick
            longWick    = math.max(upperWick, lowerWick)
            longWickPct = longWick / range_
            // longer wick must be significant
            if longWickPct < wickMin
                "none"
            else
                // ratio of long wick to body must exceed threshold
                if longWick / body >= wickRatio
                    // determine direction: if lower wick is longer -> bullish hammer, else bearish shooting star
                    if lowerWick > upperWick
                        "bullish"
                    else
                        "bearish"
                else
                    "none"
// engulfInZone(_price) =>
//              (_price >= zone1_Bottom and _price <= zone1_Top) or (_price >= zone2_Bottom and _price <= zone2_Top) or  
//              (_price >= zone3_Bottom and _price <= zone3_Top) or (_price >= zone4_Bottom and _price <= zone4_Top) or  
//              (_price >= zone5_Bottom and _price <= zone5_Top) or (_price >= zone6_Bottom and _price <= zone6_Top) or  
//              (_price >= zone7_Bottom and _price <= zone7_Top) or (_price >= zone8_Bottom and _price <= zone8_Top) 

// engulfcrossZone(_value1, _value2) =>
//              (_value1 < zone1_Bottom and _value2 > zone1_Top) or (_value1 < zone2_Bottom and _value2 > zone2_Top) or  
//              (_value1 < zone3_Bottom and _value2 > zone3_Top) or (_value1 < zone4_Bottom and _value2 > zone4_Top) or  
//              (_value1 < zone5_Bottom and _value2 > zone5_Top) or (_value1 < zone6_Bottom and _value2 > zone6_Top) or  
//              (_value1 < zone7_Bottom and _value2 > zone7_Top) or (_value1 < zone8_Bottom and _value2 > zone8_Top)             

nearZone(_value1, _value2, _top1, bottom1, _top2, _bottom2) =>

         (((_value2 >= bottom1 and _value2 <= _top1) or (_value2 >= _bottom2 and _value2 <= _top2)) // in the zone
         or 
         ((_value1 < bottom1 and _value2 > _top1) or (_value1 < _bottom2 and _value2 > _top2))) // cross over the zone 

// TP/SL drawing       
draw_sl_tp_lines(entry_bar_index, _entry, sl_price, tp_price, tp_price1, draw_TP1, draw_BE) =>
    
    color_entry = color.rgb(255, 255, 255, 60)
    color_sl = color.new(color.red, 60)
    color_tp = color.new(color.green, 60)
    line_style = line.style_solid
    line_width = 1
    end_bar = bar_index + 9
    lines_per_trade = draw_TP1 or draw_BE ? 4 : 3
    // Draw SL line (horizontal)
    _entry_ = line.new(
                x1=entry_bar_index, y1=_entry,
                x2=end_bar, y2=_entry,
                color=color_entry, style=line_style, width=line_width,
                extend=extend.none  // 
            )
    _sl_ = line.new(
                x1=entry_bar_index, y1=sl_price,
                x2=end_bar, y2=sl_price,
                color=color_sl, style=line_style, width=line_width,
                extend=extend.none  // no extend 
            )
    // Draw TP line (horizontal)
    _tp_ = line.new(
                x1=entry_bar_index, y1=tp_price,
                x2=end_bar, y2=tp_price,
                color=color_tp, style=line_style, width=line_width,
                extend=extend.none
            )
    array.push(position_lines, _entry_)
    array.push(position_lines, _sl_)
    array.push(position_lines, _tp_)
    
    // fill between lines
    linefill.new(_entry_, _tp_, color=color.new(#3fde39, 90))
    linefill.new(_entry_, _sl_, color=color.new(#de3939, 90))    

    // Draw TP1 line (horizontal)
    if draw_TP1 or draw_BE
        _BE_ = line.new(
                    x1=entry_bar_index, y1=tp_price1,
                    x2=end_bar, y2=tp_price1,
                    color=draw_TP1 ? color_tp :color_entry, style=line.style_dashed, width=1,
                    extend=extend.none
                ) 
        array.push(position_lines, _BE_)

    max_lines_allowed = trades_to_keep * lines_per_trade
    
    if array.size(position_lines) > max_lines_allowed
        cleanupOldlines(position_lines, max_lines_allowed)


// SL & Risk calculation    
calc_qty(price, sl, _acct_risk) =>
    stopDist = math.abs(price - sl)
    stopDist == 0 ? 0 : math.max(math.floor(_acct_risk / stopDist), 1)

// close trades on weekend/dayend
if Close_Time
    strategy.close_all(comment= closeonDayEnd and scalping ? "Dayend Close" : "WeekEnd Close")

// reset trade counter
Todaytrades := resetTradeContr ? 0 : Todaytrades 
    
// EMA Calculate
EMAvalue   = ta.ema(src1, lenofEMA)[offsetlower]
EMAvalueHT = request.security(syminfo.tickerid, Higher_TF, ta.ema(srcHT, lenHTEMA)[offsetHT], lookahead=barmerge.lookahead_off) 

emaConfirm_buy  = allowEMAConf    ? close > EMAvalue   : true
emaConfirm_sell = allowEMAConf    ? close < EMAvalue   : true
HTemaConf_buy   = allowHT_EMAConf ? close > EMAvalueHT : true
HTemaConf_sell  = allowHT_EMAConf ? close < EMAvalueHT : true

// RSI Calculate
rsi_cal      = ta.rsi(close, RSI_len)
RSI_CON_buy  = usingRSI ? (not na(rsi_cal) and rsi_cal <= 70) : true
RSI_CON_sell = usingRSI ? (not na(rsi_cal) and rsi_cal >= 30) : true

// BB calculation
bb_basis = ta.sma(close, bb_len)
bb_std   = ta.stdev(close, bb_len)
bb_upper = bb_basis + (bb_std * bb_mult)
bb_lower = bb_basis - (bb_std * bb_mult)
bb_width = (bb_upper - bb_lower)  / bb_basis // Normalized bandwidth

low_volatility = BB_enabled ? bb_width < bbThreshold : false

periodInput = switch pivotPeriod
    "Daily"     => "D"
    "Weekly"    => "W"
    "Monthly"   => "M"
    "Quarterly" => "3M"
    "Yearly"    => "12M"        
   
[zoneatrValue, pivotOpen, pivotHigh, pivotLow, pivotClose] = request.security(syminfo.tickerid, periodInput, [ta.atr(ZoneatrLength)[offset], open[offset], high[offset], low[offset], close[offset]], lookahead=barmerge.lookahead_on)

// the first bar of the new period
isNewPeriod = ta.change(time(periodInput)) != 0

// the stat and end of period
OpenTime    = time(periodInput, ny_tz) 
CloseTime   = time_close(periodInput, ny_tz)  



// Calculate Pivot Points if new candle is open
if isNewPeriod  

    zonerang   := zoneWidthMode == "Percentage" ? close * (zoneWidthPct / 100) :
                  zoneWidthMode == "ATR Multiplier" ? zoneatrValue * zoneATRMultip : zoneWidthFixed

    swaplevel  := zonerang * (ThresholdPct / 100)

    float pivot = na
    float r1 = na, float r2 = na, float r3 = na, float r4 = na
    float s1 = na, float s2 = na, float s3 = na, float s4 = na

    H = pivotHigh
    L = pivotLow
    C = pivotClose
    O = pivotOpen 

    if TypePeriod == "Classic"
        pivot := (H + L + C) / 3
        r1    := 2*pivot - L
        s1    := 2*pivot - H
        r2    := pivot + (H - L)
        s2    := pivot - (H - L)
        r3    := H + 2*(pivot - L)
        s3    := L - 2*(H - pivot)
        r4    := H + 3*(pivot - L)
        s4    := L - 3*(H - pivot)

    else if TypePeriod == "Fibonacci"
        pivot := (H + L + C) / 3
        r1 := pivot + 0.382 * (H - L)
        s1 := pivot - 0.382 * (H - L)
        r2 := pivot + 0.618 * (H - L)
        s2 := pivot - 0.618 * (H - L)
        r3 := pivot + 1.000 * (H - L)  
        s3 := pivot - 1.000 * (H - L)
        r4 := pivot + 1.618 * (H - L)   // extra
        s4 := pivot - 1.618 * (H - L)
 
    else if TypePeriod == "Woodie (Extended)"
        pivot := (H + L + 2*C) / 4
        r1 := 2*pivot - L
        s1 := 2*pivot - H
        r2 := pivot + (H - L)
        s2 := pivot - (H - L)
        r3 := r1 + (H - L) // Extended Woodie
        s3 := s1 - (H - L) // Extended Woodie
        r4 := r2 + (H - L) // Custom extension (not standard Woodie)
        s4 := s2 - (H - L) // Custom extension (not standard Woodie)   

    else if TypePeriod == "Custom Camarilla"
        // originally Camarilla pivot not used, :(
        pivot := (H + L + C) / 3 
        range_ = H - L
        r1 := C + range_ * 1.1666
        r2 := C + range_ * 1.9166
        r3 := C + range_ * 2.6666
        r4 := C + range_ * 3.6666
        s1 := C - range_ * 1.1666
        s2 := C - range_ * 1.9166
        s3 := C - range_ * 2.6666
        s4 := C - range_ * 3.6666

    else if TypePeriod == "DM"
        float X = na
        if C < O
            X := H + 2*L + C
        else if C > O
            X := 2*H + L + C
        else
            X := H + L + 2*C
        pivot := X / 4
        r1 := X / 2 - L
        s1 := X / 2 - H
        r2 := X - s1
        s2 := X - r1
        // extra levels using pivot-based extension
        r3 := pivot + (H - L)
        s3 := pivot - (H - L)
        r4 := r1 + (H - L)  
        s4 := s1 - (H - L)
    
    // Calculate Zones
    //R4
    zone1_Top    := r4 + zonerang
    zone1_Bottom := r4 - zonerang
    //R3
    zone2_Top    := r3 + zonerang
    zone2_Bottom := r3 - zonerang
    //R2
    zone3_Top    := r2 + zonerang
    zone3_Bottom := r2 - zonerang
    //R1
    zone4_Top    := r1 + zonerang
    zone4_Bottom := r1 - zonerang
    //Pivot
    zone5_Top    := pivot + zonerang
    zone5_Bottom := pivot - zonerang
    //S1
    zone6_Top    := s1 + zonerang
    zone6_Bottom := s1 - zonerang
    //S2
    zone7_Top    := s2 + zonerang
    zone7_Bottom := s2 - zonerang
    //S3
    zone8_Top    := s3 + zonerang
    zone8_Bottom := s3 - zonerang
    //S4
    zone9_Top    := s4 + zonerang
    zone9_Bottom := s4 - zonerang
            
    // creat boxes
    // Resistance 
    lineL1A   = createBox(OpenTime, zone4_Top, zone4_Bottom, CloseTime, "R1")
    lineL2A   = createBox(OpenTime, zone3_Top, zone3_Bottom, CloseTime, "R2")
    lineL3A   = createBox(OpenTime, zone2_Top, zone2_Bottom, CloseTime, "R3")
    lineL4A   = createBox(OpenTime, zone1_Top, zone1_Bottom, CloseTime, "R4")
    // Pivot
    linePivot = createBox(OpenTime, zone5_Top, zone5_Bottom, CloseTime, "P")
    // Support levels
    lineL1B   = createBox(OpenTime, zone6_Top, zone6_Bottom, CloseTime, "S1")
    lineL2B   = createBox(OpenTime, zone7_Top, zone7_Bottom, CloseTime, "S2")
    lineL3B   = createBox(OpenTime, zone8_Top, zone8_Bottom, CloseTime, "S3")
    lineL4B   = createBox(OpenTime, zone9_Top, zone9_Bottom, CloseTime, "S4") 
    // store boxes
    array.push(zoneBoxes, lineL1A)
    array.push(zoneBoxes, lineL2A)
    array.push(zoneBoxes, lineL3A)
    array.push(zoneBoxes, lineL4A)
    array.push(zoneBoxes, linePivot)     
    array.push(zoneBoxes, lineL1B)
    array.push(zoneBoxes, lineL2B)
    array.push(zoneBoxes, lineL3B)
    array.push(zoneBoxes, lineL4B)
    // store Zones boundaries
    array.set(zoneTop, 0, zone1_Top), array.set(zoneBot, 0, zone1_Bottom)
    array.set(zoneTop, 1, zone2_Top), array.set(zoneBot, 1, zone2_Bottom)
    array.set(zoneTop, 2, zone3_Top), array.set(zoneBot, 2, zone3_Bottom)
    array.set(zoneTop, 3, zone4_Top), array.set(zoneBot, 3, zone4_Bottom)
    array.set(zoneTop, 4, zone5_Top), array.set(zoneBot, 4, zone5_Bottom)
    array.set(zoneTop, 5, zone6_Top), array.set(zoneBot, 5, zone6_Bottom)
    array.set(zoneTop, 6, zone7_Top), array.set(zoneBot, 6, zone7_Bottom)
    array.set(zoneTop, 7, zone8_Top), array.set(zoneBot, 7, zone8_Bottom)
    array.set(zoneTop, 8, zone9_Top), array.set(zoneBot, 8, zone9_Bottom)
    // clean old boxes
    if array.size(zoneBoxes) > max_boxes
        cleanupOldBox(zoneBoxes, max_boxes)

    // reset 
    allowLong  := false
    allowShort := false
    foundGapIdx := (close > zone1_Top  ? 0
                  : close > zone2_Top and close < zone1_Bottom ? 1
                  : close > zone3_Top and close < zone2_Bottom ? 2
                  : close > zone4_Top and close < zone3_Bottom ? 3
                  : close > zone5_Top and close < zone4_Bottom ? 4 
                  : close > zone6_Top and close < zone5_Bottom ? 5 
                  : close > zone7_Top and close < zone6_Bottom ? 6
                  : close > zone8_Top and close < zone7_Bottom ? 7
                  : close > zone9_Top and close < zone8_Bottom ? 8 
                  : close > zone9_Bottom ? 9 : 5)
    marketStatuse := "Waiting"

prevPrice   = close[Zoffset]
curentprice = close

check_market_statuse = foundGapIdx < 9 and foundGapIdx > 0  // between zones only

// zones logic for sell & buy
if check_market_statuse

    if (prevPrice       >= array.get(zoneBot, foundGapIdx - 1) - swaplevel 
        and prevPrice   <= array.get(zoneTop, foundGapIdx - 1) + swaplevel 
        and curentprice <= array.get(zoneTop, foundGapIdx - 1) + swaplevel
        )
        if isZoneEnabled(foundGapIdx - 1)
            allowLong     := false
            allowShort    := true
            slzone        := array.get(zoneTop, foundGapIdx - 1)
            marketStatuse := "Bearish"
        else
            // Zone is disabled – no trade
            allowLong     := false
            allowShort    := false
            slzone        := array.get(zoneTop, foundGapIdx - 1)
            marketStatuse := "Zone disabled"

    else if (prevPrice  >= array.get(zoneBot, foundGapIdx) - swaplevel 
        and prevPrice   <= array.get(zoneTop, foundGapIdx) + swaplevel 
        and curentprice >= array.get(zoneBot, foundGapIdx) - swaplevel
        )
        if isZoneEnabled(foundGapIdx)

            allowLong     := true
            allowShort    := false
            slzone        := array.get(zoneBot, foundGapIdx)
            marketStatuse := "Bullish"
        else

            allowLong     := false
            allowShort    := false
            slzone        := array.get(zoneBot, foundGapIdx)
            marketStatuse := "Zone disabled"

    else if (prevPrice  > array.get(zoneTop, foundGapIdx - 1) + swaplevel 
        and curentprice > array.get(zoneBot, foundGapIdx - 1) - swaplevel)
        if isZoneEnabled(foundGapIdx - 1)
            allowLong     := true
            allowShort    := false
            slzone        := array.get(zoneBot, foundGapIdx - 1)
            marketStatuse := "Bullish"
        else 
            allowLong     := false
            allowShort    := false
            slzone        := array.get(zoneBot, foundGapIdx - 1)
            marketStatuse := "Zone disabled"
        foundGapIdx := updateGapIndex(prevPrice)
        //slzone        := array.get(zoneBot, foundGapIdx - 1) // if price cross 2 zones in same time SL will be the last zone price crossed

    else if (prevPrice  < array.get(zoneBot, foundGapIdx) - swaplevel 
        and curentprice < array.get(zoneTop, foundGapIdx) + swaplevel)
        if isZoneEnabled(foundGapIdx)
            allowLong     := false
            allowShort    := true
            slzone        := array.get(zoneTop, foundGapIdx)
            marketStatuse := "Bearish"
        else    
            allowLong     := false
            allowShort    := true
            slzone        := array.get(zoneTop, foundGapIdx)
            marketStatuse := "Zone disabled"
        foundGapIdx := updateGapIndex(prevPrice)
        //slzone        := array.get(zoneTop, foundGapIdx) // if price cross 2 zones in same time SL will be the last zone price crossed

else 
    
    allowLong     := false
    allowShort    := false
    slzone        := foundGapIdx == 0 ? zone1_Bottom : foundGapIdx == 9 ? zone9_Top : na
    marketStatuse := "Aggressive"
    foundGapIdx   := updateGapIndex(prevPrice)


// Engulfing
isBullEngulf = bullishEngulf(open[2], close[2], open[1], close[1], high[1], low[1], open, close, high, low, engulfBodyOnly) and isinRange(open, close, engulfrange, maxengulfrange)
isBearEngulf = bearishEngulf(open[2], close[2], open[1], close[1], high[1], low[1], open, close, high, low, engulfBodyOnly) and isinRange(open, close, engulfrange, maxengulfrange)
// Pin Bar
previsPinBar = pinBar(open[1], close[1], high[1], low[1], pinWickRatio, pinBodyMax, pinWickMin) //, engulfrange)

lastbottom = ta.lowest(low, SweepLookback)[2]
lastTop    = ta.highest(high, SweepLookback)[2]

isBullPinAndEngulf = lastbottom > low[1] and previsPinBar == "bullish" and isBullish(open, close) and close > high[1] and isinRange(open, close, engulfrange, maxengulfrange)
isBearPinandEngulf = lastTop   < high[1] and previsPinBar == "bearish" and isBearish(open, close) and close < low[1]  and isinRange(open, close, engulfrange, maxengulfrange)

// Hardcoded bar location check
// engulf_InZone = engulfInZone(open)
// Bullengulfnearzone = engulf_InZone or engulfcrossZone(open, close) //or engulfcrossZone(low, high) //or engulfInZone(close)           
// Bearengulfnearzone = engulf_InZone or engulfcrossZone(close, open) //or engulfcrossZone(low, high) //or engulfInZone(close)

// actual gap state to determine which zones to check
bullEngulfNearZone = (foundGapIdx < 9 ? foundGapIdx > 0 ? 
                       nearZone(close, open, array.get(zoneTop, foundGapIdx - 1), array.get(zoneBot, foundGapIdx - 1), array.get(zoneTop, foundGapIdx), array.get(zoneBot, foundGapIdx)) 
                     : nearZone(close, open, array.get(zoneTop, 0), array.get(zoneBot, 0), array.get(zoneTop, 0), array.get(zoneBot, 0)) 
                     : nearZone(close, open, array.get(zoneTop, 8), array.get(zoneBot, 8), array.get(zoneTop, 8), array.get(zoneBot, 8))) 

bearEngulfNearZone = (foundGapIdx < 9 ? foundGapIdx > 0 ?   
                       nearZone(close, open, array.get(zoneTop, foundGapIdx - 1), array.get(zoneBot, foundGapIdx - 1), array.get(zoneTop, foundGapIdx), array.get(zoneBot, foundGapIdx)) 
                     : nearZone(close, open, array.get(zoneTop, 0), array.get(zoneBot, 0), array.get(zoneTop, 0), array.get(zoneBot, 0))
                     : nearZone(close, open, array.get(zoneTop, 8), array.get(zoneBot, 8), array.get(zoneTop, 8), array.get(zoneBot, 8))) 

longCondition  = (barstate.isconfirmed and (isBullEngulf or isBullPinAndEngulf) 
                  and allowLong and bullEngulfNearZone and (emaConfirm_buy or isBullPinAndEngulf) 
                  and Todaytrades < maxTrades and RSI_CON_buy and not low_volatility 
                  and HTemaConf_buy and not noTradesWinOn)

shortCondition = (barstate.isconfirmed and (isBearEngulf or isBearPinandEngulf) 
                  and allowShort and bearEngulfNearZone and (emaConfirm_sell or isBearPinandEngulf)  
                  and Todaytrades < maxTrades and RSI_CON_sell and not low_volatility 
                  and HTemaConf_sell and not noTradesWinOn)

[long_sl, short_sl] = switch stopLoseLevel
    "Low-High"       => [low - slbuf, high + slbuf]
    "Zone"           => [slzone - slbuf, slzone + slbuf]
    "Fixed distance" => [close - SLfixDistance, close + SLfixDistance]
    "ATR Multiplier" => [close - (SLatrValue * SLatrMultiplier), close + (SLatrValue * SLatrMultiplier)]
    "Swing high/low" => [ta.lowest(low, low_maxcount) - slbuf, ta.highest(high, high_maxcont) + slbuf]
    
acct_risk = strategy.position_size == 0 ? strategy.equity * (riskTradepct1 / 100.0) : strategy.equity * (riskTradepct2 / 100.0)

// reset positions & entry bar index % TPs/SLs
if strategy.position_size == 0 and bar_index > lastEntryBar + BarsNewEntries
    positions    := 0
    entryPrice1  := na
    entryPrice2  := na
    activeID1    := na
    activeID2    := na
    L1tpPrice    := na
    L2tpPrice    := na
    long1TP1     := na
    long2TP1     := na
    SH1tpPrice   := na
    SH2tpPrice   := na
    short1TP1    := na
    short2TP1    := na
    TP1triggered1:= false
    TP1triggered2:= false



if  longCondition and positions < positionallowed and bar_index > lastEntryBar + BarsNewEntries
    
    entryPrice = close 
    qty = calc_qty(entryPrice, long_sl, acct_risk) 
    if qty > 0 
        if strategy.position_size == 0
            entryPrice1  := close
            L1tpPrice    := entryPrice + ((entryPrice - long_sl) * risk_reward)
            long1TP1     := entryPrice + ((entryPrice - long_sl) * risk_reward_BE)
            tradeCounter := tradeCounter + 1
            entryID       = str.tostring(tradeCounter)
            activeID1    := entryID
            strategy.entry(entryID, strategy.long, qty)
            
            if Tp_division and risk_reward > risk_reward_BE
                strategy.exit(PartialExitID + str.tostring(tradeCounter) ,entryID, stop=long_sl, limit=long1TP1, qty_percent=tp_pct)
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, limit=L1tpPrice, stop=long_sl, qty_percent=100)
                
            else    
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=long_sl, limit=L1tpPrice)
            
            Todaytrades := Todaytrades + 1
            positions   := positions + 1
            lastEntryBar:= bar_index
            // draw line TP/SL & label
            draw_sl_tp_lines(bar_index, entryPrice, long_sl , L1tpPrice, long1TP1, Tp_division, breakeven)
            
            
        else if allow_two_trade and in_long //strategy.position_size != 0 //and (strategy.position_size > 0)
            entryPrice2 := close
            L2tpPrice    :=(entryPrice + ((entryPrice - long_sl) * risk_reward2))
            long2TP1     := entryPrice + ((entryPrice - long_sl) * risk_reward_BE)
            tradeCounter := tradeCounter + 1
            entryID       = str.tostring(tradeCounter)
            activeID2    := entryID
            strategy.entry(entryID, strategy.long, qty)

            if Tp_division and risk_reward2 > risk_reward_BE
                strategy.exit(PartialExitID + str.tostring(tradeCounter), entryID, stop=long_sl, limit=long2TP1, qty_percent=tp_pct)
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=long_sl, limit=L2tpPrice, qty_percent=100)
                
            else    
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=long_sl, limit=L2tpPrice)
            
            positions    := positions + 1
            lastEntryBar := bar_index
            // draw line TP/SL & label
            draw_sl_tp_lines(bar_index, entryPrice, long_sl , L2tpPrice, long2TP1, Tp_division, breakeven)
            

if  shortCondition and positions < positionallowed and bar_index > lastEntryBar + BarsNewEntries
    entryPrice = close
    qty = calc_qty(entryPrice, short_sl, acct_risk)
    if qty > 0 
        if strategy.position_size == 0
            entryPrice1  := close
            SH1tpPrice   := entryPrice - ((short_sl - entryPrice) * risk_reward)
            short1TP1    := entryPrice - ((short_sl - entryPrice) * risk_reward_BE)
            tradeCounter := tradeCounter + 1
            entryID       = str.tostring(tradeCounter)
            activeID1    := entryID
            strategy.entry(entryID, strategy.short, qty)
            if Tp_division and risk_reward > risk_reward_BE
                strategy.exit(PartialExitID + str.tostring(tradeCounter) , entryID, stop=short_sl, limit=short1TP1, qty_percent=tp_pct)
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=short_sl, limit=SH1tpPrice, qty_percent=100)
                       
            else    
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=short_sl, limit=SH1tpPrice)
            
            Todaytrades  := Todaytrades + 1
            positions    := positions + 1 
            lastEntryBar := bar_index
            // draw line TP/SL & label
            draw_sl_tp_lines(bar_index, entryPrice, short_sl , SH1tpPrice, short1TP1, Tp_division, breakeven)
                                      
        else if allow_two_trade and in_short //strategy.position_size != 0  //and (strategy.position_size < 0) Strategy.
            entryPrice2  := close
            SH2tpPrice   := (entryPrice - ((short_sl - entryPrice) * risk_reward2)) 
            short2TP1    := entryPrice - ((short_sl - entryPrice) * risk_reward_BE)
            tradeCounter := tradeCounter + 1
            entryID       = str.tostring(tradeCounter)
            activeID2    := entryID
            strategy.entry(entryID, strategy.short, qty)

            if Tp_division and risk_reward2 > risk_reward_BE
                strategy.exit(PartialExitID + str.tostring(tradeCounter) , entryID, stop=short_sl, limit=short2TP1, qty_percent=tp_pct)
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=short_sl, limit=SH2tpPrice, qty_percent=100)  
            else    
                strategy.exit(mainExitID + str.tostring(tradeCounter), entryID, stop=short_sl, limit=SH2tpPrice)
            
            positions    := positions + 1
            lastEntryBar := bar_index
            // draw line TP/SL & label
            draw_sl_tp_lines(bar_index, entryPrice, short_sl  , SH2tpPrice, short2TP1, Tp_division, breakeven)
    


if breakeven and strategy.position_size != 0

    if in_long

        BE1 = not na(activeID1) and high >= long1TP1
        BE2 = not na(activeID2) and high >= long2TP1

        if not TP1triggered1 and BE1 and risk_reward > risk_reward_BE

            strategy.cancel(PartialExitID + activeID1) 
            strategy.cancel(mainExitID + activeID1)
            strategy.exit(breakevenExitID + activeID1, activeID1, stop=entryPrice1, limit=L1tpPrice, qty_percent=100)
            TP1triggered1 := true
        if not TP1triggered2 and BE2 and risk_reward2 > risk_reward_BE
            
            strategy.cancel(PartialExitID + activeID2) 
            strategy.cancel(mainExitID + activeID2)
            strategy.exit(breakevenExitID + activeID2, activeID2, stop=entryPrice2, limit=L2tpPrice, qty_percent=100)
            TP1triggered2 := true

    if in_short

        BE1          = not na(activeID1) and low <=short1TP1
        BE2          = not na(activeID2) and low <= short2TP1

        if not TP1triggered1 and BE1 and risk_reward > risk_reward_BE

            strategy.cancel(PartialExitID + activeID1) 
            strategy.cancel(mainExitID + activeID1)
            strategy.exit(breakevenExitID + activeID1, activeID1, stop=entryPrice1, limit=SH1tpPrice, qty_percent=100)
            TP1triggered1 := true
        if not TP1triggered2 and BE2 and risk_reward2 > risk_reward_BE

            strategy.cancel(PartialExitID + activeID2) 
            strategy.cancel(mainExitID + activeID2)
            strategy.exit(breakevenExitID + activeID2, activeID2, stop=entryPrice2, limit=SH2tpPrice, qty_percent=100)
            TP1triggered2 := true
// Table 
table.set_border_color(infoTable,color.rgb(255, 255, 255, 75))
table.set_bgcolor(infoTable, color.rgb(255,255,255,95))
table.set_frame_color(infoTable,color.gray)

table.cell(infoTable, 0, 0, 
            "Market Status",                        text_size=size.small, text_color=color.rgb(43, 141, 222), tooltip="Shows the current trading bias based on the zone the price is near.\n\nBullish – Price near a support zone. Long trades are allowed.\nBearish – Price near a resistance zone. Short trades are allowed.\nWaiting – A new period has started; zone levels are being recalculated. No trades until price enters a zone.\nAggressive – Price is above R4 or below S4. No trades are allowed.\nZone disabled – The relevant zone is manually disabled. No trades are allowed.")

table.cell(infoTable, 1, 0, 
            marketStatuse,                          text_size=size.small, text_color=marketStatuse == "Bullish" ? color.green : marketStatuse == "Bearish" ? color.red : marketStatuse == "Aggressive"? color.yellow : color.gray)

table.cell(infoTable, 0, 1,     
            "Current TF EMA",                       text_size=size.small, text_color=color.rgb(43, 141, 222), tooltip="Green = EMA trend matches market status. Red = EMA and market status are conflicting.")

table.cell(infoTable, 1, 1, 
            not allowEMAConf ? "Disabled" 
            : emaConfirm_buy ? "CONFIRMING BUY" 
            :"CONFIRMING SELL",                     text_size=size.small, text_color=allowEMAConf and (marketStatuse == "Bullish" or marketStatuse == "Bearish") ? allowLong ? emaConfirm_buy ? color.green : color.red: emaConfirm_sell ? color.green : color.red : color.gray)

table.cell(infoTable, 0, 2,     
            "Higher TF EMA",                        text_size=size.small, text_color=color.rgb(43, 141, 222), tooltip="Green = EMA trend matches market status. Red = EMA and market status are conflicting.")

table.cell(infoTable, 1, 2, 
            not allowHT_EMAConf ? "Disabled" 
            : HTemaConf_buy ? "CONFIRMING BUY" 
            : "CONFIRMING SELL",                    text_size=size.small, text_color=allowHT_EMAConf and (marketStatuse == "Bullish" or marketStatuse == "Bearish") ? allowLong ? HTemaConf_buy ? color.green : color.red: HTemaConf_sell ? color.green : color.red : color.white)

table.cell(infoTable, 0, 3, 
            "Zone width mode" + "\n-----------\n" 
            + "Zone Width",                         text_size=size.small, text_color=color.rgb(43, 141, 222))

table.cell(infoTable, 1, 3,
            zoneWidthMode=="Percentage" ? "Percentage"  
            + "\n-----------\n" 
            + str.tostring(zonerang, "#.#####")   
            + " $" : zoneWidthMode=="ATR Multiplier" ? 
            "ATR Multiplier"    
            + "\n-----------\n"
            + str.tostring(zonerang, "#.#####") 
            + " $": "Fixed width" 
            + "\n-------------\n"   
            + str.tostring(zonerang, "#.#####") 
            + " $",                                 text_size=size.small, text_color=color.rgb(255, 255, 255, 20))

table.cell(infoTable, 0, 4, 
            "Breakout threshold",                   text_size=size.small, text_color=color.rgb(43, 141, 222), tooltip="")

table.cell(infoTable, 1, 4,     
              str.tostring(swaplevel, "#.#####")
            + " $",                                 text_size=size.small, text_color=color.rgb(255, 255, 255, 20), tooltip="") 

table.cell(infoTable, 0, 5, 
            "Engulf range mode" 
            + "\n-----------\n"     
            + "Min engulfing\n-----------\n"
            + "Max engulfing",                      text_size=size.small, text_color = color.rgb(43, 141, 222))

table.cell(infoTable, 1, 5, 
            engulfMode + "\n-----------\n" 
            + str.tostring(engulfrange, "#.#####")
            + " $ \n-----------\n "   
            + str.tostring(maxengulfrange, "#.#####")
            + " $",                                 text_size=size.small, text_color = color.rgb(255, 255, 255, 20))

table.cell(infoTable, 0, 6, 
            not showSLofset ? "Stop loss reference"     
            + "\n-----------\n" 
            +  "SL distance" : "Stop loss reference" 
            + "\n-----------\n"   
            + "SL buffer" ,                         text_size=size.small, text_color = color.rgb(43, 141, 222))     

table.cell(infoTable, 1, 6, 
            showSLfixDistance ? stopLoseLevel   
            + "\n-----------\n"   
            + str.tostring(SLfixDistance, "#.#####") 
            + " $" : showSLofset ? stopLoseLevel    
            + "\n-----------\n"    
            + str.tostring(slbuf, "#.#####")
            + " $" : stopLoseLevel + "\n-----------\n"  
            + str.tostring((SLatrValue * SLatrMultiplier), "#.#####")     
            + " $",                                 text_size=size.small, text_color = color.rgb(255, 255, 255, 20))  

// Plot EMA 
plot(allowEMAConf    ? EMAvalue   : na , color=color.rgb(33, 149, 243, 7), title="EMA confirmation",     linewidth=1, display=display.pane + display.price_scale)
plot(allowHT_EMAConf ? EMAvalueHT : na , color=color.rgb(243, 58, 33, 15), title="Higher Timeframe EMA", linewidth=1, display=display.pane + display.price_scale)

// draw signals
plotshape(longCondition,    title="Long Signal",         location=location.belowbar, color=color.rgb(76, 175, 79, 3),    style=shape.triangleup,   text="L",                    size = size.small, textcolor=color.rgb(54, 58, 69, 20),    display=display.pane)
plotshape(shortCondition,   title="Short Signal",        location=location.abovebar, color=color.rgb(255, 82, 82, 7),    style=shape.triangledown, text="S",                    size = size.small, textcolor=color.rgb(54, 58, 69, 20),    display=display.pane)
plotshape(resetTradeContr , title="Reset trade counter", location=location.abovebar, color=color.rgb(224, 228, 223, 37), style=shape.arrowdown,    text="Reset Trade\ncounter", size = size.small, textcolor=color.rgb(243, 245, 248, 54), display=display.pane)
// BG 
//bgcolor((isFirst15NY or isFirst15lon or isFirstBar) ? color.new(#ffffff, 95) : na, title="Reset trade counter")
bgcolor(noTradesWinOn ? color.new(#d7e826, 95) : na, title="No-Trades Window")
bgcolor(Close_Time    ? color.new(#f1f1f1, 80) : na, title="Day/Week end closing")
````
