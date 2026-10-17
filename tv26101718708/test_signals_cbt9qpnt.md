# Test Signals

- url: https://www.tradingview.com/script/cbT9qPnt/
- type: indicator
- pine_id: PUB;00b9446549d24ebea2f66d47233e4bda
- version: 1.0

## Description

A smart alert-testing indicator designed to help traders quickly verify and monitor trading signals in real time.
The indicator sends instant buy and sell alerts based on candle conditions, making it useful for testing alert systems, webhook connections, bots, and automated trading setups.

Features:

* Real-time buy and sell signal alerts
* Lightweight and fast performance
* Useful for TradingView alert testing
* Compatible with webhook automation systems
* Simple and clean chart behavior
* Ideal for signal verification and strategy monitoring

This indicator is perfect for traders who want a reliable way to test notifications, automation flows, and signal delivery accuracy before using advanced trading systems.

## Source Code

````pine
//@version=5
indicator("Test Signals", overlay=true)

// إشارات الشموع
isBull = close > open
isBear = close < open

// التنبيهات بدون رسالة ثابتة
alertcondition(isBull, title="Buy Alert")
alertcondition(isBear, title="Sell Alert")
````
