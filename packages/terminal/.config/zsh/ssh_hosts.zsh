# hosts
# kitty.sh -> nyaa-proxy
# dynip -> nyaa-core nyaa-gate
alias kitty.sh="ssh kitty@kitty.sh"
alias nyaa-core="ssh kitty@nyaa-core.kitty.sh -p 22335"
alias kitty.sh-reverse="ssh -R 2222:localhost:22 -N kitty@kitty.sh"
alias reverse-local="ssh kitty@localhost -p 2222"
