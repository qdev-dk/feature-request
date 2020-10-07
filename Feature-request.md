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
* Clean the raw driver (perhaps best to replace it with the vendor provided one?)
  Or perhaps make a new wrapper using cython, but likely it's not that much faster considering it's only streams.  
* Add a single QCOdes get-parameter (.trace) to acquire data in a blocking way
* Add a single method (.acquire) to aquire data in a non-blocking way (using a thread)
  ```` python
  def acquire(self, buffer_ready=None, acquisition_ready=None):
    """ Organize buffer, start thread that acquires data
    Argument:
    -  buffer_ready: function((buffer_numpy_handles)) to be called when a buffer is complete. This function should return before the buffers are again required by the alazar.
    -  acquisition_ready: function to be called when acquisition is complete
    """
* Add a QCodes get-parameter (.trace_async) wrapping .acquire. Its .get() method should return a concurrent.Future 
  which returns the data.
* Add raw methods to control alazar acquisition

### DSP virtual instrument
A new virtual instrument handling the processing of numpy arrays in flexible and programmable way and facilitates multiple data outputs (channels) via QCodes parameters. The actual execution of the chain happens in a continuous active background thread which waits for input on an internal 'input' queue.
  - It exposes a .add_node(fnc, bind=None) method that adds an execution node 
    * fnc should be a function accepting the right number of positional arguments and the keyword arguments 'local' and 'output' and returning the data to be handled by the next node in the chain. 
        The argument 'local' will be given a dictionary with registered data (see .register() method and the example). 
        The argument 'output' will be given a dictionary with output buffers (perhaps this should be \*\*kwargs instead?). Output will only contains those keys declared by a 'binding'.
    * When bind is given it should be a dictionary containing keys corresponding to the output dictionary elements. Each dict-value should either be a dictionary containing qcodes parameter initialization arguments (in which case qc-parameters will be created) or a reference to an existing qc-parameter.
  - Need to figure out what would be the best way to enforce a proper snapshot of the function (serialize or enforce git-tracked module? Or either?).
  - It exposes a .register(name, data, snapshot=None) method to store data which is persistent between dsp executions such as reference traces (subtract background, demodulation references, etc). 
    * The value of 'data' will be added the DSP snapshot under 'register.name' unless keyword argument 'snapshot' is provided in which case the snapshot value will be used. This is especially useful when registering data which can be parameterized easily like demodulation references (A*cos(2*pi*f0*t)). In these cases it may be more useful to store the parameters (e.g. A, f0) instead of the data. This is a little dangerous as the user may provide insufficient snapshot data to parametrize the function, but the alternative are worse.
    * When data is a string it is assumed to be a numexpr which will be evaluated as numepxr.evaluate(data, local_dict = snapshot, global_dict = registered_data, out=output), registered_data is the dict of registered values with the DSP and output is the value stored in the DSP register. After evaluation, the numexpr expressing ('data') will be added to the snapshot.
    * Calling this function with an existing name, will just overwrite the data. 
- It exposes a .push(buffer_numpy_handle) methods that queues/triggers an execution of the DSP chain (adds an item the the internal input queue). This function should be a little smart about either adding the buffer handle directly (when the DSP is able to process faster than the buffer is required again) or adding a copy of the data. When auto-detection of overflow is hard, we can add an instance attribute (.copy_on_input) to indicate what to do with incoming data. 
- It (the background thread) adds execution results to internal queues (one per output channel)
- It exposes a .pull(timeout=None) method which pulls from the queues (blocking ) add 'populates' the QCodes parameters.
- Data is pulled via the QCodes parameters.

Example using the gpu as computational back-end
```` python 
import cupy as cp
import cusignal
from cusignal.filter_design.fir_filter_design import firwin

# This implements demodulation for a single frequency. Scaling up to many is straight-forward. 
def gpu_filter(buffer, local, output):
    # Example of a function implementing a single output stream
    gpud = cusignal.get_shared_mem(len(buffer), dtype=type(input))
    gpud[:] = input # Transfer the data to the gpu
    gpud = cp.reshape(gpud, local['pnts'], local['N'])
     
    # Multiply the gpu data with the gpu_data register in the DSPmachine
    gI = local['sin'] * gpud
    gQ = local['cos'] * gpud
    
    filter = cp.asarray(filter, dtype=cupy.float32)
    fI = cusignal.resample_poly(gI, 16, 25, window=local['filter'], axes=0)
    fQ = cusignal.resample_poly(gQ, 16, 25, window=local['filter'], axis=0)
   
    # If 'traces' is bound, store the result in the output stream 
    if 'traces' in output:
      output['traces'].append((cp.asnumpy(fI), cp.asnumpy(fQ)))
    
    return (fI, fQ)
    
def gpu_integrate(fI, fQ, local, output):
  # Example of a function implementing a two output streams
    iI = cp.mean(fI, axis=0)
    iQ = cp.mean(fQ, axis=0)
    
    mI = cp.mean(fI)
    mQ = cp.mean(fQ)
   
    # If 'values' is bound, store the result in the output stream 
    if 'values' in output:
      output['values'].append( cp.asnumpy(iI) + 1j * cp.asnumpy(iQ))
    
    # If 'average' is bound, store the result in the output stream 
    if 'average' in output:
      output['average'].append( cp.asnumpy(mI) + 1j * cp.asnumpy(mQ) )
    
# Example of API use
dsp = DSPmachine('BareIQ')
dsp.add(gpu_filter, bind={'traces': {...}) # This node binds the 'traces' output stream to a qc-parameter
dsp.add(gpu_integrate, bind={'values', {...}, 'average':{...}} ) # This node binds the 'values' and 'average' output streams to qc-parameters. 

time = cp.linspace(start, stop, num_samps, endpoint=False) 
f0 = 10E6 # Demodulation frequency
fc = 10   # Lowpass filter cutoff frequency
dsp.register('cos', cp.cos(2*np.pi*f0*time), snapshot = dict(ch=1, q='I', ampl=1, f0=f0))
dsp.register('sin', cp.sin(2*np.pi*f0*time), snapshot = dict(ch=1, q='Q', ampl=1, f0=f0))
dsp.register('filter', firwin(251, fc), snapshot = dict(func='cusignal.filter_design.fir_filter_design.firwin', taps=251, fc=fc)

azalar.acquire(buffer_ready = dsp.push)
for i in range(num_buffers):
    dsp.pull(timeout=500) # Wait. When it returns new data has been pushed to the qc-parameters bound.
    meas.add_result(dsp.traces, (time, repetitions, dsp.traces()))
    meas.add_result(dsp.values, (repetitions, dsp.values()))
    meas.add_result(dsp.average, (dsp.average()))
````

### Other
* Something   
