# 3/252 MA

- url: https://www.tradingview.com/script/2IguNN0i-3-252-MA/
- type: indicator
- pine_id: PUB;cdbc57a67c834f9d999a6a4601b64baf
- version: 1.0

## Description

gives Moving Averages 3, 5, 10, 20, 50, 100, 200 up to 252

You can switch on or off what you need at the moment.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ferdor

//@version=5
indicator(title="3/252 MA", shorttitle="MA", overlay=true, linktoseries=true)

plot(ta.sma(close, 3), title="3 SMA", color=#ffffff, linewidth=1)
plot(ta.sma(close, 5), title="5 SMA", color=#fc7600, linewidth=1)

plot(ta.sma(close, 10), title="10 SMA", color=#db0000, linewidth=1)
plot(ta.sma(close, 20), title="20 SMA", color=#fcf800, linewidth=1)
plot(ta.sma(close, 50), title="50 SMA", color=#00DB00, linewidth=1)
plot(ta.sma(close, 100), title="100 SMA", color=#0178f7, linewidth=1)
plot(ta.sma(close, 200), title="200 SMA", color=#e302f8, linewidth=1)
plot(ta.sma(close, 252), title="252 SMA", color=#02f8e0, linewidth=1)
````
