#!/bin/bash
# This is an install script for kadavris/mqtt-tools repo
# Run without arguments to get help

EXEDEST="/usr/local/lib/kadavris/mqtt"
SYSTEMD="/etc/systemd/system"
ETC="/etc/smarthome"

USER="smarthome"
GROUP="smarthome"

OWNER="--owner=${USER} --group=${GROUP}"
EXEOPT="-D ${OWNER} --mode=0755"
#SVCOPT="${OWNER} --mode=0644"
INIOPT="-D ${OWNER} --mode=0640"

INST="/bin/install"

# in: <src file> <dst dir> <new name or ''> <install params>
function install_to_dir_w_check() {
    src=$1; shift
    ddir=$1; shift
    nn=$1; shift
    [ "$nn" == "" ] && nn=$(basename "$src")
    nn="${ddir}/${nn}"

    if [ "$src" -nt "$nn" ]; then
        [ -e "$nn" ] && nn="${nn}.new"
        echo "+ Will install $src ==> $nn"
        $INST $* "$src" "$nn"
    else
        echo "- Skipping older file: $src"
    fi
}

function install_mqtt() {
    ETCM="${ETC}/mqtt"
    srcd="."
    $INST $EXEOPT "${srcd}/mqtt" "$EXEDEST"
    #install_to_dir_w_check "${srcd}/mqtt.service.sample" "${SYSTEMD}" "mqtt.service" "$SVCOPT"
    install_to_dir_w_check "${srcd}/mqtt.ini.sample" "$ETCMIK" "mqtt.ini" "$INIOPT"
}

########################
if [ "$1" == "" ]; then
    echo Use \'install.sh all\' to process all of the files
    echo Or specify \'mikrotik\' or \'power\' or \'storage\' to install specific ones
    exit 0
fi

if [ ! -d "$ETC" ]; then
    mkdir -p "$ETC"
    chown "$USER:$GROUP" "$ETC"
    chmod ug+rwx "$ETC"
fi

if [ "$1" == "all" ]; then
    list="mqtt"
else
    list="$1"
fi

for opt in $list
do
    install_$opt
done

echo "You may need to check the permissons and ownership of intermediate directories:"
echo "  - $ETC"
echo "  - $EXEDEST"
echo "Due to 'install' utility not making it all the way up"
