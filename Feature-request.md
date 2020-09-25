# Feature requests

This is the file we will use to keep track of feature requests. 

### Tutorials
* Notebook example of using Tektronix xxxx together with the Zurich instruments ultra high frequency quantum analyzer
* Notebook example of using Tektronix xxxx together with the Alazar card 
* Notebook examples of broadbean together with Tektronix 5014,5208 and 7000A 



### Broadbean Features
* Nice way of saving and loading waveforms. This could be used both as documentation/repeatability and to build a library of commonly used waveforms
* Broadbean support for more than 2 triggers 
* For broadbean to create parameters e.g a setpoint array based on the sequence that is created. Suppose I create a sequence that changes the duration of something in each element. Then it's likely that I want that to be a parameter for some measurement. Broadbean should create sensible parameters with the pulse sequence without having to manually create them later.
+ Integration with qcodes parameters and metadata system. Perhaps a sequence can be exposed as some (temporary) vitual instrument (using a name given as required argument of Sequence.__init__). The snapshot of the sequence 'instrument' returns a complete serialization of all required information to recreate the sequence from scratch. Parameters of named segments (used in the sequence) become exposed as qcodes parameters ordered in a channel per **named** sequence such that sequence parameter can be used as independent measurement parameters. A possible challenge could be that, depending on the setup (i.e. user wishes) the qcodes parameter should be either ArrayParameters (buffered senario) or Parameters (triggered scenario), but quite likely an easy solution exists. There are perhaps other challenges, but lets think together how to tackle these as probably non of these will be hard to solve.
    ```` python
    bp_pulse = bb.BluePrint()
    bp_pulse.insertSegment(0, ramp, (0, 0), dur=0.5)
    bp_pulse.insertSegment(1, ramp, (1, 1), dur=1, name='high')
    bp_pulse.insertSegment(2, 'waituntil', 5)
    elem1 = bb.Element()
    elem1.addBluePrint(1, bp_square)
    seq1 = bb.Sequence('T1Sequence')
    seq1.addElement(1, elem1)  # Call signature: seq. pos., element
    
    meas = Measurement(exp=exp, station=station)
    meas.register_parameter(seq1.high.duration) 
    meas.register_parameter(acquisition, setpoints=(seq1.high.duration,))
* Create sequence from serialization (taken from metadata). This allows for the quick visualization of sequences executed during a measurement being studied/analysed. 
    ```` python
    dataset = load_by_run_spec(experiment_name='dataset_context_manager', captured_run_id=1)
    # Retrieve the snapshot of the sequence named 'T1Sequence' from the metadata
    sequence_shapshot = dataset.snapshot.<>.T1Sequence 
    sequence = bb.Sequence.from_snapshot(sequence_shapshot)
    plotter(sequence)
    
    # We can now even re-use the sequence to repeat a measurement
    meas = Measurement(exp=exp, station=station)
    meas.register_parameter(sequence.high.duration) 
    meas.register_parameter(acquisition, setpoints=(sequence.high.duration,))
### "Broadbean" GUI Features
* Make the "broadbean" GUI support different AWGs

### Alazar requests


### Other
* Something   
