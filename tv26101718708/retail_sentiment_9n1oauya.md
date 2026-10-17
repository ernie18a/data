# Retail Sentiment

- url: https://www.tradingview.com/script/9N1OaUYa-Retail-Sentiment/
- type: indicator
- pine_id: PUB;a8ab19490f7c4349b9205d3c4af85713
- version: 1.0

## Description

Retail Sentiment - Manual Dashboard

Overview

The Retail Sentiment - Manual dashboard is a visual analysis tool designed to help traders track the "Crowd Sentiment" directly on their charts. Inspired by data providers like MyFxBook, this tool allows you to visualize the Long vs. Short ratio of retail traders, providing a clear picture of market positioning.

The Contrarian Edge
In the world of Forex and Indices, the "retail crowd" is often caught on the wrong side of major moves. Market liquidity tends to flow toward where the majority of retail stop-losses are clustered. By monitoring retail sentiment, you can:

Identify Overcrowded Trades: Avoid buying when the crowd is already 80-90% Long.

Spot Liquidity Traps: Align yourself with "Smart Money" by looking for opportunities opposite to retail mass-positioning.

Enhance Confirmation: Use sentiment as a final filter for your existing technical strategy.

Why Manual Entry?
While automated sentiment feeds are convenient, they are often delayed or locked behind expensive subscriptions. This manual version gives you full control:

Aggregated Data: You can pull data from any source you trust (MyFxBook, IG Client Sentiment, Oanda, etc.).

Market Awareness: The act of manually updating the data forces you to stay "in tune" with the market environment before placing a trade.

Clean Visualization: No need for multiple browser tabs. View the sentiment ratio as a clean, professional graphic right next to your price action.

How to Use
Check: Look up the current sentiment percentage for your pair (e.g., EURUSD is 70% Short).

Input: Enter the value into the indicator's settings.

Analyze: The dashboard will display the ratio. If sentiment is heavily skewed one way, look for price action setups in the opposite direction.

A Gift to the Community
I am making this tool Public to help fellow traders develop a more sophisticated view of market mechanics. Trading isn't just about patterns; it's about understanding where the liquidity lies. Manual data entry is a proven way to build discipline and keep your "eyes on the ball."

Trade safe!

Pro-Tips for your Post:
Keywords: Use tags like #Sentiment, #Contrarian, #Psychology, and #Liquidity.

Visuals: Upload a screenshot showing the dashboard on a chart where the market moved against the retail crowd—this is the best "social proof" for your tool!

## Source Code

````pine
//@version=5
indicator("Retail Sentiment", overlay=true)

posStr  = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")
selPair = input.string("EURUSD", "Pair", options=["DXY", "EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDCAD", "USDCHF", "USDJPY", "XAUUSD", "EURJPY", "GBPJPY"], group="Display")

long_dxy  = input.int(28, "DXY    L%", group="Sentiment %", minval=1, maxval=99)
long_eur  = input.int(62, "EURUSD L%", group="Sentiment %", minval=1, maxval=99)
long_gbp  = input.int(58, "GBPUSD L%", group="Sentiment %", minval=1, maxval=99)
long_aud  = input.int(55, "AUDUSD L%", group="Sentiment %", minval=1, maxval=99)
long_nzd  = input.int(53, "NZDUSD L%", group="Sentiment %", minval=1, maxval=99)
long_cad  = input.int(45, "USDCAD L%", group="Sentiment %", minval=1, maxval=99)
long_chf  = input.int(38, "USDCHF L%", group="Sentiment %", minval=1, maxval=99)
long_jpy  = input.int(66, "USDJPY L%", group="Sentiment %", minval=1, maxval=99)
long_xau  = input.int(71, "XAUUSD L%", group="Sentiment %", minval=1, maxval=99)
long_eurj = input.int(60, "EURJPY L%", group="Sentiment %", minval=1, maxval=99)
long_gbpj = input.int(57, "GBPJPY L%", group="Sentiment %", minval=1, maxval=99)

lp = selPair == "DXY" ? long_dxy : selPair == "EURUSD" ? long_eur : selPair == "GBPUSD" ? long_gbp : selPair == "AUDUSD" ? long_aud : selPair == "NZDUSD" ? long_nzd : selPair == "USDCAD" ? long_cad : selPair == "USDCHF" ? long_chf : selPair == "USDJPY" ? long_jpy : selPair == "XAUUSD" ? long_xau : selPair == "EURJPY" ? long_eurj : long_gbpj
sp = 100 - lp

C_LONG  = color.new(#0f5c3a, 0)
C_SHORT = color.new(#e24b4a, 0)
C_BG    = color.new(#131722, 80)

tblPos = posStr == "Top Right" ? position.top_right : posStr == "Top Left" ? position.top_left : posStr == "Bottom Right" ? position.bottom_right : position.bottom_left

var table t = table.new(tblPos, 8, 1, border_width=0, frame_width=0)

if barstate.islast
    table.cell(t, 0, 0, str.tostring(lp) + "%", text_color=color.new(#1a8c55,0), bgcolor=C_BG, text_size=size.tiny, text_halign=text.align_right)
    for i = 1 to 6
        table.cell(t, i, 0, "", bgcolor=i * 16 <= lp ? C_LONG : C_SHORT, width=2, height=10)
    table.cell(t, 7, 0, str.tostring(sp) + "%", text_color=color.new(#e24b4a,0), bgcolor=C_BG, text_size=size.tiny, text_halign=text.align_left)
````
