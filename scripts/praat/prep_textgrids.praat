#####################################################################
# prep_textgrids.praat
#####################################################################
# This script enhances the annotation/segmentation of the production
# study TextGrids. The following information is included:
#   - condition (NF, AF, ANF)
#   - word-level segmentation
#   - phone-level segmentation
#   - trial number
#   - notes
#
# The "notes" tier (tier 5) has "error" as label if that token is
# an error and should be discarded.
#####################################################################

include split.proc.praat

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
  Duplicate tier: 1, 4, "trial"
  Duplicate tier: 1, 5, "notes"
  # Numeric index of tiers.
  condition = 1
  words = 2
  phones = 3
  note = 6
  trial = 4
  notes = 5
  # Remove text from intervals in Words.
  # The second and third arguments (1, 0) mean from first to last interval.
  Replace interval texts: words, 1, 0, ".*", "", "Regular Expressions"
  Replace interval texts: trial, 1, 0, ".*", "", "Regular Expressions"
  Replace interval texts: notes, 1, 0, ".*", "", "Regular Expressions"

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

      int_start = Get start time of interval: condition, int
      int_end = Get end time of interval: condition, int
      int_dur = int_end - int_start
      int_mid = int_start + (int_dur / 2)

      note_int = Get interval at time: note, int_mid
      the_note$ = Get label of interval: note, note_int

      if the_note$ != ""
        Set interval text: notes, int, the_note$
      endif

      selectObject(trials)
      colour$ = Get value: q, "target_colour"
      selectObject(colours)
      col_row = Search column: "colour", colour$
      col_phones = Get value: col_row, "n_phones"
      colour_infl$ = Get value: col_row, "inflected"
      colour_ipa$ = Get value: col_row, "ipa"

      selectObject(trials)
      name$ = Get value: q, "target_name"
      selectObject(objects)
      target_row = Search column: "object", name$
      target_phones = Get value: target_row, "n_phones"
      target_det$ = Get value: target_row, "det"
      target_ipa$ = Get value: target_row, "ipa"

      selectObject(trials)
      # Number of phones in the frame sentence
      und = 3
      jetzt = 4
      sollst = 5
      du = 2
      den = 3
      wurfel = 6
      auf = 2
      det = 3
      ablegen = 7
      total_ints = und + jetzt + sollst + du + den + wurfel + auf + det + col_phones + target_phones + ablegen
      fraction = int_dur / total_ints

      words_labels$# = {"und", "jetzt", "sollst", "du", "den", "würfel", "auf", target_det$, colour_infl$, name$, "ablegen"}

      selectObject(this_tg)

      # I am sure there is a more elegant way.
      Insert boundary: words, int_start + fraction * und
      Insert boundary: words, int_start + fraction * (und + jetzt)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du + den)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du + den + wurfel)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du + den + wurfel + auf)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du + den + wurfel + auf + det)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du + den + wurfel + auf + det + col_phones)
      Insert boundary: words, int_start + fraction * (und + jetzt + sollst + du + den + wurfel + auf + det + col_phones + target_phones)
      # Insert boundary: words, int_start + fraction * 6

      words_int = Get interval at time: words, int_start

      for w from 0 to words_no - 1
        Set interval text: words, words_int + w, words_labels$# [w + 1]
      endfor

      for p from 1 to total_ints - 1
        Insert boundary: phones, int_start + fraction * p
      endfor

      phones_int = Get interval at time: phones, int_start

      phones_labels$# = {"u", "n", "d", "j", "e", "tz", "t", "s", "o", "l", "s", "t",
        ... "d", "u", "d", "e", "n", "w", "ü", "r", "f", "ə", "l", "aʊ", "f"}

      # Number of phones in "und jetzt solst du den Würfel auf"
      n_und_auf = und + jetzt + sollst + du + den + wurfel + auf

      for f from 0 to n_und_auf - 1
        Set interval text: phones, phones_int + f, phones_labels$# [f + 1]
      endfor

      phones_int += n_und_auf
      for f from 1 to 3
        Set interval text: phones, phones_int + f - 1, mid$(target_det$, f, 1)
      endfor

      @split (".", colour_ipa$)

      phones_int += 3
      for f from 1 to col_phones
        Set interval text: phones, phones_int + f - 1, split.array$[f]
      endfor

      @split (".", target_ipa$)

      phones_int += col_phones
      for f from 1 to target_phones
        Set interval text: phones, phones_int + f - 1, split.array$[f]
      endfor

      phones_int += target_phones
      ablegen$# = { "a", "b", "l", "eː", "g", "ə", "n" }
      for f from 1 to ablegen
        Set interval text: phones, phones_int + f - 1, ablegen$# [f]
      endfor

      # Update index of trial-lists
      q += 1
    endif
  endfor

  selectObject(this_tg)
  Remove tier: 6

  Save as text file: "../../osf/data/production/audio/'speaker$'.TextGrid"

endfor
