#LFOing

#requires _LFO_

use_bpm 73

lfo1 = LFO.getLfo :lfo1, wave: :sin, freq: 0.005, min: 55, max: 110
lfo2 = LFO.getLfo :lfo2, wave: :saw, freq: 0.1, min: 0.45, max: 0.98
lfo3 = LFO.getLfo :lfo3, wave: :sin, freq: 0.1, min: 0.005, max: 0.5

lpf = nil
echo = nil
live_loop :lfos do
  control lpf, cutoff: lfo1.tick, res: lfo2.tick if lpf != nil
  control echo, phase: lfo2.value, decay: lfo1.value / 55 if echo != nil
  lfo1.freq(lfo3.tick)
  sleep 0.075
end

live_loop :lmel do
  use_synth :supersaw
  with_fx :echo, mix: 0.58, phase_slide: 0.25, decay_slide: 0.1 do |fx0|
    echo = fx0
    with_fx :rlpf, cutoff_slide: 0.1, res_slide: 0.1 do |fx1|
      lpf = fx1
      play_pattern_timed scale(:As3, :minor).pick(4), [0.5,0.25,0.25,0.5]
      play_pattern_timed chord(:Fs3, :M), [0.25,0.1,0.15]
      play_pattern_timed scale(:Cs3, :major).pick([3,3,3,4,4,6].choose), 0.5
      play_pattern_timed chord(:Ds3, :m), [[0.1,0.25,0.15], [0.5,0.1,0.4]].choose
    end
  end
end
