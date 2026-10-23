//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright   "pipwolfie@gmail.com"
#property description "Buffer Inspector"
#property version     "1.4"
#property script_show_inputs 
#property description "Extracts ticks, ohlc, heiken-ashi ohlc, bar body, bar range & all buffers of indicators on the chart"

//+-------------------------------------------------------------------------------------------------------------------------------------+
//+ User Input Variables 
//+-------------------------------------------------------------------------------------------------------------------------------------+
input datetime inptStart     = D'2019.07.01 00:00:00';   // start
input datetime inptEnd       = D'2019.12.31 23:59:59';   // end
input bool     inptOhlc      = true;                     // extract ohlc
input bool     inptMedian    = true;                     // calculate OHLC median   price (H+L)/2
input bool     inpttypical   = true;                     // calculate OHLC typical  price (H+L+C)/3    
input bool     inptweighted  = true;                     // calculate OHLC weighted price (H+L+C+C)/4    
input bool     inptRange     = true;                     // calculate bar range (H-L)
input bool     inptBody      = true;                     // calculate bar body (C-O)  
input bool     inptTrueRange = true;                     // calculate true range(Max(H-L, ABS(prev H-C), ABS(prev L-C))
input bool     inptHOhlc     = true;                     // calculate heiken-ashi
input bool     inptTVolume   = true;                     // extract tick volume
input bool     inptRVolume   = false;                    // extract real volume (not available for all brokers)
input bool     inptBuffers   = true;                     // extract indicator buffers
input bool     inptTicks     = false;                    // extract ticks ( creates separate file )
input string   inptFileName  = "BI4_";                   // File name ( symbol & time frame are appended )
//+--------------------------------------------------------------------------------------------------------------------------------------+

// Buffer Info
struct buff_buff
  {
   double            buffer[];  // Buffer Raw
  };
// Indicator Buffers
struct indc_buffer
  {
   string            indicator;    //Indicator Name
   int               ihdl;            //Indicator handle
   buff_buff         buffers[]; //buffer Info Data
  };

