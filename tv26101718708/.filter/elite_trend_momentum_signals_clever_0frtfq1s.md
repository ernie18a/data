# Elite Trend & Momentum Signals [CLEVER]

- url: https://www.tradingview.com/script/0fRtFq1S-Elite-Trend-Momentum-Signals-CLEVER/
- type: indicator
- pine_id: PUB;9949b80b85f8493f906182c92d7cc5f4
- version: 1.0

## Description

📊 Elite Trend & Momentum Signals [CLEVER] 

This indicator is an advanced multi-confirmation trading system designed to analyze market trend, momentum, and strength together before generating buy or sell signals. It follows a confluence-based approach, meaning signals are only created when several conditions align at the same time, rather than relying on a single indicator.

At its core, the script uses an ATR-based trailing stop to track price movement and define trend direction. When price stays above the trailing stop, the market is considered bullish, and when it moves below it, the market is considered bearish. This dynamic structure helps the indicator adapt to changing volatility conditions.

To improve trend accuracy, the indicator also uses the EMA 200 as a major trend filter. Price above EMA 200 confirms a bullish environment, while price below it confirms bearish bias. An optional faster EMA filter (EMA 50) can further refine entries by filtering weaker setups inside the main trend.

Momentum confirmation is handled through RSI and a custom Pulse Oscillator. RSI determines whether buying or selling pressure is dominant, while the oscillator visually represents momentum strength using a histogram style. This combination helps identify whether price movement has real strength behind it or is weak and corrective.

The system also includes multiple filters to reduce false signals. The ADX filter ensures that signals only appear in strong trending conditions. Volume confirmation ensures that market participation is high enough to validate the move. These filters help the indicator avoid ranging or low-quality market conditions.

Multi-timeframe functionality is also supported, allowing the indicator to use higher timeframe data for trend confirmation. This improves accuracy but may cause slight signal adjustments until the higher timeframe candle is fully closed, which is normal behavior in MTF systems.

Visually, the indicator provides a clean structure using trend clouds, buy and sell labels, EMA lines, and a pulse oscillator pane. These visual tools help traders quickly understand trend direction, momentum strength, and potential entry zones without analyzing complex data manually.

A dashboard system is included to display real-time market information such as ADX strength, volume status, momentum reading, trend direction, and timeframe context. This allows quick decision-making without needing additional indicators.

Additionally, a power meter feature visually represents market strength from 0% to 100% using a neon-style candle. It also shows BUY or SELL sentiment based on current conditions, giving a simplified overview of market pressure.

The indicator also includes a divergence detection system that identifies potential reversals. Bullish divergence occurs when price forms lower lows but momentum forms higher lows, suggesting weakening downside pressure. Bearish divergence occurs when price forms higher highs but momentum forms lower highs, indicating weakening upside strength.

Overall, this is a structured, multi-layer trading model that combines trend following, momentum analysis, volume confirmation, and divergence detection into one system. It is designed to filter out weak setups and highlight only higher-probability trading conditions while maintaining clean visual interpretation.

🧠 Core Concept — Elite Trend & Momentum Signals 

The core idea of this indicator is to behave like a multi-layer market filter system, not a simple signal tool. It only allows a trade signal when the market structure, trend direction, momentum, and strength are all pointing in the same direction. This is the main “house rule” behind the script: no single condition is enough — everything must agree.

At the foundation, the system uses an ATR-based trailing stop to define market direction. This trailing stop automatically adjusts with volatility, meaning the indicator does not rely on fixed levels. Instead, it continuously follows price movement and classifies the market as bullish when price stays above it and bearish when price falls below it. This creates a dynamic trend structure that adapts to different market conditions.

On top of this structure, the indicator applies a trend confirmation layer using EMA 200. This acts like a higher-level filter that defines the broader market bias. If price is above EMA 200, the system only prefers long setups. If below, it only prefers short setups. This ensures trades are aligned with the dominant market direction rather than against it.

The next layer is momentum validation using RSI and a Pulse Oscillator. RSI checks whether buying or selling pressure is strong enough to support a move, while the oscillator visually represents momentum expansion or weakness. This prevents the system from taking trades in weak or exhausted market moves where direction exists but strength is missing.

Then comes the strength filter layer using ADX and Volume. ADX ensures the market is actually trending and not ranging, while volume confirms real participation behind the move. This step is critical because many false signals in trading come from low-strength or low-liquidity conditions. The system intentionally blocks those situations.

The indicator also follows a strict signal discipline rule (cooldown + confirmation logic). This prevents repeated or noisy signals in choppy markets and ensures that entries are spaced and meaningful rather than spam-like.

In advanced mode, the system can use multi-timeframe confirmation, meaning higher timeframe structure is used to validate lower timeframe entries. This increases accuracy but introduces a normal behavior: signals may slightly adjust until the higher timeframe candle closes. This is not repainting in a broken sense — it is how higher timeframe data naturally stabilizes.

Finally, everything is tied together under one rule: a signal is only valid when trend, momentum, strength, and volatility all align at the same time. If even one condition disagrees, the system rejects the trade. This is what makes the indicator “institutional-style” in logic — it prioritizes quality over frequency.

In simple terms, the core concept is:
👉 “Trade only when the market structure supports the direction, momentum confirms it, and strength validates it.”

🔑 Key Features 
1. Multi-Condition Signal System

This script generates buy and sell signals only when multiple conditions align together. It combines trend direction, momentum strength, volatility, and market participation to avoid weak or random entries.

2. ATR-Based Trend Structure

It uses an ATR-based trailing mechanism to track price movement and define the current trend. This helps the system adapt dynamically to volatility instead of relying on fixed levels.

3. EMA 200 Trend Filter

The EMA 200 acts as a long-term trend filter. Signals are only considered valid when they align with the broader market direction, helping to avoid counter-trend noise.

4. Momentum Confirmation (RSI)

