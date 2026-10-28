//+---------------------------------------------------------------------+
//|                                            RegressionPolynomial.mq5 |
//|                                     Copyright © 2012, Ivan Kornilov |
//|                                     excelf@gmail.com, skype: excelf |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, paladin80"
#property link "forevex@mail.ru"
//--- номер версии индикатора
#property version   "1.02"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора 1            |
//+----------------------------------------------+
//--- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//--- в качестве цветов индикатора использованы
#property indicator_color1  clrAquamarine,clrViolet
//--- отображение метки индикатора
#property indicator_label1  "RegressionPolynomial"
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  объявление перечислений                     |
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
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint period=55;                     // Период мувинга
input Smooth_Method XMA_Method=MODE_SMA_; // Метод усреднения сигнальной линии
input uint XLength=8;                     // Глубина сглаживания сигнальной линии                   
input int XPhase=15;                      // Параметр сглаживания сигнальной линии
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_TYPICAL;   // Ценовая константа
input uint degree=1;                      // Алгоритм расчёта
input int Shift=0;                        // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   // Сдвиг индикатора по вертикали в пунктах
//+-----------------------------------+
//--- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
//--- объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
//--- объявление целочисленных переменных начала отсчёта данных
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| RegressionPolynomial indicator initialization function           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_=int(period);
   min_rates_total=min_rates_+GetStartBars(XMA_Method,XLength,XPhase);
//--- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength",XLength);
   XMA1.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//--- инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"RegressionPolynomial(",XLength,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| RegressionPolynomial iteration function                          | 
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
//--- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);
//--- объявление переменных с плавающей точкой  
   double price,sma,lwma;
//--- объявление целочисленных переменных и получение уже посчитанных баров
   int first,bar;
   static CXMA XMA2,XMA3;
//--- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      if(degree!=1 && degree!=2) first=min_rates_; // стартовый номер для расчёта всех баров
      else first=0;
      sma=XMA2.XMASeries(0,prev_calculated,rates_total,MODE_SMA_,0,period,0,0,false);
      lwma=XMA3.XMASeries(0,prev_calculated,rates_total,MODE_LWMA_,0,period,0,0,false);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров
//--- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      if(degree==1)
        {
         price=PriceSeries(IPC,bar,open,low,high,close);
         sma=XMA2.XMASeries(0,prev_calculated,rates_total,MODE_SMA_,0,period,price,bar,false);
         lwma=XMA3.XMASeries(0,prev_calculated,rates_total,MODE_LWMA_,0,period,price,bar,false);
         UpBuffer[bar]=regression_LRMA(sma,lwma);
        }
      else if(degree==2)
        {
         price=PriceSeries(IPC,bar,open,low,high,close);
         sma=XMA2.XMASeries(0,prev_calculated,rates_total,MODE_SMA_,0,period,price,bar,false);
         lwma=XMA3.XMASeries(0,prev_calculated,rates_total,MODE_LWMA_,0,period,price,bar,false);
         if(bar<min_rates_) continue;
         UpBuffer[bar]=regression_QRMA(sma,lwma,period,bar,IPC,open,low,high,close);
        }
      else UpBuffer[bar]=regression_regressionPolynomial(bar,period,degree,IPC,open,low,high,close);

      DnBuffer[bar]=XMA1.XMASeries(min_rates_,prev_calculated,rates_total,XMA_Method,XPhase,XLength,UpBuffer[bar],bar,false)+dPriceShift;
      UpBuffer[bar]+=dPriceShift;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| regression_LRMA()                                                |
//+------------------------------------------------------------------+
double regression_LRMA(double Sma,double Lwma) {return(3*Sma-2*Lwma);}
//+------------------------------------------------------------------+
//| regression_QRMA()                                                |
//+------------------------------------------------------------------+
double regression_QRMA(double Sma,
                       double Lwma,
                       int len,
                       int shift,int price,
                       const double &Open[],
                       const double &Low[],
                       const double &High[],
                       const double &Close[])
  {
//---
   double qwma=ma_qwma(len,shift,price,Open,Low,High,Close);
   double value=3.0*Sma+qwma*(10-15/(len+2))-Lwma*(12-15/(len+2));
//---
   return(value);
  }
//+------------------------------------------------------------------+
//| ma_qwma()                                                        |
//+------------------------------------------------------------------+
double ma_qwma(int len,
               int shift,
               int price,
               const double &Open[],
               const double &Low[],
               const double &High[],
               const double &Close[])
  {
//---
   double sum=0;
   int j,i;
   for(j=shift,i=1; j>shift-len; j--,i++) sum+=PriceSeries(price,j,Open,Low,High,Close)*MathPow(len-i+1,2);
   double value=6.0/(len *(len+1) *(2*len+1));
//---
   return(value*sum);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double regression_regressionPolynomial(int shift,int len,
                                       int fdegree,int price,
                                       const double &Open[],
                                       const double &Low[],const double &High[],
                                       const double &Close[])
  {
//---
   double a[10][10];
   double b[10];
   double x[10];
   double sx[20];
   int n=0;
   int i;
   int k;
   double t;
   int degree1;
   ArrayInitialize(a,0.0);
   ArrayInitialize(b,0.0);

   sx[1]=len+1;
   degree1=fdegree+1;
   for(i=1; i<=degree1*2-2; i++)
     {
      sx[i+1]=0;
      for(n=0; n<=len; n++) sx[i+1]+=MathPow(n,i);
     }
   for(i=1; i<=degree1; i++)
     {
      b[i]=0;
      for(n=0; n<=len; n++)
        {
         if(i==1) b[i]+=PriceSeries(price,shift-n,Open,Low,High,Close);
         else b[i]+=PriceSeries(price,shift-n,Open,Low,High,Close)*MathPow(n,i-1);
        }
     }

   for(int j=1; j<=degree1; j++)
     {
      for(i=1; i<=degree1; i++)
        {
         k=i+j-1;
         a[i][j]=sx[k];
        }
     }

   for(k=1; k<=degree1-1; k++)
     {
      int l=0;
      double mm=0;
      for(i=k; i<=degree1; i++)
        {
         if(MathAbs(a[i][k])>mm)
           {
            mm= MathAbs(a[i][k]);
            l = i;
           }
        }
      if(!l) return(0);

      if(l!=k)
        {
         for(int j=1; j<=degree1; j++)
           {
            t=a[k,j];
            a[k][j] = a[l][j];
            a[l][j] = t;
           }
         t=b[k];
         b[k] = b[l];
         b[l] = t;
        }
      double div=0;
      for(i=k+1; i<=degree1; i++)
        {
         div=a[i][k]/a[k][k];
         for(int j=1; j<=degree1; j++)
           {
            if(j==k) a[i][j]=0;
            else a[i][j]=a[i][j]-div*a[k][j];
           }
         b[i]=b[i]-div*b[k];
        }
     }

   x[degree1]=b[degree1]/a[degree1][degree1];
   for(i=fdegree; i>=1; i--)
     {
      t=0;
      for(int j=1; j<=degree1-i; j++)
        {
         t=t+a[i][i+j]*x[i+j];
         x[i]=(1/a[i][i])*(b[i]-t);
        }
     }

   double value=x[1];
   for(i=1; k<=fdegree; i++) value+=x[i+1]*MathPow(n,i);
//---
   return(value);
  }
//+------------------------------------------------------------------+
