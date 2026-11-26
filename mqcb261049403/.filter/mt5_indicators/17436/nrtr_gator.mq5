//+------------------------------------------------------------------+
//|                                                   NRTR_Gator.mq5 |
//|                                             Copyright 2010, Rosh |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright 2010, Rosh"
//---- ссылка на сайт автора
#property link      "http://forexsystems.ru/phpBB/index.php"
//---- номер версии индикатора
#property version   "2.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано девять буферов
#property indicator_buffers 9
//---- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color1  clrTomato
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей метки индикатора
#property indicator_label1  "Линия продажи"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован голубой цвет
#property indicator_color2  clrDeepSkyBlue
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Линия покупки"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3 DRAW_ARROW
//---- в качестве цвета бычьей линии индикатора использован голубой цвет
#property indicator_color3 clrDeepSkyBlue
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- отображение бычей метки индикатора
#property indicator_label3  "Потолок"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4 DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color4 clrTomato
//---- толщина линии индикатора 4 равна 1
#property indicator_width4  1
//---- отображение медвежьей метки индикатора
#property indicator_label4 "Пол"

//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5 DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов индикатора использованы зелёный и красный цвета
#property indicator_color5 clrGreen,clrRed 
//---- толщина линии индикатора 5 равна 1
#property indicator_width5  1
//---- отображение бычей метки индикатора
#property indicator_label5  "Бар"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET 0                        // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int    PerATR=40;
input double kATR=2.0;
input bool   useSendMail=false;
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
double Ceil[];
double Floor[];
double Trend[];
double ATR[];  
double UpBar[];
double DownBar[];
double ColorBar[];
double GatorTrend[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- объявление переменной для хранения хендла индикатора
int ATR_Handle, Alligator_Handle;
int sm_Bars, supervizerShift,SymbolSpread,GatorBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=int(PerATR)+1;
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,251);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,251);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Ceil,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Ceil,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Floor,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Floor,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,UpBar,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpBar,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,DownBar,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DownBar,true);  
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(6,ColorBar,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBar,true); 
   

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(7,Trend,INDICATOR_CALCULATIONS);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Trend,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(8,GatorTrend,INDICATOR_CALCULATIONS);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(GatorTrend,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(9,ATR,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ATR,true);

//---- инициализации переменной для короткого имени индикатора
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"NRTR_Gator");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- Получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,PerATR);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
     
