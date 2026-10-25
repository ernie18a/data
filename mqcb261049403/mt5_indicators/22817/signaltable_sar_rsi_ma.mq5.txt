//+------------------------------------------------------------------+
//|                                       SignalTable_Sar_RSI_MA.mq5 |
//|                                   Copyright © 2007, Antonuk Oleg |
//|                                            antonukoleg@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Antonuk Oleg"
#property link      "antonukoleg@gmail.com"
#property version   "1.00"
#property description "Cигналы на покупку и продажу с нескольких индикаторов и разных таймфреймов в виде таблицы"

//---- номер версии индикатора
#property version   "2.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора не использовано буферов
#property indicator_buffers 0
//---- использовано 0 графических построений
#property indicator_plots   0
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
// Описание перечисления type_font               |
// Описание класса CFontName                     | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string Symbol_="";                              // финансовый актив
sinput string info1="<<<==============  Параметры iSAR ===============>>>";
//--- параметры iSAR
input double SARStep=0.02;                            // Шаг iSAR
input double SARMaximum=0.2;                          // Максимум iSAR
input uint SARNumberofBar=0;                          // Номер бара для получения сигнала iSAR
sinput string info2="<<<============  Параметры Мувингов =============>>>";
//---- Параметры мувингов
input  ENUM_MA_METHOD   MAType=MODE_EMA;
input uint   FastMA=13;
input uint   SlowMA=24;
input ENUM_APPLIED_PRICE MAPrice=PRICE_CLOSE;
input uint MANumberofBar=0;                           // Номер бара для получения сигнала Мувингов
sinput string info3="<<<==============  Параметры iRSI ===============>>>";
//---- Параметры RSI
input int   RSIPeriod=14;
input ENUM_APPLIED_PRICE RSIPrice=PRICE_CLOSE; 
input uint RSIHighLevel=60;                           // уровень перезакупа iRSI
input uint RSILowLevel=40;                            // уровень перепроданности iRSI
input bool RSIInvert=true;                            // инвертирование сигналов iRSI
input uint RSINumberofBar=0;                          // Номер бара для получения сигнала RSI

