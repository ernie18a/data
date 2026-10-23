//+------------------------------------------------------------------+
//|                                  ChandelierStops_v1Trend_x10.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property description "Индикатор отображает положение осциллятора ChandelierStops_v1 с разных таймфреймов"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 0
#property indicator_buffers 0 
//---- не использовано ни одного графического построения
#property indicator_plots   0
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0          // константа для возврата терминалу команды на пересчет индикатора
#define INDTOTAL 10      // константа для количества отображаемых индикаторов
//+----------------------------------------------+
//| Описание перечисления type_font              |
//| Описание класса CFontName                    | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame0=PERIOD_H1;           // Период графика 1
input ENUM_TIMEFRAMES TimeFrame1=PERIOD_H2;           // Период графика 2
input ENUM_TIMEFRAMES TimeFrame2=PERIOD_H3;           // Период графика 3
input ENUM_TIMEFRAMES TimeFrame3=PERIOD_H4;           // Период графика 4
input ENUM_TIMEFRAMES TimeFrame4=PERIOD_H6;           // Период графика 5
input ENUM_TIMEFRAMES TimeFrame5=PERIOD_H8;           // Период графика 6
input ENUM_TIMEFRAMES TimeFrame6=PERIOD_H12;          // Период графика 7
input ENUM_TIMEFRAMES TimeFrame7=PERIOD_D1;           // Период графика 8
input ENUM_TIMEFRAMES TimeFrame8=PERIOD_W1;           // Период графика 9
input ENUM_TIMEFRAMES TimeFrame9=PERIOD_MN1;          // Период графика 10 
//---- параметры ChandelierStops_v1
input uint   Length=20;
input uint   ATRPeriod=10;
input double Kv=3;
//----
input color  CpColor=clrDarkOrchid;                   // Цвет названия индикатора
input color  UpColor=clrLime;                         // Цвет перекупленности индикатора
input color  DnColor=clrMagenta;                      // Цвет перепроданности индикатора
input color  ZrColor=clrGray;                         // Цвет без изменения
input int    FontSize=11;                             // Размер шрифта
input type_font FontType=Font14;                      // Тип шрифта
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_LOWER; // Угол расположения
input uint Y_=20;                                     // Расположение по вертикали
input uint X_=5;                                      // Расположение по горизонтали
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
//| Класс массивов                                                   |
//+------------------------------------------------------------------+  
class CIndArrow
  {
public:
   double            m_UpInd[1];
   double            m_DnInd[1];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
  };
//---- объявление массивов, которые будут в 
//---- дальнейшем использованы для получения индикаторных значений
CIndArrow Ind[INDTOTAL];
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
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
//---- получение хендлов индикаторов
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      Ind[poz].m_Handle=iCustom(Symbol(),Ind[poz].m_TimeFrame,"ChandelierStops_v1",Length,ATRPeriod,Kv,0);

      if(Ind[poz].m_Handle==INVALID_HANDLE)
        {
         Print("OnInit()(",poz,"): Не удалось получить хендл индикатора ChandelierStops_v1");
         return(false);
        }
     }
//----   
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
   min_rates_total=int(ATRPeriod+Length)+1;
//----  
   xshift=int(X_+8.3*FontSize);
   Cap="ChandelierStops_v1Trend_x10";
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         for(int poz=0; poz<=INDTOTAL; poz++) shift[10-poz]=Y_+22*poz;
         break;
        }
      //----
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
//----
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
   Deinit();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      ObjectDelete(0,sPerA[poz]);
      ObjectDelete(0,sPerB[poz]);
     }
   ObjectDelete(0,Cap);
  }
//+------------------------------------------------------------------+
//| Создание текстовой метки                                         |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
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
  }
//+------------------------------------------------------------------+
//| Переустановка текстовой метки                                    |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // идентификатор графика
               string name,             // имя объекта
               int    nwin,             // индекс окна
               ENUM_BASE_CORNER corner, // положение угла привязки
               ENUM_ANCHOR_POINT point, // положение точки привязки
               int    X,                // дистанция в пикселях по оси X от угла привязки
               int    Y,                // дистанция в пикселях по оси Y от угла привязки
               string text,             // текст
               color  Color,            // цвет текста
               string Font,             // шрифт текста
               int    Size)             // размер шрифта
  {
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
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
//--- проверка количества баров на достаточность для расчета
   for(int poz=0; poz<INDTOTAL; poz++) if(Bars(Symbol(),ePer[poz])<min_rates_total) return(RESET);
//---- копируем вновь появившиеся данные в массивы 
   for(int poz=0; poz<INDTOTAL; poz++) if(CopyBuffer(Ind[poz].m_Handle,0,1,1,Ind[poz].m_UpInd)<=0) return(RESET);
   for(int poz=0; poz<INDTOTAL; poz++) if(CopyBuffer(Ind[poz].m_Handle,1,1,1,Ind[poz].m_DnInd)<=0) return(RESET);
//----
   color ColorGain[INDTOTAL];
   ArrayInitialize(ColorGain,ZrColor);
//---- копируем вновь появившиеся данные в массивы 
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      if(Ind[poz].m_UpInd[0]) ColorGain[poz]=UpColor;
      if(Ind[poz].m_DnInd[0]) ColorGain[poz]=DnColor;
     }
//----
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      SetTLabel(0,sPerA[poz],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift[poz+1],sPer[poz]+": ",ColorGain[poz],sFontType,FontSize);
      SetTLabel(0,sPerB[poz],0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),xshift,shift[poz+1],"n",ColorGain[poz],"Wingdings",FontSize);
     }
   SetTLabel(0,Cap,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift[0],Cap,CpColor,sFontType,FontSize);
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
