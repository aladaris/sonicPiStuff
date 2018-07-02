# _LFO_
clear

TWO_PI = 2 * Math::PI
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

  def self.instances
    @@instances
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
    @values = Array.new(@stepCount){|i| map(Math::sin((i.to_f/@stepCount)*TWO_PI)+1, 0, 2, @minVal, @maxVal)}.ring if waveForm == :sin
    @values = Array.new(@stepCount){|i| map(i.to_f/@stepCount, 0, 1, @minVal, @maxVal)}.ring if waveForm == :saw
    @values = Array.new(@stepCount){|i| map(1-(i.to_f/@stepCount), 0, 1, @minVal, @maxVal)}.ring if waveForm == :ramp
    @values = Array.new(@stepCount){|i| i > @stepCount/2.0 ? @maxVal : @minVal}.ring if waveForm == :squ
    @values = Array.new(@stepCount){@@random.rand(@minVal..@maxVal)}.ring if waveForm == :rng
  end
  
  private :now, :map
  private_class_method :new
end

'''
# Usage example
lfo1 = LFO.getLfo :lfo1, wave: :sin, freq: 0.1, min: 25, max: 127
lfo2 = LFO.getLfo :lfo2, wave: :saw, freq: 2, min: 0, max: 0.998

use_bpm 60

lpf = nil

live_loop :lfoLoop do
  control lpf, cutoff: lfo1.tick, res: lfo2.tick if lpf != nil
  sleep 0.05
end


live_loop :l0 do
  use_synth :supersaw
  with_fx :rlpf, cutoff_slide: 0.15, res_slide: 0.015 do |fx1|
    lpf = fx1
    play scale([:Es3, :Es2, :Gs2].choose, :locrian).choose, attack: 0.2, sustain: 0.15, release: 0.15
    sleep 0.25
  end
end
'''


