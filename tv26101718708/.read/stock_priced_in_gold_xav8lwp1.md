# Stock Priced in Gold

- url: https://www.tradingview.com/script/XAV8lWp1-Stock-Priced-in-Gold/
- type: indicator
- pine_id: PUB;a4250fdc9fe94d599215f974bca11ff9
- version: 1.0

## Description

# Stock Priced in Gold — How to Use

**The simple idea:** Instead of looking at how much your stock costs in dollars, this indicator shows how many ounces of gold one share can buy. If that number goes up, your stock is really gaining ground. If it goes down, your stock is losing — even when the dollar chart looks fine.

---

## Why this matters

Dollars get cheaper over time. The same $100 today buys less than it did 5 years ago. So when a stock's dollar price goes up, you can't always tell whether:

- The company is actually doing better, or
- The dollar is just getting weaker

By measuring your stock in gold instead, you cut through that confusion. Gold doesn't get printed and doesn't lose value the same way dollars do. So if your stock can buy more gold than before, it's truly worth more. If it can buy less, it's losing — no matter what the dollar chart says.

The math is simple:

```
Stock price ÷ Gold price = How many ounces of gold one share is worth
```

The indicator tracks this number over time and shows whether it's going up (stock winning) or down (stock losing).

---

## Setup

1. Open TradingView and click **Pine Editor** at the bottom of the screen
2. Copy the contents of `stock_priced_in_gold.txt` into the editor
3. Click **Save** (give it any name)
4. Click **Add to chart**
5. A new pane appears below your main price chart

**Important:** Your chart and the gold price must be in the same currency. The default settings work for U.S. dollar charts. If your chart is in another currency, switch to a USD-priced version of the same stock, or change the gold symbol to a matching currency version.

---

## What you see on the chart

The pane below your price chart has three things to look at:

**1. The orange line** — your stock's value measured in gold. This is the main reading. When it goes up, your stock is gaining against gold. When it goes down, it's losing.

**2. The trend line** (the smoothed version) — colored to show the overall direction:
- **Green** = trend is going up. Your stock is winning against gold over time.
- **Red** = trend is going down. Your stock is losing against gold over time.

**3. The colored fill between the two lines:**
- **Green fill** = the stock is currently above its trend (winning right now)
- **Red fill** = the stock is currently below its trend (losing right now)

---

## How to read the colors — the four combinations

| Trend line | Fill | What it means |
|---|---|---|
| 🟢 Green | 🟢 Green | **Strong winning.** Your stock is gaining vs gold both long-term and right now. The real deal. |
| 🟢 Green | 🔴 Red | **Pullback in an uptrend.** Long-term you're winning, but you're currently dipping. Often a buying opportunity. |
| 🔴 Red | 🟢 Green | **Counter-trend bounce.** Long-term losing, but currently bouncing back. Be cautious — could be temporary. |
| 🔴 Red | 🔴 Red | **Strong losing.** You're losing vs gold both long-term and right now. The dollar chart might still look okay, but real value is shrinking. |

This is the core skill: glance at the trend line color and the fill color. Two pieces of information, immediate read.

---

## The info table (top-right corner)

| Row | What it tells you |
|---|---|
| Stock | Current stock price in dollars |
| Gold | Current gold price |
| oz/share | How many ounces of gold one share can buy right now |
| vs start | How much your stock has gained or lost (in gold terms) since the chart's first bar |
| Trend | Plain-English direction: "winning" or "losing" vs gold |

The **vs start** row is the most important number. If it shows -20%, your stock has lost 20% of its real value since the chart began — even if the dollar price is up over the same period.

---

## Three display modes

You can switch between three views in the settings:

**Mode 1: Ratio (oz/share)**
Shows the actual number — like "0.05 oz per share". Numbers are tiny but precise. Useful when you want the literal figure for valuation work.

**Mode 2: % Change from Start** *(default — easiest to read)*
Shows the percentage gain or loss in gold terms since the chart began. A reading of "+15%" means you've gained 15% in real terms. A reading of "-25%" means you've lost 25%, no matter what the dollar chart says.

**Mode 3: Normalized to 100**
Rebases everything to start at 100. A value of 130 means +30%, a value of 70 means -30%. Useful for screenshots or comparing two charts side by side.

---

## Real-world examples

**Example 1 — A stock that looked great but really wasn't**

Imagine a stock that's up 40% over 3 years. Your dollar chart looks like a clear winner. But during those 3 years, gold went up 50%. The gold-priced ratio shows your stock is actually **down 6.7% in real terms**. The trend line is red. The 40% gain was mostly the dollar getting weaker — not the company getting stronger.

**Example 2 — A genuine winner**

Another stock is up 80% over the same 3 years while gold went up 50%. The gold-priced ratio shows you're **up 20% in real terms**. The trend line is green. This company actually created real value.

**Example 3 — A "losing" stock during a strong-dollar period**

A stock is down 10% over a year. Looks bad. But during that year, gold dropped 20%. The gold-priced ratio shows you're actually **up 12.5% in real terms**. The trend line might be green even though the dollar chart looks red.

---

## Common mistakes to avoid

**Currency mismatch.** If your chart is in Japanese yen but you're using a U.S. dollar gold price, the math is meaningless. The chart currency and the gold symbol's currency must match.

**Reading too much into short timeframes.** This indicator works best on daily, weekly, or monthly charts. Don't trust readings on 5-minute or 15-minute charts — they're too noisy.

**Forgetting about dividends.** The indicator compares prices only. Stocks that pay big dividends (utilities, REITs, banks) may be doing better in real terms than the line suggests, because the dividend cash isn't counted.

