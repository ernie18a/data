//+------------------------------------------------------------------+
//|                                                SpreadMonitor.mq5 |
//|                                 Musa Khunarikov, Copyright 2026. |
//|                      https://www.mql5.com/ru/users/musa1994/news |
//+------------------------------------------------------------------+
#property copyright "Musa Khunarikov, 2026"
#property link      "https://www.mql5.com/ru/users/musa1994/news"
#property version   "1.01"

#property description "Spread Monitor — индикатор текущего спреда."
#property description "Показывает спред в пунктах с цветовой индикацией:"
#property description "зелёный — низкий, жёлтый — средний, красный — высокий."
#property description "Поддержка русского и английского языков."
#property description "Spread Monitor — current spread indicator with color alerts."

#property indicator_chart_window
#property indicator_plots   0
#property indicator_buffers 0

//--- Язык
enum ENUM_LANG
  {
   LANG_RU = 0,   // Русский
   LANG_EN = 1    // English
  };

//--- Настройки
input ENUM_LANG Language      = LANG_RU;   // Язык / Language
input int    X_Offset         = 10;        // Отступ по X / X offset
input int    Y_Offset         = 20;        // Отступ по Y / Y offset
input int    FontSize         = 12;        // Размер шрифта / Font size
input color  ColorLow         = clrLime;   // Цвет низкого спреда / Low spread color
input color  ColorMid         = clrYellow; // Цвет среднего спреда / Mid spread color
input color  ColorHigh        = clrRed;    // Цвет высокого спреда / High spread color
input int    MidThreshold     = 20;        // Порог среднего спреда / Mid threshold
input int    HighThreshold    = 50;        // Порог высокого спреда / High threshold

//--- Глобальные переменные
string objName = "SpreadMonitor_Label";

//--- Тексты на двух языках
string TextSpread[2] = {"СПРЕД", "SPREAD"};
string TextPts[2]    = {"пт",    "pts"};

//+------------------------------------------------------------------+
//| Инициализация                                                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
     {
      Print("Ошибка создания объекта. Код: ", GetLastError());
      return(INIT_FAILED);
     }

   ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, X_Offset);
   ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, Y_Offset);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, objName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, objName, OBJPROP_HIDDEN, true);

   Print("Spread Monitor запущен / started. Язык / Language: ",
         (Language == LANG_RU ? "Русский" : "English"));
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Деинициализация                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, objName);
   Print("Spread Monitor остановлен / stopped. Причина / Reason: ", reason);
  }

//+------------------------------------------------------------------+
//| Расчёт                                                            |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   int spreadPoints = (int)MathRound((ask - bid) / _Point);

   color clr = ColorLow;
   if(spreadPoints >= HighThreshold)
      clr = ColorHigh;
   else
      if(spreadPoints >= MidThreshold)
         clr = ColorMid;

   int idx = (int)Language;
   string text = StringFormat("%s: %d %s  |  Bid: %.*f  Ask: %.*f",
                              TextSpread[idx],
                              spreadPoints,
                              TextPts[idx],
                              _Digits, bid,
                              _Digits, ask);

   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
