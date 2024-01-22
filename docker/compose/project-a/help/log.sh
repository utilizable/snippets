#!/bin/bash

declare -A gColors=(
  ["RED"]="0;31m"
  ["LIGHT_RED"]="1;31m"    
  ["GREEN"]="0;32m"
  ["LIGHT_GREEN"]="1;32m"
  ["BROWN"]="0;33m"
  ["LIGHT_BROWN"]="1;33m"
  ["BLUE"]="0;34m"
  ["LIGHT_BLUE"]="1;34m")

function logSeparator(){
	mWidthConsole=$(tput cols)
  for ((i=0,j=0,k=0;i<${mWidthConsole};i++,j++)); do

    mSplitColumns=$(( ${mWidthConsole} / 2 ))
    mPivot=$(( ${mSplitColumns} / 4 ))
    mModulo=$(expr $j % ${mPivot})
    mColor=$(( 88 + ${k} ))

    if [[ ${i} -le ${mSplitColumns} ]]; then
      if [[ ${mModulo} -eq 0 ]]; then ((k++)); fi;
    else
      if [[ ${mModulo} -eq 0 ]]; then ((k--)); fi;
    fi
    if [[ ${mModulo} -eq 0 ]]; then j=0; fi;
    echo -en "\e[38;5;${mColor}m-\e[0m"; 
  done
}

function logPrint() { 

  pCallerName=$2
  pCallerFunction=$3
  pCallerMessage=$4

  mColumnOne=$(echo -en         \
  "\033[${gColors["BROWN"]}"    \
  "[${pCallerName}]"            \
  "\033[0m"                     \
  | sed 's/ //g'
	);

  mColumnTwo=$(echo -en               \
	"\033[${gColors["LIGHT_BROWN"]}"    \
	"[${pCallerFunction}]"              \
	"\033[0m"                           \
  | sed 's/ //g'
	);

  # lorem ipsum
  loremGenerator=$(
  curl -s http://metaphorpsum.com/paragraphs/2  \
  | sed -e 's/;//g'                             \
  | sed -z 's/\n/;/g'                           \
  | sed 's/;/%;/g'
  );

  #pCallerMessage=$(echo ${loremGenerator})

  IFS=$';' read -rd '' -a arr <<<"${pCallerMessage}"
  mOutput=""

	mWidthConsole=$(tput cols)
  for (( i=0;i<${#arr[@]};i++ )); do

    var=$(
    echo ${mColumnOne}  \
    | sed 's/.*m\[/[/'  \
    | sed 's/\].*/]/'   \
    ); 
    mWidthColumnOne=${#var};

    var=$(
      echo ${mColumnTwo}  \
      | sed 's/.*m\[/[/'  \
      | sed 's/\].*/]/'   \
    ); 
    mWidthColumnTwo=${#var};

    mWidthColumnsTwoAndOne=$((
      ${mWidthColumnOne} + ${mWidthColumnTwo} + 4
    ));

    mWidthColumnThree=$(( 
      ${mWidthConsole} - ${mWidthColumnsTwoAndOne}
    ));

    mParagraphSize=${#arr[$i]}

    while 
(( ${mWidthColumnThree} < ${mParagraphSize} )); do 
			mParagraphSize=$(( 
      ${mParagraphSize} - ${mWidthColumnThree}
      ));
    done

    mEmtpySpaceColumnThree=$((
    ${mWidthColumnThree} - ${mParagraphSize}
    ));

    mSpacing=$((
    ${memtpyspacecolumnthree} + ${mWidthColumnThree}
    ));

    mCounterNewLine=$(echo ${arr[$i]} | sed 's/[^%]//g' | wc -L)
    mParsedMessage=$(echo -n ${arr[$i]} | sed 's/%/ /g')

    for (( j=0; j<${mCounterNewLine};j++ )); do
      mEmtpySpaceColumnThree=$((
      ${mEmtpySpaceColumnThree} + ${mWidthColumnThree}
      ));
    done

    mOutput+=$(
      echo -en "${mParsedMessage}" \
      | sed "s/$/$(printf "%${mEmtpySpaceColumnThree}s")/g" 
    )
  done

  mColumnThree=${mOutput}
  echo ""

  echo "${mColumnOne}|${mColumnTwo}|${mColumnThree}" \
  | column --separator '|'          \
  --table                           \
  --output-width $(tput cols)       \
  --table-noheadings                \
  --table-columns C1,C2,C3          \
  --table-wrap C3                   \
  | sed "s/ /$(echo -e "\e[$1")/3"  \
  | sed "s/$/$(echo -e '\e[0m')/"
  
  logSeparator
}
  
function log() {

  mCallerName=$( 
  echo $0           \
  | sed 's/.*\///g' 
  )

  mCallerFunction=$( 
  echo "${FUNCNAME[@]:1:${#FUNCNAME[@]}}" \
  | sed -e 's/main//g; s/ //g' 
  )

  if [ -z $mCallerFunction ]; then
    mCallerFunction=$(ps -o comm= $PPID)
  fi

  mCallerMessage=$( 
  echo $2 \
  | sed -e 's/;$//g' \
  | sed -e 's/; /;/g' \
  )

  case ${1} in
    ERROR)
      logPrint ${gColors["RED"]}      \
              "${mCallerName}"        \
              "${mCallerFunction}"    \
              "${mCallerMessage}"     \
              >&2 
      ;;
    INFO)
      logPrint ${gColors["GREEN"]}    \
              "${mCallerName}"        \
              "${mCallerFunction}"    \
              "${mCallerMessage}"         
      ;;
    WARN)
      logPrint ${gColors["BLUE"]}     \
              "${mCallerName}"        \
              "${mCallerFunction}"    \
              "${mCallerMessage}"         
      ;;
    SEPARATOR)
      logSeparator
      ;;
    *)
      log "ERROR" "unknow log level"
      return 1
      ;;
  esac
}

"$@"

# color sh ideas from
# https://misc.flogisoft.com/bash/tip_colors_and_formatting
function 256colors() {
  for fgbg in 38 48 ; do # Foreground / Background
      for color in {0..255} ; do # Colors
          # Display the color
          printf "\e[${fgbg};5;%sm  %3s  \e[0m" $color $color
          # Display 6 colors per lines
          if [ $((($color + 1) % 6)) == 4 ] ; then
              echo # New line
          fi
      done
      echo # New line
  done
}

function 256colors() {
  #Background
  for clbg in {40..47} {100..107} 49 ; do
  	#Foreground
  	for clfg in {30..37} {90..97} 39 ; do
  		#Formatting
  		for attr in 0 1 2 4 5 7 ; do
  			#Print the result
  			echo -en "\e[${attr};${clbg};${clfg}m ^[${attr};${clbg};${clfg}m \e[0m"
  		done
  		echo #Newline
  	done
  done
}
