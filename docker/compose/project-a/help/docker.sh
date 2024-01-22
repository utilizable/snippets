#!/bin/bash

gRelativePath=$(dirname $(realpath -s "$0"))
. $gRelativePath/misc.sh
. $gRelativePath/log.sh


function dockerComposeAttach() {
  echo -n "${mBranchName}/docker-compose.yml" >> ${OLDPWD}/.env
  sed -r -i 's/(yml)([a-z])/\1:\2/g' ${OLDPWD}/.env
};

function dockerComposeCheck() {
	mComposeStatus=$( 
(docker-compose config -q) 2>&1
  );

  mComposeInvalid=$(
  echo "${mComposeStatus}"        \
  | sed '/invalid/!d'             \
  | sed "s/.*'.\/\(.*\)'.*$/\1/"  \
  | sed 's/\//\\\//g'
  )

  if [[ "${mComposeInvalid}" != "" ]]; then

    log "ERROR" "[BRANCH: ${mBranchName}]; 
    docker-compose.yaml is invalid!; 
    excluding from build!"
    
    sed -i "s/${mComposeInvalid}//g" ".env"
    sed -i 's/:$//g' .env
  else

    log "INFO" "[BRANCH: ${mBranchName}]; 
    docker-compose.yaml is valid!; 
    including to build!"
  fi
}

function docker() {

  miscMake

  var="$(find ~+ -name '*docker-compose*')";

  IFS=$' ' read -rd '' -a mDockerBranchesRaw <<<"${var}";

  vScriptPath=$(
    echo ${PWD}/ | sed 's/\//\\\//g'
  );

  declare -A mDockerBranchesParsed; 

  for i in ${mDockerBranchesRaw[@]}; do
    vBranchName=$(
      echo $i | sed "s/${vScriptPath}\(.*\)\/.*$/\1/"
    );
    vBranchPath=$(
      echo $i | rev | sed 's/^[^\/]*\///' | rev
    );
    mDockerBranchesParsed[${vBranchName}]="${vBranchPath}"
  done

  touch .env
  #sed -i '/COMPOSE_FILE/d' .env
  echo -n "COMPOSE_FILE=" > .env

  for i in ${!mDockerBranchesParsed[@]}; do
    mBranchPath=${mDockerBranchesParsed[${i}]}
    mBranchName=${i}

    pushd ${mBranchPath} >/dev/null

    dockerComposeAttach

    popd >/dev/null

    dockerComposeCheck

  done
}

docker $@
