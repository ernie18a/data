# ATR with Volatility Markers

- url: https://www.tradingview.com/script/CLiJ9SDl-ATR-with-Volatility-Markers/
- type: indicator
- pine_id: PUB;5dfb3eac00e6462ba64a47cd7f78f953
- version: 3.0

## Description

[b]TradingView Indicator Manual: ATR with Volatility Markers[/b]

Author: hkpress@CANSLIM Research

[b]Overview[/b]

The ATR with Volatility Markers indicator is designed to measure the "heartbeat" of the market. Rather than predicting price direction, it measures the *energy* and *size* of price movements. By comparing the current short-term volatility (14-period ATR) against a long-term historical baseline (100-period ATR), this script automatically flags periods where the market is "coiling up" or actively "breaking out."

[b]The Theory: Volatility, Price, and Volume[/b]

To use this indicator effectively, you must understand how Average True Range (ATR) interacts with price patterns and trading volume. Markets naturally cycle between periods of high volatility (expansion) and low volatility (contraction).

[b]1. Volatility Contraction (The Setup)[/b]

Before a major move occurs, markets typically consolidate. Buyers and sellers reach a temporary equilibrium.

* Price: Moves sideways in a tight range (forming patterns like bull flags, flat bases, or pennants).
* Volume: Dries up significantly, often dropping below its 50-day average. This indicates that large institutions are quietly accumulating (or distributing) shares without aggressively pushing the price.
* ATR Change: The daily candles get smaller, causing the 14-period ATR to drop. When it falls below its historical normal baseline, your script flags this as a deep contraction. Think of this as a spring being compressed.

[b]2. Volatility Expansion (The Breakout)[/b]

A breakout occurs when new catalysts or aggressive institutional orders shatter the equilibrium.

* Price: Pierces firmly through a known support or resistance level with a large-range candle.
* Volume: Surges well above its average, confirming heavy participation and conviction.
* ATR Change: The size of the daily moves rapidly increases. The 14-period ATR hooks sharply upward. When it aggressively crosses above its historical baseline, your script flags this as a high-volatility event. The compressed spring has been released.

[b]How to Read the Indicator[/b]

The indicator uses four primary visual elements to communicate market conditions:

[i]1. Solid Red Line[/i]
Represents: Current ATR (14-period)
How to Interpret It: The current, real-time measurement of price movement size.

[i]2. Solid Gray Line[/i]
Represents: Normal Baseline (100-period)
How to Interpret It: The long-term average volatility. Used as a benchmark to define what is "normal" for this specific asset.

[i]3. Red Dots [/i]
Represents: Low Volatility Drop
How to Interpret It: Fires when current ATR drops below your defined threshold for contraction. Signals consolidation.

[i]4. Green Dots [/i]
Represents: High Volatility Spike
How to Interpret It: Fires when current ATR spikes above your defined threshold for expansion. Signals breakouts.

[b]Trading Application: Step-by-Step Observation[/b]

This indicator is most powerful when combined with your standard price and volume charts. Here is how to use them together:

[i]Step 1: Hunt for Red Dots (The Watchlist Phase)[/i]

* Scan your charts for assets printing Red Dots on the bottom of the indicator pane.
* Check the price chart: Is the asset forming a tight, constructive base or pattern?
* Check the volume: Is the volume noticeably lower than normal?
* *Action:* Put this asset on your immediate watchlist. Do not enter yet; the market is still deciding which way to break.

[i]Step 2: Wait for the Trigger (The Breakout Phase)[/i]

* Monitor the assets on your watchlist for a sudden price move that breaks the tight range (either up through resistance or down through support).
* Check the volume: You want to see a massive spike in volume on the breakout candle.
* Check the ATR indicator: The red ATR line should be hooking upward sharply.
* *Action:* This is your entry signal. The market has chosen a direction with conviction.

[i]Step 3: Look for the Green Dot (Confirmation Phase)[/i]

* Within a few candles of the breakout, a Green Dot should appear at the top of the indicator pane.
* *Action:* This confirms that the volatility expansion is severe enough to be a mathematically significant trend change. It validates that your breakout trade has genuine momentum behind it.

