/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton;

import PNGtoMSX.ConvertPatternsToAssembler;
import PNGtoMSX.FindAllTiles;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;


/**
 *
 * @author santi
 */
public class ExtractTiles {
    public static final int TOLERANCE = 40;
    
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
    
    public static void main(String args[]) throws Exception
    {
        //String map = "salamand-horizontal.png";
        String map = "triton-title-4-no-text.png";
        List<List<Integer>> tiles = new ArrayList<>();
        
        ConvertPatternsToAssembler.MSX1Palette = MSX1Palette;
        //findAllTiles(ImageIO.read(new File(map)), tiles, 0, 1056);
        //findAllTiles(ImageIO.read(new File(map)), tiles, 0, 360);
        //findAllTiles(ImageIO.read(new File(map)), tiles, 360, 720);
        //findAllTiles(ImageIO.read(new File(map)), tiles, 720, 888);
        //findAllTiles(ImageIO.read(new File(map)), tiles, 888, 1056);

        findAllTiles(ImageIO.read(new File(map)), tiles, 0, 192);

        System.out.println("# tiles found: " + tiles.size());
        
        BufferedImage tilesImg = generateTilesImage(tiles);
        //ImageIO.write(tilesImg, "png", new File("salamand-horizontal-tiles.png"));
        ImageIO.write(tilesImg, "png", new File("triton-title-4-tiles.png"));
        
        /*
        - todo junto: 600 tiles
        - fase 1: 159 tiles
        - fase 2: 162 tiles
        - fase 3: 106 tiles
        - fase 4: 176 tiles
        */        
    }
    
    
    public static BufferedImage generateTilesImage(List<List<Integer>> tiles) throws Exception 
    {
        int width = 32*8;
        int height = ((tiles.size()+31)/32)*8;
        
        BufferedImage img = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        for(int i = 0;i<tiles.size();i++) {
            int x = (i%32);
            int y = (i/32);
            FindAllTiles.drawTile(img, tiles.get(i), x, y);
        }
        return img;
    }
    

    // Find all tiles
    public static void findAllTiles(BufferedImage img,
                                    List<List<Integer>> tiles,
                                    int starty, int endy) throws Exception
    {        
        for(int y = starty;y<endy && y<img.getHeight();y+=8) {
            for(int x = 0;x<img.getWidth();x+=8) {
                List<Integer> tile = getTile(img, x/8, y/8);

                int found = -1;
                for(List<Integer> t2:tiles) {
                    boolean equals = true;
                    for(int i = 0;i<tile.size();i++) {
                        if (!t2.get(i).equals(tile.get(i))) {
                            equals = false;
                            break;
                        }
                    }
                    if (equals) {
                        found = tiles.indexOf(t2);
                        //System.out.println("    " + tiles.size() + " == " + found);
                        break;
                    }
                }
                if (found == -1) tiles.add(tile);
            }
        }
    }    
    
    
    public static List<Integer> getTile(BufferedImage img, int x, int y) throws Exception {
        List<Integer> tile = new ArrayList<>();
        for(int i = 0;i<8;i++) {
            List<Integer> pixels = ConvertPatternsToAssembler.patternColors(x, y, i, img, TOLERANCE);
            tile.addAll(pixels);
        }
        return tile;
    }    
    
}
