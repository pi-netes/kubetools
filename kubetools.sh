SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ "${EUID}" == 0 ]] ; then
   echo "Do not run this as root."
   exit 1
fi

if [[ ! -f /etc/docker/daemon.json ]]; then
  echo is this new hardware? [Y/n]
  read IS_NEW_HARDWARE

  if [[ $IS_NEW_HARDWARE != 'n' ]]; then
    echo configuring new hardware...
    sudo bash $SCRIPT_DIR/onetimesettings.sh

    echo you should reboot before provisioning the cluster...
    echo then, you may access this menu by using the command 'kubetools'
    exit 0
  fi
fi

until [[ $OPTION == '0' ]]; do
  echo 'what would you like to do?
  [0]  quit

  [1]  create a new cluster [master]
  [2]  add a node to a cluster [worker]
  [3]  reset an old cluster

  [4]  add postgres operator to cluster (x86 only)
  [5]  add webhook listener to cluster

  [8]  create a new stateless app
  [9]  create a new stateful app'
  read OPTION

  if [[ $OPTION == '1' ]]; then
    bash $SCRIPT_DIR/newcluster.sh
  fi

  if [[ $OPTION == '2' ]]; then
    bash $SCRIPT_DIR/addnode.sh
  fi

  if [[ $OPTION == '3' ]]; then
    bash $SCRIPT_DIR/resetcluster.sh
  fi

  if [[ $OPTION == '4' ]]; then
    bash $SCRIPT_DIR/pgo.sh
  fi
done
