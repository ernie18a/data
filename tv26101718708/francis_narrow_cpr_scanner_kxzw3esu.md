# Francis Narrow CPR Scanner

- url: https://www.tradingview.com/script/KXzw3eSU-Francis-Narrow-CPR-Scanner/
- type: indicator
- pine_id: PUB;95de9a22ed9a48b3ba07d428ead1332a
- version: 1.0

## Description

This indicator is designed to identify stocks whose next trading day's Central Pivot Range (CPR) is expected to be narrow based on the current day's High, Low, and Close prices.

The underlying assumption is that:

A narrow CPR indicates price compression and balance in the market.

Markets that are compressed often transition into expansion.

Therefore, narrow CPR days frequently precede strong directional moves, trend days, breakouts, and increased volatility.

The indicator automatically calculates tomorrow's CPR from today's price data and marks candles where the CPR width falls below a user-defined threshold.

What is CPR?

Central Pivot Range (CPR) consists of three levels:

Pivot Point (P)

P=
3
H+L+C
	​


Where:

H = High
L = Low
C = Close
Bottom Central Pivot (BC)

BC=
2
H+L
	​


Top Central Pivot (TC)

TC=2P−BC

The CPR is the zone between:

TC (Top Central Pivot)
BC (Bottom Central Pivot)
How Tomorrow's CPR is Calculated

Unlike support and resistance indicators that use current day's data, this indicator calculates the CPR for the next trading session.

Example:

Today's data:

High = 100
Low = 95
Close = 98

The indicator uses these values to calculate:

Tomorrow's Pivot
Tomorrow's BC
Tomorrow's TC

Thus, at today's close you already know whether tomorrow's CPR will be narrow.

This provides a trading edge because you can prepare before the next session opens.

CPR Width Calculation

The indicator first computes:

CPR Width = TC - BC

Then converts it into a percentage of the closing price:

CPR Width %=
Close
TC−BC
	​

×100

Using percentage instead of absolute values allows comparison between:

₹100 stock
₹500 stock
₹5000 stock

on the same scale.

Narrow CPR Detection

The indicator compares CPR Width % with the threshold chosen by the user.

Example:

If threshold = 0.25%

Then:

CPR Width % ≤ 0.25

Stock is marked as Narrow CPR.

Otherwise:

CPR Width % > 0.25

No signal is generated.

Visual Output

Whenever a Narrow CPR is detected:

A label appears below the candle.

Example:

      |
      |
      |
   ┌─────┐
   │     │
   └─────┘
      ▼
    NCPR

NCPR stands for:

Narrow Central Pivot Range

This label indicates:

"Tomorrow's CPR is narrow."

User Adjustable Inputs
1. Maximum CPR Width (%)

Default:

0.25%

This controls how strict the scan is.

0.10%

Extremely selective.

Only the tightest CPR stocks.

Very few signals.

0.20%

Professional level filter.

Many intraday traders prefer this.

Strong breakout potential.

0.25%

Balanced setting.

Good mix of opportunities and signal frequency.

0.30%

Moderately narrow.

More stocks appear.

0.50%

Loose filter.

Many stocks qualify.

Breakout quality decreases.

2. Label Color

Allows customization of the label color.

Examples:

Green
Blue
Yellow
Red
3. Label Text

Default:

NCPR

Can be changed to:

Narrow CPR

or

Tomorrow CPR

or any custom text.

Trading Logic Behind Narrow CPR

A narrow CPR indicates:

Buyers and sellers are balanced.

Neither side has gained clear control.

Price finished the session near equilibrium.

Because of this equilibrium:

The next day often experiences:

Volatility expansion
Trend development
Breakout moves
Range expansion
Why Narrow CPR Works

Markets alternate between:

Contraction

Low volatility.

Small CPR.

Compressed ranges.

Low directional conviction.

Expansion

High volatility.

Large ranges.

Directional movement.

Trend days.

Narrow CPR identifies the contraction phase.

Traders then look for expansion on the following day.

How Professional Traders Use Narrow CPR
Step 1

Run the scanner after market close.

Step 2

Generate list of stocks with Narrow CPR.

Step 3

Mark:

Previous day High
Previous day Low
Step 4

Wait for breakout.

Bullish:

Price > Previous High

Bearish:

Price < Previous Low
Step 5

Confirm with:

Volume
VWAP
Market Profile
Volume Delta
Footprint
Combining With Volume Delta

You frequently use:

Volume Delta
Footprint
Tape Reading

This indicator works very well with them.

Bullish Setup

Narrow CPR stock.

Price breaks previous high.

Delta becomes positive.

Footprint shows stacked bid absorption.

Buyers gain control.

Bearish Setup

Narrow CPR stock.

Price breaks previous low.

Delta becomes negative.

Footprint shows offer absorption.

Sellers gain control.

Best Timeframe
Daily Chart

Recommended.

The indicator was designed for daily CPR calculations.

Most reliable.

Weekly Chart

Possible.

Identifies stocks with narrow CPR for the next week.

Useful for swing trading.

Intraday Charts

Not recommended for this version.

CPR concept is strongest when calculated from daily data.

Ideal Use Case

For your style of trading in NSE stock futures:

Run scanner after market close.
Collect Narrow CPR stocks.
Check relative volume.
Check overnight news.
Monitor opening range.
Use Volume Delta and Footprint for confirmation.
Trade the breakout from the compression zone.

## Source Code

````pine
//@version=6
indicator("Tomorrow Narrow CPR Scanner", overlay=true)

// ===== INPUTS =====
cprPercent = input.float(0.25, "Maximum CPR Width (%)", minval=0.01, step=0.01)

labelColor = input.color(color.lime, "Label Color")
labelText = input.string("NCPR", "Label Text")

// ===== CPR CALCULATION =====
pivot = (high + low + close) / 3.0
bc = (high + low) / 2.0
tc = (2.0 * pivot) - bc

topCPR = math.max(tc, bc)
bottomCPR = math.min(tc, bc)

cprWidth = topCPR - bottomCPR
cprWidthPct = (cprWidth / close) * 100.0

// ===== NARROW CPR CONDITION =====
isNarrowCPR = cprWidthPct <= cprPercent

// ===== LABEL =====
if isNarrowCPR
    label.new(
         bar_index,
         low,
         labelText,
         style=label.style_label_up,
         color=labelColor,
         textcolor=color.white,
         size=size.small)

// ===== OPTIONAL CPR WIDTH PLOT =====
plot(cprWidthPct, title="CPR Width %", color=color.blue, linewidth=2)

// ===== ALERT =====
alertcondition(
     isNarrowCPR,
     title="Tomorrow Narrow CPR Alert",
     message="Tomorrow Narrow CPR detected")
````
