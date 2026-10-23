//+------------------------------------------------------------------+
//|                                          XBarClearCloseTrend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   6
//--- plot Arr0
#property indicator_label1  "Strongly up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Arr1
#property indicator_label2  "Up"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Arr2
#property indicator_label3  "Uncertainly up"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrPaleGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Arr3
#property indicator_label4  "Strongly down"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Arr4
#property indicator_label5  "Down"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrTomato
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot Arr5
#property indicator_label6  "Uncertainly down"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrKhaki
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- input parameters
input uint     InpPeriod=5;   // Period
//--- indicator buffers
double         BufferArr0[];
double         BufferArr1[];
double         BufferArr2[];
double         BufferArr3[];
double         BufferArr4[];
double         BufferArr5[];
double         BufferTrend[];
//--- global variables
string         prefix;
int            period;
int            wnd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period=int(InpPeriod<1 ? 1 : InpPeriod);
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
   wnd=ChartWindowFind();
   SizeByScale();
   Descriptions();
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferArr0,INDICATOR_DATA);
   SetIndexBuffer(1,BufferArr1,INDICATOR_DATA);
   SetIndexBuffer(2,BufferArr2,INDICATOR_DATA);
   SetIndexBuffer(3,BufferArr3,INDICATOR_DATA);
   SetIndexBuffer(4,BufferArr4,INDICATOR_DATA);
   SetIndexBuffer(5,BufferArr5,INDICATOR_DATA);
   SetIndexBuffer(6,BufferTrend,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"XBarClearCloseTrend("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_HEIGHT,60);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0; i<6; i++)
      PlotIndexSetInteger(i,PLOT_ARROW,167);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferArr0,true);
   ArraySetAsSeries(BufferArr1,true);
   ArraySetAsSeries(BufferArr2,true);
   ArraySetAsSeries(BufferArr3,true);
   ArraySetAsSeries(BufferArr4,true);
   ArraySetAsSeries(BufferArr5,true);
   ArraySetAsSeries(BufferTrend,true);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period-2;
      ArrayInitialize(BufferArr0,EMPTY_VALUE);
      ArrayInitialize(BufferArr1,EMPTY_VALUE);
      ArrayInitialize(BufferArr2,EMPTY_VALUE);
      ArrayInitialize(BufferArr3,EMPTY_VALUE);
      ArrayInitialize(BufferArr4,EMPTY_VALUE);
      ArrayInitialize(BufferArr5,EMPTY_VALUE);
      ArrayInitialize(BufferTrend,EMPTY_VALUE);
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferTrend[i]=BufferTrend[i+1];
      BufferArr0[i]=EMPTY_VALUE;
      BufferArr1[i]=EMPTY_VALUE;
      BufferArr2[i]=EMPTY_VALUE;
      BufferArr3[i]=EMPTY_VALUE;
      BufferArr4[i]=EMPTY_VALUE;
      BufferArr5[i]=EMPTY_VALUE;

      if(BufferTrend[i+1]==1)
        {
         if(IsBarUp(high,close,i))
            BufferArr0[i]=1;
         else
           {
            if(IsBarDn(low,close,i))
               BufferArr3[i]=1;
            else
              {
               if(close[i]>=close[i+1])
                 {
                  BufferArr1[i]=1;
                  BufferTrend[i]=-1;
                 }
               else
                  BufferArr2[i]=1;
              }
           }
        }
      else
        {
         if(IsBarDn(low,close,i))
            BufferArr3[i]=1;
         else
           {
            if(IsBarUp(high,close,i))
              {
               BufferArr0[i]=1;
               BufferTrend[i]=1;
              }
            else
              {
               if(close[i]<=close[i+1])
                  BufferArr4[i]=1;
               else
                  BufferArr5[i]=1;
              }
           }
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      for(int i=0;i<6;i++)
         PlotIndexSetInteger(i,PLOT_LINE_WIDTH,SizeByScale());
      Descriptions();
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Возвращает размер, соответствующий масштабу                      |
//+------------------------------------------------------------------+
uchar SizeByScale(void)
  {
   uchar scale=(uchar)ChartGetInteger(0,CHART_SCALE);
   uchar size=(scale<3 ? 1 : scale==3 ? 2 : scale==4 ? 5 : 8);
   return size;
  }
//+------------------------------------------------------------------+
//| Возвращает флаг направления вверх за период                      |
//+------------------------------------------------------------------+
bool IsBarUp(const double &high[],const double &close[],const int index)
  {
   for(int i=1; i<period; i++)
      if(high[index+i]>=close[index]) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает флаг направления вниз за период                       |
//+------------------------------------------------------------------+
bool IsBarDn(const double &low[],const double &close[],const int index)
  {
   for(int i=1; i<period; i++)
      if(low[index+i]<=close[index]) return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Описание                                                         |
//+------------------------------------------------------------------+
void Descriptions(void)
  {
   int x=4;
   int y=1;
   int arr_colors[]={indicator_color1,indicator_color2,indicator_color3,indicator_color4,indicator_color5,indicator_color6};
   string arr_texts[]={"Strongly up","Up","Uncertainly up","Strongly down","Down","Uncertainly down"};
   string arr_names[6];
   for(int i=0; i<6; i++)
     {
      arr_names[i]=prefix+"label"+(string)i;
      arr_colors[i]=PlotIndexGetInteger(i,PLOT_LINE_COLOR);
      x=(i==0 ? x : i==1 ? 80 : i==2 ? 110 : i==3 ? 210 : i==4 ? 300 : 346);
      Label(arr_names[i],x,y,CharToString(167),16,arr_colors[i],"Wingdings");
      Label(arr_names[i]+"_txt",x+10,y+5,arr_texts[i],10,clrGray,"Calibri");
     }
  }
//+------------------------------------------------------------------+
//| Выводит текстовую метку                                          |
//+------------------------------------------------------------------+
void Label(const string name,const int x,const int y,const string text,const int size,const color clr,const string font)
  {
   if(ObjectFind(0,name)!=wnd)
      ObjectCreate(0,name,OBJ_LABEL,wnd,0,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
//---
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
  }
//+------------------------------------------------------------------+
