//+------------------------------------------------------------------+
//|                                                  Fractal_MFI.mq5 |
//|                              Copyright © 2008, jppoton@yahoo.com |
//|                              http://fractalfinance.blogspot.com/ |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, jppoton@yahoo.com"
#property link "http://fractalfinance.blogspot.com/"
#property description "Фрактальный MFI"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+--------------------------------------------+
//|  Параметры отрисовки индикатора            |
//+--------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован MediumOrchid цвет
#property indicator_color1 clrMediumOrchid
//---- линия индикатора - сплошная
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Fractal_MFI"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 30.0
#property indicator_levelcolor clrLime
#property indicator_levelstyle STYLE_DASHDOTDOT
//+--------------------------------------------+
//|  объявление перечислений                   |
//+--------------------------------------------+
enum ENUM_APPLIED_PRICE_ //Тип константы
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
//+--------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА              |
//+--------------------------------------------+
input uint e_period=30; //глубина  усреднения                    
input uint normal_speed=30;
input ENUM_APPLIED_PRICE_ IPC=PRICE_TYPICAL_;//ценовая константа
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  // объём 
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+--------------------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer0[];
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве буфера данных
double ExtLineBuffer1[];
double LOG_2;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,g_period_minus_1;
//+------------------------------------------------------------------+   
//| XMA BBx3 indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(e_period,normal_speed))+1;
   g_period_minus_1=int(e_period-1);
   LOG_2=MathLog(2.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_CALCULATIONS);
//---- инициализации переменной для короткого имени индикатора
   string shortname="";
   StringConcatenate(shortname,"Fractal_MFI(",e_period,", ",normal_speed,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=0; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Загрузка данных для расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++) ExtLineBuffer1[bar]=PriceSeries(IPC,bar,open,low,high,close);
//---- Основной цикл расчёта индикатора
   if(prev_calculated>rates_total || prev_calculated<=0) first=min_rates_total; // стартовый номер для расчёта всех баров
   FRACTAL_MFI(first,tick_volume,volume,rates_total);
//----     
   return(rates_total);
  }
//+================================================================================================================+
//+=== FUNCTION : _computeLastNbBars                                                                            ===+
//+===                                                                                                          ===+
//+===                                                                                                          ===+
//+=== This callback is fired by metatrader for each tick                                                       ===+
//+===                                                                                                          ===+
//+=== In :                                                                                                     ===+
//+===    - lastBars : these "n" last bars must be repainted                                                    ===+
//+===                                                                                                          ===+
//+================================================================================================================+
//+------------------------------------------------------------------+
//| FUNCTION : FRACTAL_MA                                            |
//| Compute the Fractal Bands for input data                         |
//| In :                                                             |
//|    - lastBars : these "n" last bars are considered for           |
//|      calculating the fractal dimension                           |
//| For further theoretical explanations, see my blog:               |  
//|    http://fractalfinance.blogspot.com/                           |
//+------------------------------------------------------------------+
void FRACTAL_MFI(int lastBar,const long &Tick_Volume[],const long &Volume[],int Rates_Total)
  {
   double diff,priorDiff;
   double length;
   double priceMax,priceMin;
   double fdi,trail_dim,beta,hurst;
   int    speed;
//----
   for(int index=lastBar; index<Rates_Total; index++)
     {
      priceMax=_highest(e_period,index,ExtLineBuffer1);
      priceMin=_lowest(e_period,index,ExtLineBuffer1);
      length=NULL;
      priorDiff=NULL;
      //----
      for(int kkk=0; kkk<=g_period_minus_1; kkk++)
        {
         if(priceMax-priceMin>0.0)
           {
            diff=(ExtLineBuffer1[index-kkk]-priceMin)/(priceMax-priceMin);
            if(kkk>0)
              {
               length+=MathSqrt(MathPow(diff-priorDiff,2.0)+(1.0/MathPow(e_period,2.0)));
              }
            priorDiff=diff;
           }
        }
      if(length>0.0)
        {
         fdi=1.0+(MathLog(length)+LOG_2)/MathLog(2*g_period_minus_1);
        }
      else
        {
/*
         ** The FDI algorithm suggests in this case a zero value.
         ** I prefer to use the previous FDI value.
         */
         fdi=NULL;
        }
      hurst=2-fdi; // The Hurst exponent
      trail_dim=1/hurst; // This is the trail dimension, the inverse of the Hurst-Holder exponent 
      beta=trail_dim/2;
      speed=int(MathRound(normal_speed*beta));
      ExtLineBuffer0[index]=GetMFI(speed,index,ExtLineBuffer1,Tick_Volume,Volume);
     }
  }
//+------------------------------------------------------------------+
//| FUNCTION : _highest                                              |
//| Search for the highest value in an array data                    |
//| In :                                                             |
//|    - n : find the highest on these n data                        |
//|    - index : begin to search for from this index                 |
//|    - inputData : data array on which the searching for is done   |
//|                                                                  |
//| Return : the highest value                                       |                                             
//+------------------------------------------------------------------+
double _highest(int n,int index,double &inputData[])
  {
   double highest=0.0;
//----
   for(int i=index-n+1; i<=index; i++)
     {
      if(inputData[i]>highest) highest=inputData[i];
     }
   return( highest );
  }
//+------------------------------------------------------------------+
//| FUNCTION : _lowest                                               |
//| Search for the lowest value in an array data                     |
//| In :                                                             |
//|    - n : find the hihest on these n data                         |
//|    - index : begin to search for from this index                 |
//|    - inputData : data array on which the searching for is done   |
//|                                                                  |
//| Return : the highest value                                       |
//+------------------------------------------------------------------+
double _lowest(int n,int index,double &inputData[])
  {
   double lowest=9999999999.0;
//----
   for(int i=index-n+1; i<=index; i++)
     {
      if(inputData[i]<lowest) lowest=inputData[i];
     }
   return( lowest );
  }
//+------------------------------------------------------------------+
// вычисление осциллятора MFI                                        |
//+------------------------------------------------------------------+ 
double GetMFI(int period,int index,double &InputData[],const long &Tick_Volume[],const long &Volume[])
  {
//----
   double dPositiveMF=NULL;
   double dNegativeMF=NULL;
   double dCurrentTP=InputData[index];
   for(int kkk=1; kkk<=period; kkk++)
     {
      int poz=index-kkk;
      double dPreviousTP=InputData[poz];
      long Vol;
      if(VolumeType==VOLUME_TICK) Vol=long(Tick_Volume[poz-1]);
      else Vol=long(Volume[poz-1]);
      if(dCurrentTP>dPreviousTP) dPositiveMF+=Vol*dCurrentTP;
      if(dCurrentTP<dPreviousTP) dNegativeMF+=Vol*dCurrentTP;
      dCurrentTP=dPreviousTP;
     }
   double MFI;
   if(dNegativeMF) MFI=100.0-100.0/(1+dPositiveMF/dNegativeMF);
   else MFI=100.0;
//----
   return(MFI);
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
