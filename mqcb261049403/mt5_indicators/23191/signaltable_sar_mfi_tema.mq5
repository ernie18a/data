//+------------------------------------------------------------------+
//|                                     SignalTable_Sar_MFI_TEMA.mq5 |
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
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_M1;           // Период графика 1
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_M5;           // Период графика 2
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_M15;          // Период графика 3
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_M30;          // Период графика 4
input ENUM_TIMEFRAMES TimeFrame5=PERIOD_H1;           // Период графика 5
input ENUM_TIMEFRAMES TimeFrame6=PERIOD_H4;           // Период графика 6
input ENUM_TIMEFRAMES TimeFrame7=PERIOD_D1;           // Период графика 7
input ENUM_TIMEFRAMES TimeFrame8=PERIOD_W1;           // Период графика 8
input ENUM_TIMEFRAMES TimeFrame9=PERIOD_MN1;          // Период графика 9

sinput string info1="<<<==============  Параметры iSAR ===============>>>";
//--- параметры iSAR
input double SARStep=0.02;                            // Шаг iSAR
input double SARMaximum=0.2;                          // Максимум iSAR
input uint SARNumberofBar=0;                          // Номер бара для получения сигнала iSAR
sinput string info2="<<<============  Параметры Мувингов =============>>>";
//---- Параметры мувингов
input uint   FastTEMA=13;                             // быстрый TEMA
input uint   SlowTEMA=24;                             // медленый TEMA
input ENUM_APPLIED_PRICE TEMAPrice=PRICE_CLOSE;       // цена TEMA
input uint TEMANumberofBar=0;                         // Номер бара для получения сигнала Мувингов
sinput string info3="<<<==============  Параметры iMFI ===============>>>";
//---- Параметры MFI
input int   MFIPeriod=14;
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;  // объём iMFI
input uint MFIHighLevel=60;                           // уровень перезакупа iMFI
input uint MFILowLevel=40;                            // уровень перепроданности iMFI
input bool MFIInvert=true;                            // инвертирование сигналов iMFI
input uint MFINumberofBar=0;                          // Номер бара для получения сигнала MFI

sinput string info4="<<< === Параметры визуального отображения индикатора === >>>";
//---- Параметры визуального отображения индикаторов
input color  TextColor=clrBlueViolet;                 // цвет текста
input color  UpColor=clrDarkTurquoise;                // цвет растущего тренда
input color  MdColor=clrSlateBlue;                    // цвет отсутствия тренда
input color  DnColor=clrTomato;                       // цвет падающего тренда
input int    FontSize=13;                             // размер шрифта
input type_font FontType=Font14;                      // тип шрифта
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; // угол расположения
input uint Y_=20;                                     // расположение по вертикали
input uint X_=5;                                      // расположение по горизонтали
input string LableSirname="SignalTable_Sar_MFI_TEMA 1";
//+----------------------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
double Width;
ENUM_ANCHOR_POINT SPoint;
string sFontType,Lable1,Lable2,Lable3,Lable4,Lable1_[9],Lable2_[9],Lable3_[9],Lable4_[9],symbol;
uint shift_1,shift_2,shift_3,shift_4,X1,X2,X2i[9];
ENUM_TIMEFRAMES period[9];
//---- создаем еще один массив с названиями индикаторов
string signalNameString[]={"TEMA","MFI","SAR"};
//---- Объявление целых переменных для хендлов индикаторов
int FsTEMA_Handle[9],SlTEMA_Handle[9],MFI_Handle[9],SAR_Handle[9];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=1;
   period[0]=TimeFrame1;
   period[1]=TimeFrame2;
   period[2]=TimeFrame3;
   period[3]=TimeFrame4;
   period[4]=TimeFrame5;
   period[5]=TimeFrame6;
   period[6]=TimeFrame7;
   period[7]=TimeFrame8;
   period[8]=TimeFrame9;
//---- инициализация переменных 
   if(Symbol_!="") symbol=Symbol_;
   else symbol=Symbol();
   Width=3.3; //ширина между символами
   SPoint=ENUM_ANCHOR_POINT(2*WhatCorner);

//---- получение хендлов
   for(int iii=0; iii<9; iii++)
     {
      //---- получение хендла индикатора iTEMA
      FsTEMA_Handle[iii]=iTEMA(symbol,period[iii],FastTEMA,0,TEMAPrice);
      if(FsTEMA_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iTEMA");

      //---- получение хендла индикатора iTEMA
      SlTEMA_Handle[iii]=iTEMA(symbol,period[iii],SlowTEMA,0,TEMAPrice);
      if(SlTEMA_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iTEMA");

      //---- получение хендла индикатора iMFI
      MFI_Handle[iii]=iMFI(symbol,period[iii],MFIPeriod,MFIVolumeType);
      if(MFI_Handle[iii]==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iMFI");

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
   SetTLabel(0,Lable2,0,WhatCorner,SPoint,X1,shift_2,"MFI: ",TextColor,sFontType,FontSize);
   SetTLabel(0,Lable3,0,WhatCorner,SPoint,X1,shift_3,"TEMA: ",TextColor,sFontType,FontSize);

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
      if(BarsCalculated(FsTEMA_Handle[iii])<min_rates_total
         || BarsCalculated(SlTEMA_Handle[iii])<min_rates_total
         || BarsCalculated(MFI_Handle[iii])<min_rates_total
         || BarsCalculated(SAR_Handle[iii])<min_rates_total)
         return(RESET);

//----
   CArray FsTEMA[9],SlTEMA[9],MFI[9],SAR[9];
   string Symb;
   color Color;

//---- копируем вновь появившиеся данные в массивы
   for(int iii=0; iii<9; iii++)
     {
      if(CopyBuffer(MFI_Handle[iii],0,MFINumberofBar,1,MFI[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(SAR_Handle[iii],0,SARNumberofBar,1,SAR[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(FsTEMA_Handle[iii],0,TEMANumberofBar,1,FsTEMA[iii].IndArr)<=0) return(RESET);
      if(CopyBuffer(SlTEMA_Handle[iii],0,TEMANumberofBar,1,SlTEMA[iii].IndArr)<=0) return(RESET);
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
      if(MFI[iii].IndArr[0]<MFILowLevel)
        {
         if(MFIInvert)
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
      else if(MFI[iii].IndArr[0]>MFIHighLevel)
        {
         if(MFIInvert)
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
      if(FsTEMA[iii].IndArr[0]>SlTEMA[iii].IndArr[0])
        {
         Symb="г";
         Color=UpColor;
        }
      else if(FsTEMA[iii].IndArr[0]<SlTEMA[iii].IndArr[0])
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
