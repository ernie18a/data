//+------------------------------------------------------------------+
//|                                                ZigZag_2_Line.mq5 |
//|Added lines - https://www.mql5.com/ru/users/ich_hub 16.05.2017    |
//+------------------------------------------------------------------+
//|                                                       ZigZag.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.3"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
//---- plot Zigzag
#property indicator_label1  "Zigzag"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      ExtDepth=12;
input int      ExtDeviation=5;
input int      ExtBackstep=3;
input bool     ObjLineDel=true;
//--- indicator buffers
double         ZigzagBuffer[];      // main buffer
double         HighMapBuffer[];     // highs
double         LowMapBuffer[];      // lows
int            level=3;             // recounting depth
double         deviation;           // deviation in points
double         price_zig[10];        // Last Point Buffer Price
datetime       time_zig[10];         // Last Point Buffer Time 
double         pr_1=0,pr_2=0;
datetime       t_1=0,t_2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigzagBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighMapBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,LowMapBuffer,INDICATOR_CALCULATIONS);

//--- set short name and digits  
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag("+(string)ExtDepth+","+(string)ExtDeviation+","+(string)ExtBackstep+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- to use in cycle
   deviation=ExtDeviation*_Point;

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjLineDel)
     {
      ObjectDelete(0,"ZZCR1");
      ObjectDelete(0,"ZZCR2");
     }
  }
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[],
             int depth,
             int startPos)
  {
   int index=startPos;
//--- start index validation
   if(startPos<0)
     {
      Print("Invalid parameter in the function iHighest, startPos =",startPos);
      return 0;
     }
   int size=ArraySize(array);
//--- depth correction if need
   if(startPos-depth<0) depth=startPos;
   double max=array[startPos];
//--- start searching
   for(int i=startPos;i>startPos-depth;i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//--- return index of the highest bar
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double &array[],
            int depth,
            int startPos)
  {
   int index=startPos;
//--- start index validation
   if(startPos<0)
     {
      Print("Invalid parameter in the function iLowest, startPos =",startPos);
      return 0;
     }
   int size=ArraySize(array);
//--- depth correction if need
   if(startPos-depth<0) depth=startPos;
   double min=array[startPos];
//--- start searching
   for(int i=startPos;i>startPos-depth;i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//--- return index of the lowest bar
   return(index);
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
   ArraySetAsSeries(ZigzagBuffer,false);
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(low,false);
   int i=0;
   int limit=0,counterZ=0,whatlookfor=0;
   int shift=0,back=0,lasthighpos=0,lastlowpos=0;
   double val=0,res=0;
   double curlow=0,curhigh=0,lasthigh=0,lastlow=0;
//--- auxiliary enumeration
   enum looling_for
     {
      Pike=1,  // searching for next high
      Sill=-1  // searching for next low
     };
//--- initializing
   if(prev_calculated==0)
     {
      ArrayInitialize(ZigzagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      ArrayInitialize(price_zig,0.0);
      ArrayInitialize(time_zig,0.0);
     }
//--- set start position for calculations
   if(prev_calculated==0) limit=ExtDepth;
   if(rates_total<100) return(0);
//--- ZigZag was already counted before
   if(prev_calculated>0)
     {
      i=rates_total-1;
      //--- searching third extremum from the last uncompleted bar
      while(counterZ<level && i>rates_total-100)
        {
         res=ZigzagBuffer[i];
         if(res!=0) counterZ++;
         i--;
        }
      i++;
      limit=i;

      //--- what type of exremum we are going to find
      if(LowMapBuffer[i]!=0)
        {
         curlow=LowMapBuffer[i];
         whatlookfor=Pike;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=Sill;
        }
      //--- chipping
      for(i=limit+1;i<rates_total;i++)
        {
         ZigzagBuffer[i]=0.0;
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }

//--- searching High and Low
   for(shift=limit;shift<rates_total;shift++)
     {
      val=low[iLowest(low,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         if((low[shift]-val)>deviation) val=0.0;
         else
           {
            for(back=1;back<=ExtBackstep;back++)
              {
               res=LowMapBuffer[shift-back];
               if((res!=0) && (res>val)) LowMapBuffer[shift-back]=0.0;
              }
           }
        }
      if(low[shift]==val) LowMapBuffer[shift]=val; else LowMapBuffer[shift]=0.0;
      //--- high
      val=high[iHighest(high,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         if((val-high[shift])>deviation) val=0.0;
         else
           {
            for(back=1;back<=ExtBackstep;back++)
              {
               res=HighMapBuffer[shift-back];
               if((res!=0) && (res<val)) HighMapBuffer[shift-back]=0.0;
              }
           }
        }
      if(high[shift]==val) HighMapBuffer[shift]=val; else HighMapBuffer[shift]=0.0;
     }

//--- last preparation
   if(whatlookfor==0)// uncertain quantity
     {
      lastlow=0;
      lasthigh=0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }

//--- final rejection
   for(shift=limit;shift<rates_total;shift++)
     {
      res=0.0;
      switch(whatlookfor)
        {
         case 0: // search for peak or lawn
            if(lastlow==0 && lasthigh==0)
              {
               if(HighMapBuffer[shift]!=0)
                 {
                  lasthigh=high[shift];
                  lasthighpos=shift;
                  whatlookfor=Sill;
                  ZigzagBuffer[shift]=lasthigh;
                  res=1;
                 }
               if(LowMapBuffer[shift]!=0)
                 {
                  lastlow=low[shift];
                  lastlowpos=shift;
                  whatlookfor=Pike;
                  ZigzagBuffer[shift]=lastlow;
                  res=1;
                 }
              }
            break;
         case Pike: // search for peak
            if(LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               ZigzagBuffer[shift]=lastlow;
               res=1;
              }
            if(HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               ZigzagBuffer[shift]=lasthigh;
               whatlookfor=Sill;
               res=1;
              }
            break;
         case Sill: // search for lawn
            if(HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               ZigzagBuffer[shift]=lasthigh;
              }
            if(LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               ZigzagBuffer[shift]=lastlow;
               whatlookfor=Pike;
              }
            break;
         default: return(rates_total);
        }
     }

//Let's find our points
   bool fl_stop=false;
   shift=0;
   int  n=0;
   bool fl_low=false;
   ArraySetAsSeries(ZigzagBuffer,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(low,true);
   while(!fl_stop && !IsStopped())
     {
      if(ZigzagBuffer[shift]!=0)
        {
         if(n>0)
           {
            if((ND(ZigzagBuffer[shift])-ND(low[shift])==0.0))
              {
               price_zig[n]=ZigzagBuffer[shift];
               if((n-1)==0) fl_low=true;
              }
            else
              {
               price_zig[n]=ZigzagBuffer[shift];
              }
            time_zig[n]=iTimeMQL4(Symbol(),Period(),shift);
           }
         n++;
         if(n>=6) fl_stop=true;
        }
      shift++;
     }

//Draw the lines
   if(fl_low)
     {
      SetLowZZ(price_zig[2],price_zig[4],time_zig[2],time_zig[4]);
      SetHighZZ(price_zig[1],price_zig[3],time_zig[1],time_zig[3]);
     }
   else
     {
      SetLowZZ(price_zig[1],price_zig[3],time_zig[1],time_zig[3]);
      SetHighZZ(price_zig[2],price_zig[4],time_zig[2],time_zig[4]);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+-------------------------------------------------------------------------------------+
//| Converting values to the accuracy of one item                                       |
//+-------------------------------------------------------------------------------------+
double ND(double A)
  {
   return(NormalizeDouble(A, _Digits));
  }
//+------------------------------------------------------------------+
//|  https://www.mql5.com/ru/articles/81                             |
//+------------------------------------------------------------------+
datetime iTimeMQL4(string symbol,int tf,int index)
  {
   if(index < 0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[];
   if(CopyTime(symbol,timeframe,index,1,Arr)>0)
      return(Arr[0]);
   else return(-1);
  }
//+------------------------------------------------------------------+

//=================================================================================================
void SetLowZZ(double price_1,double price_2,datetime time_1,datetime time_2)
  {
   ObjectDelete(0,"ZZCR1");
   ObjectCreate(0,"ZZCR1",OBJ_TREND,0,time_2,price_2,time_1,price_1);
   ObjectSetInteger(0,"ZZCR1",OBJPROP_COLOR,clrAqua);
   ObjectSetInteger(0,"ZZCR1",OBJPROP_WIDTH,2);
   ObjectSetInteger(0,"ZZCR1",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"ZZCR1",OBJPROP_BACK,false);
   ObjectSetInteger(0,"ZZCR1",OBJPROP_RAY_RIGHT,true);
  }
//=================================================================================================
void SetHighZZ(double price_1,double price_2,datetime time_1,datetime time_2)
  {
   ObjectDelete(0,"ZZCR2");
   ObjectCreate(0,"ZZCR2",OBJ_TREND,0,time_2,price_2,time_1,price_1);
   ObjectSetInteger(0,"ZZCR2",OBJPROP_COLOR,clrKhaki);
   ObjectSetInteger(0,"ZZCR2",OBJPROP_WIDTH,2);
   ObjectSetInteger(0,"ZZCR2",OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,"ZZCR2",OBJPROP_BACK,false);
   ObjectSetInteger(0,"ZZCR2",OBJPROP_RAY_RIGHT,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);

      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);
      default: return(PERIOD_CURRENT);
     }
  }
//+------------------------------------------------------------------+
