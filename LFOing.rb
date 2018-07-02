#LFOing

use_bpm 73


set :lfo, Array.new(50){|i| i + 55}.ring.reflect


live_loop :lmel do
  use_synth :supersaw
  with_fx :rlpf, cutoff_slide: 0.5, res_slide: 0.6 do |lpf|
    controlLpf(lpf)
    play_pattern_timed scale(:As3, :minor).pick(4), [0.5,0.25,0.25,0.5]
    controlLpf(lpf)
    play_pattern_timed chord(:Fs3, :M), [0.25,0.1,0.15]
    controlLpf(lpf)
    play_pattern_timed scale(:Cs3, :major).pick([3,3,3,4,4,6].choose), 0.5
    controlLpf(lpf)
    play_pattern_timed chord(:Ds3, :m), [[0.1,0.25,0.15], [0.5,0.1,0.4]].choose
  end
end

def controlLpf(lpf)
  control lpf, cutoff: get[:lfo].tick(:lfo), res: rrand(0.1, 0.65)
end
