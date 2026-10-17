# kill zones

- url: https://www.tradingview.com/script/bpdKhE30/
- type: indicator
- pine_id: PUB;bd85241750e948ad83832cebfbb10005
- version: 1.0

## Description

[b]Kill Zones: (Warsaw) – London + US Sessions[/b]

This indicator defines key time-based market activity zones (Kill Zones) for the London and New York sessions, converted to Warsaw time (CET/CEST).

It is designed to analyze periods of highest volatility and liquidity, which often occur during the opening and first minutes of major trading sessions.

[b]What the indicator shows[/b]

The indicator automatically highlights four main zones:

[list]
[*]London Extended (07:00–10:00 Warsaw)

A broader period of European market activity before and during the London open.
[/list]

[list]
[*]London Narrow (08:30–09:00 Warsaw)

A tight window of highest volatility during the London market open.
[/list]

[list]
[*]US Extended (15:00–16:30 Warsaw)

The first phase of the US session, characterized by increasing volume and volatility.
[/list]

[list]
[*]US Narrow (15:30–16:00 Warsaw)

The most active and volatile period of the US market open.
[/list]

[b]Usage[/b]

This indicator helps with:

[list]
[]identifying periods of high liquidity
[]finding potential price impulses
[]intraday trading setups (scalping / day trading)
[]combining with ICT / Smart Money Concepts methodology
[*]avoiding trading outside “active market hours”
[/list]

[b]Features[/b]

[list]
[]Automatic session highlighting
[]Separate colors for each zone
[]Warsaw + New York time support
[]Fully customizable hours and ranges
[*]Alerts for each active zone
[/list]




[b]Kill Zones: (Warszawa) – London + US Sessions[/b]

Ten wskaźnik wyznacza kluczowe strefy czasowe aktywności rynkowej (Kill Zones) dla sesji London i New York, przeliczone na czas Warszawy (CET/CEST) 

Został zaprojektowany do analizy momentów największej zmienności i płynności, które często występują podczas otwarcia i pierwszych minut głównych sesji giełdowych.

[b]Co pokazuje wskaźnik[/b]

Wskaźnik automatycznie zaznacza cztery główne strefy:

[list]
[*]
[/list]London Extended (07:00–10:00 Warszawa)

Szerszy okres aktywności rynku europejskiego przed i w trakcie otwarcia Londynu.

[list]
[*]
[/list]London Narrow (08:30–09:00 Warszawa)

Wąskie okno największej zmienności podczas otwarcia Londynu.

[list]
[*]
[/list]US Extended (15:00–16:30 Warszawa)

Pierwsza faza sesji amerykańskiej, obejmująca wzrost wolumenu i zmienności.

[list]
[*]
[/list]US Narrow (15:30–16:00 Warszawa)

Najbardziej dynamiczny moment otwarcia rynku USA.

[b]Zastosowanie[/b]

Wskaźnik pomaga w:

[list]
[*]identyfikacji momentów wysokiej płynności
[*]znajdowaniu potencjalnych impulsów cenowych
[*]analizie setupów intraday (scalping / day trading)
[*]łączeniu z metodologią ICT / Smart Money Concepts
[*]unikaniu handlu poza “aktywnymi godzinami rynku”
[/list]

[b]Funkcje[/b]
[list]
[*]Automatyczne zaznaczanie sesji czasowych
[*]Osobne kolory dla każdej strefy
[*]Obsługa czasu Warszawa + New York
[*]W pełni konfigurowalne godziny i zakresy
[*]Alerty dla każdej strefy aktywności
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © marta_anna_urbanska

//@version=6
indicator("kill zones", overlay=true)
// === INPUTY ===
// London extended
show_london_ext = input.bool(true, "Pokaż London extended (07:00-10:00 Warszawa)")
ext_start_h = input.int(7, "London extended start hour", minval=0, maxval=23)
ext_start_m = input.int(0, "London extended start minute", minval=0, maxval=59)
ext_end_h   = input.int(10, "London extended end hour", minval=0, maxval=23)
ext_end_m   = input.int(0, "London extended end minute", minval=0, maxval=59)
col_london_ext = input.color(color.new(color.blue, 75), "Kolor London extended")

