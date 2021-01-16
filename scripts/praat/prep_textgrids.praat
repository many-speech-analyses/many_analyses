data_tg$ = "../../data/textgrids"
data_trials$ = "../../data/trial-lists"

tgs = Create Strings as file list: "tgs_list", "'data_tg$'/*.TextGrid"

tgs_no = Get number of strings

# Number of words in the stimulus utterance.
words_no = 11

for tg from 1 to tgs_no
  selectObject(tgs)
  tg_path$ = Get string: tg
  this_tg = Read from file: "'data_tg$'/'tg_path$'"
  speaker$ = tg_path$ - ".TextGrid"
  trials = Read Table from comma-separated file: "'data_trials$'/'speaker$'.csv"
  selectObject(this_tg)

  # Remove tiers "Syllable", "Vowel_modifier", "Vowel_noun"
  Remove tier: 2
  Remove tier: 2
  Remove tier: 2
  # Keep "Note" tier.

  # Duplicate tier "Condition" to position 2
  Duplicate tier: 1, 2, "words"
  Duplicate tier: 1, 4, "trial"
  # Numeric index of tiers.
  condition = 1
  words = 2
  note = 3
  trial = 4
  # Remove text from intervals in Words.
  # The second and third arguments (1, 0) mean from first to last interval.
  Replace interval texts: words, 1, 0, ".*", "", "Regular Expressions"
  Replace interval texts: trial, 1, 0, ".*", "", "Regular Expressions"

  # Now the TextGrid has the following tiers:
  # - Condition
  # - Words (= Condition)
  # - Note

  # Loop through the Words (2) tier and create 11 equally sized intervals.
  int_no = Get number of intervals: condition

  # Index for trial-lists.
  q = 1

  for int from 1 to int_no
    int_label$ = Get label of interval: condition, int

    if int_label$ != ""
      # Set trial number.
      Set interval text: trial, int, string$(q)

      # Split interval in 11 (there are 11 words in the stimulus utterance).
      int_start = Get start time of interval: condition, int
      int_end = Get end time of interval: condition, int
      int_dur = int_end - int_start
      fraction = int_dur / words_no

      selectObject(trials)
      colour$ = Get value: q, "target_colour"
      name$ = Get value: q, "target_name"

      # TODO: Need to get the article DET (changes depending on gender).
      words_labels$# = {"und", "jetzt", "sollst", "du", "den", "würfel", "auf", "DET", colour$, name$, "ablegen"}

      selectObject(this_tg)
      for y from 1 to words_no - 1
        Insert boundary: words, int_start + fraction * y
      endfor

      words_int = Get interval at time: words, int_start

      for w from 0 to words_no - 1
        Set interval text: words, words_int + w, words_labels$# [w + 1]
      endfor

      # Update index of trial-lists
      q += 1
    endif
  endfor

endfor
