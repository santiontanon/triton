/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton;

import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;
import util.APLib;
import util.Pletter;
import util.Tiled;
import util.Z80Assembler;

/**
 *
 * @author santi
 */
public class GenerateScoreboard {
    public static void main(String args[]) throws Exception
    {
        String outputFolder = "src/autogenerated";
        int tiles[][] = Tiled.loadTMX("data/scoreboard.tmx");
        List<Integer> bytes = new ArrayList<>();
        
        for(int i = 0;i<tiles[0].length;i++) {
            for(int j = 0;j<tiles.length;j++) {
                if (tiles[j][i] > 0) {
                    bytes.add(tiles[j][i]+20);
                } else {
                    bytes.add(tiles[j][i]);
                }
            }
        }
        
        System.out.println("Raw size: " + bytes.size());
        String fileName = outputFolder + "/scoreboard";
        FileWriter fw = new FileWriter(fileName + ".asm");
        Z80Assembler.dataBlockToAssembler(bytes, "pattern", fw, 16);
        fw.flush();
        fw.close();

        nl.grauw.glass.Assembler.main(new String[]{fileName + ".asm", fileName + ".bin"});
        Pletter.intMain(new String[]{fileName + ".bin", fileName + ".plt"});            
        APLib.main(fileName + ".bin", fileName + ".apl", true);
    }
}
