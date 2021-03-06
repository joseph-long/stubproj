source ~/.stubproj/bin/common.sh

function do_remotely {
    host=$1
    command=$2
    echo "Doing command:" $command "on host:" $host
    ssh "$host" -t "bash --rcfile <(echo '. ~/.bashrc; $command && exit 0')"
}

function proj {
    set_from_proj_name $1
    ssh "$PROJ_HOST" -t "bash --rcfile <(echo '. ~/.bashrc; localproj $PROJ_NAME')"
}

function projnb {
    set_from_proj_name $1
    do_remotely $PROJ_HOST "localprojnb $PROJ_NAME" &&
    open "http://$PROJ_HOST:$PROJ_PORT/" &&
    echo "Opened a browser pointing at notebook running at http://$PROJ_HOST:$PROJ_PORT/"
}

function projnboff {
    set_from_proj_name $1
    do_remotely $PROJ_HOST "localprojnboff $PROJ_NAME"
}

function stubproj {
    if [ "$#" -ne 4 ]; then
        show_usage
        return 1
    fi
    PROJ_NAME="$1"
    PROJ_HOST="$2"
    PROJ_DIR="$3"
    PROJ_PORT="$4"

    echo "PROJ_HOST=" $PROJ_HOST
    echo "PROJ_DIR=" $PROJ_DIR
    echo "PROJ_NAME=" $PROJ_NAME
    echo "PROJ_PORT=" $PROJ_PORT

    do_remotely $PROJ_HOST "stubproj $PROJ_NAME $PROJ_HOST $PROJ_DIR $PROJ_PORT"
    
    touch ~/.stubproj/projects
    if [ $(grep $PROJ_NAME ~/.stubproj/projects | wc -l) != 0 ]; then
        echo "Name already present in ~/.stubproj/projects locally:"
        echo $(grep $PROJ_NAME ~/.stubproj/projects)
    else
        echo "Appending a line to ~/.stubproj/projects locally:"
        echo $PROJ_NAME $PROJ_HOST $PROJ_DIR $PROJ_PORT
        echo $PROJ_NAME $PROJ_HOST $PROJ_DIR $PROJ_PORT >> ~/.stubproj/projects
    fi
}
