data_tg$ = "../../data/textgrids"
data_trials$ = "../../data/trial-lists"
datasets$ = "../../data/dataset"

objects = Read Table from comma-separated file: "'datasets$'/objects.csv"
colours = Read Table from comma-separated file: "'datasets$'/colours.csv"

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
  Duplicate tier: 1, 3, "phones"
  Duplicate tier: 1, 5, "trial"
  # Numeric index of tiers.
  condition = 1
  words = 2
  phones = 3
  note = 4
  trial = 5
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

      selectObject(trials)
      colour$ = Get value: q, "target_colour"
      selectObject(colours)
      col_row = Search column: "colour", colour$
      col_phones = Get value: col_row, "n_phones"

      selectObject(trials)
      name$ = Get value: q, "target_name"
      selectObject(objects)
      target_row = Search column: "object", name$
      target_phones = Get value: target_row, "n_phones"

      selectObject(trials)
      # Number of phones in the frame sentence
      total_ints = 3 + 4 + 5 + 2 + 3 + 5 + 3 + 3  + col_phones + target_phones + 6
      fraction = int_dur / total_ints

      # TODO: Need to get the article DET (changes depending on gender).
      words_labels$# = {"und", "jetzt", "sollst", "du", "den", "würfel", "auf", "DET", colour$, name$, "ablegen"}

      selectObject(this_tg)

      # I am sure there is a more elegant way.
      Insert boundary: words, int_start + fraction * 3
      Insert boundary: words, int_start + fraction * (3 + 4)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2 + 3)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2 + 3 + 4)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2 + 3 + 4 + 3)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2 + 3 + 4 + 3 + 3)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2 + 3 + 4 + 3 + 3 + col_phones)
      Insert boundary: words, int_start + fraction * (3 + 4 + 5 + 2 + 3 + 4 + 3 + 3 + col_phones + target_phones)
      # Insert boundary: words, int_start + fraction * 6

      words_int = Get interval at time: words, int_start

      for w from 0 to words_no - 1
        Set interval text: words, words_int + w, words_labels$# [w + 1]
      endfor

      for p from 1 to total_ints - 1
        Insert boundary: phones, int_start + fraction * p
      endfor

      # Update index of trial-lists
      q += 1
    endif
  endfor

endfor
