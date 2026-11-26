//+------------------------------------------------------------------+
//|                                                        J_TPO.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графические построение
#property indicator_plots   1
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//---- отрисовка индикатора в виде пятицветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве окраски гистограммы использовано пять цветов
#property indicator_color1 clrGray,clrLime,clrTeal,clrRed,clrBrown
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 +0.5
#property indicator_level2  0.0
#property indicator_level3 -0.5
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Перечисление для выбора таймсерии            |
//+----------------------------------------------+
enum Applied_price_ //тип константы
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Len_=14; // Период усреднения
input Applied_price_ IPC=PRICE_CLOSE_; // Ценовая константа
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double ExtBuffer[],ColorExtBuffer[];
//----
int Len,LenM,LenP;
double Kf,Kl;
double arr0[],arr1[],arr2[],arr3[];
double Arr0[],Arr1[],Arr2[],Arr3[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных
   Len=int(MathMax(Len_,3));
   LenM=Len-1;
   LenP=LenM+1;
   double k=LenP;
   Kf = 12 / (k * (k - 1) * (k + 1));
   Kl = (LenP + 1) * 0.5;
//---- инициализация переменных начала отсчета данных 
   min_rates_total=2*Len+1;
//---- распределение памяти под массивы переменных
   int size=Len+2;
   if(ArrayResize(arr0,size)<size) {Print("Не удалось распределить память под массив arr0[]"); return(-1);}
   if(ArrayResize(arr1,size)<size) {Print("Не удалось распределить память под массив arr1[]"); return(-1);}
   if(ArrayResize(arr2,size)<size) {Print("Не удалось распределить память под массив arr2[]"); return(-1);}
   if(ArrayResize(arr3,size)<size) {Print("Не удалось распределить память под массив arr3[]"); return(-1);}
   ZeroMemory(arr0);
   ZeroMemory(arr1);
   ZeroMemory(arr2);
   ZeroMemory(arr3);
//---- превращение динамического массива ExtBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора MAPeriod
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(ExtBuffer,true);
   ArraySetAsSeries(ColorExtBuffer,true);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов  цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявления локальных переменных 
   int limit1,limit2;
   int run,count,fff,numbx,ppp,rrr,sss;
   double invelue1,invelue=0.0,tmp2,outvelue,tmp1,tmp,max,value,series;
   static int Count,run_;
//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit1=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      limit2=limit1-1;
      ZeroMemory(arr0);
      ZeroMemory(arr1);
      ZeroMemory(arr2);
      ZeroMemory(arr3);
      Count=0;
      run_=0;
     }
   else
     {
      limit1=rates_total-prev_calculated; // стартовый номер для расчета новых баров
      limit2=limit1; // стартовый номер для расчета новых баров
     }
//---- восстанавливаем значения переменных
   ArrayCopy(arr0,Arr0,0,0,WHOLE_ARRAY);
   ArrayCopy(arr1,Arr1,0,0,WHOLE_ARRAY);
   ArrayCopy(arr2,Arr2,0,0,WHOLE_ARRAY);
   ArrayCopy(arr3,Arr3,0,0,WHOLE_ARRAY);
   count=Count;
   run=run_;
//---- основной цикл расчета индикатора
   for(int bar=limit1; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         ArrayCopy(Arr0,arr0,0,0,WHOLE_ARRAY);
         ArrayCopy(Arr1,arr1,0,0,WHOLE_ARRAY);
         ArrayCopy(Arr2,arr2,0,0,WHOLE_ARRAY);
         ArrayCopy(Arr3,arr3,0,0,WHOLE_ARRAY);
         Count=count;
         run_=run;
        }
      //---- обращение к функции PriceSeries для получения входной цены Series
      series=PriceSeries(IPC,bar,open,low,high,close);
      tmp2=0;
      tmp1=0;
      //----
      if(!count)
        {
         count=1;
         run=0;
         invelue=series;
         arr0[count]=invelue;
        }
      else
        {
         if(count<=LenP) count++;
         else count=LenP+1;
         //----
         invelue1=invelue;
         invelue=series;
         //----
         if(count>LenP)
           {
            for(fff=2; fff<=LenP; fff++) arr0[fff-1]=arr0[fff];
            arr0[LenP]=invelue;
           }
         else arr0[count]=invelue;
         //----
         if(LenM>= count && invelue1 != invelue) run = 1;
         if(LenM == count &&! run) count = 0;
        }
      //----
      if(count>=LenP)
        {
         for(rrr=1; rrr<=LenP; rrr++)
           {
            arr1[rrr] = arr0[rrr];
            arr2[rrr] = rrr;
            arr3[rrr] = rrr;
           }
         //----
         for(ppp=1; ppp<LenP; ppp++)
           {
            max=arr1[ppp];
            numbx=ppp;
            fff=ppp+1;
            //----
            for(fff=ppp+1; fff<=LenP; fff++)
               if(arr1[fff]<max)
                 {
                  max=arr1[fff];
                  numbx=fff;
                 }
            //----
            tmp=arr1[ppp];
            arr1[ppp]=arr1[numbx];
            arr1[numbx]=tmp;
            tmp=arr2[ppp];
            arr2[ppp]=arr2[numbx];
            arr2[numbx]=tmp;
           }
         //----
         ppp=1;
         while(LenP>ppp)
           {
            fff=ppp+1;
            tmp2 = 1;
            tmp1 = arr3[ppp];
            while(tmp2!=0)
              {
               if(arr1[ppp]!=arr1[fff])
                 {
                  if(fff-ppp>1)
                    {
                     tmp1/=fff-ppp;
                     sss=ppp;
                     for(sss=ppp; sss<fff; sss++) arr3[sss]=tmp1;
                    }
                  //----
                  tmp2=0;
                 }
               else
                 {
                  tmp1+=arr3[fff];
                  fff++;
                 }
              }
            //----
            ppp=fff;
           }
         //----
         tmp1=0;
         for(ppp=1; ppp<=LenP; ppp++) tmp1+=(arr3[ppp]-Kl) *(arr2[ppp]-Kl);
         outvelue=Kf*tmp1;
        }
      else outvelue=0;
      //----
      value=outvelue;
      if(value==0) value=0.00001;
      //----
      ExtBuffer[bar]=value;
     }
//---- основной цикл раскраски индикатора
   for(int bar=limit2; bar>=0; bar--)
     {
      ColorExtBuffer[bar]=0;
      //----
      if(ExtBuffer[bar]>0)
        {
         if(ExtBuffer[bar]>ExtBuffer[bar+1]) ColorExtBuffer[bar]=1;
         if(ExtBuffer[bar]<ExtBuffer[bar+1]) ColorExtBuffer[bar]=2;
        }
      //----
      if(ExtBuffer[bar]<0)
        {
         if(ExtBuffer[bar]<ExtBuffer[bar+1]) ColorExtBuffer[bar]=3;
         if(ExtBuffer[bar]>ExtBuffer[bar+1]) ColorExtBuffer[bar]=4;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries(uint applied_price,// ценовая константа
                   uint   bar,        // индекс сдвига относительно текущего бара на указанное количество периодов назад или вперед
                   const double &Open[],
                   const double &Low[],
                   const double &High[],
                   const double &Close[])
  {
//----
   switch(applied_price)
     {
      //---- ценовые константы из перечисления ENUM_APPLIED_PRICE
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
      default: return(Close[bar]);
     }
//----
//return(0);
  }
//+------------------------------------------------------------------+
