# Volume To Bar Range Ratio

- url: https://www.tradingview.com/script/WJLiYgIn-Volume-To-Bar-Range-Ratio/
- type: indicator
- pine_id: PUB;74280927fd464fb88cdca78ad2a6e6aa
- version: 1.0

## Description

This script plots
[pine]volume / (high - low)[/pine]
for each bar. A simple measure of how much volume was traded per unit of price range.

[b]Usage[/b]
In normal trading bars, volume tends to be correlated to the size of the bar. Small bars have small volume, large bars have large volume. However, key bars tend to have an unusually high ratio of range to volume. This is useful for identifying areas of support and resistance, when they are broken, and key runaway days when price goes parabolic.

[b]Support and Resistance[/b]
[list]
[*]When price is near an area of support or resistance, or approaching a recent high/low, a small bar with unusually high volume tends to be an indicator that the support/resistance is holding.
[*]When price breaks through an area of support or resistance, or makes a new high or low, and the bar that does is large with an unusually high ratio of volume to range, this is an indicator that support/resistance has been decisively broken. Conversely, if the bar is large, but the ratio of price to volume is similar to other large bars, it is a warning that this might not be a decisive break.
[/list]
[b]Key Runaway Days[/b]
When price has become parabolic and has made several consecutive large moves up, a large bar with a volume to bar range ratio that is extremely high, higher than any other bar made previously, this is an indicator that a runaway day is occurring. Price is unlikely to continue moving parabolically after this day, and it would be a good time to take profits.

[b]Notes[/b]
[list]
[*]Bars where `high == low` produce `na` (a gap in the plot) to avoid division by zero.
[*]Works on any symbol and timeframe that reports volume.
[/list]
[b]Note on Originality[/b]
This is the first, only, and original implementation of Volume to Bar Range Ratio available in PineScript. This can be easily verified with a search for "Volume to Bar Range Ratio", "Volume Bar Range Ratio", "VBRR",  and"VTBRR" on TradingView. Also, a Google search for the same terms, adding "pinescript" or "tradingview" shows that my implementation is the only implementation, and the only other result is a complaint on reddit that this does not exist.

## Source Code

````pine
//@version=6
indicator("Volume To Bar Range Ratio", shorttitle="VBRR", overlay=false)

barRange = high - low
ratio = barRange > 0 ? volume / barRange : na

plot(ratio, title="Vol/Range", color=color.yellow, linewidth=1, style=plot.style_circles)
````
