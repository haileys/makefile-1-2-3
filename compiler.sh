#!/bin/bash
spreadsheet="$1"

col_names="ABCDEFGHIJKLMNOPQRSTUVWXYZ"

echo -n > Makefile.tmp
all_cells=""

row_idx=1
col_max=0
while read line; do
  col_idx=0
  IFS=", "
  for cell_value in $line; do
    cell_name="${col_names:$col_idx:1}$row_idx"
    all_cells="$all_cells $cell_name"
    if [ $col_idx > $col_max ]; then
      col_max=$col_idx
    fi
    if [[ "${cell_value:0:1}" = "=" ]]; then
      cell_expr="${cell_value:1}"
      cell_expr="$(echo "$cell_expr" | sed -Ee 's/([A-Z]+[0-9]+)/$(shell cat \1)/g')"
      cell_deps="$(echo "$cell_expr" | sed -Ee 's/([A-Z]+[0-9]+)/_\1_/g')"
      cell_expr="echo '$cell_expr' | bc > $cell_name"
      cell_deps="_${cell_deps}_"
      cell_deps="$(echo "$cell_deps" | sed -Ee 's/_[^_]+_/ /g')"
      echo -e "$cell_name: Makefile $cell_deps\n\t$cell_expr" >> Makefile.tmp
    else
      echo -e "$cell_name: Makefile\n\techo $cell_value > $cell_name" >> Makefile.tmp
    fi
    col_idx=$(($col_idx+1))
  done
  row_idx=$(($row_idx+1))
done < <(cat "$1")

echo -e "clean:\n\trm -f $all_cells" >> Makefile.tmp
echo -e "Makefile: compiler.sh $spreadsheet\n\t./compiler.sh $spreadsheet" >> Makefile.tmp
echo -e "output.txt: $all_cells Makefile\n\tcat $all_cells | xargs -L $(($col_max + 1)) | column -t > output.txt" > Makefile

cat Makefile.tmp >> Makefile
rm Makefile.tmp
