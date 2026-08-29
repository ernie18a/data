<!-- tradingview-pine-id: PUB;b66094f73ba74ac8a9201e64d0f5568f -->
<!-- tradingviewscripts-format: 1 -->
# Alpha S/R Channel Strategy

Source: https://www.tradingview.com/script/mikVFwAu-Alpha-S-R-Channel-Strategy/

## Description

Alpha S/R Channel Strategy (ASRC)

Mean-reversion strategy trading pullbacks to a dynamic Higher Timeframe EMA channel. Confirms exhaustion via Engulfing & Pin Bar patterns, with Pin+Engulf combo overriding trend filters to capture institutional liquidity grabs. Features optional RSI, BB width, and inverted Squeeze Momentum filters. Includes adaptive position sizing, partial TP, breakeven stops, session trade limits, no-trade windows, day/weekend close, and Friday trading control.

📌 Strategy Overview
Alpha S/R Channel Strategy is a dual‑timeframe mean‑reversion strategy that identifies high‑probability reversal setups by combining a dynamic channel derived from a Higher Timeframe EMA with high‑conviction candlestick patterns (Engulfing and Pin Bar).

The strategy waits for price to retrace to a dynamic value area (the channel) and confirms exhaustion through candlestick patterns before entering—capturing pullbacks within the prevailing trend while avoiding counter‑trend trades.

🧠 Unique Edge – Why This Mashup Works

Most trend‑following strategies chase breakouts and get caught in false moves. Most engulfing strategies ignore the bigger picture and enter too early. This strategy solves both problems by combining these components in a specific sequence:

1. Dynamic EMA Channel (The Value Area)

Instead of using static support/resistance, the strategy constructs a dynamic channel around a Higher Timeframe EMA. The channel width adapts to volatility using three modes:

- Percentage – width as % of current price.(price * (channelWidthPct / 100) )
- ATR Multiplier – width based on ATR from the Higher Timeframe.
- Fixed – static price distance.

Why this matters: The HTF EMA represents the "fair value" or equilibrium price. When price pulls back to this zone, it's statistically more likely to resume the trend rather than reverse.

-------------------------------------------------------------------

2. Channel Break + Candlestick Confirmation (The Trigger)
The strategy enters only when price returns to the channel AND shows exhaustion:

- Bullish Engulfing – Current green candle engulfs previous red/small green candle

- Bearish Engulfing – Current red candle engulfs previous green/small red candle

- Pin Bar + Engulfing Combo – Pin bar sweeps recent high/low and is followed by an engulfing pattern

Why this matters: The channel provides the context (where price should reverse). The candlestick patterns provide the confirmation (that reversal is actually happening). Using both drastically reduces false signals.

-------------------------------------------------------------------

3. Optional Multi‑Layer Filters (The Quality Control)
The strategy includes configurable filters that can be enabled/disabled:

1- EMA Lower TF – Ensures micro‑trend alignment (longs above EMA, shorts below)
However, there is a critical override:

🔄 Pin Bar + Engulfing Combo OVERRIDES the EMA Confirmation

When a Pin Bar sweeps the N‑bar high/low (proving a breakout attempt failed) and is immediately followed by an Engulfing pattern on the next candle, this combo represents a "double confirmation" of exhaustion that bypasses the EMA filter.

Why this is a breakthrough:
Strong institutional reversals (liquidity grabs) often happen against the short‑term EMA trend. A pure trend‑following strategy with a strict EMA filter would miss these reversals because price is moving against the EMA.

2- Higher Timeframe EMA – Ensures long‑term trend alignment 

This acts as a "trend filter on top of the trend filter" – preventing entries that go against the even larger market structure. Users can select a separate timeframe (e.g., 1H) with its own EMA length for additional confirmation.

3- RSI – Prevents buying above 70 and selling below 30

4- Bollinger Bands – Blocks entries during low volatility (sideways markets)

5- Squeeze Momentum – This strategy uses an inverted Squeeze Momentum logic:

 "val < 0 → Longs allowed, Shorts blocked"

 "val > 0 → Shorts allowed, Longs blocked"

 "val == 0 → Both allowed"

This inversion is intentional. The strategy is mean‑reversion based—it waits for momentum to become overextended and then trades against that momentum 

These filters are optional because different assets and market conditions require different levels of confirmation. The user has full control.

-------------------------------------------------------------------

4. Comprehensive Risk Management
The strategy includes:

- Position Sizing – Fixed percentage of equity per trade (separate for first and second entry)

- Pyramiding – Allows up to 2 positions in the same direction (second trade uses lower risk)

- Multiple SL Options – Low-High, Swing high/low, Channel, Fixed distance

- Trade Counter Reset – Resets at session starts for scalping timeframes, daily for swing

- No‑Trade Windows – Blocks entries during end‑of‑day volatility (active only for TF ≤ 15m)

- Day/Week End Closing – Closes positions before gaps (configurable by timeframe)

- Partial Take Profit – Closes a configurable percentage (default: 50%) at a specified R:R ratio (default: 1:2), allowing the remainder to run to the full target (default: 1:3)

- Breakeven Stop – Optionally moves the stop loss to breakeven when the first TP level is reached, protecting the remaining position from turning into a loss

Why this matters: The risk controls ensure survivability across different market conditions. Also Breakeven protection reduces the risk of winning trades turning into losers.

-------------------------------------------------------------------

📊 How It Works

1. Dynamic Channel Calculation
The strategy constructs a channel around an Exponential Moving Average (EMA) from a selected Higher Timeframe:

- EMA – Calculated on the Higher Timeframe
- Channel Width – Adaptive based on volatility (Percentage, ATR, or Fixed)
- Upper Band = EMA + (Width / 2)
- Lower Band = EMA - (Width / 2)

Channel Width Modes:

- Percentage – Width = Price × (User‑defined %)
- ATR Multiplier – Width = ATR(14) × Multiplier
- Fixed – Width = Static distance

-------------------------------------------------------------------

2. Entry Signal Detection
Trades are executed on the Lower Timeframe (default: 5m) when all conditions are met:

Pattern Requirements (One of the following):

- Bullish Engulfing: Current green candle completely engulfs previous bearish or small green candle

- Bearish Engulfing: Current red candle completely engulfs previous bullish or small red candle

- Pin Bar + Engulfing Combo: Pin bar sweeps recent high/low AND is followed by engulfing pattern (Overrides LTF EMA)

# Engulfing Filters:

Body Only – Only bodies must engulf (not full range)

Min/Max Range – Configurable via Percentage, ATR, or Fixed

Gap Allowance – Controls how much gap is allowed in the wrong direction

Previous Range % – Limits the size of the prior candle when it's in the same color

# Pin Bar Detection:

- Wick/Body Ratio (default: 3.0) – Wick must be 3× larger than body

- Max Body/Range (default: 0.20) – Body must be ≤20% of total range

- Min Wick/Range (default: 0.70) – Wick must be ≥70% of total range

- Sweep Lookback (default: 10 bars) – Pin bar must sweep a recent high/low

Min Pin Bar Range % – Pin bar must meet a minimum size threshold

# Channel Proximity:

Price must be within the channel boundaries (open inside)

-------------------------------------------------------------------

3. Confirmation Filters (All Optional)

- Lower Timeframe EMA : Longs require price > EMA; Shorts require price < EMA (overridden by Pin+Engulf combo)

- Higher Timeframe EMA : Ensures long‑term trend alignment (longs above HTF EMA, shorts below)

- RSI : Prevents longs above 70; Prevents shorts below 30

- Bollinger Bands : Blocks entries when BB width < threshold (low volatility)

- Squeeze Momentum : Ensures momentum matches trade direction (inverted logic)

-------------------------------------------------------------------

4. Risk & Position Management

# Position Sizing:

- First Trade – Fixed % of equity (default: 2%)
- Second Trade – Separate % of equity (default: 1%)
- Position size = (Account Risk) / (Entry – SL Distance)

# Friday Trading:

- Allow Friday Trading (default: Disabled) – When disabled, no new trades will be opened on Fridays. Existing positions are not affected. This helps avoid weekend gap risk as markets close for the week.

# Stop‑Loss Options:

1- Low-High : Entry bar low/high ± buffer
2- Swing high/low : N-bar low/high ± buffer
3- Channel : Channel band ± buffer
4- Fixed distance : Fixed price distance from entry

# Take Profit:

- Main R:R ratio (default: 1:3)
- Separate R:R for second trade (default: 1:3)

# Trade Counter Reset:
TF ≤ 15m – Resets at Asia (20:00 NY), London (03:30 NY), New York (09:30 NY)
TF > 15m – Resets once per day at session start

# No‑Trade Window:

- Active only for TF ≤ 15m (16:45–19:05 NY time)
- Protects against end‑of‑day volatility spikes

# Close All Positions:

- TF ≤ 15m – Can close at day end and/or week end (configurable)
- 15m < TF ≤ 240m – Week end only
- TF > 240m – Feature disabled

# Entry Spacing:

- Minimum Bars Between Entries (default: 4) – Prevents multiple entries on the same bar or too close together, reducing the impact of whipsaw on tightly clustered signals

⚙️ Default Settings – Optimized for XAUUSD (Gold)

All default values have been specifically calibrated for Gold's typical volatility and intraday structure.

Setting	   \   Default     \   Why This Works for Gold

-----------------------------------------------------------------------------------
Higher Timeframe \ 15m \ Gold's intraday rhythm operates on 15‑minute cycles. This timeframe captures the balance between institutional order flow and retail noise.

-----------------------------------------------------------------------------------
EMA Length \ 36   \ approximately one full trading session. This captures the dominant intraday trend without excessive lag.

-----------------------------------------------------------------------------------
Channel Width Mode \ Percentage \ Gold's price levels change over time. Percentage mode ensures the channel scales with price, maintaining consistent relative width regardless of Gold's price level.

