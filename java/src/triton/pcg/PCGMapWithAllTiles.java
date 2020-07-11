/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton.pcg;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import triton.GenerateTileSets;
import util.Pair;

/**
 *
 * @author santi
 */
public class PCGMapWithAllTiles {
    static int MAX_RETRIES = 32;
        
    public static void main(String args[]) throws Exception
    {
        List<Pattern> patterns_moai = LevelPatterns.loadMoaiPatterns();
        Pattern map_moai = generateMapWithAllTiles(patterns_moai, Pattern.EMPTY, LevelPatterns.MAP_MOAI);
        map_moai.saveTMX("data/patterns/moai-all-tiles-auto.tmx", "moai-tiles.png");

        List<Pattern> patterns_tech = LevelPatterns.loadTechPatterns();
        Pattern map_tech = generateMapWithAllTiles(patterns_tech, Pattern.EMPTY, LevelPatterns.MAP_TECH);
        map_tech.saveTMX("data/patterns/tech-all-tiles-auto.tmx", "tech-tiles.png");

        List<Pattern> patterns_water = LevelPatterns.loadWaterPatterns();
        Pattern map_water = generateMapWithAllTiles(patterns_water, Pattern.EMPTY, LevelPatterns.MAP_WATER);
        map_water.saveTMX("data/patterns/water-all-tiles-auto.tmx", "water-tiles.png");

        List<Pattern> patterns_temple = LevelPatterns.loadTemplePatterns();
        Pattern map_temple = generateMapWithAllTiles(patterns_temple, Pattern.EMPTY, LevelPatterns.MAP_TEMPLE);
        map_temple.saveTMX("data/patterns/temple-all-tiles-auto.tmx", "temple-tiles.png");
        
    }
        