RSI is used to confirm whether price has enough momentum in the direction of the trade. This reduces entries during weak or exhausted moves.

5. Trend Strength Filter (ADX)

ADX ensures that trades are taken only when the market is actually trending with sufficient strength, filtering out sideways or choppy conditions.

6. Volume / Activity Filter

The script checks for volume (or volatility) confirmation to ensure that signals are supported by real market participation instead of low-liquidity movement.

7. Multi-Timeframe Support (Optional)

It can pull data from a higher timeframe to align trades with bigger market structure, improving signal reliability for intraday trading.

8. Signal Cooldown Protection

A cooldown system prevents back-to-back signals in a short period. This reduces overtrading and noise in ranging markets.

9. Anti-Repaint Confirmation Mode

Signals can be locked on candle close, helping reduce real-time signal fluctuation during live candles and improving consistency on completed bars.

10. Trend Cloud Visualization

A visual cloud shows bullish or bearish market structure based on smoothed price ranges, making trend identification easier at a glance.

11. Pulse Momentum Oscillator

A built-in oscillator measures short-term momentum pressure, helping confirm whether trend direction has strength behind it.

12. Divergence Detection (Advanced Option)

Detects bullish and bearish divergences between price and momentum, which can signal potential reversals or weakening trends.

13. Market Power Meter

A visual gauge combines RSI and price range position to estimate buying or selling pressure in real time.

📘 How to Use It

🧭 Market Direction Rule (EMA 200 Filter)

The first and most important rule is to always identify the overall market direction using the EMA 200. This acts as the backbone of the entire strategy. When price is trading above the EMA 200, the market is considered bullish and you should only look for buy setups. When price is below the EMA 200, the market is bearish and only sell setups are valid. If you ignore this rule, you will end up taking trades against the main trend, which significantly reduces accuracy and increases risk.

⚙️ Trend Confirmation Rule (ATR-Based Structure)

After identifying direction, the next step is confirming whether the market is actually trending or just moving sideways. The indicator uses an ATR-based trailing structure to measure real movement in price. When the trend is clear, price follows a smooth directional path. When the market is choppy, the trailing logic will keep shifting frequently. In such conditions, trades should be avoided because uncertainty is high and signals become less reliable.

📊 Momentum Confirmation Rule (RSI Filter)

Momentum is confirmed using RSI, which ensures that price has enough strength behind its move. For buy setups, RSI should be above 50, showing bullish momentum. For sell setups, RSI should be below 50, showing bearish momentum. If RSI is in the middle range or not aligned with the trade direction, it means the market lacks strong momentum and the signal should be ignored. This rule helps avoid weak or delayed entries.

📈 Market Strength Rule (ADX Filter)

ADX is used to measure how strong the trend actually is, regardless of direction. A high ADX value means the market is trending strongly, while a low ADX indicates a ranging or weak environment. Trades should only be taken when ADX is above the defined threshold because strong signals require strong market conditions. If ADX is low, even valid-looking signals should be avoided because the market may not sustain the move.

📦 Volume Participation Rule

Volume confirms whether real participation is supporting the move. If price is moving with high volume, it means genuine market interest is present. If volume is low, the move is weak and can easily reverse. This rule is essential for filtering out false breakouts and fake signals. A valid trade setup must always have supportive volume or volatility conditions to ensure reliability.

🧠 Fast Trend Filter Rule (Optional EMA 50)

When enabled, the fast EMA filter adds an extra layer of confirmation inside the trend. For buy trades, price must remain above the fast EMA, and for sell trades, price must remain below it. This helps refine entries by ensuring that even short-term movement aligns with the main direction. It is especially useful in fast-moving markets where early entries can be risky.

⏳ Candle Close Confirmation Rule (Anti-Repaint Logic)

This rule ensures that signals are only considered valid after the candle has fully closed. During live candle movement, signals can change or fluctuate, which may lead to false entries. By waiting for candle close confirmation, the strategy becomes more stable and reliable. This rule is important for reducing noise and improving consistency in real trading conditions.

🔁 Signal Cooldown Rule (Anti Overtrading Control)

After a valid signal appears, the system applies a cooldown period before allowing another signal. This prevents multiple entries in the same market move and avoids overtrading. It ensures that traders only take high-quality setups instead of reacting to every minor fluctuation. This rule helps maintain discipline and improves overall trade quality.

📉 Divergence Rule (Advanced Reversal Insight)

Divergence is used as an advanced tool to detect possible market reversals. When price forms a lower low but momentum forms a higher low, it indicates bullish divergence and potential upward reversal. Similarly, when price forms a higher high but momentum weakens, it indicates bearish divergence. However, divergence should only be used as confirmation near key levels, not as a standalone entry signal.

🎯 Final Execution Rule (Full Confluence Requirement)

A trade is only valid when all major conditions align together. This includes trend direction, momentum strength, market strength, volume confirmation, and candle close validation. If even one condition is missing, the trade should be skipped. The core idea of this system is not frequency but quality, meaning fewer trades but higher probability setups.

🧠 How This System Works 

This indicator works like a layered decision engine, not a simple signal tool. It does not rely on one condition. Instead, it builds a stack of confirmations, and only when most layers agree, a BUY or SELL signal is generated.

🧭 Step 1 — Market Direction Layer (Trend Foundation)

The system first reads the overall direction using EMA 200 and ATR-based trend behavior. This is the foundation layer.

If price is above EMA 200, the system assumes the market is in a bullish environment. If price is below EMA 200, it assumes bearish structure. At the same time, ATR-based trailing logic tracks whether price is actually respecting that direction or just moving sideways.

👉 If this layer is not clear, the system becomes cautious and avoids signals.

⚙️ Step 2 — Trend Validation Layer (Structure Check)

After direction is identified, the system checks whether the trend is actually stable or not. It uses a trailing stop mechanism based on volatility (ATR) to see if price is truly trending.

