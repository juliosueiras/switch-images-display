for i in $(ls node_modules/@smui); do
  if [[ -f "node_modules/@smui/$i/_index.scss" ]]; then
    sed -i "/@use 'smui-theme';/d" "node_modules/@smui/$i/_index.scss"
  fi
done
