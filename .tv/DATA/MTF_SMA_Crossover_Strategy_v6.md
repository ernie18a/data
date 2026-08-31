<!-- tradingview-pine-id: PUB;af62d0063bd9486d870a998711b0bd10 -->
<!-- tradingviewscripts-format: 1 -->
# MTF SMA Crossover Strategy v6

Source: https://www.tradingview.com/script/jcysZ6nI-MTF-SMA-Crossover-Strategy/

## Description

<h1>MTF SMA Crossover Strategy Documentation</h1>
<p><strong>Multi-Timeframe Trend-Following Framework for TradingView (Pine Script v5)</strong></p>

<hr />

<h2>1. Strategy Overview</h2>
<p>The <strong>Multi-Timeframe (MTF) SMA Crossover Strategy</strong> is designed for long-term investors seeking to eliminate market noise and maximize trend capture. The strategy relies on a strict dual-timeframe hierarchy:</p>

<ul>
    <li><strong>The Weekly Macro Filter (Bottom Chart):</strong> Establishes the primary structural trend. Trades are only permitted in the direction of the macro bull market.</li>
    <li><strong>The Daily Execution Trigger (Top Chart):</strong> Fine-tunes precise market entries using momentum crossovers.</li>
</ul>

<p>By combining these two distinct horizons, the strategy systematically filters out low-probability "fake-outs" common during broader multi-month market corrections.</p>

<pre>
[Weekly Chart Filter]  ---> Is Weekly Fast SMA > Weekly Slow SMA?
                                     |
                                     +---> YES ---> [Check Daily Chart] ---> Has Daily Crossover Occurred? ---> [BUY SIGNAL]

                                     |                                                    |
                                     +---> NO  ---> [STAY IN CASH]                        +---> NO ---> [WAIT]
</pre>

<hr />

<h2>2. Core Operational Logic</h2>

<h3>Entry Architecture (The Dual-Key Verification)</h3>
<p>An entry order is programmatically executed <strong>only</strong> when the following two rules align on the same candle close:</p>
<ul>
    <li><strong>Rule 1 (Weekly Filter):</strong> The Weekly Fast Moving Average must be trading structurally above the Weekly Slow Moving Average (Weekly Fast > Weekly Slow).</li>
    <li><strong>Rule 2 (Daily Trigger):</strong> The Daily Fast Moving Average must explicitly cross <em>above</em> the Daily Slow Moving Average.</li>
</ul>
<p><em>Note: If the daily chart experiences a bullish crossover while the weekly chart is still locked in a macro downtrend, the signal is discarded as a bull trap.</em></p>

<h3>Exit Architecture</h3>
<p>To preserve large cyclical gains while preventing premature shake-outs, the strategy maintains a single-timeframe exit:</p>
<ul>
    <li><strong>The Velocity Clause:</strong> The strategy liquidates the entire long position immediately when the Daily Fast Moving Average crosses <em>under</em> the Daily Slow Moving Average.</li>
</ul>

<hr />

<h2>3. Parameter Technical Specifications</h2>
<table border="1" cellpadding="5" style="border-collapse:collapse; width:100%;">
    <thead>
        <tr style="background-color:#2a2e39; color:white;">
            <th>Parameter Input</th>
            <th>Default Value</th>
            <th>Recommended Variations</th>
            <th>Purpose</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><strong>Fast SMA Length</strong></td>
            <td><code>50</code></td>
            <td>20 (Aggressive) / 50 (Standard)</td>
            <td>Controls the Daily Trigger line and maps directly to the 10-Week SMA on the macro layer.</td>
        </tr>
        <tr>
            <td><strong>Slow SMA Length</strong></td>
            <td><code>200</code></td>
            <td>100 (Aggressive) / 200 (Standard)</td>
            <td>Controls the Daily Baseline line and maps directly to the 40-Week SMA on the macro layer.</td>
        </tr>
        <tr>
            <td><strong>Initial Capital</strong></td>
            <td><code>$10,000</code></td>
            <td>User-defined</td>
            <td>Baseline cash simulation equity for the backtesting engine.</td>
        </tr>
        <tr>
            <td><strong>Order Sizing</strong></td>
            <td><code>100%</code></td>
            <td>1% to 100%</td>
            <td>Allocates the total percentage of current portfolio equity deployed into each qualified trade.</td>
        </tr>
    </tbody>
