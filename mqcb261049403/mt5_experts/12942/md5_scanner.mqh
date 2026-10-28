//+------------------------------------------------------------------+
//|                                                  MD5.Scanner.mqh |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"

#define MIN_SCAN_PART  (1024*1024)          // minimum series 1 million passes 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum BruteForceEnumType
  {
   BRUTEFORCE_SET_LATIN,                    // Latin: a-Z, specials
   BRUTEFORCE_SET_ASCII,                    // ASCII: a-Z, 0-9, specials
   BRUTEFORCE_SET_ASCII_DIGITS,             // ASCII & Digits: a-Z, 0-9
   BRUTEFORCE_SET_DIGITS,                   // Digits only: 0-9
   BRUTEFORCE_SET_CUSTOM                    // Custom list of characters
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum HashEnumType
  {
   HASH_TYPE_SINGLE,                        // Single MD5 hash
   HASH_TYPE_FILENAME                       // Filename with MD5 hashes
  };
//+------------------------------------------------------------------+
//| Password scanner                                                 |
//+------------------------------------------------------------------+
class CMD5Scanner
  {
private:
   int               m_password_from;       // The number of initial symbols
   int               m_password_to;         // The number of final symbols
   char              m_charset[128];        // The working set of characters
   uint              m_charset_len;         // The calculated length of the set of characters
   char              m_table[256];          // The table of counter changes

   double            m_passes;              // The total number of passes
   char              m_password[];          // The array, in which a password is tried

   uchar             m_hashes[];            // An array of hashes
   int               m_hashes_total;        // The total number of 16-byte hashes

public:
                     CMD5Scanner(void);
                    ~CMD5Scanner(void);

   bool              CalculatePasses(int password_from,int password_to,BruteForceEnumType brute_type,string brute_custom,double &passes);
   bool              SetHashesMD5(string hashes);
   bool              DoPass(const long pass);

private:
   bool              Bruteforce(const long pass,int symbols);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMD5Scanner::CMD5Scanner(void):m_password_from(1),m_password_to(1),m_charset_len(0),m_passes(0),m_hashes_total(0)
  {
   ZeroMemory(m_charset);
//   ZeroMemory(m_password);
   ZeroMemory(m_table);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMD5Scanner::~CMD5Scanner(void)
  {
  }
//+------------------------------------------------------------------+
//| Calculating the number of passes                                 |
//+------------------------------------------------------------------+
bool CMD5Scanner::CalculatePasses(int password_from,int password_to,BruteForceEnumType brute_type,string brute_custom,double &passes)
  {
//--- Resetting the number of passes
   passes=0.0;
//--- Dealing with a custom set of characters
   switch(brute_type)
     {
      case BRUTEFORCE_SET_LATIN:
         m_charset_len=StringToCharArray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :;<=>?@[\\]^_`!\"#$%&'()*+,-./{|}~",m_charset)-1;
         break;

      case BRUTEFORCE_SET_ASCII:
         m_charset_len=StringToCharArray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 :;<=>?@[\\]^_`!\"#$%&'()*+,-./{|}~",m_charset)-1;
         break;

      case BRUTEFORCE_SET_ASCII_DIGITS:
         m_charset_len=StringToCharArray("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",m_charset)-1;
         break;

      case BRUTEFORCE_SET_DIGITS:
         m_charset_len=StringToCharArray("0123456789",m_charset)-1;
         break;

      case BRUTEFORCE_SET_CUSTOM:
         //--- Is the custom set specified?
         if(StringLen(brute_custom)<1)
           {
            Print("Bruteforce custom charset is empty");
            return(false);
           }
         //--- Saving the custom set
         m_charset_len=StringToCharArray(brute_custom,m_charset)-1;
         break;

      default:
         Print("Bruteforce charset is invalid");
         return(false);
     }
//   Print("Charset: ",m_charset);
//--- Checking the length of passwords
   if(password_from<1 || password_from>password_to)
     {
      Print("Password length from must be greater than 1 and less/equal to");
      return(false);
     }

   if(password_to<1 || password_to>10)
     {
      Print("Password length to must be greater than 1 and less/equal 10");
      return(false);
     }
   Print("Passwords: ",password_from," to ",password_to,", ",m_charset_len," characters");

   m_password_from=password_from;
   m_password_to  =password_to;
//--- Counting the number of attack options
   for(int i=password_from;i<=password_to;i++)
      passes+=MathPow(m_charset_len,i);

   m_passes=passes;
//--- Showing the statistics 
   if(passes<1000000.0)
      Print("Passes: ",passes);
   else
      Print("Passes: ",(int)(passes/1000000.0)," mln");
//--- Preparing a table of counter changes
   ZeroMemory(m_table);

   for(uint i=0;i<m_charset_len-1;i++)
      m_table[m_charset[i]]=m_charset[i+1];
   m_table[m_charset_len-1]=0;              // End!
//--- Everything is OK
   return(true);
  }
//+------------------------------------------------------------------+
//| Comma separated hash enumerations                                |
//+------------------------------------------------------------------+
bool CMD5Scanner::SetHashesMD5(string hashes)
  {
   int len=StringLen(hashes);
   int chars=0;
//--- Allocate required space in the array of hashes
   m_hashes_total=0;
   ArrayResize(m_hashes,32+len/32);
//--- Convert the string of type hash1,hash2
   ushort ch1,ch2;
   uchar  val1,val2;

   StringToUpper(hashes);
   for(int i=0;i<len;i+=2)
     {
      //--- Take two characters
      ch1=StringGetCharacter(hashes,i);
      if((i+1)<len) ch2=StringGetCharacter(hashes,i+1);
      else          ch2=0;
      //--- Check the separator
      if(ch1==',' || ch1==';' || ch1==' ' || ch2==',' || ch2==';' || ch2==' ')
        {
         //--- Isn't it on the border?
         if((chars&15)!=0)
           {
            Print("Invalid separator in the list of hashes: ",hashes);
            return(false);
           }
         //--- go next
         continue;
        }
      //--- Convert 0-9,A-F to byte
      val1=uchar(ch1-'0');
      if(val1>9) val1-=7;

      val2=uchar(ch2-'0');
      if(val2>9) val2-=7;

      if(val1>15 || val2>15)
        {
         Print("Invalid characters ",ch1," & ",ch2," in the list of hashes: ",hashes);
         return(false);
        }
      //--- Writing the byte
      m_hashes[chars++]=(val1<<4)+val2;
     }
//--- Setting the number of full hashes
   m_hashes_total=chars/16;
//--- Returning the result
   return(m_hashes_total>0 ? true:false);
  }
//+------------------------------------------------------------------+
//| Calculating the specified pass                                   |
//+------------------------------------------------------------------+
bool CMD5Scanner::DoPass(const long pass)
  {
   double     realpass=1+(double)pass*MIN_SCAN_PART; // Finding the exact position
   double     passes_last=0;                         // The previous counter
   double     passes=0;                              // Current calculation
   int        symbols=m_password_from;               // The number of initial characters
   const char firstchar=m_charset[0];                // Remember the first character of the charset
//--- Optimization method for a quick search of the start
//--- Finding the number of characters from which we need to start
   for(int i=m_password_from;i<=m_password_to;i++)
     {
      //--- Adding the amount of passes according to the number of symbols 
      passes+=MathPow(m_charset_len,i);
      //--- Is the level broken?
      if(passes>=realpass)
         break;
      //--- Saving the previous counter and moving on to the next character
      passes_last=passes;
      symbols++;
     }
//   Print("Initial: ",symbols," symbols, ",passes_last," pass, ",realpass," real passes, delta ",realpass-passes_last);
//---
//--- for 'symbols' 'passes' completed, so now we need 
//--- to increase the counter to realpass position
//---
//--- Preparing a draft of 'symbols' values
   ArrayResize(m_password,symbols,16);
   for(int i=0;i<symbols;i++)
      m_password[i]=firstchar;                   // enter aaaaaa
//---
   long stages[12];
   int  stages_total=0;

   for(int i=symbols;i>0;i--)
      stages[stages_total++]=MathPow(m_charset_len,i-1);
//--- пробуем подобраться
   for(int i=0;i<stages_total;i++)
     {
      while(realpass>(passes_last+stages[i]))
        {
         passes_last+=stages[i];
         m_password[i]=m_table[m_password[i]];
        }
     }
//--- The position has been found
//   string password=CharArrayToString(m_password,0,symbols);
//   Print("Pass: ",pass," position: ",password," in ",GetTickCount()-start_time," ms");
//--- Sent to brute force
   return Bruteforce(pass,symbols);
  }
//+------------------------------------------------------------------+
//| Go through the block to find MIN_SCAN_PART values                |
//+------------------------------------------------------------------+
bool CMD5Scanner::Bruteforce(const long original_pass,int symbols)
  {
   const char firstchar=m_charset[0];            // Remember the first character of the charset
   int        sympos   =symbols-1;               // The starting position in the password
   string     md5_hash;
//---
   for(ulong pass=0;pass<MIN_SCAN_PART;pass++)
     {
      //--- increase the character in the current position
      m_password[sympos]=m_table[m_password[sympos]];
      //--- Is it the limit of the charset?
      if(m_password[sympos]==0)
        {
         m_password[sympos]=firstchar;           // Setting the starting character
         //--- Now increase other positions
         int i=sympos-1;
         while(true)
           {
            //--- Is it the limit and we need to increase the width?
            if(i<0)
              {
               symbols++;
               if(symbols>m_password_to)
                 {
                  Print("Invalid counter, extra symbols in bruteforce");
                  return(false);
                 }
               //--- Once again feel the positions
               ArrayResize(m_password,symbols,0);
               for(int j=0;j<symbols;j++)
                  m_password[j]=firstchar;
               //--- Resetting the counter
               sympos=symbols-1;
               i=sympos;
              }
            //---
            m_password[i]=m_table[m_password[i]];
            if(m_password[i]!=0)
               break;
            //--- Setting the starting character and going to the next digit
            m_password[i]=firstchar;
            i--;
           }
         //--- Are we stopped?
         if(IsStopped())
            return(false);
        }
      //--- Count the hash
      uchar hash[16];

      CryptEncode(CRYPT_HASH_MD5,m_password,hash,hash);
      for(int k=0;k<m_hashes_total;k++)
         if(ArrayCompare(hash,m_hashes,0,k*16,16)==0)
           {
            string password=CharArrayToString(m_password,0,symbols);
            Print(k," -> ",password);
            FrameAdd(password,original_pass,0,NULL);
            return(true);
           }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
