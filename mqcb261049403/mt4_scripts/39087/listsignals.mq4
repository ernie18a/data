//---------------------------------------------------------------------------------------------------------------------
#define     MName          "List Signals"
#define     MVersion       "1.210"
#define     MBuild         "2022-09-03 12:24 WEST"
#define     MCopyright     "Copyright \x00A9 2022, Fernando M. I. Carreiro, All rights reserved"
#define     MProfile       "https://www.mql5.com/en/users/FMIC"
//---------------------------------------------------------------------------------------------------------------------
#property   strict
#property   version        MVersion
#property   description    MName
#property   description    "MetaTrader Script (Build "MBuild")"
#property   copyright      MCopyright
#property   link           MProfile
//---------------------------------------------------------------------------------------------------------------------

// Script Setup
   #property script_show_inputs

// Script inputs
   input string
      sFileName  = "SignalsData.csv",  // File name of CSV file
      sDelimeter = "\t",               // Delimeter character (default = TAB)
      sDecimal   = ",",                // Decimal character
      sDate      = "-";                // Date delimiter character
   input int
      nDigits    = 2;                  // Number of decimal digits for floating point numbers

// Declare list of properties to collect
   ENUM_SIGNAL_BASE_STRING g_eStringProperty[] =
      { SIGNAL_BASE_NAME, SIGNAL_BASE_AUTHOR_LOGIN, SIGNAL_BASE_BROKER, SIGNAL_BASE_BROKER_SERVER, SIGNAL_BASE_CURRENCY };
   ENUM_SIGNAL_BASE_INTEGER g_eDateProperty[] =
      { SIGNAL_BASE_DATE_PUBLISHED, SIGNAL_BASE_DATE_STARTED, SIGNAL_BASE_DATE_UPDATED };
   ENUM_SIGNAL_BASE_INTEGER g_eIntegerProperty[] =
      { SIGNAL_BASE_ID, SIGNAL_BASE_LEVERAGE, SIGNAL_BASE_PIPS, SIGNAL_BASE_RATING, SIGNAL_BASE_SUBSCRIBERS, SIGNAL_BASE_TRADES, SIGNAL_BASE_TRADE_MODE };
   ENUM_SIGNAL_BASE_DOUBLE g_eDoubleProperty[] =
      { SIGNAL_BASE_BALANCE, SIGNAL_BASE_EQUITY, SIGNAL_BASE_GAIN, SIGNAL_BASE_MAX_DRAWDOWN, SIGNAL_BASE_PRICE, SIGNAL_BASE_ROI };

// OnStart event handler
   void OnStart() {
      int nSinglsTotal = SignalBaseTotal();
      if( nSinglsTotal > 0 ) {
         int hSignalsFile=FileOpen( sFileName, FILE_WRITE | FILE_CSV | FILE_ANSI, "", CP_UTF8 );
         if( hSignalsFile != INVALID_HANDLE ) {
            FileWriteString( hSignalsFile, sField( "INDEX", false ) );
            for( int i = 0; i < ArraySize( g_eStringProperty ); i++ )
               FileWriteString( hSignalsFile, eField( g_eStringProperty[  i ] ) );
            for( int i = 0; i < ArraySize( g_eDateProperty ); i++ )
               FileWriteString( hSignalsFile, eField( g_eDateProperty[    i ] ) );
            for( int i = 0; i < ArraySize( g_eIntegerProperty ); i++ )
               FileWriteString( hSignalsFile, eField( g_eIntegerProperty[ i ] ) );
            for( int i = 0; i < ArraySize( g_eDoubleProperty ); i++ )
               FileWriteString( hSignalsFile, eField( g_eDoubleProperty[  i ] ) );
            FileWriteString( hSignalsFile, "\n" );
            for( int j = 0; j < nSinglsTotal; j++ ) {
               if( SignalBaseSelect( j ) ) {
                  FileWriteString( hSignalsFile, (string) j );
                  for( int i = 0; i < ArraySize( g_eStringProperty ); i++ )
                     FileWriteString( hSignalsFile, sField( SignalBaseGetString(  g_eStringProperty[  i ] ) ) );
                  for( int i = 0; i < ArraySize( g_eDateProperty ); i++ )
                     FileWriteString( hSignalsFile, dtField( SignalBaseGetInteger( g_eDateProperty[   i ] ) ) );
                  for( int i = 0; i < ArraySize( g_eIntegerProperty ); i++ )
                     FileWriteString( hSignalsFile, lField( SignalBaseGetInteger( g_eIntegerProperty[ i ] ) ) );
                  for( int i = 0; i < ArraySize( g_eDoubleProperty ); i++ )
                     FileWriteString( hSignalsFile, dbField( SignalBaseGetDouble( g_eDoubleProperty[  i ] ) ) );
               };
               FileWriteString( hSignalsFile, "\n" );
            };
            FileClose( hSignalsFile );
         }
         else
            Print( "Invalid file handle!" );
      }
      else
         Print( "No Signals!" );
   };

// Supprt functions
   string sField(  string   sValue,  bool bDelimeter = true ) { return ( bDelimeter ? sDelimeter : "" ) + sValue; };
   string lField(  long     lValue,  bool bDelimeter = true ) { return sField( IntegerToString( lValue  ), bDelimeter ); };
   string dtField( datetime dtValue, bool bDelimeter = true ) {
      string sValue = TimeToString( dtValue );
      StringReplace( sValue, ".", sDate );
      return sField( sValue, bDelimeter ); };
   string dbField( double   dbValue, bool bDelimeter = true ) {
      string sValue = DoubleToString( dbValue, nDigits );
      StringReplace( sValue, ".", sDecimal );
      return sField( sValue, bDelimeter ); };
   template<typename T>
      string eField( T eValue,  bool bDelimeter = true ) {
         string sValue = EnumToString( eValue );
         StringReplace( sValue, "SIGNAL_BASE_", "" );
         return sField( sValue, bDelimeter ); };
