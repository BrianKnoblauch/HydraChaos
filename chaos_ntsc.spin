' //////////////////////////////////////////////////////////////////////
' Chaos - NTSC
' AUTHOR: Brian Knoblauch
' LAST MODIFIED: 8.19.2013
' VERSION 1.0
'
' //////////////////////////////////////////////////////////////////////

'///////////////////////////////////////////////////////////////////////
' CONSTANTS SECTION ////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

CON

  _clkmode = xtal2 + pll8x            ' enable external clock and pll
  _xinfreq = 10_000_000 + 0000        ' set frequency to 10 MHZ plus some error
  _stack = ($3000 + $3000 + 64) >> 2  'accomodate display memory and stack

  ' graphics driver and screen constants
  PARAMCOUNT        = 14        
  OFFSCREEN_BUFFER  = $2000           ' offscreen buffer
  ONSCREEN_BUFFER   = $5000           ' onscreen buffer

  ' size of graphics tile map
  X_TILES           = 16
  Y_TILES           = 12
  
  SCREEN_WIDTH      = 256
  SCREEN_HEIGHT     = 192

  COL_Black     = %0000_0010
  COL_White     = %0000_0111

  COLOR_0 = (COL_Black << 0)
  COLOR_1 = (COL_White << 8)
  COLOR_2 = (COL_Black << 16)
  COLOR_3 = (COL_Black << 24)

'///////////////////////////////////////////////////////////////////////
' VARIABLES SECTION ////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

VAR
  long  tv_status     '0/1/2 = off/visible/invisible           read-only
  long  tv_enable     '0/? = off/on                            write-only
  long  tv_pins       '%ppmmm = pins                           write-only
  long  tv_mode       '%ccinp = chroma,interlace,ntsc/pal,swap write-only
  long  tv_screen     'pointer to screen (words)               write-only
  long  tv_colors     'pointer to colors (longs)               write-only               
  long  tv_hc         'horizontal cells                        write-only
  long  tv_vc         'vertical cells                          write-only
  long  tv_hx         'horizontal cell expansion               write-only
  long  tv_vx         'vertical cell expansion                 write-only
  long  tv_ho         'horizontal offset                       write-only
  long  tv_vo         'vertical offset                         write-only
  long  tv_broadcast  'broadcast frequency (Hz)                write-only
  long  tv_auralcog   'aural fm cog                            write-only

  word  screen[X_TILES * Y_TILES] ' storage for screen tile map
  long  colors[64]                ' color look up table
  long  random
  byte  direction

'///////////////////////////////////////////////////////////////////////
' OBJECT DECLARATION SECTION ///////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////
OBJ
  tv    : "tv_drv_010.spin"          ' instantiate a tv object
  gr    : "graphics_drv_010.spin"    ' instantiate a graphics object

'///////////////////////////////////////////////////////////////////////
' PUBLIC FUNCTIONS /////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

PUB start | i, dx, dy, x, y

  'start tv
  longmove(@tv_status, @tvparams, paramcount)
  tv_screen := @screen
  tv_colors := @colors
  tv.start(@tv_status)

  'init colors
  repeat i from 0 to 64
    colors[i] := COLOR_3 | COLOR_2 | COLOR_1 | COLOR_0
    
  'init tile screen
  repeat dx from 0 to tv_hc - 1
    repeat dy from 0 to tv_vc - 1
      screen[dy * tv_hc + dx] := onscreen_buffer >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

  'start and setup graphics 256x192, with orgin (0,0) at bottom left of screen
  gr.start
  gr.setup(X_TILES, Y_TILES, 0, 0, onscreen_buffer)

  ' BEGIN GAME LOOP ////////////////////////////////////////////////////

  ' initialize some vars
  x := SCREEN_WIDTH << 1
  y := SCREEN_HEIGHT << 1

  'clear the onscreen buffer
  gr.clear
  gr.colorwidth(1,0)  
  
  ' infinite loop
  repeat while TRUE
  
    ' RENDERING SECTION (render to offscreen buffer always//////////////

    random:=?random
    direction:=random//3
    if direction==0
      x:=(x+(SCREEN_WIDTH/2))>>1
      y:=(y+SCREEN_HEIGHT)>>1
    elseif direction==1
      x:=x>>1
      y:=y>>1
    elseif direction==2
      x:=(x+SCREEN_WIDTH)>>1
      y:=y>>1
    gr.plot(x, y)
    
    ' synchronize to frame rate would go here...

    ' END RENDERING SECTION ///////////////////////////////////////////////

  ' END MAIN GAME LOOP REPEAT BLOCK //////////////////////////////////

'///////////////////////////////////////////////////////////////////////
' DATA SECTION /////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

DAT

' TV PARAMETERS FOR DRIVER /////////////////////////////////////////////

tvparams                long    0               'status
                        long    1               'enable
                        long    %011_0000       'pins
                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx timing stretch
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    55_250_000      'broadcast on channel 2 VHF, each channel is 6 MHz above the previous
                        long    0               'auralcog