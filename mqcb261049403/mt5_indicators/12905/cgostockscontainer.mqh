//+------------------------------------------------------------------+
//|                                           CGOStocksContainer.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#include <Arrays\ArrayObj.mqh>
#include "CGOStocksBG.mqh"
//+------------------------------------------------------------------+
//| The class is for managing CGOStockBG's                           |
//+------------------------------------------------------------------+
class CGOStocksContainer
  {
protected:
   long           m_id;                                                    // chart ID
   int            m_subwin;                                                // subwindow index
   int            m_scheme;                                                // current scheme
   bool           m_created;                                               // true if all objects cteated
   bool           m_caption;                                               // text in caption
   datetime       m_dt_start[];                                            // checking start datetimes
   string         m_prefix;                                                // common prefix
   string         m_suffix[];                                              // additional suffix
   int            m_total;                                                 // total CGOStocksBG-objects in serisa
   int            m_current;                                               // current index in the seria of m_total
   int            m_top_indent;                                            // indent from top
   int            m_bottom_indent;                                         // indent from bottom
   CArrayObj      *m_container_stock;                                      // pointer to the containeg stock
public:
   CGOStocksContainer(datetime& aDTime[],                                  // datetime array
                      int      aTop=0,                                     // top indent
                      int      aDown=20,                                   // bottom indent
                      int      aScheme=0,                                  // color scheme
                      string   aPrefix="ST_",                              // common name prefix if needed
                      int      aTotal=1,                                   // number of datetimes
                      bool     aCaption=false,                             // show text in caption
                      long     aID=0,                                      // chart ID
                      int      aSubwin=0);                                 // subwindow index
   ~CGOStocksContainer();
   //getting
   CArrayObj      *GetStocks(void) {return(m_container_stock);}            // get stocks in seria
   CGOStocksBG    *GetPtrToStocks(void) {return(m_container_stock.At(m_current));} // get access to the current CGOStocksBG-object
   int            GetTotal(void) {return(m_total);}                        // get total number of CGOStocksBG-objects
   // setting
   void           SetCurrentIndex(int aIndex) {m_current=aIndex;}          // set index in seria
   void           SetAllStocks(void);                                      // set all CGOStocks-objects
   // other
   void           ProcessingAllStocks(datetime& aDTime[]);                 // processing all stocks
   void           DeInit(void);                                            // deinit method
   void           ReDraw(void)   {ChartRedraw(m_id);}                      // chart redrawing 
   void           DeleteByPrefix(string aPrefix);                          // delete objects by prefix
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGOStocksContainer::CGOStocksContainer(datetime& aDTime[],
                                       int aTop=0,
                                       int aDown=20,
                                       int aScheme=0,
                                       string aPrefix="ST_",
                                       int aTotal=1,
                                       bool aCaption=false,
                                       long aID=0,
                                       int aSubwin=0)
  {
   // store all variables
   m_id=aID;
   m_subwin=aSubwin;
   m_scheme=aScheme;
   m_top_indent=aTop;
   m_bottom_indent=aDown;
   m_caption=aCaption;
   m_total=aTotal;
   m_prefix=aPrefix;
   ArrayResize(m_dt_start,m_total);                                        // resize and fill datetime checking array 
   ArrayResize(m_suffix,m_total);                                          // resize and fill suffix array
   for(int i=0;i<m_total;i++)
     {
      m_dt_start[i]=aDTime[i];                                             // store datetimes in inner array
      m_suffix[i]=IntegerToString(i,3,'0');                                // suffix for the whole of seria
     }
   m_container_stock=new CArrayObj;                                        // create container for CGOStocksBG-objects  
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGOStocksContainer::~CGOStocksContainer()
  {
   m_container_stock.DeleteRange(0,m_total-1);
   delete m_container_stock;
  }
//+------------------------------------------------------------------+
//| DeInitialization                                                 |
//+------------------------------------------------------------------+
void CGOStocksContainer::DeInit(void)
  {
   CGOStocksBG *ptr_stocks_bg;
   for(int i=0;i<m_total;i++)
     {
      SetCurrentIndex(i);
      ptr_stocks_bg=GetPtrToStocks();
      ptr_stocks_bg.DeInit();
     }
   m_container_stock.DeleteRange(0,m_total-1);
   delete m_container_stock;
  }
//+------------------------------------------------------------------+
//| Processing all stocks                                            |
//+------------------------------------------------------------------+
void CGOStocksContainer::ProcessingAllStocks(datetime& aDTime[])
  {
   CGOStocksBG *ptr_stocks_bg;
   ptr_stocks_bg=GetPtrToStocks();
   for(int i=0;i<m_total;i++)
     {
      SetCurrentIndex(i);
      ptr_stocks_bg=GetPtrToStocks();
      m_dt_start[i]=aDTime[i];                                             // refresh datetimes in inner array
      ptr_stocks_bg.ProcessingStocks(m_dt_start[i]);
     }
  }
//+------------------------------------------------------------------+
//| Set all CGOStocks-objects                                        |
//+------------------------------------------------------------------+
void CGOStocksContainer::SetAllStocks(void)
  {
   for(int i=0;i<m_total;i++)
     {
      // create CGOStocks-objects
      CGOStocksBG *stocks_bg=new CGOStocksBG(m_dt_start[i],m_top_indent,m_bottom_indent,m_scheme,m_prefix,m_suffix[i],m_caption,m_id,m_subwin);
      stocks_bg.SetPositionsDefaults();      
      m_container_stock.Add(stocks_bg);                                    // add stock as ONE object to the container
     }
   ReDraw();
  }
//+------------------------------------------------------------------+
//| Delete all CGOStocks-objects by prefix                           |
//+------------------------------------------------------------------+
void CGOStocksContainer::DeleteByPrefix(string aPrefix)
  {
   string obj_name;
   int obj_total = ObjectsTotal(0,0,-1);
   for(int i=obj_total-1;i>=0;i--)
     {
      obj_name = ObjectName(0,i,0,-1);
      if(StringFind(obj_name,aPrefix,0)==0)
         ObjectDelete(0,obj_name);
     }
  }
//+------------------------------------------------------------------+

