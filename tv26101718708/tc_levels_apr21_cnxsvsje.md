# TC Levels Apr21

- url: https://www.tradingview.com/script/CnxSVsje-TC-Levels-Apr21/
- type: indicator
- pine_id: PUB;6814fc6167d24d9b9ae71b5441fe266e
- version: 1.0

## Description

TradeCompanion support and resistance levels for MES1! — April 21. Major levels (solid), minor levels (dashed). Green = support, red = resistance.

## Source Code

````pine
//@version=6
indicator("TC Levels Apr21", overlay=true)

// SUPPORT MAJOR (solid green)
hline(7135, "7135 S*", color.green, hline.style_solid, 2)
hline(7121, "7121 S*", color.green, hline.style_solid, 2)
hline(7104, "7104 S*", color.green, hline.style_solid, 2)
hline(7086, "7086 S*", color.green, hline.style_solid, 2)
hline(7078, "7078 S*", color.green, hline.style_solid, 2)
hline(7057, "7057 S*", color.green, hline.style_solid, 2)
hline(7049, "7049 S*", color.green, hline.style_solid, 2)
hline(7036, "7036 S*", color.green, hline.style_solid, 2)
hline(7014, "7014 S*", color.green, hline.style_solid, 2)
hline(7003, "7003 S*", color.green, hline.style_solid, 2)
hline(6983, "6983 S*", color.green, hline.style_solid, 2)
hline(6963, "6963 S*", color.green, hline.style_solid, 2)
hline(6938, "6938 S*", color.green, hline.style_solid, 2)
hline(6928, "6928 S*", color.green, hline.style_solid, 2)
hline(6916, "6916 S*", color.green, hline.style_solid, 2)
hline(6903, "6903 S*", color.green, hline.style_solid, 2)
hline(6888, "6888 S*", color.green, hline.style_solid, 2)
hline(6873, "6873 S*", color.green, hline.style_solid, 2)
hline(6861, "6861 S*", color.green, hline.style_solid, 2)
hline(6848, "6848 S*", color.green, hline.style_solid, 2)
hline(6838, "6838 S*", color.green, hline.style_solid, 2)

// SUPPORT MINOR (dashed green)
hline(7148, "7148 S", color.green, hline.style_dashed, 1)
hline(7126, "7126 S", color.green, hline.style_dashed, 1)
hline(7110, "7110 S", color.green, hline.style_dashed, 1)
hline(7095, "7095 S", color.green, hline.style_dashed, 1)
hline(7074, "7074 S", color.green, hline.style_dashed, 1)
hline(7067, "7067 S", color.green, hline.style_dashed, 1)
hline(7053, "7053 S", color.green, hline.style_dashed, 1)
hline(7041, "7041 S", color.green, hline.style_dashed, 1)
hline(7031, "7031 S", color.green, hline.style_dashed, 1)
hline(7026, "7026 S", color.green, hline.style_dashed, 1)
hline(7021, "7021 S", color.green, hline.style_dashed, 1)
hline(7009, "7009 S", color.green, hline.style_dashed, 1)
hline(6993, "6993 S", color.green, hline.style_dashed, 1)
hline(6967, "6967 S", color.green, hline.style_dashed, 1)
hline(6958, "6958 S", color.green, hline.style_dashed, 1)
hline(6948, "6948 S", color.green, hline.style_dashed, 1)
hline(6944, "6944 S", color.green, hline.style_dashed, 1)
hline(6923, "6923 S", color.green, hline.style_dashed, 1)
hline(6908, "6908 S", color.green, hline.style_dashed, 1)
hline(6893, "6893 S", color.green, hline.style_dashed, 1)
hline(6883, "6883 S", color.green, hline.style_dashed, 1)
hline(6868, "6868 S", color.green, hline.style_dashed, 1)
hline(6853, "6853 S", color.green, hline.style_dashed, 1)
hline(6840, "6840 S", color.green, hline.style_dashed, 1)

// RESISTANCE MAJOR (solid red)
hline(7153, "7153 R*", color.red, hline.style_solid, 2)
hline(7174, "7174 R*", color.red, hline.style_solid, 2)
hline(7194, "7194 R*", color.red, hline.style_solid, 2)
hline(7217, "7217 R*", color.red, hline.style_solid, 2)
hline(7232, "7232 R*", color.red, hline.style_solid, 2)
hline(7253, "7253 R*", color.red, hline.style_solid, 2)
hline(7283, "7283 R*", color.red, hline.style_solid, 2)
hline(7290, "7290 R*", color.red, hline.style_solid, 2)
hline(7318, "7318 R*", color.red, hline.style_solid, 2)
hline(7341, "7341 R*", color.red, hline.style_solid, 2)
hline(7358, "7358 R*", color.red, hline.style_solid, 2)
hline(7369, "7369 R*", color.red, hline.style_solid, 2)

// RESISTANCE MINOR (dashed red)
hline(7159, "7159 R", color.red, hline.style_dashed, 1)
hline(7169, "7169 R", color.red, hline.style_dashed, 1)
hline(7186, "7186 R", color.red, hline.style_dashed, 1)
hline(7204, "7204 R", color.red, hline.style_dashed, 1)
hline(7224, "7224 R", color.red, hline.style_dashed, 1)
hline(7239, "7239 R", color.red, hline.style_dashed, 1)
hline(7245, "7245 R", color.red, hline.style_dashed, 1)
hline(7262, "7262 R", color.red, hline.style_dashed, 1)
hline(7271, "7271 R", color.red, hline.style_dashed, 1)
hline(7304, "7304 R", color.red, hline.style_dashed, 1)
hline(7314, "7314 R", color.red, hline.style_dashed, 1)
hline(7330, "7330 R", color.red, hline.style_dashed, 1)
hline(7352, "7352 R", color.red, hline.style_dashed, 1)
hline(7362, "7362 R", color.red, hline.style_dashed, 1)
````
