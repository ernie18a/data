//+------------------------------------------------------------------+
//|                                                    GapFinder.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot LineToUpUP
#property indicator_label1  "Upper up area"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LineToUpDN
#property indicator_label2  "Lower up area"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot LineToDnUP
#property indicator_label3  "Upper down area"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot LineToDnDN
#property indicator_label4  "Lower down area"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

//--- plot arrow up
#property indicator_label5  "Arrow up"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrDodgerBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- plot arrow down
#property indicator_label6  "Arrow down"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- enums
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
//--- input parameters
input uint              InpMinGapSize  =  2;                   // Minimum gap size (in points)
input ENUM_INPUT_YES_NO InpDrawArea    =  INPUT_YES;           // Whether to draw a gap area
input color             InpColorToUP   =  clrMediumTurquoise;  // Color of the gap area up
input color             InpColorToDN   =  clrGold;             // Color of the gap area down
//--- indicator buffers
double                  BufferLineToUpUP[];
double                  BufferLineToUpDN[];
double                  BufferLineToDnUP[];
double                  BufferLineToDnDN[];
double                  BufferArrowUP[];
double                  BufferArrowDN[];
//--- global variables
double                  min_gap_size;
string                  prefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   min_gap_size=(InpMinGapSize<1 ? 1 : InpMinGapSize)*Point();
   prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_";
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferLineToUpUP,INDICATOR_DATA);
   SetIndexBuffer(1,BufferLineToUpDN,INDICATOR_DATA);
   SetIndexBuffer(2,BufferLineToDnUP,INDICATOR_DATA);
   SetIndexBuffer(3,BufferLineToDnDN,INDICATOR_DATA);
   SetIndexBuffer(4,BufferArrowUP,INDICATOR_DATA);
   SetIndexBuffer(5,BufferArrowDN,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(4,PLOT_ARROW,241);
   PlotIndexSetInteger(5,PLOT_ARROW,242);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Gap finder("+(string)min_gap_size+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferLineToUpUP,true);
   ArraySetAsSeries(BufferLineToUpDN,true);
   ArraySetAsSeries(BufferLineToDnUP,true);
   ArraySetAsSeries(BufferLineToDnDN,true);
   ArraySetAsSeries(BufferArrowUP,true);
   ArraySetAsSeries(BufferArrowDN,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,prefix);
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<4) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-5;
      BuffersInitialize();
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
   //--- Гэп вверх
      if(low[i]-high[i+1]>=min_gap_size)
        {
         BufferArrowUP[i]=high[i+1];
         //--- Если на прошлом баре есть стрелка
         if(BufferArrowUP[i+1]!=EMPTY_VALUE)
           {
            double up=fmin(open[i+1],close[i+1]);
            double dn=fmax(open[i+2],close[i+2]);
            //--- Стереть линии соседнего гэпа
            SetGapToUP(0,0,i+2);
           }
         //--- Вывести гэп
         double up=fmin(open[i],close[i]);
         double dn=fmax(open[i+1],close[i+1]);
         SetGapToUP(up,dn,i);
         DrawArea(i,up,dn,time,InpColorToUP,1);
        }
      else
        {
         BufferArrowUP[i]=EMPTY_VALUE;
         if(BufferArrowUP[i+1]==EMPTY_VALUE)
            SetGapToUP(0,0,i);
        }
   //--- Гэп вниз
      if(low[i+1]-high[i]>=min_gap_size)
        {
         BufferArrowDN[i]=low[i+1];
         //--- Если на прошлом баре есть стрелка
         if(BufferArrowDN[i+1]!=EMPTY_VALUE)
           {
            double up=fmin(open[i+2],close[i+2]);
            double dn=fmax(open[i+1],close[i+1]);
            //--- Стереть линии соседнего гэпа
            SetGapToDN(0,0,i+2);
           }
         //--- Вывести гэп
         double up=fmin(open[i+1],close[i+1]);
         double dn=fmax(open[i],close[i]);
         SetGapToDN(up,dn,i);
         DrawArea(i,up,dn,time,InpColorToDN,0);
        }
      else
        {
         BufferArrowDN[i]=EMPTY_VALUE;
         if(BufferArrowDN[i+1]==EMPTY_VALUE)
            SetGapToDN(0,0,i);
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Инициализация буферов                                            |
//+------------------------------------------------------------------+
void BuffersInitialize(void)
  {
   ArrayInitialize(BufferLineToUpUP,EMPTY_VALUE);
   ArrayInitialize(BufferLineToUpDN,EMPTY_VALUE);
   ArrayInitialize(BufferLineToDnUP,EMPTY_VALUE);
   ArrayInitialize(BufferLineToDnDN,EMPTY_VALUE);
   ArrayInitialize(BufferArrowUP,EMPTY_VALUE);
   ArrayInitialize(BufferArrowDN,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Устанавливает значения "гэп вверх"                               |
//+------------------------------------------------------------------+
void SetGapToUP(const double price_up,const double price_dn,const int shift)
  {
   BufferLineToUpUP[shift]=BufferLineToUpUP[shift+1]=(price_up>0 ? price_up : EMPTY_VALUE);
   BufferLineToUpDN[shift]=BufferLineToUpDN[shift+1]=(price_dn>0 ? price_dn : EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Устанавливает значения "гэп вниз"                                |
//+------------------------------------------------------------------+
void SetGapToDN(const double price_up,const double price_dn,const int shift)
  {
   BufferLineToDnUP[shift]=BufferLineToDnUP[shift+1]=(price_up>0 ? price_up : EMPTY_VALUE);
   BufferLineToDnDN[shift]=BufferLineToDnDN[shift+1]=(price_dn>0 ? price_dn : EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Рисует область                                                   |
//+------------------------------------------------------------------+
void DrawArea(const int index, const double price_up,const double price_dn,const datetime &time[],const color color_area,const char dir)
  {
   if(!InpDrawArea) return;
   string name=prefix+(dir>0 ? "up_" : "dn_")+TimeToString(time[index]);
   if(ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_RECTANGLE,0,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_FILL,true);
   ObjectSetInteger(0,name,OBJPROP_BACK,true);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,"\n");
   //---
   ObjectSetInteger(0,name,OBJPROP_COLOR,color_area);
   ObjectSetInteger(0,name,OBJPROP_TIME,0,time[index+1]);
   ObjectSetInteger(0,name,OBJPROP_TIME,1,time[index]);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,price_up);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,price_dn);
  }
//+------------------------------------------------------------------+
