/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package text;

import java.io.FileWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import util.APLib;
import util.Pair;
import util.Pletter;
import util.Z80Assembler;

/**
 *
 * @author santi
 */
public class EncodeText {
    public static int MAX_LINES_PER_BANK = 64;
    public static boolean useaplib = true;
    
    // maxBankSize is in bytes of text per bank
    public static Pair<List<Integer>,List<Integer>> encodeTextInBanks(List<String> lines, PAKFont font, int maxBankSize, String outputFolder, HashMap<String, Pair<Integer, Integer>> ids) throws Exception
    {
        List<Integer> sizes_before = new ArrayList<>();
        List<Integer> sizes_after = new ArrayList<>();
        int bank = 0;
        int bankSize = 0;
        List<String> bankLines = new ArrayList<>();
        for(String line:lines) {
            if (bankSize + 1 + line.length() > maxBankSize ||
                bankLines.size()>=MAX_LINES_PER_BANK) {
                // new bank:
                System.out.println("   predicted text bank size: " + bankSize);
                Pair<Integer,Integer> tmp = compressTextLines(bankLines, font, outputFolder, "textBank" + bank);
                sizes_before.add(tmp.m_a);
                sizes_after.add(tmp.m_b);
                bankSize = 0;
                bankLines.clear();
                bank++;
            }
            ids.put(line, new Pair<>(bank, bankLines.size()));
            bankLines.add(line);   
            bankSize += 1 + line.length();
        }

        System.out.println("   predicted text bank size: " + bankSize);
        Pair<Integer,Integer> tmp = compressTextLines(bankLines, font, outputFolder, "textBank" + bank);
        sizes_before.add(tmp.m_a);
        sizes_after.add(tmp.m_b);
        
        return new Pair<>(sizes_before, sizes_after);
    }
    
    
    // returns the size of the data before and after compression
    public static Pair<Integer,Integer> compressTextLines(List<String> lines, PAKFont font, String outputFolder, String fileName) throws Exception
    {
        List<Integer> data = new ArrayList<>();
        FileWriter fw = new FileWriter(outputFolder + "/" + fileName + ".asm");

        for(String line:lines) {
            List<Integer> line_data;
            line_data = font.convertStringToAssembler(line);
            if (line_data.size() > 255) throw new Exception("Line of text longer than 255 characters!");
            // data.add(line_data.size());
            data.addAll(line_data);
            fw.write("; line: '" + line + "'\n");
            Z80Assembler.dataBlockToAssembler(line_data, "line_"+lines.indexOf(line), fw, 16);
        }
        
        fw.close();
        nl.grauw.glass.Assembler.main(new String[]{outputFolder + "/" + fileName + ".asm", outputFolder + "/" + fileName + ".bin"});
        int compressedSizePletter = Pletter.intMain(new String[]{outputFolder + "/" + fileName + ".bin", outputFolder + "/" + fileName + ".plt"});
        int compressedSizeAPLib = APLib.main(outputFolder + "/" + fileName + ".bin", outputFolder + "/" + fileName + ".apl", true);
        if (useaplib) {
            return new Pair<>(data.size(), compressedSizeAPLib);
        } else {
            return new Pair<>(data.size(), compressedSizePletter);
        }
    }
    
    
    // maxBankSize is in bytes of text per bank
    public static int estimateSizeOfAllTextBanks(List<String> lines, PAKFont font, int maxBankSize) throws Exception
    {
        int total_size = 0;
        int bankSize = 0;
        List<String> bankLines = new ArrayList<>();
        for(String line:lines) {
            if (bankSize + 1 + line.length() > maxBankSize ||
                bankLines.size()>=MAX_LINES_PER_BANK) {
                // new bank:
                // System.out.println("   predicted text bank size: " + bankSize);
                total_size += estimateSizeOfCompressedTextBank(bankLines, font);
                bankSize = 0;
                bankLines.clear();
            }
            bankLines.add(line);   
            bankSize += 1 + line.length();
        }

        // System.out.println("   predicted text bank size: " + bankSize);
        total_size += estimateSizeOfCompressedTextBank(bankLines, font);
        return total_size;
    }    
    
    public static int estimateSizeOfCompressedTextBank(List<String> lines, PAKFont font) throws Exception
    {
        List<Integer> data = new ArrayList<>();

        for(String line:lines) {
            List<Integer> line_data;
            line_data = font.convertStringToAssembler(line);
            if (line_data.size() > 255) throw new Exception("Line of text longer than 255 characters!");
            data.addAll(line_data);
        }
        
        // make sure buffer is not too small for pletter:
        while(data.size()<16) data.add(0);
        
        if (useaplib) {
            return APLib.sizeOfCompressedBuffer(data, "texttmp");
        } else {
            return Pletter.sizeOfCompressedBuffer(data);
        }
    }
}
