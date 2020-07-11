/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package PNGtoMSX;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import javax.imageio.ImageIO;
import util.APLib;
import util.Pletter;
import util.Z80Assembler;

/**
 *
 * @author santi
 */
public class ConvertNonEmptyPatternsToAssembler {
    
    public static boolean useaplib = true;
    
    static int PW = 8;
    static int PH = 8;
    static public int MSX1Palette[][] = {{0,0,0},
                                    {0,0,0},
                                    {43,221,81},
                                    {81,255,118},
                                    {81,81,255},
                                    {118,118,255},
                                    {221,81,81},
                                    {81,255,255},
                                    {255,81,81},
                                    {255,118,118},
                                    {255,221,81},
                                    {255,255,118},
                                    {43,187,43},
                                    {221,81,187},
                                    {221,221,221},
                                    {255,255,255}};     
    
    public static void main(String args[]) throws Exception {
        convert(args[0], args[1], true);
    }
    
    
    public static List<Integer> convertToBytes(String inputFile, boolean saveSize) throws Exception {
        return convertToBytes(inputFile, saveSize, 0);
    }

    
    public static List<Integer> convertToBytes(String inputFile, boolean saveSize, int tolerance) throws Exception {
        System.out.println("Converting " + inputFile);
        File f = new File(inputFile);
        BufferedImage sourceImage = ImageIO.read(f);
        List<Integer> data = new ArrayList<>();
        // determine the size:
        int sizeInBytes = 0;    // 8 bytes per pattern
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            String line = generateAssemblerPatternBitmap(x ,y, sourceImage, tolerance);
            if (line != null) sizeInBytes += 8;
        }

