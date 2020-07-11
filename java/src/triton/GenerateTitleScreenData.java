/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton;

import PNGtoMSX.ConvertNonEmptyPatternsToAssembler;
import PNGtoMSX.ConvertPatternsToAssembler;
import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import javax.imageio.ImageIO;
import util.APLib;
import util.Pletter;

/**
 *
 * @author santi
 */
public class GenerateTitleScreenData {
    public static int TOLERANCE = 32;
    
    public static int MSX1Palette[][]={
                                {0,0,0},              // Transparent
                                {0,0,0},              // Black
                                {32,208,48},          // Medium Green
                                {96,232,112},         // Light Green
                                {80,80,232},          // Dark Blue
                                {120,112,247},        // Light Blue
                                {208,80,72},          // Dark Red
                                {64,232,240},         // Cyan
                                {247,80,80},          // Medium Red
                                {247,120,120},        // Light Red
                                {208,192,80},         // Dark Yellow
                                {224,200,128},        // Light Yellow
                                {32,160,44},          // Dark Green
                                {219,73,182},         // Magenta
                                {182,182,182},        // Grey
                                {255,255,255}};       // White      
    
    public static void main(String args[]) throws Exception {
        generateScreenData(new String[]{"data/triton-title-4-no-text.png",
                                        "data/triton-title-4-no-text-sprites.png",
                                        "data/triton-title-base-patterns.png",
                                        "data/triton-title-patterns.png"});
    }    
    
    
    public static void generateScreenData(String args[]) throws Exception {
        ConvertPatternsToAssembler.MSX1Palette = MSX1Palette;
        ConvertNonEmptyPatternsToAssembler.MSX1Palette = MSX1Palette;
        File f1 = new File(args[0]);
        BufferedImage title_image_patterns = ImageIO.read(f1);
        File f2 = new File(args[1]);
        BufferedImage title_image_sprites = ImageIO.read(f2);
        File f3 = new File(args[2]);
        BufferedImage title_patterns = ImageIO.read(f3);    // base patterns
        
        int title_start_y = 0;
        int nameTable[][] = new int[32][14];
        
        for(int y = 1;y<15;y++) {
            for(int x = 0;x<32;x++) {
                if (!isPatternEmpty(title_image_patterns,x,y)) {
                    int idx = addNewPatternToImage(title_patterns, title_image_patterns, x, y);
                    if (idx==-1) {
                        System.err.println("Ran out of space!!");
                        System.exit(1);
                    }
//                    System.out.println("non empty tile at " + x + "," + y + " -> " + idx);
                    nameTable[x][y-1] = idx;
                } else {
                    nameTable[x][y-1] = 0;
                }
            }
        }
        
        // space for the subtitle:
        for(int i = 0;i<16;i++) {
            nameTable[i+11][10] = 224+i;
        }
        
        // write title patterns image:
        ImageIO.write(title_patterns, "png", new File(args[3]));
                
        List<int []> sprite_patterns = new ArrayList<>();
        List<int []> sprite_attributes = new ArrayList<>();
        for(int y = 1*8;y<15*8;y++) {
            for(int x = 0;x<32*8;x++) {
                int color = ConvertPatternsToAssembler.findMSXColor(x,y,title_image_sprites, TOLERANCE);
                //if (color == -1) System.err.println("non MSX color in sprite image!");
                if (color > 0) {
                    int sprite_x = x;
                    int sprite_y = y;
                    // sprite found!!
                    // 1) find the top-left corner:
                    for(int y1 = -15;y1<16;y1++) {
                        if (y+y1>=0 && y+y1<title_image_sprites.getHeight()) {
                            for(int x1 = -15;x1<15;x1++) {
                                if (x+x1>=0 && x+x1<title_image_sprites.getWidth()) {
                                    int color2 = ConvertPatternsToAssembler.findMSXColor(x+x1,y+y1,title_image_sprites, TOLERANCE);
                                    if (color2 == color) {
                                        sprite_x = Math.min(sprite_x,x+x1);
                                        sprite_y = Math.min(sprite_y,y+y1);
                                    }
                                }
                            }
                        }
                    }
                    // align the coordinates to an 8x8 grid:
                    //sprite_x = sprite_x - (sprite_x%8);
                    //sprite_y = sprite_y - (sprite_y%8);
                    
                    // 2) get the pattern, and clear the pixels, so we don't get confused later on:
                    int pattern[] = new int[32];
                    boolean anyColor = false;
                    for(int i = 0;i<16;i++) {
                        for(int j = 0;j<16;j++) {
                            int color2 = ConvertPatternsToAssembler.findMSXColor(sprite_x+j,sprite_y+i,title_image_sprites, TOLERANCE);
                            if (color2 == color) {
                                // first clear the pixel:
                                title_image_sprites.setRGB(sprite_x+j, sprite_y+i, 0);
                                int byte_idx = i+(j>=8 ? 16:0);
                                int bit_idx = 7-j%8;
                                pattern[byte_idx] += (int)Math.pow(2, bit_idx);
                                anyColor = true;
                            }
                        }
                    }
                    
                    if (anyColor) {
                        sprite_patterns.add(pattern);

                        // 3) store the sprite attributes for later:
                        sprite_attributes.add(new int[] {title_start_y+sprite_y-1, sprite_x, sprite_attributes.size()*4, color});
                    } else {
                        System.err.println("empty sprite found! weird! (color: " + color + ", x/sx: " + x + "/" + sprite_x + ", y/sy: " + y + "/" + sprite_y);
                    }
                }
            }
        }
        
        
//        ConvertNonEmptyPatternsToAssembler.convert(args[3], "src/autogenerated/title-screen-tiles.asm", false, TOLERANCE);
//        nl.grauw.glass.Assembler.main(new String[]{"src/autogenerated/title-screen-tiles.asm", "src/autogenerated/title-screen-tiles.bin"});
//        Pletter.intMain(new String[]{"src/autogenerated/title-screen-tiles.bin", "src/autogenerated/title-screen-tiles.plt"});        
//        APLib.main("src/autogenerated/title-screen-tiles.bin", "src/autogenerated/title-screen-tiles.apl", true);
          

        // try to optimize space:
        // original: 1025, 454
        // compressed Pletter (seed 0): 910, 453
        // compressed APLib (seed 0): 
        {
            HashMap<Integer, Integer> map = new HashMap<>();
            ConvertNonEmptyPatternsToAssembler.convertOptimizingCompressionOrder(args[3], "src/autogenerated/title-screen-tiles.asm", false, TOLERANCE, map);
            nl.grauw.glass.Assembler.main(new String[]{"src/autogenerated/title-screen-tiles.asm", "src/autogenerated/title-screen-tiles.bin"});
            Pletter.intMain(new String[]{"src/autogenerated/title-screen-tiles.bin", "src/autogenerated/title-screen-tiles.plt"});
            APLib.main("src/autogenerated/title-screen-tiles.bin", "src/autogenerated/title-screen-tiles.apl", true);
            for(int y = 1;y<15;y++) {
                for(int x = 0;x<32;x++) {
                    int key = nameTable[x][y-1];
                    if (key > 0) {
                        key--;
                        if (map.containsKey(key)) {
                            int value = map.get(key);
                            nameTable[x][y-1] = value+1;
                        }
                    }
                }
            }
        }    
        
        // generate assembler file:
        String outputFileName = "src/autogenerated/title-screen-data";
        FileWriter fw = new FileWriter(outputFileName + ".asm");
        fw.write("  org #0000\n");
        fw.write("\n");
        fw.write("title_name_table:\n");
        for(int y = 0;y<nameTable[0].length;y++) {
            fw.write("  db " + nameTable[0][y]);
            for(int x = 1;x<32;x++) {
                fw.write(", " + nameTable[x][y]);
            }
            fw.write("\n");
        }        
        fw.write("; title_n_sprites:\n");
        fw.write(";   db " + sprite_attributes.size() + "\n");
        fw.write("title_sprites:\n");
        for(int []pattern:sprite_patterns) {
            // 3) write the pattern data:
            fw.write("  db " + pattern[0]);
            for(int i = 1;i<32;i++) fw.write("," + pattern[i]);
            fw.write("\n");
        }
        fw.write("title_sprite_table:\n");
        for(int[] attributes:sprite_attributes) {
            fw.write("  db " + attributes[0]);
            for(int i = 1;i<attributes.length;i++) {
                fw.write("," + attributes[i]);
            }
            fw.write("\n");
        }
        fw.flush();
        fw.close();
                
        nl.grauw.glass.Assembler.main(new String[]{outputFileName + ".asm", outputFileName + ".bin"});
        Pletter.intMain(new String[]{outputFileName + ".bin", outputFileName + ".plt"});                    
        APLib.main(outputFileName + ".bin", outputFileName + ".apl", true);
    }
    
    
    public static boolean isPatternEmpty(BufferedImage img, int x, int y) throws Exception
    {
//        System.out.println(x + "," + y + " image is: " + img.getWidth() + "x" + img.getHeight());
        List<Integer> differentColors = new ArrayList<>();
        for(int i = 0;i<8;i++) {
            List<Integer> pixels = ConvertPatternsToAssembler.patternColors(x, y, i, img, TOLERANCE);
            for(int c:pixels) if (!differentColors.contains(c)) differentColors.add(c);
        }
        if (differentColors.size()==1 && differentColors.get(0)==0) return true;
        return false;
    }
    

