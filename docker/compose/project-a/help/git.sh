#!/bin/bash

gRelativePath=$(dirname $(realpath -s "$0"))
. $(dirname $(realpath -s "$0"))/misc.sh
. $(dirname $(realpath -s "$0"))/log.sh

function gitCollectBranchStatus() {

  mStatusRaw=$(git status | sed '/branch/d')
  mStatusParsed=""

  if [[ "$mStatusRaw" != *"clean"* ]]; then
    mStatusParsed=$(
      echo "$mStatusRaw"          \
      | sed '/branch/d'           \
      | sed 's/([^()]*)//g'       \
      | sed -r '/^\s*$/d'         \
      | sed '/\t/s/.*:/\U &/g'    \
      | sed '/\t/s/\t/-/g'        \
      | sed 's/ $//g'             \
      | sed 's/$/;/g'             \
      | sed 's/ \{2,\}//g'        \
    )
  else
    mStatusParsed=$(
      echo "$mStatusRaw" \
			| sed '/ahead/d' \
      | sed 's/(.*//g' \
      | sed 's/$/;/' \
    )
  fi

  echo $mStatusParsed
}

function gitLog() {

  mBranchStatus=$(gitCollectBranchStatus)

  if [[ "$mBranchStatus" == *"%"* ]]; then
    log "WARN" "[BRANCH: ${mBranchName}];$mBranchStatus";
  else
    log "INFO" "[BRANCH: ${mBranchName}];$mBranchStatus";
  fi
}

function gitAdd() {
  git add . 
}

function gitCommit() {
  mBranchStatus=$(gitCollectBranchStatus)

  if [[ "$mBranchStatus" == *"committed"* ]]; then
    mCommitMessage=$(
    echo $mBranchStatus         \
    | sed '/$/i [auto commit]'  \
    | sed 's/;/\n/g'            \
    | sed '/committed/d'
    )
    git commit -m "$mCommitMessage" >/dev/null
  fi

  if [[ "$mBranchStatus" == *"%"* ]]; then
    log "WARN" "[BRANCH: ${mBranchName}];$mBranchStatus";
  else
    log "INFO" "[BRANCH: ${mBranchName}];$mBranchStatus";
  fi
}

function main() {
  miscMake

  var="$(git worktree list)"; 

  IFS=$'\n' read -rd '' -a mBranchesRaw <<<"${var}"; 

  declare -A mBranchesParsed;
  
  for ((i=0;i<${#mBranchesRaw[@]};i++)); do
		vBranch=${mBranchesRaw[${i}]}
    vBranchName=$(
      echo "${vBranch}" | sed 's/.*\[\(.*\)\].*/\1/' 
    ); 
 
    mArrayOrder+=( "$vBranchName" )

    vBranchPath=$(
      echo "${vBranch}" | sed -e 's/ .*//g; s/://g'
    );
    mBranchesParsed[${vBranchName}]="${vBranchPath}"
  done
  
#  for i in ${!mBranchesParsed[@]}; do

  for ((l=${#mArrayOrder[@]}-1;l>=0;l--)); do 

    mBranchName=${mArrayOrder[$l]} 
    mBranchPath=${mBranchesParsed[${mArrayOrder[$l]}]}
    
    pushd ${mBranchPath} >/dev/null    

    gitAdd 
    gitCommit 
  #  gitLog

    popd >/dev/null    
  done
}

main $@



# +-----------+
# |   ideas   |
# +-----------+

function gitTrash() {
  if [ -f "readme" ]; then
    mTrackedFiles=( $(
      cat readme                  \
      | sed '0,/CONTENT:/d'       \
      | sed '0,/./d'              \
      | sed 's/[^[:alpha:].]//g'
    ) );
  
    mFilesCurrent=( $(ls) );
    
    for j in "${mTrackedFiles[@]}"; do
      for k in "${!mFilesCurrent[@]}"; do
        if [[ $j == ${mFilesCurrent[$k]} ]]; then
          unset 'mFilesCurrent[k]'
        fi      
      done
    done
    
    for i in "${mFilesCurrent[@]}"; do
      mv $i .gittrash/$i
    done
  fi
}

gitUntracked() {
  mUntrackedFiles=""
  for i in ${_branches[@]}; do
    pushd $i >/dev/null 
    _untrackedFiles[$i]="$(              
      git status                    \
      | sed '0,/^Untracked files/d' \
      | sed 's/([^()]*)//g'         \
      | sed '/^[\t]/!d'             \
      | sed 's/\t//g'         
    )"
    popd >/dev/null
  done
  for i in ${!_untrackedFiles[@]}; do
    mFiles=( ${_untrackedFiles[${i}]} );
    if [[ "${#mFiles[@]}" -gt "0" ]]; then
      for j in ${mFiles[@]}; do
        pushd $i >/dev/null 
        if [ "$(cat ${j} | wc -l)" -eq "0" ]; then
          rm ${j}
        fi
        popd >/dev/null
      done
    fi    
  done
}
