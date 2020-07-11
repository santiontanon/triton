/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton.pcg;

import java.util.Random;

/**
 *
 * @author santi
 */
public class Minimap {
    public static int SYSTEM_ITHAKI = 1;
    public static int SYSTEM_NEBULA = 2;
    public static int SYSTEM_NEBULA_LEFT = 12;
    public static int SYSTEM_NEBULA_RIGHT = 13;
    public static int SYSTEM_TRITON = 3;
    public static int SYSTEM_LEVEL_MOAI = 4;
    public static int SYSTEM_LEVEL_TECH = 5;
    public static int SYSTEM_LEVEL_WATER = 6;
    public static int SYSTEM_LEVEL_TEMPLE = 7;
    
    public static int CONNECTION_H = 8;
    public static int CONNECTION_V = 9;
    public static int CONNECTION_NW_SE = 10;
    public static int CONNECTION_SW_NE = 11;


    public static char planet_chars[] = {' ', 'I', 'N', 'T', 'm', 't', 'w', 'p',
                                         '-', '|', '\\', '/', 'N', 'N'};
    public static int minimap_codes[] = {31, 81, 83, 81, 85, 86, 87, 88, 
                                         93, 96, 94, 95, 82, 84};
    
    public static void main(String args[]) throws Exception
    {
        for(int i = 0;i<100;i++) {
            int minimap[][] = generateMinimap(26,9);
            printMinimap(minimap);
            printMinimapAssembler(minimap);
        }
    }
    
    
    public static void printMinimap(int minimap[][])
    {
        int w = minimap.length;
        int h = minimap[0].length;
        System.out.println("");
        for(int i=0;i<h;i++) {
            for(int j=0;j<w;j++) {
                int v = minimap[j][i];
                System.out.print(planet_chars[v]);
            }
            System.out.println("");
        }
        
    }
    

    public static void printMinimapAssembler(int minimap[][])
    {
        int w = minimap.length;
        int h = minimap[0].length;
        System.out.println("global_state_minimap:");
        for(int i=0;i<h;i++) {
            System.out.print("  db ");
            for(int j=0;j<w;j++) {
                int v = minimap[j][i];
                if (j<w-1) {
                    System.out.print(minimap_codes[v] + ", ");
                } else {
                    System.out.print(minimap_codes[v] + "");
                }
            }
            System.out.println("");
        }
    }
    

    
    public static int[][] generateMinimap(int width, int height)
    {
        int minimap[][] = new int[width][height];
        for(int i=0;i<height;i++) {
            for(int j=0;j<width;j++) {
                minimap[j][i] = 0;
            }
        }

        randomPathMethod(minimap);
        
        removeBridgePlanets(minimap, 0.5);
        
        // predefined elements:
        minimap[0][height-1] = SYSTEM_ITHAKI;
        minimap[width-1][0] = SYSTEM_TRITON;
        minimap[width-2][0] = CONNECTION_H;
        minimap[width-3][0] = CONNECTION_H;
        minimap[width-4][0] = SYSTEM_LEVEL_TEMPLE;
        minimap[width-5][1] = CONNECTION_SW_NE;
        minimap[width-6][2] = SYSTEM_NEBULA;
        minimap[width-7][2] = SYSTEM_NEBULA_LEFT;
        minimap[width-5][2] = SYSTEM_NEBULA_RIGHT;
                        
        return minimap;
    }
    
    
    public static void removeBridgePlanets(int minimap[][], double fraction) 
    {
        Random r = new Random();
        int width = minimap.length;
        int height = minimap[0].length;

        for(int i = 0;i<height;i+=2) {
            for(int j = 0;j<width;j+=2) {
                int n_connections = 0;
                for(int i1 = -1;i1<=1;i1++) {
                    for(int j1 = -1;j1<=1;j1++) {
                        if (j+j1 >= 0 && i+i1 >= 0 &&
                            j+j1 < width && i+i1 < height) {
                            if (minimap[j+j1][i+i1] >= CONNECTION_H) {
                                n_connections ++;
                            }
                        }
                    }
                }
                if (n_connections != 2) continue;
                if (j>0 && j<width-1) {
                    if (minimap[j-1][i] == CONNECTION_H && minimap[j+1][i] == CONNECTION_H) {
                        if (r.nextDouble() < fraction) minimap[j][i] = CONNECTION_H;
                    }
                }
                if (i>0 && i<height-1) {
                    if (minimap[j][i-1] == CONNECTION_V && minimap[j][i+1] == CONNECTION_V) {
                        if (r.nextDouble() < fraction) minimap[j][i] = CONNECTION_V;
                    }
                }
            }
        }
    }

    
    public static void randomPathMethod(int minimap[][])
    {
        Random r = new Random();
        
        int width = minimap.length;
        int height = minimap[0].length;
        
        // a middle path:
        int xmid = 8+r.nextInt(3)*2;
        int ymid = 2+r.nextInt(3)*2;
        minimap[xmid][ymid] = r.nextInt(4)+SYSTEM_LEVEL_MOAI;
        randomPath(minimap, 0, height-1, xmid, ymid, 0.025);   
        randomPath(minimap, xmid, ymid, width-6, 2, 0.025);   

        // a top path:
        int xtl = r.nextInt(3)*2;
        int ytl = r.nextInt(2)*2;
        minimap[xtl][ytl] = r.nextInt(4)+SYSTEM_LEVEL_MOAI;
        randomPath(minimap, 0, height-1, xtl, ytl, 0.025);   
        randomPath(minimap, xtl, ytl, width-6, 2, 0.025);   

        // a bottom path:
        int xbr = r.nextInt(3)*2 + ((width/2)-3)*2;
        int ybr = r.nextInt(2)*2 + ((height/2)-1)*2;
        minimap[xbr][ybr] = r.nextInt(4)+SYSTEM_LEVEL_MOAI;
        randomPath(minimap, 0, height-1, xbr, ybr, 0.025);   
        randomPath(minimap, xbr, ybr, width-6, 2, 0.025);   

        // connect tl with br:
        randomPath(minimap, xtl, ytl, xmid, ymid, 0.025);   
        randomPath(minimap, xmid, ymid, xbr, ybr, 0.025);   

    }
    

