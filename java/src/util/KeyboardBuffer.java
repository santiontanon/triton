/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package util;

import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

/**
 *
 * @author santi
 */
public class KeyboardBuffer implements KeyListener {
    final int KeyboardBufferSize = 256;
    public boolean keyboardbuffer[] = new boolean[KeyboardBufferSize];
    
    public KeyboardBuffer() {
        for(int i = 0;i<KeyboardBufferSize;i++) keyboardbuffer[i] = false;
    }
    
    @Override
    public void keyTyped(KeyEvent e) {
    }

    @Override
    public void keyPressed(KeyEvent e) {
        int k = e.getKeyCode();
        if (k>=0 && k<KeyboardBufferSize) keyboardbuffer[k] = true;
    }

    @Override
    public void keyReleased(KeyEvent e) {
        int k = e.getKeyCode();
        if (k>=0 && k<KeyboardBufferSize) keyboardbuffer[k] = false;
    }
    
}