-----------------------------------------------------------------------------------
Channel Width \ 0.35% \ Gold's daily range averages $30–$100. At current prices, 0.35% = approximately $113–$16. This width captures ~70% of Gold's daily volatility, creating a meaningful "value zone" that filters noise while remaining relevant.

-----------------------------------------------------------------------------------
Lower Timeframe \ 5m \ Fast enough to capture entry signals within the same session, slow enough to filter out micro‑noise. 5m is Gold's "sweet spot" for intraday entries.

-----------------------------------------------------------------------------------
Engulfing Mode \ Percentage \ Adapts to Gold's volatility. As Gold's price moves, the required engulfing range scales proportionally—ensuring consistent pattern quality.

-----------------------------------------------------------------------------------
Engulfing Min Range \ 0.098% \ At Gold's current price3000-5000, this ≈ $3.0–$5.0. Anything smaller is just market noise, not a meaningful reversal signal.

-----------------------------------------------------------------------------------
Engulfing Max Range \ 0.550% \ At Gold's current price, this ≈ $20–$25. Larger candles are often blow‑off spikes driven by news —they tend to reverse violently, making them poor entry points.

-----------------------------------------------------------------------------------
Previous Range % \ 0.60 \ Allows the prior candle to be up to 60% of the engulfing candle's range. This is Gold's "consolidation before reversal" pattern—a small same‑color candle before a large reversal candle.

-----------------------------------------------------------------------------------
Gap Allowance \ 250 ticks \ Gold's typical spread and gap behavior. (250 ticks = $0.250 However, tick values vary between brokers), which accommodates normal  gaps without allowing extreme invalid gaps.

-----------------------------------------------------------------------------------
Pin Bar Sweep \ 	10 bars \ On a 5m chart, 10 bars = 50 minutes. Gold's liquidity grabs often occur within a 30–60 minute window. 10 bars captures these recent liquidity zones without looking too far back.

-----------------------------------------------------------------------------------
Pin Bar Range % \ 0.70 \ Requires the pin bar(high-low) to be at least 70% of the minimum engulfing range. This ensures the pin bar has enough size to be meaningful—rejecting tiny pin bars that lack conviction.

-----------------------------------------------------------------------------------
Risk per Trade (1st)  \  2%  \ Gold experiences 3–5 trade losing streaks regularly. 2% risk ensures that a typical losing streak results in only 6–10% drawdown—recoverable with a few winning trades.

-----------------------------------------------------------------------------------
Risk per Trade (2nd)  \ 1% \ When pyramiding, total exposure increases. 1% on the second trade limits worst‑case loss to -3% total (2% + 1%), protecting the account during false reversals.

-----------------------------------------------------------------------------------
Risk:Reward \ 1:3 \ Gold routinely moves 1.5–2× its ATR in a single directional push. A 1:3 target (e.g., $15 on a $5 stop) is well within Gold's typical daily range—achievable without being overly ambitious.

-----------------------------------------------------------------------------------
Stop‑Loss Reference \ Channel \ Aligns the stop with the value area. If price breaks beyond the channel, the mean‑reversion thesis is invalidated. This is the most logical stop placement for this strategy.

-----------------------------------------------------------------------------------
Stop‑Loss Buffer \ 500 ticks \ 500 ticks = ($0.50 ) on Gold. However, tick values vary between brokers so The  table on  chart will display and show the calculated dollar value. This provides a safety buffer against spread, slippage, and normal wicks—preventing premature stops while keeping the stop within the value area.

-----------------------------------------------------------------------------------
Partial TP & Breakeven \ Disabled (50%, 1:2) \ Optional features that allow locking in partial profits and protecting positions once they move in your favor. Recommended to enable after forward testing.

-----------------------------------------------------------------------------------
No‑Trade Window \ Enabled \ 16:45–19:05 NY time captures the end‑of‑day volatility spike. Gold often experiences erratic moves during this period as institutional traders close positions.

-----------------------------------------------------------------------------------
Day End Close \ Enabled \ Gold gaps frequently at the daily open (5:00 PM NY). Closing before day end avoids these gaps, which can easily stop out tight positions. 

-----------------------------------------------------------------------------------
Week End Close \ Enabled \ Gold is highly sensitive to weekend news (geopolitics, central banks). Gaps of $20–$50+ are common at Sunday open. Closing before Friday close is essential.

-----------------------------------------------------------------------------------
EMA Lower TF \ Enabled \ Ensures entries align with the 5m micro‑trend. However, the Pin+Engulf combo overrides this filter to capture institutional reversals against the trend.

-----------------------------------------------------------------------------------
Higher TF EMA \ Enabled (1H, 55) \ Provides an additional layer of trend confirmation at the macro level. The 1H 55‑EMA acts as a reliable gauge of the broader intraday trend, preventing entries against strong momentum.

-----------------------------------------------------------------------------------
RSI \ Enabled length(14) \ Prevents buying when Gold is overbought (RSI > 70) and selling when oversold (RSI < 30). Gold's sharp spikes often create extreme RSI readings—this filter avoids chasing exhausted moves.

-----------------------------------------------------------------------------------
Bollinger Bands \ Enabled \ locks entries during low volatility (BB width < 0.002). Gold sometimes enters tight consolidation ranges (BB width < 0.002) where engulfing patterns fail. This filter avoids trading in these conditions.

-----------------------------------------------------------------------------------
Squeeze Momentum \ Enabled \ This is inverted from standard SQZMOM. Gold's momentum often overshoots before reversing. By fading the extreme (longs when val < 0, shorts when val > 0), the strategy captures the reversal rather than chasing the continuation.

-----------------------------------------------------------------------------------

# Important Notes on Backtest Realism

- Commission – Most ECN/raw-spread brokers charge $3.00–$3.50 per side (round-turn commission of $6.00- $7.00) for 1 standard lot (100 oz) of XAUUSD. Standard accounts usually build the fee into a wider spread instead of charging a separate cash. This strategy deducts $3.50 per entry and $3.50 per exit ($0.035 × 100 oz)round-turn commission of $7.00. Adjust this to match your broker's exact fees.

- 4 ticks Slippage – For XAUUSD on OANDA, 1 tick = $0.001** per ounce (3 decimal places). 4 ticks = **$0.004 per ounce. Adjust this value if your broker quotes XAUUSD with different decimal precision (e.g., 2 decimal = $0.01 per tick).

Always adjust the commission value to your broker's exact fee structure before relying on the results.

"A backtest without realistic commission and slippage is a fantasy. A backtest with realistic commission and slippage is a truthful reflection of what you can expect when trading live."

-------------------------------------------------------------------

📊 Chart Display

Channel – Upper/Lower bands with a semi‑transparent fill (red zone), representing the value area

EMA Lower TF – Green EMA on the lower timeframe for confirmation

HTF EMA Filter – Red EMA line showing the additional trend filter (plotted on all timeframes ≤ its TF)

Info Table – Shows Market Status, EMA confirmations, Channel Width, Engulfing ranges, SL settings, 
Filters, No‑Trade Window status, Session Close status

Signal Arrows – Green arrow pointing up (below bar) for Long entries, Red arrow pointing down (above bar) for Short entries

Historical Trades – Configurable number of past trades to display on the chart (default: 111, max: 125). Adjust this to optimize chart performance while keeping sufficient trade history for visual analysis.

Reset Signal – Arrow marker (grey) indicating when the trade counter resets at session starts (Asia, London, New York for TF ≤ 15m, or daily for larger TFs)

Background Colors – red for No‑Trade Window, Gray/White for Session Close

UI Note

 # When you adjust any setting in the Inputs tab (Channel Width, Engulfing Min/Max, Previous Range, SL Buffer, etc.), the values displayed in the info table update automatically in real‑time.

This allows you to:

- See the impact of your changes immediately

- Verify the actual dollar values of your settings at current price levels

- Fine‑tune parameters without switching between tabs

Example: If you change the Channel Width from 0.35% to 0.50%, the info table will instantly show the new width in dollars (e.g., $8.50 → $12.00).

# Inputs are hidden from the status line to keep the chart clean. All settings (zones, EMAs, risk, patterns) remain fully adjustable in Settings → Inputs tab.

-------------------------------------------------------------------

📌 In Summary: 

This is not a random collection of indicators.

- The HTF EMA Channel provides the structural context – a dynamic value area that adapts to volatility.

- The Engulfing/Pin Bar patterns provide the high‑conviction trigger – exhaustion confirmation.

- The EMA Override provides the institutional edge – capturing liquidity grabs that standard EMA‑based strategies miss.

- The Optional Filters provide the quality control – reducing false signals.

- The Risk Management provides the survivability – realistic position sizing and stops.

Each component exists specifically to compensate for a flaw in the others. This interdependency is what makes the strategy original, robust, 

Author: Awab_Hassan

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Awab_Hassan
//@version=6

strategy(title="Alpha S/R Channel Strategy", shorttitle = "ASRC",
         overlay = true, margin_short = 0 , margin_long = 0, 
         pyramiding = 2, close_entries_rule="ANY", 
         process_orders_on_close = false, calc_on_every_tick = true,  
         max_bars_back = 500, max_lines_count = 500, 
         initial_capital = 10000, currency = "USD",
         commission_type = strategy.commission.cash_per_contract, 
         commission_value = 0.035 , slippage = 4
         )

// ========== Strategy input setting ==========
//Historical trades to keep on chart--------------------------------------------------------------------Historical data to keep on chart--------------------------------------------------------------------Historical data to keep on chart-------------------------------------------------------------------------------------------------------
trades_to_keep    = input.int   (111,          "   Historical Trades",                      minval=1,       maxval=125,     step=1,     group="Historical trades to keep on chart", display=display.none,                                               tooltip="Number of historical trades to keep on the chart. (max 125)")