// London narrow
show_london_narrow = input.bool(true, "Pokaż London narrow (08:30-09:00 Warszawa)")
london_start_h = input.int(8, "London narrow start hour", minval=0, maxval=23)
london_start_m = input.int(30, "London narrow start minute", minval=0, maxval=59)
london_end_h   = input.int(9, "London narrow end hour", minval=0, maxval=23)
london_end_m   = input.int(0, "London narrow end minute", minval=0, maxval=59)
col_london_narrow = input.color(color.new(color.blue, 75), "Kolor London narrow")

// US extended
show_us_ext = input.bool(true, "Pokaż US extended (09:00-10:30 NY)")
us_ext_start_h = input.int(9, "US extended start hour (NY)", minval=0, maxval=23)
us_ext_start_m = input.int(0, "US extended start minute (NY)", minval=0, maxval=59)
us_ext_end_h   = input.int(10, "US extended end hour (NY)", minval=0, maxval=23)
us_ext_end_m   = input.int(30, "US extended end minute (NY)", minval=0, maxval=59)
col_us_ext = input.color(color.new(color.orange, 75), "Kolor US extended")

// US narrow
show_us_narrow = input.bool(true, "Pokaż US narrow (09:30-10:00 NY)")
us_start_h_ny = input.int(9, "US narrow start hour (NY)", minval=0, maxval=23)
us_start_m_ny = input.int(30, "US narrow start minute (NY)", minval=0, maxval=59)
us_end_h_ny   = input.int(10, "US narrow end hour (NY)", minval=0, maxval=23)
us_end_m_ny   = input.int(0, "US narrow end minute (NY)", minval=0, maxval=59)
col_us_narrow = input.color(color.new(color.orange, 75), "Kolor US narrow")

// === FUNKCJA SPRAWDZAJĄCA OKNO CZASOWE W PODANEJ STREFIE ===
is_between(t, sh, sm, eh, em, tz) =>
    h = hour(t, tz)
    m = minute(t, tz)
    (h > sh or (h == sh and m >= sm)) and (h < eh or (h == eh and m < em))

t_chart = time

// === FLAGI ===
in_london_ext    = show_london_ext    ? is_between(t_chart, ext_start_h, ext_start_m, ext_end_h, ext_end_m, "Europe/Warsaw") : false
in_london_narrow = show_london_narrow ? is_between(t_chart, london_start_h, london_start_m, london_end_h, london_end_m, "Europe/Warsaw") : false
in_us_ext        = show_us_ext        ? is_between(t_chart, us_ext_start_h, us_ext_start_m, us_ext_end_h, us_ext_end_m, "America/New_York") : false
in_us_narrow     = show_us_narrow     ? is_between(t_chart, us_start_h_ny, us_start_m_ny, us_end_h_ny, us_end_m_ny, "America/New_York") : false

// === RYSOWANIE ===
bgcolor(in_london_ext ? col_london_ext : na, title="London extended Kill Zone")
bgcolor(in_london_narrow ? col_london_narrow : na, title="London narrow Kill Zone")
bgcolor(in_us_ext ? col_us_ext : na, title="US extended Kill Zone")
bgcolor(in_us_narrow ? col_us_narrow : na, title="US narrow Kill Zone")

// === ALERTY ===
alertcondition(in_london_ext, title="London extended active", message="London extended kill zone (07:00-10:00 Warszawa) aktywne")
alertcondition(in_london_narrow, title="London narrow active", message="London narrow kill zone (08:30-09:00 Warszawa) aktywne")
alertcondition(in_us_ext, title="US extended active", message="US extended kill zone (09:00-10:30 NY) aktywne")
alertcondition(in_us_narrow, title="US narrow active", message="US narrow kill zone (09:30-10:00 NY) aktywne")
````
