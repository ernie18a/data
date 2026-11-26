//+------------------------------------------------------------------+
//|                                     Fractal_Keltner_x5_Cloud.mq5 |
//|                              Copyright © 2008, jppoton@yahoo.com |
//|                              http://fractalfinance.blogspot.com/ |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, jppoton@yahoo.com"
#property link "http://fractalfinance.blogspot.com/"
#property description "Два фрактальных канала Кёлтнера в облачном исполнении"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 8
#property indicator_buffers 8 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrGreenYellow
//---- отображение метки индикатора
#property indicator_label1  "Upper Keltner 2 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrLavender
//---- отображение метки индикатора
#property indicator_label2  "Keltner Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки мувинга                 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color3 clrBlueViolet
//---- линия индикатора - сплошная
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "Frasma"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type4   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color4  clrLightPink
//---- отображение метки индикатора
#property indicator_label4  "Lower Keltner 2 Cloud"
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
input double alpha1=1.0; //девиация 1
input double alpha2=2.0; //девиация 2
input ENUM_APPLIED_PRICE_ IPC=PRICE_CLOSE_;//ценовая константа
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input color  Upper_color=clrGreen;
input color  Middle_color=clrBlueViolet;
input color  Lower_color=clrMagenta;
input uint FontSize=2; // размер ценовых меток
//+--------------------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer0[];
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов уровней
double UpBuffer1[],DnBuffer1[],UpBuffer2[],DnBuffer2[],UpBuffer3[],DnBuffer3[];
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве буфера данных
double ExtLineBuffer3[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
double LOG_2;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total,g_period_minus_1;
//---- Объявление стрингов для текстовых меток
string upper_name,middle_name,lower_name;
//+------------------------------------------------------------------+   
//| XMA BBx3 indicator initialization function                       | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(MathMax(e_period,normal_speed));
   g_period_minus_1=int(e_period-1);
   LOG_2=MathLog(2.0);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- Инициализация стрингов
   upper_name="Fractal_Keltner upper text lable";
   middle_name="Fractal_Keltner middle text lable";
   lower_name="Fractal_Keltner lower text lable";

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer0,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer2,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,UpBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,DnBuffer1,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer0,INDICATOR_DATA);
   SetIndexBuffer(5,UpBuffer3,INDICATOR_DATA);
   SetIndexBuffer(6,DnBuffer3,INDICATOR_DATA);
   SetIndexBuffer(7,ExtLineBuffer3,INDICATOR_CALCULATIONS);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);

//---- инициализации переменной для короткого имени индикатора
   string shortname="";
   StringConcatenate(shortname,"Fractal_Keltner_x5_Cloud(",e_period,", ",normal_speed,", ",DoubleToString(alpha1,2),", ",DoubleToString(alpha2,2),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name);
//----
   ChartRedraw(0);
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
   double ;
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
   FRACTAL_BANDS(first,rates_total,high,low);
//---- Установка ценовых меток
   int bar0=rates_total-1;
   SetRightPrice(0,upper_name,0,time[bar0],UpBuffer2[bar0],Upper_color,FontSize);
   SetRightPrice(0,middle_name,0,time[bar0],ExtLineBuffer0[bar0],Middle_color,FontSize);
   SetRightPrice(0,lower_name,0,time[bar0],DnBuffer3[bar0],Lower_color,FontSize);
//----     
   ChartRedraw(0);
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
//| FUNCTION : FRACTAL_BANDS                                         |
//| Compute the Fractal Bands for input data                         |
//| In :                                                             |
//|    - lastBars : these "n" last bars are considered for           |
//|      calculating the fractal dimension                           |
//|    - inputData : data array on which the computation is applied  | 
//| For further theoretical explanations, see my blog:               |  
//|    http://fractalfinance.blogspot.com/                           |
//+------------------------------------------------------------------+
void FRACTAL_BANDS(int lastBar,int Rates_Total,const double &High[],const double &Low[])
  {
   double diff,priorDiff;
   double length;
   double priceMax,priceMin;
   double fdi,trail_dim,beta,sum,deviation,frasma,hurst;
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
      sum=NULL;
      for(int iii=0; iii<speed; iii++) sum+=ExtLineBuffer3[MathMax(index-iii,0)];
      ExtLineBuffer0[index]=sum/speed;
      frasma=ExtLineBuffer0[index];          
      double Keltner=GetKeltner(e_period,index,High,Low);
      deviation=alpha1*Keltner;
      UpBuffer1[index]=DnBuffer2[index]=frasma+deviation*MathPow(alpha1,hurst)+dPriceShift;
      DnBuffer1[index]=UpBuffer3[index]=frasma-deviation*MathPow(alpha1,hurst)+dPriceShift;
      deviation=alpha2*Keltner;
      UpBuffer2[index]=frasma+deviation*MathPow(alpha2,hurst)+dPriceShift;
      DnBuffer3[index]=frasma-deviation*MathPow(alpha2,hurst)+dPriceShift;
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
// вычисление половины ширины канала Кёлтнера                        |
//+------------------------------------------------------------------+ 
double GetKeltner(int period,int index,const double &High[],const double &Low[])
  {
//----
   double keltner,sum=NULL;
   for(int iii=0; iii<period; iii++) sum +=High[MathMax(index-iii,0)]-Low[MathMax(index-iii,0)];
   keltner=sum/period;
//----
   return(keltner);
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      int     Font                // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color,             // Text color
                   int      Font               // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
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
