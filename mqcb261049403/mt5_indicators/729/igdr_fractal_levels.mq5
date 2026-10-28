//+------------------------------------------------------------------+
//|                                          iGDR_Fractal_Levels.mq5 |
//|                          Copyright © 2008-2009, GreenDog, Russia |
//|                                                    krot@inbox.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2008-2009, GreenDog"
//---- link to the website of the author
#property link      "krot@inbox.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers  1
#property indicator_plots    1
//+----------------------------------------------+
//|  Declaration of enumeration                  |
//+----------------------------------------------+
enum FRACTAL_MODE
  {
   MODE_HIGH_LOW=0, // by extremums
   MODE_LOW,        // by tops
   MODE_HIGH        // by bottoms
  };
//+----------------------------------------------+
//|  Declaration of enumeration                  |
//+----------------------------------------------+
enum FRACTAL_TYPE
  {
   TYPE1=0, // strict
   TYPE2    // not strict
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint frNum_=2;                      // Number of fractal bars, 2=5 bar fractal, 3=7 bar etc.
input FRACTAL_TYPE frType= TYPE2;         // Fractal specifying type 0=strict, 1=not strict
input FRACTAL_MODE frMode =MODE_HIGH_LOW; // Mode 
input double dlt_=0.24;                   // Inaccuracy measure from the bars average height
input uint sBars_=200;                    // Number of bars (not more than 200)
//----
input color  BG1_Color = PaleGreen;  // First levels background color
input color  TL1Color  = Green;      // First levels lines color
input color  BG2_Color = Yellow;     // Second levels background color
input color  TL2Color  = DarkOrange; // Second levels lines color
input color  BG3_Color = Pink;       // Third levels background color
input color  TL3Color  = Red;        // Third levels lines color
//+----------------------------------------------+
uint lastBars=0;
uint frNum,sBars;
datetime lastTime=0;
color BGColor[3],TLColor[3];
double aData[240][2],aRes[3][2];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of constants
   frNum=frNum_;
   if(frNum_<2) frNum=2;
   sBars=sBars_;
   if(sBars_>200) sBars=200;
   if(sBars_<10) sBars=10;
   BGColor[0]=BG1_Color;
   BGColor[1]=BG2_Color;
   BGColor[2]=BG3_Color;
   TLColor[0]=TL1Color;
   TLColor[1]=TL2Color;
   TLColor[2]=TL3Color;
//----
  }
//+------------------------------------------------------------------+
//|  Creation of a text label                                        |
//+------------------------------------------------------------------+
void CreateTextLabel(long     chart_id,   // chart ID
                     string   name,       // object name
                     int      nwin,       // window index
                     datetime time1,      // price level time 1
                     double   price1,     // price level 1
                     color    Color,      // line color
                     string   text,       // text
                     string   font,       // font 
                     int      fontsize)   // font size
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time1,price1);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
   ObjectSetString(chart_id,name,OBJPROP_FONT,font);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,fontsize);
//----
  }
//+------------------------------------------------------------------+
//|  Text label reinstallation                                       |
//+------------------------------------------------------------------+
void SetTextLabel(long     chart_id,    // chart ID
                  string   name,        // object name
                  int      nwin,        // window index
                  datetime time1,       // price level time 1
                  double   price1,      // price level 1
                  color    Color,       // line color
                  int      style,       // line style
                  int      width,       // line width
                  string   text,        // text
                  string   font,        // font
                  int      fontsize)    // font size
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTextLabel(chart_id,name,nwin,time1,price1,Color,text,font,fontsize);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Channel creation                                                |
//+------------------------------------------------------------------+
void CreateChannel(long     chart_id,      // chart ID
                   string   name,          // object name
                   int      nwin,          // window index
                   datetime time1,         // price level time 1
                   double   price1,        // price level 1
                   datetime time2,         // price level time 2
                   double   price2,        // price level 2
                   datetime time3,         // price level time 3
                   double   price3,        // price level 3
                   color    Color,         // line color
                   int      style,         // line style
                   int      width,         // line width
                   string   text)          // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_CHANNEL,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_FILL,true);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,true);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Channel reinstallation                                          |
