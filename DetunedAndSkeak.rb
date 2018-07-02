# DetunedAndSkeak

tone = :Ef2   # Good values => :Gf1, :Ef2
# BASS
bass = {
  :enabled => true, # set false to mute
  :sleep => 24.0,
  :times => 16,
  :cutoff => 80,
  :cueSleep => 0
}
bass[:cueSleep] = bass[:sleep]/bass[:times]

live_loop :lBass do
  #stop
  use_synth :dtri
  with_fx :rlpf, cutoff: bass[:cutoff], res: 0.67, cutoff_slide: 0.25 do |lpf|
    s1 = play 0, sustain: bass[:sleep], attack: 1.25, release: 0.01, note_slide: 0.1, detune_slide: 0.5, pan_slide: 0.75
    bass[:times].times do |i|
      if bass[:enabled]
        control lpf, cutoff: (bass[:cutoff] - (0.25 * i)).abs
        control s1, note: scale(tone, :hex_major7).choose, detune: rrand(0.001, 0.01) * i, pan: rrand(-0.7, 0.7), amp: rrand(0.7, 0.85)
      end
      cue :bass
      sleep bass[:cueSleep]
    end
  end
end

# PRUISss
prui = {
  :v1Semi => 7, # default: 19; NOTE: progression (7, 12, 19, 24); Microtunning: add .XXX to this values
  :v2Semi => 36 - 0.25, # default: 36
  :v2Prob => 12, # default: 12
  :skipProb => 7, # default: 4
  :sleep  => 0.25 # default: 0.1; More good values: 0.05, 0.2, 0.25, 0.5
}

live_loop :lPrui do
  #stop
  zsync :bass  # Turn on and off
  use_synth :sine
  [3, 4, 4, 7].choose.times do
    if not one_in(prui[:skipProb])
      with_fx :krush, gain: 0.45 do
        with_fx :rlpf, cutoff: 65, res: 0.43, cutoff_slide: 0.5 do |lpf|
          control lpf, cutoff: rrand_i(55, 70)
          play scale(tone + prui[:v1Semi], :hex_major7).choose, release: 1.125
          if one_in(prui[:v2Prob])
            play scale(tone + prui[:v2Semi], [:messiaen5, :messiaen6, :messiaen7].ring.tick).choose, release: rrand(2.3, 3), amp: 0.85
          end
        end
      end
    end
    sleep prui[:sleep]
  end
end

# KICK
kick = {
  :times => 1,
  :sleep => 0
}
kick[:sleep] = bass[:cueSleep] / (kick[:times] * 2)

live_loop :lKick do
  #stop
  kick[:times].times do
    with_fx :rlpf, cutoff: 80, res: 0.20, res_slide: 0.2 do |lpf|
      control lpf, cutoff: rrand_i(70, 90), res: rrand(0.18, 0.5)
      sample :drum_heavy_kick, amp: rrand(9, 15)
    end
    cue :kick
    sleep kick[:sleep]
  end
end

# CYMBALS
cymbals = {
  :hhTimes => [2, 3, 3, 4, 4, 4, 4, 4, 6]
}
live_loop :lCymbals do
  #stop
  sync :kick
  hhTimes = cymbals[:hhTimes].choose
  hhTimes.times do
    # Hi-hat
    sample [:drum_cymbal_closed, :drum_cymbal_closed, :drum_cymbal_closed, :drum_cymbal_closed, :drum_cymbal_open, :drum_cymbal_hard].ring.tick, amp: rrand(0.15, 0.35)
    # Accent Cymbals
    if one_in(12)
      sample [:drum_splash_soft, :drum_cymbal_soft].choose, amp: rrand(0.35, 0.65), rate: [1, -1].choose
    end
    sleep kick[:sleep] / hhTimes
    
  end
end