In strong trends, price moves cleanly away from the trailing stop. In weak markets, price keeps crossing it frequently.

👉 If structure is unstable, signals are filtered out.

📊 Step 3 — Momentum Layer (RSI Confirmation)

Once trend is confirmed, the system checks momentum using RSI.

If RSI is above 50, it confirms bullish pressure. If RSI is below 50, it confirms bearish pressure. This ensures that price is not only trending but also has internal strength supporting the move.

👉 If momentum disagrees with trend, the signal is rejected.

📈 Step 4 — Strength Layer (ADX Filter)

ADX acts like a trend quality detector. It does not care about direction, only strength.

High ADX → strong trend environment
Low ADX → weak or sideways market

The system only allows signals when ADX confirms that the market has enough energy to continue moving.

👉 Weak trend = no trade, even if other conditions are correct.

📦 Step 5 — Participation Layer (Volume Filter)

This layer checks whether real market participation exists behind the move.

If volume is above average, it means institutions or strong participants are active. If volume is low, the move is weak and unreliable.

👉 This layer protects against fake breakouts and low-liquidity traps.

🧠 Step 6 — Entry Refinement Layer (Fast EMA Filter)

If enabled, the system adds a faster EMA filter to refine entries.

This ensures that short-term price action is also aligned with the main direction. It helps avoid early or premature entries during pullbacks or corrections.

👉 This layer improves precision inside trending markets.

⏳ Step 7 — Timing Layer (Candle Close Logic)

The system can wait for candle close confirmation before validating signals.

This is important because during live candles, price constantly changes and can temporarily trigger false signals. By locking signals after candle close, the system improves stability and reduces repaint-like behavior.

👉 This layer ensures cleaner and more reliable signals.

🔁 Step 8 — Signal Control Layer (Cooldown System)

After a signal is generated, the system enforces a cooldown period.

This prevents repeated signals during the same market movement and avoids overtrading. It forces the trader to wait for a new structure instead of chasing every small fluctuation.

👉 This layer protects discipline and reduces noise trading.

📉 Step 9 — Divergence Layer (Reversal Detection)

This is the advanced layer that detects early reversals using price vs momentum behavior.

If price continues making new highs but momentum weakens, it signals possible bearish reversal. If price makes new lows but momentum strengthens, it signals possible bullish reversal.

👉 This layer is not for entry alone, but for early warning and confirmation.

🎯 Final Decision Engine (How Signal is Actually Created)

A BUY or SELL signal is only generated when multiple layers align together:

Trend direction agrees
Momentum supports direction
Market strength is sufficient
Volume confirms participation
Entry timing is stable
No cooldown restriction

If even one major layer fails, the signal is blocked.

🧩 Simple Reality of How It Works

This system behaves like a filter stack machine:

It first understands trend
Then checks strength
Then confirms momentum
Then validates participation
Then refines entry timing
Then finally allows signal

👉 Result: fewer signals, but higher quality setups.

⚠️ Key Understanding

This indicator is designed for discipline-based trading, not fast random entries. Its strength is not in frequency but in confluence filtering, where only high-probability market conditions are allowed to pass through all layers.

⚙️ Core Logic Settings (Market Behavior Control)

The core settings control how the indicator understands overall market structure and how it builds signals. Multi-Timeframe (MTF) allows the system to use a higher timeframe trend while you trade on a lower timeframe, which improves stability and reduces noise. The timeframe setting decides the base data window, where higher timeframes produce smoother but slower signals, and lower timeframes produce faster but more reactive signals. Sensitivity controls how easily signals are generated; lower sensitivity produces fewer but stronger setups, while higher sensitivity increases signal frequency but also increases noise. ATR length controls how volatility is measured and directly affects how tightly or loosely the trailing logic follows price movement.

📊 Signal Filter Settings (Quality Control Layer)

The signal filters act as protection layers that decide whether a trade is valid or not. The ADX filter ensures that trades are only allowed when the market has enough trend strength, preventing entries during weak or sideways conditions. The volume filter confirms whether real market participation is supporting the move, helping to avoid fake breakouts or low-liquidity spikes. The RSI filter checks momentum alignment, ensuring that trades follow actual buying or selling pressure. The fast EMA filter adds an extra layer of precision by confirming short-term trend direction. Signal cooldown controls how often signals can appear, preventing overtrading and repeated entries in the same move.

🎨 Visual Settings (Display & Clarity Layer)

The visual settings do not affect trading logic but improve readability and decision-making. The trend cloud visually shows whether the market is bullish or bearish, helping traders quickly understand structure. The oscillator display shows momentum strength, indicating whether buying or selling pressure is increasing or decreasing. The dashboard provides real-time data such as ADX strength, volume status, and momentum values, allowing quick confirmation without deep analysis. The power meter visually represents overall market pressure, combining multiple factors into a single strength gauge for easier interpretation.

🧠 Advanced Safety Settings (Execution Control Layer)

These settings control how stable and safe the signals are during live market conditions. Candle close confirmation ensures that signals are only generated after a candle fully closes, which prevents signal fluctuation during live movement and improves reliability. Performance mode disables heavy visual elements to improve speed and reduce system load, especially useful on lower-performance devices or when focusing only on signals. These settings ensure that the system remains stable, efficient, and consistent during real-time trading conditions.

🧩 Final Customization Principle 

The most important rule in customization is not to weaken all filters at the same time. If sensitivity is increased while ADX, RSI, and volume filters are disabled, the system becomes noisy and loses its structured logic. The strength of this indicator comes from layered confirmation, not from signal frequency. Proper customization means balancing speed and safety rather than trying to maximize signals. A disciplined configuration keeps the system aligned with its original purpose, which is high-quality, filtered, and structured trade signals.

🧠 How the Whole System Works (Full Combined Explanation)

