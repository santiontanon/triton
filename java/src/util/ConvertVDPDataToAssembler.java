/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package util;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author santi
 */
public class ConvertVDPDataToAssembler {
    
    public static void convertPatternData(VDPSimulator vdp, int bank, boolean RLE)
    {
        System.out.println(";-----------------------------------------------");
        System.out.println(";; Graphic pattern definition");
        System.out.println("patterns:");
        if (RLE) {
            ConvertVDPDataToAssembler.convertDataRLE(vdp.getMemoryRange(vdp.PTRNTBL,vdp.PTRNTBL+256*8), 256*8);
        } else {
            ConvertVDPDataToAssembler.convertData(vdp.getMemoryRange(vdp.PTRNTBL,vdp.PTRNTBL+256*8), 256*8);
        }
        System.out.println("patternattributes:");
        if (RLE) {
            ConvertVDPDataToAssembler.convertDataRLE(vdp.getMemoryRange(vdp.CLRTBL,vdp.CLRTBL+256*8), 256*8);
        } else {
            ConvertVDPDataToAssembler.convertData(vdp.getMemoryRange(vdp.CLRTBL,vdp.CLRTBL+256*8), 256*8);
        }
    }
    
    
    public static void convertData(int data[], int length) 
    {
        int valuesPerRow = 16;
        int indent = 4;
        
        int rowCount = 0;
        for(int i = 0;i<length;i++) {
            if (rowCount==0) {
                for(int j = 0;j<indent;j++) System.out.print(" ");
                System.out.print("db ");
            }
            System.out.print(toHex8bit(data[i]));
            rowCount++;
            if (rowCount<valuesPerRow && i<length-1) {
                System.out.print(", ");
            } else {
                System.out.println("");
                rowCount = 0;
            }
        }
    }
    
    
    public static void convertDataRLE(int rawdata[], int length) 
    {
        int valuesPerRow = 16;
        int indent = 4;
        List<Integer> encoded = RLE(rawdata, length, 255);        
        
        for(int j = 0;j<indent;j++) System.out.print(" ");
        System.out.println(";; RLE encoded with meta: 255");
        for(int j = 0;j<indent;j++) System.out.print(" ");
        System.out.println(";; original size: "+length+", RLE size: " + encoded.size());
        
        int rowCount = 0;
        for(int i = 0;i<encoded.size();i++) {
            if (rowCount==0) {
                for(int j = 0;j<indent;j++) System.out.print(" ");
                System.out.print("db ");
            }
            System.out.print(toHex8bit(encoded.get(i)));
            rowCount++;
            if (rowCount<valuesPerRow && i<encoded.size()-1) {
                System.out.print(", ");
            } else {
                System.out.println("");
                rowCount = 0;
            }
        }
    }
    
    
    public static List<Integer> RLE(int data[], int length, int meta) {
        List<Integer> rle = new ArrayList<>();
        int last = -1;
        int count = 0;
        int base = 0;
        for(int i = 0;i<length;i++) {
            int v = data[i];
            if (v==last) {
                count++;
            } else {
                if (last>=0) {
                    if (count==1 && last!=meta) {
                        rle.add(last);
                        base++;
                    } else if (count==2 && last!=meta) {
                        rle.add(last);
                        rle.add(last);                        
                        base+=2;
                    } else {
                        do {
                            int counttmp = Math.min(255,count);
                            rle.add(meta);
                            rle.add(last);
                            rle.add(counttmp);
                            base += counttmp;
                            count -= counttmp;
                        }while(count>0);
                    }
                }
                last = v;
                count = 1;
            }
//            System.out.println(base);
        }
        if (count>0) {
            if (count==1 && last!=meta) {
                rle.add(last);
                base++;
            } else if (count==2 && last!=meta) {
                rle.add(last);
                rle.add(last);                        
                base+=2;
            } else {
                do {
                    int counttmp = Math.min(255,count);
                    rle.add(meta);
                    rle.add(last);
                    rle.add(counttmp);
                    base += counttmp;
                    count -= counttmp;
                }while(count>0);
            }
        }
//        System.out.println(";; encoded: " + base);
        return rle;
    }
    
    
    public static String toHex8bit(int value) {
        char table[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
        return "#" + table[value/16] + table[value%16];
    }    
}