//+------------------------------------------------------------------+
void SetChannel(long     chart_id,    // chart ID
                string   name,        // object name
                int      nwin,        // window index
                datetime time1,       // price level time 1
                double   price1,      // price level 1
                datetime time2,       // price level time 2
                double   price2,      // price level 2
                datetime time3,       // price level time 3
                double   price3,      // price level 3
                color    Color,       // line color
                int      style,       // line style
                int      width,       // line width
                string   text)        // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateChannel(chart_id,name,nwin,time1,price1,time2,price2,time3,price3,Color,style,width,text);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectMove(chart_id,name,2,time3,price3);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,    // chart ID
                 string   name,        // object name
                 int      nwin,        // window index
                 datetime time1,       // price level time 1
                 double   price1,      // price level 1
                 datetime time2,       // price level time 2
                 double   price2,      // price level 2
                 color    Color,       // line color
                 int      style,       // line style
                 int      width,       // line width
                 string   text)        // text
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
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,    // chart ID
              string   name,        // object name
              int      nwin,        // window index
              datetime time1,       // price level time 1
              double   price1,      // price level 1
              datetime time2,       // price level time 2
              double   price2,      // price level 2
              color    Color,       // line color
              int      style,       // line style
              int      width,       // line width
              string   text)        // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
     }
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
//| Searching for the upper fractal                                  |
//+------------------------------------------------------------------+   
bool upFrac(int cnt,const double &High[])
  {
//----
   for(int i=1; i<=int(frNum); i++)
     {
      if(frType==TYPE1)
        {
        //---- in case condition is strict and previous and next bars are above or equal the neighbouring ones, there is no fractal
         if(High[cnt+i]>=High[cnt+i-1] || High[cnt-i]>=High[cnt-i+1]) return(false);
        }
      else
        { 
        //---- in case condition is not strict and previous and next bars are above the middle, there is no fractal
         if(High[cnt+i]>High[cnt] || High[cnt-i]>High[cnt]) return(false);
        }
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Searching for the lower fractal                                  |
//+------------------------------------------------------------------+ 
bool dwFrac(int cnt,const double &Low[])
  {
//----
   for(int i=1; i<=int(frNum); i++)
     {
      if(frType==TYPE1)
        { 
         //---- in case condition is strict and previous and next bars are below or equal the neighbouring ones, there is no fractal
         if(Low[cnt+i]<=Low[cnt+i-1] || Low[cnt-i]<=Low[cnt-i+1]) return(false);
        }
      else
        { 
         //---- in case condition is not strict and previous and next bars are below the middle, there is no fractal
         if(Low[cnt+i]<Low[cnt] || Low[cnt-i]<Low[cnt]) return(false);
        }
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Comment("");
   for(int i=0; i<3; i++)
     {
      string name="IPGDR_Lv"+string(i);
      ObjectDelete(0,name);
      ObjectDelete(0,name+"Up");
      ObjectDelete(0,name+"Dw");
      ObjectDelete(0,name+"Tx");
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price highes for the indicator calculation
                const double& low[],      // price array of price lows for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<int(sBars)) return(0);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   lastBars=rates_total;

//---- searching for fractals, putting them to the array without exceeding permitted number
   int sh=0;
   ArrayInitialize(aData,0);
   double lastExt=0;
   int total=int(sBars-2*frNum);
   int start=int(frNum+1);

   for(int i=start; i<total; i++)
     {
      if(frMode!=MODE_LOW && upFrac(i,high))
        { 
         //---- adding tops [except bottoms mode]
         //---- skip doubling neighbouring tops in case of a not strict condition
         if(!(frType!=TYPE1 && lastExt>0 && lastExt==high[i]))
           {
            aData[sh][0]=high[i];
            lastExt=high[i];
            sh++;
           }
        }

      if(sh>=240) break;

      if(frMode!=MODE_HIGH && dwFrac(i,low))
        { 
         //---- adding bottoms [except tops mode]
         //---- skip doubling neighbouring bottoms in case of a not strict condition
         if(!frType!=TYPE1 && lastExt>0 && lastExt==low[i])
           {
            aData[sh][0]=low[i];
            lastExt=low[i];
            sh++;
           }
        }
      if(sh>=240) break;
     }

//---- determining the average range of the candlesticks and appropriate clearance
   double dlt,sHL=0;
   for(int i=1; i<=int(sBars); i++) sHL+=(high[i]-low[i]);
   sHL/=sBars;
   dlt=sHL*dlt_;

//---- determining ratings for each level
   for(int i=0; i<sh; i++)
      for(int j=i+1; j<sh; j++)
         if(aData[j][0]>aData[i][0]-dlt && aData[j][0]<aData[i][0]+dlt)
           {
            aData[i][1]+=1;
            aData[j][1]+=1;
           }

//---- determining three strongest levels
   double cur[2],tmp[2];
   aRes[0][0]=aData[0][0];
   aRes[0][1]=aData[0][1];

   for(int i=1; i<sh; i++)
     {
      cur[0]=aData[i][0];
      cur[1]=aData[i][1];

      if(cur[1]>aRes[0][1])
        { 
         //---- in case a rating exceeds the 1st place, the 1st becomes the current one
         tmp[0]=aRes[0][0];
         tmp[1]=aRes[0][1];
         aRes[0][0]=cur[0];
         aRes[0][1]=cur[1];
         cur[0]=tmp[0];
         cur[1]=tmp[1];
        }

      //---- in case a rating exceeds the 2nd place and does not belong to the 1st one, the 2nd one is replaced
      if(cur[1]>aRes[1][1] && (cur[0]<aRes[0][0]-dlt || cur[0]>aRes[0][0]+dlt))
        {
         tmp[0]=aRes[1][0]; tmp[1]=aRes[1][1]; aRes[1][0]=cur[0]; aRes[1][1]=cur[1]; cur[0]=tmp[0]; cur[1]=tmp[1];
        }
      //---- in case a rating exceeds the 3rd place and does not belong to the 1st and 2nd ones, the 3rd place is replaced
      if(cur[1]>aRes[2][1] && (cur[0]<aRes[0][0]-dlt || cur[0]>aRes[0][0]+dlt) && (cur[0]<aRes[1][0]-dlt || cur[0]>aRes[1][0]+dlt))
        {
         aRes[2][0]=cur[0];
         aRes[2][1]=cur[1];
        }
     }

   for(int i=0; i<3; i++)
     {
      double dwL=aRes[i][0]-dlt,upL=aRes[i][0]+dlt;
      string name="IPGDR_Lv"+string(i);
      SetChannel(0,name,0,time[24],upL,time[1],upL,time[24],dwL,BGColor[i],STYLE_SOLID,1,name);
      SetTline(0,name+"Up",0,time[24],upL,time[1],upL,TLColor[i],STYLE_SOLID,1,name+"Up");
      SetTline(0,name+"Dw",0,time[24],dwL,time[1],dwL,TLColor[i],STYLE_SOLID,1,name+"Dw");
      SetTextLabel(0,name+"Tx",0,time[32],upL+2*_Point,TLColor[i],STYLE_SOLID,1,DoubleToString(aRes[i][0],_Digits),"tahoma",14);
     }

//---- displaying comments
   string rem1="",rem2="";
   if(frType==TYPE2) rem1=rem1+"Standard ";
   else rem1=rem1+"Strict ";

   rem1=rem1+string(frNum*2+1)+" bar fractals";
   if(frMode==MODE_LOW) rem1=rem1+", bottoms";
   else if(frMode==MODE_HIGH) rem1=rem1+", tops";

   rem1=rem1+"\nFound "+string(sh)+" fractals \nThe strongest levels ";

   StringConcatenate(rem2,aRes[0][0],"[",aRes[0][1],"], ",
                     aRes[1][0],"[",aRes[1][1],"], ",aRes[2][0],"[",aRes[2][1],
                     "], inaccuracy measure ±",NormalizeDouble(dlt/_Point,1)," points");
   Comment(rem1+rem2);

//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
