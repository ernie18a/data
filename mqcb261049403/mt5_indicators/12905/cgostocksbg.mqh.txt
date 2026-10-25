//+------------------------------------------------------------------+
//|                                                  CGOStocksBG.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#include <Object.mqh> 
#include "CGStockAsBG.mqh"
//+------------------------------------------------------------------+
//| Class creates background with all main stocks                    |
//+------------------------------------------------------------------+
class CGOStocksBG : CObject
  {
protected:
   long           m_id;                                                    // graph ID
   int            m_subwin;                                                // subwindow index
   int            m_scheme;                                                // current scheme
   bool           m_created;                                               // true if all objects cteated
   bool           m_caption;                                               // text in caption
   datetime       m_dt_start;                                              // checking datetime
   string         m_prefix;                                                // common prefix
   string         m_suffix;                                                // additional suffix
   int            m_top_indent;                                            // indent from top
   int            m_bottom_indent;                                         // indent from bottom
   int            m_ydist[15];                                             // y-distance array
   int            m_window_height;
   CGStockAsBG    *m_ptr_stock_bg0;                                        // pointer to the CGStockAsBG Tokio
   CGStockAsBG    *m_ptr_stock_bg1;                                        // pointer to the CGStockAsBG Singapure
   CGStockAsBG    *m_ptr_stock_bg2;                                        // pointer to the CGStockAsBG Shanghai
   CGStockAsBG    *m_ptr_stock_bg3;                                        // pointer to the CGStockAsBG Dubai
   CGStockAsBG    *m_ptr_stock_bg4;                                        // pointer to the CGStockAsBG Moscow
   CGStockAsBG    *m_ptr_stock_bg5;                                        // pointer to the CGStockAsBG London
   CGStockAsBG    *m_ptr_stock_bg6;                                        // pointer to the CGStockAsBG Zurich
   CGStockAsBG    *m_ptr_stock_bg7;                                        // pointer to the CGStockAsBG Frankfurt
   CGStockAsBG    *m_ptr_stock_bg8;                                        // pointer to the CGStockAsBG Yohannensburg
   CGStockAsBG    *m_ptr_stock_bg9;                                        // pointer to the CGStockAsBG Riyadh
   CGStockAsBG    *m_ptr_stock_bg10;                                       // pointer to the CGStockAsBG NewYork
   CGStockAsBG    *m_ptr_stock_bg11;                                       // pointer to the CGStockAsBG Toronto
   CGStockAsBG    *m_ptr_stock_bg12;                                       // pointer to the CGStockAsBG Chicago
   CGStockAsBG    *m_ptr_stock_bg13;                                       // pointer to the CGStockAsBG Wellington
   CGStockAsBG    *m_ptr_stock_bg14;                                       // pointer to the CGStockAsBG Sidnay
public:
   CGOStocksBG(datetime aDTime,                                            // checked datetime
               int      aTop=0,                                            // top indent
               int      aDown=20,                                          // bottom indent
               int      aScheme=0,                                         // color scheme
               string   aPrefix="ST_",                                     // common name prefix if needed
               string   aSuffix="",                                        // common hame suffix if needed
               bool     aCaption=false,                                    // show text in caption
               long     aID=0,                                             // chart ID
               int      aSubwin=0);                                        // subwindow index
   ~CGOStocksBG();
   int            GetWindowHeight(long chart_ID=0,int sub_window=0);       // Get window height in pixels
   void           ProcessingStocks(datetime aDTime);                           // Setting positions
   void           SetPositionsDefaults(void);                              // Setting positions defaults
   void           ReDraw(void)   {ChartRedraw(m_id);}                      // chart redrawing 
   bool           Created(void) {return(m_created);}                       // true when class created
   void           DeInit(void);                                            // deinit method
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGOStocksBG::CGOStocksBG(datetime aDTime,
                         int aTop=0,
                         int aDown=20,
                         int aScheme=0,
                         string aPrefix="ST_",
                         string aSuffix="",
                         bool aCaption=false,
                         long aID=0,
                         int aSubwin=0)
  {
   m_created=false;
   m_scheme=aScheme;
   m_prefix=aPrefix;
   m_suffix=aSuffix;
   m_id=aID;
   m_subwin=aSubwin;
   m_caption=aCaption;
   m_window_height=GetWindowHeight(m_id,m_subwin);
   m_top_indent=aTop;
   m_bottom_indent=aDown;
   m_dt_start=aDTime;
   int indent,band,free_space;
   free_space=m_window_height-300-m_top_indent-m_bottom_indent; 
   indent=free_space/16;
   band=m_window_height / 15;
   m_ydist[0]=indent+m_top_indent;
   for(int i=1;i<15;i++)
     m_ydist[i]=m_ydist[i-1]+indent+20;
   m_ptr_stock_bg0=new CGStockAsBG(Tokio,m_dt_start,m_ydist[0],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg1=new CGStockAsBG(Singapore,m_dt_start,m_ydist[1],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg2=new CGStockAsBG(Shanghai,m_dt_start,m_ydist[2],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg3=new CGStockAsBG(Dubai,m_dt_start,m_ydist[3],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg4=new CGStockAsBG(Moscow,m_dt_start,m_ydist[4],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg5=new CGStockAsBG(London,m_dt_start,m_ydist[5],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg6=new CGStockAsBG(Zurich,m_dt_start,m_ydist[6],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg7=new CGStockAsBG(Frankfurt,m_dt_start,m_ydist[7],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg8=new CGStockAsBG(Yohannensburg,m_dt_start,m_ydist[8],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg9=new CGStockAsBG(Riyadh,m_dt_start,m_ydist[9],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg10=new CGStockAsBG(NewYork,m_dt_start,m_ydist[10],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg11=new CGStockAsBG(Toronto,m_dt_start,m_ydist[11],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg12=new CGStockAsBG(Chicago,m_dt_start,m_ydist[12],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg13=new CGStockAsBG(Wellington,m_dt_start,m_ydist[13],m_prefix,m_suffix,m_scheme);
   m_ptr_stock_bg14=new CGStockAsBG(Sidney,m_dt_start,m_ydist[14],m_prefix,m_suffix,m_scheme);
   if(m_ptr_stock_bg0.Created()&&
      m_ptr_stock_bg1.Created()&&
      m_ptr_stock_bg2.Created()&&
      m_ptr_stock_bg3.Created()&&
      m_ptr_stock_bg4.Created()&&
      m_ptr_stock_bg5.Created()&&
      m_ptr_stock_bg6.Created()&&
      m_ptr_stock_bg7.Created()&&
      m_ptr_stock_bg8.Created()&&
      m_ptr_stock_bg9.Created()&&
      m_ptr_stock_bg10.Created()&&
      m_ptr_stock_bg11.Created()&&
      m_ptr_stock_bg12.Created()&&
      m_ptr_stock_bg13.Created()&&
      m_ptr_stock_bg14.Created())
         m_created=true;
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void CGOStocksBG::DeInit(void)
  {
   delete m_ptr_stock_bg0;   
   delete m_ptr_stock_bg1;   
   delete m_ptr_stock_bg2;   
   delete m_ptr_stock_bg3;   
   delete m_ptr_stock_bg4;   
   delete m_ptr_stock_bg5;   
   delete m_ptr_stock_bg6;   
   delete m_ptr_stock_bg7;   
   delete m_ptr_stock_bg8;   
   delete m_ptr_stock_bg9;   
   delete m_ptr_stock_bg10;   
   delete m_ptr_stock_bg11;   
   delete m_ptr_stock_bg12;   
   delete m_ptr_stock_bg13;   
   delete m_ptr_stock_bg14;   
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGOStocksBG::~CGOStocksBG()
  {
   DeInit();
  }
//+------------------------------------------------------------------+
//| Set positions for all objects                                    |
//+------------------------------------------------------------------+
void CGOStocksBG::ProcessingStocks(datetime aDTime)
  {
   m_dt_start=aDTime;
   m_window_height=GetWindowHeight(m_id,m_subwin);
   int indent,band,free_space;
   free_space=m_window_height-300-m_top_indent-m_bottom_indent; 
   indent=free_space/16;
   band=m_window_height / 15;
   m_ydist[0]=indent+m_top_indent;
   for(int i=1;i<15;i++)
      m_ydist[i]=m_ydist[i-1]+indent+20;
   if(m_created)
     {
      m_ptr_stock_bg0.SetPositionProps(m_dt_start,m_ydist[0]);
      m_ptr_stock_bg0.ProcessingColor(m_dt_start);
      m_ptr_stock_bg1.SetPositionProps(m_dt_start,m_ydist[1]);
      m_ptr_stock_bg1.ProcessingColor(m_dt_start);
      m_ptr_stock_bg2.SetPositionProps(m_dt_start,m_ydist[2]);
      m_ptr_stock_bg2.ProcessingColor(m_dt_start);
      m_ptr_stock_bg3.SetPositionProps(m_dt_start,m_ydist[3]);
      m_ptr_stock_bg3.ProcessingColor(m_dt_start);
      m_ptr_stock_bg4.SetPositionProps(m_dt_start,m_ydist[4]);
      m_ptr_stock_bg4.ProcessingColor(m_dt_start);
      m_ptr_stock_bg5.SetPositionProps(m_dt_start,m_ydist[5]);
      m_ptr_stock_bg5.ProcessingColor(m_dt_start);
      m_ptr_stock_bg6.SetPositionProps(m_dt_start,m_ydist[6]);
      m_ptr_stock_bg6.ProcessingColor(m_dt_start);
      m_ptr_stock_bg7.SetPositionProps(m_dt_start,m_ydist[7]);
      m_ptr_stock_bg7.ProcessingColor(m_dt_start);
      m_ptr_stock_bg8.SetPositionProps(m_dt_start,m_ydist[8]);
      m_ptr_stock_bg8.ProcessingColor(m_dt_start);
      m_ptr_stock_bg9.SetPositionProps(m_dt_start,m_ydist[9]);
      m_ptr_stock_bg9.ProcessingColor(m_dt_start);
      m_ptr_stock_bg10.SetPositionProps(m_dt_start,m_ydist[10]);
      m_ptr_stock_bg10.ProcessingColor(m_dt_start);
      m_ptr_stock_bg11.SetPositionProps(m_dt_start,m_ydist[11]);
      m_ptr_stock_bg11.ProcessingColor(m_dt_start);
      m_ptr_stock_bg12.SetPositionProps(m_dt_start,m_ydist[12]);
      m_ptr_stock_bg12.ProcessingColor(m_dt_start);
      m_ptr_stock_bg13.SetPositionProps(m_dt_start,m_ydist[13]);
      m_ptr_stock_bg13.ProcessingColor(m_dt_start);
      m_ptr_stock_bg14.SetPositionProps(m_dt_start,m_ydist[14]);
      m_ptr_stock_bg14.ProcessingColor(m_dt_start);
     }
  }
//+------------------------------------------------------------------+
//| Set positions for all objects                                    |
//+------------------------------------------------------------------+
void CGOStocksBG::SetPositionsDefaults(void)
  {
   m_dt_start=TimeCurrent();
   if(m_created)
     {
      m_ptr_stock_bg0.SetPositionPropsXY();
      m_ptr_stock_bg1.SetPositionPropsXY();
      m_ptr_stock_bg2.SetPositionPropsXY();
      m_ptr_stock_bg3.SetPositionPropsXY();
      m_ptr_stock_bg4.SetPositionPropsXY();
      m_ptr_stock_bg5.SetPositionPropsXY();
      m_ptr_stock_bg6.SetPositionPropsXY();
      m_ptr_stock_bg7.SetPositionPropsXY();
      m_ptr_stock_bg8.SetPositionPropsXY();
      m_ptr_stock_bg9.SetPositionPropsXY();
      m_ptr_stock_bg10.SetPositionPropsXY();
      m_ptr_stock_bg11.SetPositionPropsXY();
      m_ptr_stock_bg12.SetPositionPropsXY();
      m_ptr_stock_bg13.SetPositionPropsXY();
      m_ptr_stock_bg14.SetPositionPropsXY();
     }
  }
//+------------------------------------------------------------------+
//| Get window height in pixels                                      |
//+------------------------------------------------------------------+
int CGOStocksBG::GetWindowHeight(long chart_ID=0,int sub_window=0)
  {
   long result=-1;
   ResetLastError();
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
   return((int)result);
  }
