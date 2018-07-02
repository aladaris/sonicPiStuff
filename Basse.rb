# Basse

fDrums = "Y:/Audio/SAMPLES/bateri3/Absynth"

use_bpm 73




t0 = 4
s0 = 1.0/t0
bassMode = true
live_loop :l0 do
  if not one_in(8)
    sample fDrums, [3,4,5,8].choose
  end
  t0.times do
    with_fx :rlpf, cutoff_slide: s0/3 do |lpf|
      if bassMode
        control lpf, cutoff: rrand_i(60, 110), res: rrand(0.5, 0.8)
        sample fDrums, 15, amp: 2.15, attack: rrand(0.005, 0.1)
      else
        control lpf, cutoff: rrand_i(90, 95), res: rrand(0.4, 0.55)
        sample fDrums, [24,24,26,26,28].choose, amp: rrand(0.4, 0.8)
      end
    end
    sleep s0
  end
end

s1 = s0 / 3
live_loop :l1 do
  sync :l0
  use_synth :blade
  with_fx :rlpf, cutoff: rrand_i(60, 75), res: 0.8 do |lpf|
    with_fx :echo, phase: 1 do |echo|
      with_fx :ring_mod, freq: :C4, mix: 0.68 do
        [1,2,4,4,4,4,6].choose.times do
          play chord([:Df4, :E4, :Cf4, :F4].ring.tick, :augmented), sustain: s1/2, release: s1/2
          control echo, phase: [0.33,0.5,0.5,0.75,0.66].choose
          sleep s1
        end
      end
    end
  end
end
