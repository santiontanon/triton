/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton;

/**
 *
 * @author santi
 */
public class Main {
    public static void main(String args[]) throws Exception {

        // this sometimes fails, so, we run it first:
        triton.pcg.PCGMapWithAllTiles.main(args);
        
        ExtractSprites.main(args);
        GenerateScoreboard.main(args);
        GenerateTMXGraphicData.main(args);
        GenerateTextAndWeaponData.main(args);  // slow (minutes with pletter, hours with aplib)
        //GenerateTitleScreenData.main(args);    // slow (minutes with pletter, hours with aplib)
        GenerateUIData.main(args);
        GenerateWeaponData.main(args);

        GenerateTileSets.main(args);    
        triton.pcg.EncodePatternsAndEnemies.main(args);
        BossData.main(args);
        
        music.TSVMusic.createTritonSongs();
    }
}
