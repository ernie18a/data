//+---------------------------------------------------------------------+
//|                                    Normalized_Volume_Oscillator.mq5 | 
//|                                   Copyright © 2007, Vadim Shumiloff | 
//|                                                   shumiloff@mail.ru | 
//+---------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, Vadim Shumilov (DrShumiloff)"
#property link "shumiloff@mail.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a color histogram
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- the following colors are used for the indicator
#property indicator_color1 clrDodgerBlue,clrGreen,clrLime,clrDarkOrange,clrYellow
//---- indicator line width is equal to 1
#property indicator_width1  3
//---- displaying the indicator label
#property indicator_label1  "Normalized_Volume_Oscillator"
//+----------------------------------------------+
//| Parameters of displaying horizontal levels   |
//+----------------------------------------------+
#property indicator_level1  1
#property indicator_levelcolor clrMagenta
#property indicator_levelstyle STYLE_DASHDOTDOT

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input uint VolumePeriod=12;                        // smoothing depth                    
//+-----------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtBuffer[],ColorExtBuffer[];

//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+   
//| NormalizedVolume indicator initialization function               | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=int(VolumePeriod);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- set dynamic array as as a color index buffer   
   SetIndexBuffer(1,ColorExtBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Normalized_Volume_Oscillator(",VolumePeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator function NormalizedVolume                       |
//+------------------------------------------------------------------+  
double NormalizedVolume(int index,const long &Tick_Volume[],const long &Volume[])
  {
//----
   if(VolumeType==VOLUME_REAL)
     {
      double nv=0;
      for(int kkk=int(index-VolumePeriod+1); kkk<=index; kkk++) nv+=double(Volume[kkk]);
      nv/=VolumePeriod;
      return(Volume[index]/nv);
     }
   else
     {
      double nv=0;
      for(int kkk=int(index-VolumePeriod+1); kkk<=index; kkk++) nv+=double(Tick_Volume[kkk]);
      nv/=VolumePeriod;
      return(Tick_Volume[index]/nv);
     }
//----
  }
//+------------------------------------------------------------------+ 
//| NormalizedVolume iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of variables with a floating point  
   double nvo;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar,clr;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=min_rates_total; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for the calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      nvo=double(NormalizedVolume(bar,tick_volume,volume)*100-100);
      ExtBuffer[bar]=nvo;

      if(nvo<0) clr=0;
      else
        {
         if(nvo<38.2) clr=1;
         else
           {
            if(nvo<61.8) clr=2;
            else
              {
               if(nvo<100.0) clr=3;
               else clr=4;
              }
           }
        }
        
      ColorExtBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