This indicator works like a multi-layer decision machine where different technical tools are combined together. Instead of relying on one signal, it builds a complete “confirmation chain” from trend → strength → momentum → volume → timing. Only when most layers agree, a BUY or SELL signal is created.

📊 Trend Foundation (EMA 200 + ATR Structure)

The system first builds the main market direction using EMA 200. This defines the long-term bias of the market. If price is above EMA 200, the system assumes bullish structure; if below, bearish structure. Along with this, ATR-based trailing logic follows price movement and checks whether the trend is stable or unstable. This combination ensures the system does not trade against the main market flow.

⚙️ Trend Behavior Engine (ATR Trailing System)

After direction is identified, the ATR-based trailing mechanism tracks price movement dynamically. It creates a flexible stop-like structure that moves with volatility. If price respects this structure, it confirms that the trend is strong. If price keeps breaking and crossing it, the system understands that the market is choppy and avoids taking trades. This is how the system separates trending vs ranging markets.

📈 Momentum Layer (RSI + Pulse Oscillator)

Once trend is confirmed, the system checks momentum strength using RSI and a custom oscillator. RSI ensures whether buyers or sellers are actually in control (above 50 = bullish, below 50 = bearish). The pulse oscillator measures short-term acceleration and slowdown in price movement. Together, they confirm whether the trend has real strength or is losing energy.

📊 Strength Layer (ADX Filter)

ADX is used to measure the quality of the trend, not direction. Even if price is moving up or down, ADX checks whether the movement is strong enough to trade. High ADX means strong trending market, while low ADX means weak or sideways market. This layer blocks all weak market conditions and allows trades only when momentum has real structure behind it.

📦 Participation Layer (Volume Filter)

Volume acts like a confirmation of real market activity. If volume is high, it means real buyers or sellers are participating in the move. If volume is low, the move is weak and often fake. This layer protects the system from false breakouts and low-quality price spikes. Without volume confirmation, even a good-looking signal is rejected.

🧠 Precision Layer (Fast EMA Filter)

The fast EMA filter adds a short-term trend check inside the main trend. It ensures that price is not only aligned with long-term direction but also with short-term momentum. This helps avoid early or premature entries during pullbacks and improves timing accuracy inside strong trends.

⏳ Timing Layer (Candle Close Confirmation)

This layer ensures that signals are only valid after a candle fully closes. During live candles, price constantly changes and can temporarily trigger false signals. By locking signals after candle close, the system removes noise and improves reliability. This is an important stability feature that prevents false real-time signals.

🔁 Control Layer (Signal Cooldown System)

After a signal is generated, the system activates a cooldown period. This prevents multiple signals in the same move and avoids overtrading. It forces discipline by ensuring that traders wait for a new market structure instead of reacting to every small movement.

📉 Advanced Layer (Divergence Detection)

The divergence system compares price movement with momentum behavior. If price makes a new high but momentum weakens, it signals potential bearish reversal. If price makes a new low but momentum strengthens, it signals bullish reversal. This layer is not for direct entries but for early warning of possible market reversals.

🧩 Final Decision System (How Everything Combines)

All layers work together like a filter stack system:

Trend direction is identified (EMA 200 + ATR)
Market strength is checked (ADX)
Momentum is confirmed (RSI + oscillator)
Participation is verified (Volume)
Timing is validated (candle close)
Entry precision is refined (fast EMA)
Signal cooldown controls repetition

Only when ALL important conditions align, the system releases a BUY or SELL signal.

🎯 Simple Understanding (In One Line)

👉 This system does not “predict” market direction — it filters low-quality market conditions and only allows high-probability setups to pass through multiple confirmations.

⚠️ HTF (Higher Timeframe) Misleading Issue — Explained Deeply

When you enable Multi-Timeframe (HTF/MTF) in this system, it pulls trend data from a higher timeframe (like 1H, 4H, or 1D) and applies it to your current chart. This improves overall trend accuracy, but it also introduces a common problem called HTF lag or misleading signals.

🧠 Why HTF Can Become Misleading

Higher timeframe data does not update every small candle like lower timeframes. Instead, it only fully confirms when its own candle closes. Because of this, the system is working with unfinished information during live movement.

So what happens is:

The HTF trend looks stable
But inside the lower timeframe, price is already changing direction
This creates a temporary mismatch between HTF trend and real price action

👉 This is why signals may look correct at first, but later feel delayed or slightly off.

⏳ Candle Completion Delay Problem

On higher timeframes, each candle represents a large time period. Until that candle closes:

Trend direction can remain “partially formed”
Price can move inside it in opposite direction
The system still reads the older HTF structure

👉 This delay creates the illusion that the trend is strong, while lower timeframe already shows weakness.

📊 Signal Lag Effect (Why Entry Feels Late)

Because HTF updates slowly, signals based on it can:

Appear slightly delayed
Confirm after a move has already started
Enter when lower timeframe pullback is already done

👉 This is called lagging confirmation effect, not repainting, but delayed alignment.

🔁 False Alignment During Volatility

In fast-moving markets, lower timeframe can reverse quickly, but HTF still shows the previous trend.

Example behavior:

HTF still bullish
LTF already bearish pullback
System still allows buy bias

👉 This creates temporary misleading direction conflict

⚖️ When HTF Works Best

HTF becomes powerful only when:

Market is trending strongly
No major news volatility
Structure is clean and directional

In these conditions:

HTF filters noise
Signals become high quality
Fake moves are reduced
❌ When HTF Becomes Dangerous

HTF becomes misleading in:

Sideways markets
High volatility spikes
Sudden reversals
News-driven candles

In these cases:

HTF lags behind reality
Signals may appear late or wrong
Lower timeframe tells the real story first
🧩 Simple Understanding

👉 HTF = “Big picture trend lens”
👉 LTF = “real-time market behavior”

When both match → strong signal
When they differ → confusion or delay

