//+------------------------------------------------------------------+
//|                                              MD5.Speed.Chart.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#include <controls\wndobj.mqh>
#include <canvas\canvas.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMD5SpeedChart : public CWndObj
  {
private:
   CCanvas           m_canvas;                // Drawing area
   double            m_max_value;             // Maximum value
   double            m_series[];              // An array of values in a ring buffer
   int               m_series_start;          // Starting position in the buffer
   int               m_series_end;            // Final position in the buffer

public:
                     CMD5SpeedChart();
                    ~CMD5SpeedChart();

   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   void              Refresh(const int width,const int height);
   void              Update(void);

   void              AddValue(const double value);
   //--- internal event handlers
   virtual bool      OnShow(void);
   virtual bool      OnHide(void);
   virtual bool      OnMove(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMD5SpeedChart::CMD5SpeedChart():m_max_value(100.0),m_series_start(0),m_series_end(0)
  {
   ArrayResize(m_series,2048,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMD5SpeedChart::~CMD5SpeedChart()
  {
   Print("Destroy");
   m_canvas.Destroy();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMD5SpeedChart::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
//--- Creating a control
   if(m_canvas.CreateBitmapLabel(name,x1,y1,x2+1-x1,y2+1-y1,COLOR_FORMAT_ARGB_RAW))
     {
      //m_canvas.FillRectangle(0,0,m_canvas.Width()-1,m_canvas.Height()-1,0x1234567);
      m_canvas.Erase(XRGB(0xFF,0x00,0x00));
      m_canvas.Update();
      return(true);
     }
//--- Failed
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMD5SpeedChart::Refresh(const int width,const int height)
  {
//---
   if(width!=m_canvas.Width()-1 || height!=m_canvas.Height()-1)
     {
      //---
      m_canvas.Resize(width,height);
      //--- отрисуем рамку и фон
      m_canvas.Rectangle(0,0,width-2,height-1,XRGB(247,247,247));

      m_canvas.LineHorizontal(1,width-2,1,XRGB(105,105,105));
      m_canvas.LineVertical(1,1,height-3,XRGB(105,105,105));

      m_canvas.LineHorizontal(1,width-2,height-2,XRGB(200,200,200));
      m_canvas.LineVertical(width-3,2,height-3,XRGB(200,200,200));

      m_canvas.FillRectangle(2,2,width-3,height-3,XRGB(0,0,0));
     }
//---
   Update();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMD5SpeedChart::Update(void)
  {
   int width  =(m_canvas.Width()-6)/2;
   int start  =m_series_end;
   int maxsize=ArraySize(m_series);
//--- Finding the initial position of the output
   while(width>0)
     {
      //--- Is it the beginning?
      if(start==m_series_start) break;
      //--- Decrease the position counter
      start--;
      if(start<0)
         start=maxsize-1;
      //--- Decrease the output data counter
      width--;
     }
//--- Painting the background
   m_canvas.FillRectangle(2,2,m_canvas.Width()-3,m_canvas.Height()-3,XRGB(0,0,0));
//--- Drawing a histogram
   int    end   =m_series_end;
   int    xpos  =m_canvas.Width()-5;
   int    height=m_canvas.Height()-6;
   color  clr   =XRGB(0,255,0);

   while(end!=start)
     {
      //--- Moving on to the next position
      end--;
      if(end<0)
         end=maxsize-1;
      //--- Calculating the height
      int pos=int(m_series[end]*height/m_max_value);
      //--- Output
      m_canvas.LineVertical(xpos,height+2,height+3-pos,clr);
      xpos-=2;
     }
//---
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Enqueue the new value                                            |
//+------------------------------------------------------------------+
void CMD5SpeedChart::AddValue(const double value)
  {
//--- Adding at the end and increasing the position
   m_series[m_series_end++]=value;
//--- Setting a new maximum
   if(value>m_max_value)
      m_max_value=value;
//--- Is it the end of the buffer?
   if(m_series_end>=ArraySize(m_series))
      m_series_end=0;
//--- Is it the beginning?
   if(m_series_end==m_series_start)
     {
      m_series_start++;
      if(m_series_start>=ArraySize(m_series))
         m_series_start=0;
     }
//---
//   Print("Added ",value,", positions ",m_series_start,":",m_series_end);
  }
//+------------------------------------------------------------------+
//| Display object on chart                                          |
//+------------------------------------------------------------------+
bool CMD5SpeedChart::OnShow(void)
  {
   return ObjectSetInteger(ChartID(),m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
  }
//+------------------------------------------------------------------+
//| Hide object from chart                                           |
//+------------------------------------------------------------------+
bool CMD5SpeedChart::OnHide(void)
  {
   return ObjectSetInteger(ChartID(),m_canvas.ChartObjectName(),OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
  }
//+------------------------------------------------------------------+
//| Absolute movement of the chart object                            |
//+------------------------------------------------------------------+
bool CMD5SpeedChart::OnMove(void)
  {
//--- position the chart object
   ObjectSetInteger(ChartID(),m_canvas.ChartObjectName(),OBJPROP_XDISTANCE,m_rect.left);
   ObjectSetInteger(ChartID(),m_canvas.ChartObjectName(),OBJPROP_YDISTANCE,m_rect.top);
//---
   return(true);
  }
//+------------------------------------------------------------------+