//Higher timeframe Settings-------------------------------------------------------------------------Higher timeframe Settings-----------------------------------------------------------------Higher timeframe Settings-----------------------------------------------------------------------------Higher timeframe Settings--------------------------------
_tfInput          = input.string("15m",         "   EMA Higher Timeframe",      options=["1m","5m","15m","30m","1H","4H","1D","1W"],    group="Higher timeframe Settings",          display=display.none,                                               tooltip="Higher timeframe for EMA calculation.\nThis EMA will reflect trends from the selected timeframe regardless of your chart's current timeframe.\n\n All default settings below are optimized for XAUUSD.\nCheck strategy documentation for a BTCUSD configuration example")
len               = input.int   (36,            "   EMA Length",                            minval=1,                       step= 1,    group="Higher timeframe Settings",          display=display.none)
src               = input       (close,         "   Source",                                                                            group="Higher timeframe Settings",          display=display.none)
offset            = input.int   (0,             "   Offset",                                minval=-500,    maxval=500,     step= 1,    group="Higher timeframe Settings",          display=display.none,                                               tooltip="Number of bars to shift the EMA values.\nUse 1 referencing the confirmed previous bar's EMA")

//Channel Settings------------------------------------------------------------Channel Settings-------------------------------------------------------Channel Settings-----------------------------Channel Settings-----------------------------------------------------Channel Settings-----------------------
channelWidthMode  = input.string("Percentage",  "   Channel Width Mode",             options=["Percentage", "ATR Multiplier", "Fixed"], group="Channel Settings",                   display=display.none,                                               tooltip="How to calculate Width of channel requirements.")
channelWidthPct   = input.float (0.35,          "   Channel Width (%)",                     minval=0.000001,maxval=50.0,    step=0.001, group="Channel Settings",                   display=display.none, active=(channelWidthMode=="Percentage"),      tooltip="Width of channel as percentage of current price.")
channelatrLength  = input.int   (14,            "   Channel ATR Length",                    minval=1,                       step=1,     group="Channel Settings",                   display=display.none, active=(channelWidthMode=="ATR Multiplier"),  tooltip="ATR length from the selected Higher Timeframe above.\nFor example, if Higher Timeframe is '15m', this uses the 15m ATR.")
channelATRmulti   = input.float (3.5,           "   Channel Width ATR Multiplier",          minval=0.000001,maxval=50.0,    step=0.1,   group="Channel Settings",                   display=display.none, active=(channelWidthMode=="ATR Multiplier"),  tooltip="Width of channel as multiple of ATR.")
channelWidthFixed = input.float (15,            "   Channel Width (Fixed)",                 minval=0,                                   group="Channel Settings",                   display=display.none, active=(channelWidthMode=="Fixed"),           tooltip="Fixed Width of channel in price units.")

// Engulf settings-------------------------------------------------------------Engulf settings ----------------------------------------------------------------------------Engulf settings ------------------------------------------------------Engulf settings ------------------------------------------------Engulf settings ---------------------------------------------------------------------------------------------------- 
lower_tfInput     = input.string("5m",          "   Lower TimeFrame",             options=["1m","3m","5m","15m","30m","1H","4H","1D"],  group="Candlestick Settings (Engulf)",      display=display.none,                                               tooltip="⏱️ Execution Timeframe: This is the timeframe where trades are actually executed. All entry signals, stop-losses, take-profits, and candlestick patterns are based on this timeframe. Adjust parameters for other assets.\n\n⚠️ NOTE: Strategy performance may vary between brokers Always test and adjust parameters according to your specific broker's execution environment.")
engulfBodyOnly    = input.bool  (true,          "Engulfing: Body Only",                                                                 group="Candlestick Settings (Engulf)",      display=display.none,                                               tooltip="If true, only body must engulf. If false, full range (high/low) must engulf.")
engulfMode        = input.string("Percentage",  "   Engulf Range Mode",             options=["Percentage", "ATR Multiplier", "Fixed"],  group="Candlestick Settings (Engulf)",      display=display.none,                                               tooltip="How to calculate engulfing candle range requirements.\nSmaller timeframes (1m-5m) typically need smaller values ; larger TFs (30m-4h) need bigger values.\n\nHelps filter out small, low-volatility engulfing patterns while adapting to market conditions.")

engulfPct         = input.float (0.098,         "   Engulf: Min Range (%)",                 minval=0.000001,maxval=50.0,    step=0.001, group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="Percentage"),            tooltip="Minimum engulfing candle range as percentage of current price.")
maxEngulfPct      = input.float (0.550,         "   Engulf: Max Range (%)",                 minval=0.000001,maxval=200.0,   step=0.001, group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="Percentage"),            tooltip="Maximum engulfing candle range as percentage of current price.")

// Engulf ATR mode--------------------------------------------------------------Engulf ATR mode---------------------------------------------------------------Engulf ATR mode---------------------------------------------------------------Engulf ATR mode---------------------------------------------------------------Engulf ATR mode-------------------------------------------------------------------------------------  
EngulfatrLength   = input.int   (14,            "   Engulf: ATR Length",                    minval=2,                                   group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="ATR Multiplier"),        tooltip="Uses ATR of the execution (lower) timeframe." )
engulfATR         = input.float (0.375,         "   Engulf: Min ATR Multiplier",            minval=0.000001,maxval=50.0,    step=0.1,   group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="ATR Multiplier"),        tooltip="Minimum range as multiple of ATR.")
maxEngulfATR      = input.float (2.5,           "   Engulf: Max ATR Multiplier",            minval=0.000001,maxval=200.0,   step=0.1,   group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="ATR Multiplier"),        tooltip="Maximum range as multiple of ATR.")

// Engulf Fixed mode--------------------------------------------------------------Engulf Fixed mode-------------------------------------------------------------- Engulf Fixed mode-------------------------------------------------------------- Engulf Fixed mode--------------------------------------------------------------Engulf Fixed mode-------------------------------------------------------------- -                                                               Fixed mode                                                                   Fixed mode
engulfFixed       = input.float (3.8,           "   Engulf: Min Range (Fixed)",             minval=0,                                   group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="Fixed"),                 tooltip="Fixed minimum range in price units.")
maxEngulfFixed    = input.float (25,            "   Engulf: Max Range (Fixed)",             minval=0,                                   group="Candlestick Settings (Engulf)",      display=display.none, active=(engulfMode=="Fixed"),                 tooltip="Fixed maximum range in price units.")
prevranPct        = input.float (0.60,          "   Previous Range (%)",                    minval=0,       maxval=1,       step=0.001, group="Candlestick Settings (Engulf)",      display=display.none,                                               tooltip="Prior candle range as percentage of the minimum engulfing candle range.\nThis percentage requirement is **only applies** when the candle immediately preceding the engulfing candle is the same color as the engulfing candle. When previous is opposite color, this check is skipped. Set to 0 to require strictly opposite-colored previous candle")

// Pin Bar settings-------------------------------------------------------------Pin Bar settings------------------------------------------------------------- Pin Bar settings------------------------------------------------------------- Pin Bar settings------------------------------------------------------------- Pin Bar settings-------------------------------------------------------------                                                               // Pin Bar settings                                                    // Pin Bar settings                                                                             // Pin Bar settings                                                                                                                                      
pinWickRatio      = input.float (3.0,           "   Pin Bar: Wick / Body Ratio",            minval=1.0,                     step=0.1,   group="Candlestick Settings (Pin Bar)",     display=display.none,                                               tooltip="Minimum ratio of the longer wick to body size. Note: A valid pin bar signal also requires a sweep of N-bar high/low AND an engulfing candle on the following bar.")
pinBodyMax        = input.float (0.20,          "   Pin Bar: Max Body / Range",             minval=0.0,     maxval=1.0,     step=0.05,  group="Candlestick Settings (Pin Bar)",     display=display.none,                                               tooltip="Maximum body size relative to the total range (high-low).")
pinWickMin        = input.float (0.70,          "   Pin Bar: Min Wick / Range",             minval=0.0,     maxval=1.0,     step=0.05,  group="Candlestick Settings (Pin Bar)",     display=display.none,                                               tooltip="Minimum length of the longer wick relative to total range.")
Pin_BarPct        = input.float (0.70,          "   Pin Bar Range (%)",                     minval=0,       maxval=1,       step=0.01,  group="Candlestick Settings (Pin Bar)",     display=display.none,                                               tooltip="Pin Bar candle range as percentage of the minimum engulfing candle range. (0.0-1.0 <-> 0-100%)")
SweepLookback     = input.int   (10,            "   Pin Bar Sweep Lookback (bars)",         minval=1,       maxval=500,     step=1,     group="Candlestick Settings (Pin Bar)",     display=display.none,                                               tooltip="Number of bars to look back for the sweep condition.\n\nA bullish pinbar must have its low below the lowest low of this many previous bars.\nA bearish pinbar must have its high above the highest high of this many previous bars.")

// Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------Gap & previous Range------------------------------------------------------------                                                                    Gap & previous Range                                                             Gap & previous Range 
gapAllowance      = input.int   (250,           "   Gap Allowance (ticks)",                 minval=0,                       step=1,     group="Candlestick Settings (Gap)",         display=display.none,                                               tooltip="(250 ticks = $0.250 However, tick values vary between brokers.)\n\nMaximum allowed price gap in the direction that invalidates the pattern.\n\nFor a bullish engulf:\n- Limits how far the current OPEN can be ABOVE the previous CLOSE (prevents invalid upward gaps).\n- Downward gaps (current open below previous close) are ALWAYS allowed.\n\nFor a bearish engulf:\n- Limits how far the current OPEN can be BELOW the previous CLOSE (prevents invalid downward gaps).\n- Upward gaps (current open above previous close) are ALWAYS allowed.")

