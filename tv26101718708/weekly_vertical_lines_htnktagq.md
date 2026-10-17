# Weekly Vertical Lines

- url: https://www.tradingview.com/script/htNkTAgq-Weekly-Vertical-Lines/
- type: indicator
- pine_id: PUB;d6e8c1de6c504431ac5c4a1cca5b2a72
- version: 1.0

## Description

Here is the English version of the description, ready to use for your TradingView script publication or personal notes!

---

### **Weekly Vertical Lines (Weekly Separator)**

**Short Summary**
A clean and efficient tool that automatically draws vertical lines at the start of every new trading week. Perfect for structuring your charts and getting a quick overview of weekly price action.

**Description**
This indicator is designed for traders who want better visual control over market timeframes and cycles. Instead of manually finding and drawing lines for the Monday open, this indicator automatically identifies exactly when a new week begins and marks it directly on your chart.

The tool is especially powerful on **intraday charts** (such as 5-minute, 15-minute, or 1-hour timeframes), where it can otherwise be difficult to quickly spot where one week ends and the next begins.

**Key Features:**

* **Automatic Segmentation:** Instantly detects and marks the start of every new trading week in real time.
* **Fully Customizable:** Easily change the line color, transparency, and style (solid, dashed, or dotted) directly in the indicator settings to match your personal chart layout.
* **Minimalist Design:** Sits neatly in the background without cluttering your existing technical analysis or distracting from the price action.

**Why Use This Indicator?**

* **Clear Time Structure:** Gives you an instant visual grasp of how much the price has moved during the current week compared to previous ones.
* **Identify Weekend Gaps:** Perfect for analyzing how the market opens on Sunday night/Monday morning relative to Friday's close.
* **Strategic Planning:** Helps swing traders and day traders track weekly cycles, weekly highs/lows, and market momentum right from the opening bell.

## Source Code

````pine
//@version=5
indicator("Weekly Vertical Lines", overlay=true)

newWeek = ta.change(time("W"))

if newWeek
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color.new(color.gray, 60), width=1)
````
