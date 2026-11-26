# Market Breadth: NH/NL

- url: https://www.tradingview.com/script/an5WgWNS-Market-Breadth-NH-NL/
- type: indicator
- pine_id: PUB;5f2ea557391e4cb784685f01207541d0
- version: 1.0

## Description

Market Breadth: NH/NL Indicator

This indicator tracks the daily number of stocks making New Highs (NH) and New Lows (NL) across the NYSE and NASDAQ exchanges to evaluate underlying market breadth.

Key Features:

Data Source: Utilizes native TradingView breadth tickers (USI:NYH, USI:NYL, USI:NDH, USI:NDL).

Visual Layout: New Highs are plotted above the zero line. New Lows are inverted and plotted below the zero line for immediate visual assessment of market bias.

Formatting: NYSE breadth is displayed as a histogram. NASDAQ breadth is overlaid as continuous lines.

Application: Used to gauge internal market participation, measure trend strength, and identify structural divergences between price action and breadth.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alxest

//@version=6
indicator('Market Breadth: NH/NL', shorttitle = 'NH/NL Breadth', overlay = false)

// Входные параметры (встроенные тикеры TradingView)
nyh_sym = input.symbol('HIGN', title = 'NYSE New Highs')
nyl_sym = input.symbol('LOWN', title = 'NYSE New Lows')
ndh_sym = input.symbol('HIGQ', title = 'NASDAQ New Highs')
ndl_sym = input.symbol('LOWQ', title = 'NASDAQ New Lows')

// Запрос дневных значений
nyh = request.security(nyh_sym, 'D', close)
nyl = request.security(nyl_sym, 'D', close)
ndh = request.security(ndh_sym, 'D', close)
ndl = request.security(ndl_sym, 'D', close)

// Отрисовка NYSE (Гистограмма)
plot(nyh, title = 'NYSE NH', style = plot.style_columns, color = color.new(color.teal, 60))
plot(-nyl, title = 'NYSE NL', style = plot.style_columns, color = color.new(color.red, 60))

// Отрисовка NASDAQ (Линии)
plot(ndh, title = 'NASDAQ NH', style = plot.style_line, linewidth = 2, color = color.lime)
plot(-ndl, title = 'NASDAQ NL', style = plot.style_line, linewidth = 2, color = color.maroon)

// Нулевая линия
hline(0, title = 'Zero Line', color = color.gray, linestyle = hline.style_dashed)
````
