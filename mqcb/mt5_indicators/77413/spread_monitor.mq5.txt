//+------------------------------------------------------------------+
//|                                                SpreadMonitor.mq5 |
//|                                 Musa Khunarikov, Copyright 2026. |
//|                      https://www.mql5.com/ru/users/musa1994/news |
//+------------------------------------------------------------------+
#property copyright "Musa Khunarikov, 2026"
#property link      "https://www.mql5.com/ru/users/musa1994/news"
#property version   "1.02"

#property description "Spread Monitor — индикатор текущего спреда."
#property description "Показывает спред в пунктах с графической панелью и цветовой индикацией."
#property description "Поддержка русского и английского языков."

#property indicator_chart_window
#property indicator_plots   0
#property indicator_buffers 0

//--- Язык
enum ENUM_LANG {
   LANG_RU = 0,   // Русский
   LANG_EN = 1    // English
};

//--- Настройки
input ENUM_LANG Language      = LANG_RU;   // Язык / Language
input int    X_Offset         = 20;        // Отступ по X / X offset
input int    Y_Offset         = 30;        // Отступ по Y / Y offset
input int    PanelWidth       = 220;       // Ширина панели (px)
input int    PanelHeight      = 50;        // Высота панели (px)
input int    FontSize         = 10;        // Размер шрифта
input color  ColorLow         = clrLime;   // Цвет низкого спреда
input color  ColorMid         = clrYellow; // Цвет среднего спреда
input color  ColorHigh        = clrRed;    // Цвет высокого спреда
input int    MidThreshold     = 20;        // Порог среднего спреда (пунктов)
input int    HighThreshold    = 50;        // Порог высокого спреда (пунктов)

//--- Глобальные переменные
string prefix = "SpreadMon_";
string bgName, barName, textName;

//--- Тексты
string TextSpread[2] = {"СПРЕД", "SPREAD"};
string TextPts[2]    = {"пт",    "pts"};

//+------------------------------------------------------------------+
//| Инициализация                                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   bgName   = prefix + "BG";
   barName  = prefix + "BAR";
   textName = prefix + "TEXT";

   //--- Фон панели
   ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, X_Offset);
   ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, Y_Offset);
   ObjectSetInteger(0, bgName, OBJPROP_XSIZE, PanelWidth);
   ObjectSetInteger(0, bgName, OBJPROP_YSIZE, PanelHeight);
   ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bgName, OBJPROP_COLOR, clrGray);
   ObjectSetInteger(0, bgName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, bgName, OBJPROP_BACK, false);
   ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, bgName, OBJPROP_HIDDEN, true);

   //--- Полоса (будет менять ширину)
   ObjectCreate(0, barName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, barName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, barName, OBJPROP_XDISTANCE, X_Offset + 5);
   ObjectSetInteger(0, barName, OBJPROP_YDISTANCE, Y_Offset + PanelHeight - 12);
   ObjectSetInteger(0, barName, OBJPROP_XSIZE, 0);
   ObjectSetInteger(0, barName, OBJPROP_YSIZE, 7);
   ObjectSetInteger(0, barName, OBJPROP_BGCOLOR, clrLime);
   ObjectSetInteger(0, barName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, barName, OBJPROP_COLOR, clrLime);
   ObjectSetInteger(0, barName, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, barName, OBJPROP_BACK, false);
   ObjectSetInteger(0, barName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, barName, OBJPROP_HIDDEN, true);

   //--- Текст
   ObjectCreate(0, textName, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, textName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, textName, OBJPROP_XDISTANCE, X_Offset + 10);
   ObjectSetInteger(0, textName, OBJPROP_YDISTANCE, Y_Offset + 10);
   ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, FontSize);
   ObjectSetString(0, textName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, textName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, textName, OBJPROP_HIDDEN, true);

   Print("Spread Monitor запущен / started");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Деинициализация                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, bgName);
   ObjectDelete(0, barName);
   ObjectDelete(0, textName);
   Print("Spread Monitor остановлен / stopped. Причина: ", reason);
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

   //--- Определяем цвет и ширину полосы
   color clr = ColorLow;
   int barWidth = 0;
   int maxSpread = HighThreshold * 2; // для масштаба
   if(spreadPoints >= HighThreshold) {
      clr = ColorHigh;
      barWidth = PanelWidth - 20;
   } else if(spreadPoints >= MidThreshold) {
      clr = ColorMid;
      barWidth = (int)((double)(spreadPoints - MidThreshold) / (HighThreshold - MidThreshold) * (PanelWidth - 20));
   } else {
      clr = ColorLow;
      barWidth = (int)((double)spreadPoints / MidThreshold * (PanelWidth - 20));
   }
   if(barWidth < 0) barWidth = 0;
   if(barWidth > PanelWidth - 20) barWidth = PanelWidth - 20;

   //--- Обновляем полосу
   ObjectSetInteger(0, barName, OBJPROP_XSIZE, barWidth);
   ObjectSetInteger(0, barName, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, barName, OBJPROP_COLOR, clr);

   //--- Формируем текст
   int idx = (int)Language;
   string text = StringFormat("%s: %d %s", TextSpread[idx], spreadPoints, TextPts[idx]);
   ObjectSetString(0, textName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, textName, OBJPROP_COLOR, clr);

   return(rates_total);
}
//+------------------------------------------------------------------+