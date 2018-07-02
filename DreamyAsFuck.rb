# DreamyAsFuck

s = 5.0
live_loop :l1 do
  use_synth :hollow
  with_fx :gverb, room: 15, release: s + 0.5, mix: 0.1 do
    with_fx :rlpf, cutoff: 60, res: 0.7, cutoff_slide: s/3.0, res_slide: s/4.0 do |lpf|
      control lpf, cutoff: rrand_i(50, 83), res: rrand(0.1, 0.89)
      
      v1 = play 0, attack: s/2.5, sustain: s + 0.1, release: s/3.0, note_slide: 0.01, pan_slide: s/2
      control v1, note: scale([:Ds3, :A3, :Ds4, :A4].ring.tick, :melodic_major).choose, pan: rrand(-0.7, 0.7)
      
      v2 = play 0, attack: s/2.88, sustain: s - 0.5, release: s/2.5, note_slide: 0.1, pan_slide: s/3
      control v2, note: scale([:Ds2, :A2].ring.tick, :melodic_minor).choose, pan: rrand(-0.35, 0.63)
      
      if one_in(6)
        v3 = play 0, attack: s/3, sustain: s, release: s * 2, note_slide: s * 2, amp_slide: s/2
        control v3, note: scale([:Fs1].ring.tick, :diatonic).choose, amp: rrand(2, 7)
      end
      
    end
  end
  sleep s
end

t = 6
s2 = (s/4)/t
t2 = 3
s3 = s2/t2
live_loop :l2 do
  #stop
  use_synth :sine
  t.times do |i|
    with_fx :rlpf, cutoff: 71, res: 0.55, cutoff_slide: 0.015 do |lpf|
      control lpf, cutoff: 30 + (10 * i)
      if not one_in(5)
        play scale(:Ds3, :melodic_major).take(t - rrand_i(0, 2)).tick, release: 0.1
      else
        play scale(:Ds3, :melodic_minor).reverse.take(t).tick, release: 0.1
      end
      if one_in(16)
        t2.times do
          with_fx :echo, phase: 0.5 do
            play scale(:C6, :melodic_minor_asc).choose, release: 0
            sleep s3
          end
        end
      else
        sleep s2
      end
    end
  end
end

s4 = s2 * 4
live_loop :l3 do
  #stop
  use_synth :beep
  with_fx :rlpf, cutoff: 60, res: 0.35, cutoff_slide: s4 do |lpf|
    with_fx :echo, decay: s4 * 2, phase: s4 do
      t = [3,4,4,5].choose
      t.times do
        if one_in(2.5)
          play scale(:Ds5 + 7, :melodic_major).choose, release: rrand(s2, s4)
          control lpf, cutoff: [57, 63, 75, 80].ring.reflect.tick, res: rrand(0, 0.4)
        end
        sleep s4 / t
      end
    end
  end
end
