

//+------------------------------------------------------------------+
//|                                                  rvmGann_sv8.mq4 |
//|                                        Copyright © 2005, Profi_R |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2005, Profi_R"
//--- a link to the website of the author
#property link      "https://www.metaquotes.net/"
//--- indicator version
#property version   "1.01"
#property description "The indicator implements the Gann principle in the form of a zigzag"
//+----------------------------------------------+ 
//| Indicator drawing parameters                 |
//+----------------------------------------------+ 
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- eight buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 8
//--- only 1 plot is used
#property indicator_plots   1
//--- ZIGZAG is used for the indicator
#property indicator_type1   DRAW_ZIGZAG
//--- displaying the indicator label
#property indicator_label1  "rvmGann_sv8"
//--- DodgerBlue color is used for the indicator line color
#property indicator_color1 clrDodgerBlue
//--- the indicator line is a long dashed line
#property indicator_style1  STYLE_SOLID
//--- indicator line width is 2
#property indicator_width1  2
//+----------------------------------------------+ 
//| Indicator input parameters                   |
//+----------------------------------------------+ 
input uint GSv_tend=2;
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double Upz[];
double Dnz[];
double sH[];
double sL[];
double aH[];
double aL[];
double fB[];
double lB[];
//---
double CurH,CurL;
int lb,sp,lbars;
bool draw_up,draw_dn;
//--- declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=2;
   CurH=0.0;
   CurL=0.0;
   lb=0;
   sp=0;
   lbars=0;
   draw_up=false;
   draw_dn=false;
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- set the position, from which the drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,Upz,INDICATOR_DATA);
   SetIndexBuffer(1,Dnz,INDICATOR_DATA);
   SetIndexBuffer(2,sH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,sL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,aH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,aL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,fB,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,lB,INDICATOR_CALCULATIONS);
//---- Indexing buffer elements as timeseries   
   ArraySetAsSeries(Upz,true);
   ArraySetAsSeries(Dnz,true);
   ArraySetAsSeries(sH,true);
   ArraySetAsSeries(sL,true);
   ArraySetAsSeries(aH,true);
   ArraySetAsSeries(aL,true);
   ArraySetAsSeries(fB,true);
   ArraySetAsSeries(lB,true);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   IndicatorSetString(INDICATOR_SHORTNAME,"rvmGann_sv8");
//---   
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int limit,bar,ai,last,prev_calculated_;
   prev_calculated_=MathMax(0,prev_calculated);
