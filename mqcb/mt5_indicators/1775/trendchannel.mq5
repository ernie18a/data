//+------------------------------------------------------------------+
//|                                                 TrendChannel.mq5 |
//|                                        Copyright © 2008, nsi2000 | 
//|                                      http://www.expert-mt4.nm.ru | 
//+------------------------------------------------------------------+ 
//---- Copyright
#property copyright "Copyright © 2008, nsi2000"
//---- link to the website of the author
#property link "http://www.expert-mt4.nm.ru" 
//---- Indicator version number
#property version   "1.00"
#property description "The indicator draws a trend channel"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- no buffers used for the calculation and drawing of the indicator
#property indicator_buffers 0
//---- 0 graphical plots are used
#property indicator_plots   0
//+------------------------------------------------+ 
//| Enumeration for the level width                |
//+------------------------------------------------+ 
enum ENUM_WIDTH //Type of constant
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
//+------------------------------------------------+ 
//| Enumeration for the level style                |
//+------------------------------------------------+ 
enum STYLE
  {
   SOLID_,//Solid line
   DASH_,//Dashed line
   DOT_,//Dotted line
   DASHDOT_,//Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
input string levels_sirname="Price_Level_1"; //Label of the levels
input uint nPeriod=10;                 //Period for finding extrema
input uint Limit=350;                  //Number of bars for review

input color Up_level_color=clrLime;    //The color of the upper level
input STYLE Up_level_style=SOLID_;     //The style of the upper level
input ENUM_WIDTH Up_level_width=w_3;   //The width of the first upper level

input color Dn_level_color=clrRed;     //The color of the lower level
input STYLE Dn_level_style=SOLID_;     //The style of the lower level
input ENUM_WIDTH Dn_level_width=w_3;   //The width of the lower level
//+----------------------------------------------+

int Res;
string UpName,DnName;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 double   price1,        // price level 1
 datetime time2,         // price level time 2
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting a trend line                                          |
//+------------------------------------------------------------------+
void SetTline
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 double   price1,        // price level 1
 datetime time2,         // price level time 2
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   UpName=levels_sirname+"_UpName";
   DnName=levels_sirname+"_DnName";
   Res=int((nPeriod-1)/2);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,UpName);
   ObjectDelete(0,DnName);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<int(Limit)) return(0);
   
//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true); 
   ArraySetAsSeries(Time,true); 

//---- declaration of local variables 
   double r1=0,r2=0,r3=0,r4=0,r5=0,r6=0;
   double s1=0,s2=0,s3=0,s4=0,s5=0,s6=0;
   int rt1=0,rt2=0,rt3=0,rt4=0,rt5=0,rt6=0;  
   int st1=0,st2=0,st3=0,st4=0,st5=0,st6=0;
   
   
   for(int bar=int(Limit); bar>=0; bar--)
     {
      int barx=bar+Res;
      double HH=High[ArrayMaximum(High,bar,nPeriod)];
      double LL=Low[ArrayMinimum(Low,bar,nPeriod)];
      
      if(Low[barx]==LL)
        {
         s6=s5;
         s5=s4;
         s4=s3;
         s3=s2;
         s2=s1;
         s1=Low[barx];
         st6=st5; 
         st5=st4; 
         st4=st3;
         st3=st2;
         st2=st1;
         st1=barx;
        }
        
      if(High[barx]==HH)
        {
         r6=r5;
         r5=r4; 
         r4=r3; 
         r3=r2; 
         r2=r1; 
         r1=High[barx];
         rt6=rt5; 
         rt5=rt4; 
         rt4=rt3; 
         rt3=rt2; 
         rt2=rt1; 
         rt1=barx;
        }
     }

//----
   SetTline(0,UpName,0,Time[rt2],r2,Time[rt1],r1,Up_level_color,Up_level_style,Up_level_width,UpName);
   SetTline(0,DnName,0,Time[st2],s2,Time[st1],s1,Dn_level_color,Dn_level_style,Dn_level_width,DnName);

//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
