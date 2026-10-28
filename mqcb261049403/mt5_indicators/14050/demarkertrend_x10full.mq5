//+------------------------------------------------------------------+
//|                                        DeMarkerTrend_x10Full.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2015, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property description "Индикатор отображает положение осциллятора DeMarker с разных таймфреймов"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window
//---- количество индикаторных буферов 0
#property indicator_buffers 0 
//---- не использовано ни одного графического построения
#property indicator_plots   0
//+-----------------------------------+
//|  объявление констант              |
//+-----------------------------------+
#define RESET 0          // Константа для возврата терминалу команды на пересчёт индикатора
#define INDTOTAL 10      // Константа для количества отображаемых индикаторов
//+----------------------------------------------+
// Описание перечисления type_font               |
// Описание класса CFontName                     | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_TIMEFRAMES      TimeFrame1=PERIOD_H1;       //период графика 1
input uint                 DeMarkerPeriod1=7;          //период DeMarker 1
input double               UpLevel1=0.7;               //уровень перезакупа 1
input double               DnLevel1=0.3;               //уровень перепроданности 1

input ENUM_TIMEFRAMES      TimeFrame2=PERIOD_H1;       //период графика 2
input uint                 DeMarkerPeriod2=11;         //период DeMarker 2
input double               UpLevel2=0.7;               //уровень перезакупа 2
input double               DnLevel2=0.3;               //уровень перепроданности 2

input ENUM_TIMEFRAMES      TimeFrame3=PERIOD_H1;       //период графика 3
input uint                 DeMarkerPeriod3=15;         //период DeMarker 3
input double               UpLevel3=0.7;               //уровень перезакупа 3
input double               DnLevel3=0.3;               //уровень перепроданности 3

input ENUM_TIMEFRAMES      TimeFrame4=PERIOD_H1;       //период графика 4
input uint                 DeMarkerPeriod4=19;         //период DeMarker 4
input double               UpLevel4=0.7;               //уровень перезакупа 4
input double               DnLevel4=0.3;               //уровень перепроданности 4

input ENUM_TIMEFRAMES      TimeFrame5=PERIOD_H1;       //период графика 5
input uint                 DeMarkerPeriod5=23;         //период DeMarker 5
input double               UpLevel5=0.7;               //уровень перезакупа 5
input double               DnLevel5=0.3;               //уровень перепроданности 5

input ENUM_TIMEFRAMES      TimeFrame6=PERIOD_H1;       //период графика 6
input uint                 DeMarkerPeriod6=27;         //период DeMarker 6
input double               UpLevel6=0.7;               //уровень перезакупа 6
input double               DnLevel6=0.3;               //уровень перепроданности 6

input ENUM_TIMEFRAMES      TimeFrame7=PERIOD_H1;       //период графика 7
input uint                 DeMarkerPeriod7=31;         //период DeMarker 7
input double               UpLevel7=0.7;               //уровень перезакупа 7
input double               DnLevel7=0.3;               //уровень перепроданности 7

input ENUM_TIMEFRAMES      TimeFrame8=PERIOD_H1;       //период графика 8
input uint                 DeMarkerPeriod8=35;         //период DeMarker 8
input double               UpLevel8=0.7;               //уровень перезакупа 8
input double               DnLevel8=0.3;               //уровень перепроданности 8

input ENUM_TIMEFRAMES      TimeFrame9=PERIOD_H1;       //период графика 9
input uint                 DeMarkerPeriod9=39;         //период DeMarker 9
input double               UpLevel9=0.7;               //уровень перезакупа 9
input double               DnLevel9=0.3;               //уровень перепроданности 9

