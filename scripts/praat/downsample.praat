
form Downsample audio files
  comment Select folder with files
  sentence directory ~/Documents
endform

writeInfoLine: "Job started..."

down$ = "'directory$'/downsampled"
createFolder: down$

wavs = Create Strings as file list: "wav_list", "'directory$'/*.wav"

wavs_no = Get number of strings

for wav from 1 to wavs_no

  selectObject(wavs)
  wav_path$ = Get string: wav
  this_wav = Read from file: "'directory$'/'wav_path$'"

  downsampled = Resample: 22100, 50

  Save as WAV file: "'down$'/'wav_path$'"

  removeObject: this_wav, downsampled

endfor
