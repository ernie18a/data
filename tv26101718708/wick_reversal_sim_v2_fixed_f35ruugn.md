#  Wick Reversal SIM  V2 Fixed 

- url: https://www.tradingview.com/script/F35ruuGn-Wick-Reversal-SIM-V2-Fixed/
- type: indicator
- pine_id: PUB;8d72474eedf44a4e9304e4082d22f9cc
- version: 1.0

## Description

Wick Reversal SIM is a price-action-based reversal + trade simulation tool designed to identify high-probability turning points using wick dominance and then instantly map out a complete trade plan (entry, stop loss, and multiple take profits).

It combines pure candlestick psychology with automated risk management visualization, making it both:

a signal generator
and a trade execution framework
 What It Is Made Of (Core Components)
1. Wick Strength Engine

At its core, the indicator measures:

Body size → |close - open|
Upper wick
Lower wick

Then compares wick size vs body using:

Wick ÷ Body ≥ Threshold (e.g., 2.0x)

 This identifies rejection candles:

Large lower wick → buyers stepped in → potential LONG
Large upper wick → sellers stepped in → potential SHORT
2. Confirmation Logic (No Blind Entries)

It does NOT enter on the wick candle itself.

Instead:

Waits for the next candle to confirm direction

LONG setup:

Previous candle = strong lower wick
Current candle = bullish close + breaks previous close

SHORT setup:

Previous candle = strong upper wick
Current candle = bearish close + breaks previous close

This reduces fake-outs and increases signal quality.

3. Trade Simulation Engine

Once a signal triggers, the indicator automatically plots:

 Entry price
 Stop loss (fixed %)
TP1 (partial take profit)
 TP2 (runner target)

It visually draws:

Horizontal levels (entry, SL, TP1, TP2)
Risk/Reward zones (red = risk, green = reward)
Optional projected move path (arrow)
4. Risk/Reward Visualization

You instantly see:

Position structure
Risk vs reward balance
Trade quality before entering

 This is huge for discipline + prop firm trading

5. Chart Signals & Visual Cues
 Stars = wick setups forming
 Arrows = confirmed entries
 Gold candles = high rejection candles
 How to Use It (Simple but Powerful)
Step-by-Step Workflow

1. Wait for a Wick Signal (Star)

Look for strong rejection (gold candle + star)

2. Wait for Confirmation

Don’t jump early — let the next candle confirm

3. Enter on Signal Arrow

LONG or SHORT appears

4. Follow the Trade Map

Entry already defined
Stop loss already calculated
TP1 + TP2 plotted

5. Manage Trade

Scale out at TP1
Let runner go to TP2
Optional: move SL to breakeven after TP1
 Best Timeframes
-
Optimal:
5M → scalping (fast, high frequency)
15M → best balance (recommended)
1H → stronger confirmations, fewer trades
 Less Effective:
1m → too noisy
Daily+ → signals too rare for this strategy
 What to Trade With It

This indicator performs best on liquid, high-volume markets:

 Top Choices:
Crypto (especially trending pairs)
BTCUSD
ETHUSD
LTCUSD  (great with this setup)
 Also Works Well:
Indices
NASDAQ (NQ)
S&P 500 (ES)
 Good Option:
Forex
EURUSD
GBPUSD
XAUUSD (Gold — very strong with wick logic)
 Why This Indicator Works

It’s based on real market behavior:

Wicks = failed moves / liquidity grabs
Large wick = trapped traders
Confirmation candle = true direction revealed

 You’re essentially trading:
“Stop hunts → reversal → continuation”

- Key Rules (Don’t Ignore These)
 -Don’t enter without confirmation
 -Avoid ranging/choppy markets
-Don’t fight strong trends blindly
-Best used after liquidity sweeps
-Combine with structure (support/resistance)
 -Trade during active sessions (NY / London)
-Pro Tip (This Changes Everything)

Use it with:

Market structure (higher highs / lower lows)
Key levels (previous highs/lows)
Session timing

 The A+ setup is:

Wick rejection + structure level + confirmation = high probability trade

 Bottom Line

Wick Reversal SIM is not just an indicator — it’s a full trade execution system.

It gives you:

Entry logic 
Risk management 
Trade visualization 
Confirmation filtering 

If  used  correctly, it eliminates:

Emotional entries
Poor risk management
Guesswork