//--- calculate the limit starting number for loop of bars recalculation and start initialization of variables
   last=rates_total-1;
   if(last-prev_calculated_<2)
     {
      limit=0;
     }
   else
     {
      limit=last-prev_calculated_-1;
     }
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      sH[bar]=0.0;
      sL[bar]=0.0;
      aH[bar]=-1.0;
      aL[bar]=-1.0;
      fB[bar]=-1.0;
      lB[bar]=-1.0;
      Upz[bar]=0.0;
      Dnz[bar]=0.0;

      ai=last-bar;
      if(lbars!=rates_total && lb==ai)
        {
         lbars=rates_total;
         continue;
        }

      if(lb!=ai)
        {
         lb=ai;
         if(Upz[bar+1]>0 || Dnz[bar+1]>0)
           {
            aH[bar]=high[bar+1];
            aL[bar]=low[bar+1];
           }
         else
           {
            if(high[bar+1]<=aH[bar+1] && low[bar+1]>=aL[bar+1])
              {
               aH[bar]=aH[bar+1];
               aL[bar]=aL[bar+1];
               sH[bar]=sH[bar+1];
               sL[bar]=sL[bar+1];
              }
            else
              {
               if(high[bar+1]>aH[bar+1])
                 {
                  aH[bar]=high[bar+1];
                 }
               else
                 {
                  aH[bar]=aH[bar+1];
                 }
               if(aL[bar+1]>0)
                 {
                  if(low[bar+1]<aL[bar+1])
                    {
                     aL[bar]=low[bar+1];
                    }
                  else
                    {
                     aL[bar]=aL[bar+1];
                    }
                 }
               else
                 {
                  aL[bar]=low[bar+1];
                 }
              }
           }
         if(draw_up)
           {
            if(fB[bar+1]==1)
              {
               sH[bar]=sH[bar+1]+1;
               if(lB[bar+1]==0)
                 {
                  sH[bar]=0;
                  sL[bar]=1;
                 }
              }
            else
              {
               if(fB[bar+1]==0)
                 {
                  sL[bar]=sL[bar+1]+1;
                  if(lB[bar+1]==1)
                    {
                     sH[bar]=1;
                     sL[bar]=0;
                    }
                 }
              }
           }
         else
           {
            if(draw_dn)
              {
               if(fB[bar+1]==0)
                 {
                  sL[bar]=sL[bar+1]+1;
                  if(lB[bar+1]==1)
                    {
                     sH[bar]=1;
                     sL[bar]=0;
                    }
                 }
               else
                 {
                  if(fB[bar+1]==1)
                    {
                     sH[bar]=sH[bar+1]+1;
                     if(lB[bar+1]==0)
                       {
                        sH[bar]=0;
                        sL[bar]=1;
                       }
                    }
                 }
              }
            else
              {
               if(fB[bar+1]==1)
                 {
                  sH[bar]=sH[bar+1]+1;
                  sL[bar]=sL[bar+1];
                  if(lB[bar+1]==0)
                    {
                     sL[bar]++;
                    }
                 }
               else
                 {
                  if(fB[bar+1]==0)
                    {
                     sH[bar]=sH[bar+1];
                     sL[bar]=sL[bar+1]+1;
                     if(lB[bar+1]==1)
                       {
                        sH[bar]++;
                       }
                    }
                 }
              }
           }
         if(GSv_tend>1)
           {
            //if on the previous candlestick refraction goes up and it is external to the previous + the last minimum
            if(sH[bar]==GSv_tend && Upz[bar+1]>0 && high[bar+1]>high[bar+2] && low[bar+1]<low[bar+2] && fB[bar+1]==1)
              {
               sL[bar]=1;
              }
            else //if on the previous candlestick the counter had refraction up
              {
               //if on the previous candlestick refraction goes down and it is external to the previous + the last maximum
               if(sL[bar]==GSv_tend && Dnz[bar+1]>0 && high[bar+1]>high[bar+2] && low[bar+1]<low[bar+2] && fB[bar+1]==0)
                 {
                  sH[bar]=1;
                 }
              }
           }
         //Zero out
         CurH=0;
         CurL=low[bar];
        }
      if(high[bar]<=aH[bar] && low[bar]>=aL[bar]) continue;
      if(high[bar]<=CurH && low[bar]>=CurL) continue;
      if(high[bar]>CurH) CurH=high[bar];
      if(low[bar] <CurL) CurL=low[bar];
      Extr_seq(open,high,low,close,bar);
      //if the swing is two or more bars, reset counter of minimums during the first high and reset the counter of maximums during the first low
      if(GSv_tend>1)
        {
         if(fB[bar]>0 && sH[bar]==GSv_tend-1 && sL[bar]>0) sL[bar]=0;
         else if(fB[bar]>-1 && sL[bar]==GSv_tend-1 && sH[bar]>0) sH[bar]=0;
        }

      if(draw_up)
        {
         if(fB[bar]==1)
           {
            if(sp!=ai)
              {
               Upz[MathMax(0,last-sp)]=0;
               sp=ai;
              }
            Upz[bar]=high[bar];
            if(lB[bar]==0 && (sL[bar]+1)>=GSv_tend && GSv_tend<2)
              {
               Dnz[bar]=low[bar];
               draw_up=0;
               draw_dn=1;
              }
           }
         else
           {
            if(fB[bar]==0)
              {
               if((sL[bar]+1)>=GSv_tend)
                 {
                  Dnz[bar]=low[bar];
                  sp=ai;
                  draw_up=0;
                  draw_dn=1;
                  if(lB[bar]==1 && (sH[bar]+1)>=GSv_tend)
                    {
                     Upz[bar]=high[bar];
                     draw_up=1;
                     draw_dn=0;
                    }
                 }
               else
                 {
                  if(lB[bar]==1)
                    {
                     Upz[MathMax(0,last-sp)]=0;
                     sp=ai;
                     Upz[bar]=high[bar];
                    }
                 }
              }
           }
        }
      else
        {
         if(draw_dn)
           {
            if(fB[bar]==1)
              {
               if((sH[bar]+1)>=GSv_tend)
                 {
                  Upz[bar]=high[bar];
                  sp=ai;
                  draw_up=1;
                  draw_dn=0;
                  if(!lB[bar] && (sL[bar]+1)>=GSv_tend)
                    {
                     Dnz[bar]=low[bar];
                     draw_up=0;
                     draw_dn=1;
                    }
                 }
               else
                 {
                  if(!lB[bar])
                    {
                     Dnz[MathMax(0,last-sp)]=0;
                     sp=ai;
                     Dnz[bar]=low[bar];
                    }
                 }
              }
            else
              {
               if(!fB[bar])
                 {
                  if(sp!=ai)
                    {
                     Dnz[MathMax(0,last-sp)]=0;
                     sp=ai;
                    }
                  Dnz[bar]=low[bar];
                  if(lB[bar]==1 && (sH[bar]+1)>=GSv_tend && GSv_tend<2)
                    {
                     Upz[bar]=high[bar];
                     draw_up=1;
                     draw_dn=0;
                    }
                 }
              }
           }
         else
           {
            if(fB[bar]==1 && (sH[bar]+1)>=GSv_tend)
              {
               Dnz[last]=low[last];
               Upz[bar]=high[bar];
               draw_up=1;
               sp=ai;
               if(!lB[bar] && (sL[bar]+1)>=GSv_tend)
                 {
                  Dnz[bar]=low[bar];
                  draw_up=0;
                  draw_dn=1;
                 }
              }
            else
              {
               if(!fB[bar] && (sL[bar]+1)>=GSv_tend)
                 {
                  Upz[last]=high[last];
                  Dnz[bar]=low[bar];
                  draw_dn=1;
                  sp=ai;
                  if(lB[bar]==1 && (sH[bar]+1)>=GSv_tend)
                    {
                     Upz[bar]=high[bar];
                     draw_up=1;
                     draw_dn=0;
                    }
                 }
              }
           }
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| The function defines the sequence of appearance of extrema       |
//+------------------------------------------------------------------+
void Extr_seq(const double &Open[],const double &High[],const double &Low[],const double &Close[],int index)
  {
//--- 
   if(fB[index]<0)
     {
      //if a bar is calculated on history and it is external
      if(High[index]>aH[index] && Low[index]<aL[index])
        {
         //if open is on a new maximum
         if(Open[index]>aH[index])
           {
            fB[index]=1;
            lB[index]=0;
           }
         else //otherwise if open on a new maximum
           {
            //if open is on a new minimum
            if(Open[index]<aL[index])
              {
               fB[index]=0;
               lB[index]=1;
              }
            else
              {
               //if close is on a new maximum and is higher than or equal to open
               if(Close[index]>aH[index] && Close[index]>=Open[index])
                 {
                  fB[index]=0;
                  lB[index]=1;
                 }
               else //otherwise if close is on a new maximum and is higher than or equal to open
                 {
                  //if close is on a new minimum and is lower than or equal to open
                  if(Close[index]>aL[index] && Close[index]<=Open[index])
                    {
                     fB[index]=1;
                     lB[index]=0;
                    }
                  else //if close is on a new minimum and is lower than or equal to open
                    {
                     //if clause is higher than open
                     if(Close[index]>Open[index])
                       {
                        fB[index]=0;
                        lB[index]=1;
                       }
                     else //otherwise if clause is higher than open
                       {
                        //if clause is lower than open
                        if(Close[index]<Open[index])
                          {
                           fB[index]=1;
                           lB[index]=0;
                          }
                        else //otherwise if clause is lower than open
                          {
                           //if open is closer to the active minimum
                           if(MathAbs(Open[index]-aL[index])<MathAbs(Open[index]-aH[index]))
                             {
                              fB[index]=0;
                              lB[index]=1;
                             }
                           else //otherwise if open is closer to the active minimum
                             {
                              //if open is closer to the active maximum
                              if(MathAbs(Open[index]-aL[index])>MathAbs(Open[index]-aH[index]))
                                {
                                 fB[index]=1;
                                 lB[index]=0;
                                }
                              else //otherwise if open is closer to the active maximum
                                {
                                 //if open is closer or equally distant from the minimum
                                 if(MathAbs(Open[index]-Low[index])>=MathAbs(Open[index]-High[index]))
                                   {
                                    fB[index]=0;
                                    lB[index]=1;
                                   }
                                 else
                                   {
                                    fB[index]=1;
                                    lB[index]=0;
                                   }
                                }
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
      else
        {
         if(High[index]>aH[index])
           {
            fB[index]=1;
           }
         else
           {
            fB[index]=0;
           }
        }
     }
   else
     {
      //If the current price is equal to the maximum on the bar or there is no minimum, and the maximum is new
      if((Low[index]>=aL[index] || Close[index]==High[index]) && High[index]>aH[index])
        {
         lB[index]=1;
        }
      else //otherwise if the price is equal to the bar maximum
        {
         //If the price is equal to the minimum on the bar or there is no new maximum, and the maximum is new
         if((High[index]<=aH[index] || Close[index]==Low[index]) && Low[index]<aL[index])
           {
            lB[index]=0;
           }
        }
     }
//---
   return;
  }
//+------------------------------------------------------------------+

   