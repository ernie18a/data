//+----------------------------------------------------------------------------------+
//|                                                                 Din_fibo_Nex.mq5 | 
//|             Copyright © 2006, unknown author, get from kaizer, conversed by Rosh | 
//|link to kaizer: http://forum.alpari-idc.ru/profile.php?mode=viewprofile&u=4196161 | 
//+----------------------------------------------------------------------------------+
#property copyright "Copyright © 2006, unknown author, get from kaizer, conversed by Rosh"
#property link "http://forum.alpari-idc.ru/profile.php?mode=viewprofile&u=4196161"
#property description "Индикатор линии перемещения трейлинстопа"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 3
#property indicator_buffers 3
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета индикатора использован
#property indicator_color1  clrTeal
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "Din_fibo_Nex MaH"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета индикатора использован
#property indicator_color2  clrMaroon
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "Din_fibo_Nex MaL"
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint      Fibo_Channel_Period=3;
input double    Ratio=0.786;
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer1[],ExtLineBuffer2[],tvBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Проверим - разделитель диапазона или нет                         |
//+------------------------------------------------------------------+
bool isDelimeter(int TimeFrame,int Rates_total,const datetime &Time[],int shift)
  {
//----
   bool result=false;
   MqlDateTime tm;
   TimeToStruct(Time[shift],tm);
//---- 
   switch(TimeFrame)
     {
      case PERIOD_M1:result=(tm.min==0); break;
      case PERIOD_M2:result=(tm.min==0); break;
      case PERIOD_M3:result=(tm.min==0); break;
      case PERIOD_M4:result=(tm.min==0); break;
      case PERIOD_M5:result=(tm.min==0); break;
      case PERIOD_M6:result=(tm.min==0); break;
      case PERIOD_M10:result=(tm.min==0); break;
      case PERIOD_M12:result=(tm.min==0); break;
      case PERIOD_M15:result=(tm.min==0); break;
      case PERIOD_M20:result=(tm.min==0); break;
      case PERIOD_M30:result=(tm.min==0) && (MathMod(tm.hour,4.0)==0); break;
      case PERIOD_H1:result=(tm.min==0) && (MathMod(tm.hour,4.0)==0); break;
      case PERIOD_H2:result=(tm.min==0) && (MathMod(tm.hour,4.0)==0); break;
      case PERIOD_H3:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H4:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H6:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H8:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_H12:result=(tm.min==0) && (tm.hour==0); break;
      case PERIOD_D1:result=(tm.day_of_week==MONDAY) && (tm.hour==0); break;
      case PERIOD_W1:
        {
         MqlDateTime tm1;
         TimeToStruct(Time[MathMin(Rates_total-1,shift+1)],tm1);
         result=(tm.day==1) || (tm.day==2 && tm1.day!=1) || (tm.day==3 && tm1.day!=2); break;
        }
      default: Print("Недопустимый таймфрейм!!!");
     }
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| Установим MaH и MaL на границе диапазона                         |
//+------------------------------------------------------------------+
void SetHnL(int Rates_total,const double &Low[],const double &High[],const double &Close[],int shift)
  {
//---- 
   int i=shift+1;
   int counterPeriod=0;
   int first=0;
   while(counterPeriod<int(Fibo_Channel_Period))
     {
      while(i<Rates_total && !tvBuffer[i]) i++;
      if(!first) first=i;
      counterPeriod++;
      i++;
     }
   i--;
//----  
   int hh=ArrayMaximum(High,shift+1,i-shift);
   int ll=ArrayMinimum(Low,shift+1,i-shift);
//----   
   double tv=NormalizeDouble((High[hh]+Low[ll]+Close[shift+1])/3.0,_Digits);
   double diff=NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,_Digits);
   double MaH=tv+diff;
   double MaL=tv-diff;
   tvBuffer[shift]=tv;
   ExtLineBuffer1[shift]=MaH;
   ExtLineBuffer2[shift]=MaL;
   SetMovingHnL(first,shift);
//----
   return;
  }