🎯 Final House Rule (Very Important)

If using HTF:

Do not blindly trust HTF direction alone
Always confirm with lower timeframe structure
Avoid trading during fast reversals or news spikes
Treat HTF as “filter”, not “decision maker”

⚠️ Final Note (House Rules Safe Disclaimer)

This indicator is a technical analysis tool only and is designed to help you understand market structure, trend direction, and momentum conditions. It does not predict the market, guarantee profits, or ensure accurate outcomes in every situation. All signals generated are based on historical price data combined with mathematical filters such as trend, momentum, volatility, and volume, which means results can change depending on market conditions.

🧠 No Financial Advice Clause

This system is strictly for educational and informational purposes. It should not be considered financial advice, investment advice, or a recommendation to buy or sell any asset. Every trading decision remains the responsibility of the user. You should always apply your own analysis, strategy, and risk management before entering any trade.

⚠️ Market Risk Warning

Financial markets are highly volatile and unpredictable. Even with strong filters like trend confirmation, ADX strength, RSI momentum, and volume validation, losses can still occur. No indicator can remove risk completely. Sudden news events, liquidity changes, or market manipulation can override all technical signals instantly.

🔁 Signal Limitation Disclaimer

Signals generated by this system are based on structured conditions, but they are not perfect. They may appear late, early, or sometimes fail due to changing market behavior. Higher timeframe data may also introduce delays or temporary mismatches with lower timeframe price action. Users must understand that signals are probabilistic, not guaranteed outcomes.

🧩 Execution Responsibility Rule

This system does not execute trades, manage risk, or protect capital. It only provides visual and logical conditions for analysis. All entries, exits, stop-loss placement, and risk decisions are fully controlled by the trader. Poor risk management can still lead to losses even with high-quality signals.

🎯 Final House Rule Statement

By using this indicator, you agree that:

👉 You understand trading involves risk
👉 You will not rely on signals blindly
👉 You will use proper risk management
👉 You accept full responsibility for all trading decisions

📌 Simple Closing Line

👉 This tool improves decision-making, but it does not remove uncertainty from the market.

## Source Code

````pine
//@version=6
// Elite Trend & Momentum Signals [CLEVER]
// 
// Quick Start Guide:
// 1. Trend: Ensure price is above/below the EMA 200 (white line).
// 2. Momentum: Look for signals aligned with the Pulse Oscillator color.
// 3. Confirmation: Signals only appear when Volume and ADX filters are met.
// 4. Sensitivity: Lower values = more signals (aggressive), Higher = fewer (conservative).
// 5. Repaint: Signals are confirmed on candle close.
// 
// This indicator combines trend-following and momentum concepts to highlight potential buy and sell opportunities.
// 
// Features:
// - ATR-based trailing logic
// - EMA trend filter
// - RSI momentum filter
// - Volume and ADX confirmation
// - Optional multi-timeframe analysis
// 
// Notes:
// - Live Mode: Signals may update during live candle movement.
// - Confirmed Mode: Signals are confirmed on candle close. No repaint on closed candles in the current timeframe. When using multi-timeframe data, signals may update until higher timeframe candle closes.
// - Multi-timeframe data is used when enabled.
// - This script does not use future data.
// - Signals are derived from price data and may update during live candles until confirmation.
// - Divergence signals are based on pivot detection and may appear with delay due to confirmation logic.
// - This tool is for educational purposes only.
// 
// No guarantee of profitability. Use proper risk management.

indicator("Elite Trend & Momentum Signals [CLEVER]", shorttitle="Elite", overlay=false, format=format.price, precision=2, max_lines_count=100, max_labels_count=100)

// ==========================================
// --- Premium Color Palette ---
// ==========================================
color_bull     = #00fff2 // Neon Cyan/Green
color_bear     = #dd00ff // Neon Pink/Red
color_neutral  = #607d8b
color_bg       = #080a12
color_gold     = #ffb300
color_white    = #ffffff

// ==========================================
// --- Inputs ---
// ==========================================
grp_logic = "Core Signal Strategy"
useMTF      = input.bool(false, "Enable Multi-Timeframe", group=grp_logic)
tf          = input.timeframe("60", "Select Timeframe", group=grp_logic)
sensitivity = input.float(2.5, "Signal Sensitivity", minval=1.0, maxval=5.0, step=0.1, tooltip="Controls signal frequency. Lower = More signals (riskier), Higher = Fewer signals (more reliable)")
atrLen      = input.int(10, "ATR Smoothing", minval=1, tooltip="Adjusts how closely the signal follows price volatility.")

grp_filters = "Signal Confirmation Filters (Power Mode)"
useAdx      = input.bool(true, "Trend Strength Filter (ADX)", tooltip="Only signals in strong trends", group=grp_filters)
adxThreshold = input.int(20, "ADX Threshold", minval=10, group=grp_filters)
useVol      = input.bool(true, "Volume Confirmation", tooltip="Only signals with high volume", group=grp_filters)
useRsi      = input.bool(true, "Momentum Filter (RSI)", group=grp_filters)
rsiLen      = input.int(14, "RSI Length", group=grp_filters)
useFastEma  = input.bool(false, "Fast Trend Filter (EMA 50)", tooltip="Adds a faster EMA filter to refine entries in trending markets.", group=grp_filters)
fastEmaLen  = input.int(50, "Fast EMA Length", minval=10, group=grp_filters)
signalCooldown = input.int(5, "Signal Cooldown (Bars)", minval=0, tooltip="Prevents multiple signals from appearing too close to each other (reduces noise in ranging markets).", group=grp_filters)

