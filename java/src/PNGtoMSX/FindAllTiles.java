/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package PNGtoMSX;

import PNGtoMSX.ConvertPatternsToAssembler;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;

/**
 *
 * @author santi
 */
public class FindAllTiles {
    public static void main(String args[]) throws Exception
    {
        findTiles(new String[]{"msxracing/tests/test-track2.png"}, "msxracing/tests/tiles2.png");
    }

    public static void findTiles(String inputFileNames[], String outputFileName) throws Exception
    {
        List<List<Integer>> tiles = new ArrayList<>();
        
        for(String inputFile:inputFileNames) {
            BufferedImage img = ImageIO.read(new File(inputFile));
            findAllTiles(img, tiles);
        }
        
        System.out.println("Found # tiles: " + tiles.size());
        
        // generate an image with the tiles:
        saveTilesToPNG(tiles, "msxracing/tests/tiles2.png");
    }
    
    
    public static void saveTilesToPNG(List<List<Integer>> tiles, String fileName) throws Exception
    {
        BufferedImage img = new BufferedImage(128, 128, BufferedImage.TYPE_INT_ARGB);
        System.out.println("saveTilesToPNG: " + tiles.size() + " tiles");
        for(int i = 0;i<tiles.size();i++) {
            int x = (i%16);
            int y = (i/16);
            drawTile(img, tiles.get(i), x, y);
        }
        
        ImageIO.write(img, "png", new File(fileName));
    }
    
    
    public static void findAllTiles(BufferedImage img, List<List<Integer>> tiles) throws Exception
    {        
        for(int y = 0;y<img.getHeight();y+=8) {
            for(int x = 0;x<img.getWidth();x+=8) {
                List<Integer> tile = getTile(img, x/8, y/8);
                
                boolean found = false;
                for(List<Integer> t2:tiles) {
                    boolean equals = true;
                    for(int i = 0;i<tile.size();i++) {
                        if (t2.get(i) != tile.get(i)) {
                            equals = false;
                            break;
                        }
                    }
                    if (equals) {
                        found = true;
                        break;
                    }
                }
                if (!found) tiles.add(tile);
            }
        }
    }
    
    
    public static void findAllTiles(BufferedImage img, List<List<Integer>> tiles, int tolerance) throws Exception
    {        
        for(int y = 0;y<img.getHeight();y+=8) {
            for(int x = 0;x<img.getWidth();x+=8) {
                List<Integer> tile = getTile(img, x/8, y/8, tolerance);
                
                boolean found = false;
                for(List<Integer> t2:tiles) {
                    boolean equals = true;
                    for(int i = 0;i<tile.size();i++) {
                        if (t2.get(i) != tile.get(i)) {
                            equals = false;
                            break;
                        }
                    }
                    if (equals) {
                        found = true;
                        break;
                    }
                }
                if (!found) tiles.add(tile);
            }
        }
    }    

    
    public static List<Integer> getTile(BufferedImage img, int x, int y) throws Exception {
        return getTile(img, x, y, 0);
    }
        
        
    public static List<Integer> getTile(BufferedImage img, int x, int y, int tolerance) throws Exception {
        List<Integer> tile = new ArrayList<>();
        for(int i = 0;i<8;i++) {
            List<Integer> pixels = ConvertPatternsToAssembler.patternColors(x, y, i, img, tolerance);
            tile.addAll(pixels);
        }
        return tile;
    }
    
    
    public static void drawTile(BufferedImage img, List<Integer> tile, int x, int y)
    {
        for(int i = 0;i<tile.size();i++) {
            int image_x = x*8 + i%8;
            int image_y = y*8 + i/8;
            int color = tile.get(i);
            int a = 255;
            if (image_x >= img.getWidth() ||
                image_y >= img.getHeight()) {
                System.err.println("pixel out of bounds!");
            } else {
                img.setRGB(image_x, image_y, ConvertPatternsToAssembler.MSX1Palette[color][2] + (ConvertPatternsToAssembler.MSX1Palette[color][1]<<8) + (ConvertPatternsToAssembler.MSX1Palette[color][0]<<16) + (a<<24));
            }
        }
    }
}