[b]Adapting to Different Asset Classes (The 5 Volatility Profiles)[/b]

The percentage change in ATR behaves very differently depending on a stock's inherent volatility (its "Beta" or personality). Because this script looks at *relative* change, you will see different magnitude shifts across different asset classes.

To get accurate signals, use the built-in dropdown menu to select the profile that matches the asset you are trading:

* Level 1: Extreme (Penny/Meme): Requires massive ATR shifts (2.0x for breakout, 0.4x for contraction). Perfect for filtering out the normal daily chaos of wild crypto altcoins or penny stocks.
* Level 2: High (Tech/Crypto): Requires 1.75x breakouts and 0.6x contractions. Ideal for fast movers like TSLA or NVDA.
* Level 3: Medium (S&P 500 Avg): The balanced default (1.35x and 0.85x) for everyday mid-to-large cap trading.
* Level 4: Low (Blue Chips/ETFs): Tightened thresholds (1.20x and 0.90x) to catch more subtle moves in established, stable companies like KO or AAPL.
* Level 5: Very Low (Utilities/Bonds): Extremely sensitive thresholds (1.10x and 0.95x) designed for assets that rarely make large percentage moves.

[b]How to Determine a Stock's Volatility Level[/b]

If you are unsure which of the 5 Levels to apply to a specific stock, use one of these three methods:

[b]Method 1: The Visual Calibration Test (Fastest)[/b]

Let the indicator tell you what settings to use right on your chart:

1. Load your stock and set the indicator to Level 3: Medium.
2. Zoom out and look at the last 1–2 years of price action.
* Too Many Dots ("The Christmas Tree"): If dots fire constantly during standard, choppy price action, the stock is too volatile for Level 3. Shift up to Level 2 or Level 1.
* Zero Dots ("The Desert"): If the stock has clearly made bases and breakouts but the indicator didn't fire *any* dots, the stock is too stable. Shift down to Level 4 or Level 5.
* Just Right: If the dots only trigger at the tightest squeezes and most violent breakouts, you have found the perfect level.

[b]Method 2: Check the "Beta" (The Industry Standard)[/b]

Beta measures how volatile a stock is compared to the S&P 500 (which has a Beta of 1.0). You can find Beta on Yahoo Finance, Finviz, or via a TradingView indicator. Match it here:

* Beta > 2.0 $\rightarrow$ Level 1 (Extreme) * Beta 1.3 to 2.0 $\rightarrow$ Level 2 (High) * Beta 0.9 to 1.3 $\rightarrow$ Level 3 (Medium) * Beta 0.5 to 0.9 $\rightarrow$ Level 4 (Low) * Beta < 0.5 $\rightarrow$ Level 5 (Very Low) Method 3: Calculate the "ATR Percentage" (The CANSLIM Way)
Measure how much a stock moves relative to its own price.
Formula: `(14-Day ATR / Current Stock Price) * 100`
* > 5% daily movement $\rightarrow$ Level 1 or 2
* 2% to 4% daily movement $\rightarrow$ Level 3
* < 2% daily movement $\rightarrow$ Level 4 or 5

[b]Indicator Settings Guide[/b]

You can fully customize the script's behavior via the TradingView inputs menu:

* ATR Length (Default: 14): Defines the speed of the red ATR line. A lower number (e.g., 7) makes it highly sensitive to recent days. A higher number (e.g., 20) smooths it out.
* Smoothing (Default: RMA): The mathematical formula used for the ATR. RMA is the industry standard created by J. Welles Wilder, but you can switch to SMA, EMA, or WMA.
* Normal ATR Baseline Length (Default: 100): The lookback period for the gray baseline. 100 periods provide a highly stable long-term average.
* Asset Volatility Profile: Use the dropdown to select Levels 1-5, or select "Custom Profile" to manually set your own Multipliers using the fields below it.

## Source Code

````pine
//@version=6
//  Author : hkpress@CANSLIM Research
//  License: Free
indicator(title="ATR with Volatility Markers v2", shorttitle="ATR Markers", overlay=false, timeframe="", timeframe_gaps=true)

