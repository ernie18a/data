# London Session Candle (Ganzo Sweden FIX )

- url: https://www.tradingview.com/script/JoydCaM2-London-Session-Candle-Ganzo-Sweden-FIX/
- type: indicator
- pine_id: PUB;938580b086fc4751bad0d4ba801074d9
- version: 1.0

## Description

This indicator automatically highlights all candles that open between 08:00 and 11:00 Stockholm time (Europe/Stockholm) every day. It is designed to visually isolate specific morning trading hours, such as the London session open, helping traders analyze European market volume and initial morning trends without any timezone confusion

## Source Code

````pine
//@version=6
indicator("London Session Candle (Ganzo Sweden FIX )", overlay=true)

// Europe/Stockholm цагийн бүсээр өдөр бүр 08:00-аас 11:00 хүртэлх хугацааг заах
// "1-7" гэдэг нь Даваагаас Ням гараг хүртэл өдөр бүр гэсэн үг
in_session = time(timeframe.period, "0800-1100:1234567", "Europe/Stockholm")

// Хэрэв лаа тухайн цагийн сесс дотор байвал шар өнгөөр будна
is_target_time = not na(in_session)
barcolor(is_target_time ? color.yellow : na)
````
