GNOME_POLKIT="/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
if [ -f ${GNOME_POLKIT} ]; then
  ${GNOME_POLKIT} &
fi