    /*
    Generates a map that ensures having all possible tiles we can have in all
    banks with a given set of patterns. This will be used to later generate the
    scroll tile types
    */
    public static Pattern generateMapWithAllTiles(List<Pattern> patterns, int constraint, int map_type) throws Exception
    {
        Random r = new Random();
        List<Pattern> sequence = new ArrayList<>();

        // Extract the list of possible enemy positions, to ensure we generate
        // all of them:
        List<Pattern> patternsLeftToSpawn = new ArrayList<>();
        List<Pair<Integer, List<Integer>>> enemiesLeftToSpawn = new ArrayList<>();
        for(Pattern p:patterns) {
            patternsLeftToSpawn.add(p);
            for(int y = 0; y<p.tiles[0].length; y++) {
                for(int x = 0; x<p.tiles.length; x++) {
                    int tile = p.tiles[x][y];
                    boolean top = false;
                    if (y<p.tiles[0].length-1 && 
                        (p.tiles[x][y+1] == 0 ||
                         p.tiles[x][y+1] == GenerateTileSets.SOLID_BLACK_BG_TILE)) top = true;
                    if (top) {
                        if (map_type == LevelPatterns.MAP_MOAI) {
                            switch(tile) {
                                case 254: // moai
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(32))));
                                    break;
                                case 255: // turret
                                    // enemiesLeftToSpawn.add(new Pair<>(y+1, new ArrayList<>(Arrays.asList(64, 68, 96, 71, 75,98))));
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(70, 73))));
                                    enemiesLeftToSpawn.add(new Pair<>(y+1, new ArrayList<>(Arrays.asList(64, 68, 96))));
                                    break;
                            }
                        } else if (map_type == LevelPatterns.MAP_TECH) {
                            switch(tile) {
                                case 254: // generator
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(16))));
                                    break;
                                case 255: // turret
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(70, 73))));
                                    enemiesLeftToSpawn.add(new Pair<>(y+1, new ArrayList<>(Arrays.asList(64, 68, 96))));
                                    break;
                            }
                        } else if (map_type == LevelPatterns.MAP_WATER) {
                            switch(tile) {
                                case 254: // water dome
                                    enemiesLeftToSpawn.add(new Pair<>(y-2, new ArrayList<>(Arrays.asList(58))));
                                    break;
                                case 255: // turret
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(70, 73))));
                                    enemiesLeftToSpawn.add(new Pair<>(y+1, new ArrayList<>(Arrays.asList(64, 68, 96))));
                                    break;
                            }
                        } else if (map_type == LevelPatterns.MAP_TEMPLE) {
                            switch(tile) {
                                case 255: // turret
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(70, 73))));
                                    enemiesLeftToSpawn.add(new Pair<>(y+1, new ArrayList<>(Arrays.asList(64, 68, 96))));
                                    break;
                                case 254: // snake
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(58, 60))));
                                    break;
                            }
                        }
                    } else {
                        if (map_type == LevelPatterns.MAP_MOAI) {
                            switch(tile) {
                                case 254: // moai
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(16))));
                                    break;
                                case 255: // turret
                                    //enemiesLeftToSpawn.add(new Pair<>(y-1, new ArrayList<>(Arrays.asList(48, 52, 80, 55, 59, 82))));
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(54, 57))));
                                    enemiesLeftToSpawn.add(new Pair<>(y-1, new ArrayList<>(Arrays.asList(48, 52, 80))));
                                    break;
                            }
                        } else if (map_type == LevelPatterns.MAP_TECH) {
                            switch(tile) {
                                case 254: // generator
                                    enemiesLeftToSpawn.add(new Pair<>(y-1, new ArrayList<>(Arrays.asList(23,26))));
                                    break;
                                case 255: // turret
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(54, 57))));
                                    enemiesLeftToSpawn.add(new Pair<>(y-1, new ArrayList<>(Arrays.asList(48, 52, 80))));
                                    break;
                            }
                        } else if (map_type == LevelPatterns.MAP_WATER) {
                            switch(tile) {
                                case 254: // water dome
                                    enemiesLeftToSpawn.add(new Pair<>(y-2, new ArrayList<>(Arrays.asList(58))));
                                    break;
                                case 255: // turret
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(54, 57))));
                                    enemiesLeftToSpawn.add(new Pair<>(y-1, new ArrayList<>(Arrays.asList(48, 52, 80))));
                                    break;
                            }
                        } else if (map_type == LevelPatterns.MAP_TEMPLE) {
                            switch(tile) {
                                case 255: // turret
                                    enemiesLeftToSpawn.add(new Pair<>(y, new ArrayList<>(Arrays.asList(54, 57))));
                                    enemiesLeftToSpawn.add(new Pair<>(y-1, new ArrayList<>(Arrays.asList(48, 52, 80))));
                                    break;
                            }
                        }
                    }
                }
            }
        }
        
        
        while(patternsLeftToSpawn.size() + enemiesLeftToSpawn.size() > 0) {
            System.out.println("leftToSpawn: " + patternsLeftToSpawn.size() + " / " + enemiesLeftToSpawn.size());
            List<Pattern> candidates = new ArrayList<>();
            for(Pattern p:patterns) {
                if (p.leftConstraint == constraint) {
                    candidates.add(p);
                }
            }         
            
            // Select one among the candidates:
            for(int i = 0;i<MAX_RETRIES;i++) {
                boolean progress = false;
                
                Pattern p = candidates.get(r.nextInt(candidates.size()));
                if (patternsLeftToSpawn.contains(p)) {
                    patternsLeftToSpawn.remove(p);
                    progress = true;
                }

                Pattern p_clone = new Pattern(p);
                p_clone.randomizeTiles(map_type);
                if (map_type == LevelPatterns.MAP_MOAI) {
                    p_clone.addEnemiesMoai(0.5);
                } else if (map_type == LevelPatterns.MAP_TECH) {
                    p_clone.addEnemiesTech(0.5);
                } else if (map_type == LevelPatterns.MAP_WATER) {
                    p_clone.addEnemiesWater(0.5);
                } else if (map_type == LevelPatterns.MAP_TEMPLE) {
                    p_clone.addEnemiesTemple(0.5);
                }
                
                // check enemies left:
                List<Pair<Integer, List<Integer>>> toDelete = new ArrayList<>();
                for(int y = 0; y<p.tiles[0].length; y++) {
                    for(int x = 0; x<p.tiles.length; x++) {
                        int tile = p_clone.tiles[x][y];
                        for(Pair<Integer, List<Integer>> enemy: enemiesLeftToSpawn) {
                            if (tile!=0 && enemy.m_a == y) {
                                //System.out.println("tile: " + tile + " in " + enemy.m_b);
                                if (enemy.m_b.contains(tile)) {
                                    progress = true;
                                    enemy.m_b.remove(enemy.m_b.indexOf(tile));
                                    if (enemy.m_b.isEmpty()) toDelete.add(enemy);
                                }
                            }
                        }
                    }
                }
                for(Pair<Integer, List<Integer>> enemy: toDelete) {
                    enemiesLeftToSpawn.remove(enemy);
                }
                if (!progress && i<MAX_RETRIES-1) continue;
                constraint = p_clone.rightConstraint;
                sequence.add(p_clone);
                break;
            }
            

            if (sequence.size() >= 160) {
                System.err.println(enemiesLeftToSpawn);
                throw new Exception("map got too long! stopping!");
            }
        }
        
        System.out.println("map generated with " + sequence.size() + " patterns");
        int mapWidth = 0;
        int mapHeight = 0;
        for(Pattern p:sequence) {
            mapWidth += p.tiles.length;
            mapHeight = p.tiles[0].length;
        }
        
        int x = 0;
        Pattern map = new Pattern(mapWidth, mapHeight);
        for(Pattern p:sequence) {
            map.copyPattern(p, x, 0);
            x+= p.tiles.length;
        }
                
        return map;
    }      
}
