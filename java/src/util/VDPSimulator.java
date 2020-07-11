/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package util;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.GraphicsEnvironment;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;

/**
 *
 * @author santi
 */
public class VDPSimulator {
    public static int PTRNTBL = 0x0000;   // pattern table address
    public static int NAMTBL  = 0x1800;   // name table address
    public static int SPRATR  = 0x1b00;   //sprite attribute address
    public static int CLRTBL  = 0x2000;   // color table address
    public static int SPRTBL  = 0x3800;   // sprite pattern address
    
    public static int PTRNBANKSIZE = 8*256;
    public static int CLRBANKSIZE = 8*256;
    
    public static int MEMORY_SIZE = 16384;
    public static int WIDTH = 256;
    public static int HEIGHT = 192;
    
    public static Color MSX1Palette[]= {new Color(0,0,0),           // 0  transparent
                                        new Color(0,0,0),           // 1  black
                                        new Color(0,241,20),        // 2  medium green
                                        new Color(68,249,86),       // 3  light green
                                        new Color(85,79,255),       // 4  dark blue
                                        new Color(128,111,255),     // 5  medium blue
                                        new Color(242,70,40),       // 6  dark red
                                        new Color(12,255,255),      // 7  light blue
                                        new Color(255,81,52),       // 8  medium red
                                        new Color(255,115,86),      // 9  light red
                                        new Color(226,210,4),       // 10 dark yellow
                                        new Color(242,217,71),      // 11 light yellow
                                        new Color(4,212,19),        // 12 dark green
                                        new Color(231,80,229),      // 13 violet
                                        new Color(208,208,208),     // 14 grey
                                        new Color(255,255,255)};    // 15 white
    
    
    // video memory
    int memory[] = new int[MEMORY_SIZE];
    BufferedImage buffer = null;
    
    
    public VDPSimulator() {
        GraphicsConfiguration gc = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice().getDefaultConfiguration();
        buffer = gc.createCompatibleImage(WIDTH, HEIGHT);
    }
    
    
    
    
    public void clear() {
        for(int i = 0;i<MEMORY_SIZE;i++) memory[i] = 0;
        for(int i = 0;i<CLRBANKSIZE*3;i++) {
            memory[CLRTBL+i] = (0 + 15*16);  // white foreground, transparent background
        }
    }
    
    
    public void setPattern(int pattern, int bank, int []data) {
        for(int i = 0;i<8;i++) {
            memory[PTRNTBL + bank*PTRNBANKSIZE + pattern*8 + i] = data[i];
        }
    }
    

    public void setPatternColor(int pattern, int bank, int []data) {
        for(int i = 0;i<8;i++) {
            memory[CLRTBL + bank*CLRBANKSIZE + pattern*8 + i] = data[i];
        }
    }

    
    public void setNames(int start, int length, int []data) {
        for(int i = 0;i<length;i++) {
            memory[NAMTBL + i] = data[i];
        }
    }
    
    
    public void draw(Graphics g, int x, int y, int scale) {
        // draw the patterns:
        for(int i = 0;i<HEIGHT/8;i++) {
            int bank = i/8;
            for(int j = 0;j<WIDTH/8;j++) {
                drawPattern(buffer, memory[NAMTBL+j+i*32], bank, j*8, i*8);
            }
        }
                
        // draw the sprites:
        // ...

        ((Graphics2D)g).setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR);
        g.drawImage(buffer, x, y, WIDTH*scale, HEIGHT*scale, null);
    }
    
    
    public void drawPattern(BufferedImage img, int pattern, int bank, int x, int y)
    {
        int patternoffset = PTRNTBL + pattern*8 + bank*PTRNBANKSIZE;
        int coloroffset = CLRTBL + pattern*8 + bank*CLRBANKSIZE;
        
        for(int i = 0;i<8;i++) {
            int colors[] = new int[]{memory[coloroffset+i]%16,
                                     memory[coloroffset+i]/16};
            int v = memory[patternoffset +i];
            for(int j = 0;j<8;j++) {
                int bit_j = (v>>j)%2;
                img.setRGB(x+(7-j), y+i, MSX1Palette[colors[bit_j]].getRGB());
            }
        }
    }
    
    
    public int[] getMemoryRange(int start, int end) 
    {
        int []data = new int[end-start];
        for(int i = 0;i<end-start;i++) {
            data[i] = memory[start+i];
        }
        return data;
    }
    
}
