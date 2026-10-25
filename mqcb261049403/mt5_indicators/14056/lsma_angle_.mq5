//+------------------------------------------------------------------+
//|                                                  LSMA_Angle_.mq5 |
//|                                                           MrPip  |
//|                                                                  |
//| You can use this indicator to measure when the LSMA angle is     |
//| "near zero". AngleTreshold determines when the angle for the     |
//| LSMA is "about zero": This is when the value is between          |
//| [-AngleTreshold, AngleTreshold] (or when the histogram is red).  |
//|   LSMAPeriod: LSMA period                                        |
//|   AngleTreshold: The angle value is "about zero" when it is      |
//|     between the values [-AngleTreshold, AngleTreshold].          |      
//|   StartLSMAShift: The starting point to calculate the            |   
//|     angle. This is a shift value to the left from the            |
//|     observation point. Should be StartEMAShift > EndEMAShift.    | 
//|   EndLSMAShift: The ending point to calculate the                |
//|     angle. This is a shift value to the left from the            | 
//|     observation point. Should be StartEMAShift > EndEMAShift.    |
//|                                                                  |
//|   Modified by MrPip from EMAAngle by jpkfox                      |
//|       Red for down                                               |
//|       Yellow for near zero                                       |
//|       Green for up                                               |   
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Robert L. Hill aka MrPip"
#property link "" 
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//|  Параметры отрисовки индикатора   |
//+-----------------------------------+
//--- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- в качестве цветов пятицветной гистограммы использованы
#property indicator_color1 clrMagenta,clrViolet,clrGray,clrDodgerBlue,clrBlue
//--- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1 2
//--- отображение метки индикатора
#property indicator_label1 "LSMA_Angle"
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum ENUM_PRICE_TYPE //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint LSMAPeriod=25;
input int  AngleTreshold=15.0; // Порог срабатывания
input uint StartLSMAShift=4;
input uint EndLSMAShift=0;
input ENUM_PRICE_TYPE IPC=PRICE_CLOSE_;//ценовая константа
//+-----------------------------------+
double mFactor,dFactor,ShiftDif;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//+------------------------------------------------------------------+
//|  LSMA - Least Squares Moving Average function calculation        |
//+------------------------------------------------------------------+
double LSMA(int Rperiod,const double &Open[],const double &Low[],const double &High[],const double &Close[],int shift)
  {
//---
   int iii;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;
//---
   length=Rperiod;
//--- 
   sum=0;
   for(iii=length; iii>=1; iii--)
     {
      lengthvar = length+1;
      lengthvar/= 3;
      tmp=(iii-lengthvar)*PriceSeries(IPC,length-iii+shift,Open,Low,High,Close);
      sum+=tmp;
     }
   wt=sum*6/(length*(length+1));
//---
   return(wt);
  }
//+------------------------------------------------------------------+    
//| LSMA_Angle indicator initialization function                     | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчета данных
   min_rates_total=int(MathMax(LSMAPeriod+StartLSMAShift,LSMAPeriod+EndLSMAShift));
   dFactor = 2*3.14159/180.0;
   mFactor = 100000.0;
   string Sym = StringSubstr(Symbol(),3,3);
   if (Sym == "JPY") mFactor = 1000.0;
   ShiftDif = StartLSMAShift-EndLSMAShift;
   mFactor /= ShiftDif; 
//---
   if(EndLSMAShift>=StartLSMAShift)
     {
      Print("Error: EndLSMAShift >= StartLSMAShift");
      return(INIT_FAILED);
     }
//--- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);
//--- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"LSMA_Angle");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- количество  горизонтальных уровней индикатора 9   
   IndicatorSetInteger(INDICATOR_LEVELS,2);
//--- значения горизонтальных уровней индикатора   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,+AngleTreshold);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-AngleTreshold);
//--- в качестве цветов линий горизонтальных уровней использованы серый и розовый цвета  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrTeal);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrTeal);
//--- в линии горизонтального уровня использован короткий штрих-пунктир  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| LSMA_Angle iteration function                                    | 
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
   if(rates_total<min_rates_total) return(0);
//--- объявления локальных переменных 
   int limit,bar,clr;
   double fEndMA,fStartMA,fAngle;
//--- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }   
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      fEndMA=LSMA(LSMAPeriod,open,low,high,close,bar+EndLSMAShift);
      fStartMA=LSMA(LSMAPeriod,open,low,high,close,bar+StartLSMAShift);
      fAngle=mFactor*(fEndMA-fStartMA)/2;
      IndBuffer[bar]=fAngle;
     }
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//--- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=2;
      if(IndBuffer[bar]>AngleTreshold)
        {
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=4;
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=3;
        }
      if(IndBuffer[bar]<-AngleTreshold)
        {
         if(IndBuffer[bar]<IndBuffer[bar+1]) clr=0;
         if(IndBuffer[bar]>IndBuffer[bar+1]) clr=1;
        }
      ColorIndBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 uint applied_price,// Ценовая константа
 uint   bar,// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 const double &Open[],
 const double &Low[],
 const double &High[],
 const double &Close[]
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);

      //----                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //----                                
      case 10:
        {
         if(Close[bar]>Open[bar])return(High[bar]);
         else
           {
            if(Close[bar]<Open[bar])
               return(Low[bar]);
            else return(Close[bar]);
           }
        }
      //----         
      case 11:
        {
         if(Close[bar]>Open[bar])return((High[bar]+Close[bar])/2.0);
         else
           {
            if(Close[bar]<Open[bar])
               return((Low[bar]+Close[bar])/2.0);
            else return(Close[bar]);
           }
         break;
        }
      //----         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //----
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