//---- Получение хендла индикатора Alligator
   Alligator_Handle=iAlligator(NULL,0,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);
   if(Alligator_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Alligator");
      return(INIT_FAILED);
     }
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| пробитие верха ДАУНтренда                                        |
//+------------------------------------------------------------------+
bool BreakDown(int shift,const double &Close[])
  {
//----
   if(Close[shift]>SellBuffer[shift+1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| пробитие дна АПтренда                                            |
//+------------------------------------------------------------------+
bool BreakUp(int shift,const double &Close[])
  {
//----
   if(Close[shift]<BuyBuffer[shift+1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| взятие нового минимума по ДАУНтренду                             |
//+------------------------------------------------------------------+
bool BreakFloor(int shift,const double &High[])
  {
//----
   if(High[shift]<Floor[shift+1]) return(true);
//----  
   return(false);
  }
//+------------------------------------------------------------------+
//| взятие нового максимума по АПтренду                              |
//+------------------------------------------------------------------+
bool BreakCeil(int shift,const double &Low[])
  {
//----
   if(Low[shift]>Ceil[shift+1]) return(true);
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| определение предыдущего тренда                                   |
//+------------------------------------------------------------------+
bool Uptrend(int shift)
  {
//----
//Print("Trend=",Trend[shift+1]);
   bool result=false;
   if(Trend[shift + 1] ==  1) result = true;
   if(Trend[shift + 1] == -1) result = false;
   if(Trend[shift+ 1] !=  1 && Trend[shift + 1] != -1)
      Print("Внимание! Тренд не определен, такого быть не может. Бар от конца ",(Bars(NULL,0)-shift));
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| установка нового уровня потолка                                  |
//+------------------------------------------------------------------+
void NewCeil(int shift,const double &Close[])
  {
//----
   Ceil[shift]=Close[shift];
   Floor[shift]=0.0;
//----
  }
//+------------------------------------------------------------------+
//| установка нового уровня пола                                     |
//+------------------------------------------------------------------+
void NewFloor(int shift,const double &Close[])
  {
//----
   Floor[shift]= Close[shift];
   Ceil[shift] = 0.0;
//----
  }
//+------------------------------------------------------------------+
//| установка уровня поддержки АПтренда                              |
//+------------------------------------------------------------------+
void SetBuyBuffer(int shift,const double &Close[])
  {
//----
   BuyBuffer[shift]=Close[shift]-kATR*ATR[shift];
   SellBuffer[shift]=0.0;
//----
  }
//+------------------------------------------------------------------+
//| установка уровня поддержки ДАУНтренда                            |
//+------------------------------------------------------------------+
void SetSellBuffer(int shift,const double &Close[])
  {
//----
   SellBuffer[shift]= Close[shift]+kATR * ATR[shift];
   BuyBuffer[shift] = 0.0;
//----
  }
//+------------------------------------------------------------------+
//| реверс тренда и установка новых уровней                          |
//+------------------------------------------------------------------+
void NewTrend(int shift,const double &Close[])
  {
//----
   if(Trend[shift+1]==1)
     {
      Trend[shift]=-1;
      NewFloor(shift,Close);
      SetSellBuffer(shift,Close);
     }
   else
     {
      Trend[shift]=1;
      NewCeil(shift,Close);
      SetBuyBuffer(shift,Close);
     }

   if(Trend[shift+1]!=1 && Trend[shift+1]!=-1)
      Print("Внимание! Тренд не определен, такого быть не может");
//----
  }
//+------------------------------------------------------------------+
//| продолжение тренда                                               |
//+------------------------------------------------------------------+
void CopyLastValues(int shift)
  {
//----
   SellBuffer[shift]= SellBuffer[shift+1];
   BuyBuffer[shift] = BuyBuffer[shift+1];
   Ceil[shift]=Ceil[shift+1];
   Floor[shift] = Floor[shift + 1];
   Trend[shift] = Trend[shift + 1];
//----
  }
//+------------------------------------------------------------------+
//| продолжение тренда                                               |
//+------------------------------------------------------------------+
void SendSMS(int shift)
  {
//----
   if(IsNewBar() && Trend[shift+1] *Trend[shift+2]==-1 && shift==0 && useSendMail) // сменился тренд
     {
      if(Trend[shift+1]==1)
        SendMail("NRTR ",Symbol()+" "+EnumToString(Period())+" развернулся вверх, Ask = "+DoubleToString(SymbolInfoDouble(NULL,SYMBOL_ASK),_Digits));
      else                 
        SendMail("NRTR ",Symbol()+" "+EnumToString(Period())+" развернулся вниз, Bid = " +DoubleToString(SymbolInfoDouble(NULL,SYMBOL_BID),_Digits));
     }

//----
  }
//+------------------------------------------------------------------+
//| IsNewBar() function                                              |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
//----
   static datetime Told;
   datetime Tnew[1];

   CopyTime(Symbol(),0,0,1,Tnew);
   if(Tnew[0]!=Told)
     {
      Told=Tnew[0];
      return(true);
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов  цены для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  { 
   
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
   if(BarsCalculated(ATR_Handle)<rates_total) return(prev_calculated);
   if(BarsCalculated(Alligator_Handle)<rates_total) return(prev_calculated);

//---- объявления локальных переменных 
   int limit,to_copy;
   double GATORJAW[],GATORTEETH[],GATORLIPS[];
   
//---- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(GATORJAW,true);
   ArraySetAsSeries(GATORTEETH,true);
   ArraySetAsSeries(GATORLIPS,true);
   
//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-PerATR-1;  // стартовый номер для расчёта всех баров
      to_copy=rates_total;

      //---- копируем вновь появившиеся данные в динамический массив
      if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(prev_calculated);
      if(CopyBuffer(Alligator_Handle,GATORJAW_LINE,0,to_copy,GATORJAW)<=0) return(prev_calculated);
      if(CopyBuffer(Alligator_Handle,GATORTEETH_LINE,0,to_copy,GATORTEETH)<=0) return(prev_calculated);
      if(CopyBuffer(Alligator_Handle,GATORLIPS_LINE,0,to_copy,GATORLIPS)<=0) return(prev_calculated);

      double closeX= close[limit+1];
      double openX = open[limit+1];
      int limit1=limit+1; 
      //----
      if(closeX >  openX){Trend[limit1]=+1; Ceil[limit1]=closeX; BuyBuffer[limit1]=closeX - kATR * ATR[limit1];}
      if(closeX <  openX){Trend[limit1]=-1; Floor[limit1]=closeX; SellBuffer[limit1]=closeX + kATR * ATR[limit1];}
      if(closeX == openX){Trend[limit1]=+1; Ceil[limit1]=closeX; BuyBuffer[limit1]=closeX - kATR * ATR[limit1];}
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=limit+1;
      //--- копируем вновь появившиеся данные в динамический массив
      if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(prev_calculated);
      if(CopyBuffer(Alligator_Handle,GATORJAW_LINE,0,to_copy,GATORJAW)<=0) return(prev_calculated);
      if(CopyBuffer(Alligator_Handle,GATORTEETH_LINE,0,to_copy,GATORTEETH)<=0) return(prev_calculated);
      if(CopyBuffer(Alligator_Handle,GATORLIPS_LINE,0,to_copy,GATORLIPS)<=0) return(prev_calculated);      
     }

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      supervizerShift=bar;

      if (GATORJAW[bar]<GATORTEETH[bar] && GATORTEETH[bar]<GATORLIPS[bar]) GatorTrend[bar]=+1.0;
      if (GATORJAW[bar]>GATORTEETH[bar] && GATORTEETH[bar]>GATORLIPS[bar]) GatorTrend[bar]=-1.0;
      
      if(Uptrend(bar))
        {
         //Print("UpTrend");
         if(BreakCeil(bar,low))
           {
            NewCeil(bar,close);
            SetBuyBuffer(bar,close);
            Trend[bar]=+1;
            continue;
           }

         if(BreakUp(bar,close))
           {
            NewTrend(bar,close);
            continue;
           }

         CopyLastValues(bar);
        }
      else
        {
         if(BreakFloor(bar,high))
           {
            NewFloor(bar,close);
            SetSellBuffer(bar,close);
            Trend[bar]=-1;
            continue;
           }

         if(BreakDown(bar,close))
           {
            NewTrend(bar,close);
            continue;
           }

         CopyLastValues(bar);
        }
      if(DownBar[bar]>UpBar[bar]) ColorBar[bar]=1;
      else ColorBar[bar]=0;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
