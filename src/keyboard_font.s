.segment "CHARS"

.scope NormalChars
  FILL_VALUE=$00
  .include "ascii_chars.inc"
.endscope

.scope HighlightedChars
  FILL_VALUE=$FF
  .include "ascii_chars.inc"
.endscope