    public static void randomPath(int minimap[][], 
                                  int x1, int y1, int x2, int y2,
                                  double randomness)
    {
        int x = x1;
        int y = y1;
        int w = minimap.length;
        int h = minimap[0].length;
        Random r = new Random();
        
        while(x != x2 || y != y2) {
            //System.out.println(x + ", " + y);
            int dx = 0;
            int dy = 0;
            if (x < x2) dx = 2;
            if (x > x2) dx = -2;
            if (y < y2) dy = 2;
            if (y > y2) dy = -2;
            double v = r.nextDouble();
            if (v < randomness) {
                if (dx == 0) {
                    dx = (r.nextInt(3)-1)*2;
                } else {
                    dx = -dx;
                }
            } else if (v<randomness*2) {
                dx = 0;
            }
            v = r.nextDouble();
            if (v < randomness*2) {
                if (dy == 0) {
                    dy = (r.nextInt(3)-1)*2;
                } else {
                    dy = -dy;
                }
            } else if (v<randomness*4) {
                dy = 0;
            }

            // do not get out of bounds:
            if (x+dx < 0) continue;
            if (y+dy < 0) continue;
            if (x + dx >= w) continue;
            if (y + dy >= h) continue;

            // protect the nebula:
            if (x+dx > 20 && y+dy<3) continue;
            if (x+dx == 18 && y+dy == 2) continue;
            // protect the area around ITHAKI:
            if (x+dx == 0 && y+dy == 6) continue;
            if (x+dx == 2 && y+dy == 8) continue;
            
            // place conection:
            if (dx == 0) {
                minimap[x+dx/2][y+dy/2] = CONNECTION_V;
            } else if (dy == 0) {
                minimap[x+dx/2][y+dy/2] = CONNECTION_H;
            } else {
                if (dx + dy == 0) {
                    minimap[x+dx/2][y+dy/2] = CONNECTION_SW_NE;
                } else {
                    minimap[x+dx/2][y+dy/2] = CONNECTION_NW_SE;
                }
            }
            x += dx;
            y += dy;
            minimap[x][y] = r.nextInt(4)+SYSTEM_LEVEL_MOAI;
            if (x == x2 && y == y2) return;
        }
    }

}