## Source Code

````pine
//@version=6
indicator("⚡ Wick Reversal SIM v2 (Fixed)", overlay=true, max_lines_count=200, max_boxes_count=50)

// ═══════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════
wickRatio = input.float(2.0, "Wick / Body Ratio", minval=1.0)
stopPct   = input.float(15.0, "Stop Loss %")
tp1Pct    = input.float(30.0, "TP1 %")
tp2Pct    = input.float(55.0, "TP2 %")
extBars   = input.int(40, "Extend Bars", minval=5)

// ═══════════════════════════════════════
// WICK CALC
// ═══════════════════════════════════════
body   = math.abs(close - open)
upWick = high - math.max(open, close)
dnWick = math.min(open, close) - low

bigDn = body > 0 and dnWick / body >= wickRatio
bigUp = body > 0 and upWick / body >= wickRatio

// ═══════════════════════════════════════
// SIGNALS
// ═══════════════════════════════════════
longSig  = bigDn[1] and close > open and close > close[1]
shortSig = bigUp[1] and close < open and close < close[1]

// ═══════════════════════════════════════
// VISUALS
// ═══════════════════════════════════════
barcolor(bigDn or bigUp ? color.new(#f7c948, 0) : na)

plotshape(longSig,  title="LONG",  style=shape.triangleup,   location=location.belowbar, color=#4ade80, size=size.small)
plotshape(shortSig, title="SHORT", style=shape.triangledown, location=location.abovebar, color=#f87171, size=size.small)

// ═══════════════════════════════════════
// OBJECT STORAGE
// ═══════════════════════════════════════
var line entryLine = na
var line slLine    = na
var line tp1Line   = na
var line tp2Line   = na
var box  lossBox   = na
var box  winBox    = na

// ═══════════════════════════════════════
// CLEAN FUNCTION (FIXES LINE 36-TYPE ERRORS)
// ═══════════════════════════════════════
f_clear() =>
    if not na(entryLine)
        line.delete(entryLine)
    if not na(slLine)
        line.delete(slLine)
    if not na(tp1Line)
        line.delete(tp1Line)
    if not na(tp2Line)
        line.delete(tp2Line)
    if not na(lossBox)
        box.delete(lossBox)
    if not na(winBox)
        box.delete(winBox)

// ═══════════════════════════════════════
// LONG TRADE
// ═══════════════════════════════════════
if longSig
    f_clear()

    ep  = close
    sl  = ep * (1 - stopPct / 100)
    tp1 = ep * (1 + tp1Pct / 100)
    tp2 = ep * (1 + tp2Pct / 100)
    ext = bar_index + extBars

    entryLine := line.new(bar_index, ep, ext, ep, color=color.green, style=line.style_dashed)
    slLine    := line.new(bar_index, sl, ext, sl, color=color.red, style=line.style_dashed)
    tp1Line   := line.new(bar_index, tp1, ext, tp1, color=color.blue, style=line.style_dashed)
    tp2Line   := line.new(bar_index, tp2, ext, tp2, color=color.purple, style=line.style_dashed)

    lossBox := box.new(bar_index, ep, ext, sl, bgcolor=color.new(color.red, 85))
    winBox  := box.new(bar_index, tp2, ext, ep, bgcolor=color.new(color.green, 85))

// ═══════════════════════════════════════
// SHORT TRADE
// ═══════════════════════════════════════
if shortSig
    f_clear()

    ep  = close
    sl  = ep * (1 + stopPct / 100)
    tp1 = ep * (1 - tp1Pct / 100)
    tp2 = ep * (1 - tp2Pct / 100)
    ext = bar_index + extBars

    entryLine := line.new(bar_index, ep, ext, ep, color=color.green, style=line.style_dashed)
    slLine    := line.new(bar_index, sl, ext, sl, color=color.red, style=line.style_dashed)
    tp1Line   := line.new(bar_index, tp1, ext, tp1, color=color.blue, style=line.style_dashed)
    tp2Line   := line.new(bar_index, tp2, ext, tp2, color=color.purple, style=line.style_dashed)

    lossBox := box.new(bar_index, sl, ext, ep, bgcolor=color.new(color.red, 85))
    winBox  := box.new(bar_index, ep, ext, tp2, bgcolor=color.new(color.green, 85))
````
