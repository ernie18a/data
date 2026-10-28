//+------------------------------------------------------------------+
//|                                                Interpolation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "Interpolation"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpLength         =  100;           // Length
input uint                 InpPower          =  5;             // Power
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
input uint                 InpNodeDrawStyle=STYLE_DOT;         // Drawing style of node line
//--- indicator buffers
double         BufferRegression[];
double         BufferMA[];
//--- global variables
int            handle_ma;
int            length_def;
int            power;
int            period_ma;
string         prefix;
datetime       last_time;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- setting global variables
   length_def=int(InpLength<5 ? 5 : InpLength);
   power=int(InpPower<1 ? 1 : InpPower>9 ? 9 : InpPower);
   last_time=0;
//---
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferRegression,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMA,INDICATOR_CALCULATIONS);
//--- settings indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   string descr="Interpolation("+(string)power+")";
   IndicatorSetString(INDICATOR_SHORTNAME,descr);
   PlotIndexSetString(0,PLOT_LABEL,descr);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferRegression,true);
   ArraySetAsSeries(BufferMA,true);
//--- create MA's handle
   ResetLastError();
   handle_ma=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpAppliedPrice);
   if(handle_ma==INVALID_HANDLE)
     {
      Print("The iMA(1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,prefix,0);
   ChartRedraw();
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
//--- Проверка на минимальное количество баров для расчёта
   if(rates_total<length_def) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Подготовка данных
   DrawVLine(length_def,time);
//--- Расчёт индикатора
   if(last_time!=time[0])
     {
      Calculate(rates_total);
      last_time=time[0];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      if(StringFind(sparam,prefix)==0)
         Calculate(Bars(NULL,PERIOD_CURRENT));
     }
  }
//+------------------------------------------------------------------+
//| Выводит линии узлов                                              |
//+------------------------------------------------------------------+
void DrawVLine(const int first_bar,const datetime &time[])
  {
//---
   if(ObjectFind(0,prefix+"node_1")==WRONG_VALUE)
     {
      ObjectCreate(0,prefix+"node_1",OBJ_VLINE,0,time[first_bar],0);
      ObjectSetInteger(0,prefix+"node_1",OBJPROP_RAY,false);
      ObjectSetInteger(0,prefix+"node_1",OBJPROP_STYLE,InpNodeDrawStyle);
      ObjectSetInteger(0,prefix+"node_1",OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,prefix+"node_1",OBJPROP_SELECTED,true);
      ObjectSetString(0,prefix+"node_1",OBJPROP_TOOLTIP,"Node 1");
     }
//---
   if(ObjectFind(0,prefix+"node_2")==WRONG_VALUE)
     {
      ObjectCreate(0,prefix+"node_2",OBJ_VLINE,0,time[0],0);
      ObjectSetInteger(0,prefix+"node_2",OBJPROP_RAY,false);
      ObjectSetInteger(0,prefix+"node_2",OBJPROP_STYLE,InpNodeDrawStyle);
      ObjectSetInteger(0,prefix+"node_2",OBJPROP_SELECTABLE,true);
      ObjectSetInteger(0,prefix+"node_2",OBJPROP_SELECTED,true);
      ObjectSetString(0,prefix+"node_2",OBJPROP_TOOLTIP,"Node 2");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetStartPoint()
  {
   if(ObjectFind(0,prefix+"node_1")!=WRONG_VALUE)
      return BarShift(NULL,PERIOD_CURRENT,ObjectGetInteger(0,prefix+"node_1",OBJPROP_TIME));
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetEndPoint()
  {
   if(ObjectFind(0,prefix+"node_2")!=WRONG_VALUE)
      return BarShift(NULL,PERIOD_CURRENT,ObjectGetInteger(0,prefix+"node_2",OBJPROP_TIME));
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Возвращает смещение бара по времени                              |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time,bool exact=false)
  {
   int res=Bars(symbol_name,timeframe,time+1,UINT_MAX);
   if(exact) if((timeframe!=PERIOD_MN1 || time>TimeCurrent()) && res==Bars(symbol_name,timeframe,time-PeriodSeconds(timeframe)+1,UINT_MAX)) return(WRONG_VALUE);
   return(res);
  }
//+------------------------------------------------------------------+
//| Рассчитывает линию                                               |
//+------------------------------------------------------------------+
bool Calculate(const int rates_total)
  {
//--- Подготовка данных
   ArrayInitialize(BufferMA,0);
   int copied=CopyBuffer(handle_ma,0,0,rates_total,BufferMA);
   if(copied!=rates_total) return false;
//---
   ArrayInitialize(BufferRegression,EMPTY_VALUE);
   int StartBar=GetStartPoint();
   int EndBar=GetEndPoint();
   if(StartBar<EndBar)
     {
      int A=StartBar;
      StartBar=EndBar;
      EndBar=A;
     }
   if(StartBar<3) StartBar=3;
   if(EndBar<0) EndBar=0;
   int length=(StartBar-EndBar<3 ? 3 : StartBar-EndBar);
//--- Подготовка данных
   double summ_x_value[21],summ_y_value[11],constant[11],matrix[11][11];
   ArrayInitialize(summ_x_value,0);
   ArrayInitialize(summ_y_value,0);
   ArrayInitialize(constant,0);
   ArrayInitialize(matrix,0);

   double summ=0,summ_x=0,summ_y=0;
   int pos=StartBar-1;
   summ_x_value[0]=length;
   for(int exp_n=1; exp_n<=2*power; exp_n++)
     {
      summ_x=0;
      summ_y=0;
      for(int k=1; k<=length; k++)
        {
         summ_x+=MathPow(k,exp_n);
         if(exp_n==1)
            summ_y+=BufferMA[pos-k+1];
         else if(exp_n<=power+1)
                        summ_y+=BufferMA[pos-k+1]*MathPow(k,exp_n-1);
        }
      summ_x_value[exp_n]=summ_x;
      if(summ_y!=0)
         summ_y_value[exp_n-1]=summ_y;
     }

   for(int row=0; row<=power; row++)
      for(int col=0; col<=power; col++)
         matrix[row][col]=summ_x_value[row+col];

   int initial_row=1;
   int initial_col=1;
   for(int i=1; i<=power; i++)
     {
      for(int row=initial_row; row<=power; row++)
        {
         summ_y_value[row]=summ_y_value[row]-(matrix[row][i-1]/matrix[i-1][i-1])*summ_y_value[i-1];
         for(int col=initial_col; col<=power; col++)
            matrix[row][col]=matrix[row][col]-(matrix[row][i-1]/matrix[i-1][i-1])*matrix[i-1][col];
        }
      initial_col++;
      initial_row++;
     }
   int j=0;
   for(int i=power; i>=0; i--)
     {
      if(j==0)
         constant[i]=summ_y_value[i]/matrix[i][i];
      else
        {
         summ=0;
         for(int k=j; k>=1; k--)
            summ+=constant[i+k]*matrix[i][i+k];
         constant[i]=(summ_y_value[i]-summ)/matrix[i][i];
        }
      j++;
     }
   int k=1;
   for(int i=StartBar; i>=EndBar; i--)
     {
      summ=0;
      for(int n=0; n<=power; n++)
         summ+=constant[n]*MathPow(k,n);
      BufferRegression[i]=(summ);
      k++;
     }
   ChartRedraw();
   return true;
  }
//+------------------------------------------------------------------+
