/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton.pcg;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author santi
 */
public class LevelPatterns {
    public static int MAP_MOAI = 0;
    public static int MAP_TECH = 1;
    public static int MAP_WATER = 2;
    public static int MAP_TEMPLE = 3;
    
    
    public static List<Pattern> loadMoaiPatterns() throws Exception 
    {
        List<Pattern> patterns = new ArrayList<>();
        
        // waves:
        // trilos: 1 (top),2 (bot), 3 (middle), 12 (top higher)
        // fish: 4 (waving), 5 following, 6 (following 2top, 2bot), 7 (bullet drop at top), 13 (bullet drop at top)
        // ufo: 8 (top), 9 (bot), 10 (top,bw), 11 (bot,bw)
        
        patterns.add(new Pattern("data/patterns/moai0.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{1,1,2,2}));
        patterns.add(new Pattern("data/patterns/moai1.tmx", Pattern.EMPTY, Pattern.TOP_BOTTOM, new int[]{0,1,3,4}));
        patterns.add(new Pattern("data/patterns/moai2.tmx", Pattern.TOP_BOTTOM, Pattern.EMPTY, new int[]{0,10,11,4}));
        patterns.add(new Pattern("data/patterns/moai3.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,3,4,5}));
        patterns.add(new Pattern("data/patterns/moai4.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,4,5,6}));
        patterns.add(new Pattern("data/patterns/moai5.tmx", Pattern.EMPTY, Pattern.BOTTOM, new int[]{0,1,2,7}));
        patterns.add(new Pattern("data/patterns/moai6.tmx", Pattern.BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,4,8,6}));
        patterns.add(new Pattern("data/patterns/moai7.tmx", Pattern.BOTTOM, Pattern.BOTTOM, new int[]{0,8,3,4}));
        patterns.add(new Pattern("data/patterns/moai8.tmx", Pattern.BOTTOM, Pattern.BOTTOM, new int[]{0,10,5,7}));
        patterns.add(new Pattern("data/patterns/moai9.tmx", Pattern.BOTTOM, Pattern.EMPTY, new int[]{8,10,6,7}));
        patterns.add(new Pattern("data/patterns/moai10.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,3,4,6}));
        patterns.add(new Pattern("data/patterns/moai11.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,4,5,6}));
        patterns.add(new Pattern("data/patterns/moai12.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{8,9,10,11}));
        patterns.add(new Pattern("data/patterns/moai13.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{1,2,5,6}));
        patterns.add(new Pattern("data/patterns/moai14.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{1,2,5,6}));
        

        return patterns;
    }


    public static List<Pattern> loadTechPatterns() throws Exception 
    {
        List<Pattern> patterns = new ArrayList<>();
        
        // waves:
        // trilos: 1 (top),2 (bot), 3 (middle), 12 (top higher)
        // fish: 4 (waving), 5 following, 6 (following 2top, 2bot), 7 (bullet drop at top), 13 (bullet drop at top)
        // ufo: 8 (top), 9 (bot), 10 (top,bw), 11 (bot,bw)
        // walker: 14 (front), 15 (back)
        
        patterns.add(new Pattern("data/patterns/moai0.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{1,1,2,2}));
        patterns.add(new Pattern("data/patterns/tech1.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{8,9,10,11}));
        patterns.add(new Pattern("data/patterns/tech2.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{7,7,9,9}));
        patterns.add(new Pattern("data/patterns/tech3.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{13,13,8,9}));
        patterns.add(new Pattern("data/patterns/tech4.tmx", Pattern.EMPTY, Pattern.TOP_BOTTOM, new int[]{8,10,14,15}));
        patterns.add(new Pattern("data/patterns/tech5.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{14,14,14,14}));
        patterns.add(new Pattern("data/patterns/tech6.tmx", Pattern.TOP_BOTTOM, Pattern.EMPTY, new int[]{8,9,10,11}));
        patterns.add(new Pattern("data/patterns/tech7.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{8,10,14,15}));
        patterns.add(new Pattern("data/patterns/tech8.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{9,11,14,15}));        
        patterns.add(new Pattern("data/patterns/tech9.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{8,8,10,10}));
        patterns.add(new Pattern("data/patterns/tech10.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{8,8,10,10}));        
        patterns.add(new Pattern("data/patterns/tech11.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{8,9,14,14}));        
        patterns.add(new Pattern("data/patterns/tech12.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{9,11,14,15}));        

        return patterns;
    }
    
    
    public static List<Pattern> loadWaterPatterns() throws Exception 
    {
        List<Pattern> patterns = new ArrayList<>();
        
        // waves:
        // trilos: 1 (top),2 (bot), 3 (middle), 12 (top higher)
        // fish: 4 (waving), 5 following, 6 (following 2top, 2bot), 7 (bullet drop at top), 13 (bullet drop at top)
        // ufo: 8 (top), 9 (bot), 10 (top,bw), 11 (bot,bw)
        // walker: 14 (front), 15 (back)
        
        patterns.add(new Pattern("data/patterns/moai0.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{12,12,2,2}));
        patterns.add(new Pattern("data/patterns/water1.tmx", Pattern.EMPTY, Pattern.TOP_BOTTOM, new int[]{12,12,2,2}));
        patterns.add(new Pattern("data/patterns/water2.tmx", Pattern.TOP_BOTTOM, Pattern.EMPTY, new int[]{10,4,5,11}));
        patterns.add(new Pattern("data/patterns/water3.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{8,4,6,2}));
        patterns.add(new Pattern("data/patterns/water4.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM_MIDDLE, new int[]{12,5,6,9}));
        patterns.add(new Pattern("data/patterns/water5.tmx", Pattern.TOP_BOTTOM_MIDDLE, Pattern.TOP_BOTTOM, new int[]{10,4,2,2}));
        patterns.add(new Pattern("data/patterns/water6.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{8,12,5,2}));
        patterns.add(new Pattern("data/patterns/water7.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{12,6,2,11}));
        patterns.add(new Pattern("data/patterns/water8.tmx", Pattern.TOP_BOTTOM_MIDDLE, Pattern.EMPTY, new int[]{12,4,2,11}));
        patterns.add(new Pattern("data/patterns/water9.tmx", Pattern.EMPTY, Pattern.TOP_BOTTOM, new int[]{8,12,5,2}));
        patterns.add(new Pattern("data/patterns/water10.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{9,10,6,11}));

        return patterns;
    }
    
    
    public static List<Pattern> loadTemplePatterns() throws Exception 
    {
        List<Pattern> patterns = new ArrayList<>();
        
        // waves:
        // trilos: 1 (top),2 (bot), 3 (middle), 12 (top higher), 18 (middle)
        // fish: 4 (waving), 5 following, 6 (following 2top, 2bot), 7 (bullet drop at top), 13 (bullet drop at top)
        // ufo: 8 (top), 9 (bot), 10 (top,bw), 11 (bot,bw)
        // walker: 14 (front), 15 (back)
        // faces: 17 (front)
        
        patterns.add(new Pattern("data/patterns/moai0.tmx", Pattern.EMPTY, Pattern.EMPTY, new int[]{1,1,2,2}));
        patterns.add(new Pattern("data/patterns/temple1.tmx", Pattern.EMPTY, Pattern.BOTTOM, new int[]{18,18,4,8}));
        patterns.add(new Pattern("data/patterns/temple2.tmx", Pattern.BOTTOM, Pattern.EMPTY, new int[]{4,8,10,17}));
        patterns.add(new Pattern("data/patterns/temple3.tmx", Pattern.EMPTY, Pattern.TOP_BOTTOM, new int[]{5,8,9,17}));
        patterns.add(new Pattern("data/patterns/temple4.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{6,8,17,17}));
        patterns.add(new Pattern("data/patterns/temple5.tmx", Pattern.TOP_BOTTOM, Pattern.EMPTY, new int[]{8,9,1,2}));
        patterns.add(new Pattern("data/patterns/temple6.tmx", Pattern.BOTTOM, Pattern.BOTTOM, new int[]{8,10,17,4}));
        patterns.add(new Pattern("data/patterns/temple7.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{5,4,17,17}));
        patterns.add(new Pattern("data/patterns/temple8.tmx", Pattern.BOTTOM, Pattern.BOTTOM, new int[]{18,8,10,17}));
        patterns.add(new Pattern("data/patterns/temple9.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,0,5,17}));
        patterns.add(new Pattern("data/patterns/temple10.tmx", Pattern.TOP_BOTTOM, Pattern.TOP_BOTTOM, new int[]{0,0,5,17}));

        return patterns;
    }    
        
}
