//+------------------------------------------------------------------+
//|                                                       CStock.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Project Stocks"
#include "StockStruct.mqh"
//+------------------------------------------------------------------+
//| Stock names and schedules                                        |
//+------------------------------------------------------------------+
class CStock
  {
protected:
   STOCK_NAME     m_stock;                                                 // enum stock name
   datetime       m_tm_shift_srv_gmt;                                      // datetime shift between server time and gmt(utc) time
   datetime       m_srv_utc_delta;                                         // server time minus utc(gmt) time 
   datetime       m_timeopen;                                              // open time
   datetime       m_timeclose;                                             // close time  
   string         m_stock_name;                                            // stock object name
   string         m_stock_text;                                            // stock object displayed text 
   bool           m_caps;                                                  // caps on/off
   bool           m_active_stock;                                          // stock is active  
   bool           m_created;                       
public:
   CStock(STOCK_NAME aStock=Tokio,bool aCaps=false);                       // displayed stock with caps on/off
   ~CStock();
   bool           DSTime(datetime aTime,datetime &aSummer,bool checkSrv=false); // return true when Daylight Saving Time is applyed
   void           StockShedule(datetime aTime,                             // input datetime
                               datetime &aDTOpen,                          // open datetime
                               datetime &aDTClose);                        // close datetime
   datetime       SetTimeOpen(datetime aSrvTime,int aSrvHH,int aSrvMM);    // set server open time
   bool           StockIsActive(void) {return(m_active_stock);}            // return true if the stock is active
   datetime       StockTimeOpen(void) {return(m_timeopen);}                // return stock open time
   datetime       StockTimeClose(void) {return(m_timeclose);}              // return stock close time
   string         StockText(bool aCaps);                                   // return text for the object
   string         StockName(string aPrefix="",string aSuffix="");          // return name for the object
   datetime       ChangeWeekend(datetime aTime);                          // Saturday is changing in Monday
   bool           Created(void)        {return(m_created);}                // checking creating of the object
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStock::CStock(STOCK_NAME aStock=0,bool aCaps=false)
  {
   m_stock=aStock;                                                         // enum stock name
   m_caps=aCaps;                                                           // display with caps on/off
   m_tm_shift_srv_gmt=TimeTradeServer()-TimeGMT();
   m_created=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStock::~CStock()
  {
  }
//+------------------------------------------------------------------+
//| Daylight Saving Time                                             |
//| Input : Datetime to check                                        |
//| Output: Datetime corrected by DST if needed                      |
//| if checkSrv is true the method returns above for the server      |
//+------------------------------------------------------------------+
bool CStock::DSTime(datetime aTime,datetime &aSummer,bool checkSrv=false)
  {
   MqlDateTime stm,s_stm;
   //datetime s_time;
   TimeToStruct(aTime,stm);
   // it is suggested that the server is in the North Hemishera
   if(checkSrv==true)
     {
         if(stm.mon<3 && stm.mon>0)                                        // Winter. North
            return(false);
         // Last Sunday of March
         if(stm.mon==3)                                                    // The month of Daylight Saving Time. North. Europe 
           {   
            if(stm.day>25&&(stm.day+7-stm.day_of_week)>31)                 // The week of Daylight Saving Time. North. Europe
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                          
            else
               return(false);
           }
         if(stm.mon>3 && stm.mon<10)                                       // Summer. North
            {
             s_stm.day=stm.day;
             s_stm.day_of_week=stm.day_of_week;
             s_stm.day_of_year=stm.day_of_year;
             s_stm.hour=stm.hour-1;
             s_stm.min=stm.min;
             s_stm.mon=stm.mon;
             s_stm.sec=stm.sec;
             s_stm.year=stm.year;
             aSummer=StructToTime(s_stm);
             return(true);
            }          
         if(stm.mon==10)                                                   // The month of changing to winter time. North
           {   
            if(stm.day>25&&(stm.day+7-stm.day_of_week)>31)                 // The week of changing to winter time. North
               return(false);
            else
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                         
           }
         if(stm.mon>10 && stm.mon<=12)                                     // Winter Time. North
            return(false);
     }
   switch (m_stock)
     {
      case Tokio:                                                          // DST not used
      case Singapore:
      case Shanghai:
      case Dubai:
      case Moscow:                                                         // Moscow stock is unimportant for a while
      case Yohannensburg:
      case Riyadh:
          return(false);                                                
         break;
      case London:
      case Zurich:
      case Frankfurt:
         if(stm.mon<3 && stm.mon>0)                                        // Winter. North
            return(false);
         // Last Sunday of March
         if(stm.mon==3)                                                    // The month of Daylight Saving Time. North. Europe 
           {   
            if(stm.day>25&&(stm.day+7-stm.day_of_week)>31)                 // The week of Daylight Saving Time. North. Europe
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                          
            else
               return(false);
           }
         if(stm.mon>3 && stm.mon<10)                                       // Summer. North
            {
             s_stm.day=stm.day;
             s_stm.day_of_week=stm.day_of_week;
             s_stm.day_of_year=stm.day_of_year;
             s_stm.hour=stm.hour-1;
             s_stm.min=stm.min;
             s_stm.mon=stm.mon;
             s_stm.sec=stm.sec;
             s_stm.year=stm.year;
             aSummer=StructToTime(s_stm);
             return(true);
            }          
         if(stm.mon==10)                                                   // The month of changing to winter time. North
           {   
            if(stm.day>25&&(stm.day+7-stm.day_of_week)>31)                 // The week of changing to winter time. North
               return(false);
            else
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                         
           }
         if(stm.mon>10 && stm.mon<=12)                                     // Winter Time. North
            return(false);
         break;
      case NewYork:
      case Chicago:
      case Toronto:
         if(stm.mon<3 && stm.mon>0)                                        // Winter. North
            return(false);
         // Second Sunday of March 
         if(stm.mon==3)                                                    // The month of Daylight Saving Time. North. America 
           {   
            if(stm.day>7&&(stm.day+stm.day_of_week)>14)                    // The week of Daylight Saving Time. North. America
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                                            // Time changed to summer time
            else
               return(false);
           }
         if(stm.mon>3 && stm.mon<11)                                       // Summer. North
            { 
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
            }          
         // First Sunday of November 
         if(stm.mon==11)                                                   // Stop the month of Daylight Saving Time. North. America 
           {   
            if(stm.day>0&&(stm.day+stm.day_of_week)>7)                     // Stop the week of Daylight Saving Time. North. America
               return(false);                                              // Time changed to summer time
            else
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                                 
           }
         if(stm.mon==12)                                                   // Winter Time. North
            return(false);          
         break;
      case Wellington:
         if(stm.mon<4 && stm.mon>0)                                        // Summer. South
           {
            s_stm.day=stm.day;
            s_stm.day_of_week=stm.day_of_week;
            s_stm.day_of_year=stm.day_of_year;
            s_stm.hour=stm.hour-1;
            s_stm.min=stm.min;
            s_stm.mon=stm.mon;
            s_stm.sec=stm.sec;
            s_stm.year=stm.year;
            aSummer=StructToTime(s_stm);
            return(true);
           }
         // First Sunday of April
         if(stm.mon==4)                                                    // The month to stop the Daylight Saving Time. South. 
           {   
            if(stm.day>0&&(stm.day+stm.day_of_week)>7)                     // The week Stop of Daylight Saving Time. North. America
               return(false);                                              // Time changed to Winter time
            else
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                             
           }
         if(stm.mon>4 && stm.mon<9)                                        // Winter. South
             return(false);
         // The last week of september
         if(stm.mon==9)                                                    // The month of changing to Summer time. South
           {   
            if(stm.day>25&&(stm.day+7-stm.day_of_week)>31)                 // The week of changing to Summer time. South
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                        
            else
               return(false);
           }
         if(stm.mon>9 && stm.mon<=12)                                      // Summer. South
           {
            s_stm.day=stm.day;
            s_stm.day_of_week=stm.day_of_week;
            s_stm.day_of_year=stm.day_of_year;
            s_stm.hour=stm.hour-1;
            s_stm.min=stm.min;
            s_stm.mon=stm.mon;
            s_stm.sec=stm.sec;
            s_stm.year=stm.year;
            aSummer=StructToTime(s_stm);
            return(true);
           }                                         
         break;
      case Sidney:
         if(stm.mon<4 && stm.mon>0)                                        // Summer. South
           {
            s_stm.day=stm.day;
            s_stm.day_of_week=stm.day_of_week;
            s_stm.day_of_year=stm.day_of_year;
            s_stm.hour=stm.hour-1;
            s_stm.min=stm.min;
            s_stm.mon=stm.mon;
            s_stm.sec=stm.sec;
            s_stm.year=stm.year;
            aSummer=StructToTime(s_stm);
            return(true);
           }
         // First Sunday of April
         if(stm.mon==4)                                                    // The month to stop the Daylight Saving Time. South. 
           {   
            if(stm.day>0&&(stm.day+stm.day_of_week)>7)                     // The week Stop of Daylight Saving Time. North. America
               return(false);                                              // Time changed to Winter time
            else
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                             
           }
         if(stm.mon>4 && stm.mon<10)                                       // Winter. South
             return(false);
         if(stm.mon==10)                                                   // The month of changing to Summer time. South
           {   
           // The first week of october
            if(stm.day>0&&(stm.day+7-stm.day_of_week)>7)                   // The week of changing to Summer time. South
              {
               s_stm.day=stm.day;
               s_stm.day_of_week=stm.day_of_week;
               s_stm.day_of_year=stm.day_of_year;
               s_stm.hour=stm.hour-1;
               s_stm.min=stm.min;
               s_stm.mon=stm.mon;
               s_stm.sec=stm.sec;
               s_stm.year=stm.year;
               aSummer=StructToTime(s_stm);
               return(true);
              }                                        
            else
               return(false);
           }
         if(stm.mon>10 && stm.mon<=12)                                     // Summer. South
           {
            s_stm.day=stm.day;
            s_stm.day_of_week=stm.day_of_week;
            s_stm.day_of_year=stm.day_of_year;
            s_stm.hour=stm.hour-1;
            s_stm.min=stm.min;
            s_stm.mon=stm.mon;
            s_stm.sec=stm.sec;
            s_stm.year=stm.year;
            aSummer=StructToTime(s_stm);
            return(true);
           }                                         
         break;
     }
    return(false);                                 
  }
//+------------------------------------------------------------------+
//| Set server open time                                             |
//|                                                                  |
//+------------------------------------------------------------------+
datetime CStock::SetTimeOpen(datetime aSrvTime,int aSrvHH,int aSrvMM)
  {
   MqlDateTime stm_srv;
   datetime aTime00;
   if(aSrvHH>=24) aSrvHH=aSrvHH-24;
   TimeToStruct(aSrvTime,stm_srv);
   stm_srv.hour=aSrvHH;
   stm_srv.min=aSrvMM;
   stm_srv.sec=0;
   aTime00=StructToTime(stm_srv);
   return(aTime00);
  }
//+------------------------------------------------------------------+
//| Set server open time                                             |    
//|                                                                  |
//+------------------------------------------------------------------+
datetime CStock::ChangeWeekend(datetime aTime)
  {
   datetime dt_changed=aTime;
   MqlDateTime stm;
   TimeToStruct(aTime,stm);
   if(stm.day_of_week==6)
     dt_changed=aTime+172800;
   if(stm.day_of_week==0)
     dt_changed=aTime-172800;
   return(dt_changed);
  }
//+------------------------------------------------------------------+
//| Stock WorkTime                                                   |
//| Input : Datetime to calculate                                    |
//| Output: Datetime stock open                                      |
//| Output: Datetime stock close                                     |
//| The server is placed in Europe, so there is no need to change    |
//| time for Europeen stocks                                         |
//+------------------------------------------------------------------+
void CStock::StockShedule(datetime aTime,datetime &aDTOpen,datetime &aDTClose)
  {
   int one_hour_seconds=3600;
   int srv_shift=(int)m_tm_shift_srv_gmt/3600;
   datetime dummy;
   bool server_summer=DSTime(aTime,dummy,true);
   bool stock_summer;
   
   switch (m_stock)
     {
      case Tokio:                        
         if(!server_summer)    
            aDTOpen=SetTimeOpen(aTime,0+srv_shift,0);
         else
            aDTOpen=SetTimeOpen(aTime,1+srv_shift,0);
         aDTClose=aDTOpen+6*one_hour_seconds;                              // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Singapore:
         if(!server_summer)    
            aDTOpen=SetTimeOpen(aTime,1+srv_shift,0);
         else
            aDTOpen=SetTimeOpen(aTime,2+srv_shift,0);
         aDTClose=aDTOpen+8*one_hour_seconds;                              // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Shanghai:
         if(!server_summer)    
            aDTOpen=SetTimeOpen(aTime,1+srv_shift,30);
         else
            aDTOpen=SetTimeOpen(aTime,2+srv_shift,30);
         aDTClose=aDTOpen+5*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Dubai:
         if(!server_summer)    
            aDTOpen=SetTimeOpen(aTime,6+srv_shift,0);
         else
            aDTOpen=SetTimeOpen(aTime,7+srv_shift,0);
         aDTClose=aDTOpen+3*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Moscow:
         //it is supposed that Moscow don't change time at all
         //if(server_summer)    
         aDTOpen=SetTimeOpen(aTime,6+srv_shift,0);
         aDTClose=aDTOpen+8*one_hour_seconds+(one_hour_seconds/4)*3;       // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case London:
         if(server_summer)    
            aDTOpen=SetTimeOpen(aTime,7+srv_shift,0);
         else
            aDTOpen=SetTimeOpen(aTime,8+srv_shift,0);
         aDTClose=aDTOpen+8*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Zurich:
         aDTOpen=SetTimeOpen(aTime,7+srv_shift,0);
         aDTClose=aDTOpen+8*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Frankfurt:
         aDTOpen=SetTimeOpen(aTime,7+srv_shift,0);
         aDTClose=aDTOpen+8*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Yohannensburg:
         aDTOpen=SetTimeOpen(aTime,7+srv_shift,0);
         aDTClose=aDTOpen+8*one_hour_seconds;                              // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Riyadh:
         if(!server_summer)    
            aDTOpen=SetTimeOpen(aTime,8+srv_shift,0);
         else
            aDTOpen=SetTimeOpen(aTime,9+srv_shift,0);
         aDTClose=aDTOpen+4*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case NewYork:
         stock_summer=DSTime(aTime,dummy);
         if(!server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,14+srv_shift,30);
         if(!server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,13+srv_shift,30);
         if(server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,14+srv_shift,30);
         if(server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,13+srv_shift,30);
         aDTClose=aDTOpen+6*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Toronto:
         stock_summer=DSTime(aTime,dummy);
         if(!server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,14+srv_shift,30);
         if(!server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,13+srv_shift,30);
         if(server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,14+srv_shift,30);
         if(server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,13+srv_shift,30);
         aDTClose=aDTOpen+6*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Chicago:
         stock_summer=DSTime(aTime,dummy);
         if(!server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,14+srv_shift,30);
         if(!server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,13+srv_shift,30);
         if(server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,14+srv_shift,30);
         if(server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,13+srv_shift,30);
         aDTClose=aDTOpen+6*one_hour_seconds+one_hour_seconds/2;           // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Wellington:
         stock_summer=DSTime(aTime,dummy);
         if(!server_summer&&stock_summer)                     
            aDTOpen=SetTimeOpen(aTime,21+srv_shift,0);    
         if(!server_summer&&!stock_summer)                    
            aDTOpen=SetTimeOpen(aTime,22+srv_shift,0);                   
         if(server_summer&&stock_summer)                      
            aDTOpen=SetTimeOpen(aTime,23+srv_shift,0);                             ///???????????????
         if(server_summer&&!stock_summer)                     
            aDTOpen=SetTimeOpen(aTime,22+srv_shift,0);
         aDTClose=aDTOpen+6*one_hour_seconds+(one_hour_seconds/4)*3;       // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
      case Sidney:
         stock_summer=DSTime(aTime,dummy);
         if(!server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,23+srv_shift,0);
         if(!server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,0+srv_shift,0);                             ///???????????????
         if(server_summer&&stock_summer)
            aDTOpen=SetTimeOpen(aTime,1+srv_shift,0);                             ///???????????????
         if(server_summer&&!stock_summer)
            aDTOpen=SetTimeOpen(aTime,0+srv_shift,0);
         aDTClose=aDTOpen+6*one_hour_seconds;                              // stock server close time
         aDTClose=ChangeWeekend(aDTClose);
         break;
     }         
  }
//+------------------------------------------------------------------+
//| return text for the object                                       |
//+------------------------------------------------------------------+
string CStock::StockText(bool aCaps=false)
  {
   string ret_str="";
   switch (m_stock)
     {
      case Tokio:
         if(aCaps) ret_str="TOKIO";
         else ret_str="Tokio";
         break;
      case Singapore:
         if(aCaps) ret_str="SINGAPORE";
         else ret_str="Singapore";
         break;
      case Shanghai:
         if(aCaps) ret_str="SHANGHAI";
         else ret_str="Shanghai";
         break;
      case Dubai:
         if(aCaps) ret_str="DUBAI";
         else ret_str="Dubai";
         break;
      case Moscow:
         if(aCaps) ret_str="MOSCOW";
         else ret_str="Moscow";
         break;
      case London:
         if(aCaps) ret_str="LONDON";
         else ret_str="London";
         break;
      case Zurich:
         if(aCaps) ret_str="ZURICH";
         else ret_str="Zurich";
         break;
      case Frankfurt:
         if(aCaps) ret_str="FRANKFURT";
         else ret_str="Frankfurt";
         break;
      case Yohannensburg:
         if(aCaps) ret_str="YOHANNENSBURG";
         else ret_str="Yohannensburg";
         break;
      case Riyadh:
         if(aCaps) ret_str="RIYADH";
         else ret_str="Riyadh";
         break;
      case NewYork:
         if(aCaps) ret_str="NEW YORK";
         else ret_str="New York";
         break;
      case Toronto:
         if(aCaps) ret_str="TORONTO";
         else ret_str="Toronto";
         break;
      case Chicago:
         if(aCaps) ret_str="CHICAGO";
         else ret_str="Chicago";
         break;
      case Wellington:
         if(aCaps) ret_str="WELLINGTON";
         else ret_str="Wellington";
         break;
      case Sidney:
         if(aCaps) ret_str="SIDNEY";
         else ret_str="Sidney";
         break;
     }
   //Alert(ret_str+IntegerToString((int)m_stock));
    return(ret_str);
  }
//+------------------------------------------------------------------+
//| return name for the object                                       |
//+------------------------------------------------------------------+
string CStock::StockName(string aPrefix="",string aSuffix="")
  {
   string ret_str="";
   switch (m_stock)
     {
      case Tokio:
         ret_str=aPrefix+"Tok_"+aSuffix;
         break;
      case Singapore:
         ret_str=aPrefix+"Sin_"+aSuffix;
         break;
      case Shanghai:
         ret_str=aPrefix+"Sha_"+aSuffix;
         break;
      case Dubai:
         ret_str=aPrefix+"Dub_"+aSuffix;
         break;
      case Moscow:
         ret_str=aPrefix+"Mos_"+aSuffix;
         break;
      case London:
         ret_str=aPrefix+"Lon_"+aSuffix;
         break;
      case Zurich:
         ret_str=aPrefix+"Zur_"+aSuffix;
         break;
      case Frankfurt:
         ret_str=aPrefix+"Fra_"+aSuffix;
         break;
      case Yohannensburg:
         ret_str=aPrefix+"Yoh_"+aSuffix;
         break;
      case Riyadh:
         ret_str=aPrefix+"Riy_"+aSuffix;
         break;
      case NewYork:
         ret_str=aPrefix+"New_"+aSuffix;
         break;
      case Toronto:
         ret_str=aPrefix+"Tor_"+aSuffix;
         break;
      case Chicago:
         ret_str=aPrefix+"Chi_"+aSuffix;
         break;
      case Wellington:
         ret_str=aPrefix+"Wel_"+aSuffix;
         break;
      case Sidney:
         ret_str=aPrefix+"Sid_"+aSuffix;
         break;
     }
    return(ret_str);
  }
//+------------------------------------------------------------------+
