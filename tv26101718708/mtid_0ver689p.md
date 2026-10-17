# MTID

- url: https://www.tradingview.com/script/0VER689p-MTID/
- type: indicator
- pine_id: PUB;ceaa52c900e848c2ac803fd6fd4a3887
- version: 3.0

## Description

[b]Description[/b]
MTID is an all-in-one overlay built for swing and position traders who want price action, key statistics and fundamentals on a single pane. Six configurable moving averages, a "big move" marker, a live stats dashboard, and an 8-quarter fundamentals table are combined into one indicator with independent toggles for every section.

[b]WHAT'S ON THE CHART[/b]
• Six moving averages — each with its own length, type (SMA/EMA), color and timeframe-visibility filter (All / Intraday+Daily / Weekly+Monthly / Intraday-only / Daily-only / Weekly-only). Default lengths 10/20/50/100/150/200 cover the most-watched values.
• Purple-Dot Big Move — flags bars whose move ≥ a configurable % AND volume ≥ a configurable threshold. Shape, size, color and timeframe-visibility are all configurable; bars can be color-coded on move direction.
• Optional bar coloring for high relative-volume bars.

STATS DASHBOARD (vertical table or horizontal headband)
• Sector & Industry (auto-detected from the symbol)
• Market Cap with currency conversion (Auto / USD / INR / EUR / GBP / JPY) and Indian (Cr/LCr) or Western (M/B/T) formatting
• 52-Week High/Low — % off the high and % off the low (daily-candle based regardless of chart TF)
• 13-Week Peak/Bottom — same idea over a quarter
• ADR (Average Daily Range %) and ATR — daily-candle based
• U/D Ratio — up-volume vs down-volume
• Float %
• Distance vs Daily SMA and Distance vs Weekly SMA — both shown simultaneously, regardless of chart timeframe
• Relative Volume (RVol)
• % above Low-of-Day (intraday session low; bar low on daily+)

[b]FUNDAMENTALS TABLE[/b]
Last four quarters (with three more held internally for YoY math) of:
• EPS with YoY and QoQ % change
• Sales (auto-scaled units) with YoY and QoQ % change
• OPM% (Operating Margin = Operating Income / Revenue) with YoY and QoQ
• Per-quarter P/E (annualised from quarter EPS)
Plus an optional row showing the next two estimated quarters (EPS estimates, YoY/QoQ).
Header row showing Market Cap, Free-Float Mkt Cap, ROE and TTM P/E.
Vertical (full grid) or horizontal (transposed headband) layout.

[b]IPO-FRIENDLY[/b]
Lookback windows adapt to available history. A newly listed symbol with fewer than 52 weeks (or 13 weeks, 50 bars for RVol, 20 days for ADR, etc.) still gets values computed over whatever data exists, instead of showing "N/A".

[b]CUSTOMIZATION[/b]
• Every section independently togglable.
• Per-table position (6 anchor points), text size, layout (vertical / horizontal headband), border & frame width.
• Per-column text alignment (Left / Center / Right) for the dashboard.
• Configurable blank spacer rows at the top of each table — useful when TradingView's hover controls overlap the table.
• Fully themable colors (positive / negative / neutral, backgrounds, borders).

[b]NOTES[/b]
• Sector, Industry, Market Cap, ROE, Float, EPS, Sales, Operating Income and EPS estimates are sourced from TradingView's request.financial / request.earnings and may be unavailable for some symbols or exchanges.
• Currency conversion uses FX_IDC daily rates.
• Built in Pine Script v6.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © atticsalt

//@version=6
indicator("The script is not managed now")
plot(close)
````
