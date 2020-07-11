/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton.pcg;

import java.awt.Graphics;
import java.awt.image.BufferedImage;
import java.util.HashMap;
import java.util.Random;
import triton.GenerateTileSets;
import util.Tiled;

/**
 *
 * @author santi
 */
public class Pattern {
    static public int EMPTY = 0;
    static public int TOP = 1;
    static public int BOTTOM = 2;
    static public int TOP_BOTTOM = 3;
    static public int TOP_BOTTOM_MIDDLE = 4;
            
    Random r = new Random();
    public int tiles[][];
    public int leftConstraint, rightConstraint;
    public int enemyWaves[];
    
    
    public Pattern(String fileName, int lc, int rc, int ew[]) throws Exception
    {
        tiles = Tiled.loadTMX(fileName);
        leftConstraint = lc;
        rightConstraint = rc;
        enemyWaves = ew;
    }


    public Pattern(int w, int h)
    {
        tiles = new int[w][h];
        for(int i = 0; i<h; i++) {
            for(int j = 0; j<w; j++) {
                tiles[j][i] = 0;
            }
        }
        enemyWaves = new int[0];
    }    
    
    
    public Pattern(Pattern p)
    {
        tiles = new int[p.tiles.length][p.tiles[0].length];
        for(int i = 0; i<p.tiles[0].length; i++) {
            for(int j = 0; j<p.tiles.length; j++) {
                tiles[j][i] = p.tiles[j][i];
            }
        }
        leftConstraint = p.leftConstraint;
        rightConstraint = p.rightConstraint;
        enemyWaves = new int[p.enemyWaves.length];
        for(int i = 0;i<p.enemyWaves.length;i++) {
            enemyWaves[i] = p.enemyWaves[i];
        }
    }   
    
    
    public void copyPattern(Pattern p, int x, int y)
    {
        for(int i = 0; i<p.tiles[0].length; i++) {
            for(int j = 0; j<p.tiles.length; j++) {
                tiles[x+j][y+i] = p.tiles[j][i];
            }
        }
    }
    
    
    public void randomizeTiles(int mapType)
    {
        HashMap<Integer, int[]> randomizations = new HashMap<>();
        
        if (mapType == LevelPatterns.MAP_MOAI) {
            randomizations.put(2, new int[]{2, 3});
            //randomizations.put(6, new int[]{6, 7});
        }
        
        // the first and last columns should not be randomized, since that's where patterns connect
        for(int i = 0; i<tiles[0].length; i++) {
            for(int j = 1; j<tiles.length-1; j++) {
                int tile = tiles[j][i];
                int candidates[] = randomizations.get(tile);
                
                if (candidates != null) {
                    tiles[j][i] = candidates[r.nextInt(candidates.length)];
                }
            }
        }
    }
    
    
    public void randomizeTilesCompressible(String mapTypeName)
    {
        HashMap<Integer, int[]> randomizations = new HashMap<>();
        HashMap<Integer, Integer> randomizationState = new HashMap<>();
        
        if (mapTypeName.equals("moai")) {
            randomizations.put(2, new int[]{2, 3, 2});
            randomizationState.put(2, 0);
        }
        
        // the first and last columns should not be randomized, since that's where patterns connect
        for(int i = 0; i<tiles[0].length; i++) {
            for(int j = 1; j<tiles.length-1; j++) {
                int tile = tiles[j][i];
                int candidates[] = null;
                if (mapTypeName.equals("moai")) {
                    if (tiles[j-1][i] == 2 && tiles[j+1][i] == 2) {
                        // only randomize if left & right are also regular wall
                        candidates = randomizations.get(tile);
                    } else {
                        candidates = null;
                    }
                } else {
                    candidates = randomizations.get(tile);
                }
                
                if (candidates != null) {
                    int state = randomizationState.get(tile);
                    tiles[j][i] = candidates[state % candidates.length];
                    randomizationState.put(tile, state+1);
                }
            }
        }
    }    
    
    
    // p: probability of instantiating an enemy
    public void addEnemiesMoai(double p)
    {
        for(int i = 0; i<tiles[0].length; i++) {
            for(int j = 0; j<tiles.length; j++) {
                int tile = tiles[j][i];
                if (tile == 255) {
                    // small enemy (turret):
                    if (r.nextDouble()<p) {
                        spawnTurret(j, i, r.nextDouble()>0.5);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 254) {
                    // large enemy (moai):
                    if (r.nextDouble()<p) {
                        spawnMoai(j, i);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 253) {
                    // growing wall (nothing to spawn):
                    tiles[j][i] = 0;
                }
            }
        }
    }
    
    
    public void addEnemiesTech(double p)
    {
        for(int i = 0; i<tiles[0].length; i++) {
            for(int j = 0; j<tiles.length; j++) {
                int tile = tiles[j][i];
                if (tile == 255) {
                    // small enemy (turret):
                    if (r.nextDouble()<p) {
                        spawnTurret(j, i, r.nextDouble()>0.5);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 254) {
                    // large enemy (generator):
                    if (r.nextDouble()<p) {
                        spawnGeneratorTech(j, i);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 253) {
                    // growing wall (nothing to spawn):
                    tiles[j][i] = 0;
                }
            }
        }
    }
    
    
    public void addEnemiesWater(double p)
    {
        for(int i = 0; i<tiles[0].length; i++) {
            for(int j = 0; j<tiles.length; j++) {
                int tile = tiles[j][i];
                if (tile == 255) {
                    // small enemy (turret):
                    if (r.nextDouble()<p) {
                        spawnTurret(j, i, r.nextDouble()>0.5);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 254) {
                    if (r.nextDouble()<p) {
                        spawnWaterDome(j, i);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 253) {
                    // rock drop:
                    tiles[j][i] = 0;
                }
            }
        }
    }
        
    
    public void addEnemiesTemple(double p)
    {
        for(int i = 0; i<tiles[0].length; i++) {
            for(int j = 0; j<tiles.length; j++) {
                int tile = tiles[j][i];
                if (tile == 255) {
                    // small enemy (turret):
                    if (r.nextDouble()<p) {
                        spawnTurret(j, i, r.nextDouble()>0.5);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 254) {
                    if (r.nextDouble()<p) {
                        spawnSnake(j, i);
                    } else {
                        tiles[j][i] = 0;
                    }
                } else if (tile == 253) {
                    // moving column:
                    tiles[j][i] = 0;
                }
            }
        }
    }
            
    
    public void spawnTurret(int x, int y, boolean red)
    {
        int groundTurretTiles[] = {54,51,48,49};
        int groundTurretTiles2[] = {54,51,52,53};
        int groundTurretTiles3[] = {54,51,80,81};
        
        int groundTurretTiles_red[] = {57,56,48,49};
        int groundTurretTiles_red2[] = {57,56,52,53};
        int groundTurretTiles_red3[] = {57,56,80,81};

        int ceilingTurretTiles[] = {70,67,64,65};
        int ceilingTurretTiles2[] = {70,67,68,69};
        int ceilingTurretTiles3[] = {70,67,96,97};
        
        int ceilingTurretTiles_red[] = {73,72,64,65};
        int ceilingTurretTiles_red2[] = {73,72,68,69};
        int ceilingTurretTiles_red3[] = {73,72,96,97};
            
        int turretTiles[];
        
        int below_tile = tiles[x][y+1];

        if (below_tile == 0 || 
            below_tile == GenerateTileSets.SOLID_BLACK_BG_TILE) {
            if (red) {
                switch(r.nextInt(3)) {
                    case 0: turretTiles = ceilingTurretTiles_red; break;
                    case 1: turretTiles = ceilingTurretTiles_red2; break;
                    default: turretTiles = ceilingTurretTiles_red3; break;
                }
            } else {
                switch(r.nextInt(3)) {
                    case 0: turretTiles = ceilingTurretTiles; break;
                    case 1: turretTiles = ceilingTurretTiles2; break;
                    default: turretTiles = ceilingTurretTiles3; break;
                }
            }
            // ceiling turret:
            tiles[x][y] = turretTiles[0];
            tiles[x+1][y] = turretTiles[1];
            tiles[x][y+1] = turretTiles[2];
            tiles[x+1][y+1] = turretTiles[3];
       } else {
            if (red) {
                switch(r.nextInt(3)) {
                    case 0: turretTiles = groundTurretTiles_red; break;
                    case 1: turretTiles = groundTurretTiles_red2; break;
                    default: turretTiles = groundTurretTiles_red3; break;
                }
            } else {
                switch(r.nextInt(3)) {
                    case 0: turretTiles = groundTurretTiles; break;
                    case 1: turretTiles = groundTurretTiles2; break;
                    default: turretTiles = groundTurretTiles3; break;
                }
            }
            
            // ground turret:
            tiles[x][y] = turretTiles[0];
            tiles[x+1][y] = turretTiles[1];
            tiles[x][y-1] = turretTiles[2];
            tiles[x+1][y-1] = turretTiles[3];
        }
    }
    

    public void spawnMoai(int x, int y)
    {
        int groundTiles[] = {16,17,18,0,
                             19,20,21,22,
                             23,24,25,26,
                             0,0,27,28};
        int ceilingTiles[] = {32,33,34,0,
                              35,36,37,38,
                              39,40,41,42,
                              0,0,43,44};
        
        if (tiles[x][y+1] == 0) {
            // ceiling moai:
            tiles[x][y] = ceilingTiles[0];
            tiles[x+1][y] = ceilingTiles[1];
            tiles[x+2][y] = ceilingTiles[2];
            tiles[x+3][y] = ceilingTiles[3];
            tiles[x][y+1] = ceilingTiles[4];
            tiles[x+1][y+1] = ceilingTiles[5];
            tiles[x+2][y+1] = ceilingTiles[6];
            tiles[x+3][y+1] = ceilingTiles[7];            

            tiles[x][y+2] = ceilingTiles[8];
            tiles[x+1][y+2] = ceilingTiles[9];
            tiles[x+2][y+2] = ceilingTiles[10];
            tiles[x+3][y+2] = ceilingTiles[11];            

            tiles[x][y+3] = ceilingTiles[12];
            tiles[x+1][y+3] = ceilingTiles[13];
            tiles[x+2][y+3] = ceilingTiles[14];
            tiles[x+3][y+3] = ceilingTiles[15];    
        } else {
            // ground moai:
            tiles[x][y] = groundTiles[0];
            tiles[x+1][y] = groundTiles[1];
            tiles[x+2][y] = groundTiles[2];
            tiles[x+3][y] = groundTiles[3];
            tiles[x][y-1] = groundTiles[4];
            tiles[x+1][y-1] = groundTiles[5];
            tiles[x+2][y-1] = groundTiles[6];
            tiles[x+3][y-1] = groundTiles[7];            

            tiles[x][y-2] = groundTiles[8];
            tiles[x+1][y-2] = groundTiles[9];
            tiles[x+2][y-2] = groundTiles[10];
            tiles[x+3][y-2] = groundTiles[11];            

            tiles[x][y-3] = groundTiles[12];
            tiles[x+1][y-3] = groundTiles[13];
            tiles[x+2][y-3] = groundTiles[14];
            tiles[x+3][y-3] = groundTiles[15];            
        }        
    }
    
    
    public void spawnGeneratorTech(int x, int y)
    {
        int start_tile = 16;
        if (tiles[x][y+1] == 0) {
            // ceiling:
            start_tile = 16 + r.nextInt(2)*3;
        } else {
            // ground:
            start_tile = 22 + r.nextInt(2)*3;
            y--;
        }        
        
        tiles[x][y] = start_tile;
        tiles[x+1][y] = start_tile+1;
        tiles[x+2][y] = start_tile+2;
        tiles[x][y+1] = start_tile+16;
        tiles[x+1][y+1] = start_tile+17;
        tiles[x+2][y+1] = start_tile+18;
    }
    
    
    public void spawnWaterDome(int x, int y)
    {
        int start_tile = 58;
        tiles[x][y-2] = start_tile;
        tiles[x+1][y-2] = start_tile+1;
        tiles[x+2][y-2] = start_tile+2;
        tiles[x][y-1] = start_tile+16;
        tiles[x+1][y-1] = start_tile+17;
        tiles[x+2][y-1] = start_tile+18;
        tiles[x][y] = start_tile+32;
        tiles[x+1][y] = start_tile+33;
        tiles[x+2][y] = start_tile+34;
    }


    public void spawnSnake(int x, int y)
    {
        if (r.nextBoolean()) {
            int start_tile = 58;
            tiles[x-1][y] = start_tile;
            tiles[x][y] = start_tile+1;
        } else {
            int start_tile = 60;
            tiles[x-1][y] = start_tile;
            tiles[x][y] = start_tile+1;
            tiles[x-1][y+1] = start_tile+16;
            tiles[x][y+1] = start_tile+17;            
        }
    }
    
    
    public BufferedImage render(BufferedImage tilesImg) throws Exception
    {
        BufferedImage img = new BufferedImage(tiles.length*8, tiles[0].length*8, BufferedImage.TYPE_INT_ARGB);
        Graphics g = img.getGraphics();
        
        for(int i = 0;i<tiles[0].length;i++) {
            for(int j = 0;j<tiles.length;j++) {
                int tile = tiles[j][i];
                g.drawImage(tilesImg, j*8, i*8, j*8+8, i*8+8, 
                            (tile%16)*8, (tile/16)*8, (tile%16)*8+8, (tile/16)*8+8, null);
            }
        }
        
        return img;
    }
    

    void saveTMX(String fileName, String tilesImg) throws Exception
    {
        Tiled.saveTMX(fileName, tiles, tilesImg);
    }
        
}
