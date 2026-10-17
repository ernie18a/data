# End Of Moove

- url: https://www.tradingview.com/script/aY5GLO8a/
- type: indicator
- pine_id: PUB;86e22624871f483a953d62c4324a4567
- version: 1.0

## Description

INDICATOR: END OF MOOVE (EOM)

1. Overview
The [b]EndOfMoove (EOM)[/b] is a specialized volatility analysis tool designed to detect [b]market exhaustion[/b] and potential price reversals. By utilizing a modified Williams Vix Fix (WVF) logic, it identifies when fear or selling pressure has reached a [i]statistical extreme[/i] relative to recent history.

---

2. Core Logic & Calculation
The script functions by measuring the "synthetic" volatility created during sharp price drops and momentum shifts.

* [b]Williams Vix Fix (WVF) Logic:[/b] It calculates the distance between the current low and the highest close over a specific lookback period ([i]20 bars by default[/i]). This creates a volatility spike during market bottoms or rapid corrections.
* [b]Dynamic Normalization:[/b] The indicator continuously tracks the [b]Historical Maximum[/b] of this volatility over a long window ([i]250 bars[/i]).
* [b]Statistical Thresholding:[/b] It sets a "Danger Zone" at a specific percentage ([i]75%[/i]) of that historical maximum to filter out noise and isolate significant exhaustion events.

---

3. Adaptive Intelligence (Detection & Smoothing)
The [b]EOM[/b] adapts to different market conditions through its detection engine:

1. [b]Spike Confirmation:[/b] To avoid premature entries, the script uses a confirmation window ([i]3 bars[/i]). A signal is only "confirmed" if the current volatility spike is the highest within this local window.
2. [b]Variable Smoothing:[/b] Traders can apply an internal SMA smoothing to the raw volatility data to filter out erratic price action on lower timeframes.

---

4. Visual Anatomy
The interface uses a high-contrast design to highlight institutional exhaustion:

* [b]The Histogram:[/b]
   * [b]Faded Gray:[/b] Represents standard market volatility. The transparency is [i]dynamic[/i]; it darkens as volatility rises, signaling a buildup in pressure.
   * [b]Bright White:[/b] Activates when the volatility crosses the [b]Dynamic Threshold[/b], marking a high-probability exhaustion zone.
* [b]The Threshold Line:[/b] A continuous horizontal boundary that represents the [i]75% of historical max[/i], acting as the "Trigger Line."
* [b]Signal Triangles:[/b] A small white triangle appears at the top of the indicator when a [b]Volatility Spike[/b] is statistically confirmed.

---

5. How to Trade with EndOfMoove
* [b]Spotting Bottoms:[/b] Large white columns often coincide with "capitulation" phases. When the histogram reaches these levels, the current downward move is likely overextended.
* [b]Divergence Watch:[/b] If price makes a new low but the EOM histogram shows a lower spike than the previous one, it indicates that selling pressure is drying up.
* [b]Volatility Breakouts:[/b] A sudden transition from faded gray to bright white suggests an [i]impulse move[/i] that is reaching its peak velocity.

---

6. Technical Parameters
* [b]WVF Period:[/b] Controls the sensitivity of the raw volatility calculation.
* [b]Historical Max Period:[/b] Determines the depth of the statistical database (50 to 500 bars).
* [b]Threshold %:[/b] Allows the trader to tighten or loosen the "Extreme" zone (set to 75% for balanced results).

## Source Code

````pine
//@version=5
indicator("EndOfMoove", overlay=false, precision=2)

lookbackPeriodWVF = input.int(20, "WVF Period", minval=1, group="WVF Parameters")
wvfSmoothingPeriod = input.int(1, "WVF Smoothing", minval=1, group="WVF Parameters")

historicalPeriod = input.int(250, "Period for historical max", minval=50, maxval=500, group="Detection")
spikeConfirmationPeriod = input.int(3, "Spike confirmation period", minval=1, maxval=10, group="Detection")
thresholdPercentage = input.float(75, "% of max for threshold", minval=1, maxval=100, step=1, group="Detection")

baseColor = input.color(color.gray, "Base Color", group="Colors")
highlightColor = input.color(color.white, "Highlight Color", group="Colors")

highest_close_lookback = ta.highest(close, lookbackPeriodWVF)
wvf_raw = ((highest_close_lookback - low) / (highest_close_lookback + 0.000001)) * 100
wvf = wvfSmoothingPeriod > 1 ? ta.sma(wvf_raw, wvfSmoothingPeriod) : wvf_raw
//
max_wvf = ta.highest(wvf, historicalPeriod)
dynamicSpikeThreshold = max_wvf * (thresholdPercentage / 100)

isSpike = wvf >= dynamicSpikeThreshold
isConfirmedSpike = isSpike and ta.highest(wvf, spikeConfirmationPeriod) == wvf

float dynamicValue = math.min(wvf / 15, 1.0)
int dynamic_transparency = math.round((1 - dynamicValue) * 70)
dynamic_transparency := math.max(0, math.min(100, dynamic_transparency))

color bar_color = wvf >= dynamicSpikeThreshold ? highlightColor : color.new(baseColor, dynamic_transparency)

plot(wvf, title="Raw WVF (%)", style=plot.style_columns, color=bar_color, histbase=0)

hline(0, "Zero Line", color=color.new(baseColor, 50), linestyle=hline.style_dotted, linewidth=1)

plot(dynamicSpikeThreshold, title="Dynamic Threshold", color=color.new(highlightColor, 60), style=plot.style_line, linewidth=1)

plotshape(isConfirmedSpike, "Volatility Spike", shape.triangleup, location.top, highlightColor, 0, size=size.tiny)
````