        if (saveSize) {
            data.add(sizeInBytes%256);
            data.add(sizeInBytes/256);
        }
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            List<Integer> patternData = generatePatternBitmapBytes(x, y, sourceImage, tolerance);
            if (patternData != null) data.addAll(patternData);
        }
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            List<Integer> patternData = generatePatternattributesBytes(x, y, sourceImage, tolerance);
            if (patternData != null) data.addAll(patternData);
        }
        return data;
    }    
    
    
    public static int convert(String inputFile, String outputFile, boolean saveSize) throws Exception {
        return convert(inputFile, outputFile, saveSize, 0);
    }

    
    public static int convert(String inputFile, String outputFile, boolean saveSize, int tolerance) throws Exception {
        System.out.println("Converting " + inputFile);
        File f = new File(inputFile);
        BufferedImage sourceImage = ImageIO.read(f);
        FileWriter fw = new FileWriter(new File(outputFile));
        // determine the size:
        int sizeInBytes = 0;    // 8 bytes per pattern
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            String line = generateAssemblerPatternBitmap(x ,y, sourceImage, tolerance);
            if (line != null) sizeInBytes += 8;
        }

        fw.write("    org #0000\n\n");
        if (saveSize) {
            fw.write("patterns_length:\n");
            fw.write("    dw " + sizeInBytes + "\n");
        } else {
            fw.write("; patterns size in bytes: " + sizeInBytes + "\n");
        }
        fw.write("patterns:\n");
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            String line = generateAssemblerPatternBitmap(x, y, sourceImage, tolerance);
            if (line != null) fw.write(line + "\n");
        }
        fw.write("patternattributes:\n");
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            String line = generateAssemblerPatternattributes(x, y, sourceImage, tolerance);
            if (line != null) fw.write(line + "\n");
        }
        fw.close();
        return sizeInBytes;
    }
    
    
    public static void convertOptimizingCompressionOrder(String inputFile, String outputFile, boolean saveSize, int tolerance, HashMap<Integer,Integer> map) throws Exception 
    {
        Random r = new Random(0);
        System.out.println("Converting " + inputFile);
        File f = new File(inputFile);
        BufferedImage sourceImage = ImageIO.read(f);
        List<List<Integer>> patterns = new ArrayList<>();
        List<List<Integer>> attributes = new ArrayList<>();
                
        // get all the tiles:
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            List<Integer> pattern = generatePatternBitmapBytes(x, y, sourceImage, tolerance);
            if (pattern != null) patterns.add(pattern);
        }
        for(int i = 0;i<256;i++) {
            int x = i%16;
            int y = i/16;
            List<Integer> attribute = generatePatternattributesBytes(x, y, sourceImage, tolerance);
            if (attribute != null) attributes.add(attribute);
        }
        
        // optimize:
        List<List<Integer>> original_patterns = new ArrayList<>();
        List<List<Integer>> original_attributes = new ArrayList<>();
        original_patterns.addAll(patterns);
        original_attributes.addAll(attributes);
        //for(int i = 0;i<patterns.size();i++) map.put(i, i);
        {
            List<Integer> bytes = convertOptimizingCompressionOrder_getBytes(patterns, attributes, saveSize);
            int best_size = (useaplib ? APLib.sizeOfCompressedBuffer(bytes, "imgtmp"):
                                        Pletter.sizeOfCompressedBuffer(bytes));
            System.out.println("initial size: " + best_size);
            boolean repeat = true;
            while(repeat) {
                repeat = false;
                // we start at 1, since we do not want to change tile 0
                for(int i = 1;i<patterns.size();i++) {
                    System.out.println("" + i);
                    for(int j = i+1;j<patterns.size();j++) {
                        // swap:
                        List<Integer> tmp = patterns.get(i);
                        patterns.set(i, patterns.get(j));
                        patterns.set(j, tmp);
                        tmp = attributes.get(i);
                        attributes.set(i, attributes.get(j));
                        attributes.set(j, tmp);
                        
                        List<Integer> tmp_bytes = convertOptimizingCompressionOrder_getBytes(patterns, attributes, saveSize);
                        int size = (useaplib ? APLib.sizeOfCompressedBuffer(tmp_bytes, "imgtmp") : 
                                               Pletter.sizeOfCompressedBuffer(tmp_bytes));
                        if (size < best_size) {
                            best_size = size;
                            System.out.println("  " + size + " (" + i + " <-> " + j + ")");
                            repeat = true;
                        } else if (size == best_size && r.nextDouble() > 0.5) {
                            System.out.println("  " + size + "* (" + i + " <-> " + j + ")");     
                        } else {
                            // undo the swap:
                            tmp = patterns.get(i);
                            patterns.set(i, patterns.get(j));
                            patterns.set(j, tmp);
                            tmp = attributes.get(i);
                            attributes.set(i, attributes.get(j));
                            attributes.set(j, tmp);
                        }
                    }
                }
                System.out.println("loop");
            }
        }
        
        for(int i = 0;i<patterns.size();i++) {
            int new_idx = -1;
            for(int j = 0;j<original_patterns.size();j++) {
                if (original_patterns.get(j).equals(patterns.get(i)) &&
                    original_attributes.get(j).equals(attributes.get(i))) {
                    new_idx = j;
                    break;
                }
            }
            if (new_idx == -1) throw new Exception("Tile not found!!");
            // int new_idx = original_patterns.indexOf(patterns.get(i));
            map.put(new_idx, i);
        }
        
        for(int i = 0;i<patterns.size();i++) {
            System.out.println("  " + i + " -> " + map.get(i));
        }
                
        // generate the final data:
        List<Integer> bytes = convertOptimizingCompressionOrder_getBytes(patterns, attributes, saveSize);
        FileWriter fw = new FileWriter(new File(outputFile));        
        Z80Assembler.dataBlockToAssembler(bytes, "data", fw, 16);
        fw.flush();
        fw.close();
    }    
    
    public static List<Integer> convertOptimizingCompressionOrder_getBytes(List<List<Integer>> patterns, List<List<Integer>> attributes, boolean saveSize)
    {
        List<Integer> bytes = new ArrayList<>();
        if (saveSize) {
            int size = patterns.size()*8;
            bytes.add(size%256);
            bytes.add(size/256);
        }
        for(List<Integer> pattern: patterns) {
            bytes.addAll(pattern);
        }
        for(List<Integer> attribute: attributes) {
            bytes.addAll(attribute);
        }
        return bytes;
    }


    public static List<Integer> generatePatternBitmapBytes(int x, int y, BufferedImage image, int tolerance) throws Exception {
        List<Integer> data = new ArrayList<>();
        for(int i = 0;i<PH;i++) {
            List<Integer> pixels = patternColors(x, y, i, image, tolerance);
            if (pixels == null) return null;   // if it's transparent, ignore!
            int bitmap = generateAssemblerBitmapLine(pixels);
            data.add(bitmap);
        }
        return data;
    }

    
    public static String generateAssemblerPatternBitmap(int x, int y, BufferedImage image, int tolerance) throws Exception {
        String line = "    db ";
        for(int i = 0;i<PH;i++) {
            List<Integer> pixels = patternColors(x, y, i, image, tolerance);
            if (pixels == null) return null;   // if it's transparent, ignore!
            int bitmap = generateAssemblerBitmapLine(pixels);
            line += toHex8bit(bitmap);
            if (i<PH-1) line+=",";
        }
        return line;
    }    
    
    
    public static int generateAssemblerBitmapLine(List<Integer> pixels) {
        List<Integer> differentColors = new ArrayList<>();
        for(int c:pixels) if (!differentColors.contains(c)) differentColors.add(c);
        if (differentColors.size()==1) differentColors.add(0);
        Collections.sort(differentColors);
        int bitmap = 0;
        int mask = (int)Math.pow(2, PW-1);
        for(int j = 0;j<PW;j++) {
            if (pixels.get(j).equals(differentColors.get(0))) {
                // 0
            } else {
                // 1
                bitmap+=mask;
            }
            mask/=2;
        }
        return bitmap;
    }        

    
    public static List<Integer> generatePatternattributesBytes(int x, int y, BufferedImage image, int tolerance) throws Exception {
        List<Integer> data = new ArrayList<>();
        for(int i = 0;i<PH;i++) {
            List<Integer> pixels = patternColors(x, y, i, image, tolerance);
            if (pixels == null) return null;   // if it's transparent, ignore!
            int bitmap = generateAssemblerAttributesLine(pixels);
            data.add(bitmap);
        }
        return data;
    }       
    
    
    public static String generateAssemblerPatternattributes(int x, int y, BufferedImage image, int tolerance) throws Exception {
        String line = "    db ";
        for(int i = 0;i<PH;i++) {
            List<Integer> pixels = patternColors(x, y, i, image, tolerance);
            if (pixels == null) return null;   // if it's transparent, ignore!
            int bitmap = generateAssemblerAttributesLine(pixels);
            line += toHex8bit(bitmap);
            if (i<PH-1) line+=",";
        }
        return line;
    }    
    
    
    public static int generateAssemblerAttributesLine(List<Integer> pixels) {
        List<Integer> differentColors = new ArrayList<>();
        for(int c:pixels) if (!differentColors.contains(c)) differentColors.add(c);
        if (differentColors.size()==1) differentColors.add(0);
        Collections.sort(differentColors);
        int bitmap = differentColors.get(0) + 16*differentColors.get(1);
        return bitmap;
    }      
    


    public static List<Integer> generateAssemblerAttributes(List<Integer> pixels) {
        List<Integer> data = new ArrayList<>();
        for(int i = 0;i<8;i++) {
            List<Integer> linePixels = new ArrayList<>();
            for(int j = 0;j<8;j++) {
                linePixels.add(pixels.get(i*8+j));
            }
            data.add(generateAssemblerAttributesLine(linePixels));
        }
        return data;
    }      


    public static List<Integer> generateAssemblerBitmap(List<Integer> pixels) {
        List<Integer> data = new ArrayList<>();
        for(int i = 0;i<8;i++) {
            List<Integer> linePixels = new ArrayList<>();
            for(int j = 0;j<8;j++) {
                linePixels.add(pixels.get(i*8+j));
            }
            data.add(generateAssemblerBitmapLine(linePixels));
        }
        return data;
    }      

    
    public static String toHex8bit(int value) {
        char table[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
        return "#" + table[value/16] + table[value%16];
    }
    
    
    public static int pixelColor(int image_x, int image_y, BufferedImage image) throws Exception {
        int color = image.getRGB(image_x, image_y);
        int r = (color & 0xff0000)>>16;
        int g = (color & 0x00ff00)>>8;
        int b = color & 0x0000ff;
        return ConvertPatternsToAssembler.findMSXColor(r, g, b);
    }

    
    public static List<Integer> patternColors(int x, int y, int line, BufferedImage image) throws Exception {
        return patternColors(x, y, line, image, 0);
    }


    public static List<Integer> patternColors(int x, int y, int line, BufferedImage image, int tolerance) throws Exception {
        List<Integer> pixels = new ArrayList<>();
        List<Integer> differentColors = new ArrayList<>();
        for(int j = 0;j<PW;j++) {
            int image_x = x*PW + j;
            int image_y = y*PH + line;
            int color = image.getRGB(image_x, image_y);
            int r = (color & 0xff0000)>>16;
            int g = (color & 0x00ff00)>>8;
            int b = color & 0x0000ff;
            int a = (color & 0xff000000)>>24;
            if (a == 0) return null;
            int msxColor = ConvertPatternsToAssembler.findMSXColor(r, g, b, tolerance);
            if (msxColor==-1) throw new Exception("Undefined color at " + image_x + ", " + image_y + ": " + r + ", " + g + ", " + b);
            if (!differentColors.contains(msxColor)) differentColors.add(msxColor);
            pixels.add(msxColor);
        }
        if (differentColors.size()>2) System.out.println("ERROR: more than 2 colors in pattern " + x + ", " + y + ", line " + line);
        return pixels;        
    }
}