//Risk & Reward Settings-----------------------------------------------------------Risk & Reward Settings---------------------------------------------------------------Risk & Reward Settings-------------------------------------------------------------------Risk & Reward Settings-----------------------------------------------------------------------------------
maxTrades         = input.int   (2,             "   Maximum Number of Trades Per Session",  minval=1,       maxval=10,      step= 1,    group="Risk & Reward Settings",             display=display.none,                                               tooltip="The trade counter reset frequency adapts to your selected lower timeframe. \n\nFor timeframes of 15 minutes or less, the counter resets at the beginning of each major session (Asia, London, and New York) to capitalize on intra-session volatility. \n\nFor timeframes greater than 15 minutes, the counter resets only once per day at the daily session start.")
riskTradepct1     = input.float (2,             "   Risk per Trade (%)",                    minval=0.01,    maxval=100,     step=0.01,  group="Risk & Reward Settings",             display=display.none)
risk_reward       = input.float (3,             "   Risk to Reward Ratio",                  minval=0.1,                     step=0.1,   group="Risk & Reward Settings",             display=display.none)
BarsNewEntries    = input.int   (4,             "   Min Bars Between Entries",              minval=0,       maxval=500,     step=1,     group="Risk & Reward Settings",             display=display.none,                                               tooltip="Minimum number of bars that must pass between consecutive entries.\n\nPrevents multiple entries on the same bar or too close together.\nSet to 0 to allow entries on consecutive bars.\n\nThis applies to both long and short entries.")
tradeOnFriday     = input.bool  (false,         "Allow Friday Trading",                                                                 group="Risk & Reward Settings",             display=display.none,                                               tooltip="When disabled, no new trades will be opened on Fridays. Existing positions are not affected.")

allow_two_trade   = input.bool  (true,          "Allow Second Trade",                                                                   group="Risk & Reward Settings - 2nd Trade", display=display.none,                                               tooltip="Allow another trade in the same direction.")
riskTradepct2     = input.float (1,             "   Risk Per Trade (%) (second trade)",     minval=0.01,    maxval=100,     step=0.01,  group="Risk & Reward Settings - 2nd Trade", display=display.none, active=allow_two_trade,                       tooltip="Active when 'Allow two trade' is enabled.")
risk_reward2      = input.float (3,             "   Risk to Reward (Second Trade)",         minval=0.1,                     step=0.1,   group="Risk & Reward Settings - 2nd Trade", display=display.none, active=allow_two_trade)

//--------Risk & Reward Settings (Stop-Loss)---------------------------------------------------------------------------------Risk & Reward Settings (Stop-Loss)-------------------------------------------------------------------------------------------------------Risk & Reward Settings (Stop-Loss)--------------------------------------------------------------------------------
stopLoseLevel     = input.string("Channel",     "   SL Reference",   options=["Low-High","Swing high/low","Channel","Fixed distance"],  group="Risk & Reward Settings (Stop-Loss)", display=display.none,                                               tooltip="Determines how the stop loss price is sourced. \n'Low-High' bases it on the low/high of the entry bar.\nSwing high/low looks back N bars for the highest high/lowest low, then applies the SL buffer. \n'Channel' uses the upper/lower channel bands, \n'Fixed distance' sets a fixed price offset from entry.")

showSLfixDistance = stopLoseLevel == "Fixed distance"
showSLHighLowSwing= stopLoseLevel == "Swing high/low"

high_maxcont      = input.int   (10,            "   Highest Price Bar",                     minval=0,                       step=1,     group="Risk & Reward Settings (Stop-Loss)", display=display.none, active=showSLHighLowSwing,                    tooltip="Number of bars to look back for the highest high. This value (plus the SL buffer) sets the initial stop-loss for SHORT positions.")
low_maxcount      = input.int   (10,            "   Lowest Price Bar",                      minval=0,                       step=1,     group="Risk & Reward Settings (Stop-Loss)", display=display.none, active=showSLHighLowSwing,                    tooltip="Number of bars to look back for the lowest low.\nThis value (minus the SL buffer) sets the initial stop-loss for LONG positions.")
SLfixDistance     = input.float (20,            "   Stop Loss Distance",                    minval=0.001,                   step=0.001, group="Risk & Reward Settings (Stop-Loss)", display=display.none, active=showSLfixDistance,                     tooltip="Sets the stop loss price distance when 'Fixed distance' is chosen as the SL reference. Enter a price distance from entry.")
slbuf             = input.int   (500,           "   Stop-Loss Buffer (ticks)",              minval=0,                       step=1,     group="Risk & Reward Settings (Stop-Loss)", display=display.none, active=not showSLfixDistance,                 tooltip="Adds a safety buffer below low (for longs) or above high (for shorts) to prevent stop-loss from being triggered by minor wicks, spread, or market noise.\n\n500 ticks = $0.50 However, tick values vary between brokers.")

ny_tz = "America/New_York"
bar_start_time    = time(timeframe.period, ny_tz)
bar_seconds       = timeframe.in_seconds()
bar_end_time      = na(bar_start_time) ? na : bar_start_time + (bar_seconds * 1000)

[lower_tfstr, trade_TF] = switch lower_tfInput 
    "1m"  => ["1",     1]
    "3m"  => ["3",     3]
    "5m"  => ["5",     5]
    "15m" => ["15",   15]
    "30m" => ["30",   30]
    "1H"  => ["60",   60]
    "4H"  => ["240", 240]
    "1D"  => ["D",  1440]

[higher_TFstr, Higher_TF] = switch _tfInput
    "1m"  => ["1" ,    1]
    "3m"  => ["3" ,    3]
    "5m"  => ["5" ,    5]
    "15m" => ["15" ,  15]
    "30m" => ["30" ,  30]
    "1H"  => ["60" ,  60]
    "4H"  => ["240", 240]
    "1D"  => ["D" , 1440]
    "1W"  => ["W", 10080]

chartTF           = timeframe.in_seconds() / 60
scalping          = trade_TF <= 15

//Manage Risk-----------------------------------------------------------------Manage Risk---------------------------------------------------------------Manage Risk-----------------------------------------------------------------------Manage Risk--------------------------------------------------------------Manage Risk---------------------------------------------
Tp_division       = input.bool    (false,   "Allow Partial TP   ",                                                                      group="Manage Risk - Partial TP & Break even", inline="BE",     display=display.none,                                   tooltip="Allow Partial TP: closing part of the trade at (Risk to Reward Ratio for TP1).\n\nAllow Break even: move stop loss to breakeven when reaching (Risk to Reward Ratio for TP1).")
breakeven         = input.bool    (false,   "Allow Break Even",                                                                         group="Manage Risk - Partial TP & Break even", inline="BE",     display=display.none)
risk_reward_BE    = input.float   (2,       "   Risk to Reward Ratio (TP1)",                minval=0.1,                     step=0.1,   group="Manage Risk - Partial TP & Break even",                  display=display.none, active=breakeven or Tp_division,  tooltip="The risk/reward level at which partial TP or breakeven is triggered.")
tp_pct            = input.float   (50,      "   Close % of the Position at TP1",            minval=0,       maxval=100,     step=10,    group="Manage Risk - Partial TP & Break even",                  display=display.none, active=Tp_division,               tooltip="Closing percentage of the position when (Risk to Reward Ratio for TP1) is triggered.")

//Manage Risk - Week/Dayend closing------------------------------------------------------------Manage Risk - Week/Dayend closing---------------------------------------------------Manage Risk - Week/Dayend closing--------------------------------------------------------------Manage Risk - Week/Dayend closing--------------------------
closeonDayEnd     = input.bool  (true,      "Close on Day End",                                                                         group="Manage Risk - Week/Day End closing",inline="DailyClose", display=display.none,                                   tooltip="Closes all positions at the configured day end time (NY timezone)")
closeonWeekEnd    = input.bool  (true,      "Close on Week End",                                                                        group="Manage Risk - Week/Day End closing",inline="DailyClose", display=display.none)
showdayendtime    = closeonDayEnd or closeonWeekEnd
TradeEndHour      = input.int   (17,        "      Day End Time :" + "  Hour",              minval=0,       maxval=23,                  group="Manage Risk - Week/Day End closing",inline="time_end",   display=display.none, active=showdayendtime)
TradeEndMin       = input.int   (00,        "  Min",                                        minval=0,       maxval=59,                  group="Manage Risk - Week/Day End closing",inline="time_end",   display=display.none, active=showdayendtime,            tooltip="Set the official End-of-Day (EOD) closing time. Must be in New York time zone.")

//Manage Risk - No Trade Windows-----------------------------------------------------------------Manage Risk - No Trade Windows----------------------------------------------------------------Manage Risk - No Trade Windows----------------------------------------------------------------Manage Risk - No Trade Windows--------------------------------------------
activNoTradeWin   = input.bool  (true,      "Enable No-Trade Windows",                                                                  group="Manage Risk - No Trade Windows",                         display=display.none,                                   tooltip="Prevents trading during high volatility, end of the day, excessive slippage periods. \nWhen enabled, trading will be blocked during specified time windows. Disable to allow trading at all times regardless of the configured windows.\n\n⚠️ Only active when lower timeframe ≤ 15m. For timeframes > 15m, no-trade windows are automatically disabled.")
showNoTradeInputs = activNoTradeWin 
noTradeStartHour1 = input.int   (16,        "  Start1" + "  Hour ",                         minval=0,       maxval=23,                  group="Manage Risk - No Trade Windows", inline="win2_start",    display=display.none, active=showNoTradeInputs,         tooltip="")
noTradeStartMin1  = input.int   (45,        "   Min",                                       minval=0,       maxval=59,                  group="Manage Risk - No Trade Windows", inline="win2_start",    display=display.none, active=showNoTradeInputs,         tooltip="(NY time zone) \nno-trade window1 starts (last 15m of the day by default).")
noTradeEndHour1   = input.int   (19,        "  End1" +   "   Hour ",                        minval=0,       maxval=23,                  group="Manage Risk - No Trade Windows", inline="win2_end",      display=display.none, active=showNoTradeInputs,         tooltip="")
noTradeEndMin1    = input.int   (05,        "   Min",                                       minval=0,       maxval=59,                  group="Manage Risk - No Trade Windows", inline="win2_end",      display=display.none, active=showNoTradeInputs,         tooltip="(NY time zone) \nno-trade window1 ends (One hour after opening by default).")

