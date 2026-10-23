//+------------------------------------------------------------------+
//|                                            DemoBufferPattern.mq5 |
//|                             Copyright 2010, Loong@forum.mql4.com |
//|                              https://www.mql5.com/en/users/loong |
//+------------------------------------------------------------------+
#property copyright "2010, Loong@forum.mql4.com"
#property link      "https://www.mql5.com/en/users/loong"
#property version   "1.00"
#property indicator_separate_window
#property indicator_plots   5  //must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 15 //must set, can be bigger than necessary
                                                //BufferPattern
#property indicator_type1   DRAW_COLOR_CANDLES  //DDDDC
#property indicator_type2   DRAW_ARROW          //D
#property indicator_type3   DRAW_ARROW          //D
#property indicator_type4   DRAW_COLOR_ZIGZAG   //DDC
#property indicator_type5   DRAW_COLOR_LINE     //DC
#property indicator_color1  Red,Lime
#property indicator_color2  Red
#property indicator_color3  Lime
#property indicator_color4  Red,Blue
#property indicator_color5  Magenta,Yellow,DeepSkyBlue

//--- input parameters
input int ExtPeriod=10;
//--- input parameters from ZigzagColor.mq5
input int ExtDepth=12;
input int ExtDeviation=5;
input int ExtBackstep=3;
int level=3; // recounting's depth 

double P1B1[];   //  data buffer
double P1B2[];
double P1B3[];
double P1B4[];
double P1BC[];   // color buffer

double P2B1[];   //  data buffer
double P3B1[];   //  data buffer

double P4B1[];   //  data buffer
double P4B2[];   //  data buffer
double P4BC[];   // color buffer
double P4M1[];   //  calc buffer
double P4M2[];   //  calc buffer

double P5B1[];   //  data buffer
double P5BC[];   // color buffer

//--- 10 pixels upper from high price
int    iArrowShift=10;
int    maHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer( 0,P1B1,INDICATOR_DATA);
   SetIndexBuffer( 1,P1B2,INDICATOR_DATA);
   SetIndexBuffer( 2,P1B3,INDICATOR_DATA);
   SetIndexBuffer( 3,P1B4,INDICATOR_DATA);
   SetIndexBuffer( 4,P1BC,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 5,P2B1,INDICATOR_DATA);
   SetIndexBuffer( 6,P3B1,INDICATOR_DATA);
   SetIndexBuffer( 7,P4B1,INDICATOR_DATA);
   SetIndexBuffer( 8,P4B2,INDICATOR_DATA);
   SetIndexBuffer( 9,P4BC,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,P5B1,INDICATOR_DATA);
   SetIndexBuffer(11,P5BC,INDICATOR_COLOR_INDEX);
//--- Auxiliary buffers for intermediate calculations
   SetIndexBuffer(12,P4M1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,P4M2,INDICATOR_CALCULATIONS);
//--- They should be placed after all the buffer to be displayed, or else ... you can try it by youself

//--- ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,217);
   PlotIndexSetInteger(2,PLOT_ARROW,218);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-iArrowShift);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,iArrowShift);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- ZIGZAG
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//--- MA
   maHandle=iMA(Symbol(),0,ExtPeriod,0,MODE_EMA,PRICE_CLOSE);

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//---
   CalcCandles(rates_total,prev_calculated,open,high,low,close);
   CalcFractal(rates_total,prev_calculated,high,low,P2B1,P3B1);
   CalcZigzag (rates_total,prev_calculated,high,low,P4B1,P4B2,P4BC,P4M1,P4M2);
   CalcColorMA(rates_total,prev_calculated,P5B1,P5BC);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
