//+------------------------------------------------------------------+
//|                                                 ChartOnChart.mq5 |
//|                                      Copyright 2016 prostotrader |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016 prostotrader"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots   1
//
input string SecSymb="RTS-12.16";  //Отображаемый символ
input bool   Match=true;           //Точное совпадение свечей по времени
input color  LineColor = clrWhite; //Цвет линии
input color  BullColor = clrGreen; //Цвет бычьей свечи
input color  BearColor = clrRed;   //Цвет медвежьей свечи

//--- plot Label1
#property indicator_label1  ""
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrWhite, clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- Levels
#property indicator_level1 0
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
//--- индикаторные буферы 
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double LastBuffer[];
//
double att_cnt;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   att_cnt = 1;
   if(!SymbolSelect(SecSymb,true))
     {
      Alert("Не правильно выбран символ "+SecSymb);
      return(INIT_FAILED);
     }
   int digits=int(SymbolInfoInteger(SecSymb,SYMBOL_DIGITS));
   IndicatorSetInteger(INDICATOR_DIGITS,digits);
      IndicatorSetString(INDICATOR_SHORTNAME,SecSymb);
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
   SetIndexBuffer(2,Buffer3,INDICATOR_DATA);
   SetIndexBuffer(3,Buffer4,INDICATOR_DATA);
   SetIndexBuffer(4,LastBuffer,INDICATOR_CALCULATIONS);
//---
   ArraySetAsSeries(Buffer1,true);
   ArraySetAsSeries(Buffer2,true);
   ArraySetAsSeries(Buffer3,true);
   ArraySetAsSeries(Buffer4,true);
   ArraySetAsSeries(LastBuffer,true);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,LineColor); 
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,BullColor); 
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,BearColor);
//---
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrYellow);
   PlotIndexSetString(0,PLOT_LABEL," Open;"+" High;"+" Low;"+" Close");
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
   ArraySetAsSeries(time,true);
   MqlRates rates[];
   if(prev_calculated==0)
     {
      ArrayInitialize(Buffer1,EMPTY_VALUE);
      ArrayInitialize(Buffer2,EMPTY_VALUE);
      ArrayInitialize(Buffer3,EMPTY_VALUE);
      ArrayInitialize(Buffer4,EMPTY_VALUE);
      ArrayInitialize(LastBuffer,EMPTY_VALUE);
      //---
      int attempts=0;
      int result=0;
      int a_cnt=1000;
      //--- делаем 1000 попыток получить таймсерию 
      while((attempts<a_cnt) && !IsStopped())
        {
         result=CopyRates(SecSymb,Period(),0,rates_total,rates);
         if(result>0) break;
         for(int i=0; i<a_cnt;i++)
           {
            result=1;
            result=0;
           }
         attempts++;
        }
      if(result>0)
        {
         int mem_pos=result;
         ArraySetAsSeries(rates,true);
         if(Match)
           {
            for(int i=rates_total-1;i>=0;i--)
              {
               int is_done=false;
               for(int j=mem_pos-1;j>=0;j--)
                 {
                  if(time[i]==rates[j].time)
                    {
                     mem_pos=j;
                     Buffer1[i] = rates[j].open;
                     Buffer2[i] = rates[j].high;
                     Buffer3[i] = rates[j].low;
                     Buffer4[i] = rates[j].close;
                     is_done=true;
                     break;
                    }
                 }
               if(!is_done)
                 {
                  Buffer1[i] = EMPTY_VALUE;
                  Buffer2[i] = EMPTY_VALUE;
                  Buffer3[i] = EMPTY_VALUE;
                  Buffer4[i] = EMPTY_VALUE;
                 }
              }
           }
         else
           {
            for(int i=result-1;i>=0;i--)
              {
               Buffer1[i] = rates[i].open;
               Buffer2[i] = rates[i].high;
               Buffer3[i] = rates[i].low;
               Buffer4[i] = rates[i].close;
              }
           }
        }
      else
        {
          if(att_cnt == 5)
          {
            Alert("Данные по символу "+SecSymb+" не скопированы! Перегрузите индикатор.");
          }
          else
          {
            att_cnt++;
            return(0);
          }  
        }
     }
     else
     {
       int diff = rates_total - prev_calculated;
       if(diff>0)
       {
         for(int i=diff-1; i>0; i++)
         {
          Buffer1[i] = Buffer1[i+1];
          Buffer2[i] = Buffer2[i+1];
          Buffer3[i] = Buffer3[i+1];
          Buffer4[i] = Buffer4[i+1];
         }
         Buffer1[0]= EMPTY_VALUE;
         Buffer2[0] = EMPTY_VALUE;
         Buffer3[0] = EMPTY_VALUE;
         Buffer4[0] = EMPTY_VALUE;
       }
     }
   if(CopyRates(SecSymb,Period(),0,1,rates)==1)
     {
      if(time[0]==rates[0].time)
        {
         Buffer1[0]= rates[0].open;
         Buffer2[0] = rates[0].high;
         Buffer3[0] = rates[0].low;
         Buffer4[0] = rates[0].close;
        }
     }
     else
     {
       int attempts = 0;
       int a_cnt=10;
       int result =0;
       while((attempts<a_cnt) && !IsStopped())
        {
         result=CopyRates(SecSymb,Period(),0,1,rates);
         if(result>0) break;
         for(int i=0; i<100;i++)
           {
            result=1;
            result=0;
           }
         attempts++;
        }
        if(result>0)
        {
          if(time[0]==rates[0].time)
          {
           Buffer1[0]= rates[0].open;
           Buffer2[0] = rates[0].high;
           Buffer3[0] = rates[0].low;
           Buffer4[0] = rates[0].close;
         }
        }
        else
        {
          Alert("Данные тика не скопированы!");
        }
     }
   double s_last=SymbolInfoDouble(SecSymb,SYMBOL_LAST);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,s_last);
   LastBuffer[0]=s_last;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
