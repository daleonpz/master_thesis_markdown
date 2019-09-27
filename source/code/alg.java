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