// --- General Inputs ---
length = input.int(title="ATR Length", defval=14, minval=1)
smoothing = input.string(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"])
normLength = input.int(title="Normal ATR Baseline Length", defval=100, minval=1, tooltip="Used to calculate what 'normal' ATR is over time")

// --- Volatility Profile Inputs ---
assetProfile = input.string(title="Asset Volatility Profile", defval="Auto-Detect (Recommended)", 
  options=[
      "Auto-Detect (Recommended)",
      "Level 1: Extreme (Penny/Meme)", 
      "Level 2: High (Tech/Crypto)", 
      "Level 3: Medium (S&P 500 Avg)", 
      "Level 4: Low (Blue Chips/ETFs)", 
      "Level 5: Very Low (Utilities/Bonds)", 
      "Custom Profile"
  ], 
  tooltip="Auto-Detect measures the stock's daily percentage move to assign the perfect thresholds automatically.")

// Custom Multiplier Inputs (Only active if "Custom Profile" is selected above)
customHigh = input.float(title="Custom High Multiplier", defval=1.25, minval=0.1)
customLow  = input.float(title="Custom Low Multiplier", defval=0.9, minval=0.1)

// --- Functions ---
ma_function(source, len) =>
    switch smoothing
        "RMA" => ta.rma(source, len)
        "SMA" => ta.sma(source, len)
        "EMA" => ta.ema(source, len)
        => ta.wma(source, len)

// --- Calculations ---
// Calculate current ATR
atrValue = ma_function(ta.tr(true), length)

// Calculate the historical 'normal' ATR baseline
atrNormal = ta.sma(atrValue, normLength)

// --- AUTO-DETECT LOGIC ---
// Calculate the stock's average daily move as a percentage of its price
atrPct = ta.sma((atrValue / close) * 100, 100)

// Dynamically assign thresholds based on the stock's natural ATR %
autoHigh = atrPct >= 5.0 ? 2.00 : atrPct >= 3.5 ? 1.75 : atrPct >= 1.5 ? 1.35 : atrPct >= 0.75 ? 1.20 : 1.10
autoLow  = atrPct >= 5.0 ? 0.40 : atrPct >= 3.5 ? 0.60 : atrPct >= 1.5 ? 0.85 : atrPct >= 0.75 ? 0.90 : 0.95

// --- Assign Multipliers ---
// This applies either the Auto-Detect logic or the manual dropdown choice
[highMult, lowMult] = switch assetProfile
    "Auto-Detect (Recommended)"           => [autoHigh, autoLow]
    "Level 1: Extreme (Penny/Meme)"       => [2.00, 0.40]
    "Level 2: High (Tech/Crypto)"         => [1.75, 0.60]
    "Level 3: Medium (S&P 500 Avg)"       => [1.35, 0.85]
    "Level 4: Low (Blue Chips/ETFs)"      => [1.20, 0.90]
    "Level 5: Very Low (Utilities/Bonds)" => [1.10, 0.95]
    => [customHigh, customLow]

// Define signal conditions
isHighVol = atrValue > (atrNormal * highMult)
isLowVol  = atrValue < (atrNormal * lowMult)

// --- Plotting ---
// Plot the standard ATR line
plot(atrValue, title="ATR", color=color.new(#B71C1C, 0), linewidth=2)

// Plot the baseline for visual reference
plot(atrNormal, title="Normal ATR Baseline", color=color.new(color.gray, 50), style=plot.style_line)

// Plot Markers for High and Low Volatility 
plotchar(isHighVol, title="High Volatility Spike", char="•", location=location.top, color=color.new(color.green, 0), size=size.tiny)
plotchar(isLowVol, title="Low Volatility Drop", char="•", location=location.bottom, color=color.new(color.red, 0), size=size.tiny)

// Output the hidden ATR % metric to the Data Window so the user can verify the stock's volatility level
plot(atrPct, title="Stock's Average Daily Move %", display=display.data_window)
````
