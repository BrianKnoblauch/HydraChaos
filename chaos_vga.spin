' //////////////////////////////////////////////////////////////////////
' Chaos - VGA
' AUTHOR: Brian Knoblauch
' LAST MODIFIED: 8.16.2013
' VERSION 1.0
'
' //////////////////////////////////////////////////////////////////////

'///////////////////////////////////////////////////////////////////////
' CONSTANTS SECTION ////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

CON

  _clkmode = xtal2 + pll8x            ' enable external clock and pll times 4
  _xinfreq = 10_000_000 + 0000        ' set frequency to 10 MHZ plus some error
  SCREEN_HEIGHT=320
  SCREEN_WIDTH=240
  vga_params = 21
  screensize = SCREEN_WIDTH * SCREEN_HEIGHT

'///////////////////////////////////////////////////////////////////////
' VARIABLES SECTION ////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

VAR
  long  vga_status      'status: off/visible/invisible  read-only       (21 contiguous longs)
  long  vga_enable      'enable: off/on                 write-only
  long  vga_pins        'pins: byte(2),topbit(3)        write-only
  long  vga_mode        'mode: interlace,hpol,vpol      write-only
  long  vga_videobase   'video base @word               write-only
  long  vga_colorbase   'color base @long               write-only              
  long  vga_hc          'horizontal cells               write-only
  long  vga_vc          'vertical cells                 write-only
  long  vga_hx          'horizontal cell expansion      write-only
  long  vga_vx          'vertical cell expansion        write-only
  long  vga_ho          'horizontal offset              write-only
  long  vga_vo          'vertical offset                write-only
  long  vga_hd          'horizontal display pixels      write-only
  long  vga_hf          'horizontal front-porch pixels  write-only
  long  vga_hs          'horizontal sync pixels         write-only
  long  vga_hb          'horizontal back-porch pixels   write-only
  long  vga_vd          'vertical display lines         write-only
  long  vga_vf          'vertical front-porch lines     write-only
  long  vga_vs          'vertical sync lines            write-only
  long  vga_vb          'vertical back-porch lines      write-only
  long  vga_rate        'pixel rate (Hz)                write-only
  byte  screen[screensize/4] ' 2 bpp, to get the 4 colors we need                                

'///////////////////////////////////////////////////////////////////////
' OBJECT DECLARATION SECTION ///////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////
OBJ

  vga : "vga_drv_010.spin" 

'///////////////////////////////////////////////////////////////////////
' PUBLIC FUNCTIONS /////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

PUB start(pins) : r | lIndex, x, y, random, direction
  
  longmove(@vga_status, @vgaparams, vga_params)
  vga_pins := %10111
  vga_videobase := @screen
  
  r := vga.start(@vga_status)   
    
  ' BEGIN GAME LOOP ////////////////////////////////////////////////////
  
  ' initialize some vars
  x := SCREEN_WIDTH/2
  y := SCREEN_HEIGHT/2

  'clear the onscreen buffer
  
  ' infinite loop
  'repeat while TRUE
  
    ' RENDERING SECTION (render to offscreen buffer always//////////////

    random:=?random
    direction:=random//3
    if direction==0
      x:=(x+(SCREEN_WIDTH/2))/2
      y:=(y+SCREEN_HEIGHT)/2
    elseif direction==1
      x:=x/2
      y:=y/2
    elseif direction==2
      x:=(x+SCREEN_WIDTH)/2
      y:=y/2    

    ' set pen attributes, color (1..3), size 0
    'gr.colorwidth(direction+1,0)
    'gr.plot(x, y)
    
    ' synchronize to frame rate would go here...

    ' END RENDERING SECTION ///////////////////////////////////////////////

  ' END MAIN GAME LOOP REPEAT BLOCK //////////////////////////////////

'///////////////////////////////////////////////////////////////////////
' DATA SECTION /////////////////////////////////////////////////////////
'///////////////////////////////////////////////////////////////////////

DAT
vgaparams               long    0               'status
                        long    1               'enable
                        long    %00_111         'pins
                        long    %011            'mode
                        long    0               'videobase
                        long    0               'colorbase
                        long    16              'hc
                        long    16              'vc
                        long    1               'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    256             'hd
                        long    8               'hf
                        long    32              'hs
                        long    96              'hb
                        long    768>>1          'vd
                        long    2               'vf
                        long    8               'vs
                        long    48              'vb
                        long    16_000_000      'rate

vgacolors               long    $C030C0DA       'red
                        long    $C0C00000
                        long    $30003000       'green
                        long    $30300000
                        long    $0C000C00       'blue
                        long    $0C0C0000
                        long    $FC00FC00       'white
                        long    $FCFC0000                        