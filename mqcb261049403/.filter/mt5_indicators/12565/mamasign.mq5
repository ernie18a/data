//+------------------------------------------------------------------+
//|                                                     MAMASign.mq5 |
//|              MQL5 Code:     Copyright © 2015,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.10"
//--- отрисовка индикатора в основном окне
#property indicator_chart_window
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0    // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DeepPink цвет
#property indicator_color1  clrDeepPink
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "LeadingSign Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован Blue цвет
#property indicator_color2  clrBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "LeadingSign Buy"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double FastLimit = 0.5;
input double SlowLimit = 0.05;
input Applied_price_ IPC=PRICE_CLOSE_;// Ценовая константа
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int               ATR_Handle;
//--- объявление целочисленных переменных начала отсчета данных
int               min_rates_total;
//+------------------------------------------------------------------+
//| CountVelue() function                                            |
//+------------------------------------------------------------------+
double CountVelue(double  &Array1[],double  &Array2[])
  {
//---
   double Resalt=
                 (0.0962*Array1[0]
                 +0.5769*Array1[2]
                 -0.5769*Array1[4]
                 -0.0962*Array1[6])
                 *(0.075*Array2[1]+0.54);
//---
   return(Resalt);
  }
//+------------------------------------------------------------------+
//| ReCountArray() function                                          |
//+------------------------------------------------------------------+
void ReCountArray(double  &Array[])
  {
//---
   Array[6]=Array[5];
   Array[5]=Array[4];
   Array[4]=Array[3];
   Array[3]=Array[2];
   Array[2]=Array[1];
   Array[1]=Array[0];
//---
   return;
  }
//+------------------------------------------------------------------+
//| SmoothVelue() function                                           |
//+------------------------------------------------------------------+
double SmoothVelue(double  &Array[])
  {
//---
   return(0.2*Array[0]+0.8*Array[1]);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,7+1));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,171);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,171);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"MAMASign(",FastLimit,", ",SlowLimit,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- введение переменных памяти  
   static double smooth[7],detrender[7],Q1[7],I1[7],I2[7];
   static double Q2[7],jI[7],jQ[7],Re[7],Im[7],period[7],Phase[7];
//--- объявления локальных переменных 
   int first,bar;
   double DeltaPhase,alpha,MAMA,FAMA,ATR[1];
   static double MAMA_,FAMA_;
//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated==0) // проверка на первый старт расчёта индикатора
     {
      first=min_rates_total; // стартовый номер для расчёта всех баров
      //---
      ArrayInitialize(smooth,0.0);
      ArrayInitialize(detrender,0.0);
      ArrayInitialize(period,0.0);
      ArrayInitialize(Phase,0.0);
      ArrayInitialize(Q1,0.0);
      ArrayInitialize(I1,0.0);
      ArrayInitialize(I2,0.0);
      ArrayInitialize(Q2,0.0);
      ArrayInitialize(jI,0.0);
      ArrayInitialize(jQ,0.0);
      ArrayInitialize(Re,0.0);
      ArrayInitialize(Im,0.0);
      //---
      MAMA_=PriceSeries(IPC,first-1,open,low,high,close);
      FAMA_=PriceSeries(IPC,first-1,open,low,high,close);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//---
   MAMA=MAMA_;
   FAMA=FAMA_;
//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      smooth[0]=(4*PriceSeries(IPC,bar,open,low,high,close)
                 +3*PriceSeries(IPC,bar-1,open,low,high,close)
                 +2*PriceSeries(IPC,bar-2,open,low,high,close)
                 +1*PriceSeries(IPC,bar-3,open,low,high,close))/10.0;
      //---
      detrender[0]=CountVelue(smooth,period);
      Q1[0] = CountVelue(detrender,period);
      I1[0] = detrender[3];
      jI[0] = CountVelue(I1, I1);
      jQ[0] = CountVelue(Q1, Q1);
      I2[0] = I1[0] - jQ[0];
      Q2[0] = Q1[0] + jI[0];
      I2[0] = SmoothVelue(I2);
      Q2[0] = SmoothVelue(Q2);
      Re[0] = I2[0]*I2[1] + Q2[0]*Q2[1];
      Im[0] = I2[0]*Q2[1] - Q2[0]*I2[1];
      Re[0] = SmoothVelue(Re);
      Im[0] = SmoothVelue(Im);
      //---
      if(Im[0] && Re[0])
        {
         double res=MathArctan(Im[0]/Re[0]);
         if(res) period[0]=6.285714/res;
         else period[0]=6.285714;
        }
      else period[0]=6.285714;
      //---
      if(period[0]>1.50*period[1]) period[0]=1.50*period[1];
      if(period[0]<0.67*period[1]) period[0]=0.67*period[1];
      if(period[0]<6.00) period[0]=6.00;
      if(period[0]>50.0) period[0]=50.0;
      //---
      period[0]=0.2*period[0]+0.8*period[1];
      //---
      if(I1[0]) Phase[0]=57.27272987*MathArctan(Q1[0]/I1[0]);
      else Phase[0]=57.27272987;
      //---
      DeltaPhase=Phase[1]-Phase[0];
      if(DeltaPhase<1) DeltaPhase=1.0;
      //---
      alpha=FastLimit/DeltaPhase;
      if(alpha<SlowLimit)alpha=SlowLimit;
      //---
      MAMA=alpha*PriceSeries(IPC,bar,open,low,high,close)+(1.0-alpha)*MAMA_;
      FAMA=0.5*alpha*MAMA+(1.0-0.5*alpha)*FAMA_;
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(FAMA_>MAMA_ && FAMA<MAMA)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(FAMA_<MAMA_ && FAMA>MAMA)
        {
         //--- копируем вновь появившиеся данные в массив ATR[]
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar<rates_total-1)
        {
         ReCountArray(smooth);
         ReCountArray(detrender);
         ReCountArray(period);
         ReCountArray(Phase);
         ReCountArray(Q1);
         ReCountArray(I1);
         ReCountArray(I2);
         ReCountArray(Q2);
         ReCountArray(jI);
         ReCountArray(jQ);
         ReCountArray(Re);
         ReCountArray(Im);
         MAMA_=MAMA;
         FAMA_=FAMA;
        }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,    // Ценовая константа
                   uint   bar,            // Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//---
   switch(applied_price)
     {
      //--- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(Close[bar]);
      case  PRICE_OPEN: return(Open [bar]);
      case  PRICE_HIGH: return(High [bar]);
      case  PRICE_LOW: return(Low[bar]);
      case  PRICE_MEDIAN: return((High[bar]+Low[bar])/2.0);
      case  PRICE_TYPICAL: return((Close[bar]+High[bar]+Low[bar])/3.0);
      case  PRICE_WEIGHTED: return((2*Close[bar]+High[bar]+Low[bar])/4.0);
      //---                            
      case  8: return((Open[bar] + Close[bar])/2.0);
      case  9: return((Open[bar] + Close[bar] + High[bar] + Low[bar])/4.0);
      //---                                
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
      //---         
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
      //---         
      case 12:
        {
         double res=High[bar]+Low[bar]+Close[bar];
         if(Close[bar]<Open[bar]) res=(res+Low[bar])/2;
         if(Close[bar]>Open[bar]) res=(res+High[bar])/2;
         if(Close[bar]==Open[bar]) res=(res+Close[bar])/2;
         return(((res-Low[bar])+(res-High[bar]))/2);
        }
      //---
      default: return(Close[bar]);
     }
  }
//+------------------------------------------------------------------+