//+------------------------------------------------------------------+
//| Установим MaH и MaL внутри диапазона                             |
//+------------------------------------------------------------------+
void SetMovingHnL(int DelimeterBar,int CurBar)
  {
   int m_cnt;
   double deltaH,deltaL;
//---- 
   deltaH=(ExtLineBuffer1[DelimeterBar]-ExtLineBuffer1[CurBar])/(DelimeterBar-CurBar);
   deltaL=(ExtLineBuffer2[DelimeterBar]-ExtLineBuffer2[CurBar])/(DelimeterBar-CurBar);
//----  
   for(m_cnt=DelimeterBar-1; m_cnt>CurBar; m_cnt--)
     {
      ExtLineBuffer1[m_cnt]=ExtLineBuffer1[m_cnt+1]-deltaH;
      ExtLineBuffer2[m_cnt]=ExtLineBuffer2[m_cnt+1]-deltaL;
     }
//----     
   for(m_cnt=DelimeterBar-1; m_cnt>CurBar; m_cnt--)
     {
      ExtLineBuffer1[m_cnt]=NormalizeDouble(ExtLineBuffer1[m_cnt],_Digits);
      ExtLineBuffer2[m_cnt]=NormalizeDouble(ExtLineBuffer2[m_cnt],_Digits);
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Установим MaH и MaL на правом краю                               |
//+------------------------------------------------------------------+
void SetValuesNullBar(int Rates_total,const double &Low[],const double &High[],const double &Close[],int shift)
  {
//---- 
   int i=shift;
   while(!tvBuffer[i]) i++;
   for(int j=i-1; j>shift; j--)
     {
      ExtLineBuffer1[j]=0.0;
      ExtLineBuffer2[j]=0.0;
     }
//---- 
   int first=0;
   i=shift;
   int counterPeriod=0;
   while(counterPeriod<int(Fibo_Channel_Period))
     {
      while(i<Rates_total && !tvBuffer[i]) i++;
      if(!first) first=i;
      counterPeriod++;
      i++;
     }
   i--;
//---- 
   int hh=ArrayMaximum(High,shift,i-shift);
   int ll=ArrayMinimum(Low,shift,i-shift);
//---- 
   double tv=NormalizeDouble((High[hh]+Low[ll]+Close[shift])/3.0,_Digits);
   double diff=NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,_Digits);
   double MaH=tv+diff;
   double MaL=tv-diff;
   ExtLineBuffer1[shift]=MaH;
   ExtLineBuffer2[shift]=MaL;
   SetMovingHnL(first,shift);
  }
//+------------------------------------------------------------------+   
//| SL_ATR indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- проверка таймфрейма на валидность 
   if(Period()==PERIOD_MN1)
     {
      Print("Недопустимый таймфрейм!!!");
      return(INIT_FAILED);
     }
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(20*Fibo_Channel_Period)+1;
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,tvBuffer,INDICATOR_CALCULATIONS);
//---- установка позиции, с которой начинается отрисовка индикаторов
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
   ArraySetAsSeries(tvBuffer,true);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Din_fibo_Nex(",Fibo_Channel_Period,",",DoubleToString(Ratio,4),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| SL_ATR iteration function                                        | 
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//---- объявления локальных переменных 
   int limit,bar;
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      //---- найти первый и второй разделитель и установить limit
      bar=rates_total-1;
      while(!isDelimeter(Period(),rates_total,time,bar)) bar--;
      int first=bar;
      bar--;
      int counterPeriod=0;
      while(counterPeriod<int(Fibo_Channel_Period))
        {
         while(!isDelimeter(Period(),rates_total,time,bar)) bar--;
         bar--;
         counterPeriod++;
        }
      bar++;
      int hh=ArrayMaximum(high,bar+1,first-bar);
      int ll=ArrayMinimum(low,bar+1,first-bar);
      //----
      double tv=NormalizeDouble((high[hh]+low[ll]+close[bar+1])/3.0,_Digits);
      double MaH=tv+NormalizeDouble((high[hh]-low[ll])/2.0*Ratio,_Digits);
      double MaL=tv-NormalizeDouble((high[hh]-low[ll])/2.0*Ratio,_Digits);
      tvBuffer[bar]=tv;
      ExtLineBuffer1[bar]=MaH;
      ExtLineBuffer2[bar]=MaL;
      limit=bar-1; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      tvBuffer[bar]=0.0;
      if(isDelimeter(Period(),rates_total,time,bar)) SetHnL(rates_total,low,high,close,bar);
      if(!bar) SetValuesNullBar(rates_total,low,high,close,bar);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