input ENUM_TIMEFRAMES      TimeFrame10=PERIOD_H1;      //период графика 10
input uint                 DeMarkerPeriod10=43;        //период DeMarker 10
input double               UpLevel10=70;               //уровень перезакупа 10
input double               DnLevel10=30;               //уровень перепроданности 10
//----
input color  CpColor=clrDarkOrchid;                   //цвет названия индикатора
input color  UpColor=clrDodgerBlue;                   //цвет перекупленности индикатора
input color  DnColor=clrRed;                          //цвет перепроданности индикатора
input color  ZrColor=clrGray;                         //цвет без изменения
input int    FontSize=11;                             //размер шрифта
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
   double               m_Ind[1];
   int                  m_Handle;
   ENUM_TIMEFRAMES      m_TimeFrame;
   uint                 m_Period;
   double               m_UpLevel;
   double               m_DnLevel;
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
   ePer[0]=TimeFrame1;
   ePer[1]=TimeFrame2;
   ePer[2]=TimeFrame3;
   ePer[3]=TimeFrame4;
   ePer[4]=TimeFrame5;
   ePer[5]=TimeFrame6;
   ePer[6]=TimeFrame7;
   ePer[7]=TimeFrame8;
   ePer[8]=TimeFrame9;
   ePer[9]=TimeFrame10;
   for(int poz=0; poz<INDTOTAL; poz++) Ind[poz].m_TimeFrame=ePer[poz];
   //----  
   Ind[0].m_Period=DeMarkerPeriod1;
   Ind[1].m_Period=DeMarkerPeriod2;
   Ind[2].m_Period=DeMarkerPeriod3;
   Ind[3].m_Period=DeMarkerPeriod4;
   Ind[4].m_Period=DeMarkerPeriod5;
   Ind[5].m_Period=DeMarkerPeriod6;
   Ind[6].m_Period=DeMarkerPeriod7;
   Ind[7].m_Period=DeMarkerPeriod8;
   Ind[8].m_Period=DeMarkerPeriod9;
   Ind[9].m_Period=DeMarkerPeriod10;
   //----  
   Ind[0].m_UpLevel=UpLevel1;
   Ind[1].m_UpLevel=UpLevel2;
   Ind[2].m_UpLevel=UpLevel3;
   Ind[3].m_UpLevel=UpLevel4;
   Ind[4].m_UpLevel=UpLevel5;
   Ind[5].m_UpLevel=UpLevel6;
   Ind[6].m_UpLevel=UpLevel7;
   Ind[7].m_UpLevel=UpLevel8;
   Ind[8].m_UpLevel=UpLevel9;
   Ind[9].m_UpLevel=UpLevel10;
   //----  
   Ind[0].m_DnLevel=DnLevel1;
   Ind[1].m_DnLevel=DnLevel2;
   Ind[2].m_DnLevel=DnLevel3;
   Ind[3].m_DnLevel=DnLevel4;
   Ind[4].m_DnLevel=DnLevel5;
   Ind[5].m_DnLevel=DnLevel6;
   Ind[6].m_DnLevel=DnLevel7;
   Ind[7].m_DnLevel=DnLevel8;
   Ind[8].m_DnLevel=DnLevel9;
   Ind[9].m_DnLevel=DnLevel10;
//---- Получение хендлов индикаторов
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      Ind[poz].m_Handle=iDeMarker(Symbol(),Ind[poz].m_TimeFrame,Ind[poz].m_Period);

      if(Ind[poz].m_Handle==INVALID_HANDLE)
        {
         Print("OnInit()(",poz,"): Не удалось получить хендл индикатора DeMarker",poz);
         return(false);
        }
     }
//----   
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
   uint max=0;
   for(int poz=0; poz<INDTOTAL; poz++) if(Ind[poz].m_Period>max) max=Ind[poz].m_Period;
   min_rates_total=int(max+1);
//----  
   xshift=int(X_+8.3*FontSize);
   Cap="DeMarkerTrend_x10Full";
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
      sPer[poz]=string(poz+1)+" "+GetStringTimeframe(ePer[poz]);
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
ENUM_BASE_CORNER corner, // положение угла привязки
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
   for(int poz=0; poz<INDTOTAL; poz++) if(Bars(Symbol(),ePer[poz])<min_rates_total) return(RESET);

//---- копируем вновь появившиеся данные в массивы 
   for(int poz=0; poz<INDTOTAL; poz++) if(CopyBuffer(Ind[poz].m_Handle,MAIN_LINE,1,1,Ind[poz].m_Ind)<=0) return(RESET);
//----
   color ColorGain[INDTOTAL];
   ArrayInitialize(ColorGain,ZrColor);
//---- копируем вновь появившиеся данные в массивы 
   for(int poz=0; poz<INDTOTAL; poz++)
     {
      if(Ind[poz].m_Ind[0]>Ind[poz].m_UpLevel) ColorGain[poz]=UpColor;
      if(Ind[poz].m_Ind[0]<Ind[poz].m_DnLevel) ColorGain[poz]=DnColor;
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

   