//filtering setup (EMA)---------------------------------filtering setup (EMA)-----------------------------------------filtering setup (EMA)---------------------------------------------------------filtering setup (EMA)-----------------------------------------------------------------------------filtering setup (EMA)---------------------------------------------------------------
allowEMAlower     = input.bool  (true,      "Allow EMA on Lower TimeFrame",                                                             group="filtering Settings (EMA)",                               display=display.none,                                   tooltip="Allow EMA on lower time frame to confirm the move.")
lenlowerTF        = input.int   (21,        "   EMA Length",                                minval=1,                                   group="filtering Settings (EMA)",                               display=display.none, active=allowEMAlower,             tooltip="The length of the exponential moving average on the smaller timeframe is used for trend confirmation.")
src1              = input       (close,     "   Source",                                                                                group="filtering Settings (EMA)",                               display=display.none, active=allowEMAlower)
offsetlower       = input.int   (0,         "   Offset",                                    minval=-500,    maxval=500,     step= 1,    group="filtering Settings (EMA)",                               display=display.none, active=allowEMAlower)

//filtering setup (EMA)---------------------------------filtering setup (EMA)-----------------------------------------filtering setup (EMA)---------------------------------------------------------filtering setup (EMA)-----------------------------------------------------------------------------filtering setup (EMA)---------------------------------------------------------------
allowEMA_HT       = input.bool  (true,      "Allow Higher TimeFrame EMA",                                                               group="filtering Settings (EMA)",                               display=display.none,                                   tooltip="Allow another EMA on higher time frame to confirm the trend.")
emaHT_Input       = input.string("1H",      "   TimeFrame",   options=["1m","5m","10m","15m","30m","1H","2H","4H","8H","1D","1W","1M"], group="filtering Settings (EMA)",                               display=display.none, active=allowEMA_HT,               tooltip="Higher timeframe for EMA calculation.\n\nThis EMA will reflect trends from the selected timeframe.")
HTemaLen          = input.int   (55,        "   EMA Length",                                minval=1,                                   group="filtering Settings (EMA)",                               display=display.none, active=allowEMA_HT,               tooltip="The length of the exponential moving average on the selected timeframe is used for the long term trend confirmation.")
HTemaSrc          = input       (close,     "   Source",                                                                                group="filtering Settings (EMA)",                               display=display.none, active=allowEMA_HT)
HTemaOffset       = input.int   (0,         "   Offset",                                    minval=-500,    maxval=500,     step= 1,    group="filtering Settings (EMA)",                               display=display.none, active=allowEMA_HT)

//filtering setup (RSI)----------------------------------------------------------------------filtering setup (RSI)----------------------------------------------------------------------filtering setup (RSI)----------------------------------------------------------------------
usingRSI          = input.bool  (true,      "Use RSI (Over Bought/Sold)",                                                               group="filtering Settings (RSI)",                               display=display.none,                                   tooltip="Prevent trades when overbought (RSI > 70) or oversold (RSI < 30).")
RSI_len           = input.int   (14,        "   RSI Length",                                minval=1,                                   group="filtering Settings (RSI)",                               display=display.none, active=usingRSI)

// Bollinger Band Width Settings-----------------------------------------------------------Bollinger Band Width Settings-----------------------------------------------------------Bollinger Band Width Settings-----------------------------------------------------------
BB_enabled        = input.bool  (true,      "Use Bollinger Band (Low Volatility)",                                                      group="filtering Settings (Bollinger Band)",                    display=display.none,                                   tooltip="Prevent trades during low volatility (sideways markets).")
bb_len            = input.int   (20,        "   BB Length",                                 minval=1,                                   group="filtering Settings (Bollinger Band)",                    display=display.none, active=BB_enabled)
bb_mult           = input.float (2.0,       "   BB Multiplier",                             minval=0.5,                 step=0.1,       group="filtering Settings (Bollinger Band)",                    display=display.none, active=BB_enabled)
bbThreshold       = input.float (0.002,     "   BB Width Threshold (below = sideways)",                                 step=0.0001,    group="filtering Settings (Bollinger Band)",                    display=display.none, active=BB_enabled,                tooltip="Lower value = detects sideways markets more aggressively.\nWhen BB width falls below this threshold, entries are blocked.")

//-filtering setup (Squeeze Momentum)-----------------------------------------------------------------filtering setup (Squeeze Momentum)-----------------------------------------------------------------filtering setup (Squeeze Momentum)-----------------------------------------------------------------
use_SQZMOM        = input.bool  (true,      "Use Squeeze Momentum",                                                                     group="filtering Settings (Squeeze Momentum)",                  display=display.none,                                   tooltip = "This uses a custom inverted setup compared to the standard SQZMOM convention.\nWhen enabled, the script calculates a regression value (val) to strictly control trade entry permissions:\nIf val < 0 → (Longs allowed) and (Shorts blocked).\nIf val > 0 → (Longs blocked) and (Shorts allowed).\nIf val == 0 → (Both directions allowed).")
length            = input.int   (20,        "   SQZ BB Length",                             minval=1,                   step=1,         group="filtering Settings (Squeeze Momentum)",                  display=display.none, active=use_SQZMOM)
mult              = input.float (2.0,       "   SQZ BB MultFactor",                                                                     group="filtering Settings (Squeeze Momentum)",                  display=display.none, active=use_SQZMOM)
lengthKC          = input.int   (20,        "   KC Length",                                 minval=1,                   step=1,         group="filtering Settings (Squeeze Momentum)",                  display=display.none, active=use_SQZMOM)
multKC            = input.float (1.5,       "   KC MultFactor",                                                                         group="filtering Settings (Squeeze Momentum)",                  display=display.none, active=use_SQZMOM)
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
[ema_HTFstr, emaHTF] = switch emaHT_Input
    "1m"   => ["1",        1]
    "3m"   => ["3",        3]
    "5m"   => ["5",        5]
    "10m"  => ["10",      10]
    "15m"  => ["15",      15]
    "30m"  => ["30",      30]
    "1H"   => ["60",      60]
    "2H"   => ["120",    120]
    "4H"   => ["240",    240]
    "8H"   => ["480",    480]
    "1D"   => ["1440",  1440]
    "1W"   => ["W",    10080]
    "1M"   => ["M", 43800.05]

// Get current time and day of week (New_York time zone)
currentTime = time(timeframe.period, ny_tz)
dayOfWeek   = dayofweek(currentTime)

var int positions       = 0
var int positionallowed = 2
var int Todaytrades     = 0
var int lastEntryBar    = -1
var int tradeCounter    = 0

var float EMALowerTF    = na
var float highestTF_ema = na
var float entryPrice1   = na
var float entryPrice2   = na
var float SH1TP         = na
var float L1TP          = na
var float SH2TP         = na
var float L2TP          = na
var float L1tp1         = na
var float SH1tp1        = na
var float L2tp1         = na
var float SH2tp1        = na

var bool low_volatility    = false
var bool allowLong         = false
var bool allowShort        = false
var bool closeAboveoutch1  = false 
var bool closeBelowoutch2  = false 
var bool isFirstNY         = false
var bool isFirstAsia       = false
var bool isFirstLON        = false
var bool sessionEnd        = false
var bool emaConfirm_buy    = false
var bool emaConfirm_sell   = false
var bool HTemaConfirm_buy  = false
var bool HTemaConfirm_sell = false
var bool SQZMOM_long       = false
var bool SQZMOM_short      = false
var bool emaHTerror        = false

var string activeID1 = na
var string activeID2 = na
mainExitID           = "EX: " 

// lines entry/TP/SL
var line[] position_lines = array.new_line()
// table
var warningTable = table.new(position.top_right, 2, 10, 
                   bgcolor=color.new(color.red, 90),
                   border_color=color.rgb(255, 82, 82, 40),
                   border_width=2 
                     ) 

isFirstBar  = session.isfirstbar
allWeekDays = (dayOfWeek == dayofweek.friday or dayOfWeek == dayofweek.monday 
            or dayOfWeek == dayofweek.tuesday or dayOfWeek == dayofweek.wednesday 
            or dayOfWeek == dayofweek.thursday or dayOfWeek == dayofweek.sunday 
            or dayOfWeek == dayofweek.saturday)

isFriday    = dayOfWeek == dayofweek.friday

// the opening time of the last bar
target_dayend_time        = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), TradeEndHour, TradeEndMin, 0) - (chartTF + 1) * 60000
// the notradewin start and end
target_t_notradewin_Start = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), noTradeStartHour1, noTradeStartMin1, 0) - (chartTF) * 60000
target_t_notradewin_End   = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), noTradeEndHour1, noTradeEndMin1, 0) - (chartTF) * 60000
// the NY session start 
target_NY_time            = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), 9, 30, 0) //- (chartTF + 1) * 60000
// the Asia session start 
target_ASIAN_time         = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), 20, 0, 0) //- (chartTF + 1) * 60000
// the London session start 
target_LON_time           = timestamp(ny_tz, year(currentTime), month(currentTime), dayofmonth(currentTime), 3, 30, 0) //- (chartTF + 1) * 60000

lastMinute  = currentTime <= target_dayend_time and bar_end_time > target_dayend_time
Close_Time  = (closeonDayEnd and scalping ? allWeekDays and lastMinute
              : closeonWeekEnd and trade_TF <= 240  ? isFriday and lastMinute : false) 

DayWeekEndclose_str = (closeonDayEnd and scalping ? "Dayend Close" 
                      : closeonWeekEnd and trade_TF <= 240 ? "WeekEnd Close" : "Disabled")

noTradesWinOn  = activNoTradeWin and scalping ? currentTime >= target_t_notradewin_Start and currentTime <= target_t_notradewin_End : false
plotNoTradeWin = noTradesWinOn and chartTF <= 15 and trade_TF <= 15

