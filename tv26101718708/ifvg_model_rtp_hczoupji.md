# IFVG MODEL [RTP]

- url: https://www.tradingview.com/script/hcZouPJI-IFVG-MODEL-RTP/
- type: indicator
- pine_id: PUB;2257a3a4ce6843d78ba640cb98401421
- version: 6.0

## Description

[i][b]IFVG MODEL [RTP][/b][/i] is a clean intraday model built around higher-timeframe fair value gaps, lower-timeframe refinement, session liquidity, key levels, macros, swing liquidity, and SMT divergence.

[b]Core features:[/b]
- HTF Fair Value Gaps: 15m, 30m, 1h, and 4h selectable rows
- LTF Fair Value Gaps: 15s, 30s, and 1m-5m selectable rows
- Filled FVG deletion based on candle close through the gap
- Session highs/lows for Asia, London, NY AM, NY Lunch, and NY PM
- Unswept session levels extend live and swept levels are removed
- Key levels including Previous Day H/L, weekly/monthly levels, midnight open, and 08:30 open
- Macro windows with centered time labels
- Automatic swing liquidity dotted levels
- SMT divergence using a comparison symbol such as ES against NQ

[b]Default layout is intentionally simple:[/b]
15m, 1h, and 4h HTF FVGs are enabled, 5m LTF FVGs are enabled, Previous Day H/L is enabled, sessions are enabled, and SMT is limited to the most recent divergence.

This tool is designed to keep the chart readable while highlighting the liquidity and imbalance areas I use for intraday context.

[i]No indicator guarantees profits. This script is for education, analysis, and trade planning only. Always use risk management and test the model before trading live.[/i]

## Source Code

````pine
//@version=5
indicator("RTP Trading Access Notice", overlay=true)
plot(na, title="Access Notice", display=display.none)

// Public placeholder only.
// The private IFVG MODEL [RTP Trading] is available by invite-only access.
````
