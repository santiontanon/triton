/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton;

import PNGtoMSX.ConvertNonEmptyPatternsToAssembler;
import PNGtoMSX.ConvertPatternsToAssembler;
import PNGtoMSX.FindAllTiles;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.List;
import javax.imageio.ImageIO;
import util.APLib;
import util.Pletter;

/**
 *
 * @author santi
 */
public class GenerateWeaponData {
    public static void main(String args[]) throws Exception {
        ConvertPatternsToAssembler.MSX1Palette = triton.GenerateUIData.MSX1Palette;
        ConvertNonEmptyPatternsToAssembler.MSX1Palette = triton.GenerateUIData.MSX1Palette;
        
        generateWeapon("weapon-bullet", "src/autogenerated", "data/weapons.png", 0, 1, 4);
        generateWeapon("weapon-laser", "src/autogenerated", "data/weapons.png", 1, 2, 4);
        generateWeapon("weapon-twister-laser", "src/autogenerated", "data/weapons.png", 2, 3, 4);
        generateWeapon("weapon-flame", "src/autogenerated", "data/weapons.png", 3, 4, 4);
        generateWeapon("weapon-directional", "src/autogenerated", "data/weapons.png", 4, 5, 4);

        generateWeapon("weapon-all", "src/autogenerated", "data/weapons.png", 0, 5, 4);
    }
    
    
    public static void generateWeapon(String name, String outputFolder, String tilesFile, int row0, int row1, int ntiles) throws Exception
    {
        List<List<Integer>> tiles = new ArrayList<>();
        BufferedImage img = ImageIO.read(new File(tilesFile));
        for(int row = row0;row<row1;row++) {
            for(int x = 0;x<ntiles;x++) {
                List<Integer> tile = FindAllTiles.getTile(img, x, row, GenerateTileSets.TOLERANCE);
                tiles.add(tile);
            }
        }
        
        // generate data:
        FindAllTiles.saveTilesToPNG(tiles, outputFolder + "/" + name + ".png");
        ConvertNonEmptyPatternsToAssembler.convert(outputFolder + "/" + name + ".png", outputFolder + "/" + name + ".asm", false);
        nl.grauw.glass.Assembler.main(new String[]{outputFolder + "/" + name + ".asm", outputFolder + "/" + name + ".bin"});
        Pletter.intMain(new String[]{outputFolder + "/" + name + ".bin", outputFolder + "/" + name + ".plt"});            
        APLib.main(outputFolder + "/" + name + ".bin", outputFolder + "/" + name + ".apl", true);
        
    }
}
