//+------------------------------------------------------------------+
//|                                                    CCIValues.mq5 |
//|                                    Copyright 2015, Mohit Marwaha |
//|                                               marwaha1@gmail.com |
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2015, Mohit Marwaha"
#property link      "marwaha1@gmail.com"
//---- номер версии индикатора
#property version   "1.00"
//+------------------------------------------------+ 
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------+ 
//|  Объявление констант                           |
//+------------------------------------------------+
#define INDICATOR_NAME      "CCIValues"         // Имя индикатора
//+------------------------------------------------+ 
// Описание перечисления type_font                 |
// Описание класса CFontName                       | 
//+------------------------------------------------+ 
#include <GetFontName.mqh>
CFontName FONT;
//+------------------------------------------------+ 
//|  Входные параметры индикатора                  |
//+------------------------------------------------+ 
input string Symbols_Sirname=INDICATOR_NAME"_Label_CCIValues_";  // Название для меток индикатора
//---- настройки для таймфрейма 1
input bool ShowTimeframe1=true;                         //1 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe1=PERIOD_M1;             //1 Таймфрейм индикатора для расчета индикатора
input uint iPeriod1=10;                                 //1 Период индикатора

//---- настройки для таймфрейма 2
input bool ShowTimeframe2=true;                         //2 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe2=PERIOD_M5;             //2 Таймфрейм индикатора для расчета индикатора
input uint iPeriod2=10;                                 //2 Период индикатора

//---- настройки для таймфрейма 3
input bool ShowTimeframe3=true;                         //3 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe3=PERIOD_M15;            //3 Таймфрейм индикатора для расчета индикатора
input uint iPeriod3=10;                                 //3 Период индикатора

//---- настройки для таймфрейма 4
input bool ShowTimeframe4=true;                         //4 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe4=PERIOD_M30;            //4 Таймфрейм индикатора для расчета индикатора
input uint iPeriod4=10;                                 //4 Период индикатора для расчета индикатора

//---- настройки для таймфрейма 5
input bool ShowTimeframe5=true;                         //5 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe5=PERIOD_H1;             //5 Таймфрейм индикатора для расчета индикатора
input uint iPeriod5=10;                                 //5 Период индикатора для расчета индикатора

//---- настройки для таймфрейма 6
input bool ShowTimeframe6=true;                         //6 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe6=PERIOD_H2;             //6 Таймфрейм индикатора для расчета индикатора
input uint iPeriod6=10;                                 //6 Период индикатора для расчета индикатора

//---- настройки для таймфрейма 7
input bool ShowTimeframe7=true;                         //7 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe7=PERIOD_H4;             //7 Таймфрейм индикатора для расчета индикатора
input uint iPeriod7=10;                                 //7 Период индикатора для расчета индикатора

//---- настройки для таймфрейма 8
input bool ShowTimeframe8=true;                         //8 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe8=PERIOD_H12;            //8 Таймфрейм индикатора для расчета индикатора
input uint iPeriod8=10;                                 //8 Период индикатора для расчета индикатора

//---- настройки для таймфрейма 9
input bool ShowTimeframe9=true;                         //9 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe9=PERIOD_D1;             //9 Таймфрейм индикатора для расчета индикатора
input uint iPeriod9=10;                                 //9 Период индикатора для расчета индикатора

//---- настройки для таймфрейма 10
input bool ShowTimeframe10=true;                        //10 Отображение таймфрейма
input ENUM_TIMEFRAMES Timeframe10=PERIOD_W1;            //10 Таймфрейм индикатора для расчета индикатора
input uint iPeriod10=10;                                //10 Период индикатора для расчета индикатора

input ENUM_APPLIED_PRICE   CCIPrice=PRICE_MEDIAN;       // Цена CCI индикатора

//---- настройки визуального отображения индикатора
input uint SignalBar=0;                                 // Номер бара для получения сигнала (0 - текущий бар)
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_UPPER;   // Угол расположения индикатора
input uint X_=10;                                       // Смещение по горизонтали индикатора
input uint Y_=25;                                       // Смещение по вертикали индикатора
//---- настройки шрифта
input type_font Font_Type=Font14;                       // Шрифт отображения индикатора
input uint Font_Size=13;                                // Размер шрифта
input int HighLevel=+100;                               // уровень перекупленности
input int LowLevel=-100;                                // уровень перепроданности
input color HighColor=clrLightSeaGreen;                 // цвет перекупленности
input color MiddleColor=clrGray;                        // цвет вне тренда
input color LowColor=clrOrange;                         // цвет перепроданности
//+-----------------------------------+
//---- объявление целочисленных переменных для хендлов индикаторов
int CCI_Handle[10];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total[10];
//---- объявление переменных для имен меток
string Name[10];
//---- объявление переменных для текста
string Text[10];
//---- объявление переменных для параметров индикаторов CCI
bool ShowTimeframe[10];
ENUM_TIMEFRAMES Timeframe[10];
uint iPeriod[10];
uint iX[10];
uint iY[10];
string sFontType;
//+------------------------------------------------------------------+
//|  Получение таймфрейма в виде строки                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Создание текстовой метки                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  string textTT,           // текст всплывающей подсказки
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой метки                                   |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // идентификатор графика
               string name,             // имя объекта
               int    nwin,             // индекс окна
               ENUM_BASE_CORNER corner, // положение угла привязки
               ENUM_ANCHOR_POINT point, // положение точки привязки
               int    X,                // дистанция в пикселях по оси X от угла привязки
               int    Y,                // дистанция в пикселях по оси Y от угла привязки
               string text,             // текст
               string textTT,           // текст всплывающей подсказки
               color  Color,            // цвет текста
               string Font,             // шрифт текста
               int    Size)             // размер шрифта
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация массивов переменных для индикаторов
   ArrayInitialize(iX,X_);
