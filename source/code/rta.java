/**
 **************************************************************
 * Copyright (c) 2018 Robert Bosch GmbH.
 * 
 * This program and the accompanying materials are made
 * available under the terms of the Eclipse Public License 2.0
 * which is available at https://www.eclipse.org/legal/epl-2.0/
 * 
 * SPDX-License-Identifier: EPL-2.0
 * 
 * Contributors:
 *     Robert Bosch GmbH - initial API and implementation
 *************************************************************
 */

package app4mc.example.tool.java;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import org.eclipse.app4mc.amalthea.model.AmaltheaFactory;
import org.eclipse.app4mc.amalthea.model.DiscreteValueConstant;
import org.eclipse.app4mc.amalthea.model.SWModel;
import org.eclipse.app4mc.amalthea.model.Ticks;
import org.eclipse.app4mc.amalthea.model.Runnable;
import org.eclipse.app4mc.amalthea.model.util.*;
import org.eclipse.emf.common.util.EList;

public class rta{

    public static Long findIndexOfMinValue(Map<Long, Integer> hashMap){
        ArrayList<Long> al = new ArrayList<Long>();
        for (Long m: hashMap.keySet()) {
                al.add(m);
        }
        Long minVal  = Long.MAX_VALUE;
        for (int i=0; i<hashMap.size();i++) {
            if (al.get(i)<minVal) {
                minVal = al.get(i);
            }
        } 
        
        return minVal;         
}

    public static Map<Long, Integer> updateH ( Map<Long, Integer> h, Long ticks, Integer blocks){
        if ( h.containsKey(ticks) ){
            h.put( ticks , h.get( ticks ) + blocks); 
        }
        else h.put( ticks, blocks );
        return h;
    }

    // Input: swmodel  
    // Output: Completion times
    public static ArrayList<Long> rtaAlgorithm(SWModel swmodel){
        EList<Runnable> rList = swmodel.getRunnables();
    
        ArrayList<Long> c_i = new ArrayList<Long>();
        ArrayList<Integer> g_i = new ArrayList<Integer>();
        ArrayList<Long> f = new ArrayList<Long>();

        // Set values c_i, g_i
        for (int i = 0; i < rList.size(); i++) {
            Runnable rr = rList.get(i);
            c_i.add( ((DiscreteValueConstant) SoftwareUtil.getTicks(rr, null).get(0).getDefault()).getValue() );
            g_i.add( CustomPropertyUtil.customGetInteger(rr, "GridSize") );
    }

        // Initialization algorithm 
        Long t_a = (long) 0;
        Integer g_max = 8; 
        Integer g_f = g_max; 
        Map< Long, Integer> h = new HashMap<Long, Integer>();
        int current_kernel = 0;
        Long minimumRegisteredTicks;
  
       // Main loop 
        while ( current_kernel < rList.size() ) {
            if (g_f >= g_i.get(current_kernel) ){
               f.add(current_kernel, t_a + c_i.get(current_kernel) ) ; 

               h = updateH(h, f.get(current_kernel), g_i.get(current_kernel) ); 

               g_f = g_f - g_i.get(current_kernel);
               current_kernel++;
            } 
            else {
                g_i.set(current_kernel, g_i.get(current_kernel) - g_f);

                h = updateH(h, t_a + c_i.get(current_kernel), g_f );
                minimumRegisteredTicks = findIndexOfMinValue(h);

                g_f = h.get(minimumRegisteredTicks);
                t_a = minimumRegisteredTicks;

                h.remove(minimumRegisteredTicks);
            }
        } 

        return f;
    }

    public static void main(String[] args) {


    	// Creating a SWModel
        SWModel swmodel = AmaltheaFactory.eINSTANCE.createSWModel();         
        
        Random rand = new Random();
        int tick;
        int NumberOfRunnables = 5; 
        int minTicks = 10;
        int maxTicks = 20;
        int minGridSize = 2;
        int maxGridSize = 20;
        int gridSize;

        for(int i=0; i<NumberOfRunnables; i++) {
        	Runnable r = AmaltheaFactory.eINSTANCE.createRunnable();
        	Ticks ticks = AmaltheaFactory.eINSTANCE.createTicks();
        	DiscreteValueConstant dvc = AmaltheaFactory.eINSTANCE.createDiscreteValueConstant();
            tick = rand.nextInt((maxTicks - minTicks) +1) + minTicks;
        	dvc.setValue(tick);
        	ticks.setDefault(dvc);
        	r.getRunnableItems().add(ticks);
        	gridSize = rand.nextInt((maxGridSize - minGridSize) +1) + minGridSize;
            CustomPropertyUtil.customPut(r, "GridSize", gridSize);
        	swmodel.getRunnables().add(r);
        }

        ArrayList<Long> f = new ArrayList<Long>();

        f = rtaAlgorithm(swmodel);
        
        for( int i=0; i<f.size(); i++){
            System.out.println("\t Computation time:" + f.get(i));
        }
    }
}