// Candlestick engulf, pinbar detection      
isBullish(_open, _close) => 
    _close > _open

isBearish(_open, _close) => 
    _close < _open

isinRange(value1, value2, _min, _max) => 
    math.abs(value1 - value2) >= _min and math.abs(value1 - value2) <= _max

bullishEngulf(_prerangeallow, prevOpen, prevClose, prevHigh, prevLow, currOpen, currClose, currHigh, currLow, bodyOnly) =>
    _prev_Level = isBearish(prevOpen, prevClose) ? prevOpen : prevHigh
    // Previous candle must be bearish or small bullish in predifined range limit, and current candle bullish
    (isBearish(prevOpen, prevClose) or ((prevOpen < prevClose) and (prevClose - prevOpen <= _prerangeallow))) // isBearish(prevIdx2Open, prevIdx2Close)) 
         and isBullish(currOpen, currClose) 
         and (bodyOnly ? (currOpen <= prevClose + (syminfo.mintick * gapAllowance) 
         and currClose > _prev_Level) : (currLow < prevLow 
         and currHigh > prevHigh))

bearishEngulf(_prerangeallow, prevOpen, prevClose, prevHigh, prevLow, currOpen, currClose, currHigh, currLow, bodyOnly) =>
    _prev_Level = isBullish(prevOpen, prevClose) ? prevOpen : prevLow
    // Previous candle must be bullish or bearish with predifined range limit, and current candle bearish
    (isBullish(prevOpen, prevClose) or ((prevOpen > prevClose) and (prevOpen - prevClose <= _prerangeallow)) ) //isBullish(prevIdx2Open, prevIdx2Close)) 
         and isBearish(currOpen, currClose) 
         and (bodyOnly ?  (currOpen >= prevClose - (syminfo.mintick * gapAllowance) 
         and currClose < _prev_Level) : (currLow < prevLow 
         and currHigh > prevHigh))

// Pin Bar detection
pinBar(Open_, Close_, High_, Low_, wickRatio, bodyMax, wickMin, minRange) =>

    range_   = High_ - Low_
    _inrange = range_ >= minRange
    if range_ == 0 or not _inrange
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

// clean up old lines
cleanupOldlines(lines_array, max_number) =>
        // deleting the OLDEST line 
    while array.size(lines_array) > max_number
        // Remove the first + deletes its child linefill
        oldest_line = array.shift(lines_array) 
        line.delete(oldest_line)