</table>

<hr />

<h2>4. TradingView Implementation Steps</h2>

<h3>Chart Layout Configuration</h3>
<p>To mimic a clean visual synchronization, set up your workspace environment as follows:</p>
<ol>
    <li>Click the <strong>Select Layout</strong> button on the top toolbar of TradingView and choose the <strong>2-Screen Split</strong> (Vertical or Horizontal).</li>
    <li>Set the <strong>Top Screen</strong> to the <strong>1D</strong> (Daily) interval.</li>
    <li>Set the <strong>Bottom Screen</strong> to the <strong>1W</strong> (Weekly) interval.</li>
    <li>Click the price scale gear icon on both charts and activate <strong>Logarithmic Scale</strong>. This scales exponential compounding visually over multi-year asset lifecycles.</li>
</ol>

<h3>Script Installation</h3>
<ol>
    <li>Open up the <strong>Pine Editor</strong> tab located at the bottom section of your TradingView interface.</li>
    <li>Delete any default template code present in the editor workspace.</li>
    <li>Paste the generated MTF strategy Pine Script code into the module.</li>
    <li>Click <strong>Save</strong>, rename the file, and then click <strong>Add to Chart</strong>.</li>
    <li>Ensure the script is explicitly running over the <strong>Daily (Top)</strong> panel. It will automatically fetch data from the background weekly structure using TradingView's native context security pipeline.</li>
</ol>

<hr />

<h2>5. Risk Considerations & Edge Blindspots</h2>
<ul>
    <li><strong>Whipsaw Windows:</strong> During extended multi-month horizontal consolidations or choppy trading ranges, the daily SMAs may cross frequently, resulting in small capital drawdowns.</li>
    <li><strong>Lag Penetration:</strong> Because moving averages are inherently lagging mathematical calculations, the execution trigger will sit slightly above the exact absolute market bottom, and exit triggers will drop slightly below the absolute cyclical top.</li>
    <li><strong>Asset Class Volatility:</strong> When applying this model to hyper-volatile assets (e.g., small-cap equities or crypto tokens), a temporary fast-moving crash can create short-term divergence before the weekly candles print a finalized macro print.</li>
</ul>

---

## Source Code

````pine
//@version=6
strategy("MTF SMA Crossover Strategy v6", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// 1. INPUTS
fast_len = input.int(50, title="Daily Fast SMA (or 10 Weekly)")
slow_len = input.int(200, title="Daily Slow SMA (or 40 Weekly)")

// 2. DAILY CHART INDICATORS (Top Chart)
daily_fast = ta.sma(close, fast_len)
daily_slow = ta.sma(close, slow_len)

// Daily Buy Signal (Crossover)
daily_buy_signal = ta.crossover(daily_fast, daily_slow)

// 3. WEEKLY CHART INDICATORS (Bottom Chart)
// Requesting background weekly data using barmerge.lookahead_off to ensure historical backtest accuracy
weekly_fast = request.security(syminfo.tickerid, "W", ta.sma(close, fast_len), barmerge.gaps_off, barmerge.lookahead_off)
weekly_slow = request.security(syminfo.tickerid, "W", ta.sma(close, slow_len), barmerge.gaps_off, barmerge.lookahead_off)

// Weekly Bullish Condition (Fast SMA is above Slow SMA)
weekly_trend_bullish = weekly_fast > weekly_slow

// 4. STRATEGY LOGIC
// Buy on daily crossover ONLY IF weekly trend is already bullish
buy_condition = daily_buy_signal and weekly_trend_bullish

// Exit when daily fast crosses under daily slow
exit_condition = ta.crossunder(daily_fast, daily_slow)

// 5. EXECUTION & PLOTTING
if buy_condition
    strategy.entry("MTF Long", strategy.long)

if exit_condition
    strategy.close("MTF Long")

// Visuals on Chart
plot(daily_fast, color=color.blue, title="Daily 50 SMA")
plot(daily_slow, color=color.orange, title="Daily 200 SMA")
plotshape(buy_condition, title="Confirmed Buy", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
````