    private static int addNewPatternToImage(BufferedImage title_base_patterns, BufferedImage title_image, int x, int y) throws Exception {
        for(int y2 = 0;y2<16;y2++) {
            for(int x2 = 0;x2<16;x2++) {
                // first see if we already have the pattern:
                int differentPixels = differences(title_base_patterns, x2, y2, title_image, x, y);
                if (differentPixels==0) return y2*16+x2;
//                if (differentPixels==1) System.err.println(x+","+y + " only has 1 pixel difference with respect to " + x2+","+y2);
            }
        }
        for(int y2 = 0;y2<16;y2++) {
            for(int x2 = 0;x2<16;x2++) {
                // otherwise, look for an empty one:
                if (y2*16+x2!=0 &&
                    isPatternEmpty(title_base_patterns,x2,y2)) {
                    Graphics g = title_base_patterns.getGraphics();
                    g.drawImage(title_image, x2*8, y2*8, (x2+1)*8, (y2+1)*8, 
                                             x*8, y*8, (x+1)*8, (y+1)*8, null);
                    return y2*16+x2;
                }
            }
        }
        return -1;
    }
    

    private static int differences(BufferedImage img1, int x1, int y1, BufferedImage img2, int x2, int y2) throws Exception {
        int differences = 0;
        for(int i = 0;i<8;i++) {
            List<Integer> colors1 = ConvertPatternsToAssembler.patternColors(x1,y1,i,img1,TOLERANCE);
            List<Integer> colors2 = ConvertPatternsToAssembler.patternColors(x2,y2,i,img2,TOLERANCE);
            
            for(int j = 0;j<8;j++) {
                if (colors1.get(j) != colors2.get(j)) differences++;
            }
        }
        
        return differences;
    }
}
