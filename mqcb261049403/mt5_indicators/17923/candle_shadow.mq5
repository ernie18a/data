//+------------------------------------------------------------------+
//|                                                Candle Shadow.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"

#property description "Индикатор поиска свечей без теней" 
#property description "Найденные свечи отмечаются символами из набора Wingdings" 

#property indicator_chart_window 
#property indicator_buffers 2 
#property indicator_plots   2 
//--- plot Arrows 
#property indicator_label1  "High" 
#property indicator_type1   DRAW_ARROW 
#property indicator_color1  clrBlue 
#property indicator_width1  1 
#property indicator_label2  "Low" 
#property indicator_type2   DRAW_ARROW 
#property indicator_color2  clrRed
#property indicator_width2  1 
//--- input параметры
sinput string  __1__             = "";          // Параметры верха свечи
input bool     IsTopShadow       = true;        // true -> отображать свечи без верхней тени  
input ushort   top_shadow_code   = 226;         // Код символа верха свечи (32-255)
sinput string  __2__             = "";          // Параметр тела свечи
input ushort   min_size_candel   = 15;          // Минимальный размер тела свечи ()
sinput string  __3__             = "";          // Параметры низа свечи
input bool     IsLowerShadow     = true;        // true -> отображать свечи без нижней тени  
input ushort   lower_shadow_code = 225;         // Код символа верха свечи (32-255)
sinput string  __4__             = "";          // Параметр смещения
input uchar    vertical_shift    = 15;          // Смещение стрелок по вертикали (0-255)
//--- индикаторные буфера для построения  
double         BufferTop[];
double         BufferLower[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- проверка корректности параметров
   if(!IsTopShadow && !IsLowerShadow)
     {
      Print("Оба параметра \"отображать свечи без верхней/нижней тени\" равны false");
      return(INIT_PARAMETERS_INCORRECT);
     }
//--- indicator buffers mapping 
   SetIndexBuffer(0,BufferTop,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLower,INDICATOR_DATA);
//--- зададим код символа для отрисовки в PLOT_ARROW 
   PlotIndexSetInteger(0,PLOT_ARROW,top_shadow_code);
   PlotIndexSetInteger(1,PLOT_ARROW,lower_shadow_code);
//--- зададим cмещение стрелок по вертикали в пикселях  
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-(int)vertical_shift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,(int)vertical_shift);
//--- установим в качестве пустого значения 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- 
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
   static datetime prev_time=0;
//--- работаем только в момент рождения нового бара, внутри бара не работаем
   if(prev_time==time[rates_total-1])
      return(rates_total);
//--- на новом баре запоминает время его рождения
   prev_time=time[rates_total-1];
//--- блок расчета значений индикатора 
   int start=1;
   if(prev_calculated>0)
      start=prev_calculated;
//--- цикл расчета 
   for(int i=start;i<rates_total;i++)
     {
      //--- если предыдущая свеча имеет тело больше минимального
      if(MathAbs(open[i-1]-close[i-1])/Point()>min_size_candel)
        {
         if(IsTopShadow)
            if(high[i-1]==open[i-1] || high[i-1]==close[i-1])
               BufferTop[i-1]=high[i-1];
         if(IsLowerShadow)
            if(low[i-1]==open[i-1] || low[i-1]==close[i-1])
               BufferLower[i-1]=low[i-1];
        }
     }
//--- return value of prev_calculated for next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+
