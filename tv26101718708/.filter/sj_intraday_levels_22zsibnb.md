# SJ Intraday Levels

- url: https://www.tradingview.com/script/22zsIbnB-SJ-Intraday-Levels/
- type: indicator
- pine_id: PUB;0c84e994988e46ac87a18e01f8e7330d
- version: 1.0

## Description

[b]SJ Intraday Levels[/b]

This indicator is designed specifically for intraday traders who rely on predefined price levels for structured decision-making. It provides a clean and distraction-free way to plot important horizontal levels such as resistance, support, and intermediate zones, along with optional daily separators for better session awareness.

[b]🔹 Key Features[/b]

[b]1. Intraday-Focused Design[/b]

* The indicator is optimized to work on [b]intraday timeframes up to 5 minutes[/b].
* Helps traders maintain consistency in lower timeframes where precision matters most.

[b]2. Custom Horizontal Levels[/b]

* Users can manually define:

  * [b]Resistance Levels (R1, R2)[/b] – plotted in red
  * [b]Intermediate Levels (B1, B2)[/b] – plotted in black
  * [b]Support Levels (S1, S2)[/b] – plotted in green

* Each group of levels can be independently enabled or disabled.

[b]3. Smart Plotting Logic[/b]

* Levels are plotted [b]only when a valid value is entered[/b].
* If a level is left as default (`0.0`), [b]it will not be displayed[/b], keeping the chart clean and clutter-free.

[b]4. Daily Separator with Day Labels[/b]

* Displays a vertical dotted line at the start of each new trading day.
* Automatically labels the day as MON, TUE, WED, etc.
* Helps visually segment trading sessions and improves context for intraday strategies.

[b]5. Clean Visual Experience[/b]

* Minimalistic design to avoid unnecessary distractions.
* Fixed styling ensures consistent appearance across charts.

[b]🔹 How to Use[/b]

1. Apply the indicator on [b]1-minute to 5-minute charts[/b].
2. Enter your predefined levels based on your trading plan (e.g., previous day levels, supply/demand zones, VWAP deviations, OI data).
3. Enable or disable specific level groups as per your strategy.
4. Use the daily separator to identify session boundaries and align trades accordingly.

[b]🔹 Use Cases[/b]

* Intraday breakout trading
* Mean reversion strategies
* Scalping with predefined zones
* Support & resistance-based trading systems


[b]🔹 Notes[/b]

* This indicator [b]does not generate buy/sell signals[/b]. It is a visual aid to support your existing trading strategy.
* Works best when combined with proper risk management and a well-defined trading plan.


[b]🔹 Open Source[/b]

This script is published as [b]open-source[/b] for learning and customization purposes.
Feel free to modify and enhance it according to your trading needs.

If you find it useful, consider sharing feedback or improvements with the community.


[b]Disclaimer:[/b]
This tool is for educational purposes only and does not constitute financial advice. Trading involves risk, and users should perform their own analysis before making trading decisions.

## Source Code

````pine
//@version=6
indicator("SJ Intraday Levels", overlay = true)

showDailySep=input.bool(true,"Show Daily Separator")

if showDailySep and timeframe.change("D")
    line.new(bar_index,high,bar_index,low,extend=extend.both,color=color.rgb(120,123,134,45),width=1,style=line.style_dotted)
    dayText=dayofweek==dayofweek.monday?"MON":dayofweek==dayofweek.tuesday?"TUE":dayofweek==dayofweek.wednesday?"WED":dayofweek==dayofweek.thursday?"THU":dayofweek==dayofweek.friday?"FRI":dayofweek==dayofweek.saturday?"SAT":"SUN"
    label.new(bar_index,high,text=dayText,yloc=yloc.abovebar,textcolor=color.blue,style=label.style_none,size=size.small)

// Timeframe condition (only <= 5 min)
is_valid_tf = timeframe.isintraday and timeframe.multiplier <= 5

// User Inputs
show_R = input.bool(true, "Show Resistance Lines (Red)")
R1 = input.float(0.0, "R1")
R2 = input.float(0.0, "R2")

show_B = input.bool(false, "Show Intermediate Lines (Black)")
B1 = input.float(0.0, "B1")
B2 = input.float(0.0, "B2")

show_S = input.bool(true, "Show Support Lines (Green)")
S1 = input.float(0.0, "S1")
S2 = input.float(0.0, "S2")

// Plot Levels (only if timeframe valid AND value != 0)
plot(is_valid_tf and show_R and R1 != 0 ? R1 : na, title="R1", color=color.red, linewidth=1)
plot(is_valid_tf and show_R and R2 != 0 ? R2 : na, title="R2", color=color.red, linewidth=1)

plot(is_valid_tf and show_B and B1 != 0 ? B1 : na, title="B1", color=color.black, linewidth=1)
plot(is_valid_tf and show_B and B2 != 0 ? B2 : na, title="B2", color=color.black, linewidth=1)

plot(is_valid_tf and show_S and S1 != 0 ? S1 : na, title="S1", color=color.green, linewidth=1)
plot(is_valid_tf and show_S and S2 != 0 ? S2 : na, title="S2", color=color.green, linewidth=1)
````