int CalcCandles(const int rates_total,
                const int prev_calculated,
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[])
  {
//--- auxiliary variables
   int i=0;
//--- set position for beginning
   if(i<prev_calculated) i=prev_calculated-1;
//--- start calculations
   while(i<rates_total)
     {
      P1B1[i]=open[i];
      P1B2[i]=high[i];
      P1B3[i]=low[i];
      P1B4[i]=close[i];
      P1BC[i]=(double)((close[i]>open[i])?0:1);
      i++;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
int CalcFractal(const int rates_total,
                const int prev_calculated,
                const double &High[],
                const double &Low[],
                double &Upper[],
                double &Lower[])
  {
   int i,limit;
//---
   if(rates_total<5)
      return(0);
//---
   if(prev_calculated<7)
     {
      limit=2;
      //--- clean up arrays
      ArrayInitialize(Upper,EMPTY_VALUE);
      ArrayInitialize(Lower,EMPTY_VALUE);
     }
   else limit=rates_total-5;

   for(i=limit;i<rates_total-3;i++)
     {
      //---- Upper Fractal
      if(High[i]>High[i+1] && High[i]>High[i+2] && High[i]>=High[i-1] && High[i]>=High[i-2])
         Upper[i]=High[i];
      else Upper[i]=EMPTY_VALUE;
      //---- Lower Fractal
      if(Low[i]<Low[i+1] && Low[i]<Low[i+2] && Low[i]<=Low[i-1] && Low[i]<=Low[i-2])
         Lower[i]=Low[i];
      else Lower[i]=EMPTY_VALUE;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double&array[],int range,int fromIndex)
  {
   double res;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res<array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double&array[],int range,int fromIndex)
  {
   double res;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Detrended Price Oscillator                                       |
//+------------------------------------------------------------------+
int CalcZigzag(const int rates_total,const int prev_calculated,
                const double &High[],
                const double &Low[],
                double &ZigzagPeakBuffer[],
                double &ZigzagLawnBuffer[],
                double &ColorBuffer[],
                double &HighMapBuffer[],
                double &LowMapBuffer[])
  {
   int i,limit=0;
//--- check for rates count
   if(rates_total<100)
     {
      //--- clean up arrays
      ArrayInitialize(ZigzagPeakBuffer,0.0);
      ArrayInitialize(ZigzagLawnBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      ArrayInitialize(ColorBuffer,0.0);
      //--- exit with zero result
      return(0);
     }
//--- preliminary calculations
   int counterZ=0,whatlookfor=0;
   int shift,back=0,lasthighpos=0,lastlowpos=0;
   double val=0,res=0;
   double curlow=0,curhigh=0,lasthigh=0,lastlow=0;
//--- set empty values
   if(prev_calculated==0)
     {
      ArrayInitialize(ZigzagPeakBuffer,0.0);
      ArrayInitialize(ZigzagLawnBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
      //--- start calculation from bar number ExtDepth
      limit=ExtDepth-1;
     }
//---
   if(prev_calculated>0)
     {
      i=rates_total-1;
      while(counterZ<level && i>rates_total -100)
        {
         res=(ZigzagPeakBuffer[i]+ZigzagLawnBuffer[i]);
         //---
         if(res!=0) counterZ++;
         i--;
        }
      i++;
      limit=i;
      //---
      if(LowMapBuffer[i]!=0)
        {
         curlow=LowMapBuffer[i];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=-1;
        }
      //---
      for(i=limit+1;i<rates_total;i++)
        {
         ZigzagPeakBuffer[i]=0.0;
         ZigzagLawnBuffer[i]=0.0;
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }
//----
   for(shift=limit;shift<rates_total;shift++)
     {

      val=Lowest(Low,ExtDepth,shift);
      //---
      if(val==lastlow) val=0.0;
      else
        {
         lastlow=val;
         //---
         if((Low[shift]-val)>(ExtDeviation*_Point)) val=0.0;
         else
           {
            //---
            for(back=ExtBackstep;back>=1;back--)
              {
               res=LowMapBuffer[shift-back];
               //---
               if((res!=0) && (res>val)) LowMapBuffer[shift-back]=0.0;
              }
           }
        }
      //---
      if(Low[shift]==val) LowMapBuffer[shift]=val;
      else
         LowMapBuffer[shift]=0.0;
      //--- high
      val=Highest(High,ExtDepth,shift);
      //---
      if(val==lasthigh) val=0.0;
      else
        {
         lasthigh=val;
         //---
         if((val-High[shift])>(ExtDeviation*_Point)) val=0.0;
         else
           {
            //---
            for(back=ExtBackstep;back>=1;back--)
              {
               res=HighMapBuffer[shift-back];
               //---
               if((res!=0) && (res<val)) HighMapBuffer[shift-back]=0.0;
              }
           }
        }
      //---
      if(High[shift]==val) HighMapBuffer[shift]=val;
      else  HighMapBuffer[shift]=0.0;
     }
// final cutting 
   if(whatlookfor==0)
     {
      lastlow=0;
      lasthigh=0;
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
//----
   for(shift=limit;shift<rates_total;shift++)
     {
      res=0.0;
      switch(whatlookfor)
        {
         // look for peak or lawn 
         case 0: if(lastlow==0 && lasthigh==0)
           {
            if(HighMapBuffer[shift]!=0)
              {
               lasthigh=High[shift];
               lasthighpos=shift;
               whatlookfor=-1;
               ZigzagPeakBuffer[shift]=lasthigh;
               ColorBuffer[shift]=0;
               res=1;
              }
            if(LowMapBuffer[shift]!=0)
              {
               lastlow=Low[shift];
               lastlowpos=shift;
               whatlookfor=1;
               ZigzagLawnBuffer[shift]=lastlow;
               ColorBuffer[shift]=1;
               res=1;
              }
           }
         break;
         // look for peak
         case 1: if(LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && 
                    HighMapBuffer[shift]==0.0)
           {
            ZigzagLawnBuffer[lastlowpos]=0.0;
            lastlowpos=shift;
            lastlow=LowMapBuffer[shift];
            ZigzagLawnBuffer[shift]=lastlow;
            ColorBuffer[shift]=1;
            res=1;
           }
         if(HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
           {
            lasthigh=HighMapBuffer[shift];
            lasthighpos=shift;
            ZigzagPeakBuffer[shift]=lasthigh;
            ColorBuffer[shift]=0;
            whatlookfor=-1;
            res=1;
           }
         break;
         // look for lawn
         case -1:  if(HighMapBuffer[shift]!=0.0 && 
                      HighMapBuffer[shift]>lasthigh && 
                      LowMapBuffer[shift]==0.0)
           {
            ZigzagPeakBuffer[lasthighpos]=0.0;
            lasthighpos=shift;
            lasthigh=HighMapBuffer[shift];
            ZigzagPeakBuffer[shift]=lasthigh;
            ColorBuffer[shift]=0;
           }
         if(LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
           {
            lastlow=LowMapBuffer[shift];
            lastlowpos=shift;
            ZigzagLawnBuffer[shift]=lastlow;
            ColorBuffer[shift]=1;
            whatlookfor=1;
           }
         break;
         default: return(rates_total);
        }
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| get color index                                                  |
//+------------------------------------------------------------------+
int getIndexOfColor(int i)
  {
   int j=i%300;
   if(j<100) return(0);// first index
   if(j<200) return(1);// second index
   return(2); // third index
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int CalcColorMA(const int rates_total,
                const int prev_calculated,
                double &ColorLineBuffer[],
                double &ColorsBuffer[])
  {
//--- check data
   int calculated=BarsCalculated(maHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of maHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      //--- copy values of MA into indicator buffer ColorLineBuffer
      if(CopyBuffer(maHandle,0,0,rates_total,ColorLineBuffer)<=0) return(0);
      //--- now set line color for every bar
      for(int i=0;i<rates_total;i++)
         ColorsBuffer[i]=getIndexOfColor(i);
     }
   else
     {
      //--- we can copy not all data
      int to_copy;
      if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
      else
        {
         to_copy=rates_total-prev_calculated;
         if(prev_calculated>0) to_copy++;
        }
      //--- copy values of MA into indicator buffer ColorLineBuffer
      int copied=CopyBuffer(maHandle,0,0,rates_total,ColorLineBuffer);
      if(copied<=0) return(0);
/*
      ticks++;// ticks counting
      if(ticks>=5)//it's time to change color scheme
        {
         ticks=0; // reset counter
         modified++; // counter of color changes
         if(modified>=3)modified=0;// reset counter 
         ResetLastError();
         switch(modified)
           {
            case 0:// first color scheme
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Red);
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Blue);
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Green);
               //Print("Color scheme"+modified);
               break;
            case 1:// second color scheme
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,Yellow);
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Pink);
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,LightSlateGray);
               //Print("Color scheme"+modified);
               break;
            default:// third color scheme
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,LightGoldenrod);
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Orchid);
               PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,LimeGreen);
               //Print("Color scheme"+modified);
           }
        }
      else
        {
         //--- set start position
         limit=prev_calculated-1;
         //--- now we set line color for every bar
         for(int i=limit;i<rates_total;i++)
            ColorsBuffer[i]=getIndexOfColor(i);
        }
*/
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