//--- File name to be written
string m_file_name;
string m_file_name_ticks;
int    m_total_bars;
int    m_total_ticks;
//+------------------------------------------------------------------+
//| Start
//+------------------------------------------------------------------+
void OnStart()
  {

   string result;
   ResetLastError();


   if(!GetBuffers())
      result="FAILURE: "+LastError();
   else {
   
      string m_tick_descr;
      if ( inptTicks ) {
         m_tick_descr = " and " + IntegerToString(m_total_ticks) + " ticks";
      }
   
      result="SUCCESS: "+IntegerToString(m_total_bars)+" bars" + m_tick_descr + " calculated";
   }

   Comment("");
   
   Print(result);
   Alert(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidateInputs()
  {

//--- Set File name and check for existance 
   m_file_name=inptFileName;
   StringAdd(m_file_name,Symbol());
   StringAdd(m_file_name,"_");
   StringAdd(m_file_name,TimeFrameToString(Period()));
   StringConcatenate(m_file_name_ticks,m_file_name,"_ticks");
   StringAdd(m_file_name,".csv");
   StringAdd(m_file_name_ticks,".csv");

   if(FileIsExist(m_file_name) || FileIsExist(m_file_name_ticks))
     {
      SetUserError(3);
      return false;
     }

   if(FileIsExist(m_file_name))
     {
      SetUserError(3);
      return false;
     }



//--- Validate Input Date Range
   if(inptEnd<=inptStart)
     {
      SetUserError(1);
      return false;
     }

//--- Validate Input Conditionals 
   if(!inptOhlc && 
      !inptHOhlc && 
      !inptRange && 
      !inptBody && 
      !inptMedian && 
      !inpttypical && 
      !inptweighted && 
      !inptRVolume && 
      !inptTVolume && 
      !inptBuffers && 
      !inptTicks)
     {
      SetUserError(2);
      return(false);
     }

   return(true);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetBuffers()
  {

   if( !ValidateInputs() ) return(false);

   Comment("Starting Buffer Extraction ... Please wait");

   double      m_open[];        //Open
   double      m_high[];        //High
   double      m_low[];         //Low
   double      m_close[];       //Close
   datetime    m_time[];        //Time
   long        m_rvol[];        //Real Volume
   long        m_tvol[];        //Tick Volume
   indc_buffer m_rsc_buff[];    //Hold Buffers
   int         m_gtot_ind;      //Total Indicators

//--- get ohlc & volume data. Use one period behind chosen date for heiken-ashi
   if( CopyOpen(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_open)       <= 0 ) return false;
   if( CopyHigh(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_high)       <= 0 ) return false;
   if( CopyLow(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_low)         <= 0 ) return false;
   if( CopyClose(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_close)     <= 0 ) return false;
   if( CopyTime(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_time)       <= 0 ) return false;
   if( CopyTickVolume(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_tvol) <= 0 ) return false;
   if( CopyRealVolume(Symbol(),Period(),inptStart-PeriodSeconds(),inptEnd,m_rvol) <= 0 ) return false;

//--- Count total bars
   m_total_bars = ArraySize(m_open)-1;
   long chart   = ChartID();
   m_gtot_ind   = 0;

//--- indicator buffer counter for file output 
   int m_tot_buff=0;

//--- Get total available windows
   long m_total_wind=ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL);

//--- Ittr Windows
   for(int w=0; w<m_total_wind && !_StopFlag;++w)
     {
        {

         //--- Get total available indicators in window 
         int m_total_ind=ChartIndicatorsTotal(ChartID(),w);

         //-- Ittr Indicators
         for(int i=0; i<m_total_ind && !_StopFlag; i++)
           {

            //--- resize m_rsc_buff
            m_gtot_ind=ArraySize(m_rsc_buff);
            ArrayResize(m_rsc_buff,m_gtot_ind+1);

            //--- assign array node indicator details 
            m_rsc_buff[m_gtot_ind].indicator   = ChartIndicatorName(chart,w,i);
            m_rsc_buff[m_gtot_ind].ihdl        = ChartIndicatorGet(chart,w,m_rsc_buff[m_gtot_ind].indicator);
            int m_bidx=0;

            //--- Ittr indefinitely for indicator buffers 
            for(;;)
              {

               //--- Make buffer place holder
               double m_ibuf[];

               //--- make sure there is a buffer at this index
               if(CopyBuffer(m_rsc_buff[m_gtot_ind].ihdl,m_bidx,inptStart-PeriodSeconds(),inptEnd,m_ibuf)<=0)
                 {
                  break;
                 }

               m_tot_buff++;

               //--- if there is a buffer grab it
               ArrayResize(m_rsc_buff[m_gtot_ind].buffers,m_bidx+1);
               ArrayCopy(m_rsc_buff[m_gtot_ind].buffers[m_bidx].buffer,m_ibuf);

               //--- Kill place holder
               ArrayFree(m_ibuf);
               ZeroMemory(m_ibuf);

               m_bidx++;

              }
           }
        }
     }

   int m_file_handle=FileOpen(m_file_name,FILE_READ|FILE_WRITE|FILE_CSV);
   if(m_file_handle < 0) return (false);


//--- create header row based on user input conditionals 
   string m_header="time";
   if(inptOhlc) StringAdd(m_header,"\topen\thigh\tlow\tclose");
   if(inptMedian) StringAdd(m_header,"\tmedian");
   if(inpttypical) StringAdd(m_header,"\ttypical");
   if(inptweighted) StringAdd(m_header,"\tweighted");
   if(inptBody) StringAdd(m_header,"\tbody");
   if(inptRange) StringAdd(m_header,"\trange");
   if(inptTrueRange)StringAdd(m_header,"\ttrue range");
   if(inptTVolume) StringAdd(m_header,"\ttick volume");
   if(inptRVolume) StringAdd(m_header,"\treal volume");
   if(inptHOhlc) StringAdd(m_header,"\theiken-ashi open\theiken-ashi high\theiken-ashi low\theiken-ashi close");

//--- Append indicator buffer headers if any
   if(inptBuffers)
     {
      for(int h=0; h<ArraySize(m_rsc_buff);h++)
        {
         for(int b=0;b<ArraySize(m_rsc_buff[h].buffers);b++)
           {
            StringAdd(m_header,"\t");
            StringAdd(m_header,m_rsc_buff[h].indicator);
            StringAdd(m_header," buffer ");
            StringAdd(m_header,IntegerToString(b));
           }
        }
     }

//--- Write header row
   FileWrite(m_file_handle,m_header);

//--- Write header row   for(int x=1;x<ArraySize(m_time);x++){
   for(int x=1;x<ArraySize(m_time);x++)
     {
      //--- Make time easier for Excel
      string m_ts=TimeToString(m_time[x]);
      StringReplace(m_ts,".","/");
      string m_row=m_ts;

      //--- Concat OHLC
      if(inptOhlc)
        {
         StringAdd(m_row,StringFormat("\t%G",m_open[x]));
         StringAdd(m_row,StringFormat("\t%G",m_high[x]));
         StringAdd(m_row,StringFormat("\t%G",m_low[x]));
         StringAdd(m_row,StringFormat("\t%G",m_close[x]));
        }

      //--- Concat Median
      if(inptMedian) StringAdd(m_row,StringFormat("\t%G",(m_high[x]+m_low[x])/2));

      //--- Concat Typical
      if(inpttypical) StringAdd(m_row,StringFormat("\t%G",(m_high[x]+m_low[x]+m_close[x])/3));

      //--- Concat Weighted
      if(inptweighted) StringAdd(m_row,StringFormat("\t%G",(m_high[x]+m_low[x]+m_close[x]+m_close[x])/4));

      //--- Concat Body
      if(inptBody) StringAdd(m_row,StringFormat("\t%G",m_close[x]-m_open[x]));

      //--- Concat Range
      if(inptRange) StringAdd(m_row,StringFormat("\t%G",m_high[x]-m_low[x]));

      //--- Concat True Range
      if(inptTrueRange) StringAdd(m_row,StringFormat("\t%G",MathMax(m_high[x],m_close[x-1])-MathMin(m_low[x],m_close[x-1])));

      //--- Concat Tick Volume
      if(inptTVolume) StringAdd(m_row,StringFormat("\t%G",m_tvol[x]));

      //--- Concat Real Volume
      if(inptRVolume) StringAdd(m_row,StringFormat("\t%G",m_rvol[x]));

      //--- Concat Heiken-Ashi OHLC
      if(inptHOhlc)
        {
         StringAdd(m_row,StringFormat("\t%G",(m_open[x-1]+m_close[x-1])/2));
         StringAdd(m_row,StringFormat("\t%G",MathMax(MathMax(m_high[x],m_close[x]),m_open[x])));
         StringAdd(m_row,StringFormat("\t%G",MathMin(MathMin(m_low[x],m_close[x]),m_open[x])));
         StringAdd(m_row,StringFormat("\t%G",(m_open[x]+m_high[x]+m_low[x]+m_close[x])/4));
        }

      if(inptBuffers)
        {
         for(int h=0; h<ArraySize(m_rsc_buff);h++)
            for(int b=0;b<ArraySize(m_rsc_buff[h].buffers);b++)
              {
               StringAdd(m_row,StringFormat("\t%G",m_rsc_buff[h].buffers[b].buffer[x]));
              }
        }

      FileWrite(m_file_handle,m_row);

     }

   FileClose(m_file_handle);

   //--- Save tick data if required
   if ( inptTicks ) {   
      Comment("Starting Tick Save ... Please wait");
      MqlTick m_ticks[];
      if ( CopyTicksRange(Symbol(),m_ticks,COPY_TICKS_ALL,inptStart*1000,inptEnd*1000) <= 0 ) return false;
      m_total_ticks  = ArraySize(m_ticks);
      m_file_handle  = FileOpen(m_file_name_ticks,FILE_READ|FILE_WRITE|FILE_CSV);
      if(m_file_handle < 0) return (false);      
      
      //--- Write tick header
      FileWrite(m_file_handle,"time\ttime msc\tbid\task\tlast\ttick volume\treal volume"); 
      for(int i=0;i<m_total_ticks;i++) {
       
         //--- Make time easier for Excel
         string m_ts=TimeToString(m_ticks[i].time);
         StringReplace(m_ts,".","/");
         string m_tick_row=m_ts;
         
         //--- Write tick data 
         StringAdd(m_tick_row,StringFormat("\t%G",m_ticks[i].time_msc));
         StringAdd(m_tick_row,StringFormat("\t%G",m_ticks[i].bid));
         StringAdd(m_tick_row,StringFormat("\t%G",m_ticks[i].ask));
         StringAdd(m_tick_row,StringFormat("\t%G",m_ticks[i].last));
         StringAdd(m_tick_row,StringFormat("\t%G",m_ticks[i].volume));
         StringAdd(m_tick_row,StringFormat("\t%G",m_ticks[i].volume_real));
         
         FileWrite(m_file_handle,m_tick_row); 
      }
   }
   
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeFrameToString(ENUM_TIMEFRAMES tframe)
  {
   if( tframe == PERIOD_M1 )  return  "M1";
   if( tframe == PERIOD_M2 )  return  "M2";
   if( tframe == PERIOD_M3 )  return  "M3";
   if( tframe == PERIOD_M4 )  return  "M4";
   if( tframe == PERIOD_M5 )  return  "M5";
   if( tframe == PERIOD_M6 )  return  "M6";
   if( tframe == PERIOD_M10 ) return "M10";
   if( tframe == PERIOD_M15 ) return "M15";
   if( tframe == PERIOD_M20 ) return "M20";
   if( tframe == PERIOD_M30 ) return "M30";
   if( tframe == PERIOD_H1 )  return "H1";
   if( tframe == PERIOD_H2 )  return "H2";
   if( tframe == PERIOD_H3 )  return "H3";
   if( tframe == PERIOD_H4 )  return "H4";
   if( tframe == PERIOD_H6 )  return "H6";
   if( tframe == PERIOD_H8 )  return "H8";
   if( tframe == PERIOD_D1 )  return "D1";
   if( tframe == PERIOD_MN1 ) return "MN1";
   if( tframe == PERIOD_W1 )  return "W1";

   return "UNKNOWN PERIOD";

  }
//+------------------------------------------------------------------+
string LastError()
  {
   string descr=GetErrorDescription(GetLastError());
   ResetLastError();
   return descr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetErrorDescription(int errCode)
  {

   if( errCode == ( ERR_USER_ERROR_FIRST + 1 ) ) return "End Date must be after start date";
   if( errCode == ( ERR_USER_ERROR_FIRST + 2 ) ) return "At least one condition must be true";
   if( errCode == ( ERR_USER_ERROR_FIRST + 3 ) ) return "File already exists. Please remove this file and try again";

   switch(errCode)
     {
      case ERR_SUCCESS:
         return "The operation completed successfully";
      case ERR_INTERNAL_ERROR:
         return "Unexpected internal error";
      case ERR_WRONG_INTERNAL_PARAMETER:
         return "Wrong parameter in the inner call of the client terminal function";
      case ERR_INVALID_PARAMETER:
         return "Wrong parameter when calling the system function";
      case ERR_NOT_ENOUGH_MEMORY:
         return "Not enough memory to perform the system function";
      case ERR_STRUCT_WITHOBJECTS_ORCLASS:
         return "The structure contains objects of strings and/or dynamic arrays and/or structure of such objects and/or classes";
      case ERR_INVALID_ARRAY:
         return "Array of a wrong type, wrong size, or a damaged object of a dynamic array";
      case ERR_ARRAY_RESIZE_ERROR:
         return "Not enough memory for the relocation of an array, or an attempt to change the size of a static array";
      case ERR_STRING_RESIZE_ERROR:
         return "Not enough memory for the relocation of string";
      case ERR_NOTINITIALIZED_STRING:
         return "Not initialized string";
      case ERR_INVALID_DATETIME:
         return "Invalid date and/or time";
      case ERR_ARRAY_BAD_SIZE:
         return "Requested array size exceeds 2 GB";
      case ERR_INVALID_POINTER:
         return "Wrong pointer";
      case ERR_INVALID_POINTER_TYPE:
         return "Wrong type of pointer";
      case ERR_FUNCTION_NOT_ALLOWED:
         return "Function is not allowed for call";
      case ERR_RESOURCE_NAME_DUPLICATED:
         return "The names of the dynamic and the static resource match";
      case ERR_RESOURCE_NOT_FOUND:
         return "Resource with this name has not been found in EX5";
      case ERR_RESOURCE_UNSUPPOTED_TYPE:
         return "Unsupported resource type or its size exceeds 16 Mb";
      case ERR_RESOURCE_NAME_IS_TOO_LONG:
         return "The resource name exceeds 63 characters";
      case ERR_MATH_OVERFLOW:
         return "Overflow occurred when calculating math function";
      case ERR_CHART_WRONG_ID:
         return "Wrong chart ID";
      case ERR_CHART_NO_REPLY:
         return "Chart does not respond";
      case ERR_CHART_NOT_FOUND:
         return "Chart not found";
      case ERR_CHART_NO_EXPERT:
         return "No Expert Advisor in the chart that could handle the event";
      case ERR_CHART_CANNOT_OPEN:
         return "Chart opening error";
      case ERR_CHART_CANNOT_CHANGE:
         return "Failed to change chart symbol and period";
      case ERR_CHART_WRONG_PARAMETER:
         return "Error value of the parameter for the function of working with charts";
      case ERR_CHART_CANNOT_CREATE_TIMER:
         return "Failed to create timer";
      case ERR_CHART_WRONG_PROPERTY:
         return "Wrong chart property ID";
      case ERR_CHART_SCREENSHOT_FAILED:
         return "Error creating screenshots";
      case ERR_CHART_NAVIGATE_FAILED:
         return "Error navigating through chart";
      case ERR_CHART_TEMPLATE_FAILED:
         return "Error applying template";
      case ERR_CHART_WINDOW_NOT_FOUND:
         return "Subwindow containing the indicator was not found";
      case ERR_CHART_INDICATOR_CANNOT_ADD:
         return "Error adding an indicator to chart";
      case ERR_CHART_INDICATOR_CANNOT_DEL:
         return "Error deleting an indicator from the chart";
      case ERR_CHART_INDICATOR_NOT_FOUND:
         return "Indicator not found on the specified chart";
      case ERR_OBJECT_ERROR:
         return "Error working with a graphical object";
      case ERR_OBJECT_NOT_FOUND:
         return "Graphical object was not found";
      case ERR_OBJECT_WRONG_PROPERTY:
         return "Wrong ID of a graphical object property";
      case ERR_OBJECT_GETDATE_FAILED:
         return "Unable to get date corresponding to the value";
      case ERR_OBJECT_GETVALUE_FAILED:
         return "Unable to get value corresponding to the date";
      case ERR_MARKET_UNKNOWN_SYMBOL:
         return "Unknown symbol";
      case ERR_MARKET_NOT_SELECTED:
         return "Symbol is not selected in MarketWatch";
      case ERR_MARKET_WRONG_PROPERTY:
         return "Wrong identifier of a symbol property";
      case ERR_MARKET_LASTTIME_UNKNOWN:
         return "Time of the last tick is not known (no ticks)";
      case ERR_MARKET_SELECT_ERROR:
         return "Error adding or deleting a symbol in MarketWatch";
      case ERR_HISTORY_NOT_FOUND:
         return "Requested history not found";
      case ERR_HISTORY_WRONG_PROPERTY:
         return "Wrong ID of the history property";
      case ERR_HISTORY_TIMEOUT:
         return "Exceeded history request timeout";
      case ERR_HISTORY_BARS_LIMIT:
         return "Number of requested bars limited by terminal settings";
      case ERR_HISTORY_LOAD_ERRORS:
         return "Multiple errors when loading history";
      case ERR_HISTORY_SMALL_BUFFER:
         return "Receiving array is too small to store all requested data";
      case ERR_GLOBALVARIABLE_NOT_FOUND:
         return "Global variable of the client terminal is not found";
      case ERR_GLOBALVARIABLE_EXISTS:
         return "Global variable of the client terminal with the same name already exists";
      case ERR_GLOBALVARIABLE_NOT_MODIFIED:
         return "Global variables were not modified";
      case ERR_GLOBALVARIABLE_CANNOTREAD:
         return "Cannot read file with global variable values";
      case ERR_GLOBALVARIABLE_CANNOTWRITE:
         return "Cannot write file with global variable values";
      case ERR_MAIL_SEND_FAILED:
         return "Email sending failed";
      case ERR_PLAY_SOUND_FAILED:
         return "Sound playing failed";
      case ERR_MQL5_WRONG_PROPERTY:
         return "Wrong identifier of the program property";
      case ERR_TERMINAL_WRONG_PROPERTY:
         return "Wrong identifier of the terminal property";
      case ERR_FTP_SEND_FAILED:
         return "File sending via ftp failed";
      case ERR_NOTIFICATION_SEND_FAILED:
         return "Failed to send a notification";
      case ERR_NOTIFICATION_WRONG_PARAMETER:
         return "Invalid parameter for sending a notification – an empty string or NULL has been passed to the SendNotification() function";
      case ERR_NOTIFICATION_WRONG_SETTINGS:
         return "Wrong settings of notifications in the terminal (ID is not specified or permission is not set)";
      case ERR_NOTIFICATION_TOO_FREQUENT:
         return "Too frequent sending of notifications";
      case ERR_FTP_NOSERVER:
         return "FTP server is not specified";
      case ERR_FTP_NOLOGIN:
         return "FTP login is not specified";
      case ERR_FTP_FILE_ERROR:
         return "File not found in the MQL5\\Files directory to send on FTP server";
      case ERR_FTP_CONNECT_FAILED:
         return "FTP connection failed";
      case ERR_FTP_CHANGEDIR:
         return "FTP path not found on server";
      case 4524:
         return "FTP connection closed";
      case ERR_BUFFERS_NO_MEMORY:
         return "Not enough memory for the distribution of indicator buffers";
      case ERR_BUFFERS_WRONG_INDEX:
         return "Wrong indicator buffer index";
      case ERR_CUSTOM_WRONG_PROPERTY:
         return "Wrong ID of the custom indicator property";
      case ERR_ACCOUNT_WRONG_PROPERTY:
         return "Wrong account property ID";
      case ERR_TRADE_WRONG_PROPERTY:
         return "Wrong trade property ID";
      case ERR_TRADE_DISABLED:
         return "Trading by Expert Advisors prohibited";
      case ERR_TRADE_POSITION_NOT_FOUND:
         return "Position not found";
      case ERR_TRADE_ORDER_NOT_FOUND:
         return "Order not found";
      case ERR_TRADE_DEAL_NOT_FOUND:
         return "Deal not found";
      case ERR_TRADE_SEND_FAILED:
         return "Trade request sending failed";
      case ERR_TRADE_CALC_FAILED:
         return "Failed to calculate profit or margin";
      case ERR_INDICATOR_UNKNOWN_SYMBOL:
         return "Unknown symbol";
      case ERR_INDICATOR_CANNOT_CREATE:
         return "Indicator cannot be created";
      case ERR_INDICATOR_NO_MEMORY:
         return "Not enough memory to add the indicator";
      case ERR_INDICATOR_CANNOT_APPLY:
         return "The indicator cannot be applied to another indicator";
      case ERR_INDICATOR_CANNOT_ADD:
         return "Error applying an indicator to chart";
      case ERR_INDICATOR_DATA_NOT_FOUND:
         return "Requested data not found";
      case ERR_INDICATOR_WRONG_HANDLE:
         return "Wrong indicator handle";
      case ERR_INDICATOR_WRONG_PARAMETERS:
         return "Wrong number of parameters when creating an indicator";
      case ERR_INDICATOR_PARAMETERS_MISSING:
         return "No parameters when creating an indicator";
      case ERR_INDICATOR_CUSTOM_NAME:
         return "The first parameter in the array must be the name of the custom indicator";
      case ERR_INDICATOR_PARAMETER_TYPE:
         return "Invalid parameter type in the array when creating an indicator";
      case ERR_INDICATOR_WRONG_INDEX:
         return "Wrong index of the requested indicator buffer";
      case ERR_BOOKS_CANNOT_ADD:
         return "ERR_BOOKS_CANNOT_ADD";
      case ERR_BOOKS_CANNOT_DELETE:
         return "Depth Of Market can not be removed";
      case ERR_BOOKS_CANNOT_GET:
         return "The data from Depth Of Market can not be obtained";
      case ERR_BOOKS_CANNOT_SUBSCRIBE:
         return "Error in subscribing to receive new data from Depth Of Market";
      case ERR_TOO_MANY_FILES:
         return "More than 64 files cannot be opened at the same time";
      case ERR_WRONG_FILENAME:
         return "Invalid file name";
      case ERR_TOO_LONG_FILENAME:
         return "Too long file name";
      case ERR_CANNOT_OPEN_FILE:
         return "File opening error";
      case ERR_FILE_CACHEBUFFER_ERROR:
         return "Not enough memory for cache to read";
      case ERR_CANNOT_DELETE_FILE:
         return "File deleting error";
      case ERR_INVALID_FILEHANDLE:
         return "A file with this handle was closed, or was not opening at all";
      case ERR_WRONG_FILEHANDLE:
         return "Wrong file handle";
      case ERR_FILE_NOTTOWRITE:
         return "The file must be opened for writing";
      case ERR_FILE_NOTTOREAD:
         return "The file must be opened for reading";
      case ERR_FILE_NOTBIN:
         return "The file must be opened as a binary one";
      case ERR_FILE_NOTTXT:
         return "The file must be opened as a text";
      case ERR_FILE_NOTTXTORCSV:
         return "The file must be opened as a text or CSV";
      case ERR_FILE_NOTCSV:
         return "The file must be opened as CSV";
      case ERR_FILE_READERROR:
         return "File reading error";
      case ERR_FILE_BINSTRINGSIZE:
         return "String size must be specified, because the file is opened as binary";
      case ERR_INCOMPATIBLE_FILE:
         return "A text file must be for string arrays, for other arrays - binary";
      case ERR_FILE_IS_DIRECTORY:
         return "This is not a file, this is a directory";
      case ERR_FILE_NOT_EXIST:
         return "File does not exist";
      case ERR_FILE_CANNOT_REWRITE:
         return "File can not be rewritten";
      case ERR_WRONG_DIRECTORYNAME:
         return "Wrong directory name";
      case ERR_DIRECTORY_NOT_EXIST:
         return "Directory does not exist";
      case ERR_FILE_ISNOT_DIRECTORY:
         return "This is a file, not a directory";
      case ERR_CANNOT_DELETE_DIRECTORY:
         return "The directory cannot be removed";
      case ERR_CANNOT_CLEAN_DIRECTORY:
         return "Failed to clear the directory (probably one or more files are blocked and removal operation failed)";
      case ERR_FILE_WRITEERROR:
         return "Failed to write a resource to a file";
      case ERR_FILE_ENDOFFILE:
         return "Unable to read the next piece of data from a CSV file (FileReadString, FileReadNumber, FileReadDatetime, FileReadBool), since the end of file is reached";
      case ERR_NO_STRING_DATE:
         return "No date in the string";
      case ERR_WRONG_STRING_DATE:
         return "Wrong date in the string";
      case ERR_WRONG_STRING_TIME:
         return "Wrong time in the string";
      case ERR_STRING_TIME_ERROR:
         return "Error converting string to date";
      case ERR_STRING_OUT_OF_MEMORY:
         return "Not enough memory for the string";
      case ERR_STRING_SMALL_LEN:
         return "The string length is less than expected";
      case ERR_STRING_TOO_BIGNUMBER:
         return "Too large number, more than ULONG_MAX";
      case ERR_WRONG_FORMATSTRING:
         return "Invalid format string";
      case ERR_TOO_MANY_FORMATTERS:
         return "Amount of format specifiers more than the parameters";
      case ERR_TOO_MANY_PARAMETERS:
         return "Amount of parameters more than the format specifiers";
      case ERR_WRONG_STRING_PARAMETER:
         return "Damaged parameter of string type";
      case ERR_STRINGPOS_OUTOFRANGE:
         return "Position outside the string";
      case ERR_STRING_ZEROADDED:
         return "0 added to the string end, a useless operation";
      case ERR_STRING_UNKNOWNTYPE:
         return "Unknown data type when converting to a string";
      case ERR_WRONG_STRING_OBJECT:
         return "Damaged string object";
      case ERR_INCOMPATIBLE_ARRAYS:
         return "Copying incompatible arrays. String array can be copied only to a string array, and a numeric array - in numeric array only";
      case ERR_SMALL_ASSERIES_ARRAY:
         return "The receiving array is declared as AS_SERIES, and it is of insufficient size";
      case ERR_SMALL_ARRAY:
         return "Too small array, the starting position is outside the array";
      case ERR_ZEROSIZE_ARRAY:
         return "An array of zero length";
      case ERR_NUMBER_ARRAYS_ONLY:
         return "Must be a numeric array0";
      case ERR_ONEDIM_ARRAYS_ONLY:
         return "Must be a one-dimensional array";
      case ERR_SERIES_ARRAY:
         return "Timeseries cannot be used";
      case ERR_DOUBLE_ARRAY_ONLY:
         return "Must be an array of type double";
      case ERR_FLOAT_ARRAY_ONLY:
         return "Must be an array of type float";
      case ERR_LONG_ARRAY_ONLY:
         return "Must be an array of type long";
      case ERR_INT_ARRAY_ONLY:
         return "Must be an array of type int";
      case ERR_SHORT_ARRAY_ONLY:
         return "Must be an array of type short";
      case ERR_CHAR_ARRAY_ONLY:
         return "Must be an array of type char";
      case ERR_STRING_ARRAY_ONLY:
         return "String array only";
      case ERR_OPENCL_NOT_SUPPORTED:
         return "OpenCL functions are not supported on this computer";
      case ERR_OPENCL_INTERNAL:
         return "Internal error occurred when running OpenCL";
      case ERR_OPENCL_INVALID_HANDLE:
         return "Invalid OpenCL handle";
      case ERR_OPENCL_CONTEXT_CREATE:
         return "Error creating the OpenCL context";
      case ERR_OPENCL_QUEUE_CREATE:
         return "Failed to create a run queue in OpenCL";
      case ERR_OPENCL_PROGRAM_CREATE:
         return "Error occurred when compiling an OpenCL program";
      case ERR_OPENCL_TOO_LONG_KERNEL_NAME:
         return "Too long kernel name (OpenCL kernel)";
      case ERR_OPENCL_KERNEL_CREATE:
         return "Error creating an OpenCL kernel";
      case ERR_OPENCL_SET_KERNEL_PARAMETER:
         return "Error occurred when setting parameters for the OpenCL kernel";
      case ERR_OPENCL_EXECUTE:
         return "OpenCL program runtime error";
      case ERR_OPENCL_WRONG_BUFFER_SIZE:
         return "Invalid size of the OpenCL buffer";
      case ERR_OPENCL_WRONG_BUFFER_OFFSET:
         return "Invalid offset in the OpenCL buffer";
      case ERR_OPENCL_BUFFER_CREATE:
         return "Failed to create an OpenCL buffer";
      case ERR_OPENCL_TOO_MANY_OBJECTS:
         return "Too many OpenCL objects";
      case ERR_OPENCL_SELECTDEVICE:
         return "OpenCL device selection error";
      case ERR_WEBREQUEST_INVALID_ADDRESS:
         return "Invalid URL";
      case ERR_WEBREQUEST_CONNECT_FAILED:
         return "Failed to connect to specified URL";
      case ERR_WEBREQUEST_TIMEOUT:
         return "Timeout exceeded";
      case ERR_WEBREQUEST_REQUEST_FAILED:
         return "HTTP request failed";
      case ERR_NOT_CUSTOM_SYMBOL:
         return "A custom symbol must be specified";
      case ERR_CUSTOM_SYMBOL_WRONG_NAME:
         return "The name of the custom symbol is invalid. The symbol name can only contain Latin letters without punctuation, spaces or special characters (may only contain \".\", \"_\", \"&\" and \"#\"). It is not recommended to use characters <, >, :, \", /,\\, |, ?, *.\";";
      case ERR_CUSTOM_SYMBOL_NAME_LONG:
         return "The name of the custom symbol is too long. The length of the symbol name must not exceed 32 characters including the ending 0 character";
      case ERR_CUSTOM_SYMBOL_PATH_LONG:
         return "The path of the custom symbol is too long. The path length should not exceed 128 characters including \"Custom\", the symbol name, group separators and the ending 0";
      case ERR_CUSTOM_SYMBOL_EXIST:
         return "A custom symbol with the same name already exists";
      case ERR_CUSTOM_SYMBOL_ERROR:
         return "Error occurred while creating, deleting or changing the custom symbol";
      case ERR_CUSTOM_SYMBOL_SELECTED:
         return "You are trying to delete a custom symbol selected in Market Watch";
      case ERR_CUSTOM_SYMBOL_PROPERTY_WRONG:
         return "An invalid custom symbol property";
      case ERR_CUSTOM_SYMBOL_PARAMETER_ERROR:
         return "A wrong parameter while setting the property of a custom symbol";
      case ERR_CUSTOM_SYMBOL_PARAMETER_LONG:
         return  "A too long string parameter while setting the property of a custom symbol";
      case ERR_CUSTOM_TICKS_WRONG_ORDER:
         return "Ticks in the array are not arranged in the order of time";
      case ERR_USER_ERROR_FIRST:
         return "User defined errors start with this code";

     }

   return "UNKNOWN";
  }
//+------------------------------------------------------------------+