grp_visuals = "Aesthetic & Decoration"
showCloud   = input.bool(true, "Neon Trend Cloud", group=grp_visuals)
showDash    = input.bool(true, "Elite HUD Dashboard", group=grp_visuals)
dashPos     = input.string("Top Right", "HUD Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"], group=grp_visuals)
perfMode    = input.bool(false, "Performance Mode (High Speed)", tooltip="Disables heavy visuals (HUD, Power Meter, & Divergence) for maximum speed on low-end systems.", group=grp_visuals)
confirmedSignals = input.bool(true, "Wait for Candle Close (Anti-Repaint)", tooltip="Signals are confirmed on candle close. No repaint on closed candles in the current timeframe. When using multi-timeframe data, signals may update until higher timeframe candle closes.", group=grp_visuals)

grp_osc = "Elite Pulse Oscillator"
showOsc     = input.bool(true, "Show Pulse Oscillator", group=grp_osc)
oscLen      = input.int(20, "Oscillator Length", group=grp_osc)
oscMult     = input.float(2.0, "Squeeze Factor", group=grp_osc)

// --- MTF Data Fetching ---
f_get_data() =>
    [close, high, low, volume, ta.atr(atrLen), ta.ema(close, 200), ta.rsi(close, rsiLen), ta.ema(close, fastEmaLen)]

[src_raw, high_raw, low_raw, vol_raw, atr_raw, ema200_raw, rsi_raw, emaFast_raw] = f_get_data()

