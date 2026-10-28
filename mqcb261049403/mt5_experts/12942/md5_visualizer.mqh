//+------------------------------------------------------------------+
//|                                               MD5.Visualizer.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"

#include <controls\dialog.mqh>
#include <controls\label.mqh>
#include <controls\picture.mqh>

#include "md5.speed.chart.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMD5Visualizer
  {
private:
   CDialog           m_dialog;
   CLabel            m_speed_text;
   CMD5SpeedChart    m_speed_graph;
   bool              m_timer;

   uint              m_start_time;                   // Start time
   uint              m_last_time;                    // Last update time
   double            m_total_blocks;                 // The total number of counted blocks

public:
                     CMD5Visualizer();
                    ~CMD5Visualizer();

   bool              Initialize(void);
   void              Refresh(void);
   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   void              OnTimer();
   void              AddResult(const double passes);

private:
   bool              CreateDialog(void);
   bool              CreateIndicator(void);
   bool              CleanChart(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMD5Visualizer::CMD5Visualizer():m_timer(false),m_start_time(0),m_last_time(0),m_total_blocks(0)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMD5Visualizer::~CMD5Visualizer()
  {
//--- Deleting the timer
   if(m_timer)
     {
      EventKillTimer();
      m_timer=false;
     }
//---
  }
//+------------------------------------------------------------------+
//| Preparing GUI                                                    |
//+------------------------------------------------------------------+
bool CMD5Visualizer::Initialize(void)
  {
//---
   if(CreateIndicator())
      if(CleanChart())
         if(CreateDialog())
           {
           }
//--- Redrawing the window
   ChartRedraw();
//--- Setting the timer
   if(!m_timer)
      m_timer=EventSetTimer(1);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creating an indicator                                            |
//+------------------------------------------------------------------+
bool CMD5Visualizer::CreateIndicator(void)
  {
   return(true);
   MqlParam params[4];
//--- create iMA("EURUSD",PERIOD_M15,8,0,MODE_EMA,PRICE_CLOSE);
   params[0].type         =TYPE_INT;
   params[0].integer_value=12;
   params[1].type         =TYPE_INT;
   params[1].integer_value=26;
   params[2].type         =TYPE_INT;
   params[2].integer_value=9;
   params[3].type         =TYPE_INT;
   params[3].integer_value=PRICE_CLOSE;
//--- Creating an indicator and attaching it to a chart
/*   int ind=IndicatorCreate(_Symbol,_Period,IND_MACD,4,params);
   if(ind!=INVALID_HANDLE)
     {
      ChartIndicatorAdd(ChartID(),1,ind);
      return(true);
     }*/
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Preparing the chart                                              |
//+------------------------------------------------------------------+
bool CMD5Visualizer::CleanChart(void)
  {
   long  id  =ChartID();
   long  back=ChartGetInteger(id,CHART_COLOR_BACKGROUND);
   long  fore=ChartGetInteger(id,CHART_COLOR_FOREGROUND);
//--- Leave a narrow strip on the main chart, the rest will be left in our window
//   ChartSetInteger(id,CHART_HEIGHT_IN_PIXELS,0,22);
//--- Disable unnecessary elements
   ChartSetInteger(id,CHART_SHOW_GRID,0,false);
   ChartSetInteger(id,CHART_SHOW_ASK_LINE,0,false);
   ChartSetInteger(id,CHART_SHOW_BID_LINE,0,false);
   ChartSetInteger(id,CHART_SHOW_LAST_LINE,0,false);
   ChartSetInteger(id,CHART_SHOW_OHLC,0,false);
   ChartSetInteger(id,CHART_SHOW_PERIOD_SEP,0,false);
   ChartSetInteger(id,CHART_SHOW_TRADE_LEVELS,0,false);
   ChartSetInteger(id,CHART_SHOW_VOLUMES,0,CHART_VOLUME_HIDE);
   ChartSetInteger(id,CHART_MODE,CHART_LINE);
//--- Configuring chart colors
   ChartSetInteger(id,CHART_COLOR_ASK,back);
   ChartSetInteger(id,CHART_COLOR_BID,back);
//   ChartSetInteger(id,CHART_COLOR_BACKGROUND,back);
//   ChartSetInteger(id,CHART_COLOR_FOREGROUND,fore);
   ChartSetInteger(id,CHART_COLOR_CANDLE_BEAR,back);
   ChartSetInteger(id,CHART_COLOR_CANDLE_BULL,back);
   ChartSetInteger(id,CHART_COLOR_CHART_DOWN,back);
   ChartSetInteger(id,CHART_COLOR_CHART_LINE,back);
   ChartSetInteger(id,CHART_COLOR_CHART_UP,back);
   ChartSetInteger(id,CHART_COLOR_GRID,back);
   ChartSetInteger(id,CHART_COLOR_LAST,back);
   ChartSetInteger(id,CHART_COLOR_STOP_LEVEL,back);
   ChartSetInteger(id,CHART_COLOR_VOLUME,back);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creating a dialog                                                |
//+------------------------------------------------------------------+
bool CMD5Visualizer::CreateDialog(void)
  {
   long id    =ChartID();
   int  width =(int)ChartGetInteger(id,CHART_WIDTH_IN_PIXELS);
   int  height=(int)ChartGetInteger(id,CHART_HEIGHT_IN_PIXELS);
//--- Creating the main window
   m_dialog.Create(id,"MD5 Cloud Decryptor",0,0,22,width,height);
//--- Creating a text area to show the speed
   m_speed_text.Create(id,"MD5 Speed Text",0,width/2,height/2,100,100);
   m_speed_text.Color(clrBlack);
   m_speed_text.Text("1 256 mps");
   m_dialog.Add(m_speed_text);
//---
//   m_speed_graph.Create(id,"MD5 Speed Graph",0,0,height/2+20,width-8,height-8);
   m_speed_graph.Create(id,"MD5 Speed Graph",0,1,1,31,31);
   m_dialog.Add(m_speed_graph);
//--- Showing the dialog
   m_dialog.Show();
   return(true);
  }
//+------------------------------------------------------------------+
//| Creating a dialog                                                |
//+------------------------------------------------------------------+
void CMD5Visualizer::Refresh(void)
  {
   long id    =ChartID();
   int  width =(int)ChartGetInteger(id,CHART_WIDTH_IN_PIXELS);
   int  height=(int)ChartGetInteger(id,CHART_HEIGHT_IN_PIXELS);
//---
   m_speed_graph.Refresh(width,height);
//   if(m_dialog.Height()
//   m_dialog.Create(id,"MD5 Cloud Decryptor",0,0,22,width,height);
//   m_dialog.Show();
//---
  }
//+------------------------------------------------------------------+
//| Event handling                                                   |
//+------------------------------------------------------------------+
bool CMD5Visualizer::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Calling the basic processing
   bool res=m_dialog.OnEvent(id,lparam,dparam,sparam);
//--- If not processed, check the change of dimensions
   if(!res)
      if(id==CHARTEVENT_CHART_CHANGE)
        {
         long cid=ChartID();
         int  width =(int)ChartGetInteger(cid,CHART_WIDTH_IN_PIXELS);
         int  height=(int)ChartGetInteger(cid,CHART_HEIGHT_IN_PIXELS);
         //---
         if(m_dialog.Height()!=height || m_dialog.Width()!=width)
           {
            m_dialog.Width(width);
            m_dialog.Height(height-22);
            m_speed_text.Move(width/2,height/2);
            m_speed_graph.Move(5,height/2+30);
            m_speed_graph.Refresh(width-9,height/2-34);
            ChartRedraw();
           }
        }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMD5Visualizer::OnTimer()
  {
//--- Have the calculations started?
   if(m_start_time!=0)
     {
      uint   curtime=GetTickCount();
      double speed=0.0;
      //--- Haven't the calculations stopped?
      if((curtime-m_last_time)<5000) // Haven't the calculations stopped?
        {
         double delta=(m_last_time-m_start_time)/1000.0;
         if(delta>0.1)
            speed=m_total_blocks/delta;
        }
      //--- Show the speed in figures
      m_speed_text.Text(DoubleToString(speed,2)+" mln per second");
      //--- Add the value to the histogram of speed
      m_speed_graph.AddValue(speed);
     }
//--- Update
   m_speed_graph.Update();
  }
//+------------------------------------------------------------------+
//| Adding results accumulated for 1 sec                             |
//+------------------------------------------------------------------+
void CMD5Visualizer::AddResult(const double passes)
  {
//--- Save the last upload time
   m_last_time=GetTickCount();
//--- If it is the first call, correct the starting position
   if(m_start_time==0)
     {
      m_start_time=m_last_time;
      m_total_blocks=0.0;
     }
//--- Adding the counted blocks
   m_total_blocks+=passes;
  }
//+------------------------------------------------------------------+
