//+------------------------------------------------------------------+
//|                                                        Flame.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#property indicator_chart_window // allow operation of a script and an Expert Advisor    
#property indicator_plots   1
#property indicator_buffers 1

#define SCREEN_CY 200            // define the height of the image (our flame is not high)                
//+------------------------------------------------------------------+
//| Necessary global variables                                       |
//+------------------------------------------------------------------+
uint    ExtPal[256];             // flame palette
uint    ExtScreen[];             // buffer for outputting to resource   
uchar   ExtFlame[][SCREEN_CY+1]; // flame calculation buffer
uint    ExtTime=0;               // time of the next event         
long    ExtChartID=0;            // our chart's ID
uint    ExtWidth=0;              // flame image width
uint    ExtY=0;                  // Point for binding the flame to the bottom
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- store the chart's ID and create a graphical object bound to resource
   ExtChartID=ChartID();
   ObjectCreate(ExtChartID,"flame",OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetString(ExtChartID,"flame",OBJPROP_BMPFILE,"::flame");
//--- create the palette
   double g=0,b=0,dg=1.5,db=0.63;
//---
   for(uint a,i=0;i<256;i++)
     {
      //--- the first 32 values of flame are completely transparent
      a=uchar(i<32?0:i-32);
      //--- generate color for the i value of flame
      ExtPal[i]=(a<<24)|(uint(255)<<16)|(uint(g+0.5)<<8)|uint(b+0.5);
      //--- increment the color components
      //--- the red color gets gradient due to transparency
      if(i>80)  g+=dg;
      if(i>160) b+=db;
     }
//--- determine the size of the chart and display the first frame
   Resize();
//--- arrange custom timer, OnTimer's 1 time per second is not enough
   EventChartCustom(ExtChartID,1302,0,0,NULL);
  }
//+------------------------------------------------------------------+
//| Remove                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int)
  {
   ObjectDelete(ExtChartID,"flame");
  }
//+------------------------------------------------------------------+
//| Calculate nothing                                                |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Event handling                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lp,const double &dp,const string &sp)
  {
   switch(id)
     {
      //--- organize custom timer
      case 2302:
         //--- time to draw the new frame?
         if(GetTickCount()>ExtTime)
           {
            //--- draw frame
            Calculate();
            //--- calculate time for the next frame
            ExtTime=GetTickCount()+20;
           }
         //--- generate next event for custom timer
         EventChartCustom(ExtChartID,1302,0,0,NULL);
         break;
         //--- changes on the chart
      case CHARTEVENT_CHART_CHANGE:
         //--- recalculate with new parameters
         Resize();
         break;
     }
  }
//+------------------------------------------------------------------+
//| Calculate and render frame                                       |
//+------------------------------------------------------------------+
void Calculate()
  {
//--- calculate new frame
   for(uint x=0;x<ExtWidth;x++)
      ExtFlame[x][SCREEN_CY]++;
//--- draw flame shapes
   for(uint y=SCREEN_CY-1;y>0;y--)
     {
      for(uint c,x=1,n=ExtWidth-1;x<n;x++)
        {
         c =ExtFlame[x-1][y]+ExtFlame[x+1][y];
         c+=ExtFlame[x-1][y+1]+ExtFlame[x][y+1]+ExtFlame[x+1][y+1];
         ExtFlame[x][y]=uchar(c/5);
        }
     }
//--- move flame to the resource buffer
   for(uint y=0;y<SCREEN_CY;y++)
      for(uint x=0;x<ExtWidth;x++)
         ExtScreen[y*ExtWidth+x]=ExtPal[ExtFlame[x][y]];
//--- update the resource and display it on the screen
   ResourceCreate("::flame",ExtScreen,ExtWidth,SCREEN_CY,0,0,ExtWidth,COLOR_FORMAT_ARGB_NORMALIZE);
   ChartRedraw(ExtChartID);
  }
//+------------------------------------------------------------------+
//| Chart update                                                     |
//+------------------------------------------------------------------+
void Resize()
  {
//--- request new chart size
   uint cx=(uint)ChartGetInteger(ExtChartID,CHART_WIDTH_IN_PIXELS);
   uint cy=(uint)ChartGetInteger(ExtChartID,CHART_HEIGHT_IN_PIXELS);
//--- chart's height changed - move the image
   if(ExtY!=cy)
     {
      ExtY=cy;
      ObjectSetInteger(ExtChartID,"flame",OBJPROP_YDISTANCE,ExtY-SCREEN_CY);
     }
//--- width changed
   if(ExtWidth!=cx)
     {
      //--- change size of the buffers
      ArrayResize(ExtScreen,cx*SCREEN_CY);
      ArrayResize(ExtFlame,cx);
      //--- expand the flame
      for(uint x=ExtWidth;x<cx;x++)
        {
         //--- zero out flame shapes
         for(uint y=0;y<SCREEN_CY;y++) ExtFlame[x][y]=0;
         //--- put some "wood"
            ExtFlame[x][SCREEN_CY]=uchar(rand()%256);
        }
      //--- update the size and re-draw the frame
      ExtWidth=cx;
      Calculate();
     }
  }
//+------------------------------------------------------------------+