src    = useMTF ? request.security(syminfo.tickerid, tf, src_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : src_raw
h      = useMTF ? request.security(syminfo.tickerid, tf, high_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : high_raw
l      = useMTF ? request.security(syminfo.tickerid, tf, low_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : low_raw
v      = useMTF ? request.security(syminfo.tickerid, tf, vol_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : vol_raw
xATR   = useMTF ? request.security(syminfo.tickerid, tf, atr_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : atr_raw
ema200_val = useMTF ? request.security(syminfo.tickerid, tf, ema200_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : ema200_raw
rsi_val    = useMTF ? request.security(syminfo.tickerid, tf, rsi_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : rsi_raw
emaFast_val = useMTF ? request.security(syminfo.tickerid, tf, emaFast_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : emaFast_raw

// --- STABILIZED Signal Logic ---
float nLoss = sensitivity * xATR

var float trailStop = 0.0
trailStop := src[1] > nz(trailStop[1], 0) ? math.max(nz(trailStop[1], 0), src[1] - nLoss) : 
             src[1] < nz(trailStop[1], 0) ? math.min(nz(trailStop[1], 0), src[1] + nLoss) : 
             src[1] > nz(trailStop[1], 0) ? src[1] - nLoss : src[1] + nLoss

// Trend sentiment (Stabilized to prevent blinking)
var int trailTrend = 0
if src[1] > trailStop
    trailTrend := 1
else if src[1] < trailStop
    trailTrend := -1

bool rawBuy  = ta.crossover(src, trailStop)
bool rawSell = ta.crossunder(src, trailStop)

// --- Signal Confirmation Filters ---
[plus, minus, adxVal] = ta.dmi(14, 14)
adxConfirm = not useAdx or adxVal > adxThreshold
avgVol = ta.sma(v, 20)
volConfirm = not useVol or v > avgVol
rsiBuyConfirm = not useRsi or rsi_val > 50
rsiSellConfirm = not useRsi or rsi_val < 50
emaBuy = src > ema200_val
emaSell = src < ema200_val
fastEmaConfirmBuy = not useFastEma or src > emaFast_val
fastEmaConfirmSell = not useFastEma or src < emaFast_val

// --- FINAL FILTERED SIGNALS WITH GLOBAL COOLDOWN ---
var int lastSignalBar = -100

// Signal logic with optional 'Wait for Close' (Anti-Repaint)
buyLogic  = rawBuy and adxConfirm and volConfirm and rsiBuyConfirm and emaBuy and fastEmaConfirmBuy
sellLogic = rawSell and adxConfirm and volConfirm and rsiSellConfirm and emaSell and fastEmaConfirmSell

buySignal  = (confirmedSignals ? buyLogic[1] : buyLogic) and (bar_index - lastSignalBar > signalCooldown)
sellSignal = (confirmedSignals ? sellLogic[1] : sellLogic) and (bar_index - lastSignalBar > signalCooldown)

if buySignal or sellSignal
    lastSignalBar := bar_index

// ==========================================
// --- Visual Decoration (Elite Pro) ---
// ==========================================

// 1. Bar Coloring (Applied to the Oscillator Pane)
barcolor(trailTrend == 1 ? color_bull : color_bear, title="Oscillator Bar Color")

// 2. Neon Trend Cloud (On Main Chart)
smaHigh = ta.sma(h, 20)
smaLow = ta.sma(l, 20)
var int hlv = 0
hlv := src > smaHigh ? 1 : src < smaLow ? -1 : nz(hlv[1], 1)
cloudTop = hlv == 1 ? smaHigh : smaLow
cloudBot = hlv == 1 ? smaLow : smaHigh

// Trend Flip Dots
bool trendFlip = ta.change(hlv) != 0
plotshape(trendFlip and hlv == 1, "Bull Trend Flip", shape.circle, location.belowbar, color_bull, size=size.tiny, force_overlay=true)
plotshape(trendFlip and hlv == -1, "Bear Trend Flip", shape.circle, location.abovebar, color_bear, size=size.tiny, force_overlay=true)

p1 = plot(showCloud ? cloudTop : na, "Cloud High", color=hlv == 1 ? color.new(color_bull, 85) : color.new(color_bear, 85), linewidth=1, force_overlay=true)
p2 = plot(showCloud ? cloudBot : na, "Cloud Low", color=hlv == 1 ? color.new(color_bull, 90) : color.new(color_bear, 90), linewidth=1, force_overlay=true)
fill(p1, p2, color=hlv == 1 ? color.new(color_bull, 96) : color.new(color_bear, 96), title="Trend Cloud")

// Clean Buy/Sell Labels (On Main Chart)
plotshape(buySignal,  "Buy Label",  style=shape.labelup,   location=location.belowbar, color=color.new(color_bull, 10), text="BUY",  textcolor=color_bg, size=size.small, force_overlay=true)
plotshape(sellSignal, "Sell Label", style=shape.labeldown, location=location.abovebar, color=color.new(color_bear, 10), text="SELL", textcolor=color_white, size=size.small, force_overlay=true)

// EMA 200 Neon Line (On Main Chart)
plot(ema200_val, "Base EMA", color=color.new(color_white, 40), linewidth=2, style=plot.style_line, force_overlay=true)

// ==========================================
// --- Elite Pulse Oscillator (New Pane) ---
// ==========================================
// Squeeze / Momentum Hybrid
basis = ta.sma(src, oscLen)
dev = oscMult * ta.stdev(src, oscLen)
upperBB = basis + dev
lowerBB = basis - dev
ma = ta.sma(src, oscLen)
dist = src - ma
oscVal = ta.linreg(dist, oscLen, 0)

// Visuals
col_osc = oscVal > 0 ? (oscVal > nz(oscVal[1]) ? color_bull : color.new(color_bull, 50)) : (oscVal < nz(oscVal[1]) ? color_bear : color.new(color_bear, 50))
plot(showOsc ? oscVal : na, "Pulse Momentum", color=col_osc, style=plot.style_columns)
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dotted)

// ==========================================
// --- Elite HUD Dashboard ---
// ==========================================
var table hud = na
if showDash and not perfMode and barstate.islast
    string pos = dashPos == "Top Right" ? position.top_right : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_left
    hud := table.new(pos, 2, 8, bgcolor=color.new(color_bg, 5), border_width=1, border_color=color.new(color_white, 80))
    
    table.cell(hud, 0, 0, "✦ ELITE V2 HUD ✦", text_color=color_white, text_size=size.small, bgcolor=color.new(color_white, 90), text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    // Rows
    table.cell(hud, 0, 1, "TREND POWER", text_color=color.new(color_white, 50), text_size=size.small)
    table.cell(hud, 1, 1, str.tostring(adxVal, "#.#"), text_color=adxVal > 25 ? color_bull : color_neutral, text_size=size.small)
    
    table.cell(hud, 0, 2, "VOL CONFIRM", text_color=color.new(color_white, 50), text_size=size.small)
    table.cell(hud, 1, 2, volConfirm ? "ACTIVE ✓" : "LOW ✗", text_color=volConfirm ? color_bull : color_bear, text_size=size.small)
    
    table.cell(hud, 0, 3, "PULSE MOM", text_color=color.new(color_white, 50), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(oscVal, "#.#"), text_color=col_osc, text_size=size.small)
    
    table.cell(hud, 0, 4, "DAY RANGE", text_color=color.new(color_white, 50), text_size=size.small)
    d_high = request.security(syminfo.tickerid, "D", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    d_low = request.security(syminfo.tickerid, "D", low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    d_range_perc = ((d_high - d_low) / d_low) * 100
    table.cell(hud, 1, 4, str.tostring(d_range_perc, "#.##") + "%", text_color=color_white, text_size=size.small)

    table.cell(hud, 0, 5, "SIGNAL", text_color=color.new(color.white, 50), text_size=size.small)
    table.cell(hud, 1, 5, trailTrend == 1 ? "BULLISH" : "BEARISH", text_color=trailTrend == 1 ? color_bull : color_bear, text_size=size.small)
    
    if useFastEma
        table.cell(hud, 0, 6, "FAST TREND", text_color=color.new(color_white, 50), text_size=size.small)
        table.cell(hud, 1, 6, src > emaFast_val ? "UP" : "DOWN", text_color=src > emaFast_val ? color_bull : color_bear, text_size=size.small)

    table.cell(hud, 0, 7, "TIMEFRAME", text_color=color.new(color_white, 50), text_size=size.small)
    table.cell(hud, 1, 7, useMTF ? tf : timeframe.period, text_color=color_white, text_size=size.small)



// ==========================================
// ==========================================
// --- Elite Power Meter (Giant Neon Candle) ---
// ==========================================
var box meterBg   = box.new(na, na, na, na, bgcolor=color.new(color_bg, 70), border_color=color.new(color_white, 0), border_width=2, force_overlay=true)
var box meterFill = box.new(na, na, na, na, border_color=na, force_overlay=true)
var line topWick  = line.new(na, na, na, na, color=color.new(color_white, 0), width=2, force_overlay=true)
var line botWick  = line.new(na, na, na, na, color=color.new(color_white, 0), width=2, force_overlay=true)
var label meterLb = label.new(na, na, "", color=color.new(color_white, 100), textcolor=color_white, style=label.style_label_center, size=size.huge, force_overlay=true)

if barstate.islast and not perfMode
    // Calculate Power with stability
    d_h = nz(request.security(syminfo.tickerid, "D", high, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off), high)
    d_l = nz(request.security(syminfo.tickerid, "D", low, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off), low)
    range_pos = ((close - d_l) / math.max(d_h - d_l, 0.000001)) * 100
    float powerVal = math.min(math.max((range_pos + rsi_val) / 2, 0), 100)
    
    // "Giant Candle" Dimensions
    float h_size = ta.atr(14) * 4 
    int left   = bar_index + 40
    int right  = bar_index + 50
    float bottom = close - h_size
    float top    = close + h_size
    float fillTop = bottom + (top - bottom) * (powerVal / 100)
    
    // Update Body (Box)
    box.set_lefttop(meterBg, left, top)
    box.set_rightbottom(meterBg, right, bottom)
    
    // Update Fill (Inside)
    box.set_lefttop(meterFill, left + 1, fillTop)
    box.set_rightbottom(meterFill, right - 1, bottom)
    box.set_bgcolor(meterFill, color.new(color_white, 20))
    
    // Update Wicks
    midX = (left + right) / 2
    line.set_xy1(topWick, midX, top)
    line.set_xy2(topWick, midX, top + (h_size * 0.4))
    line.set_xy1(botWick, midX, bottom)
    line.set_xy2(botWick, midX, bottom - (h_size * 0.4))
    
    // Update Label (Sentiment + Percentage)
    string sentiment = powerVal >= 50 ? " BUY" : " SELL"
    color txtColor   = color_white
    
    label.set_xy(meterLb, midX, close)
    label.set_text(meterLb, str.tostring(powerVal, "0") + "%" + sentiment)
    label.set_textcolor(meterLb, txtColor)
    label.set_size(meterLb, size.large)

// ==========================================
// --- RSI Divergence Detection ---
// ==========================================
grp_div = "Divergence Settings"
showDivMain = input.bool(true, "Show Div on Main Chart (Overlay)", group=grp_div)
showDivOsc  = input.bool(true, "Show Div on Oscillator Pane", group=grp_div)
useDivLogic = input.bool(true, "Enable Divergence Scanning", tooltip="Divergence signals are based on pivot detection and may appear with delay due to confirmation logic.", group=grp_div)
divLookback = input.int(5, "Pivot Lookback", minval=2, maxval=15, group=grp_div)
divMaxBars  = input.int(60, "Max Divergence Bars", group=grp_div)

// Pivot detection on price only
priceLow  = (not perfMode and useDivLogic) ? ta.pivotlow(l, divLookback, divLookback) : na
priceHigh = (not perfMode and useDivLogic) ? ta.pivothigh(h, divLookback, divLookback) : na

// Get Oscillator value at the exact bar of the price pivot
oscLowAtPivot  = not na(priceLow) ? oscVal[divLookback] : na
oscHighAtPivot = not na(priceHigh) ? oscVal[divLookback] : na

// Track previous pivot values
var float prevPriceLow  = na
var int   prevPriceLowBar = na
var float prevOscLow    = na

var float prevPriceHigh = na
var int   prevPriceHighBar = na
var float prevOscHigh   = na

// --- Bullish Divergence: Price Lower Low + Osc Higher Low ---
bool bullDiv = false
if not na(priceLow)
    if not na(prevPriceLow) and not na(prevOscLow)
        if priceLow < prevPriceLow and oscLowAtPivot > prevOscLow and (bar_index - prevPriceLowBar) <= divMaxBars
            bullDiv := true
            if showDivMain
                line.new(prevPriceLowBar, prevPriceLow, bar_index - divLookback, priceLow, color=color_bull, width=2, style=line.style_solid, force_overlay=true)
                label.new(bar_index - divLookback, priceLow, "BULL DIV", color=color.new(color_bull, 20), textcolor=color_bg, style=label.style_label_up, size=size.tiny, force_overlay=true)
            if showDivOsc
                line.new(prevPriceLowBar, prevOscLow, bar_index - divLookback, oscLowAtPivot, color=color_bull, width=2, style=line.style_solid)
                label.new(bar_index - divLookback, prevOscLow, "BULL DIV", color=color.new(color_bull, 20), textcolor=color_bg, style=label.style_label_up, size=size.tiny)
    prevPriceLow    := priceLow
    prevPriceLowBar := bar_index - divLookback
    prevOscLow      := oscLowAtPivot

// --- Bearish Divergence: Price Higher High + Osc Lower High ---
bool bearDiv = false
if not na(priceHigh)
    if not na(prevPriceHigh) and not na(prevOscHigh)
        if priceHigh > prevPriceHigh and oscHighAtPivot < prevOscHigh and (bar_index - prevPriceHighBar) <= divMaxBars
            bearDiv := true
            if showDivMain
                line.new(prevPriceHighBar, prevPriceHigh, bar_index - divLookback, priceHigh, color=color_bear, width=2, style=line.style_solid, force_overlay=true)
                label.new(bar_index - divLookback, priceHigh, "BEAR DIV", color=color.new(color_bear, 20), textcolor=color_white, style=label.style_label_down, size=size.tiny, force_overlay=true)
            if showDivOsc
                line.new(prevPriceHighBar, prevOscHigh, bar_index - divLookback, oscHighAtPivot, color=color_bear, width=2, style=line.style_solid)
                label.new(bar_index - divLookback, prevOscHigh, "BEAR DIV", color=color.new(color_bear, 20), textcolor=color_white, style=label.style_label_down, size=size.tiny)
    prevPriceHigh    := priceHigh
    prevPriceHighBar := bar_index - divLookback
    prevOscHigh      := oscHighAtPivot

// --- Divergence Highlights (Global Scope) ---
plotshape(bullDiv ? priceLow : na,  "Bull Div Highlight",     shape.circle, location.absolute, color.new(color_bull, 0), offset=-divLookback, size=size.tiny, force_overlay=true)
plotshape(bullDiv ? oscLowAtPivot : na, "Bull Div Osc Highlight", shape.circle, location.absolute, color.new(color_bull, 0), offset=-divLookback, size=size.tiny)
plotshape(bearDiv ? priceHigh : na, "Bear Div Highlight",     shape.circle, location.absolute, color.new(color_bear, 0), offset=-divLookback, size=size.tiny, force_overlay=true)
plotshape(bearDiv ? oscHighAtPivot : na, "Bear Div Osc Highlight", shape.circle, location.absolute, color.new(color_bear, 0), offset=-divLookback, size=size.tiny)

// ==========================================
// --- Alerts ---
// ==========================================
alertcondition(buySignal,  "Elite Buy",  "Buy signal detected")
alertcondition(sellSignal, "Elite Sell", "Sell signal detected")
alertcondition(bullDiv, "Bullish Divergence", "RSI Bullish Divergence detected!")
alertcondition(bearDiv, "Bearish Divergence", "RSI Bearish Divergence detected!")
````
