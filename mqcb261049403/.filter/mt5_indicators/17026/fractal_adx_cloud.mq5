//+------------------------------------------------------------------+
//|                                            Fractal_ADX_Cloud.mq5 |
//|                              Copyright © 2008, jppoton@yahoo.com |
//|                              http://fractalfinance.blogspot.com/ |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, jppoton@yahoo.com"
#property link "http://fractalfinance.blogspot.com/"
#property description "Фрактальный ADX"
//---- номер версии индикатора
#property version   "1.02"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//---- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора облака       |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета индикатора использованы
#property indicator_color1  clrLime,clrRed
//---- отображение метки индикатора
#property indicator_label1  "ADX Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки ADX индикатора          |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета ADX линии индикатора использован синий цвет
#property indicator_color2  clrBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "ADX"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 88.0
#property indicator_level2 50.0
#property indicator_level3 12.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
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
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint e_period=30; //глубина  усреднения                    
input uint normal_speed=30;
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer0[],ExtLineBuffer1[],ExtLineBuffer2[];
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве буфера данных
double ExtLineBuffer3[],ExtPDBuffer[],ExtNDBuffer[],ExtTmpBuffer[];
double LOG_2;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,g_period_minus_1;
//+------------------------------------------------------------------+   
//| XMA BBx3 indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(e_period,normal_speed));
   g_period_minus_1=int(e_period-1);
   LOG_2=MathLog(2.0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);


//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtLineBuffer0,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- запрет на отображение значений индикатора в левом верхнем углу окна индикатора
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);

//---- превращение динамических массивов в буферы данных
   SetIndexBuffer(3,ExtLineBuffer3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtPDBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtNDBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ExtTmpBuffer,INDICATOR_CALCULATIONS);
//---- инициализации переменной для короткого имени индикатора
   string shortname="";
   StringConcatenate(shortname,"Fractal_ADX(",e_period,", ",normal_speed,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,2);
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
   for(bar=first; bar<rates_total && !IsStopped(); bar++) ExtLineBuffer3[bar]=PriceSeries(IPC,bar,open,low,high,close);
//---- Основной цикл расчёта индикатора
   if(prev_calculated>rates_total || prev_calculated<=0) first=min_rates_total; // стартовый номер для расчёта всех баров
   FRACTAL_ADX(first,high,low,close,rates_total);
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
void FRACTAL_ADX(int lastBar,const double &High[],const double &Low[],const double &Close[],int Rates_Total)
  {
   double diff,priorDiff;
   double length;
   double priceMax,priceMin;
   double fdi,trail_dim,beta,hurst;
   int    speed;
//----
   for(int index=lastBar; index<Rates_Total; index++)
     {
      priceMax=_highest(e_period,index,ExtLineBuffer3);
      priceMin=_lowest(e_period,index,ExtLineBuffer3);
      length=NULL;
      priorDiff=NULL;
      //----
      for(int kkk=0; kkk<=g_period_minus_1; kkk++)
        {
         if(priceMax-priceMin>0.0)
           {
            diff=(ExtLineBuffer3[index-kkk]-priceMin)/(priceMax-priceMin);
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
      GetADX(speed,index,High,Low,Close,Rates_Total);
     }
  }
//+------------------------------------------------------------------+
// вычисление осциллятора ADX                                        |
//+------------------------------------------------------------------+ 
void GetADX(int period,int index,const double &High[],const double &Low[],const double &Close[],int Rates_Total)
  {
//----
   if(index<period) return;

//--- get some data
   double Hi=High[index];
   double prevHi=High[index-1];
   double Lo=Low[index];
   double prevLo=Low[index-1];
   double prevCl=Close[index-1];
//--- fill main positive and main negative buffers
   double dTmpP=Hi-prevHi;
   double dTmpN=prevLo-Lo;
   dTmpP=MathMax(0,dTmpP);
   dTmpN=MathMax(0,dTmpN);
   if(dTmpP>dTmpN) dTmpN=NULL;
   else
     {
      if(dTmpP<dTmpN) dTmpP=NULL;
      else
        {
         dTmpP=NULL;
         dTmpN=NULL;
        }
     }
//--- define TR
   double tr=MathMax(MathMax(MathAbs(Hi-Lo),MathAbs(Hi-prevCl)),MathAbs(Lo-prevCl));
   //---
      if(tr)
        {
         ExtPDBuffer[index]=100.0*dTmpP/tr;
         ExtNDBuffer[index]=100.0*dTmpN/tr;
        }
      else
        {
         ExtPDBuffer[index]=NULL;
         ExtNDBuffer[index]=NULL;
        }
      //--- fill smoothed positive and negative buffers
      ExtLineBuffer1[index]=GetEMA(period,index,ExtPDBuffer);
      ExtLineBuffer2[index]=GetEMA(period,index,ExtNDBuffer);
      //--- fill ADXTmp buffer
      double dTmp=ExtLineBuffer1[index]+ExtLineBuffer2[index];
      if(dTmp) dTmp=100.0*MathAbs((ExtLineBuffer1[index]-ExtLineBuffer2[index])/dTmp);
      else dTmp=0.0;
      ExtTmpBuffer[index]=dTmp;
      //--- fill smoothed ADX buffer
      ExtLineBuffer0[index]=GetEMA(period,index,ExtTmpBuffer);
//----
  }
//+------------------------------------------------------------------+
// вычисление EMA                                                    |
//+------------------------------------------------------------------+ 
double GetEMA(int period,int index,double &inputData[])
  {
//----
   double EMA=inputData[index-period];
   double SmoothFactor=2.0/(1.0+period);
   for(int iii=period-1; iii>=0; iii--) EMA=inputData[MathMax(index-iii,0)]*SmoothFactor+EMA*(1.0-SmoothFactor);
//----
   return(EMA);
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
double _highest(int n,int index,const double &inputData[])
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
double _lowest(int n,int index,const double &inputData[])
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
