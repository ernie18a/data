//+------------------------------------------------------------------+
//|                                                    Dserg-PPZ.mq5 |
//|                                           Copyright © 2010 Dserg |
//|                               http://www.mql4.com/ru/users/Dserg |
//+------------------------------------------------------------------+
#property description "Indicator for the automatic drawing of PPZ levels by three fractals"
//---- author of the indicator
#property copyright "Copyright © 2010 Dserg"
//---- link to the website of the author
#property link      "http://www.mql4.com/ru/users/Dserg"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- four buffers are used for the indicator calculation and drawing
#property indicator_buffers 4
//---- only four plots are used
#property indicator_plots   4
//+----------------------------------------------+ 
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0  // The constant for getting the command for the indicator recalculation back to the terminal
#define COUNTSIZE 1000  // The constant for the number of calculated bars
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- blue color is used for the indicator bearish line
#property indicator_color1  clrBlue
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "PPZ 0"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- HotPink color is used as the color of the bullish line of the indicator
#property indicator_color2  clrHotPink
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2 "PPZ 1"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- Teal color is used for the indicator bearish line
#property indicator_color3  clrTeal
//---- thickness of the indicator 3 line is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "PPZ 2"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- Tomato color is used as the color of the bullish line of the indicator
#property indicator_color4  clrTomato
//---- indicator 4 line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4 "PPZ 3"
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,//Solid line
   DASH_,//Dashed line
   DOT_,//Dotted line
   DASHDOT_,//Dot-dash line
   DASHDOTDOT_   //Dot-dash line with double dots
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int Nbars_=150; //??Width of the window in which the levels are sought
input int Nfirst=0; // offset of right bar fot the window
input double minDiff=300.0; //Minimal distance between the levels in points 
input int minBars=5; //Minimum distance between the fractals in bars
//----
input color  Color_PPZ0=clrBlue;       //PPZ0 level color
input color  Color_PPZ1=clrMagenta;    //PPZ1 level color
input color  Color_PPZ2=clrTeal;       //PPZ2 level color
input color  Color_PPZ3=clrBlueViolet; //PPZ3 level color
input color  Color_V1=clrRed;          //V1 level color
input color  Color_V2=clrLime;         //V2 level color
//----
input STYLE  Style_PPZ0 = SOLID_; //PPZ0 level line style
input STYLE  Style_PPZ1 = SOLID_; //PPZ1 level line style
input STYLE  Style_PPZ2 = SOLID_; //PPZ2 level line style
input STYLE  Style_PPZ3 = SOLID_; //PPZ3 level line style
input STYLE  Style_V1 = SOLID_;   //V1 level line style
input STYLE  Style_V2 = SOLID_;   //V2 level line style
//----
input Width  Width_PPZ0 = Width_1; //PPZ0 level line width
input Width  Width_PPZ1 = Width_1; //PPZ1 level line width
input Width  Width_PPZ2 = Width_1; //PPZ2 level line width
input Width  Width_PPZ3 = Width_1; //PPZ3 level line width
input Width  Width_V1 = Width_3; //V1 level line width
input Width  Width_V2 = Width_3; //V2 level line width
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double B0Buffer[];
double B1Buffer[];
double B2Buffer[];
double B3Buffer[];
//---
double Fr0[COUNTSIZE];
int    Ind0[COUNTSIZE];
//---- Declaration of integer variables for the indicator handles
int FRA_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,Nbars,loopbegin;
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline
(
 long   chart_id,      // chart ID
 string name,          // object name
 int    nwin,          // window index
 double price,         // price level
 color  Color,         // line color
 int    style,         // line style
 int    width,         // line width
 string text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline
(
 long   chart_id,      // chart ID
 string name,          // object name
 int    nwin,          // window index
 double price,         // price level
 color  Color,         // line color
 int    style,         // line style
 int    width,         // line width
 string text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line creation                                          |
//+------------------------------------------------------------------+
void CreateVline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // vertical level time
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n"); //tooltip disabling
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //background object
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line reinstallation                                    |
//+------------------------------------------------------------------+
void SetVline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // vertical level time
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- getting handle of the iFractals indicator
   FRA_Handle=iFractals(NULL,0);
   if(FRA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the iFractals indicator");

//---- initialization of global variables
   Nbars=Nbars_;
   if(Nbars>500)
     {
      Comment("Too many bars for the calculation! The parameter value will be limited to 500");
      Nbars=500;
     }

   loopbegin=Nbars+Nfirst;
   min_rates_total=loopbegin;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,B0Buffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,119);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(B0Buffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,B1Buffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(B1Buffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,B2Buffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 3 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,119);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(B2Buffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,B3Buffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 4 drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,119);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(B3Buffer,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Fine Fractals";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"PPZ");
   ObjectDelete(0,"PPZ1");
   ObjectDelete(0,"PPZ2");
   ObjectDelete(0,"PPZ3");
   ObjectDelete(0,"V1");
   ObjectDelete(0,"V2");
   Comment("");
//----
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
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(FRA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
   if(rates_total==prev_calculated) return(rates_total);

//---- declaration of local variables 
   int i,j,k,l,imin,jmin,kmin,lmin,imin1,jmin1,kmin1,lmin1,imin2,jmin2,kmin2,lmin2,imin3,jmin3,kmin3,lmin3;
   double f0,f1,f2,f3,p0,s0,pmin,smin,pmin1,smin1,pmin2,smin2,pmin3,smin3;
   double UpFractal[],DnFractal[],A,B,C;
   int Nmax;

//---- calculations of the necessary amount of data to be copied
   int to_copy=loopbegin+1;

//---- copy the newly appeared data into the UpFractal and DnFractal arrays
   if(CopyBuffer(FRA_Handle,0,0,to_copy,UpFractal)<=0) return(RESET);
   if(CopyBuffer(FRA_Handle,1,0,to_copy,DnFractal)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(UpFractal,true);
   ArraySetAsSeries(DnFractal,true);

   pmin = 10.0;
   smin = 10000.0;
   pmin1 = 20.0;
   smin1 = 20000.0;
   pmin2 = 30.0;
   smin2 = 30000.0;
   pmin3 = 40.0;
   smin3 = 40000.0;
   
//---- zero out the contents of the indicator buffers before the calculation
   for(i=0; i<rates_total; i++)
     {
      B0Buffer[i]=0.0;
      B1Buffer[i]=0.0;
      B2Buffer[i]=0.0;
      B3Buffer[i]=0.0;
     }

//----  search fractals and add it into array
   j=0;
   for(i=loopbegin; i>Nfirst; i--)
     {
      f0=UpFractal[i];
      if(!f0) f0=DnFractal[i];
      if(f0)
        {
         Fr0[j]=f0;
         Ind0[j]=i;
         j++;
        }
     }
   Nmax=j;
   
//---- search the first PPZ line by 4 fractals
   for(i=0; i<Nmax; i++)
     {
      f0=Fr0[i];
      for(j=0; j<Nmax; j++)
        {
         f1=Fr0[j];
         A=MathAbs(Ind0[i]-Ind0[j]);
         if(i!=j && A>minBars)
           {
            for(k=0; k<Nmax; k++)
              {
               f2=Fr0[k];
               A=MathAbs(Ind0[i]-Ind0[k]);
               B=MathAbs(Ind0[k]-Ind0[j]);
               if(k!=j && k!=j && A>minBars && B>minBars)
                 {
                  for(l=0; l<Nmax; l++)
                    {
                     f3=Fr0[l];
                     A=MathAbs(Ind0[i]-Ind0[l]);
                     B=MathAbs(Ind0[j]-Ind0[l]);
                     C=MathAbs(Ind0[k]-Ind0[l]);
                     if(l!=i && l!=j && l!=k && A>minBars && B>minBars && C>minBars)
                       {
                        p0 = (f0+f1+f2+f3)/4.0;
                        s0 = (f0-p0)*(f0-p0)+(f1-p0)*(f1-p0)+(f2-p0)*(f2-p0)+(f2-p0)*(f2-p0);
                        if(s0<smin)
                          {
                           smin=s0;
                           pmin=p0;
                           imin=i;
                           jmin=j;
                           kmin=k;
                           lmin=l;
                          }
                       }
                    }
                 }
              }
           }
        }
     }
     
//---- search the second PPZ line by 4 fractals
   for(i=0; i<Nmax; i++)
     {
      f0=Fr0[i];
      if(i!=imin && i!=jmin && i!=kmin && i!=lmin)
        {
         for(j=0; j<Nmax; j++)
           {
            f1=Fr0[j];
            A=MathAbs(Ind0[i]-Ind0[j]);
            if(i!=j && A>minBars && j!=imin && j!=jmin && j!=kmin && j!=lmin)
              {
               for(k=0; k<Nmax; k++)
                 {
                  f2=Fr0[k];
                  A=MathAbs(Ind0[i]-Ind0[k]);
                  B=MathAbs(Ind0[k]-Ind0[j]);
                  if(k!=j && k!=j && A>minBars && B>minBars && k!=imin && k!=jmin && k!=kmin && k!=lmin)
                    {
                     for(l=0; l<Nmax; l++)
                       {
                        f3=Fr0[l];
                        A=MathAbs(Ind0[i]-Ind0[l]);
                        B=MathAbs(Ind0[j]-Ind0[l]);
                        C=MathAbs(Ind0[k]-Ind0[l]);
                        if(l!=i && l!=j && l!=k && A>minBars && B>minBars && C>minBars && l!=imin && l!=jmin && l!=kmin && l!=lmin)
                          {
                           p0 = (f0+f1+f2+f3)/4.0;
                           s0 = (f0-p0)*(f0-p0)+(f1-p0)*(f1-p0)+(f2-p0)*(f2-p0)+(f2-p0)*(f2-p0);
                           if(s0<smin1 && MathAbs(p0-pmin)>minDiff*_Point)
                             {
                              smin1=s0;
                              pmin1=p0;
                              imin1=i;
                              jmin1=j;
                              kmin1=k;
                              lmin1=l;
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
     }

//---- search the third PPZ line by 4 fractals
   for(i=0; i<Nmax; i++)
     {
      f0=Fr0[i];
      if(i!=imin && i!=jmin && i!=kmin && i!=lmin && i!=imin1 && i!=jmin1 && i!=kmin1 && i!=lmin1)
        {
         for(j=0; j<Nmax; j++)
           {
            f1=Fr0[j];
            A=MathAbs(Ind0[i]-Ind0[j]);
            if(i!=j && A>minBars && j!=imin && j!=jmin && j!=kmin && j!=lmin && j!=imin1 && j!=jmin1 && j!=kmin1 && j!=lmin1)
              {
               for(k=0; k<Nmax; k++)
                 {
                  f2=Fr0[k];
                  A=MathAbs(Ind0[i]-Ind0[k]);
                  B=MathAbs(Ind0[k]-Ind0[j]);
                  if(k!=j && k!=j && A>minBars && B>minBars && k!=imin && k!=jmin && k!=kmin && k!=lmin && k!=imin1 && k!=jmin1 && k!=kmin1 && k!=lmin1)
                    {
                     for(l=0; l<Nmax; l++)
                       {
                        f3=Fr0[l];
                        A=MathAbs(Ind0[i]-Ind0[l]);
                        B=MathAbs(Ind0[j]-Ind0[l]);
                        C=MathAbs(Ind0[k]-Ind0[l]);
                        if(l!=i && l!=j && l!=k && A>minBars && B>minBars && C>minBars && l!=imin && l!=jmin && l!=kmin && l!=lmin && l!=imin1 && l!=jmin1 && l!=kmin1 && l!=lmin1)
                          {
                           p0 = (f0+f1+f2+f3)/4.0;
                           s0 = (f0-p0)*(f0-p0)+(f1-p0)*(f1-p0)+(f2-p0)*(f2-p0)+(f2-p0)*(f2-p0);
                           if(s0<smin2 && MathAbs(p0-pmin)>minDiff*_Point && MathAbs(p0-pmin1)>minDiff*_Point)
                             {
                              smin2=s0;
                              pmin2=p0;
                              imin2=i;
                              jmin2=j;
                              kmin2=k;
                              lmin2=l;
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
     }

//---- search the fourth PPZ line by 4 fractals
   for(i=0; i<Nmax; i++)
     {
      f0=Fr0[i];
      if(i!=imin && i!=jmin && i!=kmin && i!=lmin && i!=imin1 && i!=jmin1 && i!=kmin1 && i!=lmin1 && i!=imin2 && i!=jmin2 && i!=kmin2 && i!=lmin2)
        {
         for(j=0; j<Nmax; j++)
           {
            f1=Fr0[j];
            A=MathAbs(Ind0[i]-Ind0[j]);
            if(i!=j && A>minBars && j!=imin && j!=jmin && j!=kmin && j!=lmin && j!=imin1 && j!=jmin1 && j!=kmin1 && j!=lmin1 && j!=imin2 && j!=jmin2 && j!=kmin2 && j!=lmin2)
              {
               for(k=0; k<Nmax; k++)
                 {
                  f2=Fr0[k];
                  A=MathAbs(Ind0[i]-Ind0[k]);
                  B=MathAbs(Ind0[k]-Ind0[j]);
                  if(k!=j && k!=j && A>minBars && B>minBars && k!=imin && k!=jmin && k!=kmin && k!=lmin && k!=imin1 && k!=jmin1 && k!=kmin1 && k!=lmin1 && k!=imin2 && k!=jmin2 && k!=kmin2 && k!=lmin2)
                    {
                     for(l=0; l<Nmax; l++)
                       {
                        f3=Fr0[l];
                        A=MathAbs(Ind0[i]-Ind0[l]);
                        B=MathAbs(Ind0[j]-Ind0[l]);
                        C=MathAbs(Ind0[k]-Ind0[l]);
                        if(l!=i && l!=j && l!=k && A>minBars && B>minBars && C>minBars && l!=imin && l!=jmin && l!=kmin && l!=lmin && l!=imin1 && l!=jmin1 && l!=kmin1 && l!=lmin1 && l!=imin2 && l!=jmin2 && l!=kmin2 && l!=lmin2)
                          {
                           p0 = (f0+f1+f2+f3)/4.0;
                           s0 = (f0-p0)*(f0-p0)+(f1-p0)*(f1-p0)+(f2-p0)*(f2-p0)+(f2-p0)*(f2-p0);
                           if(s0<smin3 && MathAbs(p0-pmin)>minDiff*_Point && MathAbs(p0-pmin1)>minDiff*_Point && MathAbs(p0-pmin2)>minDiff*_Point)
                             {
                              smin3=s0;
                              pmin3=p0;
                              imin3=i;
                              jmin3=j;
                              kmin3=k;
                              lmin3=l;
                             }
                          }
                       }
                    }
                 }
              }
           }
        }
     }

   int Max=COUNTSIZE-1;
//----   
   imin=MathMin(imin,Max);
   jmin=MathMin(jmin,Max); 
   kmin=MathMin(kmin,Max); 
   lmin=MathMin(lmin,Max);  
//----   
   imin1=MathMin(imin1,Max);
   jmin1=MathMin(jmin1,Max); 
   kmin1=MathMin(kmin1,Max); 
   lmin1=MathMin(lmin1,Max);  
//----   
   imin2=MathMin(imin2,Max);
   jmin2=MathMin(jmin2,Max); 
   kmin2=MathMin(kmin2,Max); 
   lmin2=MathMin(lmin2,Max);
//----   
   imin3=MathMin(imin3,Max);
   jmin3=MathMin(jmin3,Max); 
   kmin3=MathMin(kmin3,Max); 
   lmin3=MathMin(lmin3,Max);     

//---- Draw results, mark points
   B0Buffer[Ind0[imin]] = open[Ind0[imin]];
   B0Buffer[Ind0[jmin]] = open[Ind0[jmin]];
   B0Buffer[Ind0[kmin]] = open[Ind0[kmin]];
   B0Buffer[Ind0[lmin]] = open[Ind0[lmin]];

   B1Buffer[Ind0[imin1]] = open[Ind0[imin1]];
   B1Buffer[Ind0[jmin1]] = open[Ind0[jmin1]];
   B1Buffer[Ind0[kmin1]] = open[Ind0[kmin1]];
   B1Buffer[Ind0[lmin1]] = open[Ind0[lmin1]];

   B2Buffer[Ind0[imin2]] = open[Ind0[imin2]];
   B2Buffer[Ind0[jmin2]] = open[Ind0[jmin2]];
   B2Buffer[Ind0[kmin2]] = open[Ind0[kmin2]];
   B2Buffer[Ind0[lmin2]] = open[Ind0[lmin2]];

   B3Buffer[Ind0[imin3]] = open[Ind0[imin3]];
   B3Buffer[Ind0[jmin3]] = open[Ind0[jmin3]];
   B3Buffer[Ind0[kmin3]] = open[Ind0[kmin3]];
   B3Buffer[Ind0[lmin3]] = open[Ind0[lmin3]];


   double velue=NormalizeDouble(pmin,_Digits);
   string svelue=string(velue);
   SetHline(0,"PPZ",0,velue,Color_PPZ0,Style_PPZ0,Width_PPZ0,"PPZ"+svelue);

   velue=NormalizeDouble(pmin1,_Digits);
   svelue=string(velue);
   SetHline(0,"PPZ1",0,velue,Color_PPZ1,Style_PPZ1,Width_PPZ1,"PPZ1"+svelue);

   velue=NormalizeDouble(pmin2,_Digits);
   svelue=string(velue);
   SetHline(0,"PPZ2",0,velue,Color_PPZ2,Style_PPZ2,Width_PPZ2,"PPZ2"+svelue);

   velue=NormalizeDouble(pmin3,_Digits);
   svelue=string(velue);
   SetHline(0,"PPZ3",0,velue,Color_PPZ3,Style_PPZ3,Width_PPZ3,"PPZ3"+svelue);

   SetVline(0,"V1",0,time[Nbars+Nfirst],Color_V1,Style_V1,Width_V1,true,"V1");
   SetVline(0,"V2",0,time[Nfirst],Color_V2,Style_V2,Width_V2,true,"V2");
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
