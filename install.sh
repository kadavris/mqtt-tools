#!/bin/bash
# This is an install script for kadavris/mqtt-tools repo
# Run without arguments to get help

ENVFILE="./service-env"

if [ "$1" == "" ]; then
    echo "Use 'install.sh [-e <env file name>]'"
    echo "  '-e' option is to provide the existing environment variable list file with correct paths"
    echo "     by default $ENVFILE will be used"
    echo "NOTE: This script will not overwrite existing .ini files."
    exit 0
fi

USER="smarthome"
GROUP="smarthome"

/usr/bin/id "$USER" 2> /dev/null
if [ $? == 1 ]; then
    if [ -d "$CONFDIR" ]; then
        USER=$(/usr/bin/stat --printf %U "$CONFDIR")
        GROUP=$(/usr/bin/stat --printf %G "$CONFDIR")
        echo "I see that you use $USER:$GROUP credentials. Will obey."
    else
        echo "ERROR! Cannot determine what UID/GID to use."
        echo "You may want to add these by running:"
        echo "useradd -d '$CONFDIR' -s /sbin/nologin -g $GROUP $USER"
        exit 1
    fi
fi

OWNER="--owner=${USER} --group=${GROUP}"
EXEOPT="-v -C -D ${OWNER} --mode=0755"
INIOPT="-v -C -D ${OWNER} --mode=0640"

INST="/usr/bin/install"

while getopts "e:" OPT; do
    if [ "$OPT" = "e" ]; then
        ENVFILE=$OPTARG
    fi
done

# We'll use BINDIR, CONFDIR and PYTHONPATH from here:
. $ENVFILE

export BINDIR CONFDIR PYTHONPATH

# python's import dest
export py_namespace="$PYTHONPATH/kadpy"

# in: <src file> <dst dir> <new name or ''> <install params>
function install_to_dir_w_check() {
    src=$1; shift
    ddir=$1; shift
    nn=$1; shift
    [ "$nn" == "" ] && nn=$(basename "$src")
    nn="${ddir}/${nn}"

    # only if new file is newer we will copy it as .ini.sample for suggestions
    if [ "$src" -nt "$nn" ]; then
        [ -e "$nn" ] && nn="${nn}.new"
        echo "+ Will install $src ==> $nn"
        $INST $* "$src" "$nn"
    else
        echo "- Skipping older file: $src"
    fi
}

function install_mqtt() {
    srcd="."
    $INST $EXEOPT "${srcd}/mqtt-tool" "$BINDIR"
    install_to_dir_w_check "${srcd}/mqtt-tool.sample.ini" "$CONFDIR/mqtt" "mqtt-tool.ini" "$INIOPT"
}

########################

if [ ! -d "$CONFDIR" ]; then
    /usr/bin/mkdir -p -m 0770 "$CONFDIR"
    /usr/bin/chown "$USER:$GROUP" "$CONFDIR"
fi

list="mqtt"

for opt in $list
do
    install_$opt
done

echo "You may need to check the permissons and ownership of intermediate directories:"
echo "  - $CONFDIR"
echo "  - $BINDIR"
echo "Due to 'install' utility not making it all the way up"
