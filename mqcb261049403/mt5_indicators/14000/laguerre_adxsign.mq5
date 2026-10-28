//+--------------------------------------------------------------------------+
//|                                                     Laguerre_ADXSign.mq5 |
//|                         Copyright © 2005, Emerald King / transport_david | 
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ | 
//+--------------------------------------------------------------------------+
#property copyright "Copyright © 2007, Emerald King / transport_david"
#property link "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение бычей метки индикатора
#property indicator_label1  "Laguerre_ADX Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован голубой цвет
#property indicator_color2  clrDodgerBlue
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение медвежьей метки индикатора
#property indicator_label2 "Laguerre_ADX Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint ADXPeriod=14;
input double gamma=0.764;
input int Shift=0;                                 // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int ADX_Handle,ATR_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,ADXPeriod));

//---- получение хендла индикатора iADX
   ADX_Handle=iADX(NULL,0,ADXPeriod);
   if(ADX_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iADX");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
   
//--- завершение инициализации
   return(INIT_SUCCEEDED);
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
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || BarsCalculated(ADX_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double pL0,pL1,pL2,pL3,pL0A,pL1A,pL2A,pL3A,mL0,mL1,mL2,mL3,mL0A,mL1A,mL2A,mL3A,LDMIP=0,LDMIM=0,CU,CD,DMIP[],DMIM[],ATR[];
//---- объявления статических переменных для хранения действительных значений коэфициентов
   static double pL0_,pL1_,pL2_,pL3_,pL0A_,pL1A_,pL2A_,pL3A_,LDMIP_;
   static double mL0_,mL1_,mL2_,mL3_,mL0A_,mL1A_,mL2A_,mL3A_,LDMIM_;

//---- расчёт стартового номера для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
      //---- стартовая инициализация расчётных коэффициентов
      pL0_ = 0.0;
      pL1_ = 0.0;
      pL2_ = 0.0;
      pL3_ = 0.0;
      pL0A_ = 0.0;
      pL1A_ = 0.0;
      pL2A_ = 0.0;
      pL3A_ = 0.0;
      //---- стартовая инициализация расчётных коэффициентов
      mL0_ = 0.0;
      mL1_ = 0.0;
      mL2_ = 0.0;
      mL3_ = 0.0;
      mL0A_ = 0.0;
      mL1A_ = 0.0;
      mL2A_ = 0.0;
      mL3A_ = 0.0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
   to_copy=limit+1;

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(ADX_Handle,PLUSDI_LINE,0,to_copy,DMIP)<=0) return(RESET);
   if(CopyBuffer(ADX_Handle,MINUSDI_LINE,0,to_copy,DMIM)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0)  return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(DMIP,true);
   ArraySetAsSeries(DMIM,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- восстанавливаем значения переменных
   pL0 = pL0_;
   pL1 = pL1_;
   pL2 = pL2_;
   pL3 = pL3_;
   pL0A = pL0A_;
   pL1A = pL1A_;
   pL2A = pL2A_;
   pL3A = pL3A_; 
     
//---- восстанавливаем значения переменных
   mL0 = mL0_;
   mL1 = mL1_;
   mL2 = mL2_;
   mL3 = mL3_;
   mL0A = mL0A_;
   mL1A = mL1A_;
   mL2A = mL2A_;
   mL3A = mL3A_;

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      pL0A = pL0;
      pL1A = pL1;
      pL2A = pL2;
      pL3A = pL3;
      //----
      pL0 = (1 - gamma) * DMIP[bar] + gamma * pL0A;
      pL1 = - gamma * pL0 + pL0A + gamma * pL1A;
      pL2 = - gamma * pL1 + pL1A + gamma * pL2A;
      pL3 = - gamma * pL2 + pL2A + gamma * pL3A;
      //----
      CU = 0;
      CD = 0;
      //---- 
      if(pL0 >= pL1) CU  = pL0 - pL1; else CD  = pL1 - pL0;
      if(pL1 >= pL2) CU += pL1 - pL2; else CD += pL2 - pL1;
      if(pL2 >= pL3) CU += pL2 - pL3; else CD += pL3 - pL2;
      //----
      if(CU+CD!=0) LDMIP=CU/(CU+CD);

      mL0A = mL0;
      mL1A = mL1;
      mL2A = mL2;
      mL3A = mL3;
      //----
      mL0 = (1 - gamma) * DMIM[bar] + gamma * mL0A;
      mL1 = - gamma * mL0 + mL0A + gamma * mL1A;
      mL2 = - gamma * mL1 + mL1A + gamma * mL2A;
      mL3 = - gamma * mL2 + mL2A + gamma * mL3A;
      //----
      CU = 0;
      CD = 0;
      //---- 
      if(mL0 >= mL1) CU  = mL0 - mL1; else CD  = mL1 - mL0;
      if(mL1 >= mL2) CU += mL1 - mL2; else CD += mL2 - mL1;
      if(mL2 >= mL3) CU += mL2 - mL3; else CD += mL3 - mL2;
      //----
      if(CU+CD!=0) LDMIM=CU/(CU+CD);
      
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;
      
      if(LDMIP_<=LDMIM_ && LDMIP>LDMIM) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(LDMIP_>=LDMIM_ && LDMIP<LDMIM) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;

      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(bar==1)
        {
         pL0_ = pL0;
         pL1_ = pL1;
         pL2_ = pL2;
         pL3_ = pL3;
         pL0A_ = pL0A;
         pL1A_ = pL1A;
         pL2A_ = pL2A;
         pL3A_ = pL3A;
         
         mL0_ = mL0;
         mL1_ = mL1;
         mL2_ = mL2;
         mL3_ = mL3;
         mL0A_ = mL0A;
         mL1A_ = mL1A;
         mL2A_ = mL2A;
         mL3A_ = mL3A;
        }
        
      if(bar)
        {
         LDMIP_=LDMIP;
         LDMIM_=LDMIM;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
