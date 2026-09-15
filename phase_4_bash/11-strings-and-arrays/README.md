# String Manipulation, Parameter Expansion, and Arrays

Session 11 of Phase 4 — Bash.

## What this covers
- Default value expansions: ${var:-x}, ${var:=x}, ${var:?msg}, ${var:+x}
- Stripping prefixes/suffixes: # ## (front, shortest/longest) and % %% (back, shortest/longest)
- String length: ${#variable}
- Search and replace: ${var/old/new} (first match) vs ${var//old/new} (all matches)
- Declaring and accessing arrays, ${#array[@]} for count, "${!array[@]}" for indexes
- "${array[@]}" vs "${array[*]}" quoting — the array version of the $@ vs $* gotcha from Session 8

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the array quoting comparison, side by side
- scripts/ — practice script combining everything from this session

## Key takeaway
Parameter expansion does string manipulation directly in Bash, no external process needed - ${file##*/} and ${file%/*} replace basename/dirname, for example. Arrays with quoted "${array[@]}" are the correct way to loop over a list of servers, files, or anything that might contain spaces, exactly parallel to "$@" for script arguments.
