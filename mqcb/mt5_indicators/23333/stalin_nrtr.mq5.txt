//+------------------------------------------------------------------+
//|                                                  Stalin_NRTR.mq5 |
//|                   Copyright © 2011, Andrey Vassiliev (MoneyJinn) |
//|                                         http://www.vassiliev.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andrey Vassiliev (MoneyJinn)"
#property link      "http://www.vassiliev.ru/"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1 DRAW_LINE
//---- в качестве окраски индикатора использован
#property indicator_color1 clrLime
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "NRTR Line Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type2 DRAW_LINE
//---- в качестве окраски индикатора использован
#property indicator_color2 clrMagenta
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "NRTR Line Down"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type3 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color3 clrLimeGreen
//---- линия индикатора - сплошная
#property indicator_style3 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width3 2
//---- отображение метки сигнальной линии
#property indicator_label3  "NRTR Up"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type4 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color4 clrDeepPink
//---- линия индикатора - сплошная
#property indicator_style4 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4 2
//---- отображение метки сигнальной линии
#property indicator_label4  "NRTR Down"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде значка
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет зелёный
#property indicator_color5  clrLimeGreen
//---- линия индикатора 5 - непрерывная кривая
#property indicator_style5  STYLE_SOLID
//---- толщина линии индикатора 5 равна 5
#property indicator_width5  5
//---- отображение бычьей метки индикатора
#property indicator_label5  "Buy BykovTrend signal"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 6 в виде значка
#property indicator_type6   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет глубоко-розовый
#property indicator_color6  clrDeepPink
//---- линия индикатора 6 - непрерывная кривая
#property indicator_style6  STYLE_SOLID
//---- толщина линии индикатора 6 равна 5
#property indicator_width6  5
//---- отображение медвежьей метки индикатора
#property indicator_label6 "Sell BykovTrend signal"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input ENUM_MA_METHOD MAMethod=MODE_EMA;
input int    MAShift=0;
input int    Fast=14;
input int    Slow=21;
input int    RSI=17;
input int    Confirm=0.0;
input int    Flat=0.0;
input double AtrRatio=0.375;
input bool   SoundAlert=false;
input bool   EmailAlert=false;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем будут использованы в качестве индикаторных буферов
double UpBuffer1[],DnBuffer1[];
double UpBuffer2[],DnBuffer2[];
double SellBuffer[],BuyBuffer[];
//----
double IUP,IDN,E1,E2,Confirm2,Flat2,ATR_[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total;
int trend,trend_prev;
//---- Объявление целых переменных для хранения хендлов индикаторов
int SLMA_Handle,FSMA_Handle,RSI_Handle,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void BU(int i,const double &Low[],const datetime &Time[])
  {
//----
   if(Low[i]>=(E1+Flat2) || Low[i]<=(E1-Flat2))
     {
      if(trend<=0) BuyBuffer[i]=Low[i]-AtrRatio*ATR_[i];
      E1=Low[i];
      trend=+1;
      Alerts(i,"UP "+Symbol()+" "+TimeToString(Time[i]));
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void BD(int i,const double &High[],const datetime &Time[])
  {
//----
   if(High[i]>=(E2+Flat2) || High[i]<=(E2-Flat2))
     {
      if(trend>=0) SellBuffer[i]=High[i]+AtrRatio*ATR_[i];
      E2=High[i];
      trend=-1;
      Alerts(i,"DN "+Symbol()+" "+TimeToString(Time[i]));
     }
//---- 
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void Alerts(int pos,string txt)
  {
//----
   if(SoundAlert==true&&pos==1){PlaySound("alert.wav");}
   if(EmailAlert==true&&pos==1){SendMail("Stalin alert signal: "+txt,txt);}
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   min_rates_total=MathMax(RSI,MathMax(Slow,Fast));
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,min_rates_total))+1;

//---- Инициализация переменных
   IUP=0;
   IDN=0;
   E1=0;
   E2=0;

   if(_Digits==3 || _Digits==5)
     {
      double Point10=10*_Point;
      Confirm2=Point10;
      Flat2=Flat*Point10;
     }
   else
     {
      Confirm2=Confirm*_Point;
      Flat2=Flat*_Point;
     }

//---- получение хендла индикатора iRSI
   if(RSI)
     {
      RSI_Handle=iRSI(NULL,0,RSI,PRICE_CLOSE);
      if(RSI_Handle==INVALID_HANDLE)
        {
         Print(" Не удалось получить хендл индикатора iRSI");
         return(INIT_FAILED);
        }
     }
//---- получение хендла индикатора iMA
   SLMA_Handle=iMA(NULL,0,Slow,MAShift,MAMethod,PRICE_CLOSE);
   if(SLMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора iMA
   FSMA_Handle=iMA(NULL,0,Fast,MAShift,MAMethod,PRICE_CLOSE);
   if(FSMA_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnBuffer1,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer1,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnBuffer2,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(4,PLOT_ARROW,171);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(5,PLOT_ARROW,171);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,NULL);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для подокон 
   string short_name="Stalin_NRTR";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//---- проверка количества баров на достаточность для расчета
   if((RSI && BarsCalculated(RSI_Handle)<rates_total)
      || BarsCalculated(SLMA_Handle)<rates_total
      || BarsCalculated(FSMA_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit;
   double RSI_[],SLMA_[],FSMA_[],range,stop;

//---- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      to_copy=rates_total; // расчетное количество всех баров
      trend_prev=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
      to_copy=limit+2; // расчетное количество только новых баров
     }

//---- индексация элементов в массивах, как в таймсериях
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(SLMA_,true);
   ArraySetAsSeries(FSMA_,true);
   ArraySetAsSeries(ATR_,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(SLMA_Handle,0,0,to_copy,SLMA_)<=0) return(RESET);
   if(CopyBuffer(FSMA_Handle,0,0,to_copy,FSMA_)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy-1,ATR_)<=0) return(RESET);

   if(RSI)
     {
      ArraySetAsSeries(RSI_,true);
      if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI_)<=0) return(RESET);
     }

//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=SellBuffer[bar]=UpBuffer1[bar]=DnBuffer1[bar]=UpBuffer2[bar]=DnBuffer2[bar]=NULL;
      trend=trend_prev;

      if(FSMA_[bar+1]<SLMA_[bar+1]&&FSMA_[bar]>SLMA_[bar]&&(!RSI || RSI_[bar]>50)){if(!Confirm2)BU(bar,low, time); else{IUP=low[bar]; IDN=0;}}
      if(FSMA_[bar+1]>SLMA_[bar+1]&&FSMA_[bar]<SLMA_[bar]&&(!RSI || RSI_[bar]<50)){if(!Confirm2)BD(bar,high,time); else{IDN=high[bar];IUP=0;}}
      if(IUP && high[bar]-IUP>=Confirm2 && close[bar]<=high[bar]){BU(bar,low,time); IUP=0;}
      if(IDN && IDN-low[bar]>=Confirm2 && open[bar]>=close[bar]){BD(bar,high,time);IDN=0;}
      range=AtrRatio*ATR_[bar];
      if(trend>0)
        {
         if(BuyBuffer[bar])
           {
            UpBuffer1[bar]=UpBuffer2[bar]=BuyBuffer[bar];
            DnBuffer1[bar]=DnBuffer1[bar+1];
           }
         else
           {
            stop=low[bar]-range;
            if(stop<UpBuffer1[bar+1]) stop=UpBuffer1[bar+1];
            UpBuffer1[bar]=UpBuffer2[bar]=stop;
           }
        }

      if(trend<0)
        {
         if(SellBuffer[bar])
           {
            DnBuffer1[bar]=DnBuffer2[bar]=SellBuffer[bar];
            UpBuffer1[bar]=UpBuffer1[bar+1];
           }
         else
           {
            stop=high[bar]+range;
            if(stop>DnBuffer1[bar+1]) stop=DnBuffer1[bar+1];
            DnBuffer1[bar]=DnBuffer2[bar]=stop;
           }
        }
      
      if(bar) trend_prev=trend;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
