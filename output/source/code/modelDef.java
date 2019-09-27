// Creating a SWModel
SWModel swmodel = AmaltheaFactory.eINSTANCE.createSWModel();         

// Initalization with random values
for(int i=0; i<NumberOfRunnables; i++) {
    Runnable r = AmaltheaFactory.eINSTANCE.createRunnable();
    
    Ticks ticks = AmaltheaFactory.eINSTANCE.createTicks();
    tick = rand.nextInt((maxTicks - minTicks) +1) + minTicks;
    
    DiscreteValueConstant dvc = AmaltheaFactory.eINSTANCE.createDiscreteValueConstant();
    dvc.setValue(tick);
    ticks.setDefault(dvc);

    r.getRunnableItems().add(ticks);
    
    gridSize = rand.nextInt((maxGridSize - minGridSize) +1) + minGridSize;
   
    CustomPropertyUtil.customPut(r, "GridSize", gridSize);
    swmodel.getRunnables().add(r);
}