//----  
   ShowTimeframe[0]=ShowTimeframe1;
   Timeframe[0]=Timeframe1;
   iPeriod[0]=iPeriod1;
   iY[0]=Y_;
//----
   ShowTimeframe[1]=ShowTimeframe2;
   Timeframe[1]=Timeframe2;
   iPeriod[1]=iPeriod2;
   if(ShowTimeframe[1]) iY[1]=iY[0]+20;
   else iY[1]=iY[0];
//----
   ShowTimeframe[2]=ShowTimeframe3;
   Timeframe[2]=Timeframe3;
   iPeriod[2]=iPeriod3;
   if(ShowTimeframe[2]) iY[2]=iY[1]+20;
   else iY[2]=iY[1];
//----
   ShowTimeframe[3]=ShowTimeframe4;
   Timeframe[3]=Timeframe4;
   iPeriod[3]=iPeriod4;
   if(ShowTimeframe[3]) iY[3]=iY[2]+20;
   else iY[3]=iY[2];
//----
   ShowTimeframe[4]=ShowTimeframe5;
   Timeframe[4]=Timeframe5;
   iPeriod[4]=iPeriod5;
   if(ShowTimeframe[4]) iY[4]=iY[3]+20;
   else iY[4]=iY[3];
//----
   ShowTimeframe[5]=ShowTimeframe6;
   Timeframe[5]=Timeframe6;
   iPeriod[5]=iPeriod6;
   if(ShowTimeframe[5]) iY[5]=iY[4]+20;
   else iY[5]=iY[4];
//----
   ShowTimeframe[6]=ShowTimeframe7;
   Timeframe[6]=Timeframe7;
   iPeriod[6]=iPeriod7;
   if(ShowTimeframe[6]) iY[6]=iY[5]+20;
   else iY[6]=iY[5];
//----
   ShowTimeframe[7]=ShowTimeframe8;
   Timeframe[7]=Timeframe8;
   iPeriod[7]=iPeriod8;
   if(ShowTimeframe[7]) iY[7]=iY[6]+20;
   else iY[7]=iY[6];
//----
   ShowTimeframe[8]=ShowTimeframe9;
   Timeframe[8]=Timeframe9;
   iPeriod[8]=iPeriod9;
   if(ShowTimeframe[8]) iY[8]=iY[7]+20;
   else iY[8]=iY[7];
//----
   ShowTimeframe[9]=ShowTimeframe10;
   Timeframe[9]=Timeframe10;
   iPeriod[9]=iPeriod10;
   if(ShowTimeframe[9]) iY[9]=iY[8]+20;
   else iY[9]=iY[8];
//--- получение хендлов индикаторов CCI
   for(int count=0; count<10; count++)
     {
      if(!ShowTimeframe[count]) continue;
      CCI_Handle[count]=iCCI(Symbol(),Timeframe[count],iPeriod[count],CCIPrice);
      if(CCI_Handle[count]==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора CCI "+string(count+1));
         return(INIT_FAILED);
        }
     }

//---- инициализация переменных
   for(int count=0; count<10; count++) if(ShowTimeframe[count]) min_rates_total[count]=int(iPeriod[count])+int(SignalBar);
   for(int count=0; count<10; count++) if(ShowTimeframe[count]) Name[count]=Symbols_Sirname+" "+string(count+1);
   for(int count=0; count<10; count++) if(ShowTimeframe[count]) Text[count]="CCI("+GetStringTimeframe(Timeframe[count])+","+string(iPeriod[count])+")"+"=";
   sFontType=FONT.GetFontName(Font_Type);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectsDeleteAll(0,Symbols_Sirname,-1,-1);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   for(int count=0; count<10; count++) if(ShowTimeframe[count])
     {
      if(BarsCalculated(CCI_Handle[count])<min_rates_total[count]) return(prev_calculated);
      if(BarsCalculated(CCI_Handle[count])<Bars(Symbol(),Timeframe[count])) return(prev_calculated);
     }
     
//---- 
   for(int count=0; count<10; count++) if(ShowTimeframe[count])
     {
      double CCI[1];
      if(CopyBuffer(CCI_Handle[count],0,SignalBar,1,CCI)<=0) return(prev_calculated);
      color Col=MiddleColor;
      if(CCI[0]>HighLevel) Col=HighColor;
      if(CCI[0]<LowLevel) Col=LowColor;
      string info=Text[count]+DoubleToString(CCI[0],0);
      SetTLabel(0,Name[count],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),iX[count],iY[count],info,info,Col,sFontType,Font_Size);
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+