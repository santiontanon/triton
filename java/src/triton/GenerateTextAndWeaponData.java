/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package triton;

import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Random;
import text.EncodeText;
import text.PAKFont;
import util.APLib;
import util.Pair;
import util.Pletter;

/**
 *
 * @author santi
 */
public class GenerateTextAndWeaponData {
    public static void main(String args[]) throws Exception
    {
        List<String> characters = new ArrayList<>();
        characters.add(" !$'()?,-.");
        characters.add("0123456789:");
        characters.add("ABCDEFGHIJKLMNO");
        characters.add("PQRSTUVWXYZ");
        characters.add("ÑÓ");
        PAKFont font = new PAKFont("data/font-triton.png", characters);   
        font.generateAssemblerData("src/autogenerated/font");
        
        font.printFontInfo();
        
        // Text lines:
        List<String> lines = new ArrayList<>();
        String weapon_names[] = {"SPEED UP", 
                                 "INIT SPEED",
                                 "TRANSFER",
                                 "   BULLET",
                                 "     TWIN",
                                 "   TRIPLE",
                                 "   SHIELD",
                                 " LT. TORP.",
                                 " HV. TORP.",
                                 "UP MISSILE",
                                 "DN.MISSILE",
                                 "BI.MISSILE",
                                 "    LASER",
                                 " TW.LASER",
                                 "   FLAME",
                                 " B.OPTION",
                                 " M.OPTION",
                                 " D.OPTION",
                                 "SKIP LVL.",
                                 "INIT WPN.",
                                 "PILOTS"};
                                 
        String weapon_descriptions[][] = {
            {"- INCREASES MOVEMENT SPEED",
             "  OF THE SHIP.",
             "- HOLD FIRE TO SLOW DOWN."},
            
            {"- INCREASES INITIAL SPEED",
             "  LEVEL.",
             "- PASSIVE UPGRADE."},

            {"- TURNS ENERGY CAPSULES",
             "  INTO ONE CREDIT."},

            {"- FIRES BULLETS FORWARD.",
             "- SPECIAL (HOLD FIRE):",
             "  MACHINE GUN."},

            {"- FIRES BULLETS FORWARD",
             "  AND BACKWARD.",
             "- SPECIAL (HOLD FIRE):",
             "  MACHINE GUN."},

            {"- THREE BULLETS SPREAD",
             "  FORWARD.",
             "- SPECIAL (HOLD FIRE):",
             "  MACHINE GUN."},
        
            {"- PROTECTS YOUR SHIP FROM",
             "  A LIMITED AMOUNT OF DAMAGE."},

            {"- FORWARD TORPEDOES WITH",
             "  LOW POWER BUT HIGH",
             "  CADENCE."},

            {"- FORWARD TORPEDOES WITH",
             "  HIGH POWER BUT LOW",
             "  CADENCE."},

            {"- UPWARD AIR-LAND MISSILES."},            

            {"- DOWNWARD AIR-LAND MISSILES."},

            {"- BI-DIRECTIONAL AIR-LAND",
             "  MISSILES, FIRED IN THE",
             "  SHIP'S LAST DIRECTION."},
        
            {"- FIRES PIERCING LASER",
             "  BULLETS.",
             "- SPECIAL (HOLD FIRE):",
             "  CONTINUOUS LASER."},

            {"- DOUBLE POWER LASER.",
             "- SPECIAL (HOLD FIRE):",
             "  CONTINUOUS LASER."},

            {"- FLAME THROWER.",
             "- SPECIAL (HOLD FIRE):",
             "  CONTINUOUS FLAME."},
            
            {"- BULLET FIRING OPTION.",
             "- YOU CAN HAVE UP TO TWO",
             "  AT THE SAME TIME."},

            {"- MISSILE FIRING OPTION.",
             "- YOU CAN HAVE UP TO TWO",
             "  AT THE SAME TIME."},

            {"- DIRECTIONAL OPTION.",
             "- YOU CAN HAVE UP TO TWO",
             "  AT THE SAME TIME."},

            {"- WHEN YOU SELECT A NEW",
             "  WEAPON IN GAME, START",
             "  WITH A HIGHER LEVEL.",
             "- PASSIVE UPGRADE."},

            {"- START WITH THE BEST",
             "  EQUIPPED WEAPON.",
             "- PASSIVE UPGRADE."},

            {"- NUMBER OF RESERVE PILOTS",
             "  AVAILABLE PER MISSION.",
             "- PASSIVE UPGRADE."},
        };
        
        HashMap<String,String> lines_with_constant = new HashMap<>();
        lines_with_constant.put("THE MENACE FROM", "SUBTITLE");
        lines_with_constant.put("PRESS FIRE TO START", "PRESS_FIRE");
        lines_with_constant.put("SANTIAGO ONTAÑÓN     2020", "CREDITS");
        lines_with_constant.put("PRESENTS", "PRESENTS");
        lines_with_constant.put(" PAUSE", "PAUSE");
        lines_with_constant.put("Q - QUIT", "Q_QUIT");
        lines_with_constant.put("QUIT", "QUIT");
        lines_with_constant.put("GAME OVER", "GAMEOVER");
        lines_with_constant.put("EQUIP YOUR SHIP!", "EQUIPSHIP");
        lines_with_constant.put("CREDITS:", "MONEY");
        lines_with_constant.put("  BACK", "BACK");
        lines_with_constant.put("UPGRADE", "UPGRADE");
        lines_with_constant.put("EQUIPPED", "EQUIPPED");
        lines_with_constant.put(" UPGRD", "UPGRD");
        lines_with_constant.put("   MAX", "MAX");
        lines_with_constant.put("EQP", "EQP");
        lines_with_constant.put("GALAXY MAP:", "GALAXY_MAP");
        lines_with_constant.put("ITHAKI", "ITHAKI");
        lines_with_constant.put("TRITON", "TRITON");
        lines_with_constant.put("AIGAI", "AIGAI");
        lines_with_constant.put("NEBULA", "NEBULA");
        lines_with_constant.put(" UPGRADE YOUR SHIP OR CHOOSE A PLANET TO ATTACK!", "MISSION_INSTRUCTIONS");
        lines_with_constant.put("SYSTEM CLEAR", "SYSTEM_CLEAR");
        
        // Story:
        lines_with_constant.put("YEAR 9918", "CUTSCENE_1_1");
        lines_with_constant.put("HUMANITY HAD SPREAD ACROSS THE GALAXY,", "CUTSCENE_1_2");
        lines_with_constant.put("COLONIZING PLANET AFTER PLANET.", "CUTSCENE_1_3");
        lines_with_constant.put("IT WAS A NEW GOLDEN AGE!", "CUTSCENE_1_4");
        lines_with_constant.put("UNTIL SOMETHING WENT WRONG...", "CUTSCENE_1_5");

        lines_with_constant.put("SCOUT SHIP ARGO-1.", "CUTSCENE_2_1");
        lines_with_constant.put("ON A SCOUT MISSION NEAR AIGAI NEBULA.", "CUTSCENE_2_2");
        lines_with_constant.put("HERE ARGO-1, WE ARE PICKING UP SOMETHING", "CUTSCENE_2_3");
        lines_with_constant.put("AHEAD OF US!", "CUTSCENE_2_4");
        lines_with_constant.put("IT LOOKS LIKE... A GIANT HEAD?", "CUTSCENE_2_5");

        lines_with_constant.put("IT'S NOT RESPONDING TO OUR HAILS", "CUTSCENE_3_1");
        lines_with_constant.put("WAIT! WHAT IS IT DOING?", "CUTSCENE_3_2");
        lines_with_constant.put("IT'S FIRING ON US!", "CUTSCENE_3_3");
                
        lines_with_constant.put("HERE ITHAKI BASE, ARGO-1 WE LOST YOUR", "CUTSCENE_4_1");
        lines_with_constant.put("SIGNAL. PLEASE RESPOND!", "CUTSCENE_4_2");

        lines_with_constant.put("HUMANS!!!", "CUTSCENE_5_1");
        lines_with_constant.put("WE HAVE BEEN WATCHING YOU...", "CUTSCENE_5_2");
        lines_with_constant.put("YOU HAVE GONE TOO FAR!", "CUTSCENE_5_3");
        lines_with_constant.put("NO ONE BUT THE TRITON EMPIRE WILL RULE", "CUTSCENE_5_4");
        lines_with_constant.put("THE GALAXY!", "CUTSCENE_5_5");
        lines_with_constant.put("YOU WILL BE ANIHILATED!!", "CUTSCENE_5_6");
        
        lines_with_constant.put("UNFORTUNATELY THE MISSION FAILED.", "M_CUTSCENE_0_1");
        lines_with_constant.put("NO PILOTS SURVIVED...", "M_CUTSCENE_0_2");
        lines_with_constant.put("WE'LL GET THEM NEXT TIME!", "M_CUTSCENE_0_3");

        lines_with_constant.put("THIS IS GENERAL LAERTE,", "M_CUTSCENE_1_1");
        lines_with_constant.put("ITHAKI IS OUR CLOSEST BASE TO TRITON.", "M_CUTSCENE_1_2");
        lines_with_constant.put("WE NEED TO ATTACK BEFORE THEY DO!", "M_CUTSCENE_1_3");
        lines_with_constant.put("YOUR COMBAT SHIPS ARE READY.", "M_CUTSCENE_1_4");
        lines_with_constant.put("MAKE US PROUD! FIGHT FOR HUMANITY!", "M_CUTSCENE_1_5");

        lines_with_constant.put("WE HAVE LOST ALL THE SHIPS THAT HAVE", "M_CUTSCENE_2_1");
        lines_with_constant.put("ATTEMPTED TO CROSS THE NEBULA!", "M_CUTSCENE_2_2");
        lines_with_constant.put("WE NEED TO FIND A WAY TO CROSS IT!", "M_CUTSCENE_2_3");

        lines_with_constant.put("THE TRITON EMPIRE IS ON THE MOVE!", "M_CUTSCENE_3_1");
        lines_with_constant.put("THEIR GENERALS ARE ADVANCING TOWARDS", "M_CUTSCENE_3_2");
        lines_with_constant.put("ITHAKI! FIND THEM AND DEFEAT THEM!", "M_CUTSCENE_3_3");
        
        lines_with_constant.put("YOU DEFEATED POLYPHEMUS!!", "M_CUTSCENE_4_1");
        lines_with_constant.put("AMONGST THE DEBRIS WE DISCOVERED ONE", "M_CUTSCENE_4_2");
        lines_with_constant.put("PART OF A MAP TO CROSS AIGAI!! THE", "M_CUTSCENE_4_3");
        lines_with_constant.put("OTHER GENERALS OF TRITON MIGHT HAVE", "M_CUTSCENE_4_4");
        lines_with_constant.put("MORE! WE NEED TO FIND THEM!", "M_CUTSCENE_4_5");

        lines_with_constant.put("YOU DEFEATED SCYLLA!!", "M_CUTSCENE_5_1");
        lines_with_constant.put("WE FOUND A SECOND PIECE OF THE MAP.", "M_CUTSCENE_5_2");
        lines_with_constant.put("WE ONLY NEED THE LAST PIECE NOW!", "M_CUTSCENE_5_3");
        
        lines_with_constant.put("YOU DEFEATED CHARYBDIS!!", "M_CUTSCENE_6_1");
        lines_with_constant.put("WE NOW HAVE THE FULL MAP OF AIGAI.", "M_CUTSCENE_6_2");
        lines_with_constant.put("WE MUST HURRY AND ATTACK TRITON", "M_CUTSCENE_6_3");
        lines_with_constant.put("BEFORE IT'S TOO LATE!", "M_CUTSCENE_6_4");

        lines_with_constant.put("AT LAST!!", "M_CUTSCENE_7_1");
        lines_with_constant.put("TRITON WAS DEFEATED, AND", "M_CUTSCENE_7_2");
        lines_with_constant.put("HUMANITY CAN REST AT PEACE ONCE", "M_CUTSCENE_7_3");
        lines_with_constant.put("AGAIN! WELL DONE!", "M_CUTSCENE_7_4");

        lines_with_constant.put("CONGRATULATIONS!!!", "E_CUTSCENE_1");
        lines_with_constant.put("AFTER A LONG AND COSTLY", "E_CUTSCENE_2");
        lines_with_constant.put("BATTLE, YOUR COURAGE", "E_CUTSCENE_3");
        lines_with_constant.put("AND SKILL DEFEATED THE", "E_CUTSCENE_4");
        lines_with_constant.put("EVIL TRITON EMPIRE!", "E_CUTSCENE_5");
        lines_with_constant.put("THANK YOU FOR PLAYING", "E_CUTSCENE_6");
        lines_with_constant.put("THE MENACE FROM TRITON", "E_CUTSCENE_7");
        lines_with_constant.put("SANTIAGO ONTAÑÓN", "E_CUTSCENE_8");
        lines_with_constant.put("BRAIN GAMES 2020", "E_CUTSCENE_9");
        lines_with_constant.put("WAS CREATED FOR THE", "E_CUTSCENE_10");
        lines_with_constant.put("MSXDEV 2020 COMPO", "E_CUTSCENE_11");
        lines_with_constant.put("KEEP THE MSX ALIVE!", "E_CUTSCENE_12");

        for(String s:lines_with_constant.keySet()) {
            if (!lines.contains(s)) lines.add(s);
        }


        // weapons:
        for(String s:weapon_names) {
            if (lines.indexOf(s) == -1) lines.add(s);
        }
        for(String l[]:weapon_descriptions) {
            for(String s:l) {
                if (lines.indexOf(s) == -1) lines.add(s);
            }
        }

        // List<String> newlines = lines;
        List<String> newlines = optimizeGrouppings(lines, font, 512);
        // List<String> newlines = optimizeGrouppings(lines, font, 600);
        // List<String> newlines = optimizeGrouppings(lines, font, 640);
        // List<String> newlines = optimizeGrouppings(lines, font, 700);
        // List<String> newlines = optimizeGrouppings(lines, font, 4096);
        
        HashMap<String, Pair<Integer, Integer>> ids = new HashMap<>();
        EncodeText.encodeTextInBanks(newlines, font, 512, "src/autogenerated", ids);
        /*
        for(String line:lines) {
            System.out.println(line + " -> " + ids.get(line).m_a + ", " + ids.get(line).m_b);
        }
        */

        // String constants:
        {
            FileWriter fw = new FileWriter(new File("src/autogenerated/text-constants.asm"));
            for(String s:lines_with_constant.keySet()) {
                fw.write("TEXT_"+lines_with_constant.get(s)+"_BANK:   equ " + ids.get(s).m_a + "\n");
                fw.write("TEXT_"+lines_with_constant.get(s)+"_IDX:   equ " + ids.get(s).m_b + "\n");            
            }
            fw.flush();
            fw.close();
        }
        
        
        // Generate weapon tables:
        {
            FileWriter fw = new FileWriter(new File("src/autogenerated/weapon-data.asm"));
            int weapon_gfx[] = {
                    9,9,31,31,      // speed
                    9,9,31,31,      // initial speed
                    10,11,31,31,    // transfer
                    18,19,34,35,    // bullet
                    18,19,36,35,    // twin bullet
                    18,21,34,37,    // triple bullet
                    22,23,38,39,    // shield
                    24,25,40,41,    // light torpedoes
                    24,25,40,41,    // heavy torpedoes
                    26,27,42,43,    // up missiles
                    26,28,42,44,    // down missiles
                    26,27,42,44,    // bidirectional missiles
                    29,19,45,46,    // laser
                    29,19,45,46,    // twister laser
                    29,19,45,68,    // flame
                    48,49,64,65,
                    50,51,66,67,
                    53,54,69,70,
                    55,56,71,72,
                    57,58,73,74,
                    59,59,59,59};
            fw.write("weapon_gfx_and_names:\n");
            fw.write("    db 16,17,32,33, #ff,#ff\n");

            for(int i = 0;i<weapon_names.length;i++) {
                String s = weapon_names[i];
                int bank = ids.get(s).m_a;
                int idx = ids.get(s).m_b;
                fw.write("    db " + weapon_gfx[i*4] + ", " + weapon_gfx[i*4+1] + ", " + 
                                     weapon_gfx[i*4+2] + ", " + weapon_gfx[i*4+3] + ", " + bank + ", " + idx + "\n");
            }

            fw.write("\nweapon_detailed_descritions:\n");
            for(int i = 0;i<weapon_descriptions.length;i++) {
                fw.write("    db ");
                for(int j = 0;j<4;j++) {
                    int bank = 255;
                    int idx = 255;
                    if (weapon_descriptions[i].length>j) {
                        bank = ids.get(weapon_descriptions[i][j]).m_a;
                        idx = ids.get(weapon_descriptions[i][j]).m_b;
                    }
                    fw.write(bank + ", " + idx);
                    if (j== 3) {
                        fw.write("\n");
                    } else {
                        fw.write(", ");
                    }
                }
            }        
            
            fw.write("\n"+
                    "weapon_max_buyable_upgrades:\n"+
                    "    db 3 ; speed up (4 - 6 - 8 speed ups)\n"+
                    "    db 3 ; init speed \n"+
                    "    db 2 ; transfer (1 - 2 credits per use)\n"+
                    "    db 3 ; bullet (1 - 2 - 3 upgrades)\n"+
                    "    db 2 ; twin bullet (1 - 2 upgrades)\n"+
                    "    db 3 ; triple bullet (1 - 2 - 3 upgrades)\n"+
                    "    db 2 ; shield (3 - 5 protection)\n"+
                    "    db 3 ; light torpedoes (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; heavy torpedoes (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; up missiles (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; down missiles (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; bidirectional missiles (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; laser (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; twister laser (1 - 2 - 3 upgrades)\n"+
                    "    db 3 ; flame (1 - 2 - 3 upgrades)\n"+
                    "    db 2 ; bullet option (2 - 3 upgrades)\n"+
                    "    db 2 ; missile option (2 - 3 upgrades)\n"+
                    "    db 2 ; directional option (2 - 3 upgrades)\n"+
                    "    db 2 ; level-up start\n"+
                    "    db 1 ; start with highest primary weapon\n"+
                    "    db 4 ; pilots\n"+
                    "\n"+
                    "weapon_max_ingame_upgrades_at_level:\n"+
                    "    db 3,5,7 ; speed up (3 - 5 - 7 speed ups)\n"+
                    "    db 0,0,0 ; init speed\n"+
                    "    db 32,16,16 ; transfer (1 - 2 credits per use)\n"+
                    "    db 1,2,3 ; bullet (1 - 2 - 3 upgrades)\n"+
                    "    db 1,2,3 ; twin bullet (1 - 2 upgrades)\n"+
                    "    db 1,2,3 ; triple bullet (1 - 2 - 3 upgrades)\n"+
                    "    db 3,5,5 ; shield (3 - 5 protection)\n"+
                    "    db 1,2,3 ; light torpedoes (1 - 2 - 3 upgrades)\n"+
                    "    db 1,2,3 ; heavy torpedoes (1 - 2 - 3 upgrades)\n"+
                    "    db 1,2,3 ; up missiles (1 - 2 - 3 upgrades)\n"+
                    "    db 1,2,3 ; down missiles (1 - 2 - 3 upgrades)\n"+
                    "    db 1,2,3 ; bidirectional missiles (1 - 2 - 3 upgrades)\n"+
                    "    db 1,2,3 ; laser (1 - 4 upgrades)\n"+
                    "    db 1,2,3 ; twister laser (1 - 4 upgrades)\n"+
                    "    db 1,2,3 ; flame (1 - 4 upgrades)\n"+
                    "    db 2,3,3 ; bullet option (2 - 3 upgrades)\n"+
                    "    db 2,3,3 ; missile option (2 - 3 upgrades)\n"+
                    "    db 2,3,3 ; missile option (2 - 3 upgrades)\n"+
                    "    db 0,0,0 ; level-up start\n"+
                    "    db 0,0,0 ; start with highest primary weapon\n"+
                    "    db 0,0,0 ; pilots\n"+
                    "\n"+
                    "weapon_price:\n"+
                    "    db 1 ; speed up\n"+
                    "    db 1 ; init speed\n"+
                    "    db 6 ; transfer\n"+
                    "    db 2 ; bullet\n"+
                    "    db 2 ; twin bullet\n"+
                    "    db 3 ; triple bullet\n"+
                    "    db 2 ; shield\n"+
                    "    db 2 ; light torpedoes\n"+
                    "    db 2 ; heavy torpedoes\n"+
                    "    db 2 ; up missiles\n"+
                    "    db 2 ; down missiles\n"+
                    "    db 2 ; bidirectional missiles\n"+
                    "    db 3 ; laser\n"+
                    "    db 4 ; twister laser\n"+
                    "    db 4 ; flame\n"+
                    "    db 2 ; bullet option\n"+
                    "    db 2 ; missile option\n"+
                    "    db 2 ; directional option (2 - 3 upgrades)\n"+
                    "    db 2 ; level-up start\n"+
                    "    db 2 ; start with highest primary weapon\n"+
                    "    db 2 ; pilots\n"+
                    "\n"+

                    "weapon_slot_number:\n"+
                    "    db 0 ; speed up\n"+
                    "    db #ff ; init speed\n"+
                    "    db 7 ; transfer\n"+
                    "    db 2 ; bullet\n"+
                    "    db 3 ; twin bullet\n"+
                    "    db 3 ; triple bullet\n"+
                    "    db 6 ; shield\n"+
                    "    db 1 ; light torpedoes\n"+
                    "    db 1 ; heavy torpedoes\n"+
                    "    db 1 ; up missiles\n"+
                    "    db 1 ; down missiles\n"+
                    "    db 1 ; bidirectional missiles\n"+
                    "    db 4 ; laser\n"+
                    "    db 4 ; twister laser\n"+
                    "    db 4 ; flame\n"+
                    "    db 5 ; bullet option\n"+
                    "    db 5 ; missile option\n"+
                    "    db 5 ; directional option\n"+
                    "    db #ff ; level-up start\n"+
                    "    db #ff ; start with highest primary weapon\n"+
                    "    db #ff ; pilots\n");
            fw.flush();
            fw.close();
            nl.grauw.glass.Assembler.main(new String[]{"src/autogenerated/weapon-data.asm", "src/autogenerated/weapon-data.bin"});
            Pletter.intMain(new String[]{"src/autogenerated/weapon-data.bin", "src/autogenerated/weapon-data.plt"});
            APLib.main("src/autogenerated/weapon-data.bin", "src/autogenerated/weapon-data.apl", true);
        }
    }
    
    
    public static List<String>  optimizeGrouppings(List<String> input_lines, PAKFont font, int group_size) throws Exception
    {
        List<String> bestLines = null;
        EncodeText.useaplib = false;
        int best_size = 0;
        int best_seed = 0;      // seed 234: 1899 (for group_size 512, with 0.5 lateral moves)
                                // seed 0: 1903 (for group size 600)
                                // seed 3: 1874 (for group size 640)
                                // seed 6: 1850 (for group size 700)
        for(int seed = 0;seed<0+1;seed++) {
//        for(int seed = 0;seed<1000;seed++) {
//        for(int seed = 234;seed<234+1;seed++) {

            Pair<List<String>,Integer> tmp = optimizeGrouppingsInternal(input_lines, font, group_size, seed);
            if (bestLines == null || tmp.m_b < best_size) {
                bestLines = tmp.m_a;
                best_size = tmp.m_b;
                best_seed = seed;
                System.out.println("new best_size: " + best_size + " (best_seed: " + best_seed + ")");
            }
        }
        
        System.out.println("final best_size: " + best_size + " (best_seed: " + best_seed + ")");
        return bestLines;
    }
    
    
    public static Pair<List<String>,Integer>  optimizeGrouppingsInternal(List<String> input_lines, PAKFont font, int group_size, int seed) throws Exception  
    {
        Random r = new Random();
        r.setSeed(seed);

        List<String> lines = new ArrayList<>();
        lines.addAll(input_lines);
        Collections.shuffle(lines, r);
        int initial_size = EncodeText.estimateSizeOfAllTextBanks(lines, font, group_size);
        int best = initial_size;
        System.out.println("Original order size: " + EncodeText.estimateSizeOfAllTextBanks(input_lines, font, group_size));
        System.out.println("Initial size (seed " + seed + "):" + initial_size);

        double threshold = 1.0; // 1.0 means doing it sistematically, lower values run faster, but might not result in the best results
        double temperature = 0.0;
        double temperature_decay = 0.8;
        boolean repeat = true;
        // boolean repeat = false;
        while(repeat){
            repeat = false;
            System.out.println("temperature: " + temperature);
            for(int idx1 = 0;idx1<lines.size();idx1++) {
                // System.out.println(idx1 + "");
                for(int idx2 =idx1+1;idx2<lines.size();idx2++) {
                    if (r.nextDouble() > threshold) continue;
                    String tmp1 = lines.get(idx1);
                    String tmp2 = lines.get(idx2);
                    lines.set(idx1, tmp2);
                    lines.set(idx2, tmp1);

                    int size = EncodeText.estimateSizeOfAllTextBanks(lines, font, group_size);
                    if (size < best) {
                        System.out.print(size + " ");
                        best = size;
                        repeat = true;
                    } else if (size == best && r.nextDouble() > 0.5) {
                        System.out.print(size + "* ");
                        best = size;
                        // repeat = true;
                    } else {
                        if (r.nextDouble() > temperature) {
                            // undo the swap:
                            lines.set(idx1, tmp1);
                            lines.set(idx2, tmp2);
                        } else {
                            System.out.println("- temperature ("+temperature+") induced random swap: " + size);
                            best = size;
                            repeat = true;                            
                        }
                    }
                }
            }
            System.out.println("");
            temperature *= temperature_decay;
            
            // repeat = false;
        }
        
        // System.out.println(lines);
        
        return new Pair<>(lines, best);
    }
}