**Zooming changes the baseline.** The "vs start" percentage uses the first visible bar as its anchor. Zoom out further and that number shifts. If you want to lock in a specific reference date (e.g., "since the pandemic"), turn on the **Custom baseline start date** option and set your date.

---

## The mental shift

Most people think the dollar chart tells them how their stock is doing. It does — but only against the dollar. By measuring against gold, you're asking a different question: "Is my stock really getting more valuable, or just keeping up with the dollar's slide?"

Once you start watching both charts, you notice things you'd otherwise miss:

- A stock making new dollar highs but flat in gold terms → the rally is dollar weakness, not company strength
- A stock that's flat in dollars but rising in gold terms → a hidden winner
- A stock falling in both → real trouble

Use the dollar chart to track price. Use this one to track value.

---

## Quick reference

- **Orange line going up** = winning vs gold
- **Orange line going down** = losing vs gold
- **Green trend line** = long-term direction is winning
- **Red trend line** = long-term direction is losing
- **Green fill** = winning right now
- **Red fill** = losing right now

## Files

- `stock_priced_in_gold.txt` — the Pine Script source. Paste it into TradingView's Pine Editor.
- `stock_priced_in_gold_README.md` — this guide.

## Source Code

````pine
//@version=6
indicator("Stock Priced in Gold", shorttitle="$/Au", overlay=false, precision=6)

// ============================================================
// Stock Priced in Gold
// ------------------------------------------------------------
// Measures your stock in ounces of gold instead of dollars.
// If the line goes up, your stock is gaining real ground.
// If it goes down, your stock is losing — even when the
// dollar price chart looks fine.
//
// Colors tell you the direction at a glance:
//   Green = stock winning against gold
//   Red   = stock losing against gold
// ============================================================

// ============== INPUTS ==============
gGold = "Gold reference"
goldSym = input.symbol("TVC:GOLD", "Gold symbol", group=gGold,
     tooltip="TVC:GOLD = LBMA spot. Alternatives: OANDA:XAUUSD, COMEX:GC1!. Must match chart currency.")

gMode = "Display"
mode = input.string("% Change from Start", "Mode", group=gMode,
     options=["Ratio (oz/share)", "% Change from Start", "Normalized to 100"])

gBase = "Baseline"
useCustomStart = input.bool(false, "Custom baseline start date", group=gBase)
startDate      = input.time(timestamp("2020-01-01"), "Start date", group=gBase)

gTrend = "Trend signal"
showMA   = input.bool(true, "Show trend line",                     group=gTrend, inline="ma")
maLen    = input.int(50,    "len",                                  group=gTrend, inline="ma", minval=1)
showFill = input.bool(true, "Color fill (green=winning, red=losing)", group=gTrend,
     tooltip="Green fill = stock currently above its trend. Red fill = currently below.")

gAdd = "Other"
showTbl = input.bool(true, "Info table", group=gAdd)

// ============== DATA ==============
goldPrice  = request.security(goldSym, timeframe.period, close, ignore_invalid_symbol=true)
stockPrice = close
ratio      = stockPrice / goldPrice

// ============== BASELINE ==============
var float baseline = na
canSet = useCustomStart ? (time >= startDate and not na(ratio)) : (not na(ratio))
if na(baseline) and canSet
    baseline := ratio

// ============== DISPLAY VALUE ==============
display = switch mode
    "Ratio (oz/share)"     => ratio
    "% Change from Start"  => (ratio / baseline - 1) * 100
    "Normalized to 100"    => ratio / baseline * 100
    => ratio

// ============== MA AND TREND DIRECTION ==============
maVal   = ta.sma(display, maLen)
trendUp = maVal > maVal[1]   // is the trend line sloping up?
aboveMA = display > maVal     // is price above the trend right now?

// Colors
maColor   = trendUp ? color.new(color.green, 0)  : color.new(color.red, 0)
fillColor = aboveMA ? color.new(color.green, 80) : color.new(color.red, 80)

// ============== PLOTS ==============
mainPlot = plot(display, "Price in gold", color=color.new(color.orange, 0), linewidth=2)
maPlot   = plot(showMA ? maVal : na, "Trend", color=maColor, linewidth=2)
fill(mainPlot, maPlot, color=showFill ? fillColor : na, title="Win/Lose vs gold")

// Zero line for % mode
plot(mode == "% Change from Start" ? 0 : na, "Zero", color=color.new(color.gray, 50), style=plot.style_line)

// ============== INFO TABLE ==============
var table info = table.new(position.top_right, 2, 5,
     bgcolor=color.new(color.black, 75), border_width=1, border_color=color.new(color.gray, 80))

if showTbl and barstate.islast and not na(baseline)
    pctVsStart = (ratio / baseline - 1) * 100
    signStart  = pctVsStart >= 0 ? "+" : ""
    trendText  = trendUp ? "↑ winning vs gold" : "↓ losing vs gold"
    trendColor = trendUp ? color.lime : color.red

    table.cell(info, 0, 0, "Stock",     text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 0, str.tostring(stockPrice, "#.##"), text_color=color.white)
    table.cell(info, 0, 1, "Gold",      text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 1, str.tostring(goldPrice, "#.##"),  text_color=color.white)
    table.cell(info, 0, 2, "oz/share",  text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 2, str.tostring(ratio, "#.######"),  text_color=color.orange)
    table.cell(info, 0, 3, "vs start",  text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 3, signStart + str.tostring(pctVsStart, "#.##") + "%",
         text_color=pctVsStart >= 0 ? color.lime : color.red)
    table.cell(info, 0, 4, "Trend",     text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 4, trendText, text_color=trendColor)
````
