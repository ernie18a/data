//+------------------------------------------------------------------+
//|                                           Skyscraper_Fix_x10.mq5 |
//|                               Copyright © 2018, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property description "Индикатор отображает положение направление тренда индикатора Skyscraper_Fix с десяти разных таймфреймов"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 0
#property indicator_buffers 0 
//---- не использовано ни одного графического построения
#property indicator_plots   0
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0          // Константа для возврата терминалу команды на пересчёт индикатора
#define INDTOTAL 10      // Константа для количества отображаемых индикаторов
//+----------------------------------------------+
// Описание перечисления type_font               |
// Описание класса CFontName                     | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum Method
  {
   MODE_HighLow,  //High/Low
   MODE_Close     //Close
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H1;           //период графика 1
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H2;           //период графика 2
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H3;           //период графика 3
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H4;           //период графика 4
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H6;           //период графика 5
input ENUM_TIMEFRAMES TimeFrame5=PERIOD_H8;           //период графика 6
input ENUM_TIMEFRAMES TimeFrame6=PERIOD_H12;          //период графика 7
input ENUM_TIMEFRAMES TimeFrame7=PERIOD_D1;           //период графика 8
input ENUM_TIMEFRAMES TimeFrame8=PERIOD_W1;           //период графика 9
input ENUM_TIMEFRAMES TimeFrame9=PERIOD_MN1;          //период графика 10 
input uint SignalBar=1;                               //Номер бара для получения сигнала (0 - текущий бар)
//---- Параметры Skyscraper_Fix
input uint    Length=10;                              //Период ATR
input double  Kv=0.9;                                 //Фактор чувствительности индикатора
input double  Percentage=0;                           //Приближение средней линии к линиям экстремумов
input Method  HighLow=MODE_HighLow;                   //Расчёт индикатора по High/Low или Close
//---- Параметры отображения индикатора
input color  CpColor=clrBlueViolet;                   //цвет названия индикатора
input color  BuyColor=clrLimeGreen;                   //цвет Buy сигнала
input color  UpColor=clrTeal;                         //цвет продолжения растущего тренда
input color  DnColor=clrPurple;                       //цвет продолжения падающего тренда
input color  SellColor=clrRed;                        //цвет Sell сигнала
input int    FontSize=15;                             //размер шрифта
input type_font FontType=Font14;                      //тип шрифта
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; //угол расположения
input uint Y_=20;                                     //расположение по вертикали
input uint X_=5;                                      //расположение по горизонтали
//+----------------------------------------------+
string sFontType;
int min_rates_total;
uint xshift,shift[11];
string sPer[10],sPerA[10],sPerB[10],Cap;
ENUM_TIMEFRAMES ePer[10];
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//|  Класс массивов                                                  |
//+------------------------------------------------------------------+  
class CIndArrow
  {
   //----
public:
   double            m_Ind[2];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
   //---- 
  };
//---- объявление массивов, которые будут в 
// дальнейшем использованы для получения индикаторных значений
CIndArrow Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//----  
   ePer[0]=TimeFrame0;
   ePer[1]=TimeFrame1;
   ePer[2]=TimeFrame2;
   ePer[3]=TimeFrame3;
   ePer[4]=TimeFrame4;
   ePer[5]=TimeFrame5;
   ePer[6]=TimeFrame6;
   ePer[7]=TimeFrame7;
   ePer[8]=TimeFrame8;
   ePer[9]=TimeFrame9;
   for(int poz=0; poz<INDTOTAL; poz++) Ind[poz].m_TimeFrame=ePer[poz];
//---- Получение хендлов индикаторов
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      Ind[poz].m_Handle=iCustom(Symbol(),Ind[poz].m_TimeFrame,"Skyscraper_Fix",Length,Kv,Percentage,HighLow);

      if(Ind[poz].m_Handle==INVALID_HANDLE)
        {
         Print("OnInit()(",poz,"): Не удалось получить хендл индикатора Skyscraper_Fix");
         return(false);
        }
     }
//----   
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
   int ATR_Period=15;
   min_rates_total=ATR_Period+int(Length+1);
   min_rates_total++;
//----  
   xshift=int(X_+8.3*FontSize);
   Cap="Skyscraper_Fix_x10";
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         for(int poz=0; poz<=INDTOTAL; poz++) shift[10-poz]=Y_+22*poz;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         for(int poz=0; poz<=INDTOTAL; poz++) shift[10-poz]=Y_+22*poz;
         break;
        }
      default:
        {
         for(int poz=0; poz<=INDTOTAL; poz++) shift[poz]=Y_+22*poz;
        }
     }

   for(int poz=0; poz<INDTOTAL; poz++)
     {
      sPer[poz]=GetStringTimeframe(ePer[poz]);
      sPerA[poz]=sPer[poz]+"Stat+";
      sPerB[poz]=sPer[poz]+"Stat_";
     }
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      ObjectDelete(0,sPerA[poz]);
      ObjectDelete(0,sPerB[poz]);
     }
   ObjectDelete(0,Cap);
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
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
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
     }
//----
  }
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
//--- проверка количества баров на достаточность для расчета
   for(int poz=0; poz<INDTOTAL; poz++) if(Bars(Symbol(),ePer[poz])<min_rates_total) return(prev_calculated);

//---- копируем вновь появившиеся данные в массивы 
   for(int poz=0; poz<INDTOTAL; poz++) if(CopyBuffer(Ind[poz].m_Handle,5,SignalBar,2,Ind[poz].m_Ind)<=0) return(prev_calculated);
//----
   color ColorGain[INDTOTAL];
   string SignalSymbol[INDTOTAL];
   ArrayInitialize(ColorGain,clrNONE);
//---- копируем вновь появившиеся данные в массивы 
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      switch(int(Ind[poz].m_Ind[1]))
        {
         case  0: ColorGain[poz]=BuyColor;
         switch(int(Ind[poz].m_Ind[0]))
           {
            case  0: SignalSymbol[poz]="в"; ColorGain[poz]=UpColor; break;
            case  1: SignalSymbol[poz]="ж"; ColorGain[poz]=BuyColor; break;
           }
         break;
         case  1: ColorGain[poz]=SellColor;
         switch(int(Ind[poz].m_Ind[0]))
           {           
            case  0: SignalSymbol[poz]="и"; ColorGain[poz]=SellColor; break;
            case  1: SignalSymbol[poz]="в"; ColorGain[poz]=DnColor; break;
           }
         break;
        }
     }
//----
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      SetTLabel(0,sPerA[poz],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift[poz+1],sPer[poz]+": ",ColorGain[poz],sFontType,FontSize);
      SetTLabel(0,sPerB[poz],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift[poz+1],SignalSymbol[poz],ColorGain[poz],"Wingdings 3",FontSize);
     }
   SetTLabel(0,Cap,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift[0],Cap,CpColor,sFontType,FontSize);
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