sinput string info4="<<< === Параметры визуального отображения индикатора === >>>";
//---- Параметры визуального отображения индикаторов
input color  TextColor=clrBlueViolet;                 // цвет текста
input color  UpColor=clrDodgerBlue;                   // цвет растущего тренда
input color  MdColor=clrGray;                         // цвет отсутствия тренда
input color  DnColor=clrMagenta;                      // цвет падающего тренда
input int    FontSize=13;                             // размер шрифта
input type_font FontType=Font14;                      // тип шрифта
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; // угол расположения
input uint Y_=20;                                     // расположение по вертикали
input uint X_=5;                                      // расположение по горизонтали
input string LableSirname="SignalTable_Sar_RSI_MA 1";
//+----------------------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
double Width;
ENUM_ANCHOR_POINT SPoint;
string sFontType,Lable1,Lable2,Lable3,Lable4,Lable1_[9],Lable2_[9],Lable3_[9],Lable4_[9],symbol;
uint shift_1,shift_2,shift_3,shift_4,X1,X2,X2i[9];
ENUM_TIMEFRAMES period[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
//---- создаем еще один массив с названиями индикаторов
string signalNameString[]={"MA","RSI","SAR"};
//---- Объявление целых переменных для хендлов индикаторов
int FsMA_Handle[9],SlMA_Handle[9],RSI_Handle[9],SAR_Handle[9];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=1;

//---- инициализация переменных 
   if(Symbol_!="") symbol=Symbol_;
   else symbol=Symbol();
   Width=3.3; //ширина между символами
   SPoint=ENUM_ANCHOR_POINT(2*WhatCorner);

//---- получение хендлов
   for(int iii=0; iii<9; iii++)
     {
      //---- получение хендла индикатора iMA
      FsMA_Handle[iii]=iMA(symbol,period[iii],FastMA,0,MAType,MAPrice);
      if(FsMA_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMA");

      //---- получение хендла индикатора iMA
      SlMA_Handle[iii]=iMA(symbol,period[iii],SlowMA,0,MAType,MAPrice);
      if(SlMA_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMA");

      //---- получение хендла индикатора iRSI
      RSI_Handle[iii]=iRSI(symbol,period[iii],RSIPeriod,RSIPrice);
      if(RSI_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI");

      //---- получение хендла индикатора iSAR
      SAR_Handle[iii]=iSAR(symbol,period[iii],SARStep,SARMaximum);
      if(SAR_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iSAR");
     }

//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
//---- 
   Lable1=LableSirname+"_"+"String_0";
   Lable2=LableSirname+"_"+"String_1";
   Lable3=LableSirname+"_"+"String_2";
   Lable4=LableSirname+"_"+"String_3";

   for(int iii=0; iii<9; iii++)
     {
      Lable1_[iii]=LableSirname+"_"+"String_0_"+string(iii);
      Lable2_[iii]=LableSirname+"_"+"String_1_"+string(iii);
      Lable3_[iii]=LableSirname+"_"+"String_2_"+string(iii);
      Lable4_[iii]=LableSirname+"_"+"String_3_"+string(iii);
     }

//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=int(Y_+FontSize*6);
         shift_2=int(Y_+FontSize*4);
         shift_3=int(Y_+FontSize*2);
         shift_4=int(Y_+0);
         X1=int(X_+FontSize*3);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=int(Y_+FontSize*6);
         shift_2=int(Y_+FontSize*4);
         shift_3=int(Y_+FontSize*2);
         shift_4=int(Y_+0);
         X1=int(X_);
         X2=X_+FontSize*5;
         break;
        }

      case CORNER_RIGHT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*2);
         shift_3=int(Y_+FontSize*4);
         shift_4=int(Y_+FontSize*6);
         X1=int(X_+FontSize*3);
         X2=int(X_);
         break;
        }

      case CORNER_LEFT_UPPER:
        {
         shift_1=int(Y_+0);
         shift_2=int(Y_+FontSize*2);
         shift_3=int(Y_+FontSize*4);
         shift_4=int(Y_+FontSize*6);
         X1=int(X_);
         X2=int(X_+FontSize*5);
        }
     }

   SetTLabel(0,Lable1,0,WhatCorner,SPoint,X1,shift_1,"Sar: ",TextColor,sFontType,FontSize);
   SetTLabel(0,Lable2,0,WhatCorner,SPoint,X1,shift_2,"RSI: ",TextColor,sFontType,FontSize);
   SetTLabel(0,Lable3,0,WhatCorner,SPoint,X1,shift_3,"MA: ",TextColor,sFontType,FontSize);

   for(int iii=0; iii<9; iii++) X2i[iii]=X2+int(Width*iii*FontSize);

   for(int iii=0; iii<9; iii++)
      SetTLabel(0,Lable4_[iii],0,WhatCorner,SPoint,X2i[iii],shift_4,GetStringTimeframe(period[iii]),TextColor,sFontType,FontSize);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Массивы переменных для создания индикаторных значений           |
//+------------------------------------------------------------------+  
class CArray
  {
public: double    IndArr[];
  };
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   for(int iii=0; iii<9; iii++)
      if(BarsCalculated(FsMA_Handle[iii])<min_rates_total
         || BarsCalculated(SlMA_Handle[iii])<min_rates_total
         || BarsCalculated(RSI_Handle[iii])<min_rates_total
         || BarsCalculated(SAR_Handle[iii])<min_rates_total)
         return(RESET);

//----
   CArray FsMA[9],SlMA[9],RSI[9],SAR[9];
   string Symb;
   color Color;

//---- копируем вновь появившиеся данные в массивы
   for(int iii=0; iii<9; iii++)
     {
      if(CopyBuffer(RSI_Handle[iii],0,RSINumberofBar,1,RSI[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(SAR_Handle[iii],0,SARNumberofBar,1,SAR[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(FsMA_Handle[iii],0,MANumberofBar,1,FsMA[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(SlMA_Handle[iii],0,MANumberofBar,1,SlMA[iii].IndArr)<=0) return(RESET);
     }
//---- 
   for(int iii=0; iii<9; iii++)
     {
      if(SAR[iii].IndArr[0]<close[rates_total-1])
        {
         Symb="г";
         Color=UpColor;
        }
      else if(SAR[iii].IndArr[0]>close[rates_total-1])
        {
         Symb="д";
         Color=DnColor;
        }
      else
        {
         Symb="в";
         Color=MdColor;
        }

      SetTLabel(0,Lable1_[iii],0,WhatCorner,SPoint,X2i[iii],shift_1,Symb,Color,"Wingdings 3",FontSize);
     }
//----
   for(int iii=0; iii<9; iii++)
     {
      if(RSI[iii].IndArr[0]<RSILowLevel)
        {
         if(RSIInvert)
           {
            Symb="г";
            Color=UpColor;
           }
         else
           {
            Symb="д";
            Color=DnColor;
           }
        }
      else if(RSI[iii].IndArr[0]>RSIHighLevel)
        {
         if(RSIInvert)
           {
            Symb="д";
            Color=DnColor;
           }
          else
           {
            Symb="г";
            Color=UpColor;
           }
        }
      else
        {
         Symb="в";
         Color=MdColor;
        }

      SetTLabel(0,Lable2_[iii],0,WhatCorner,SPoint,X2i[iii],shift_2,Symb,Color,"Wingdings 3",FontSize);
     }
//----
   for(int iii=0; iii<9; iii++)
     {
      if(FsMA[iii].IndArr[0]>SlMA[iii].IndArr[0])
        {
         Symb="г";
         Color=UpColor;
        }
      else if(FsMA[iii].IndArr[0]<SlMA[iii].IndArr[0])
        {
         Symb="д";
         Color=DnColor;
        }
      else
        {
         Symb="в";
         Color=MdColor;
        }

      SetTLabel(0,Lable3_[iii],0,WhatCorner,SPoint,X2i[iii],shift_3,Symb,Color,"Wingdings 3",FontSize);
     }
//----  
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,Lable1);
   ObjectDelete(0,Lable2);
   ObjectDelete(0,Lable3);
   ObjectDelete(0,Lable4);

   for(int iii=0; iii<9; iii++)
     {
      ObjectDelete(0,Lable1_[iii]);
      ObjectDelete(0,Lable2_[iii]);
      ObjectDelete(0,Lable3_[iii]);
      ObjectDelete(0,Lable4_[iii]);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Получение стрингового таймфрейма                                |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  Создание текстовой лейбы                                        |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // идентификатор графика
 string name,             // имя объекта
 int    nwin,             // индекс окна
 ENUM_BASE_CORNER corner,// положение угла привязки
 ENUM_ANCHOR_POINT point, // положение точки привязки
 int    X,                // дистанция в пикселях по оси X от угла привязки
 int    Y,                // дистанция в пикселях по оси Y от угла привязки
 string text,             // текст
 color  Color,            // цвет текста
 string Font,             // шрифт текста
 int    Size              // размер шрифта
 )
//---- 
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
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой лейбы                                   |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // идентификатор графика
 string name,             // имя объекта
 int    nwin,             // индекс окна
 ENUM_BASE_CORNER corner,// положение угла привязки
 ENUM_ANCHOR_POINT point, // положение точки привязки
 int    X,                // дистанция в пикселях по оси X от угла привязки
 int    Y,                // дистанция в пикселях по оси Y от угла привязки
 string text,             // текст
 color  Color,            // цвет текста
 string Font,             // шрифт текста
 int    Size              // размер шрифта
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+
