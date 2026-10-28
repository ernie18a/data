//+------------------------------------------------------------------+
//|                                      StochasticTrend_x10Full.mq5 |
//|                               Copyright © 2015, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "2015, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property description "Индикатор отображает положение осциллятора Stochastic с разных таймфреймов"
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
input uint                 KPeriod1=5;
input uint                 DPeriod1=3;
input uint                 Slowing1=3;
input ENUM_MA_METHOD       MA_Method1=MODE_SMA;
input ENUM_STO_PRICE       Price_field1=STO_LOWHIGH;
input uint                 UpLevel1=70;                //уровень перезакупа 1
input uint                 DnLevel1=30;                //уровень перепроданности 1

input ENUM_TIMEFRAMES      TimeFrame2=PERIOD_H1;       //период графика 2
input uint                 KPeriod2=9;
input uint                 DPeriod2=3;
input uint                 Slowing2=3;
input ENUM_MA_METHOD       MA_Method2=MODE_SMA;
input ENUM_STO_PRICE       Price_field2=STO_LOWHIGH;
input uint                 UpLevel2=70;                //уровень перезакупа 2
input uint                 DnLevel2=30;                //уровень перепроданности 2

input ENUM_TIMEFRAMES      TimeFrame3=PERIOD_H1;       //период графика 3
input uint                 KPeriod3=13;
input uint                 DPeriod3=3;
input uint                 Slowing3=3;
input ENUM_MA_METHOD       MA_Method3=MODE_SMA;
input ENUM_STO_PRICE       Price_field3=STO_LOWHIGH;
input uint                 UpLevel3=70;                //уровень перезакупа 3
input uint                 DnLevel3=30;                //уровень перепроданности 3

input ENUM_TIMEFRAMES      TimeFrame4=PERIOD_H1;       //период графика 4
input uint                 KPeriod4=17;
input uint                 DPeriod4=3;
input uint                 Slowing4=3;
input ENUM_MA_METHOD       MA_Method4=MODE_SMA;
input ENUM_STO_PRICE       Price_field4=STO_LOWHIGH;
input uint                 UpLevel4=70;                //уровень перезакупа 4
input uint                 DnLevel4=30;                //уровень перепроданности 4

input ENUM_TIMEFRAMES      TimeFrame5=PERIOD_H1;       //период графика 5
input uint                 KPeriod5=21;
input uint                 DPeriod5=3;
input uint                 Slowing5=3;
input ENUM_MA_METHOD       MA_Method5=MODE_SMA;
input ENUM_STO_PRICE       Price_field5=STO_LOWHIGH;
input uint                 UpLevel5=70;                //уровень перезакупа 5
input uint                 DnLevel5=30;                //уровень перепроданности 5

input ENUM_TIMEFRAMES      TimeFrame6=PERIOD_H1;       //период графика 6
input uint                 KPeriod6=25;
input uint                 DPeriod6=3;
input uint                 Slowing6=3;
input ENUM_MA_METHOD       MA_Method6=MODE_SMA;
input ENUM_STO_PRICE       Price_field6=STO_LOWHIGH;
input uint                 UpLevel6=70;                //уровень перезакупа 6
input uint                 DnLevel6=30;                //уровень перепроданности 6

input ENUM_TIMEFRAMES      TimeFrame7=PERIOD_H1;       //период графика 7
input uint                 KPeriod7=29;
input uint                 DPeriod7=3;
input uint                 Slowing7=3;
input ENUM_MA_METHOD       MA_Method7=MODE_SMA;
input ENUM_STO_PRICE       Price_field7=STO_LOWHIGH;
input uint                 UpLevel7=70;                //уровень перезакупа 7
input uint                 DnLevel7=30;                //уровень перепроданности 7

input ENUM_TIMEFRAMES      TimeFrame8=PERIOD_H1;       //период графика 8
input uint                 KPeriod8=33;
input uint                 DPeriod8=3;
input uint                 Slowing8=3;
input ENUM_MA_METHOD       MA_Method8=MODE_SMA;
input ENUM_STO_PRICE       Price_field8=STO_LOWHIGH;
input uint                 UpLevel8=70;                //уровень перезакупа 8
input uint                 DnLevel8=30;                //уровень перепроданности 8

input ENUM_TIMEFRAMES      TimeFrame9=PERIOD_H1;       //период графика 9
input uint                 KPeriod9=37;
input uint                 DPeriod9=3;
input uint                 Slowing9=3;
input ENUM_MA_METHOD       MA_Method9=MODE_SMA;
input ENUM_STO_PRICE       Price_field9=STO_LOWHIGH;
input uint                 UpLevel9=70;                //уровень перезакупа 9
input uint                 DnLevel9=30;                //уровень перепроданности 9

