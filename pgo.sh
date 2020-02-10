# see https://access.crunchydata.com/documentation/postgres-operator/latest/quickstart/
cd $HOME

echo verifying k8s cluster existence...
kubectl cluster-info
if [[ $? != '0' ]]; then
  echo no cluster present... please create a cluster
  exit 0
fi


echo verifying existence of storageclasses...
STORAGE_CLASSES=$(kubectl get storageclass 2>&1)
if [[ $STORAGE_CLASSES == 'No resources found in default namespace.' ]]; then
  echo no storageclass present.. please add one
  exit 0
fi

echo cloning the ansible playbook...
git clone https://github.com/CrunchyData/postgres-operator.git
cd postgres-operator
git checkout v4.2.1 # you can substitute this for the version that you want to install
cd ansible

echo configuring playbook...
echo setting k8s context...
KUBERNETES_CONTEXT=$(kubectl config current-context)
sed -i "s/# kubernetes_context=''/kubernetes_context='$KUBERNETES_CONTEXT'/" inventory

echo setting pg operator admin pw...
PGO_ADMIN_PASSWORD='changeme'
until [[ $PGO_ADMIN_PASSWORD == $PGO_ADMIN_PASSWORD_VERIFY ]]; do
  echo what should the admin password be?
  read PGO_ADMIN_PASSWORD

  echo retype:
  read PGO_ADMIN_PASSWORD_VERIFY
done
sed -i "s/pgo_admin_password=''/pgo_admin_password='$PGO_ADMIN_PASSWORD'/" inventory

echo setting operator storageclass...
echo $STORAGE_CLASSES
echo which storageclass would you like to use? [ie 'local-storage']
read SELECTED_STORAGE_CLASS
sed -i "s/backrest_storage='.*'/backrest_storage='$SELECTED_STORAGE_CLASS'/" inventory
sed -i "s/backup_storage='.*'/backup_storage='$SELECTED_STORAGE_CLASS'/" inventory
sed -i "s/primary_storage='.*'/primary_storage='$SELECTED_STORAGE_CLASS'/" inventory
sed -i "s/replica_storage='.*'/replica_storage='$SELECTED_STORAGE_CLASS'/" inventory

echo would you like to make any further edits to the playbook? [y/N]
read SHOULD_OPEN_PLAYBOOK
if [[ $SHOULD_OPEN_PLAYBOOK == 'y' ]]; then
  nvim inventory
fi

ansible-playbook -i inventory --tags=install main.yml

export PGOUSER="${HOME?}/.pgo/pgo/pgouser"
export PGO_CA_CERT="${HOME?}/.pgo/pgo/client.crt"
export PGO_CLIENT_CERT="${HOME?}/.pgo/pgo/client.crt"
export PGO_CLIENT_KEY="${HOME?}/.pgo/pgo/client.pem"
export PGO_APISERVER_URL='https://127.0.0.1:8443'

echo would you like to PGO environment variables to your .bashrc? [y/N]
read SHOULD_APPEND_BASHRC
if [[ $SHOULD_APPEND_BASHRC == 'y' ]]; then
cat <<EOF >> ~/.bashrc
export PGOUSER="${HOME?}/.pgo/pgo/pgouser"
export PGO_CA_CERT="${HOME?}/.pgo/pgo/client.crt"
export PGO_CLIENT_CERT="${HOME?}/.pgo/pgo/client.crt"
export PGO_CLIENT_KEY="${HOME?}/.pgo/pgo/client.pem"
export PGO_APISERVER_URL='https://127.0.0.1:8443'
EOF
fi

cd $HOME rm -rf postgres-operator