// Function to draw SL/TP lines extending 19 candles forward
draw_sl_tp_lines(entry_bar_index, _entry, sl_price, tp_price, tp_price1, draw_TP1, draw_BE) =>
    color_entry = color.rgb(255, 255, 255, 40)
    color_sl = color.new(color.red, 40)
    color_tp = color.new(color.green, 40)
    line_style = line.style_solid
    line_width = 1
    end_bar = bar_index + 33
    lines_per_trade = draw_TP1 or draw_BE ? 4 : 3
    // Draw SL line (horizontal)
    _entry_ = line.new(
                x1=entry_bar_index, y1=_entry,
                x2=end_bar, y2=_entry,
                color=color_entry, style=line_style, width=line_width,
                extend=extend.none  // 
                )
    _sl_    = line.new(
                x1=entry_bar_index, y1=sl_price,
                x2=end_bar, y2=sl_price,
                color=color_sl, style=line_style, width=line_width,
                extend=extend.none  // Don't extend automatically, we set exact x2
                )
    // Draw TP line (horizontal)
    _tp_    = line.new(
                x1=entry_bar_index, y1=tp_price,
                x2=end_bar, y2=tp_price,
                color=color_tp, style=line_style, width=line_width,
                extend=extend.none
                )
    array.push(position_lines, _entry_)
    array.push(position_lines, _sl_)
    array.push(position_lines, _tp_)
    
    // fill between lines
    linefill.new(_entry_, _tp_, color=color.new(#3fde39, 85))
    linefill.new(_entry_, _sl_, color=color.new(#de3939, 85))
    
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

// Size caculation
calc_qty(price, sl, _acct_risk) =>
    stopDist = math.abs(price - sl)
    stopDist == 0 ? 0 : math.max(math.floor(_acct_risk / stopDist), 1)

if isFirstBar
    sessionEnd  := false
// current position
in_long  = strategy.position_size > 0
in_short = strategy.position_size < 0

// EMA Channel
[out, ChannelATR]    = request.security(syminfo.tickerid, higher_TFstr, [ta.ema(src,len)[offset], ta.atr(channelatrLength)], lookahead=barmerge.lookahead_off) 

channelWidth   = channelWidthMode == "Percentage" ? close * (channelWidthPct / 100) :
                 channelWidthMode == "ATR Multiplier" ? ChannelATR * channelATRmulti : channelWidthFixed

outch1 = out + channelWidth / 2
outch2 = out - channelWidth / 2
// engulf max, min
atrValue = ta.atr(EngulfatrLength)
engulfrange    = engulfMode == "Percentage" ? close * (engulfPct / 100) :
                 engulfMode == "ATR Multiplier" ? atrValue * engulfATR : engulfFixed

maxengulfrange = engulfMode == "Percentage" ? close * (maxEngulfPct / 100) :
                 engulfMode == "ATR Multiplier" ? atrValue * maxEngulfATR : maxEngulfFixed  

prevrane = engulfrange * prevranPct

if scalping
    isFirstNY   := currentTime <= target_NY_time    and bar_end_time > target_NY_time  
    isFirstAsia := currentTime <= target_ASIAN_time and bar_end_time > target_ASIAN_time  
    isFirstLON  := currentTime <= target_LON_time   and bar_end_time > target_LON_time  
else 
    isFirstNY   := false
    isFirstAsia := false
    isFirstLON  := false
// Dayend Weekend Close all
if (Close_Time)
    strategy.close_all(comment= DayWeekEndclose_str)
    sessionEnd := true

closeAboveoutch1 := (close[1]  > outch1 and close  > outch1) 
closeBelowoutch2 := (close [1] < outch2 and close  < outch2) 

if ta.change(closeAboveoutch1) and closeAboveoutch1
    allowLong  := true
    allowShort := false
if ta.change(closeBelowoutch2) and closeBelowoutch2
    allowShort := true
    allowLong  := false

// EMA lowerTF 
if allowEMAlower 
    EMALowerTF       := ta.ema(src1,lenlowerTF)[offsetlower]
    emaConfirm_buy   := not na(EMALowerTF) and close > EMALowerTF 
    emaConfirm_sell  := not na(EMALowerTF) and close < EMALowerTF
else
    emaConfirm_buy   := true
    emaConfirm_sell  := true

// higher TR EMA 
if allowEMA_HT
    emaHTerror       := emaHTF < trade_TF
    highestTF_ema    := request.security(syminfo.tickerid, ema_HTFstr, ta.ema(HTemaSrc,HTemaLen)[HTemaOffset], lookahead=barmerge.lookahead_off) 
    HTemaConfirm_buy := close > highestTF_ema 
    HTemaConfirm_sell:= close < highestTF_ema
else 
    HTemaConfirm_buy := true
    HTemaConfirm_sell:= true

//rsi_calculated := request.security(syminfo.tickerid, higher_tf, ta.rsi(close, 14)[1], lookahead=barmerge.lookahead_off)//, gaps= barmerge.gaps_on) 
rsi_cal      = ta.rsi(close, RSI_len)
RSI_CON_buy  = usingRSI ? (not na(rsi_cal) and rsi_cal <= 70) : true
RSI_CON_sell = usingRSI ? (not na(rsi_cal) and rsi_cal >= 30) : true

// Calculate Bollinger Bands
if BB_enabled
    bb_basis = ta.sma(close, bb_len)
    bb_std   = ta.stdev(close, bb_len)
    bb_upper = bb_basis + (bb_std * bb_mult)
    bb_lower = bb_basis - (bb_std * bb_mult)
    bb_width = (bb_upper - bb_lower)  /bb_basis // Normalized bandwidth
    low_volatility := bb_width < bbThreshold
else
    low_volatility := false
// Time Window (no execution)
no_trade_window1_start = (noTradeStartHour1 * 60) + noTradeStartMin1   
no_trade_window1_end   = (noTradeEndHour1   * 60) + noTradeEndMin1  

// SQZMOM calculation
if use_SQZMOM
    //useTrueRange = input.bool(true, title="Use TrueRange (KC)")
    useTrueRange = true
    // Calculate BB
    source = close
    basis = ta.sma(source, length)
    dev = multKC * ta.stdev(source, length)
    upperBB = basis + dev
    lowerBB = basis - dev
    // Calculate KC
    ma = ta.sma(source, lengthKC)
    range_ = useTrueRange ? ta.tr : (high - low)
    rangema = ta.sma(range_, lengthKC)
    upperKC = ma + rangema * multKC
    lowerKC = ma - rangema * multKC

    sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
    sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
    noSqz  = (sqzOn == false) and (sqzOff == false)
    val = ta.linreg(source  -  math.avg(math.avg(ta.highest(high, lengthKC), ta.lowest(low, lengthKC)),ta.sma(close,lengthKC)), lengthKC,0)
    if val < 0 
        SQZMOM_long  := true
        SQZMOM_short := false
    else if val > 0 
        SQZMOM_long  := false
        SQZMOM_short := true
    else  
        SQZMOM_long  := true
        SQZMOM_short := true 

else  
    SQZMOM_long := true
    SQZMOM_short := true 

// trades counter
resetTradeContr = scalping ? (isFirstNY or isFirstAsia or isFirstLON) : isFirstBar
Todaytrades    := resetTradeContr ? 0 : Todaytrades

// Engulfing
isBullEngulf = bullishEngulf(prevrane, open[1], close[1], high[1], low[1], open, close, high, low, engulfBodyOnly) and isinRange(open, close, engulfrange, maxengulfrange)
isBearEngulf = bearishEngulf(prevrane, open[1], close[1], high[1], low[1], open, close, high, low, engulfBodyOnly) and isinRange(open, close, engulfrange, maxengulfrange)

// is previous PinBar
previsPinBar = pinBar(open[1], close[1], high[1], low[1], pinWickRatio, pinBodyMax, pinWickMin, (engulfrange * Pin_BarPct)) 


lastbottom = ta.lowest(low, SweepLookback)[2]
lastTop    = ta.highest(high, SweepLookback)[2]

isBullPinAndEngulf = lastbottom > low[1]  and previsPinBar == "bullish" and isBullish(open, close) and close > high[1] and isinRange(open, close, (engulfrange * Pin_BarPct), maxengulfrange) 
isBearPinandEngulf = lastTop    < high[1] and previsPinBar == "bearish" and isBearish(open, close) and close < low[1]  and isinRange(open, close, (engulfrange * Pin_BarPct), maxengulfrange) 

// Price is within channel range
priceInChannel = (open >= outch2 and open <= outch1)

//------------------------------------
shouldShow  = (chartTF <= Higher_TF) and (Higher_TF >= trade_TF)  and not emaHTerror
shouldTrade = chartTF == trade_TF and shouldShow

// ========== ENTRY CONDITIONS ==========
// long condition
longEntry = (shouldTrade and not noTradesWinOn and (tradeOnFriday or not isFriday)
             and allowLong and priceInChannel and (isBullEngulf or isBullPinAndEngulf) 
             and Todaytrades < maxTrades and not sessionEnd
             and RSI_CON_buy and (emaConfirm_buy or isBullPinAndEngulf) 
             and SQZMOM_long and not low_volatility and HTemaConfirm_buy)
// short condition
shortEntry = (shouldTrade and not noTradesWinOn and (tradeOnFriday or not isFriday)
             and allowShort and priceInChannel and (isBearEngulf or isBearPinandEngulf) 
             and Todaytrades < maxTrades and not sessionEnd 
             and RSI_CON_sell and (emaConfirm_sell or isBearPinandEngulf) 
             and SQZMOM_short and not low_volatility and HTemaConfirm_sell)

// ========== STOP LOSS AND TAKE PROFIT ==========
SL_Buffer = syminfo.mintick * slbuf
[long_sl, short_sl] = switch stopLoseLevel
    "Low-High"       => [low    - SL_Buffer    , high   + SL_Buffer]
    "Channel"        => [outch2 - SL_Buffer    , outch1 + SL_Buffer]
    "Fixed distance" => [close  - SLfixDistance, close  + SLfixDistance]
    "Swing high/low" => [ta.lowest(low, low_maxcount) - SL_Buffer, ta.highest(high, high_maxcont) + SL_Buffer]

acct_risk = (strategy.position_size == 0 
             ? strategy.equity * (riskTradepct1 / 100.0) 
             : strategy.equity * (riskTradepct2 / 100.0))

if strategy.position_size == 0 and bar_index > lastEntryBar 
    positions    := 0
    lastEntryBar := -1
    entryPrice1  := na
    entryPrice2  := na
    activeID1    := na
    activeID2    := na
    SH1TP        := na
    L1TP         := na
    SH2TP        := na
    L2TP         := na
    L1tp1        := na
    SH1tp1       := na
    L2tp1        := na
    SH2tp1       := na

// ========== EXECUTE TRADES ==========
if longEntry and positions < positionallowed and bar_index > lastEntryBar + BarsNewEntries
    entryPrice = close
    qty = calc_qty(entryPrice, long_sl, acct_risk) 
    if qty > 0  
        if strategy.position_size == 0
            entryPrice1:= entryPrice
            L1TP       := entryPrice + ((entryPrice - long_sl) * risk_reward)
            L1tp1      := entryPrice + ((entryPrice - long_sl) * risk_reward_BE)
            entryID     = str.tostring(tradeCounter)
            activeID1  := entryID        
            activeID2  := na 
            strategy.entry(entryID, strategy.long, qty)

            if Tp_division and risk_reward > risk_reward_BE
                strategy.exit("P/L: " + entryID,entryID, stop=long_sl, limit=L1tp1, qty_percent=tp_pct)
                strategy.exit(mainExitID + entryID, entryID, limit=L1TP, stop=long_sl, qty_percent=100)
            else
                strategy.exit(mainExitID + entryID, entryID, stop=long_sl, limit=L1TP)

            draw_sl_tp_lines(bar_index, entryPrice, long_sl, L1TP, L1tp1, Tp_division, breakeven) 
            tradeCounter := tradeCounter + 1
            Todaytrades  += 1
            positions    := positions + 1
            lastEntryBar := bar_index

        else if allow_two_trade and in_long 
            entryPrice2:= entryPrice
            L2TP       := entryPrice + ((entryPrice - long_sl) * risk_reward2)
            L2tp1      := entryPrice + ((entryPrice - long_sl) * risk_reward_BE)
            entryID     = str.tostring(tradeCounter)
            activeID2  := entryID
            strategy.entry(entryID, strategy.long, qty)

            if Tp_division and risk_reward2 > risk_reward_BE
                strategy.exit("P/L: " + entryID,entryID, stop=long_sl, limit=L2tp1, qty_percent=tp_pct)
                strategy.exit(mainExitID + entryID, entryID, limit=L2TP, stop=long_sl, qty_percent=100)
            else
                strategy.exit(mainExitID + entryID, entryID, stop=long_sl, limit=L2TP)

            tradeCounter := tradeCounter + 1
            positions    := positions + 1
            lastEntryBar := bar_index
            draw_sl_tp_lines(bar_index, entryPrice, long_sl, L2TP, L2tp1, Tp_division, breakeven)

if shortEntry and positions < positionallowed and bar_index > lastEntryBar + BarsNewEntries
    entryPrice = close
    qty = calc_qty(entryPrice, short_sl, acct_risk)
    if qty > 0  
        if strategy.position_size == 0
            entryPrice1:= entryPrice
            SH1TP      := (entryPrice - ((short_sl - entryPrice ) * risk_reward)) 
            SH1tp1     := entryPrice - ((short_sl - entryPrice) * risk_reward_BE)
            entryID     = str.tostring(tradeCounter)
            activeID1  := entryID        
            activeID2  := na 
            strategy.entry(entryID, strategy.short, qty)

            if Tp_division and risk_reward > risk_reward_BE
                strategy.exit("P/L: " + entryID, entryID, stop=short_sl, limit=SH1tp1, qty_percent=tp_pct)
                strategy.exit(mainExitID + entryID, entryID, stop=short_sl, limit=SH1TP, qty_percent=100)
            else
                strategy.exit(mainExitID + entryID, entryID, stop=short_sl, limit=SH1TP)

            tradeCounter := tradeCounter + 1
            Todaytrades  += 1
            positions    := positions + 1
            lastEntryBar := bar_index
            draw_sl_tp_lines(bar_index, entryPrice, short_sl, SH1TP, SH1tp1, Tp_division, breakeven)

        else if allow_two_trade and in_short
            entryPrice2:= entryPrice
            SH2TP      := (entryPrice - ((short_sl - entryPrice ) * risk_reward2)) 
            SH2tp1     := entryPrice - ((short_sl - entryPrice) * risk_reward_BE)
            entryID     = str.tostring(tradeCounter) 
            activeID2  := entryID
            strategy.entry(entryID, strategy.short, qty)

            if Tp_division and risk_reward2 > risk_reward_BE
                strategy.exit("P/L: " + entryID, entryID, stop=short_sl, limit=SH2tp1, qty_percent=tp_pct)
                strategy.exit(mainExitID + entryID, entryID, stop=short_sl, limit=SH2TP, qty_percent=100)
            else    
                strategy.exit(mainExitID + entryID, entryID, stop=short_sl, limit=SH2TP)
                  
            tradeCounter := tradeCounter + 1
            positions    := positions + 1
            lastEntryBar := bar_index
            draw_sl_tp_lines(bar_index, entryPrice, short_sl, SH2TP, SH2tp1, Tp_division, breakeven)
 
if breakeven and in_long

    BE1 = not na(activeID1) and high >= L1tp1
    BE2 = not na(activeID2) and high >= L2tp1
    
    if BE1 and risk_reward > risk_reward_BE 

        strategy.cancel("P/L: " + activeID1) 
        strategy.cancel(mainExitID + activeID1)
        strategy.exit(mainExitID + activeID1, activeID1, stop=entryPrice1, limit=L1TP, qty_percent=100)

    if BE2 and risk_reward2 > risk_reward_BE

        strategy.cancel("P/L: " + activeID2) 
        strategy.cancel(mainExitID + activeID2)
        strategy.exit(mainExitID + activeID2, activeID2, stop=entryPrice2, limit=L2TP, qty_percent=100)

if breakeven and in_short 

    BE1          = not na(activeID1) and low <=SH1tp1
    BE2          = not na(activeID2) and low <= SH2tp1

    if BE1 and risk_reward > risk_reward_BE 

        strategy.cancel("P/L: " + activeID1) 
        strategy.cancel(mainExitID + activeID1)
        strategy.exit(mainExitID + activeID1, activeID1, stop=entryPrice1, limit=SH1TP, qty_percent=100)

    if BE2 and risk_reward2 > risk_reward_BE

        strategy.cancel("P/L: " + activeID2) 
        strategy.cancel(mainExitID + activeID2)
        strategy.exit(mainExitID + activeID2, activeID2, stop=entryPrice2, limit=SH2TP, qty_percent=100)

// ========== VISUAL ON CHART ==========
if shouldTrade

    table.clear(warningTable, 0, 0, 1, 9)
    table.set_border_color(warningTable,color.gray)
    table.set_bgcolor(warningTable, color.rgb(255,255,255,95))
    table.set_frame_color(warningTable,color.gray)
    table.cell(warningTable, 0, 0, "Market Status",                                                                             text_size=size.small, text_color = color.rgb(43, 141, 222), tooltip = "Indicates current market bias based on price closing outside the channel bands (upper/lower). Bullish = price closed above upper band. Bearish = price closed below lower band")
    table.cell(warningTable, 1, 0, allowLong ? "BULLISH" : "BEARISH",                                                            text_size=size.small, text_color = allowLong ? color.green : color.red)

    table.cell(warningTable, 0, 1, "Higher TF",                                                                                 text_size=size.small, text_color = color.rgb(43, 141, 222))
    table.cell(warningTable, 1, 1, _tfInput,                                                                                    text_size=size.small, text_color = color.rgb(255, 255, 255, 20))

    table.cell(warningTable, 0, 2, "EMA Lower TF",                                                                              text_size=size.small, text_color = color.rgb(43, 141, 222), tooltip = "CONFIRMING BUY = price above EMA. CONFIRMING SELL = price below EMA. Green = aligns with current market bias. Red = conflicts with market bias.")
    table.cell(warningTable, 1, 2, not allowEMAlower ? "Disabled" : emaConfirm_buy   ? "CONFIRMING BUY" : "CONFIRMING SELL",      text_size=size.small, text_color = allowEMAlower ? allowLong ? emaConfirm_buy ? color.green : color.red:emaConfirm_sell ? color.green : color.red : color.white)

    table.cell(warningTable, 0, 3, "EMA Higher TF",                                                                              text_size=size.small, text_color = color.rgb(43, 141, 222), tooltip = "CONFIRMING BUY = price above EMA. CONFIRMING SELL = price below EMA. Green = aligns with current market bias. Red = conflicts with market bias.")
    table.cell(warningTable, 1, 3, not allowEMA_HT   ? "Disabled" : HTemaConfirm_buy ? "CONFIRMING BUY" : "CONFIRMING SELL",    text_size=size.small, text_color = allowEMA_HT ? allowLong ? HTemaConfirm_buy ? color.green : color.red: HTemaConfirm_sell ? color.green : color.red : color.white)

    table.cell(warningTable, 0, 4, "Channel Mode\n-------------\nChannel Width",                                                text_size=size.small, text_color = color.rgb(43, 141, 222))
    table.cell(warningTable, 1, 4, channelWidthMode + "\n-------------\n" + str.tostring(channelWidth, "#.######") + " $",      text_size=size.small, text_color = color.rgb(255, 255, 255, 20))

    table.cell(warningTable, 0, 5, 
                    "Engulfing Mode\n-------------\nEngulfing Min\n-------------\nEngulfing Max\n-------------\nPrevious Range",   text_size=size.small, text_color = color.rgb(43, 141, 222))
    table.cell(warningTable, 1, 5, engulfMode + "\n-------------\n" 
                                                    + str.tostring(engulfrange, "#.######") + " $\n-------------\n"
                                                    + str.tostring(maxengulfrange, "#.######") + " $\n-------------\n" 
                                                    + str.tostring(prevrane, "#.######") + " $",                                   text_size=size.small, text_color = color.rgb(255, 255, 255, 20))

    table.cell(warningTable, 0, 6, showSLfixDistance ? "Stop Loss Reference" + "\n-------------\n" +  "SL Distance" :
                                                        "Stop Loss Reference" + "\n-------------\n" + "SL Buffer" ,              text_size=size.small, text_color = color.rgb(43, 141, 222))     
    table.cell(warningTable, 1, 6, showSLfixDistance ? stopLoseLevel + "\n-------------\n" 
                                    + str.tostring(SLfixDistance, "#.###") + " $" 
                                    : stopLoseLevel + "\n-------------\n" + str.tostring(SL_Buffer, "#.###") + " $",               text_size=size.small, text_color = color.rgb(255, 255, 255, 20)) 

    table.cell(warningTable, 0, 7, "No Trades Window",                                                                          text_size=size.small, text_color = color.rgb(43, 141, 222), tooltip = "Red = within no-trade window. Green = outside no-trade window. Gray = feature disabled.")
    table.cell(warningTable, 1, 7, activNoTradeWin ? "Enabled" : "Disabled",                                                    text_size=size.small, text_color =  not activNoTradeWin ? color.gray : not noTradesWinOn ? color.green : color.red)

    table.cell(warningTable, 0, 8, "Day/Week-End Close" ,                                                                       text_size=size.small, text_color = color.rgb(43, 141, 222), tooltip = "Indicates when positions are closed or evaluated. If lower timeframe is 15min or less, this refers to daily close. If the lower timeframe is above 15min, this switches to weekly close for swing trading strategy.")
    table.cell(warningTable, 1, 8, DayWeekEndclose_str,                                                                         text_size=size.small, text_color = DayWeekEndclose_str == "Disabled" ? color.gray :color.green)

    table.cell(warningTable, 0, 9, "Filters",                                                                                   text_size=size.small ,text_color = color.rgb(43, 141, 222))
    filters = ""
    if usingRSI or BB_enabled or use_SQZMOM
        if usingRSI
            filters += " RSI "
        if BB_enabled
            filters += " BB "
        if use_SQZMOM
            filters += " SQZMOM"
    else 
        filters += " NONE "

    table.cell(warningTable, 1, 9, filters, text_size=size.small, text_color = usingRSI or BB_enabled or use_SQZMOM ? color.green : color.gray)

else     
    table.clear(warningTable, 0, 0, 1, 9)
    table.cell(warningTable, 0, 0, "⛔ WRONG TIMEFRAME",                                    text_color=color.white, text_size=size.normal)
    table.cell(warningTable, 0, 1, "Required: " + lower_tfInput + " for strategy execution", text_color=color.white, text_size=size.small)

if (chartTF > Higher_TF) and (Higher_TF >= trade_TF)

    table.clear(warningTable, 0, 0, 1, 9)
    table.cell(warningTable, 0, 0, "⛔ WRONG TIMEFRAME" + str.tostring(chartTF),                                          text_color=color.white, text_size=size.normal)
    table.cell(warningTable, 0, 1, "Required: " + lower_tfInput + " for strategy execution",       text_color=color.white, text_size=size.small)
    table.cell(warningTable, 0, 2, "Required: " + _tfInput + " or lower to show EMA plots",        text_color=color.white, text_size=size.small)   

else if (Higher_TF < trade_TF)

    table.clear(warningTable, 0, 0, 1, 9)
    table.cell(warningTable, 0, 0, "⛔ WRONG TIMEFRAME",                                          text_color=color.white, text_size=size.normal)
    table.cell(warningTable, 0, 1, "The (Lower timeframe) is greater than the (higher timeframe).", text_color=color.white, text_size=size.small)
    table.cell(warningTable, 0, 2, "Required: (Lower timeframe) <= (higher timeframe).",            text_color=color.white, text_size=size.small)  
    table.cell(warningTable, 0, 3, "Set a higher (Higher Timeframe) from the settings.",            text_color=color.white, text_size=size.small)         

else if emaHTerror

    table.clear(warningTable, 0, 0, 1, 9)
    table.cell(warningTable, 0, 0, "⛔ WRONG HT EMA",                                             text_color=color.white, text_size=size.normal)
    table.cell(warningTable, 0, 1, 
                             "The Higher TimeFrame EMA setting is smaller than the Lower TimeFrame.", text_color=color.white, text_size=size.small)
    table.cell(warningTable, 0, 2, "Required: (Higher TimeFrame EMA) >= (Lower TimeFrame).",  text_color=color.white, text_size=size.small)  
    table.cell(warningTable, 0, 3, "Set a higher (Higher Timeframe EMA) from the settings.",       text_color=color.white, text_size=size.small) 

// Plot channel
// plot(shouldShow ? out       : na , color=color.rgb(251, 35, 35, 80),  title="SMA",                 linewidth=2, display=display.pane + display.price_scale)
Upper = plot(shouldShow ? outch1     : na , color=color.rgb(251, 35, 35, 80), title="Upper Channel",       linewidth=1, display=display.pane + display.price_scale)
Lower = plot(shouldShow ? outch2     : na , color=color.rgb(251, 35, 35, 80), title="Lower Channel",       linewidth=1, display=display.pane + display.price_scale)
fill(Upper, Lower, color=color.new(#de3939, 85))

// Plot EMAs
plot(chartTF <=  emaHTF 
             ? highestTF_ema : na , color=color.rgb(235, 28, 28, 40),   title="Higher TimeFrame EMA", linewidth=1, display=display.pane + display.price_scale)
plot(chartTF ==  trade_TF 
             ? EMALowerTF    : na , color=color.rgb(75, 197, 34, 40),   title="Lower TimeFrame EMA",linewidth=1, display=display.pane + display.price_scale)

// Plot entry signals
plotshape(longEntry,        title="Long Signal",         location=location.belowbar, color=color.rgb(76, 175, 79, 25),   style=shape.arrowup,   text="Long",                 size=size.normal, textcolor=color.rgb(89, 247, 87, 40),   display=display.pane)
plotshape(shortEntry,       title="Short Signal",        location=location.abovebar, color=color.rgb(255, 82, 82, 25),   style=shape.arrowdown, text="Short",                size=size.normal, textcolor=color.rgb(255, 37, 37, 35),   display=display.pane)
plotshape(resetTradeContr , title="Reset trade counter", location=location.abovebar, color=color.rgb(224, 228, 223, 37), style=shape.arrowdown, text="Reset Trade\ncounter", size=size.small,  textcolor=color.rgb(243, 245, 248, 54), display=display.pane)

// Plot bg
bgcolor((Close_Time or sessionEnd) 
        and shouldTrade ? color.new(#f1f1f1, 90) : na, title = "Week/Day end close")
bgcolor( plotNoTradeWin ? color.new(#ff5252, 90) : na, title = "No_trade_window")
````