input ENUM_TIMEFRAMES      TimeFrame10=PERIOD_H1;      //период графика 10
input uint                 KPeriod10=41;
input uint                 DPeriod10=3;
input uint                 Slowing10=3;
input ENUM_MA_METHOD       MA_Method10=MODE_SMA;
input ENUM_STO_PRICE       Price_field10=STO_LOWHIGH;
input uint                 UpLevel10=70;               //уровень перезакупа 10
input uint                 DnLevel10=30;               //уровень перепроданности 10
//----
input color  CpColor=clrDarkOrchid;                   //цвет названия индикатора
input color  UpColor=clrMediumSpringGreen;            //цвет перекупленности индикатора
input color  DnColor=clrMagenta;                      //цвет перепроданности индикатора
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
   double            m_Ind[1];
   int               m_Handle;
   ENUM_TIMEFRAMES   m_TimeFrame;
   uint              m_KPeriod;
   uint              m_DPeriod;
   uint              m_Slowing;
   ENUM_MA_METHOD    m_MA_Method;
   ENUM_STO_PRICE    m_Price_field;
   double            m_UpLevel;
   double            m_DnLevel;
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
   Ind[0].m_KPeriod=KPeriod1;
   Ind[1].m_KPeriod=KPeriod2;
   Ind[2].m_KPeriod=KPeriod3;
   Ind[3].m_KPeriod=KPeriod4;
   Ind[4].m_KPeriod=KPeriod5;
   Ind[5].m_KPeriod=KPeriod6;
   Ind[6].m_KPeriod=KPeriod7;
   Ind[7].m_KPeriod=KPeriod8;
   Ind[8].m_KPeriod=KPeriod9;
   Ind[9].m_KPeriod=KPeriod10;
//----  
   Ind[0].m_DPeriod=DPeriod1;
   Ind[1].m_DPeriod=DPeriod2;
   Ind[2].m_DPeriod=DPeriod3;
   Ind[3].m_DPeriod=DPeriod4;
   Ind[4].m_DPeriod=DPeriod5;
   Ind[5].m_DPeriod=DPeriod6;
   Ind[6].m_DPeriod=DPeriod7;
   Ind[7].m_DPeriod=DPeriod8;
   Ind[8].m_DPeriod=DPeriod9;
   Ind[9].m_DPeriod=DPeriod10;
//----  
   Ind[0].m_Slowing=Slowing1;
   Ind[1].m_Slowing=Slowing2;
   Ind[2].m_Slowing=Slowing3;
   Ind[3].m_Slowing=Slowing4;
   Ind[4].m_Slowing=Slowing5;
   Ind[5].m_Slowing=Slowing6;
   Ind[6].m_Slowing=Slowing7;
   Ind[7].m_Slowing=Slowing8;
   Ind[8].m_Slowing=Slowing9;
   Ind[9].m_Slowing=Slowing10;
//----  
   Ind[0].m_MA_Method=MA_Method1;
   Ind[1].m_MA_Method=MA_Method2;
   Ind[2].m_MA_Method=MA_Method3;
   Ind[3].m_MA_Method=MA_Method4;
   Ind[4].m_MA_Method=MA_Method5;
   Ind[5].m_MA_Method=MA_Method6;
   Ind[6].m_MA_Method=MA_Method7;
   Ind[7].m_MA_Method=MA_Method8;
   Ind[8].m_MA_Method=MA_Method9;
   Ind[9].m_MA_Method=MA_Method10;
//----  
   Ind[0].m_Price_field=Price_field1;
   Ind[1].m_Price_field=Price_field2;
   Ind[2].m_Price_field=Price_field3;
   Ind[3].m_Price_field=Price_field4;
   Ind[4].m_Price_field=Price_field5;
   Ind[5].m_Price_field=Price_field6;
   Ind[6].m_Price_field=Price_field7;
   Ind[7].m_Price_field=Price_field8;
   Ind[8].m_Price_field=Price_field9;
   Ind[9].m_Price_field=Price_field10;
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
      Ind[poz].m_Handle=iStochastic(Symbol(),Ind[poz].m_TimeFrame,Ind[poz].m_KPeriod,Ind[poz].m_DPeriod,Ind[poz].m_Slowing,Ind[poz].m_MA_Method,Ind[poz].m_Price_field);

      if(Ind[poz].m_Handle==INVALID_HANDLE)
        {
         Print("OnInit()(",poz,"): Не удалось получить хендл индикатора Stochastic",poz);
         return(false);
        }
     }
//----   
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit();
   uint max=0;
   for(int poz=0; poz<INDTOTAL; poz++)
    {
     double res=Ind[poz].m_KPeriod+Ind[poz].m_DPeriod+Ind[poz].m_Slowing;
     if(res>max) max=int(res);
    }
   min_rates_total=int(max+1);
//----  
   xshift=int(X_+8.3*FontSize);
   Cap="StochasticTrend_x10Full";
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
