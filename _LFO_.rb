# _LFO_
clear

TAU = 2 * Math::PI
class LFO
  attr_reader :name
  
  @@instances = []
  @@random = Random.new
  
  # Constructor is private; use LFO.getLfo
  def initialize(name, freq, minVal, maxVal, waveForm = :sin, stepCount = 1024 * 5)
    @name = name
    @stepCount = stepCount
    @stepDur = (1/freq.to_f)/@stepCount
    @prevTime = 0
    @acc = 0
    setWaveForm(waveForm, minVal, maxVal)
  end

  def self.getLfo(name, freq: nil, min: nil, max: nil, wave: nil)
    lfo = @@instances.find{|l| l.name == name}
    if lfo == nil
      f = freq != nil ? freq : 1
      minVal = min != nil ? min : 0
      maxVal = max != nil ? max : 1
      w = wave != nil ? wave : :sin
      lfo = new(name, f, minVal, maxVal, w)
      @@instances.push lfo
    else
      if freq != nil
        lfo.freq(freq)
      end
      if min != nil and max != nil and wave != nil
        lfo.setWaveForm(wave, min, max)
      elsif min != nil and max != nil
        lfo.range(min, max)
      elsif wave != nil
        lfo.waveForm(wave)
      end
    end
    lfo
  end

  def freq(f)
    @stepDur = (1/f.to_f)/@stepCount if f != nil
  end
  
  def waveForm(waveForm)
    setWaveForm(waveForm, @minVal, @maxVal)
  end
  
  def range(minVal, maxVal)
    setWaveForm(@waveForm, minVal, maxVal)
  end
  
  def tick
    diff = now - @prevTime
    @acc += (diff/@stepDur).round
    @prevTime = now
    value
  end
  
  def value
    @values[@acc]
  end
  
  # Utility methods
  def now
    Time.now.to_f
  end
  
  def map(x, min1, max1, min2, max2)
    (x - min1) * ((max2 - min2).to_f/(max1 - min1).to_f) + min2 # y = (x - a) * ((d - c)/(b - a)) + c
  end
  
  def setWaveForm(waveForm, minVal, maxVal)
    @waveForm = waveForm
    @minVal = minVal.to_f
    @maxVal = maxVal.to_f
    @values = Array.new((@stepCount/2.0)+1){|i| map(i.to_f/(@stepCount/2.0), 0, 1, @minVal, @maxVal)}.ring.reflect if waveForm == :tri
    @values = Array.new(@stepCount){|i| map(Math::sin((i.to_f/@stepCount)*TAU)+1, 0, 2, @minVal, @maxVal)}.ring if waveForm == :sin
    @values = Array.new(@stepCount){|i| map(i.to_f/@stepCount, 0, 1, @minVal, @maxVal)}.ring if waveForm == :ramp
    @values = Array.new(@stepCount){|i| map(1-(i.to_f/@stepCount), 0, 1, @minVal, @maxVal)}.ring if waveForm == :saw
    @values = Array.new(@stepCount){|i| i > @stepCount/2.0 ? @maxVal : @minVal}.ring if waveForm == :squ
    @values = Array.new(@stepCount){@@random.rand(@minVal..@maxVal)}.ring if waveForm == :rng
  end
  
  private :now, :map
  private_class_method :new
end

'''
# Usage example
lfo1 = LFO.getLfo :lfo1, wave: :sin, freq: 0.01, min: 0.1, max: 0.99 # Controls echo.mix and lpf.res
lfo2 = LFO.getLfo :lfo2, wave: :saw, freq: 0.05, min: -1, max: 1     # Controls the panning
lfo3 = LFO.getLfo :lfo3, wave: :sin, freq: 0.005, min: 55, max: 108  # Controls lpf.cutoff
lfo4 = LFO.getLfo :lfo4, wave: :squ, freq: 0.1, min: 0, max: 2       # Controls the chord to be played
lfo5 = LFO.getLfo :lfo5, wave: :sin, freq: 0.05, min: 0.001, max: 4  # Controls lfo3.freq

use_bpm 53

echo = nil
lpf = nil
live_loop :lfoLoop do
  control echo, mix: lfo1.tick if echo != nil
  control lpf, cutoff: lfo3.tick, res: lfo1.value if lpf != nil
  lfo3.freq lfo5.tick
  sleep 0.05
end

live_loop :l0 do
  use_synth :mod_dsaw
  with_fx :rlpf, cutoff_slide: 0.05, res_slide: 0.01 do |fx0|
    lpf = fx0
    with_fx :echo, phase: 0.05, decay: 0.1, mix: 0.95 do |fx1|
      echo = fx1
      play_pattern_timed chord(:Ds3 + lfo4.tick, :m), [[0.1,0.25,0.15],[0.5,0.1,0.4],[0.25,0.25,0.25]].choose, pan: lfo2.tick
    end
  end
end
'''


