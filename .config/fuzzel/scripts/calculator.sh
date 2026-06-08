#!/usr/bin/env bash

pkill -x fuzzel 2>/dev/null && exit 0

expr=$(fuzzel -d --prompt "= " --placeholder "2+2*3")
[ -z "$expr" ] && exit

result=$(EXPR="$expr" python3 -c "
import math, os, re, builtins

expr = os.environ['EXPR']

if not re.match(r'^[0-9a-zA-Z+*/()%^ .eE,_-]+$', expr):
    print('ERROR')
else:
    expr = expr.replace('^', '**')
    ns = {'__builtins__': {}}
    for name in ['abs','int','float','round']:
        ns[name] = getattr(builtins, name)
    for name in dir(math):
        if not name.startswith('_'):
            ns[name] = getattr(math, name)
    try:
        r = eval(expr, ns)
        if isinstance(r, float):
            print(f'{r:.10g}'.rstrip('.'))
        else:
            print(r)
    except Exception:
        print('ERROR')
" 2>&1)

[[ "$result" == ERROR ]] && {
  notify-send -u critical "Calc" "Invalid expression"
  exit 1
}

picked=$(echo "$result" | fuzzel -d --prompt "= " --no-sort)
[ -n "$picked" ] && echo "$picked" | wl-copy
